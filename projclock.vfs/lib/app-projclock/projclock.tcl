#!/usr/bin/wish -f
#
# Project Clock
#
# Copyright &copy; 2000 David Keeffe
# Subject to the terms of the GNU General Public License
#
# $Id: projclock.tcl,v 1.13 2004/03/17 22:13:50 david Exp david $

# History:
#	$Log: projclock.tcl,v $
#	Revision 1.13  2004/03/17 22:13:50  david
#	lots of changes
#	edit previous day
#	diary
#	app state/history
#	different timer DBs
#
#	Revision 1.12  2001/02/02 06:18:13  david
#	used subscript call to show summary data
#
#	Revision 1.11  2001/01/24 03:20:03  david
#	added properties GUI
#	added report menus and display GUI
#
#	Revision 1.10  2000/06/07 02:01:21  david
#	no longer save 0 time days
#
#	Revision 1.9  2000/03/19 09:00:41  david
#	fixed cutoff
#	upped version
#
#	Revision 1.8  2000/02/28 05:26:14  david
#	time timeout is now 5 minutes
#
#	Revision 1.7  2000/02/25 00:58:35  david
#	added cutoff timer
#	added load of rcfile ~/.pclockrc for config params
#
#	Revision 1.6  2000/02/23 22:16:46  david
#	spelling
#	version incr
#
#	Revision 1.5  2000/02/23 22:08:22  david
#	changed redraw behaviour to eliminate grid bug
#
#	Revision 1.4  2000/02/21 23:08:28  david
#	changed to use a single timer
#
#	Revision 1.3  2000/02/08 11:46:43  david
#	added toolbar and labels
#
#	Revision 1.2  2000/02/01 23:22:57  david
#	*** empty log message ***
#
#

# cmdtrace on stderr

set env(LANG) "C"
set env(LC_ALL) "C"

set revision {$Revision: 1.14 $}
set version {0.91}

package provide app-projclock $version

package require Tk

if { ![info exists env(HOME)] } {
  if { ![info exists env(USERPROFILE)] } {
    set env(HOME) $env(USERPROFILE)
  } else {
    set env(HOME) {/}
  }
}

set rundir "[file dirname [info script]]"

if {[info commands infox] == "infox"} {
	# bug in TclX (simply fixed, I think)
	# duplicates last arg - including argv0!
	# a workaround is needed because no-one has the fix
	switch -glob [infox version] {
	{8.2.*} -
	{8.3.[012]} {
		incr argc -1
		set argv [lreplace $argv end end]
	}
	}
}

if {$argc > 0} then {
  set datadir "[lindex $argv 0]"
} else {
  set datadir "$env(HOME)"
}

if {[string length $datadir] > 23} then {
    set wmSubtitle "...[string range $datadir end-20 end]"
} else {
    set wmSubtitle "[lindex [file split $datadir] end]"
}

puts "using data dir $datadir"

set env(PCLOCK_DATADIR) "$datadir"
set env(PATH) "$rundir:$env(PATH)"
set env(PCLOCK_HOME) "$rundir"

set historycount 0
set historylist {}
set startupdefaultproject {}
set pdir "$datadir/.pclock.d"
set pfile "$datadir/.pclock"
set pconfig "$datadir/.pclockrc"

source "$rundir/utilproc.tcl"
source "$rundir/tips.tcl"

if {![catch {open /tmp/pck.trc w} tfd]} {
	puts $tfd "ARGV0: [list $argv0]"
	puts $tfd "ARGV: [list $argv]"
	close $tfd
}

image create photo save_image -file $rundir/filefloppy.gif
image create photo stop_image -file $rundir/stop.gif
image create photo diary_image -file $rundir/quill.gif

# application procs
set rolltime {00:00}
set lockflag 0
# set rolltime {09:24}

proc quit { { code 0 } } {
	exit $code
}

proc cumtime { proj } {
	global timers days
	set ctime 0

	foreach t [array names days "*,$proj"] {
		incr ctime $days($t)
	}
	return $ctime

}

proc rolltimes { day reset } {
	global timers days

	set theday [clock format $day -format {%d-%b-%Y}]

	foreach t [array names timers] {
		set days($theday,$t) $timers($t)
		if { $reset } {
			set timers($t) 0
		}
	}
}

