# CSC2529 Computational Imaging — Week 1 Study Notes

**Topic:** Human Visual System
**Source:** Lecture 1 slides (D. Lindell, CSC2529, Fall 2026), Oliva/Torralba/Schyns 2006 "Hybrid Images" (SIGGRAPH)
**Scope:** Logistics slides skipped; notes start from "The Human Visual System."
**Order differs from the slides, on purpose.** Each topic comes after the ideas it needs. Eye optics (anatomy, focusing, focusing errors) come before the retina; the retina and color come before the eye-vs-camera comparison; angles and acuity come before the display and field-of-view examples; stops (a log scale) come before dynamic range; spatial frequency, contrast and the CSF come before the Fourier transform; convolution comes before frequency-domain filtering; and hybrid images, which use all of these, come after them. Deconvolution (the reverse of blurring) is an optional side branch placed last, and the lecture's summary slide closes the file. Every numbered section ends with a Summary box.

---

## 1. Why start a computational imaging course with the human eye?

Computational imaging is about designing a *whole pipeline*: optics → sensor → computation. The output is an image (or other information) that a human or an algorithm will use.

Before you can design that pipeline well, you need a model of the "detector" the image is ultimately for: human vision. The eye is also a physical instrument built from optics (cornea, lens) and sensing (retina), so comparing it to a camera is the fastest way to build intuition for both.

The lecture frames the field with a simple triangle:

> **Computational Imaging = Optics + Sensing + Computation**

Traditional cameras keep these three separate: a fixed lens, a passive sensor, and image processing bolted on afterward. Computational imaging designs them *together*. For example, a **coded aperture** (a specially shaped opening in the lens, Week 4) is chosen jointly with the software that later sharpens the picture.

> **Summary**
> - Computational imaging = optics + sensing + computation, designed *together*.
> - The eye is both the detector many images are made for and a physical instrument built from optics and a sensor, so it is the best first model.
> - *Next:* §2 walks through the eye's anatomy.

---

## 2. Anatomy of the Human Eye

Cross-section, front to back:

