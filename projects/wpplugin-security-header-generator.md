---
name: wpplugin-security-header-generator
description: Security Header Generator — wp.org WordPress plugin that sends security headers, builds a Content Security Policy and Permissions-Policy for front-end, admin and REST. Legacy work/inc layout. Read before any work in kpirnie/wpplugin-security-header-generator.
---

# Security Header Generator

WordPress.org plugin (`security-header-generator`) that emits security response headers (HSTS, X-Frame-Options, Referrer-Policy, etc.), generates a CSP and Permissions-Policy from settings/presets, and applies them to front-end, wp-admin, and REST responses. Repo: `kpirnie/wpplugin-security-header-generator`. Skill: `wp-plugin` (legacy-era plugin — match its style, don't port it to the `src/` architecture).

## Stack
- PHP 8.2+, GPLv3, settings UI built on `kevinpirnie/kpt-wpfieldframework` (`\KP\WPFieldFramework\Loader::init()`)
- Composer classmap autoload of `work/inc/`; vendor is installed into `distribute/` at build time
- Constants: `WPSH_PATH`, `WPSH_DIRNAME`, `WPSH_FILENAME`, `WPSH_VERSION`
- All settings in one option: `wpsh_settings`

## Layout and build
- `source/` — the plugin you edit; `distribute/` — build output (committed), zipped into a GitHub release on `v*` tags
- `build.sh` (`npm run build`) — checks header `Version` == readme `Stable tag`, copies PHP + index guards + readme into `distribute/`, minifies `assets/css/style.css` and `assets/js/script.js` in place with esbuild, copies root `composer.json` and runs `composer install --no-dev --classmap-authoritative` inside `distribute/`, generates the `.pot`

## Map
- `source/security-header-generator.php` — plugin header, constants, requires `work/common.php`
- `source/work/common.php` — bootstrap: activation checks (PHP < 8.2 and network activation both `wp_die`), settings, assets, AJAX (`wp_ajax_wpsh_load_preset`), header processing
- `source/work/inc/` — classes prefixed `KCP_CSPGEN_`:
  - `kcp-cspgen-headers.php` (`KCP_CSPGEN_Headers`: `kp_process_headers`, front-end via `send_headers`, REST via `rest_pre_serve_request`, admin via `admin_init`, `kp_csp_builder`, `kp_permissions_policy_builder`)
  - `kcp-cspgen-settings.php` (`KCP_CSPGEN_Settings`, field framework tabs)
  - `kcp-cspgen-presets.php`, `kcp-cspgen-configs.php`
  - `kcp-cspgen-migration.php` (`KCP_CSPGEN_Migration::maybe_migrate()` on `plugins_loaded` priority 1: one-time pre-5.6.03 flat → grouped `csp_group_*` schema, snapshotting first to `wpsh_settings_pre_migration_backup`) + `kcp-cspgen-migration-backup.php` (priority 2: admin notice for `manage_options` users and a nonce-protected download of the backup, which deletes the option)
- `source/work/doc.php` — in-admin documentation; `source/assets/` — admin CSS/JS
- `index.php` "silence is golden" guards in every directory

## Conventions
- Old-style plugin header comment (no docblock) and `defined('ABSPATH') or die(...)` first
- File docblocks `@since 7.4`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package Kevin's Security Header Generator`
- Method names prefixed `kp_` / `kcp_`; `sprintf` with placeholders for translated HTML

## Behaviour in the code
- Headers are applied on three paths: front end `send_headers`, REST `rest_pre_serve_request`, admin `admin_init` (`KCP_CSPGEN_Headers`)
- Activation `wp_die`s on PHP < 8.2 and on network activation (`work/common.php`)
- Preset AJAX `wp_ajax_wpsh_load_preset`: `check_ajax_referer('wpsh_presets', 'nonce')` then `manage_options`
- `build.sh` only compares header `Version` with readme `Stable tag`; `WPSH_VERSION` is not checked
- readme.txt: Contributors `kevp75`, Requires at least 6.0.9, Tested up to 7.1.2

## Repo inconsistency
- Plugin header `Version: 6.1.04` and readme `Stable tag: 6.1.04`, but `define('WPSH_VERSION', '6.0.86')`
