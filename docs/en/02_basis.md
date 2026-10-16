# 02. Basis sets and completeness

*English ・ [🌐 日本語](../ja/02_basis.md)*

[← 01. Self-consistent field](01_scf.md) | [Index](README.md) | [Next: 03. Quantum ESPRESSO →](03_quantum-espresso.md)

**Goal**: to handle a differential equation on a computer you must expand the
function in a basis and turn the problem into linear algebra. These exercises
let you feel the three properties that matter when you do that —
**completeness / orthogonality / boundary conditions**.

```
-½∇²φ(r) + V(r)φ(r) = εφ(r)        φ(r) = Σ cᵢ gᵢ(r)
          ↓  expand in a basis
     H c = ε c                      (matrix eigenvalue problem — solvable by a computer)
```

| Exercise | Question |
|---|---|
| 03 | What happens if you expand a non-periodic function in a periodic basis? |
| 04 | Can even functions alone represent an odd function? (completeness) |
| 05 | How many plane waves does a localised function need? (cutoff energy) |

---

## Exercise 03: expanding a square wave in sines

**Directory**: [`03_sinx_fitting/`](../../03_sinx_fitting/)

### What it does

Approximates the square wave `y = sign(sin x)` as a superposition of
odd-order sine functions.

```
f(x) ≈ Σ_{k=1}^{N} (4/π) · sin((2k-1)x) / (2k-1)
```

### Running it

```bash
cd 03_sinx_fitting
source ../.venv/bin/activate
python fourier.py
```

The default is `N_list = [1]` (a single basis function). A plot window opens.

### Tasks

1. Extend `N_list` from `[1]` to e.g. `[1, 3, 5, 10, 50]`, and change
   `plt.subplot(1, 1, i+1)` to `plt.subplot(len(N_list), 1, i+1)` so the
   results are shown side by side
2. Observe the oscillation that remains near the discontinuity as you add
   basis functions (**Gibbs phenomenon**)
3. Change to `x = np.linspace(-3*np.pi, 3*np.pi, 1000)` and see what happens
   outside the expansion interval `[-π, π]`

### Checklist

- [ ] You confirmed that more basis functions give a better approximation (completeness)
- [ ] You confirmed that the expansion **repeats periodically** outside the interval
- [ ] You can explain what goes wrong when a non-periodic function is expanded in a periodic basis

> This is exactly why **periodic boundary conditions / vacuum layers** matter
> in first-principles calculations.

---

## Exercise 04: expanding an odd function in an even basis

**Directory**: [`04_sinx-cosx/`](../../04_sinx-cosx/)

### What it does

Tries to expand the odd function `sin(x)` using **cosines only**.

```
odd   f(x) = -f(-x)       e.g. sin(x)
even  g(x) =  g(-x)       e.g. cos(kx)

coefficients  a_k = ∫ f(x)·cos(kx) dx / normalisation     ← inner product (projection)
```

### Running it

```bash
cd 04_sinx-cosx
python odd-by-even-rep.py
```

The coefficients `a_0 … a_N` are printed, and the plot shows the original
function together with the approximation.

### Tasks

1. Look at the printed coefficients `a_k` — what is happening?
2. Confirm that increasing `N = 10` to `N = 100` does not improve anything
3. Confirm that adding sine functions does work
   (a complete version is in `.answear/odd-by-full-rep.py`)

### Checklist

- [ ] You can explain from the coefficients why cosines alone cannot represent a sine
- [ ] You can explain what "the basis set is not complete" means
- [ ] You can relate this to the three-primary-colour example
      (Red + Blue alone cannot make every colour)

---

## Exercise 05: expanding a Gaussian in plane waves

**Directory**: [`05_gaussian-plane-wave-fitting/`](../../05_gaussian-plane-wave-fitting/)

A Gaussian — standing in for an electron orbital localised around a nucleus —
is expanded in a **plane-wave basis**, exactly the basis Quantum ESPRESSO uses.

### Plane waves and the cutoff energy

```
-½∇² φ(x) = ε φ(x)        →   φ_m(x) = exp( i·2πm·x / L ),  m ∈ ℤ

kinetic energy of each plane wave   ε_m = ½ · (2πm/L)²
keeping everything up to E_cut      →  |m| ≤ L·√(2E_cut) / 2π
```

**Raising E_cut = including higher-frequency basis functions = being able to
describe sharper features.**

### 05-A: one-shot (a single E_cut)

```bash
cd 05_gaussian-plane-wave-fitting/one-shot
python wf-fitting.py
```

`Energy cutoff / k_max / n_max` and the relative error (RSE) are printed.

| Variable | Default | Meaning |
|---|---|---|
| `E_list` | `[20]` | Cutoff energies to try |
| `L` | 20.0 | Half-width of the box (period is 2L) |
| `N` | 400 | Number of real-space grid points |
| `gaussian()` | sum of two Gaussians | The target function |

**Task**: change `E_list = [20]` to `[0.5]`, `[2]`, `[50]` and look at the
relation between the number of basis functions `n_max` and the quality of the fit.

### 05-B: convergence (cutoff dependence in one go)

```bash
cd 05_gaussian-plane-wave-fitting/convergence
python wf-fitting.py
```

Output:

| File | Content |
|---|---|
| `convergence_wave.png` | Reconstructed waveforms for each E_cut, overlaid |
| `convergence.png` | Relative error (RSE) vs E_cut (logarithmic axis) |

The default is `E_list = [0.5, 1, 2, 5, 10, 20]`.

### Tasks

1. Read off from `convergence.png` the E_cut at which the error drops to a
   practically acceptable level
2. Narrow the Gaussian width `sigma` from 1.0 to 0.3 and re-run — how does the
   required E_cut change?
3. Enable the two-peak function (`def wf(x)`) that is commented out in the
   script and repeat the study

### Checklist

- [ ] You can explain that raising the cutoff energy means adding higher-frequency basis functions
- [ ] You can explain why a more localised function requires a higher cutoff
- [ ] You can explain why describing core electrons directly with plane waves is
      impractical (→ **pseudopotentials**)

---

## Summary

| Property | Exercise | How it appears in QE |
|---|---|---|
| Periodicity / boundary conditions | 03 | Periodic boundary conditions, vacuum layers for molecules |
| Completeness | 04 | Choice of basis set (plane waves vs localised) |
| Cutoff energy | 05 | `ecutwfc`, `ecutrho` (`&SYSTEM`) |
| Handling localisation | 05 | Pseudopotentials (core replaced by a smooth function) |

---

[← 01. Self-consistent field](01_scf.md) | [Index](README.md) | [Next: 03. Quantum ESPRESSO →](03_quantum-espresso.md)
