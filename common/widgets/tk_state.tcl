proc ::exWidgets::tk_state {pathname state} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode [list TK INVALID_PARAM $pathname] \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]
    set cmd "__state_$class"

    if {[info proc $cmd] eq ""} {
        return -code error -errorcode [list TK LOOKUP $class] \
            "there is no state command for extended $class widgets"
    }

    tailcall $cmd $pathname $state
}

proc ::exWidgets::__state_text {pathname {state ""}} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    # Return the state of the widget
    if {$state eq ""} {
        return [$pathname.text cget -state]
    } \
    elseif {$state ni {normal disabled}} {
        # Invalid state, is not normal or disabled
        return -code error -errorcode [list TK INVALID_PARAM $state] \
            "invalid state \"$state\", must be normal or disabled"
    }

    # Background color based on state
    if {$state eq "normal"} {
        set bg [dict get $PackInfo background]
    } else {
        set bg [dict get $PackInfo disabledbackground]
    }

    $pathname.text configure -state $state -background $bg
}
