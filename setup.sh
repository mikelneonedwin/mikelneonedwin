#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# Ubuntu Workstation Bootstrap
# Target: Ubuntu 26.04+ / AMD64
# ============================================================

SCRIPT_NAME="workstation-bootstrap"

WORKSPACE="$HOME/workspace"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
CACHE_DIR="$HOME/.cache/$SCRIPT_NAME"
STATE_DIR="$HOME/.local/state/$SCRIPT_NAME"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_FILE="$REPO_DIR/AGENTS.md"

mkdir -p \
    "$WORKSPACE" \
    "$LOCAL_BIN" \
    "$LOCAL_OPT" \
    "$CACHE_DIR" \
    "$STATE_DIR"

# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

info() {
    printf '\n\033[1;34m==>\033[0m %s\n' "$*"
}

success() {
    printf '\033[1;32m✓\033[0m %s\n' "$*"
}

warning() {
    printf '\033[1;33m⚠\033[0m %s\n' "$*"
}

error() {
    printf '\033[1;31m✗\033[0m %s\n' "$*" >&2
}

die() {
    error "$*"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null \
        | grep -q 'install ok installed'
}

ask() {
    local answer

    if [[ ! -r /dev/tty ]]; then
        return 1
    fi

    printf '%s [Y/n] ' "$1" >/dev/tty
    IFS= read -r answer </dev/tty || return 1

    [[ -z "$answer" || "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# ------------------------------------------------------------
# Error handling
# ------------------------------------------------------------

on_error() {
    local code=$?
    local line="${BASH_LINENO[0]:-unknown}"

    error "Failed at line $line (exit code $code)."
    error "Fix the issue and rerun ./setup.sh to resume."

    exit "$code"
}

trap on_error ERR

exec 9>"$STATE_DIR/setup.lock"

flock -n 9 || die "Another setup process is already running."


# ------------------------------------------------------------
# CLI Options
# ------------------------------------------------------------

show_help() {
    cat <<EOF
Usage: ./setup.sh [OPTIONS]

Unified workstation bootstrap and dotfiles configuration script.

Options:
  --symlinks-only    Only create symlinks for AGENTS.md and tool configs
  --skills-only      Only install global skills from skills.json via Bun
  --help, -h         Show this help message
EOF
}

MODE="all"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --symlinks-only)
            MODE="symlinks"
            shift
            ;;
        --skills-only)
            MODE="skills"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            show_help
            exit 1
            ;;
    esac
done


TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

[[ "$EUID" -ne 0 ]] || die "Do not run this script as root."
command_exists sudo || die "sudo is required."
command_exists curl || die "curl is required."

[[ -f /etc/os-release ]] || die "Cannot identify Ubuntu version."

source /etc/os-release

[[ "$ID" == ubuntu ]] || die "This script targets Ubuntu."
[[ "$(dpkg --print-architecture)" == amd64 ]] \
    || die "This script targets AMD64."

# Make local and tool-managed binaries available immediately so presence checks work.
export PATH="$LOCAL_BIN:$HOME/.bun/bin:$HOME/.local/share/fnm:$HOME/.opencode/bin:$HOME/.kiro/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"

# Persist local binary directory before installing any CLIs.
if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
    printf '\n# Local executables\nexport PATH="$HOME/.local/bin:$PATH"\n' \
        >> "$HOME/.bashrc"
fi

info "Preparing Ubuntu workstation..."
success "Ubuntu $VERSION_ID detected."

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

download() {
    curl \
        --fail \
        --location \
        --silent \
        --show-error \
        --retry 3 \
        --retry-delay 2 \
        "$1" \
        --output "$2"
}

run_bash_installer() {
    local name="$1"
    local url="$2"
    shift 2

    local cmd
    for cmd in "$@"; do
        if command_exists "$cmd"; then
            success "$name ($cmd) is already installed. Skipping."
            return 0
        fi
    done

    local slug
    slug="$(printf '%s' "$name" | tr -cs 'A-Za-z0-9' '-')"
    local installer="$TEMP_DIR/installer-${slug}.sh"

    info "Installing $name..."

    download "$url" "$installer"
    bash "$installer"

    success "$name installer completed."
}

run_sh_installer() {
    local name="$1"
    local url="$2"
    shift 2

    local cmd
    for cmd in "$@"; do
        if command_exists "$cmd"; then
            success "$name ($cmd) is already installed. Skipping."
            return 0
        fi
    done

    local slug
    slug="$(printf '%s' "$name" | tr -cs 'A-Za-z0-9' '-')"
    local installer="$TEMP_DIR/installer-${slug}.sh"

    info "Installing $name..."

    download "$url" "$installer"
    sh "$installer"

    success "$name installer completed."
}

# ------------------------------------------------------------
# Dotfiles & Global Skills
# ------------------------------------------------------------

link_path() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "  [ERROR] Source missing: $src" >&2
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  # If dest is already a symlink pointing to the exact source, report and return
  if [ -L "$dest" ]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      echo "  [OK] Already linked: $dest -> $src"
      return 0
    fi
  fi

  # If dest exists and is a regular non-symlink file with content, back it up
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    if [ -s "$dest" ]; then
      local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
      echo "  [BACKUP] Backing up $dest to $backup"
      mv "$dest" "$backup"
    elif [ -f "$dest" ]; then
      rm -f "$dest"
    fi
  fi

  ln -sfn "$src" "$dest"
  echo "  [LINK] $dest -> $src"
}

