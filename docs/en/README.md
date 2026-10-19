# DFT Seminar Manual (English)

[🌐 Language](../../README.md) ・ English ・ [日本語](../ja/README.md) ・ [简体中文](../zh/README.md)

Hands-on exercise manual for the internal seminar
**"Density Functional Theory — Theory and Calculation"**
Laboratory for Chemistry and Life Science (CLS), Institute of Science Tokyo.

This manual is written so that a student newly joining the group can
**run every exercise simply by following this page from top to bottom**.

---

## How to proceed

1. Keep this page open in your browser and open one **Terminal** window
2. Complete [00. Environment setup](00_setup.md) (first time only, 1–2 hours)
3. Work through the exercises below **in order**
4. Move on once you can answer the "Checklist" at the end of each chapter

> **Read this first** → [00_setup.md](00_setup.md)

---

## Learning roadmap

| # | Chapter | Exercise directory | What you learn | Time |
|---|---|---|---|---|
| 00 | [Environment setup](00_setup.md) | `00_environment/` | Terminal, Homebrew, Git, Python, Quantum ESPRESSO | 1–2 h |
| 01 | [Self-consistent field (SCF)](01_scf.md) | `01_`, `02_` | `01_`: SCF loop, mixing / `02_`: Kohn-Sham equation (Hartree + exchange-correlation, double counting) | 1 h |
| 02 | [Basis sets and completeness](02_basis.md) | `03_`, `04_`, `05_` | Fourier expansion, completeness, plane waves, cutoff energy | 1.5 h |
| 03 | [Quantum ESPRESSO](03_quantum-espresso.md) | `06_qe-examples/` | SCF, relax, wavefunctions, bands, DOS, PDOS, phonons, k-point convergence, functional comparison, spin polarisation | 3–4 h |
| 04 | [HOMO-LUMO analysis](04_homo-lumo.md) | `07_homo-lumo/` | Visualising molecular orbitals and energy levels | 1 h |
| 05 | [Tight-binding model](05_tight-binding.md) | `TB_model/` | Linking TB models to first-principles calculations | 1 h |

**Appendix**

- [Command cheat sheet, external tools, troubleshooting](90_reference.md)

> Every exercise has been verified on **QE 7.5 / Open MPI 5.0.9 / phonopy 3.5.1 /
> pythtb 2.0.0 / macOS (Apple Silicon)**. Reference values and measured runtimes
> are given in each chapter — compare them against your own results.

---

## Theoretical background covered by the seminar

```
Many-body Schrödinger eq.   HΦ = EΦ        ← computationally impossible to solve directly
          ↓  Hohenberg-Kohn theorem         E = E[n]  (total energy is a functional of the density)
          ↓  Kohn-Sham theorem              (-½∇² + v_eff[n]) φᵢ = εᵢ φᵢ
          ↓  approximation to E_xc          LDA / GGA / meta-GGA / hybrid
          ↓  discretisation in a basis      plane waves + pseudopotentials
          ↓  solve self-consistently        SCF loop
      Quantum ESPRESSO (PWscf)
```

The exercises in this repository are arranged so that you confirm each step of
this flow **by hand, on the smallest possible model**.

| Step in the flow | Exercises |
|---|---|
| Kohn-Sham equation / approximating E_xc | 02 |
| Solving self-consistently | 01, 02 |
| Discretising in a basis | 03, 04, 05 |
| Real calculations with pseudopotentials + plane waves | 06, 07 |
| Relating models to first-principles results | TB_model |

---

## Repository layout

```
DFT_seminar_materials/
├── README.md                       ← language selection page
├── requirements.txt                 Python dependencies
├── docs/
│   ├── en/                          English manual (this directory)
│   ├── ja/                          Japanese manual
│   └── zh/                          Simplified Chinese manual
├── 00_environment/                  vim / tmux configuration examples
├── 01_2-site-convergence/           exercise 01: SCF loop and mixing (on-site = U·n)
├── 02_2-site-KSeq-convergence/      exercise 02: Kohn-Sham equation (v_eff = V_H + V_xc)
├── 03_sinx_fitting/                 exercise 03: Fourier expansion of a square wave (Gibbs phenomenon)
├── 04_sinx-cosx/                    exercise 04: an odd function in a cos basis (basis symmetry)
├── 05_gaussian-plane-wave-fitting/  exercise 05: a Gaussian in a plane-wave basis (cutoff energy)
├── 06_qe-examples/                  exercise 06: real QE runs (H₂O, graphene/graphite, Si bands/DOS/phonons,
│                                            k-point convergence, LDA vs PBE, O₂ spin polarisation)
├── 07_homo-lumo/                    exercise 07: HOMO-LUMO of F₂ (relax → SCF → orbital visualisation)
├── TB_model/                        exercise 08: tight-binding graphene (Dirac cone, vs. first principles)
└── 99_slides/                       lecture slides (git-ignored, see below)
```

> `KSeq` in `02_2-site-KSeq-convergence/` stands for **K**ohn-**S**ham **eq**uation
> (not "k-point sequence"). Exercise 02 replaces the on-site energy `U·n` of
> exercise 01 with the Kohn-Sham effective potential `v_eff = V_H + V_xc`.

> `99_slides/` is **not included in the repository** (git-ignored).
> Lecture slides, exercise sheets and homework are distributed separately by
> the organiser.

---

## When you get stuck

1. Check "Troubleshooting" in [90_reference.md](90_reference.md)
2. Copy the full error message and search for it
3. If that does not help, ask — and include **the command you ran** and
   **the complete error output**

---

[Next: 00. Environment setup →](00_setup.md)
