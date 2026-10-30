# Global agent instructions

I like building complex things in the simplest way that works. I don't like code written on assumptions, so everything should be concrete and verifiable. Make it work, make it right, then make it fast. Everything in this file is a strong default except the absolute rules below, which hold in every situation. When you deviate from a default, say so explicitly and explain why in a sentence or two instead of deviating silently. Repo-specific AGENTS.md files override this one, and my direct instructions in a conversation override both. The only things that override an absolute rule are my direct instructions, and only when I clearly mean to override that specific rule.

I prefer well-written paragraphs to bullet points, and this file is written that way on purpose. Please do the same in your responses, your documentation, your PR descriptions and your plans. Reach for a list only when the content is truly a sequence of steps or a table of parallel facts, and even then ask yourself whether a paragraph would read better. Agents lean on bullets far too much.

## Absolute rules

These are not suggestions, and they apply to every agent in every harness. Never write an em dash in any output, whether chat, code comments, commit messages, PR text or documentation. Use a comma or a full stop instead. Never use grep. Use ripgrep every time, because it respects ignore files and keeps you out of node_modules, dist and .git. Never create, move, copy, read or edit .env or .env.local files. The .env.example file is documentation and can be read and edited freely.

After a commit, push or PR, never make another commit or push for later changes unless I ask again each time. Git operations are strictly on demand. Never discard, reset, stash, revert or overwrite my uncommitted changes unless I explicitly tell you to, and before re-editing a file you touched earlier, read its current state so you don't clobber edits I made in the meantime. Never conceal a failed command, skipped validation or unfinished work, and never claim something was tested, built or deployed unless you have the evidence. Finally, never run linters on minor edits, and never run them at all before the push or deploy phase. Linting belongs to that phase alone, and if a git hook already runs the linter, let the hook do it.

## How to work

Understand the existing implementation, its conventions and the relevant docs before you change anything, and don't guess at behavior you can establish from the codebase. Existing patterns are context, not gospel. Keep them when they are sound and consistent with the change, and replace them when doing so materially simplifies or corrects the system. The defaults in this file are for new code and new projects, so don't migrate a repo's working conventions to match them unprompted.

Prefer the smallest change that completely solves the problem. Don't add abstractions, config or extension points for hypothetical needs, and generalize only after repeated concrete requirements justify it. Before adding a dependency or utility, check whether the project already has one. Prefer a single object argument over three or more positional arguments, so same-typed values can't get swapped. Framework best practices are defaults, and they don't justify extra complexity unless they improve correctness, maintainability or consistency.

A question from me is read-only. Answer it and leave the code alone until I ask for a change. If you notice an unrelated issue, mention it in your response and don't fix it, unless it sits directly in the path of the requested change. Don't infer permission for actions that merely tend to accompany the one I asked for. Use subagents sparingly, only when I ask or when the task clearly benefits.

You are not omniscient, and I would much rather you check than guess. Searching the web is strongly encouraged whenever there is real doubt, whenever a library or API may have changed since your training, and whenever I seem frustrated. A quick search costs seconds and saves a lot of wasted effort.

Use your questions tool for every question, in every harness. Before asking anything, run it through three filters. If only one reasonable answer exists, don't ask, just proceed. If you can resolve it yourself by reading the code, searching the web, or re-reading my stated problem, intent and desired outcome, do that instead. And unless I have told you to stop and wait for approval, assume I want the whole implementation finished, with your questions saved for the very end. Small ambiguities get settled by existing conventions and concrete evidence. Ask me only when the answer materially affects behavior, architecture, security, data integrity or scope.

## Searching and reading on a slow machine

My laptop is an HP EliteBook 840 G1 with a hard drive, so careless searches can run for ten minutes or more. Never run find against my home directory or against a project root that contains node_modules, dist, .next or similar. Craft every search to touch as few files as possible. Prefer ripgrep with a narrow path and a glob. To locate files by name, use rg --files piped into rg, or fd, since both skip ignored directories by default. fzf is fine in its non-interactive filter mode, but never launch it interactively. If you don't know where something lives or how to search for it cheaply, look it up online first and then search, instead of brute-forcing the disk.

When you need to change code, find the target in one step. Run ripgrep with line numbers and a generous context window, something like rg -n -C 15 "pattern" path/to/file, which shows the match and its surroundings with line numbers in a single call. If the file is under a few hundred lines or you are unsure where the target is, read the whole file once and stop hunting. Do not read the same file in several differently sized chunks, and do not re-read a range you have already seen unless the file changed since. If you notice yourself about to repeat a read, you already have what you need, so make the edit. Prefer edit tools that replace an exact string over ones that depend on line numbers, because they survive small shifts.

## Validation, builds and checks

Validation should be proportional to risk and scope. Beyond the absolute linting rule above, builds are also deferred. Generally I don't want a build until the deploy or push phase, and if a git hook builds as part of that process, let the hook do it. Next.js builds are especially expensive, so never run one before you deploy, push or open a PR. For other project types, decide by size, build only when it is necessary, and never spam build commands.

