proc ::exWidgets::tk_instate {pathname statespec {script ""}} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode [list TCL INVALID PARAM $pathname] \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]

    # instate command for ttk widgets
    if {$class in {entry tree}} {
	set opts [list $pathname.$class instate $statespec]
	if {$script ne ""} {
	    lappend opts $script
	}
	tailcall {*}$opts
    }

    # Do specialized 'instate' function
    set cmd "__instate_$class"
    if {[info proc $cmd] eq ""} {
        return -code error -errorcode [list TK LOOKUP $class] \
            "there is no instate command for extended $class widgets"
    }
    tailcall $cmd $pathname $statespec $script
}

proc ::exWidgets::__instate_text {pathname statespec script} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {$statespec ni {normal disabled}} {
        # Invalid state, is not normal or disabled
        return -code error -errorcode [list TCL INVALID PARAM $statespec] \
            "invalid state \"$statespec\", must be normal or disabled"
    }

    # Boolean: state of widget matches $statespec
    set cond [expr "[$pathname.text cget -state] eq $statespec"]

    if {$script ne ""} {
	# Evaluate script if the condition is true
	if {$cond} {
	    return [uplevel $script]
	}
	return

    }

    return $cond
}
