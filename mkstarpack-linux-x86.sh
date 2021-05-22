#!/bin/sh

PROGDIR=$(dirname $(readlink -f $0))

cd $PROGDIR

TCLKIT=tclkit-linux-x86

$PROGDIR/3rd_party/$TCLKIT $PROGDIR/3rd_party/sdx.kit wrap projclock -runtime $PROGDIR/3rd_party/${TCLKIT}_kitprefixcopy
mv projclock $PROGDIR/bin/projclock-linux-x86
