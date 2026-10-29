---
name: kp-router
description: KPT Router — PHP routing library with middleware, rate limiting, view rendering and Class@method controller resolution, in the KPT namespace. Read before any work in kpirnie/kp-router.
---

# KPT Router

Routing library used by kptv-filter-app and kp-memos (both require `kevinpirnie/kpt-router`). Repo: `kpirnie/kp-router`. Skill: `php`.

## Stack
- PHP `>=8.4`, requires `kevinpirnie/kpt-logger ^1.0` and `kevinpirnie/kpt-cache ^1.0`; `suggest`: `ext-redis`, `predis/predis`
- Autoload: PSR-4 `KPT\` → `src/` plus `classmap` `src/`
- Dev: `phpunit/phpunit ^13`, `squizlabs/php_codesniffer ^3.6`; scripts `cs-check` / `cs-fix` (`--standard=PSR12` on `src`), `test`, `quality` (`cs-check` + `test`)
- CI (PHP 8.4 + 8.5): `composer validate --strict`, `cs-check`, `test`; tag `v*` release → GitHub release + Packagist update

## Map
- `src/router.php` — `KPT\Router` (guarded by `class_exists`), composed of traits `RouterRateLimiter`, `RouterMiddlewareHandler`, `RouterRouteHandler`, `RouterRequestProcessor`, `RouterResponseHandler`
- `src/router/route-handler.php` — `registerRoutes`, `registerMiddlewareDefinitions`, `registerMiddleware`, `getRoutes`, `getMiddlewareDefinitions`, `get`, `post`, `put`, `patch`, `delete`, `head`, `options` (fluent, return `self`)
- `src/router/middleware.php` — `addMiddleware`
- `src/router/ratelimiter.php` — `enableRateLimiter`, `disableRateLimiting` (Redis or file storage)
- `src/router/request-processor.php` — `dispatch`, `notFound`
- `src/router/response-handler.php` — `setViewsPath`, `view`, `share`, `Class@method` controller resolution (checks the class exists and the method is callable, throws otherwise)
- `tests/SimpleRouterTest.php`

## Conventions
- File and class docblocks: `@since 8.4`, `@author Kevin Pirnie <me@kpirnie.com>`, `@package KP Library`
- Classes guarded by `class_exists`, traits by `trait_exists`; `// throw it under my namespace`-style step comments
- Route arrays in the readme use `'method'`, `'path'`, `'handler'` (`'HomeController@index'`), plus middleware keys
