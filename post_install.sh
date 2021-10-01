#!/bin/sh

HOSTNAME=$(hostname)

# Create certificates
mkdir -p /usr/local/etc/restserver
openssl req -nodes -x509 -newkey rsa:4096 -keyout /usr/local/etc/restserver/server.key -out /usr/local/etc/restserver/server.crt -days 365 -subj "/CN=${HOSTNAME}"
chown root:restserver /usr/local/etc/restserver/server.crt /usr/local/etc/restserver/server.key
chmod o=wr,g=r,o= /usr/local/etc/restserver/server.crt /usr/local/etc/restserver/server.key

# Create htpasswd file
touch /var/db/restserver/.htpasswd
chown root:restserver /var/db/restserver/.htpasswd
chmod o=wr,g=r,o= /var/db/restserver/.htpasswd

# Configure the service
sysrc restserver_enable=YES
sysrc restserver_syslog_output_enable=YES
sysrc restserver_syslog_output_priority=debug
sysrc restserver_options="--listen :8000 --tls --tls-cert /usr/local/etc/restserver/server.crt --tls-key /usr/local/etc/restserver/server.key --private-repos"

# Start the service
service restserver start
