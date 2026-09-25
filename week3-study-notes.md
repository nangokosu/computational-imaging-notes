# CSC2529 Computational Imaging — Week 3 Study Notes

**Topic:** Digital Photography II — Color Science & the Camera Processing Pipeline
**Source:** Lecture 3 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 2 ("PS2," a TA problem session covering HW2), Task 2 (image processing pipeline: demosaicing, gamma correction) and Task 3 (denoising).
**Scope:** Announcements skipped. The lecture's own "Review" slides (sensors-as-buckets, Bayer color filter arrays, per-pixel perspective) are skipped here since Week 1 §4 and Week 2 §11 already cover this ground — notes start from "Color is an artifact of human perception." Historical/biographical detail in the source slides (early color-photography techniques and the people behind them) is omitted per this project's no-history policy — a technique is described only by what it does; a paper is cited only by author/year, the way the course itself cites it.
**Exam note:** this week reuses some single-letter symbols from earlier weeks with different meanings — most importantly, the capital letter **D** meant "aperture diameter" in Week 2 (§8) but means a **gradient/difference term** in this week's demosaicking formulas (§10.5). Keep track of which week's formula you're in.
**Symbol note for the "Linear-algebra view" asides:** the identity matrix is written **Id** (never I, which is the image in §10.6 and §11.8). A bare **M** used as a matrix always means the Y′CbCr matrix of §10.3 (in Part 1, M is still the medium-wavelength cone); color-space conversion matrices always carry subscripts, e.g. M_sRGB→XYZ. **G_σ** is a Gaussian-blur matrix, unrelated to the green channel G.

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

**Linear-algebra view: the SSF integral is an inner product.**
- Sample the spectrum at N evenly spaced wavelengths λ₁ … λ_N, a step Δλ apart. For example, 400–700 nm every 10 nm gives N = 31. The light becomes a vector φ ∈ ℝ^N (one power value per wavelength), and the sensor's SSF becomes a vector **f** ∈ ℝ^N.
- The integral becomes a sum: R ≈ Σ_k Φ(λ_k)·f(λ_k)·Δλ = Δλ · (**f** · φ). That is the **inner product** (dot product) of the two vectors, times the constant step Δλ.
- An inner product measures "how much of φ points along **f**," which is exactly the weighted-combination intuition above.
- It is **linear** in φ: doubling the light doubles R, and the response to two lights shown together is the sum of their separate responses. §2 builds everything on this property.

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

**Linear-algebra view: a 3×N matrix, its null space, and a cone.**
- Stack the three cone SSF vectors from §1 as the rows of a 3×N matrix **A**. Then (S, M, L) = Δλ · **A**φ: all three inner products at once. **A** maps spectrum space ℝ^N down to ℝ³ (31 numbers down to 3 in the 10 nm example). "Projection" here means this many-to-one map to fewer dimensions, not the stricter linear-algebra sense of a square matrix P with P² = P.
- The three rows are linearly independent, so **A** has rank 3. The **rank–nullity theorem** (rank + null-space dimension = number of columns) then gives a **null space** of dimension N − 3 = 28: every spectral "direction" **n** with **A n** = 0 is invisible to the eye.
- **Metamerism, exactly:** φ₁ and φ₂ are metamers precisely when **A**(φ₁ − φ₂) = 0, i.e. they differ by a null-space vector. Adding such a vector changes the light but not the color (as long as every power value stays non-negative, so it is still real light).
- **The cone is a conic hull.** Column k of **A** is the response to a unit spike at λ_k, i.e. one point of the lasso curve. The achievable cone is the set of all **non-negative combinations** Σ c_k·(column k), with every c_k ≥ 0: the **conic hull** of the lasso vectors.
- A **convex combination** is the special case whose weights are non-negative *and* sum to 1: formally, a weighted average. The paragraph above's "convex combination" is exact once total power is normalized to 1. Dropping the sum-to-1 condition is what lets brightness scale freely and turns the curve into a cone.

---

## 3. CIE Color Matching Experiments

Section 2 described the space of achievable colors abstractly, in terms of cone responses no one can observe directly. The **CIE color matching experiment** is the practical procedure used to *measure* that space using only what an observer can report: whether two lights look the same.

**Setup.** Pick a small fixed set of reference lights, the **primaries** (in the classic experiment, three fixed, nameable lights). Also pick a **test light** — the color to be matched. An observer views a split field: primaries mixed together on one side, the test light on the other. The experimenter adjusts the *strengths* (intensities) of the primaries — how much of each is mixed in — until the combined primary mixture looks visually identical to the test light. "Looks identical" here means exactly what §2 built: the primary mixture and the test light produce the same (S, M, L) triplet, i.e. they are metamers of each other, even though the primary mixture's own spectrum is (in general) nothing like the test light's spectrum. This identity is written with an equality symbol meaning "has the same retinal color as" / "is metameric to," not "is the same physical spectrum as."

**Why some matches need negative coefficients.** For many test colors, no non-negative combination of the three primaries' strengths can reproduce the test color — the observer simply cannot make the primary side look right no matter how they adjust the knobs, because the required primary mixture would need to be *more saturated* than any achievable combination of those three specific primaries allows. The experimental fix: instead of trying to subtract light from the primary mixture (physically impossible — a light source can only add photons, never remove them), the experimenter adds some amount of one primary **to the test side instead**. Adding light to the test side and matching what remains is mathematically equivalent to subtracting that same amount from the primary side — so the coefficient recorded for that primary in the final result is written as **negative**, even though what physically happened was addition, just on the other side of the equation. Repeating this matching experiment for pure test beams across the visible spectrum, and recording each primary's required coefficient (positive when added normally to the primary side, negative when it had to be added to the test side instead) at every wavelength, produces the **color matching functions** for that choice of primaries.

**Linear-algebra view: a match solves for coordinates in a basis.**
- Let **p**₁, **p**₂, **p**₃ ∈ ℝ³ be the (S, M, L) responses of the three primaries at unit strength (each primary's spectrum pushed through §2's matrix **A**). They are linearly independent, so they form a **basis** of the 3D color space.
- A match is the equation c₁**p**₁ + c₂**p**₂ + c₃**p**₃ = **t**, where **t** is the test light's response. With the primaries as the columns of a 3×3 matrix **P**, that is **P c** = **t**, so **c** = **P**⁻¹**t**: the test color's **coordinates** in the primary basis. Turning the knobs is physically solving this 3×3 linear system.
- **A negative coefficient** means **t** lies outside the cone spanned non-negatively by **p**₁, **p**₂, **p**₃ (their conic hull, §2). That three-edged cone sits strictly inside §2's rounded cone, so some real colors fall outside it.
- The color matching functions are **P**⁻¹**A**: every wavelength's lasso vector (column of **A**) re-expressed in primary coordinates.

**Whose eyes? The standard observer.** Different people's cones differ slightly, so matches made by one person don't exactly fit another. The 1931 CIE data were therefore pooled from a small panel of observers (the lecture slide says 12 people, but the standard references describe two independent matching experiments, one with 10 observers and one with 7, so 17 people in total, whose averaged results were combined) and averaged into one idealized, "typical" viewer: the **standard observer**. Think of it like a clothing size chart built from measuring a group of people: nobody is exactly "size M," but everyone can agree on what M means. Formally, the standard observer *is* its three color matching functions — every CIE number in §4–§5 means "what this averaged viewer would report," not what any single person sees.

---

## 4. Two Equivalent Views, and the CIE RGB → XYZ Trade-off

