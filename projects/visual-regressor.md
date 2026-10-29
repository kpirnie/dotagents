---
name: visual-regressor
description: KP Visual Regressor — container-only Python/FastAPI visual regression app: Playwright screenshots of URL pairs, pixel + expected-content checks, optional Anthropic/OpenAI review, spider, PDF/email reports, four account levels with mandatory TOTP. Read before any work in kpirnie/visual-regressor.
---

# KP Visual Regressor

Projects group comparisons (two URLs plus strings that must appear on both). A run captures both sides in headless Chromium, diffs the screenshots, checks the expected strings against each page's rendered text, stores the three images, and — when the project names an AI provider — sends the screenshots, diff, measurements and page text to the model for a verdict. Runs can spider the site for 4xx/5xx, be marked manual pass, and download/email as PDF. Repo: `kpirnie/visual-regressor`. Images: `ghcr.io/kpirnie/visual-regressor` (`:latest`, `:1.2.3`, `:main`, `:dev`). Skill: `python`.

## Stack
- Python 3.14 (`python:3.14-slim`), FastAPI + uvicorn, Jinja2, Playwright (`playwright install --with-deps --only-shell chromium`), Pillow, numpy, PyMySQL, argon2-cffi, cryptography, pyotp, segno, reportlab, anthropic, openai — pinned in `requirements.txt`
- Runs as uid/gid 10001 (`vreg`), port 8080, data under `/data`
- MariaDB in a second container in the same pod (`compose-example.yaml`: app uses `network_mode: "service:mariadb"`, reaches it on `127.0.0.1`; `slirp4netns` on the DB container); first start loads `sql/schema.sql`; tables prefixed `kpvr_`
- Env (only these): `VREG_DB_HOST`/`_PORT`, `VREG_DB_NAME`, `VREG_DB_USER`/`_PASSWORD`, `VREG_SECRET_KEY` (required; encrypts every stored secret), `VREG_SAFE_MODE`. Everything else is on the Global Settings page; a project overrides what it has its own field for.
- Entry: `python -m visregressor.main`; `vr-unit.service` runs it as a systemd/podman unit inside the `pn-dev-vr` PodNest pod

## Map
- `visregressor/main.py` — entry; `visregressor/core/guard.py` refuses to start outside a container (no override); `visregressor/core/logging.py`
- `visregressor/config.py`, `settings.py`, `defaults.py` — env config, DB-backed global settings and defaults
- `visregressor/runner.py` — `Runner`: `start`, `_execute` (captures/compare/review), `_spider`, `_spider_allows`, findings, prune
- `visregressor/capture/` — `browser.py` (Playwright capture, ignore-selector masking, freeze animations), `settings.py`
- `visregressor/compare/` — `image.py` (pixel diff, size padding), `content.py` (expected strings)
- `visregressor/ai/` — `base.py` (`Judgement`, `Judge` protocol, `build_judge`), `anthropic_judge.py`, `openai_judge.py`, `prompt.py`
- `visregressor/netguard.py` — `check_url()` / `BlockedHostError`: refuses private, loopback, link-local and reserved targets unless the global setting allows them
- `visregressor/db/store.py` + `sql/schema.sql` — `kpvr_projects`, `kpvr_pages`, `kpvr_runs`, `kpvr_results`, `kpvr_spider_findings`, `kpvr_users`, `kpvr_recovery_codes`, `kpvr_trusted_devices`, `kpvr_sessions`, `kpvr_project_users`, `kpvr_audit`, `kpvr_settings`
- `visregressor/auth.py`, `twofactor.py`, `crypto.py` — Argon2id, TOTP + recovery codes, secret encryption
- `visregressor/web/` — `app.py`, `security.py` (session resolution, CSRF), `throttle.py` (lockouts), `routes/` (`ui`, `api` incl. `/api/health`, `auth`, `users`, `settings`, `audit`), `templates/`, `static/`
- `visregressor/report.py` (PDF), `mailer.py`, `email_template.py`, `storage.py` (screenshots under the shots dir), `utils.py`

## Conventions
- Module docblocks: title, prose description, `@package Visual Regressor`, `@author Kevin Pirnie <me@kpirnie.com>`, `@copyright Copyright (c) 2026`; `from __future__ import annotations`; `# setup the imports`
- Function docblocks inside the def with `@param name: type` / `@return type:` tags
- The readme is the user manual; features are documented there in prose

## Rules (as implemented and documented in the repo)
- `check_url()` runs when a comparison URL is saved (`web/routes/ui.py`), again at capture (`runner.py`), and on every spider URL; "Allow private and loopback addresses" is a global, admin-only setting.
- Stored secrets (comparison/spider basic auth, authenticator secrets, SMTP password, API keys) are encrypted with a key from `VREG_SECRET_KEY`; passwords and API keys are write-only in the UI and only noted as changed in the audit log.
- Basic-auth credentials are handed to Chromium scoped to that URL's own origin.
- `/shots/` images are served only with a signed per-run token that lapses after an hour; `/api/health` only says `ok` without a session; every form post carries a CSRF token; sign-out is a POST.
- `X-Forwarded-For` / `X-Forwarded-Proto` are believed only from **Trusted proxies**.
- Account levels: Admin, Manager, Trial, User. Trial accounts never get AI review, spider, PDF or email, are limited to one project/one comparison and 5 runs per UTC day.
- Every account needs TOTP (7-day grace for new accounts); codes are never accepted twice; 12 recovery codes stored as keyed hashes.
- A comparison whose AI review fails is recorded as **warn**, never pass; a missing expectation fails the comparison whatever the model says.
- AI review sends three downscaled images and up to 8,000 characters of page text per comparison; there is no spend cap in the app.
- Deleting runs/projects deletes their screenshots; nothing deletes while a run is in flight; **Runs to keep** prunes at the end of each run.
- `VREG_SAFE_MODE=true` boots on shipped network/cookie/storage settings to recover from a bad config.
