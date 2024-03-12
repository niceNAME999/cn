set ns [new Simulator]

set tf [open 2.tr w]
$ns trace-all $tf

set  nf [open 2.nam w]
$ns namtrace-all $nf

set cwind [open win2.tr w]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

$ns duplex-link $n1 $n3 2Mb 2ms DropTail
$ns duplex-link $n2 $n3 2Mb 2ms DropTail
$ns duplex-link $n3 $n4 2Mb 2ms DropTail
$ns duplex-link $n4 $n5 2Mb 2ms DropTail
$ns duplex-link $n4 $n6 2Mb 2ms DropTail

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n6 $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n5 $sink2
$ns connect $tcp2 $sink2
set tel1 [new Application/Telnet]
$tel1 attach-agent $tcp2
#set ftp2 [new Application/FTP]
#$ftp2 attach-agent $tcp2

$ns at 1.0 "$ftp1 start"
$ns at 2.0 "$tel1 start"
$ns at 10.0 "finish"

proc plotWindow {tcpSource file} {
	global ns
	set time 0.01
	set now [$ns now]	
	set cwnd [$tcpSource set cwnd_]
	puts $file "$now $cwnd"
	$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 2.0 "plotWindow $tcp1 $cwind"
$ns at 5.5 "plotWindow $tcp2 $cwind"


proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    puts "exec nam.."
    exec nam 2.nam &
    exec xgraph win2.tr &
    exec awk -f 2awk.awk 2.tr &
    exit 0
}

$ns run
