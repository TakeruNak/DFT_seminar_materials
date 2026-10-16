# 00. Environment setup

*English ・ [日本語](../ja/00_setup.md) ・ [简体中文](../zh/00_setup.md)*

[← Back to index](README.md) | [Next: 01. Self-consistent field →](01_scf.md)

First time only. Takes 1–2 hours (excluding build time).
**Target OS: macOS** (on Linux, read Homebrew as apt/dnf).

---

## 0-1. Checklist

Tick these off as you go.

- [ ] You can open Terminal
- [ ] Homebrew is installed
- [ ] You cloned the repository with Git
- [ ] You created a Python environment and can `import numpy`
- [ ] Quantum ESPRESSO (`pw.x`) runs
- [ ] Visualisation tools (VESTA / gnuplot) run

---

## 0-2. Opening a Terminal

The CLI (Command Line Interface) is the direct channel for giving commands to
the machine. Unlike a GUI it has no artificial limits, it is reproducible, and
it can be automated.

```
Command + Space  →  type "Terminal"  →  launch Terminal.app
```

Check that it works (one line = one command; press `return` to send it):

```bash
pwd                 # print the current directory
mkdir -p ~/workspace
cd ~/workspace
pwd
```

> A minimal command list is in [90_reference.md](90_reference.md#linux-command-cheat-sheet).

---

## 0-3. Homebrew

The package manager for macOS. Every tool below is installed through it.

```bash
# only if it is not installed yet
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# check
brew doctor
```

`Your system is ready to brew.` — or only warnings — means you are fine.

---

## 0-4. Installing the required tools

```bash
brew install git gnu-sed gnuplot open-babel
brew install --cask vesta
```

| Tool | Purpose | Used in |
|---|---|---|
| `git` | Getting and updating the repository | all chapters |
| `gnu-sed` (`gsed`) | Required by the band/DOS plotting scripts | 03 |
| `gnuplot` | Plotting bands / DOS / PDOS | 03 |
| `open-babel` (`obabel`) | Converting structure file formats (sdf → xyz/cif) | 03, 04 |
| `VESTA` | Visualising crystals, molecules and wavefunctions (cube) | 03, 04 |
| `avogadro` (optional) | Molecular modelling | 03 |

---

## 0-5. Getting the repository

```bash
cd ~/workspace
git clone https://github.com/TakeruNak/DFT_seminar_materials.git
cd DFT_seminar_materials
ls
```

To pull in updates later:

```bash
git pull
```

---

## 0-6. Python environment

You will use `numpy` / `scipy` / `matplotlib` and friends.
A venv is recommended (conda also works).

```bash
cd ~/workspace/DFT_seminar_materials

python3 -m venv .venv
source .venv/bin/activate          # run this every time you start an exercise
pip install --upgrade pip
pip install -r requirements.txt
```

Check:

```bash
python -c "import numpy, scipy, matplotlib; print('OK')"
```

> **You must run `source .venv/bin/activate` every time you open a new Terminal.**
> The prompt shows `(.venv)` when it is active.

<details>
<summary>Using conda instead</summary>

```bash
conda create -n dft-seminar python=3.12
conda activate dft-seminar
pip install -r requirements.txt
```
</details>

---

## 0-7. Quantum ESPRESSO

Required from chapter 03 onwards. There are two ways to install it.

### Option A: conda-forge (recommended, easiest)

```bash
conda create -n qe -c conda-forge qe
conda activate qe
which pw.x
```

### Option B: build from source

```bash
brew install open-mpi scalapack fftw gcc
cd ~/workspace
curl -L -O https://gitlab.com/QEF/q-e/-/archive/qe-7.5/q-e-qe-7.5.tar.gz
tar xf q-e-qe-7.5.tar.gz && cd q-e-qe-7.5
./configure
make all -j4          # roughly 30 min – 1 hour
```

### Telling the scripts where the binaries are

The `run-local.sh` scripts in this repository **look for `pw.x` on your `PATH`
by default**. Only if it is not on the `PATH` (e.g. you built from source) do
you need to set the `QE_BIN_DIR` environment variable.

```bash
# example 1) built from source
echo 'export QE_BIN_DIR=$HOME/workspace/q-e-qe-7.5/bin' >> ~/.zshrc
# example 2) all binaries symlinked into one bin directory
echo 'export QE_BIN_DIR=$HOME/opt/bin' >> ~/.zshrc

source ~/.zshrc
```

Check:

```bash
pw.x -h | head -3             # if it is on the PATH
ls $QE_BIN_DIR/pw.x           # if you use QE_BIN_DIR
mpirun --version
```

> If you see `pw.x が見つかりません` / `pw.x not found`, check `QE_BIN_DIR`.
> `run-local.sh` verifies that `pw.x` exists before running and stops
> immediately if it does not.

### MPI

`run-local.sh` uses `mpirun`. If it is missing, `brew install open-mpi`.
Keep `NUM_PROCS` in `system.in` **at or below the number of physical cores**
on your machine.

```bash
sysctl -n hw.physicalcpu      # number of physical cores
```

---

## 0-8. Editor configuration (optional)

`00_environment/` contains example vim and tmux configurations.

```bash
cp 00_environment/vim/.vimrc    ~/.vimrc
cp 00_environment/tmux/.tmux.conf ~/.tmux.conf
```

> These overwrite any existing configuration — be careful.

---

## 0-9. Final check

```bash
cd ~/workspace/DFT_seminar_materials
source .venv/bin/activate

python -c "import numpy, scipy, matplotlib; print('python OK')"
which gsed gnuplot obabel
which pw.x || echo "QE_BIN_DIR=$QE_BIN_DIR"
```

If all of these pass, your environment is ready.

---

[← Back to index](README.md) | [Next: 01. Self-consistent field →](01_scf.md)
