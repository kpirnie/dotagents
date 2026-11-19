---
name: "updates-completed"
description: "Write a WordPress site updates completed report from Kevin's raw notes. Use when Kevin pastes a site name with \"updates completed\" (or \"updates run\"), plus the same Notes and Updates Needed lists used for an updates audit."
---

# Updates Completed

## Rules
- Report only what the notes state. Assume nothing: no inferred causes, risks, recommendations, or priorities.
- Only list items that were updated. An item counts as updated only if it has a true version change: `x.x.x -> x.x.x`.
- Items with `x.x.x -> ?` are not updated. Omit them entirely.
- Items with only a current version and no target version are not updated. Omit them entirely.
- Do not list, count, or mention omitted items anywhere in the report.
- If Kevin sends a list of plugins to not include in the updated list, omit those plugins entirely, even if they have a true version change. in the original audit reported.
- Deactivated items with a true version change are included.
- Render the report directly in chat as formatted bullets. No tables, no doc artifact, no code block, no file.
- No summary section. No notes or observations section, unless Kevin states to include.
- No commentary before or after the report. End with one line: "Ready for the next site."
- Keep plugin, theme, and add-on names exactly as given.
- Every updated plugin appears exactly once.

## Format
Title: `# Updates Completed: <domain>`, followed by `**Date:** <current date, e.g. October 21, 2026>`.

Single section: `## Updates Run`.

Subsections, in this order. Omit any subsection with no updated items.
1. `### Core`
2. `### Themes`
3. `### Plugins`

- Item format everywhere: `* Name: old -> new` (e.g. `* Plugin Name: 1.2.3 -> 1.2.4`). Keep the `->` exactly as written.

### Plugins
- One flat list of every updated plugin. Do not split into any groups.
- Keep the order given in the notes.
