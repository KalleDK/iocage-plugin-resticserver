#!/bin/sh -e

BASEDIR=/usr/local/etc/lego
CONFIGFILE=${BASEDIR}/lego.conf

if [ -r "${CONFIGFILE}" ]
then
    . "${CONFIGFILE}"
fi

LEGO_LIB=${LEGO_LIB:-"/var/db/lego"}

RESTSERVER_CRT=/usr/local/etc/restserver/server.crt
RESTSERVER_KEY=/usr/local/etc/restserver/server.key

copy_certs () {
  local certfile keyfile rc
  rc=1

  certfile="${LEGO_LIB}/certificates/${DOMAIN}.crt"
  keyfile="${LEGO_LIB}/certificates/${DOMAIN}.key"

  if ! cmp -s "${certfile}" "${RESTSERVER_CRT}"
  then
    cp "${certfile}" "${RESTSERVER_CRT}"
    cp "${keyfile}" "${RESTSERVER_KEY}"
    rc=0
  fi
  

  return $rc
}

if copy_certs
then
  output=$(service restserver restart 2>&1) || (echo "$output" && exit 1)
fi

