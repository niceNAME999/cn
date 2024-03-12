set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ll) LL
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50
set val(ant) Antenna/OmniAntenna
set val(rp) AODV
set val(stop) 60
set val(nn) 5
set val(x) 500
set val(y) 500

set ns [new Simulator]
set tf [open 10.tr w]
$ns trace-all $tf
set nf [open 10.nam w]
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
                -routerTrace ON \
                -macTrace ON \
                -agentTrace ON \
                -IncomingErrProc "uniformErr" \
                -OutgoingErrProc "uniformErr" 

proc uniformErr {} {
    set err [new ErrorModel]
    $err unit pkt
    $err set rate_ 0.01
    return $err
}

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
    $node_($i) random-motion 0
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 50
}

$ns at 1.0 "$node_(0) setdest 100.0 100.0 50.0 "
$ns at 1.0 "$node_(1) setdest 100.0 250.0 50.0"
$ns at 1.0 "$node_(2) setdest 250.0 250.0 50.0"
$ns at 1.0 "$node_(3) setdest 250.0 100.0 50.0"
$ns at 1.0 "$node_(4) setdest 175.0 175.0 50.0"

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
set ftp1 [new Application/FTP]
$ns attach-agent $node_(0) $tcp1
$ns attach-agent $node_(2) $sink1
$ns connect $tcp1 $sink1
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
set ftp2 [new Application/FTP]
$ns attach-agent $node_(1) $tcp2
$ns attach-agent $node_(2) $sink2
$ns connect $tcp2 $sink2
$ftp2 attach-agent $tcp2

$ns at 5.0 "$ftp1 start"
$ns at 5.0 "$ftp2 start"
$ns at 55.0 "$ftp1 stop"
$ns at 55.0 "$ftp2 stop"

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset"
}

$ns at $val(stop) "puts  \"NS EXIITNG..\" ; $ns halt"
$ns run

