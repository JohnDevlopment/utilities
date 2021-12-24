proc ::exWidgets::tk_state {pathname {statespec ""}} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode [list TCL INVALID PARAM $pathname] \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]
    set cmd "__state_$class"

    if {[info proc $cmd] eq ""} {
        return -code error -errorcode [list TK LOOKUP $class] \
            "there is no state command for extended $class widgets"
    }

    set opts [list $cmd $pathname]
    if {$statespec ne ""} {lappend opts $statespec}

    tailcall {*}$opts
}

proc ::exWidgets::__state_text {pathname {statespec ""}} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    # Return the state of the widget
    if {$statespec eq ""} {
        return [$pathname.text cget -state]
    } \
    elseif {$statespec ni {normal disabled}} {
        # Invalid state, is not normal or disabled
        return -code error -errorcode [list TCL INVALID PARAM $statespec] \
            "invalid state \"$statespec\", must be normal or disabled"
    }

    # Background color based on state
    if {$statespec eq "normal"} {
        set bg [dict get $PackInfo background]
    } else {
        set bg [dict get $PackInfo disabledbackground]
    }

    $pathname.text configure -state $statespec -background $bg
}

proc ::exWidgets::__state_entry {pathname {statespec ""}} {
    if {$statespec eq ""} {
        return [$pathname.entry state]
    }
    return [$pathname.entry state $statespec]
}
