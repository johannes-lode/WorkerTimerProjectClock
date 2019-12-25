#!/bin/sh
#
# Project Clock Shell Wrapper
#
# $Id$
#

PCLOCK_HOME=${PCLOCK_HOME:-@@LIBDIR@@}
export PCLOCK_HOME

WRAPPER_DIR=`dirname $0`

if [ -f "${WRAPPER_DIR}/@@SCRIPT@@" ]
then
	RUNTIME_LOCATION=${WRAPPER_DIR}
else
	RUNTIME_LOCATION=${PCLOCK_HOME}
fi

exec @@INTERPRETER@@ ${RUNTIME_LOCATION}/@@SCRIPT@@ "$@"

