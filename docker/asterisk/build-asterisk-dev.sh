#!/bin/bash

PROGNAME=$(basename $0)

# 1.5 jobs per core works out okay
: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}

set -ex

if test ${DEV_MODE} = true; then
   if ! test -e ./configure; then
       cat >&2 <<EOF
${PROGNAME}: --dev-mode requires Asterisk source directory to be mounted
at /usr/src/asterisk (i.e. docker run -v \${AST_SRC_DIR}:/usr/src/asterisk)
EOF
       exit 1
   fi

   PATH=/usr/lib/ccache:$PATH

   # Only reconfigure if it's needed
   if ! test makeopts -nt configure; then
       ./configure --prefix=/usr/local --with-sounds-cache=/usr/src/sounds \
                   --enable-dev-mode=noisy

       make menuselect/menuselect menuselect-tree menuselect.makeopts

       menuselect/menuselect --enable DONT_OPTIMIZE menuselect.makeopts
       menuselect/menuselect --enable TEST_FRAMEWORK menuselect.makeopts
       menuselect/menuselect --enable DO_CRASH menuselect.makeopts
       menuselect/menuselect --enable-category MENUSELECT_TESTS menuselect.makeopts
       menuselect/menuselect --enable-category MENUSELECT_UTILS menuselect.makeopts
       menuselect/menuselect --disable muted menuselect.makeopts
   fi
fi

# MOAR SOUNDS
for i in CORE-SOUNDS-EN MOH-OPSOUND EXTRA-SOUNDS-EN; do
    for j in WAV ULAW ALAW G722 GSM; do
        menuselect/menuselect --enable $i-$j menuselect.makeopts
    done
done

make -j ${JOBS} all
make install samples
chown -R asterisk:asterisk /usr/local/var/*/asterisk
chmod -R 750 /usr/local/var/spool/asterisk

sed -i -E 's/^;(run)(user|group)/\1\2/' /usr/local/etc/asterisk/asterisk.conf
