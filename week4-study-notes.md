# CSC2529 Computational Imaging — Week 4 Study Notes

**Topic:** Great Ideas in Computational Photography — HDR Imaging, Tone Mapping, Coded Imaging
**Source:** Lecture 4 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 4 ("PS4," the TA problem session covering HW4; the course site lists the HDR/SNR session as PS3), Task 1 only (image filtering: PSF, OTF, primal-domain vs. Fourier-domain filtering). The exposure, exposure-time and ISO material (§2) comes from Lecture 2, moved here from Week 2's notes because everything after it leans on it.
**HW3 supplements:** §3, §10.4–§10.5, §9.5, §11, §14.1–§14.2, and §23.3 go beyond the lecture slides and exist to cover what HW3 (HDR fusion, burst denoising SNR, flutter shutter SNR) needs. They explain methods and set up quantities but never compute the assignment's own answers. Problem Session 3 ("PS3," the HW3 problem session: Debevec merge, tonemapping, burst and flutter-shutter SNR) is the source for these supplements.
**Order differs from the slides.** The lecture jumps between topics (it opens with a bracketed-exposure teaser, defines exposure only in passing, and introduces PSFs only after the coded-aperture slides). These notes reorder it so that every section uses only ideas already built above it: exposure, then noise from combining frames, then metering and dynamic range, then HDR (bracketing, calibration, merging), then tonemapping, then the PSF/OTF primer, and only then the coded-imaging topics that need it (coded aperture, extended depth of field, depth, flutter shutter, parabolic sweep). Each section ends with a **Summary** box; forward pointers appear only there, as optional "where this goes next" lines.
**Scope:** Announcements, the HW4/project-proposal reminders, and the problem-session plug are skipped. PS4's Tasks 2–3 (deconvolution/inverse filtering/Wiener deconvolution, and gradient descent/SGD) are **not** covered here: they are the formal inverse-problem material that belongs to Weeks 5–6 (§26 says where each piece lands). Only PS4's Task 1 is used, since it directly supports the PSF/OTF material (§18).
**Two loose words, flagged where they first appear.** (1) "**Exposure**" is used loosely for "how bright the photo looks" and strictly for *H*, the light energy per unit sensor area (§2.1). (2) "**HDR imaging**" is used for five different things in the lecture; §16 lists and separates them once all the building blocks exist.

---

# Part 1 — Exposure, Noise, and HDR Imaging

## 1. Motivation: One Scene, Many Exposures

A camera does not take one perfect picture of a high-contrast scene. It takes a family of pictures, one per exposure setting, and each gets some part of the scene right at the expense of another.

The lecture's opening slides show the same room photographed four times, from very dark to very bright:

- The darkest shot shows only the sky and the window detail.
- The brightest shot shows only the room's shadows.
- Everything else in each shot is clipped to pure white or crushed to pure black.

Two problems follow, and they structure Part 1:

1. **HDR imaging** (high-dynamic-range imaging): combine the whole family into one image that represents *every* brightness in the scene. This is about what the **sensor** can *measure*.
2. **Tonemapping**: squeeze that combined image onto a screen that cannot reproduce anywhere near that brightness range. This is about what the **display** can *show*.

The lecture is emphatic that these are "distinct techniques with different goals": **HDR imaging compensates for sensor limitations; tonemapping compensates for display limitations.**

First, though, we need to build "exposure" itself, because every later section leans on it.

> **Summary**
> - One exposure setting cannot capture a high-contrast scene; a family of exposures can.
> - Two separate jobs: *measure* the whole brightness range (HDR imaging), then *show* it on a limited display (tonemapping).
> - Next: what "exposure" actually means, built from scratch (§2).

---

## 2. Exposure, Exposure Time, and ISO

*This material is from Lecture 2, moved here from Week 2's notes. Week 2 now points here.*

Exposure time is the one camera setting that trades *time* for *light*, and time is where motion, noise and saturation enter. This section builds the idea from scratch.

### 2.1 What "exposure" means: three uses of one word

**Analogy.** A bucket left out in the rain. What ends up in it depends on how hard it rains (the *rate*) and how long you leave it out (the *time*). A sensor pixel is the bucket, photons are the raindrops, and the photo-generated electrons of Week 2 §14 are the water.

