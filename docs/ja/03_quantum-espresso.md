# 03. Quantum ESPRESSO 入門

*[English](../en/03_quantum-espresso.md) ・ 日本語 ・ [简体中文](../zh/03_quantum-espresso.md)*

[← 02. 基底関数](02_basis.md) | [目次](README.md) | [次へ：04. HOMO-LUMO →](04_homo-lumo.md)

**ねらい**：平面波基底 + 擬ポテンシャル法の ab initio コードである Quantum ESPRESSO (QE) で、
SCF → 構造最適化 → 波動関数 → band → DOS → PDOS までの基本計算を一通り実行する。

> 先に [00. 環境構築](00_setup.md#0-7-quantum-espresso) で `pw.x` が動くことを確認しておくこと。

---

## 3-0. 共通ルール（必ず最初に読む）

### 実行方法

全ての演習ディレクトリは同じ形式。**`system.in` を編集して `./run-local.sh` を叩くだけ。**

```bash
cd 06_qe-examples/<例題ディレクトリ>
cat system.in          # 設定を確認
./run-local.sh         # 実行
```

### `system.in` の 3 行

```
NAME h2o            ← input file の prefix。 h2o.scf.in なら h2o
CAL  scf            ← 計算手法
NUM_PROCS 6         ← MPI 並列数。自分のマシンの物理コア数以下にする
```

`CAL` に指定できる主な値:

| `CAL` | 実行される内容 |
|---|---|
| `scf` | `pw.x` で SCF |
| `nscf` | `pw.x` で SCF → non-SCF |
| `relax` | `pw.x` で原子位置の構造最適化 |
| `vc-relax` | `pw.x` で原子位置 + 格子定数の構造最適化 |
| `bands` | SCF → NSCF → `bands.x` → プロット整形 |
| `dos` | SCF → NSCF → `dos.x` |
| `proj` | NSCF → `projwfc.x` → プロット整形 |
| `wf` | SCF → `pp.x`（波動関数を cube 出力） |
| `cd` | SCF → `pp.x`（電荷密度を cube 出力） |

### ディレクトリの中身

| ファイル | 役割 |
|---|---|
| `system.in` | 実行制御（上記 3 行） |
| `run-local.sh` | 実行スクリプト。QE バイナリは PATH または `$QE_BIN_DIR` から解決 |
| `<NAME>.scf.in` 等 | QE の input file |
| `pseudo/` | 擬ポテンシャル (`.UPF`) |
| `out/` | 計算で生成される作業ディレクトリ（`.gitignore` 済） |
| `<NAME>.*.out` | 計算結果のログ |

### 擬ポテンシャルを覗く（5 分）

演習 05 で「内殻電子をそのまま平面波で表すのは非現実的」という結論に達した。
その解決策が `pseudo/` に置いてある `.UPF` ファイルである。中身は読める：

```bash
cd 06_qe-examples/h2o/scf
grep -iE 'element=|z_valence|pseudo_type|functional=' pseudo/*.UPF
```

```
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   element=" H"
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   pseudo_type="USPP"
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   functional="PBE"
pseudo/H.pbe-rrkjus_psl.1.0.0.UPF:   z_valence="1.000000000000000E+000"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    element=" O"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    pseudo_type="PAW"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    functional=" SLA  PW   PBX  PBC"
pseudo/O.pbe-n-kjpaw_psl.0.1.UPF:    z_valence="6.000000000000000E+000"
```

| 項目 | 意味 |
|---|---|
| `z_valence` | **実際に解く電子の数**。O は 8 ではなく 6（1s² を凍結）、H は 1 |
| `functional` | この擬ポテンシャルが作られた汎関数（PBE / PZ など） |
| `pseudo_type` | `NC`（norm-conserving）/ `US`（ultrasoft）/ `PAW` |

ファイル名そのものが規約になっている（`O.pbe-n-kjpaw_psl.0.1.UPF`
= 元素 O / PBE / PAW 系）。H₂O の価電子は 6 + 1 + 1 = **8 個**で、`*.scf.out` の
`number of electrons = 8.00` と一致する。占有バンドは 4 本だが
`number of Kohn-Sham states` は **8** と出る——`occupations = 'smearing'` のため
QE が空バンドを足しているからで、3-1 の固有値が 8 個並ぶのも同じ理由である。

**確認すること**

1. 自分の例題の `z_valence` を数え、`&SYSTEM` の `nbnd` や価電子数と辻褄が合うか
2. [SSSP](https://www.materialscloud.org/discover/sssp/) でその元素の**推奨 `ecutwfc`**
   を調べ、input file の値と比べる（→ 3-1 課題 2 の cutoff 収束テストと同じ話）
3. 同じ計算の中で LDA の UPF と PBE の UPF を混ぜてはいけない理由を説明する

> `pseudo_type` が `US` / `PAW` のときは `ecutrho` を `ecutwfc` の 8〜12 倍
> 取る必要がある（`NC` なら 4 倍で足りる）。この比が足りないと SCF が収束しない。

---

### QE input file の構造

```
&CONTROL     計算種別と入出力（calculation, prefix, outdir, pseudo_dir）
&SYSTEM      系の定義（ecutwfc, ecutrho, nat, ntyp, occupations, nbnd）
&ELECTRONS   SCF の制御（conv_thr, mixing_beta, electron_maxstep）
&IONS        構造最適化の制御（relax 系のみ）
&CELL        格子最適化の制御（vc-relax のみ）
ATOMIC_SPECIES    元素と擬ポテンシャルの対応
ATOMIC_POSITIONS  原子座標
K_POINTS          k 点メッシュ / パス
CELL_PARAMETERS   格子ベクトル
```

**演習 01, 02, 05 で触った量との対応**:

| 演習での名前 | QE のパラメータ |
|---|---|
| mixing 係数 `alpha` | `mixing_beta` |
| 収束判定 `tol` | `conv_thr` |
| cutoff energy `E_cut` | `ecutwfc`（波動関数）, `ecutrho`（電荷密度） |

> パラメータの意味は公式ドキュメント参照: https://www.quantum-espresso.org/Doc/INPUT_PW.html

---

## 3-1. SCF 計算（H₂O）

**ディレクトリ**: [`06_qe-examples/h2o/scf/`](../../06_qe-examples/h2o/scf/)

孤立分子なので、10 Å の立方体セルに真空層を取って周期境界条件の影響を切っている
（→ 演習 03 で見た周期基底の性質）。

```bash
cd 06_qe-examples/h2o/scf
cat system.in            # NAME h2o / CAL scf
./run-local.sh
```

### 結果の確認

```bash
grep '!' h2o.scf.out                      # 全エネルギー（収束値）
grep 'estimated scf accuracy' h2o.scf.out # 残差の推移
grep -i 'Fermi' h2o.scf.out               # Fermi 準位
grep 'Total force' h2o.scf.out            # 残留力
grep -A6 'End of self-consistent calculation' h2o.scf.out   # 固有値 (eV)
```

> 本リポジトリの例題は全て `occupations = 'smearing'` なので、QE は
> `the Fermi energy is ...` と出力する。`highest occupied level` は
> `occupations = 'fixed'` のときだけ出る表記なので grep しても何も出ない。

**動作確認済みの参照値**（QE 7.5 / 6 MPI / 実行 20 秒）

| 項目 | 値 |
|---|---|
| 全エネルギー | `-44.04045673 Ry` |
| Fermi 準位 | `-4.1193 eV` |
| 固有値 (eV) | `-25.1858 -12.9610 -9.2120 -7.1077 -0.9506 0.4281 0.7307 1.0887` |
| 残留力 | `0.004066` |

同じ値が出れば環境は正しく動いている。

### 課題

1. `estimated scf accuracy` の推移を見て、演習 01 の `residual.png` と同じ形か確認する
2. `ecutwfc` を 60 → 30 → 20 と下げて全エネルギーの変化を記録する（**cutoff 収束テスト**）
3. `mixing_beta` を 0.4 → 0.1 / 0.9 と変え、SCF step 数がどう変わるか記録する

> `ecutrho` は通常 `ecutwfc` の 4 倍（norm-conserving）〜 8〜12 倍（ultrasoft/PAW）。

### 構造ファイルの扱い

```bash
obabel input.sdf -O output.xyz --gen3d    # 形式変換
open -a VESTA output.xyz                  # 可視化
```

構造の入手先は [90_reference.md](90_reference.md#構造データベース) を参照。

---

## 3-2. 構造最適化（H₂O relax）

**ディレクトリ**: [`06_qe-examples/h2o/relax/`](../../06_qe-examples/h2o/relax/)

```bash
cd 06_qe-examples/h2o/relax
./run-local.sh           # CAL relax
```

### 結果の確認

```bash
grep -A6 'ATOMIC_POSITIONS' h2o.relax.out | tail -20   # 最終構造
grep 'Total force' h2o.relax.out                       # 力の収束
grep '!' h2o.relax.out                                 # 各 step の全エネルギー
```

最適化後の構造は `h2o.relax.vasp` として保存されている。

### 力はどこから来るか（Hellmann-Feynman の定理）

`grep 'Total force'` で出てくる力は、数値微分で求めたものでは**ない**。
エネルギーを核座標 R で微分すると、

```
F = -dE/dR = -⟨ψ| ∂H/∂R |ψ⟩        ← Hellmann-Feynman の定理
```

となり、**波動関数の微分 ∂ψ/∂R が落ちる**。つまり SCF を 1 回解いて密度 n(r) が
求まれば、そこから力が**解析的に**得られる。

```
SCF を解く → n(r) → 力 F → 原子を動かす → 再び SCF …   （= relax）
```

もし力が数値微分でしか求まらないなら、原子 1 個あたり最低 6 回の SCF が必要になり、
構造最適化は実用にならない。**DFT が構造予測の道具になったのは、この定理が
あるからである。**

> 実際には基底関数が原子に張り付いている場合（局在基底）、∂ψ/∂R が完全には
> 落ちず **Pulay 力**という補正項が要る。平面波基底は原子位置に依存しないので
> この問題がなく、QE が力を素直に出せる理由の一つになっている。

**動作確認済みの参照値**（6 MPI / 実行 1 分）

| 項目 | 値 | 実験値 |
|---|---|---|
| 全エネルギー | `-44.04046586 Ry` | — |
| O–H 結合長 | 0.970 Å | 0.958 Å |
| H–O–H 結合角 | 104.2° | 104.5° |
| 最終 Total force | `0.000152` | — |

### 課題

1. 最適化前後の O–H 結合長と H–O–H 結合角を計算し、実験値（0.958 Å, 104.5°）と比較する
   （座標は分率座標。セルは 10 Å の立方体なので、差に 10 を掛ければ Å になる）
2. `forc_conv_thr` を 1e-4 → 1e-3 に緩めると step 数と最終構造がどう変わるか

---

## 3-3. 波動関数の可視化（H₂O wf）

**ディレクトリ**: [`06_qe-examples/h2o/wf/`](../../06_qe-examples/h2o/wf/)

SCF で求めた Kohn-Sham 軌道 φᵢ を `pp.x` で cube 形式に出力し、VESTA で見る。

```bash
cd 06_qe-examples/h2o/wf
cat h2o.wf.in            # 出力する軌道の指定
./run-local.sh           # CAL wf: scf -> pp.x
open -a VESTA h2o_G2.cube
```

### `h2o.wf.in` の要点

```
&inputpp
    plot_num = 7        ! 7 = Kohn-Sham 軌道の |ψ|²
    kpoint   = 1        ! 何番目の k 点か
    kband    = 2        ! ★ 何番目のバンド（軌道）か
    lsign    = .true.   ! 波動関数の符号を保持
/
&plot
    iflag         = 3   ! 3 次元出力
    output_format = 6   ! 6 = Gaussian cube
    fileout       = 'h2o_G2.cube'
/
```

### 課題

1. `kband` を 1, 2, 3, 4, 5 と変えて再実行し、それぞれ cube を出力して VESTA で見る
   （`fileout` も同時に変えること）
2. H₂O の価電子数から HOMO が何番目のバンドか求め、HOMO / LUMO を特定する
3. `wf_png/` の既存結果と比較する

**動作確認済み**（6 MPI / 実行 1 分）: `h2o_G2.cube`（約 32 MB）が生成される。

> `.cube` は巨大（数十 MB）なので `.gitignore` 済み。commit しないこと。
> `pp.x` は中間ファイル `tmp.pp` も作る。これも数十 MB になる。

---

## 3-4. 周期系の SCF（graphene / graphite）

### graphene（2D）

**ディレクトリ**: [`06_qe-examples/graphene/scf/`](../../06_qe-examples/graphene/scf/)

```bash
cd 06_qe-examples/graphene/scf
./run-local.sh
grep '!' graphene.scf.out
```

**動作確認済み**（4 MPI / 実行 2 秒）: 全エネルギー `-36.86820864 Ry`, Fermi 準位 `-1.6568 eV`

ポイント:

- `K_POINTS automatic` が `6 6 1` ← **面内のみメッシュ、面直は 1 点**
- セルの c 軸方向に真空層を取って層間相互作用を切っている

波動関数も同様に出せる:

```bash
cd ../wf
./run-local.sh           # CAL wf, kband=6
open -a VESTA graphene_G6.cube
```

### graphite（3D, vc-relax）

**ディレクトリ**: [`06_qe-examples/graphite/`](../../06_qe-examples/graphite/)

```bash
cd 06_qe-examples/graphite/vc-relax
./run-local.sh                              # 格子定数 + 原子位置の最適化
grep -A5 'CELL_PARAMETERS' graphite.vc-relax.out | tail -10

cd ../scf
./run-local.sh
```

**動作確認済み**

| 計算 | 時間 (8 MPI) | 結果 |
|---|---|---|
| `vc-relax` | 4 分 30 秒 | a = 2.4673 Å, c = 7.9009 Å → **層間距離 3.95 Å** |
| `scf` | 9 秒 | 全エネルギー `-73.77286739 Ry` |

> `scf` の出力に `Minimization algorithm failed to find Fermi energy: reverting to
> bisection` が出るが、これは警告であってエラーではない（半金属的で Fermi 準位の
> 探索が難しいため、より頑健な二分法に切り替えたという意味）。

### 課題

1. graphene の `K_POINTS` を `3 3 1` / `6 6 1` / `12 12 1` と変えて全エネルギーを比較する
   （**k 点収束テスト**）
2. graphene の面直方向の真空層を変えて（`CELL_PARAMETERS` の c）エネルギーの変化を見る
3. graphite の最適化後の層間距離を求め、実験値（3.35 Å）と比較する。
   PBE で層間距離が合わない理由を調べる（van der Waals 相互作用）

---

## 3-5. バンド構造（silicon）

**ディレクトリ**: [`06_qe-examples/sillicon/bands/`](../../06_qe-examples/sillicon/bands/)

```
SCF (pw.x) → NSCF: calculation='bands' (pw.x) → bands.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/bands
./run-local.sh           # CAL bands。最後に chbandplot_mac.sh が band.plt を整形
gnuplot band.plt         # 描画ウィンドウが開く
```

> `chbandplot_mac.sh` は **`gsed`（GNU sed）** に依存する。
> 無い場合は `brew install gnu-sed`。

`chbandplot_mac.sh` は `silicon.scf.out` から Fermi 準位を読み、`band.plt` の
`ef = ...` 行と k 点座標・縦線を自動で書き換える。

**PDF で保存したい場合**は `band.plt` 末尾の 3 行のコメントを外す
（`dos.plt` / `projwfc.plt` と違い、`band.plt` は既定で PDF を出さない）。

```gnuplot
set term pdfcairo enhanced size 4in, 3in font "Times New Roman,18"
set output "bands.pdf"
replot
```

> `band.plt` の途中に `pause -1` があるため、ウィンドウが出たあと
> Terminal で **Enter を押すまで gnuplot は終了しない**。

### バンドパス

`silicon.nscf.in` の `K_POINTS crystal_b` に Γ–X–U–K–Γ–L–W–X が書かれている。
パスは結晶の対称性で決まる。自分の系で調べるときは
[SeeK-path](https://www.materialscloud.org/work/tools/seekpath) を使う。

**動作確認済み**（6 MPI / 実行 6 秒）

| 項目 | 値 |
|---|---|
| Fermi 準位 | `6.7675 eV` |
| VBM (Γ) | `6.3959 eV` |
| CBM (X 近傍) | `7.0704 eV` |
| **間接ギャップ** | **0.67 eV**（実験値 1.17 eV） |

### 課題

1. `silicon.band.gnu` から Si のバンドギャップを読み取り、実験値（1.17 eV）と比較する
2. PBE/LDA がバンドギャップを過小評価する理由を調べる
   （→ 主因の一つは [演習 02 の課題 4](01_scf.md) で見た **自己相互作用誤差 (SIE)**）
3. 既定のパスは 1 区間あたり 2 点しか取っていないため、バンドが折れ線に見える。
   `silicon.nscf.in` の `K_POINTS crystal_b` の各行末の数字（区間の分割数）を
   20 程度に増やして滑らかなバンド図にする
4. `silicon.nscf.in` の `nbnd` を増やし、より高いバンドまで描く

---

## 3-6. 状態密度 DOS（silicon）

**ディレクトリ**: [`06_qe-examples/sillicon/dos/`](../../06_qe-examples/sillicon/dos/)

```
SCF (pw.x) → NSCF 密なメッシュ (pw.x) → dos.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/dos
./run-local.sh              # CAL dos  ★ 7〜8 分かかる
./chdosplot_mac.sh silicon  # Fermi 準位を dos.plt に書き込む
gnuplot dos.plt             # 描画 + dos.pdf を自動生成（Enter で終了）
```

> **時間がかかる理由**: NSCF の `K_POINTS automatic` が `50 50 50` で、
> 既約 k 点が 11050 点になるため。試すだけなら `20 20 20` に落としてよい。

**動作確認済み**（6 MPI / 実行 7 分 23 秒）: `silicon.dos` と `dos.pdf` が生成される。
Fermi 準位 `6.7675 eV`。

### 課題

1. DOS と 3-5 のバンド図を並べ、ギャップ位置が一致することを確認する
2. `silicon.dos.in` の `degauss` を 0.01 → 0.05 と変えて broadening の効果を見る
3. NSCF の k 点メッシュを粗くすると DOS がどう劣化するか確認する

---

## 3-7. 射影状態密度 PDOS（silicon）

**ディレクトリ**: [`06_qe-examples/sillicon/pdos/`](../../06_qe-examples/sillicon/pdos/)

各状態を原子軌道（s, p, d）に射影し、どの軌道由来かを分解する。

> `CAL proj` の処理は **NSCF から始まる**（SCF は実行されない）。
> `out/` が無い状態からは、先に SCF を済ませる必要がある。

```bash
cd 06_qe-examples/sillicon/pdos

# 1) まず SCF を実行（4 秒）
sed -i '' 's/^CAL  proj/CAL  scf/' system.in
./run-local.sh

# 2) PDOS を実行（★ 3〜4 分。NSCF が 50x50x50 メッシュのため）
sed -i '' 's/^CAL  scf/CAL  proj/' system.in
./run-local.sh

# 3) プロット（projwfc.pdf を自動生成。Enter で終了）
gnuplot projwfc.plt
```

> `run-local.sh` の `proj` 分岐は最後に `chprojwfcplot_mac.sh` を呼び、
> 生成された `*pdos_atm*` ファイルを `projwfc.plt` の plot 行に自動で並べる。

出力される `silicon.pdos.pdos_atm#1(Si)_wfc#1(s)` などが射影成分。

**動作確認済み**（6 MPI / SCF 4 秒 + PROJ 3 分 40 秒）

| 項目 | 値 |
|---|---|
| SCF 全エネルギー | `-22.83713469 Ry` |
| 生成ファイル | `pdos_atm#1(Si)_wfc#1(s)`, `#wfc#2(p)`, 原子 2 の同様分, `pdos_tot` |
| プロット | `projwfc.pdf` |

### 課題

1. `chprojwfcplot_mac.sh` が入れる凡例は全て `title 'title'` になっている。
   `projwfc.plt` を編集して `Si-3s` / `Si-3p` など意味のある凡例に直す
2. 価電子帯の上端・伝導帯の下端がそれぞれ主に s/p のどちらかを判定する
3. `projwfc.plt` のコメントアウトを外し、`silicon.pdos.pdos_tot` と
   DOS（3-6）が一致することを確認する

---

## 3-8. フォノン計算（silicon, 発展）

**ディレクトリ**: [`06_qe-examples/sillicon/phonon/`](../../06_qe-examples/sillicon/phonon/)

phonopy を用いた有限変位法。**余裕がある場合のみ。**

### phonopy のバージョン（重要）

本ディレクトリのスクリプトと [`howtouse.md`](../../06_qe-examples/sillicon/phonon/howtouse.md)
は **phonopy 3 系以前の CLI** を前提にしている。
phonopy 4 以降は `-d` / `-f` / `-c` が別コマンド `phonopy-init` に移動しており、
そのままでは動かない。

```bash
pip install "phonopy<4"          # 3.5.1 で動作確認済み
```

### 手順（動作確認済み）

```bash
cd 06_qe-examples/sillicon/phonon

# 1) 2x2x2 supercell と変位パターンを生成
phonopy --qe -d --dim="2 2 2" -c silicon.scf.in
#   → supercell-001.in, phonopy_disp.yaml

# 2) header.in の nat を supercell の原子数に合わせる（既定は nat = 16 で一致）
#    その上で QE input を組み立てる
./attach_header_mac.sh           # → silicon-001.in
python making_script_mac.py      # → phonopy_mac.sh

# 3) 各 supercell の SCF（★ 8〜9 分）
chmod +x phonopy_mac.sh
./phonopy_mac.sh                 # → silicon-001.out

# 4) 力定数
phonopy -f silicon-001.out       # → FORCE_SETS

# 5) バンド
phonopy --qe -c silicon.scf.in -p band.conf          # → band.yaml
phonopy-bandplot --gnuplot band.yaml > gnuplot_band.dat

# 6) PDOS
phonopy -p pdos.conf             # → projected_dos.dat
```

**動作確認済み**（phonopy 3.5.1, QE 7.5, 6 MPI）

| 項目 | 値 |
|---|---|
| supercell | 16 原子 / 変位パターン 1 個 / 空間群 Fd-3m (227) |
| supercell SCF | 8 分 36 秒 |
| フォノン周波数 | 0.00 〜 **15.28 THz**（実験の光学モード ≈ 15.5 THz） |

### 課題

1. `band.conf` の `BAND` を書き換えて別のパスで分散を描く
2. `--dim="2 2 2"` を `"3 3 3"` にすると何が改善するか（計算時間は大幅に増える）
3. Γ 点の音響モードが 0 になっているか確認する（なっていなければ力定数が不正確）

---

## まとめ

| 節 | 系 | `CAL` | 主な出力 | 実測時間 |
|---|---|---|---|---|
| 3-1 | H₂O | `scf` | `*.scf.out` | 20 秒 |
| 3-2 | H₂O | `relax` | `*.relax.vasp` | 1 分 |
| 3-3 | H₂O | `wf` | `*.cube` | 1 分 |
| 3-4 | graphene | `scf` / `wf` | `*.scf.out`, `*.cube` | 2 秒 |
| 3-4 | graphite | `vc-relax` / `scf` | 最適化セル | 4 分 30 秒 / 9 秒 |
| 3-5 | silicon | `bands` | `*.band.gnu` → `bands.pdf` | 6 秒 |
| 3-6 | silicon | `dos` | `*.dos` → `dos.pdf` | 7 分 23 秒 |
| 3-7 | silicon | `proj` | `*.pdos_atm#*` → `projwfc.pdf` | 3 分 44 秒 |
| 3-8 | silicon | （phonopy） | `band.yaml`, `projected_dos.dat` | 8 分 36 秒 |

時間はいずれも **Apple Silicon / 6 MPI（graphite のみ 8 MPI）** での実測値。

### PDF が自動生成されるかどうか

| スクリプト | PDF 自動生成 |
|---|---|
| `dos.plt` | ○ `dos.pdf` |
| `projwfc.plt` | ○ `projwfc.pdf` |
| `band.plt` | **×** 末尾 3 行のコメントを外す必要がある |

3 つとも途中に `pause -1` があるので、**Terminal で Enter を押すまで終了しない**。

### 収束テストの 3 本柱（研究で必ずやること）

1. **`ecutwfc` 収束** — 全エネルギーが変化しなくなる cutoff を探す（→ 演習 05）
2. **k 点収束** — メッシュを密にして全エネルギーが変化しなくなる点を探す
3. **真空層 / セルサイズ収束** — 孤立系・表面系で周期像の影響を切る（→ 演習 03）

---

[← 02. 基底関数](02_basis.md) | [目次](README.md) | [次へ：04. HOMO-LUMO →](04_homo-lumo.md)
