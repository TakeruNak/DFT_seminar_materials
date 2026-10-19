# 05. Tight-binding モデル（graphene）

*[English](../en/05_tight-binding.md) ・ 日本語 ・ [简体中文](../zh/05_tight-binding.md)*

[← 04. HOMO-LUMO](04_homo-lumo.md) | [目次](README.md) | [付録：早見表 →](90_reference.md)

**ねらい**：演習 01 で使った 2 サイト tight-binding を周期系に拡張し、
**モデル計算（top-down）と第一原理計算（bottom-up）が同じ物理を見ている**ことを確認する。

**ディレクトリ**: [`TB_model/graphene/src/`](../../TB_model/graphene/src/)

---

## 5-1. モデル

graphene の π 電子系を、A/B 2 副格子の最近接 tight-binding で記述する。

```
格子ベクトル   a₁ = (1, 0),  a₂ = (-1/2, √3/2)
軌道位置       A = (0, 0),  B = (1/3, 2/3)      （分率座標）
hopping        t = -2.8 eV  （最近接 A–B 間、3 本）
```

演習 01 の 2×2 行列が、k 空間で

```
H(k) = |  0      f(k)  |        f(k) = t · Σ_δ exp(i k·δ)
       | f*(k)    0    |
```

になったもの。K 点で f(k) = 0 となり、**Dirac cone** が現れる。

---

## 5-2. 実行

```bash
cd TB_model/graphene/src
source ../../../.venv/bin/activate
pip install pythtb pymatgen       # 未導入の場合
python graphene_tb.py
```

> `graphene_tb.py` が本体（出力は `graphene_tb.png`）。
> `template/graphene.py` は import だけの雛形で、実行には使わない。
> `pythtb` は **2.0 以降**が必要（`TBModel` / `Lattice` API を使う）。
> `pymatgen` は CIF 出力のコメント部分でのみ使うが、import されるので必要。

**動作確認済み**（pythtb 2.0.0 / 実行 10 秒程度）

| 項目 | 値 |
|---|---|
| バンド幅 | 約 17 eV ≈ 6\|t\| = 16.8 eV |
| K 点 | 2 本のバンドが 0 eV で縮退（**Dirac point**） |
| PDOS(A) と PDOS(B) | 完全に一致 |

### 出力

| ファイル | 内容 |
|---|---|
| `graphene_tb.png` | 左: バンド構造 (K′–Γ–K–M–Γ) / 右: DOS と副格子分解 PDOS |

計算内容:

1. **バンド構造** — `path = [K′, Γ, K, M, Γ]` を 300 点でサンプリング
2. **DOS / PDOS** — BZ を 120×120 メッシュで刻み、Gaussian broadening (σ = 0.10 eV)
   で状態密度を作り、固有ベクトルの A/B 成分 |c_A|², |c_B|² で分解

---

## 5-3. 触るパラメータ

| 変数 | 既定値 | 意味 |
|---|---|---|
| `t` | -2.8 | 最近接 hopping (eV) |
| `path`, `labels` | K′–Γ–K–M–Γ | バンドパス |
| `nk_path` | 300 | パス上の k 点数 |
| `nk_grid` | 120 | DOS 用の BZ メッシュ（120×120） |
| `sigma` | 0.10 | DOS の Gaussian broadening (eV) |
| `E_mesh` | -9 〜 9 eV | DOS のエネルギー範囲 |

---

## 5-4. 課題

1. K 点でバンドが縮退（Dirac point）していることを確認する
2. `sigma` を 0.02 / 0.10 / 0.5 と変え、DOS の van Hove 特異点の見え方を比較する
3. `nk_grid` を 30 / 60 / 120 と変え、DOS の滑らかさがどう変わるか確認する
   （→ 演習 **3-9** の k 点収束と同じ話）
4. A と B の PDOS が完全に一致する理由を、副格子の対称性から説明する
5. **オンサイトエネルギーの導入**: A と B に異なるオンサイトエネルギー（±Δ）を
   加えるとバンドがどう変わるか。これは何に対応するか（h-BN との関係）

---

## 5-5. 第一原理計算との比較

演習 03-4 で計算した graphene の QE 結果と比較する。

```bash
# QE 側のバンド計算（03-5 の silicon と同じ手順）
cd 06_qe-examples/graphene/scf
```

| 観点 | TB モデル | QE (DFT) |
|---|---|---|
| 基底 | 2 つの π 軌道 | 平面波（`ecutwfc` 本） |
| パラメータ | `t` を手で与える | 擬ポテンシャルのみ、t は結果 |
| 計算コスト | 2×2 行列 | 数千次元の SCF |
| 再現できる範囲 | π バンドのみ | 全価電子バンド |

### 確認事項

- [ ] TB の Dirac cone が QE のバンド図の K 点にも現れることを確認した
- [ ] モデル計算の `t` を、QE のバンド幅から見積もれる
      （graphene の π バンド幅 ≈ 6|t|）
- [ ] モデル計算と第一原理計算それぞれの長所・短所を説明できる

---

[← 04. HOMO-LUMO](04_homo-lumo.md) | [目次](README.md) | [付録：早見表 →](90_reference.md)
