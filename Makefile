#
# Project Clock Makefile
#
# $Id: Makefile,v 1.8 2004/03/17 22:11:08 david Exp david $
#
# History:
#	$Log: Makefile,v $
#	Revision 1.8  2004/03/17 22:11:08  david
#	made more use of make vars
#
#	Revision 1.7  2001/01/24 03:22:10  david
#	upped version
#
#	Revision 1.6  2000/06/07 02:06:18  david
#	added spec file
#	added Announce
#
#	Revision 1.5  2000/02/25 05:18:52  david
#	added new wrappers/execs
#	added oinstall for old names
#
#	Revision 1.4  2000/02/23 22:23:30  david
#	added getopt, summary
#	/.
#
#	Revision 1.3  2000/02/01 23:22:41  david
#	added -c to install calls
#
#	Revision 1.2  2000/02/01 23:21:58  david
#	fixed installs and dist rule
#
#	Revision 1.1  2000/02/01 23:10:33  david
#	Initial revision
#
#

#
# User Configurable
#
INSTALL_PREFIX=
PREFIX=/usr/local
#PREFIX=/pkgs/proj-clock-$(VERSION)
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib/pclock
DOCDIR=$(PREFIX)/doc/pclock
WISHX=wishx
#WISHX=wish
TCLSH=tclsh

#
# Needed Programs
#
#INSTALL=ginstall		# Must be GNU install compatible
INSTALL=install		# Must be GNU install compatible
TAR=tar				# Must be GNU Tar
ZIP=zip				# Must be GNU Tar
SED=sed

#
# Developer Cofigurable
#
VERSION=0.9
TCLPROGS=projclock.tcl utilproc.tcl tips.tcl summary.tcl getopt.tcl
IMAGES=filefloppy.gif stop.gif quill.gif
SHPROGS=pclock.sh summary.sh
PROGS = pck-timer pck-summary
OPROGS= $(SHPROGS:.sh=)
RUNFILES=$(TCLPROGS) $(IMAGES)
DOC=CHANGES INSTALL README TODO Announce-$(VERSION)
PROGSRC=$(SHPROGS) $(CGIPROGS) $(TCLPROGS)
.SUFFIXES: .tcl
FLAGFILE=update-flag
TARFILE=pclock-update.tgz
DISTFILE=pclock$(VERSION).tgz
ZIPFILE=pclock$(VERSION).zip
DIR=.
AUX=prepareScript.sh wrapper.sh
PREPARE_SCRIPT=BINDIR=$(BINDIR) LIBDIR=$(LIBDIR) DOCDIR=$(DOCDIR) sh ./prepareScript.sh

# ***** Should this go ???? ******

# uncomment the following line for big-endian machines (SPARC, PPC, M68K)
# BIGEND=-DBIGEND

ALLFILES=$(PROGS) $(ETCFILES) $(FILES) $(CGIS) $(PAGES)

all: $(TCLPROGS) $(PROGS) $(ETCFILES) $(FILES) $(CGIS) $(PAGES)

.tcl:
	cat $*.tcl >$*
	chmod 755 $*

source: $(PROGSRC) $(ETCFILES) $(FILES) $(PAGES) $(DOC) $(IMAGES) $(AUX) projclock.spec
	@echo $(PROGSRC) $(ETCFILES) $(FILES) $(PAGES) $(DOC) $(IMAGES) $(AUX) Makefile projclock.spec | $(SED) -e 's:^:$(DIR)/:' -e 's: : $(DIR)/:g'

dist: 
	$(TAR) cvfz $(DISTFILE) -C .. `$(MAKE) -s DIR=\`basename $$PWD\` source`

zip: 
	mkdir workertimer
	$(MAKE) install INSTALL_PREFIX=workertimer
	$(ZIP) -r $(ZIPFILE) workertimer
	rm -rf workertimer

install: all dir
	$(INSTALL) -c -m 755 $(PROGS)     $(INSTALL_PREFIX)$(BINDIR)
	$(INSTALL) -c -m 644 $(RUNFILES)  $(INSTALL_PREFIX)$(LIBDIR)
	$(INSTALL) -c -m 644 $(DOC)       $(INSTALL_PREFIX)$(DOCDIR)

oinstall: all dir $(OPROGS)
	$(INSTALL) -c -m 755 $(OPROGS)    $(INSTALL_PREFIX)$(BINDIR)
	$(INSTALL) -c -m 644 $(RUNFILES)  $(INSTALL_PREFIX)$(LIBDIR)
	$(INSTALL) -c -m 644 $(DOC)       $(INSTALL_PREFIX)$(DOCDIR)

dir:
	$(INSTALL) -d -m 755 $(INSTALL_PREFIX)$(BINDIR)
	$(INSTALL) -d -m 755 $(INSTALL_PREFIX)$(LIBDIR)
	$(INSTALL) -d -m 755 $(INSTALL_PREFIX)$(DOCDIR)

update: all
	mkupdate $(FLAGFILE) $(TARFILE) $(ALLFILES)
	@touch $(FLAGFILE)
	@co -l release-note
	@echo -e "\n RELEASE on `date`\n" >>release-note
	@$(TAR) tvfz $(TARFILE) >>release-note
	@ci release-note

clean:
	rm -f $(PROGS) $(CGIS) core *.o

pck-timer: wrapper.sh Makefile
	INTERPRETER=$(WISHX) SCRIPT=projclock.tcl	\
		 $(PREPARE_SCRIPT) wrapper.sh pck-timer 755

pck-summary: wrapper.sh Makefile
	INTERPRETER=$(TCLSH) SCRIPT=summary.tcl		\
		 $(PREPARE_SCRIPT) wrapper.sh pck-summary 755

summary: wrapper.sh Makefile
	INTERPRETER=$(TCLSH) SCRIPT=summary.tcl		\
		 $(PREPARE_SCRIPT) wrapper.sh summary 755
