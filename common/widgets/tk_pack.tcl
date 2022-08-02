# pack pathName ?pack_switches ...?
proc ::exWidgets::tk_pack {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode [list TCL INVALID PARAM $pathname] \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]
    tailcall "__pack_$class" $pathname {*}$args
}

proc ::exWidgets::__pack_tree {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    ::pack $pathname {*}$args
    ::pack $pathname.tree -fill both -expand 1 -side left -anchor n -padx {0 30}

    if {[dict get $PackInfo yscrollbar]} {
        ::place $pathname.yscroll -in $pathname.tree -bordermode outside -relx 1 -y 0 -relheight 1
    }
}

proc ::exWidgets::__pack_entry {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    ::pack $pathname {*}$args
    ::pack $pathname.entry -fill x -expand 1 -side top -anchor n -ipadx 2 -padx "0 35"

    # Label has a value
    set label [dict get $PackInfo label]
    if {$label ne ""} {
        ::pack $pathname.label -side top -anchor nw -before $pathname.entry
    }

    # Clear button is enabled
    if {[dict get $PackInfo clearbutton]} {
	::place $pathname.clear -in $pathname.entry -anchor ne -bordermode outside -relx 1.1 -rely 0 -width 30 -height 20
	after idle [subst {
	    set font [ttk::style lookup TEntry -font]
	    set w [font measure \$font -displayof $pathname.entry 0]
	    ::place $pathname.clear -x \$w
	    unset -nocomplain font w
	}]
    }

    # Scrollbar is enabled
    if {[dict get $PackInfo scrollbar]} {
        ::pack $pathname.xscroll -side bottom -anchor n -fill x -expand 1
    }
}

proc ::exWidgets::__pack_text {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    ::pack $pathname {*}$args
    ::pack $pathname.text -fill both -expand 1 -side left -anchor n -padx {0 30}

    # Vertical and horizontal scrollbars
    if {[dict get $PackInfo yscrollbar]} {
        #::pack $pathname.yscroll -side right -anchor w -fill y -expand 1
        ::place $pathname.yscroll -in $pathname.text -bordermode outside -relx 1 -y 0 -relheight 1
    }
    if {[dict get $PackInfo xscrollbar]} {
        ::pack $pathname.xscroll -side bottom -anchor n -fill x -expand 1
    }
}
