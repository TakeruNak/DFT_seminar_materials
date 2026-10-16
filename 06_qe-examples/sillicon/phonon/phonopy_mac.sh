#!/bin/bash

#NUM_PROCS=8
#

QE_BIN_DIR=${QE_BIN_DIR:-}
PW_COMMAND=${QE_BIN_DIR:+${QE_BIN_DIR}/}pw.x

if [ -e system.in ]; then
    echo ">>> READ system.in"
    NUM_PROCS=(`grep -i "NUM_PROCS" system.in | awk -F " " '{print $2}'`)
fi
prefix=silicon-001
mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${prefix}.in >${prefix}.out
wait