proc diary {} {
	global currentproj pdir
	global db_priv
	if { $currentproj == {} } {
		set myproj [edProject sel]
		if { $myproj == {} } {
			return
		}
	} else {
		set myproj $currentproj
	}
	if {[catch {open "$pdir/[string map {\  _} ${myproj}].txt" r} dfd]} {
		set dtext {}
	} else {
		set dtext [read $dfd]
		close $dfd
	}
	set box .diary
	toplevel $box
	# PopupWindow $box sb_priv
	wm title  $box "Project Diary"
	wm protocol $box WM_DELETE_WINDOW { set db_priv 0 }
	frame $box.f1
	frame $box.f2
	frame $box.f3
	label $box.f1.l -text "Previous entries for '$myproj'"
	label $box.f3.l -text "New entry for '$myproj'"
	text $box.f1.t -font {Courier 8} -width 80 -height 20 -relief sunken -wrap none  -bg white \
		-yscrollcommand "$box.f1.vscroll set" \
		-xscrollcommand "$box.f1.hscroll set" 
	scrollbar $box.f1.vscroll -command "$box.f1.t yview" -relief sunken
	scrollbar $box.f1.hscroll -command "$box.f1.t xview" -relief sunken -orient horizontal
	grid $box.f1.l 
	grid $box.f1.t -row 1 -column 0 -sticky news 
	grid $box.f1.vscroll -row 1 -column 1 -sticky news
	grid $box.f1.hscroll -row 2 -column 0 -sticky news
	grid columnconfigure $box.f1 0 -weight 1
	grid rowconfigure    $box.f1 1 -weight 1

	text $box.f3.t -font {Courier 8} -width 80 -height 10 -relief sunken -wrap none  -bg white \
		-yscrollcommand "$box.f3.vscroll set" \
		-xscrollcommand "$box.f3.hscroll set" 
	scrollbar $box.f3.vscroll -command "$box.f3.t yview" -relief sunken
	scrollbar $box.f3.hscroll -command "$box.f3.t xview" -relief sunken -orient horizontal
	grid $box.f3.l 
	grid $box.f3.t -row 1 -column 0 -sticky news
	grid $box.f3.vscroll -row 1 -column 1 -sticky news
	grid $box.f3.hscroll -row 2 -column 0 -sticky news
	grid columnconfigure $box.f3 0 -weight 1
	grid rowconfigure    $box.f3 1 -weight 1

	button $box.f2.save -text OK -command { set db_priv 1 }
	set_tip $box.f2.save {Save this report in the diary}
	button $box.f2.dismiss -text Cancel -command { set db_priv 0 }
	pack $box.f2.dismiss $box.f2.save -padx 8 -side right
	pack $box.f1 $box.f3 -pady 8 -expand y -fill both
	pack $box.f2 -pady 8 -fill x
	set oldfocus [focus]

	$box.f1.t insert 0.1 $dtext
	$box.f1.t config -state disabled
	update
	# wm deiconify $box
	raise $box
	grab $box
	focus $box
		
	tkwait variable db_priv
	if { $db_priv == 1 } {
		file mkdir "$pdir"
		set newtext [$box.f3.t get 1.0 end]
		
		if {$newtext != {} && ![catch {open "$pdir/[string map {\  _} ${myproj}].txt" a} dfd]} {
			puts $dfd "*** [clock format [clock seconds]] ***"
			puts $dfd $newtext
			close $dfd
		}
	}
	destroy $box
	focus $oldfocus
	return 0
}

proc loaddb {} {
	global pfile timers final days lastsave rolltime currentproj lockflag env
	global historymenu historypos historycount startupdefaultproject

	set thefile [tk_getOpenFile -initialdir $env(HOME) -defaultextension {.pck} -filetypes {{{Clock Database} {.pck}}}]
	if { $thefile == {} } {
		return
	}
	loadfile $thefile
	$historymenu insert $historypos command -label [file tail $thefile] -command "loadfile $thefile"
	incr historycount
	if {$historycount > 5} {
		$historymenu delete 10
		incr historycount -1
	}
}

proc loadfile { thefile } {
	global pfile timers final days lastsave rolltime currentproj lockflag env wmSubtitle startupdefaultproject
	if { $thefile == "$pfile" } {
		return
	}
	set lockflag 1
	set currentproj {}
	wm title . "WorkerTimer ($wmSubtitle)"
	save {}
	set pfile $thefile
	catch {unset timers}
	catch {unset days}
	catch {unset final}
	catch {unset lastsave}

	uplevel #0 source $pfile
	updateDisplay
	set lockflag 0
}

