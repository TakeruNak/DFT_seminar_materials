#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: gaussian-plane-wave-fitting.py
Description: Gaussian plane wave fitting with PNG output
Author: Takeru Nakashima
Date: 2026-03-23

Copyright (c) 2026-03-23 <Takeru Nakashima>. All rights reserved.
"""
import numpy as np
import matplotlib.pyplot as plt

# ============================
# 1. 実空間グリッド
# ============================
L = 10.0
N = 1024
x = np.linspace(-L/2, L/2, N, endpoint=False)
dx = x[1] - x[0]

# ============================
# 2. Gaussian（ターゲット）
# ============================
sigma = 0.5
g = np.exp(-x**2 / (2 * sigma**2))

# ============================
# 3. フーリエ変換
# ============================
g_k = np.fft.fft(g)
k = 2 * np.pi * np.fft.fftfreq(N, d=dx)

# ============================
# 4. cutoff設定
# ============================
k_max = 10
mask = np.abs(k) < k_max

k_selected = k[mask]
gk_selected = g_k[mask]

# ============================
# 5. 係数ベクトル出力
# ============================
print("\n=== Plane wave coefficients (sorted by magnitude) ===")

coeff_list = []
for k_val, gk_val in zip(k_selected, gk_selected):
    coeff = gk_val / N
    magnitude = np.abs(coeff)
    phase = np.angle(coeff)
    coeff_list.append((k_val, coeff, magnitude, phase))

# 振幅順にソート
coeff_list_sorted = sorted(coeff_list, key=lambda x: x[2], reverse=True)

num_print = 12
for i in range(min(num_print, len(coeff_list_sorted))):
    k_val, coeff, mag, phase = coeff_list_sorted[i]
    print(f"{i+1:2d}: k = {k_val:8.3f} | coeff = {coeff.real: .5e} + {coeff.imag: .5e}j "
          f"| |c_k| = {mag: .5e} | phase = {phase: .3f}")

# ============================
# 6. 個々の平面波成分プロット
# ============================
plt.figure(figsize=(10, 6))

num_show = 8
indices = np.argsort(np.abs(gk_selected))[-num_show:]

for idx in indices:
    k_val = k_selected[idx]
    coeff = gk_selected[idx] / N
    plane_wave = coeff * np.exp(1j * k_val * x)
    plt.plot(x, plane_wave.real, label=f"k={k_val:.2f}")

plt.title("Individual plane wave components (real part)")
plt.xlabel("x")
plt.ylabel("Amplitude")
plt.legend(loc="upper right")

# 画像を保存 (追加)
plt.savefig("01_individual_components.png", bbox_inches='tight', dpi=300)
plt.show()

# ============================
# 7. 構築過程の可視化
# ============================
g_rec_progress = np.zeros_like(x, dtype=complex)

plt.figure(figsize=(10, 6))

# 大きい成分から順に足す
sorted_indices = np.argsort(np.abs(gk_selected))[::-1]

for i, idx in enumerate(sorted_indices[:num_show]):
    k_val = k_selected[idx]
    coeff = gk_selected[idx] / N
    plane_wave = coeff * np.exp(1j * k_val * x)

    g_rec_progress += plane_wave
    plt.plot(x, g_rec_progress.real, label=f"{i+1} components")

plt.plot(x, g, 'k--', label="Original Gaussian")
plt.title("Build-up of Gaussian from plane waves")
plt.xlabel("x")
plt.ylabel("g(x)")
plt.legend(loc="upper right")

# 画像を保存 (追加)
plt.savefig("02_buildup_process.png", bbox_inches='tight', dpi=300)
plt.show()

# ============================
# 8. 最終再構成
# ============================
g_k_cut = g_k * mask
g_rec = np.fft.ifft(g_k_cut).real

plt.figure(figsize=(8, 5))
plt.plot(x, g, 'k', label="Original")
plt.plot(x, g_rec, label=f"Reconstructed (k_max={k_max})")
plt.legend(loc="upper right")
plt.title("Final reconstruction")
plt.xlabel("x")
plt.ylabel("g(x)")

# 画像を保存 (追加)
plt.savefig("03_final_reconstruction.png", bbox_inches='tight', dpi=300)
plt.show()

# ============================
# 9. 誤差評価
# ============================
error = np.sqrt(np.mean((g - g_rec)**2))
print(f"\nRMS error (k_max = {k_max}): {error:.5e}")

# ============================
# 10. k空間分布
# ============================
plt.figure()
plt.plot(k, np.abs(g_k)/N)
plt.xlabel("k")
plt.ylabel("|c_k|")
plt.title("Fourier coefficients (magnitude)")

# 画像を保存 (追加)
plt.savefig("04_k_space_distribution.png", bbox_inches='tight', dpi=300)
plt.show()
