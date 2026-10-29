---
name: kp-wpfieldframework
description: KPT WP Field Framework (kevinpirnie/kpt-wpfieldframework) — Composer library for WordPress options pages, meta boxes (posts, users, nav menu items), Gutenberg blocks, repeaters, conditional fields and settings export/import. Read before any work in kpirnie/kp-wpfieldframework.
---

# KPT WP Field Framework

Composer library that WordPress plugins embed to build options pages, meta boxes and Gutenberg blocks generated from meta box configs, with repeaters, groups, accordions, conditional fields, a storage API, and JSON settings export/import. Packagist `kevinpirnie/kpt-wpfieldframework`; used by Security Header Generator, The Cache Purger, KP Support and US Star Gazers. Repo: `kpirnie/kp-wpfieldframework`. Skills: `wp-plugin` + `php`.

## Stack
- PHP `>=8.2` (CI runs 8.4 only), WordPress 6.8+ (readme), `declare(strict_types=1)`, PSR-4 `KP\WPFieldFramework\` → `src/`
- No `require-dev`; scripts `cs-check` / `cs-fix` (`--standard=PSR12`, ignores JS/CSS); CI: `composer validate --strict`, `cs-check`; tag `v*` release → GitHub release + Packagist update
- Admin assets: `assets/css/wsf-admin.css` (handle `kp-wsf-admin`, version `time()`), `assets/js/wsf-admin.js` (handle `kp-wsf-admin`, deps `jquery`, `wp-color-picker`, `jquery-ui-datepicker`, `jquery-ui-sortable`, version `Framework::VERSION`)

## Map
- `src/Framework.php` — final class, instances per identifier (`private static array $instances`, `getInstance(string $identifier = 'kpff')`): `init`, `addOptionsPage`, `addMetaBox`, `registerOptionsPages`, `registerSettings`, `registerMetaBoxes`, `saveMetaBoxes`, `saveUserMeta`, `renderUserMetaFields`, `renderNavMenuFields`, `saveNavMenuFields`, `registerBlocks`, `getFieldTypes`, `getStorage`, `getExportImport`, `getRegisteredOptionKeys`, `getOptionsPageBySlug`, `ajaxExportSettings`, `ajaxImportSettings` (`wp_ajax_kp_wsf_export_settings_<id>` / `..._import_settings_<id>`)
- `src/OptionsPage.php`, `src/MetaBox.php` (posts, users, nav menu items), `src/BlockGenerator.php`
- `src/FieldTypes.php` — field rendering; `src/Repeater.php` — repeatable groups
- `src/Sanitizer.php` — `sanitize`, `sanitizeUnknown`, `validate`
- `src/Storage.php` — options (`getOption`, `getOptionKey`, …), post/user/term/comment meta, transients, generic `get`/`update`/`delete`, cache toggles
- `src/ExportImport.php` — `export`, `exportWithDefaults`, `exportDownload`, `import`, `importFromFile`, `validate` (rejects invalid JSON and a missing/non-array `settings` key)
- `src/Loader.php` — `Loader::init()` with its own autoloader for use without Composer

## Conventions
- File docblock: description, `@package KP\WPFieldFramework`, `@author Kevin Pirnie <iam@kevinpirnie.com>`, `@copyright 2025 Kevin Pirnie`, `@license MIT`, `@since 1.0.0`
- `defined('ABSPATH') || die('No direct script access allowed');` after the namespace; classes guarded by `class_exists`
- Prefixes: `kp_wsf_` for hooks/AJAX/nonce (`kp_wsf_nonce`), `kp-wsf-` for script/style handles

## Security checks in the code
- Export/import AJAX: `check_ajax_referer('kp_wsf_nonce', 'nonce')` then `current_user_can($required_capability)`
- Import size capped by the `kp_wsf_max_import_bytes` filter (default `DEFAULT_MAX_IMPORT_BYTES` = 1048576)
- Meta box saves: `wp_verify_nonce($_POST[<id>_nonce], <id>_nonce_action)` then the post type's `edit_post` cap / `edit_user`; options pages check the configured `capability`
