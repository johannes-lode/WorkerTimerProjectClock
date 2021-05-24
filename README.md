Project Clock
=============

Changes:

	2019-12-25 johannes-lode
	packged as tclkit and maintainer transfer to johannes-lode
	at github.com

	Revision 1.7  2004/03/17 22:11:36  david
	changed for 0.7

	Revision 1.6  2001/01/24 03:21:51  david
	added features for v0.6

	Revision 1.5  2000/06/07 02:05:05  david
	added summary usage

	Revision 1.4  2000/02/28 05:26:55  david
	version 0.4

	Revision 1.3  2000/02/23 22:24:07  david
	v0.3 updates

	Revision 1.2  2000/02/23 22:17:39  david
	v0.2 changes

	Revision 1.1  2000/02/01 23:14:28  david
	Initial revision


Version 0.92

David Keeffe; david@systemsolve.net
Johannes Lode; linuxer@quantentunnel.de

Motivation for this time tracking tool
--------------------------------------

I often work on several different projects at once, and really need
to keep track of time on each so I can bill clients correctly and fairly.

Noting the time in a diary was a start, but if your desk is anything
like mine, finding the diary *and* a writing implement is a stressful
activity. So the time gets recorded occasionally and inaccurately.

The only constant is my Linux desktop, so I looked for a simple program
which would let me run timers for multiple projects, where a click of
the mouse would stop one timer and start another.

I wrote this in Tcl/Tk. It just about does enough for me;
it's a bit short on reporting tools (but see "summary" below).

The version as reported by "Help->About" is 1.x - this is because RCS starts
at 1.1!

Read the CHANGES file!

Copyright
---------

This program is COPYRIGHT 2000-2001 David Keeffe. You may use and distribute
it under the terms of the GNU Public License.

Installing Project Clock
------------------------

Read the INSTALL file in this directory.

Using Project Clock
-------------------

Start Project Clock by issuing the command "pck-timer".

Pclock will create and maintain a project record automatically.

When you fire up pck-timer, there will be no projects. Use the menu item
'Edit->Add Project' to add an item, and 'Edit->Delete Project' to delete
an item.

A project timer will start when you click on the project button with the
left mouse button.

You can update times manually by RIGHT-clicking on the project button.

Every two minutes, the project state will be written out to a file
'$HOME/.pclock', with a backup to '$HOME/.pclock.bak'.

The data is saved when you exit and when you send the program SIGINT.

The data is formatted as a couple of Tcl associative arrays.

(new in v0.7)

You can keep a simple diary of work for a project. If you click the
"quill" icon on the toolbar, a window will pop up with diary entries
for the currenly selected project, and space to write a new one. If no
project is current, a list will be popped up first.

Diary entries normally go in $HOME/pclock.d/diary.<project-name>. It's
possible to implement a shared diary by setting the diary home to be a
world- (or group-) writable directory, but note that there is no locking
presently implemented.

(new in v0.6)

You can display a number of reports from pck-timer.
The reports are generated using pck-summary (see below). Currently pck-timer
calls pck-summary using "exec". This won't work on MS Windows. There is a
function "runprog" in the utilproc.tcl library, but I haven't tested it
with Project Clock yet.

Various properties are saved in a file $HOME/.pclockrc and can be set
using the built-in properties editor. You can also edit the rc file by
hand.

Report generator "summary"
--------------------------

You can generate a summary for a given range of dates, using the "pck-summary"
program. You can also specify one or more projects to restrict output.
Also, because of the way Tcl works, you can specify a project name using
a "glob" style pattern. This feature is a happy accident!

Usage: pck-summary [-hxlrs][-f day][-t day][-d range][project-name ...]
Where -
	-h            : output this message
	-x            : increment debug level
	-l            : list projects
	-q            : don't print headings
	-r            : just rawtimes times, no factoring
	-s            : omit summaries
	-v            : print daily times
	-f            : start day (default 1)
	-t            : end day (default last of month)
	-d period     : process times for 'period' (single (m/y) or range (m/y-m/y)) 
	-i file       : read data from 'file'

