#!/bin/bash

NAME=$1  #name

# write Fermi energy
FERMI=(`grep 'Fermi' ${NAME}.scf.out`)
gsed -i'.bak' "/#Fermi energy/c ef = ${FERMI[4]}    #Fermi energy" dos.plt

# clean previous plot info
gsed -i -e "/#plot\$/ d" dos.plt


gsed -i -e "/#plot_end/i plot \'${NAME}.dos\' using 2:(\$1-ef) title 'title' w l #plot" dos.plt
