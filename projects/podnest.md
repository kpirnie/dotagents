---
name: podnest
description: PodNest project map and hard rules — self-hosted site management platform with built-in reverse proxy (Coraza WAF), Podman orchestration, and pdnctl host manager. Use for any work in this repo.
---

# PodNest

Follow the global Go skill for style. This file covers the project map and project-specific rules.

## Map

- `main.go` → `internal/server` (`routes.go`, `handler_*.go`, `middleware_*.go`, `background.go` workers, `statscache`)
- `internal/proxy`: reverse proxy, organized by concern (`basicauth`, `caches`, `certs`, `domains`, `geoip`, `redirects`, `rules`, WAF via Coraza + OWASP CRS auto-update, `trustedproxies`, `upstream`, `sitelogs`)
- `internal/podman`: container orchestration (`adapter`, `pod`, `registry`, `containers`, `features`, `platform`)
- Other `internal/` areas: `auth`, `db`, `models`, `modules`, `backup`, `cron`, `sftp`, `fileops`, `notifications` (SNS), `audit`, `apiutil`, `logger`, `config`, `version`
- `cmd/pdnctl`: host-side manager binary; `CGO_ENABLED=0`; root-only; state at `/etc/podnest/install.json` (directory mode `0700`, file mode `0600`)
- Web templates and static assets are built via esbuild/PostCSS; `web/apidocs/` holds the OpenAPI spec.
- Fail2ban ships jail/filter configs.

## Full-stack change checklist

A configuration or security feature may require updates across:
- DB schema
- Loader / `Warm*Cache`
- Handlers
- Middleware, where applicable
- Web UI (UIkit)
- OpenAPI spec (`web/apidocs/`)
- README / documentation
- `pdnctl`, if host-level

State the layers to be touched before coding. Never leave the OpenAPI spec or docs stale.

## Hard rules

- Lockout-prevention preflight before applying security rules is sacred; its contract returns HTTP 200. Recovery command: `podnest security --bypass <CIDR>`. Never break either.
- Whitelist/blacklist precedence: trust code, not docs; docs have been wrong before. Verify in `internal/proxy/rules.go`.
- ASN blocking uses map-based O(1) lookup; preserve this property.
- Timing-oracle authentication defenses (dummy bcrypt comparison, matched cost) must not be simplified away.
- `pdnctl` state permissions `0700`/`0600` are load-bearing.
- Never edit `bootstrap.sh` install flow or the release workflow without explicit request.
