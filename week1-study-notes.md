# CSC2529 Computational Imaging — Week 1 Study Notes

**Topic:** Human Visual System
**Source:** Lecture 1 slides (D. Lindell, CSC2529, Fall 2026), Oliva/Torralba/Schyns 2006 "Hybrid Images" (SIGGRAPH)
**Scope:** Logistics slides skipped — notes start from "The Human Visual System."

---

## 0. Why start a computational imaging course with the human eye?

Computational imaging is about designing a *whole pipeline*: optics → sensor → computation, with the goal of producing an image (or piece of information) that is ultimately consumed by a human or a downstream algorithm. Before you can design good optics/sensors/algorithms, you need a model of the "detector" the image is really for: human vision. The eye is also a physical instrument built from optics (cornea, lens) and sensing (retina) — comparing it to a digital camera is the fastest way to build intuition for both.

The lecture frames this with a simple triangle:

> **Computational Imaging = Optics + Sensing + Computation**

Traditional cameras separate these three (a fixed lens, a passive sensor, and image processing bolted on afterward). Computational imaging co-designs them — e.g., a coded aperture (a specially shaped opening that controls how light enters a lens — full definition in §1, where the eye's own version of this shows up) *jointly* changes the optics and the deconvolution algorithm on purpose.

---

## 1. Anatomy of the Human Eye

Cross-section, front to back:

| Structure | Role |
|---|---|
| **Cornea** | The clear, curved front surface. Does *most* of the eye's fixed focusing power (it's a strong, non-adjustable lens). |
| **Aqueous humour** (anterior chamber) | Clear fluid between cornea and lens; maintains eye pressure/shape. |
| **Iris / Pupil** | The iris is the colored muscle ring; the pupil is the hole in its middle. The iris contracts/dilates the pupil to control how much light enters — this is the eye's **aperture**. (*Aperture* is camera terminology for "the opening that controls how much light gets let in": a wider opening lets in more light, a narrower one lets in less — exactly like your pupil widening in the dark and shrinking in bright light. Every camera lens has one, usually made of adjustable overlapping blades rather than a muscle.) |
| **Lens** | A flexible, adjustable lens behind the iris. Fine-tunes focus by changing shape (see *accommodation*, §5). |
| **Ciliary muscle / zonular (suspensory) fibers** | Muscles and fibers attached to the lens that squeeze or relax it to change its shape/focal power. |
| **Vitreous humour** | Clear gel filling the main eyeball cavity, behind the lens. |
| **Retina** | The light-sensitive "**sensor**" layer at the back of the eye (see §2). (In a digital camera, the *image sensor* is the electronic chip that sits where photographic film used to go — it converts incoming light into an electrical signal that becomes a digital image. The retina does the same biological job.) |
| **Choroid** | A blood-vessel-rich layer behind the retina; supplies oxygen/nutrients and absorbs stray light (like the black interior paint of a pinhole camera — this is *literally why HW1 has you paint the box interior black*: to stop internal reflections from ruining contrast). |
| **Sclera** | The white, tough outer shell of the eyeball — structural support, like a camera body. |
| **Fovea** | A small pit in the retina, directly behind the pupil, packed with cone photoreceptors — this is where sharp, color vision happens (see §2, §3). |
| **Optic disc** | The spot where the optic nerve and retinal blood vessels exit the eye. It has *no* photoreceptors — this is your **blind spot**. |
| **Optic nerve** | Carries the electrical signal from retina to brain. |

**Key terminology:**
- *Accommodation* — the eye's ability to change focus by physically changing lens shape (ciliary muscle contracts → lens gets rounder/more powerful, for near focus).
- *Emmetropia* — normal-sighted eye (see §6, refractive errors).

---

## 2. The Retina: Rods and Cones

The retina is a layered neural circuit, not just a passive light-sensitive film:

**Light path through the retina layers (light enters from the *inner* side first, counter-intuitively):**

