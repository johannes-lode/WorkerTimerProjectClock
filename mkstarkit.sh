#!/bin/sh

PROGDIR=$(dirname $(readlink -f $0))

cd $PROGDIR

$PROGDIR/bin/tclkit-linux-x86_64 $PRODIR/3rd_party/sdx.kit wrap projclock.kit
mv projclock.kit $PRODIR/bin/
