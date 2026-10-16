# 01. 自己無撞着場（SCF）

*[English](../en/01_scf.md) ・ 日本語 ・ [简体中文](../zh/01_scf.md)*

[← 00. 環境構築](00_setup.md) | [目次](README.md) | [次へ：02. 基底関数 →](02_basis.md)

**ねらい**：Kohn-Sham 方程式が「解を求めるのに解が必要」という循環構造を持つこと、
それを反復（SCF ループ）と mixing で解くことを、2 サイト最小モデルで体感する。

```
         ┌─────────────────────────────────────┐
         ↓                                     │
  n(r) → v_eff[n] → KS eq. を解く → φᵢ → n'(r) ─┘
                                        │
                              |n' - n| < tol なら収束
```

---

## 演習 01: 2-site tight-binding の自己無撞着

**ディレクトリ**: [`01_2-site-convergence/`](../../01_2-site-convergence/)

### モデル

2 原子分子を模した 2 サイト模型。on-site energy が自分の電子密度に依存する。

```
H = | U·n₁   -t   |      εᵢ = U·nᵢ  (on-site energy)
    |  -t   U·n₂  |      t         (hopping)
```

基底状態の固有ベクトル ψ から密度を更新 → H を作り直す、を繰り返す。

### 実行

```bash
cd 01_2-site-convergence
source ../.venv/bin/activate
python 2-site-convergence.py
```

### 出力

| ファイル | 内容 |
|---|---|
| `density.png` | 各サイトの密度 n₁, n₂ の反復変化 |
| `energy.png` | 基底状態エネルギーの反復変化 |
| `residual.png` | 残差 \|Δn\|（対数軸） |

標準出力に `Converged at iteration N` が出れば収束。

### 触るパラメータ

スクリプト冒頭を書き換えて再実行する。

| 変数 | 既定値 | 意味 | 試すこと |
|---|---|---|---|
| `U` | 2.0 | on-site 相互作用の強さ | 大きくすると発散・振動しやすい |
| `t` | 2.0 | hopping | |
| `alpha` | 0.1 | **mixing 係数** | 1.0 に近づけるほど速いが発散しやすい |
| `tol` | 1e-6 | 収束判定 | |
| `n1, n2` | 3.0, 2.0 | 初期密度（非対称） | 対称にすると何が起きるか |

### 課題

1. `alpha = 1.0`（mixing なし）にして実行し、`residual.png` がどうなるか確認する
2. `alpha` を 0.05 / 0.1 / 0.5 / 1.0 と変えて、収束に要した iteration 数を記録する
3. `U` を 2.0 → 10.0 に上げたとき、収束する `alpha` の範囲はどう変わるか

### 確認事項

- [ ] なぜ 1 回計算して終わりではなく、反復が必要なのか説明できる
- [ ] mixing parameter が何をしているか説明できる
- [ ] 残差プロットが対数軸である理由を説明できる

---

## 演習 02: 2-site 疑似 Kohn-Sham 方程式

**ディレクトリ**: [`02_2-site-KSeq-convergence/`](../../02_2-site-KSeq-convergence/)

### モデル

演習 01 の on-site energy を、Kohn-Sham の有効ポテンシャル `v_eff` に置き換える。

```
v_eff(n) = V_H(n) + V_xc(n)
V_H(n)   = U·n                 ← Hartree 項（古典 Coulomb）
V_xc(n)  = -A·√n               ← 交換相関項（LDA の √n 依存を模した形）
```

全エネルギーは **KS 固有値の単純な和ではない** ことに注意：

```
E_tot = ε_KS - E_H + E_xc        （double counting の補正）
E_H   = ½U(n₁² + n₂²)
E_xc  = -(2/3)A(n₁^1.5 + n₂^1.5)
```

### 実行

```bash
cd 02_2-site-KSeq-convergence
python 2-site-KSeq.py
```

### 出力

| ファイル | 内容 |
|---|---|
| `density.png` | 密度の収束 |
| `energy.png` | 全エネルギーの収束 |
| `residual.png` | 残差（対数軸） |
| `vxc.png` | V_xc の反復変化 |
| `totalN.png` | 粒子数保存の確認（1.0 の破線と比較） |
| `vxc_vs_density.png` | V_xc(n) 曲線上を解が動く様子 |
| `veff_vs_density.png` | V_eff(n) 曲線上を解が動く様子 |

### 触るパラメータ

| 変数 | 既定値 | 意味 |
|---|---|---|
| `U` | 4.0 | Hartree 項の強さ |
| `A` | 10.0 | **交換相関項の強さ** |
| `t` | -1.0 | hopping |
| `alpha` | 0.2 | mixing 係数 |
| `n1, n2` | 1.0, 0.0 | 初期密度 |

### 課題

1. `A = 0`（交換相関なし）で実行し、演習 01 と密度分布がどう違うか比較する
2. `A` を 0 → 5 → 10 → 20 と上げ、`vxc_vs_density.png` で解がどこに落ち着くか追う
3. `totalN.png` を見て、粒子数が保存されているか確認する

### 確認事項

- [ ] Hartree 項と交換相関項の役割の違いを説明できる
- [ ] `E_tot = ε_KS - E_H + E_xc` で引き算が入る理由（double counting）を説明できる
- [ ] KS 固有値 ε と全エネルギー E が別物であることを説明できる

---

## まとめ

| 概念 | この章で見たもの | 実際の DFT での対応 |
|---|---|---|
| SCF ループ | 2×2 行列の反復対角化 | 数万次元の KS 方程式の反復解法 |
| mixing | `alpha` | `mixing_beta`（QE の `&ELECTRONS`） |
| 収束判定 | `tol` | `conv_thr`（QE の `&ELECTRONS`） |
| v_eff | `U·n - A·√n` | Hartree + LDA/GGA 汎関数 |

→ 演習 03 で **QE の `mixing_beta` / `conv_thr`** として同じものが再登場する。

---

[← 00. 環境構築](00_setup.md) | [目次](README.md) | [次へ：02. 基底関数 →](02_basis.md)