setup_agents_md() {
  echo "Linking AGENTS.md for main agents..."

  # 1. Copilot CLI (personal instructions and AGENTS.md fallback)
  link_path "$AGENTS_FILE" "$HOME/.copilot/copilot-instructions.md"
  link_path "$AGENTS_FILE" "$HOME/.copilot/AGENTS.md"

  # 2. OpenCode (global instructions)
  link_path "$AGENTS_FILE" "$HOME/.config/opencode/AGENTS.md"

  # 3. Antigravity and T3 Code (global rules in ~/.gemini/ and ~/.gemini/config/)
  link_path "$AGENTS_FILE" "$HOME/.gemini/AGENTS.md"
  link_path "$AGENTS_FILE" "$HOME/.gemini/GEMINI.md"
  link_path "$AGENTS_FILE" "$HOME/.gemini/config/AGENTS.md"
  link_path "$AGENTS_FILE" "$HOME/.gemini/config/GEMINI.md"

  # 4. Codex CLI (global instructions in ~/.codex/)
  link_path "$AGENTS_FILE" "$HOME/.codex/AGENTS.md"

  # 5. Cline (global instructions in ~/.cline/ and universal ~/.agents/)
  link_path "$AGENTS_FILE" "$HOME/.cline/AGENTS.md"
  link_path "$AGENTS_FILE" "$HOME/.agents/AGENTS.md"

  # 6. Devin CLI (global instructions in ~/.config/devin/)
  link_path "$AGENTS_FILE" "$HOME/.config/devin/AGENTS.md"
}

setup_configs() {
  echo "Linking tool configs (Antigravity, OpenCode, Zed)..."

  # Antigravity MCP configuration
  link_path "$REPO_DIR/gemini/config/mcp_config.json" "$HOME/.gemini/config/mcp_config.json"

  # OpenCode configuration
  link_path "$REPO_DIR/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"

  # Zed editor configuration
  link_path "$REPO_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
  link_path "$REPO_DIR/zed/keymap.json" "$HOME/.config/zed/keymap.json"
  link_path "$REPO_DIR/zed/snippets" "$HOME/.config/zed/snippets"
  link_path "$REPO_DIR/zed/themes" "$HOME/.config/zed/themes"
}

install_skills() {
  local skills_file="$REPO_DIR/skills.json"
  if [ ! -f "$skills_file" ]; then
    echo "  [ERROR] Skills list not found at $skills_file" >&2
    return 1
  fi

  if ! command -v bun >/dev/null 2>&1; then
    if [ -x "$HOME/.bun/bin/bun" ]; then
      export PATH="$HOME/.bun/bin:$PATH"
    else
      echo "  [ERROR] bun is required to install skills globally. Please install bun." >&2
      return 1
    fi
  fi

  echo "Installing global skills from skills.json using bun..."
  bun -e '
    import { readFileSync } from "fs";
    import { spawnSync } from "child_process";

    const skillsFile = process.argv.slice(1).find((arg) => arg.endsWith(".json")) || process.argv[1];
    const raw = readFileSync(skillsFile, "utf-8");
    const items = JSON.parse(raw);
    const failed = [];

    for (const item of items) {
      const pkg = item.package;
      const skills = item.skills || [];
      const args = ["skills", "add", pkg, "-g", "-y", "-a", "*"];

      if (skills.length === 1 && skills[0] === "*") {
        args.push("--skill", "*");
      } else {
        for (const s of skills) {
          args.push("--skill", s);
        }
      }

      console.log(`\n==> Installing ${pkg} (${skills.join(", ")})...`);
      const res = spawnSync("bunx", args, { stdio: "inherit" });
      if (res.status !== 0) {
        console.error(`Error: Failed to install ${pkg} (exit code ${res.status})`);
        failed.push(pkg);
      }
    }

    if (failed.length > 0) {
      console.error(`\nFailed to install ${failed.length} skill package(s): ${failed.join(", ")}`);
      process.exit(1);
    }
  ' "$skills_file"
}

