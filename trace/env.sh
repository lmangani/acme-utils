set -ue

root="/export/provisioning/acme/trace"
data="$root/data"
statefile="$data/state"
fifo="$data/fifo"
pcapfile="$data/pcap"
lockfile="$data/lock"
logdir="$root/log"
event_log="$logdir/event"
error_log="$logdir/event"
status="$data/status"
capture="$root/capture.sh"
info="$data/info"
mkdir -p $logdir


date=$(date +%FT%T)

exec 1> >(while read line ; do echo $date $(basename $0)[$$] $line >> $event_log ; done)
exec 2> >(while read line ; do echo $date $(basename $0)[$$] $line >> $error_log ; done)


