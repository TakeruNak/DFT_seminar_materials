#!/bin/bash
# ============================================================
# 演習 3-10: 交換相関汎関数の比較（LDA vs PBE）
#   擬ポテンシャルだけを差し替えて vc-relax を実行し、
#   平衡格子定数を比較する。
#
#   2 つの UPF は functional 以外（USPP / NLCC / z_valence /
#   l_max）が同一なので、差は純粋に汎関数の効果である。
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
XC_LIST=$(grep -i "^XC_LIST"  system.in | cut -d' ' -f2-)

printf "# functional  pseudopotential  a0(ang)  E_tot(Ry)\n" > xc.dat

for UPF in ${XC_LIST}; do
    if [ ! -e "${UPF}" ]; then
        echo ">>> ERROR: ${UPF} がありません。README の手順で取得してください。"
        exit 1
    fi
    FUNC=$(grep -m1 -i 'functional=' "${UPF}" | sed 's/.*functional="\([^"]*\)".*/\1/' | tr -d ' ')
    TAG=$(echo "${FUNC}" | tr 'A-Z' 'a-z')

    sed "s|__PSEUDO__|${UPF}|" ${NAME}.vc-relax.in.tmpl > ${NAME}.vc-relax.in

    echo ">> ${FUNC} (${UPF}) ..."
    mpirun -np "${NUM_PROCS}" "${PW_COMMAND}" -inp ${NAME}.vc-relax.in > ${NAME}.vc-relax.${TAG}.out

    # 最終 CELL_PARAMETERS から格子定数を取る（FCC: a = sqrt(2) * |v1|）
    A0=$(awk '/^CELL_PARAMETERS/{g=NR} g&&NR==g+1{x=$1;y=$2;z=$3} END{printf "%.4f", sqrt(2.0)*sqrt(x*x+y*y+z*z)}' ${NAME}.vc-relax.${TAG}.out)
    ETOT=$(grep '^!' ${NAME}.vc-relax.${TAG}.out | tail -1 | awk '{print $5}')

    printf "%-12s %-30s %8s %16s\n" "${FUNC}" "${UPF}" "${A0}" "${ETOT}" >> xc.dat
    echo "   a0 = ${A0} ang / E = ${ETOT} Ry"
done

echo ""
echo ">>> 結果: xc.dat   （実験値 a0 = 5.431 ang）"
cat xc.dat
