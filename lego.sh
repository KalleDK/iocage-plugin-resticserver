#!/bin/sh -e

BASEDIR=/usr/local/etc
CONFIGFILE=${BASEDIR}/lego.conf

if [ -r "${CONFIGFILE}" ]
then
    . "${CONFIGFILE}"
fi

LEGO_LIB=${LEGO_LIB:-"/var/db/lego"}
LEGO_DNS=${LEGO_DNS:-"httpreq"}
ACME_SERVER=${ACME_SERVER:-"https://acme-v02.api.letsencrypt.org/directory"}


if [ -z "${EMAIL}" ]; then
        echo "Please set EMAIL to a valid address in ${CONFIGFILE}"
        exit 1
fi

if [ -z "${DOMAIN}" ]; then
        echo "Please set DOMAIN to a valid domain in ${CONFIGFILE}"
        exit 1
fi

if [ "$1" = "run" ]; then
        command="-a run"
else
        command="renew --days=30"
fi

run_or_renew() {
        /usr/local/bin/lego \
                --path "${LEGO_LIB}" \
                --server="${ACME_SERVER}" \
                --email="${EMAIL}" \
                --domains="${DOMAIN}" \
                --dns="${LEGO_DNS}" \
                $1
}

if [ "$command" = "run" ]; then
        run_or_renew "$command"
else
        output=$(run_or_renew "$command") || (echo "$output" && exit 1)
fi
