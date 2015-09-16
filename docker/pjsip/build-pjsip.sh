#!/bin/sh

set -ex

cd /usr/src/pjsip

mv /tmp/config_site.h pjlib/include/pj/

PATH=/usr/lib/ccache:$PATH

if ! test -e build.mak; then
    ./configure \
        --enable-shared --disable-opencore-amr --disable-resample \
        --disable-sound --disable-video --with-external-gsm \
        --with-external-pa --with-external-speex \
        --with-external-srtp

    make dep
fi

make all install

/sbin/ldconfig
