#!/bin/bash

#Script for quesize vs throughput

i=10
incr=2
echo "cbrPacketSize cbrInterval cbrBW Queue Time Throughput"

for (( j=1; j<=30; j++ ))
do
    #for i in {50..200..4}
    #do
        time=$i"ms"
        cbrBW=$j"mb"
        ns nw.tcl $cbrBW $time 10
        echo -n $cbrBW" "  #cbrBW
        echo -n 10 " " #Queue
        echo -n "10ms "
        awk -f "throughput.awk" out.tr
        echo " "
    #done
done


