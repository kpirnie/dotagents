---
name: updates-audit
description: Write a WordPress site updates audit report from Kevin's raw notes. Use when Kevin pastes a site name with "updates audit", Notes, and Updates Needed lists (core, themes, plugins, versions, license status).
---

# Updates Audit

## Rules
- Report only what the notes state. Assume nothing: no inferred causes, risks, recommendations, or priorities.
- Do not add, drop, or reword findings beyond cleaning up grammar and capitalization (e.g. "WordPress", "WooCommerce").
- Render the report directly in chat as formatted bullets. No tables, no doc artifact, no code block, no file.
- No commentary before or after the report. End with one line: "Ready for the next site."
- Keep plugin, theme, and add-on names exactly as given.
- Keep items in the order given within each group.
- Every plugin appears in exactly one Findings group.

## Format
Title: `# Updates Audit Report: <domain>`, followed by `**Date:** <current date, e.g. October 21, 2026>`.

Sections, in this order: `## Summary`, `## Site Observations`, `## Findings`.

### Summary
Bullets, in this order. Count from the notes only and double-check the math.
- **Core:** update available (old → new)
- **Themes:** update(s) available (name old → new)
- **Plugins:** N installed; X have updates listed, Y have none listed
- **Purchased plugins:** N total, with sub-bullets: unlicensed on live, license status not determined (with reason if stated), confirmed licensed
- **Deactivated plugins:** count, with names in parentheses (omit the bullet if none)
- **Security scan:** the scan note, cleaned up (omit if no scan note)

### Site Observations
- One bullet per note that is not the scan result (child theme, modified version, no child theme, etc.), cleaned up only.
- If there are none, write "None noted".

### Findings
Subsections, in this order:
1. `### Core`
2. `### Themes`
3. `### Plugins: Purchased`
4. `### Plugins: Updates Available`
5. `### Plugins: No Update Listed`

- Version format: `**Name:** old → new`. If the new version is "?", keep it as `→ ?`.
- Items with no new version listed: `**Name:** 1.2.2`. Inside Purchased, append "(no update listed)".
- Status details (deactivated, requires X) go as sub-bullets under the item.
- Purchased themes: list under Themes, with `Source:` sub-bullet for the link.

### Plugins: Purchased
- A plugin is "purchased" only if the notes say so (license mention, purchase link, etc.). Never infer it from the name or vendor.
- Order within the group: licensed on live, then unlicensed on live, then license status not determined.
- Each item gets sub-bullets:
  - `License on live: Licensed | Unlicensed | Not determined` (add the stated reason in parentheses, e.g. "WooCommerce account not connected")
  - `Source: <link>`
- Expired licenses are reported as stated: `License on live: Expired`.
- Purchased plugins appear only here, not in the other plugin groups.
- If there are no purchased plugins, write "None noted".

### Plugins: Updates Available
- Non-purchased plugins with an old → new version, including deactivated ones (keep their sub-bullets).

### Plugins: No Update Listed
- Non-purchased plugins with only a current version. Keep status sub-bullets (e.g. Deactivated, Requires X).