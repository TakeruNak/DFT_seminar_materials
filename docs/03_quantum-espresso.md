# 03. Quantum ESPRESSO 入門

[← 02. 基底関数](02_basis.md) | [目次](../README.md) | [次へ：04. HOMO-LUMO →](04_homo-lumo.md)

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

**ディレクトリ**: [`06_qe-examples/h2o/scf/`](../06_qe-examples/h2o/scf/)

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
grep 'total energy' h2o.scf.out | head    # SCF 各 step のエネルギー
grep 'estimated scf accuracy' h2o.scf.out # 残差の推移
grep 'highest occupied' h2o.scf.out       # HOMO / LUMO
grep 'Total force' h2o.scf.out            # 残留力
```

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

**ディレクトリ**: [`06_qe-examples/h2o/relax/`](../06_qe-examples/h2o/relax/)

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

### 課題

1. 最適化前後の O–H 結合長と H–O–H 結合角を計算し、実験値（0.958 Å, 104.5°）と比較する
2. `forc_conv_thr` を 1e-4 → 1e-3 に緩めると step 数と最終構造がどう変わるか

---

## 3-3. 波動関数の可視化（H₂O wf）

**ディレクトリ**: [`06_qe-examples/h2o/wf/`](../06_qe-examples/h2o/wf/)

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

> `.cube` は巨大（数十 MB）なので `.gitignore` 済み。commit しないこと。

---

## 3-4. 周期系の SCF（graphene / graphite）

### graphene（2D）

**ディレクトリ**: [`06_qe-examples/graphene/scf/`](../06_qe-examples/graphene/scf/)

```bash
cd 06_qe-examples/graphene/scf
./run-local.sh
grep '!' graphene.scf.out
```

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

**ディレクトリ**: [`06_qe-examples/graphite/`](../06_qe-examples/graphite/)

```bash
cd 06_qe-examples/graphite/vc-relax
./run-local.sh                              # 格子定数 + 原子位置の最適化
grep -A5 'CELL_PARAMETERS' graphite.vc-relax.out | tail -10

cd ../scf
./run-local.sh
```

### 課題

1. graphene の `K_POINTS` を `3 3 1` / `6 6 1` / `12 12 1` と変えて全エネルギーを比較する
   （**k 点収束テスト**）
2. graphene の面直方向の真空層を変えて（`CELL_PARAMETERS` の c）エネルギーの変化を見る
3. graphite の最適化後の層間距離を求め、実験値（3.35 Å）と比較する。
   PBE で層間距離が合わない理由を調べる（van der Waals 相互作用）

---

## 3-5. バンド構造（silicon）

**ディレクトリ**: [`06_qe-examples/sillicon/bands/`](../06_qe-examples/sillicon/bands/)

```
SCF (pw.x) → NSCF: calculation='bands' (pw.x) → bands.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/bands
./run-local.sh           # CAL bands。最後に chbandplot_mac.sh が band.plt を整形
gnuplot band.plt         # bands.pdf も生成される
```

> `chbandplot_mac.sh` は **`gsed`（GNU sed）** に依存する。
> 無い場合は `brew install gnu-sed`。

### バンドパス

`silicon.nscf.in` の `K_POINTS crystal_b` に Γ–X–U–K–Γ–L–W–X が書かれている。
パスは結晶の対称性で決まる。自分の系で調べるときは
[SeeK-path](https://www.materialscloud.org/work/tools/seekpath) を使う。

### 課題

1. `bands.pdf` を開き、Si のバンドギャップを読み取る。実験値（1.17 eV）と比較する
2. PBE/LDA がバンドギャップを過小評価する理由を調べる
3. `silicon.nscf.in` の `nbnd` を増やし、より高いバンドまで描く

---

## 3-6. 状態密度 DOS（silicon）

**ディレクトリ**: [`06_qe-examples/sillicon/dos/`](../06_qe-examples/sillicon/dos/)

```
SCF (pw.x) → NSCF 密なメッシュ (pw.x) → dos.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/dos
./run-local.sh              # CAL dos
./chdosplot_mac.sh silicon  # Fermi 準位を dos.plt に書き込む
gnuplot dos.plt             # dos.pdf 生成
```

### 課題

1. DOS と 3-5 のバンド図を並べ、ギャップ位置が一致することを確認する
2. `silicon.dos.in` の `degauss` を 0.01 → 0.05 と変えて broadening の効果を見る
3. NSCF の k 点メッシュを粗くすると DOS がどう劣化するか確認する

---

## 3-7. 射影状態密度 PDOS（silicon）

**ディレクトリ**: [`06_qe-examples/sillicon/pdos/`](../06_qe-examples/sillicon/pdos/)

各状態を原子軌道（s, p, d）に射影し、どの軌道由来かを分解する。

> `CAL proj` の処理は **NSCF から始まる**（SCF は実行されない）。
> `out/` が無い状態からは、先に SCF を済ませる必要がある。

```bash
cd 06_qe-examples/sillicon/pdos

