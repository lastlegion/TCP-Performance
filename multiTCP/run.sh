#!/bin/bash

for i in {5..800..5}
do
    timet=$i"ms"
    echo -n $i" "
    ns nw.tcl $timet
    perl throughput "out.tr" 1 2.0 1.0 0.5
#    echo ""
    perl throughput "out.tr" 1 3.0 1.1 0.5
#    echo ""
    perl throughput "out.tr" 1 4.0 1.2 0.5
    echo ""
done
