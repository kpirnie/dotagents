---
name: kp-datatables
description: KPT DataTables (kevinpirnie/kpt-datatables) — server-side PHP table/CRUD library (joins, filters, bulk actions, inline edit, uploads, modal forms) with UIKit/Bootstrap/Tailwind/Plain themes and a vanilla JS client. Read before any work in kpirnie/kp-datatables.
---

# KPT DataTables

Server-rendered PHP data table library with a zero-dependency vanilla JS client and four themes. Packagist `kevinpirnie/kpt-datatables`; used by kptv-filter-app. Repo: `kpirnie/kp-datatables`. Skill: `php`.

## Stack
- PHP `>=8.4`, `ext-fileinfo`, requires `kevinpirnie/kpt-database ^1.0` and `kevinpirnie/kpt-logger ^1.0`; PSR-4 `KPT\` → `src/class/`
- Dev: `phpunit/phpunit ^13`, `phpstan/phpstan ^1.10`, `squizlabs/php_codesniffer ^3.7`; `phpcs.xml` uses `PSR12`; scripts `test`, `test-coverage`, `cs-check`, `cs-fix`, `build`, `build-js`, `build-css`, `build-tailwind`
- Assets: `build.js` + Tailwind 3 (`package.json`: `build:tailwind`, `build:js`, `build:css`, `build`, `dev`, `watch:tailwind`) → `src/assets/js/dist/`, `src/assets/css/dist/`
- CI (PHP 8.4 + 8.5): `composer validate --strict`, `cs-check`, `test`, `test-coverage`; tag `v*` release → GitHub release + Packagist update

## Map
- `src/class/DataTables.php` — `KPT\DataTables`, fluent configuration and orchestration
- `src/class/DataTablesBase.php` — shared base
- `src/class/AjaxHandler.php` — `handle(string $action)` with an `$allowedActions` whitelist: `fetch_data`, `add_record`, `edit_record`, `delete_record`, `bulk_action`, `inline_edit`, `upload_file`, `fetch_record`, `action_callback`, `fetch_aggregations`, `fetch_select2_options`, `grid_order`; `sanitizeColumnName()`, `sanitizeSortDirection()`, `validateSearchColumn()`; uploads checked against size, `allowed_extensions`, `UPLOAD_BLOCKED_EXTENSIONS`, and `finfo` MIME type
- `src/class/Renderer.php` — HTML output; `esc()` = `htmlspecialchars(..., ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')`
- `src/class/ThemeManager.php` — theme class maps
- `src/assets/js/` — `datatables.js`, `select2.js`, `theme-helpers.js` (+ `dist/`)
- `src/assets/css/themes/` — `uikit.css`, `bootstrap.css`, `tailwind.src.css` → `tailwind.css`, `plain.css`
- `tests/DataTablesTest.php`

## Conventions
- `declare(strict_types=1)` first; classes guarded by `class_exists('KPT\<Class>', false)`
- Class docblocks: description/feature list, `@since   1.0.0` (package version — the other KPT libraries use the PHP version), `@author  Kevin Pirnie <me@kpirnie.com>`, `@package KPT\DataTables`
- Configuration methods are documented in the readme (`Core Configuration Methods`, `Action Configuration`, `Bulk Actions`, `Modal Forms`, `Calculated Columns`, `Footer Aggregations`, …)