proc saveas {} {
    global env
	set thefile [tk_getSaveFile -initialdir $env(HOME) -defaultextension {.pck} -filetypes {{{Clock Database} {.pck}}}]
	if { $thefile != {} } {
		save $thefile
	}
}

proc savestate {} {
	global pstate 
	global historymenu historypos historycount startupdefaultproject

	if {[catch {open ${pstate}.tmp w} pfd]} {
		Warn $pfd
		return
	}

	set hlist {}
	
	for {set i $historypos} {$i < $historypos + $historycount} {incr i} {
		lappend hlist [$historymenu entrycget $i -command]
	}
 
	puts $pfd "set historylist [list $hlist]"
	puts $pfd "set startupdefaultproject [list $startupdefaultproject]"
	close $pfd

	catch {file rename -force $pstate ${pstate}.bak}
	catch {file rename -force ${pstate}.tmp ${pstate}}
}

proc save { file } {
	global pfile timers final days lastsave rolltime
	set midnight [clock scan $rolltime]
	set checktime [clock seconds]

	if { $file == {} } {
		set file $pfile
	}

	if { $lastsave < $midnight && $checktime >= $midnight } {
		rolltimes $lastsave 1
	}

	if {[catch {open ${file}.tmp w} pfd]} {
		Warn $pfd
		return
	}
	
	foreach t [array names timers] {
		puts $pfd "set [list timers($t)] $timers($t)"
	}

	foreach t [array names final] {
		puts $pfd "set [list final($t)] [list $final($t)]"
	}

	foreach t [array names days] {
		if { $days($t) != 0 } {
			puts $pfd "set [list days($t)] [list $days($t)]"
		}
	}

	set lastsave $checktime
	puts $pfd "set lastsave $lastsave"
	close $pfd

	catch {file delete -force ${file}.bak}
	catch {file rename -force $file ${file}.bak}
	catch {file rename -force ${file}.tmp ${file}}
	if { $file == "$pfile" } {
		updateAllTimers
	}
}

proc edProject { op } {
	global timers final buttons tlabels
	switch -exact $op {
	{add} {
		set newname [EntryBox .pname "New Project Name"]
		if {$newname == {}} {
			return
		} elseif {![info exists timers($newname)]} {
			set timers($newname) 0
		} else {
			Warn "Project '$newname' already exists!"
			return
		}
	}
	{del} {
		set oldname [SLBBox .plist "Project to Delete" [lsort [array names timers]]]
		if {$oldname == {}} {
			return
		} elseif {[info exists timers($oldname)]} {
			lappend final($oldname) $timers($oldname)
			unset timers($oldname)
		} else {
			Warn "Project '$oldname' has no info!"
			return
		}
	}
	{sel} {
		set oldname [SLBBox .plist "Choose Project" [lsort [array names timers]]]
		if {$oldname == {}} {
			return {}
		} else {
			return $oldname
		}
	}
	}
	updateDisplay
}

proc edProps {} {
	global pp_ctl factor cycles mycycles pconfig pdir
	set box .props
	# PopupWindow .props pp_ctl
	toplevel $box
	wm transient $box .
	wm title  $box "Properties"
	wm protocol $box WM_DELETE_WINDOW "set pp_ctl 0"
	array set mycycles [array get cycles]
	
	# parray cycles
	# parray mycycles
	frame $box.f1
	frame $box.f2

	label $box.f1.l1 -text "End of day (HH:MM)"
	entry $box.f1.e1 -textvariable mycycles(endofday)
	grid $box.f1.l1 $box.f1.e1 -sticky w
	
	label $box.f1.l2 -text "Day length (h or hh:mm)"
	entry $box.f1.e2 -textvariable mycycles(workday)
	grid $box.f1.l2 $box.f1.e2 -sticky w
	
	label $box.f1.l3 -text "Autosave period (s)"
	entry $box.f1.e3 -textvariable mycycles(save)
	grid $box.f1.l3 $box.f1.e3 -sticky w
	
	label $box.f1.l4 -text "Timer period (ms)"
	entry $box.f1.e4 -textvariable mycycles(timer)
	grid $box.f1.l4 $box.f1.e4 -sticky w

	label $box.f1.l5 -text "Diary directory"
	entry $box.f1.e5 -textvariable pdir
	grid $box.f1.l5 $box.f1.e5 -sticky w

	button $box.f2.apply -text Apply -command { set pp_ctl 1 }
	set_tip $box.f2.apply {Apply these properties to current session}
	button $box.f2.save -text Save -command { set pp_ctl 2 }
	set_tip $box.f2.save {Apply then save these properties}
	button $box.f2.dismiss -text Cancel -command { set pp_ctl 0 } 
	pack $box.f2.dismiss $box.f2.save $box.f2.apply -padx 8 -side right
	pack $box.f1 $box.f2 -pady 8
	set oldfocus [focus]

	update
	# wm deiconify $box
	raise $box
	grab $box
	focus $box.f1.e1
		
	tkwait variable pp_ctl
	destroy $box
	focus $oldfocus
	if { $pp_ctl > 0 } {
		if { $pp_ctl == 2 } {
			if { [catch {open $pconfig a} pfd] } {
				Warn $pfd
				return 0
			}
			puts $pfd "# config update: [clock format [clock seconds]]"
			puts $pfd "array set factor [list [array get factor]]"
			puts $pfd "array set cycles [list [array get mycycles]]"
			close $pfd
		}
		array set cycles [array get mycycles]
		return 1
	} else {
		return 0
	}
}

