#!/bin/sh

DARWIN="darwin`uname -r | cut -d. -f1`"
FAILED=0
# Written by Anders F. Björklund
cd "`dirname \"$0\"`"

# set up symbolic links to compilers without version suffix

tempdir=/tmp/build-$$
mkdir -p $tempdir 
for target in powerpc-apple-$DARWIN i686-apple-$DARWIN; do
  for prefix in /usr /usr/local /opt/gdc /sw /opt/local; do
  if [ -x $prefix/bin/gdc ]; then
    version=`$prefix/bin/gdc -dumpversion`
    for program in gcc g++ gdc; do
    if [ ! -L "$prefix/bin/$target-$program" ]; then
      if [ -x "$prefix/bin/$target-$program-$version" ]; then
      echo "$target-$program -> $target-$program-$version"
      ln -s $prefix/bin/$target-$program-$version $tempdir/$target-$program
      fi
    fi
    done
  fi
  if [ -x "$prefix/bin/gdmd" ]; then
    for program in gdmd; do
    if [ ! -L "$prefix/bin/$target-$program" ]; then
      echo "$target-$program -> $program"
      ln -s $prefix/bin/$program $tempdir/$target-$program
    fi
    done
  fi
  done
done
export PATH="$tempdir:$PATH"

# build Universal Binary versions of the Tango libraries

export MAKETOOL=make

HOME=`pwd` make -s clean -fgdc-posix.mak

LIBS="common/libtango-cc-tango.a gc/libtango-gc-basic.a libgphobos.a"

for lib in $LIBS; do test -r $lib && rm $lib; done

DINC="-q,-nostdinc -I`pwd`/common -I`pwd`/.. -I`pwd`/compiler/gdc"

# Potential additions for later
#export CFLAGS="-arch ppc -arch ppc64" 
#export DFLAGS="-arch ppc -arch ppc64" 
if ADD_CFLAGS="-m32" ADD_DFLAGS="$DINC -m32" ./build-gdc-x.sh powerpc-apple-$DARWIN 1>&2
then
    for lib in $LIBS; do mv $lib $lib.ppc; done
    if ADD_CFLAGS="-m64" ADD_DFLAGS="$DINC -m64" ./build-gdc-x.sh powerpc-apple-$DARWIN 1>&2
    then
        for lib in $LIBS; do mv $lib $lib.ppc64; done
    else
        FAILED=1
    fi
else
    FAILED=1
fi

if [ "$FAILED" = "0" ]
then
    # Potential additions for later
    #export CFLAGS="-arch i386 -arch x86_64" 
    #export DFLAGS="-arch i386 -arch x86_64" 
    if ADD_CFLAGS="-m32" ADD_DFLAGS="$DINC -m32" ./build-gdc-x.sh i686-apple-$DARWIN 1>&2
    then
        for lib in $LIBS; do mv $lib $lib.i386; done
        if ADD_CFLAGS="-m64" ADD_DFLAGS="$DINC -m64" ./build-gdc-x.sh i686-apple-$DARWIN 1>&2
        then
            for lib in $LIBS; do mv $lib $lib.x86_64; done
        else
            FAILED=1
        fi
    else
        FAILED=1
    fi
fi

if [ "$FAILED" = "1" ]
then
    echo 'Failed to build universal binaries. Trying GDC.'
    if ./build-gdc.sh 1>&2
    then
        echo 'Universal binary failed to build, fallback succeded by using standard GDC.'
    else
        echo 'Universal binary failed to build, and so did the fallback method using standard GDC.'
    fi
else
    for lib in $LIBS; do \
    lipo -create -output $lib $lib.ppc $lib.ppc64 $lib.i386 $lib.x86_64; done
fi