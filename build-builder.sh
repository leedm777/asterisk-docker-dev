#!/bin/bash

#
# Dev process for building Asterisk from a local source tree
#

TOPDIR=$(cd $(dirname $0) && pwd)
PROGNAME=$(basename $0)

: ${FLAVOR:=ubuntu-trusty}

if ! test -e configure; then
    echo "${PROGNAME}: must run from Asterisk source directory" >&2
fi

set -ex

mkdir -p ~/.asterisk-builder/${FLAVOR}/ccache
mkdir -p ~/.asterisk-builder/sounds

docker build -t pjsip:${FLAVOR} -f ${TOPDIR}/${FLAVOR}/Dockerfile.pjsip ${TOPDIR}

docker build -t asterisk-builder:${FLAVOR} \
       -f ${TOPDIR}/${FLAVOR}/Dockerfile.asterisk-builder ${TOPDIR}
docker ps -qa --filter name=asterisk-builder | xargs docker rm
docker run --name asterisk-builder \
       -v $(pwd):/usr/src/asterisk \
       -v ${HOME}/.asterisk-builder/${FLAVOR}/ccache:/root/.ccache \
       -v ${HOME}/.asterisk-builder/sounds:/usr/src/sounds \
       asterisk-builder:${FLAVOR}
docker commit \
       --author "David M. Lee, II <dlee@digium.com>" \
       -c 'CMD ["/usr/local/sbin/asterisk", "-c"]"' \
       asterisk-builder asterisk:${FLAVOR}

docker build -t chan_respoke:${FLAVOR} \
       -f ${TOPDIR}/${FLAVOR}/Dockerfile.chan_respoke ${TOPDIR}
