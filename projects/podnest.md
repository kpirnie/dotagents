---
name: podnest
description: PodNest — self-hosted Podman web hosting control panel with built-in reverse proxy/WAF and the pdnctl host manager. Read before any work in kpirnie/podnest.
---

# PodNest

Self-hosted hosting control panel (Go). Provisions isolated Podman pods per site (WordPress, PHP, Node, .NET, Python, static, reverse-proxy) and fronts them with its own reverse proxy (Coraza WAF + OWASP CRS, GeoIP/ASN, Spamhaus DROP, autoban). Repo: `kpirnie/podnest`. Docs site: podnest.app. Skill: `go`.

## Stack
- Go (module `podnest`), cobra CLI, `net/http` mux, gorilla/websocket, quic-go (HTTP/3)
- SQLite via `mattn/go-sqlite3` (CGO) — WAL, foreign keys on
- Frontend: UIkit, vanilla JS views, esbuild + PostCSS (`npm run build`); CodeMirror 5, Chart.js, Scalar API reference
- Container images from `kpirnie/infra-build` (ghcr.io/kpirnie)

## Map
- `main.go` → `cmd/` (cobra: `serve`, `init`, `reset`, `recreate`, `security`, `unparent`)
- `cmd/pdnctl/` — host-side manager binary (install/update/upgrade/uninstall/service/selfupdate); state in `/etc/podnest/install.json`
- `internal/server/` — `server.go`, `routes.go`, `handler_*.go`, `middleware_*.go`, `background.go` workers, `statscache.go`, `resourcewatcher.go`
- `internal/handlers/<area>/handler.go` — API handlers per area (sites, domains, security, users, nodes, ssl, wpcli, wpupdates, malware, pma, redirects, rproxy, configs, logs, auditlog, settings, health)
- `internal/modules/` — plugin-style architecture:
  - `registry.go` defines `SiteTypeModule` and `FeatureModule` interfaces
  - `types/<type>/` — one module per site type (`module.go`, `containers.go`, `config.go`, `scaffold.go`)
  - `features/<feature>/` — per-site features (backups, basicauth, crons, dbtools, files, sftp, stats, waf)
  - `containers/` — shared container builders (nginx, mariadb, redis, varnish, pma)
- `internal/proxy/` — reverse proxy: `proxy.go`, `caches.go`, `rules.go` (IP/UA/country/ASN allow/deny), `waf.go`, `crs_updater.go`, `geoip.go`, `spamhaus.go`, `autoban.go`, `certs.go`, `redirects.go`, `upstream.go`, `trustedproxies.go`, `sitelogs.go`
- `internal/db/` — one file per table group; `db.go` holds `schema`, `Migrate`, `migrateColumns`
- `internal/podman/` — Podman socket client; `internal/auth/` — sessions, CSRF, rate limit, TOTP; `internal/nodelink/` — parent/child node pairing
- Other `internal/`: `backup` (restic, S3), `cron`, `sftp`, `fileops`, `malware`, `wpupdate`, `notifications` (SNS/mail/SMS), `audit`, `apiutil`, `config`, `logger`, `models`, `version`
- `web/` — embedded via `web/web.go` (`static`, `templates`, `apidocs`); JS/CSS sources in `web/static/src/`, built output in `web/static/js/app.js` and `web/static/css/app.css`
- `web/apidocs/openapi.json` — API spec
- `fail2ban/` — jail/filter configs; `bootstrap.sh` — pdnctl installer; `podnest.service` — systemd unit

## Conventions
- File header on every Go file: `// PodNest - Self-hosted site management platform` / `// Copyright (c) 2026 Kevin Pirnie <iam@kevinpirnie.com>` / `// Licensed under the MIT License. See LICENSE file in the project root for full license text.`
- Godoc comment on exported funcs/types; a short comment above each logical step inside function bodies (e.g. `// the main entry point of the app`, `// Ensure the parent directory exists`); struct fields often carry trailing `//` comments
- Imports grouped: stdlib, blank line, `podnest/internal/...`, blank line, third-party
- Logging: `logger.Debug/Info/Warn/Error` with `"context: message: %v"` prefixes (e.g. `"saveCountryRules: replace failed: %v"`); `internal/logger` drains through a buffered channel so callers never block
- DB tables are prefixed `kppn_`; new installs get `schema` and existing installs get `migrateColumns` (both in `internal/db/db.go`)
- Proxy state is held in `atomic.Pointer` fields on `Proxy` (`internal/proxy/proxy.go`: domain cache, security cache, WAF engines) and rebuilt whole then swapped with `.Store()` (`internal/proxy/caches.go`)
- Site types and per-site features are modules in `internal/modules/` (`SiteTypeModule`, `FeatureModule`); `registry.go` states no `switch` on site type exists outside modules
- Site container images are `ghcr.io/kpirnie/*` (`internal/models/models.go`)
- Version injected at build: `-X podnest/internal/version.AppVersion=...`

## Layers a config or security feature can span
`kppn_` schema + migration (`internal/db`) → proxy cache rebuild (`internal/proxy/caches.go`) → handler (`internal/handlers/<area>`) → middleware (`internal/server/middleware_*.go`) → JS view (`web/static/src/js/views/`) → `web/apidocs/openapi.json` → readme / podnest.app docs → `cmd/pdnctl` if host-level.

## Security invariants in the code
- Lockout preflight on global security rules (`internal/handlers/security/handler.go`): without `Confirm`, a rule set that would block the saving connection answers HTTP 200 `{"status":"confirm","reason":...}`.
- Recovery: `podnest security --bypass <IP|CIDR>` (`cmd/security.go`) adds to the bypass list, which skips all IP/UA/country/ASN/WAF checks.
- Allow/deny precedence lives in `internal/proxy/rules.go` (`checkIP`, `checkCountry`, `checkASN`, `checkUA`) — the code is the source of truth over docs.
- ASN rules are `map[uint32]struct{}`; IP rules are `bart` prefix tables (`ipTable`).
- Login timing defense in `internal/auth/auth.go`: unknown usernames and synced node users still run `bcrypt.CompareHashAndPassword` against `loginDummyHash`.
- SQLite: main binary uses `mattn/go-sqlite3` and builds `CGO_ENABLED=1` (Dockerfile, gcc + musl-dev, static); `pdnctl` builds `CGO_ENABLED=0` for amd64/arm64 (`.github/workflows/build.yml`).
- `pdnctl` state: `/etc/podnest/install.json`, directory `0o700`, file `0o600`, written via a temp file (`cmd/pdnctl/state.go`).
- `~/.pn.env` holds `PN_SECRET_KEY`, which encrypts node-link private keys; changing or losing it means re-pairing every child node (readme).
- `bootstrap.sh` installs `pdnctl` (`curl … | sudo bash`); `build.yml` builds on `main`, `develop` and `v*.*.*` tags.
