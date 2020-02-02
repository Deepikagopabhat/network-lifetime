if {$argc != 1} {
       error "\nCommand: ns topologyCreation.tcl <No.of.Nodes> \n\n " 
}


set topology    [open topology.tcl w]
set val(nn)       [lindex $argv 0]
set val(x)           600   		       	;# X dimension of topography
set val(y)           600			 	;# Y dimension of topography  


for {set i 0} {$i < $val(nn) } { incr i } {
set xx($i) [expr rand()*$val(x)]
set yy($i) [expr rand()*$val(y)]

puts $topology "set xx($i) $xx($i)"
puts $topology "set yy($i) $yy($i)"
puts $topology "\n"

#set energy($i) [expr round([expr rand()]*10)+30]
#puts $topology "set energy($i) $energy($i)"
#puts $topology "set IE($i) $energy($i)"

puts $topology "\n"

}

