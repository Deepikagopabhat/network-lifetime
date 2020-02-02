if {$argc != 1} {
       error "\nCommand: ns test.tcl <no.of.mobile-nodes>\n\n " 
}


# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         200                       ;# max packet in ifq
set val(nn)             [lindex $argv 0]           ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              600   			   ;# X dimension of topography
set val(y)              600   			   ;# Y dimension of topography  
set val(stop)		100			         ;# time($i) of simulation end
set opt(energymodel)    EnergyModel     ;
set opt(logenergy)      "on"           ;# log energy every 150 seconds


#-------Event scheduler object creation--------#

set ns [new Simulator]

#creating the trace file and nam file

set tracefd [open test.tr w]
set namtrace [open test.nam w]    

set r1 [open cluster_result1.tr w]
#set r2 [open cluster_result2.tr w]
#set r3 [open cluster_result3.tr w]
#set r4 [open cluster_result4.tr w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

set communication_range 250
set rx 3.65262e-10 


# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ $rx
Phy/WirelessPhy set RXThresh_ $rx
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0


# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON \
                   -energyModel $opt(energymodel) \
                   -rxPower 1.0 \
			 -txPower 3.0 \
                   -idlePower 0.0 \
			 -sensePower 0.0 \
                   -initialEnergy 1000.0

#for {set i 0} {$i < $val(nn) } {incr i } {
#set node_($i) [$ns node]	
#}

#---------- Setting node and its initial energy------------:

for {set i 0} {$i < 1} { incr i } {
set energy 1000
$ns node-config \
                -initialEnergy $energy \
                -rxPower 1.0 \
                -txPower 5.0 
set node_($i) [$ns node]	
set E($i) $energy
set IE($i) $E($i)
set Ec($i) 6.0
}


for {set i 1} {$i < $val(nn)} { incr i } {
set energy [expr round([expr rand()*500]) + 200]
$ns node-config \
                -initialEnergy $energy \
                -rxPower 1.0 \
                -txPower 5.0 
set node_($i) [$ns node]	
set E($i) $energy
set IE($i) $E($i)
set Ec($i) 6.0
}


# Initial node color plus labeling color			 
	
for {set i 0} {$i < $val(nn) } {incr i } {
$node_($i) color black
$ns at 0.0 "$node_($i) label-color maroon"
}

# Provide initial location of mobilenodes..



$ns at 0.1 "$node_(0) label BaseStation"

source ./topology.tcl

#Distance Calculation: (following pithacorous theorm)


$ns at 0.1 "deploy" 
$ns at 1.0 "clustering $r1" 
#$ns at 15.0 "clustering $r2" 
#$ns at 30.0 "clustering $r3" 
#$ns at 45.0 "clustering $r4" 

proc deploy {} {
	global ns node_ val r xx yy
	set currentTime [$ns now]
	set xx(0) 270
	set yy(0) 310
	$ns at $currentTime "$node_(0) setdest $xx(0) $yy(0) 5000"
	for {set i 1} {$i < $val(nn) } { incr i } {
		#set xx($i) [expr rand()*$val(x)]
		#set yy($i) [expr rand()*$val(y)]
		$ns at $currentTime "$node_($i) setdest $xx($i) $yy($i) 5000"
	}
}

