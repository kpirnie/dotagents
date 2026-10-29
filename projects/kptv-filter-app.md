---
name: kptv-filter-app
description: KPTV Filter App (KPTV Stream Manager) — PHP 8.4 IPTV provider/stream manager with sync-time filtering, M3U export and Xtream Codes API emulation, built on the KPT libraries. Read before any work in kpirnie/kptv-filter-app.
---

# KPTV Filter App (KPTV Stream Manager)

Self-hosted PHP app for managing IPTV providers (Xtream Codes and M3U), filtering streams at sync time, and exporting per-user playlists as M3U or through an Xtream Codes-compatible API. A CLI sync tool pulls and filters provider streams on cron. Repo: `kpirnie/kptv-filter-app`. Skill: `php` (this repo is the skill's KPT consumption example).

## Stack
- PHP `>=8.4` (`config.platform.php` pinned to `8.4`), MVC-lite front controller, `vendor/` committed
- KPT libraries via Composer `dev-main`: `kevinpirnie/kpt-router`, `kpt-datatables`, `kpt-utils` (plus their deps `kpt-database`, `kpt-cache`, `kpt-logger`); PHPMailer 7
- DB: MySQL/MariaDB (readme), configured in `config.json` `database` (`driver`, `server`, `port`, `schema`, `username`, `password`, `charset`, `collation`, `tbl_prefix` `kptv_`) and passed straight to `KPT\Database`; `assets/schema.sql` is the schema (includes stored procedures used by the CLI cleanup action)
- Front-end: plain CSS/JS in `assets/`, minified by `npm run build` (clean-css + terser → `kptv.min.css`, `kptv.min.js`)
- `my_epg/` — `epg-sync`, a standalone Go tool that merges and dedupes every XMLTV file in a directory into one `epg.xml` (`--input`, `--output`)

## Map
- `index.php` → `controllers/main.php` (bootstraps autoloader, `KPTV_PATH`, `KPTV_CONFIG_PATH`, `KPTV` alias, display_errors forced off)
- `controllers/` — classmap-autoloaded: `kptv-user.php` (`KPTV_User`), `kptv-stream-playlists.php`, `kptv-xtreme-api.php`, `kptv-proxy.php` (browser playback/CORS proxy), `kptv-static.php`
- `views/routes.php` — middleware definitions (`guest_only`, `auth_required`, `admin_required`, `csrf_protection` with exemptions for XC/stream paths, `auth_rate_limit`, `api_rate_limit`) and the route table (`'method'`, `'path'`, `'middleware'`, ...)
- `views/pages/` — `stream/` (providers, filters, streams, missing, faq), `users/` (login, register, forgot, changepass, admin), `home.php`, `terms.php`; `views/wrapper/` — header/footer/nav/sidebar; `views/common/control-panel.php`
- `sync/` — CLI only (`kptv-sync.php sync|testmissing|fixup|cleanup` with `--user-id`, `--provider-id`, ...); classes under `sync/src/` in namespace `Kptv\IptvSync\` (`SyncEngine`, `ProviderManager`, `FilterManager`, `FixupEngine`, `MissingChecker`, `EpisodeSync`, `GroupBackfill`, own `KpDb` + `Database/` query helpers, `Parsers/` providers)
- `.nginx.conf` — reference server config: XC endpoints, internal proxy locations, deny rules

## Conventions
- File docblocks: title, description, `@since 8.4` (PHP version), `@author Kevin Pirnie <me@kpirnie.com>`, `@package KP Library`
- Direct-access guard in views/includes: `defined('KPTV_PATH') || die('Direct Access is not allowed!');`
- KPT library classes are called as `\KPT\...` (e.g. `\KPT\Http::getUserReferer()`)
- Conversational lowercase step comments

## Facts the code and readme state
- `vendor/` is committed, including the `kevinpirnie/kpt-*` packages; changes to those belong in their own repos
- `config.json` (`appname`, `debug_app`, `mainuri`, `xcuri`, `mainkey`, `mainsecret`, `database`, `smtp`) lives in the project root; `.nginx.conf` denies `/config.json`, `/assets/config.json`, `/sync/`, composer/package files and readme/licence files
- `sync/kptv-sync.php` exits with 403 unless run from the CLI
- `mainkey` / `mainsecret` encrypt and decrypt IDs used in exported URLs and app auth tokens (`controllers/kptv-static.php`)
- The login cookie is set `secure: true`, so HTTPS is expected
- `/proxy/stream?url=` (`controllers/kptv-proxy.php`) rewrites HLS playlists for browser playback; the readme warns it can be abused if left open
- License: MIT (`composer.json` and `LICENSE`)
