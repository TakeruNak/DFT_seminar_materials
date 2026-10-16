# 04. HOMO-LUMO analysis (F₂ molecule)

*English ・ [🌐 日本語](../ja/04_homo-lumo.md)*

[← 03. Quantum ESPRESSO](03_quantum-espresso.md) | [Index](README.md) | [Next: 05. Tight-binding →](05_tight-binding.md)

**Goal**: run the full chain — structure relaxation → SCF → wavefunction
output — yourself, and identify the **HOMO / LUMO** from the energies and
spatial distributions of the Kohn-Sham orbitals.

**Directory**: [`07_homo-lumo/F2/`](../../07_homo-lumo/F2/)

F₂ is a good choice because σ/σ* and π/π* appear clearly, making the
correspondence with molecular orbital theory easy to see.

---

## 4-1. Structure relaxation

**Directory**: [`07_homo-lumo/F2/relax/`](../../07_homo-lumo/F2/relax/)

```bash
cd 07_homo-lumo/F2/relax
cat system.in            # NAME F2 / CAL relax
./run-local.sh
```

### Reading the results

```bash
grep -A5 'ATOMIC_POSITIONS' F2.relax.out | tail -10   # final structure
grep 'Total force' F2.relax.out                       # force convergence
grep '!' F2.relax.out                                 # total energy
```

The relaxed structure is `F2.relax.vasp`; view it with
`open -a VESTA F2.relax.vasp`.

**Verified reference values** (QE 7.5 / 6 MPI / 42 s)

| Quantity | Value | Experiment |
|---|---|---|
| Total energy | `-96.91814727 Ry` | — |
| Final coordinates (crystal) | F: (0.5, 0.5, 0.4290) / (0.5, 0.5, 0.5710) | — |
| **F–F bond length** | **1.419 Å** | 1.412 Å |
| Final total force | `0.000001` | — |

**Task**: compute the relaxed F–F bond length and compare with experiment
(1.412 Å). The cell is a 10 Å cube, so multiply the difference of the z
coordinates by 10 to get Å.

---

## 4-2. SCF and the eigenvalues

**Directory**: [`07_homo-lumo/F2/wf/`](../../07_homo-lumo/F2/wf/)

An `F2.scf.in` based on the relaxed structure (`F2.relax.vasp`) is provided.

```bash
cd ../wf
cat system.in            # NAME F2 / CAL wf → pp.x runs after scf
./run-local.sh
```

### Reading the Kohn-Sham eigenvalues

```bash
grep -A10 'End of self-consistent calculation' F2.scf.out
grep 'Fermi' F2.scf.out
```

The printed eigenvalues (eV) are the energies of the Kohn-Sham orbitals.
Everything below the Fermi level is **occupied**, everything above is
**unoccupied**.

**Verified reference values** (6 MPI / SCF + pp.x in 18 s)

```
bands (ev):
  -33.7916 -27.5716 -15.1798 -12.6376 -12.6376
   -9.3160  -9.3160  -5.7980  -0.4147   0.9986   1.0973

the Fermi energy is  -7.3731 ev
```

Note that `-12.6376` and `-9.3160` are doubly degenerate (π / π*).

```
     ... occupied ...     E_F     ... unoccupied ...
   ─────────────────────┬───────────────────────
            HOMO ───────┤─────── LUMO
```

---

## 4-3. Energy level diagram

`wf_png/wf_energy.py` draws the level diagram.

```bash
cd wf_png
source ../../../../.venv/bin/activate
python wf_energy.py
```

The F₂ eigenvalues are written directly at the top of the script.
Replace them with your own values from 4-2 and re-run.

```python
eigenvalues = [-15.1798, -12.6376, -12.6376, -9.3160, -9.3160, -5.7980, -0.4147]
fermi_energy = -7.3731
```

> These defaults match the measured values in 4-2 (degeneracies are detected
> automatically and marked `(Degenerate)`). Run it **as is** first to confirm
> the figure appears, then substitute your own results.

Compare against the existing `wf_png/wf_energy.png`.

---

## 4-4. Visualising the orbitals

Change `kband` in `F2.wf.in` to write out each orbital as a cube file.

```
&inputpp
    plot_num = 7
    kpoint   = 1
    kband    = 2        ← ★ change this
    lsign    = .true.
/
&plot
    iflag         = 3
    output_format = 6
    fileout       = 'F2_G2.cube'    ← ★ change this too
/
```

```bash
cd 07_homo-lumo/F2/wf

# after editing kband and fileout
./run-local.sh
open -a VESTA F2_G2.cube
```

The defaults are `kband = 2` / `fileout = 'F2_G2.cube'` (about 23 MB).
`wf_png/` contains example outputs for G3–G8.

> `CAL wf` redoes the SCF every time (about 18 s). If you only want to vary
> `kband`, it is faster to call `pp.x` directly while `out/` still exists.
>
> ```bash
> mpirun -np 6 $QE_BIN_DIR/pp.x -inp F2.wf.in > F2.wf.out
> ```

### Tasks

1. Count the valence electrons of F₂ and determine which band is the HOMO
2. Vary `kband` from HOMO-2 to LUMO+1, write out the cubes, and look at the
   shapes in VESTA
3. Classify each orbital as σ, σ*, π or π* and match them to the molecular
   orbital diagram
4. Set `lsign = .false.` and see how the output changes

---

## 4-5. Checklist

- [ ] You can identify HOMO / LUMO from the Kohn-Sham eigenvalues
- [ ] You can tell bonding (σ, π) from antibonding (σ*, π*) by the spatial
      distribution of the orbital
- [ ] You can explain why "KS eigenvalue = ionisation potential" is not true
      (strictly it holds only for the HOMO — compare Janak's theorem and
      Koopmans' theorem)
- [ ] You understand why cube files must not be committed

---

## Going further

Apply the same procedure to other diatomic molecules (N₂, O₂, CO).

1. Download an SDF from [PubChem](https://pubchem.ncbi.nlm.nih.gov/)
2. Convert it with `obabel input.sdf -O output.xyz --gen3d`
3. Open it in VESTA and export in POSCAR format
4. Generate the input with the
   [QE input generator](https://qeinputgenerator.materialscloud.io/)
5. Get the pseudopotentials from
   [SSSP](https://www.materialscloud.org/discover/sssp/) and put them in `pseudo/`
6. Write a `system.in` and run `./run-local.sh`

> O₂ has a triplet ground state, so it needs `nspin = 2`. Think about why.

---

[← 03. Quantum ESPRESSO](03_quantum-espresso.md) | [Index](README.md) | [Next: 05. Tight-binding →](05_tight-binding.md)
