# CSC2529 Computational Imaging — Week 5 Study Notes

**Topic:** Review of Sampling, Deconvolution, Linear Systems — the Fourier transform, sampling and aliasing, the DFT/FFT, diffraction and the lens as a low-pass filter, image filtering, deconvolution (inverse and Wiener filtering), and linear inverse problems (least squares, gradient descent, stochastic gradient descent)
**Source:** Lecture 5 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 4 ("PS4," the HW4 problem session), all three tasks: Task 1 image filtering (primal vs. Fourier domain), Task 2 deconvolution (inverse filtering and Wiener deconvolution), Task 3 gradient descent and stochastic gradient descent.
**HW4 supplements:** §16.4, §22, §23, §25, §29–§32 go deeper than the slides because HW4 (as described in PS4) depends on them: filtering in both domains and `psf2otf`, inverse filtering, the Wiener filter and its SNR knob, MSE/PSNR, the least-squares gradient, gradient descent and stochastic gradient descent. They explain each method and the quantities it needs, but never compute the assignment's own answers.
**Ties to earlier weeks, covered again in full here.** Much of this lecture revisits ideas that earlier weeks introduced in a lighter, homework-driven form: the Fourier transform and convolution (Week 1 §19–§21), diffraction (Week 2 §3, §12), the optical low-pass filter and aliasing in demosaicking (Week 3 §14.2), unsharp masking (Week 3 §17), MSE/PSNR (Week 3 §13), and the PSF/OTF (Week 4 §18). This file re-explains each of them from scratch, at this week's greater depth, so it can be read on its own; earlier weeks are named only so you can see where an idea first appeared.
**Order differs from the slides.** The lecture opens with the Fourier transform, then jumps to sampling, then to lenses and diffraction, then to filtering, and only near the end reviews linear algebra. These notes reorder it so each section uses only ideas already built: complex numbers and waves → the Fourier transform → convolution and the convolution theorem → a small set of standard functions (box, sinc, triangle, Gaussian, impulse train) → sampling and aliasing → the DFT and FFT → the lens and sensor as filters (diffraction, pixel integration) → filtering → aliasing in practice (downsampling, wagon wheels, LiDAR range ambiguity, the sensor's anti-aliasing filter) → deconvolution → linear systems and their solvers. The linear-algebra vocabulary each section needs (matrix–vector product, eigenvector, null space) is introduced where it is first used. Each section ends with a **Summary** box; forward pointers appear only there, as optional "where this goes next" lines.
**Scope:** Announcements and the "next lecture" teaser slide are skipped. The lecture's video and textbook readings (a visual Fourier-transform introduction and a Fourier-transform book) are not summarized separately; everything they would add is built here.

---

# Part 1 — The Fourier Toolkit

## 1. Orientation: One Lecture, Three Meanings of "Frequency"

This lecture is a review that makes precise several ideas earlier weeks used loosely. Its outline has four parts:

1. **Fourier transform review** — writing any signal as a sum of waves.
2. **Fourier transforms in imaging** — why a lens and a pixel each act as a blur, and what blur does to each wave.
3. **Image filtering, anti-aliasing and deconvolution** — removing waves on purpose, avoiding fake waves when sampling, and trying to undo blur.
4. **Linear systems review** — the matrix view, b = Ax, that ties all of it together and leads to Week 6's optimization methods.

**The word "frequency" means three different things this week.** Each section says which one it means.

| Name | What repeats | Units | Where it appears this week |
|---|---|---|---|
| **Temporal frequency** | a signal over *time* (a sound, a flickering light, a spinning wheel, a LiDAR waveform) | hertz (Hz) = cycles per second | the sampling exercise (§8), the wagon-wheel effect and LiDAR range ambiguity (§20) |
| **Spatial frequency** | brightness across *space* (stripes on a page or on the sensor) | cycles per millimeter (or per degree of visual angle, Week 1 §16) | lens and pixel blur (§12–§15) |
| **Image frequency** | brightness across the *pixel grid* of a stored image | cycles per pixel | filtering, `fft2`, downsampling, deconvolution (§16–§25) |
| **Optical frequency / wavelength of light** | the light wave itself | wavelength λ in nanometers (green ≈ 550 nm) | diffraction (§13) only |

Image frequency is the precise, file-bound sub-flavor of spatial frequency: the same stripes have one fixed image frequency (cycles per pixel) but a spatial frequency that depends on the pixel size. Whenever this file says "frequency" inside an image-processing formula, it means image frequency; inside a lens or sensor formula, spatial frequency in cycles/mm; inside a time-signal formula, temporal frequency in Hz. The wavelength of light is never called a "frequency" here.

**Symbols this week (several letters are reused by the slides for different things).**

| Symbol | Meaning in this file |
|---|---|
| *j* | the imaginary unit, √−1. The slides write it as *i* on some slides and *j* on others; these notes always write *j*, because *i* is the image in Part 6 |
| ξ (xi) | a 1D frequency variable (the slides' notation) |
| *k_x*, *k_y* | 2D spatial (or image) frequencies, horizontal and vertical |
| *n*, *k* inside square brackets, *x*[*n*], *x̂*[*k*] | sample index and DFT frequency index |
| *k* (alone, in *i* ∗ *k* = *b*), *c* | the blur kernel (PSF). *K* = its Fourier transform, the OTF |
| *i*, *b*, *n* (Part 6) | sharp image, blurred measurement, noise |
| **x**, **b**, **A** (Part 7) | unknown image vector, measurement vector, image-formation matrix |
| λ | wavelength of light in Part 3; regularization weight in Part 7 |
| μ | an eigenvalue (Part 7) |
| σ | the width of a Gaussian kernel; σ_n is a noise standard deviation |
| α | gradient-descent step size |

> **Summary**
> - The lecture reviews four connected tools: the Fourier transform, Fourier analysis of lenses and sensors, filtering/anti-aliasing/deconvolution, and linear systems.
> - "Frequency" means temporal (Hz), spatial (cycles/mm), or image (cycles/pixel) frequency; light's wavelength is a separate thing.
> - Next: the two ingredients of every Fourier formula, waves and complex numbers (§2).

---

## 2. Waves and Complex Numbers, from Scratch

**Why this comes first.** Every Fourier formula this week contains a term like *e*^{*j*2πξ*x*}. That term is just a compact way of writing a wave. This section builds it in three steps: a real wave, a complex number, and Euler's formula that joins them.

### 2.1 A real wave: amplitude, frequency, phase

*Analogy:* a row of ocean swells passing a pier. How tall the swells are, how closely they are packed, and where the first crest sits are three independent facts.

```
s(x) = A · cos(2π ξ x + φ)
```

| Symbol | Meaning | Units | Who sets it |
|---|---|---|---|
| *x* | position (or time, for a time signal) | mm, pixels, or seconds | the axis you measure along |
| *A* | **amplitude**: half the peak-to-trough height | same units as the signal (e.g. brightness) | the signal |
| ξ | **frequency**: how many full cycles fit in one unit of *x* | cycles per unit of *x* | the signal |
| φ | **phase**: how far the wave is shifted, as an angle | radians (2π = one full cycle) | the signal |
| 2π | converts "cycles" to the radians that cos expects | — | fixed |

**Intuition for the shape.** cos repeats every 2π radians. Writing the angle as 2πξ*x* means that each time *x* grows by 1/ξ, the angle grows by 2π, so the wave repeats once. That is why the **period** (the distance between crests) is 1/ξ. Adding φ slides the whole wave sideways without changing its shape.

> **Worked example.** *s*(*x*) = 2·cos(2π·0.25·*x* + π/2), with *x* in pixels. Amplitude 2; frequency 0.25 cycles/pixel, so period 1/0.25 = 4 pixels; phase π/2 (a quarter cycle). Sampled at *x* = 0, 1, 2, 3: angles π/2, π, 3π/2, 2π, so values 0, −2, 0, 2. The pattern repeats every 4 pixels, as the period says.

### 2.2 Complex numbers as arrows

A **complex number** *z* = *a* + *j b* is a pair of real numbers (*a*, *b*), drawn as an arrow from the origin to the point (*a*, *b*) in a plane. The horizontal axis is the **real part**, the vertical axis the **imaginary part**; *j* is defined by *j*² = −1.

Two numbers describe the arrow just as well as (*a*, *b*):

- **Magnitude** |*z*| = √(*a*² + *b*²): the arrow's length.
- **Angle** (also **phase** or **argument**) ∠*z* = atan2(*b*, *a*): the direction it points.

**Why complex numbers suit waves.** Multiplying two complex numbers **multiplies their lengths and adds their angles**. So multiplying by a complex number *A e*^{*j*φ} (length *A*, angle φ, see next subsection) means "scale by *A*, rotate by φ." Scaling and shifting a wave are exactly what blur and filtering do to each frequency, so one complex number per frequency is enough to describe them.

The **complex conjugate** *z** = *a* − *j b* mirrors the arrow across the horizontal axis: same length, opposite angle. Useful facts: *z*·*z** = |*z*|², and *z* + *z** = 2*a* (twice the real part).

**Linear-algebra view (multiplying by a complex number is a 2×2 rotation-and-scaling matrix).** Write *z* = *a* + *jb* as the column vector (*a*, *b*). Multiplying by *w* = *A e*^{*j*φ} sends it to

```
[ Re(w·z) ]       [ cos φ   −sin φ ] [ a ]
[ Im(w·z) ]  = A · [ sin φ    cos φ ] [ b ]
```

The matrix is a **rotation** by φ times a **scaling** by *A*. So "multiply each frequency's coefficient by a complex number" (what the convolution theorem will say a blur does, §5) is, for each frequency separately, a tiny 2×2 rotate-and-scale matrix acting on that frequency's (cosine, sine) pair.

### 2.3 Euler's formula: the spinning arrow

```
e^{jθ} = cos θ + j sin θ
```

*Analogy:* the tip of a clock hand. As the angle θ grows, the arrow of length 1 sweeps around the circle. Its shadow on the horizontal axis traces cos θ; its shadow on the vertical axis traces sin θ.

- *e*^{*j*θ} is the unit-length arrow at angle θ.
- *A e*^{*j*φ} is the arrow of length *A* at angle φ. This is the **polar form**, and it is how the lecture packs amplitude and phase into one number (slide 11: "*A e*^{*j*φ}").
- *e*^{*j*2πξ*x*} is an arrow that spins as *x* increases, making ξ full turns per unit of *x*. Its real part is cos(2πξ*x*): a wave of frequency ξ.
- *A e*^{*j*φ}·*e*^{*j*2πξ*x*} = *A e*^{*j*(2πξ*x* + φ)}. Its real part is *A* cos(2πξ*x* + φ), exactly the wave of §2.1, and its imaginary part is *A* sin(2πξ*x* + φ). This is the identity on slide 12.

**Negative frequencies.** Adding the arrow spinning one way to the arrow spinning the other way cancels the vertical parts:

```
cos(2π ξ x) = ½ e^{j2πξx} + ½ e^{−j2πξx}
```

So one real cosine is two complex spinning arrows, one at frequency +ξ and one at −ξ, each with half the amplitude. A "negative frequency" is not a physical thing; it is the second arrow needed to cancel the imaginary parts and leave a real wave. This is why every real signal's spectrum has matching entries at +ξ and −ξ (§3.3).

> **Worked example.** *A* = 2, φ = π/2. Then *A e*^{*j*φ} = 2(cos 90° + *j* sin 90°) = 2*j*: an arrow of length 2 pointing straight up. Times *e*^{*j*2πξ*x*}, its real part is 2cos(2πξ*x* + π/2) = −2 sin(2πξ*x*): the same frequency, amplitude 2, shifted a quarter cycle.

> **Summary**
> - A wave *A* cos(2πξ*x* + φ) has amplitude *A*, frequency ξ (period 1/ξ) and phase φ.
> - A complex number is an arrow; multiplying complex numbers multiplies lengths and adds angles (a 2×2 rotate-and-scale matrix).
> - Rule to remember: **e^{jθ} = cos θ + j sin θ**, so *A e*^{*j*φ} stores an amplitude and a phase in one number, and *e*^{*j*2πξ*x*} is a wave of frequency ξ.
> - A real cosine = two arrows at +ξ and −ξ.
> - Next: the Fourier transform writes any signal as a sum of these spinning arrows (§3).

---

## 3. The Fourier Transform

### 3.1 The idea and the formula (1D)

*Analogy:* a chord on a piano sounds like one sound, but it is several pure notes played together. The Fourier transform is the procedure that lists which notes are present and how loud each one is.

The slides' claim (slide 8): any continuous, integrable function can be written as a sum (an integral, i.e. a continuous sum) of sines and cosines.

```
f(x)  = ∫_{−∞}^{∞} f̂(ξ) · e^{ j2πξx} dξ          (inverse transform: rebuild the signal from waves)
f̂(ξ) = ∫_{−∞}^{∞} f(x) · e^{−j2πξx} dx          (forward transform: measure how much of each wave)
```

**What goes in and what comes out.** In: a signal *f*(*x*), one value per position (or time). Out: its **spectrum** *f̂*(ξ), one complex number per frequency ξ. The magnitude |*f̂*(ξ)| says how much of frequency ξ is present; the angle ∠*f̂*(ξ) says how that wave is shifted.

**Intuition, step by step.**

1. An integral ∫ … d*x* is the limit of a sum: chop the *x*-axis into tiny pieces of width d*x*, multiply each piece's value by d*x*, and add. So read ∫ as "add up over every position."
2. *Forward transform.* Multiply the signal by *e*^{−*j*2πξ*x*}, an arrow spinning at frequency ξ the *opposite* way, then add over all *x*. If the signal contains a wave at frequency ξ, that wave spins at the same rate as the probe and cancels its rotation, so the products all point the same direction and add up to something large. Every other frequency keeps spinning relative to the probe, so its products point in every direction and cancel to (nearly) zero. The result measures "how much of the signal looks like a wave at ξ."
3. *Inverse transform.* Take every frequency's arrow *e*^{*j*2πξ*x*}, scale and rotate it by the measured coefficient *f̂*(ξ), and add them all back up. You get the signal again. Nothing is lost.

| Symbol | Meaning | Units |
|---|---|---|
| *f*(*x*) | the signal in the **primal domain** (the slides' name for the original space or time domain) | signal units (e.g. brightness) |
| *x* | position or time | mm, pixels, s |
| ξ | frequency | cycles per unit of *x* |
| *f̂*(ξ) | spectrum: one complex coefficient per frequency, in the **Fourier domain** | signal units × unit of *x* |
| *e*^{±*j*2πξ*x*} | the spinning arrow (wave) of frequency ξ | dimensionless |
| d*x*, dξ | the tiny step of the continuous sum | units of *x*, of ξ |

The two formulas differ only in the sign of the exponent. That symmetry is why "transform, then transform again" almost gives back the signal, and why every pair of functions in §6 can be read in both directions.

### 3.2 From 1D to 2D: images

An image varies along two directions, so its waves do too. The 2D transform (slide 9) is

```
f(x, y) = ∫∫ F(k_x, k_y) · e^{ j2π(k_x·x + k_y·y)} dk_x dk_y
```

**What each building block looks like.** The real part of *e*^{*j*2π(*k_x x* + *k_y y*)} is cos(2π(*k_x x* + *k_y y*)): a **grating**, a pattern of parallel stripes.

- *k_y* = 0: brightness changes only with *x*, so the stripes are vertical.
- *k_x* = 0: horizontal stripes.
- Both nonzero: diagonal stripes, perpendicular to the direction of the vector (*k_x*, *k_y*).
- The stripes' frequency (how tightly packed) is √(*k_x*² + *k_y*²); their spacing is its reciprocal.

**Reading a 2D spectrum picture (slides 4–7).** The lecture shows the parrots photo's magnitude spectrum: a gray square, brightest at its center, with a faint cross through it.

- Each **point** in the spectrum is one grating. Its distance from the center is the stripes' frequency; its direction from the center is the direction the stripes change in. Slide 5 picks a point near the center (wide, slowly varying diagonal stripes); slide 6 a point farther out (tight stripes).
- The center (*k_x* = *k_y* = 0) is the **DC component**: the zero-frequency "wave," a constant, equal to the image's average brightness. ("DC" is borrowed from electronics' direct current.)
- Natural photos have most of their energy at low frequencies, so the center is brightest and brightness falls off outward. The spectrum is usually shown on a logarithmic brightness scale so the faint high frequencies remain visible.
- The bright cross along the axes comes from the image's borders: the transform treats the image as repeating, and the jump from the right edge back to the left edge acts like a strong vertical edge (and likewise top/bottom), which spreads energy along the axes (§9 explains the repetition).

**Each coefficient is a cosine with amplitude and phase** (slides 10–12). Writing *F*(*k_x*, *k_y*) = *A e*^{*j*φ} in polar form (§2.3), each term of the integral is

```
A·cos(2π[k_x x + k_y y] + φ) + j·A·sin(2π[k_x x + k_y y] + φ)
```

So: **an image is a sum of gratings at different amplitudes, phases and spatial frequencies** (slide 14's summary).

### 3.3 Conjugate symmetry: why real images have mirrored spectra

Slide 13: "Fourier coefficients of real signals are conjugate symmetric."

```
F(−k_x, −k_y) = F(k_x, k_y)*
```

**Why.** A real image has no imaginary part, so in the inverse transform all imaginary parts must cancel. §2.3 showed how that happens for one cosine: an arrow at +ξ paired with its mirror arrow at −ξ. The same pairing is forced at every frequency: the coefficient at −(*k_x*, *k_y*) must be the conjugate (same length, opposite angle) of the coefficient at +(*k_x*, *k_y*).

**Consequences.**

- The magnitude spectrum of a real image is symmetric through its center (rotate it 180° and it looks the same). That is the symmetry visible in every spectrum picture this week.
- Only half of the spectrum carries independent information; the other half is its mirror. A real *N*-sample signal has *N* real numbers, and its *N* complex coefficients (2*N* real numbers) are half redundant.
- When you filter a real image, your frequency mask must also be symmetric through the center, or the result will no longer be real.

> **Summary**
> - The Fourier transform measures how much of each wave *e*^{*j*2πξ*x*} a signal contains; the inverse transform adds the waves back up. Nothing is lost.
> - Rule to remember: **f̂(ξ) = ∫ f(x) e^{−j2πξx} dx** and **f(x) = ∫ f̂(ξ) e^{j2πξx} dξ**; in 2D each coefficient is a grating with amplitude, phase, frequency and orientation.
> - A spectrum picture: center = average brightness (DC), distance from center = stripe frequency, direction = stripe orientation.
> - Real images have conjugate-symmetric spectra: |*F*| looks the same rotated 180°.
> - Next: which half of each coefficient, magnitude or phase, carries the picture (§4).

---

## 4. Magnitude vs. Phase

Each Fourier coefficient has two parts: a magnitude (how strong a grating is) and a phase (where its stripes sit). Which one carries the recognizable content of a photo?

**The experiment (slides 15–16).** Take two photos, a cameraman and a cat. Compute both spectra. Build two hybrid spectra:

- the cameraman's **magnitudes** combined with the cat's **phases**, and
- the cat's magnitudes with the cameraman's phases.

Inverse-transform each. The first result looks like a noisy **cat**; the second like a noisy **cameraman**.

**Why phase wins.** An edge is a place where many gratings line up so their crests coincide. Phase decides *where* each grating's crests sit, so phase decides where edges appear, and edges are what we recognize. Magnitude mostly says how much energy each frequency has, and most natural photos have similar magnitude spectra (strong low frequencies, falling off outward). Swapping magnitudes therefore changes the overall "texture statistics" but not the layout.

**Why this matters later.**

- A blur kernel that is **symmetric** (like a Gaussian or a centered disc) has a real-valued spectrum, so it changes magnitudes but only ever flips phase by 0° or 180°. Its blur leaves edges in place, only softened.
- A kernel whose spectrum has negative regions (a disc's or a box's, §6) flips the phase of those frequencies by 180°. Deconvolution must get these flips right, which is one more reason it needs the kernel's full complex spectrum, not just its magnitude.

> **Summary**
> - Magnitude says how strong each grating is; phase says where its stripes sit.
> - Swapping phases between two photos swaps what you recognize: **phase carries the structure** (edge locations).
> - Next: the operation that makes Fourier analysis essential to imaging, convolution (§5).

---

## 5. Convolution and the Convolution Theorem

### 5.1 Convolution, from scratch

*Analogy (the stamp view):* photograph a row of light bulbs slightly out of focus. Each bulb lands on the sensor as a small soft blob, not a dot. The photo is the sum of all the blobs, each one as bright as its bulb. The blob's shape is the **kernel**. Convolution is "place a copy of the kernel at every input point, scaled by that point's value, and add all the copies."

*The same thing read from the output's side (the window view):* each output value is a weighted average of nearby input values, with the kernel (flipped) as the weights.

**Discrete definition (sampled signals, e.g. one row of pixels):**

```
(x ∗ h)[n] = Σ_m h[m] · x[n − m]
```

**Continuous definition (signals on a continuous axis, e.g. light on the sensor):**

```
(f ∗ g)(x) = ∫ g(u) · f(x − u) du
```

| Symbol | Meaning |
|---|---|
| *x*[*n*] or *f*(*x*) | the input signal (e.g. sharp image brightness) |
| *h*[*m*] or *g*(*u*) | the **kernel** (also called **filter**, **impulse response**, or for optics **point spread function, PSF**) |
| *n*, *x* | the output position being computed |
| *m*, *u* | how far from the output position the kernel weight sits |
| ∗ | the convolution operator (not multiplication) |

**Intuition for *x*[*n* − *m*].** The weight *h*[*m*] multiplies the input that sits *m* steps *behind* the output position. Equivalently, input sample *x*[*p*] contributes *x*[*p*]·*h*[*m*] to output position *p* + *m*: a copy of the kernel, scaled by *x*[*p*], starting at *p*. That is the stamp view. In the window view the kernel appears reversed ("flipped"), which matters only for asymmetric kernels.

> **Worked example (stamp view).** Signal *x* = [0, 2, 0, 1, 0] (two "bulbs," brightness 2 at position 1 and 1 at position 3), kernel *h* = [0.25, 0.5, 0.25] centered (positions −1, 0, +1). Bulb 1 stamps 2·[0.25, 0.5, 0.25] = [0.5, 1, 0.5] at positions 0–2. Bulb 2 stamps [0.25, 0.5, 0.25] at positions 2–4. Adding: [0.5, 1, 0.75, 0.5, 0.25]. The two sharp spikes became two overlapping blobs; position 2, between them, picked up light from both. Total brightness: 2 + 1 = 3 before, 0.5 + 1 + 0.75 + 0.5 + 0.25 = 3 after, because the kernel sums to 1.

**Key vocabulary.**

- **Impulse** (or **delta**, δ): a signal that is 1 at one point and 0 elsewhere. Convolving with it returns the kernel itself, which is why the kernel is called the **impulse response**. In optics the "impulse" is one point of light and its image is the **point spread function (PSF)**.
- **Linear**: blurring a sum gives the sum of the blurs, and blurring a scaled signal scales the blur.
- **Shift-invariant**: shifting the input shifts the output by the same amount; the same kernel applies everywhere.
- **LSI system** (linear shift-invariant): any system with both properties. **Every LSI system is a convolution with its impulse response.** This is why one PSF describes a whole lens, *provided* its blur is the same everywhere (§12 notes when it is not).
- **Normalized kernel**: weights summing to 1, so flat regions keep their brightness and total light is conserved (PS4: "normalize the filter so it sums to 1").

**Properties** (all follow from the definition): commutative (*x* ∗ *h* = *h* ∗ *x*), associative (two blurs in a row equal one blur by the combined kernel), distributive (*x* ∗ (*h*₁ + *h*₂) = *x* ∗ *h*₁ + *x* ∗ *h*₂), and *x* ∗ δ = *x*.

### 5.2 The convolution theorem

Slide 17 calls this "critical":

```
x ∗ g = F⁻¹{ F{x} · F{g} }          equivalently    F{x ∗ g} = F{x} · F{g}
```

**In words:** convolving two signals in the primal domain is the same as multiplying their spectra, frequency by frequency, in the Fourier domain.

**Why it is true, in three steps.**

1. *A pure wave goes through any LSI system unchanged in frequency.* Feed in *e*^{*j*2πξ*x*}. Shift-invariance says a shifted input gives a shifted output. Shifting this wave by *d* just multiplies it by the constant *e*^{−*j*2πξ*d*} (rotating the arrow), and linearity says the output gets multiplied by the same constant. The only functions with this property are multiples of the same wave. So the output is *G*(ξ)·*e*^{*j*2πξ*x*}: the same wave, scaled and rotated by one complex number *G*(ξ).
2. *That number is the kernel's spectrum.* Plug the wave into the convolution integral: ∫ *g*(*u*) *e*^{*j*2πξ(*x*−*u*)} d*u* = *e*^{*j*2πξ*x*} · ∫ *g*(*u*) *e*^{−*j*2πξ*u*} d*u* = *e*^{*j*2πξ*x*} · *ĝ*(ξ). So *G*(ξ) = *ĝ*(ξ), the Fourier transform of the kernel.
3. *Assemble.* Any input is a sum of waves (§3). Convolution is linear, so each wave is handled separately: multiplied by *ĝ*(ξ). Adding the results gives an output whose spectrum is *x̂*(ξ)·*ĝ*(ξ).

| Term | Meaning |
|---|---|
| F{*x*} | spectrum of the input |
| F{*g*} | spectrum of the kernel, its **frequency response** (for a lens, the **optical transfer function, OTF**, §14). A value near 1 passes that frequency; near 0 removes it |
| · | ordinary multiplication, one frequency at a time |
| F⁻¹ | the inverse transform, back to the primal domain |

**Why it matters.** (a) It makes blur easy to *understand*: look at where |F{*g*}| is small to see what detail is lost. (b) It makes blur cheap to *compute* for big kernels (§11, §16). (c) It makes deconvolution conceivable: if blur multiplies, perhaps dividing undoes it (§22).

> **Worked example (Gaussians, using the result of §6.4).** A Gaussian blur of width σ₁ followed by one of width σ₂ equals one Gaussian blur of width √(σ₁² + σ₂²). By the theorem: each Gaussian's spectrum is a Gaussian *e*^{−2π²σ²ξ²}, and multiplying two of them adds the exponents: *e*^{−2π²(σ₁² + σ₂²)ξ²}, which is the spectrum of a Gaussian of width √(σ₁² + σ₂²). Two blurs of σ = 3 and σ = 4 pixels give one blur of σ = 5 pixels.

**Linear-algebra view (convolution is a circulant matrix that the Fourier basis diagonalizes).** Flatten a signal of *N* samples into a vector **x**. Convolution with a fixed kernel is linear, so it is some *N*×*N* matrix **C** acting on **x**.

- *Its structure.* Shift-invariance means each row is the row above shifted one place right. With wrap-around edges (the assumption the discrete Fourier transform makes, §9), this is a **circulant matrix**: one row pattern, rotated one step per row. Without wrap-around it is a **Toeplitz** matrix (constant along each diagonal).
- *Its eigenvectors.* An **eigenvector** of a matrix is a vector the matrix only rescales, never turns; the rescaling factor is its **eigenvalue**. Step 1 above says exactly that every sampled wave is an eigenvector of **C**, and step 2 says its eigenvalue is the kernel's spectrum at that frequency.
- *Diagonalization.* Writing **F** for the matrix that takes a signal to its spectrum (built in §10), **C** = **F**⁻¹ · diag(*ĉ*) · **F**: transform, multiply each frequency by its own number, transform back. The convolution theorem *is* this diagonalization.
- *Example.* For *N* = 4 and kernel [0.5, 0.25, 0, 0.25] (half weight on the sample itself, a quarter on each neighbor, wrapping around), **C** has rows [0.5, 0.25, 0, 0.25], [0.25, 0.5, 0.25, 0], [0, 0.25, 0.5, 0.25], [0.25, 0, 0.25, 0.5]. Its eigenvalues, one per frequency *k* = 0, 1, 2, 3, are [1, 0.5, 0, 0.5]: it keeps the average, halves the slow wave, and erases the fastest alternation. The 0 means the alternating vector [1, −1, 1, −1] is in this matrix's **null space** (the set of vectors it sends to zero), a fact §22 will lean on.

> **Summary**
> - Convolution stamps a scaled copy of the kernel at every input point and adds them; every linear shift-invariant system, including a lens with uniform blur, is a convolution with its impulse response (the PSF).
> - Rule to remember: **F{x ∗ g} = F{x}·F{g}**: blur multiplies each frequency by the kernel's spectrum.
> - Linear-algebra view: convolution is a circulant matrix; the waves are its eigenvectors and the kernel's spectrum lists its eigenvalues.
> - Next: the handful of standard kernels and signals this lecture uses, and their spectra (§6).

---

## 6. Six Functions and Their Fourier Transforms

The rest of the lecture is built from a few standard shapes. Each one is introduced with the problem it models, then its formula, then its transform. Every pair in this section has a plot in the artifact.

### 6.1 The impulse δ and the constant

- *What it models:* a single point of light, or a single sample.
- *Definition:* δ(*x*) is zero everywhere except at *x* = 0, with total area 1. (Think of a box of width ε and height 1/ε, with ε shrinking to zero.)
- *Key property (sifting):* ∫ *f*(*x*) δ(*x* − *a*) d*x* = *f*(*a*). Multiplying by a shifted impulse picks out one value.
- *Transform:* F{δ} = 1 for every frequency. A single point contains every wave equally. Conversely, a constant has all its energy at ξ = 0: F{1} = δ(ξ).

### 6.2 The box (rect) and the sinc

- *What it models:* a 1D aperture (a slit of width 1), a pixel averaging the light that falls on it (§15), a camera shutter open for a fixed time, a moving object's motion blur.
- *Definition:* rect(*x*) = 1 for |*x*| < ½, and 0 otherwise.
- *Transform:*

```
F{rect(x)} = sinc(ξ) = sin(πξ) / (πξ)          (and sinc(0) = 1)
```

- *Shape of the sinc:* a central peak of height 1 at ξ = 0, then smaller and smaller ripples that alternate positive and negative, crossing **exactly zero** at ξ = ±1, ±2, ±3, … (wherever sin(πξ) = 0, except at 0).
- *Why the zeros:* a wave with exactly one full cycle (or two, or three) across the box's width has as much positive as negative inside the box, so averaging it over the box gives zero. That wave is completely erased.
- This course uses the **normalized sinc**, with π inside. Some books define sinc(*x*) = sin(*x*)/*x* instead, which moves the zeros to multiples of π.

### 6.3 The triangle (tent) and sinc²

- *What it models:* the overlap of a box with a shifted copy of itself, which turns out to be a lens's transfer function (§13).
- *Definition:* tent(*x*) = 1 − |*x*| for |*x*| < 1, and 0 otherwise. It is a box convolved with itself: rect ∗ rect = tent.
- *Transform:* by the convolution theorem, F{tent} = F{rect}·F{rect} = **sinc²(ξ)**. sinc² has the same zeros as sinc but is never negative, and its ripples die off faster.

### 6.4 The Gaussian

- *What it models:* a smooth blur (Week 3 §12's Gaussian filter, PS4's `fspecial_gaussian_2d`), and many real lens blurs approximately.
- *Definition:* *g*(*x*) = (1/(σ√(2π))) *e*^{−*x*²/(2σ²)}, a bell curve of width σ and area 1.
- *Transform:* *ĝ*(ξ) = *e*^{−2π²σ²ξ²}, **another Gaussian**, of width 1/(2πσ) (slide 18 shows a narrow Gaussian in the primal domain paired with a wide one in the Fourier domain).
- *Why it matters:* the Gaussian is the one common blur with **no ripples and no negative values** in either domain. That is why Gaussian low-pass filtering does not "ring" (§16).

> **Worked example.** A Gaussian blur with σ = 2 pixels has a spectrum of width 1/(2π·2) ≈ 0.080 cycles/pixel. At that frequency the spectrum has fallen to *e*^{−½} ≈ 0.61; at twice that (0.16 cycles/pixel) to *e*^{−2} ≈ 0.14. So stripes finer than about one cycle per 6 pixels are mostly erased by this blur.

### 6.5 The impulse train (comb) and its transform

- *What it models:* **sampling** (§7). Measuring a signal only at evenly spaced points is multiplying it by a row of impulses.
- *Definition:* comb_T(*x*) = Σ_n δ(*x* − *nT*): impulses spaced *T* apart, forever.
- *Transform:* another comb, with spacing 1/*T* (scaled by 1/*T*):

```
F{ comb_T } = (1/T) · comb_{1/T}
```

- *Why:* a signal that repeats every *T* can contain only waves that also repeat every *T*: frequencies 0, 1/*T*, 2/*T*, …. The comb repeats every *T* and is spiky enough to contain all of them equally.

### 6.6 The scaling theorem: wide in one domain means narrow in the other

```
F{ f(x/a) } = |a| · f̂(a·ξ)
```

*Analogy:* playing a recording at half speed stretches it in time and lowers every pitch by half. Stretching a signal by a factor *a* squeezes its spectrum by the same factor (and scales its height).

**Examples that recur this week.**

- rect(*x*/2) (a box twice as wide) has transform 2·sinc(2ξ): a sinc twice as tall and **half as wide**, with zeros at ξ = ±½, ±1, ….
- A Gaussian of width σ has a spectrum of width 1/(2πσ): double σ, halve the spectrum's width.
- A comb of spacing *T* has a spectrum of spacing 1/*T*: sample twice as densely and the spectral copies move twice as far apart (§7).

This single rule explains three facts later in the week: a **bigger aperture gives a smaller blur** (§13), a **bigger pixel loses more fine detail** (§15), and a **wider blur kernel has a narrower OTF** (§16).

> **Summary**
> - Six shapes recur: impulse ↔ constant; box ↔ sinc (exact zeros at the integers); tent = box ∗ box ↔ sinc²; Gaussian ↔ Gaussian (no ripples); comb of spacing *T* ↔ comb of spacing 1/*T*.
> - Rule to remember: **stretching by a in one domain squeezes by a in the other** (scaling theorem).
> - Next: sampling is multiplication by a comb, so its effect on the spectrum follows immediately (§7).

---

# Part 2 — Sampling and the Discrete Fourier Transform

## 7. Sampling: What Happens to the Spectrum

**The problem.** Light on a sensor, sound in the air, and a LiDAR return waveform are continuous. A computer stores only values at evenly spaced points: pixels, audio samples, digitizer ticks. What does keeping only those points do to the signal's frequency content?

**Sampling as multiplication by a comb (slide 20).** Keeping only the values at *x* = 0, *T*, 2*T*, … is the same as multiplying the continuous signal by the comb of §6.5:

```
f_sampled(x) = f(x) · comb_T(x)
```

- *T* is the **sampling interval** (pixel pitch, or seconds between samples).
- *f_s* = 1/*T* is the **sampling rate** (samples per unit length or per second).

**What it does to the spectrum.** The convolution theorem works in both directions: multiplying in the primal domain is convolving in the Fourier domain. And F{comb_T} is a comb of spacing *f_s* (§6.5). Convolving a spectrum with a comb stamps a copy of the spectrum at every comb tooth (stamp view of convolution, §5.1). So:

```
F{ f · comb_T } = (1/T) · Σ_m f̂(ξ − m·f_s)
```

**In words:** the sampled signal's spectrum is the original spectrum **plus shifted copies of it, centered at every multiple of the sampling rate** (slide 20: "shifted copies at *f_s*").

| Symbol | Meaning | Units |
|---|---|---|
| *f*(*x*) | the continuous signal | signal units |
| *T* | sampling interval | mm, pixels, or s |
| *f_s* = 1/*T* | sampling rate | samples per mm, per pixel, or per second (Hz) |
| *m* | which copy (…, −1, 0, 1, …) | integer |
| *f̂*(ξ − *m f_s*) | the original spectrum shifted to sit around *m f_s* | |

**Linear-algebra view (sampling a finite signal is a selection matrix).** For a signal already stored as *N* fine samples in a vector **x**, keeping every *D*-th sample is a matrix **S** of size (*N*/*D*)×*N* with exactly **one 1 per row** and zeros elsewhere: row *r* has its 1 in column *rD*. **S x** is the sampled signal. **S** has far fewer rows than columns, so it has a large **null space**: any change to **x** that is zero at the kept positions is invisible after sampling. Aliasing (§8) is the frequency-domain description of exactly this lost information.

> **Summary**
> - Sampling = multiplying by an impulse train of spacing *T*.
> - Rule to remember: **sampling at rate f_s copies the spectrum to every multiple of f_s**.
> - Linear-algebra view: subsampling is a selection matrix (one 1 per row) with a large null space.
> - Next: when the copies overlap, frequencies get confused: aliasing (§8).

---

## 8. The Nyquist–Shannon Sampling Theorem and Aliasing

### 8.1 The theorem

Suppose the signal contains no frequency above some highest frequency *f_max* (the signal is **band-limited**). Its spectrum lives between −*f_max* and +*f_max*, a band of total width 2*f_max*. After sampling, copies sit every *f_s* apart (§7). They do not overlap if each copy fits in the gap:

```
f_s ≥ 2·f_max          (Nyquist–Shannon sampling theorem; slide 94)
```

- **Nyquist rate**: 2*f_max*, the lowest sampling rate that avoids overlap for a given signal.
- **Nyquist frequency**: *f_s*/2, the highest frequency a given sampling rate can represent.
- If the copies do not overlap, the original can be recovered exactly: cut out the central copy with an ideal low-pass filter and inverse-transform (§16). This is the "reconstruction" half of the theorem.
- If they do overlap, a frequency from one copy lands where another copy's frequency should be. The two become indistinguishable after sampling. This is **aliasing**: a high frequency masquerading as ("taking the alias of") a lower one.

**Strictly greater, in practice.** A wave at exactly *f_s*/2 sampled at *f_s* gives two samples per cycle, which can land on the zero crossings and read as zero. Real systems sample comfortably above the Nyquist rate.

### 8.2 Where an aliased frequency lands

A frequency *f* sampled at rate *f_s* is indistinguishable from *f* − *m f_s* for every integer *m* (because *e*^{*j*2π(*f* − *m f_s*)·*nT*} = *e*^{*j*2π*f nT*}·*e*^{−*j*2π*mn*} and *e*^{−*j*2π*mn*} = 1 for whole numbers). The frequency you actually *see* is the one closest to zero:

```
f_apparent = | f − f_s · round(f / f_s) |
```

**Intuition.** Picture the frequency axis folded like a paper fan at every multiple of *f_s*/2. A frequency above *f_s*/2 folds back down. As the true frequency climbs steadily, the apparent frequency zig-zags between 0 and *f_s*/2 (the artifact plots this triangle-wave curve).

### 8.3 The lecture's sampling exercise, worked

Slides 22–31 sample a sinusoid at *f_s* = **20 Hz** (temporal frequency: 20 samples per second), with the signal frequency climbing from 4 Hz to 32 Hz. The Nyquist frequency is 10 Hz.

| True frequency | Below Nyquist (10 Hz)? | Apparent frequency, \|*f* − 20·round(*f*/20)\| | What the samples look like |
|---|---|---|---|
| 4 Hz | yes | 4 Hz | correct |
| 8 Hz | yes | 8 Hz | correct (only 2.5 samples per cycle, but still unambiguous) |
| 12 Hz | no | \|12 − 20\| = **8 Hz** | an 8 Hz wave |
| 16 Hz | no | \|16 − 20\| = **4 Hz** | a 4 Hz wave |
| 20 Hz | no | \|20 − 20\| = **0 Hz** | (nearly) constant |
| 24 Hz | no | \|24 − 20\| = **4 Hz** | a 4 Hz wave |
| 28 Hz | no | \|28 − 20\| = **8 Hz** | an 8 Hz wave |
| 32 Hz | no | \|32 − 40\| = **8 Hz** | an 8 Hz wave |

**Reading the slides' spectrum plots.** Each plot shows peaks at ± the true frequency plus the copies centered at the red lines (−20, 0, +20 Hz). For 4 Hz the peaks sit at ±4, ±16, ±24: the central copy is clean. For 16 Hz the same set of peaks appears (±4, ±16, ±24), which is exactly why 16 Hz and 4 Hz cannot be told apart from samples.

**Checking one pair numerically (24 Hz vs. 4 Hz).** At the sample times *t* = 0, 0.05, 0.10, 0.15, 0.20 s, cos(2π·24·*t*) = 1, 0.309, −0.809, −0.809, 0.309, and cos(2π·4·*t*) gives exactly the same five numbers. The 24 Hz wave wiggles 1.2 times between consecutive samples; the samples only see the leftover 0.2 cycles per sample, which is 4 Hz.

**About the 20 Hz slide.** Sampling a wave at exactly its own frequency catches it at the same point of its cycle every time, so every sample is identical: the wave looks like a constant (0 Hz). On slide 28 the orange samples instead drift slowly upward; that is consistent with the plot's sample grid being very slightly slower than exactly 20 Hz (for example samples spaced about 0.0503 s apart instead of exactly 0.05 s), so each sample lands a tiny bit later in the cycle. Either way, a 20 Hz wave sampled at 20 Hz is reported as (nearly) zero frequency.

### 8.4 Aliasing cannot be undone afterwards

Once two frequencies produce the same samples, no processing can tell which one was there (slide 125: "aliasing cannot be corrected digitally in post-processing"). The only cure is to remove frequencies above *f_s*/2 **before** sampling, with a low-pass filter. That is called **anti-aliasing**, and §19 and §21 show it twice: as a digital blur before downsampling, and as an optical blur in front of a camera sensor.

> **Summary**
> - Rule to remember: **f_s ≥ 2 f_max** (Nyquist–Shannon); the Nyquist frequency *f_s*/2 is the highest representable frequency.
> - Above it, a frequency folds back to **|f − f_s·round(f/f_s)|**: at 20 Hz sampling, 12 and 28 Hz look like 8 Hz, 16 and 24 Hz like 4 Hz, 20 Hz like 0 Hz.
> - Aliasing is permanent; prevent it by low-pass filtering *before* sampling.
> - Next: the mirror-image fact, that a *repeating* signal has a *sampled* spectrum (§9).

---

## 9. Periodicity and Discreteness Are Two Sides of One Coin

§7 showed: **sampled in the primal domain ⇒ repeating (periodic) in the Fourier domain**. Because the forward and inverse transforms have the same form (§3.1), the same argument runs the other way (slides 32–35):

**repeating (periodic) in the primal domain ⇒ sampled (discrete) in the Fourier domain.**

**Why.** A periodic signal with period *P* is one copy convolved with a comb of spacing *P*. By the convolution theorem its spectrum is the copy's spectrum *multiplied* by a comb of spacing 1/*P*: only frequencies 0, 1/*P*, 2/*P*, … survive. Intuitively, a signal that repeats every *P* can contain only waves that also fit a whole number of times into *P*. These discrete coefficients are called the **Fourier series coefficients** (slide 35).

| Primal domain | Fourier domain |
|---|---|
| continuous, not repeating | continuous, not repeating (the Fourier transform, §3) |
| sampled every *T* | repeating every 1/*T* (§7) |
| repeating every *P* | sampled every 1/*P* (Fourier series) |
| sampled **and** repeating | sampled **and** repeating: the **discrete Fourier transform** (§10) |

The last row is the only one a computer can store, because both sides are finite lists of numbers.

> **Summary**
> - Sampling in one domain causes repetition in the other, in both directions.
> - Rule to remember: **sampled ↔ periodic**; a computer's Fourier transform must therefore treat the signal as repeating.
> - Next: the formula that results, the DFT (§10).

---

## 10. The Discrete Fourier Transform (DFT)

### 10.1 The formula

**The problem.** We want the spectrum of a *stored* signal: *N* samples. §9 says the computer's version must treat those *N* samples as one period of a repeating signal (slides 36–38: "assume the primal domain signal is periodic"); then the spectrum is also *N* numbers. The formulas (slide 39, with *j* for the imaginary unit):

```
x̂[k] = Σ_{n=0}^{N−1} x[n] · e^{−j2πkn/N}              (forward DFT, k = 0, 1, …, N−1)
x[n]  = (1/N) · Σ_{k=0}^{N−1} x̂[k] · e^{ j2πkn/N}      (inverse DFT, n = 0, 1, …, N−1)
```

**Intuition.** These are the continuous formulas of §3.1 with the integral replaced by a sum over the *N* samples. The probe wave *e*^{−*j*2π*kn*/*N*} completes exactly *k* cycles across the *N* samples. *x̂*[*k*] measures how much of that wave the signal contains. The 1/*N* in the inverse undoes the fact that the forward sum adds up *N* terms.

| Symbol | Meaning | Units |
|---|---|---|
| *x*[*n*] | the *n*-th sample (pixel value, audio sample) | signal units |
| *n* | sample index, 0 to *N*−1 | — |
| *N* | number of samples | — |
| *k* | frequency index: the probe wave makes *k* full cycles across all *N* samples | cycles per *N* samples |
| *k*/*N* | the same frequency in cycles per sample (cycles per pixel for an image) | cycles/sample |
| *x̂*[*k*] | the *k*-th Fourier coefficient (complex) | signal units |

