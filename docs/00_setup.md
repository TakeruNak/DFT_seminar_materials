# 00. 環境構築

[← 目次に戻る](../README.md) | [次へ：01. 自己無撞着場 →](01_scf.md)

初回のみ実施。所要 1〜2 時間（ビルド時間を除く）。
**対象 OS: macOS**（Linux の場合は Homebrew → apt/dnf に読み替え）

---

## 0-1. チェックリスト

完了したものに ✅ を付けながら進める。

- [ ] Terminal が開ける
- [ ] Homebrew が入っている
- [ ] Git でリポジトリを clone した
- [ ] Python 環境を作り `numpy` が import できる
- [ ] Quantum ESPRESSO (`pw.x`) が動く
- [ ] 可視化ツール（VESTA / gnuplot）が動く

---

## 0-2. Terminal を開く

CLI (Command Line Interface) は、マシンに直接命令を送るための窓口。
GUI と違い「できることに制限がない」「再現できる」「自動化できる」。

```
Command + Space  →  "Terminal" と入力  →  Terminal.app を起動
```

動作確認（1 行 = 1 命令。入力後に `return`）:

```bash
pwd                 # 現在地を表示
mkdir -p ~/workspace
cd ~/workspace
pwd
```

> 最低限のコマンドは [90_reference.md](90_reference.md#linux-コマンド早見表) にまとめてある。

---

## 0-3. Homebrew

macOS 用のパッケージ管理ソフト。以降のツールは全てこれで入れる。

```bash
# 未インストールの場合のみ
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 動作確認
brew doctor
```

`Your system is ready to brew.` もしくは警告のみなら問題ない。

---

## 0-4. 必要なツールの導入

```bash
brew install git gnu-sed gnuplot open-babel
brew install --cask vesta
```

| ツール | 用途 | 使う章 |
|---|---|---|
| `git` | リポジトリの取得・更新 | 全章 |
| `gnu-sed` (`gsed`) | band/DOS プロット用スクリプトが依存 | 03 |
| `gnuplot` | band / DOS / PDOS の描画 | 03 |
| `open-babel` (`obabel`) | 構造ファイルの形式変換 (sdf → xyz/cif) | 03, 04 |
| `VESTA` | 結晶・分子構造と波動関数(cube)の可視化 | 03, 04 |
| `avogadro`（任意） | 分子構造のモデリング | 03 |

---

## 0-5. リポジトリの取得

```bash
cd ~/workspace
git clone https://github.com/TakeruNak/DFT_seminar_materials.git
cd DFT_seminar_materials
ls
```

更新を取り込むとき:

```bash
git pull
```

---

## 0-6. Python 環境

`numpy` / `scipy` / `matplotlib` などを使う。
venv を推奨（conda でも可）。

```bash
cd ~/workspace/DFT_seminar_materials

python3 -m venv .venv
source .venv/bin/activate          # 以降、演習のたびにこれを実行する
pip install --upgrade pip
pip install -r requirements.txt
```

動作確認:

```bash
python -c "import numpy, scipy, matplotlib; print('OK')"
```

> **Terminal を開き直すたびに `source .venv/bin/activate` が必要。**
> プロンプト先頭に `(.venv)` が出ていれば有効。

<details>
<summary>conda を使う場合</summary>

```bash
conda create -n dft-seminar python=3.12
conda activate dft-seminar
pip install -r requirements.txt
```
</details>

---

## 0-7. Quantum ESPRESSO

演習 03 以降で必須。方法は 2 つ。

### 方法 A: conda-forge（推奨・最も簡単）

```bash
conda create -n qe -c conda-forge qe
conda activate qe
which pw.x
```

### 方法 B: ソースからビルド

```bash
brew install open-mpi scalapack fftw gcc
cd ~/workspace
curl -L -O https://gitlab.com/QEF/q-e/-/archive/qe-7.5/q-e-qe-7.5.tar.gz
tar xf q-e-qe-7.5.tar.gz && cd q-e-qe-7.5
./configure
make all -j4          # 30分〜1時間程度
```

### 実行パスの設定

本リポジトリの `run-local.sh` は **既定で PATH 上の `pw.x` を探す**。
ビルドした場合など PATH に無いときだけ、環境変数を設定する。

```bash
# 例: ソースビルドした場合
echo 'export QE_BIN_DIR=$HOME/workspace/q-e-qe-7.5/bin' >> ~/.zshrc
source ~/.zshrc
```

動作確認:

```bash
which pw.x                    # または
ls $QE_BIN_DIR/pw.x
mpirun --version
```

> `pw.x が見つかりません` と出たら、`QE_BIN_DIR` の設定を確認する。

---

## 0-8. エディタ設定（任意）

`00_environment/` に vim と tmux の設定例がある。

```bash
cp 00_environment/vim/.vimrc    ~/.vimrc
cp 00_environment/tmux/.tmux.conf ~/.tmux.conf
```

> 既存の設定がある場合は上書きされるので注意。

---

## 0-9. 最終確認

```bash
cd ~/workspace/DFT_seminar_materials
source .venv/bin/activate

python -c "import numpy, scipy, matplotlib; print('python OK')"
which gsed gnuplot obabel
which pw.x || echo "QE_BIN_DIR=$QE_BIN_DIR"
```

全て通れば環境構築は完了。

---

[← 目次に戻る](../README.md) | [次へ：01. 自己無撞着場 →](01_scf.md)
