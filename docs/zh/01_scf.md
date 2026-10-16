# 01. 自洽场（SCF）

*[English](../en/01_scf.md) ・ [日本語](../ja/01_scf.md) ・ 简体中文*

[← 00. 环境搭建](00_setup.md) | [目录](README.md) | [下一章：02. 基函数 →](02_basis.md)

**目标**：通过双格点最小模型，亲身体会 Kohn-Sham 方程具有"求解需要解本身"
的循环结构，以及如何用迭代（SCF 循环）加混合（mixing）来解决它。

```
         ┌──────────────────────────────────────────┐
         ↓                                          │
  n(r) → v_eff[n] → 求解 KS 方程 → φᵢ → n'(r) ───────┘
                                      │
                         |n' - n| < tol 时判定收敛
```

---

## 练习 01：双格点紧束缚模型的自洽

**目录**：[`01_2-site-convergence/`](../../01_2-site-convergence/)

### 模型

模拟双原子分子的双格点模型。格点能（on-site energy）依赖于该格点自身的电子密度。

```
H = | U·n₁   -t   |      εᵢ = U·nᵢ  (格点能)
    |  -t   U·n₂  |      t         (跃迁积分 hopping)
```

由基态本征矢 ψ 更新密度 → 重新构造 H，如此反复。

### 运行

```bash
cd 01_2-site-convergence
source ../.venv/bin/activate
python 2-site-convergence.py
```

### 输出

| 文件 | 内容 |
|---|---|
| `density.png` | 各格点密度 n₁, n₂ 随迭代的变化 |
| `energy.png` | 基态能量随迭代的变化 |
| `residual.png` | 残差 \|Δn\|（对数坐标） |

标准输出中出现 `Converged at iteration N` 即表示收敛。

### 可调参数

修改脚本开头后重新运行。

| 变量 | 默认值 | 含义 | 建议尝试 |
|---|---|---|---|
| `U` | 2.0 | 格点相互作用强度 | 增大后更容易发散・振荡 |
| `t` | 2.0 | 跃迁积分 | |
| `alpha` | 0.1 | **混合系数** | 越接近 1.0 收敛越快，但越容易发散 |
| `tol` | 1e-6 | 收敛判据 | |
| `n1, n2` | 3.0, 2.0 | 初始密度（非对称） | 改为对称会发生什么？ |

### 任务

1. 设 `alpha = 1.0`（无混合）运行，观察 `residual.png` 的变化
2. 取 `alpha` = 0.05 / 0.1 / 0.5 / 1.0，记录收敛所需的迭代次数
3. 把 `U` 从 2.0 提高到 10.0，能收敛的 `alpha` 范围如何变化？

### 自查清单

- [ ] 能说明为什么不能只算一次，而必须迭代
- [ ] 能说明混合参数（mixing parameter）的作用
- [ ] 能说明残差图为什么用对数坐标

---

## 练习 02：双格点的赝 Kohn-Sham 方程

**目录**：[`02_2-site-KSeq-convergence/`](../../02_2-site-KSeq-convergence/)

### 模型

把练习 01 中的格点能替换为 Kohn-Sham 有效势 `v_eff`。

```
v_eff(n) = V_H(n) + V_xc(n)
V_H(n)   = U·n                 ← Hartree 项（经典库仑）
V_xc(n)  = -A·√n               ← 交换关联项（模仿 LDA 的 √n 依赖形式）
```

注意总能量 **并不是 KS 本征值的简单求和**：

```
E_tot = ε_KS - E_H + E_xc        （重复计数 double counting 的修正）
E_H   = ½U(n₁² + n₂²)
E_xc  = -(2/3)A(n₁^1.5 + n₂^1.5)
```

### 运行

```bash
cd 02_2-site-KSeq-convergence
python 2-site-KSeq.py
```

### 输出

| 文件 | 内容 |
|---|---|
| `density.png` | 密度的收敛过程 |
| `energy.png` | 总能量的收敛过程 |
| `residual.png` | 残差（对数坐标） |
| `vxc.png` | V_xc 随迭代的变化 |
| `totalN.png` | 粒子数守恒的确认（与 1.0 的虚线对比） |
| `vxc_vs_density.png` | 解沿 V_xc(n) 曲线移动的过程 |
| `veff_vs_density.png` | 解沿 V_eff(n) 曲线移动的过程 |

### 可调参数

| 变量 | 默认值 | 含义 |
|---|---|---|
| `U` | 4.0 | Hartree 项的强度 |
| `A` | 10.0 | **交换关联项的强度** |
| `t` | -1.0 | 跃迁积分 |
| `alpha` | 0.2 | 混合系数 |
| `n1, n2` | 1.0, 0.0 | 初始密度 |

### 任务

1. 令 `A = 0`（无交换关联）运行，与练习 01 的密度分布作比较
2. 把 `A` 依次提高到 0 → 5 → 10 → 20，在 `vxc_vs_density.png` 中追踪解最终落在何处
3. 查看 `totalN.png`，确认粒子数是否守恒

### 自查清单

- [ ] 能说明 Hartree 项与交换关联项作用上的区别
- [ ] 能说明 `E_tot = ε_KS - E_H + E_xc` 中为什么出现减法（重复计数）
- [ ] 能说明 KS 本征值 ε 与总能量 E 是两回事

---

## 小结

| 概念 | 本章所见 | 实际 DFT 中的对应 |
|---|---|---|
| SCF 循环 | 2×2 矩阵的反复对角化 | 数万维 KS 方程的迭代求解 |
| 混合 | `alpha` | `mixing_beta`（QE 的 `&ELECTRONS`） |
| 收敛判据 | `tol` | `conv_thr`（QE 的 `&ELECTRONS`） |
| v_eff | `U·n - A·√n` | Hartree + LDA/GGA 泛函 |

→ 同样的量将在练习 03 中以 **QE 的 `mixing_beta` / `conv_thr`** 再次出现。

---

[← 00. 环境搭建](00_setup.md) | [目录](README.md) | [下一章：02. 基函数 →](02_basis.md)
