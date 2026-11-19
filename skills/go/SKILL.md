---
name: go
description: Kevin's Go coding standards — file headers, godoc comments, package layout, logging conventions, security patterns. Use when writing or editing any Go code.
---

# Kevin's Go Standards

Reference implementations: kpirnie/podnest (current standard),
kpirnie/kptv-proxy, kpirnie/m3u-scanner.

## File conventions
- File header (podnest standard, before the package clause):

      // PodNest - Self-hosted site management platform
      // Copyright (c) 2026 Kevin Pirnie <iam@kevinpirnie.com>
      // Licensed under the MIT License. See LICENSE file in the project root for full license text.

  kptv-proxy and m3u-scanner have no header block (some kptv-proxy files
  open with a path comment like `// work/db/streamorder.go`) — match the repo
- Godoc comment on every exported type, func and method, starting with the
  identifier name
- Inside function bodies, podnest carries a short comment above each logical
  step (`// the main entry point of the app`, `// Ensure the parent directory
  exists`) — match the density of the file being edited. In new code, don't
  add verbose comments on constants or types, or inline comments inside
  function bodies, unless the code is not obvious; when one is needed it
  explains the why (security rationale, format constraints), not the what
- gofmt-clean always
- Imports (podnest): stdlib, blank line, module-local, blank line,
  third-party. kptv-proxy mixes groups in many files — match the file

## Package layout
- podnest (current): `internal/<domain>` packages, `cmd/<name>` for extra
  binaries (`cmd/pdnctl`), `internal/server` with `handler_*.go` /
  `middleware_*.go`, per-area API handlers in `internal/handlers/<area>/`,
  pluggable site types and features in `internal/modules/`
- kptv-proxy: `work/<domain>` packages (match it when editing that repo)
- m3u-scanner: `internal/<domain>`
- Small focused packages: db access, logger, config, models separated

## Logging
- The project's own internal logger package (`logger.Debug/Info/Warn/Error`),
  printf-style formatting; m3u-scanner uses stdlib `log.Printf("[component] ...")`
- kptv-proxy prefix: `"{package/file - FuncName} message: %v"`; podnest prefix:
  `"context: message: %v"` — match the repo
- Log the error at the failure site, then return it; callers don't double-log

## Patterns
- Background workers: goroutine with `time.NewTicker` + `defer ticker.Stop()`,
  running an initial pass before the loop when freshness matters
- Shared read-mostly state (podnest proxy caches, rule sets, WAF engines) is
  held in `atomic.Pointer` fields, rebuilt as a complete new structure, then
  swapped with `.Store()` — never mutated in place under readers
- SQLite persistence; prepared/parameterized queries always
- Explicit error handling; no panics in server paths; wrap errors with context
  via `fmt.Errorf("...: %w", err)`

## Security posture
- Timing-oracle-aware auth: unknown users still run a bcrypt compare against
  a dummy hash of matching cost (podnest `internal/auth/auth.go`)
- bcrypt (podnest) or Argon2id (kptv-proxy) for credentials, never homemade
- Validate and bound all user-supplied input at the handler edge
- New security-relevant code gets a why-comment documenting the threat it
  addresses

## Build/deploy
- Docker-first: `Dockerfile` plus a compose example (podnest
  `docker-compose-example.yaml`, kptv-proxy `docker-compose.example.yaml`,
  m3u-scanner `docker-composer-example.yaml`)
- CGO awareness matters: podnest main uses `mattn/go-sqlite3` and builds
  `CGO_ENABLED=1`; podnest's `pdnctl` builds `CGO_ENABLED=0`; kptv-proxy and
  m3u-scanner use `ncruces/go-sqlite3` (CGO-free) and build `CGO_ENABLED=0`
  — never swap sqlite drivers between them

## Rules
- Minimal diffs; match the repo's existing patterns over generic
  "best practice"; no dependency additions without asking
