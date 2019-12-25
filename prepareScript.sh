#!/bin/sh
#
# Generate a script for all the configurable parameters replaced
#
# $Id$
#

#
# Usage : ${0} <source> <destination> [ <mode> ]

#
# Design to be run by make and use variables from the environment to generate
# the script customised for the local environment
#

# Uncomment the following to aid with debugging
#DO=echo

echo "Processing ${1} -> ${2}"

${DO} ${SED:-sed}                                       \
        -e "s:@@BINDIR@@:${BINDIR}:g"                   \
        -e "s:@@LIBDIR@@:${LIBDIR}:g"                   \
        -e "s:@@DOCDIR@@:${DOCDIR}:g"                   \
        -e "s:@@INTERPRETER@@:${INTERPRETER}:g"         \
        -e "s:@@SCRIPT@@:${SCRIPT}:g"                   \
        ${1} > ${2}

if [ -n "${3}" ]
then
    ${DO} ${CHMOD:-chmod} ${3} ${2}
fi
