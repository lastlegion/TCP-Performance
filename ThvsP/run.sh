#!/bin/bash

#Script for quesize vs throughput

i=10
incr=2
echo "cbrPacketSize cbrInterval Queue Time Throughput"

for j in {3..30..1}
do
    #for i in {50..200..4}
    #do
        time=$i"ms"
        #echo $time
        ns nw.tcl $time $j
        echo -n $j " " #Queue
        echo -n $time " "
        awk -f "throughput.awk" out.tr
        echo " "
    #done
done


