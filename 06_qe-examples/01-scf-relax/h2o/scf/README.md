---
title: README.md
excerpt: <excerpt or description on this script>
author: Takeru Nakashima
collection: portfolio
date: 2026-04-27
# Copyright (c) 2026-04-27 <Takeru Nakashima>. All rights reserved.
---

# Convet the sdf file to xyz file

'''
obabel input.sdf -O output.xyz --gen3d
'''

Convet the sdf file to cif file

'''
obabel input.sdf -O output.cif --gen3d

'''

# Open the file via VESTA

'''
open -a /Application/VESTA.app output.xyz
or
vesta output.xyz
'''

