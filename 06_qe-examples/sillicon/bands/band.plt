#!/usr/local/bin/gnuplot -persist
# Last modified: 2016/02/18 11:04

###--- terminal output ---###
#set terminal x11 enhanced font "Times New Roman,18" # for external supercomputer
set terminal qt enhanced font "Times New Roman,18"   

###--- eps output ---###
#set terminal postscript eps enhanced color font "Times-New-Roman,24"
#set terminal postscript eps enhanced monochrome font "Helvetica"
#set output "band.eps"


###--- main gnuplot setting ---###
#set xlabel 'momentum'
set ylabel 'Energy [eV]'
#set size ratio 2.0

set ytics 5
set mytics 5

unset key
# set size ratio 2

ry = 1.0 #13.60569193
#coord_start
x1 = 0.0000    #coord
x2 = 0.7071    #coord
x3 = 0.9571    #coord
x4 = 0.9571    #coord
x5 = 1.7071    #coord
x6 = 2.3195    #coord
x7 = 2.8195    #coord
x8 = 3.1730    #coord
xmax = x8      #coord
#coord_end
ymin = -12 #20.83997
ymax = 10 #13.25511
ef = 6.7675    #Fermi energy

set xrange [0:xmax]
set yrange [ymin:ymax]
set xtics ("{/Symbol G}" x1, "X" x2, "" x3, "U,K" x4, "{/Symbol G}" x5, "L" x6, "W" x7, "X" x8)
set arrow 100 nohead from 0,0     to xmax,0  lt 3 lc rgb "#1a1a1a" dt '-'
set arrow 1 nohead from x1,ymin to x1,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 2 nohead from x2,ymin to x2,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 3 nohead from x3,ymin to x3,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 4 nohead from x4,ymin to x4,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 5 nohead from x5,ymin to x5,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 6 nohead from x6,ymin to x6,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 7 nohead from x7,ymin to x7,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
set arrow 8 nohead from x8,ymin to x8,ymax lt 2 lc rgb "#1a1a1a" dt '.'  #varr
#axes

plot 'silicon.band.gnu' using 1:($2*ry-ef) w l lw 2 lc rgb "#1a1a1a"  #plot

pause -1

####--- eps output ---###
##set terminal postscript eps enhanced monochrome font "Helvetica,18"
#set terminal postscript eps enhanced color font "Helvetica,18"
#set output "bands.eps"
#replot

# ###--- pdf output ---###
# set term pdfcairo enhanced size 4in, 3in font "Times New Roman,18"
# set output "bands.pdf"
# replot
