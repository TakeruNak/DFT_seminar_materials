# 附录：速查表・外部工具・故障排查

*[English](../en/90_reference.md) ・ [日本語](../ja/90_reference.md) ・ 简体中文*

[← 05. 紧束缚模型](05_tight-binding.md) | [目录](README.md)

---

## Linux 命令速查表

| 目的 | 命令 |
|---|---|
| 当前位置 | `pwd` |
| 列出文件 | `ls` / `ls -la`（含隐藏文件） |
| 切换目录 | `cd <dir>` / `cd ..`（上一级） / `cd ~`（主目录） |
| 创建目录 | `mkdir -p <dir>` |
| 复制 / 移动 | `cp <src> <dst>` / `mv <src> <dst>` |
| 删除 | `rm <file>` / `rm -r <dir>`（**无法撤销**） |
| 查看内容 | `cat <file>` / `less <file>`（`q` 退出） |
| 开头 / 结尾 | `head -20 <file>` / `tail -20 <file>` |
| 搜索 | `grep '!' *.out` / `grep -A5 'KEY' <file>`（同时显示后 5 行） |
| 查看运行中的进程 | `top` / `ps aux \| grep pw.x` |
| 强制终止 | `Ctrl + C` |
| 历史记录 | `history` / `↑` 键 |
| 自动补全 | `Tab` 键 |

---

## Git 速查表

| 目的 | 命令 |
|---|---|
| 克隆 | `git clone <url>` |
| 拉取更新 | `git pull` |
| 查看状态 | `git status` |
| 查看差异 | `git diff` |
| 丢弃修改 | `git restore <file>` |
| 新建分支 | `git switch -c <branch>` |

> **自己修改的练习文件不需要提交。**
> 如果 `git pull` 发生冲突，先用 `git restore <file>` 还原再拉取。

---

## Quantum ESPRESSO 速查表

### 从输出中提取数值

```bash
grep '!'                      *.out   # 收敛的总能量
grep 'estimated scf accuracy' *.out   # SCF 残差的变化
grep 'Total force'            *.out   # 残余力
grep -i 'Fermi'               *.out   # 费米能级
grep 'number of k points'     *.out   # k 点数
grep -A6 'End of self-consistent calculation' *.out  # 本征值 (eV)
grep -A5 'ATOMIC_POSITIONS'   *.out   # 结构（relax 类）
grep 'PWSCF.*WALL'            *.out   # 计算耗时
grep -c 'JOB DONE'            *.out   # 是否正常结束（为 1 即 OK）
grep -i 'error'               *.out   # 错误
```

> 本仓库的例题全部使用 `occupations = 'smearing'`，因此 HOMO/LUMO 要从
> `the Fermi energy is ...` 和本征值列表来判断。
> `highest occupied level` 只在 `occupations = 'fixed'` 时才出现。

### 主要参数

| 参数 | 所属段 | 含义 |
|---|---|---|
| `calculation` | `&CONTROL` | `scf` / `nscf` / `bands` / `relax` / `vc-relax` |
| `prefix` | `&CONTROL` | 工作文件的名称 |
| `outdir` | `&CONTROL` | 工作目录（通常为 `./out/`） |
| `pseudo_dir` | `&CONTROL` | 赝势所在位置 |
| `ecutwfc` | `&SYSTEM` | 波函数的截断能 (Ry) |
| `ecutrho` | `&SYSTEM` | 电荷密度的截断能 (Ry) |
| `nbnd` | `&SYSTEM` | 要计算的能带数 |
| `occupations` | `&SYSTEM` | `smearing` / `fixed` / `tetrahedra` |
| `degauss` | `&SYSTEM` | 展宽宽度 (Ry) |
| `nspin` | `&SYSTEM` | 设为 2 开启自旋极化 |
| `conv_thr` | `&ELECTRONS` | SCF 收敛判据 |
| `mixing_beta` | `&ELECTRONS` | 密度混合系数（练习 01 的 `alpha`） |
| `electron_maxstep` | `&ELECTRONS` | SCF 最大迭代次数 |

官方文档：https://www.quantum-espresso.org/Doc/INPUT_PW.html

### 单位

| 物理量 | QE 的默认单位 |
|---|---|
| 能量（输入中的截断能） | Ry |
| 能量（输出中的本征值） | eV |
| 总能量 | Ry |
| 长度 | bohr，或用 `CELL_PARAMETERS angstrom` 时为 Å |

1 Ry = 13.6057 eV，1 bohr = 0.529177 Å

---

## 外部工具

### 结构数据库

