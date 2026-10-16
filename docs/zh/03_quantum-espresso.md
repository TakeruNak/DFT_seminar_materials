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

耗时均为 **Apple Silicon / 6 MPI**（graphite 为 8 MPI）下的实测值。

### 是否自动生成 PDF

| 脚本 | 自动生成 PDF |
|---|---|
| `dos.plt` | ○ `dos.pdf` |
| `projwfc.plt` | ○ `projwfc.pdf` |
| `band.plt` | **×** 需取消末尾三行的注释 |

三者中途都有 `pause -1`，因此 **必须在终端按 Enter 才会退出**。

### 收敛测试的三大支柱（研究中必做）

1. **`ecutwfc` 收敛** — 找到总能量不再变化的截断能（→ 练习 05）
2. **k 点收敛** — 加密网格直到总能量不再变化
3. **真空层 / 晶胞尺寸收敛** — 在孤立体系和表面体系中切断周期像的影响（→ 练习 03）

---

[← 02. 基函数](02_basis.md) | [目录](README.md) | [下一章：04. HOMO-LUMO →](04_homo-lumo.md)
