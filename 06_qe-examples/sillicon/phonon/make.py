
f = open ('QE_super.sh','w')

f.write('\
#!/bin/bash \n\
#PJM -L "vnode=4"\n\
#PJM -L "vnode-core=36"\n\
#PJM -L "rscunit=ito-a"\n\
#PJM -L "rscgrp=ito-s"\n\
#PJM -L "elapse=04:00:00"\n\
#PJM --no-stging\n#PJM -j\n\
module load qe/6.7.0_intel2018.3\n\
\n\
NUM_PROCS=16\n\
export I_MPI_PERHOST=4\n\
export OMP_NUM_THREADS=9\n\
\n\
export I_MPI_FABRICS=shm:ofa\n\
export I_MPI_PIN_DOMAIN=omp\n\
export I_MPI_PIN_CELL=core\n\
export KMP_STACKSIZE=8m\n\
export KMP_AFFINITY=compact\n\
export I_MPI_HYDRA_BOOTSTRAP=rsh\n\
export I_MPI_HYDRA_BOOTSTRAP_EXEC=/bin/pjrsh\n\
export I_MPI_HYDRA_HOST_FILE=${PJM_O_NODEINF}\n\
\n\
touch RUN\n\
_path_t=$(pwd)\n\
_date_t=$(date \'+%D %T\')\n\
#_path_calcman=/Users/takerunakashima/workspace/workspace/project/work/runspcae/calcman\n\
_path_calcman=/home/usr2/r70192a/job_tmp\n\
\n\
echo "> -------------" >> ${_path_calcman}\n\
echo "> " ${_date_t} >> ${_path_calcman}\n\
echo "> " ${_path_t} >> ${_path_calcman}\n\
echo "> -------------" >> ${_path_calcman}\n\
\n\
\n')

with open('./tmp_file2') as f2:
    for line in f2:
        f.write('\
line='+str(line)+'\
name=a2HB-${line}\n\
mpiexec.hydra -n ${NUM_PROCS} pw.x -inp ${name}.in >${name}.out\n\
wait\n\n')

f2.close()
f.close()
