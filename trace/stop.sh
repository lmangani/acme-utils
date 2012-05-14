#!/bin/bash

source /export/provisioning/acme/trace/env.sh

netif=$1
ipaddr=$2

exit_code=0

stop() {
    echo "stop" > $fifo
    $root/stop_trace.sh $netif $ipaddr
    rm $pcapfile
    echo "Stopped trace"
}

do_stop() {
    state="0"
    if [ -f $statefile ] ; then
	state="$(cat $statefile)"
    fi

    case $state in
	"0")
	    echo "No trace started" >&2
	    exit_code=1
	    exit 1
	    ;;
	"1")
	    stop
	    state="0"
	    ;;
	*)
	    echo "Bad state($state)" >&2
	    exit_code=1
	    exit 1
	    ;;
    esac

    echo -n $state > $statefile

}


##
## Grab the lockfile and run
##
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; 
then
   trap 'rm -f "$lockfile"; exit $exit_code' INT TERM EXIT

   > "$lockfile"

   do_stop

   rm -f "$lockfile"
   trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $lockfile...exiting" >&2
fi 
