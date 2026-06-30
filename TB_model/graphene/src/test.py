#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
from pythtb import TBModel, Lattice as TBLattice
from pymatgen.core import Structure, Lattice

# =====================================================================
# 1. Graphene TB model
# =====================================================================
lat = np.array([
    [1.0, 0.0],
    [-0.5, np.sqrt(3.0) / 2.0]
], dtype=float)

orb = np.array([
    [0.0, 0.0],          # A
    [1.0/3.0, 2.0/3.0]   # B
], dtype=float)

# # optional: export CIF
# lat_3d = np.array([
#     [lat[0, 0], lat[0, 1], 0.0],
#     [lat[1, 0], lat[1, 1], 0.0],
#     [0.0, 0.0, 10.0]
# ], dtype=float)
# 
# orb_3d = np.array([
#     [orb[0, 0], orb[0, 1], 0.0],
#     [orb[1, 0], orb[1, 1], 0.0]
# ], dtype=float)
# 
# Structure(
#     lattice=Lattice(lat_3d),
#     species=["C", "C"],
#     coords=orb_3d,
#     coords_are_cartesian=False
# ).to(filename="graphene.cif")

# TB model (periodic directions in 2D)
model_lattice = TBLattice(
    lat_vecs=lat,
    orb_vecs=orb,
    periodic_dirs=[0, 1]
)

graphene = TBModel(lattice=model_lattice)

t = -2.8
graphene.set_hop(t, 0, 1, [0, 0])
graphene.set_hop(t, 0, 1, [0, -1])
graphene.set_hop(t, 0, 1, [-1, -1])

# =====================================================================
# 2. Band structure: Γ -> K -> M -> Γ
# =====================================================================
G = [0.0, 0.0]
K = [1.0/3.0, 1.0/3.0]
Kp = [-1.0/3.0, -1.0/3.0]
M = [0.5, 0.]

# path = [G, K, M, G]
path = [Kp, G, K, M, G]
labels = [r'$K^\prime$', r'$\Gamma$', r'$K$', r'$M$', r'$\Gamma$']
nk_path = 300

k_vec, k_dist, k_node = graphene.k_path(path, nk_path)

evals_path = np.asarray(graphene.solve_ham(k_pts=np.asarray(k_vec), return_eigvecs=False))
if evals_path.ndim == 1:
    evals_path = evals_path[:, None]
elif evals_path.shape[0] == len(k_vec):
    evals_path = evals_path.T

# =====================================================================
# 3. DOS / PDOS (BZ sampling)
# =====================================================================
nk_grid = 120
k1 = np.linspace(0.0, 1.0, nk_grid, endpoint=False)
k2 = np.linspace(0.0, 1.0, nk_grid, endpoint=False)
k_grid = np.array([[x, y] for x in k1 for y in k2], dtype=float)

evals_all, evecs_all = graphene.solve_ham(k_pts=k_grid, return_eigvecs=True)
evals_all = np.asarray(evals_all)
evecs_all = np.asarray(evecs_all)

if evals_all.shape[0] != len(k_grid):
    evals_all = evals_all.T

if evecs_all.shape[0] != len(k_grid) and evecs_all.shape[1] == len(k_grid):
    evecs_all = np.transpose(evecs_all, (1, 0, 2))
if evecs_all.shape[1] == orb.shape[0] and evecs_all.shape[2] != orb.shape[0]:
    evecs_all = np.transpose(evecs_all, (0, 2, 1))

wA = np.abs(evecs_all[:, :, 0])**2
wB = np.abs(evecs_all[:, :, 1])**2

energies = evals_all.reshape(-1)
wA = wA.reshape(-1)
wB = wB.reshape(-1)

E_mesh = np.linspace(-9.0, 9.0, 500)
sigma = 0.10

dE = E_mesh[:, None] - energies[None, :]
gauss = np.exp(-0.5 * (dE / sigma)**2) / (sigma * np.sqrt(2.0 * np.pi))

norm = nk_grid**2
dos = np.sum(gauss, axis=1) / norm
pdA = np.sum(gauss * wA[None, :], axis=1) / norm
pdB = np.sum(gauss * wB[None, :], axis=1) / norm

# =====================================================================
# 4. Plot
# =====================================================================
fig, axes = plt.subplots(1, 2, figsize=(12, 5), gridspec_kw={"width_ratios": [2.2, 1.0]})

ax = axes[0]
for ib in range(evals_path.shape[0]):
    ax.plot(k_dist, evals_path[ib], color="black", lw=1.2)
for x in k_node:
    ax.axvline(x=x, color="gray", lw=0.8, alpha=0.8)
ax.set_xticks(k_node)
ax.set_xticklabels(labels)
ax.set_ylabel("Energy (eV)")
ax.set_title("Band structure (graphene)")
ax.grid(alpha=0.25)

ax.set_xlim(k_dist.min(), k_dist.max())

ax = axes[1]
ax.plot(dos, E_mesh, color="black", lw=1.3, label="Total DOS")
ax.plot(pdA, E_mesh, "--", lw=1.1, label="PDOS(A)")
ax.plot(pdB, E_mesh, "-.", lw=1.1, label="PDOS(B)")
ax.set_xlabel("DOS (arb. units)")
ax.set_ylabel("Energy (eV)")
ax.set_title("DOS / PDOS")
ax.grid(alpha=0.25)
ax.legend(loc="best")

plt.tight_layout()
plt.savefig("graphene_tb.png", dpi=300)
plt.show()
