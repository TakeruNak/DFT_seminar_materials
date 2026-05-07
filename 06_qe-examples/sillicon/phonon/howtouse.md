---
title: How to use phonopy with Quantum ESPRESSO
excerpt: The calculation flow of phonopy; post process after QE
author: Takeru Nakashima
modified-date: 2025-09-03
# Copyright (c) 2025-06-13 <Takeru Nakashima>. All rights reserved.
---

# The calculation flow of phonopy; post process after QE
reference is [phonopy v.2.17.0](https://phonopy.github.io/phonopy/qe.html)

1. Read a QE-PW input file and create supercells with --qe option:
    ```
    phonopy --qe -d --dim="2 2 2" -c *.scf.in
    ```
    In this example, 2x2x2 supercells are created.
2. Please modifies the header input `header.in`.
   Because the number of atoms in the supercell is different from one in the original unit cell, modifies the `nat=*`.
   Then, exectue `attach_header.sh`
   ```
   ./attach_header.sh
   ```
3. After execution of `attach_header.sh`, execute `makeng_script_mac.py` or `making_script.py`. 
    ```
    python making_script.py
    or
    python making_script_mac.py
    ```
4. Finally complted input files for phonopy and script, just run `phonopy_*.sh`.
    ```
    phonopy_*.sh  
    ```
5. Calculate the force coefficients by calculation results for each supercell system.
   ```
   phonopy -f *.out
   ```
6. Postprocess is executed as below
   For band plot
   ```
   phonopy --qe -c *.scf.in -p band.conf
   phonopy-bandplot --gnuplot band.yaml > gnuplot_band.dat
   ```

   For pdos plot
   reference:[pdos](https://phonopy.github.io/phonopy/setting-tags.html#xyz-projection-tag)
   ```
   phonopy -p pdos.conf
   ```

   For both band and pdos
   ```
   phonopy band-pdos.conf --nac -p
   ```
