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
   stops changing (→ exercise 05)
2. **k-point convergence** — densify the mesh until the total energy stops
   changing
3. **Vacuum layer / cell size convergence** — remove the influence of periodic
   images in isolated and surface systems (→ exercise 03)

---

[← 02. Basis sets](02_basis.md) | [Index](README.md) | [Next: 04. HOMO-LUMO →](04_homo-lumo.md)
