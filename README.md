# DFT Seminar Materials

Hands-on exercise materials for the internal seminar
**"Density Functional Theory — Theory and Calculation"**
Laboratory for Chemistry and Life Science (CLS), Institute of Science Tokyo.

---

## 📖 Choose your language

| | Manual | Start here |
|---|---|---|
| 🇬🇧 | **[English](docs/en/README.md)** | [Environment setup](docs/en/00_setup.md) |
| 🇯🇵 | **[日本語](docs/ja/README.md)** | [環境構築](docs/ja/00_setup.md) |
| 🇨🇳 | **[简体中文](docs/zh/README.md)** | [环境搭建](docs/zh/00_setup.md) |

All three manuals cover exactly the same content and exercises.

---

## What is in this repository

| # | Topic | Exercise directory |
|---|---|---|
| 00 | Environment setup | `00_environment/` |
| 01 | Self-consistent field (SCF) | `01_` (SCF loop, mixing) · `02_` (Kohn-Sham equation: Hartree + exchange-correlation) |
| 02 | Basis sets and completeness | `03_`, `04_`, `05_` |
| 03 | Quantum ESPRESSO | `06_qe-examples/` |
| 04 | HOMO-LUMO analysis | `07_homo-lumo/` |
| 05 | Tight-binding model | `TB_model/` |

```
DFT_seminar_materials/
├── README.md            ← this page (language selection)
├── requirements.txt      Python dependencies
├── docs/
│   ├── en/               English manual
│   ├── ja/               日本語マニュアル
│   └── zh/               简体中文手册
├── 00_environment/ ... 07_homo-lumo/, TB_model/   exercises
└── 99_slides/            lecture slides (git-ignored, distributed separately)
```

> `KSeq` in `02_2-site-KSeq-convergence/` stands for **K**ohn-**S**ham **eq**uation
> (not "k-point sequence").

> `99_slides/` is **not** part of this repository (git-ignored).
> Lecture slides, exercise sheets and homework are distributed separately by
> the organiser.

---

## Quick start

```bash
git clone https://github.com/TakeruNak/DFT_seminar_materials.git
cd DFT_seminar_materials
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

Then open the setup chapter in your language from the table above.

> All exercises are verified on **QE 7.5 / Open MPI 5.0.9 / phonopy 3.5.1 /
> pythtb 2.0.0 / macOS (Apple Silicon)**. Reference values and measured
> runtimes are given in each chapter.

---

## Author / License

Takeru Nakashima (Laboratory for Chemistry and Life Science, Institute of Science Tokyo)
License: [LICENSE](LICENSE)
