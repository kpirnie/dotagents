---
name: kptv-proxy
description: kptv-proxy project map and rules — Go IPTV streaming proxy with restreaming, failover, EPG, and admin UI. Use for any work in this repo.
---

# kptv-proxy

Follow the global Go skill for style; this repo uses the `work/<domain>` package layout and the `"{package - FuncName}"` log-prefix convention.

## Map

- `main.go` → `work/app`; HTTP via `gorilla/mux`
- Streaming path: `work/stream`, `work/restream`, `work/buffer`, `work/proxy`, `work/deadstreams`, `work/streamorder` (per-channel order overrides in DB)
- Sources: `work/parser` (m3u8, xtremecodes, master), `work/watcher`
- EPG: `work/epgindex`, `work/schedulesdirect`
- Admin UI/API: `work/admin` (per-domain files: channels, streams, epgs, stats, logs, config, proxy, accounts)
- Auth: `work/users` (Argon2, sessions, token, middleware)
- Infrastructure: `work/db` (`ncruces/go-sqlite3` — CGO-free; do not swap to `mattn`), `work/cache` (otter), goroutine pooling via ants, `work/logger`, `work/config`, `work/constants`, `work/metrics`, `work/middleware`

## Rules

- The streaming hot path is performance-critical: no per-request allocations, locks, or logging added casually; preserve pooling (ants) and cache (otter) usage patterns.
- Failover/dead-stream logic changes need a stated test plan against live streams before merging. The streaming-issues audit follow-up is still pending.
- Stream order overrides: `s_order >= 0` means custom-ordered; `-1` or unset means default. Preserve this sentinel convention.
- Never log stream URLs or credentials at Info level or above.
