# DFT Seminar Materials

Institute of Science Tokyo / CLS Tateyama-Ando Group 内セミナー
**「密度汎関数理論（理論概略・計算）」** の演習資料一式。

新しく研究室に配属された学生が、**このページを上から順にたどるだけで全ての演習を実行できる**ように構成されています。

---

## 進め方

1. ブラウザでこのページを開いたまま、手元で **Terminal** を 1 枚開く
2. [00. 環境構築](docs/00_setup.md) を完了させる（初回のみ・所要 1〜2 時間）
3. 下表の演習を **上から順に** 実施する
4. 各章の末尾にある「確認事項」に答えられれば次へ進む

> **はじめに必ず読むこと** → [docs/00_setup.md](docs/00_setup.md)

---

## 学習ロードマップ

| # | 章 | 演習ディレクトリ | 学ぶこと | 所要 |
|---|---|---|---|---|
| 00 | [環境構築](docs/00_setup.md) | `00_environment/` | Terminal, Homebrew, Git, Python, Quantum ESPRESSO | 1–2 h |
| 01 | [自己無撞着場 (SCF)](docs/01_scf.md) | `01_`, `02_` | SCF ループ, mixing, Kohn-Sham 方程式 | 1 h |
| 02 | [基底関数と完備性](docs/02_basis.md) | `03_`, `04_`, `05_` | Fourier 展開, 完備性, 平面波基底, cutoff energy | 1.5 h |
| 03 | [Quantum ESPRESSO 入門](docs/03_quantum-espresso.md) | `06_qe-examples/` | SCF, relax, 波動関数, band, DOS, PDOS, phonon | 3–4 h |
| 04 | [HOMO-LUMO 解析](docs/04_homo-lumo.md) | `07_homo-lumo/` | 分子軌道の可視化とエネルギー準位 | 1 h |
| 05 | [Tight-binding モデル](docs/05_tight-binding.md) | `TB_model/` | TB モデルと第一原理計算の対応 | 1 h |

**付録**

- [コマンド早見表・外部ツール・トラブルシュート](docs/90_reference.md)

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
| 自己無撞着に解く | 01, 02 |
| 基底関数で離散化 | 03, 04, 05 |
| 擬ポテンシャル + 平面波 で実計算 | 06, 07 |
| 第一原理計算とモデルの対応 | TB_model |

---

## ディレクトリ構成

```
DFT_seminar_materials/
├── README.md                       ← このファイル（入口）
├── requirements.txt                 Python 依存パッケージ
├── docs/                            マニュアル本体
│   ├── 00_setup.md
│   ├── 01_scf.md
│   ├── 02_basis.md
│   ├── 03_quantum-espresso.md
│   ├── 04_homo-lumo.md
│   ├── 05_tight-binding.md
│   └── 90_reference.md
├── 00_environment/                  vim / tmux の設定例
├── 01_2-site-convergence/           演習 01
├── 02_2-site-KSeq-convergence/      演習 02
├── 03_sinx_fitting/                 演習 03
├── 04_sinx-cosx/                    演習 04
├── 05_gaussian-plane-wave-fitting/  演習 05
├── 06_qe-examples/                  演習 06（QE 本体）
├── 07_homo-lumo/                    演習 07
├── TB_model/                        演習 08
└── 99_slides/                       講義スライド（.gitignore 済・配布は別途）
```

> `99_slides/` は **リポジトリに含まれません**（`.gitignore` 済）。
> 講義スライド・演習問題・HOMEWORK は担当者から別途配布されます。

---

## 困ったとき

1. [docs/90_reference.md](docs/90_reference.md) の「トラブルシュート」を確認
2. エラーメッセージ全文をコピーして検索
3. それでも解決しなければ、**実行したコマンド** と **エラー全文** を添えて質問する

---

## Author / License

Takeru Nakashima (Laboratory for Chemistry and Life Science, Institute of Science Tokyo)
License: [LICENSE](LICENSE)
