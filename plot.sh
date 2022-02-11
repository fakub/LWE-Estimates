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
set out OUT

unset key

set xrange [0:N_MAX]
set xtics N_STEP font ",10" rotate by 45 right
set xlabel "LWE dimension n"

set yrange [0:MLA_MAX]
set ytics MLA_STEP font ",10"

set ylabel "-log(alpha)"

set cbrange [64:600]
set cbtics 64

set grid

set tmargin at screen 0.12
set bmargin at screen 0.95

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

splot RES matrix nonuniform

