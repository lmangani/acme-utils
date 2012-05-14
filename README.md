acme-utils
==========

A set of basic utilities to provision ACME packet SBCs.  Known to work
on Net-Net.  The trunk group stuff is specific to a particular network
design, namely of directly cross-connecting CORE to ACCESS realms.  In
this configuration the Net-Net is working only as a entry point to a
core network.

Prerequisites
=============
* Expect


Setup
=====

Change the pair ip, user, password and community.


Functionality
=============

### backup/backup
This backs up the config on the pair and curls it to a local directory. To use it, put something like

    0 * * * * PATH_TO_POLL/backup

In your cron

### tg
These tools are used to create trunk groups
    add_acl
    add_route
    add_session_agent
    change_limits
    create
    create_all
    create_session_agent
    create_session_group
    delete

All have their options relatively well documented

### trace

A basic trace facility. Includes bash scripts that can be run as CGI
so the server can be run remotely. Basically, running the trace
command makes the acme send the serve ip-ip encapsulated packets. We
run a tcpdump process to decode these and write them to a file.
Before using, you need to start the tcpdumpd server with

  nohub tcpdumpd &

There are also some basic settings in trace/env.sh

### tmp
Custom expect scripts are written here
