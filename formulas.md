# CSC2529 — Running Formula Reference

A single, cumulative reference of every load-bearing formula from the course, grouped by the week it's introduced in. Where `glossary.md` is organized around *terms*, this file is organized around *formulas*: each entry gives the formula exactly as written in that week's notes, a term-by-term table (what each symbol means, its units where relevant, and whether it's something you control or something fixed by the setup), and a one-sentence "Computes" line stating what real-world or computational quantity it produces.

This covers formulas substantial enough to get the full "Equations" treatment (intuition, term-by-term breakdown, diagram if geometric) in that week's notes — not every one-off numeric substitution inside a worked example. For the full derivation and intuition behind any formula here, follow its link back to the week's notes; for the diagram that goes with a geometric one, see the [running artifact](https://claude.ai/code/artifact/81a2c9a4-30d8-4c1c-83a2-e5165873f6e0).

**How this file is maintained:** every time a new week's study notes are written, append that week's formulas as a new `## Week N` section below, in the order they appear in the notes. Never delete or renumber an existing week's entries — later weeks may reuse or build on an earlier formula, but the original entry stays as the reference.

---

## Week 1 — Human Visual System
*(full derivations and diagrams in [`week1-study-notes.md`](./week1-study-notes.md); this is the lookup-speed reference)*

### Cone response as a linear map (§3)

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

### Weber contrast (§11)

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

### Michelson contrast (§11)

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

### Image frequency → physical spatial frequency (§12.2.1)

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

### 2D sinusoidal grating (§12.4.2)

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

### DFT array index → cycles per pixel (§12.4.3)

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

### Hybrid-image frequency-domain combination (§12.4.5)

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

### Hybrid image as a sum of projections (§13.2)

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

## Week 2 — Digital Photography I (ray optics, aperture, sensor)
*(full derivations and diagrams in [`week2-study-notes.md`](./week2-study-notes.md); this is the lookup-speed reference)*

### Image formation as a linear map (§0)

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

### Perspective projection (pinhole camera matrix) (§1)

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

### Optimal pinhole diameter (§2.1)

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

### Thin lens equation (Gaussian lens formula) (§4.1, §4.3)

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

### Magnification (§4.1)

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

### Ray-transfer (ABCD) matrices (§4.1, Linear-algebra view)

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

### Converting a pixel blur threshold to a length (§9.3)

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

### Depth of field (§9.3)

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

### Near and far distance of depth of field (§9.3)

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
| m | magnification at the focused pair (S, S') — see the Magnification (§4.1) entry above for how to compute it |
| D | aperture diameter |

---

### Hyperfocal distance (§9.4)

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

---

### Diffraction limit (Abbe's formula) (§10)

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

### Exposure (§13.2)

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

### Exposure value (§13.3)

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

### Motion blur streak length (§13.5)

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

### LiDAR range equation (§13.8)

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

### Shot noise (Poisson statistics) (§16.2)

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

### Signal-to-noise ratio (§16.3)

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

### Noise as an additive vector (§16.3, Linear-algebra view)

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

### Spectral sensitivity function (SSF) integral (§1)

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

### Tristimulus vector and the sensitivity matrix A (§2)

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

### Color matching as a linear system (§3)

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

### CIE RGB → XYZ conversion matrix (§4)

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

### CIE xy chromaticity projection (§5)

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

### Gamut triangle / barycentric coordinates (§6)

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

### Display P3 → sRGB conversion matrix (§7)

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

### White balance as a diagonal matrix (§9.1)

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

### Naive (linear) green-channel demosaicking (§10.1)

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

### Bayer mosaicking as a selection matrix (§10.1)

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

### RGB ↔ Y′CbCr conversion (§10.3)

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

### Malvar-He-Cutler gradient-corrected demosaicking (§10.5)

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
| ĝ_lin, r̂_lin | The plain naive-average estimate (§10.1) for that channel/pixel |
| D_R, D_G, D_B | Discrete Laplacian (local curvature) of the actually-sampled channel, from same-color samples two pixels away; D_G uses a different 9-point weighting (not given numerically in these notes) |
| α, β, γ | Fixed, empirically optimized gain constants controlling how strongly the correction is trusted |
| r(x,y) | The actually-measured red value at (x,y) (analogous for b in D_B) |
| (m,n) | The four cardinal offsets two pixels away — nearest same-color Bayer samples |

---

### Mean squared error (MSE) (§10.6)

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

### Peak signal-to-noise ratio (PSNR) (§10.6)

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

### General weighted-average denoising framework (§11.1)

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

### Gaussian filter spatial weight (§11.2)

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

### Gaussian blur's frequency response (§11.2)

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

### Median filter (§11.3)

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

### Bilateral filter weight (§11.4)

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

### Non-local means weight and patch distance (§11.5)

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

### Unsharp masking (§11.8)

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
| G_σ | The Gaussian-blur matrix (§11.2) |
| i | The image, flattened into a vector |

---

### Gamma correction — simple power law (§12)

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

### Gamma correction — exact sRGB piecewise curve (§12)

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

### Camera RGB → CIE XYZ calibration matrix (§13)

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

### sRGB ↔ XYZ conversion matrices (§13)

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

### DCT as a change of basis (§14)

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
