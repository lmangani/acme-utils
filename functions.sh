##
## Site specific config here
## 

# The user name and password
user=acme
password=packet

# The HA config address for the N-N
host=10.100.0.6

# The N-N community
community=j3110

# The config address
admin_host=10.17.0.163

# This is where to store the config archives
config_root=/export/config/acme

# Set this to the root of where the scripts live
root=/export/provisioning/acme

# The vland of the core network
core_vlan=405

# The default SIP port on the access side
access_port=5060

# The default SIP port on the core side
core_port=5060

##
## Don't change below here
##

set -u

trim () { echo $1; }

cfg_prompt="(configure)#"
tmp=$root/tmp
tmpfile=$tmp/$$.exp
logfile=$tmp/$$.log
base=$(basename $0)


on_error() {
    echo "ERROR:"
    cat $tmp/*.log
    rm -f $tmp/*.log
}

trap on_error ERR


cleanup_tmp () {
    rm -f $tmpfile
}

create_tmp() {
    mkdir -p $tmp
    > $tmpfile
    > $logfile
    trap cleanup_tmp EXIT
}


execute() {
cat <<EOF > $tmpfile
set timeout 5
proc abort {} {
	puts "Timeout or EOF\n"
	exit 1
}
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
$*
expect {
	"#" { send "exit\r"; exp_continue }
	-ex {Save Changes [y/n]?:} { send "y\n" ;exp_continue }
	">" { send "exit\r" }
	default abort
	eof
}
EOF
expect -f $tmpfile 
#> $logfile
rm $logfile
}

cfg_cmd() {
prompt=$1
cmd=$2
cat <<EOF
expect {
	"$prompt" { send "$cmd\r" }
	default abort
}
EOF
}

configure() {
cat <<EOF
expect {
	"#" { send "configure term\r"}
	default abort
}
$*
expect {
	"$cfg_prompt" { send "exit\r"}
	default abort
}
EOF
}

activate() {
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
	"#" { send "activate-config\r"}
	default abort
}
expect {
	-ex { continue (y/n) } { send "y\r"; exp_continue}
	"#" { send "exit\r"; exp_continue }
	">" { send "exit\r" }
	default abort
	eof
}
EOF
expect -f $tmpfile >> $logfile
rm $logfile

}



