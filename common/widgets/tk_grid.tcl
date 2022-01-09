proc ::exWidgets::tk_grid args {
    set pathspecs {}
    set opts {}

    foreach arg $args {
        switch -regexp $arg {
            {\.\w+} -
            {^[x-]$} {
                lappend pathspecs $arg
            }
            default {
                lappend opts $arg
            }
        }
    }

    # where '-' may not go
    set i [lsearch -exact $pathspecs -]
    if {$i == 0} {
        return -code error -errorcode [list INVALID PARAM -] \
            "a '-' may not be the first content argument"
    } elseif {$i >= 1} {
        set left [lindex $pathspecs $i-1]
        if {$left eq "^" || $left eq "x"} {
            return -code error -errorcode [list INVALID PARAM -] \
                "a '-' may not follow a 'x' or a '^'"
        }
    }

    eval ::grid $pathspecs $opts

    foreach pathname $pathspecs {
        if {$pathname in {x ^ -}} continue

        namespace upvar [namespace current] packinfo($pathname) PackInfo
        if {[catch {dict size $PackInfo} err]} {
            set cmd [list ::grid {*}$pathspecs {*}$opts]
            if {[catch $cmd err]} {
                return -code error $err
            }
            #return -code error -errorcode [list TCL INVALID PARAM $pathname] \
                "$pathname is not a path that was created by any of our functions"
        } else {
            set class [dict get $PackInfo class]
            set cmd ""
            try {
                "__grid_$class" $pathname {*}$args
            } trap {TCL LOOKUP COMMAND} {err opts} {
                set cmd [lindex [dict get $opts -errorcode] end]
            }
            # no grid for this class of widget
            if {$cmd ne ""} {
                return -code error "there is no grid function for exw class \"$class\""
            }
        }
    }
}

proc ::exWidgets::__grid_entry {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    #::grid $pathname {*}$args
    ::pack $pathname.entry -fill x -expand 1 -side top -anchor n

    # Label has a value
    set label [dict get $PackInfo label]
    if {$label ne ""} {
        ::pack $pathname.label -side top -anchor nw -before $pathname.entry
    }

    # Clear button is enabled
    if {[dict get $PackInfo clearbutton]} {
        ::place $pathname.clear -in $pathname.entry -anchor ne -bordermode inside -relx 1 -rely 0 -width 30 -height 20
    }

    # Scrollbar is enabled
    if {[dict get $PackInfo scrollbar]} {
        ::pack $pathname.xscroll -side bottom -anchor n -fill x -expand 1
    }
}