| 网站 | 对象 |
|---|---|
| [PubChem](https://pubchem.ncbi.nlm.nih.gov/) | 分子 |
| [ChemSpider](https://www.chemspider.com/) | 分子 |
| [Materials Project](https://next-gen.materialsproject.org/) | 体相晶体 |
| [COD](https://www.crystallography.net/cod/) | 晶体结构（开放） |
| [OQMD](https://oqmd.org/) | 体相晶体 |

### 网页工具

| 网站 | 用途 |
|---|---|
| [QE input generator](https://qeinputgenerator.materialscloud.io/) | 用图形界面生成 PWscf 输入文件 |
| [SeeK-path](https://www.materialscloud.org/work/tools/seekpath) | 自动推荐能带路径 |
| [SSSP](https://www.materialscloud.org/discover/sssp/) | 推荐的赝势与推荐截断能 |

### 赝势库

| 库 | 特点 |
|---|---|
| [SSSP](https://www.materialscloud.org/discover/sssp/) | 针对 QE 验证过。**默认使用这个** |
| [PS-library](https://www.quantum-espresso.org/pseudopotentials/) | QE 官方 |
| [PseudoDojo](http://www.pseudo-dojo.org/) | 含相对论修正，提供多种 LDA/GGA |

> **绝对不要混用 LDA 和 GGA 的赝势。**
> 同一个计算中必须统一使用同一泛函系列。

### 本地工具

| 工具 | 用途 | 安装 |
|---|---|---|
| VESTA | 晶体・分子・cube 的可视化 | `brew install --cask vesta` |
| Avogadro | 分子建模 | `brew install avogadro` |
| OpenBabel | 结构文件转换 | `brew install open-babel` |
| gnuplot | 绘制能带 / DOS | `brew install gnuplot` |
| GNU sed | 绘图整理脚本依赖它 | `brew install gnu-sed` |
| phonopy | 声子计算（3-8） | `pip install "phonopy<4"` |

```bash
obabel input.sdf -O output.xyz --gen3d     # sdf → xyz
obabel input.sdf -O output.cif --gen3d     # sdf → cif
open -a VESTA output.xyz
```

---

## 故障排查

### 环境相关

| 症状 | 处理方法 |
|---|---|
| 提示找不到 `pw.x` | 确认 `which pw.x`；没有则 `export QE_BIN_DIR=<QE 的 bin 目录>` |
| `command not found: gsed` | `brew install gnu-sed` |
| `command not found: gnuplot` | `brew install gnuplot` |
| `ModuleNotFoundError: numpy` | 确认是否忘记执行 `source .venv/bin/activate` |
| `ModuleNotFoundError: pythtb` | `pip install pythtb pymatgen` |
| 无法 import `TBModel` | 需要 pythtb 2.0 以上（`pip install -U pythtb`） |
| matplotlib 窗口不出现 | 用 `plt.savefig()` 代替 `plt.show()` |
| `'-d' is a setup operation that moved to 'phonopy-init' in v4` | 装的是 phonopy 4。改用 `pip install "phonopy<4"` |
| gnuplot 一直不退出 | 这是 `.plt` 中 `pause -1` 的行为。在终端按 Enter |

### QE 运行错误

| 症状 | 原因与处理 |
|---|---|
| `ERROR: Please put system.in in this directory` | 会生成 `system.in_tmp`，重命名为 `system.in` 后编辑 |
| `file ... .UPF not found` | 确认 `pseudo_dir` 的设置与实际 `pseudo/` 的位置是否一致 |
| `convergence NOT achieved` | 降低 `mixing_beta`（0.4 → 0.2 → 0.1）／增大 `electron_maxstep` ／稍微增大 `degauss` |
| `Not enough space allocated for radial FFT` | 提高 `ecutrho` |
| 内存不足 / 异常终止 | 减小 `NUM_PROCS` ／降低 `ecutwfc` 和 k 点先用小体系测试 |
| 没有 `mpirun` | `brew install open-mpi`，或改用 conda 版的 QE |
| 第二次运行结果异常 | `rm -rf out/` 后重新开始 |
| `fatal error reading xml file`（pp.x / projwfc.x） | 没有先跑 SCF。`out/` 为空时请从 `CAL scf` 开始 |
| `file ... .UPF not found` 且显示别人的绝对路径 | 输入文件的 `pseudo_dir` 仍指向他人环境。改为 `'./pseudo/'` 等 |
| `Minimization algorithm failed to find Fermi energy` | 这是警告而非错误（只是切换到了二分法） |

### SCF 不收敛时的常规做法

1. 降低 `mixing_beta`（0.4 → 0.1）
2. 增大 `electron_maxstep`（80 → 200）
3. 稍微增大 `degauss`（金属体系）
4. 尝试 `mixing_mode = 'local-TF'`（不均匀体系）
5. 先用粗糙设置（低截断能、稀疏 k 点）收敛，再以该密度为出发点

→ 与 [01. 自洽场](01_scf.md) 中改变 `alpha` 时看到的是同一现象。

---

## 绝对不能提交的文件

虽然已加入 `.gitignore`，仍需注意。

| 对象 | 原因 |
|---|---|
| `99_slides/` | 讲义幻灯片原件。**不要 push 到远端** |
| `out/` | 计算的工作目录，体积巨大 |
| `*.cube` | 波函数输出，数十 MB |
| `.answear` | 参考答案 |

```bash
git status            # 提交前务必确认
```

---

## 参考文献

- P. Hohenberg, W. Kohn, *Phys. Rev.* **136**, B864 (1964) — Hohenberg-Kohn 定理
- W. Kohn, L. J. Sham, *Phys. Rev.* **140**, A1133 (1965) — Kohn-Sham 方程
- J. P. Perdew, K. Burke, M. Ernzerhof, *Phys. Rev. Lett.* **77**, 3865 (1996) — PBE
- R. M. Martin, *Electronic Structure: Basic Theory and Practical Methods*
- P. Taylor, O. Heinonen, *Condensed Matter Physics*
- Y. Hinuma et al., *Comput. Mater. Sci.* **128**, 140 (2017) — 能带路径的规范
- [Quantum ESPRESSO 官方文档](https://www.quantum-espresso.org/documentation/)
- [phonopy with QE](https://phonopy.github.io/phonopy/qe.html)

---

[← 05. 紧束缚模型](05_tight-binding.md) | [目录](README.md)
