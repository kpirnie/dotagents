---
name: kptv-fast
description: KPTV FAST Streams — Python Flask + gevent aggregator that merges free FAST streaming providers into one M3U playlist and XMLTV EPG. Read before any work in kpirnie/kptv-fast.
---

# KPTV FAST Streams

Pulls live channels from free streaming services concurrently, dedupes them by name + stream URL, filters them, and serves one M3U playlist, XMLTV EPG (plain + gzip), and JSON. Caches for 2 h by default with background refresh, and warms caches at startup. Repo: `kpirnie/kptv-fast`. Skill: `python`.

## Stack
- Python 3.12 (`python:3.12-alpine3.20`), `requirements.txt` (unpinned): gevent, flask, requests, beautifulsoup4
- Runs as `appuser` (UID 1000); entry `python3 app.py`

## Map
- `app.py` — `monkey.patch_all()` first ("CRITICAL: must be first"), `setup_logging()`, `UnifiedStreamingAggregator().run()`
- `core/aggregator.py` — env config and blueprint registration: `CACHE_DURATION` (7200), `MAX_WORKERS` (5), `PROVIDER_TIMEOUT` (45), `GIT_COUNTRY`, `STARTUP_CACHE_DELAY` (10), `ENABLED_PROVIDERS` (`all`), `WARM_CACHE_ON_STARTUP` (`true`), `DEBUG` (`false`)
- `core/provider_loader.py` — `load_providers()`: `_single` list of `(key, module, Class)` for `xumo`, `tubi`, `pluto`, `plex`, `samsung`, `distrotv`, `lg`, `stirr`, `philo`, `roku`, `whale`; git group (`GitIptvProvider`, `GitFreetvProvider`); apsattv group (`vizio`, `localnow`, `tcl`, `tclplus`, `firetv`, `xiaomi`, `tablo`)
- `core/channel_manager.py` — channel cache, concurrent fetching, filtering, dedup
- `providers/base_provider.py` — `BaseProvider(ABC)`: pooled `requests.Session` with urllib3 `Retry` (tries `allowed_methods`, falls back to `method_whitelist`), abstract `get_channels()` / `get_epg_data()`, `validate_channel`, `normalize_channel`, `validate_programme`, `normalize_programme`, `get_user_agent`, `get_timeout`, `make_request`
- `providers/<name>_provider.py` — one per service; `git_providers.py`, `apsattv_provider.py` hold several classes
- `routes/` — `create_blueprint()` per module: `playlist.py` (`/playlist`, `/epg`, `/epg-gz`, `/channels`), `status.py` (`/`, `/status`, `/debug`), `admin.py` (`/clear_cache`, `/refresh`)
- `utils/` — `epg_aggregator.py`, `epg_fallback.py`, `logging_config.py` (`setup_logging`, `get_logger`)

## Configuration (readme, beyond the above)
`WARM_EPG_ON_STARTUP`, `CHANNEL_NAME_INCLUDE`/`_EXCLUDE`, `GROUP_INCLUDE`/`_EXCLUDE` (regex), `PLUTO_REGION`/`_USERNAME`/`_PASSWORD`, `PLEX_REGION`, `SAMSUNG_REGION`, `PHILO_SESSION_ID`, `PHILO_HASHED_SESSION_ID`, `WHALE_COUNTRY`, `WHALE_LANG`, plus country filtering for the git and LG providers

## Conventions
- Short `"""..."""` docstrings (no phpDoc tags), f-string logging, type hints from `typing`
- Per-provider loggers: `logging.getLogger(f"providers.{name}")`

## Readme vs code
- The readme's "Adding a Provider" says to register the class in `app.py` inside `_init_providers()`; in the code, providers are registered in `core/provider_loader.py` (`load_providers()`)
