---
name: kp-memos
description: KP Memos — secure self-hosted PHP 8.5 notes app (WYSIWYG, attachments, categories/tags, sharing, mandatory TOTP) built on the KPT libraries with stored-procedure-only MariaDB access. Read before any work in kpirnie/kp-memos.
---

# KP Memos

Self-hosted notes app: WYSIWYG editor with source view, multi-file attachments, nested categories, tags, full-text search, draggable pinned notes, public share links, PWA shell. Every account uses password + TOTP. Repo: `kpirnie/kp-memos`. Skill: `php`.

## Stack
- PHP 8.5 (`pdo_mysql`, `sodium`, `openssl`, `redis`, `fileinfo`, `intl`, `mbstring`, `curl`), MariaDB, Redis
- Composer: `kevinpirnie/kpt-router ^1.0`, `kpt-database ^1.1`, `kpt-utils ^1.2`, `ezyang/htmlpurifier`, `bacon/bacon-qr-code`; PSR-4 `KPM\` → `app/`, files `app/helpers.php`
- PSR-12 via `composer cs-check` / `cs-fix` (views excluded)
- No front-end build: plain `assets/js/*.js`, `assets/css/app.css`, self-hosted fonts

## Map
- `index.php` — the only executable PHP entry (`KPM_PATH`, autoload, `(new \KPM\Core\App())->run()`)
- `app/Core/`:
  - `App.php` (boot, `KPT\Router`, `KPT\Session`, `KPT\Logger`), `Routes.php` (`[method, path, Controller::class, action, [middleware]]`), `Request.php`, `Response.php`, `View.php`, `Config.php`
  - `Db.php` — gateway over `KPT\Database`: `rows()`, `row()`, `value()` calling **stored procedures only**
  - security: `Auth.php`, `Totp.php`, `Csrf.php` (token + `Origin`/`Sec-Fetch-Site` same-origin), `Security.php` (nonce CSP, headers), `Throttle.php`, `Audit.php`
  - content: `Html.php` (HTMLPurifier on save), `Storage.php` (attachments: random names, `send()` as download with sandbox CSP), `NoteQuery.php`, `Taxonomy.php`, `Format.php`, `Cache.php`, `Flash.php`, `Cli.php`
- `app/Controllers/` — `Auth`, `Account`, `Admin`, `Notes`, `Attachments`, `Share`, `Taxonomy` (base `Controller.php`)
- `app/views/` — `layout.php` + `account/`, `admin/`, `auth/` (enroll, verify, recovery codes), `notes/`, `share/`, `taxonomy/`, `partials/`
- `app/config.sample.php` → `app/config.php` (`app.url`, `app.key`, DB, Redis, `security.trusted_proxies`, `app.debug`)
- `bin/` — `keygen.php`, `install.php` (tables + procedures + EXECUTE-only app account; idempotent), `create-admin.php`
- `database/` — `01-schema.sql` (tables, idempotent), `10-…50-*.sql` (`kpm_` procedures, dropped/recreated each install)
- `storage/` — attachments + HTMLPurifier cache (writable, web-denied); `.nginx.conf` — reference server config

## Conventions
- File docblocks `@since 8.5`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package KP Memos`; `declare(strict_types=1)`
- Conversational lowercase comments (`// throw it under our namespace`)

## Security model (readme, matched by the code layout)
- Database: the app account holds `EXECUTE` only; every read/write is a `kpm_` stored procedure (definer's rights) scoped to the signed-in user, called through `KPM\Core\Db::rows()/row()/value()`; no table names in the PHP. `bin/install.php` re-applies tables (idempotent) and drops/recreates procedures. Admins manage accounts and can never read another user's notes.
- Sign in: Argon2id passwords, mandatory TOTP (RFC 6238, replay-protected, secret encrypted with `app.key`), 10 single-use recovery codes stored as keyed hashes, per-account and per-IP lockouts, idle and absolute session timeouts, sessions bound to the browser and ended by any password/role/2FA change
- Requests: CSRF token plus `Origin` / `Sec-Fetch-Site` checks on every state change (`app/Core/Csrf.php`), nonce-based CSP, HSTS, `frame-ancestors 'none'`, no-store caching (`app/Core/Security.php`)
- Content: note HTML sanitized by HTMLPurifier on save (`app/Core/Html.php`); attachments stored under random names, never executed, served as downloads with a sandbox CSP, only raster images inline (`app/Core/Storage.php`)
- Sharing: 192-bit link tokens, optional expiry and Argon2id password, revocation by regenerating, `noindex`, throttled
- PWA: online only; the service worker caches the static shell, never notes
- Config: `app.url` must be the exact public origin; `security.trusted_proxies` for a reverse proxy; `app.debug` off in production; back up the DB, `storage/attachments/` and `app.key` (without it enrolled authenticators and recovery codes stop working)
- nginx (`.nginx.conf`) denies `storage/`, `app/`, `bin/`, `database/`, `vendor/`, `tmp/`, so root `index.php` is the only executable PHP
