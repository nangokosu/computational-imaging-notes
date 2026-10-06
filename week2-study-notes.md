# CSC2529 Computational Imaging — Week 2 Study Notes

**Topic:** Digital Photography I — Ray Optics, Aperture, Sensor
**Source:** Lecture 2 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 2 ("PS2," a TA problem session covering HW2), Task 1 only (f-number / depth of field / circle of confusion); reading: Marc Levoy, Stanford CS178 "Digital Photography" course.
**Order differs from the slides.** The lecture mixes optics and sensor topics and uses the f-number, circle of confusion and noise before building them. These notes reorder it so every section uses only ideas built above it: why we need optics, then the pinhole (size, light), then the lens (thin lens equation, real lenses, field of view), then the aperture and f-number, then defocus, depth of field, hyperfocal distance, the lens's diffraction limit, and bokeh; then the sensor (pixel, CCD/CMOS, shutters), the path from photons to a RAW image, noise from scratch, SNR, and dynamic range. Each section ends with a **Summary** box; forward pointers appear only there, as optional "where this goes next" lines.
**Scope:** Announcements and the guest-colloquium plug are skipped; notes start from "Let's say we have a sensor…". PS2's Tasks 2–3 (demosaicing methods, gamma correction, denoising) belong to the image-signal-processing pipeline the lecture defers to "Next", which is Week 3's material. This lecture's exposure/exposure-time/ISO material now lives in Week 4 §2, next to the HDR and flutter-shutter material that depends on it; where this file needs those words, it gives a one-line inline meaning and points there.
**Exam note:** several formulas reuse the same symbols with shifted meanings (flagged where it happens: *S* vs *O*, *c* as a general size vs a fixed threshold, *d* as pinhole diameter vs sensor width, λ as wavelength vs a Poisson rate). The usual mistake is mixing up which symbol means what, not the algebra.

---

## 1. Why Doesn't a Bare Sensor Take a Picture?

**Analogy.** Hold a sheet of white paper in a room with a lamp and a window. Every spot on the paper is lit by *everything* in the room at once, so you see a soft glow, not a picture. A bare sensor is that sheet of paper.