proc clustering {r} {

	global ns xx yy node_ E Ec val communication_range

set currentTime [$ns now]
puts $r "currentTime = $currentTime" 
for {set i 0} {$i < $val(nn) } { incr i } {
	#set xx($i) [$node_($i) set X_]
	#set yy($i) [$node_($i) set Y_]
}

for {set i 0} {$i < $val(nn) } { incr i } {
	set E($i) [$node_($i) energy]
}
for {set i 0} {$i < $val(nn) } { incr i } {
     puts "\n"
     puts $r "\n"

     for {set j 0} {$j < $val(nn) } { incr j } {
                                           
                                                set dx [expr $xx($i) - $xx($j)]
                                                set dy [expr $yy($i) - $yy($j)]

                                                set dx2 [expr $dx * $dx]
                                                set dy2 [expr $dy * $dy]

                                                set h2 [expr $dx2 + $dy2]

                                                set h($i-$j) [expr pow($h2, 0.5)]
                                                puts "distance of node($i) from node($j) = $h($i-$j)"
                                                puts $r "distance of node($i) from node($j) h($i-$j) = $h($i-$j)"
                                                
   }
}
   
set num 1
set j 1
set num2 1
set j2 1
set num3 1
set j3 1
set num4 1
set j4 1

#Seperating regions..

          for {set i 1} {$i < $val(nn) } {incr i } {

              if {$xx($i) > 270} {	

                 if {$yy($i) > 310} {

                         $ns at $currentTime "$node_($i) color darkcyan"
                        
                         set region1($num) $i
                                                                     
                        set num [expr $num + 1]

				$ns at $currentTime "$ns trace-annotate \"Nodes in the dark cyan color forms cluster1\""	

                 }
             }


          if {$xx($i) > 270} {	

              if {$yy($i) < 310} {

                      $ns at $currentTime "$node_($i) color darkmagenta"

                        set region2($num2) $i
                                                
                        set num2 [expr $num2 + 1]

				$ns at $currentTime "$ns trace-annotate \"Nodes in the dark magenta color forms cluster2\""	

 
               }
           }

             



         if {$xx($i) < 270} {	

             if {$yy($i) < 310} {

                     $ns at $currentTime "$node_($i) color dodgerblue"
                         set region3($num3) $i
                                             
                        set num3 [expr $num3 + 1]

				$ns at $currentTime "$ns trace-annotate \"Nodes in the dodgerblue color forms cluster3\""	

               }
           }





        if {$xx($i) < 270} {	

            if {$yy($i) > 310} {

                    $ns at $currentTime "$node_($i) color purple"
                        
                         set region4($num4) $i
                                              
                        set num4 [expr $num4 + 1]

				$ns at $currentTime "$ns trace-annotate \"Nodes in the dark cyan color forms cluster4\""	

               }
           }




	}


#Printing each region nodes:

for {set i 1} {$i < $num} { incr i } {

puts "region1($i) = $region1($i)"

puts $r "region1($i) = $region1($i)"

}

for {set i 1} {$i < $num2} { incr i } {

puts "region2($i) = $region2($i)"

puts $r "region2($i) = $region2($i)"

}

for {set i 1} {$i < $num3} { incr i } {

puts "region3($i) = $region3($i)"

puts $r "region3($i) = $region3($i)"

}

for {set i 1} {$i < $num4} { incr i } {

puts "region4($i) = $region4($i)"

puts $r "region4($i) = $region4($i)"

}


#Finding neighbors: Communication range of the node is 250m. Nodes which comes under <250m are neighbors.

	for {set j 0} {$j < $val(nn) } { incr j } {

		#puts "Neighbors of node$j"

		#puts $r "Neighbors of node$j"

		set count($j) 0

		for {set k 0} {$k < $val(nn) } { incr k } {
		
		    if {$h($j-$k)!= 0} {
	
		    if {$h($j-$k) < $communication_range} {

		    	set n($j-$count($j)) $k

			#puts "Neighbor of node($j-$count($j)) = $n($j-$count($j))"

			#puts $r "Neighbor of node($j-$count($j)) = $n($j-$count($j))"

			set count($j) [expr $count($j) + 1]
			
		    }

		    }
		}
		#puts "Number of neighbors of node$j = $count($j)"

		#puts $r "Number of neighbors of node$j = $count($j)"

		#puts "\n"

		#puts $r "\n"

	}



#Calculation of alpha: It depends on energy and degree of the node


		puts $r "NodeID		ResidualEnergy "


	for {set j 1} {$j < $val(nn) } { incr j } {

                  #$ns at 0.3 "$node_($j) label $E($j),$count($j)"

			set E($j) [$node_($j) energy]

			
			set alpha_($j) $E($j)

			puts $r "$j	   	$E($j)"

			puts "alpha_($j) = $alpha_($j)"

			#puts $r "alpha_($j) = $alpha_($j)"

                  $ns at [expr $currentTime + 0.7] "$node_($j) label $alpha_($j)"

			$ns at [expr $currentTime + 0.3] "$ns trace-annotate \"Cluster head is elected based on the energy\""	


			$ns at [expr $currentTime+0.7] "$ns trace-annotate \"The node which is having the highest residual energy is elected as cluster head.\""	


	}


#Election of cluster head for Cluster1

for {set i 1} {$i < $num } { incr i } {
	set a($i) $alpha_($region1($i))
}


for {set i 1} {$i < $num } { incr i } {
	for {set j 1} {$j < $num } { incr j } {
		if {$a($j) > $a($i)} {
			set swap $a($j)
			set a($j) $a($i)
			set a($i) $swap
		}
	}
}

set highest_alpha $a([expr $num -1])

puts "highest alpha = $highest_alpha"

puts $r "highest alpha = $highest_alpha"

for {set i 1} {$i < $num } { incr i } {

	if {$alpha_($region1($i)) == $highest_alpha } {

		set clusterhead1 $region1($i)
	}

}

puts "clusterhead1 = $clusterhead1"

puts $r "clusterhead1 = $clusterhead1"

$ns at [expr $currentTime+1.0] "$node_($clusterhead1) label ClusterHead1"
$ns at [expr $currentTime+1.0] "$node_($clusterhead1) color cyan"



#Election of cluster head for Cluster2

for {set i 1} {$i < $num2 } { incr i } {
	set a($i) $alpha_($region2($i))
}


for {set i 1} {$i < $num2 } { incr i } {
	for {set j 1} {$j < $num2 } { incr j } {
		if {$a($j) > $a($i)} {
			set swap $a($j)
			set a($j) $a($i)
			set a($i) $swap
		}
	}
}

set highest_alpha $a([expr $num2 -1])

puts "highest alpha = $highest_alpha"

puts $r "highest alpha = $highest_alpha"

for {set i 1} {$i < $num2 } { incr i } {

	if {$alpha_($region2($i)) == $highest_alpha } {

		set clusterhead2 $region2($i)
	}

}

puts "clusterhead2 = $clusterhead2"

puts $r "clusterhead2 = $clusterhead2"

$ns at [expr $currentTime+1.0] "$node_($clusterhead2) label ClusterHead2"
$ns at [expr $currentTime+1.0] "$node_($clusterhead2) color cyan"



#Election of cluster head for Cluster3:

for {set i 1} {$i < $num3 } { incr i } {
	set a($i) $alpha_($region3($i))
}


for {set i 1} {$i < $num3 } { incr i } {
	for {set j 1} {$j < $num3 } { incr j } {
		if {$a($j) > $a($i)} {
			set swap $a($j)
			set a($j) $a($i)
			set a($i) $swap
		}
	}
}

set highest_alpha $a([expr $num3 -1])

puts "highest alpha = $highest_alpha"

puts $r "highest alpha = $highest_alpha"

for {set i 1} {$i < $num3 } { incr i } {

	if {$alpha_($region3($i)) == $highest_alpha } {

		set clusterhead3 $region3($i)
	}

}

puts "clusterhead3 = $clusterhead3"

puts $r "clusterhead3 = $clusterhead3"

$ns at [expr $currentTime+1.0] "$node_($clusterhead3) label ClusterHead3"
$ns at [expr $currentTime+1.0] "$node_($clusterhead3) color cyan"

$ns at [expr $currentTime+1.0] "$ns trace-annotate \"Nodes in the cyan color are cluster head\""	

#Election of cluster head for Cluster4:

for {set i 1} {$i < $num4 } { incr i } {
	set a($i) $alpha_($region4($i))
}


for {set i 1} {$i < $num4 } { incr i } {
	for {set j 1} {$j < $num4 } { incr j } {
		if {$a($j) > $a($i)} {
			set swap $a($j)
			set a($j) $a($i)
			set a($i) $swap
		}
	}
}

set highest_alpha $a([expr $num4 -1])

puts "highest alpha = $highest_alpha"

puts $r "highest alpha = $highest_alpha"

for {set i 1} {$i < $num4 } { incr i } {

	if {$alpha_($region4($i)) == $highest_alpha } {

		set clusterhead4 $region4($i)
	}

}

puts "clusterhead4 = $clusterhead4"

puts $r "clusterhead4 = $clusterhead4"

$ns at [expr $currentTime+1.0] "$node_($clusterhead4) label ClusterHead4"
$ns at [expr $currentTime+1.0] "$node_($clusterhead4) color cyan"



for {set i 1} {$i < $num } { incr i } {

set udp [new Agent/UDP]
$ns attach-agent $node_($clusterhead1) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 128
$cbr set interval_ 0.1
$cbr attach-agent $udp

set null [new Agent/Null] 
$ns attach-agent $node_($region1($i)) $null

$ns connect $udp $null
$ns at [expr $currentTime+1.0] "$cbr start"
$ns at [expr $currentTime+10.0] "$cbr stop"

$ns at [expr $currentTime+1.2] "$ns trace-annotate \"Clusterhead sends --clusterhead elected message-- to its cluster members\""	


}

for {set i 1} {$i < $num2 } { incr i } {

set udp [new Agent/UDP]
$ns attach-agent $node_($clusterhead2) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 128
$cbr set interval_ 0.1
$cbr attach-agent $udp

set null [new Agent/Null] 
$ns attach-agent $node_($region2($i)) $null

$ns connect $udp $null
$ns at [expr $currentTime+1.0] "$cbr start"
$ns at [expr $currentTime+10.0] "$cbr stop"

$ns at [expr $currentTime+1.2] "$ns trace-annotate \"Clusterhead sends --clusterhead elected message-- to its cluster members\""	


}

for {set i 1} {$i < $num3 } { incr i } {

set udp [new Agent/UDP]
$ns attach-agent $node_($clusterhead3) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 128
$cbr set interval_ 0.1
$cbr attach-agent $udp

set null [new Agent/Null] 
$ns attach-agent $node_($region3($i)) $null

$ns connect $udp $null
$ns at [expr $currentTime+1.0] "$cbr start"
$ns at [expr $currentTime+10.0] "$cbr stop"

$ns at [expr $currentTime+1.2] "$ns trace-annotate \"Clusterhead sends clusterhead elected message to its cluster members\""	


}

for {set i 1} {$i < $num4 } { incr i } {

set udp [new Agent/UDP]
$ns attach-agent $node_($clusterhead4) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 128
$cbr set interval_ 0.1
$cbr attach-agent $udp

set null [new Agent/Null] 
$ns attach-agent $node_($region4($i)) $null

$ns connect $udp $null
$ns at [expr $currentTime+1.0] "$cbr start"
$ns at [expr $currentTime+10.0] "$cbr stop"

$ns at [expr $currentTime+1.2] "$ns trace-annotate \"Clusterhead sends clusterhead elected message to its cluster members\""	

}


set source [expr round([expr rand()*$val(nn)])]

puts "source = $source"

puts $r "source = $source"

for {set i 1} {$i < $num } { incr i } {

	if {$region1($i) == $source} {

		set ch $clusterhead1
	}

}

for {set i 1} {$i < $num2 } { incr i } {

	if {$region2($i) == $source} {

		set ch $clusterhead2
	}

}

for {set i 1} {$i < $num3 } { incr i } {

	if {$region3($i) == $source} {

		set ch $clusterhead3
	}

}

for {set i 1} {$i < $num4 } { incr i } {

	if {$region4($i) == $source} {

		set ch $clusterhead4
	}

}


puts "ch = $ch"

puts $r "ch = $ch"

$ns at [expr $currentTime+4.0] "$node_($source) color orange"
$ns at [expr $currentTime+4.0] "$node_($source) label Source"

set udp [new Agent/UDP]
$ns attach-agent $node_($source) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1024
$cbr set interval_ 0.1
$cbr attach-agent $udp

set null [new Agent/Null] 
$ns attach-agent $node_($ch) $null

$ns connect $udp $null
$ns at [expr $currentTime+4.0] "$cbr start"
$ns at [expr $currentTime+7.0] "$cbr stop"

set udp [new Agent/UDP]
$ns attach-agent $node_($ch) $udp

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1024
$cbr set interval_ 0.1
$cbr attach-agent $udp

set null [new Agent/Null] 
$ns attach-agent $node_(0) $null

$ns connect $udp $null
$ns at [expr $currentTime+4.0] "$cbr start"
$ns at [expr $currentTime+7.0] "$cbr stop"

$ns at [expr $currentTime+4.0] "$ns trace-annotate \"Orange color node is source node and it is in  cluster$ch.\""	
$ns at [expr $currentTime+4.2] "$ns trace-annotate \"Source node sends data to its cluster head.\""	
$ns at [expr $currentTime+4.2] "$ns trace-annotate \"Clustrehead sends data to BaseStation\""	

}


#Define the node size for nam
for {set i 0} {$i < $val(nn)} { incr i } {
$ns initial_node_pos $node_($i) 30
}


# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at $val(stop).01 "puts \"end simulation\" ; $ns halt"

#stop procedure...
proc stop {} {
    global ns tracefd namtrace val communication_range
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam test.nam &
}

$ns run

