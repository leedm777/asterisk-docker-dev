#!/bin/sh

set -ex

CFLAGS="-O2 -DNDEBUG" ./configure \
      --enable-shared --disable-opencore-amr --disable-resample \
      --disable-sound --disable-video --with-external-gsm \
      --with-external-pa --with-external-speex \
      --with-external-srtp

make dep all install

/sbin/ldconfig
exec rm -f /build-pjsip
