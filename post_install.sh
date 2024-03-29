#!/bin/sh

HOSTNAME=$(hostname)
DOMAINNAME=$(domainname)

# Create certificates
mkdir -p /usr/local/etc/restserver
openssl req -nodes -x509 -newkey rsa:4096 -keyout /usr/local/etc/restserver/server.key -out /usr/local/etc/restserver/server.crt -days 365 -subj "/CN=${HOSTNAME}.${DOMAINNAME}"
chown root:restserver /usr/local/etc/restserver/server.crt /usr/local/etc/restserver/server.key
chmod o=wr,g=r,o= /usr/local/etc/restserver/server.crt /usr/local/etc/restserver/server.key

# Install htpasswd
# Use openssl passwd -apr1
# fetch --no-verify-peer https://github.com/KalleDK/go-htpasswd/releases/download/v0.0.3/htpasswd-freebsd-amd64.tar -o - | tar xf - -C /usr/local/bin/
# chmod o=rx,g=rw,o=rx /usr/local/bin/htpasswd

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

# Add Lego Cron
mkdir -p /var/db/lego
chown _lego:_lego /var/db/lego

fetch https://raw.githubusercontent.com/KalleDK/iocage-plugin-resticserver/main/lego.sh -o /usr/local/sbin/lego.sh
chmod o=rx,g=rw,o=rx /usr/local/sbin/lego.sh

fetch https://raw.githubusercontent.com/KalleDK/iocage-plugin-resticserver/main/lego-deploy.sh -o /usr/local/sbin/lego-deploy.sh
chmod o=rx,g=rw,o=rx /usr/local/sbin/lego-deploy.sh

fetch https://raw.githubusercontent.com/KalleDK/iocage-plugin-resticserver/main/lego.env -o /usr/local/etc/lego/lego.env

sysrc -f /etc/periodic.conf weekly_lego_enable=YES
sysrc -f /etc/periodic.conf weekly_lego_renewscript=/usr/local/sbin/lego.sh
sysrc -f /etc/periodic.conf weekly_lego_deployscript=/usr/local/sbin/lego-deploy.sh
