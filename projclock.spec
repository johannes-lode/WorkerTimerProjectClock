Summary: Point and Click Task Time Recorder
Name: workertimer
%define version 0.9
Version: %{version}
Release: 1
Group: applications/productivity
Copyright: GPL
Source: pclock%{version}.tgz
BuildRoot: /tmp/projclock-root
# Following are optional fields
URL: http://members.optushome.com.au/starters/pclock/
#Distribution: Red Hat Contrib-Net
#Patch: projclock.patch
#Prefix: /usr/local
BuildArchitectures: noarch
#Requires: 
#Obsoletes: 

%description
Projclock is a simple point-and-click time recorder. Written in pure Tcl/Tk,
it's pretty well platform-neutral.

%prep
%setup -n workertimer
#%patch

%build
#./configure --prefix=/usr
make PREFIX=/usr

%install
make install PREFIX=$RPM_BUILD_ROOT/usr DOCDIR=$RPM_BUILD_ROOT/usr/doc/pclock-%{version}

%files
%dir /usr/bin
%dir /usr/lib/pclock
/usr/bin/pck-timer
/usr/bin/pck-summary
/usr/lib/pclock/projclock.tcl
/usr/lib/pclock/utilproc.tcl
/usr/lib/pclock/tips.tcl
/usr/lib/pclock/summary.tcl
/usr/lib/pclock/getopt.tcl
/usr/lib/pclock/filefloppy.gif
/usr/lib/pclock/stop.gif
/usr/lib/pclock/quill.gif
%doc Announce-%{version}
%doc CHANGES
%doc README
%doc TODO
%doc INSTALL
