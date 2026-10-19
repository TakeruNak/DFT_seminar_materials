# 03. Quantum ESPRESSO

*English ・ [日本語](../ja/03_quantum-espresso.md) ・ [简体中文](../zh/03_quantum-espresso.md)*

[← 02. Basis sets](02_basis.md) | [Index](README.md) | [Next: 04. HOMO-LUMO →](04_homo-lumo.md)

**Goal**: run the whole basic workflow — SCF → structure relaxation →
wavefunctions → bands → DOS → PDOS — with Quantum ESPRESSO (QE), an
*ab initio* code based on plane waves plus pseudopotentials.

> Make sure `pw.x` runs first — see
> [00. Environment setup](00_setup.md#0-7-quantum-espresso).

---

## 3-0. Common rules (read this first)

### How to run

Every exercise directory has the same layout.
**Edit `system.in`, then run `./run-local.sh`. That is all.**

```bash
cd 06_qe-examples/<example directory>
cat system.in          # check the settings
./run-local.sh         # run
```

### The three lines of `system.in`

```
NAME h2o            ← prefix of the input file; h2o for h2o.scf.in
CAL  scf            ← type of calculation
NUM_PROCS 6         ← number of MPI processes; keep it ≤ your physical core count
```

The main values `CAL` can take:

| `CAL` | What is executed |
|---|---|
| `scf` | SCF with `pw.x` |
| `nscf` | SCF → non-SCF with `pw.x` |
| `relax` | Relaxation of atomic positions with `pw.x` |
| `vc-relax` | Relaxation of atomic positions **and** lattice constants |
| `bands` | SCF → NSCF → `bands.x` → plot preparation |
| `dos` | SCF → NSCF → `dos.x` |
| `proj` | NSCF → `projwfc.x` → plot preparation |
| `wf` | SCF → `pp.x` (writes the wavefunction as a cube file) |
| `cd` | SCF → `pp.x` (writes the charge density as a cube file) |

### What is in a directory

| File | Role |
|---|---|
| `system.in` | Run control (the three lines above) |
| `run-local.sh` | Run script. QE binaries are resolved from `PATH` or `$QE_BIN_DIR` |
| `<NAME>.scf.in` etc. | QE input files |
| `pseudo/` | Pseudopotentials (`.UPF`) |
| `out/` | Scratch directory created by the run (git-ignored) |
| `<NAME>.*.out` | Calculation logs |

### Looking inside a pseudopotential (5 min)

Exercise 05 concluded that representing core electrons directly in plane waves
is impractical. The fix is the `.UPF` files sitting in `pseudo/` — and they are
readable text:

```bash
cd 06_qe-examples/h2o/scf
grep -iE 'element=|z_valence|pseudo_type|functional=' pseudo/*.UPF
```

```
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   element=" H"
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   pseudo_type="USPP"
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   functional="PBE"
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   z_valence="1.000000000000000E+000"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    element=" O"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    pseudo_type="PAW"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    functional=" SLA  PW   PBX  PBC"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    z_valence="6.000000000000000E+000"
```

| Field | Meaning |
|---|---|
| `z_valence` | **How many electrons are actually solved for**: 6 for O, not 8 (the 1s² is frozen); 1 for H |
| `functional` | The functional this pseudopotential was generated with (PBE, PZ, …) |
| `pseudo_type` | `NC` (norm-conserving) / `US` (ultrasoft) / `PAW` |

The file name itself follows a convention (`O.pbe-n-kjpaw_psl.0.1.UPF`
= element O / PBE / PAW). H₂O therefore has 6 + 1 + 1 = **8** valence electrons,
matching `number of electrons = 8.00` in `*.scf.out`. Only 4 bands are occupied,
yet `number of Kohn-Sham states` reads **8**: `occupations = 'smearing'` makes QE
add empty bands — the same reason 3-1 lists 8 eigenvalues.

**Check that you can**

1. Add up `z_valence` for your example and reconcile it with the valence
   electron count and `nbnd` in `&SYSTEM`
2. Look up the **recommended `ecutwfc`** for that element on
   [SSSP](https://www.materialscloud.org/discover/sssp/) and compare it with the
   value in the input file (the same cutoff convergence story as task 2 of 3-1)
3. Explain why LDA and PBE pseudopotentials must not be mixed in one calculation

> When `pseudo_type` is `US` or `PAW`, `ecutrho` must be 8–12 × `ecutwfc`
> (4 × is enough for `NC`). If the ratio is too small the SCF will not converge.

---

### Structure of a QE input file

```
&CONTROL     calculation type and I/O (calculation, prefix, outdir, pseudo_dir)
&SYSTEM      definition of the system (ecutwfc, ecutrho, nat, ntyp, occupations, nbnd)
&ELECTRONS   SCF control (conv_thr, mixing_beta, electron_maxstep)
&IONS        relaxation control (relax runs only)
&CELL        cell relaxation control (vc-relax only)
ATOMIC_SPECIES    elements and their pseudopotentials
ATOMIC_POSITIONS  atomic coordinates
K_POINTS          k-point mesh / path
CELL_PARAMETERS   lattice vectors
```

**Correspondence with exercises 01, 02 and 05**:

| Name in the exercises | QE parameter |
|---|---|
| Mixing parameter `alpha` | `mixing_beta` |
| Convergence criterion `tol` | `conv_thr` |
| Cutoff energy `E_cut` | `ecutwfc` (wavefunctions), `ecutrho` (charge density) |

> For the meaning of each parameter see the official documentation:
> https://www.quantum-espresso.org/Doc/INPUT_PW.html

---

## 3-1. SCF calculation (H₂O)

**Directory**: [`06_qe-examples/h2o/scf/`](../../06_qe-examples/h2o/scf/)

Because this is an isolated molecule, a 10 Å cubic cell provides a vacuum
layer that suppresses the effect of the periodic boundary conditions
(→ the property of periodic bases you saw in exercise 03).

```bash
cd 06_qe-examples/h2o/scf
cat system.in            # NAME h2o / CAL scf
./run-local.sh
```

### Reading the results

```bash
grep '!' h2o.scf.out                      # converged total energy
grep 'estimated scf accuracy' h2o.scf.out # evolution of the residual
grep -i 'Fermi' h2o.scf.out               # Fermi level
grep 'Total force' h2o.scf.out            # residual force
grep -A6 'End of self-consistent calculation' h2o.scf.out   # eigenvalues (eV)
```

> Every example in this repository uses `occupations = 'smearing'`, so QE
> prints `the Fermi energy is ...`. The line `highest occupied level` only
> appears with `occupations = 'fixed'`, so grepping for it returns nothing.

**Verified reference values** (QE 7.5 / 6 MPI / 20 s)

| Quantity | Value |
|---|---|
| Total energy | `-44.04045673 Ry` |
| Fermi level | `-4.1193 eV` |
| Eigenvalues (eV) | `-25.1858 -12.9610 -9.2120 -7.1077 -0.9506 0.4281 0.7307 1.0887` |
| Residual force | `0.004066` |

If you get the same numbers, your environment is working correctly.

### Tasks

1. Look at how `estimated scf accuracy` evolves — does it have the same shape
   as `residual.png` from exercise 01?
2. Lower `ecutwfc` from 60 → 30 → 20 and record the change in total energy
   (**cutoff convergence test**)
3. Change `mixing_beta` from 0.4 to 0.1 / 0.9 and record how the number of
   SCF steps changes

> `ecutrho` is normally 4× `ecutwfc` (norm-conserving) or 8–12× (ultrasoft/PAW).

### Handling structure files

```bash
obabel input.sdf -O output.xyz --gen3d    # format conversion
open -a VESTA output.xyz                  # visualisation
```

For where to get structures see
[90_reference.md](90_reference.md#structure-databases).

---

## 3-2. Structure relaxation (H₂O relax)

**Directory**: [`06_qe-examples/h2o/relax/`](../../06_qe-examples/h2o/relax/)

```bash
cd 06_qe-examples/h2o/relax
./run-local.sh           # CAL relax
```

### Reading the results

```bash
grep -A6 'ATOMIC_POSITIONS' h2o.relax.out | tail -20   # final structure
grep 'Total force' h2o.relax.out                       # force convergence
grep '!' h2o.relax.out                                 # total energy per step
```

The relaxed structure is saved as `h2o.relax.vasp`.

### Where the forces come from (Hellmann-Feynman theorem)

The forces printed by `grep 'Total force'` are **not** obtained by numerical
differentiation. Differentiating the energy with respect to a nuclear
coordinate R gives

```
F = -dE/dR = -⟨ψ| ∂H/∂R |ψ⟩        ← Hellmann-Feynman theorem
```

in which **the derivative of the wavefunction ∂ψ/∂R drops out**. So once a
single SCF cycle has produced the density n(r), the forces follow
**analytically**.

```
solve SCF → n(r) → forces F → move the atoms → solve SCF again …   (= relax)
```

If forces could only be obtained by numerical differentiation, each atom would
need at least 6 extra SCF runs and relaxation would be impractical. **This
theorem is what turned DFT into a structure-prediction tool.**

> With basis functions attached to the atoms (localised bases), ∂ψ/∂R does not
> fully drop out and a correction called the **Pulay force** is required. Plane
> waves do not depend on the atomic positions, which is one reason QE can report
> forces directly.

**Verified reference values** (6 MPI / 1 min)

| Quantity | Value | Experiment |
|---|---|---|
| Total energy | `-44.04046586 Ry` | — |
| O–H bond length | 0.970 Å | 0.958 Å |
| H–O–H bond angle | 104.2° | 104.5° |
| Final total force | `0.000152` | — |

### Tasks

1. Compute the O–H bond length and H–O–H angle before and after relaxation and
   compare with experiment (0.958 Å, 104.5°).
   (The coordinates are fractional; the cell is a 10 Å cube, so multiply
   differences by 10 to get Å.)
2. Relax `forc_conv_thr` from 1e-4 to 1e-3 — how do the number of steps and the
   final structure change?

---

## 3-3. Visualising wavefunctions (H₂O wf)

**Directory**: [`06_qe-examples/h2o/wf/`](../../06_qe-examples/h2o/wf/)

The Kohn-Sham orbitals φᵢ obtained from SCF are written as cube files by
`pp.x` and viewed in VESTA.

```bash
cd 06_qe-examples/h2o/wf
cat h2o.wf.in            # which orbital to output
./run-local.sh           # CAL wf: scf -> pp.x
open -a VESTA h2o_G2.cube
```

### Key points of `h2o.wf.in`

```
&inputpp
    plot_num = 7        ! 7 = |ψ|² of a Kohn-Sham orbital
    kpoint   = 1        ! which k-point
    kband    = 2        ! ★ which band (orbital)
    lsign    = .true.   ! keep the sign of the wavefunction
/
&plot
    iflag         = 3   ! 3D output
    output_format = 6   ! 6 = Gaussian cube
    fileout       = 'h2o_G2.cube'
/
```

### Tasks

1. Change `kband` to 1, 2, 3, 4, 5, re-run, and view each cube in VESTA
   (remember to change `fileout` as well)
2. Count the valence electrons of H₂O, work out which band is the HOMO, and
   identify HOMO / LUMO
3. Compare with the existing results in `wf_png/`

**Verified** (6 MPI / 1 min): `h2o_G2.cube` (about 32 MB) is produced.

> `.cube` files are huge (tens of MB) and are git-ignored. Do not commit them.
> `pp.x` also writes an intermediate file `tmp.pp`, which is similarly large.

---

## 3-4. SCF for periodic systems (graphene / graphite)

### graphene (2D)

**Directory**: [`06_qe-examples/graphene/scf/`](../../06_qe-examples/graphene/scf/)

```bash
cd 06_qe-examples/graphene/scf
./run-local.sh
grep '!' graphene.scf.out
```

**Verified** (4 MPI / 2 s): total energy `-36.86820864 Ry`, Fermi level `-1.6568 eV`

Points to note:

- `K_POINTS automatic` is `6 6 1` ← **mesh in-plane only, a single point out of plane**
- A vacuum layer along the c axis removes the interaction between layers

The wavefunction can be output the same way:

```bash
cd ../wf
./run-local.sh           # CAL wf, kband=6
open -a VESTA graphene_G6.cube
```

### graphite (3D, vc-relax)

**Directory**: [`06_qe-examples/graphite/`](../../06_qe-examples/graphite/)

```bash
cd 06_qe-examples/graphite/vc-relax
./run-local.sh                              # relax lattice constants + atomic positions
grep -A5 'CELL_PARAMETERS' graphite.vc-relax.out | tail -10

cd ../scf
./run-local.sh
```

**Verified**

| Calculation | Time (8 MPI) | Result |
|---|---|---|
| `vc-relax` | 4 min 30 s | a = 2.4673 Å, c = 7.9009 Å → **interlayer distance 3.95 Å** |
| `scf` | 9 s | total energy `-73.77286739 Ry` |

> The `scf` output contains `Minimization algorithm failed to find Fermi
> energy: reverting to bisection`. This is a warning, not an error — finding
> the Fermi level is hard for this semi-metallic system, so QE falls back to
> the more robust bisection method.

### Tasks

1. Change graphene's `K_POINTS` to `3 3 1` / `6 6 1` / `12 12 1` and compare
   total energies (**k-point convergence test**)
2. Change the vacuum layer along the surface normal (the c entry of
   `CELL_PARAMETERS`) and watch the energy
3. Work out the relaxed interlayer distance of graphite and compare with
   experiment (3.35 Å). Investigate why PBE does not reproduce it
   (van der Waals interaction)

---

## 3-5. Band structure (silicon)

**Directory**: [`06_qe-examples/sillicon/bands/`](../../06_qe-examples/sillicon/bands/)

```
SCF (pw.x) → NSCF with calculation='bands' (pw.x) → bands.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/bands
./run-local.sh           # CAL bands; chbandplot_mac.sh prepares band.plt at the end
gnuplot band.plt         # a plot window opens
```

> `chbandplot_mac.sh` depends on **`gsed` (GNU sed)**.
> If it is missing: `brew install gnu-sed`.

`chbandplot_mac.sh` reads the Fermi level from `silicon.scf.out` and rewrites
the `ef = ...` line, the k-point coordinates and the vertical lines in
`band.plt` automatically.

**To save a PDF**, uncomment the last three lines of `band.plt`.
(Unlike `dos.plt` / `projwfc.plt`, `band.plt` does not write a PDF by default.)

```gnuplot
set term pdfcairo enhanced size 4in, 3in font "Times New Roman,18"
set output "bands.pdf"
replot
```

> `band.plt` contains `pause -1`, so after the window appears
> **gnuplot will not exit until you press Enter in the Terminal**.

### The band path

`K_POINTS crystal_b` in `silicon.nscf.in` defines Γ–X–U–K–Γ–L–W–X.
The path is determined by the crystal symmetry. For your own system use
[SeeK-path](https://www.materialscloud.org/work/tools/seekpath).

**Verified** (6 MPI / 6 s)

| Quantity | Value |
|---|---|
| Fermi level | `6.7675 eV` |
| VBM (Γ) | `6.3959 eV` |
| CBM (near X) | `7.0704 eV` |
| **Indirect gap** | **0.67 eV** (experiment 1.17 eV) |

### Tasks

1. Read the band gap of Si from `silicon.band.gnu` and compare with experiment (1.17 eV)
2. Investigate why PBE/LDA underestimate the band gap
   (one of the main causes is the **self-interaction error (SIE)** you met in
   [task 4 of exercise 02](01_scf.md))
3. The default path samples only 2 points per segment, so the bands look like
   straight line segments. Increase the number at the end of each line of
   `K_POINTS crystal_b` in `silicon.nscf.in` to about 20 for a smooth plot
4. Increase `nbnd` in `silicon.nscf.in` to plot higher bands

---

## 3-6. Density of states, DOS (silicon)

**Directory**: [`06_qe-examples/sillicon/dos/`](../../06_qe-examples/sillicon/dos/)

```
SCF (pw.x) → NSCF on a dense mesh (pw.x) → dos.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/dos
./run-local.sh              # CAL dos  ★ takes 7–8 minutes
./chdosplot_mac.sh silicon  # write the Fermi level into dos.plt
gnuplot dos.plt             # plots and writes dos.pdf automatically (Enter to exit)
```

> **Why it is slow**: the NSCF `K_POINTS automatic` is `50 50 50`, which gives
> 11050 irreducible k-points. Reduce it to `20 20 20` if you are just trying it out.

**Verified** (6 MPI / 7 min 23 s): `silicon.dos` and `dos.pdf` are produced.
Fermi level `6.7675 eV`.

### Tasks

1. Put the DOS next to the band plot from 3-5 and confirm the gap is at the
   same position
2. Change `degauss` in `silicon.dos.in` from 0.01 to 0.05 and see the effect of
   the broadening
3. Make the NSCF k-point mesh coarser and see how the DOS degrades

---

## 3-7. Projected density of states, PDOS (silicon)

**Directory**: [`06_qe-examples/sillicon/pdos/`](../../06_qe-examples/sillicon/pdos/)

Each state is projected onto atomic orbitals (s, p, d) to show which orbital
it comes from.

> The `CAL proj` branch **starts from NSCF** (it does not run SCF).
> Starting from an empty `out/`, you must run SCF first.

```bash
cd 06_qe-examples/sillicon/pdos

# 1) run SCF first (4 s)
sed -i '' 's/^CAL  proj/CAL  scf/' system.in
./run-local.sh

# 2) run PDOS (★ 3–4 minutes; the NSCF mesh is 50x50x50)
sed -i '' 's/^CAL  scf/CAL  proj/' system.in
./run-local.sh

# 3) plot (writes projwfc.pdf automatically; Enter to exit)
gnuplot projwfc.plt
```

> The `proj` branch of `run-local.sh` ends by calling `chprojwfcplot_mac.sh`,
> which lists all generated `*pdos_atm*` files in the plot commands of
> `projwfc.plt` automatically.

The files `silicon.pdos.pdos_atm#1(Si)_wfc#1(s)` and so on are the projected
components.

**Verified** (6 MPI / SCF 4 s + PROJ 3 min 40 s)

| Quantity | Value |
|---|---|
| SCF total energy | `-22.83713469 Ry` |
| Files produced | `pdos_atm#1(Si)_wfc#1(s)`, `#wfc#2(p)`, the same for atom 2, and `pdos_tot` |
| Plot | `projwfc.pdf` |

### Tasks

1. The legend entries inserted by `chprojwfcplot_mac.sh` all read
   `title 'title'`. Edit `projwfc.plt` to use meaningful labels such as
   `Si-3s` / `Si-3p`
2. Decide whether the top of the valence band and the bottom of the conduction
   band are mainly s or p
3. Uncomment the relevant lines in `projwfc.plt` and confirm that
   `silicon.pdos.pdos_tot` agrees with the DOS from 3-6

---

## 3-8. Phonon calculation (silicon, advanced)

**Directory**: [`06_qe-examples/sillicon/phonon/`](../../06_qe-examples/sillicon/phonon/)

The finite-displacement method with phonopy. **Only if you have time.**

### phonopy version (important)

The scripts in this directory and
[`howtouse.md`](../../06_qe-examples/sillicon/phonon/howtouse.md)
assume the **phonopy 3.x or earlier CLI**.
In phonopy 4, `-d` / `-f` / `-c` were moved to a separate command
`phonopy-init`, so the commands below fail as they are.

```bash
pip install "phonopy<4"          # verified with 3.5.1
```

### Procedure (verified)

```bash
cd 06_qe-examples/sillicon/phonon

# 1) generate the 2x2x2 supercell and the displacement patterns
phonopy --qe -d --dim="2 2 2" -c silicon.scf.in
#   → supercell-001.in, phonopy_disp.yaml

# 2) make nat in header.in match the number of atoms in the supercell
#    (the default nat = 16 already matches), then assemble the QE inputs
./attach_header_mac.sh           # → silicon-001.in
python making_script_mac.py      # → phonopy_mac.sh

# 3) SCF for each supercell (★ 8–9 minutes)
chmod +x phonopy_mac.sh
./phonopy_mac.sh                 # → silicon-001.out

# 4) force constants
phonopy -f silicon-001.out       # → FORCE_SETS

# 5) band structure
phonopy --qe -c silicon.scf.in -p band.conf          # → band.yaml
phonopy-bandplot --gnuplot band.yaml > gnuplot_band.dat

# 6) PDOS
phonopy -p pdos.conf             # → projected_dos.dat
```

**Verified** (phonopy 3.5.1, QE 7.5, 6 MPI)

| Quantity | Value |
|---|---|
| Supercell | 16 atoms / 1 displacement pattern / space group Fd-3m (227) |
| Supercell SCF | 8 min 36 s |
| Phonon frequencies | 0.00 – **15.28 THz** (experimental optical mode ≈ 15.5 THz) |

### Tasks

1. Change `BAND` in `band.conf` to plot the dispersion along a different path
2. What improves if you use `--dim="3 3 3"` instead of `"2 2 2"`?
   (The computational cost grows considerably.)
3. Confirm that the acoustic modes go to zero at Γ — if they do not, the force
   constants are inaccurate

---

## 3-9. k-point convergence test (silicon)

**Directory**: [`06_qe-examples/sillicon/kconv/`](../../06_qe-examples/sillicon/kconv/)

**Goal**: run the one pillar of the "three pillars of convergence testing" that
exercise 05 (cutoff) and exercise 03 (vacuum layer) do not cover — **k-point
convergence**.

In a periodic system an integral over the Brillouin zone is approximated by a
finite sum over k-points. With too few of them, neither the total energy nor the
forces nor the bands can be trusted.

```bash
cd 06_qe-examples/sillicon/kconv
cat system.in            # K_LIST 2 4 6 8 10 12 14
./run-kconv.sh
```

The script changes **only** the k-mesh in `si.scf.in.tmpl` and repeats the SCF.
Cutoff, structure and pseudopotential stay fixed — **changing exactly one
quantity is the golden rule of a convergence test**.

Results land in `kconv.dat`. To plot them:

```bash
source ../../../.venv/bin/activate
python plot-kconv.py          # kconv.png
```

### Verified reference values

**QE 7.5 / 6 MPI / Apple Silicon / 11 s for all 7 cases**

| k-mesh | irreducible k-points | Total energy (Ry) | Deviation from 14×14×14 (mRy) |
|---|---|---|---|
| 2×2×2 | 3 | `-22.65063727` | **187.696** |
| 4×4×4 | 8 | `-22.82563276` | 12.701 |
| 6×6×6 | 16 | `-22.83871576` | 0.382 |
| 8×8×8 | 29 | `-22.83753033` | 0.803 |
| 10×10×10 | 47 | `-22.83784804` | 0.486 |
| 12×12×12 | 72 | `-22.83814573` | 0.188 |
| 14×14×14 | 104 | `-22.83833364` | — |

What this shows:

1. **2×2×2 is off by 188 mRy (≈ 2.6 eV).** Energy differences between structures
   are discussed at the mRy level, so this is simply unusable.
2. **Convergence is not monotonic.** 6×6×6 sits 0.382 mRy *below* the reference
   and 8×8×8 comes back 0.803 mRy *above* it. This is why **you must never take
   two points, see a small difference, and declare convergence**.
3. **Cost is set by the irreducible k-point count, not n³.** Symmetry reduces
   14³ = 2744 points to 104.

### Side note: convergence under different settings (all measured)

k-point convergence is entangled with other settings. The table below uses the
same structure and cutoff, changing only what the column says, and lists the
deviation from that column's own 14×14×14 value.

| k-mesh | default<br>(cold smearing, degauss 0.02) | `occupations='fixed'` | degauss 0.05 |
|---|---|---|---|
| 2×2×2 | 187.696 | 187.808 | 184.097 |
| 4×4×4 | 12.701 | 13.825 | 13.832 |
| 6×6×6 | 0.382 | 1.759 | 1.603 |
| 8×8×8 | 0.803 | 0.285 | 0.010 |
| that column's 14³ value (Ry) | `-22.83833364` | `-22.83960904` | `-22.83792684` |

- With `fixed`, **the oscillation disappears and convergence becomes monotonic**.
  The non-monotonic behaviour of the default was produced by the cold smearing.
  For a semiconductor, `fixed` is the physically correct choice.
- Raising degauss drops the 8×8×8 residual from **0.803 to 0.010 mRy**: smearing
  smooths over an insufficient k-point sampling.
- But **all three columns converge to a different value** (up to 1.3 mRy apart).
  Smearing hides the k-point deficiency, and in exchange you converge to a
  different answer. **"What it converged to" only means something together with
  the settings.**

Odd meshes, also measured (default settings, deviation from 14³):

| | 3×3×3 | 5×5×5 | 7×7×7 | 9×9×9 |
|---|---|---|---|---|
| irreducible k-points | 4 | 10 | 20 | 35 |
| deviation (mRy) | 44.52 | 3.54 | **1.24** | 0.69 |

**7×7×7 (20 irreducible points) is worse than 6×6×6 (16 points)** — more
k-points, less accuracy. Odd and even meshes do not lie on one smooth curve, so
never mix the two series when comparing.

### Tasks

1. Add `3 5 7 9` to `K_LIST` and reproduce the odd-mesh table above. Why is
   7×7×7 worse than 6×6×6? Think about Γ and the weights of high-symmetry points
2. Switch `si.scf.in.tmpl` to `occupations = 'fixed'` (delete the `degauss` and
   `smearing` lines) and confirm that the oscillation disappears
3. Set `nosym = .true.` and run 8×8×8. The irreducible count goes 29 → 260 while
   the total energy only moves `-22.83753033` → `-22.83753027`. Explain what
   symmetry is saving
4. Repeat the test on graphene (`06_qe-examples/graphene/scf/`), a semimetal, and
   confirm that it needs many more k-points than the semiconductor silicon

### Checklist

- [ ] You can explain what the k-mesh discretises
- [ ] You can explain why a convergence test changes exactly one quantity
- [ ] You can explain that convergence may be non-monotonic, hence the need for ≥ 3 points
- [ ] You can explain that changing the smearing moves the converged value itself
- [ ] You can explain the relation between irreducible k-points and cost

---

## 3-10. Comparing exchange-correlation functionals (LDA vs PBE)

**Directory**: [`06_qe-examples/sillicon/xc/`](../../06_qe-examples/sillicon/xc/)

**Goal**: exercise 02 used the toy form `V_xc = -A·√n`. In a real DFT
calculation the choice of approximation for E_xc drives the result. Here we
quantify that through the lattice constant.

```
LDA (PZ)   local density approximation: E_xc depends only on n(r) at each point
PBE (GGA)  generalised gradient approximation: it also uses ∇n(r)
```

### The pseudopotentials used

```bash
cd 06_qe-examples/sillicon/xc
grep -iE 'functional=|pseudo_type|core_correction|z_valence|l_max' *.UPF
```

| | `Si.pz-n-rrkjus_psl.0.1.UPF` | `Si.pbe-n-rrkjus_psl.0.1.UPF` |
|---|---|---|
| `functional` | **LDA** | **PBE** |
| `pseudo_type` | USPP | USPP |
| `core_correction` | T | T |
| `z_valence` | 4 | 4 |
| `l_max` | 2 | 2 |

**This pair was chosen deliberately: everything but `functional` is identical.**
Comparing pseudopotentials built by different schemes would mix the effect of
the functional with the effect of the pseudopotential.

> As 3-0 said, **LDA and PBE must never be mixed inside one calculation**. What
> we do here is run two separate calculations and compare their results — that
> is not mixing.

```bash
./run-xc.sh
```

### Verified reference values

**QE 7.5 / 6 MPI / 19 s for both cases** (vc-relax; residual pressure ≈ 0 kbar in
both)

| Functional | Equilibrium a₀ (Å) | Deviation from experiment | Total energy (Ry) |
|---|---|---|---|
| LDA (PZ) | **5.3987** | **−0.6 %** | `-22.76784172` |
| PBE (GGA) | **5.4687** | **+0.7 %** | `-22.83615811` |
| Experiment | 5.431 | — | — |

**LDA binds too strongly (overbinding), PBE too weakly (underbinding), and the
experimental value sits between them.** This is a general trend across many
solids, not something specific to Si.

> **Never compare total energies across two functionals.**
> The definition of E_xc differs, so the energy zero differs. Reading
> `-22.768` against `-22.836` and concluding "PBE is more stable" is wrong.
> What may be compared are energy *differences* **within one functional**
> (structure A vs B) and structural quantities such as the lattice constant.

### Band gap (reference, measured)

Reading the Kohn-Sham indirect gap at each functional's own equilibrium lattice
constant, with `occupations = 'fixed'` on an 8×8×8 mesh:

| Functional | KS indirect gap |
|---|---|
| LDA | 0.441 eV |
| PBE | 0.611 eV |
| Experiment | **1.17 eV** |

**Going from LDA to PBE does not bring the gap to experiment** (38 % → 52 %).
The lattice constant improved with PBE; the gap did not. This is not a question
of functional accuracy — it stems from the **self-interaction error (SIE)** seen
in [task 4 of exercise 02](01_scf.md), and from the fact that KS eigenvalues are
not quasiparticle energies.

> These are values on a mesh, so they differ slightly from the band-path value in
> 3-5 (PBE 0.67 eV): the true CBM may not fall on the mesh. The point is not the
> absolute number but that **the LDA–PBE difference (0.17 eV) is small compared
> with the gap to experiment (over 0.5 eV)**.

### Tasks

1. Convert the 0.07 Å difference in `a₀` into a percentage change in volume
2. Estimate the bulk modulus from the `si.vc-relax.*.out` of each functional
   (sample a few lattice constants and fit the E–V curve). Compare with the
   experimental 98 GPa
3. Redo the band calculation of 3-5 with the LDA pseudopotential and check how
   the overall band shape compares with PBE (nearly identical apart from the gap)
4. Repeat the comparison on graphite (`06_qe-examples/graphite/`), where the
   interlayer distance differs far more dramatically. Look into how LDA and GGA
   treat van der Waals forces

### Checklist

- [ ] You can state the difference between LDA and GGA in one sentence
- [ ] You can explain why the pseudopotentials must match when comparing functionals
- [ ] You can explain why absolute total energies must not be compared across functionals
- [ ] You can describe the overbinding/underbinding trend of LDA/GGA
- [ ] You can explain why moving to GGA does not fix the band-gap problem

---

## 3-11. Spin polarisation (the triplet ground state of O₂)

**Directory**: [`06_qe-examples/o2/spin/`](../../06_qe-examples/o2/spin/)

**Goal**: every calculation so far treated ↑ and ↓ electrons as identical
(`nspin = 1`). For an open-shell system that breaks down.

The ground state of O₂ is the **triplet** ³Σg⁻: the two π* orbitals each take one
↑ electron (Hund's rule). Solving without separating the spins cannot reach it.

```bash
cd 06_qe-examples/o2/spin
./run-spin.sh
```

Structure, pseudopotential and cutoff stay fixed; only `nspin` changes.

```
nspin = 1                           the same potential for ↑ and ↓
nspin = 2                           separate potentials for ↑ and ↓
starting_magnetization(1) = 0.5     initial magnetisation (needed to break the symmetry)
```

### Verified reference values

**QE 7.5 / 6 MPI / 9 s for both cases** (bond length 1.21 Å, 10 Å cubic cell,
Γ point only)

| | Total energy (Ry) | total magnetization (μB/cell) |
|---|---|---|
| `nspin = 1` | `-82.97218672` | 0.00 |
| `nspin = 2` | **`-83.04565381`** | **2.00** |

```
E(nspin=2) - E(nspin=1) = -1.000 eV        ← the triplet is 1 eV more stable
total magnetization     =  2.00 μB/cell    ← 2 unpaired ↑ = a triplet
```

That the magnetisation comes out at **exactly 2.00** matters. It is not a
coincidence: it *is* the triplet, one ↑ electron in each of the two π* orbitals.

### Looking at the splitting

```bash
grep -A11 "SPIN UP"   o2.scf.nspin2.out | tail -8
grep -A11 "SPIN DOWN" o2.scf.nspin2.out | tail -8
grep -i   "Fermi"     o2.scf.nspin2.out | tail -1
```

Eigenvalues at Γ (eV):

```
SPIN UP    -32.7708 -20.3546 -13.3518 -13.3464 -13.3464  -6.6492  -6.6492 | -0.3853 ...
SPIN DOWN  -31.5870 -18.5567 -12.4444 -11.4820 -11.4820  -4.3350  -4.3350 |  1.0807 ...
                                                           ↑↑
                                            the π* orbitals; exchange splitting 2.314 eV

Fermi = -5.4846 eV      ← between π*(↑) at -6.6492 and π*(↓) at -4.3350
```

The same command also prints the `occupation numbers`, the direct evidence for
the triplet:

```
SPIN UP     1 1 1 1 1 1 1 | 0 0 0      ← 7 occupied
SPIN DOWN   1 1 1 1 1 0 0 | 0 0 0      ← 5 occupied (both π* empty)
```

The 12 valence electrons split into 7 ↑ and 5 ↓ (7 − 5 = 2 = the magnetisation).
The Fermi level falls between π*(↑) and π*(↓), so **π*(↑) is occupied and π*(↓)
is empty** — exactly the triplet configuration.

**Every ↑ level lies deeper than its ↓ counterpart** because ↑ is the majority
spin and gains stabilisation from exchange between same-spin electrons. This is
the origin of magnetism.

### Tasks

1. Set `starting_magnetization(1)` to `0.0` and see what happens (the symmetry
   may never break, leaving you in the same solution as `nspin = 1`)
2. Change the bond length from 1.21 Å to 1.10 / 1.30 Å and track how the
   triplet–singlet energy difference changes
3. Work out why `absolute magnetization` (2.05 μB) is slightly larger than
   `total magnetization` (2.00 μB) — the two are defined differently
4. Repeat for N₂ (closed shell) and confirm the magnetisation stays 0 even with
   `nspin = 2` (get the pseudopotential from SSSP; see
   [the extension of exercise 07](04_homo-lumo.md))

### Checklist

- [ ] You can explain what `nspin = 1` versus `nspin = 2` changes
- [ ] You can explain from Hund's rule why O₂ has a triplet ground state
- [ ] You can explain why `starting_magnetization` is needed (symmetry breaking)
- [ ] You can explain the ↑/↓ eigenvalue splitting in terms of exchange
- [ ] You can say what goes wrong if you forget `nspin = 2` for a magnetic material

---

## Summary

| Section | System | `CAL` | Main output | Measured time |
|---|---|---|---|---|
| 3-1 | H₂O | `scf` | `*.scf.out` | 20 s |
| 3-2 | H₂O | `relax` | `*.relax.vasp` | 1 min |
| 3-3 | H₂O | `wf` | `*.cube` | 1 min |
| 3-4 | graphene | `scf` / `wf` | `*.scf.out`, `*.cube` | 2 s |
| 3-4 | graphite | `vc-relax` / `scf` | relaxed cell | 4 min 30 s / 9 s |
| 3-5 | silicon | `bands` | `*.band.gnu` → `bands.pdf` | 6 s |
| 3-6 | silicon | `dos` | `*.dos` → `dos.pdf` | 7 min 23 s |
| 3-7 | silicon | `proj` | `*.pdos_atm#*` → `projwfc.pdf` | 3 min 44 s |
| 3-8 | silicon | (phonopy) | `band.yaml`, `projected_dos.dat` | 8 min 36 s |
| 3-9 | silicon | `scf` × 7 | `kconv.dat` → `kconv.png` | 11 s |
| 3-10 | silicon | `vc-relax` × 2 | `xc.dat` | 19 s |
| 3-11 | O₂ | `scf` × 2 | `spin.dat` | 9 s |

All times measured on **Apple Silicon with 6 MPI processes** (graphite: 8).

### Does the script write a PDF automatically?

| Script | PDF written automatically |
|---|---|
| `dos.plt` | yes — `dos.pdf` |
| `projwfc.plt` | yes — `projwfc.pdf` |
| `band.plt` | **no** — uncomment the last three lines |

All three contain `pause -1`, so **they do not exit until you press Enter in
the Terminal**.

### The three pillars of convergence testing (always do these in research)

1. **`ecutwfc` convergence** — find the cutoff beyond which the total energy
   stops changing (→ exercise 05, task 2 of 3-1)
2. **k-point convergence** — densify the mesh until the total energy stops
   changing (→ **3-9**)
3. **Vacuum layer / cell size convergence** — remove the influence of periodic
   images in isolated and surface systems (→ exercise 03)

> The three pillars are not independent. As 3-9 shows, changing the smearing
> moves the value that the k-point series converges to. **"What it converged to"
> only means something together with the settings.**

---

[← 02. Basis sets](02_basis.md) | [Index](README.md) | [Next: 04. HOMO-LUMO →](04_homo-lumo.md)
