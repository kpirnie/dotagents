---
name: kp-php-utils
description: KPT Utils (kevinpirnie/kpt-utils) — PHP 8.2+ static utility classes (Arr, Str, Crypto, Curl, Http, Sanitize, Validate, Session, Token, ...) in the KPT namespace. Read before any work in kpirnie/kp-php-utils.
---

# KPT Utils

Static utility classes, Packagist `kevinpirnie/kpt-utils`; used by kptv-filter-app and kp-memos (`\KPT\Http`, `\KPT\Crypto`, `\KPT\Session`, `\KPT\Token`). Repo: `kpirnie/kp-php-utils`. Skill: `php`.

## Stack
- PHP `>=8.2`, `ext-openssl`, `ext-sodium`, `ext-curl`, `ext-intl`; no Composer runtime deps; PSR-4 `KPT\` → `src/`
- Dev: `squizlabs/php_codesniffer ^3.6` only; scripts `cs-check` / `cs-fix` (`--standard=PSR12`), `quality` (`cs-check`); no test suite
- CI (PHP 8.2, 8.3, 8.4): `composer validate --strict`, `cs-check`; tag `v*` release → GitHub release + Packagist update

## Map
- `src/<Class>.php`, one class each (all 20 guarded by `class_exists`): `Arr`, `Cast`, `Cli`, `Collection`, `Crypto`, `Curl`, `DateTime`, `Env`, `Http`, `Num`, `Paginator`, `Pipeline`, `Retry`, `Sanitize`, `Session`, `Stopwatch`, `Str`, `Token`, `Uuid`, `Validate`
- `Crypto.php` — sodium (`sodium_crypto_pwhash` key derivation, `sodium_memzero`), `hash_equals` comparison
- `Curl.php` — every method returns a consistent response array; check with `Curl::isError()`
- `readme.md` — per-class reference under `## Classes`

## Conventions
- `declare(strict_types=1)` after the file docblock
- File docblock: title, description, `@since      8.2`, `@author     Kevin Pirnie <me@kpirnie.com>`, `@package    KP Library` (tag columns aligned)
- Class docblock adds `@copyright  2026 Kevin Pirnie`, `@license    MIT`
- `// namespace this class`, `// make sure the class does not already exist`-style comments
