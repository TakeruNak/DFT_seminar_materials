# DFT 研讨会实践手册（简体中文）

[🌐 Language](../../README.md) ・ [English](../en/README.md) ・ [日本語](../ja/README.md) ・ 简体中文

东京科学大学（Institute of Science Tokyo）CLS 立山・安藤研究组内部研讨会
**《密度泛函理论——理论概要与计算》** 的实践手册。

本手册的编写目标是：**新加入课题组的学生只要从上到下按顺序阅读本页，就能完成全部练习。**

---

## 使用方法

1. 在浏览器中打开本页，同时打开一个 **终端（Terminal）** 窗口
2. 完成 [00. 环境搭建](00_setup.md)（仅首次，约 1–2 小时）
3. **按顺序** 完成下表中的练习
4. 能够回答每章末尾的"自查清单"后再进入下一章

> **请先阅读** → [00_setup.md](00_setup.md)

---

## 学习路线

| # | 章节 | 练习目录 | 学习内容 | 用时 |
|---|---|---|---|---|
| 00 | [环境搭建](00_setup.md) | `00_environment/` | 终端, Homebrew, Git, Python, Quantum ESPRESSO | 1–2 h |
| 01 | [自洽场 (SCF)](01_scf.md) | `01_`, `02_` | SCF 循环, 混合 (mixing), Kohn-Sham 方程 | 1 h |
| 02 | [基函数与完备性](02_basis.md) | `03_`, `04_`, `05_` | 傅里叶展开, 完备性, 平面波基, 截断能 | 1.5 h |
| 03 | [Quantum ESPRESSO 入门](03_quantum-espresso.md) | `06_qe-examples/` | SCF, 结构优化, 波函数, 能带, DOS, PDOS, 声子 | 3–4 h |
| 04 | [HOMO-LUMO 分析](04_homo-lumo.md) | `07_homo-lumo/` | 分子轨道的可视化与能级 | 1 h |
| 05 | [紧束缚模型](05_tight-binding.md) | `TB_model/` | 紧束缚模型与第一性原理计算的对应关系 | 1 h |

**附录**

- [命令速查表・外部工具・故障排查](90_reference.md)

> 全部练习均已在 **QE 7.5 / Open MPI 5.0.9 / phonopy 3.5.1 / pythtb 2.0.0 /
> macOS (Apple Silicon)** 上验证通过。各章给出了参考数值与实测耗时，
> 请与自己的结果进行对照。

---

## 研讨会涉及的理论脉络

```
多体薛定谔方程   HΦ = EΦ        ← 直接求解在计算量上不可行
          ↓  Hohenberg-Kohn 定理      E = E[n]  （总能量是电子密度的泛函）
          ↓  Kohn-Sham 定理           (-½∇² + v_eff[n]) φᵢ = εᵢ φᵢ
          ↓  对 E_xc 的近似            LDA / GGA / meta-GGA / hybrid
          ↓  用基函数离散化             平面波基 + 赝势
          ↓  自洽求解                   SCF 循环
      Quantum ESPRESSO (PWscf)
```

本仓库的练习按照这一流程排列，目的是让你 **用最小模型亲手确认每一个步骤**。

| 流程中的步骤 | 对应练习 |
|---|---|
| 自洽求解 | 01, 02 |
| 用基函数离散化 | 03, 04, 05 |
| 用赝势 + 平面波做实际计算 | 06, 07 |
| 模型与第一性原理计算的对应 | TB_model |

---

## 目录结构

```
DFT_seminar_materials/
├── README.md                       ← 语言选择页
├── requirements.txt                 Python 依赖包
├── docs/
│   ├── en/                          English manual
│   ├── ja/                          日本語マニュアル
│   └── zh/                          简体中文手册（本目录）
├── 00_environment/                  vim / tmux 配置示例
├── 01_2-site-convergence/           练习 01
├── 02_2-site-KSeq-convergence/      练习 02
├── 03_sinx_fitting/                 练习 03
├── 04_sinx-cosx/                    练习 04
├── 05_gaussian-plane-wave-fitting/  练习 05
├── 06_qe-examples/                  练习 06（Quantum ESPRESSO）
├── 07_homo-lumo/                    练习 07
├── TB_model/                        练习 08
└── 99_slides/                       讲义幻灯片（已 .gitignore，另行分发）
```

> `99_slides/` **不包含在本仓库中**（已加入 `.gitignore`）。
> 讲义幻灯片、练习题和作业由负责人另行分发。

---

## 遇到问题时

1. 查阅 [90_reference.md](90_reference.md) 中的"故障排查"
2. 复制完整的错误信息进行搜索
3. 仍无法解决时，附上 **你执行的命令** 和 **完整的错误输出** 再提问

---

[下一章：00. 环境搭建 →](00_setup.md)
