---
name: webscanner
description: KP WebScanner — single Docker image bundling 22 web security tools (nuclei, nmap, ZAP, sqlmap, testssl, WPScan, ...) orchestrated by one bash entrypoint that writes a UIkit report.html. Read before any work in kpirnie/webscanner.
---

# KP WebScanner

Self-contained security scanning image: passive recon (Shodan, Censys), fingerprinting (httpx, WhatWeb), subdomains/DNS (subfinder, dnsx), ports (naabu, nmap), SSL (testssl.sh), headers (Mozilla Observatory), discovery (katana, gobuster, ffuf, Arjun), injection/XSS (sqlmap, Dalfox), dependencies (OSV-Scanner), vulns (nuclei, Nikto), WordPress (WPScan, auto-triggered), nginx bad-bot-blocker validation, and OWASP ZAP. Results compiled into one `report.html`. Published to `ghcr.io/kpirnie/webscanner` (`latest`, `develop`, `v#.#.#`). Repo: `kpirnie/webscanner`. No language skill — bash + Dockerfile.

## Stack
- `Dockerfile`: stage 1 `golang:1.26-bookworm` (`CGO_ENABLED=1`, libpcap) `go install …@latest` for the ProjectDiscovery tools, ffuf, gobuster, dalfox, osv-scanner; stage 2 `debian:bookworm-slim` with nmap, Ruby (WPScan), Perl (Nikto), Python (Arjun, shodan, censys), Node LTS (Observatory), Java (ZAP, `JAVA_OPTS=-Xmx512m`), git-cloned WhatWeb/sqlmap/Nikto/testssl, baked nuclei templates, SecLists `big.txt`
- All tools install at their latest versions at image build time (readme)
- Runtime env: `WPSCAN_API_TOKEN`, `SHODAN_API_KEY`, `CENSYS_APP_ID`, `CENSYS_TOKEN` (all optional)
- Run: `--network host --cap-add NET_ADMIN --cap-add NET_RAW`, output volume `/output`

## Map
- `scan.sh` (~1,400 lines) — the whole tool:
  - header with `VER` (reference only), colour helpers `info`/`ok`/`warn`/`section`, `usage`
  - argument parsing: `<target-uri>`, `-o PATH`, `--severity` (default `low,medium,high,critical`), 19 `--skip-*` flags (`fingerprint`, `recon`, `subdomains`, `dns`, `ports`, `nmap`, `ssl`, `headers`, `nikto`, `cms`, `crawl`, `brute`, `arjun`, `xss`, `sqlmap`, `osv`, `nuclei`, `botblocker`, `zap`), `--bot-sample N` (default 50)
  - one block per stage in run order, each writing into `${OUT_DIR}`
  - report builder: `file_content()` / `json_content()` HTML-escape each tool's output (or print `(no output)` when the file is empty/missing) into `${OUT_DIR}/report.html` (UIkit), embedding `zap_report.html` when present
- `.github/workflows/` — build & push to GHCR on `main`, `develop`, `v*.*.*` tags and manual dispatch

## Conventions
- Bash with `set -euo pipefail`; section banners as `# ----` / `# ====` comment rules; status output via `info`/`ok`/`warn`/`section`
- Stages are toggled with `--skip-*` flags, some covering more than one tool (`--skip-brute` = gobuster + ffuf, `--skip-recon` = Shodan + Censys, `--skip-cms` = CMS detection + WPScan)

## Behaviour in the code
- Skipped stages log `warn "<Stage> skipped (--skip-…)"`; many tool invocations end in `|| true` (53 occurrences) so a failing tool does not stop the run under `set -euo pipefail`
- Shodan runs only when `SHODAN_API_KEY` is set, Censys only when `CENSYS_APP_ID` and `CENSYS_TOKEN` are set; otherwise a `warn` names the missing key
- The readme carries the warning: only scan targets you own or have explicit written permission to test
