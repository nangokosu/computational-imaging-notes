# CSC2529 Computational Imaging — Week 3 Study Notes

**Topic:** Digital Photography II — Color Science & the Camera Processing Pipeline
**Source:** Lecture 3 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 2 ("PS2," a TA problem session covering HW2), Task 2 (image processing pipeline: demosaicing, gamma correction) and Task 3 (denoising).
**Scope:** Announcements skipped. The lecture's own "Review" slides (sensors-as-buckets, Bayer color filter arrays, per-pixel perspective) are skipped here since Week 1 §4 and Week 2 §11 already cover this ground — notes start from "Color is an artifact of human perception." Historical/biographical detail in the source slides (early color-photography techniques and the people behind them) is omitted per this project's no-history policy — a technique is described only by what it does; a paper is cited only by author/year, the way the course itself cites it.
**Exam note:** this week reuses some single-letter symbols from earlier weeks with different meanings — most importantly, the capital letter **D** meant "aperture diameter" in Week 2 (§8) but means a **gradient/difference term** in this week's demosaicking formulas (§10.5). Keep track of which week's formula you're in.

---

# Part 1 — Color

## 0. Why color needs formal treatment now

Week 1 §3 already introduced the basic facts: the retina has three cone types (S, M, L) with overlapping wavelength sensitivities, color perception is therefore a **tristimulus** (three-number) representation rather than a direct measurement of wavelength, and two physically different spectra that produce the same three cone responses are **metamers** — indistinguishable to the eye. Week 2 §11's Bayer color filter array is the camera's own three-channel-per-neighborhood answer to the same problem. Neither week formalized *why* three numbers are enough, what geometric shape the space of achievable colors takes, or why building a color camera or display turns out to be harder than "just measure/reproduce the spectrum." That formalization is this section's job.

The lecture's own review slides (sensors as buckets integrating incident light; the Bayer pattern; each pixel seeing the scene from a slightly different perspective) are skipped here — they restate Week 1 §4 and Week 2 §11 without adding anything new.

---

## 1. Spectral Sensitivity Function (SSF)

**Setup.** Any light sensor — a cone cell in the retina, a photodiode under a Bayer filter, a spectrometer, anything that turns incident light into a single number — responds differently to light at different wavelengths. That per-wavelength responsiveness is the sensor's **spectral sensitivity function (SSF)**, written *f*(λ): a curve giving "how strongly does this sensor respond to one unit of light at wavelength λ," for every wavelength λ the sensor can detect at all.

Incoming light itself is described by its **spectral power distribution (SPD)**, written Φ(λ): how much power the light source emits (or how much radiance reaches the sensor) at each wavelength. This is a *physical* description of the light, with no reference to any sensor or observer — the same SPD illuminates every sensor in the room identically; what differs is how each sensor's own *f*(λ) reacts to it.

**The formula:**

```
R = ∫ Φ(λ) · f(λ) dλ
```

**Intuition.** The sensor doesn't report "how much light of exactly this wavelength arrived" — it reports one aggregate number summarizing the *entire* spectrum, weighted by how sensitive it happens to be at each wavelength. Wavelengths where *f*(λ) is large contribute heavily to the final response even if Φ(λ) there is modest; wavelengths where *f*(λ) is near zero contribute almost nothing to *R* no matter how much power Φ(λ) carries there. This is exactly the "weighted combination" idea the lecture states directly: light contributes more at wavelengths where the sensor has higher sensitivity.

**Term-by-term:**
- *R* — the sensor's scalar output (a single number, e.g. one cone cell's firing rate or one photodiode's accumulated charge). This is what gets measured.
- Φ(λ) — the incident light's SPD, a property of the *scene and illumination*, not the sensor. Units: power per unit wavelength.
- *f*(λ) — the sensor's SSF, a property of the *sensor* (fixed by the physical/chemical/electronic design — a cone cell's pigment, or a camera pixel's color filter plus photodiode response), not the scene.
- The integral runs over the wavelength range the sensor can respond to at all (for a human cone or an RGB camera pixel, this is essentially the visible range, roughly 400–700 nm per Week 1 §3); outside that range *f*(λ) is taken to be zero, so those wavelengths don't contribute regardless of how much power Φ(λ) carries there.

**Why this is a general fact, not a geometric one.** This is a dot-product-style weighted integral — it describes a *relationship between two functions*, not a shape in space, so there is nothing to draw. It applies identically whether the sensor is a retinal cone or a camera pixel, and it is the single mechanism underlying everything else in Part 1: three cone SSFs (or three camera-filter SSFs) applied to the same Φ(λ) is exactly how a spectrum becomes three numbers.

---

## 2. The Retinal (Tristimulus) Color Space

Apply §1's formula three times — once per cone SSF (S, M, L, from Week 1 §3) — to the same incident light, and the result is a point (S, M, L) in a 3D space. This section builds the geometric picture of what region of that 3D space is actually reachable by real light, and formalizes metamerism as a fact about that geometry.

**The "lasso curve."** Consider a **pure beam**: a single, idealized monochromatic light source (a laser) at one exact wavelength λ, with Φ(λ) a single spike. Sweep λ across the visible range and plot the resulting (S, M, L) triplet at each wavelength — this traces a curve through 3D space, one point per wavelength. The lecture calls this the **lasso curve**, and it has three notable properties, each a direct consequence of §1's formula:

