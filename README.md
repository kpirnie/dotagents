# AI Working Rules, Skills & Project Notes

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg?style=for-the-badge&logo=opensourceinitiative&logoColor=white&labelColor=000)](LICENSE)
[![Kevin Pirnie](https://img.shields.io/badge/-KevinPirnie.com-000d2d?style=for-the-badge&labelColor=000&logoColor=white&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ3aGl0ZSIgc3Ryb2tlLXdpZHRoPSIxLjgiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI+CiAgPGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiLz4KICA8ZWxsaXBzZSBjeD0iMTIiIGN5PSIxMiIgcng9IjQuNSIgcnk9IjEwIi8+CiAgPGxpbmUgeDE9IjIiIHkxPSIxMiIgeDI9IjIyIiB5Mj0iMTIiLz4KICA8bGluZSB4MT0iNC41IiB5MT0iNi41IiB4Mj0iMTkuNSIgeTI9IjYuNSIvPgogIDxsaW5lIHgxPSI0LjUiIHkxPSIxNy41IiB4Mj0iMTkuNSIgeTI9IjE3LjUiLz4KPC9zdmc+Cg==)](https://kevinpirnie.com/)

<p>
  <a href="https://github-stats-extended.vercel.app/api?username=kpirnie&hide_title=true&show_icons=true&include_all_commits=true&theme=algolia"><img height="170" alt="GitHub Stats" src="https://github-stats-extended.vercel.app/api?username=kpirnie&hide_title=true&show_icons=true&include_all_commits=true&theme=algolia" /></a>
  <a href="https://github-stats-extended.vercel.app/api/top-langs?username=kpirnie&hide_title=true&langs_count=5&theme=algolia"><img height="170" alt="Top Languages" src="https://github-stats-extended.vercel.app/api/top-langs?username=kpirnie&hide_title=true&langs_count=5&theme=algolia" /></a>
</p>

Shared instructions for Claude (claude.ai, Claude Code) and ChatGPT (ChatGPT, Codex), in the open [Agent Skills](https://agentskills.io) format.

## Layout

```
AGENTS.md              shared working rules (Codex reads this natively)
CLAUDE.md              @AGENTS.md (Claude Code import)
skills/<name>/SKILL.md one folder per skill
projects/<repo>.md     per-project notes, named after the project's repo
.claude/skills         -> ../skills (Claude Code, repo-local)
.agents/skills         -> ../skills (Codex, repo-local)
scripts/install.sh     link everything into the global locations
scripts/package-skills.sh  build per-skill upload zips into dist/
```

## Skills

| Skill | Use |
|---|---|
| `go` | Go code |
| `php` | Non-WordPress PHP (KPT libraries, apps, CLI) |
| `python` | Python code |
| `wp-plugin` | WordPress plugin PHP and wp.org compliance |
| `updates-audit` | WordPress updates audit report from raw notes |
| `updates-completed` | WordPress updates completed report from raw notes |

## Install

### Claude Code / Codex (any repo)

```
./scripts/install.sh
```

Links:

- `~/.agents/AGENTS.md`, `~/.codex/AGENTS.md` -> `AGENTS.md`
- `~/.claude/CLAUDE.md` -> imports `~/.agents/AGENTS.md`
- `~/.claude/skills/<name>`, `~/.agents/skills/<name>` -> `skills/<name>`
- `~/.agents/projects` -> `projects/`

Existing files in the way are backed up as `*.bak.<timestamp>`. Edits in this repo are live everywhere; re-run only after adding a skill.

### claude.ai

1. `./scripts/package-skills.sh`
2. Settings → Capabilities → Skills → upload each `dist/<name>.zip`
3. In a Project, add `AGENTS.md` and the matching `projects/<repo>.md` as project knowledge.

### ChatGPT

- Skills (Business / Enterprise / Edu plans): Profile → Skills → New skill → Upload, using the `dist/<name>.zip` files.
- Other plans: add `AGENTS.md`, the relevant `skills/<name>/SKILL.md`, and the matching `projects/<repo>.md` to a Project's files.

## Adding things

- **Skill:** `skills/<name>/SKILL.md` with `name` (lowercase, hyphens, must match the folder) and `description` (what it does and when to use it) frontmatter, then re-run `install.sh`.
- **Project:** `projects/<repo name>.md`. No install step.

## Windows

Git symlinks need `git config core.symlinks true` and Developer Mode enabled, or the `.claude/skills` and `.agents/skills` links check out as plain text files.