**Which index is which frequency.** Because the spectrum repeats every *N* (§9), index *k* and index *k* − *N* are the same frequency. So indices above *N*/2 are really **negative frequencies**: *k* = *N* − 1 is frequency −1/*N*. Libraries store them in that order, with zero frequency at index 0; `np.fft.fftshift` only reorders the array so zero frequency sits in the middle (Week 1 §19.4). Index *N*/2 is the Nyquist frequency, ½ cycle per sample, the fastest possible alternation (+, −, +, −).

### 10.2 A worked 4-sample example

Take *x* = [1, 2, 3, 4], *N* = 4. The probe waves *e*^{−*j*2π*kn*/4} take only the values 1, −*j*, −1, *j*:

| *k* | probe values for *n* = 0, 1, 2, 3 | *x̂*[*k*] = Σ *x*[*n*]·probe | magnitude | phase |
|---|---|---|---|---|
| 0 | 1, 1, 1, 1 | 1 + 2 + 3 + 4 = **10** | 10 | 0° |
| 1 | 1, −*j*, −1, *j* | 1 − 2*j* − 3 + 4*j* = **−2 + 2*j*** | 2.83 | 135° |
| 2 | 1, −1, 1, −1 | 1 − 2 + 3 − 4 = **−2** | 2 | 180° |
| 3 | 1, *j*, −1, −*j* | 1 + 2*j* − 3 − 4*j* = **−2 − 2*j*** | 2.83 | −135° |

