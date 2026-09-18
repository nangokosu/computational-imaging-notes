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

---
---

# Week 3 Audit — 2026-09-18

**Last audited:** 2026-09-18

**Scope:** `week3-study-notes.md` (full file), the `## Week 3` section of `glossary.md`, and the
`<section class="week-block" id="week-3" ...>` block plus the `#glossary-week-3` `.week-card` of
the live published artifact (https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0),
including all 6 of that block's diagrams (Fig. 28–33). Weeks 1 and 2 were intentionally **not**
re-audited this run. Primary verification used the actual CSC2529 Lecture 3 slide deck
(`cs.toronto.edu/~lindell/teaching/2529/slides/lecture3.pdf`, 129 slides, extracted and rendered
directly, including its "References and Further Reading" slide), the Malvar/He/Cutler 2004 paper
via its IPOL reimplementation writeup, and independent sources (Wikipedia, direct web search) for
every cited paper, standard, and numeric constant.

**Summary: 42 claims/diagrams audited — 39 confirmed / 2 corrected / 1 unverifiable-category
(several individual PS2-sourced implementation details, listed together below).**

Corrected items (one line each):
1. §10.3's Y′CbCr matrix carried a note saying the lecture's own slide "survived PDF extraction
   with its exact numeric coefficients garbled" — the slide has now been read directly (rendered
   as an image) and its matrix **confirmed** to match the standard BT.601 matrix already given;
   the uncertainty note is replaced with a confirmation note (`week3-study-notes.md` only — the
   artifact never carried this caveat).
2. §10.5's claim that Malvar-He-Cutler's filter coefficients are "**exact powers of two**" →
   corrected to "**dyadic rationals**" (fractions with a power-of-2 *denominator*, e.g. 3/4, 5/8,
   3/2 — not powers of two themselves), matching the IPOL reimplementation's own description
   ("rounded to dyadic rationals ... integer arithmetic and bitshifting") and the actual published
   gains (β=5/8, γ=3/4 are not powers of two). Corrected in **both**
   `week3-study-notes.md` and the artifact's `week-3` block.

**Drift observed (not corrected — both sides defensible):** §2/`week-3-s2`'s "lasso curve" bullet
list states the curve "starts and ends **at** the origin" in `week3-study-notes.md`, but "starts
and ends **near** the origin" in the artifact. The lecture's own slide (23) says "starts and ends
at origin" verbatim, so the markdown's wording matches the primary source more literally; the
artifact's "near" is arguably the more physically precise statement (cone sensitivity curves are
asymptotic, never exactly zero at any finite wavelength). Neither is factually wrong, so left as
is — flagged here as a genuine (if minor) inconsistency between the two files rather than silently
resolved.

No other drift was found: every other claim and diagram checked said/showed the same thing in
`week3-study-notes.md`, the Week 3 glossary section, and the artifact's week-3 block/glossary card.

---

## Corrected claims (detail)

### 1. §10.3 — Y′CbCr conversion matrix, reconstruction-uncertainty note resolved

- **Claim as found:** a footnote in `week3-study-notes.md` said the lecture's own slide for the
  RGB↔Y′CbCr matrix "survived PDF extraction with its exact numeric coefficients garbled" and that
  the given matrix (Y′=16+65.481R+128.553G+24.966B, etc.) was "reconstructed from the known
  standard rather than read cleanly off the slide."
