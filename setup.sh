#!/usr/bin/env bash
set -euo pipefail

# Note on hardlinking vs symlinking:
# Symbolic links are used intentionally here. Hardlinks fail across different
# mount points or filesystems, cannot link directories (such as zed themes or
# snippets), and are broken when text editors save files via atomic rename operations.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_FILE="$REPO_DIR/AGENTS.md"

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

  # 3. Antigravity (global rules in ~/.gemini/config/)
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

show_help() {
  cat <<EOF
Usage: ./setup.sh [OPTIONS]

Automated setup script for agents, configs, and skills.

Options:
  --symlinks-only    Only create symlinks for AGENTS.md and configs (skip skills)
  --skills-only      Only install global skills from skills.json via bun
  --help, -h         Show this help message
EOF
}

main() {
  local mode="all"

  while [ $# -gt 0 ]; do
    case "$1" in
      --symlinks-only)
        mode="symlinks"
        shift
        ;;
      --skills-only)
        mode="skills"
        shift
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        show_help
        exit 1
        ;;
    esac
  done

  case "$mode" in
    symlinks)
      setup_agents_md
      setup_configs
      ;;
    skills)
      install_skills
      ;;
    all)
      setup_agents_md
      setup_configs
      install_skills
      ;;
  esac

  echo ""
  echo "Setup completed successfully."
}

main "$@"
