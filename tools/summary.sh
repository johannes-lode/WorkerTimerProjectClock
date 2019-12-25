#!/bin/sh
#
# Project Clock run wrapper
#
# David Keeffe
# Raster Solutions P/L
#
# $Id: summary.sh,v 1.2 2000/06/07 02:05:52 david Exp $

# History:
#	$Log: summary.sh,v $
#	Revision 1.2  2000/06/07 02:05:52  david
#	added 'run from this dir' capabiity
#
#	Revision 1.1  2000/02/25 04:34:36  david
#	Initial revision
#
#
#

# change this to suit your location!
# example:
PCLOCK_HOME=${PCLOCK_HOME:-$HOME/Programme/WorkerTimer}
THISDIR=`dirname $0`
# PCLOCK_HOME=${PCLOCK_HOME:-/home/david/src/projclock}


if [ -f $THISDIR/projclock.tcl ] ; then
	exec tclsh $THISDIR/summary.tcl "$@"
else
	exec tclsh $PCLOCK_HOME/summary.tcl "$@"
fi
