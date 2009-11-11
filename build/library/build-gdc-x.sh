#!/usr/bin/env bash

die() {
    echo "$1"
    exit $2
}

cd "`dirname $0`"

if [ ! "$1" ]
then
    echo 'Use: build-gdc-x.sh <target> [phobos-fragments-directory]'
    exit 1
fi
HOST="$1"
BUILD="`./compiler/gdc/config.guess`"
CONFIGURE_FLAGS=""
if [ "$2" ]
then
    CONFIGURE_FLAGS="--enable-phobos-config-dir=$2"
fi

$HOST-gdc --help >& /dev/null || die "$HOST-gdc not found on your \$PATH!" 1

HOST_ARCH="`echo $HOST | sed 's/-.*//'`"
#ADD_CFLAGS=
if [ "$HOST_ARCH" = "powerpc" -a ! "`echo $HOST | grep darwin`" ]
then
    ADD_CFLAGS="-mregnames"
fi
#ADD_DFLAGS=

GDC_VER="`$HOST-gdc --version | grep 'gdc' | sed 's/^.*gdc \(pre\-\{0,1\}release \)*\([0-9]*\.[0-9]*\).*$/\2/'`"
GDC_MAJOR="`echo $GDC_VER | sed 's/\..*//'`"
GDC_MINOR="`echo $GDC_VER | sed 's/.*\.//'`"

if [ "$GDC_MAJOR" = "0" -a \
     "$GDC_MINOR" -lt "23" ]
then
    echo 'This version of Tango requires GDC 0.23 or newer.'
    exit 1
fi

cd ./compiler/gdc
./configure --host="$HOST" --build="$BUILD" $CONFIGURE_FLAGS || exit 1
cd ../..

OLDHOME=$HOME
export HOME=`pwd`
make clean -fgdc-posix.mak CC=$HOST-gcc DC=$HOST-gdmd || exit 1
make lib doc install -fgdc-posix.mak CC=$HOST-gcc DC=$HOST-gdmd \
    ADD_CFLAGS="$ADD_CFLAGS" ADD_DFLAGS="$ADD_DFLAGS" SYSTEM_VERSION="-version=Posix" || exit 1
make clean -fgdc-posix.mak CC=$HOST-gcc DC=$HOST-gdmd || exit 1
export HOME=$OLDHOME