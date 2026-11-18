---
name: php
description: Kevin's vanilla PHP standards — KPT library conventions,
  PSR-12, strict types, composer/packagist packaging, docblocks.
  Use for any non-WordPress PHP work (libraries, apps, CLI tools).
  For WordPress plugin work, use the wp-plugin skill instead.
---

# Kevin's PHP Standards (non-WordPress)

Reference implementations: the kevinpirnie/kpt-* packagist libraries
(kpt-database, kpt-utils, kpt-logger, kpt-cache, kpt-router,
kpt-datatables — repos kpirnie/kp-database, kp-php-utils, kp-logger,
kp-cache, kp-router, kp-datatables). Consumption examples:
kpirnie/kptv-filter-app, kpirnie/kp-memos.

## File conventions
- `declare(strict_types=1);` after the file docblock (current standard;
  add when substantially editing older files that lack it)
- Namespace: `KPT` for libraries; wrap class definitions in
  `if (! class_exists('\KPT\ClassName', false)) {` guards (traits:
  `trait_exists`)
- File-level docblock with title, description, and tags:
  @since <PHP version — NOT package version>, @author Kevin Pirnie
  <me@kpirnie.com>, @package KP Library. (kpt-datatables is the exception:
  `@since 1.0.0`, `@package KPT\DataTables`; kp-memos uses
  `@package KP Memos`.)
- Class-level docblock repeats the tags, plus @access, and documents
  notable @property entries and array shapes in <code> blocks
  (response/options array shapes documented inline is house style)
- Method docblocks: description, @since, @access, @param aligned,
  @return, @throws where applicable

## Code style
- PSR-12 enforced: `composer cs-check` / `cs-fix` (phpcs/phpcbf
  `--standard=PSR12`) must pass on any change
- PHP 8.4+ for the libraries (`"php": ">=8.4"`); kpt-utils stays on
  `>=8.2`, kp-memos targets 8.5. Typed properties, constructor promotion,
  readonly, match, nullsafe, `mixed` where honest
- Conversational lowercase step comments between docblocks:
  "// throw it under my namespace", "// hold the database handle object"
  — same voice as all Kevin's code; comment most logical steps
- Patterns in use: fluent chaining (query builder), named-instance
  connections (`protected static array $instances` keyed by name, e.g.
  `Database::getInstance('default', $settings)`), consistent
  response-array returns with an `isError()` check (`KPT\Curl`, modeled
  after WordPress's HTTP API)
- Database access: PDO only, prepared statements always, `FETCH_OBJ`
  default

## Packaging (packagist libraries)
composer.json carries: name `kevinpirnie/<pkg>`, type library, keywords,
homepage, MIT license, funding block (paypal + ko-fi), authors, `php`
requirement + ext requirements, require-dev with `phpunit/phpunit ^13`
(where the repo has tests) and `squizlabs/php_codesniffer`, psr-4
`"KPT\\" => "src/"` (kpt-datatables: `src/class/`), autoload-dev
`"KPT\\Tests\\" => "tests/"`, scripts (`cs-check`, `cs-fix`, plus `test`
/ `test-coverage` where there are tests), config (`sort-packages`,
`optimize-autoloader`, `preferred-install: dist`), support links.
kpt-database also has `archive.exclude` (tests, coverage, .github,
.phpunit.cache, phpunit.xml).

- Inter-package deps use ^caret constraints (e.g. kpt-logger ^1.0)
- Existing tests live in `tests/` (grouped by area, e.g. kp-database's
  Binding/Crud/Transaction tests); don't add tests or test
  infrastructure unless asked
- CI (`.github/workflows/ci.yml`): `composer validate --strict`,
  `cs-check`, and `test` where defined. Release (`release.yml`): tag
  `v*` → GitHub release + Packagist update

## Apps consuming the libraries
- MVC-lite: `index.php` front controller + kpt-router, controllers,
  views, assets (kptv-filter-app: `controllers/`, `views/`; kp-memos:
  `app/Controllers/`, `app/views/`, `app/Core/`); business logic in
  controllers or KPT library classes, not views
- Never modify anything under vendor/ — changes to kpt-* packages
  happen in their own repos and version-bump through composer

## Rules
- Match the file's era: don't add strict_types or modernize typing in
  a file you're only touching lightly
- Minimal diffs; no drive-by refactors; PSR-12 fixes only within the
  lines being changed
