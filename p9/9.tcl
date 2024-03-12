set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(rp) DSR
# set val(ifq) Queue/DropTail/PriQueue
set val(ifq) CMUPriQueue
set val(ifqlen) 50
set val(ll) LL
set val(x) 700
set val(y) 700
set val(nn) 6
set val(stop) 60.0
set val(ant) Antenna/OmniAntenna

set ns_ [new Simulator]
set tf [open 9.tr w]
$ns_ trace-all $tf
set nf [open 9.nam w]
$ns_ namtrace-all-wireless $nf $val(x) $val(y)

set prop [new $val(prop)]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

$ns_ node-config -adhocRouting $val(rp) \
                -channelType $val(chan) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -llType $val(ll) \
                -antType $val(ant) \
                -topoInstance $topo \
                -routerTrace ON \
                -agentTrace ON \
                -macTrace ON

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
}                


for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 60
}       


$node_(0) set X_ 150.0
$node_(0) set Y_  300.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 300.0
$node_(1) set Y_ 500.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 500.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 300.0
$node_(3) set Y_ 100.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 500.0
$node_(4) set Y_ 100.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 650.0
$node_(5) set Y_ 300.0
$node_(5) set Z_ 0.0



$ns_ at 1.0 "$node_(0) setdest 150.0 300.0 100.0"
$ns_ at 1.0 "$node_(1) setdest 300.0 500.0 100.0"
$ns_ at 1.0 "$node_(2) setdest 500.0 500.0 100.0"
$ns_ at 1.0 "$node_(3) setdest 300.0 100.0 100.0"
$ns_ at 1.0 "$node_(4) setdest 500.0 100.0 100.0"
$ns_ at 1.0 "$node_(5) setdest 650.0 300.0 100.0"

$ns_ at 4.0 "$node_(3) setdest 300.0 500.0 5.0"

set tcp [new Agent/TCP]
$ns_ attach-agent $node_(0) $tcp
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(5) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns_ at 5.0 "$ftp start"
$ns_ at 60.0 "$ftp stop"

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ at $val(stop) "$node_($i) reset"
}       

$ns_ at $val(stop) "puts  \"NS EXITING...\" ; $ns_ halt"
puts "animation"
$ns_ run
