# Fact Audit — CSC2529 Computational Imaging Study Notes

**Last audited:** 2026-09-14

**Scope:** `README.md`, `week1-study-notes.md`, `glossary.md`, and the live published artifact
(https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0), audited cold against
external sources. This run gave particular attention to the §12.4 Fourier-transform material
(1D→2D, `fft2` output semantics, `fftshift`/`ifftshift`, frequency-domain filtering, the
convolution theorem) and the §13.2 hybrid-images mechanism, in addition to re-checking every
other discrete factual claim in the notes.

**Summary: 47 claims audited — 43 confirmed / 3 corrected / 1 unverifiable.**

Corrected claims (one line each):
1. Foveal cone spacing (Roorda & Williams 1999): "~5 arcminutes" → **"~0.5 arcminutes"** (10× error).
2. §17 summary line falsely implied "~6.5 f-stops instantaneous" and "~5 orders of magnitude instantaneous" (§10) are just two units for the same number — they are not (6.5 stops ≈ 2 orders of magnitude, not 5); text corrected to state this plainly rather than paper over the mismatch.
3. (Same underlying error as #2, corrected everywhere it appears — see "Dynamic range" entry below for detail.)

Markdown and artifact had **drifted apart in exactly the errors above** (both files independently
stated "5 arcminutes" and the false stops/orders-of-magnitude equivalence — i.e., not drift
between the two, but the same errors present in both, now fixed identically in both). No other
drift was found: every other claim checked said the same thing in the markdown and the artifact.

---

## Corrected claims (detail)

### 1. Foveal cone spacing (Roorda & Williams, 1999)

- **Claim:** "individual cones separated by about **5 arcminutes** of visual angle" (Roorda &
  Williams, 1999, *Nature*).
- **Verdict: Corrected.** The actual foveal cone spacing reported in the adaptive-optics cone
  mosaic literature is on the order of **0.5 arcminutes** (roughly 3 µm center-to-center spacing,
  cited elsewhere as corresponding to ~1 arcminute of resolution via the sampling/Nyquist limit —
  see e.g. the discussion of Nyquist-limited foveal acuity in PMC2822659 and related adaptive-optics
  cone-mosaic papers). "5 arcminutes" was internally inconsistent with the *rest of the notes'
  own numbers*: with a 0.5 arcmin cone pitch, the Nyquist sampling limit is ≈1 arcmin — exactly
  matching §8's cited 20/20 acuity limit — and the corresponding cutoff spatial frequency is
  30/0.5 = **60 cycles/degree**, exactly matching §12.3's cited CSF high-frequency cutoff. A 5
  arcmin pitch would instead predict a 6 cpd cutoff, contradicting the notes' own 60 cpd figure.
  This internal-consistency check plus independent secondary sources gave high confidence in the
  correction.
- **Before → after (both `week1-study-notes.md` and the artifact, each occurrence):**
  - §2 / week-1-s2: "separated by about **5 arcminutes**" → "separated by about **0.5
    arcminutes**" (with an added parenthetical cross-referencing the Nyquist consistency above).
  - §12.3 / week-1-s12: "the same **~5-arcminute** cone spacing" → "the same **~0.5-arcminute**
    cone spacing."
- **Sources:** [Roorda & Williams 1999, *Nature* 397:520–522 (citation record)](https://pmc.ncbi.nlm.nih.gov/articles/PMC5290289/), [The relationship between visual resolution and cone spacing in the human fovea (Nature Neuroscience)](https://www.nature.com/articles/nn.2465), [Nyquist-limited foveal cone sampling discussion, PMC2822659](https://pmc.ncbi.nlm.nih.gov/articles/PMC2822659/), [foveal cone spacing ≈3 µm ↔ 1 arcmin discussion, NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK554706/).

### 2. §17 "dynamic range" summary — false equivalence between two different numbers

- **Claim:** "~6.5 f-stops instantaneous, adapts up to ~46.5 total (equivalently the ~5 vs. ~14
  orders of magnitude figures in §10 — these are two different ways of citing the same
  underlying range)."
- **Verdict: Corrected.** Checking the arithmetic: 1 order of magnitude ≈ log₂(10) ≈ 3.32
  f-stops. 14 orders of magnitude × 3.32 ≈ **46.5 f-stops** — this half of the claimed equivalence
  is correct and was left alone. But 5 orders of magnitude × 3.32 ≈ **16.6 f-stops, not 6.5
  f-stops** — so the "instantaneous" pairing is *not* a unit conversion of the same number, despite
  the notes' claim that it is. Both "~5 orders of magnitude" and "~6.5 f-stops" are independently,
  commonly cited figures for the eye's "instantaneous" (non-adapted) dynamic range in different
  sources (see Wolfcrow and related photography/vision-science discussions), but they describe
  different operational definitions of "instantaneous" and do not reduce to one another
  arithmetically. The notes' framing incorrectly presented them as interchangeable.
- **Before → after:**
  - `week1-study-notes.md` §17: replaced the parenthetical claiming equivalence with a corrected
    explanation: the 46.5-stop/14-orders pairing is a genuine, verified unit conversion; the
    6.5-stop/5-orders pairing is not, and the two numbers are separately-sourced rather than
    interchangeable.
  - Artifact §17 (`week-1-s17` term-table "Dynamic range" row): same correction applied — added a
    clause noting the 46.5-stop figure is a clean ×3.32 conversion of the 14-orders figure, while
    the 6.5-stop figure does not likewise convert from the 5-orders figure.
- **Sources:** [What is the Dynamic Range of the Human Eye? (Wolfcrow)](https://wolfcrow.com/what-is-the-dynamic-range-of-the-human-eye/), [The Dynamic Range of the Human Eye (REDUSER discussion, citing ~6.5 stops instantaneous / ~10–14 stops simultaneous)](https://reduser.net/threads/the-dynamic-range-of-the-human-eye.54516/), arithmetic cross-check (log₂10 ≈ 3.32).

---

## Confirmed claims

*(Grouped by section; source(s) given for each. Numeric/formula claims were checked against an
independent source stating the number, not merely against plausibility.)*

**§0–1 (intro, eye anatomy):** Optics+Sensing+Computation framing, cornea doing most fixed focusing power, iris/pupil as aperture, ciliary muscle/zonular fibers changing lens shape, choroid absorbing stray light, sclera as structural shell, optic disc as the blind spot — standard ophthalmology/optics facts, confirmed via general anatomy references and the [Cornea](https://en.wikipedia.org/wiki/Cornea), [Ciliary muscle](https://en.wikipedia.org/wiki/Ciliary_muscle), [Zonule of Zinn](https://en.wikipedia.org/wiki/Zonule_of_Zinn), [Choroid](https://en.wikipedia.org/wiki/Choroid), [Optic disc](https://en.wikipedia.org/wiki/Optic_disc)/[Blind spot](https://en.wikipedia.org/wiki/Blind_spot_(vision)) Wikipedia pages (all resolve and match the concept linked).

**§2 (rods/cones):** Rod count ~120 million, cone count ~6 million — confirmed via [AAO Rods](https://www.aao.org/eye-health/anatomy/rods)/[AAO Cones](https://www.aao.org/eye-health/anatomy/cones) and consistent secondary sources. Retina light path (light passes through ganglion/bipolar cells before reaching photoreceptors) — standard, confirmed by general retinal-anatomy sources.

**§3 (color):** Visible spectrum ~400–700 nm — confirmed, standard. S/M/L cone peak wavelengths (~440/545/565 nm) — confirmed as within the commonly-cited range across sources (S 420–440 nm, M 530–545 nm, L 560–580 nm); exact peak values vary modestly by measurement technique across the literature, and the notes' figures fall inside the normal range rather than outside it. Metamerism definition — confirmed via [Metamerism (color)](https://en.wikipedia.org/wiki/Metamerism_(color)).

**§4 (eye vs. camera, Bayer):** Bayer RGGB mosaic, green doubled for luminance sensitivity, demosaicking definition — confirmed via [Bayer filter](https://en.wikipedia.org/wiki/Bayer_filter), [Demosaicing](https://en.wikipedia.org/wiki/Demosaicing) (both links resolve to the correct topic).

**§5 (accommodation range):** ~8 cm near point at ~16 y/o (≈12.3 D amplitude), ~50 cm near point at ~50 y/o (≈2 D amplitude) — confirmed consistent with published amplitude-of-accommodation-vs-age data (Indian Journal of Ophthalmology and related sources); presbyopia mechanism confirmed via [Presbyopia](https://en.wikipedia.org/wiki/Presbyopia).

**§6 (refractive errors):** Myopia/hyperopia/astigmatism definitions and corrections (concave/convex/cylindrical lenses) — confirmed via [Myopia](https://en.wikipedia.org/wiki/Myopia), [Farsightedness](https://en.wikipedia.org/wiki/Farsightedness) (confirmed this page covers hyperopia/farsightedness as the same condition), [Astigmatism](https://en.wikipedia.org/wiki/Astigmatism).

**§7 (field of view):** Monocular ~190°, binocular ~120°, vertical ~135° — confirmed via multiple FOV references (perspectiveresearchcentre.com and related ergonomics/optics sources reporting the same figures).

**§8 (acuity):** 20/20 ≈ 1 arcminute; Snellen letter subtends 5 arcmin, each stroke 1 arcmin — confirmed via [Visual acuity](https://en.wikipedia.org/wiki/Visual_acuity), [Snellen chart](https://en.wikipedia.org/wiki/Snellen_chart), [Minute and second of arc](https://en.wikipedia.org/wiki/Minute_and_second_of_arc) (all links resolve correctly).

**§9 (retina display worked example):** Formula p = 2·d·tan(α/2) — correct right-triangle derivation, confirmed by direct trigonometric check. Numeric worked example (12", 1 arcmin → p ≈ 0.0035", dpi ≈ 286) — recomputed independently and confirmed arithmetically correct. Steve Jobs'/Apple's claimed 300 ppi at 10–12 inches — confirmed via multiple sources quoting Jobs' actual keynote language ("magic number right around 300 pixels per inch... 10 to 12 inches away"). dpi = 1/p relationship and dpi-vs-ppi terminology history — confirmed via [Dots per inch](https://en.wikipedia.org/wiki/Dots_per_inch), [Pixel density](https://en.wikipedia.org/wiki/Pixel_density).

**§10 (dynamic range):** Full adapted human range ~14 orders of magnitude — confirmed via multiple HDR-imaging/vision-science sources. Typical (era-appropriate) display range ~3 orders of magnitude — confirmed as a standard figure in HDR-display literature. (The "instantaneous" figures in this section were also independently checked; see Corrected item #2 above for the one issue found — the §10 numbers themselves, "~5 orders of magnitude" and "~6.5 f-stops," are each independently attested, they just don't convert into each other as §17 previously implied.)

**§11 (contrast):** Weber contrast formula (I_feature − I_background)/I_background and Michelson contrast formula (I_max − I_min)/(I_max + I_min) — confirmed verbatim via the [Contrast (vision)](https://en.wikipedia.org/wiki/Contrast_(vision)) Wikipedia page, including that the `#Weber_contrast` and `#Michelson_contrast` anchors used in the notes/artifact actually exist and point to the right formulas.

**§12.0–12.2 (spatial frequency, cpd):** Three-way "frequency" disambiguation (light/temporal/spatial) — sound conceptual framing, no factual claim to falsify beyond definitions, which are standard. cpd as a viewing-distance-dependent unit, and the worked "step back → cpd increases" example — verified by direct trigonometric reasoning, correct.

**§12.2.1 (image frequency):** Worked example (period-6-pixel texture → 0.167 cycles/px → ×300 dpi → 50 cycles/inch → ≈13.7 cpd at 40 cm) — independently recomputed and confirmed arithmetically consistent (using the same p = 2·d·tan(α/2) relationship as §9).

**§12.3 (CSF curve):** Campbell & Robson (1968) used sinusoidal gratings, measured minimum detectable contrast across spatial frequencies, found a band-pass sensitivity curve, and proposed spatial-frequency-tuned "channels" — confirmed by directly locating and characterizing the original *J. Physiol.* (1968) 197:551–566 paper and secondary descriptions of it. CSF peak "around 4–6 cpd" — confirmed as within the commonly cited range across sources (values from ~2 to ~8 cpd appear depending on luminance/testing conditions; 4–6 cpd is a standard textbook figure and not contradicted by any source found). High-frequency cutoff "~60 cpd," attributed to cone packing density — confirmed via multiple vision-science sources explicitly citing a ~60 cpd cutoff set by photoreceptor density.

**§12.4.0–12.4.5 (Fourier transform / fft2 / fftshift / convolution theorem):** All checked directly against NumPy's own documentation and standard DFT theory:
  - `fft2` output has the DC (zero-frequency) term in the low-index corner, positive frequencies in the first half of each axis, and negative frequencies (via periodic wraparound) in the second half — confirmed via [numpy.fft.fft2 docs](https://numpy.org/doc/stable/reference/generated/numpy.fft.fft2.html).
  - `fftshift` moves the DC component from a corner to the center by swapping opposite quadrants; `ifftshift` undoes it and must precede `ifft2` — confirmed via [numpy.fft.fftshift docs](https://numpy.org/doc/stable/reference/generated/numpy.fft.fftshift.html).
  - 2D grating formula I(x,y) = A·cos(2π(ux+vy)+φ) and the u/v-frequency geometric interpretation — standard Fourier-optics formula, confirmed correct by direct inspection (v=0 → vertical stripes, u=0 → horizontal stripes, matches the definition of a 2D plane wave).
  - Convolution theorem (multiplication in frequency domain ⇔ convolution in spatial domain) — standard, confirmed via [Convolution theorem](https://en.wikipedia.org/wiki/Convolution_theorem).
  - Low/high-pass masks as disc/complement-of-disc masks around the centered DC — standard frequency-domain filtering description, confirmed conceptually correct.
  - **HW1's actual code path**: independently confirmed (via the CSC2529 course site and cached descriptions of Homework 1) that the assignment does in fact have students call `fft2`, apply a hard-cutoff low-pass filter to one image and high-pass filter to the other (same cutoff), merge in the Fourier domain, and inverse-transform — matching the notes' description of "HW1's own code path" essentially exactly.

**§13 (hybrid images):** Oliva, Torralba & Schyns, "Hybrid images," *ACM Transactions on Graphics* 25(3):527–532, SIGGRAPH 2006 — confirmed venue, year, authors, and title via [ACM Digital Library record](https://dl.acm.org/doi/10.1145/1179352.1141919) and the [SIGGRAPH history page](https://history.siggraph.org/learning/hybrid-images-by-oliva-torralba-and-schyns/). High-pass(A) + low-pass(B) → hybrid image mechanism — confirmed as the paper's actual construction (per multiple independent course-project descriptions of the paper's method: "hybrid = low_pass(image1) + high_pass(image2)"). §13.2's specific framing of doing this via `fft2`/mask/`ifft2` (rather than spatial-domain Gaussian convolution) was cross-checked against CSC2529's own HW1 instructions (see above) rather than the original paper's own implementation choice, since the notes explicitly present it as "HW1's own code path" — confirmed accurate to the assignment. [Hybrid image](https://en.wikipedia.org/wiki/Hybrid_image) Wikipedia link resolves correctly and matches the definition given.

**§14 (depth perception):** Monocular/binocular cue lists, vergence/disparity definitions — standard depth-perception taxonomy, confirmed via [Depth perception](https://en.wikipedia.org/wiki/Depth_perception), [Monocular vision](https://en.wikipedia.org/wiki/Monocular_vision), [Binocular vision](https://en.wikipedia.org/wiki/Binocular_vision), [Vergence](https://en.wikipedia.org/wiki/Vergence), [Binocular disparity](https://en.wikipedia.org/wiki/Binocular_disparity) (all links resolve to the correct topic).

**§15 (stereoscopy history):** Charles Wheatstone invented/presented the stereoscope in 1838 (presented 21 June 1838, published in *Philosophical Transactions of the Royal Society*) — confirmed via the [Wheatstone stereoscope Wikipedia page](https://en.wikipedia.org/wiki/Wheatstone_stereoscope) and the Royal Society's own historical account. Ivan Sutherland built an early head-mounted VR/AR display ("Sword of Damocles") in 1968 — confirmed via [Ivan Sutherland's head-mounted 3D display](https://en.wikipedia.org/wiki/Ivan_Sutherland's_head-mounted_3D_display) and the Computer History Museum's account. "Stereoscopic" etymology (stereo + scopic) — confirmed standard.

**§16 (vergence-accommodation conflict):** Definition and mechanism (verging to simulated depth while accommodating to fixed screen distance) — standard, well-attested concept in the VR/display literature; confirmed conceptually via [Vergence-accommodation conflict](https://en.wikipedia.org/wiki/Vergence-accommodation_conflict) and the light-field-display link, [Light field § 3D display](https://en.wikipedia.org/wiki/Light_field#3D_display) (confirmed this anchor exists and the section is about autostereoscopic/light-field 3D display, matching how it's cited).

**§17 (summary):** Acuity, FOV, temporal resolution (~60 Hz), accommodation range figures — all cross-references to already-confirmed numbers above, consistent. CIE xy chromaticity / CIE Lab approximate perceptual uniformity — confirmed via general color-science sources describing CIELAB as designed for (approximate) perceptual uniformity.

---

## Unverifiable claim

- **Claim:** "Visual illusions (M.C. Escher; **Held et al., 2006, SIGGRAPH**) show these cues can be
  individually tricked or isolated" (§14, both `week1-study-notes.md` and the artifact).
- **Verdict: Unverifiable.** Multiple targeted searches (author name + year + venue, and by
  general subject) did not turn up a specific, identifiable 2006 SIGGRAPH paper or course by a
  "Held" on visual-illusion depth-cue demos matching this description. This may refer to a
  SIGGRAPH course, talk, or demo reel not well-indexed in general web search, or the citation
  detail (year/venue) may be off — but I could not find a source either confirming or
  contradicting it, so it is left unverified rather than guessed at or corrected. **Not changed**
  in either the markdown or the artifact, per instructions not to "correct" a claim that cannot
  actually be verified.

---
---

# Week 2 Audit — 2026-09-15

**Last audited:** 2026-09-15

**Scope:** `week2-study-notes.md` (full file), the `## Week 2` section of `glossary.md`, and the
`<section class="week-block" id="week-2" ...>` block plus the `#glossary-week-2` `.week-card` of
the live published artifact (https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0).
Week 1 content was intentionally **not** re-audited this run. Primary verification used Wikipedia,
independent photography/optics references (B&H, Nikonians, Evident/Nikon MicroscopyU, NASA/ESA
Hubble pages), the original CVPR 2017 "Computational Imaging on the Electric Grid" / ICCP 2018
"Rolling Shutter Imaging on the Electric Grid" papers (Sheinin, Schechner, Kutulakos), and — as a
primary source for what the lecture itself asserts (since several Week 2 claims are explicitly
"values as cited in lecture") — the actual CSC2529 Lecture 2 slide deck
(`cs.toronto.edu/~lindell/teaching/2529/slides/lecture2.pdf`), extracted and read directly.

**Summary: 36 claims audited — 34 confirmed / 1 corrected / 1 unverifiable.**

Corrected claims (one line each):
1. Field-of-view table, 135 mm focal length column: **"~10°"** → **"~18°"** (the lecture's own FOV
   chart gives 135 mm → 18°; "~10°" is actually the chart's value for 250 mm, apparently
   transcribed into the wrong column when the table was built).

Markdown and artifact had **drifted apart in one respect**: `week2-study-notes.md` §6 only states
three FOV data points (8 mm, 50 mm, 1000 mm — all correct), while the artifact's §6 table
additionally lists 28 mm, 135 mm, and 500 mm. This isn't a contradiction between the two files (the
three shared values agree), but it is an asymmetry — the artifact contains claims the markdown
doesn't, one of which was wrong. The erroneous 135 mm value has been corrected directly in the
artifact table (see above); no markdown edit was needed since the markdown never stated a 135 mm
figure. No other drift was found between `week2-study-notes.md`, the Week 2 glossary section, and
the artifact's week-2 block/glossary card — every other claim checked said the same thing in all
three places.

---

## Corrected claim (detail)

### 1. Field of view at 135 mm focal length (full-frame sensor)

- **Claim (artifact §6 table only):** "135 mm → ~10°" (diagonal field of view, full-frame sensor).
- **Verdict: Corrected.** Independently computing the notes' own formula, FOV = 2·arctan(d /
  2f), with a full-frame diagonal d ≈ 43.3 mm and f = 135 mm, gives FOV ≈ 18.2°, not 10°.
  This is corroborated by multiple independent photography references (Nikon's own Z 135mm f/1.8 S
  Plena spec sheet lists 18°10′ diagonal AOV for FX/full-frame; general angle-of-view charts
  agree). Going back to the actual CSC2529 Lecture 2 slide ("Field of View," slide 84), the
  lecture's own reference chart reads 1000 mm→2.5°, 500 mm→5°, 350 mm→7.5°, **250 mm→10°**, **135
  mm→18°**, 85 mm→29°, 50 mm→43°, 35 mm→63°, 28 mm→75°, 8 mm→180° — confirming that "18°" is the
  correct value for 135 mm, and "10°" is actually the chart's value for the (unlisted-in-notes)
  250 mm row. This looks like a transcription slip when the table was condensed into the artifact
  (adjacent-row value copied into the wrong column) rather than a genuine disagreement with the
  source.
- **Before → after (artifact only — `week2-study-notes.md` never stated a 135 mm value):**
  - Artifact `week-2-s6` FOV table, 135 mm column: **"~10°"** → **"~18°"**.
- **Sources:** [CSC2529 Lecture 2 slides, "Field of View" (slide 84), cs.toronto.edu/~lindell/teaching/2529/slides/lecture2.pdf](https://www.cs.toronto.edu/~lindell/teaching/2529/slides/lecture2.pdf), [Nikon Nikkor Z 135mm f/1.8 S Plena specifications](https://en.wikipedia.org/wiki/Nikon_Nikkor_Z_135_mm_f/1.8_S_Plena), direct arithmetic check of FOV = 2·arctan(d/2f) with d = 43.3 mm (36×24 mm sensor diagonal).

---

## Confirmed claims

*(Grouped by section; source(s) given for each. Numeric/formula claims were checked against an
independent source stating the number, not merely against plausibility. Where a claim is
explicitly framed in the notes as "values/method as cited in lecture," the actual Lecture 2 slide
deck was read directly as the primary source, in addition to independent secondary sources.)*

**§1 (pinhole camera, historical aside):** Mo-Ti/Mozi (470–390 BC) gave the earliest known written
description of the camera-obscura/pinhole principle, correctly explaining image inversion —
confirmed via multiple camera-obscura history sources describing the Mo-Jing texts. Niépce's *View
from the Window at Le Gras* (1826), 8-hour exposure — confirmed as "the traditional estimate" per
[Wikipedia's own article on the photograph](https://en.wikipedia.org/wiki/View_from_the_Window_at_Le_Gras)
(the same article also notes one modern researcher's re-creation suggests the true exposure may
have run several days — a genuine secondary-scholarship caveat, not a contradiction of the
commonly-cited 8-hour figure the notes use). Vermeer's *The Milkmaid* (1658) as an example of
camera-obscura-assisted painting — see "Unverifiable" below; not corrected.

**§4 (refraction, thin lens, historical aside):** Refraction definition — confirmed via
[Refraction](https://en.wikipedia.org/wiki/Refraction). Nimrud lens, ~2,700 years old, among the
oldest known manufactured lenses — confirmed via multiple sources (British Museum object history,
Amusing Planet, Ancient Origins). Daguerre's 1838/1839 daguerreotype cutting exposure to
"10–12 minutes" — confirmed as within the commonly-cited range for the original 1839 process
(sources report 3–15 minutes generally, "about 10 minutes" as a typical figure, dropping toward
~1 minute only after later lens/bromine improvements). Thin lens equation 1/f = 1/S₁ + 1/S₂ and the
three-characteristic-ray hand-tracing method (parallel ray, chief ray, near-focal-plane ray) —
confirmed directly against the CSC2529 Lecture 2 slides (slides 59–63), which show the identical
construction and formula. Magnification M = f/(f − S₁) — confirmed directly against Lecture 2
slide 63, which gives the same formula, and independently re-derived from the thin-lens equation
plus similar triangles.

**§5 (aberrations):** Spherical aberration (spherical vs. ideal hyperbolic lens surfaces),
chromatic aberration (dispersion, wavelength-dependent focal length, achromatic doublets), and
oblique aberrations (off-axis only) — confirmed directly against Lecture 2 slides 81–83, and via
[Chromatic aberration](https://en.wikipedia.org/wiki/Chromatic_aberration) and
[Dispersion (optics)](https://en.wikipedia.org/wiki/Dispersion_(optics)). Hubble Space Telescope's
primary-mirror spherical aberration (a 2.2 µm figuring error from a flawed null corrector) and its
correction by the COSTAR instrument package installed in the 1993 servicing mission — confirmed via
[NASA's Hubble mirror-flaw page](https://science.nasa.gov/mission/hubble/observatory/design/optics/hubbles-mirror-flaw/)
and [Corrective Optics Space Telescope Axial Replacement](https://en.wikipedia.org/wiki/Corrective_Optics_Space_Telescope_Axial_Replacement),
matching Lecture 2 slide 88 exactly.

**§6 (field of view):** FOV = 2·arctan(d/2f) — confirmed as the standard rectilinear angle-of-view
formula via [Angle of view](https://en.wikipedia.org/wiki/Angle_of_view) and direct trigonometric
re-derivation. Table values 8 mm→~180°, 28 mm→~75°, 50 mm→~43°, 500 mm→~5°, 1000 mm→~2.5° —
confirmed both against Lecture 2 slide 84's own reference chart and independently against general
photography angle-of-view references; 135 mm→~10° was **not** confirmed (see Corrected above).

**§7 (aperture/f-number):** N = f/D — confirmed via [F-number](https://en.wikipedia.org/wiki/F-number)
("N = f/D where f is the focal length and D is the diameter of the entrance pupil"), matching
Lecture 2 slide 90 exactly. "Stop" = a factor-of-2× change in light — confirmed via the same
Wikipedia page and Lecture 2 slide 91 ("a 'stop' changes the amount of light by a factor of 2").
2× diameter → 4× light and 2× focal length → ¼× light — confirmed by direct geometric/inverse-square
reasoning (area ∝ diameter², irradiance ∝ 1/distance²); standard optics, not disputed by any source
found.

**§8 (circle of confusion, depth of field, hyperfocal distance):** Circle-of-confusion formula c =
M·D·|S − S₁|/S — confirmed via the [Circle of confusion](https://en.wikipedia.org/wiki/Circle_of_confusion)
Wikipedia page, which gives the equivalent general form c = A·m·|S₂ − S₁|/S₂ (A = aperture diameter,
m = magnification), and directly against Lecture 2 slide 93, which states the identical formula and
sign convention M = f/(S₁ − f). Depth-of-field definition (range of object distances whose blur
stays below a fixed acceptable-circle-of-confusion threshold) — confirmed via
[Depth of field](https://en.wikipedia.org/wiki/Depth_of_field). Hyperfocal distance H = f²/(N·c) —
confirmed via multiple independent photography references (B&H Photo, Omnicalculator) and directly
against Lecture 2 slide 96. Canon 5D Mark III worked-example parameters (f = 50 mm, N = 2.8, focused
at 5 m, 7.5 µm pixel pitch) — confirmed as matching the actual lecture slide (95–96) verbatim; the
specific numeric depth-of-field answer is intentionally left uncomputed in the notes, per project
policy, and was not computed here either.

**§9 (diffraction limit):** Ernst Abbe's 1873 diffraction-limit result and its 1882 formula d =
λ/(2·NA) — confirmed via Britannica's "Abbe limit" entry and multiple microscopy-history sources
(Abbe's 1873 paper contained no explicit equation; the equation form was published in 1882 — the
underlying physical claim and the "1873" attribution for the discovery itself are both standard and
correct). Numerical aperture NA = n·sinθ and the small-angle approximation NA ≈ 1/(2N) relating
numerical aperture to photographic f-number — confirmed via
[Numerical aperture](https://en.wikipedia.org/wiki/Numerical_aperture) ("N ≈ 1/(2·NAᵢ), assuming
normal use in air"), and directly against Lecture 2 slides 103–104, which give the identical
formula chain d = λ/(2n sinθ) = λ/(2NA) ≈ λN. Microscope objectives today reaching NA 1.4–1.6
(giving d = λ/2.8) — confirmed via Nikon MicroscopyU and Evident/Olympus microscopy references
(practical oil-immersion maximum ≈1.4, specialized high-performance objectives up to ~1.6), and
matches Lecture 2 slide 104 verbatim.

**§10 (sensors/pixel anatomy):** Photodiode/photoelectric-effect photon-to-electron conversion —
confirmed via [Photoelectric effect](https://en.wikipedia.org/wiki/Photoelectric_effect). Microlens,
color filter, fill-factor roles — confirmed conceptually, matching Lecture 2 slides 107–108
exactly. Quantum efficiency "~50% for a typical sensor" — confirmed directly against Lecture 2
slide 108 ("quantum efficiency: ~50%") and independently corroborated as a commonly-cited
whole-system estimate for consumer camera sensors (noting that specialized/back-illuminated
sensors can reach substantially higher QE — the notes' "~50% typical" framing is accurate as a
general/consumer figure, not a universal maximum).

**§11 (CCD vs. CMOS):** Architecture and readout descriptions (CCD: shared amplifiers, row-by-row
charge shifting; CMOS: per-pixel amplifiers, multiplexed readout) and the sensitivity/noise vs.
speed/cost trade-off — confirmed directly against Lecture 2 slides 111–113, which state the
identical trade-off (CCD: "higher sensitivity, lower noise"; CMOS: "faster read-out, lower cost").

**§13 (exposure, exposure time, ISO) — re-audited 2026-09-24 after the section was rewritten
(was §12).** The earlier entry here ("exposure as accumulation time, independent of aperture/ISO")
is superseded: the notes now use the strict definition *H* = *E*·*t*, which depends on aperture
through *E* and not on ISO. Confirmed:
- *H* = *E*·*t* and the camera equation *E* = (π/4)·*L*/*N*² (lens focused at infinity, no
  transmission losses; real lenses add T-stop losses and cos⁴ falloff) — [F-number § Camera
  equation](https://en.wikipedia.org/wiki/F-number), [Vignetting](https://en.wikipedia.org/wiki/Vignetting).
- Equivalent exposures depend only on *t*/*N*²; EV = log₂(*N*²/*t*), one EV = one stop —
  [Exposure value](https://en.wikipedia.org/wiki/Exposure_value).
- Reciprocity holds for digital sensors (their long-exposure limit is dark current, not reciprocity
  failure) — [Reciprocity (photography)](https://en.wikipedia.org/wiki/Reciprocity_(photography)).
- ISO is, in the usual design, analog gain before the ADC (some "expanded ISO" settings are digital)
  and does not change *H* — [Film speed § Digital camera ISO speed](https://en.wikipedia.org/wiki/Film_speed)
  and Lecture 2 slide 118.
- Slide values: slide 121 ladder f/16 1/8 … f/2 1/500 (three photos, at 1/8, 1/125, 1/500);
  slide 155 "¼ sec, f/3.3, ISO 200" vs "2 sec, f/6.3, ISO 80" — read from the rendered slides and
  PDF text. All table/worked-example numbers recomputed by script: ladder *t*/*N*² ratios
  1.000–1.128 (max 0.174 stop) and EV 10.83–11.00; 16/√2 = 11.31; 62.5× time ratio; slide 155
  8× time, 0.274× aperture (−1.87 stops), net 2.195× (+1.13), ISO 0.4× (−1.32), final 0.878×
  (−0.19 stop); streaks 4/16/250/4000 px; burst SNRs 4.29/19.78/17.15; *c* = 0.2998 m/ns,
  0.150 m per ns of round trip, 100 m → 667 ns, 1 m gate → 6.67 ns, gate/10 ms ≈ 1/1.5 million;
  null space of [1, −2] is span(2, 1); length-*L* box kernel's DFT has exact zeros at multiples of
  *n*/*L*.
- Flutter shutter: binary pseudo-random open/close code makes motion blur broadband/invertible
  (Raskar, Agrawal & Tumblin, SIGGRAPH 2006; [Coded exposure photography](https://en.wikipedia.org/wiki/Coded_exposure_photography)).
- LiDAR/ToF: *d* = *c*τ/2, SPAD time-correlated histogramming, CW-ToF phase-shift ranging —
  [Lidar](https://en.wikipedia.org/wiki/Lidar), [Time-of-flight camera](https://en.wikipedia.org/wiki/Time-of-flight_camera),
  [Single-photon avalanche diode](https://en.wikipedia.org/wiki/Single-photon_avalanche_diode).
  Multi-integration-time HDR depth modes exist commercially (e.g. LUCID Helios2+ HDR mode fusing
  62.5/200/1000 µs; Basler ToF "dual exposure") — [thinklucid.com](https://thinklucid.com/helios-time-of-flight-tof-camera/),
  [baslerweb.com](https://www.baslerweb.com/en/cameras/basler-tof-camera/).
- HW1's 15–60 s exposure times — confirmed against the HW1 handout.

Corrected (wording, minimal edits):
1. ISO paragraph: "it amplifies certain noise sources, like read noise, disproportionately relative
   to … photon-counting noise" was wrong — pre-ADC gain amplifies shot noise and upstream read
   noise equally with the signal, and if anything *reduces* the relative impact of downstream
   (post-amplifier/ADC) noise. Replaced with that statement; "analog gain" qualified "(in the usual
   camera design)"; glossary ISO entry "applied before the ADC" → "usually applied before the ADC".
2. §13.7 HDR: "dividing each unclipped pixel value by its known *t*" was misleading — Debevec &
   Malik (SIGGRAPH 1997) first recover the nonlinear response curve *g*, then ln *E* = *g*(*Z*) − ln Δ*t*,
   weighted-averaged over frames ([paper](https://people.eecs.berkeley.edu/~malik/papers/debevec-malik97.pdf)).
3. §13.7 dark frame "capturing the *D·t* term alone" → also contains the sensor's fixed offset.
4. §13.8 "A pulsed LiDAR fires a pulse, then only opens the bucket in a gate" overgeneralized;
   now attributed to range gating specifically.
5. §13.1 HW1 photos "long exposures in exactly this sense [bulb]" — HW1 does not require bulb mode;
   reworded to "bulb mode or a long timed setting".
6. Self-check "a million times shorter than either" → "roughly" (a 6.67 ns gate is ~3×10⁵ times
   shorter than 1/500 s and ~1.9×10⁷ times shorter than 1/8 s).

All 12 Wikipedia links in §13 and its glossary entries return HTTP 200 and are not redirects.

**§13 (dynamic range, bit depth):** RAW 12–14 bits/pixel vs. JPEG 8 bits/channel — confirmed
directly against Lecture 2 slide 121 ("common bit depths: 12-14 bits RAW / 8 bits JPEG") and
independently via multiple photography references on RAW vs. JPEG bit depth.

**§14 (rolling vs. global shutter):** Global-shutter/rolling-shutter definitions and trade-offs —
confirmed via [Rolling shutter](https://en.wikipedia.org/wiki/Rolling_shutter) and Lecture 2 slide
123. 60 Hz AC power → 120 Hz light flicker (twice per electrical cycle) — confirmed directly
against Lecture 2 slide 125 ("60 Hz AC power results in 120 Hz flicker!") and independently via
multiple photography/electrical references. Sheinin et al. (2017), "26 frames over 10 ms" recovered
from a single rolling-shutter capture — confirmed directly against Lecture 2 slide 127, which shows
the identical cityscape image captioned "26 frames over 10 ms" and attributed "[Sheinin et al.
'17]"; this matches the notes' claim exactly. (A closely related 2018 ICCP paper by the same first
two authors plus Kutulakos, "Rolling Shutter Imaging on the Electric Grid," was also read directly
as a check — it develops the same rolling-shutter-as-sensor idea in more depth with a different
demo scene reporting 30 rendered frames over a 10 ms flicker cycle; this is a different example
from a related follow-up paper, not a contradiction of the 2017-attributed, 26-frame cityscape
example the lecture and notes cite.)

**§15 (sensor noise, SNR):** Photon → photodiode → amplifier (ISO gain) → ADC (quantization noise)
→ RAW image pipeline, plus fixed-pattern noise as a manufacturing-consistent (non-random) source —
confirmed directly against Lecture 2 slide 128. Gaussian noise as additive and signal-independent
(thermal/read/amplifier sources) and photon/shot noise as signal-dependent and Poisson-distributed
with standard deviation = √N — confirmed via [Gaussian noise](https://en.wikipedia.org/wiki/Gaussian_noise),
[Shot noise](https://en.wikipedia.org/wiki/Shot_noise), [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution),
and directly against Lecture 2 slides 129–131, which give the identical characterization and the
same Poisson formula f(k;λ) = λᵏe⁻λ/k!, σ = √λ. SNR formula SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²) —
confirmed directly against Lecture 2 slide 132 (identical formula and variable definitions: P =
incident photon flux, Qe = quantum efficiency, t = exposure time, D = dark current, Nr = read
noise) and independently via scientific-imaging references (Hamamatsu, Scientific Imaging Inc.)
giving the same formula. Scientific sensors cooled to ~−100°C to suppress dark current/read noise
down toward the shot-noise floor — confirmed directly against Lecture 2 slide 133 (Andor iXon Ultra
897 example, cooled to −100°C).

**Wikipedia links (spot-checked, in addition to the topical checks above):** `CMOS_sensor` resolves
(via redirect) to [Active-pixel sensor](https://en.wikipedia.org/wiki/Active-pixel_sensor), which is
indeed about CMOS image sensors — correct target. `Image_noise#Read_noise` anchor exists and
discusses read noise in digital cameras — correct target. `Numerical_aperture`,
`Circle_of_confusion`, `F-number`, `Depth_of_field`, `Chromatic_aberration`,
`Dispersion_(optics)`, `Photoelectric_effect`, `Charge-coupled_device`, `Gaussian_noise`,
`Shot_noise`, `Poisson_distribution`, `Signal-to-noise_ratio`, `Film_speed`,
`Exposure_(photography)`, `Rolling_shutter`, `Field_of_view`, `Refraction`, `Camera_obscura`, and
`Geometrical_optics` were all fetched or checked and resolve to the correct, matching concept.

---

## Unverifiable claim

- **Claim:** "Vermeer's *The Milkmaid* (1658) is a well-known example [of camera-obscura-assisted
  painting] cited in lecture" (§1, both `week2-study-notes.md` and the artifact).
- **Verdict: Unverifiable / genuinely disputed.** That painters, including Vermeer, used
  camera-obscura projections as a drawing aid is well-established in general (and *The Milkmaid* is
  indeed a commonly repeated example in popular accounts of this claim, which is presumably why the
  lecture cites it). However, art-historical sources specifically examining *The Milkmaid* report
  counter-evidence for this particular painting: a pinhole in the canvas used to mark a
  one-point-perspective vanishing point (inconsistent with camera-obscura tracing), and a figure
  shown mid-motion (inconsistent with the static projection a camera obscura would produce, since a
  model could not hold a pouring pose for the long exposure a camera-obscura tracing session would
  require). I could not find a source that definitively resolves this dispute either way, so this
  is left **Unverifiable** rather than corrected or confirmed — the general claim (painters used
  camera obscuras; Vermeer is popularly cited as an example) is well-attested, but the specific
  application to *this* painting is contested by specialists. **Not changed** in either the
  markdown or the artifact.
- **Sources consulted:** [Did Johannes Vermeer use a camera obscura or not? (vermeerdelft.nl)](https://www.vermeerdelft.nl/en/blogs/did-johannes-vermeer-use-a-camera-obscura-or-not),
  [Vermeer and the Camera Obscura, Part One (essentialvermeer.com)](https://www.essentialvermeer.com/camera_obscura/co_one.html),
  [A Closer Look at The Milkmaid (drawpaintacademy.com)](https://drawpaintacademy.com/the-milkmaid/).

---

## Addendum — 2026-09-24: §9.3 units trap (new passage)

**Scope:** only the new "Units trap: the threshold is stated in pixels, but the formula needs a
length" paragraph and bullets in §9.3, and the new glossary entry **Pixel pitch**.

**Summary: 6 claims audited — 6 confirmed / 0 corrected.**

- *m* and |*O* − *S*|/*O* are dimensionless, so *c* = *m·D·|O − S|/O* carries *D*'s length unit,
  and *k* = *ε*/(*mD*) dimensionless forces *ε* to be a length. Confirmed by dimensional analysis.
- Pixel pitch = center-to-center pixel spacing = sensor width ÷ pixels across; equal from height
  for square pixels; ε(length) = ε(pixels) × pitch. Confirmed (definition; Wikipedia Dot pitch,
  which the `Pixel_pitch` link redirects to, defines pitch for pixel-based devices generally).
- Illustrative example: 24 mm / 4000 px = 0.006 mm = 6 µm; 3 px × 0.006 mm = 0.018 mm. Arithmetic
  confirmed. Uses made-up numbers, not a homework camera, so the homework rule is respected.
- *D* = *f*/*N* carries *f*'s unit; *m* = *S′*/*S* matches §4.1 (line 151). Confirmed.
- "Typically a few µm." Confirmed (e.g. the lecture's own 5D Mark III example uses 7.5 µm).
- **Wikipedia link:** `Pixel_pitch` resolves, via redirect, to *Dot pitch*. Kept, because the
  article defines pitch for pixel-based devices in general, but it is display-oriented.

---
---

# Week 3 Audit — 2026-09-23

**Last audited:** 2026-09-23

**Scope:** `week3-study-notes.md` (full file), the `## Week 3` section of `glossary.md`, and the
`<section class="week-block" id="week-3" ...>` block plus the `#glossary-week-3` `.week-card` of
the live published artifact (https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0),
including all 11 of that block's diagrams (Fig. 28–38). Weeks 1 and 2 were not audited or
edited. Their markdown files were not opened; their artifact blocks were read only because the
full page source has to be read before republishing. This run focused on the claims added in commit 8e36cac (frequency and sharpness,
Bayer aliasing, Y′CbCr, gamut mapping, filter math, unsharp masking) and the four new figures
(Fig. 31, 32, 36, 38), plus four open items: the CIE 1931 observer count, chroma vs. luminance
acuity, the Display P3 primaries and XYZ→sRGB matrix, and σ_f = 1/(2πσ).

**Sources used:** Wikipedia (sRGB, CIE 1931 color space and its raw wikitext for section anchors,
DCI-P3, Gaussian filter, YCbCr, Nyquist frequency, Chroma subsampling, Luminous efficiency
function, Unsharp masking, Bilateral filter, Non-local means, Foveon X3, Anti-aliasing filter,
Three-CCD camera, Thermographic camera, Clipping (photography)); the IEC 61966-2-1 committee draft
(1997) PDF, read directly; the Malvar, He & Cutler ICASSP 2004 paper, read directly from the course
reading list; the CSC2529 Problem Session 2 slide deck (`slides/PS2.pdf`, 31 slides, read
directly); Mullen (1985), *J. Physiol.*, via its abstract as indexed; and hand re-derivation of
every worked number and every new figure's coordinates.

**Source limitation this run:** the Lecture 3 deck (`slides/lecture3.pdf`) is larger than the
10 MB fetch limit, and no local PDF renderer was available in this run. So claims whose only
source is a specific Lecture 3 slide could not be re-checked against the slide. They are listed as
Unverifiable below, not as Confirmed.

**Summary: 82 claims/diagrams audited: 67 confirmed / 7 corrected / 8 unverifiable.**
(Grouped counting: each bolded group below counts one claim per distinct fact or figure listed.)

Corrected items (one line each):
1. §13 XYZ→linear-sRGB matrix: the values given were the 1997 IEC committee-draft coefficients
   (3.2410, −1.5374, … 0.0556), not the published IEC 61966-2-1:1999 values (3.2406, −1.5372, …
   0.0557) that the text claims and that inverting the given forward matrix produces. Corrected in
   the markdown and the artifact.
2. §13 P3-green worked example, green channel: briefly changed 1.0421 → 1.0420, then **reverted to 1.0421**
   after script recomputation (see the entry below). Red and blue, −0.2249 and −0.0786, unchanged.
3. §10.5 "D_G and D_B are defined identically [to D_R]" → D_B is; **D_G is not**. The paper
   computes Δ_G over a 9-point region, which is why the R-at-G filters are not crosses. Markdown
   corrected; artifact sentence qualified and a short note added.
4. §11.8 texture add-on numbers: flat-region amplitude 0.0407 (Gaussian) / 0.0399 (bilateral) →
   **0.0397 / 0.0389**, and bilateral band 0.1589–0.8411 → **0.1611–0.8389**. Markdown and artifact.
5. Fig. 33 legend: the gradient term was labelled "D₀" (subscript zero) instead of D_R. The legend
   also used HTML `<sub>` inside SVG `<text>`, which HTML parsing treats as leaving the SVG, so the
   rest of the figure did not render as drawn. Artifact only.
6. Fig. 37 (gamma curves): the drawn curves and the four guide-line input labels (.05/.14/.30/.55)
   did not match I^(1/2.2) or the sRGB formula. Redrawn from computed points, labels now
   **.03/.13/.33/.61**. The same `<sub>`/`<sup>`-in-SVG problem was fixed. Artifact only.
7. Two dead Wikipedia section anchors: `CIE_1931_color_space#Color_matching_functions` →
   `#Color_matching`, and `#CIE_xy_chromaticity_diagram_and_the_CIE_xyY_color_space` →
   `#Chromaticity_diagram`. Fixed in `glossary.md` (2 links) and the artifact (§3, §5, glossary
   card: 4 links).

**Open items requested by the dispatcher, resolved:**
- **(1) CIE 1931 observer count.** Confirmed: two independent experiments, 10 observers (Wright)
  and 7 (Guild), 17 people in total. Neither count is 12. The slide's "12 people" could not be
  re-checked (deck unfetchable this run). The notes keep the attribution and now say plainly:
  "the lecture slide says 12 people, but the standard references describe two independent
  matching experiments, one with 10 observers and one with 7, so 17 people in total, whose
  averaged results were combined." This is a wording clarification, not a factual correction; the
  previous text ("two datasets of 10 and 7") was already accurate.
- **(2) Chroma acuity coarser than luminance acuity.** Confirmed. Mullen (1985): red-green and
  blue-yellow chromatic CSFs are low-pass, with limiting acuity around 11–12 cycles/deg, far below
  luminance acuity. Wikipedia's Chroma subsampling article gives the same rationale.
- **(3) Display P3 primaries / XYZ→sRGB matrix.** P3 primaries confirmed. Matrix corrected (items
  1–2 above).
- **(4) σ_f = 1/(2πσ).** Confirmed (Wikipedia Gaussian filter: σ·σ_f = 1/(2π), with
  ĝ(f) = exp(−f²/(2σ_f²)) for f in cycles per unit). The whole script-check table was re-derived
  by hand, including the σ = 1 px "7.2 × 10⁻³" deviation (see §11.2 below).

**Drift between markdown and artifact:**
- Fig. 33's "D₀" label and Fig. 37's wrong curves were artifact-only errors (the markdown carries
  no figures).
- §2: the markdown says the lasso curve "starts and ends **at** the origin", the artifact says
  "**near**". Neither is wrong. Left as is.
- Asymmetries, not contradictions: the markdown's §10.2 mentions camera models sold with and
  without an OLPF, which the artifact omits. The artifact's §8 table adds "less common than
  Bayer" for Foveon, which the markdown omits. The markdown's §10.3 carries a slide-73 audit note
  the artifact does not.
- Every other claim checked says the same thing in the markdown, the glossary section and the
  artifact.

**Observation, not changed:** PS2 (slide 17) applies `rgb2ycbcr` to the *linear* demosaiced image,
before gamma correction. The notes define Y′ as luma computed from gamma-encoded values. That
definition is the standard one, and the notes do not claim PS2 applies it after gamma, so nothing
was edited.

**Layout issues outside fact scope, not changed:** Fig. 33's bottom formula line is wider than its
460-unit viewBox and is clipped at both ends. Fig. 36's legend draws the output line in ink colour
while the plotted outputs are amber and teal.

---

## Corrected claims (detail)

### 1. §13 — XYZ → linear sRGB matrix

- **Before:** `[3.2410 −1.5374 −0.4986; −0.9692 1.8760 0.0416; 0.0556 −0.2040 1.0570]`, presented
  as "standardized (IEC 61966-2-1)" and as "the script's result" of inverting the sRGB→XYZ matrix
  built from the sRGB primaries and D65.
- **After:** `[3.2406 −1.5372 −0.4986; −0.9689 1.8758 0.0415; 0.0557 −0.2040 1.0570]`.
- **Why:** Wikipedia's sRGB article gives the 1999 standard's matrix as the "after" values, with a
  2003 amendment extending them to 7 decimals (3.2406255, −1.5372080, …). The "before" values
  appear exactly as eq. (6) of the 1997 IEC 61966-2-1 committee draft, read directly. That draft
  also used a D65 y of 0.3291 instead of 0.3290. Inverting the forward matrix as the notes
  describe gives the 1999 values, not the draft ones. Check: the corrected matrix sends D65
  (0.9505, 1, 1.0890) to (1.00001, 1.00005, 1.00001).
- **Sources:** [sRGB (Wikipedia)](https://en.wikipedia.org/wiki/SRGB); [IEC 61966-2-1 committee
  draft, 1997](https://ftp.osuosl.org/.1/libpng/documents/proposals/history/sRGB-iec6196621cd1.pdf)
  (eq. 5–6, Table 1).

### 2. §13 — P3 green through the matrix: green channel confirmed 1.0421 (an audit change to 1.0420 was reverted)

- Display P3 green primary XYZ = (0.2656677, 0.6917385, 0.0451134), the green column of the P3
  (D65) RGB→XYZ matrix. Its xy is (0.2650, 0.6900). Confirmed.
- Script recomputation (2026-09-23): the exact inverse derived from sRGB primaries + D65 gives
  (−0.224940, **1.042057**, −0.078636), and the 7-decimal matrix gives (−0.224904, 1.042081, −0.078655).
  Both round to G = **1.0421**, so the hand-derived 1.0420 was a rounding slip and was reverted. The
  published 4-decimal matrix gives (−0.2247, 1.0419, −0.0786), which the notes now mention alongside.
- The downstream numbers are unchanged and were re-derived: blend fraction t =
  0.2249/(0.2249 + 0.6917) = 24.54%; result (0, 0.9561, 0.1104); xy (0.2843, 0.5436), which lies on
  sRGB's G–B edge; luminance 0.6917. An independent P3→sRGB matrix (endavid.com) gives the P3-green
  column as (−0.2247, 1.0419, −0.0786), agreeing to within ±0.0002.
- **Sources:** as item 1; [Exploring the Display P3 color space (endavid.com)](https://endavid.com/index.php?entry=79);
  P3 matrix values via [search](https://www.russellcottrell.com/photo/matrixCalculator.htm), consistent with
  [DCI-P3 (Wikipedia)](https://en.wikipedia.org/wiki/DCI-P3) primaries plus D65.

### 3. §10.5 — definition of D_G

- **Before (markdown):** "(D_G and D_B are defined identically, substituting g or b for r.)"
  Artifact: "The gradient term is a discrete Laplacian of whichever channel is actually sampled at
  that pixel, using that same channel's values two pixels away in each cardinal direction."
- **After:** D_B uses the same 5-point cross as D_R. D_G uses a 9-point region: the green pixel,
  its 4 diagonal green neighbours, and the green samples 2 px away, weighted differently along
  the row and the column. The artifact sentence now opens "For D_R (and likewise D_B), …" and a
  one-line note on D_G follows the formula.
- **Why:** the paper (§3.1) says, for R at green pixels, "Δ_G(i,j) determined by a 9-point region"
  and, for R at blue pixels, "Δ_B(i,j) computed on a 5-point region". PS2 slide 21 shows the same
  kernels: the "R at green" filters carry −1 at the diagonals, −1 at ±2 along one axis and +1/2 at
  ±2 along the other.
- **Sources:** [Malvar, He & Cutler, ICASSP 2004 (course reading)](https://www.cs.toronto.edu/~lindell/teaching/2529/reading/Demosaicing_ICASSP04.pdf),
  eq. (2)–(5); [PS2 slides](https://www.cs.toronto.edu/~lindell/teaching/2529/slides/PS2.pdf), slide 21.

### 4. §11.8 — texture add-on numbers

- **Setup, from the notes:** step 0.2→0.8 with ±0.02 alternating texture, σ = 1 px, k = 1,
  σ_i = 0.1. The Gaussian blur is radius-3 (implied by the notes' own blur row, e.g. pixel 2 =
  0.2027, pixel 1 = 0.2).
- **Gaussian:** the blur is linear, so its effect on an alternating texture is H(0.5) = w0 − 2w1 +
  2w2 − 2w3 = 0.0141. The sharpened texture amplitude is therefore (2 − H(0.5))·0.02 = **0.0397**,
  and it can never exceed 0.04 for any positive H(0.5). The old 0.0407 exceeds that bound. It also
  contradicts the notes' own −0.02 / 1.02 edge values, which are exactly 0.0197 − 0.0397 and
  0.9803 + 0.0397.
- **Bilateral, interior:** neighbour intensity weight exp(−0.04²/0.02) = 0.923. Blurred texture =
  0.0541·a, so the sharpened amplitude is 1.946·0.02 = **0.0389** (old: 0.0399).
- **Bilateral, near the edge:** computed pixel by pixel with cross-edge weights ≈ 0. The extremes
  are 0.2 − 0.0389 and 0.8 + 0.0389, so the band is **0.1611–0.8389** (old: 0.1589–0.8411).
- **Caveat:** these are hand derivations; no script was run. The old values most likely came from
  array-boundary padding in a short test array. The qualitative claims ("roughly doubles";
  Gaussian overshoots, bilateral doesn't) are unchanged and confirmed.

### 5. Fig. 33 — gradient-term label and SVG markup

- **Before:** legend "used in D₀ (gradient term)" and "ĝ = ĝ_lin + α·D₀, where D₀ = …", using the
  Unicode subscript zero. The formula it illustrates names **D_R**. The labels also used HTML
  `<sub>` tags inside SVG `<text>`. Under the HTML parsing rules for foreign content, a `<sub>`
  start tag pops out of the SVG, so the legend and the elements after it did not render as SVG.
- **After:** D_R and ĝ_lin are written with `<tspan baseline-shift="sub">`. Every symbol in the
  D_R formula now has a correctly labelled counterpart. The grid geometry was already correct and
  is unchanged: 5×5 Bayer tile centred on R, G at ±1, R at ±2, matching the paper's G-at-R kernel
  (4 / 2 / −1)/8.

### 6. Fig. 37 — gamma curves and guide lines

- **Before:** hand-drawn Bézier curves that sat well above the true curves (e.g. at input 0.386
  the drawn power-law curve read 0.80 instead of 0.649), and guide lines from outputs
  0.2/0.4/0.6/0.8 down to inputs labelled .05/.14/.30/.55. Those labels were placed at x-positions
  corresponding to 0.15/0.28/0.44/0.65 and did not meet the drawn curve. The true inputs are
  0.2^2.2 = 0.029, 0.4^2.2 = 0.133, 0.6^2.2 = 0.325 and 0.8^2.2 = 0.612 (sRGB inverse: 0.033,
  0.133, 0.319, 0.604).
- **After:** both curves are polylines through points computed from I^(1/2.2) and from the sRGB
  piecewise formula (0.0031308 / 12.92 / 1.055 / 2.4). The guide lines end on the power-law curve
  at the computed inputs, labelled .03/.13/.33/.61. The `<sub>`/`<sup>` in the power-law label were
  replaced with `<tspan>`. Styling, colours and caption are unchanged; the caption still describes
  the figure correctly.

### 7. Dead Wikipedia section anchors

- The raw wikitext of *CIE 1931 color space* has section headings "Color matching" and
  "Chromaticity diagram" (with `{{anchor|Chromaticity diagram}}`). It has no anchor named
  "Color matching functions" or "CIE xy chromaticity diagram and the CIE xyY color space". The
  links still opened the right article but landed at the top. Fixed in `glossary.md` and in the
  artifact's §3, §5 and glossary card. `#CIE_standard_observer` exists and was left alone.
- **Source:** [CIE 1931 color space, raw wikitext](https://en.wikipedia.org/w/index.php?title=CIE_1931_color_space&action=raw).

---

## Confirmed claims and diagrams

**§1 (SSF):** R = ∫Φ(λ)f(λ)dλ is the standard colorimetric weighting integral, the same form as
the CIE's "Computing XYZ from spectral data" construction. Confirmed.

**§2 (tristimulus cone) — claim + Fig. 28:** positive octant, linear scaling along rays, mixtures
as non-negative combinations inside a convex cone, and metamerism as many-to-one. All follow
directly from the non-negativity and linearity of §1's integral (re-derived). Fig. 28 is labelled
schematic and is consistent with that geometry.

**§3:** matching by adding a primary to the test side, recorded as a negative coefficient.
Confirmed (Wikipedia, CIE 1931 "Color matching"). **Observer counts 10 + 7:** confirmed (Wikipedia:
"conducted in the mid-1920s by William David Wright using ten observers and John Guild using seven
observers"; search results citing the same). Standard observer defined by its CMFs: confirmed
(same article; the reference observer of IEC 61966-2-1 is "the CIE 1931 two-degree standard
observer").

**§4:** "The ȳ(λ) color matching function would be exactly equal to the photopic luminous
efficiency function", and "Y is the luminance". Confirmed (Wikipedia CIE 1931). V(λ) normalized to
a peak of 1 at 555 nm (green): confirmed (Wikipedia Luminous efficiency function). XYZ chosen so
that coordinates are non-negative, at the cost of non-physical primaries: confirmed (Wikipedia CIE
1931, "X is a mix … chosen to be nonnegative").

**§5:** x = X/(X+Y+Z), y = Y/(X+Y+Z), a projection that discards luminance. Confirmed.

**§6 — claim + Fig. 29:** three primaries plus convex combination gives a triangle (re-derived).
Fig. 29 is schematic and labelled as such.

**§7:** sRGB primaries (0.64, 0.33) / (0.30, 0.60) / (0.15, 0.06) and D65 (0.3127, 0.3290):
confirmed (Wikipedia sRGB; IEC draft Table 1). Display P3 = the DCI-P3 primaries (0.680, 0.320) /
(0.265, 0.690) / (0.150, 0.060) with a D65 white: confirmed (Wikipedia DCI-P3). Worked table
re-derived: (0.2, 0.8, 0.3) → sRGB xy (0.2928, 0.4409), P3 xy (0.2753, 0.4644).

**§8:** Foveon X3 (stacked photodiodes, depth-dependent absorption in silicon, no demosaicing):
confirmed (Wikipedia). Three-CCD (beam-splitter prism, three sensors, costlier): confirmed
(Wikipedia). Thermal-IR detector materials (InSb, HgCdTe, PbS/PbSe): confirmed (Wikipedia
Thermographic camera).

**§10.1 — claim + Fig. 30:** ĝ = ¼Σg over the four orthogonal neighbours. Confirmed (Malvar et al.
eq. 1, same offsets). Fig. 30's 3×3 neighbourhood (B G B / G R G / B G B) is the correct RGGB
tiling around R. PS2's `interp2d` route and `np.roll` hint for green: confirmed (PS2 slide 15).

**§10.2 — Bayer aliasing claim + Fig. 31:** red samples every 2nd column, so its Nyquist limit is
0.25 cycles/px. A 0.4 cycles/px pattern aliases to |0.4 − 0.5| = 0.1 cycles/px (period 10 px), and
the two agree at every even column. Confirmed (Wikipedia Nyquist frequency: 0.5 cycles/sample and
the alias/folding description). All 9 table rows re-derived. **Fig. 31:** every plotted point was
checked against x = 70 + 52·col, y = 115 − 75·value. The solid curve is cos(2π·0.4·col) and the
dashed curve cos(2π·0.1·col). The 6 amber dots (even columns) lie on both curves, the 5 hollow dots
on the true stripes only, and the shaded bands are centred on even columns. The caption and the
§10.2 text match. Two birefringent layers spreading each point into four: confirmed (Wikipedia
Anti-aliasing filter: "two layers of birefringent material such as lithium niobate, which spreads
each optical point into a cluster of four points").

**§10.3:** the BT.601 coefficients (65.481, 128.553, 24.966; −37.797, −74.203, 112.0; 112.0,
−93.786, −18.214), K_R = 0.299, K_B = 0.114, and Cb/Cr as blue/red-difference chroma: confirmed
(Wikipedia YCbCr). The scale factors 112/0.886 = 126.41 and 112/0.701 = 159.77, and their products
(e.g. −0.299 × 126.41 = −37.797), were re-derived. Worked example: gray gives Y′ 125.5 and Cb = Cr =
128; red gives Y′ 81.481, Cb 90.203, Cr 240. Re-derived. The "size 9" median filter on Cb/Cr:
confirmed (PS2 slide 17). **Chroma acuity coarser than luminance:** confirmed (Mullen 1985;
Wikipedia Chroma subsampling).

**§10.3.1 — claims + Fig. 32:** over a 16-px window, the hard step's |F|/N is 1/(16·sin(πk/16)) for
odd k: 0.3204, 0.1125, 0.0752, 0.0637, with 0 for even k and DC 0.5. The cosine bump gives 0.5 and
0.25. All re-derived. 3-tap average 0 0 0 1 1 1 → 0 0 0.333 0.667 1 1, so a 1-step rise becomes a
3-step rise: re-derived. **Fig. 32:** bar heights (0.333·130 = 43.3, etc.), step brackets (index
2→3 and 1→4) and spectrum bars (200 px per unit; x step 58.75 px per 1/16) all match the table.
White noise has equal expected power across frequency bands (theory: variance 0.01 in each half).

**§10.5:** eq. (2)–(5) and α = 1/2, β = 5/8, γ = 3/4, obtained as a Wiener (minimum-MSE) solution on
the Kodak set and then approximated by small powers of ½: confirmed (paper §3.2). "Only 4 unique"
filters and "many multiplications are factors of 2": confirmed (PS2 slide 21). The notes' "dyadic
rationals" wording is consistent with this.

**§10.6:** MSE = (1/3mn)ΣΣΣ[…]², PSNR = 10·log₁₀(max²/MSE), and "Calculate PSNR after applying
gamma correction": confirmed verbatim (PS2 slide 14).

**§11.1:** the normalized weighted-average form matches Wikipedia's bilateral-filter definition
(W_p normalizer).

**§11.2:** w = exp(−|x−x′|²/2σ²); at distance σ the weight is exp(−½) = 0.6065. **σ_f = 1/(2πσ):**
confirmed (Wikipedia Gaussian filter). Script-check table re-derived: σ_f = 0.1592 / 0.0796 /
0.0398; half-amplitude f = √(ln2/(2π²))/σ = 0.1874 / 0.0937 / 0.0468. The σ = 1 px deviation
7.2 × 10⁻³ equals the aliased tail 2·G(0.5) − G(0.5) = exp(−π²/2) = 0.0072 at f = 0.5, and σ = 2
gives exp(−2π²) = 2.7 × 10⁻⁹. Both match the table exactly.

**§11.3:** the median filter is nonlinear and robust to outliers. Standard.

**§11.4 — claims + Fig. 34:** the formula, "non-linear, edge-preserving, and noise-reducing" and
the Tomasi & Manduchi 1998 attribution: confirmed (Wikipedia Bilateral filter; PS2 slides 24–26).
Worked table re-derived: weights 0.1353 / 0.6065 / 1; intensity weights 0.980 / 0.783 /
6.1 × 10⁻¹⁴ / 1.1 × 10⁻¹⁵; normalizers 2.4837 and 1.6074; outputs 0.3375 and 0.0977. Also
re-derived: the left-shifted normalizer 2.0100; the doubled-input output 0.2127; and σ_i = 0.25 →
0.0971, σ_i = 1 → 0.2879. The σ_r → ∞ limit reduces to the Gaussian (re-derived). Fig. 34 is
schematic and consistent.

**§11.5 — claims + Fig. 35:** Buades et al. 2005, patch-similarity weights, and a search window for
cost: confirmed (Wikipedia Non-local means; PS2 slide 27). PS2 refinements (a) exclude the window
centred on the current pixel, (b) "Weight the center pixel with the maximal weight seen in the
neighborhood", (c) Gaussian k_mn weighted norm: all confirmed verbatim (PS2 slide 29, the slide the
notes cite as "~29"). Fig. 35 matches.

**§11.6:** comparison table, consistent with the confirmed definitions above.

**§11.8 — claims + Fig. 36:** sharpened = original + amount·(original − blurred), with overshoot and
halos at edges. Confirmed (Wikipedia Unsharp masking). Gaussian worked example re-derived with a
radius-3 σ = 1 kernel: blur 0.2027 / 0.2351 / 0.3803 / 0.6197 …, sharpened 0.0197 / 0.9803. With the
bilateral filter (σ_i = 0.1) on a clean 0.6 step, the cross-edge weight is exp(−18) ≈ 1.5 × 10⁻⁸,
so the detail layer is effectively 0 and there is no halo. **Fig. 36:** points checked against
y = 230 − 180·value (0.0197 → 226.5, 0.9803 → 53.5, 0.1649 → 200.3, …), all correct.

**§12:** "Scale pixel values to [0, 1] first; apply I → I^(1/2.2)": confirmed (PS2 slide 11). sRGB
piecewise constants (0.0031308, 12.92, 1/2.4, 0.055): confirmed (Wikipedia sRGB). Mid-gray
example: 0.18^(1/2.2) = 0.4587 (code 117), sRGB 0.4614 (code 118), linear code 46. Re-derived.

**§13 (other than items 1–2) — claims + Fig. 38:** sRGB→XYZ matrix [0.4124 0.3576 0.1805; 0.2126
0.7152 0.0722; 0.0193 0.1192 0.9505]: confirmed (Wikipedia sRGB; IEC draft eq. 5). The luminance
row sums to 1. Clipping (0, 1, 0) gives xy (0.3000, 0.6000) and Y 0.7152: re-derived. Compression
figures: re-derived (item 2). **Fig. 38:** all coordinates checked. Left panel: x = 50 + 300·x,
y = 310 − 300·y, and all six primaries placed correctly. Zoom panel: 1833.3 px per unit x, 1227.3
px per unit y, with P3 green (442.5, 76.8), sRGB green (506.7, 187.3) and the compressed point
(477.9, 256.5). The compressed point lies on sRGB's G–B edge. The compression arrow points along
the line to D65, as a blend toward same-luminance gray should. The axis labels are correct.

**§14:** Cb/Cr subsampled because of lower color acuity. 4:4:4 / 4:2:2 (half horizontal) / 4:2:0
(half both ways) are defined correctly, and 4:2:0 is used by "most common JPEG/JFIF"
implementations. Confirmed (Wikipedia Chroma subsampling).

**Figure numbering:** Fig. 28–38 are sequential in document order, and every in-text reference
(Fig. 29 in §5/§7, Fig. 31 in §10.2, Fig. 32 in §10.3.1, Fig. 36 in §11.8, Fig. 38 in §13) points
at the right figure.

**Wikipedia links:** `CIE_1931_color_space#CIE_standard_observer`, `Luminous_efficiency_function`,
`SRGB`, `DCI-P3`, `YCbCr`, `Chroma_subsampling`, `Nyquist_frequency`, `Gaussian_filter` (related to
the `Gaussian_blur` link), `Bilateral_filter`, `Non-local_means`, `Unsharp_masking`,
`Clipping_(photography)` (covers out-of-gamut clipping), `Foveon_X3_sensor`, `Three-CCD_camera` and
`Thermographic_camera` were fetched and match the concepts they are attached to. The remaining
week-3 links (e.g. `Rec._601`, `Luma_(video)`, `Acutance`, `Overshoot_(signal)`,
`Ringing_artifacts`, `Middle_gray`, `ColorChecker`, `Colorfulness`, `Wagon-wheel_effect`) were
checked by title only, not fetched. See the corrected item 7 for the two dead anchors.

---

## Unverifiable claims

1. **"The lecture slide says 12 people" (§3, slide 39).** Could not re-check: the Lecture 3 deck
   exceeds the fetch limit. No external source found that gives 12. The standard counts (10 + 7)
   are confirmed. Attribution kept, with the standard counts stated alongside.
2. **Other Lecture-3-slide-specific quotes and attributions:** slide 49 ("RGB values have no
   meaning…"), slide 50 (2D-vs-3D caveat), slide 71 ("(too) high-frequency"), slide 83 ("remove
   noise but retain high-frequency detail"), slide 86 ("Gaussian low-pass filter"), slide 98
   (σ_s 2/6/18, σ_r 0.1/0.25/∞), slide 100 (bilateral vs. Gaussian sharpening), the gamut-mapping
   slide ("camera XYZ", modes), the slide-73 Y′CbCr note, the lecture's "roughly γ = 2.2",
   Heide et al. 2016 (§15), and the closing-slide list (§16). None of these could be re-read this
   run. The technical content each quote supports is confirmed independently above where
   applicable.
3. **§10.4 edge-directed interpolation:** the Gunturk et al. 2005 citation and the lecture's three
   "stepping stone" bullets. Lecture-only framing; not re-checked.
4. **§12 "HW2 explicitly leaves the choice [of gamma form] open".** The HW2 handout was not
   available. PS2 shows only the 1/2.2 form.
5. **§10.3.1 seeded white-noise numbers (0.00970 / 0.01021).** A script result that cannot be
   reproduced without the seed. The expected value (0.01 in each half) is confirmed by theory.
6. **§10.2 OLPF details:** the infrared-blocking layer, "hot-rodding", and (markdown only) models
   sold with and without an OLPF. The fetched Wikipedia article does not cover these.
7. **§8:** germanium optics for thermal IR (the fetched article does not discuss lens materials),
   and the field-sequential capture description (not independently sourced this run).
8. **§9 / §11.7:** Exif field list, the 5-stage pipeline order, and the BM3D description were not
   independently fetched this run.

---

## Addendum — 2026-09-24: new §9.1, §10.1, §10.3, §11.5 passages and glossary entries

**Scope:** only the newly added passages: §9.1 "Opening a real camera RAW file (HW2 bonus)",
the §10.1 `interp2d` library warning, the §10.3 skimage `rgb2ycbcr` library note, the §11.5
"Translating HW2's notation into these notes'" table and paragraph, and the glossary entries
RAW file / dcraw, Black level / white level, White balance, and NLM filtering parameter *h* /
normalizer *Z(i)*.

**Summary: 27 claims audited — 25 confirmed / 2 corrected.**

Corrected claims:
1. **§9.1 dcraw table, `-D`:** "Output the mosaic totally unprocessed: no black subtraction,
   scaling, demosaicking or color" → "Output the mosaic with no black subtraction, scaling,
   demosaicking or color conversion. The gamma curve and automatic brightening applied when the
   file is written still happen unless `-4` is added". In dcraw.c 9.28, `-D` only skips
   `scale_colors()`, demosaicking and the color matrix. `write_ppm_tiff()` still applies the
   99th-percentile auto-brightening and the default 2.222/4.5 gamma curve to every output
   (`-4` = `-6 -W -g 1 1` turns both off).
2. **§9.1 dcraw table, `-d`:** "with black-level subtraction and scaling applied" → "with
   black-level subtraction and scaling (including the white-balance multipliers) applied".
   In `scale_colors()`, `scale_mul` combines the white-balance multipliers `pre_mul` with the
   65535/(maximum − black) scaling.

Confirmed claims:
- **dcraw options** (usage text in dcraw.c v9.28, rev. 1.478): `-i -v` "Identify files and show
  metadata". Verbose identify prints Camera, Filter pattern, Daylight and Camera multipliers.
  `-4` "Linear 16-bit, same as -6 -W -g 1 1". `-T` "Write TIFF instead of PPM". Document mode
  writes `.pgm`, so "PPM/PGM" is correct. `-w` "Use camera white balance, if possible".
  `-o 0` = raw color space. `-q 0` → `lin_interpolate()` (bilinear), 1 VNG, 2 PPG, 3 AHD.
- **dcraw default output** applies auto-brightening (unless `-W`), gamma 2.222/4.5, the sRGB
  matrix (`output_color=1`) and AHD demosaicking (`quality = 2 + !fuji_width` = 3). Confirmed
  from the source.
- **rawpy attributes** `raw_image_visible`, `raw_pattern`, `black_level_per_channel`,
  `white_level` and `camera_whitebalance` all exist with the stated meanings (rawpy API docs).
  LibRaw's processing methods are "inherited from Dave Coffin's dcraw.c" (libraw.org/about).
- RAW extensions (CR2/CR3, NEF, ARW, DNG); 12–14-bit values. Black-level pedestal. Normalizing
  by (white − black). White balance as a diagonal matrix. Camera RGB → sRGB as a 3×3 change of
  basis. Pipeline order. Confirmed (Wikipedia Raw image format, Color balance; dcraw.c order:
  scale_colors → demosaic → convert_to_rgb → gamma on output).
- **§10.1 SciPy:** on SciPy 1.18.1, calling `interp2d` raises `NotImplementedError`: "`interp2d`
  has been removed in SciPy 1.14.0 … nearly bug-for-bug compatible replacements are
  `RectBivariateSpline` on regular grids". `RectBivariateSpline(kx=1, ky=1)` matched
  `RegularGridInterpolator(method="linear")` exactly (max difference 0.0) on a random 4×4 grid.
  With `bounds_error=False, fill_value=None`, `RegularGridInterpolator` returned 25.0 for a
  linear plane at an out-of-grid point (exact value 25), so it extrapolates linearly.
  `griddata(method="linear")` handles scattered (checkerboard) samples. Confirmed.
- **§10.3 scikit-image 0.26.0 `rgb2ycbcr`:** over all 8 RGB-cube corners (an affine map reaches
  its extremes at vertices), Y′ ∈ [16, 235] and Cb, Cr ∈ [16, 240]. Gray gives Cb = Cr = 128.
  Red (1, 0, 0) gives (81.481, 90.203, 240.000). The `ycbcr2rgb` round trip has a max error of
  2.8 × 10⁻¹⁶. Confirmed.
- **§11.5 Buades, Coll & Morel, CVPR 2005 ("A non-local algorithm for image denoising", §3):**
  w(i, j) = (1/Z(i))·exp(−‖v(N_i) − v(N_j)‖²₂,ₐ / h²), with Z(i) the normalizing sum and h "a
  degree of filtering". The distance is a "weighted Euclidean distance" with "a > 0 … the
  standard deviation of the Gaussian kernel", so the original paper does use a Gaussian-weighted
  patch distance. exp(−d²/h²) = exp(−d²/(2σ²)) ⇔ h² = 2σ². Algebra confirmed. Here σ is the
  weight-width symbol in these notes' formula, not the noise σ in the paper's
  E‖·‖² = ‖·‖² + 2σ² identity. The paper sets h proportional to the noise level (h = 10σ for
  its Gaussian-weighted distance). This supports the notes' qualitative "scale of *h*"
  paragraph. The notes give no specific value, per the homework rule.
- **Wikipedia links:** `Raw_image_format`, `Dcraw` and `Color_balance` resolve to matching
  articles.

Sources: dcraw.c v9.28 (mirror of Dave Coffin's source, github.com/ncruces/dcraw; the
dechifro.org original failed TLS verification from this machine),
https://letmaik.github.io/rawpy/api/rawpy.RawPy.html, https://www.libraw.org/about, the installed
SciPy 1.18.1 and scikit-image 0.26.0, the Buades–Coll–Morel CVPR 2005 PDF, and Wikipedia.

**Uncertain / not checked:** what the HW2 and PS2 handouts themselves say (that `interp2d` is
suggested, HW2's exact weight formula and notation, HW2 applying YCbCr to linear data). The
handouts were not available.
