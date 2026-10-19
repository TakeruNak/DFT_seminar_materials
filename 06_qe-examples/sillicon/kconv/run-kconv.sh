#!/bin/bash
# ============================================================
# 演習 3-9: k 点収束テスト
#   si.scf.in.tmpl の k メッシュだけを変えて SCF を繰り返し、
#   全エネルギーの変化を kconv.dat にまとめる。
#
#   他のパラメータ（ecutwfc, 構造, 擬ポテンシャル）は一切変えない。
#   変える量を 1 つに絞るのが収束テストの鉄則。
# ============================================================
set -u

QE_BIN_DIR=${QE_BIN_DIR:-}
QE_PREFIX=${QE_BIN_DIR:+${QE_BIN_DIR}/}
PW_COMMAND=${QE_PREFIX}pw.x

if ! command -v "${PW_COMMAND}" >/dev/null 2>&1; then
    echo ">>> ERROR: pw.x が見つかりません (${PW_COMMAND})"
    echo ">>> Quantum ESPRESSO を install するか, QE_BIN_DIR を設定してください."
    exit 1
fi

if [ ! -e system.in ]; then
    echo ">>> ERROR: system.in がありません"
    exit 1
fi

NAME=$(grep -i "^NAME"      system.in | awk '{print $2}')
NUM_PROCS=$(grep -i "^NUM_PROCS" system.in | awk '{print $2}')
K_LIST=$(grep -i "^K_LIST"  system.in | cut -d' ' -f2-)

echo ">>> NAME      ${NAME}"
echo ">>> NUM_PROCS ${NUM_PROCS}"
echo ">>> K_LIST    ${K_LIST}"
echo ""

printf "# nk  n_kpoints  total_energy(Ry)  wall(s)\n" > kconv.dat

for NK in ${K_LIST}; do
    sed "s/__NK__/${NK}/g" si.scf.in.tmpl > ${NAME}.scf.in

    echo ">> k-mesh ${NK}x${NK}x${NK} ..."
    START=$(date +%s)
    mpirun -np "${NUM_PROCS}" "${PW_COMMAND}" -inp ${NAME}.scf.in > ${NAME}.scf.${NK}.out
    END=$(date +%s)

    # 既約 k 点数と全エネルギー
    NKPT=$(grep -m1 "number of k points" ${NAME}.scf.${NK}.out | awk '{print $5}')
    ETOT=$(grep '^!' ${NAME}.scf.${NK}.out | tail -1 | awk '{print $5}')

    if [ -z "${ETOT}" ]; then
        echo "   !! SCF が収束しませんでした (${NAME}.scf.${NK}.out を確認)"
        continue
    fi

    printf "%4s %10s %18s %8s\n" "${NK}" "${NKPT}" "${ETOT}" "$((END-START))" >> kconv.dat
    echo "   既約 k 点 ${NKPT} 個 / E = ${ETOT} Ry / $((END-START)) 秒"
done

echo ""
echo ">>> 結果: kconv.dat"
cat kconv.dat