**The shutter.** A **[shutter](https://en.wikipedia.org/wiki/Shutter_(photography))** decides *when* collection starts and stops. It is either a physical curtain that uncovers the sensor, or an **electronic shutter** that clears each pixel's charge at the start and reads it out at the end. The bucket model is the same either way: charge = rate × open time.

"Exposure" is used in three senses; mixing them up is the main source of confusion:

| Term | What it means | Units | Who controls it |
|---|---|---|---|
| **Exposure time** (a.k.a. **shutter speed**) | How *long* the shutter lets each pixel collect light | seconds (1/250, 1/60, 1, 15…) | You |
| **Exposure** (strict sense, *H*) | *Total* light delivered per unit sensor area during that time: water per square centimeter of bucket opening | lux·seconds | Exposure time, aperture (Week 2 §8) and scene brightness, but **not** ISO |
| **"An exposure"** (countable noun) | One captured frame ("take three exposures and merge them") | — | — |

In this file, "exposure" alone means the strict *H*; the duration is always "exposure time." A "fast shutter speed" is a *short* exposure time.

The lecture also uses a looser, plain-language sense: **how bright the photo looks = Gain × Flux × Time**, where *gain* is ISO (§2.5), *flux* is the light let in (set by the aperture) and *time* is exposure time. This loose product folds ISO in, so it is *not* the strict *H* below.

**"Bulb" mode** is an exposure time with no preset value: the shutter stays open while the button is held. HW1's pinhole-box photos (15–60 s) are long exposures of this kind, needed because a pinhole (Week 2 §4) passes very little light per second.

### 2.2 The exposure formula

```
H = E · t          and, for a lens,          E ≈ (π/4) · L / N²
so:                H ∝ L · t / N²
```

**Intuition.**

1. The first equation is the bucket: total = rate × time. The rate of light per unit sensor area is the **[irradiance](https://en.wikipedia.org/wiki/Irradiance)** *E* (photometric name: **illuminance**).
2. If *E* is steady while the shutter is open, *H* = *E*·*t*. If *E* changes (a flickering lamp), *H* is the **area under the E-versus-time curve**; "rate × time" is the flat special case.
3. The second equation says where *E* comes from. A scene patch of fixed brightness *L* sends light toward the lens. The light collected grows with the aperture's *area* ∝ *D*² (Week 2 §4, §8). The patch's image is spread over an area that grows with *f*², by the same inverse-square logic as Week 2 §4. The ratio is *D*²/*f*² = 1/*N*².
4. So the f-number *N* alone captures everything the lens contributes, which is why photographers use it instead of *D* or *f* separately.

**Term by term:**

- ***H*** — **exposure**: total light energy per unit sensor area in one capture (lux·s photometrically, J/m² radiometrically). You do not set it directly.
- ***E*** — **image-plane irradiance**: light *power* per unit sensor area (lux, or W/m²). Fixed by the scene plus the aperture.
- ***t*** — **exposure time**, seconds. **You control this.**
- ***L*** — scene **[luminance](https://en.wikipedia.org/wiki/Luminance)**: how bright the scene patch is (candela per m²). Fixed by the scene and lighting, unless you add light (a flash; in LiDAR, a laser).
- ***N*** — the **f-number** of Week 2 §8 (dimensionless). **You control this.** It is squared because light gathered scales with aperture *area*.
- ***π/4*** — geometric constant from integrating over a circular aperture. It never changes, which is why the proportional form (∝) is all a photographer needs. The ≈ hides small real-lens losses: glass transmission below 100%, and dimming toward the image corners (**vignetting**).

**Link to noise.** In Week 2 §19's SNR formula, *P* (photons per pixel per second) is just *E* counted in photons and multiplied by one pixel's area. The mean signal *P·Qe·t* is "exposure in photons × quantum efficiency": the same *E·t*, counted in electrons.

**Reciprocity.** *H* depends only on *t*/*N*². Halving *t* while opening the aperture one stop leaves *H* unchanged. Different (*t*, *N*) pairs with the same *H* are **equivalent exposures**, and this interchangeability is the **reciprocity law**. For a digital sensor it holds essentially exactly (electrons accumulate linearly) until the pixel fills up (§2.4).

### 2.3 Stops of time, and the equivalent-exposure ladder

Exposure time is spaced in the same **stops** as aperture (Week 2 §8): one stop = a factor of 2 in light. The standard sequence 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1 s doubles at every step. Unlike the aperture sequence there is no √2, because exposure time enters *H* directly, not squared.

**Stops notation for all three controls** (full primer: Week 1 §14; aperture: Week 2 §8):

- Comparing a new exposure time *t*₂ with an old one *t*₁: `stops = log₂(t₂ / t₁)`. Positive means *more* light.
- Shutter dials print rounded values (1/60 for 1/64 s, 1/125 for 1/128 s).
- Third-stop steps multiply the time by 2^(1/3) ≈ 1.26 (1/125 → 1/100 → 1/80 → 1/60).
- ISO also doubles per stop (100 → 200 → 400); third-stop ladder 100, 125, 160, 200, 250, 320, 400.
- An exposure-compensation setting of "+2" asks for 2 stops (4×) more brightness, "−1" for half. The camera delivers it with whichever of the three controls it may change.

> **Worked example (generic, not HW3).** Start at f/4, 1/60 s, ISO 100. Go to ISO 400 (+2 stops of gain) and keep brightness: the other settings must give 2 stops *less* light, e.g. shutter 1/60 → 1/250 (≈ −2 stops). Net: +2 − 2 = 0 stops. The brightness is identical, but motion blur dropped (shorter shutter) and noise rose (§2.5).

The lecture's "Depth of Field & Motion Blur" slide prints a ladder of equivalent exposures. Plugging each pair into *t*/*N*² (relative to the first), and into the **exposure value** EV = log₂(*N*²/*t*) (one number labelling a whole family of equivalent exposures; one EV step = one stop), gives:

| Aperture | Exposure time | *t*/*N*² relative to f/16, 1/8 s | EV |
|---|---|---|---|
| f/16 | 1/8 s | 1.000 | 11.00 |
| f/11 | 1/15 s | 1.128 | 10.83 |
| f/8 | 1/30 s | 1.067 | 10.91 |
| f/5.6 | 1/60 s | 1.088 | 10.88 |
| f/4 | 1/125 s | 1.024 | 10.97 |
| f/2.8 | 1/250 s | 1.045 | 10.94 |
| f/2 | 1/500 s | 1.024 | 10.97 |

Every row delivers (within ~13%, under 0.2 stop) the *same* exposure. The wobble comes only from rounded marked numbers: "f/11" is really 16/√2 ≈ 11.3, and "1/15" is really 1/16. Yet the three photos on that slide look completely different:

- **f/16, 1/8 s:** small aperture (deep **depth of field**, Week 2 §10), long exposure time. The flying pigeons smear into ghostly streaks: **motion blur** (the streaking of anything that moves during the exposure).
- **f/2, 1/500 s:** wide aperture (shallow depth of field), exposure time 62.5× shorter. The pigeons are frozen mid-wingbeat.

Exposure fixes only the *brightness*. The *path* along the ladder decides what kind of image you get.

**Linear-algebra view (equivalent exposures as a null space).**

- Take logarithms: log₂*H* = log₂*L* + log₂*t* − 2·log₂*N* (+ a constant). The multiplicative formula becomes linear.
- Collect your two settings into **s** = (log₂*t*, log₂*N*). A change Δ**s** changes log-exposure by the row vector **r** = [1, −2] applied to it: Δlog₂*H* = **r**·Δ**s**.
- The setting changes that leave exposure *unchanged* form the **null space** of **r**: every multiple of (2, 1). "One stop wider aperture (log₂*N* down by ½), one stop shorter time (log₂*t* down by 1)" is (−1, −½), on that line.
- So the ladder is literally a walk along the null space of a 1×2 matrix. Moving *off* the line changes brightness; moving *along* it trades depth of field against motion blur.

### 2.4 Getting it wrong: underexposure, overexposure, saturation

Each pixel's bucket has a finite size: the **full-well capacity**, the maximum number of electrons a photodiode can hold.

- **Overexposure.** Too much *H*: bright regions overflow and every pixel there reads the same maximum. This is **saturation**, or **[clipping](https://en.wikipedia.org/wiki/Clipping_(photography))**. A white shirt and the sun behind it both become flat "max white," and no processing can recover the difference, since the sensor never recorded it.
- **Underexposure.** Too little *H*: dark regions collect only a handful of electrons, so the noise floor of Week 2 §18 (read noise *Nr*, dark current *D·t*) is comparable to the signal. The detail is there but buried. Brightening afterwards (digitally or via ISO, §2.5) amplifies the noise too.
- **"Correct" exposure** places the scene's important brightness range between those two failures. That window is the sensor's **dynamic range** (Week 2 §20). When the scene's range is wider (a sunlit window inside a dark room), *no* single exposure works: one clips the window, the other buries the room in noise. That is the motivation for HDR imaging, later in this file.

### 2.5 ISO: brightness from gain, not from light

**[ISO](https://en.wikipedia.org/wiki/Film_speed)** ("film speed," a name carried over from chemical film) is, in the usual camera design, an **analog gain** applied to the sensor's signal *before* the analog-to-digital converter (ADC, Week 2 §17).

- Raising ISO does not collect more photons. It electrically amplifies whatever charge was collected, lifting a dim signal into a usable digital range.
- It amplifies the noise already present (shot noise, and read noise added before the amplifier) along with the signal, so it cannot raise the SNR set by the photons collected (Week 2 §19).
- At most, amplifying before the ADC makes the noise added *after* the amplifier matter less. ISO trades *cleanliness* for *brightness* on a fixed amount of light.

So ISO does **not** change the exposure *H*; it changes how bright the *recorded image* is for a given *H*. Photographers speak of an "**exposure triangle**"; the table says what each corner does:

| Knob | Changes the light collected (*H*)? | Side effect you pay |
|---|---|---|
| Aperture (f-number, Week 2 §8) | Yes, ∝ 1/*N*² | Depth of field (Week 2 §10); diffraction at small apertures (Week 2 §12) |
| Exposure time | Yes, ∝ *t* | Motion blur, camera shake, saturation risk |
| ISO (gain) | **No**; scales the output only | Amplified noise; highlights clip sooner at high gain |

> **Optional: where exposure resurfaces (old pointers kept short).**
> - *Rolling shutter* (Week 2 §16): each sensor row gets its own exposure window, offset from its neighbors'.
> - *Dark-frame subtraction* (Week 3's ISP pipeline): a dark frame is an exposure with the shutter closed at the same *t*, capturing the dark-current *D·t* signal (plus fixed offset) so it can be subtracted. *Autoexposure* is the camera picking *t*, *N* and ISO from a brightness measurement (**metering**, §6).
> - Later in this file: HDR bracketing (§8) merges exposures of different *t*; coded exposure (§23) reshapes the timing of one exposure; deconvolution (Week 5) inverts the resulting blur.

> **Summary**
> - Exposure *H* = *E*·*t* ∝ *L*·*t*/*N*² is "rate × time" for light; ISO scales the recorded image but does *not* change *H*.
> - Rule to remember: one stop = 2× light; equivalent exposures share the same *t*/*N*² (the same EV) and differ only in blur and depth of field.
> - Too much *H* clips (information lost for good); too little drowns in noise.
> - Next: what happens to noise when you combine several short exposures (§3), then the long-versus-short trade-off (§4).

---

## 3. Noise Statistics of Summed and Averaged Frames (supports HW3 Task 2)

*(Beyond the lecture's slides: the probability rules behind burst photography, stated in general form so they apply to any combination of noise sources. Applying them to HW3's specific noise models is left to the assignment.)*

**Why now.** Exposure time buys light; a second way to buy light is to take *K* frames and combine them. Whether that is as good as one long exposure depends on how noise adds up, so we need the rules first.

**Vocabulary, restated** (full from-scratch version with a numeric example: Week 2 §18).

- A pixel's recorded value is a **random variable**: re-photograph the scene and the number changes slightly.
- Its **mean** μ is the average over many repeats (the "true signal"). Its **variance** σ² is the average squared deviation from the mean. Its **standard deviation** σ = √variance is the typical wobble, in pixel-value units.
- **SNR** = μ/σ (Week 2 §19).

Two noise models matter (Week 2 §18):

- **Gaussian (normal) noise**, 𝒩(μ, σ²): a bell curve. Read noise is modeled this way; σ does not depend on the signal.
- **Poisson noise**, Pois(λ): counts of randomly timed events (photon arrivals) with average λ. Mean and variance are **both** λ, so the standard deviation is √λ.

**Two basic rules, for *independent* random variables** (one draw does not influence another):

1. **Variances of a sum add.** Var(*X*₁ + ... + *X*_K) = Var(*X*₁) + ... + Var(*X*_K).
   - *Why:* independent deviations are as likely to cancel as to reinforce, so cross terms average to zero and only each variable's squared deviation survives (Week 2 §19's "orthogonal vectors" picture).
   - **Standard deviations do not add**: for two equal terms, σ_total = √(σ² + σ²) = σ√2, not 2σ.
   - Two families are closed under addition: 𝒩(μ₁, σ₁²) + 𝒩(μ₂, σ₂²) = 𝒩(μ₁ + μ₂, σ₁² + σ₂²), and Pois(λ₁) + Pois(λ₂) = Pois(λ₁ + λ₂). So splitting a photon count across frames and adding the frames back is statistically the same as counting once.
2. **Scaling squares.** Var(*c*·*X*) = *c*²·Var(*X*).
   - *Why:* multiplying *X* by *c* stretches every deviation by *c*, and squaring a stretched deviation gives *c*² times the original square. The standard deviation scales by plain |*c*|.
   - A scaled Poisson variable is **no longer** Poisson (its variance *c*²λ no longer equals its mean *c*λ). To average Poisson counts, apply rule 1 first, then rule 2.

A pixel with several noise sources (shot, dark current, read) is also covered by rule 1: the total variance is the sum of the individual variances, the denominator of Week 2 §19's SNR formula.

**Averaging *K* aligned frames, step by step.** Each of *K* frames gives an independent measurement *X*_k of the same pixel, with mean μ and variance σ² (itself possibly a sum of shot, dark and read variances). Let the **sum** be *S* = *X*₁ + ... + *X*_K and the **average** *M* = *S*/*K*.

1. **Sum, mean:** *K* terms each with mean μ, so the mean of *S* is *K*μ.
2. **Sum, variance (rule 1):** *K* terms each contributing σ², so Var(*S*) = ***K*·σ²**. The factor *K* is simply the *count of terms*. The sum's standard deviation σ√*K* grows more slowly than the signal *K*μ, so the sum's SNR is *K*μ/(σ√*K*) = √*K*·μ/σ.
3. **Divide by *K* (rule 2 with *c* = 1/*K*):** the mean is (1/*K*)·*K*μ = μ (signal unchanged) and the variance is (1/*K*)²·*K*σ² = **σ²/*K***. The *K*² comes from squaring the 1/*K* in front of the sum; one *K* cancels, leaving a single *K* in the denominator.
4. **Standard deviation of the average:** σ_M = **σ/√*K***.

Averaging keeps the signal and shrinks the noise *variance* by *K* (the standard deviation by √*K*). Sum and average have the *same* SNR, √*K*·μ/σ, because rescaling multiplies mean and standard deviation by the same factor.

> **Worked example (pure rules, *K* = 4, by hand).** Each frame reads a pixel with true signal μ = 10 and σ = 2 (variance 4).
> - Sum of 4: mean 40; variance 4 + 4 + 4 + 4 = 16 (the factor *K* = 4 is the count of terms); σ_sum = 4. Not 4 × 2 = 8: standard deviations do not add.
> - Divide by 4: mean 10; variance (1/4)² × 16 = **1**; σ_avg = 1.
> - Check: σ²/*K* = 4/4 = 1 and σ/√*K* = 2/2 = 1. ✓
> - SNR: one frame 10/2 = 5; averaged 10/1 = 10, i.e. √4 = 2 times better. Doubling SNR cost 4 frames.

**When does this work?** The derivation assumed the *K* noise draws are **independent** with the **same variance**, and that the frames are **aligned** (the same scene point lands on the same pixel; otherwise you average different scene content).

- **Averages down (variance ∝ 1/*K*):** every *fresh random draw per frame*: shot noise, dark-current noise, read noise, quantization noise (Week 2 §18).
- **Does NOT average down:** **fixed-pattern noise**, since it is identical in every frame (perfectly *correlated*; the cross terms rule 1 dropped are as large as the variances). Averaging 100 frames leaves it untouched. A drifting light level, a shared reference-voltage wobble or an unaligned moving subject behave the same way.
- **Read noise is paid per readout:** *K* frames contain *K* read-noise draws, so the sum's read variance is *K*·*Nr*², whereas one *K*-times-longer exposure pays *Nr*² once. A burst is therefore not quite as clean as one long exposure of the same total light.

How the averaged SNR scales with *K* depends on what σ² is made of; that is the exercise HW3 Task 2 poses for its two noise models, and it is left to the assignment.

**Linear-algebra view.**

- Averaging *K* frames is a dot product with the weight vector **a** = (1/*K*, ..., 1/*K*).
- If the *K* noise values are independent with equal variance σ², their covariance matrix is σ²**I** (diagonal, by independence). The output variance of any linear combination **a**ᵀ**n** is **a**ᵀ(σ²**I**)**a** = σ²‖**a**‖².
- Here ‖**a**‖² = *K*·(1/*K*)² = 1/*K*, reproducing σ²/*K*. The *K* is the number of entries; the (1/*K*)² is the squared weight.
- This is the "uncorrelated noise behaves like orthogonal vectors" fact of Week 2 §19: squared length of the output = sum of squared lengths of its parts.
- If the noises were *correlated*, the covariance matrix would have non-zero off-diagonal entries and the answer would exceed σ²/*K*. Fixed-pattern noise is the extreme case, every entry 1, where nothing is gained.

> **Worked example (a mixed-noise case, deliberately not either of HW3's cases).** Per frame: mean 20 photons, Poisson shot noise (variance 20) plus Gaussian read noise σ = 4 (variance 16), *K* = 4 frames.
> - One frame: variance 20 + 16 = 36, σ_total = 6, SNR = 20/6 ≈ **3.33**.
> - Average of 4: mean 20; variance 36/4 = 9, σ_total = 3; SNR = 20/3 ≈ **6.67**, a factor 2 = √4 better.
>
> The √*K* gain holds here because the *total* per-frame variance is the same in every frame. HW3's flutter-shutter-vs-burst comparison (late in this file) differs: the burst's per-frame variance is itself smaller than the single exposure's.

> **Summary**
> - Independent noise: **variances add**, standard deviations do not; scaling by *c* scales variance by *c*².
> - Rule to remember: averaging *K* aligned frames keeps the signal and gives variance σ²/*K*, so σ/√*K* and SNR ×√*K*.
> - It fails for fixed-pattern noise (same every frame), for unaligned frames, and read noise is paid once per readout.
> - Next: use these rules to compare long exposures with bursts (§4).

---

## 4. Long vs. Short Exposure, and Burst Photography

Holding everything else fixed, lengthening exposure time collects more light. That helps and hurts in predictable ways.

### 4.1 The trade-off table

| | Short exposure (e.g. 1/500 s) | Long exposure (e.g. 1/8 s, 2 s, bulb) |
|---|---|---|
| Light collected | Less | More (∝ *t*) |
| Noise (Week 2 §18) | Worse SNR; shot-noise-limited SNR ∝ √*t* | Better SNR |
| Moving subjects | Frozen | Smeared into streaks / trails (**motion blur**) |
| Camera shake (hand-held) | Negligible | Whole frame blurs unless on a tripod |
| Bright regions | Less risk of clipping | More risk of saturation |
| Dark current *D·t* (Week 2 §19) | Negligible | Grows with *t* (matters for very long exposures) |
| Price elsewhere to keep the same brightness | Wider aperture (shallower depth of field, Week 2 §10) or higher ISO (amplified noise, §2.5) | Smaller aperture possible (deeper depth of field) |
| Typical uses | Sports, wildlife, anything fast; bright daylight | Night scenes, astronomy, light trails, "silky" water, HW1's pinhole box |

### 4.2 Worked example: the lecture's night-highway photos

Two photos of the same highway at night (slide "Exposure (shutter speed)"):

- **Photo A:** 1/4 s at f/3.3, ISO 200. Moving cars show as short, partly-recognizable blurs.
- **Photo B:** 2 s at f/6.3, ISO 80. The cars have vanished, replaced by long continuous red and white **light trails**.

Why do they look about equally bright?

1. **Time:** B's exposure time is 2 / 0.25 = **8×** longer (3 stops more light).
2. **Aperture:** its f-number is larger, so relative light per second is (3.3/6.3)² ≈ 0.27× (≈1.9 stops less).
3. **Net exposure:** *t*/*N*² gives 2.0/6.3² ÷ 0.25/3.3² ≈ **2.2×** more light in B (+1.13 stops).
4. **ISO:** B uses ISO 80 instead of 200, a 0.4× gain (−1.32 stops). Final brightness ≈ 2.2 × 0.4 ≈ **0.88×** A's, only ~0.19 stop apart.

Photo B spent its brightness budget on a much longer exposure time. Every headlight moved far *during* the exposure and painted its whole path onto the sensor: motion blur used deliberately.

### 4.3 Worked example: how long is a motion-blur streak?

A moving point slides across the sensor during the exposure, leaving a streak:

```
blur length (pixels) = image-plane speed (pixels/second) × exposure time (seconds)
```

- *Image-plane speed*: how fast the subject's image crosses the sensor. Fixed by the subject's real speed, its distance and the focal length, not by you.
- *Exposure time*: yours to choose.

Illustrative numbers: a subject crossing a 4000-pixel-wide frame in 2 s moves at 4000/2 = 2000 px/s.

| Exposure time | Streak length |
|---|---|
| 1/500 s | 4 px (looks sharp) |
| 1/125 s | 16 px (visibly soft) |
| 1/8 s | 250 px (a smear, like the slide's pigeons) |
| 2 s | 4000 px (the full frame width: a trail, like Photo B) |

The streak grows *linearly* with exposure time. "Freezing motion" just means making *t* small enough that the streak is shorter than about one pixel.

*For uniform motion along one direction, each recorded pixel is a time average of the scene points that slid past it, which is a convolution with a flat "box" kernel (Week 1 §20, §21). §23 builds the matrix and Fourier view of this and shows how to make it invertible.*

### 4.4 Worked example: why long exposures are cleaner

In the shot-noise-limited case (bright enough that *Nr* and *D* are negligible), SNR = √(*P·Qe·t*) ∝ √*t* (Week 2 §19):

- doubling the exposure time improves SNR by √2 ≈ 1.41×
- 4× the time gives 2×
- 16× the time gives 4×

Diminishing returns, but steady: to halve the relative noise you need 4× the light.

### 4.5 Worked example: one long exposure vs. many short ones (burst photography)

Instead of one long exposure, take *k* short ones and add them afterwards. Each frame is short enough to avoid blur, and you can re-align frames before summing. Is it as clean?

Illustrative very dim scene (using Week 2 §19's formula and §3's sum rules): 25 electrons per pixel per short frame, read noise *Nr* = 3 electrons, *k* = 16 frames. Noise variance is in electrons².

| Capture | Signal | Noise variance | SNR |
|---|---|---|---|
| One short frame | 25 | 25 (shot) + 3² (read) = 34 | √34 = 5.83, so 25/5.83 = **4.29** |
| One long exposure (16× the time) | 400 | 400 (shot) + 3² (read) = 409 | √409 = 20.22, so 400/20.22 = **19.78** |
| 16 short frames, summed | 400 | 16·25 (shot) + 16·3² (read) = 400 + 144 = 544 | √544 = 23.32, so 400/23.32 = **17.15** |

- Same total light, but the burst pays read noise 16 times (once per readout): 16·3² = 144 instead of 9.
- Its shot-noise variance is the same 400 either way, since 16 frames of 25 photons are statistically one count of 400 (the Poisson sum rule, §3).
- Because the variances add, the burst's SNR comes out lower.
- For bright scenes, where shot noise dominates, the gap nearly vanishes. That is why phones can replace one long, blur-prone exposure with a burst of short, well-aligned ones.

> **Summary**
> - Longer exposure = more light and better SNR (∝ √*t* when shot-noise-limited), but more motion blur, shake and clipping risk.
> - Rule to remember: blur length (pixels) = image-plane speed × exposure time.
> - A burst of *k* short frames matches one long exposure's shot noise but pays read noise *k* times.
> - Next: the same exposure trade-offs for a sensor that supplies its own light (§5, LiDAR).

---

## 5. Exposure in LiDAR and Time-of-Flight Depth Sensing

**[LiDAR](https://en.wikipedia.org/wiki/Lidar)** ("light detection and ranging") and **[time-of-flight (ToF) cameras](https://en.wikipedia.org/wiki/Time-of-flight_camera)** measure *distance* instead of (or alongside) brightness. They send out their own light, typically an infrared laser, and time how long it takes to bounce back. "Exposure" is just as central to them, with one big twist.

**Passive vs. active sensing.** An ordinary camera is **passive**: it only collects light already in the scene. A LiDAR is **active**: it supplies its own **active illumination**. The photons it wants are its own laser's echo; every other photon is unwanted background.

**Analogy.** A passive camera is the rain bucket of §2.1. A LiDAR is trying to catch one specific squirt from its own garden hose *while it is also raining*. Every extra moment the bucket stays open adds rain (ambient light) without adding any more squirt. The rain's randomness (shot noise, Week 2 §18, ∝ √(ambient photons)) buries the squirt.

### 5.1 The time–distance link

Light travels at *c* ≈ 3 × 10⁸ m/s, i.e. **0.30 m per nanosecond** (ns, 10⁻⁹ s). A pulse sent to an object at distance *d* and back travels 2*d*, so

```
round-trip time  τ = 2d / c          ⇔          d = c·τ / 2
```

- ***d*** — distance to the object, meters. The unknown; fixed by the scene.
- ***τ*** — round-trip time, seconds. What the sensor actually times.
- ***c*** — speed of light, a physical constant.
- The **factor 2** is there because light goes out *and* back. Forgetting it doubles every distance.

Each nanosecond of round-trip time is 0.30/2 ≈ **0.15 m** of distance. An object 100 m away echoes back after 2 × 100 / (3 × 10⁸) ≈ 667 ns. This all happens on a nanosecond scale, a *million* times shorter than photographic exposure times.

### 5.2 Range gating: an ultra-short exposure

A **pulsed (direct) time-of-flight** LiDAR fires a short laser pulse. With **range gating**, it then "opens the bucket" only in a narrow time window, or **gate**, when an echo from the distances of interest could be arriving. Opening the detector for a window *is* an exposure, just nanoseconds long and timed relative to the pulse. Numbers:

- A gate covering a 1 m slice of depth lasts 2 × 1 m / *c* ≈ **6.67 ns**.
- An ordinary short photographic exposure of 1/100 s is 10 ms.
- Ambient light arrives continuously, so the gate collects about 6.67 ns / 10 ms ≈ **1/1.5 million** as many background photons as that photo exposure.
- The echo from inside the slice arrives *entirely within* the gate, so none of the signal is lost.

That is the §4 trade-off pushed to the extreme: shortening the exposure costs nothing if your signal is guaranteed to land inside it. Choose it short enough and you reject almost all background, a key reason pulsed LiDAR works outdoors in sunlight.

### 5.3 Accumulating many pulses: exposure as pulse count

One pulse returns only a few photons from a distant or dark object. Many single-photon LiDARs (using **[single-photon avalanche diodes](https://en.wikipedia.org/wiki/Single-photon_avalanche_diode)**, SPADs: detectors sensitive enough to register individual photons) therefore repeat the measurement over many pulses and build a **histogram** of photon arrival times, whose peak marks *τ*. The "exposure" is now the total acquisition time, or number of pulses.

The same √*t* rule of §4.4 applies: 4× as many pulses halves the relative noise of the histogram. The same motion trade-off applies too: anything that moves during acquisition smears its histogram peak, the depth equivalent of motion blur.

### 5.4 Continuous-wave (indirect) ToF: an "integration time" knob

Many depth cameras (phones, game controllers) do not time individual pulses. They light the scene with brightness modulated as a wave, and infer distance from the **phase shift** of the returning wave. Each pixel integrates the returning light over an **integration time**, these cameras' name for exposure time. It shows the §4 trade-offs, now in depth rather than brightness:

- **Too short:** too few photons, so noisy depth values.
- **Too long:** moving objects produce depth errors at their edges (the depth analogue of motion blur).
- **Saturation (§2.4):** near or highly reflective objects saturate pixels and ruin their depth estimate. Such cameras often combine readings from two or more integration times, a depth counterpart of the exposure bracketing built later in this file (§8).

**Takeaway.** Whether the output is brightness or distance, "exposure" is the same decision: how long to collect before reading out. More time buys lower relative noise (∝ √*t*), and costs motion blur, saturation risk and, when your own light source is the signal, extra ambient background.

> **Summary**
> - A LiDAR is an active sensor: its own laser echo is the signal, ambient light is noise.
> - Rule to remember: **τ = 2d/c**, so 1 ns of round-trip time = 0.15 m of range.
> - Range gating is an exposure of a few nanoseconds that rejects ~10⁶× the background; many pulses accumulate into a histogram whose SNR grows ∝ √(pulse count).
> - Next: how a camera decides how bright a scene is, so it can pick an exposure (§6).

---

## 6. Light Metering

Before choosing an exposure, a camera has to answer: *how bright is this scene, overall?* That measurement is **[light metering](https://en.wikipedia.org/wiki/Light_meter)**.

**Where the measurement comes from.** SLR cameras (Week 2's mirror-based design) use a separate low-resolution sensor at the focusing screen. Mirrorless cameras (no mirror) meter directly off the main sensor's live feed.

**The 18% "key" assumption.**

- The metering sensor's readings are averaged to one overall brightness number.
- The camera *assumes* that number corresponds to **18% reflectance**, the "mid gray" of Week 3 §10's gamma example (a surface reflecting 18% of incident light, linear value 0.18 on [0, 1]).
- The 18% figure is the conventional round number. Real meters are calibrated through exposure-equation constants that work out to roughly 12–18% depending on the standard.
- This assumed average brightness is the **key**.
- The camera then sets exposure (aperture, shutter, ISO; §2) so the key lands at the **middle** of the sensor's dynamic range, the "correct exposure sits between the two failure modes" logic of §2.4, applied to one summary number.

**Averaging is not one fixed procedure.** A backlit portrait and a snow landscape need different weightings, so cameras offer several strategies:

| Method | What it averages over |
|---|---|
| **Center-weighted** | The whole frame, favoring the center (where the subject usually sits) |
| **Spot** | A single small region (e.g. the subject's face), ignoring the rest |
| **Scene-specific preset** | A fixed weighting tuned for a named scenario (portrait, landscape, horizon) |
| **"Intelligent"** | A proprietary manufacturer algorithm (often scene recognition) |

**Worked example: why metering can be "fooled."** The 18%-key assumption is why a camera pointed at snow or a white wall tends to render it dull gray: snow reflects far more than 18%, but the meter still drags the average down to 18% gray, underexposing everything. Conversely, a mostly-black scene (a coal pile, a night stage) gets pushed *brighter* than it should look. Both are the same "assumed 18% average" rule applied to a scene that violates it.

> **Summary**
> - A meter averages the scene to one number and assumes it is 18% gray (the "key").
> - Rule to remember: the camera places the key mid-range, so very bright or very dark scenes get mis-exposed.
> - Metering gives the "correct" exposure time that bracketing is centered on (§8.2).
> - Next: how far the real world's brightness range exceeds what sensors and displays can handle (§7).

---

## 7. The Dynamic-Range Mismatch: World → Eye → Sensor → Image → Display

Week 1 §15 introduced **[dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)**, the ratio between the brightest and darkest signal a system can represent, for the eye alone (~14 orders of magnitude across all adaptation states, ~5 instantaneously). This section lays *every* stage of the imaging pipeline on the same scale to see where range is lost at each handoff.

**The eye vs. the world.** The lecture's illustrative scale runs from 10⁻⁶ to 10⁶ (roughly candela per m²; 12 orders of magnitude) and places the eye's full adaptation range and the band of "common real-world scenes" on it. Common scenes occupy a narrower slice roughly in the middle, which the eye's adaptation range comfortably brackets.

**Worked example: one real HDR photograph's measured range.** The lecture shows a bracketed sequence of a room with a window, with each frame's measured relative brightness printed beneath: **1** (a dim interior patch) → **1,500** → **25,000** → **400,000** → **2,000,000,000** (a bright light source seen through the window). That is roughly **9–10 orders of magnitude inside one ordinary scene**, nearly as much as the eye's whole adaptation window.

**Sensor: narrower still.** A sensor's achievable range occupies about the same band as common real-world scenes, not the eye's full range. It is capped by the smaller of its noise floor (Week 2 §18) and its bit-depth quantization step (Week 2 §20).

**Image: narrower again, and it slides.** Commit to *one* exposure setting (§2) and the image keeps only the slice of the sensor's range that setting lands on:

- A "high exposure" slides the slice toward the bright end (crisp shadows, blown highlights).
- A "low exposure" slides it toward the dark end (crisp highlights, noisy or crushed shadows).
- Everything outside the slice is clipped to white (§2.4) or buried in noise.

**Display: narrower again, surprisingly so.** On a standard 8-bit-per-channel (0–255) display, displayed pure white is only about **50×** brighter than displayed pure black, not the 256× the bit count suggests. (Independent sources put the typical black-to-white ratio of a *picture* at about 1:20 to 1:50, and 1:500 at most. The 1,000:1 LCD figure in the table below is a panel's rated contrast, not what an ordinary picture on it delivers.) This is Week 2 §20's point made concrete: bit depth (a *digital* count of code values) and achievable dynamic range (a *physical* ratio capped by backlight leakage and ambient reflections) are different things.

**Real device ratios on one scale** (the lecture's comparison; contrast ratio, brightest:darkest):

| Device / medium | Contrast ratio |
|---|---|
| Photographic print (higher for glossy paper) | 10:1 |
| Artist's paints | 20:1 |
| Slide film | 200:1 |
| Negative film | 500:1 |
| LCD display | 1,000:1 |
| Digital SLR (at 12 bits) | 2,000:1 |
| **Real world** | **100,000:1** |

**The two challenges, with numbers attached.** A sensor has 8–14 bits to decide which slice of that 100,000:1 range to *measure* (widening that slice with several exposures is **HDR imaging**). A display has 4–10 bits to decide which slice of the measured data to *show* (that decision is **tonemapping**). Two different jobs, even though a consumer "HDR photo" workflow usually does both back to back (§16).

> **Summary**
> - The real world spans ~100,000:1 (and up to 9–10 orders of magnitude inside one scene); a sensor, one exposure and a display each keep a narrower slice.
> - Rule to remember: bit depth is a count of codes; dynamic range is a physical brightest-to-darkest ratio, and the display's is far smaller than 256:1.
> - HDR imaging fixes the *measuring* problem; tonemapping fixes the *display* problem.
> - Next: HDR step 1, capturing a bracket of exposures (§8).

---
## 8. HDR Imaging, Step 1: Exposure Bracketing

The lecture's basic HDR recipe has two steps:

1. Capture several ordinary **low-dynamic-range (LDR)** exposures of the same static scene at different exposure settings: **exposure bracketing** (this section).
2. **Merge** them into one image that keeps what each exposure captured well (§10). Merging needs the pixel values to be proportional to light, so §9 first shows how to make them so.

### 8.1 Four ways to vary exposure, and their trade-offs

Each knob was built earlier; the table compares them side by side for *how well each serves bracketing*:

| Knob | Range | Pros | Cons |
|---|---|---|---|
| **Shutter speed** (§2.1–§2.3) | ~30 s to 1/4000 s (about 5 orders of magnitude: 30 ÷ (1/4000) = 120,000) | Repeatable, linear (§2.2's reciprocity) | Noise and motion blur at long exposure times |
| **F-stop** (aperture, Week 2 §8) | ~f/0.98 to f/22 (about 3 orders of magnitude of light: (22/0.98)² ≈ 500) | Fully optical, no added electronic noise | Changes depth of field (Week 2 §10) |
| **ISO** (§2.5) | ~100 to 1600 (about 1.2 orders of magnitude: a factor of 16) | Nothing physically changes between shots, so no motion | Adds noise (amplifies what was already collected) |
| **[Neutral density (ND) filter](https://en.wikipedia.org/wiki/Neutral-density_filter)** | Up to 6 densities (6 orders of magnitude) | Works even with strobe/flash lighting | Not perfectly color-neutral; extra glass adds interreflections/aberrations (Week 2 §6) |

**What an ND filter is.** A piece of darkened glass or film in front of the lens that attenuates *all* wavelengths about equally. It cuts the total light without changing color, so you can use a wider aperture or longer shutter than the scene's brightness would otherwise allow. Its strength is its **[optical density](https://en.wikipedia.org/wiki/Optical_density)**, OD = log₁₀(1/transmittance), a base-10 logarithm. That is why "up to 6 densities" matches "6 orders of magnitude": OD 6 means transmittance 10⁻⁶, one-millionth of the light.

**Why shutter speed is the default.** For a bracket to merge cleanly, frames should differ *only* in overall brightness.

- Changing the f-stop also changes depth of field, so frames would be sharp in different places, and the merge cannot account for that.
- ISO's range is small (~1.2 orders) and its cost is exactly the noise HDR tries to reduce.
- ND filters matter mainly when shutter time is constrained (e.g. a fixed-duration flash pop).
- Shutter speed is repeatable, linear, continuous and wide-ranging (~5 orders), so the lecture's own bracket varies shutter time alone.

### 8.2 How many exposures, and which ones

> **Worked example: the standard 5-exposure bracket.** Shutter times follow a power-of-2 sequence, one stop apart (§2.3). Given a metered "correct" time *t₀* (§6), the lecture's default is **5 exposures: the metered one and ±2 stops around it**. Each stop is a factor 2 in light, so the bracket is
> ```
> t₀/4,   t₀/2,   t₀,   2t₀,   4t₀
> ```
> five frames spanning a **16× (4-stop) range** of collected light, symmetric about the meter's guess. The number of exposures actually needed depends on how wide the scene's range is (§7); 5 is a general-purpose default, not a constant.

> **Summary**
> - Bracketing = several LDR exposures of a static scene at different settings.
> - Rule to remember: vary **shutter time** alone, one stop apart; the default is the metered time ±2 stops (5 frames, 16× span).
> - Aperture changes depth of field, ISO adds noise, ND filters are for flash/fixed-time cases.
> - Next: why recorded pixel values are not proportional to light, and how to fix that (§9), before merging (§10).

---

## 9. Radiometric Calibration

### 9.1 What "calibration" means, what is being calibrated, and why

**Calibration in general.** A **measuring instrument** reports a number about the world, and is only trustworthy if you know how that number relates to the truth. **Calibration** means measuring things whose true values you already know, recording what the instrument reports, and thereby learning the mapping *reading → truth*. Two everyday cases:

- **Kitchen scale.** Place 100 g, 200 g and 500 g reference weights on it. If it shows 104, 208 and 520, it reads 4% high everywhere; divide its display by 1.04 from then on.
- **Thermometer in ice water.** Ice water is 0 °C. If it says 2 °C, you have learned its offset and subtract it later.

**Calibration target.** The "thing whose true values are known" is a **calibration target** (or reference): any object, scene or setup with a known true physical value. The reference weights and the ice bath are targets. No target, nothing to compare against.

**What is being calibrated here.** A camera is a *light-measuring instrument*. For each pixel it reports one number (the **pixel value**, e.g. 0–255), and the true quantity it tries to report is how much light reached that pixel: scene flux × exposure time (§9.2's *t_i*·Φ; §2.2's exposure *H*). **Radiometric** means "to do with measured light power." So **radiometric calibration** finds the mapping between true light amount and recorded pixel value. That mapping is the **response curve** *f* of §9.2 (also called the **camera response function**, CRF): true light on the horizontal axis, pixel value on the vertical, and *f* is the curve you get. (This is the camera-response sense of the term, not the satellite-sensor or ionizing-radiation sense.)

**Why the curve is not a straight line.** If pixel value were proportional to light, there would be nothing to calibrate. Three things bend it:

- **Saturation (clipping) at the top.** A pixel holds only so much charge (full-well capacity, §2.4); past that, the curve goes flat.
- **The noise floor at the bottom.** Very dim light is swamped by random noise (§3), so the lowest values say little about the true light.
- **The in-camera tone curve in between.** A **tone curve** is a function from input brightness to output brightness (a straight diagonal changes nothing; a curve bowing upward brightens dark tones more than bright ones). To make a JPEG that looks right on a screen and spends its 8 bits efficiently, the camera applies a non-linear tone curve, usually gamma-like (Week 3 §10) and sometimes S-shaped. This is the main bend, and *f* is essentially this curve plus the clipping. (It is a different thing from HDR *tonemapping*, applied later by you.)

**Why calibrate: linearizing.** Once *f* is known, its inverse *f*⁻¹ turns pixel values back into numbers proportional to light ("**linearizing**"). Everything that assumes "doubling the light doubles the number" needs this:

- **HDR merging (§10)** divides each pixel by its exposure time and averages; that is right only if pixel value ∝ *E*·*t*.
- **Noise and SNR reasoning (§3, §4)** treats pixel values as counts of collected light.
- **Physically meaningful measurements**: brightness ratios between scene points, a light's strength, light probes (HDR measurements of real illumination).
- **LiDAR and other active sensors** have the same issue: returned intensity tracks surface reflectivity only after calibration against known-reflectance reference panels (a gray target of known reflectivity at known range).

**Worked numeric illustration (invented numbers, not from any assignment).**

- Suppose a camera secretly applies *f*(*x*) = 255·*x*^(1/2.2) to the linear value *x* in [0, 1] (the γ ≈ 1/2.2 model of §9.4), and we do not know that.
- We photograph a printed **grayscale step chart** (patches of known reflectance, the fraction of incident light each bounces back) under uniform light. Patches of reflectance 100%, 50%, 25%, 12.5% give true linear signals in the ratio 1 : 0.5 : 0.25 : 0.125. Say the brightest gives linear value 0.8:

| Patch reflectance | True linear value *x* (known from chart) | Recorded pixel value (measured) | Pixel value if camera were linear (255·*x*) |
|---|---|---|---|
| 100% | 0.8 | 230 | 204 |
| 50% | 0.4 | 168 | 102 |
| 25% | 0.2 | 123 | 51 |
| 12.5% | 0.1 | 90 | 26 |

- Each time the true light halves, the pixel value drops by only about a quarter (230 → 168 → 123 → 90), not by half. That mismatch **is** the calibration finding: the table of (pixel value, true value) pairs is a sampled picture of *f*.
- To linearize a new pixel, look up and interpolate: 123 means linear 0.2. A pixel of 150 lies between 123 (0.2) and 168 (0.4), so 0.2 + (150 − 123)/(168 − 123) × 0.2 = 0.32. That is already close to the exact ≈ 0.31 for this made-up *f*; more patches shrink the error.
- Which numbers *your* HW3 images produce is for the assignment to determine; the point is the procedure.

*Linear-algebra note.* This is **not** a matrix operation: *f* acts on each pixel value on its own (a point-wise non-linearity, §9.5), so no change of basis is involved.

### 9.2 The non-linear image formation model

```
I_linear(x, y)     = clip[ tᵢ · Φ(x, y) + noise ]
I_nonlinear(x, y)  = f[ I_linear(x, y) ]
```

**Term by term.**

- Φ(*x*,*y*): real scene flux hitting pixel (*x*,*y*); fixed by scene and lighting (§2.2's *E*, restated per pixel).
- *tᵢ*: exposure *i*'s exposure time; you control it (§8).
- *I_linear*: what the sensor *would* record with no further distortion, after clipping at saturation (§2.4).
- *f*[·]: the camera's tone reproduction curve, fixed, generally unknown, monotonic and non-linear, baked in by the camera.
- *I_nonlinear*: what is actually written to the output file.

**Linearization.** Only *I_nonlinear* is available, so recovering the true linear signal needs the *inverse* curve:

```
I_est(x, y) = f⁻¹[ I_nonlinear(x, y) ]
```

**Recipe for non-linear stacks:** (1) calibrate *f* (next subsections); (2) linearize every frame via *f*⁻¹; (3) merge the linearized values (§10). The merge math does not change; only its inputs are pre-processed.

### 9.3 Three ways to calibrate the response curve

Every calibration needs "known truth" (§9.1). The three methods differ only in **where the truth comes from**. Only *relative* brightness must be known (a patch is exactly half as bright as another), not absolute units (a separate issue).

| Method | Where the known truth comes from | What's varied | What's held fixed | A good target |
|---|---|---|---|---|
| **Vary flux only** | The target's printed reflectances: under uniform light, a patch returns light proportional to its reflectance | Scene brightness (patches of known reflectance) | Camera exposure setting | A **[ColorChecker](https://en.wikipedia.org/wiki/ColorChecker)** chart: its bottom row is six neutral gray patches with known reflectances from about 90% to about 3% (optical density 0.05 to 1.50, steps growing from about 0.18 to about 0.45, so log-reflectance is monotonic but not evenly spaced), a ladder of known relative flux at one fixed exposure |
| **Vary exposure only** | The shutter: collected light ∝ exposure time, so doubling *t* doubles the light by construction | Exposure time (known) | Scene brightness (one uniformly-reflective target) | A **white-balance card**: every point of its white area has the same reflectance, isolating how the response depends on *t* |
| **Vary both** | The *consistency* of the stack: the same scene point is photographed at several known exposure times, so its true light is unknown but is the *same* quantity in every frame | Scene flux *and* exposure | — | The bracketed LDR stack itself (§8); its internal consistency is enough to solve for *f* |

**Method 1 in §9.1's numbers.** The chart's known ratios 1 : 0.5 : 0.25 : 0.125 are the truth; the recorded 230, 168, 123, 90 are the readings; the table of pairs is the curve.

**Method 2 in §9.1's numbers.** Photograph one white card whose linear signal at *t* = 1/100 s is 0.1. Then *t* = 1/100, 1/50, 1/25, 1/12.5 s collect 0.1, 0.2, 0.4, 0.8 by construction, and the same readings 90, 123, 168, 230 appear. The truth is a ratio of exposure times that the camera's clock guarantees; no printed chart is needed. (Keep exposures short enough that the brightest does not saturate; a clipped reading is not on the curve.)

**Method 3 in §9.1's numbers.** A single scene point records 90, 123 and 168 at *t*, 2*t* and 4*t*. Its true light is unknown, but frame 2 received exactly twice frame 1's, and frame 3 twice frame 2's. So the pairs (90 → 123) and (123 → 168) both mean "light doubled." Many such pairs from many pixels pin down *f* up to one overall scale factor (the same overall-scale ambiguity that remains in any merged HDR image). §11 turns this idea into a least-squares solve.

**Which to pick.** Methods 1 and 2 give the most direct, trustworthy curve but need a target and controlled shooting. Method 3 needs nothing extra but gives the curve only up to scale and needs a static scene and camera. The assignment's PNGs have a known curve (§9.5), so the main HW3 task needs none of the three; the bonus (§11) is where method 3 appears.

*(Artifact figure: the response curve, with the dashed ideal-linear line, the saturation plateau, the noise floor, and the inversion of a measured pixel value back to light amount.)*

### 9.4 When you can't calibrate: EXIF and the γ ≈ 1/2.2 default

If no calibration is possible, two fallbacks:

- **EXIF metadata.** An image file typically stores **[Exif](https://en.wikipedia.org/wiki/Exif)** metadata (Week 3 §9), often including the tone curve and color space used, which can be read directly instead of estimated.
- **The default gamma model.** Otherwise, *f* is well approximated by a power law *f*(*x*) ≈ *x*^γ with **γ = 1/2.2**, the same γ ≈ 2.2 perceptual constant Week 3 §10 built for deliberately *encoding* a linear sensor reading into 8 bits.
  - The role differs: Week 3 §10 was a chosen encoding step; here *f* is whatever curve the camera silently *already* applied, and γ ≈ 1/2.2 is the best generic guess so it can be undone (raise to ≈ 2.2) before merging.
  - The lecture's rule of thumb, "if nothing else, take the square of your image," is this one step cruder: since 1/(1/2.2) = 2.2 ≈ 2, squaring roughly approximates *f*⁻¹ and removes most of the tone curve.

### 9.5 Linearizing an sRGB image precisely (supports HW3 Task 1)

*(Beyond the lecture's slides: if HW3's PNGs are stored in **sRGB**, the standard display color space whose tone curve Week 3 §10 introduced, an inverse gamma must be applied before merging. PS3's slide says "Linearize the images using gamma of 2.2.")*

Here *f*⁻¹ is not unknown: the file format fixes it. For each color channel of each PNG:

1. Convert the stored 8-bit integer to a float in [0, 1] by dividing by the maximum 8-bit code (255). The merge weights used later assume this [0, 1] scale.
2. Apply the **sRGB decoding curve**: *C*_lin = *C*/12.92 if *C* ≤ 0.04045, otherwise ((*C* + 0.055)/1.055)^2.4. Here *C* is the stored value in [0, 1] and *C*_lin the linear value. The short straight segment avoids an infinite slope at black; the rest is a power law whose exponent 2.4, with its offsets, behaves like the plain γ ≈ 2.2 of §9.4.
3. The simpler *C*_lin = *C*^2.2 (what the assignment's "inverse gamma curve" wording and PS3's "gamma of 2.2" point to) differs from step 2 only in the darkest tones, and merging is forgiving of it. Either is defensible if you state which you used.

Nothing here is a linear-algebra operation: the curve acts independently on each scalar, a **point-wise non-linearity**. (Contrast Week 3's color-space *change of basis*, which mixes channels by a matrix.)

> **Summary**
> - A camera is a light-measuring instrument; **calibration** compares its readings with known truth to learn the response curve *f* (pixel value vs. true light).
> - Rule to remember: **linearize** with *f*⁻¹ before doing any arithmetic that assumes "double the light, double the number"; default fallback is γ ≈ 1/2.2 (or the exact sRGB decoding curve for sRGB files).
> - Three ways to get the truth: known reflectances, known exposure times, or the stack's own consistency.
> - Next: merge the linearized bracket into one HDR image (§10).

---

## 10. HDR Imaging, Step 2: Merging — Confidence Weights and Log-Domain Least Squares

### 10.1 Why simple averaging doesn't work

Given a linearized bracket, the naive idea is to average every frame's value at each pixel. That is wrong because **not every frame's value is equally trustworthy**:

- A badly underexposed pixel is dominated by noise (§2.4).
- A saturated pixel carries no information about the true brightness (§2.4).

A good merge weights each frame's contribution at each pixel by how *confident* that measurement is.

### 10.2 The confidence weight function

**What problem it solves.** Each exposure is a noisy, possibly clipped opinion about the same scene point; the merge needs a number saying how much to believe each opinion.

- **In:** one pixel's value from one exposure (in [0, 1]).
- **Out:** a confidence weight in (0, 1]: 1 = "trust fully", near 0 = "nearly ignore."
- **Analogy:** witnesses to one event. One who squinted into the sun (saturated) or stood in the dark (near the noise floor) gets little credit; one who saw it in good light gets full credit; the verdict is the credit-weighted average.

**Intuition.** A value in the middle of a frame's range is the most trustworthy: far from the noise floor and from saturation. Values near either extreme are the least. So the weight should peak at mid-range and fall off toward both ends. The lecture's choice is a **Gaussian bump centered at mid-gray**:

```
w(I) = exp( −4·(I − 0.5)² / 0.5² )
```

**Term by term.**

- *I*: one pixel's linear value from one exposure, on [0, 1] (or the equivalent on another scale, e.g. 127.5 is mid-range on [0, 255]).
- *w(I)*: the confidence weight, in (0, 1].
- 0.5: the mid-range value where the weight peaks ("correctly exposed, confident," §2.4).
- −4/0.5²: sets the fall-off. In standard Gaussian form exp(−(I−0.5)²/(2σ²)) this is σ² = 0.5²/8, σ ≈ 0.177, so the weight has dropped to about a fifth of peak (≈ 0.19) at *I* = 0.18 or 0.82.

> **Worked numeric check.** At *I* = 0.5: *w* = exp(0) = **1**, full confidence. At *I* = 0 or 1 (fully clipped): *w* = exp(−4) ≈ **0.0183**, under 2% of peak, correctly signalling "barely trust this."

The weight is computed **per color channel, per pixel, per exposure**: each of the *N* frames contributes its own weight at every pixel, from its own recorded value there.

### 10.3 The log-domain weighted least-squares objective

**What problem it solves.** After bracketing, one scene point has *N* recorded values (one per exposure time) that disagree because of noise, clipping and different exposure times. The merge must collapse them into one best estimate of the true brightness.

- **In:** the *N* linearized values, the *N* exposure times, the *N* weights of §10.2.
- **Out:** one HDR value *X̂* for that pixel.
- **Analogy:** *N* people measure the same table with rulers in different units. Convert each reading to common units (dividing out the exposure time, which is what taking logs and subtracting log *t_i* does), then average, listening more to people with better rulers.

**Setup, for one pixel location.** *i* = 1, ..., *N* indexes the bracketed exposures. *I_lin,i* is the linearized value in exposure *i* (§9); *t_i* its exposure time; *w_i* = *w*(*I_lin,i*) its weight. *X* is the single unknown: the scene's true underlying exposure/radiance at that pixel, the *same* for every *i* since it belongs to the scene, not to any frame.

**Intuition.**

1. Because *H* = *E*·*t* (§2.2, with *E* ∝ *X*), every well-behaved exposure satisfies *I_lin,i* ≈ *t_i*·*X*, up to noise.
2. Taking logs turns this multiplicative relation into an additive one: log *I_lin,i* ≈ log *t_i* + log *X*.
3. Recovering log *X* from *N* independent, differently-weighted noisy estimates is exactly a **weighted least-squares fit of a single constant**:

```
minimize    O(X) = Σᵢ wᵢ · ( log(I_lin,i) − log(tᵢ·X) )²
    X
```

**Solving it.** Set the derivative with respect to log *X* to zero:

```
∂O/∂(log X) = −2 Σᵢ wᵢ · ( log(I_lin,i) − log(tᵢ) − log(X) ) = 0
```

which gives the closed form the lecture states:

```
X̂ = exp( [ Σᵢ wᵢ·(log(I_lin,i) − log(tᵢ)) ] / [ Σᵢ wᵢ ] )
```

**Term by term.**

- *X̂*: the merged HDR value at this pixel, in relative units (§12.1 covers absolute scale).
- Numerator Σᵢ wᵢ·(log I_lin,i − log tᵢ): a confidence-weighted sum of each exposure's own "back out the exposure time" estimate of log *X*.
- Dividing by Σᵢ wᵢ makes it a proper weighted *average*.
- The outer exp() undoes the log.
- No diagram is needed: like Week 3 §1's spectral-sensitivity integral, this relates numbers computed *per pixel*, not a shape in space.

**Linear-algebra view (the simplest possible weighted least-squares problem).**

- Treat *yᵢ* = log(*I_lin,i*) − log(*tᵢ*) as *N* noisy observations of one unknown constant *μ* = log *X*.
- Minimizing Σᵢ *wᵢ*(*yᵢ* − *μ*)² is ordinary weighted linear regression whose "design matrix" is a column of *N* ones (the model has no other free parameter).
- The weighted normal equations **Aᵀ W A** *μ* = **Aᵀ W y** then collapse, for this all-ones **A**, to exactly the weighted-average formula above.
- Every pixel runs this identical 1-parameter regression independently; nothing here is more exotic than fitting a mean.

### 10.4 Debevec's triangle weight, and displaying the weights (supports HW3 Task 1.1)

*(Beyond the lecture's slides, which print §10.2's Gaussian bump.)*

**What problem it solves:** the same as §10.2 (how much to trust one value from one exposure), with a cheaper shape. **In:** a pixel value *z* in [0, 1]; **out:** a weight in [0, 0.5]. **Analogy:** a tent whose peak is mid-gray and whose edges touch the ground at pure black and pure white; the credit is the tent's height. The original Debevec–Malik weight is a **triangle (hat) function**:

```
w(z) = z        if z ≤ 0.5
w(z) = 1 − z    if z > 0.5        (equivalently  w(z) = min(z, 1 − z))
```

**Intuition and terms.** Same trust rule as §10.2 (peak at mid-gray, fall to the extremes) with straight lines instead of a bell. *z* is one pixel's value in one exposure on [0, 1], fixed by the data. The peak is *w* = 0.5 at *z* = 0.5, and the weight is exactly 0 at *z* = 0 and 1, so completely black or clipped values get **zero** trust (§10.2's Gaussian only gets near zero, ≈ 0.018). Both shapes are valid instances of §10.1's idea, and §10.3's merge takes either unchanged. PS3's Task 1 slides print §10.2's Gaussian form (evaluated on the linearized image), so that is the problem session's weight; the triangle is the original method's version.

**Which values go in?** §10.2 evaluates the weight on the *linear* value; the original method evaluates it on the *stored* (non-linear) value. Pick one, apply it consistently across all 16 exposures, and say which in your write-up.

**Weight images.** To "show the weights" of an exposure, evaluate *w* at every pixel and display the array as a grayscale image (bright = trusted, dark = ignored), one per exposure (and per color channel if the weights are per channel). What to expect:

- In the shortest exposure, weights are high on bright scene parts (they land mid-range) and low on dark parts (near the noise floor).
- In the longest exposure it is the reverse.
- So every scene point should be trusted by at least a few exposures. If a region is dark in *every* weight image, the stack has no trustworthy measurement there (see §10.5).

### 10.5 Two numerical pitfalls when implementing the merge (supports HW3 Task 1.2)

- **log(0).** The merge takes ln of the linearized values, but fully black pixels are exactly 0 and ln 0 = −∞. One −∞ poisons the weighted sum, and with a triangle weight of exactly 0 at *z* = 0 you get 0 × (−∞) = **NaN** ("not a number"), which spreads through every later step. The fix: add a tiny constant before the log, ln(*value* + ε). The assignment prescribes ε = machine epsilon of 32-bit floats, `np.finfo(np.float32).eps` (about 1.2 × 10⁻⁷). It is far smaller than the smallest nonzero 8-bit value, so it changes real data negligibly while keeping the log finite; computing it from `np.finfo` follows this project's rule that constants be derived, not typed.
- **All weights zero.** Where every exposure has *w* = 0 at some pixel (e.g. black in all 16 frames), the denominator Σᵢ *wᵢ* of §10.3 is 0 and the division is 0/0. Guard against it (e.g. clamp the denominator to a small positive floor), or the HDR image gets NaN holes.

**Pipeline order, end to end:** load each PNG → divide by 255 (§9.5) → linearize (§9.5) → compute weights (§10.2 or §10.4) → ln(value + ε) − ln(*t_i*) per exposure → weighted average over exposures (§10.3) → exp → normalize to [0, 1] → tonemap (§14, introduced below).

> **Summary**
> - Averaging fails because frames differ in trustworthiness; a **confidence weight** peaks at mid-gray and falls to ≈0 at black and white.
> - Rule to remember: **X̂ = exp( Σ wᵢ(ln Iᵢ − ln tᵢ) / Σ wᵢ )**, a weighted average of per-frame log-radiance estimates (a 1-parameter weighted least-squares fit).
> - Guard ln(0) with a tiny ε and all-zero weights with a denominator floor.
> - Next: estimating the response curve algorithmically (§11), then practical HDR details (§12) and displaying the result (§13–§15).

---

## 11. Estimating the Response Curve Algorithmically: the "CRF" (supports the HW3 bonus)

*(Beyond the lecture's slides, which only list the calibration setups of §9.3.)* The **camera response function (CRF)** is the usual name for the curve *f* of §9.2 (or its inverse, depending on the author's convention); this is what OpenCV's calibrate functions estimate. It uses §9.3's "vary both" idea, §10.2's weights and linear least squares.

**What the OpenCV calibrate object solves (conceptual).**

- **Input:** a stack of photographs of one static scene, plus each exposure time. No calibration target.
- **Output:** the curve, as a 256-entry table (one per 8-bit pixel value) saying how much light each value stands for.
- **Analogy:** you weigh the same unknown objects on a scale you can load with 1, 2 or 4 identical extra weights. Since you know what you added, the readings reveal how the dial behaves even though you never knew the objects' masses.
- The merge object then takes the stack, exposure times and curve and outputs the HDR image. The two objects are the two stages of §9.2's recipe: calibrate *f*, then linearize and merge (§10).

**Idea.** For pixel location *j* with true flux *E_j*, photographed at known time *t_i*, the model says *f*⁻¹(recorded value *Z_ij*) = *E_j* · *t_i*. Taking logs, *g*(*Z_ij*) = ln *E_j* + ln *t_i*, where *g* = ln *f*⁻¹ is an *unknown function on the 256 possible 8-bit values*.

- Unknowns: the 256 values of *g* plus one ln *E_j* per sampled pixel.
- Equations: one per (pixel, exposure) pair.

**Linear-algebra view.**

- Stacking the equations gives one big overdetermined linear system **A** *u* = **b**: *u* holds the 256 *g* values and the ln *E_j* values; each row of **A** has just two nonzero entries (one selecting *g*(*Z_ij*), one selecting ln *E_j*); **b** holds the known ln *t_i*.
- It is solved by **linear least squares**, weighted by §10.2's confidence weights, with an extra row-block penalizing the second difference of *g* so the curve is smooth.
- One extra row pins *g* at mid-gray to 0, because the system only determines *g* up to an additive constant (the null space of **A** contains "add the same constant to every *g* and subtract it from every ln *E*").

**In practice (bonus only).** OpenCV packages this as a calibrate-then-merge pair: a Debevec calibrate object (`cv2.createCalibrateDebevec`) estimates the curve from the stack and times; a Debevec merge object (`cv2.createMergeDebevec`) applies it and fuses the stack into an HDR image, as in the OpenCV HDR tutorial the assignment links. The main HW3 task skips this, since the PNGs' curve is known (§9.5).

> **Summary**
> - With no target, the bracket's own consistency (same scene, known exposure times) determines the response curve.
> - Rule to remember: *g*(*Z_ij*) = ln *E_j* + ln *t_i*, an overdetermined linear least-squares system with two nonzero entries per row, determined up to an additive constant.
> - OpenCV does it with a calibrate object, then a merge object.
> - Next: practical aspects of HDR (scale, alignment, formats, light probes) in §12.

---

## 12. Other Aspects of HDR Imaging

### 12.1 Relative vs. absolute flux

The merge of §10 recovers *X̂* only up to one unknown global scale factor. Every pixel's brightness relative to every other is right, but nothing in the stack says what physical flux "1.0" corresponds to. If the *absolute* flux at even one scene point is known (e.g. from a handheld **spotmeter**, which measures absolute flux at one point), that one measurement fixes the scale and turns the relative HDR image into an absolute flux map.

### 12.2 Alignment sensitivity

The two-step recipe (§8, §10) assumes a **static scene and static camera**: every pixel location across the stack must be the same physical scene point. Any movement (a breeze-blown branch, hand-held micro-shake) misaligns the stack and corrupts the merge, since §10's per-pixel average silently assumes all *N* samples measure the *same* quantity. Modern automatic HDR pipelines therefore align the frames first.

### 12.3 HDR file formats

An HDR image's pixel values are floating point: the merged *X̂* values can span many orders of magnitude and would clip or round in a fixed integer range. Three specialized formats:

| Format | Layout (per pixel) | Note |
|---|---|---|
| **[Portable float map (.pfm)](https://en.wikipedia.org/wiki/Netpbm#File_formats)** | Ordinary IEEE floating point: sign, exponent, mantissa, per channel | Very simple: essentially a raw float dump with a small header |
| **[Radiance format (.hdr)](https://en.wikipedia.org/wiki/RGBE_image_format)** | 8 bits red mantissa + 8 bits green mantissa + 8 bits blue mantissa + **one shared 8-bit exponent** = 32 bits | The shared exponent is the trick: a pixel takes 32 bits instead of the 96 bits of three 32-bit floats (about one third); supported directly by MATLAB |
| **[OpenEXR (.exr)](https://en.wikipedia.org/wiki/OpenEXR)** | Sign, exponent, mantissa (typically a 16-bit "half" float per channel) | Extra features: multiple layers, metadata, compression |

### 12.4 Light probes, environment maps, and rendered HDR

A **light probe** is a mirrored chrome sphere placed in a scene and photographed as an HDR image. The sphere reflects the whole surrounding environment into one image, so the result measures the real illumination environment (an **environment map**), directly useful for **image-based relighting** (lighting a synthetic object as if it sat in that real environment). Separately, physics-based renderers compute flux maps (relative or absolute) as their native output, so a rendered image is very often already HDR, with no capture or merging needed.

> **Summary**
> - A merged HDR image is correct only up to a global scale (one spotmeter reading fixes it); it needs a static scene and static camera.
> - Rule to remember: store HDR data as floats (.pfm, .hdr with a shared exponent, .exr), never in clipped integers.
> - Light probes use HDR to capture real illumination; renderers produce HDR natively.
> - Next: showing an HDR image on a limited display (§13).

---

## 13. Tonemapping: Why Linear Scaling Fails

### 13.1 What "tone" and "tone mapping" mean

**Tone.** The **tone** of a pixel or region is its brightness level on the dark-to-light scale (for color images, usually luminance, the brightness part of color, Week 3). The **tonal range** is the span of tones from darkest to brightest. Analogy: in music a *tone* is a position on a low-to-high pitch scale; in an image, a position on a dark-to-light scale. (Photographers also say "warm tone" for a color cast; here "tone" means brightness only.)

**Tone curve (recap of §9.1).** A function from input tone to output tone: input brightness on the horizontal axis, output on the vertical. A straight diagonal changes nothing; a curve bowing upward brightens dark tones more than bright ones. It is like an audio equalizer re-shaping loudness.

**Tone mapping.** Applying a tone curve (or something more elaborate) to an HDR image so its enormous tonal range fits the small range a display can show, while keeping the *look* of contrast and detail. Analogy: fitting a long scroll onto a postcard (shrink uniformly and the writing is unreadable; you must decide what to squeeze most), or squeezing an orchestra's loud and quiet passages into a phone speaker's narrow range.

**Two different "tone curves," kept apart:**

| | In-camera tone curve (§9) | HDR tonemapping (this part) |
|---|---|---|
| Where it happens | Inside the camera, when it writes the JPEG | On your computer, after merging an HDR image |
| Input | Sensor's linear values (limited range) | Linear HDR values (huge, unbounded range) |
| Goal | Look right on a screen; spend 8 bits efficiently | Compress the huge range into the display's small range |
| Who chooses it | The camera maker (fixed, usually unknown) | You (the algorithm and its settings) |
| What we do with it | **Undo it** (calibration, then *f*⁻¹) | **Apply it** (the last step before display) |

Their mathematical shape can look alike (a gamma-type curve appears in both), which is why they are easy to confuse. The difference is purpose and direction.

### 13.2 Why linear scaling fails, with numbers

Once an HDR image *I_HDR* exists (§8–§12), it must be shown on a display with a far smaller range (§7). Illustrative HDR values for a room with a window (units chosen so white paper in the room reads 1; invented, not from any assignment):

| Region | *I_HDR* (linear) |
|---|---|
| Deep shadow | 0.002 |
| Dim corner | 0.02 |
| Face | 0.2 |
| Sunlit wall | 2 |
| Sky through window | 20 |

The ratio brightest : darkest is 20 / 0.002 = 10,000 : 1 (about 13.3 stops, since log2(10,000) ≈ 13.3), while an 8-bit display value has only 256 levels (0 to 255). Treat the output as a fraction of the display's maximum light and multiply by 255 for the 8-bit code.

**Linear scaling** picks one reference value in the HDR image, maps it to the display maximum (1.0) and scales everything proportionally. Two obvious choices fail in complementary ways:

- **Scale so the maximum maps to 1** (divide by 20). The regions become 0.0001, 0.001, 0.01, 0.1, 1, i.e. 8-bit codes 0, 0, 3, 26, 255. Shadow and dim corner are both pure black, and the face is a very dark 26. The result looks *underexposed*, though the data is fine: almost the whole range is crushed into the display's low end because only the single brightest pixel earns the full "1.0."
- **Scale so a lower reference maps to 1**, say the sunlit wall (2): divide by 2 to get 0.001, 0.01, 0.1, 1, 10, with the last clipped to 1, giving codes 0, 3, 26, 255, 255. Wall and sky are both flat white, so the window's detail is gone: it looks *saturated* (blown out).

Neither failure is a defect in the HDR data, which contains all the brightness information. The failure is purely in squeezing it *linearly*. We need a **non-linear** curve, steep for dark tones (to spread them apart) and flat for bright tones (to pack them together). §14 gives one.

> **Summary**
> - **Tonemapping** applies a tone curve so a huge HDR range fits a display; it is chosen by you, unlike the in-camera curve you undo.
> - Rule to remember: any *linear* scaling either crushes the shadows (reference = maximum) or blows out the highlights (reference = a lower value).
> - A non-linear curve (steep for darks, flat for brights) is needed.
> - Next: two such curves (§14), then color-aware and local methods (§15).

---

## 14. Photographic Tonemapping

**Intuition.** A tone curve (§13.1) maps input brightness to output brightness. A good tonemapping curve needs two properties at once:

1. **Bring every HDR value, however large, into the display's finite range:** the curve must *asymptote* to 1, never reaching or exceeding it.
2. **Leave genuinely dark regions alone:** a curve with **slope 1 near 0** does not waste contrast compressing shadows that were already fine.

A hyperbola-shaped function does both:

```
I_display = I_HDR / (1 + I_HDR)
```

*(The lecture notes the exact formula used in practice is somewhat more complicated; this simplified version makes both design goals visible in the algebra.)*

**Term by term.**

- *I_HDR*: the input HDR intensity at one pixel (linear, non-negative, unbounded above; what the merge of §10 produced).
- *I_display*: the output sent to the display, guaranteed to lie in [0, 1).

**Checking the two design goals from the formula.**

- Near *I_HDR* = 0, *I_display* ≈ *I_HDR* (dividing by 1 + a small number barely changes it): slope 1, dark detail untouched.
- As *I_HDR* → ∞, *I_display* → 1: it asymptotes, so no value, however bright, exceeds the display's range.
- The lecture notes this shape is **perceptually motivated**, approximating the eye's own response to intensity (Week 1 §15, Week 3 §10: perception is roughly logarithmic/power-law), so a display encoding matched to it looks more natural than a linear compression.

> **Worked check on §13.2's five room values** (0.002, 0.02, 0.2, 2, 20). The curve gives 0.002, 0.0196, 0.167, 0.667, 0.952, i.e. 8-bit codes **1, 5, 43, 170, 243**: five distinct, usable codes, where linear scaling gave 0, 0, 3, 26, 255 or 0, 3, 26, 255, 255.

**Diagram.** Plot *L_display* against *L_world* (the lecture's axis labels): a straight line of slope 1 near the origin, curving over and flattening toward an asymptote, contrasted with the two broken linear-scaling lines of §13.2 (one would need to climb past 1, impossible, hence clipping; the other starts too shallow, hence looks dark). (See Fig. — companion diagram of the photographic tonemapping curve with the two failed linear-scaling lines overlaid.)

**Worked comparison.** The lecture's side-by-side examples show photographic tonemapping recovering *both* the highlight and shadow detail that each linear-scaling choice sacrificed, matching a high-exposure LDR shot's shadows and a low-exposure LDR shot's highlights in one image.

### 14.1 The two-knob gamma tonemapper (supports HW3 Task 1.2)

*(Beyond the lecture's slides: the simplest tonemapper HW3 asks you to build and tune.)*

**Analogy.** Brightening a dim photo with a "brightness" slider (multiply everything), then a "gamma" slider (lift shadows more than highlights). Two sliders, in that order.

```
I_display = clip( (s · I_HDR)^γ , 0, 1 )
```

**Intuition, step by step.**

1. *I_HDR* is first normalized to [0, 1] (divide by its maximum), as HW3 specifies.
2. Multiply by the **scale** *s*: a pure linear exposure change (§13). *s* > 1 pushes more of the image upward; anything above 1 clips in step 4.
3. Raise to the power **γ**. For 0 < γ < 1 the curve rises steeply near 0 and flattens toward 1, lifting shadows much more than highlights. That is the shape of Week 3 §10's gamma *encoding* (γ ≈ 1/2.2) and, like I/(1+I), gives dark detail more room, but unlike I/(1+I) it does **not** asymptote: values can exceed 1.
4. **clip** to [0, 1]: anything above is cut to 1 (negatives, if any, to 0). Multiplying by the display's maximum code (255) and rounding gives the 8-bit image.

**Term by term.**

- *I_HDR*: normalized linear HDR value from the merge (§10); fixed by the data.
- *s*: dimensionless linear gain, **you choose**; larger *s* brightens but clips more highlights.
- *γ*: dimensionless exponent, **you choose**; smaller γ lifts shadows more and flattens contrast overall.
- *clip*: forces the result into the displayable range.
- There is no single correct pair: the assignment asks you to tune both by eye and report them, so the numbers are yours to find.

**Trade-off while tuning.** *s* trades highlight clipping against overall brightness; γ trades shadow visibility against flattened mid-tone contrast. The same *I_HDR* always maps to the same output, so this is a **global** operator (next subsection); extreme settings cannot recover local contrast the way local operators can.

### 14.2 Global vs. local tonemapping, and OpenCV's built-in tonemappers

- A **global** operator applies one fixed curve to every pixel: the output depends only on that pixel's own value. §13's linear scaling, §14's I/(1+I) and §14.1's (*s*·*I*)^γ are all global.
- A **local** operator lets the output depend on a pixel's neighbors too, so it can compress large-scale brightness differences while keeping local contrast. §15 walks through the lecture's local examples (base/detail split, bilateral filtering, gradient-domain methods).

**What a tonemapper object does (conceptual).**

- **Input:** a floating-point HDR image (linear values, unbounded above).
- **Output:** an image with values in [0, 1], ready to scale to 8 bits.
- **Analogy:** a photo-lab technician printing a high-contrast negative onto paper of limited contrast, choosing how to compress highlights and shadows. Each OpenCV class is a technician with a different recipe; its constructor arguments are the adjustable settings (typically a gamma-like exponent and, for the more elaborate ones, how strongly to compress contrast).

HW3's starter code calls one of **OpenCV**'s (the standard open-source computer-vision library) built-in tonemappers: `cv2.createTonemap` (a simple gamma operator), `cv2.createTonemapDrago` (adaptive-logarithmic), `cv2.createTonemapReinhard`, and `cv2.createTonemapMantiuk` (gradient-domain, a local method). You need not implement any: the assignment only asks you to run the one in the starter code and compare it with your own two-knob result from §14.1. PS3's slides name Drago (`cv2.createTonemapDrago`).

> **Summary**
> - A good tonemapping curve asymptotes to 1 for large inputs and has slope 1 near 0.
> - Rule to remember: **I_display = I_HDR / (1 + I_HDR)**, and the tunable **(s·I)^γ, clipped**, where *s* sets brightness and γ < 1 lifts shadows.
> - These are *global* operators (output depends on the pixel alone); *local* ones also use neighbors.
> - Next: why applying a curve per color channel goes wrong, and the local methods that fix it (§15).

---

## 15. Color-Aware Tonemapping

§14's curve was described for a single scalar intensity. Applying it to a color image raises the question the lecture poses: apply the *same* curve independently to R, G and B? The lecture walks through five increasingly sophisticated answers, each fixing the previous one's failure. It states that "there are many more, and more complicated" algorithms, so this is a survey of *why* each step was needed, not a derivation of any.

| Step | Approach | Fixes | New problem introduced |
|---|---|---|---|
| 1 | **Naive per-channel**: apply §14's curve separately to R, G, B | — | **Colors wash out**: each channel is compressed by a different amount, which distorts the ratios between channels, and those ratios encode hue and saturation |
| 2 | **Intensity-only, in xyY**: convert to a luminance/chromaticity representation (**[xyY](https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_xyY_color_space)**, a reparameterization of Week 3 §6's CIE xy chromaticity plus a luminance axis Y), tonemap only Y, leave xy untouched | Colors no longer wash out: hue/saturation are preserved by construction | **Contrast/detail washes out**: one *global* curve still compresses every pixel's fine local contrast the same way |
| 3 | **Low-frequency intensity-only**: split intensity into a low-spatial-frequency (coarse, blurred) component and a high-spatial-frequency (fine detail) component (the low-pass/high-pass split of Week 1 §21, §22.1), tonemap only the low-frequency part, leave detail and chromaticity untouched | Nice color *and* nice local contrast | **Halo artifacts**: a naive low-pass filter (e.g. Gaussian) blurs *across* strong edges, mixing very different brightness levels, giving ringing/halos around high-contrast boundaries |
| 4 | **Edge-aware filtering**: the same base/detail split, but with an edge-preserving filter: the **[bilateral filter](https://en.wikipedia.org/wiki/Bilateral_filter)** of Week 3 §16.2 (averages nearby pixels only when they are *also* similar in intensity, so it never blurs across a strong edge) | Fixes the halos without losing earlier color and contrast gains | (None flagged by the lecture) |
| 5 | **Gradient-domain processing** and **Local Laplacian Filters** (Paris et al., 2011) | State-of-the-art alternatives | "Too many algorithms to discuss here": the lecture declines to go deeper |

**Step 5, briefly.** Gradient-domain tonemapping computes the image's spatial gradients, attenuates the large gradients (the steep brightness jumps that overflow the display) while leaving small ones alone, then **re-integrates** the modified gradient field into an image by solving a **[Poisson equation](https://en.wikipedia.org/wiki/Poisson%27s_equation)**. It compresses range while preserving fine detail, with no explicit base/detail split.

**Linear-algebra view (gradient-domain tonemapping is solving a linear system).**

- Computing an image's gradient is a **linear operator**: a fixed finite-difference matrix **G** acting on the image vector (Week 1 §21's "convolution is a matrix" idea, with a difference kernel instead of a blur kernel).
- Scaling the gradient field rescales **G**'s output entry by entry.
- Recovering a displayable image from the *modified* gradients means finding **x̂** whose own gradient **Gx̂** best matches the target: a least-squares problem whose solution (the discrete Poisson solve) is the normal-equations inverse of **G**.
- "Re-integrating a gradient field" is, underneath the graphics vocabulary, solving a linear system for the vector that a linear operator was applied to.

> **Summary**
> - A per-channel curve washes out color; tonemapping luminance only (xyY) keeps color but flattens detail; a base/detail split keeps detail but makes halos with a blur; an edge-preserving (bilateral) filter removes halos.
> - Rule to remember: compress the *coarse* brightness, keep the *fine* detail and the chromaticity.
> - Gradient-domain methods solve a Poisson (least-squares) problem on a modified gradient field.
> - Next: tidy up the vocabulary of "HDR" (§16).

---

## 16. Terminology: Five Loose Uses of "HDR Imaging," Disambiguated

The lecture calls out that **"high-dynamic-range imaging"** gets used to mean genuinely different things. Now that §8–§15 have built every piece, here is its list and resolution.

**The five loose senses:**

1. Using single RAW images (no bracketing or merging, just capturing at high native bit depth, Week 2 §20).
2. Performing radiometric calibration (§9) alone.
3. Merging an exposure stack (§10) into one HDR image.
4. Tonemapping an image: linear or non-linear input, HDR or LDR input (§13–§15).
5. Some or all of the above, lumped together.

**The precise split:**

- **HDR imaging**, precisely, is the process of creating a *radiometrically linear* image free of over- and under-exposure artifacts, via some combination of senses 1–3 (a single well-exposed RAW file may suffice; a very high-contrast scene needs the full bracket-and-merge pipeline).
- **Tonemapping** (sense 4) is the separate process of mapping an image's intensities, whatever their source (HDR or LDR, linear or non-linear), into the tonal range a display can show.

**In ordinary consumer usage,** "HDR photography" routinely means **both** HDR imaging (senses 1–3) **and** tonemapping (sense 4) as one "HDR mode" workflow. That is why the phrase feels overloaded, even though the halves are distinct techniques with different goals (§1, §7).

> **Summary**
> - "HDR" is used for five things; precisely, **HDR imaging** = producing a radiometrically linear, unclipped image, and **tonemapping** = making it displayable.
> - Rule to remember: HDR imaging fixes *sensor* limits; tonemapping fixes *display* limits.
> - Consumer "HDR mode" does both.
> - Next: why many "HDR photos" look bad (§17).

---

## 17. A Note of Caution: The Over-Tonemapped Look

HDR photography done well is compelling, but by the lecture's description it is also "a very routinely abused technique," producing the garish, flattened, halo-ringed look associated with "HDR photos" in popular culture.

- **The blame belongs to the tonemapping choice, not HDR imaging itself.** An aggressive local operator (over-compressing contrast, over-sharpening local detail) produces the unnatural look, not the radiometrically correct data it was applied to.
- Most cameras today, including phones, ship an automatic HDR mode, and the algorithms behind some of them (e.g. Google's HDR+) are published research, appearing in SIGGRAPH and SIGGRAPH Asia.

> **Summary**
> - The over-processed "HDR look" comes from aggressive local tonemapping, not from HDR capture.
> - Rule to remember: keep HDR imaging and tonemapping separate when judging a result.
> - Next: Part 2 turns from brightness to *blur*, starting with the point spread function (§18).

---
# Part 2 — Coded (Aperture) Computational Imaging

Part 1 was about *brightness*. Part 2 is about *blur*: how to shape it on purpose so a computer can undo it afterwards. We first need the tools for describing blur, the PSF and OTF.

## 18. Point Spread Function and Optical Transfer Function, from Scratch

This section leans on **convolution** (a kernel slid across a signal as a weighted sum), which Week 1 §20 builds from scratch with worked numbers. If its terms (kernel, impulse response, shift-invariant, convolution theorem) are unfamiliar, read that first. Week 2 §3, §9 already used the *idea* informally (a finite pinhole's blur disc, a lens's circle of confusion, a convolution-matrix view of blur) without this name; this section (using PS4 Task 1's material) gives it its formal name and its frequency-domain partner.

### 18.1 The point spread function (PSF)

**Analogy and definition.** Photograph one isolated point of light (a distant star, or a backlit pinhole) through some optical system. Whatever blob of light lands on the sensor, however large or oddly shaped, **is** that system's **[point spread function (PSF)](https://en.wikipedia.org/wiki/Point_spread_function)**: the picture of a single point, "spread" by the optics.

- A perfect pinhole (Week 2 §2) has a PSF that is (ideally) a single point.
- A finite pinhole gives a disc (Week 2 §3); a defocused lens gives a circle of confusion (Week 2 §9); a diffraction-limited circular aperture gives an Airy pattern.

**From one point to a whole image.** If the blur behaves the same at every location (**shift-invariant**), every scene point is smeared by that same PSF shape, centered where the point's sharp image would land. The blurred image is the sum, over every scene point, of a copy of the PSF scaled by that point's brightness: the **convolution** of Week 1 §20 ("stamp a scaled copy of the kernel at every point and add," with the PSF as the stamp):

```
I_blurred(x, y) = (I_ideal * PSF)(x, y)
```

**Term by term.**

- *I_ideal*(*x*,*y*): the hypothetical perfectly sharp image an ideal pinhole would give.
- PSF(*x*,*y*): the system's blur kernel, normalized to sum (or integrate) to 1, as PS4 instructs ("normalize the filter so it sums to 1"). That makes the blur redistribute light rather than add or remove any.
- *I_blurred*: the image actually captured.
- `*`: convolution, the sliding weighted sum of Week 1 §20 (the PSF is that section's kernel, or "impulse response").

**Diagram.** (See Fig. — companion diagram: one bright point through an ideal pinhole lands as a sharp dot; through a real lens it lands as a blurred disc, and that disc *is* the PSF.)

### 18.2 The optical transfer function (OTF)

**Definition.** The **[optical transfer function (OTF)](https://en.wikipedia.org/wiki/Optical_transfer_function)** is the two-dimensional Fourier transform of the PSF:

```
OTF(u, v) = FT{ PSF }(u, v)
```

where *u*, *v* are image frequencies as built in Week 1 §19.2 (cycles per pixel).

**Intuition via the convolution theorem.**

1. Week 1 §20.7 showed that convolving in the spatial domain equals multiplying spectra in the frequency domain: each pure wave passes through a shift-invariant blur as the same wave, only scaled (and phase-shifted), so the blur treats each frequency independently.
2. In this section's terms: if *I* is the sharp image with spectrum *Ĩ*, the blurred image has spectrum *Ĩ* × OTF, entry by entry.
3. So the OTF reports, frequency by frequency, how much of each spatial-frequency component *survives* the optics. Where |OTF(*u*,*v*)| is near 1, that frequency passes through; where it is near 0, that frequency is (nearly) destroyed, and no after-the-fact processing can recover what was never recorded.

**A word we will use a lot: broadband.** A PSF or OTF is **broadband** when its OTF has **no exact zeros**: every spatial frequency survives with *some* nonzero strength, even if weakly. Being broadband is what makes a blur, in principle, invertible.

**Linear-algebra view (recapping Week 1 §20, §21 and Week 2 §3).**

- Convolution by a fixed kernel is a **linear, shift-invariant operator**: a **Toeplitz/circulant matrix** acting on the flattened image vector (Week 2 §3 applied this to a finite pinhole's blur disc).
- Every sinusoid is an eigenvector of that matrix, with eigenvalue equal to the kernel's Fourier transform. So the OTF *is* the convolution matrix's eigenvalues, one per spatial frequency.
- A frequency where the OTF is exactly zero has a zero eigenvalue: the matching Fourier basis vector lies in the matrix's **null space**, a direction in "scene space" this optical system provably cannot see.
- A **broadband** OTF means a trivial null space, so the convolution matrix is, in principle, invertible.

### 18.3 Filtering in the primal domain vs. the Fourier domain (PS4 Task 1)

PS4 Task 1 has you implement the *same* filtering two ways, to see the OTF's practical payoff. A **low-pass filter** (Week 1 §22.1) can be applied by convolving with a low-pass PSF in the spatial ("primal") domain, or by multiplying by the corresponding low-pass OTF in the Fourier domain. A **high-pass filter** (recovering fine detail) is the complement of the low-pass version (Week 1 §21's complementary-projection idea and Week 1 §20.6's "blur-then-subtract is a convolution"), now in this week's vocabulary:

```
I − I * PSF_LP              (primal domain: subtract a low-pass-blurred copy)
Ĩ × (1 − OTF_LP)             (Fourier domain: multiply by the complementary mask)
```

Here PSF_LP is a low-pass blur kernel (e.g. a Gaussian), OTF_LP its Fourier transform, *I* the spatial-domain image and *Ĩ* its spectrum. The "mask" is not hand-drawn: it is the OTF of a real blur kernel.

**Deconvolution, the reason this matters (orientation).**

- Everything above is the *forward* direction: sharp scene → PSF → blurry photo.
- **Deconvolution** is the reverse: recover the sharp scene from the blurry photo, dividing by the OTF at each frequency.
- It is **non-blind** when the PSF is known (as for a coded aperture you designed) and **blind** when it must be estimated.
- It is **ill-posed** because where |OTF| is near zero the division amplifies noise (an exact zero loses that frequency outright). This is why coded imaging designs PSFs with no zeros, and why Weeks 5–6 (Wiener filter, priors, regularization) exist. A numeric first look, with a LiDAR pulse-blur example, is in Week 1 §23.

**Why Fourier-domain filtering cost is independent of kernel size.**

- Direct convolution of an *N*-pixel image with a *K*×*K* kernel costs *K*² multiplies per output pixel, so *O*(*N*·*K*²): a bigger kernel means more work.
- Fourier-domain filtering costs one FFT (*O*(*N* log *N*)), one pointwise multiply by the OTF (*O*(*N*); once the kernel is zero-padded to the image size the OTF array is as large as the image however wide the kernel was), and one inverse FFT.
- **The kernel's size never enters the Fourier-domain cost**; only the image's size does.

> **Worked example: PS4's own runtime benchmark.** PS4 blurs an image with a Gaussian kernel at three widths (σ = 0.1, 1, 10) using both routes. The spatial route's runtime grows sharply (its bars climb by roughly three orders of magnitude from σ = 0.1 to σ = 10 on the log-scale axis), while the Fourier route stays essentially flat: a measured confirmation of *O*(*N*·*K*²) vs. *O*(*N* log *N*).

> **Summary**
> - The **PSF** is the image a system makes of one point; a shift-invariant system's output is the *ideal image convolved with the PSF*.
> - The **OTF** = FT{PSF} says how much of each spatial frequency survives; zeros in it are lost for good (the null space of the convolution matrix).
> - Rule to remember: **blurred = ideal \* PSF** in space, **Ĩ × OTF** in frequency; a **broadband** OTF (no exact zeros) is what makes deblurring possible.
> - Next: how coding the aperture shapes the PSF (§19).

---

## 19. Coded Apertures: Reshaping the PSF

### 19.1 The camera aperture revisited: two codable parts

Week 2 §8 introduced the aperture as a single number, the f-number *N* = *f*/*D*. A real camera aperture has (at least) **two physically separate parts**, and either can be deliberately **coded**, i.e. replaced by something more elaborate than its default:

1. **The aperture stop itself.** Normally a circular opening of adjustable diameter (Week 2 §8). Coding it means replacing the plain hole with a patterned, **attenuating** mask: a stencil, opaque in some places and transparent (or partly so) in others.
2. **The refractive elements.** The lens or compound-lens system (Week 2 §5, §6). Coding it means altering the optics' shape or adding a phase-changing element so light does not refract as an ordinary lens would. This is **wavefront coding** (used again in §20).

Both work by reshaping the camera's PSF (§18).

### 19.2 An out-of-focus point's blur is (a scaled copy of) the aperture's shape

- Recall Week 2 §3: a pinhole of nonzero diameter passes an entire small cone of rays per scene point, so each point projects to a blurred disc **the same shape as the opening**.
- The same geometry holds for a defocused lens (Week 2 §9): an out-of-focus point sends a full cone of rays through the *entire* aperture, and that cone's cross-section at the sensor, the PSF, is a scaled copy of the aperture's opening.
- A plain circular stop therefore gives a circular (at the diffraction limit, Airy-ring) defocus PSF.
- **Coding the stop's shape directly and predictably reshapes the PSF into that pattern.**

Photographers already see this un-coded as **bokeh**, the look of out-of-focus highlights: hexagons from a polygonal diaphragm, donuts from mirror lenses (Week 2 §13). A coded aperture is a deliberately designed bokeh shape.

### 19.3 Why the circular PSF is a problem, and what "broadband" fixes

The lecture (Veeraraghavan et al., 2007) photographs the same out-of-focus point through an ordinary circular aperture, getting a smooth circular blob, and through a specifically designed coded aperture, getting a blob shaped like the pattern. Comparing their Fourier magnitudes (the OTF, §18.2) shows why this matters:

- The **circular aperture's OTF has visible dark rings**: frequencies where it drops to (near) zero.
- The **coded aperture's OTF has no such rings**: it stays nonzero (if uneven) across the whole frequency range shown.
- In §18.2's linear-algebra language: the circular PSF's convolution matrix has a genuine null space (those frequencies are unrecoverable by any algorithm); the coded PSF's matrix has a **trivial** null space, since every frequency survives with *some* nonzero strength.

That is what the lecture calls **broadband**. A broadband PSF's blur is, in principle, invertible by deconvolution (Weeks 5–6), whereas a circular/Airy PSF has provably lost information at its zero-crossing frequencies, however good the algorithm. The lecture states two payoffs: coding the aperture (1) **preserves high frequencies** a circular aperture would destroy, giving (2) **more content available to help determine correct depth**, which is what makes coded-aperture depth estimation possible (§21).

> **Summary**
> - A real aperture has two codable parts: the **stop** (attenuating mask) and the **refractive optics** (wavefront coding).
> - An out-of-focus point's blur is a scaled copy of the aperture shape, so changing the shape changes the PSF.
> - Rule to remember: a circular aperture's OTF has exact zeros (information lost); a well-designed coded aperture's OTF is **broadband** (no zeros), so deconvolution can recover the scene.
> - Next: using engineered PSFs to get sharp images at every depth (§20).

---

## 20. Extended Depth of Field

### 20.1 Two problems with ordinary defocus deblurring

Recall Week 2 §9: an object away from the focused distance *S* produces a circle of confusion of size *c* = *m*·*D*·|*O*−*S*|/*O* (Week 2 §9.2), depending on its own depth *O*. Trying to "deblur" an ordinary out-of-focus photo hits two problems:

1. **The PSF's scale depends on unknown depth.** Since *c* varies with *O*, and *O* is generally unknown per scene point, no single deconvolution kernel undoes the blur everywhere; each depth needs its own.
2. **The PSF usually isn't invertible.** Even at one known depth, an ordinary circular/Airy PSF has the null-space problem of §19.3: some frequencies are gone.

### 20.2 Two engineering fixes, one per problem

**Fix for problem 1: engineer a *depth-invariant* PSF.** If the PSF is (approximately) the *same* whatever the depth, one shift-invariant deconvolution kernel handles the whole image. Two ways:

- **Focal sweep.** Physically move the sensor (or focal plane) through a range of positions *during* one exposure. Each scene point is in focus only briefly and defocused by a *changing* amount otherwise; averaged over the exposure, points at *every* depth get approximately the same time-integrated kernel, because the sweep passes every depth through the same range of defocus.
- **Wavefront coding** (§19.1, part 2). Change the optics so rays from a point no longer converge to a sharp focus at any single plane, but form an extended, roughly constant smear across a range of depths. That gives an approximately depth-invariant PSF directly, with no moving parts.

**Fix for problem 2: engineer a *broadband* PSF.** As in §19.3: shape the aperture (or the wavefront-coding optics) so the OTF has no zero crossings, making the depth-invariant blur well-posed to invert.

### 20.3 Focal sweep, worked (Nagahara et al., 2008)

The lecture compares three captures of one scene:

- **(a)** A conventional photo with a *wide* aperture (shallow depth of field): sharp only in a narrow depth slice.
- **(b)** A conventional photo with a *small* aperture (large physical depth of field, Week 2 §10): sharp almost everywhere but much noisier, since a small aperture collects far less light (Week 2 §4, §8).
- **(c)** A **focal-sweep** capture: deliberately blurry *everywhere* (every depth gets the same time-integrated defocus), then deconvolved with one shared, depth-invariant kernel to give an **EDOF (extended depth of field)** image sharp at every depth at once.

**Why SNR, not just sharpness, is the honest comparison.** (b) and (c) can both *look* sharp everywhere; the real difference is *how much noise* was paid.

- (b) gets depth of field by stopping down, which costs light (Week 2 §4, §8) and so SNR (Week 2 §19).
- (c) can keep the aperture wide open throughout the sweep, collecting far more light, and pays instead in a single known, invertible blur.
- So SNR reveals whether focal sweep was worth it. The outcome is not universal: it depends on the sensor's noise characteristics (Week 2 §18), so the winner can change with different read noise, dark current or quantum efficiency.

**Diagram.** (See Fig. — companion diagram extending Week 2 §9.2's circle-of-confusion figure: the same lens/sensor geometry with the sensor sweeping through a range of positions during one exposure, so every depth's rays are captured at a whole range of defocus states.)

> **Summary**
> - Ordinary defocus deblurring fails twice: the PSF scale depends on unknown depth, and the PSF has zeros.
> - Fixes: a **depth-invariant** PSF (focal sweep, or wavefront coding) and a **broadband** PSF.
> - Rule to remember: sweep (or code) so every depth gets the same blur, then deconvolve once; judge by SNR, not sharpness alone.
> - Next: reading depth *out of* the PSF instead of removing its depth-dependence (§21).

---

## 21. Monocular Depth Estimation via Coded Apertures

### 21.1 Motivation: depth from one lens, one shot

Dedicated depth cameras (structured light, LiDAR/time-of-flight, §5) are complex active systems. A different family asks: can a single ordinary 2D photograph carry enough information to recover per-pixel depth? Two answers appear on the lecture's slides:

- **Learned, pictorial-cue depth** (Godard et al., 2017): train a model to infer depth from the cues a human uses (relative size, occlusion, perspective); an entirely ordinary lens and aperture.
- **Coded-aperture depth** (Chang & Wetzstein, 2019; Ikoma et al., 2021): engineer (or jointly *learn*) a non-circular aperture/PSF whose blur varies with depth in a way that is easy to read back out, encoding depth into the optics "rather than just pictorial cues."

### 21.2 Why an ordinary circular aperture's blur is an *ambiguous* depth cue

Week 2 §9.2's formula *c* = *m*·*D*·|*O*−*S*|/*O* shows blur size *c* depends on depth *O*, so blur size could in principle give depth. But Week 2 §9.3 showed a problem: the formula depends only on |*O*−*S*|, so **a point closer than the focus plane and a point farther than it can give the *exact same* circle-of-confusion size** (the "bicone" argument: the converging near cone and diverging far cone are mirror images at the sensor's cross-section). A circular aperture's PSF is symmetric in exactly the way that makes near-defocus and far-defocus *look identical*.

> **Worked numeric example: the sign ambiguity.** Reuse Week 2 §10.3's near/far formulas with the tolerance fraction *k* = ε/(*mD*), and take *k* = 0.2. A point at *O*_near = *S*/(1+*k*) and one at *O*_far = *S*/(1−*k*) both satisfy |*O*−*S*|/*O* = 0.2 exactly, so for the same *D* and *m* they give the **identical** *c*. With *S* = 1000 mm: *O*_near = 1000/1.2 ≈ 833 mm and *O*_far = 1000/0.8 = 1250 mm give the same blur size through an ordinary circular aperture. Blur size alone cannot distinguish "833 mm" from "1250 mm," only that the point is some fixed distance off focus, on one side or the other.

**How a coded aperture breaks the tie.**

- An *asymmetric* aperture pattern changes the blur's *shape/orientation*, not only its size, differently on the near and far side of focus (e.g. rotated or mirrored). The circular case was symmetric only because of the aperture's own circular symmetry (Week 2 §9.3).
- Recovering the PSF's *shape* at an image patch therefore resolves the sign ambiguity a circular aperture cannot.
- This is what the lecture means by "PSF engineering can make depth estimation more robust by encoding low-level depth information in the PSF (rather than just pictorial cues)."

### 21.3 Passive defocus-cue depth vs. active time-of-flight depth: two structurally different families

This reader's interest is LiDAR, so it is worth being explicit: coded-aperture monocular depth and the LiDAR/ToF sensing of §5 are **not two versions of one idea**. They are different sensing families.

| | Passive PSF-encoded monocular depth (this section) | Active time-of-flight / LiDAR (§5; Week 2 §13.4) |
|---|---|---|
| **Illumination** | **Passive**: uses ambient light; supplies none | **Active**: supplies its own light (infrared laser or modulated wave) and measures its return |
| **What's physically measured** | A single 2D image's *local blur pattern* (PSF shape/size per patch) | The *round-trip travel time* (or phase shift) of its own emitted light, τ = 2*d*/*c* (§5.1) |
| **How depth is recovered** | Computationally/statistically: which depth a local blur pattern best fits (often learned end-to-end) | Directly from a physical time/phase measurement; no blur pattern involved |
| **Number of exposures/shots** | A single ordinary photograph | Typically many laser pulses accumulated into a histogram (§5.3), or one continuous-wave phase measurement |
| **Fails when...** | The patch has no texture (a flat, featureless surface has no visible blur pattern) | Ambient sunlight or reflective surfaces overwhelm or saturate the return (§2.4, §5) |
| **Works even when...** | Lighting is uncontrolled/ambient | The scene is a flat, textureless wall: an active system supplies its own signal regardless |

Both output a per-pixel depth estimate and serve the same applications (3D reconstruction, robotics, AR). But one is an engineered optical side-channel read from an otherwise ordinary photograph; the other is a dedicated active ranging system built around a precise clock (or phase detector). A later lecture treats time-of-flight properly; this section's coded-aperture depth is a purely passive, purely optical alternative, not a stepping stone toward LiDAR and not interchangeable with it.

> **Summary**
> - Blur size from a circular aperture is ambiguous in sign: a near point (833 mm) and a far point (1250 mm) can blur identically when focused at 1000 mm.
> - A coded (asymmetric) aperture makes the blur *shape* depend on which side of focus the point is, resolving the ambiguity.
> - Rule to remember: passive PSF-encoded depth reads blur *patterns* from one photo; active LiDAR reads *round-trip time* (τ = 2d/c); they are different families.
> - Next: other places coded apertures are used (§22), then coding the *shutter* instead of the aperture (§23).

---

## 22. Coded Apertures Beyond Photography: Astronomy and Microscopy

Two brief pointers to where coded apertures appear outside ordinary cameras:

- **Astronomy.** Some wavelengths (hard x-rays and gamma rays) cannot be focused by any ordinary lens: no transparent refractive material works, and the grazing-incidence mirrors that focus softer x-rays do not work for these. Coded apertures are used directly in place of a lens, e.g. on NASA's *Swift* and ESA's *INTEGRAL*/SPI space telescopes.
- **Microscopy.** For very low-light imaging, coding the *refraction* (rather than attenuating light with a mask) loses less of the scarce light. The lecture's example is a rotating "double helix" PSF (Stanford Moerner lab): an engineered PSF whose orientation rotates with depth, giving depth from its rotation angle in a single image. It is the same idea as §21's depth-encoding PSFs, engineered as a refractive rather than attenuating pattern.

> **Summary**
> - Where no lens can focus (hard x-rays, gamma rays), a coded aperture replaces the lens.
> - In low-light microscopy, a refractive code (a rotating double-helix PSF) encodes depth without discarding light.
> - Rule to remember: the same "shape the PSF so it carries information" idea, in different hardware.
> - Next: apply the broadband idea to *time* rather than aperture shape, to fix motion blur (§23).

---

## 23. Motion Blur and Deblurring: The Flutter Shutter

### 23.1 Why motion deblurring is hard

§4.3 built the core mechanism: an object moving during the exposure smears across the sensor by (image-plane speed × exposure time) pixels. With the PSF/OTF vocabulary of §18, we can now say this precisely. The lecture states the difficulty in two parts: **(1)** the motion PSF may be unknown and different for every differently-moving object in the frame; **(2)** the motion PSF is difficult to invert.

**Linear-algebra view (motion blur is a linear filter).**

- Each recorded pixel is the *time average* of the scene points that slid past it. For uniform motion along one direction, that is a **convolution** (Week 1 §20) of the sharp image with a **box kernel**: a flat line segment as long as the streak.
- Stack the image into a vector **x**, and blur is one matrix–vector product **y** = **B x**, where **B** is a banded (Toeplitz) matrix with the box kernel repeated along its diagonals.
- Undoing the blur means inverting **B**, and that is badly conditioned (§23.2): the box's Fourier transform has *exact zeros*, so detail at those frequencies is multiplied by zero and lands in **B**'s null space.
- (This is exact for a periodic, wrap-around image. For a finite image with truncated edges, **B** has tiny but not necessarily exactly zero singular values there, which is just as bad in practice.)

### 23.2 The box shutter's sinc zeros vs. the coded shutter's broadband spectrum

**What problem these kernels address.** A moving object smears, and we want to undo the smear. How well that is possible depends on the *blur kernel*, the pattern spreading each point's light along the motion direction, and the shutter's open/closed schedule sets it.

- **In:** the shutter schedule over the exposure (open = 1, closed = 0).
- **Out:** the blur kernel (that schedule laid along the streak) and its Fourier magnitude (the OTF, §18.2), which shows which spatial frequencies survive.
- **Analogy:** recording a speaker with a microphone that is either always on (a smooth muffle that completely cancels certain pitches) or switched on and off in a clever pattern (every pitch leaks through a little, so a clean-up can reconstruct all of them).

**The traditional camera: a box filter.**

- An ordinary shutter is open continuously, so the kernel is a flat **box function** of width *W*, the streak length in pixels (§4.3: image-plane speed × exposure time).
- The Fourier transform of a box is a **sinc function** (a decaying oscillation that crosses zero at regular spacing), and it has **exact zeros** at spatial frequencies *f* = *n*/*W* for every nonzero integer *n*.
- At each, the OTF is exactly 0: whatever detail the scene had at that spatial frequency is destroyed, and no deconvolution can recover it. This is the null-space loss of §23.1.

**Flutter shutter (Raskar et al., 2006): a coded filter.**

- Instead of staying open, **flicker the shutter open and closed** in a specific, precomputed pattern *within* the same total exposure duration.
- The blur kernel is then a jagged 0/1 sequence following the pattern, and its Fourier transform is **broadband**: nonzero (if uneven and noise-like) everywhere in-band, with **no exact zeros**.
- The lecture's side-by-side Fourier-magnitude plots show it: the box shutter's spectrum is a smoothly decaying sinc dipping repeatedly to zero; the coded shutter's is a rough curve that never touches zero, captioned **"Preserves High Frequencies!!!"**

**Term by term.**

- *W*: the streak length in pixels; fixed by the scene and exposure time, not something you directly design.
- *f*: spatial (image) frequency, cycles per pixel (Week 1 §16.4), the same axis as every other spectrum in this course.
- The sinc's zeros *f* = *n*/*W* depend only on the streak length: every box-shutter photo of a given motion speed has zeros at the same frequencies, whatever the scene.
- The coded shutter's open/closed sequence is a designed, precomputed binary code (chosen by Raskar et al. to be broadband); the lecture gives no closed form for it, only the resulting Fourier-magnitude behavior.

**Diagram.** (See Fig. — companion diagram: a box kernel and its sinc-shaped, zero-crossing Fourier magnitude on one side; a flickered/coded kernel and its zero-free, broadband magnitude on the other, reproducing the lecture's "traditional camera: box filter" vs. "flutter shutter: coded filter" comparison.)

**Linear-algebra view (extending §23.1 with the OTF vocabulary).**

- The box-shutter and flutter-shutter blurs are the *same kind* of matrix, a banded Toeplitz convolution matrix **B**, differing only in which kernel fills the bands.
- The box kernel's **B** (periodic form, so eigenvalues are exactly the DFT) has eigenvalues, its OTF, that hit exactly zero at the sinc's zeros: a **nontrivial null space**, unrecoverable directions in image space, exactly as in §19.3's circular-PSF case.
- The coded kernel's **B** has an OTF nonzero at every frequency: a **trivial null space**, so **B** is invertible in principle and deconvolution is *well-posed* rather than impossible.
- As with any real inversion, frequencies where the OTF is merely *small* still amplify noise heavily, the trade-off Wiener deconvolution (Week 5) manages.

**Application: license plate retrieval.** The lecture shows flutter shutter recovering legible license-plate text from a fast-moving car that a conventional long exposure rendered as an unreadable smear: a concrete payoff of trading the box's null-space frequencies for the coded kernel's invertible spectrum.

### 23.3 What the flutter shutter costs in light, and how that compares to a burst of short exposures (supports HW3 Task 3)

*(Beyond the lecture's slides: it builds the noise bookkeeping HW3 Task 3 asks for. It sets up quantities and comparison logic only; plugging in the assignment's numbers and filling its table is left to the assignment.)*

**Analogy.** Two ways to photograph a runner without blur. **Flutter shutter:** keep one bucket in the rain, but hold a lid over it for a pre-chosen half of the time, then read the bucket once. **Burst:** one bucket per short interval, no lid, each read separately. The lid wastes rain; the many buckets each pay a fixed reading fee. Which wins depends on whether the fee or the rain's own randomness is the bigger noise source.

**Setup, in symbols.** Let the full, unmodulated exposure collect *n* photons on average at one pixel (HW3's definition of *n*). Let the **duty cycle** *d* be the fraction of the exposure during which the flutter shutter is open (HW3 fixes it at 50%, *d* = 0.5). Split the exposure into *M* equal time slots (HW3: slots of the shutter's switching period); the shutter is open in a fraction *d* of them.

- **Flutter shutter signal.** Light arrives only in open slots: **μ_flutter = d · n**. Closed slots throw light away, the price of a broadband kernel (§23.2).
- **Flutter shutter readouts.** Read **once**, so read noise (variance σ²) is paid once.
- **Burst signal.** *M* frames, each exposed for one slot with no gaps, collect the full *n* in total (a factor 1/*d* more than the flutter shutter); each frame holds *n*/*M* on average.
- **Burst readouts.** Every frame is read out, so read noise is paid *M* times (§4.5); the frames are then combined as in §3.

**Which noise formula to use.** The per-frame noise comes from §3's rules, and which applies depends on the noise model the question specifies:

- **Gaussian read noise only:** the variance does not depend on the signal; what differs between schemes is the signal size and how many independent read-noise samples are combined.
- **Poisson shot noise only:** the variance equals the mean photons collected, so it scales with how much light the scheme collects (and §3's Poisson-sum rule says splitting light into frames and re-adding loses nothing).

Each scheme's SNR is its mean divided by the square root of its total noise variance (§3).

**Why the comparison is not a foregone conclusion.** The flutter shutter collects less light (factor *d*) but reads out once; the burst collects more light but reads out *M* times. When read noise dominates, the burst's *M* readouts hurt it; when shot noise dominates, the flutter shutter's lost light hurts it and the extra readouts barely matter. That crossover is what the two cameras in HW3's table (a read-noise-limited consumer camera and a shot-noise-limited scientific sensor) are chosen to expose.

**Caveats the idealized homework model leaves out.**

1. The SNR above is that of the *recorded* image. Deblurring a flutter-shutter image multiplies noise by an extra code-dependent amplification when **B** (§23.1) is inverted, a topic of Week 5's Wiener-deconvolution material.
2. Burst frames of a *moving* object combine cleanly only after alignment (motion within a short frame is small but nonzero between frames).

Both are modeling assumptions to state in a write-up, not numbers to compute.

> **Summary**
> - Motion blur is convolution with a box kernel, **y = Bx**; the box's sinc spectrum has exact zeros at *f* = *n*/*W*, so the blur is not invertible.
> - A **flutter shutter** (coded open/closed schedule) gives a broadband kernel with no zeros, so deconvolution becomes well-posed.
> - Rule to remember: **μ_flutter = d·n**: the coded shutter pays for invertibility with light (duty cycle *d*) but reads out only once; a burst keeps all the light but pays read noise *M* times.
> - Next: code the *camera's motion* so one kernel fits every object (§24).

---

## 24. Parabolic Sweep / Motion-Invariant Photography

### 24.1 From coding *when* the shutter is open to coding *how the camera moves*

Flutter shutter (§23) fixes *invertibility* for one known motion. But §23.1's first difficulty remains: a static camera still records a **different** blur kernel for every differently-moving object in the frame (a fast car and a stationary background have different streak lengths, §23.2), so no single deconvolution kernel undoes the whole frame.

**Motion-invariant photography** extends the broadband idea one step. Instead of coding *when* the shutter is open, it codes the **camera's own motion trajectory** during the exposure, so the blur kernel becomes the *same* for every object, whatever its velocity.

**The mechanism: a parabolic sweep.**

- If the camera's position follows a **parabola** over time (it *accelerates* at a constant rate), then every scene object, whatever its true velocity, matches the camera's instantaneous velocity at *some* moment of the sweep (for any object velocity within the range the sweep covers; §24.2).
- This is the meta-strategy of focal sweep (§20.2): rather than pick one value of a nuisance parameter (there defocus scale, here relative velocity) and hope it matches, *sweep through the whole range* during one exposure, so every scene point is equally (mis)matched on average and the blur stops depending on that parameter.
- The payoff, as the lecture frames it: "everything is blurry" (nothing is perfectly sharp, since the camera is always in relative motion to any single velocity), but the blur kernel is **motion invariant**, the same for every object. That is exactly what a single shared deconvolution kernel needs.

### 24.2 Hardware implementation

Physically sweeping a camera through a true parabolic *translation* is awkward. The lecture's implementation **approximates a small translation by a small rotation**:

- The camera sits on a rotating platform that turns about a vertical axis through the camera's optical center.
- A rotating cam, whose edge radius is shaped as a parabola, pushes a lever attached to the platform, so the camera turns with approximately constant angular acceleration.
- For a small enough rotation, the image shift from turning closely approximates the shift from the desired parabolic translation, avoiding dedicated linear-motion hardware.

**Results.** The lecture compares a static camera's capture of a scene with several differently-moving objects (each with its own unknown blur) against the parabolic-sweep capture (uniformly blurry by design) deconvolved with one shared kernel. The sweep-plus-deconvolution recovers a sharp image across every object's velocity at once, while the static camera's blur is unrecoverable per-object without knowing each object's speed. The lecture also shows a failure case, posed as an open question ("why does it fail in this case?") with no answer on the slide. A plausible reading, consistent with the mechanism but not stated by the lecture: motion invariance holds only for velocities *within* the range the parabola was designed to sweep, so an object moving outside it shows ordinary, uncorrected blur.

> **Summary**
> - A static camera gives each moving object its own blur kernel; a **parabolic sweep** of the camera makes the kernel the same for every object velocity in range.
> - Rule to remember: when a nuisance parameter varies across the scene (depth in §20, velocity here), *sweep through its whole range during one exposure* so everything gets the same blur, then deconvolve once.
> - Hardware: a cam-driven rotation approximates the parabolic translation.
> - Next: a brief pointer to learned, programmable sensors (§25).

---

## 25. Coded Imaging with Neural Sensors, and What's Next

One brief pointer the lecture flags without elaborating: **coded imaging with neural sensors** (Martel et al., 2020), programmable image sensors whose individual pixel exposures can themselves be *learned*, rather than fixed by a separate coded aperture or shutter pattern. This blurs the line between "coding the optics" (§19–§24) and "coding the sensor's own per-pixel readout." The lecture's closing line points to the next lecture's topic: **image processing with neural networks**.

> **Summary**
> - Neural sensors learn per-pixel exposure patterns instead of using a fixed code.
> - Rule to remember: coded imaging = design the capture (aperture, shutter, motion, pixel exposure) so a computer can invert it.
> - Next lecture: image processing with neural networks.

---

## 26. Looking Ahead

The lecture's reference list closes Part 2 with the papers cited by name in §19–§25 (Veeraraghavan et al. 2007; Dowski & Cathey 1995 and Nagahara et al. 2008 for extended depth of field; Godard et al. 2017, Chang & Wetzstein 2019, Ikoma et al. 2021 for depth estimation; Raskar et al. 2006 for flutter shutter; Levin et al. 2008 for motion-invariant photography; Martel et al. 2020 for neural sensors). No further derivation is needed, since each was built from first principles above.

Two formal topics are built properly starting next week, both previewed informally here and in earlier weeks:

- **Week 5, "Sampling, Linear Systems, Deconvolution."** This is where **PS4's Task 2** (deconvolution and inverse filtering, and **Wiener deconvolution** specifically) belongs: the formal machinery for inverting a known PSF/OTF (§18), including the noise amplification §23.2 flagged for near-zero (rather than exactly-zero) OTF values. Week 5 also formalizes the sampling theorem and aliasing (used informally in Week 3 §14.2) and the exact discrete Fourier transform machinery Week 1 §19 built only partially.
- **Week 6, "Regularized Inverse Problems with ADMM."** This is where **PS4's Task 3** (gradient descent and stochastic gradient descent, as a general method for problems of the form minimize ½‖**A**x − b‖²) belongs, together with the natural-image priors Week 1 §21 forward-pointed to: the framework for under-determined or ill-posed inverse problems (demosaicking's null space, Week 3 §14.1; the circular and box-kernel null spaces of §19.3 and §23.2) by adding assumptions about what a plausible image looks like.

> **Summary**
> - Week 4 left one question open: how to actually *invert* a known blur (PSF/OTF) in the presence of noise.
> - Week 5 answers it with Wiener deconvolution; Week 6 with priors and regularization (ADMM).
> - Rule to remember: coded capture makes the blur invertible *in principle*; deconvolution is how you do it *in practice*.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology previews stay in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check

**§2, exposure.** If a friend asked why doubling the ISO and doubling the exposure time both make a photo twice as bright, but only one of them actually changes the exposure *H*, you should be able to answer using only the words "gain," "irradiance," and "reciprocity," without looking anything up.

**Part 1.** If you can explain, in your own words, *why* HDR imaging and tonemapping are "distinct techniques with different goals" even though a single consumer "HDR photo" workflow runs both back to back, using only the words "radiometrically linear," "confidence weight," and "display's available range," you have understood the core distinction of Part 1.

**Part 2.** If a friend asked "why does coding the shutter or the aperture actually help, if the image still looks blurry either way?", you should be able to answer using only the words "OTF," "null space," and "broadband," without looking anything up.
