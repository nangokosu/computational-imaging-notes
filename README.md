# CSC2529 Computational Imaging — Study Notes

Running, beginner-level study notes for CSC2529 (Computational Imaging), written up week by week as the course goes.

**📖 Read the notes:** [Running Notes](https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0) — a running, browsable course notebook (nav per week + a cumulative glossary). The markdown in this repo is the same content in plain-text form.

## Contents

| File | What it is |
|---|---|
| [`week1-study-notes.md`](./week1-study-notes.md) | Week 1 — the human visual system: eye anatomy, the contrast sensitivity function, hybrid images, and more. |
| [`week2-study-notes.md`](./week2-study-notes.md) | Week 2 — optical principles: lenses, focal length, image formation, diffraction, and the pinhole camera. |
| [`week3-study-notes.md`](./week3-study-notes.md) | Week 3 — color science (spectral sensitivity, CIE color matching, chromaticity, gamuts) and the camera image processing pipeline: demosaicking, denoising, gamma correction, gamut mapping, and JPEG compression. |
| [`glossary.md`](./glossary.md) | A single, cumulative glossary of course terminology, grouped by the week each term is (or will be) covered. |
| [`formulas.md`](./formulas.md) | A single, cumulative reference of important formulas, grouped by week — each with the formula, a term-by-term breakdown, and what it computes. |
| [`CLAUDE.md`](./CLAUDE.md) | The project's own working notes for how these are generated and kept up to date. |
| [`FACT_AUDIT.md`](./FACT_AUDIT.md) | Verification log of factual claims against external sources. |

More `weekN-study-notes.md` files are added as the course progresses.

## Built with Claude Code

These notes are written with [Claude Code](https://claude.com/claude-code), driven by the workflow instructions in [`CLAUDE.md`](./CLAUDE.md). Cloning this repo and opening it in Claude Code will register the plugins used to produce it (see [`.claude/settings.json`](./.claude/settings.json)):

| Plugin | Used for |
|---|---|
| [`superpowers`](https://github.com/anthropics/claude-plugins-official) | Process discipline (brainstorming, plans, verification) applied when researching and drafting each week's notes. |
| [`document-skills`](https://github.com/anthropics/skills) | Extracting text/figures from the lecture-slide PDFs before writing them into notes. |

Also used, no install required (bundled with Claude Code):
- **`artifact-design` / `artifact-diagramming`** — govern the visual design and original inline-SVG diagrams in the [published running artifact](https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0).
- **A custom subagent**, [`.claude/agents/fact-auditor.md`](./.claude/agents/fact-auditor.md) — runs the fact-checking pass recorded in `FACT_AUDIT.md`.

## Source

Course site: https://www.cs.toronto.edu/~lindell/teaching/2529/
