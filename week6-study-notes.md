# CSC2529 Computational Imaging — Week 6 Study Notes

**Topic:** Solving Regularized Inverse Problems with ADMM — a Bayesian view of where the objective comes from, image priors (smoothness, sparsity, total variation), the Adam solver, constrained optimization (Lagrange multipliers, augmented Lagrangian), ADMM and its proximal steps (soft thresholding, denoisers as priors), half-quadratic splitting, the conjugate gradient method, and compressive imaging (single-pixel imaging, CT, MRI, hyperspectral).
**Source:** Lecture 6 slides (D. Lindell, CSC2529, Fall 2026); Problem Session 5 ("PS5," the HW5 problem session), all three tasks: Task 1 deconvolution with Adam and TV, Task 2 deconvolution with ADMM (TV and DnCNN priors), Task 3 single-pixel imaging (least norm via CG, ADMM + TV, ADMM + DnCNN).
**HW5 supplements:** §8–§9, §11–§12, §19–§26 go deeper than the slides because HW5 depends on them: image gradients as Fourier-domain filters and the [2, M, N] stacking, anisotropic vs. isotropic TV and why `torch.sqrt` breaks at 0, how Adam scales its steps, the x-update derived line by line and turned into Fourier-domain multiplications, why the denominator can be computed once, the soft-thresholding formulas the starter code uses, the noise level a denoiser is asked to remove, the least-norm solution and the conjugate gradient method with SciPy's `LinearOperator`, and the unrolled HQS idea behind the bonus. They explain each method and the quantities it needs, but never compute the assignment's own answers (no PSNR values for HW5's images appear here).
**Ties to earlier weeks, restated here.** This lecture builds directly on Week 5: deconvolution, the inverse and Wiener filters, the convolution matrix and its transpose, least squares, Tikhonov regularization, gradient descent and subgradients (Week 5 §22–§31). Each idea is restated briefly where it is used, so this file can be read on its own.
**Order differs from the slides.** The lecture presents the ADMM algorithm before saying how its pieces are solved, and introduces Lagrange multipliers without the calculus behind them. These notes put a short primer before each new tool: probability before the Bayesian view, norms before priors, finite differences before total variation, Lagrange multipliers before the augmented Lagrangian, and the proximal operator before soft thresholding. The single-pixel camera's least-norm solution is derived with the same Lagrange-multiplier tool. Each section ends with a **Summary** box; forward pointers appear only there.
**Scope:** Announcements, the overview slides and the references slide are skipped. The course notes the slides point to ("Image Deconvolution with ADMM," "Compressive Imaging") are not summarized separately; everything HW5 needs from them is built here.

---

# Part 1 — The Problem, Restated

## 1. Orientation: What This Week Adds

Week 5 ended with a problem: undoing blur is **ill-posed**, which in plain words means "the question has no single trustworthy answer": many sharp images explain the same blurry photo, and dividing by small numbers amplifies noise. The Wiener filter helped by damping noisy frequencies, but its results were "not too bad, but noisy." This week's answer has two halves:

1. **A better description of a good answer.** Write down, as a formula, what real images tend to look like (a **prior**, literally "what you believe *before* looking at the data"), and look for the image that both explains the measurement and looks like a real image.
2. **Better ways to find that image.** Two general-purpose **solvers** (step-by-step search procedures that home in on the best image), Adam and ADMM, that work for almost any measurement process, not just blur.

The lecture then applies the same tools to a camera with a single pixel, to show that one recipe covers very different imaging problems ("if you can solve this, you can solve anything").

**Three words in this week mean more than one thing.** Each section says which meaning it uses.

| Word | Meaning 1 | Meaning 2 |
|---|---|---|
| **gradient** | **image gradient**: how fast brightness changes from one pixel to the next, across space (computed by finite differences, §8; HW5's `grad_fn`) | **objective gradient** ∇: the vector of partial derivatives of a cost with respect to every unknown pixel value (what gradient descent and PyTorch's `.backward()` compute, §11) |
| **y** | the vertical image direction (as in *D_y*, the vertical difference) | the Lagrange multiplier vector (§14–§16); the lecture uses *y* for both |
| **N** | number of unknown pixel values (lecture) | number of *measurements* (HW5 Task 3 starter code's variable `N`) |

**Symbols this week.**

| Symbol | Meaning in this file |
|---|---|
| **x** | the unknown image, flattened into a column of *N* numbers |
| **b** | the measurements, *M* numbers |
| **A** | the *M*×*N* matrix that models image formation (any process) |
| **C**, *c* | the convolution (blur) matrix and its kernel, when the process is a blur; **C** is *N*×*N* |
| **η** (eta) | the noise added to the measurements |
| σ | the noise's standard deviation |
| Ψ(**x**) | the **regularizer** (prior), a number that is small for plausible images; some slides write Γ |
| λ | the **regularization weight**: how much the prior counts |
| **D** = [**D**_x; **D**_y] | finite-difference (image-gradient) operator, horizontal and vertical stacked (§8) |
| **z**, **u** | ADMM's split variable and scaled dual variable (§15–§17) |
| ρ (rho) | ADMM's **penalty parameter** (§15) |
| κ (kappa) | the soft-threshold level, κ = λ/ρ (§19) |
| 𝒟 (calligraphic D) | a denoiser, such as DnCNN (§21); not the matrix **D** |
| F, F⁻¹ | the 2D discrete Fourier transform (computed with the FFT) and its inverse |

**Frequency, this week.** Every Fourier formula here acts on the stored pixel grid, so "frequency" always means **image frequency** in cycles per pixel (Week 5 §1). §27 (LiDAR) works with *time* (round-trip delays measured in nanoseconds), not with any frequency.

> **Summary**
> - Week 5 showed deconvolution is ill-posed; Week 6 adds **priors** (what real images look like) and **solvers** (Adam, ADMM) that combine them with any measurement process.
> - "Gradient," "*y*" and "*N*" each mean two things this week; the table above says which is which.
> - Next: a short restatement of the deconvolution problem the lecture starts from (§2).

---

## 2. Deconvolution, Briefly Restated

**The forward model (slide 7).** A camera with blur records

```
b = c ∗ x + η
```

| Symbol | Meaning (slide 7) | Who sets it |
|---|---|---|
| *b* | the 2D measurement (blurry, noisy photo) | measured |
| *c* | the known 2D convolution kernel (the PSF, Week 5 §12) | known (non-blind) |
| ∗ | convolution (Week 5 §5.1): every pixel is replaced by a weighted sum of its neighbors | — |
| *x* | the 2D sharp target image | unknown |
| η | additive noise | random |

**Two equivalent ways to write the same blur (slide 14).** The **signal-processing** form uses the convolution theorem: convolution becomes multiplication of spectra, *b* = F⁻¹{F{*c*}·F{*x*}} + η. The **algebraic** form flattens the image into a vector and writes the blur as a matrix: **b** = **C x** + **η**, with **C** an *N*×*N* matrix. Both say the same thing. This week moves back and forth between them constantly, using three facts from Week 5:

| Matrix form | Fourier form (one image frequency at a time) | Why |
|---|---|---|
| **C x** | F{*c*} · F{*x*} | convolution theorem (Week 5 §5.2) |
| **C**ᵀ**x** (transpose) | F{*c*}\* · F{*x*} (complex conjugate) | the transpose of a blur is the blur with the flipped kernel, and flipping a real kernel conjugates its spectrum (Week 5 §31.2) |
| **C**ᵀ**C x** | \|F{*c*}\|² · F{*x*} | apply both in turn: F{*c*}\*·F{*c*} = \|F{*c*}\|² |

PS5 states the middle row as "conjugation in Fourier domain = time-reversal (matrix transpose) in spatial domain." The matrix **C** is called **circulant** (from "circle"): the FFT assumes the image wraps around at its edges like a loop (Week 5 §10.3), so every row of **C** is the previous row shifted along by one, with whatever falls off the end coming back at the start.

**Plain-language glosses for the table.** The **transpose** **C**ᵀ is the matrix flipped across its diagonal (rows become columns); for a blur it means "spread the light back the way it came." The **complex conjugate** F{*c*}\* of a Fourier coefficient keeps its size and flips the sign of its phase (its shift); in pictures, it mirrors the arrow of Week 5 §2.2 top-to-bottom. Flipping a kernel left-to-right in space does exactly that to every coefficient.

**Week 5's two direct fixes (slides 10–16).**

```
inverse filter:   x̃_if = F⁻¹{ F{b} / F{c} }
Wiener filter:    x̃_wf = F⁻¹{ |F{c}|² / (|F{c}|² + 1/SNR) · F{b} / F{c} }
```

The inverse filter divides by numbers near zero and turns noise into garbage. Wiener damps (turns down) the frequencies where the **signal-to-noise ratio** (SNR: how strong the real picture is compared with the noise, at that frequency) is low, which keeps noise under control but leaves the result blurry and still noisy (slide 16, at noise σ = 0.1).

**The real problem (slide 17).** Deconvolution is **ill-posed**: "there are infinitely many solutions that satisfy the measurements." We "need some way to determine how 'desirable' any one of these feasible solutions is → need an image **prior**."

> **Summary**
> - Forward model: **b = c ∗ x + η**, equivalently **b = C x + η** with a circulant matrix **C**.
> - Rule to remember: **C x ↔ F{c}·F{x}**, **Cᵀ x ↔ F{c}\*·F{x}**, **CᵀC x ↔ |F{c}|²·F{x}**.
> - Inverse filtering amplifies noise; Wiener is better but noisy. Both lack a description of what a real image looks like.
> - Next: where such a description enters the math, through probability (§3–§5).

---

# Part 2 — Where the Objective Comes From: the Bayesian View

## 3. A Probability Primer

The lecture's "Bayesian perspective" (slides 19–31) explains *why* the objective we will minimize has the shape it has. It needs five pieces of probability, each built here from scratch.

**Random variable.** A quantity whose value is not fixed in advance, but follows a pattern over many repetitions. The noise η in one pixel is one: every photo gets a different value, but the values cluster around zero with a typical size σ.

**Probability density, p(·).** For a quantity that can take any real value, *p*(*t*) says how likely values near *t* are, per unit of *t*. Higher *p* means more likely. (A density can be larger than 1; only the area under it, over any range, is a probability.)

**The Gaussian (normal) density.** *Analogy:* the shape of a pile of sand poured from one spot: tallest in the middle, falling off smoothly and symmetrically.

```
p(t) = 1/√(2πσ²) · exp( −(t − μ)² / (2σ²) )          written t ∼ 𝒩(μ, σ²)
```

| Term | Meaning |
|---|---|
| μ (mu) | the mean: where the peak sits |
| σ | the standard deviation: the width; σ² is the **variance** |
| (*t* − μ)² / (2σ²) | how many "widths" *t* is from the peak, squared and halved |
| exp(−…) | turns "far from the peak" into "small probability," falling off very fast |
| 1/√(2πσ²) | a constant that makes the total area 1 |
| ∼ | "is distributed as" |

The one feature to remember: **the exponent is a squared distance.** That is where squared errors will come from.

**Conditional density, p(b | x).** Read "the density of *b* **given** *x*": how likely each measurement is if we assume the true image is **x**. The vertical bar means "assuming."

**Independence → multiply.** If two random quantities do not influence each other (the noise in pixel 1 says nothing about the noise in pixel 2), the probability of both outcomes together is the product of their separate probabilities. *Analogy:* two fair coins both landing heads: ½ × ½ = ¼.

**Proportional to, ∝.** "*p* ∝ *q*" means *p* = (some constant) × *q*, where the constant does not depend on the variable we care about. Constants never change *where* a maximum or minimum is, so we can drop them.

> **Summary**
> - A **density** *p*(*t*) ranks how likely each value is; *p*(*b* | *x*) ranks measurements assuming a particular true image.
> - Rule to remember: the Gaussian 𝒩(μ, σ²) is **exp(−(t − μ)²/(2σ²))** up to a constant; its exponent is a squared distance.
> - Independent events **multiply**; constants (∝) can be dropped when looking for a best value.
> - Next: apply this to the measurement noise (§4).

---

## 4. The Likelihood: How Well Does an Image Explain the Data?

**Treat everything as random (slides 20–21).** The image formation model is **b** = **A x** + **η**, with **b** ∈ ℝ^*M*, **x** ∈ ℝ^*N*, **A** ∈ ℝ^(*M*×*N*). (ℝ^*M* means "a list of *M* real numbers.") Assume each noise value is Gaussian with mean 0 and variance σ²:

```
η_i ∼ 𝒩(0, σ²)          so          b_i ∼ 𝒩( (A x)_i , σ² )
```

*In words:* if the true image is **x**, measurement *i* lands near its noise-free prediction (**A x**)_*i*, spread out by the noise. Subscript *i* means "entry *i* of."

**One measurement (slides 22–23).**

```
p(b_i | x, σ) = 1/√(2πσ²) · exp( −(b_i − (A x)_i)² / (2σ²) )
```

**All measurements together (slides 24–25).** The noise in each measurement is independent, so multiply, and the product of exponentials is the exponential of a sum:

```
p(b | x, σ) = Π_{i=1}^{M} p(b_i | x, σ)  ∝  exp( −Σ_i (b_i − (A x)_i)² / (2σ²) )  =  exp( −‖b − A x‖₂² / (2σ²) )
```

Π means "multiply over *i* = 1 … *M*," the product counterpart of Σ. ‖**v**‖₂² = Σ_i *v_i*² is the squared ℓ₂ norm (Week 5 §29). This function of **x** is called the **likelihood**: it scores how well a candidate image explains the measured data.

> **Worked example (one pixel, noise σ = 0.1, measured b = 0.5).** Compare three candidate images whose predictions (**A x**)_*i* are 0.5, 0.6 and 0.8. Divide each likelihood by the best one so the constant cancels:
>
> | prediction | miss | squared miss / (2σ²) | relative likelihood exp(−…) |
> |---|---|---|---|
> | 0.5 | 0 | 0 | 1 |
> | 0.6 | 0.1 (one σ) | 0.5 | 0.61 |
> | 0.8 | 0.3 (three σ) | 4.5 | 0.011 |
>
> A miss of one noise width is entirely plausible; a miss of three widths is about 90 times less likely. The likelihood prefers images that reproduce the data to within the noise.

> **Same concept, different names.** The **likelihood** *p*(**b** | **x**) = the **image formation model** in probabilistic form (slide 27 labels it that way) = the **data model** / **noise model**. Its negative logarithm is the **data term** = **data fidelity term** = **data-consistency term** = **loss** of Week 5 §29.

> **Summary**
> - Gaussian noise makes each measurement *b_i* ∼ 𝒩((**A x**)_*i*, σ²).
> - Rule to remember: **p(b | x) ∝ exp(−‖b − A x‖₂² / (2σ²))**, the likelihood.
> - Maximizing it alone is least squares, which for an ill-posed problem has many (or wildly noisy) answers.
> - Next: add a belief about what images look like, with Bayes' rule (§5).

---

## 5. Bayes' Rule, the Prior, and the MAP Estimate

**The question flips.** The likelihood answers "given the image, how likely is this data?" We want the reverse: "given this data, how likely is each image?" **Bayes' rule** turns one into the other (slides 26–27):

```
p(x | b, σ) = p(b | x, σ) · p(x) / p(b)   ∝   p(b | x, σ) · p(x)
               posterior     likelihood   prior
```

| Term | Name (slide 27) | Meaning |
|---|---|---|
| *p*(**x** \| **b**, σ) | **posterior** (Latin for "coming after") | how plausible image **x** is *after* seeing the data |
| *p*(**b** \| **x**, σ) | likelihood = "image formation model" | how well **x** explains the data (§4) |
| *p*(**x**) | **prior** ("coming before") | how plausible **x** is as an image, *before* any data: real photos are likely, TV static is not |
| *p*(**b**) | **evidence** | how likely this data was overall, averaged over every possible image; the same number whichever **x** we test, so it is a dropped constant (∝) |

*Analogy:* a doctor's diagnosis. The symptoms (data) fit both a cold and a rare disease equally well (likelihood). Colds are far more common (prior), so the doctor's best guess (posterior) is a cold.

**The best single image: MAP (slides 28–30).** The **maximum-a-posteriori (MAP)** estimate is the image with the highest posterior. Three moves turn it into something we can compute:

1. **Take −log.** The logarithm only ever increases, so the image that maximizes *p* also maximizes log *p*, and minimizes −log *p*. Logs turn products into sums, which are easier to differentiate and avoid multiplying millions of tiny numbers.
2. **Split the product.** log(*p*(**b**|**x**)·*p*(**x**)) = log *p*(**b**|**x**) + log *p*(**x**).
3. **Insert the Gaussian.** −log *p*(**b** | **x**) = ‖**b** − **A x**‖₂²/(2σ²) + (a constant).

```
x_MAP = argmin_x  −log p(x | b, σ)
      = argmin_x  −log p(b | x, σ) − log p(x)
      = argmin_x  (1/(2σ²)) ‖b − A x‖₂²  +  Ψ(x)          with  Ψ(x) = −log p(x)
```

**argmin** means "the value of **x** that makes the following expression smallest" (the minimum *location*, not the minimum value).

**Terminology (slide 31).** (1/(2σ²))‖**b** − **A x**‖₂² is the **data fidelity term**; Ψ(**x**) is the **regularization term**. "Regularizer" and "prior" name the same object from two angles: Ψ = −log *p*(**x**).

> **Same concept, different names.** **Prior** *p*(**x**) ↔ **regularizer** = **regularization term** = **image prior** = **penalty**, Ψ(**x**) = −log *p*(**x**) (some slides write Γ(**x**)). **MAP estimate** = **maximum a posteriori** ("the most likely, after seeing the data") = **posterior mode** ("mode" = the most common value, the peak of the distribution). **Data fidelity term** = data term (§4).

**Where λ comes from.** Multiply the whole objective by σ² (a positive constant, so the minimizer does not move):

```
argmin_x  ½ ‖b − A x‖₂²  +  σ² Ψ(x)
```

The slides' general form (slide 48) writes the weight as λ:

```
minimize_x   ½ ‖b − A x‖₂²  +  λ Ψ(x)
```

So λ plays the role of σ² times the prior's own strength. **More noise → larger λ → trust the prior more.** That is the intuition to carry: λ is a dial between "believe the data" (small λ) and "believe what images usually look like" (large λ).

> **Worked example (one pixel, a Gaussian prior gives Week 5's Tikhonov).** Measure *b* = *x* + η with σ = 0.1, and suppose prior knowledge says pixel values cluster around 0 with spread τ = 0.2, i.e. *x* ∼ 𝒩(0, τ²), so Ψ(*x*) = *x*²/(2τ²). The objective (1/(2σ²))(*b* − *x*)² + *x*²/(2τ²) has derivative −(*b* − *x*)/σ² + *x*/τ²; setting it to zero gives
>
> *x*_MAP = *b* · τ²/(τ² + σ²) = *b* · 0.04/0.05 = **0.8 *b***.
>
> For *b* = 1, *x*_MAP = 0.8: the prior pulls the estimate 20% toward its own favorite value. Written as ½(*b* − *x*)² + (λ/2)*x*², this is Week 5's **Tikhonov regularization** ("fit the data, but prefer small values") with λ = σ²/τ² = 0.25. A **Gaussian prior is Tikhonov regularization**; Wiener deconvolution is the same idea, frequency by frequency (Week 5 §30).

> **Summary**
> - **Bayes' rule:** posterior ∝ likelihood × prior.
> - Rule to remember: **x_MAP = argmin ½‖b − Ax‖₂² + λΨ(x)**, with **Ψ = −log p(x)**; λ grows with the noise.
> - The data term comes from Gaussian noise; the regularizer comes from what we believe images look like.
> - A Gaussian prior gives Tikhonov (and Wiener). Better priors need other Ψ, built in Part 3.
> - Next: the measuring sticks (norms) that priors are made of (§6).

---

# Part 3 — Image Priors

## 6. Norms and Why ℓ₁ Produces Zeros

A **norm** measures the size of a vector. Priors are built from them, and the choice of norm changes the character of the answer completely.

| Norm | Formula | Name | Size measured as |
|---|---|---|---|
| ℓ₂ | ‖**v**‖₂ = √(Σ *v_i*²) | Euclidean | straight-line length |
| ℓ₁ | ‖**v**‖₁ = Σ \|*v_i*\| | Manhattan / taxicab (Week 5 §31.3) | blocks walked on a grid |
| "ℓ₀" | number of nonzero entries | counting "norm" (not a true norm) | how many entries are used |

A vector is **sparse** ("thinly scattered") if most of its entries are exactly zero (small ℓ₀): a few meaningful values scattered among zeros. Sparsity is what the best priors ask for, but counting nonzeros is nearly impossible to optimize directly: the count jumps in whole steps, so it has no slope to follow, and finding the best set of entries to keep means trying out enormous numbers of combinations. The ℓ₁ norm is the practical substitute, for a geometric reason.

**What a "norm" is, in plain words.** A rule that turns a list of numbers into one "size" that is never negative, is zero only for the all-zero list, doubles when every entry doubles, and obeys the triangle inequality (going via a detour is never shorter).

**Why ℓ₁ favors sparse answers.** Week 5 §30 solved *x*₁ + 2*x*₂ = 5 (one equation, two unknowns) by picking the solution of smallest ℓ₂ norm. Do the same with ℓ₁:

> **Worked example (smallest ℓ₂ vs. smallest ℓ₁ on the line x₁ + 2x₂ = 5).**
>
> | Candidate on the line | ℓ₂ norm | ℓ₁ norm | zeros |
> |---|---|---|---|
> | (1, 2) | **2.236** (smallest ℓ₂) | 3.0 | none |
> | (0, 2.5) | 2.5 | **2.5** (smallest ℓ₁) | one |
> | (5, 0) | 5.0 | 5.0 | one |
>
> The smallest-ℓ₂ answer spreads the value over both entries. The smallest-ℓ₁ answer puts everything into one entry and sets the other to exactly zero.

**The picture behind it.** Grow a "ball" of all vectors with norm ≤ *r* until it first touches the line of solutions. The ℓ₂ ball is a circle, smooth everywhere, so it touches the line at a generic point with both coordinates nonzero. The ℓ₁ ball is a diamond with corners on the axes; a line almost always touches it first at a corner, where one coordinate is exactly zero. In many dimensions the ℓ₁ ball has very many sharp corners and edges, all lying where some coordinates are zero, so ℓ₁ answers have many exact zeros.

**The prior behind each norm (Ψ = −log *p*).** Penalizing *t*² corresponds to a Gaussian prior (§5): every value is pulled toward 0 in proportion to its size, so small values are shrunk but rarely made exactly 0. Penalizing |*t*| corresponds to the **Laplace distribution**, *p*(*t*) ∝ exp(−|*t*|/β) (β sets its width): a sharper peak at 0 *and* **heavier tails**. "Tails" are the far-left and far-right ends of the curve, the large values; "heavy" tails fall off slowly, so large values stay reasonably likely instead of becoming practically impossible as under a Gaussian. It says "most values are exactly or nearly zero, but a few can be large." That is exactly the statistics of an image's gradients (§9).

| Penalty | Pull toward 0 on a value of size *t* | Effect on small values | Effect on large values |
|---|---|---|---|
| ½*t*² (ℓ₂²) | proportional to *t* (weak when *t* is small) | shrunk, almost never exactly 0 | punished very hard (squared) |
| \|*t*\| (ℓ₁) | constant, the same for any *t* ≠ 0 | pushed all the way to 0 | punished only proportionally, so allowed |

> **Summary**
> - ℓ₂ = length, ℓ₁ = sum of absolute values, "ℓ₀" = count of nonzeros. **Sparse** = mostly exact zeros.
> - Rule to remember: **minimizing ℓ₁ gives sparse answers** (the diamond touches at a corner); minimizing ℓ₂ spreads values out.
> - ℓ₂² ↔ Gaussian prior; ℓ₁ ↔ Laplace prior (sharp peak at 0, heavy tails).
> - Next: three priors built from these norms (§7).

---

## 7. Three Example Priors

Slides 33–38 match three kinds of images to three regularizers.

**1. "Blurry stuff" → promote smoothness: Ψ(**x**) = ‖Δ**x**‖₂** (slide 38's form; in practice it is usually squared, ‖Δ**x**‖₂², which favors the same smooth images and is easier to minimize; the rest of this section uses the squared form). The **Laplace operator** Δ (the **Laplacian**) measures how much a pixel differs from the average of its neighbors, i.e. local **curvature**: how much the brightness surface *bends* there. A flat floor or a straight ramp does not bend (curvature 0); the top of a bump or the lip of a step bends sharply. In discrete form it is a convolution with the kernel

```
 0   1   0
 1  −4   1
 0   1   0
```

It is zero on flat regions and on straight ramps, large at bumps, spikes and edges. Penalizing its square says "the image bends gently everywhere." Good for images that really are smooth; bad for photos, because it also smooths away edges.

**2. "Stars" → promote sparsity: Ψ(**x**) = ‖**x**‖₁.** A night-sky image is almost all black with a few bright points: the pixel values themselves are sparse. The ℓ₁ norm (§6) prefers exactly that.

**3. "Natural" images → promote sparse gradients: Ψ(**x**) = TV(**x**).** A typical photo is not sparse (few pixels are black) and not smooth (it has sharp edges). But its **image gradients** (the changes from one pixel to the next) are sparse: most neighboring pixels are nearly equal, and a few, along object edges, differ a lot. The **total variation** (TV) regularizer applies the ℓ₁ norm to image gradients. It needs two building blocks, finite differences (§8) and the TV formulas (§9).

| Image type | What is sparse or small | Regularizer Ψ(**x**) | Corresponding belief |
|---|---|---|---|
| blurry stuff | curvature | ‖Δ**x**‖₂² | "smooth everywhere" |
| stars | pixel values | ‖**x**‖₁ | "mostly black" |
| natural photo | image gradients | TV(**x**) | "flat regions separated by sharp edges" |

> **Summary**
> - A prior encodes "what is small or sparse" in a given kind of image.
> - Rule to remember: **smooth → ‖Δx‖₂²; sparse pixels → ‖x‖₁; natural photos → TV(x), sparse image gradients.**
> - Next: how to compute an image gradient, as a convolution (§8).

---

## 8. Image Gradients by Finite Differences (supports HW5 Task 1 and Task 2)

**The problem it solves.** We need "how much does brightness change between neighboring pixels?" for every pixel, as a linear operation we can put into matrices and the Fourier domain. (In this section "gradient" always means **image gradient**, the spatial change in brightness, not the objective gradient.)

**Forward difference.** The horizontal change at pixel (row *r*, column *s*) is the next pixel to the right minus this one; the vertical change is the pixel below minus this one:

```
(D_x x)[r, s] = x[r, s+1] − x[r, s]          (D_y x)[r, s] = x[r+1, s] − x[r, s]
```

*Analogy:* the slope of a staircase measured one step at a time.

**As a convolution (slide 40; PS5 slide 5).** Each difference is a tiny kernel slid across the image. Written as 3×3 kernels, the lecture uses

```
d_x =  0  0  0          d_y =  0  1  0
       1 −1  0                 0 −1  0
       0  0  0                 0  0  0
```

and PS5 writes d_x with the 1 on the *right*: [0 0 0; 0 −1 1; 0 0 0]. Both describe the same forward difference. They differ only in convention: true **convolution** flips the kernel before sliding it (Week 5 §5.1), so a kernel written for convolution looks mirrored compared with one written as a "multiply-and-sum template" slid without flipping (**cross-correlation**). Whichever convention a piece of code uses, the result is "next pixel minus this pixel" (up to a sign, which TV ignores because it takes absolute values). HW5's starter code stores the kernels as `dx = [[-1, 1]]` and `dy = [[-1], [1]]` and converts them with `psf2otf`.

**In the Fourier domain (PS5 slide 6).** Because a difference is a convolution, the convolution theorem applies, exactly as for the blur in §2:

```
D_x x  =  F⁻¹{ F{d_x} · F{x} }          D_y x  =  F⁻¹{ F{d_y} · F{x} }
```

`psf2otf(dx, shape)` pads the small kernel to the image size, centers it so that its "this pixel" tap sits at position (0, 0) (otherwise the output would shift), and returns F{*d_x*}, the kernel's **OTF** (optical transfer function: the Fourier transform of a kernel, Week 4 §18). The FFT treats the image as wrapping around, so the last column's "next pixel to the right" is the first column (the **circular** or **periodic** boundary: as if the image were printed on a tube, or tiled endlessly like wallpaper).

> **Worked example (a 4×4 image with one vertical edge).**
>
> ```
> x =  0 0 1 1          D_x x =  0 1 0 −1          D_y x = all zeros
>      0 0 1 1                   0 1 0 −1
>      0 0 1 1                   0 1 0 −1
>      0 0 1 1                   0 1 0 −1
> ```
>
> Column 2 of D_x is 1: the jump from dark to bright. Column 4 is −1: the wrap-around "edge" from the last column (bright) back to the first (dark), which is not in the scene at all. Wrap-around boundaries create fake edges where the image's left and right (or top and bottom) borders differ. Every row is identical, so the vertical differences are all zero: the image does not change going down.

**Stacking both directions (slide 76; HW5 Task 2).** The full gradient operator puts the two difference images on top of each other:

```
D = [ D_x ]          D ∈ ℝ^(2N × N):  N pixels in, 2N numbers out
    [ D_y ]
```

HW5 stores **D x** as an array of shape [2, M, N], horizontal differences in slot 0 and vertical in slot 1 (here M×N is the image's height × width). The z-update the starter code already provides indexes it that way, so `grad_fn` must return exactly that shape (HW5 Task 2.1).

**The transpose Dᵀ.** The x-update (§20) needs **D**ᵀ, the **transpose** (also called the **adjoint**: the operation that sends each difference back onto the two pixels it was computed from). For a convolution, the transpose is convolution with the flipped kernel (Week 5 §31.2), which in the Fourier domain is the conjugate: **D**_xᵀ ↔ F{*d_x*}\* (PS5 slide 9: "[D_xᵀ D_yᵀ] in the Fourier domain"). In pixel terms, for the 1D forward difference with wrap-around,

```
(Dᵀ w)[i] = w[i−1] − w[i]          (minus the backward difference)
```

> **Worked example (Dᵀ on 5 samples, wrap-around).** The forward-difference matrix **D** has −1 on the diagonal and +1 just right of it (wrapping). Its transpose applied to a spike *w* = [0, 0, 1, 0, 0] gives [0, 0, −1, 1, 0]: the kernel reversed, as expected. HW5 Task 3's `finite_differences.py` implements exactly this as `opDtx` (`-diffx + np.roll(diffx, 1)`), next to `opDx` for **D**.

**DᵀD is a (negative) Laplacian.** Multiplying out for the 1D case gives a matrix with 2 on the diagonal and −1 on each side: the kernel [−1, 2, −1], which is minus the 1D Laplacian of §7. In the Fourier domain it is |F{*d_x*}|², which equals 4 sin²(π*k*/*N*) at image-frequency index *k* of an *N*-sample row:

> **Worked example (|F{d_x}|² on an 8-pixel row).** At frequency indices *k* = 0 … 7: 0, 0.59, 2, 3.41, **4**, 3.41, 2, 0.59. It is 0 at *k* = 0 (a constant image has no gradient) and largest, 4, at *k* = 4, the fastest alternation (0.5 cycles/pixel, the Nyquist frequency of Week 5 §8.1), where neighbors differ by twice the amplitude. **DᵀD is a high-pass filter** (it lets fast, fine-detail frequencies through and blocks slow ones, Week 5 §5.4): it measures how much fine detail an image has. This shape reappears in the x-update (§20).

> **Same concept, different names.** **Finite difference** = **discrete derivative** = **image gradient** (when both directions are stacked) = the **gradient operator D** (slides) = `grad_fn` (HW5 Task 1–2) = `opDx` (HW5 Task 3). Its transpose **D**ᵀ = `opDtx` = the **adjoint** of the gradient = minus the **discrete divergence** ("divergence" measures how much a field of arrows spreads outward from a point, like water from a spring).

> **Summary**
> - Image gradient = **next pixel − this pixel**, horizontally (**D**_x) and vertically (**D**_y); both are convolutions with 2-tap kernels.
> - Rule to remember: **D_x x = F⁻¹{F{d_x}·F{x}}**; the transpose uses **F{d_x}\***; **DᵀD ↔ |F{d_x}|² + |F{d_y}|²**, a high-pass filter.
> - HW5 stacks the two difference images as shape **[2, M, N]**. The FFT's wrap-around adds a fake edge at the borders.
> - Next: turning these differences into one number that measures "how edgy" an image is (§9).

---

## 9. Total Variation (supports HW5 Task 1)

**The problem it solves.** We want a single number Ψ(**x**) that is small for "flat regions separated by sharp edges" and large for noise. *Analogy:* hiking. The total variation of a route is the total climb plus total descent. A route with one cliff and flat plains has a modest total; a route over constant small bumps (noise) piles up a large total.

**Evidence (slides 41–42).** The gradient-magnitude images of the parrots are "mostly black, indicating that gradient magnitudes are close to 0 → natural images have sparse gradients!"

**Two words first, in plain terms.** **Isotropic** comes from Greek *iso* = "same" and *tropos* = "direction": it means "behaves the same in every direction." A round ball is isotropic; it looks the same whichever way you turn it. **Anisotropic** (*an-* = "not") means "direction matters": wood is anisotropic, because it splits easily along the grain and hardly at all across it. For TV, the question is whether an edge costs the same no matter which way it is turned (isotropic) or whether some orientations cost more (anisotropic).

**The two versions (slide 45; PS5 slide 5).** At each pixel *i* there are two differences, (**D**_x**x**)_*i* and (**D**_y**x**)_*i*. TV combines them into a size, then adds over all *N* pixels:

```
TV_anisotropic(x) = ‖D_x x‖₁ + ‖D_y x‖₁ = Σ_{i=1}^{N} ( |(D_x x)_i| + |(D_y x)_i| )

TV_isotropic(x)   = ‖D x‖₂,₁           = Σ_{i=1}^{N} √( (D_x x)_i² + (D_y x)_i² )
```

| Term | Meaning |
|---|---|
| (**D**_x**x**)_*i*, (**D**_y**x**)_*i* | horizontal and vertical brightness change at pixel *i* (§8) |
| \|·\| | absolute value: the size of a change, ignoring direction |
| √(*a*² + *b*²) | the length of the 2D arrow (*a*, *b*): the gradient's magnitude, by Pythagoras |
| Σ over *i* | add the per-pixel sizes over the whole image: an ℓ₁-type sum, which makes most of them want to be exactly zero (§6) |
| ‖·‖₂,₁ | "ℓ₂ inside, ℓ₁ outside": take the ℓ₂ length of each pixel's 2-vector, then the ℓ₁ sum of those lengths |

**The difference between them: direction.** Anisotropic TV measures the gradient arrow like a taxi on a grid (east-west blocks plus north-south blocks); isotropic TV measures its true length.

> **Worked example (one pixel).** Differences (**D**_x**x**, **D**_y**x**) = (3, 4). Anisotropic: 3 + 4 = **7**. Isotropic: √(9 + 16) = **5**.
>
> Now an edge of the same strength in two orientations: a gradient of length 1 pointing horizontally, (1, 0), gives 1 for both versions. The same edge rotated 45°, (0.707, 0.707), gives isotropic 1 but anisotropic 1.414. **Anisotropic TV charges diagonal edges up to √2 ≈ 1.41× more than horizontal or vertical ones**, so it prefers to reshape diagonal edges into horizontal and vertical stair-steps. "Isotropic" means "the same in every direction": it does not care how an edge is oriented. That is why slide 41 labels it "better: isotropic" and the other "easier: anisotropic" (easier because each term involves only one difference).

> **Worked example (why TV keeps edges and smoothness priors do not).** Three 1D brightness profiles, all going from 0 to 1 (or wiggling), and two penalties on their differences:
>
> | Profile | Values | TV = Σ\|differences\| | quadratic Σ(differences)² |
> |---|---|---|---|
> | sharp step | 0, 0, 0, 1, 1, 1, 1 | **1.0** | 1.0 |
> | soft ramp | 0, 0.25, 0.5, 0.75, 1, 1, 1 | **1.0** | 0.25 |
> | noise | 0, 0.1, −0.1, 0.1, −0.1, 0.1, 0 | **1.0** | 0.18 |
>
> A quadratic penalty (the smoothness idea) finds the ramp 4× cheaper than the step, so it turns every sharp edge into a blur. TV charges the step and the ramp the same: it only counts *how far* brightness climbs in total, not how steeply, so sharp edges survive. And a tiny noise wiggle of amplitude 0.1 costs TV as much as an entire black-to-white edge, so TV removes noise aggressively. Fewer, larger jumps are cheap; many small jiggles are expensive.

**Why "pseudo-norm" (slide 43).** A true norm is zero only for the zero vector ("size zero" should mean "nothing there"). TV is zero for *any* constant image, even a bright one (every difference vanishes), so it is only *almost* a norm: a **pseudo-norm** ("false norm") or **semi-norm** ("half norm"). Consequence for solving: TV alone says nothing about overall brightness; the data term has to pin that down.

**A known side effect: staircasing** (smooth slopes turned into flat steps, like a ramp rebuilt as a staircase). TV favors exactly flat regions, so a smooth gradual shading (a sky, a curved cheek) can come out as visible flat terraces. The extensions on slide 46 were invented partly to fix this: a **hyper-Laplacian** prior (a penalty |*t*|^*p* with *p* below 1, even more tolerant of big jumps and harsher on small ones than ℓ₁), **total generalized variation** (which also lets the slope itself vary, so ramps are free), and **Hessian-based** penalties (the Hessian is the table of second derivatives, i.e. how the slope changes, so these penalize bending rather than slope). They are beyond this course's scope.

**Implementing TV in PyTorch, and the `sqrt` trap (HW5 Task 1).** The HW warns: "do not try to use the function `torch.sqrt()` to implement your TV terms, because the gradient of this function at 0 is nan." Why, using the **chain rule** (the derivative of a function of a function is the product of the two derivatives):

- d/d*t* √*t* = 1/(2√*t*). At *t* = 0 this is 1/0 = ∞. At *t* = 10⁻⁸ it is already 5000.
- In isotropic TV, *t* = *a*² + *b*², and d*t*/d*a* = 2*a*. In flat regions *a* = *b* = 0, so the chain rule multiplies ∞ × 0, which floating-point arithmetic defines as **NaN** ("not a number"). One NaN in the objective gradient poisons every pixel on the next step.
- **The way out is the subgradient (Week 5 §31.3).** The length √(*a*² + *b*²) has a corner at (0, 0), like |*t*|, and any value in the allowed range is a valid subgradient there. PyTorch's `torch.abs` and `torch.norm` are written to return 0 at an exact zero, a valid choice, so the HW recommends building the TV terms from `torch.abs`, `torch.norm` (taking the norm over the two-direction axis gives the isotropic per-pixel length) and `torch.sum`.

**A scale detail when reading the starter code.** HW5 Task 1's data term is `(Afun(x) - b).pow(2).sum()`, i.e. ‖**A x** − **b**‖₂² without the slides' ½. Minimizing ‖·‖² + λ TV is the same as minimizing ½‖·‖² + (λ/2) TV, so the same λ means a different balance in different files. Compare λ values only within one file's convention.

> **Same concept, different names.** **Total variation (TV)** = **TV regularizer** = **TV prior** = **TV pseudo-norm** (= semi-norm). **Isotropic TV** = ‖**D x**‖₂,₁ = the "ℓ₂,₁" version (also called **group** sparsity, because each pixel's two differences are kept or zeroed together as a group); **anisotropic TV** = ‖**D x**‖₁ = ‖**D**_x**x**‖₁ + ‖**D**_y**x**‖₁.

> **Summary**
> - TV = sum over pixels of the image-gradient size: **anisotropic Σ(|D_x x| + |D_y x|)**, **isotropic Σ√((D_x x)² + (D_y x)²)**.
> - Rule to remember: TV charges the **total climb**, not the steepness: sharp edges cost the same as ramps, noise costs a lot → edges kept, noise removed.
> - Isotropic treats all edge directions equally; anisotropic overcharges diagonals by up to √2.
> - HW5: avoid `torch.sqrt` (NaN gradient at 0); use `torch.abs`, `torch.norm`, `torch.sum`.
> - Next: with the objective fully defined, how to minimize it (Part 4).

---

## 10. The Objective, Assembled

Every problem this week is one objective (slide 48):

```
minimize_x   ½ ‖b − A x‖₂²   +   λ Ψ(x)
             data fidelity        weight × regularizer
```

| Problem | **A** | Ψ | Where |
|---|---|---|---|
| HW5 Task 1 | blur **C** | TV (both versions) | §11–§12 |
| HW5 Task 2 | blur **C** | TV, or a DnCNN denoiser | §17–§21 |
| HW5 Task 3 | single-pixel patterns | none (least norm), TV, DnCNN | §23–§26 |

The data term is smooth (a bowl). TV is not: it has a corner wherever a difference is zero, which is most pixels. That mix is what makes the solvers interesting: Adam (§11) pushes through it with subgradients; ADMM (§13–§20) separates the two parts and handles each exactly.

> **Summary**
> - Rule to remember: **minimize ½‖b − Ax‖₂² + λΨ(x)**; one form, different **A** and Ψ for each problem.
> - The data term is smooth; TV has corners everywhere. Two strategies follow: push through (Adam) or split apart (ADMM).

---

# Part 4 — Solver 1: Adam

## 11. Gradient Descent, Automatic Differentiation, and Adam (supports HW5 Task 1)

**Restating gradient descent (Week 5 §31).** To minimize an **objective** *f*(**x**) (the single number we want as small as possible), repeat

```
x^(k+1) = x^(k) − α ∇f(x^(k))
```

where ∇*f* is the **objective gradient** (in this section "gradient" always means this one: the direction in which the *cost* rises fastest, one entry per unknown pixel), α the step size, and *k* the iteration number. *Analogy:* walking downhill in fog, one step at a time in the steepest downhill direction.

**Who computes ∇f? Automatic differentiation.** For ½‖**b** − **A x**‖² + λ TV(**x**), working out the gradient by hand is tedious. **PyTorch** (a Python library for numerical computing and neural networks) does it for you. As your code computes the loss, PyTorch records every operation in a **computational graph** (a diagram of which numbers were combined, how, to make which). Calling `loss.backward()` walks that record backwards, applying the chain rule at each step, and stores ∇*f* in `x.grad`. This is **automatic differentiation** ("autograd"). Two details from HW5's loop:

- `optim.zero_grad()` clears the stored gradient first, because `.backward()` *adds* to whatever is already stored.
- Every operation in the loss must be one PyTorch can differentiate. That is why `grad_fn` is written with `torch.fft` functions in Task 1, and why `torch.sqrt` is a problem at 0 (§9).

**Why not plain gradient descent? Two weaknesses.**

1. **The right step size depends on the scale of the problem.** Week 5 §31.1: for least squares α must stay below 2/μ_max, which depends on **A**. A badly chosen α diverges or crawls.
2. **TV's gradient is jumpy.** Its subgradient (§9) is ±1 per difference regardless of how close to zero the difference is, so steps keep overshooting back and forth (Week 5 §31.3).

**Adam's idea in one sentence.** Keep a running average of recent gradients (to smooth out the jumps) and divide each pixel's step by a running estimate of that pixel's typical gradient size (so the step size no longer depends on the problem's scale). The name comes from **adaptive moment estimation**: "moment" is the statistics word for an average of a power of a quantity (the 1st moment is the mean, the 2nd moment is the mean of the square).

**The update, step by step (for each pixel separately; all operations element-wise, i.e. done to each pixel's own number independently of the others).**

```
g_k = ∇f(x^(k−1))                               1. objective gradient now
m_k = β₁ m_{k−1} + (1 − β₁) g_k                  2. running average of gradients (momentum)
v_k = β₂ v_{k−1} + (1 − β₂) g_k²                 3. running average of squared gradients
m̂_k = m_k / (1 − β₁^k)    v̂_k = v_k / (1 − β₂^k)  4. bias correction
x^(k) = x^(k−1) − α · m̂_k / ( √v̂_k + ε )         5. step
```

| Term | Meaning | Who sets it |
|---|---|---|
| *g_k* | the objective gradient at the current estimate | computed by `.backward()` |
| *m_k* | **first moment**: an **exponential moving average** of gradients, i.e. a running average where each older gradient counts a fixed fraction less (β₁ times as much as the next newer one) | computed |
| β₁ | how long the gradient "memory" is; default 0.9 (about the last 1/(1 − 0.9) = 10 steps matter) | PyTorch default |
| *v_k* | **second moment**: running average of squared gradients, a measure of each pixel's typical gradient *size* | computed |
| β₂ | memory for *v*; default 0.999 (about 1000 steps) | PyTorch default |
| 1 − β^*k* | **bias correction**: *m* and *v* start at 0, so early averages are too small; dividing by 1 − β^*k* scales them back up (at *k* = 1, *m*₁ = 0.1 *g*₁, and dividing by 1 − 0.9 = 0.1 gives back *g*₁) | computed |
| α | **learning rate** (HW5 Task 1 sets 5 × 10⁻²) | you |
| ε | a tiny number (10⁻⁸) that prevents division by zero | PyTorch default |

**Why each piece.**

- *Momentum (step 2).* A ball rolling downhill does not stop at every bump; its speed carries it. Averaging gradients cancels the back-and-forth flips of TV's subgradient while keeping the consistent downhill direction.
- *Dividing by √v̂ (step 5).* m̂/√v̂ is roughly "average gradient ÷ typical gradient size," a number between −1 and 1 that no longer depends on the scale of the problem. Each step therefore moves each pixel by about α or less. That makes α easy to choose: it is roughly "how far a pixel value may move per step."

> **Worked example (Adam ignores the problem's scale; plain gradient descent does not).** Minimize *f*(*x*) = ½*a x*² from *x* = 1 with α = 0.05, for a steep bowl (*a* = 100) and a very flat one (*a* = 0.01).
>
> | | step 1 | step 2 | step 3 |
> |---|---|---|---|
> | Adam, *a* = 100 | 0.950 | 0.900 | 0.850 |
> | Adam, *a* = 0.01 | 0.950 | 0.900 | 0.850 |
> | gradient descent, *a* = 100 | **−4.0** (overshoots, will diverge) | | |
> | gradient descent, *a* = 0.01 | 0.9995 (barely moves) | | |
>
> Adam's steps are identical for a bowl 10 000 times steeper: each is about α = 0.05. Gradient descent with the same α explodes on the steep bowl and stalls on the flat one.

**"The fine print: convenient but doesn't always converge well" (slide 51).** Adam's ±α-sized steps never shrink on their own, so near the minimum it keeps hovering instead of landing exactly, and it has no guarantee of reaching the true minimum of a non-smooth objective like TV. It is the "practical #1 go-to" because it needs only three steps (slide 50): (1) write code that evaluates the loss, (2) choose hyperparameters including the learning rate, (3) run. A **hyperparameter** is a setting you choose before running (learning rate, λ, number of iterations), as opposed to the unknowns the solver finds.

> **Same concept, different names.** **Learning rate** = **step size** = α = `lr` (Week 5 §31). **Adam** = **adaptive moment estimation**. **First moment** = running mean of gradients = **momentum**; **second moment** = running mean of squared gradients (RMS, root-mean-square, after the square root). **Loss** = **objective** = **cost**. **Automatic differentiation** = **autograd** = **backpropagation** (in neural networks).

> **Summary**
> - PyTorch builds a record of the loss computation and `.backward()` returns the **objective gradient** by the chain rule (autograd).
> - Rule to remember: Adam steps by **α · m̂/(√v̂ + ε)**: a running average of gradients divided by their running typical size, so each pixel moves ≈ α per step whatever the problem's scale.
> - Convenient (three steps: loss, hyperparameters, run) but hovers near the minimum rather than converging exactly.
> - Next: what HW5 Task 1 asks you to assemble (§12).

---

## 12. Deconvolution with Adam and TV: the Pieces (HW5 Task 1)

PS5 (slides 5–7) sets up Task 1 as

```
minimize_x   ½ ‖C x − b‖² + λ TV(x)          solved with Adam, one color channel at a time
```

The starter code already provides, and you should be able to read:

| Piece | What it computes | Built in |
|---|---|---|
| `cFT = psf2otf(c, shape)` | the blur's OTF F{*c*} (PS5: "OTF is the Fourier transform of PSF c") | §2 |
| `Afun(x)` | **C x** = real part of F⁻¹{F{*x*}·F{*c*}} | §2 |
| `dxFT`, `dyFT`, `dxyFT` | F{*d_x*}, F{*d_y*}, and the two stacked: "[**D**_x; **D**_y] but in the Fourier domain" | §8 |
| `loss_data` | ‖**C x** − **b**‖² (no ½, §9) | §4 |
| the loop | zero the gradient, compute loss, `.backward()`, `optim.step()` (one Adam step) | §11 |

What remains for you, described by the math it implements (writing the code is the assignment):

1. `grad_fn`: the horizontal and vertical image gradients of **x**, i.e. **D**_x**x** and **D**_y**x**, computed as F⁻¹{F{*x*}·F{*d*}} for each kernel (§8), keeping the real part. The `.real` matters: F⁻¹ of a product returns complex numbers with tiny imaginary parts from rounding, and the TV terms need real ones.
2. `loss_regularizer`: one number, the anisotropic TV (sum of absolute values of both difference images) or the isotropic TV (sum over pixels of the length of each pixel's two-difference arrow), built from `torch.abs`, `torch.norm` and `torch.sum` (§9).

**Comparing anisotropic and isotropic.** The HW asks how different the two results are. What to look for, from §9: isotropic should treat diagonal edges and horizontal/vertical ones alike, while anisotropic may show slight blockiness or stair-stepping along diagonal edges. The size of the difference on the birds image, and its PSNR (Week 5 §25), are for you to measure.

> **Summary**
> - Task 1 = minimize **½‖Cx − b‖² + λTV(x)** with Adam; blur and image gradients are both FFT multiplications.
> - You supply `grad_fn` (two Fourier-domain differences, real part) and the TV aggregation (abs-sum or per-pixel length-sum).
> - Look for diagonal-edge differences between the two TV versions.
> - Next: a solver that handles TV's corners exactly instead of pushing through them (Part 5).

---

# Part 5 — Solver 2: ADMM

## 13. The Splitting Idea

**The problem.** In ½‖**b** − **A x**‖² + λΨ(**x**), the two terms are each easy alone but hard together:

- The **data term alone** is a smooth bowl; setting its gradient to zero gives a linear system that, for a blur, the FFT solves in one shot (Week 5 §30).
- The **TV term alone** is easy in a different way: §19 will show that "find **z** close to a given **v** with small ‖**z**‖₁" has a one-line, pixel-by-pixel answer.

Together, the corners of TV ruin the FFT shortcut, and the blur ruins the pixel-by-pixel shortcut.

*Analogy:* two specialists who cannot do each other's job: a plumber and an electrician renovating one house. Instead of one person doing everything badly, let each work on their own copy of the plan, then meet to reconcile the copies; repeat until the copies agree.

**Split the variable (slides 53–54).** Give the regularizer its own copy of the unknown:

```
minimize_{x,z}   ½ ‖b − A x‖₂²  +  λ Γ(z)          subject to   K x − z = 0
                 └─── f(x) ───┘     └ g(z) ┘
```

| Term | Meaning |
|---|---|
| *f*(**x**) | the data term, depending only on **x** |
| *g*(**z**) | the regularizer, depending only on the new variable **z** |
| **K** | the matrix the regularizer looks through: **K** = **D** for TV (Γ(**D x**) = ‖**D x**‖₁), **K** = *I* (identity, "do nothing") for a denoiser prior |
| **K x** − **z** = 0 | the **constraint** (a condition the answer is required to satisfy): **z** must equal **K x** |
| "subject to" | "while obeying the condition that" |

"Mathematically equivalent" (slide 54): any **x** that solves the original problem, paired with **z** = **K x**, solves the split one, and vice versa. Nothing has been gained yet. The gain comes from *how* we enforce the constraint, which needs Lagrange multipliers.

> **Summary**
> - The data term is easy alone (FFT/linear solve); the regularizer is easy alone (per-pixel); together they are hard.
> - Rule to remember: **split**: minimize **f(x) + g(z)** subject to **Kx − z = 0**, with **K = D** for TV.
> - Next: a tool for minimizing under a constraint (§14).

---

## 14. Lagrange Multipliers from Scratch

**The problem it solves.** Minimize a function while obeying an equation. *Analogy:* finding the lowest point of a hilly park while staying on a specific footpath. The lowest point of the park is probably not on the path; you want the lowest point *of the path*.

**A two-variable example.** Minimize *f*(*x*₁, *x*₂) = *x*₁² + *x*₂² (distance-squared from the origin; its **level curves**, the lines of equal height like contour lines on a hiking map, are circles) subject to *x*₁ + *x*₂ = 1 (a straight path).

**The key picture: at the best point, the path is tangent to a level curve.** Walk along the path. Wherever the path *crosses* a level circle, stepping one way goes downhill, so you are not at the best point yet. At the best point, the path just *touches* a level circle without crossing it (it is **tangent**: touching at one point and running in the same direction there). Two curves touching tangentially have parallel perpendicular directions, so

```
∇f  is parallel to  ∇(constraint)          i.e.   ∇f = −y · ∇(x₁ + x₂ − 1)   for some number y
```

The number *y* is the **Lagrange multiplier** (the minus sign is just a convention matching the slides).

**The Lagrangian packs both conditions into one function (slide 55).**

```
L(x, y) = f(x) + y · (constraint)
```

Setting all partial derivatives to zero (slide 56: "optimal if all partial derivatives are zero") gives:

- ∂*L*/∂**x** = 0: ∇*f* + *y*∇(constraint) = 0, the tangency condition;
- ∂*L*/∂*y* = 0: the constraint itself = 0 ("constraint is satisfied," slide 59).

> **Worked example.** *L* = *x*₁² + *x*₂² + *y*(*x*₁ + *x*₂ − 1).
> - ∂*L*/∂*x*₁ = 2*x*₁ + *y* = 0 and ∂*L*/∂*x*₂ = 2*x*₂ + *y* = 0, so *x*₁ = *x*₂ = −*y*/2.
> - ∂*L*/∂*y* = *x*₁ + *x*₂ − 1 = 0, so −*y* = 1, *y* = −1.
> - Answer: (*x*₁, *x*₂) = (0.5, 0.5), *f* = 0.5. Check by hand: on the path, (1, 0) gives *f* = 1, (0.8, 0.2) gives 0.68; (0.5, 0.5) is lowest.

**What the multiplier means: a price.** |*y*| measures how much the best value of *f* would improve if the constraint were relaxed a little. Here, changing the path to *x*₁ + *x*₂ = 1 + δ makes the best *f* = (1 + δ)²/2 ≈ 0.5 + δ: the rate is 1 = |*y*|. Economists call *y* a **shadow price**: what the constraint "costs" you.

**The lecture's version (slides 57–62).** For the split problem, *L*(**x**, **z**, **y**) = *f*(**x**) + *g*(**z**) + **y**ᵀ(**K x** − **z**), with one multiplier per constraint entry, collected in a vector **y** (this *y* is the multiplier, not the vertical direction). Zero partial derivatives "also imply" ∇_{x,z}(*f* + *g*) = −**y**ᵀ∇_{x,z}(**K x** − **z**) together with **K x** − **z** = 0. The contour plot (slides 61–62) is the tangency picture above: the red line is the set of points satisfying **K x** − **z** = 0; the dotted ellipses are level curves of *f*(*x*) + *g*(*z*); the minimum *along the red line* is where a level curve just touches it, and there the arrows (gradients) of *f* + *g* and of the constraint are parallel.

> **Same concept, different names.** **Lagrange multiplier** = **dual variable** = **shadow price**, written *y* (slides) or λ in many textbooks (here λ is already the regularization weight). The original unknowns (**x**, **z**) are the **primal variables**; "primal" just means "the original ones," and "dual" means "the partners attached to the constraints." **Level curve** = **contour** = **isoline**.

> **Summary**
> - At a constrained minimum, the constraint is **tangent** to a level curve, so the gradients are parallel.
> - Rule to remember: **L = f + yᵀ(constraint)**; setting all partial derivatives to zero gives both the tangency and the constraint.
> - The multiplier *y* is a **price**: how much the objective would improve if the constraint were loosened.
> - Next: making this robust enough to iterate (§15).

---

## 15. From Lagrangian to Augmented Lagrangian

**An iterative way to find the multiplier: raise the price when the rule is broken.** Usually we cannot solve for **x** and *y* in one go. The **method of multipliers** repeats two moves: (1) for the current price *y*, find the best **x**; (2) if **x** breaks the constraint, adjust *y* in proportion to how much it was broken. *Analogy:* a city sets a fine for parking violations; if many people still park illegally, it raises the fine; once nobody does, the fine stays where it is.

**Why add a penalty (slide 64).** The plain Lagrangian can misbehave when the constraint is not yet satisfied: with only a linear term *y*·(constraint), the "best **x** for the current price" may not even exist (the objective can head off to −∞ in some direction). Adding a quadratic **penalty** that grows with the square of the violation makes every sub-problem a well-behaved bowl:

```
L_ρ(x, z, y) = f(x) + g(z) + yᵀ(K x − z) + (ρ/2) ‖K x − z‖₂²
```

This is the **augmented Lagrangian** ("augmented" = "with something added"). ρ > 0 is the **penalty parameter** (slide 64: "see Boyd 2011"), controlling how hard a violation is punished.

**Why keep the multiplier at all, then? A penalty alone is never exact.** A pure penalty (no *y*) only satisfies the constraint in the limit ρ → ∞, and huge ρ makes the problem badly balanced. The multiplier lets a moderate ρ reach the exact answer.

> **Worked example (minimize ½x² subject to x = 1; the answer is obviously x = 1).**
>
> *Penalty only:* minimize ½*x*² + (ρ/2)(*x* − 1)². Setting the derivative *x* + ρ(*x* − 1) to zero gives *x* = ρ/(1 + ρ):
>
> | ρ | 1 | 10 | 100 |
> |---|---|---|---|
> | *x* | 0.5 | 0.909 | 0.990 |
>
> Never exactly 1.
>
> *Augmented Lagrangian with ρ = 1:* each round, minimize ½*x*² + *y*(*x* − 1) + ½(*x* − 1)², which gives *x* = (1 − *y*)/2, then update the price *y* ← *y* + ρ(*x* − 1). Starting from *y* = 0:
>
> | round | 1 | 2 | 3 | 4 | 5 | 6 |
> |---|---|---|---|---|---|---|
> | *x* | 0.5 | 0.75 | 0.875 | 0.9375 | 0.969 | 0.984 |
> | *y* | −0.5 | −0.75 | −0.875 | −0.9375 | −0.969 | −0.984 |
>
> The gap to 1 halves every round and goes to zero with a fixed, modest ρ. The price settles at *y* = −1, the exact Lagrange multiplier (§14's tangency condition: *x* + *y* = 0 at *x* = 1).

> **Summary**
> - Method of multipliers: best **x** for the current price, then raise the price by ρ × violation.
> - Rule to remember: **L_ρ = f(x) + g(z) + yᵀ(Kx − z) + (ρ/2)‖Kx − z‖²** — the Lagrangian plus a quadratic penalty.
> - The penalty makes each sub-problem a bowl; the multiplier makes the answer exact without ρ → ∞.
> - Next: a tidier way to write the same function (§16).

---

## 16. The Scaled Form: Completing the Square

**The problem.** *L*_ρ has two terms involving the constraint residual **r** = **K x** − **z** (a "residual" again means "how far from satisfied," here the constraint's): a linear one **y**ᵀ**r** and a quadratic one (ρ/2)‖**r**‖². Merging them into a single square makes every later step simpler, because "minimize (something) + (ρ/2)‖(stuff) − (target)‖²" is a form we can solve.

**The algebra: completing the square.** The 1D version is the school trick *a r* + (ρ/2)*r*² = (ρ/2)(*r* + *a*/ρ)² − *a*²/(2ρ). Check by expanding (ρ/2)(*r* + *a*/ρ)² = (ρ/2)*r*² + *a r* + *a*²/(2ρ). The vector version, line by line:

```
(ρ/2) ‖r + y/ρ‖²  =  (ρ/2) (r + y/ρ)ᵀ(r + y/ρ)
                  =  (ρ/2) ‖r‖²  +  yᵀr  +  (1/(2ρ)) ‖y‖²          expand; the two cross terms are each (ρ/2)(1/ρ) yᵀr
so
yᵀr + (ρ/2) ‖r‖²  =  (ρ/2) ‖r + y/ρ‖²  −  (1/(2ρ)) ‖y‖²
```

**Name u = y/ρ, the scaled dual variable (slide 65).** Then (1/(2ρ))‖**y**‖² = (ρ/2)‖**u**‖², and

```
L_ρ(x, z, u) = f(x) + g(z) + (ρ/2) ‖K x − z + u‖₂² − (ρ/2) ‖u‖₂²
```

| Term | Meaning |
|---|---|
| *f*(**x**) | data fidelity term |
| *g*(**z**) | regularizer on the split variable |
| (ρ/2)‖**K x** − **z** + **u**‖² | the merged constraint terms: "make **K x** equal **z** − **u**" |
| −(ρ/2)‖**u**‖² | a leftover that does not depend on **x** or **z**, so it never affects the x- or z-steps |
| **u** = **y**/ρ | **scaled dual variable**: the price, measured in the same units as **K x** |
| ρ | penalty parameter |

It is "the same function, written differently" (slide 65: "given by some algebraic manipulation, easier form to work with"). Slide 75 labels the parts: data fidelity term, regularizer, augmented Lagrangian terms.

> **Summary**
> - Completing the square merges **yᵀr + (ρ/2)‖r‖²** into **(ρ/2)‖r + u‖² − (ρ/2)‖u‖²** with **u = y/ρ**.
> - Rule to remember: **L_ρ(x, z, u) = f(x) + g(z) + (ρ/2)‖Kx − z + u‖² − (ρ/2)‖u‖²** (scaled form).
> - Lagrangian → augmented Lagrangian → scaled form (slide 66's recap).
> - Next: minimize it one variable at a time: ADMM (§17).

---

## 17. The ADMM Algorithm

**The idea.** Minimizing *L*_ρ over **x** and **z** together is as hard as the original problem. Instead, **alternate**: minimize over **x** with **z** frozen, then over **z** with **x** frozen, then update the price **u**. That is the **alternating direction method of multipliers** (ADMM): "alternating directions" (take turns on **x** and **z**) + "method of multipliers" (§15).

**Deriving each step from L_ρ (slides 68, 71, 118).** In each step, drop every term that does not contain the variable being updated, because constants do not move a minimum.

*x-step.* Terms with **x**: *f*(**x**) and (ρ/2)‖**K x** − **z** + **u**‖². Write **K x** − **z** + **u** = **K x** − (**z** − **u**) and name **v** = **z** − **u**:

```
x ← argmin_x  f(x) + (ρ/2) ‖K x − v‖₂²,          v = z − u
```

*z-step.* Terms with **z**: *g*(**z**) and (ρ/2)‖**K x** − **z** + **u**‖² = (ρ/2)‖**v** − **z**‖² with **v** = **K x** + **u** (using the *new* **x**):

```
z ← argmin_z  g(z) + (ρ/2) ‖v − z‖₂²,             v = K x + u
```

*u-step (price update).* The method-of-multipliers update **y** ← **y** + ρ(**K x** − **z**), divided by ρ:

```
u ← u + K x − z
```

The full loop, as in slide 118:

```
while not converged:
    x ← argmin_x  f(x) + (ρ/2)‖K x − v‖²      with v = z − u      (data step)
    z ← argmin_z  g(z) + (ρ/2)‖v − z‖²        with v = K x + u    (prior step)
    u ← u + K x − z                                                 (price step)
```

| Variable | Size (TV deconvolution, slide 76) | Role |
|---|---|---|
| **x** | *N* (one per pixel) | the image being estimated |
| **z** | 2*N* ("twice the size of **x**!") | the image gradients the prior is allowed to choose |
| **u** | 2*N* | the running price for disagreement between **D x** and **z** |

**What u really is: the running total of disagreements.** Unrolling *u* ← *u* + (**K x** − **z**) from **u** = 0 gives **u** after *k* steps = the sum of all past mismatches **K x** − **z**. *Analogy:* a thermostat that keeps adding up how long the room has been too cold, and turns the heat up further the longer it has been; once the room is right, the total stops changing and the heat stays where it is. This "sum of past errors" behavior is why ADMM eventually satisfies the constraint exactly.

> **Worked example (ADMM on one number).** Minimize ½(*x* − 3)² + |*x*| (data *b* = 3, λ = 1). Split: *f*(*x*) = ½(*x* − 3)², *g*(*z*) = |*z*|, constraint *x* − *z* = 0 (**K** = 1), ρ = 1. The steps are:
> - x-step: minimize ½(*x* − 3)² + ½(*x* − *v*)², so *x* = (3 + *v*)/2 with *v* = *z* − *u*.
> - z-step: minimize |*z*| + ½(*v* − *z*)²: the soft threshold of *v* = *x* + *u* at level 1 (proved in §19: shrink *v* toward 0 by 1, stopping at 0).
> - u-step: *u* ← *u* + *x* − *z*.
>
> Starting from *x* = *z* = *u* = 0:
>
> | iteration | 1 | 2 | 3 | 4 | 5 | 6 | 8 |
> |---|---|---|---|---|---|---|---|
> | *x* | 1.500 | 1.250 | 1.625 | 1.813 | 1.906 | 1.953 | 1.988 |
> | *z* | 0.500 | 1.250 | 1.625 | 1.813 | 1.906 | 1.953 | 1.988 |
> | *u* | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 |
>
> The exact answer is *x* = 2 (§19: shrink 3 by λ = 1). *x* and *z* agree from iteration 2 onward, and the remaining gap to 2 halves each iteration. The price *u* settles at λ/ρ = 1: the constant pull the |*z*| prior exerts on the data.

**When to stop (slide 100).** Either run a fixed number of iterations *K* ("unroll" for *K* iterations; HW5 uses 75), or stop when the change between iterations drops below a threshold.

> **Same concept, different names.** **ADMM** = **alternating direction method of multipliers**. **u** = **scaled dual variable** = scaled Lagrange multiplier = the "running residual sum." **z** = **split variable** = **slack variable** (slide 79's "slack/dual variable," loosely) = **auxiliary variable**. **x-update** = data step; **z-update** = prior step = regularization step; **u-update** = **dual update** = dual ascent step.

> **Summary**
> - ADMM minimizes the scaled augmented Lagrangian **one variable at a time**, then updates the price.
> - Rule to remember: **x ← argmin f(x) + (ρ/2)‖Kx − (z − u)‖²; z ← argmin g(z) + (ρ/2)‖(Kx + u) − z‖²; u ← u + Kx − z.**
> - **u** is the running sum of constraint mismatches, which drives them to zero.
> - Both minimizations have the same shape, "a function plus (ρ/2)‖· − target‖²," which has a name (§18).

---

## 18. The Proximal Operator

**The shape both ADMM steps share (slide 69).**

```
prox_{λf}(v) = argmin_x  f(x) + (1/(2λ)) ‖x − v‖₂²
```

| Term | Meaning |
|---|---|
| **v** | the point you start from (the target handed in by ADMM) |
| *f* | the function you would like to be small |
| (1/(2λ))‖**x** − **v**‖² | a leash: the farther **x** wanders from **v**, the more it costs |
| λ (here) | the leash length; long leash (large λ) → **x** goes most of the way to *f*'s minimum, short leash → **x** stays near **v**. On this one slide λ is the proximal step size, not the regularization weight |
| prox | short for **proximal** ("nearby"): the answer is the point near **v** that does best on *f* |

*Analogy:* walking a dog on a leash. You stand at **v**; the dog wants to reach the lowest point of *f*; where it ends up is a compromise between its goal and how far the leash lets it go. Slide 69's figure: the blue points (each **v**) are each pulled to a red point (their proximal point), toward lower values of *f* or into *f*'s allowed region.

**Matching to ADMM.** With leash weight ρ/2 instead of 1/(2λ), i.e. λ_prox = 1/ρ:

- x-step = prox of the data term *f*, around **v** = **z** − **u** (when **K** = *I*; with **K** = **D**, it is a generalized version, solved in §20). Slides label it prox_{‖·‖₂,ρ}: "the prox of the squared-ℓ₂ data term with weight ρ."
- z-step = prox of the regularizer *g*, around **v** = **K x** + **u**. For TV it is labeled prox_{‖·‖₁,ρ}; for a denoiser, prox_{𝒟,ρ}.

So ADMM is "apply the data prox, apply the prior prox, update the price," and each prior only needs its prox to be easy. Two are: ℓ₁ (§19) and, via a trick, any denoiser (§21).

> **Same concept, different names.** **Proximal operator** = **prox** = **proximal mapping** = the "proximal point of **v** with respect to *f*" (slide 69). The x-update = "prox of the data term" = prox_{‖·‖₂,ρ}; the z-update = "prox of the regularizer" = prox_{‖·‖₁,ρ} (TV) or prox_{𝒟,ρ} (denoiser).

> **Summary**
> - Rule to remember: **prox_f(v) = argmin_x f(x) + (ρ/2)‖x − v‖²**: the point near **v** that makes *f* small (a dog on a leash).
> - Both ADMM steps are proxes: the data prox and the prior prox.
> - Next: the prox of the ℓ₁ norm, which gives TV its exact zeros (§19).

---

## 19. Soft Thresholding: the Prox of ℓ₁ (supports HW5 Task 2 and 3)

**The problem.** For anisotropic TV, the z-step is (slides 89–91)

```
z ← argmin_z  λ ‖z‖₁ + (ρ/2) ‖v − z‖₂²,          v = D x + u
```

Both terms are sums over entries (‖**z**‖₁ = Σ|*z_i*|, ‖**v** − **z**‖² = Σ(*v_i* − *z_i*)²), so each entry can be solved on its own: a one-variable calculus problem, repeated for all 2*N* entries.

**Derivation (one entry, divide by ρ, and let κ = λ/ρ).** Minimize *h*(*z*) = κ|*z*| + ½(*v* − *z*)². |*z*| has a corner at 0, so check three cases (Week 5 §31.3's subgradients handle the corner):

1. *Suppose z > 0.* Then |*z*| = *z*, and *h*′(*z*) = κ − (*v* − *z*) = 0 gives *z* = *v* − κ. This is consistent with *z* > 0 only if **v > κ**.
2. *Suppose z < 0.* Then |*z*| = −*z*, and *h*′(*z*) = −κ − (*v* − *z*) = 0 gives *z* = *v* + κ, consistent only if **v < −κ**.
3. *Otherwise, |v| ≤ κ, and the answer is z = 0.* At *z* = 0 the subgradient of κ|*z*| is any value in [−κ, κ], and the quadratic's slope there is −*v*. Zero is a minimum exactly when some allowed value cancels that slope, i.e. when |*v*| ≤ κ.

```
S_κ(v) = v − κ     if v > κ
       = 0         if |v| ≤ κ
       = v + κ     if v < −κ
       = (v − κ)₊ − (−v − κ)₊          with (t)₊ = max(t, 0)
       = max(1 − κ/|v|, 0) · v          the form HW5's starter code uses
```

**In words: "shrink toward zero by κ, and stop at zero."** *Analogy:* a tax with a flat deduction. Every value loses κ off its size; values smaller than κ are wiped out entirely. This is why it is called **soft thresholding** (or **shrinkage**): unlike a hard threshold, which keeps big values unchanged and kills small ones, it also pulls the survivors in by κ.

| Term | Meaning | Who sets it |
|---|---|---|
| *v* | the entry handed in: an image-gradient value **D x** plus its price **u** | computed |
| κ = λ/ρ | the threshold: regularization weight ÷ penalty parameter | from your λ, ρ |
| *S*_κ(*v*) | the new **z** entry | computed |

> **Worked example (κ = 0.5).** *S*(2.0) = 1.5; *S*(0.3) = **0** (wiped out); *S*(−1.0) = −0.5; *S*(−0.5) = 0. In the starter code's form: max(1 − 0.5/2, 0)·2 = 0.75 × 2 = 1.5, the same. Every image-gradient entry smaller than κ becomes exactly zero: that is where TV's flat regions come from.

**Isotropic TV: block soft thresholding (slide 91's note; HW5's default in Task 2).** For isotropic TV the two differences at a pixel are a 2-vector **v**_*i* = ((**D**_x**x** + **u**)_*i*, (**D**_y**x** + **u**)_*i*), and the penalty is its length. The same case analysis, done on the length instead of the absolute value, gives: **shrink the arrow's length by κ, keep its direction, and set it to zero if it was shorter than κ**:

```
z_i = max(1 − κ / ‖v_i‖₂, 0) · v_i
```

> **Worked example (κ = 1, v = (3, 4)).** Length 5 → 4, direction kept: **z** = 0.8·(3, 4) = (2.4, 3.2). The anisotropic (entry-by-entry) version would give (2, 3) instead, which changes the arrow's direction. Block shrinkage treats the pixel's gradient as one object, consistent with isotropic TV ignoring edge orientation.

HW5's starter code already implements both z-updates (the `anisotropic_tv` branch and the `vnorm` branch). Its formula divides by |*v*| or ‖*v*‖, which is a division by zero when *v* is exactly 0. NumPy then warns and gives κ/0 = ∞, so 1 − ∞ = −∞, and max(−∞, 0) = 0: the result is still the correct *z* = 0.

> **Same concept, different names.** **Soft thresholding** = **shrinkage** = **soft shrinkage** (starter code comment) = the **prox of the ℓ₁ norm**, written 𝒮_κ. **Block soft thresholding** = **group shrinkage** = the prox of the ℓ₂,₁ norm (isotropic TV). Contrast: **hard thresholding** keeps values above the threshold unchanged.

> **Summary**
> - The ℓ₁ prox splits into one-variable problems, solved case by case with a subgradient at 0.
> - Rule to remember: **S_κ(v) = sign(v)·max(|v| − κ, 0) = max(1 − κ/|v|, 0)·v**, with **κ = λ/ρ**: shrink by κ, stop at zero.
> - Isotropic TV: shrink each pixel's gradient arrow's *length* by κ (block soft thresholding).
> - Next: the other ADMM step, the x-update, for deconvolution (§20).

---

## 20. The x-Update for Deconvolution, Derived (supports HW5 Task 2.1)

**The problem (slide 82).** With *f*(**x**) = ½‖**C x** − **b**‖² (blur data term) and **K** = **D** (TV):

```
x ← argmin_x  ½ ‖C x − b‖₂²  +  (ρ/2) ‖D x − v‖₂²,          v = z − u
```

A sum of two squared-error terms: a smooth bowl, so the minimum is where the objective gradient is zero.

**Step 1: write each square as a product (slide 83).** ‖**w**‖² = **w**ᵀ**w**:

```
= ½ (C x − b)ᵀ(C x − b)  +  (ρ/2) (D x − v)ᵀ(D x − v)
```

**Step 2: multiply out (slide 84),** exactly as for least squares in Week 5 §29.2:

```
= ½ ( xᵀCᵀC x − 2 xᵀCᵀb + bᵀb )  +  (ρ/2) ( xᵀDᵀD x − 2 xᵀDᵀv + vᵀv )
```

**Step 3: set the objective gradient to zero (slide 85).** Use Week 5's two rules (the gradient of **x**ᵀ**M x** is 2**M x** for symmetric **M**; the gradient of **c**ᵀ**x** is **c**); **b**ᵀ**b** and **v**ᵀ**v** do not contain **x** and vanish:

```
0 = CᵀC x − Cᵀb + ρ DᵀD x − ρ Dᵀv
```

**Step 4: collect the x terms (slide 86),** a "closed-form solution" (one that is written down directly, with no iterating):

```
(CᵀC + ρ DᵀD) x = Cᵀb + ρ Dᵀv          ⇒          x ← (CᵀC + ρ DᵀD)⁻¹ (Cᵀb + ρ Dᵀv)
```

| Term | Meaning | Changes between ADMM iterations? |
|---|---|---|
| **C**ᵀ**C** | "blur, then blur back": how strongly each image frequency survives the blur, squared | no |
| ρ**D**ᵀ**D** | "take image gradients, then send them back": a high-pass filter (§8), weighted by ρ | no |
| **C**ᵀ**b** | the measurement, blurred back by the transpose | no |
| ρ**D**ᵀ**v** | the prior step's preferred gradients **v** = **z** − **u**, turned back into an image | **yes**, **v** changes every iteration |

*Intuition:* "find the image whose blur matches the photo *and* whose gradients match what the prior step asked for, weighted by ρ."

**Is the matrix invertible?** **D**ᵀ**D** alone is not: a constant image has zero gradient (**D**ᵀ**D** · constant = 0). But **C**ᵀ**C** passes the constant (average-brightness) component unchanged whenever the blur kernel sums to 1 (it only redistributes light), so the sum is invertible. In the Fourier domain below, this is "the denominator is never zero."

**Step 5: turn it into FFTs (slide 88; PS5 slide 8).** All four matrices are convolutions, so each becomes a multiplication at each image frequency (§2's table): **C**ᵀ**C** → |F{*c*}|², **D**ᵀ**D** → |F{*d_x*}|² + |F{*d_y*}|², **C**ᵀ**b** → F{*c*}\*·F{*b*}, **D**ᵀ**v** → F{*d_x*}\*·F{*v*₁} + F{*d_y*}\*·F{*v*₂}. Inverting a matrix that is "multiply each frequency by a number" just means dividing each frequency by that number:

```
x = F⁻¹{  [ F{c}*·F{b} + ρ ( F{d_x}*·F{v₁} + F{d_y}*·F{v₂} ) ]
         / [ F{c}*·F{c} + ρ ( F{d_x}*·F{d_x} + F{d_y}*·F{d_y} ) ]  }
```

with *v*₁ = **v**(1 : *N*) the horizontal half and *v*₂ = **v**(*N*+1 : 2*N*) the vertical half (in HW5's [2, M, N] array, slots 0 and 1). The division is element-wise, one image frequency at a time. F{*c*}\*·F{*c*} is |F{*c*}|², a real, non-negative number.

**What the formula is doing, frequency by frequency.** Compare with Wiener (Week 5 §23):

```
Wiener:      F{c}* · F{b}  /  ( |F{c}|² + 1/SNR )
x-update:    ( F{c}* · F{b} + ρ·[prior's gradients] )  /  ( |F{c}|² + ρ·(|F{d_x}|² + |F{d_y}|²) )
```

The denominator is Wiener's, with the constant 1/SNR replaced by ρ times a **high-pass** curve: about 0 at low image frequencies and up to 8ρ (4 from each direction) at the highest. So the x-update barely regularizes coarse structure but strongly damps fine detail, unless the numerator's prior term (the TV step's cleaned-up gradients) supplies fine detail it trusts. At image frequency 0 the denominator is |F{*c*}(0)|² = 1 (for a kernel summing to 1), never zero.

**Why the denominator is computed once (HW5 Task 2.1).** Nothing in it changes during ADMM (*c*, *d_x*, *d_y* and ρ are fixed), so the starter code asks you to compute it before the loop. Only the numerator, which contains **v** = **z** − **u**, must be recomputed each iteration. ("Nominator" in the HW text means numerator.) The starter code also precomputes `cTFT`, `dxTFT`, `dyTFT` = the conjugates (the transposes, PS5 slide 9) and `bFT` = F{*b*}.

> **Same concept, different names.** **x-update** = **data step** = prox_{‖·‖₂,ρ} = "inverse filtering: Fourier multiplications and divisions" (starter code comment). **Closed-form** = **analytic** solution. **Numerator** = "nominator" (HW5 text).

> **Summary**
> - Setting the objective gradient to zero gives **(CᵀC + ρDᵀD) x = Cᵀb + ρDᵀv**, the normal equations of Week 5 with an extra prior term.
> - Rule to remember: **x = F⁻¹{(F{c}\*F{b} + ρ(F{d_x}\*F{v₁} + F{d_y}\*F{v₂})) / (|F{c}|² + ρ(|F{d_x}|² + |F{d_y}|²))}**.
> - It is Wiener with a high-pass regularizer; the denominator never changes, so compute it once; the numerator changes with **v** every iteration.
> - Next: replacing TV with a neural-network denoiser (§21).

---

## 21. Denoisers as Priors: Plug-and-Play ADMM (supports HW5 Task 2.2 and 3.3)

**The idea.** TV is a hand-written belief about images. A neural network trained on thousands of real photos to remove noise has learned a far richer one. Can ADMM use it, even though we cannot write its Ψ as a formula? Yes, because ADMM never needs Ψ itself, only its prox.

**Set K = I (slide 92).** The split is now **x** − **z** = 0: **z** is simply a second copy of the image.

*x-update (slides 92–94).* Same derivation as §20 with **D** replaced by the identity *I* ("no matrix **D**!"):

```
x ← (CᵀC + ρ I)⁻¹ (Cᵀb + ρ v)  =  F⁻¹{ ( F{c}*·F{b} + ρ F{v} ) / ( F{c}*·F{c} + ρ ) },          v = z − u
```

The denominator is now Wiener's exactly, with 1/SNR = ρ: a constant regularizer at every frequency. **v** ∈ ℝ^*N* here (one value per pixel).

*z-update (slides 95–97): a denoising problem in disguise.* With **v** = **x** + **u**:

```
z ← argmin_z  λ Ψ(z) + (ρ/2) ‖v − z‖₂²
  = argmin_z  Ψ(z) + (ρ/(2λ)) ‖v − z‖₂²          divide by λ
  = argmin_z  Ψ(z) + (1/(2σ²)) ‖v − z‖₂²          with  σ² = λ/ρ
```

Compare with §5's MAP objective with **A** = *I*: (1/(2σ²))‖**b** − **x**‖² + Ψ(**x**). They are the same. **The z-update is MAP denoising**: "the clean image most likely to have produced the noisy image **v**, if the noise were Gaussian with variance σ² = λ/ρ" ("This is a denoising problem with a regularizer that imposes a prior!", slide 96). So any good denoiser 𝒟 can stand in for the prox:

```
z ← 𝒟(v, σ² = λ/ρ)          e.g. DnCNN or non-local means
```

Plugging in an off-the-shelf denoiser this way is called **plug-and-play** (PnP) ADMM: the prior becomes a replaceable part. The price: with a neural network there is no explicit Ψ, and the guarantees of **convex** optimization (for bowl-shaped objectives with a single lowest point and no false valleys, Week 5 §28, ADMM is proven to reach the minimum) no longer strictly apply; in practice it works well.

**DnCNN, briefly.** A **convolutional neural network** (CNN: a stack of layers, each convolving the image with many small learned kernels and then applying a simple **nonlinearity**, a fixed bend such as "replace negative values by 0," without which the stack would collapse into a single convolution) trained to remove Gaussian noise. HW5's model has 17 layers (`nb=17`) of 64 channels (`nc=64`), and it is trained to predict the *noise* and subtract it (**residual learning**: it is easier to recognize "what looks like noise" than to draw a whole clean image). The weights file `dncnn_25.pth` is trained for noise of standard deviation 25 on a 0–255 scale, i.e. 25/255 ≈ 0.098 on a 0–1 scale. It takes no σ input: it always removes noise of about that strength.

> **Worked example (the noise level the starter code's λ and ρ ask for).** HW5 Task 2 sets λ = 0.01 × 0.5 = 0.005 and ρ = 1 × 0.5 = 0.5, so σ² = λ/ρ = 0.01 and σ = **0.1**. Task 3 sets λ = 0.05, ρ = 5.2: σ² = 0.0096, σ = **0.098**. Both match the network's training level, 25/255 = 0.098. With a fixed-level denoiser, λ and ρ should be chosen so that λ/ρ matches the level it was trained for.

**Running the network (PS5 slide 11).** The starter code already does these steps; knowing why each is there helps when something breaks:

| Step | Why |
|---|---|
| build the network (`net(...)`), load weights (`load_state_dict`) | create the layers, then fill them with the trained kernel values |
| `model.eval()` | switch to "test-time behavior": some layers act differently during training (e.g. **batch normalization**, which rescales values using averages over the current training batch); `eval()` freezes them to their trained settings |
| `requires_grad = False` | the network is used, not trained, so do not record operations for `.backward()` (saves memory and time) |
| `.to(device)` | move to the GPU (graphics processor) if available; HW5 Task 2's file hard-codes `device = torch.device("mps")`, Apple's GPU, which fails on non-Apple machines; Task 3's file picks CUDA or CPU automatically |
| reshape to (1, 1, H, W) | networks expect a batch of images with channels: 1 image, 1 channel (grayscale) |
| `.cpu().numpy()` | convert the output back to a NumPy array for the rest of ADMM |

> **Same concept, different names.** **Plug-and-play (PnP) prior** = **denoiser prior** = **learned prior** (when the denoiser is a trained network) = "ADMM with denoiser." 𝒟(·) = the **denoiser**; prox_{𝒟,ρ} = the z-step it replaces. **DnCNN** = "denoising convolutional neural network." **Non-local means** = a classical denoiser that averages pixels whose surrounding patches look alike.

> **Summary**
> - With **K = I**, the x-update is a Wiener-type filter: **x = F⁻¹{(F{c}\*F{b} + ρF{v}) / (|F{c}|² + ρ)}**.
> - Rule to remember: the z-update **argmin λΨ(z) + (ρ/2)‖v − z‖²** is **denoising v with noise variance σ² = λ/ρ**, so any denoiser can be plugged in.
> - HW5's DnCNN removes noise of σ ≈ 25/255 ≈ 0.098; the starter code's λ/ρ is set to match.
> - Next: a simpler cousin of ADMM, and turning the iterations into a trainable network (§22).

---

## 22. Half-Quadratic Splitting and Unrolled Optimization (supports the HW5 bonus)

**HQS: ADMM without the price (slides 122–127).** Start from the same split problem, but enforce the constraint with the penalty alone (no multiplier):

```
L_ρ(x, z) = f(x) + g(z) + (ρ/2) ‖D x − z‖₂²

while not converged:
    x ← argmin_x  f(x) + (ρ/2) ‖D x − z‖₂²
    z ← argmin_z  g(z) + (ρ/2) ‖D x − z‖₂²
```

The name: "half-quadratic" because, once **z** is held fixed, the new objective is quadratic in the image **x** (one "half" of the variables), so the x-step has a closed-form answer. Each step is the same prox as in ADMM with **u** = 0. The weakness is §15's: without **u** the constraint holds exactly only as ρ → ∞, so HQS is "very sensitive to the penalty parameter" and usually needs a schedule of growing ρ. "Steps not tied together with dual variable" (slide 127).

**Unrolled optimization (slides 101–102).** Run ADMM or HQS for a fixed small number *K* of iterations and draw them as a chain: **b** → (x-step, z-step) → (x-step, z-step) → … → **x̃**. That chain is a **feedforward network**: a pipeline of layers where data flows one way, each layer feeding the next, with no loops back. Then **train** it like one:

- **Learnable parameters**: a separate λ^(*k*) and ρ^(*k*) for each iteration *k* (and even a separate denoiser 𝒟^(*k*)), chosen by gradient descent on a training set to make the final output match ground-truth images.
- Benefits listed on slide 102: **skip connections** between iterations (shortcuts that hand a layer's output directly to later layers, not only the next one; "DenseNet-like" names a well-known network built that way), a regularizer that adapts to the specific **C**, and training with richer losses: **perceptual** losses (compare images by the features a trained network sees in them, closer to human judgment than pixel-by-pixel MSE) and **adversarial** losses (a second network tries to tell results from real photos, and the first is trained to fool it).

**The HW5 bonus, conceptually.** Fix *K* (whatever fits on your GPU), keep the pretrained DnCNN as the denoiser, and learn λ^(*k*) and ρ^(*k*) by backpropagating a loss (e.g. MSE to ground truth, Week 5 §25) through all *K* iterations, using training images that do *not* include the birds test image. Excluding it matters: tuning on the image you then score on would make the comparison unfair (the parameters would have "seen the answer"). Every operation in the chain (FFTs, divisions, the network) must be written in PyTorch so `.backward()` can pass through it. The design choices and results are the bonus task's.

> **Same concept, different names.** **HQS** = **half-quadratic splitting** = the **quadratic penalty method** with alternating minimization. **Unrolled optimization** = **algorithm unrolling** = **deep unfolding** = an "unrolled feedforward network."

> **Summary**
> - HQS = ADMM without **u**: simpler, but exact only as ρ → ∞, so very sensitive to ρ.
> - Rule to remember: **unrolling** = run *K* iterations as layers of a network and **learn λ^(k), ρ^(k)** per iteration from training data.
> - For the bonus: train on images other than the test image, and keep every step differentiable in PyTorch.
> - Next: the same machinery on a completely different camera (Part 6).

---

# Part 6 — Compressive Imaging and the Single-Pixel Camera

## 23. The Single-Pixel Camera (supports HW5 Task 3)

**The idea (slides 104–107).** A normal camera has millions of light-sensing pixels. A **single-pixel camera** has *one*, and still makes an image, by taking many measurements, each through a different known pattern.

**How the hardware works.**

1. A lens forms an image of the scene, not on a sensor, but on a **digital micromirror device** (DMD): a chip covered in hundreds of thousands of microscopic mirrors, each of which can tilt to one of two angles (the same chip used in many video projectors).
2. Each mirror sends its piece of the image either *toward* a second lens ("on") or *away* ("off"). The on/off layout is the **pattern** (the **mask**).
3. The second lens gathers all the "on" light onto a single **photodiode** (a one-pixel light meter), which reports one number: the total light passing the pattern.
4. Change the pattern, read again. Repeat *M* times.

**Each reading is a weighted sum (slide 107).** If the scene, flattened, is **x** (*N* pixel values) and pattern *m* is the row **a**_*m* (1 = on, 0 = off, or any weight in between), then reading *m* is

```
b_m = Σ_p a_m[p] · x[p]  =  a_mᵀ x          ⇒          b = A x + η,   A ∈ ℝ^(M×N)
```

| Term | Meaning (slide 107) | Who sets it |
|---|---|---|
| **a**_*m* | pattern *m*, one weight per pixel *p* | the designer (HW5: random) |
| **A** | the **measurement matrix**: one pattern per row | the designer |
| *b_m* | measurement *m*: the photodiode's reading | measured |
| *M* | number of measurements | the designer |
| *N* | number of pixels in the image | the designer |

**Why bother with one pixel?** At wavelengths where large sensor arrays are expensive or do not exist (infrared, terahertz, some x-ray bands, slide 138), one excellent detector plus a cheap mirror array can beat a poor array. The same idea is central to some LiDAR systems (§27).

**Compression (slides 106, 108–109).** If *M* = *N*, the system can be solved like any square one. The interesting case is **M < N**: fewer measurements than pixels. That makes the problem **under-determined** (more unknowns than equations; Week 5 §28), also called a **compressive imaging** problem: the camera "compresses" while measuring, instead of measuring everything and compressing afterwards (as JPEG does, Week 3). The **compression factor** is *N*/*M*. Slide 106 shows reconstructions from 10%, 5% and 2% as many measurements as pixels.

**HW5 Task 3's setup, in these terms.** The test image is a 64×64 logo, so *N* = 4096 unknowns. With compression factor 4, *M* = 4096/4 = 1024 measurements. The patterns are random gray levels between 0 and 1 (`np.random.rand`), one 64×64 mask per measurement, and the noise has σ = 0.001. The starter code supplies the two operations as functions (handles, Week 5 §26):

- `Afun(x)`: multiply each mask by the image and sum each product, giving 1024 numbers (that is **A x**);
- `Atfun(b)`: weight each mask by its measurement and add the masks up, giving a 64×64 image (that is **A**ᵀ**b**).

**Watch the names.** In `hw5_task3.py`, the variable `N` is the number of *measurements* (1024), the lecture's *M*. These notes always use the lecture's meaning (*N* = pixels, *M* = measurements).

> **Summary**
> - A single-pixel camera reads the total light through *M* known patterns: **b = A x + η**, one pattern per row of **A**.
> - Rule to remember: **compressive** means **M < N** (under-determined); compression factor = **N/M**. HW5 Task 3: *N* = 4096, *M* = 1024.
> - `Afun` = **A x** (masks times image, summed), `Atfun` = **A**ᵀ**b** (masks weighted by readings, summed). The starter code's `N` is the lecture's *M*.
> - Next: the simplest answer to an under-determined system, and why it is not enough (§24).

---

## 24. The Least-Norm Solution (supports HW5 Task 3.1)

**The problem (slide 110).** With *M* < *N*, "infinitely many solutions satisfy the observations": any solution plus anything the patterns cannot see (any vector in the **null space** of **A**, Week 5 §27.1: changes to the image that leave every reading unchanged) is another solution. We must pick one.

**The standard pick: the shortest (slide 111).** Choose the exact solution with the smallest ℓ₂ norm:

```
minimize_x  ‖x‖₂          subject to   A x = b          ⇒          x̃_ln = Aᵀ (A Aᵀ)⁻¹ b
```

**Derivation with a Lagrange multiplier (§14).** Minimize ½‖**x**‖² (same minimizer as ‖**x**‖, easier to differentiate) subject to **A x** = **b**, with one multiplier per measurement collected in **w**:

```
L(x, w) = ½ xᵀx + wᵀ(A x − b)
∂L/∂x = x + Aᵀw = 0           ⇒   x = −Aᵀw              the answer is a combination of the patterns
∂L/∂w = A x − b = 0           ⇒   −A Aᵀ w = b   ⇒   w = −(A Aᵀ)⁻¹ b
substitute:                        x = Aᵀ (A Aᵀ)⁻¹ b
```

| Term | Meaning | Size |
|---|---|---|
| **A A**ᵀ | how much each pair of patterns overlaps (entry (*m*, *m*′) = **a**_*m*ᵀ**a**_*m*′) | *M*×*M* (small side) |
| (**A A**ᵀ)⁻¹**b** | the weights that say how much of each pattern to use | *M* |
| **A**ᵀ(…) | add up the patterns with those weights to make an image | *N* |

**What it means.** The first line of the derivation says the least-norm image is *a weighted sum of the patterns themselves*. It contains nothing the patterns cannot see (no null-space part), which is exactly why it is the shortest: any null-space part would only add length. "Equivalent to an ‖·‖₂ regularizer" (slide 111): it is Tikhonov (§5, Week 5 §30) in the limit λ → 0.

**Why it looks bad.** "Results (not great)" (slide 112). Nothing in it says "look like an image." With random patterns, a weighted sum of random patterns looks like random speckle, and the missing null-space part (75% of the image's degrees of freedom at 4× compression) is simply set to zero.

> **Worked example (4 pixels, 2 patterns).** Scene **x** = [0.2, 0.9, 0.4, 0.7]. Patterns **a**₁ = [1, 0, 1, 0] and **a**₂ = [0, 1, 1, 1]. Readings: *b*₁ = 0.2 + 0.4 = 0.6, *b*₂ = 0.9 + 0.4 + 0.7 = 2.0.
> - **A A**ᵀ = [[2, 1], [1, 3]] (pattern 1 has 2 "on" pixels, pattern 2 has 3, and they share 1).
> - Solve [[2, 1], [1, 3]]**w** = [0.6, 2.0]: **w** = [−0.04, 0.68]. Then **x̃** = **A**ᵀ**w** = −0.04·**a**₁ + 0.68·**a**₂ = **[−0.04, 0.68, 0.64, 0.68]**.
> - It reproduces both readings exactly (−0.04 + 0.64 = 0.6; 0.68 + 0.64 + 0.68 = 2.0) and is shorter than the truth (length 1.156 vs. 1.225), but it is wrong everywhere, and pixel 1 is even negative (impossible for light). The error, truth − estimate = [0.24, 0.22, −0.24, 0.02], is invisible to both patterns: **A** times it is [0, 0]. That is the null-space part least-norm discards.

**Computing it without inverting anything (PS5 slides 13–14; HW5 Task 3.1).** **A A**ᵀ is 1024×1024 here, but in larger problems it is still too big to form. Solve in two stages, using only `Afun` and `Atfun`:

1. **Find w:** solve (**A A**ᵀ)**w** = **b** iteratively, with conjugate gradients (§25).
2. **Map back:** **x** = **A**ᵀ**w**. ("Don't forget to apply the final **A**ᵀ!")

The starter code's hint calls the first-stage unknown *y* (yet another use of that letter).

> **Same concept, different names.** **Least-norm solution** = **minimum-norm solution** = "LN" (PS5, HW5 plots) = the pseudoinverse solution **A**⁺**b** for a wide **A** (Week 5 §29.2). **Under-determined** = **compressive** = **compressed sensing** setting (*M* < *N*). **Measurement matrix** = **sensing matrix** = **A**.

> **Summary**
> - Under-determined: infinitely many exact solutions; least norm picks the shortest.
> - Rule to remember: **x̃_ln = Aᵀ(AAᵀ)⁻¹b**, derived with a Lagrange multiplier; it is a weighted sum of the patterns.
> - It fits the data exactly but discards everything in the null space, so it looks like speckle.
> - Compute it as: solve **(AAᵀ)w = b** with CG, then **x = Aᵀw**.
> - Next: the conjugate gradient method (§25).

---

## 25. The Conjugate Gradient Method (supports HW5 Task 3)

**The problem it solves.** Solve **Ã w** = **b̃** for a large matrix **Ã** that we can only *apply* (via a function), never store or invert. (The tilde notation follows slide 119; it just means "the system for this step.") It works when **Ã** is:

- **symmetric**: **Ã** = **Ã**ᵀ (mirror-image across its diagonal), and
- **positive definite**: **w**ᵀ**Ã w** > 0 for every nonzero **w**. In plain words: the quadratic "bowl" ½**w**ᵀ**Ã w** − **b̃**ᵀ**w** curves upward in *every* direction, so it has exactly one lowest point.

**Why solving the system = finding the bottom of a bowl.** The objective gradient of *q*(**w**) = ½**w**ᵀ**Ã w** − **b̃**ᵀ**w** is **Ã w** − **b̃** (Week 5 §29.2's rules). It is zero exactly when **Ã w** = **b̃**. So solving the system and minimizing the bowl are the same task.

**Why not gradient descent?** On a stretched bowl (an ellipse-shaped valley), the steepest direction rarely points at the bottom, so gradient descent zig-zags back and forth across the valley (Week 5 §31.1's slow convergence). Even **steepest descent** with the best possible step length each time (go downhill until the ground starts rising again) keeps undoing part of its previous progress.

**CG's idea: never undo a previous step.** Choose each new direction so that moving along it does not spoil the minimization already done along earlier directions. Such directions are called **conjugate** (or **Ã-orthogonal**): if you stretched space so the elliptical bowl became perfectly round, they would be perpendicular. In a round bowl, minimizing along *N* perpendicular directions one at a time reaches the bottom exactly, so CG finishes in at most *N* steps (with exact arithmetic), and usually gets close much sooner.

**The algorithm, step by step.**

```
r₀ = b̃ − Ã w₀,   p₀ = r₀                       start: residual = how far from solving; first direction = steepest
repeat for k = 0, 1, 2, …
    α_k   = r_kᵀ r_k / (p_kᵀ Ã p_k)            best step length along p_k (bottom of the bowl along that line)
    w_{k+1} = w_k + α_k p_k                     step
    r_{k+1} = r_k − α_k Ã p_k                   update the residual (no extra matrix product needed)
    β_k   = r_{k+1}ᵀ r_{k+1} / (r_kᵀ r_k)       how much of the old direction to keep
    p_{k+1} = r_{k+1} + β_k p_k                 new direction: steepest, corrected to be conjugate to the old ones
```

| Term | Meaning |
|---|---|
| **r**_*k* | the **residual** **b̃** − **Ã w**_*k*: how far the current guess is from solving the system (also minus the bowl's objective gradient) |
| **p**_*k* | the search direction |
| α_*k* | step length (not the learning rate of §11) |
| β_*k* | mixing weight that bends the steepest direction to make it conjugate |
| **Ã p**_*k* | the single matrix-vector product per iteration: one call of your function |

> **Worked example (2×2: steepest descent vs. CG).** Solve **Ã** = [[4, 1], [1, 3]], **b̃** = [1, 2]. Exact answer: **w** = [1/11, 7/11] = [0.0909, 0.6364]. Start at **w** = [0, 0].
>
> | iteration | steepest descent (best step each time) | error | CG | error |
> |---|---|---|---|---|
> | 1 | [0.2500, 0.5000] | 0.21 | [0.2500, 0.5000] | 0.21 |
> | 2 | [0.0833, 0.5833] | 0.054 | **[0.0909, 0.6364]** | **0** |
> | 3 | [0.1042, 0.6250] | 0.018 | (done) | |
> | 5 | [0.0920, 0.6354] | 0.0015 | | |
>
> The first steps are identical (both start downhill). Then steepest descent zig-zags toward the answer, gaining about a factor 3–4 per step; CG's second direction (β₀ = 0.0625 of the old direction mixed in) lands exactly on the answer: 2 unknowns, 2 steps.

**Why AAᵀ qualifies.** It is symmetric ((**A A**ᵀ)ᵀ = **A A**ᵀ), and **w**ᵀ**A A**ᵀ**w** = ‖**A**ᵀ**w**‖² ≥ 0, with equality only if **A**ᵀ**w** = 0, which cannot happen for nonzero **w** when the patterns are **linearly independent** (no pattern can be built as a weighted sum of the others; true, with overwhelming probability, for random patterns with *M* < *N*). The starter code's hint says CG needs "positive semi-definite matrices, like AA′"; semi-definite (≥ 0 instead of > 0) is enough as long as the system has a solution.

**Using SciPy's CG matrix-free (PS5 slide 14).** `scipy.sparse.linalg.cg` never needs the matrix, only a way to apply it, wrapped in a `LinearOperator`:

- `LinearOperator(shape, matvec=function)`. *shape* is the matrix's size: for least norm, (number of measurements, number of measurements). *matvec* is a function that takes a **flat vector** and returns **Ã** times it as a flat vector; for least norm, **w** ↦ **A A**ᵀ**w** (apply `Atfun`, then `Afun`).
- **Reshape carefully.** CG works on 1D vectors; `Afun` expects a 64×64 image and `Atfun` returns one. Inside your matvec, reshape to the image shape before calling an image function and flatten (`.ravel()` / `.reshape(-1)`) after.
- `cg(A=operator, b=right_side, maxiter=…, …)` returns a pair: the solution vector and an info flag (0 = converged to the tolerance; a positive number = stopped at `maxiter`). Take the first element.
- **Tolerance argument name.** The starter code passes the tolerance as `tol`. Recent SciPy versions renamed it `rtol` ("relative tolerance"); the old name was first **deprecated** (still accepted, with a warning that it will go away) and then removed. If `tol` raises an error, that is why.

> **Same concept, different names.** **Conjugate gradient (CG)** = **conjugate gradient method**. **Matrix-free** = using only a function that applies the matrix (a function handle, Week 5 §26; SciPy's `LinearOperator`; `matvec` = "matrix-vector product"). **Symmetric positive definite** = SPD = a bowl curving up in every direction. **Steepest descent** = gradient descent with the best step length chosen at each step (exact **line search**).

> **Summary**
> - CG solves **Ã w = b̃** for symmetric positive definite **Ã** using one matrix-vector product per step.
> - Rule to remember: solving the system = minimizing the bowl **½wᵀÃw − b̃ᵀw**; CG picks **conjugate** directions that never undo earlier progress, reaching the exact answer in at most *N* steps (2 in the 2×2 example).
> - **AAᵀ** and **AᵀA + ρDᵀD** are SPD, so CG applies.
> - In SciPy: `LinearOperator(shape, matvec=…)` + `cg(...)`; flatten/reshape inside the matvec; the solution is the first returned item.
> - Next: putting CG inside ADMM (§26).

---

## 26. ADMM for Single-Pixel Imaging (supports HW5 Task 3.2 and 3.3)

**Same algorithm, different A (slides 115–120; PS5 slides 15–16).** Replace the blur **C** with the measurement matrix **A**. The z- and u-updates do not change at all (they never involve **A**); only the x-update does:

```
TV prior (K = D):      x ← (AᵀA + ρ DᵀD)⁻¹ (Aᵀb + ρ Dᵀv),        v = z − u
DnCNN prior (K = I):   x ← (AᵀA + ρ I)⁻¹  (Aᵀb + ρ v),          v = z − u
```

These are §20's and §21's formulas with **C** → **A**, derived the same way (set the objective gradient to zero).

**Why no FFT this time (PS5: "unlike deconvolution, the red part doesn't have a Fourier counterpart").** The Fourier trick worked because a blur is a convolution, and convolutions all become per-frequency multiplications. Random patterns are not a convolution, so **A**ᵀ**A** is not diagonal in the Fourier domain and cannot be inverted by division. Instead, solve the system with CG every ADMM iteration (slide 119: "use matrix-free iterative solver, such as the conjugate gradient method, to solve **Ã x** = **b̃**"):

| Piece | TV prior | DnCNN prior |
|---|---|---|
| **Ã** (apply to **x**) | **A**ᵀ(**A x**) + ρ**D**ᵀ(**D x**) | **A**ᵀ(**A x**) + ρ**x** |
| **b̃** (right side) | **A**ᵀ**b** + ρ**D**ᵀ**v** | **A**ᵀ**b** + ρ**v** |
| operator size | *N*×*N* (pixels × pixels) | *N*×*N* |
| function calls in the matvec | `Afun`, `Atfun`, `opDx`, `opDtx` | `Afun`, `Atfun` |

"Combine the least squares objectives first" (PS5) means exactly this: merge the data term and the ADMM coupling term into one system **Ã x** = **b̃** before calling CG. Both versions of **Ã** are symmetric and positive definite, so CG applies. Each is a sum of terms **G**ᵀ**G**, which are never negative (**x**ᵀ**G**ᵀ**G x** = ‖**G x**‖² ≥ 0). With ρ*I*, every nonzero **x** gives a positive value. With ρ**D**ᵀ**D**, the only images it ignores are constant ones, and the patterns do see a constant image (every mask has positive weights), so no nonzero image is ignored by both terms.

**Costs.** HW5 runs 75 ADMM iterations with 25 CG iterations inside each: 1875 applications of **A** and **A**ᵀ in total. Note **b̃** changes every ADMM iteration (through **v**), so it is rebuilt inside the loop; **Ã** itself does not change.

**A practical tip: warm starts.** Consecutive ADMM iterations produce similar **x**, so starting CG from the previous **x** (SciPy's `x0` argument) instead of from zero usually reaches the tolerance in fewer iterations. Optional; the HW does not require it.

**What the lecture's results show (slide 121).** At every compression factor, least norm is far worse than any method with a prior. As compression grows from 2× to 8×, ADMM + DnCNN degrades most gracefully, while both TV-based methods already drop sharply at 4×. ADMM beat HQS with the same prior in every case except TV at 8×, where the two are about tied (HQS slightly ahead). The learned DnCNN prior beat TV at 4× and 8×; at 2×, TV was slightly ahead. The values on HW5's image are for you to measure.

**"If you can solve this, you can solve anything" (slide 114).** CT, MRI, hyperspectral imaging and many more (§28) are all "minimize ½‖**b** − **A x**‖² + λΨ(**x**)" with a different **A**. Swap in the right `Afun` and `Atfun`, and every line of this ADMM code stays the same.

> **Summary**
> - Single-pixel ADMM: same z- and u-updates; the x-update solves **(AᵀA + ρDᵀD)x = Aᵀb + ρDᵀv** (TV) or **(AᵀA + ρI)x = Aᵀb + ρv** (DnCNN).
> - Rule to remember: no Fourier shortcut for random patterns, so **solve the x-update with CG** using a matvec built from `Afun`, `Atfun` (and `opDx`, `opDtx`).
> - **Ã** is fixed; **b̃** changes every iteration. Warm-starting CG from the previous **x** is an optional speedup.
> - Priors dramatically beat least norm at every compression factor; the DnCNN prior with ADMM holds up best as compression grows.
> - Next: the same machinery for LiDAR (§27).

---

# Part 7 — LiDAR

## 27. Compressive and Single-Pixel LiDAR

LiDAR (light detection and ranging; Week 4 and Week 5 §20.2) measures distance by timing laser light's round trip: distance *d* = *c t* / 2, where *t* is the round-trip time and *c* ≈ 3 × 10⁸ m/s is the speed of light. This week's tools matter for LiDAR in four concrete ways.

### 27.1 Why LiDAR and single-pixel imaging fit together

A depth camera needs, at every pixel, a detector fast enough to time light to within a nanosecond (a billionth of a second; light travels 30 cm in that time). Such detectors (for example **single-photon avalanche diodes**, SPADs, which click on individual photons) are expensive to build in large arrays, especially at the infrared wavelengths many LiDARs use (such as 1550 nm, chosen partly because it is safer for eyes). Three ways to get a depth *image*:

| Approach | How | Detector |
|---|---|---|
| **scanning** LiDAR | steer one laser beam across the scene, one point at a time | one fast detector |
| **flash** LiDAR | light the whole scene at once | a full array of fast detectors |
| **compressive (single-pixel) LiDAR** | light the whole scene; a DMD (§23) applies patterns; time the total return | one fast detector |

The third is §23's single-pixel camera with a timing detector. Research systems built this way have recovered depth images from fewer patterns than pixels.

### 27.2 The forward model: one single-pixel problem per time bin

**Time bins.** The detector does not report one time; it records a **histogram**: counts of returned light in each short time slot (a **time bin**) after the laser pulse. A bin of width Δ*t* corresponds to a depth slice of thickness Δ*d* = *c* Δ*t* / 2.

> **Worked example (bin sizes).** Δ*t* = 1 ns gives Δ*d* = 3 × 10⁸ × 10⁻⁹ / 2 ≈ **0.15 m** per bin. Covering depths 0–30 m then takes 30 / 0.15 = **200 bins**.

**The model.** Describe the scene as a stack of 2D images, one per depth bin: *x*[*p*, *t*] is how much light pixel *p* sends back in time bin *t* (nonzero only in the bin matching that pixel's surface depth). The light reaching the detector in bin *t*, through pattern *m*, is the pattern-weighted sum of that slice:

```
b[m, t] = Σ_p a_m[p] · x[p, t]          ⇒          B = A X
```

| Term | Meaning | Size (64×64 scene, 4×, 200 bins) |
|---|---|---|
| **A** | the same pattern matrix as §23 | 1024 × 4096 |
| **X** | the scene: column *t* = the image of "what is at depth bin *t*" | 4096 × 200 |
| **B** | the data: row *m* = the histogram recorded through pattern *m* | 1024 × 200 |

**Read it column by column:** each time bin is an ordinary single-pixel imaging problem **b**_*t* = **A x**_*t*, all sharing the same **A**. HW5 Task 3's solver, run 200 times (or on all columns at once), recovers the whole depth-resolved scene.

> **Worked example (4 pixels, 2 patterns, two surfaces).** Reuse §24's scene reflectivities [0.2, 0.9, 0.4, 0.7], with pixels 1–2 on a wall in bin 3 and pixels 3–4 on a box in bin 5. Patterns **a**₁ = [1, 0, 1, 0], **a**₂ = [0, 1, 1, 1].
>
> | | bin 3 (wall) | bin 5 (box) |
> |---|---|---|
> | pattern 1 histogram | 0.2 (pixel 1) | 0.4 (pixel 3) |
> | pattern 2 histogram | 0.9 (pixel 2) | 0.4 + 0.7 = 1.1 (pixels 3, 4) |
>
> Timing has already separated the two surfaces: the bin-3 column is a single-pixel measurement of the wall alone, the bin-5 column of the box alone. Adding the bins back up gives §24's readings 0.6 and 2.0 (the plain intensity image).

**A prior that fits naturally.** Each depth slice **x**_*t* is mostly zero (only the pixels whose surface is at that depth are lit): the "stars" situation of §7, so an ℓ₁ prior suits each slice. Across slices, each pixel has typically one main return (sparse in time), and neighboring pixels tend to have similar depths (sparse depth gradients: TV, §27.4).

**From the cube to a depth map.** For each pixel, the depth is the bin with the strongest return times 0.15 m. A cheaper variant used in practice recovers just two images with two single-pixel solves, the total reflectivity Σ_*t* *x*[*p*, *t*] and the time-weighted sum Σ_*t* *t*·*x*[*p*, *t*]; their ratio is each pixel's average return bin, i.e. its depth (correct when each pixel has one surface).

**The data-size picture.** The full cube has 4096 × 200 = 819 200 unknowns; the data has 1024 × 200 = 204 800 numbers. The same 4× compression as HW5, with the prior making up the difference.

**One more advantage: light efficiency.** Each pattern with about half its mirrors "on" sends roughly half of the whole scene's returned light to the detector, instead of one pixel's worth at a time. When the detector's own electronic noise dominates (rather than the randomness of the light itself), that larger signal per reading improves the signal-to-noise ratio. This is called the **multiplex advantage**.

### 27.3 Counting photons changes the data term

**The problem.** Long-range or low-power LiDARs often return only a handful of photons per bin. Photon arrivals are random, and their counts follow a **Poisson distribution** (the probability law for counting independent random events, such as raindrops landing on a tile in a minute; this is the photon shot noise of Week 2 §18), not a Gaussian: a bin expecting 4 photons gets 4 ± 2 (50% spread), while one expecting 400 gets 400 ± 20 (5%), because the standard deviation is the square root of the mean. At low counts, a Gaussian noise model is wrong: it even assigns probability to negative counts.

**§5's recipe still works; only the likelihood changes.** If bin *i* expects (**A x**)_*i* photons, the Poisson probability of seeing *b_i* is (**A x**)_*i*^*b_i* e^{−(**A x**)_*i*} / *b_i*!, so

```
−log p(b | x) = Σ_i [ (A x)_i − b_i log (A x)_i ] + (terms without x)
```

| Term | Meaning |
|---|---|
| (**A x**)_*i* | the expected photon count in measurement *i* if the scene were **x** (in practice plus a known background level from ambient light) |
| *b_i* | the photons actually counted |
| *b_i*! | "*b_i* factorial," 1·2·…·*b_i*; it does not depend on **x** and drops out |

This replaces ½‖**b** − **A x**‖²/σ² as the data term. The MAP objective is still "data term + λΨ," and ADMM still applies: the data step is no longer a linear system (no closed form), but splitting can isolate it into its own simple per-measurement prox step. The deeper machinery is beyond this week; the point is that the Bayesian view tells you *which* data term to use when the noise is not Gaussian.

### 27.4 TV for depth maps: edges stay sharp, no "flying pixels"

**Why TV fits depth even better than brightness.** A depth map has no texture: a printed poster on a wall has a busy brightness image but a perfectly flat depth image. Depth maps are mostly flat or smoothly varying patches separated by sharp jumps at object boundaries: exactly what TV favors (§9).

**Flying pixels.** Ordinary smoothing (averaging neighbors) at a depth edge invents depths that belong to *no* surface: points floating in mid-air between a foreground object and the background. These are the same artifacts LiDAR and time-of-flight users call **flying pixels** (or **mixed pixels**); a sensor also creates them on its own when one pixel's light comes partly from the foreground and partly from the background. TV's edge-preserving behavior avoids adding them.

> **Worked example (a scan line across a box edge).** Measured depths, in meters, with noise: [10.0, 10.1, 9.9, 10.0, 15.1, 14.9, 15.0, 15.0] (a wall at 10 m, then a box surface at 15 m). Two clean-ups:
>
> | Method | Result |
> |---|---|
> | 3-tap moving average (each sample averaged with its two neighbors, end values repeated) | 10.03, 10.00, 10.00, **11.67**, **13.33**, 15.00, 14.97, 15.00 |
> | TV denoising, minimize ½‖**x** − **b**‖² + 0.2 ‖**D x**‖₁ (solved with this week's ADMM, ρ = 1) | 10.05, 10.05, 10.05, 10.05, 14.95, 14.95, 14.95, 14.95 |
>
> The average invents two flying points at 11.67 m and 13.33 m, where nothing exists. TV returns two perfectly flat plateaus and a single clean 10 → 15 m jump. Its one bias: each plateau moves toward the other by λ ÷ (plateau length) = 0.2/4 = 0.05 m, because TV charges for the jump's height (§9's "total climb") and trims it slightly. This **contrast loss** is TV's typical small price.

**Slanted surfaces and staircasing.** A floor seen at an angle has depth that rises steadily, a constant nonzero depth gradient. Plain TV penalizes every step of that slope and may turn the ramp into flat terraces (staircasing, §9). Higher-order priors such as **total generalized variation** (TGV, slide 46), which penalize *changes* in the gradient rather than the gradient itself, treat a plane as free and fit depth maps of slanted surfaces better.

> **Same concept, different names.** **Single-pixel LiDAR** = **compressive LiDAR** = compressive depth imaging. **Time bin** = histogram bin = range bin. **Flying pixels** = **mixed pixels** = edge artifacts in depth maps. **Multiplex advantage** = Fellgett advantage (the spectroscopy name).

> **Summary**
> - Compressive LiDAR = single-pixel camera + timing detector: **B = A X**, one single-pixel problem per **time bin** (bin depth = **cΔt/2**, 0.15 m for 1 ns), all sharing the same **A**.
> - Each depth slice is sparse (ℓ₁ prior); each pixel has one main return; depth = strongest bin × bin depth.
> - Photon counts are Poisson, so the data term becomes **Σ[(Ax)_i − b_i log(Ax)_i]**; the MAP/ADMM recipe still applies.
> - TV suits depth maps: sharp edges, no flying pixels (11.67 m and 13.33 m invented by averaging vs. clean plateaus with TV), at a small contrast loss; slanted planes call for TGV.
> - Next: other imaging systems built on the same objective (§28).

---

# Part 8 — Compressive Imaging Elsewhere

## 28. CT, MRI and Hyperspectral Imaging

Slides 113–138 survey other inverse problems; all are "minimize ½‖**b** − **A x**‖² + λΨ(**x**)" with a different **A**.

**Computed tomography (CT, slides 129–131).** An x-ray source and a sensor rotate around the patient. Each reading is the total absorption along one straight line through the body; a full set of readings at one angle is a **projection**. The **Fourier slice theorem** links projections to the image: the 1D Fourier transform of the projection at angle θ equals the 2D Fourier transform of the image along a straight line through the origin at that same angle θ. So each angle fills in one line ("slice") of the image's 2D spectrum, and many angles fill the whole spectrum. **Compressive CT** uses fewer angles, so fewer slices, so less radiation dose and faster scans, with a prior filling in the gaps.

**Magnetic resonance imaging (MRI, slide 132).** An MRI scanner measures the image's Fourier coefficients directly (radiologists call the frequency domain **k-space**). **Compressive MRI** measures fewer (often randomly chosen) coefficients, shortening scans, which matters for patients who must hold still. Here **A** = "Fourier transform, then keep only the measured frequencies."

**Hyperspectral imaging (slides 134–137).** A **hyperspectral** image records many narrow wavelength bands per pixel (dozens to hundreds, instead of RGB's three): a 3D **datacube** (*x*, *y*, λ), here λ meaning wavelength. Conventional instruments scan, either over space (*x*, *y*) or over wavelength. **CASSI** (coded aperture snapshot spectral imager) captures the whole cube in one 2D photo: a **coded aperture** (a fixed random mask) patterns the light, then a **disperser** (a prism or grating, which bends each wavelength by a different amount) shifts each wavelength's copy sideways by a different distance, and all the shifted, masked copies land summed on one sensor. **A** = "mask, shift by wavelength, sum." Quality is moderate for a single snapshot, good with several coded shots (slide 137).

**A caution from medical imaging (slide 133).** Practitioners are "often hesitant about priors": there are few guarantees of success; if reconstruction breaks it is not clear how; and "is that feature a reconstruction artifact or the thing I'm looking for?" A prior can **hallucinate**: produce plausible-looking detail that was never measured (a learned prior trained on healthy anatomy might smooth away a small tumor, or invent a structure).

> **Same concept, different names.** **CT** = **computed tomography** = CAT scan. **Fourier slice theorem** = **projection-slice theorem** = central slice theorem. **k-space** = the frequency domain of an MRI image. **Hyperspectral** (many narrow bands) vs. **multispectral** (a handful of bands). **Datacube** = spectral cube. **Disperser** = prism or diffraction grating.

> **Summary**
> - CT: projections are slices of the 2D spectrum (Fourier slice theorem); compressive CT = fewer angles, less dose.
> - MRI measures Fourier coefficients directly; compressive MRI = fewer coefficients, faster scans.
> - Hyperspectral: CASSI codes and disperses a 3D (*x*, *y*, λ) cube onto one 2D sensor.
> - Rule to remember: **every one of these is ½‖b − Ax‖² + λΨ(x) with its own A**; priors help but can hallucinate.

---

## 29. Looking Ahead

The lecture's closing notes (slide 139), restated with where each idea was built:

- Compressive imaging is "an exploding area," and "most variants of compressive imaging problems can be implemented with ADMM" (§17–§26).
- "Increasingly we want to learn the sensing matrices, reconstruction using neural networks and datasets": designing **A** (the patterns, masks, optics) jointly with the reconstruction, the learned-prior idea of §21 and the unrolling of §22 taken one step further.
- The comparison on slide 98 (deconvolution at noise σ = 0.1) ranks the methods: Wiener clearly worst; Adam + TV and ADMM + TV close to each other; ADMM + DnCNN best.

**Where this goes next (optional).** Later weeks apply the same "forward model + prior + solver" pattern to new kinds of measurements (light fields, neural representations); whenever a new camera appears, ask: what is **A**, what is Ψ, and which solver step handles each?

> **Summary**
> - One objective (**½‖b − Ax‖² + λΨ(x)**), two solvers (Adam: easy and general; ADMM: split, exact prox steps, faster convergence), many priors (TV, denoisers).
> - Rule to remember: for any new imaging problem, identify **A** (with **A**ᵀ), choose Ψ, and plug both into ADMM.

---

# Part B — Glossary

Moved to the project's running, cumulative glossary so terminology stays in one place across all weeks: see [`glossary.md`](./glossary.md).

---

## Quick self-check

**Part 2.** If asked why the data term is a *squared* error and where λ comes from, you should be able to answer using only "Gaussian noise," "−log," "Bayes' rule," and "prior."

**Part 3.** If asked why TV keeps edges sharp but a squared-gradient penalty blurs them, use only "total climb," "ramp," and "ℓ₁." If asked why isotropic TV is "better," use only "same in every direction" and "diagonal edges."

**Part 4.** If asked why Adam's learning rate is easier to choose than gradient descent's step size, use only "running average," "typical gradient size," and "scale."

**Part 5.** If asked what each of ADMM's three steps does, use only "data prox," "prior prox," and "running sum of disagreements." If asked why the TV x-update for deconvolution needs no iterative solver but the single-pixel one does, use only "circulant," "Fourier domain," "division," and "conjugate gradient."

**Part 6.** If asked why the least-norm reconstruction of a single-pixel camera looks like noise, use only "weighted sum of patterns," "null space," and "prior."

**Part 7.** If asked how a single-pixel camera can measure depth, use only "time bin," "histogram," and "one single-pixel problem per bin." If asked why TV beats averaging on a depth map, use only "flying pixels" and "plateaus."