Checks:

- *x̂*[0] = 10 = *N* × the average (2.5). The zero-frequency coefficient is always the sum of the samples.
- *x̂*[3] is the conjugate of *x̂*[1]: index 3 is frequency −1, and a real signal's spectrum is conjugate symmetric (§3.3).
- Inverse at *n* = 0: (1/4)(10 + (−2 + 2*j*) + (−2) + (−2 − 2*j*)) = 4/4 = 1 = *x*[0]. The other samples come back the same way (`np.fft.ifft` returns [1, 2, 3, 4]).

**Linear-algebra view (the DFT is a change of basis by an N×N matrix).** Stack the samples as a vector **x**. The forward DFT is a matrix–vector product **x̂** = **F x**, where **F** is the *N*×*N* **DFT matrix** with entries F[*k*, *n*] = *e*^{−*j*2π*kn*/*N*}. For *N* = 4:

```
      [ 1   1   1   1 ]        [1]     [ 10     ]
F  =  [ 1  −j  −1   j ]   F ·  [2]  =  [ −2 + 2j]
      [ 1  −1   1  −1 ]        [3]     [ −2     ]
      [ 1   j  −1  −j ]        [4]     [ −2 − 2j]
```

- Each **row** is one sampled wave (conjugated); each output entry is the inner product of the signal with that wave: "how much does the signal look like this wave?"
- The rows are **orthogonal**: the inner product of two different rows is 0, and of a row with its own conjugate is *N*. So **F**⁻¹ = (1/*N*)·**F**^H, where ^H means conjugate transpose. That is the inverse DFT formula above.
- Orthogonality makes the DFT a **change of basis**: from the standard basis (one spike per sample position) to the basis of *N* sampled waves. A change of basis loses nothing, which is why *N* numbers go in and *N* come out and the inverse recovers the signal exactly.
- The 2D DFT of an *H*×*W* image applies the 1D DFT to every row, then to every column. In matrix form it is the same change of basis on the image flattened to a vector of length *HW*.

### 10.3 The wrap-around assumption and why it matters

The DFT treats the *N* samples as one period of a repeating signal (§9). Two practical consequences:

- **Convolution via the DFT is circular.** Multiplying two DFTs and inverting gives a convolution in which the kernel wraps around the ends: blur from the right edge leaks onto the left edge. To get an ordinary (non-wrapping) convolution, pad both signals with zeros to at least *N* + *K* − 1 samples first (*K* = kernel length).
- **Edges look like jumps.** If the left and right edges of an image have different brightness, the repeated version has a sharp jump there, which adds energy along the spectrum's axes (the bright cross of §3.2).

> **Summary**
> - Rule to remember: **x̂[k] = Σ_n x[n] e^{−j2πkn/N}**, inverse with +*j* and a 1/*N*; index *k* is *k*/*N* cycles per sample, and indices above *N*/2 are negative frequencies.
> - Linear-algebra view: the DFT is an orthogonal change of basis, **x̂ = F x**, with **F**⁻¹ = **F**^H/*N*.
> - The DFT assumes the signal repeats, so its convolutions wrap around unless you zero-pad.
> - Next: computing it fast (§11).

---

## 11. The Fast Fourier Transform (FFT)

**The problem.** Computing **F x** directly costs *N*² multiply-adds (an *N*×*N* matrix times a vector). The **fast Fourier transform (FFT)** computes exactly the same numbers in about *N* log₂ *N* operations (slides 40–41, Cooley & Tukey 1965: "O(*N*²) → O(*N* log *N*)").

**How, in one idea: split, solve the halves, recombine.** Split the *N* samples into the even-indexed ones and the odd-indexed ones. Each half is a signal of length *N*/2, whose DFT can be computed separately. Because the probe waves *e*^{−*j*2π*kn*/*N*} repeat with period *N*, the two half-length DFTs can be combined into the full one with one extra multiply per output (a **twiddle factor** *e*^{−*j*2π*k*/*N*}):

```
x̂[k]        = E[k] + e^{−j2πk/N} · O[k]
x̂[k + N/2]  = E[k] − e^{−j2πk/N} · O[k]          (k = 0, …, N/2 − 1)
```

where *E* and *O* are the DFTs of the even and odd samples. Each half is split again, and again, until pieces have length 1. There are log₂ *N* levels of splitting, each costing about *N* operations, so the total is about *N* log₂ *N*. (The plain version requires *N* to be a power of 2; library FFTs handle any *N*.)

**How much faster, in numbers.**

| *N* | direct DFT, *N*² | FFT, *N* log₂ *N* | speed-up |
|---|---|---|---|
| 1 024 (one image row) | ≈ 1.05 million | ≈ 10 thousand | ≈ 100× |
| 1 048 576 = 2²⁰ (a 1-megapixel image, flattened) | ≈ 1.1 × 10¹² | ≈ 2.1 × 10⁷ | ≈ 52 000× |

This speed-up is what makes Fourier-domain filtering (§16) and Fourier-domain deconvolution (§22–§23) practical on real images.

**Linear-algebra view (the FFT factors the DFT matrix into sparse matrices).** The FFT does not change *what* is computed, only *how*: it writes the dense *N*×*N* matrix **F** as a product of log₂ *N* **sparse** matrices (mostly zeros), each with only 2 nonzero entries per row, times a **permutation** (a reordering that puts even-indexed samples first). For *N* = 4:

```
F₄ = B · (block-diagonal: F₂, F₂) · P
```

- **P** reorders [*x*₀, *x*₁, *x*₂, *x*₃] into [*x*₀, *x*₂, *x*₁, *x*₃] (evens, then odds).
- The middle matrix applies a 2-point DFT, [[1, 1], [1, −1]], to each half separately.
- **B** is the "butterfly" that combines them with the twiddle factors 1 and −*j*.

**Check on §10.2's signal.** For *x* = [1, 2, 3, 4]: evens [1, 3] have 2-point DFT *E* = [4, −2]; odds [2, 4] have *O* = [6, −2]. Then *x̂*[0] = 4 + 6 = 10, *x̂*[1] = −2 + (−*j*)(−2) = −2 + 2*j*, *x̂*[2] = 4 − 6 = −2, *x̂*[3] = −2 − (−*j*)(−2) = −2 − 2*j*: the same four numbers as the direct DFT.

Multiplying by a sparse matrix costs only as much as its nonzero entries, about 2*N* per factor, and there are log₂ *N* factors.

> **Summary**
> - The FFT computes the exact DFT in about *N* log₂ *N* operations instead of *N*² by splitting even/odd samples recursively.
> - Rule to remember: **O(N²) → O(N log N)**; about 52 000× faster for a 1-megapixel image.
> - Linear-algebra view: the dense DFT matrix factors into log₂ *N* sparse "butterfly" matrices and a permutation.
> - Next: Part 3 puts the Fourier toolkit to work on the camera itself, starting with why a real lens blurs (§12).

---

# Part 3 — The Lens and the Sensor as Filters

## 12. Why a Real Lens Blurs: the Point Spread Function

### 12.1 The ideal lens, restated

A **lens** is a curved piece of glass that bends (refracts) light so that all the rays leaving one point of the scene meet again at one point behind it. The **thin lens equation** (Week 2 §5) says where:

```
1/S′ + 1/S = 1/f
```

| Symbol | Meaning | Units | Who sets it |
|---|---|---|---|
| *S* | **object distance**: from the lens to the scene point | m | the scene |
| *S′* | **sensor distance**: from the lens to the plane where that point comes back into focus | m | you, by focusing (moving the lens) |
| *f* | **focal length**: the lens's bending strength (the sensor distance that focuses a point at infinity) | m | fixed by the lens |

*Intuition:* a stronger lens (smaller *f*) bends rays more sharply, so they meet closer behind it. A nearer object sends rays that are spreading more steeply, so they need more distance to come back together: as *S* shrinks, *S′* grows.

