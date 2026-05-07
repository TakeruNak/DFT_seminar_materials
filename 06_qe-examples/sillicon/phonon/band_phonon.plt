#!/usr/local/bin/gnuplot -persist
# Last modified: 2023/10/13 17:47

###--- terminal output ---###
#set terminal x11 enhanced font "Times New Roman,18" # for external supercomputer
set terminal qt enhanced font "Times New Roman,18"   

###--- eps output ---###
#set terminal postscript eps enhanced color font "Times-New-Roman,24"
#set terminal postscript eps enhanced monochrome font "Helvetica"
#set output "band.eps"

###--- main gnuplot setting ---###
#set xlabel ''
set ylabel 'Frequency [THz]'
#set size ratio 2.0

set ytics 5
#set mytics 5

unset key
# set size ratio 2

#ry = 1.0 #13.60569193
#coord_start
x1 = 0.0000    #coord
x2 = 0.07619540    #coord
x3 = 0.12018690    #coord
x4 = 0.20816980    #coord
x5 = 0.29330250    #coord
x6 = 0.36949800    #coord
x7 = 0.41348940    #coord
x8 = 0.50147230    #coord
x9 = 0.57766780    #coord
x10 = 0.66280050    #coord
x11 = 0.75862750    #coord
x12 = 0.84376020    #coord
xmax = x12      #coord
#coord_end
ymin = -5.0
ymax = 45

set xrange [0:xmax]
set yrange [ymin:ymax]
set xtics ("{/Symbol G}" x1, "M" x2, "K" x3, "{/Symbol G}" x4, "A" x5, "L" x6, "H" x7, "A" x8, \
            "L" x9, "M" x10, "H" x11, "K" x12)
set arrow 100 nohead from 0,0     to xmax,0  lt 3 lc rgb "#1a1a1a" dt '-'
set arrow 1 nohead from x1,ymin to x1,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 2 nohead from x2,ymin to x2,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 3 nohead from x3,ymin to x3,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 4 nohead from x4,ymin to x4,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 5 nohead from x5,ymin to x5,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 6 nohead from x6,ymin to x6,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 7 nohead from x7,ymin to x7,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 8 nohead from x8,ymin to x8,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 9 nohead from x9,ymin to x9,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 10 nohead from x10,ymin to x10,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 11 nohead from x11,ymin to x11,ymax lt 2 lc rgb "#1a1a1a"   #varr
set arrow 12 nohead from x12,ymin to x12,ymax lt 2 lc rgb "#1a1a1a"   #varr
#axes

plot 'gnuplot_band.dat' using 1:2 w l lw 2 lc rgb "#1a1a1a"  #plot

pause -1

####--- eps output ---###
##set terminal postscript eps enhanced monochrome font "Helvetica,18"
#set terminal postscript eps enhanced color font "Helvetica,18"
#set output "bands.eps"
#replot

###--- pdf output ---###
set term pdfcairo enhanced size 4in, 3in font "Times New Roman,18"
set output "bands_phonon.pdf"
replot
