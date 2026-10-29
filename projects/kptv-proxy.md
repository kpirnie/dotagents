---
name: kptv-proxy
description: KPTV Proxy — Go IPTV stream aggregator/proxy with failover, restreaming, EPG, Xtream Codes output, HDHomeRun emulation, local media and admin UI. Read before any work in kpirnie/kptv-proxy.
---

# KPTV Proxy

Go IPTV proxy that aggregates M3U/Xtream Codes sources, dedupes channels, fails over between streams, restreams (Go or FFmpeg), merges EPG, and serves M3U8, XC API, and HDHomeRun-emulation output. Repo: `kpirnie/kptv-proxy`. Skill: `go`.

## Stack
- Go (module `kptv-proxy`), `gorilla/mux`, `coder/websocket`
- SQLite via `ncruces/go-sqlite3` (CGO-free); Dockerfile builds `CGO_ENABLED=0`, multi-arch via `$BUILDPLATFORM`/`$TARGETARCH`
- `panjf2000/ants` worker pool, `maypok86/otter` cache, `xsync`, Prometheus metrics, `grafov/m3u8`, taglib
- Admin UI: Tailwind 3 + plain JS in `static/src/*.js`, concatenated and minified by `npm run build` (order set in `package.json`); `build.sh` runs it

## Map
- `main.go` → `work/app` (`app.go` boots pool/cache, `route.go` public routes, `restart.go`, `version.go`)
- Public output: `work/handlers/` — playlists (`/pl`, `/playlist`), streams (`/s`), XC API (`/player_api.php`, `/get.php`, `/xmltv.php`, `/live`, `/movie`, `/series`), EPG, logos, local media, `hdhr.go`
- Streaming path: `work/proxy/` (stream, playlist, restreaming, sessions, epg, import), `work/restream/` (restream loop, ffmpeg, hls, fallback, clients, stats), `work/stream/`, `work/buffer/`, `work/deadstreams/`, `work/client/`
- Sources: `work/parser/` (m3u8, xtremecodes, master, seriesinfo), `work/filter/`, `work/watcher/`
- EPG: `work/epgindex/`, `work/schedulesdirect/`
- Local media: `work/localscan/` (scanner, ffprobe, nfo, tag writing, TMDB enrich), `work/tmdb/`
- Logos: `work/logos/`
- Admin API: `work/admin/` (one file per area + `routes.go`, `websocket.go`); auth in `work/users/` (Argon2id, sessions, API tokens with permission bitmask, middleware)
- Data: `work/db/` (`db.go` schema + `Get()`/`GetReader()`, one file per table group, `migrate.go` = one-time JSON→SQLite migration), `work/cache/`, `work/config/`, `work/constants/`, `work/types/`, `work/utils/`, `work/logger/`, `work/metrics/`, `work/middleware/`
- `static/` — admin HTML/CSS/JS, `openapi.json`, `api-docs.html`

## Conventions
- No copyright/licence header; 38 of the 115 files under `work/` open with a path comment (`// work/db/streamorder.go`)
- Import grouping varies: `main.go` groups stdlib / third-party / local, many `work/` files use one mixed block — match the file
- Logging prefix: `"{package/file - FuncName} message: %v"`, e.g. `logger.Error("{parser/m3u8 - ParseM3U8} fetching M3U8 from %s: %v", ...)`
- Upstream URLs are logged through `utils.LogURL(cfg, url)`, which obfuscates them when `ObfuscateUrls` is set
- Tables prefixed `kp_`; schema in `initSchema` in `work/db/db.go`; `work/db/migrate.go` (`MigrateFromJSON`) is the one-time import of `/settings/config.json` into `kp_settings`
- `db.Get()` is the single serialized write connection; `db.GetReader()` is the read pool "for every SELECT path" (`work/db/db.go`)

## Behaviour in the code
- Worker pool: `ants.NewPool(cfg.WorkerThreads, ants.WithPreAlloc(true))` in `work/app/app.go`; caching via `otter` (`work/cache/`)
- Stream order: `kp_stream_order` (`channel`, `s_hash`, `s_order`); `GetChannelOrder` returns an empty map when a channel has no custom order
- HDHomeRun routes (`/discover.json`, `/device.xml`, …) are wrapped in `users.RequireLocalNetwork` (`work/users/middleware.go`): RFC1918 + loopback only, and `X-Forwarded-For` is honoured only when the TCP peer is loopback
- M3U/stream/XC output routes carry `{username}/{password}` and authenticate against XC accounts; admin auth is Argon2id (`work/users/argon2.go`) with sessions and permission-bitmask API tokens
- SQLite driver is `ncruces/go-sqlite3` (CGO-free); the Dockerfile builds `CGO_ENABLED=0`
