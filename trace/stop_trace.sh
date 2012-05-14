#!/bin/bash

set -ue


root=/export/provisioning/acme/trace
tmp=$root/tmp
tmpfile=$tmp/$$.exp
logfile=$tmp/$$.log
host=10.100.0.6
user=acme
password=packet

netif=$1
ipaddr=$2

mkdir -p $tmp
> $tmpfile
> $logfile

netif=$1
ipaddr=$2

stop_trace() {
cat <<EOF > $tmpfile
set timeout 10
proc abort {} {
	puts "Timeout or EOF\n"
	exit 1
}
sleep 1
spawn telnet $host
expect {
	Password: { send "$user\r" }
	default abort	
}
expect {
	> { send "en\r"; exp_continue }
	Password: { send "$password\r" }
	default abort
}
expect {
	"#" { send "packet-trace stop $netif $ipaddr\r"}
	default abort
}
expect {
	"#" { send "exit\r"; exp_continue }
	">" { send "exit\r" }
	default abort
	eof
}
EOF
expect -f $tmpfile >> $logfile
rm $logfile

}


stop_trace



