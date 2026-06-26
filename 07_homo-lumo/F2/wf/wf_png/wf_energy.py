#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: wf_energy.py
Description: Energy level diagram plot adjusted for F2 molecule eigenvalues.
Author: Takeru Nakashima
Date: 2026-06-26

Copyright (c) 2026-06-26 <Takeru Nakashima>. All rights reserved.
"""

import numpy as np
import matplotlib.pyplot as plt

# 1. 新しいデータの定義 (F2分子の固有値)
eigenvalues = [-15.1798, -12.6376, -12.6376, -9.3160, -9.3160, -5.7980, -0.4147]
fermi_energy = -7.3731

# 2. フェルミエネルギーを基準(0 eV)にシフト
shifted_eigenvalues = [e - fermi_energy for e in eigenvalues]
shifted_fermi = 0.0

# 3. グラフのプロット設定
fig, ax = plt.subplots(figsize=(6, 8))

# フェルミ準位の破線を描画
ax.axhline(y=shifted_fermi, color='red', linestyle='--', linewidth=2, label=f'Fermi Energy ({fermi_energy} eV)')

# 4. 各エネルギー準位を描画（重複・縮退のハンドリングを含む）
# 重複をカウントするためにユニークな値とその個数を取得
unique_energies, counts = np.unique(eigenvalues, return_counts=True)

# 凡例用のフラグ
added_occ_label = False
added_unocc_label = False

for orig_e, count in zip(unique_energies, counts):
    shifted_e = orig_e - fermi_energy
    
    # フェルミ準位より下は青（占有）、上は赤（非占有）
    if shifted_e < 0:
        color = '#1f77b4'  # 青
        if not added_occ_label:
            label = 'Occupied'
            added_occ_label = True
        else:
            label = ""
    else:
        color = '#d62728'  # 赤
        if not added_unocc_label:
            label = 'Unoccupied'
            added_unocc_label = True
        else:
            label = ""
            
    # 線の描画（縮退している場合は線を少し太くして存在感を出します）
    line_width = 3 if count == 1 else 5
    ax.hlines(y=shifted_e, xmin=0.2, xmax=0.8, color=color, linewidth=line_width, label=label)
    
    # テキストラベルの作成 (2重縮退の場合はその旨を明記)
    deg_str = " (Degenerate)" if count > 1 else ""
    text_label = f"{shifted_e:+.4f} eV{deg_str}\n(orig: {orig_e:.4f} eV)"
    
    # 値のテキスト配列を追加
    ax.text(0.83, shifted_e, text_label, 
            va='center', ha='left', fontsize=9, color=color)

# 5. グラフの装飾
ax.set_title('Energy Levels relative to Fermi Energy', fontsize=12, fontweight='bold')
ax.set_ylabel('$E - E_F$ (eV)', fontsize=12)
ax.set_xlim(0, 1.5)  # テキストがしっかり収まるように横幅を拡張
ax.set_ylim(min(shifted_eigenvalues) - 1.5, max(shifted_eigenvalues) + 1.5) # 上下に余白を持たせる

# 不要な横軸の目盛り・枠線を消す
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
