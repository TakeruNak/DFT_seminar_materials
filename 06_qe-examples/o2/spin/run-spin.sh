#!/bin/bash
# ============================================================
# 演習 3-11: スピン分極（O2 の三重項基底状態）
#   構造・擬ポテンシャル・cutoff を固定したまま
#   nspin = 1 と nspin = 2 を比較する。
# ============================================================
set -u

QE_BIN_DIR=${QE_BIN_DIR:-}
QE_PREFIX=${QE_BIN_DIR:+${QE_BIN_DIR}/}
PW_COMMAND=${QE_PREFIX}pw.x

if ! command -v "${PW_COMMAND}" >/dev/null 2>&1; then
    echo ">>> ERROR: pw.x が見つかりません (${PW_COMMAND})"
    exit 1
fi

NAME=$(grep -i "^NAME"      system.in | awk '{print $2}')
NUM_PROCS=$(grep -i "^NUM_PROCS" system.in | awk '{print $2}')

printf "# case    E_tot(Ry)        total_magnetization(Bohr_mag/cell)\n" > spin.dat

run_case () {
    TAG=$1
    BLOCK=$2
    printf '%s\n' "${BLOCK}" > .spinblock.tmp
    # __SPINBLOCK__ の行を BLOCK で置き換える
    awk '/__SPINBLOCK__/{while((getline line < ".spinblock.tmp")>0) print line; next} {print}' \
        ${NAME}.scf.in.tmpl > ${NAME}.scf.${TAG}.in
    rm -f .spinblock.tmp

    echo ">> ${TAG} ..."
    mpirun -np "${NUM_PROCS}" "${PW_COMMAND}" -inp ${NAME}.scf.${TAG}.in > ${NAME}.scf.${TAG}.out

    ETOT=$(grep '^!' ${NAME}.scf.${TAG}.out | tail -1 | awk '{print $5}')
    MAG=$(grep 'total magnetization' ${NAME}.scf.${TAG}.out | tail -1 | awk '{print $4}')
    MAG=${MAG:-0.00}

    if [ -z "${ETOT}" ]; then
        echo "   !! SCF が収束しませんでした (${NAME}.scf.${TAG}.out)"
        return
    fi
    printf "%-8s %16s %12s\n" "${TAG}" "${ETOT}" "${MAG}" >> spin.dat
    echo "   E = ${ETOT} Ry / M = ${MAG} Bohr mag/cell"
}

run_case "nspin1" "  nspin = 1"
run_case "nspin2" "  nspin = 2
  starting_magnetization(1) =   5.0000000000d-01"

echo ""
cat spin.dat

python3 - <<'PY' 2>/dev/null || true
import re
rows = {}
for line in open("spin.dat"):
    if line.startswith("#"): continue
    f = line.split()
    rows[f[0]] = (float(f[1]), float(f[2]))
if "nspin1" in rows and "nspin2" in rows:
    dE = (rows["nspin2"][0] - rows["nspin1"][0]) * 13.605693
    print(f"\n  E(nspin=2) - E(nspin=1) = {dE:+.3f} eV   （負なら三重項が安定）")
    print(f"  total magnetization     = {rows['nspin2'][1]:.2f} Bohr mag/cell")
PY
