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
- Purchased items are included whether licensed or not, since they may be updated manually instead of by the automated WP process.
- Deactivated items with a true version change are included, with their stated status as sub-bullets.
- Do not add, drop, or reword findings beyond cleaning up grammar and capitalization (e.g. "WordPress", "WooCommerce").
- Render the report directly in chat as formatted bullets. No tables, no doc artifact, no code block, no file.
- No summary section. No notes or observations section.
- No commentary before or after the report. End with one line: "Ready for the next site."
- Keep plugin, theme, and add-on names exactly as given.
- Keep items in the order given within each group.
- Every updated plugin appears in exactly one group.

## Format
Title: `# Updates Completed: <domain>`, followed by `**Date:** <current date, e.g. October 21, 2026>`.

Single section: `## Updates Run`.

Subsections, in this order. Omit any subsection with no updated items.
1. `### Core`
2. `### Themes`
3. `### Plugins: Purchased`
4. `### Plugins: Other`

- Version format: `**Name:** old → new`. Convert `->` to `→`.
- Stated status details (deactivated, requires X) go as sub-bullets under the item.
- Purchased themes: list under Themes, with a `Source:` sub-bullet for the link.

### Plugins: Purchased
- A plugin is "purchased" only if the notes say so (license mention, purchase link, etc.). Never infer it from the name or vendor.
- Order within the group: licensed on live, then unlicensed/expired on live, then license status not determined.
- Each item gets sub-bullets:
  - `License on live: Licensed | Unlicensed | Expired | Not determined` (add the stated reason in parentheses, e.g. "WooCommerce account not connected")
  - `Source: <link>` (only if a link is given in the notes)
- Purchased plugins appear only here, not in Plugins: Other.

### Plugins: Other
- Non-purchased plugins with a true old → new version, including deactivated ones (keep their status sub-bullets).