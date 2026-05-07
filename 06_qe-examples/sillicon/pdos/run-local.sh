#!/bin/bash

PW_COMMAND=/Users/takerunakashima/workspace/src/QE/qe-7.5/bin/pw.x
PP_COMMAND=/Users/takerunakashima/workspace/src/QE/qe-7.5/bin/pp.x
BANDS_COMMAND=/Users/takerunakashima/workspace/src/QE/qe-7.5/bin/bands.x
PROJWFC_COMMAND=/Users/takerunakashima/workspace/src/QE/qe-7.5/bin/projwfc.x
# UTILITY_COMMAND=/Users/takerunakashima/workspace/src/QE/utulity/

if [ -e system.in ]; then
    echo ">>> READ system.in"
    NAME=(`grep -i "NAME" system.in | awk -F " " '{print $2}'`)
    CAL=(`grep -i "CAL" system.in | awk -F " " '{print $2}'`)
    NUM_PROCS=(`grep -i "NUM_PROCS" system.in | awk -F " " '{print $2}'`)
    echo ">>> NAME " ${NAME}
    echo ">>> CAL  " ${CAL}
    echo ">>> NUM_PROCS " ${NUM_PROCS}
    echo ""
    echo ""
else
    echo ">>> ERROR !!!"
    echo ">>> Please put system.in in this directory"
    echo ""
     if [ -e *.scf.in ]; then
#        NAME=(`ls *.scf.in | awk -F "." '{print $1}'`)
        NAME=$(basename *.scf.in .scf.in)
     else
         NAME='###'
     fi
   # echo ${NAME}
cat << EOS > system.in_tmp
NAME ${NAME}
CAL  scf
NUM_PROCS 6

# ============================================
# \$CAL is the flag for calculation methods
# --- QE ---
# scf = scf calcultion
# band = band calculation
# wf = wave functions
# cd = charge density
# dos = density of states
# proj = projection wave function
# lat_opt = optimization of lattice const.
# relax = relaxation of the inner structure
# vc-relax = relaxation of the inner and lattice const.
#
# --- Wannier90 ---
# wannier = loacalized maximum wannier
#
# --- ESM-RISM ---
# esm-rism = ESM-RISM calculation
# pprism = Post process ESM-RISM calculation
#
# --- BGW ---
# epsilon.real.x = bgw epsilon real
# epsilon.cplx.x = bgw epsilon complex
# sigma.real = bgw sigma real
# sigma.cplx = bgw sigma complex
# inteqp.real = bgw inteqp real
# inteqp.cplx = bgw inteqp complex
# kernel.real = bgw kernel real
# kernel.cplx = bgw kernel complex
# absorption.real = bgw absorption real
# absorption.cplx = bgw absorption complex
#
# ============================================

### USAGE ###
# - scf -
# > 1) mpirun -np \${NUM_PROCS} pw.x -inp \${NAME}.scf.in >\${NAME}.scf.out
#
# - proj -
# \${NAME}.scf.in, \${NAME}.nscf.in, \${NAME}.projwfc.in, projwfc.plt,
# and chprojwfcplot_mac.sh are needed
#
# > 1) mpirun -np \${NUM_PROCS} pw.x -inp \${NAME}.scf.in >\${NAME}.scf.out
# > 2) mpirun -np \${NUM_PROCS} pw.x -inp \${NAME}.nscf.in >\${NAME}.nscf.out
# > 3) mpirun -np \${NUM_PROCS} projwfc.x -inp \${NAME}.projwfc.in >\${NAME}.projwfc.out
# > 4) ./chprojwfcplot_mac.sh \${NAME}
# --------------------------------------------
EOS
    exit
#    NUM_PROCS=6
#    NAME=$1 # name
#    CAL=wannier
fi

echo "NUM_PROCS:", ${NUM_PROCS}
#export OMP_NUM_THREADS=2

### --- Program execution ---###
if [ ${CAL} = "scf" ]; then         ### SCF calculation ###
    ###
    echo ">> Start scf calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} < ${NAME}.scf.in >${NAME}.scf.out
    ###
elif [ ${CAL} = "nscf" ]; then      ### relaxation of inner structure calculation ###
    ###
    echo ">> Start nscf calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} < ${NAME}.scf.in >${NAME}.scf.out
    wait
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} < ${NAME}.nscf.in >${NAME}.nscf.out
    ###
