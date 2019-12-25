# boilerplate
#
# Utility procedures
#
# David Keeffe
# Raster Solutions P/L
#
# $Id: utilproc.tcl,v 1.4 2004/03/17 22:13:03 root Exp $

# History:
#	$Log: utilproc.tcl,v $
#	Revision 1.4  2004/03/17 22:13:03  root
#	added sub-interpreter stuff
#
#	Revision 1.3  2000/02/25 04:34:07  david
#	added dbputs
#
#	Revision 1.2  2000/02/01 23:23:03  david
#	added Numeric bindtag
#	NumberBox
#	Info proc
#
#

set debuglevel 0
proc dbputs { level msg } {
	global debuglevel

	if { $debuglevel >= $level } {
		puts stderr $msg
	}
}

proc PopupWindow { win ctlvar } {
	toplevel $win
	wm withdraw $win
	wm transient $win [winfo toplevel [winfo parent $win]]
	wm protocol $win WM_DELETE_WINDOW "set $ctlvar 0"
	update idletasks
	set pos [winfo pointerxy $win]
	wm geom $win +[lindex $pos 0]+[lindex $pos 1]
	return $win
}

proc OldMakeMenubar { {w {}} { items {File Edit} } } {
        frame $w.menuframe -relief raised -bd 2
        pack $w.menuframe -side top -fill both
	foreach item $items {
		set tag [string tolower $item]
		menubutton $w.menuframe.$tag -text "$item" -underline 0 \
			-menu $w.menuframe.$tag.m
		MakeMenu $w.menuframe.$tag $tag
		pack $w.menuframe.$tag -side left -padx 3
		lappend menuitems $w.menuframe.$tag
	}

	set item Help
	set tag help

	menubutton $w.menuframe.$tag -text "$item" -underline 0 \
		-menu $w.menuframe.$tag.m
	MakeMenu $w.menuframe.$tag $tag
        pack $w.menuframe.$tag -side right -padx 3
	lappend menuitems $w.menuframe.$tag

        eval tk_menuBar $w.menuframe [join $menuitems]
}

proc MakeMenubar { {w {}} { items {File Edit} } } {
        menu $w.menuframe 
	foreach item $items {
		set tag [string tolower $item]
		MakeMenu $w.menuframe.$tag $tag
		$w.menuframe add cascade -menu $w.menuframe.$tag -label $item
		lappend menuitems $w.menuframe.$tag
	}

	set item Help
	set tag help

	MakeMenu $w.menuframe.$tag $tag
	$w.menuframe add cascade -menu $w.menuframe.$tag -label $item
	lappend menuitems $w.menuframe.$tag
	if { $w == {} } {
		. config -menu $w.menuframe
	} else {
		$w config -menu $w.menuframe
	}
}

proc MakeMenu { menu item } {
	menu $menu -tearoff 0
	if { [info procs ${item}MakeMenu] != {} } {
		${item}MakeMenu $menu
	}
}

proc OldMakeMenu { menu item } {
	menu $menu.m
	if { [info procs ${item}MakeMenu] != {} } {
		${item}MakeMenu $menu.m
	}
}

proc helpMakeMenu { menu } {
	$menu add command -label {About...}
	$menu add command -label {To Come...}
}

proc Confirm { msg } {
	set answer [tk_messageBox -message "$msg" -icon question -title Confirm -type yesno]
	if { $answer == "yes" } { return 1 } else { return 0 }

}

proc Info { msg } {
	tk_messageBox -message "$msg" -icon info -title Info -type ok
}

proc Warn { msg } {
	tk_messageBox -message "$msg" -icon warning -title Warning -type ok
}

proc ExitOK {} {
	CheckSave
	if [Confirm "Do you really want to exit?"] { quit 0 }
}

# useful elements

# scrolling list box

proc slb { { fr .f } lab } {
	frame $fr -borderwidth 10

	message $fr.m -text "$lab" -aspect 400
	scrollbar $fr.s -relief sunken -command "$fr.l yview"
	listbox $fr.l -yscroll "$fr.s set" -relief sunken -setgrid 1

	pack $fr.m -side top
	pack $fr.s -side right -fill y
	pack $fr.l -side left -expand yes -fill both
	pack $fr -side left
}


proc ChoiceBox { box label choices } {
	global eb_priv cb_optionval
	toplevel $box
	wm title $box "$label"
	wm protocol $box WM_DELETE_WINDOW { set eb_priv 0 }
	frame $box.f1
	frame $box.f2
	label $box.f1.l -text "$label"
	eval tk_optionMenu $box.f1.e cb_optionval $choices
	pack $box.f1.l $box.f1.e -side left

	button $box.f2.ok -text OK -command { set eb_priv 1 }
	button $box.f2.cancel -text Cancel -command { set eb_priv 0 }
	pack $box.f2.ok $box.f2.cancel -padx 8 -side left
	pack $box.f1 $box.f2 -pady 8
	set oldfocus [focus]
	grab $box
	focus $box

	tkwait variable eb_priv
	set val $cb_optionval
	destroy $box
	focus $oldfocus
	if { $eb_priv == 1 } {
		return $val
	} else {
		return {}
	}
}

proc SLBBox { box label items } {
	global eb_priv
	toplevel $box
	wm title $box "$label"
	wm protocol $box WM_DELETE_WINDOW { set eb_priv 0 }
	frame $box.f1
	frame $box.f2
	slb $box.f1.e $label
	eval $box.f1.e.l insert end $items
	pack $box.f1.e -side top
	set val {}

	button $box.f2.ok -text OK -command { set eb_priv 1 }
	button $box.f2.cancel -text Cancel -command { set eb_priv 0 }
	pack $box.f2.ok $box.f2.cancel -padx 8 -side left
	pack $box.f1 $box.f2 -pady 8
	set oldfocus [focus]
	grab $box
	focus $box

	tkwait variable eb_priv
	set sel [$box.f1.e.l curselection]
	if { $sel != {} } {
		set val [$box.f1.e.l get $sel]
	}
	destroy $box
	focus $oldfocus
	if { $eb_priv == 1 } {
		return $val
	} else {
		return {}
	}
}

