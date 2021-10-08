# jdebug - A module for debugging messages
# How To Use:
#   jdebug::on to turn it on
#   jdebug::off to turn it off
#
#   jdebug::eval script - $script is a Tcl script to be run only when the jdebug flag is set
#   jdebug::print tag msg - print $msg with the tag $tag, which can be one of the loglevels
#
# Log levels:
#   FATAL -> ERROR -> WARN -> INFO -> DEBUG -> TRACE -> ALL -> OFF

package provide jdebug 2.0.1

namespace eval jdebug {
    variable enabled 0
    variable loglevel all
    variable chan stderr
    variable header ""
    variable trailer ""

    namespace export -clear on off eval print level frame header trailer

    proc _getTagValue {tag} {
        set value ""
        set code 0
        switch -nocase -exact -- $tag {
            all {
                set value 0
            }
            trace  {
                set value 1
            }
            debug {
                set value 2
            }
            info  {
                set value 3
            }
            warn {
                set value 4
            }
            error {
                set value 5
            }
            fatal {
                set value 6
            }
            default {
                set code 1
                set value "invalid tag \"$tag\": must be all, trace, info, warn, error, or fatal"
            }
        }

        return -code $code $value
    }
}

proc ::jdebug::on {} {
    variable enabled 1
    level all
    header ""
    trailer ""
}

proc ::jdebug::off {} {variable enabled 0}

proc ::jdebug::eval script {
    variable enabled
    if {$enabled} [list uplevel $script]
    return
}

proc ::jdebug::print {tag msg} {
    variable enabled
    variable chan
    variable loglevel
    variable header
    variable trailer

    if {! $enabled} return

    # Return if the given loglevel is disabled
    set curlevel [_getTagValue $loglevel]
    set reqlevel [_getTagValue $tag]
    if {$reqlevel < $curlevel} return

    set message $msg
    set cmdname ""

    # Print each line
    foreach line [split $message "\n"] {
        puts $chan "$header$tag | $line$trailer"
    }

    return
}

proc jdebug::frame {{uplevel 0}} {
    # If the current frame number is 1, we are on the top level, so
    # set level to -1 (caller of info frame) instead of -2 (caller's caller)
    if {[info frame] < 2} {
        set level -1
    } else {set level -2}

    if {$uplevel ne "" && [string is digit $uplevel]} {
        set level [expr $level - $uplevel]
    }

    if {[catch "info frame $level" lFrame]} {
        puts stderr $lFrame
        set lFrame [info frame -1] ; # Get caller frame
    }

    # Get name of script/procedure/file this is called in
    set cmdname {}
    switch -exact [dict get $lFrame type] {
        eval {
            set cmdname [lindex [dict get $lFrame cmd] 0]
        }

        proc {
            if {[dict exists $lFrame lambda]} {
                set cmdname "lambda function"
            } else {
                set cmdname [dict get $lFrame proc]
            }
        }

        source {
            set cmdname "source [dict get $lFrame file]"
        }

        default {
            return -code error "Unknown or unsupported frame type [dict get $lFrame type]"
        }
    }

    return $cmdname
}

proc ::jdebug::level {level} {
    variable loglevel

    switch -nocase -exact -- $level {
        all -
        trace -
        debug -
        info -
        warn -
        error -
        fatal {
            set loglevel [string tolower $level]
        }
        default {
            return -code error \
                "invalid loglevel \"$level\": must be all, trace, info, warn, error, or fatal"
        }
    }

    return
}

proc ::jdebug::header {text} {variable header $text}
proc ::jdebug::trailer {text} {variable trailer $text}
