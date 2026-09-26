# CSC2529 Computational Imaging — Week 2 Study Notes

**Topic:** Digital Photography I — Ray Optics, Aperture, Sensor
**Source:** Lecture 2 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 2 ("PS2," a TA problem session covering HW2), Task 1 only (f-number / depth of field / circle of confusion); reading: Marc Levoy, Stanford CS178 "Digital Photography" course.
**Scope:** Announcements and the guest-colloquium plug skipped — notes start from "Let's say we have a sensor…". PS2's Tasks 2–3 (demosaicing methods, gamma correction, denoising) belong to the image-signal-processing pipeline the lecture itself defers to "Next" — that material is Week 3's, not repeated here.
**Exam note:** this lecture is unusually formula-dense, and several of its formulas reuse the same handful of symbols with quietly-shifted meanings across sections (flagged explicitly below wherever it happens) — the most common source of confusion on this material is mixing up which symbol means what in which formula, not the algebra itself.

---

## 0. Why doesn't a bare sensor take a picture?

Point a digital sensor (the electronic chip that converts light into an electrical signal — introduced as the camera's "retina" in Week 1 §1, §4) at a scene with nothing in between, and you get nothing usable: every point on the sensor receives light from *every* point in the scene at once, all overlapping. There is no optical element separating "light from here" from "light from there," so the sensor just measures one blurred average brightness everywhere — not an image.

That "one blurred average" is not perfectly flat, however — it is a heavily blurred version of the scene, not a single uniform value. A sensor location's measured brightness is a weighted sum of light arriving from every scene point, and the weight is not equal for every point: light landing nearly head-on (close to perpendicular to the sensor surface) contributes more than light arriving at a shallow, grazing angle (a cosine falloff for the angle of incidence), and light from a nearer scene point contributes more than light from a farther one (the same inverse-square-law falloff that makes a light source look dimmer the farther away it is, per §3). Because each sensor location sits at a slightly different position, it is dominated by a slightly different — though heavily overlapping — mix of the scene. Only the coarsest, lowest-spatial-frequency shapes survive this averaging (broad regions of light vs. dark, large blobs of color); anything with fine spatial detail washes out completely. The result looks like a photo taken with extreme, maximal defocus blur: a smear of the scene's biggest shapes, not a flat gray field.

**Linear-algebra view (image formation as a matrix–vector product):** list the brightness of every scene point as one long vector **x** (standard basis: each basis vector is "one scene point lit, all others dark"), and every sensor reading as a vector **y**. Because each reading is a weighted sum of scene brightnesses, the whole capture is one **linear map**, **y** = **A x**, where entry A_ij is the cosine-and-distance weight from scene point j to sensor location i. For a bare sensor, neighboring rows of **A** are nearly identical, so the matrix is **ill-conditioned**: some directions in scene space are shrunk almost to zero and cannot be recovered. In a toy 1D model (8 scene points, 8 sensor locations, weights = cos/distance²) the **singular values** of **A** run from 6.41 down to 3.18 × 10⁻⁶, a **condition number** (largest ÷ smallest singular value, i.e. how much measurement errors can be amplified when inverting) of about 2.0 × 10⁶. An ideal pinhole (§1) turns **A** into a **permutation matrix** (each scene point sent to exactly one mirrored sensor location) with condition number exactly 1. Treating **y** = **A x** as something to invert is the inverse-problem framing of Weeks 5–6.

Everything in this lecture is optics or sensing built to fix exactly that problem: some device between scene and sensor that maps *each scene point to (ideally) one sensor location*, so that spatial structure in the scene survives into spatial structure in the image.

**Standing assumption — ray optics.** Both the pinhole camera (§1–3) and the lens (§4 onward, until §10 revisits wave effects) are analyzed using **[ray optics](https://en.wikipedia.org/wiki/Geometrical_optics)** (also called geometric optics): light is modeled as travelling in perfectly straight lines ("rays") that only bend at a lens surface or get blocked by an opaque barrier, ignoring the fact that light is actually a wave. This is the same simplifying assumption behind HW1's pinhole-box geometry. It's an excellent approximation almost everywhere in this lecture — until §2 and §10, where the *size* of an opening becomes small enough that light's wave nature can no longer be ignored, and ray optics alone stops predicting the right answer.

---

## 1. The Pinhole Camera

**Fix:** put an opaque barrier (a **diaphragm**) between scene and sensor, with a single small opening in it — a **pinhole**, also called a **[camera obscura](https://en.wikipedia.org/wiki/Camera_obscura)**, or the camera's **[aperture](https://en.wikipedia.org/wiki/Aperture)** in this context (the general "opening that controls how much light gets in," first introduced via the eye's pupil in Week 1 §1). Now, of all the rays leaving any one scene point in every direction, only the *one* ray heading straight at the pinhole makes it through to the sensor — every other ray from that point is blocked by the barrier. Each scene point therefore lights up (ideally) exactly one sensor location, instead of smearing across the whole sensor as in §0.

**Geometry and terms** (all consequences of straight-line ray optics, §0):
- **Camera center** (or **center of projection**): the pinhole itself — every surviving ray passes through this single point.
- **Image plane**: the sensor surface, where the surviving rays land.
- **Focal length, f**: the distance from the pinhole to the image plane.

Because every ray travels in a straight line through one fixed point (the pinhole), the image that lands on the sensor is a scaled, upside-down copy of the scene — trace a ray from the top of an object, through the pinhole, and by simple straight-line geometry it continues downward, landing on the *bottom* of the image plane (and vice versa). This is the same similar-triangles idea used throughout the course: two rays from the same object point, one passing above the pinhole's axis and one below, form mirror-image triangles on either side of the pinhole, so the image is inverted **and** rescaled by the ratio of distances (pinhole-to-sensor vs. pinhole-to-object).

**Focal length controls image size.** Halving the focal length (moving the sensor to sit half as far behind the pinhole) exactly halves the size of the projected image, for the same reason a shadow shrinks as you move the wall closer to the object: the same cone of rays from an object, converging back down to the single pinhole point, is caught by the image plane at half the distance, so it's caught before spreading as wide.

**A pinhole never needs "focusing."** Notice there is no separate notion of "the distance the pinhole is focused at" — every scene point, at every distance, projects through the same single undeviated ray to exactly one sensor point, regardless of how far away it is. Keep this in mind for §5: it's exactly the property a lens gives up in exchange for gathering more light.

**Linear-algebra view (perspective projection in homogeneous coordinates):** put the pinhole at the origin, with basis axes sensor-horizontal *X*, sensor-vertical *Y* and depth *Z* along the optical axis, and append a 1 to each scene point to get its **homogeneous coordinates** (X, Y, Z, 1). The 3×4 **camera matrix** P = [[−f, 0, 0, 0], [0, −f, 0, 0], [0, 0, 1, 0]] maps that vector **linearly** to (−fX, −fY, Z), and dividing by the last entry (the depth) gives the sensor position (−fX/Z, −fY/Z): *f*·X/Z is the similar-triangles ratio above, and the minus signs are the upside-down flip. P has **rank** 3, so one input dimension is lost; its **null space** is spanned by (0, 0, 0, 1), the pinhole itself. Every point t·(X, Y, Z) on one ray yields a scaled copy of the same output vector, which the division collapses to one pixel: with *f* = 50 mm, (100, 200, 1000) mm and (200, 400, 2000) mm both land at (−5, −10) mm. The collapsed dimension is depth, which is why one photo cannot tell how far away anything is, and why depth sensors such as LiDAR must add a separate distance measurement along each ray.

---

## 2. Pinhole Size: A Sharpness/Light Trade-off, and the Diffraction Limit

An *ideal* pinhole is infinitesimally small (a true single point), but that's physically impossible to manufacture, and even if it were possible it would let through zero light. So every real pinhole has some nonzero diameter, and that diameter turns out to control image quality from two directions at once — one predicted by the ray optics of §1, the other requiring a genuinely new idea.

**Direction 1 — geometric blur (ray optics still applies).** A pinhole with nonzero diameter doesn't pass just *one* ray per scene point — it passes a small *cone* of rays (every ray from that point that happens to hit somewhere within the finite opening). Each of these rays lands at a slightly different spot on the sensor, so a single scene point no longer projects to a single sensor point — it projects to a small blurred disc the same size as the pinhole opening. **The larger the pinhole, the blurrier the image.** This predicts that shrinking the pinhole should sharpen the image indefinitely — but it doesn't.

**Linear-algebra view (pinhole blur as a convolution matrix):** in §0's **y** = **A x** picture, a finite pinhole replaces the ideal permutation matrix with a matrix where each column (one scene point) is a small disc of nonzero weights instead of a single 1. Since the same disc appears at every position, each row is the previous row shifted by one: a **Toeplitz** (constant-along-diagonals) **convolution matrix**, restated from Week 1 §12.4.5. The Fourier basis **diagonalizes** such a matrix, with the disc's own Fourier transform as the eigenvalues. A bigger disc makes more of those eigenvalues close to zero, so more fine detail is effectively lost. Undoing this matrix is **deconvolution**, the subject of Weeks 5–6.

**Direction 2 — diffraction (a genuinely new, wave-optics effect).** Once the pinhole is only a few multiples of the wavelength of light wide, **[diffraction](https://en.wikipedia.org/wiki/Diffraction)** — the tendency of a wave to spread out after passing through a narrow opening — takes over, and ray optics (which assumes light *doesn't* spread like this) stops being an adequate model. Diffraction is a direct consequence of the wave nature of light: squeezing a wave through a small enough gap causes it to fan out on the other side, and the *smaller* the gap, the *more* it fans out.

**Why, precisely — the diffraction pattern is the aperture's Fourier transform.** The pattern of light spreading out past an opening is, quite literally, the two-dimensional **[Fourier transform](https://en.wikipedia.org/wiki/Fourier_transform)** of the opening's shape — the same Fourier-transform idea built up from scratch in Week 1 §12.4 to explain hybrid images, now showing up in physical optics rather than digital image processing. Recall from Week 1 §12.4.3 that a *small*, tightly-packed feature in the spatial domain corresponds to spectral energy spread across *large* (u, v) values in the frequency domain — a general fact about the Fourier transform, not specific to images. A pinhole is exactly that kind of spatial-domain feature: a small physical opening. So by that same general fact, a *smaller* pinhole produces a *wider*-spread diffraction pattern (energy pushed out to large spatial frequencies), while a *larger* pinhole produces a *narrower*, more tightly concentrated diffraction pattern close to the geometric-optics prediction.

**Putting the two directions together:** shrinking the pinhole reduces geometric blur (good) right up until diffraction effects take over and start *increasing* blur again (bad) — so there is a genuine sweet-spot pinhole diameter that minimizes total blur, not "smaller is always sharper."

### 2.1 The Exact Trade-off: Optimal Pinhole Diameter

**Writing both blur contributions as one quantity to minimize.** Direction 1 says a pinhole of diameter *d* smears each scene point into a blurred disc roughly *d* wide — geometric blur ≈ *d*. Direction 2 says diffraction fans light out by an angle of roughly λ/*d* radians after it squeezes through an opening of width *d* (a standard result: the narrower the gap relative to the wavelength, the wider the fan-out); over the distance *f* from pinhole to image plane, that angular spread becomes a linear spread on the sensor of about *f*·λ/*d* (small-angle approximation: linear spread ≈ angle × distance). Adding the two independent contributions gives one blur-size function of the pinhole diameter:

```
blur(d) ≈ d + fλ/d
```

**Why the minimum sits where the two contributions balance, not at either extreme.** The first term grows with *d* (bigger hole → more geometric blur); the second shrinks with *d* (bigger hole → less relative diffraction spread). Shrinking *d* always helps one term while hurting the other, so `blur(d)` bottoms out where they're comparable in size, not where either term alone is smallest — setting its derivative to zero (d(blur)/d*d* = 1 − fλ/d² = 0) gives d² = fλ, i.e. d ≈ √(fλ). The course's own pinhole-camera build slides give this same balance with a leading factor of 2 from the exact geometry of the two blur terms:

```
d = 2√(fλ)
```

where *f* is the pinhole-to-image-plane distance (the pinhole's focal length, §1) and λ is the wavelength of light being imaged (nothing to do with spatial or temporal frequency — see Week 1 §12.0's frequency disambiguation). This is precisely the formula behind "how big should the hole be" for HW1's hand-built pinhole box; plugging in your own box's focal length to get an actual diameter in millimeters is the homework step, left to the assignment.

---

## 3. Light Efficiency vs. Pinhole Size and Focal Length

Two independent geometric facts, both straightforward consequences of §1's ray-optics picture:

- **Doubling the pinhole diameter quadruples the light reaching the sensor.** The amount of light passing through an opening scales with its *area*, not its diameter, and the area of a circular opening scales with the *square* of its diameter (area = π·(diameter/2)²) — so doubling the diameter multiplies the area, and therefore the light, by 2² = 4.
- **Doubling the focal length quarters the light reaching the sensor.** Moving the sensor twice as far from the pinhole spreads the same total bundle of light over roughly 4× the sensor area (the same inverse-square-law reasoning that makes a light source look dimmer from farther away), so the light *per unit area* — the quantity that actually matters for exposure — drops by a factor of 4.

These two facts are the geometric seed of the aperture/f-number trade-off formalized in §8, and of the exposure concept formalized in §13.

---

## 4. Refraction, the Thin Lens Model, and the Gaussian Lens Formula

A pinhole's fundamental problem is that "small enough to be sharp" and "large enough to gather useful light" pull in opposite directions (§2–3) — a pinhole can never have both. A **lens** — a shaped piece of transparent material, most often glass — solves this by bending many rays from the same scene point back together at one image point, so the imaging aperture can be made large (lots of light) without smearing the image (still sharp).

**[Refraction](https://en.wikipedia.org/wiki/Refraction)** is the bending of a light ray when it crosses the boundary between two materials with different optical densities (e.g., air into glass) — the same phenomenon that makes a straw look bent where it enters a glass of water. A lens is manufactured with precisely curved surfaces so that refraction bends parallel or diverging rays in a specific, useful way: toward a common point.

**The thin lens model** is a deliberate simplification of real (curved, thick) lens geometry, valid for well-designed lenses, built on two assumptions:

1. **A ray passing through the exact center of the lens is unaffected** — it continues in a straight line, as if the lens weren't there.
2. **All rays that arrive parallel to each other converge to a single point on the focal plane** — the plane located one focal length *f* behind the lens.

These two assumptions are enough to trace an image by hand using three characteristic rays from any object point:
- the **parallel ray**, which travels parallel to the lens's main axis and then bends through the far focal point (assumption 2);
- the **chief ray**, which passes straight through the lens center unbent (assumption 1);
- the **near-focal-plane ray**, which passes through the *near* focal point on its way to the lens and emerges parallel to the axis (the reverse of assumption 2).

All three rays from the same object point reconverge at the same image point — which is both the geometric justification for the thin lens model and the standard hand-tracing technique for predicting where an image will form. §4.1 turns exactly two of these three rays into algebra.

### 4.1 Scene-space vs. image-space: deriving the Gaussian lens formula

The hand-tracing picture above is qualitative — it tells you *that* the three rays meet, but not *where*, in numbers. To get a formula, put actual measurements on the picture:

| Symbol | What it measures |
|---|---|
| *y* | height of the object above the lens's central axis |
| *S* | **object distance** — from the object to the lens |
| *f* | **focal length** — from the lens to its focal point (a fixed property of the lens, §4.2) |
| *S′* | **sensor distance** (also called *image distance* or *focus distance*) — from the lens to wherever the sharp image actually forms |
| *y′* | height of the image below the axis (the image is inverted, so *y′* points the opposite way from *y*; the diagram below treats both as unsigned magnitudes and keeps track of the inversion separately, exactly as the ray-tracing above already showed it) |

Two of the three characteristic rays each give one similar-triangles relation between these quantities:

**Relation 1 — from the chief ray.** The chief ray passes straight through the lens center, so the triangle formed by (object, lens center, axis) on the scene side is similar to the triangle formed by (lens center, image, axis) on the image side — they share the same vertex angle at the lens center. Similar triangles means their corresponding side ratios are equal:

```
y'/y = S'/S
```

**Relation 2 — from the parallel ray.** The parallel ray travels flat until the lens, then bends through the far focal point *f* behind the lens and continues to the image point. This produces a *second*, different pair of similar triangles — one spanning the object height over the full object distance, the other spanning the image height over just the last stretch *(S′ − f)* from the focal point to the image:

```
y'/y = (S' - f)/f
```

**Combining the two relations** (both equal *y′/y*, so they equal each other) eliminates the heights entirely and leaves a relation purely between distances:

```
S'/S = (S' - f)/f
⟹ f·S' = S·(S' - f)          (cross-multiply)
⟹ f·S' = S·S' - S·f
⟹ f·S' + S·f = S·S'          (move S·f to the left)
⟹ f·(S' + S) = S·S'          (factor out f)
⟹ (S' + S)/(S·S') = 1/f      (divide both sides by S·S'·f)
```

```
1/S + 1/S' = 1/f
```

This is the **thin lens equation** (also called the **Gaussian lens formula**) — the single algebraic fact that ties together where an object sits (*S*), where its sharp image forms (*S′*), and the lens's own fixed focal length (*f*). Substituting *S′ = fS/(S−f)* (solved from the same equation) back into Relation 2 gives the **magnification**:

```
m = y'/y = (S' - f)/f
```

*(equivalently m = S′/S, from Relation 1 — both are the same quantity, just expressed with different variables substituted in.)* Consistent with §1's pinhole finding that a shorter focal length shrinks the image: for a fixed object distance, shrinking *f* also shrinks the *S′* the equation demands, and *m* shrinks with it.

**Linear-algebra view (ray-transfer matrices):** the lecture traces rays with similar triangles, but the thin lens model is secretly a **linear map** on a 2-entry vector per ray: (height above the axis, angle to the axis in radians, small-angle approximation). Travelling a distance *L* is the matrix [[1, L], [0, 1]] (height grows by *L*·angle), and the thin lens is [[1, 0], [−1/f, 1]] (height unchanged, per assumption 1; angle bent in proportion to height, per assumption 2). Multiplying object-to-lens, lens, lens-to-sensor gives the whole camera as one 2×2 matrix whose top-right entry is S + S′ − S·S′/f = S·S′·(1/S + 1/S′ − 1/f). That entry is 0 exactly when the thin lens equation holds; then output height no longer depends on input angle, which is *why* every ray from one object point meets at one image point, and the top-left entry reduces to −S′/S, the magnification with its inversion sign. Example with illustrative numbers: *f* = 50 mm, *S* = 150 mm gives *S′* = 75 mm and the matrix [[−1/2, 0], [−1/50, −2]] (determinant 1, as every product of these matrices has).

### 4.2 Intrinsic lens properties vs. setup properties

This is the single most useful distinction for reading every formula in the rest of this lecture without confusing yourself:

- **Intrinsic to the lens** (fixed the moment the glass is ground; you cannot change it without physically swapping the lens, or, for a zoom lens, changing the zoom setting): the **focal length *f***, and — once §7 introduces it — the lens's maximum aperture diameter and its aberration characteristics (§6).
- **A property of the scene, not the lens at all**: the **object distance *S***, i.e., however far away the thing you're photographing happens to be. Nothing about the lens sets this; it's just wherever the subject is standing.
- **A property of the setup / how the lens interacts with the sensor**: the **sensor distance *S′***. This is *not* fixed by the lens alone — it's a mechanical choice. Turning a lens's focus ring physically moves internal lens elements, which changes the effective distance from the lens's optical center to the sensor. *S′* is the thing a focus mechanism (manual ring or autofocus motor) actively adjusts.

The thin lens equation `1/S + 1/S' = 1/f` is precisely the constraint linking these three. For a *fixed* focal length *f* (you can't change that) and a *chosen* object distance *S* (wherever your subject is), there is exactly **one** value of *S′* that puts it in sharp focus — the value the equation demands. **"Focusing" means physically turning the focus ring until *S′* reaches that value.** Get *S′* right for your chosen *S*, and the image is sharp; leave it at the wrong value, and you get the defocus blur that §5 formalizes.

### 4.3 The inverse relationship: how moving the lens changes what's in focus

**In practice, *S′* is usually the variable you actually know, and *S* is what you calculate.** The lens's physical position — set by the focus ring or autofocus motor — fixes *S′* directly; the object distance that ends up in focus, *S*, is the one this section's rearranged equation solves for. (§4.2 described the thin lens equation from the other direction — "choose a subject distance *S*, then find the *S′* needed" — useful for explaining *why* focusing works at all. This section's direction — "given wherever the ring already is, *S′*, find what's now in focus, *S*" — is the one you'll actually use when tabulating a focus distance from a known lens setting.)

Rearranging the thin lens equation to isolate the object distance that's currently in focus, for whatever sensor distance *S′* the focus ring happens to be set to:

```
S = 1 / (1/f - 1/S')
```

Read this rearrangement directly: **as *S′* increases, 1/*S′* shrinks, so `1/f − 1/S′` grows, so *S* shrinks.** In plain language — moving the lens *farther* from the sensor (larger *S′*) brings the *plane of focus closer* to the camera; moving the lens *closer* to the sensor (smaller *S′*) pushes the plane of focus *farther* away. This is exactly what the lecture's own focus-ring diagram shows, and it's the physical mechanism behind every manual-focus and autofocus system: there is no separate "focus knob" other than this one lens-to-sensor distance.

> **Two special focus distances, worked symbolically (general facts about *any* lens, not tied to a specific homework setup).**
> - **Infinity focus:** set *S′ = f* exactly. Plugging into the thin lens equation, `1/S = 1/f − 1/f = 0`, so *S = ∞*. This is why "infinity focus" is a single, fixed lens position — exactly one focal length from the sensor — rather than a moving target: it's the *S′ = f* limit of the same equation everything else in this section uses. (It's also consistent with assumption 2 of the thin lens model: parallel rays, i.e. rays from an object infinitely far away, converge exactly at the focal plane.)
> - **Unity magnification ("1:1 macro"):** set *S′ = S = 2f*. Check the thin lens equation: `1/(2f) + 1/(2f) = 2/(2f) = 1/f` ✓. Check the magnification: `m = (S′−f)/f = (2f−f)/f = 1`. A symmetric setup — object and sensor equally far from the lens, each at twice the focal length — reproduces the object at exactly life-size on the sensor.

---

## 5. Defocus: What Happens When the Object Isn't at the Focused Distance

§4.2 established that for a given, fixed sensor distance *S′* (wherever you last left the focus ring), the thin lens equation names exactly *one* object distance that comes out sharp. The lecture's own notation gives this specific, currently-in-focus distance a name distinct from wherever an actual scene point happens to sit:

- **S** — the **in-focus (or "focused") object distance**: whatever distance the thin lens equation currently predicts for the fixed *S′* the lens is set to. This is the *same* symbol *S* as §4.1, just now thought of as "fixed by wherever you left the focus ring" rather than as a free variable.
- **O** — the **actual object distance**: wherever a real point in the scene actually is. It only equals *S* by coincidence (or because you deliberately focused on it).

When *O = S*, that scene point's rays converge exactly at the sensor plane, and it renders as a sharp point. When *O ≠ S*, the thin lens equation says those rays actually want to converge somewhere *other* than the sensor plane — either before it (if the true object is farther than the focused distance) or after it (if closer) — so by the time they reach the actual, fixed sensor, they've re-diverged into a small blurred disc instead of a point. This blurred disc is the **circle of confusion**, and its exact size is derived in §9.2. In the linear-algebra picture of §2, defocus is still a **linear map** (a sum of blurred discs), but the disc's width depends on each point's depth *O*, so for a scene with many depths the matrix is no longer one shift-invariant convolution: different columns carry different-sized discs.

**Why this never happens with an ideal pinhole (§1).** A pinhole has no focal length and no focus distance to get wrong — every scene point, at every distance *O*, projects through its single undeviated ray to one sensor point, with no dependence on *O* at all. Defocus is specifically a lens phenomenon: it's the price paid for the light-gathering aperture a lens buys over a pinhole (§4's entire motivation for using a lens in the first place).

**Focus is local to one plane.** Because a single fixed *S′* only satisfies the thin lens equation for one *S*, and real scenes have objects at many different actual distances *O* at once, no single lens position brings an entire non-flat scene into focus simultaneously — some range of nearby distances will look "acceptably" sharp and everything else will show some degree of defocus blur. Exactly how wide that acceptably-sharp range is is the subject of **depth of field**, §9.3.

---

## 6. Real Lenses: Compound Lenses and Aberrations

**Thin lenses are a fiction.** The thin lens model assumes a lens with literally zero thickness, which no real lens has. Real camera lenses are **compound lenses**: several individual lens elements stacked together, engineered so that, to a good approximation, the whole stack behaves paraxially (i.e., for rays close to the central axis) like one single ideal thin lens with some equivalent focal length and aperture.

Even a well-engineered compound lens doesn't behave *exactly* like the thin lens model — the differences are called **aberrations**: any systematic deviation from ideal thin-lens focusing behavior.

| Aberration | Cause | Where it appears |
|---|---|---|
| **Spherical aberration** | Real lens surfaces are usually ground *spherical*, not the ideal hyperbolic shape that would perfectly focus parallel rays to one point (spherical surfaces are simply far easier to manufacture — two curved surfaces ground together mechanically settle into a sphere) | Everywhere in the field, worst for rays far from the lens's central axis |
| **[Chromatic aberration](https://en.wikipedia.org/wiki/Chromatic_aberration)** | Glass has **[dispersion](https://en.wikipedia.org/wiki/Dispersion_(optics))** — its refractive index (and therefore its effective focal length) depends slightly on wavelength — so different colors of light focus at slightly different distances | Everywhere in the field; partially correctable with a two-element "doublet" combining glasses of different dispersion so their errors cancel |
| **Oblique aberrations** (coma, pincushion/barrel distortion, astigmatism, field curvature, etc.) | Departures from the paraxial assumption itself | Only away from the center of the field of view — unlike spherical/chromatic aberration, these are zero exactly on-axis and grow toward the edges |

A famous real-world example: the Hubble Space Telescope's primary mirror originally suffered from severe spherical aberration due to a manufacturing error, corrected in orbit by the COSTAR instrument package — a striking demonstration that "aberration" is a precise, fixable geometric fact about a specific optical system, not just a vague image-quality complaint.

---

## 7. Field of View

**[Field of view (FOV)](https://en.wikipedia.org/wiki/Field_of_view)** is the angular extent of the scene a lens/sensor combination captures — the same angular-extent idea introduced for the human eye in Week 1 §7 (monocular ~190°, binocular ~120°), now applied to a camera. It depends on both the lens's focal length *f* (intrinsic, §4.2) and the physical size of the sensor capturing the image (a property of the camera body, not the lens): a longer focal length concentrates the same sensor size onto a narrower angular slice of the scene (a "telephoto" or "zoom" effect), while a shorter focal length spreads a wider angular slice onto that same sensor size (a "wide-angle" effect).

This is exactly the same right-triangle relationship as Week 1 §9's screen-pixel formula, just run in the opposite direction: there, a fixed angle and a known distance gave a physical size; here, a fixed physical size (the sensor) and a known distance (the focal length) give an angle. For a sensor dimension *d* and focal length *f*:

```
FOV = 2 · arctan(d / (2f))
```

**Components:** *d* is the sensor's physical width or height (a fixed number, set by the camera body); *f* is the lens's focal length (intrinsic, §4.2); the *2×* and the *arctan* come from splitting the sensor in half around the lens's central axis and treating each half as one leg of a right triangle whose other leg is the focal length — the same half-angle construction as Week 1 §9's `p = 2·d·tan(α/2)`, just solved for the angle instead of the length.

Concretely (values as cited in lecture, for a full-frame sensor): an 8 mm lens gives roughly 180° FOV, a 50 mm "normal" lens gives roughly 43°, and a 1000 mm super-telephoto lens narrows to roughly 2.5° — the same sensor size, wildly different captured angle, purely as a function of focal length.

> **Worked example, from lecture: the Hubble Space Telescope's focal length.** Posed as a "what's the focal length?" exercise: given Hubble's field of view (52 arcseconds ≈ 0.0144°) and its 1024×1024 CCD, running §7's FOV formula in reverse gives Hubble's actual effective focal length: **f ≈ 57.6 m** — an extreme telephoto by any camera-lens standard (compare the 1000 mm/2.5° row of the table above; Hubble's FOV is roughly 170× narrower still). The lecture pairs this with a genuinely surprising follow-up fact: Hubble's physical optical tube assembly is only **13.2 m long** — far shorter than a straight lens barrel achieving a 57.6 m focal length would need. The gap is closed by *folding* the light path: Hubble is a mirror telescope, so light travels from a large primary mirror to a smaller secondary mirror and back down the tube to the instruments, covering an effective 57.6 m of optical path inside a physically much shorter housing. This decouples *effective focal length* from *physical lens length* — a real design technique (also used in compact "mirror lenses" for cameras), not just an astronomy curiosity.

---

## 8. Aperture and F-Number

Most real lenses include an adjustable **aperture** (§1) — typically a diaphragm made of overlapping blades, mechanically playing the same role as the eye's iris (Week 1 §1) — that can widen or narrow the effective diameter *D* of the lens opening, independent of the lens's fixed focal length *f*. Note that *D* is a *setup* choice (you turn an aperture ring or let the camera pick it), not an intrinsic lens property, even though it's capped by an intrinsic one — the lens's *maximum* possible aperture diameter.

The standard way to describe aperture size is the **[f-number](https://en.wikipedia.org/wiki/F-number)**, *N*, written as "f/*N*":

```
N = f / D
```

**Components:** *f* is the lens's (intrinsic, fixed) focal length; *D* is the (setup-chosen) aperture diameter; *N* is their ratio, dimensionless. Because *N* is *f* divided by *D*, a *larger* f-number (like f/16) means a *smaller* physical opening, and a *smaller* f-number (like f/1.4) means a *larger* opening — the inverse relationship is baked directly into the formula's shape, not an arbitrary convention. Aperture sizes are conventionally spaced in **stops**, where one full stop changes the amount of light reaching the sensor by a factor of 2× (the same "stop" unit already introduced for dynamic range in Week 1 §10) — so f/2.8 lets in twice as much light as f/4, which lets in twice as much as f/5.6, and so on.

**Why full stops step by √2, not by 2.** It's the aperture's *area* — proportional to *D*² (§3) — that sets how much light gets through, not *D* itself. Halving the light (one stop) means halving *D*², which means shrinking *D* itself by a factor of 1/√2; since *N* = *f*/*D* at fixed *f*, that shrinks *N* by the same 1/√2 — so each full-stop f-number is roughly **√2 times** its predecessor, not simply double it. This is exactly why the standard full-stop sequence reads f/1.4, f/2, f/2.8, f/4, f/5.6, f/8, f/11, f/16, f/22 — each number ≈ √2 × the one before it, even though the *light* halves at every step.

By §3's area-scales-as-diameter-squared logic, halving the f-number (doubling the aperture diameter *D* at fixed *f*) quadruples the light reaching the sensor — the exact same 2× diameter → 4× light relationship already derived for pinholes, now expressed through *N* instead of *D* directly.

Widening the aperture doesn't only affect brightness — it also affects how much of the scene appears sharply focused at once, which is exactly the subject of §9.

---

## 9. Depth of Field and Circle of Confusion

This is the most important technical concept of Week 2 — the direct basis for PS2's Task 1 and for HW2, and the section where the lecture's notation is easiest to mix up under exam pressure. §5 already introduced the key distinction (*S* = the currently in-focus distance, *O* = a scene point's actual distance) — this section puts exact numbers on what happens when they differ.

### 9.1 What "in focus" and "out of focus" mean, precisely

**S is the object distance the lens is currently focused at** — not a free variable, but the one specific distance the thin lens equation names for the lens's current, fixed sensor distance *S′*. Every formula from here through §9.4 (circle of confusion, depth of field, near/far distances, hyperfocal distance) treats *S* as this fixed, chosen quantity — never the varying actual distance of whatever scene point you happen to be evaluating (that's *O*).

Recap from §5: for a lens with a fixed sensor distance *S′*, the thin lens equation (§4.1) names exactly one object distance *S* whose rays converge perfectly at the sensor plane. A real scene point sitting at its own actual distance *O* is perfectly sharp only when *O = S*; at any other *O*, its rays converge either before or after the sensor plane and have re-diverged into a small blurred disc — the **circle of confusion** — by the time they reach the sensor.

### 9.2 The circle-of-confusion formula, derived

Two similar-triangle relations, exactly parallel in spirit to §4.1's derivation of the thin lens equation, but now tracking a point that is *not* at the focused distance:

**Relation 1.** The actual object point (at distance *O*) sends a full cone of rays spanning the entire aperture diameter *D* by the time they reach the lens. Slice that same cone at the closer *S*-plane (the in-focus plane) instead of at the lens, and by similar triangles (same rays, same apex at the object point, just measured at a different distance along the axis) the cone's half-width there, call it *y*, scales down proportionally:

```
y / (D/2) = |O - S| / O
```

**Relation 2.** By definition, *S* is the one object distance whose rays converge to a perfect point at the sensor (*S′*) — so the lens maps that *y*-wide slice at the *S*-plane to the sensor with exactly the magnification *m* that applies to the focused pair (*S*, *S′*) from §4.1. The half-width at the sensor is therefore *m·y*, and since the actual object is at *O* ≠ *S*, this mapped width is exactly half the circle of confusion:

```
y / (c/2) = 1/m
```

**Combining** (solve Relation 2 for *y* = *c*/(2*m*), then substitute into Relation 1 and solve for *c*):

```
c = m · D · |O - S| / O
```

**Components:** *c* is the circle-of-confusion diameter (what we're solving for); *m* is the magnification at the focused pair (*S*, *S′*), from §4.1; *D* is the aperture diameter (§8); *O* is the actual object distance; *S* is the currently-focused distance. Sanity checks: if *O = S* (object actually at the focused distance), *c* = 0 — perfectly sharp, matching §9.1. As the "focus error" |*O* − *S*| grows, *c* grows too, and it grows fastest for a large aperture diameter *D* — consistent with §2's pinhole finding that a bigger opening produces more geometric blur, now formalized for a lens.

### 9.3 Depth of field: the formula and where it comes from

A real sensor's own pixel grid already has finite resolution (Week 1 §12.2.1's "image frequency" ruler is fixed by pixel pitch), so a blur disc smaller than some small threshold — call it *ε* pixels — is simply invisible; it can't be told apart from a perfectly sharp point at that resolution. **[Depth of field (DoF)](https://en.wikipedia.org/wiki/Depth_of_field)** is the range of actual object distances *O* for which *c* stays below that threshold.

**Deriving the range from §9.2's formula.** Require *c* ≤ *ε*:

```
m·D·|O - S|/O ≤ ε
⟹ |1 - S/O| ≤ ε/(mD)
```

Call *k* = *ε*/(*mD*) (small when the acceptable blur *ε* is small compared to the aperture-and-magnification term *mD*, which is the case for any reasonably tight focus tolerance). Then *S*/*O* is squeezed between (1−*k*) and (1+*k*), which inverts to a range for *O* itself:

```
O ranges from S/(1+k)  (near edge)   to   S/(1-k)  (far edge)
```

The width of that range, for small *k* (using 1/(1−*k*) − 1/(1+*k*) = 2*k*/(1−*k*²) ≈ 2*k* when *k* ≪ 1):

```
DOF = S/(1-k) - S/(1+k) ≈ 2kS = 2εS/(mD)
```

which is exactly the compact formula the lecture states directly:

```
DOF = 2·ε·S / (m·D)
```

**A caveat on the symmetric approximation.** This compact formula comes from the small-*k* step in the derivation above, which treats the near and far edges as equally spaced around *S*. The lecture notes directly that the *true* depth of field is slightly **asymmetric** — visible already in the exact `O = S/(1±k)` expressions above, which are not symmetric around *S* even though their *difference* is well-approximated by the symmetric formula when *k* is small. In practice, a typical acceptable circle-of-confusion threshold *ε* is on the order of **4–5 pixels**.

**Units trap: the threshold is stated in pixels, but the formula needs a length.** In *c* = *m·D·|O − S|/O*, the magnification *m* and the ratio |*O* − *S*|/*O* are both dimensionless, so *c* comes out in whatever length unit *D* is in (mm, if *D* is in mm). It is a physical diameter on the sensor surface, not a pixel count. The same holds for *ε* inside *k* = *ε*/(*mD*): *k* must be dimensionless, so *ε* has to be a *length* in the same unit as *D*. A threshold given as "*ε* pixels" must first be converted:

```
pixel pitch   = sensor width / number of pixels across that width
ε (length)    = ε (pixels) × pixel pitch
```

- **Pixel pitch** is the center-to-center spacing of pixels on the sensor, a length (typically a few µm). It's fixed by the camera, not something you choose.
- Computing it from the *height* and the vertical pixel count gives the same value when pixels are square (the usual case), a useful self-check that you've read the sensor's specifications correctly.
- Illustrative numbers (not any homework's camera): a 24 mm-wide sensor with 4000 pixels across has a pitch of 24/4000 = 0.006 mm (6 µm), so a 3-pixel threshold is 3 × 0.006 = 0.018 mm on the sensor.

The other inputs need the same care. *D* = *f*/*N* (§8) comes out in the unit of *f*. *m* for the focused pair comes from §4.1 (*m* = *S′*/*S*, with *S′* from the thin lens equation), so *f*, *S* and *S′* must all be in one unit too: mixing meters and millimeters is the most common way to get a depth of field that's off by a factor of 1000.

**Notation trap, worth flagging explicitly:** the lecture's own slide writes this with the symbol *O* in place of *S* (i.e. `DOF = 2εO/(mD)`) — but as the derivation above shows, the distance that belongs in this particular formula is the *focused* distance (§9.1's *S*), since depth of field is a range *centered on the focus plane*, not a property of any one actual object's distance. Read that slide's "*O*" as meaning *S* specifically inside the DOF formula; §9.2's circle-of-confusion formula is the one where *O* genuinely means "actual object distance," a distinct, independent variable from *S*.

**Why a small f-number gives shallow depth of field.** Because *c* (§9.2) grows in proportion to aperture diameter *D*, and *D* = *f*/*N* (§8, rearranged), a *smaller* f-number (bigger aperture, more light) makes both *c* and the DOF-shrinking factor *mD* larger — so the acceptable-blur range shrinks. This is the classic depth-of-field trade-off: more light (small *N*) inherently costs a shallower zone of acceptable sharpness.

> **Worked example, from lecture (method only — not solved here).** For a Canon 5D Mark III with f = 50 mm, N = 2.8, focused at 5 m, and a 7.5 µm pixel pitch, §9.2's formula gives a curve of circle-of-confusion size (in pixels) vs. object distance. The lecture's own exercise is: "using the graph [of *c* vs. distance], what is the depth of field?" — i.e., read off the distance range where the curve stays under the allowed-blur threshold. Per this project's policy of never computing the specific numeric answers a homework/exercise asks the student to derive, that range is intentionally left uncomputed here — but the *method* is exactly §9.2's formula, evaluated across a range of *O* and compared against a fixed pixel-based threshold *ε*.

### 9.3.1 Near and far distances: the two edges of the depth-of-field range, and how to get each one

§9.3 gave the *width* of the depth-of-field range, `DOF ≈ 2εS/(mD)` — but a homework question (like HW2 Task 1) usually asks for the **near distance** and **far distance** themselves: where the acceptably-sharp zone actually starts and ends in the scene, not just how wide it is. Both come directly out of the same derivation, one step before the small-*k* approximation was taken:

```
O_near = S / (1 + k)      (near edge)
O_far  = S / (1 - k)      (far edge)
where  k = ε / (m·D)
```

**Intuition.** §9.3's derivation showed *S*/*O* is squeezed between (1−*k*) and (1+*k*) once the circle of confusion is required to stay at or below the threshold *ε*. Solving each inequality boundary for *O* on its own gives one distance per edge: the *nearer* boundary (*O* < *S*) corresponds to dividing *S* by the *larger* factor (1+*k*), and the *farther* boundary (*O* > *S*) corresponds to dividing by the *smaller* factor (1−*k*) — dividing by a smaller number gives a bigger result, which is exactly why the far-edge denominator is the one that can blow up toward infinity as *k* → 1, the case §9.4's hyperfocal distance handles. The compact `DOF = O_far − O_near` relationship from §9.3 is only the *difference* of these two; the two distances themselves are what a "near distance / far distance" question is actually asking for.

**Term-by-term breakdown:**
- *O_near*, *O_far* — the two boundary object distances (a length, same unit as *S*) marking where the acceptably-sharp zone begins and ends in the scene. These are what "near distance" and "far distance" mean in a depth-of-field question.
- *S* — the currently-focused object distance (§9.1) — fixed by wherever the lens is focused, not something these formulas solve for.
- *k* = *ε*/(*m·D*) — the same dimensionless "tolerance fraction" from §9.3's derivation: *ε* is the acceptable circle-of-confusion threshold (as a *length*, after the pixel→length conversion from §9.3's units-trap paragraph), *m* is the magnification at the focused pair (computed as shown in the callout below), and *D* = *f*/*N* is the aperture diameter (§8).
- Both formulas are exact (no small-*k* approximation), unlike the compact `DOF ≈ 2εS/(mD)` width formula, which *does* rely on *k* being small. When a question specifically asks for near/far distances (not just the width), use these two formulas directly rather than trying to back them out from the approximate width formula and *S* alone — the true near/far edges are asymmetric around *S* (§9.3's caveat), so "*S* ± DOF/2" is **not** the same as (*O_near*, *O_far*).
- Sanity check: at *k* = 0 (an infinitely small aperture or infinitely loose tolerance — no defocus possible), *O_near* = *O_far* = *S*: the entire "range" collapses to the focal plane itself, as expected.

> **Which distance is "near" and which is "far"?** *O_near* < *S* < *O_far* always (for 0 < *k* < 1): the near distance is *closer* to the camera than the focus plane, the far distance is *farther away* — matching the ordinary photography sense of "the depth of field runs from this near point to that far point, with the subject in between."

**Diagram.** This is a geometric relationship along the optical axis, so picture it directly: on the object side of the lens, mark the focused plane *S*, then the near boundary *O_near* a little closer to the lens, and the far boundary *O_far* a little farther away; an object placed at exactly *O_near* or exactly *O_far* produces a circle of confusion of exactly the threshold diameter *ε* at the sensor (any closer or farther than that, and *c* > *ε* — too blurred to count as "in focus"). See the artifact for the full drawn version, which extends §9.2's circle-of-confusion construction (Fig. 36) with these two boundary planes marked in.

**How to compute the magnification *m* this formula needs.** Both the circle-of-confusion formula (§9.2) and everything in this section use the magnification *m* at the *focused* pair (*S*, *S′*) — not at whatever actual distance *O* a given scene point sits at. A typical problem (including HW2 Task 1) gives you the focal length *f* and the focused distance *S* directly, but *not S′* — so *m* has to be computed in two steps:

1. **Get *S′* from the thin lens equation (§4.1).** Solve `1/S + 1/S' = 1/f` for the sensor distance: `S' = f·S / (S − f)`.
2. **Get *m* from *S′* and *S* (§4.1).** `m = S'/S` (equivalently `m = (S' − f)/f`, the same quantity from the other similar-triangle relation).

Skipping step 1 — plugging *f* and *S* straight into a magnification-shaped formula without first finding *S′* — is the most common way to get *m* (and therefore every downstream *k*, *O_near*, *O_far*, and DOF value) wrong. As in §9.3's units-trap paragraph, keep *f*, *S*, and *S′* all in one consistent unit throughout both steps.

### 9.4 Hyperfocal distance

The **hyperfocal distance**, *H*, is the specific focus distance *S* that pushes the *far* edge of the depth-of-field range (§9.3) all the way out to infinity. Deriving it directly from §9.2's circle-of-confusion formula: as the actual object distance *O* → ∞, the ratio |*O* − *S*|/*O* → 1 (the finite *S* becomes negligible next to an infinite *O*), so the circle of confusion an object at infinity would show, if focused at *S* = *H*, is simply *c*<sub>∞</sub> = *m·D* (using the magnification evaluated at that focus distance). Setting this equal to the fixed acceptable threshold and solving for *S* = *H* (using *D* = *f*/*N* from §8, and dropping *f* itself as negligible next to the much larger *H*) gives:

