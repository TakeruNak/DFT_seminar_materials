# 03. Quantum ESPRESSO 入门

*[English](../en/03_quantum-espresso.md) ・ [日本語](../ja/03_quantum-espresso.md) ・ 简体中文*

[← 02. 基函数](02_basis.md) | [目录](README.md) | [下一章：04. HOMO-LUMO →](04_homo-lumo.md)

**目标**：用基于平面波基 + 赝势方法的第一性原理程序 Quantum ESPRESSO (QE)，
完整走一遍 SCF → 结构优化 → 波函数 → 能带 → DOS → PDOS 的基本计算流程。

> 请先在 [00. 环境搭建](00_setup.md#0-7-quantum-espresso) 中确认 `pw.x` 可以运行。

---

## 3-0. 通用规则（务必先读）

### 运行方式

所有练习目录格式相同。**只需编辑 `system.in` 然后执行 `./run-local.sh`。**

```bash
cd 06_qe-examples/<例题目录>
cat system.in          # 确认设置
./run-local.sh         # 运行
```

### `system.in` 的三行

```
NAME h2o            ← 输入文件的前缀。h2o.scf.in 则填 h2o
CAL  scf            ← 计算方法
NUM_PROCS 6         ← MPI 并行数。不要超过本机物理核心数
```

`CAL` 可取的主要值：

| `CAL` | 执行的内容 |
|---|---|
| `scf` | 用 `pw.x` 做 SCF |
| `nscf` | 用 `pw.x` 做 SCF → non-SCF |
| `relax` | 用 `pw.x` 优化原子位置 |
| `vc-relax` | 用 `pw.x` 优化原子位置 + 晶格常数 |
| `bands` | SCF → NSCF → `bands.x` → 绘图准备 |
| `dos` | SCF → NSCF → `dos.x` |
| `proj` | NSCF → `projwfc.x` → 绘图准备 |
| `wf` | SCF → `pp.x`（输出波函数为 cube） |
| `cd` | SCF → `pp.x`（输出电荷密度为 cube） |

### 目录中的文件

| 文件 | 作用 |
|---|---|
| `system.in` | 运行控制（上述三行） |
| `run-local.sh` | 运行脚本。QE 可执行文件从 `PATH` 或 `$QE_BIN_DIR` 解析 |
| `<NAME>.scf.in` 等 | QE 的输入文件 |
| `pseudo/` | 赝势 (`.UPF`) |
| `out/` | 计算生成的工作目录（已 `.gitignore`） |
| `<NAME>.*.out` | 计算结果日志 |

### 看一眼赝势文件（5 分钟）

练习 05 的结论是「直接用平面波表示内层电子不现实」。其解决方案就是放在 `pseudo/`
里的 `.UPF` 文件，而它的内容是可读的：

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

| 字段 | 含义 |
|---|---|
| `z_valence` | **实际参与求解的电子数**：O 是 6 而非 8（1s² 被冻结），H 是 1 |
| `functional` | 生成该赝势所用的泛函（PBE / PZ 等） |
| `pseudo_type` | `NC`（模守恒）/ `US`（超软）/ `PAW` |

文件名本身就是一种约定（`O.pbe-n-kjpaw_psl.0.1.UPF`
= 元素 O / PBE / PAW）。因此 H₂O 的价电子为 6 + 1 + 1 = **8 个**，与 `*.scf.out` 中的
`number of electrons = 8.00` 一致。占据的能带只有 4 条，但
`number of Kohn-Sham states` 显示为 **8**——因为 `occupations = 'smearing'`
使 QE 补充了空带，这也是 3-1 中列出 8 个本征值的原因。

**需要确认**

1. 数一下自己例题的 `z_valence`，与价电子数以及 `&SYSTEM` 中的 `nbnd` 是否吻合
2. 在 [SSSP](https://www.materialscloud.org/discover/sssp/) 查该元素的
   **推荐 `ecutwfc`**，与 input file 中的值比较（与 3-1 任务 2 的截断能收敛测试同理）
3. 说明为什么同一个计算中不能混用 LDA 与 PBE 的赝势

> 当 `pseudo_type` 为 `US` / `PAW` 时，`ecutrho` 需取 `ecutwfc` 的 8–12 倍
>（`NC` 取 4 倍即可）。该比值不足会导致 SCF 不收敛。

---

### QE 输入文件的结构

```
&CONTROL     计算类型与输入输出（calculation, prefix, outdir, pseudo_dir）
&SYSTEM      体系定义（ecutwfc, ecutrho, nat, ntyp, occupations, nbnd）
&ELECTRONS   SCF 控制（conv_thr, mixing_beta, electron_maxstep）
&IONS        结构优化控制（仅 relax 类）
&CELL        晶格优化控制（仅 vc-relax）
ATOMIC_SPECIES    元素与赝势的对应
ATOMIC_POSITIONS  原子坐标
K_POINTS          k 点网格 / 路径
CELL_PARAMETERS   晶格矢量
```

**与练习 01, 02, 05 中所调参数的对应**：

| 练习中的名称 | QE 的参数 |
|---|---|
| 混合系数 `alpha` | `mixing_beta` |
| 收敛判据 `tol` | `conv_thr` |
| 截断能 `E_cut` | `ecutwfc`（波函数）, `ecutrho`（电荷密度） |

> 各参数的含义参见官方文档：
> https://www.quantum-espresso.org/Doc/INPUT_PW.html

---

## 3-1. SCF 计算（H₂O）

**目录**：[`06_qe-examples/h2o/scf/`](../../06_qe-examples/h2o/scf/)

由于是孤立分子，使用 10 Å 的立方晶胞留出真空层，以切断周期性边界条件的影响
（→ 练习 03 中看到的周期性基的性质）。

```bash
cd 06_qe-examples/h2o/scf
cat system.in            # NAME h2o / CAL scf
./run-local.sh
```

### 查看结果

```bash
grep '!' h2o.scf.out                      # 总能量（收敛值）
grep 'estimated scf accuracy' h2o.scf.out # 残差的变化
grep -i 'Fermi' h2o.scf.out               # 费米能级
grep 'Total force' h2o.scf.out            # 残余力
grep -A6 'End of self-consistent calculation' h2o.scf.out   # 本征值 (eV)
```

> 本仓库的例题全部使用 `occupations = 'smearing'`，因此 QE 输出的是
> `the Fermi energy is ...`。`highest occupied level` 只在
> `occupations = 'fixed'` 时才出现，grep 它不会有任何结果。

**已验证的参考值**（QE 7.5 / 6 MPI / 耗时 20 秒）

| 项目 | 数值 |
|---|---|
| 总能量 | `-44.04045673 Ry` |
| 费米能级 | `-4.1193 eV` |
| 本征值 (eV) | `-25.1858 -12.9610 -9.2120 -7.1077 -0.9506 0.4281 0.7307 1.0887` |
| 残余力 | `0.004066` |

得到相同数值即说明环境工作正常。

### 任务

1. 观察 `estimated scf accuracy` 的变化，确认其形状是否与练习 01 的
   `residual.png` 一致
2. 把 `ecutwfc` 从 60 降到 30、20，记录总能量的变化（**截断能收敛测试**）
3. 把 `mixing_beta` 从 0.4 改为 0.1 / 0.9，记录 SCF 步数的变化

> `ecutrho` 通常取 `ecutwfc` 的 4 倍（模守恒）或 8–12 倍（超软/PAW）。

### 结构文件的处理

```bash
obabel input.sdf -O output.xyz --gen3d    # 格式转换
open -a VESTA output.xyz                  # 可视化
```

结构的获取途径参见 [90_reference.md](90_reference.md#结构数据库)。

---

## 3-2. 结构优化（H₂O relax）

**目录**：[`06_qe-examples/h2o/relax/`](../../06_qe-examples/h2o/relax/)

```bash
cd 06_qe-examples/h2o/relax
./run-local.sh           # CAL relax
```

### 查看结果

```bash
grep -A6 'ATOMIC_POSITIONS' h2o.relax.out | tail -20   # 最终结构
grep 'Total force' h2o.relax.out                       # 力的收敛
grep '!' h2o.relax.out                                 # 各步的总能量
```

优化后的结构保存为 `h2o.relax.vasp`。

### 力从何而来（Hellmann-Feynman 定理）

`grep 'Total force'` 给出的力**并非**通过数值微分求得。将能量对核坐标 R 求导，

```
F = -dE/dR = -⟨ψ| ∂H/∂R |ψ⟩        ← Hellmann-Feynman 定理
```

其中**波函数的导数 ∂ψ/∂R 被消掉了**。也就是说，只要解一次 SCF 得到密度 n(r)，
力就可以**解析地**得到。

```
解 SCF → n(r) → 力 F → 移动原子 → 再解 SCF …   （= relax）
```

如果力只能靠数值微分求得，每个原子至少要额外跑 6 次 SCF，结构优化将不具实用性。
**正是这条定理使 DFT 成为结构预测的工具。**

> 当基函数附着在原子上时（局域基），∂ψ/∂R 不能完全消去，需要称为 **Pulay 力**
> 的修正项。平面波不依赖原子位置，这也是 QE 能直接给出力的原因之一。

**已验证的参考值**（6 MPI / 耗时 1 分钟）

| 项目 | 数值 | 实验值 |
|---|---|---|
| 总能量 | `-44.04046586 Ry` | — |
| O–H 键长 | 0.970 Å | 0.958 Å |
| H–O–H 键角 | 104.2° | 104.5° |
| 最终 Total force | `0.000152` | — |

### 任务

1. 计算优化前后的 O–H 键长和 H–O–H 键角，与实验值（0.958 Å, 104.5°）比较
   （坐标为分数坐标；晶胞是 10 Å 的立方体，差值乘以 10 即为 Å）
2. 把 `forc_conv_thr` 从 1e-4 放宽到 1e-3，步数和最终结构如何变化？

---

## 3-3. 波函数的可视化（H₂O wf）

**目录**：[`06_qe-examples/h2o/wf/`](../../06_qe-examples/h2o/wf/)

用 `pp.x` 把 SCF 得到的 Kohn-Sham 轨道 φᵢ 输出为 cube 格式，再用 VESTA 查看。

```bash
cd 06_qe-examples/h2o/wf
cat h2o.wf.in            # 指定要输出的轨道
./run-local.sh           # CAL wf: scf -> pp.x
open -a VESTA h2o_G2.cube
```

### `h2o.wf.in` 的要点

```
&inputpp
    plot_num = 7        ! 7 = Kohn-Sham 轨道的 |ψ|²
    kpoint   = 1        ! 第几个 k 点
    kband    = 2        ! ★ 第几条能带（轨道）
    lsign    = .true.   ! 保留波函数的符号
/
&plot
    iflag         = 3   ! 三维输出
    output_format = 6   ! 6 = Gaussian cube
    fileout       = 'h2o_G2.cube'
/
```

### 任务

1. 把 `kband` 依次改为 1, 2, 3, 4, 5 重新运行，输出各自的 cube 并用 VESTA 查看
   （`fileout` 也要同时修改）
2. 由 H₂O 的价电子数推算 HOMO 是第几条能带，确定 HOMO / LUMO
3. 与 `wf_png/` 中已有的结果比较

**已验证**（6 MPI / 耗时 1 分钟）：生成 `h2o_G2.cube`（约 32 MB）。

> `.cube` 文件很大（数十 MB），已加入 `.gitignore`，请勿提交。
> `pp.x` 还会生成中间文件 `tmp.pp`，同样有数十 MB。

---

## 3-4. 周期体系的 SCF（graphene / graphite）

### graphene（二维）

**目录**：[`06_qe-examples/graphene/scf/`](../../06_qe-examples/graphene/scf/)

```bash
cd 06_qe-examples/graphene/scf
./run-local.sh
grep '!' graphene.scf.out
```

**已验证**（4 MPI / 耗时 2 秒）：总能量 `-36.86820864 Ry`，费米能级 `-1.6568 eV`

要点：

- `K_POINTS automatic` 为 `6 6 1` ← **仅面内取网格，面外只取 1 个点**
- 沿晶胞 c 轴留出真空层以切断层间相互作用

波函数同样可以输出：

```bash
cd ../wf
./run-local.sh           # CAL wf, kband=6
open -a VESTA graphene_G6.cube
```

### graphite（三维, vc-relax）

**目录**：[`06_qe-examples/graphite/`](../../06_qe-examples/graphite/)

```bash
cd 06_qe-examples/graphite/vc-relax
./run-local.sh                              # 优化晶格常数 + 原子位置
grep -A5 'CELL_PARAMETERS' graphite.vc-relax.out | tail -10

cd ../scf
./run-local.sh
```

**已验证**

| 计算 | 耗时 (8 MPI) | 结果 |
|---|---|---|
| `vc-relax` | 4 分 30 秒 | a = 2.4673 Å, c = 7.9009 Å → **层间距 3.95 Å** |
| `scf` | 9 秒 | 总能量 `-73.77286739 Ry` |

> `scf` 输出中会出现 `Minimization algorithm failed to find Fermi energy:
> reverting to bisection`，这是警告而非错误（因体系接近半金属，费米能级搜索
> 较困难，QE 切换到更稳健的二分法）。

### 任务

1. 把 graphene 的 `K_POINTS` 改为 `3 3 1` / `6 6 1` / `12 12 1`，比较总能量
   （**k 点收敛测试**）
2. 改变 graphene 面外方向的真空层厚度（`CELL_PARAMETERS` 的 c），观察能量变化
3. 求 graphite 优化后的层间距并与实验值（3.35 Å）比较。
   调查 PBE 无法重现层间距的原因（范德华相互作用）

---

## 3-5. 能带结构（silicon）

**目录**：[`06_qe-examples/sillicon/bands/`](../../06_qe-examples/sillicon/bands/)

```
SCF (pw.x) → NSCF: calculation='bands' (pw.x) → bands.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/bands
./run-local.sh           # CAL bands。最后由 chbandplot_mac.sh 整理 band.plt
gnuplot band.plt         # 弹出绘图窗口
```

> `chbandplot_mac.sh` 依赖 **`gsed`（GNU sed）**。
> 没有的话执行 `brew install gnu-sed`。

`chbandplot_mac.sh` 会从 `silicon.scf.out` 读取费米能级，自动改写 `band.plt`
中的 `ef = ...` 行以及 k 点坐标和竖线。

**若要保存 PDF**，请取消 `band.plt` 末尾三行的注释
（与 `dos.plt` / `projwfc.plt` 不同，`band.plt` 默认不输出 PDF）。

```gnuplot
set term pdfcairo enhanced size 4in, 3in font "Times New Roman,18"
set output "bands.pdf"
replot
```

> `band.plt` 中间有 `pause -1`，因此窗口弹出后
> **必须在终端按 Enter，gnuplot 才会退出**。

### 能带路径

`silicon.nscf.in` 的 `K_POINTS crystal_b` 中写有 Γ–X–U–K–Γ–L–W–X。
路径由晶体对称性决定。研究自己的体系时请使用
[SeeK-path](https://www.materialscloud.org/work/tools/seekpath)。

**已验证**（6 MPI / 耗时 6 秒）

| 项目 | 数值 |
|---|---|
| 费米能级 | `6.7675 eV` |
| VBM (Γ) | `6.3959 eV` |
| CBM (X 附近) | `7.0704 eV` |
| **间接带隙** | **0.67 eV**（实验值 1.17 eV） |

### 任务

1. 从 `silicon.band.gnu` 读出 Si 的带隙，与实验值（1.17 eV）比较
2. 调查 PBE/LDA 低估带隙的原因
   （主要成因之一是 [练习 02 任务 4](01_scf.md) 中看到的 **自相互作用误差 (SIE)**）
3. 默认路径每段只取 2 个点，因此能带看起来是折线。把 `silicon.nscf.in` 中
   `K_POINTS crystal_b` 各行末尾的数字（每段的分割数）增大到 20 左右，
   得到光滑的能带图
4. 增大 `silicon.nscf.in` 中的 `nbnd`，画出更高的能带

---

## 3-6. 态密度 DOS（silicon）

**目录**：[`06_qe-examples/sillicon/dos/`](../../06_qe-examples/sillicon/dos/)

```
SCF (pw.x) → NSCF 密网格 (pw.x) → dos.x → gnuplot
```

```bash
cd 06_qe-examples/sillicon/dos
./run-local.sh              # CAL dos  ★ 需要 7–8 分钟
./chdosplot_mac.sh silicon  # 把费米能级写入 dos.plt
gnuplot dos.plt             # 绘图并自动生成 dos.pdf（按 Enter 退出）
```

> **耗时的原因**：NSCF 的 `K_POINTS automatic` 为 `50 50 50`，
> 不可约 k 点达 11050 个。仅作尝试时可降到 `20 20 20`。

**已验证**（6 MPI / 耗时 7 分 23 秒）：生成 `silicon.dos` 和 `dos.pdf`。
费米能级 `6.7675 eV`。

### 任务

1. 把 DOS 与 3-5 的能带图并排放置，确认带隙位置一致
2. 把 `silicon.dos.in` 的 `degauss` 从 0.01 改为 0.05，观察展宽的效果
3. 把 NSCF 的 k 点网格变粗，确认 DOS 如何劣化

---

## 3-7. 投影态密度 PDOS（silicon）

**目录**：[`06_qe-examples/sillicon/pdos/`](../../06_qe-examples/sillicon/pdos/)

把各个态投影到原子轨道（s, p, d）上，分解出它们分别来自哪个轨道。

> `CAL proj` 的流程 **从 NSCF 开始**（不执行 SCF）。
> 在 `out/` 为空的状态下，必须先完成 SCF。

```bash
cd 06_qe-examples/sillicon/pdos

# 1) 先执行 SCF（4 秒）
sed -i '' 's/^CAL  proj/CAL  scf/' system.in
./run-local.sh

# 2) 执行 PDOS（★ 3–4 分钟。NSCF 为 50x50x50 网格）
sed -i '' 's/^CAL  scf/CAL  proj/' system.in
./run-local.sh

# 3) 绘图（自动生成 projwfc.pdf，按 Enter 退出）
gnuplot projwfc.plt
```

> `run-local.sh` 的 `proj` 分支最后会调用 `chprojwfcplot_mac.sh`，
> 把生成的 `*pdos_atm*` 文件自动排入 `projwfc.plt` 的 plot 行。

输出的 `silicon.pdos.pdos_atm#1(Si)_wfc#1(s)` 等即为投影分量。

**已验证**（6 MPI / SCF 4 秒 + PROJ 3 分 40 秒）

| 项目 | 数值 |
|---|---|
| SCF 总能量 | `-22.83713469 Ry` |
| 生成的文件 | `pdos_atm#1(Si)_wfc#1(s)`, `#wfc#2(p)`, 原子 2 的同类文件, `pdos_tot` |
| 绘图 | `projwfc.pdf` |

### 任务

1. `chprojwfcplot_mac.sh` 插入的图例全部是 `title 'title'`。
   编辑 `projwfc.plt`，改为 `Si-3s` / `Si-3p` 等有意义的图例
2. 判断价带顶和导带底分别主要来自 s 还是 p
3. 取消 `projwfc.plt` 中相应行的注释，确认 `silicon.pdos.pdos_tot`
   与 3-6 的 DOS 一致

---

## 3-8. 声子计算（silicon, 进阶）

**目录**：[`06_qe-examples/sillicon/phonon/`](../../06_qe-examples/sillicon/phonon/)

使用 phonopy 的有限位移法。**仅在有余力时进行。**

### phonopy 的版本（重要）

本目录的脚本和
[`howtouse.md`](../../06_qe-examples/sillicon/phonon/howtouse.md)
都基于 **phonopy 3 系及更早版本的 CLI**。
phonopy 4 以后 `-d` / `-f` / `-c` 被移到了独立命令 `phonopy-init`，
直接使用会失败。

```bash
pip install "phonopy<4"          # 已用 3.5.1 验证
```

### 步骤（已验证）

```bash
cd 06_qe-examples/sillicon/phonon

# 1) 生成 2x2x2 超胞与位移模式
phonopy --qe -d --dim="2 2 2" -c silicon.scf.in
#   → supercell-001.in, phonopy_disp.yaml

# 2) 让 header.in 的 nat 与超胞原子数一致（默认 nat = 16 已匹配），
#    然后组装 QE 输入文件
./attach_header_mac.sh           # → silicon-001.in
python making_script_mac.py      # → phonopy_mac.sh

# 3) 各超胞的 SCF（★ 8–9 分钟）
chmod +x phonopy_mac.sh
./phonopy_mac.sh                 # → silicon-001.out

# 4) 力常数
phonopy -f silicon-001.out       # → FORCE_SETS

# 5) 能带
phonopy --qe -c silicon.scf.in -p band.conf          # → band.yaml
phonopy-bandplot --gnuplot band.yaml > gnuplot_band.dat

# 6) PDOS
phonopy -p pdos.conf             # → projected_dos.dat
```

**已验证**（phonopy 3.5.1, QE 7.5, 6 MPI）

| 项目 | 数值 |
|---|---|
| 超胞 | 16 原子 / 1 个位移模式 / 空间群 Fd-3m (227) |
| 超胞 SCF | 8 分 36 秒 |
| 声子频率 | 0.00 – **15.28 THz**（实验光学模约 15.5 THz） |

### 任务

1. 改写 `band.conf` 的 `BAND`，沿其他路径绘制色散
2. 把 `--dim="2 2 2"` 改为 `"3 3 3"` 会改善什么？（计算时间会大幅增加）
3. 确认 Γ 点的声学模是否为 0（若不为 0 说明力常数不够准确）

---

## 3-9. k 点收敛测试（silicon）

**目录**：[`06_qe-examples/sillicon/kconv/`](../../06_qe-examples/sillicon/kconv/)

**目标**：在「收敛测试的三根支柱」中，练习 05（截断能）与练习 03（真空层）
已经覆盖了两根，这里实际跑一遍剩下的 **k 点收敛**。

周期体系中，Brillouin 区内的积分要用有限个 k 点求和来近似。
k 点不够时，总能量、力和能带都不可信。

```bash
cd 06_qe-examples/sillicon/kconv
cat system.in            # K_LIST 2 4 6 8 10 12 14
./run-kconv.sh
```

脚本**只**改 `si.scf.in.tmpl` 中的 k 网格并重复 SCF。
截断能、结构、赝势全部固定——**每次只变一个量是收敛测试的铁律**。

结果写入 `kconv.dat`。作图：

```bash
source ../../../.venv/bin/activate
python plot-kconv.py          # kconv.png
```

### 已验证的参考值

**QE 7.5 / 6 MPI / Apple Silicon / 全部 7 个算例共 11 秒**

| k 网格 | 不可约 k 点 | 总能量 (Ry) | 与 14×14×14 之差 (mRy) |
|---|---|---|---|
| 2×2×2 | 3 | `-22.65063727` | **187.696** |
| 4×4×4 | 8 | `-22.82563276` | 12.701 |
| 6×6×6 | 16 | `-22.83871576` | 0.382 |
| 8×8×8 | 29 | `-22.83753033` | 0.803 |
| 10×10×10 | 47 | `-22.83784804` | 0.486 |
| 12×12×12 | 72 | `-22.83814573` | 0.188 |
| 14×14×14 | 104 | `-22.83833364` | — |

可以读出：

1. **2×2×2 偏差 188 mRy（≈ 2.6 eV）。** 结构之间的能量差要在 mRy 量级上讨论，
   所以这完全不能用。
2. **收敛不是单调的。** 6×6×6 比参考值低 0.382 mRy，8×8×8 又回到高 0.803 mRy。
   这正是**不能「取两个点、看差值小就宣布收敛」**的原因。
3. **开销由不可约 k 点数决定，而不是 n³。** 对称性把 14³ = 2744 个点约化为 104 个。

### 补充：改变设置后的收敛（均为实测值）

k 点收敛与其他设置纠缠在一起。下表结构与截断能相同，只改变列标注的部分，
列出的是「相对于该列自身 14×14×14 值的偏差 (mRy)」。

| k 网格 | 默认<br>(cold smearing, degauss 0.02) | `occupations='fixed'` | degauss 0.05 |
|---|---|---|---|
| 2×2×2 | 187.696 | 187.808 | 184.097 |
| 4×4×4 | 12.701 | 13.825 | 13.832 |
| 6×6×6 | 0.382 | 1.759 | 1.603 |
| 8×8×8 | 0.803 | 0.285 | 0.010 |
| 该列 14³ 的值 (Ry) | `-22.83833364` | `-22.83960904` | `-22.83792684` |

- 改为 `fixed` 后**振荡消失，收敛变为单调**。默认设置的非单调行为是
  cold smearing 造成的。对半导体而言 `fixed` 才是物理上正确的选择。
- 提高 degauss 使 8×8×8 的残差从 **0.803 降到 0.010 mRy**：
  smearing 抹平了 k 点采样的不足。
- 但是**三列收敛到的值各不相同**（最大相差 1.3 mRy）。
  smearing 掩盖了 k 点不足，代价是收敛到另一个答案。
  **「收敛到了什么」只有连同设置一起说才有意义。**

奇数网格同样为实测值（默认设置，相对 14³ 的偏差）：

| | 3×3×3 | 5×5×5 | 7×7×7 | 9×9×9 |
|---|---|---|---|---|
| 不可约 k 点 | 4 | 10 | 20 | 35 |
| 偏差 (mRy) | 44.52 | 3.54 | **1.24** | 0.69 |

**7×7×7（不可约 20 点）比 6×6×6（16 点）更差**——k 点更多，精度反而更低。
奇数与偶数网格不落在同一条光滑曲线上，比较时不要把两个序列混在一起。

### 任务

1. 在 `K_LIST` 中加入 `3 5 7 9` 并运行，重现上面的奇数网格表。
   从 Γ 点与高对称点的权重出发，思考 7×7×7 为何比 6×6×6 差
2. 把 `si.scf.in.tmpl` 改为 `occupations = 'fixed'`（删除 `degauss` 与
   `smearing` 两行），确认振荡消失
3. 把 `nosym = .false.` 改为 `.true.` 并运行 8×8×8。不可约 k 点从 29 增至 260，
   而总能量仅从 `-22.83753033` 变到 `-22.83753027`。说明对称性节省了什么
4. 对半金属 graphene（`06_qe-examples/graphene/scf/`）做同样的收敛测试，
   确认它比半导体 silicon 需要多得多的 k 点

### 自查清单

- [ ] 能说明 k 网格离散化的是什么
- [ ] 能说明收敛测试为何「每次只变一个量」
- [ ] 能说明收敛可能非单调，因此至少要取 3 个点
- [ ] 能说明改变 smearing 会移动收敛值本身
- [ ] 能说明不可约 k 点数与计算开销的关系

---

## 3-10. 交换关联泛函的比较（LDA vs PBE）

**目录**：[`06_qe-examples/sillicon/xc/`](../../06_qe-examples/sillicon/xc/)

**目标**：练习 02 中使用了 `V_xc = -A·√n` 这一玩具模型。在真实的 DFT 计算中，
对 E_xc 的近似如何选择会左右结果。这里用晶格常数来定量考察这一效应。

```
LDA (PZ)   局域密度近似。E_xc 只由各点的密度 n(r) 决定
PBE (GGA)  广义梯度近似。还要用到 ∇n(r)
```

### 所用的赝势

```bash
cd 06_qe-examples/sillicon/xc
grep -iE 'functional=|pseudo_type|core_correction|z_valence|l_max' *.UPF
```

| | `Si.pz-n-rrkjus_psl.0.1.UPF` | `Si.pbe-n-rrkjus_psl.0.1.UPF` |
|---|---|---|
| `functional` | **LDA** | **PBE** |
| `pseudo_type` | USPP | USPP |
| `core_correction` | T | T |
| `z_valence` | 4 | 4 |
| `l_max` | 2 | 2 |

**这一对是特意挑选的：除 `functional` 之外完全一致。**
若比较生成方式不同的赝势，泛函的效应与赝势的效应就会混在一起无法分离。

> 正如 3-0 所述，**同一个计算中绝不能混用 LDA 与 PBE**。
> 这里做的是「分别跑两个计算再比较结果」，而不是混用。

```bash
./run-xc.sh
```

### 已验证的参考值

**QE 7.5 / 6 MPI / 两个算例共 19 秒**（vc-relax，残余压力均 ≈ 0 kbar）

| 泛函 | 平衡晶格常数 a₀ (Å) | 与实验值之差 | 总能量 (Ry) |
|---|---|---|---|
| LDA (PZ) | **5.3987** | **−0.6 %** | `-22.76784172` |
| PBE (GGA) | **5.4687** | **+0.7 %** | `-22.83615811` |
| 实验值 | 5.431 | — | — |

**LDA 把成键估计得过强（overbinding），PBE 估计得过弱（underbinding），
实验值被夹在两者之间。** 这不是 Si 特有的，而是许多固体的普遍趋势。

> **绝不能跨泛函比较总能量的数值。**
> E_xc 的定义本身不同，能量零点也就不同。
> 看到 `-22.768` 与 `-22.836` 就断定「PBE 更稳定」是错误的。
> 可以比较的是**同一泛函内部**的能量差（结构 A 与 B 之差）以及晶格常数这类结构量。

### 带隙（参考·实测值）

在各泛函自身的平衡晶格常数下，以 `occupations = 'fixed'` 在 8×8×8 网格上
读取 Kohn-Sham 间接带隙：

| 泛函 | KS 间接带隙 |
|---|---|
| LDA | 0.441 eV |
| PBE | 0.611 eV |
| 实验值 | **1.17 eV** |

**从 LDA 换到 PBE 并不能让带隙达到实验值**（38 % → 52 %）。
晶格常数因 PBE 而改善，带隙却没有。这不是泛函精度的问题，而是源于
[练习 02 任务 4](01_scf.md) 中看到的**自相互作用误差 (SIE)**，
以及 KS 本征值并非准粒子能量这一事实。

> 这是网格上的取值，与 3-5 沿能带路径读出的值（PBE 0.67 eV）略有出入，
> 因为真正的 CBM 未必落在网格上。要讨论的不是绝对值，而是
> **LDA 与 PBE 之差（0.17 eV）相对于与实验之差（0.5 eV 以上）而言很小**。

### 任务

1. 计算 `a₀` 相差 0.07 Å 换算成体积是百分之几
2. 从各泛函的 `si.vc-relax.*.out` 估算体弹性模量
   （取几个晶格常数拟合 E–V 曲线），与实验值 98 GPa 比较
3. 用 LDA 赝势重做 3-5 的能带计算，确认除带隙外整体能带形状与 PBE 几乎相同
4. 对 graphite（`06_qe-examples/graphite/`）做同样的比较，层间距的差异会更极端。
   调查 LDA / GGA 如何处理 van der Waals 力

### 自查清单

- [ ] 能用一句话说明 LDA 与 GGA 的区别
- [ ] 能说明比较泛函时为何必须统一赝势
- [ ] 能说明为何不能跨泛函比较总能量的绝对值
- [ ] 能说明 LDA 的 overbinding 与 GGA 的 underbinding 趋势
- [ ] 能说明为何换成 GGA 也解决不了带隙问题

---

## 3-11. 自旋极化（O₂ 的三重态基态）

**目录**：[`06_qe-examples/o2/spin/`](../../06_qe-examples/o2/spin/)

**目标**：到目前为止所有计算都把 ↑ 与 ↓ 电子当作同一种东西（`nspin = 1`）。
对开壳层体系，这个做法会失效。

O₂ 的基态是**三重态** ³Σg⁻，两条 π* 轨道各进入一个 ↑ 电子（Hund 规则）。
不把自旋分开求解，就无法到达这个态。

```bash
cd 06_qe-examples/o2/spin
./run-spin.sh
```

结构、赝势、截断能保持固定，只改变 `nspin`。

```
nspin = 1                           ↑ 与 ↓ 使用同一套势
nspin = 2                           ↑ 与 ↓ 使用各自的势
starting_magnetization(1) = 0.5     初始磁化（破缺对称性所必需）
```

### 已验证的参考值

**QE 7.5 / 6 MPI / 两个算例共 9 秒**（键长 1.21 Å，10 Å 立方晶胞，仅 Γ 点）

| | 总能量 (Ry) | total magnetization (μB/cell) |
|---|---|---|
| `nspin = 1` | `-82.97218672` | 0.00 |
| `nspin = 2` | **`-83.04565381`** | **2.00** |

```
E(nspin=2) - E(nspin=1) = -1.000 eV        ← 三重态低 1 eV
total magnetization     =  2.00 μB/cell    ← 多出 2 个 ↑ = 三重态
```

磁化**恰好等于 2.00** 这一点很重要。这并非巧合，它**就是**三重态：
两条 π* 轨道各有一个 ↑ 电子。

### 观察轨道劈裂

```bash
grep -A11 "SPIN UP"   o2.scf.nspin2.out | tail -8
grep -A11 "SPIN DOWN" o2.scf.nspin2.out | tail -8
grep -i   "Fermi"     o2.scf.nspin2.out | tail -1
```

Γ 点处的本征值 (eV)：

```
SPIN UP    -32.7708 -20.3546 -13.3518 -13.3464 -13.3464  -6.6492  -6.6492 | -0.3853 ...
SPIN DOWN  -31.5870 -18.5567 -12.4444 -11.4820 -11.4820  -4.3350  -4.3350 |  1.0807 ...
                                                           ↑↑
                                                π* 轨道。交换劈裂 2.314 eV

Fermi = -5.4846 eV      ← 位于 π*(↑) 的 -6.6492 与 π*(↓) 的 -4.3350 之间
```

同一条命令还会输出 `occupation numbers`，这是三重态最直接的证据：

```
SPIN UP     1 1 1 1 1 1 1 | 0 0 0      ← 占据 7 条
SPIN DOWN   1 1 1 1 1 0 0 | 0 0 0      ← 占据 5 条（两条 π* 为空）
```

12 个价电子分成 ↑ 7 个与 ↓ 5 个（7 − 5 = 2 = 磁化）。
费米能级落在 π*(↑) 与 π*(↓) 之间，因此 **π*(↑) 被占据、π*(↓) 为空**——
这正是三重态的电子组态。

**↑ 的每一条能级都比对应的 ↓ 更深**，因为 ↑ 是多数自旋，
受到同自旋电子之间交换作用的稳定化。这就是磁性的起源。

### 任务

1. 把 `starting_magnetization(1)` 设为 `0.0` 运行，观察会发生什么
   （对称性可能不破缺，从而落回与 `nspin = 1` 相同的解）
2. 把键长从 1.21 Å 改为 1.10 / 1.30 Å，考察三重态与单重态的能量差如何变化
3. 思考为何 `absolute magnetization`（2.05 μB）略大于
   `total magnetization`（2.00 μB）——两者定义不同
4. 对 N₂（闭壳层）做同样的计算，确认即便 `nspin = 2` 磁化仍为 0
   （赝势从 SSSP 获取，步骤见 [练习 07 的进阶部分](04_homo-lumo.md)）

### 自查清单

- [ ] 能说明 `nspin = 1` 与 `nspin = 2` 改变了什么
- [ ] 能用 Hund 规则说明 O₂ 基态为何是三重态
- [ ] 能说明为何需要 `starting_magnetization`（对称性破缺）
- [ ] 能用交换作用说明 ↑ 与 ↓ 本征值劈裂的原因
- [ ] 能说明处理磁性材料时忘记 `nspin = 2` 会发生什么

---

## 小结

| 节 | 体系 | `CAL` | 主要输出 | 实测耗时 |
|---|---|---|---|---|
| 3-1 | H₂O | `scf` | `*.scf.out` | 20 秒 |
| 3-2 | H₂O | `relax` | `*.relax.vasp` | 1 分钟 |
| 3-3 | H₂O | `wf` | `*.cube` | 1 分钟 |
| 3-4 | graphene | `scf` / `wf` | `*.scf.out`, `*.cube` | 2 秒 |
| 3-4 | graphite | `vc-relax` / `scf` | 优化后的晶胞 | 4 分 30 秒 / 9 秒 |
| 3-5 | silicon | `bands` | `*.band.gnu` → `bands.pdf` | 6 秒 |
| 3-6 | silicon | `dos` | `*.dos` → `dos.pdf` | 7 分 23 秒 |
| 3-7 | silicon | `proj` | `*.pdos_atm#*` → `projwfc.pdf` | 3 分 44 秒 |
| 3-8 | silicon | （phonopy） | `band.yaml`, `projected_dos.dat` | 8 分 36 秒 |
| 3-9 | silicon | `scf` × 7 | `kconv.dat` → `kconv.png` | 11 秒 |
| 3-10 | silicon | `vc-relax` × 2 | `xc.dat` | 19 秒 |
| 3-11 | O₂ | `scf` × 2 | `spin.dat` | 9 秒 |

耗时均为 **Apple Silicon / 6 MPI**（graphite 为 8 MPI）下的实测值。

### 是否自动生成 PDF

| 脚本 | 自动生成 PDF |
|---|---|
| `dos.plt` | ○ `dos.pdf` |
| `projwfc.plt` | ○ `projwfc.pdf` |
| `band.plt` | **×** 需取消末尾三行的注释 |

三者中途都有 `pause -1`，因此 **必须在终端按 Enter 才会退出**。

### 收敛测试的三大支柱（研究中必做）

1. **`ecutwfc` 收敛** — 找到总能量不再变化的截断能（→ 练习 05、3-1 任务 2）
2. **k 点收敛** — 加密网格直到总能量不再变化（→ **3-9**）
3. **真空层 / 晶胞尺寸收敛** — 在孤立体系和表面体系中切断周期像的影响（→ 练习 03）

> 三根支柱并不独立。正如 3-9 所示，改变 smearing 会移动 k 点序列收敛到的值本身。
> **「收敛到了什么」只有连同设置一起说才有意义。**

---

[← 02. 基函数](02_basis.md) | [目录](README.md) | [下一章：04. HOMO-LUMO →](04_homo-lumo.md)
