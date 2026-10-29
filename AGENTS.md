# Working Rules

## Workflow
- **No filesystem sharing either way.** I can't see Claude's filesystem; Claude can't see mine. 
- All code must be posted as **copy/paste-able blocks in chat**.
- One item (or one tightly-coupled group) at a time. Kevin signals advancement explicitly ("next"). Deploy/verify happens incrementally between items.
- If a question has been asked, wait for the answer. Don't proceed on assumptions.
- "Verify" means: read the code and report what's actually there BEFORE changing anything.
- Never ask a question the codebase can answer — check existence, behavior, values, and paths by reading first. If the repo is public, clone it and read it.
- Don't post code until I say to start. Don't write out proposals either — verify silently, then ask only genuine open questions, one line each.
- When told a fix is deployed, it's deployed. Don't ask to re-verify.
- For UI-dependent or multi-step interactive tasks: one step, wait for confirmation, then the next.

## Output
- Minimal diffs: only the code necessary for the change. 
- Post exactly where the code goes including the exact line that exists right before the code change location. 
- Whole functions/files only when necessary or asked for.
- Direct, minimal filler, no explanations unless asked. Order output by importance.
- Post the commit message for each item as it's finished. First line only, no body.
- Match the file being edited: comment style and voice, naming, formatting, error handling. Never impose new conventions.
- Use the applicable skill (python, php, wp-plugin, go, and per-project skills) for language and project conventions.

## Boundaries
- No tests. Don't write them, don't add test infrastructure, don't propose either.
- No refactoring, reformatting, or "improving" anything outside the task.
- No new external dependencies without asking.
- Never touch deployment configs, .env files, credentials, or build artifacts (dist/, release scripts) unless asked.
- Never weaken or "simplify" security code (auth, timing defenses, permission checks, sanitization) — flag concerns instead.

## Observations
- Bugs, mismatches, or oddities noticed in passing (outside the current task): flag them in one line at the end. Don't fix unprompted.

## Context
- Skills: `skills/<name>/SKILL.md` in this repo; installed globally under `~/.claude/skills/` and `~/.agents/skills/`.
- Project notes: before starting work in a repo, read `~/.agents/projects/<repo name>.md` if it exists (`projects/` in this repo). Project notes guide navigation; the repo's code is the source of truth.
