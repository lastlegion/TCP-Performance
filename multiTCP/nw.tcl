  set ns [new Simulator]
  set delay [lindex $argv 0]
  #puts $delay


# ####################################################################
# Open NAM trace file
  set nf [open out.nam w]
  $ns namtrace-all $nf    

# ####################################################################
# Open NS trace file
  set tf [open out.tr w]
  $ns trace-all $tf

# ####################################################################
# Open TCP cndw trace file
  set windowVsTime [open win w]

# ####################################################################
# Open parameter recording file
  set param [open parameters w]

# ####################################################################
# Define a 'finish' procedure
  proc finish {} {
     global ns nf tf

     $ns flush-trace
     close $nf                   
     close $tf
     #exec nam out.nam &               
     exit 0
  }

# ####################################################################
# Create bottleneck and dest nodes
  set n2 [$ns node]
  set n3 [$ns node]

# ####################################################################
# Create links between bottleneck nodes
  $ns duplex-link $n2 $n3 0.7Mb $delay DropTail

# ####################################################################
# Set simulation parameters
  set NumbSrc 3
  set SimDuration 50

# ####################################################################
# Create $NumbSrc source nodes
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     set S($j) [$ns node]
  }                

# ####################################################################
# Create a random generator for starting the ftp and 
# for bottleneck link delays
  set rng [new RNG]
  $rng seed 2

# ####################################################################
# parameters for random variables for begenning of ftp connections 
  set RVstart [new RandomVariable/Uniform]
  $RVstart set min_ 0
  $RVstart set max_ 7
  $RVstart use-rng $rng   

# ####################################################################
# Define random starting times for each connection
  for {set i 1} {$i<=$NumbSrc} { incr i } {
     set startT($i)  [expr [$RVstart value]]
     set dly($i) 1
     #puts "startT($i)  $startT($i) sec"
     #puts $param "startT($i)  $startT($i) sec"
  }

# ####################################################################
# Create links between source and bottleneck
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     $ns duplex-link $S($j) $n2 10Mb $dly($j)ms DropTail
     $ns queue-limit $S($j) $n2 20
  }                         


# ####################################################################
# Orient the links
  $ns duplex-link-op $n2 $n3 orient right
  $ns duplex-link-op $S(1) $n2 orient right-down
  $ns duplex-link-op $S(2) $n2 orient right
  $ns duplex-link-op $S(3) $n2 orient right-up

# ####################################################################
# Set Queue Size of (bottleneck) link (n2-n3) to 100
  $ns queue-limit $n2 $n3 100

# ####################################################################
# Create TCP Sources
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     set tcp_src($j) [new Agent/TCP/Reno]
     $tcp_src($j) set window_ 8000
  } 

# ####################################################################
# Color the packets
  $tcp_src(1) set fid_ 1
  $ns color 1 red
  $tcp_src(2) set fid_ 2
  $ns color 2 yellow
  $tcp_src(3) set fid_ 3
  $ns color 3 blue

# ####################################################################
# Create TCP Destinations
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     set tcp_snk($j) [new Agent/TCPSink]
  }  

# ####################################################################
# Define connections between TCP src's and sinks
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     $ns attach-agent $S($j) $tcp_src($j)
     $ns attach-agent $n3 $tcp_snk($j)
     $ns connect $tcp_src($j) $tcp_snk($j)
  }  

# ####################################################################
# Further parametrisation of TCP sources
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     $tcp_src($j) set packetSize_ 552
  }                   

# ####################################################################
# Create FTP sources
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     set ftp($j) [$tcp_src($j) attach-source FTP]
  }       

# ####################################################################
# Schedule events for the FTP agents:
  for {set i 1} {$i<=$NumbSrc} { incr i } {
     $ns at $startT($i) "$ftp($i) start"
     $ns at $SimDuration "$ftp($i) stop"
  }                    

# ####################################################################
# plotWindow(tcpSource file k): Write CWND of k tcpSources in file
  proc plotWindow {tcpSource file k} {
     global ns NumbSrc

     set time 0.03
     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]

     if {$k == 1} {
        puts -nonewline $file "$now \t $cwnd \t" 
     } else { 
     if {$k < $NumbSrc } { 
        puts -nonewline $file "$cwnd \t" 
        }
     }

     if { $k == $NumbSrc } {
        puts -nonewline $file "$cwnd \n" 
     }

     $ns at [expr $now+$time] "plotWindow $tcpSource $file $k" 
  }

# ####################################################################
# Start plotWindow() for all tcp sources
  for {set j 1} {$j<=$NumbSrc} { incr j } {
     $ns at 0.1 "plotWindow $tcp_src($j) $windowVsTime $j" 
  }

# ####################################################################
# Monitor avg queue length of link ($n2,$n3)
  set qfile [$ns monitor-queue $n2 $n3  [open queue.tr w] 0.05]
  [$ns link $n2 $n3] queue-sample-timeout;


# ####################################################################
# Schedule simulation end
  $ns at [expr $SimDuration] "finish"

# ####################################################################
# run
  $ns run

