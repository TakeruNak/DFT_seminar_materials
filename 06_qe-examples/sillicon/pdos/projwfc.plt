#!/usr/local/bin/gnuplot -persist
# Last modified: 2016/02/18 18:10
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
set ylabel 'Energy (eV)'
ef = 6.7675    #Fermi energy
set xrange [0:1.2]
set noxtics 
set key outside

set yrange [-12:10]
set ytics 5
set mytics 5

plot 'silicon.pdos.pdos_atm#1(Si)_wfc#1(s)' using 2:($1-ef) title 'Si-1s' w l #plot
replot 'silicon.pdos.pdos_atm#1(Si)_wfc#2(p)' using 2:($1-ef) title 'Si-2p' w l #plot
# replot 'silicon.pdos.pdos_tot' using 2:($1-ef) title 'Total-pdos' w l #plot
# replot 'silicon.pdos.pdos_atm#2(Si)_wfc#1(s)' using 2:($1-ef) title 'title' w l #plot
# replot 'silicon.pdos.pdos_atm#2(Si)_wfc#2(p)' using 2:($1-ef) title 'title' w l #plot
#plot_end
pause-1


###--- pdf output ---###
set term pdfcairo color enhanced size 4in, 3in font "Times New Roman,18"
#set term pdfcairo monochrome enhanced size 4in, 3in font "Times New Roman,18"
set output "projwfc.pdf"
replot


###--- eps output ---###
# set terminal postscript eps enhanced monochrome font "Times New Roman,18"
## set terminal postscript eps enhanced monochrome font "Helvetica,18"
# #set terminal postscript eps enhanced color font "Times New Roman,18"
## #set terminal postscript eps enhanced color font "Helvetica,18"
# set output "projwfc.eps"
# replot


# ###--- total dos ---###
# ###--- main gnuplot setting ---###
# set terminal qt enhanced font "Times New Roman,18"
# #tottal_dos
# pause-1
# 
# ###--- eps output ---###
# #set terminal postscript eps enhanced monochrome font "Times New Roman,18"
## #set terminal postscript eps enhanced monochrome font "Helvetica,18"
# set terminal postscript eps enhanced color font "Times New Roman,18"
## set terminal postscript eps enhanced color font "Helvetica,18"
# set output "total_pdos.eps"
# replot

