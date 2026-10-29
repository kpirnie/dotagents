---
name: kp-logger
description: KPT Logger — small static PHP logger (ERROR/WARNING/INFO/DEBUG to the system log or a file) that the other KPT libraries depend on. Read before any work in kpirnie/kp-logger.
---

# KPT Logger

Static application logger in the KPT namespace, Packagist `kevinpirnie/kpt-logger`; required by kpt-database, kpt-cache, kpt-router and kpt-datatables (`^1.0`). Repo: `kpirnie/kp-logger`. Skill: `php`.

## Stack
- PHP `>=8.4` (readme: 8.4 or higher), no runtime dependencies; `declare(strict_types=1)`; PSR-4 `KPT\` → `src/`
- Dev: `squizlabs/php_codesniffer ^3.9` only; scripts `cs-check` / `cs-fix` (`--standard=PSR12` on `src`); no tests
- CI (PHP 8.4 + 8.5): `composer validate --strict`, `cs-check`; tag `v*` release → GitHub release + Packagist update

## Map
- `src/Logger.php` — `KPT\Logger` (not wrapped in a `class_exists` guard): static `error`, `warning`, `info`, `debug`, `setLogFile`, `getLogFile`, `setEnabled`, `isEnabled`, `setIncludeStackTrace`
  - writes with `error_log()` when no file is set, otherwise `@file_put_contents(..., FILE_APPEND | LOCK_EX)` and falls back to `error_log()` if that fails; new log files are `chmod 0640`; JSON encoding failures are caught (`JsonException`)

## Conventions
- File and class docblocks: `@since 8.4`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package KP Library`; level constants documented with `/** @var int ... */`