**Two views of the same retinal color.** The lecture states these as formally equivalent:
- **Analytic view** (§1's machinery): retinal color is produced by *analyzing* a spectral power distribution — taking the dot product (§1's integral) of Φ(λ) against a set of sensitivity functions.
- **Synthetic view** (§3's machinery): retinal color is produced by *synthesizing* a matching mixture of physical color primaries, recording the weights (color matching functions) needed.

These are the same underlying fact seen from two directions: a set of color matching functions (§3) *is* a set of color sensitivity functions (§1) — for any chosen set of primaries, there exists a corresponding set of matching functions that plays the exact same mathematical role as an SSF. Analyzing a spectrum with those matching functions gives the identical coefficients that synthesizing with the corresponding primaries would require.

**CIE RGB.** Running the §3 experiment with a specific, standardized set of three physical primaries (fixed reference lights, standardized by the International Commission on Illumination based on pooled color-matching data from a panel of human observers) gives the **CIE RGB color space** — three color matching functions, one per primary. As §3 already showed, some test wavelengths require a negative coefficient in this basis: **CIE RGB's primaries are physical (realizable, non-negative light), but its coordinates are not guaranteed non-negative for every real color.**

**CIE XYZ.** The CIE also defines a second, purely mathematical set of three "primaries" — not any real, physically producible lights, but linear combinations of the CIE RGB primaries chosen specifically so that **every** real color's coordinates in this new basis come out non-negative. This is **CIE XYZ**. The price: XYZ's own "primaries" are not physically realizable light sources — they are mathematical constructs (in effect requiring negative light to actually produce), useful only as a coordinate system, never as an actual set of projector bulbs.

**Linear-algebra view: CIE RGB → XYZ is a change of basis.**
- CIE RGB and CIE XYZ are two coordinate systems (two bases) for the same 3D color space. Switching between them is a **change of basis**: multiply by one fixed 3×3 matrix, v_XYZ = M_CIERGB→XYZ · v_CIERGB. The standard's matrix is
  ```
  M_CIERGB→XYZ = (1/0.17697) · [0.49000  0.31000  0.20000]   = [2.7688  1.7517  1.1301]
                               [0.17697  0.81240  0.01063]     [1.0000  4.5906  0.0601]
                               [0.00000  0.01000  0.99000]     [0.0000  0.0565  5.5942]
  ```
- Its determinant is 61.36, not 0, so it is **invertible**: the conversion can be undone exactly, and no color information is lost either way.
- The same matrix converts the matching functions: (x̄, ȳ, z̄) = M_CIERGB→XYZ · (r̄, ḡ, b̄), wavelength by wavelength. Its middle row says Y = 1.0000·R + 4.5906·G + 0.0601·B: luminance as a fixed linear functional of CIE RGB.
- "Analytic = synthetic" is this algebra too. §3's matching functions **P**⁻¹**A** have rows that are fixed linear combinations of the cone-SSF rows of **A**, so they act as sensitivity functions themselves.

**Why Y is special: the direct link to human brightness.** The XYZ basis wasn't picked arbitrarily. Its middle coordinate, Y, was chosen so that Y's matching function equals the eye's **luminous efficiency function V(λ)**. Analogy first: V(λ) is like a "brightness exchange rate" per wavelength — how many units of perceived brightness one watt of light at that wavelength buys you. Formally, V(λ) is the standard observer's relative brightness sensitivity at each wavelength λ (dimensionless, normalized so its peak, in the green, equals 1, and falling toward zero at the violet and deep-red ends of the visible range). Because Y's matching function *is* V(λ), plugging a spectrum into §1's formula with *f*(λ) = V(λ) gives Y directly: **Y is luminance**, the perceived brightness of the light. This is the concrete bridge between CIE's abstract coordinates and human vision, and it is why §5 can say Y "carries brightness."

**The fundamental problem, stated explicitly.** You can choose a basis with physically realizable (non-negative) primaries, or you can choose a basis where every real color gets non-negative coordinates — **but not both at once.** CIE RGB picks the first (real primaries, some negative coordinates); CIE XYZ picks the second (non-negative coordinates, imaginary primaries). This is not a limitation of either particular choice — it is a geometric fact about the shape of the achievable-color cone from §2: no flat, three-sided (triangular) coordinate frame can simultaneously contain that whole rounded, horseshoe-cross-sectioned cone within its non-negative octant *and* have its three corner "primary" directions sit on the cone's own physically-achievable boundary.

**Linear-algebra view of the fundamental problem.** Real primaries are real light, so their vectors lie inside §2's achievable cone, and so does their conic hull (all non-negative combinations). For every real color to get non-negative coordinates, that three-edged hull would have to contain the *whole* achievable cone. A cone with three edges has a triangular cross-section, while the achievable cone's cross-section is the curved horseshoe, so a three-edged cone inside it always misses part of it. No basis of three vectors inside the achievable cone has a non-negative span containing the whole cone. XYZ escapes by putting its three basis vectors *outside* the achievable cone, which is exactly why its primaries are imaginary.

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

**Linear-algebra view: projective, not linear.** The map v ↦ v / (X+Y+Z) normalizes every vector onto the plane X+Y+Z = 1, so every vector on the same ray lands on one point. Example: sRGB's red primary and three times it both give xy = (0.6400, 0.3300). The map is **not linear**, because it doesn't preserve sums:
- Full-strength sRGB red plus full-strength sRGB green gives xy = (0.4193, 0.5053).
- That is *not* the midpoint of their chromaticities, (0.4700, 0.4650).

It is **projective**: straight lines map to straight lines, so the sum still lands on the segment joining the two chromaticity points. Its position along that segment is weighted by each color's X+Y+Z, not by ½. Red's X+Y+Z is 0.6444 and green's is 1.1919, so red's share is 0.6444 / (0.6444 + 1.1919) = 0.3509. That preserved straightness is why §6's triangles work.

*(This is genuinely a geometric construction — a diagram showing the 3D cone from §2 being collapsed onto the X+Y+Z=1 plane by rays from the origin would make the projection immediately intuitive. That diagram belongs in the artifact, not here.)*

---

## 6. Color Gamuts

A device's **gamut** is the set of colors it can actually produce (a display) or actually capture as physically distinct (a sensor), expressed as a region of the chromaticity diagram (§5).

**Why three real primaries always give a triangle.** Any real display or printer builds every color it shows as a non-negative-weighted combination of a small, fixed set of primaries — usually three (red, green, blue phosphors/LEDs/inks). In chromaticity coordinates, each primary is a single fixed point. A non-negative combination of three fixed points, normalized to sum to one (exactly what a convex combination is), sweeps out precisely the **triangle** whose corners are those three points — nothing outside that triangle is reachable by any non-negative mixture, and everything inside is. This is the same convex-combination logic §2 used for mixed beams, just carried through the chromaticity projection.

**Linear-algebra view: a gamut triangle is a convex hull.** The **convex hull** of the three primary chromaticity points **q**_R, **q**_G, **q**_B is every point w_R**q**_R + w_G**q**_G + w_B**q**_B with all w ≥ 0 and w_R + w_G + w_B = 1. The weights are the point's **barycentric coordinates**, found by solving a 3×3 linear system (the two xy equations plus the sum-to-1 equation):
- **D65 white** in the sRGB triangle: w = (0.2120, 0.3922, 0.3959). All positive, so it is inside.
- These are not RGB = (1, 1, 1). They equal each primary's X+Y+Z (0.6444, 1.1919, 1.2032) divided by their total: §5's projective weighting again.
- **Display P3's green** (0.265, 0.690): w = (−0.1446, 1.2390, −0.0944). Negative weights mean it is outside the hull, i.e. out of sRGB's gamut (§13's worked example).

**sRGB gamut.** **sRGB** is the standard RGB color space most consumer displays, cameras, and image files (including JPEG) target. Its gamut is exactly such a triangle: the three corners are its three standard primaries' chromaticity coordinates, the interior is every color reproducible as some non-negative mix of those three primaries, and — critically — the exterior is every color that would require a **negative** coordinate to express in that primary basis. "Outside the triangle" is not a vague notion of "very saturated" — it is the precise, geometric restatement of §4's fundamental problem: a color outside the gamut triangle is one that cannot be built from these three specific real primaries without an impossible negative contribution from at least one of them.

**Other RGB spaces.** Different devices and standards (camera-native RGB spaces, wider-gamut display standards, etc.) use different sets of primaries, and therefore trace out *different* triangles in the same chromaticity diagram — some larger than sRGB's, some smaller, some overlapping only partially. Comparing gamuts this way — as triangles inscribed in the same 2D chromaticity diagram — is exactly how the lecture's "gamuts of various common industrial RGB spaces" comparison works: each space's reachable-color triangle sits differently inside the full horseshoe-shaped boundary of all humanly visible chromaticities (that horseshoe boundary being, precisely, the 2D projection of §2's lasso curve).

---

## 7. Take-Home Synthesis

Putting §4's fundamental problem and §6's gamut-triangle geometry together: **no RGB space can simultaneously have physically realizable (non-negative) primaries and guarantee non-negative coordinates for every real color.** Any triangle built from three real, physical primary points is strictly smaller than the full horseshoe of achievable chromaticities (§2, §5) — some real colors always fall outside it. The only way to *cover* every real color with non-negative coordinates (as CIE XYZ does) is to give up on the primaries themselves being physically producible light.

This is precisely why **consumer devices disagree on color without calibration**: different cameras, displays, and printers use different physical primaries, hence different gamut triangles, hence different mappings from "RGB numbers" to actual chromaticity. A raw RGB triplet carries no meaning at all unless you also know *which* device's primaries it's expressed relative to — the same three numbers mean a different actual color on two different uncalibrated screens. Standards like sRGB exist to fix one agreed-upon triangle that everyone is supposed to target, but a consumer display that isn't calibrated to actually hit sRGB's specific primaries will still render the same RGB numbers as a visibly different color than a calibrated one.

> **Worked example: the same RGB numbers on two different standards (slide 49: "RGB values have no meaning if the primaries between devices are not the same").** Compare two real standards that share the same white point (D65, a standardized daylight white) but use different primaries:
> - **sRGB** (standard IEC 61966-2-1): red primary at xy = (0.640, 0.330), green (0.300, 0.600), blue (0.150, 0.060).
> - **Display P3**, a wider-gamut standard used by many recent phone and laptop screens: red (0.680, 0.320), green (0.265, 0.690), blue (0.150, 0.060). These are the same primaries as the cinema standard DCI-P3, paired with a D65 white instead of DCI-P3's own white.
>
> Each standard's RGB → XYZ matrix is built from those four chromaticities (three primaries plus white): each primary's column is scaled so that RGB = (1, 1, 1) lands exactly on the white point. Then:
>
> | Linear RGB triplet | Read as sRGB → xy | Read as Display P3 → xy |
> |---|---|---|
> | (1, 0, 0) | (0.6400, 0.3300) | (0.6800, 0.3200) |
> | (0.2, 0.8, 0.3) | (0.2928, 0.4409) | (0.2753, 0.4644) |
>
> The first row is the obvious case: "full red, nothing else" simply *is* each standard's red primary, and the two reds are different points on the chromaticity diagram. P3's red is deeper, further out toward the horseshoe edge. The second row shows it isn't only the corners: an ordinary mixed color also lands somewhere different. Same three numbers, two different physical colors. The numbers only mean something once you say which primaries they refer to.

**Linear-algebra view: sRGB and Display P3 are two bases for the same space.**
- An RGB triplet is a **coordinate vector**, and coordinates mean nothing without a basis: the pair (1, 0) points to different arrows in different bases. Each standard's RGB → XYZ matrix is its change-of-basis matrix, whose columns are its primaries' XYZ vectors (§13 shows sRGB's).
- Converting P3 coordinates to sRGB coordinates composes two changes of basis, P3 → XYZ and then XYZ → sRGB:
  ```
  M_P3→sRGB = M_XYZ→sRGB · M_P3→XYZ = [ 1.2249  −0.2249   0.0000]
                                      [−0.0421   1.0421   0.0000]
                                      [−0.0196  −0.0786   1.0983]
  ```
- Its middle column is P3 green in sRGB coordinates, (−0.2249, 1.0421, −0.0786): §13's out-of-gamut example, exactly the value in §13's worked example.
- The two zeros in the last column appear because both standards use the same blue chromaticity. P3's blue is just sRGB's blue scaled by 1.0983.
- The inverse, M_sRGB→P3, has only non-negative entries: rows (0.8225, 0.1775, 0), (0.0332, 0.9668, 0), (0.0171, 0.0724, 0.9105). Every sRGB primary is a non-negative mix of P3 primaries, so sRGB's whole gamut sits inside P3's.

**Caveat (slide 50): the 2D diagram can mislead.** The xy diagram divides out overall brightness (§5), so a gamut drawn as a flat triangle hides how bright each chromaticity can get. Two gamuts whose triangles look one way in xy can compare quite differently once the missing brightness dimension is restored, i.e. as 3D volumes in the full tristimulus space of §2. Treat triangle comparisons as a first look, not the whole story.

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

**Also part of a real pipeline** (mentioned by the lecture, not deep-dived here since HW2 doesn't exercise them): dead-pixel removal (patching over known-defective sensor sites), dark-frame subtraction (subtracting a no-light reference exposure to cancel fixed-pattern/thermal noise — Week 2 §16.1), lens-blur/vignetting/distortion correction (compensating for the aberrations of Week 2 §6), and sharpening/edge enhancement (boosting high image-frequency detail; see §11.8 for how it works). The lecture's slides also separately list **digital autoexposure** and **white balancing** as pipeline stages sitting alongside demosaicking and gamma correction; both are mentioned here for completeness but, like the "also" list above, aren't built up further since HW2's own tasks are demosaicking, denoising, and gamma correction specifically.

Each subsequent section below (§10–§14) covers one pipeline stage in the depth HW2 or the lecture actually demands.

**Exif metadata.** Alongside the pixel data itself, a finished image file typically stores **Exif** ("exchangeable image file format") metadata — capture settings and context (exposure time, aperture, ISO, timestamp, lens model, and similar) embedded directly in the file next to the pixel data.

### 9.1 Opening a real camera RAW file (HW2 bonus)

HW2's provided images are already-extracted mosaics. A RAW file straight off a real camera needs a few extra steps before the pipeline above can run on it, and it helps to know what they are before comparing your own pipeline's output with a reference decoder.

**What a RAW file is.** A camera's RAW file (`.CR2`/`.CR3` for Canon, `.NEF` for Nikon, `.ARW` for Sony, or the open `.DNG` format) is a container holding:
- the sensor's mosaic values, essentially unprocessed: one number per pixel, usually 12–14 bits (Week 2 §14);
- the metadata needed to interpret them: Exif (above), the color filter layout, black and white levels, the white-balance gains the camera chose, and a color matrix.

The formats differ between manufacturers, so you need a decoder to get at the numbers.

**`dcraw`** is the classic free command-line decoder that HW2 points to. It can either dump the raw mosaic as-is or run its own complete pipeline. **`rawpy`** is a Python wrapper around LibRaw (a library built on dcraw's code) that exposes the same data as NumPy arrays, e.g. `raw_image_visible` (the mosaic), `raw_pattern` (which filter color sits at each position of the repeating tile), `black_level_per_channel`, `white_level`, and `camera_whitebalance`.

**The steps between a RAW file and the §9 pipeline**, in order:

1. **Check the mosaic layout.** Not every camera is RGGB. BGGR, GRBG and GBRG are the same 2×2 tile starting at a different corner. Read it from the metadata (`dcraw -i -v`, or `rawpy`'s `raw_pattern`) rather than assuming, or every demosaicking formula in §10 will put colors in the wrong places.
2. **Subtract the black level.** A pixel that received no light doesn't read 0: the electronics add a fixed offset (a "pedestal") so noise below it isn't clipped off. Subtract that **black level** from every pixel first. This is the same idea as the dark frame above, using a per-camera constant instead of a measured frame.
3. **Normalize by the white level.** Divide by (white level − black level), so a saturated pixel (full-well capacity, Week 2 §13.4) maps to 1 and the image is on a [0, 1] linear scale.
4. **White balance.** Multiply each color channel by its own gain so that an object that's neutral gray in the scene comes out with R = G = B. Without it, images take on the color cast of the light source (orange under indoor bulbs, blue in shade). The camera's "as shot" gains are stored in the file.
   - *Linear-algebra view:* white balance is multiplication by a **diagonal matrix** diag(*g_R*, *g_G*, *g_B*). Each color basis vector is scaled by its own gain; no channel is mixed into another.
5. **Demosaic** (§10), and optionally **denoise** (§11). These are the steps HW2 asks you to implement.
6. **Convert camera RGB to a standard color space.** The sensor's own R, G, B filters don't match sRGB's primaries (§6). A 3×3 matrix stored in or derived from the file's metadata converts them.
   - *Linear-algebra view:* a **change of basis** from the camera's color basis to sRGB's, exactly like §4's RGB → XYZ conversions.
7. **Gamma-encode** (§12) and quantize to 8 bits for display.

**Useful `dcraw` options** for building a fair comparison:

| Option | What it does |
|---|---|
| `-i -v` | Print the file's metadata (camera, filter pattern, white-balance multipliers) without decoding |
| `-D` | Output the mosaic with no black subtraction, scaling, demosaicking or color conversion. The gamma curve and automatic brightening applied when the file is written still happen unless `-4` is added |
| `-d` | Like `-D`, but with black-level subtraction and scaling (including the white-balance multipliers) applied ("document mode") |
| `-4` | Output linear 16-bit data (no gamma curve, no automatic brightening) |
| `-T` | Write a TIFF instead of dcraw's default PPM/PGM image |
| `-w` | Use the camera's own ("as shot") white balance |
| `-o 0` | Leave colors in the camera's raw color space (skip step 6) |
| `-q 0`…`-q 3` | Demosaicking quality, from bilinear interpolation (0) to AHD (3), an adaptive edge-aware method |

**Comparing like with like.** dcraw's default output also brightens the image and applies its own gamma curve, color matrix and demosaicking method. If you compare it against a pipeline that skips any of those steps, most of the difference you see will come from the skipped step rather than the demosaicking or denoising you implemented. Either switch the matching dcraw steps off (e.g. `-4 -o 0`), or implement them in yours, before judging the result.

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

**Library warning: `interp2d` no longer exists.** `scipy.interpolate.interp2d`, which both PS2 and HW2 suggest, was removed in SciPy 1.14.0. Calling it on any current SciPy raises `NotImplementedError`. The replacements depend on how the known samples are laid out:
- **Red and blue:** their known samples sit on a regular sub-grid (e.g. every other row *and* every other column). A regular-grid interpolator fits this directly: `scipy.interpolate.RegularGridInterpolator` with `method="linear"`, or `RectBivariateSpline` with `kx=1, ky=1` (degree-1 splines, i.e. plain linear interpolation along each axis), which SciPy's own error message names as the closest drop-in replacement.
- **Green:** its known samples form a checkerboard, which is *not* a rectangular grid. Use a scattered-data interpolator (`scipy.interpolate.griddata` with `method="linear"`), or the `np.roll` four-neighbor average above, which is simpler and exactly equivalent at interior pixels.
- **Edges:** a sub-grid's samples don't reach every border pixel, so whichever routine you use needs a stated rule there. For example, `RegularGridInterpolator(..., bounds_error=False, fill_value=None)` extrapolates linearly instead of raising an error.

Naive interpolation like this tends to introduce visible color fringing/artifacts near edges — each channel is interpolated *independently*, ignoring the fact that a real edge should show up consistently across all three channels at once. §10.3–§10.5 address this in increasingly sophisticated ways.

**Linear-algebra view: mosaicking is a selection matrix; naive demosaicking is a fixed matrix.**
- Stack the true full-color image into one long vector **x** (every pixel's R, G, B). For a tiny 4×4 image that is 48 numbers, but the sensor records only 16.
- The RAW image is **y** = **P**_Bayer **x**, where **P**_Bayer is a 16×48 **selection matrix**. Each row holds a single 1, picking out the one channel that pixel's color filter passes, and zeros everywhere else.
- **P**_Bayer has rank 16, so by rank–nullity (§2) its null space has dimension 48 − 16 = 32. There are 32 independent ways to change the true image that the sensor cannot see at all.
- So demosaicking is an **underdetermined inverse problem**: infinitely many images **x** give the same **y**. Every method in §10 picks one by assuming something about what images look like (a **prior**): smooth channels (§10.1), smooth chroma (§10.3), edges shared across channels (§10.4–§10.5). Week 6 makes priors explicit, as regularized inverse problems.
- Naive interpolation is itself **linear**: **x̂** = **E y** for a fixed 48×16 matrix **E**. For example, the green row for a non-green pixel has four entries of 1/4 on its neighbors. The same weights repeat at every pixel with the same Bayer position, so multiplying by **E** is implemented as convolution (the `np.roll` trick above), never by building the matrix.
- The script's check on the green part: **E**(2**a** + 3**b**) equals 2**E a** + 3**E b** to within 4.4 × 10⁻¹⁶ (floating-point round-off) for random RAW vectors **a**, **b**.

### 10.2 Aside: The Optical Low-Pass Filter (OLPF)

Because the Bayer mosaic samples each color channel at less than the sensor's full pixel resolution (green at half density, red and blue at a quarter each), fine scene detail near or beyond what that reduced sampling density can represent risks **aliasing** — showing up, after demosaicking, as false color patterns (moiré) that were never in the original scene. (Aliasing itself is formalized properly with the sampling theorem in Week 5; the intuition needed here is just that under-sampling fine periodic detail can fold it into spurious low-frequency artifacts.) Throughout this subsection, "frequency" means **image frequency** in the sense of Week 1 §12.2.1: how many light-dark cycles of a pattern fit per pixel of the sensor grid, in cycles per pixel. It has nothing to do with the frequency (wavelength) of the light itself, which is what "red" or "blue" refers to.

**Analogy.** Picture a spinning wagon wheel filmed by a camera that takes too few frames per second: the spokes can appear to crawl slowly, or even backwards. The camera isn't lying about any single frame; it just doesn't look often enough to tell a fast rotation from a slow one. A Bayer channel that samples a fine stripe pattern too sparsely is fooled the same way, except across space instead of time.

> **Worked example: why red aliases where green doesn't.** Take vertical stripes whose brightness varies left-to-right at **0.4 cycles/pixel** (one full light-dark cycle every 2.5 px).
> - **Red** in an RGGB mosaic sits in every 2nd column. One sample per 2 px is a sampling rate of 0.5 samples/px, and a sampled signal can only represent patterns up to half its sampling rate, so red's limit is **0.25 cycles/pixel** (one cycle per 4 px). 0.4 is above that limit.
> - **Green** occupies every column once its two rows per 2×2 tile are combined (they are offset by one column), so its limit for this pattern is 0.5 cycles/pixel. 0.4 is below it, so green records the stripes correctly.
>
> A frequency above the limit "folds back": it becomes indistinguishable from its distance to the nearest multiple of the sampling rate. For red that is |0.4 − 0.5| = **0.1 cycles/pixel**, a period of **10 px** instead of the true 2.5 px. The script's samples show why red can't tell them apart:
>
> | Column | True stripe cos(2π·0.4·col) | Red sample here? | Impostor cos(2π·0.1·col) |
> |---|---|---|---|
> | 0 | +1.000 | yes | +1.000 |
> | 1 | −0.809 | – | +0.809 |
> | 2 | +0.309 | yes | +0.309 |
> | 3 | +0.309 | – | −0.309 |
> | 4 | −0.809 | yes | −0.809 |
> | 5 | +1.000 | – | −1.000 |
> | 6 | −0.809 | yes | −0.809 |
> | 8 | +0.309 | yes | +0.309 |
> | 10 | +1.000 | yes | +1.000 |
>
> At every column where red is actually measured, the two patterns agree exactly; they only disagree at columns red never sees. So after demosaicking, green reports fine 2.5 px stripes while red (and, by the same argument, blue) reports coarse 10 px bands. The channels disagree about the pattern, and that disagreement shows up as colored bands that were never in the scene: **false color, or moiré**.

Many sensors sit behind an **optical low-pass filter (OLPF)**, also called an optical anti-aliasing filter. ("Low-pass" here refers to spatial frequency — fine stripes and texture across the image — not to the frequency of light; despite being "optical," it doesn't filter colors. The infrared-blocking layer mentioned below is the part that acts on light's wavelength.) It is a glass sheet placed directly in front of the sensor that slightly pre-blurs the incoming light *before* it ever reaches the pixel grid, specifically to attenuate detail fine enough to alias, before sampling ever happens. It's commonly built from two **birefringent** layers (a birefringent material splits a single incoming ray into two, based on the light's polarization), combined with an infrared-blocking filter; stacking two such splitting layers turns one incoming ray into four, which together act as a small 4-tap discrete convolution (blurring) kernel applied optically, before the sensor ever sees the light.

**The trade-off.** An OLPF removes the risk of aliasing, but it does so by removing genuine fine detail along with it — a straightforward resolution-vs-aliasing trade, the same tension Week 2 §2 already encountered between geometric blur and diffraction for pinhole size, now appearing as a deliberate design choice rather than an unavoidable physical limit. Because it's a *choice*, some photographers physically remove the OLPF from their camera ("hot-rodding") to trade back some aliasing risk for maximum resolution, and manufacturers sometimes sell otherwise-identical camera models with and without the OLPF installed, aimed at photographers who have made that trade-off deliberately.

### 10.3 Chrominance Low-Pass Demosaicking

Naive per-channel interpolation (§10.1) still leaves color-fringing artifacts, especially near edges, because red, green, and blue are each interpolated independently with no shared structure. The lecture (slide 71) names the root cause as a **sampling problem that persists despite the OLPF**: red and blue are the sparsest channels (one sample per 2×2 tile), so any fine detail they receive is "(too) high-frequency" for their sampling — high *image* frequency, in cycles per pixel, exactly as in §10.2's worked example. Their interpolation errors therefore come out as fine, pixel-scale color speckle and colored fringes along edges.

A cheap fix exploits an asymmetry in human perception: **people are far more sensitive to sharpness in luminance than in chrominance** ("sharpness" meaning fine, high-spatial-frequency detail; built up properly in §10.3.1). This is a direct extension of Week 1 §12's contrast-sensitivity material — the entire Contrast Sensitivity Function built up there describes sensitivity to *brightness* contrast; the visual system's ability to resolve fine spatial detail in pure color-without-brightness-change is considerably coarser. So blurring the *color* information slightly, while leaving *brightness* detail untouched, should be far less perceptible than blurring both together — exactly what naive per-channel interpolation risks doing when it lets color artifacts appear at full resolution.

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

**Linear-algebra view: an affine map, with three linear functionals as rows.**
- With **v** = (R, G, B), **u** = (Y′, Cb, Cr) and offset **o** = (16, 128, 128), the conversion is **u** = M**v** + **o**. A linear map plus a constant shift is an **affine** map, not a linear one: black, **v** = (0, 0, 0), goes to (16, 128, 128), not to zero.
- To undo it, remove the shift first, then undo the matrix: **v** = M⁻¹(**u** − **o**). This works because det M = 2.596 × 10⁶ ≠ 0, so M is invertible. Round trip for the red pixel below: (81.481, 90.203, 240.000) → (1, 0, 0).
- Each row of M is a **linear functional**: a fixed vector you take the dot product with, just like §1's SSF. Row 1 reads off luma; rows 2 and 3 read off the two color differences.
- Rows 2 and 3 each sum to 0, so any gray (R = G = B) gets 0 from them, which leaves Cb = Cr = 128.
- The first column of M⁻¹ is (0.004566, 0.004566, 0.004566), i.e. 1/219 in every channel. Changing Y′ alone therefore moves R, G and B by equal amounts, straight along the gray axis. Conversely, Y′ is its own coordinate, so changing Cb or Cr leaves it untouched. That is why smoothing only Cb and Cr can't disturb luma detail.

**Library note: skimage's `rgb2ycbcr` uses this same 8-bit-style scale.** HW2 suggests `skimage.color.rgb2ycbcr`, which applies exactly the formula above. So even when you pass R, G, B as floats in [0, 1], the output is *not* in [0, 1]:
- Y′ runs from **16** (black) to **235** (white).
- Cb and Cr run from **16** to **240**, with **128** meaning "no color."

(Checked on scikit-image 0.26: pure black → Y′ = 16, pure white → Y′ = 235, and `ycbcr2rgb` returns the original [0, 1] values to within floating-point round-off.) Practical consequences:
- Always convert back with `skimage.color.ycbcr2rgb`, not by dividing by 255 yourself. The offsets (16, 128, 128) must be subtracted *before* the matrix is undone, exactly as in the inverse formula above.
- A median filter or linear low-pass filter on Cb/Cr works the same at any scale: rescaling values doesn't change which neighbor is the median, and a normalized linear filter commutes with rescaling. But any parameter you set in *intensity units* (a threshold, or an intensity σ like the bilateral filter's σ_i, §11.4) has to be chosen for the 16–240 scale, not for [0, 1].
- HW2 applies this conversion to the *linear* demosaicked image, before gamma correction (§12). Strictly, the primed "Y′" means luma from gamma-encoded values, so here it's a luminance-like channel of linear light instead. That doesn't affect the purpose: the matrix still separates a brightness channel from two color-difference channels, which is all chroma filtering needs.

*(Fact-audit note: the lecture's own slide (p. 73) gives this matrix as Y′ = 65.48R + 128.55G + 24.97B, Cb = −37.80R − 74.20G + 112.00B, Cr = 112.00R − 93.79G − 18.21B, applied to R,G,B on a 0–255 scale and then multiplied by 257/65535 — which equals exactly 1/255 since 255×257 = 65535. That is algebraically the same standard BT.601 matrix given above for R,G,B scaled to [0,1], just re-expressed for 8-bit inputs; a prior draft of this note flagged the slide's coefficients as unreadable, but a fact-checking pass against the rendered slide image confirms the match, including the internal check that the Y′ row's three coefficients sum to 219.00 as BT.601 requires.)*

**What Cb and Cr actually measure.** Analogy first: describe a pixel the way a painter mixes paint. Start with how light or dark it is (Y′), then say "a bit more blue than a neutral gray of that lightness would have" and "a bit less red." Cb and Cr are exactly those two "compared to gray" statements:
- **Cb** is a scaled **blue-difference**, B′ − Y′: how much bluer (positive) or less blue (negative) the pixel is than a gray of the same luma.
- **Cr** is a scaled **red-difference**, R′ − Y′: the same comparison for red.

(The primes mark gamma-encoded values, §12.) With the BT.601 luma weights Y = 0.299·R′ + 0.587·G′ + 0.114·B′ (on a [0,1] scale), the difference B′ − Y can swing at most ±(1 − 0.114), so it is scaled by 112/(1 − 0.114) = 126.41 to fill Cb's ±112 range around 128. Likewise R′ − Y is scaled by 112/(1 − 0.299) = 159.77. Multiplying these out reproduces the Cb and Cr rows of the matrix above exactly (e.g. −0.299 × 126.41 = −37.797). A perfectly neutral pixel has B′ = Y and R′ = Y, so both differences are zero and both channels sit at the 128 "no color" midpoint.

> **Worked example: two pixels through the BT.601 matrix** (R′, G′, B′ on a [0,1] scale).
>
> | Pixel | R′G′B′ | Y (0–1) | B′ − Y | R′ − Y | Y′ | Cb | Cr |
> |---|---|---|---|---|---|---|---|
> | Mid gray | (0.5, 0.5, 0.5) | 0.500 | 0.000 | 0.000 | 125.500 | 128.000 | 128.000 |
> | Saturated red | (1, 0, 0) | 0.299 | −0.299 | +0.701 | 81.481 | 90.203 | 240.000 |
>
> Gray: both color differences vanish, so Cb = Cr = 128, and all its information lives in Y′. Red: Cr hits its maximum, 240 = 128 + 112, because red is as far above its own luma as the format allows. Cb drops below 128 because red has less blue than a gray of equal luma would. Y′ is fairly low (81.5, where the full 16–235 luma range is available) because red contributes only 0.299 of luma.

**Why chroma is where demosaicking errors live.** The fringes and speckle of naive interpolation are mostly disagreements *between* channels (red says one thing, green another), not errors in overall brightness. A disagreement between channels is, by definition, a color difference, so it lands mostly in Cb and Cr. Smoothing just those two channels attacks the artifacts where they are concentrated.

**Why a median filter counts as a low-pass filter here.** A low-pass filter (Week 1 §13.1) keeps slow, broad variation across the image (low image frequency) and removes rapid, pixel-to-pixel variation (high image frequency). A median filter (§11.3) isn't a weighted average, but it behaves the same way on this kind of content. An isolated wrong-colored pixel is an outlier in its window, so the median discards it entirely: a fine-scale spike, i.e. high-frequency content, is removed. A broad region of consistent chroma has the same median as its own value, so it passes through unchanged. Unlike a plain average, the median doesn't smear a speckle into a halo around it, which is why PS2 suggests it.

Filtering only Cb and Cr (e.g. via a median filter, per PS2's own suggestion of a 9×9 median window) smooths over the color artifacts naive interpolation introduced while leaving the fine, perceptually important luminance detail (the high image-frequency content in Y′ that §10.3.1 explains the eye relies on for "sharpness") fully intact.

### 10.3.1 Frequency, edges, and sharpness

§10.2, §10.3, and all of §11 lean on phrases like "high-frequency detail," "low-pass," and "sharpness." This subsection pins down what they mean in this week's context, from first principles.

**Which frequency?** Week 1 §12.0 separated three meanings of "frequency." In this week's image-processing sections, it is always the third:

| Kind | What oscillates | Unit | Role in Week 3 |
|---|---|---|---|
| Light frequency / wavelength | The electromagnetic wave itself | nm (wavelength) | This is what "color" is about: Part 1, cone and filter sensitivities |
| Temporal frequency | A signal over time (flicker) | Hz | Not used in Week 3 |
| **Spatial frequency, as image frequency** | Pixel values across the pixel grid | **cycles per pixel** | Demosaicking aliasing (§10.2), chroma filtering (§10.3), denoising (§11), JPEG (§14) |

So "a red channel's high-frequency content" means *fine spatial detail in the red channel*, not "high-frequency light." Red light is actually the *lowest* light frequency of the three. Keeping those apart is the whole point of this table.

**Analogy.** Think of an image row as a landscape seen on a hike. Gentle rolling hills are low frequency: the height changes slowly over many steps. A cliff, or a field of small rocks, is high frequency: the height changes abruptly from one step to the next.

**Edges and texture are high frequency; shading is low frequency.**
- **Smooth shading** (a gradual sky gradient, a softly lit wall) changes slowly across many pixels, so it is made almost entirely of low-frequency waves.
- **Fine texture** (fabric weave, hair, gravel) alternates within a few pixels, so its content sits at high frequencies.
- **A sharp edge** is a sudden jump. Building a jump out of smooth waves (Week 1 §12.4's "any signal is a sum of waves") needs many of them, including high-frequency ones, to make the transition abrupt.

> **Numeric illustration: a step needs many frequencies.** Over a 16-pixel repeating window, compare a hard step (8 px at 0, 8 px at 1) with a single smooth cosine bump of the same period. Their Fourier magnitudes at each image frequency (cycles/pixel):
>
> | Frequency (cycles/px) | 0 | 0.0625 | 0.125 | 0.1875 | 0.25 | 0.3125 | 0.375 | 0.4375 | 0.5 |
> |---|---|---|---|---|---|---|---|---|---|
> | Hard step | 0.5 | 0.3204 | 0 | 0.1125 | 0 | 0.0752 | 0 | 0.0637 | 0 |
> | Smooth cosine | 0.5 | 0.25 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
>
> The smooth bump uses exactly one wave. The step has energy spread across many frequencies, up to 0.4375 cycles/px. Remove those upper entries and the step's corners round off.

**Why denoising is a dilemma (slide 83: "remove noise but retain high-frequency detail").** Sensor noise (Week 2 §16) is independent from pixel to pixel. Its power spreads evenly across all image frequencies ("white" noise). In a seeded 4096-sample test with noise standard deviation 0.1 (variance 0.01), the average power in the lower half of the frequency band was 0.00970 and in the upper half 0.01021: essentially equal. Natural image content, by contrast, is mostly low frequency (large smooth regions). So at low frequencies the image dominates the noise, while at high frequencies the noise is comparable to or larger than the image. That is where noise is most visible, as grain. A **low-pass filter** therefore removes a lot of noise, but it also removes the high-frequency part of every genuine edge and texture. It can't tell the two apart by frequency alone. This is exactly why §11 moves on from the Gaussian to edge-aware filters.

> **Numeric illustration: a blur widens an edge.** A 1D step edge, 0 0 0 1 1 1, goes from dark to bright in **1** pixel step. Replace each pixel with the average of itself and its two neighbors (a 3-tap average, the simplest low-pass filter) and it becomes 0 0 0.333 0.667 1 1. The transition now takes **3** pixel steps. That widening is what "the edge got blurrier" means numerically.

**Where "sharpness" lives.** Perceived sharpness comes mostly from high frequencies in **luminance** (brightness), not in color. Week 1 §12's Contrast Sensitivity Function was measured with brightness gratings. The visual system's resolution for pure color changes (equal brightness, different hue) is coarser, so it runs out at lower spatial frequencies. Hence the asymmetry used twice in this week:
- Chroma (Cb, Cr) can be low-passed with little visible cost: demosaicking in §10.3, chroma subsampling in JPEG §14.
- Luma (Y′) cannot: low-passing it is exactly the edge-widening shown above, and the image visibly softens.

The same "split an image into low- and high-frequency parts" idea powered Week 1 §13's hybrid images, and it returns in §11.8's sharpening. Week 5 formalizes image frequency, sampling, and aliasing with the discrete Fourier transform.

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

(D_B is defined identically, substituting b for r. D_G is not: the paper computes it over a 9-point region, the green pixel itself, its four diagonal green neighbors, and the green samples two pixels away, with different weights along the row and the column. That is why the two "R at a G pixel" filters are not simple crosses.)

**Term-by-term:** ĝ_lin, r̂_lin are the plain §10.1 naive-average estimates; D_R(x,y) is "the red channel's value right here, minus the average of red's value two pixels away in each direction" — a measure of local curvature in red, computable exactly at this pixel because red *is* the channel actually sampled there (for the first formula's case). α, β, γ are fixed gain constants controlling how strongly that cross-channel curvature correction is trusted.

**The published gain constants**, exactly as given (optimized empirically against the Kodak demosaicking dataset): **α = 1/2** (multiplies the correction for interpolating G), **β = 5/8** (multiplies the correction for interpolating R or B at a G pixel), **γ = 3/4** (multiplies the correction for interpolating R at a B pixel, or B at an R pixel — the diagonal case).

**Why this works.** Naive interpolation (§10.1) only ever uses same-channel neighbors, so it's blind to any information the *other* two channels carry about where edges actually are. By the sharp-edges-appear-in-every-channel assumption above ("sharp edge" meaning an abrupt spatial jump, i.e. high image-frequency content per §10.3.1; "every channel" meaning across R, G, and B, not across light frequencies), the curvature visible in whichever channel is locally measured is a cheap, already-available proxy for the curvature the *missing* channels would show if they'd also been measured — adding a scaled copy of that curvature nudges the naive average toward the true edge-aware value, without abandoning linearity (the whole computation is still just a fixed weighted sum of RAW pixel values, expressible as ordinary linear convolution filters).

**Linear-algebra view.** Malvar–He–Cutler is still **x̂** = **E**_MHC **y** for one fixed matrix, exactly like §10.1's **E**. The correction α·D_R is itself a fixed weighted sum of RAW values, so adding it only changes the matrix's entries. PS2's "4 unique filter shapes" are its 4 distinct row patterns. The problem stays just as underdetermined, since **P**_Bayer's null space hasn't changed. What changes is the prior built into the matrix: "channels share curvature" instead of "each channel is smooth on its own."

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

Nearby pixels get high weight, distant pixels get vanishingly small weight, and *nothing* about the pixels' actual intensity values enters the weight at all — this is exactly the low-pass filtering idea already built in Week 1 §13.1 (blurring by averaging neighbors), here formalized as one specific, spatially-weighted instance of §11.1's general framework. Because the weights don't depend on the noisy image's own values, this is both **linear** (the output is a fixed linear combination of inputs, regardless of what those inputs are) and purely **local** (weight decays with distance alone). (Slide 86 calls it a "Gaussian low-pass filter": low-pass in image frequency, cycles per pixel, per §10.3.1.)

**Linear-algebra view: Gaussian filtering is a fixed matrix.** Stack the image into a vector **i**. The filtered image is G_σ**i**, where G_σ is a square matrix whose row for pixel x holds the normalized weights w(x, x′)/normalizer. In §11.4's 5-pixel example (σ = 1 px), the middle pixel's row is (0.0545, 0.2442, 0.4026, 0.2442, 0.0545). Every row has the same pattern shifted over by one pixel, which makes G_σ a **convolution matrix**: convolving *is* multiplying by it, although code never builds it explicitly. G_σ doesn't depend on **i**, so the filter is linear: G_σ(a**i**₁ + b**i**₂) = aG_σ**i**₁ + bG_σ**i**₂.

**Term-by-term:** *x* and *x′* are pixel positions; |x − x′| is their distance in pixels; **σ** (sigma) is the spatial standard deviation of the Gaussian, in pixels, and is **the knob you control**. The factor 2σ² sets the scale: a neighbor exactly σ pixels away gets weight exp(−1/2) ≈ 0.61 of the center's.

**What σ does.** Analogy: σ is the radius of a "neighborhood vote." Small σ means only immediate neighbors get a say, so noise is averaged over few pixels and only slightly reduced, but edges stay fairly crisp. Large σ means pixels farther away also vote. More noise is averaged away, but more genuine detail is averaged away too. In short, a **larger σ → wider kernel → more smoothing → lower cutoff frequency** (finer detail is removed).

**Why it is a low-pass filter: a Gaussian's Fourier transform is a Gaussian.** Week 1 §12.4.5's convolution theorem says blurring with a kernel multiplies the image's spectrum by the kernel's own Fourier transform (its *frequency response*: how much of each image frequency survives). For a Gaussian kernel of spatial width σ (in pixels), that frequency response is another Gaussian:

```
H(f) = exp( −f² / (2σ_f²) ),   σ_f = 1 / (2πσ)
```

**Intuition.** The response is 1 at f = 0 (the image's average brightness passes untouched, since the weights are normalized to sum to 1) and falls smoothly toward 0 as f grows. There's no hard cutoff, just a gentle roll-off, so it attenuates high frequencies without the ringing a hard cutoff causes. The two widths are inversely related: σ_f = 1/(2πσ). A wide blur in space (big σ) is a narrow pass-band in frequency (small σ_f). This is the "wider kernel, lower cutoff" rule above, now as a formula.

**Term-by-term:** *f* is image frequency in **cycles per pixel** (not light frequency; §10.3.1); H(f) is the dimensionless fraction of a wave at frequency f that survives the blur; σ is the spatial width in pixels, which you choose; σ_f is the resulting frequency-domain width in cycles per pixel, fixed by your choice of σ. The units check: σ in pixels, so 1/(2πσ) is in 1/pixel, i.e. cycles per pixel.

> **Script check (FFT of a sampled, normalized Gaussian).** For each σ, the measured response at f = σ_f should be exp(−1/2) = 0.6065:
>
> | σ (px) | σ_f = 1/(2πσ) (cycles/px) | Measured response at σ_f | Half-amplitude frequency (cycles/px) | Max deviation from formula |
> |---|---|---|---|---|
> | 1 | 0.1592 | 0.6065 | 0.1874 | 7.2 × 10⁻³ |
> | 2 | 0.0796 | 0.6065 | 0.0937 | 2.7 × 10⁻⁹ |
> | 4 | 0.0398 | 0.6065 | 0.0468 | 2.2 × 10⁻¹⁶ |
>
> The "half-amplitude frequency" is where H(f) = 0.5: f = √(ln 2 / (2π²)) / σ. Doubling σ halves every frequency in the table. For σ = 1 px the formula is slightly off (0.007), because a Gaussian only one pixel wide is too narrow to be sampled cleanly. For wider kernels it matches to numerical precision. These σ values are illustrations of the relationship, not choices for HW2.

### 11.3 Median Filtering

An almost-equally simple alternative, but **nonlinear**: rather than computing any weighted average, replace each pixel with the **median** value found within a small window centered on it —

```
i_denoised(x) = median( W(i_noisy, x) )
```

where *W(i_noisy, x)* denotes the small window of the noisy image centered at *x*. Because the median is not a linear operation (it can't be written as any fixed weighted sum of the window's pixel values), this doesn't fit neatly into §11.1's weighted-average form as written, but it shares the same "local" spirit: only nearby pixels are consulted, and the point of taking a median rather than a mean is that it's far less sensitive to a small number of extreme outlier pixels (e.g. salt-and-pepper-style noise) than an average would be.

### 11.4 Bilateral Filtering (Tomasi & Manduchi, 1998)

**The problem with plain Gaussian smoothing.** A Gaussian filter (§11.2) averages every pixel with its spatial neighbors regardless of how different their values are — which is exactly the problem, illustrated with a step edge plus noise: convolving a noisy step function with a Gaussian kernel blurs the sharp transition (the abrupt jump, i.e. high image-frequency content per §10.3.1; "sharp" in this section always means that) into a smooth ramp, because the kernel doesn't know or care that pixels on opposite sides of the edge belong to genuinely different regions; it blurs straight across the edge along with smoothing out the noise on each side.

**The fix: also weight by intensity similarity.** The **bilateral filter** multiplies §11.2's spatial Gaussian by a *second*, independent Gaussian term based on how different two pixels' actual intensity values are:

```
w(x, x') = exp( −|x − x'|² / (2σ²) ) · exp( −|i_noisy(x') − i_noisy(x)|² / (2σ_i²) )
```

**Why a product of two Gaussians is the natural way to combine these.** The filter is meant to answer "are these two pixels both *close in space* **and** *close in intensity*?" — two independent conditions that both need to hold for a strong weight. Multiplying two independent Gaussian terms is exactly the natural way to combine two independent "closeness" criteria into one joint weight: if either factor is small (pixels far apart in space, *or* very different in intensity), the product collapses toward zero, since a product is only large when *both* factors are large. Two separate, independently-tunable scale parameters control the two notions of closeness: **σ** (the spatial scale, exactly as in §11.2) and **σ_i** (the intensity scale, controlling how different in value two pixels can be before they stop being treated as "the same surface").

**Term-by-term:** the first factor is identical to §11.2's spatial Gaussian; the second factor compares the noisy intensity *at the candidate neighbor x′* against the noisy intensity *at the center pixel x* — note it deliberately uses the noisy image's own values for this comparison, since that's the only information available at filtering time; σ_i is the "intensity sigma," a separate tunable parameter from the spatial σ.

**Walking through the step-edge example again, now with bilateral weighting.** Take a noisy step edge — flat, noisy region on one side, a sharp jump, then another flat, noisy region on the other side. For a pixel sitting near the edge, its same-side neighbors have intensities close to its own (small |i(x′) − i(x)|, so the intensity-Gaussian term stays close to 1, contributing normally) — but its opposite-side neighbors, across the step, have intensities far from its own (large |i(x′) − i(x)|, so the intensity-Gaussian term collapses toward **≈0**, killing that neighbor's contribution almost entirely, *regardless* of how spatially close it might be). The result: the filter effectively only averages same-side pixels together — smoothing out the noise on each side of the edge exactly as a plain Gaussian would — while the sharp step itself survives untouched, because the intensity-difference term has zeroed out every cross-edge contribution before it could blur the transition. This dual behavior — simultaneously **noise-reducing** (within a side) and **edge-preserving** (across a side) — is what the lecture calls **"edge-aware smoothing."**

> **Worked example: the weights, number by number.** A noisy 1D step: values **[0.10, 0.05, 0.12, 0.90, 0.95]**. Filter the middle pixel (value 0.12, just left of the edge). Parameters for illustration only, not HW2 values: **σ = 1 px, σ_i = 0.1**.
>
> | Offset | Value | Spatial weight | Intensity weight | Product (bilateral) | Gaussian normalized | Bilateral normalized |
> |---|---|---|---|---|---|---|
> | −2 | 0.10 | 0.1353 | 0.980 | 0.1327 | 0.0545 | 0.0825 |
> | −1 | 0.05 | 0.6065 | 0.783 | 0.4747 | 0.2442 | 0.2953 |
> | 0 | 0.12 | 1.0000 | 1.000 | 1.0000 | 0.4026 | 0.6221 |
> | +1 | 0.90 | 0.6065 | 6.1 × 10⁻¹⁴ | 3.7 × 10⁻¹⁴ | 0.2442 | 0.0000 |
> | +2 | 0.95 | 0.1353 | 1.1 × 10⁻¹⁵ | 1.5 × 10⁻¹⁶ | 0.0545 | 0.0000 |
>
> - **Gaussian:** normalizer 2.4837, output **0.3375**. The two bright pixels across the edge carry 0.2442 + 0.0545 ≈ 30% of the weight, so the dark pixel is pulled from 0.12 up to 0.3375, toward the bright side: the edge blurs.
> - **Bilateral:** normalizer 1.6074, output **0.0977**. The cross-edge pixels differ from the center by 0.78 and 0.83 in intensity, about eight times σ_i, so their intensity weights are effectively zero. The output stays ≈ 0.1, an average of the dark side only.

**Why this makes the bilateral filter nonlinear, even though it is "just" a weighted average.** For the Gaussian, the normalizer (2.4837) is the same at every pixel, because the weights depend only on distances. For the bilateral filter, the weights depend on the pixel values themselves, so the normalizer changes from pixel to pixel: 1.6074 here, but 2.0100 when the same filter is centered one pixel to the left (using the samples available). A fixed weighted sum is linear; a weighted sum whose weights are recomputed from the input is not. The script shows it directly: doubling the input doubles the Gaussian output (0.6750 = 2 × 0.3375), but the bilateral output of the doubled input is 0.2127, not 2 × 0.0977 = 0.1954. Doubling the input doubled every intensity difference, which changed the weights.

**Linear-algebra view: a matrix that depends on its input.** The bilateral output is W(**i**)·**i**, where the weight matrix W(**i**) is rebuilt from the input each time. (This W is unrelated to §11.3's window W.) For the middle pixel above:
- Row of W(**i**): (0.0825, 0.2953, 0.6221, 0.0000, 0.0000), output 0.0977.
- Row of W(2**i**) for the doubled input: (0.0924, 0.1683, 0.7393, 0.0000, 0.0000), a *different* row. Its output W(2**i**)·2**i** = 0.2127 ≠ 2 × 0.0977.

A matrix that changes with the vector it multiplies is not a linear map. Freeze W and you get a linear weighted average, but the bilateral filter never freezes it. That is how it can be "just a weighted average" and still nonlinear, unlike §11.2's fixed G_σ.

**The parameter space (slide 98).** The lecture sweeps σ_s (its name for the spatial σ) over 2, 6, 18 and σ_r (its name for σ_i, "r" for range, meaning intensity) over 0.1, 0.25, ∞:
- **Growing σ_s** lets the smoothing reach farther, averaging over wider areas of each flat region.
- **Small σ_r** keeps edges strictly: even modest intensity differences cut a neighbor off. Larger σ_r tolerates bigger differences, so weaker edges and texture start to be smoothed away. In the worked example above, the output moves from 0.0977 (σ_i = 0.1) to 0.0971 (0.25), 0.2879 (1.0), and 0.3370 (10), approaching the Gaussian's 0.3375.
- **σ_r = ∞ is exactly a Gaussian blur**, as the slide labels it. Mathematically, the intensity factor is exp(−Δ²/(2σ_r²)). For any fixed intensity difference Δ, the exponent −Δ²/(2σ_r²) → 0 as σ_r → ∞, so the factor → exp(0) = 1 for every neighbor. The bilateral weight becomes spatial weight × 1, which is §11.2's Gaussian weight, and the normalizer becomes the Gaussian's. The script confirms: with σ_i = ∞ the output is 0.3375, identical to the Gaussian.

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

**Translating HW2's notation into these notes'.** HW2 writes the non-local means weight as

```
w(i, j) = (1 / Z(i)) · exp( −‖v(N_i) − v(N_j)‖² / h² ),   for all i ≠ j
```

which is the same formula as the one above, in different symbols:

| HW2 symbol | Meaning | Same thing in these notes |
|---|---|---|
| *i*, *j* | The pixel being denoised, and a candidate pixel | *x*, *x′* |
| *N_i*, *N_j* | The small patch (window) around each pixel | N(*x*), N(*x′*) |
| v(*N_i*) | That patch's pixel values, stacked into one vector | N(*x*)'s values |
| ‖v(*N_i*) − v(*N_j*)‖² | Squared Euclidean distance between the two patch vectors | ‖N(*x′*) − N(*x*)‖² |
| *h* | **Filtering parameter**: how different two patches may be before their weight collapses toward 0; larger *h* averages more aggressively | Plays σ's role: *h*² = 2σ², i.e. *h* = √2·σ |
| *Z*(*i*) | Sum of the unnormalized exp(…) weights over every candidate *j* in the search window | §11.1's *normalizer*: dividing by it makes the weights sum to 1, so the result is a true weighted average |
| "for all *i* ≠ *j*" | The pixel's own patch is left out of the search | Tip (a) above; tip (b) then gives it the largest neighbor weight |

HW2's second formula replaces the plain squared distance with tip (c)'s k_mn-weighted sum. That Gaussian-weighted patch distance is also the form used in Buades, Coll & Morel's original paper. **Scale of *h*:** if the k_mn sum to 1, the weighted distance is a weighted *mean* squared difference per pixel, so a sensible *h* is on the scale of the per-pixel noise level. If the k_mn are left unnormalized (or the plain sum is used), the distance grows with patch size, and *h* has to grow with it to keep the same behavior. Choosing the actual value is part of the assignment.

### 11.6 Comparison: Gaussian vs. Bilateral vs. Non-Local Means

Mirroring the lecture's own "everything put together" summary:

| Method | Depends on | Behavior near edges |
|---|---|---|
| **Gaussian filtering** | Spatial distance only | Smooths everything nearby, including across edges — edges get blurred |
| **Bilateral filtering** | Spatial distance **and** intensity distance | Smooths pixels close in *both* space and intensity — edge-aware |
| **Non-local means** | Patch similarity (intensity-pattern distance) | Smooths similar patches no matter how far away — ignores spatial distance entirely |

### 11.7 BM3D (Brief, Not Required for HW2)

**BM3D** (Dabov et al.) is mentioned by the lecture as current state-of-the-art, non-local denoising — **not** one of HW2's required methods, included here only for context. The idea: find groups of mutually similar image patches (as in §11.5) and stack each group into a 3D block; apply a "collaborative filter" to the whole block at once — a DCT-style transform of the 3D block, thresholding (zeroing) small transform coefficients (the assumption being that true signal concentrates into a few large coefficients while noise spreads thinly across many small ones), then inverting the transform back to pixel values.

### 11.8 Sharpening with a blur (slide 100)

Slide 100 shows "sharpening based on bilateral filtering" next to "sharpening based on Gaussian filtering" and asks: *how would you use Gaussian or bilateral filtering for sharpening?* The standard answer is **unsharp masking**. It sounds backwards: you sharpen an image by first blurring it.

**Analogy.** To exaggerate a friend's accent, first work out what the "plain" version of each word sounds like, subtract it to find what is distinctive, then say the words with that distinctive part turned up. Unsharp masking does the same with an image: the blur is the "plain" version, and the difference is what makes the image crisp.

```
detail     = I − blur(I)
sharpened  = I + k · (I − blur(I))
```

**Intuition, step by step.**
1. A blur is a low-pass filter (§11.2): blur(I) keeps the low image-frequency part of I (smooth shading) and drops the high-frequency part (edges, texture).
2. Subtracting it from the original leaves exactly what the blur removed. This is the **detail layer**: the high-frequency part of the image, near zero in smooth regions and large at edges and texture. (It is the same high-pass construction Week 1 §13.1 used for hybrid images.)
3. Adding a scaled copy of the detail layer back boosts high frequencies relative to low ones. Per §10.3.1, high-frequency luminance content is what the eye reads as sharpness, so the image looks crisper.

**Term-by-term:**
- *I* — the input image (pixel values, e.g. on a [0,1] scale). Fixed by the capture.
- blur(I) — a blurred copy. You choose the blur (Gaussian or bilateral) and its σ, which sets how coarse a structure counts as "base" rather than "detail."
- I − blur(I) — the detail layer, in the same units as I; positive where a pixel is brighter than its neighborhood, negative where darker.
- *k* — the sharpening strength, a dimensionless number you control. k = 0 leaves the image unchanged; larger k exaggerates detail more.

**Linear-algebra view: sharpening is one fixed matrix.** Flatten the image I into a vector **i**, use a Gaussian blur G_σ (§11.2), and write **Id** for the identity matrix (the matrix that leaves every vector unchanged; not the image I). Then
```
sharpened = i + k·(i − G_σ i) = (Id + k·(Id − G_σ))·i = ((1+k)·Id − k·G_σ)·i
```
- Id − G_σ is the **high-pass** (detail-layer) matrix.
- The whole operation is one fixed matrix, so Gaussian unsharp masking is linear: one convolution with one kernel.
- For the worked example below (σ = 1 px with taps out to ±3 px, k = 1), the kernel is (−0.0044, −0.0540, −0.2420, 1.6009, −0.2420, −0.0540, −0.0044). It sums to 1, so flat regions pass unchanged. Applying it reproduces the table's 0.0197 and 0.9803.
- Its negative side lobes are the undershoot and overshoot.
- With a bilateral blur, G_σ becomes §11.4's input-dependent W(**i**), so bilateral sharpening is nonlinear.

> **Worked example: Gaussian unsharp masking overshoots at an edge.** 1D step from 0.2 to 0.8, Gaussian blur with σ = 1 px, k = 1 (illustrative values). The eight pixels around the edge:
>
> | Pixel position | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
> |---|---|---|---|---|---|---|---|---|
> | Input | 0.2 | 0.2 | 0.2 | 0.2 | 0.8 | 0.8 | 0.8 | 0.8 |
> | Gaussian blur | 0.2 | 0.2027 | 0.2351 | 0.3803 | 0.6197 | 0.7649 | 0.7973 | 0.8 |
> | Detail layer | 0 | −0.0027 | −0.0351 | −0.1803 | +0.1803 | +0.0351 | +0.0027 | 0 |
> | Sharpened | 0.2 | 0.1973 | 0.1649 | **0.0197** | **0.9803** | 0.8351 | 0.8027 | 0.8 |
>
> Right next to the edge, the dark side dips to 0.0197, well below its true level 0.2 (**undershoot**), and the bright side jumps to 0.9803, above 0.8 (**overshoot**). The edge's contrast is exaggerated, which reads as crisp. But the dark and bright bands hugging the edge are visible as a glowing outline: a **halo artifact**. It happens because the Gaussian blurred *across* the edge, so the edge itself ended up in the detail layer and got amplified.
>
> **Same step, bilateral blur** (σ = 1 px, σ_i = 0.1): the bilateral filter preserves the edge (§11.4), so blur(I) equals the input, the detail layer is 0 everywhere, and the sharpened output is the unchanged 0.2 / 0.8 step. No halo.
>
> **Add fine texture** (±0.02 alternating pixel to pixel on both sides of the step): with either blur, the texture amplitude in flat regions roughly doubles, 0.02 → 0.0397 (Gaussian) and 0.02 → 0.0389 (bilateral). The texture differences (0.04) are small relative to σ_i, so the bilateral filter blurs the texture like a Gaussian would, and it ends up in the detail layer. But next to the edge, the Gaussian version still overshoots to −0.02 and 1.02, while the bilateral version stays within 0.1612–0.8388, just the plateaus plus the amplified texture.

**The upshot.** With a Gaussian blur, the detail layer contains both texture *and* the edges themselves, so sharpening enhances texture but also draws halos around strong edges. With a bilateral blur, the blur keeps strong edges, so the detail layer holds mostly fine texture. Sharpening then enhances texture and local contrast with much less halo. That is the difference slide 100's two outputs illustrate. (Conceptual only; how far to push *k* and σ is a design choice.)

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

> **Worked example: mid gray, linear 0.18.** Photography's conventional "mid gray" is a surface reflecting 18% of the light, so linear value 0.18 on a [0,1] scale. Encoding it to 8 bits (codes 0–255) three ways:
>
> | Encoding | Encoded value (0–1) | 8-bit code (×255) | Rounded code |
> |---|---|---|---|
> | None (linear) | 0.1800 | 45.90 | 46 |
> | (a) Power law, 0.18^(1/2.2) | 0.4587 | 116.96 | 117 |
> | (b) sRGB piecewise, 1.055·0.18^(1/2.4) − 0.055 | 0.4614 | 117.65 | 118 |
>
> Stored linearly, mid gray gets code 46, so only 46 of the 256 codes are spent on everything darker than mid gray. With either gamma curve it lands near the middle (117 or 118), so roughly half the codes describe the darker half of the perceived tones, which is what "perceptually even spacing" means. The two curves differ by only one code value here, consistent with the sRGB curve approximating γ ≈ 2.2. Decoding recovers the input exactly: 0.4587^2.2 = 0.180000 and the inverse sRGB formula applied to 0.4614 also gives 0.180000.

**The round trip.** The encoding exponent 1/2.2 mirrors the eye's roughly-2.2 perceptual response, so code values are spread evenly in *perceived* brightness. The display then applies the inverse, decoding curve (raising to the power ≈ 2.2, or the exact inverse of the sRGB formula) before emitting light. Encode then decode is the identity, so the light leaving the screen is again proportional to the light the sensor recorded: the overall chain is linear. Gamma encoding is a storage trick, not a change in the picture.

**Linear-algebra view: gamma is not linear, so the matrices come first.** A linear map must satisfy g(a·v) = a·g(v). Gamma fails that test:
- The sRGB curve maps 0.18 to 0.4614, but twice the light, 0.36, maps to 0.6343, not 2 × 0.4614 = 0.9227.
- The simple power law fails the same way: 0.6285 instead of 0.9173.

Every color-space matrix in §4, §7 and §13 describes mixing *amounts of light*, so it is only valid on linear values. Multiplying gamma-encoded numbers by M_XYZ→sRGB would mix the wrong quantities. That is why the pipeline (§9) does gamut mapping, which is linear, *before* gamma correction. (Y′CbCr, §10.3 and §14, is the deliberate exception: it is defined on gamma-encoded R′G′B′ as a coding convenience, not as a statement about mixing light. The prime marks that.)

---

## 13. Gamut Mapping

A camera sensor's native color response is defined by its own physical filters, not by the sRGB primaries of §6 — so a captured image's raw tristimulus values live in the camera's own, device-specific gamut, not in any standardized space. **Gamut mapping** converts from that camera-native gamut to a standard target gamut, typically sRGB, so the resulting image displays correctly and predictably across other people's screens. Internally this is done as a chain of two color-space conversions: camera-native XYZ → standard CIE XYZ (§4) → sRGB (§6) — each step a linear transform between tristimulus bases, in the same spirit as §4's CIE RGB ↔ XYZ relationship. Different choices of exactly how this mapping projects colors that fall outside the target gamut back into it correspond to the different color "modes" (vivid, portrait, landscape, etc.) some cameras offer — different gamut-mapping strategies applied to the same underlying capture.

**Analogy.** Think of translating a text in two steps through a common reference language. Each camera "speaks" its own dialect of RGB, set by its own color filters. Translating first into a universal reference (CIE XYZ) and then into the widely understood target (sRGB) means each camera needs only one calibrated dictionary, into XYZ.

**Reading the slide's "camera XYZ."** The slide's phrase "camera XYZ" means the camera's own native tristimulus responses, i.e. its raw (demosaicked) R, G, B values as defined by its filter SSFs (§1). It is not a true CIE XYZ. Both steps below happen in **linear light**, *before* gamma correction (§12): matrix multiplication only means "mixing amounts of light" when the numbers are proportional to light.

**Step 1: camera RGB → CIE XYZ.**

```
[X; Y; Z] = C · [R_cam; G_cam; B_cam]
```

*C* is a 3×3 color matrix found by **calibration**: photograph targets with known XYZ values (e.g. a color chart) and fit the matrix that best maps the camera's readings onto them. It is **camera-specific** (different sensors have different filters), fixed by the manufacturer or calibration, not something the photographer sets. Because the camera's SSFs are generally not exact linear combinations of the standard observer's matching functions, a 3×3 matrix is a best fit, not an exact conversion.

**Step 2: CIE XYZ → linear sRGB.** This matrix is standardized (IEC 61966-2-1) and doesn't need to be looked up. It follows from sRGB's primaries and D65 white by the same construction as §7's worked example: build the sRGB → XYZ matrix column by column, then invert it. Shown below are the left matrix as computed and, on the right, the inverse as the standard publishes it (rounded to 4 decimals; the exact inverse differs in the fourth decimal, see the linear-algebra view below):

```
sRGB → XYZ:                     XYZ → linear sRGB (its inverse):
[0.4124  0.3576  0.1805]        [ 3.2406  −1.5372  −0.4986]
[0.2126  0.7152  0.0722]        [−0.9689   1.8758   0.0415]
[0.0193  0.1192  0.9505]        [ 0.0557  −0.2040   1.0570]
```

**Term-by-term:**
- Each **column** of the left matrix is the XYZ of one sRGB primary at full strength (red, green, blue). The middle row, 0.2126 / 0.7152 / 0.0722, is each primary's luminance Y. They sum to 1, so sRGB white (1, 1, 1) has Y = 1, and green dominates perceived brightness, consistent with V(λ) peaking in the green (§4).
- The right matrix undoes the left. Its **negative entries** are the key feature: an XYZ color outside the sRGB triangle yields a negative (or above-1) channel, which is §6's "outside the gamut" statement made numeric.
- Sanity check from the script: D65 white's XYZ maps to exactly (1, 1, 1).
- Inputs are XYZ with white scaled to Y = 1; outputs are linear sRGB values, valid (displayable) only when all three lie in [0, 1]. Gamma encoding (§12) comes *after* this.

**Linear-algebra view: composing and inverting changes of basis.**
- **Columns are the new basis vectors.** The columns of a change-of-basis matrix are the new basis vectors written in the old coordinates. M_sRGB→XYZ's columns are sRGB's red, green and blue primaries written in XYZ: (0.4124, 0.2126, 0.0193), (0.3576, 0.7152, 0.1192), (0.1805, 0.0722, 0.9505). Projecting each onto xy (§5) gives back exactly (0.640, 0.330), (0.300, 0.600), (0.150, 0.060), sRGB's corners.
- **Composition.** The two steps are v_sRGB = M_XYZ→sRGB · (C · v_cam) = (M_XYZ→sRGB · C) · v_cam. The ISP can multiply the two matrices once and apply the single combined 3×3 matrix to every pixel. Order matters (matrix products don't commute): the rightmost matrix is applied first.
- **The inverse undoes a conversion.** M_XYZ→sRGB = (M_sRGB→XYZ)⁻¹. Multiplying the two 4-decimal matrices printed above gives the identity Id to within 3.5 × 10⁻⁵:
  ```
  [ 0.999999   0.000023   0.000006]
  [ 0.000016   1.000035  −0.000006]
  [−0.000006   0.000025   1.000002]
  ```
  The leftover comes from rounding: the standard's published 4-decimal inverse differs slightly from the exact inverse of the left matrix, (3.2410, −1.5374, −0.4986 / −0.9692, 1.8760, 0.0416 / 0.0556, −0.2040, 1.0570).

> **Worked example: a color sRGB can't show.** Take Display P3's green primary (§7), a real color that P3 screens display. Its XYZ is (0.2657, 0.6917, 0.0451), chromaticity xy = (0.2650, 0.6900). Through the exact XYZ → sRGB inverse (the published 4-decimal matrix gives (−0.2247, 1.0419, −0.0786), the same to rounding):
>
> **linear sRGB = (−0.2249, 1.0421, −0.0786)**
>
> Red and blue come out negative and green exceeds 1. No sRGB display can produce this: the color lies outside the sRGB triangle, whose green corner is at (0.300, 0.600).

**Strategy 1: clipping.** Clamp each channel to [0, 1] separately. Here, (−0.2249, 1.0421, −0.0786) → (0, 1, 0), which is simply sRGB's own green primary at xy = (0.3000, 0.6000), with luminance Y = 0.7152 instead of the original 0.6917. It is simple and cheap, but it has costs:
- It **shifts hue and brightness**, because each channel is changed independently.
- It **collapses detail**: every out-of-gamut color that clips to the same corner becomes identical, so gradations in a saturated region (a flower petal, a neon sign) flatten into a single patch.

**Strategy 2: compression / perceptual mapping.** Move out-of-gamut colors inward smoothly instead of chopping them. One simple version keeps the luminance and blends toward the neutral gray of the same brightness until every channel is legal. For the P3 green, a 24.54% blend toward gray (Y = 0.6917 in all three channels) gives linear sRGB (0, 0.9561, 0.1104), at xy = (0.2843, 0.5436), with luminance still 0.6917. The color is less saturated than the original but keeps its brightness. Real implementations typically also compress nearby in-gamut colors a little, so neighboring shades stay distinguishable instead of piling up at the boundary.

**Camera "modes."** Choosing how aggressively to compress, how much saturation to preserve versus hue accuracy, and where to accept clipping is exactly the kind of "different ways of projecting the colors" the slide ties to vivid/portrait/landscape modes. Which specific strategy a given manufacturer uses isn't something the lecture specifies, and it varies.

---

## 14. JPEG Compression

JPEG compression is lecture content, not one of HW2's tasks, so this is covered at a lighter, conceptual level. The standard pipeline:

1. **Transform to Y′CbCr** — exactly the same luma/chrominance representation built in §10.3, now used for compression rather than demosaicking.
2. **Downsample the chroma channels.** Because human vision is far more sensitive to fine (high spatial-frequency) luminance detail than chrominance detail (§10.3.1; the identical fact §10.3 already used to justify chrominance-only low-pass filtering during demosaicking), JPEG throws away *spatial resolution* in Cb and Cr — not Y′ — to save space, at standard ratios: **4:4:4** (no downsampling — every luma sample has its own chroma sample), **4:2:2** (chroma downsampled 2× horizontally), and **4:2:0** (chroma downsampled 2× in both directions, the most aggressive of the three, and the most common default).
3. **Split into 8×8 pixel blocks.**
4. **Discrete cosine transform (DCT) each block**, per channel — conceptually the same spatial-frequency-decomposition idea (here image frequency, cycles per pixel within the block; §10.3.1) as the Fourier transform built up in Week 1 §12.4 (a different but related basis of waves, here confined to small 8×8 blocks rather than the whole image).
5. **Quantize the resulting DCT coefficients** — divide each coefficient by a (typically image-frequency-dependent) step size and round, discarding fine distinctions in coefficients human vision is least likely to notice (typically the higher image-frequency ones, where §10.3.1's fine detail and noise live).
6. **Entropy/run-length code the quantized coefficients** — a lossless compression step (no further information is thrown away here) that exploits the fact that quantization tends to leave long runs of zero-valued coefficients, especially at high image frequencies (cycles per pixel) within a block.

**Linear-algebra view: the DCT is a change to an orthonormal cosine basis.**
- One 8×8 block of one channel is 64 numbers: a vector **b** in the 64-dimensional space ℝ⁶⁴.
- The 2D DCT chooses 64 basis vectors, each an 8×8 cosine pattern (one horizontal image frequency times one vertical). The block's DCT coefficients are its **coordinates** in that basis: **c** = T**b**, where T is the 64×64 matrix whose rows are those patterns.
- The basis is **orthonormal**: every pattern has length 1 and every two are perpendicular. So T⁻¹ = Tᵀ, and the inverse is just the transpose, with no system to solve. Script check: the largest entry of T·Tᵀ − Id is 1.4 × 10⁻¹⁵. A random block's vector length is also unchanged by T to 15 digits.
- Step 4 therefore loses nothing. **Quantization** (step 5) is where information goes: rounding coordinates coarsely, and zeroing many, discards the block's components along mostly high-frequency basis vectors. The decoder rebuilds Tᵀ·(kept coordinates).

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
