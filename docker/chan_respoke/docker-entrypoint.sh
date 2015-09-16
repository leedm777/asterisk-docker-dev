#!/bin/bash

set -ex

export RANDFILE=/tmp/.rnd

#
# Generate private key and cert
#
openssl genrsa -out /tmp/respoke.key
openssl req -new -key /tmp/respoke.key -out /tmp/respoke.csr -subj "/CN=Respoke"
openssl x509 -req -days 3650 -in /tmp/respoke.csr -signkey /tmp/respoke.key -out /tmp/respoke.crt

mkdir -p /usr/local/etc/asterisk/keys
cat /tmp/respoke.key /tmp/respoke.crt > /usr/local/etc/asterisk/keys/respoke.pem
rm -f /tmp/respoke.{key,csr,crt}

exec "$@"
