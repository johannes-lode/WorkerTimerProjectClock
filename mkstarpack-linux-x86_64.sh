#!/bin/sh

PROGDIR=$(dirname $(readlink -f $0))

cd $PROGDIR

$PROGDIR/3rd_party/tclkit-linux-x86_64 $PROGDIR/3rd_party/sdx.kit wrap projclock -runtime $PROGDIR/3rd_party/tclkit-linux-x86_64_kitprefixcopy
mv projclock $PROGDIR/bin/projclock-linux-x86_64
