# CSC2529 Computational Imaging — Midterm Review (Weeks 1–6, HW1–4)

> **Scope:** Weeks 1–6 lecture content and Homeworks 1–4. This is a condensed exam sheet: key concepts, key equations (every symbol defined), causal chains, a recap of what each homework asked and its answer, and 10 practice questions per week (calculation + conceptual, all doable without a calculator) with worked answers. For diagrams and first-principles explanations, use the running notes artifact (linked in the README) or the `weekN-study-notes.md` files.

**How to use it:** read a week's concepts → equations → chains, then do its 10 questions with the answers hidden. Practice calculations use *fresh numbers* modeled on the homework problem types; the HW tie-in boxes quote the homework's actual numbers. Where Khai's solution source contains an error, the tie-in flags it with **⚠ Correction**.

**No calculator assumed.** The professor has not confirmed whether calculators are allowed, so every practice calculation is built to be done by hand: numbers are chosen to cancel, angles use the small-angle approximation, and answers keep exact fractions (and π, √, e^(…), log symbols) until the last step, then give a rough decimal. If calculators turn out to be allowed, every answer still holds. The toolkit below collects the tricks; each equation also lists its by-hand form.

## No-calculator toolkit

**Habits**
- Keep fractions and symbols (π, √5, e^(−1)) until the very end. Cancel common factors before multiplying anything out.
- Write very big or very small numbers in scientific notation: c = 3×10⁸ m/s (speed of light), λ = 500 nm (a wavelength of light) = 5×10⁻⁷ m.
- Compare without dividing or rooting: to decide whether 326 < 1080/π, check whether 326·π (≈ 1024) < 1080. To compare two SNRs (signal-to-noise ratios: signal ÷ noise), compare their squares.
- Finish with an order-of-magnitude sanity check.

**Small-angle approximation.** Picture an angle θ opening from your eye. At distance d, it spans an arc of length d·θ (θ in **radians**). When θ is small, that arc, the straight chord across it and the tangent segment are almost the same length. So, for small θ in radians:
```
sin θ ≈ tan θ ≈ θ          ⇒   2·d·tan(α/2) ≈ d·α        (size ≈ distance × angle)
```
- How good it is: tan θ ≈ θ + θ³/3, so for small θ the relative error is about θ²/3: 0.01% at 1° and 1% at 10°. By 45° the error has grown to 27%.
- Safe for visual acuity (arcminutes; 1 arcmin = 1/60 of a degree), pixels per degree (1°), diffraction angles, and narrow fields of view (FOV = the angle of scene a camera takes in; narrow = telephoto, a long-focal-length lens).
- **Not** safe for wide FOV. The exact 2·arctan(1) is 90°, but the small-angle form would give 2 rad ≈ 115°. Use the special angles below instead.

**Angle conversions (keep them as fractions)**

| Angle | Degrees | Radians, exact | Rough decimal |
|---|---|---|---|
| 1 degree | 1 | π/180 | ≈ 0.0175 |
| 1 arcmin | 1/60 | π/10800 | ≈ 2.9×10⁻⁴ |
| 0.5 arcmin | 1/120 | π/21600 | ≈ 1.45×10⁻⁴ |
| 1 arcsec | 1/3600 | π/648000 | ≈ 4.8×10⁻⁶ |
| 1 radian | 180/π ≈ 57.3 | 1 | — |

Which of these a question needs is often unstated: anything "per degree" (cycles per degree = cpd, pixels per degree = px/deg) silently assumes 1°, while acuity assumes 1 arcmin. The Week 1 note "the hidden 1°" and its decision table explain which angle to use.

**π:** π ≈ 3.14, 1/π ≈ 0.318, π² ≈ 10. Check a division by multiplying back: 1080/π ≈ 344 because 344 × 3.14 ≈ 1080.

**Special angles (exact):** tan 30° = 1/√3 ≈ 0.577, tan 45° = 1, tan 60° = √3 ≈ 1.732. So FOV = 2·arctan(ratio) is exactly 60°, 90° or 120° when the ratio is 1/√3, 1 or √3. Also sin²(π/6) = 1/4, sin²(π/4) = 1/2, sin²(π/2) = 1.

**Powers of 2 and logs**
- 2¹⁰ = 1024 ≈ 10³. So log₂(1000) ≈ 10, log₂(10⁶) ≈ 20, and log₂(10) ≈ 10/3 ≈ 3.32.
- Know these: 2⁸ = 256, 2¹² = 4096, 2¹⁴ = 16 384, 2¹⁶ = 65 536, 2¹⁸ = 262 144.
- log₁₀ 2 ≈ 0.301 and log₁₀ 3 ≈ 0.477. So ×2 in power = +3 dB (decibels: 10·log₁₀ of a power ratio, or 20·log₁₀ of an amplitude ratio) (10·log₁₀ 2), ×2 in amplitude = +6 dB (20·log₁₀ 2), and log₁₀ 11 ≈ 1.04.
- ln 2 ≈ 0.693 and ln 10 ≈ 2.303.
- Fractional powers of 2: 2^(1/2) ≈ 1.41, 2^(1/3) ≈ 1.26, 2^(1/6) ≈ 1.12.

**Camera number sequences (memorize; each step = 1 stop = a ×2 change in light)**
- f-numbers (N = focal length ÷ aperture diameter, written "f/N"; bigger N = smaller opening; Week 2 E4) go up by ×√2: 1, 1.4, 2, 2.8, 4, 5.6, 8, 11, 16, 22. The printed values are rounded: f/2.8 means 2√2 (N² = 8), f/5.6 means 4√2 (N² = 32), f/11 means 8√2 (N² = 128).
- Shutter times (how long the sensor collects light per photo) halve: 1, 1/2, 1/4, 1/8, 1/15, 1/30, 1/60, 1/125, 1/250, 1/500, 1/1000 s. Again rounded: 1/125 means 1/128, 1/250 means 1/256.

**Exponentials (Gaussian = bell-curve weights, used in later weeks):** e^(−1/8) ≈ 0.88, e^(−1/4) ≈ 0.78, e^(−1/2) ≈ 0.61, e^(−1) ≈ 0.37, e^(−2) ≈ 0.14, e^(−3) ≈ 0.05, e^(−4) ≈ 0.018. For small x, e^(−x) ≈ 1 − x + x²/2. Multiply exponentials by adding exponents: e^(−a)·e^(−b) = e^(−(a+b)).

**Square roots:** √2 ≈ 1.414, √3 ≈ 1.732, √5 ≈ 2.236, √10 ≈ 3.162. Pull out perfect squares: √2000 = √(400·5) = 20√5 ≈ 44.7. Near a perfect square, √(n² + δ) ≈ n + δ/(2n), e.g. √1025 ≈ 32 + 1/64.

> **Summary**
> - Keep exact fractions and symbols; convert to a rough decimal only at the end.
> - Rule to remember: for small angles in radians, **sin θ ≈ tan θ ≈ θ**, and **1 arcmin = π/10800 rad**, **1° = π/180 rad**. Don't use it for wide fields of view.
> - Logs come from 2¹⁰ ≈ 10³ and log₁₀ 2 ≈ 0.3; f-numbers and shutter times are powers of √2 and 2 in disguise.
> - Every practice calculation below uses only these tricks.

## Homework → week map

| Homework | Task | What it tests | Week |
|---|---|---|---|
| HW1 | T1–T2 Pinhole camera | FOV, optimal pinhole diameter (geometric blur vs. diffraction) | 2 |
| HW1 | T3 Hybrid images | print size from dpi, pixels per degree, CSF peak → cycles/pixel → FFT cutoff radius | 1 |
| HW2 | T1 Depth of field | thin lens, f-number, circle of confusion, near/far limits, hyperfocal distance | 2 |
| HW2 | T2 Simple ISP | Bayer demosaicking (bilinear, Malvar–He–Cutler), gamma, YCbCr chroma filtering, PSNR | 3 |
| HW2 | T3 Denoising | Gaussian, median, bilateral, non-local means | 3 |
| HW3 | T1 HDR fusion | linearization, confidence weights, log-domain merge, tonemapping | 4 |
| HW3 | T2 Burst SNR | variance of averaged frames, read vs. shot noise, √K gain | 4 |
| HW3 | T3 Flutter vs. burst | read-noise-limited vs. photon-limited regimes | 4 |
| HW4 | T1 Spatial vs. Fourier filtering | convolution theorem, psf2otf, O(N·k²) vs. O(N log N) | 5 |
| HW4 | T2 Inverse vs. Wiener | ill-posed deconvolution, noise amplification, Wiener damping | 5 |
| HW4 | T3 GD vs. SGD | least squares gradient, step size, batch-size trade-off | 5 |

Week 6 has no midterm homework (HW5 is outside the midterm). The terms in this table and in the causal map below are defined in each week's section; on a first pass, skim the maps and come back to them after the weeks.

## Cross-week causal map

The six weeks form a few long chains. Knowing these makes most conceptual questions answerable.

