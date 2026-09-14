# CSC2529 Computational Imaging — Week 1 Study Notes

**Topic:** Human Visual System
**Source:** Lecture 1 slides (D. Lindell, CSC2529, Fall 2026), Oliva/Torralba/Schyns 2006 "Hybrid Images" (SIGGRAPH)
**Scope:** Logistics slides skipped — notes start from "The Human Visual System."

---

## 0. Why start a computational imaging course with the human eye?

Computational imaging is about designing a *whole pipeline*: optics → sensor → computation, with the goal of producing an image (or piece of information) that is ultimately consumed by a human or a downstream algorithm. Before you can design good optics/sensors/algorithms, you need a model of the "detector" the image is really for: human vision. The eye is also a physical instrument built from optics (cornea, lens) and sensing (retina) — comparing it to a digital camera is the fastest way to build intuition for both.

The lecture frames this with a simple triangle:

> **Computational Imaging = Optics + Sensing + Computation**

Traditional cameras separate these three (a fixed lens, a passive sensor, and image processing bolted on afterward). Computational imaging co-designs them — e.g., a [coded aperture](https://en.wikipedia.org/wiki/Coded_aperture) (a specially shaped opening that controls how light enters a lens — full definition in §1, where the eye's own version of this shows up) *jointly* changes the optics and the deconvolution algorithm on purpose.

---

## 1. Anatomy of the Human Eye

Cross-section, front to back:

| Structure | Role |
|---|---|
| **[Cornea](https://en.wikipedia.org/wiki/Cornea)** | The clear, curved front surface. Does *most* of the eye's fixed focusing power (it's a strong, non-adjustable lens). |
| **[Aqueous humour](https://en.wikipedia.org/wiki/Aqueous_humour)** (anterior chamber) | Clear fluid between cornea and lens; maintains eye pressure/shape. |
| **[Iris](https://en.wikipedia.org/wiki/Iris_(anatomy)) / [Pupil](https://en.wikipedia.org/wiki/Pupil)** | The iris is the colored muscle ring; the pupil is the hole in its middle. The iris contracts/dilates the pupil to control how much light enters — this is the eye's **[aperture](https://en.wikipedia.org/wiki/Aperture)**. (*Aperture* is camera terminology for "the opening that controls how much light gets let in": a wider opening lets in more light, a narrower one lets in less — exactly like your pupil widening in the dark and shrinking in bright light. Every camera lens has one, usually made of adjustable overlapping blades rather than a muscle.) |
| **[Lens](https://en.wikipedia.org/wiki/Lens_(vertebrate_anatomy))** | A flexible, adjustable lens behind the iris. Fine-tunes focus by changing shape (see *accommodation*, §5). |
| **[Ciliary muscle](https://en.wikipedia.org/wiki/Ciliary_muscle) / [zonular (suspensory) fibers](https://en.wikipedia.org/wiki/Zonule_of_Zinn)** | Muscles and fibers attached to the lens that squeeze or relax it to change its shape/focal power. |
| **[Vitreous humour](https://en.wikipedia.org/wiki/Vitreous_body)** | Clear gel filling the main eyeball cavity, behind the lens. |
| **[Retina](https://en.wikipedia.org/wiki/Retina)** | The light-sensitive "**sensor**" layer at the back of the eye (see §2). (In a digital camera, the *[image sensor](https://en.wikipedia.org/wiki/Image_sensor)* is the electronic chip that sits where photographic film used to go — it converts incoming light into an electrical signal that becomes a digital image. The retina does the same biological job.) |
| **[Choroid](https://en.wikipedia.org/wiki/Choroid)** | A blood-vessel-rich layer behind the retina; supplies oxygen/nutrients and absorbs stray light (like the black interior paint of a pinhole camera — this is *literally why HW1 has you paint the box interior black*: to stop internal reflections from ruining contrast). |
| **[Sclera](https://en.wikipedia.org/wiki/Sclera)** | The white, tough outer shell of the eyeball — structural support, like a camera body. |
| **[Fovea](https://en.wikipedia.org/wiki/Fovea_centralis)** | A small pit in the retina, directly behind the pupil, packed with cone photoreceptors — this is where sharp, color vision happens (see §2, §3). |
| **[Optic disc](https://en.wikipedia.org/wiki/Optic_disc)** | The spot where the optic nerve and retinal blood vessels exit the eye. It has *no* photoreceptors — this is your **[blind spot](https://en.wikipedia.org/wiki/Blind_spot_(vision))**. |
| **[Optic nerve](https://en.wikipedia.org/wiki/Optic_nerve)** | Carries the electrical signal from retina to brain. |

**Key terminology:**
- *[Accommodation](https://en.wikipedia.org/wiki/Accommodation_(vertebrate_eye))* — the eye's ability to change focus by physically changing lens shape (ciliary muscle contracts → lens gets rounder/more powerful, for near focus).
- *[Emmetropia](https://en.wikipedia.org/wiki/Emmetropia)* — normal-sighted eye (see §6, refractive errors).

---

## 2. The Retina: Rods and Cones

The retina is a layered neural circuit, not just a passive light-sensitive film:

**Light path through the retina layers (light enters from the *inner* side first, counter-intuitively):**

Light → [Ganglion cells](https://en.wikipedia.org/wiki/Retinal_ganglion_cell) → [Bipolar cells](https://en.wikipedia.org/wiki/Retina_bipolar_cell) (+ horizontal/amacrine cells for lateral processing) → **[Photoreceptors](https://en.wikipedia.org/wiki/Photoreceptor_cell) (rods & cones)** → Retinal pigment epithelium → (absorbed)

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

A key experimental data point cited in lecture (Roorda & Williams, 1999, *Nature*): imaging the living human cone mosaic in the fovea, they found individual [cones](https://en.wikipedia.org/wiki/Cone_cell) separated by about **5 [arcminutes](https://en.wikipedia.org/wiki/Minute_and_second_of_arc) of visual angle** — i.e., that's roughly the finest-grain "sampling grid" your retina's cone mosaic provides at the very center of vision. (An arcminute is 1/60th of a degree — see §8 for how this becomes the basis for acuity limits.)

---

## 3. Color Perception

[Visible light](https://en.wikipedia.org/wiki/Visible_spectrum) is a narrow slice (~400–700 nanometers) of the full [electromagnetic spectrum](https://en.wikipedia.org/wiki/Electromagnetic_spectrum), between ultraviolet and infrared.

Color vision comes from **three types of cones**, each with a different (overlapping) sensitivity curve over wavelength:

- **S (short)** cones — peak near ~440 nm (bluish)
- **M (medium)** cones — peak near ~545 nm (greenish)
- **L (long)** cones — peak near ~565 nm (yellowish-red)

Note the M and L curves overlap *heavily* — this is why the "green" and "red" cones are so easily confused/aliased by the visual system, and it's a key reason color is represented as a 3-number ([tristimulus](https://en.wikipedia.org/wiki/CIE_1931_color_space#Definition_of_the_CIE_XYZ_color_space)) space rather than measuring wavelength directly: **your eye doesn't measure wavelength, it measures three overlapping weighted sums of the incoming spectrum.** Two physically different spectra that produce the same 3 cone responses look *identical* to you — this phenomenon is called **[metamerism](https://en.wikipedia.org/wiki/Metamerism_(color))**, and it's the whole reason RGB displays/cameras work at all (they don't need to reproduce the true spectrum, just match your 3 cone responses).

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

A digital camera sensor is actually colorblind on its own — each individual light-sensing pixel can only measure *brightness*, not color. To get color, manufacturers glue a **[Bayer color filter array](https://en.wikipedia.org/wiki/Bayer_filter)** directly on top of the sensor: a physical grid of tiny red, green, and blue filters, one per pixel, arranged in a repeating 2×2 tile of one red, two green, and one blue filter ("**RGGB**" — green is doubled because human vision is most sensitive to green, per §3's cone curves). Each pixel then only ever records *one* of the three colors; the other two get computationally filled in later, a process called *[demosaicking](https://en.wikipedia.org/wiki/Demosaicing)* (Week 3).

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

This age-related loss of near-focus ability is called **[presbyopia](https://en.wikipedia.org/wiki/Presbyopia)** (why people need reading glasses as they age) — the lens becomes stiffer and the ciliary muscle can no longer deform it enough for close focus.

---

## 6. Refractive Errors

Four categories, defined by *where light rays converge relative to the retina*:

| Condition | What happens | Correction |
|---|---|---|
| **Emmetropia** | Normal — rays focus exactly on the retina | None needed |
| **[Myopia](https://en.wikipedia.org/wiki/Myopia)** (nearsightedness) | Rays focus *in front of* the retina (eyeball too long / cornea too curved) | **[Concave (diverging)](https://en.wikipedia.org/wiki/Corrective_lens)** lens |
| **Hypermetropia / [Hyperopia](https://en.wikipedia.org/wiki/Farsightedness)** (farsightedness) | Rays focus *behind* the retina (eyeball too short) | **Convex (converging)** lens |
| **[Astigmatism](https://en.wikipedia.org/wiki/Astigmatism)** | Cornea is irregularly curved (not spherical), so rays don't converge to a single point at all | **Cylindrical** lens (corrects only the irregular axis) |

This is a nice concrete example of "optics can be broken in a specific, geometrically describable way, and correction is just adding a compensating optical element" — the same logic (add optics or add computation to compensate for a known aberration) will reappear constantly in computational imaging.

---

## 7. Visual Field / Field of View (FOV)

- **Monocular FOV** (one eye): ~190°
- **Binocular FOV** (both eyes overlapping): ~120°
- **Vertical FOV**: ~135°

This matters directly for designing displays (e.g., "how important is [FOV](https://en.wikipedia.org/wiki/Field_of_view) for immersive VR?" — a wide FOV headset is trying to fill as much of this natural visual field as possible) and for the pinhole camera in HW1 (field of view of your pinhole box is a geometric function of pinhole-to-screen distance and screen size — same angular-FOV concept, applied to a man-made "eye").

---

## 8. Visual Acuity

**Visual angle** is the angular size an object subtends at your eye — it depends on *both* the object's physical size and its distance, not size alone. It's measured in degrees, or in smaller units of **[arcminutes](https://en.wikipedia.org/wiki/Minute_and_second_of_arc)** (1° = 60 arcmin) and arcseconds (1 arcmin = 60 arcsec).

- **[20/20 vision](https://en.wikipedia.org/wiki/Visual_acuity)** (the "normal" acuity reference) corresponds to being able to resolve detail at about **1 arcminute** of visual angle.
- The **[Snellen chart](https://en.wikipedia.org/wiki/Snellen_chart)** (the classic eye-test letter chart) is built around this: each letter's individual strokes are designed to subtend 1 arcminute at the standard test distance when you can *just barely* read that row, and the whole letter subtends 5 arcminutes.

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

**[dpi](https://en.wikipedia.org/wiki/Dots_per_inch) is just *p* turned upside down.** *p* is a *length* — how physically big one resolvable pixel is (in inches). **dpi** ("dots per inch") is a *density* — how many of those pixel-widths fit side by side into one inch. Since *p* is already "inches per pixel," dpi is just its reciprocal:

```
dpi = 1 inch / p
```

Plugging in: 1 / 0.0035 ≈ **286 dpi**. It isn't a separately measured quantity — it's the exact same fact about pixel size, just flipped from "how big is one pixel" into "how many pixels fit in an inch," because "286 dots per inch, bigger is sharper" is a more intuitive number to compare screens by than "0.0035 inches, smaller is sharper."

(A pixel and a "dot" are the same unit here — *dpi* is historically a *printing* term, since a printer physically deposits ink dots on paper; it got carried over informally to describe screens too, even though the more precise screen term is **[ppi](https://en.wikipedia.org/wiki/Pixel_density)**, pixels per inch. Apple's "300 dpi" claim is really a ppi claim wearing the older, more familiar name — the lecture and this course treat the two as interchangeable, same as Apple's own marketing did.)

**≈ 286 dpi** is the density at which pixels become individually unresolvable at 12 inches — Apple's marketing claim was **300 dpi**, i.e., *slightly* above the computed "retina" threshold (300 > 286), which is the point of the slide: the marketing number is a real, checkable physical claim, not just a buzzword, and it holds up to the math (with a small safety margin).

**Why this generalizes:** the same formula tells you that "how many pixels fall in your fovea" is a *moving target* that depends entirely on viewing distance — a screen designed to be "retina" at 12 inches would look pixelated at 3 inches and be wastefully over-resolved at 3 meters. This exact idea — same physical image, different perceived spatial frequency content depending on distance — is the entire mechanism behind hybrid images (§13) and is exactly what HW1 Task 3 asks you to compute for a printed photo at two different viewing distances.

---

## 10. Dynamic Range

**[Dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)** = the ratio between the brightest and darkest signal a system can represent, usually expressed in **[f-stops](https://en.wikipedia.org/wiki/F-number)** (each stop = a factor of 2×) or **orders of magnitude** (factors of 10×).

From the lecture:
- **Full human luminance vision range** (across all adaptation states — from starlight to sunlight): about **14 orders of magnitude** (10¹⁴×).
- **Instantaneous** human range (without the eye re-adapting, e.g., pupil dilation / photoreceptor bleaching adjustments): about **5 orders of magnitude** (≈ this is often quoted elsewhere as ~6.5 f-stops instantaneously, per the lecture's own summary slide).
- **Typical digital displays (at the time of the cited slide)**: only about **3 orders of magnitude**.

This large gap between what the eye can perceive and what a standard display can reproduce is exactly the motivation for **HDR (high dynamic range) imaging and displays** (Week 4 topic) — e.g., "Sunnybrook" style HDR displays that add a secondary low-resolution backlight array behind an LCD panel to multiply the achievable contrast ratio.

---

## 11. Contrast

Before you can even define a "contrast sensitivity function," you need a numeric definition of contrast itself — and there isn't just one:

- **[Weber contrast](https://en.wikipedia.org/wiki/Contrast_(vision)#Weber_contrast)**: designed for a single, small feature on a large uniform background.
  ```
  C_weber = (I_feature − I_background) / I_background
  ```
  Good when there's one clear "object" and one clear "background" luminance.

- **[Michelson contrast](https://en.wikipedia.org/wiki/Contrast_(vision)#Michelson_contrast)**: designed for periodic/repeating patterns (like the sinusoidal gratings used in CSF experiments, §12), where there's no single "background."
  ```
  C_michelson = (I_max − I_min) / (I_max + I_min)
  ```
  This normalizes by the *average* of the brightest and darkest parts of the pattern, which makes sense for a repeating stripe pattern where "background" isn't well-defined.

**Takeaway:** "contrast" is context-dependent — which formula you use depends on whether you're describing a single feature (Weber) or a repeating pattern (Michelson). CSF experiments (next section) use grating stimuli, so Michelson contrast is the natural definition there.

---

## 12. Contrast Sensitivity Function (CSF)

This is the most important technical concept of Week 1, and it's the direct theoretical basis for HW1 Task 3. Because the whole rest of this section — and hybrid images in §13 — leans on the word "frequency," and that word is dangerously overloaded in this course, we build it up from scratch before touching the CSF itself.

### 12.0 First, disambiguate: which "frequency"?

This course uses *frequency* to mean three genuinely different things. Mixing them up is the single most common source of confusion with this material, so pin them down explicitly:

| Word as used here | What varies | Unit | Where else it shows up |
|---|---|---|---|
| **Light frequency** (equivalently, wavelength/color) | How fast the *electromagnetic wave itself* oscillates | Hz, or more commonly its wavelength in nm | §3 (color perception) — ~400–700 nm visible range |
| **Temporal frequency** | How fast a signal changes *over time* (e.g. a flickering light, or a video's frame rate) | Hz (cycles per second) | §17 (temporal resolution, ~60 Hz) |
| **Spatial frequency** | How fast *brightness* changes *across space* — i.e., as you scan your eye or a sensor sideways across an image | cycles per degree (cpd), or cycles per unit distance | This section, §13 (hybrid images), and reused formally in Week 5 |

**Every "high-frequency" / "low-frequency" mention from here through §13 means spatial frequency, and nothing else.** It has nothing to do with color (light frequency) and nothing to do with flicker/time (temporal frequency) — a "high-frequency" region of an image can be any color at all, and the image can be a single still photo with no time dimension involved.

### 12.1 What spatial frequency actually is, built up from a picture

Picture a **grating**: a test pattern of alternating light and dark stripes, like a barcode. This is literally the stimulus Campbell & Robson (1968) used. Define one **cycle** as one full light-stripe-then-dark-stripe pair — start at the left edge of a light stripe, and the cycle ends where the *next* light stripe begins.

- **Fine, tightly-packed stripes** (many stripes crammed into a short distance) = brightness flips from light to dark and back *rapidly* as you scan across = **high spatial frequency**. This is the same underlying idea as a sharp edge or fine detail in an ordinary photo — anywhere brightness changes abruptly over a short distance is, in this sense, "high-frequency" content.
- **Wide, slowly-varying stripes** (or a smooth gradient, or a large blurry blob with no sharp edges) = brightness changes *gradually* over a long distance = **low spatial frequency**. A photo's overall shape, silhouette, and coarse shading are its low-frequency content.

**Spatial frequency is just a count of how many of these cycles are packed into some distance.** Nothing about color, nothing about time — purely "how bunched-up are the light/dark transitions."

### 12.2 Why "cycles per degree" instead of "cycles per centimeter"

If you printed a grating on paper, "cycles per centimeter" would be a perfectly good, fixed number — a physical property of the ink pattern that never changes no matter who looks at it or from where.

But your visual system doesn't experience physical centimeters directly — it experiences **visual angle** (§8): how large something appears in your field of view, which is *not* fixed — it shrinks as you back away and grows as you step closer (this is exactly the p = 2·d·tan(α/2) relationship from §9, just used in the other direction: a fixed physical size p subtends a smaller angle α as distance d grows). So instead of asking "how many cycles per centimeter of paper," vision science asks the perceptual version: **"how many light/dark cycles fit into one degree of your visual field, from wherever you happen to be standing?"** That count is **cycles per degree (cpd)** — the same "one degree = 60 arcminutes" unit from §8, just now used to measure how densely packed a repeating pattern looks, rather than the size of a single object.

**Worked example — the same grating from two distances:**

Suppose a grating's cycles are 1 cm wide (1 cm of light stripe + dark stripe together), and you're standing 1 meter away.

- **Step back to 2 meters:** the same physical 1 cm cycle now subtends roughly *half* the visual angle it did before (visual angle shrinks as distance grows). Since each cycle now takes up less of your field of view, *more* whole cycles fit into any fixed one-degree slice of that field of view → the pattern's spatial frequency, measured in cpd, goes **up**.
- **Step closer to 50 cm:** the same 1 cm cycle now subtends roughly *double* the visual angle. Each cycle eats up more of your field of view, so *fewer* whole cycles fit into one degree → cpd goes **down**.

The physical ink on the page never changes. Only *how many of its cycles fit inside your one-degree window* changes, and that depends entirely on viewing distance. This single fact — **cpd is a property of "the pattern as seen from here," not a fixed property of the pattern itself** — is exactly what the rest of this section, and all of §13, is built on.

### 12.3 The CSF curve itself

**Setup:** Campbell & Robson (1968) showed subjects sinusoidal gratings (the "smoothly-fading" version of the light/dark stripe idea above, rather than sharp-edged bars) at different **spatial frequencies** and different **[contrasts](https://en.wikipedia.org/wiki/Contrast_(vision))** (§11), and found the *minimum contrast* at which a subject could just barely detect the stripes at all. The reciprocal of that minimum detectable contrast is the subject's **[contrast sensitivity](https://en.wikipedia.org/wiki/Contrast_(vision)#Contrast_sensitivity)** at that spatial frequency: a *low* minimum-detectable-contrast means you're very sensitive (you can spot even a faint pattern), so sensitivity = 1 / (that minimum contrast).

**Shape of the CSF curve (contrast sensitivity, on the y-axis, plotted against spatial frequency in cpd, on the x-axis):**
- It is **band-pass**, not low-pass or flat: sensitivity is *reduced* at very low spatial frequencies (large, slowly-varying patterns — picture a very gradual, barely-there gradient, which is genuinely hard to notice) *and* at very high spatial frequencies (very fine stripes), and **peaks around 4–6 cpd**, meaning that's the "sweet spot" density of light/dark cycles your eye is best at detecting.
- At the high-frequency end, sensitivity eventually drops to zero around **~60 cpd**, set by **[cone](https://en.wikipedia.org/wiki/Cone_cell) packing density** — you simply cannot perceive stripes finer than your photoreceptor mosaic can sample (a direct callback to §2 and §8: this is the same physical sampling-grid limit as the ~5-arcminute cone spacing Roorda & Williams measured).
- Critically, because of §12.2: **the same physical pattern's position on this curve shifts as you change your viewing distance**, since its cpd value itself changes with distance. Move closer → its cpd drops, potentially sliding it toward the 4–6 cpd peak (more visible). Move farther away → its cpd rises, potentially pushing it past ~60 cpd (less visible, eventually invisible).

**Why this matters (the big idea, restated concretely):** take a photo with genuinely fine detail in it — hairline-thin brushstrokes, say. Physically, those fine strokes are a fixed size. But per §12.2, their *cpd* isn't fixed: viewed from far away, that small physical size subtends a tiny visual angle, so a huge number of them cram into one degree → very high cpd → likely past the ~60 cpd cutoff → invisible. Viewed up close, the same strokes subtend a much larger visual angle, so far fewer fit into one degree → their cpd drops into the visible, even peak-sensitivity range → clearly visible. A single physical image can therefore contain content that is only visible up close (high spatial frequency) stacked with content that stays visible from far away (low spatial frequency) — and that's precisely how a hybrid image works.

---

## 13. [Hybrid Images](https://en.wikipedia.org/wiki/Hybrid_image) (Oliva, Torralba & Schyns, 2006, SIGGRAPH)

Every "frequency" word in this section is **spatial frequency**, exactly as pinned down in §12.0 — how rapidly brightness changes as you scan across the image, nothing to do with color or with time.

**Core idea:** merge two different images into one composite such that:
- **Viewed up close** → the **high-spatial-frequency** (fine detail, sharp edges) content dominates perception → you see Image A.
- **Viewed from far away** → the **low-spatial-frequency** (coarse, blurry, "gist") content dominates perception → you see Image B.

### 13.1 What the two filters actually do to an image, concretely

Any photo can be thought of as a mix of coarse structure (the rough shapes and overall shading — low spatial frequency) plus fine structure layered on top (edges, texture, fine detail — high spatial frequency). The two filters split that mix apart:

- A **[low-pass filter](https://en.wikipedia.org/wiki/Low-pass_filter)** blurs the image — literally, e.g. averaging each pixel with its neighbors. Averaging smooths out anything that changes quickly from pixel to pixel (high spatial frequency), while leaving slow, broad variations (low spatial frequency) mostly intact. The result looks like the original image out of focus.
- A **[high-pass filter](https://en.wikipedia.org/wiki/High-pass_filter)** does the opposite: subtract a blurred version of the image from the original. Whatever was slow/broad cancels out (since it was present in both the original and the blur), leaving only the fast-changing edges and fine texture behind — the result looks like a faint line drawing of just the edges, mid-gray everywhere else.

### 13.2 Mechanism, tying directly back to §12

1. Take Image A, apply a high-pass filter → keep only its fine detail / sharp edges, discard its smooth/coarse structure.
2. Take Image B, apply a low-pass filter → keep only its coarse, smooth/blurry structure, discard its fine detail.
3. **Add the two filtered images together**, pixel by pixel (done per color channel, in the Fourier/frequency domain in the course's approach — see Week 5 for what "frequency domain" formally means).
4. The result is a single image containing *both* spatial-frequency bands at once, stacked on top of each other. Which band you consciously perceive depends entirely on **viewing distance**, because — per §12.3 — your CSF determines which spatial-frequency band is currently sitting in your visible range at that distance.

### 13.3 Why it works perceptually, walked through with §12.2's logic

- **Image A's high-frequency content** (fine edges/detail) is, physically, made of small, tightly-packed features. Per §12.2: viewed **up close**, those small features subtend a large-enough visual angle that relatively few of them fit into one degree → their cpd sits in a visible (even peak-sensitivity, ~4–6 cpd) range → **you see Image A clearly**. Viewed **from far away**, those same tiny physical features subtend a much smaller visual angle, so many more of them cram into one degree → their cpd shoots up past the ~60 cpd cutoff → **they become invisible**.
- **Image B's low-frequency content** (broad, slowly-varying shapes) is made of large-scale features to begin with. Those stay at a low, visible cpd across a wide range of realistic viewing distances — including far away, where Image A's fine detail has already dropped out. So from a distance, Image B's coarse structure is essentially all that's left to see.

So the same printed composite gives you Image A up close and Image B from across the room, purely because your CSF (§12.3) admits a different spatial-frequency band at each distance — no trick beyond the ordinary physics of visual angle already covered in §8–9 and §12.2.

*(Note: the specific numeric cutoff frequency, filter radius in pixels, and print-size calculations are exactly what HW1 Task 3 asks you to derive yourself — intentionally left out of these notes.)*

---

## 14. [Depth Perception](https://en.wikipedia.org/wiki/Depth_perception)

Human depth perception combines many independent cues, grouped into two families:

**[Monocular cues](https://en.wikipedia.org/wiki/Monocular_vision)** (work with just one eye):
- **Perspective** (parallel lines converging toward a vanishing point)
- **Relative size** (same object type appears smaller when farther away)
- **Absolute size** (known real-world size of familiar objects)
- **Occlusion** (an object blocking another is in front of it)
- **Accommodation** (the eye's focus state, from §5, is itself a weak depth cue)
- **Retinal blur** (out-of-focus objects are perceived as being at a different depth)
- **[Motion parallax](https://en.wikipedia.org/wiki/Motion_parallax)** (nearer objects appear to move faster across your view than farther objects, as you move)
- **Texture gradients** (texture appears finer/denser as distance increases)
- **Shading** (how light and shadow fall on a surface implies its 3D shape)

**[Binocular cues](https://en.wikipedia.org/wiki/Binocular_vision)** (require two eyes):
- **[(Con)vergence](https://en.wikipedia.org/wiki/Vergence)** — the inward rotation angle of both eyes needed to fixate on a near object (more rotation = closer object)
- **[Disparity](https://en.wikipedia.org/wiki/Binocular_disparity) / parallax** — the difference in each eye's retinal image of the same scene, which the brain decodes into depth (this is the basis of [stereoscopic](https://en.wikipedia.org/wiki/Stereopsis) 3D)

**Visual illusions** (e.g., M.C. Escher drawings, or the Held et al. 2006 SIGGRAPH illusion demos) are used pedagogically to show that these cues can be *individually* tricked/isolated — if a picture violates one cue (e.g., impossible occlusion) while satisfying others, you get a perceptual paradox, which is strong evidence that these are genuinely separable computational cues rather than one monolithic "depth sense."

---

## 15. [Stereoscopic](https://en.wikipedia.org/wiki/Stereoscopy) Displays & a Brief History of VR

**Stereoscopic** comes from *stereo* ("two"/"solid") + *scopic* ("viewing") — literally "two-eyed viewing." It describes anything that recreates depth by giving each eye a slightly different image, the way ordinary binocular vision already works: your two eyes sit a few centimeters apart, so each sees the same scene from a slightly different horizontal viewpoint, and the difference between those two views (**binocular disparity**, §14) is what your brain decodes into depth.

A **stereoscopic** device or display exploits this on purpose: instead of showing both eyes the same flat image, it feeds each eye its own slightly-offset image, so the brain perceives depth that isn't really there on a flat screen or print. Stereoscopic 3D displays work by presenting each eye a slightly different image (mimicking binocular disparity, §14) so the brain fuses them into a perceived depth.

Brief timeline given in lecture:
- **1838**: [Charles Wheatstone](https://en.wikipedia.org/wiki/Charles_Wheatstone) invents the **stereoscope** — the first device to present offset images to each eye and produce a 3D perception (predates photography-based stereo images; early stereoscopes used stereo pairs of drawings/photos, e.g., a 1865 stereo photo of Lincoln shown in lecture).
- **1968**: [Ivan Sutherland](https://en.wikipedia.org/wiki/Ivan_Sutherland) builds an early [head-mounted](https://en.wikipedia.org/wiki/Head-mounted_display) VR/AR display.
- **2012–2022**: the modern [VR](https://en.wikipedia.org/wiki/Virtual_reality) "explosion" (Oculus, Sony, Valve, Microsoft, etc.).

---

## 16. [Vergence-Accommodation Conflict](https://en.wikipedia.org/wiki/Vergence-accommodation_conflict) (VAC)

This is a specific, important problem with conventional stereoscopic displays (glasses-based 3D, most VR headsets):

- **In the real world**, *vergence* (§14, how much your eyes rotate inward to fixate an object) and *accommodation* (§5, how your lens focuses) both point to **the same distance** — they naturally match.
- **On a stereo display**, the two eyes are shown offset images that make you *verge* your eyes to a simulated depth (say, an object appears 2m away) — but your eyes must still *accommodate* (focus) at the **actual physical screen distance** (e.g., a headset lens at a fixed distance), which is usually different from the simulated depth.

This mismatch — verging to one distance while accommodating to another — is the **vergence-accommodation conflict**, and it's the leading cause of visual discomfort, fatigue, eyestrain, and nausea in stereo 3D/VR displays. It's also the direct engineering motivation for **[light field displays](https://en.wikipedia.org/wiki/Light_field#3D_display)** and future **[holographic](https://en.wikipedia.org/wiki/Holography) displays** (mentioned as near-/long-term solutions), which can (in principle) present a physically correct focus depth per pixel instead of a fixed screen distance — this connects forward to the light field imaging week (Week 9).

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
