# CSC2529 Computational Imaging — Study Notes Project

## Purpose

This project produces running study notes for CSC2529 (Computational Imaging): one markdown file per lecture week plus a cumulative glossary, to help the user learn the field from scratch over the term — not to solve homework.

## Who these notes are for

The user is a complete beginner to computational imaging and to cameras/photography specifically — assume nothing beyond general math/programming literacy.

- Define every term on first use, including ordinary camera vocabulary (aperture, image sensor, Bayer/color filter array, dpi, exposure, f-stop, etc.) — don't treat "camera" as an assumed-familiar analogy when explaining the eye; give the camera side the same from-scratch treatment.
- Put definitions inline where a term first appears, not only in the glossary — a reader should never have to jump elsewhere to follow the current sentence. The glossary is a lookup-speed index; its entry can be a shorter echo of the inline definition.
- Give a plain-language analogy before the formal definition.
- For every critical formula, follow the equation checklist below (see "Equations").
- Cross-reference where a concept reappears or gets formalized in a later week.
- Go deeper on concepts a homework assignment actually depends on (e.g. the Contrast Sensitivity Function for HW1's hybrid-images task), even if the lecture itself only mentions them in passing: build from first principles, disambiguate overloaded terms explicitly every time they recur (e.g. spatial frequency vs. the temporal frequency of a flickering signal vs. the frequency/wavelength of light — state in-line which is meant), and work through at least one concrete numeric example before generalizing. Briefly restate earlier-lecture terms in their new context rather than only pointing back at them.
- **When a subsection introduces a stricter sub-term for a word already used loosely elsewhere** (e.g. "image frequency," cycles/pixel, as a precise sub-flavor of the broader "spatial frequency" umbrella), audit every other place that word is used in that same technical context — earlier sections and later ones, both files, and the artifact, not just the subsection being written — and either switch each use to the precise term or leave a short note explaining why the looser term is still correct there. Overloading can drift back in anywhere the word is reused later, not just at first introduction, so it needs the same audit each time.
- Illustrate geometric/spatial ideas (ray paths, angles, top-down comparisons, frequency-domain composition, etc.) with a diagram proactively, whenever prose alone would be hard to picture — see "Published artifact" below for how these are built.
- Avoid dense, unbroken blocks of text — a long paragraph signals a concept needs restructuring, not just tighter prose. Split multi-idea paragraphs at idea boundaries, pull worked examples/asides into their own callout blocks, use lists for enumerations, and add a diagram wherever one would carry weight prose is carrying alone. This matters most in first-principles sections (see the homework-depth rule above), where density accumulates fastest.
- No historical asides — skip the history of a technique, instrument, or field, and skip biographical background on the people behind a name (e.g. who a transform or law is named after, or when/why it was discovered). A person's or paper's name appears only when that's how the concept is actually referred to in the course, not as a launching point for history.
- The user is specifically interested in LiDAR and has little prior background in it. Any chapter or concept that is even remotely relevant to LiDAR (time-of-flight sensing, structured light, active illumination, depth sensing, point clouds, range imaging, pulsed/continuous-wave ranging, etc.) gets extensive elaboration beyond the notes' normal depth — treat it the same way the homework-depth rule treats HW-critical concepts: build from first principles, work through concrete numeric examples, and don't just gesture at it in passing even if the lecture itself only mentions it briefly.

## Equations

Every critical formula behind a key concept must be fully explained, never just stated. Cover all three, in this order:

1. **Intuition** — why the formula takes that specific shape, walked through step by step, not just asserted as a result.
2. **Term-by-term breakdown** — what each component/variable stands for: what it physically means, its units, and whether it's something the reader controls or something fixed by the setup.
3. **Diagram, if geometric** — when the formula is geometric (see the illustration rule above), add a diagram built to the construction rules in "Published artifact" below, showing exactly the quantities the formula relates so it visibly corresponds to the derivation — the reader should be able to point at a line in the figure for every symbol in the formula.

## Source material

- Course site: https://www.cs.toronto.edu/~lindell/teaching/2529/ (slides under `/slides/`, readings under `/reading/`).
- Lecture PDFs are large slide decks with sparse embedded text — extract with a local PDF library (e.g. PyMuPDF/`fitz`), and render key diagram/formula slides to images to verify exact numbers, labels, and figures before writing them into notes. If `pdftoppm`/poppler isn't installed, a local Python extraction script is an acceptable workaround.
- Skip course-logistics slides (schedule, grading, staff, policies) — notes start from the first technical content slide of each lecture.

## What never goes in these notes

Never compute the specific numeric answers a homework asks the student to derive themselves (filter cutoff frequencies, pinhole diameters, print-size calculations, etc.) — but do explain the underlying concepts a homework depends on (e.g. what the CSF is, how hybrid images work conceptually), explicitly flagging that the specific calculation is left to the assignment.

## File structure

- `CLAUDE.md` — this file.
- `README.md` — the project's public face: one-paragraph summary, link to the running artifact, and a table listing all `weekN-study-notes.md` files and related project files with brief descriptions. Update the table every time a new week is added (new row with filename, week number, and 1-sentence content summary) and when `FACT_AUDIT.md` is first created.
- `weekN-study-notes.md` — one per lecture week, following the structure established in `week1-study-notes.md`: numbered sections mirroring the lecture's own slide order, tables for structured comparisons, worked examples in their own callout-style blocks, and a "Part A" that ends with a pointer to the shared glossary rather than repeating it.
- `glossary.md` — the single, cumulative, beginner-facing glossary, grouped by the course week each term is actually covered (not flat A–Z). Update it every time a new week's notes are written: promote that week's terms out of any "forward-looking preview," and add genuinely new forward-looking terms for weeks further out if the new lecture introduces them. Never delete an existing entry — later weeks may deepen a definition, but the original beginner-level anchor stays.
- `FACT_AUDIT.md` — created and updated when fact-checking the artifact against external sources (not on every change, but proactively before major revisions or on request). Lists every factual claim verified, with sources cited. Document its existence in the README table once it exists.
- `.claude/settings.json` — declares the Claude Code plugins/marketplaces this project's workflow uses (`superpowers`, `document-skills`), so cloning the repo and opening it in Claude Code reproduces the same setup.
- `.claude/agents/fact-auditor.md` — the custom subagent definition that runs the fact-checking pass behind `FACT_AUDIT.md`.

## Published artifact — one running notebook, not one per week

A single Claude Artifact covers the whole course, updated in place every time a new week is added (never create a second artifact for a new week):

- **URL:** https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0
- **Title:** "Optics, Sensing, Computation"

It's one HTML page with a `<section class="week-block" id="week-N" data-week-number="N" data-week-title="...">` per lecture week (currently just `week-1`), each containing that week's own numbered subsections and ending in its own `.selfcheck` block, followed by a persistent `<section id="glossary">` holding one `.week-card` per syllabus week. A script builds the sidebar/mobile nav and the "N of 10 lecture weeks logged" progress indicator from whatever `.week-block`/`.week-card` elements exist — adding a week just means adding a new `.week-block` (and a matching glossary card, if one doesn't already exist as a forward-looking preview).

Diagrams live only in the artifact, never in the markdown files, and every diagram is an original inline SVG `<figure class="chart-fig">` — never a screenshot or cropped image from the lecture slides. Draw each one hand-inspired by how the slide deck depicts the same concept (matching its layout and labels where that helps recognition), but feel free to add more annotation than the slide has — extra labels, construction lines, or callouts that make the geometry or the formula's derivation easier to follow than the source slide alone. Style every diagram with the existing CSS custom properties (`var(--accent)`, `var(--accent-2)`, `var(--accent-3)`, `var(--border)`, `var(--ink-faint)`, `.chart-label`) so it stays theme-aware. Every figure gets a caption describing what it shows plainly (no "source: lecture slides" credit line, since nothing is copied from them). Figure captions are numbered "Fig. N" sequentially in document order across the whole page (not per week), so inserting a new figure ahead of existing ones means renumbering the ones after it. The `weekN-study-notes.md` files stay plain text/tables only, matching the pattern set by Week 1.

**Hyperlinks:** every technical term, named concept, instrument, formula, or phenomenon introduced in the artifact's prose or tables is wrapped in an inline `<a href="https://en.wikipedia.org/wiki/...">` link on first mention within its section. Wikipedia is the only link target ever used — never lecture slides, other course sites, or other external references. This matches the convention already established across Week 1's content and must be followed for every week added afterward. The `weekN-study-notes.md` files carry no hyperlinks at all, per the plain-text/tables-only rule above.

## Git workflow

Every change made in this project — new week notes, glossary updates, CLAUDE.md edits, anything — must always be committed and pushed to GitHub (`origin/main`) once made. Don't leave changes sitting uncommitted or unpushed for the user to handle separately.

## When asked to add a new week

See the `add-lecture-week` skill (`.claude/skills/add-lecture-week/SKILL.md`) for the step-by-step procedure.
