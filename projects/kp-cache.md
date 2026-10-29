---
name: kp-cache
description: KPT Cache (kevinpirnie/kpt-cache) — static multi-tier PHP cache (array, OPcache, SHMOP, APCu, YAC, Redis, Memcached, SQLite, file, async) in the KPT namespace. Read before any work in kpirnie/kp-cache.
---

# KPT Cache

Static multi-tier cache that discovers which tiers are available, prioritises them, pools Redis/Memcached connections, and fails over between tiers. Packagist `kevinpirnie/kpt-cache`; required by kpt-router. Repo: `kpirnie/kp-cache`. Skill: `php`.

## Stack
- PHP `>=8.4`, `ext-json`, requires `kevinpirnie/kpt-logger ^1.0`; `suggest`: `ext-redis`, `ext-memcached`, `ext-apcu`, `ext-yac`
- Autoload: PSR-4 `KPT\` → `src/` plus `classmap` `src/` (filenames are lowercase)
- Dev: `phpunit/phpunit ^13`, `squizlabs/php_codesniffer ^3.7`; scripts `test`, `test-coverage`, `cs-check` / `cs-fix` (`--standard=PSR12`, ignores JS/CSS)
- CI (PHP 8.4 + 8.5): `composer validate --strict`, `cs-check`, `test`, `test-coverage`; tag `v*` release → GitHub release + Packagist update

## Map
- `src/cache.php` — `KPT\Cache`, composed of traits: `CacheArray`, `CacheAPCU`, `CacheFile`, `CacheMemcached`, `CacheOPCache`, `CacheRedis`, `CacheSHMOP`, `CacheYAC`, `CacheAsync`, `CacheRedisAsync`, `CacheFileAsync`, `CacheMemcachedAsync`, `CacheMixedAsync`, `CacheOPCacheAsync`, `CacheSQLite`
  - public static API: `configure`, `reinitialize`, `get`, `set`, `delete`, `clear`, `clearSpecificTier`, `getFromTier`, `setToTier`, `deleteFromTier`, `setToTiers`, `deleteFromTiers`, `isTierValid`, `isTierAvailable`, `isTierHealthy`, `getValidTiers`, `getAvailableTiers`, `getTierStatus`, `getLastUsedTier`, `getLastError`, `cleanup`, `close`, `getStats`, `isHealthy`, `getSettings`, `setCachePath`, `getCachePath`, `updateCachePath`, `refreshCachePathFromGlobal`, `setConnectionPooling`, `setPromotionTtl`, `debug`
- `src/cache/backends/` — one trait file per tier: `array`, `apcu`, `file`, `memcached`, `opcache`, `redis`, `shmop`, `sqlite`, `yac`, `async_file`, `async_memcached`, `async_mixed`, `async_opcache`, `async_redis`
- `src/cache/managers/` — `tier.php` (`CacheTierManager`: `TIER_*` constants, availability tests), `key.php` (`CacheKeyManager`), `healthmonitor.php` (`CacheHealthMonitor`)
- `src/cache/config/config.php` (`CacheConfig`), `src/cache/pooling/pooling.php` (`CacheConnectionPool`), `src/cache/async/` (`CacheAsync` trait, `CachePromise`), `src/cache/cleaner.php` (`CacheCleaner`)
- `tests/CacheTest.php`

## Conventions
- File and class docblocks: `@since 8.4`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package KP Library`
- Every class/trait wrapped in `if (! class_exists('\KPT\...', false))` / `trait_exists`
- `// throw it under my namespace`-style step comments

## Readme vs repo
- The readme's CLI section runs `php vendor/kevinpirnie/kpt-cache/cache/cleaner.php`; the file in the repo is `src/cache/cleaner.php`