elif [ ${CAL} = "stm_cc" ]; then      ### constant-current calculation ###
    ###
    echo ">> Start stm calculation"
    mpirun -np ${NUM_PROCS} ${PP_COMMAND} < ${NAME}.pp_stm+.in >${NAME}.pp_stm+.out
    wait
    mpirun -np ${NUM_PROCS} ${PP_COMMAND} < ${NAME}.pp_isostm+.in >${NAME}.pp_isostm+.out
    ###
elif [ ${CAL} = "relax" ]; then      ### relaxation of inner structure calculation ###
    ###
    echo ">> Start relax calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.relax.in >${NAME}.relax.out 
    ###
elif [ ${CAL} = "vc-relax" ]; then      ### relaxation of inner and lattice structure calculation ###
    ###
    echo ">> Start vc-relax calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.vc-relax.in >${NAME}.vc-relax.out
    ###
elif [ ${CAL} = "bands" ]; then      ### Band calculation ###
    ###
    echo ">> Start bands calculation"
    # mpirun -np ${NUM_PROCS} ${PW_COMMAND} < ${NAME}.scf.in >${NAME}.scf.out
    # wait
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} < ${NAME}.nscf.in >${NAME}.nscf.out
    wait
    mpirun -np ${NUM_PROCS} ${BANDS_COMMAND} < ${NAME}.bands.in >${NAME}.bands.out
    wait
    ./chbandplot_mac.sh ${NAME}
    ###
elif [ ${CAL} = "wf" ]; then        ### Wave function calculation ###
    ###
    echo ">> Start wf calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.scf.in >${NAME}.scf.out
    wait
    mpirun -np ${NUM_PROCS} ${PP_COMMAND} -inp ${NAME}.${CAL}.in >${NAME}.${CAL}.out
    ###
elif [ ${CAL} = "cd" ]; then        ### charge density calculation ###
    ###
    echo ">> Start charge density calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.scf.in >${NAME}.scf.out
    wait
#    mpirun -np ${NUM_PROCS} pw.x -inp ${NAME}.nscf.in >${NAME}.nscf.out
#    wait
    mpirun -np ${NUM_PROCS} pp.x -inp ${NAME}.${CAL}.in >${NAME}.${CAL}.out 
    ###
elif [ ${CAL} = "dos" ]; then       ### Density of states calcualtion ###
    ###
    echo ">> Start DOS calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.scf.in >${NAME}.scf.out
    wait
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.nscf.in >${NAME}.nscf.out
    wait
    mpirun -np ${NUM_PROCS} dos.x -inp ${NAME}.${CAL}.in >${NAME}.${CAL}.out
    wait
    ###
elif [ ${CAL} = "wannier" ]; then   ### Maximally localized Wannier function calculation ###
    ###
### ----------------- Quantum ESPRESSO ----------------
#    echo ">> Start wannier calculation -> scf calc"
#    mpirun -np ${NUM_PROCS} pw.x -inp ${NAME}.scf.in >${NAME}.scf.out
#    wait
#    echo ">> Start wannier calculation -> nscf calc"
#    mpirun -np ${NUM_PROCS} pw.x -inp ${NAME}.nscf.in >${NAME}.nscf.out
#    wait
### ----------------- Wannier ----------------
    echo ">> Start wannier calculation -> wannier calc post process"
    wannier90.x -pp ${NAME}
    wait
    echo ">> Start wannier calculation -> wannier pw2wannier90 calc"
    mpirun -np ${NUM_PROCS} pw2wannier90.x -inp ${NAME}.pw2wan.in >${NAME}.pw2wan.out
    wait
    echo ">> Start wannier calculation -> wannier90 calc"
    wannier90.x ${NAME}
    wait
    if [ -e ${NAME}_band.gnu ]; then
        echo ">> Please plot band; gnuplot & load \"${NAME}_band.gnu\""
    fi
    ###
elif [ ${CAL} = "proj" ]; then   ### Projection wave function ###
    ###
    echo ">> Start projection calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.scf.in >${NAME}.scf.out
    wait
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.nscf.in >${NAME}.nscf.out
    wait
    mpirun -np ${NUM_PROCS} ${PROJWFC_COMMAND} -inp ${NAME}.projwfc.in >${NAME}.projwfc.out
    wait
    ./chprojwfcplot_mac.sh ${NAME}
    ###