proc Summarise { what } {
	global tcl_platform env pfile
	set summaryprog "$env(PCLOCK_HOME)/summary.tcl"
	if {[info exists env(TZ)]} {
		set mytz $env(TZ)
	}
	set env(TZ) UTC
	switch -exact $what {
	{current} {
		ShowSummary [subscript $summaryprog -T -i $pfile ]
	}
	{detail} {
		ShowSummary [subscript $summaryprog -v -i $pfile ]
	}
	{current_week} {
		ShowSummary [subscript $summaryprog -T -d "[clock format [clock scan "last monday"] -format "%d/%h/%Y"]-" -i $pfile ]
	}
	{detail_week} {
		ShowSummary [subscript $summaryprog -v -d "[clock format [clock scan "last monday"] -format "%d/%h/%Y"]-" -i $pfile ]
	}
	{last} {
		ShowSummary [subscript $summaryprog -T -d "[clock format [clock scan "last month"] -format {%h/%Y}]" -i $pfile]
	}
	{detail_last} {
		ShowSummary [subscript $summaryprog -v -d "[clock format [clock scan "last month"] -format {%h/%Y}]" -i $pfile]
	}
	{last_week} {
		set scanbase [clock scan "last sunday"]
        set starttime [clock scan "last monday" -base $scanbase]
		ShowSummary [subscript $summaryprog -T -d "[clock format $starttime -format "%d/%h/%Y"]-[clock format $scanbase -format "%d/%h/%Y"]" -i $pfile]
	}
	{detail_last_week} {
		set scanbase [clock scan "last sunday"]
        set starttime [clock scan "last monday" -base $scanbase]
		ShowSummary [subscript $summaryprog -v -d "[clock format $starttime -format "%d/%h/%Y"]-[clock format $scanbase -format "%d/%h/%Y"]" -i $pfile ]
	}
	{help} {
		ShowSummary [subscript $summaryprog -H]
	}
	{project} {
		set selproj [edProject sel]
		if { $selproj != {} } {
			ShowSummary [subscript $summaryprog -T -v $selproj -i $pfile ]
		}
	}
	{custom} {
		set summaryargs [EntryBox .sargs "Summary params"]
		if {[catch "subscript [list $summaryprog] $summaryargs" result]} {
			Warn $result
		} else {
			ShowSummary $result
		}
	}
	}
	if {[info exists mytz]} {
		set env(TZ) $mytz
	} else {
		unset env(TZ)
	}
}

proc SaveSummary {} {
	set sfn [tk_getSaveFile -title {Save Summary} -defaultextension txt]
	if { $sfn == {} } {
		return
	}

	if {[catch {open $sfn w} sfd]} {
		Warn $sfd
		return
	}
	puts $sfd [.summary.f1.t get 1.0 end]
	close $sfd
}

