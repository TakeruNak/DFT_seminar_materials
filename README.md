# DFT Seminar Materials

Hands-on exercise materials for the internal seminar
**"Density Functional Theory — Theory and Calculation"**
Laboratory for Chemistry and Life Science (CLS), Institute of Science Tokyo.

Institute of Science Tokyo / CLS 立山・安藤グループ 内セミナー
**「密度汎関数理論（理論概略・計算）」** の演習資料一式。

---

## 📖 Choose your language / 言語を選択してください

<table>
<tr>
<td width="50%" valign="top">

### 🇬🇧 English

**→ [Open the English manual](docs/en/README.md)**

Start here if you prefer English.
The manual walks you from environment setup to
Quantum ESPRESSO calculations step by step.

</td>
<td width="50%" valign="top">

### 🇯🇵 日本語

**→ [日本語マニュアルを開く](docs/ja/README.md)**

日本語で読みたい場合はこちら。
環境構築から Quantum ESPRESSO 計算まで
手順どおり進められます。

</td>
</tr>
</table>

Both manuals cover exactly the same content and exercises.
どちらのマニュアルも内容・演習は完全に同一です。

---

## What is in this repository / このリポジトリの内容

| # | Topic | Exercise directory |
|---|---|---|
| 00 | Environment setup / 環境構築 | `00_environment/` |
| 01 | Self-consistent field (SCF) / 自己無撞着場 | `01_`, `02_` |
| 02 | Basis sets and completeness / 基底関数と完備性 | `03_`, `04_`, `05_` |
| 03 | Quantum ESPRESSO / Quantum ESPRESSO 入門 | `06_qe-examples/` |
| 04 | HOMO-LUMO analysis / HOMO-LUMO 解析 | `07_homo-lumo/` |
| 05 | Tight-binding model / Tight-binding モデル | `TB_model/` |

```
DFT_seminar_materials/
├── README.md            ← this page / このページ（言語選択）
├── requirements.txt      Python dependencies
├── docs/
│   ├── en/               English manual
│   └── ja/               日本語マニュアル
├── 00_environment/ ... 07_homo-lumo/, TB_model/   exercises / 演習
└── 99_slides/            lecture slides (git-ignored, distributed separately)
```

> `99_slides/` is **not** part of this repository (git-ignored).
> Lecture slides, exercise sheets and homework are distributed separately.
>
> `99_slides/` は **リポジトリに含まれません**（`.gitignore` 済）。
> 講義スライド・演習問題・HOMEWORK は担当者から別途配布されます。

---

## Quick start / クイックスタート

```bash
git clone https://github.com/TakeruNak/DFT_seminar_materials.git
cd DFT_seminar_materials
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

Then open [English setup](docs/en/00_setup.md) or [日本語の環境構築](docs/ja/00_setup.md).

> All exercises are verified on **QE 7.5 / Open MPI 5.0.9 / phonopy 3.5.1 /
> pythtb 2.0.0 / macOS (Apple Silicon)**. Reference values and measured
> runtimes are given in each chapter.

---

## Author / License

Takeru Nakashima (Laboratory for Chemistry and Life Science, Institute of Science Tokyo)
License: [LICENSE](LICENSE)
