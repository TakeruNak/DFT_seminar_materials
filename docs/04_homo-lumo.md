# 04. HOMO-LUMO 解析（F₂ 分子）

[← 03. Quantum ESPRESSO](03_quantum-espresso.md) | [目次](../README.md) | [次へ：05. Tight-binding →](05_tight-binding.md)

**ねらい**：構造最適化 → SCF → 波動関数出力の一連の流れを自分で通し、
Kohn-Sham 軌道のエネルギー準位と空間分布から **HOMO / LUMO** を同定する。

**ディレクトリ**: [`07_homo-lumo/F2/`](../07_homo-lumo/F2/)

F₂ 分子は σ/σ*, π/π* が明快に現れるため、分子軌道論との対応を見るのに適している。

---

## 4-1. 構造最適化

**ディレクトリ**: [`07_homo-lumo/F2/relax/`](../07_homo-lumo/F2/relax/)

```bash
cd 07_homo-lumo/F2/relax
cat system.in            # NAME F2 / CAL relax
./run-local.sh
```

### 結果の確認

```bash
grep -A5 'ATOMIC_POSITIONS' F2.relax.out | tail -10   # 最終構造
grep 'Total force' F2.relax.out                       # 力の収束
grep '!' F2.relax.out                                 # 全エネルギー
```

最適化構造は `F2.relax.vasp`。可視化は `open -a VESTA F2.relax.vasp`。

**課題**: 最適化後の F–F 結合長を求め、実験値（1.412 Å）と比較する。

---

## 4-2. SCF と固有値の取得

**ディレクトリ**: [`07_homo-lumo/F2/wf/`](../07_homo-lumo/F2/wf/)

最適化構造（`F2.relax.vasp`）を使った `F2.scf.in` が用意されている。

```bash
cd ../wf
cat system.in            # NAME F2 / CAL wf → scf の後に pp.x が走る
./run-local.sh
```

### Kohn-Sham 固有値を読む

```bash
grep -A10 'End of self-consistent calculation' F2.scf.out
grep 'Fermi' F2.scf.out
```

出力される固有値（eV）の列が、各 Kohn-Sham 軌道のエネルギー。
Fermi 準位より下が **占有**、上が **非占有**。

```
     ... 占有 ...        E_F        ... 非占有 ...
   ─────────────────────┬───────────────────────
            HOMO ───────┤─────── LUMO
```

---

## 4-3. エネルギー準位図

`wf_png/wf_energy.py` が準位図を描くスクリプト。

```bash
cd wf_png
source ../../../../.venv/bin/activate
python wf_energy.py
```

**自分の計算結果を反映させる**:

```python
# wf_energy.py の冒頭を、4-2 で読み取った値に書き換える
eigenvalues = [-9.1977, -7.1040, -0.9529, 0.4271]   # ← 固有値 (eV)
fermi_energy = -4.1157                              # ← Fermi 準位 (eV)
```

既存の `wf_png/wf_energy.png` と見比べること。

---

## 4-4. 軌道の可視化

`F2.wf.in` の `kband` を変えて、各軌道を cube 出力する。

```
&inputpp
    plot_num = 7
    kpoint   = 1
    kband    = 2        ← ★ ここを変える
    lsign    = .true.
/
&plot
    iflag         = 3
    output_format = 6
    fileout       = 'F2_G2.cube'    ← ★ 同時に変える
/
```

```bash
cd 07_homo-lumo/F2/wf

# kband と fileout を書き換えてから
./run-local.sh
open -a VESTA F2_G2.cube
```

`wf_png/` に G3〜G8 の出力例がある。

### 課題

1. F₂ の価電子数を数え、HOMO が何番目のバンドかを求める
2. `kband` を HOMO-2 〜 LUMO+1 まで変えて cube を出力し、VESTA で形を見る
3. 各軌道が σ, σ*, π, π* のどれかを判定し、分子軌道ダイアグラムと対応づける
4. `lsign = .false.` にすると出力がどう変わるか確認する

---

## 4-5. 確認事項

- [ ] Kohn-Sham 固有値から HOMO / LUMO を特定できる
- [ ] 軌道の空間分布から結合性 (σ, π) / 反結合性 (σ*, π*) を判別できる
- [ ] 「KS 固有値 = 実際のイオン化ポテンシャル」ではない理由を説明できる
      （厳密に対応するのは HOMO のみ / Janak の定理, Koopmans の定理との違い）
- [ ] cube ファイルが巨大なので commit してはいけない理由を理解している

---

## 発展

同じ手順を他の二原子分子（N₂, O₂, CO）に適用する。

1. [PubChem](https://pubchem.ncbi.nlm.nih.gov/) から SDF をダウンロード
2. `obabel input.sdf -O output.xyz --gen3d` で変換
3. VESTA で開いて POSCAR 形式でエクスポート
4. [QE input generator](https://qeinputgenerator.materialscloud.io/) で input を生成
5. 擬ポテンシャルを [SSSP](https://www.materialscloud.org/discover/sssp/) から取得して `pseudo/` へ
6. `system.in` を用意して `./run-local.sh`

> O₂ は基底状態が三重項なので `nspin = 2` の設定が必要。なぜかを考えること。

---

[← 03. Quantum ESPRESSO](03_quantum-espresso.md) | [目次](../README.md) | [次へ：05. Tight-binding →](05_tight-binding.md)