proc ShowSummary { data } {
	global sb_priv
	set box .summary
	toplevel $box
	# PopupWindow $box sb_priv
	wm title  $box "Project Summaries"
	wm protocol $box WM_DELETE_WINDOW { set sb_priv 1 }
	frame $box.f1
	frame $box.f2
	text $box.f1.t -font {Courier 10} -width 50 -height 24 -relief sunken -wrap none  -bg white \
		-yscrollcommand "$box.f1.vscroll set" \
		-xscrollcommand "$box.f1.hscroll set" 
	scrollbar $box.f1.vscroll -command "$box.f1.t yview" -relief sunken
	scrollbar $box.f1.hscroll -command "$box.f1.t xview" -relief sunken -orient horizontal
	grid $box.f1.t -row 0 -column 0 -sticky news
	grid $box.f1.vscroll -row 0 -column 1 -sticky ns
	grid $box.f1.hscroll -row 1 -column 0 -sticky ew
    grid rowconfigure    $box.f1 0 -weight 1
    grid columnconfigure $box.f1 0 -weight 1

	button $box.f2.save -text Save... -command { SaveSummary }
	set_tip $box.f2.save {Save this report in a text file}
	button $box.f2.dismiss -text Dismiss -command { set sb_priv 1 }
	pack $box.f2.dismiss $box.f2.save -padx 8 -side right

	pack $box.f1 -pady 8 -expand y -fill both
	pack $box.f2 -pady 8 -expand n -fill x
    
	set oldfocus [focus]

	$box.f1.t insert 0.1 $data
	update
	# wm deiconify $box
	raise $box
	grab $box
	focus $box
		
	tkwait variable sb_priv
	destroy $box
	focus $oldfocus
	return 0
}

proc TimedBoxUD { box } {
	global tb_timer tb_priv tb_tid
	incr tb_timer -1
	$box.f1.t config -text "[expr $tb_timer / 60]m [expr $tb_timer % 60]s"
	if { $tb_timer <= 0 } {
		set tb_priv 0
	} else {
		set tb_tid [after 1000 "TimedBoxUD $box"]
	}
}

proc edDay {} {
	set thesecs -1
	while { $thesecs == -1 } {
		set theday [EntryBox .pdate "Date (yyyy-mm-dd):"]
		if { $theday == {} } {
			return
		}
		if {[catch {clock scan $theday} thesecs]} {
			Warn $thesecs
			set thesecs -1
		}
	}
	EditDayList .daybox "Edit Day: $theday" $thesecs
	updateAllTimers
}

proc EditDayList { box label date} {
	global tb_priv tb_optionval days timers ed_timers ed_tlabels
	toplevel $box
	wm transient $box .
	wm title $box "Edit Day"
	wm protocol $box WM_DELETE_WINDOW { set tb_priv 0 }
	set theday [clock format $date -format {%d-%b-%Y}]
	frame $box.f1
	frame $box.f2
	set main $box.f1

	label $main.title1 -text Project -relief ridge -bd 2 -width 16
	label $main.title2 -text Times -relief ridge -bd 2
	label $main.total1 -text Total 
	label $main.total2 -text {}
	set_tip $main.total2 "Total recorded time for [clock format $date -format {%d %b %Y}]."
	grid $main.title1 $main.title2 -sticky ew
	grid $main.total1 $main.total2 -sticky ew

	set next 0

	foreach projname [lsort [array names timers]] {
		if {[info exists days($theday,$projname)]} {
			set p $theday,$projname
			set ed_timers($projname) $days($p)
		} else {
			set ed_timers($projname) 0
			set p {}
		}
		set fmttime	"[clock format $ed_timers($projname) -format {%H:%M:%S} -gmt 1]"
		set i [incr next]
		set ed_p($projname) [label $main.b$i -text $projname -anchor w -relief raised]
		bind $ed_p($projname) <1> [list fixtimeEd $projname]
		set_tip $ed_p($projname) "Click to for adjustment popup."
		set ed_tlabels($projname) [label $main.l$i -width 16 -text $fmttime -anchor w]
		set_tip $ed_tlabels($projname) "Day's time on '$projname'"
		grid $ed_p($projname) $ed_tlabels($projname) -sticky ew
	}

    grid columnconfigure $main 0 -weight 1
    
	button $box.f2.ok -text OK -command { set tb_priv 1 }
	button $box.f2.cancel -text Cancel -command { set tb_priv 0 }
	pack $box.f2.cancel $box.f2.ok -padx 8 -side right
	pack $box.f1 -pady 8 -expand y -fill both
	pack $box.f2 -pady 8 -expand n -fill x
	set oldfocus [focus]
	update
	raise $box
	grab $box
	focus $box
		
	tkwait variable tb_priv
	destroy $box
	focus $oldfocus
	if { $tb_priv == 1 } {
		foreach n [array names ed_timers] {
			if { $ed_timers($n) > 0 } {
				set days($theday,$n) $ed_timers($n)
			}
		}
		return 1
	} else {
		return 0
	}
}


