#!/bin/sh
#
# Project Clock run wrapper
#
# David Keeffe
# Raster Solutions P/L
#
# $Id: pclock.sh,v 1.5 2000/06/07 02:05:31 david Exp $

# History:
#	$Log: pclock.sh,v $
#	Revision 1.5  2000/06/07 02:05:31  david
#	added 'run from this dir' capability
#
#	Revision 1.4  2000/02/25 04:34:23  david
#	added env variable
#
#	Revision 1.3  2000/02/01 23:21:38  david
#	fixed PCLOCK_HOME default
#
#	Revision 1.2  2000/02/01 22:34:12  david
#	added comments
#
#

# change this to suit your location!
# example:
PCLOCK_HOME=${PCLOCK_HOME:-$HOME/Programme/WorkerTimer}
THISDIR=`dirname $0`
# PCLOCK_HOME=${PCLOCK_HOME:-/home/david/src/projclock}

if [ -f $THISDIR/projclock.tcl ] ; then
	exec wish "$THISDIR/projclock.tcl" "$@"
else
	exec wish "$PCLOCK_HOME/projclock.tcl" "$@"
fi
