# 05. Tight-binding model (graphene)

*English ・ [日本語](../ja/05_tight-binding.md) ・ [简体中文](../zh/05_tight-binding.md)*

[← 04. HOMO-LUMO](04_homo-lumo.md) | [Index](README.md) | [Appendix: cheat sheet →](90_reference.md)

**Goal**: extend the two-site tight-binding model of exercise 01 to a periodic
system and confirm that **model calculations (top-down) and first-principles
calculations (bottom-up) describe the same physics**.

**Directory**: [`TB_model/graphene/src/`](../../TB_model/graphene/src/)

---

## 5-1. The model

The π-electron system of graphene described by nearest-neighbour tight binding
on the A/B sublattices.

```
lattice vectors   a₁ = (1, 0),  a₂ = (-1/2, √3/2)
orbital sites     A = (0, 0),  B = (1/3, 2/3)      (fractional coordinates)
hopping           t = -2.8 eV  (3 nearest-neighbour A–B bonds)
```

This is the 2×2 matrix of exercise 01 transferred to k space:

```
H(k) = |  0      f(k)  |        f(k) = t · Σ_δ exp(i k·δ)
       | f*(k)    0    |
```

At the K point f(k) = 0, which produces the **Dirac cone**.

---

## 5-2. Running it

```bash
cd TB_model/graphene/src
source ../../../.venv/bin/activate
pip install pythtb pymatgen       # if not installed yet
python test.py
```

> `test.py` is the working script; `graphene.py` is only a template (imports).
> `pythtb` **2.0 or later** is required (it uses the `TBModel` / `Lattice` API).
> `pymatgen` is only used in the commented-out CIF export, but it is imported,
> so it must be installed.

**Verified** (pythtb 2.0.0 / about 10 s)

| Quantity | Value |
|---|---|
| Band width | about 17 eV ≈ 6\|t\| = 16.8 eV |
| K point | the two bands are degenerate at 0 eV (**Dirac point**) |
| PDOS(A) and PDOS(B) | identical |

### Output

| File | Content |
|---|---|
| `graphene_tb.png` | Left: band structure (K′–Γ–K–M–Γ) / Right: DOS and sublattice-resolved PDOS |

What is computed:

1. **Band structure** — `path = [K′, Γ, K, M, Γ]` sampled with 300 points
2. **DOS / PDOS** — the BZ is sampled on a 120×120 mesh, the density of states
   is built with Gaussian broadening (σ = 0.10 eV), and it is decomposed using
   the A/B components of the eigenvectors, |c_A|² and |c_B|²

---

## 5-3. Parameters to play with

| Variable | Default | Meaning |
|---|---|---|
| `t` | -2.8 | Nearest-neighbour hopping (eV) |
| `path`, `labels` | K′–Γ–K–M–Γ | Band path |
| `nk_path` | 300 | Number of k-points along the path |
| `nk_grid` | 120 | BZ mesh for the DOS (120×120) |
| `sigma` | 0.10 | Gaussian broadening of the DOS (eV) |
| `E_mesh` | -9 to 9 eV | Energy range of the DOS |

---

## 5-4. Tasks

1. Confirm that the bands are degenerate at the K point (Dirac point)
2. Vary `sigma` through 0.02 / 0.10 / 0.5 and compare how the van Hove
   singularities appear in the DOS
3. Vary `nk_grid` through 30 / 60 / 120 and see how smooth the DOS becomes
   (→ the same issue as k-point convergence of the DOS in 03-6)
4. Explain why the PDOS of A and B agree exactly, using the symmetry of the
   sublattices
5. **Add an on-site energy**: give A and B different on-site energies (±Δ) and
   see how the bands change. What does this correspond to physically?
   (Think of h-BN.)

---

## 5-5. Comparison with first principles

Compare with the QE results for graphene from 03-4.

```bash
# band calculation on the QE side (same procedure as silicon in 03-5)
cd 06_qe-examples/graphene/scf
```

| Aspect | TB model | QE (DFT) |
|---|---|---|
| Basis | 2 π orbitals | Plane waves (as many as `ecutwfc` allows) |
| Parameters | `t` is given by hand | Only the pseudopotential; t is a *result* |
| Cost | 2×2 matrix | SCF with thousands of degrees of freedom |
| Coverage | π bands only | All valence bands |

### Checklist

- [ ] You confirmed that the Dirac cone of the TB model also appears at the
      K point of the QE band structure
- [ ] You can estimate the model parameter `t` from the QE band width
      (the π band width of graphene ≈ 6|t|)
- [ ] You can explain the strengths and weaknesses of model calculations and
      first-principles calculations

---

[← 04. HOMO-LUMO](04_homo-lumo.md) | [Index](README.md) | [Appendix: cheat sheet →](90_reference.md)
