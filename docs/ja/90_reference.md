# 付録：早見表・外部ツール・トラブルシュート

*[🌐 English](../en/90_reference.md) ・ 日本語*

[← 05. Tight-binding](05_tight-binding.md) | [目次](README.md)

---

## Linux コマンド早見表

| 目的 | コマンド |
|---|---|
| 現在地 | `pwd` |
| 一覧 | `ls` / `ls -la`（隠しファイル含む） |
| 移動 | `cd <dir>` / `cd ..`（1 つ上） / `cd ~`（ホーム） |
| ディレクトリ作成 | `mkdir -p <dir>` |
| コピー / 移動 | `cp <src> <dst>` / `mv <src> <dst>` |
| 削除 | `rm <file>` / `rm -r <dir>`（**取り消せない**） |
| 中身を見る | `cat <file>` / `less <file>`（`q` で終了） |
| 先頭 / 末尾 | `head -20 <file>` / `tail -20 <file>` |
| 検索 | `grep '!' *.out` / `grep -A5 'KEY' <file>`（後 5 行も表示） |
| 実行中の確認 | `top` / `ps aux \| grep pw.x` |
| 強制終了 | `Ctrl + C` |
| 履歴 | `history` / `↑` キー |
| 補完 | `Tab` キー |

---

## Git 早見表

| 目的 | コマンド |
|---|---|
| 取得 | `git clone <url>` |
| 更新を取り込む | `git pull` |
| 状態確認 | `git status` |
| 差分確認 | `git diff` |
| 変更を捨てる | `git restore <file>` |
| ブランチ作成 | `git switch -c <branch>` |

> **自分で書き換えた演習ファイルは commit しなくてよい。**
> `git pull` が衝突したら `git restore <file>` で元に戻してから pull する。

---

## Quantum ESPRESSO 早見表

### 出力から値を取り出す

```bash
grep '!'                      *.out   # 収束した全エネルギー
grep 'estimated scf accuracy' *.out   # SCF 残差の推移
grep 'Total force'            *.out   # 残留力
grep -i 'Fermi'               *.out   # Fermi 準位
grep 'number of k points'     *.out   # k 点数
grep -A6 'End of self-consistent calculation' *.out  # 固有値 (eV)
grep -A5 'ATOMIC_POSITIONS'   *.out   # 構造（relax 系）
grep 'PWSCF.*WALL'            *.out   # 計算時間
grep -c 'JOB DONE'            *.out   # 正常終了したか（1 なら OK）
grep -i 'error'               *.out   # エラー
```

> 本リポジトリの例題は全て `occupations = 'smearing'` なので HOMO/LUMO は
> `the Fermi energy is ...` と固有値の列から判断する。
> `highest occupied level` は `occupations = 'fixed'` のときだけ出る表記。

### 主要パラメータ

| パラメータ | 節 | 意味 |
|---|---|---|
| `calculation` | `&CONTROL` | `scf` / `nscf` / `bands` / `relax` / `vc-relax` |
| `prefix` | `&CONTROL` | 作業ファイルの名前 |
| `outdir` | `&CONTROL` | 作業ディレクトリ（通常 `./out/`） |
| `pseudo_dir` | `&CONTROL` | 擬ポテンシャルの場所 |
| `ecutwfc` | `&SYSTEM` | 波動関数の cutoff energy (Ry) |
| `ecutrho` | `&SYSTEM` | 電荷密度の cutoff energy (Ry) |
| `nbnd` | `&SYSTEM` | 計算するバンド数 |
| `occupations` | `&SYSTEM` | `smearing` / `fixed` / `tetrahedra` |
| `degauss` | `&SYSTEM` | smearing 幅 (Ry) |
| `nspin` | `&SYSTEM` | 2 でスピン分極 |
| `conv_thr` | `&ELECTRONS` | SCF 収束判定 |
| `mixing_beta` | `&ELECTRONS` | 密度の mixing 係数（演習 01 の `alpha`） |
| `electron_maxstep` | `&ELECTRONS` | SCF 最大反復数 |

公式ドキュメント: https://www.quantum-espresso.org/Doc/INPUT_PW.html

### 単位

| 量 | QE の既定単位 |
|---|---|
| エネルギー（入力 cutoff） | Ry |
| エネルギー（出力の固有値） | eV |
| 全エネルギー | Ry |
| 長さ | bohr または Å（`CELL_PARAMETERS angstrom`） |

1 Ry = 13.6057 eV, 1 bohr = 0.529177 Å

---

## 外部ツール

### 構造データベース

