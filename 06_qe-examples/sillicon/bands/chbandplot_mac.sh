#!/bin/bash

NAME=$1  #name

# write Fermi energy
FERMI=(`grep 'Fermi' ${NAME}.scf.out`)
gsed -i'.bak' "/#Fermi energy/c ef = ${FERMI[4]}    #Fermi energy" band.plt

# clean previous coordinates and meshes
gsed -i -e "/#coord\$/ d" band.plt
gsed -i -e "/#varr\$/ d" band.plt
# write new corrdinates and meshes
CORD=(`grep 'x coordinate' ${NAME}.bands.out`)
N=${#CORD[@]}
# how many point j
j=0
for i in `seq 1 $N`
do
  if [ "${CORD[$i]}" = "coordinate" ]
    then
    j=`expr $j + 1`
    # coordinate is witten in the next of "coordinate"
    gsed -i -e "/#coord_end$/i x$j = ${CORD[`expr $i+1`]}    #coord" band.plt
    gsed -i -e "/#axes/i set arrow $j nohead from x$j,ymin to x$j,ymax lt 2 lc rgb \"#1a1a1a\" dt '.'  #varr" band.plt
  fi
done
gsed -i -e "/#coord_end$/i xmax = x$j      #coord" band.plt
# replace plot command
gsed -i -e "/#plot/c plot '${NAME}.band.gnu' using 1:(\$2*ry-ef) w l lw 2 lc rgb \"#1a1a1a\"  #plot" band.plt
#gsed -i -e "/#plot/c plot 'band.out.gnu' using 1:(\$2*ry-ef) w l  #plot" band.plt
