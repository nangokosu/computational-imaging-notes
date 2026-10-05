# CSC2529 — Running Formula Reference

A single, cumulative reference of every load-bearing formula from the course, grouped by the week it's introduced in. Where `glossary.md` is organized around *terms*, this file is organized around *formulas*: each entry gives the formula exactly as written in that week's notes, a term-by-term table (what each symbol means, its units where relevant, and whether it's something you control or something fixed by the setup), and a one-sentence "Computes" line stating what real-world or computational quantity it produces.

This covers formulas substantial enough to get the full "Equations" treatment (intuition, term-by-term breakdown, diagram if geometric) in that week's notes — not every one-off numeric substitution inside a worked example. For the full derivation and intuition behind any formula here, follow its link back to the week's notes; for the diagram that goes with a geometric one, see the [running artifact](https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0).

**How this file is maintained:** every time a new week's study notes are written, append that week's formulas as a new `## Week N` section below, in the order they appear in the notes. Never delete or renumber an existing week's entries — later weeks may reuse or build on an earlier formula, but the original entry stays as the reference.

---

## Week 1 — Human Visual System
*(full derivations and diagrams in [`week1-study-notes.md`](./week1-study-notes.md); this is the lookup-speed reference)*

### Cone response as a linear map (§6)

```
c = C s
C n = 0
```

**Computes:** Converts a full light spectrum into the eye's three cone responses, and defines exactly which spectral differences (metamers) the eye cannot tell apart.

| Term | Meaning |
|---|---|
| c | 3-entry vector of cone responses (L, M, S); the eye's output measurement |
| C | 3×N matrix whose rows are the three cone types' sensitivity curves sampled at N wavelengths; fixed by human physiology |
| s | N-entry vector of the incoming light's spectral power sampled at N wavelengths; the input, set by the scene/light source |
| n | a spectrum-difference vector in the null space of C; any two spectra s and s+n are metamers (look identical) |

---

### Visual angle → resolvable pixel size, and its dpi corollary (§9)

```
p = 2 · d · tan(α / 2)
dpi = 1 inch / p
```

**Computes:** Gives the physical size of the smallest pixel the eye can resolve at a given viewing distance (and, inverted, the pixel density — dpi — at which a screen becomes "retina").

| Term | Meaning |
|---|---|
| p | physical size (length, e.g. inches) of the smallest resolvable pixel/feature; computed output |
| d | viewing distance from eye to screen; set by the use case, not fixed |
| α | the eye's minimum resolvable visual angle (≈1 arcminute for 20/20 vision); fixed by visual acuity |
| dpi | pixel density (pixels per inch); the reciprocal of p, more intuitive to compare screens by |

---

### Stops and light ratio (§14)

```
stops = log₂(ratio)          ratio = 2^stops
```

**Computes:** Converts between a brightness or light ratio (e.g. 16×) and the photographer's count of doublings ("4 stops"), including the signed "+2 / −4" exposure-compensation notation (+2 = 4× the light, −4 = 1/16).

| Term | Meaning |
|---|---|
| ratio | how many times more (or, below 1, fewer) light, or brighter/darker, one quantity is than another; dimensionless; set by scene or settings |
| stops | the same comparison counted as doublings (positive) or halvings (negative); also the unit of exposure compensation, written EV; chosen by you on the camera dial |
| 2 | the base, because one stop is by definition a factor of 2; fixed by definition |

---

### Image frequency → physical spatial frequency (§16.4)

```
physical spatial frequency (cycles/inch) = image frequency (cycles/pixel) × dpi (pixels/inch)
```

**Computes:** Converts a digital image's fixed cycles-per-pixel frequency into a real-world cycles-per-inch frequency once a print/display density is chosen.

| Term | Meaning |
|---|---|
| physical spatial frequency | how fast brightness varies per unit physical length once printed/displayed (cycles/inch); computed output |
| image frequency | how fast brightness varies per pixel in the digital file (cycles/pixel); fixed property of the pixel data alone |
| dpi | pixel density at which the image is printed/displayed (pixels/inch); chosen by whoever prints/displays it |

---

### Weber contrast (§17)

```
C_weber = (I_feature − I_background) / I_background
```

**Computes:** Measures the contrast of a single, small feature against a large uniform background.

| Term | Meaning |
|---|---|
| C_weber | Weber contrast value (dimensionless); computed output |
| I_feature | luminance/intensity of the single small feature being judged; measured |
| I_background | luminance/intensity of the surrounding uniform background; measured |

---

### Michelson contrast (§17)

```
C_michelson = (I_max − I_min) / (I_max + I_min)
```

**Computes:** Measures the contrast of a repeating/periodic pattern (e.g. a sinusoidal grating), where there is no single well-defined background.

| Term | Meaning |
|---|---|
| C_michelson | Michelson contrast value (dimensionless); computed output |
| I_max | brightest luminance in the periodic pattern (light stripes); measured |
| I_min | darkest luminance in the periodic pattern (dark stripes); measured |

---

### 2D sinusoidal grating (§19.2)

```
I(x, y) = A · cos(2π(u·x + v·y) + φ)
```

**Computes:** Describes a single repeating stripe pattern (grating) of given orientation, spacing, contrast, and shift — the basic wave building block every image is decomposed into by the 2D Fourier transform.

| Term | Meaning |
|---|---|
| I(x, y) | brightness at pixel coordinates (x, y); the grating's output value |
| A | amplitude of the grating (contrast/strength); controllable |
| x, y | horizontal/vertical pixel coordinates; independent variables scanning the image |
| u | horizontal image frequency, cycles/pixel scanning left-right |
| v | vertical image frequency, cycles/pixel scanning up-down |
| φ | phase — where the stripes sit (shift); controllable |

---

### DFT array index → cycles per pixel (§19.3)

```
u = k_u / W      v = k_v / H
```

**Computes:** Converts `fft2`'s raw integer array-index output into actual image frequency in cycles per pixel, accounting for image width/height.

| Term | Meaning |
|---|---|
| u, v | actual image frequency, cycles per pixel (the same u, v used in the grating formula); computed output |
| k_u, k_v | raw integer positions in the fft2 output array; plain indices, not physical units |
| W, H | image width and height in pixels; fixed by the image's dimensions |

---

### Discrete 1D convolution (§20.2)

```
(x * h)[n] = sum over m of  h[m] · x[n − m]
```

**Computes:** The filtered or blurred signal obtained by stamping a copy of the kernel h, scaled by each input value, at every input position and adding the stamps (equivalently, a weighted neighborhood sum with the kernel reversed); the operation behind blur, PSFs, Gaussian smoothing, and LiDAR pulse smearing.

| Term | Meaning |
|---|---|
| x[j] | input signal value at position j (e.g. a pixel's brightness); fixed by the scene |
| h[m] | kernel weight at offset m (unitless); you design it, or the optics impose it (normalized so the weights sum to 1 to conserve brightness) |
| n | output position being computed; the index you loop over |
| m | offset into the kernel; summation variable |
| (x*h)[n] | output at position n, in the signal's own units; computed |
| * | convolution operator (the kernel is reversed relative to the signal; cross-correlation is the same without the reversal) |

Worked check (§20.3): x = [1, 3, 2, 5, 4], h = [¼, ½, ¼] gives the full output [0.25, 1.25, 2.25, 3.00, 4.00, 3.25, 1.00] (length N + K − 1 = 7).

---

### Convolution theorem (§20.7)

```
DFT{ x * h } = DFT{ x } · DFT{ h }      (entry-by-entry product, one frequency at a time)
```

**Computes:** The spectrum of a convolved (blurred or filtered) signal as the input's spectrum scaled, frequency by frequency, by the kernel's own spectrum (its frequency response); exact for circular convolution, and for ordinary convolution after zero-padding both to at least N + K − 1 samples.

| Term | Meaning |
|---|---|
| DFT{x} | spectrum of the input: how much of each wave is present; fixed by the scene |
| DFT{h} | kernel's spectrum (frequency response): unitless scale factor per frequency, 1 = passes unchanged, 0 = erased; set by the kernel you choose or the optics (it is the eigenvalue of the convolution matrix at that frequency) |
| DFT{x*h} | spectrum of the output; computed |
| · | ordinary multiplication at each frequency (not a convolution) |

Worked check: x = [3, 1, −1, 1] with kernel [½, ¼, 0, ¼]: [4, 4, 0, 4] × [1, ½, 0, ½] = [4, 2, 0, 2], whose inverse DFT is the circular convolution [2, 1, 0, 1]. Dividing the output spectrum by DFT{h} undoes the blur (the inverse filter of Week 1 §23), which fails where DFT{h} is zero and amplifies noise where it is small.

---

### Hybrid-image frequency-domain combination (§22.2)

```
F_hybrid(u, v) = H_A(u, v) + L_B(u, v)
```

**Computes:** Builds a hybrid image's spectrum by adding Image A's high-frequency (fine detail) content to Image B's low-frequency (coarse structure) content, per color channel, before inverse-transforming back to pixels.

| Term | Meaning |
|---|---|
| F_hybrid(u, v) | combined spectrum of the hybrid image at frequency (u, v); later inverse-transformed to recover pixel values |
| H_A(u, v) | Image A's spectrum after a high-pass mask (keeps only high image frequencies) |
| L_B(u, v) | Image B's spectrum after a low-pass mask (keeps only low image frequencies) |

---

### Hybrid image as a sum of projections (§22.2)

```
hybrid = P_high a + P_low b
```

**Computes:** Restates the hybrid-image construction as a sum of two orthogonal projections in the Fourier basis — the linear-algebra equivalent of the frequency-domain mask-and-add procedure above.

| Term | Meaning |
|---|---|
| hybrid | resulting hybrid image, as a pixel-value vector; computed output |
| a | Image A, as a pixel-value vector; input |
| b | Image B, as a pixel-value vector; input |
| P_high | high-pass projection matrix, keeps high-frequency sinusoid components; equals I − P_low |
| P_low | low-pass projection matrix, keeps low-frequency sinusoid components |

---

---

## Week 2 — Digital Photography I (ray optics, aperture, sensor)
*(full derivations and diagrams in [`week2-study-notes.md`](./week2-study-notes.md); this is the lookup-speed reference)*

### Image formation as a linear map (§1)

```
y = A x
```

**Computes:** Models every sensor reading as a weighted sum of scene-point brightnesses, explaining why a bare sensor with no optics in front of it produces one heavily blurred smear rather than a picture.

| Term | Meaning |
|---|---|
| y | vector of sensor readings, one entry per sensor location — what you actually measure |
| A | matrix of cosine-and-distance weights from each scene point to each sensor location — fixed by the geometry/optics, not chosen |
| x | vector of true scene-point brightnesses, one entry per scene point — unknown, what you want to recover |

---

### Perspective projection (pinhole camera matrix) (§2)

```
P = [[−f, 0, 0, 0], [0, −f, 0, 0], [0, 0, 1, 0]]
(X, Y, Z, 1) → P·(X,Y,Z,1) = (−fX, −fY, Z) → divide by Z → (−fX/Z, −fY/Z)
```

**Computes:** Gives the 2D sensor position where a 3D scene point projects through a pinhole, in one linear step followed by one division — and shows why depth is lost (every point along one ray lands on the same pixel).

| Term | Meaning |
|---|---|
| P | 3×4 camera matrix built from the pinhole geometry — fixed once f is fixed |
| X, Y, Z | scene point's coordinates: sensor-horizontal, sensor-vertical, depth along the optical axis — property of the scene |
| f | focal length, pinhole-to-image-plane distance — intrinsic, fixed |
| (−fX/Z, −fY/Z) | resulting 2D sensor position |
| division by Z | the "perspective divide"; collapses every point on the same ray to one pixel, which is why one photo can't recover depth |

---

### Optimal pinhole diameter (§3.1)

```
blur(d) ≈ d + fλ/d
d = 2√(fλ)
```

**Computes:** Gives the pinhole diameter that minimizes total image blur by balancing geometric blur (grows with diameter) against diffraction blur (shrinks with diameter) — the size to drill for the sharpest possible pinhole camera.

| Term | Meaning |
|---|---|
| d | pinhole diameter — the quantity being solved for/chosen |
| f | pinhole-to-image-plane distance (focal length) — fixed by the box geometry |
| λ | wavelength of light being imaged — fixed by the light source |
| blur(d) | predicted total blur size on the sensor: geometric-blur term (d) plus diffraction-blur term (fλ/d) |

---

### Thin lens equation (Gaussian lens formula) (§5.1, §5.3)

```
1/S + 1/S' = 1/f
S = 1 / (1/f − 1/S')
```

**Computes:** Relates where an object sits, where its sharp image forms, and the lens's fixed focal length; used to find the sensor distance needed to focus on a known object distance, or (rearranged) which object distance is currently in focus for a given sensor distance.

| Term | Meaning |
|---|---|
| S | object distance, lens to subject — property of the scene |
| S' | sensor (image) distance, lens to sharp-image plane — property of the setup, set by the focus ring |
| f | focal length — intrinsic, fixed property of the lens |

---

### Magnification (§5.1)

```
m = y'/y = (S' − f)/f = S'/S
```

**Computes:** Gives the ratio of image height to object height a lens produces — how much bigger or smaller the sensor image is than the real object.

| Term | Meaning |
|---|---|
| m | magnification (dimensionless ratio) |
| y | object height above the lens's central axis |
| y' | image height below the axis (image is inverted) |
| S, S', f | as in the thin lens equation |

---

### Ray-transfer (ABCD) matrices (§5.1, Linear-algebra view)

```
Translation by distance L:   [[1, L], [0, 1]]
Thin lens of focal length f: [[1, 0], [−1/f, 1]]
```

**Computes:** Represents ray propagation and lens bending as 2×2 matrices acting on a ray's (height, angle) vector; multiplying object-to-lens, lens, and lens-to-sensor matrices reproduces the thin lens equation as the condition that the product's top-right entry equals zero.

| Term | Meaning |
|---|---|
| L | distance travelled (object-to-lens or lens-to-sensor) — set by the setup |
| f | focal length — intrinsic |
| height | ray's height above the optical axis (top vector entry) |
| angle | ray's angle to the axis, small-angle approximation (bottom vector entry) |

---

### Field of view (§7)

```
FOV = 2 · arctan(d / (2f))
```

**Computes:** Gives the angular extent of scene a lens/sensor combination captures, from the sensor's physical size and the lens's focal length.

| Term | Meaning |
|---|---|
| FOV | angular field of view |
| d | sensor's physical width or height — fixed by the camera body |
| f | focal length — intrinsic to the lens |

---

### F-number (§8)

```
N = f / D
```

**Computes:** Gives the standard "f/N" aperture rating, expressing aperture size relative to focal length so light-gathering and diffraction behavior compare across different lenses.

| Term | Meaning |
|---|---|
| N | f-number (dimensionless) |
| f | focal length — intrinsic |
| D | aperture diameter — setup-chosen, capped by the lens's maximum aperture |

---

### Stops between two f-numbers (§8)

```
stops = 2 · log₂(N₂ / N₁)          N_k = N₀ · 2^(k/2)
```

**Computes:** The number of stops of light lost (positive) or gained (negative) in going from f-number *N*₁ to *N*₂, and the f-number reached *k* stops from a starting *N*₀.

| Term | Meaning |
|---|---|
| N₁, N₂ | starting and new f-numbers; dimensionless; set by you via the aperture ring |
| N₀ | starting f-number for the stepping formula; set by you |
| k | number of stops stepped (negative = wider aperture); a third-stop click is k = ±1/3 |
| 2 in front | because light ∝ aperture area ∝ 1/N², so squaring *N* doubles the log |

---

### Circle of confusion (§9.2)

```
c = m · D · |O − S| / O
```

**Computes:** Gives the diameter of the blur disc that a defocused scene point forms on the sensor.

| Term | Meaning |
|---|---|
| c | circle-of-confusion diameter (a length, e.g. mm) |
| m | magnification at the focused pair (S, S') |
| D | aperture diameter |
| O | actual distance of the scene point — fixed by the scene |
| S | currently-focused object distance — set by the focus ring |

---

### Depth of field (§10.1)

```
DOF = 2 · ε · S / (m · D)
```

**Computes:** Gives the range of actual object distances that stay acceptably sharp (circle of confusion below threshold ε) for a given focus setting.

| Term | Meaning |
|---|---|
| DOF | depth-of-field range (a length) |
| ε | acceptable circle-of-confusion threshold, as a length |
| S | focused object distance |
| m | magnification at the focused pair |
| D | aperture diameter |

---

### Converting a pixel blur threshold to a length (§10.2)

```
pixel pitch = sensor width / number of pixels across that width
ε (length) = ε (pixels) × pixel pitch
```

**Computes:** Converts an acceptable blur threshold stated in pixels into the physical length unit that the circle-of-confusion and depth-of-field formulas require.

| Term | Meaning |
|---|---|
| pixel pitch | center-to-center spacing of sensor pixels, a length — fixed by the camera |
| sensor width | physical width of the sensor — fixed by the camera |
| number of pixels | pixel count across that width — fixed by the camera |
| ε (pixels) | acceptable blur threshold stated in pixels — a chosen tolerance |
| ε (length) | same threshold converted to a physical length |

---

### Near and far distance of depth of field (§10.3)

```
O_near = S / (1 + k)
O_far  = S / (1 - k)
k = ε / (m·D)
```

**Computes:** Gives the two boundary object distances — near and far — where the depth-of-field range begins and ends in the scene, exactly (not just the range's width).

| Term | Meaning |
|---|---|
| O_near | near edge of the depth-of-field range — closer to the camera than S |
| O_far | far edge of the depth-of-field range — farther from the camera than S |
| S | focused object distance |
| k | dimensionless tolerance fraction, ε/(mD) |
| ε | acceptable circle-of-confusion threshold, as a length |
| m | magnification at the focused pair (S, S') — see the Magnification (§5.1) entry above for how to compute it |
| D | aperture diameter |

---

### Hyperfocal distance (§11)

```
H = f² / (N·c)
```

**Computes:** Gives the focus distance that extends the far edge of the depth of field all the way to infinity.

| Term | Meaning |
|---|---|
| H | hyperfocal distance |
| f | focal length — intrinsic |
| N | f-number — setup-chosen |
| c | fixed acceptable circle-of-confusion threshold (not the general variable of §9.2) |

**Note:** evaluating §10.3's near-distance formula O_near = S/(1+k) at S = H (where k = 1 by H's own definition) gives O_near(H) = H/2 — the classical "H/2 to infinity" depth-of-field rule.

---

### Diffraction limit (Abbe's formula) (§12)

```
d = λ / (2n·sinθ) = λ / (2·NA) ≈ λN
```

**Computes:** Gives the smallest resolvable spot size an optical system can produce due to diffraction alone — the best-case resolution floor even with zero aberrations.

| Term | Meaning |
|---|---|
| d | diffraction-limited spot size (resolution floor) |
| λ | wavelength of light being imaged |
| n | refractive index of the medium |
| θ | half-angle of the widest ray cone the lens accepts/emits |
| NA | numerical aperture, NA = n·sinθ |
| N | photographic f-number, via NA ≈ 1/(2N) |

---

### Approximate bokeh disc diameter (§13.2)

```
c ≈ (f² / N) · | 1/S − 1/O |
```

**Computes:** How wide the out-of-focus disc (bokeh ball) of a point at distance *O* is, on the sensor, when the lens is focused at *S*, valid when *S* is much larger than *f*; derived from the exact circle-of-confusion formula.

| Term | Meaning |
|---|---|
| c | blur-disc diameter on the sensor (length); computed |
| f | lens focal length (length); fixed by the lens |
| N | f-number, so aperture diameter D = f/N; chosen by you |
| S | distance the lens is focused at (length); chosen by you |
| O | actual distance of the blurred point (length); fixed by the scene |

---

### Noise-source variances in electrons (§18.3)

```
Var_shot = N        Var_dark = D·t        Var_read = Nr²        σ_DN = g · σ_electrons
```

**Computes:** The random variance each independent noise source contributes to one pixel, in electrons², and how a standard deviation converts from electrons to digital numbers.

| Term | Meaning |
|---|---|
| N | mean number of photo-electrons collected (P·Qe·t) — set by scene, sensor, exposure |
| D | dark-current rate (e⁻/pixel/s) — fixed by sensor and temperature |
| t | exposure time — you control this |
| Nr | RMS read noise (electrons), paid once per readout — fixed by the sensor |
| g | conversion gain (DN per electron) — set by ISO |

---

### Shot noise (Poisson statistics) (§18.4)

```
f(k; λ) = λᵏe⁻λ/k!
σ = √N
```

**Computes:** Describes the random arrival of photons and gives the resulting noise standard deviation for an average of N collected photons — the fundamental, unavoidable noise floor of any sensor.

| Term | Meaning |
|---|---|
| f(k; λ) | probability of observing exactly k photon arrivals given average rate λ |
| k | number of observed discrete events (photon arrivals) |
| λ | average event rate (mean photon count) |
| σ | standard deviation of the photon count (shot noise) |
| N | mean number of photons collected |

---

### Quantization noise variance (§18.5)

```
Var(u) = (1/Δ) · ∫ u² du  (u from −Δ/2 to +Δ/2)  =  Δ²/12
```

**Computes:** The noise variance added when an ADC rounds a continuous value to the nearest integer level, assuming the rounding error is uniform within one step.

| Term | Meaning |
|---|---|
| u | rounding error, in DN; uniform on [−Δ/2, +Δ/2] with mean 0 |
| Δ | quantization step in DN (1 DN for an integer ADC) — fixed by the ADC and gain |
| 1/Δ | probability density of the uniform error |

---

### Signal-to-noise ratio (§19)

```
SNR = P·Qe·t / √(P·Qe·t + D·t + Nr²)
```

**Computes:** Gives the ratio of mean recorded signal to its noise standard deviation, combining shot noise, dark current, and read noise into one measure of image quality.

| Term | Meaning |
|---|---|
| SNR | signal-to-noise ratio (dimensionless) |
| P | incident photon flux (photons per pixel per second) — fixed by scene brightness and optics |
| Qe | quantum efficiency — fraction of photons converted to electrons, fixed by the sensor |
| t | exposure time — you control this |
| D | dark current (electrons per pixel per second with no light) — fixed by the sensor |
| Nr | read noise (RMS electrons from readout electronics) — fixed by the sensor |

---

### Noise as an additive vector (§19, Linear-algebra view)

```
y = A x + n
```

**Computes:** Extends the ideal linear image-formation model to include sensor noise — the starting model for denoising and the inverse-problem methods of later weeks.

| Term | Meaning |
|---|---|
| y | actual noisy measurement vector |
| A | linear imaging operator (optics + sensor) |
| x | true scene vector |
| n | noise vector, one random entry per pixel, independent/uncorrelated across pixels |

---

## Week 3 — Digital Photography II (color science & the camera processing pipeline)
*(full derivations and diagrams in [`week3-study-notes.md`](./week3-study-notes.md); this is the lookup-speed reference)*

### Spectral sensitivity function (SSF) integral (§2)

```
R = ∫ Φ(λ) · f(λ) dλ

Discrete / inner-product form: R ≈ Δλ · Σ_k Φ(λ_k)·f(λ_k) = Δλ · (f · φ)
```

**Computes:** How much a light sensor (a retinal cone, a camera pixel) reports as its single output number when hit by a given light spectrum — the sensor's response as a weighted summary of the whole spectrum.

| Term | Meaning |
|---|---|
| R | The sensor's scalar output (e.g. a cone's firing rate, a photodiode's charge) — what gets measured |
| Φ(λ) | Incident light's spectral power distribution — power per unit wavelength; a property of the scene/illumination |
| f(λ) | The sensor's spectral sensitivity function — a property of the sensor (fixed by design), not the scene |
| λ | Wavelength; integral runs over the sensor's responsive range (~400–700 nm for visible-light sensors) |
| Δλ, φ, f (bold) | Discretization step and vectors used in the sampled/inner-product form |

---

### Tristimulus vector and the sensitivity matrix A (§3)

```
(S, M, L) = Δλ · A φ

Metamer condition: A(φ₁ − φ₂) = 0
```

**Computes:** Stacks the three cone SSFs into one matrix so a full spectrum becomes the eye's 3-number (S,M,L) response in one step; two spectra are metamers exactly when they differ by a vector A cannot see.

| Term | Meaning |
|---|---|
| A | 3×N matrix whose rows are the three cone SSFs sampled at N wavelengths — fixed by eye physiology |
| φ | Sampled spectrum vector (N wavelength samples) — the incident light |
| Δλ | Wavelength sampling step, a fixed constant of the discretization |
| S, M, L | The three cone responses — what's measured |
| φ₁, φ₂ | Two different light spectra being compared |
| null space of A | Dimension N−3 (rank–nullity); any spectral component in it changes the light but not the perceived color |

---

### Color matching as a linear system (§4)

```
c₁p₁ + c₂p₂ + c₃p₃ = t
P c = t
c = P⁻¹ t
```

**Computes:** Finds how much of each of three fixed primary lights an observer must mix to visually match a test light — turns "adjusting knobs until it looks right" into solving a 3×3 linear system.

| Term | Meaning |
|---|---|
| p₁, p₂, p₃ | (S,M,L) responses of the three primaries at unit strength — fixed choice of primaries |
| P | 3×3 matrix with p₁, p₂, p₃ as columns — the primary basis |
| c₁, c₂, c₃ (= c) | Matching coefficients solved for; negative if a primary had to be added to the test side instead |
| t | (S,M,L) response of the test light being matched |

---

### CIE RGB → XYZ conversion matrix (§5)

```
M_CIERGB→XYZ = (1/0.17697) · [0.49000  0.31000  0.20000]   = [2.7688  1.7517  1.1301]
                             [0.17697  0.81240  0.01063]     [1.0000  4.5906  0.0601]
                             [0.00000  0.01000  0.99000]     [0.0000  0.0565  5.5942]

v_XYZ = M_CIERGB→XYZ · v_CIERGB
```

**Computes:** Converts a color's coordinates from the CIE RGB basis (real primaries, sometimes-negative coordinates) to the CIE XYZ basis (non-negative coordinates for every real color, but imaginary primaries) — a pure change of basis.

| Term | Meaning |
|---|---|
| M_CIERGB→XYZ | Fixed 3×3 change-of-basis matrix, standardized by the CIE — not user-chosen |
| v_CIERGB | A color's coordinates in the CIE RGB basis |
| v_XYZ | The same color's coordinates in the CIE XYZ basis |
| middle row (1.0000, 4.5906, 0.0601) | Gives Y (luminance) as a fixed linear combination of R, G, B |

---

### CIE xy chromaticity projection (§6)

```
x = X / (X + Y + Z)
y = Y / (X + Y + Z)
```

**Computes:** Projects a 3D XYZ tristimulus value down to a 2D point representing pure hue/saturation, discarding luminance/brightness.

| Term | Meaning |
|---|---|
| X, Y, Z | CIE XYZ tristimulus coordinates of a color (Y carries luminance) |
| x, y | The two chromaticity coordinates — dimensionless ratios, roughly 0–1 for real colors |
| X + Y + Z | Normalizing denominator — "how far out along the ray from the origin" that gets divided away |

---

### Gamut triangle / barycentric coordinates (§7)

```
w_R·q_R + w_G·q_G + w_B·q_B = point,   w_R + w_G + w_B = 1,   w_R, w_G, w_B ≥ 0
```

**Computes:** Expresses a chromaticity point as a non-negative weighted average of a device's three primaries, so the weights themselves reveal whether the point is inside (all ≥0) or outside (any negative) the device's gamut.

| Term | Meaning |
|---|---|
| q_R, q_G, q_B | Chromaticity (xy) coordinates of the device's red, green, blue primaries — fixed by device/standard |
| w_R, w_G, w_B | Barycentric coordinates / mixing weights, found by solving a 3×3 linear system |
| point | The chromaticity (x,y) being tested or reconstructed |

---

### Display P3 → sRGB conversion matrix (§8)

```
M_P3→sRGB = M_XYZ→sRGB · M_P3→XYZ = [ 1.2249  −0.2249   0.0000]
                                    [−0.0421   1.0421   0.0000]
                                    [−0.0196  −0.0786   1.0983]
```

**Computes:** Converts RGB coordinates from the Display P3 primary basis to the sRGB primary basis by composing two changes of basis into one matrix — reveals which P3 colors (e.g. its green primary) fall outside sRGB's gamut.

| Term | Meaning |
|---|---|
| M_P3→sRGB | Combined 3×3 change-of-basis matrix, fixed by the two standards' primaries |
| M_XYZ→sRGB, M_P3→XYZ | The two individual change-of-basis matrices being composed (rightmost applied first) |
| middle column (−0.2249, 1.0421, −0.0786) | P3's green primary in sRGB coordinates — negative/>1 entries mean it's outside sRGB's gamut |

---

### Gamma correction — simple power law (§10)

```
I_out = I_in^(1/2.2)
```

**Computes:** Encodes a linear [0,1] intensity with a single power-law curve so finite bit-depth code values are spaced to match perceived brightness rather than physical intensity.

| Term | Meaning |
|---|---|
| I_in | Linear intensity value, scaled to [0,1] |
| I_out | Gamma-encoded output value |
| 1/2.2 | Encoding exponent — reciprocal of the human-sensitivity gamma (γ≈2.2) |

---

### Gamma correction — exact sRGB piecewise curve (§10)

```
C_sRGB = 12.92 · C_linear                          if C_linear ≤ 0.0031308
C_sRGB = (1 + α) · C_linear^(1/2.4) − α            if C_linear > 0.0031308,   α = 0.055
```

**Computes:** The sRGB standard's exact gamma-encoding curve — a linear segment near black joined to a power-law segment, together closely approximating a γ≈2.2 power law.

| Term | Meaning |
|---|---|
| C_linear | Linear-light input value, scaled to [0,1] |
| C_sRGB | sRGB-encoded output value |
| 0.0031308 | Fixed crossover threshold between the two segments |
| 12.92 | Slope of the linear segment near zero |
| 1/2.4 | Exponent of the power-law segment |
| α = 0.055 | Constant shaping the power-law segment to meet the linear one smoothly |

---

### General weighted-average denoising framework (§12.1)

```
i_denoised(x) = (1 / normalizer) · Σ_{x'} w(x, x') · i_noisy(x'),
normalizer = Σ_{x'} w(x, x')
```

**Computes:** The umbrella template every denoising method in this week specializes — average pixels believed to share the same true value, since random noise cancels under averaging while true signal doesn't.

| Term | Meaning |
|---|---|
| x | The pixel currently being denoised |
| x' | A candidate pixel, ranging over a neighborhood or search window |
| w(x,x') | Non-negative weight expressing how much x' should contribute to denoising x — this is what differs between methods |
| i_noisy, i_denoised | The noisy input and denoised output images |
| normalizer | Sum of all weights, making the result a true weighted average |

---

### Gaussian filter spatial weight (§12.2)

```
w(x, x') = exp( −|x − x'|² / (2σ²) )
```

**Computes:** Weights a neighboring pixel by spatial distance alone — the simplest denoising weight, equivalent to ordinary blurring/low-pass filtering.

| Term | Meaning |
|---|---|
| x, x' | Pixel positions |
| \|x − x'\| | Spatial distance between them, in pixels |
| σ | Spatial standard deviation, in pixels — the smoothing radius, user-controlled |

---

### Gaussian blur's frequency response (§12.2)

```
H(f) = exp( −f² / (2σ_f²) ),   σ_f = 1 / (2πσ)
```

**Computes:** Gives the fraction of each image frequency that survives a Gaussian blur of spatial width σ, explaining why a Gaussian blur is a smooth (no hard cutoff) low-pass filter.

| Term | Meaning |
|---|---|
| f | Image frequency, cycles per pixel |
| H(f) | Fraction of that frequency's amplitude surviving the blur (1 = untouched, 0 = removed) |
| σ | Blur's spatial width in pixels — chosen/controlled |
| σ_f | Resulting frequency-domain width, cycles per pixel — fixed once σ is chosen |

---

### Median filter (§12.3)

```
i_denoised(x) = median( W(i_noisy, x) )
```

**Computes:** Replaces each pixel with the median of a small surrounding window, removing outlier noise without smearing it into a halo the way an average would.

| Term | Meaning |
|---|---|
| x | The pixel being denoised |
| W(i_noisy, x) | The small window of the noisy image centered at x |
| median(...) | The window's middle value — a nonlinear operation, not a weighted sum |

---

### Mean squared error (MSE) (§13)

```
MSE = (1 / (3·m·n)) · Σ_{i=1}^{m} Σ_{j=1}^{n} Σ_{c=1}^{3} [I_estimate(i,j,c) − I_groundtruth(i,j,c)]²
```

**Computes:** The average squared per-pixel, per-channel error between a reconstructed image and ground truth — a single number summarizing reconstruction quality.

| Term | Meaning |
|---|---|
| m, n | Image height and width, in pixels |
| c | Color channel index (1 to 3) |
| I_estimate | The reconstructed/estimated image |
| I_groundtruth | The true reference image |
| 3·m·n | Total number of pixel-channel values, normalizing the sum into an average |

---

### Peak signal-to-noise ratio (PSNR) (§13)

```
PSNR = 10 · log₁₀( max(I_groundtruth)² / MSE )
```

**Computes:** Rescales MSE onto a self-normalizing, logarithmic (decibel) quality scale so reconstruction error is comparable regardless of the image's value range.

| Term | Meaning |
|---|---|
| MSE | Mean squared error (previous formula) |
| max(I_groundtruth) | Largest possible/occurring pixel value in the reference image (e.g. 255 for 8-bit, 1.0 for [0,1]) |
| 10·log₁₀(...) | Decibel scale — each fixed additive step corresponds to a fixed multiplicative change in the underlying ratio |

---

### Naive (linear) green-channel demosaicking (§14.1)

```
ĝ(x,y) = (1/4) · Σ g(x+m, y+n),   (m,n) ∈ {(0,−1), (0,1), (−1,0), (1,0)}
```

**Computes:** Estimates the missing green value at a non-green Bayer pixel by averaging its four nearest actually-measured green neighbors.

| Term | Meaning |
|---|---|
| ĝ(x,y) | Reconstructed (estimated) green value at pixel (x,y) — not directly measured there |
| g(x+m, y+n) | Measured green values at the four orthogonal neighboring pixels |
| (m,n) | The four neighbor offsets: up, down, left, right |

---

### Bayer mosaicking as a selection matrix (§14.1)

```
y = P_Bayer · x
```

**Computes:** Models the Bayer sensor's raw capture as a matrix that keeps exactly one color channel per pixel from the full-color image, discarding the other two — formalizes demosaicking as an underdetermined inverse problem.

| Term | Meaning |
|---|---|
| x | The true full-color image, flattened into one vector (every pixel's R,G,B) |
| P_Bayer | Selection matrix — one row per sensor pixel, a single 1 picking out that pixel's filtered color |
| y | The raw sensor mosaic actually measured (one number per pixel) |

---

### RGB ↔ Y′CbCr conversion (§14.3)

```
Y'  = 16  + 65.481·R + 128.553·G + 24.966·B
Cb  = 128 − 37.797·R − 74.203·G + 112.000·B
Cr  = 128 + 112.000·R − 93.786·G − 18.214·B

[R; G; B] = M⁻¹ · ([Y'; Cb; Cr] − [16; 128; 128])

Linear-algebra (affine) form:  u = M v + o,   v = M⁻¹(u − o)
```

**Computes:** Converts demosaicked RGB into one luma channel (Y′) plus two chrominance channels (Cb, Cr), and back, so only chrominance can be smoothed without touching perceptually important brightness detail.

| Term | Meaning |
|---|---|
| R, G, B | Color channel values, [0,1]-scaled (= v) |
| Y' | Luma — the brightness-carrying channel |
| Cb, Cr | Blue-difference and red-difference chrominance channels |
| 16, 128, 128 | Fixed offsets (o) shifting channels into conventional digital ranges (128 = "no color") |
| M | Fixed 3×3 BT.601 coefficient matrix; M⁻¹ its inverse, used to undo the transform |
| u, v, o | Vector shorthand: u=(Y′,Cb,Cr), v=(R,G,B), o=(16,128,128) |

---

### Malvar-He-Cutler gradient-corrected demosaicking (§14.5)

```
ĝ(x,y) = ĝ_lin(x,y) + α · D_R(x,y)     — interpolating G at an R pixel
r̂(x,y) = r̂_lin(x,y) + β · D_G(x,y)     — interpolating R at a G pixel
r̂(x,y) = r̂_lin(x,y) + γ · D_B(x,y)     — interpolating R at a B pixel

D_R(x,y) = r(x,y) − (1/4) · Σ r(x+m, y+n),   (m,n) ∈ {(0,−2), (0,2), (−2,0), (2,0)}

α = 1/2,   β = 5/8,   γ = 3/4
```

**Computes:** Improves naive demosaicking by adding a scaled local-curvature (gradient) correction taken from whichever channel is actually measured at that pixel, exploiting the fact that sharp edges appear in all color channels at once.

| Term | Meaning |
|---|---|
| ĝ_lin, r̂_lin | The plain naive-average estimate (§14.1) for that channel/pixel |
| D_R, D_G, D_B | Discrete Laplacian (local curvature) of the actually-sampled channel, from same-color samples two pixels away; D_G uses a different 9-point weighting (not given numerically in these notes) |
| α, β, γ | Fixed, empirically optimized gain constants controlling how strongly the correction is trusted |
| r(x,y) | The actually-measured red value at (x,y) (analogous for b in D_B) |
| (m,n) | The four cardinal offsets two pixels away — nearest same-color Bayer samples |

---

### Bilateral filter weight (§16.2)

```
w(x, x') = exp( −|x − x'|² / (2σ²) ) · exp( −|i_noisy(x') − i_noisy(x)|² / (2σ_i²) )
```

**Computes:** Weights a neighbor by spatial closeness AND intensity similarity together, so smoothing happens within a region but stops at an edge ("edge-aware smoothing").

| Term | Meaning |
|---|---|
| x, x' | Pixel positions |
| σ | Spatial standard deviation, in pixels — controls how far smoothing reaches |
| i_noisy(x), i_noisy(x') | Noisy intensity values at the center and candidate pixel |
| σ_i | Intensity ("range") standard deviation — how different two values may be before losing weight |

---

### Non-local means weight and patch distance (§16.3)

```
w(x, x') = exp( −‖N(x') − N(x)‖² / (2σ²) )

Weighted patch distance: Σ_{m,n} k_mn · (v(N_i)_mn − v(N_j)_mn)²

HW2 notation: w(i, j) = (1 / Z(i)) · exp( −‖v(N_i) − v(N_j)‖² / h² ),   h² = 2σ²
```

**Computes:** Weights a candidate pixel by how similar its surrounding patch is to the target's patch (not by spatial distance), exploiting image self-similarity; the Gaussian-weighted patch distance favors near-center pixels within each patch.

| Term | Meaning |
|---|---|
| N(x), N(x') | Small patches (pixel neighborhoods) centered at x and x' |
| ‖N(x')−N(x)‖² | Squared distance between the two patches' pixel values |
| σ | Patch-similarity scale (plays the spatial σ's role, but for patch distance) |
| k_mn | Fixed Gaussian weights over a patch's own layout, larger near its center |
| v(N_i)_mn, v(N_j)_mn | Pixel values at offset (m,n) within two patches |
| i, j / N_i, N_j | HW2's names for x, x' / N(x), N(x') |
| h | HW2's filtering parameter — how different two patches may be before their weight collapses; h²=2σ² |
| Z(i) | Normalizer — sum of unnormalized weights over the search window |

---

### Unsharp masking (§17)

```
detail     = I − blur(I)
sharpened  = I + k · (I − blur(I))

Linear-algebra form: sharpened = ((1+k)·Id − k·G_σ) · i
```

**Computes:** Sharpens an image by adding back an amplified copy of its own high-frequency ("detail") content, obtained by subtracting a blurred version of itself.

| Term | Meaning |
|---|---|
| I | The input image |
| blur(I) | A blurred (low-pass) copy — Gaussian or bilateral, with a chosen σ |
| detail | I − blur(I): the high-frequency content the blur removed |
| k | Sharpening strength, dimensionless, user-controlled; k=0 leaves the image unchanged |
| Id | The identity matrix |
| G_σ | The Gaussian-blur matrix (§12.2) |
| i | The image, flattened into a vector |

---

### Camera RGB → CIE XYZ calibration matrix (§18)

```
[X; Y; Z] = C · [R_cam; G_cam; B_cam]
```

**Computes:** Converts a camera's native, device-specific RGB response into standard CIE XYZ, using a matrix fit by photographing known-color calibration targets.

| Term | Meaning |
|---|---|
| R_cam, G_cam, B_cam | Camera's native, demosaicked linear RGB values |
| C | 3×3 calibration matrix, camera-specific, found by fitting to a known color target — fixed per camera model, not user-set |
| X, Y, Z | Resulting standard CIE XYZ tristimulus values |

---

### sRGB ↔ XYZ conversion matrices (§18)

```
sRGB → XYZ:                     XYZ → linear sRGB (its inverse):
[0.4124  0.3576  0.1805]        [ 3.2406  −1.5372  −0.4986]
[0.2126  0.7152  0.0722]        [−0.9689   1.8758   0.0415]
[0.0193  0.1192  0.9505]        [ 0.0557  −0.2040   1.0570]
```

**Computes:** The standardized change-of-basis matrices between linear sRGB and CIE XYZ, used to map a camera's calibrated XYZ into displayable sRGB (and back) and to test whether a color falls inside the sRGB gamut (negative or >1 results mean it doesn't).

| Term | Meaning |
|---|---|
| sRGB→XYZ matrix | Each column is one sRGB primary's XYZ value at full strength; standardized (IEC 61966-2-1) |
| XYZ→linear sRGB matrix | Its inverse; negative entries flag out-of-gamut colors |
| middle row of sRGB→XYZ (0.2126, 0.7152, 0.0722) | Each primary's luminance contribution (Y), summing to 1 |

---

### DCT as a change of basis (§19)

```
c = T · b
```

**Computes:** Re-expresses an 8×8 image block's 64 pixel values as coordinates in a fixed orthonormal cosine (spatial-frequency) basis — the lossless transform step of JPEG compression.

| Term | Meaning |
|---|---|
| b | One 8×8 block's pixel values, flattened into a 64-vector |
| T | 64×64 orthonormal DCT matrix, whose rows are the fixed cosine basis patterns |
| c | The block's DCT coefficients — its coordinates in the cosine basis |
| T⁻¹ = Tᵀ | Inverse equals transpose because T is orthonormal, so no system needs solving to invert |

---

### White balance as a diagonal matrix (§20)

```
v_wb = diag(g_R, g_G, g_B) · v_cam
```

**Computes:** Rescales each raw color channel independently so a neutral gray scene object reads R=G=B, removing the light source's color cast.

| Term | Meaning |
|---|---|
| v_cam | Camera's raw (R,G,B) triplet before white balance |
| g_R, g_G, g_B | Per-channel gain factors, stored as the camera's "as-shot" white balance — set by capture, not by this formula |
| diag(g_R,g_G,g_B) | Diagonal gain matrix — scales each channel independently, mixes none into another |
| v_wb | The white-balanced (R,G,B) triplet |

---

## Week 4 — Great Ideas in Computational Photography (HDR imaging, tonemapping, coded imaging)
*(full derivations and diagrams in [`week4-study-notes.md`](./week4-study-notes.md); this is the lookup-speed reference)*

### Exposure = Gain × Flux × Time (§2.1)

```
Exposure = Gain × Flux × Time
```

**Computes:** How bright a single captured photo looks overall — this is the *loose*, colloquial sense of "exposure" that folds ISO gain in, distinct from this file's own §2.2 strict physical exposure *H* = *E*·*t* (light energy per unit sensor area), which explicitly excludes ISO (§2.5 proves ISO doesn't change the physical light collected, only how it's amplified afterward). Do not confuse the two: this formula is a plain-language recap, not a new physical quantity.

| Term | Meaning |
|---|---|
| Exposure | How bright the resulting photo looks (loose sense, not a physical energy-per-area quantity) — computed/perceived output |
| Gain | ISO setting — amplifies the already-collected signal (and its noise) after the fact; you control this |
| Flux | Overall light arriving at the sensor, controlled by aperture (f-number, Week 2 §8); you control this |
| Time | Shutter speed/exposure time; you control this |

---

### Exposure (§2.2)

```
H = E · t
E ≈ (π/4) · L / N²
H ∝ L · t / N²
```

**Computes:** Gives the total light energy collected per unit sensor area during a capture — the quantity that sets image brightness.

| Term | Meaning |
|---|---|
| H | exposure, total light per unit area (lux·s) |
| E | image-plane irradiance, light power per unit area (lux) |
| t | exposure time (seconds) — you control this |
| L | scene luminance — fixed by the scene |
| N | f-number — you control this |
| π/4 | geometric constant from integrating over a circular aperture |

---

### Exposure value (§2.3)

```
EV = log₂(N² / t)
```

**Computes:** Gives a single number labeling a whole family of equivalent (aperture, time) exposure settings; one EV step equals one stop.

| Term | Meaning |
|---|---|
| EV | exposure value |
| N | f-number |
| t | exposure time (seconds) |

---

### Sum, scaling, and average of independent noisy values (§3)

```
Var(X₁ + X₂) = σ₁² + σ₂²        Var(c·X) = c²·σ²        Var(mean of K) = σ²/K
Pois(λ₁) + Pois(λ₂) = Pois(λ₁ + λ₂)

Var(X₁ + … + X_K) = K·σ²        Var(mean) = (1/K)² · K·σ² = σ²/K        σ_mean = σ/√K
```

**Computes:** The noise variance left after adding, rescaling, or averaging independent noisy measurements, which is the bookkeeping behind any burst-denoising or SNR comparison.

| Term | Meaning |
|---|---|
| X₁, X₂ | Independent random pixel values (independent noise draws), e.g. two frames |
| σ², σ₁², σ₂² | Variances of those values, in squared pixel-value (or squared photon) units; fixed by the noise model |
| c | A constant multiplier, e.g. 1/K when averaging; chosen by you |
| K | Number of independent frames averaged; chosen by you. Appears once as the count of terms in the summed variance (K·σ²) |
| (1/K)² = 1/K² | The squared 1/K averaging weight (rule Var(cX) = c²Var(X) with c = 1/K); one K cancels, leaving σ²/K |
| σ_mean | Standard deviation of the average, σ/√K; assumes independent, equal-variance, aligned frames (fixed-pattern noise does not average down) |
| Pois(λ) | Poisson distribution with mean = variance = λ photons; fixed by scene brightness |

---

### Motion blur streak length (§4.3, §23.1)

```
blur length (pixels) = image-plane speed (pixels/second) × exposure time (seconds)
y = B x
```

**Computes:** Gives the length of the streak a moving point leaves on the sensor, and (in matrix form) shows motion blur is a convolution of the sharp image with a box kernel.

| Term | Meaning |
|---|---|
| blur length | length of the motion streak, in pixels |
| image-plane speed | how fast the subject's image moves across the sensor — fixed by scene motion, distance, and focal length |
| exposure time | duration of the capture — you control this |
| y | blurred image, as a vector |
| B | banded (Toeplitz) matrix implementing convolution with the box kernel of length = streak length |
| x | sharp image, as a vector |

---

### LiDAR range equation (§5.1)

```
τ = 2d / c   ⇔   d = c·τ / 2
```

**Computes:** Converts a measured round-trip light travel time into distance to an object — the core ranging equation behind LiDAR and time-of-flight sensing.

| Term | Meaning |
|---|---|
| d | distance to the object (meters) — the unknown being measured |
| τ | round-trip time (seconds) — what the sensor times |
| c | speed of light, physical constant |
| 2 | factor accounting for the light travelling out and back |

---

### Non-linear image formation model and linearization (§9.2)

```
I_linear(x, y)     = clip[ tᵢ · Φ(x, y) + noise ]
I_nonlinear(x, y)  = f[ I_linear(x, y) ]
I_est(x, y)        = f⁻¹[ I_nonlinear(x, y) ]
```

**Computes:** Models how a camera's internal tone-reproduction curve nonlinearly distorts the linear sensor signal before it's written out, and gives the inversion needed to recover an estimate of the true linear signal (radiometric calibration: comparing the camera's readings against calibration targets of known light amount to learn *f*, then inverting it) before HDR merging.

| Term | Meaning |
|---|---|
| Φ(x,y) | True scene flux hitting pixel (x,y) — fixed by the scene/lighting |
| tᵢ | Exposure i's exposure time — you control this |
| I_linear | What the sensor would record with no further distortion (after clipping at saturation) |
| f[·] | Camera's tone reproduction curve — fixed, generally unknown, monotonic nonlinear function baked in by the camera |
| I_nonlinear | What actually gets written to the output file — measured |
| f⁻¹[·] | Inverse of the tone reproduction curve, used to linearize |
| I_est | Recovered estimate of the true linear signal — computed output, fed into §10.3's merge |

---

### sRGB decoding (inverse gamma) (§9.5)

```
C_lin = C / 12.92                    if C ≤ 0.04045
C_lin = ((C + 0.055) / 1.055)^2.4    otherwise
```

**Computes:** The linear-light value of a stored sRGB value, undoing the display tone curve so the merge of §10.3 operates on values proportional to scene light.

| Term | Meaning |
|---|---|
| C | Stored sRGB value for one channel, in [0, 1] (the 8-bit code divided by 255); measured |
| C_lin | Linear value for that channel; computed output |
| 12.92, 0.04045, 0.055, 1.055, 2.4 | Constants fixed by the sRGB standard |

---

### Confidence weight function (§10.2)

```
w(I) = exp( −4·(I − 0.5)² / 0.5² )
```

**Computes:** Gives how much to trust one bracketed exposure's pixel value when merging an HDR stack — peaking at mid-gray and falling off toward black and white, where noise or clipping make the measurement unreliable.

| Term | Meaning |
|---|---|
| I | A single pixel's linear, [0,1]-scaled value from one exposure in the bracketed stack — measured |
| w(I) | Resulting confidence weight, in (0,1] — computed output |
| 0.5 | Mid-range value the weight peaks at (fully-confident, correctly-exposed case) — fixed constant |
| −4 / 0.5² | Sets the fall-off rate; equivalent standard-Gaussian width σ ≈ 0.177 — fixed constant |

---

### HDR merging: log-domain weighted least-squares solution (§10.3)

```
O(X) = Σᵢ wᵢ · ( log(I_lin,i) − log(tᵢ·X) )²

X̂ = exp( [ Σᵢ wᵢ·(log(I_lin,i) − log(tᵢ)) ] / [ Σᵢ wᵢ ] )
```

**Computes:** Recovers, per pixel, the single best-estimate true (relative) scene radiance value from an exposure-bracketed stack, by weighting each exposure's own estimate by how confident it is — the merge step of HDR imaging.

| Term | Meaning |
|---|---|
| i = 1...N | Index over the N bracketed exposures of the same pixel — fixed by the bracket (§8) |
| I_lin,i | Linearized recorded value at this pixel in exposure i — measured (after §9's linearization) |
| tᵢ | Exposure i's known exposure time — you control this (via bracketing, §8) |
| wᵢ | Confidence weight for exposure i, = w(I_lin,i) from the confidence weight function above |
| X | Unknown true scene exposure/radiance value at this pixel — the same for every i; solved for |
| O(X) | Weighted least-squares objective being minimized over X (in the log domain) |
| X̂ | The recovered, merged HDR value at this pixel (relative units) — computed output |

---

### Debevec triangle weight (§10.4)

```
w(z) = min( z, 1 − z )
```

**Computes:** How much to trust one pixel value from one exposure when merging an HDR stack, peaking at mid-range and reaching exactly zero at black and at saturation (the alternative to the Gaussian weight of §10.2).

| Term | Meaning |
|---|---|
| z | One pixel's value in one exposure on a [0, 1] scale; measured |
| w(z) | Confidence weight in [0, 0.5], computed output |
| 0.5 | Value at which the weight peaks; fixed |

---

### Photographic tonemapping curve (§14)

```
I_display = I_HDR / (1 + I_HDR)
```

**Computes:** Maps an unbounded, linear HDR intensity value down into a display's finite [0,1) range non-linearly, leaving dark regions essentially untouched (slope 1 near 0) while asymptoting to 1 for arbitrarily bright input — the simplified tonemapping curve (a tone curve in the sense of Week 4 §13.1: input brightness to output brightness).

| Term | Meaning |
|---|---|
| I_HDR | Input HDR intensity at one pixel — linear, non-negative, unbounded above; from the merge (§10.3) |
| I_display | Output value sent to the display, guaranteed to lie in [0,1) — computed output |

---

### Two-knob gamma tonemapper (§14.1)

```
I_display = clip( (s · I_HDR)^γ , 0, 1 )
```

**Computes:** A displayable [0, 1] image from a normalized linear HDR image, with s setting overall brightness and γ setting how strongly shadows are lifted.

| Term | Meaning |
|---|---|
| I_HDR | Normalized linear HDR value in [0, 1] from the merge; fixed by the data |
| s | Linear scale (gain) applied before the curve; you choose it |
| γ | Exponent, usually below 1 to lift shadows; you choose it |
| clip(·, 0, 1) | Forces values into the displayable range |

---

### PSF convolution (image formation) (§18.1)

```
I_blurred(x, y) = (I_ideal * PSF)(x, y)
```

**Computes:** Models a real optical system's blurred image as the convolution of the hypothetical perfectly sharp (pinhole) image with the system's point spread function — the formal name for the blur behavior already used informally in Week 2's pinhole/defocus/circle-of-confusion sections.

| Term | Meaning |
|---|---|
| I_ideal(x,y) | Hypothetical perfectly sharp image an ideal pinhole would produce (Week 2 §2) |
| PSF(x,y) | System's blur kernel, normalized to sum/integrate to 1 (redistributes light, adds/removes none) — fixed by the optics |
| I_blurred(x,y) | Image actually captured — computed output |
| * | Convolution (sliding weighted sum, Week 1 §20) |

---

### OTF as the Fourier transform of the PSF, and the primal/Fourier high-pass identity (§18.2, §18.3)

```
OTF(u, v) = FT{ PSF }(u, v)

I − I * PSF_LP   ≡   Ĩ × (1 − OTF_LP)
```

**Computes:** Gives, frequency by frequency, how much of each spatial-frequency component of the true scene survives the imaging system (near 1 = passes through, near 0 = destroyed and unrecoverable) — the frequency-domain partner of the PSF; the second line shows the same high-pass-as-complement-of-low-pass filtering identity expressed equivalently in the spatial (primal) domain via subtraction or in the Fourier domain via multiplication by the complementary mask.

| Term | Meaning |
|---|---|
| u, v | Image frequencies, cycles per pixel (Week 1 §19.2) |
| PSF | The system's blur kernel (previous entry) |
| OTF(u,v) | Fourier transform of the PSF — fraction of each frequency that survives imaging; computed from the optics |
| I | Spatial-domain image |
| PSF_LP | A low-pass blur kernel (e.g. Gaussian) |
| OTF_LP | Fourier transform of PSF_LP |
| Ĩ | Spectrum (Fourier transform) of I |
| I − I*PSF_LP | Primal-domain high-pass filtering: subtract a low-pass-blurred copy |
| Ĩ×(1−OTF_LP) | Equivalent Fourier-domain high-pass filtering: multiply by the complementary mask |

---

### Flutter shutter light budget (§23.3)

```
μ_flutter = d · n        (one readout)
```

**Computes:** The mean recorded value of a coded-exposure image, used as the signal term when comparing a flutter shutter against a burst of short exposures.

| Term | Meaning |
|---|---|
| n | Mean photons collected over a full, unmodulated exposure; fixed by the scene and exposure time |
| d | Duty cycle, the fraction of the exposure the shutter is open; set by the code you choose |
| μ_flutter | Mean recorded value of the coded image; computed output |

---

## Week 5 — Sampling, Linear Systems, Deconvolution
*(full derivations and diagrams in [`week5-study-notes.md`](./week5-study-notes.md); this is the lookup-speed reference)*

### A sinusoidal wave (§2.1)

```
s(x) = A · cos(2π ξ x + φ)
```

**Computes:** The value at position (or time) x of a single pure wave, the building block every Fourier formula decomposes signals into.

| Term | Meaning |
|---|---|
| x | Position or time — the axis you measure along |
| A | Amplitude: half the peak-to-trough height; signal units — fixed by the signal |
| ξ | Frequency: cycles per unit of x (period 1/ξ) — fixed by the signal |
| φ | Phase: sideways shift, in radians (2π = one cycle) — fixed by the signal |
| 2π | Converts cycles to radians — fixed |

---

### Euler's formula and the polar form (§2.3)

```
e^{jθ} = cos θ + j sin θ
A e^{jφ} · e^{j2πξx} = A e^{j(2πξx + φ)}    (real part: A cos(2πξx + φ))
cos(2πξx) = ½ e^{j2πξx} + ½ e^{−j2πξx}
```

**Computes:** Packs a wave's amplitude and phase into one complex number and writes a real cosine as two counter-rotating complex waves (at +ξ and −ξ).

| Term | Meaning |
|---|---|
| j | Imaginary unit, j² = −1 (the slides also write it i) |
| θ | Angle of the unit arrow, radians |
| A e^{jφ} | Arrow of length A (amplitude) at angle φ (phase) |
| e^{j2πξx} | Arrow spinning ξ turns per unit of x: a complex wave of frequency ξ |

---

### Continuous Fourier transform pair, 1D and 2D (§3.1–§3.2)

```
f̂(ξ) = ∫ f(x) e^{−j2πξx} dx          f(x) = ∫ f̂(ξ) e^{j2πξx} dξ
f(x, y) = ∫∫ F(k_x, k_y) e^{j2π(k_x x + k_y y)} dk_x dk_y
```

**Computes:** The spectrum — one complex coefficient per frequency saying how much of each wave (1D) or grating (2D) a signal contains — and, inversely, rebuilds the signal from it with nothing lost.

| Term | Meaning |
|---|---|
| f(x), f(x,y) | Signal in the primal domain (signal units) |
| ξ; k_x, k_y | Frequency (1D); horizontal and vertical frequency (2D), cycles per unit length |
| f̂(ξ), F(k_x,k_y) | Fourier coefficients: magnitude = strength, angle = shift of each wave |
| e^{∓j2πξx} | Probe wave (forward, minus sign) / building-block wave (inverse, plus sign) |

---

### Conjugate symmetry of real signals (§3.3)

```
F(−k_x, −k_y) = F(k_x, k_y)*
```

**Computes:** The constraint every real image's spectrum satisfies, so its magnitude spectrum is symmetric through the center and half the coefficients are redundant.

| Term | Meaning |
|---|---|
| F(k_x,k_y) | Fourier coefficient at frequency (k_x, k_y) |
| * | Complex conjugate (same magnitude, opposite angle) |

---

### Convolution, discrete and continuous (§5.1)

```
(x ∗ h)[n] = Σ_m h[m] · x[n − m]          (f ∗ g)(x) = ∫ g(u) · f(x − u) du
```

**Computes:** The output of any linear shift-invariant system (blur, smoothing filter, lens) as a stamped-and-summed copy of its kernel at every input point.

| Term | Meaning |
|---|---|
| x[n], f(x) | Input signal — fixed by the scene |
| h[m], g(u) | Kernel / impulse response / PSF — chosen (a filter) or fixed by the optics (a blur) |
| n, x | Output position |
| m, u | Offset of a kernel weight from the output position |

---

### Convolution theorem (§5.2)

```
F{x ∗ g} = F{x} · F{g}          x ∗ g = F⁻¹{ F{x} · F{g} }
```

**Computes:** Convolution in the primal domain as element-wise multiplication of spectra: each frequency of the input is scaled and shifted by the kernel's spectrum (its frequency response, or OTF for a lens).

| Term | Meaning |
|---|---|
| F{x} | Input spectrum |
| F{g} | Kernel spectrum (frequency response / OTF): near 1 = passed, near 0 = removed |
| · | Multiplication, one frequency at a time |
| F⁻¹ | Inverse Fourier transform |

---

### Standard Fourier pairs and the scaling theorem (§6)

```
δ(x) ↔ 1                    rect(x) ↔ sinc(ξ) = sin(πξ)/(πξ)
tent = rect ∗ rect ↔ sinc²(ξ)
(1/(σ√(2π))) e^{−x²/(2σ²)} ↔ e^{−2π²σ²ξ²}
comb_T(x) = Σ_n δ(x − nT) ↔ (1/T) · comb_{1/T}(ξ)
f(x/a) ↔ |a| · f̂(aξ)
```

**Computes:** The spectra of the shapes the lecture uses (point, aperture/pixel box, triangle, Gaussian blur, sampling comb), and how stretching a signal by a squeezes its spectrum by a.

| Term | Meaning |
|---|---|
| δ | Impulse: a single point of unit area |
| rect | Box: 1 for \|x\| < ½ (aperture slit, pixel, shutter) |
| sinc | Its transform; exact zeros at every nonzero integer ξ |
| tent | Triangle 1 − \|x\| on \|x\| < 1 |
| σ | Gaussian width (spectrum width 1/(2πσ)) — you choose for a filter |
| T | Comb spacing (sampling interval) |
| a | Stretch factor |

---

### Spectrum of a sampled signal (§7)

```
f_sampled(x) = f(x) · comb_T(x)          F{f · comb_T} = (1/T) · Σ_m f̂(ξ − m f_s),   f_s = 1/T
```

**Computes:** The effect of sampling on frequency content: copies of the original spectrum centered at every multiple of the sampling rate.

| Term | Meaning |
|---|---|
| T | Sampling interval (pixel pitch, seconds per sample) — set by the sensor/digitizer |
| f_s | Sampling rate, samples per unit length or per second |
| m | Index of the spectral copy |
| f̂(ξ − m f_s) | Original spectrum shifted to m f_s |

---

### Nyquist–Shannon criterion and the aliased frequency (§8)

```
f_s ≥ 2 f_max                      Nyquist frequency = f_s / 2
f_apparent = | f − f_s · round(f / f_s) |
```

**Computes:** Whether a sampling rate is fast enough to represent a band-limited signal without aliasing, and, if not, the lower frequency an under-sampled frequency appears as (e.g. 24 Hz at f_s = 20 Hz appears as 4 Hz).

| Term | Meaning |
|---|---|
| f_s | Sampling rate — you or the hardware choose it |
| f_max | Highest frequency present in the signal — fixed by the signal (or by an anti-aliasing filter) |
| f | A frequency present in the signal |
| f_apparent | The frequency it appears as after sampling, between 0 and f_s/2 |

---

### Discrete Fourier transform pair (§10)

```
x̂[k] = Σ_{n=0}^{N−1} x[n] e^{−j2πkn/N}          x[n] = (1/N) Σ_{k=0}^{N−1} x̂[k] e^{j2πkn/N}
x̂ = F x,   F[k, n] = e^{−j2πkn/N},   F⁻¹ = F^H / N
```

**Computes:** The N Fourier coefficients of N stored samples (treated as one period of a repeating signal), an orthogonal change of basis that the inverse undoes exactly.

| Term | Meaning |
|---|---|
| x[n] | n-th sample, n = 0…N−1 |
| N | Number of samples |
| k | Frequency index: k cycles across the N samples, i.e. k/N cycles per sample; indices above N/2 are negative frequencies |
| x̂[k] | k-th complex coefficient; x̂[0] = sum of samples |
| F | N×N DFT matrix; F^H is its conjugate transpose |

---

### FFT recombination (butterfly) (§11)

```
x̂[k]       = E[k] + e^{−j2πk/N} · O[k]
x̂[k + N/2] = E[k] − e^{−j2πk/N} · O[k]          (k = 0 … N/2 − 1)
```

**Computes:** The full N-point DFT from the DFTs of the even-indexed (E) and odd-indexed (O) samples; applied recursively, it reduces the cost from N² to about N log₂ N operations.

| Term | Meaning |
|---|---|
| E[k], O[k] | Half-length DFTs of the even and odd samples |
| e^{−j2πk/N} | Twiddle factor |
| N | Transform length (a power of 2 in the basic version) |

---

### Diffraction chain: aperture → PSF → OTF (§13.2)

```
coherent PSF   = F{ aperture }
incoherent PSF = | F{ aperture } |²
OTF            = F{ incoherent PSF } = autocorrelation of the aperture
1D slit:  rect(x) → sinc(x) → sinc²(x) → tent(x)
```

**Computes:** Under Fraunhofer (far-field) and incoherent-light assumptions, the diffraction-limited blur of a lens from its aperture shape, and the fraction of each spatial frequency it transmits.

| Term | Meaning |
|---|---|
| aperture | Opening shape: 1 where light passes, 0 where blocked — set by the lens design |
| coherent PSF | Wave amplitude on the sensor (can be negative) |
| incoherent PSF | Intensity the sensor records (squared magnitude) |
| OTF | Transfer function; zero beyond a cutoff |

---

### Airy disc radius and diffraction cutoff (§13.5)

```
r = 1.22 · λ · N          ξ_cutoff = 1 / (λ · N)
```

**Computes:** The radius of the central bright disc of a circular aperture's diffraction PSF, and the highest spatial frequency the lens transmits (e.g. 5.37 µm and 227 cycles/mm for 550 nm light at f/8).

| Term | Meaning |
|---|---|
| λ | Wavelength of light, m — fixed by the light |
| N | f-number f/D — you choose it |
| 1.22 | First zero of the jinc (circular geometry) — fixed |
| r | Airy disc radius on the sensor, m |
| ξ_cutoff | OTF cutoff, cycles per unit length on the sensor |

---

### LiDAR beam divergence (§13.6)

```
θ ≈ 1.22 · λ / D          r ≈ θ · R
```

**Computes:** The diffraction-limited half-angle spread of a laser beam leaving an aperture of diameter D, and the resulting spot radius at range R (e.g. 0.11 mrad and 1.1 cm at 100 m for 905 nm, D = 10 mm).

| Term | Meaning |
|---|---|
| λ | Laser wavelength, m — set by the laser |
| D | Exit aperture diameter, m — set by the design |
| θ | Half-angle beam spread, radians |
| R | Distance to the target, m |
| r | Spot radius on the target, m |

---

### Lens blur model; MTF (§14)

```
b = c ∗ x          B = C · X          MTF = |OTF| = |C|
```

**Computes:** The blurred image a lens forms from the ideal sharp image, as a convolution with the PSF or, equivalently, a per-frequency multiplication by the OTF; the MTF is the contrast-only part.

| Term | Meaning |
|---|---|
| x, X | Sharp image and its spectrum |
| c, C | PSF and its Fourier transform, the OTF — fixed by the optics |
| b, B | Blurred image and its spectrum |

---

### Pixel integration, sampling, and the footprint MTF (§15)

```
ĩ(x, y) = i(x, y) ∗ ( rect(x/w) · rect(y/h) )
E[i, j] = ĩ(x, y) · Σ_m Σ_n δ(x − m p, y − n p)
MTF_footprint(ξ) = | sin(π ξ w) / (π ξ w) |          sensor Nyquist = 1 / (2p)
```

**Computes:** How a sensor turns continuous irradiance into pixel values (box-average over each pixel, then sample at pixel centers), the contrast lost to pixel averaging at each spatial frequency (zero at 1/w), and the highest frequency the pixel grid can represent (e.g. 0.64 at Nyquist and 125 cycles/mm for 4 µm pixels).

| Term | Meaning |
|---|---|
| i(x, y) | Irradiance on the sensor, W/m² |
| w, h | Pixel light-collecting width and height — fixed by the sensor |
| p | Pixel pitch (center spacing) — fixed by the sensor |
| E[i, j] | Stored value of pixel (i, j) |
| ξ | Spatial frequency, cycles per unit length |

---

### Low-pass filtering in two domains, and its cost (§16)

```
b = x ∗ c          F{b} = F{x} · F{c}
cost:  primal ≈ P · K²          Fourier ≈ 2 P log₂ P + P
```

**Computes:** A blurred (low-passed) image by direct convolution or by Fourier-domain multiplication, and the operation counts that make the Fourier route cheaper for large kernels.

| Term | Meaning |
|---|---|
| x | Input image |
| c | Low-pass kernel (e.g. a normalized Gaussian) — you choose it |
| P | Number of pixels |
| K | Kernel width in pixels (K×K kernel) |

---

### High-pass filtering and unsharp masking (§17)

```
high-pass:   x − x ∗ c_LP          X · (1 − C_LP)
sharpened:   x ∗ (δ + c_highpass) = x + x ∗ c_highpass,     c_highpass = δ − c_lowpass_gauss
Fourier:     X · (2 − C_LP)
```

**Computes:** The detail layer (image minus its blur) and a sharpened image (original plus one extra copy of its detail), in both domains.

| Term | Meaning |
|---|---|
| c_LP, c_lowpass_gauss | Normalized low-pass (Gaussian) kernel — you choose its σ |
| C_LP | Its Fourier transform |
| δ | Impulse kernel (identity for convolution) |
| c_highpass | High-pass kernel δ − c_LP |

---

### Anti-aliasing cutoff for downsampling (§19)

```
keep every D-th pixel  ⇒  remove image frequencies above 1 / (2D) cycles per original pixel first
```

**Computes:** How much to low-pass filter an image before downsampling by a factor D so that the subsampled image does not alias (e.g. 0.125 cycles/pixel for D = 4).

| Term | Meaning |
|---|---|
| D | Downsampling factor — you choose it |
| 1/(2D) | New Nyquist frequency, in cycles per original pixel |

---

### LiDAR range ambiguity: pulsed and continuous-wave (§20.2)

```
pulsed:            R_max = c / (2 · PRF)          d_reported = d_true − m · R_max
continuous-wave:   R_amb = c / (2 · f_mod)        d_reported = d_true mod R_amb
waveform sampling: range bin = c · Δt / 2
```

**Computes:** The farthest distance a LiDAR can report unambiguously (150 m at PRF = 1 MHz; 7.5 m at f_mod = 20 MHz), where a farther target is wrongly reported (time-domain aliasing), and the range spanned by one digitizer sample (15 cm at 1 GS/s).

| Term | Meaning |
|---|---|
| c | Speed of light, ≈ 3 × 10⁸ m/s — fixed |
| PRF | Pulse repetition frequency, Hz — set by the designer |
| f_mod | Modulation frequency of a continuous-wave ToF sensor, Hz — set by the designer |
| m | Number of skipped pulse gaps (integer) |
| Δt | Digitizer sample interval, s |

---

### Noisy blur model and the inverse filter (§22)

```
b = k ∗ i + n          B = K · I + N
i_est = F⁻¹( F(b) / F(k) )          B / K = I + N / K
```

**Computes:** The naive deconvolution estimate, and why it fails: the noise term N/K becomes huge wherever the OTF K is small or zero.

| Term | Meaning |
|---|---|
| i, I | Sharp image and spectrum — unknown |
| k, K | Blur kernel (PSF) and OTF — known (non-blind) |
| b, B | Blurred noisy measurement and spectrum — measured |
| n, N | Noise (zero-mean, independent of i) and its spectrum |

---

### Wiener deconvolution (§23)

```
i_est = F⁻¹( [ |F(k)|² / ( |F(k)|² + 1/SNR(ω) ) ] · F(b) / F(k) )
      = F⁻¹( K* / ( |K|² + 1/SNR(ω) ) · F(b) )
SNR(ω) = signal variance at ω / noise variance at ω          (PS4's estimate: SNR = Ī / σ_noise)
```

**Computes:** A deconvolved image that divides by the OTF only where the signal dominates the noise, damping each frequency by |K|²/(|K|² + 1/SNR) — near 1 at high SNR (inverse filter), near 0 at low SNR (frequency abandoned).

| Term | Meaning |
|---|---|
| F(k) = K | OTF of the known blur; K* its conjugate |
| F(b) | Spectrum of the measurement |
| SNR(ω) | Signal-to-noise power ratio at frequency ω — estimated or chosen; often one constant |
| Ī | Mean pixel value of the noisy image (PS4's amplitude-ratio estimate) |
| σ_noise | Standard deviation of the added noise |

---

### Wiener filter as the expected-error minimizer (§24)

```
min_H  E[ |I − H B|² ]   ⇒   loss(H) = (1 − HK)² E[I²] + H² E[N²]
H = K E[I²] / ( K² E[I²] + E[N²] ) = (1/K) · K² / ( K² + 1/SNR )
```

**Computes:** The per-frequency multiplier H that minimizes the average squared restoration error, balancing leftover blur (first loss term) against amplified noise (second term).

| Term | Meaning |
|---|---|
| H | Restoration multiplier at one frequency — the unknown being optimized |
| E[·] | Expected value (average over noise realizations) |
| E[I²], E[N²] | Signal and noise power at this frequency |
| 1/SNR | E[N²]/E[I²] |

---

### MSE and PSNR for a restored image (§25)

```
MSE  = (1/(m n)) Σ_i Σ_j [ I_original(i, j) − I_restored(i, j) ]²
PSNR = 10 · log₁₀( max(I_original)² / MSE )    (dB)
```

**Computes:** The average squared pixel error of a restoration and the same error expressed as a scale-free ratio in decibels (higher PSNR is better; MSE 0.001 on [0, 1] images = 30 dB). Same metrics as Week 3 §13, single-channel form.

| Term | Meaning |
|---|---|
| m, n | Image height and width, pixels |
| I_original, I_restored | Ground-truth and restored pixel values |
| max(I_original) | Largest value the image format holds (1 or 255) |

---

### Linear image formation (§26)

```
b = A x
```

**Computes:** The measurements produced by any linear imaging process (blur, pixel binning, sampling, mosaicking) as one matrix applied to the unknown image vector.

| Term | Meaning |
|---|---|
| x | Unknown image, flattened to n×1 |
| A | m×n image-formation matrix — usually known |
| b | m×1 measurement vector |

---

### Singular value decomposition and condition number (§27)

```
A = U Σ Vᵀ          condition number = s_max / s_min
```

**Computes:** The input directions, output directions and stretch factors of a matrix, from which its rank (nonzero s), null space (zero s) and noise amplification (condition number) follow; for a circulant blur the singular values are |OTF|.

| Term | Meaning |
|---|---|
| U, V | Orthogonal matrices of output and input directions |
| Σ | Diagonal matrix of singular values s₁ ≥ s₂ ≥ … ≥ 0 |
| s_max, s_min | Largest and smallest singular values |

---

### Least squares, its gradient, and the normal equations (§29)

```
minimize_x  ½ ‖b − A x‖₂²          ‖r‖₂² = Σ_i r_i²,   r = b − A x
∇ₓ ½‖b − Ax‖₂² = AᵀA x − Aᵀb
AᵀA x = Aᵀb          (residual ⟂ columns of A;  A x̂ = P b,  P = A(AᵀA)⁻¹Aᵀ)
```

**Computes:** The best-fitting solution of an over-determined linear system (the orthogonal projection of b onto the column space of A), and the gradient used by iterative solvers.

| Term | Meaning |
|---|---|
| r | Residual: measurement minus prediction |
| ‖·‖₂ | ℓ₂ norm (length) |
| Aᵀ | Transpose of A |
| P | Projection matrix onto the column space of A |

---

### Tikhonov-regularized solution (§30)

```
x_est = (AᵀA + λ I)⁻¹ Aᵀ b          minimizes ½‖b − Ax‖₂² + (λ/2)‖x‖₂²
per singular value:  1/s  →  s / (s² + λ)
for a circulant blur:  K* / (|K|² + λ)     (Wiener with 1/SNR = λ)
```

**Computes:** A unique, stable solution even for under-determined or ill-conditioned systems, by adding λ to every eigenvalue of AᵀA; λ → 0 gives the least-norm solution.

| Term | Meaning |
|---|---|
| λ | Regularization weight (> 0) — you choose it |
| I | Identity matrix |
| s | A singular value of A |

---

### Gradient descent for least squares, and its step-size limit (§31.1)

```
x^(k+1) = x^(k) − α ∇f(x^(k)) = x^(k) − α Aᵀ( A x^(k) − b )
converges if 0 < α < 2 / μ_max,   μ_max = largest eigenvalue of AᵀA
```

**Computes:** Successive estimates that move downhill on the least-squares objective, using only one product with A and one with Aᵀ per step, never an inverse.

| Term | Meaning |
|---|---|
| x^(k) | Estimate after k iterations |
| α | Step size / learning rate — you choose it |
| μ_max | Largest eigenvalue of AᵀA (steepest curvature) |

---

### Gradient descent for deconvolution (§31.2)

```
x^(k+1) = x^(k) − α · c* ∗ ( c ∗ x^(k) − b )
        = x^(k) − α · F⁻¹{ F{c}* · ( F{c} · F{x^(k)} − F{b} ) }
```

**Computes:** A gradient-descent deblurring step in which Aᵀ is convolution with the flipped kernel c*, implemented with FFTs as multiplication by the conjugate OTF.

| Term | Meaning |
|---|---|
| c | Blur kernel (PSF) — known |
| c* | Flipped kernel c(−x), the adjoint of the blur (not complex conjugation in space) |
| F{c}* | Complex conjugate of the OTF |

---

### Stochastic gradient descent (§32)

```
x^(k+1) = x^(k) − α Ã^(k)ᵀ ( Ã^(k) x^(k) − b̃^(k) )          E[ g(x) ] = ∇f(x)
‖A x − b‖₂² = Σ_{i=1}^{m} ( a_iᵀ x − b_i )²
```

**Computes:** A gradient step using only a random batch of rows of A and b, whose gradient estimate equals the full gradient on average (exactly, with an m/B scale).

| Term | Meaning |
|---|---|
| Ã^(k), b̃^(k) | The B randomly chosen rows of A and entries of b at iteration k |
| B | Batch size — you choose it |
| a_iᵀ, b_i | Row i of A and entry i of b |
| g(x) | Random gradient estimate |
