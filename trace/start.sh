#!/bin/bash

source /export/provisioning/acme/trace/env.sh

netif=$1
ipaddr=$2

exit_code=0

start() {
    echo "Starting trace"
    $root/start_trace.sh $netif $ipaddr
    echo "start" > $fifo
    echo "OK" > $status
    echo "$netif $ipaddr" > $info


}

do_trace() {
    state="0"
    if [ -f $statefile ] ; then
	state="$(cat $statefile)"
    fi

    case $state in
	"0")
	    start
	    state="1"
	    ;;
	"1")
	    echo "Trace already started" >&2
	    echo "Trace already started" > $status
	    exit_code=1
	    exit 1
	    ;;
	*)
	    echo "Bad state($state)" >&2
	    echo "Bad state($state)" > $status
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

   do_trace
   rm -f "$lockfile"
   trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $lockfile...exiting" >&2
fi 
