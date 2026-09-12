# CSC2529 — Running Glossary

A single, cumulative glossary that grows week by week as the course progresses. Each term: a one-sentence, beginner-level definition plus which week it belongs to, so this file doubles as a map of "what I've learned so far" and "what's coming."

**How this file is maintained:** every time a new week's study notes are written, add that week's *actually-covered* terms to a `## Week N` section here (promoted out of the "forward-looking" preview if they were already listed below), and trim the forward-looking preview under later weeks once they're no longer speculative. Don't delete a term once it's here — later weeks may deepen a definition, but the original stays as a beginner anchor.

---

## Week 1 — Human Visual System
*(full explanations in [`week1-study-notes.md`](./week1-study-notes.md); this is the lookup-speed version)*

- **Aperture** — camera terminology for the opening that controls how much light gets let in (a wider opening = more light); the pupil is the eye's own aperture. Deepened in Week 2.
- **Image sensor** — the electronic chip behind a camera's lens that converts incoming light into a digital image, sitting where photographic film used to go; the retina plays the same biological role. Deepened in Week 2.
- **Bayer color filter array / RGGB mosaic** — the physical grid of tiny red/green/green/blue filters glued onto a sensor, one per pixel, so each pixel measures only one color; the rest gets computationally filled in later (demosaicking, Week 3).
- **dpi (dots per inch)** — how many printed dots or screen pixels are packed into one inch; higher dpi means finer, less visible pixel structure, up to the limit of what the eye can actually resolve (§9).
- **Accommodation** — the eye changing focus by reshaping its lens via the ciliary muscle.
- **Fovea** — the small, cone-dense pit in the retina responsible for sharp central vision.
- **Rods / cones** — the retina's two photoreceptor types: rods for low-light/no-color vision, cones for color and fine detail.
- **Metamerism** — two physically different light spectra producing identical cone responses, so they look like the same color.
- **Visual angle / arcminute** — the angular size an object subtends at the eye (1° = 60 arcmin); acuity and spatial frequency are both defined in these units, not raw distance.
- **Dynamic range** — the ratio between the brightest and darkest signal a system (eye, sensor, or display) can represent, in f-stops or orders of magnitude.
- **Weber contrast / Michelson contrast** — two different formulas for "contrast": Weber for one feature against a uniform background, Michelson for a repeating pattern.
- **Spatial frequency** — how rapidly brightness varies across an image, in cycles per unit distance (or cycles per degree, perceptually).
- **Contrast Sensitivity Function (CSF)** — the curve describing how sensitive the eye is to a given spatial frequency; band-pass, peaking around 4–6 cycles per degree.
- **Low-pass / high-pass filter** — operations that keep only coarse/smooth content, or only fine detail/edges, respectively.
- **Stereoscopic** — literally "two-eyed viewing" (*stereo* + *scopic*); describes any device or display that feeds each eye a slightly different image (mimicking binocular disparity) so the brain perceives depth from an otherwise flat picture.
- **Vergence-accommodation conflict (VAC)** — the mismatch, in stereo displays, between where the eyes converge (simulated depth) and where they must focus (actual screen distance).

## Week 2 — Digital Photography I (ray optics, aperture, sensor)
- **Ray optics** — modeling light as straight-line rays, ignoring wave effects — the assumption behind pinhole-camera geometry (HW1).
- **Aperture** — the opening controlling how much light enters a lens; analogous to the iris/pupil.
- **f-number** — ratio of focal length to aperture diameter; smaller means more light and shallower depth of field.
- **Depth of field** — the range of distances that appear acceptably in focus at once.
- **Exposure** — total light collected, set by aperture, exposure time, and ISO together.
- **Sensor** — the chip converting incident light into an electrical signal — the camera's "retina."
- **Shot noise / read noise** — shot noise: fundamental randomness in photon arrival counts. Read noise: added by the sensor's own readout electronics.
- **ISO** — a sensor gain setting that amplifies signal (and noise) without collecting more light.

## Week 3 — Digital Photography II (ISP, demosaicking, deconvolution)
- **ISP** — the image signal processor pipeline (demosaic, denoise, color-correct) turning raw sensor output into a viewable photo.
- **Demosaicking** — reconstructing full color from a sensor where each pixel measured only one channel.
- **Bayer pattern** — the common repeating RGGB color-filter mosaic on most camera sensors.
- **Denoising** — computationally removing sensor noise after capture.
- **Deconvolution** — computationally undoing a known blur — a first taste of an inverse problem (Week 6).

## Week 4 — Great Ideas in Computational Photography
- **HDR imaging** — combining multiple exposures to represent a wider brightness range than one shot could.
- **Tone mapping** — compressing an HDR image into the range a normal display/print can show.
- **Coded aperture** — a specially patterned mask, co-designed with a recovery algorithm, replacing a plain circular aperture.
- **Flutter shutter** — opening/closing the shutter in a coded temporal pattern during one exposure to make motion blur easier to invert.

## Week 5 — Sampling, Linear Systems, Deconvolution
- **DFT / FFT** — converts an image from pixel-brightness representation to spatial-frequency representation; FFT is the efficient algorithm for computing it.
- **Aliasing** — distortion from sampling below a signal's true frequency content (e.g. moiré).
- **Nyquist rate** — the minimum sampling rate needed to avoid aliasing for a given highest frequency present.
- **Diffraction** — bending/spreading of light through small openings — limits how sharply any lens or pinhole can focus.
- **PSF (point spread function)** — how a single point of light gets smeared by an imaging system.
- **Wiener filter** — a statistically optimal deconvolution method that accounts for noise.

## Week 6 — Regularized Inverse Problems with ADMM
- **Inverse problem** — recovering an unknown true signal from indirect or corrupted measurements.
- **Natural image prior / regularization** — assumptions about what real images typically look like, used to make an ill-posed inverse problem solvable.
- **ADMM** — an optimization algorithm splitting a hard joint problem into easier alternating sub-steps.
- **Single-pixel imaging** — reconstructing a full image from many single-value measurements plus known coded illumination patterns.

## Week 9 — Light Field Imaging
- **Plenoptic function** — a theoretical function describing light intensity in every direction, at every point in space, wavelength, and time.
- **Light field** — a practical capture of many directional rays, often via camera arrays or microlens arrays.
- **Light field / 3D display** — a display reproducing different images per viewing angle — one proposed fix for VAC (Week 1, §16).

## Weeks 10–12 — Foundation Models, Neural Rendering, Black Hole Imaging
*(advanced/guest-lecture topics — brief pointers only until covered in detail)*
- **Foundation model** — a large, general-purpose pretrained network adapted to imaging tasks, rather than trained from scratch per task.
- **Neural rendering** — using neural networks, rather than a traditional graphics pipeline, to synthesize or reconstruct images/3D scenes.