A **sensor** (the electronic chip that turns light into an electrical signal; the camera's "retina", Week 1 §2, §7) pointed at a scene with nothing in front of it receives light from *every* scene point at *every* sensor location. Nothing separates "light from here" from "light from there".

The result is not a flat gray field; it is an extremely blurred scene. Each sensor location adds up light from all scene points, with unequal weights:

- **Angle:** light arriving nearly head-on counts more than light arriving at a grazing angle (a cosine falloff).
- **Distance:** light from a nearer point counts more than from a farther one. This is the **inverse-square law**: a source spreads its light over a sphere whose area grows as distance², so brightness at a point falls as 1/distance².

Only the coarsest shapes (broad light/dark regions) survive this averaging; fine detail (high spatial frequency, Week 1 §16) washes out. The picture looks like maximal defocus blur.

**Linear-algebra view (image formation as a matrix–vector product).** List the brightness of every scene point as one long vector **x** (basis: "one scene point lit, all others dark") and every sensor reading as a vector **y**. Each reading is a weighted sum of scene brightnesses, so the capture is one **linear map**, **y** = **A x**, where entry *A_ij* is the cosine-and-distance weight from scene point *j* to sensor location *i*.

- For a bare sensor, neighboring rows of **A** are nearly identical, so **A** is **ill-conditioned**: some scene directions are shrunk almost to zero and cannot be recovered.
- *Toy example:* 8 scene points, 8 sensor locations, weights = cos/distance². The **singular values** of **A** run from 6.41 down to 3.18 × 10⁻⁶, a **condition number** (largest ÷ smallest singular value: how much measurement error inverting **A** can amplify) of about 2.0 × 10⁶.
- A good camera needs **A** close to a **permutation matrix** (each scene point sent to exactly one sensor location), whose condition number is exactly 1.

Everything in this lecture is optics or sensing built to make **A** that well-behaved: a device between scene and sensor that sends *each scene point to (ideally) one sensor location*. Inverting **y** = **A x** is the inverse-problem framing of Weeks 5–6.

**The model we use: ray optics.** **[Ray optics](https://en.wikipedia.org/wiki/Geometrical_optics)** (geometric optics) treats light as straight lines ("rays") that bend only at a lens surface or stop at an opaque barrier, ignoring that light is a wave. It is the assumption behind HW1's pinhole-box geometry and is excellent almost everywhere here. It fails only when an opening becomes tiny, where light's wave nature matters.

> **Summary**
> - A bare sensor mixes light from every scene point, so it records a heavily blurred average, not an image.
> - As a matrix: **y** = **A x** with **A** ill-conditioned (toy condition number about 2 × 10⁶); a camera must make **A** close to a permutation.
> - We analyze the fix with ray optics (straight-line rays).
> - Next: the simplest fix, a barrier with one small hole (§2).

---

## 2. The Pinhole Camera

**Fix:** put an opaque barrier (a **diaphragm**) with one small opening, a **pinhole** (also called a **[camera obscura](https://en.wikipedia.org/wiki/Camera_obscura)**), between scene and sensor. The pinhole is the camera's **[aperture](https://en.wikipedia.org/wiki/Aperture)**, the opening that controls how much light gets in (the eye's pupil plays the same role, Week 1 §2).

Of all the rays leaving one scene point, only the one heading straight at the pinhole gets through. Each scene point now lights up (ideally) one sensor location instead of smearing across the sensor as in §1.

**Terms** (all consequences of straight-line rays):
- **Camera center** (center of projection): the pinhole itself; every surviving ray passes through it.
- **Image plane**: the sensor surface where the rays land.
- **Focal length, *f***: the distance from the pinhole to the image plane.

**The image is upside-down and scaled.** A ray from the top of an object passes through the pinhole and continues downward, landing on the *bottom* of the image plane. Two rays from one object point, one above and one below the pinhole's axis, form mirror-image similar triangles on either side, so the image is inverted and rescaled by (pinhole-to-sensor distance) ÷ (pinhole-to-object distance).

**Focal length controls image size.** Halving *f* (sensor half as far behind the pinhole) halves the image, like a shadow shrinking as the wall moves closer to the object.

**A pinhole never needs focusing.** Every scene point, at any distance, sends exactly one undeviated ray to one sensor point. This is the property a lens gives up in exchange for more light.

**Linear-algebra view (perspective projection in homogeneous coordinates).** Put the pinhole at the origin, with axes sensor-horizontal *X*, sensor-vertical *Y* and depth *Z* along the optical axis, and append a 1 to each scene point to get **homogeneous coordinates** (X, Y, Z, 1).

- The 3×4 **camera matrix** P = [[−f, 0, 0, 0], [0, −f, 0, 0], [0, 0, 1, 0]] maps that vector linearly to (−fX, −fY, Z). Dividing by the last entry (the depth) gives the sensor position (−fX/Z, −fY/Z). The factor *f*·X/Z is the similar-triangles ratio; the minus signs are the upside-down flip.
- P has **rank** 3, so one input dimension is lost. Its **null space** is spanned by (0, 0, 0, 1), the pinhole itself.
- Every point *t*·(X, Y, Z) on one ray gives a scaled copy of the same output vector, and the division collapses it to one pixel. Example: with *f* = 50 mm, (100, 200, 1000) mm and (200, 400, 2000) mm both land at (−5, −10) mm.
- The collapsed dimension is depth. That is why one photo cannot tell how far away anything is, and why depth sensors such as LiDAR add a separate distance measurement along each ray.

> **Summary**
> - A pinhole sends each scene point through one ray to one sensor point: an inverted, scaled image with no focusing needed.
> - Remember: image position = −*f*·(X/Z, Y/Z); *f* is the pinhole-to-sensor distance.
> - The projection matrix has rank 3: depth is lost along each ray.
> - Next: a real pinhole has nonzero size, and size controls both blur and brightness (§3, §4).

---

## 3. Pinhole Size: A Sharpness/Light Trade-off, and the Diffraction Limit

An ideal pinhole would be a single point, which is impossible to build and would pass zero light. A real pinhole has some diameter *d*, and *d* affects image quality from two opposite directions.

**Direction 1: geometric blur (ray optics still works).** A pinhole of nonzero size passes a small *cone* of rays per scene point. They land at slightly different sensor spots, so each scene point becomes a blur disc about as wide as the pinhole. **A larger pinhole means a blurrier image.** By this logic a smaller pinhole should sharpen the image forever; it does not.

**Linear-algebra view (pinhole blur as a convolution matrix).** In §1's **y** = **A x** picture, a finite pinhole replaces the permutation matrix with one whose columns are small discs of nonzero weights instead of a single 1.

- The same disc appears at every position, so each row is the previous row shifted by one: a **Toeplitz** (constant-along-diagonals) **convolution matrix**.
- **Convolution** means "stamp a copy of the blur shape at every scene point and add them up"; the blur shape is the **kernel** or, in optics, the **point spread function (PSF)**: the image the system makes of a single point. Week 1 §20 builds convolution with worked numbers.
- The Fourier basis **diagonalizes** such a matrix; the disc's Fourier transform gives the eigenvalues. A bigger disc pushes more eigenvalues toward zero, so more fine detail is lost.
- Undoing the matrix is **deconvolution** (Week 1 §23 previews why it is hard; Weeks 5–6 treat it fully).

**Direction 2: diffraction (a wave effect).** Once the pinhole is only a few wavelengths wide, **[diffraction](https://en.wikipedia.org/wiki/Diffraction)**, the spreading of a wave after passing a narrow opening, takes over, and ray optics (which says light does not spread) fails. *The smaller the gap, the more the light fans out.* Ripples fanning out through a narrow harbor gap are the analogy.

> **Optional deeper dive: why smaller means more spread.** The diffraction pattern past an opening is the 2D **[Fourier transform](https://en.wikipedia.org/wiki/Fourier_transform)** of the opening's shape. By the general Fourier fact of Week 1 §19.3 (a small feature in space has energy spread over large frequencies), a smaller hole gives a wider pattern and a larger hole a narrower one, close to the ray prediction.

**Putting them together.** Shrinking the pinhole cuts geometric blur until diffraction takes over and blur grows again. There is a sweet-spot diameter, not "smaller is always sharper".

### 3.1 The exact trade-off: optimal pinhole diameter

**What problem this solves.** You must choose a real diameter. Input: pinhole-to-sensor distance *f* and wavelength λ. Output: the diameter *d* with the least total blur. *Analogy:* a tug-of-war between two penalties, like picking the speed that balances arriving late against paying for fuel.

**Intuition: write both blurs as one quantity.**
1. Geometric blur ≈ *d* (Direction 1).
2. Diffraction fans light out by an angle of roughly λ/*d* radians (the narrower the gap relative to the wavelength, the wider the fan).
3. Over the distance *f* to the sensor, that angle becomes a linear spread ≈ angle × distance = *f*·λ/*d* (small-angle approximation).
4. Adding the two independent contributions:

```
blur(d) ≈ d + fλ/d
```

**Why the minimum sits at a balance.** The first term grows with *d*, the second shrinks, so the total bottoms out where they are comparable. Setting the derivative to zero, 1 − fλ/d² = 0, gives d² = fλ, so *d* ≈ √(fλ). The course's pinhole-build slides give this balance with a factor 2 from the exact geometry:

```
d = 2√(fλ)
```

**Terms:**
- *d* — pinhole diameter (what you choose).
- *f* — pinhole-to-image-plane distance (fixed by your box).
- λ — wavelength of the light imaged (fixed by the light source). Here λ is the *wavelength of light*, not a spatial or temporal frequency (Week 1 §16.1).

This is the formula behind "how big should the hole be" for HW1's pinhole box. Plugging in your own box's *f* to get a diameter is the homework step, left to the assignment.

> **Summary**
> - A bigger pinhole means more geometric blur; a smaller one means more diffraction blur. Neither extreme is sharp.
> - Remember: blur(*d*) ≈ *d* + *f*λ/*d*, minimized at *d* = 2√(*f*λ) (course form).
> - Pinhole blur is a convolution (Toeplitz matrix) with the disc as its kernel/PSF.
> - Next: a smaller pinhole also gathers less light (§4), which is what motivates a lens (§5).

---

## 4. Light Efficiency vs. Pinhole Size and Focal Length

Two geometric facts, both from §2's ray picture:

- **Doubling the pinhole diameter quadruples the light.** Light passing an opening scales with its *area*, and a circle's area is π·(diameter/2)², so doubling *d* multiplies area and light by 2² = 4.
- **Doubling the focal length quarters the light per unit sensor area.** Putting the sensor twice as far from the pinhole spreads the same light over about 4× the area (inverse-square law, §1). Light *per unit area* is what matters for brightness.

Together these are the seed of the aperture/f-number trade-off and of exposure (Week 4 §2).

> **Summary**
> - Light collected scales with opening area ∝ *d*²; light per sensor area scales as 1/*f*².
> - Remember: 2× diameter gives 4× light; 2× focal length gives ¼ light per area.
> - Next: a pinhole cannot be both sharp (small) and bright (large); a lens can (§5).

---

## 5. Refraction, the Thin Lens Model, and the Gaussian Lens Formula

A pinhole forces a choice: small enough to be sharp (§3) or large enough to be bright (§4). A **lens**, a shaped piece of transparent material (usually glass), bends many rays from one scene point back together at one image point. The opening can then be large (bright) without smearing the image (sharp).

**[Refraction](https://en.wikipedia.org/wiki/Refraction)** is the bending of a ray when it crosses between two materials of different optical density (air into glass), the same effect that makes a straw look bent in water. A lens's curved surfaces refract rays toward a common point.

**The thin lens model** is a simplification (valid for well-designed lenses) built on two assumptions:

1. **A ray through the exact center of the lens is unaffected.**
2. **Rays arriving parallel to each other converge to one point on the focal plane**, the plane one focal length *f* behind the lens.

Three characteristic rays from any object point then let you trace the image by hand:
- the **parallel ray**: travels parallel to the main axis, then bends through the far focal point (assumption 2);
- the **chief ray**: passes through the lens center unbent (assumption 1);
- the **near-focal-plane ray**: passes through the *near* focal point and emerges parallel to the axis (assumption 2 reversed).

All three meet at the same image point. §5.1 turns two of them into algebra.

### 5.1 Scene-space vs. image-space: deriving the Gaussian lens formula

**What problem this solves.** To focus, you must know where behind the lens the sharp image forms. Input: object distance *S* and focal length *f*. Output: the lens-to-sensor distance *S′* at which that object is sharp. *Analogy:* a funnel with one sweet spot; each object distance maps to exactly one *S′* where its rays meet.

Hand tracing shows *that* the rays meet, not *where*. To get numbers, label the picture:

| Symbol | What it measures |
|---|---|
| *y* | height of the object above the lens's central axis |
| *S* | **object distance**: from the object to the lens |
| *f* | **focal length**: from the lens to its focal point (a fixed property of the lens) |
| *S′* | **sensor distance** (also *image distance*): from the lens to where the sharp image forms |
| *y′* | height of the image below the axis (inverted; both heights are treated as unsigned, with the inversion tracked separately) |

**Relation 1, from the chief ray.** The triangle (object, lens center, axis) on the scene side is similar to (lens center, image, axis) on the image side, since they share the vertex angle at the lens center. Equal side ratios give:

```
y'/y = S'/S
```

**Relation 2, from the parallel ray.** It travels flat, bends through the far focal point, then continues to the image point. This forms a second pair of similar triangles: the object height over the full distance *f*, and the image height over the last stretch *(S′ − f)*:

```
y'/y = (S' - f)/f
```

**Combine.** Both equal *y′*/*y*, so the heights drop out:

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

This is the **thin lens equation** (Gaussian lens formula). It ties together where the object sits (*S*), where its sharp image forms (*S′*) and the lens's fixed *f*. Solving it for *S′* (*S′ = fS/(S−f)*) and substituting into Relation 2 gives the **magnification**:

```
m = y'/y = (S' - f)/f
```

Equivalently *m* = *S′*/*S* (Relation 1). Consistent with §2: for a fixed object distance, a shorter *f* forces a smaller *S′*, and *m* shrinks with it.

**Linear-algebra view (ray-transfer matrices).** The thin lens model is secretly a **linear map** on a 2-entry vector per ray: (height above the axis, angle to the axis in radians, small-angle approximation).

- Travelling a distance *L* is the matrix [[1, L], [0, 1]] (height grows by *L*·angle).
- The thin lens is [[1, 0], [−1/f, 1]]: height unchanged (assumption 1), angle bent in proportion to height (assumption 2).
- Multiplying object-to-lens, lens, lens-to-sensor gives the whole camera as one 2×2 matrix whose top-right entry is S + S′ − S·S′/f = S·S′·(1/S + 1/S′ − 1/f).
- That entry is 0 exactly when the thin lens equation holds. Then output height no longer depends on input angle, which is *why* every ray from one object point meets at one image point. The top-left entry reduces to −S′/S, the magnification with its inversion sign.
- *Example (illustrative numbers):* *f* = 50 mm, *S* = 150 mm gives *S′* = 75 mm and the matrix [[−1/2, 0], [−1/50, −2]] (determinant 1, as for every product of these matrices).

### 5.2 Intrinsic lens properties vs. setup properties

This distinction makes every later formula easier to read.

- **Intrinsic to the lens** (fixed when the glass is ground; changes only by swapping the lens, or the zoom setting on a zoom lens): the **focal length *f***.
- **A property of the scene**: the **object distance *S***, wherever the subject happens to stand.
- **A property of the setup**: the **sensor distance *S′***. Turning the focus ring moves internal lens elements, changing the effective lens-to-sensor distance. *S′* is what a focus mechanism (ring or autofocus motor) adjusts.

`1/S + 1/S' = 1/f` is the constraint linking them. For fixed *f* and a chosen *S*, exactly **one** *S′* gives a sharp image. **"Focusing" means turning the focus ring until *S′* reaches that value.** At any other *S′* you get defocus blur.

### 5.3 The inverse relationship: how moving the lens changes what's in focus

In practice the ring position fixes *S′*, and *S* (what is in focus) is what you solve for. Rearranging:

```
S = 1 / (1/f - 1/S')
```

**Reading it:** as *S′* increases, 1/*S′* shrinks, so `1/f − 1/S′` grows, so *S* shrinks. Moving the lens *farther* from the sensor brings the plane of focus *closer*; moving it *closer* to the sensor pushes focus *farther*. That one lens-to-sensor distance is the only "focus knob" there is.

> **Two special focus distances (general facts, not tied to any homework setup).**
> - **Infinity focus:** set *S′ = f*. Then `1/S = 1/f − 1/f = 0`, so *S = ∞*. Infinity focus is one fixed lens position, one focal length from the sensor (consistent with assumption 2: parallel rays come from infinitely far away).
> - **Unity magnification ("1:1 macro"):** set *S′ = S = 2f*. Check: `1/(2f) + 1/(2f) = 1/f` ✓ and `m = (2f−f)/f = 1`. Object and sensor sit at twice the focal length each, and the object is reproduced life-size.

> **Summary**
> - A lens bends many rays from one point to one image point, giving brightness *and* sharpness.
> - Remember: **1/S + 1/S′ = 1/f**, with magnification *m* = *S′*/*S*; *f* is intrinsic, *S* is the scene's, *S′* is the setup's (set by the focus ring).
> - The thin lens is a 2×2 ray-transfer matrix whose top-right entry is zero exactly when the equation holds.
> - Next: real lenses are not thin or perfect (§6), and *f* fixes the field of view (§7).

---

## 6. Real Lenses: Compound Lenses and Aberrations

**Thin lenses are a fiction.** The thin lens model assumes zero thickness. Real camera lenses are **compound lenses**: several lens elements stacked so that, for rays close to the central axis (called *paraxial* rays), the stack acts like one ideal thin lens with some equivalent focal length.

Even a good compound lens deviates from the model. Any systematic deviation from ideal thin-lens focusing is an **aberration**:

| Aberration | Cause | Where it appears |
|---|---|---|
| **Spherical aberration** | Real lens surfaces are usually ground *spherical*, not the ideal shape that focuses parallel rays to one point (spheres are far easier to manufacture) | Everywhere; worst for rays far from the central axis |
| **[Chromatic aberration](https://en.wikipedia.org/wiki/Chromatic_aberration)** | Glass has **[dispersion](https://en.wikipedia.org/wiki/Dispersion_(optics))**: its refractive index (so its focal length) depends slightly on wavelength, so colors focus at slightly different distances | Everywhere; partly correctable with a two-element "doublet" of glasses with different dispersion |
| **Oblique aberrations** (coma, pincushion/barrel distortion, astigmatism, field curvature) | Departures from the paraxial assumption itself | Only away from the field's center; zero on-axis, growing toward the edges |

> **Summary**
> - Real lenses are stacks of elements that approximate a thin lens only near the axis.
> - Remember: aberrations are precise, fixable geometric deviations (spherical, chromatic, oblique), not vague "softness".
> - Next: the angular extent of scene a lens and sensor capture (§7).

---

## 7. Field of View

**[Field of view (FOV)](https://en.wikipedia.org/wiki/Field_of_view)** is the angular extent of the scene a lens/sensor combination captures. It is the camera version of the eye's FOV in Week 1 §10 (monocular ~190°, binocular ~120°). It depends on the lens's focal length *f* (intrinsic, §5.2) and the sensor's physical size (a property of the camera body):

- longer *f* concentrates the sensor onto a narrower slice of the scene ("telephoto");
- shorter *f* spreads a wider slice onto the same sensor ("wide-angle").

**What problem this solves.** Before choosing a lens you want to know how much scene will fit in the frame. Input: sensor width (or height) *d* and focal length *f*. Output: the viewing angle in degrees. *Analogy:* looking through a window: close up you see a wide slice of the outdoors, standing back a narrow one; *f* is how far back the sensor sits from the "window".

**Intuition.** This is the same right triangle as Week 1 §9's screen-pixel formula, solved the other way: there a known angle and distance gave a size; here a known size (the sensor) and distance (*f*) give an angle. Split the sensor in half around the central axis: each half is one leg (*d*/2) of a right triangle whose other leg is *f*, with half-angle arctan((*d*/2)/*f*). Doubling gives the full angle:

```
FOV = 2 · arctan(d / (2f))
```

**Terms:**
- *d* — sensor width or height (fixed by the camera body; here *d* is a sensor size, not the pinhole diameter of §3).
- *f* — focal length (intrinsic).
- The *2×* and *arctan* come from the half-angle construction above (Week 1 §9's `p = 2·d·tan(α/2)`, solved for the angle).

**Diagram.** Picture the lens as a point on the optical axis with the sensor a distance *f* behind it. Rays from the lens to the sensor's top and bottom edges span the FOV; the axis bisects the angle into two halves of FOV/2, each the angle of a right triangle with opposite leg *d*/2 and adjacent leg *f*. The artifact has the drawn version.

*Values from lecture (full-frame sensor):* an 8 mm lens gives about 180° FOV, a 50 mm "normal" lens about 43°, a 1000 mm super-telephoto about 2.5°. Same sensor, very different angle, purely from focal length.

> **Worked example, from lecture: Hubble Space Telescope's focal length.** Given Hubble's field of view (52 arcseconds ≈ 0.0144°) and its 1024×1024 CCD, running the FOV formula in reverse gives an effective focal length of **f ≈ 57.6 m**, an extreme telephoto (about 170× narrower than the 1000 mm row above). Yet its optical tube is only **13.2 m** long. The gap is closed by *folding* the light path: light goes from a large primary mirror to a smaller secondary mirror and back down the tube, so *effective focal length* is decoupled from *physical length* (also used in compact mirror lenses for cameras).

> **Summary**
> - FOV is set by sensor size and focal length: longer *f* means narrower view.
> - Remember: **FOV = 2·arctan(*d*/(2*f*))**.
> - Folded mirror designs show effective focal length need not equal physical length.
> - Next: the one lens control we have not yet named, the adjustable aperture (§8).

---

## 8. Aperture and F-Number

Most lenses have an adjustable **aperture** (the opening of §2), typically a **diaphragm** of overlapping blades playing the role of the eye's iris (Week 1 §2). It sets the opening's diameter *D*, independently of the fixed focal length *f*. *D* is a *setup* choice (an aperture ring, or the camera picks it), capped by the lens's maximum opening (an intrinsic limit).

The standard way to describe aperture size is the **[f-number](https://en.wikipedia.org/wiki/F-number)** *N*, written "f/*N*":

```
N = f / D
```

**Terms:**
- *f* — focal length (intrinsic).
- *D* — aperture diameter (setup).
- *N* — their ratio, dimensionless.

Because *N* = *f*/*D*, a *larger* f-number (f/16) is a *smaller* opening, and a *smaller* one (f/1.4) is a *larger* opening. The inverse relationship is built into the formula.

**Reading "f/2.8".** The slash is a division: *D* = *f*/2.8. On a 50 mm lens, f/2.8 is 50/2.8 ≈ 17.9 mm and f/5.6 is ≈ 8.9 mm. A lens labelled "50 mm f/1.8" is a 50 mm lens whose *widest* opening is f/1.8 (its smallest *N*). Since the opening is always a fixed fraction of *f*, the same f-number gives the same *brightness* on any lens, so photographers can swap lenses and keep "f/4".

**Stops.** Aperture sizes are spaced in **stops**: one full stop changes the light reaching the sensor by a factor of 2 (the same unit as Week 1 §15's dynamic-range stops). So f/2.8 lets in twice the light of f/4, which lets in twice the light of f/5.6.

**Why full stops step by √2, not 2.** Light depends on the aperture's *area* ∝ *D*² (§4). Halving the light means halving *D*², so shrinking *D* by 1/√2. Since *N* = *f*/*D* at fixed *f*, each full stop multiplies *N* by about **√2**. That is why the full-stop sequence is f/1.4, f/2, f/2.8, f/4, f/5.6, f/8, f/11, f/16, f/22: each number is about √2 times the last, while the light halves each step.

By §4's area logic, halving *N* (doubling *D* at fixed *f*) quadruples the light.

**Stops as a count (building on Week 1 §14's `stops = log₂(ratio)`).** Light through the aperture goes as *D*² ∝ 1/*N*², so the light ratio between *N*₁ and *N*₂ is (*N*₂/*N*₁)², and:

```
stops = log₂( (N₂ / N₁)² ) = 2 · log₂( N₂ / N₁ )
```

*Intuition:* the square comes from area; log₂ turns "how many doublings of light" into a count; the 2 in front is why one stop in *N* is only a factor √2. *Terms:* *N*₁ the starting f-number, *N*₂ the new one (both set by you, dimensionless). A positive result means *N*₂ lets in *less* light, so signs are easy to flip: **bigger f-number = fewer stops of light**. Equivalently, the *k*-th stop from a starting *N*₀ is *N*₀ · 2^(*k*/2).

| Stops from f/2.8 | Exact N = 2.8 · 2^(k/2) | Marked on the lens |
|---|---|---|
| −2 | 1.40 | f/1.4 |
| −1 | 1.98 | f/2 |
| 0 | 2.80 | f/2.8 |
| +1 | 3.96 | f/4 |
| +2 | 5.60 | f/5.6 |
| +3 | 7.92 | f/8 |
| +4 | 11.2 | f/11 |

The marked numbers are rounded versions of the exact values, which is why the printed sequence looks slightly irregular.

**Third-stop f-numbers.** A third of a stop multiplies *N* by 2^(1/6) ≈ 1.12. From f/2.8 the three one-third steps are ≈ 3.14 → 3.52 → 3.95, marked f/3.2, f/3.5, f/4.

**Exposure compensation (aperture-priority vs. shutter-priority).** The **shutter time** is how long each pixel collects light (Week 4 §2 builds it fully). In *aperture-priority* mode you fix *N* and the camera picks the shutter time. A "+2" exposure-compensation setting (Week 1 §14) asks for 2 stops (4×) more light than the meter's pick, so the camera lengthens the shutter time 4× (e.g. 1/250 s → 1/60 s, up to rounding). In *shutter-priority* mode the same "+2" is delivered by opening the aperture 2 stops (e.g. f/5.6 → f/2.8). The same dial moves a different knob, and the brightness is the same (Week 4 §2.2).

> **Worked example (generic, not homework).** Going from f/8 to f/2.8 gives *N*₂/*N*₁ = 2.8/8 = 0.35, so stops = 2·log₂(0.35) ≈ −3.03: about 3 stops *more* light (negative because *N* got smaller). As a multiplier, (8/2.8)² ≈ 8.2×, matching 2³ = 8 up to rounding. If correct exposure at f/8 was 1/60 s, the same brightness at f/2.8 needs about 3 stops less time: 1/60 → 1/125 → 1/250 → 1/500 s.

> **Summary**
> - The aperture diameter *D* is a setup choice; the f-number *N* = *f*/*D* expresses it relative to focal length.
> - Remember: **N = f/D**, one stop = ×√2 in *N* = ×2 in light, and **stops = 2·log₂(*N*₂/*N*₁)**; bigger *N* means less light.
> - Light ∝ 1/*N*²; doubling *D* quadruples it.
> - Next: what happens to points *not* at the focused distance, using *D* (§9).

---

## 9. Defocus and the Circle of Confusion

This is the start of the most important technical material of Week 2: the direct basis for PS2's Task 1 and for HW2. The lecture's notation is easy to mix up under exam pressure, so this section fixes it first.

### 9.1 Defocus: the focused distance *S* vs. the actual distance *O*

§5.2 showed that for a fixed sensor distance *S′* (wherever you left the focus ring), the thin lens equation names exactly one object distance that comes out sharp. Two symbols keep this straight:

- ***S*** — the **focused object distance**: the distance the thin lens equation predicts for the current, fixed *S′*. It is the same *S* as §5.1, now thought of as "fixed by where you left the focus ring". **It is not a free variable.**
- ***O*** — the **actual object distance**: where a real scene point actually is. It equals *S* only by coincidence or because you focused on it.

When *O = S*, that point's rays converge exactly on the sensor: a sharp point. When *O ≠ S*, its rays want to converge somewhere *other* than the sensor, either before it (point farther than *S*) or after it (point closer). By the time they reach the fixed sensor they form a small blurred disc, the **circle of confusion**.

**Why this never happens with a pinhole.** A pinhole has no focus distance to get wrong (§2): every point at every *O* projects through one undeviated ray. Defocus is the price a lens pays for its light-gathering aperture.

**Focus is local to one plane.** One fixed *S′* satisfies the thin lens equation for only one *S*, and real scenes have points at many distances *O*. So a range around *S* looks acceptably sharp and the rest is blurred; how wide that range is is the topic of depth of field.

In the linear-algebra picture of §3, defocus is still a **linear map** (a sum of blur discs), but the disc width depends on each point's depth *O*. For a scene with many depths the matrix is no longer one shift-invariant convolution: different columns carry different-sized discs.

### 9.2 The circle-of-confusion formula, derived

**What problem this solves.** A lens focuses sharply at one distance, so an object elsewhere is smeared into a disc. This formula says how big. Input: aperture diameter *D*, focused distance *S*, actual distance *O* (and the magnification of the focused pair). Output: the blur-disc diameter *c* on the sensor. *Analogy:* a flashlight beam on a wall: a tight spot at one distance, a widening circle if the wall moves nearer or farther.

Two similar-triangle relations, parallel to §5.1's derivation, now for a point *not* at the focused distance.

**Relation 1.** The object point (at *O*) sends a full cone of rays spanning the aperture diameter *D* at the lens. Slice the same cone at the in-focus *S*-plane instead; by similar triangles (same apex at the object point), its half-width *y* there scales down:

```
y / (D/2) = |O - S| / O
```

**Relation 2.** By definition *S* is the one object distance whose rays converge to a point at the sensor, so the lens maps that *y*-wide slice at the *S*-plane to the sensor with the magnification *m* of the focused pair (*S*, *S′*) from §5.1. The half-width at the sensor is *m·y*, which is half the circle of confusion:

```
y / (c/2) = 1/m
```

**Combine.** Solve Relation 2 for *y* = *c*/(2*m*), substitute into Relation 1, solve for *c*:

```
c = m · D · |O - S| / O
```

**Terms:**
- *c* — circle-of-confusion diameter (a length on the sensor; what we solve for).
- *m* — magnification at the focused pair (*S*, *S′*), from §5.1.
- *D* — aperture diameter (§8).
- *O* — actual object distance (the scene's).
- *S* — focused distance (the focus ring's).

**Sanity checks.** If *O = S*, *c* = 0: perfectly sharp. As the focus error |*O* − *S*| grows, *c* grows, and it grows faster for a larger *D*, matching §3's finding that a bigger opening makes more geometric blur.

### 9.3 Two ray pictures, one formula: near-defocus and far-defocus blur the same way

The object's own rays converge at a distance *S′_O* from the lens, found by plugging *O* (not *S*) into the thin lens equation: 1/*O* + 1/*S′_O* = 1/*f*. The sensor sits at *S′*, so which side of the sensor *S′_O* falls on gives two different pictures:

- **Far side (*O* > *S*).** A farther object forms its image *closer* to the lens (§5.3: bigger *O* means smaller *S′_O*), so *S′_O* < *S′*. The rays cross *before* the sensor and have already re-diverged when they arrive. The blur disc is a slice of an **already-diverged** cone.
- **Near side (*O* < *S*).** A closer object forms its image *farther* from the lens, so *S′_O* > *S′*. The rays are still narrowing when the sensor intercepts them. The blur disc is a slice of a **not-yet-converged** cone.

**Why both give the same formula.** The ray bundle from any object is an hourglass (a **bicone**): it narrows to a point, the waist at *S′_O*, then widens again at the same opening angle, because both halves are the same straight rays extended through the crossing. The sensor is a fixed slice through this hourglass. A slice at axial distance Δ from the waist has a width set only by |Δ| and the opening angle, not by which side of the waist it is on. That is why §9.2's formula depends on |*O* − *S*| and never on the sign of *O* − *S*.

*Consequence:* two objects, one nearer and one farther than *S*, can show exactly the same blur size even though the ray pictures differ. This is why a single tolerance ε gives a near and a far edge, and (Week 4 §21) why depth from blur is ambiguous.

**Diagram.** The artifact has a single lens-and-sensor system with three ray sets overlaid: the in-focus case (converging on the sensor, zero blur), a near object's still-converging cone, and a far object's already-diverged cone, with the two cross-sections drawn at matching diameters.

> **Summary**
> - *S* is the focused distance (set by the focus ring); *O* is a scene point's actual distance. A point at *O* ≠ *S* blurs into a disc.
> - Remember: **c = m·D·|O − S|/O**, with *c* in the unit of *D* (a length on the sensor), and *c* = 0 at *O* = *S*.
> - Near and far points blur identically in size because the same hourglass of rays is sliced on either side of its waist.
> - Next: how big a blur still looks sharp, which defines depth of field (§10).

---

## 10. Depth of Field

### 10.1 Depth of field: the formula and where it comes from

**What problem this solves.** Only one distance is perfectly sharp, but a zone around it looks sharp enough. Depth of field puts a size on that zone. Input: blur tolerance ε, magnification *m*, aperture *D*, focused distance *S*. Output: the width of the acceptably sharp range. *Analogy:* a spotlight on a stage: the brightest point is one spot, but everyone in the lit circle around it is "in the light".

A sensor's pixel grid has finite resolution (Week 1 §16.4: the pixel pitch fixes the finest "image frequency" it can record), so a blur disc below some small threshold ε is indistinguishable from a sharp point. **[Depth of field (DoF)](https://en.wikipedia.org/wiki/Depth_of_field)** is the range of actual distances *O* for which *c* stays below ε.

**Derive the range from §9.2.** Require *c* ≤ *ε*:

```
m·D·|O - S|/O ≤ ε
⟹ |1 - S/O| ≤ ε/(mD)
```

Call *k* = *ε*/(*mD*), a small number when the tolerance is tight compared to *mD*. Then *S*/*O* lies between (1−*k*) and (1+*k*), which inverts to a range for *O*:

```
O ranges from S/(1+k)  (near edge)   to   S/(1-k)  (far edge)
```

Its width, using 1/(1−*k*) − 1/(1+*k*) = 2*k*/(1−*k*²) ≈ 2*k* for small *k*:

```
DOF = S/(1-k) - S/(1+k) ≈ 2kS = 2εS/(mD)
```

This is the compact formula the lecture states:

```
DOF = 2·ε·S / (m·D)
```

**Caveat: the symmetric approximation.** The compact formula treats the near and far edges as equally spaced around *S* (small *k*). The true depth of field is slightly **asymmetric**, visible in the exact `O = S/(1±k)` expressions (the end of this section shows why). A typical acceptable threshold *ε* is on the order of **4–5 pixels**.

**Notation trap.** The lecture's slide writes this as `DOF = 2εO/(mD)`, with *O* in place of *S*. As the derivation shows, the distance belonging in this formula is the *focused* distance *S*, since DoF is a range centered on the focus plane. Read the slide's "*O*" as *S* here; §9.2 is where *O* genuinely means "actual object distance".

**Why a small f-number gives shallow depth of field.** *D* = *f*/*N* (§8), so a smaller *N* (bigger aperture, more light) makes *D* bigger and therefore *c* larger and the DoF-shrinking factor *mD* larger. The acceptable range shrinks: more light inherently costs a shallower zone of sharpness.

### 10.2 Units trap: the threshold is stated in pixels, but the formula needs a length

In *c* = *m·D·|O − S|/O*, *m* and |*O* − *S*|/*O* are dimensionless, so *c* comes out in the unit of *D*: a physical diameter on the sensor, not a pixel count. In *k* = *ε*/(*mD*), *k* must be dimensionless, so *ε* must be a *length* in the unit of *D*. A threshold given in pixels must first be converted:

```
pixel pitch   = sensor width / number of pixels across that width
ε (length)    = ε (pixels) × pixel pitch
```

- **Pixel pitch** is the center-to-center spacing of pixels on the sensor, a length (typically a few µm), fixed by the camera.
- Computing it from the *height* and vertical pixel count gives the same value when pixels are square (the usual case), a self-check that you read the specifications correctly.
- *Illustrative numbers (not any homework's camera):* a 24 mm-wide sensor with 4000 pixels across has pitch 24/4000 = 0.006 mm (6 µm), so a 3-pixel threshold is 3 × 0.006 = 0.018 mm.

The other inputs need the same care. *D* = *f*/*N* (§8) comes out in the unit of *f*. *m* comes from §5.1 (*m* = *S′*/*S*, with *S′* from the thin lens equation), so *f*, *S* and *S′* must all be in one unit. Mixing meters and millimeters is the most common way to get a DoF off by a factor of 1000.

### 10.3 Near and far distances: the two edges of the depth-of-field range

§10.1 gave the *width* of the range. A homework question (like HW2 Task 1) usually asks for the **near distance** and **far distance** themselves: where the sharp zone starts and ends in the scene. Both come from the same derivation, one step before the small-*k* approximation:

```
O_near = S / (1 + k)      (near edge)
O_far  = S / (1 - k)      (far edge)
where  k = ε / (m·D)
```

**Intuition.** §10.1 showed *S*/*O* is squeezed between (1−*k*) and (1+*k*). Solving each boundary for *O* gives one distance per edge. The nearer edge divides *S* by the *larger* factor (1+*k*); the farther edge divides by the *smaller* factor (1−*k*), and dividing by a smaller number gives a bigger result. That is why the far-edge denominator can hit zero (*k* → 1), the case the hyperfocal distance handles. The width formula is only the *difference* of these two; a "near/far distance" question wants the two distances themselves.

**Term-by-term:**
- *O_near*, *O_far* — boundary object distances (lengths, same unit as *S*); where the sharp zone begins and ends.
- *S* — the focused distance (§9.1), fixed by the focus ring; not something these formulas solve for.
- *k* = *ε*/(*m·D*) — the dimensionless tolerance fraction. *ε* is the blur threshold *as a length* (§10.2), *m* is the magnification at the focused pair (see below), *D* = *f*/*N* (§8).
- Both formulas are exact. Unlike the compact width formula, they do not need small *k*. Do not back them out of the width formula: the true edges are asymmetric around *S*, so "*S* ± DOF/2" is **not** (*O_near*, *O_far*).
- Sanity check: at *k* = 0 (no defocus allowed), *O_near* = *O_far* = *S*: the range collapses to the focal plane.

> **Which is "near" and which is "far"?** *O_near* < *S* < *O_far* always (for 0 < *k* < 1): the near distance is closer to the camera than the focus plane, the far distance farther away.

**Diagram.** Along the optical axis on the object side of the lens, mark the focused plane *S*, the near boundary *O_near* a little closer, and the far boundary *O_far* a little farther. An object at exactly either boundary produces a circle of confusion of exactly *ε* at the sensor; any closer or farther gives *c* > *ε*. The artifact extends §9.2's circle-of-confusion figure with these two planes.

**How to compute the magnification *m* this needs.** Both §9.2 and this section use the magnification at the *focused* pair (*S*, *S′*), not at the actual distance *O*. A typical problem (including HW2 Task 1) gives *f* and *S* but not *S′*, so *m* takes two steps:

1. **Get *S′* from the thin lens equation (§5.1).** `1/S + 1/S' = 1/f` gives `S' = f·S / (S − f)`.
2. **Get *m* from *S′* and *S* (§5.1).** `m = S'/S` (equivalently `m = (S' − f)/f`).

Skipping step 1 (plugging *f* and *S* straight into a magnification-shaped formula) is the most common way to get *m*, and every downstream *k*, *O_near*, *O_far* and DoF, wrong. Keep *f*, *S*, *S′* in one unit, as in §10.2.

### 10.4 Why depth of field is a range, and why the edges are not mirror images

**Why a range, not one sharp plane.** §9.2 makes *c* a continuous function of *O*: *c*(*O*) = *m*·*D*·|1 − *S*/*O*|. It is exactly zero only at *O* = *S*, but being continuous it must pass through small values around *S*. The threshold *ε* is some fixed nonzero size (set by the pixel grid or the eye), so a whole neighborhood of *O* has *c*(*O*) ≤ *ε*. That neighborhood is the depth of field. If *ε* were zero, the range would collapse to the single plane *O* = *S* (the *k* = 0 check in §10.3).

**How *c*(*O*) changes on each side.** Split the formula at *O* = *S*:

```
O < S (near side):  c(O) = m·D·(S/O − 1)
O > S (far side):   c(O) = m·D·(1 − S/O)
```

*S*/*O* is a reciprocal, so neither side is a straight ramp, and the two sides differ:

- **Near side.** As *O* shrinks toward the lens, *S*/*O* grows without limit, so *c* → ∞ as *O* → 0, faster than linearly.
- **Far side.** As *O* → ∞, *S*/*O* → 0, so *c* climbs toward a **finite ceiling**, *c*<sub>∞</sub> = *m*·*D*. No matter how far the object, its blur never exceeds *m*·*D*. (The next section uses this ceiling.)

**Is the growth symmetric?** Only approximately and only locally. Write *O* = *S*(1+*δ*) with small *δ* (positive on the far side, negative on the near side); then *c*/(*m·D*) = |*δ*/(1+*δ*)|, and

```
far side (δ>0):  c/(mD) ≈ δ − δ²
near side (δ<0): c/(mD) ≈ |δ| + δ²
```

To first order both sides grow at the same rate *m*·*D*·|*δ*|, which is why the compact formula can treat the edges as symmetric. The second-order term has opposite signs: it bends the far-side curve down (toward saturation) and the near-side curve up (toward blow-up).

The extreme case: as *k* → 1, *O_far* = *S*/(1−*k*) goes to infinity while *O_near* = *S*/(1+*k*) only shrinks to the finite floor *S*/2. The far edge can be pushed arbitrarily far out; the near edge can only collapse halfway to the lens. This lopsidedness comes from the same "distances add as reciprocals" structure as the thin lens equation.

> **Illustrative example (arbitrary S, not any homework's numbers).** Take *S* = 5 (any consistent unit). At *k* = 0.1: (*O_near*, *O_far*) ≈ (4.55, 5.56), nearly symmetric. At *k* = 0.5: (3.33, 10), already lopsided; the far edge sits five times farther from *S* than the near edge. As *k* → 1: (2.5, ∞); the near edge stalls at *S*/2 while the far edge diverges.

**Diagram.** Plot *c* as a curve over *O*: a V touching zero at *S*, rising steeply and without bound toward the lens on the near side, and flattening toward a horizontal asymptote at height *m*·*D* on the far side. The threshold *ε* is a horizontal line whose two crossings are *O_near* and *O_far*, placed asymmetrically around *S*. The artifact has the drawn version.

> **Summary**
> - Depth of field is the range of distances where the blur disc stays under a tolerance ε (a length, so convert pixels with the pixel pitch).
> - Remember: with **k = ε/(mD)**, **O_near = S/(1+k)**, **O_far = S/(1−k)**, and the compact width **DOF ≈ 2εS/(mD)**; get *m* from *S′ = fS/(S−f)* then *m = S′/S*.
> - A smaller f-number (bigger *D*) gives shallower depth of field.
> - The range is lopsided: the far edge can reach infinity, the near edge cannot go below *S*/2.
> - Next: the focus distance that pushes the far edge to infinity (§11).

---

## 11. Hyperfocal Distance

**What problem this solves.** A landscape photographer wants as much of the scene sharp as possible with one focus setting. The hyperfocal distance says where to focus. Input: focal length *f*, f-number *N*, blur tolerance *c*. Output: one focus distance *H*. *Analogy:* standing at the one spot in a room from which the far wall and everything down to halfway toward you are visible at once.

The **hyperfocal distance** *H* is the focus distance *S* that pushes the *far* edge of the depth of field (§10) out to infinity.

**Derivation from §9.2.** As the actual distance *O* → ∞, |*O* − *S*|/*O* → 1 (a finite *S* is negligible next to infinite *O*), so an object at infinity focused at *S* = *H* makes a blur of *c*<sub>∞</sub> = *m·D* (the ceiling of §10.4). Set this equal to the fixed acceptable threshold and solve for *S* = *H*, using *D* = *f*/*N* (§8) and dropping *f* as negligible next to the much larger *H*:

```
H = f² / (N·c)
```

**Terms:**
- *H* — hyperfocal distance (a length).
- *f* — focal length (intrinsic).
- *N* — f-number (setup).
- *c* — the **fixed acceptable-blur threshold**, the same role §10.1 calls *ε*. The lecture reuses the letter *c* both for this constant and for §9.2's general, distance-dependent blur size; **in this formula it means the fixed threshold only.**

**Link to §10.3.** Setting the object-at-infinity blur *m·D* equal to the threshold *is* the statement *k* = *ε*/(*mD*) = 1 at *S* = *H*. With *k* = 1 the far edge *S*/(1−*k*) diverges, and §10.3's exact near-edge formula gives:

```
O_near(H) = H / (1 + k) = H / (1 + 1) = H/2
```

This is the familiar rule "focus at *H* and everything from *H*/2 to infinity is acceptably sharp". It is not a separate fact. It is exact *given* the approximate *H*, so it is not a second approximation stacked on the first. It is the classic landscape technique for maximizing the in-focus range without stopping down so far that diffraction hurts.

> **Summary**
> - The hyperfocal distance *H* is the focus setting whose far edge of acceptable sharpness reaches infinity.
> - Remember: **H = f²/(N·c)** (*c* = fixed threshold), and focusing at *H* makes everything from **H/2 to ∞** acceptably sharp.
> - It falls out of the near/far formulas at *k* = 1.
> - Next: why stopping down to get more depth of field eventually backfires (§12).

---

## 12. The Diffraction Limit of a Lens

**What problem this solves.** Even a perfect, aberration-free lens cannot focus light to a true point, because light is a wave. This formula gives the smallest spot a lens can make: a floor on sharpness. Input: wavelength λ and the lens's numerical aperture (or f-number). Output: the minimum resolvable spot size *d*. *Analogy:* ripples through a harbor gap: however carefully you aim, a wave squeezed through an opening cannot stay narrower than a certain width.

§3 introduced diffraction for a pinhole: a smaller opening spreads light wider. **Abbe's formula** makes this precise for a lens system, giving the smallest spot size *d* purely from diffraction, i.e. the best result even with zero aberrations (§6):

```
d = λ / (2n·sinθ) = λ / (2·NA) ≈ λN
```

**Terms:**
- *λ* — wavelength of the light imaged (the wavelength of light, not a spatial or temporal frequency; Week 1 §16.1).
- *n* — refractive index of the medium (about 1 for air).
- *θ* — half-angle of the widest cone of light the lens accepts or emits.
- **Numerical aperture**, *NA = n·sinθ* — packages *n* and *θ*. A bigger NA means a wider cone of rays, which (same Fourier logic as §3, run in reverse) means a *narrower* focused spot.
- *N* — the photographic f-number (§8). The right-hand form uses the small-angle relation *NA ≈ 1/(2N)*, so f-number alone sets the diffraction-limited resolution floor.

**The resolution vs. depth-of-field trade-off.** §10 showed that a *small* *N* (wide aperture) buys light at the cost of shallow depth of field. This section shows the opposite pressure: a *large* *N* (narrow aperture, more depth of field) makes the diffraction spot *d* bigger, a blurrier best-case image however well aberrations are corrected. High-end microscope objectives push NA to 1.4–1.6 (*d* = λ/2.8, an extremely tight spot) by sacrificing depth of field almost entirely.

> **Optional deeper dive: a space-bandwidth trade-off.** This unavoidable trade (better 2D resolution costs 3D depth information, and vice versa) is an instance of a **space-bandwidth product** ("uncertainty principle") constraint: no optical system has arbitrarily good resolution *and* arbitrarily good depth of field, only a trade governed jointly by the f-number.

> **Summary**
> - Light's wave nature puts a floor on the spot size a lens can make, even a perfect one.
> - Remember: **d ≈ λN** (Abbe: *d* = λ/(2·NA)); a larger f-number means a larger minimum spot.
> - Stopping down buys depth of field but costs resolution: the same trade seen from the other side.
> - Next: what the out-of-focus blur *looks like* (§13).

---

## 13. Bokeh: The *Look* of the Circle of Confusion

§9–§11 treated the blur disc as a *number* (its diameter *c*) to be kept below a threshold. Photographers also care what the blur *looks like*, because the out-of-focus region is a large part of a portrait or night street scene. The aesthetic quality of that blur is called **bokeh**.

**Analogy.** Photograph a string of fairy lights from across a room with the lights deliberately out of focus. Each bulb becomes not a smudge but a clearly shaped bright disc, a "bokeh ball", and the picture is a scatter of overlapping discs. Each disc is §9.2's circle of confusion, visible because the source is a bright tiny point.

### 13.1 Why a defocused point becomes a copy of the aperture

(The same argument as §3's finite pinhole.) A point sends a cone of rays through *every* part of the open aperture, and the sensor slices that cone (§9.3). Each ray lands where its passage through the aperture dictates, so the slice is a scaled copy of the aperture's own outline:

| Aperture outline | Defocused-point shape | Where you see it |
|---|---|---|
| Circle (wide open, or many rounded blades) | round disc | portrait lenses at wide aperture |
| *n*-sided polygon (diaphragm blades form a polygon when partly closed, §8; 5 to 9 sides are common) | an *n*-gon, e.g. a hexagon | stopped-down lenses: each blade edge becomes a straight edge of the disc |
| Circle partly clipped by the lens barrel for off-axis points (**mechanical vignetting**: the barrel's front and rear rims each block part of an oblique cone) | "cat's-eye" or lemon-shaped discs toward image corners | wide-open lenses, image edges |
| Circle with a central blocker (mirror or **catadioptric** lenses fold the light path with mirrors, like Hubble in §7; the small secondary mirror blocks the middle of the opening) | ring or "donut" | long mirror telephoto lenses |
| Circle with ripples from lens-surface machining (a rough or *aspheric*, non-spherical, element, §6) | concentric "onion rings" inside the disc | some lenses with moulded aspheric elements |
| A deliberately cut-out shape (heart, star) in front of the lens | that shape | creative photography; Week 4 §19.2 does this on purpose to reshape the PSF |

The general statement: the blur of a point is the **point spread function (PSF)** (§3). **Bokeh is the defocus PSF.** A photograph's blurred region is every point's PSF added together, a **convolution** of the sharp scene with the PSF (Week 1 §21 has the primer). That is a *single* convolution only if every blurred point has the same disc size; with real depth variation the size changes with distance (§9.1).

**Linear-algebra view.** Defocus blur is a linear map: write the sharp image as a vector **x** (one entry per pixel) and the blurred image as **y**; then **y** = **B x**.

- Each *column* of **B** holds the disc one scene pixel spreads into: nonzero entries form a small blob shaped like the aperture (circle, polygon, ring), with entries summing to 1.
- If all depths are equal, every column is the same blob shifted, so **B** is a (Toeplitz or circulant, Week 1 §20.7 and §21) convolution matrix.
- If depths differ, each column carries a *different-sized* blob and **B** is not shift-invariant. This is the matrix form of "bokeh size depends on distance".

### 13.2 How big is the bokeh disc?

Start from the exact formula *c* = *m*·*D*·|*O* − *S*|/*O* (§9.2). When the focus distance *S* is much larger than *f* (true for most photographs), *m* = *S′*/*S* ≈ *f*/*S* (since *S′* ≈ *f*, §5.1) and *D* = *f*/*N* (§8). Substituting, and using |*O* − *S*|/(*S*·*O*) = |1/*S* − 1/*O*|:

```
c ≈ (f² / N) · | 1/S − 1/O |
```

*Intuition:* the first factor, *f*²/*N*, is the lens-and-aperture "bokeh strength"; the second measures how far apart the object and focus plane are in *inverse distance*.

*Terms:* *f* focal length (fixed by the lens), *N* f-number (you choose), *S* focus distance (you choose), *O* actual distance of the blurred point (the scene's). All lengths in one unit, so *c* comes out in that unit (on the sensor).

Reading it off:
- **Aperture:** *c* ∝ 1/*N*, so f/1.8 gives a disc 8/1.8 ≈ 4.4× wider than f/8 for the same scene.
- **Focal length:** *c* ∝ *f*², so doubling *f* at the same *N* and *S* gives a disc about 4× wider (why telephoto portraits have creamy backgrounds).
- **Distance:** *c* grows as the background gets farther behind the subject but saturates: as *O* → ∞ the 1/*O* term vanishes and *c* → *f*²/(*N*·*S*). A *foreground* point (*O* < *S*) has no ceiling, since 1/*O* keeps growing as it nears the lens.
- **Focusing closer** (smaller *S*) enlarges the background discs.

> **Worked example (generic).** A 50 mm lens at f/1.8 focused on *S* = 2 m, with a bright light at *O* = 10 m. Opening *D* = 50/1.8 ≈ 27.8 mm. Approximate formula: *c* ≈ (50²/1.8)·(1/2000 − 1/10000) = 1389 · 0.0004 ≈ 0.56 mm on the sensor, about 1.5% of a 36 mm-wide full-frame sensor. The exact formula (with *S′* = *fS*/(*S* − *f*) ≈ 51.3 mm, *m* ≈ 0.0256) gives ≈ 0.57 mm, within a few percent. Stopping down to f/8 shrinks the disc to ≈ 0.13 mm.
> *A phone for contrast (illustrative numbers):* *f* = 6 mm at f/1.8 with the same *S*, *O*: *c* ≈ (36/1.8)·0.0004 ≈ 0.008 mm. The sensor is only about 6.7 mm wide, so that is ~0.12% of the width versus 1.5% above, roughly 12× smaller in relative terms. Small sensors with short focal lengths cannot produce strong optical bokeh, which is why phones fake it (end of this section).

### 13.3 Smooth vs. busy bokeh

The disc has an *intensity profile*, not just an outline. Two common shapes:

- **Flat-top disc with a bright rim** (energy piled at the edge, often from uncorrected spherical aberration, §6): each ball has a hard outline, so overlapping balls look busy and "nervous".
- **Soft, Gaussian-like falloff** (bright centre fading smoothly to the edge): overlapping discs blend into a creamy wash. Some lenses add an **apodization** filter, a transparent disc whose transmission fades toward the rim ("apodize" = remove the hard edge), to force this profile. The cost is lost light.

Why the profile matters: a convolution sums neighboring points with weights from the PSF, so a hard-edged PSF turns every sharp-edged bright object behind the subject into a hard-edged copy, while a soft PSF smears it.

**Highlights look special because of clipping.** A bright light may be thousands of times brighter than its surroundings. Blurred into a disc, its brightness is spread thin but often still above the pixel's **saturation** level (the point where its charge bucket is full and it cannot record more), so the disc is recorded as a crisp, uniformly bright ball, while a dim object would just fade. That is why bokeh *balls* come from lights, not from a grey wall.

> **Optional deeper dive: the frequency view.** The PSF's Fourier transform is the **optical transfer function (OTF)**. A soft-edged disc has far weaker ringing in its OTF than a hard one, and a hard circular disc has visible zero-crossings. Week 4 §18.2 builds the OTF; Week 4 §19.3 uses those zeros as the reason a circular aperture is poor for deblurring.

### 13.4 Computational bokeh, and depth sensors (LiDAR and time of flight)

**Why phones fake it.** From §13.2, a phone's optics cannot blur backgrounds. **Portrait mode** computes the blur after capture:

1. **Estimate a depth map**: a distance *O* for each pixel. Sources: two lenses (stereo, Week 1 §11); phase differences between the two halves of each pixel (*dual-pixel* sensors, which see the scene from two slightly different aperture positions); a trained neural network guessing depth from one image; and a depth sensor (below).
2. **Pick the focus plane** *S* (usually the detected face) and compute each pixel's blur size from the same relation as §13.2, *c* ∝ |1/*S* − 1/*O*|, scaled to the artistic strength the maker wants.
3. **Blur each pixel with a disc (or polygon) kernel of that size**: a depth-varying convolution, exactly the non-shift-invariant **B** of §13.1. A good implementation protects the subject's edge (hair!) with a segmentation mask and brightens saturated highlights before blurring so bokeh balls appear.

**Depth sensors: LiDAR and time of flight (ToF).** Many phones add a sensor that measures depth *directly* with light instead of guessing it from the image.

- **Time of flight** emits a short light pulse, waits for the reflection, and converts the delay into distance. Light travels at *c*_light ≈ 3×10⁸ m/s and the pulse goes *there and back*, so distance = *c*_light · Δ*t* / 2.
- *Check by example:* a subject at 3 m gives Δ*t* = 2 · 3 / (3×10⁸) = 20 ns. To resolve 1 cm in depth, the sensor must time the pulse to 2 · 0.01 / (3×10⁸) ≈ 67 picoseconds, which is why these sensors need very fast detectors.
- **LiDAR** ("light detection and ranging") is this same measurement, usually with a scanning or multi-point laser pattern, producing a **point cloud** (a set of 3D points, one range per aimed direction).
- A phone's LiDAR is typically *sparse*, low-resolution compared with the colour image, and limited to a few metres, so the phone *fuses* it: it upsamples the sparse depths guided by the colour image's edges, then feeds the result to step 2 above.
- Compared with the passive route (depth inferred from blur or disparity, which fails in textureless or dark scenes), the active route works in the dark and on blank walls but depends on the object returning enough of the emitted light.

*Where this goes next:* Week 4 §5 elaborates ToF exposure and range; Week 4 §21.3 compares active and passive depth; Week 4 §21 covers depth from the *shape of the defocus PSF* of a coded aperture.

**Limits.** Computational bokeh imitates a *depth-dependent disc convolution*, so it is only as good as its depth map: errors show up as halos around hair and glasses, or blur applied to the wrong object.

> **Summary**
> - Bokeh is the defocus PSF: a defocused point becomes a copy of the aperture's outline, and the blurred region is the scene convolved with it.
> - Remember: **c ≈ (f²/N)·|1/S − 1/O|**: bigger with a wider aperture, a longer focal length, and a farther background.
> - Smooth or busy bokeh depends on the disc's intensity profile; phones fake bokeh with a depth map (stereo, dual-pixel, network, or LiDAR/ToF with distance = *c*_light·Δ*t*/2) plus per-pixel blur.
> - Next: the optics are done; the sensor that records the image comes next (§14).

---

## 14. Sensors: What's a Pixel?

A camera sensor's building block is the **photodiode**: a semiconductor structure that converts an incoming photon into an electron via the **[photoelectric effect](https://en.wikipedia.org/wiki/Photoelectric_effect)** (a photon striking the material knocks an electron loose). Counting those freed electrons, as an accumulated charge, over the **exposure time** (how long the shutter lets the pixel collect light; Week 4 §2 builds it fully) is what "measuring light" means at the hardware level.

A real pixel is more than a bare photodiode:
- A **microlens** on top of each pixel focuses light that would land on the pixel's non-light-sensitive circuitry back onto the active photodiode.
- A **color filter** (Week 1 §7's Bayer/RGGB mosaic) beneath the microlens restricts each pixel to one color channel.
- **[Quantum efficiency](https://en.wikipedia.org/wiki/Quantum_efficiency)** is the fraction of incoming photons actually converted into a counted electron (roughly 50% for a typical sensor); not every photon produces a usable signal.
- **Fill factor** is the fraction of a pixel's area that is light-sensitive (the rest holds wiring and per-pixel circuitry). The microlens compensates for a fill factor below 100% by funneling light from the "dead" area to the live area.

**Linear-algebra view (the Bayer mosaic as an underdetermined system).** As in Week 1 §7, stack the true color image as a vector with 3 unknowns (R, G, B) per pixel and the raw readout as a vector with 1 number per pixel.

- The color filter array is a **selection matrix**: one row per pixel, with a single 1 in the column of the channel that pixel's filter passes.
- For a 4×4 patch this is a 16×48 matrix of **rank** 16 (16 measurements of 48 unknowns: 4 red, 8 green, 4 blue), so its **null space** has dimension 32.
- The system is **underdetermined**: infinitely many full-color images give the same raw data. Demosaicking (Week 3) must add assumptions such as "neighboring pixels have similar colors" to pick one.

> **Summary**
> - A pixel is a photodiode (photons → electrons by the photoelectric effect) plus a microlens and a color filter.
> - Remember: quantum efficiency = fraction of photons counted; fill factor = fraction of pixel area that is light-sensitive.
> - The Bayer color filter array is a 16×48 selection matrix of rank 16 for a 4×4 patch: underdetermined, so demosaicking needs assumptions.
> - Next: how the collected charge is converted and read out (§15).

---

## 15. CCD vs. CMOS

Two sensor architectures differ in *how* accumulated pixel charge is converted to a readable signal:

| | **[CCD](https://en.wikipedia.org/wiki/Charge-coupled_device)** (charge-coupled device) | **[CMOS](https://en.wikipedia.org/wiki/CMOS_sensor)** (complementary metal-oxide-semiconductor) |
|---|---|---|
| Charge-to-voltage conversion | A few shared amplifiers; each row's charge is physically shifted ("bucket-brigaded") row-by-row to reach them | Every pixel has its **own** tiny amplifier |
| Readout | Charges shifted out row-by-row, then converted centrally | Per-pixel voltages read out row-by-row via a multiplexer; no charge shifting |
| Typical trade-off | Higher sensitivity, lower noise (fewer, better-matched amplifiers) | Faster readout, lower manufacturing cost (parallel per-pixel amplification, standard chip fabrication) |

Both deliver a per-pixel voltage proportional to accumulated charge. They differ in the electrical path and cost/performance, not in the photoelectric principle of §14.

**Linear-algebra view (a linear sensor).** "Voltage proportional to accumulated charge", with charge proportional to photons collected (scaled by quantum efficiency), makes the raw reading a **linear function** of light: double the photons, double the value; two light sources together read as the sum of their separate readings.

- This holds until a pixel saturates (cannot hold more charge) and up to the rounding of the **ADC** (analog-to-digital converter, the circuit that turns the voltage into an integer).
- It is what lets the whole optics-plus-sensor chain be written as one matrix, **y** = **A x** (§1, §3, §14).
- It is also why the first deliberately nonlinear step, gamma correction, happens only later in Week 3's pipeline.

> **Summary**
> - CCD shifts charge to a few shared amplifiers (sensitive, low noise); CMOS has an amplifier per pixel (fast, cheap).
> - Both give a voltage proportional to charge, so the raw reading is a linear function of light until saturation and rounding.
> - Remember: linear sensor means **y = A x** holds for the whole camera.
> - Next: when each row of pixels is exposed (§16).

---

## 16. Global Shutter vs. Rolling Shutter

There are two ways to time each pixel's exposure relative to readout:

- **Global shutter**: every pixel is exposed over the *exact same* time window, then all are read out. This avoids motion artifacts within a frame, at the cost of extra per-pixel circuitry to hold each pixel's charge while it waits to be read.
- **[Rolling shutter](https://en.wikipedia.org/wiki/Rolling_shutter)**: rows are exposed and read out one after another. It is cheaper and allows shorter per-row exposure, but different rows capture the scene at *slightly different moments*, which can cause skew or banding on fast-changing scenes.

**Concrete example: 60 Hz AC flicker.** (1 Hz = 1 cycle per second.) AC lighting in much of the world runs at 60 Hz, but the light itself flickers at **120 Hz**: twice per electrical cycle the lamp dims (without fully switching off) as the voltage crosses zero.

- A rolling-shutter camera scans its rows over a short time window. Different rows land at different phases of the 120 Hz flicker, so the frame shows dark/light horizontal bands that were not in the scene.
- A global-shutter camera exposes every row at once, so the whole frame is uniformly brighter or dimmer depending on where in the flicker cycle the shared exposure landed. There is no banding, because there is no row-to-row time offset to reveal the flicker's phase.

**An artifact turned into a sensor.** Sheinin et al. showed a rolling shutter's row-by-row timing can itself be used for sensing: each row samples the scene at a slightly different, precisely known instant, so a single rolling-shutter frame can be unpacked into a short sequence of instants (the lecture's example: 26 sub-frames recovered from 10 ms of one capture). A recurring computational-imaging theme: information hidden in an otherwise "broken" capture.

> **Summary**
> - Global shutter exposes all rows together; rolling shutter exposes row by row, so rows see different moments.
> - Remember: 120 Hz flicker under 60 Hz AC bands rolling-shutter frames but not global-shutter ones.
> - The row-by-row timing can be exploited as extra temporal information.
> - Next: the path from photons to a stored RAW image (§17).

---

## 17. From Photons to a RAW Image

The full chain from light to a stored **RAW image** (the sensor's near-unprocessed output):

1. **Photons** arrive at the pixel (their arrival times are random, which matters for noise).
2. The **photodiode** (§14) converts them to electrons, up to the quantum efficiency.
3. An **amplifier** multiplies the signal by a **gain** set by the **ISO** setting (Week 4 §2.5 builds ISO; for now: a higher ISO means a bigger multiplier).
4. An **ADC** rounds the amplified analog voltage to one of a finite set of integer levels. The number of levels is set by the **bit depth**: *b* bits give 2^*b* levels (12 bits: 4,096; 14 bits: 16,384; 8 bits: 256).
5. The result is the **RAW image**: one integer per pixel, typically 12–14 bits, one color channel per pixel (§14). A processed, display-ready **JPEG** typically keeps only 8 bits per channel after later pipeline steps (Week 3).

Each step can add randomness or error, which is the subject of the next section.

> **Summary**
> - Photons → electrons (photodiode) → amplified voltage (ISO gain) → integer levels (ADC, 2^*b* levels at *b* bits) → RAW image.
> - Remember: a RAW pixel is one integer, typically 12–14 bits; JPEG is typically 8.
> - Next: why the same scene does not give the same numbers twice: noise (§18).

---

## 18. Noise from Scratch: What It Is and the Five Sources

### 18.1 What noise is, and four words you need

**What noise is.** Photograph the same unchanging scene twice with the same settings, and a given pixel will not record exactly the same number. **Noise** is that random deviation of a measured value from the value you would "ideally" get (the **expected value** or **mean**: the average over a very large number of repeats). *Analogy:* weigh the same apple ten times on a kitchen scale and the readings jitter slightly around a central value. The central value is the signal; the jitter is the noise. A single reading is signal plus one random draw of jitter.

**Four vocabulary words**, used throughout the notes:

- **Variance (σ²)**: the average of the *squared* deviation from the mean. *Example:* readings 9, 10, 11 have mean 10, deviations −1, 0, +1, squared 1, 0, 1, so variance = (1 + 0 + 1)/3 ≈ 0.67. Squaring makes every deviation count positively and punishes big ones more.
- **Standard deviation (σ)**: √variance, the "typical size of the wobble" in the *same units as the pixel value*. In the example, σ ≈ 0.82.
- **Independent / uncorrelated**: one pixel's (or frame's) jitter tells you nothing about another's. Separate photon arrivals or separate readouts are independent. This matters because *variances of independent noise sources add* (Week 4 §3 derives and uses this).
- **SNR (signal-to-noise ratio)**: mean divided by standard deviation (the next sections build it into a formula). *Example:* mean 100 with σ = 10 gives SNR = 10; the noise is 10% of the signal.

### 18.2 Units: electrons versus digital numbers (DN)

A pixel collects *photo-electrons* (one absorbed photon frees at most one electron, §14). Noise is easiest to reason about in **electrons (e⁻)**. The ADC (§17) then converts the electron count into an integer **digital number (DN)**, the value stored in the RAW file, using a **conversion gain** *g* (DN per electron, set by the ISO gain): DN = *g* × electrons. Standard deviations convert the same way (σ in DN = *g* × σ in e⁻), so variances convert with *g*². Unless stated, the formulas below are in electrons.

### 18.3 The five sources, in the order the signal meets them (§17)

| Source | Physical cause | Variance (electrons²) | Depends on |
|---|---|---|---|
| **Photon shot noise** | Photons arrive at random moments, so the count in a fixed window varies | *N* = mean number of collected photo-electrons (*P·Qe·t*, the mean signal) | Signal and exposure time. Brighter or longer means *more* absolute noise but *less* relative noise |
| **Dark current noise** | Heat randomly frees electrons in the photodiode even with no light, indistinguishable from photo-electrons; their *count* is random too | *D·t*, where *D* is the mean dark-current rate (e⁻/pixel/s) | Exposure time and temperature (hotter means larger *D*); not light |
| **Read noise** | Random voltage fluctuations in the readout electronics when the pixel's charge is measured | *Nr*² (*Nr* is its RMS in electrons), **a fixed amount per readout** | Neither signal nor exposure time. Paid once *per read*, so *k* frames pay it *k* times |
| **Quantization noise** | The ADC rounds a continuous voltage to the nearest integer DN; the error is random-looking, uniform in ±½ step | Δ²/12 in DN² for a step of Δ DN (derivation below) | ADC bit depth and gain; not light |
| **Fixed-pattern noise** | Pixel-to-pixel manufacturing differences (gain, offset) | Not random jitter: a *fixed* per-pixel offset or gain error | The sensor itself; **identical from shot to shot** |

### 18.4 Two statistical shapes: Gaussian and Poisson

Many physical sources contribute (heat, electronics, amplifier gain, photon-to-electron conversion, pixel defects), but two statistical distributions dominate.

**[Gaussian noise](https://en.wikipedia.org/wiki/Gaussian_noise)**: from readout electronics, amplifier gain and other electronic jitter (the *read noise* above; quantization noise is also usually modeled this way). It is **additive** and **signal-independent**: every pixel gets a random value from the same bell curve, whatever its true brightness. A dark and a bright pixel are perturbed equally on average.

**[Photon (shot) noise](https://en.wikipedia.org/wiki/Shot_noise)**: from the random arrival timing of photons. *Analogy:* rain on a bucket. The average rate is steady, but how many drops land in exactly one second varies. Counts of randomly timed, independent events at a steady rate follow the **[Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution)**:

```
f(k; λ) = λᵏe⁻λ/k!
```

*Terms:* *k* is the number of events actually observed; *λ* is the average event rate (here the mean photon count; not a wavelength: this is the Poisson rate); *f* is the probability of seeing exactly *k*. Its key property: **variance equals mean**, so with mean *N* photons the standard deviation is

```
σ = √N
```

- *Example:* a pixel averaging 100 photo-electrons has σ = 10 (SNR = 10); one averaging 10,000 has σ = 100 (SNR = 100). A hundred times the light gives only ten times the noise, so SNR grows like √signal.
- Shot noise is **signal-dependent**: a brighter pixel has *more* absolute noise (√*N* grows) but proportionally *less* relative noise (√*N*/*N* = 1/√*N* shrinks). Doubling the light multiplies the noise only by √2.
- Shot noise is a property of *light itself*, so no sensor design can remove it.

### 18.5 Quantization noise: why the variance is Δ²/12

Suppose the true value falls uniformly anywhere within one rounding step of width Δ. The rounding error *u* is then uniform on [−Δ/2, +Δ/2] with probability density 1/Δ and mean 0, so its variance is the average of *u*²:

```
Var(u) = (1/Δ) · ∫ u² du  (u from −Δ/2 to +Δ/2) = (1/Δ)·(2·(Δ/2)³/3) = Δ²/12
```

*Example:* with Δ = 1 DN, σ = √(1/12) ≈ 0.29 DN, so quantization is rarely the limit unless the signal is only a few DN.

**Which of these can be reduced?**
- Dark current's *average* can be measured with the lens capped and subtracted (a **dark frame**), but its randomness (√(*D·t*)) cannot.
- Fixed-pattern noise can be measured and divided out, because it repeats.
- Shot, dark-current, read and quantization noise are fresh random draws every capture, so they **average down** when several frames are combined (Week 4 §3). Fixed-pattern noise does **not** average down: it is the same in every frame.

> **Summary**
> - Noise is the random jitter of a measured value around its mean; variance is its squared size, σ its typical size, and independent variances add.
> - Five sources: shot (variance *N*), dark current (*D·t*), read (*Nr*² per readout), quantization (Δ²/12), fixed-pattern (not random).
> - Remember: **shot noise has σ = √N**, so SNR grows like √signal; and quantization variance is **Δ²/12**.
> - Next: combine the random sources into one number, SNR (§19).

---

## 19. Signal-to-Noise Ratio (SNR)

**What problem this solves.** "Noisy" is vague; SNR gives one number for how trustworthy a pixel's reading is. Input: light level, exposure time, and the sensor's noise parameters. Output: one unitless ratio, larger meaning cleaner. *Analogy:* how clearly you hear a conversation over background chatter: speech loudness divided by chatter loudness.

**[Signal-to-noise ratio](https://en.wikipedia.org/wiki/Signal-to-noise_ratio)** is the mean pixel value divided by its standard deviation (§18.1):

```
SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²)
```

**Term-by-term:**
- *P* — incident photon flux (photons per pixel per second); fixed by scene brightness and optics.
- *Qe* — quantum efficiency (§14); fixed by the sensor.
- *t* — exposure time (also called **shutter speed**; Week 4 §2); you control it.
- *D* — dark current (electrons per pixel per second with no light); fixed by the sensor. Its electron count is randomly timed like photon arrivals, so its variance equals its mean *D·t* (§18.3).
- *Nr* — read noise (RMS electrons from the readout electronics, once per readout); fixed by the sensor.

**Why it has this shape.** The numerator *P·Qe·t* is the mean photo-electron count, the *signal*. Inside the square root, that same term reappears as the *shot-noise variance* (§18.4's √*N*, squared back into a variance), next to the other two variances *D·t* and *Nr*². The formula covers only the random sources: quantization noise (negligible when the signal spans many DN) and fixed-pattern noise (not random) are left out.

**Linear-algebra view (noise as an additive vector, and why variances add).** The full measurement model is **y** = **A x** + **n**: the ideal linear measurement (§15) plus a noise vector **n** with one random entry per pixel.

- Independent noise sources are **uncorrelated**, and uncorrelated random variables behave like **orthogonal** vectors: the cross terms in Var(n₁ + n₂) vanish, so variances add the way squared lengths add in Pythagoras's theorem. That is why the SNR denominator is the square root of a *sum* of variances (shot + dark + read), not a sum of standard deviations.
- Each pixel's noise is independent of its neighbors', so the noise **covariance matrix** is **diagonal**. For shot noise the diagonal entries equal the mean signal itself (Poisson), which is what "signal-dependent" means in matrix terms.
- Denoising (Week 3) and inverting **y** = **A x** + **n** (Weeks 5–6) both start from this model.

**Scientific sensors** (e.g. cooled to around −100°C for astronomy or microscopy) minimize *D* and *Nr* by aggressive cooling and low-noise electronics, leaving nearly only the shot-noise floor set by *P·Qe·t* itself, the one term no engineering can remove, since it comes from the quantum randomness of photon arrival.

> **Summary**
> - SNR is signal over noise standard deviation, with shot, dark-current and read variances added under the square root.
> - Remember: **SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²)**; doubling exposure time improves SNR by about √2 when shot noise dominates.
> - Independent noise adds like orthogonal vectors: **y = A x + n**, with a diagonal covariance.
> - Next: how SNR and bit depth limit the range of brightness a sensor can represent (§20).

---

## 20. Dynamic Range and Bit Depth

**[Dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)** was introduced in Week 1 §15 for the human eye (~14 orders of magnitude adapted, ~5 instantaneous). For a sensor the definition is the same: the ratio between the brightest and darkest signal it can represent.

A sensor adds a second, digital limit on top of the physical one: **bit depth** (§17), the number of discrete levels the ADC can output. A sensor's *achievable* dynamic range is capped by whichever is smaller:

- the physical **noise floor** (§18–§19): signals below the noise cannot be told from it; or
- the digital **quantization step** set by bit depth (e.g. 12–14 bits for RAW, 8 for JPEG).

*Where this goes next:* Week 4 §7 and §13.1 use dynamic range to motivate HDR imaging and tone curves.

> **Summary**
> - Dynamic range is the brightest-to-darkest ratio a sensor can represent.
> - Remember: it is capped by the smaller of the noise floor and the bit-depth quantization step.
> - Next: the lecture's own pointer to what happens to RAW data (§21).

---

## 21. Looking Ahead: The Image Processing Pipeline

This lecture's closing slide names what comes next: **RAW images → demosaicking → denoising → deblurring → white balancing → gamma correction → compression**, the **image signal processing (ISP)** pipeline that turns the raw, single-channel-per-pixel, noisy sensor output of §14–§19 into the finished color photo a viewer sees. PS2's remaining tasks (linear, chrominance-smoothed and Malvar–He–Cutler high-quality demosaicing; gamma correction; Gaussian, median, bilateral and non-local-means denoising) live there and are covered in Week 3, not here. Week 2 has covered the optics (§1–§13) and raw sensing (§14–§20) stages that come *before* any of that.

Week 3 covers more than the pipeline: before the ISP stages it builds the color science underneath them (spectral sensitivity, CIE color matching, XYZ/RGB spaces, the xy chromaticity diagram, gamuts, deepening Week 1 §6), and past the pipeline it covers gamut mapping, JPEG compression, and a one-slide preview of deconvolution ahead of Weeks 5–6.

> **Summary**
> - Week 2 covered optics (pinhole, lens, aperture, defocus, depth of field, diffraction, bokeh) and raw sensing (pixel, CMOS/CCD, shutters, noise, SNR, dynamic range).
> - The sensor's output is a noisy, single-channel-per-pixel RAW image.
> - Next: Week 3 turns RAW into a color photo (color science, demosaicking, denoising, JPEG).

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check
If you can explain, in your own words, *why* a wider aperture (smaller f-number) simultaneously gathers more light, produces shallower depth of field, and moves you further from (not closer to) the diffraction limit — using only the words "circle of confusion," "f-number," and "numerical aperture" — you've understood the core trade-off of Week 2.

A second check, for the focal-length/sensor-distance distinction (§5.2–§5.3, §9.1): if a friend asked you "what's the difference between focal length and sensor distance, and why does moving the sensor change what's in focus?", you should be able to answer using only the words "intrinsic," "setup," and "thin lens equation" — without needing to look anything up.

A third check, for sensor noise (§18): if a friend asked you why doubling the exposure time only improves signal-to-noise ratio by about 1.41× (√2) rather than doubling it outright, you should be able to answer using only the words "Poisson," "shot noise," and "square root" — without needing to look anything up. (Exposure itself — the setting being doubled here — is built from scratch in Week 4 §2.)