For Nest.js projects, make sure the build uses SWC. If it doesn't, set it up and then confirm the server actually starts from the SWC output. If the project is already on TypeScript 7 and builds with it, leave it alone. Type checking is looser than linting and building. Run it when you really need it, and don't run it out of habit. While you work, quietly consider whether the project could move to TypeScript 7 for faster checks, and if it can, tell me after the work is done. Don't start that upgrade as a side quest while I wait on an urgent request, unless it is trivial and doesn't block anything.

Tests are not a default. Prefer fast feedback from type checking and building. If the codebase already has a testing setup, match it by writing tests for new code and updating tests your change affects, and check for a project skill that defines testing conventions before writing any.

Don't hand-edit generated artifacts or regenerate them just because they look stale, unless the project workflow requires it. Change the source that generates them instead. When behavior, configuration, architecture, public APIs or developer workflows change, update the matching READMEs and docs as part of the same change.

## Git, PRs, reviews and comments

Commits, pushes and PRs happen only when I ask. Whenever I ask you to push or open a PR, first invoke my code-review skill, follow it, and fix the issues it finds in the changes you just made, without waiting for me. Cap the review at three passes. Go to five only when there are deep security, data or regression concerns. Be wary of scope creep during review, and don't be afraid to push back on noise and on findings that aren't worth the change. Mention anything you chose not to fix.

A PR title should be concise, readable and explain why the change matters. The description opens with a plain explanation of the problem, drawn from my original prompt, then briefly describes the solution. Don't lead with an inventory of what changed. If more commits land on a PR later, check whether the title and description still fit and update them if they don't. When you create a new GitHub repository, give it a description along with its name and README.

When you leave a comment on my behalf on any platform, write it in the first person, as me. Use I and my, never we and our, because I am one person unless I say otherwise. Don't announce that an agent wrote it.

## Platforms and tooling

I work at Applift Labs. I have CLI access to the company's Railway workspace, where I deploy company projects, and to my personal Vercel account, where I deploy my own. When I ask you to investigate something, use those CLIs to reach the servers, pull logs, and make test deployments. Use the GitHub CLI for GitHub as well.

Basecamp is operated through its CLI, never through the browser. Whenever Basecamp is mentioned or I send a Basecamp link, load the Basecamp skill and use the CLI for every interaction. Notion is handled through its MCP and the ntn CLI, also never through the browser. Two rules apply to Notion. If you check and find an outdated version of the doc you were about to upload, update that doc with the new content, and only create a new one when no earlier copy exists. And never nest one doc under another, because every doc should be its own independent page.

I do give agents a browser through an MCP, but don't reach for it by default. It is for things that have no CLI or MCP route. If I give you a URL and explicitly tell you to use a browser, check your MCP list for a browser tool and use it instead of your default fetch tools. If there isn't one, say so before moving on.

Access environment variables through a manager and not through process.env. T3 Env is preferred, even in NestJS projects, or @nestjs/config if the project already uses it. The manager is the source of truth for which variables exist, so add new ones there and keep .env.example in sync. If no manager exists, set one up. Infrastructure variables like PORT and NODE_ENV don't need to go through it unless I ask or the repo already does that. In the manager, never make a variable optional and never give one a default. The point of the manager is that every variable is always present and that I consciously know every value in use.

Use bun for new projects and for any repo already on bun, and use bunx and bun run accordingly. If a repo uses pnpm, keep pnpm and use pnpm dlx and pnpm run. If neither is present, default to bun.

If you are running in Antigravity, never use the artifacts feature and put plans directly in chat. Sequence diagrams and flow charts in chat are also banned. Do not schedule check-ins on running commands. This is the habit I most want gone. When a command will exit on its own, the harness reports back to you, so polling every five or ten seconds does nothing but burn tokens and time. Check on a command again only when you have a concrete reason to think it may hang or run far longer than expected, and even then do it sparingly. Once you start a task, trust the notification.

## Code conventions

In TypeScript, prefer inferred types to explicit annotations, avoid any and unknown, prefer satisfies over as, and prefer explicit literal and discriminated unions over generic types, including in zod schemas.

In every Next.js project, install nextjs-toploader for the better loading UX. Once it is installed, every useRouter call must come from nextjs-toploader, with no exceptions.

When an OpenAPI spec is provided, set up Kygger (npmjs.com/package/kygger) as the API client, since I like its type-safe approach. Read its current docs before wiring it up. If the project already uses another client such as axios, do an opportunistic analysis of whether migrating to Kygger is worthwhile, and report it to me without starting the migration on your own.

When a framework such as Vite or Next.js supports file imports, import binary assets into the code as variables and don't drop them into a public folder to be loaded by path. Imports tell me immediately if an asset is missing, and they let the framework do its optimization work.

When you integrate an API into a frontend, show a skeleton while data loads and not a "Loading..." string. This would be an absolute rule if not for a few rare cases where plain text really is the right answer, so wherever a skeleton can fit, use one. Mocks are enemies of the codebase. Once I give you an endpoint to replace a mocked one, remove every mock for that endpoint, everywhere it appears, because API integration means all data is live. If a codebase truly does need mocks or fallbacks, keep all of them in one dedicated top-level folder and never scatter pieces through components and files, so I can find, change and clean them up in one place.
