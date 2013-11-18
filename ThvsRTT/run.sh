#!/bin/bash

i=10
incr=2

for i in {10..800..5}
do
    time=$i"ms"
    #echo $time
    ns nw.tcl $time
    echo -n $time
    echo -n " "
    awk -f "throughput.awk" out.tr
    echo " "



done


