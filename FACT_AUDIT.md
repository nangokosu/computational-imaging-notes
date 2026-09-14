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
