---
name: kptv-weather
description: KPTV Weather — self-hosted TV-style weather channel container (Python/Pillow renderer → external ffmpeg H.264 → one MPEG-TS stream over HTTP). Read before any work in kpirnie/kptv-weather.
---

# KPTV Weather

Renders broadcast-style weather graphics in Python, encodes them to H.264 with a bind-mounted ffmpeg, and serves one continuous MPEG-TS channel over HTTP that any number of clients can pull at once. One station per container, configured entirely through `KPTVW_` environment variables. Images: `ghcr.io/kpirnie/kptv-weather` (`main` → `:beta`, tags → version + `:latest`, amd64 + arm64). Repo: `kpirnie/kptv-weather`. Skill: `python`.

## Stack
- Python 3.14 (`python:3.14-slim`), `requirements.txt`: `Pillow==11.3.0`, `requests==2.32.5`
- ffmpeg is not in the image (Dockerfile says so); a static build is bind-mounted and pointed to by `KPTVW_FFMPEG_PATH` (default `/usr/local/bin/ffmpeg`); `FFMPEGStreamer` errors with "ffmpeg not found at …" otherwise
- Encoders: `KPTVW_ENCODER=auto` probes NVENC, QSV, VAAPI with a one-frame test encode and falls back to `libx264`; `/dev/dri` passthrough for hardware
- Data: Open-Meteo (forecast, no key), NWS (alerts, US only), NOAA reflectivity + RainViewer (radar), OpenStreetMap (base maps), Zippopotam (ZIP lookup)
- Entry: `python -m kptvweather.main` (`main()` → `sys.exit(main())`)

## Endpoints
- `/stream.ts` (`KPTVW_STREAM_PATH`), `/playlist.m3u8` (`KPTVW_PLAYLIST_PATH`), `/health` and `/status` (client count, bytes served, channel name); default port `5960`

## Map
- `kptvweather/main.py` — resolves location, starts the encoder and HTTP service, builds pages, runs the render loop
- `kptvweather/config.py` — `ENV_PREFIX = "KPTVW_"`; typed readers: trimmed string, clamped int, clamped float, fixed-set choice
- `kptvweather/core/` — `layer.py` (`Layer`: own RGBA surface, `z`, `per_frame`, `min_interval`), `compositor.py` (`Compositor.compose`, `present`), `scheduler.py`, `datastore.py`
- `kptvweather/layers/` — `almanac`, `chrome`, `clock`, `current`, `daily`, `forecast_text`, `header_current`, `hourly_graph`, `maps`, `radar`, `ticker`
- `kptvweather/providers/` — `openmeteo.py`, `nws.py` (both send a `User-Agent`)
- `kptvweather/output/` — `stream_ffmpeg.py` (`FFMPEGStreamer`), `fanout.py`, `http_server.py`
- `kptvweather/` — `pages.py`, `layout.py`, `draw.py`, `theme.py`, `icons.py`, `normalize.py`, `rss.py`, `map_tiles.py`, `radar_sources.py`, `utils.py`
- `kptvweather/data/` — `cities.py`, `zipcodes.py`
- `assets/` — fonts, icons, branding, music

## Pages (readme)
Current Conditions, 12-Hour Trend, 7-Day Forecast, Live Radar, Regional Conditions, Forecast Highs, Extended Forecast, Almanac — about 14 s each (`KPTVW_PAGE_SECONDS`); `KPTVW_RADAR_SOURCE=off` drops radar. Header band + bottom ticker (`KPTVW_RSS_URLS`).

## Configuration groups (readme)
Location (`ZIP`, `LAT`/`LON`, `LOCATION_NAME`, `TZ`), Channel (`CHANNEL_NAME`, `CHANNEL_LOGO`), Encoder (`FFMPEG_PATH`, `ENCODER`, `ENCODER_PRESET`, `RESOLUTION`, `FPS`, `VIDEO_KBPS`, `AUDIO_KBPS`), Service (`HTTP_HOST`, `HTTP_PORT`, `STREAM_PATH`, `PLAYLIST_PATH`, `BASE_URL`), Data (`UNITS`, `DATA_INTERVAL_SEC`, `REGIONAL_INTERVAL_SEC`, `REGIONAL_CITIES`, `RADAR_SOURCE`), Presentation (`PAGE_SECONDS`, `TICKER_SPEED`, `SCROLL_SPEED`, `MUSIC_DIR`, `MUSIC_VOLUME`, `RSS_URLS`, `RSS_REFRESH_SEC`, `RSS_MAX_ITEMS`) — all prefixed `KPTVW_`

## Conventions
- Module docblocks: title, description, `@package KPTV Weather`, `@author Kevin Pirnie <me@kpirnie.com>`, `@copyright Copyright (c) 2026`
- `from __future__ import annotations`; lowercase step comments (`# setup the imports`); class attributes commented above (`# where this sits in the stack, higher draws later`)
- New settings go through the `config.py` readers and the readme Configuration tables

## Behaviour in the code
- Each `Layer` redraws its own surface only when its `min_interval` comes around; only `per_frame` layers are pasted every frame (`core/layer.py` docblock: "what keeps a thirty frame per second channel affordable")
