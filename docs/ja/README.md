# DFT セミナー演習マニュアル（日本語）

[🌐 Language](../../README.md) ・ [English](../en/README.md) ・ 日本語 ・ [简体中文](../zh/README.md)

Institute of Science Tokyo / CLS Tateyama-Ando Group 内セミナー
**「密度汎関数理論（理論概略・計算）」** の演習マニュアル。

新しく研究室に配属された学生が、**このページを上から順にたどるだけで全ての演習を実行できる**ように構成されています。

---

## 進め方

1. ブラウザでこのページを開いたまま、手元で **Terminal** を 1 枚開く
2. [00. 環境構築](00_setup.md) を完了させる（初回のみ・所要 1〜2 時間）
3. 下表の演習を **上から順に** 実施する
4. 各章の末尾にある「確認事項」に答えられれば次へ進む

> **はじめに必ず読むこと** → [00_setup.md](00_setup.md)

---

## 学習ロードマップ

| # | 章 | 演習ディレクトリ | 学ぶこと | 所要 |
|---|---|---|---|---|
| 00 | [環境構築](00_setup.md) | `00_environment/` | Terminal, Homebrew, Git, Python, Quantum ESPRESSO | 1–2 h |
| 01 | [自己無撞着場 (SCF)](01_scf.md) | `01_`, `02_` | `01_`: SCF ループ, mixing ／ `02_`: Kohn-Sham 方程式（Hartree + 交換相関, double counting） | 1 h |
| 02 | [基底関数と完備性](02_basis.md) | `03_`, `04_`, `05_` | Fourier 展開, 完備性, 平面波基底, cutoff energy | 1.5 h |
| 03 | [Quantum ESPRESSO 入門](03_quantum-espresso.md) | `06_qe-examples/` | SCF, relax, 波動関数, band, DOS, PDOS, phonon | 3–4 h |
| 04 | [HOMO-LUMO 解析](04_homo-lumo.md) | `07_homo-lumo/` | 分子軌道の可視化とエネルギー準位 | 1 h |
| 05 | [Tight-binding モデル](05_tight-binding.md) | `TB_model/` | TB モデルと第一原理計算の対応 | 1 h |

**付録**

- [コマンド早見表・外部ツール・トラブルシュート](90_reference.md)

> 全演習は **QE 7.5 / Open MPI 5.0.9 / phonopy 3.5.1 / pythtb 2.0.0 / macOS (Apple Silicon)**
> で実行確認済み。各章に参照値と実測時間を載せてあるので、自分の結果と突き合わせること。

---

## 理論的な前提（セミナーで扱う範囲）

```
Many-Body Schrödinger eq.   HΦ = EΦ        ← 直接解くのは計算量的に不可能
          ↓  Hohenberg-Kohn theorem         E = E[n]  （全エネルギーは電子密度の汎関数）
          ↓  Kohn-Sham theorem              (-½∇² + v_eff[n]) φᵢ = εᵢ φᵢ
          ↓  E_xc への近似                   LDA / GGA / meta-GGA / hybrid
          ↓  基底関数で離散化                 平面波基底 + 擬ポテンシャル
          ↓  自己無撞着に解く                 SCF ループ
      Quantum ESPRESSO (PWscf)
```

本リポジトリの演習は、この流れの各ステップを **最小モデルで手を動かして確認する** ために並べてあります。

| 流れ | 対応する演習 |
|---|---|
| Kohn-Sham 方程式 / E_xc への近似 | 02 |
| 自己無撞着に解く | 01, 02 |
| 基底関数で離散化 | 03, 04, 05 |
| 擬ポテンシャル + 平面波 で実計算 | 06, 07 |
| 第一原理計算とモデルの対応 | TB_model |

---

## ディレクトリ構成

```
DFT_seminar_materials/
├── README.md                       ← 言語選択ページ（英語）
├── requirements.txt                 Python 依存パッケージ
├── docs/
│   ├── en/                          English manual
│   ├── ja/                          日本語マニュアル（このディレクトリ）
│   └── zh/                          简体中文手册
├── 00_environment/                  vim / tmux の設定例
├── 01_2-site-convergence/           演習 01: SCF ループと mixing（on-site = U·n）
├── 02_2-site-KSeq-convergence/      演習 02: Kohn-Sham 方程式（v_eff = V_H + V_xc）
├── 03_sinx_fitting/                 演習 03: 矩形波の Fourier 展開（Gibbs 現象）
├── 04_sinx-cosx/                    演習 04: 奇関数を cos 基底で展開（基底の対称性）
├── 05_gaussian-plane-wave-fitting/  演習 05: Gaussian の平面波展開（cutoff energy）
├── 06_qe-examples/                  演習 06: QE 実計算（H₂O, graphene/graphite, Si band/DOS/phonon）
├── 07_homo-lumo/                    演習 07: F₂ の HOMO-LUMO（relax → SCF → 軌道可視化）
├── TB_model/                        演習 08: graphene の tight-binding（Dirac cone・第一原理との比較）
└── 99_slides/                       講義スライド（.gitignore 済・配布は別途）
```

> `02_2-site-KSeq-convergence/` の `KSeq` は **K**ohn-**S**ham **eq**uation の略
>（k 点列 = k-point sequence ではない）。演習 01 の on-site energy `U·n` を、
> 演習 02 で Kohn-Sham の有効ポテンシャル `v_eff = V_H + V_xc` に置き換える、という関係。

> `99_slides/` は **リポジトリに含まれません**（`.gitignore` 済）。
> 講義スライド・演習問題・HOMEWORK は担当者から別途配布されます。

---

## 困ったとき

1. [90_reference.md](90_reference.md) の「トラブルシュート」を確認
2. エラーメッセージ全文をコピーして検索
3. それでも解決しなければ、**実行したコマンド** と **エラー全文** を添えて質問する

---

[次へ：00. 環境構築 →](00_setup.md)
