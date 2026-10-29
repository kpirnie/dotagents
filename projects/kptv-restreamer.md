---
name: kptv-restreamer
description: KPTV Restreamer — Python/FastAPI HLS/TS restreamer that aggregates Xtream Codes and M3U sources with failover, one-upstream-many-clients caching, and an Xtream Codes API. Read before any work in kpirnie/kptv-restreamer.
---

# KPTV Restreamer

Async FastAPI app that pulls streams from Xtream Codes and M3U sources, groups them under unified channel names, fails over between sources, and serves each stream from a single upstream connection to many clients. Exposes M3U8, EPG, management/debug endpoints, and an Xtream Codes-compatible API. Repo: `kpirnie/kptv-restreamer`. Skill: `python` (older style than the skill's current reference repos — match this repo when editing it).

## Stack
- Python 3.12 (`python:3.12-alpine`), FastAPI, uvicorn, aiohttp, pydantic v2, PyYAML — pinned in `requirements.txt`
- Config: YAML at `/app/config/config.yaml` (`python -m app.main --config ...`)

## Map
- `app/main.py` — `create_app()` (lifespan, CORS, routers), argparse, uvicorn
- `app/config.py` — `load_config()` → `AppConfig` via `yaml.safe_load`
- `app/models/stream.py` — `StreamInfo`, `SourceConfig`, `FilterConfig`, `XtreamAuthConfig`, `AppConfig`
- `app/core/restreamer.py` — `StreamRestreamer` orchestrator
- `app/sources/` — `base.py`, `xtream.py`, `m3u.py`
- `app/services/` — `stream_aggregator.py` (group by name), `stream_mapper.py`, `stream_filter.py` (regex include/exclude), `stream_cache.py` (`StreamBuffer` + `CachedStream`: shared buffer, consumer registration, staleness, reconnect), `connection_manager.py` (per-source and global connection limits), `stream_service.py`, `epg_cache.py`
- `app/api/routes.py` — `/`, `/playlist.m3u8`, `/status`, `/cache-status`, `/active-streams`, `/streams`, `/stream/{id}`, `/debug/*`, `/epg.xml`, `/xmltv.php`
- `app/api/xtream_routes.py` — `/player_api.php`, `/live|movie|series/{username}/{password}/{id}.{ext}`

## Conventions
- Module docblocks: title, description, `@package KPTV_Restreamer`, `@author Kevin Pirnie <me@kpirnie.com>`, `@copyright Copyright (c) 2025`
- Many functions carry the phpDoc-style docstring *above* the `def` plus a short one-line docstring inside (e.g. `create_app` in `app/main.py`)
- Lowercase step comments (`# setup the imports necessary`, `# setup the logging`, `# now open it grab the data as yaml`)
- `logging.basicConfig(level=logging.INFO)` in `app/main.py`; `logger = logging.getLogger(__name__)`

## Architecture (readme)
- Stream caching: one upstream connection per stream, many consumers, in-memory buffer (`StreamBuffer`), stale streams cleaned up
- Aggregation: streams grouped by name across sources; source picked by connection availability; failover to backup sources on failure; an already-cached stream is served from cache regardless of source
- Connection management: global limit (`max_total_connections`), per-source `max_connections`, real-time tracking, per-source API rate limiting
- Config: YAML (`sources`, `filters` regex lists, `max_total_connections`, `bind_host`, `bind_port`, `public_url`, `log_level`, `xtream_auth`), parsed with `yaml.safe_load` into the `@dataclass` models in `app/models/stream.py` (pydantic is in `requirements.txt` but the config models are dataclasses)
