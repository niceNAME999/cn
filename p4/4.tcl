set ns [new Simulator]
set tf [open 4.tr w]
$ns trace-all $tf
set nf [open 4.nam w]
$ns namtrace-all $nf

set s [$ns node]
set c [$ns node]
$s label "SERVER"
$c label "CLIENT"
$ns color 1 red

$ns duplex-link $s $c 10Mb 10ms DropTail 

set tcp [new Agent/TCP]
$ns attach-agent $s $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $c $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp set fid_ 1
$tcp set packetSize_ 1500

$ns at 0.1 "$ftp start"
$ns at 10.0 "finish"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $nf
    close $tf
    exec nam 4.nam &
    exec awk -f p4transfer.awk 4.tr &
    exec awk -f p4convert.awk 4.tr > convert.tr &
    exec xgraph convert.tr &
    exit 0
}
$ns run
