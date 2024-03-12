set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(rp) AODV
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50
set val(ll) LL
set val(ant) Antenna/OmniAntenna 
set val(x) 500
set val(y) 500
set val(stop) 60.0
set val(nn) 3

set ns [new Simulator]
set tf [open 7.tr w]
$ns trace-all $tf
set nf [open 7.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set prop [new $val(prop)]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
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
                -macTrace ON \
                -agentTrace ON

for { set i 0 } { $i < $val(nn) } { incr i } {
    set node_($i) [$ns node]
    $node_($i) random-motion 0
}


for {set i 0} {$i<$val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 40
}

$ns at 0.0 "$node_(0) setdest 450.0 285.0 30.0"
$ns at 0.0 "$node_(1) setdest 200.0 285.0 30.0"
$ns at 0.0 "$node_(2) setdest 1.0 285.0 30.0"
$ns at 25.0 "$node_(0) setdest 300.0 285.0 10.0"
$ns at 25.0 "$node_(2) setdest 100.0 285.0 10.0"
$ns at 40.0 "$node_(0) setdest 490.0 285.0 5.0"
$ns at 40.0 "$node_(2) setdest 1.0 285.0 5.0

 
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
set ftp [new Application/FTP]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(2) $sink
$ns connect $tcp $sink
$ftp attach-agent $tcp

$ns at 1.0 "$ftp start"
$ns at 59.0 "$ftp stop"

for {set i 0} {$i<$val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset"
}

$ns at $val(stop) "puts  \"NS EXITING..\" ; $ns halt"
$ns run

