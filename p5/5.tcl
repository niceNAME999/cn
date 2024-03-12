set ns [new Simulator -multicast on]
set tf [open 5.tr w]
$ns trace-all $tf
set nf [open 5.nam w]
$ns namtrace-all $tf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

$ns duplex-link $n0 $n2 2Mb 2ms DropTail
$ns duplex-link $n1 $n2 2Mb 2ms DropTail
$ns duplex-link $n2 $n3 2Mb 2ms DropTail
$ns duplex-link $n3 $n4 2Mb 2ms DropTail
$ns duplex-link $n4 $n5 2Mb 2ms DropTail
$ns duplex-link $n4 $n6 2Mb 2ms DropTail
$ns duplex-link $n3 $n7 2Mb 2ms DropTail

set mproto DM
set mrthandle [$ns mrtproto $mproto {}]

set group1 [Node allocaddr]
set group2 [Node allocaddr]

$ns color 1 Red
$ns color 2 Blue

$n0 label "Source 1"
$n1 label "Source 2"
$n5 label "DST 1"
$n6 label "DST 2"
$n7 label "DST 3"

set udp1 [new Agent/UDP]
$ns attach-agent $n0 $udp1
$udp1 set dst_addr_ $group1
$udp1 set dst_port_ 0
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1

set udp2 [new Agent/UDP]
$ns attach-agent $n1 $udp2
$udp2 set dst_addr_ $group2
$udp2 set dst_port_ 0
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2

$udp1 set fid_ 1
$udp2 set fid_ 2
$n0 color Red
$n1 color Blue


set rcvr1 [new Agent/Null]
$ns attach-agent $n5 $rcvr1
set rcvr2 [new Agent/Null]
$ns attach-agent $n6 $rcvr2
set rcvr3 [new Agent/Null]
$ns attach-agent $n6 $rcvr3
set rcvr4 [new Agent/Null]
$ns attach-agent $n5 $rcvr4
set rcvr5 [new Agent/Null]
$ns attach-agent $n6 $rcvr5
set rcvr6 [new Agent/Null]
$ns attach-agent $n7 $rcvr6

$ns at 0.5 "$cbr1 start"
$ns at 0.5 "$cbr2 start"
$ns at 9.5 "$cbr1 stop"
$ns at 9.5 "$cbr2 stop"
$ns at 10.0 "finish"

$ns at 1.0 "$n2 join-group $rcvr1 $group1"
$ns at 1.5 "$n3 join-group $rcvr2 $group1"
$ns at 2.0 "$n4 join-group $rcvr3 $group1"
$ns at 2.5 "$n5 join-group $rcvr4 $group2"
$ns at 3.0 "$n6 join-group $rcvr5 $group2"
$ns at 3.5 "$n7 join-group $rcvr6 $group2"

$ns at 5.0 "$n7 leave-group $rcvr6 $group2"
$ns at 5.5 "$n6 leave-group $rcvr5 $group2"
$ns at 6.0 "$n5 leave-group $rcvr4 $group2"
$ns at 6.5 "$n4 leave-group $rcvr3 $group1"
$ns at 7.0 "$n3 leave-group $rcvr2 $group1"
$ns at 7.5 "$n2 leave-group $rcvr1 $group1"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam 5.tr &
    exit 0 
}

$ns run
