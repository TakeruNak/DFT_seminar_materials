# 01. Self-consistent field (SCF)

*English ・ [日本語](../ja/01_scf.md) ・ [简体中文](../zh/01_scf.md)*

[← 00. Environment setup](00_setup.md) | [Index](README.md) | [Next: 02. Basis sets →](02_basis.md)

**Goal**: experience, on a minimal two-site model, that the Kohn-Sham equation
has a circular structure — you need the solution in order to find the
solution — and that this is resolved by iteration (the SCF loop) with mixing.

```
         ┌──────────────────────────────────────────┐
         ↓                                          │
  n(r) → v_eff[n] → solve KS eq. → φᵢ → n'(r) ──────┘
                                      │
                         converged when |n' - n| < tol
```

---

## Exercise 01: self-consistency in a 2-site tight-binding model

**Directory**: [`01_2-site-convergence/`](../../01_2-site-convergence/)

### The model

A two-site model of a diatomic molecule. The on-site energy depends on the
electron density on that same site.

```
H = | U·n₁   -t   |      εᵢ = U·nᵢ  (on-site energy)
    |  -t   U·n₂  |      t         (hopping)
```

Update the density from the ground-state eigenvector ψ, rebuild H, repeat.

### Running it

```bash
cd 01_2-site-convergence
source ../.venv/bin/activate
python 2-site-convergence.py
```

### Output

| File | Content |
|---|---|
| `density.png` | Densities n₁, n₂ versus iteration |
| `energy.png` | Ground-state energy versus iteration |
| `residual.png` | Residual \|Δn\| (logarithmic axis) |

`Converged at iteration N` on stdout means it converged.

### Parameters to play with

Edit the top of the script and re-run.

| Variable | Default | Meaning | What to try |
|---|---|---|---|
| `U` | 2.0 | Strength of the on-site interaction | Larger values diverge / oscillate more easily |
| `t` | 2.0 | Hopping | |
| `alpha` | 0.1 | **Mixing parameter** | Closer to 1.0 is faster but diverges more easily |
| `tol` | 1e-6 | Convergence criterion | |
| `n1, n2` | 3.0, 2.0 | Initial densities (asymmetric) | What happens if you make them symmetric? |

### Tasks

1. Set `alpha = 1.0` (no mixing) and see what happens to `residual.png`
2. Try `alpha` = 0.05 / 0.1 / 0.5 / 1.0 and record the number of iterations
3. Raise `U` from 2.0 to 10.0 — how does the range of `alpha` that still
   converges change?

### Checklist

- [ ] You can explain why one single calculation is not enough and iteration is needed
- [ ] You can explain what the mixing parameter does
- [ ] You can explain why the residual plot uses a logarithmic axis

---

## Exercise 02: pseudo Kohn-Sham equation for a 2-site model

**Directory**: [`02_2-site-KSeq-convergence/`](../../02_2-site-KSeq-convergence/)

### The model

The on-site energy of exercise 01 is replaced by the Kohn-Sham effective
potential `v_eff`.

```
v_eff(n) = V_H(n) + V_xc(n)
V_H(n)   = U·n                 ← Hartree term (classical Coulomb)
V_xc(n)  = -A·√n               ← exchange-correlation, mimicking the √n of LDA
```

Note that the total energy is **not** simply the sum of the KS eigenvalues:

```
E_tot = ε_KS - E_H + E_xc        (double-counting correction)
E_H   = ½U(n₁² + n₂²)
E_xc  = -(2/3)A(n₁^1.5 + n₂^1.5)
```

### Running it

```bash
cd 02_2-site-KSeq-convergence
python 2-site-KSeq.py
```

### Output

| File | Content |
|---|---|
| `density.png` | Convergence of the densities |
| `energy.png` | Convergence of the total energy |
| `residual.png` | Residual (logarithmic axis) |
| `vxc.png` | V_xc versus iteration |
| `totalN.png` | Particle-number conservation (compare with the dashed line at 1.0) |
| `vxc_vs_density.png` | How the solution moves along the V_xc(n) curve |
| `veff_vs_density.png` | How the solution moves along the V_eff(n) curve |

### Parameters to play with

| Variable | Default | Meaning |
|---|---|---|
| `U` | 4.0 | Strength of the Hartree term |
| `A` | 10.0 | **Strength of the exchange-correlation term** |
| `t` | -1.0 | Hopping |
| `alpha` | 0.2 | Mixing parameter |
| `n1, n2` | 1.0, 0.0 | Initial densities |

### Tasks

1. Run with `A = 0` (no exchange-correlation) and compare the density
   distribution with exercise 01
2. Raise `A` through 0 → 5 → 10 → 20 and follow where the solution settles in
   `vxc_vs_density.png`
3. Check `totalN.png` — is the particle number conserved?
4. **Self-interaction error (SIE)**: as `totalN.png` shows, this system holds only
   **one** electron (the density is built from the normalised ground-state
   eigenvector, so n₁ + n₂ = 1 always). Applying a Hartree term `V_H = U·n` to a
   single electron means **the electron repels itself**. For a one-electron system
   E_H and E_xc must cancel exactly. Compare the ground state at `U = 0` and
   `U = 4` and decide which one is physically correct.

> **Why this matters**
>
> The error you just saw is the **self-interaction error (SIE)**, one of the
> biggest weaknesses of LDA / GGA. In exercise 3-5 you will meet the fact that
> PBE/LDA underestimates the band gap of silicon — SIE is one of its main causes.
> Hybrid functionals (HSE, B3LYP) mix in exact exchange precisely to cancel part
> of this error.

### Checklist

- [ ] You can explain the different roles of the Hartree and exchange-correlation terms
- [ ] You can explain why `E_tot = ε_KS - E_H + E_xc` contains a subtraction (double counting)
- [ ] You can explain that the KS eigenvalue ε and the total energy E are different things
- [ ] You can explain what is wrong with applying a Hartree term to a one-electron system (SIE)

---

## Summary

| Concept | What you saw here | Counterpart in real DFT |
|---|---|---|
| SCF loop | Repeated diagonalisation of a 2×2 matrix | Iterative solution of a KS equation with 10⁴–10⁵ dimensions |
| Mixing | `alpha` | `mixing_beta` (QE `&ELECTRONS`) |
| Convergence criterion | `tol` | `conv_thr` (QE `&ELECTRONS`) |
| v_eff | `U·n - A·√n` | Hartree + LDA/GGA functional |

→ The same quantities reappear in exercise 03 as QE's **`mixing_beta` / `conv_thr`**.

---

[← 00. Environment setup](00_setup.md) | [Index](README.md) | [Next: 02. Basis sets →](02_basis.md)