1. **Perception sets the encoding (W1 → W3).** The eye is far more sensitive to relative (Weber) contrast and to mid image frequencies (CSF peak ≈ 4–6 cycles/degree; HW1 uses 5) than to fine chroma detail → gamma encoding spends code values where the eye notices, YCbCr chroma filtering and JPEG discard what it doesn't, and hybrid images exploit distance-dependent CSF cutoffs.
2. **Light → photons → noise → SNR (W2 → W4).** Exposure H ∝ L·t/N² (H = light per unit sensor area, L = scene brightness, t = exposure time, N = f-number; not Week 2's hyperfocal H) → photon count n → shot noise √n (Poisson) plus read noise σ per readout → SNR → decides whether to take one long exposure, a burst (pays read noise K times), or a flutter shutter (loses light, reads once).
3. **Dynamic range mismatch (W1 → W2 → W4).** World ≫ sensor (full well / read noise, bit depth) ≫ display → bracket exposures → linearize with the inverse response curve → weighted log-domain merge (HDR) → tonemap for the display.
4. **Optics blur is a low-pass filter (W2 → W4 → W5).** Finite aperture → diffraction (Airy disk diameter ≈ 2.44·λ·N; λ = wavelength of light, N = f-number) and defocus (circle of confusion) → PSF → its Fourier transform, the OTF (optical transfer function), attenuates high image frequencies → limits resolution and, together with pixel pitch (centre-to-centre pixel spacing), sets the Nyquist limit (the finest pattern a pixel grid can record: 0.5 cycles/pixel); sampling below Nyquist aliases.
5. **Blur is convolution, deblurring is division (W1 → W4 → W5 → W6).** Image ∗ PSF ⇔ spectrum × OTF → inverse filter divides by the OTF → noise explodes where |OTF| ≈ 0 → fixes: make the OTF broadband (coded aperture / flutter shutter, W4), damp the division (Wiener, W5), or add a prior and solve iteratively (TV + ADMM, W6).
6. **Everything is Ax = b (W3 → W5 → W6).** Blur, demosaicking, and single-pixel imaging are all linear measurements → least squares (normal equations / gradient descent) → under-determined or ill-conditioned → regularization = a Bayesian prior (MAP) → sparsity (ℓ1, TV) → solved by splitting (ADMM, soft thresholding, plug-and-play denoisers).
7. **Color is three samples of a spectrum (W1 → W3).** Three cone types / three camera filters reduce a spectrum to 3 numbers (metamers exist) → a Bayer CFA records only 1 of 3 per pixel → demosaicking interpolates → zipper and false-color artifacts at edges → gradient-corrected (MHC) or chroma-domain filtering reduces them.
8. **The LiDAR thread (W4 → W5 → W6).** Range from round-trip time d = c·τ/2 (d = distance to the target, c = speed of light, τ = round-trip time of the light pulse; W4) → a fixed pulse rate means echoes from beyond c/(2·f_rep) (f_rep = pulses sent per second; not a focal length) alias back as near targets — temporal aliasing (W5) → a single-pixel detector with coded illumination plus sparsity priors gives compressive LiDAR (W6).

---

## Week 1 — Human Visual System

> **Scope:** Eye anatomy, accommodation, refractive errors, rods/cones, color, eye vs. camera, visual angle/acuity, retina displays, FOV, depth cues, stereo displays and VAC, stops/EV, dynamic range, spatial frequency (cpd), contrast, CSF, Fourier transform/`fft2`, convolution, frequency-domain filtering, hybrid images, deconvolution first look. Tested by **HW1 Task 3 (hybrid images)**.

### Key concepts
**Eye optics**
- **Cornea** — fixed front lens, does most of the focusing. **Lens** — adjustable fine focus.
- **Pupil** — the eye's **aperture** (the opening that sets how much light enters). **Retina** — the eye's **image sensor**. Fovea = small cone-packed center patch (sharp, color vision). Optic disc = **blind spot** (no photoreceptors).
- **Accommodation** — ciliary muscle reshapes the lens to refocus. Range ~8 cm–∞ at ~16 yr, ~50 cm–∞ at ~50 yr (**presbyopia**).
- **Refractive errors** — myopia (focus in front of retina → concave lens, thinner in the middle, spreads light), hyperopia (behind → convex lens, thicker in the middle, converges light), astigmatism (no single focus → cylindrical lens, curved in one direction only). Same concept, different names: hyperopia = hypermetropia = farsightedness; myopia = nearsightedness.

**Retina and color**
- **Rods** ~120 M: very sensitive, colorless, periphery. **Cones** ~6 M: color (S, M, L = short-, medium-, long-wavelength types; peak sensitivity at ~440, ~545, ~565 nm wavelength), fovea, high acuity. Foveal cone spacing ≈ **0.5 arcmin**.
- **Metamerism** — different spectra (spectrum = how much light there is at each wavelength) with the same 3 cone responses look identical; why RGB works.
- **Bayer CFA (color filter array), RGGB pattern** — one color filter per pixel, in repeating 2×2 blocks of red, green, green, blue; the other 2 channels are interpolated (**demosaicking**, Week 3). Retina differs: irregular mosaic, non-uniform density.

**Angles and displays**
- **Visual angle** — angular size at the eye (1° = 60 arcmin, 1 arcmin = 60 arcsec). **20/20 acuity ≈ 1 arcmin.** (20/20 = normal eye-chart vision; acuity = the smallest angle the eye can resolve.)

> **Note (the hidden 1°):** any quantity written **"per degree"** (cycles per degree = cpd, pixels per degree = px/deg) quietly fixes the visual angle at **exactly 1°**. Nobody measures that 1°; it is the unit. You are counting how many cycles (or pixels) fit inside a 1° slice of your view.
> - **When to assume 1°:** whenever cpd or px/deg appears. That covers the CSF's x-axis, the CSF peak (4–6 cpd), the 60 cpd cutoff, HW1's 5 cpd target, and every hybrid-image cutoff.
> - **Convert it before using it:** 1° = **π/180 rad**. At viewing distance D, the slice covers a width of 1° = 2·D·tan(0.5°) ≈ **D·π/180**.
> - **Where the 0.5° comes from:** it is half of that same 1°. The 1° wedge is split into two right triangles, each with angle 0.5° = **π/360 rad**, so 2·D·(π/360) = D·π/180.
> - **Don't mix it up with 1 arcmin:** acuity and "retina display" (a screen whose pixels each span ≤ 1 arcmin at the intended distance, so none can be seen individually) questions use α = 1 arcmin = 1/60° = **π/10800 rad**, an angle 60× smaller.

**Which angle to assume (Week 1 decision table)**

| You see… | Angle to assume | In radians | Width it covers at distance D |
|---|---|---|---|
| cpd, px/deg, CSF peak or cutoff, hybrid-image cutoff | 1° (the "per degree") | π/180 | D·π/180 |
| the half-angle inside 2·D·tan(…) for that 1° | 0.5° | π/360 | D·π/360 (each half) |
| 20/20 acuity, smallest resolvable pixel, "retina" dpi | 1 arcmin | π/10800 | D·π/10800 |
| foveal cone spacing | 0.5 arcmin | π/21600 | D·π/21600 |
- **dpi** (dots per inch) — pixels per inch = 1/p, with p = one pixel's size in inches. Same concept, different names: dpi = ppi (pixel density).
- **FOV** (field of view: the angle of scene seen at once) — ~190° monocular, ~120° binocular, ~135° vertical.

**Depth and displays**
- **Depth cues** — monocular: perspective, relative/absolute size, occlusion, accommodation, retinal blur, motion parallax, texture gradient, shading. Binocular: **vergence** (both eyes rotating to point at the same object), **disparity** (the difference between the left and right eyes' images). Same concept, different names: disparity = binocular parallax.
- **VAC** (vergence-accommodation conflict) — stereo display: eyes verge to the simulated depth but accommodate to the physical screen. Causes discomfort; light-field/holographic displays are the fix (Week 9).

**Brightness ratios**
- **Stop** — a factor of 2 in light. Same concept, different names: "+1 stop" = "+1 EV" (EV = exposure value; "exposure compensation" = telling the camera to make the photo brighter or darker by that many stops). Shutter time = exposure time = shutter speed (how long the sensor collects light).
- **Dynamic range** — brightest ÷ darkest representable signal. Eye ~14 orders of magnitude (a factor of 10¹⁴ ≈ 46.5 stops) over all adaptation; ~6.5 stops instantaneous (slide; ~5 orders is a separate, looser figure); displays ~3 orders (≈ 10 stops).

**Frequency** (always say which one)
- **Spatial frequency** — cycles of light/dark per distance (cycles/inch) or per degree (**cpd** = cycles inside **1°** of visual angle, 1° = π/180 rad; viewer-dependent; rises as you step back). **Image frequency** — cycles per pixel, fixed by the file (the `fft2` axis). Not light frequency (color) and not temporal frequency (flicker, ~60 Hz limit).
- **Contrast** — Weber (one feature on a background) vs. Michelson (periodic gratings).
- **CSF** (contrast sensitivity function) — contrast sensitivity (1 / minimum detectable contrast) vs. cpd. **Band-pass** (most sensitive to middle frequencies, less to low and high ones), peak ~4–6 cpd, cutoff ~60 cpd. The cutoff means 60 cycles squeezed into 1° = 60 arcmin, so 1 arcmin per cycle, which matches the cone spacing: 2 × 0.5 arcmin = 1 arcmin per cycle.
- **Fourier transform** — image as a sum of 2D gratings; `fft2` (2D FFT = fast Fourier transform, the standard algorithm that computes it) output entry = one grating's magnitude + phase. `fftshift` moves DC (zero frequency, the mean) to the center; `ifftshift` before `ifft2`. One FFT per color channel.
- **Convolution** — slide/stamp a kernel and sum. Same concept, different names: kernel = filter = impulse response = PSF (point spread function: the blur pattern a single point of light makes; optics). LSI (linear shift-invariant: same blur everywhere, effects add) system = convolution with its impulse response.
- **Low-pass / high-pass** — keep a disc around the shifted spectrum's center / keep everything outside it. Masking spectra = convolving in space.
- **Hybrid image** — high-pass of A + low-pass of B: A seen up close, B from afar.
- **Deconvolution** — inverse of convolution; **ill-posed** (zeros destroy info, near-zeros amplify noise) → regularization (Wiener, Week 5; priors, Week 6). Non-blind = kernel known; blind = kernel unknown.

### Key equations
#### E1. Resolvable pixel size and dpi
```
p = 2 · d · tan(α / 2)
dpi = 1 inch / p
by hand (small angle, α in rad):   p ≈ d · α,   α = 1 arcmin = π/10800   ⇒   dpi ≈ 10800 / (π · d)   (d in inches)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| p | size of the smallest resolvable feature (pixel) | inches (any length) | computed |
| d | viewing distance (written D in E4 and the 1° note; unrelated to Week 2's d) | same length unit as p | set by use case |
| α | minimum resolvable visual angle (≈ 1 arcmin) | degrees/arcmin | fixed by acuity |
| dpi | pixel density | pixels/inch | computed |

*Use it when:* "how dense must a screen be to look smooth at distance d?" *Gotcha:* α must be in **radians** for the small-angle form: 1 arcmin = 1/60° = π/10800 rad. At 1 arcmin the small-angle error is far below 0.01%, so p ≈ d·α is effectively exact.

#### E2. Stops ↔ ratio
```
stops = log₂(ratio)          ratio = 2^stops
by hand:  2¹⁰ ≈ 10³  ⇒  stops ≈ (10/3) × (orders of magnitude)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| ratio | light (or brightness) multiplier between two cases | dimensionless | scene / settings |
| stops | same comparison counted in doublings (± = more/less light) | stops (EV) | dialed in |
| 2 | base: one stop = ×2 by definition | — | fixed |

*Use it when:* exposure compensation, dynamic range, aperture/shutter trade-offs. *Gotcha:* 1 order of magnitude = log₂10 ≈ 3.32 stops; one aperture stop = f-number × √2 (f-number N = focal length ÷ opening diameter; Week 2) (area ∝ diameter²).

#### E3. Image frequency → physical spatial frequency
```
physical spatial frequency (cycles/inch) = image frequency (cycles/pixel) × dpi (pixels/inch)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| physical spatial frequency | cycles per printed length | cycles/inch | computed |
| image frequency | cycles per pixel in the file | cycles/pixel | fixed by the image |
| dpi | print/display density | pixels/inch | chosen when printing |

*Use it when:* moving between `fft2` units and the CSF's cpd. *Gotcha:* the final step to cpd needs viewing distance (E4), plus the hidden 1°: cpd = cycles/inch × (inches spanned by 1° at distance D) = cycles/inch × D·π/180.

#### E4. Pixels per degree and cpd → cycles/pixel (HW1 Task 3 chain)
```
width of 1° = 2 · D · tan(0.5°)            ← assume 1°: it is the "per degree" in px/deg and cpd; 0.5° is half of it
px/deg = (width of 1°) / pixel pitch,     pixel pitch = 2.54 cm / dpi (2.54 cm = 1 inch)
image frequency (cycles/px) = cpd / (px/deg)
by hand (small angle):  0.5° = π/360 rad  ⇒  width of 1° ≈ 2·D·π/360 = D · π/180   ⇒   px/deg ≈ π · D · dpi / (180 · 2.54)   (D in cm)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| D | viewing distance | cm | chosen |
| width of 1° | length on the print spanned by 1° (= π/180 rad) of visual angle. The 1° is fixed by the unit "per degree", not chosen | cm | computed |
| 0.5° | half of the 1° wedge, the angle in each right triangle (= π/360 rad) | degrees (rad) | fixed |
| pixel pitch | printed size of one pixel | cm/pixel | set by dpi |
| dpi | print density | pixels/inch | chosen |
| px/deg | pixels inside 1° of visual angle | pixels/degree | computed |
| cpd | target spatial frequency (e.g. CSF peak) | cycles/degree | chosen from CSF |
| image frequency | the same frequency on the pixel grid | cycles/pixel | computed |

*Use it when:* picking a hybrid-image cutoff. *Gotcha:* the 1° is never stated in a question; it is implied by "cpd" or "px/deg". Plug in 1° = π/180 rad (or 0.5° = π/360 rad inside the tan), not 1 arcmin. Farther D → more px/deg → lower cycles/px for the same cpd. By hand, keep π in the answer (e.g. px/deg = 20π) and divide it out only at the end. A dpi of 254 makes the pitch exactly 0.01 cm, because 2.54/254 = 0.01.

#### E5. Contrast
```
C_weber     = (I_feature − I_background) / I_background
C_michelson = (I_max − I_min) / (I_max + I_min)
contrast sensitivity = 1 / (minimum detectable contrast)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| C_weber | contrast of one feature on a uniform background | dimensionless | computed |
| I_feature | feature luminance | luminance (any consistent unit) | measured |
| I_background | background luminance | same | measured |
| C_michelson | contrast of a periodic pattern (0–1) | dimensionless | computed |
| I_max, I_min | brightest / darkest luminance of the pattern | same | measured |
| minimum detectable contrast | faintest contrast still seen at a given cpd | dimensionless | measured (observer) |
| contrast sensitivity | CSF's y-axis | dimensionless | computed |

*Use it when:* gratings/CSF → Michelson; single spot → Weber.

#### E6. 2D grating and DFT (discrete Fourier transform, what fft2 computes) index → cycles/pixel
```
I(x, y) = A · cos(2π(u·x + v·y) + φ)
u = k_u / W      v = k_v / H
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| I(x, y) | grating brightness at pixel (x, y) | brightness | output |
| A | amplitude (contrast) | brightness | grating property |
| x, y | pixel coordinates | pixels | independent variables |
| u, v | horizontal / vertical image frequency | cycles/pixel | grating property / computed |
| φ | phase (stripe shift) | radians | grating property |
| k_u, k_v | integer `fft2` array indices = cycles across the whole width/height | cycles per image | read off array |
| W, H | image width / height | pixels | fixed by image |

*Use it when:* turning a cutoff in cycles/px into an FFT mask radius: radius (bins = FFT array cells) = cutoff image frequency (cycles/px) × image side (px). Neither factor here is a focal length or an f-number. *Gotcha:* stripes are perpendicular to (u, v); combined frequency = √(u² + v²).

#### E7. Convolution and the convolution theorem
```
(x * h)[n] = Σ_m h[m] · x[n − m]
DFT{ x * h } = DFT{ x } · DFT{ h }
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x[·] | input signal (e.g. pixel brightness) | signal units | fixed by scene |
| h[m] | kernel weight at offset m | unitless | you design / optics impose |
| n | output position | samples/pixels | loop index |
| m | kernel offset | samples/pixels | summation variable |
| (x * h)[n] | filtered output at n | signal units | computed |
| * | convolution (kernel reversed) | — | — |
| DFT{·} | spectrum; DFT{h} = frequency response (1 = pass, 0 = erase) | per frequency | computed |
| · | entry-by-entry product per frequency | — | — |

*Use it when:* blur, filtering, PSFs, deconvolution. *Gotcha:* theorem is exact for circular convolution (the signal wraps around at its edges); zero-pad (append zeros) to ≥ N + K − 1 for ordinary linear convolution, where N = signal length and K = kernel length; full output length = N + K − 1. Cost: direct N·K vs. FFT ~N log N.

#### E8. Hybrid image in the frequency domain
```
F_hybrid(u, v) = H_A(u, v) + L_B(u, v)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| F_hybrid(u, v) | hybrid's spectrum at image frequency (u, v) | complex amplitude | computed |
| H_A(u, v) | image A's spectrum × high-pass mask | complex amplitude | you choose cutoff |
| L_B(u, v) | image B's spectrum × low-pass mask | complex amplitude | you choose cutoff |
| u, v | image frequency | cycles/pixel | axes |

*Use it when:* building the hybrid per channel, then `ifftshift` → `ifft2` → real part → clip. *Gotcha:* add spectra (or filtered images), not a pixel cross-fade of the originals.

### Causal chains
1. Step back from a print → each cycle subtends a smaller angle → more cycles fit in the fixed 1° slice (width D·π/180 grows with D) → more cycles per degree (cpd ↑) → fine detail passes the ~60 cpd cutoff. *So:* distance, not the print, decides what is visible.
2. Cone spacing 0.5 arcmin → ≥ 2 samples per cycle → smallest cycle ≈ 1 arcmin → 1° = 60 arcmin holds 60 such cycles → 60 cpd cutoff = 20/20 acuity. *So:* acuity, CSF cutoff and sampling are one fact.
3. Acuity 1 arcmin at d = 12 in → p ≈ 12 · π/10800 = π/900 in ≈ 0.0035 in → dpi = 900/π ≈ 286 → 300 dpi "retina" claim holds. *So:* "retina" only means retina at a stated distance.
4. Stereo display → vergence at simulated depth, accommodation at the screen → conflicting cues → VAC discomfort. *So:* displays that give correct focus per pixel (light field/holographic) are needed.
5. Eye ~46.5 stops vs. display ~10 stops → scenes cannot be shown as-is → HDR capture + tonemapping (Week 4). *So:* dynamic range gaps drive HDR.
6. Mask on shifted spectrum = multiplying by DFT{h} → convolution theorem → same as blurring (LPF, low-pass filter) or original − blur (HPF, high-pass filter). *So:* frequency masking gives an exact cutoff radius for the same operation.
7. Blur multiplies each frequency by DFT{h} → undo by dividing → zeros lose info, small values amplify noise (×1/|H|). *So:* deconvolution is ill-posed and needs regularization.

### HW tie-in
**HW1 Task 3 — Hybrid images.** Given 1001×1001 px images printed at 300 dpi, viewed at 40 cm and 2 m, CSF peak 5 cpd.
- 3.1 Print size: 1001/300 = 3.34 in = 8.48 cm. Pitch 2.54/300 = 0.00847 cm. Width of 1° (the implied "per degree" slice) = 2·D·tan(0.5°) → **82 px/deg** (82.46) at 40 cm, **412 px/deg** (412.29) at 2 m.
- 3.2 Image frequency = cpd / (px/deg): 5/82 = **0.0610 cycles/px** (40 cm), 5/412 = **0.0121 cycles/px** (2 m); cutoff = arithmetic mean = **0.0366 cycles/px**.
- 3.3 FFT radius = cutoff (cycles/px) × image side (px) = 0.036556 × 1001 = **36.59 px** (FFT bins = cycles per image width). Ideal circular LPF r ≤ 36.59 on the airplane, HPF r ≥ 36.59 on the macaw; per channel; `fftshift`/`ifftshift`; real part; sum; clip to [0, 255].
- Result: at 40 cm the macaw (high frequencies) dominates; at 2 m its detail is beyond the CSF, only the blurry airplane remains.
- Takeaway: one cpd target maps to different cycles/px at each distance; the cutoff is set between them.

> **Note (rounding):** the solution rounds px/deg to 82 and 412 before dividing. With unrounded 82.46 and 412.29, the cycles/px are 0.0606 and 0.0121, mean 0.0364, radius ≈ 36.4 px (vs. 36.59). Either is fine in practice; just be consistent.

> **Note (by hand):** the small-angle form px/deg = π·D·dpi/(180·2.54) gives the same 82.46 and 412.29: tan(0.5°) and 0.5° in radians differ by about 0.003%. In fraction form, 40 cm and 300 dpi give px/deg = 12000π/457.2.

### Practice questions
**Q1. [Calc]** A phone is held 10 inches from the eye. Assuming 20/20 acuity (α = 1 arcmin), what pixel size and dpi make it a "retina" display? Does a 326 dpi phone qualify at this distance?
<details><summary>Answer</summary>

Small angle: α = 1 arcmin = π/10800 rad, so p ≈ d·α = 10 · π/10800 = **π/1080 in** (≈ 0.0029 in). dpi = 1/p = **1080/π ≈ 344 dpi** (check: 344 × 3.14 ≈ 1080).  
Does 326 dpi qualify? Compare without dividing: 326·π ≈ 326 × 3.14 ≈ 1024 < 1080, so 326 < 1080/π. The phone's pixels are slightly too big, so it is **not** quite retina at 10 in. At 12 in the threshold is 10800/(π·12) = 900/π ≈ 286 dpi, which 326 beats.

</details>

**Q2. [Calc]** (a) A display has a 1000:1 contrast ratio. How many stops is that? (b) You take one shot at +2 EV exposure compensation and another at −3 EV. What is the light ratio between them? (c) The camera's light meter (built-in sensor that suggests settings) suggests f/8 at 1/250 s; you open to f/4. What shutter time keeps the same exposure?
<details><summary>Answer</summary>

(a) 2¹⁰ = 1024 ≈ 1000, so log₂(1000) ≈ **10 stops** (just under; 3 orders × 10/3).  
(b) Difference = 2 − (−3) = 5 stops → 2⁵ = **32×** more light in the +2 shot.  
(c) f/8 → f/4: N halves, so the opening's diameter D = f/N doubles and its area (∝ D²) ×4 → 2·log₂(8/4) = 2 stops more light. Pay back with 2 stops less time: 1/250 → 1/500 → **1/1000 s**.

</details>

**Q3. [Calc]** A sinusoidal grating varies between luminance 180 and 20. (a) Michelson contrast? (b) An observer at 5 cpd can just detect a grating of contrast 0.005. What is their contrast sensitivity there? (c) Weber contrast of a 120 spot on a 100 background?
<details><summary>Answer</summary>

(a) (180 − 20)/(180 + 20) = 160/200 = **0.8**.  
(b) 1/0.005 = **200**.  
(c) (120 − 100)/100 = **0.2**.

</details>

**Q4. [Calc]** HW1-style: two 1000×1000 px images printed at 254 dpi, viewed at 36 cm and 1.8 m; target the CSF peak at 4 cpd. Find (a) the pixel pitch and print size, (b) px/deg at each distance (small-angle approximation), (c) cycles/px at each distance and their mean, (d) the FFT mask radius.
<details><summary>Answer</summary>

(a) Pitch = 2.54 cm/254 = **0.01 cm**. Print size = 1000 × 0.01 = **10 cm** (= 1000/254 ≈ 3.94 in).  
(b) "px/deg" means pixels inside 1° of visual angle, so assume 1° = π/180 rad. Width of 1° = 2·D·tan(0.5°) ≈ 2·D·(π/360) = D·π/180. At 36 cm: 36π/180 = π/5 cm, so px/deg = (π/5)/0.01 = **20π ≈ 63 px/deg**. At 180 cm: 180π/180 = π cm, so px/deg = π/0.01 = **100π ≈ 314 px/deg**.  
(c) cycles/px = cpd/(px/deg). At 36 cm: 4/(20π) = **1/(5π) ≈ 0.064**. At 1.8 m: 4/(100π) = **1/(25π) ≈ 0.013**. Mean = ½(5/(25π) + 1/(25π)) = 6/(50π) = **3/(25π) ≈ 0.038 cycles/px**.  
(d) Radius = cycles/px × image side (N = 1000 px) = 1000 · 3/(25π) = **120/π ≈ 38 px** (120/3.14 ≈ 38.2). Use LPF r ≤ 38 on the image meant to be seen from far away and HPF r ≥ 38 on the image meant to be seen up close.

</details>

**Q5. [Calc]** A 512-px-wide image's `fft2` has a strong peak at k_u = 16. (a) Image frequency? Period in pixels? (b) Printed at 160 dpi, physical frequency? (c) Viewed from 36 inches, cpd (small-angle approximation)? Where on the CSF?
<details><summary>Answer</summary>

(a) u = 16/512 = **1/32 cycles/px**, period **32 px**.  
(b) (1/32) × 160 = **5 cycles/inch**.  
(c) "cpd" means cycles inside 1° of visual angle, so assume 1° = π/180 rad. Width of 1° at 36 in ≈ 36 · π/180 = π/5 in. cpd = 5 cycles/in × π/5 in/degree = **π ≈ 3.1 cpd**. That is just below the 4–6 cpd peak, on the rising low-frequency side. It is clearly visible and becomes more visible (toward the peak) as you step back.

</details>

**Q6. [Concept]** Why does a hybrid image show A up close and B from far away? Use cpd and the CSF.
<details><summary>Answer</summary>

A contributes only high spatial frequencies (small features). Up close those features span large angles → modest cpd → near the CSF's sensitive range → visible. Far away the same features span tiny angles → cpd rises past the ~60 cpd cutoff (and loses sensitivity well before) → invisible. B's low frequencies stay at low, visible cpd at every realistic distance, so they are what remains far away.

</details>

**Q7. [Concept]** A student says "image frequency of 0.06 cycles/px is high, so it's invisible from far away." What is wrong?
<details><summary>Answer</summary>

Cycles/px is a property of the file only. Visibility depends on cpd, which needs dpi (print size) and viewing distance: cpd = cycles/px × px/deg, where px/deg counts the pixels inside the implied 1° (= π/180 rad) slice at that distance. The same 0.06 cycles/px is ~5 cpd at 40 cm/300 dpi (0.06 × 82 px/deg; peak, very visible) and ~25 cpd at 2 m (0.06 × 412 px/deg). Never compare cycles/px to the CSF directly.

</details>

**Q8. [Concept]** Explain the vergence-accommodation conflict and why it does not occur in natural viewing.
<details><summary>Answer</summary>

Naturally, the eyes rotate (verge) and the lens focuses (accommodates) at the same object distance. A stereo display shows offset images that make the eyes verge to a simulated depth, while the sharp image is always at the physical screen, so the lens accommodates there. The two cues disagree → fatigue/nausea. Fix: displays that reproduce correct focus depth (light field, holographic).

</details>

**Q9. [Concept]** In the hybrid-image code, why must you (a) call `ifftshift` before `ifft2`, (b) process each color channel separately, and (c) take the real part?
<details><summary>Answer</summary>

(a) `ifft2` expects DC in the corner (the raw layout); masks are drawn on the centered (`fftshift`ed) spectrum, so you must undo the shift first.  
(b) `fft2` takes one 2D array; color = three independent arrays, so three spectra with no interaction.  
(c) A real image's spectrum is conjugate-symmetric (the value at frequency −(u, v) has the same magnitude and opposite phase as the value at +(u, v)); after symmetric masking the inverse is real up to tiny numerical imaginary parts, which are discarded.

</details>

**Q10. [Concept]** A blur kernel's spectrum has a smallest value of 0.2 at the highest image frequency (finest stripes) and no exact zeros. What happens to noise at that frequency under the inverse filter? What if the minimum were 0?
<details><summary>Answer</summary>

Inverse filter divides by DFT{h}, so noise at that frequency is multiplied by 1/0.2 = **5×**. With an exact zero, the blurred spectrum there is 0 for any original → information destroyed, division undefined; many originals give the same image. Both make deconvolution ill-posed → regularize (Wiener damps where |H| (the magnitude of DFT{h}) is small).

</details>

> **Summary**
> - The eye is an optical instrument (pupil = aperture, retina = sensor) whose limits are angles (1 arcmin acuity, 60 cpd cutoff) and ratios (stops, dynamic range).
> - Rules to remember: **p = 2·d·tan(α/2) ≈ d·α** (α in rad, 1 arcmin = π/10800), **stops = log₂(ratio)**, and the chain **cycles/px = cpd / (px/deg)** with radius = cycles/px × N.
> - CSF is band-pass (peak 4–6 cpd); cpd depends on distance, which is why hybrid images work.
> - Hidden assumption: "per degree" (cpd, px/deg) always means a 1° slice = π/180 rad, covering width D·π/180 at distance D. Acuity uses 1 arcmin = π/10800 rad instead.
> - Fourier transform + convolution theorem: masking spectra = convolving; deconvolution reverses it but is ill-posed.
> - Sets up Week 2 (lens/aperture optics, pinhole FOV) and Week 5 (sampling, Wiener deconvolution).

---

## Week 2 — Digital Photography I (ray optics, aperture, sensor)

> **Scope:** pinhole camera and optimal pinhole size, thin lens / magnification, FOV, aperture and f-number/stops, circle of confusion, depth of field, hyperfocal distance, diffraction limit, bokeh, pixels, CCD vs CMOS, global vs rolling shutter, noise sources, SNR, dynamic range and bit depth (tested by HW1 Tasks 1–2 and HW2 Task 1).

### Key concepts
**Optics**
- **Pinhole camera** — one small hole lets roughly one ray per scene point through, giving an inverted, scaled image. (Same concept, different names: pinhole camera = camera obscura.)
- **Pinhole size trade-off** — a bigger hole gives more geometric blur (blur ≈ d, the hole's diameter); a smaller hole gives more diffraction blur (≈ fλ/d, with f = hole-to-screen distance and λ = wavelength of light). The sharpest hole sits where the two balance.
- **Diffraction** — a wave spreads out after passing through a narrow opening; the smaller the opening, the wider the spread. Ray optics ignores it.
- **Focal length f** — the distance from the lens (or pinhole) to where light from a very distant (infinitely far) object comes into focus. **Lenses are named by their focal length:** a "50 mm lens" means f = 50 mm, *not* a lens 50 mm wide. The width of the opening is a separate number, the aperture diameter D = f/N (below). It is intrinsic: you change it only by swapping lenses or zooming.
- **Object distance S / sensor distance S′** — S is a property of the scene, S′ of the setup (set with the focus ring, which moves the lens toward or away from the sensor). (Same concept, different names: S′ = image distance = sensor distance.)
- **Thin lens model** — a ray through the lens centre goes straight; parallel rays meet at the focal point. These two rules give `1/S + 1/S′ = 1/f`. (Same concept, different names: thin lens equation = Gaussian lens formula.)
- **Infinity focus** — the lens setting for subjects infinitely far away (in practice, anything much farther than f, like a landscape). Then 1/S → 0, so S′ = f: the lens sits exactly one focal length from the sensor. Any nearer subject needs S′ > f, so focusing closer moves the lens *out*, away from the sensor.
- **Field of view (FOV)** — the angle of scene that lands on the sensor. Longer f means a narrower view (telephoto); shorter f means a wider view (wide-angle).
- **Aperture D / f-number N** — D is the diameter of the lens's adjustable opening and N = f/D. In "f/8" the f is the focal length, so f/8 literally means D = f ÷ 8 (on a 50 mm lens, D = 6.25 mm). A "wide" or "fast" aperture means a big D, i.e. a small N. A **bigger N means a smaller hole**. (Same concept, different names: aperture size written as "f/N" = f-stop = f-number.)
- **Stop** — a ×2 change in light. One full aperture stop multiplies N by √2 (area ∝ D² = (f/N)², so N × √2 halves the light). (Same concept, different names: full stop = whole stop.)
- **Third stop** — most cameras change the aperture (and shutter time) in clicks of 1/3 of a stop, so three clicks make one full stop. Each click multiplies N by the cube root of √2, i.e. 2^(1/6) ≈ 1.12. Between f/8 and f/11 there are two in-between clicks, marked on the camera as f/9 and f/10.
- **Defocus / actual distance O** — a point at O ≠ S focuses in front of or behind the sensor, so it lands as a disc instead of a point.
- **Circle of confusion (CoC) c** — that blur disc's diameter on the sensor, measured as a length. (Same concept, different names: CoC = blur disc = bokeh disc when you look at its shape.)
- **Depth of field (DoF)** — the range of O where c ≤ ε, a threshold usually given in pixels. Convert it to a length with the **pixel pitch** (centre-to-centre pixel spacing).
- **Hyperfocal distance H** — the focus distance whose far DoF edge reaches ∞. Everything from H/2 to ∞ is then acceptably sharp.
- **Diffraction limit** — even a perfect lens cannot make a spot smaller than about λN (λ = wavelength of light, N = f-number). (Same concept, different names: diffraction-limited spot ≈ Airy disk, the bright central blob a diffraction-blurred point forms; Week 5 gives its radius as 1.22λN.)
- **Bokeh** — the look of out-of-focus blur. A defocused point becomes a copy of the aperture's shape.

**Sensor**
- **Pixel** — a photodiode (photon → electron via the photoelectric effect) plus a microlens (tiny lens that funnels light onto the photodiode) and a colour filter. **Quantum efficiency Qe** = fraction of photons counted; **fill factor** = light-sensitive fraction of the pixel's area.
- **CCD (charge-coupled device) vs CMOS (complementary metal-oxide-semiconductor) sensors** — CCD shifts charge row by row to a few shared amplifiers (sensitive, low noise). CMOS has an amplifier in every pixel (fast, cheap).
- **Global vs rolling shutter** — a global shutter exposes all rows together. A rolling shutter exposes rows one after another, which causes skew and flicker banding.
- **Noise sources** — shot (randomness in when photons arrive; Poisson statistics, where variance = mean, so variance N = mean electron count, not the f-number), dark current (electrons freed by heat even with no light; variance D·t, D = dark-current rate, not the aperture D), read (electronics noise added each time a pixel is read out; variance Nr² per readout), quantization (rounding to integer output levels; variance Δ²/12, Δ = step between levels), fixed-pattern (pixel-to-pixel differences; not random, same every frame).
- **SNR** (signal-to-noise ratio) — mean ÷ noise standard deviation. **Dynamic range** — brightest ÷ darkest signal the sensor can represent, capped by the noise floor or the bit depth (2^b levels), whichever is smaller.
- **"Frequency" / λ check:** in this week, λ in pinhole and diffraction formulas is the *wavelength of light*. λ as the Poisson mean (lecture notation, used in Week 4 E2) is the *mean count*, written N in this week's noise formulas. The 120 Hz lamp flicker is a *temporal* frequency.

### Key equations
#### E1. Optimal pinhole diameter
```
blur(d) ≈ d + f·λ/d        d = 2·√(f·λ)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| d | pinhole diameter | m (mm) | you choose |
| f | pinhole-to-screen distance (focal length) | m | fixed by the box |
| λ | wavelength of light | m (e.g. 550 nm) | fixed by the light |
| blur(d) | total blur: geometric (d) + diffraction (fλ/d) | m | result |

*Use it when:* sizing a pinhole for a given box depth. *Gotcha:* setting the derivative of blur(d) to zero gives d = √(fλ). The course form has the factor 2, and Wikipedia's version uses 1.9. *By hand:* write f·λ as (perfect square) × 10^(even power), e.g. 0.1 m × 4×10⁻⁷ m = 4×10⁻⁸ m², whose root is 2×10⁻⁴ m. At d = 2√(fλ), fλ/d = d/4, so blur = 5d/4.

#### E2. Field of view
```
FOV = 2 · arctan(d / (2f))
by hand:  d/(2f) = 1/√3, 1, √3  ⇒  FOV = 60°, 90°, 120° exactly;   narrow view (d ≪ f):  FOV ≈ d/f rad
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| FOV | full viewing angle | degrees | result |
| d | sensor (or screen) width, height or diagonal | mm | fixed by the body |
| f | focal length (pinhole-to-screen distance for a pinhole camera) | mm | intrinsic to the lens / box |

*Use it when:* you need the horizontal, vertical or diagonal angle. Use the matching sensor dimension for d. *Gotcha:* this d is a sensor size, not E1's pinhole diameter. The small-angle form overestimates wide views (it gives 2 rad ≈ 115° where the truth is 90°), so use it only when d is much smaller than f. Convert radians to degrees with × 180/π.

#### E3. Thin lens equation and magnification
```
1/S + 1/S′ = 1/f        S′ = f·S / (S − f)        m = y′/y = S′/S = (S′ − f)/f
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| S | object distance (lens to subject) | mm | scene |
| S′ | sensor (image) distance | mm | setup (focus ring) |
| f | focal length | mm | intrinsic |
| m | magnification (image height ÷ object height) | — | result |
| y, y′ | object height; image height (the image is inverted) | mm | scene; result |

*Use it when:* finding where to put the sensor, or the m that CoC and DoF need. *Gotcha:* compute S′ first, then m. Keep every length in one unit.

#### E4. F-number and stops
```
N = f / D        stops = 2 · log₂(N₂ / N₁)        N_k = N₀ · 2^(k/2)
by hand:  count steps along 1, 1.4, 2, 2.8, 4, 5.6, 8, 11, 16, 22 (each step = 1 stop);  third stops (one click of a camera's aperture dial; three clicks = one full stop): N × (√2)^(1/3) = N × 2^(1/6) ≈ N × 1.12
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| N | f-number | — | you (aperture ring) |
| f | focal length | mm | intrinsic |
| D | aperture diameter | mm | you, up to the lens's maximum |
| N₁, N₂ | starting and new f-numbers | — | you |
| stops | light lost (+) or gained (−) going from N₁ to N₂ | stops | result |
| N₀, k | starting f-number; number of stops stepped (±1/3 for a third-stop click) | —; stops | you |

*Use it when:* comparing exposures. Light ∝ D² ∝ 1/N². *Gotcha:* the "2" is there because light depends on area, so one stop changes N by √2, not 2.

#### E5. Circle of confusion
```
c = m · D · |O − S| / O        (bokeh size, S ≫ f:  c ≈ (f²/N) · |1/S − 1/O|)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| c | blur-disc diameter on the sensor | mm | result |
| m | magnification at the focused pair (S, S′) | — | from E3 |
| D | aperture diameter (= f/N) | mm | you |
| O | actual distance of the point | mm | scene |
| S | focused distance | mm | you (focus) |
| f, N | focal length; f-number | mm; — | intrinsic; you |

*Use it when:* you want the blur of a point that is not at S. *Gotcha:* as O → ∞, c → m·D (a finite ceiling). Near the lens, c → ∞.

#### E6. Depth of field: near/far edges and width
```
k = ε / (m·D)        O_near = S / (1 + k)        O_far = S / (1 − k)
DOF ≈ 2·ε·S / (m·D)                     ε (length) = ε (pixels) × pixel pitch
≡ HW form:  O_near = S·f² / (f² + N·c·(S − f)),   O_far = S·f² / (f² − N·c·(S − f))
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| k | dimensionless tolerance fraction | — | derived |
| ε (= c in HW form) | acceptable CoC threshold, as a length | mm | you choose (in px) × pitch |
| m | magnification at (S, S′) | — | from E3 |
| D | aperture diameter = f/N | mm | you |
| S | focused distance | mm | you |
| O_near, O_far | near and far edges of the sharp zone | mm | result |
| DOF | width of the range (small-k approximation) | mm | result |
| f, N | focal length; f-number | mm; — | intrinsic; you |
| pixel pitch | sensor width ÷ pixels across (√(area/pixel count) for square pixels) | mm | fixed by the camera |

*Use it when:* a question asks for near/far/DoF (HW2 T1). Both forms are identical, because m·D = f²/(N(S − f)), so k = N·ε·(S − f)/f². *Gotcha:* the edges are **asymmetric**, so the true edges are not S ± DOF/2. The compact width underestimates once k is not small. If k ≥ 1, O_far = ∞.

#### E7. Hyperfocal distance
```
H = f² / (N·c)        focus at H → sharp from H/2 to ∞
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| H | hyperfocal distance | mm | result |
| f | focal length | mm | intrinsic |
| N | f-number | — | you |
| c | **fixed** acceptable-blur threshold (= ε) | mm | you choose |

*Use it when:* landscape focusing, or checking whether a far focus distance already makes the far edge infinite (S ≥ H ⇒ O_far = ∞). *Gotcha:* this c is the threshold, not E5's variable c. This is the approximate form: the exact one is f²/(N·c) + f, and the + f is dropped because H ≫ f.

#### E8. Diffraction limit (Abbe)
```
d = λ / (2·n·sinθ) = λ / (2·NA) ≈ λ·N
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| d | smallest resolvable spot (not E1's pinhole d or E2's sensor width d) | µm | result |
| λ | wavelength of light | µm | fixed by the light |
| n | refractive index of the medium (≈ 1 in air) | — | fixed |
| θ | half-angle of the widest accepted ray cone | rad | set by the aperture |
| NA | numerical aperture = n·sinθ ≈ 1/(2N) | — | set by the aperture |
| N | f-number | — | you |

*By hand:* NA ≈ 1/(2N) is itself the small-angle approximation: sin θ ≈ tan θ = (D/2)/f = 1/(2N). *Use it when:* comparing the best possible spot with the pixel pitch. Stopping down (raising N, i.e. shrinking the opening) too far gives diffraction blur bigger than a pixel. *When does that blur start to matter?* There is no exact cut-off: softening grows gradually as N rises, so people use one of two rules of thumb, and an exam question should say which one it means. (1) **λN > pixel pitch:** the smallest detail the lens can resolve (≈ λN) is now bigger than one pixel, so the lens, not the pixel grid, limits sharpness. (2) **Airy diameter 2.44·λN > 2 pixels:** the finest pattern a pixel grid can record is one light pixel next to one dark pixel, i.e. one cycle per 2 px (the Nyquist limit, 0.5 cycles/px). Once the blur disc is wider than that 2 px cycle, light from each bright pixel spills across its dark neighbour, so the finest stripes the sensor could record lose contrast. Rule (2) uses the full Airy disk (out to its first dark ring) instead of the smaller ≈ λN spot, which is why its threshold is 2 px rather than 1 px. *Gotcha:* the Airy-disk *diameter* to its first dark ring is 2.44·λ·N (Week 5: radius 1.22·λ·N), so it is bigger than λN.

#### E9. Signal-to-noise ratio
```
SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²)        shot noise: σ = √N
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| SNR | mean ÷ noise std | — (or dB = 20·log₁₀ SNR) | result |
| P | photon flux per pixel | photons/px/s | scene + optics |
| Qe | quantum efficiency | — | sensor |
| t | exposure time (= shutter speed) | s | you |
| D | dark-current rate (not aperture D here) | e⁻/px/s | sensor + temperature |
| Nr | RMS (root-mean-square, i.e. standard deviation) read noise, paid once per readout | e⁻ (electrons) | sensor |
| N | mean collected electrons (= P·Qe·t; not the f-number) | e⁻ | result |

*Use it when:* predicting image quality. Independent variances add under the √. *By hand:* get the dB with 20·log₁₀(a/b) = 20·log₁₀ a − 20·log₁₀ b, e.g. 20·log₁₀(100/11) = 40 − 20.8. To compare two SNRs, compare SNR² (no roots needed). *Gotcha:* when shot noise dominates, SNR ∝ √t (×2 exposure → ×√2 SNR). When read noise dominates, SNR ∝ t.

#### E10. Dynamic range and bit depth
```
DR = max signal / noise floor      DR_stops = log₂(DR)      DR_dB = 20·log₁₀(DR)      levels = 2^b
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| DR | brightest ÷ darkest representable signal | — | sensor |
| max signal | full-well (saturation) capacity | e⁻ | sensor |
| noise floor | dark-level noise (≈ read noise Nr) | e⁻ | sensor |
| b | ADC (analog-to-digital converter: turns the pixel's voltage into an integer) bit depth | bits | sensor / RAW (unprocessed sensor data) format |
| levels | number of integer output values | — | result |

*Use it when:* deciding whether the noise or the ADC limits range. A b-bit ADC caps it at about b stops. *By hand:* each stop is ×2 in amplitude, i.e. 20·log₁₀ 2 ≈ 6 dB, so DR_dB ≈ 6 × DR_stops. *Gotcha:* use 20·log₁₀ for amplitude ratios (electrons) and 10·log₁₀ for power ratios.

### Causal chains
1. Pinhole shrinks → geometric blur ↓ but diffraction (fλ/d) ↑ and light ↓ (∝ d²) → **so:** there is one optimal d = 2√(fλ); smaller is not always sharper.
2. Pinhole too dim → a lens bends many rays from a point back to one image point → bright *and* sharp, but only at one S for each S′ → **so:** a lens brings defocus (CoC) and the need to focus.
3. N ↓ (wider D) → more light (∝ 1/N²) and a bigger CoC (c ∝ D) → shallower DoF → **so:** fast lenses (lenses with a small minimum N, which gather light quickly) give subject isolation and smooth bokeh, at the cost of a thin focus zone.
4. N ↑ (stopping down) → deeper DoF, but diffraction spot ≈ λN grows → once λN exceeds the pixel pitch, the image softens everywhere → **so:** there is a sweet-spot aperture (resolution vs DoF trade).
5. Focus distance S ↑ → k = Nε(S−f)/f² grows → DoF grows roughly as S², until k = 1 at S = H → **so:** far subjects are easy to get sharp; macro (extreme close-up) DoF is millimetres.
6. Rolling shutter reads rows at different times → 120 Hz (temporal) lamp flicker (60 Hz AC power, two brightness peaks per cycle) is sampled at different phases per row → horizontal bands → **so:** a global shutter, or exposure times that are multiples of 1/120 s, avoid banding.
7. Shot noise variance = mean → SNR = √N → 4× the light gives only 2× the SNR; read noise is fixed per readout → **so:** dark scenes are read-noise-limited, which matters for burst vs single exposure (HW3).

### HW tie-in
**HW1 Task 1 — Pinhole camera.** They built a shoebox camera (white-paper screen 30 cm × 20 cm, pinhole-to-screen f = 19.5 cm) and tried 0.1, 3 and 5 mm pinholes with 15–60 s exposures. FOV from E2: **75.1° horizontal, 54.3° vertical, 85.5° diagonal** (diagonal = √(30² + 20²) cm). Optimal pinhole from E1 at λ = 550 nm: **d ≈ 0.655 mm** (≈ 0.622 mm with Wikipedia's 1.9 constant). Takeaway: 0.1 mm is diffraction-limited, 3–5 mm is geometric-blur-limited, and none of the drilled holes was optimal.

**HW1 Task 2 — Photos.** 9 photos. Images are inverted. A larger pinhole gave a brighter but blurrier image (light ∝ d², blur ≈ d). Some blur also came from the phone camera not being focused on the screen.

**HW2 Task 1 — Depth of field.** Canon 5D Mark II (36 × 24 mm, 5616 × 3744 px), EF 50 mm f/1.8 lens (EF = Canon's lens mount; 50 mm = focal length f, not the lens's width; f/1.8 = its widest aperture, smallest N); the 36 × 24 mm is the sensor size; sharp means CoC ≤ **5 px**. Pixel pitch = √(36·24/(5616·3744)) = 0.00641 mm, so **c = 5 × 0.00641 ≈ 0.032 mm**. Method: E6 HW form with f = 50 mm (this matches the notes' k = ε/(mD), since both give identical numbers).

| Setting (f-number @ focus distance S) | Near | Far | DoF |
|---|---|---|---|
| f/1.8 @ 2.5 m | 2.366 m | 2.650 m | 0.284 m |
| f/3 @ 2.5 m | 2.285 m | 2.760 m | 0.475 m |
| f/16 @ 2.5 m | 1.664 m | 5.026 m | 3.36 m |
| f/3 @ 0.5 m | 0.4915 m | 0.5088 m | 17.3 mm |
| f/3 @ 20 m | 11.32 m | 85.95 m | 74.6 m |

Hyperfocal H = f²/(Nc): **26.0 m at f/3**, **4.875 m at f/16**. Takeaways: DoF grows with N (f/3 → f/16 at 2.5 m is ≈ 7.1× wider) and roughly as S². The edges are lopsided (at 20 m: 8.7 m in front of S, 66 m behind).

> **⚠ Correction:** HW2_Solutions.pdf used **c = 1 px = 0.0064 mm** instead of the required 5 px = 0.032 mm, so every DoF it reports is about 5× too small (e.g. f/3 @ 2.5 m: 2.45–2.55 m, DoF 0.094 m; f/16: 2.27–2.78 m, 0.50 m; f/3 @ 0.5 m: 3.4 mm; f/3 @ 20 m: 17.34–23.62 m). Its "6.12 m" at 20 m does not even match its own edges (they give 6.29 m). Its "ninefold" f/3 → f/16 claim is ≈ 5.3× by its own numbers and ≈ 7.1× with the correct c. Use the table above.

### Practice questions
**Q1. [Calc]** A pinhole box has its screen 10 cm behind the hole. The screen is 20 cm wide. (a) Horizontal FOV, and why not use the small-angle approximation here? (b) A second, deep box has f = 50 cm and a 5 cm wide screen: estimate its FOV. (c) Optimal pinhole diameter for the 10 cm box at λ = 400 nm, and the predicted blur there?
<details><summary>Answer</summary>

(a) d/(2f) = 20/20 = 1, and arctan(1) = 45°, so FOV = **90°** exactly. The small-angle form would give d/f = 2 rad ≈ 115°, far off, because 45° is not a small angle.  
(b) d/(2f) = 2.5/50 = 1/20 is small, so FOV ≈ d/f = 5/50 = **1/10 rad** = 18/π degrees ≈ **5.7°** (exact: 5.72°).  
(c) fλ = 0.1 m × 4×10⁻⁷ m = 4×10⁻⁸ m², so √(fλ) = 2×10⁻⁴ m and d = 2√(fλ) = **4×10⁻⁴ m = 0.4 mm**. blur ≈ d + fλ/d = 0.4 mm + (4×10⁻⁸)/(4×10⁻⁴) m = 0.4 + 0.1 = **0.5 mm** (= 5d/4). For comparison, a 1 mm hole gives 1 + 0.04 = 1.04 mm, and a 0.05 mm hole gives 0.05 + 0.8 = 0.85 mm.

</details>

**Q2. [Calc]** A 50 mm lens (focal length f = 50 mm) is focused on a person 1.8 m tall standing 2.55 m away. Find the sensor distance S′, the magnification m, and the person's image height. Does the person fit on a 36 × 24 mm sensor? How far must the lens move from its infinity-focus position?
<details><summary>Answer</summary>

S′ = fS/(S − f) = 50·2550/2500 = **51 mm**. m = S′/S = 51/2550 = **1/50** (check: (S′ − f)/f = 1/50). Image height = 1800/50 = **36 mm**. That is taller than the 24 mm sensor height, so the person only fits with the camera turned to portrait orientation (36 mm side vertical), and then exactly. At infinity focus (subject infinitely far, so 1/S → 0 and the thin lens equation gives S′ = f), S′ = 50 mm. Focusing on the person needs S′ = 51 mm, so the lens moves out by **1 mm**.

</details>

**Q3. [Calc]** You go from f/2 to f/8 on a 50 mm lens (focal length f = 50 mm). (a) Aperture diameters? (b) How many stops, and what light ratio? (c) If 1/1000 s was correct at f/2, what shutter time keeps the same brightness? (d) The camera's aperture dial moves in third-stop clicks (1/3 of a stop each; three clicks = one full stop). Starting at f/8 and closing the aperture down (raising N), what f-numbers do the next two clicks show, before you reach the next full stop, f/11?
<details><summary>Answer</summary>

(a) D = 50/2 = **25 mm**; 50/8 = **6.25 mm**.  
(b) stops = 2·log₂(8/2) = 2·2 = **4 stops less light** (count: 2 → 2.8 → 4 → 5.6 → 8); ratio (8/2)² = **16× less**.  
(c) Time × 16: 16/1000 s = 1/62.5 s ≈ **1/60 s** (the nominal 4-stop step 1/1000 → 1/500 → 1/250 → 1/125 → 1/60).  
(d) One full stop multiplies N by √2 = 2^(1/2), so one third of a stop multiplies N by 2^(1/6) ≈ 1.12. First click: 8 × 2^(1/6) ≈ 8 × 1.12 ≈ 9.0 → **f/9**; second click: 8 × 2^(1/6) × 2^(1/6) = 8 × 2^(1/3) ≈ 8 × 1.26 ≈ 10.1 → **f/10**. The next full stop is f/11.

</details>

**Q4. [Calc]** A full-frame camera (sensor 36 × 24 mm, the size of a 35 mm film frame; 7200 × 4800 px) has a 50 mm lens (focal length f = 50 mm) at f/8, focused at S = 2.55 m. Sharp means CoC ≤ 5 px. Find near, far, DoF, the compact-formula DoF, and the hyperfocal distance.
<details><summary>Answer</summary>

Pitch = 36/7200 = 0.005 mm → ε = 5 × 0.005 = 0.025 mm. Use k = N·ε·(S − f)/f². Here N·ε = 8 × 0.025 = 0.2 mm, S − f = 2500 mm and f² = 2500 mm², so k = 0.2 × 2500/2500 = **0.2** (= 1/5).  
O_near = S/(1 + k) = 2550/1.2 = **2125 mm**; O_far = S/(1 − k) = 2550/0.8 = **3187.5 mm**; DoF = **1062.5 mm ≈ 1.06 m**. The compact 2kS gives 2 × 0.2 × 2550 = 1020 mm, a slight underestimate. The edges are lopsided: 425 mm in front of S, 637.5 mm behind.  
H = f²/(Nε) = 2500/0.2 = **12 500 mm = 12.5 m** → focusing there makes **6.25 m to ∞** sharp.

</details>

**Q5. [Calc]** A sensor has a 4 µm pixel pitch. For λ = 500 nm, find the diffraction spot λN and the Airy-disk diameter 2.44λN at f/2.8, f/8 and f/16. Above what f-number does λN exceed one pixel?
<details><summary>Answer</summary>

λ = 0.5 µm, so λN is just N/2 µm, and 2.44·λN = 1.22·N µm.

| N | λN | 2.44·λN |
|---|---|---|
| f/2.8 | 1.4 µm | 3.4 µm |
| f/8 | 4 µm | 9.76 µm |
| f/16 | 8 µm | 19.5 µm |

λN = 4 µm at N = 4/0.5 = **8**. Beyond f/8 the diffraction spot is bigger than a pixel, and at f/16 the Airy disk spans about 5 pixels (19.5/4). Using the other rule of thumb from E8 instead (diffraction starts to hide the finest pattern the pixels can record, one cycle per 2 px, once the Airy diameter exceeds 2 px), the limit is 1.22·N > 8, i.e. N > 8/1.22 ≈ **f/6.6**.

</details>

**Q6. [Calc]** A pixel receives P = 2000 photons/s with Qe = 0.5, t = 0.1 s, dark current D = 50 e⁻/s and read noise Nr = 4 e⁻. (a) SNR, and in dB? (b) SNR at 4× the exposure time? (c) The sensor has a 16 384 e⁻ full well. Find its dynamic range in stops and dB. Does a 12-bit ADC limit it? A 10-bit one?
<details><summary>Answer</summary>

(a) Signal = 2000·0.5·0.1 = 100 e⁻. Variance = shot 100 + dark 50·0.1 = 5 + read 4² = 16 → 121, so σ = 11 → **SNR = 100/11 ≈ 9.1**. In dB: 20·log₁₀(100/11) = 40 − 20·log₁₀ 11 ≈ 40 − 20.8 = **≈ 19.2 dB**.  
(b) Signal 400, variance 400 + 20 + 16 = 436. Since 21² = 441, σ ≈ 20.9 → **SNR ≈ 19.1**, a gain of about 2.1×. That is a bit more than √4 = 2, because the fixed read noise matters less as the signal grows.  
(c) DR = 16 384/4 = 4096 = 2¹² → **12 stops**, and 20·log₁₀(2¹²) = 12 × 6.02 ≈ **72 dB**. A 12-bit ADC has exactly 4096 levels = 12 stops, so it just matches and does not limit. A 10-bit ADC (1024 levels) would cap it at **10 stops**.

</details>

**Q7. [Concept]** Using "circle of confusion", "f-number" and "diffraction", explain why opening the aperture from f/16 to f/2.8 gives more light, shallower DoF, *and* a smaller diffraction spot.
<details><summary>Answer</summary>

Light ∝ 1/N², so f/2.8 gives ≈ 32× more light (5 stops: f/16 → 11 → 8 → 5.6 → 4 → 2.8, and 2⁵ = 32). D = f/N grows, so the CoC c = m·D·|O−S|/O grows for every out-of-focus point, which shrinks the range where c ≤ ε (shallower DoF). A wider cone of rays (bigger NA ≈ 1/(2N)) focuses to a narrower diffraction spot ≈ λN. Wide apertures trade DoF for light and resolution.

</details>

**Q8. [Concept]** Why is depth of field lopsided (more behind the subject than in front), and why does focusing at H give "H/2 to ∞"?
<details><summary>Answer</summary>

Rewrite E5 as c = m·D·|1 − S/O|: c depends on 1/O. Behind S, c rises toward a finite ceiling m·D. In front of S, it blows up as O → 0. So the threshold crossings O = S/(1 ± k) are asymmetric. At S = H, the ceiling m·D equals ε, i.e. k = 1, so O_far = S/0 = ∞ and O_near = H/(1+1) = H/2.

</details>

**Q9. [Concept]** Under lighting powered by 60 Hz AC household ("mains") electricity, a phone video shows horizontal dark bands but a global-shutter machine-vision camera does not. Why? And CCD vs CMOS: which one is usually rolling-shutter, and why?
<details><summary>Answer</summary>

Lamps flicker at 120 Hz (temporal frequency: twice per AC cycle). A rolling shutter exposes rows at successive times, so each row catches a different flicker phase, which shows up as bands. A global shutter exposes all rows together, so the whole frame is uniformly brighter or darker with no bands. Most phone sensors are CMOS, reading rows out one at a time through per-pixel amplifiers. A global shutter needs extra per-pixel storage circuitry, which costs area and money.

</details>

**Q10. [Concept]** Which noise sources average down when you combine several frames, which can be subtracted, and why does doubling exposure improve SNR by only about √2 in bright light?
<details><summary>Answer</summary>

Shot, dark-current, read and quantization noise are fresh random draws each frame, so they average down. Fixed-pattern noise is the same every frame, so it doesn't average down; it can be calibrated out instead. The *mean* dark current can be subtracted with a dark frame (a shot taken with the lens capped), but its randomness cannot. In bright light shot noise dominates: it is Poisson, so σ = √N, and SNR = N/√N = √N. Doubling t doubles N, which raises SNR by √2.

</details>

> **Summary**
> - Image formation: a pinhole trades blur against diffraction (optimum d = 2√(fλ)). A lens fixes the light problem but brings focus: 1/S + 1/S′ = 1/f, m = S′/S, FOV = 2·arctan(d/2f).
> - One knob, N = f/D, drives exposure (1/N², √2 per stop), CoC/DoF (k = ε/(mD), O = S/(1 ± k), H = f²/(Nc)) and diffraction (≈ λN).
> - Always convert pixel thresholds to lengths with the pixel pitch, and compute S′ before m. HW2's official numbers used 1 px instead of 5 px.
> - Sensor: photons → electrons → gain (amplification) → ADC. SNR = signal/√(shot + dark + read variances). Dynamic range is capped by the noise floor or the bit depth.
> - Sets up Week 3 (RAW → colour image via the ISP, image signal processing, pipeline) and Week 4 (exposure, HDR, burst SNR).

---

## Week 3 — Color Science & the Camera ISP

> **Scope:** SSF and tristimulus (LMS) color, CIE color matching, CIE RGB vs XYZ, xy chromaticity, gamuts; the ISP pipeline (RAW → demosaic → denoise → gamut map → gamma → JPEG), image frequency and edges, Gaussian/median smoothing, MSE/PSNR, bilinear, chroma-filtered and Malvar–He–Cutler demosaicking, bilateral filter, non-local means, unsharp masking, gamut mapping, JPEG. Tested by HW2 Task 2 (simple ISP) and HW2 Task 3 (denoising).

### Key concepts
**Color**
- **Spectral sensitivity function (SSF), f(λ)** — a sensor's response per wavelength λ (here λ = wavelength of light, and f is a function name, not focal length or frequency). It turns a whole spectrum into one number.
- **Spectral power distribution (SPD), Φ(λ)** — the light's power per wavelength. It belongs to the scene, not to the sensor.
- **Tristimulus / LMS (= SML) space** — three cone readings form a point in 3D. All real light falls inside a convex cone (a geometric cone shape, unrelated to the eye's cone cells) in the positive octant (the region where all three readings are ≥ 0). Its cross-section is the "horseshoe", traced by the spectral "lasso curve" (the path of the pure single-wavelength colors; L, M, S = long-, medium-, short-wavelength cones).
- **Metamers** — different spectra that give the same three readings. This happens because spectrum → 3 numbers is many-to-one.
- **Color matching functions (CMFs)** — how much of each of three primaries (fixed reference lights that get mixed) is needed to match each pure wavelength. A negative value means that primary was added to the test side (in the matching experiment, a viewer adjusts a primary mix on one side to match a test light on the other; a primary that can only help by being added to the test light counts as negative). The **standard observer** is the averaged set of CMFs.
- **CIE RGB vs CIE XYZ** — CIE RGB uses real primaries but some colors need negative coordinates. CIE XYZ gives every real color non-negative coordinates but uses imaginary primaries (lights that cannot physically exist). No basis can have both.
- **Y = luminance** — Y's matching function is the eye's brightness curve V(λ), so Y carries brightness.
- **Chromaticity (x, y)** — XYZ with brightness divided out. It is a projection onto the plane X+Y+Z = 1.
- **Gamut** — the colors a device can make. Three real primaries give a triangle in xy. A color is out of gamut when at least one barycentric weight (the mixing weight of a primary, with the three weights summing to 1) (equivalently, one linear RGB value) is negative.
- **RGB numbers mean nothing without their primaries** — (1,0,0) in sRGB (the standard color space of most monitors and the web) and (1,0,0) in Display P3 (a wider-gamut space used on newer displays) are different colors.

**Pipeline**
- **ISP (image signal processing) pipeline** — RAW (the sensor's unprocessed, linear values, one color per pixel) Bayer mosaic → demosaicking → denoising → gamut mapping → gamma → compression → JPEG. A real camera also does black-level subtraction (removing the nonzero value a pixel reads in total darkness), white balance (per-channel gains that make gray come out R = G = B) and dead-pixel fixes.
- **Gamma encoding** — stores linear light as I^(1/2.2) so the 8-bit codes (the 256 stored integers 0–255; 2.2 is the "gamma" exponent γ) are evenly spaced in *perceived* brightness. The display decodes with ^2.2, so the chain as a whole stays linear. Linear ops (demosaicking, color matrices) belong *before* gamma.
- **Image frequency** — "frequency" in Part 2 always means image frequency (spatial frequency measured in cycles/pixel), never the frequency of light. Red light has a *low* light frequency, but "high-frequency red content" means fine detail in the red channel. Temporal frequency (Hz) is not used this week.
- **Edges/texture = high image frequency; shading = low.** A blur (low-pass filter) widens edges. Perceived sharpness lives in **luminance**, not chroma.
- **Aliasing / moiré (= false color)** — red and blue sit on every 2nd column, so they can only represent up to 0.25 cycles/px (half of their 0.5 samples/px sampling rate, the Nyquist limit). Finer detail folds back to a lower frequency. The **OLPF (optical low-pass filter; Same concept, different names: OLPF = optical anti-aliasing filter)** pre-blurs the light optically to prevent this, at the cost of resolution.
- **Demosaicking (= demosaicing)** — estimates the 2 missing channels at every pixel. *Bilinear (= naive / linear)* interpolation fills each channel independently, which causes zipper artifacts (alternating light/dark pixels along edges) and colored fringes. *Chroma low-pass* converts to Y′CbCr and median-filters only Cb and Cr. *MHC* (Malvar–He–Cutler) adds a cross-channel Laplacian (curvature: a sample minus the average of its neighbors) correction and is still linear.
- **Y′CbCr** — Y′ is luma (brightness computed from gamma-encoded values; the prime ′ marks "gamma-encoded", unlike linear luminance Y). Cb and Cr are the blue-difference and red-difference chroma channels, with 128 meaning "no color". Demosaicking errors are disagreements between channels, so they land mostly in Cb and Cr.
- **Denoising families** — a Gaussian filter (linear, weights by spatial distance only), a median filter (nonlinear, robust to outliers), a **bilateral filter** (space × intensity weights, edge-aware, nonlinear), and **non-local means (NLM)** (weights by patch similarity across a search window, uses self-similarity). Same concept, different names: spatial σ = σ_s; intensity σ_i = range σ_r ("range" here means the span of pixel values, not distance as in LiDAR range).
- **Unsharp masking** — sharpening: add back k × (I − blur(I)), k = sharpening strength. A Gaussian blur gives halos (bright/dark fringes along edges) at edges; a bilateral blur avoids them.
- **Gamut mapping** — camera RGB → XYZ (a calibrated 3×3 matrix C) → linear sRGB (a standard matrix). Out-of-gamut colors are then clipped (shifts hue, merges detail) or compressed (desaturates smoothly).
- **JPEG** — Y′CbCr → chroma subsampling (storing Cb/Cr at lower resolution: 4:4:4 = none, 4:2:2 = half horizontally, 4:2:0 = half in both directions) → 8×8 DCT (discrete cosine transform: a Fourier-like split of each block into frequency components) → quantization (rounding those components coarsely; not the ADC's quantization) → lossless entropy coding (packing the result into fewer bits). Information is lost only at subsampling and quantization.

### Key equations
#### E1. SSF response integral
```
R = ∫ Φ(λ) · f(λ) dλ
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| R | sensor's single output number | sensor units | result |
| Φ(λ) | incident light's SPD | power per nm | scene |
| f(λ) | sensor's spectral sensitivity | response per unit power | fixed by sensor |
| λ | wavelength (~400–700 nm range) | nm | integration variable |
*Use it when:* explaining why 3 sensors give 3 numbers, and metamerism. *Gotcha:* R is linear in Φ, so scaling the light scales R.

#### E2. CIE xy chromaticity
```
x = X / (X + Y + Z),   y = Y / (X + Y + Z),   z = 1 − x − y
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| X, Y, Z | CIE tristimulus values (Y = luminance) | relative | from the color |
| x, y, z | chromaticity coordinates | dimensionless | result |
*Use it when:* comparing hue/saturation, plotting gamuts. *Gotcha:* any scaled copy k·(X,Y,Z) has the same (x, y). The map is a projection, not linear.

#### E3. Gamma encoding (simple and exact sRGB)
```
I_out = I_in^(1/2.2)                    decode: I_in = I_out^2.2
C_sRGB = 12.92 · C_lin                  if C_lin ≤ 0.0031308
C_sRGB = (1 + α) · C_lin^(1/2.4) − α    otherwise,  α = 0.055
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| I_in, C_lin | linear light value | [0,1] | input |
| I_out, C_sRGB | encoded value | [0,1] | result |
| 1/2.2, 1/2.4 | encoding exponents | — | fixed by standard |
| 12.92, 0.0031308 | slope / threshold of the linear piece near black | — | fixed |
| α | offset constant for the power piece | — | fixed (0.055) |
*Use it when:* converting between linear and display values (HW2 applies `x^(1/2.2)` before PSNR). *Gotcha:* the two curves differ by about 1 code at mid-gray (linear mid-gray 0.18 → 8-bit code 117 vs 118). *By hand:* x^(1/2.2) cannot be done without a calculator, so estimate with γ = 2 (encode = √x, decode = x²). That gives slightly darker codes than true 2.2 (√0.25 → code 128 vs 136 with 2.2). Below the 0.0031308 threshold, exact sRGB is just ×12.92.

#### E4. Weighted-average smoothing and Gaussian weight
```
i_denoised(x) = (1 / Σ_{x'} w(x,x')) · Σ_{x'} w(x,x') · i_noisy(x')
Gaussian:  w(x,x') = exp(−|x − x'|² / (2σ²))     H(f) = exp(−f² / (2σ_f²)),  σ_f = 1/(2πσ)   (a Gaussian's Fourier transform is a Gaussian of reciprocal width; this H is a frequency response, not Week 2's hyperfocal H or Week 4's exposure H)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x, x' | target pixel, candidate pixel | px position | — |
| w(x,x') | weight (the only thing that differs between methods) | — | set by method |
| i_noisy, i_denoised | input / output image | intensity | — |
| σ | spatial width of the Gaussian | px | you |
| f | image frequency | cycles/px | — |
| H(f) | fraction of frequency f that survives | — | result |
| σ_f | frequency-domain width | cycles/px | fixed by σ |
*Use it when:* building any kernel. *Gotcha:* larger σ → narrower σ_f → lower cutoff → more blur. A neighbor at distance σ gets e^(−1/2) ≈ 0.607 of the center weight. *By hand:* keep the weights as e^(−fraction), add exponents when weights multiply, and normalize at the end. The binomial kernel [1/4, 1/2, 1/4] is a calculator-free stand-in for a small Gaussian (σ² = 1/2, its variance: ¼·1² + ¼·1²).

#### E5. MSE and PSNR
```
MSE  = (1 / (3·m·n)) · Σ_i Σ_j Σ_c [I_est(i,j,c) − I_gt(i,j,c)]²
PSNR = 10 · log₁₀( max(I_gt)² / MSE )      ⇔   MSE = max² · 10^(−PSNR/10)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| m, n | image height, width | px | fixed |
| i, j, c | row, column, channel index (c = 1..3) | — | — |
| I_est, I_gt | estimate, ground truth | intensity | — |
| max(I_gt) | peak value: 1 for [0,1] data, 255 for 8-bit | intensity | fixed by data format |
| PSNR | quality score, higher = better | dB | result |
*Use it when:* ranking reconstructions. *Gotcha:* max and MSE must be on the same scale. +3 dB ≈ half the MSE; +10 dB = 1/10 the MSE. *By hand:* split the log, e.g. 10·log₁₀(1/0.0004) = 10·log₁₀(10⁴/4) = 10·(4 − 2·0.301) ≈ 34 dB. For 8-bit data, 255² = (256 − 1)² = 65 025.

#### E6. Bilinear and Malvar–He–Cutler demosaicking
```
ĝ_lin(x,y) = ¼ · Σ g(x+m, y+n),   (m,n) ∈ {(0,±1), (±1,0)}
ĝ(x,y) = ĝ_lin(x,y) + α·D_R(x,y),   D_R(x,y) = r(x,y) − ¼ · Σ r(x+m, y+n),  (m,n) ∈ {(0,±2), (±2,0)}
r̂ = r̂_lin + β·D_G (R at G),   r̂ = r̂_lin + γ·D_B (R at B);   α = 1/2, β = 5/8, γ = 3/4  (MHC gains, unrelated to the gamma exponent γ or sRGB's α in E3)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| ĝ_lin, r̂_lin | bilinear estimate of the missing channel | intensity | — |
| g, r | measured green / red samples | intensity | data |
| ĝ, r̂ | MHC-corrected estimate | intensity | result |
| (m,n) | neighbor offsets | px | fixed by Bayer layout |
| D_R, D_G, D_B | Laplacian (curvature) of the channel actually measured at the pixel | intensity | computed |
| α, β, γ | correction gains | — | fixed (empirically fit) |
*Use it when:* filling Bayer gaps. In bilinear, R and B at a G pixel use the mean of 2 neighbors (horizontal or vertical); R at a B pixel (or B at R) uses the mean of 4 diagonals. *Gotcha:* this D is a gradient term, unrelated to Week 2's aperture D. MHC's G-at-R kernel is (4·center + 2·Σcross − Σouter-cross)/8, where cross = the 4 G neighbors 1 px away and outer-cross = the 4 R samples 2 px away.

#### E7. Bilateral filter weight
```
w(x,x') = exp(−|x − x'|² / (2σ²)) · exp(−|i_noisy(x') − i_noisy(x)|² / (2σ_i²))
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x, x' | center, neighbor positions | px | — |
| σ (= σ_s) | spatial scale | px | you |
| i_noisy(x), i_noisy(x') | noisy intensities at center / neighbor | intensity | data |
| σ_i (= σ_r) | intensity (range) scale | intensity | you |
*Use it when:* you need edge-preserving smoothing. *Gotcha:* σ_i → ∞ gives exactly a Gaussian. The weights depend on the data, so the filter is nonlinear.

#### E8. Non-local means weight
```
w(x,x') = exp(−‖N(x') − N(x)‖² / (2σ²))
HW2 form:  w(i,j) = (1/Z(i)) · exp(−Σ_{m,n} k_mn (v(N_i)_mn − v(N_j)_mn)² / h²),   h² = 2σ²
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| N(x), N_i | patch around the target pixel (i = x) | intensities | data |
| N(x'), N_j | patch around a candidate pixel (j = x') | intensities | data |
| v(·)_mn | patch value at offset (m,n) | intensity | data |
| k_mn | Gaussian weights within the patch | — | you (patch σ) |
| σ, h | similarity scale (h = √2·σ) | intensity | you |
| Z(i) | sum of unnormalized weights over the search window | — | computed |
*Use it when:* the image has repeated texture (self-similarity). *Gotcha:* spatial distance does not appear in w. The window only limits computation cost.

#### E9. Unsharp masking
```
sharpened = I + k · (I − blur(I))
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| I | input image | intensity | data |
| blur(I) | low-pass copy (Gaussian or bilateral) | intensity | you choose blur and σ |
| I − blur(I) | detail layer (high image frequency) | intensity | computed |
| k | strength (0 = unchanged) | — | you |
*Gotcha:* with a Gaussian blur the edge itself ends up in the detail layer, which causes over/undershoot halos.

#### E10. XYZ → linear sRGB (gamut test)
```
[R; G; B]_lin = [ 3.2406 −1.5372 −0.4986; −0.9689 1.8758 0.0415; 0.0557 −0.2040 1.0570 ] · [X; Y; Z]
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| X, Y, Z | CIE tristimulus values (white Y = 1) | relative | from calibration (C · camera RGB) |
| R, G, B (lin) | linear sRGB | [0,1] if displayable | result |
| matrix | inverse of sRGB→XYZ (whose middle row 0.2126/0.7152/0.0722 is luminance) | — | fixed (IEC 61966-2-1) |
*Gotcha:* any output below 0 or above 1 means the color is out of the sRGB gamut. Apply gamma only *after* this step. *By hand:* for a gamut test only the signs matter, so round the matrix to about [3.2 −1.5 −0.5; −1.0 1.9 0.04; 0.06 −0.2 1.06]. Redo a row with full precision only if its result lands close to 0 or 1.

### Causal chains
1. Sensor gives one number per filter → spectrum collapses to 3 values → metamers exist → so: cameras and eyes can be fooled the same way, and three primaries are enough for display.
2. Color cone is curved and three real primaries form a flat triangle → some real colors need negative weights → CIE RGB has negatives, XYZ has imaginary primaries → so: any real-device gamut misses colors.
3. 8-bit storage combined with a nonlinear eye → linear coding wastes codes on highlights → encode with ^(1/2.2) → so: do all linear math (demosaic, color matrix) *before* gamma.
4. R/B sampled every 2nd pixel → limit 0.25 cycles/px → fine detail aliases into false color → OLPF pre-blur or chroma filtering → so: color errors live in Cb/Cr.
5. Eye resolves luminance detail better than chroma → blurring Cb/Cr is almost invisible → chroma median removes fringes and keeps edges → so: JPEG subsamples chroma, and HW2's chroma median gets the best PSNR.
6. Noise is white (all image frequencies) while images are mostly low-frequency → low-pass removes noise *and* edges → weight by intensity (bilateral) or by patch (NLM) → so: edge-aware denoising.
7. Gaussian blur crosses edges → detail layer contains the edges → unsharp mask amplifies them → so: halos. A bilateral blur keeps edges out of the detail layer.

### HW tie-in
**HW2 Task 2 — Simple ISP.** Input: the noisy lighthouse RAW (RGGB, noise standard deviation σ = 0.01 on [0,1] intensities). (1) Bilinear demosaic: G at R/B = mean of the 4 cross neighbors; R/B at G = mean of the 2 horizontal or vertical neighbors; R at B and B at R = mean of the 4 diagonals. Then gamma x^(1/2.2) → **27.15 dB**. (2) Convert to Y′CbCr, apply a 9×9 median to Cb and Cr only (Y′ untouched), convert back → **30.23 dB**. (3) MHC 5×5 kernels /8 → **28.66 dB**. Ranking: bilinear 27.15 < MHC 28.66 < bilinear + chroma median 30.23. Takeaway: the fence's false color (zipper/moiré) is high-image-frequency *chroma* error, so removing it in Cb/Cr beats MHC's sharper but still per-pixel linear estimate. (MHC's gain over bilinear is +1.51 dB ≈ 1.42× lower MSE. The chroma median's gain is +3.08 dB ≈ 2.03× lower MSE.)
> **⚠ Correction:** the solution code median-filtered Cb/Cr of the *gamma-corrected* image, not the linear demosaicked image the method describes. The method is conceptually the same, but the 30.23 dB comes from that variant. Also note that `scipy.interpolate.interp2d` (suggested by the HW) was removed in SciPy 1.14.

**HW2 Task 3 — Denoising.** Input: the night image with noise σ = 0.0781. Methods: Gaussian (filter width σ = 0.5, 1, 1.5 px), median (window sizes 2, 3, 4 px), bilateral (w = spatial Gaussian × exp(−(I − I_c)²/(2σ_i²)), normalized, σ_i = 0.25 or 0.5), NLM (11×11 search window, Gaussian-weighted patch distance, h = 0.1; the center pixel is excluded and then re-added with the largest neighbor weight). No PSNRs were reported. Takeaway: Gaussian blurs edges; median handles outliers; bilateral keeps edges where the intensity step ≫ σ_i; NLM averages similar patches from anywhere.
> **⚠ Correction:** two code quirks. (a) The bilateral window radius was int(σ), so σ = 0.5 gives a 1×1 window and the filter does nothing. (b) The NLM patch radius was 0, so it compares single pixels rather than patches, which throws away NLM's noise-robust patch comparison. Learn the concepts, not those settings.

### Practice questions
**Q1. [Calc]** (a) A reconstruction on [0,1] data has MSE = 0.0004. What is its PSNR? (b) An 8-bit image scores 30 dB. What are its MSE and RMS error in code values? (c) Method B scores 3 dB higher than method A. By what factor is its MSE lower?
<details><summary>Answer</summary>

(a) PSNR = 10·log₁₀(1²/0.0004) = 10·log₁₀(10⁴/4) = 10·(4 − log₁₀ 4) = 10·(4 − 0.602) ≈ **34 dB** (33.98).  
(b) MSE = 255² · 10^(−30/10) = 65 025 × 10⁻³ ≈ **65 code values²**. RMSE = √65 ≈ **8.1 code values** (8² = 64).  
(c) MSE ratio = 10^(3/10) = 10^0.3 ≈ **2× lower MSE**, because log₁₀ 2 ≈ 0.3 (+3 dB ≈ halves the error power).

</details>

**Q2. [Calc]** A 3×3 RGGB Bayer neighborhood is centered on an R pixel. The corners are B, the edge-centers are G, and the center is R:
```
B 0.20   G 0.50   B 0.24
G 0.46   R 0.80   G 0.54
B 0.16   G 0.42   B 0.28
```
(a) Give the bilinear G and B at the center. (b) Give the bilinear B at the left-middle G pixel (0.46). (c) The red samples two pixels away from the center are 0.60, 0.70, 0.65, 0.75. Give MHC's G at the center.
<details><summary>Answer</summary>

(a) G = (0.50+0.46+0.54+0.42)/4 = **0.48**. B = mean of the 4 diagonals = (0.20+0.24+0.16+0.28)/4 = **0.22**. R = 0.80 (measured).  
(b) That G pixel sits in an R row, so its B neighbors are vertical: (0.20+0.16)/2 = **0.18**.  
(c) D_R = 0.80 − (0.60+0.70+0.65+0.75)/4 = 0.80 − 0.675 = 0.125. ĝ = 0.48 + ½·0.125 = **0.5425**. Check with the kernel: (4·0.80 + 2·1.92 − 2.70)/8 = 4.34/8 = 0.5425. The center red is a local peak, so green is nudged up.

</details>

**Q3. [Calc]** Use the by-hand gamma γ = 2 (encode √x, decode x²). (a) Encode the linear values 0.25 and 0.04 and give the 8-bit codes. (b) Decode the 8-bit code 204 (= 0.8 × 255). (c) Code 128 is "half" the code range. What linear value does it represent, and what does the true γ = 2.2 change? (d) Encode the linear value 0.002 with exact sRGB.
<details><summary>Answer</summary>

(a) √0.25 = 0.5 → 0.5 × 255 = 127.5 → **code 128**. √0.04 = 0.2 → 0.2 × 255 = **code 51**. (With true γ = 2.2 the codes are ≈ 136 and 59, slightly brighter.)  
(b) 0.8² = **0.64 linear** (true γ = 2.2 gives ≈ 0.61).  
(c) Code 128 ≈ 0.5 → 0.5² = **0.25 linear**. With γ = 2.2 it is 0.5^2.2 = 0.25 × 0.5^0.2, a bit less, ≈ 0.22. Either way, half the codes cover only the darkest ~¼ of the light, which is the point of gamma encoding.  
(d) 0.002 < 0.0031308, so use the linear piece: 12.92 × 0.002 = 0.02584 → × 255 ≈ 6.6 → **code 7**.

</details>

**Q4. [Calc]** A color has XYZ = (0.25, 0.40, 0.15). (a) Find (x, y). (b) What is (x, y) for XYZ = (0.50, 0.80, 0.30)? (c) Using E10 with the by-hand rounded matrix, is the first color inside the sRGB gamut? What about XYZ = (0.20, 0.70, 0.10)?
<details><summary>Answer</summary>

(a) Sum = 0.80 → x = 0.25/0.80 = **5/16 = 0.3125**, y = 0.40/0.80 = **1/2** (z = 3/16).  
(b) It is the same color at 2× brightness → **(5/16, 1/2)**.  
(c) First color, rounded rows: R ≈ 3.2·0.25 − 1.5·0.40 − 0.5·0.15 = 0.8 − 0.6 − 0.075 = 0.125; G ≈ −0.25 + 1.9·0.40 + 0.04·0.15 ≈ 0.52; B ≈ 0.06·0.25 − 0.2·0.40 + 1.06·0.15 ≈ 0.09. All are in [0,1] → **inside** (full precision: 0.12, 0.51, 0.09).  
Second color: R ≈ 3.2·0.20 − 1.5·0.70 − 0.5·0.10 = 0.64 − 1.05 − 0.05 = **−0.46** < 0 → **out of gamut**, without needing G or B (full precision: R = −0.48, G = 1.12 > 1, B = −0.03). Its xy = (0.20, 0.70) lies beyond sRGB's green corner (the xy of sRGB's green primary) at (0.30, 0.60).

</details>

**Q5. [Calc]** Bilateral filter with σ = 2 px and σ_i = 0.2. A neighbor sits diagonally at offset (1, 1). (a) Find its weight when its intensity differs from the center's by 0.1, and (b) when it differs by 0.5 (across an edge). (c) NLM with h = 0.1: the target patch is [0.20, 0.30, 0.25] and the candidate patch is [0.20, 0.30, 0.45]. Find the unnormalized weight using the plain squared distance and using k = [0.25, 0.5, 0.25]. Keep the answers as powers of e, then estimate.
<details><summary>Answer</summary>

Spatial factor: |Δx|² = 1² + 1² = 2 and 2σ² = 8 → e^(−2/8) = e^(−1/4).  
(a) Intensity factor: 0.1² = 0.01 and 2σ_i² = 0.08 → e^(−1/8). Total w = e^(−1/4 − 1/8) = **e^(−3/8) ≈ 0.69** (1 − 0.375 + 0.375²/2 ≈ 0.70; exact 0.687).  
(b) Intensity factor: 0.5² = 0.25 → e^(−0.25/0.08) = e^(−25/8). Total w = e^(−2/8 − 25/8) = **e^(−27/8) ≈ 0.034**. The ratio to (a) is e^(−24/8) = e^(−3) ≈ 0.05, so it is about **20× smaller**. The edge is preserved.  
(c) Squared differences: 0, 0, 0.2² = 0.04. Plain: sum 0.04, h² = 0.01 → e^(−4) ≈ **0.018**. Weighted: 0.25 × 0.04 = 0.01 → e^(−1) ≈ **0.37**. The k-weighting forgives a mismatch at the patch edge. (Both are normalized by Z(i) afterwards.)

</details>

**Q6. [Calc]** (a) Write the normalized 3-tap Gaussian kernel for σ = 1 px in exact form, then estimate it. (b) Unsharp-mask the 1D edge [0.3, 0.3, 0.3, 0.7, 0.7, 0.7] with k = 1.5, using the binomial blur [1/4, 1/2, 1/4] (replicate the borders: pad by repeating the edge values).
<details><summary>Answer</summary>

(a) Raw weights [e^(−1/2), 1, e^(−1/2)], so the kernel is **[e^(−1/2), 1, e^(−1/2)] / (1 + 2e^(−1/2))**. With e^(−1/2) ≈ 0.61, the sum is ≈ 2.22, giving ≈ **[0.27, 0.45, 0.27]**.  
(b) The blur changes only the two edge pixels: 0.3 + ¼·0.4 = 0.4 and 0.7 − ¼·0.4 = 0.6. The detail layer I − blur is −0.1 and +0.1 there. Sharpened = I + 1.5·detail → **[0.3, 0.3, 0.15, 0.85, 0.7, 0.7]**. The undershoot and overshoot (the halo) make the edge contrast 0.7 instead of 0.4.

</details>

**Q7. [Concept]** In HW2, why did "bilinear + 9×9 median on Cb/Cr" beat MHC, and why would the same median applied to Y′ (or to R, G, B) be a bad idea?
<details><summary>Answer</summary>

Bilinear errors are mostly *disagreements between channels* (false color at the fence), which sit in Cb/Cr as high-image-frequency speckle. The median removes those outliers. Y′, which carries the sharpness the eye cares about, is left untouched. MHC sharpens edges but still makes per-pixel color errors. Applying the median to Y′ or RGB would blur luminance edges, which is visible and lowers PSNR.

</details>

**Q8. [Concept]** Why is the bilateral filter nonlinear even though it is a weighted average? What does it become as σ_i → ∞, and as σ_i → 0?
<details><summary>Answer</summary>

The weights are computed from the input's own intensities, so the normalizer and weights change with the data. Doubling the input changes the weights, so the output does not simply double. As σ_i → ∞ the intensity factor → 1, giving **exactly a Gaussian blur**. As σ_i → 0 only identical-valued neighbors keep any weight, so the output is ≈ the input (no smoothing).

</details>

**Q9. [Concept]** Why does CIE XYZ need imaginary primaries while CIE RGB needs negative coordinates? How does a negative value from XYZ→sRGB relate to this?
<details><summary>Answer</summary>

Real colors fill a curved convex cone. Three *real* primaries span a triangular cone that sits strictly inside it, so colors outside need negative weights (CIE RGB). To contain the whole cone with non-negative weights, the basis vectors must lie outside it, which makes them non-physical (XYZ). sRGB is a real-primary triangle, so a negative linear sRGB value means "outside this triangle": the color is out of gamut and must be clipped or compressed.

</details>

**Q10. [Concept]** A classmate says: "Red has the lowest frequency of visible light, so the red channel can't show high-frequency aliasing." Correct them. What does a 0.35 cycles/px stripe pattern look like in the red channel?
<details><summary>Answer</summary>

They are mixing up *light* frequency (wavelength, which determines color) with *image* frequency (cycles/px across the sensor). Red pixels sample every 2nd column (0.5 samples/px), so red's limit is 0.25 cycles/px. A 0.35 cycles/px pattern folds back to |0.35 − 0.5| (an above-limit frequency reflects to |f − sampling rate|) = **0.15 cycles/px** (period 1/0.15 = 20/3 ≈ 6.7 px instead of 1/0.35 = 20/7 ≈ 2.9 px). Green still reports the true stripes, so the channels disagree, and that shows up as false color (moiré).

</details>

> **Summary**
> - Color is a 3-number projection of a spectrum (R = ∫Φf dλ). XYZ fixes the coordinates as non-negative with Y = luminance, xy divides out brightness, and a device's gamut is its primaries' triangle.
> - The ISP turns a RAW Bayer mosaic into a photo. Do linear operations (demosaic, color matrix) in linear light, then apply gamma.
> - Rule to remember: PSNR = 10·log₁₀(max²/MSE). +3 dB ≈ half the MSE.
> - "Frequency" here means image frequency (cycles/px). Chroma can be blurred almost invisibly, luma cannot. Edge-aware filters (bilateral, NLM) weight by intensity or patch similarity.
> - Sets up Week 4 (HDR, noise and calibration) and Weeks 5–6 (sampling/aliasing formalized, deconvolution).

---

## Week 4 — Exposure, Noise, HDR, Tonemapping, Coded Imaging

> **Scope:** exposure/exposure time/ISO, noise of summed and averaged frames, burst photography, exposure in LiDAR/ToF, metering, dynamic-range mismatch, HDR bracketing, radiometric calibration/CRF, log-domain weighted merge, tonemapping (photographic, gamma, color-aware), PSF/OTF, coded apertures, extended DoF, coded-aperture depth, flutter shutter, parabolic sweep (tested by HW3 Tasks 1–3).

### Key concepts
**Exposure and noise**
- **Exposure (strict)** — *H* = light energy per unit sensor area (lux·s; lux = light power per area, weighted by the eye's sensitivity). The loose sense, "how bright the photo looks", also folds in ISO gain. Keep the two apart.
- **Exposure time** — how long the sensor collects light. (Same concept, different names: exposure time = shutter speed = shutter time = integration time, the ToF camera term.)
- **Stop** — a factor of 2 in light. **EV** (exposure value) labels a whole family of equivalent (f-number *N*, exposure time *t*) pairs, EV = log₂(N²/t), so a higher EV means less light admitted (unlike Week 1's "+1 EV" compensation, which means one stop more light); 1 EV = 1 stop.
- **ISO** — analog gain applied before the ADC (analog-to-digital converter: turns each pixel's voltage into an integer). It scales the recorded value but does **not** change *H*, and it amplifies noise along with signal. (Same concept, different names: ISO = gain = film speed.)
- **Saturation** — the pixel's full well overflows, so the true value is lost for good. (Saturation = clipping = overexposure.)
- **Variances add** — for independent noise, variances add and standard deviations do not. Averaging *K* aligned frames gives σ/√*K*.
- **Fixed-pattern noise** — identical in every frame, so averaging never removes it. Read noise is paid once per readout.
- **Burst photography** — take *K* short aligned frames and combine them. Shot noise matches one long exposure, but read noise is paid *K* times.
- **Metering** — the camera averages the scene to one number, assumes it is 18% gray (the "key"), and puts it mid-range. This is why snow comes out gray.

**HDR**
- **Dynamic range** — brightest-to-darkest ratio. Real world ≈ 100,000:1, DSLR (digital single-lens reflex camera; 12-bit) ≈ 2,000:1, LCD ≈ 1,000:1, print ≈ 10:1. Bit depth counts codes and is **not** dynamic range.
- **Exposure bracketing** — several LDR (low dynamic range: ordinary single-exposure) shots of a static scene at different shutter times. The default is the metered time ±2 stops in 1-stop steps (−2, −1, 0, +1, +2): 5 frames spanning 2⁴ = 16×. (Same concept, different names: bracket = exposure stack.)
- **Radiometric calibration** — learn the camera's response curve *f* (pixel value vs. true light) from known truth (e.g. a bracket with known exposure times), then invert it to linearize (make values ∝ light). "Radiometric" = about measured light amounts. (Same concept, different names: response curve = tone reproduction curve = camera response function (CRF).) Fallback: assume the file was gamma-encoded with exponent 1/2.2 (Week 3's γ = 2.2), so raise the [0,1]-normalized pixel values to the power 2.2.
- **Confidence weight** — trust in one pixel of one exposure. It peaks at mid-gray and falls toward black and white (Gaussian bump, or the Debevec triangle/"hat").
- **HDR imaging vs. tonemapping** — HDR imaging builds a radiometrically linear (pixel value ∝ scene light), unclipped image (fixes the *sensor* limit). Tonemapping squeezes it into display range (fixes the *display* limit).
- **Global vs. local tonemapping** — a global operator applies one curve to every pixel. A local operator also uses neighbors: base/detail split (blur the image into a "base" layer, keep image − base as "detail", compress only the base), bilateral filter, gradient domain (compress large brightness differences between neighbors).
- **Color-aware tonemapping** — per-channel curves wash out color. Tonemapping Y only (xyY = Week 3's chromaticity x, y plus luminance Y) flattens detail. A Gaussian base/detail split adds halos. A bilateral (edge-aware) split fixes the halos.

**Coded imaging**
- **PSF (point spread function)** — the image of a single point; blur = image ∗ PSF. **OTF** = Fourier transform of the PSF = the fraction of each *image frequency* (spatial frequency in cycles/pixel) that survives.
- **Broadband** — the OTF has no exact zeros, so the blur is invertible in principle.
- **Coded aperture** — a patterned mask in the aperture stop (the lens's light-limiting opening, not the factor-of-2 "stop") (attenuating) or modified optics (wavefront coding). Defocus PSF = a scaled copy of the aperture shape.
- **Extended DoF (EDOF)** — make the PSF depth-invariant (focal sweep = moving focus through the whole depth range during one exposure; wavefront coding = a special lens element that makes the blur the same at all depths), then deconvolve once.
- **Coded-aperture depth** — an asymmetric PSF tells near from far, which a circular aperture cannot. It is *passive* and is not ToF.
- **Flutter shutter** — the shutter flickers open/closed in a code, giving a broadband motion kernel. (Flutter shutter = coded exposure.)
- **Motion-invariant photography** — a parabolic camera sweep (camera slides sideways with position ∝ time², i.e. at steadily changing speed) gives every object velocity the same blur kernel. (Motion-invariant = parabolic sweep.)
- **Active vs. passive** — LiDAR (light detection and ranging) / ToF (time-of-flight: distance from how long light takes to return) supplies its own light: the echo is signal and ambient light is noise. **Range gating** = a nanosecond exposure timed to the expected echo.

### Key equations
#### E1. Exposure and exposure value
```
H = E · t        E ≈ (π/4) · L / N²        H ∝ L · t / N²        EV = log₂(N² / t)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| H | exposure, light energy per unit area (not Week 2's hyperfocal H) | lux·s | result |
| E | image-plane irradiance | lux | set by L, N |
| t | exposure time (= shutter speed) | s | you control |
| L | scene luminance (brightness of the scene surface) | cd/m² (candela per m², the luminance unit) | fixed by scene |
| N | f-number | — | you control |
| π/4 | geometric constant for a circular aperture | — | fixed |
| EV | exposure value; 1 EV = 1 stop | stops | result |

*Use it when:* trading aperture against time at equal brightness; ISO multiplies the recorded brightness (∝ ISO·t/N²) but not H. *Gotcha:* aperture enters squared, so f/2.8 → f/8 is ≈ 3 stops, not 2.9×. *By hand:* use the nominal values behind the printed ones, N² = 2^(steps from f/1) and t = 2^(−steps from 1 s). Then EV is a sum of integers, e.g. f/2.8 at 1/250 s: log₂(8 × 256) = 3 + 8 = 11.

#### E2. Sum / average of K independent frames
```
Var(X₁+…+X_K) = K·σ²      Var(c·X) = c²·σ²      Var(mean) = σ²/K      σ_mean = σ/√K
Pois(λ₁) + Pois(λ₂) = Pois(λ₁ + λ₂)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| X₁…X_K | independent per-frame pixel values | DN (digital numbers: the ADC's integer output) or photons | measured |
| σ² | per-frame noise variance | (DN)² | fixed by noise model |
| K | number of frames | — | you control |
| c | scale constant (1/K when averaging) | — | you choose |
| σ_mean | std. dev. of the average | DN | result |
| λ, λ₁, λ₂ | Poisson means (= variances; mean photon counts, not wavelength) | photons | fixed by scene brightness |

*Use it when:* any burst/denoising SNR. *Gotcha:* sum and average have the **same** SNR. This only holds for independent, aligned frames, and fixed-pattern noise does not average down.

#### E3. SNR of K averaged frames (HW3 Task 2)
```
read noise only (Gaussian σ):   SNR_K = √K · μ / σ
shot noise only (Poisson λ):    SNR_K = √(K·λ)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| μ | mean signal per frame | DN | fixed by scene/exposure |
| σ | read-noise std. dev. per frame | DN | fixed by sensor |
| λ | mean photons per frame | photons | fixed by scene/exposure |
| K | frames averaged | — | you control |
| SNR_K | SNR of the K-frame average | — | result |

*Use it when:* "how many frames to reach SNR X": K = (target / single-frame SNR)². *Gotcha:* SNR is ∝ √K, so doubling SNR costs 4× the frames.

#### E4. Flutter shutter vs. burst (HW3 Task 3)
```
μ_flutter = d · n                SNR_flutter = d·n / √(d·n + σ²)      (one readout)
μ_burst   = n  (M frames summed)  SNR_burst   = n   / √(n + M·σ²)      (M readouts)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| n | mean photons over full unmodulated exposure | photons | fixed by scene, exposure |
| d | duty cycle (open fraction; not distance d in E5) | — | set by the code (HW3: 0.5) |
| M | number of time slots = burst frames | — | you choose |
| σ | read-noise std. dev. per readout | photons (e⁻) | fixed by sensor |
| μ_flutter, μ_burst | mean recorded signal | photons | result |
| SNR_flutter, SNR_burst | resulting SNRs | — | result |

*Use it when:* comparing coded exposure with a burst. Drop the σ² term for "Poisson only" and the shot term (d·n or n) for "read only". *Gotcha:* the flutter shutter loses light (factor d) but reads out once. The burst keeps all the light but pays M·σ².

#### E5. LiDAR / ToF range
```
τ = 2d / c   ⇔   d = c·τ / 2
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| d | distance to object (not E4's duty cycle d) | m | unknown, measured |
| τ | round-trip time | s | measured |
| c | speed of light ≈ 3×10⁸ | m/s | constant |
| 2 | out-and-back factor | — | fixed |

*Use it when:* timing ↔ range and gate widths. 1 ns of round trip = 0.15 m of range. *Gotcha:* forgetting the 2 doubles every distance.

#### E6. Linearization and confidence weight
```
I_nonlinear = f[ clip(tᵢ·Φ + noise) ]      I_est = f⁻¹[ I_nonlinear ]      (HW3: I_lin = (I/255)^2.2)
w(I) = exp( −4·(I − 0.5)² / 0.5² )          Debevec hat:  w(z) = 1 − |2z − 1|
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| Φ | true scene flux at the pixel | relative | fixed by scene |
| tᵢ | exposure i's exposure time | s | you control |
| f, f⁻¹ | camera response curve (CRF) and its inverse | — | fixed by camera |
| clip | saturation at full well | — | fixed by sensor |
| noise | random per-capture noise | relative | fixed by sensor |
| I_nonlinear | value stored in the file | [0,1] | measured |
| I_est, I_lin | linearized value | [0,1] | computed |
| I | in I/255: the stored 8-bit code 0–255; in w(I): the [0,1] value being weighted (HW3 weights I_lin) | DN / [0,1] | measured |
| w(I) | Gaussian weight, peak 1 at 0.5, w(0)=w(1)≈0.018 | — | computed |
| z | pixel value for the hat weight | [0,1] | measured |
| 0.5, −4/0.5² | peak location; fall-off (4/0.5² = 16 = 1/(2σ²), so σ = 1/√32 ≈ 0.177) | — | fixed |

*Use it when:* before any merge, since arithmetic needs values ∝ light. *Gotcha:* the hat weight is exactly 0 at the ends, so ln(0)·0 gives NaN. Add a tiny constant ε inside the log and keep Σw above a small minimum. *By hand:* the Gaussian simplifies to w(I) = e^(−16(I − 0.5)²), so I = 0.25 or 0.75 → e^(−1), I = 0.125 → e^(−2.25), and I = 0 or 1 → e^(−4) ≈ 0.018. The hat weight needs no exponentials at all.

#### E7. HDR log-domain weighted merge (HW3 Task 1)
```
O(X) = Σᵢ wᵢ · ( ln I_lin,i − ln(tᵢ·X) )²
X̂   = exp( Σᵢ wᵢ·(ln I_lin,i − ln tᵢ) / Σᵢ wᵢ )
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| i | exposure index, 1…N | — | fixed by bracket |
| I_lin,i | linearized value in exposure i | [0,1] | measured |
| tᵢ | exposure time of frame i | s | you control |
| wᵢ | weight w(I_lin,i) | — | computed |
| X | true relative radiance (light coming from that scene point, up to an unknown overall scale) at the pixel | relative | unknown |
| O(X) | weighted least-squares objective | — | minimized |
| X̂ | merged HDR value | relative (global scale unknown) | result |

*Use it when:* fusing a bracket. Each frame "votes" ln(I/t), and the result is the weighted mean in the log domain. *By hand:* the same formula is a weighted *geometric* mean, X̂ = Π (Iᵢ/tᵢ)^(wᵢ/Σw). So if every frame with nonzero weight votes the same value I/t, X̂ is exactly that value and no logs are needed. *Gotcha:* it gives relative radiance only, and it assumes a static, aligned stack.

#### E8. Tonemapping curves
```
Photographic (simplified Reinhard):  I_display = I_HDR / (1 + I_HDR)
Two-knob gamma (HW3):                I_display = clip( (s · I_HDR)^γ , 0, 1 )
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| I_HDR | linear HDR value (normalized to [0,1] for the gamma form) | relative | from merge |
| I_display | display value, in [0,1) or [0,1] | — | result |
| s | linear brightness gain | — | you choose |
| γ | tonemapping exponent, a free knob (<1 lifts shadows); not the fixed 2.2 encoding gamma | — | you choose |
| clip(·,0,1) | force into display range | — | fixed |

*Use it when:* showing HDR on an LDR display. L/(1+L) (L = I_HDR, not E1's scene luminance) has slope 1 near 0 and approaches 1 asymptotically. *Gotcha:* any *linear* scaling either crushes the shadows or blows out the highlights. Gamma does not approach 1 asymptotically, which is why it needs clip.

#### E9. PSF, OTF, and box-shutter zeros
```
I_blurred = I_ideal ∗ PSF        OTF(u,v) = FT{PSF}(u,v)        Ĩ_blurred = Ĩ · OTF
box (open) shutter: kernel width W → |OTF| = |sinc| (sinc(x) = sin(πx)/(πx), the Fourier transform of a box) with zeros at f = n / W,  n = ±1, ±2, …
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| I_ideal | perfectly sharp image | intensity | fixed by scene |
| PSF | blur kernel, sums to 1 | — | fixed by optics/shutter |
| ∗ | convolution | — | — |
| I_blurred | captured image | intensity | measured |
| OTF | per-frequency survival factor | — | fixed by optics |
| u, v, f | image frequency (spatial, cycles/pixel) | cycles/px | axis |
| Ĩ, Ĩ_blurred | image spectra (Fourier transforms) | — | — |
| W | motion streak length = image speed × exposure time | px | fixed by motion, t |
| n | nonzero integer indexing zeros | — | — |

*Use it when:* explaining why coding helps. Zeros mean information is lost, and broadband means the blur is invertible. *Gotcha:* "frequency" here is spatial/image frequency, not the shutter's temporal flicker rate (100 Hz in HW3) and not the frequency of light.

### Causal chains
1. Longer t → more photons → SNR ∝ √t (shot-limited) → but more motion blur, shake, and clipping. So: exposure time trades noise against blur.
2. Raise ISO → output gain ↑, H unchanged → noise amplified with signal → brightness but no SNR gain. So: only aperture and time buy light.
3. Burst of K frames → shot variance the same as one long exposure, read variance K·σ² → burst SNR < long-exposure SNR when read-limited, ≈ equal when shot-limited. So: phones burst in bright-enough light.
4. Scene range ≫ sensor range → one exposure clips or drowns → bracket shutter times → linearize (f⁻¹) → weight mid-tones → log-domain merge. So: HDR fixes measurement, not display.
5. HDR range ≫ display range → linear scaling crushes or blows out → nonlinear curve (L/(1+L), local base/detail with bilateral filter). So: tonemapping is a separate, user-chosen step.
6. Circular aperture or box shutter → OTF has exact zeros → frequencies destroyed → deconvolution impossible there → code the aperture/shutter for a broadband OTF. So: coding trades light for invertibility.
7. Nuisance parameter varies over the scene (depth, velocity) → sweep it during the exposure (focal sweep, parabolic motion) → one shared PSF → deconvolve once. So: "make everything equally blurry, then undo it."

### HW tie-in
**HW3 Task 1 — HDR fusion.** 16 LDR sRGB exposures of Memorial Church (512×768), times 1/1024 s … 32 s in powers of 2, f/8. Steps: linearize I_lin = (I/255)^2.2 → Gaussian weight w = exp(−4(I_lin − 0.5)²/0.5²) per channel → ln X̂ = Σ w_k(ln I_lin,k − ln t_k)/Σ w_k (ε inside the log) → HDR = X̂ = exp(ln X̂). Display: clip((s·I_HDR)^γ, 0, 1) with s = 1, γ = 0.5, compared with OpenCV Drago (gamma 1/2.2, saturation 0.7, bias 0.85). Takeaway: weight images show short exposures trusted on highlights and long ones on shadows. No CRF estimation was needed because the curve is known.

**HW3 Task 2 — Burst-averaging SNR.** Read noise only: the average of K has mean μ and variance σ²/K, so SNR = √K·μ/σ. Shot noise only: mean λ and variance λ/K, so SNR = √(Kλ). Takeaway: both scale as √K. The noise model only changes what σ is made of.

**HW3 Task 3 — Flutter shutter vs. burst.** 1 s exposure, 100 Hz shutter flicker (a temporal frequency: 100 open/closed slots per second, 10 ms each), 50% duty cycle. Flutter: signal 0.5n, 1 readout. Burst: 100 × 10 ms frames.

| Camera | Flutter (S, σ, SNR) | Burst (S, σ, SNR) | Winner |
|---|---|---|---|
| 1: n = 10,000 photons/s, read σ = 50 only | 5000, 50, **100** | 10,000, √(100·50²) = 500, **20** | flutter |
| 2 (sCMOS = scientific CMOS, very low read noise): n = 1,000 photons/s, Poisson only | 500, √500, **22.36** | 1000, √1000, **31.62** | burst (×√2) |

Takeaway: read-noise-limited → flutter wins, because the burst pays read noise 100×. Photon-limited → burst wins by √2, because it collects 2× the photons and splitting is free under Poisson. (The burst S is the sum. Averaging gives the same SNR.)

### Practice questions
**Q1. [Calc]** A sensor has a pixel mean of μ = 40 DN with Gaussian read noise σ = 8 DN only. (a) What is the SNR of one frame and of a 16-frame average? (b) How many frames reach SNR 30? (c) A different pixel is shot-noise-only with λ = 25 photons/frame. What is the SNR of a 9-frame average?
<details><summary>Answer</summary>

(a) One frame: 40/8 = 5. Average of 16: σ/√16 = 2 → 40/2 = **20** (= √16·5).  
(b) K = (30/5)² = **36 frames**.  
(c) One frame: √25 = 5. Average of 9: variance 25/9, σ = 5/3 → 25/(5/3) = **15** (= √(9·25)). The sum of 9 (mean 225, σ = 15) has the same SNR of 15.

</details>

**Q2. [Calc]** A 0.5 s exposure uses a flutter shutter with 5 ms slots (M = 100) at d = 0.5, compared with a 100-frame burst of 5 ms frames (summed). (a) Camera A: n = 40,000 photons, read σ = 30 only. (b) Camera B: n = 2,000 photons, Poisson only. (c) Camera B with Poisson **plus** read σ = 5. (d) What read σ makes them tie for camera B?
<details><summary>Answer</summary>

(a) Flutter 20 000/30 = **2000/3 ≈ 667**. Burst 40 000/√(100·900) = 40 000/300 = **400/3 ≈ 133** → flutter (5× better).  
(b) Poisson only, SNR = √(signal). Flutter √1000 = 10√10 ≈ **31.6**. Burst √2000 = 20√5 ≈ **44.7** → burst (√2 ×).  
(c) Compare SNR² to skip the roots. Flutter: 1000²/(1000 + 25) = 10⁶/1025 ≈ **976** (SNR ≈ 1000/32 ≈ 31.2, since √1025 ≈ 32). Burst: 2000²/(2000 + 100·25) = 4×10⁶/4500 ≈ **889** (SNR ≈ 29.8) → flutter, narrowly.  
(d) Set d²n²/(dn + σ²) = n²/(n + Mσ²) → σ² = (dn − d²n)/(d²M − 1) = 500/24 = **125/6 ≈ 20.8** → σ ≈ **4.6 e⁻** (4.5² = 20.25, 4.6² = 21.16). Below that the burst wins, above it the flutter shutter wins.

</details>

**Q3. [Calc]** One pixel is captured at t = 1/16, 1/4, 1 s with linearized values 0.125, 0.5, 1.0 (the last is clipped). (a) Use the Debevec hat weight w(z) = 1 − |2z − 1| and the log-domain merge to find X̂. (b) Repeat the reasoning with the Gaussian weight w(I) = e^(−16(I − 0.5)²): is X̂ above or below your answer to (a), and roughly by how much? (c) Compare with a naive average of I/t.
<details><summary>Answer</summary>

Per-frame votes I/t: 0.125 × 16 = **2**, 0.5 × 4 = **2**, 1.0/1 = **1** (the clipped frame under-reports).  
(a) Hat weights: 1 − |0.25 − 1| = 0.25, 1 − 0 = 1, 1 − |2 − 1| = 0. The clipped frame gets zero weight, and the other two both vote 2, so X̂ = exp((0.25·ln 2 + 1·ln 2)/1.25) = e^(ln 2) = **2 exactly** (relative units). No log values were needed.  
(b) Gaussian weights: e^(−16·(0.375)²) = e^(−2.25) ≈ 0.11, e^0 = 1, e^(−16·0.25) = e^(−4) ≈ 0.018. Now the clipped frame's vote of 1 gets a small nonzero weight, so X̂ = 2^(1.11/1.128) × 1^(0.018/1.128) ≈ 2^0.984. That is slightly **below 2**: 2^(−0.016) ≈ 1 − 0.016 × 0.69 ≈ 0.99, so X̂ ≈ 1.98, about 1% low.  
(c) Naive mean of I/t = (2 + 2 + 1)/3 = **5/3 ≈ 1.67**, dragged down by the clipped frame. The weights suppress that frame.

</details>

**Q4. [Calc]** A scene spans 1,000,000:1. One exposure usefully records 1,000:1, and brackets are spaced 2 stops apart. (a) How many exposures are needed? (b) After merging, tonemap with L/(1+L). What display values and 8-bit codes result for L = 0.05, 1, 3, 19, 99? (c) What L maps to 0.9?
<details><summary>Answer</summary>

(a) With 2¹⁰ ≈ 10³: the scene is log₂(10⁶) ≈ 20 stops and one shot covers log₂(1000) ≈ 10 stops. That leaves ≈ 10 stops to add → 10/2 = 5 extra steps → **6 exposures**. (The exact 19.93 and 9.97 give the same count.)  
(b) L/(1+L) = 1/21, 1/2, 3/4, 19/20, 99/100 ≈ 0.048, 0.5, 0.75, 0.95, 0.99 → × 255 → codes ≈ **12, 128, 191, 242, 252**. Highlights are compressed hard and shadows stay ≈ linear.  
(c) L/(1+L) = 0.9 → L = 0.9/0.1 = **9**.

</details>

**Q5. [Calc]** A correct exposure is f/2.8, 1/250 s, ISO 400. You want f/8 at ISO 1600 with the same image brightness. (a) What exposure time? (b) What happens to the physical exposure H, and what is the EV of each (N, t) pair?
<details><summary>Answer</summary>

(a) Count stops instead of dividing. Aperture f/2.8 → 4 → 5.6 → 8 = 3 stops less light. ISO 400 → 1600 = ×4 = 2 stops more brightness. Net: 1 stop short, so double the time: 1/250 → **1/125 s**. (Exact arithmetic, (1/250)·(400/1600)·(8/2.8)², gives 1/122.5 s, because the printed 2.8 is a rounded 2√2.)  
(b) t/N² falls to **¼**, so H is 2 stops lower and ISO's 4× gain makes up the brightness, with more noise. With nominal values (2.8² = 8, 1/250 ≈ 1/2⁸, 1/125 ≈ 1/2⁷): EV₁ = log₂(8 × 256) = 3 + 8 = **11**, EV₂ = log₂(64 × 128) = 6 + 7 = **13**. They are 2 EV apart (the higher EV admits less light), matching the 2 stops of ISO.

</details>

**Q6. [Calc]** A pulsed LiDAR (c = 3×10⁸ m/s) receives an echo 400 ns after firing. (a) What is the range? (b) What gate opens and closes to accept only 30–45 m, and how wide is it? (c) What range does 1 ns of timing jitter (random error in the measured echo arrival time) represent? (d) Relative to a 1 ms exposure, what fraction of ambient light does the gate admit?
<details><summary>Answer</summary>

(a) d = cτ/2 = 3×10⁸·400×10⁻⁹/2 = **60 m**.  
(b) Open at 2·30/c = **200 ns**, close at 2·45/c = **300 ns** → width **100 ns**.  
(c) c·1 ns/2 = **0.15 m**.  
(d) 100 ns / 1 ms = **10⁻⁴**: 10,000× less background, and the whole echo from inside the slice still arrives inside the gate.

</details>

**Q7. [Concept]** Raising ISO and doubling exposure time both make a photo twice as bright. Why does only one improve SNR?
<details><summary>Answer</summary>

Doubling t doubles the photons collected (H doubles). Shot-limited SNR rises by √2. ISO is gain applied after collection: signal and existing noise are amplified together, H is unchanged, and SNR does not improve. At most, it hides noise added after the amplifier.

</details>

**Q8. [Concept]** Why does the HDR merge use a confidence weight and the log domain, rather than averaging I_i/t_i?
<details><summary>Answer</summary>

Frames are not equally trustworthy. Near-black values are noise-dominated and clipped values carry no information (see Q3), so the weights favor mid-tones. In the log domain, I ≈ t·X becomes ln I − ln t ≈ ln X, which turns the merge into a weighted least-squares fit of one constant with a closed form. Linearize first: the arithmetic assumes values ∝ light.

</details>

**Q9. [Concept]** Why is an ordinary-shutter motion blur not invertible, while a flutter-shutter blur of the same duration is, even though the flutter image is darker?
<details><summary>Answer</summary>

The open shutter gives a box kernel of width W. Its spectrum is a sinc with exact zeros at image frequencies f = n/W cycles/px, so that scene detail is gone. A well-chosen open/closed code gives a **broadband** OTF with no zeros, so every frequency survives weakly and deconvolution can recover it. The cost is light: d = 0.5 halves the signal. (This f is spatial frequency, not the 100 Hz temporal flicker rate.)

</details>

**Q10. [Concept]** How do focal sweep and the parabolic camera sweep apply the same idea? How does coded-aperture depth differ from LiDAR depth?
<details><summary>Answer</summary>

Both sweep a nuisance parameter that varies across the scene (defocus/depth, or object velocity) through its whole range during one exposure. Every point then gets the same time-integrated PSF, so one deconvolution kernel restores everything. Coded-aperture depth is **passive**: it reads the depth-dependent shape of the blur in one photo, needs texture, and an asymmetric mask resolves near-vs-far. LiDAR is **active**: it times its own light's round trip (τ = 2d/c) and works on textureless walls, but ambient light and saturation can hurt it.

</details>

> **Summary**
> - Exposure H ∝ L·t/N² sets the light; ISO only scales it. Averaging K frames gives σ/√K, but read noise is paid per readout.
> - Rules to remember: X̂ = exp(Σwᵢ(ln Iᵢ − ln tᵢ)/Σwᵢ), and SNR_flutter = dn/√(dn+σ²) vs. SNR_burst = n/√(n+Mσ²).
> - HDR imaging (bracket → linearize → weighted merge) fixes the sensor limit. Tonemapping (L/(1+L), (sI)^γ, local bilateral) fixes the display limit.
> - Coded capture (aperture, shutter, sweep) makes the PSF broadband and/or invariant, so the blur is invertible.
> - Sets up Week 5: actually inverting a known PSF/OTF under noise (Wiener deconvolution).

---

## Week 5 — Fourier, Sampling, Deconvolution, Linear Systems

> **Scope:** Fourier transform and convolution theorem · sampling, Nyquist–Shannon, aliasing, spectral copies · DFT/FFT, `psf2otf` and circular convolution · diffraction and pixel integration as optical low-pass filters · filtering, up/downsampling, anti-aliasing, LiDAR range ambiguity · deconvolution (inverse filter, Wiener) · b = Ax, least squares, normal equations, regularization · gradient descent and SGD. Tested by HW4 Tasks 1–3.

### Key concepts
**"Frequency" — three meanings (always say which)**
- **Spatial frequency** — cycles per unit length (cycles/mm on the sensor) or, on a pixel grid, **image frequency** in cycles/pixel. **Temporal frequency** — cycles per second (Hz) of a time signal (flicker, LiDAR pulses, wagon-wheel spokes). **Light frequency** — the frequency of the electromagnetic wave itself, ∝ 1/wavelength λ (appears here only through λ in diffraction).

**Fourier basics**
- **Fourier transform** — rewrites a signal as a weighted sum of sinusoids; each complex coefficient stores amplitude (magnitude) and shift (phase). (Same concept, different names: primal domain = spatial domain = time domain; Fourier domain = frequency domain = spectral domain; Fourier transform = spectrum = Fourier coefficients.)
- **Magnitude vs. phase** — phase carries most of the structure (where edges are); magnitude says how much of each frequency.
- **Convolution** — slide a flipped kernel over the signal, multiply-and-sum at each position. (Kernel = filter = impulse response; for optics = point spread function (PSF) = blur kernel.)
- **Convolution theorem** — convolution in one domain = point-wise multiplication in the other.
- **Scaling theorem** — wide in space ⇔ narrow in frequency (bigger blur → narrower passband).
- **OTF / MTF** — OTF = Fourier transform of the PSF (= transfer function = frequency response); MTF = |OTF|. Every physical PSF has OTF(0) = 1 (the value at zero frequency, i.e. the image mean, passes unchanged) and |OTF| ≤ 1 → every lens is a **low-pass filter**.

**Sampling**
- **Sampling** (f_s = sampling rate: samples per second, or per mm / per pixel) — multiply by an impulse train (a row of evenly spaced spikes, one per sample) (comb, Dirac comb, Shah function) → spectrum is **copied** at every multiple of f_s. (Spectral copy = replica = spectral image.)
- **Nyquist frequency** (f_max = the highest frequency present in the signal) — f_s/2, belongs to the sampler (= folding frequency = Nyquist limit). **Nyquist rate** — 2·f_max, belongs to the signal. Do not mix them up.
- **Aliasing** — copies overlap → a high frequency masquerades as a low one; **cannot be undone after sampling**.
- **Anti-aliasing filter** — low-pass *before* sampling (= AA filter = prefilter = optical low-pass filter (OLPF) in a camera).
- **Downsampling by D** — low-pass to 1/(2D) cycles/original pixel first, then keep every D-th pixel. (Subsampling = discard without filtering; downsampling = decimation = filter first.) **Upsampling by D** — zero-stuff (insert D − 1 zeros between neighbouring pixels), then interpolate with a low-pass kernel of gain D (its weights sum to D, making up for the inserted zeros).
- **Temporal aliasing** — wagon-wheel effect; in **LiDAR**, range ambiguity: a return arriving after the next pulse is assigned to the wrong pulse.

**DFT / FFT and code**
- **DFT** (discrete Fourier transform: the Fourier transform of a finite list of samples) — N samples → N coefficients, treating the samples as one period of a repeating signal → filtering by DFT = **circular convolution** (wrap-around at borders).
- **FFT** (fast Fourier transform) — an *algorithm* computing the DFT exactly in ~N log₂ N instead of N² operations.
- **`psf2otf(k, shape)`** — zero-pad kernel to image size → circularly shift (shift with wrap-around) its center to index (0,0) (the top-left array entry, where the DFT puts the origin) → FFT. Without the shift, the output image is translated.

**Optics as low-pass**
- **Diffraction** — aperture → coherent PSF (laser-like light whose waves stay in step) = F{aperture} (F = Fourier transform); incoherent PSF (ordinary light) = |F{aperture}|²; OTF = autocorrelation of aperture (how much the aperture overlaps a shifted copy of itself, for each shift), zero beyond a cutoff spatial frequency. Bigger aperture → smaller blur.
- **Pixel integration** — each pixel box-averages light over its area (sinc MTF: sinc(f) = sin(πf)/(πf), a ripple that shrinks with frequency and has exact zeros; MTF = |OTF|) before the grid samples at pitch p (sensor Nyquist 1/(2p)).

**Inverse problems**
- **Deconvolution** — undo a known blur (= deblurring = image restoration; non-blind = PSF known). **Inverse filter** — divide spectrum by OTF; blows up noise where |OTF| ≈ 0.
- **Wiener filter** — inverse filter × damping factor |K|²/(|K|² + 1/SNR) (K = the blur's OTF; SNR here = signal power ÷ noise power, not Week 2's mean ÷ std; see E6). (Wiener filter = Wiener deconvolution; damping factor = regularizing factor = filter factor.)
- **b = Ax** — any linear imaging process (x = unknown image as one long column of numbers, A = matrix describing the camera/blur, b = measurements); **null space** = inputs x that A maps to zero (invisible to the camera), **rank** = how many independent pieces of information survive; **condition number** s_max/s_min (s = singular values: the gains A applies along its independent directions) = noise amplification.
- **Least squares** — minimize ½‖Ax − b‖² (‖v‖² = sum of squared entries of v) (= ℓ₂ fitting = data term); **normal equations** AᵀAx = Aᵀb (Aᵀ = transpose of A: rows and columns swapped). **Tikhonov regularization** adds λ‖x‖²/2 (λ = regularization weight, a dial you set; not a wavelength) → stable, unique.
- **Gradient descent (GD)** — step downhill along −∇f (∇f = gradient: the vector of partial derivatives of the cost f, pointing uphill); (= full-batch/vanilla GD; step size = learning rate α). **SGD** (stochastic, i.e. random, gradient descent) — same step using a random batch of rows (each row of A = one measurement).

### Key equations

#### E1. Convolution theorem
```
b = x ∗ c          F{b} = F{x} · F{c}          (B = X · C)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x, X | Input image and its spectrum | intensity | fixed (the scene) |
| c, C | Kernel/PSF and its Fourier transform (OTF) | unitless (sums to 1) | you (a filter) or fixed (optics) |
| b, B | Filtered/blurred image and its spectrum | intensity | result |
| ∗ | Convolution | — | — |
| F{·} | Fourier transform (DFT in code) | — | — |
| · | Point-wise (per-frequency) multiplication | — | — |
*Use it when:* filtering by FFT, analysing blur, deriving deconvolution. *Gotcha:* with the DFT it is **circular** convolution — borders wrap around.

#### E2. Nyquist–Shannon criterion and aliased frequency
```
f_s ≥ 2 f_max          Nyquist frequency = f_s / 2
f_apparent = | f − f_s · round(f / f_s) |
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| f_s | Sampling rate | Hz (temporal) or cycles/px, samples/mm (spatial) | you / hardware |
| f_max | Highest frequency in the signal | same as f_s | fixed by signal (or by AA filter) |
| f | A frequency present in the signal | same as f_s | fixed by signal |
| f_apparent | Frequency it appears as after sampling, in [0, f_s/2] | same as f_s | result |
| round(·) | Nearest integer (which spectral copy is closest) | — | — |
*Use it when:* checking for aliasing; predicting what a too-high frequency looks like. *Gotcha:* f exactly = f_s looks like 0 Hz (constant).

#### E3. Filtering cost: direct vs FFT
```
primal ≈ P · K²          Fourier ≈ 2 P log₂ P + P
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| P | Number of pixels in the image | pixels | fixed by image |
| K | Kernel side length (K×K kernel); not the OTF K of E5 | pixels | you (e.g. ceil(9σ): σ = the Gaussian's width in pixels, ceil = round up) |
| 2 P log₂ P | One forward + one inverse FFT | operations | — |
| + P | Per-frequency multiply | operations | — |
*Use it when:* deciding which route is faster. *Gotcha:* FFT cost ignores K; for tiny kernels direct convolution wins (break-even K² ≈ 2 log₂ P + 1). *By hand:* write P and K as powers of 2 (512² = 2¹⁸, 32² = 2¹⁰), so products are exponent sums and log₂ P is just the exponent.

#### E4. LiDAR range ambiguity (temporal aliasing)
```
pulsed:   R_max = c / (2 · PRF)          d_reported = d_true − m · R_max
CW ToF:   R_amb = c / (2 · f_mod)        d_reported = d_true mod R_amb
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| R_max, R_amb | Max unambiguous range | m | follows from PRF / f_mod |
| c | Speed of light ≈ 3 × 10⁸ | m/s | fixed |
| PRF | Pulse repetition frequency (temporal) | Hz | designer |
| f_mod | Modulation frequency of a continuous-wave (CW) ToF sensor, whose light brightness oscillates as a sine wave and reads distance from the echo's phase delay (a temporal frequency: brightness oscillations per second, not the light's own frequency) | Hz | designer |
| 2 | Round trip (out and back) | — | fixed |
| d_true, d_reported | Actual and reported distance | m | scene / result |
| m | Number of pulse periods skipped (integer) | — | fixed by geometry |
| mod | Remainder after dividing by R_amb | — | — |
*Use it when:* sizing a LiDAR's pulse rate. *Gotcha:* higher PRF = more points/s but shorter R_max — a direct trade-off.

#### E5. Noisy blur model and inverse filter
```
b = k ∗ i + n          B = K · I + N
i_est = F⁻¹( B / K )   ⇒   B / K = I + N / K
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| i, I | Sharp image and spectrum | intensity | unknown |
| k, K | Blur PSF and OTF (this K is not E3's kernel side length) | unitless | known (non-blind) |
| n, N | Additive noise and its spectrum | intensity | fixed by sensor |
| b, B | Measurement and its spectrum | intensity | measured |
| i_est | Restored image | intensity | result |
| F⁻¹ | Inverse Fourier transform | — | — |
*Use it when:* noise-free (or near-noise-free) deconvolution. *Gotcha:* N/K explodes where |K| ≈ 0 → garbage with any noise.

#### E6. Wiener deconvolution (textbook power form)
```
i_est = F⁻¹( K* / ( |K|² + 1/SNR ) · F(b) )
      = F⁻¹( (1/K) · [ |K|² / ( |K|² + 1/SNR ) ] · F(b) )
SNR(ω) = signal power at ω / noise power at ω     (constant approx: 1/SNR ≈ σ_n² / signal power)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| K, K* | OTF of the known blur, and its complex conjugate (same magnitude, opposite phase: flip the sign of the imaginary part) | unitless | known |
| \|K\|² | Squared OTF magnitude at frequency ω | unitless | known |
| SNR(ω) | Signal-to-noise **power** (variance) ratio at frequency ω | unitless | estimated / chosen (often one constant) |
| ω | Spatial frequency index | cycles/px | — |
| F(b) | Spectrum of the measurement | — | measured |
| σ_n | Noise standard deviation | intensity | fixed by sensor |
| [ … ] | Damping factor, between 0 and 1 | unitless | follows |
*Use it when:* deblurring with noise. *Gotcha:* SNR → ∞ gives the inverse filter; small |K| → gain ≈ |K|·SNR → 0 instead of ∞.

#### E7. Least squares, gradient, normal equations
```
x̂ = argmin_x ½ ‖A x − b‖₂²        (argmin_x = "the x that makes this smallest")
∇ₓ ½‖Ax − b‖₂² = Aᵀ(Ax − b) = AᵀA x − Aᵀb
AᵀA x̂ = Aᵀb
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x, x̂ | Unknown (image/parameters) and its LS estimate | problem units | unknown / result |
| A | m×n forward (image-formation) matrix | — | known |
| b | m×1 measurements | measured units | measured |
| Aᵀ | Transpose of A (rows and columns swapped; for a blur: convolve with flipped kernel) | — | — |
| ‖·‖₂ | Euclidean (ℓ₂) norm = a vector's length √(Σ vᵢ²) | — | — |
| ∇ₓ | Gradient with respect to x | — | — |
*Use it when:* over-determined fits (more measurements than unknowns); deriving GD. *Gotcha:* AᵀA is singular (has no inverse) if A has a null space → add λI (I = identity matrix: 1s on the diagonal, 0 elsewhere) (Tikhonov: (AᵀA + λI)x = Aᵀb).

#### E8. Gradient descent and its step-size limit
```
x^(k+1) = x^(k) − α Aᵀ( A x^(k) − b )
converges if 0 < α < 2 / μ_max
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x^(k) | Estimate after k iterations | problem units | result |
| k | Iteration index | — | — |
| α | Step size = learning rate | — | you |
| A, b | As in E7 | — | known / measured |
| μ_max | Largest eigenvalue of AᵀA (= s_max²; an eigenvalue μ is a stretch factor: AᵀA v = μ v for some direction v) | — | fixed by A |
*Use it when:* A is too big to invert (HW4: 16384×128). *Gotcha:* α too large → diverges; too small → slow.

#### E9. Stochastic gradient descent
```
x^(k+1) = x^(k) − α Ã^(k)ᵀ ( Ã^(k) x^(k) − b̃^(k) )          E[ g(x) ] ∝ ∇f(x)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| Ã^(k), b̃^(k) | B randomly chosen rows of A and entries of b at iteration k | — | random |
| B | Batch size (not the spectrum B of E5) | rows | you |
| α | Step size | — | you |
| g(x) | Batch gradient estimate | — | random |
| E[·] | Expectation = average over all possible random batches; E[g] = (B/m)·∇f exactly, with m = total rows of A | — | — |
| f | Full objective ½‖Ax − b‖² | — | — |
*Use it when:* m is huge; each iteration cheap. *Gotcha:* batch gradient is ~B/m the size of the full gradient at the same α → small batches take many more iterations.

### Causal chains
1. Sampling = multiply by comb → spectrum copied every f_s → copies overlap if f_max > f_s/2 → aliasing. **So:** low-pass *before* sampling; it cannot be fixed afterwards.
2. Keep every D-th pixel → copies move D× closer (Nyquist drops to 1/(2D) cycles/original px) → overlap. **So:** blur to 1/(2D) first, then decimate.
3. Higher LiDAR PRF → next pulse fires before far returns arrive → far target reported at d − R_max. **So:** R_max = c/(2·PRF); more points/s costs range.
4. Lens/pixel PSF ≥ 0 and sums to 1 → |OTF| ≤ 1 with zeros/small values at high frequency → information attenuated or lost. **So:** every camera is a low-pass filter, and undoing it means amplifying.
5. Inverse filter divides by small |K| → noise term N/K explodes → PSNR collapses. **So:** Wiener damps each frequency by |K|²/(|K|²+1/SNR), trading leftover blur for less noise.
6. DFT treats image as periodic → FFT filtering = circular convolution → borders wrap; `psf2otf` must centre the kernel at (0,0). **So:** FFT and `convolve2d` match in the interior, differ at edges.
7. AᵀA has large eigenvalue spread (ill-conditioned = large condition number, so small noise causes big errors) → GD step capped by 2/μ_max but slow along small-eigenvalue directions; SGD batch gradient is a noisy, scaled-down estimate. **So:** pick α from μ_max; smaller batch → cheaper but more iterations.

### HW tie-in
**HW4 Task 1 — Spatial vs Fourier filtering.** Gaussian LPF σ = 0.1, 1, 10 (kernel ceil(9σ): 1×1, 9×9, 90×90) and HPF = δ − Gaussian (101×101; δ = a kernel with a single 1 at its centre, which leaves the image unchanged), filtered by `convolve2d(..., 'same', symmetric)` (output same size as input; borders filled by mirroring) vs `real(ifft2(fft2(img)·psf2otf(k, shape)))` · cost E3 · timings ≈ 0.01 s, 0.1 s, ~12 s for LPF direct and ~15.5 s for the 101×101 HPF; FFT ≈ 0.03–0.05 s regardless of kernel; for the 1×1 kernel direct is slightly faster · **Takeaway:** direct ∝ P·K², FFT ∝ P log P independent of K (E3's symbols).

**HW4 Task 2 — Inverse vs Wiener deconvolution.** Birds image blurred with Gaussian PSF σ = 5 px (35×35), circular via FFT; noise std. dev. σ_n = 0, 0.001, 0.01, 0.1 (intensities on a 0–1 scale) · E5 vs E6 · PSNR (dB):

| σ_n | 0 | 0.001 | 0.01 | 0.1 |
|---|---|---|---|---|
| Inverse | 112.10 | 5.52 | 5.52 | 5.52 |
| Wiener | 31.77 | 26.64 | 25.88 | 19.60 |

· **Takeaway:** any noise destroys the inverse filter (N/K where |K| ≈ 0); Wiener degrades gracefully. At σ_n = 0 Wiener < inverse because its finite 1/SNR still damps small-|K| frequencies.
> **⚠ Correction:** the HW code set SNR = Ī/σ_n (mean over std — an **amplitude** ratio). The textbook Wiener filter uses a **power** ratio: H = K*/(|K|² + 1/SNR) with SNR = S_x/S_n (signal power ÷ noise power at each frequency), constant approx 1/SNR = σ_n²/(signal power). They differ by a square, so the code's damping knob is not the textbook value; state E6 on the exam.

**HW4 Task 3 — GD vs SGD for least squares.** min ½‖Ax − b‖², A 16384×128, gradient Aᵀ(Ax − b), α = 1e-4, 1500 iterations, x₀ = 0; SGD batches of 10, 100, 1000 rows, same α · E8, E9 · residual (here the objective value ½‖Ax − b‖²) ≈ 1e6 → ≈ 8e-3 (1e6 = 10⁶; matches `lstsq`, NumPy's direct least-squares solver); GD converges in ~100 iterations (~0.15 s); SGD-1000 ~110 iterations, ~0.08 s (fastest wall time); SGD-100 ~1100 iterations; SGD-10 does not converge (~5e4) · **Takeaway:** smaller batch → cheaper iteration but noisier, smaller effective step → more iterations.

### Practice questions

**Q1. [Calc]** A signal contains a 130 Hz (temporal) tone and is sampled at f_s = 100 Hz. (a) What is the Nyquist frequency of the sampler, and the Nyquist rate the signal needs? (b) At what frequency does the tone appear?
<details><summary>Answer</summary>

(a) Nyquist frequency = f_s/2 = 50 Hz; Nyquist rate = 2·130 = 260 Hz → under-sampled.  
(b) round(130/100) = 1 → |130 − 100·1| = **30 Hz**.

</details>

**Q2. [Calc]** A pulsed LiDAR fires at PRF = 750 kHz. (a) Max unambiguous range? (b) Where is a target at 260 m reported?
<details><summary>Answer</summary>

(a) R_max = c/(2·PRF) = 3×10⁸ / (2 · 7.5×10⁵) = **200 m**.  
(b) Its echo arrives after the next pulse (m = 1): 260 − 200 = **60 m**.

</details>

**Q3. [Calc]** A 512×512 image is filtered with a 32×32 kernel. Estimate operation counts for direct convolution and the FFT route (E3). Above what kernel size K does FFT win?
<details><summary>Answer</summary>

P = 512² = 2¹⁸ (≈ 2.6×10⁵); log₂ P = 18. K² = 32² = 2¹⁰.  
Direct: P·K² = 2¹⁸ · 2¹⁰ = **2²⁸ ≈ 2.7 × 10⁸** (2⁸ × 2²⁰ ≈ 256 × 10⁶).  
FFT: 2·P·18 + P = 37·P = 37 × 2¹⁸ ≈ **9.7 × 10⁶**. Ratio = 2¹⁰/37 ≈ 1024/37 → ~**28× fewer**.  
Break-even: K² = 2·18 + 1 = 37 → K ≈ 6 (6² = 36), so FFT wins for **K ≳ 7**.

</details>

**Q4. [Calc]** At one frequency the OTF magnitude is |K| = 0.05 and the (power) SNR is 100. Compare the gain of the inverse filter and the Wiener filter. Repeat for |K| = 0.9.
<details><summary>Answer</summary>

Wiener gain magnitude = |K|/(|K|² + 1/SNR) (from E6, since |K*| = |K|), 1/SNR = 0.01.
|K| = 0.05: inverse 1/0.05 = **20**; Wiener 0.05/(0.0025 + 0.01) = **4** (damping factor 0.2).
|K| = 0.9: inverse 1/0.9 = **10/9 ≈ 1.11**; Wiener 0.9/(0.81 + 0.01) = 0.9/0.82 = **45/41 ≈ 1.10** (damping 0.81/0.82 = 81/82 ≈ 0.99) — nearly identical where signal dominates.

</details>

**Q5. [Calc]** f(x) = ½‖Ax − b‖² with A = [[1, 1], [0, 1], [1, 0]], b = [3, 1, 2]ᵀ, x⁽⁰⁾ = [0, 0]ᵀ. (a) Compute ∇f(x⁽⁰⁾). (b) Take one GD step with α = 0.2. (c) What is the largest stable α?
<details><summary>Answer</summary>

(a) Ax⁽⁰⁾ − b = [−3, −1, −2]; ∇f = Aᵀ(Ax − b) = [−3 − 2, −3 − 1] = **[−5, −4]ᵀ**.  
(b) x⁽¹⁾ = [0, 0] − 0.2·[−5, −4] = **[1, 0.8]ᵀ**; f drops from 7.0 to 1.24. (Exact solution is [2, 1], where f = 0.)  
(c) AᵀA = [[2, 1], [1, 2]], eigenvalues 1 and 3 (for [[a, b], [b, a]] they are a − b and a + b; check: [1, 1] → [3, 3], [1, −1] → [1, −1]) → α < 2/3 ≈ **0.667**.

</details>

**Q6. [Calc]** Fit y = c₀ + c₁t to the points (0, 1), (1, 2), (2, 2), (3, 4) by least squares using the normal equations.
<details><summary>Answer</summary>

A rows [1, t]: AᵀA = [[4, 6], [6, 14]], Aᵀy = [9, 18]ᵀ. det = 4·14 − 36 = 20 (2×2 inverse: [[a, b], [c, d]]⁻¹ = [[d, −b], [−c, a]] / (ad − bc)).  
c₀ = (14·9 − 6·18)/20 = 0.9; c₁ = (4·18 − 6·9)/20 = 0.9 → **y = 0.9 + 0.9t**.

</details>

**Q7. [Concept]** In HW4, the inverse filter scored 112 dB at σ_n = 0 but 5.52 dB at every σ_n ≥ 0.001. Why does even tiny noise ruin it, and why is the score the same across noise levels?
<details><summary>Answer</summary>

B/K = I + N/K. A Gaussian blur's OTF falls to ≈ 0 at high frequencies, so N/K is astronomically large there for *any* nonzero noise; the output is dominated by amplified noise (so the PSNR saturates at a floor regardless of σ_n). At σ_n = 0 only rounding error remains → near-perfect.

</details>

**Q8. [Concept]** You downsample a photo of a brick wall by 4 by keeping every 4th pixel and see moiré. Explain the cause, the fix, and why blurring the small image afterwards does not help.
<details><summary>Answer</summary>

Keeping every 4th pixel lowers the Nyquist frequency to 1/(2·4) = 0.125 cycles/original pixel (image frequency); brick detail above that folds into false low frequencies (aliasing). Fix: low-pass to ≤ 0.125 cycles/px **before** decimating. After sampling, the aliased energy sits at legitimate low frequencies, indistinguishable from real content — a blur can't separate it.

</details>

**Q9. [Concept]** Filtering by FFT with `psf2otf` and by `convolve2d` gives matching interiors but different borders. If you skipped the circular shift inside `psf2otf`, what would go wrong?
<details><summary>Answer</summary>

The DFT assumes periodicity → FFT filtering is circular convolution (borders wrap from the opposite edge), while `convolve2d` pads (zeros or symmetric). Without centring the kernel at index (0,0), the output is **translated** by half the kernel size (shift theorem: shifting a signal leaves each frequency's magnitude alone and adds a phase that grows steadily with frequency, a "phase ramp").

</details>

**Q10. [Concept]** In HW4 Task 3, with the same α, SGD with 1000-row batches beat full GD in wall time, but 10-row batches never converged. Explain both.
<details><summary>Answer</summary>

Each SGD step costs ~B/m of a GD step, so 1000 rows (≈ 6% of 16384) are far cheaper, and their gradient is still accurate enough to converge in ~110 iterations. But the batch gradient is ~B/m the size of the full one at fixed α (smaller effective step) and noisier as B shrinks: with B = 10 the progress per iteration is tiny and noisy, so 1500 iterations aren't enough.

</details>

> **Summary**
> - Convolution ⇔ multiplication (E1): blur, filtering and deconvolution are all per-frequency multiplies; every PSF is low-pass.
> - Sampling copies the spectrum every f_s; keep f_max < f_s/2 or anti-alias first — applies to pixels, downsampling, video, and LiDAR range (R_max = c/(2·PRF)).
> - Deconvolution: inverse filter explodes noise; Wiener K*/(|K|² + 1/SNR) is the one formula to remember.
> - Linear view b = Ax: least squares → normal equations AᵀAx = Aᵀb, or GD with α < 2/μ_max; SGD trades per-step cost for iterations.
> - Sets up Week 6: regularized inverse problems (priors beyond Tikhonov) solved iteratively with ADMM.

---

## Week 6 — Regularized Inverse Problems with ADMM

> **Scope:** Bayesian/MAP view (likelihood, prior → data term + λ·Ψ), norms and ℓ₁ sparsity, priors (smoothness, sparsity, TV), finite differences, Adam, splitting → Lagrangian → augmented Lagrangian → ADMM (prox, soft thresholding, Fourier x-update), plug-and-play / HQS / unrolling, single-pixel camera (least norm, CG), compressive LiDAR, CT/MRI/hyperspectral. No HW tie-in (HW5 is outside the midterm).

### Key concepts
**Bayesian view**
- **Inverse problem / ill-posed** — recover x from b = Ax + η (η = measurement noise); many x fit b (and small divisors amplify noise), so a prior must pick one.
- **Likelihood** p(b | x) (read "probability of b given x") — how well image x explains the data; Gaussian noise → squared-error data term. (= image formation model.)
- **Prior** p(x) — how plausible x is before any data. (Same concept, different names: prior ↔ regularizer = regularization term = penalty, Ψ(x) = −log p(x); some slides write Γ.)
- **Posterior / MAP** — posterior ∝ likelihood × prior; MAP = argmax posterior (the x that makes the posterior p(x | b) largest) = argmin (−log). (MAP = maximum a posteriori = posterior mode.) **Data fidelity term** = data term.
- **λ (regularization weight)** — dial between "believe the data" (small) and "believe the prior" (large); ≈ σ² × prior strength (σ = noise standard deviation), so more noise → larger λ. (λ here is a weight, not a wavelength.)

**Norms and priors**
- **ℓ₂ / ℓ₁ / "ℓ₀"** — length / sum of |entries| (Manhattan = taxicab) / count of nonzeros ("ℓ₀" is not a true norm; impractical to optimize).
- **Sparse** — mostly exact zeros. Minimizing ℓ₁ gives sparse answers (the ℓ₁ "ball", all vectors with ‖v‖₁ ≤ r, is a diamond in 2D; it touches the solution set, i.e. the x's that fit the data, at a corner on an axis); ℓ₂ spreads values out. ℓ₂² ↔ Gaussian prior; ℓ₁ ↔ Laplace prior (sharp peak at 0, heavy tails).
- **Three priors** — smooth images → ‖Δx‖₂² (Laplacian = curvature); stars → ‖x‖₁ (sparse pixels); natural photos → TV(x) (sparse **image** gradients).
- **"Gradient" is overloaded** — *image gradient* = pixel-to-pixel brightness change (finite differences D_x, D_y) vs. *objective gradient* ∇f = partial derivatives of the cost (what Adam / PyTorch's `.backward()`, which computes ∇f automatically, uses).
- **Total variation (TV)** — sum of image-gradient sizes = "total climb": a sharp step costs the same as a ramp, noise costs a lot → edges kept, noise removed. Pseudo-norm (= semi-norm): 0 for any constant image. Side effect: **staircasing** (ramps → terraces); contrast loss.
- **Isotropic vs anisotropic TV** — isotropic (ℓ₂,₁, "same in every direction") = true gradient length per pixel; anisotropic (ℓ₁) = |D_x|+|D_y|, overcharges diagonal edges by up to √2. "Better: isotropic; easier: anisotropic."

**Solvers**
- **Adam** — gradient descent with momentum (each step follows a running average of past gradients, like a rolling ball) + per-pixel step normalized by typical gradient size → step ≈ α regardless of scale.
- **Splitting** — give the prior its own copy z with constraint Kx − z = 0 (K = D, the finite-difference operator of E3, for TV; K = I, the identity, for a denoiser; this K is not Week 5's OTF K); data part and prior part each become easy.
- **Lagrange multiplier y** (= dual variable = shadow price: a price charged per unit of constraint violation Kx − z) → Lagrangian (cost + y·violation) → **augmented Lagrangian** (adds (ρ/2)‖Kx − z‖², ρ = penalty parameter) → **scaled form** u = y/ρ.
- **ADMM** (= alternating direction method of multipliers) — data step (x), prior step (z), price step (u = running sum of mismatches Kx − z; drives them to 0).
- **Proximal operator** — "dog on a leash": best point for f near v. Prox of ℓ₁ = **soft thresholding** (shrink by the threshold κ = λ/ρ, stop at 0); isotropic TV → **block** soft thresholding (shrink arrow length, keep direction).
- **Plug-and-play (PnP) ADMM** — z-step with K = I is MAP denoising at σ² = λ/ρ → plug in any denoiser (DnCNN = a trained neural-network denoiser; NLM = non-local means, Week 3). Slide 98 ranking: Wiener worst; Adam+TV ≈ ADMM+TV; ADMM+DnCNN best.
- **HQS** (= half-quadratic splitting = quadratic penalty method) — ADMM without u; exact only as ρ → ∞, very ρ-sensitive. **Unrolled optimization** (= algorithm unrolling = deep unfolding) — K iterations as network layers, learn λ⁽ᵏ⁾, ρ⁽ᵏ⁾.

**Compressive imaging**
- **Single-pixel camera** — DMD (digital micromirror device: a chip of tiny tilting mirrors that displays a pattern) shows M patterns, one photodiode sums light through each: b = Ax + η. **Compressive** = under-determined = M < N (fewer measurements than the N scene pixels); compression factor N/M. (Measurement matrix = sensing matrix = A.)
- **Least-norm solution** (= minimum-norm = pseudoinverse A⁺b, the generalized "inverse" for a non-square A) — shortest exact fit; weighted sum of patterns, zero null-space part → looks like speckle. Computed via CG on (AAᵀ)w = b, then x = Aᵀw.
- **Conjugate gradients (CG)** — solves SPD (symmetric positive definite: symmetric, with all eigenvalues > 0; not Week 3's spectral power distribution) systems with one matrix-vector product per step (works with function handles `Afun`/`Atfun`, functions that compute Ax and Aᵀy without storing A; no matrix inverse).
- **Compressive LiDAR** (= single-pixel LiDAR) — single-pixel camera + timing detector; histogram per pattern; one single-pixel problem per **time bin** (= range bin). Poisson photon counts change the data term; TV on depth avoids **flying pixels** (= mixed pixels: pixels on an object's edge that get a false depth between foreground and background).
- **CT / MRI / hyperspectral** (CT = X-ray computed tomography; MRI = magnetic resonance imaging; hyperspectral = an image with many narrow wavelength bands per pixel, not just RGB) — same objective, different A: CT projections = slices of the 2D spectrum (Fourier slice = projection-slice theorem); MRI samples k-space (Fourier coefficients) directly; CASSI (coded aperture snapshot spectral imager) = mask + disperser (a prism that spreads wavelengths sideways) + sum onto one sensor. Priors can **hallucinate**.
- **"Frequency" this week** always = **image frequency** (cycles/pixel) in the FFT formulas; LiDAR uses time (ns), not frequency.

### Key equations
#### E1. MAP objective (Gaussian likelihood + prior)
```
x_MAP = argmin_x (1/(2σ²)) ‖b − A x‖₂² + Ψ(x)   ⇔   argmin_x ½ ‖b − A x‖₂² + λ Ψ(x),   Ψ(x) = −log p(x)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x | unknown image, N pixel values | intensity | estimated |
| b | M measurements | intensity | measured |
| A | M×N image-formation matrix | — | fixed by setup |
| σ | Gaussian noise std. dev. | intensity | fixed by sensor |
| Ψ(x) | regularizer = −log prior | unitless | you choose (TV, ‖x‖₁, denoiser) |
| λ | regularization weight (≈ σ² × prior strength) | — | you choose |
| ‖·‖₂² | squared ℓ₂ norm Σ vᵢ² | — | — |
*Use it when:* turning any noise model + belief into an objective. *Gotcha:* Gaussian prior x ∼ 𝒩(0, τ²) (x drawn from a bell curve with mean 0 and standard deviation τ) gives Tikhonov with λ = σ²/τ²; HW-style code may drop the ½ (then λ means half as much).

#### E2. Norms
```
‖v‖₂ = √(Σ vᵢ²)      ‖v‖₁ = Σ |vᵢ|      "ℓ₀" = number of nonzero entries
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| v | any vector (pixels, gradients, residual) | same as entries | — |
| vᵢ | i-th entry | same | — |
*Use it when:* choosing a prior: ℓ₁ → sparse, ℓ₂ → spread out. *Gotcha:* "ℓ₀" is not a norm (not scale-homogeneous: doubling v doesn't double its count); TV is only a pseudo-norm.

#### E3. Finite differences and total variation
```
(D_x x)[r,s] = x[r,s+1] − x[r,s]        (D_y x)[r,s] = x[r+1,s] − x[r,s]
TV_aniso(x) = Σᵢ ( |(D_x x)ᵢ| + |(D_y x)ᵢ| )        TV_iso(x) = ‖D x‖₂,₁ = Σᵢ √( (D_x x)ᵢ² + (D_y x)ᵢ² )
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x[r,s] | pixel at row r, column s | intensity | unknown |
| D_x, D_y | horizontal / vertical forward-difference operators (kernels [−1, 1]) | — | fixed |
| D | [D_x; D_y] stacked, 2N×N | — | fixed |
| i | pixel index, 1…N | — | — |
| ‖·‖₂,₁ | ℓ₂ of each pixel's 2-vector, then ℓ₁ sum | — | — |
*Use it when:* scoring "flat regions + sharp edges." *Gotcha:* FFT version wraps around (circular boundary); in PyTorch avoid `torch.sqrt` (NaN = "not a number" gradient at 0, because √'s slope is infinite there).

#### E4. Augmented Lagrangian, scaled form
```
L_ρ(x, z, y) = f(x) + g(z) + yᵀ(K x − z) + (ρ/2) ‖K x − z‖₂²
            = f(x) + g(z) + (ρ/2) ‖K x − z + u‖₂² − (ρ/2) ‖u‖₂²,     u = y/ρ
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| f(x) | data term ½‖b − Ax‖² | — | fixed by setup |
| g(z) | λΨ(z), regularizer on split variable | — | you choose |
| K | K = D (TV) or I (denoiser) | — | your choice of prior |
| z | split variable (copy of Kx) | as Kx | computed |
| y | Lagrange multiplier (dual variable, shadow price) | — | computed |
| u | scaled dual variable y/ρ | as Kx | computed |
| ρ | penalty parameter, > 0 | — | you choose |
*Use it when:* deriving the ADMM steps (complete the square). *Gotcha:* −(ρ/2)‖u‖² never affects the x- or z-step.

#### E5. ADMM updates
```
x ← argmin_x f(x) + (ρ/2) ‖K x − v‖₂²,   v = z − u        (data step)
z ← argmin_z g(z) + (ρ/2) ‖v − z‖₂²,     v = K x + u      (prior step)
u ← u + K x − z                                           (price step)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| x | image (N values) | intensity | computed |
| z | split variable (2N for TV) | intensity/px | computed |
| u | running sum of mismatches Kx − z | intensity/px | computed |
| v | target handed to each step (different in each) | — | computed |
| f, g, K, ρ | as in E4 | — | as in E4 |
*Use it when:* any "data term + λΨ" problem where each part alone is easy. *Gotcha:* z-step uses the *new* x; HQS = same loop with u ≡ 0.

#### E6. Proximal operator and soft thresholding
```
prox_{λf}(v) = argmin_x f(x) + (1/(2λ)) ‖x − v‖₂²
S_κ(v) = v − κ if v > κ;  0 if |v| ≤ κ;  v + κ if v < −κ  = max(1 − κ/|v|, 0)·v,    κ = λ/ρ
block (isotropic TV):  zᵢ = max(1 − κ/‖vᵢ‖₂, 0) · vᵢ
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| v | input point (TV: Dx + u entry) | as z | computed |
| f | function made small | — | — |
| λ (in prox only) | leash length / step size = 1/ρ in ADMM (not the regularization weight) | — | — |
| κ | threshold = regularization λ ÷ ρ | as v | from your λ, ρ |
| S_κ(v) | new z entry | as v | computed |
| vᵢ | pixel i's 2-vector of (D_x x + u, D_y x + u) | as v | computed |
*Use it when:* z-step for an ℓ₁ or TV prior. *Gotcha:* entries with |v| ≤ κ become exactly 0 — this is where sparsity comes from.

#### E7. TV-deconvolution x-update in the Fourier domain
```
(CᵀC + ρ DᵀD) x = Cᵀb + ρ Dᵀv,   v = z − u
x = F⁻¹{ [F{c}*·F{b} + ρ(F{d_x}*·F{v₁} + F{d_y}*·F{v₂})] / [ |F{c}|² + ρ(|F{d_x}|² + |F{d_y}|²) ] },   |F{d_x}|² = 4 sin²(πk/N)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| C, c | blur matrix (circulant: each row is the row above shifted by one with wrap-around, i.e. circular convolution as a matrix) and its PSF kernel | — | known, fixed |
| b | blurry noisy photo | intensity | measured |
| D, d_x, d_y | gradient operator and its kernels | — | fixed |
| v₁, v₂ | horizontal / vertical halves of v = z − u | intensity/px | changes each iteration |
| ρ | penalty parameter | — | you choose |
| F, F⁻¹, * | 2D DFT, inverse, complex conjugate (= transpose in Fourier) | — | — |
| k, N | image-frequency index (cycles/N px) and row length in pixels (here N = image width, not the total pixel count N of E8) | — | — |
*Use it when:* data step for circulant blur — element-wise division per image frequency. *Gotcha:* denominator is constant → precompute once; PnP (K = I) replaces ρ|F{d}|² with ρ.

#### E8. Single-pixel model and least-norm solution
```
b = A x + η,  A ∈ ℝ^(M×N)  (A is a real-valued M×N matrix),  compression factor = N/M
x̃_ln = Aᵀ (A Aᵀ)⁻¹ b      (solve (A Aᵀ) w = b by CG, then x = Aᵀ w)
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| A | measurement matrix, one pattern aₘ per row | weights 0–1 | designer |
| x | scene, N pixels | intensity | unknown |
| b | M photodiode readings | intensity | measured |
| η | measurement noise | intensity | fixed by sensor |
| M, N | # measurements, # pixels | count | designer |
| AAᵀ | M×M pattern overlaps | — | computed |
| w | multipliers / pattern weights (size M) | — | computed |
*Use it when:* the plain exact fit of an under-determined system. *Gotcha:* exact but ignores the null space (N − M dims) → speckle; a prior (TV/DnCNN in ADMM) is needed. Single-pixel x-update (AᵀA + ρDᵀD)x = … has no FFT shortcut → CG every iteration.

#### E9. Compressive LiDAR
```
Δd = c Δt / 2          b[m, t] = Σ_p aₘ[p] · x[p, t]   ⇒   B = A X
```
| Symbol | Meaning | Units | You control / fixed |
|---|---|---|---|
| Δt | time-bin width | s | detector electronics |
| c | speed of light ≈ 3 × 10⁸ | m/s | fixed |
| Δd | depth slice per bin (/2 = round trip) | m | derived |
| aₘ[p] | pattern m's weight at pixel p | — | designer |
| x[p, t] | light pixel p returns in bin t | counts | unknown |
| A, X, B | patterns (M×N), scene cube (N×bins), histograms (M×bins) | — | designer / unknown / measured |
*Use it when:* depth imaging with one timing detector — each bin is a single-pixel problem sharing A. *Gotcha:* low photon counts → Poisson data term Σ[(Ax)ᵢ − bᵢ log(Ax)ᵢ], not least squares.

### Causal chains
1. Gaussian noise → −log likelihood is a squared error → data term ½‖b − Ax‖² → so: least squares is MAP with a flat prior.
2. Prior p(x) → Ψ = −log p(x) → added as λΨ, λ ∝ σ² → so: noisier data ⇒ trust the prior more.
3. ℓ₁ ball has corners on the axes → minimizer lands on a corner → exact zeros → so: ℓ₁ (and TV = ℓ₁ of gradients) gives sparse solutions; ℓ₂ only shrinks.
4. TV charges total climb, not steepness → step costs = ramp, noise wiggles cost a lot → so: edges survive, noise is removed (but slopes may staircase).
5. Data term easy alone (FFT), TV easy alone (per-pixel) but not together → split x/z with Kx = z → augmented Lagrangian → ADMM alternates two easy proxes + price u → so: exact constraint at moderate ρ (HQS without u needs ρ → ∞).
6. Blur matrix is circulant → CᵀC, DᵀD diagonal in Fourier → x-update = per-frequency division → so: no iterative solver; single-pixel A is random (not circulant) → CG needed.
7. M < N → infinite exact solutions (null space) → least norm sets null-space part to 0 → speckle → so: compressive imaging needs a prior; same recipe covers LiDAR (per time bin), CT, MRI, CASSI.

### Practice questions
**Q1. [Calc]** For v = [2.2, −0.7, 0, −2.6, 0.4]: (a) compute ‖v‖₂, ‖v‖₁, "ℓ₀". (b) Soft-threshold with κ = 1 and recompute all three. (c) Block soft-threshold the 2-vector (3, 4) with κ = 2.
<details><summary>Answer</summary>

(a) ‖v‖₂ = √(4.84 + 0.49 + 0 + 6.76 + 0.16) = √12.25 = **3.5**; ‖v‖₁ = 2.2 + 0.7 + 2.6 + 0.4 = **5.9**; ℓ₀ = **4**.  
(b) S₁(v): 2.2 → 1.2; −0.7 → 0 (|v| ≤ 1); 0 → 0; −2.6 → −1.6; 0.4 → 0 ⇒ **[1.2, 0, 0, −1.6, 0]**; ‖·‖₂ = √(1.44 + 2.56) = √4 = 2, ‖·‖₁ = 2.8, ℓ₀ = 2 (sparser).  
(c) ‖(3,4)‖ = 5; factor max(1 − 2/5, 0) = 0.6 ⇒ **(1.8, 2.4)** (length 3, same direction).

</details>

**Q2. [Calc]** 2×2 image x = [[0, 1], [2, 4]]. Use forward differences; where the next pixel does not exist, the difference is 0 (no wrap-around). Compute anisotropic and isotropic TV.
<details><summary>Answer</summary>

D_x x = [[1, 0], [2, 0]], D_y x = [[2, 3], [0, 0]].  
Per pixel (D_x, D_y): (1,2), (0,3), (2,0), (0,0).  
Anisotropic = 3 + 3 + 2 + 0 = **8**. Isotropic = √5 + 3 + 2 + 0 = **5 + √5 ≈ 7.24**. They differ only at the pixel with a diagonal gradient (1,2): 1 + 2 = 3 vs √(1 + 4) = √5 ≈ 2.24.

</details>

**Q3. [Calc]** One pixel, b = x + η with σ = 0.05, measured b = 0.6. (a) Gaussian prior x ∼ 𝒩(0, τ²), τ = 0.1: find λ in the form ½(b − x)² + (λ/2)x², and x_MAP. (b) Laplace prior p(x) ∝ exp(−|x|/β), β = 0.02: find λ in ½(b − x)² + λ|x|, and x_MAP.
<details><summary>Answer</summary>

(a) Multiply (1/(2σ²))(b − x)² + x²/(2τ²) by σ²: λ = σ²/τ² = 0.0025/0.01 = **0.25**; setting the derivative −(b − x) + λx to 0 gives x = b/(1 + λ) = 0.6/1.25 = **0.48**.  
(b) Ψ = |x|/β; × σ²: λ = σ²/β = 0.0025/0.02 = **0.125**; x_MAP = S_{0.125}(0.6) (minimizing ½(b − x)² + λ|x| is exactly the ℓ₁ prox, i.e. soft thresholding by κ = λ) = **0.475** (soft threshold: shifts by λ instead of scaling).

</details>

**Q4. [Calc]** (a) Least-norm solution of A = [[1, 1, 0], [0, 1, 1]], b = [3, 5]. Check it against the exact solution [0, 3, 2]. (b) A single-pixel camera images 128×128 pixels at compression factor 8: M, null-space dimension, fraction measured?
<details><summary>Answer</summary>

(a) AAᵀ = [[2, 1], [1, 2]]; solve 2w₁ + w₂ = 3, w₁ + 2w₂ = 5 → w = [1/3, 7/3]; x = Aᵀw = [w₁, w₁ + w₂, w₂] = **[1/3, 8/3, 7/3]**. Check Ax = [9/3, 15/3] = [3, 5] ✓. Compare squared norms (no roots needed): ‖x‖² = (1 + 64 + 49)/9 = 114/9 ≈ 12.7 < ‖[0, 3, 2]‖² = 13, so it is the shortest exact fit.  
(b) N = 16384; M = 16384/8 = **2048**; null space ≥ N − M = **14336** dims; measured fraction **12.5%**.

</details>

**Q5. [Calc]** ADMM on a scalar: minimize ½(x − 5)² + 2|x| with K = 1, ρ = 1, starting x = z = u = 0. Give x, z, u after iterations 1 and 2, and the exact minimizer.
<details><summary>Answer</summary>

x-step: minimizing ½(x − 5)² + ½(x − v)² (derivative = 0) gives x = (5 + v)/2, v = z − u. z-step: z = S_{λ/ρ = 2}(x + u). u ← u + x − z.  
It 1: x = (5 + 0)/2 = 2.5; z = S₂(2.5) = 0.5; u = 0 + 2.5 − 0.5 = 2.0.  
It 2: v = 0.5 − 2 = −1.5, x = 1.75; z = S₂(3.75) = 1.75; u = 2 + 0 = 2.0.  
(It 3: 2.375, it 4: 2.6875 — gap to the answer halves each step.) Exact: S₂(5) = **3**; u settles at λ/ρ = **2**.

</details>

**Q6. [Calc]** TV-deconvolution x-update at a single image frequency (cycles/pixel): F{c} = 0.5 (real), F{b} = 0.4, ρ = 2, horizontal index k = 2 with N = 8, vertical index 0, and the gradient numerator term F{d_x}\*F{v₁} + F{d_y}\*F{v₂} = 0.3. Compute F{x}, and compare with the inverse filter F{b}/F{c}.
<details><summary>Answer</summary>

|F{d_x}|² = 4 sin²(π·2/8) = 4 · 0.5 = 2; |F{d_y}|² = 4 sin²(0) = 0.
Numerator = 0.5·0.4 + 2·0.3 = 0.8. Denominator = 0.25 + 2·(2 + 0) = 4.25.  
F{x} = 0.8/4.25 = **16/85 ≈ 0.19** vs inverse filter 0.4/0.5 = **0.8**: the ρ·DᵀD high-pass term damps this frequency heavily and the prior's v pulls it toward the preferred gradients.

</details>

**Q7. [Concept]** Why does the ℓ₁ prior (or TV) produce exact zeros while an ℓ₂² prior only shrinks values? Answer via both the geometry and the "pull toward 0".
<details><summary>Answer</summary>

Geometry: the ℓ₁ ball is a diamond with corners on the axes; the solution set first touches it at a corner, where coordinates are 0. The ℓ₂ ball is round, so it touches at a generic point. Pull: ½t² pulls with force ∝ t (vanishes near 0, never reaches 0); |t| pulls with constant force, so small values are pushed all the way to 0 (soft thresholding sets |v| ≤ κ to 0). TV applies this to image gradients → flat regions with a few sharp edges.

</details>

**Q8. [Concept]** In ADMM, what does u represent, and why does HQS (no u) need ρ → ∞ while ADMM works at moderate ρ?
<details><summary>Answer</summary>

u is the running sum of past mismatches Kx − z (scaled multiplier y/ρ). While a mismatch persists, u keeps growing and shifts the targets v until Kx = z exactly — like a thermostat integrating error. HQS only has the penalty (ρ/2)‖Dx − z‖², which leaves a residual mismatch for any finite ρ, so it is exact only as ρ → ∞ and is very sensitive to ρ (needs a growing schedule).

</details>

**Q9. [Concept]** Why is the TV-deconvolution x-update a one-shot FFT division, while the single-pixel camera's x-update needs conjugate gradients every ADMM iteration?
<details><summary>Answer</summary>

Circular blur C and gradients D are circulant → diagonal in the Fourier domain → CᵀC + ρDᵀD becomes per-frequency |F{c}|² + ρ(|F{d_x}|² + |F{d_y}|²), so solving = element-wise division. The single-pixel A is random (not circulant), so AᵀA + ρDᵀD has no Fourier diagonalization; it is solved iteratively with CG, which needs only matrix-vector products via `Afun`/`Atfun`.

</details>

**Q10. [Concept]** (a) In plug-and-play ADMM, what noise level is the denoiser asked to remove, and what happens if λ is increased? (b) Why does the least-norm single-pixel reconstruction look like speckle, and how does compressive LiDAR reuse the same machinery?
<details><summary>Answer</summary>

(a) With K = I the z-step is argmin Ψ(z) + (1/(2σ²))‖v − z‖² with σ² = λ/ρ: MAP denoising at variance λ/ρ. Larger λ → larger σ² → stronger denoising (smoother, more prior-driven, risk of hallucination/lost detail).  
(b) Least norm = weighted sum of random patterns with the null-space part (N − M dims) set to 0 → random-looking speckle; nothing says "look like an image." Compressive LiDAR: histogram per pattern, B = AX; each time bin (Δd = cΔt/2) is its own single-pixel problem with the same A, solved with ADMM + a prior (ℓ₁ per slice, TV on depth).

</details>

> **Summary**
> - Every problem this week is **minimize ½‖b − Ax‖₂² + λΨ(x)**: Gaussian likelihood → data term, prior → Ψ = −log p(x), λ grows with noise.
> - ℓ₁ gives exact zeros; TV = ℓ₁ of image gradients keeps edges and removes noise (isotropic treats all directions equally).
> - ADMM: x ← data prox, z ← prior prox (soft threshold, κ = λ/ρ, or a denoiser at σ² = λ/ρ), u ← u + Kx − z; Fourier division for blur, CG for random A.
> - Compressive imaging (M < N) needs a prior — least norm alone is speckle; the same recipe covers single-pixel LiDAR, CT, MRI, hyperspectral.