if [[ "$MODE" == "symlinks" ]]; then
    setup_agents_md
    setup_configs
    success "Symlinks setup completed."
    exit 0
fi

if [[ "$MODE" == "skills" ]]; then
    install_skills
    success "Global skills setup completed."
    exit 0
fi

setup_agents_md
setup_configs


# ------------------------------------------------------------
# 1. Base dependencies
# ------------------------------------------------------------

info "Checking base dependencies..."

BASE_APT_PACKAGES=(
    apt-transport-https
    ca-certificates
    curl
    file
    ffmpeg
    gpg
    jq
    lsb-release
    software-properties-common
    unzip
    wget
    xclip
    xz-utils
    zip
    build-essential
    gnupg
)

MISSING_BASE_PACKAGES=()

for pkg in "${BASE_APT_PACKAGES[@]}"; do
    if ! package_installed "$pkg"; then
        MISSING_BASE_PACKAGES+=("$pkg")
    fi
done

if (( ${#MISSING_BASE_PACKAGES[@]} > 0 )); then
    info "Installing missing base dependencies: ${MISSING_BASE_PACKAGES[*]}..."
    sudo apt-get update
    sudo apt-get install -y "${MISSING_BASE_PACKAGES[@]}"
    success "Base dependencies installed."
else
    success "All base dependencies are already installed. Skipping."
fi

# ------------------------------------------------------------
# 2. APT repositories
# ------------------------------------------------------------

info "Checking APT repositories..."

APT_REPOS_CHANGED=0

# Git Core PPA
if ! grep -Rqs 'ppa.launchpadcontent.net/git-core/ppa' \
    /etc/apt/sources.list.d/ 2>/dev/null; then

    sudo add-apt-repository -y ppa:git-core/ppa
    APT_REPOS_CHANGED=1
else
    success "Git Core PPA already registered."
fi

# Helium
sudo install -d -m 0755 /usr/share/keyrings

if [[ ! -f /usr/share/keyrings/helium.gpg ]]; then
    curl -fsSL \
        https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc \
        | sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg
    APT_REPOS_CHANGED=1
fi

if [[ ! -f /etc/apt/sources.list.d/helium.list ]]; then
    echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" \
        | sudo tee /etc/apt/sources.list.d/helium.list >/dev/null
    APT_REPOS_CHANGED=1
else
    success "Helium APT repository already configured."
fi

# Spotify
sudo install -d -m 0755 /etc/apt/keyrings

if [[ ! -f /etc/apt/keyrings/spotify.gpg ]]; then
    curl -fsSL \
        https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/spotify.gpg
    APT_REPOS_CHANGED=1
fi

if [[ ! -f /etc/apt/sources.list.d/spotify.list ]]; then
    echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" \
        | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null
    APT_REPOS_CHANGED=1
else
    success "Spotify APT repository already configured."
fi

success "APT repositories ready."

# ------------------------------------------------------------
# 3. Latest Debian packages
# ------------------------------------------------------------

github_latest_deb() {
    local repository="$1"
    local pattern="$2"
    local destination="$3"

    local metadata="$TEMP_DIR/release.json"

    info "Finding latest stable release: $repository"

    if command_exists gh && gh auth status >/dev/null 2>&1; then
        gh api "repos/$repository/releases/latest" > "$metadata"
    else
        download \
            "https://api.github.com/repos/$repository/releases/latest" \
            "$metadata"
    fi

    local asset
    asset="$(jq -er \
        --arg pattern "$pattern" \
        '.assets[]
         | select(.name | test($pattern))
         | .browser_download_url' \
        "$metadata" | head -n 1)"

    [[ -n "$asset" ]] || die "No matching Debian package found for $repository."

    local filename
    filename="$(basename "$asset")"

    info "Package: $filename"

    download "$asset" "$destination"

    dpkg-deb --info "$destination" >/dev/null \
        || die "Invalid Debian package: $filename"

    local architecture
    architecture="$(dpkg-deb -f "$destination" Architecture)"

    [[ "$architecture" == amd64 || "$architecture" == all ]] \
        || die "Unexpected architecture: $architecture"

    local expected_digest
    expected_digest="$(jq -r \
        --arg filename "$filename" \
        '.assets[]
         | select(.name == $filename)
         | .digest // empty' \
        "$metadata")"

    if [[ "$expected_digest" == sha256:* ]]; then
        local actual_digest
        actual_digest="$(sha256sum "$destination" | awk '{print $1}')"

        [[ "$actual_digest" == "${expected_digest#sha256:}" ]] \
            || die "SHA-256 verification failed: $filename"

        success "SHA-256 verified."
    else
        warning "GitHub did not provide an API digest for $filename."
    fi

    success "Validated $filename."
}

github_nightly_deb() {
    local repository="$1"
    local pattern="$2"
    local destination="$3"

    local metadata="$TEMP_DIR/nightly-release.json"

    info "Finding latest nightly release: $repository"

    if command_exists gh && gh auth status >/dev/null 2>&1; then
        gh api "repos/$repository/releases" --jq '[.[] | select(.tag_name | contains("nightly"))][0]' > "$metadata"
    else
        python3 -c "
import urllib.request, re, json, sys

dest = sys.argv[1]
repo = sys.argv[2]
try:
    url = f'https://github.com/{repo}/releases.atom'
    req = urllib.request.Request(url, headers={'User-Agent': 'curl/7.88.1'})
    with urllib.request.urlopen(req) as resp:
        xml = resp.read().decode()
    m = re.search(r'<link [^>]*href=\"[^\"]*/releases/tag/([^\"/]*nightly[^\"]*)\"', xml)
    tag = m.group(1) if m else None
    if not tag:
        sys.exit(1)
    assets_url = f'https://github.com/{repo}/releases/expanded_assets/{tag}'
    req2 = urllib.request.Request(assets_url, headers={'User-Agent': 'curl/7.88.1'})
    with urllib.request.urlopen(req2) as resp2:
        html = resp2.read().decode()
    debs = re.findall(rf'/{repo}/releases/download/[^\"]*amd64\.deb', html)
    if not debs:
        sys.exit(1)
    deb_url = 'https://github.com' + debs[0]
    filename = deb_url.split('/')[-1]
    data = {'tag_name': tag, 'assets': [{'name': filename, 'browser_download_url': deb_url}]}
    with open(dest, 'w') as f:
        json.dump(data, f)
except Exception:
    sys.exit(1)
" "$metadata" "$repository" || download "https://api.github.com/repos/$repository/releases" "$metadata"
    fi

    local asset
    if jq -e 'type == "array"' "$metadata" >/dev/null 2>&1; then
        asset="$(jq -er \
            --arg pattern "$pattern" \
            '[.[] | select(.tag_name | contains("nightly"))][0].assets[]
             | select(.name | test($pattern))
             | .browser_download_url' \
            "$metadata" | head -n 1)"
    else
        asset="$(jq -er \
            --arg pattern "$pattern" \
            '.assets[]
             | select(.name | test($pattern))
             | .browser_download_url' \
            "$metadata" | head -n 1)"
    fi

    [[ -n "$asset" ]] || die "No matching nightly Debian package found for $repository."

    local filename
    filename="$(basename "$asset")"

    info "Package: $filename"

    download "$asset" "$destination"

    dpkg-deb --info "$destination" >/dev/null \
        || die "Invalid Debian package: $filename"

    local architecture
    architecture="$(dpkg-deb -f "$destination" Architecture)"

    [[ "$architecture" == amd64 || "$architecture" == all ]] \
        || die "Unexpected architecture: $architecture"

    success "Validated $filename."
}

LOCAL_DEBS_TO_INSTALL=()

if package_installed "windscribe"; then
    success "Windscribe is already installed. Skipping download."
else
    info "Finding latest stable Windscribe release..."
    github_latest_deb \
        "Windscribe/Desktop-App" \
        '^windscribe_[0-9][A-Za-z0-9._-]*_amd64\.deb$' \
        "$TEMP_DIR/windscribe.deb"
    LOCAL_DEBS_TO_INSTALL+=("$TEMP_DIR/windscribe.deb")
fi

if package_installed "localsend"; then
    success "LocalSend is already installed. Skipping download."
else
    info "Finding latest LocalSend AMD64 release..."
    github_latest_deb \
        "localsend/localsend" \
        '^LocalSend-[0-9][A-Za-z0-9.-]*-linux-x86-64\.deb$' \
        "$TEMP_DIR/localsend.deb"
    LOCAL_DEBS_TO_INSTALL+=("$TEMP_DIR/localsend.deb")
fi

if package_installed "t3code" || package_installed "t3-code"; then
    success "T3 Code is already installed. Skipping download."
else
    info "Finding latest T3 Code nightly AMD64 release..."
    github_nightly_deb \
        "pingdotgg/t3code" \
        '^T3-Code-[0-9][A-Za-z0-9._-]*nightly[A-Za-z0-9._-]*amd64\.deb$' \
        "$TEMP_DIR/t3code-nightly.deb"
    LOCAL_DEBS_TO_INSTALL+=("$TEMP_DIR/t3code-nightly.deb")
fi

# ------------------------------------------------------------
# 4. APT installation
# ------------------------------------------------------------

SYSTEM_APT_PACKAGES=(
    git
    helium-bin
    spotify-client
    gnome-shell-extension-manager
    ffmpeg
    xclip
)

APT_INSTALL_TARGETS=()

for pkg in "${SYSTEM_APT_PACKAGES[@]}"; do
    if package_installed "$pkg"; then
        success "APT package already installed: $pkg"
    else
        APT_INSTALL_TARGETS+=("$pkg")
    fi
done

APT_TEMP_DIR=""

if (( ${#LOCAL_DEBS_TO_INSTALL[@]} > 0 )); then
    # Copy packages to /tmp so the _apt user can access them.
    # This avoids APT's unsandboxed-download warning.
    APT_TEMP_DIR="$(mktemp -d /tmp/workstation-debs.XXXXXX)"

    for deb in "${LOCAL_DEBS_TO_INSTALL[@]}"; do
        dest="$APT_TEMP_DIR/$(basename "$deb")"
        install -m 0644 "$deb" "$dest"
        APT_INSTALL_TARGETS+=("$dest")
    done
fi

if (( ${#APT_INSTALL_TARGETS[@]} > 0 )); then
    info "Updating APT package lists..."
    sudo apt-get update

    info "Installing missing system applications..."
    sudo apt-get install -y "${APT_INSTALL_TARGETS[@]}"
    success "APT installation completed."
else
    if (( APT_REPOS_CHANGED == 1 )); then
        info "Updating APT package lists for newly added repositories..."
        sudo apt-get update
    fi
    success "All system APT applications are already installed. Skipping."
fi

if [[ -n "$APT_TEMP_DIR" ]]; then
    rm -rf "$APT_TEMP_DIR"
fi

# ------------------------------------------------------------
# 5. Homebrew
# ------------------------------------------------------------

info "Setting up Homebrew..."

if ! command_exists brew; then
    NONINTERACTIVE=1 \
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    success "Homebrew is already installed. Skipping."
fi

BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

[[ -x "$BREW_BIN" ]] || die "Homebrew executable not found."

# Configure the active shell immediately.
eval "$("$BREW_BIN" shellenv bash)"

BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"'

if ! grep -Fq "$BREW_SHELLENV" "$HOME/.bashrc"; then
    printf '\n# Homebrew\n%s\n' "$BREW_SHELLENV" >> "$HOME/.bashrc"
fi

# Homebrew's confirmation prompt is automatically accepted.
brew_noninteractive() {
    local status

    set +o pipefail
    yes | brew "$@"
    status=${PIPESTATUS[1]}
    set -o pipefail

    return "$status"
}

BREW_FORMULAS=(gh ripgrep)
BREW_TO_INSTALL=()

for formula in "${BREW_FORMULAS[@]}"; do
    if brew list --formula "$formula" >/dev/null 2>&1; then
        success "Homebrew formula already installed: $formula. Skipping."
    else
        BREW_TO_INSTALL+=("$formula")
    fi
done

if (( ${#BREW_TO_INSTALL[@]} > 0 )); then
    info "Installing Homebrew formulas: ${BREW_TO_INSTALL[*]}..."
    brew_noninteractive install --formula "${BREW_TO_INSTALL[@]}"
fi

success "Homebrew packages ready."

# ------------------------------------------------------------
# 6. fnm and Node.js
# ------------------------------------------------------------

info "Setting up fnm..."

if ! command_exists fnm; then
    download "https://fnm.vercel.app/install" "$TEMP_DIR/fnm-install.sh"
    bash "$TEMP_DIR/fnm-install.sh" --skip-shell
else
    success "fnm is already installed. Skipping."
fi

export PATH="$HOME/.local/share/fnm:$PATH"

command_exists fnm || die "fnm installation failed."

if ! grep -Fq 'fnm env --use-on-cd --shell bash' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell bash)"
EOF
fi

eval "$(fnm env --use-on-cd --shell bash)"

if fnm list 2>/dev/null | grep -Eq 'v26\.'; then
    success "Node.js 26 is already installed. Skipping install."
else
    info "Installing Node.js 26..."
    fnm install 26
fi

fnm default 26
fnm use 26

success "Node.js $(node --version) configured."

# ------------------------------------------------------------
# 7. Bun
# ------------------------------------------------------------

info "Setting up Bun..."

if ! command_exists bun; then
    download "https://bun.sh/install" "$TEMP_DIR/bun-install.sh"
    bash "$TEMP_DIR/bun-install.sh"
else
    success "Bun ($(bun --version)) is already installed. Skipping."
fi

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

command_exists bun || die "Bun installation failed."

if ! grep -Fq 'export BUN_INSTALL="$HOME/.bun"' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
EOF
fi

success "Bun $(bun --version) ready."

# ------------------------------------------------------------
# 8. Bun global CLIs
# ------------------------------------------------------------

BUN_GLOBAL_PACKAGES=(
    vercel
    @railway/cli
    @github/copilot
)

INSTALLED_BUN_GLOBALS="$(bun pm ls -g 2>/dev/null || true)"
BUN_GLOBALS_TO_INSTALL=()

for pkg in "${BUN_GLOBAL_PACKAGES[@]}"; do
    if grep -Fq "${pkg}@" <<< "$INSTALLED_BUN_GLOBALS"; then
        success "Bun global package already installed: $pkg. Skipping."
    else
        BUN_GLOBALS_TO_INSTALL+=("$pkg")
    fi
done

if (( ${#BUN_GLOBALS_TO_INSTALL[@]} > 0 )); then
    info "Installing Bun global packages: ${BUN_GLOBALS_TO_INSTALL[*]}..."
    bun add --global "${BUN_GLOBALS_TO_INSTALL[@]}"
fi

success "Bun global packages ready."

install_skills

# ------------------------------------------------------------
# 9. Developer CLIs
# ------------------------------------------------------------

run_bash_installer \
    "Antigravity CLI" \
    "https://antigravity.google/cli/install.sh" \
    "agy"

if command_exists agy; then
    info "Installing Antigravity WakaTime plugin..."
    agy plugin install https://github.com/wakatime/antigravity-cli-wakatime || warning "Failed to install Antigravity WakaTime plugin."
fi

run_bash_installer \
    "OpenCode" \
    "https://opencode.ai/v2/install" \
    "opencode"

# Codex: suppress the optional launch prompt.
if command_exists codex; then
    success "Codex CLI (codex) is already installed. Skipping."
else
    info "Installing Codex CLI..."

    download \
        "https://chatgpt.com/codex/install.sh" \
        "$TEMP_DIR/codex-install.sh"

    CODEX_NON_INTERACTIVE=1 \
        sh "$TEMP_DIR/codex-install.sh"

    success "Codex CLI installed."
fi

run_bash_installer \
    "Kiro CLI" \
    "https://cli.kiro.dev/install" \
    "kiro-cli" \
    "kiro"

# ------------------------------------------------------------
# 10. Devin CLI
# ------------------------------------------------------------

if command_exists devin; then
    success "Devin CLI (devin) is already installed. Skipping."
else
    info "Installing Devin CLI without launching setup..."

    download \
        "https://cli.devin.ai/install.sh" \
        "$TEMP_DIR/devin-install.sh"

    # The official installer ends by launching:
    # "$VERSION_DIR/bin/$COMPILED_BIN_NAME" setup
    #
    # That wizard requires interactive authentication. Remove only
    # that final invocation. The official installer still handles
    # release discovery, download, checksum verification and setup
    # of the executable itself.

    DEVIN_SETUP_LINE='"$VERSION_DIR/bin/$COMPILED_BIN_NAME" setup'

    grep -Fqx "$DEVIN_SETUP_LINE" "$TEMP_DIR/devin-install.sh" \
        || die "Devin installer changed. Refusing to modify an unexpected installer."

    sed -i \
        '\|^"\$VERSION_DIR/bin/\$COMPILED_BIN_NAME" setup$|d' \
        "$TEMP_DIR/devin-install.sh"

    grep -Fqx "$DEVIN_SETUP_LINE" "$TEMP_DIR/devin-install.sh" \
        && die "Could not disable Devin's automatic setup wizard."

    bash "$TEMP_DIR/devin-install.sh"

    command_exists devin || die "Devin CLI installation failed."

    success "Devin CLI installed without starting its login wizard."
fi

# ------------------------------------------------------------
# 11. Zed
# ------------------------------------------------------------

run_bash_installer \
    "Zed" \
    "https://zed.dev/install.sh" \
    "zed"

# ------------------------------------------------------------
# 12. Notion CLI
# ------------------------------------------------------------

run_bash_installer \
    "Notion CLI" \
    "https://ntn.dev" \
    "ntn"

# ------------------------------------------------------------
# 13. Tailscale
# ------------------------------------------------------------

run_sh_installer \
    "Tailscale" \
    "https://tailscale.com/install.sh" \
    "tailscale"

# ------------------------------------------------------------
# 14. Basecamp CLI
# ------------------------------------------------------------

run_bash_installer \
    "Basecamp CLI" \
    "https://basecamp.com/install-cli" \
    "basecamp"

# ------------------------------------------------------------
# 15. yt-dlp
# ------------------------------------------------------------

if command_exists yt-dlp; then
    success "yt-dlp ($(yt-dlp --version)) is already installed. Skipping."
else
    info "Installing yt-dlp..."

    download \
        "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp" \
        "$LOCAL_BIN/yt-dlp"

    chmod 0755 "$LOCAL_BIN/yt-dlp"

    success "yt-dlp $(yt-dlp --version) installed."
fi

# ------------------------------------------------------------
# 16. Snap packages
# ------------------------------------------------------------

command_exists snap || die "snap is required to install Snap applications."

if snap list telegram-desktop >/dev/null 2>&1; then
    success "Telegram Desktop (snap) is already installed. Skipping."
else
    info "Installing Telegram Desktop via Snap..."
    sudo snap install telegram-desktop
    success "Telegram Desktop installed."
fi

if snap list vlc >/dev/null 2>&1; then
    success "VLC (snap) is already installed. Skipping."
else
    info "Installing VLC via Snap..."
    sudo snap install vlc
    success "VLC installed."
fi

# ------------------------------------------------------------
# 17. Shell aliases
# ------------------------------------------------------------

info "Configuring shell aliases..."

if ! grep -Fq "alias copy='xclip -selection clipboard'" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Clipboard
alias copy='xclip -selection clipboard'
EOF
fi

success "Shell configuration updated."

# ------------------------------------------------------------
# 18. Workspace repositories
# ------------------------------------------------------------

WORKSPACE_REPOS=(
    "mikelneonedwin/wape|$WORKSPACE/wape"
    "appliftlabs/modools-api|$WORKSPACE/modools/api"
    "appliftlabs/modools_frontend|$WORKSPACE/modools/web"
    "appliftlabs/modools-mcp|$WORKSPACE/modools/mcp"
    "yusuf-ishaku/manualbook|$WORKSPACE/modools/manualbook"
    "mikelneonedwin/modools-admin|$WORKSPACE/modools/admin"
    "mikelneonedwin/mikelneonedwin|$WORKSPACE/mikelneonedwin"
    "mikelneonedwin/skills|$WORKSPACE/skills"
    "mikelneonedwin/re5|$WORKSPACE/re5"
)

BUN_PROJECT_DIRS=(
    "$WORKSPACE/wape"
    "$WORKSPACE/modools/api"
    "$WORKSPACE/modools/web"
    "$WORKSPACE/modools/mcp"
    "$WORKSPACE/modools/manualbook"
    "$WORKSPACE/modools/admin"
    "$WORKSPACE/mikelneonedwin"
    "$WORKSPACE/re5"
)

flush_clone_batch() {
    local i
    for (( i = 0; i < ${#CLONE_PIDS[@]}; i++ )); do
        if wait "${CLONE_PIDS[i]}"; then
            success "Cloned ${CLONE_REPOS[i]}"
        else
            warning "Could not clone ${CLONE_REPOS[i]}."
            [[ -s "${CLONE_LOGS[i]}" ]] && sed 's/^/    /' "${CLONE_LOGS[i]}" >&2
        fi
    done

    CLONE_PIDS=()
    CLONE_REPOS=()
    CLONE_LOGS=()
}

clone_repositories_batch() {
    local max_jobs="${1:-4}"
    local entry repo dest log_file
    local idx=0

    CLONE_PIDS=()
    CLONE_REPOS=()
    CLONE_LOGS=()

    for entry in "${WORKSPACE_REPOS[@]}"; do
        IFS='|' read -r repo dest <<< "$entry"

        if [[ -d "$dest/.git" ]]; then
            success "Already cloned: $dest"
            continue
        fi

        if [[ -e "$dest" ]]; then
            warning "Destination exists but is not a Git repository: $dest"
            continue
        fi

        mkdir -p "$(dirname "$dest")"
        log_file="$TEMP_DIR/clone-$idx.log"
        idx=$((idx + 1))

        info "Cloning $repo -> $dest"
        GIT_TERMINAL_PROMPT=0 \
        GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" \
            gh repo clone "$repo" "$dest" >"$log_file" 2>&1 &

        CLONE_PIDS+=("$!")
        CLONE_REPOS+=("$repo")
        CLONE_LOGS+=("$log_file")

        if (( ${#CLONE_PIDS[@]} >= max_jobs )); then
            flush_clone_batch
        fi
    done

    if (( ${#CLONE_PIDS[@]} > 0 )); then
        flush_clone_batch
    fi
}

flush_bun_batch() {
    local i
    for (( i = 0; i < ${#BUN_PIDS[@]}; i++ )); do
        if wait "${BUN_PIDS[i]}"; then
            success "Installed dependencies: ${BUN_DIRS[i]}"
        else
            warning "Failed to install dependencies: ${BUN_DIRS[i]}"
            [[ -s "${BUN_LOGS[i]}" ]] && sed 's/^/    /' "${BUN_LOGS[i]}" >&2
        fi
    done

    BUN_PIDS=()
    BUN_DIRS=()
    BUN_LOGS=()
}

install_bun_dependencies_batch() {
    local max_jobs="${1:-4}"
    local dir log_file
    local idx=0

    BUN_PIDS=()
    BUN_DIRS=()
    BUN_LOGS=()

    for dir in "${BUN_PROJECT_DIRS[@]}"; do
        [[ -d "$dir" && -f "$dir/package.json" ]] || continue

        if [[ -d "$dir/node_modules" ]]; then
            success "Dependencies already installed: $dir. Skipping."
            continue
        fi

        log_file="$TEMP_DIR/bun-install-$idx.log"
        idx=$((idx + 1))

        info "Installing dependencies: $dir"
        (
            cd "$dir"
            bun install
        ) >"$log_file" 2>&1 &

        BUN_PIDS+=("$!")
        BUN_DIRS+=("$dir")
        BUN_LOGS+=("$log_file")

        if (( ${#BUN_PIDS[@]} >= max_jobs )); then
            flush_bun_batch
        fi
    done

    if (( ${#BUN_PIDS[@]} > 0 )); then
        flush_bun_batch
    fi
}

if command_exists gh; then
    if gh auth status >/dev/null 2>&1; then
        success "GitHub CLI is already authenticated."
    elif ask "Authenticate GitHub CLI now (required to clone workspace repositories)?"; then
        gh auth login
    fi
fi

if command_exists gh && gh auth status >/dev/null 2>&1; then
    clone_repositories_batch 4
    install_bun_dependencies_batch 4

    if [[ -d "$WORKSPACE/wape" && -f "$WORKSPACE/wape/package.json" ]]; then
        if command_exists wape; then
            success "wape is already linked globally. Skipping."
        else
            (
                cd "$WORKSPACE/wape"
                bun link
            )
            success "Linked wape globally with Bun."
        fi
    fi
else
    warning "GitHub is not authenticated. Workspace cloning skipped."
fi

# ------------------------------------------------------------
# 19. Authentication
# ------------------------------------------------------------

info "Checking CLI authentication..."

if command_exists tailscale; then
    if tailscale status --json 2>/dev/null \
        | jq -e '.BackendState == "Running"' >/dev/null 2>&1; then
        success "Tailscale is already connected. Skipping."
    elif ask "Connect Tailscale and enable SSH?"; then
        sudo tailscale up --ssh --accept-dns=false
    fi
fi

if command_exists vercel; then
    if vercel whoami >/dev/null 2>&1; then
        success "Vercel CLI is already authenticated. Skipping."
    elif ask "Authenticate Vercel CLI?"; then
        vercel login
    fi
fi

if command_exists railway; then
    if railway whoami >/dev/null 2>&1; then
        success "Railway CLI is already authenticated. Skipping."
    elif ask "Authenticate Railway CLI?"; then
        railway login
    fi
fi

if command_exists basecamp; then
    if basecamp auth status >/dev/null 2>&1; then
        success "Basecamp CLI is already authenticated. Skipping."
    elif ask "Authenticate Basecamp CLI?"; then
        basecamp auth login
    fi
fi

if command_exists ntn; then
    if [[ -n "$(ntn auth token 2>/dev/null || true)" ]]; then
        success "Notion CLI is already authenticated. Skipping."
    elif ask "Authenticate Notion CLI?"; then
        ntn login
    fi
fi

if command_exists devin; then
    if devin auth status >/dev/null 2>&1; then
        success "Devin CLI is already authenticated. Skipping."
    elif ask "Authenticate Devin CLI?"; then
        devin auth login
    fi
fi

# ------------------------------------------------------------
# 20. Manual reminders
# ------------------------------------------------------------

cat <<'EOF'

============================================================
MANUAL SETUP REMINDERS
============================================================

Applications:
  [ ] Sign in to Windscribe.
  [ ] Sign in to Spotify.
  [ ] Sign in to Telegram.
  [ ] Sign in to Helium.
  [ ] Configure your AI developer CLIs.

GNOME:
  [ ] Install Battery Notifier from App Center.
  [ ] Configure GSConnect.
  [ ] Install Resource Notifier by 0ry0n.
  [ ] Configure the re5 GNOME extension locally.

Developer setup:
  [ ] Verify Git identity and SSH keys.
  [ ] Verify GitHub repository access.
  [ ] Verify Wape's global Bun link.
  [ ] Check all workspace dependencies.

============================================================

EOF

success "Workstation bootstrap completed."

info "Restart your terminal or run: source ~/.bashrc"
info "Workspace: $WORKSPACE"
