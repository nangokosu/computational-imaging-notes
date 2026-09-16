# CSC2529 Computational Imaging — Week 2 Study Notes

**Topic:** Digital Photography I — Ray Optics, Aperture, Sensor
**Source:** Lecture 2 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 2 ("PS2," a TA problem session covering HW2), Task 1 only (f-number / depth of field / circle of confusion); reading: Marc Levoy, Stanford CS178 "Digital Photography" course.
**Scope:** Announcements and the guest-colloquium plug skipped — notes start from "Let's say we have a sensor…". PS2's Tasks 2–3 (demosaicing methods, gamma correction, denoising) belong to the image-signal-processing pipeline the lecture itself defers to "Next" — that material is Week 3's, not repeated here.

---

## 0. Why doesn't a bare sensor take a picture?

Point a digital sensor (the electronic chip that converts light into an electrical signal — introduced as the camera's "retina" in Week 1 §1, §4) at a scene with nothing in between, and you get nothing usable: every point on the sensor receives light from *every* point in the scene at once, all overlapping. There is no optical element separating "light from here" from "light from there," so the sensor just measures one blurred average brightness everywhere — not an image.

Everything in this lecture is optics or sensing built to fix exactly that problem: some device between scene and sensor that maps *each scene point to (ideally) one sensor location*, so that spatial structure in the scene survives into spatial structure in the image.

**Standing assumption — ray optics.** Both the pinhole camera (§1–3) and the lens (§4 onward, until §9 revisits wave effects) are analyzed using **[ray optics](https://en.wikipedia.org/wiki/Geometrical_optics)** (also called geometric optics): light is modeled as travelling in perfectly straight lines ("rays") that only bend at a lens surface or get blocked by an opaque barrier, ignoring the fact that light is actually a wave. This is the same simplifying assumption behind HW1's pinhole-box geometry. It's an excellent approximation almost everywhere in this lecture — until §2 and §9, where the *size* of an opening becomes small enough that light's wave nature can no longer be ignored, and ray optics alone stops predicting the right answer.

---

## 1. The Pinhole Camera

**Fix:** put an opaque barrier (a **diaphragm**) between scene and sensor, with a single small opening in it — a **pinhole**, also called a **[camera obscura](https://en.wikipedia.org/wiki/Camera_obscura)**, or the camera's **[aperture](https://en.wikipedia.org/wiki/Aperture)** in this context (the general "opening that controls how much light gets in," first introduced via the eye's pupil in Week 1 §1). Now, of all the rays leaving any one scene point in every direction, only the *one* ray heading straight at the pinhole makes it through to the sensor — every other ray from that point is blocked by the barrier. Each scene point therefore lights up (ideally) exactly one sensor location, instead of smearing across the whole sensor as in §0.

**Geometry and terms** (all consequences of straight-line ray optics, §0):
- **Camera center** (or **center of projection**): the pinhole itself — every surviving ray passes through this single point.
- **Image plane**: the sensor surface, where the surviving rays land.
- **Focal length, f**: the distance from the pinhole to the image plane.

Because every ray travels in a straight line through one fixed point (the pinhole), the image that lands on the sensor is a scaled, upside-down copy of the scene — trace a ray from the top of an object, through the pinhole, and by simple straight-line geometry it continues downward, landing on the *bottom* of the image plane (and vice versa). This is the same similar-triangles idea used throughout the course: two rays from the same object point, one passing above the pinhole's axis and one below, form mirror-image triangles on either side of the pinhole, so the image is inverted **and** rescaled by the ratio of distances (pinhole-to-sensor vs. pinhole-to-object).

**Focal length controls image size.** Halving the focal length (moving the sensor to sit half as far behind the pinhole) exactly halves the size of the projected image, for the same reason a shadow shrinks as you move the wall closer to the object: the same cone of rays from an object, converging back down to the single pinhole point, is caught by the image plane at half the distance, so it's caught before spreading as wide.

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

These two facts are the geometric seed of the aperture/f-number trade-off formalized in §7, and of the exposure concept formalized in §12.

---

## 4. Refraction and the Thin Lens Model

A pinhole's fundamental problem is that "small enough to be sharp" and "large enough to gather useful light" pull in opposite directions (§2–3) — a pinhole can never have both. A **lens** — a shaped piece of transparent material, most often glass — solves this by bending many rays from the same scene point back together at one image point, so the imaging aperture can be made large (lots of light) without smearing the image (still sharp).

**[Refraction](https://en.wikipedia.org/wiki/Refraction)** is the bending of a light ray when it crosses the boundary between two materials with different optical densities (e.g., air into glass) — the same phenomenon that makes a straw look bent where it enters a glass of water. A lens is manufactured with precisely curved surfaces so that refraction bends parallel or diverging rays in a specific, useful way: toward a common point.

**The thin lens model** is a deliberate simplification of real (curved, thick) lens geometry, valid for well-designed lenses, built on two assumptions:

1. **A ray passing through the exact center of the lens is unaffected** — it continues in a straight line, as if the lens weren't there.
2. **All rays that arrive parallel to each other converge to a single point on the focal plane** — the plane located one focal length *f* behind the lens.

These two assumptions are enough to trace an image by hand using three characteristic rays from any object point:
- the **parallel ray**, which travels parallel to the lens's main axis and then bends through the far focal point (assumption 2);
- the **chief ray**, which passes straight through the lens center unbent (assumption 1);
- the **near-focal-plane ray**, which passes through the *near* focal point on its way to the lens and emerges parallel to the axis (the reverse of assumption 2).

All three rays from the same object point reconverge at the same image point — which is both the geometric justification for the thin lens model and the standard hand-tracing technique for predicting where an image will form.

**The thin lens equation**, relating object distance *S₁* (from lens to object) and image distance *S₂* (from lens to the sharp image it forms) to the lens's focal length *f*:

```
1/f = 1/S₁ + 1/S₂
```

*(derivation intuition: both S₁ and S₂ are being measured from the same lens, and the two assumptions above say the lens has exactly one focal length that governs both "how parallel rays converge" and "how a nearby point re-diverges" — the equation is the algebraic statement that these two facts about the same lens must be mutually consistent for any conjugate object/image pair.)*

**Magnification** — how much larger or smaller the image is than the object:

```
M = f / (f − S₁)
```

*(consistent with §1's pinhole finding that a shorter focal length shrinks the image: as f shrinks relative to a fixed S₁, |M| shrinks too.)* When the object sits *closer* than one focal length (S₁ < f), the lens acts as a magnifying glass, producing an enlarged, upright virtual image; at typical photographic distances (S₁ > f), it produces a real, inverted, minified image on the sensor — exactly the pinhole-camera picture of §1, now achieved with far more light-gathering aperture.

---

## 5. Real Lenses: Compound Lenses and Aberrations

**Thin lenses are a fiction.** The thin lens model assumes a lens with literally zero thickness, which no real lens has. Real camera lenses are **compound lenses**: several individual lens elements stacked together, engineered so that, to a good approximation, the whole stack behaves paraxially (i.e., for rays close to the central axis) like one single ideal thin lens with some equivalent focal length and aperture.

Even a well-engineered compound lens doesn't behave *exactly* like the thin lens model — the differences are called **aberrations**: any systematic deviation from ideal thin-lens focusing behavior.

| Aberration | Cause | Where it appears |
|---|---|---|
| **Spherical aberration** | Real lens surfaces are usually ground *spherical*, not the ideal hyperbolic shape that would perfectly focus parallel rays to one point (spherical surfaces are simply far easier to manufacture — two curved surfaces ground together mechanically settle into a sphere) | Everywhere in the field, worst for rays far from the lens's central axis |
| **[Chromatic aberration](https://en.wikipedia.org/wiki/Chromatic_aberration)** | Glass has **[dispersion](https://en.wikipedia.org/wiki/Dispersion_(optics))** — its refractive index (and therefore its effective focal length) depends slightly on wavelength — so different colors of light focus at slightly different distances | Everywhere in the field; partially correctable with a two-element "doublet" combining glasses of different dispersion so their errors cancel |
| **Oblique aberrations** (coma, pincushion/barrel distortion, etc.) | Departures from the paraxial assumption itself | Only away from the center of the field of view — unlike spherical/chromatic aberration, these are zero exactly on-axis and grow toward the edges |

A famous real-world example: the Hubble Space Telescope's primary mirror originally suffered from severe spherical aberration due to a manufacturing error, corrected in orbit by the COSTAR instrument package — a striking demonstration that "aberration" is a precise, fixable geometric fact about a specific optical system, not just a vague image-quality complaint.

---

## 6. Field of View

**[Field of view (FOV)](https://en.wikipedia.org/wiki/Field_of_view)** is the angular extent of the scene a lens/sensor combination captures — the same angular-extent idea introduced for the human eye in Week 1 §7 (monocular ~190°, binocular ~120°), now applied to a camera. It depends on both the lens's focal length *f* and the physical size of the sensor (or film) capturing the image: a longer focal length concentrates the same sensor size onto a narrower angular slice of the scene (a "telephoto" or "zoom" effect), while a shorter focal length spreads a wider angular slice onto that same sensor size (a "wide-angle" effect).

This is exactly the same right-triangle relationship as Week 1 §9's screen-pixel formula, just run in the opposite direction: there, a fixed angle and a known distance gave a physical size; here, a fixed physical size (the sensor) and a known distance (the focal length) give an angle. For a sensor dimension *d* and focal length *f*:

```
FOV = 2 · arctan(d / (2f))
```

Concretely (values as cited in lecture, for a full-frame sensor): an 8 mm lens gives roughly 180° FOV, a 50 mm "normal" lens gives roughly 43°, and a 1000 mm super-telephoto lens narrows to roughly 2.5° — the same sensor size, wildly different captured angle, purely as a function of focal length.

---

## 7. Aperture and F-Number

Most real lenses include an adjustable **aperture** (§1) — typically a diaphragm made of overlapping blades, mechanically playing the same role as the eye's iris (Week 1 §1) — that can widen or narrow the effective diameter *D* of the lens opening, independent of the lens's fixed focal length *f*.

The standard way to describe aperture size is the **[f-number](https://en.wikipedia.org/wiki/F-number)**, *N*, written as "f/*N*":

```
N = f / D
```

i.e., f-number is focal length divided by aperture diameter — so, confusingly, a *larger* f-number (like f/16) means a *smaller* physical opening, and a *smaller* f-number (like f/1.4) means a *larger* opening. Aperture sizes are conventionally spaced in **stops**, where one full stop changes the amount of light reaching the sensor by a factor of 2× (the same "stop" unit already introduced for dynamic range in Week 1 §10) — so f/2.8 lets in twice as much light as f/4, which lets in twice as much as f/5.6, and so on.

By §3's area-scales-as-diameter-squared logic, halving the f-number (doubling the aperture diameter *D* at fixed *f*) quadruples the light reaching the sensor — the exact same 2× diameter → 4× light relationship already derived for pinholes, now expressed through *N* instead of *D* directly.

Widening the aperture doesn't only affect brightness — it also affects how much of the scene appears sharply focused at once, which is exactly the subject of §8.

---

## 8. Depth of Field and Circle of Confusion

This is the most important technical concept of Week 2 — the direct basis for PS2's Task 1 and for HW2. It answers a question the thin lens equation (§4) leaves hanging: that equation names *one* object distance *S₁* that focuses perfectly onto the sensor — so what happens to everything else in the scene, at every *other* distance?

### 8.1 What "in focus" and "out of focus" actually mean, geometrically

The thin lens equation (§4) guarantees a perfectly sharp image point only for an object sitting at the *one* distance *S₁* the lens is currently focused on (i.e., the distance for which the sensor sits exactly at the corresponding image distance *S₂* the equation predicts). An object at any *other* distance *S* still has rays converging somewhere — just not exactly *at* the sensor plane. Those rays, caught by the sensor slightly before or after their true convergence point, form a small blurred disc on the sensor instead of a sharp point. That disc is the **circle of confusion**.

### 8.2 The circle-of-confusion formula

For a lens with aperture diameter *D*, focused at distance *S₁*, imaging an object actually at distance *S*, the diameter of the resulting blur disc on the sensor is:

```
c = M · D · |S − S₁| / S
```

where *M* is the magnification for the focused distance (§4, M = f/(S₁ − f) here, up to the sign convention used for this particular formula — only its magnitude matters for a blur-disc *size*, which can't be negative).

*(derivation intuition: |S − S₁| is how far the actual object sits from the plane the lens is focused on — the "focus error." If that error is zero (S = S₁), c is exactly zero: perfect focus, matching §8.1. As the focus error grows, the blur disc grows too, and it grows fastest for a large aperture diameter D — consistent with §2's pinhole finding that a bigger opening produces more geometric blur, now formalized for a lens instead of a pinhole.)*

### 8.3 Depth of field: the range where blur stays imperceptible

A real sensor's own pixel grid already has finite resolution (Week 1 §12.2.1's "image frequency" ruler is fixed by pixel pitch), so a blur disc smaller than roughly one pixel is simply invisible — it can't be told apart from a perfectly sharp point at that resolution. **[Depth of field (DoF)](https://en.wikipedia.org/wiki/Depth_of_field)** is exactly this: the range of object distances *S* for which the circle of confusion *c* stays below that pixel-set "acceptable blur" threshold, rather than the single exact distance *S₁* the lens happens to be focused on.

> **Worked example, from lecture (method only — not solved here).** For a Canon 5D Mark III with f = 50 mm, N = 2.8, focused at 5 m, and a 7.5 µm pixel pitch, §8.2's formula gives a curve of circle-of-confusion size (in pixels) vs. object distance. The lecture's own exercise is: "using the graph [of c vs. distance], what is the depth of field?" — i.e., read off the distance range where the curve stays under the allowed-blur threshold. Per this project's policy of never computing the specific numeric answers a homework/exercise asks the student to derive, that range is intentionally left uncomputed here — but the *method* is exactly §8.2's formula, evaluated across a range of S and compared against a fixed pixel-based threshold.

**Why a small f-number gives shallow depth of field.** Because *c* in §8.2 grows in proportion to aperture diameter *D*, and *D* = f/N (§7, rearranged), a *smaller* f-number (bigger aperture, more light) makes *c* grow *faster* as the actual object distance strays from *S₁* — so the "acceptable blur" range shrinks. This is the classic depth-of-field trade-off: more light (small N) inherently costs you a shallower zone of acceptable sharpness. It's also why focusing far away costs you less depth-of-field sensitivity to the *lens's* f-number than focusing close up does — at large S₁, the same aperture produces proportionally less blur growth per unit of focus error, holding f fixed.

### 8.4 Hyperfocal distance

The **hyperfocal distance**, *H*, is the specific focus distance that pushes the *far* edge of the depth-of-field range all the way out to infinity — i.e., focus at *H* and everything from roughly *H*/2 out to infinity satisfies §8.3's "acceptable blur" threshold simultaneously:

```
H = f² / (N · c)
```

where *c* here is the fixed acceptable-circle-of-confusion threshold (set by pixel size, as in §8.3), not a variable. Focusing at the hyperfocal distance is a classic landscape-photography technique for maximizing the usable in-focus range without stopping the aperture down so far that diffraction (§2, §9) starts to matter.

---

## 9. The Diffraction Limit, Formalized

§2 introduced diffraction qualitatively: shrinking an opening spreads its Fourier-transform-shaped diffraction pattern wider. Ernst Abbe (1873) made this precise for a lens system, giving the smallest resolvable spot radius *d* an optical system can produce, purely as a consequence of diffraction (i.e., the best possible result even with zero aberrations, §5):

```
d = λ / (2n·sinθ) = λ / (2·NA) ≈ λN
```

Here *λ* is the wavelength of light being imaged (light frequency, in Week 1 §12.0's disambiguation — nothing to do with spatial or temporal frequency), and **numerical aperture**, *NA = n·sinθ*, packages together the refractive index *n* of the medium and the half-angle *θ* of the widest cone of light the lens can accept or emit — a bigger NA means the lens gathers a wider cone of rays, which (by the same Fourier-transform logic as §2, run in reverse) corresponds to a *narrower*, more tightly focused diffraction spot. The right-hand approximation, *d ≈ λN*, substitutes the standard small-angle relationship *NA ≈ 1/(2N)* between numerical aperture and the everyday photographic f-number *N* (§7) — showing that f-number alone, not just raw aperture diameter, sets the diffraction-limited resolution floor.

**The resolution/depth-of-field trade-off.** §8.3 showed that a *small* f-number (wide aperture) buys more light at the cost of shallow depth of field. §9's formula shows the opposite pressure: a *large* f-number (narrow aperture, more depth of field) makes the diffraction-limited spot size *d* bigger — i.e., a fundamentally blurrier best-case image, no matter how well-corrected the lens's aberrations (§5) are. High-end microscope objectives, for comparison, push NA up to 1.4–1.6 (giving *d* = λ/2.8, an extremely tight spot) specifically by sacrificing depth of field almost entirely. This unavoidable trade — better 2D resolution always costs some 3D (depth) information, and vice versa — is an instance of a **space-bandwidth product** (or "uncertainty principle") constraint: no optical system can have arbitrarily good resolution *and* arbitrarily good depth of field at once, only a trade between them, governed jointly by f-number.

---

## 10. Sensors: What's a Pixel?

A camera sensor's fundamental building block is the **photodiode**: a semiconductor structure that converts an incoming photon into an electron via the **[photoelectric effect](https://en.wikipedia.org/wiki/Photoelectric_effect)** — a photon striking the material knocks loose an electron, and counting those freed electrons (as an accumulated charge) over the exposure time is what "measuring light" means at the hardware level.

A real pixel is more than a bare photodiode:
- A **microlens** sits on top of each pixel, focusing light that would otherwise land on the pixel's non-light-sensitive circuitry back down onto the active photodiode area.
- A **color filter** (Week 1 §4's Bayer/RGGB mosaic) sits beneath the microlens, restricting each pixel to measuring only one color channel.
- **[Quantum efficiency](https://en.wikipedia.org/wiki/Quantum_efficiency)** is the fraction of incoming photons that actually get converted into a counted electron (roughly ~50% for a typical sensor) — not every photon that arrives produces a usable signal.
- **Fill factor** is the fraction of the pixel's total physical area that is actually light-sensitive (vs. taken up by wiring and per-pixel circuitry); the microlens exists specifically to compensate for a fill factor below 100% by funneling light from the "dead" area back onto the live area.

---

## 11. CCD vs. CMOS

There are two dominant sensor architectures, differing in *how* accumulated pixel charges get converted to a readable signal and read out:

| | **[CCD](https://en.wikipedia.org/wiki/Charge-coupled_device)** (charge-coupled device) | **[CMOS](https://en.wikipedia.org/wiki/CMOS_sensor)** (complementary metal-oxide-semiconductor) |
|---|---|---|
| Charge-to-voltage conversion | A small number of shared amplifiers, with each row's charge physically shifted ("bucket-brigaded") row-by-row to reach them | Every pixel has its **own** tiny amplifier built in |
| Readout | Charges shifted out row-by-row, then converted centrally | Per-pixel voltages read out row-by-row via a multiplexer, no charge-shifting needed |
| Typical trade-off | Higher sensitivity, lower noise (fewer, more carefully-matched amplifiers) | Faster readout, lower manufacturing cost (parallel per-pixel amplification, standard chip-fabrication processes) |

Both approaches ultimately deliver a per-pixel voltage proportional to accumulated charge; they differ in the electrical path and cost/performance trade-offs for getting there, not in the underlying photoelectric sensing principle of §10.

---

## 12. Exposure and ISO

**[Exposure](https://en.wikipedia.org/wiki/Exposure_(photography))** (shutter speed) is simply how *long* the sensor is allowed to accumulate photo-generated charge before readout — typical values range from small fractions of a second (1/250 s, freezing motion) to many seconds or a manually-held "bulb" exposure (as long as the shutter button stays pressed) for very dim scenes, directly recalling HW1's own 15–60 s pinhole-box exposures. Exposure, together with aperture (§7) and ISO (below), jointly determines total light collected.

**[ISO](https://en.wikipedia.org/wiki/Film_speed)** ("film speed," a name carried over from chemical film) is an **analog gain** applied to the sensor's signal *before* it reaches the analog-to-digital converter (ADC, §13). Raising ISO does not make the sensor collect more photons — it electrically amplifies whatever charge was collected, boosting a dim signal up into a usable digital range. Critically, this amplification boosts noise right along with signal (indeed, it amplifies certain noise sources, like read noise, disproportionately relative to the fundamental photon-counting noise of §14) — so raising ISO is a way of trading *cleanliness* for *brightness* on a fixed amount of collected light, not a way of gathering more light in the first place.

---

## 13. Dynamic Range and Bit Depth

**[Dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)** was introduced in Week 1 §10 for the human eye (~14 orders of magnitude adapted, ~5 instantaneous). For a digital sensor, the same *ratio-between-brightest-and-darkest-representable-signal* definition applies, but a sensor adds a second, purely digital constraint on top of the physical one: **bit depth** — how many discrete numeric levels the ADC (§14) can output. A typical camera's unprocessed **RAW** format uses 12–14 bits per pixel (4,096–16,384 distinct levels), while a processed, display-ready **JPEG** typically compresses this down to 8 bits per channel (256 levels) after the tone-mapping and gamma-correction steps previewed in §16 — so a sensor's *achievable* dynamic range is capped by whichever is smaller: the physical noise floor (§14) or the digital quantization step size set by bit depth.

---

## 14. Global Shutter vs. Rolling Shutter

There are two ways to time when each pixel's exposure happens relative to readout:

- **Global shutter**: every pixel on the sensor is exposed over the *exact same* time window, then all are read out together. This avoids motion artifacts within a single frame, at the cost of extra per-pixel circuitry (to hold each pixel's charge steady while waiting its turn to be read out).
- **[Rolling shutter](https://en.wikipedia.org/wiki/Rolling_shutter)**: rows are exposed and read out sequentially, one after another, rather than all at once — cheaper and allows shorter per-row exposure times, but different rows of the same "frame" are actually capturing the scene at *slightly different moments in time*, which can produce visible skew or banding artifacts for anything changing quickly during the row-by-row scan.

**Concrete example: 60 Hz AC flicker.** Ordinary AC-powered lighting in much of the world runs at 60 Hz, but the light output itself flickers at **120 Hz** — twice per electrical cycle, since the lamp dims (though doesn't fully switch off) each time the AC voltage crosses zero, which happens twice per cycle. A rolling-shutter camera scans through its rows over some short time window; since different rows land at different phases of that 120 Hz brightness flicker, the captured frame shows visible dark/light horizontal bands, even though nothing in the actual scene was banded. A global-shutter camera, exposing every row simultaneously, would instead show the whole frame uniformly brighter or dimmer depending on when within the flicker cycle the single shared exposure happened to land — no banding, because there's no row-to-row time offset to reveal the flicker's phase.

Rather than treating this purely as a nuisance, Sheinin et al. (2017) demonstrated that a rolling shutter's row-by-row timing can itself be exploited as a sensing tool: because each row effectively samples the scene at a slightly different, precisely known instant, a single rolling-shutter frame can be unpacked into a short sequence of instants (the lecture's example: 26 sub-frames recovered from just 10 ms of a single capture) — turning what looks like a shutter *artifact* into extra temporal information, a recurring theme in computational imaging of finding information hidden in an otherwise "broken" capture.

---

## 15. Sensor Noise and Signal-to-Noise Ratio

### 15.1 From photons to a RAW image

The full chain from incoming light to a stored RAW image: **photons** arrive at the sensor → the **photodiode** (§10) converts them to electrons, with photon-counting randomness (**shot noise**, below) already baked in at this step → an **amplifier** applies ISO gain (§12), adding further noise → an **ADC** quantizes the amplified analog voltage into discrete digital levels (§13), adding **quantization noise** (the unavoidable rounding error from representing a continuous voltage with a finite number of discrete levels) → the result is the **RAW image**, which also carries **fixed pattern noise** — per-pixel manufacturing-defect variation that is consistent from shot to shot (unlike the random noise sources above), caused by slight fabrication differences between individual pixels.

### 15.2 The two dominant noise distributions

Sensor noise comes from many physical sources (heat, electronics, amplifier gain, the photon-to-electron conversion itself, individual pixel defects, read-out electronics), but two statistical distributions dominate:

**[Gaussian noise](https://en.wikipedia.org/wiki/Gaussian_noise)** — from thermal effects, read-out electronics, and amplifier gain. It is **additive** and **signal-independent**: it adds a random value from the same bell-curve distribution to every pixel, regardless of how bright that pixel's true signal is. A dark pixel and a bright pixel get equally-sized random perturbations on average.

**[Photon (shot) noise](https://en.wikipedia.org/wiki/Shot_noise)** — from the fundamentally random arrival timing of individual photons. Photon arrivals follow a **[Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution)**, `f(k; λ) = λᵏe⁻λ/k!`, which describes the probability of observing exactly *k* discrete, randomly-timed events (here, photon arrivals) given an average rate λ. A defining property of the Poisson distribution is that its **standard deviation equals the square root of its mean**: for an average of *N* photons collected, the standard deviation of the actual count is `√N`. Shot noise is therefore **signal-dependent** — a brighter pixel (larger *N*) has *more* absolute noise (`√N` grows with *N*), but proportionally *less* relative noise, since the ratio `√N / N = 1/√N` shrinks as *N* grows. This is why doubling the light collected (*N* → 2*N*) doesn't double the noise — it only multiplies it by `√2`, meaningfully improving the *ratio* of signal to noise even though both the signal and its absolute noise both increased.

### 15.3 Signal-to-noise ratio (SNR)

**[Signal-to-noise ratio](https://en.wikipedia.org/wiki/Signal-to-noise_ratio)**, SNR, is the mean pixel value divided by the standard deviation of that pixel value (a general statistics definition, here applied to sensor measurements):

```
SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²)
```

where *P* is the incident photon flux (photons per pixel per second), *Qe* is quantum efficiency (§10), *t* is exposure time (§12), *D* is dark current (unwanted electrons generated per pixel per second even with no incident light — one source of §15.2's Gaussian noise family), and *Nr* is read noise (root-mean-square electrons of noise added purely by the sensor's own readout electronics, including fixed pattern noise). The numerator, *P·Qe·t*, is exactly the mean number of photo-generated electrons collected — the *signal* — while inside the square root, that same term reappears as the *shot-noise variance* (§15.2's `√N` fact, squared back into a variance) alongside the two Gaussian-family noise-variance terms *D·t* and *Nr²*.

**Scientific sensors** (e.g., cooled to around −100°C for astronomical or microscopy work) minimize *D* and *Nr* by aggressive cooling and specialized low-noise electronics, driving nearly all remaining noise down to the fundamental, physically unavoidable shot-noise floor set by *P·Qe·t* itself — the one noise term in the formula above that no amount of engineering can remove, since it comes from the quantum randomness of photon arrival itself, not from any imperfection in the sensor.

---

## 16. Looking Ahead: The Image Processing Pipeline

This lecture's own closing slide names what comes next: **RAW images → demosaicking → denoising → deblurring → white balancing → gamma correction → compression** — the **image signal processing (ISP)** pipeline that turns the raw, single-channel-per-pixel, noisy sensor output described in §10–15 into the finished color photo a viewer actually sees. PS2's remaining tasks (linear, chrominance-smoothed, and Malvar–He–Cutler high-quality demosaicing; gamma correction; Gaussian, median, bilateral, and non-local-means denoising) live here, and are covered in Week 3's notes rather than this week's — Week 2 has been entirely about the optics (§1–9) and raw sensing (§10–15) stages that come *before* any of that pipeline runs.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check
If you can explain, in your own words, *why* a wider aperture (smaller f-number) simultaneously gathers more light, produces shallower depth of field, and moves you further from (not closer to) the diffraction limit — using only the words "circle of confusion," "f-number," and "numerical aperture" — you've understood the core trade-off of Week 2.
