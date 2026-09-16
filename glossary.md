# CSC2529 — Running Glossary

A single, cumulative glossary that grows week by week as the course progresses. Each term: a one-sentence, beginner-level definition plus which week it belongs to, so this file doubles as a map of "what I've learned so far" and "what's coming."

**How this file is maintained:** every time a new week's study notes are written, add that week's *actually-covered* terms to a `## Week N` section here (promoted out of the "forward-looking" preview if they were already listed below), and trim the forward-looking preview under later weeks once they're no longer speculative. Don't delete a term once it's here — later weeks may deepen a definition, but the original stays as a beginner anchor.

---

## Week 1 — Human Visual System
*(full explanations in [`week1-study-notes.md`](./week1-study-notes.md); this is the lookup-speed version)*

- **[Aperture](https://en.wikipedia.org/wiki/Aperture)** — camera terminology for the opening that controls how much light gets let in (a wider opening = more light); the pupil is the eye's own aperture. Deepened in Week 2.
- **[Image sensor](https://en.wikipedia.org/wiki/Image_sensor)** — the electronic chip behind a camera's lens that converts incoming light into a digital image, sitting where photographic film used to go; the retina plays the same biological role. Deepened in Week 2.
- **[Bayer color filter array](https://en.wikipedia.org/wiki/Bayer_filter) / RGGB mosaic** — the physical grid of tiny red/green/green/blue filters glued onto a sensor, one per pixel, so each pixel measures only one color; the rest gets computationally filled in later ([demosaicking](https://en.wikipedia.org/wiki/Demosaicing), Week 3).
- **[dpi (dots per inch)](https://en.wikipedia.org/wiki/Dots_per_inch)** — pixel *size* flipped into pixel *density*: if a pixel is p inches wide, dpi = 1/p. Historically a printing term ([ppi](https://en.wikipedia.org/wiki/Pixel_density) is the more precise word for screens), but used interchangeably with pixel density here (§9).
- **[Accommodation](https://en.wikipedia.org/wiki/Accommodation_(vertebrate_eye))** — the eye changing focus by reshaping its lens via the ciliary muscle.
- **[Fovea](https://en.wikipedia.org/wiki/Fovea_centralis)** — the small, cone-dense pit in the retina responsible for sharp central vision.
- **[Rods](https://en.wikipedia.org/wiki/Rod_cell) / [cones](https://en.wikipedia.org/wiki/Cone_cell)** — the retina's two photoreceptor types: rods for low-light/no-color vision, cones for color and fine detail.
- **[Metamerism](https://en.wikipedia.org/wiki/Metamerism_(color))** — two physically different light spectra producing identical cone responses, so they look like the same color.
- **Visual angle / [arcminute](https://en.wikipedia.org/wiki/Minute_and_second_of_arc)** — the angular size an object subtends at the eye (1° = 60 arcmin); acuity and spatial frequency are both defined in these units, not raw distance.
- **[Dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)** — the ratio between the brightest and darkest signal a system (eye, sensor, or display) can represent, in f-stops or orders of magnitude.
- **[Weber contrast](https://en.wikipedia.org/wiki/Contrast_(vision)#Weber_contrast) / [Michelson contrast](https://en.wikipedia.org/wiki/Contrast_(vision)#Michelson_contrast)** — two different formulas for "contrast": Weber for one feature against a uniform background, Michelson for a repeating pattern.
- **[Spatial frequency](https://en.wikipedia.org/wiki/Spatial_frequency)** — how rapidly *brightness* varies across an image, in cycles per unit distance (or cycles per degree, perceptually); not to be confused with the frequency of light itself (color, §3) or temporal frequency (flicker/frame rate, §17). Full buildup, including why the same pattern's cycles-per-degree changes with viewing distance, in §12.
- **Image frequency** — how rapidly brightness varies across a digital image's *pixel grid* (cycles per pixel), a fixed property of the file alone, independent of print size, display, or viewing distance. Converts into physical spatial frequency via dpi, and from there into cycles-per-degree via viewing distance — the full chain, worked numerically, is in §12.2.1.
- **[Contrast Sensitivity Function (CSF)](https://en.wikipedia.org/wiki/Contrast_(vision)#Contrast_sensitivity)** — the curve describing how sensitive the eye is to a given spatial frequency; band-pass, peaking around 4–6 cycles per degree.
- **[Low-pass](https://en.wikipedia.org/wiki/Low-pass_filter) / [high-pass filter](https://en.wikipedia.org/wiki/High-pass_filter)** — operations that keep only coarse/smooth content, or only fine detail/edges, respectively.
- **[Fourier transform](https://en.wikipedia.org/wiki/Fourier_transform) (1D → 2D)** — the operation that rewrites a signal (a 1D signal like sound, or a 2D signal like an image) as a sum of sine waves of different frequency, amplitude, and phase; for images, the "wave" is a 2D sinusoidal grating with a horizontal frequency *u* and vertical frequency *v*. Introduced early, in §12.4, because HW1's hybrid-images task depends on it; formalized fully in Week 5.
- **Spatial domain / frequency domain** — two equally complete descriptions of the same image: spatial domain indexes by pixel location (ordinary "what color is here"); frequency domain indexes by `(u,v)` spatial-frequency pair (how much of that stripe pattern is present). The Fourier transform converts between them; nothing is lost (§12.4.0).
- **Spectrum (magnitude / phase)** — the Fourier transform's output, one complex number per `(u,v)` pair: magnitude = how strong that frequency is, phase = how it's shifted. Low `(u,v)` = coarse image content, high `(u,v)` = fine detail (§12.4.3).
- **DC component** — the `(u,v) = (0,0)` entry of a spectrum: zero spatial frequency, equal to the image's overall average brightness (§12.4.4).
- **[fftshift](https://en.wikipedia.org/wiki/Discrete_Fourier_transform) / ifftshift** — reorders a raw FFT output so the DC component moves from a corner to the center (`fftshift`), or undoes that reordering before an inverse transform (`ifftshift`) — needed because of how the discrete Fourier transform indexes negative frequencies (§12.4.4).
- **[Convolution theorem](https://en.wikipedia.org/wiki/Convolution_theorem)** — multiplying two spectra in the frequency domain is mathematically identical to convolving (a sliding weighted average of) the corresponding signals in the spatial domain; the mechanism behind frequency-domain filtering (§12.4.5) and, later, the PSF and deconvolution (Weeks 5–6).
- **[Stereoscopic](https://en.wikipedia.org/wiki/Stereoscopy)** — literally "two-eyed viewing" (*stereo* + *scopic*); describes any device or display that feeds each eye a slightly different image (mimicking binocular disparity) so the brain perceives depth from an otherwise flat picture.
- **[Vergence-accommodation conflict (VAC)](https://en.wikipedia.org/wiki/Vergence-accommodation_conflict)** — the mismatch, in stereo displays, between where the eyes converge (simulated depth) and where they must focus (actual screen distance).

## Week 2 — Digital Photography I (ray optics, aperture, sensor)
*(full explanations in [`week2-study-notes.md`](./week2-study-notes.md); this is the lookup-speed version)*

- **[Ray optics](https://en.wikipedia.org/wiki/Geometrical_optics)** — modeling light as straight-line rays, ignoring wave effects — the assumption behind pinhole-camera geometry (HW1) and the thin lens model (§0, §4).
- **Pinhole camera / [camera obscura](https://en.wikipedia.org/wiki/Camera_obscura)** — a barrier with a single small opening that lets only one ray per scene point reach the sensor, forming an inverted, scaled image (§1).
- **[Aperture](https://en.wikipedia.org/wiki/Aperture)** — the opening controlling how much light enters a lens or pinhole; analogous to the iris/pupil. Deepened here with the f-number/stops formalism (§8).
- **Focal length (f)** — the distance from a pinhole or lens to the plane where a sharp image forms; an **intrinsic** property fixed at manufacture, not something a photographer adjusts by moving anything (§1, §4.2).
- **Object distance (S) vs. sensor distance (S′)** — S is how far the actual subject sits from the lens, a property of the *scene*; S′ is how far the lens sits from the sensor, a property of the *setup*, adjusted by the focus ring. The thin lens equation ties the two to the (intrinsic) focal length; "focusing" means physically changing S′ until it matches what the equation demands for the S you want sharp (§4.1–4.3).
- **Magnification (m)** — the ratio of image height to object height produced by a lens, m = (S′ − f)/f = S′/S (§4.1).
- **[Refraction](https://en.wikipedia.org/wiki/Refraction)** — the bending of light at a boundary between two materials of different optical density; the mechanism a lens uses to redirect rays (§4).
- **Thin lens model / Gaussian lens formula** — a simplified lens model (zero thickness) built on two assumptions (center rays pass straight through; parallel rays converge at the focal plane), giving the thin lens equation 1/S + 1/S′ = 1/f, derived from two similar-triangle ray relations (§4.1).
- **Defocus / actual object distance (O)** — a scene point at actual distance O ≠ the currently-focused distance S has rays that converge before or after the sensor plane, landing as a blurred circle of confusion instead of a sharp point; never happens with an ideal pinhole (§5).
- **Aberrations** (spherical, [chromatic](https://en.wikipedia.org/wiki/Chromatic_aberration), oblique/coma/distortion) — systematic deviations from ideal thin-lens focusing, caused respectively by spherical (not hyperbolic) lens shapes, wavelength-dependent refraction (dispersion), and off-axis geometry (§6).
- **[Field of view (FOV)](https://en.wikipedia.org/wiki/Field_of_view)** — the angular extent of scene captured, set by focal length and sensor size; the camera analog of Week 1's eye FOV (§7).
- **[f-number](https://en.wikipedia.org/wiki/F-number)** — ratio of focal length to aperture diameter (N = f/D); smaller means more light and shallower depth of field (§8).
- **Stop** — a change in light by a factor of 2×, the standard unit for spacing aperture (and exposure) settings; the same unit as Week 1's dynamic-range f-stops (§8).
- **[Circle of confusion](https://en.wikipedia.org/wiki/Circle_of_confusion)** — the blur disc a defocused point forms on the sensor, c = m·D·|O − S|/O, derived from two similar-triangle relations tying the aperture, the focused distance S, and the actual distance O (§9.2).
- **[Depth of field](https://en.wikipedia.org/wiki/Depth_of_field)** — the range of actual object distances whose circle of confusion stays below an acceptable (pixel-set) threshold ε, DOF ≈ 2εS/(mD) — centered on the focused distance S, not a free "actual distance" (§9.3).
- **Hyperfocal distance (H)** — the focus distance that extends the far edge of the depth of field to infinity, H = f²/(Nc), where this c is the fixed acceptable-blur threshold, not the general circle-of-confusion variable (§9.4).
- **Diffraction limit / [numerical aperture](https://en.wikipedia.org/wiki/Numerical_aperture) (NA)** — the smallest resolvable spot size set by diffraction alone (Abbe's formula, d ≈ λ/(2·NA) ≈ λN); trades off against depth of field via f-number (§2, §10).
- **Optimal pinhole diameter** — the pinhole size that minimizes total image blur by balancing geometric blur (grows with diameter *d*) against diffraction spread (shrinks with *d*): d = 2√(fλ), where *f* is the pinhole-to-image-plane distance and λ is the wavelength of light (§2.1).
- **Exposure** — total light collected, set by aperture, exposure time, and ISO together (§13).
- **Sensor** — the chip converting incident light into an electrical signal — the camera's "retina" (§11).
- **[Photoelectric effect](https://en.wikipedia.org/wiki/Photoelectric_effect)** — a photon striking a photodiode knocking loose an electron; the basic photon-to-signal conversion inside every pixel (§11).
- **[Quantum efficiency](https://en.wikipedia.org/wiki/Quantum_efficiency) / fill factor** — the fraction of incoming photons actually converted to signal, and the fraction of a pixel's area that is light-sensitive, respectively (§11).
- **[CCD](https://en.wikipedia.org/wiki/Charge-coupled_device) / [CMOS](https://en.wikipedia.org/wiki/CMOS_sensor)** — two sensor architectures for converting and reading out pixel charge; CCD trades speed/cost for sensitivity/noise, CMOS the reverse (§12).
- **[ISO](https://en.wikipedia.org/wiki/Film_speed)** — a sensor gain setting, applied before the ADC, that amplifies signal (and noise) without collecting more light (§13).
- **Bit depth** — the number of discrete digital levels a sensor's ADC can output (12–14 bits RAW vs. 8 bits JPEG), an additional cap on dynamic range beyond the physical noise floor (§14).
- **[Rolling shutter](https://en.wikipedia.org/wiki/Rolling_shutter) / global shutter** — row-by-row vs. all-at-once pixel exposure timing; rolling shutter can produce motion/flicker banding (e.g. 120 Hz AC-light flicker) but can also be exploited as a fine-grained temporal sensor (§15).
- **[Gaussian noise](https://en.wikipedia.org/wiki/Gaussian_noise)** — additive, signal-independent sensor noise from thermal/read/amplifier sources (§16).
- **[Shot noise](https://en.wikipedia.org/wiki/Shot_noise) / [read noise](https://en.wikipedia.org/wiki/Image_noise#Read_noise)** — shot noise: fundamental, signal-dependent randomness in photon arrival counts (Poisson-distributed, standard deviation = √N). Read noise: added by the sensor's own readout electronics, signal-independent (§16).
- **[Signal-to-noise ratio (SNR)](https://en.wikipedia.org/wiki/Signal-to-noise_ratio)** — mean signal divided by its standard deviation; combines shot noise, dark current, and read noise into one formula (§16).

## Week 3 — Digital Photography II (ISP, demosaicking, deconvolution)
- **[ISP](https://en.wikipedia.org/wiki/Image_processor)** — the image signal processor pipeline (demosaic, denoise, color-correct) turning raw sensor output into a viewable photo.
- **[Demosaicking](https://en.wikipedia.org/wiki/Demosaicing)** — reconstructing full color from a sensor where each pixel measured only one channel.
- **Bayer pattern** — the common repeating RGGB color-filter mosaic on most camera sensors.
- **[Denoising](https://en.wikipedia.org/wiki/Noise_reduction)** — computationally removing sensor noise after capture.
- **[Deconvolution](https://en.wikipedia.org/wiki/Deconvolution)** — computationally undoing a known blur — a first taste of an inverse problem (Week 6).

## Week 4 — Great Ideas in Computational Photography
- **[HDR imaging](https://en.wikipedia.org/wiki/High_dynamic_range#Capture)** — combining multiple exposures to represent a wider brightness range than one shot could.
- **[Tone mapping](https://en.wikipedia.org/wiki/Tone_mapping)** — compressing an HDR image into the range a normal display/print can show.
- **Coded aperture** — a specially patterned mask, co-designed with a recovery algorithm, replacing a plain circular aperture.
- **[Flutter shutter](https://en.wikipedia.org/wiki/Coded_exposure_photography)** — opening/closing the shutter in a coded temporal pattern during one exposure to make motion blur easier to invert.

## Week 5 — Sampling, Linear Systems, Deconvolution
- **[DFT](https://en.wikipedia.org/wiki/Discrete_Fourier_transform) / [FFT](https://en.wikipedia.org/wiki/Fast_Fourier_transform)** — converts an image from pixel-brightness representation to spatial-frequency representation; FFT is the efficient algorithm for computing it. The underlying idea (image as sum of 2D waves) was introduced early, in Week 1 §12.4, for the hybrid-images homework; this entry covers the discrete, computationally efficient version — the exact DFT formula and why the FFT algorithm is fast.
- **[Aliasing](https://en.wikipedia.org/wiki/Aliasing)** — distortion from sampling below a signal's true frequency content (e.g. moiré).
- **[Nyquist rate](https://en.wikipedia.org/wiki/Nyquist_rate)** — the minimum sampling rate needed to avoid aliasing for a given highest frequency present.
- **[Diffraction](https://en.wikipedia.org/wiki/Diffraction)** — bending/spreading of light through small openings — limits how sharply any lens or pinhole can focus.
- **PSF ([point spread function](https://en.wikipedia.org/wiki/Point_spread_function))** — how a single point of light gets smeared by an imaging system.
- **[Wiener filter](https://en.wikipedia.org/wiki/Wiener_filter)** — a statistically optimal deconvolution method that accounts for noise.

## Week 6 — Regularized Inverse Problems with ADMM
- **[Inverse problem](https://en.wikipedia.org/wiki/Inverse_problem)** — recovering an unknown true signal from indirect or corrupted measurements.
- **Natural image prior / [regularization](https://en.wikipedia.org/wiki/Regularization_(mathematics))** — assumptions about what real images typically look like, used to make an ill-posed inverse problem solvable.
- **[ADMM](https://en.wikipedia.org/wiki/Alternating_direction_method_of_multipliers)** — an optimization algorithm splitting a hard joint problem into easier alternating sub-steps.
- **[Single-pixel imaging](https://en.wikipedia.org/wiki/Single-pixel_imaging)** — reconstructing a full image from many single-value measurements plus known coded illumination patterns.

## Week 9 — Light Field Imaging
- **[Plenoptic function](https://en.wikipedia.org/wiki/Light_field)** — a theoretical function describing light intensity in every direction, at every point in space, wavelength, and time.
- **[Light field](https://en.wikipedia.org/wiki/Light_field)** — a practical capture of many directional rays, often via camera arrays or microlens arrays.
- **[Light field / 3D display](https://en.wikipedia.org/wiki/Light_field#3D_display)** — a display reproducing different images per viewing angle — one proposed fix for VAC (Week 1, §16).

## Weeks 10–12 — Foundation Models, Neural Rendering, Black Hole Imaging
*(advanced/guest-lecture topics — brief pointers only until covered in detail)*
- **[Foundation model](https://en.wikipedia.org/wiki/Foundation_model)** — a large, general-purpose pretrained network adapted to imaging tasks, rather than trained from scratch per task.
- **Neural rendering** — using neural networks, rather than a traditional graphics pipeline, to synthesize or reconstruct images/3D scenes. *(No dedicated Wikipedia article exists for this general term as of writing — left unlinked rather than pointing at a narrower or inaccurate page.)*
