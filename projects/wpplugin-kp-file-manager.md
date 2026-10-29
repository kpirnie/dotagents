---
name: wpplugin-kp-file-manager
description: KP File Manager — security-critical WordPress file manager (admin page, block, shortcode) sandboxed to wp-content with per-role operation matrix, audit log, rate limiting, GitHub-release updater. Read before any work in kpirnie/wpplugin-kp-file-manager.
---

# KP File Manager

WordPress plugin (`kp-file-manager`) to browse, edit, upload, rename, delete and chmod files from wp-admin or a front-end block/shortcode, sandboxed to a base path under wp-content, with per-role permissions (including an `anonymous` role), audit logging, rate limiting, and a CodeMirror-style editor. Distributed via GitHub Releases with its own updater. Repo: `kpirnie/wpplugin-kp-file-manager`. Skill: `wp-plugin`.

## Stack
- PHP 8.2+, WP 6.0+, MIT license (header); no Composer, no build step — the repo root **is** the plugin
- `KFM_`-prefixed classes autoloaded from `includes/class-kfm-<name>.php`; constants `KFM_VERSION`, `KFM_PLUGIN_DIR`, `KFM_PLUGIN_URL`
- Release workflow zips the repo on `v*` tags; `KFM_Updater` reads `api.github.com/repos/<GH_REPO>/releases/latest`
- Multisite: network activation is supported; per-site disable list in site option `kfm_disabled_sites`

## Map
- `kp-file-manager.php` — header, constants, autoloader, `plugins_loaded` boot (skips disabled subsites), `final class KFM_Plugin`
- `includes/`:
  - `class-kfm-file-manager.php` — `resolve`, `relative`, `list_dir`, `read_file`, `write_file`, `create_file`, `create_dir`, `delete`, `rename`, `copy`, `move`, `chmod`, `upload`, `get_base_path`
  - `class-kfm-ajax.php` — `PUBLIC_ACTIONS` (`kfm_list`, `kfm_read`, `kfm_write`, `kfm_create_file`, `kfm_create_dir`, `kfm_delete`, `kfm_rename`, `kfm_copy`, `kfm_move`, `kfm_chmod`, `kfm_upload`, `kfm_download`) registered for `wp_ajax_` **and** `wp_ajax_nopriv_`; `dispatch()` gate: `KFM_Settings::current_user_allowed()` → `check_ajax_referer('kfm_nonce','nonce')` → referer host check → `KFM_Permissions::current_user_can_op()` → `KFM_Rate_Limiter::check()`
  - `class-kfm-permissions.php` — role × operation matrix (`kfm_role_permissions`; ops list/read/write/upload/rename/delete/chmod), admins bypass, `anonymous` role for logged-out users, deny by default
  - `class-kfm-settings.php` — settings incl. `kfm_blocked_exts` (default blocks php/phtml/phar/…/htaccess/htpasswd/sh/cgi)
  - `class-kfm-audit-log.php`, `class-kfm-rate-limiter.php`, `class-kfm-admin-menu.php`, `class-kfm-asset-loader.php`, `class-kfm-block.php`, `class-kfm-shortcode.php`, `class-kfm-updater.php`
- `blocks/file-manager/` — `block.json`, `index.js` (prebuilt, with `index.asset.php`), `render.php`, styles
- `templates/` — admin page and settings tabs (general, permissions, security, audit)
- `assets/` — `kfm-app.js`, admin/front CSS; `uninstall.php`

## Conventions
- Docblocks `@package KP - File Manager`, `@since 1.0.0`, `@author Kevin Pirnie <iam@kevinpirnie.com>`
- Class files `class-kfm-*.php`, WordPress-style naming (`snake_case` methods)

## Security behaviour in the code
- `dispatch()` order: `KFM_Settings::current_user_allowed()` (logged-out users only if the `anonymous` role has any op) → `check_ajax_referer('kfm_nonce', 'nonce')` → referer host must match `home_url()` host (`www.` ignored) → `KFM_Permissions::current_user_can_op()` → `KFM_Rate_Limiter::check()`
- Permissions: `manage_options` bypasses the matrix; logged-out users use the `anonymous` role; any one of a user's roles granting the op is enough; `default_ops_for_role()` gives `administrator` every op and every other role (including `anonymous`) none
- `resolve()`: normalizes the path, `realpath()` of the target (or of its parent for new files), then requires it to equal the base path or start with base path + separator
- `kfm_blocked_exts` (default `php,phtml,phar,php3,php4,php5,php7,phps,pht,exe,sh,pl,cgi,htaccess,htpasswd,shtml,asis`) is enforced in `create_file`, `rename`, `copy` and `upload`
- Audit log entries are written for bad referer, role-permission denial, rate-limit blocks, operation errors, successful operations, and downloads
- Version is set in two places: header `Version` and `KFM_VERSION` (both `1.0.60`)

## Repo inconsistency
- `includes/class-kfm-updater.php` sets `GH_REPO = 'kpirnie/wppluggin-kp-file-manager'` (double "g"); the repo is `kpirnie/wpplugin-kp-file-manager`
