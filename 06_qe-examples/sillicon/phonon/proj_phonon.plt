#!/usr/local/bin/gnuplot -persist
# Last modified: 2023/10/13 17:05
###--- terminal output ---###
#set terminal x11 enhanced font "Times New Roman,18" # for external supercomputer
set terminal qt enhanced font "Times New Roman,18"

###--- eps output ---###
#set terminal postscript eps enhanced color font "Times-New-Roman,24"
#set terminal postscript eps enhanced monochrome font "Helvetica"
#set terminal postscript eps enhanced color solid 28 lw 2
#set output "pdos.eps"

###--- main gnuplot setting ---###
set size ratio 2.0
set ylabel ''

# --- x is projected density of state  : y is energy range  ---
#set xrange [0:1.0]
set xrange [0:2]
#set xtics scale 0
#set xtics 0.1
set mxtics 5
#set xtics nomirror
#set noxtics 

e_min = -5.
e_max = 45.
set yrange [e_min:e_max]
set ytics 5
#set noxtics
set key outside

set style fill solid 0.2

data = 'projected_dos.dat'
data2 = 'total_dos.dat'

# VERSION I ---------
# plot data using ($2+$3+$5+$6):1 title 'B-xy' w l lw 2
# replot data using 4:1 title 'B-z'  w l lw 2
# replot data using ($8+$9):1 title 'Li-xy' w l lw 2
# replot data using 10:1 title 'Li-z' w l lw 2
# replot data2 using 2:1  w l lw 2 notitle

plot data2 using 2:1  with filledcurve x1 notitle lc rgb '#808080'

replot data using ($2+$3+$5+$6):1 title 'B-xy' w l lw 2 lc rgb '#005AFF'
replot data using ($4+$7):1 title 'B-z'  w l lw 2 lc rgb '#FF4B00'
replot data using ($8+$9+$11+$12):1 title 'Li-xy' w l lw 2 lc rgb '#F6AA00'
replot data using ($10+$13):1 title 'Li-z' w l lw 2 lc rgb '#03AF7A'

# --- x is energy range : y is projected density of state ---
# e_min = 0.
# e_max = 45.
# set xrange [e_min:e_max]
# #set noxtics
# set key outside
# set yrange [0:0.6]
# set ytics 0.1
# set mytics 5
# plot 'projected_dos.dat' using 1:($2+$3) title 'B-xy' w l lt 4 lc rgb "#00c000" #plot
# replot 'projected_dos.dat' using 1:4 title 'B-z' w l lt 4 lc rgb "#556b2f" #plot
# replot 'projected_dos.dat' using 1:($8+$9) title 'Li-xy' w l lt 4 lc rgb "#0080ff" #plot
# replot 'projected_dos.dat' using 1:10 title 'Li-z' w l lt 4 lc rgb "#00008b" #plot
#plot_end
pause-1


###--- pdf output ---###
set term pdfcairo color enhanced size 4in, 3in font "Times New Roman,18"
#set term pdfcairo monochrome enhanced size 4in, 3in font "Times New Roman,18"
set output "proj_phonon.pdf"
replot