| Structure | Role |
|---|---|
| **Cornea** | The clear, curved front surface. Does *most* of the eye's fixed focusing power (it's a strong, non-adjustable lens). |
| **Aqueous humour** (anterior chamber) | Clear fluid between cornea and lens; maintains eye pressure/shape. |
| **Iris / Pupil** | The iris is the colored muscle ring; the pupil is the hole in its middle. The iris contracts/dilates the pupil to control how much light enters — this is the eye's **aperture**. (*Aperture* is camera terminology for "the opening that controls how much light gets let in": a wider opening lets in more light, a narrower one lets in less — exactly like your pupil widening in the dark and shrinking in bright light. Every camera lens has one, usually made of adjustable overlapping blades rather than a muscle.) |
| **Lens** | A flexible, adjustable lens behind the iris. Fine-tunes focus by changing shape (see *accommodation* under Key terminology below). |
| **Ciliary muscle / zonular (suspensory) fibers** | Muscles and fibers attached to the lens that squeeze or relax it to change its shape/focal power. |
| **Vitreous humour** | Clear gel filling the main eyeball cavity, behind the lens. |
| **Retina** | The light-sensitive "**sensor**" layer at the back of the eye. (In a digital camera, the *image sensor* is the electronic chip that sits where photographic film used to go — it converts incoming light into an electrical signal that becomes a digital image. The retina does the same biological job.) |
| **Choroid** | A blood-vessel-rich layer behind the retina; supplies oxygen/nutrients and absorbs stray light (like the black interior paint of a pinhole camera (a light-tight box with a tiny hole instead of a lens; Week 2). This is *literally why HW1 has you paint the box interior black*: to stop internal reflections from ruining contrast). |
| **Sclera** | The white, tough outer shell of the eyeball — structural support, like a camera body. |
| **Fovea** | A small pit in the retina, directly behind the pupil, packed with **cones** (the retina's color-sensing light detectors). This is where sharp, color vision happens. |
| **Optic disc** | The spot where the optic nerve and retinal blood vessels exit the eye. It has *no* photoreceptors — this is your **blind spot**. |
| **Optic nerve** | Carries the electrical signal from retina to brain. |

**Key terminology:**
- *Accommodation* — the eye's ability to change focus by physically changing lens shape (ciliary muscle contracts → lens gets rounder/more powerful, for near focus).
- *Emmetropia* — a normal-sighted eye, whose focus lands exactly on the retina.

> **Summary**
> - The eye is a camera-like instrument: cornea and lens focus light, the iris/pupil is the adjustable opening (the **aperture**), and the retina is the light-sensing layer (the **sensor**).
> - Remember the mapping: pupil = aperture, retina = image sensor, fovea = the small high-detail patch at the center of the retina.
> - The blind spot is where the optic nerve leaves the eye: no light detectors there.
> - *Next:* §3 and §4 cover how the eye focuses and how focusing fails; §5 looks inside the retina.

---

## 3. Accommodation: How the Eye Focuses

**Accommodation** is how the eye refocuses: the ciliary muscle changes the lens's shape (and so its bending power) to bring objects at different distances into sharp focus, near or far. Analogy: turning the focus ring on a camera lens, except the "ring" is a muscle squeezing a flexible lens.

Your accommodation *range* (the span of distances you can bring into sharp focus) shrinks with age:
- **At ~16 years old:** can accommodate from about **8 cm to infinity**.
- **At ~50 years old:** typically down to about **50 cm to infinity** — the near range is largely lost.

This age-related loss of near-focus ability is called **presbyopia** (why people need reading glasses as they age) — the lens becomes stiffer and the ciliary muscle can no longer deform it enough for close focus.

> **Summary**
> - Accommodation = changing lens shape to refocus between near and far objects.
> - The range shrinks with age: ~8 cm to infinity at ~16 years, ~50 cm to infinity at ~50 years (presbyopia, from a stiffening lens).
> - *Next:* §4 covers what happens when the eye's focus misses the retina; §11 returns to accommodation as a weak depth cue.

---

## 4. Refractive Errors

Light entering the eye is bent (**refracted**) by the cornea and lens so that rays from one point meet again at one point, ideally on the retina. Four categories are defined by *where the rays converge relative to the retina*:

| Condition | What happens | Correction |
|---|---|---|
| **Emmetropia** | Normal — rays focus exactly on the retina | None needed |
| **Myopia** (nearsightedness) | Rays focus *in front of* the retina (eyeball too long / cornea too curved) | **Concave (diverging)** lens |
| **Hypermetropia / Hyperopia** (farsightedness) | Rays focus *behind* the retina (eyeball too short) | **Convex (converging)** lens |
| **Astigmatism** | Cornea is irregularly curved (not spherical), so rays don't converge to a single point at all | **Cylindrical** lens (corrects only the irregular axis) |

This is a nice concrete example of "optics can be broken in a specific, geometrically describable way, and correction is just adding a compensating optical element" — the same logic (add optics or add computation to compensate for a known aberration) will reappear constantly in computational imaging.

> **Summary**
> - Refractive errors are focus misses: rays converge in front of the retina (myopia), behind it (hyperopia), or not to a single point (astigmatism).
> - Each is fixed by adding a compensating optical element: concave lens, convex lens, cylindrical lens.
> - The pattern "add optics or computation to cancel a known aberration" recurs throughout the course.
> - *Next:* §5 looks inside the retina, the surface the rays are supposed to land on.

---

## 5. The Retina: Rods and Cones

The retina is a layered neural circuit, not just a passive light-sensitive film:

**Light path through the retina layers (light enters from the *inner* side first, counter-intuitively):**

Light → Ganglion cells → Bipolar cells (+ horizontal/amacrine cells for lateral processing) → **Photoreceptors (rods & cones)** → Retinal pigment epithelium → (absorbed)

So light actually passes through several neuron layers *before* hitting the photoreceptors, which sit at the very back, pointed away from incoming light. The photoreceptor signal then travels back forward through the bipolar and ganglion cells, whose axons bundle into the optic nerve.

**Two types of photoreceptors:**

| | Rods | Cones |
|---|---|---|
| Count | ~120 million | ~6 million |
| Sensitivity | Very high — used in **low light / night vision** | Lower — need brighter light |
| Color | Colorblind (one type only) | 3 types (color vision) |
| Location | Spread across the periphery of the retina | Densely packed in the **fovea** (center) |
| Acuity | Low spatial resolution | High spatial resolution |

**Why this matters:** your sharp, colorful vision only exists in a *tiny* central region (the fovea) that you're constantly darting your eyes around in rapid jumps (**saccades**) to sample — you don't actually perceive the world in uniform high resolution the way a camera sensor captures a frame.

This non-uniform, foveated sampling is a recurring theme that resurfaces later when the course discusses light-field/foveated displays and compressive/adaptive sensing.

**A key measurement from the lecture** (Roorda & Williams, 1999, *Nature*): imaging the living cone mosaic at the center of the fovea, individual cones sit about **0.5 arcminutes** apart. An arcminute is 1/60th of a degree of visual angle. In other words, 0.5 arcmin is the finest "sampling grid" your retina offers at the very center of vision.

> **Summary**
> - The retina has two detector types: ~120 million rods (very light-sensitive, no color, spread over the periphery) and ~6 million cones (color, fine detail, packed into the fovea).
> - Light passes through several neuron layers before it reaches the photoreceptors at the back.
> - Sharp color vision exists only in a tiny central patch; you build the rest of the scene by moving your eyes.
> - Remember the number: cone spacing in the fovea is about 0.5 arcmin.
> - *Next:* §6 explains how three cone types turn light into color; §8 and §18 reuse the 0.5 arcmin figure.

---

## 6. Color Perception

Visible light is a narrow slice (~400–700 nanometers; a nanometer, nm, is a billionth of a meter, and a light wave's *wavelength* is the distance over which it repeats) of the full electromagnetic spectrum, between ultraviolet and infrared.

Color vision comes from **three types of cones**, each with a different (overlapping) sensitivity curve over wavelength:

- **S (short)** cones — peak near ~440 nm (bluish)
- **M (medium)** cones — peak near ~545 nm (greenish)
- **L (long)** cones — peak near ~565 nm (yellowish-red)

Note the M and L curves overlap *heavily* — so the "green" and "red" cones respond to much of the same light, and this is a key reason color is represented as a 3-number (tristimulus) space rather than measuring wavelength directly: **your eye doesn't measure wavelength, it measures three overlapping weighted sums of the incoming spectrum.**

Two physically different spectra that produce the same 3 cone responses look *identical* to you — this phenomenon is called **metamerism**, and it's the whole reason RGB displays/cameras work at all (they don't need to reproduce the true spectrum, just match your 3 cone responses).

**Linear-algebra view (cone responses as inner products):** sample a light's spectrum at N wavelengths and it becomes a vector **s** with N entries (the power at each wavelength). Each cone type's sensitivity curve, sampled at the same N wavelengths, is another N-entry vector, and that cone's response is the **inner product** (dot product) of the two: multiply wavelength by wavelength, then add up. Stack the three sensitivity vectors as the rows of a 3×N matrix **C**, and the whole eye's color measurement is one matrix–vector product, **c** = **C s**, giving a 3-entry vector (L, M, S). That is a **linear map from N dimensions down to 3**: a huge amount of spectral detail is squashed into three numbers.

**Linear-algebra view (metamerism as a null space):** the **null space** of **C** is the set of spectrum-difference vectors **n** with **C n** = 0 — changes to the spectrum that no cone responds to. Any two spectra **s** and **s** + **n** give the same (L, M, S), so they are metamers; metamerism is exactly "differs by a null-space vector." The null space is big: with, say, samples every 10 nm across 400–700 nm (N = 31), a rank-3 matrix leaves a 31 − 3 = 28-dimensional null space, so most spectral detail is invisible. (Real spectra must also stay non-negative, which limits which null-space vectors you can actually add, but the dimension count shows why metamers are common.) Because (L, M, S) lives in a 3D vector space, any invertible 3×3 matrix gives an equally complete **change of basis** for color. That is what XYZ and RGB color spaces are, and Week 3 builds those 3×3 conversions explicitly.

> **Summary**
> - Three cone types (S, M, L) each report one weighted sum of the light spectrum, so the eye reports 3 numbers, not a wavelength.
> - Different spectra with the same 3 numbers are **metamers**; this is why RGB displays and cameras work.
> - Linear-algebra view to remember: **c** = **C s**, a 3×N matrix squashing N spectral samples to 3, with a large null space.
> - *Next:* §7 compares the whole eye with a camera, including how a camera gets color.

---

## 7. Eye vs. Camera

The lecture draws a direct structural analogy:

| Eye | Camera |
|---|---|
| Cornea + lens | Lens |
| Iris/pupil | Aperture |
| Retina | Image sensor |
| Fovea (non-uniform density, denser in center) | Uniform pixel grid |
| 3 cone types, irregularly interleaved | Bayer color filter array (regular RGGB mosaic) |

A digital camera sensor is actually colorblind on its own — each individual light-sensing cell (a **pixel**, short for "picture element") can only measure *brightness*, not color; it has no way to tell what wavelength of light it absorbed, only how much light hit it. To get color, manufacturers glue a **Bayer color filter array** directly on top of the sensor: a physical grid of tiny red, green, and blue filters, with exactly **one filter sitting over each individual pixel**.

**Every single pixel is single-color, not multi-color.** A pixel under a green filter only ever measures the green component of the light hitting that spot — it has *no* red or blue information at all, because the filter physically blocked those wavelengths before they reached it. What *is* multi-color is the grid as a whole: the filters are arranged in a repeating 2×2 tile — one red, two green, one blue — across the array of individually single-color pixels ("**RGGB**," green doubled because human vision is most sensitive to green, per §6's cone curves). **"RGGB" describes the mosaic pattern of the pixel grid, not any property of a single pixel** — no individual pixel is ever itself "RGGB."

Because each pixel only ever records one channel, the full-color image you eventually see — where every pixel appears to have a red, green, *and* blue value — isn't what the sensor directly measured. It's a **reconstruction**: for each pixel, the two channels it didn't measure are estimated by looking at its neighboring pixels (which, thanks to the repeating tile, measured different colors) and interpolating between them. This estimation step is called *demosaicking* (Week 3) — it means two-thirds of every pixel's RGB value in a final photo is computed, not measured.

**Linear-algebra view (the Bayer mosaic as a linear operator):** stack the "true" full-color image into one long vector with 3 entries per pixel (R, G, B), so 3·P entries for P pixels. The sensor records one number per pixel, so its raw output is a P-entry vector. The mosaic is a P×3P **linear operator**: each row has a single 1 that picks out whichever channel that pixel's filter lets through, and 0 everywhere else. This matrix has far fewer rows than columns, so like the cone matrix in §6 it has a large **null space** (any change to the channels a pixel did *not* measure is invisible to it). Demosaicking therefore cannot simply invert the matrix. It has to bring in extra assumptions, such as "neighboring pixels have similar colors," to choose one full-color image among all those consistent with the measurement (Week 3).

Two important **disanalogies** to remember (both matter again for demosaicking in Week 3 and for adaptive sampling schemes later):
1. The retina's cone mosaic is **irregular/random**, not a neat repeating grid like a camera's Bayer pattern.
2. Sampling density is **non-uniform** (dense at the fovea, sparse at the periphery); a camera sensor samples uniformly across the whole frame.

> **Summary**
> - Eye to camera: cornea + lens = lens, pupil = aperture, retina = sensor, cones = color filters.
> - Each camera pixel measures one color only (Bayer RGGB mosaic); full-color pixels are *estimated* from neighbors (**demosaicking**, Week 3), so two-thirds of each final pixel's RGB value is computed.
> - Linear-algebra view to remember: the mosaic is a P×3P selection matrix with a large null space, so it cannot simply be inverted.
> - The eye differs in two ways: its cone mosaic is irregular, and its sampling density is non-uniform (dense fovea, sparse periphery).
> - *Next:* §8 turns the eye's angular resolution into numbers.

---

## 8. Visual Angle and Visual Acuity

**Visual angle** is the angular size an object subtends at your eye — it depends on *both* the object's physical size and its distance, not size alone. It's measured in degrees, or in smaller units of **arcminutes** (1° = 60 arcmin) and arcseconds (1 arcmin = 60 arcsec).

- **20/20 vision** (the "normal" acuity reference) corresponds to being able to resolve detail at about **1 arcminute** of visual angle.
- The **Snellen chart** (the classic eye-test letter chart) is built around this: each letter's individual strokes are designed to subtend 1 arcminute at the standard test distance when you can *just barely* read that row, and the whole letter subtends 5 arcminutes.

**Small-angle shortcut, with a number.** For small angles, an object's size is about distance × angle, with the angle in *radians* (a full turn is 2π radians, so 1 arcmin = (1/60)·(π/180) ≈ 2.9 × 10⁻⁴ rad). At the standard 20-foot (≈ 6 m) test distance, a 1 arcmin detail is about 6000 mm × 2.9 × 10⁻⁴ ≈ 1.7 mm across. (The exact trigonometric version of the same idea comes next.)

So "acuity" is fundamentally a statement about the smallest *angle* your visual system can resolve — not a raw distance or pixel count. This angular framing is what lets you compare, e.g., a phone screen 30cm from your face to a movie screen 10m away on equal footing.

> **Summary**
> - **Visual angle** is how big something looks, set by both its size and its distance: 1° = 60 arcmin, 1 arcmin = 60 arcsec.
> - 20/20 vision resolves about 1 arcmin; for small angles, size ≈ distance × angle (radians).
> - Acuity is a statement about angle, not distance or pixel count.
> - *Next:* §9 turns this angle into a pixel size and a dpi for a screen.

---

## 9. Retina Displays — Worked Example

This is the lecture's worked example of turning the acuity idea (§8) into a concrete engineering number, using basic trigonometry. A **pixel** here is one dot of a screen.

**Setup:** if the eye can just resolve a visual angle of α (≈1 arcmin, from §8), and the viewer sits at distance *d* from a screen, what is the physical size *p* of the smallest resolvable feature (pixel) on that screen?

**What problem this solves.** It converts an angle your eye can resolve into a physical size on a screen, so a display maker knows how small pixels need to be. Input: viewing distance *d* and angle α. Output: pixel size *p*. Analogy: a coin held at arm's length covers a small angle, and the same coin across a room covers a smaller one; this formula runs that relationship backwards from angle to size.

**Formula:**

```
p = 2 · d · tan(α / 2)
```

*(derivation intuition: the resolvable feature subtends a small angle α at the eye; draw the right-triangle from eye to the two edges of that feature at distance d — half the feature width is d·tan(α/2), so the full width is 2d·tan(α/2))*

**Worked numbers from lecture (Steve Jobs' "Retina Display" claim):** for a tablet viewed at **12 inches**, with α = 1 arcminute:

```
p = 2 × 12" × tan(0.5 arcmin) ≈ 0.0035"
```

**dpi is just *p* turned upside down.** *p* is a *length* — how physically big one resolvable pixel is (in inches). **dpi** ("dots per inch") is a *density* — how many of those pixel-widths fit side by side into one inch. Since *p* is already "inches per pixel," dpi is just its reciprocal:

```
dpi = 1 inch / p
```

Plugging in: 1 / 0.0035 ≈ **286 dpi**. It isn't a separately measured quantity — it's the exact same fact about pixel size, just flipped from "how big is one pixel" into "how many pixels fit in an inch," because "286 dots per inch, bigger is sharper" is a more intuitive number to compare screens by than "0.0035 inches, smaller is sharper."

(*dpi* is historically a *printing* term, since a printer deposits ink dots on paper. The more precise screen term is **ppi**, pixels per inch. The lecture and this course treat the two as interchangeable.)

**≈ 286 dpi** is the density at which pixels become individually unresolvable at 12 inches. The marketing claim was **300 dpi**, slightly above that threshold (300 > 286). So the marketing number is a real, checkable physical claim, and it holds up with a small safety margin.

**Why this generalizes:** how many pixels fit inside your finest-detail patch depends entirely on viewing distance. A screen that is "retina" at 12 inches looks pixelated at 3 inches and is wastefully over-detailed at 3 meters. The same physical image can look sharp or blurry depending on distance, and that is the effect hybrid images exploit (HW1 Task 3 asks you to compute it for a printed photo at two viewing distances).

> **Summary**
> - Formula to remember: **p = 2·d·tan(α/2)**, the physical size of the smallest resolvable feature at distance *d* for resolvable angle α.
> - **dpi = 1 / p**, so dpi is just pixel size flipped into pixel density; at 12 inches and 1 arcmin that gives ≈ 286 dpi, just under the 300 dpi claim.
> - What counts as "sharp enough" depends on viewing distance, not on the screen alone.
> - *Next:* §10 covers the eye's field of view; §16 turns "detail vs. distance" into spatial frequency.

---

## 10. Visual Field / Field of View (FOV)

- **Monocular FOV** (one eye): ~190°
- **Binocular FOV** (both eyes overlapping): ~120°
- **Vertical FOV**: ~135°

This matters directly for designing displays (e.g., "how important is FOV for immersive VR?" — a wide FOV headset is trying to fill as much of this natural visual field as possible) and for the pinhole camera in HW1 (a light-tight box with a tiny hole; the field of view of your pinhole box is a geometric function of pinhole-to-screen distance and screen size — same angular-FOV concept, applied to a man-made "eye").

> **Summary**
> - Human field of view: ~190° monocular, ~120° binocular overlap, ~135° vertical.
> - FOV is an angle, so it is set by geometry (size and distance), which is why VR headsets and the HW1 pinhole box are described the same way.
> - *Next:* §11 covers how the two eyes' views combine into depth.

---

## 11. Depth Perception

Human depth perception combines many independent cues, grouped into two families:

**Monocular cues** (work with just one eye):
- **Perspective** (parallel lines converging toward a vanishing point)
- **Relative size** (same object type appears smaller when farther away)
- **Absolute size** (known real-world size of familiar objects)
- **Occlusion** (an object blocking another is in front of it)
- **Accommodation** (the eye's focus state, from §3, is itself a weak depth cue)
- **Retinal blur** (out-of-focus objects are perceived as being at a different depth)
- **Motion parallax** (nearer objects appear to move faster across your view than farther objects, as you move)
- **Texture gradients** (texture appears finer/denser as distance increases)
- **Shading** (how light and shadow fall on a surface implies its 3D shape)

**Binocular cues** (require two eyes):
- **(Con)vergence** — the inward rotation angle of both eyes needed to fixate on a near object (more rotation = closer object)
- **Disparity / parallax** — the difference in each eye's retinal image of the same scene, which the brain decodes into depth (this is the basis of stereoscopic 3D)

**Visual illusions** (e.g., M.C. Escher drawings, or the Held et al. 2006 SIGGRAPH illusion demos) are used pedagogically to show that these cues can be *individually* tricked/isolated — if a picture violates one cue (e.g., impossible occlusion) while satisfying others, you get a perceptual paradox, which is strong evidence that these are genuinely separable computational cues rather than one monolithic "depth sense."

> **Summary**
> - Depth comes from many separable cues: monocular (perspective, relative/absolute size, occlusion, accommodation, blur, motion parallax, texture, shading) and binocular (vergence, disparity).
> - Illusions show these cues can be isolated and individually fooled.
> - *Next:* §12 and §13 show how 3D displays use, and misuse, the binocular cues.

---

## 12. Stereoscopic Displays

**Stereoscopic** comes from *stereo* ("two"/"solid") + *scopic* ("viewing") — literally "two-eyed viewing." It describes anything that recreates depth by giving each eye a slightly different image, the way ordinary binocular vision already works: your two eyes sit a few centimeters apart, so each sees the same scene from a slightly different horizontal viewpoint, and the difference between those two views (**binocular disparity**, §11) is what your brain decodes into depth.

A **stereoscopic** device or display exploits this on purpose: instead of showing both eyes the same flat image, it feeds each eye its own slightly-offset image, so the brain perceives depth that isn't really there on a flat screen or print.

> **Summary**
> - *Stereoscopic* = "two-eyed viewing": show each eye a slightly offset image so the brain fuses them into depth (mimicking binocular disparity, §11).
> - The depth is simulated: the picture itself is still flat.
> - *Next:* §13 covers the discomfort this causes.

---

## 13. Vergence-Accommodation Conflict (VAC)

This is a specific, important problem with conventional stereoscopic displays (glasses-based 3D, most VR headsets):

- **In the real world**, *vergence* (§11, how much your eyes rotate inward to fixate an object) and *accommodation* (§3, how your lens focuses) both point to **the same distance** — they naturally match.
- **On a stereo display**, the two eyes are shown offset images that make you *verge* your eyes to a simulated depth (say, an object appears 2m away) — but your eyes must still *accommodate* (focus) at the **actual physical screen distance** (e.g., a headset lens at a fixed distance), which is usually different from the simulated depth.

This mismatch — verging to one distance while accommodating to another — is the **vergence-accommodation conflict**, and it's the leading cause of visual discomfort, fatigue, eyestrain, and nausea in stereo 3D/VR displays. It's also the direct engineering motivation for **light field displays** and future **holographic displays** (mentioned as near-/long-term solutions), which can (in principle) present a physically correct focus depth per pixel instead of a fixed screen distance — this connects forward to the light field imaging week (Week 9).

> **Summary**
> - In the real world, vergence (eye rotation) and accommodation (lens focus) agree on one distance.
> - On a stereo display they disagree: eyes verge to the simulated depth but focus on the physical screen. That mismatch is the **vergence-accommodation conflict**, a leading cause of VR/3D discomfort.
> - Light-field and holographic displays are the proposed fixes (Week 9).
> - *Next:* §14 starts the quantitative toolkit: brightness ratios in stops.

---

## 14. Stops, EV, and the Photographer's "+2 / −4" Notation

**Why this section is here.** Brightness ranges are quoted in *stops* (for the eye and for displays, for example), and "stop" returns in every camera week (aperture in Week 2 §8, exposure time and ISO in Week 4 §2.3). Photographers also write brightness changes as "+2", "−1", "−4 EV" or "f/2.8" without explanation. This is the one place where the whole shorthand is explained from scratch.

**Analogy first: musical octaves.** Notes an octave apart differ by a factor of 2 in vibration frequency, yet you hear that as one equal-sized "step" up. Light brightness works the same way: your eye and a camera's settings both care about *ratios*, not differences, so photographers count brightness in *doublings*. One doubling is one **stop**.

**Definition.** A **stop** is a factor of 2 in the amount of light (or in a ratio of brightnesses, such as dynamic range). Counting stops is just counting how many times you doubled or halved.

```
stops = log₂(ratio)          ratio = 2^stops
```

**Intuition.** Start from a ratio of 1 (no change) and double it once: ratio 2, which is 1 stop. Double again: ratio 4, 2 stops. Each extra stop multiplies the ratio by 2, so after *n* stops the ratio is 2 multiplied by itself *n* times, i.e. 2ⁿ. The logarithm base 2 (log₂) is simply the question "how many doublings gives this ratio?", the inverse of that multiplication. A negative number of stops is halvings: −1 stop is ×½, −2 stops is ×¼.

**Terms.**

| Symbol | Meaning | Units | Who controls it |
|---|---|---|---|
| ratio | how many times more (or fewer, if below 1) light, or brighter/darker, one thing is than another | dimensionless | fixed by the scene or your settings |
| stops | the same comparison counted in doublings; positive = more light, negative = less | "stops" (also written EV, see below) | what you dial in |

**Stops-to-light-multiplier table** (computed as 2^stops; the "+" and "−" are the same signs you see on a camera's exposure-compensation dial):

| Stops | Light multiplier | Reads as |
|---|---|---|
| −4 | 1/16 = 0.0625 | one-sixteenth as much light |
| −3 | 1/8 = 0.125 | |
| −2 | 1/4 = 0.25 | |
| −1 | 1/2 = 0.5 | |
| 0 | 1 | no change |
| +1 | 2 | twice the light |
| +2 | 4 | four times the light |
| +3 | 8 | |
| +4 | 16 | sixteen times the light |

**Converting between orders of magnitude and stops.** An **order of magnitude** is a factor of 10 (the scale you get by counting zeros: 10³ = 1000 is three orders). Since log₂(10) ≈ 3.32, 1 order of magnitude ≈ 3.32 stops. Example: 14 orders ≈ 14 × 3.32 ≈ 46.5 stops.

**Third-stop steps.** Cameras usually move in fractions of a stop, most often one third. A "+1/3 stop" step multiplies the light by 2^(1/3) ≈ 1.26, "+2/3" by 2^(2/3) ≈ 1.59, and three such steps give 2^(3/3) = 2, a full stop again. Every step is the same *multiplier*, not the same added amount (that is the octave idea: equal-sounding steps are equal ratios).

**"EV" has two uses; keep them apart.**

- **Exposure compensation** (the dial that reads "−2 … 0 … +2" on a camera). A value like **+2** (or "+2 EV") means "make the photo 2 stops, i.e. 2² = 4 times, brighter than the camera's automatic **meter** (its built-in light measurement) would have chosen". "−4" means 2⁻⁴ = 1/16 as bright. This is a *relative* instruction, an offset from the meter's suggestion.
- **Exposure value** (absolute EV, a single number labelling a combination of aperture and shutter time). It is defined in Week 4 §2.3; one step of it is again one stop.

**The three physical controls, and what one stop of each looks like.** (All three are defined properly later; this is the lookup you need now.)

| Control | What it is, in one line | One stop *more* light (or brightness) | Where deepened |
|---|---|---|---|
| **Aperture**, written f/N | the adjustable opening in the lens, f/N meaning opening diameter = focal length ÷ N (the slash is "divided by") | f/4 → f/2.8 (N shrinks by √2 ≈ 1.41, because light follows opening *area*, which goes as diameter²) | Week 2 §8 |
| **Shutter time** (also called **exposure time** or **shutter speed**: three names for one setting) | how long the sensor collects light | 1/125 s → 1/60 s (time doubles; the printed numbers are rounded powers of 2) | Week 4 §2.3 |
| **ISO** | an electronic amplification of the recorded signal (brightens the picture without collecting more light) | ISO 100 → ISO 200 | Week 4 §2.5 |

Because each control moves in stops, they trade off exactly: one stop opened on the aperture can be paid back by one stop faster on the shutter, leaving the picture's brightness unchanged (called **reciprocity**, Week 4 §2.2).

> **Worked example (a generic one, not a homework case).** A meter suggests f/4, 1/125 s, ISO 100. You want a faster shutter to freeze motion: 1/500 s is 2 stops faster (125 → 250 → 500 is two doublings, so 1/4 as much light). To pay those 2 stops back you can open the aperture 2 stops: f/4 → f/2.8 → f/2. Result: f/2, 1/500 s, ISO 100, same brightness as the meter's pick. Now add exposure compensation of +1: the camera will deliver 2× the light of that pick, for instance by slowing the shutter to 1/250 s.

> **Why this matters for HDR (Week 4).** A bracket "at −4, −2, +2, +4 stops" is just the multipliers 1/16, 1/4, 4, 16 from the table, applied to one baseline exposure; the whole spread is 8 stops, a 256× range.

The formulas above are in `formulas.md` (Week 1). Week 2 §8 gives the aperture sequence, and Week 4 §2.3 and §2.5 give the shutter and ISO sequences and absolute EV.

> **Summary**
> - A **stop** is a factor of 2 in light: **stops = log₂(ratio)**, **ratio = 2^stops**. +2 stops = 4×, −4 stops = 1/16.
> - 1 order of magnitude (×10) ≈ 3.32 stops; camera steps come in thirds of a stop, each a ×1.26 multiplier.
> - Aperture, shutter time and ISO all move in stops, so they trade off exactly (reciprocity).
> - *Next:* §15 uses stops and orders of magnitude to compare the eye with displays.

---

## 15. Dynamic Range

**Dynamic range** is the ratio between the brightest and darkest signal a system can represent. It is usually quoted in **stops** (each a factor of 2, §14) or in **orders of magnitude** (each a factor of 10). Analogy: the loudest and quietest sounds a microphone can record without clipping or drowning in hiss.

From the lecture:
- **Full human luminance vision range** (across all adaptation states, from starlight to sunlight): about **14 orders of magnitude** (10¹⁴×).
- **Instantaneous** human range (without re-adapting, e.g. pupil dilation or photoreceptor adjustments): about **5 orders of magnitude**.
- **Typical digital displays (at the time of the cited slide)**: only about **3 orders of magnitude**.

**The same numbers in stops** (orders × 3.32, from §14): 14 orders ≈ 46.5 stops, 5 orders ≈ 16.6 stops, 3 orders ≈ 10 stops.

**A caution about the "instantaneous" figure.** The lecture's summary slide quotes ~6.5 stops for instantaneous range, which does *not* match 5 orders (≈ 16.6 stops). They are two independently cited numbers: 6.5 stops is the eye's truly momentary contrast range with no adaptation, while ~5 orders is a looser figure that already includes some fast local adaptation. Only the 46.5-stop total is a straight unit conversion.

The large gap between what the eye can perceive and what a standard display can reproduce is the motivation for **HDR (high dynamic range) imaging and displays** (Week 4). For example, "Sunnybrook"-style HDR displays put a secondary low-resolution backlight array behind an LCD panel to multiply the achievable contrast ratio.

> **Summary**
> - Dynamic range = brightest ÷ darkest representable signal, in stops or orders of magnitude.
> - Human range: ~14 orders (≈ 46.5 stops) over all adaptation states; ~5 orders (a looser figure) or ~6.5 stops (momentary) at one instant; displays ~3 orders (≈ 10 stops).
> - Rule to remember: 1 order of magnitude ≈ 3.32 stops.
> - *Next:* §16 starts the other half of the toolkit: how detail of different sizes is measured.

---

## 16. Spatial Frequency

This section and the next two (contrast, then how well the eye detects stripes of each density, the **contrast sensitivity function** or CSF) are the direct theoretical basis for HW1 Task 3. Because the word "frequency" is dangerously overloaded in this course, this section builds it from scratch before anything else uses it.

### 16.1 First, disambiguate: which "frequency"?

This course uses *frequency* for three genuinely different things. Mixing them up is the most common source of confusion with this material, so pin them down:

| Word as used here | What varies | Unit | Where else it shows up |
|---|---|---|---|
| **Light frequency** (equivalently, wavelength/color) | How fast the *electromagnetic wave itself* oscillates | Hz, or more commonly its wavelength in nm | Color perception, §6 (~400–700 nm visible range) |
| **Temporal frequency** | How fast a signal changes *over time* (e.g. a flickering light, or a video's frame rate) | Hz (cycles per second) | A video's frame rate, a lamp's flicker |
| **Spatial frequency** | How fast *brightness* changes *across space* — i.e., as you scan your eye or a sensor sideways across an image | cycles per degree (cpd), or cycles per unit distance | Everything from here through hybrid images; split into "image", "physical" and "perceptual" flavors later in this section; reused formally in Week 5 |

**Every "high-frequency" / "low-frequency" mention from here through hybrid images means spatial frequency, and nothing else.** It has nothing to do with color (light frequency) and nothing to do with flicker/time (temporal frequency) — a "high-frequency" region of an image can be any color at all, and the image can be a single still photo with no time dimension involved.

### 16.2 What spatial frequency actually is, built up from a picture

Picture a **grating**: a test pattern of alternating light and dark stripes, like a barcode. (Campbell & Robson, 1968, used exactly this kind of stimulus.) Define one **cycle** as one full light-stripe-then-dark-stripe pair — start at the left edge of a light stripe, and the cycle ends where the *next* light stripe begins.

- **Fine, tightly-packed stripes** (many stripes crammed into a short distance) = brightness flips from light to dark and back *rapidly* as you scan across = **high spatial frequency**. This is the same underlying idea as a sharp edge or fine detail in an ordinary photo — anywhere brightness changes abruptly over a short distance is, in this sense, "high-frequency" content.
- **Wide, slowly-varying stripes** (or a smooth gradient, or a large blurry blob with no sharp edges) = brightness changes *gradually* over a long distance = **low spatial frequency**. A photo's overall shape, silhouette, and coarse shading are its low-frequency content.

**Spatial frequency is just a count of how many of these cycles are packed into some distance.** Nothing about color, nothing about time — purely "how bunched-up are the light/dark transitions."

### 16.3 Why "cycles per degree" instead of "cycles per centimeter"

If you printed a grating on paper, "cycles per centimeter" would be a perfectly good, fixed number — a physical property of the ink pattern that never changes no matter who looks at it or from where.

But your visual system doesn't experience physical centimeters directly — it experiences **visual angle** (§8): how large something appears in your field of view, which is *not* fixed — it shrinks as you back away and grows as you step closer (this is the p = 2·d·tan(α/2) relationship from §9, used in the other direction: a fixed physical size p subtends a smaller angle α as distance d grows).

So instead of asking "how many cycles per centimeter of paper," vision science asks the perceptual version: **"how many light/dark cycles fit into one degree of your visual field, from wherever you happen to be standing?"** That count is **cycles per degree (cpd)** — the same "one degree = 60 arcminutes" unit from §8, just now used to measure how densely packed a repeating pattern looks, rather than the size of a single object.

**Worked example — the same grating from two distances:**

Suppose a grating's cycles are 1 cm wide (1 cm of light stripe + dark stripe together), and you're standing 1 meter away. Using §8's small-angle shortcut, one cycle subtends about 0.01 rad ≈ 0.57°, so ≈ 1/0.57 ≈ 1.7 cycles fit into one degree: **about 1.7 cpd**.

- **Step back to 2 meters:** the same 1 cm cycle now subtends roughly *half* the visual angle (≈ 0.29°). More whole cycles fit into one degree, so the pattern's frequency goes **up**, to about 3.5 cpd.
- **Step closer to 50 cm:** the same cycle subtends roughly *double* the angle (≈ 1.15°). Fewer cycles fit into one degree, so cpd goes **down**, to about 0.87 cpd.

The physical ink on the page never changes. Only *how many of its cycles fit inside your one-degree window* changes, and that depends entirely on viewing distance. This single fact — **cpd is a property of "the pattern as seen from here," not a fixed property of the pattern itself** — is what the contrast sensitivity function and hybrid images are built on.

### 16.4 Image frequency vs. spatial frequency: the same pattern, three different rulers

§16.3 already showed that "cycles per centimeter" (fixed, physical) and "cycles per degree" (cpd, viewer-dependent) are two different rulers for measuring the *same* grating. There's a third ruler sitting even further upstream of both, and Week 5's material (Fourier transforms of digital images) leans on the distinction: **image frequency**.

**Image frequency** is how fast brightness changes across the *pixel grid* of a digital image file — cycles per pixel (equivalently, how many cycles fit across the image's full pixel width). It is a property of the array of pixel values alone: it doesn't know or care how large the image is printed, what screen shows it, or how far away anyone stands. Two copies of the exact same image file — one displayed on a phone, one blown up on a cinema screen — have identical image frequency, because that number never leaves the file's own pixel-index coordinate system. This is precisely the frequency axis you get from a digital image's Fourier transform (formalized in Week 5) — measured in cycles per pixel, not cycles per inch or cycles per degree.

**Spatial frequency**, as built up in §16.2 and §16.3, is the *physical/perceptual* version of the same idea — how fast brightness changes across real space, in cycles per unit distance (fixed, once an image is printed/displayed at a given size) or cycles per degree of visual angle (cpd — additionally dependent on viewing distance, per §16.3).

**The relationship is a two-step conversion chain**, reusing tools already built in this section:

1. **Image frequency → physical spatial frequency**, via dpi (§9). Image frequency is in cycles/pixel; dpi is in pixels/inch (the same dpi = 1/p density from §9). Multiplying converts the units:
   ```
   physical spatial frequency (cycles/inch) = image frequency (cycles/pixel) × dpi (pixels/inch)
   ```
   This step turns a fixed *digital* quantity into a fixed *physical* quantity — it depends only on what dpi you choose to print or display at, never on the viewer.

2. **Physical spatial frequency → cpd**, via viewing distance — exactly the visual-angle logic §16.3 already applied to the 1 cm grating example. This is the only step in the whole chain that depends on the viewer at all.

**Worked example:** suppose a digital image contains a fine repeating texture with a period of 6 pixels — one full light-dark cycle every 6 pixels — so its **image frequency is 1/6 ≈ 0.167 cycles/pixel**, a fixed fact about the file, unrelated to how it's ever displayed. Printed at **300 dpi** (the same density as §9's retina-display example):

```
physical spatial frequency = 0.167 cycles/pixel × 300 pixels/inch = 50 cycles/inch (≈ 19.7 cycles/cm)
```

This number is now fixed too — it stays 50 cycles/inch no matter how far anyone stands from the print, because it's baked into the physical ink the moment you commit to 300 dpi. Only the last step — converting to cpd — depends on the viewer: viewed from 40 cm, applying the same visual-angle machinery as §16.3's worked example gives roughly **13.7 cpd**. Change the viewing distance and, per §16.3, that cpd number moves — but the image frequency (0.167 cycles/pixel) and the physical spatial frequency (50 cycles/inch) never do.

**Takeaway:** image frequency is the innermost, most fixed quantity — a property of the pixel array alone. Spatial frequency is the umbrella term for "how fast brightness varies across space," which itself splits into a fixed-once-printed flavor (cycles per physical distance) and a viewer-dependent flavor (cpd, the unit the eye's sensitivity curve is plotted in). Confusing "cycles per pixel" with "cycles per degree" is a common mistake — a texture with fixed image frequency can sit anywhere on the CSF curve depending on print size and viewing distance, which is exactly the print-size/viewing-distance reasoning HW1 Task 3 asks you to work through (the specific numbers are left to the assignment).

> **Summary**
> - Spatial frequency = how many light/dark cycles fit into some distance; cycles per degree (cpd) is the viewer-dependent version, and the same pattern's cpd rises as you step back.
> - Three rulers for one pattern: image frequency (cycles/pixel, fixed by the file) → physical spatial frequency (cycles/inch = cycles/pixel × dpi) → cpd (needs viewing distance).
> - Never mix "spatial" with light frequency (color) or temporal frequency (flicker).
> - *Next:* §17 defines the contrast of a stripe pattern; §18 plots how well the eye sees each cpd.

---

## 17. Contrast

**What problem this solves.** To study how well the eye detects a pattern, you need a single number saying "how strong is this brightness difference?" Contrast is that number. Input: the brightness (luminance) values in a scene or pattern. Output: one dimensionless contrast value, larger meaning easier to see. Analogy: contrast is like a signal-to-background ratio, how loudly someone speaks relative to the room's noise, since the same absolute brightness step is obvious on a dark background and invisible on a bright one.

Before you can measure how well the eye detects stripes, you need a numeric definition of contrast itself, and there isn't just one:

- **Weber contrast**: designed for a single, small feature on a large uniform background.
  ```
  C_weber = (I_feature − I_background) / I_background
  ```
  Good when there's one clear "object" and one clear "background" luminance. Example: a feature of brightness 120 on a background of 100 has Weber contrast (120 − 100)/100 = 0.2.

- **Michelson contrast**: designed for periodic/repeating patterns (like the gratings of §16.2), where there's no single "background."
  ```
  C_michelson = (I_max − I_min) / (I_max + I_min)
  ```
  This normalizes by the *average* of the brightest and darkest parts of the pattern, which makes sense for a repeating stripe pattern where "background" isn't well-defined. Example: stripes alternating between brightness 150 and 50 have Michelson contrast (150 − 50)/(150 + 50) = 0.5.

**Takeaway:** "contrast" is context-dependent — which formula you use depends on whether you're describing a single feature (Weber) or a repeating pattern (Michelson). Experiments on stripe detection use grating stimuli, so Michelson contrast is the natural definition there.

> **Summary**
> - Contrast is one dimensionless number for "how strong is this brightness difference?"
> - **Weber** = (I_feature − I_background) / I_background, for one feature on a uniform background; **Michelson** = (I_max − I_min) / (I_max + I_min), for repeating patterns.
> - *Next:* §18 asks how small a Michelson contrast the eye can detect at each spatial frequency.

---

## 18. The Contrast Sensitivity Function (CSF)

**What problem this solves.** Visual acuity (§8) says only the *smallest* detail you can resolve, but real images contain stripes and textures of every size and every strength. The contrast sensitivity function (CSF) answers: for each stripe density, how faint can the stripes get before you stop seeing them? Input: a spatial frequency in cycles per degree (cpd). Output: contrast sensitivity, the reciprocal of the faintest contrast you can still detect. Analogy: it is an equalizer curve for vision, like a hearing test that finds the quietest audible volume at each pitch, except the "pitch" is stripe density and the "volume" is contrast.

**Setup:** Campbell & Robson (1968) showed subjects sinusoidal gratings (the "smoothly-fading" version of the stripe idea in §16.2, rather than sharp-edged bars) at different **spatial frequencies** and different **contrasts** (§17), and found the *minimum contrast* at which a subject could just barely detect the stripes at all. The reciprocal of that minimum detectable contrast is the subject's **contrast sensitivity** at that spatial frequency: a *low* minimum-detectable-contrast means you're very sensitive (you can spot even a faint pattern), so sensitivity = 1 / (that minimum contrast).

**Shape of the CSF curve (contrast sensitivity, on the y-axis, plotted against spatial frequency in cpd, on the x-axis):**
- It is **band-pass**, not low-pass or flat: sensitivity is *reduced* at very low spatial frequencies (large, slowly-varying patterns — picture a very gradual, barely-there gradient, which is genuinely hard to notice) *and* at very high spatial frequencies (very fine stripes), and **peaks around 4–6 cpd**, meaning that's the "sweet spot" density of light/dark cycles your eye is best at detecting.
- At the high-frequency end, sensitivity eventually drops to zero around **~60 cpd**, set by **cone packing density** — you simply cannot perceive stripes finer than your photoreceptor mosaic can sample (explained just below).
- Critically, because of §16.3: **the same physical pattern's position on this curve shifts as you change your viewing distance**, since its cpd value itself changes with distance. Move closer → its cpd drops, potentially sliding it toward the 4–6 cpd peak (more visible). Move farther away → its cpd rises, potentially pushing it past ~60 cpd (less visible, eventually invisible).

**Why this matters (the big idea, restated concretely):** take a photo with genuinely fine detail in it — hairline-thin brushstrokes, say. Physically, those fine strokes are a fixed size. But per §16.3, their *cpd* isn't fixed: viewed from far away, that small physical size subtends a tiny visual angle, so a huge number of them cram into one degree → very high cpd → likely past the ~60 cpd cutoff → invisible. Viewed up close, the same strokes subtend a much larger visual angle, so far fewer fit into one degree → their cpd drops into the visible, even peak-sensitivity range → clearly visible.

A single physical image can therefore contain content that is only visible up close (high spatial frequency) stacked with content that stays visible from far away (low spatial frequency) — and that's precisely how a hybrid image works.

**Where the ~60 cpd cutoff comes from (a consistency check).** §5 gave the cone spacing: ~0.5 arcmin. To see a stripe pair you need at least one cone sample on each light stripe and each dark stripe, so the smallest resolvable cycle is about 2 × 0.5 = 1 arcmin. That matches 20/20 acuity (§8). One cycle per arcmin is 60 cycles per 60 arcmin, so **60 cpd**, the CSF's cutoff. Week 5 formalizes this "two samples per cycle" rule as the sampling (Nyquist) limit.

> **Summary**
> - The CSF plots contrast sensitivity (1 / minimum detectable contrast) against spatial frequency in cpd.
> - It is band-pass: peak around 4–6 cpd, falling at low frequencies, reaching zero near ~60 cpd (set by cone spacing).
> - Because cpd depends on distance (§16.3), the same image slides along this curve as you move, which is the basis of hybrid images.
> - Computing specific cutoff frequencies for HW1 is left to the assignment.
> - *Next:* §19 shows how a computer actually splits an image into low and high spatial frequencies.

---

## 19. The Fourier Transform: Images as Sums of Waves

§16 to §18 established *that* an image has spatial-frequency content and how humans perceive it. This section answers a different question: on a computer, how do you pull an image apart into its low-frequency and high-frequency pieces? The tool is the **Fourier transform**, the mechanism underneath hybrid images, the HW1 task.

**Which frequency is meant here.** The "frequency" this section computes with is **image frequency** (§16.4): cycles per pixel, fixed to the file. A bare "frequency" or "(u,v)" below always means image frequency, never cpd. Converting to cpd still needs the dpi and viewing-distance chain of §16.4.

HW1's hybrid-images task is implemented by calling `np.fft.fft2`, `np.fft.fftshift`, `np.fft.ifftshift` and `np.fft.ifft2`. To use them as more than magic incantations, you need a mental model of what they do to an image.

**The reframing.** Most computer-vision code treats an image as an array of brightness values indexed by pixel location ("what color is at row y, column x?"). That is the **spatial domain** view. Computational imaging routinely switches to another description of the *same* image: "how much of each possible wave pattern is present, across the whole image at once?" That is the **frequency domain**. The Fourier transform converts between the two. Nothing is lost, and an *inverse* Fourier transform converts back.

> **Optional deeper dive: scope of this section.** Properly, this is Week 5 material ("Sampling, Linear Systems, Deconvolution"). What follows is a deliberately partial, HW1-driven preview. Left for Week 5: the exact discrete Fourier transform formula, the sampling theorem, aliasing, why the FFT algorithm is fast, and blur as convolution with a point spread function (PSF) plus its first inverse, the Wiener filter. Left for Week 6: deconvolution with natural-image priors.

### 19.1 The 1D idea: any signal is a sum of waves

A musical chord sounds like one complex sound, but it's really several pure tones (sine waves) sounding at once, each with its own pitch (**frequency**) and loudness (**amplitude**). Taking a chord apart into its individual pure tones is, informally, exactly what a Fourier transform does.

Stated more generally: essentially any signal — a sound wave over time, brightness measured along a single scanline of a photo, or anything that's a single value varying along one axis — can be written as a sum of sine waves of different frequencies, each with its own **amplitude** (how strong that wave is) and **phase** (how far that wave is shifted left/right relative to a reference starting point). The **Fourier transform** is the operation that takes a signal's original description — a value at each moment or position, the "time domain" or "spatial domain" view — and returns the *recipe* of which frequencies are present and how strong/shifted each one is — the "frequency domain" view.

**Worked example:** let `s(t) = sin(2π·3t) + 0.5·sin(2π·7t)` — a signal built from exactly two pure tones: one oscillating 3 times per unit of *t* with amplitude 1, another oscillating 7 times per unit of *t* with amplitude 0.5. Its Fourier transform is *not* a smooth curve — it's zero almost everywhere except two sharp spikes: one at frequency 3 (reflecting amplitude 1), one at frequency 7 (reflecting amplitude 0.5). That's the core idea: the frequency-domain view tells you exactly which pure frequencies are "in" a signal and how strong each one is, and a signal built from only a few frequencies produces a spectrum that's mostly zero with a few spikes.

**Linear-algebra view (the Fourier transform as a change of basis):** a signal of N samples is just a vector with N entries. Its usual description ("value at sample 0, value at sample 1, ...") is its coordinates in the **standard basis**, where each basis vector is a single spike at one position. The discrete Fourier transform (DFT) rewrites the *same* vector in a different basis made of N sampled sinusoids, one per frequency, which makes it a **change of basis**. These sinusoidal basis vectors are **orthogonal**: the inner product of any two different ones is 0. So each Fourier coefficient is simply the inner product of the signal with that frequency's basis vector ("how much does the signal look like this wave?"). The inverse transform is the inverse change of basis: add the basis vectors back up, each scaled by its coefficient. No information is lost, because N independent basis vectors describe N-dimensional space completely.

**Worked example — a 4-point DFT basis (N = 4):** the four basis vectors, written as rows, are

```
k = 0:  [ 1,  1,  1,  1 ]    (constant — the average, called the **DC component**, zero frequency)
k = 1:  [ 1,  i, −1, −i ]    (one cycle across the 4 samples)
k = 2:  [ 1, −1,  1, −1 ]    (two cycles — the fastest possible flip)
k = 3:  [ 1, −i, −1,  i ]    (one cycle, turning the opposite way: a "negative frequency")
```

They are complex numbers because a complex exponential packs a cosine and a sine (amplitude and phase) into one number. With the complex inner product (multiply by the *conjugate* of the second vector, then sum), every pair of different rows gives 0 and every row with itself gives 4 = N. Take the signal **x** = [3, 1, −1, 1]. Its four inner products with the rows are **X** = [4, 4, 0, 4], which is exactly what `np.fft.fft` returns. Going back, (1/4)·(4·row₀ + 4·row₁ + 0·row₂ + 4·row₃) = [3, 1, −1, 1] recovers **x**. In words, **x** is "average 1 everywhere" plus "one slow cycle of amplitude 2," and contains nothing at the fastest frequency. Week 5 formalizes the full DFT formula; this is the same thing written as a 4×4 matrix.

### 19.2 From 1D to 2D: an image needs waves that vary in two directions

A 1D signal like sound only has one axis to vary along — time. An image has two: brightness can change as you move left-right (horizontal) *and* as you move up-down (vertical), independently. So the "pure tone" building block for a 2D signal can't be an ordinary 1D sine wave — it needs to be a pattern that can oscillate horizontally, vertically, or diagonally (some mix of both) at once. That building block is a **2D sinusoidal grating**: a repeating stripe pattern, like the gratings from §16.2, but now allowed to run in any direction.

Once that picture is clear, here's the formula it corresponds to (introduced only to read off what each piece means — it isn't manipulated further here):

```
I(x, y) = A · cos(2π(u·x + v·y) + φ)
```

where *x, y* are pixel coordinates, *A* is the grating's amplitude (contrast/strength), *φ* is its phase (where the stripes sit), and — the important pair — **u** is the *horizontal* image frequency (cycles per pixel as you scan left-right) and **v** is the *vertical* image frequency (cycles per pixel as you scan up-down). Per the note at the start of §19, these are image frequencies, the same cycles-per-pixel ruler as §16.4, not cpd.

What *u* and *v* control, geometrically:
- `v = 0, u > 0`: brightness only changes as *x* changes → **vertical stripes** — a pure "horizontal wave."
- `u = 0, v > 0`: brightness only changes as *y* changes → **horizontal stripes** — a pure "vertical wave."
- `u > 0` and `v > 0` both: stripes run **diagonally**, tilted at an angle set by the ratio of *v* to *u*. The stripes are always oriented *perpendicular* to the direction pointed to by `(u, v)`, and how tightly packed they are is set by the combined image frequency `√(u² + v²)` cycles/pixel.

This is exactly the "image as horizontal and vertical waves" idea: any real image — not just a striped test pattern — can be treated as a giant sum of these 2D gratings, one for every possible `(u, v)` pair, each with its own amplitude and phase. The **2D Fourier transform** is the operation that reports, for every `(u, v)`, how much of that particular tilted stripe pattern is present in the image.

### 19.3 What `fft2`'s output actually represents: same shape, different meaning

**What problem this solves.** To separate an image into coarse and fine detail, you need to know how much of each stripe pattern (§19.2) the image contains. `fft2` computes exactly that. Input: an *H*×*W* array of pixel brightnesses (one color channel). Output: an *H*×*W* array of complex numbers, one per stripe pattern, giving its strength and shift. Analogy: a prism turns one beam of white light into a rainbow showing how much of each color is present; `fft2` turns a picture into a "rainbow" showing how much of each stripe pattern is present.

This is the single most common point of confusion, worth stating bluntly: when you call `np.fft.fft2` on an *H*-pixel-tall, *W*-pixel-wide image, you get back another array that is also *H*×*W* — but comparing the two arrays entry-by-entry is meaningless, because they represent completely different things.

- In the **input** array, the entry at row *y*, column *x* is the brightness at pixel location `(x, y)`. Spatial domain: index = location.
- In the **output** array, the entry at row `k_v`, column `k_u` — plain integer positions, exactly like any other array index — is a single complex number describing one particular 2D grating: its **magnitude** (the number's size) tells you how strong that grating is in the image, and its **phase** (the number's angle) tells you how that grating is shifted. Frequency domain: index = *which grating*, not a location.

(A complex number's magnitude and phase are just two numbers packaged together — magnitude answers "how much," phase answers "shifted by how much." It's the same amplitude/phase pair from §19.1's sine waves, just stored compactly as one number.)

**Linear-algebra view (why the output is the same shape):** flatten an *H*×*W* single-channel image into one vector of *H*·*W* numbers. The 2D gratings of §19.2, one for each integer pair `(k_u, k_v)`, are *H*·*W* orthogonal basis vectors for that same space. `fft2` is the change of basis from pixel coordinates to grating coordinates, the 2D version of §19.1's 4-point example. A change of basis never changes how many coordinates you need, so *H*·*W* numbers go in and *H*·*W* come out. But entry `[r, c]` means "pixel at (c, r)" in the input and "coefficient of grating `(k_u, k_v) = (c, r)`" in the output. That is why the two arrays can't be compared entry by entry.

**Units, precisely — array index vs. cycles per pixel.** `k_u` and `k_v` are *not yet* the `u` and `v` from §19.2's grating formula. `k_u` is a plain integer (0 to *W*−1 before `fftshift`, roughly −*W*/2 to *W*/2 after) that counts how many complete stripe-cycles that grating fits across the image's *entire width* — cycles across the whole image, not cycles per pixel. To get the actual image frequency in cycles per pixel — the same `u`, `v` used everywhere else in this part — divide by the corresponding dimension:

```
u = k_u / W      v = k_v / H
```

Because *W* and *H* can differ for a non-square image, the same array position generally gives *different* cycles-per-pixel values for `u` and `v` — worth remembering whenever reading a frequency straight off an axis.

**Worked example:** a 256-pixel-wide image's `fft2` output has a nonzero entry at column index `k_u = 8`. That grating completes exactly 8 full stripe-cycles across the whole 256-pixel width — its image frequency is `u = 8 / 256 = 0.03125 cycles/pixel`, i.e., one full light-dark cycle every 32 pixels.

The whole array of these magnitudes is called the image's **spectrum** (or *magnitude spectrum*, when specifically plotting `|F(u,v)|` and ignoring phase — usually on a log scale for display, since real photos are dominated by a few very strong low frequencies that would otherwise wash out everything else on a linear scale).

This formalizes §16.4's "image frequency": once converted from raw array index by dividing by *W* or *H* as above, `u` and `v` are literally measured in cycles per pixel — exactly the unit §16.4 defined.

- Low `(u,v)`, near the origin: slow brightness variation — coarse shapes and broad shading.
- High `(u,v)`, far from the origin: rapid variation — fine edges and texture.

This is the precise, computable version of §16.2's qualitative "fine stripes = high frequency" story (there a general notion of frequency; here specifically image frequency). It is what lets a computer split an image into the "coarse" and "fine" bands that hybrid images combine.

**What about color?** `fft2` only accepts a single 2D array, and a color image is really *three* of them stacked — one *H*×*W* array per channel (R, G, B). There's no single joint "color spectrum": you call `fft2` on each channel separately, giving three completely independent spectra, one per channel, each with its own magnitude and phase at every `(k_u, k_v)`. So any procedure built on `fft2` (a hybrid-image recipe, for example) repeats three times, once per channel, with no interaction between channels.

### 19.4 `fftshift`: reordering the output to match intuition

**What problem this solves.** `fft2` stores its output in an order that is awkward to read and to mask. `fftshift` only rearranges that array so zero frequency sits in the center. Input: a raw `fft2` output array. Output: the same numbers, same shape, with the four quadrants swapped diagonally. Analogy: a map printed with its center torn into the four corners; `fftshift` tapes the corners back so the center is in the middle again, and `ifftshift` tears it back apart.

Display a raw `fft2` output's magnitude as an image, and it looks wrong at first: the brightest spot — the **DC component**, meaning zero image frequency, `u = v = 0`, which is just the image's overall average brightness — sits in a *corner*, not the center, and the pattern seems to wrap around the edges.

Why: in how the discrete Fourier transform indexes frequencies, index 0 means frequency 0 as expected, but the far end of the array (index *N*−1) doesn't mean "the highest positive frequency" — it means a small *negative* frequency, because the transform is periodic and treats frequency *N*−1 as identical to frequency −1. So the second half of each axis actually holds the negative frequencies, wrapped around to the far end of the array instead of sitting naturally in front of frequency 0.

Concretely, since rows index *v* and columns index *u*, each of the raw array's four quadrants holds one fixed combination of signs: top-left is `u ≥ 0, v ≥ 0` (and contains the DC corner), top-right is `u < 0, v ≥ 0`, bottom-left is `u ≥ 0, v < 0`, and bottom-right is `u < 0, v < 0`. `fftshift` doesn't touch a single pixel's *value* — it only relocates these four fixed-sign blocks so they meet at a shared center instead of wrapping at the array's outer edges, which is why frequency 0 ends up in the **center** and frequency magnitude increases outward in every direction from there — matching the natural mental picture of a spectrum, and matching how low-pass/high-pass masks (used for filtering) are naturally described ("a disc around the center"). `ifftshift` undoes exactly this reordering, and must be applied *before* `ifft2`, since `ifft2` expects the original DC-in-the-corner layout, not the shifted one.


> **Summary**
> - The Fourier transform rewrites a signal or image as a sum of waves (amplitude + phase per frequency); in 2D the waves are gratings with horizontal frequency *u* and vertical frequency *v*, in cycles per pixel.
> - `fft2` returns an array of the same shape but a different meaning: entry `[k_v, k_u]` is a *grating's* strength and shift, not a pixel; **u = k_u / W, v = k_v / H**.
> - Linear-algebra view to remember: the DFT is a change from the pixel basis to an orthogonal basis of sinusoids, so no information is lost.
> - `fftshift` only moves the zero-frequency (DC) entry from the corner to the center.
> - *Next:* §20 builds convolution, the spatial-domain twin of multiplying spectra.

---

## 20. Convolution from Scratch

The next section says "multiplying spectra is the same as convolving signals." That sentence is meaningless until **convolution** itself has been defined, so this section builds it from nothing, then explains *why* the theorem is true (and checks it on numbers). The same idea returns in Week 2 §3 (pinhole blur), Week 3 §12.2 (Gaussian smoothing), Week 4 §18 (PSF/OTF) and §23 (flutter shutter), and in LiDAR ranging.

### 20.1 Analogy: a stamp, and a sliding window

- *Stamp view (each point spreads its light).* Imagine a row of light bulbs of different brightness, photographed out of focus. Each bulb does not land on the sensor as one dot; it lands as a small soft blob. The photo is every bulb's blob added together, where a brighter bulb stamps a stronger blob. The blob's shape is the **kernel**. Convolution is "stamp a copy of the kernel at every input sample, scaled by that sample's value, and add all the stamps."
- *Window view (a weighted neighborhood average).* The same arithmetic, read from the output's side: to get one output value, slide a small window of weights over the input, multiply the input values under the window by the weights, and add. This is "average each pixel with its neighbors" (a blur), now allowed to use *unequal* weights.

### 20.2 Definition in 1D (discrete signals)

A 1D signal here is a list of numbers `x[0], x[1], ...` (for example, brightness along one scanline). The convolution of `x` with a kernel `h` is a new list:

```
(x * h)[n] = sum over m of  h[m] · x[n − m]
```

- *Intuition, step by step.* (1) The output at position `n` is a weighted sum of input values near `n`. (2) The weight `h[m]` multiplies the input value that sits `m` steps *behind* `n` (index `n − m`). (3) Equivalently, the input sample `x[j]` contributes `x[j]·h[m]` to output position `n = j + m`, which is the stamp view: a copy of `h`, scaled by `x[j]`, starting at position `j`. The two readings are the same sum with the indices relabeled.
- *Why `n − m` (the "flip").* Walking `m` forward in the kernel walks backward in the input. So in the window view the kernel appears *reversed* relative to the signal. For a symmetric kernel (like `[¼, ½, ¼]`) the reversal changes nothing, so it is easy to miss; for an asymmetric kernel it matters (see the impulse example in §20.3).
- *Term by term.*

| Symbol | Meaning | Units | Controlled by you? |
|---|---|---|---|
| `x[j]` | the input signal's value at position `j` (a pixel's brightness) | same as the signal (e.g. brightness) | fixed by the scene |
| `h[m]` | the kernel's weight at offset `m` | unitless weight | **yes**: it is the filter you design, or the blur the optics impose |
| `n` | the output position being computed | pixels (or samples) | the index you loop over |
| `m` | offset into the kernel (how many steps from the center or start) | pixels | summation variable |
| `(x * h)[n]` | the filtered / blurred output at position `n` | same as signal | computed |
| `*` | the convolution operator (not ordinary multiplication) | | |

- *Complexity.* A kernel with `K` nonzero entries costs `K` multiplies per output sample, so `N` samples cost about `N·K` work. In 2D with a `K×K` kernel it is about `N·K²` (the cost Week 4 §18.3 compares against the FFT route).

### 20.3 Fully worked 1D example (stamp view and window view agree)

Signal `x = [1, 3, 2, 5, 4]` (positions 0 to 4), kernel `h = [¼, ½, ¼]` (positions 0 to 2; a weighted 3-point average). Zero-pad: treat everything outside the signal as 0.

Stamp view. Each input sample stamps `h` scaled by its value, starting at its own position:

| Input sample | Stamp (scaled kernel) | Lands on output positions |
|---|---|---|
| `x[0] = 1` | `[0.25, 0.5, 0.25]` | 0, 1, 2 |
| `x[1] = 3` | `[0.75, 1.5, 0.75]` | 1, 2, 3 |
| `x[2] = 2` | `[0.5, 1.0, 0.5]` | 2, 3, 4 |
| `x[3] = 5` | `[1.25, 2.5, 1.25]` | 3, 4, 5 |
| `x[4] = 4` | `[1.0, 2.0, 1.0]` | 4, 5, 6 |

Adding the stamps position by position:

| Output position `n` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| `(x*h)[n]` | 0.25 | 1.25 | 2.25 | 3.00 | 4.00 | 3.25 | 1.00 |

Window view check at `n = 3`: `h[0]·x[3] + h[1]·x[2] + h[2]·x[1] = 0.25·5 + 0.5·2 + 0.25·3 = 1.25 + 1 + 0.75 = 3.00`. Same number.

Observations: (1) The output has length `5 + 3 − 1 = 7` (**full** convolution: signal length plus kernel length minus 1), because the blur spreads the signal past both ends. (2) The jagged input `1, 3, 2, 5, 4` became the smoother `1.25, 2.25, 3, 4, 3.25` in the middle: it is a low-pass filter. (3) The kernel sums to 1, so the total brightness is preserved away from the edges.

**Impulse example (why the flip matters, and why "impulse response" is a name).** Feed in a **unit impulse** (also called a **delta**): a signal that is 0 everywhere except a single 1, here `[0, 0, 1, 0, 0]`. With the *asymmetric* kernel `h = [1, 2, 3]` the output is `[0, 0, 1, 2, 3, 0, 0]`: the output is simply a copy of the kernel placed where the impulse was, not reversed. This is why the kernel is also called the system's **impulse response** (what comes out when you put a single spike in), and why a camera's blur kernel is called a **point spread function** (the "impulse" is a single point of light; Week 4 §18.1). **Cross-correlation** is the near-twin operation that slides the kernel *without* reversing it; on the same impulse it returns `[0, 0, 3, 2, 1, 0, 0]`, the kernel backwards. Many libraries (including most deep-learning "convolution" layers) actually compute correlation; for a symmetric kernel the two coincide.

### 20.4 Tiny 2D example

Images are convolved the same way, with the kernel sliding in both directions: each output pixel is a weighted sum over a small 2D neighborhood. Take the `3×3` image and a `2×2` kernel whose four weights are all `¼` (a 4-pixel average):

```
image            kernel (2x2 box)       output, "valid" region only (2x2)
1 2 3            0.25 0.25              3 4
4 5 6            0.25 0.25              6 7
7 8 9
```

Top-left output: `(1 + 2 + 4 + 5)/4 = 3`; the other three follow the same way. "Valid" means only positions where the kernel fits entirely inside the image (output smaller than input: `3−2+1 = 2` per side). 2D impulse: a `3×3` image that is all 0 except a single `4` in the center, convolved with the same box kernel (full output, `4×4`), gives a `2×2` block of `1`s (`4 × ¼`) in the middle: a copy of the kernel scaled by the impulse's value. That copy is the 2D PSF in action.

### 20.5 Terminology, in one place

| Term | Plain meaning |
|---|---|
| **Kernel** (also **filter**, **mask**, **template**; for optics, **PSF**; for signals, **impulse response**) | the small list/grid of weights `h` that gets slid over the signal. "Mask" is also used for the 0/1 frequency masks used for filtering, which are a different object (they live in the frequency domain). |
| **Tap** | one entry of the kernel; a 3-tap kernel has 3 weights. |
| **Support** | the positions where the kernel is nonzero; its width is how far one point's light can spread (3 for `[¼, ½, ¼]`). |
| **Normalization** | scaling the kernel so its weights sum to 1; then flat regions keep their brightness and total light is conserved. |
| **Boundary handling / padding** | what to assume outside the signal where the window overhangs the edge: zeros (**zero-padding**, used above), repeat the edge value, mirror, or wrap around to the opposite side (**circular**, which is what the DFT silently assumes; §19.4's wrap-around). |
| **Full / same / valid** | which output positions to keep: all (length `N+K−1`), the central `N`, or only those where the kernel fully fits (`N−K+1`). |
| **Impulse / delta** | the signal that is a single 1 and zeros elsewhere. |
| **Linear** | scaling or adding inputs scales or adds outputs: `(a·x₁ + b·x₂)*h = a·(x₁*h) + b·(x₂*h)`. |
| **Shift-invariant** (time-invariant for signals in time) | shifting the input by `d` shifts the output by `d`; the same kernel applies everywhere. |
| **LSI system** (linear shift-invariant) | any system with both properties. **Every LSI system is a convolution with its impulse response**, which is why a camera's blur is fully described by one PSF *when* the blur is the same everywhere. |

### 20.6 Properties worth knowing (all follow from the definition)

- *Commutative:* `x * h = h * x` (signal and kernel are interchangeable roles).
- *Associative:* `(x * h₁) * h₂ = x * (h₁ * h₂)`: two blurs in a row equal one blur by the combined kernel (two small Gaussians make a wider Gaussian).
- *Distributive and linear:* `x * (h₁ + h₂) = x*h₁ + x*h₂`; this is what makes "blur, then subtract from the original" (which keeps only the fine detail) itself a convolution, with kernel `δ − h` (`δ` = the delta kernel `[1]`).
- *Identity:* convolving with the delta returns the signal unchanged: `x * δ = x`.
- *Shift:* convolving with a delta that sits `d` steps over just translates the signal by `d`.

### 20.7 The convolution theorem, motivated (not just stated)

*Step 1: why a sinusoid is special.* Feed a pure wave (say a cosine at one frequency) into an LSI system. Shift-invariance says shifting the input wave shifts the output the same way. A shifted cosine is a mix of that same-frequency cosine and sine. So the output cannot contain any *new* frequency: a wave comes out as **the same-frequency wave, scaled in amplitude and shifted in phase**. In linear-algebra language, sinusoids are the **eigenvectors** of every convolution (an eigenvector is a vector that a matrix only rescales, never turns), and the scale-and-shift for each frequency is its **eigenvalue**, a complex number `H(f)`. The linear-algebra view below makes this concrete.

*Step 2: check on numbers.* Use the 4-sample setting of §19.1 with wrap-around (circular) edges: kernel `[½, ¼, 0, ¼]` and the slow cosine `[1, 0, −1, 0]` (k = 1). Convolving gives `[½, 0, −½, 0]`: the same wave, scaled by `½`. That `½` is exactly the kernel's DFT at `k = 1`. (Taking inner products of the kernel with the four basis rows of §19.1 gives the full list of scale factors, `[1, ½, 0, ½]`.)

*Step 3: assemble.* Any signal is a sum of sinusoids (§19.1). Convolution is linear, so convolve each sinusoid separately, and each one only gets multiplied by its own number `H(f)`. Re-adding gives the result. The bookkeeping is:

```
DFT{ x * h } = DFT{ x } · DFT{ h }        (entry-by-entry multiplication, one frequency at a time)
```

- *Term by term.* `DFT{x}` is the input spectrum (how much of each wave is in the signal; units of the signal); `DFT{h}` is the kernel's spectrum, its **frequency response** (a unitless scale factor per frequency, 1 means "passes unchanged", 0 means "erased"); `DFT{x*h}` is the output's spectrum. *You* control `h`, so you control `DFT{h}`.
- *Exactness caveat.* The DFT assumes a wrap-around signal, so the identity is exact for **circular** convolution. For the ordinary (zero-padded) convolution, zero-pad the signal and kernel to at least `N + K − 1` samples before transforming and it is exact there too.
- *Why it is useful.* Spatial convolution costs about `N·K` multiplies; in the frequency domain it costs two FFTs plus one multiply per frequency, independent of `K` (compared in Week 4 §18.3). It is also what lets you *see* what a kernel does: look at where `|DFT{h}|` is near 1 (kept) or near 0 (removed).
- *Numeric check (same 4-sample example).* Directly, `x = [3, 1, −1, 1]` convolved circularly with `[½, ¼, 0, ¼]` gives `[2, 1, 0, 1]`. Through the spectra: `[4, 4, 0, 4] × [1, ½, 0, ½] = [4, 2, 0, 2]`, and the inverse DFT of that is `[2, 1, 0, 1]`. The two routes match.

**Linear-algebra view (convolution as a banded Toeplitz matrix).** Write the 5-sample signal as a vector **x** and the full convolution as `y = H x`, where **H** is a `7×5` matrix whose column `j` is the kernel placed starting at row `j` (that column is the stamp from `x[j]`):

```
[0.25   .    .    .    .  ]   [1]   [0.25]
[0.5  0.25   .    .    .  ]   [3]   [1.25]
[0.25 0.5  0.25   .    .  ]   [2]   [2.25]
[ .   0.25 0.5  0.25   .  ] x [5] = [3.00]
[ .    .   0.25 0.5  0.25 ]   [4]   [4.00]
[ .    .    .   0.25 0.5  ]         [3.25]
[ .    .    .    .   0.25 ]         [1.00]       ( . = 0 )
```

Same pattern in every column, shifted down one row each time: constant along diagonals, a **Toeplitz** matrix; with wrap-around edges it becomes a **circulant** matrix. The Fourier basis vectors (§19.1) are its eigenvectors; the eigenvalues are `DFT{h}`; so in the Fourier basis the whole matrix is a diagonal list of scale factors, and applying `H` costs one multiply per frequency. That diagonalization *is* the convolution theorem. Inverting `H` (deconvolution, next subsection) is therefore "divide by each eigenvalue," which fails exactly where an eigenvalue is 0.

### 20.8 Where this shows up, so you know why it is worth the detour

- Blur from optics (finite pinhole, defocus, diffraction, lens aberrations) is a convolution with a PSF (Week 2 §3, §9; formalized in Week 4 §18).
- Motion blur is a convolution with a box along the motion direction (Week 4 §4.3, §23).
- Denoising/smoothing filters such as the Gaussian (Week 3 §12.2) are convolutions; the median and bilateral filters are *not* (they are non-linear).
- Demosaicking's interpolation and unsharp masking (Week 3 §14.1, §17) are convolutions.
- Hybrid images are a convolution (blur) and its complement.

> **Summary**
> - Convolution = stamp a copy of the kernel at every input sample (scaled by that sample's value) and add; equivalently, a sliding weighted average. **(x * h)[n] = Σ_m h[m] · x[n − m]**.
> - Blur from optics and most smoothing filters are convolutions; a camera's blur kernel is its point spread function (PSF), and any linear shift-invariant system is a convolution with its impulse response.
> - **Convolution theorem** to remember: DFT{x * h} = DFT{x} · DFT{h}, because sinusoids pass through a convolution unchanged except for scaling.
> - Linear-algebra view: convolution is a banded Toeplitz matrix, diagonalized by the Fourier basis.
> - *Next:* §21 uses the theorem to filter an image with a frequency mask.

---

## 21. Filtering in the Frequency Domain

**What problem this solves.** You want to keep only the coarse part of an image (or only the fine part) with precise control over where the split happens. A frequency-domain mask does this. Input: a shifted spectrum plus a 0/1 mask the same shape. Output: a filtered spectrum, which `ifftshift` and `ifft2` turn back into an image. Analogy: an audio equalizer that mutes the bass or the treble sliders, here with stripe patterns instead of pitches.

Once a spectrum is fftshift-ed (DC centered), building a filter becomes a simple masking operation: to keep only low image frequencies, zero out everything except a disc around the center — a **low-pass filter**. To keep only high image frequencies, do the opposite — zero out that disc and keep everything outside it — a **high-pass filter**, the complement of the low-pass mask.

Multiplying a spectrum by such a mask, then inverse-transforming back (`ifftshift`, then `ifft2`) to the spatial domain, produces a filtered image — and this turns out to be the *exact same operation* as the spatial-domain description (blurring by averaging neighboring pixels, as in §20; edge-extraction by subtracting a blur from the original). This equivalence is the **convolution theorem** (motivated and checked on numbers in §20.7) — multiplying two spectra together in the frequency domain is mathematically identical to *convolving* (the sliding weighted sum of §20) the two corresponding signals in the spatial domain. The frequency-domain route (mask + `fft2`/`ifft2`) and the spatial-domain route (blur/subtract) are two views of *one* operation, not two different techniques — the frequency-domain view is usually easier to control precisely (e.g., choosing an exact cutoff frequency as a mask radius), and it's the route HW1's own code path actually uses.

**Linear-algebra view (a mask is a projection):** in the Fourier basis, multiplying by a 0/1 mask is a **diagonal matrix** with 1s for the kept frequencies and 0s for the rest. Seen in pixel space, that operation is a **projection onto the subspace** spanned by the kept sinusoids. Applying it twice changes nothing more (P² = P). The high-pass mask is the complementary projection I − P onto the remaining sinusoids. Because the basis is orthogonal, the two pieces are orthogonal to each other and add back up to the original exactly.

**Linear-algebra view (convolution is a matrix the Fourier basis diagonalizes):** convolution with a fixed kernel is a **linear operator** (blur(a·x + b·y) = a·blur(x) + b·blur(y)), so it is some matrix acting on the image vector. It is also **shift-invariant** (the same weights are used at every position), so each row of the matrix is the row above shifted by one. With the wrap-around edges the DFT assumes, that is a **circulant** matrix (a **Toeplitz** matrix, constant along each diagonal, if edges are not wrapped). Every sinusoid is an **eigenvector** of every circulant matrix: blurring a pure wave returns the same wave, only scaled. The scale factors (eigenvalues) are exactly the kernel's own DFT. So switching to the Fourier basis **diagonalizes** the convolution matrix, and a full matrix–vector product becomes one multiplication per frequency. The convolution theorem is precisely this diagonalization. Week 5 ("Sampling, Linear Systems, Deconvolution") builds on this same matrix view of convolution.

**Worked example — continuing §19.1's 4-point signal x = [3, 1, −1, 1]:**
- *Projection.* A low-pass mask that keeps only k = 0 gives [1, 1, 1, 1]. Its complement (k = 1, 2, 3) gives [2, 0, −2, 0]. Their inner product is 0 (orthogonal), they sum back to **x**, and re-applying the low-pass mask to [1, 1, 1, 1] returns it unchanged.
- *Diagonalization.* The circular blur kernel [½, ¼, 0, ¼] (half weight on the sample itself, a quarter on each neighbor) builds the circulant matrix

  ```
  [ 0.5   0.25  0     0.25 ]
  [ 0.25  0.5   0.25  0    ]
  [ 0     0.25  0.5   0.25 ]
  [ 0.25  0     0.25  0.5  ]
  ```

  Each of the four basis vectors from §19.1 is an eigenvector of it, with eigenvalues [1, 0.5, 0, 0.5]. That list is also `np.fft.fft` of the kernel. So this blur keeps the average (1), halves the slow cycle (0.5), and wipes out the fastest flip (0): a low-pass filter.
- *Two routes, one answer.* The matrix times **x** gives [2, 1, 0, 1]. The frequency route gives the same result: [4, 4, 0, 4] × [1, 0.5, 0, 0.5] = [4, 2, 0, 2], and inverse-transforming that gives [2, 1, 0, 1].

> **Summary**
> - A frequency-domain filter is a 0/1 mask on the shifted spectrum: keep a disc around the center for **low-pass** (coarse content), keep everything outside it for **high-pass** (fine detail); then `ifftshift` and `ifft2`.
> - Masking is the same operation as blurring (or blur-and-subtract) by convolution; the mask route just gives exact control of the cutoff.
> - Linear-algebra views to remember: a mask is a projection (P² = P; high-pass = I − P, orthogonal to low-pass), and the Fourier basis diagonalizes the convolution (circulant) matrix.
> - *Where this goes next (optional):* the same theorem underlies the PSF and Wiener filtering (Week 5) and prior-based deconvolution (Week 6).

---

## 22. Hybrid Images (Oliva, Torralba & Schyns, 2006, SIGGRAPH)

Every "frequency" word in this section is **spatial frequency**, exactly as pinned down in §16.1 — how rapidly brightness changes as you scan across the image, nothing to do with color or with time — with one exception: §22.2's Fourier-domain mechanism works in **image frequency** (the fft2 `(u,v)` ruler from §19), not spatial frequency. §22.1 and §22.3 stay at the general/perceptual level where "spatial frequency" is correct.

**Core idea:** merge two different images into one composite such that:
- **Viewed up close** → the **high-spatial-frequency** (fine detail, sharp edges) content dominates perception → you see Image A.
- **Viewed from far away** → the **low-spatial-frequency** (coarse, blurry, "gist") content dominates perception → you see Image B.

### 22.1 What the two filters actually do to an image, concretely

Any photo can be thought of as a mix of coarse structure (the rough shapes and overall shading — low spatial frequency) plus fine structure layered on top (edges, texture, fine detail — high spatial frequency). The two filters split that mix apart:

- A **low-pass filter** blurs the image — literally, e.g. averaging each pixel with its neighbors. Averaging smooths out anything that changes quickly from pixel to pixel (high spatial frequency), while leaving slow, broad variations (low spatial frequency) mostly intact. The result looks like the original image out of focus.
- A **high-pass filter** does the opposite: subtract a blurred version of the image from the original. Whatever was slow/broad cancels out (since it was present in both the original and the blur), leaving only the fast-changing edges and fine texture behind — the result looks like a faint line drawing of just the edges, mid-gray everywhere else.

### 22.2 Mechanism, tying back to §16 to §21

In code, this isn't done by blurring and subtracting pixels directly — it's done in the frequency domain, using exactly the machinery §19 to §21 built:

1. Take Image A, compute its spectrum (`fft2`, then `fftshift` so the DC component sits at the center, §19.3 and §19.4), and apply a **high-pass mask** (§21) to keep only its high-`(u,v)` content — fine detail and sharp edges. Call this masked spectrum `H_A(u,v)`.
2. Take Image B, compute its spectrum the same way, and apply a **low-pass mask** to keep only its low-`(u,v)` content — coarse, smooth structure. Call this masked spectrum `L_B(u,v)`.
3. **Add the two masked spectra together**, entry by entry, per color channel — literal Fourier-domain addition, not a spatial-domain blend of pixel values:

   ```
   F_hybrid(u, v) = H_A(u, v) + L_B(u, v)
   ```

4. Undo the shift (`ifftshift`) and inverse-transform (`ifft2`) back to the spatial domain to recover the hybrid image's actual pixel values.

By the convolution theorem (§20.7, applied in §21), this frequency-domain construction is mathematically equivalent to §22.1's blur-and-subtract description — the two are the same operation, viewed in two different domains; the frequency-domain route is just the one that gives precise control over the cutoff.

**Linear-algebra view (a hybrid image is a sum of two projections):** writing each image channel as a vector (§19.3's aside), the whole recipe is **hybrid** = P_high **a** + P_low **b**. Here P_low is the low-pass projection onto the span of the low-frequency gratings, and P_high = I − P_low projects onto the rest (§21's aside). If the two masks are exact complements, as in §21, the two pieces live in **orthogonal subspaces**, so the sum mixes them without either overwriting the other. Your CSF at a given viewing distance acts like a third, perceptual filter that mostly lets through one of the two subspaces. Because `fft2`/`ifft2` are linear, adding in the frequency domain (step 3) gives the same result as adding the two filtered images pixel by pixel. That is another reason the frequency-domain and blur-and-subtract descriptions agree.

The result is a single image containing *both* spatial-frequency bands at once, stacked on top of each other. Which band you consciously perceive depends entirely on **viewing distance**, because — per §18 — your CSF determines which spatial-frequency band is currently sitting in your visible range at that distance.

### 22.3 Why it works perceptually, walked through with §16.3's logic

- **Image A's high-frequency content** (fine edges/detail) is, physically, made of small, tightly-packed features. Per §16.3: viewed **up close**, those small features subtend a large-enough visual angle that relatively few of them fit into one degree → their cpd sits in a visible (even peak-sensitivity, ~4–6 cpd) range → **you see Image A clearly**. Viewed **from far away**, those same tiny physical features subtend a much smaller visual angle, so many more of them cram into one degree → their cpd shoots up past the ~60 cpd cutoff → **they become invisible**.
- **Image B's low-frequency content** (broad, slowly-varying shapes) is made of large-scale features to begin with. Those stay at a low, visible cpd across a wide range of realistic viewing distances — including far away, where Image A's fine detail has already dropped out. So from a distance, Image B's coarse structure is essentially all that's left to see.

So the same printed composite gives you Image A up close and Image B from across the room, purely because your CSF (§18) admits a different spatial-frequency band at each distance — no trick beyond the ordinary physics of visual angle already covered in §8–9 and §16.3.

*(Note: the specific numeric cutoff frequency, filter radius in pixels, and print-size calculations are exactly what HW1 Task 3 asks you to derive yourself — intentionally left out of these notes.)*


> **Summary**
> - A hybrid image adds Image A's high-frequency content to Image B's low-frequency content: **F_hybrid(u,v) = H_A(u,v) + L_B(u,v)**, per color channel, then inverse-transforms.
> - Up close, A's fine detail is visible; from far away its cpd passes the CSF cutoff and only B's coarse shapes remain.
> - Linear-algebra view: hybrid = P_high a + P_low b, a sum of projections onto orthogonal subspaces.
> - The specific cutoffs and print sizes for HW1 Task 3 are left to the assignment.
> - *Next:* §23 steps back to the reverse of blurring; §24 collects the lecture's summary numbers.

---

## 23. Deconvolution: A First Look at the Reverse Problem

**Forward vs. inverse.** *Forward problem:* given a sharp signal and a kernel, compute the blurred result (convolution, §20). *Inverse problem:* given the blurred result (and, usually, the kernel), recover the sharp signal. **Deconvolution** is that inverse problem. This is only a primer so the word is never undefined; the real treatment (the exact formulas, the Wiener filter) is **Week 5**, and priors that tame the hard cases are **Week 6**.

**Analogy.** Convolution is stirring a drop of dye into a glass of water; deconvolution is un-stirring it. If you know exactly how the water was stirred, and measured exactly, the motion can in principle be reversed. If your measurement is slightly off, or some detail was mixed beyond recovery, the "un-stirred" result will be garbage. Both halves of that sentence are the whole subject.

**How it works in the simplest case: divide in the Fourier domain.** The theorem (§20.7) says blurring multiplies each frequency by `DFT{h}`. To undo it, divide each frequency of the blurred spectrum by `DFT{h}` and inverse-transform. This is the **inverse filter**. Linear-algebra view: it is applying `H⁻¹`, and in the Fourier basis `H⁻¹` is a diagonal matrix of `1/DFT{h}`.

**Why it is hard (an ill-posed problem).** A problem is **ill-posed** if it has no solution, many solutions, or a solution that changes wildly when the data change slightly. Deconvolution suffers from the last two:
- *Exact zeros (information destroyed).* Where `DFT{h} = 0`, the blurred spectrum is 0 whatever the original was, so many different originals give the *same* blurred image (the null space, Week 4 §18.2). Division by 0 is undefined. (A box kernel, such as ordinary motion blur or a plain circular aperture, has such zeros, which is why Week 4 §19 and §23 engineer kernels without them.)
- *Near-zeros (noise amplification).* Where `DFT{h}` is small but not zero, dividing by it multiplies any noise present at that frequency by `1/DFT{h}`, a large number. Real measurements always contain noise (Week 2 §18, Week 4 §3), so the "recovered" image can be dominated by amplified noise.
- *Regularization* is the family of remedies: add a preference (a prior) for plausible answers (for instance, "do not trust frequencies where the blur has nearly removed the signal," or "natural images are mostly smooth"), trading a little sharpness for stability. The **Wiener filter** (Week 5) is the first, noise-aware version: instead of `1/H` it uses a damped factor that falls toward 0 where `H` is small. Week 6's ADMM-based methods use richer priors.
- *Non-blind vs. blind.* **Non-blind** deconvolution means the kernel is known (measured or calibrated). **Blind** deconvolution means the kernel is unknown too and must be estimated along with the sharp image, a much harder problem (which is why Week 4 §24's motion-invariant camera tries to make the unknown blur known in advance).

**Small numeric illustration with a LiDAR flavor (a pulse-shape blur).** A pulsed LiDAR fires a short laser pulse and records, with a detector sampled at fixed time ticks, when reflections come back (Week 4 §5). The recorded waveform is *not* the scene's reflections themselves: every reflection arrives smeared by the pulse's own shape and the detector's response (together, the **system impulse response**), so the measured signal is `measured = (true returns) * (impulse response)` plus noise. A convolution again, here along *time* instead of space (the "frequency" in this example is the temporal frequency of the return waveform, not image frequency or light's wavelength).

Numbers (chosen small by hand; `c` is the speed of light):
- Sample the waveform every 1 ns. Each tick of round-trip time is `c·Δt/2 ≈ 3×10⁸ × 1×10⁻⁹ / 2 = 0.15 m` of range (the round-trip rule `d = c·τ/2` of Week 4 §5.1).
- True scene: two surfaces, e.g. a branch and a wall behind it, 2 ticks apart (0.30 m): strength 1.0 at tick 3, strength 0.5 at tick 5. As a list over 8 ticks: `[0, 0, 0, 1, 0, 0.5, 0, 0]`.
- Impulse response (pulse + detector blur), a 3-tap kernel centered on each return: `[0.2, 0.6, 0.2]`.
- Measured (circular convolution; the returns sit away from the ends so wrap-around is harmless): `[0, 0, 0.2, 0.6, 0.3, 0.3, 0.1, 0]`. One fat peak at tick 3 with a flat shoulder: a peak finder would see one surface, and the second one is almost hidden.
- Kernel spectrum `DFT{h}` over the 8 frequencies, `0.6 + 0.4·cos(2πk/8)`: `[1, 0.883, 0.6, 0.317, 0.2, 0.317, 0.6, 0.883]`. No exact zeros (smallest, 0.2, at the fastest-alternating frequency).
- Dividing the measured spectrum by this and transforming back gives `[0, 0, 0, 1, 0, 0.5, 0, 0]`: both returns, at the right ticks and strengths. Two peaks 0.30 m apart that the raw waveform could not separate are now resolved.
- Noise sensitivity: add a faint ±0.02 alternating wiggle (the fastest frequency, where the kernel passes only 0.2 of the signal) to the measurement. Dividing by 0.2 multiplies that wiggle by 5, so the recovered waveform becomes `[0.1, −0.1, 0.1, 0.9, 0.1, 0.4, 0.1, −0.1]`: spurious ±0.1 bumps, 20% as strong as the weaker real return. Real systems add a regularizer for exactly this reason.

**Related operation: matched filtering (cross-correlation).** To *detect* a known pulse shape buried in noise, a LiDAR receiver slides a copy of the expected pulse over the waveform and records how well it matches at each offset: a cross-correlation. This is the best linear detector for a known pulse in white noise, but it does not sharpen: for the numbers above, correlating with `[0.2, 0.6, 0.2]` convolves the returns with the pulse's autocorrelation `[0.04, 0.24, 0.44, 0.24, 0.04]`, which is *wider* than the pulse. Matched filtering answers "is there a return, and about when?"; deconvolution tries to answer "what are the separate returns, finely resolved?". Continuous-wave ToF sensors correlate the received light with the sent modulation for the same reason (Week 4 §5; the dedicated ToF lecture later).

**Why deconvolution matters for this course (map).**
- *Defocus and motion blur* (Week 2 §9; Week 4 §4.3): the blur is a known-ish kernel, and sharpening the photo is deconvolution.
- *Coded aperture, extended depth of field, flutter shutter, parabolic sweep* (Week 4 §19 to §24): these all choose the blur kernel on purpose so its spectrum has no exact zeros (is **broadband**) and a later deconvolution can recover the scene. The camera hardware and the deconvolution software are designed together.
- *LiDAR / time-of-flight:* resolving closely spaced returns, sharpening range peaks beyond the pulse width, and handling multipath (several surfaces in one pixel) are deconvolution problems along the time axis.
- *Everywhere noise matters:* the better the kernel's spectrum behaves, the less noise is amplified.

> **Summary**
> - **Deconvolution** is the inverse of convolution: recover the sharp signal from the blurred one, in the simplest case by dividing the spectrum by the kernel's spectrum (the inverse filter).
> - It is **ill-posed**: exact zeros in the kernel's spectrum destroy information, near-zeros amplify noise, so real methods add regularization (Wiener filter in Week 5, priors in Week 6).
> - LiDAR flavor: a pulsed LiDAR's recorded waveform is the true returns convolved with the system impulse response; deconvolving can separate returns closer together than the pulse width. Matched filtering (cross-correlation) detects a pulse but does not sharpen.
> - *Next:* §24 collects the lecture's summary numbers.

---

## 24. Lecture's Summary Slide — Reproduced and Explained

The lecture ends with a compact summary of every number introduced. Reproduced here with the section reference for each:

- **Visual acuity**: 20/20 is about 1 arcminute (§8)
- **Field of view**: ~190° monocular, ~120° binocular, ~135° vertical (§10)
- **Temporal resolution**: ~60 Hz (varies with contrast and luminance): how fast a flickering stimulus must change before it looks steady to us (this is *temporal* frequency, §16.1); relevant later for flutter-shutter/coded-exposure photography (Week 4) and displays generally
- **Dynamic range**: ~6.5 f-stops instantaneous, adapts up to ~46.5 total (§15, including why the instantaneous figure is not a unit conversion of ~5 orders of magnitude)
- **Color**: describable by the CIE xy chromaticity diagram; perceptual distances between colors are approximately uniform in CIE Lab space (a color space designed so that equal numeric distances correspond to roughly equal perceived color differences). Both are built in Week 3.
- **Depth cues in 3D displays**: vergence, focus (accommodation), their potential conflict, and resulting (dis)comfort (§11–§13)
- **Accommodation range**: ~8 cm to ∞ (young), degrading with age (§3)

> **Summary**
> - Numbers to keep: acuity ~1 arcmin; FOV ~190° / ~120° / ~135°; flicker ~60 Hz; dynamic range ~46.5 stops total; accommodation 8 cm to infinity (young).
> - Every one of them is an *angle* or a *ratio*, which is why the notes measure things in visual angle, cycles per degree and stops.
> - *Next:* Week 2 starts the camera side: how a lens and aperture form an image.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check
If you can explain, in your own words, *why* a hybrid image looks different up close vs. far away using only the words "spatial frequency," "contrast sensitivity function," and "low/high-pass filter" — you've understood the core idea of Week 1.
