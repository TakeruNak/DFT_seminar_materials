#!/bin/bash

#NUM_PROCS=8
#

PW_COMMAND=/Users/takerunakashima/workspace/src/QE/qe-7.5/bin/pw.x 

if [ -e system.in ]; then
    echo ">>> READ system.in"
    NUM_PROCS=(`grep -i "NUM_PROCS" system.in | awk -F " " '{print $2}'`)
fi
prefix=silicon-001
mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${prefix}.in >${prefix}.out
wait