# 1) まず SCF を実行
sed -i '' 's/^CAL  proj/CAL  scf/' system.in
./run-local.sh

# 2) PDOS を実行
sed -i '' 's/^CAL  scf/CAL  proj/' system.in
./run-local.sh

# 3) プロット
gnuplot projwfc.plt          # projwfc.pdf 生成
```

出力される `silicon.pdos.pdos_atm#1(Si)_wfc#1(s)` などが射影成分。

### 課題

1. `projwfc.plt` のコメントアウトを外し、Si-3s と Si-3p の寄与を重ねて描く
2. 価電子帯の上端・伝導帯の下端がそれぞれ主に s/p のどちらかを判定する
3. `silicon.pdos.pdos_tot` と DOS（3-6）が一致することを確認する

---

## 3-8. フォノン計算（silicon, 発展）

**ディレクトリ**: [`06_qe-examples/sillicon/phonon/`](../06_qe-examples/sillicon/phonon/)

phonopy を用いた有限変位法。**余裕がある場合のみ。**

```bash
pip install phonopy
```

手順は同ディレクトリの [`howtouse.md`](../06_qe-examples/sillicon/phonon/howtouse.md) に従う。

```
phonopy --qe -d --dim="2 2 2" -c *.scf.in   # supercell 生成
→ header.in の nat を修正 → ./attach_header_mac.sh
→ python making_script_mac.py → ./phonopy_*.sh
→ phonopy -f *.out                           # 力定数
→ phonopy --qe -c *.scf.in -p band.conf      # band plot
```

---

## まとめ

| 計算 | `CAL` | 主な出力 | 対応する物理量 |
|---|---|---|---|
| SCF | `scf` | `*.scf.out` | 全エネルギー、電荷密度 |
| 構造最適化 | `relax` / `vc-relax` | `*.vasp` | 平衡構造、格子定数 |
| 波動関数 | `wf` | `*.cube` | Kohn-Sham 軌道 |
| バンド | `bands` | `*.band.gnu`, `bands.pdf` | 分散関係、バンドギャップ |
| DOS | `dos` | `*.dos`, `dos.pdf` | 状態密度 |
| PDOS | `proj` | `*.pdos_atm#*`, `projwfc.pdf` | 軌道別寄与 |

### 収束テストの 3 本柱（研究で必ずやること）

1. **`ecutwfc` 収束** — 全エネルギーが変化しなくなる cutoff を探す（→ 演習 05）
2. **k 点収束** — メッシュを密にして全エネルギーが変化しなくなる点を探す
3. **真空層 / セルサイズ収束** — 孤立系・表面系で周期像の影響を切る（→ 演習 03）

---

[← 02. 基底関数](02_basis.md) | [目次](../README.md) | [次へ：04. HOMO-LUMO →](04_homo-lumo.md)
