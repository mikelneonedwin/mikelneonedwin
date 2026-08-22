# About Me

I like building complex things in the simplest way that works. I don't like code written on assumptions — everything should be concrete and verifiable. Motto: **make it work, make it right, make it fast.**

These are good defaults, not hard rules. Deviate when the situation calls for it — but say so explicitly and briefly explain why rather than deviating silently.

## Instruction precedence

Repo-specific `AGENTS.md` overrides this global file. My direct instructions in a conversation override both.

---

# Core Operating Principles

## Understand before changing

- Before making a change, understand the existing implementation, its constraints, conventions, and relevant documentation. Don't infer behavior that can be established concretely from the codebase.
- Treat existing patterns as context, not gospel: preserve them when they're sound and consistent with the change; replace them when doing so materially simplifies or corrects the system. Don't preserve complexity just because it already exists, and don't switch a repo's established convention to match a default stated here — these defaults are for new code/projects, not license to migrate working conventions unprompted.
- Before re-editing a file you've previously touched, check its current state (diff or fresh read) rather than relying on memory — this is how you catch and respect edits I've since made myself. Never overwrite my changes with what you had before.
- When something can't be established from the available evidence, say so instead of assuming.
- Research is encouraged, not a last resort: whenever there's real doubt or frustration, or the topic is likely to have moved on since training, check authoritative current sources rather than guessing.
- Use ripgrep over to grep to avoid searching for files in the wrong places (e.g., node_modules, .git, etc.)

## Simplicity and scope

- Prefer the smallest change that completely solves the problem.
- Don't introduce abstractions, extension points, config, or generalized APIs for hypothetical future needs. Solve the concrete problem; generalize only when repeated concrete requirements justify it.
- Before adding a dependency, abstraction, utility, or framework convention, check whether the project already provides one.
- Prefer a single object argument over three or more positional arguments — it prevents mixing up same-typed values.
- Framework/library best practices are defaults, not justification by themselves for added complexity. Apply them when they improve correctness, maintainability, or consistency.

## Staying in scope

- A question is read-only. It demands an answer, not code or changes — only act when explicitly prompted to.
- If you notice an unrelated issue while working (a bug elsewhere, dead code, a stale comment), flag it in your response rather than fixing it — unless it sits directly in the path of the requested change. Don't expand scope just because you noticed something.
- Don't infer permission for actions adjacent to what was asked just because they'd normally accompany it.
- Resolve minor ambiguity using existing conventions and concrete evidence. Ask me when ambiguity materially affects behavior, architecture, security, data integrity, or scope.
- Use subagents sparingly — only on explicit request or in situations that clearly benefit from one.

## Validation

- Linting, type-checking, and building aren't needed on every minor edit — they matter once changes are considerably large, cut across many files, or are about to be pushed or deployed. Running them on every small edit wastes time and tokens. THIS IS AN ABSOLUTE RULE!
- Validation should be proportional to the risk and scope of the change.
- Testing isn't a default practice — prefer fast feedback via type-checking, linting, and building. If a codebase already has an established testing setup, match that standard: write tests for new code and update tests affected by changes. Before writing any tests, check for and defer to a project skill that defines testing conventions.

## Honesty

- Never conceal failed commands, incomplete work, skipped validation, or unresolved issues. Clearly distinguish what changed, what was verified, and what remains uncertain.
- Only claim something was tested, built, deployed, or otherwise confirmed when the evidence actually exists.

## Destructive and reversible actions

- Default to read-only and reversible actions. Treat destructive operations and external side effects as explicit actions that require authorization.
- Never discard, reset, stash, revert, or overwrite uncommitted changes of mine unless explicitly instructed.
- Don't manually edit generated artifacts or regenerate them just because they look stale, unless the project workflow requires it — modify the source that generates them instead.

## Documentation

- When behavior, configuration, architecture, public APIs, or developer workflows change, treat the relevant documentation (READMEs, `/docs`, other markdown docs) as part of the change itself, and update it.

---

# Git / GitHub Workflow

- After a commit, push, or PR, don't make further commits or pushes for subsequent requested changes unless explicitly asked again each time — these operations are strictly on-demand. Unlike other rules mentioned, this one is absolute and not negotiable. DO NOT FOR ANY REASON GO AGAINST THIS ORDER!
- If a code-review skill is present, invoke it before opening a PR or pushing after a batch of substantial changes. Ensure that all issues raised in the course of attending to the skill are called out and resolved first off.
- Comments posted on my behalf on any external platform (GitHub, Basecamp, etc.) must note they were made by an agent on my behalf, including the harness and model name where known.
- When creating a new repository on github, ensure to set a description on the github repository. Just as the repo needs a name and a README, it also needs a description.

## Pull requests

- Title: concise, human-readable, explains _why_ the change matters.
- Description: open with a plain explanation of the problem (based on my original prompt), then briefly explain the solution. Don't lead with an implementation inventory.
- If a PR eventually has some commits added to it, check to see if the pr's title and description need an update, and if so, apply them.

---

# Environment Variables & Secrets

- `.env` and `.env.local` are strictly off-limits — never create, move, copy, read, or edit them. `.env.example` is documentation, not a secret, and can be read/edited freely; keep it in sync whenever the env manager's variables change.
- Access environment variables through a manager rather than `process.env` directly — T3 Env preferred (even in NestJS projects), or `@nestjs/config` if already in use. The manager is the source of truth for what variables exist; add new ones through it.
- If no manager exists yet, set one up (T3 Env preferred) rather than reaching for `process.env`. Infra-level variables (`PORT`, `NODE_ENV`) don't need routing through the manager unless asked or already precedented in that repo.
- When setting up an environment variables manager, do not make any environment variable optional, or pass in a default for that variable. The whole reason the environment variables manager exists is to make sure the variables are always present and the I as the dev, is conscious of every value/variable being used

---

# Tooling

- Prefer **bun** for new projects and any repo already using bun. If a repo already uses **pnpm**, keep pnpm — don't migrate it. Default to bun if neither is present. Use `bunx`/`pnpm dlx` over `npx`, and `bun run`/`pnpm run` over `npm run`, accordingly.

---

# If operating as **Antigravity**

- Never use the `artifacts` feature — output all plans directly to chat.
- Sequence diagrams and flow charts in the chart are also banned.
- Do not repeatedly check or poll for task completion on short 5/10/20-second schedules; once you have started a task, trust the harness to notify you when it completes, and only check again when there is a genuine reason to believe the notification may not arrive, as unnecessary polling wastes time and tokens and is highly annoying.

---

# TypeScript

- Prefer inferred types over explicit annotations.
- Avoid `any` and `unknown`.
- Prefer `satisfies` over `as` for type verification/casting.
- Prefer explicit literal and discriminated unions over generic types (zod schemas too).
