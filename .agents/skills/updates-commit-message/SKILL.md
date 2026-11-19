---
name: "updates-commit-message"
description: "Write a git commit message for a WordPress site updates run from Kevin's notes, listing every update, reinstall and install, sectioned by type like the updates-completed report. Use when Kevin asks for a commit message for updates."
---

# Updates Commit Message

## Rules
- Source is the same raw notes used for updates audit / updates completed (Notes, Core, Themes, Plugins lists), or the updates-completed report already produced in the chat.
- List EVERY item that was updated, reinstalled, or installed. Never leave any out.
- Updated = a true version change (old -> new). Items with `-> ?` or no target version are not updated, unless the notes say they were installed or reinstalled (e.g. "Reinstalled WP Migrate: 2.7.12"); those are included.
- Installs and reinstalls go in the SAME commit message as the updates, never a separate one.
- Use the new version only, not old -> new.
- Keep plugin, theme, and add-on names exactly as given. Short-form names only if Kevin has already accepted one in the chat.
- Keep items in the order given within each section.
- Every item appears in exactly one section.
- Purchased and non-purchased plugins go together in one Plugins section; license status does not matter, only that the item is listed.
- Output only the commit message in a single code block. No commentary before or after, no explanations, no summary.
- No Co-Authored-By or other attribution lines.
- Do not commit or push anything.

## Format
First line (subject): `Update WordPress core, plugins` (add `themes` if themes were updated; add `install <name>` only when it fits naturally).

Blank line, then sections separated by a blank line. Each section is a plain-text heading line followed by one item per line, each starting with `- `. Sections, in this order; omit any section with no items:
1. `Core`: `- WordPress <new>`
2. `Installs`: `- <name> <version>`
3. `Reinstalls`: `- <name> <version>`
4. `Themes`: `- <name> <new>`
5. `Plugins`: `- <name> <new>`

Installs and reinstalls sit right after core, since the notes state them as work done on top of the update run. The section heading carries the action, so item lines are just name and version with no Update/Install/Reinstall verb.

## Example
```
Update WordPress core, plugins

Core
- WordPress 7.1.4

Reinstalls
- WP Migrate 2.7.12

Plugins
- AffiliateWP 2.37.5
- AffiliateWP - Custom Affiliate Slugs 1.3.1
- Yoast SEO 28.8
```

End with one line: "Ready for the next site." only if Kevin is working through multiple sites; otherwise nothing.
