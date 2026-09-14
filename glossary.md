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
- **[Contrast Sensitivity Function (CSF)](https://en.wikipedia.org/wiki/Contrast_(vision)#Contrast_sensitivity)** — the curve describing how sensitive the eye is to a given spatial frequency; band-pass, peaking around 4–6 cycles per degree.
- **[Low-pass](https://en.wikipedia.org/wiki/Low-pass_filter) / [high-pass filter](https://en.wikipedia.org/wiki/High-pass_filter)** — operations that keep only coarse/smooth content, or only fine detail/edges, respectively.
- **[Stereoscopic](https://en.wikipedia.org/wiki/Stereoscopy)** — literally "two-eyed viewing" (*stereo* + *scopic*); describes any device or display that feeds each eye a slightly different image (mimicking binocular disparity) so the brain perceives depth from an otherwise flat picture.
- **[Vergence-accommodation conflict (VAC)](https://en.wikipedia.org/wiki/Vergence-accommodation_conflict)** — the mismatch, in stereo displays, between where the eyes converge (simulated depth) and where they must focus (actual screen distance).

## Week 2 — Digital Photography I (ray optics, aperture, sensor)
- **[Ray optics](https://en.wikipedia.org/wiki/Geometrical_optics)** — modeling light as straight-line rays, ignoring wave effects — the assumption behind pinhole-camera geometry (HW1).
- **[Aperture](https://en.wikipedia.org/wiki/Aperture)** — the opening controlling how much light enters a lens; analogous to the iris/pupil.
- **[f-number](https://en.wikipedia.org/wiki/F-number)** — ratio of focal length to aperture diameter; smaller means more light and shallower depth of field.
- **[Depth of field](https://en.wikipedia.org/wiki/Depth_of_field)** — the range of distances that appear acceptably in focus at once.
- **[Exposure](https://en.wikipedia.org/wiki/Exposure_(photography))** — total light collected, set by aperture, exposure time, and ISO together.
- **Sensor** — the chip converting incident light into an electrical signal — the camera's "retina."
- **[Shot noise](https://en.wikipedia.org/wiki/Shot_noise) / [read noise](https://en.wikipedia.org/wiki/Image_noise#Read_noise)** — shot noise: fundamental randomness in photon arrival counts. Read noise: added by the sensor's own readout electronics.
- **[ISO](https://en.wikipedia.org/wiki/Film_speed)** — a sensor gain setting that amplifies signal (and noise) without collecting more light.

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
- **[DFT](https://en.wikipedia.org/wiki/Discrete_Fourier_transform) / [FFT](https://en.wikipedia.org/wiki/Fast_Fourier_transform)** — converts an image from pixel-brightness representation to spatial-frequency representation; FFT is the efficient algorithm for computing it.
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
