# CSC2529 Computational Imaging — Week 2 Study Notes

**Topic:** Digital Photography I — Ray Optics, Aperture, Sensor
**Source:** Lecture 2 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 2 ("PS2," a TA problem session covering HW2), Task 1 only (f-number / depth of field / circle of confusion); reading: Marc Levoy, Stanford CS178 "Digital Photography" course.
**Scope:** Announcements and the guest-colloquium plug skipped — notes start from "Let's say we have a sensor…". PS2's Tasks 2–3 (demosaicing methods, gamma correction, denoising) belong to the image-signal-processing pipeline the lecture itself defers to "Next" — that material is Week 3's, not repeated here.
**Exam note:** this lecture is unusually formula-dense, and several of its formulas reuse the same handful of symbols with quietly-shifted meanings across sections (flagged explicitly below wherever it happens) — the most common source of confusion on this material is mixing up which symbol means what in which formula, not the algebra itself.

---

## 0. Why doesn't a bare sensor take a picture?

Point a digital sensor (the electronic chip that converts light into an electrical signal — introduced as the camera's "retina" in Week 1 §1, §4) at a scene with nothing in between, and you get nothing usable: every point on the sensor receives light from *every* point in the scene at once, all overlapping. There is no optical element separating "light from here" from "light from there," so the sensor just measures one blurred average brightness everywhere — not an image.

That "one blurred average" is not perfectly flat, however — it is a heavily blurred version of the scene, not a single uniform value. A sensor location's measured brightness is a weighted sum of light arriving from every scene point, and the weight is not equal for every point: light landing nearly head-on (close to perpendicular to the sensor surface) contributes more than light arriving at a shallow, grazing angle (a cosine falloff for the angle of incidence), and light from a nearer scene point contributes more than light from a farther one (the same inverse-square-law falloff that makes a light source look dimmer the farther away it is, per §3). Because each sensor location sits at a slightly different position, it is dominated by a slightly different — though heavily overlapping — mix of the scene. Only the coarsest, lowest-spatial-frequency shapes survive this averaging (broad regions of light vs. dark, large blobs of color); anything with fine spatial detail washes out completely. The result looks like a photo taken with extreme, maximal defocus blur: a smear of the scene's biggest shapes, not a flat gray field.

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

---

## 2. Pinhole Size: A Sharpness/Light Trade-off, and the Diffraction Limit

An *ideal* pinhole is infinitesimally small (a true single point), but that's physically impossible to manufacture, and even if it were possible it would let through zero light. So every real pinhole has some nonzero diameter, and that diameter turns out to control image quality from two directions at once — one predicted by the ray optics of §1, the other requiring a genuinely new idea.

**Direction 1 — geometric blur (ray optics still applies).** A pinhole with nonzero diameter doesn't pass just *one* ray per scene point — it passes a small *cone* of rays (every ray from that point that happens to hit somewhere within the finite opening). Each of these rays lands at a slightly different spot on the sensor, so a single scene point no longer projects to a single sensor point — it projects to a small blurred disc the same size as the pinhole opening. **The larger the pinhole, the blurrier the image.** This predicts that shrinking the pinhole should sharpen the image indefinitely — but it doesn't.

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

### 4.2 Intrinsic lens properties vs. setup properties

This is the single most useful distinction for reading every formula in the rest of this lecture without confusing yourself:

- **Intrinsic to the lens** (fixed the moment the glass is ground; you cannot change it without physically swapping the lens, or, for a zoom lens, changing the zoom setting): the **focal length *f***, and — once §7 introduces it — the lens's maximum aperture diameter and its aberration characteristics (§6).
- **A property of the scene, not the lens at all**: the **object distance *S***, i.e., however far away the thing you're photographing happens to be. Nothing about the lens sets this; it's just wherever the subject is standing.
- **A property of the setup / how the lens interacts with the sensor**: the **sensor distance *S′***. This is *not* fixed by the lens alone — it's a mechanical choice. Turning a lens's focus ring physically moves internal lens elements, which changes the effective distance from the lens's optical center to the sensor. *S′* is the thing a focus mechanism (manual ring or autofocus motor) actively adjusts.

The thin lens equation `1/S + 1/S' = 1/f` is precisely the constraint linking these three. For a *fixed* focal length *f* (you can't change that) and a *chosen* object distance *S* (wherever your subject is), there is exactly **one** value of *S′* that puts it in sharp focus — the value the equation demands. **"Focusing" means physically turning the focus ring until *S′* reaches that value.** Get *S′* right for your chosen *S*, and the image is sharp; leave it at the wrong value, and you get the defocus blur that §5 formalizes.

### 4.3 The inverse relationship: how moving the lens changes what's in focus

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

When *O = S*, that scene point's rays converge exactly at the sensor plane, and it renders as a sharp point. When *O ≠ S*, the thin lens equation says those rays actually want to converge somewhere *other* than the sensor plane — either before it (if the true object is farther than the focused distance) or after it (if closer) — so by the time they reach the actual, fixed sensor, they've re-diverged into a small blurred disc instead of a point. This blurred disc is the **circle of confusion**, and its exact size is derived in §9.2.

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

**Notation trap, worth flagging explicitly:** the lecture's own slide writes this with the symbol *O* in place of *S* (i.e. `DOF = 2εO/(mD)`) — but as the derivation above shows, the distance that belongs in this particular formula is the *focused* distance (§9.1's *S*), since depth of field is a range *centered on the focus plane*, not a property of any one actual object's distance. Read that slide's "*O*" as meaning *S* specifically inside the DOF formula; §9.2's circle-of-confusion formula is the one where *O* genuinely means "actual object distance," a distinct, independent variable from *S*.

**Why a small f-number gives shallow depth of field.** Because *c* (§9.2) grows in proportion to aperture diameter *D*, and *D* = *f*/*N* (§8, rearranged), a *smaller* f-number (bigger aperture, more light) makes both *c* and the DOF-shrinking factor *mD* larger — so the acceptable-blur range shrinks. This is the classic depth-of-field trade-off: more light (small *N*) inherently costs a shallower zone of acceptable sharpness.

> **Worked example, from lecture (method only — not solved here).** For a Canon 5D Mark III with f = 50 mm, N = 2.8, focused at 5 m, and a 7.5 µm pixel pitch, §9.2's formula gives a curve of circle-of-confusion size (in pixels) vs. object distance. The lecture's own exercise is: "using the graph [of *c* vs. distance], what is the depth of field?" — i.e., read off the distance range where the curve stays under the allowed-blur threshold. Per this project's policy of never computing the specific numeric answers a homework/exercise asks the student to derive, that range is intentionally left uncomputed here — but the *method* is exactly §9.2's formula, evaluated across a range of *O* and compared against a fixed pixel-based threshold *ε*.

### 9.4 Hyperfocal distance

The **hyperfocal distance**, *H*, is the specific focus distance *S* that pushes the *far* edge of the depth-of-field range (§9.3) all the way out to infinity. Deriving it directly from §9.2's circle-of-confusion formula: as the actual object distance *O* → ∞, the ratio |*O* − *S*|/*O* → 1 (the finite *S* becomes negligible next to an infinite *O*), so the circle of confusion an object at infinity would show, if focused at *S* = *H*, is simply *c*<sub>∞</sub> = *m·D* (using the magnification evaluated at that focus distance). Setting this equal to the fixed acceptable threshold and solving for *S* = *H* (using *D* = *f*/*N* from §8, and dropping *f* itself as negligible next to the much larger *H*) gives:

