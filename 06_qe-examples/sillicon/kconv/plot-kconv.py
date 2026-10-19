#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Title: plot-kconv.py
Description: run-kconv.sh が出力した kconv.dat を読み、k 点収束を 2 枚のグラフにする。
             左: 全エネルギーそのもの / 右: 最密メッシュからのずれ（対数軸）
"""

import numpy as np
import matplotlib.pyplot as plt

RY_TO_MRY = 1000.0

nk, nkpt, etot = [], [], []
with open("kconv.dat") as f:
    for line in f:
        if line.startswith("#") or not line.strip():
            continue
        c = line.split()
        nk.append(int(c[0]))
        nkpt.append(int(c[1]))
        etot.append(float(c[2]))

nk = np.array(nk)
nkpt = np.array(nkpt)
etot = np.array(etot)

# 最密メッシュを「正解」とみなし、そこからのずれを見る
e_ref = etot[-1]
diff = np.abs(etot - e_ref) * RY_TO_MRY

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

# --- 左: 全エネルギー ---
ax1.plot(nk, etot, "o-")
ax1.axhline(e_ref, ls="--", lw=1, color="gray",
            label=f"{nk[-1]}x{nk[-1]}x{nk[-1]} = {e_ref:.6f} Ry")
ax1.set_xlabel("k-mesh  n  (n x n x n)")
ax1.set_ylabel("Total energy (Ry)")
ax1.set_title("Total energy vs k-mesh")
ax1.legend()
ax1.grid(True)

# --- 右: ずれ（対数軸） ---
#   最後の点はずれ 0 になり log 軸に乗らないので除く
ax2.semilogy(nk[:-1], diff[:-1], "s-")
ax2.axhline(1.0, ls="--", lw=1, color="red", label="1 mRy")
ax2.set_xlabel("k-mesh  n  (n x n x n)")
ax2.set_ylabel(f"|E - E({nk[-1]}x{nk[-1]}x{nk[-1]})|  (mRy)")
ax2.set_title("Deviation from the densest mesh")
ax2.legend()
ax2.grid(True, which="both")

plt.tight_layout()
plt.savefig("kconv.png", dpi=300)
plt.show()

# --- 標準出力にも表を出す ---
print(f"{'nk':>4} {'irr. k-points':>14} {'E (Ry)':>16} {'|dE| (mRy)':>12}")
for a, b, c, d in zip(nk, nkpt, etot, diff):
    print(f"{a:>4} {b:>14} {c:>16.8f} {d:>12.3f}")
