#!/usr/bin/tcl
#
# Summarising module for Project Clock
#
# David Keeffe
# Raster Solutions P/L
#
# $Id: summary.tcl,v 1.4 2004/03/17 22:14:47 david Exp $

# History:
#	$Log: summary.tcl,v $
#	Revision 1.4  2004/03/17 22:14:47  david
#	changed date format for -d
#	added -T option for hours only
#
#	Revision 1.3  2001/01/24 03:20:59  david
#	added summary date ranges
#	added multiple projects
#
#	Revision 1.2  2000/06/07 02:01:10  david
#	lots of options
#
#	Revision 1.1  2000/02/21 23:07:03  david
#	Initial revision
#
#

set progname [file tail $argv0]
set progdir [file dirname $argv0]
set env(LANG) "C"
set env(LC_ALL) "C"

source "$progdir/getopt.tcl"

if {[array names env PCLOCK_DATADIR] != ""} then {
  set datadir $env(PCLOCK_DATADIR)
} else {
  set datadir $env(HOME)
}

set dbfile "$datadir/.pclock"
set pconfig "$datadir/.pclockrc"
set projects *
set listonly false
set summarise 1
set verbose 0
set quiet 0
set day 1
set eday end
set year {}
set month {}
set eyear {}
set emonth {}
set debug 0
set workday 8
set rawtimes 0
set showhours 0

