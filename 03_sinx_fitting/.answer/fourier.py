#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: fourier.py
Description: <Description on this script>
Author: Takeru Nakashima
Date: 2026-04-22

Copyright (c) 2026-04-22 <Takeru Nakashima>. All rights reserved.
"""

import numpy
import matplotlib.pyplot as plt
import argparse
import logging

# Configure logging
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
import numpy as np
import matplotlib.pyplot as plt

# x軸のデータ（-π から π まで）
x = np.linspace(-np.pi, np.pi, 1000)

# 理想的な矩形波（ターゲットとなる実際の関数）
# sin(x)の符号を取ることで、-1と1を行き来する矩形波を作る
y_ideal = np.sign(np.sin(x))

# 足し合わせる基底関数（サイン波）の数 N のリスト
N_list = [1, 3, 5, 50, 100, 200, 300, 400 ]

# グラフの設定
plt.figure(figsize=(12, 8))
# plt.suptitle("基底関数の増加による関数近似（完備性）の視覚化", fontsize=16)
plt.suptitle("Visualization of function approximation through increasing basis functions (Completeness)", fontsize=16)

for i, N in enumerate(N_list):
    y_approx = np.zeros_like(x)
    
    # N個の基底関数を足し合わせるループ
    # 矩形波のフーリエ級数は奇数次のみ現れるため、n = 2k-1 とする
    for k in range(1, N + 1):
        n = 2 * k - 1  
        # 各基底関数の係数とサイン波を計算して加算
        y_approx += (4 / np.pi) * (np.sin(n * x) / n)

    # グラフの描画処理
    plt.subplot(2, 4, i + 1)
    plt.plot(x, y_ideal, 'k--', linewidth=2, label='The original function (square wave)')
    plt.plot(x, y_approx, 'r-', label=f'Sum of basis functions (N={N})')
    plt.title(f'Using {N} basis function of sin(x)')
    plt.ylim(-1.5, 1.5)
    plt.legend()
    plt.grid(True)

plt.tight_layout()
plt.show()
