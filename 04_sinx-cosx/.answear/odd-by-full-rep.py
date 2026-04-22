#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: odd-by-even-rep.py
Description: <Description on this script>
Author: Takeru Nakashima
Date: 2026-04-22

Copyright (c) 2026-04-22 <Takeru Nakashima>. All rights reserved.
"""

# Configure logging
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import quad

# 展開する区間 [-L, L] （ここでは [-π, π] とします）
L = np.pi

# ターゲット関数：奇関数の代表 sin(x)
def target_func(x):
    return (0.3*np.sin(x) + 0.5*np.cos(x))*np.exp(-x**2)
    # return (0.3*np.sin(x) - 0.5*np.cos(x))*np.exp(1j*np.pi*x)
    # return 0.3*np.sin(x) - 0.5*np.cos(x)

# 基底関数：偶関数のパレット cos(kπx/L) -> 今回は cos(kx)
def basis_cos(x, k):
    return np.cos(k * np.pi * x / L)

def basis_sin(x, k):
    return np.sin(k * np.pi * x / L)

# 係数を計算する関数（内積をとって射影する）
def calc_coeff(func, basis, k):
    # 積分の中身: f(x) * g(x)
    integrand = lambda x: func(x) * basis(x, k)
    # 区間 [-L, L] で数値積分
    integral_val, _ = quad(integrand, -L, L)

    # フーリエ係数の正規化
    norm = 2 * L if k == 0 else L
    return integral_val / norm

# 何個の基底（コサイン関数）を混ぜるか
N = 10

# コサイン基底の係数 a_k を計算
print("--- コサイン基底（偶関数）による展開係数 ---")
a_coeffs = []
for k in range(N + 1):
    coeff = calc_coeff(target_func, basis_cos, k)
    a_coeffs.append(coeff)
    print(f"a_{k} (cos({k}x)の係数): {coeff:.5f}")

# サイン基底の係数 b_k を計算
print("--- サイン基底（奇関数）による展開係数 ---")
b_coeffs = []
for k in range(N + 1):
    coeff = calc_coeff(target_func, basis_sin, k)
    b_coeffs.append(coeff)
    print(f"b_{k} (sin({k}x)の係数): {coeff:.5f}")

# 計算した係数を使って近似関数を組み立てる
def approx_function(x):
    res = np.zeros_like(x)
    for k in range(N + 1):
        res += a_coeffs[k] * basis_cos(x, k) + b_coeffs[k] * basis_sin(x, k)
    return res

# グラフの描画設定
x_vals = np.linspace(-L, L, 1000)
y_target = target_func(x_vals)
y_approx = approx_function(x_vals)

plt.figure(figsize=(10, 6))
# 元の関数（青色）
plt.plot(x_vals, y_target, label="Original: $\sin(x)$ (Odd)", color='blue', linewidth=2)
# コサインで頑張って近似した結果（赤色の破線）
plt.plot(x_vals, y_approx, label="Approximation by $\cos(kx)$ (Even) + $\sin(kx)$ (odd) ", color='red', linestyle='--', linewidth=3)

plt.title("Attempt to expand Odd function with Even basis")
plt.xlabel("x")
plt.ylabel("y")
plt.axhline(0, color='black', linewidth=0.5)
plt.axvline(0, color='black', linewidth=0.5)
plt.legend()
plt.grid(True)
plt.show()