set usagelist {
	{h {} {output this message}}
	{T {} {show times as hours}}
	{x {} {increment debug level}}
	{l {} {list projects}}
	{q {} {don't print headings}}
	{r {} {just rawtimes times, no factoring}}
	{s {} {omit summaries}}
	{v {} {print daily times}}
	{d {period} {process times for 'period' (single ([d/]m/y) or range ([d/]m/y-[d/]m/y)) }}
	{i {file} {read data from 'file'}}
}


set ufmt {Usage: %s [-hTxlrs][-d range][project-name]}
	

proc usage { { fd stderr }} {
	global argv0 usagelist ufmt
	puts $fd [format $ufmt $argv0]
	puts $fd "Where -"
	foreach l $usagelist {
		puts $fd [format {	-%s %-10s : %s} [lindex $l 0] [lindex $l 1] [lindex $l 2]]
	}
}

proc getdays { date plist } {
	global days

	set result {}
	# puts stderr "getdays: $date -> $plist"

	foreach p $plist {
		foreach n [array names days "$date,$p"] {
			if {[lsearch -exact $result $n] == -1} {
				lappend result $n
			}
		}
	}
	return $result
}


proc timeof { value showdays } {
	global workday showhours
	if { $showhours } {
		if { $value > 0 } {
			set hours [expr floor(10 * (($value+300.0) / ( 60.0 * 60.0 )))/10.0]
		} else {
			set hours 0.0
		}
		return "    [format %#5.1f $hours]"
	} elseif { $showdays } {
		set days [expr $value / ( $workday * 60 * 60 )]
		set hours [expr $value % ( $workday * 60 * 60 )]
		return "[format %2dd $days] [clock format $hours -format {%H:%M:%S} -gmt 1]"
	} else {
		return "    [clock format $value -format {%H:%M:%S} -gmt 1]"
	}
}


while { [ set err [getopt $argv "THhdrxqlsvf:t:i:d:" opt arg] ] } {
	if { $err <  0 } {
		puts stderr "$argv0: $arg"
	} else {
		switch -exact $opt {
		T {
			set showhours 1
		}

		H {
			usage stdout
			exit 0
		}

		h {
			usage
			exit 0
		}

		d {
			set datexx [split $arg -]
			
			if {[llength $datexx] == 1} {
				set dstr [lindex $datexx 0]
				set date [split $dstr /]
				set d0 [lindex $date 0]
				set d1 [lindex $date 1]
				set d2 [lindex $date 2]
				if {[string match -nocase {[a-z]*} $d0]} {
					set day 1
					set month $d0
					set year $d1
				} else {
					set day $d0
					set month $d1
					set year $d2
				}
				set emonth {}
				set eyear {}
			} else {
				set day {1}
				set month {epoch}
				set year {epoch}
				set eday {end}
				set emonth {eot}
				set eyear {eot}
				if {[lindex $datexx 0] != {} } {
					set dstr [lindex $datexx 0]
					set date [split $dstr /]
					set d0 [lindex $date 0]
					set d1 [lindex $date 1]
					set d2 [lindex $date 2]
					if {[string match -nocase {[a-z]*} $d0]} {
						set day 1
						set month $d0
						set year $d1
					} else {
						set day $d0
						set month $d1
						set year $d2
					}
				}
				if {[lindex $datexx 1] != {} } {
					set dstr [lindex $datexx 1]
					set date [split $dstr /]
					set d0 [lindex $date 0]
					set d1 [lindex $date 1]
					set d2 [lindex $date 2]
					if {[string match -nocase {[a-z]*} $d0]} {
						set eday end
						set emonth $d0
						set eyear $d1
					} else {
						set eday $d0
						set emonth $d1
						set eyear $d2
					}
				}
			}

		}

		r {
			set rawtimes 1
		}

		i {
			set dbfile $arg
		}

		x {
			incr debug
		}

		l {
			set listonly true
		}

		q {
			set quiet 1
		}

		v {
			incr verbose
		}

		s {
			set summarise 0
		}

		}
	}
}

if { $debug > 1 } {
	cmdtrace on stderr
}

set argv [lrange $argv $optind end] 

set projects $argv

if { $projects == {} } {
	set projects *
}

if {[file readable $pconfig]} {
	source $pconfig
}


set now [clock seconds]

if { $month == {epoch} } {
	set month Jan
}

if { $year == {epoch} } {
	set year [clock format $now -format "%Y" -gmt 1]
}

if { $month == {} } {
	set month [clock format $now -format "%b" -gmt 1]
}

if { $year == {} } {
	set year [clock format $now -format "%Y" -gmt 1]
}

if { $emonth == {eot} } {
	set emonth Dec
}

if { $eyear == {eot} } {
	set eyear [clock format $now -format "%Y" -gmt 1]
}

if {[catch {source $dbfile} res]} {
	puts stderr "$res"
	exit 1
}

if { $listonly } {
	foreach n [array names days] {
		regsub {[-a-zA-Z0-9]*,(.*)} $n {\1} p
		set plist($p) 1
	}
	puts [join [array names plist] "\n"]
	exit 0
}

array set months_n {
Jan 1
Feb 2
Mar 3
Apr 4
May 5
Jun 6
Jul 7
Aug 8
Sep 9
Oct 10
Nov 11
Dec 12
}

foreach m [array names months_n] {
	set n_months($months_n($m)) $m
}

array set alldays {}
set total 0

if [scan $day "%d" t] {
	set day $t
	unset t
}

if { $emonth != {} || $eyear != {} } {
	if { $eday == "end" } { 
		set tbanner [format "Times from %04d-%02d-%02d to %s" $year $months_n($month) $day $eday]
	} elseif [scan $eday "%d" t] {
		set eday $t
		unset t
		set tbanner [format "Times from %04d-%02d-%02d to %04d-%02d-%02d" $year $months_n($month) $day $eyear $months_n($emonth) $eday]
	} else {
		set tbanner [format "Times from %04d-%02d-%02d to %4.4s-%2.2s-%2.2s" $year $months_n($month) $day $eyear $months_n($emonth) $eday]
	}
} else {
	set tbanner [format "Times for %04d-%02d" $year $months_n($month)]
}
if { $verbose && !$quiet } {
	puts $tbanner
	puts [format {%-15s %-20s %8s} Date Project Time]
	puts [format {%-15s-%-20s-%s} --------------- --------------------- -----------]
}

if { $emonth == {} } {
	set emonth $month
}

if { $eyear == {} } {
	set eyear $year
}


# puts stderr "FROM $day $month $year TO $eday $emonth $eyear"
set dstart [clock scan "$day $month $year" -gmt 1]
set daysec [expr 24*60*60]
if { $eday == "end" } {
	set dend [expr [clock scan "1 $emonth $eyear + 1 month" -gmt 1] - $daysec]
} else {
	set dend [clock scan "$eday $emonth $eyear" -gmt 1]
}

if { $dstart >= $dend } {
	puts stderr "$progname: start is before end!"
	exit 0
}


# puts stderr "START \[2\]: [clock format $dstart -gmt 1] - END: [clock format $dend -gmt 1]"

for { set actual $dstart} { $actual <= $dend } { incr actual $daysec } {

	# puts stderr "ACTUAL: [clock format $actual -gmt 1]"

	set date [clock format $actual -format "%d-%b-%Y" -gmt 1]
	set fdate [clock format $actual -format "%a %Y-%m-%d" -gmt 1]
	set matches [lsort [getdays $date $projects]] 
	if { ($verbose > 1) && $matches == {} } {
		puts [format {%s %-20s %s} $fdate "--EMPTY--" 0]
	}
	foreach n $matches {
		regsub "$date," $n {} proj
		if { $rawtimes == 0 && [info exists factor($proj)] } {
			set dd [expr int($factor($proj) * $days($n))]
		} else {
			set dd $days($n)
		}
		if {[info exists alldays($proj)]} {
			incr alldays($proj) $dd
		} else {
			set alldays($proj) $dd
		}
		incr total $dd
		if { $verbose > 1 || ( $verbose && $dd > 0 ) } {
			puts [format {%s %-20s %s} $fdate $proj [timeof $dd 0]]
		}
	}
}

if { $summarise } {
	if { !$quiet } {
		if { !$verbose } {
			puts $tbanner
			puts [format {%-15s %-20s %8s} {} Project Time]
		}
		puts [format {%-15s-%-20s-%s} --------------- --------------------- -----------]
	}
	foreach n [lsort [array names alldays]] {
		puts [format {%-15s %-20s %s} {} $n [timeof $alldays($n) 1]]	
	}
	if { !$quiet } {
		puts [format {%-15s-%-20s-%s} --------------- --------------------- -----------]
		puts [format {%-15s %-20s %s} {} TOTAL [timeof $total 1]]
	}
}