Light → Ganglion cells → Bipolar cells (+ horizontal/amacrine cells for lateral processing) → **Photoreceptors (rods & cones)** → Retinal pigment epithelium → (absorbed)

So light actually passes through several neuron layers *before* hitting the photoreceptors, which sit at the very back, pointed away from incoming light. The photoreceptor signal then travels back forward through the bipolar and ganglion cells, whose axons bundle into the optic nerve.

**Two types of photoreceptors:**

| | Rods | Cones |
|---|---|---|
| Count | ~120 million | ~6 million |
| Sensitivity | Very high — used in **low light / night vision** | Lower — need brighter light |
| Color | Colorblind (one type only) | 3 types (color vision, see §4) |
| Location | Spread across the periphery of the retina | Densely packed in the **fovea** (center) |
| Acuity | Low spatial resolution | High spatial resolution |

**Why this matters:** your sharp, colorful vision only exists in a *tiny* central region (the fovea) that you're constantly darting your eyes ("saccades") around to sample — you don't actually perceive the world in uniform high resolution the way a camera sensor captures a frame. This non-uniform, foveated sampling is a recurring theme that resurfaces later when the course discusses light-field/foveated displays and compressive/adaptive sensing.

A key experimental data point cited in lecture (Roorda & Williams, 1999, *Nature*): imaging the living human cone mosaic in the fovea, they found individual cones separated by about **5 arcminutes of visual angle** — i.e., that's roughly the finest-grain "sampling grid" your retina's cone mosaic provides at the very center of vision. (An arcminute is 1/60th of a degree — see §8 for how this becomes the basis for acuity limits.)

---

## 3. Color Perception

Visible light is a narrow slice (~400–700 nanometers) of the full electromagnetic spectrum, between ultraviolet and infrared.

Color vision comes from **three types of cones**, each with a different (overlapping) sensitivity curve over wavelength:

- **S (short)** cones — peak near ~440 nm (bluish)
- **M (medium)** cones — peak near ~545 nm (greenish)
- **L (long)** cones — peak near ~565 nm (yellowish-red)

Note the M and L curves overlap *heavily* — this is why the "green" and "red" cones are so easily confused/aliased by the visual system, and it's a key reason color is represented as a 3-number (tristimulus) space rather than measuring wavelength directly: **your eye doesn't measure wavelength, it measures three overlapping weighted sums of the incoming spectrum.** Two physically different spectra that produce the same 3 cone responses look *identical* to you — this phenomenon is called **metamerism**, and it's the whole reason RGB displays/cameras work at all (they don't need to reproduce the true spectrum, just match your 3 cone responses).

---

## 4. Eye vs. Camera

The lecture draws a direct structural analogy:

| Eye | Camera |
|---|---|
| Cornea + lens | Lens |
| Iris/pupil | Aperture |
| Retina | Image sensor |
| Fovea (non-uniform density, denser in center) | Uniform pixel grid |
| 3 cone types, irregularly interleaved | Bayer color filter array (regular RGGB mosaic) |

