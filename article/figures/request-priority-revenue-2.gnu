#!/usr/bin/gnuplot -persist
#
#    
#    	G N U P L O T
#    	Version 4.4 patchlevel 3
#    	last modified March 2011
#    	System: Linux 3.2.0-53-generic
#    
#    	Copyright (C) 1986-1993, 1998, 2004, 2007-2010
#    	Thomas Williams, Colin Kelley and many others
#    
#    	gnuplot home:     http://www.gnuplot.info
#    	faq, bugs, etc:   type "help seeking-assistance"
#    	immediate help:   type "help"
#    	plot window:      hit 'h'
# set terminal wxt 0
# set output
set term epslatex size 6,3 standalone color colortext 10
set out 'request-priority-revenue-2.tex'
unset clip points
set clip one
unset clip two
set bar 1.000000 front
set border 31 front linetype -1 linewidth 1.000
set xdata
set ydata
set zdata
set x2data
set y2data
set timefmt x "%d/%m/%y,%H:%M"
set timefmt y "%d/%m/%y,%H:%M"
set timefmt z "%d/%m/%y,%H:%M"
set timefmt x2 "%d/%m/%y,%H:%M"
set timefmt y2 "%d/%m/%y,%H:%M"
set timefmt cb "%d/%m/%y,%H:%M"
set boxwidth
set style fill  empty border
set style rectangle back fc lt -3 fillstyle   solid 1.00 border lt -1
set style circle radius graph 0.02, first 0, 0 
set dummy x,y
set format x "$%g$"
set format y "$%g$"
set format x2 "$%g$"
set format y2 "$%g$"
set format cb "% g"
set angles radians
unset grid
set key title ""
set key inside right bottom vertical Right noreverse enhanced autotitles nobox
set key noinvert samplen 4 spacing 1 width 0 height 0 
set key maxcolumns 0 maxrows 0
unset label
unset arrow
set style increment default
unset style line
unset style arrow
set style histogram clustered gap 2 title  offset character 0, 0, 0
unset logscale
set offsets 0, 0, 0, 0
set pointsize 1
set pointintervalbox 1
set encoding default
unset polar
unset parametric
unset decimalsign
set view 60, 30, 1, 1
set samples 100, 100
set isosamples 10, 10
set surface
unset contour
set clabel '%8.3g'
set mapping cartesian
set datafile separator whitespace
unset hidden3d
set cntrparam order 4
set cntrparam linear
set cntrparam levels auto 5
set cntrparam points 5
set size ratio 0 1,1
set origin 0,0
set style data points
set style function lines
set xzeroaxis linetype -2 linewidth 1.000
set yzeroaxis linetype -2 linewidth 1.000
set zzeroaxis linetype -2 linewidth 1.000
set x2zeroaxis linetype -2 linewidth 1.000
set y2zeroaxis linetype -2 linewidth 1.000
set ticslevel 0.5
set mxtics default
set mytics default
set mztics default
set mx2tics default
set my2tics default
set mcbtics default
set xtics border in scale 1,0.5 mirror norotate  offset character 0, 0, 0
set xtics autofreq  norangelimit
set ytics border in scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set ytics autofreq  norangelimit
set ztics border in scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set ztics autofreq  norangelimit
set nox2tics
set y2tics border in scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set y2tics autofreq  norangelimit
set cbtics border in scale 1,0.5 mirror norotate  offset character 0, 0, 0
set cbtics autofreq  norangelimit
set title "" 
set title  offset character 0, 0, 0 font "" norotate
set timestamp bottom 
set timestamp "" 
set timestamp  offset character 0, 0, 0 font "" norotate
set rrange [ * : * ] noreverse nowriteback  # (currently [8.98847e+307:-8.98847e+307] )
set trange [ * : * ] noreverse nowriteback  # (currently [-5.00000:5.00000] )
set urange [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set vrange [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set xlabel "Time (h)" 
set xlabel  offset character 0, 0, 0 font "" textcolor lt -1 norotate
set x2label "" 
set x2label  offset character 0, 0, 0 font "" textcolor lt -1 norotate
set xrange [ 4.5 : 6 ] noreverse nowriteback
set x2range [ 16.9258 : 21.8837 ] noreverse nowriteback
set ylabel "Number of VM instances" 
set ylabel  offset character 0, 0, 0 font "" textcolor lt -1 rotate by -270
set y2label "Revenue ($10^3$)\\$" 
set y2label  offset character 0, 0, 0 font "" textcolor lt -1 rotate by -270
set yrange [ 2.51021 : 10.4677 ] noreverse nowriteback
set y2range [ 11.3437 : 26.3051 ] noreverse nowriteback
set zlabel "" 
set zlabel  offset character 0, 0, 0 font "" textcolor lt -1 norotate
set zrange [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set cblabel "" 
set cblabel  offset character 0, 0, 0 font "" textcolor lt -1 rotate by -270
set cbrange [ * : * ] noreverse nowriteback  # (currently [8.98847e+307:-8.98847e+307] )
set zero 1e-08
set lmargin  -1
set bmargin  -1
set rmargin  -1
set tmargin  -1
set locale "pl_PL.UTF-8"
set pm3d explicit at s
set pm3d scansautomatic
set pm3d interpolate 1,1 flush begin noftriangles nohidden3d corners2color mean
set palette positive nops_allcF maxcolors 0 gamma 1.5 color model RGB 
set palette rgbformulae 7, 5, 15
set colorbox default
set colorbox vertical origin screen 0.9, 0.2, 0 size screen 0.05, 0.6, 0 front bdefault
set loadpath 
set fontpath 
set fit noerrorvariables
a(t) = t < 5 ? 10 : (t >= 5 && t < 5.5 ? 10*(t-5)+10 : (t >= 5.5 && t < 11 ? 15 : (t >= 11 && t < 11.5 ? -10*(t-11)+15 : 10)))
b(t) = t < 13 ? 10 : (t >= 13 && t < 13.5 ? 10*(t-13)+10 : (t >= 13.5 && t < 19 ? 15 : (t >= 19 && t < 19.5 ? -10*(t-19)+15 : 10)))
c(t) = t < 5 ? 10 : (t >= 5 && t < 5.2 ? 15*(t-5)+10 : 13)
d(t) = t < 5 ? 3 : (t >= 5 && t < 5.1 ? 20*(t-5)+3 : 5)
e(t) = 10
f(t) = t < 5 ? 3 : (t >= 5 && t < 5.2 ? 25*(t-5)+3 : 8)
GNUTERM = "wxt"
GPFUN_a = "a(t) = t < 5 ? 10 : (t >= 5 && t < 5.5 ? 10*(t-5)+10 : (t >= 5.5 && t < 11 ? 15 : (t >= 11 && t < 11.5 ? -10*(t-11)+15 : 10)))"
GPFUN_b = "b(t) = t < 13 ? 10 : (t >= 13 && t < 13.5 ? 10*(t-13)+10 : (t >= 13.5 && t < 19 ? 15 : (t >= 19 && t < 19.5 ? -10*(t-19)+15 : 10)))"
GPFUN_c = "c(t) = t < 5 ? 10 : (t >= 5 && t < 5.2 ? 15*(t-5)+10 : 13)"
GPFUN_d = "d(t) = t < 5 ? 3 : (t >= 5 && t < 5.1 ? 20*(t-5)+3 : 5)"
GPFUN_e = "e(t) = 10"
GPFUN_f = "f(t) = t < 5 ? 3 : (t >= 5 && t < 5.2 ? 25*(t-5)+3 : 8)"
plot e(x) axes x1y1 t 'Client A', f(x) axes x1y1 t 'Client B', 1*e(x)+2*f(x) axes x1y2 t 'Total revenue'
#    EOF
