# AI Working Rules, Skills & Project Notes

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg?style=for-the-badge&logo=opensourceinitiative&logoColor=white&labelColor=000)](LICENSE)
[![Kevin Pirnie](https://img.shields.io/badge/-KevinPirnie.com-000d2d?style=for-the-badge&labelColor=000&logoColor=white&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ3aGl0ZSIgc3Ryb2tlLXdpZHRoPSIxLjgiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI+CiAgPGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiLz4KICA8ZWxsaXBzZSBjeD0iMTIiIGN5PSIxMiIgcng9IjQuNSIgcnk9IjEwIi8+CiAgPGxpbmUgeDE9IjIiIHkxPSIxMiIgeDI9IjIyIiB5Mj0iMTIiLz4KICA8bGluZSB4MT0iNC41IiB5MT0iNi41IiB4Mj0iMTkuNSIgeTI9IjYuNSIvPgogIDxsaW5lIHgxPSI0LjUiIHkxPSIxNy41IiB4Mj0iMTkuNSIgeTI9IjE3LjUiLz4KPC9zdmc+Cg==)](https://kevinpirnie.com/)

<p>
  <a href="https://github-stats-extended.vercel.app/api?username=kpirnie&hide_title=true&show_icons=true&include_all_commits=true&theme=algolia"><img height="170" alt="GitHub Stats" src="https://github-stats-extended.vercel.app/api?username=kpirnie&hide_title=true&show_icons=true&include_all_commits=true&theme=algolia" /></a>
  <a href="https://github-stats-extended.vercel.app/api/top-langs?username=kpirnie&hide_title=true&langs_count=5&theme=algolia"><img height="170" alt="Top Languages" src="https://github-stats-extended.vercel.app/api/top-langs?username=kpirnie&hide_title=true&langs_count=5&theme=algolia" /></a>
</p>


A centralized collection of AI working rules, development skills, and project-specific knowledge for Claude Code, Claude.ai, ChatGPT, and OpenAI Codex.

Built around my development workflows, coding conventions, and project architectures, using the open [Agent Skills](https://agentskills.io) format.

The goal is simple: consistent AI-assisted development across different models, tools, and projects without repeatedly explaining the same requirements.

## Overview

This repository contains three primary components:

- **Working Rules:** Global instructions governing how AI assistants interact with me, inspect code, implement changes, and report results.
- **Skills:** Reusable instructions for programming languages, WordPress development, security reviews, maintenance reporting, and other specialized workflows.
- **Project Notes:** Repository-specific architectural information, conventions, dependencies, and implementation details.

Working rules govern behavior, skills provide specialized knowledge, and project notes establish context.

Actual project source code always takes precedence over documentation when determining existing behavior.

## Repository Structure

```text
dotagents/
├── AGENTS.md
├── CLAUDE.md
├── skills/
│   ├── go/
│   ├── php/
│   ├── python/
│   ├── wp-plugin/
│   ├── wp-theme/
│   ├── wordpress-security/
│   ├── updates-audit/
│   ├── updates-completed/
│   ├── updates-commit-message/
│   └── project-handoff/
├── projects/
│   └── <repository-name>.md
├── .agents/
│   └── skills -> ../skills
├── .claude/
│   └── skills -> ../skills
└── scripts/
    ├── install.sh
    └── package-skills.sh
```

### Working Rules

**`AGENTS.md`**

The shared instructions used by AI coding assistants.

These establish my development workflow, including:

- Read and verify existing code before making changes.
- Never ask questions that the repository can answer.
- Do not generate code until explicitly instructed.
- Work incrementally, one item at a time.
- Make minimal, targeted changes.
- Preserve established coding conventions.
- Provide exact file locations and replacement instructions.
- Never introduce dependencies without approval.
- Never add tests or testing infrastructure.
- Never modify unrelated functionality.
- Preserve existing security controls.
- Provide commit messages for completed changes.

See [AGENTS.md](AGENTS.md) for the complete rules.

**`CLAUDE.md`**

Imports the shared working rules for Claude Code.

The repository-local file references `AGENTS.md`. The global installer configures Claude Code to import the installed shared rules instead.

This keeps the instructions centralized rather than maintaining separate copies.

## Available Skills

Each skill lives in its own directory and contains a `SKILL.md` file with Agent Skills-compatible frontmatter.

Skills are grouped by responsibility and can be combined where appropriate.

### Development

| Skill | Description |
|---|---|
| [`go`](skills/go/SKILL.md) | Go development conventions, package organization, documentation, logging, and security patterns. |
| [`php`](skills/php/SKILL.md) | Non-WordPress PHP development, KPT libraries, Composer, PSR-12, PHPDoc, and established project conventions. |
| [`python`](skills/python/SKILL.md) | Python development conventions, documentation, typing, logging, and modular application architecture. |

### WordPress

| Skill | Description |
|---|---|
| [`wp-plugin`](skills/wp-plugin/SKILL.md) | WordPress plugin development, architecture, PHPDoc, security, naming, and WordPress.org compliance. |
| [`wp-theme`](skills/wp-theme/SKILL.md) | WordPress theme development, templates, PHPDoc, assets, performance, accessibility, and WordPress conventions. |
| [`wordpress-security`](skills/wordpress-security/SKILL.md) | Security auditing, vulnerability analysis, authorization, nonces, input validation, escaping, and targeted hardening. |

The `wp-plugin` and `wp-theme` skills define coding conventions for their respective projects.

The `wordpress-security` skill supplements either one when performing security-sensitive work.

### WordPress Maintenance

| Skill | Description |
|---|---|
| [`updates-audit`](skills/updates-audit/SKILL.md) | Generate structured WordPress update audit reports from raw site notes. |
| [`updates-completed`](skills/updates-completed/SKILL.md) | Generate reports documenting completed WordPress core, theme, and plugin updates. |
| [`updates-commit-message`](skills/updates-commit-message/SKILL.md) | Generate detailed Git commit messages for WordPress updates, installations, and reinstalls. |

These skills use the same underlying maintenance notes but produce different deliverables.

### Project Management

| Skill | Description |
|---|---|
| [`project-handoff`](skills/project-handoff/SKILL.md) | Generate detailed architectural and implementation handoff documents for continuing development in another AI session. |

### Using Skills Together

Some tasks benefit from multiple skills.

For example:

| Task | Skills |
|---|---|
| Develop a WordPress plugin | `wp-plugin` |
| Develop a WordPress theme | `wp-theme` |
| Audit WordPress plugin security | `wp-plugin` + `wordpress-security` |
| Audit WordPress theme security | `wp-theme` + `wordpress-security` |
| Develop a standalone PHP application | `php` |
| Generate a WordPress update report | `updates-audit` or `updates-completed` |
| Prepare a WordPress update commit | `updates-commit-message` |
| Prepare an AI development handoff | `project-handoff` |

Skills provide task-specific instructions. They do not override the global working rules or the actual codebase.

## Project Notes

The [`projects/`](projects/) directory contains repository-specific reference material.

Each file is named after its corresponding repository:

```text
projects/<repository-name>.md
```

Project notes document existing architecture, code organization, dependencies, integrations, conventions, and other useful information.

They help AI assistants understand how an individual project works before making changes.

### Project Inventory

**PHP Libraries and Applications**

- `kp-cache`
- `kp-database`
- `kp-datatables`
- `kp-logger`
- `kp-memos`
- `kp-php-utils`
- `kp-router`
- `kp-wpfieldframework`
- `kptv-filter-app`

**WordPress Plugins**

- `wpplugin-kp-agent-ready`
- `wpplugin-kp-file-manager`
- `wpplugin-security-header-generator`
- `wpplugin-stargazers`
- `wpplugin-support`
- `wpplugin-the-cache-purger`

**Python Applications and Utilities**

- `kp-wp-vulnscan`
- `kptv-fast`
- `kptv-restreamer`
- `kptv-weather`
- `visual-regressor`
- `webscanner`
- `wp-malware-scanner`

**Go Applications**

- `kptv-proxy`
- `m3u-scanner`
- `podnest`

Project notes are reference material, not replacements for reading the current source code.

If documentation conflicts with the repository, the repository is authoritative.

## Installation

### Claude Code and OpenAI Codex

Clone the repository and run the installer:

```bash
git clone https://github.com/kpirnie/dotagents.git
cd dotagents
./scripts/install.sh
```

The installer creates symbolic links into the global locations used by Claude Code and Codex.

**Working Rules**

```text
~/.agents/AGENTS.md -> <repo>/AGENTS.md
~/.codex/AGENTS.md  -> <repo>/AGENTS.md
```

Claude Code receives a global `CLAUDE.md` that imports the shared rules:

```text
~/.claude/CLAUDE.md
    @~/.agents/AGENTS.md
```

**Skills**

Each skill is linked individually:

```text
~/.claude/skills/<name> -> <repo>/skills/<name>
~/.agents/skills/<name> -> <repo>/skills/<name>
```

**Project Notes**

```text
~/.agents/projects -> <repo>/projects
```

The installer also restores the repository-local skill symlinks if necessary.

Existing regular files or directories that conflict with installed links are backed up using a timestamped `.bak` suffix.

The installer can be run again after adding new skills.

Since the skills are symlinked, edits to existing skill files are reflected in the installed locations without reinstalling.

### Claude.ai

The repository includes a packaging script for creating individual skill ZIP archives.

Run:

```bash
./scripts/package-skills.sh
```

This generates:

```text
dist/
├── go.zip
├── php.zip
├── python.zip
├── wp-plugin.zip
├── wp-theme.zip
├── wordpress-security.zip
├── updates-audit.zip
├── updates-completed.zip
├── updates-commit-message.zip
└── project-handoff.zip
```

Each archive contains its corresponding skill directory and `SKILL.md` file.

Upload the desired archives through Claude's Skills settings, where supported by your account.

For project-specific work, add `AGENTS.md` and the matching `projects/<repository-name>.md` to the Claude Project's knowledge.

### ChatGPT

Skill installation depends on the ChatGPT features available to your account or workspace.

Where custom skill uploads are supported, use the individual archives generated by:

```bash
./scripts/package-skills.sh
```

Otherwise, the relevant instructions can be supplied as project context:

- `AGENTS.md` for working rules.
- `skills/<name>/SKILL.md` for specialized conventions.
- `projects/<repository-name>.md` for project-specific information.

Custom skill support and settings locations may vary by account and product version.

## Adding Skills

Create a new directory under `skills/`:

```text
skills/
└── example-skill/
    └── SKILL.md
```

Each skill must include YAML frontmatter:

```yaml
---
name: example-skill
description: Explain what this skill does and when it should be used.
---
```

Requirements:

- The skill name must match its directory.
- Use lowercase names with hyphens.
- Give each skill a clear, specific responsibility.
- Describe when the skill should be invoked.
- Keep instructions focused and reusable.
- Avoid duplicating rules already defined in `AGENTS.md`.
- Follow the open Agent Skills format.

After adding a skill, run:

```bash
./scripts/install.sh
```

To regenerate upload archives, run:

```bash
./scripts/package-skills.sh
```

Update the skill inventory in this README when adding or removing skills.

## Adding Project Notes

Create a Markdown file in `projects/` matching the repository name:

```text
projects/example-repository.md
```

Project notes should describe existing implementation details, including:

- Project purpose and architecture.
- Languages, frameworks, and dependencies.
- Source code organization.
- Important classes, functions, and integration points.
- Build and deployment conventions.
- Project-specific restrictions or compatibility requirements.
- Established coding patterns.

Project notes should describe verified behavior, not assumptions.

No installation step is necessary when the `projects/` directory is already linked globally.

## Windows

The repository uses Git symbolic links for its repository-local skill directories.

On Windows, enable Developer Mode and configure Git to preserve symbolic links before checking out the repository:

```bash
git config --global core.symlinks true
```

Without proper symlink support, Git may check out symbolic links as plain text files rather than functional directory links.

The installation scripts require a Bash-compatible environment and Unix-style symbolic-link support.

## Maintenance

This repository is intended to evolve alongside my development projects.

General guidelines:

- Keep global working rules centralized in `AGENTS.md`.
- Keep language and framework conventions in reusable skills.
- Keep repository-specific details in project notes.
- Remove obsolete or one-off skills when they are no longer useful.
- Update documentation when skill responsibilities change.
- Avoid duplicating instructions across multiple files.
- Preserve compatibility with the AI tools consuming these instructions.

## License

Released under the [MIT License](LICENSE).

Copyright © Kevin Pirnie.
