#!/bin/bash
if [ -e system.in ]; then
    echo ">>> READ system.in"
    NAME=(`grep -i "NAME" system.in | awk -F " " '{print $2}'`)
    CAL=(`grep -i "CAL" system.in | awk -F " " '{print $2}'`)
    #NUM_PROCS=(`grep -i "NUM_PROCS" system.in | awk -F " " '{print $2}'`)
    echo ">>> NAME " ${NAME}
#    echo ">>> CAL  " ${CAL}
    echo ">>> NUM_PROCS " ${NUM_PROCS}
    echo ""
    echo ""
else
    echo ">>> ERROR !!!"
    echo ">>> Please put system.in in this directory"
    echo ""
     if [ -e *.scf.in ]; then
        NAME=$(basename *.scf.in .scf.in)
     else
         NAME='###'
     fi
   # echo ${NAME}
cat << EOS > system.in_tmp
NAME ${NAME}
CAL  scf
NUM_PROCS ${NUM_PROCS}

# --------------------------------------------
# \$CAL is the flag for calculation methods
# --- QE ---
# scf = scf calcultion
# band = band calculation
# wf = wave functions
# cd = charge density
# dos = density of states
# proj = projection wave function
# lat_opt = optimization of lattice const.
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
# --------------------------------------------
EOS
exit
#    NUM_PROCS=6
#    NAME=$1 # name
#    CAL=wannier
fi

### --- create supecell QE input part --- ###
ls supercell-* > tmp_file1
gsed 's/supercell-//g' tmp_file1 |
gsed 's/.in//g' > tmp_file2
while read line
do  
    cat header.in supercell-$line.in > ${NAME}-${line}.in
done < ./tmp_file2

ls ${NAME}-*.in > tmp_file1 
gsed 's/.in//g' tmp_file1 > tmp_file2
