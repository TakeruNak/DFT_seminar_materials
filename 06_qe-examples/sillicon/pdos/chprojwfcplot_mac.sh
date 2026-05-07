#!/bin/bash

NAME=$1  #name

# write Fermi energy
FERMI=(`grep 'Fermi' ${NAME}.scf.out`)
gsed -i'.bak' "/#Fermi energy/c ef = ${FERMI[4]}    #Fermi energy" projwfc.plt

# clean previous plot info
gsed -i -e "/#plot\$/ d" projwfc.plt

#CORD=(`grep 'x coordinate' ${NAME}.bands.out`)
pdos=(`ls *pdos_atm*`)

N=${#pdos[@]}
#echo $N
## how many point j
##j=0
for i in `seq 1 $N`
do
    if [ $i = 1 ]; then
        echo ${pdos[`expr $i-1`]} "using (\$1-ef):2 title 'title' w l,\\ #plot"
#        gsed -i -e "/#plot_end/i plot \'${pdos[`expr $i-1`]}\' using (\$1-ef):2 title 'title' w l #plot" projwfc.plt ### type 1 ###
        gsed -i -e "/#plot_end/i plot \'${pdos[`expr $i-1`]}\' using 2:(\$1-ef) title 'title' w l #plot" projwfc.plt ### type 2 ###
    else
        echo ${pdos[`expr $i-1`]} "using (\$1-ef):2 title 'title' w l #plot"
#        gsed -i -e "/#plot_end/i replot \'${pdos[`expr $i-1`]}\' using (\$1-ef):2 title 'title' w l #plot" projwfc.plt ### type 1 ###
        gsed -i -e "/#plot_end/i replot \'${pdos[`expr $i-1`]}\' using 2:(\$1-ef) title 'title' w l #plot" projwfc.plt ### type 2 ###
    fi
#    
done

gsed -i -e "/#total_dos/i # plot \'${NAME}.pdos_tot\' using 2:(\$1-ef) title 'total dos' w l #plot" projwfc.plt ### type 2 ###
gsed -i -e "/#total_dos/i # replot \'${NAME}.pdos_tot\' using 3:(\$1-ef) title 'sum pdos' w l #plot" projwfc.plt ### type 2 ###
### replace plot command
##gsed -i -e "/#plot/c plot '${NAME}.band.gnu' using 1:(\$2*ry-ef) w l  #plot" band.plt
###gsed -i -e "/#plot/c plot 'band.out.gnu' using 1:(\$2*ry-ef) w l  #plot" band.plt
