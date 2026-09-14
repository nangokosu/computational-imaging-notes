# CSC2529 Computational Imaging — Study Notes Project

## Purpose

This project generates running study notes for CSC2529 (Computational Imaging), one file per lecture week, plus a cumulative glossary. It exists to help the user learn the field from the ground up over the course of the term — not to solve homework.

## Who these notes are for

The user is a **complete beginner** to computational imaging with no prior background in the field. Every explanation should assume nothing beyond general math/programming literacy:

- Define every piece of jargon the first time it's used — never assume a term is "obviously" known, even ones that feel basic to the field (e.g. "aperture," "spatial frequency," "convolution").
- Assume **zero prior knowledge of cameras or photography specifically**, not just of computational imaging as a research field. Ordinary camera vocabulary (aperture, image sensor, Bayer/color filter array, dpi, exposure, f-stop, etc.) needs the same from-scratch treatment as any other jargon — don't lean on "camera" as an assumed-familiar analogy for explaining the eye; explain the camera side too.
- **Definitions belong inline, in the reading flow, not only in the glossary.** The glossary (`glossary.md` / the artifact's "Reference" section) is a lookup-speed index for later, not the primary place a term gets explained — a reader should never have to stop and jump elsewhere just to understand the sentence they're on. Weave the one- or two-sentence definition into the paragraph or table cell where the term first appears; the glossary entry can then be a shorter echo of that same definition.
- Prefer plain-language analogies before formal definitions, then give the formal definition.
- When a formula appears, show the derivation intuition, not just the result — a beginner should be able to see *why* the formula has that shape, not just memorize it.
- Explicitly cross-reference where a concept reappears or gets formalized in a later week — this course builds concepts cumulatively, and notes should make those threads visible.
- **Go deeper on any concept a homework assignment actually depends on — don't stop at a high-level pass.** If a concept is load-bearing for an assignment (e.g. the Contrast Sensitivity Function for HW1's hybrid-images task), build the explanation up from first principles rather than stating the result and moving on: disambiguate any overloaded terminology explicitly and every time it recurs (e.g. "spatial frequency" vs. the temporal frequency of a flickering signal vs. the frequency/wavelength of light itself — say in-line which one is meant, don't assume it's obvious from context), and walk through at least one concrete worked numeric example before generalizing to the abstract case. Don't assume a term introduced earlier in the same lecture is fully internalized just because it's cross-referenced — briefly restate it in the new context rather than only pointing back at it.
- **Illustrate geometric or spatial ideas with a diagram, proactively.** Angles, ray paths, triangles, top-down comparisons, frequency-domain composition, anything where the geometry itself carries the meaning — don't rely on prose alone to carry a spatial idea. If an explanation would be confusing or hard to picture from text, it needs a diagram; add one without waiting to be asked. (See "Published artifact" below for how these are built.)

## Source material

- Course site: https://www.cs.toronto.edu/~lindell/teaching/2529/ (syllabus, lecture slides under `/slides/`, readings under `/reading/`)
- Lecture PDFs are large slide decks with sparse embedded text — extract with a local PDF library (e.g. PyMuPDF/`fitz` in Python) rather than assuming the text layer alone is enough, and render key diagram/formula slides to images to verify exact numbers, labels, and figures before writing them into notes. `pdftoppm`/poppler may not be installed on this machine — a local Python extraction script is an acceptable workaround.
- Always ignore course-logistics slides (schedule, grading, staff, policies) — notes start from the first technical content slide of each lecture.

## What never goes in these notes

**Never solve homework problems directly.** It's fine — expected — to explain the underlying concepts a homework assignment depends on (e.g. what the contrast sensitivity function is, how hybrid images work conceptually), but never compute the specific numeric answers a homework asks the student to derive themselves (filter cutoff frequencies, pinhole diameters, print-size calculations, etc.). When a concept is homework-adjacent, say so explicitly and note that the specific calculation is left to the assignment.

## File structure

- `CLAUDE.md` — this file.
- `weekN-study-notes.md` — one file per lecture week, following the structure established in `week1-study-notes.md`: numbered sections mirroring the lecture's own slide order, tables for structured comparisons, worked examples in their own callout-style blocks, and a "Part A" that ends with a pointer to the shared glossary rather than repeating it.
- `glossary.md` — the single, cumulative, beginner-facing glossary, grouped by the course week each term is actually covered (not flat A–Z). Update this file every time a new week's notes are written: promote that week's terms out of any "forward-looking preview," and add genuinely new forward-looking terms for weeks further out if the new lecture introduces them. Never delete an existing entry — later weeks may deepen a definition, but the original beginner-level anchor stays.

## Published artifact — one running notebook, not one per week

There is a single Claude Artifact for the whole course, updated in place every time a new week is added (never create a second artifact for a new week):

- **URL:** https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0
- **Title:** "Optics, Sensing, Computation"

It's a single HTML page with one `<section class="week-block" id="week-N" data-week-number="N" data-week-title="...">` per lecture week (currently just `week-1`), each containing that week's own numbered subsections and ending in its own `.selfcheck` block, followed by a persistent `<section id="glossary">` holding one `.week-card` per syllabus week. A small script reads whatever `.week-block` and `.week-card` elements exist and builds the sidebar/mobile navigation and the "N of 10 lecture weeks logged" progress indicator automatically — adding a week means adding a new `.week-block` (and a matching glossary card if one doesn't already exist as a forward-looking preview); the nav and progress bar update themselves.

**Diagrams live only in the artifact, not in the markdown files.** Any geometric or quantitative concept worth illustrating (ray diagrams, angle/trig diagrams, frequency-domain diagrams, etc.) gets an original inline SVG `<figure class="chart-fig">` in the HTML, styled with the existing CSS custom properties (`var(--accent)`, `var(--accent-2)`, `var(--accent-3)`, `var(--border)`, `var(--ink-faint)`, the `.chart-label` class) so it stays theme-aware — never a screenshot of the actual lecture slide. Figure captions are numbered "Fig. N" sequentially in document order across the whole page (not per week), so inserting a new figure ahead of existing ones means renumbering the ones after it. The `weekN-study-notes.md` files stay plain text/tables only, matching the pattern already set by Week 1 (whose CSF and cone-sensitivity charts likewise exist only in the artifact).

## When asked to add a new week

1. Fetch/read that week's lecture slides and any linked readings the same way Week 1 was researched (see "Source material" above).
2. Write `weekN-study-notes.md` following the Week 1 structure and tone.
3. Update `glossary.md`: move that week's terms into a dated `## Week N` section, keep the beginner-level one-sentence-plus-cross-reference format.
4. Update the running artifact (URL above) by reading it first (`action: "read"`), then republishing with `url` set to that same address: append a new `.week-block` after the previous one (before the `<hr class="div"/>` that precedes `#glossary`), and refresh the matching `#glossary` `.week-card` so it reflects what was actually covered rather than a forward-looking guess. Reuse the established visual language exactly (Source Serif 4 / Public Sans / IBM Plex Mono, the warm-amber-on-indigo-slate palette, inline SVG charts for anything genuinely quantitative) — don't redesign per week. Keep the JS's coding standard (JSDoc per function, fully descriptive names, no unexplained hardcoded numbers) when touching the nav-building script. Load the `artifact-design` skill before touching the HTML.
