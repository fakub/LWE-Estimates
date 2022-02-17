#!/usr/bin/env gnuplot

reset

# this can be used via: $ gnuplot -c plot.sh data.dat
RES      = ARG1
OUT      = ARG2
N_MAX    = ARG3
N_STEP   = ARG4
MLA_MAX  = ARG5
MLA_STEP = ARG6

set term pngcairo dashed size 1800,900
#~ set term epslatex size 16cm,8cm color colortext standalone font 10 header \
#~ '\usepackage{amsmath}\usepackage{nicefrac}'

set out OUT

set xrange [0:N_MAX]
set  xtics 8*N_STEP
set mxtics 8

set yrange [8:MLA_MAX]
set  ytics 5*MLA_STEP
set mytics 5

set cbrange [64:576]
set cbtics 64

set grid mxtics xtics mytics ytics

#~ set tmargin at screen 0.15
#~ set rmargin at screen 0.88
#~ set bmargin at screen 0.95
#~ set lmargin at screen 0.10

set pm3d map
set pm3d interpolate 0,0

# 0 "#000090",\
# 8 "#7f0000")
set palette negative defined ( \
                      0 "#000090",\
                      1 "#000fff",\
                      2 "#0090ff",\
                      3 "#0fffee",\
                      4 "#90ff70",\
                      5 "#ffee00",\
                      6 "#ff7000",\
                      7 "#ee0000",\
                      8 "#ffffff")

#~ unset key
set key at 987,37.9

set xlabel 'LWE dimension n'
set ylabel 'log(alpha)' offset -1,0

splot RES matrix nonuniform t 'Est. bit-security of LWE'

#~ set xlabel '\LWE dimension $n$'
#~ set ylabel '$-\log(\alpha)$' offset -1,0

#~ splot RES matrix nonuniform t 'Est.\ bit-security of \LWE'