proc TimedBox { box label timeout } {
	global tb_priv tb_optionval tb_timer tb_tid
	toplevel $box
	wm transient $box .
	wm protocol $box WM_DELETE_WINDOW { set tb_priv 0 }
	set tb_timer $timeout
	wm title $box "Timed Question"
	frame $box.f1
	frame $box.f2
	label $box.f1.l -text "$label" -anchor w
	label $box.f1.t -text "[expr $timeout / 60]m [expr $timeout % 60]s" -anchor w
	pack $box.f1.l $box.f1.t -side top

	button $box.f2.ok -text Yes -command { set tb_priv 1 }
	button $box.f2.cancel -text No -command { set tb_priv 0 }
	pack $box.f2.cancel $box.f2.ok -padx 8 -side right
	pack $box.f1 $box.f2 -pady 8
	set oldfocus [focus]
	set tb_tid [after 1000 "TimedBoxUD $box"]
	update
	raise $box
	grab $box
	focus $box
		
	tkwait variable tb_priv
	set tb_timer 0
	after cancel $tb_tid
	destroy $box
	focus $oldfocus
	if { $tb_priv == 1 } {
		return 1
	} else {
		return 0
	}
}

proc ChangeBox { box label choices } {
	global cb_priv cb_optionval
	toplevel $box
	wm transient $box .
	wm title $box $label
	wm protocol $box WM_DELETE_WINDOW { set cb_priv 0 }
	frame $box.f1
	frame $box.f2
	label $box.f1.l -text "$label"
	entry $box.f1.t -width 5
	bindtags $box.f1.t {Numeric Entry .}
	eval tk_optionMenu $box.f1.e cb_optionval $choices
	pack $box.f1.l $box.f1.t $box.f1.e -side left

	button $box.f2.ok -text OK -command { set cb_priv 1 }
	button $box.f2.cancel -text Cancel -command { set cb_priv 0 }
	pack $box.f2.cancel $box.f2.ok -padx 8 -side right
	pack $box.f1 $box.f2 -pady 8
	set oldfocus [focus]
	update
	grab $box
	focus $box.f1.t

	tkwait variable cb_priv
	set val [list [$box.f1.t get] $cb_optionval]
	destroy $box
	focus $oldfocus
	if { $cb_priv == 1 } {
		return $val
	} else {
		return {}
	}
}

proc fixtime { proj } {
	global timers

	set change [ChangeBox .ptime "Update '$proj' Time" {hours mins secs}]
	if { $change == {} } return
	set dtime [lindex $change 0]
	set mytime $timers($proj)
	switch -glob [lindex $change 1] {
	{hours} {
		set mytime [expr $mytime + ($dtime * 3600)]
	}
	{mins} {
		set mytime [expr $mytime + ($dtime * 60)]
	}
	{secs} {
		set mytime [expr $mytime + $dtime]
	}
	}
	if { $mytime >= 0 } {
		set timers($proj) $mytime
		showTimer $proj
	}
}
		
proc fixtimeEd { proj } {
	global ed_timers 

	set change [ChangeBox .ptime "Update '$proj' Time" {hours mins secs}]
	if { $change == {} } return
	set dtime [lindex $change 0]
	set mytime $ed_timers($proj)
	switch -glob [lindex $change 1] {
	{hours} {
		set mytime [expr $mytime + ($dtime * 3600)]
	}
	{mins} {
		set mytime [expr $mytime + ($dtime * 60)]
	}
	{secs} {
		set mytime [expr $mytime + $dtime]
	}
	}
	if { $mytime >= 0 } {
		set ed_timers($proj) $mytime
		showEdTimer $proj
	}
}
		

proc showEdTimer { theproj } {
	global ed_timers ed_tlabels 

	if { $theproj != {} && [info exists ed_timers($theproj)]} {
		set hours  $ed_timers($theproj)
		$ed_tlabels($theproj) config -text "[clock format $hours -format {%H:%M:%S} -gmt 1]"
	}
	set total2 0
	foreach t [array names ed_timers] {
		incr total2 $ed_timers($t)
	}
	.daybox.f1.total2 config -text "[clock format $total2 -format {%H:%M:%S} -gmt 1]"
}

proc showTimer { theproj } {
	global timers currentproj buttons next tlabels cycles

	if { $theproj != {} && [info exists timers($theproj)]} {
		set hours  $timers($theproj)
		$tlabels($theproj) config -text "[clock format $hours -format {%H:%M:%S} -gmt 1]"
		wm title . "[clock format $hours -format {%H:%M:%S} -gmt 1] - $currentproj"
	}
	set total2 0
	foreach t [array names timers] {
		incr total2 $timers($t)
	}
	.main.total2 config -text "[clock format $total2 -format {%H:%M:%S} -gmt 1]"
}

