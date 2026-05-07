f = open ('phonopy_mac.sh','w')


f.write('\
#!/bin/bash\n\
\n\
#NUM_PROCS=8\n\
#\n\
\n\
PW_COMMAND=/Users/takerunakashima/workspace/src/QE/qe-7.5/bin/pw.x \n\
\n\
if [ -e system.in ]; then\n\
    echo ">>> READ system.in"\n\
    NUM_PROCS=(`grep -i "NUM_PROCS" system.in | awk -F " " \'{print $2}\'`)\n\
fi\n')


with open('./tmp_file2') as f2:
    for line in f2:
        f.write('\
prefix='+str(line)+'\
mpirun -np ${NUM_PROCS} ${PW_COMMAND} -inp ${prefix}.in >${prefix}.out\n\
wait\n\n')

f2.close()
f.close()