# simple binding which only lets decimal numbers through

bind Numeric <Any-Key> {
        if { "%A" == "{}" || [string match {[0-9]} %A] || "%A" == "-" || "%A" < " " || "%A" == "\177" } {
                continue
        } else {
                break
        }
}

proc NumberBox { box label } {
	return [EntryBox $box $label { Numeric Entry . }]
}

proc EntryBox { box label  { binding {} }} {
	global eb_priv
	PopupWindow $box eb_priv

	wm title $box "Enter Value"
	frame $box.f1
	frame $box.f2
	label $box.f1.l -text "$label"
	entry $box.f1.e -width 32 -relief sunken
	if { $binding != {} } {
		bindtags $box.f1.e $binding
	}
	bind $box.f1.e <Return> "$box.f2.ok invoke"
	pack $box.f1.l $box.f1.e -side left

	button $box.f2.ok -text OK -command { set eb_priv 1 }
	button $box.f2.cancel -text Cancel -command { set eb_priv 0 }
	pack $box.f2.ok $box.f2.cancel -padx 8 -side left
	pack $box.f1 $box.f2 -pady 8
	set oldfocus [focus]
	wm deiconify $box
	grab $box
	focus $box.f1.e

	tkwait variable eb_priv
	set val [$box.f1.e get]
	destroy $box
	focus $oldfocus
	if { $eb_priv == 1 } {
		return $val
	} else {
		return {}
	}
}

proc MakeMessageArea { { win {} } } {
	frame $win.msg
	label $win.msg.l -relief ridge -bd 2 -anchor w 
	label $win.msg.i -relief ridge -bd 2 -anchor e -width 10
	pack $win.msg.l -side left -fill x -expand y -anchor w
	pack $win.msg.i -side right -fill x -expand n -anchor e

	pack $win.msg -side bottom -fill x -expand y -anchor s
}

proc minfo { msg } {
	.msg.i config -text $msg
	update
}

proc report { msg } {
	dbputs 1 "REPORT: $msg"
	.msg.l config -text $msg
	update
}

# Menu Creation Procs

proc defvar { var default } {
	upvar $var myvar
	if {!([info exists myvar] && $myvar != {})} {
		set myvar $default
	}
	return $myvar
}

if { $tcl_platform(platform) == "windows" } {
	package require registry
}

proc runprog { prog args } {
	global tcl_platform
	dbputs 2 "runprog: $prog $args"
	if { $tcl_platform(platform) == "unix" } {
		return [eval exec $prog $args]
	} elseif { $tcl_platform(platform) == "windows" } {
		set ext [file extension $prog]
		if { $ext == {} } {
			set ext .tcl
			set prog $prog$ext
		}
		set key [registry get HKEY_CLASSES_ROOT\\$ext {}]
		set command [registry get HKEY_CLASSES_ROOT\\$key\\shell\\open\\command {}]
		regsub -all {\\} $command {/} command
		regsub -all {%1} $command $prog command
		regsub -all {%\*} $command {} command
		if { [auto_load winexec] } {
			set runner winexec
			regsub {& *$} $args {} args
			dbputs 2 "using winexec - '$command' + '$args'"
		} else {
			set runner exec
			dbputs 2 "using plain exec - '$command' + '$args'"
		}
		if { $command != {} } {
			return [eval $runner $command $args]
		} else {
			return [eval $runner $prog $args]
		}
	}
}

proc mangle { input } {
	regsub -all {%} $input {%25} input
	regsub -all "{" $input {%7B} input
	regsub -all "}" $input {%7D} input
	regsub -all {\+} $input {%2B} input
	regsub -all {:} $input {%3A} input
	regsub -all {"} $input {%22} input
	regsub -all {'} $input {%27} input
	regsub -all {/} $input {%2F} input
	regsub -all "\n" $input {%0A} input
	regsub -all "\r" $input {%0D} input
	regsub -all {=} $input {%3D} input
	regsub -all {\?} $input {%3F} input
	regsub -all {&} $input {%26} input
	regsub -all { } $input {%20} input
	return [join $input {}]
}
 
proc gather { args } {
	global buffer
	set first 0
	set nonewline 0
	if {[string match {-nonewline} [lindex $args $first]]} {
		set nonewline 1
		set args [lrange $args 1 end]
	}
	set data [lindex $args end]
	switch -exact [llength $args] {
	{0} {
		error "missing string"
	}
	{1} {
		append buffer(stdout) $data
		if { !$nonewline } {
			append buffer(stdout) "\n"
		}
	}
	{2} {
		append buffer([lindex $args 0]) $data
		if { !$nonewline } {
			append buffer([lindex $args 0]) "\n"
		}
	}
	}
}

proc subscript {file args} {
	global buffer
	catch {interp delete sinterp}
	interp create sinterp

	sinterp alias puts gather
	sinterp alias exit return
	catch {unset buffer}

	set cmdframe {
		set argv0 "$file"
		set argv {}
		set argv [list $args]
		set argc [llength [set argv]]
		source "$file"
	}

	set res [sinterp eval [subst -nocommand -nobackslash $cmdframe]]
	interp delete sinterp
	if { [info exists buffer(stderr)] } {
		error $buffer(stderr)
	}
	return $buffer(stdout)
}

#END 
