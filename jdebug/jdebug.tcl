# jdebug - A module for debugging messages
# How To Use:
#   jdebug::on to turn it on
#   jdebug::off to turn it off
#
#   jdebug::eval script - $script is a Tcl script to be run only when the jdebug flag is set
#   jdebug::print msg [[chan] level] - print $msg on channel $chan at uplevel $level if the jdebug flag is set

package provide jdebug 1.0

namespace eval jdebug {
    variable bEnable 0

    proc on {} {
        variable bEnable
        set bEnable 1
        puts "Debug mode enabled"
    }

    proc off {} {
        variable bEnable
        set bEnable 0
    }

    proc eval script {
        variable bEnable
        if {$bEnable} [list uplevel $script]
        return
    }

    proc print {msg {chan stdout} {uplevel 0}} {
        variable bEnable

        # If the current frame number is 1, we are on the top level, so
        # set iLevel to -1 (caller of info frame) instead of -2 (caller's caller)
        if {[info frame] < 2} {
            set iLevel -1
        } else {set iLevel -2}

        if {$uplevel != "" && [string is digit $uplevel]} {
            set iLevel [expr $iLevel - $uplevel]
        }

        if {$bEnable} {
            if {[catch "info frame $iLevel" lFrame]} {
                puts stderr "::jdebug::print error: \"$lFrame\""
                set lFrame [info frame -1] ; # Get caller frame
            }

            # Get name of script/procedure/file this is called in
            set sCmdName {}
            switch -exact [dict get $lFrame type] {
                eval {
                    set sCmdName [lindex [dict get $lFrame cmd] 0]
                }

                proc {
                    set sCmdName [dict get $lFrame proc]
                }

                source {
                    set sCmdName "source [dict get $lFrame file]"
                }

                default {
                    return -code error "Unknown or unsupported frame type [dict get $lFrame type]"
                }
            }

            puts $chan "DEBUG: $sCmdName: $msg"
        }

        return
    }
}
