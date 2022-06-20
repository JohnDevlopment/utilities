# tk_focus $pathname
proc ::exWidgets::tk_focus {args} {
    set args [lmap e $args {
	if {[regexp {\..+} $e]} {
	    set pathname $e
	    continue
	} else {set e $e}
    }]

    namespace upvar [namespace current] packinfo($pathname) PackInfo

    set class [dict get $PackInfo class]
    switch -exact $class {
        text -
        entry -
        tree {
            set cmd [list ::focus $pathname.$class]
	    if {[llength $args] >= 1} {
		set cmd [linsert $cmd 1 {*}$args]
	    }
        }
        default {
            return -code error -errorcode [list TCL INVALID PARAM $pathname] \
                "$pathname is not one of our expanded widgets"
        }
    }

    eval $cmd
}