```
H = f² / (N·c)
```

where *c* here is the fixed acceptable-circle-of-confusion threshold (the same role §9.3 calls *ε* — the lecture reuses the letter *c* for this constant *and* for §9.2's general, object-distance-dependent circle-of-confusion size; in this one formula, it means the fixed threshold only). Focusing at the hyperfocal distance means everything from roughly *H*/2 out to infinity satisfies the depth-of-field threshold simultaneously — a classic landscape-photography technique for maximizing usable in-focus range without stopping the aperture down so far that diffraction (§2, §10) starts to matter.

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

---

## 12. CCD vs. CMOS

There are two dominant sensor architectures, differing in *how* accumulated pixel charges get converted to a readable signal and read out:

| | **[CCD](https://en.wikipedia.org/wiki/Charge-coupled_device)** (charge-coupled device) | **[CMOS](https://en.wikipedia.org/wiki/CMOS_sensor)** (complementary metal-oxide-semiconductor) |
|---|---|---|
| Charge-to-voltage conversion | A small number of shared amplifiers, with each row's charge physically shifted ("bucket-brigaded") row-by-row to reach them | Every pixel has its **own** tiny amplifier built in |
| Readout | Charges shifted out row-by-row, then converted centrally | Per-pixel voltages read out row-by-row via a multiplexer, no charge-shifting needed |
| Typical trade-off | Higher sensitivity, lower noise (fewer, more carefully-matched amplifiers) | Faster readout, lower manufacturing cost (parallel per-pixel amplification, standard chip-fabrication processes) |

Both approaches ultimately deliver a per-pixel voltage proportional to accumulated charge; they differ in the electrical path and cost/performance trade-offs for getting there, not in the underlying photoelectric sensing principle of §11.

---

## 13. Exposure and ISO

**[Exposure](https://en.wikipedia.org/wiki/Exposure_(photography))** (shutter speed) is simply how *long* the sensor is allowed to accumulate photo-generated charge before readout — typical values range from small fractions of a second (1/250 s, freezing motion) to many seconds or a manually-held "bulb" exposure (as long as the shutter button stays pressed) for very dim scenes, directly recalling HW1's own 15–60 s pinhole-box exposures. Exposure, together with aperture (§8) and ISO (below), jointly determines total light collected.

**[ISO](https://en.wikipedia.org/wiki/Film_speed)** ("film speed," a name carried over from chemical film) is an **analog gain** applied to the sensor's signal *before* it reaches the analog-to-digital converter (ADC, §14). Raising ISO does not make the sensor collect more photons — it electrically amplifies whatever charge was collected, boosting a dim signal up into a usable digital range. Critically, this amplification boosts noise right along with signal (indeed, it amplifies certain noise sources, like read noise, disproportionately relative to the fundamental photon-counting noise of §16) — so raising ISO is a way of trading *cleanliness* for *brightness* on a fixed amount of collected light, not a way of gathering more light in the first place.

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
