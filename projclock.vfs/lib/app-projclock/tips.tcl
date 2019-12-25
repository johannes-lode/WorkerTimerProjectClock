#
# tooltip/balloon help utility
#
# David Keeffe
# Raster Solutions P/L
#
# $Id: tips.tcl,v 1.3 2001/01/24 02:56:59 david Exp $

# History:
#	$Log: tips.tcl,v $
#	Revision 1.3  2001/01/24 02:56:59  david
#	added check for existence of window before firing timer
#
#	Revision 1.2  2001/01/08 21:14:39  david
#	ridge profile -> raised
#
#	Revision 1.1  2000/02/01 22:29:43  david
#	Initial revision
#
#
proc show_tip { win } {
	global tipmsg
	if {![winfo exists $win]} {
		return
	}
	if { [info exists tipmsg($win)] } {
		set message $tipmsg($win)
	} else {
		set message TIP
	}
	toplevel .tip
	wm overrideredirect .tip 1
	set xy [winfo pointerxy $win]
	set x [expr [lindex $xy 0] + 8]
	set y [expr [lindex $xy 1] + 8]
	wm geometry .tip +$x+$y
	message .tip.msg -text $message -font {helvetica 10} -bg bisque -bd 1 -relief raised -aspect 300
	pack .tip.msg
}

proc set_tip { win message } {
	global tipmsg
	set tipmsg($win) $message
	bind $win <Enter> {
		after 1000 show_tip %W
	}
	bind $win <Leave> {
		after cancel show_tip %W
		catch {destroy .tip}
	}
}

