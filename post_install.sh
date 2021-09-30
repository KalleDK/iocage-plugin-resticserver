#!/bin/sh

# Configure the service
sysrc restserver_enable=YES
sysrc restserver_syslog_output_enable=YES
sysrc restserver_syslog_output_priority=debug
sysrc restserver_options="--listen :8000 --tls --tls-cert /usr/local/etc/restserver/server.crt --tls-key /usr/local/etc/restserver/server.key --private-repos"

# Start the service
service restserver start