proc updateTimer {} {
	global timers currentproj buttons next tlabels cycles wmSubtitle
	global lasttick lastsave cuts

	set theproj $currentproj
	set cutoff [clock scan $cycles(endofday)]
	if { $currentproj != {} && ( [clock seconds] > ($cutoff + $cuts) ) } {
		if {[TimedBox .timer {End of day! Continue working?} [expr 5 * 60]]} {
			set cuts [expr ([clock seconds] - $cutoff) + (10 * 60)]
			# puts stderr "Next EOD check: [clock format [expr $cutoff + $cuts]]"
			# report "Next EOD check: [clock format [expr $cutoff + $cuts]]"
		} else {
			set currentproj {}
			set theproj {}
			set cuts 0
			report "Timers stopped at end of day"
			wm title . "WorkerTimer ($wmSubtitle)"
		}
	}

	set diff [expr [set now [clock seconds]] - $lasttick]
	set sdiff [expr $now - $lastsave]
	set lasttick $now
	if { $theproj != {} && [info exists timers($theproj)]} {
		incr timers($theproj) $diff
		# report {}
		showTimer $theproj
	} else {
		set currentproj {}
		wm title . "WorkerTimer ($wmSubtitle)"
	}

	if { $sdiff >= $cycles(save) } {
		save {}
	}

	after $cycles(timer) updateTimer
}

proc updateSave {} {
	global cycles lockflag
	if { !$lockflag } {
		save {}
	}
	after $cycles(save) updateSave
}
	

proc updateDisplay {} {
	global timers currentproj buttons next tlabels dlabels
	foreach b [array names buttons] {
		grid forget $buttons($b) $tlabels($b) $dlabels($b)
		if {![info exists timers($b)]} {
			unset buttons($b)
			unset tlabels($b)
			unset dlabels($b)
		}
	}
	
	foreach p [lsort [array names timers]] {
		if {![info exists buttons($p)]} {
			set i [incr next]
			set buttons($p) [radiobutton .main.b$i -indicatoron false -variable currentproj -value $p -text $p -anchor w -selectcolor "#fdb913"]
			bind $buttons($p) <3> [list fixtime $p]
			set_tip $buttons($p) "Left-click to resume timer; right-click for adjustment popup."
			set tlabels($p) [label .main.l$i -width 16 -text {} -anchor w]
			set_tip $tlabels($p) "Today's time on '$p'"
			set dlabels($p) [label .main.d$i -width 16 -text {} -anchor w]
			set_tip $dlabels($p) "Total time on '$p' as at last rollover."
		}
		grid $buttons($p) $tlabels($p) $dlabels($p) -sticky ew
	}
	updateAllTimers
	wm geometry . {}
}

proc updateAllTimers {} {
	global timers currentproj buttons next tlabels dlabels cycles
	foreach t [array names timers] {
		set ctime [cumtime $t]
		set daylen [expr 8 * 60 * 60]
		if {[string match "*\[0-9\].\[0-9\]*" $cycles(workday)]} then {
		    set daylen [expr round($cycles(workday) * 60 * 60)]
		} else {
		    set daylen [clock scan $cycles(workday) -base 0 -gmt 1]
		}
		set cdays [expr $ctime / $daylen]
		set chours [expr $ctime % $daylen]
		$tlabels($t) config -text "[clock format $timers($t) -format {%H:%M:%S} -gmt 1]"
		$dlabels($t) config -text "${cdays}d [clock format $chours -format {%H:%M:%S} -gmt 1]"
	}
}

# Menu Creation Procs
proc AboutBox {} {
	global revision version
	Info "WorkerTimer V$version ($revision)\n(used to be Project Clock)\n(c)2000 David Keeffe"
}

proc HelpBox {} {
	Info "Hold your mouse over a button and wait for a tip.\nThat's all so far, folks!"
}

proc CheckSave {} {
	rolltimes [clock seconds] 0
	save {}
	savestate
	return
}

