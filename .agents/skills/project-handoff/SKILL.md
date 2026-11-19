---
name: "project-handoff"
description: "This is to be utilized as a project handoff. Generally utilized by Opus models to generate a workable \"project\" for Sonnet"
---

We have completed our planning and Q&A phase. I am going to freeze this architectural design and hand it off to Claude Sonnet 5.5 in a brand-new chat session to execute the coding work. 

I will be providing you with direct access to my actual codebase (via Git/folder/zip), so DO NOT dump large blocks of source code into this file. Instead, focus entirely on mapping the context.

Please compile our discussion into a highly detailed, standalone, downloadable Markdown (.md) specification file with these exact sections:

1. EXECUTIVE SUMMARY & OBJECTIVE
- A concise, 2-3 sentence overview of what we are building, its core purpose, and the end-user goal.

2. ARCHITECTURE & TECH STACK
- Explicitly list the languages, frameworks, libraries, and exact versions agreed upon. These should never be construed as the end-all-be-all as we may upgrade them.

3. HARD CONSTRAINTS & "GROUND TRUTH" RULES
- Bulleted list of non-negotiable coding standards established in our chat (e.g., error handling patterns, naming conventions, performance thresholds, security constraints).
- A strict rule forbidding the use of code placeholders (e.g., "// TODO: implement later").
- If you have a skill matching this, mention that it needs to be loaded as well.

4. PRIORITIZED EXECUTION BLUEPRINT
- A highly granular, step-by-step sequential checklist of exactly what tasks Sonnet 5.5 needs to execute.
- Group these logically by imoprtance
- Highlight potential edge cases or tricky logical traps we identified that you must actively guard against.

Please package this entirely inside a downloadable .md file. Do not include conversational filler before or after the file generation.
