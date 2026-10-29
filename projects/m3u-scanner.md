---
name: m3u-scanner
description: KPTV m3u-scanner — Go media library scanner serving extended M3U playlists from memory, with an admin UI that edits metadata and writes it back to .nfo sidecars and audio tags. Read before any work in kpirnie/m3u-scanner.
---

# KPTV m3u-scanner

Recursive media scanner (movies, music, shows, images) that serves extended M3U playlists from RAM over HTTP. Metadata comes from folder structure, embedded tags and Jellyfin/Kodi `.nfo` sidecars; the admin UI edits it and writes it back. Unchanged files load from a SQLite cache on rescans. Repo: `kpirnie/m3u-scanner`. Skill: `go`.

## Stack
- Go (module `m3u-scanner`), stdlib `net/http` with method patterns (`"GET /api/entries"`), stdlib `log`
- SQLite via `ncruces/go-sqlite3` (Wasm, no CGO) and `go.senan.xyz/taglib` (Wasm) sharing wazero; `rwcarlsen/goexif`
- Dockerfile builds `CGO_ENABLED=0` for `${TARGETOS}/${TARGETARCH}` (amd64, arm64); `debian:trixie-slim` final image (readme)
- Admin UI: Tailwind 3 + plain JS in `internal/server/static/src/` (`utils`, `modals`, `entries`, `editor`, `core`), concatenated + minified by `npm run build`, embedded via `//go:embed` in `internal/server/assets.go`

## Map
- `main.go` — config, cache, scan orchestration, cron, server, signal handling
- `internal/config/` — env: `SCAN_PATH` (`/media`), `SCAN_TYPES` (`movies music shows`), `SCAN_NFO` (`false`), `BASE_URL`, `PLAYLIST_NAME` (`playlist.m3u`, read in code, not in the readme table), `SERVE_PORT` (`8888`), `CRON_SCHEDULE` (`*/30 * * * *`), `FFPROBE_PATH` (`/usr/local/bin/ffprobe`); readme also lists `TZ`
- `internal/scanner/` — filesystem walk; `internal/extensions/` — media type by extension
- `internal/parser/` — path-first metadata from folder structure
- `internal/meta/` — `ffprobe.go`, `audio.go`, `video.go`, `exif.go`, `nfo.go` / `nfowrite.go` (`WriteNFO`), `tagwrite.go` (`WriteAudioTags`, `WriteAudioCover`), `enrich.go`, `fscache.go`
- `internal/cache/` — SQLite cache (`meta` table)
- `internal/writer/` — M3U generation; `internal/models/` — entry and media types
- `internal/server/` — `server.go` routes, `handler_api.go`; `internal/cron/` — scheduled scans
- `docker-composer-example.yaml` (that is the filename)

## Endpoints (readme)
- Playlists: `/all.m3u`, `/movies.m3u`, `/music.m3u`, `/shows.m3u`, `/images.m3u`; files: `/media/...`; admin: `/admin/`
- `/health`, `POST /rescan[?type=]`
- API: `GET /api/health`, `GET /api/entries` (`type`, `q`, `limit`, `offset`), `GET|PUT /api/entry/{id}` (PUT saves and writes the `.nfo`), `POST /api/entry/{id}/rescan`, `POST /api/entry/{id}/tags` (music only), `POST /api/rescan`

## Conventions
- No file header block; imports grouped stdlib, blank line, `m3u-scanner/internal/...`
- Log lines: `log.Printf("[component] ...")` / `log.Fatalf("[main] ...")`; section rules in `main.go` like `// ── Config ───`
- `internal/meta` covers the same ground as `kptv-proxy`'s `work/localscan` (NFO, tags, ffprobe) but the files differ

## Behaviour in the code
- Write-back to disk happens only from the API handlers: `PUT /api/entry/{id}` → `meta.WriteNFO`, `POST /api/entry/{id}/tags` → `meta.WriteAudioTags` / `meta.WriteAudioCover`
- `SCAN_NFO=true` only enables reading sidecars and sibling artwork during scans
- Playlists are held in memory and served with no disk I/O at request time (readme)
