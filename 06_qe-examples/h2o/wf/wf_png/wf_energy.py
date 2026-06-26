#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: wf_energy.py
Description: <Description on this script>
Author: Takeru Nakashima
Date: 2026-06-26

Copyright (c) 2026-06-26 <Takeru Nakashima>. All rights reserved.
"""

import numpy
import matplotlib.pyplot as plt
import argparse
import logging

# Configure logging
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
import matplotlib.pyplot as plt

# 1. データの定義
eigenvalues = [-9.1977, -7.1040, -0.9529, 0.4271]
fermi_energy = -4.1157

# 2. フェルミエネルギーを基準(0 eV)にシフト
# (物理学・化学の慣習に合わせて、E - E_F を計算します)
shifted_eigenvalues = [e - fermi_energy for e in eigenvalues]
shifted_fermi = 0.0

# 3. グラフのプロット設定
fig, ax = plt.subplots(figsize=(5, 7))

# フェルミ準位の破線を描画
ax.axhline(y=shifted_fermi, color='red', linestyle='--', linewidth=2, label=f'Fermi Energy ({fermi_energy} eV)')

# 各エネルギー準位を横線（レベル）として描画
for i, energy in enumerate(shifted_eigenvalues):
    # フェルミ準位より下は青（占有）、上は赤（非占有）
    if energy < 0:
        color = '#1f77b4'  # 青
        label = 'Occupied' if i == 0 else "" # 凡例の重複を避ける
    else:
        color = '#d62728'  # 赤
        label = 'Unoccupied' if i == 2 else "" # 4つの値のうち3番目(-0.9529はシフト後正になる)
        
    ax.hlines(y=energy, xmin=0.2, xmax=0.8, color=color, linewidth=3, label=label)
    # 値のテキストラベルを追加（元のeV値も併記）
    ax.text(0.82, energy, f"{energy:+.4f} eV\n(orig: {eigenvalues[i]} eV)", 
            va='center', ha='left', fontsize=9, color=color)

# 4. グラフの装飾
ax.set_title('Energy Levels relative to Fermi Energy', fontsize=12, fontweight='bold')
ax.set_ylabel('$E - E_F$ (eV)', fontsize=12)
ax.set_xlim(0, 1.3)  # 横軸の範囲（テキストが収まるように調整）
ax.set_ylim(min(shifted_eigenvalues) - 1, max(shifted_eigenvalues) + 1) # 縦軸の範囲

# 不要な横軸の目盛りを消す
ax.set_xticks([])
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)

# 凡例の表示（重複を整理）
handles, labels = ax.get_legend_handles_labels()
by_label = dict(zip(labels, handles))
ax.legend(by_label.values(), by_label.keys(), loc='upper left')

plt.tight_layout()
plt.show()