A digital camera sensor is actually colorblind on its own — each individual light-sensing pixel can only measure *brightness*, not color. To get color, manufacturers glue a **Bayer color filter array** directly on top of the sensor: a physical grid of tiny red, green, and blue filters, one per pixel, arranged in a repeating 2×2 tile of one red, two green, and one blue filter ("**RGGB**" — green is doubled because human vision is most sensitive to green, per §3's cone curves). Each pixel then only ever records *one* of the three colors; the other two get computationally filled in later, a process called *demosaicking* (Week 3).

Two important **disanalogies** to remember:
1. The retina's cone mosaic is **irregular/random**, not a neat repeating grid like a camera's Bayer pattern.
2. Sampling density is **non-uniform** (dense at fovea, sparse at periphery) — a camera sensor samples uniformly across the whole frame.

Both of these differences matter a lot later in the course when we discuss demosaicking (Week 3) and non-uniform/adaptive sampling schemes.

---

## 5. Oculomotor Processes (Accommodation)

*Accommodation* is the active process of changing the eye's focal power (mainly by changing lens shape via the ciliary muscle) to focus on objects at different distances — near focus vs. far focus.

Your accommodation *range* (the span of distances you can bring into sharp focus) shrinks with age:
- **At ~16 years old:** can accommodate from about **8 cm to infinity**.
- **At ~50 years old:** typically down to about **50 cm to infinity** — the near range is largely lost.

This age-related loss of near-focus ability is called **presbyopia** (why people need reading glasses as they age) — the lens becomes stiffer and the ciliary muscle can no longer deform it enough for close focus.

---

## 6. Refractive Errors

Four categories, defined by *where light rays converge relative to the retina*:

| Condition | What happens | Correction |
|---|---|---|
| **Emmetropia** | Normal — rays focus exactly on the retina | None needed |
| **Myopia** (nearsightedness) | Rays focus *in front of* the retina (eyeball too long / cornea too curved) | **Concave (diverging)** lens |
| **Hypermetropia / Hyperopia** (farsightedness) | Rays focus *behind* the retina (eyeball too short) | **Convex (converging)** lens |
| **Astigmatism** | Cornea is irregularly curved (not spherical), so rays don't converge to a single point at all | **Cylindrical** lens (corrects only the irregular axis) |

This is a nice concrete example of "optics can be broken in a specific, geometrically describable way, and correction is just adding a compensating optical element" — the same logic (add optics or add computation to compensate for a known aberration) will reappear constantly in computational imaging.

---

## 7. Visual Field / Field of View (FOV)

- **Monocular FOV** (one eye): ~190°
- **Binocular FOV** (both eyes overlapping): ~120°
- **Vertical FOV**: ~135°

This matters directly for designing displays (e.g., "how important is FOV for immersive VR?" — a wide FOV headset is trying to fill as much of this natural visual field as possible) and for the pinhole camera in HW1 (field of view of your pinhole box is a geometric function of pinhole-to-screen distance and screen size — same angular-FOV concept, applied to a man-made "eye").

---

## 8. Visual Acuity

**Visual angle** is the angular size an object subtends at your eye — it depends on *both* the object's physical size and its distance, not size alone. It's measured in degrees, or in smaller units of **arcminutes** (1° = 60 arcmin) and arcseconds (1 arcmin = 60 arcsec).

- **20/20 vision** (the "normal" acuity reference) corresponds to being able to resolve detail at about **1 arcminute** of visual angle.
- The **Snellen chart** (the classic eye-test letter chart) is built around this: each letter's individual strokes are designed to subtend 1 arcminute at the standard test distance when you can *just barely* read that row, and the whole letter subtends 5 arcminutes.

So "acuity" is fundamentally a statement about the smallest *angle* your visual system can resolve — not a raw distance or pixel count. This angular framing is what lets you compare, e.g., a phone screen 30cm from your face to a movie screen 10m away on equal footing (see §9).

---

## 9. Retina Displays — Worked Example

This is the lecture's worked example of turning the acuity concept (§8) into a concrete engineering number, using basic trigonometry.

**Setup:** if the eye can just resolve a visual angle of α (≈1 arcmin, from §8), and the viewer sits at distance *d* from a screen, what is the physical size *p* of the smallest resolvable feature (pixel) on that screen?

**Formula:**

```
p = 2 · d · tan(α / 2)
```

*(derivation intuition: the resolvable feature subtends a small angle α at the eye; draw the right-triangle from eye to the two edges of that feature at distance d — half the feature width is d·tan(α/2), so the full width is 2d·tan(α/2))*

**Worked numbers from lecture (Steve Jobs' "Retina Display" claim):** for a tablet viewed at **12 inches**, with α = 1 arcminute:

```
p = 2 × 12" × tan(0.5 arcmin) ≈ 0.0035"
```

Converting that resolvable pixel pitch to a dot density (**dpi**, "dots per inch" — how many printed dots or screen pixels are packed into one inch; higher dpi means finer, less visible pixel structure, assuming the eye is even able to resolve it): **≈ 286 dpi** is the density at which pixels become individually unresolvable at 12 inches — Apple's marketing claim was **300 dpi**, i.e., *slightly* above the computed "retina" threshold (300 > 286), which is the point of the slide: the marketing number is a real, checkable physical claim, not just a buzzword, and it holds up to the math (with a small safety margin).

**Why this generalizes:** the same formula tells you that "how many pixels fall in your fovea" is a *moving target* that depends entirely on viewing distance — a screen designed to be "retina" at 12 inches would look pixelated at 3 inches and be wastefully over-resolved at 3 meters. This exact idea — same physical image, different perceived spatial frequency content depending on distance — is the entire mechanism behind hybrid images (§13) and is exactly what HW1 Task 3 asks you to compute for a printed photo at two different viewing distances.

---

## 10. Dynamic Range

**Dynamic range** = the ratio between the brightest and darkest signal a system can represent, usually expressed in **f-stops** (each stop = a factor of 2×) or **orders of magnitude** (factors of 10×).

From the lecture:
- **Full human luminance vision range** (across all adaptation states — from starlight to sunlight): about **14 orders of magnitude** (10¹⁴×).
- **Instantaneous** human range (without the eye re-adapting, e.g., pupil dilation / photoreceptor bleaching adjustments): about **5 orders of magnitude** (≈ this is often quoted elsewhere as ~6.5 f-stops instantaneously, per the lecture's own summary slide).
- **Typical digital displays (at the time of the cited slide)**: only about **3 orders of magnitude**.

This large gap between what the eye can perceive and what a standard display can reproduce is exactly the motivation for **HDR (high dynamic range) imaging and displays** (Week 4 topic) — e.g., "Sunnybrook" style HDR displays that add a secondary low-resolution backlight array behind an LCD panel to multiply the achievable contrast ratio.

---

## 11. Contrast

Before you can even define a "contrast sensitivity function," you need a numeric definition of contrast itself — and there isn't just one:

- **Weber contrast**: designed for a single, small feature on a large uniform background.
  ```
  C_weber = (I_feature − I_background) / I_background
  ```
  Good when there's one clear "object" and one clear "background" luminance.

- **Michelson contrast**: designed for periodic/repeating patterns (like the sinusoidal gratings used in CSF experiments, §12), where there's no single "background."
  ```
  C_michelson = (I_max − I_min) / (I_max + I_min)
  ```
  This normalizes by the *average* of the brightest and darkest parts of the pattern, which makes sense for a repeating stripe pattern where "background" isn't well-defined.

**Takeaway:** "contrast" is context-dependent — which formula you use depends on whether you're describing a single feature (Weber) or a repeating pattern (Michelson). CSF experiments (next section) use grating stimuli, so Michelson contrast is the natural definition there.

---

## 12. Contrast Sensitivity Function (CSF)

This is the most important technical concept of Week 1, and it's the direct theoretical basis for HW1 Task 3.

**Setup:** psychophysics experiments (Campbell & Robson, 1968) show subjects sinusoidal grating patterns (alternating light/dark stripes) at different **spatial frequencies** and different **contrasts**, and find the *minimum contrast* at which the subject can just barely detect the stripes. The reciprocal of that minimum detectable contrast is the subject's **contrast sensitivity** at that spatial frequency.

**Spatial frequency** here is measured in **cycles per degree (cpd)** of visual angle — i.e., how many light/dark stripe pairs fit into one degree of your field of view. This is a crucial unit because it's *perceptual*, not physical: the same physical stripe pattern has a different cpd value depending on how far away you're standing (closer → the same physical stripes subtend a larger visual angle → fewer cycles per degree; farther → more cycles per degree). This distance-dependence is exactly the mechanism hybrid images exploit (§13).

**Shape of the CSF curve (plotted as contrast sensitivity vs. spatial frequency):**
- It is **band-pass**, not low-pass or flat: sensitivity is *reduced* at very low spatial frequencies (large, slowly-varying patterns) *and* at very high spatial frequencies (fine detail), and **peaks around 4–6 cycles per degree**.
- At the high-frequency end, sensitivity eventually drops to zero around the physical sampling limit imposed by **cone packing density (~60 cpd)** — you simply cannot perceive stripes finer than your photoreceptor mosaic can sample, a direct callback to the retina/acuity material in §2 and §8.
- Critically: **the CSF curve shifts depending on viewing distance**, because — as above — the same *physical* image pattern maps to a different cpd value as your distance to it changes. Move closer → that pattern's apparent spatial frequency (in cpd) decreases, potentially moving it toward the peak of your CSF (more visible); move farther away → its cpd increases, potentially pushing it past your visible range (less visible, eventually invisible).

**Why this matters (the big idea):** because visibility of a given spatial-frequency band depends on viewing distance, you can construct an image where **high spatial frequencies are only visible up close** and **low spatial frequencies dominate perception from far away** — and that's precisely a hybrid image.

---

## 13. Hybrid Images (Oliva, Torralba & Schyns, 2006, SIGGRAPH)

**Core idea:** merge two different images into one composite such that:
- **Viewed up close** → the **high-frequency** (fine detail, sharp edges) content dominates perception → you see Image A.
- **Viewed from far away** → the **low-frequency** (coarse, blurry, "gist") content dominates perception → you see Image B.

**Mechanism, tying directly back to §12:**
1. Take Image A, apply a **high-pass filter** (keep only fine detail / sharp edges, remove smooth/coarse structure).
2. Take Image B, apply a **low-pass filter** (keep only coarse, smooth/blurry structure, remove fine detail).
3. **Add the two filtered images together** (this is done in the Fourier/frequency domain in the course's approach — filtering each color channel separately, per the homework's advice).
4. The result is a single image containing *both* frequency bands simultaneously. Which one you consciously perceive depends entirely on **viewing distance**, because (per §12) your CSF determines which spatial-frequency band is currently visible to you at that distance.

**Why it works perceptually:** the high-frequency content becomes imperceptible once its cpd (which increases as you back away) moves past your CSF's visible range — so from far away, only the low-frequency image "survives" perceptually, and vice versa up close.

*(Note: the specific numeric cutoff frequency, filter radius in pixels, and print-size calculations are exactly what HW1 Task 3 asks you to derive yourself — intentionally left out of these notes.)*

---

## 14. Depth Perception

Human depth perception combines many independent cues, grouped into two families:

**Monocular cues** (work with just one eye):
- **Perspective** (parallel lines converging toward a vanishing point)
- **Relative size** (same object type appears smaller when farther away)
- **Absolute size** (known real-world size of familiar objects)
- **Occlusion** (an object blocking another is in front of it)
- **Accommodation** (the eye's focus state, from §5, is itself a weak depth cue)
- **Retinal blur** (out-of-focus objects are perceived as being at a different depth)
- **Motion parallax** (nearer objects appear to move faster across your view than farther objects, as you move)
- **Texture gradients** (texture appears finer/denser as distance increases)
- **Shading** (how light and shadow fall on a surface implies its 3D shape)

**Binocular cues** (require two eyes):
- **(Con)vergence** — the inward rotation angle of both eyes needed to fixate on a near object (more rotation = closer object)
- **Disparity / parallax** — the difference in each eye's retinal image of the same scene, which the brain decodes into depth (this is the basis of stereoscopic 3D)

**Visual illusions** (e.g., M.C. Escher drawings, or the Held et al. 2006 SIGGRAPH illusion demos) are used pedagogically to show that these cues can be *individually* tricked/isolated — if a picture violates one cue (e.g., impossible occlusion) while satisfying others, you get a perceptual paradox, which is strong evidence that these are genuinely separable computational cues rather than one monolithic "depth sense."

---

## 15. Stereoscopic Displays & a Brief History of VR

**Stereoscopic** comes from *stereo* ("two"/"solid") + *scopic* ("viewing") — literally "two-eyed viewing." It describes anything that recreates depth by giving each eye a slightly different image, the way ordinary binocular vision already works: your two eyes sit a few centimeters apart, so each sees the same scene from a slightly different horizontal viewpoint, and the difference between those two views (**binocular disparity**, §14) is what your brain decodes into depth.

A **stereoscopic** device or display exploits this on purpose: instead of showing both eyes the same flat image, it feeds each eye its own slightly-offset image, so the brain perceives depth that isn't really there on a flat screen or print. Stereoscopic 3D displays work by presenting each eye a slightly different image (mimicking binocular disparity, §14) so the brain fuses them into a perceived depth.

Brief timeline given in lecture:
- **1838**: Charles Wheatstone invents the **stereoscope** — the first device to present offset images to each eye and produce a 3D perception (predates photography-based stereo images; early stereoscopes used stereo pairs of drawings/photos, e.g., a 1865 stereo photo of Lincoln shown in lecture).
- **1968**: Ivan Sutherland builds an early head-mounted VR/AR display.
- **2012–2022**: the modern VR "explosion" (Oculus, Sony, Valve, Microsoft, etc.).

---

## 16. Vergence-Accommodation Conflict (VAC)

This is a specific, important problem with conventional stereoscopic displays (glasses-based 3D, most VR headsets):

- **In the real world**, *vergence* (§14, how much your eyes rotate inward to fixate an object) and *accommodation* (§5, how your lens focuses) both point to **the same distance** — they naturally match.
- **On a stereo display**, the two eyes are shown offset images that make you *verge* your eyes to a simulated depth (say, an object appears 2m away) — but your eyes must still *accommodate* (focus) at the **actual physical screen distance** (e.g., a headset lens at a fixed distance), which is usually different from the simulated depth.

This mismatch — verging to one distance while accommodating to another — is the **vergence-accommodation conflict**, and it's the leading cause of visual discomfort, fatigue, eyestrain, and nausea in stereo 3D/VR displays. It's also the direct engineering motivation for **light field displays** and future **holographic displays** (mentioned as near-/long-term solutions), which can (in principle) present a physically correct focus depth per pixel instead of a fixed screen distance — this connects forward to the light field imaging week (Week 9).

---

## 17. Lecture's Summary Slide — Reproduced and Explained

The lecture ends with a compact summary of every number introduced. Reproduced here with the section reference for each:

- **Visual acuity**: 20/20 is about 1 arcminute (§8)
- **Field of view**: ~190° monocular, ~120° binocular, ~135° vertical (§7)
- **Temporal resolution**: ~60 Hz (varies with contrast and luminance) — how fast a flickering/changing stimulus needs to be before it appears smooth/continuous to us; relevant later for flutter-shutter/coded-exposure photography (Week 4) and displays generally
- **Dynamic range**: ~6.5 f-stops instantaneous, adapts up to ~46.5 total (equivalently the ~5 vs. ~14 orders of magnitude figures in §10 — these are two different ways of citing the same underlying range)
- **Color**: describable by the CIE xy chromaticity diagram; perceptual distances between colors are approximately linear (uniform) in CIE Lab space (a color space designed so that equal numeric distances correspond to roughly equal perceived color differences)
- **Depth cues in 3D displays**: vergence, focus (accommodation), their potential conflict, and resulting (dis)comfort (§14–§16)
- **Accommodation range**: ~8 cm to ∞ (young), degrading with age (§5)

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check
If you can explain, in your own words, *why* a hybrid image looks different up close vs. far away using only the words "spatial frequency," "contrast sensitivity function," and "low/high-pass filter" — you've understood the core idea of Week 1.