elif [ ${CAL} = "pw2bgw" ]; then   ### --- pw2bgw --- ###
    ###
    echo ">> Start pw2bgw calculation"
    #mpirun -n 1 $kgrid ./kgrid.inp ./kgrid.out ./kgrid.log
    #wait
    #cat kgrid.out  >> ./in
    #wait
    mpirun -n ${PJM_MPI_PROC} ${PW_COMMAND} -in ${NAME}.nscf.in &> ${NAME}.nscf.out
    wait
    mpirun -n ${PJM_MPI_PROC} pw2bgw.x -in  ${NAME}.pw2bgw.in &> ${NAME}.pw2bgw.out
    ###
elif [ ${CAL} = "epsilon.real" ]; then   ### --- epsilon.real --- ###
    ###
    #mpirun -n ${PJM_MPI_PROC}  ${bgw_path}/$epsilon &> epsilon.out
    mpirun -n ${PJM_MPI_PROC}  ${bgw_path}/epsilon.real.x &> epsilon.out

#    # Extract qy for the first 12 qpoints
#    # For this example, qy = |q| in crystal coordinates because qx=0.0 for
#    # the first 12 points.
#
#    grep -A 7 "begin qpoint" epsilon.inp | awk '{print $2}' | tail -n -7 >qpoints
#
#    # Find the head of epsilon inverse for the 1st 12 qpoints
#    grep "Head of Epsilon Inverse" epsilon.out |head -7 |awk  '{print $8}' > head
#    paste qpoints head >head.dat
#    rm qpoints
#    rm head
    ###
elif [ ${CAL} = "epsilon.cplx" ]; then   ### --- epsilon.cplx --- ###
    ###
    #mpirun -n ${PJM_MPI_PROC}  ${bgw_path}/$epsilon &> epsilon.out
    mpirun -n ${PJM_MPI_PROC}  ${bgw_path}/epsilon.cplx.x &> epsilon.out

#    # Extract qy for the first 12 qpoints
#    # For this example, qy = |q| in crystal coordinates because qx=0.0 for
#    # the first 12 points.
#
#    grep -A 7 "begin qpoint" epsilon.inp | awk '{print $2}' | tail -n -7 >qpoints
#
#    # Find the head of epsilon inverse for the 1st 12 qpoints
#    grep "Head of Epsilon Inverse" epsilon.out |head -7 |awk  '{print $8}' > head
#    paste qpoints head >head.dat
#    rm qpoints
#    rm head
    ###
elif [ ${CAL} = "sigma.real" ]; then   ### --- sigma.real --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/sigma.real.x &> sigma.out
    ###
elif [ ${CAL} = "sigma.cplx" ]; then   ### --- sigma.cplx --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/sigma.cplx.x &> sigma.out
    ###
elif [ ${CAL} = "inteqp.real" ]; then   ### --- inteqp.real --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/inteqp.real.x &> inteqp.out
    ###
elif [ ${CAL} = "inteqp.cplx" ]; then   ### --- inteqp.cplx --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/inteqp.cplx.x &> inteqp.out
    ###
elif [ ${CAL} = "kernel.real" ]; then   ### --- kernel.real --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/kernel.real.x &> kernel.out
    ###
elif [ ${CAL} = "kernel.cplx" ]; then   ### --- kernel.cplx --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/kernel.cplx.x &> kernel.out
    ###
elif [ ${CAL} = "absorption.real" ]; then   ### --- absorption.real --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/absorption.real.x &> absorption.out
    ###
elif [ ${CAL} = "absorption.cplx" ]; then   ### --- absorption.cplx --- ###
    ###
    mpirun -n ${PJM_MPI_PROC} ${bgw_path}/absorption.cplx.x &> absorption.out
    ###
elif [ ${CAL} = "esm-rism" ]; then   ### --- ESM-Calculation --- ###
    ###
    echo ">> Start ESM-Calculation"
    mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${NAME}.esm-rism.in >${NAME}.esm-rism.out
    ###
elif [ ${CAL} = "pprism" ]; then   ### --- ESM-Calculation --- ###
    ###
    echo ">> Start Post-process ESM-Calculation"
    mpirun -np ${NUM_PROCS} pprism.x -inp ${NAME}.pprism.in >${NAME}.pprism.out
    ###
else

    echo ">> Error please type band or wf"
#    break
    ###
fi

