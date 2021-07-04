package provide tk_widgets 0.1b0

set srcfile [lindex [dict get [info frame -1] cmd] 1]
set dir [file dirname $srcfile]

after idle {unset -nocomplain srcfile dir}

namespace eval ::exWidgets {}

source [file join $dir tk_entry.tcl]
source [file join $dir tk_pack.tcl]

namespace eval exWidgets {
    variable packinfo
    variable alias

    variable commands {tk_entry tk_pack subcmd}

    namespace export -clear tk_entry tk_pack
    namespace ensemble create -command ::exw \
        -map {entry tk_entry pack tk_pack subcmd subcmd}
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

    set nonargs {}

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
                return -code error -errorcode [list TK INVALID PARAM $opt] \
                    "unknown option \"$opt\""
            }
        } else {
            # The first nonoption, stop processing
            set args [list $opt {*}$args]
            break
        }
    } ; # end while
}

# subcmd PATH CMD ?args ...?
proc ::exWidgets::subcmd {pathname cmd args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode {TK UNKNOWN PATH} \
            "$pathname is not a path that was created by any of our functions"
    }

    tailcall "__subcmd_[dict get $PackInfo class]" $pathname $cmd {*}$args
}