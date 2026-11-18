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
kpt-datatables). Consumption example: kpirnie/kptv-filter-app.

## File conventions
- `declare(strict_types=1);` after the file docblock (current standard;
  add when substantially editing older files that lack it)
- Namespace: `KPT` for libraries; wrap class definitions in
  `if (! class_exists('\KPT\ClassName')) {` guards
- File-level docblock with title, description, and tags:
  @since <PHP version — NOT package version>, @author Kevin Pirnie
  <me@kpirnie.com>, @package KP Library
- Class-level docblock repeats the tags, plus @access, and documents
  notable @property entries and array shapes in <code> blocks
  (response/options array shapes documented inline is house style)
- Method docblocks: description, @since, @access, @param aligned,
  @return, @throws where applicable

## Code style
- PSR-12 enforced: `composer cs-check` / `cs-fix` (phpcs/phpcbf) must
  pass on any change
- PHP 8.2+ minimum: typed properties, constructor promotion, readonly,
  match, nullsafe, `mixed` where honest
- Conversational lowercase step comments between docblocks:
  "// throw it under my namespace", "// hold the database handle object"
  — same voice as all Kevin's code; comment most logical steps
- Patterns in use: fluent chaining (query builder), named-instance
  singleton/connection pools (static $instances keyed by name),
  consistent response-array returns with an isError() check pattern
  (modeled after WordPress's HTTP API)
- Database access: PDO only, prepared statements always, FETCH_OBJ
  default

## Packaging (packagist libraries)
composer.json must include: name kevinpirnie/<pkg>, type library,
keywords, homepage, MIT license, funding block (paypal + ko-fi),
authors, php >=8.2 + ext requirements, require-dev with phpunit ^11
and squizlabs/php_codesniffer, archive.exclude (tests, coverage,
.github, phpunit config), psr-4 autoload "KPT\\" => "src/",
autoload-dev "KPT\\Tests\\", scripts (cs-check, cs-fix, test,
test-coverage), config (sort-packages, optimize-autoloader,
preferred-install dist), support links.

- Inter-package deps use ^caret constraints (e.g. kpt-logger ^1.0)
- Tests in tests/ mirroring src/; new public methods get PHPUnit
  coverage

## Apps consuming the libraries
- MVC-lite: index.php front controller + kpt-router, controllers/,
  views/, assets/; business logic in controllers or KPT library
  classes, not views
- Never modify anything under vendor/ — changes to kpt-* packages
  happen in their own repos and version-bump through composer

## Rules
- Match the file's era: don't add strict_types or modernize typing in
  a file you're only touching lightly
- Minimal diffs; no drive-by refactors; PSR-12 fixes only within the
  lines being changed