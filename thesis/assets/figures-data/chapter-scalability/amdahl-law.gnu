set term epslatex size 6,3 standalone color colortext 10
set output 'amdahl-law.tex'

a=0.3
b=0.5
c=0.7
d=0.9

GNUTERM = "wxt"
#plot './public-cloud-services-market-size-data' u 0:2:xtic(1) w boxes lc rgb "blue" notitle, '' u 0:2:2 w labels center offset 0,1 notitle

set xlabel "Number of processors"
set ylabel "Speedup"
set xrange [1:10]

plot 1/(a + 1/x*(1 - a)) title "30\\% sequential" lc rgb "#1486C7", 1/(b + 1/x*(1 - b)) title "50\\% sequential" lc rgb "#66C7FF", 1/(c + 1/x*(1 - c)) title "70\\% sequential" lc rgb "#33647F", 1/(d + 1/x*(1 - d)) title "90\\% sequential" lc rgb "#30CDFF"