- **It is confined to the positive octant** (S ≥ 0, M ≥ 0, L ≥ 0 everywhere along the curve). Both Φ(λ) (physical light power) and every cone's *f*(λ) (a physical sensitivity) are non-negative by construction, so the integral in §1 — a non-negative function times a non-negative function, integrated — can never come out negative. No real light can produce a negative cone response.
- **It starts and ends at the origin.** At the extreme ends of the visible range, all three cone SSFs taper off toward zero (Week 1 §3's S/M/L curves are bell-shaped, not flat), so a monochromatic spike at the very edge of visibility produces a vanishingly small response in all three cones at once — (S, M, L) ≈ (0, 0, 0).
- **It never comes close to the M axis** (i.e., it never produces a response that is almost-purely-M with S and L near zero). Week 1 §3 already noted the M and L sensitivity curves overlap heavily — there is no wavelength at which M responds strongly while L stays near zero, because their peaks sit close together and their curves largely track each other. A monochromatic light strong enough to drive M substantially always drives L at least somewhat too.

*(A diagram would make this curve's shape immediately clear — a looping, lasso-shaped path swept through the positive octant of a 3D S-M-L space, bulging away from the M axis. That visualization belongs in the project's artifact, not this file; it's noted here in prose only.)*

**From curve to cone.** The lasso curve above assumed one fixed laser strength (brightness) per wavelength. Because §1's formula is linear in Φ(λ), scaling a monochromatic beam's power by some factor scales its (S, M, L) response by that same factor — the response point simply moves out along the ray from the origin through that wavelength's lasso point. Sweeping every wavelength through every possible strength (from off, to arbitrarily bright) doesn't just give one curve — it sweeps out an entire solid, **convex, radial cone**: for every point on the lasso curve, the entire ray from the origin through that point (at every non-negative scale) is also reachable. A cross-section of this cone at any fixed radius (fixed overall intensity) reproduces the lasso curve's own shape — the lecture's **"horseshoe" cross-section**, so named because the curve's shape (looping away from, and never crossing near, the M axis) resembles a horseshoe.

**Mixed beams and metamerism, formalized.** A **mixed beam** — ordinary light, which is essentially never purely monochromatic — is a sum (or, in the continuous case, an integral) of many wavelengths' contributions at once. Because §1's formula is linear, the response to a mix of several pure beams is just the sum of each pure beam's own response, scaled by its relative contribution. Geometrically, this makes the mixed beam's (S, M, L) point a **convex combination** of points on the cone's boundary surface — a weighted average with non-negative weights — which necessarily lands *inside* the convex cone (on the boundary only in the special case of a single pure wavelength). This is exactly why every real, physically achievable color's tristimulus coordinate lies somewhere in this cone, never outside it.

This geometric picture **formalizes Week 1 §3's metamerism**: since the map from a full spectrum Φ(λ) down to a single 3D point (S, M, L) is many-to-one (an entire continuous function collapsed to three numbers), many different spectra — potentially infinitely many — land on the exact same interior point of the cone. Any two of those spectra are **metamers**: physically different light, identical retinal color, because the eye never measures the spectrum directly, only this one 3D projection of it.

---

## 3. CIE Color Matching Experiments

Section 2 described the space of achievable colors abstractly, in terms of cone responses no one can observe directly. The **CIE color matching experiment** is the practical procedure used to *measure* that space using only what an observer can report: whether two lights look the same.

**Setup.** Pick a small fixed set of reference lights, the **primaries** (in the classic experiment, three fixed, nameable lights). Also pick a **test light** — the color to be matched. An observer views a split field: primaries mixed together on one side, the test light on the other. The experimenter adjusts the *strengths* (intensities) of the primaries — how much of each is mixed in — until the combined primary mixture looks visually identical to the test light. "Looks identical" here means exactly what §2 built: the primary mixture and the test light produce the same (S, M, L) triplet, i.e. they are metamers of each other, even though the primary mixture's own spectrum is (in general) nothing like the test light's spectrum. This identity is written with an equality symbol meaning "has the same retinal color as" / "is metameric to," not "is the same physical spectrum as."

**Why some matches need negative coefficients.** For many test colors, no non-negative combination of the three primaries' strengths can reproduce the test color — the observer simply cannot make the primary side look right no matter how they adjust the knobs, because the required primary mixture would need to be *more saturated* than any achievable combination of those three specific primaries allows. The experimental fix: instead of trying to subtract light from the primary mixture (physically impossible — a light source can only add photons, never remove them), the experimenter adds some amount of one primary **to the test side instead**. Adding light to the test side and matching what remains is mathematically equivalent to subtracting that same amount from the primary side — so the coefficient recorded for that primary in the final result is written as **negative**, even though what physically happened was addition, just on the other side of the equation. Repeating this matching experiment for pure test beams across the visible spectrum, and recording each primary's required coefficient (positive when added normally to the primary side, negative when it had to be added to the test side instead) at every wavelength, produces the **color matching functions** for that choice of primaries.

---

## 4. Two Equivalent Views, and the CIE RGB → XYZ Trade-off

**Two views of the same retinal color.** The lecture states these as formally equivalent:
- **Analytic view** (§1's machinery): retinal color is produced by *analyzing* a spectral power distribution — taking the dot product (§1's integral) of Φ(λ) against a set of sensitivity functions.
- **Synthetic view** (§3's machinery): retinal color is produced by *synthesizing* a matching mixture of physical color primaries, recording the weights (color matching functions) needed.

These are the same underlying fact seen from two directions: a set of color matching functions (§3) *is* a set of color sensitivity functions (§1) — for any chosen set of primaries, there exists a corresponding set of matching functions that plays the exact same mathematical role as an SSF. Analyzing a spectrum with those matching functions gives the identical coefficients that synthesizing with the corresponding primaries would require.

**CIE RGB.** Running the §3 experiment with a specific, standardized set of three physical primaries (fixed reference lights, standardized by the International Commission on Illumination based on pooled color-matching data from a panel of human observers) gives the **CIE RGB color space** — three color matching functions, one per primary. As §3 already showed, some test wavelengths require a negative coefficient in this basis: **CIE RGB's primaries are physical (realizable, non-negative light), but its coordinates are not guaranteed non-negative for every real color.**

**CIE XYZ.** The CIE also defines a second, purely mathematical set of three "primaries" — not any real, physically producible lights, but linear combinations of the CIE RGB primaries chosen specifically so that **every** real color's coordinates in this new basis come out non-negative. This is **CIE XYZ**. The price: XYZ's own "primaries" are not physically realizable light sources — they are mathematical constructs (in effect requiring negative light to actually produce), useful only as a coordinate system, never as an actual set of projector bulbs.

**The fundamental problem, stated explicitly.** You can choose a basis with physically realizable (non-negative) primaries, or you can choose a basis where every real color gets non-negative coordinates — **but not both at once.** CIE RGB picks the first (real primaries, some negative coordinates); CIE XYZ picks the second (non-negative coordinates, imaginary primaries). This is not a limitation of either particular choice — it is a geometric fact about the shape of the achievable-color cone from §2: no flat, three-sided (triangular) coordinate frame can simultaneously contain that whole rounded, horseshoe-cross-sectioned cone within its non-negative octant *and* have its three corner "primary" directions sit on the cone's own physically-achievable boundary.

---

## 5. CIE xy Chromaticity Diagram

CIE XYZ (§4) is a 3D space, and one of its three axes, *Y*, is specifically designed to carry the color's overall **luminance/brightness**. Often what's wanted for comparing colors is not "how bright is it" but purely "what hue and saturation is it" — the same color, brighter or dimmer, should be treated as "the same color." The **CIE xy chromaticity coordinates** strip out the brightness dimension:

```
x = X / (X + Y + Z)
y = Y / (X + Y + Z)
```

(a third coordinate, z = Z/(X+Y+Z), is never needed separately since x + y + z = 1 by construction — once x and y are known, z is determined.)

**Intuition.** This is a **perspective projection** of the 3D tristimulus space onto a 2D plane: dividing every coordinate by the total X+Y+Z collapses each ray from the origin (§2's cone is built entirely of such rays — recall that scaling a beam's strength just moves its point out along a ray from the origin) down to the single point where that ray crosses the plane X+Y+Z=1. Every color along that ray — same hue and saturation, different overall brightness — projects to the exact same (x,y) point. What's discarded is precisely "how far out along the ray," i.e. luminance; what survives is precisely "which ray," i.e. chromaticity.

**Term-by-term:**
- *X, Y, Z* — the CIE XYZ tristimulus coordinates from §4 (Y specifically carrying luminance by the standard's own design).
- *x, y* — the two chromaticity coordinates, each a dimensionless ratio (values roughly between 0 and 1 for real colors).
- The denominator *X+Y+Z* is exactly the "distance out along the ray" (in this coordinate system) being divided out.

*(This is genuinely a geometric construction — a diagram showing the 3D cone from §2 being collapsed onto the X+Y+Z=1 plane by rays from the origin would make the projection immediately intuitive. That diagram belongs in the artifact, not here.)*

---

## 6. Color Gamuts

A device's **gamut** is the set of colors it can actually produce (a display) or actually capture as physically distinct (a sensor), expressed as a region of the chromaticity diagram (§5).

**Why three real primaries always give a triangle.** Any real display or printer builds every color it shows as a non-negative-weighted combination of a small, fixed set of primaries — usually three (red, green, blue phosphors/LEDs/inks). In chromaticity coordinates, each primary is a single fixed point. A non-negative combination of three fixed points, normalized to sum to one (exactly what a convex combination is), sweeps out precisely the **triangle** whose corners are those three points — nothing outside that triangle is reachable by any non-negative mixture, and everything inside is. This is the same convex-combination logic §2 used for mixed beams, just carried through the chromaticity projection.

**sRGB gamut.** **sRGB** is the standard RGB color space most consumer displays, cameras, and image files (including JPEG) target. Its gamut is exactly such a triangle: the three corners are its three standard primaries' chromaticity coordinates, the interior is every color reproducible as some non-negative mix of those three primaries, and — critically — the exterior is every color that would require a **negative** coordinate to express in that primary basis. "Outside the triangle" is not a vague notion of "very saturated" — it is the precise, geometric restatement of §4's fundamental problem: a color outside the gamut triangle is one that cannot be built from these three specific real primaries without an impossible negative contribution from at least one of them.

**Other RGB spaces.** Different devices and standards (camera-native RGB spaces, wider-gamut display standards, etc.) use different sets of primaries, and therefore trace out *different* triangles in the same chromaticity diagram — some larger than sRGB's, some smaller, some overlapping only partially. Comparing gamuts this way — as triangles inscribed in the same 2D chromaticity diagram — is exactly how the lecture's "gamuts of various common industrial RGB spaces" comparison works: each space's reachable-color triangle sits differently inside the full horseshoe-shaped boundary of all humanly visible chromaticities (that horseshoe boundary being, precisely, the 2D projection of §2's lasso curve).

---

## 7. Take-Home Synthesis

Putting §4's fundamental problem and §6's gamut-triangle geometry together: **no RGB space can simultaneously have physically realizable (non-negative) primaries and guarantee non-negative coordinates for every real color.** Any triangle built from three real, physical primary points is strictly smaller than the full horseshoe of achievable chromaticities (§2, §5) — some real colors always fall outside it. The only way to *cover* every real color with non-negative coordinates (as CIE XYZ does) is to give up on the primaries themselves being physically producible light.

This is precisely why **consumer devices disagree on color without calibration**: different cameras, displays, and printers use different physical primaries, hence different gamut triangles, hence different mappings from "RGB numbers" to actual chromaticity. A raw RGB triplet carries no meaning at all unless you also know *which* device's primaries it's expressed relative to — the same three numbers mean a different actual color on two different uncalibrated screens. Standards like sRGB exist to fix one agreed-upon triangle that everyone is supposed to target, but a consumer display that isn't calibrated to actually hit sRGB's specific primaries will still render the same RGB numbers as a visibly different color than a calibrated one.

---

## 8. Other Ways to Capture Color

Week 2 §11 already covered the dominant approach — a **Bayer color filter array** glued over a single sensor, with per-pixel color filters and reconstruction (demosaicking) filling in the missing channels afterward. Several other capture strategies avoid demosaicking entirely, at a cost in size, cost, or capture speed:

- **Three-sensor (beam-splitter) cameras.** A prism assembly physically splits the incoming light into three separate beams — sent to three *separate*, full-resolution sensors, one behind a red filter, one behind a green filter, one behind a blue filter. Every pixel location gets a true, simultaneously measured R, G, and B value — no interpolation needed — at the cost of three sensors, precise optical alignment, and a bulkier/more expensive camera body.
- **Vertically stacked sensors (Foveon X3–style).** Rather than splitting light optically before it reaches the sensor, this design exploits a property of silicon itself: different wavelengths of light penetrate to different depths before being absorbed (shorter wavelengths absorbed nearer the surface, longer wavelengths deeper). Stacking three photodiode layers at different depths *underneath a single pixel location* lets that one location register an approximate red, green, and blue response simultaneously, again without needing to interpolate from neighboring pixels of different colors.
- **Field-sequential capture.** Instead of splitting color spatially at all, capture three separate exposures in sequence — one through a red filter, one through green, one through blue (e.g. via a rotating filter wheel) — and combine the three monochrome frames afterward into one color image. This only works cleanly for static scenes under controlled, unchanging illumination, since anything that moves (or any lighting that flickers) between the three sequential exposures will misalign across channels.

**Beyond the visible range.** Some sensors are deliberately built to respond outside the roughly 400–700 nm range human cones cover. Ordinary silicon photodiodes already have some sensitivity into the **near-infrared**, so an added channel (RGB + near-IR, alongside the usual Bayer channels) is a straightforward extension of the same silicon sensor technology. Reaching much further out — **thermal infrared** — requires abandoning silicon altogether, since silicon simply doesn't absorb photons that far into the infrared usefully; thermal sensors instead use other photodiode materials (e.g. indium-, mercury-, or lead-based compounds) and non-glass optics (e.g. germanium, which is transparent to thermal IR wavelengths where ordinary glass is opaque).

---

# Part 2 — Camera Processing Pipeline

## 9. From RAW to a Finished Photo

Week 2 §16.1 already built the chain from incident photons to a stored **RAW image**: photodiode → ISO-gain amplifier → ADC quantization, with shot noise, fixed-pattern noise, and quantization noise entering along the way (not repeated here). This section picks up exactly where that left off — the RAW image is a single-channel-per-pixel Bayer mosaic (Week 2 §11), and everything else needed to turn it into a viewable color photo happens in the **image signal processing (ISP) pipeline**:

```
RAW image → demosaicking → denoising → gamut mapping → gamma correction → compression → JPEG image
```

**Also part of a real pipeline** (mentioned by the lecture, not deep-dived here since HW2 doesn't exercise them): dead-pixel removal (patching over known-defective sensor sites), dark-frame subtraction (subtracting a no-light reference exposure to cancel fixed-pattern/thermal noise — Week 2 §16.1), lens-blur/vignetting/distortion correction (compensating for the aberrations of Week 2 §6), and sharpening/edge enhancement. The lecture's slides also separately list **digital autoexposure** and **white balancing** as pipeline stages sitting alongside demosaicking and gamma correction; both are mentioned here for completeness but, like the "also" list above, aren't built up further since HW2's own tasks are demosaicking, denoising, and gamma correction specifically.

Each subsequent section below (§10–§14) covers one pipeline stage in the depth HW2 or the lecture actually demands.

**Exif metadata.** Alongside the pixel data itself, a finished image file typically stores **Exif** ("exchangeable image file format") metadata — capture settings and context (exposure time, aperture, ISO, timestamp, lens model, and similar) embedded directly in the file next to the pixel data.

---

## 10. Demosaicking

Demosaicking (Week 1 §4) is the reconstruction step that turns a single-channel-per-pixel Bayer mosaic into a full three-channel-per-pixel RGB image, by estimating each pixel's two *unmeasured* channels from its neighbors. This section builds up through increasingly capable methods, in the order HW2/PS2 present them.

### 10.1 Naive (Linear) Interpolation

The simplest approach: estimate each missing channel value at a pixel by averaging the nearest neighboring pixels that *did* measure that channel. For the green channel specifically (present at every other pixel in the Bayer mosaic — Week 1 §4's "RGGB," green doubled), the four nearest green-measuring neighbors of any non-green pixel are its four orthogonal (up/down/left/right) neighbors:

```
ĝ(x,y) = (1/4) · Σ g(x+m, y+n),   (m,n) ∈ {(0,−1), (0,1), (−1,0), (1,0)}
```

**Term-by-term:** ĝ(x,y) is the *estimated* (hatted, meaning "reconstructed, not directly measured") green value at pixel location (x,y); the sum runs over the four orthogonal offsets, i.e. the four immediate neighbors; each g(x+m,y+n) is an actually-measured green value at one of those neighboring pixels (guaranteed to exist at exactly those four offsets by the Bayer pattern's regular structure). Red and blue are filled in the same way — average of the nearest same-color neighbors — though the exact offset pattern differs slightly since red and blue pixels are sparser (one per 2×2 tile, vs. green's two per tile) and diagonally rather than orthogonally arranged relative to each other in places.

**Implementation note (from PS2).** PS2 suggests two equivalent routes: calling a general 2D interpolation routine (e.g. `scipy.interpolate.interp2d`) separately on each channel's known-sample locations, or — specifically for green, since it's easier — averaging several `np.roll`-shifted copies of the sparse green channel (shifting the array up/down/left/right by one pixel and averaging the shifted copies at each missing location reproduces exactly the four-neighbor average above without needing a general-purpose interpolator). Described here as a technique, not worked through as running code.

Naive interpolation like this tends to introduce visible color fringing/artifacts near edges — each channel is interpolated *independently*, ignoring the fact that a real edge should show up consistently across all three channels at once. §10.3–§10.5 address this in increasingly sophisticated ways.

### 10.2 Aside: The Optical Low-Pass Filter (OLPF)

Because the Bayer mosaic samples each color channel at less than the sensor's full pixel resolution (green at half density, red and blue at a quarter each), fine scene detail near or beyond what that reduced sampling density can represent risks **aliasing** — showing up, after demosaicking, as false color patterns (moiré) that were never in the original scene. (Aliasing itself is formalized properly with the sampling theorem in Week 5; the intuition needed here is just that under-sampling fine periodic detail can fold it into spurious low-frequency artifacts.)

Many sensors sit behind an **optical low-pass filter (OLPF)**, also called an optical anti-aliasing filter — a glass sheet placed directly in front of the sensor that slightly pre-blurs the incoming light *before* it ever reaches the pixel grid, specifically to attenuate detail fine enough to alias, before sampling ever happens. It's commonly built from two **birefringent** layers (a birefringent material splits a single incoming ray into two, based on the light's polarization), combined with an infrared-blocking filter; stacking two such splitting layers turns one incoming ray into four, which together act as a small 4-tap discrete convolution (blurring) kernel applied optically, before the sensor ever sees the light.

**The trade-off.** An OLPF removes the risk of aliasing, but it does so by removing genuine fine detail along with it — a straightforward resolution-vs-aliasing trade, the same tension Week 2 §2 already encountered between geometric blur and diffraction for pinhole size, now appearing as a deliberate design choice rather than an unavoidable physical limit. Because it's a *choice*, some photographers physically remove the OLPF from their camera ("hot-rodding") to trade back some aliasing risk for maximum resolution, and manufacturers sometimes sell otherwise-identical camera models with and without the OLPF installed, aimed at photographers who have made that trade-off deliberately.

### 10.3 Chrominance Low-Pass Demosaicking

Naive per-channel interpolation (§10.1) still leaves color-fringing artifacts, especially near edges, because red, green, and blue are each interpolated independently with no shared structure. A cheap fix exploits an asymmetry in human perception: **people are far more sensitive to sharpness in luminance than in chrominance.** This is a direct extension of Week 1 §12's contrast-sensitivity material — the entire Contrast Sensitivity Function built up there describes sensitivity to *brightness* contrast; the visual system's ability to resolve fine spatial detail in pure color-without-brightness-change is considerably coarser. So blurring the *color* information slightly, while leaving *brightness* detail untouched, should be far less perceptible than blurring both together — exactly what naive per-channel interpolation risks doing when it lets color artifacts appear at full resolution.

**The procedure:**
1. Naive-demosaic all three channels as in §10.1 (a full but artifact-prone RGB image).
2. Convert from RGB to **Y′CbCr** (a luma/chrominance representation, closely related to YUV): Y′ carries luminance/brightness, Cb and Cr carry the two chrominance (color) dimensions.
3. Low-pass filter — e.g. median-filter — **only** the Cb and Cr channels, leaving Y′ untouched.
4. Convert back from Y′CbCr to RGB.

**RGB ↔ Y′CbCr conversion.** The two are related by a fixed linear (matrix) transform plus a constant offset — the standard ITU-R BT.601 form used by common image libraries (e.g. MATLAB's `rgb2ycbcr`/`ycbcr2rgb`, for R,G,B values scaled to [0,1]):

```
Y'  = 16  + 65.481·R + 128.553·G + 24.966·B
Cb  = 128 − 37.797·R − 74.203·G + 112.000·B
Cr  = 128 + 112.000·R − 93.786·G − 18.214·B
```

and the inverse, exactly as the lecture states it structurally:

```
[R; G; B] = M⁻¹ · ([Y'; Cb; Cr] − [16; 128; 128])
```

**Term-by-term:** R, G, B are the naive-demosaicked color channel values; Y′ is luma (brightness, with the standard's own gamma-related offset — the prime mark, "Y′" rather than "Y," conventionally signals that this luma is computed from already gamma-encoded RGB, not strictly-linear light, which is what makes it a good proxy for *perceived* brightness rather than physical radiance); Cb and Cr are the blue-difference and red-difference chrominance channels; the constant offsets (16, 128, 128) shift the three channels into their conventional 0–255 digital ranges so that mid-gray chrominance sits at 128 rather than 0, letting Cb/Cr represent negative color differences using only non-negative stored values; *M* is the fixed 3×3 matrix of coefficients shown above, and *M⁻¹* is its matrix inverse, used to undo the transform after the chrominance channels have been smoothed.

*(Fact-audit note: the lecture's own slide (p. 73) gives this matrix as Y′ = 65.48R + 128.55G + 24.97B, Cb = −37.80R − 74.20G + 112.00B, Cr = 112.00R − 93.79G − 18.21B, applied to R,G,B on a 0–255 scale and then multiplied by 257/65535 — which equals exactly 1/255 since 255×257 = 65535. That is algebraically the same standard BT.601 matrix given above for R,G,B scaled to [0,1], just re-expressed for 8-bit inputs; a prior draft of this note flagged the slide's coefficients as unreadable, but a fact-checking pass against the rendered slide image confirms the match, including the internal check that the Y′ row's three coefficients sum to 219.00 as BT.601 requires.)*

Filtering only Cb and Cr (e.g. via a median filter, per PS2's own suggestion of a 9×9 median window) smooths over the color artifacts naive interpolation introduced while leaving the sharp, perceptually important luminance detail fully intact.

### 10.4 Edge-Directed Interpolation (Gunturk et al. 2005)

A natural next improvement: instead of averaging only the four immediate same-color neighbors, use a **larger neighborhood** (e.g. 5×5 instead of 3×3) and use **gradient/edge information from other color channels** to guide the interpolation — the intuition being that if there's a strong edge visible in, say, the already-densely-sampled green channel at some location, the missing red or blue value there probably also has an edge in roughly the same place, rather than being independently smooth.

This class of method is a genuine improvement, but the lecture frames it explicitly as a **stepping stone**, not an endpoint, with three insights carried forward into §10.5:
- A larger pixel neighborhood generally helps accuracy, but costs more computation.
- Using gradient/edge information from *other* channels is advantageous, even though it means the estimate for one channel now depends on measurements of a different channel.
- Existing nonlinear edge-directed methods are okay, but leave something on the table — a well-designed **linear** filter can do better.

This last point sets up Malvar, He & Cutler (2004): what is the best *linear* filter for a 5×5 neighborhood that still exploits cross-channel gradient information the way edge-directed methods do?

### 10.5 Malvar–He–Cutler (2004) High-Quality Linear Interpolation

This method stays entirely **linear** (each output pixel is still a fixed weighted sum of input pixels — no data-dependent branching like a median or an edge classifier), but improves on naive interpolation (§10.1) by adding a correction term built from a gradient measured in a *different*, already-measured channel at that same location.

**The core assumption.** Sharp edges in a natural image tend to show up strongly across essentially every channel at once — a hard edge is rarely a green-only edge with no correlate in red or blue. So a strong local gradient (second-difference/Laplacian-like curvature) measured in whichever channel *is* actually sampled at a given pixel is a useful predictor that the *missing* channels at that same pixel also have a gradient there — even though those channels weren't directly measured, their local curvature can be estimated by borrowing the curvature already visible in the one channel that was.

**The formulas.** Three interpolation cases, each of the form "naive linear estimate plus a gain times a gradient term computed from the channel actually measured at that pixel":

```
ĝ(x,y) = ĝ_lin(x,y) + α · D_R(x,y)     — interpolating G at an R pixel
r̂(x,y) = r̂_lin(x,y) + β · D_G(x,y)     — interpolating R at a G pixel
r̂(x,y) = r̂_lin(x,y) + γ · D_B(x,y)     — interpolating R at a B pixel
```

(B at a G pixel and B at an R pixel are handled symmetrically, swapping the roles of R and B.)

The gradient term is a **discrete Laplacian** (local curvature/second-difference) of whichever channel is actually sampled at that pixel, using that same channel's values two pixels away in each cardinal direction (the nearest same-color samples, since the Bayer pattern repeats every 2 pixels along each axis):

```
D_R(x,y) = r(x,y) − (1/4) · Σ r(x+m, y+n),   (m,n) ∈ {(0,−2), (0,2), (−2,0), (2,0)}
```

(D_G and D_B are defined identically, substituting g or b for r.)

**Term-by-term:** ĝ_lin, r̂_lin are the plain §10.1 naive-average estimates; D_R(x,y) is "the red channel's value right here, minus the average of red's value two pixels away in each direction" — a measure of local curvature in red, computable exactly at this pixel because red *is* the channel actually sampled there (for the first formula's case). α, β, γ are fixed gain constants controlling how strongly that cross-channel curvature correction is trusted.

**The published gain constants**, exactly as given (optimized empirically against the Kodak demosaicking dataset): **α = 1/2** (multiplies the correction for interpolating G), **β = 5/8** (multiplies the correction for interpolating R or B at a G pixel), **γ = 3/4** (multiplies the correction for interpolating R at a B pixel, or B at an R pixel — the diagonal case).

**Why this works.** Naive interpolation (§10.1) only ever uses same-channel neighbors, so it's blind to any information the *other* two channels carry about where edges actually are. By the sharp-edges-are-broadband assumption above, the curvature visible in whichever channel is locally measured is a cheap, already-available proxy for the curvature the *missing* channels would show if they'd also been measured — adding a scaled copy of that curvature nudges the naive average toward the true edge-aware value, without abandoning linearity (the whole computation is still just a fixed weighted sum of RAW pixel values, expressible as ordinary linear convolution filters).

**PS2's practical framing.** Although there are several interpolation cases above, by symmetry there are only **4 unique filter shapes** needed in total (several cases are the same filter rotated or with color roles swapped). PS2 also flags a genuinely useful implementation detail: many of the filter coefficients that fall out of this derivation are **dyadic rationals** — fractions with a power-of-two denominator (e.g. 1/2, 3/4, 5/8, 3/2), not necessarily powers of two themselves — which, in fixed-point hardware, means a multiplication can be implemented with cheap bit-shifts and additions instead of a general multiply, a real reason this specific linear filter design became popular in actual camera ISPs, not just an academic curiosity.

### 10.6 PSNR and MSE

HW2 compares its several demosaicking methods (§10.1, §10.3, §10.5) **numerically**, not just by eye, using two standard error metrics.

**Mean squared error (MSE), built from first principles.** Why *squared* error rather than plain (signed) error? A plain average of (estimate − truth) would let positive and negative errors at different pixels cancel out, hiding real disagreement even when every individual pixel is badly wrong — squaring makes every error contribute positively regardless of its sign, so the average genuinely reflects typical error *magnitude*, not a misleadingly-canceled net.

```
MSE = (1 / (3·m·n)) · Σ_{i=1}^{m} Σ_{j=1}^{n} Σ_{c=1}^{3} [I_estimate(i,j,c) − I_groundtruth(i,j,c)]²
```

**Term-by-term:** *m, n* are the image's height and width in pixels; the sum runs over every pixel location (i,j) and every one of the 3 color channels *c*; I_estimate and I_groundtruth are the reconstructed and true pixel values respectively; dividing by 3·m·n averages the total squared error over every pixel-channel value in the image, so MSE doesn't simply grow with image size.

**Peak signal-to-noise ratio (PSNR), built from first principles.** MSE alone is hard to interpret in isolation — an MSE of, say, 4 means something very different for an 8-bit image (max value 255) than it would on some other scale. PSNR fixes this by expressing the error as a **ratio** against the largest possible value the signal could take, so the number is self-normalizing regardless of the pixel value range:

```
PSNR = 10 · log₁₀( max(I_groundtruth)² / MSE )
```

**Term-by-term:** max(I_groundtruth) is the largest possible (or largest actually occurring) pixel value in the reference image; squaring it puts it on the same "squared units" footing as MSE itself; the ratio is therefore dimensionless. **Why the log/dB scale?** This is the same reasoning already used for dynamic range in Week 1 §10 and f-stops in Week 2 §8: when a quantity can meaningfully span many orders of magnitude (a near-perfect reconstruction has MSE close to zero, making the raw ratio huge), a logarithmic scale compresses that huge range into small, comparable numbers, and — exactly like a photographic "stop" — each fixed additive step in the log scale corresponds to a fixed *multiplicative* factor in the underlying ratio, which matches how error/quality differences are usually discussed ("a few dB better") far more naturally than the raw ratio would. The conventional factor of 10 (rather than, say, natural log) is simply the standard **decibel (dB)** convention this metric borrows from signal processing generally.

**How HW2 uses this.** PSNR is computed *after* gamma correction (§12) is applied, and is exactly the metric used to numerically compare the demosaicking methods above against each other. No actual PSNR number is computed here — per this project's policy, that comparison is left to the assignment; only the method is given.

---

## 11. Denoising

### 11.1 The General Weighted-Average Framework

Most (not all) of the denoising techniques below are specializations of one general formula:

```
i_denoised(x) = (1 / normalizer) · Σ_{x'} w(x, x') · i_noisy(x'),
normalizer = Σ_{x'} w(x, x')
```

**Intuition.** The idea behind every method in this section is the same: average together a number of pixels that are all believed to share the same true underlying value, since random noise tends to cancel out under averaging while the shared true signal doesn't. The **entire difference between methods is only how the weight function w(x, x') is defined** — i.e., what "similar enough to average together" is taken to mean.

**Term-by-term:** *x* is the pixel currently being denoised; the sum runs over "all pixels x′" — in practice, some neighborhood or search region, not literally the whole image, for methods where w(x,x′) is zero outside some window anyway; w(x,x′) is a non-negative weight expressing how much pixel x′ should contribute to denoising pixel x; the *normalizer* — the sum of all the weights — divides the weighted sum back down so the result is a proper weighted **average** (weights summing to 1) rather than growing with however many pixels happen to be included.

The lecture groups denoising methods into four families: (1) local, linear smoothing; (2) local, nonlinear filtering; (3) anisotropic diffusion; (4) non-local methods. HW2's tasks (§11.2–§11.5 below) cover the first, second, and fourth families; anisotropic diffusion is named here only for completeness of the taxonomy and isn't built up further, since it isn't one of HW2's required methods.

### 11.2 Gaussian Filtering

The simplest choice of *w*: weight depends **only on spatial distance** between pixels, via a Gaussian falloff —

```
w(x, x') = exp( −|x − x'|² / (2σ²) )
```

Nearby pixels get high weight, distant pixels get vanishingly small weight, and *nothing* about the pixels' actual intensity values enters the weight at all — this is exactly the low-pass filtering idea already built in Week 1 §13.1 (blurring by averaging neighbors), here formalized as one specific, spatially-weighted instance of §11.1's general framework. Because the weights don't depend on the noisy image's own values, this is both **linear** (the output is a fixed linear combination of inputs, regardless of what those inputs are) and purely **local** (weight decays with distance alone).

### 11.3 Median Filtering

An almost-equally simple alternative, but **nonlinear**: rather than computing any weighted average, replace each pixel with the **median** value found within a small window centered on it —

```
i_denoised(x) = median( W(i_noisy, x) )
```

where *W(i_noisy, x)* denotes the small window of the noisy image centered at *x*. Because the median is not a linear operation (it can't be written as any fixed weighted sum of the window's pixel values), this doesn't fit neatly into §11.1's weighted-average form as written, but it shares the same "local" spirit: only nearby pixels are consulted, and the point of taking a median rather than a mean is that it's far less sensitive to a small number of extreme outlier pixels (e.g. salt-and-pepper-style noise) than an average would be.

### 11.4 Bilateral Filtering (Tomasi & Manduchi, 1998)

**The problem with plain Gaussian smoothing.** A Gaussian filter (§11.2) averages every pixel with its spatial neighbors regardless of how different their values are — which is exactly the problem, illustrated with a step edge plus noise: convolving a noisy step function with a Gaussian kernel blurs the sharp transition into a smooth ramp, because the kernel doesn't know or care that pixels on opposite sides of the edge belong to genuinely different regions; it blurs straight across the edge along with smoothing out the noise on each side.

**The fix: also weight by intensity similarity.** The **bilateral filter** multiplies §11.2's spatial Gaussian by a *second*, independent Gaussian term based on how different two pixels' actual intensity values are:

```
w(x, x') = exp( −|x − x'|² / (2σ²) ) · exp( −|i_noisy(x') − i_noisy(x)|² / (2σ_i²) )
```

**Why a product of two Gaussians is the natural way to combine these.** The filter is meant to answer "are these two pixels both *close in space* **and** *close in intensity*?" — two independent conditions that both need to hold for a strong weight. Multiplying two independent Gaussian terms is exactly the natural way to combine two independent "closeness" criteria into one joint weight: if either factor is small (pixels far apart in space, *or* very different in intensity), the product collapses toward zero, since a product is only large when *both* factors are large. Two separate, independently-tunable scale parameters control the two notions of closeness: **σ** (the spatial scale, exactly as in §11.2) and **σ_i** (the intensity scale, controlling how different in value two pixels can be before they stop being treated as "the same surface").

**Term-by-term:** the first factor is identical to §11.2's spatial Gaussian; the second factor compares the noisy intensity *at the candidate neighbor x′* against the noisy intensity *at the center pixel x* — note it deliberately uses the noisy image's own values for this comparison, since that's the only information available at filtering time; σ_i is the "intensity sigma," a separate tunable parameter from the spatial σ.

**Walking through the step-edge example again, now with bilateral weighting.** Take a noisy step edge — flat, noisy region on one side, a sharp jump, then another flat, noisy region on the other side. For a pixel sitting near the edge, its same-side neighbors have intensities close to its own (small |i(x′) − i(x)|, so the intensity-Gaussian term stays close to 1, contributing normally) — but its opposite-side neighbors, across the step, have intensities far from its own (large |i(x′) − i(x)|, so the intensity-Gaussian term collapses toward **≈0**, killing that neighbor's contribution almost entirely, *regardless* of how spatially close it might be). The result: the filter effectively only averages same-side pixels together — smoothing out the noise on each side of the edge exactly as a plain Gaussian would — while the sharp step itself survives untouched, because the intensity-difference term has zeroed out every cross-edge contribution before it could blur the transition. This dual behavior — simultaneously **noise-reducing** (within a side) and **edge-preserving** (across a side) — is what the lecture calls **"edge-aware smoothing."**

*(Applications the lecture demonstrates using exactly this edge-aware property, briefly: "digital pore removal" in portrait retouching — smoothing skin texture while keeping sharp facial edges — and cartoonization, which combines a bilaterally-smoothed image with an edge map extracted from that same smoothed image.)*

### 11.5 Non-Local Means (Buades, Coll & Morel, 2005)

**The core idea: compare patches, not single pixels.** Rather than asking "is this one neighboring pixel's *intensity* similar to mine?" (bilateral, §11.4), non-local means asks "is the small *patch* of pixels surrounding this candidate similar to the patch surrounding me?" — comparing local neighborhoods rather than single values makes the similarity judgment far more robust to per-pixel noise, since a patch-to-patch distance averages out random noise across many pixels rather than depending on one noisy sample.

```
w(x, x') = exp( −‖N(x') − N(x)‖² / (2σ²) )
```

where N(x) denotes the patch (small neighborhood) centered at x, and the difference is measured as a squared distance between the two patches' pixel values.

**"Non-local," and why a restricted search window is still needed.** Because the weight depends only on how similar two *patches* look — not on how physically close together they are — pixels far away in the image (anywhere the same texture or structure recurs) can and do contribute meaningfully, which is the whole point: this exploits **self-similarity**, the fact that natural images tend to repeat similar-looking small patches throughout the scene, not just adjacent to each other. In principle the search could span the entire image, but in practice the search is restricted to some bounded window around each pixel purely for **computational tractability** — comparing every patch against every other patch in the whole image is far too expensive to do for every pixel.

**Implementation details from PS2/HW2 itself** — flagged explicitly since these are refinements the homework's own hints ask for, not part of the base formula above:
- **(a) Exclude the self-centered window from the similarity search.** When searching for similar patches to average in, PS2 specifically asks that the window centered on the pixel currently being denoised be excluded from the search — comparing a patch against itself trivially gives zero distance (maximal, and somewhat degenerate, weight), so it's left out of the general similarity search.
- **(b) But then give the center pixel itself the maximum weight seen among its neighbors.** This is the specific nuance from PS2 slide ~29 (not part of the base lecture formula): after computing weights for all the *other* candidate patches, the center pixel's own contribution is assigned a weight equal to the **largest** weight found among its neighbors — rather than being excluded from the average altogether, or given some arbitrary fixed weight.
- **(c) Use a weighted (masked) patch comparison, not a naive unweighted distance.** Rather than a plain sum of squared differences across every pixel in a patch (all pixels contributing equally regardless of position within the patch), compare patches using a Gaussian-weighted sum — pixels near the *center* of each patch (closer to the actual pixel of interest) contribute more to the distance than pixels near the patch's edges:
  ```
  patch distance = Σ_{m,n} k_mn · (v(N_i)_mn − v(N_j)_mn)²
  ```
  where k_mn are fixed Gaussian weights over the patch's own spatial layout (larger near the patch center, smaller toward its edges) and v(N_i)_mn, v(N_j)_mn are the pixel values at offset (m,n) within patches N_i and N_j. This is stated plainly here as exactly what HW2's own assignment text asks for — not solved further.

### 11.6 Comparison: Gaussian vs. Bilateral vs. Non-Local Means

Mirroring the lecture's own "everything put together" summary:

| Method | Depends on | Behavior near edges |
|---|---|---|
| **Gaussian filtering** | Spatial distance only | Smooths everything nearby, including across edges — edges get blurred |
| **Bilateral filtering** | Spatial distance **and** intensity distance | Smooths pixels close in *both* space and intensity — edge-aware |
| **Non-local means** | Patch similarity (intensity-pattern distance) | Smooths similar patches no matter how far away — ignores spatial distance entirely |

### 11.7 BM3D (Brief, Not Required for HW2)

**BM3D** (Dabov et al.) is mentioned by the lecture as current state-of-the-art, non-local denoising — **not** one of HW2's required methods, included here only for context. The idea: find groups of mutually similar image patches (as in §11.5) and stack each group into a 3D block; apply a "collaborative filter" to the whole block at once — a DCT-style transform of the 3D block, thresholding (zeroing) small transform coefficients (the assumption being that true signal concentrates into a few large coefficients while noise spreads thinly across many small ones), then inverting the transform back to pixel values.

---

## 12. Gamma Correction

**Why encode with a gamma curve at all.** A camera's RAW sensor readout is roughly linear in physical light intensity (twice the photons in, twice the digital count out — Week 2 §16). But storage is finite: a consumer image format typically allocates only 8 bits per channel (256 levels) to represent what a 12–14-bit RAW captured (Week 2 §14). If those 256 levels were spaced *linearly* in physical intensity, most of them would be wasted on the brightest stops of the image (where human vision barely notices small brightness differences) while the darkest, most perceptually sensitive regions would be crushed into only a handful of distinct code values. Human sensitivity to luminance is, to a good first approximation, itself a power-law-like relationship rather than linear — roughly **γ ≈ 2.2** — so encoding brightness with a matching gamma curve spaces the 256 available code values so that **equal steps in code value correspond to roughly equal steps in perceived brightness**, not equal steps in physical light intensity. This is the encoding-side analog of an idea Week 1 already leaned on repeatedly (§10's log-scale dynamic range, §12's contrast-driven sensitivity): human perception of intensity is fundamentally non-linear, so any finite-precision representation aimed at a human viewer should be spaced to match perception, not physics.

**Two variants appear in the source material — disambiguated explicitly:**

**(a) PS2's simplified version.** Scale pixel values into the [0, 1] range, then apply a single power-law function directly:

```
I_out = I_in^(1/2.2)
```

**Term-by-term:** I_in is the (already [0,1]-scaled) linear intensity value; the exponent 1/2.2 is the reciprocal of the human-sensitivity gamma quoted above, per the lecture's own "roughly γ = 2.2" framing — applying an exponent less than 1 to a value in [0,1] pulls dark values up disproportionately more than bright ones, exactly the perceptually-matched spacing described above.

**(b) The lecture's exact sRGB standard.** The sRGB standard (§6's color space, also the standard gamma curve for 8-bit consumer images) uses a precise **piecewise** function rather than a single clean power law — a straight linear segment near zero (avoiding an infinite-slope singularity that a pure power law would have at exactly zero) joined to a power-law segment for the rest of the range:

```
C_sRGB = 12.92 · C_linear                          if C_linear ≤ 0.0031308
C_sRGB = (1 + α) · C_linear^(1/2.4) − α            if C_linear > 0.0031308,   α = 0.055
```

**Term-by-term:** C_linear is the linear-light input value (scaled to [0,1]); C_sRGB is the encoded output; the threshold 0.0031308 is the fixed crossover point between the two segments; 12.92 is the slope of the linear segment, chosen so the two pieces meet smoothly (matching value and, to a close approximation, matching slope) at the threshold; the exponent 1/2.4 and the constant α = 0.055 shape the power-law segment so that, taken as a whole, the piecewise curve closely approximates (though is not identical to) a pure γ = 2.2 power law across the range that matters most.

**HW2's own framing.** HW2 explicitly leaves the choice between these two open — either the simplified single power-law form (a), which is what PS2 demonstrates and uses for its own worked examples, or the exact piecewise sRGB standard (b) from the lecture, are both treated as legitimate gamma-correction methods for the assignment.

---

## 13. Gamut Mapping

A camera sensor's native color response is defined by its own physical filters, not by the sRGB primaries of §6 — so a captured image's raw tristimulus values live in the camera's own, device-specific gamut, not in any standardized space. **Gamut mapping** converts from that camera-native gamut to a standard target gamut, typically sRGB, so the resulting image displays correctly and predictably across other people's screens. Internally this is done as a chain of two color-space conversions: camera-native XYZ → standard CIE XYZ (§4) → sRGB (§6) — each step a linear transform between tristimulus bases, in the same spirit as §4's CIE RGB ↔ XYZ relationship. Different choices of exactly how this mapping projects colors that fall outside the target gamut back into it correspond to the different color "modes" (vivid, portrait, landscape, etc.) some cameras offer — different gamut-mapping strategies applied to the same underlying capture.

---

## 14. JPEG Compression

JPEG compression is lecture content, not one of HW2's tasks, so this is covered at a lighter, conceptual level. The standard pipeline:

1. **Transform to Y′CbCr** — exactly the same luma/chrominance representation built in §10.3, now used for compression rather than demosaicking.
2. **Downsample the chroma channels.** Because human vision is far more sensitive to luminance detail than chrominance detail (the identical fact §10.3 already used to justify chrominance-only low-pass filtering during demosaicking), JPEG throws away *spatial resolution* in Cb and Cr — not Y′ — to save space, at standard ratios: **4:4:4** (no downsampling — every luma sample has its own chroma sample), **4:2:2** (chroma downsampled 2× horizontally), and **4:2:0** (chroma downsampled 2× in both directions, the most aggressive of the three, and the most common default).
3. **Split into 8×8 pixel blocks.**
4. **Discrete cosine transform (DCT) each block**, per channel — conceptually the same spatial-frequency-decomposition idea as the Fourier transform built up in Week 1 §12.4 (a different but related basis of waves, here confined to small 8×8 blocks rather than the whole image).
5. **Quantize the resulting DCT coefficients** — divide each coefficient by a (typically frequency-dependent) step size and round, discarding fine distinctions in coefficients human vision is least likely to notice (typically the higher-frequency ones).
6. **Entropy/run-length code the quantized coefficients** — a lossless compression step (no further information is thrown away here) that exploits the fact that quantization tends to leave long runs of zero-valued coefficients, especially at high spatial frequencies within a block.

No full DCT derivation is needed here — the conceptual shape (transform → subsample what's least noticeable → quantize what's least noticeable → losslessly pack what's left) is what matters for this level of treatment.

---

## 15. Deblurring / Deconvolution — A One-Slide Preview

The lecture shows exactly one slide on this topic, with no formula: a single example (from Heide et al. 2016) showing a blurred input image and its deblurred/deconvolved reconstruction, alongside a short list of common blur sources — out-of-focus (defocus) blur, geometric distortion, spherical aberration, chromatic aberration (Week 2 §6 covered the optical causes of the aberrations by name), and coma. Nothing about *how* the deblurring itself works is given at this point in the course. Full treatment of deconvolution — the actual inverse-problem formulation, and how a known or estimated blur can be computationally undone — is genuinely Week 5–6 material (Week 1 §12.4.5 already forward-pointed to this); this section is only a preview that the topic exists and roughly what causes the blur it will eventually undo.

---

## 16. Looking Ahead

The lecture's own closing slide names exactly what comes next, reproduced here as-is: **sampling, filtering, deconvolution, sparse image priors** — the mathematical toolkit (Week 5's "Sampling, Linear Systems, Deconvolution" and Week 6's regularized inverse problems) needed to formalize the deconvolution preview of §15 and to properly justify the aliasing intuition used informally in §10.2.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see `glossary.md`.

---

## Quick self-check

If you can explain, in your own words, *why* CIE XYZ needs "imaginary" (non-physical) primaries while CIE RGB doesn't, but CIE RGB needs negative coordinates for some colors while CIE XYZ doesn't — using only the words "convex cone," "color matching functions," and "gamut" — you've understood the core trade-off of Part 1.

A second check, for Part 2: if a friend asked you "why does the Malvar-He-Cutler method still count as linear interpolation, if it's smarter than naive averaging?", you should be able to answer using only the words "gain constant," "gradient," and "already-measured channel" — without needing to look anything up.