```
H = f² / (N·c)
```

where *c* here is the fixed acceptable-circle-of-confusion threshold (the same role §9.3 calls *ε* — the lecture reuses the letter *c* for this constant *and* for §9.2's general, object-distance-dependent circle-of-confusion size; in this one formula, it means the fixed threshold only).

**The connection to §9.3.1's near and far distances.** *H* is defined above as exactly the focus distance *S* at which the far edge of the depth-of-field range, *O_far* = *S*/(1−*k*) (§9.3.1), diverges to infinity — which happens precisely when *k* = 1 (the denominator hits zero). That isn't a separate fact to check — it *is* what the derivation above already says: setting the object-at-infinity circle of confusion *c*<sub>∞</sub> = *m·D* equal to the acceptable threshold *ε* is exactly the statement *k* = *ε*/(*mD*) = 1, evaluated at *S* = *H*.

Since *k* = 1 at *S* = *H*, plug that directly into §9.3.1's *exact* near-distance formula:

```
O_near(H) = H / (1 + k) = H / (1 + 1) = H/2
```

This is where the familiar "focus at the hyperfocal distance and everything from *H*/2 to infinity is acceptably sharp" rule comes from — it isn't a separate empirical fact, it falls straight out of §9.3.1's *O_near* formula evaluated at the one specific focus distance where *k* happens to equal 1. (The "*H*/2" result inherits the same one approximation already used to get the closed-form *H* = *f*²/(*N·c*) above — dropping *f* as negligible next to the much larger *H* — so it's exact *given* that approximate *H*, not a second independent approximation stacked on top.)

Focusing at the hyperfocal distance means everything from exactly *H*/2, as just derived, out to infinity satisfies the depth-of-field threshold simultaneously — a classic landscape-photography technique for maximizing usable in-focus range without stopping the aperture down so far that diffraction (§2, §10) starts to matter.

---

## 10. The Diffraction Limit, Formalized

§2 introduced diffraction qualitatively: shrinking an opening spreads its Fourier-transform-shaped diffraction pattern wider. Ernst Abbe (1873) made this precise for a lens system, giving the smallest resolvable spot radius *d* an optical system can produce, purely as a consequence of diffraction (i.e., the best possible result even with zero aberrations, §6):

```
d = λ / (2n·sinθ) = λ / (2·NA) ≈ λN
```

Here *λ* is the wavelength of light being imaged (light frequency, in Week 1 §12.0's disambiguation — nothing to do with spatial or temporal frequency), and **numerical aperture**, *NA = n·sinθ*, packages together the refractive index *n* of the medium and the half-angle *θ* of the widest cone of light the lens can accept or emit — a bigger NA means the lens gathers a wider cone of rays, which (by the same Fourier-transform logic as §2, run in reverse) corresponds to a *narrower*, more tightly focused diffraction spot. The right-hand approximation, *d ≈ λN*, substitutes the standard small-angle relationship *NA ≈ 1/(2N)* between numerical aperture and the everyday photographic f-number *N* (§8) — showing that f-number alone, not just raw aperture diameter, sets the diffraction-limited resolution floor.

**The resolution/depth-of-field trade-off.** §9.3 showed that a *small* f-number (wide aperture) buys more light at the cost of shallow depth of field. §10's formula shows the opposite pressure: a *large* f-number (narrow aperture, more depth of field) makes the diffraction-limited spot size *d* bigger — i.e., a fundamentally blurrier best-case image, no matter how well-corrected the lens's aberrations (§6) are. High-end microscope objectives, for comparison, push NA up to 1.4–1.6 (giving *d* = λ/2.8, an extremely tight spot) specifically by sacrificing depth of field almost entirely. This unavoidable trade — better 2D resolution always costs some 3D (depth) information, and vice versa — is an instance of a **space-bandwidth product** (or "uncertainty principle") constraint: no optical system can have arbitrarily good resolution *and* arbitrarily good depth of field at once, only a trade between them, governed jointly by f-number.

---

## 11. Sensors: What's a Pixel?

A camera sensor's fundamental building block is the **photodiode**: a semiconductor structure that converts an incoming photon into an electron via the **[photoelectric effect](https://en.wikipedia.org/wiki/Photoelectric_effect)** — a photon striking the material knocks loose an electron, and counting those freed electrons (as an accumulated charge) over the exposure time is what "measuring light" means at the hardware level.

A real pixel is more than a bare photodiode:
- A **microlens** sits on top of each pixel, focusing light that would otherwise land on the pixel's non-light-sensitive circuitry back down onto the active photodiode area.
- A **color filter** (Week 1 §4's Bayer/RGGB mosaic) sits beneath the microlens, restricting each pixel to measuring only one color channel.
- **[Quantum efficiency](https://en.wikipedia.org/wiki/Quantum_efficiency)** is the fraction of incoming photons that actually get converted into a counted electron (roughly ~50% for a typical sensor) — not every photon that arrives produces a usable signal.
- **Fill factor** is the fraction of the pixel's total physical area that is actually light-sensitive (vs. taken up by wiring and per-pixel circuitry); the microlens exists specifically to compensate for a fill factor below 100% by funneling light from the "dead" area back onto the live area.

**Linear-algebra view (the Bayer mosaic as an underdetermined system):** as in Week 1 §4, stack the true color image as a vector with 3 unknowns (R, G, B) per pixel, and the raw readout as a vector with 1 number per pixel. The color filter array is a **selection matrix**: one row per pixel, containing a single 1 in the column of the channel that pixel's filter passes. For a 4×4 patch this is a 16×48 matrix of **rank** 16 (16 measurements of 48 unknowns: 4 red, 8 green, 4 blue), so its **null space** has dimension 32. The system is **underdetermined**: infinitely many full-color images produce the same raw data, and demosaicking (Week 3) must add assumptions such as "neighboring pixels have similar colors" to pick one.

---

## 12. CCD vs. CMOS

There are two dominant sensor architectures, differing in *how* accumulated pixel charges get converted to a readable signal and read out:

| | **[CCD](https://en.wikipedia.org/wiki/Charge-coupled_device)** (charge-coupled device) | **[CMOS](https://en.wikipedia.org/wiki/CMOS_sensor)** (complementary metal-oxide-semiconductor) |
|---|---|---|
| Charge-to-voltage conversion | A small number of shared amplifiers, with each row's charge physically shifted ("bucket-brigaded") row-by-row to reach them | Every pixel has its **own** tiny amplifier built in |
| Readout | Charges shifted out row-by-row, then converted centrally | Per-pixel voltages read out row-by-row via a multiplexer, no charge-shifting needed |
| Typical trade-off | Higher sensitivity, lower noise (fewer, more carefully-matched amplifiers) | Faster readout, lower manufacturing cost (parallel per-pixel amplification, standard chip-fabrication processes) |

Both approaches ultimately deliver a per-pixel voltage proportional to accumulated charge; they differ in the electrical path and cost/performance trade-offs for getting there, not in the underlying photoelectric sensing principle of §11.

**Linear-algebra view (a linear sensor):** "voltage proportional to accumulated charge," with charge itself proportional to photons collected (scaled by quantum efficiency), means the raw reading is a **linear function** of light: double the photons, double the value, and the reading for two light sources together is the sum of their separate readings. This holds until a pixel saturates (can hold no more charge) and up to the ADC's rounding (§14). It is what lets the whole optics-plus-sensor chain be written as one matrix, **y** = **A x** (§0, §2, §11), and it is why the first deliberately nonlinear step, gamma correction, only happens later in Week 3's pipeline.

---

## 13. Exposure, Exposure Time, and ISO

"Long exposure" and "short exposure" come up constantly in photography and in computational imaging, because exposure time is the one camera setting that trades *time* for *light*, and time is where motion, noise, and saturation all enter. This section builds the idea from scratch, then shows why it matters beyond photography (HDR, motion deblurring, burst photography, and LiDAR/time-of-flight sensing).

### 13.1 What "exposure" means: three different uses of one word

**Analogy first.** Picture a bucket left out in the rain. How much water ends up in it depends on two things: how hard it's raining (the *rate*) and how long you leave the bucket out (the *time*). A sensor pixel is that bucket, photons are the raindrops, and the photo-generated electrons of §11 are the water collected.

**The shutter.** A **[shutter](https://en.wikipedia.org/wiki/Shutter_(photography))** is whatever decides *when* collection starts and stops. It is either a physical curtain that uncovers and re-covers the sensor, or (in many digital sensors) an **electronic shutter** that simply clears each pixel's charge at the start and reads it out at the end. The same bucket model applies either way: the charge collected is "rate × open time."

The word "exposure" is used in three distinct senses, and mixing them up is the main source of confusion:

| Term | What it means | Units | Who controls it |
|---|---|---|---|
| **Exposure time** (a.k.a. **shutter speed**) | How *long* the shutter lets each pixel collect light | seconds (written as 1/250, 1/60, 1, 15…) | You (a setting) |
| **Exposure** (strict sense, *H*) | The *total* light delivered per unit sensor area during that time — the amount of water per square centimeter of bucket opening | lux·seconds | Set jointly by exposure time, aperture (§8), and scene brightness — **not** ISO |
| **"An exposure"** (countable noun) | One captured frame (e.g. "take three exposures and merge them") | — | — |

In this section, "exposure" alone always means the strict total-light sense, *H*; the duration is always called "exposure time." ("Shutter speed" is the photographer's name for exposure time: a "fast shutter speed" is a *short* exposure time. The lecture's slide title "Exposure (shutter speed)" uses "exposure" in this time sense.)

**"Bulb" mode** is an exposure time with no preset value: the shutter stays open as long as the shutter button is held. HW1's pinhole-box photos with 15–60 s exposure times are long exposures of this kind (shot in bulb mode or with a long timed setting), needed because a pinhole (§3) lets through very little light per second.

### 13.2 The exposure formula

```
H = E · t          and, for a lens,          E ≈ (π/4) · L / N²
so:                H ∝ L · t / N²
```

**Intuition.** The first equation is just the bucket: total = rate × time. The rate of light arriving per unit sensor area is the **[irradiance](https://en.wikipedia.org/wiki/Irradiance)** *E* (photometric name: **illuminance**). If *E* holds steady while the shutter is open, the total *H* is *E* multiplied by *t*. If *E* changes during the exposure (a flickering lamp, a car's headlights sweeping past), *H* becomes the **area under the E-versus-time curve** over the open interval. "Rate × time" is the special case where that curve is flat.

The second equation says where *E* comes from. A scene patch of fixed brightness *L* sends light toward the lens. The amount collected grows with the aperture's *area* ∝ *D*² (§3, §8). The patch's image is spread over an area that grows with *f*², the focal length squared, by the same inverse-square logic as §3. The ratio is *D*²/*f*² = 1/*N*². So the f-number *N* alone captures everything the lens contributes, which is exactly why photographers use it instead of *D* or *f* separately.

**Term by term:**

- ***H*** — **exposure**: total light energy delivered per unit area of sensor during one capture (lux·s photometrically, J/m² radiometrically). You don't set it directly; it results from the other terms.
- ***E*** — **image-plane irradiance**: light *power* per unit sensor area at that moment (lux, or W/m²). Fixed by the scene plus the aperture.
- ***t*** — **exposure time**, in seconds. **You control this.**
- ***L*** — scene **[luminance](https://en.wikipedia.org/wiki/Luminance)**: how bright the scene patch itself is (candela per m²). Fixed by the scene and its lighting; you don't control it (unless you add light, e.g. a flash, or in LiDAR a laser, §13.8).
- ***N*** — the **f-number** of §8 (dimensionless). **You control this.** It appears squared because light gathered scales with aperture *area*.
- ***π/4*** — a geometric constant from integrating over a circular aperture. It never changes, which is why the proportional form (∝) is all a photographer needs. The ≈ hides small real-lens losses: glass transmission below 100%, and dimming toward the image corners (**vignetting**).

**Link to §16.3's SNR formula.** There, *P* (photons per pixel per second) is just *E* expressed in photons and multiplied by one pixel's area. The mean signal *P·Qe·t* is therefore "exposure in photons × quantum efficiency": the same *E·t* product, counted in electrons.

**Reciprocity.** *H* depends only on the product *t*/*N*², so halving *t* and letting in twice the light per second (one stop wider aperture) leaves *H* unchanged. Different (*t*, *N*) pairs that give the same *H* are called **equivalent exposures**. This interchangeability is the **reciprocity law** (*H* depends only on the product of rate and time, not on either separately). For a digital sensor it holds essentially exactly, since electrons just accumulate linearly, until the pixel fills up (§13.4).

### 13.3 Stops of time, and the equivalent-exposure ladder

Exposure time is spaced in the same **stops** as aperture (§8): one stop = a factor of 2 in light. The standard sequence 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1 s doubles at every step. Unlike the aperture sequence, there is no √2: exposure time enters *H* directly, not squared.

The lecture's "Depth of Field & Motion Blur" slide prints exactly such a ladder of equivalent exposures. Plugging each pair into *t*/*N*² (relative to the first pair), and into the **exposure value** EV = log₂(*N*²/*t*) (a single number that labels a whole family of equivalent exposures; one EV step = one stop), gives:

| Aperture | Exposure time | *t*/*N*² relative to f/16, 1/8 s | EV |
|---|---|---|---|
| f/16 | 1/8 s | 1.000 | 11.00 |
| f/11 | 1/15 s | 1.128 | 10.83 |
| f/8 | 1/30 s | 1.067 | 10.91 |
| f/5.6 | 1/60 s | 1.088 | 10.88 |
| f/4 | 1/125 s | 1.024 | 10.97 |
| f/2.8 | 1/250 s | 1.045 | 10.94 |
| f/2 | 1/500 s | 1.024 | 10.97 |

Every row delivers (within ~13%, or under 0.2 stop) the *same* exposure. The small wobble comes only from the marked numbers being rounded: "f/11" is really 16/√2 ≈ 11.3, and "1/15" is really 1/16. Yet the three photos on that slide look completely different:

- **f/16, 1/8 s:** the aperture is small (deep **depth of field**, §9) and the exposure time is long. The flying pigeons smear into ghostly streaks: **motion blur**.
- **f/2, 1/500 s:** the aperture is wide (shallow depth of field) and the exposure time is 62.5× shorter. The pigeons are frozen mid-wingbeat.

Exposure fixes only the *brightness*. The *path* you take along the ladder decides what kind of image you get.

**Linear-algebra view (equivalent exposures as a null space).** Take logarithms and the multiplicative formula becomes linear: log₂*H* = log₂*L* + log₂*t* − 2·log₂*N* (+ a constant). Collect your two settings into the vector **s** = (log₂*t*, log₂*N*). The change in log-exposure caused by a change Δ**s** is the row vector **r** = [1, −2] applied to Δ**s**: Δlog₂*H* = **r**·Δ**s**. The set of setting changes that leave exposure *unchanged* is the **null space** of **r**: every multiple of (2, 1). "Open up by one stop of aperture (log₂*N* down by ½), shorten time by one stop (log₂*t* down by 1)" is (−1, −½), which lies on that line. The ladder above is literally a walk along the null space of a 1×2 matrix. Moving *off* that line changes brightness; moving *along* it only trades depth of field against motion blur.

### 13.4 Getting it wrong: underexposure, overexposure, saturation

Each pixel's "bucket" has a finite size: the **full-well capacity**, the maximum number of electrons a photodiode can hold before extra photons have nowhere to go.

- **Overexposure.** Too much *H*: bright regions overflow the well and every pixel there reads the same maximum value. This is **saturation**, or **[clipping](https://en.wikipedia.org/wiki/Clipping_(photography))**. Different brightnesses (a white shirt, the sun behind it) all become one flat "max white," and the detail is gone for good: no processing can recover it, since the sensor never recorded the difference.
- **Underexposure.** Too little *H*: dark regions collect only a handful of electrons, so the fixed noise floor of §16 (read noise *Nr*, dark current *D·t*) is comparable to or larger than the signal. Detail is technically there but buried in noise. Brightening the image afterward (digitally or via ISO, §13.6) amplifies the noise right along with it.
- **"Correct" exposure** places the scene's important brightness range inside the window between those two failure modes. That window is exactly the sensor's **dynamic range** (§14). When the scene's own range is wider than the sensor's (a sunlit window inside a dark room), *no* single exposure time works: one choice clips the window, the other buries the room in noise. That is the motivation for **HDR imaging** (Week 4).

### 13.5 Long vs. short exposure: the core trade-off

Holding everything else fixed, lengthening the exposure time collects more light. That helps and hurts in specific, predictable ways:

| | Short exposure (e.g. 1/500 s) | Long exposure (e.g. 1/8 s, 2 s, bulb) |
|---|---|---|
| Light collected | Less | More (∝ *t*) |
| Noise (§16) | Worse SNR; shot-noise-limited SNR ∝ √*t* | Better SNR |
| Moving subjects | Frozen | Smeared into streaks / trails (**motion blur**) |
| Camera shake (hand-held) | Negligible | Whole frame blurs unless on a tripod |
| Bright regions | Less risk of clipping | More risk of saturation |
| Dark current *D·t* (§16.3) | Negligible | Grows with *t* (matters for very long exposures) |
| Price you pay elsewhere to keep the same brightness | Wider aperture (shallower depth of field, §9) or higher ISO (amplified noise, §13.6) | Smaller aperture possible (deeper depth of field) |
| Typical uses | Sports, wildlife, anything fast; bright daylight | Night scenes, astronomy, light trails, "silky" water, HW1's pinhole box |

**Worked example 1 — the lecture's night-highway photos (slide "Exposure (shutter speed)").** Two photos of the same highway at night:

- **Photo A:** 1/4 s at f/3.3, ISO 200. Moving cars show as short, partly-recognizable blurs.
- **Photo B:** 2 s at f/6.3, ISO 80. The cars have vanished completely, replaced by long continuous red and white **light trails**.

Why do they have similar overall brightness?

1. **Time:** Photo B's exposure time is 2 / 0.25 = **8×** longer (3 stops more light).
2. **Aperture:** its f-number is larger, so relative light per second is (3.3/6.3)² ≈ 0.27× (≈1.9 stops less).
3. **Net exposure:** *t*/*N*² gives 2.0/6.3² ÷ 0.25/3.3² ≈ **2.2×** more light collected in Photo B (+1.13 stops).
4. **ISO:** Photo B uses ISO 80 instead of 200, a 0.4× gain (−1.32 stops). The final rendered brightness ends up at 2.2 × 0.4 ≈ **0.88×** Photo A's, a difference of only ~0.19 stop.

So the two photos look about equally bright, but Photo B spent its "brightness budget" on a much longer exposure time. Every headlight moved a long way *during* the exposure and painted its whole path onto the sensor. The trails are motion blur, used deliberately.

**Worked example 2 — how long is a motion-blur streak?** A moving point spends the exposure sliding across the sensor, leaving a streak:

```
blur length (pixels) = image-plane speed (pixels/second) × exposure time (seconds)
```

- *Image-plane speed* is how fast the subject's image moves across the sensor (set by the subject's real speed, its distance, and the focal length). It is fixed by the scene and lens, not by you.
- *Exposure time* is yours to choose.

Illustrative numbers: a subject that crosses a 4000-pixel-wide frame in 2 s moves at 4000/2 = 2000 px/s. Then:

| Exposure time | Streak length |
|---|---|
| 1/500 s | 4 px (looks sharp) |
| 1/125 s | 16 px (visibly soft) |
| 1/8 s | 250 px (a smear, like the slide's pigeons) |
| 2 s | 4000 px (the full frame width: a trail, like Photo B) |

The streak grows *linearly* with exposure time. This is why "freezing motion" is purely a matter of making *t* small enough that the streak is shorter than about one pixel.

**Linear-algebra view (motion blur is a linear filter).** Each recorded pixel is the *time average* of all the scene points that slid past it during the exposure. For uniform motion along one direction, that is the same weighted-sum operation as Week 1's filters: a **convolution** of the sharp image with a **box kernel** (a flat line segment) whose length is the streak length. Stack the image into a vector **x** and blur is one matrix–vector product **y** = **B x**. Here **B** is a banded (Toeplitz) matrix with the box kernel repeated along its diagonals.

Undoing the blur means inverting **B**. That is badly conditioned: a box kernel's Fourier transform (a sinc shape) passes through *exact zeros* at certain image frequencies. Detail at those frequencies is multiplied by zero, lands in **B**'s null space, and is lost. This is precisely the problem **coded exposure** ("flutter shutter," Week 4) attacks: flicking the shutter open and closed in a pseudo-random pattern *during* one exposure turns the box into a code whose Fourier transform has no zeros, so the blur becomes invertible. Deblurring by inverting **B** is the deconvolution topic of Week 5.

**Worked example 3 — why long exposures are cleaner (numbers from §16.3's formula).** In the shot-noise-limited case (bright enough that *Nr* and *D* are negligible), SNR = √(*P·Qe·t*) ∝ √*t*:

- doubling the exposure time improves SNR by √2 ≈ 1.41×
- 4× the time gives 2×
- 16× the time gives 4×

Diminishing returns, but steady: to halve the relative noise you need 4× the light.

**Worked example 4 — one long exposure vs. many short ones ("burst photography").** Instead of one long exposure, you could take *k* short ones and add them up afterward: each frame is short enough to avoid blur, and you can re-align frames before summing. Is it as clean? Compare using §16.3's formula with illustrative numbers for a very dim scene: 25 electrons per pixel per short frame, read noise *Nr* = 3 electrons, *k* = 16 frames.

| Capture | Signal | Noise variance | SNR |
|---|---|---|---|
| One short frame | 25 | 25 + 3² | **4.29** |
| One long exposure (16× the time) | 400 | 400 + 3² | **19.78** |
| 16 short frames, summed | 400 | 400 + 16·3² | **17.15** |

Same total light, but the burst pays read noise 16 times (once per readout) instead of once. Because the variances add (the orthogonality argument of §16.3), its SNR comes out lower. For bright scenes, where shot noise dominates, the difference nearly vanishes. That is why phones can afford to replace one long, blur-prone exposure with a burst of short, well-aligned ones.

### 13.6 ISO: brightness from gain, not from light

**[ISO](https://en.wikipedia.org/wiki/Film_speed)** ("film speed," a name carried over from chemical film) is (in the usual camera design) an **analog gain** applied to the sensor's signal *before* it reaches the analog-to-digital converter (ADC, §14). Raising ISO does not make the sensor collect more photons — it electrically amplifies whatever charge was collected, boosting a dim signal up into a usable digital range. Critically, this amplification boosts the noise already present (shot noise, and read noise added before the amplifier) right along with the signal, so it cannot raise the signal-to-noise ratio set by the photons collected (§16); at most, amplifying before the ADC keeps the noise added *after* the amplifier from mattering as much — so raising ISO is a way of trading *cleanliness* for *brightness* on a fixed amount of collected light, not a way of gathering more light in the first place.

In the strict sense of §13.1, then, ISO does **not** change the exposure *H*; it changes how bright the *recorded image* comes out for a given *H*. Photographers often speak loosely of an "**exposure triangle**" of aperture, exposure time, and ISO. The table below makes precise what each corner actually does:

| Knob | Changes the light collected (*H*)? | Side effect you pay |
|---|---|---|
| Aperture (f-number, §8) | Yes, ∝ 1/*N*² | Depth of field (§9); diffraction at small apertures (§10) |
| Exposure time | Yes, ∝ *t* | Motion blur, camera shake, saturation risk (§13.5) |
| ISO (gain) | **No**; scales the output only | Amplified noise; highlights clip sooner at high gain |

### 13.7 Where exposure resurfaces later in the course

- **HDR imaging (Week 4).** Merge several exposures of one scene taken at different exposure times ("**exposure bracketing**"): short ones capture the highlights without clipping, long ones capture the shadows above the noise floor (§13.4). Because *H* = *E·t*, once a pixel value has been converted back to (relative) exposure *H*, dividing by its known *t* puts every frame on a common irradiance scale. Recorded pixel values are usually a *nonlinear* function of *H* (the camera's response curve), so the Debevec & Malik reading first recovers that curve from the bracketed frames, then undoes it and divides by *t* (in log form: ln *E* = *g*(pixel value) − ln *t*), averaging over the unclipped frames.
- **Coded exposure / flutter shutter (Week 4).** Reshape the *timing* of one exposure so the resulting motion blur can be inverted (§13.5, linear-algebra view).
- **Rolling shutter (§15).** Each sensor row gets its own exposure-time window, offset from its neighbors'.
- **Dark-frame subtraction and autoexposure (Week 3's ISP pipeline).** A dark frame is an exposure taken with the shutter closed at the same *t*, capturing the dark-current *D·t* signal (plus the sensor's fixed offset) with no scene light, so it can be subtracted. Autoexposure is the camera picking *t*, *N*, and ISO for you from a quick brightness measurement (**metering**).
- **Deconvolution (Week 5).** Formal treatment of inverting blur operators like **B**.

### 13.8 Exposure in LiDAR and time-of-flight depth sensing

**[LiDAR](https://en.wikipedia.org/wiki/Lidar)** ("light detection and ranging") and **[time-of-flight (ToF) cameras](https://en.wikipedia.org/wiki/Time-of-flight_camera)** measure *distance* instead of (or alongside) brightness. They send out their own light, typically an infrared laser, and time how long it takes to bounce back. The course's time-of-flight lecture treats them properly. Here the point is that "exposure" is just as central to them, with one big twist.

**Passive vs. active sensing.** An ordinary camera is **passive**: it only collects light already in the scene (sunlight, lamps). A LiDAR is **active**: it supplies its own **active illumination**. The photons it wants are its own laser's echo, and every other photon is unwanted background.

**Analogy.** A passive camera is the rain bucket of §13.1. A LiDAR is trying to catch one specific squirt from its own garden hose *while it's also raining*. Every extra moment the bucket stays open adds more rain (ambient light) without adding any more of the squirt. The rain doesn't just dilute the measurement: its randomness (shot noise, §16.2, ∝ √(ambient photons)) buries the squirt.

**The time–distance link.** Light travels at *c* ≈ 3 × 10⁸ m/s, i.e. **0.30 m per nanosecond** (ns, 10⁻⁹ s). A pulse sent to an object at distance *d* and back travels 2*d*, so

```
round-trip time  τ = 2d / c          ⇔          d = c·τ / 2
```

- ***d*** — distance to the object, in meters. The unknown being measured; fixed by the scene.
- ***τ*** — round-trip time, in seconds. What the sensor actually times.
- ***c*** — speed of light, a physical constant.
- The **factor 2** is there because the light goes out *and* back. Forgetting it doubles every distance.

Each nanosecond of round-trip time corresponds to 0.30/2 ≈ **0.15 m** of distance. An object 100 m away echoes back after 2 × 100 / (3 × 10⁸) ≈ 667 ns. Everything happens on a nanosecond scale, a *million* times shorter than photographic exposure times.

**Range gating: an ultra-short exposure.** A **pulsed (direct) time-of-flight** LiDAR fires a short laser pulse; with **range gating**, it then only "opens the bucket" in a narrow time window, or **gate**, when an echo from the distances of interest could be arriving. Opening the detector for a time window *is* an exposure. It's just nanoseconds long and timed relative to the laser pulse. Worked numbers:

- A gate covering a 1 m slice of depth lasts 2 × 1 m / *c* ≈ **6.67 ns**.
- An ordinary short photographic exposure of 1/100 s is 10 ms.
- Ambient light arrives continuously, so the gate collects about 6.67 ns / 10 ms ≈ **1/1.5 million** as many background photons as that photo exposure would.
- The laser echo from inside the slice arrives *entirely within* the gate, so none of the signal is lost.

That is the same exposure trade-off as §13.5, pushed to the extreme: shortening the exposure costs nothing if your signal is guaranteed to land inside it. Choose it short enough and you reject almost all background, a key reason pulsed LiDAR can work outdoors in sunlight.

**Accumulating many pulses: exposure as pulse count.** One laser pulse returns only a few photons from a distant or dark object. Many single-photon LiDARs (using **[single-photon avalanche diodes](https://en.wikipedia.org/wiki/Single-photon_avalanche_diode)**, SPADs, detectors sensitive enough to register individual photons) therefore repeat the measurement over many pulses. They build a **histogram** of photon arrival times, whose peak marks *τ*. The "exposure" is now the total acquisition time, or number of pulses.

The same √*t* rule of worked example 3 applies: 4× as many pulses halves the relative noise of the histogram. The same motion trade-off applies too: anything that moves during acquisition smears its histogram peak, the depth equivalent of motion blur.

**Continuous-wave (indirect) ToF cameras: an "integration time" knob.** Many depth cameras (e.g. in phones and game controllers) don't time individual pulses. They illuminate the scene with light whose brightness is modulated as a wave, and infer distance from the **phase shift** of the returning wave. Each pixel integrates the returning light over an **integration time**, which is these cameras' name for exposure time. It shows exactly the §13.5 trade-offs, now in depth rather than brightness:

- **Too short:** too few collected photons, so noisy depth values.
- **Too long:** moving objects produce depth errors at their edges (the depth analogue of motion blur).
- **Saturation (§13.4):** near or highly reflective objects saturate pixels and ruin their depth estimate. This is why such cameras often combine readings from two or more integration times: the depth-sensing counterpart of HDR bracketing.

**Takeaway.** Whether the output is brightness or distance, "exposure" is the same decision: how long to collect before reading out. More time buys lower relative noise (∝ √*t*). It costs motion blur, saturation risk, and, when your own light source is the signal, extra ambient background.

---

## 14. Dynamic Range and Bit Depth

**[Dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)** was introduced in Week 1 §10 for the human eye (~14 orders of magnitude adapted, ~5 instantaneous). For a digital sensor, the same *ratio-between-brightest-and-darkest-representable-signal* definition applies, but a sensor adds a second, purely digital constraint on top of the physical one: **bit depth** — how many discrete numeric levels the ADC can output. A typical camera's unprocessed **RAW** format uses 12–14 bits per pixel (4,096–16,384 distinct levels), while a processed, display-ready **JPEG** typically compresses this down to 8 bits per channel (256 levels) after the tone-mapping and gamma-correction steps previewed in §17 — so a sensor's *achievable* dynamic range is capped by whichever is smaller: the physical noise floor (§16) or the digital quantization step size set by bit depth.

---

## 15. Global Shutter vs. Rolling Shutter

There are two ways to time when each pixel's exposure happens relative to readout:

- **Global shutter**: every pixel on the sensor is exposed over the *exact same* time window, then all are read out together. This avoids motion artifacts within a single frame, at the cost of extra per-pixel circuitry (to hold each pixel's charge steady while waiting its turn to be read out).
- **[Rolling shutter](https://en.wikipedia.org/wiki/Rolling_shutter)**: rows are exposed and read out sequentially, one after another, rather than all at once — cheaper and allows shorter per-row exposure times, but different rows of the same "frame" are actually capturing the scene at *slightly different moments in time*, which can produce visible skew or banding artifacts for anything changing quickly during the row-by-row scan.

**Concrete example: 60 Hz AC flicker.** Ordinary AC-powered lighting in much of the world runs at 60 Hz, but the light output itself flickers at **120 Hz** — twice per electrical cycle, since the lamp dims (though doesn't fully switch off) each time the AC voltage crosses zero, which happens twice per cycle. A rolling-shutter camera scans through its rows over some short time window; since different rows land at different phases of that 120 Hz brightness flicker, the captured frame shows visible dark/light horizontal bands, even though nothing in the actual scene was banded. A global-shutter camera, exposing every row simultaneously, would instead show the whole frame uniformly brighter or dimmer depending on when within the flicker cycle the single shared exposure happened to land — no banding, because there's no row-to-row time offset to reveal the flicker's phase.

Rather than treating this purely as a nuisance, Sheinin et al. (2017) demonstrated that a rolling shutter's row-by-row timing can itself be exploited as a sensing tool: because each row effectively samples the scene at a slightly different, precisely known instant, a single rolling-shutter frame can be unpacked into a short sequence of instants (the lecture's example: 26 sub-frames recovered from just 10 ms of a single capture) — turning what looks like a shutter *artifact* into extra temporal information, a recurring theme in computational imaging of finding information hidden in an otherwise "broken" capture.

---

## 16. Sensor Noise and Signal-to-Noise Ratio

### 16.1 From photons to a RAW image

The full chain from incoming light to a stored RAW image: **photons** arrive at the sensor → the **photodiode** (§11) converts them to electrons, with photon-counting randomness (**shot noise**, below) already baked in at this step → an **amplifier** applies ISO gain (§13), adding further noise → an **ADC** quantizes the amplified analog voltage into discrete digital levels (§14), adding **quantization noise** (the unavoidable rounding error from representing a continuous voltage with a finite number of discrete levels) → the result is the **RAW image**, which also carries **fixed pattern noise** — per-pixel manufacturing-defect variation that is consistent from shot to shot (unlike the random noise sources above), caused by slight fabrication differences between individual pixels.

### 16.2 The two dominant noise distributions

Sensor noise comes from many physical sources (heat, electronics, amplifier gain, the photon-to-electron conversion itself, individual pixel defects, read-out electronics), but two statistical distributions dominate:

**[Gaussian noise](https://en.wikipedia.org/wiki/Gaussian_noise)** — from thermal effects, read-out electronics, and amplifier gain. It is **additive** and **signal-independent**: it adds a random value from the same bell-curve distribution to every pixel, regardless of how bright that pixel's true signal is. A dark pixel and a bright pixel get equally-sized random perturbations on average.

**[Photon (shot) noise](https://en.wikipedia.org/wiki/Shot_noise)** — from the fundamentally random arrival timing of individual photons. Photon arrivals follow a **[Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution)**, `f(k; λ) = λᵏe⁻λ/k!`, which describes the probability of observing exactly *k* discrete, randomly-timed events (here, photon arrivals) given an average rate λ. A defining property of the Poisson distribution is that its **standard deviation equals the square root of its mean**: for an average of *N* photons collected, the standard deviation of the actual count is `√N`. Shot noise is therefore **signal-dependent** — a brighter pixel (larger *N*) has *more* absolute noise (`√N` grows with *N*), but proportionally *less* relative noise, since the ratio `√N / N = 1/√N` shrinks as *N* grows. This is why doubling the light collected (*N* → 2*N*) doesn't double the noise — it only multiplies it by `√2`, meaningfully improving the *ratio* of signal to noise even though both the signal and its absolute noise both increased.

### 16.3 Signal-to-noise ratio (SNR)

**[Signal-to-noise ratio](https://en.wikipedia.org/wiki/Signal-to-noise_ratio)**, SNR, is the mean pixel value divided by the standard deviation of that pixel value (a general statistics definition, here applied to sensor measurements):

```
SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²)
```

where *P* is the incident photon flux (photons per pixel per second), *Qe* is quantum efficiency (§11), *t* is exposure time (§13), *D* is dark current (unwanted electrons generated per pixel per second even with no incident light — one source of §16.2's Gaussian noise family), and *Nr* is read noise (root-mean-square electrons of noise added purely by the sensor's own readout electronics, including fixed pattern noise). The numerator, *P·Qe·t*, is exactly the mean number of photo-generated electrons collected — the *signal* — while inside the square root, that same term reappears as the *shot-noise variance* (§16.2's `√N` fact, squared back into a variance) alongside the two Gaussian-family noise-variance terms *D·t* and *Nr²*.

**Linear-algebra view (noise as an additive vector, and why variances add):** the full measurement model is **y** = **A x** + **n**: the ideal linear measurement (§12) plus a noise vector **n** with one random entry per pixel. Independent noise sources are **uncorrelated**, and uncorrelated random variables behave like **orthogonal** vectors: the cross terms in Var(n₁ + n₂) vanish, so variances add the way squared lengths add in Pythagoras's theorem. That is exactly why the SNR denominator is the square root of a *sum* of variances (shot + dark + read), not a sum of standard deviations. Because each pixel's noise is independent of its neighbors', the noise **covariance matrix** is **diagonal**; for shot noise the diagonal entries equal the mean signal itself (Poisson), which is what "signal-dependent" means in matrix terms. Denoising (Week 3) and inverting **y** = **A x** + **n** (Weeks 5–6) both start from this model.

**Scientific sensors** (e.g., cooled to around −100°C for astronomical or microscopy work) minimize *D* and *Nr* by aggressive cooling and specialized low-noise electronics, driving nearly all remaining noise down to the fundamental, physically unavoidable shot-noise floor set by *P·Qe·t* itself — the one noise term in the formula above that no amount of engineering can remove, since it comes from the quantum randomness of photon arrival itself, not from any imperfection in the sensor.

---

## 17. Looking Ahead: The Image Processing Pipeline

This lecture's own closing slide names what comes next: **RAW images → demosaicking → denoising → deblurring → white balancing → gamma correction → compression** — the **image signal processing (ISP)** pipeline that turns the raw, single-channel-per-pixel, noisy sensor output described in §11–16 into the finished color photo a viewer actually sees. PS2's remaining tasks (linear, chrominance-smoothed, and Malvar–He–Cutler high-quality demosaicing; gamma correction; Gaussian, median, bilateral, and non-local-means denoising) live here, and are covered in Week 3's notes rather than this week's — Week 2 has been entirely about the optics (§1–10) and raw sensing (§11–16) stages that come *before* any of that pipeline runs.

Week 3 covers considerably more than just this pipeline, though: before reaching the ISP stages above, it first builds up the color science underneath all of it from scratch — the spectral sensitivity function, CIE color matching experiments, the CIE XYZ/RGB tristimulus spaces, the CIE xy chromaticity diagram, and color gamuts (deepening Week 1 §3's cones/tristimulus/metamerism material) — and, past the pipeline stages themselves, it also covers gamut mapping (camera-native gamut → standard sRGB gamut), JPEG compression, and a brief one-slide preview of deconvolution ahead of its full treatment in Week 5–6.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check
If you can explain, in your own words, *why* a wider aperture (smaller f-number) simultaneously gathers more light, produces shallower depth of field, and moves you further from (not closer to) the diffraction limit — using only the words "circle of confusion," "f-number," and "numerical aperture" — you've understood the core trade-off of Week 2.

A second check, specifically for the focal-length/sensor-distance distinction (§4.2–4.3, §5): if a friend asked you "what's the difference between focal length and sensor distance, and why does moving the sensor change what's in focus?", you should be able to answer using only the words "intrinsic," "setup," and "thin lens equation" — without needing to look anything up.

A third check, for exposure (§13): given the lecture's two equivalent-exposure pairs f/16 at 1/8 s and f/2 at 1/500 s, you should be able to explain why both photos come out equally bright but only one freezes the flying pigeons, and why a LiDAR deliberately uses an "exposure" roughly a million times shorter than either, using only the words "t/N²," "motion blur," and "ambient light."
