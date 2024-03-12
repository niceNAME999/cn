set ns [new Simulator]

set tf [open 3.tr w]
$ns trace-all $tf
set nf [open 3.nam w]
$ns namtrace-all $nf
set cwind [open win3.tr w]

$ns rtproto DV
$ns color 1 Blue

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n1 2Mb 2ms DropTail 
$ns duplex-link $n1 $n4 2Mb 2ms DropTail 
$ns duplex-link $n4 $n5 2Mb 2ms DropTail 
$ns duplex-link $n0 $n2 2Mb 2ms DropTail 
$ns duplex-link $n2 $n3 2Mb 2ms DropTail 
$ns duplex-link $n3 $n5 2Mb 2ms DropTail 

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp set fid_ 1

$ns at 0.1 "$ftp start"
$ns at 10.0 "finish"
$ns rtmodel-at 1.0 down $n1 $n4
$ns rtmodel-at 3.0 up $n1 $n4

proc plotWindow {tcpSource file} {
    global ns 
    set time 0.01
    set now [$ns now]
    set cwnd [$tcpSource set cwnd_]
    puts $file "$now $cwnd"
    $ns at [expr $now+$time] "plotWindow $tcpSource $file" 
}

$ns at 1.0 "plotWindow $tcp $cwind"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam 3.nam &
    exec xgraph win3.tr &
    exit 0
}

$ns run
