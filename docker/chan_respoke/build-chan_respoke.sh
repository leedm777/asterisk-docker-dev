#!/bin/bash

set -ex

cd /usr/src/chan_respoke

make all install AST_INSTALL_DIR=/usr/local

install -m 644 example/sounds/respoke* /usr/local/var/lib/asterisk/sounds/

sed 's#^;dtls_private_key=.*$#dtls_private_key=/usr/local/etc/asterisk/keys/respoke.pem#' respoke.conf.sample > /usr/local/etc/asterisk/respoke.conf
