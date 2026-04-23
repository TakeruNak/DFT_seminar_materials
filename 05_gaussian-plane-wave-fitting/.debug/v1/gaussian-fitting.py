#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: gaussian-fitting.py
Description: Gaussian plane wave fitting
Author: Takeru Nakashima
Date: 2026-03-23

Copyright (c) 2026-03-23 <Takeru Nakashima>. All rights reserved.
"""

import numpy
import matplotlib.pyplot as plt

# --------------
# Parameters
# --------------
L = 10.0  # Length of the domain
N = 300  # Number of grid points
x = numpy.linspace(-L, L, N)

# --------------
# Gaussian function
# --------------
def gaussian(x, A, x0, sigma):
    return A * numpy.exp(-(x - x0) ** 2 / (2 * sigma ** 2))

# --------------
# Check the gaussian function
# --------------
plt.figure(figsize=(10, 6))
plt.title("Gaussian Function")
plt.xlabel("x")
plt.ylabel("f(x)")

plt.plot(x, gaussian(x, A=1.0, x0=0.0, sigma=1.0), label="Gaussian")

plt.savefig("01_gaussian-model.png", bbox_inches='tight', dpi=300)
plt.show()
plt.close()


# --------------
# Fourier transform of the Gaussian function
# --------------
model_wf = gaussian(x, A=1.0, x0=0.0, sigma=1.0)
g_k = numpy.fft.fft(model_wf)
k = 2 * numpy.pi * numpy.fft.fftfreq(N, d=(x[1] - x[0]))

# --------------
# Cutoff parameters
# --------------
k_max = 50.0  # Maximum wavenumber
mask=numpy.abs(k) <= k_max
g_k_cutoff = g_k[mask]
k_cutoff = k[mask]
# print(f"Original k: {k}")
print(f"Maximum wavenumber: {k_max}")
print(f"Number of components after cutoff: {len(g_k_cutoff)}")
print(f"k cutoff: {k_cutoff}")

# --------------
# Inverse Fourier transform to get the fitted Gaussian function
# --------------
g_fit = numpy.fft.ifft(g_k_cutoff, n=N)

# --------------
# Plot the original and fitted Gaussian functions
# --------------
plt.figure(figsize=(10, 6))
plt.title("Gaussian Fitting")
plt.xlabel("x")
plt.ylabel("f(x)")
plt.plot(x, model_wf, label="Original Gaussian")
plt.plot(x, g_fit.real, label="Fitted Gaussian", linestyle='dashed')
plt.legend()

plt.savefig("02_gaussian-fitting.png", bbox_inches='tight', dpi=300)
plt.show()

# --------------
# Plot the components of the Fourier series
# --------------
plt.figure(figsize=(10, 6))
plt.title("Component Comparison")
plt.xlabel("x")
plt.ylabel("g_k*exp(ikx)")

for i in range(len(g_k_cutoff)):
    plt.plot(x, numpy.real(g_k_cutoff[i] * numpy.exp(1j * k_cutoff[i] * x)), label=f"Component {i}")

plt.legend()
plt.savefig("03_gaussian-fitting-components.png", bbox_inches='tight', dpi=300)
plt.show()