- **Verdict: Corrected (resolved to Confirmed).** Lecture 3 slide 73 was rendered directly as an
  image (not run through sparse text extraction) and reads clearly: `M` = [65.48, 128.55, 24.97;
  −37.80, −74.20, 112.00; 112.00, −93.79, −18.21], with the whole product scaled by 257/65535 and
  offset by [16;128;128], for R,G,B on a 0–255 scale. Since 255×257 = 65535 exactly, 257/65535 =
  1/255, so this is algebraically identical to the standard BT.601 form for R,G,B∈[0,1] already
  given in the notes, just re-expressed for 8-bit inputs. Internal consistency check: BT.601's Y′
  row must sum to 219.000 (the code range 16–235 spans 219 levels); the slide's own row sums to
  65.48+128.55+24.97 = 219.00, confirming the third coefficient is 24.97 (not a mis-OCR'd "24.87").
  The matrix independently matches the ITU-R BT.601 standard (Poynton, *Digital Video and HD*,
  eq. 9.6) via a separate web search.
- **Before → after (`week3-study-notes.md` §10.3 only):** the "Reconstruction note" callout, which
  flagged the matrix as unverified, is replaced with a "Fact-audit note" confirming the match
  against the rendered slide, including the 257/65535 = 1/255 identity and the 219.00 sum check.
- **Sources:** [CSC2529 Lecture 3 slides, p. 73](https://www.cs.toronto.edu/~lindell/teaching/2529/slides/lecture3.pdf) (rendered directly), [ITU-R BT.601 RGB↔YCbCr coefficients, cross-checked via web search](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/36417/versions/1/previews/YUV/rgb2yuv.m/index.html), arithmetic check (255×257=65535; 65.48+128.55+24.97=219.00).

### 2. §10.5 — Malvar-He-Cutler filter coefficients: "powers of two" → "dyadic rationals"

- **Claim:** "many of the filter coefficients that fall out of this derivation are **exact powers
  of two** — which, in fixed-point hardware, means a multiplication can be implemented as a cheap
  **bit-shift** instead of a general multiply."
- **Verdict: Corrected.** The published gains themselves are α=1/2 (a power of two, single-shift
  friendly) but β=5/8 and γ=3/4 are **not** powers of two — they are dyadic rationals (numerator×
  2⁻ⁿ), which need a shift-and-add, not a single bit-shift, to implement. The IPOL reimplementation
  of this exact method states explicitly that the coefficients were "computed to produce the
  minimum mean squared error ... then rounded to **dyadic rationals** to enable efficient
  implementation using integer arithmetic and bitshifting" — "dyadic rational," not "power of two,"
  is the precise term, and the lecture's own filter-kernel slide (79) shows values like 6, −3/2,
  and 2 that are not themselves powers of two either.
- **Before → after (both `week3-study-notes.md` §10.5 and the artifact's `week-3-s10` §10.5 "PS2's
  practical framing" paragraph):** "exact powers of two ... a cheap bit-shift instead of a general
  multiply" → "**dyadic rationals** — fractions with a power-of-two denominator (e.g. 1/2, 3/4,
  5/8, 3/2), not necessarily powers of two themselves ... cheap bit-shifts **and additions**
  instead of a general multiply."
- **Sources:** [Malvar-He-Cutler Linear Image Demosaicking, IPOL Journal](http://www.ipol.im/pub/art/2011/g_mhcd/revisions/2011-08-14/g_mhcd.htm) (fetched directly), [CSC2529 Lecture 3 slides, pp. 78–79](https://www.cs.toronto.edu/~lindell/teaching/2529/slides/lecture3.pdf) (rendered directly).

---

## Confirmed claims and diagrams

*(Grouped by section; source(s) given for each. Numeric/formula claims were checked against the
actual rendered lecture slides and/or an independent external source, not merely against
plausibility.)*

**§1 (spectral sensitivity function):** R = ∫Φ(λ)f(λ)dλ, SSF/SPD definitions — confirmed verbatim
against Lecture 3 slide 20, which states the identical formula and "weighted combination" framing.
[Spectral sensitivity](https://en.wikipedia.org/wiki/Spectral_sensitivity) and
[Spectral power distribution](https://en.wikipedia.org/wiki/Spectral_power_distribution) links
independently fetched and confirmed to resolve to the matching concepts.

**§2 (tristimulus color space / lasso curve) — Fig. 28:** "lasso curve" name, confinement to the
positive octant, starting/ending near the origin, never approaching the M axis, and — on varying
intensity — sweeping out a convex radial cone with a "horseshoe" cross-section, plus metamerism as
many-spectra-to-one-point — confirmed directly against Lecture 3 slides 22–26, which use this exact
terminology and show the identical 3D construction (a bounded lasso curve in S/M/L space, then a
convex cone swept by scaling intensity, then a "horseshoe" radial cross-section). **Diagram (Fig.
28):** the axonometric sketch's three axes (M up, S down-left, L down-right) meeting at an origin,
a closed lasso curve confined to the positive octant and bulging away from the M axis toward the
S–L region, and two dashed rays from the origin through lasso points (suggesting the cone) — this
matches the slide's own layout (M/S/L axis labels, closed curve bulging away from M) in construction
and correctly follows from the underlying non-negativity/convex-combination math described in the
same section; captioned accurately as "schematic," which it is (not to measured/plotted LMS data).
(See "Drift observed" above for the one wording nuance found in this section.)

**§3 (CIE color matching):** primaries/test-light split-field setup, adjusting primary strengths
until metameric to the test light, and the "add to the test side instead of subtracting" mechanism
for negative coefficients — confirmed directly against Lecture 3 slides 29–32, including the
"equality symbol means 'has the same retinal color as' / 'is metameric to'" annotation, which the
notes and artifact both reproduce essentially verbatim. [CIE 1931 color space#Color matching
functions](https://en.wikipedia.org/wiki/CIE_1931_color_space#Color_matching_functions) anchor
confirmed to exist and cover this exact topic.

**§4 (CIE RGB vs. CIE XYZ):** CIE RGB has physically realizable primaries but needs negative
coordinates for some real colors; CIE XYZ guarantees non-negative coordinates but its "primaries"
are not physically realizable — confirmed directly against Lecture 3 slides 36–38 and 51 ("CIE XYZ
only needs positive coordinates, but need primaries with negative light. sRGB must use physical
(non-negative) primaries, but needs negative coordinates for some colors."). "No basis can have
both" framed as a geometric fact about the achievable-color cone, not an arbitrary limitation —
consistent with the same slide's "Fundamental problem" framing.

**§5 (CIE xy chromaticity):** x=X/(X+Y+Z), y=Y/(X+Y+Z), and the "perspective projection that
discards luminance, keeps chromaticity" framing — confirmed directly against Lecture 3 slides 40–41
(identical formulas and the (X,Y,Z)↔(x,y,Y) framing). [CIE 1931 color space#CIE xy chromaticity
diagram](https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_xy_chromaticity_diagram_and_the_CIE_xyY_color_space)
anchor confirmed to exist and match.

**§6 (color gamuts) — Fig. 29:** three real primaries sweep out a triangle via convex combination;
sRGB's gamut is exactly such a triangle; points outside it need a negative coordinate — confirmed
directly against Lecture 3 slides 43–48, including the "sRGB impossible colors" vs. "sRGB
realizable colors" region labels the notes' framing exactly mirrors. **Diagram (Fig. 29):** the
schematic horseshoe-shaped spectral locus with an inscribed R/G/B triangle and one marked point
outside the triangle but inside the horseshoe — the triangle's approximate corner positions (R
lower-right, G near top, B lower-left) correctly match the real sRGB primaries' rough position on
the CIE diagram (matching Lecture 3 slide 45's own plotted triangle), and the marked "unreproducible"
point sits in the region above/right of the G–R edge, matching where slide 46 labels "sRGB
impossible colors." Caption accurately describes what's drawn and correctly flags the diagram as
schematic/illustrative rather than measured coordinates.

**§7 (synthesis):** restates §4 and §6's already-confirmed claims; no new claim to check.

**§8 (other capture methods):** three-sensor beam-splitter cameras (prism splits light to three
full-resolution sensors) — confirmed against Lecture 3 slide 13 ("Three-CCD Camera," beam-splitter
prism diagram). Foveon X3 vertically-stacked sensor (shorter wavelengths absorbed nearer the
silicon surface, longer wavelengths deeper, letting one stacked pixel register approximate R/G/B)
— confirmed against Lecture 3 slide 14 ("Stacked Sensor," silicon-absorption-by-wavelength chart).
Field-sequential capture (rotating filter wheel, static-scene-only) — confirmed against slide 7
("field sequential"). Near-IR sensitivity of ordinary silicon photodiodes (OmniVision RGB+NIR
example) — confirmed against slides 15–17. Thermal IR requiring non-silicon photodiode materials
(indium-, mercury-, lead-based compounds) and germanium optics — confirmed against Lecture 3 slide
18 and independently via web search (InSb, HgCdTe, PbSe/PbS are the standard IR-detector materials;
germanium/sapphire are standard for IR-transparent optics since silicon and ordinary glass are not).

**§9 (RAW-to-finished-photo pipeline):** demosaicking→denoising→gamut mapping→gamma
correction→compression ordering — confirmed as a reasonable, standard synthesis of the lecture's
own pipeline box-diagram (slides 55, 127: demosaicking→denoising→gamut mapping→compression, with
"…" between boxes) plus its separate stage list (slide 57: demosaicking, denoising, white
balancing/autoexposure, "linear 10/12 bit to 8 bit gamma," compression) — no single slide states
this exact 5-stage linear order with gamma placed between gamut mapping and compression, so this is
the notes' own defensible synthesis rather than a verbatim-quoted lecture sequence; not
contradicted by anything in the slides. Exif metadata contents (exposure, aperture, ISO, timestamp,
lens) — confirmed against the worked Exif-data slide (54), which lists exactly these fields among
others.

**§10.1 (naive interpolation) — Fig. 30:** four-orthogonal-neighbor green-averaging formula and
offsets — confirmed directly against Lecture 3 slide 62, which gives the identical formula
ĝ_lin(x,y)=¼Σg(x+m,y+n) over the same four (m,n) offsets. **Diagram (Fig. 30):** the 3×3
Bayer-pattern neighborhood (B G B / G R G / B G B centered on R, orthogonal neighbors green,
diagonal neighbors blue) is the geometrically correct RGGB tiling around a red pixel and matches
the standard Bayer CFA structure shown in Lecture 3 slide 6; caption accurately describes the
four-neighbor averaging construction shown.

**§10.2 (OLPF):** two birefringent layers + IR-blocking filter splitting one ray into four (a 4-tap
optical convolution kernel), the resolution/aliasing trade-off, and "hot-rodding" — confirmed
directly against Lecture 3 slides 65–69, matching essentially verbatim (including the D800/D800E
identical-camera-with/without-OLPF example). [Optical low-pass filter](https://en.wikipedia.org/wiki/Optical_low-pass_filter)
and [Birefringence](https://en.wikipedia.org/wiki/Birefringence) links confirmed to resolve
correctly.

**§10.3 (chrominance low-pass demosaicking):** procedure (naive-demosaic → RGB→Y′CbCr → median-
filter Cb/Cr only → back to RGB) — confirmed against Lecture 3 slides 70–74. Y′CbCr matrix — see
Corrected item #1 above (now fully confirmed against the rendered slide).

**§10.4 (edge-directed interpolation, Gunturk et al. 2005):** 3×3→5×5 neighborhood progression and
the three "insights carried forward" (larger neighborhood helps but costs more; cross-channel
gradient info helps; nonlinear is okay but a well-designed linear filter can do better) — confirmed
directly against Lecture 3 slides 75–77 (identical three bullet points). Citation "Gunturk et al.
2005" — confirmed via Lecture 3's own "References and Further Reading" slide (129): "Gunturk,
Glotzbach, Alltunbasak, Schafer, 'Demosaicking: Color Filter Array Interpolation', IEEE Signal
Processing Magazine 2005."

**§10.5 (Malvar-He-Cutler 2004) — Fig. 31:** the three interpolation-case formulas, the discrete-
Laplacian gradient term D_R(x,y), and the published gain constants α=1/2, β=5/8, γ=3/4 — confirmed
directly against Lecture 3 slide 78, and independently against the IPOL reimplementation of the
original paper. Citation "Malvar, He & Cutler (2004)" — confirmed via Lecture 3's References slide:
"Malvar, He, Cutler, 'High-quality Linear Interpolation for Demosaicing of Bayer-patterned Color
Images', Proc. ICASSP 2004." "4 unique filter shapes" — the underlying symmetry (G-interpolation
one shape; R/B-at-green-in-row-matching one shape; R/B-at-green-in-column-matching one shape;
diagonal R-at-B/B-at-R one shape, with R↔B and row↔column swaps accounting for the rest) is visibly
consistent with the six filter-kernel diagrams shown on Lecture 3 slide 79, though the specific
attribution to "PS2" itself is Unverifiable (see below) since PS2's own slide deck was not
available to check directly. Dyadic-rational/bit-shift claim — see Corrected item #2 above.
**Diagram (Fig. 31):** the 5×5 Bayer neighborhood centered on a red pixel, with the four orthogonal
green neighbors (1 px away, used in ĝ_lin) and the four axial red neighbors (2 px away, used in
D_R) distinctly highlighted, correctly corresponds to every symbol named in the D_R formula in the
same subsection (r(x,y), the four (m,n)={(0,±2),(±2,0)} offsets) and to Lecture 3 slide 79's own
"G at R locations" filter kernel (a cross-shaped kernel with taps at 1- and 2-pixel offsets).
Caption accurately describes the construction shown.

**§10.6 (PSNR/MSE):** MSE = (1/3mn)ΣΣΣ[...]², PSNR = 10·log₁₀(max²/MSE), and the log/dB-scale
rationale — standard, widely-documented error metrics; confirmed via general signal-processing
reference conventions (consistent with, e.g., the [Peak signal-to-noise ratio](https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio)
Wikipedia page's own formula). "PSNR computed after gamma correction" as HW2's specific practice —
Unverifiable (HW2's own assignment text was not directly available to check; see below).

**§11.1 (denoising general framework):** i_denoised(x)=(1/normalizer)Σw(x,x′)i_noisy(x′) and the
four-family taxonomy (local linear, local nonlinear, anisotropic diffusion, non-local) — confirmed
directly against Lecture 3 slides 83–84 (identical formula and identical four-item list).

**§11.2 (Gaussian filtering):** w(x,x′)=exp(−|x−x′|²/2σ²) — confirmed directly against Lecture 3
slide 85.

**§11.3 (median filtering):** i_denoised(x)=median(W(i_noisy,x)) — confirmed directly against
Lecture 3 slide 86.

**§11.4 (bilateral filtering) — Fig. 32:** the product-of-two-Gaussians weight formula and the
"edge-aware smoothing" framing — confirmed directly against Lecture 3 slides 91–95 (identical
formula, identical step-edge worked example, identical "digital pore removal" and "cartoonization"
application examples). Citation "Tomasi & Manduchi, 1998" — independently confirmed via web search:
C. Tomasi & R. Manduchi, "Bilateral Filtering for Gray and Color Images," ICCV 1998, matches the
attribution on Lecture 3 slide 93 exactly. **Diagram (Fig. 32):** the two 1D step-edge plots
(Gaussian kernel straddling the edge → blurred ramp output; bilateral intensity-weight term
collapsing from ≈1 to ≈0 across the edge → step-preserving output) is an original construction (not
a copy of the slide's own 2D-image demonstration) but correctly and consistently illustrates the
identical underlying mechanism the same subsection's formula describes — every quantity the prose
names (spatial Gaussian, intensity-difference Gaussian, same-side vs. cross-edge weight) has a
labeled counterpart in the figure, and it does not contradict Lecture 3 slides 89–91's own
demonstration of the same effect with a real image. Caption accurately describes both panels.

**§11.5 (non-local means) — Fig. 33:** patch-similarity weight formula w(x,x′)=exp(−‖N(x′)−N(x)‖²/
2σ²), the "self-similarity, not spatial proximity" framing, and the bounded-search-window rationale
— confirmed directly against Lecture 3 slides 108–110. Citation "Buades, Coll & Morel, 2005" —
independently confirmed via web search (Antoni Buades, Bartomeu Coll, Jean-Michel Morel, "A
non-local algorithm for image denoising," CVPR 2005) and via Lecture 3's own References slide
("Buades, Morel, 'A non-local algorithm for image denoising', CVPR 2005" — the References slide
itself abbreviates to two names, but the full three-author citation the notes/artifact give is the
paper's actual, correct authorship). PS2 implementation refinements (a: exclude self-patch from
search; b: reassign self-patch the max neighbor weight; c: Gaussian-weighted patch distance) —
Unverifiable as specific PS2 attributions (see below), though (c)'s general technique (a
center-weighted patch distance) is a standard, well-documented NLM refinement. **Diagram (Fig.
33):** the image-plane schematic (bounded dashed search window, several candidate patches at
varying opacity representing weight, a crossed-out self-centered patch) correctly illustrates the
prose's description that weight depends on patch similarity rather than spatial distance, and does
not contradict Lecture 3 slide 108's own real-image demonstration of the same concept (colored
boxes over a rendered building scene). Caption accurately describes what's drawn.

**§11.6 (comparison table):** Gaussian/bilateral/non-local-means "depends on" and "behavior near
edges" summary — confirmed directly against Lecture 3 slide 111 ("Everything put together"), which
states the identical three-way comparison nearly verbatim.

**§11.7 (BM3D):** "find similar patches, stack into 3D blocks, DCT-transform, threshold
coefficients, invert" — confirmed directly against Lecture 3 slides 112–113. Citation "Dabov et
al." — confirmed via Lecture 3's References slide: "Dabov, Foi, Katkovnik, Egiazarian, 'Image
denoising by sparse 3D transform-domain collaborative filtering', IEEE Trans. Im. Proc. 2007."

**§12 (gamma correction):** human luminance sensitivity "roughly γ≈2.2" — confirmed directly
against Lecture 3 slide 114 ("sensitivity to luminance is roughly γ=2.2"). PS2's simplified
I_out=I_in^(1/2.2) form — consistent with, though not verbatim quoted from, the same slide's "roughly
equivalent to γ=2.2" framing (the specific PS2-sourced formula itself is Unverifiable — PS2's own
materials were not directly available). sRGB piecewise formula and every constant (threshold
0.0031308, slope 12.92, exponent 1/2.4, α=0.055) — confirmed **exactly**, both against Lecture 3
slide 116 (identical piecewise formula) and independently via the [sRGB](https://en.wikipedia.org/wiki/SRGB)
Wikipedia page's own OETF formula.

**§13 (gamut mapping):** camera-native XYZ → CIE XYZ → sRGB conversion chain, and different
gamut-mapping strategies corresponding to camera color "modes" — confirmed directly against Lecture
3 slide 111 ("Gamut Mapping": "Internally, we transform from camera XYZ->CIE XYZ and eventually
sRGB" and "different ways of projecting the colors lead to different camera modes").

**§14 (JPEG compression):** six-stage pipeline (Y′CbCr → chroma subsample → 8×8 blocks → DCT →
quantize → entropy/RLE code) and the three named subsampling ratios (4:4:4 no downsampling, 4:2:2
horizontal-2×, 4:2:0 both-directions-2×) — confirmed directly against Lecture 3 slides 118–125
(identical six-step list and identical ratio definitions). "4:2:0 ... the most common default" —
independently confirmed via web search (4:2:0 is the standard default for JPEG and most consumer
video codecs).

**§15 (deconvolution preview):** single-slide preview, Heide et al. 2016 example image, and the
blur-source list (defocus, geometric distortion, spherical aberration, chromatic aberration, coma)
— confirmed directly against Lecture 3 slide 81, which lists exactly these five sources and cites
"Heide et al. 2016" under the same blurred/deblurred lizard-image example.

**§16 (looking ahead):** "sampling, filtering, deconvolution, sparse image priors" — confirmed
directly, verbatim, against Lecture 3's closing slide 128 ("Next: Math Review").

**Wikipedia links (spot-checked beyond the topical checks above):** [Image processor](https://en.wikipedia.org/wiki/Image_processor)
(confirmed to be specifically about camera ISPs, covering Bayer transform/demosaicing/noise
reduction/sharpening — correct target for the "ISP pipeline" glossary entry), [SRGB](https://en.wikipedia.org/wiki/SRGB)
(confirmed, matches exactly), [Spectral power distribution](https://en.wikipedia.org/wiki/Spectral_power_distribution)
(confirmed). `Demosaicing`, `Bayer_filter`, `YCbCr`, `Bilateral_filter`, `Non-local_means`,
`Block-matching_and_3D_filtering`, `Gamut`, `Exif`, `JPEG`, `Discrete_cosine_transform`,
`Chroma_subsampling`, `Deconvolution`, `Three-CCD_camera`, `Foveon_X3_sensor`,
`Thermographic_camera`, `Optical_low-pass_filter`, `Birefringence` were checked by direct inspection
of the article titles/subjects (all standard, unambiguous topic pages) and found to match; not
individually re-fetched beyond that, given they are well-established, unambiguous article titles.

---

## Unverifiable claims

- **Claim:** several small implementation details are explicitly attributed to "PS2" (the TA
  problem session covering HW2) rather than to the lecture itself: the "9×9 median window" size
  in §10.3, the `np.roll`-based green-interpolation shortcut in §10.1, the "4 unique filter shapes"
  count and the dyadic-rational/bit-shift observation in §10.5 (now corrected in wording — see
  above — but still a PS2 attribution), the three non-local-means implementation refinements in
  §11.5 (exclude-self-patch, max-neighbor-weight reassignment, Gaussian-weighted patch distance),
  and the "PSNR computed after gamma correction" claim in §10.6/§12.
  **Verdict: Unverifiable.** PS2's own slide deck/handout was not linked from the course site pages
  fetched for this audit and was not otherwise available to read directly, so none of these
  PS2-specific claims could be independently confirmed or contradicted. This is **not** the same as
  doubting them — several are standard, well-documented techniques in their own right (e.g.
  Gaussian-weighted patch distance is a widely-used NLM refinement, and 9×9 is a plausible median
  window size) — but per this audit's standard, a claim that could not be checked against any
  source is reported as Unverifiable rather than assumed correct. **Not changed** in the markdown,
  glossary, or artifact.
- **Sources consulted (none resolved the PS2 material itself):** the CSC2529 course site's slides/
  reading index (which lists only the lecture PDFs and the Demosaicing/NLM/bilateral-filtering
  readings, not a PS2 deck), and general web search for "CSC2529 problem session 2," which did not
  surface a public PS2 slide deck.
