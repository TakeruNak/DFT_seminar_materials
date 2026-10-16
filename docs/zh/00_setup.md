# 00. 环境搭建

*[English](../en/00_setup.md) ・ [日本語](../ja/00_setup.md) ・ 简体中文*

[← 返回目录](README.md) | [下一章：01. 自洽场 →](01_scf.md)

仅首次需要执行。约 1–2 小时（不含编译时间）。
**目标操作系统：macOS**（Linux 用户请将 Homebrew 替换为 apt/dnf）。

---

## 0-1. 检查清单

逐项完成并打勾。

- [ ] 能打开终端
- [ ] 已安装 Homebrew
- [ ] 已用 Git 克隆仓库
- [ ] 已创建 Python 环境，可以 `import numpy`
- [ ] Quantum ESPRESSO (`pw.x`) 能运行
- [ ] 可视化工具（VESTA / gnuplot）能运行

---

## 0-2. 打开终端

CLI（命令行界面）是向机器直接下达指令的窗口。
与 GUI 相比，它"没有功能上的限制""可复现""可自动化"。

```
Command + Space  →  输入 "Terminal"  →  启动 Terminal.app
```

确认可用（一行 = 一条命令，输入后按 `return`）：

```bash
pwd                 # 显示当前目录
mkdir -p ~/workspace
cd ~/workspace
pwd
```

> 最基本的命令汇总见 [90_reference.md](90_reference.md#linux-命令速查表)。

---

## 0-3. Homebrew

macOS 的软件包管理工具。后续所有工具都通过它安装。

```bash
# 仅在未安装时执行
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 确认
brew doctor
```

显示 `Your system is ready to brew.` 或仅有警告即可。

---

## 0-4. 安装所需工具

```bash
brew install git gnu-sed gnuplot open-babel
brew install --cask vesta
```

| 工具 | 用途 | 使用章节 |
|---|---|---|
| `git` | 获取与更新仓库 | 全部章节 |
| `gnu-sed` (`gsed`) | 能带/DOS 绘图脚本依赖它 | 03 |
| `gnuplot` | 绘制能带 / DOS / PDOS | 03 |
| `open-babel` (`obabel`) | 结构文件格式转换 (sdf → xyz/cif) | 03, 04 |
| `VESTA` | 晶体・分子结构与波函数 (cube) 的可视化 | 03, 04 |
| `avogadro`（可选） | 分子结构建模 | 03 |

---

## 0-5. 获取仓库

```bash
cd ~/workspace
git clone https://github.com/TakeruNak/DFT_seminar_materials.git
cd DFT_seminar_materials
ls
```

之后拉取更新：

```bash
git pull
```

---

## 0-6. Python 环境

会用到 `numpy` / `scipy` / `matplotlib` 等。
推荐使用 venv（conda 亦可）。

```bash
cd ~/workspace/DFT_seminar_materials

python3 -m venv .venv
source .venv/bin/activate          # 之后每次做练习都要执行这一行
pip install --upgrade pip
pip install -r requirements.txt
```

确认：

```bash
python -c "import numpy, scipy, matplotlib; print('OK')"
```

> **每次重新打开终端都需要执行 `source .venv/bin/activate`。**
> 提示符开头出现 `(.venv)` 即表示已生效。

<details>
<summary>使用 conda 的情况</summary>

```bash
conda create -n dft-seminar python=3.12
conda activate dft-seminar
pip install -r requirements.txt
```
</details>

---

## 0-7. Quantum ESPRESSO

从第 03 章开始必需。有两种安装方式。

### 方式 A：conda-forge（推荐，最简单）

```bash
conda create -n qe -c conda-forge qe
conda activate qe
which pw.x
```

### 方式 B：从源码编译

```bash
brew install open-mpi scalapack fftw gcc
cd ~/workspace
curl -L -O https://gitlab.com/QEF/q-e/-/archive/qe-7.5/q-e-qe-7.5.tar.gz
tar xf q-e-qe-7.5.tar.gz && cd q-e-qe-7.5
./configure
make all -j4          # 约 30 分钟至 1 小时
```

### 设置可执行文件路径

本仓库的 `run-local.sh` **默认在 `PATH` 中查找 `pw.x`**。
只有当它不在 `PATH` 中（例如自行编译）时，才需要设置环境变量 `QE_BIN_DIR`。

```bash
# 例1) 从源码编译的情况
echo 'export QE_BIN_DIR=$HOME/workspace/q-e-qe-7.5/bin' >> ~/.zshrc
# 例2) 把 bin 统一软链接到一个目录的情况
echo 'export QE_BIN_DIR=$HOME/opt/bin' >> ~/.zshrc

source ~/.zshrc
```

确认：

```bash
pw.x -h | head -3             # 在 PATH 中时
ls $QE_BIN_DIR/pw.x           # 使用 QE_BIN_DIR 时
mpirun --version
```

> 如果提示找不到 `pw.x`，请检查 `QE_BIN_DIR` 的设置。
> `run-local.sh` 在运行前会检查 `pw.x` 是否存在，不存在则立即停止。

### MPI

`run-local.sh` 使用 `mpirun`。没有的话执行 `brew install open-mpi`。
`system.in` 中的 `NUM_PROCS` 请 **不要超过本机的物理核心数**。

```bash
sysctl -n hw.physicalcpu      # 查看物理核心数
```

---

## 0-8. 编辑器配置（可选）

`00_environment/` 中有 vim 和 tmux 的配置示例。

```bash
cp 00_environment/vim/.vimrc    ~/.vimrc
cp 00_environment/tmux/.tmux.conf ~/.tmux.conf
```

> 若已有配置会被覆盖，请注意。

---

## 0-9. 最终确认

```bash
cd ~/workspace/DFT_seminar_materials
source .venv/bin/activate

python -c "import numpy, scipy, matplotlib; print('python OK')"
which gsed gnuplot obabel
which pw.x || echo "QE_BIN_DIR=$QE_BIN_DIR"
```

全部通过即表示环境搭建完成。

---

[← 返回目录](README.md) | [下一章：01. 自洽场 →](01_scf.md)
