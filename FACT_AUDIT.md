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

**§12 (exposure, ISO):** Exposure as accumulation time, independent of aperture/ISO — confirmed
via [Exposure (photography)](https://en.wikipedia.org/wiki/Exposure_(photography)) and Lecture 2
slide 119. ISO as pre-ADC analog gain that amplifies noise along with signal — confirmed via
[Film speed](https://en.wikipedia.org/wiki/Film_speed) and Lecture 2 slide 118 ("analog gain
applied before ADC!").

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
