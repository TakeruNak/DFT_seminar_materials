# Appendix: cheat sheets, external tools, troubleshooting

*English ・ [日本語](../ja/90_reference.md) ・ [简体中文](../zh/90_reference.md)*

[← 05. Tight-binding](05_tight-binding.md) | [Index](README.md)

---

## Linux command cheat sheet

| Purpose | Command |
|---|---|
| Where am I | `pwd` |
| List files | `ls` / `ls -la` (including hidden files) |
| Move | `cd <dir>` / `cd ..` (up one) / `cd ~` (home) |
| Create a directory | `mkdir -p <dir>` |
| Copy / move | `cp <src> <dst>` / `mv <src> <dst>` |
| Delete | `rm <file>` / `rm -r <dir>` (**cannot be undone**) |
| Look at a file | `cat <file>` / `less <file>` (`q` to quit) |
| Head / tail | `head -20 <file>` / `tail -20 <file>` |
| Search | `grep '!' *.out` / `grep -A5 'KEY' <file>` (also shows 5 following lines) |
| Check running jobs | `top` / `ps aux \| grep pw.x` |
| Kill the foreground job | `Ctrl + C` |
| History | `history` / `↑` key |
| Completion | `Tab` key |

---

## Git cheat sheet

| Purpose | Command |
|---|---|
| Clone | `git clone <url>` |
| Pull updates | `git pull` |
| Check status | `git status` |
| Check differences | `git diff` |
| Discard changes | `git restore <file>` |
| Create a branch | `git switch -c <branch>` |

> **You do not need to commit the exercise files you edited yourself.**
> If `git pull` conflicts, run `git restore <file>` first and then pull.

---

## Quantum ESPRESSO cheat sheet

### Extracting values from the output

```bash
grep '!'                      *.out   # converged total energy
grep 'estimated scf accuracy' *.out   # evolution of the SCF residual
grep 'Total force'            *.out   # residual force
grep -i 'Fermi'               *.out   # Fermi level
grep 'number of k points'     *.out   # number of k-points
grep -A6 'End of self-consistent calculation' *.out  # eigenvalues (eV)
grep -A5 'ATOMIC_POSITIONS'   *.out   # structure (relax runs)
grep 'PWSCF.*WALL'            *.out   # timing
grep -c 'JOB DONE'            *.out   # did it finish cleanly? (1 = yes)
grep -i 'error'               *.out   # errors
```

> Every example here uses `occupations = 'smearing'`, so you determine
> HOMO/LUMO from `the Fermi energy is ...` and the list of eigenvalues.
> The line `highest occupied level` only appears with `occupations = 'fixed'`.

### Key parameters

| Parameter | Namelist | Meaning |
|---|---|---|
| `calculation` | `&CONTROL` | `scf` / `nscf` / `bands` / `relax` / `vc-relax` |
| `prefix` | `&CONTROL` | Name used for the scratch files |
| `outdir` | `&CONTROL` | Scratch directory (usually `./out/`) |
| `pseudo_dir` | `&CONTROL` | Location of the pseudopotentials |
| `ecutwfc` | `&SYSTEM` | Wavefunction cutoff energy (Ry) |
| `ecutrho` | `&SYSTEM` | Charge density cutoff energy (Ry) |
| `nbnd` | `&SYSTEM` | Number of bands to compute |
| `occupations` | `&SYSTEM` | `smearing` / `fixed` / `tetrahedra` |
| `degauss` | `&SYSTEM` | Smearing width (Ry) |
| `nspin` | `&SYSTEM` | 2 for spin polarisation |
| `conv_thr` | `&ELECTRONS` | SCF convergence criterion |
| `mixing_beta` | `&ELECTRONS` | Density mixing parameter (`alpha` in exercise 01) |
| `electron_maxstep` | `&ELECTRONS` | Maximum number of SCF iterations |

Official documentation: https://www.quantum-espresso.org/Doc/INPUT_PW.html

### Units

| Quantity | QE default unit |
|---|---|
| Energy (cutoffs in the input) | Ry |
| Energy (eigenvalues in the output) | eV |
| Total energy | Ry |
| Length | bohr, or Å with `CELL_PARAMETERS angstrom` |

1 Ry = 13.6057 eV, 1 bohr = 0.529177 Å

---

## External tools

### Structure databases

