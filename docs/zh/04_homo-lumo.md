# 04. HOMO-LUMO 分析（F₂ 分子）

*[English](../en/04_homo-lumo.md) ・ [日本語](../ja/04_homo-lumo.md) ・ 简体中文*

[← 03. Quantum ESPRESSO](03_quantum-espresso.md) | [目录](README.md) | [下一章：05. 紧束缚模型 →](05_tight-binding.md)

**目标**：亲手完整走一遍 结构优化 → SCF → 波函数输出 的流程，
并从 Kohn-Sham 轨道的能级与空间分布确定 **HOMO / LUMO**。

**目录**：[`07_homo-lumo/F2/`](../../07_homo-lumo/F2/)

F₂ 分子的 σ/σ*、π/π* 表现得非常清晰，适合用来对照分子轨道理论。

---

## 4-1. 结构优化

**目录**：[`07_homo-lumo/F2/relax/`](../../07_homo-lumo/F2/relax/)

```bash
cd 07_homo-lumo/F2/relax
cat system.in            # NAME F2 / CAL relax
./run-local.sh
```

### 查看结果

```bash
grep -A5 'ATOMIC_POSITIONS' F2.relax.out | tail -10   # 最终结构
grep 'Total force' F2.relax.out                       # 力的收敛
grep '!' F2.relax.out                                 # 总能量
```

优化后的结构为 `F2.relax.vasp`，用 `open -a VESTA F2.relax.vasp` 查看。

**已验证的参考值**（QE 7.5 / 6 MPI / 耗时 42 秒）

| 项目 | 数值 | 实验值 |
|---|---|---|
| 总能量 | `-96.91814727 Ry` | — |
| 最终坐标 (crystal) | F: (0.5, 0.5, 0.4290) / (0.5, 0.5, 0.5710) | — |
| **F–F 键长** | **1.419 Å** | 1.412 Å |
| 最终 Total force | `0.000001` | — |

**任务**：求优化后的 F–F 键长并与实验值（1.412 Å）比较。
晶胞是 10 Å 的立方体，因此把 z 坐标之差乘以 10 即为 Å。

---

## 4-2. SCF 与本征值的获取

**目录**：[`07_homo-lumo/F2/wf/`](../../07_homo-lumo/F2/wf/)

已准备好使用优化结构（`F2.relax.vasp`）的 `F2.scf.in`。

```bash
cd ../wf
cat system.in            # NAME F2 / CAL wf → scf 之后运行 pp.x
./run-local.sh
```

### 读取 Kohn-Sham 本征值

```bash
grep -A10 'End of self-consistent calculation' F2.scf.out
grep 'Fermi' F2.scf.out
```

输出的本征值（eV）即各 Kohn-Sham 轨道的能量。
费米能级以下为 **占据态**，以上为 **非占据态**。

**已验证的参考值**（6 MPI / SCF + pp.x 共 18 秒）

```
bands (ev):
  -33.7916 -27.5716 -15.1798 -12.6376 -12.6376
   -9.3160  -9.3160  -5.7980  -0.4147   0.9986   1.0973

the Fermi energy is  -7.3731 ev
```

请注意 `-12.6376` 和 `-9.3160` 是二重简并（π / π*）。

```
     ... 占据 ...        E_F        ... 非占据 ...
   ─────────────────────┬───────────────────────
            HOMO ───────┤─────── LUMO
```

---

## 4-3. 能级图

`wf_png/wf_energy.py` 用于绘制能级图。

```bash
cd wf_png
source ../../../../.venv/bin/activate
python wf_energy.py
```

脚本开头直接写有 F₂ 的本征值。
请替换为你在 4-2 中读取的数值后重新运行。

```python
eigenvalues = [-15.1798, -12.6376, -12.6376, -9.3160, -9.3160, -5.7980, -0.4147]
fermi_energy = -7.3731
```

> 这些默认值与 4-2 的实测值一致（简并会被自动识别并标注
> `(Degenerate)`）。建议 **先直接运行** 确认能出图，再换成自己的计算结果。

请与已有的 `wf_png/wf_energy.png` 对照。

---

## 4-4. 轨道的可视化

修改 `F2.wf.in` 中的 `kband`，把各轨道输出为 cube。

```
&inputpp
    plot_num = 7
    kpoint   = 1
    kband    = 2        ← ★ 修改这里
    lsign    = .true.
/
&plot
    iflag         = 3
    output_format = 6
    fileout       = 'F2_G2.cube'    ← ★ 同时修改
/
```

```bash
cd 07_homo-lumo/F2/wf

# 修改 kband 和 fileout 之后
./run-local.sh
open -a VESTA F2_G2.cube
```

默认为 `kband = 2` / `fileout = 'F2_G2.cube'`（约 23 MB）。
`wf_png/` 中有 G3–G8 的输出示例。

> `CAL wf` 每次都会重新做 SCF（约 18 秒）。如果只想改变 `kband` 反复尝试，
> 在 `out/` 还存在的状态下直接调用 `pp.x` 更快。
>
> ```bash
> mpirun -np 6 $QE_BIN_DIR/pp.x -inp F2.wf.in > F2.wf.out
> ```

### 任务

1. 数出 F₂ 的价电子数，求出 HOMO 是第几条能带
2. 把 `kband` 从 HOMO-2 变到 LUMO+1，输出 cube 并在 VESTA 中观察形状
3. 判断各轨道属于 σ, σ*, π, π* 中的哪一个，并与分子轨道能级图对应
4. 设 `lsign = .false.`，确认输出有何变化

---

## 4-5. 自查清单

- [ ] 能从 Kohn-Sham 本征值确定 HOMO / LUMO
- [ ] 能从轨道的空间分布判别成键 (σ, π) / 反键 (σ*, π*)
- [ ] 能说明为什么"KS 本征值 = 实际的电离能"并不成立
      （严格对应的只有 HOMO；比较 Janak 定理与 Koopmans 定理）
- [ ] 理解为什么 cube 文件不能提交到仓库

---

## 拓展

把同样的流程应用到其他双原子分子（N₂, O₂, CO）。

1. 从 [PubChem](https://pubchem.ncbi.nlm.nih.gov/) 下载 SDF
2. 用 `obabel input.sdf -O output.xyz --gen3d` 转换
3. 用 VESTA 打开并导出为 POSCAR 格式
4. 用 [QE input generator](https://qeinputgenerator.materialscloud.io/) 生成输入文件
5. 从 [SSSP](https://www.materialscloud.org/discover/sssp/) 获取赝势放入 `pseudo/`
6. 准备 `system.in` 后执行 `./run-local.sh`

> O₂ 的基态是三重态，需要设置 `nspin = 2`。请思考为什么。

---

[← 03. Quantum ESPRESSO](03_quantum-espresso.md) | [目录](README.md) | [下一章：05. 紧束缚模型 →](05_tight-binding.md)
