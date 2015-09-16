#!/bin/bash

#
# Dev process for building Asterisk from a local source tree
#

TOPDIR=$(cd $(dirname $0) && pwd)
PROGNAME=$(basename $0)

BUILD=$1

usage() {
    cat <<EOF
usage: ${PROGNAME} [base].[repo]

  base: one of ${BASES}
  repo: one of ${REPOS}
EOF
}

if test -z ${BUILD}; then
    usage >&2
    exit 1
fi

BASE=$(echo ${BUILD} | sed -n 's/\-dev..*$// p')
REPO=$(echo ${BUILD} | sed -n 's/^.*\-dev.// p')

if test -z ${BASE} || test -z ${REPO}; then
    usage >&2
    exit 1
fi

mkdir -p ~/.asterisk-builder/${BASE}/ccache
mkdir -p ~/.asterisk-builder/sounds

set -ex

docker build -f docker/${REPO}/Dockerfile.${BASE}-builder -t ${REPO}-builder:${BASE} docker/${REPO}

if ! test -f repos/.${REPO}.base || test $(cat repos/.${REPO}.base) != ${BASE}; then
    # built for another base; clean and rebuild
    if test -d repos/${REPO}/.svn; then
        svn st --no-ignore repos/${REPO} | sed -n 's/^I// p' | xargs rm -rf
    elif test -d repos/${REPO}/.git; then
        git -C repos/${REPO} clean -Xdff
    else
        echo "${PROGNAME}: Unknown repo type for repos/${REPO}" >&2
        exit 1
    fi
    echo ${BASE} > repos/.${REPO}.base
fi

docker ps -qa --filter name=${REPO}-builder | xargs docker rm

docker run --name ${REPO}-builder \
       -v ${TOPDIR}/repos/${REPO}:/usr/src/${REPO} \
       -v ${HOME}/.asterisk-builder/${BASE}/ccache:/root/.ccache \
       -v ${HOME}/.asterisk-builder/sounds:/usr/src/sounds \
       ${REPO}-builder:${BASE} \
       /build-${REPO}

docker commit \
       --author "David M. Lee, II <dlee@digium.com>" \
       -c 'CMD ["/usr/local/sbin/asterisk", "-c"]"' \
       ${REPO}-builder ${REPO}:${BASE}

docker rm ${REPO}-builder
