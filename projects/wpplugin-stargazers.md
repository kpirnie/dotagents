---
name: wpplugin-stargazers
description: US Star Gazers (sgup) — WordPress plugin for a weather + astronomy site: NWS/Open-Meteo weather, NASA/SWPC/USNO space data synced via WP-CLI into CPTs, rendered by Gutenberg blocks and templates. Read before any work in kpirnie/wpplugin-stargazers.
---

# US Star Gazers

Site-specific WordPress plugin (`sgup`) that syncs weather and space data (NWS forecasts/alerts, Open-Meteo fallback + geocoding, NASA APOD/NEO/DONKI, NOAA SWPC space weather, USNO rise/set/transit) into WordPress via WP-CLI and displays it with Gutenberg blocks and PHP templates. Not a wp.org plugin. Repo: `kpirnie/wpplugin-stargazers`. Skill: `wp-plugin` (legacy `work/inc` classmap style, not the `src/` architecture).

## Stack
- PHP 8.4+, WP 6.8+, MIT license (header), text domain `sgup`
- Composer: classmap `work/inc/` + file `work/sgu.php`; requires `kevinpirnie/kpt-wpfieldframework` (settings, API keys)
- Blocks: `@wordpress/scripts` via `webpack.config.js` — entry `source/work/blocks-src/index.js` → `source/build/blocks.js` (+ `blocks.asset.php`)
- `npm run build` = `npm run blocks` (`wp-scripts build`) then `./build.sh`: checks header `Version` == readme `Stable tag`, rebuilds `distribute/` (PHP, readme, LICENSE, esbuild-minified `assets/*.css|*.js`, `assets/vendor/`, minified `build/blocks.js` — fails if `source/build/blocks.js` is missing), `composer install --no-dev --classmap-authoritative` inside `distribute/`, `.pot`; release workflow zips `distribute/` on `v*` tags

## Map
- `source/sgup.php` — header, `SGUP_VERSION|PATH|FILENAME|URI`, vendor autoload, `init` (priority 5) → `SGUP::init()`, WP-CLI (on `cli_init`): `wp sgu sync data|imagery|both|cleanup`, `wp sgu historical apod|imagery|both` (one-time bulk imports, default start 2015-01-01)
- `source/work/sgu.php` — `SGUP` main class
- `source/work/inc/` — `sgu-plugin.php` (`SGU_Plugin`), `sgu-settings.php` (`SGU_Settings`, API key fields), `sgu-static.php` (`SGU_Static` render helpers), `sgu-sync.php` (`SGU_Sync`)
  - `cpt/` — `SGU_CPTs`, `SGU_CPT_Settings`, `SGU_CPT_Admin_Cols`
  - `space/` — `SGU_Space_API`, USNO API, data CRUD/get, imagery, requests, `sgu-space-blocks.php` (block registration)
  - `weather/` — data, location, `sgu-weather-blocks.php`
- `source/work/blocks-src/` — one JS file per block (apod, alerts, neos, planet positions, star chart, sun/moon rise-set, light pollution, weather, astro menu)
- `source/templates/astro/`, `source/templates/weather/` — server-side render templates
- `source/assets/` — light-pollution map, location, sky-tonight, weather-block CSS/JS

## Conventions
- Docblocks `@since 8.4` (PHP version), `@author Kevin Pirnie <me@kpirnie.com>`, `@package US Stargazers Plugin`
- Classes prefixed `SGU_`, guarded by `class_exists`; spaced arrows (`$this -> method()`) in older files — match the file

## Data flow in the code
- Space data (NASA APOD/NEO/DONKI, SWPC) and imagery are pulled by `SGU_Sync` (WP-CLI) into CPTs and media; `SGU_Space_API` and `SGU_USNO_API` cache lookups in transients (`CACHE_DURATION`)
- Weather (`weather/sgu-weather-data.php`) calls Open-Meteo (forecast + geocoding), `api.weather.gov` (points, alerts) and Zippopotam on demand through `SGU_Static::get_remote_data()`, caching in transients (e.g. `sgu_openmeteo_current_<lat>_<lon>`, 15 minutes) plus an in-memory grid-point cache
- API keys are settings fields (`SGU_Settings::api_key_fields()`) built with the field framework
- readme.txt: Contributors `kevinpirnie`, Requires at least 6.8, Tested up to 7.2, Stable tag 1.0.0
