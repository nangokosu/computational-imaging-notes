# CSC2529 Computational Imaging — Week 4 Study Notes

**Topic:** Great Ideas in Computational Photography — HDR Imaging, Tone Mapping, Coded Imaging
**Source:** Lecture 4 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 3 ("PS3," a TA problem session covering HW4), Task 1 only (image filtering: PSF, OTF, primal-domain vs. Fourier-domain filtering).
**Scope:** Announcements, the HW4/project-proposal reminders, and the problem-session plug are skipped — notes start from "Motivation" (the exposure-sequence teaser). PS3's Tasks 2–3 (deconvolution/inverse filtering/Wiener deconvolution, and gradient descent/SGD) are **not** covered here: they belong to the formal inverse-problem material Week 3 §15 already flagged as "genuinely Week 5–6 material," and this file's §21 explains exactly where each piece lands (Wiener deconvolution and inverse filtering in Week 5, "Sampling, Linear Systems, Deconvolution"; gradient descent/SGD in Week 6, "Regularized Inverse Problems with ADMM"). Only PS3's Task 1 is used, since it directly supports this lecture's coded-aperture PSF/OTF material (§13).
**Exam note:** two words get used loosely in this lecture before being pinned down precisely — flagged explicitly where each first appears: (1) "**Exposure**" opens this file meaning "how bright the captured photo looks" (this lecture's own "Gain × Flux × Time" framing, §0) — a *looser* sense than Week 2 §13.1's strict *H* (light energy per unit sensor area), which explicitly **excludes** ISO gain (Week 2 §13.6). (2) "**HDR imaging**" is used to mean five different things across this very lecture, by its own admission — §10 lists and disambiguates all five once the building blocks (§§1–9) are in place to make the distinctions meaningful.

---

# Part 1 — HDR Imaging and Tonemapping

## 0. Motivation: Two Devices That Fall Short of the Real World

A camera doesn't take one perfect picture of a bright, high-contrast scene — it takes a whole *family* of pictures, one per exposure setting, and each one gets some part of the scene right at the expense of another part. The lecture's opening slides show exactly this: the same scene shot at four different exposures (−4 stops, −2 stops, +2 stops, +4 stops — "stops" is the same doubling/halving unit already built in Week 2 §8, §13.3), where the darkest exposure shows only the sky and window detail while the brightest shows only the room's shadows, with everything else clipped to pure white or pure black. Combining that whole family of exposures into one image that correctly represents *every* brightness level in the scene, and then figuring out how to actually *show* that combined image on a screen that can't reproduce anywhere near that range of brightness, are the two problems this lecture is about.

**Recap: what sets the brightness of one exposure.** This lecture's own framing (its "Exposure" slide) states it as:

```
Exposure = Gain × Flux × Time
```

where *Flux* (how much light arrives overall) is controlled by the aperture, *Time* is the shutter speed, and *Gain* is the ISO setting. **This is the loose, "how bright does the photo look" sense of the word** — as the exam note above flags, it deliberately folds ISO gain in. Week 2 §13.1–§13.6 already built the strict physical version in careful detail: exposure *H* = *E*·*t* (irradiance times time, Week 2 §13.2), a physical quantity — light energy landed per unit sensor area — that Week 2 §13.6 explicitly proves ISO does **not** change (ISO only rescales how bright the *already-collected* signal is displayed, amplifying noise right along with it). Nothing about that derivation is redone here; every "aperture/shutter/ISO" mention in this file's Part 1 is this shorthand recap, not a new derivation — see Week 2 §8 (aperture, f-number), §13.2–§13.3 (exposure formula, stops), and §13.6 (ISO as gain, not light) for the full treatment.

**Two challenges, one root cause.** The real world's brightness range vastly exceeds what any single camera exposure or any single display can represent at once (quantified in §2). That single mismatch splits into two genuinely separate engineering problems, which the lecture states explicitly and which structure the rest of Part 1:

1. **HDR imaging** — which parts of the world do we *measure*, in the 8–14 bits available to a sensor? (§§1–6)
2. **Tonemapping** — which parts of the world do we *show*, in the 4–10 bits available to a display? (§§7–9)

The lecture is emphatic that these are "distinct techniques with different goals": **HDR imaging compensates for sensor limitations; tonemapping compensates for display limitations.** Keep them separate while reading §§1–9 — §10 returns to formalize exactly where the boundary between them sits, and why "HDR imaging" so often gets used to mean both at once anyway.

---

## 1. Light Metering

Before a camera can even choose an exposure setting, it has to answer a prior question: *how bright is this scene, overall?* That measurement is **[light metering](https://en.wikipedia.org/wiki/Light_meter)**.

**Where the measurement comes from.** SLR cameras (Week 2's mirror-based design) use a separate, low-resolution sensor placed at the focusing screen, physically distinct from the main image sensor; mirrorless cameras (no mirror to bounce light to a separate screen) simply meter directly off the main sensor's own live feed.

**The 18% "key" assumption.** Whatever the metering sensor measures gets averaged down to a single overall brightness number, and the camera then *assumes* that number corresponds to a scene with **18% reflectance** — the same "mid gray" convention Week 3 §12 already used for its own gamma-encoding worked example (a surface reflecting 18% of the light hitting it, linear value 0.18 on a [0,1] scale). This assumed average brightness is called the **key**. The camera then sets exposure (via aperture, shutter, ISO — Week 2 §13) so that this key lands at the **middle** of the sensor's dynamic range, not at either extreme — the same "correct exposure places the important brightness range between the two failure modes" logic Week 2 §13.4 already built, now applied to a single summary number rather than the whole scene.

**Why "averaging" is not one fixed procedure.** Different scenes should be averaged differently — a backlit portrait and a snow-covered landscape don't want the same weighting — so real cameras offer several distinct averaging strategies:

| Method | What it averages over |
|---|---|
| **Center-weighted** | The whole frame, but weighted to favor the center (where the main subject usually sits) |
| **Spot** | A single small region (e.g., just the subject's face), ignoring the rest of the frame entirely |
| **Scene-specific preset** | A fixed weighting tuned for a named scenario (portrait, landscape, horizon) |
| **"Intelligent"** | A proprietary, manufacturer-specific algorithm (often now leaning on scene recognition) |

**Worked example — why metering can be "fooled."** The 18%-key assumption is exactly *why* a camera pointed at a bright snow field or a white wall tends to render it as a dull gray rather than white: snow reflects far more than 18% of incident light, but the meter still tries to drag the frame's average down to 18% gray, underexposing everything in it. Conversely, a metered photo of a mostly-black scene (a coal pile, a night stage) gets pushed *brighter* than it should look, since the meter is chasing the same 18% target regardless of what the scene actually contains. This is a direct, concrete consequence of the key assumption, not a separate quirk — it is the same "assumed 18% average" rule, just evaluated on a scene that violates the assumption.

---

## 2. The Dynamic-Range Mismatch: World → Eye → Sensor → Image → Display

Week 1 §10 already introduced **[dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)** — the ratio between the brightest and darkest signal a system can represent — for the human eye alone (~14 orders of magnitude across all adaptation states, ~5 instantaneously). This section lays every stage of the imaging pipeline out on the *same* scale, to see exactly where and how much gets lost at each handoff.

**The eye's adaptation range vs. the world's own range.** The lecture's own illustrative scale runs from 10⁻⁶ to 10⁶ (candela per m², roughly — 12 orders of magnitude), and places both the eye's full adaptation range and the band of "common real-world scenes" on that same axis (matching, to within the rough rounding expected of an illustrative order-of-magnitude slide, Week 1 §10's ~14-order figure for the eye's full adaptation range). Crucially, "common real-world scenes" doesn't fill that whole 12-order band — it's a somewhat narrower slice roughly in the middle, which the eye's adaptation range comfortably brackets on both sides.

**Worked example — one real HDR photograph's own measured range.** The lecture shows an actual bracketed sequence of a room with a window, with each frame's measured relative brightness printed underneath: **1** (a dim interior patch) → **1,500** → **25,000** → **400,000** → **2,000,000,000** (direct view of a bright light source through the window). That's roughly **9–10 orders of magnitude of brightness inside a single ordinary scene** — a concrete demonstration that "common real-world scenes" can themselves already span nearly as much range as the eye's whole adaptation window, well before considering the world's absolute extremes.

**Sensor: a narrower band still.** A digital sensor's own achievable dynamic range occupies roughly the same narrower band as "common real-world scenes" on that axis — not the eye's full adaptation range. This matches Week 2 §14's own framing (a sensor's achievable range is capped by whichever is smaller: its physical noise floor, Week 2 §16, or its bit-depth quantization step).

**Image: narrower still, and it *slides*.** Once you commit to *one* exposure setting (Week 2 §13), the resulting image only captures whatever slice of the sensor's range that one setting happened to land on — a "high exposure" choice shifts the captured slice toward the bright end (crisp shadow detail, blown-out highlights), a "low exposure" choice shifts it toward the dark end (crisp highlights, noisy/crushed shadows). Either way, one exposure setting only ever keeps a narrow window of the sensor's own already-narrower range, and everything outside that window is either clipped to pure white (overexposed, Week 2 §13.4) or buried in the noise floor (underexposed).

**Display: narrower again, and sometimes surprisingly so.** Once an image is finally rendered on a standard 8-bit-per-channel (0–255) display, a naive question — "how much brighter is displayed pure white than displayed pure black?" — has a surprisingly small answer: only about **50×**, not the 256× the bit count alone would suggest. This is precisely Week 2 §14's point made concrete: bit depth (a *digital* quantity — how many discrete code values exist) and achievable dynamic range (a *physical* quantity — how much the display can actually make the brightest patch outshine the darkest one) are two different things, and the second is capped by physical display limitations (backlight leakage, ambient reflections) that the code-value count alone says nothing about.

**Putting real device ratios on the same scale.** The lecture's own device comparison (contrast ratio, brightest:darkest):

| Device / medium | Contrast ratio |
|---|---|
| Photographic print (higher for glossy paper) | 10:1 |
| Artist's paints | 20:1 |
| Slide film | 200:1 |
| Negative film | 500:1 |
| LCD display | 1,000:1 |
| Digital SLR (at 12 bits) | 2,000:1 |
| **Real world** | **100,000:1** |

**The two-challenges framing, restated with numbers now attached.** A sensor has 8–14 bits to decide which slice of that 100,000:1 real-world range to *measure* (that decision, and how to widen it via multiple exposures, is **HDR imaging**, §§3–6); a display has only 4–10 bits to decide which slice of whatever was measured to actually *show* (that decision is **tonemapping**, §§7–9). The lecture states this pairing explicitly: **HDR imaging compensates for sensor limitations; tonemapping compensates for display limitations** — two genuinely different jobs, even though a single consumer "HDR photo" workflow usually does both back to back (formalized in §10).

---

## 3. HDR Imaging, Step 1: Exposure Bracketing

The lecture's basic HDR recipe has exactly two steps: **(1)** capture several ordinary low-dynamic-range (LDR) exposures of the same static scene at different exposure settings — **exposure bracketing** — then **(2)** merge them into one image that captures the *union* of what each individual exposure captured well (§4). This section covers step 1.

### 3.1 Four ways to vary exposure, and their trade-offs for bracketing

Week 2 already built three of these knobs individually; this table is new in that it compares all four side by side, specifically for *how well each one serves HDR bracketing*:

| Knob | Range | Pros | Cons |
|---|---|---|---|
| **Shutter speed** (Week 2 §13.1–§13.3) | ~30 s to 1/4000 s (6 orders of magnitude) | Repeatable, linear (Week 2 §13.2's reciprocity law) | Noise and motion blur at long exposure times |
| **F-stop** (aperture, Week 2 §8) | ~f/0.98 to f/22 (3 orders of magnitude) | Fully optical — no added electronic noise | Changes depth of field (Week 2 §9) |
| **ISO** (Week 2 §13.6) | ~100 to 1600 (1.5 orders of magnitude) | No motion at all — nothing physically changes between shots | Adds noise (amplifies whatever was already collected) |
| **[Neutral density (ND) filter](https://en.wikipedia.org/wiki/Neutral-density_filter)** | Up to 6 densities (6 orders of magnitude) | Works even with strobe/flash lighting | Not perfectly color-neutral (slight color shift); extra glass adds interreflections/aberrations (Week 2 §6) |

**What an ND filter is, from scratch.** A neutral density filter is a piece of darkened glass or film placed in front of the lens that attenuates *all* wavelengths of light roughly equally — i.e., it reduces the total light reaching the sensor without deliberately changing color, letting you use a wider aperture or a longer shutter time than the scene's actual brightness would otherwise allow. Its strength is conventionally measured in **densities**: this is **[optical density](https://en.wikipedia.org/wiki/Optical_density)**, OD = log₁₀(1/transmittance), a base-10 logarithmic unit — which is exactly why "up to 6 densities" lines up with "6 orders of magnitude" in the table above (OD 6 means a transmittance of 10⁻⁶, i.e. the filter blocks all but one-millionth of the incident light).

**Why shutter speed is usually the default choice for bracketing.** For a bracket to merge cleanly (§4), every frame in the stack should differ from the others *only* in overall brightness — nothing else about the captured scene should change between frames. Changing the f-stop between frames also changes depth of field (Week 2 §9), so different frames in the stack would be sharp in different places, which the merge step has no way to account for. ISO's range is small (only 1.5 orders of magnitude) and its whole cost is exactly the noise HDR is trying to reduce, so it adds little on its own. ND filters are mainly useful when the shutter time itself is constrained (e.g. paired with a fixed-duration flash/strobe pop, where lengthening the shutter wouldn't collect any more of the flash's light anyway). Shutter speed — repeatable, linear, and by far the widest range — is therefore the default bracketing knob, which is exactly why the lecture's own worked bracket (below) varies shutter time alone.

### 3.2 How many exposures, and which ones

> **Worked example — the standard 5-exposure bracket.** Shutter times conventionally follow a power-of-2 sequence, one stop apart (Week 2 §13.3): 1/4, 1/8, 1/16, 1/32, ... s. Given a metered "correct" exposure time *t₀* (§1's key-based estimate), the lecture's stated default bracket is **5 exposures: the metered exposure, and ±2 stops around it** — since each stop is a factor of 2× in light (Week 2 §8, §13.3), that bracket is the sequence
> ```
> t₀/4,   t₀/2,   t₀,   2t₀,   4t₀
> ```
> five frames spanning a **16× (4-stop) total range** of collected light, symmetric around the meter's own best guess. The exact number of exposures actually needed varies with how wide the scene's own dynamic range is (§2) — 5 is a reasonable, general-purpose default, not a universal constant.

---

## 4. HDR Imaging, Step 2: Merging — Confidence Weights and Log-Domain Least Squares

### 4.1 Why simple averaging doesn't work

Given the bracketed stack from §3, the naive idea — just average every frame's pixel value at each location — is wrong for a specific, fixable reason: **not every frame's pixel value is equally trustworthy.** A pixel that's badly underexposed in one frame is dominated by noise (Week 2 §13.4's noise floor); a pixel that's saturated/clipped in another frame carries no information about the true brightness at all (Week 2 §13.4). A good merge has to weight each frame's contribution at each pixel by how *confident* that particular measurement is, not treat every frame identically.

### 4.2 The confidence weight function

**Intuition.** A pixel value sitting at the middle of a frame's recordable range (neither near-black nor near-clipped) is the most trustworthy kind of measurement — nowhere near the noise floor, nowhere near saturation. A pixel value near either extreme is the least trustworthy. So the weight should be a function that peaks at the mid-range value and falls off toward both ends — the lecture's choice is a **Gaussian bump centered at mid-gray**:

```
w(I) = exp( −4·(I − 0.5)² / 0.5² )
```

**Term-by-term.** *I* is a single pixel's linear (already-in-[0,1]-range) value from one exposure in the stack — or, equivalently, the mean pixel value on whatever scale the image actually uses (e.g. 127.5, if *I* is stored on a [0, 255] scale); *w(I)* is the resulting confidence weight, itself in (0, 1]; the constant 0.5 is the mid-range value the weight peaks at (exactly the "correctly exposed, confident" case from Week 2 §13.4); the "−4/0.5²" combination sets how quickly confidence falls off away from that peak — rewriting it in the standard Gaussian form exp(−(I−0.5)²/(2σ²)) gives σ² = 0.5²/8, i.e. σ ≈ 0.177, so the weight has already dropped to a small fraction of its peak by the time *I* is within about 0.18 of either extreme (0 or 1).

> **Worked numeric check.** At *I* = 0.5 (perfectly mid-range): *w* = exp(0) = **1** — full confidence. At *I* = 0 or *I* = 1 (fully clipped black or white): *w* = exp(−4) ≈ **0.0183** — down to under 2% of peak confidence, correctly signaling "barely trust this measurement at all."

The weight is computed **per color channel, per pixel, per exposure** — every one of the *N* bracketed frames contributes its own independent weight at every pixel, in every channel, from its own recorded value there.

### 4.3 The log-domain weighted least-squares objective

**Setup, for one fixed pixel location.** Let *i* = 1, ..., *N* index the *N* bracketed exposures (the same physical scene point, photographed *N* times at different exposure times). For that one pixel: *I_lin,i* is the (linearized, §5) recorded value in exposure *i*; *t_i* is exposure *i*'s known exposure time; *w_i* = *w*(*I_lin,i*) is that exposure's confidence weight from §4.2. *X* is the single unknown quantity being solved for — the scene's true underlying exposure/radiance value at that pixel, the *same* for every exposure *i* since it's a property of the scene, not of any one frame.

**Intuition.** Because *H* = *E*·*t* (Week 2 §13.2's reciprocity law, applied per pixel with *E* ∝ *X*), every well-behaved exposure *i* should satisfy *I_lin,i* ≈ *t_i*·*X* — up to noise and up to how confident that particular frame's measurement is. Taking logarithms turns this *multiplicative* relationship into an *additive* one, log *I_lin,i* ≈ log *t_i* + log *X*, so recovering log *X* from *N* independent, differently-weighted noisy estimates of it is exactly a **weighted least-squares fit of a single constant** to *N* data points:

```
minimize    O(X) = Σᵢ wᵢ · ( log(I_lin,i) − log(tᵢ·X) )²
    X
```

**Solving it.** Setting the derivative with respect to log *X* to zero,

```
∂O/∂(log X) = −2 Σᵢ wᵢ · ( log(I_lin,i) − log(tᵢ) − log(X) ) = 0
```

and solving gives the closed form the lecture states directly:

```
X̂ = exp( [ Σᵢ wᵢ·(log(I_lin,i) − log(tᵢ)) ] / [ Σᵢ wᵢ ] )
```

**Term-by-term.** *X̂* is the recovered, merged HDR value at this pixel (in relative units — §6.1 covers converting this to an absolute physical quantity); the numerator's Σᵢ wᵢ·(log I_lin,i − log tᵢ) is a confidence-weighted sum of every exposure's own individual "back out the exposure time" estimate of log *X*; dividing by Σᵢ wᵢ turns that weighted sum into a proper weighted *average*; the outer exp() undoes the earlier log, returning to ordinary (non-log) units. No diagram is needed here — like Week 3 §1's spectral-sensitivity integral, this is a relationship between numbers computed *per pixel*, not a shape in space.

**Linear-algebra view (this is the simplest possible weighted least-squares problem).** Treat the *N* values *yᵢ* = log(*I_lin,i*) − log(*tᵢ*) as *N* noisy observations of a single unknown constant *μ* = log *X*. Minimizing Σᵢ *wᵢ*(*yᵢ* − *μ*)² is ordinary weighted linear regression whose "design matrix" is just a column of *N* ones (since the model "*μ*, the same for every observation" has no other free parameter) — the general weighted normal equations **Aᵀ W A** *μ* = **Aᵀ W y** collapse, for this all-ones **A**, to exactly the weighted-average formula above. Every pixel in the image runs this identical 1-parameter regression independently; nothing here is more exotic than fitting a mean.

---

## 5. Radiometric Calibration

### 5.1 What's being measured, and why it's needed

Everything in §4 assumed the recorded pixel values *I_lin,i* were already **linear** in the true scene radiance — i.e., that doubling the light doubles the recorded number. Most cameras don't hand you that directly: a camera's finished (e.g. JPEG) output has usually already been passed through some nonlinear **[tone reproduction curve](https://en.wikipedia.org/wiki/Transfer_function)** before you ever see it. **[Radiometric calibration](https://en.wikipedia.org/wiki/Radiometric_calibration)** is the process of measuring — and then undoing — that curve, so the log-domain merge of §4 is operating on genuinely linear values.

### 5.2 The non-linear image formation model

```
I_linear(x, y)     = clip[ tᵢ · Φ(x, y) + noise ]
I_nonlinear(x, y)  = f[ I_linear(x, y) ]
```

**Term-by-term.** Φ(*x*,*y*) is the real scene flux hitting pixel (*x*,*y*) (fixed by the scene and lighting — this is Week 2 §13.2's *E*, image-plane irradiance, restated per pixel); *tᵢ* is exposure *i*'s exposure time (you control this, §3); *I_linear* is what the sensor *would* record if nothing further distorted it, after the sensor's own clipping at saturation (Week 2 §13.4); *f*[·] is the camera's tone reproduction curve — some fixed, generally unknown, monotonic nonlinear function baked in by the camera's internal processing; *I_nonlinear* is what actually gets written to the output file.

**Linearization.** Since merging (§4) needs linear values, and only *I_nonlinear* is available, recovering an estimate of the true linear signal requires the *inverse* of that curve:

```
I_est(x, y) = f⁻¹[ I_nonlinear(x, y) ]
```

**Merging non-linear exposure stacks, step by step:** (1) calibrate the response curve *f* (methods below); (2) linearize every frame in the stack via *f*⁻¹; (3) form the merged pixel value via §4.3's exact same weighted least-squares solution, now applied to the linearized values. Nothing about the merge math itself changes — only the input values are pre-processed first.

### 5.3 Three ways to calibrate the response curve

| Method | What's varied | What's held fixed | A good target |
|---|---|---|---|
| **Vary flux only** | Scene brightness (photograph patches of different, known reflectance) | Camera exposure setting | A **[ColorChecker](https://en.wikipedia.org/wiki/ColorChecker)** chart — its bottom row of patches has log-reflectance increasing linearly step to step, giving a controlled ladder of known relative flux values at one fixed exposure |
| **Vary exposure only** | Camera exposure setting (known exposure times) | Scene brightness (photograph one uniformly-reflective target) | A **white-balance card** — every point on its white area has the same reflectance, so varying only the exposure time isolates exactly how the camera's response curve depends on *t* |
| **Vary both** | Scene flux *and* exposure, simultaneously | — | The bracketed LDR exposure stack itself (§3) — no separate calibration target needed; the stack's own internal consistency (same scene, different *t*) is enough to solve for *f* |

### 5.4 When you can't calibrate: EXIF and the γ ≈ 1/2.2 default

If no calibration is possible (no ColorChecker, no controlled bracket to fit against), two fallbacks:

- **EXIF metadata.** Alongside pixel data, an image file typically stores **[Exif](https://en.wikipedia.org/wiki/Exif)** metadata (Week 3 §9) — and it often also records information about the tone reproduction curve and color space actually used, which can be read directly instead of estimated.
- **The default gamma model.** Absent any of that, *f* is well approximated as a power law, *f*(*x*) ≈ *x*^γ, with a good default of **γ = 1/2.2** — precisely the same γ ≈ 2.2 human-perceptual constant Week 3 §12 already built from scratch for deliberately *encoding* a linear sensor reading into 8 bits. The role is different here: Week 3 §12 was about a chosen, deliberate encoding step for efficient storage; here, *f* is whatever nonlinear curve the camera silently *already* applied, and γ ≈ 1/2.2 is simply the best generic guess for *what that curve probably was*, so it can be undone (*f*⁻¹, raising to the power ≈2.2) before merging. The lecture's own rule of thumb — "if nothing else, take the square of your image" — is exactly this approximation one step cruder: since 1/(1/2.2) = 2.2 ≈ 2, squaring the nonlinear image roughly approximates the correct *f*⁻¹, close enough to remove most of the tone-curve's effect when no better estimate is available.

---

## 6. Other Aspects of HDR Imaging

### 6.1 Relative vs. absolute flux

The merge in §4 recovers *X̂* only up to a single unknown global scale factor — every pixel's relative brightness relative to every other pixel is correct, but there's no way from the stack alone to know what physical flux value "1.0" corresponds to. If the *absolute* flux at even one point in the scene is independently known (e.g. from a handheld **spotmeter**, a device that measures absolute flux at one point), that one measurement pins down the global scale factor, converting the whole relative HDR image into an absolute flux map.

### 6.2 Alignment sensitivity

The basic two-step HDR recipe (§3–§4) assumes a genuinely **static scene and a static camera** — every pixel location across the stack must correspond to the exact same physical scene point. Any movement (a breeze-blown branch, a handheld camera's micro-shake) misaligns the stack and corrupts the merge, since §4's per-pixel weighted average silently assumes all *N* samples at one pixel location are measurements of the *same* underlying quantity. Most modern automatic HDR pipelines therefore run an explicit alignment step before merging.

### 6.3 HDR file formats

An HDR image's pixel values, unlike an ordinary 8-bit-per-channel (or even 12–16-bit) image, are floating point — the merged *X̂* values from §4 can span many orders of magnitude and need a representation that doesn't clip or round them into a fixed integer range. Three specialized formats:

| Format | Layout (per pixel) | Note |
|---|---|---|
| **[Portable float map (.pfm)](https://en.wikipedia.org/wiki/Netpbm#File_formats)** | Ordinary IEEE floating point: sign, exponent, mantissa, per channel | Very simple to implement — essentially a raw float dump with a small header |
| **[Radiance format (.hdr)](https://en.wikipedia.org/wiki/RGBE_image_format)** | 8 bits red mantissa + 8 bits green mantissa + 8 bits blue mantissa + **one shared 8-bit exponent** = 32 bits total | The shared exponent is the trick: instead of three full floats (needing three separate exponents), all three color channels share one exponent, cutting storage roughly in half relative to three independent floats; supported directly by MATLAB |
| **[OpenEXR (.exr)](https://en.wikipedia.org/wiki/OpenEXR)** | Sign, exponent, mantissa (typically a 16-bit "half" float per channel) | Multiple extra features beyond raw pixel storage (multiple layers, metadata, compression) |

### 6.4 Light probes, environment maps, and rendered HDR

A **light probe** is built by placing a mirrored chrome sphere in a scene and photographing it as an HDR image — since the sphere reflects the entire surrounding environment into one image, the result is a measurement of the real-world illumination environment (an **environment map**), directly useful for **image-based relighting** (illuminating a synthetic object as if it were sitting in that captured real environment). Separately, physics-based renderers that simulate light transport directly compute flux maps (relative or absolute) as their native output — so a rendered image is very often already an HDR image, with no capture or merging step needed at all.

---

## 7. Tonemapping: Why Linear Scaling Fails

Once an HDR image *I_HDR* exists (§§3–6), it still has to be shown on a display whose own dynamic range is far smaller (§2). The naive approach — **linear scaling** — picks one reference value in the HDR image and maps it to the display's maximum (1.0), scaling everything else proportionally. Two obvious choices, both broken in complementary ways:

- **Scale so the maximum value maps to 1.** The result looks *underexposed*, even though — measured against the true scene — it isn't: almost the entire image's brightness range gets compressed into the low end of the display's range, since only the single brightest pixel earns the full "1.0."
- **Scale so, say, the 10th-percentile-brightest value maps to 1.** The result looks *saturated* (blown out), even though it isn't: everything above that chosen reference value clips to flat white.

Neither failure is a defect in the HDR data itself — the HDR image genuinely does contain all the necessary brightness information. The failure is purely in how that information gets *linearly* squeezed into the display's much smaller range. Something *non-linear* is needed.

---

## 8. Photographic Tonemapping

**Intuition.** A good tonemapping curve needs two properties simultaneously: **(1)** bring every HDR value, however large, into the display's finite range — the curve must *asymptote* to 1 rather than ever reaching or exceeding it; and **(2)** leave genuinely dark regions alone, so a curve with **slope 1 near 0** doesn't waste contrast compressing the shadows that were already fine. A function shaped like a hyperbola does exactly both:

```
I_display = I_HDR / (1 + I_HDR)
```

*(the lecture notes the exact formula actually used in practice is somewhat more complicated than this; this is the simplified version that makes both design goals visible directly in the algebra.)*

**Term-by-term.** *I_HDR* is the input HDR intensity at one pixel (linear, non-negative, unbounded above — whatever the merge in §4 produced); *I_display* is the output value actually sent to the display, guaranteed to lie in [0, 1). Checking the two design goals directly from the formula: near *I_HDR* = 0, *I_display* ≈ *I_HDR* (since dividing by 1 + a small number barely changes it) — slope 1 near zero, dark detail untouched; as *I_HDR* → ∞, *I_display* → 1 — the curve asymptotes, so no value, however bright, ever produces an output exceeding the display's range. The lecture notes this shape is **perceptually motivated**, since it approximates the eye's own response curve to intensity — the same theme Week 1 §10 and Week 3 §12 already established, that human brightness perception is itself non-linear (roughly logarithmic/power-law), so a display encoding matched to that non-linearity looks more natural than a linear compression would.

**Diagram.** Plotting *L_display* against *L_world* (the lecture's own axis labels): a straight line of slope 1 near the origin, curving over smoothly and flattening toward an asymptote as *L_world* grows — contrasted directly against the two broken linear-scaling lines of §7, one of which would need to keep climbing past 1 (impossible, hence clipping) and one of which starts too shallow (hence looking dark). (See Fig. — companion diagram of the photographic tonemapping curve, with the two failed linear-scaling lines overlaid for contrast.)

**Worked comparison.** The lecture's side-by-side examples show photographic tonemapping recovering *both* the highlight and shadow detail that either linear-scaling choice (§7) individually sacrificed — matching a high-exposure LDR shot's shadow detail and a low-exposure LDR shot's highlight detail, simultaneously, in one image.

---

## 9. Color-Aware Tonemapping

§8's curve was described for a single scalar intensity. Applying it naively to a color image raises an immediate question the lecture poses directly: apply the *same* curve independently to R, G, and B? The lecture walks through an explicit progression of five increasingly sophisticated answers, each fixing the previous one's specific failure — and states outright that "there are many more, and more complicated, tone-mapping algorithms" than it has time to cover, so this is a survey of *why* each step was needed, not a full derivation of any of them.

| Step | Approach | Fixes | New problem introduced |
|---|---|---|---|
| 1 | **Naive per-channel** — apply §8's curve separately to R, G, B | — | **Colors wash out**: compressing each channel by a different amount (since each channel's own values, and hence the correction each receives, differ) distorts the ratios between channels, and those ratios are exactly what encode hue and saturation |
| 2 | **Intensity-only, in xyY** — convert to a luminance/chromaticity representation (**[xyY](https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_xyY_color_space)**, a reparameterization of Week 3 §5's CIE xy chromaticity plus a luminance axis Y), tonemap only Y, leave xy (chromaticity) untouched | Colors no longer wash out — hue/saturation are preserved by construction, since only the brightness axis is touched | **Contrast/detail washes out**: one single *global* nonlinear curve still compresses every pixel's fine local contrast the same way, everywhere |
| 3 | **Low-frequency intensity-only** — split intensity into a low-spatial-frequency (coarse, blurred) component and a high-spatial-frequency (fine detail) component (the same low-pass/high-pass split built from scratch in Week 1 §12.4.5, §13.1), tonemap only the low-frequency part, leave the high-frequency detail and the chromaticity both untouched | Nice color *and* nice local contrast | **Halo artifacts**: a naive low-pass filter (e.g. Gaussian) blurs *across* strong edges, mixing very different brightness levels together, which produces visible ringing/halos around high-contrast boundaries |
| 4 | **Edge-aware filtering** — do the same base/detail split, but with an edge-preserving filter instead of a naive low-pass one; specifically, the **[bilateral filter](https://en.wikipedia.org/wiki/Bilateral_filter)** already built from scratch in Week 3 §11.4 (which averages nearby pixels only when they're *also* similar in intensity, so it never blurs across a strong edge) | Fixes the halos, without losing the earlier steps' color and contrast gains | (No new problem flagged by the lecture at this step) |
| 5 | **Gradient-domain processing** and **[Local Laplacian Filters](https://en.wikipedia.org/wiki/Local_Laplacian_filter)** (Paris et al., 2011) | State-of-the-art alternatives | "Too many algorithms to discuss here" — the lecture explicitly declines to go deeper |

**Step 5, briefly.** Gradient-domain tonemapping computes the image's spatial gradients, scales/attenuates the large gradients (which correspond to the steep brightness jumps that overflow the display's range) while leaving small gradients alone, then **re-integrates** the modified gradient field back into an image by solving a **[Poisson equation](https://en.wikipedia.org/wiki/Poisson%27s_equation)** — compressing dynamic range while still preserving fine local detail, without needing an explicit base/detail split at all.

**Linear-algebra view (gradient-domain tonemapping is solving a linear system).** Computing an image's gradient is a **linear operator** — a fixed finite-difference matrix **G** acting on the image vector (the same "convolution is a matrix" idea from Week 1 §12.4.5, here with a difference kernel instead of a blur kernel). Scaling that gradient field is just rescaling **G**'s output entry by entry. Recovering a displayable image from the *modified* gradient field means finding an image vector **x̂** whose own gradient **Gx̂** best matches the target modified gradients — a least-squares problem in **x̂**, whose solution (the discrete Poisson solve) is exactly the normal-equations inverse of **G**. "Re-integrating a gradient field" is, underneath the graphics vocabulary, solving a linear system for the vector that some linear operator was applied to.

---

## 10. Terminology: Five Loose Uses of "HDR Imaging," Disambiguated

As the exam note at the top of this file flagged, this lecture explicitly calls out that **"high-dynamic-range imaging"** gets used to mean genuinely different things in casual usage. Now that §§1–9 have built every piece, here is the lecture's own list, and its own resolution:

**The five loose senses:**
1. Using single RAW images (no bracketing or merging at all — just capturing at high native bit depth, Week 2 §14).
2. Performing radiometric calibration (§5) alone.
3. Merging an exposure stack (§4) into one HDR image.
4. Tonemapping an image — linear or non-linear input, HDR or LDR input (§§7–9).
5. Some or all of the above, all lumped together.

**The precise, technical split** (what this file has actually been building toward):
- **HDR imaging**, precisely, is the process of creating a *radiometrically linear* image, free of over- and under-exposure artifacts — achieved via some combination of senses 1–3 above, depending on the situation (a single well-exposed RAW file might already suffice; a very high-contrast scene needs the full bracket-and-merge pipeline).
- **Tonemapping** (sense 4) is the separate process of mapping an image's intensity values — whatever their source, HDR or LDR, linear or non-linear — into the tonal range an actual display can show.

**But, in ordinary consumer usage:** "HDR photography" routinely refers to **both** HDR imaging (senses 1–3) **and** tonemapping (sense 4) together, as one combined "HDR mode" workflow — which is exactly why the phrase feels so overloaded in casual conversation, even though the two halves are, technically, distinct techniques with different goals (§0, §2).

---

## 11. A Note of Caution: The Over-Tonemapped Look

HDR photography, done well, produces genuinely compelling results — but it is also, by the lecture's own description, "a very routinely abused technique," producing the garish, flattened, halo-ringed look often associated with "HDR photos" in popular culture. The lecture is explicit about where the blame actually belongs: **the problem is typically the tonemapping choice, not HDR imaging itself** — an aggressive local tonemapping operator (over-compressing contrast, over-sharpening local detail) is what produces the unnatural look, not the underlying radiometrically-correct HDR data it was applied to. Most cameras today, including phones, ship an automatic HDR mode, and the algorithms behind some of them (e.g. Google's HDR+) are published research, appearing in SIGGRAPH and SIGGRAPH Asia.

---

# Part 2 — Coded (Aperture) Computational Imaging

## 12. The Camera Aperture Revisited: Two Codable Parts

Week 2 §8 introduced the aperture as a single number — the f-number *N* = *f*/*D*, controlling how much light gets through and how much depth of field results. This section reopens that picture: a real camera aperture actually has (at least) **two physically separate parts**, and either one can be deliberately **coded** — replaced with something more elaborate than its plain default — to change how the camera forms an image:

1. **The aperture stop itself** — ordinarily just a plain circular opening of adjustable diameter (Week 2 §8). Coding this means replacing the plain circular hole with a patterned, **attenuating** mask: a stencil-like element, opaque in some places and transparent (or partially transparent) in others, rather than uniformly open across one circular region.
2. **The refractive elements** — the lens or compound-lens system itself (Week 2 §4, §6). Coding this means altering the optics' own shape or adding a phase-changing element, so that light doesn't refract the way an ordinary lens would (this is exactly what **wavefront coding**, §15.2, does).

Both are "coding the aperture" in the broad sense this lecture uses, and both work by deliberately reshaping the camera's **point spread function** — built from scratch next.

---

## 13. Point Spread Function and Optical Transfer Function, from Scratch

Week 1 §12.4.5 already forward-pointed to this exact pair of terms ("the point spread function (PSF) and Wiener filtering (Week 5)"), and Week 2 §2, §5, §9 already worked with the *idea* informally (a finite pinhole's blur disc, a lens's circle of confusion, a convolution-matrix view of blur) without ever giving it this name. This section (using PS3 Task 1's own material) gives the idea its formal name and its frequency-domain partner.

### 13.1 The point spread function (PSF)

**Analogy and definition.** Photograph a single, isolated point of light — a distant star, or a pinhole backlit by a lamp — through some optical system (a lens, an aperture, the whole imaging chain). Whatever blob of light actually lands on the sensor, however large or oddly shaped, **is** that system's **[point spread function (PSF)](https://en.wikipedia.org/wiki/Point_spread_function)**: literally, the picture of a single point, "spread" by the optics. A perfect pinhole (Week 2 §1) has a PSF that is (ideally) a single point; every real optical system's PSF is some larger, blurrier shape — a disc for a finite pinhole (Week 2 §2), a circle of confusion for a defocused lens (Week 2 §5, §9), an Airy pattern for a diffraction-limited circular aperture.

**Why this matters for a whole image, not just one point.** For a system whose blurring behaves the same way at every location (**shift-invariant**), every scene point gets smeared by that exact same PSF shape, just centered wherever that point's own sharp image would have landed. The whole blurred image is therefore the sum, over every scene point, of a copy of the PSF scaled by that point's brightness and centered at that point's location — precisely the **convolution** operation Week 1 §12.4.5 already built:

```
I_blurred(x, y) = (I_ideal * PSF)(x, y)
```

**Term-by-term.** *I_ideal*(*x*,*y*) is the hypothetical perfectly sharp image an ideal pinhole (Week 2 §1) would have produced; PSF(*x*,*y*) is the system's blur kernel — normalized so it sums (or integrates) to 1, exactly as PS3 instructs ("normalize the filter so it sums to 1"), which guarantees the blur redistributes light rather than adding or removing any; *I_blurred* is the image actually captured. The `*` is convolution, the same sliding-weighted-sum operation from Week 1 §12.4.5/§13.1.

**Diagram.** (See Fig. — companion diagram: a single bright point imaged through an ideal pinhole, landing as a single sharp dot, contrasted with the same point imaged through a real lens, landing as a blurred disc — that disc *is* the PSF.)

### 13.2 The optical transfer function (OTF)

**Definition.** The **[optical transfer function (OTF)](https://en.wikipedia.org/wiki/Optical_transfer_function)** is simply the two-dimensional Fourier transform of the PSF:

```
OTF(u, v) = FT{ PSF }(u, v)
```

where *u*, *v* are image frequencies exactly as built in Week 1 §12.4.2 (cycles per pixel).

**Intuition, via the convolution theorem.** Week 1 §12.4.5 already proved the key fact needed here: convolving in the spatial domain is identical to multiplying in the frequency domain. Applied to the PSF specifically: convolving an image with the PSF (spatial domain) is exactly the same operation as multiplying the image's own spectrum by the OTF (frequency domain). The OTF therefore reports, frequency by frequency, exactly how much of each spatial-frequency component of the true scene *survives* the imaging system: where |OTF(*u*,*v*)| is near 1, that frequency passes through essentially untouched; where it's near 0, that frequency has been (nearly) destroyed by the optics, and no amount of after-the-fact processing can recover information that was never recorded in the first place.

**Linear-algebra view (recapping and extending Week 1 §12.4.5 and Week 2 §2).** Convolution by a fixed kernel is a **linear, shift-invariant operator** — a **Toeplitz/circulant matrix** acting on the flattened image vector (Week 1 §12.4.5; Week 2 §2 already applied this to a finite pinhole's own blur disc). Every sinusoid is an eigenvector of that matrix, with eigenvalue equal to the kernel's own Fourier transform — so the OTF is *exactly* the convolution matrix's eigenvalues, one per spatial frequency. A frequency where the OTF is exactly zero is a frequency where that eigenvalue is zero, meaning the corresponding Fourier basis vector lies in the matrix's **null space**: a direction in "scene space" that this particular optical system provably cannot see, no matter what. Calling an OTF **broadband** (§14) means precisely that this null space is trivial — no spatial frequency gets multiplied by exactly zero — so the convolution matrix is, at least in principle, invertible.

### 13.3 Filtering in the primal domain vs. the Fourier domain (PS3 Task 1)

PS3 Task 1 has you implement the *same* filtering operation two ways, to see the OTF's practical payoff directly. A **low-pass filter** (Week 1 §13.1) can be applied either by convolving with a low-pass PSF in the spatial ("primal") domain, or by multiplying by the corresponding low-pass OTF in the Fourier domain. A **high-pass filter** — recovering fine detail — follows immediately as the complement of the low-pass version, exactly matching Week 1 §12.4.5's "high-pass mask is the complementary projection" idea, now written with this week's PSF/OTF vocabulary:

```
I − I * PSF_LP              (primal domain: subtract a low-pass-blurred copy)
Ĩ × (1 − OTF_LP)             (Fourier domain: multiply by the complementary mask)
```

where PSF_LP is a low-pass blur kernel (e.g. a Gaussian), OTF_LP is its Fourier transform, *I* is the spatial-domain image, and *Ĩ* is its spectrum. This is the identical high-pass-as-complement-of-low-pass idea from Week 1 §12.4.5 — the one difference is that here, the "mask" isn't an arbitrary hand-drawn disc; it's the OTF of a real, physically meaningful blur kernel (and, starting in §14, a kernel that's physically produced by an actual lens/aperture rather than chosen by hand).

**Why Fourier-domain filtering cost is independent of kernel size.** Direct spatial-domain convolution of an *N*-pixel image with a *K*×*K* kernel costs, per output pixel, a weighted sum over all *K*² kernel taps — so total cost scales as *O*(*N*·*K*²): a bigger blur kernel means strictly more work. Fourier-domain filtering instead costs one FFT of the image (*O*(*N* log *N*), independent of the kernel), one pointwise multiplication against the OTF (*O*(*N*), one multiply per pixel, again independent of kernel size — the OTF array, once the kernel is zero-padded to the image's own size, is exactly as large as the image no matter how "wide" the original spatial kernel was), and one inverse FFT. **The kernel's size never enters the Fourier-domain cost at all** — only the image's own size does.

> **Worked example — PS3's own runtime benchmark.** PS3's included comparison blurs an image with a Gaussian kernel at three different widths (σ = 0.1, 1, 10 — a small, tight kernel up to a very wide one) using both routes. The spatial-domain convolution's runtime grows sharply across that range (its bars climb by roughly three orders of magnitude from σ = 0.1 to σ = 10 on the chart's log-scale axis), while the Fourier-domain route's runtime stays essentially flat across the same three widths — a direct, measured confirmation of the *O*(*N*·*K*²) vs. *O*(*N* log *N*) argument above.

---

## 14. How a Coded Aperture Reshapes the PSF

### 14.1 An out-of-focus point's blur shape is (a scaled copy of) the aperture's own shape

Recall Week 2 §2's finite-pinhole argument: a pinhole of nonzero diameter passes not one ray per scene point but an entire small cone of rays spanning the whole opening, so each point projects to a blurred disc **the same shape as the opening itself**. Exactly the same geometric fact holds for a defocused lens (Week 2 §5, §9): an out-of-focus point sends a full cone of rays through the *entire* aperture, and that cone's cross-section at the sensor — the resulting blur, i.e. the PSF — is a scaled copy of the aperture's own opening shape. A plain circular aperture stop therefore produces a plain circular (or, at the diffraction limit, Airy-ring) defocus PSF. **Coding the aperture stop's shape directly and predictably reshapes the resulting PSF into that same coded pattern.**

### 14.2 Why the circular PSF is a problem, and what "broadband" fixes

The lecture shows this directly (Veeraraghavan et al., 2007): photographing the same out-of-focus point through an ordinary circular aperture gives a smooth circular blob, while photographing it through a specifically-designed coded (patterned) aperture gives a blob shaped like that pattern instead. Comparing their Fourier-domain magnitudes (the OTF, §13.2) side by side shows exactly why this matters: the **circular aperture's OTF has visible dark rings** — frequencies where it drops to (near) zero — while the **coded aperture's OTF has no such rings**, remaining nonzero (if uneven) across the whole frequency range shown. In the language of §13.2's linear-algebra view: the circular PSF's convolution matrix has a genuine null space (those exact-zero frequencies are unrecoverable no matter the algorithm); the coded PSF's convolution matrix has a **trivial** null space — every frequency survives with *some* nonzero strength, even if weakly.

This is precisely what the lecture calls **broadband**: a PSF whose OTF has no exact zeros. A broadband PSF's associated blur is, at least in principle, invertible — the underlying scene can be recovered by deconvolution (Weeks 5–6) — whereas a circular/Airy PSF's blur has provably lost information at its zero-crossing frequencies, no matter how good the deconvolution algorithm is. The lecture's own summary states both engineering payoffs at once: coding the aperture (1) **preserves high frequencies** that a circular aperture's PSF would have destroyed, giving (2) **more content available to help determine correct depth** — the extra high-frequency structure it preserves is exactly what makes coded-aperture depth estimation (§16) possible at all.

---

## 15. Extended Depth of Field

### 15.1 Two problems with ordinary defocus deblurring

Recall Week 2 §9's whole depth-of-field derivation: an object away from the focused distance *S* produces a circle of confusion whose size, *c* = *m*·*D*·|*O*−*S*|/*O* (Week 2 §9.2), depends on that point's own actual depth *O*. Deliberately trying to "deblur" an ordinary out-of-focus photo runs into exactly two problems, which the lecture states directly:

1. **The PSF's scale depends on unknown depth.** Since *c* varies with *O*, and *O* generally isn't known per scene point, there's no single, fixed deconvolution kernel that undoes the blur everywhere in the image at once — each depth would need its own kernel.
2. **The PSF usually isn't invertible.** Even at one single, known depth, an ordinary circular/Airy PSF has the null-space problem from §14.2 — some frequencies are simply gone.

### 15.2 Two engineering fixes, one per problem

**Fix for problem 1 — engineer a *depth-invariant* PSF.** If the PSF's shape/scale can be made (approximately) the *same* regardless of an object's actual depth, then a single, shift-invariant deconvolution kernel handles the whole image at once — much easier than the depth-dependent case. Two distinct ways to engineer this:

- **Focal sweep** — physically move the sensor (or the focal plane) through a range of positions *during* one exposure. Every scene point ends up in focus for only a moment and defocused by a *changing* amount for the rest of the sweep; averaged over the whole exposure, points at *every* depth end up blurred by approximately the same time-integrated kernel, because the sweep passes every depth through the same overall range of defocus amounts.
- **Wavefront coding** — instead of moving anything, change the optics themselves (§12's "refractive/diffractive coding") so that rays from a point source no longer converge to a sharp focus at any single plane at all; they form an extended, roughly constant smear across a whole range of depths, giving an approximately depth-invariant PSF directly, with no moving parts.

**Fix for problem 2 — engineer a *broadband* PSF.** Exactly §14's fix: shape the aperture (or the wavefront-coding optics) so the resulting OTF has no zero crossings, making the resulting depth-invariant blur well-posed to invert.

### 15.3 Focal sweep, worked (Nagahara et al., 2008)

The lecture's own comparison lays out three captures of the same scene: **(a)** a conventional photo with a *wide* aperture (shallow depth of field) — sharp only in a narrow depth slice, blurry everywhere else; **(b)** a conventional photo with a *small* aperture (large physical depth of field, Week 2 §9) — sharp almost everywhere, but much noisier, since a small aperture collects far less light (Week 2 §3, §8); **(c)** a **focal-sweep** capture — deliberately blurry *everywhere*, by design (every depth gets the same time-integrated defocus), which is then deconvolved with one shared, depth-invariant kernel to recover an **EDOF (extended depth of field)** image that is sharp at every depth simultaneously.

**Why SNR, not just sharpness, is the honest comparison metric.** The lecture flags this explicitly: comparing (b) and (c) purely on "does it look sharp everywhere?" misses the point, since both can look sharp everywhere — the real difference is *how much noise* was paid to get there. Option (b) achieves its large depth of field the conventional way, by stopping down the aperture, which directly costs light (Week 2 §3, §8) and therefore signal-to-noise ratio (Week 2 §16.3). Option (c) can keep the aperture wide open throughout the sweep, collecting far more total light, and pays its "cost" instead in a single, known, invertible blur. **Signal-to-noise ratio is therefore the metric that actually reveals whether focal sweep was worth it** — not visual sharpness alone, which both methods can achieve. This also means the comparison's outcome isn't universal: it depends on the specific sensor's own noise characteristics (Week 2 §16), so which approach wins can change if the underlying sensor's read noise, dark current, or quantum efficiency change.

**Diagram.** (See Fig. — companion diagram extending Week 2 §9.2's circle-of-confusion figure: the same lens/sensor geometry, now shown with the sensor sweeping through a range of positions during one exposure, so every depth's rays are captured at a whole range of defocus states rather than just one.)

---

## 16. Monocular Depth Estimation via Coded Apertures

### 16.1 Motivation: depth from one lens, one shot

Dedicated depth cameras (structured light, LiDAR/time-of-flight — Week 2 §13.8) are complex, active systems. An entirely different family of approach asks: can an ordinary single 2D photograph, on its own, carry enough information to recover per-pixel depth? Two genuinely different answers appear on the lecture's slides:

- **Learned, pictorial-cue depth** (Godard et al., 2017) — train a model to infer depth from the same kinds of cues a human uses when looking at an ordinary photo (relative size, occlusion, perspective) — no special optics, an entirely ordinary lens and aperture.
- **Coded-aperture depth** (Chang & Wetzstein, 2019; Ikoma et al., 2021) — deliberately engineer (or jointly *learn*) a non-circular aperture/PSF shape specifically so that the blur it produces varies with depth in a way that's easy to read back out, encoding depth directly and reliably into the optics themselves, "rather than just pictorial cues."

### 16.2 Why an ordinary circular aperture's blur is an *ambiguous* depth cue

This connects directly back to a specific finding from Week 2: §9.2's formula, *c* = *m*·*D*·|*O*−*S*|/*O*, shows that blur size *c* does depend on a scene point's depth *O* — so, in principle, blur size alone could be used to estimate depth. But Week 2 §9.2.1 already proved something stronger and more troublesome: because that formula depends only on |*O*−*S*|, **a point closer than the focus plane and a point farther than the focus plane can produce the *exact same* circle-of-confusion size** — the "bicone" argument, where the converging (near) and diverging (far) cones are mirror images of each other at the sensor's fixed cross-section. A circular aperture's PSF is symmetric in exactly the way that makes near-defocus and far-defocus *look identical* — same blurred disc, same size, no visual way to tell which side of focus the point was actually on.

> **Worked numeric example — the sign ambiguity, made concrete.** Reusing Week 2 §9.3.1's near/far distance formulas with the same *k* = ε/(*mD*) tolerance-fraction structure: for a focus distance *S*, take *k* = 0.2. Then a point at *O*_near = *S*/(1+*k*) and a point at *O*_far = *S*/(1−*k*) both satisfy |*O*−*S*|/*O* = 0.2 exactly (by construction), and therefore — since Week 2 §9.2's formula for *c* depends on nothing but that ratio — produce the **identical** circle-of-confusion diameter *c*, for the same aperture diameter *D* and magnification *m*. Concretely, with *S* = 1000 mm: *O*_near = 1000/1.2 ≈ 833 mm and *O*_far = 1000/0.8 = 1250 mm give exactly the same blur size, through the same ordinary circular aperture. Blur size alone genuinely cannot distinguish "833 mm away" from "1250 mm away" — only that the point is *some* fixed distance off from focus, on one side or the other.

**How a coded aperture breaks the tie.** An *asymmetric* aperture pattern doesn't just change the blur's *size* with depth — it changes the blur's *shape/orientation* differently on the near side versus the far side of focus (e.g. rotated or mirrored), because the underlying geometry that made the circular case symmetric (Week 2 §9.2.1's mirror-image bicone argument) relied specifically on the aperture's own circular symmetry. Recovering the PSF's actual *shape* at a given image patch — not just its size — therefore resolves exactly the sign ambiguity a plain circular aperture cannot: this is precisely what the lecture means by "PSF engineering can make depth estimation more robust by encoding low-level depth information in the PSF (rather than just pictorial cues)."

### 16.3 Passive defocus-cue depth vs. active time-of-flight depth: two structurally different families

Since a full lecture on time-of-flight sensing comes later in the course, and this reader's own interest is specifically in LiDAR, it's worth being explicit that coded-aperture monocular depth estimation and the LiDAR/ToF sensing already built in Week 2 §13.8 are **not two versions of the same idea** — they belong to two structurally different sensing families entirely.

| | Passive PSF-encoded monocular depth (this section) | Active time-of-flight / LiDAR (Week 2 §13.8) |
|---|---|---|
| **Illumination** | **Passive** — uses whatever ambient light is already in the scene; supplies none of its own | **Active** — supplies its own light (typically an infrared laser or a modulated wave) and measures its own signal's return |
| **What's physically measured** | A single 2D image's *local blur pattern* (the PSF shape/size at each patch) | The *round-trip travel time* (or phase shift) of the sensor's own emitted light, τ = 2*d*/*c* (Week 2 §13.8) |
| **How depth is recovered** | Computationally/statistically — recognizing which depth a given local blur pattern is most consistent with (often learned end-to-end) | Directly from a physical time/phase measurement — no blur pattern involved at all |
| **Number of exposures/shots** | A single ordinary photograph | Typically many laser pulses accumulated into a histogram (Week 2 §13.8), or one continuous-wave phase measurement |
| **Fails when...** | The scene patch has no texture at all (a flat, featureless surface has no visible blur pattern to read the PSF shape from) | Ambient sunlight or reflective surfaces overwhelm or saturate the return signal (Week 2 §13.4, §13.8) |
| **Works even when...** | Lighting is completely uncontrolled/ambient | The scene is a flat, texture-less wall — an active system supplies its own signal regardless of scene texture |

Both output the same *kind* of result — a per-pixel depth estimate — and both matter for the same downstream applications (3D reconstruction, robotics, AR). But one is a deliberately engineered optical side-channel read out of an otherwise completely ordinary photograph, and the other is a dedicated active-illumination ranging system built around a precise clock (or phase detector) rather than a lens's blur behavior at all. Keeping this distinction sharp matters specifically because LiDAR's full treatment is still ahead in this course (a dedicated time-of-flight lecture); this section's coded-aperture depth is a genuinely different, purely passive, purely optical alternative — not a stepping stone toward LiDAR, and not interchangeable with it.

---

## 17. Coded Apertures Beyond Photography: Astronomy and Microscopy

Two brief forward pointers to where coded apertures show up outside ordinary cameras:

- **Astronomy.** Some wavelengths — x-rays and gamma rays specifically — cannot be focused by any ordinary lens at all (no transparent, refractive material works at those wavelengths), so coded apertures are used directly in place of a lens, e.g. on NASA's *Swift* and ESA's *INTEGRAL*/SPI space telescopes.
- **Microscopy.** For very low-light imaging, coding the *refraction* (rather than simply attenuating light with a patterned mask) loses less of the already-scarce light — one example the lecture shows is a rotating "double helix" PSF (Stanford Moerner lab), an engineered PSF shape whose orientation rotates with depth, giving depth information directly from its rotation angle in a single image, the same underlying idea as §16's depth-encoding PSFs, just engineered as a refractive rather than attenuating pattern.

---

## 18. Motion Blur and Deblurring: The Flutter Shutter

### 18.1 Why motion deblurring is hard

Week 2 §13.5 already built the core mechanism: an object moving during the exposure smears across the sensor, and — for uniform motion along one direction — that smear is a **convolution** of the sharp image with a **box kernel** (a flat line segment as long as the motion streak), giving a **banded Toeplitz matrix B** (Week 2 §13.5's own linear-algebra view). This lecture restates the difficulty in exactly two parts: **(1)** the motion PSF may be unknown, and different for every differently-moving object in the same frame, and **(2)** the motion PSF is difficult to invert — the specific problem worked out precisely below.

### 18.2 The box shutter's sinc zeros vs. the coded shutter's broadband spectrum

**The traditional camera: a box filter.** An ordinary shutter is open continuously for the whole exposure time, so the blur kernel is a flat **box function** of width *W* (the motion-blur streak length in pixels, exactly Week 2 §13.5's own "blur length = image-plane speed × exposure time" worked formula). The Fourier transform of a box function is a **sinc function** — and a sinc has **exact zeros**, at regularly spaced spatial frequencies *f* = *n*/*W* for every nonzero integer *n*. At each of those exact-zero frequencies, the box kernel's OTF (§13.2) is exactly 0: whatever detail existed in the true scene at that spatial frequency is completely destroyed by the blur, with no way for any deconvolution algorithm to recover it — precisely Week 2 §13.5's "detail at those frequencies... lands in **B**'s null space, and is lost."

**Flutter shutter (Raskar et al., 2006): a coded filter.** Instead of leaving the shutter open continuously, **flicker it open and closed** in a specific, precomputed pattern *within* the same total exposure duration — the shutter is "OPEN & CLOSED" during the exposure, rather than simply "OPEN." The resulting blur kernel is no longer a smooth box, but a jagged 0/1 sequence following that flicker pattern. Its Fourier transform is **broadband** — nonzero (if uneven and noise-like in appearance) across the whole frequency range, with **no exact zeros** anywhere in-band. The lecture's own side-by-side Fourier-magnitude plots make this directly visible: the traditional box shutter's spectrum shows a smoothly decaying sinc curve dipping repeatedly all the way to zero, while the coded shutter's spectrum is a rough, irregular curve that never touches zero — captioned, in the lecture's own words, **"Preserves High Frequencies!!!"**

**Term-by-term.** *W* — the motion-blur streak length in pixels, i.e. image-plane speed × exposure time (Week 2 §13.5); it is fixed by the scene and the exposure time, not something you directly design. *f* — spatial (image) frequency, cycles per pixel (Week 1 §12.2.1), the same axis as every other spectrum in this course. The sinc's zero locations, *f* = *n*/*W*, are entirely determined by the streak length alone — every box-shutter photograph of a given motion speed has zeros at exactly the same frequencies, regardless of scene content. The coded shutter's specific open/closed sequence is a designed, precomputed binary code (chosen by Raskar et al. to be broadband); the lecture gives no closed-form formula for that particular sequence, only its resulting Fourier-magnitude behavior.

**Diagram.** (See Fig. — companion diagram: a box kernel and its sinc-shaped, zero-crossing Fourier magnitude on one side; a flickered/coded kernel and its zero-free, broadband Fourier magnitude on the other — reproducing the lecture's own side-by-side "traditional camera: box filter" vs. "flutter shutter: coded filter" comparison.)

**Linear-algebra view (extending Week 2 §13.5 with this week's OTF vocabulary).** Both the box-shutter blur and the flutter-shutter blur are the *same kind* of matrix — a banded Toeplitz convolution matrix **B** (Week 2 §13.5) — differing only in *which* kernel fills its bands. The box kernel's **B** has eigenvalues (its own DFT, i.e. its OTF) that hit exactly zero at the sinc's zero-crossing frequencies — a **nontrivial null space**, meaning those directions in image space are genuinely unrecoverable, exactly as in §14.2's circular-PSF case. The coded kernel's **B** has an OTF that is nonzero at every frequency — a **trivial null space** — so, in principle, **B** is invertible everywhere, and the deconvolution problem becomes *well-posed* rather than fundamentally impossible (though, as with any real inversion, frequencies where the OTF is merely *small* rather than exactly zero still amplify noise heavily when inverted — a preview of exactly the trade-off Wiener deconvolution, Week 5, is built to manage).

**Application: license plate retrieval.** The lecture demonstrates flutter shutter recovering legible license-plate text from a photograph of a fast-moving car that a conventional (box-shutter) long exposure would have rendered as an unreadable smear — a direct, concrete payoff of trading the box kernel's unrecoverable null-space frequencies for the coded kernel's fully invertible spectrum.

---

## 19. Parabolic Sweep / Motion-Invariant Photography

### 19.1 From coding *when* the shutter is open to coding *how the camera moves*

Flutter shutter (§18) fixes the *invertibility* problem for one specific, already-known motion. But §18.1's first difficulty remains even with a broadband shutter code: an ordinary static camera still records a **different** blur kernel for every differently-moving object in the same frame (a fast car and a stationary background have completely different streak lengths, §18.2), so a single deconvolution kernel still can't undo the whole frame at once. **Motion-invariant photography** extends the same broadband-spectrum idea one level further — instead of coding *when* the shutter is open (§18), it codes the **camera's own motion trajectory** *during* the exposure, so that the resulting blur kernel becomes the *same* for every object in the scene, regardless of that object's own individual velocity.

**The mechanism: a parabolic sweep.** If the camera's own position over time follows a **parabola** (i.e., the camera *accelerates* at a constant rate throughout the exposure, rather than staying still or moving at constant velocity), then every scene object — whatever its own true velocity — ends up matching the camera's own instantaneous velocity at *some* moment during the sweep. This is the same underlying meta-strategy as focal sweep (§15.2): rather than picking one fixed value of a nuisance parameter (there, defocus scale; here, relative velocity) and hoping it matches every scene point, *sweep through a whole range of that parameter during one exposure*, so every scene point ends up equally (mis)matched on average, and the resulting blur kernel stops depending on the parameter that used to vary. The payoff, stated as the lecture frames it: "everything is blurry" (nothing is left perfectly sharp, since the camera itself is now always in relative motion with respect to any single fixed velocity) — but the blur kernel is now **motion invariant**, the same for every object regardless of its own individual velocity, which is exactly the property needed for a single, shared deconvolution kernel to work across the whole frame at once.

### 19.2 Hardware implementation

Physically sweeping a camera through a true parabolic *translation* is awkward; the lecture's implementation instead **approximates a small translation by a small rotation**: the camera sits on a lever of variable radius, mounted on a rotating platform. Over a small enough angular sweep, a point at the end of a sufficiently long lever arm traces an arc that closely approximates the desired parabolic velocity profile, avoiding the need for dedicated linear-motion hardware.

**Results.** Comparing a static camera's capture of a scene with several differently-moving objects (each showing its own unknown, differently-sized blur) against the same scene captured with the parabolic sweep (uniformly blurry, by design) and then deconvolved with one shared kernel: the parabolic-sweep-plus-deconvolution result recovers a sharp image across every object's velocity at once, where the static camera's own captured blur is simply unrecoverable per-object without first somehow knowing each object's own individual speed. The lecture also shows one case where the technique visibly fails, posed as an open question ("why does it fail in this case?") without a stated answer on the slide itself — a plausible reading, consistent with the mechanism just described (though not stated explicitly by the lecture): motion invariance only holds for velocities *within* the range the parabola's own acceleration was designed to sweep through, so an object moving outside that assumed range would fall back to showing ordinary, uncorrected blur.

---

## 20. Coded Imaging with Neural Sensors, and What's Next

One further brief pointer the lecture flags without elaborating: **coded imaging with neural sensors** (Martel et al., 2020) — programmable image sensors whose individual pixel exposures can themselves be *learned*, rather than fixed by a separate coded aperture or shutter pattern, blurring the line between "coding the optics" (§§12–19) and "coding the sensor's own per-pixel readout" directly. The lecture's own closing line points forward to the next lecture's topic: **image processing with neural networks**.

---

## 21. Looking Ahead

This lecture's own reference list closes Part 2 with exactly the papers cited by name throughout §§12–20 (Veeraraghavan et al. 2007; Dowski & Cathey 1995 and Nagahara et al. 2008 for extended depth of field; Godard et al. 2017, Chang & Wetzstein 2019, Ikoma et al. 2021 for depth estimation; Raskar et al. 2006 for flutter shutter; Levin et al. 2008 for motion-invariant photography; Martel et al. 2020 for neural sensors) — no further derivation of any of them is needed here, since each was already built from first principles above.

Two formal topics get properly built starting next week, both already previewed informally in this file and in earlier weeks:

- **Week 5, "Sampling, Linear Systems, Deconvolution."** This is where **PS3's Task 2** (deconvolution and inverse filtering, and **Wiener deconvolution** specifically) belongs — the formal machinery for actually inverting a known PSF/OTF (§13), including how to handle the noise-amplification problem this file's §18.2 flagged for near-zero (rather than exactly-zero) OTF values. Week 5 also formalizes the sampling theorem and aliasing, already used informally in Week 2 §10.2, and gives the exact discrete Fourier transform machinery Week 1 §12.4 built only partially.
- **Week 6, "Regularized Inverse Problems with ADMM."** This is where **PS3's Task 3** (gradient descent and stochastic gradient descent, as a general method for solving optimization problems of the form minimize ½‖**A**x − b‖²) belongs, together with the natural-image priors Week 1 §12.4.5 already forward-pointed to — the general framework for solving under-determined or ill-posed inverse problems (demosaicking's null space, Week 3 §10.1; the circular/box-kernel null spaces of §§14, 18 above) by adding extra assumptions about what a plausible image looks like.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check

**Part 1.** If you can explain, in your own words, *why* HDR imaging and tonemapping are described as "distinct techniques with different goals" even though a single consumer "HDR photo" workflow runs both back to back — using only the words "radiometrically linear," "confidence weight," and "display's available range" — you've understood the core distinction of Part 1.

**Part 2.** If a friend asked you "why does coding the shutter or the aperture actually help, if the image still looks blurry either way?", you should be able to answer using only the words "OTF," "null space," and "broadband" — without needing to look anything up.
