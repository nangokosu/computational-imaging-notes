---
name: add-lecture-week
description: Use when asked to add a new CSC2529 lecture week to this project (new weekN-study-notes.md, glossary.md update, and running artifact update). Triggers on requests like "add week N notes" or "write up lecture N".
---

# Adding a new lecture week

Follow this sequence — see the project's root `CLAUDE.md` for the audience rules, equation checklist, source-material conventions, and published-artifact/hyperlink conventions referenced below; they still apply here and are not repeated in this file.

1. Fetch/read that week's lecture slides and any linked readings the same way Week 1 was researched (see "Source material" in `CLAUDE.md`).
2. Write `weekN-study-notes.md` following the Week 1 structure and tone, arrived at through this sequence rather than by drafting prose directly off the slides:
   a. **Identify all concepts the lecture actually depends on**, prioritizing anything a current or upcoming homework leans on for the deepest treatment (see the homework-depth rule in `CLAUDE.md`), even if the lecture itself only mentions them in passing.
   b. **Identify the underlying math each concept assumes**, without assuming familiarity — a formula, transform, or notation needs its own from-scratch treatment, not just a citation.
   c. **Map the ground-up relationships between concepts** — prerequisite, formalizes, builds-on — before writing a single sentence of exposition. This ordering, not the lecture's slide order, determines whether a concept needs its own section and where it sits relative to the others.
   d. **Only then write the narrative flow**, still bottom-up for a complete beginner: each concept introduced only after what it depends on, with the connective tissue between concepts made explicit.
3. Update `glossary.md`: move that week's terms into a dated `## Week N` section, keeping the beginner-level one-sentence-plus-cross-reference format.
4. Update the running artifact (URL in `CLAUDE.md`'s "Published artifact" section) by reading it first (`action: "read"`), then republishing with `url` set to that same address: append a new `.week-block` after the previous one (before the `<hr class="div"/>` that precedes `#glossary`), and refresh the matching `#glossary` `.week-card` so it reflects what was actually covered rather than a forward-looking guess. Reuse the established visual language exactly (Source Serif 4 / Public Sans / IBM Plex Mono, the warm-amber-on-indigo-slate palette) and diagram conventions (see "Published artifact" in `CLAUDE.md`) — don't redesign per week. Wikipedia-link every newly introduced term the same way as Week 1 (see "Hyperlinks" in `CLAUDE.md`). Keep the nav script's coding standard (JSDoc per function, fully descriptive names, no unexplained hardcoded numbers). Load the `artifact-design` skill before touching the HTML.