proc editMakeMenu { menu } {
	$menu add command -label {Add Project...} -command {edProject add}
	$menu add command -label {Delete Project...} -command {edProject del}
	$menu add command -label {Update Today} -command {CheckSave}
	$menu add separator
	$menu add command -label {Stop Timers} -command {set currentproj {}}
	$menu add command -label {Set active Timer as Default} -command {set startupdefaultproject $currentproj; report "Default timer: $startupdefaultproject"}
	$menu add command -label {Show Default Timer} -command {report "Default timer: $startupdefaultproject"}
	$menu add separator
	$menu add command -label {Edit Day...} -command {edDay}
	$menu add separator
	$menu add command -label {Properties...} -command {edProps}

}

proc viewMakeMenu { menu } {
	$menu add command -label {This month summary} -command {Summarise current}
	$menu add command -label {This month detail} -command {Summarise detail}
	$menu add command -label {This week summary} -command {Summarise current_week}
	$menu add command -label {This week detail} -command {Summarise detail_week}
	$menu add command -label {Last month summary} -command {Summarise last}
	$menu add command -label {Last month detail} -command {Summarise detail_last}
	$menu add command -label {Last week summary} -command {Summarise last_week}
	$menu add command -label {Last week detail} -command {Summarise detail_last_week}
	$menu add command -label {Project detail} -command {Summarise project}
	$menu add command -label {Custom report} -command {Summarise custom}
	$menu add command -label {Usage for custom report} -command {Summarise help}
}

proc fileMakeMenu { menu } {
	global pfile historymenu historypos historylist historycount
	$menu add command -label {Save Data} -command {save {}}
	$menu add command -label {Save as...} -command {saveas}
	$menu add command -label {Save App State} -command {savestate}
	$menu add command -label {Load default DB} -command "loadfile $pfile"
	$menu add command -label {Load time DB...} -command {loaddb}
	$menu add separator
	set historypos 6
	set historymenu $menu 
	foreach h $historylist {
		$menu add command -label [file tail [lindex $h 1]] -command "$h"
		incr historycount
		if {$historycount >= 5} {
			break;
		}
	}
	$menu add separator
	$menu add command -label {Exit...} -command {ExitOK}
}

proc helpMakeMenu { menu } {
	$menu add command -label {About...} -command {AboutBox}
	$menu add command -label {Help...} -command {HelpBox}
}


# main body here
wm protocol . WM_DELETE_WINDOW {ExitOK}
wm protocol . WM_SAVE_YOURSELF {CheckSave}
wm title . "WorkerTimer ($wmSubtitle)"
tk appname projclock.tcl

set cycles(workday) 8
set cycles(endofday) 18:30
set cycles(save) 120
set cycles(timer) 1000
array set timers {}
array set final {}
array set days {}
set cuts 0
set next 1
set currentproj {}
set checktime [clock seconds]
set lastsave $checktime

if {[file readable $pconfig]} {
	catch {source $pconfig}
}

catch {file mkdir $pdir}
set pstate $pdir/.state
catch {source $pstate}
catch {set currentproj $startupdefaultproject}

if {[file readable $pfile]} {
	source $pfile
}

MakeMenubar {} {File View Edit}

frame .toolbar
pack .toolbar -side top -fill both
label .toolbar.xx -text " "
label .toolbar.yy -text " "
label .toolbar.zz -text " "
label .toolbar.aa -text " "
button .toolbar.stoptimers -image stop_image -command {set currentproj {}}
set_tip .toolbar.stoptimers "Stop all timers."
button .toolbar.save -image save_image -command {save {}}
set_tip .toolbar.save "Save current state."
button .toolbar.diary -image diary_image -command {diary}
set_tip .toolbar.diary "Record diary entry for selected project."
# button .toolbar.tips -image refresh_image -command {RedrawAll}
# set_tip .toolbar.tips "Toggle tips"

foreach b {save xx stoptimers yy diary} {
        pack .toolbar.$b -side left
}


frame .main -width 300
pack .main -side top  -expand y -fill both

MakeMessageArea
# handle options

label .main.title1 -text Project -relief ridge -bd 2 -width 16
label .main.title2 -text Today -relief ridge -bd 2
label .main.title3 -text {To Date} -relief ridge -bd 2
label .main.total1 -text Total 
label .main.total2 -text {}
set_tip .main.total2 {Total recorded time for today.}
label .main.total3 -text {}
grid .main.title1 .main.title2 .main.title3 -sticky ew
grid .main.total1 .main.total2 .main.total3 -sticky ew
grid columnconfigure .main 0 -weight 1
updateDisplay
catch {signal trap {2 1} {CheckSave; quit}}

save {}
set lasttick [clock seconds]
updateTimer
showTimer {}

# do the real stuff here


