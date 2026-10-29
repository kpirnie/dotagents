---
name: kp-wp-vulnscan
description: KP WP VulnScan (kpwpvs) — single-container Python vulnerability scanner/reporter for WordPress core and the whole wordpress.org plugin/theme catalogs (crawl → feeds → match → report), with FastAPI UI, MariaDB, s6-overlay. Read before any work in kpirnie/kp-wp-vulnscan.
---

# KP WP VulnScan (kpwpvs)

Tracks every WordPress core release and the full wordpress.org plugin and theme catalogs, matches them against vulnerability feeds (Wordfence, NVD, CVE, wordpress.org/core sources), scores priority over issue history, and reports (DB summary, JSON/HTML, Slack/Discord/JSON webhook). One container, one volume, scheduled from the host (weekly). Also used as a PodNest service. Repo: `kpirnie/kp-wp-vulnscan`. Skill: `python`.

## Stack
- Python `>=3.14.7` (`.python-version`), hatchling build, `uv.lock`, console script `kpwpvs`; ruff (line length 120, `E,F,W,I,UP,B`)
- pydantic 2, httpx, SQLAlchemy 2 + PyMySQL, Alembic, cryptography, FastAPI + uvicorn, Jinja2, itsdangerous — pinned in `requirements.txt`
- `Containerfile` with s6-overlay services under `container/rootfs/etc/s6-overlay/s6-rc.d/`: `init-db` → `mariadb` → `init-schema` → `web` + `cron`; helpers `kpwpvs-init-db`, `kpwpvs-init-schema`, `kpwpvs-health`
- Env (only): `KPWPVS_DATABASE_PASSWORD`, `KPWPVS_SECRET_KEY` (sessions + API key encryption), each also as `*_FILE`; `KPWPVS_DATABASE_EMBEDDED=false` for external DB; optional `KPWPVS_SCHEDULE`. Everything else is DB-backed settings.

## Map
- `kpwpvs/__main__.py` — CLI: `scan`, `crawl [--full|--core-only|--skip-core|--themes-only|--skip-themes]`, `feeds [--list|--source|--set-key]`, `match`, `report [--stdout]`, `db upgrade|status|wait|downgrade`, `user add|list|passwd|role`, `web`
- `kpwpvs/core/` — `config.py`, `settings.py`, `db.py`, `migrate.py`, `crypto.py`, `logging.py`
- `kpwpvs/models/` — SQLAlchemy models: `software`, `vulnerability`, `finding`, `feed`, `run`, `report`, `setting`, `user`, `base`
- `kpwpvs/services/` — `pipeline.py` (stages in order, a failed stage doesn't abandon the run), `crawler.py` (checkpointed catalog walk), `feeds.py`, `matcher.py`, `reporter.py`, `settings_service.py`
- `kpwpvs/sources/` — `base.py` + `wordfence.py`, `nvd.py`, `cve.py`, `wporg.py`, `wpcore.py`
- `kpwpvs/web/` — `app.py`, `deps.py`, `security.py`, `routes/` (`auth`, `dashboard`, `catalog`, `findings`, `admin`), `templates/`, `static/` (CSS built by `kpwpvs/web/assets/build.sh`)
- `kpwpvs/templates/report.html.j2`; `kpwpvs/utils/version.py`
- `migrations/` — Alembic (`0001_initial_schema`, `0002_seed_defaults`)

## Conventions
- Module docblocks `@package KP WP VulnScan`, `@author Kevin Pirnie <me@kpirnie.com>`, `@copyright Copyright (c) 2026`; prose-style rationale in docblocks
- Roles: `admin` (everything), `manager` (read + work findings), `user` (read)

## How it works (readme + code)
- Schema is managed by Alembic (`migrations/versions/`), applied by `kpwpvs db upgrade` and the s6 `init-schema` service
- Pipeline (`kpwpvs/services/pipeline.py`): crawl → feeds → match → report; a failing stage does not abandon the run, and the run records which part was stale
- Crawl checkpoints as it goes so an interrupted seed resumes; later runs walk the updated ordering only until they reach ground already covered
- Feeds run in priority order; one being down or unkeyed does not stop the others. The Wordfence feed changes every few hours and rate-limits re-pulls — scheduling is weekly by intent (`0 3 * * 1 podman exec kpwpvs kpwpvs scan`) or `KPWPVS_SCHEDULE`
- Core is matched per release; plugins/themes only against the currently published version. Priority is scored over the whole issue history
- Packages named by feeds but absent from wordpress.org are catalogued as `premium` (8,600 plugins, 2,154 themes per readme), not dropped
- Reports: DB summary always; JSON/HTML only when `/reports` is mounted; webhook (Slack, Discord, generic JSON) only when configured and something met the minimum severity; all three come from one payload; notification counts exclude historical core findings
- Passwords and API keys are read from stdin, never arguments; stored API keys are encrypted with `KPWPVS_SECRET_KEY`
