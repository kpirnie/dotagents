---
name: go
description: Kevin's Go coding standards — file headers, godoc comments,
  package layout, logging conventions, security patterns. Use when
  writing or editing any Go code.
---

# Kevin's Go Standards

Reference implementations: kpirnie/podnest (current standard),
kpirnie/kptv-proxy.

## File conventions
- File header comment block: project name + one-line description,
  copyright (c) <year> Kevin Pirnie, license reference — before the
  package clause (see any podnest file)
- Proper godoc comments on EVERY exported type, func, method, and
  significant unexported ones: start with the identifier name, full
  sentences. This is the formal register — NOT the conversational
  lowercase voice used in Kevin's PHP/Python.
- Inline comments explain the why for non-obvious logic (e.g. security
  rationale, cost/format constraints), not the what
- gofmt-clean always; standard import grouping: stdlib, blank line,
  module-local, blank line, third-party

## Package layout
- podnest style (current): internal/<domain> packages, cmd/<name> for
  additional binaries, handler_*.go / middleware_*.go file naming
  within the server package
- kptv-proxy style: work/<domain> packages (match it when editing
  that repo)
- Small focused packages: db access, logger, config, models separated

## Logging
- The project's own internal logger package (logger.Debug/Info/Warn/
  Error), printf-style formatting
- kptv-proxy message prefix convention: "{package - FuncName} key=val: %v"
  — match it there; podnest uses "context: message: %v" prefixes
- Log the error at the failure site, then return it; callers don't
  double-log

## Patterns
- Background workers: goroutine with time.NewTicker + defer ticker.Stop,
  running an initial pass before the loop when freshness matters
- In-memory caches loaded from DB with Warm*Cache funcs that build a
  complete new structure and atomically replace the old (no in-place
  mutation under readers)
- SQLite persistence; prepared/parameterized queries always
- Explicit error handling; no panics in server paths; errors wrapped
  with context via fmt.Errorf("...: %w", err)

## Security posture
- Constant-time / timing-oracle-aware auth comparisons (dummy bcrypt
  compare for unknown users; cost must match real hashes)
- bcrypt (or argon2 in kptv-proxy) for credentials, never homemade
- Validate and bound all user-supplied input at the handler edge
- New security-relevant code gets a why-comment documenting the threat
  it addresses

## Build/deploy
- Docker-first: Dockerfile + docker-compose-example.yaml
- CGO awareness matters: podnest's pdnctl builds CGO_ENABLED=0;
  kptv-proxy uses ncruces/go-sqlite3 (CGO-free) while podnest main
  uses mattn/go-sqlite3 (CGO) — never swap sqlite drivers between them

## Rules
- Minimal diffs; match the repo's existing patterns over generic
  "best practice"; no dependency additions without asking