| サイト | 対象 |
|---|---|
| [PubChem](https://pubchem.ncbi.nlm.nih.gov/) | 分子 |
| [ChemSpider](https://www.chemspider.com/) | 分子 |
| [Materials Project](https://next-gen.materialsproject.org/) | バルク結晶 |
| [COD](https://www.crystallography.net/cod/) | 結晶構造（オープン） |
| [OQMD](https://oqmd.org/) | バルク結晶 |

### Web ツール

| サイト | 用途 |
|---|---|
| [QE input generator](https://qeinputgenerator.materialscloud.io/) | PWscf の input を GUI で生成 |
| [SeeK-path](https://www.materialscloud.org/work/tools/seekpath) | バンドパスの自動提案 |
| [SSSP](https://www.materialscloud.org/discover/sssp/) | 推奨擬ポテンシャル + 推奨 cutoff |

### 擬ポテンシャルライブラリ

| ライブラリ | 特徴 |
|---|---|
| [SSSP](https://www.materialscloud.org/discover/sssp/) | QE 向けに検証済み。**基本はこれを使う** |
| [PS-library](https://www.quantum-espresso.org/pseudopotentials/) | QE 公式 |
| [PseudoDojo](http://www.pseudo-dojo.org/) | 相対論補正、LDA/GGA 各種 |

> **LDA と GGA の擬ポテンシャルを混ぜて使ってはいけない。**
> 1 つの計算では同じ汎関数系列で統一する。

### ローカルツール

| ツール | 用途 | 導入 |
|---|---|---|
| VESTA | 結晶・分子・cube の可視化 | `brew install --cask vesta` |
| Avogadro | 分子モデリング | `brew install avogadro` |
| OpenBabel | 構造ファイル変換 | `brew install open-babel` |
| gnuplot | band / DOS のプロット | `brew install gnuplot` |
| GNU sed | プロット整形スクリプトが依存 | `brew install gnu-sed` |
| phonopy | フォノン計算（3-8） | `pip install "phonopy<4"` |

```bash
obabel input.sdf -O output.xyz --gen3d     # sdf → xyz
obabel input.sdf -O output.cif --gen3d     # sdf → cif
open -a VESTA output.xyz
```

---

## トラブルシュート

### 環境まわり

| 症状 | 対処 |
|---|---|
| `pw.x が見つかりません` | `which pw.x` を確認。無ければ `export QE_BIN_DIR=<QE の bin>` |
| `command not found: gsed` | `brew install gnu-sed` |
| `command not found: gnuplot` | `brew install gnuplot` |
| `ModuleNotFoundError: numpy` | `source .venv/bin/activate` を忘れていないか確認 |
| `ModuleNotFoundError: pythtb` | `pip install pythtb pymatgen` |
| `TBModel` が import できない | pythtb 2.0 以降が必要（`pip install -U pythtb`） |
| matplotlib のウィンドウが出ない | `plt.show()` の代わりに `plt.savefig()` を使う |
| `'-d' is a setup operation that moved to 'phonopy-init' in v4` | phonopy 4 が入っている。`pip install "phonopy<4"` |
| gnuplot が終了しない | `.plt` 内の `pause -1` の仕様。Terminal で Enter を押す |

### QE の実行エラー

| 症状 | 原因と対処 |
|---|---|
| `ERROR: Please put system.in in this directory` | `system.in_tmp` が生成されるので `system.in` にリネームして編集 |
| `file ... .UPF not found` | `pseudo_dir` の指定と実際の `pseudo/` の場所が合っているか確認 |
| `convergence NOT achieved` | `mixing_beta` を下げる（0.4 → 0.2 → 0.1）／ `electron_maxstep` を増やす ／ `degauss` を少し大きくする |
| `Not enough space allocated for radial FFT` | `ecutrho` を上げる |
| メモリ不足 / 異常終了 | `NUM_PROCS` を減らす ／ `ecutwfc`, k 点を下げて小さく試す |
| `mpirun` が無い | `brew install open-mpi`、または conda の QE を使う |
| 2 回目の実行結果がおかしい | `rm -rf out/` してやり直す |
| `fatal error reading xml file`（pp.x / projwfc.x） | SCF を先に流していない。`out/` が空なら `CAL scf` から実行する |
| `file ... .UPF not found` で絶対パスが出る | input の `pseudo_dir` が他人の環境のまま。`'./pseudo/'` などに直す |
| `Minimization algorithm failed to find Fermi energy` | 警告であってエラーではない（二分法に切り替わっただけ） |

### SCF が収束しないときの定石

1. `mixing_beta` を下げる（0.4 → 0.1）
2. `electron_maxstep` を増やす（80 → 200）
3. `degauss` を少し大きくする（金属系）
4. `mixing_mode = 'local-TF'` を試す（不均一な系）
5. まず粗い設定（低 cutoff・粗い k 点）で収束させ、その密度から出発する

→ 演習 [01. 自己無撞着場](01_scf.md) で `alpha` を変えたときと同じ現象。

---

## コミットしてはいけないファイル

`.gitignore` 済みだが、念のため。

| 対象 | 理由 |
|---|---|
| `99_slides/` | 講義スライド原本。**remote に push しない** |
| `out/` | 計算の作業ディレクトリ。巨大 |
| `*.cube` | 波動関数の出力。数十 MB |
| `.answear` | 解答例 |

```bash
git status            # commit 前に必ず確認する
```

---

## 参考文献

- P. Hohenberg, W. Kohn, *Phys. Rev.* **136**, B864 (1964) — Hohenberg-Kohn theorem
- W. Kohn, L. J. Sham, *Phys. Rev.* **140**, A1133 (1965) — Kohn-Sham equation
- J. P. Perdew, K. Burke, M. Ernzerhof, *Phys. Rev. Lett.* **77**, 3865 (1996) — PBE
- R. M. Martin, *Electronic Structure: Basic Theory and Practical Methods*
- P. Taylor, O. Heinonen, *Condensed Matter Physics*
- Y. Hinuma et al., *Comput. Mater. Sci.* **128**, 140 (2017) — バンドパスの規約
- [Quantum ESPRESSO 公式ドキュメント](https://www.quantum-espresso.org/documentation/)
- [phonopy with QE](https://phonopy.github.io/phonopy/qe.html)

---

[← 05. Tight-binding](05_tight-binding.md) | [目次](README.md)
