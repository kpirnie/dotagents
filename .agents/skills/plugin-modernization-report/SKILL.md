---
name: "plugin-modernization-report"
description: "Write a technical security and modernization report for a WordPress plugin after a hardening pass. Use when Kevin asks for a write-up of the fixes, why they were needed, and the commit appendix."
---

# Plugin Modernization Report

Template for the report Kevin uses to justify time spent on a security and modernization pass of a WordPress plugin (typically to his CEO). It is a technical report, not a marketing piece.

## Delivery

- Render the report directly in chat, formatted. Not a doc artifact and not markdown source in a code block.
- Technical depth is wanted: name classes, functions, hooks, sanitizers and escapers. Do not water it down into executive-summary prose.
- Do NOT include: a "Prepared for" line, a Business value section, or a Verification status / remaining work section. Kevin asked for these to be left out.
- Only claim what was actually done. Verify against the code and `git log` before writing. Never invent counts, hours, severities or vulnerabilities.

## Gather first

1. Read the repo's current state (classes, wrappers, hooks, main plugin header, readme, uninstall).
2. Pull the commit history for the work: `git log --reverse --format=%s`. Take only the commits belonging to the modernization pass (not the plugin's older history). Use the subjects verbatim in Appendix A.
3. Note the back-compat contracts that were kept (DB table, option names, hooks and filters, script handles, localized JS objects, global function wrappers, legacy class names).

## Structure

Header block
- Title: `<Plugin name>: security and modernization report`
- Repository and branch
- Scope (one line: security remediation, Plugin Check compliance, structural rewrite, language and WP minimums)
- Compatibility constraint (one line listing what was preserved)

### 1. Security
Group into these subsections, include only the ones that apply, and give concrete mechanisms (function names, checks, sanitizers):
- 1.1 Request authentication and authorization: nonces, capability checks per handler, autosave/revision skips, network-activation guards, query-arg gating, safe redirects.
- 1.2 SQL: where queries live, `$wpdb->prepare` with `%i`/`%s`/`%d`, explicit columns instead of `SELECT *`, esc_like, caching and invalidation, type-validated cache reads.
- 1.3 Output escaping (XSS): late escaping per file/class, `esc_*`, `wp_kses_post`, escaped updater output, links built safely.
- 1.4 Input sanitization: settings sanitize callbacks, superglobal reads with `wp_unslash` + sanitizer + defaults, filter return normalization, ID/slug restriction.
- 1.5 Stored and rendered URLs: scheme restrictions (`esc_url_raw` with http/https) at save and output, JS DOM building.
- 1.6 Transport and deserialization: https endpoints, removed `sslverify => false`, `unserialize` with `allowed_classes => false`.
For each item say what was wrong before, what it does now. One or two lines each.

### 2. Correctness bugs fixed
Bullet list of functional bugs found along the way (swapped defaults, wrong validity logic, enqueue/localize ordering, by-reference misuse, null/false indexing, mixed-content, malformed URLs, broken translatable strings, broken links, list-table markup).

### 3. Compliance and modernization
- Requirements declared (WP min, PHP min, Tested up to, header fields).
- Language level (strict_types, mixed hook params, match, nullsafe, typed methods).
- Structure (namespace, autoloader, class list, singleton boot, merged duplicate classes with `class_alias`, wrappers that register no hooks).
- Text domain rename and translation files.
- Installer, uninstall behavior (including multisite and cache keys).
- Asset and file cleanup (removed unused files, Plugin Check filename flags).
- Coding standards config (`phpcs.xml` changes).
- Hook and loading cleanup (screen-gated admin assets, filters registered by classes).

### Appendix A: commit messages
- Numbered list of the modernization commits, verbatim subjects, in order.
- If a commit subject contains extra text (for example two messages joined by a semicolon), add a one-line note after the list.

## Style

- Direct, no filler, ordered by importance within each section.
- Use tables only where before/after comparison genuinely helps; otherwise bullets.
- No line numbers. Reference files by path and code by function/class name.
- If a limitation or flag matters (for example a legacy behavior kept on purpose), state it in one line in the relevant section.