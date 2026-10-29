---
name: kp-database
description: KPT Database (kevinpirnie/kpt-database) — fluent PDO wrapper in the KPT namespace with named connection instances. Read before any work in kpirnie/kp-database.
---

# KPT Database

Fluent PDO database wrapper published to Packagist as `kevinpirnie/kpt-database`. Used by kpt-datatables, kptv-filter-app and kp-memos. Repo: `kpirnie/kp-database`. Skill: `php`.

## Stack
- PHP `>=8.4`, `ext-pdo`, requires `kevinpirnie/kpt-logger ^1.0`; PSR-4 `KPT\` → `src/`
- Dev: `phpunit/phpunit ^13.0`, `squizlabs/php_codesniffer ^3.7`; scripts `cs-check` / `cs-fix` (`--standard=PSR12` on `src`), `test`, `test-coverage`
- Drivers per readme: mysql, pgsql, sqlite, sqlsrv, oci; settings object: `driver`, `server`, `schema`, `username`, `password`, `charset`, `collation`, `persistent`
- CI (`.github/workflows/ci.yml`, PHP 8.4 + 8.5): `composer validate --strict`, `composer run cs-check`, `composer run test`
- Release (`release.yml`): tag `v*` → `composer install --no-dev`, GitHub release with generated notes, Packagist update via API

## Map
- `src/Database.php` — `KPT\Database`, wrapped in `if (! class_exists('\KPT\Database', false))`
  - instances: `configure(array|object)`, `getInstance(string $name = 'default', ?object $db_settings)` keyed in `protected static array $instances`, `closeInstance`
  - building/running: `query`, `bind`, `single`, `many`, `fetch`, `first`, `count`, `exists`, `execute`, `raw(string $query, array $params = [])`, `reset`
  - writes: `upsert`, `replace`; `transaction`, `commit`, `rollback`; `quote`
  - `configureDriver()` runs post-connection driver setup; default fetch mode `\PDO::FETCH_OBJ`
- `tests/` — `DatabaseTestCase` + `MockLogger`, and one class per area: Batch operations, Binding, Connection, CRUD, Helper methods, Profiling, Query, Quote, Raw query, Transaction

## Conventions
- File and class docblocks: `@since 8.4`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package KP Library`; class docblock lists `@property protected $db_handle`, `$current_query`, `$query_params`, `$fetch_mode`
- Method docblocks: name, description, `@since`, `@author`, `@package`, `@param`, `@return`, `@throws`
- `// throw it under my namespace`-style step comments; camelCase public methods (readme: "PSR-12 Compliant")
- Logging through static `Logger::debug()` / `Logger::error()` (readme: a `KPT\Logger` with those static methods must be available)
