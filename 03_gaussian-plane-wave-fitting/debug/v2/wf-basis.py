#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: wf-basis.py
Description: <Description on this script>
Author: Takeru Nakashima
Date: 2026-03-23

Copyright (c) 2026-03-23 <Takeru Nakashima>. All rights reserved.
"""
import numpy as np
import matplotlib.pyplot as plt

# =========================
# Parameters
# =========================
L = 20.0
N = 200
x = np.linspace(-L, L, N)
dx = x[1] - x[0]

# =========================
# Gaussian
# =========================
def gaussian(x, A=1.0, x0=0.0, sigma=1.0):
    return A * np.exp(-(x - x0)**2 / (2 * sigma**2))

g_x = gaussian(x)

# =========================
# Energy cutoff 
# example: E_cut = 5.0 (in atomic units)
# E = k^2 / 2 => k_max = sqrt(2 * E_cut)
#
# E_cut determines how many plane waves are included in the expansion
# A smaller E_cut means fewer plane waves and a less accurate representation 
# of the Gaussian, while a larger E_cut includes more plane waves and can 
# better capture the shape of the Gaussian.
# =========================
E_cut = 1.0

# k_max from energy
k_max = np.sqrt(2 * E_cut)

# =========================
# Plane wave basis (2π/L)
# =========================
n_max = int(np.floor(k_max * L / (2*np.pi)))+1
n_vals = np.arange(-n_max, n_max+1)

k_vals = 2 * np.pi * n_vals / (2*L)

print(f"E_cut = {E_cut}")
print(f"k_max = {k_max}")
print(f"Number of plane waves = {len(k_vals)}")

# =========================
# Fourier coefficients
# =========================
c_k = np.array([
    np.sum(g_x * np.exp(-1j * k * x)) * dx / (2*L)
    for k in k_vals
])

# =========================
# Reconstruction
# =========================
g_fit = np.sum(
    c_k[:, None] * np.exp(1j * k_vals[:, None] * x),
    axis=0
)

# =========================
# Plot
# =========================
plt.figure(figsize=(10, 6))
plt.title(f"Plane Wave Expansion (E_cut={E_cut})")
plt.xlabel("x")
plt.ylabel("f(x)")

plt.plot(x, g_x, label="Original Gaussian")
plt.plot(x, np.real(g_fit), '--', label="Plane wave expansion")

plt.legend(loc="upper right")
plt.show()
plt.close()
