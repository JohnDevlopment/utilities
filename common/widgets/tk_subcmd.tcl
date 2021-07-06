proc ::exWidgets::tk_subcmd {pathname cmd args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    # Error if the widget $pathname was not created by our functions
    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode [list TK INVALID_PARAM $pathname] \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]

    # A specialized function exists, use it
    if {[info proc "__subcmd_${cmd}_$class"] ne ""} {
        tailcall "__subcmd_${cmd}_$class" $pathname {*}$args
    }

    switch -exact $class {
    text {
        return [$pathname.text $cmd {*}$args]
    }
    entry {
        return [$pathname.entry $cmd {*}$args]
    }
    default {
        return -code error -errorcode [list TK LOOKUP $class] \
            "unknown class \"$class\""
    }
    }
}

# Specialized command functions, in the format: __subcmd_<cmd>_<class>
# Example: __subcmd_configure_text

# usage: exw subcmd PATHNAME clear
proc ::exWidgets::__subcmd_clear_text {pathname} {
    set textState [$pathname.text cget -state]
    if {$textState eq "normal"} {
        return [$pathname.text delete 1.0 end]
    }
    return
}

# usage: exw subcmd PATHNAME instate STATE ?script?
proc ::exWidgets::__subcmd_instate_text {pathname statespec {script ""}} {
    # Invalid state, is not normal or disabled
    if {$statespec ni {normal disabled}} {
        return -code error -errorcode [list TK INVALID_PARAM $statespec] \
            "invalid state \"$statespec\", must be normal or disabled"
    }

    set result 0
    set textState [$pathname.text cget -state]

    if {$textState eq $statespec} {
        if {$script eq ""} {
            set result 1
        } else {
            set result [uplevel $script]
        }
    }

    return $result
}