| Site | Target |
|---|---|
| [PubChem](https://pubchem.ncbi.nlm.nih.gov/) | Molecules |
| [ChemSpider](https://www.chemspider.com/) | Molecules |
| [Materials Project](https://next-gen.materialsproject.org/) | Bulk crystals |
| [COD](https://www.crystallography.net/cod/) | Crystal structures (open) |
| [OQMD](https://oqmd.org/) | Bulk crystals |

### Web tools

| Site | Use |
|---|---|
| [QE input generator](https://qeinputgenerator.materialscloud.io/) | Build PWscf inputs through a GUI |
| [SeeK-path](https://www.materialscloud.org/work/tools/seekpath) | Suggests band paths automatically |
| [SSSP](https://www.materialscloud.org/discover/sssp/) | Recommended pseudopotentials and cutoffs |

### Pseudopotential libraries

| Library | Characteristics |
|---|---|
| [SSSP](https://www.materialscloud.org/discover/sssp/) | Verified for QE. **Use this by default** |
| [PS-library](https://www.quantum-espresso.org/pseudopotentials/) | Official QE library |
| [PseudoDojo](http://www.pseudo-dojo.org/) | Relativistic corrections, several LDA/GGA sets |

> **Never mix LDA and GGA pseudopotentials.**
> Use a single consistent functional family within one calculation.

### Local tools

| Tool | Use | Install |
|---|---|---|
| VESTA | Visualising crystals, molecules and cube files | `brew install --cask vesta` |
| Avogadro | Molecular modelling | `brew install avogadro` |
| OpenBabel | Structure file conversion | `brew install open-babel` |
| gnuplot | Plotting bands / DOS | `brew install gnuplot` |
| GNU sed | Required by the plot-preparation scripts | `brew install gnu-sed` |
| phonopy | Phonon calculations (3-8) | `pip install "phonopy<4"` |

```bash
obabel input.sdf -O output.xyz --gen3d     # sdf → xyz
obabel input.sdf -O output.cif --gen3d     # sdf → cif
open -a VESTA output.xyz
```

---

## Troubleshooting

### Environment

| Symptom | What to do |
|---|---|
| `pw.x が見つかりません` / `pw.x not found` | Check `which pw.x`; if missing, `export QE_BIN_DIR=<QE bin directory>` |
| `command not found: gsed` | `brew install gnu-sed` |
| `command not found: gnuplot` | `brew install gnuplot` |
| `ModuleNotFoundError: numpy` | You probably forgot `source .venv/bin/activate` |
| `ModuleNotFoundError: pythtb` | `pip install pythtb pymatgen` |
| `TBModel` cannot be imported | pythtb 2.0 or later is required (`pip install -U pythtb`) |
| No matplotlib window appears | Use `plt.savefig()` instead of `plt.show()` |
| `'-d' is a setup operation that moved to 'phonopy-init' in v4` | You have phonopy 4. `pip install "phonopy<4"` |
| gnuplot never exits | That is `pause -1` in the `.plt` file. Press Enter in the Terminal |

### QE runtime errors

| Symptom | Cause and fix |
|---|---|
| `ERROR: Please put system.in in this directory` | A `system.in_tmp` is generated — rename it to `system.in` and edit it |
| `file ... .UPF not found` | Check that `pseudo_dir` matches the actual location of `pseudo/` |
| `convergence NOT achieved` | Lower `mixing_beta` (0.4 → 0.2 → 0.1) / raise `electron_maxstep` / increase `degauss` slightly |
| `Not enough space allocated for radial FFT` | Raise `ecutrho` |
| Out of memory / abnormal termination | Reduce `NUM_PROCS`, or lower `ecutwfc` and the k-point mesh to test with something smaller |
| `mpirun` is missing | `brew install open-mpi`, or use the conda build of QE |
| The second run gives strange results | `rm -rf out/` and start again |
| `fatal error reading xml file` (pp.x / projwfc.x) | SCF was not run first. If `out/` is empty, start from `CAL scf` |
| `file ... .UPF not found` with somebody else's absolute path | `pseudo_dir` in the input still points at another environment. Change it to e.g. `'./pseudo/'` |
| `Minimization algorithm failed to find Fermi energy` | A warning, not an error (QE just switched to bisection) |

### Standard recipe when SCF does not converge

1. Lower `mixing_beta` (0.4 → 0.1)
2. Raise `electron_maxstep` (80 → 200)
3. Increase `degauss` slightly (metallic systems)
4. Try `mixing_mode = 'local-TF'` (inhomogeneous systems)
5. Converge a coarse setting first (low cutoff, coarse k-points) and start from
   that density

→ The same phenomenon you saw when varying `alpha` in
[01. Self-consistent field](01_scf.md).

---

## Files that must never be committed

They are git-ignored, but just in case.

| Target | Reason |
|---|---|
| `99_slides/` | Original lecture slides. **Never push them to the remote** |
| `out/` | QE scratch directory; huge |
| `*.cube` | Wavefunction output; tens of MB |
| `.answear` | Answer keys |

```bash
git status            # always check before committing
```

---

## References

- P. Hohenberg, W. Kohn, *Phys. Rev.* **136**, B864 (1964) — Hohenberg-Kohn theorem
- W. Kohn, L. J. Sham, *Phys. Rev.* **140**, A1133 (1965) — Kohn-Sham equation
- J. P. Perdew, K. Burke, M. Ernzerhof, *Phys. Rev. Lett.* **77**, 3865 (1996) — PBE
- R. M. Martin, *Electronic Structure: Basic Theory and Practical Methods*
- P. Taylor, O. Heinonen, *Condensed Matter Physics*
- Y. Hinuma et al., *Comput. Mater. Sci.* **128**, 140 (2017) — conventions for band paths
- [Quantum ESPRESSO documentation](https://www.quantum-espresso.org/documentation/)
- [phonopy with QE](https://phonopy.github.io/phonopy/qe.html)

---

[← 05. Tight-binding](05_tight-binding.md) | [Index](README.md)
