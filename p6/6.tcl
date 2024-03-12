set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ant) Antenna/OmniAntenna
set val(rp) DSDV
set val(stop) 20.0
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50
set val(nn) 2
set val(ll) LL
set val(y) 500
set val(x) 500

set ns [new Simulator]
set tf [open 6.tr w]
$ns trace-all $tf
set nf [open 6.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set prop [new $val(prop)]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

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
                -macTrace ON 

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
    $node_($i) random-motion 0
}

for {set i 0} {$i<$val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 40
}

$ns at 1.1 "$node_(0) setdest 100.0 100.0 20.0"
$ns at 1.1 "$node_(1) setdest 300.0 100.0 20.0"

set tcp [new Agent/TCP]
$ns attach-agent $node_(0) $tcp 
set sink [new Agent/TCPSink]
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.0 "$ftp start"
$ns at 19.0 "$ftp stop"

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset";
}
$ns at $val(stop) "puts \"NS EXITING..\"; $ns halt"
puts "animation"
$ns run	