**Ideal lens:** a point maps to a point at that plane (slide 43).

### 12.2 The real lens: a point becomes a blob

**Real lens:** a point maps to a small spot, and even at the best focus the spot has a nonzero minimum size (slide 44). That spot is the lens's **point spread function (PSF)**: the image the system makes of a single point.

If the spot has the same shape everywhere in the image, the blur is **shift-invariant**, so the whole photo is the sharp image convolved with the PSF (§5.1). The slides call the PSF the **blur kernel** for this reason (slide 45: "shift-invariant blur").

**What causes the spot (slides 46–47).**

- **Aberrations**: departures of a real lens from ideal focusing (Week 2 §6). Two shown on the slides:
  - **Chromatic aberration**: glass bends different wavelengths (colors) by different amounts, so red and blue rays focus at slightly different distances.
  - **Spherical aberration**: rays through the edge of a lens with spherical surfaces focus closer than rays through its center.
- **Diffraction**: light is a wave, and a wave passing through a finite opening spreads out. Even a lens with zero aberrations cannot focus to a true point. A **small aperture** spreads the wave more (slide 47's left simulation shows strongly curved wavefronts after a narrow gap); a **large aperture** spreads it less.

**An important caveat (slide 47).** Some aberrations are *not* shift-invariant: **coma** (off-axis points smear into comet shapes that grow toward the image edge) and **distortion** (straight lines bow because magnification changes across the frame). Their blur changes with position, so they cannot be written as one convolution, and the lecture sets them aside.

**Defocus is a PSF too (slide 62).** A point *away from* the focal plane comes to focus in front of or behind the sensor, so it lands as a disc (Week 2 §9's circle of confusion). For a fixed scene depth that disc has the same shape everywhere, so it is also a convolution kernel; but its size depends on the depth, so a scene with many depths is blurred by different PSFs in different places.

> **Summary**
> - An ideal lens images a point to a point (1/*S′* + 1/*S* = 1/*f*); a real lens images it to a spot, the **PSF**.
> - Causes: aberrations (chromatic, spherical) and diffraction (unavoidable, worse for small apertures). Coma and distortion are not shift-invariant and are excluded.
> - When the PSF is the same everywhere, **blurred image = sharp image ∗ PSF**.
> - Next: diffraction's PSF can be computed exactly with the Fourier transform (§13).

---

## 13. Diffraction, Computed with Fourier Transforms

### 13.1 Assumptions

Slide 49 makes two simplifying assumptions, and states that it ignores overall scale factors:

- **Fraunhofer (far-field) diffraction**: the sensor is far from the aperture compared with the light's wavelength. Under this assumption, the light pattern far behind an opening is the **Fourier transform of the opening's shape**. (A lens focused at infinity brings this far-field pattern onto its focal plane.)
- **Incoherent illumination**: ordinary light (sunlight, lamps), whose waves from different scene points have random, unrelated timing, so their *intensities* add. Laser light is **coherent**: its waves keep a fixed timing relationship, so their *amplitudes* add and can cancel (interference).

**Which "frequency" this section uses.** λ is the **wavelength of light** (green ≈ 550 nm). The transfer function's horizontal axis is **spatial frequency** on the sensor, in cycles/mm. These are different quantities; the wavelength enters only as a scale factor that converts aperture size into PSF size.

### 13.2 The 1D chain: aperture → sinc → sinc² → tent

Model a 1D slit aperture as a box, rect(*x*). The lecture builds four linked functions (slides 50–53):

1. **Aperture** = rect(*x*): the opening, 1 where light passes, 0 where it is blocked.
2. **Coherent PSF** = F{rect} = sinc(*x*): the light wave's *amplitude* on the sensor. It has positive and negative lobes (the wave's crests and troughs). (Here the output's horizontal axis is sensor position, scaled by λ*f*; the slides suppress that scale.)
3. **Incoherent PSF** = |sinc(*x*)|² = **sinc²(*x*)**: what a sensor records under ordinary light. A sensor measures **intensity**, the squared magnitude of the wave's amplitude, so squaring is the physics, not a convention.
4. **Optical transfer function (OTF)** = F{incoherent PSF} = F{sinc²} = **tent**: how much of each spatial frequency survives (§14).

**Two routes to the same OTF ("why do we get the same result?", slide 53).** The OTF can also be reached directly from the aperture, by **autocorrelation**: slide a copy of the aperture across itself and record the overlap area at each shift. For a box, the overlap falls off linearly from full (no shift) to zero (shifted by its full width), which is a tent.

They agree because of the **autocorrelation theorem**: the Fourier transform of a function's autocorrelation equals its squared magnitude spectrum, |F{·}|². Run the chain both ways:

- Route 1: aperture → (FT) → sinc → (square) → sinc² → (FT) → tent.
- Route 2: aperture → (autocorrelate) → tent.
- The theorem says FT{autocorrelation of aperture} = |FT{aperture}|² = sinc². So the tent's FT is sinc², i.e. the tent is the FT of sinc². Both routes land on the tent.

**What the tent says.** The OTF is 1 at zero frequency (the average brightness passes untouched), falls linearly as frequency rises, and reaches **exactly zero at a cutoff frequency**. Above the cutoff, no detail at all reaches the sensor, however good the sensor or the software.

### 13.3 Bigger aperture, smaller blur

Slides 54–56 widen the slit: rect(*x*/2), then rect(*x*/10). By the scaling theorem (§6.6):

| Aperture | Coherent PSF | Incoherent PSF | OTF |
|---|---|---|---|
| rect(*x*) | sinc(*x*) | sinc²(*x*) | tent(*x*) |
| rect(*x*/2), twice as wide | sinc(2*x*), half as wide | sinc²(2*x*) | tent(*x*/2), twice as wide |
| rect(*x*/10), ten times as wide | sinc(10*x*) | sinc²(10*x*) | tent(*x*/10) |

**"As the aperture size increases, the point spread function becomes smaller"** (slide 56), and the OTF's cutoff moves out to higher frequencies: more fine detail survives. This is the same pinhole trade-off as Week 2 §3 (a smaller pinhole sharpens the geometric image but worsens diffraction), now derived from the Fourier transform.

### 13.4 The 2D case: circular and square apertures

Real apertures are 2D (slides 57–60).

- **Circular aperture** → incoherent PSF = the **Airy pattern**: a bright central disc (the **Airy disc**) surrounded by faint concentric rings. Its OTF is a smooth, cone-like hill that falls to zero at a circular cutoff. The 2D Fourier transform of a disc is the 2D cousin of the sinc, called a **jinc** (built from a **Bessel function of the first kind**, *J*₁), so the Airy PSF is jinc².
- **Square aperture** → PSF = sinc²(*x*)·sinc²(*y*): a bright center with streaks of bright spots along the horizontal and vertical axes, a cross. Its OTF is a pyramid (a tent in *x* times a tent in *y*).

**Why circular apertures are preferred** (slide 59–60): "other shapes produce very anisotropic blur." **Anisotropic** means direction-dependent. A square aperture blurs detail along the diagonals differently from detail along the axes; a circle treats every direction the same.

### 13.5 How big is the diffraction blur? Numbers

For a circular aperture of f-number *N* (**f-number** = focal length ÷ aperture diameter, *N* = *f*/*D*, Week 2 §8; a larger *N* means a smaller opening):

```
Airy disc radius (to the first dark ring):      r = 1.22 · λ · N
OTF cutoff spatial frequency:                   ξ_cutoff = 1 / (λ · N)
```

| Symbol | Meaning | Units | Who sets it |
|---|---|---|---|
| λ | wavelength of the light | m (e.g. 550 × 10⁻⁹ m) | the light |
| *N* | f-number, *f*/*D* | — | you (aperture setting) |
| 1.22 | the first zero of the jinc, a fixed number from the circular shape | — | geometry |
| *r* | radius of the central bright disc on the sensor | m (usually µm) | result |
| ξ_cutoff | highest spatial frequency the lens transmits at all | cycles per mm on the sensor | result |

*Intuition:* λ*N* is the natural length scale of diffraction: longer waves spread more, and a smaller opening (larger *N*) spreads them more. The cutoff period λ*N* is the same quantity Week 2 §12 called Abbe's diffraction limit, *d* ≈ λ*N*: the finest stripe spacing a lens can pass.

> **Worked example (green light, f/8).** λ = 550 nm, *N* = 8. Airy radius *r* = 1.22 × 550 nm × 8 = 5.37 µm, so the disc is 10.7 µm across. Cutoff = 1/(0.00055 mm × 8) = 227 cycles/mm. At f/2 the disc shrinks to 2.7 µm across and the cutoff rises to 909 cycles/mm; at f/16 the disc grows to 21.5 µm and the cutoff falls to 114 cycles/mm. A typical phone or camera pixel is 1–6 µm wide, so at f/8 and beyond the diffraction blur already spans several pixels.

### 13.6 LiDAR: diffraction sets how small a laser spot can be

The same Fourier relationship governs a **LiDAR** ("light detection and ranging": a sensor that fires laser light and times its return to measure distance, Week 4 §5). A LiDAR transmitter sends its beam out through an exit aperture (a lens of diameter *D*); in the far field the beam's angular spread is the Fourier transform of that aperture, exactly as in §13.2.

**Why it matters for LiDAR.** A LiDAR measures one distance per beam spot. If the spot on a distant surface is large, it covers several objects at once (a branch and the wall behind it), and their returns blend. The spot's angular size therefore sets the LiDAR's **angular resolution**, the finest detail it can map, just as the Airy disc sets a camera's.

**The formula, restated for angles.** For a uniformly lit circular aperture, the diffraction-limited half-angle to the first dark ring is

```
θ ≈ 1.22 · λ / D          spot radius at range R:   r ≈ θ · R
```

(the camera formula *r* = 1.22 λ*N* is this same angle times the focal length *f*, since *N* = *f*/*D*).

| Symbol | Meaning | Units |
|---|---|---|
| λ | laser wavelength (905 nm and 1550 nm are common LiDAR wavelengths, both infrared) | m |
| *D* | transmitter (exit) aperture diameter | m |
| θ | half-angle beam spread | radians |
| *R* | distance to the target | m |
| *r* | spot radius on the target | m |

> **Worked example.** λ = 905 nm, *D* = 10 mm. θ = 1.22 × 905 × 10⁻⁹ / 0.01 = 1.10 × 10⁻⁴ rad = 0.11 milliradians. At *R* = 100 m the spot radius is 1.1 cm (2.2 cm across). Doubling the aperture to 20 mm halves the spot; switching to 1550 nm with the same 10 mm aperture enlarges it by 1550/905 ≈ 1.7×.

**Caveats.** This is the floor set by physics. Real LiDAR beams usually spread more (often around a milliradian or more), because the emitting laser is not a perfect point source and the optics are not perfect; and a real laser beam's brightness falls off smoothly toward its edge (a "Gaussian beam") rather than being uniform, which changes the constant 1.22 but not the λ/*D* scaling. Laser light is also coherent, so the coherent-PSF picture (amplitudes adding) applies to the beam itself, and coherent light reflected from a rough surface produces a grainy interference pattern called **speckle**, a noise source a camera under ordinary light does not have.

> **Summary**
> - Under Fraunhofer, incoherent assumptions: aperture → (FT) → coherent PSF (amplitude) → (square) → incoherent PSF (intensity) → (FT) → OTF; the OTF also equals the aperture's autocorrelation.
> - 1D slit: rect → sinc → sinc² → tent; circle: Airy pattern (jinc²); square: anisotropic cross.
> - Rule to remember: **bigger aperture ⇒ smaller PSF ⇒ higher OTF cutoff**; Airy radius **1.22 λN**, cutoff **1/(λN)** (227 cycles/mm at f/8, green).
> - LiDAR: beam spread θ ≈ 1.22 λ/*D* sets the spot size (1.1 cm radius at 100 m for 905 nm, 10 mm) and hence angular resolution.
> - Next: the OTF as a low-pass filter acting on whole images (§14).

---

## 14. The Lens as an Optical Low-Pass Filter

Put §12 and §13 together (slides 48, 61, 63–64):

```
b = c ∗ x          (primal domain: blurred image = PSF convolved with sharp image)
B = C · X          (Fourier domain: each frequency multiplied by the OTF)
```

| Symbol | Meaning |
|---|---|
| *x* | the **sharp image**: what an ideal lens would form on the sensor |
| *c* | the **PSF** (the slides' notation in this part; the same object Part 6 calls *k*) |
| *b* | the **measured, blurred image** |
| *X*, *C*, *B* | their Fourier transforms; *C* is the **optical transfer function (OTF)** |

**Why "low-pass."** A **low-pass filter** keeps low frequencies (slow brightness changes, broad shapes) and removes high ones (fine stripes, sharp edges). Every lens OTF is near 1 at low frequency and falls to zero at its cutoff (§13), so every lens is a low-pass filter. It acts on light before the sensor sees it, which makes it an **optical** low-pass filter.

**MTF vs. OTF.** The OTF is complex: its magnitude says how much each frequency's contrast is reduced, and its angle how much each grating is shifted. Its magnitude alone is called the **modulation transfer function (MTF)**: MTF = |OTF|. Lens datasheets plot the MTF. ("Modulation" here means contrast: how far a grating swings between light and dark.)

**A whole camera multiplies its MTFs.** Each blurring stage is a convolution, so in the Fourier domain the stages multiply. The lens's OTF times the pixel's (§15) times any anti-aliasing filter's (§21) gives the system's total transfer function.

> **Summary**
> - Rule to remember: **b = c ∗ x** and **B = C·X**; the OTF *C* is the PSF's Fourier transform.
> - Every lens OTF falls to zero at a cutoff: a lens is an optical low-pass filter. MTF = |OTF|.
> - Blur stages in series multiply their transfer functions.
> - Next: the sensor itself adds a second blur and then samples (§15).

---

## 15. What Is a Discrete Image? Pixel Integration, Then Sampling

### 15.1 Three steps from light to numbers

Slides 65–67 build a digital image in three steps.

1. **Continuous signal on the sensor**, *i*(*x*, *y*): the light arriving at each point, measured as **irradiance**, power per unit area, in W/m².
2. **Integration over pixels.** A pixel does not measure light at one point; it collects all the light falling on its area, a *w* × *h* rectangle, and reports the total (an average, up to a constant). That is a convolution with a box the size of the pixel:

   ```
   ĩ(x, y) = i(x, y) ∗ ( rect(x/w) · rect(y/h) )
   ```

3. **Discrete sampling.** The averaged signal is then read out only at the pixel centers, a 2D comb (§6.5):

   ```
   E[i, j] = ĩ(x, y) · Σ_m Σ_n δ(x − m·p, y − n·p)
   ```

| Symbol | Meaning | Units |
|---|---|---|
| *i*(*x*, *y*) | irradiance on the sensor (after the lens blur) | W/m² |
| *w*, *h* | width and height of each pixel's light-collecting area | µm |
| rect(*x*/*w*)·rect(*y*/*h*) | the pixel's "footprint": a box of width *w*, height *h* | — |
| *ĩ* | irradiance after pixel averaging | W/m² |
| *p* | **pixel pitch**: center-to-center spacing between pixels (equal to *w* if pixels touch, the 100% **fill factor** case) | µm |
| *E*[*i*, *j*] | the stored value of pixel (*i*, *j*) | (proportional to) W/m² |

(The slide writes the comb as ΣΣδ(*i*, *j*); it means one impulse at each pixel center.)

### 15.2 What pixel integration does to frequencies

By §6.2 and the scaling theorem, the Fourier transform of a box of width *w* is a sinc whose first zero is at 1/*w*. Taking the magnitude gives the **detector footprint MTF** (slide 68):

```
MTF_footprint(ξ) = | sin(π ξ w) / (π ξ w) |
```

**Intuition (slide 69).** Average a grating over a pixel's width:

- **Low frequency** (stripes much wider than the pixel): the light barely changes across the pixel, so its average follows the grating closely. Essentially no loss of contrast.
- **Mid frequency**: the light varies noticeably within a pixel, so averaging flattens the peaks and fills the troughs. Some loss.
- **ξ = 1/*w*** (exactly one stripe cycle per pixel width): every pixel sees one full bright half and one full dark half, so every pixel reports the same average. **Complete loss**: the grating vanishes.

### 15.3 Sampling: the sensor's Nyquist limit

Step 3 is sampling at rate *f_s* = 1/*p* samples per mm, so by §8 the sensor can only represent spatial frequencies below its **Nyquist frequency**, 1/(2*p*). Finer detail aliases.

> **Worked example (4 µm pixels, 100% fill factor, green light).** Pitch *p* = *w* = 4 µm = 0.004 mm.
> - Footprint MTF first zero: 1/*w* = **250 cycles/mm**.
> - Sensor Nyquist frequency: 1/(2*p*) = **125 cycles/mm**.
> - Footprint MTF at Nyquist: |sin(π/2)/(π/2)| = 2/π ≈ **0.64**. So pixel averaging alone keeps 64% of the contrast of the finest representable stripes, and does *not* remove frequencies just above Nyquist (it reaches zero only at 250 cycles/mm). Pixel averaging is not a sufficient anti-aliasing filter on its own.
> - Lens OTF at 125 cycles/mm for a diffraction-limited circular aperture (cutoff from §13.5): about **0.34** at f/8 (cutoff 227 cycles/mm), about **0.83** at f/2 (cutoff 909 cycles/mm). Stopped down, the lens itself removes much of what would alias; wide open, it passes nearly everything up to and beyond Nyquist.
> - System MTF at Nyquist (lens × pixel, §14): 0.34 × 0.64 ≈ 0.21 at f/8; 0.83 × 0.64 ≈ 0.53 at f/2.

**Linear-algebra view (pixel integration then sampling is one wide "binning" matrix).** Represent the continuous irradiance by a fine grid of *N* values (say 4 sub-samples per pixel), in a vector **i**. Integrating over each pixel and reading it out is a matrix **P** of size (*N*/4)×*N*: row *r* has four equal entries ¼ in columns 4*r* to 4*r*+3 and zeros elsewhere. Its rows do not overlap, so it is block-structured. **P** = (selection matrix of §7) × (box-blur matrix of §5): blur by the pixel footprint, then keep one value per pixel. Its null space contains every pattern that averages to zero inside each pixel, for example a fine grating with one full cycle per pixel, which is §15.2's "complete loss" written as linear algebra.

> **Summary**
> - A digital image = (lens-blurred light) ∗ (pixel box) sampled at the pixel centers.
> - Rule to remember: pixel integration multiplies the spectrum by **|sinc(ξw)|**, zero at **1/w**; sampling then limits frequencies to below the Nyquist frequency **1/(2p)**.
> - Pixel averaging alone does not prevent aliasing (64% contrast left at Nyquist); the lens's own blur and an optical anti-aliasing filter (§21) do the rest.
> - Linear-algebra view: integration + sampling is one binning matrix whose null space holds "one cycle per pixel" patterns.
> - Next: Part 4 turns from blur we suffer to blur (and its opposite) we apply on purpose: image filtering (§16).

---

# Part 4 — Image Filtering

From here on, "frequency" means **image frequency**, in cycles per pixel, because the filters act on stored images (§1's table).

## 16. Low-Pass Filtering, Two Ways

### 16.1 The same filter in two domains

**The problem.** Remove fine detail (noise, texture) while keeping broad shapes. **In:** an image and a choice of how coarse to go. **Out:** a smoother image. **Analogy:** turning down the treble on a stereo.

Slides 71–72 show the two equivalent routes:

```
primal domain:   b = x ∗ c                     (convolve with a small blur kernel c)
Fourier domain:  F{b} = F{x} · F{c}            (multiply the spectrum by a big low-pass mask)
```

By the convolution theorem (§5.2) these give the same result. The slides annotate the kernel as "**small**" and its spectrum as "**big**": by the scaling theorem (§6.6), a compact blur kernel has a wide transfer function, and a wider kernel (stronger blur) has a narrower transfer function (removes more).

### 16.2 The hard cutoff and why it rings

The most obvious Fourier-domain low-pass filter is a **hard cutoff** (slide 73): a disc mask that is 1 inside some radius and 0 outside. It keeps every frequency below the cutoff perfectly and removes every frequency above it.

**Its primal-domain kernel (slide 74).** The inverse Fourier transform of a disc is the 2D sinc, the **jinc**, *J*₁(2π*ρ*)/*ρ* (*ρ* = distance from the center, *J*₁ = a Bessel function of the first kind). Like the sinc, the jinc has a central peak surrounded by rings that alternate positive and negative.

**Ringing (slide 75).** Convolving an image with a kernel that has negative rings copies each sharp edge as faint echoes: alternating light and dark bands running parallel to every edge. This is **ringing** (also called the **Gibbs phenomenon**): "hard frequency filters often introduce ringing." It is the price of an abrupt cutoff: an edge in the frequency domain becomes ripples in the primal domain.

**The fix: a smooth cutoff.** A Gaussian mask falls off gradually, and its primal-domain kernel is also a Gaussian (§6.4), which is positive everywhere. A positive kernel is a true weighted average, so it cannot create overshoots or echoes. This is why practical low-pass filters (PS4's `fspecial_gaussian_2d`) are Gaussian.

| Low-pass filter | Fourier-domain shape | Primal-domain kernel | Ringing? |
|---|---|---|---|
| Hard cutoff (ideal) | disc: 1 inside radius, 0 outside | jinc (rings alternating ±) | yes |
| Gaussian | smooth Gaussian bump | Gaussian (all positive) | no |

### 16.3 Which route is faster

- **Primal-domain convolution** of an image with *P* pixels by a *K*×*K* kernel: *K*² multiply-adds per pixel, so about *P*·*K*² in total. A wider blur means a bigger kernel, so more work.
- **Fourier-domain filtering**: one FFT of the image (about *P* log₂ *P*), one multiply per frequency (*P*), one inverse FFT (about *P* log₂ *P*). The kernel's size never appears.

> **Worked example.** A 1-megapixel image (*P* = 2²⁰ ≈ 10⁶) blurred with a 31×31 kernel: primal ≈ 10⁶ × 961 ≈ 10⁹ multiply-adds. Fourier ≈ 2 × 2.1 × 10⁷ + 10⁶ ≈ 4.3 × 10⁷, about 23× less, and the gap widens as the kernel grows. For a 3×3 kernel (9 multiply-adds per pixel, ≈ 10⁷ total) the primal route is cheaper.

PS4's runtime chart shows exactly this: as the Gaussian's σ goes from 0.1 to 1 to 10, the primal-domain bars climb steeply (on a log axis, by orders of magnitude), while the Fourier-domain bars stay flat (PS4: "the time of the convolution increases as the PSF becomes larger, while the time of the Fourier domain computation remains similar and independent of kernel size").

### 16.4 Implementing both routes (supports HW4 / PS4 Task 1)

PS4 Task 1 asks you to filter an image in both domains and compare. PS4 names the helper functions; here is what each one does and why it is needed.

- **`fspecial_gaussian_2d(size, sigma)`** builds a Gaussian kernel: a small square array, peaked in the middle. Its width should cover the bell's tails (a common choice spans about ±3σ), or the kernel is truncated and its spectrum ripples.
- **Normalize the kernel to sum to 1** (PS4). Then the blur redistributes brightness without adding or removing any: flat regions keep their value, and the OTF equals exactly 1 at zero frequency.
- **`scipy.signal.convolve2d(image, kernel, mode='same')`**: the primal route. `mode='same'` returns an output the size of the input. Pixels near the border use zero-padding unless told otherwise, so borders darken.
- **`pypher.psf2otf(kernel, image_shape)`**: turns the small kernel into a full-size OTF. Three steps happen inside:
  1. *Zero-pad* the kernel to the image's size, because the DFT multiplies arrays of equal size (§10).
  2. *Circularly shift* it so the kernel's **center** sits at array index (0, 0). The DFT measures position from index 0; a kernel centered elsewhere would shift the whole filtered image by that offset (a shift in the primal domain is a phase ramp in the Fourier domain, §5.2, step 1).
  3. *Take the 2D FFT.*
- **`numpy.fft.fft2(image)`**, multiply element-wise by the OTF, then **`numpy.fft.ifft2`**, and keep the real part. (Tiny imaginary parts, around 10⁻¹⁶, are rounding error; a real image times a conjugate-symmetric OTF has a real result, §3.3.)
- **Expect the two routes to match in the interior and differ at the borders.** The Fourier route is circular (§10.3): blur wraps around from the opposite edge, while `convolve2d` with zero-padding pulls in black. PS4's example results "look similar," as they should away from the edges.

> **Summary**
> - Low-pass = convolve with a small kernel, or multiply the spectrum by a mask; small kernel ↔ wide mask.
> - A hard (disc) cutoff has a jinc kernel with negative rings, so it **rings** at edges; a Gaussian has an all-positive kernel and does not.
> - Rule to remember: primal cost ≈ **P·K²**, Fourier cost ≈ **P log P**, independent of kernel size.
> - In code: normalize the kernel, use `psf2otf` (pad, center at (0,0), FFT), multiply, `ifft2`, take the real part; borders differ because the FFT wraps around.
> - Next: the other filters built from the same parts: high-pass, sharpening, band-pass (§17).

---

## 17. High-Pass, Sharpening, Band-Pass and Oriented Filters

### 17.1 High-pass filtering

A **high-pass filter** keeps fine detail (edges, texture) and removes broad shading. It is the complement of a low-pass filter (PS4):

```
primal domain:   x − x ∗ c_LP            (subtract a blurred copy)
Fourier domain:  X · (1 − C_LP)          (multiply by one minus the low-pass mask)
```

Subtracting the blurred copy cancels everything the blur kept (the slow variation), leaving only what it removed. Slide 76 applies a hard disc-shaped high-pass mask to the parrots: the result is a dark image with only the feather edges outlined, plus visible ringing ("sharpening, possibly with ringing").

### 17.2 Unsharp masking: sharpening without ringing

**The idea** (Week 3 §17, rebuilt here). To sharpen an image, find its fine detail and add more of it. *Analogy:* exaggerating someone's accent by working out what makes their speech distinctive and turning that part up.

```
detail     = x − x ∗ c_lowpass_gauss                  (the high-pass layer, with a Gaussian blur)
sharpened  = x + detail = x ∗ (δ + c_highpass)        where c_highpass = δ − c_lowpass_gauss
```

| Symbol | Meaning |
|---|---|
| *x* | input image |
| *c*_lowpass_gauss | a normalized Gaussian blur kernel; its σ sets how coarse a structure counts as "base" rather than "detail" |
| δ | the impulse kernel: convolving with it leaves the image unchanged (§5.1) |
| δ − *c*_lowpass_gauss | the high-pass kernel *c*_highpass: "the image minus its blur," as one kernel |
| *x* ∗ (δ + *c*_highpass) | sharpened image: the original plus one extra copy of its detail |

**A note on slide 77's first formula.** The slide writes *b* = *x* ∗ (δ − *c*_lowpass_gauss) = *x* − *x* ∗ *c*_lowpass_gauss "or" *b* = *x* ∗ (δ + *c*_highpass) = *x* + *x* ∗ *c*_highpass. As written, the first expression is the high-pass **detail layer** itself (the image minus its blur), not the sharpened image; adding that detail back to *x* gives the second expression. The two agree once the detail is added back: *x* + (*x* − *x* ∗ *c*_LP) = *x* ∗ (2δ − *c*_LP) = *x* ∗ (δ + *c*_highpass). Photoshop-style tools add a strength factor: *x* + *k*·detail.

**Why "without ringing."** A Gaussian blur's kernel is positive and its spectrum smooth (§16.2), so the detail layer contains no echo bands. Sharpening still exaggerates each edge's contrast with a slight dip and bump on either side (Week 3 §17's undershoot and overshoot), but no repeated ripples.

**In the Fourier domain:** the sharpening mask is 1 + (1 − *C*_LP) = 2 − *C*_LP: 1 at zero frequency (average brightness unchanged), rising toward 2 at high frequency (fine detail doubled).

### 17.3 Band-pass and oriented band-pass filters

- **Band-pass filter** (slide 79): keep only a **ring** of frequencies, between an inner and outer radius. Coarse shading (inside the ring) and the finest texture and noise (outside it) are both removed; mid-scale structure survives. Built as the difference of two low-pass filters, or in the Fourier domain as (outer disc) − (inner disc).
- **Oriented band-pass filter** (slide 80): keep only two opposite **wedges** of that ring. Because each spectrum point corresponds to stripes of one orientation (§3.2), a wedge keeps only edges of one orientation. On the parrots, "edges with specific orientation (e.g. hat) are gone." The two wedges must be mirror images through the center, or the output is not a real image (§3.3).

**Linear-algebra view (a frequency mask is a diagonal matrix; a 0/1 mask is a projection).** In the Fourier basis (§10.2), multiplying the spectrum by a mask *M* is multiplying by the **diagonal matrix** diag(*M*). Back in pixel space the whole filter is **F**⁻¹ diag(*M*) **F**.

- If *M* contains only 0s and 1s (hard low-pass, high-pass, band-pass, wedge), diag(*M*) is a **projection**: applying it twice changes nothing more (*P*² = *P*). It projects the image onto the subspace spanned by the kept waves.
- The high-pass mask 1 − *M* is the **complementary projection** *I* − *P*. Because the Fourier basis is orthogonal, the low-pass and high-pass parts are orthogonal and add back up to the original exactly.
- A smooth mask (Gaussian) is diagonal but not a projection: its entries lie between 0 and 1, so it shrinks frequencies rather than keeping or deleting them.

> **Summary**
> - High-pass = original minus low-pass (*x* − *x* ∗ *c*_LP, or *X*·(1 − *C*_LP)).
> - Rule to remember: **unsharp masking adds the detail back, x ∗ (δ + c_highpass)** with *c*_highpass = δ − *c*_LP; Gaussian blur avoids ringing. Slide 77's first form is the detail layer itself.
> - Band-pass keeps a ring of frequencies; an oriented band-pass keeps a pair of wedges, i.e. edges of one orientation.
> - Linear-algebra view: masks are diagonal in the Fourier basis; 0/1 masks are orthogonal projections.
> - Next: the same filtering done with lenses instead of a computer (§18).

---

## 18. Optical Filtering with Fourier Optics

Slide 81: "can do all of this optically." The key fact is that **a lens performs a Fourier transform**: an object placed one focal length in front of a lens, lit by coherent (laser) light, produces its Fourier transform in the plane one focal length behind the lens (the far-field pattern of §13.1, brought to a finite distance).

**The 4f system.** Line up, from left to right, separated by one focal length *f* each:

1. the **input plane** holding the image (a transparency, lit by a laser),
2. lens 1,
3. the **Fourier plane**, where the image's spectrum appears; place a **mask** here (e.g. an opaque disc with a hole for low-pass, or an opaque dot for high-pass),
4. lens 2, which transforms again,
5. the **output plane**, where the filtered image appears (upside down, since transforming twice flips the coordinates).

The total length is 4*f*, hence the name. The mask performs, at the speed of light, the same multiplication §16–§17 perform in software. The slide's diagram also shows the general version: a mask containing a second image's spectrum makes the output the **correlation** of the two images, an optical pattern-matcher.

> **Summary**
> - A lens with coherent light produces the Fourier transform of its input one focal length away.
> - A **4f system** (lens, mask in the Fourier plane, lens) filters an image optically: the mask is the frequency-domain multiplication.
> - Next: Part 5 returns to aliasing, now in practical situations, starting with shrinking an image (§19).

---

# Part 5 — Aliasing in Practice

## 19. Downsampling and Anti-Aliasing

### 19.1 Naive downsampling aliases

**The problem.** Make an image smaller, say keep every 4th pixel in each direction. In Matlab that is `I(1:4:end, 1:4:end)` ("that's just resampling, right?", slide 82). The lecture demonstrates with a deliberately "high-frequency" image: a stock-trading chart dense with thin vertical lines. The naive result (slide 84) is wrong: some lines vanish, others merge into fake thick bars and moiré. "Something is wrong — aliasing!"

**Why (slides 85–87).** Keeping every 4th pixel is sampling (§7) at one quarter of the original rate. The spectral copies, which sat a full sampling rate apart, now sit only one quarter as far apart. The image's spectrum is wider than the new spacing, so the copies **overlap**: "high frequencies alias into lower frequencies" (§8).

### 19.2 The fix: low-pass first, then sample

"Anti-aliasing → **before** re-sampling, apply appropriate filter!" (slide 94). Slides 88–89 show the recipe in the Fourier domain:

1. Low-pass filter the image so its spectrum fits inside the *new* Nyquist band (red cutoff lines on slide 88).
2. Then keep every *D*-th pixel. The copies are now narrower than their spacing, so nothing overlaps: "then no aliasing after downsampling!"

**How much filtering** ("what determines the cutoff?", slide 88). Keeping every *D*-th pixel gives a new sampling rate of 1/*D* samples per original pixel, so by the Nyquist–Shannon theorem (*f_s* ≥ 2*f_max*) the image must contain no image frequency above **1/(2*D*) cycles per original pixel**. For *D* = 4: 1/8 = 0.125 cycles/pixel, i.e. nothing finer than one stripe cycle per 8 original pixels. In practice a Gaussian blur is used (no ringing, §16.2), which attenuates rather than removes the frequencies near the cutoff, so its width is a trade-off between leftover aliasing and extra softness.

The comparison on slide 93: without anti-aliasing the chart's lines break up into a misleading pattern; with it, they become a smooth gray texture, which is the honest small-scale version of "many thin lines."

**Library behavior (slide 95, Parmar et al. 2021).** Downsampling a 128×128 image of a thin circle to 16×16 with the default resize functions of common libraries gives different answers: PIL's resize (which low-pass filters first) keeps a faint, smooth circle, while the OpenCV, TensorFlow and PyTorch resizes tested (which by default interpolate without an adequate prefilter) produce scattered dots. The same "resize" call can silently alias, which matters when images are compared numerically (Parmar et al. found it changes a common image-quality score).

**Upsampling.** The lecture's section title includes upsampling but shows no slides on it. In brief: enlarging an image by *D* inserts *D* − 1 new samples between existing ones. In the Fourier domain the original spectrum's copies are now all inside the new, wider band, so a low-pass filter must remove the extra copies; interpolation (nearest, bilinear, bicubic, Lanczos) is that low-pass filter in disguise. Upsampling never creates detail that was not sampled.

**Linear-algebra view (anti-aliased downsampling = selection matrix × blur matrix).** With the image flattened to a vector **x**, the naive downsample is **S x**, where **S** is the selection matrix of §7 (one 1 per row). The anti-aliased version is **S G x**, where **G** is the circulant Gaussian-blur matrix of §5. **S G** is a short, wide matrix whose rows are shifted Gaussian bumps, spaced *D* apart: each output pixel is a weighted average of a neighborhood instead of a single picked pixel. The null space of **S** contains high-frequency patterns that **S** would fold onto low frequencies; **G** shrinks those patterns to almost nothing first, so what remains in the null space is detail that was going to be lost anyway, rather than detail disguised as something else.

> **Summary**
> - Keeping every *D*-th pixel samples at 1/*D* the rate, so spectral copies overlap and fine detail aliases.
> - Rule to remember: **low-pass to below 1/(2D) cycles/pixel, then subsample**; never the other way round.
> - Library resize functions differ in whether they prefilter; some alias by default.
> - Linear-algebra view: anti-aliased downsampling is **S G**, a selection matrix times a blur matrix.
> - Next: the same failure in time instead of space (§20).

---

## 20. Temporal Aliasing: Wagon Wheels and LiDAR

Everything in §7–§8 applies to signals in time, with temporal frequency in Hz.

### 20.1 The wagon-wheel effect

In films, a fast-spinning wheel can appear to turn slowly, stop, or spin backwards (slides 96–97). A film camera samples the scene at its **frame rate** (e.g. 24 frames per second). If the wheel's spoke pattern repeats faster than half the frame rate, it aliases (slide 96: "sampling frequency was lower than 2*f_max*"). The slide's plot shows a fast red wave and, through the same sample points, a slow blue wave: the samples cannot tell them apart.

> **Worked example.** A wheel with 8 identical spokes, filmed at 24 frames/s, spins at 2.5 revolutions/s.
> - Spokes are 360°/8 = 45° apart, so the pattern looks the same after every 45° of rotation. Its temporal frequency is 8 × 2.5 = **20 Hz** (20 spokes pass a fixed point per second). The Nyquist frequency is 24/2 = 12 Hz, so 20 Hz aliases.
> - Between frames the wheel turns 360° × 2.5 / 24 = **37.5°**. That is 7.5° short of the next spoke position (45°), so the nearest spoke appears to have moved **7.5° backwards**.
> - Apparent motion: −7.5° per frame × 24 frames/s = −180°/s = **−0.5 revolutions/s**: the wheel seems to turn slowly backwards.
> - Same answer from §8.2: 20 Hz sampled at 24 Hz appears at 20 − 24 = −4 Hz, i.e. the spoke pattern moving backwards at 4 spokes/s, which is 4/8 = 0.5 revolutions/s.

### 20.2 LiDAR: range aliasing is temporal aliasing

A LiDAR measures distance from the **round-trip time** of light: a pulse travels to the target and back, so distance *d* = *c*·*t*/2 (*c* = speed of light ≈ 3 × 10⁸ m/s, Week 4 §5.1). Because distance is read from a time or a phase, sampling and periodicity in time produce **range aliasing**: a far target reported at a wrong, nearer distance. This happens in both main LiDAR families.

**(a) Pulsed LiDAR: pulse repetition rate.** A pulsed LiDAR fires short laser pulses at a fixed **pulse repetition frequency (PRF)** and times each echo from the most recent pulse. If an echo takes longer than the gap between pulses, it arrives after the *next* pulse has fired, and the system times it from the wrong pulse.

```
maximum unambiguous range:   R_max = c / (2 · PRF)
reported range (if beyond):  d_reported = d_true − m · R_max     (m = number of pulse gaps skipped)
```

- *Why this shape:* the time between pulses is 1/PRF; light covers a round trip to distance *R* in 2*R*/*c*; setting 2*R*/*c* = 1/PRF gives *R_max*.
- *Term by term:* *c* is the speed of light (m/s), fixed; PRF is the pulse rate (pulses/s, Hz), chosen by the designer; *R_max* is in meters.

> **Worked example.** PRF = 1 MHz (one pulse per microsecond). *R_max* = 3 × 10⁸ / (2 × 10⁶) ≈ **150 m**. A highly reflective sign at 180 m returns its echo 1.2 µs after its pulse, i.e. 0.2 µs after the next pulse: it is reported at about **30 m**. This "second-time-around" echo is a time-domain alias. Designers lower the PRF (longer *R_max*, fewer points per second) or vary the pulse spacing so that aliased echoes do not line up.

**(b) Continuous-wave (indirect) time-of-flight: phase wrapping.** An indirect time-of-flight camera (Week 4 §5.4) does not time a pulse. It sends light whose brightness is modulated as a sinusoid at frequency *f_mod*, and measures the **phase** of the returned sinusoid (§2.1): how far its waveform has shifted. The shift is proportional to round-trip time, but phase repeats every 2π, so distances repeat every half modulation wavelength:

```
measured phase:              φ = 2π · f_mod · (2d / c)     (mod 2π)
unambiguous range:           R_amb = c / (2 · f_mod)
reported range (if beyond):  d_reported = d_true mod R_amb
```

- *Why this shape:* one full cycle of phase (2π) corresponds to a round-trip delay of one modulation period, 1/*f_mod*, i.e. a distance of *c*/(2*f_mod*). Beyond that the phase wraps back to 0, exactly as a frequency above Nyquist folds back in §8.2.
- *Term by term:* *f_mod* is the modulation frequency (Hz), chosen by the designer; φ is the measured phase (radians); *R_amb* is in meters.

> **Worked example.** *f_mod* = 20 MHz: *R_amb* = 3 × 10⁸ / (2 × 2 × 10⁷) ≈ **7.5 m**. A wall at 9 m is reported at 9 − 7.5 ≈ **1.5 m**. Raising *f_mod* to 100 MHz improves depth precision (a given phase error is a smaller distance error) but shrinks *R_amb* to about **1.5 m**. Real sensors measure at two or more modulation frequencies and combine them, the way two clocks with different periods together pin down a longer time.

**(c) Sampling the return waveform.** A full-waveform LiDAR digitizes the returned light at a fixed sample rate. Each sample interval is a range bin of *c*·Δ*t*/2: at 1 GS/s (10⁹ samples per second) that is about **15 cm**. The returned pulse is itself a short waveform with a temporal-frequency content: a pulse lasting about 4 ns (full width at half maximum, Gaussian-shaped) has a bandwidth of roughly 110 MHz, so by Nyquist the digitizer should sample at well over 2 × 110 MHz ≈ 220 MS/s to record its shape without aliasing. Sampling faster than that does not create new information about the pulse, but it does allow its peak time to be estimated to a fraction of a bin.

> **Summary**
> - Filming a periodic motion slower than twice its frequency makes it appear slower, stopped, or reversed (8-spoke wheel at 2.5 rev/s, 24 fps → appears −0.5 rev/s).
> - Rule to remember: LiDAR ranges alias too: pulsed **R_max = c/(2·PRF)** (150 m at 1 MHz), continuous-wave **R_amb = c/(2·f_mod)** (7.5 m at 20 MHz).
> - Digitizing a LiDAR waveform obeys Nyquist like any signal; one sample = *c*Δ*t*/2 of range (15 cm at 1 GS/s).
> - Next: aliasing on the camera sensor, and the optical filter that prevents it (§21).

---

## 21. Aliasing on the Sensor and the Optical Anti-Aliasing Filter

**The setup (slides 98–99).** A point on the focal plane maps, through the lens, to the PSF on the sensor. The sensor samples at its pixel pitch *p*, with Nyquist frequency 1/(2*p*) (§15.3). If the lens is so sharp that its PSF is smaller than about two pixels, the optical image contains detail above the sensor's Nyquist frequency, and it aliases. Hence slide 99's rule of thumb: **"PSF must be larger than 2 × pixel size!"**

*Why "2 pixels":* by the scaling theorem a blur of width *W* removes frequencies above roughly 1/*W*. To remove everything above 1/(2*p*), *W* should be at least about 2*p*.

**The optical anti-aliasing (AA) filter.** Since aliasing cannot be removed afterwards (§8.4), cameras blur the light slightly **before** it reaches the pixels with an **optical low-pass filter (OLPF)**, a thin plate on top of the sensor. It is commonly made of two layers of a **birefringent** crystal (a material that splits one ray into two slightly displaced rays, depending on the light's polarization); two such layers turn every point into four points about one pixel apart, a tiny 4-tap blur kernel. This widens the system PSF just enough to bring it to about 2 pixels.

**"Hot rodding" (slide 100).** Some photographers remove the AA filter from their camera for extra sharpness. Images become crisper, but fine repeating patterns (fabric, distant brickwork, screens) produce moiré, and with a **Bayer color filter array** (the checkerboard of red, green and blue filters over the pixels, Week 3 §14) the problem is worse: each color is sampled more sparsely than the full grid (red and blue every second pixel in each direction), so they alias first, as false-color fringes. Manufacturers now sell some models with no AA filter, relying on lens blur and diffraction (§15.3's worked example) to do most of the work.

> **Summary**
> - Rule to remember: **the system PSF should span at least about 2 pixels**, or detail above the sensor's Nyquist frequency aliases.
> - The optical anti-aliasing filter (birefringent plates splitting each point into 4) adds just enough blur before sampling.
> - Removing it trades moiré (worse with a Bayer mosaic) for sharpness.
> - Next: Part 6 asks whether blur, once it has happened, can be undone: deconvolution (§22).

---

# Part 6 — Deconvolution

Notation for this part follows slides 102–123: *i* = sharp image (from a perfect lens), *k* = blur kernel (the PSF), *b* = blurred measurement, *n* = noise. Capital letters are their Fourier transforms: *I*, *K* (the OTF), *B*, *N*. "Frequency" is image frequency; ω (slides 111–112) is just a label for "one frequency," not a different kind of frequency.

## 22. Deconvolution and Why Naive Inversion Fails

### 22.1 The forward model and the naive inverse

**Forward model (slides 102–103).** An imperfect lens blurs the image a perfect lens would make:

```
i ∗ k = b          (sharp image convolved with lens PSF gives the blurred image)
```

**Deconvolution** is the inverse problem: if we know *b* and *k*, can we recover *i*? "**Non-blind**" deconvolution means the kernel is known (measured or calibrated); "blind" means it must also be estimated, a much harder problem not covered this week.

**The naive answer (slides 105–106).** Convolution is multiplication in the Fourier domain, so divide:

```
F(i) · F(k) = F(b)
F(i_est) = F(b) / F(k)                       (divide, one frequency at a time)
i_est    = F⁻¹( F(b) / F(k) )                (then inverse-transform)
```

This is the **inverse filter** (PS4: "simple inverse filtering"; PS4 writes the restoration filter as *H′* = 1/*H*, where *H* is the blur's OTF). The slides write "\" for this element-wise division.

### 22.2 Two problems (slides 107–109)

**Problem 1: the OTF has zeros at high frequencies.** The OTF of a lens is a low-pass filter (§14): near zero at high frequency, and exactly zero beyond its cutoff (§13) or at a box's sinc zeros (§6.2). Dividing by zero is undefined; dividing by a tiny number gives a huge one.

**Problem 2: the measurement includes noise.** The real forward model is

```
b = k ∗ i + n
```

where *n* is **noise**: random fluctuations added by the sensor (photon shot noise, read noise and others, Week 2 §18), different in every photo. In the Fourier domain, *B* = *K*·*I* + *N*. The naive inverse then gives

```
B / K = I + N / K
```

The first term is the right answer. The second is the noise, divided by the OTF. Noise is spread across all frequencies (unlike real images, which are concentrated at low ones), so at high frequencies, where |*K*| is tiny, *N*/*K* is enormous. "When we divide by zero, we amplify the high frequency noise" (slide 109).

**What it looks like (slide 110).** The lecture blurs the parrots with a Gaussian and adds a tiny amount of noise ("example for Gaussian of σ = 0.05"), then applies the inverse kernel *k*⁻¹: the result is pure noise, with no trace of the parrots. "Even tiny noise can make the results awful." PS4's example (noise σ = 0.001) reports a PSNR (§25) of about −157 dB after inverse filtering, i.e. a result vastly worse than the blurred input, against about 26.6 dB after Wiener deconvolution (§23).

> **Worked example (8 samples, a kernel with an exact zero and two near-zeros).** Use the 3-tap blur [0.25, 0.5, 0.25] on an 8-sample signal with wrap-around edges. Its DFT (the OTF at frequency indices *k* = 0 … 7) is
>
> | frequency index | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
> |---|---|---|---|---|---|---|---|---|
> | OTF *K* | 1 | 0.854 | 0.5 | 0.146 | **0** | 0.146 | 0.5 | 0.854 |
> | inverse gain 1/*K* | 1 | 1.17 | 2 | **6.83** | **∞** | 6.83 | 2 | 1.17 |
>
> - *Exact zero (k = 4, the fastest alternation +, −, +, −).* Blurring [1, −1, 1, −1, …] gives 0.5·1 − 0.25·1 − 0.25·1 = 0 at every sample. So a scene and the same scene plus any amount of this alternating pattern produce identical blurred images: that detail is gone, and no method can tell how much of it there was.
> - *Near-zeros (k = 3 and 5).* Add a faint noise wave of amplitude 0.01 at frequency index 3. The inverse filter multiplies it by 6.83, so it comes out with amplitude 0.068, nearly 7× larger. With real noise at every frequency and a 2D lens OTF that is near zero over most of the high frequencies, these amplifications swamp the image.

**Linear-algebra view (the inverse filter is the inverse of a circulant matrix, which fails where an eigenvalue is 0).** With wrap-around edges the blur is the circulant matrix **C** = **F**⁻¹ diag(*K*) **F** (§5.2). Its inverse would be **C**⁻¹ = **F**⁻¹ diag(1/*K*) **F**: divide each frequency by its eigenvalue. That is exactly the inverse filter.

- An eigenvalue of 0 (*K* = 0 at *k* = 4) means **C** is **singular**: the alternating vector is in its **null space**, **C**⁻¹ does not exist, and the matrix's **rank** (number of independent directions it preserves) is 7 rather than 8.
- A tiny eigenvalue (0.146) means the inverse exists but multiplies noise along that direction by 1/0.146. The ratio of largest to smallest eigenvalue magnitude, the **condition number** (§27), is 1/0.146 ≈ 6.8 for the 7 surviving directions, and infinite for the full matrix. A real lens blur on a megapixel image has condition numbers so large that naive inversion is hopeless.

> **Summary**
> - Rule to remember: inverse filter **i_est = F⁻¹(F(b)/F(k))**; it divides each frequency by the OTF.
> - It fails because the OTF is (near) zero at high frequencies and **b = k ∗ i + n** contains noise: the error term is **N/K**, huge where *K* is tiny.
> - Exact zeros destroy information (null space); near-zeros amplify noise (large condition number).
> - Next: divide only where it is safe, the Wiener filter (§23).

---

## 23. Wiener Deconvolution

### 23.1 The formula and what it does

**The problem.** Undo the blur at frequencies where the measurement is trustworthy, and do not try where noise dominates. *Analogy:* restoring a faded recording: boost the faint treble back up, but only as long as you are boosting music and not mostly tape hiss.

**The formula (slides 111–112).**

```
i_est = F⁻¹( [ |F(k)|² / ( |F(k)|² + 1/SNR(ω) ) ] · F(b) / F(k) )
```

It is the inverse filter F(*b*)/F(*k*) multiplied by a **noise-dependent damping factor** (the bracketed term), which lies between 0 and 1.

| Symbol | Meaning | Who sets it |
|---|---|---|
| F(*b*) | spectrum of the blurred, noisy measurement | the data |
| F(*k*) = *K* | the blur's OTF | known (non-blind) |
| \|F(*k*)\|² | how strongly the blur passes this frequency, as a power (squared magnitude) | known |
| SNR(ω) | **signal-to-noise ratio** at frequency ω: signal variance ÷ noise variance at that frequency | estimated, or chosen by you |
| 1/SNR(ω) | the noise-to-signal ratio: how much of this frequency is noise | as above |
| damping factor \|*K*\|²/(\|*K*\|² + 1/SNR) | near 1 where the blurred signal is strong compared with the noise, near 0 where it is not | computed |
| ω | one frequency (a label; same axis as every other spectrum here) | — |

**Variance**, used in SNR(ω), is the average squared deviation of a random quantity from its mean; the noise's variance is σ_n², the square of its standard deviation (Week 2 §18).

**Two limits (slide 112, "Intuitively").**

- *High SNR (little noise)*: 1/SNR → 0, the damping factor → |*K*|²/|*K*|² = 1, and Wiener becomes the inverse filter: "just divide by kernel."
- *Low SNR (lots of noise)*: 1/SNR dominates the denominator, the damping factor → 0: "just set to zero." That frequency is given up rather than amplified.

**Simplified form.** Cancelling one *K* (and using |*K*|² = *K*·*K**), the whole filter is

```
H_Wiener(ω) = K*(ω) / ( |K(ω)|² + 1/SNR(ω) )          i_est = F⁻¹( H_Wiener · F(b) )
```

The denominator is never zero as long as 1/SNR > 0, which is exactly the "do not divide by zero" of slide 111. (*K** is the complex conjugate; for a symmetric kernel like a centered Gaussian, *K* is real and *K** = *K*.)

> **Worked example (one frequency at a time).** Take SNR = 100 (1/SNR = 0.01).
> - Where the OTF is *K* = 0.9: Wiener gain = 0.9/(0.81 + 0.01) = **1.098**, almost the inverse filter's 1/0.9 = 1.111. Healthy frequency, nearly full correction.
> - Where *K* = 0.1: Wiener gain = 0.1/(0.01 + 0.01) = **5.0**, half the inverse filter's 10. Partial correction.
> - Same *K* = 0.1, but noisier, SNR = 10: gain = 0.1/(0.01 + 0.1) = **0.91**. The filter now does not boost this frequency at all.
> - Back to §22's 8-sample kernel with 1/SNR = 0.01: the gains at frequency indices 0–4 are 0.99, 1.16, 1.92, 4.66, **0** (vs. inverse 1, 1.17, 2, 6.83, ∞). The exact zero is now handled gracefully (gain 0, not ∞), and the near-zero at index 3 is boosted 4.66× instead of 6.83×, so §22's noise wave comes out at amplitude 0.047 instead of 0.068. The cost: the true signal at index 3 is restored to only 0.146 × 4.66 ≈ 68% of its strength rather than 100%.

**The trade-off in one sentence.** Wiener deconvolution accepts a slightly blurry answer (frequencies it gave up on stay attenuated) in exchange for not amplifying noise. Slides 113–114 show the result: naive deconvolution is pure noise; Wiener recovers recognizable, sharper parrots, still somewhat noisy. As the noise grows (σ = 0.01 → 0.05), the Wiener result gets smoother and noisier.

### 23.2 The SNR knob in practice (supports HW4 / PS4 Task 2)

The formula needs SNR(ω) at every frequency, which is rarely known exactly. Three practical versions:

- **Per-frequency SNR (the lecture's definition):** SNR(ω) = (signal variance at ω)/(noise variance at ω). If the noise is "white" (same variance σ_n² at every frequency) and you have a model of how natural images' power falls off with frequency, this is computable. It is the statistically optimal choice (§24).
- **One constant for all frequencies:** replace 1/SNR(ω) by a single number, often written *k* (PS4 slide 11: *G′* = (1/*G*)·|*G*|²/(|*G*|² + *k*), with *G* the blur's OTF). Larger *k* damps more. PS4's plot of this filter's frequency response for a Gaussian blur shows the trade-off: 1/*G* (dashed) shoots up at high frequency; the Wiener curves rise, peak, and then fall back to zero, peaking lower and earlier as *k* grows from 0.01 to 0.05 to 0.1 ("higher noise → lower SNR → more damping → less noise amplification").
- **PS4's estimate for HW4:** SNR = Ī/σ_noise, where Ī is the **average pixel value of the noisy image** and σ_noise the standard deviation of the added noise (PS4 slide 9). Note this is a ratio of *amplitudes* (a mean over a standard deviation), whereas the lecture's SNR is a ratio of *variances* (powers); the two differ by a square. Either can be used as the damping knob, but they are not numerically interchangeable, so use the one your assignment specifies.

**The HW4 pipeline, as PS4 describes it** (the specific blur widths, noise levels and resulting numbers are left to the assignment):

1. Blur the image with a Gaussian kernel (primal or Fourier domain, §16).
2. Add random Gaussian noise: `I = I + sigma * randn(size(I))` (Matlab; `np.random.randn` in Python), i.e. noise with standard deviation σ_noise.
3. Restore by (a) dividing by the OTF (inverse filtering, §22) and (b) Wiener deconvolution (this section).
4. Score each restoration with MSE and PSNR (§25).

> **Summary**
> - Rule to remember: **i_est = F⁻¹( K* / (|K|² + 1/SNR) · F(b) )**, the inverse filter times a damping factor |*K*|²/(|*K*|² + 1/SNR).
> - High SNR → divide by the kernel; low SNR → set to zero; never divide by zero.
> - In practice 1/SNR is often one constant; PS4 estimates SNR as mean pixel value ÷ noise σ (an amplitude ratio, unlike the lecture's variance ratio).
> - Next: where the formula comes from (§24).

---

## 24. Deriving the Wiener Filter

The lecture derives the filter as the one that makes the expected squared error as small as possible (slides 115–123). The derivation needs two tools first.

### 24.1 Two tools: expectation, and independence

- **Expectation** E[·]: the average value of a random quantity over many repetitions (many photos with fresh noise). If noise has **zero mean**, E[*N*] = 0: it is as often positive as negative.
- **Independence**: two random quantities are independent if knowing one tells you nothing about the other. For independent quantities, **E[*I N*] = E[*I*]·E[*N*]** (slides 119–120).
- Combining them: if the image and the noise are independent and the noise has zero mean, then E[*I N*] = E[*I*]·0 = **0** (slide 121). Cross terms between signal and noise average away.

### 24.2 The derivation, step by step

**Step 1, sensing model (slides 115–116).** *b* = *k* ∗ *i* + *n*, with noise *n* assumed zero-mean and independent of the image *i*. In the Fourier domain, convolution becomes multiplication: *B* = *K*·*I* + *N* ("why multiplication?": the convolution theorem, §5.2). This is a separate equation at every frequency, so the rest works one frequency at a time with plain numbers.

**Step 2, problem statement (slide 117).** Look for a function *H*(ω), one multiplier per frequency, so that *H*·*B* is as close as possible to the true *I*, on average over noise:

```
min over H of   E[ |I − H B|² ]
```

**Step 3, substitute *B* and regroup (slide 118).** *I* − *H B* = *I* − *H*(*K I* + *N*) = (1 − *H K*)·*I* − *H*·*N*:

```
min over H of   E[ |(1 − HK) I − H N|² ]
```

(Slide 122 reprints this line with (1 + *HK*); that is a typo, the sign is minus, as on slide 118 and in the expansion below it.)

**Step 4, expand the square (slide 118).** Treat each quantity as a real number for now (the slides do; §24.3 gives the complex version). (*a* − *c*)² = *a*² − 2*ac* + *c*², and *H*, *K* are fixed numbers that come out of the expectation:

```
(1 − HK)² E[I²]  −  2 H (1 − HK) E[I N]  +  H² E[N²]
```

**Step 5, drop the cross term (slides 119–122).** E[*I N*] = E[*I*]·E[*N*] = 0 (independence, zero-mean noise):

```
loss(H) = (1 − HK)² E[I²]  +  H² E[N²]
```

*Reading it:* the first term is **leftover blur** (signal energy not restored: zero only if *H* = 1/*K*). The second is **amplified noise** (noise energy that passes through *H*: zero only if *H* = 0). Choosing *H* balances them.

**Step 6, minimize (slide 123).** loss(*H*) is a parabola in *H* (it opens upward, so its lowest point is where the slope is zero). Differentiate and set to zero:

```
d loss / dH = −2K(1 − HK) E[I²] + 2H E[N²] = 0
⇒  H = K E[I²] / ( K² E[I²] + E[N²] )
```

**Step 7, rewrite (slide 123).** Divide top and bottom by E[*I*²] and pull out 1/*K*:

```
H = (1/K) · K² / ( K² + E[N²]/E[I²] ) = (1/K) · K² / ( K² + 1/SNR )
```

since E[*I*²]/E[*N*²] at this frequency is the signal-to-noise ratio (signal power ÷ noise power, i.e. variance ratio for zero-mean quantities). This is the Wiener filter of §23.

### 24.3 The complex version, briefly

Fourier coefficients are complex, so the squares are really squared magnitudes |·|². Repeating the steps with complex numbers gives

```
H = K* E[|I|²] / ( |K|² E[|I|²] + E[|N|²] ) = K* / ( |K|² + 1/SNR )
```

which is §23.1's simplified form. The conjugate *K** undoes the blur's phase shift as well as its magnitude.

**Where the "maximum-likelihood under Gaussian noise" remark (slide 111) fits.** Minimizing expected squared error is the natural criterion when noise is Gaussian (bell-shaped, Week 2 §18.4); with Gaussian statistics for both image and noise, the same filter is also the most probable image given the measurement. The derivation above only needs zero-mean, independent noise and known powers.

> **Summary**
> - Wiener = the per-frequency multiplier *H* minimizing **E[|I − HB|²]** with *B* = *KI* + *N*.
> - Independence + zero-mean noise kill the cross term, leaving **(1 − HK)² E[I²] + H² E[N²]**: leftover blur vs. amplified noise.
> - Setting the derivative to zero gives **H = (1/K)·K²/(K² + 1/SNR)**; the complex version is *K**/(|*K*|² + 1/SNR). (Slide 122's "1 + *HK*" is a typo.)
> - Next: how to score a restoration (§25).

---

## 25. Scoring a Restoration: MSE and PSNR

PS4 (slide 13) scores each HW4 restoration with two numbers. Both compare the restored image with the original (ground truth) image.

**Mean squared error (MSE).**

```
MSE = (1/(m·n)) · Σ_{i=1}^{m} Σ_{j=1}^{n} [ I_original(i, j) − I_restored(i, j) ]²
```

- *Why squared:* positive and negative errors would cancel in a plain average; squaring makes every error count, and weighs big errors more.
- *Term by term:* *m*, *n* = image height and width in pixels; (*i*, *j*) = a pixel position (here *i* is a row index, not the image); *I*_original = ground-truth pixel value; *I*_restored = your result. Units: (pixel value)². Lower is better; 0 is perfect.

**Peak signal-to-noise ratio (PSNR).**

```
PSNR = 10 · log₁₀( max(I_original)² / MSE )          in decibels (dB)
```

- *Why this shape:* MSE alone depends on the pixel scale (an error of 4 means something different for values in 0–255 than in 0–1). Dividing the largest possible squared value by MSE gives a scale-free ratio; the logarithm in **decibels** (10 log₁₀ of a power ratio) turns huge ratios into manageable numbers. Higher is better.
- *Term by term:* max(*I*_original) = the largest value the image's format can hold (1 for images scaled to [0, 1]; 255 for 8-bit). It must match the scale MSE was computed on.

> **Worked example.** Images on [0, 1], MSE = 0.001: PSNR = 10·log₁₀(1/0.001) = 10·log₁₀(1000) = **30 dB**. Every 10× reduction in MSE adds 10 dB. A negative PSNR, like PS4's −157 dB for inverse filtering, means MSE is *larger* than max²: the restored values are wildly outside the image's range.

> **Summary**
> - Rule to remember: **MSE = mean squared pixel difference**, **PSNR = 10 log₁₀(max²/MSE)** dB; higher PSNR is better, +10 dB = 10× smaller MSE.
> - Use the same pixel scale for max and MSE.
> - Next: Part 7 recasts every problem in this file as one matrix equation, b = Ax, and solves it without inverting anything (§26).

---

# Part 7 — Linear Systems

Notation for this part (slides 129–144, PS4 Task 3): **x** = the unknown image, flattened into a column vector of *n* numbers; **b** = the measurements, a vector of *m* numbers; **A** = the *m*×*n* matrix that models image formation. **A**ᵀ is the **transpose** (rows and columns swapped). ‖**v**‖₂ = √(Σ *v_i*²) is the **ℓ₂ norm**, a vector's length.

## 26. Most Imaging Problems Are Linear: b = Ax

**The claim (slides 128–129).** "Most computational imaging problems are linear":

```
b = A x
```

| Symbol | Meaning (slide 129) | Size |
|---|---|---|
| **b** | "blurry, noisy, or otherwise corrupted measurements" | *m* × 1 |
| **A** | "matrix modeling image formation, usually known" | *m* × *n* |
| **x** | "unknown image" | *n* × 1 |

**Why linear.** In the geometric-optics model (light as rays), light **intensities** add: two lamps give the sum of their separate images, and a lamp twice as bright gives an image twice as bright. Any process with these two properties is a matrix (Week 2 §1). Every forward model in this file is one:

| Process | Matrix **A** | Where |
|---|---|---|
| blur by a PSF | circulant/Toeplitz convolution matrix | §5, §14 |
| pixel integration + sampling | binning matrix | §15 |
| downsampling | selection matrix | §7, §19 |
| a color filter array | selection matrix picking one color per pixel | Week 3 §14 |
| any combination | the product of the stages' matrices | — |

**Not always linear** (slide 128): wave-based models, where light's **amplitudes** and **phases** add and can cancel (interference), and problems like **phase retrieval**, where the sensor records only |amplitude|², which is not linear in the amplitude.

**Size.** For a 1-megapixel image, *n* = 10⁶, and a blur matrix **A** is 10⁶ × 10⁶ = 10¹² entries: about **8 terabytes** at 8 bytes per number. Nobody stores it. Instead, code implements "multiply by **A**" as a function, e.g. a convolution or an FFT-based filter (slide 140: "implement as function handles!").

**Linear-algebra view (a blur matrix acting on an image vector).** For a 1D image of 6 pixels and kernel [0.25, 0.5, 0.25] with wrap-around, **A** is the 6×6 circulant matrix whose every row holds 0.5 on the diagonal and 0.25 on its two neighbors (wrapping at the corners), and zeros elsewhere. **b** = **A x** computes each blurred pixel as 0.25·(left) + 0.5·(self) + 0.25·(right). The band of three nonzero diagonals is the kernel; the zeros everywhere else say "light from distant pixels does not reach here."

> **Summary**
> - Rule to remember: **b = Ax** — measurements = (known image-formation matrix) × (unknown image).
> - Ray optics is linear in intensity, so blur, pixel integration, sampling and mosaicking are all matrices; wave effects (interference, phase retrieval) are not.
> - Real **A** are far too big to store (8 TB for a 1-megapixel blur) and are applied as functions.
> - Next: before solving, how to tell what can be recovered at all (§27).

---

## 27. What Can We Hope to Recover? Rank, Null Space, Condition Number, SVD

Slide 130: "given **b**, what can I hope to recover? Analyze matrix via condition number, rank, SVD." Each concept, with a 2×2 example.

### 27.1 Rank and null space: information that is gone

- **Rank**: the number of independent directions the matrix preserves, i.e. the dimension of its output space (its **range** or **column space**: all vectors **A x** can produce).
- **Null space**: all vectors **v** with **A v** = **0**. Adding any of them to the true image changes nothing in the measurements, so they can never be recovered from **b** alone.
- Rank + (dimension of null space) = *n*, the number of unknowns.

> **Worked example.** **A** = [[1, 2], [2, 4]] (second row = 2 × first). Rank 1. **A**·[2, −1] = [0, 0], so the null space is the line through (2, −1). Consequence: **A**·[1, 0] = [1, 2] and **A**·[3, −1] = [1, 2]: two different images, identical measurements. §22's blur with an exact OTF zero has the same defect (the alternating pattern is in its null space).

### 27.2 Condition number: information that is fragile

Even if no direction is lost, some may be nearly lost. The **condition number** measures how much a small error in **b** can grow in the solution **x**: the ratio of the largest to the smallest amount the matrix stretches any direction. Near 1 is safe; large means noise is amplified by up to that factor.

> **Worked example.** **A** = [[1, 1], [1, 1.001]] (condition number ≈ 4000). Solving **A x** = [2, 2.001] gives **x** = [1, 1]. Changing one measurement by 0.001, to [2, 2.002], gives **x** = [0, 2]. A 0.05% change in the data moved the answer completely.

### 27.3 The singular value decomposition (SVD)

Every matrix can be written as

```
A = U Σ Vᵀ
```

- **V**ᵀ rotates the input (columns of **V** are orthogonal "input directions"),
- **Σ** is diagonal: it stretches each direction by a **singular value** *s*₁ ≥ *s*₂ ≥ … ≥ 0,
- **U** rotates into the output (columns of **U** are orthogonal "output directions").

**What it tells you.** Rank = number of nonzero singular values. Null space = input directions with singular value 0. Condition number = *s*_max / *s*_min. Geometrically, **A** turns the unit circle into an ellipse whose semi-axes are the singular values.

**For blur, the SVD is the Fourier transform.** A circulant blur matrix is diagonalized by the Fourier basis (§5.2), so its singular values are the OTF magnitudes |*K*(ω)|: input directions = waves, stretch = how much each wave survives. Everything in Part 6 is this section in disguise: zeros of the OTF are the null space, small OTF values are small singular values, and the inverse filter's noise amplification is the condition number.

> **Summary**
> - Null space = what is invisible to the measurement (gone); rank counts what survives.
> - Condition number = *s*_max/*s*_min: how much noise can be amplified (≈ 4000 in the 2×2 example, where a 0.001 change flips the answer).
> - Rule to remember: **A = UΣVᵀ**; for a blur, singular values = |OTF|.
> - Next: why we still do not just compute **A**⁻¹**b** (§28).

---

## 28. Why Not Just Invert the Matrix?

"Answer: invert matrix? … generally not!" (slides 131–133). Two problems:

1. **The inverse often does not exist.** A matrix inverse **A**⁻¹ (the matrix with **A**⁻¹**A** = identity) is defined only for **square, full-rank** matrices. "Most imaging problems are NOT": they have more measurements than unknowns, fewer, or a null space.
2. **The matrices are enormous.** Even when an inverse exists, computing it for a 10⁶ × 10⁶ matrix (§26) is impossible in time and memory, and the inverse of a sparse matrix is usually dense.

**The solution (slide 133): "iterative (convex) optimization."** Write down a number that measures how badly a candidate **x** explains the data, and improve **x** step by step, using only "multiply by **A**" and "multiply by **A**ᵀ". (**Convex** means the objective is bowl-shaped, with one lowest point and no false valleys; the least-squares objective below is.)

**Two cases (slide 134):**

| Case | Shape of **A** | Meaning | Typical issue |
|---|---|---|---|
| **Over-determined** | *m* > *n* (tall) | more measurements than unknowns | equations conflict (noise), so no exact solution; find the best compromise (§29) |
| **Under-determined** | *m* < *n* (wide) | fewer measurements than unknowns | infinitely many exact solutions (a null space); pick one using an extra preference (§30) |

> **Summary**
> - Inverses exist only for square, full-rank matrices, and are infeasible at image scale anyway.
> - Over-determined (tall, *m* > *n*): no exact solution; under-determined (wide, *m* < *n*): too many.
> - Rule to remember: **don't invert, optimize iteratively**, using only products with **A** and **A**ᵀ.
> - Next: the over-determined case and least squares (§29).

---

## 29. Least Squares and the Normal Equations

### 29.1 The objective

**The problem.** With more measurements than unknowns and noise in **b**, no **x** fits every equation. Find the one that fits best overall. *Analogy:* drawing the straight line that passes as close as possible to a scatter of points that do not all lie on one line.

**The residual** **r** = **b** − **A x**: for each measurement, how far the prediction misses. The **least-squares** objective (slide 135) minimizes the sum of squared misses:

```
minimize over x:   ½ ‖b − A x‖₂²          where   ‖r‖₂² = Σ_i r_i²
```

- *Why squared:* positive and negative misses would cancel otherwise, and squaring gives a smooth bowl-shaped (convex) objective with a single minimum. Squared error is also the natural choice for Gaussian noise (as in §24).
- *Why the ½:* it cancels the 2 that appears when differentiating; it does not change where the minimum is.

### 29.2 The gradient and the normal equations

**Gradient primer.** The **gradient** ∇ₓ*f* of a function of many variables is the vector of its partial derivatives: it points in the direction in which *f* increases fastest, and is zero at a minimum of a smooth bowl.

**Computing it (slide 136).** Expand the square (‖**v**‖² = **v**ᵀ**v**):

```
½ ‖b − A x‖₂² = ½ ( bᵀb − 2 bᵀA x + xᵀAᵀA x )
```

Two matrix-calculus rules (each the multi-variable version of d(*ax*)/d*x* = *a* and d(*ax*²)/d*x* = 2*ax*): the gradient of **c**ᵀ**x** is **c**, and of **x**ᵀ**M x** (for symmetric **M**) is 2**M x**. So

```
∇ₓ ½ ‖b − A x‖₂² = AᵀA x − Aᵀb  =  Aᵀ(A x − b)
```

**Setting it to zero gives the normal equations (slides 136–137):**

```
AᵀA x = Aᵀb          equivalently    Aᵀ(A x − b) = 0
```

**Why "normal."** **A**ᵀ(**A x** − **b**) = 0 says the residual is perpendicular ("normal") to every column of **A** (slide 137). Geometrically: **A x** can only reach points in the column space of **A** (a flat subspace). The closest such point to **b** is its **orthogonal projection**, the foot of the perpendicular dropped from **b**, and the leftover residual is exactly that perpendicular.

> **Worked example (fit a line to three points).** Points (*t*, *y*) = (1, 1), (2, 2), (3, 2). Unknowns **x** = (intercept *a*, slope *s*), model *y* = *a* + *s t*. Each row of **A** is [1, *t*]:
>
> **A** = [[1, 1], [1, 2], [1, 3]], **b** = [1, 2, 2]. Three equations, two unknowns: over-determined.
>
> - **A**ᵀ**A** = [[3, 6], [6, 14]], **A**ᵀ**b** = [5, 11].
> - Solve [[3, 6], [6, 14]]·**x** = [5, 11]: **x** = [0.667, 0.5]. Best line: *y* = 0.667 + 0.5*t*.
> - Residual **r** = **b** − **A x** = [−0.167, 0.333, −0.167]. Check: **A**ᵀ**r** = [−0.167 + 0.333 − 0.167, −0.167 + 0.667 − 0.5] = [0, 0]. The residual is perpendicular to both columns.
> - Objective value: ½(0.0278 + 0.111 + 0.0278) = 0.083. No other line does better.

**Linear-algebra view (least squares is an orthogonal projection onto the column space).** **A x̂** = **A**(**A**ᵀ**A**)⁻¹**A**ᵀ**b** = **P b**, where **P** = **A**(**A**ᵀ**A**)⁻¹**A**ᵀ is the **projection matrix** onto the column space of **A** (it satisfies **P**² = **P**). In the example, **b** = [1, 2, 2] splits into **A x̂** = [1.167, 1.667, 2.167] (in the plane spanned by [1, 1, 1] and [1, 2, 3]) plus **r** = [−0.167, 0.333, −0.167] (perpendicular to that plane). The noise-free part of the data lives in the plane; the part that sticks out of the plane is what no choice of **x** can explain.

**Why not solve the normal equations directly?** **A**ᵀ**A** is *n*×*n*: still 10⁶×10⁶ for a megapixel image, and squaring **A** squares its condition number (6.8 → 46 in the example), making the system more sensitive. Hence gradient descent (§31).

> **Summary**
> - Least squares minimizes **½‖b − Ax‖₂²**, the sum of squared residuals.
> - Rule to remember: gradient **Aᵀ(Ax − b)**; setting it to zero gives the **normal equations AᵀAx = Aᵀb**.
> - The residual is perpendicular to the columns of **A**: least squares is an orthogonal projection of **b** onto the column space.
> - Next: the under-determined case, which needs one more ingredient (§30).

---

## 30. Under-Determined Systems and Regularization

**The problem (slide 138).** With fewer measurements than unknowns (*m* < *n*), **A**ᵀ**A** is *n*×*n* but has rank at most *m* < *n*, so it is **not invertible**: the normal equations have infinitely many solutions (any solution plus anything in the null space).

**The regularized solution (slide 138):**

```
x_est = (AᵀA + λ I)⁻¹ Aᵀ b
```

It is the minimizer of a modified objective, ½‖**b** − **A x**‖₂² + (λ/2)‖**x**‖₂²: fit the data, *and* prefer small images. This is called **Tikhonov regularization** (also **ridge regression**); λ > 0 is the **regularization weight** you choose, and *I* is the identity matrix.

**Why it always works ("always full rank").** **A**ᵀ**A** has eigenvalues μ ≥ 0 (some exactly 0 when it is singular). Adding λ*I* adds λ to every eigenvalue, so every eigenvalue becomes at least λ > 0, and the matrix is invertible. It is "still too big to directly invert," so in practice it is also solved iteratively (§31): the slides rewrite it as (**A**ᵀ**A** + λ*I*)**x** = **A**ᵀ**b**, i.e. a least-squares-type system with matrix **Ã** = **A**ᵀ**A** + λ*I* and right side **b̃** = **A**ᵀ**b** (slide 139).

**"Equivalent to least norm solution."** As λ shrinks toward 0, *x*_est approaches, among all exact solutions, the one with the smallest length ‖**x**‖: it adds nothing from the null space.

> **Worked example.** One measurement, two unknowns: *x*₁ + 2*x*₂ = 5 (**A** = [1, 2], **b** = [5]). Every point on that line is an exact solution. **A**ᵀ**A** = [[1, 2], [2, 4]] has rank 1: not invertible.
> - λ = 1: *x*_est = [0.833, 1.667] (fits 0.833 + 3.333 = 4.17, slightly short of 5, in exchange for a shorter vector).
> - λ = 0.01: *x*_est = [0.998, 1.996], almost exactly on the line.
> - λ → 0: [1, 2], the **least-norm** solution: the point of the line closest to the origin.

**The same formula is the Wiener filter.** For a blur, **A** is circulant with eigenvalues *K*(ω), and **A**ᵀ corresponds to the conjugate *K**(ω) (§31.2). In the Fourier basis, (**A**ᵀ**A** + λ*I*)⁻¹**A**ᵀ becomes, frequency by frequency,

```
K*(ω) / ( |K(ω)|² + λ )
```

which is the Wiener filter of §23 with 1/SNR(ω) replaced by the constant λ, exactly PS4's constant-*k* version. Wiener deconvolution is Tikhonov-regularized least squares, solved in closed form because the Fourier basis diagonalizes everything.

**Linear-algebra view (regularization replaces 1/s by s/(s² + λ) for each singular value).** Write **A** = **UΣV**ᵀ (§27.3). The plain inverse multiplies the component along each singular direction by 1/*s*, which explodes as *s* → 0. The regularized solution multiplies it by *s*/(*s*² + λ) instead: almost 1/*s* when *s*² ≫ λ, but going smoothly to 0 when *s*² ≪ λ. These per-direction multipliers are called **filter factors**; they form a diagonal matrix between **V** and **U**ᵀ, and their curve has the same shape as the Wiener damping factor.

> **Summary**
> - Under-determined (wide **A**): **A**ᵀ**A** is singular and solutions are not unique.
> - Rule to remember: **x_est = (AᵀA + λI)⁻¹Aᵀb**, which adds λ to every eigenvalue so the system is always solvable; λ → 0 gives the least-norm solution.
> - For a blur this is the Wiener filter with constant 1/SNR = λ.
> - Next: solving any of these systems without forming a single inverse (§31).

---

## 31. Gradient Descent

### 31.1 The algorithm

**The idea.** *Analogy:* walking downhill in fog. You cannot see the valley floor, but you can feel which way the ground slopes under your feet. Take a step in the steepest downhill direction, feel again, repeat.

PS4 (slide 15) states it for any objective *f*(**x**): move "in the direction of the negative gradient, the direction in which the function is most steeply decreasing," with **step size** α (also called the **learning rate**):

```
x^(k+1) = x^(k) − α ∇f(x^(k))
```

For least squares (slide 140; PS4 slides 16–17), the gradient is §29.2's **A**ᵀ(**A x** − **b**):

```
x^(k+1) = x^(k) − α Aᵀ( A x^(k) − b )
```

| Symbol | Meaning | Who sets it |
|---|---|---|
| **x**^(*k*) | the estimate after *k* iterations (superscript in parentheses = iteration number, not a power) | the algorithm |
| **A x**^(*k*) − **b** | the current prediction error (minus the residual) | computed |
| **A**ᵀ(…) | carries each measurement's error back onto the unknowns that caused it | computed |
| α | step size | you |

**What each step costs.** One multiplication by **A** and one by **A**ᵀ, nothing else: no inverse, no **A**ᵀ**A** stored. "For large-scale problems, implement as function handles!" means passing these two operations around as functions (PS4 Task 3's `run_gd(A, b, step_size, num_iters, grad_fn, residual_fn)` takes the gradient and residual computations as arguments). PS4's code skeleton computes the residual (objective) as `0.5 * np.linalg.norm(A @ x - b)**2`, where `@` is Python's matrix multiplication.

**Choosing α.** Too small: very slow progress. Too large: each step overshoots the valley floor, and the estimate oscillates and blows up. For least squares the precise limit is α < 2/μ_max, where μ_max is the largest eigenvalue of **A**ᵀ**A** (the steepest curvature of the bowl).

> **Worked example (the line fit of §29).** **A**ᵀ**A** = [[3, 6], [6, 14]] has eigenvalues 16.64 and 0.36, so α must stay below 2/16.64 ≈ 0.120. Start at **x**^(0) = [0, 0], α = 0.05.
> - Iteration 1: gradient = **A**ᵀ(**A**·0 − **b**) = −[5, 11]; **x**^(1) = [0, 0] + 0.05·[5, 11] = [0.25, 0.55]. Objective 0.236.
> - Iteration 2: **A x**^(1) − **b** = [−0.2, −0.65, −0.1]; gradient = [−0.95, −1.8]; **x**^(2) = [0.2975, 0.64]. Objective 0.115.
> - Iteration 10: [0.355, 0.637], objective 0.104. Iteration 100: [0.606, 0.527], 0.0841. Iteration 200: [0.657, 0.504], 0.0834. The exact answer is [0.667, 0.5], objective 0.0833.
> - With α = 0.13 (just above the limit): [0.65, 1.43], then [−0.07, −0.25], then [0.80, 1.69]: bouncing ever farther. It diverges.
>
> Why so slow at α = 0.05? The bowl is 46 times steeper in one direction than the other (condition number of **A**ᵀ**A** = 16.64/0.36 = 46). A step small enough not to overshoot the steep direction crawls along the shallow one. Poor conditioning (§27.2) slows gradient descent the same way it amplifies noise.

### 31.2 Gradient descent for deconvolution: the transpose of a blur

**Back to the convolution example (slide 141).** When **A** is "convolve with the PSF *c*," the update becomes

```
x^(k+1) = x^(k) − α · c* ∗ ( c ∗ x^(k) − b )
```

**What c\* is.** **A**ᵀ for a convolution is itself a convolution, with the **flipped** kernel, *c**(*x*) = *c*(−*x*) (for a real kernel; the star here means "flipped," the **adjoint** of the blur, not ordinary convolution). Why flipped: row *r* of **A** says which inputs land on output *r*; column *r* of **A** (= row *r* of **A**ᵀ) says which outputs input *r* spread to. Blur sends light forward along the kernel; the transpose gathers it back along the mirror image.

> **Worked example.** Full convolution with *c* = [1, 2, 3] on a 3-sample signal is the 5×3 matrix with columns [1, 2, 3, 0, 0], [0, 1, 2, 3, 0], [0, 0, 1, 2, 3]. Its transpose has rows [1, 2, 3, 0, 0], [0, 1, 2, 3, 0], [0, 0, 1, 2, 3]. Apply the transpose to an impulse at position 2, [0, 0, 1, 0, 0]: the result is [3, 2, 1], the kernel **reversed**. So **A**ᵀ = convolution with the flipped kernel [3, 2, 1].

**Efficient version via the convolution theorem (slide 141).** Each convolution becomes an FFT, a multiplication and an inverse FFT; the flip becomes the complex conjugate:

```
x^(k+1) = x^(k) − α · F⁻¹{ F{c}* · ( F{c} · F{x^(k)} − F{b} ) }
```

(For a real kernel, flipping in space = conjugating in frequency, since conjugate symmetry gives F{*c*(−*x*)} = F{*c*}*, §3.3.) Each iteration costs a few FFTs, about *n* log *n*, instead of anything proportional to *n*².

**Gradient descent's connection to Wiener.** Iterating this update from **x**^(0) = 0 applies, at each frequency, a gain that grows from 0 toward 1/*K* as iterations proceed, fastest where |*K*| is large. Stopping early leaves the small-|*K*| frequencies (the noisy ones) under-restored: early stopping acts like a regularizer, similar in spirit to Wiener's damping.

**Linear-algebra view (the adjoint of a convolution is the transposed Toeplitz matrix).** The 5×3 convolution matrix **A** above has the kernel running down each column; **A**ᵀ (3×5) has the same kernel running along each row, read left to right as 1, 2, 3, which, when slid as a convolution kernel, is the flipped kernel [3, 2, 1]. In the Fourier basis, **A** is diag(*C*) and **A**ᵀ is diag(*C**): transposing a real circulant matrix conjugates its eigenvalues.

> **Summary**
> - Rule to remember: **x^(k+1) = x^(k) − α Aᵀ(Ax^(k) − b)**; each step needs only one product with **A** and one with **A**ᵀ.
> - α must be below 2/μ_max (0.12 in the line fit) or it diverges; ill-conditioning makes convergence slow (200 iterations to approach the answer).
> - For blur, **A**ᵀ = convolution with the **flipped kernel**, = multiplying by **F{c}\*** in the Fourier domain.
> - Next: when even one product with the full **A** is too expensive (§32).

---

## 32. Stochastic Gradient Descent (SGD)

**The problem (slide 142).** "What if our measurements are too large to store in memory?" Each gradient step uses *all* *m* rows of **A** and all of **b**. That can be too much for very large linear problems, and it is the normal situation for nonlinear models such as neural networks trained on millions of images.

**The idea (slide 143; PS4 slide 18).** The least-squares objective is a sum over measurements:

```
‖A x − b‖₂² = Σ_{i=1}^{m} ( a_iᵀ x − b_i )²          (a_iᵀ = row i of A)
```

so its gradient is a sum of per-measurement gradients. At each iteration, use only a random subset of rows ("sampling entries/rows from **b** and **A**"):

```
b̃ = Ã x                                           (the sampled rows only)
x^(k+1) = x^(k) − α Ã^(k)ᵀ ( Ã^(k) x^(k) − b̃^(k) )
```

| Symbol | Meaning |
|---|---|
| **Ã**^(*k*), **b̃**^(*k*) | the rows of **A** and entries of **b** chosen at iteration *k* (a new random choice each time) |
| **batch size** *B* | the number of rows chosen per iteration (PS4: "the number of rows is the batch size") |
| `np.random.randint` | PS4's suggested way to pick the random row indices |

**Why it still works: the gradient is right on average.** PS4 writes the general rule as **x**^(*k*+1) ← **x**^(*k*) − α*g*(**x**^(*k*)) with E[*g*(**x**)] = ∇*f*(**x**): the random gradient estimate *g* is **unbiased**, it equals the true gradient on average. For least squares, choosing *B* of the *m* rows uniformly at random and scaling the sampled gradient by *m*/*B* makes it exactly unbiased (a numeric check with *m* = 1000 rows and *B* = 10 matches the full gradient to within about 0.5% after averaging 20 000 draws). Without the *m*/*B* factor the estimate is the true gradient shrunk by *B*/*m*, which a correspondingly larger α absorbs.

**Trade-offs (slide 144; PS4 slide 20).**

- **Gradient descent** is expensive per iteration but converges smoothly and precisely ("better convergence").
- **SGD** is cheap per iteration and makes fast progress far from the minimum, but near the minimum the randomness keeps it jittering ("struggles close to minima"; slide 144's contour plot shows the blue GD path heading straight to the center and the red SGD path zig-zagging). Its randomness can help escape poor regions of **non-convex** objectives (bumpy landscapes with many valleys), which is why it dominates neural-network training.
- **Per iteration vs. per second.** PS4's plots: against *iteration count*, full GD and large-batch SGD drop fastest, and small batches (*B* = 10) crawl; the flat "SVD" line is the exact least-squares answer, computed directly as a reference floor. Against *wall-clock time*, the cheap SGD iterations can win. "Exact runtimes and order of convergence in wall clock time may vary!"
- **Measuring progress fairly.** PS4: "Use full **A** matrix, not subsampled **A**, to compute residual." The objective reported each iteration must be the full ½‖**A x** − **b**‖², or different batch sizes are not comparable.

**Linear-algebra view (SGD multiplies by a random row-selection matrix).** Choosing rows is multiplying by a *B*×*m* selection matrix **S**^(*k*) (one 1 per row, like §7's): **Ã** = **S**^(*k*)**A**, **b̃** = **S**^(*k*)**b**. The SGD step uses **A**ᵀ**S**^(*k*)ᵀ**S**^(*k*)(**A x** − **b**). Averaged over random choices, **S**ᵀ**S** is (*B*/*m*) times the identity, which is why the scaled estimate is unbiased.

> **Summary**
> - SGD replaces the full gradient with one computed from a random batch of rows: **x^(k+1) = x^(k) − α Ãᵀ(Ãx^(k) − b̃)**.
> - Rule to remember: the batch gradient is **unbiased** (right on average, with an *m*/*B* scale), cheap per step, noisy near the minimum.
> - Compare methods by the *full* residual, against both iterations and wall-clock time.
> - Next: what Week 6 adds on top of all this (§33).

---

## 33. Looking Ahead

The lecture's summary slide (slide 125) and closing slides, restated with where each idea was built here:

- **Shannon–Nyquist theorem:** "always sample signal at a sampling rate ≥ 2 × highest frequency of signal!" (§8).
- **If it is violated, aliasing occurs**, and "aliasing cannot be corrected digitally in post-processing (see optical anti-aliasing filter)" (§8.4, §19, §21).
- **"PSF is usually a low-pass filter, so deconvolution is an ill-posed inverse problem"** (§22). An **ill-posed** problem is one whose solution does not exist, is not unique, or changes wildly with tiny changes in the data; deconvolution fails the last two.
- Wiener filtering gives results that are "not too bad, but noisy"; doing better needs "more advanced image **priors**": assumptions about what real images look like (slide 124).

**Where this goes next (optional).** Week 6 ("Solving regularized inverse problems with ADMM") replaces §30's simple preference for small ‖**x**‖ with richer natural-image priors (for example, "images are mostly smooth, with a few sharp edges"), and introduces ADMM, an optimization method that splits such problems into easier alternating steps. Every forward model there is still **b** = **A x**, and the inner steps still use the FFT-based tricks of §16, §23 and §31.

> **Summary**
> - Sample at ≥ 2× the highest frequency; aliasing cannot be fixed afterwards.
> - A PSF is a low-pass filter, so deconvolution is ill-posed: Wiener (= Tikhonov) helps, priors help more.
> - Rule to remember: every problem this week is **b = Ax**, solved with products by **A** and **A**ᵀ, never by **A**⁻¹.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology stays in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check

**Parts 1–2.** If a friend asked why sampling a 24 Hz wave at 20 samples per second gives the same numbers as a 4 Hz wave, you should be able to answer using only the words "comb," "shifted copies," and "Nyquist frequency," without looking anything up.

**Part 3.** If asked why stopping a lens down from f/2 to f/16 makes a photo blurrier even though it increases depth of field, you should be able to answer using only "aperture," "Fourier transform," and "OTF cutoff."

**Part 6.** If asked why the inverse filter turns a slightly noisy blurred photo into pure noise while the Wiener filter does not, you should be able to answer using only "OTF zeros," "N/K," and "damping factor."

**Part 7.** If asked why nobody computes **A**⁻¹**b** for a megapixel deblurring problem, and what they do instead, you should be able to answer using only "rank," "condition number," "Aᵀ," and "step size."
