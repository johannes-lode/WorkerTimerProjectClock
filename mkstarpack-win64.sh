#!/bin/sh

PROGDIR=$(dirname $(readlink -f $0))

cd $PROGDIR

$PROGDIR/3rd_party/tclkit-linux-x86_64 $PROGDIR/3rd_party/sdx.kit wrap projclock -runtime $PROGDIR/3rd_party/ttclkit851.exe
mv projclock $PROGDIR/bin/projclock-win64.exe
