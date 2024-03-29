package provide tk_widgets 0.6.1

# invalidParam param msg

set srcfile [lindex [dict get [info frame -1] cmd] 1]
set dir [file dirname $srcfile]

after idle {unset -nocomplain srcfile dir}

namespace eval ::exWidgets {}

source [file join $dir tk_bind.tcl]
source [file join $dir tk_entry.tcl]
source [file join $dir tk_focus.tcl]
source [file join $dir tk_grid.tcl]
source [file join $dir tk_instate.tcl]
source [file join $dir tk_tree.tcl]
source [file join $dir tk_text.tcl]
source [file join $dir tk_pack.tcl]
source [file join $dir tk_state.tcl]
source [file join $dir tk_subcmd.tcl]

namespace eval exWidgets {
    variable packinfo
    variable alias
    variable commands {tk_bind tk_entry tk_focus tk_grid tk_instate tk_pack tk_state tk_text tk_state tk_subcmd tk_text tk_tree}
    variable identifiers
    variable python 0

    namespace export -clear tk_*
    namespace ensemble create -command ::exw \
        -map {
            bind    tk_bind
            entry   tk_entry
            focus   tk_focus
            grid    tk_grid
	    instate tk_instate
            pack    tk_pack
            state   tk_state
            subcmd  tk_subcmd
            text    tk_text
            tree    tk_tree
        }
}

proc ::exWidgets::getCommandName {frame {hasOptions 0} {extras ""}} {
    set cmd [dict get $frame cmd]; puts "\"$cmd\""
    if {[lindex $cmd 0] eq "exw"} {
        set cmd [concat [lrange $cmd 0 1] pathname [lindex $cmd 3]]
        if {$hasOptions} {
            set cmd [linsert $cmd 2 "?options?"]
        }
        if {[string length $extras]} {
            set cmd [linsert $cmd 3 $extras]
        }
        return [join $cmd]
    }
    return [lindex $cmd 0]
}

proc ::exWidgets::validCommands {} {
    variable commands

    set i 1
    set length [llength $commands]
    set msg ""
    set sep ""

    foreach cmd [lsort $commands] {
        set msg "$msg$sep$cmd"
        incr i
        if {$i <= $length} {
            set sep ", "
            if {$i == $length} {append sep "or "}
        } else {
            set sep ""
        }
    }

    return $msg
}

proc ::exWidgets::wrongArgs {cmd} {
    return -code error -errorcode [list TCL WRONGARGS] \
        "wrong # args: should be \"[join $cmd]\""
}

# invalidParam param msg
proc ::exWidgets::invalidParam {param msg} {
    return -code error -errorcode [list TCL INVALID PARAM $param] $msg
}

proc ::exWidgets::emptyParam {param} {
    return -code error -errorcode [list TCL MISSING PARAM $param] \
        "missing or empty $param"
}

proc ::exWidgets::valid {name specs} {
    set i 1
    set length [llength $specs]
    set msg ""
    set sep ""

    foreach spec $specs {
        set opt [regsub {([a-zA-Z0-9]*)\.arg} [lindex $spec 0] {\1}]
        set msg "$msg$sep-$opt"
        incr i
        if {$i <= $length} {
            set sep ", "
            if {$i == $length} {append sep "or "}
        } else {
            set sep ""
        }
    }

    return $msg
}

proc ::exWidgets::popFront {listVar} {
    upvar $listVar List
    set result ""
    if {[llength $List] > 0} {
        set result [lindex $List 0]
        set List [lreplace $List 0 0]
    }
    return $result
}

proc ::exWidgets::parseOptions {dataVar specs argVar} {
    upvar $dataVar Data

    foreach spec $specs {
        set len [llength $spec]
        set opt [lindex $spec 0]
        set optBase [regsub {([a-zA-Z0-9]*)\.arg} $opt {\1}]
        set optarg [lindex $spec 1]

        if {[regexp {.*\.arg} $opt]} {
            set spectype($optBase) arg
            set Data($optBase) $optarg
        } else {
            set spectype($optBase) bool
            set Data($optBase) 0
        }
    }

    # Start option processing
    upvar $argVar args
    while {[llength $args] > 0} {
        # Extract the first element
        set opt [popFront args]

        if {[string first - $opt] == 0} {
            # We've found a switch

            # Remove the leading '-'
            set opt2 [string range $opt 1 end]

            # Is it one of our defined switches?
            if {$opt2 in [array names spectype]} {
                if {[subst \$spectype($opt2)] eq "arg"} {
                    # No argument to extract, error
                    if {! [llength $args]} {
                        return -code error -errorcode [list TK MISSING PARAM $opt] \
                            "missing argument for \"$opt\""
                    }
                    # Switch expects an argument
                    set optarg [popFront args]
                } else {
                    # Switch expects no argument
                    set optarg 1
                    #set args [lreplace $args 0 0]
                }
                set Data($opt2) $optarg
            } else {
                # Unknown option, error
                #set args [list $opt {*}$args]
                return -code error -errorcode [list TCL INVALID PARAM $opt] \
                    "unknown option \"$opt\""
            }
        } else {
            # The first nonoption, stop processing
            set args [list $opt {*}$args]
            break
        }
    } ; # end while

    return
}

proc ::exWidgets::__set_cmd_and_destroy {class pathname cmd} {
    if {$cmd eq ""} return

    # Script that executes when the widget is destroyed
    set scriptWhenDestroyed [list]

    set temp [namespace code [list unset -nocomplain identifiers($pathname) packinfo($pathname)]]
    lappend scriptWhenDestroyed [subst $temp]

    switch -exact $class {
        text {
            # Text widget command
            set cmdname "::$cmd"
            set args {subcmd args}
            set body {
                switch -exact \$subcmd {
                    state {
                        tailcall exw state $pathname {*}\$args
                    }
                    default {
                        return [exw subcmd $pathname \$subcmd {*}\$args]
                    }
                }
            }
            proc $cmdname $args [subst -nocommand $body]
            lappend scriptWhenDestroyed [list rename $cmdname ""]
        }

        entry -
        tree {
            # Tree widget command
            set cmdname "::$cmd"
            set args {subcmd args}
            set body {
                return [exw subcmd $pathname \$subcmd {*}\$args]
            }
            proc $cmdname $args [subst -nocommand $body]
            lappend scriptWhenDestroyed [list rename $cmdname ""]
        }
    }

    bind $pathname <Destroy> [join $scriptWhenDestroyed "\n"]
}
