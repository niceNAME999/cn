set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ant) Antenna/OmniAntenna
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50
set val(ll) LL
set val(rp) AODV
set val(stop) 100.0
set val(nn) 25
set val(x) 500.0
set val(y) 500.0
#set val(sc) "mob-25-50"
set val(cp) "tcp-25-8"

set ns_ [new Simulator]

set tf [open 8.tr w]
$ns_ trace-all $tf

set nf [open 8.nam w]
$ns_ namtrace-all-wireless $nf $val(x) $val(y)

set prop [new $val(prop)]

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

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
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON

for {set i 0} {$i<$val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
}

for {set i 0} {$i < $val(nn) } { incr i } {
    set xx [expr rand()*500]
    set yy [expr rand()*400]
    $node_($i) set X_ $xx
    $node_($i) set Y_ $yy
}

for {set i 0} {$i<$val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 40
}

source $val(cp)

for {set i 0} {$i<$val(nn)} {incr i} {
    $ns_ at $val(stop) "$node_($i) reset"
}
$ns_ at $val(stop) "puts  \"NS Exiting.. \"; $ns_ halt"
$ns_ run
