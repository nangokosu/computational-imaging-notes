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

A key experimental data point cited in lecture (Roorda & Williams, 1999, *Nature*): imaging the living human cone mosaic in the fovea, they found individual [cones](https://en.wikipedia.org/wiki/Cone_cell) separated by about **0.5 [arcminutes](https://en.wikipedia.org/wiki/Minute_and_second_of_arc) of visual angle** — i.e., that's roughly the finest-grain "sampling grid" your retina's cone mosaic provides at the very center of vision. (An arcminute is 1/60th of a degree — see §8 for how this becomes the basis for acuity limits. This ~0.5 arcmin spacing is also exactly what makes the numbers elsewhere in this section consistent: by the sampling/Nyquist logic in §12.3, a ~0.5 arcmin sampling pitch predicts a resolution limit around 1 arcmin — matching §8's 20/20 figure — and a spatial-frequency cutoff around 60 cycles per degree — matching §12.3's CSF cutoff.)

---

## 3. Color Perception

[Visible light](https://en.wikipedia.org/wiki/Visible_spectrum) is a narrow slice (~400–700 nanometers) of the full [electromagnetic spectrum](https://en.wikipedia.org/wiki/Electromagnetic_spectrum), between ultraviolet and infrared.

Color vision comes from **three types of cones**, each with a different (overlapping) sensitivity curve over wavelength:

- **S (short)** cones — peak near ~440 nm (bluish)
- **M (medium)** cones — peak near ~545 nm (greenish)
- **L (long)** cones — peak near ~565 nm (yellowish-red)

Note the M and L curves overlap *heavily* — this is why the "green" and "red" cones are so easily confused/aliased by the visual system, and it's a key reason color is represented as a 3-number ([tristimulus](https://en.wikipedia.org/wiki/CIE_1931_color_space#Definition_of_the_CIE_XYZ_color_space)) space rather than measuring wavelength directly: **your eye doesn't measure wavelength, it measures three overlapping weighted sums of the incoming spectrum.** Two physically different spectra that produce the same 3 cone responses look *identical* to you — this phenomenon is called **[metamerism](https://en.wikipedia.org/wiki/Metamerism_(color))**, and it's the whole reason RGB displays/cameras work at all (they don't need to reproduce the true spectrum, just match your 3 cone responses).

**Linear-algebra view (cone responses as inner products):** sample a light's spectrum at N wavelengths and it becomes a vector **s** with N entries (the power at each wavelength). Each cone type's sensitivity curve, sampled at the same N wavelengths, is another N-entry vector, and that cone's response is the **inner product** (dot product) of the two: multiply wavelength by wavelength, then add up. Stack the three sensitivity vectors as the rows of a 3×N matrix **C**, and the whole eye's color measurement is one matrix–vector product, **c** = **C s**, giving a 3-entry vector (L, M, S). That is a **linear map from N dimensions down to 3**: a huge amount of spectral detail is squashed into three numbers.

**Linear-algebra view (metamerism as a null space):** the **null space** of **C** is the set of spectrum-difference vectors **n** with **C n** = 0 — changes to the spectrum that no cone responds to. Any two spectra **s** and **s** + **n** give the same (L, M, S), so they are metamers; metamerism is exactly "differs by a null-space vector." The null space is big: with, say, samples every 10 nm across 400–700 nm (N = 31), a rank-3 matrix leaves a 31 − 3 = 28-dimensional null space, so most spectral detail is invisible. (Real spectra must also stay non-negative, which limits which null-space vectors you can actually add, but the dimension count shows why metamers are common.) Because (L, M, S) lives in a 3D vector space, any invertible 3×3 matrix gives an equally complete **change of basis** for color. That is what XYZ and RGB color spaces are, and Week 3 builds those 3×3 conversions explicitly.

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

A digital camera sensor is actually colorblind on its own — each individual light-sensing pixel can only measure *brightness*, not color; it has no way to tell what wavelength of light it absorbed, only how much light hit it. To get color, manufacturers glue a **[Bayer color filter array](https://en.wikipedia.org/wiki/Bayer_filter)** directly on top of the sensor: a physical grid of tiny red, green, and blue filters, with exactly **one filter sitting over each individual pixel**.

**Every single pixel is single-color, not multi-color.** A pixel under a green filter only ever measures the green component of the light hitting that spot — it has *no* red or blue information at all, because the filter physically blocked those wavelengths before they reached it. What *is* multi-color is the grid as a whole: the filters are arranged in a repeating 2×2 tile — one red, two green, one blue — across the array of individually single-color pixels ("**RGGB**," green doubled because human vision is most sensitive to green, per §3's cone curves). **"RGGB" describes the mosaic pattern of the pixel grid, not any property of a single pixel** — no individual pixel is ever itself "RGGB."

Because each pixel only ever records one channel, the full-color image you eventually see — where every pixel appears to have a red, green, *and* blue value — isn't what the sensor directly measured. It's a **reconstruction**: for each pixel, the two channels it didn't measure are estimated by looking at its neighboring pixels (which, thanks to the repeating tile, measured different colors) and interpolating between them. This estimation step is called *[demosaicking](https://en.wikipedia.org/wiki/Demosaicing)* (Week 3) — it means two-thirds of every pixel's RGB value in a final photo is computed, not measured.

**Linear-algebra view (the Bayer mosaic as a linear operator):** stack the "true" full-color image into one long vector with 3 entries per pixel (R, G, B), so 3·P entries for P pixels. The sensor records one number per pixel, so its raw output is a P-entry vector. The mosaic is a P×3P **linear operator**: each row has a single 1 that picks out whichever channel that pixel's filter lets through, and 0 everywhere else. This matrix has far fewer rows than columns, so like the cone matrix in §3 it has a large **null space** (any change to the channels a pixel did *not* measure is invisible to it). Demosaicking therefore cannot simply invert the matrix. It has to bring in extra assumptions, such as "neighboring pixels have similar colors," to choose one full-color image among all those consistent with the measurement (Week 3).

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

### 10.1 Stops, EV, and the photographer's "+2 / −4" notation

**Why this section is here.** The word "stop" already appeared above, and it returns in every camera-related week (aperture in Week 2 §8, exposure time and ISO in Week 4 §2.3). Photographers also write brightness changes as "+2", "−1", "−4 EV" or "f/2.8" without explanation. This is the one place where the whole shorthand is explained from scratch.

**Analogy first: musical octaves.** Notes an octave apart differ by a factor of 2 in vibration frequency, yet you hear that as one equal-sized "step" up. Light brightness works the same way: your eye and a camera's settings both care about *ratios*, not differences, so photographers count brightness in *doublings*. One doubling is one **stop**.

**Definition.** A **stop** is a factor of 2 in the amount of light (or in a ratio of brightnesses, such as dynamic range). Counting stops is just counting how many times you doubled or halved.

```
stops = log₂(ratio)          ratio = 2^stops
```

**Intuition.** Start from a ratio of 1 (no change) and double it once: ratio 2, which is 1 stop. Double again: ratio 4, 2 stops. Each extra stop multiplies the ratio by 2, so after *n* stops the ratio is 2 multiplied by itself *n* times, i.e. 2ⁿ. The logarithm base 2 is simply the question "how many doublings gives this ratio?", the inverse of that multiplication. A negative number of stops is halvings: −1 stop is ×½, −2 stops is ×¼.

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

**Converting between orders of magnitude and stops.** One order of magnitude is a factor of 10, and log₂(10) ≈ 3.32, so 1 order of magnitude ≈ 3.32 stops. This is the unit conversion used in the summary slide check in §17: 14 orders ≈ 14 × 3.32 ≈ 46.5 stops.

**Third-stop steps.** Cameras usually move in fractions of a stop, most often one third. A "+1/3 stop" step multiplies the light by 2^(1/3) ≈ 1.26, "+2/3" by 2^(2/3) ≈ 1.59, and three such steps give 2^(3/3) = 2, a full stop again. Every step is the same *multiplier*, not the same added amount (that is the octave idea: equal-sounding steps are equal ratios).

**"EV" has two uses; keep them apart.**

- **Exposure compensation** (the dial that reads "−2 … 0 … +2" on a camera). A value like **+2** (or "+2 EV") means "make the photo 2 stops, i.e. 2² = 4 times, brighter than the camera's automatic **meter** (its built-in light measurement) would have chosen". "−4" means 2⁻⁴ = 1/16 as bright. This is a *relative* instruction, an offset from the meter's suggestion.
- **Exposure value** (absolute EV, a single number labelling a combination of aperture and shutter time). It is defined in Week 4 §2.3; one step of it is again one stop.

**The three physical controls, and what one stop of each looks like.** (All three are defined properly later; this is the lookup you need now.)

| Control | What it is, in one line | One stop *more* light (or brightness) | Where deepened |
|---|---|---|---|
| **Aperture**, written f/N | the adjustable opening in the lens, f/N meaning opening diameter = focal length ÷ N (the slash is "divided by") | f/4 → f/2.8 (N shrinks by √2 ≈ 1.41, because light follows opening *area*, which goes as diameter²) | Week 2 §8 |
| **Shutter time** (exposure time) | how long the sensor collects light | 1/125 s → 1/60 s (time doubles; the printed numbers are rounded powers of 2) | Week 4 §2.3 |
| **ISO** | an electronic amplification of the recorded signal (brightens the picture without collecting more light) | ISO 100 → ISO 200 | Week 4 §2.5 |

Because each control moves in stops, they trade off exactly: one stop opened on the aperture can be paid back by one stop faster on the shutter, leaving the picture's brightness unchanged (called **reciprocity**, Week 4 §2.2).

> **Worked example (a generic one, not a homework case).** A meter suggests f/4, 1/125 s, ISO 100. You want a faster shutter to freeze motion: 1/500 s is 2 stops faster (125 → 250 → 500 is two doublings, so 1/4 as much light). To pay those 2 stops back you can open the aperture 2 stops: f/4 → f/2.8 → f/2. Result: f/2, 1/500 s, ISO 100, same brightness as the meter's pick. Now add exposure compensation of +1: the camera will deliver 2× the light of that pick, for instance by slowing the shutter to 1/250 s.

> **Why this matters for HDR (Week 4).** A bracket "at −4, −2, +2, +4 stops" is just the multipliers 1/16, 1/4, 4, 16 from the table, applied to one baseline exposure; the whole spread is 8 stops, a 256× range.

The formulas above are in `formulas.md` (Week 1). Week 2 §8 gives the aperture sequence, and Week 4 §2.3 and §2.5 give the shutter and ISO sequences and absolute EV.

---

## 11. Contrast

**What problem this solves.** To study how well the eye detects a pattern, you need a single number saying "how strong is this brightness difference?" Contrast is that number. Input: the brightness (luminance) values in a scene or pattern. Output: one dimensionless contrast value, larger meaning easier to see. Analogy: contrast is like a signal-to-background ratio, how loudly someone speaks relative to the room's noise, since the same absolute brightness step is obvious on a dark background and invisible on a bright one.

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
| **Spatial frequency** | How fast *brightness* changes *across space* — i.e., as you scan your eye or a sensor sideways across an image | cycles per degree (cpd), or cycles per unit distance | This section, §13 (hybrid images), further split into "image" vs. "physical" vs. "perceptual" flavors in §12.2.1, and reused formally in Week 5 |

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

### 12.2.1 Image frequency vs. spatial frequency — the same pattern, three different rulers

§12.2 already showed that "cycles per centimeter" (fixed, physical) and "cycles per degree" (cpd, viewer-dependent) are two different rulers for measuring the *same* grating. There's a third ruler sitting even further upstream of both, and Week 5's material (Fourier transforms of digital images) leans on the distinction: **image frequency**.

**Image frequency** is how fast brightness changes across the *pixel grid* of a digital image file — cycles per pixel (equivalently, how many cycles fit across the image's full pixel width). It is a property of the array of pixel values alone: it doesn't know or care how large the image is printed, what screen shows it, or how far away anyone stands. Two copies of the exact same image file — one displayed on a phone, one blown up on a cinema screen — have identical image frequency, because that number never leaves the file's own pixel-index coordinate system. This is precisely the frequency axis you get from a digital image's Fourier transform (formalized in Week 5) — measured in cycles per pixel, not cycles per inch or cycles per degree.

**Spatial frequency**, as built up in §12.1–12.2, is the *physical/perceptual* version of the same idea — how fast brightness changes across real space, in cycles per unit distance (fixed, once an image is printed/displayed at a given size) or cycles per degree of visual angle (cpd — additionally dependent on viewing distance, per §12.2).

**The relationship is a two-step conversion chain**, reusing tools already built in this section:

1. **Image frequency → physical spatial frequency**, via dpi (§9). Image frequency is in cycles/pixel; dpi is in pixels/inch (the same dpi = 1/p density from §9). Multiplying converts the units:
   ```
   physical spatial frequency (cycles/inch) = image frequency (cycles/pixel) × dpi (pixels/inch)
   ```
   This step turns a fixed *digital* quantity into a fixed *physical* quantity — it depends only on what dpi you choose to print or display at, never on the viewer.

2. **Physical spatial frequency → cpd**, via viewing distance — exactly the visual-angle logic §12.2 already applied to the 1 cm grating example. This is the only step in the whole chain that depends on the viewer at all.

**Worked example:** suppose a digital image contains a fine repeating texture with a period of 6 pixels — one full light-dark cycle every 6 pixels — so its **image frequency is 1/6 ≈ 0.167 cycles/pixel**, a fixed fact about the file, unrelated to how it's ever displayed. Printed at **300 dpi** (the same density as §9's retina-display example):

```
physical spatial frequency = 0.167 cycles/pixel × 300 pixels/inch = 50 cycles/inch (≈ 19.7 cycles/cm)
```

This number is now fixed too — it stays 50 cycles/inch no matter how far anyone stands from the print, because it's baked into the physical ink the moment you commit to 300 dpi. Only the last step — converting to cpd — depends on the viewer: viewed from 40 cm, applying the same visual-angle machinery as §12.2's worked example gives roughly **13.7 cpd** (comfortably inside the visible range, past the 4–6 cpd peak but nowhere near the ~60 cpd cutoff). Change the viewing distance and, per §12.2, that cpd number moves — but the image frequency (0.167 cycles/pixel) and the physical spatial frequency (50 cycles/inch) never do.

**Takeaway:** image frequency is the innermost, most fixed quantity — a property of the pixel array alone. Spatial frequency is the umbrella term for "how fast brightness varies across space," which itself splits into a fixed-once-printed flavor (cycles per physical distance) and a viewer-dependent flavor (cpd, what the CSF is actually plotted against). Confusing "cycles per pixel" with "cycles per degree" is a common mistake — a texture with fixed image frequency can sit anywhere on the CSF curve depending on print size and viewing distance, which is exactly the print-size/viewing-distance reasoning HW1 Task 3 asks you to work through (the specific numbers are left to the assignment, per the note in §13).

### 12.3 The CSF curve itself

**What problem this solves.** Visual acuity (§8) says only the *smallest* detail you can resolve, but real images contain stripes and textures of every size and every strength. The contrast sensitivity function (CSF) answers: for each stripe density, how faint can the stripes get before you stop seeing them? Input: a spatial frequency in cycles per degree (cpd). Output: contrast sensitivity, the reciprocal of the faintest contrast you can still detect. Analogy: it is an equalizer curve for vision, like a hearing test that finds the quietest audible volume at each pitch, except the "pitch" is stripe density and the "volume" is contrast.

**Setup:** Campbell & Robson (1968) showed subjects sinusoidal gratings (the "smoothly-fading" version of the light/dark stripe idea above, rather than sharp-edged bars) at different **spatial frequencies** and different **[contrasts](https://en.wikipedia.org/wiki/Contrast_(vision))** (§11), and found the *minimum contrast* at which a subject could just barely detect the stripes at all. The reciprocal of that minimum detectable contrast is the subject's **[contrast sensitivity](https://en.wikipedia.org/wiki/Contrast_(vision)#Contrast_sensitivity)** at that spatial frequency: a *low* minimum-detectable-contrast means you're very sensitive (you can spot even a faint pattern), so sensitivity = 1 / (that minimum contrast).

**Shape of the CSF curve (contrast sensitivity, on the y-axis, plotted against spatial frequency in cpd, on the x-axis):**
- It is **band-pass**, not low-pass or flat: sensitivity is *reduced* at very low spatial frequencies (large, slowly-varying patterns — picture a very gradual, barely-there gradient, which is genuinely hard to notice) *and* at very high spatial frequencies (very fine stripes), and **peaks around 4–6 cpd**, meaning that's the "sweet spot" density of light/dark cycles your eye is best at detecting.
- At the high-frequency end, sensitivity eventually drops to zero around **~60 cpd**, set by **[cone](https://en.wikipedia.org/wiki/Cone_cell) packing density** — you simply cannot perceive stripes finer than your photoreceptor mosaic can sample (a direct callback to §2 and §8: this is the same physical sampling-grid limit as the ~0.5-arcminute cone spacing Roorda & Williams measured).
- Critically, because of §12.2: **the same physical pattern's position on this curve shifts as you change your viewing distance**, since its cpd value itself changes with distance. Move closer → its cpd drops, potentially sliding it toward the 4–6 cpd peak (more visible). Move farther away → its cpd rises, potentially pushing it past ~60 cpd (less visible, eventually invisible).

**Why this matters (the big idea, restated concretely):** take a photo with genuinely fine detail in it — hairline-thin brushstrokes, say. Physically, those fine strokes are a fixed size. But per §12.2, their *cpd* isn't fixed: viewed from far away, that small physical size subtends a tiny visual angle, so a huge number of them cram into one degree → very high cpd → likely past the ~60 cpd cutoff → invisible. Viewed up close, the same strokes subtend a much larger visual angle, so far fewer fit into one degree → their cpd drops into the visible, even peak-sensitivity range → clearly visible. A single physical image can therefore contain content that is only visible up close (high spatial frequency) stacked with content that stays visible from far away (low spatial frequency) — and that's precisely how a hybrid image works.

### 12.4.0 The Fourier transform: images as sums of waves — why detour here

Everything above establishes *that* an image has spatial-frequency content, and how humans perceive it. This subsection answers a different question: on a computer, how do you actually pull an image apart into its low-frequency and high-frequency pieces?

**One more disambiguation, because it matters for everything below:** the "frequency" this subsection computes with is **image frequency** (§12.2.1) — cycles per pixel, fixed to the file — not yet the physical or perceptual spatial frequency from §12.2. §12.4 stays entirely in image-frequency space; converting an image-frequency value to cpd still needs the dpi/viewing-distance chain §12.2.1 already built. Whenever this subsection says a bare "frequency" or "(u,v)," it means image frequency, never cpd.

The answer to how a computer performs that split is the **Fourier transform**, and it's the real mechanism sitting underneath §13's hybrid images — this subsection builds just enough of it, intuitively, to understand that mechanism and to use it in code.

HW1's hybrid-images task isn't implemented by hand-blurring pixels — it's implemented by calling `np.fft.fft2`, `np.fft.fftshift`, `np.fft.ifftshift`, and `np.fft.ifft2`. To use those as more than magic incantations, you need a mental model of what they actually do to an image.

It also names a genuine reframing worth being explicit about, since it's exactly what makes computational imaging different from ordinary computer vision. Most computer-vision code treats an image as nothing more than an array of RGB brightness values indexed by pixel location — "what color is at row y, column x?" That's the **spatial domain** view.

Computational imaging routinely switches to a completely different representation of the *same* image: not "what color is here," but "how much of each possible wave pattern is present, across the whole image at once?" That second representation is the **frequency domain**. The Fourier transform converts between the two — nothing is lost in the conversion; it's an equally complete, alternative description of the same image, and an *inverse* Fourier transform converts back.

**Scope note:** this is genuinely a Week 5 topic ("Sampling, Linear Systems, Deconvolution"), formalized properly there. What follows is a deliberately partial, HW1-driven preview — just enough to use `fft2`/`fftshift` with real understanding and to see precisely how hybrid images work. Left for Week 5: the exact discrete Fourier transform formula, the sampling theorem, Nyquist rate/aliasing, why the FFT algorithm is fast, and blur as convolution with a point spread function (PSF) plus its first inverse, the Wiener filter. Left for Week 6: deconvolution with natural-image priors. Both reuse the convolution theorem, which §12.4.4a below builds from scratch (with a first look at deconvolution in §12.4.4b) and §12.4.5 then applies.

### 12.4.1 The 1D idea: any signal is a sum of waves

A musical chord sounds like one complex sound, but it's really several pure tones (sine waves) sounding at once, each with its own pitch (**frequency**) and loudness (**amplitude**). Taking a chord apart into its individual pure tones is, informally, exactly what a Fourier transform does.

Stated more generally: essentially any signal — a sound wave over time, brightness measured along a single scanline of a photo, or anything that's a single value varying along one axis — can be written as a sum of sine waves of different frequencies, each with its own **amplitude** (how strong that wave is) and **phase** (how far that wave is shifted left/right relative to a reference starting point). The **Fourier transform** is the operation that takes a signal's original description — a value at each moment or position, the "time domain" or "spatial domain" view — and returns the *recipe* of which frequencies are present and how strong/shifted each one is — the "frequency domain" view.

**Worked example:** let `s(t) = sin(2π·3t) + 0.5·sin(2π·7t)` — a signal built from exactly two pure tones: one oscillating 3 times per unit of *t* with amplitude 1, another oscillating 7 times per unit of *t* with amplitude 0.5. Its Fourier transform is *not* a smooth curve — it's zero almost everywhere except two sharp spikes: one at frequency 3 (reflecting amplitude 1), one at frequency 7 (reflecting amplitude 0.5). That's the core idea: the frequency-domain view tells you exactly which pure frequencies are "in" a signal and how strong each one is, and a signal built from only a few frequencies produces a spectrum that's mostly zero with a few spikes.

**Linear-algebra view (the Fourier transform as a change of basis):** a signal of N samples is just a vector with N entries. Its usual description ("value at sample 0, value at sample 1, ...") is its coordinates in the **standard basis**, where each basis vector is a single spike at one position. The discrete Fourier transform (DFT) rewrites the *same* vector in a different basis made of N sampled sinusoids, one per frequency, which makes it a **change of basis**. These sinusoidal basis vectors are **orthogonal**: the inner product of any two different ones is 0. So each Fourier coefficient is simply the inner product of the signal with that frequency's basis vector ("how much does the signal look like this wave?"). The inverse transform is the inverse change of basis: add the basis vectors back up, each scaled by its coefficient. No information is lost, because N independent basis vectors describe N-dimensional space completely.

**Worked example — a 4-point DFT basis (N = 4):** the four basis vectors, written as rows, are

```
k = 0:  [ 1,  1,  1,  1 ]    (constant — the DC / average component)
k = 1:  [ 1,  i, −1, −i ]    (one cycle across the 4 samples)
k = 2:  [ 1, −1,  1, −1 ]    (two cycles — the fastest possible flip)
k = 3:  [ 1, −i, −1,  i ]    (one cycle, turning the opposite way: a "negative frequency," see §12.4.4)
```

They are complex numbers because a complex exponential packs a cosine and a sine (amplitude and phase) into one number (§12.4.3). With the complex inner product (multiply by the *conjugate* of the second vector, then sum), every pair of different rows gives 0 and every row with itself gives 4 = N. Take the signal **x** = [3, 1, −1, 1]. Its four inner products with the rows are **X** = [4, 4, 0, 4], which is exactly what `np.fft.fft` returns. Going back, (1/4)·(4·row₀ + 4·row₁ + 0·row₂ + 4·row₃) = [3, 1, −1, 1] recovers **x**. In words, **x** is "average 1 everywhere" plus "one slow cycle of amplitude 2," and contains nothing at the fastest frequency. Week 5 formalizes the full DFT formula; this is the same thing written as a 4×4 matrix.

### 12.4.2 From 1D to 2D: an image needs waves that vary in two directions

A 1D signal like sound only has one axis to vary along — time. An image has two: brightness can change as you move left-right (horizontal) *and* as you move up-down (vertical), independently. So the "pure tone" building block for a 2D signal can't be an ordinary 1D sine wave — it needs to be a pattern that can oscillate horizontally, vertically, or diagonally (some mix of both) at once. That building block is a **2D sinusoidal grating**: a repeating stripe pattern, like the gratings from §12.1, but now allowed to run in any direction.

Once that picture is clear, here's the formula it corresponds to (introduced only to read off what each piece means — it isn't manipulated further here):

```
I(x, y) = A · cos(2π(u·x + v·y) + φ)
```

where *x, y* are pixel coordinates, *A* is the grating's amplitude (contrast/strength), *φ* is its phase (where the stripes sit), and — the important pair — **u** is the *horizontal* image frequency (cycles per pixel as you scan left-right) and **v** is the *vertical* image frequency (cycles per pixel as you scan up-down). Per the disambiguation in §12.4.0, these are image frequencies, the same cycles-per-pixel ruler as §12.2.1 — not yet cpd.

What *u* and *v* control, geometrically:
- `v = 0, u > 0`: brightness only changes as *x* changes → **vertical stripes** — a pure "horizontal wave."
- `u = 0, v > 0`: brightness only changes as *y* changes → **horizontal stripes** — a pure "vertical wave."
- `u > 0` and `v > 0` both: stripes run **diagonally**, tilted at an angle set by the ratio of *v* to *u*. The stripes are always oriented *perpendicular* to the direction pointed to by `(u, v)`, and how tightly packed they are is set by the combined image frequency `√(u² + v²)` cycles/pixel.

This is exactly the "image as horizontal and vertical waves" idea: any real image — not just a striped test pattern — can be treated as a giant sum of these 2D gratings, one for every possible `(u, v)` pair, each with its own amplitude and phase. The **2D Fourier transform** is the operation that reports, for every `(u, v)`, how much of that particular tilted stripe pattern is present in the image.

### 12.4.3 What `fft2`'s output actually represents — same shape, different meaning

**What problem this solves.** To separate an image into coarse and fine detail, you need to know how much of each stripe pattern (§12.4.2) the image contains. `fft2` computes exactly that. Input: an *H*×*W* array of pixel brightnesses (one color channel). Output: an *H*×*W* array of complex numbers, one per stripe pattern, giving its strength and shift. Analogy: a prism turns one beam of white light into a rainbow showing how much of each color is present; `fft2` turns a picture into a "rainbow" showing how much of each stripe pattern is present.

This is the single most common point of confusion, worth stating bluntly: when you call `np.fft.fft2` on an *H*-pixel-tall, *W*-pixel-wide image, you get back another array that is also *H*×*W* — but comparing the two arrays entry-by-entry is meaningless, because they represent completely different things.

- In the **input** array, the entry at row *y*, column *x* is the brightness at pixel location `(x, y)`. Spatial domain: index = location.
- In the **output** array, the entry at row `k_v`, column `k_u` — plain integer positions, exactly like any other array index — is a single complex number describing one particular 2D grating: its **magnitude** (the number's size) tells you how strong that grating is in the image, and its **phase** (the number's angle) tells you how that grating is shifted. Frequency domain: index = *which grating*, not a location.

(A complex number's magnitude and phase are just two numbers packaged together — magnitude answers "how much," phase answers "shifted by how much." It's the same amplitude/phase pair from §12.4.1's sine waves, just stored compactly as one number.)

**Linear-algebra view (why the output is the same shape):** flatten an *H*×*W* single-channel image into one vector of *H*·*W* numbers. The 2D gratings of §12.4.2, one for each integer pair `(k_u, k_v)`, are *H*·*W* orthogonal basis vectors for that same space. `fft2` is the change of basis from pixel coordinates to grating coordinates, the 2D version of §12.4.1's 4-point example. A change of basis never changes how many coordinates you need, so *H*·*W* numbers go in and *H*·*W* come out. But entry `[r, c]` means "pixel at (c, r)" in the input and "coefficient of grating `(k_u, k_v) = (c, r)`" in the output. That is why the two arrays can't be compared entry by entry.

**Units, precisely — array index vs. cycles per pixel.** `k_u` and `k_v` are *not yet* the `u` and `v` from §12.4.2's grating formula. `k_u` is a plain integer (0 to *W*−1 before `fftshift`, roughly −*W*/2 to *W*/2 after) that counts how many complete stripe-cycles that grating fits across the image's *entire width* — cycles across the whole image, not cycles per pixel. To get the actual image frequency in cycles per pixel — the same `u`, `v` used everywhere else in §12.4 — divide by the corresponding dimension:

```
u = k_u / W      v = k_v / H
```

Because *W* and *H* can differ for a non-square image, the same array position generally gives *different* cycles-per-pixel values for `u` and `v` — worth remembering whenever reading a frequency straight off an axis.

**Worked example:** a 256-pixel-wide image's `fft2` output has a nonzero entry at column index `k_u = 8`. That grating completes exactly 8 full stripe-cycles across the whole 256-pixel width — its image frequency is `u = 8 / 256 = 0.03125 cycles/pixel`, i.e., one full light-dark cycle every 32 pixels.

The whole array of these magnitudes is called the image's **spectrum** (or *magnitude spectrum*, when specifically plotting `|F(u,v)|` and ignoring phase — usually on a log scale for display, since real photos are dominated by a few very strong low frequencies that would otherwise wash out everything else on a linear scale).

This directly formalizes §12.2.1's "image frequency": once converted from raw array index by dividing by *W* or *H* as above, `u` and `v` are literally measured in cycles per pixel — exactly the unit §12.2.1 defined.

- Low `(u,v)`, near the origin: slow brightness variation — coarse shapes and broad shading.
- High `(u,v)`, far from the origin: rapid variation — fine edges and texture.

This is the precise, computable version of §12.1's qualitative "fine stripes = high frequency" story — there a general, pre-ruler notion of frequency; here specifically image frequency — and it's exactly what lets a computer split an image into the "coarse" and "fine" bands that hybrid images (§13) combine.

**What about color?** `fft2` only accepts a single 2D array, and a color image is really *three* of them stacked — one *H*×*W* array per channel (R, G, B). There's no single joint "color spectrum": you call `fft2` on each channel separately, giving three completely independent spectra, one per channel, each with its own magnitude and phase at every `(k_u, k_v)`. This is exactly what §13.2's "per color channel" means — the whole hybrid-image procedure (transform, mask, add, inverse-transform) repeats three times, once per channel, with no interaction between channels.

### 12.4.4 `fftshift`: reordering the output to match intuition

**What problem this solves.** `fft2` stores its output in an order that is awkward to read and to mask. `fftshift` only rearranges that array so zero frequency sits in the center. Input: a raw `fft2` output array. Output: the same numbers, same shape, with the four quadrants swapped diagonally. Analogy: a map printed with its center torn into the four corners; `fftshift` tapes the corners back so the center is in the middle again, and `ifftshift` tears it back apart.

Display a raw `fft2` output's magnitude as an image, and it looks wrong at first: the brightest spot — the **DC component**, meaning zero image frequency, `u = v = 0`, which is just the image's overall average brightness — sits in a *corner*, not the center, and the pattern seems to wrap around the edges.

Why: in how the discrete Fourier transform indexes frequencies, index 0 means frequency 0 as expected, but the far end of the array (index *N*−1) doesn't mean "the highest positive frequency" — it means a small *negative* frequency, because the transform is periodic and treats frequency *N*−1 as identical to frequency −1. So the second half of each axis actually holds the negative frequencies, wrapped around to the far end of the array instead of sitting naturally in front of frequency 0.

Concretely, since rows index *v* and columns index *u*, each of the raw array's four quadrants holds one fixed combination of signs: top-left is `u ≥ 0, v ≥ 0` (and contains the DC corner), top-right is `u < 0, v ≥ 0`, bottom-left is `u ≥ 0, v < 0`, and bottom-right is `u < 0, v < 0`. `fftshift` doesn't touch a single pixel's *value* — it only relocates these four fixed-sign blocks so they meet at a shared center instead of wrapping at the array's outer edges, which is why frequency 0 ends up in the **center** and frequency magnitude increases outward in every direction from there — matching the natural mental picture of a spectrum, and matching how the low-pass/high-pass masks in §12.4.5 are naturally described ("a disc around the center"). `ifftshift` undoes exactly this reordering, and must be applied *before* `ifft2`, since `ifft2` expects the original DC-in-the-corner layout, not the shifted one.

### 12.4.4a Convolution from scratch (the operation §12.4.5 and §13 secretly rely on)

§12.4.5 below says "multiplying spectra is the same as convolving signals." That sentence is meaningless until **convolution** itself has been defined, so this subsection builds it from nothing, then motivates *why* the theorem is true (it is explained, and checked on numbers, not just announced). The same idea returns in Week 2 §3 (pinhole blur), Week 3 §12.2 (Gaussian smoothing), Week 4 §18 (PSF/OTF) and §23 (flutter shutter), and in LiDAR ranging (Part 9 below).

**Part 1 — Analogy: a stamp, and a sliding window.**
- *Stamp view (each point spreads its light).* Imagine a row of light bulbs of different brightness, photographed out of focus. Each bulb does not land on the sensor as one dot; it lands as a small soft blob. The photo is every bulb's blob added together, where a brighter bulb stamps a stronger blob. The blob's shape is the **kernel**. Convolution is "stamp a copy of the kernel at every input sample, scaled by that sample's value, and add all the stamps."
- *Window view (a weighted neighborhood average).* The same arithmetic, read from the output's side: to get one output value, slide a small window of weights over the input, multiply the input values under the window by the weights, and add. This is the "average each pixel with its neighbors" of §13.1, now allowed to use *unequal* weights.

**Part 2 — Definition in 1D (discrete signals).** A 1D signal here is a list of numbers `x[0], x[1], ...` (for example, brightness along one scanline). The convolution of `x` with a kernel `h` is a new list:

```
(x * h)[n] = sum over m of  h[m] · x[n − m]
```

- *Intuition, step by step.* (1) The output at position `n` is a weighted sum of input values near `n`. (2) The weight `h[m]` multiplies the input value that sits `m` steps *behind* `n` (index `n − m`). (3) Equivalently, the input sample `x[j]` contributes `x[j]·h[m]` to output position `n = j + m`, which is the stamp view: a copy of `h`, scaled by `x[j]`, starting at position `j`. The two readings are the same sum with the indices relabeled.
- *Why `n − m` (the "flip").* Walking `m` forward in the kernel walks backward in the input. So in the window view the kernel appears *reversed* relative to the signal. For a symmetric kernel (like `[¼, ½, ¼]`) the reversal changes nothing, so it is easy to miss; for an asymmetric kernel it matters (see the impulse example in Part 3).
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

**Part 3 — Fully worked 1D example (stamp view and window view agree).** Signal `x = [1, 3, 2, 5, 4]` (positions 0 to 4), kernel `h = [¼, ½, ¼]` (positions 0 to 2; a weighted 3-point average). Zero-pad: treat everything outside the signal as 0.

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

**Part 4 — Tiny 2D example.** Images are convolved the same way, with the kernel sliding in both directions: each output pixel is a weighted sum over a small 2D neighborhood. Take the `3×3` image and a `2×2` kernel whose four weights are all `¼` (a 4-pixel average):

```
image            kernel (2x2 box)       output, "valid" region only (2x2)
1 2 3            0.25 0.25              3 4
4 5 6            0.25 0.25              6 7
7 8 9
```

Top-left output: `(1 + 2 + 4 + 5)/4 = 3`; the other three follow the same way. "Valid" means only positions where the kernel fits entirely inside the image (output smaller than input: `3−2+1 = 2` per side). 2D impulse: a `3×3` image that is all 0 except a single `4` in the center, convolved with the same box kernel (full output, `4×4`), gives a `2×2` block of `1`s (`4 × ¼`) in the middle: a copy of the kernel scaled by the impulse's value. That copy is the 2D PSF in action.

**Part 5 — Terminology, in one place.**

| Term | Plain meaning |
|---|---|
| **Kernel** (also **filter**, **mask**, **template**; for optics, **PSF**; for signals, **impulse response**) | the small list/grid of weights `h` that gets slid over the signal. "Mask" is also used for the 0/1 frequency masks of §12.4.5, which is a different object (it lives in the frequency domain). |
| **Tap** | one entry of the kernel; a 3-tap kernel has 3 weights. |
| **Support** | the positions where the kernel is nonzero; its width is how far one point's light can spread (3 for `[¼, ½, ¼]`). |
| **Normalization** | scaling the kernel so its weights sum to 1; then flat regions keep their brightness and total light is conserved. |
| **Boundary handling / padding** | what to assume outside the signal where the window overhangs the edge: zeros (**zero-padding**, used above), repeat the edge value, mirror, or wrap around to the opposite side (**circular**, which is what the DFT silently assumes; §12.4.4's wrap-around). |
| **Full / same / valid** | which output positions to keep: all (length `N+K−1`), the central `N`, or only those where the kernel fully fits (`N−K+1`). |
| **Impulse / delta** | the signal that is a single 1 and zeros elsewhere. |
| **Linear** | scaling or adding inputs scales or adds outputs: `(a·x₁ + b·x₂)*h = a·(x₁*h) + b·(x₂*h)`. |
| **Shift-invariant** (time-invariant for signals in time) | shifting the input by `d` shifts the output by `d`; the same kernel applies everywhere. |
| **LSI system** (linear shift-invariant) | any system with both properties. **Every LSI system is a convolution with its impulse response**, which is why a camera's blur is fully described by one PSF *when* the blur is the same everywhere. |

**Part 6 — Properties worth knowing (all follow from the definition).**
- *Commutative:* `x * h = h * x` (signal and kernel are interchangeable roles).
- *Associative:* `(x * h₁) * h₂ = x * (h₁ * h₂)`: two blurs in a row equal one blur by the combined kernel (two small Gaussians make a wider Gaussian).
- *Distributive and linear:* `x * (h₁ + h₂) = x*h₁ + x*h₂`; this is what makes "blur, then subtract from the original" (the §13.1 high-pass) itself a convolution, with kernel `δ − h` (`δ` = the delta kernel `[1]`).
- *Identity:* convolving with the delta returns the signal unchanged: `x * δ = x`.
- *Shift:* convolving with a delta that sits `d` steps over just translates the signal by `d`.

**Part 7 — The convolution theorem, motivated (not just stated).**

*Step 1: why a sinusoid is special.* Feed a pure wave (say a cosine at one frequency) into an LSI system. Shift-invariance says shifting the input wave shifts the output the same way. A shifted cosine is a mix of that same-frequency cosine and sine. So the output cannot contain any *new* frequency: a wave comes out as **the same-frequency wave, scaled in amplitude and shifted in phase**. In linear-algebra language, sinusoids are the **eigenvectors** of every convolution (§12.4.5's callout), and the scale-and-shift for each frequency is its **eigenvalue**, a complex number `H(f)`.

*Step 2: check on numbers.* Use the 4-sample circular version from §12.4.1/§12.4.5: kernel `[½, ¼, 0, ¼]` and the slow cosine `[1, 0, −1, 0]` (k = 1). Convolving gives `[½, 0, −½, 0]`: the same wave, scaled by `½`. That `½` is exactly the kernel's DFT at `k = 1` (§12.4.5 lists the eigenvalues `[1, ½, 0, ½]`).

*Step 3: assemble.* Any signal is a sum of sinusoids (§12.4.1). Convolution is linear, so convolve each sinusoid separately, and each one only gets multiplied by its own number `H(f)`. Re-adding gives the result. The bookkeeping is:

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

Same pattern in every column, shifted down one row each time: constant along diagonals, a **Toeplitz** matrix; with wrap-around edges it becomes the **circulant** matrix of §12.4.5. The Fourier basis vectors (§12.4.1) are its eigenvectors; the eigenvalues are `DFT{h}`; so in the Fourier basis the whole matrix is a diagonal list of scale factors, and applying `H` costs one multiply per frequency. That diagonalization *is* the convolution theorem. Inverting `H` (deconvolution, next subsection) is therefore "divide by each eigenvalue," which fails exactly where an eigenvalue is 0.

**Part 8 — Where this shows up, so you know why it is worth the detour.**
- Blur from optics (finite pinhole, defocus, diffraction, lens aberrations) is a convolution with a PSF (Week 2 §3, §9; formalized in Week 4 §18).
- Motion blur is a convolution with a box along the motion direction (Week 4 §4.3, §23).
- Denoising/smoothing filters such as the Gaussian (Week 3 §12.2) are convolutions; the median and bilateral filters are *not* (they are non-linear).
- Demosaicking's interpolation and unsharp masking (Week 3 §14.1, §17) are convolutions.
- Hybrid images (§13) are a convolution (blur) and its complement.

### 12.4.4b Deconvolution, a first look (the reverse problem)

**Forward vs. inverse.** *Forward problem:* given a sharp signal and a kernel, compute the blurred result (convolution, above). *Inverse problem:* given the blurred result (and, usually, the kernel), recover the sharp signal. **Deconvolution** is that inverse problem. This is only a primer so the word is never undefined; the real treatment (the exact formulas, the Wiener filter) is **Week 5**, and priors that tame the hard cases are **Week 6**.

**Analogy.** Convolution is stirring a drop of dye into a glass of water; deconvolution is un-stirring it. If you know exactly how the water was stirred, and measured exactly, the motion can in principle be reversed. If your measurement is slightly off, or some detail was mixed beyond recovery, the "un-stirred" result will be garbage. Both halves of that sentence are the whole subject.

**How it works in the simplest case: divide in the Fourier domain.** The theorem (Part 7) says blurring multiplies each frequency by `DFT{h}`. To undo it, divide each frequency of the blurred spectrum by `DFT{h}` and inverse-transform. This is the **inverse filter**. Linear-algebra view: it is applying `H⁻¹`, and in the Fourier basis `H⁻¹` is a diagonal matrix of `1/DFT{h}`.

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

### 12.4.5 Filtering in the frequency domain, and the convolution theorem

**What problem this solves.** You want to keep only the coarse part of an image (or only the fine part) with precise control over where the split happens. A frequency-domain mask does this. Input: a shifted spectrum plus a 0/1 mask the same shape. Output: a filtered spectrum, which `ifftshift` and `ifft2` turn back into an image. Analogy: an audio equalizer that mutes the bass or the treble sliders, here with stripe patterns instead of pitches.

Once a spectrum is fftshift-ed (DC centered), building a filter becomes a simple masking operation: to keep only low image frequencies, zero out everything except a disc around the center — a **low-pass filter**. To keep only high image frequencies, do the opposite — zero out that disc and keep everything outside it — a **high-pass filter**, the complement of the low-pass mask.

Multiplying a spectrum by such a mask, then inverse-transforming back (`ifftshift`, then `ifft2`) to the spatial domain, produces a filtered image — and this turns out to be the *exact same operation* as §13.1's spatial-domain description (blurring by averaging neighboring pixels; edge-extraction by subtracting a blur from the original). This equivalence has a name: the **convolution theorem** (motivated and checked on numbers in §12.4.4a above) — multiplying two spectra together in the frequency domain is mathematically identical to *convolving* (the sliding weighted sum of §12.4.4a, the formal name for the neighbor-averaging operation §13.1 describes informally) the two corresponding signals in the spatial domain. The frequency-domain route (mask + `fft2`/`ifft2`) and the spatial-domain route (blur/subtract) are two views of *one* operation, not two different techniques — the frequency-domain view is usually easier to control precisely (e.g., choosing an exact cutoff frequency as a mask radius), and it's the route HW1's own code path actually uses.

**Linear-algebra view (a mask is a projection):** in the Fourier basis, multiplying by a 0/1 mask is a **diagonal matrix** with 1s for the kept frequencies and 0s for the rest. Seen in pixel space, that operation is a **projection onto the subspace** spanned by the kept sinusoids. Applying it twice changes nothing more (P² = P). The high-pass mask is the complementary projection I − P onto the remaining sinusoids. Because the basis is orthogonal, the two pieces are orthogonal to each other and add back up to the original exactly.

**Linear-algebra view (convolution is a matrix the Fourier basis diagonalizes):** convolution with a fixed kernel is a **linear operator** (blur(a·x + b·y) = a·blur(x) + b·blur(y)), so it is some matrix acting on the image vector. It is also **shift-invariant** (the same weights are used at every position), so each row of the matrix is the row above shifted by one. With the wrap-around edges the DFT assumes, that is a **circulant** matrix (a **Toeplitz** matrix, constant along each diagonal, if edges are not wrapped). Every sinusoid is an **eigenvector** of every circulant matrix: blurring a pure wave returns the same wave, only scaled. The scale factors (eigenvalues) are exactly the kernel's own DFT. So switching to the Fourier basis **diagonalizes** the convolution matrix, and a full matrix–vector product becomes one multiplication per frequency. The convolution theorem is precisely this diagonalization. Week 5 ("Sampling, Linear Systems, Deconvolution") builds on this same matrix view of convolution.

**Worked example — continuing §12.4.1's 4-point signal x = [3, 1, −1, 1]:**
- *Projection.* A low-pass mask that keeps only k = 0 gives [1, 1, 1, 1]. Its complement (k = 1, 2, 3) gives [2, 0, −2, 0]. Their inner product is 0 (orthogonal), they sum back to **x**, and re-applying the low-pass mask to [1, 1, 1, 1] returns it unchanged.
- *Diagonalization.* The circular blur kernel [½, ¼, 0, ¼] (half weight on the sample itself, a quarter on each neighbor) builds the circulant matrix

  ```
  [ 0.5   0.25  0     0.25 ]
  [ 0.25  0.5   0.25  0    ]
  [ 0     0.25  0.5   0.25 ]
  [ 0.25  0     0.25  0.5  ]
  ```

  Each of the four basis vectors from §12.4.1 is an eigenvector of it, with eigenvalues [1, 0.5, 0, 0.5]. That list is also `np.fft.fft` of the kernel. So this blur keeps the average (1), halves the slow cycle (0.5), and wipes out the fastest flip (0): a low-pass filter.
- *Two routes, one answer.* The matrix times **x** gives [2, 1, 0, 1]. The frequency route gives the same result: [4, 4, 0, 4] × [1, 0.5, 0, 0.5] = [4, 2, 0, 2], and inverse-transforming that gives [2, 1, 0, 1].

**Forward pointer:** this same convolution theorem is the mechanism behind the point spread function (PSF) and Wiener filtering (Week 5), and prior-based deconvolution (Week 6) — in both cases, a blur is described as convolution in the spatial domain and as multiplication in the frequency domain, and "undoing" a blur means dividing out its frequency-domain multiplier. §12.4.4a defines convolution and the theorem; §12.4.4b gives the first look at undoing a blur; this subsection is where the theorem is first put to work.

---

## 13. [Hybrid Images](https://en.wikipedia.org/wiki/Hybrid_image) (Oliva, Torralba & Schyns, 2006, SIGGRAPH)

Every "frequency" word in this section is **spatial frequency**, exactly as pinned down in §12.0 — how rapidly brightness changes as you scan across the image, nothing to do with color or with time — with one exception: §13.2's Fourier-domain mechanism works in **image frequency** (the fft2 `(u,v)` ruler from §12.4.0), not spatial frequency. §13.1 and §13.3 stay at the general/perceptual level where "spatial frequency" is correct.

**Core idea:** merge two different images into one composite such that:
- **Viewed up close** → the **high-spatial-frequency** (fine detail, sharp edges) content dominates perception → you see Image A.
- **Viewed from far away** → the **low-spatial-frequency** (coarse, blurry, "gist") content dominates perception → you see Image B.

### 13.1 What the two filters actually do to an image, concretely

Any photo can be thought of as a mix of coarse structure (the rough shapes and overall shading — low spatial frequency) plus fine structure layered on top (edges, texture, fine detail — high spatial frequency). The two filters split that mix apart:

- A **[low-pass filter](https://en.wikipedia.org/wiki/Low-pass_filter)** blurs the image — literally, e.g. averaging each pixel with its neighbors. Averaging smooths out anything that changes quickly from pixel to pixel (high spatial frequency), while leaving slow, broad variations (low spatial frequency) mostly intact. The result looks like the original image out of focus.
- A **[high-pass filter](https://en.wikipedia.org/wiki/High-pass_filter)** does the opposite: subtract a blurred version of the image from the original. Whatever was slow/broad cancels out (since it was present in both the original and the blur), leaving only the fast-changing edges and fine texture behind — the result looks like a faint line drawing of just the edges, mid-gray everywhere else.

### 13.2 Mechanism, tying directly back to §12 and §12.4

In code, this isn't done by blurring and subtracting pixels directly — it's done in the frequency domain, using exactly the machinery §12.4 just built:

1. Take Image A, compute its spectrum (`fft2`, then `fftshift` so the DC component sits at the center — §12.4.3–12.4.4), and apply a **high-pass mask** (§12.4.5) to keep only its high-`(u,v)` content — fine detail and sharp edges. Call this masked spectrum `H_A(u,v)`.
2. Take Image B, compute its spectrum the same way, and apply a **low-pass mask** to keep only its low-`(u,v)` content — coarse, smooth structure. Call this masked spectrum `L_B(u,v)`.
3. **Add the two masked spectra together**, entry by entry, per color channel — literal Fourier-domain addition, not a spatial-domain blend of pixel values:

   ```
   F_hybrid(u, v) = H_A(u, v) + L_B(u, v)
   ```

4. Undo the shift (`ifftshift`) and inverse-transform (`ifft2`) back to the spatial domain to recover the hybrid image's actual pixel values.

By the convolution theorem (built in §12.4.4a, applied in §12.4.5), this frequency-domain construction is mathematically equivalent to §13.1's blur-and-subtract description — the two are the same operation, viewed in two different domains; the frequency-domain route is just the one that gives precise control over the cutoff.

**Linear-algebra view (a hybrid image is a sum of two projections):** writing each image channel as a vector (§12.4.3's aside), the whole recipe is **hybrid** = P_high **a** + P_low **b**. Here P_low is the low-pass projection onto the span of the low-frequency gratings, and P_high = I − P_low projects onto the rest (§12.4.5's aside). If the two masks are exact complements, as in §12.4.5, the two pieces live in **orthogonal subspaces**, so the sum mixes them without either overwriting the other. Your CSF at a given viewing distance acts like a third, perceptual filter that mostly lets through one of the two subspaces. Because `fft2`/`ifft2` are linear, adding in the frequency domain (step 3) gives the same result as adding the two filtered images pixel by pixel. That is another reason the frequency-domain and blur-and-subtract descriptions agree.

The result is a single image containing *both* spatial-frequency bands at once, stacked on top of each other. Which band you consciously perceive depends entirely on **viewing distance**, because — per §12.3 — your CSF determines which spatial-frequency band is currently sitting in your visible range at that distance.

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

## 15. [Stereoscopic](https://en.wikipedia.org/wiki/Stereoscopy) Displays

**Stereoscopic** comes from *stereo* ("two"/"solid") + *scopic* ("viewing") — literally "two-eyed viewing." It describes anything that recreates depth by giving each eye a slightly different image, the way ordinary binocular vision already works: your two eyes sit a few centimeters apart, so each sees the same scene from a slightly different horizontal viewpoint, and the difference between those two views (**binocular disparity**, §14) is what your brain decodes into depth.

A **stereoscopic** device or display exploits this on purpose: instead of showing both eyes the same flat image, it feeds each eye its own slightly-offset image, so the brain perceives depth that isn't really there on a flat screen or print. Stereoscopic 3D displays work by presenting each eye a slightly different image (mimicking binocular disparity, §14) so the brain fuses them into a perceived depth.

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
- **Dynamic range**: ~6.5 f-stops instantaneous, adapts up to ~46.5 total. The "total" figure is a straightforward unit conversion of §10's ~14 orders of magnitude (1 order of magnitude ≈ 3.32 f-stops, so 14 × 3.32 ≈ 46.5 f-stops — consistent). The "instantaneous" figure is *not* a matching conversion of §10's ~5 orders of magnitude, though — 5 orders of magnitude is ≈16.6 f-stops, not 6.5. These are two independently-cited numbers for "instantaneous" range (6.5 f-stops being the eye's truly momentary, no-adaptation contrast range; ~5 orders of magnitude a looser, more commonly quoted figure that already includes some fast local adaptation) rather than the same number in two units — worth knowing they don't reduce to each other.
- **Color**: describable by the CIE xy chromaticity diagram; perceptual distances between colors are approximately linear (uniform) in CIE Lab space (a color space designed so that equal numeric distances correspond to roughly equal perceived color differences)
- **Depth cues in 3D displays**: vergence, focus (accommodation), their potential conflict, and resulting (dis)comfort (§14–§16)
- **Accommodation range**: ~8 cm to ∞ (young), degrading with age (§5)

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check
If you can explain, in your own words, *why* a hybrid image looks different up close vs. far away using only the words "spatial frequency," "contrast sensitivity function," and "low/high-pass filter" — you've understood the core idea of Week 1.
