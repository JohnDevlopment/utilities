# pack pathName ?pack_switches ...?
proc ::exWidgets::tk_pack {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode {TK UNKNOWN PATH} \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]
    tailcall "__pack_$class" $pathname {*}$args
}

proc ::exWidgets::__pack_entry {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    ::pack $pathname {*}$args
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

#proc ::exWidgets::tk_grid {args} {
#    #variable packinfo
#    #__pack_internal_entry $pathname [subst \$packinfo()]
#
#    set gridArgs
#    set paths
#
#    set paths [lmap arg $args {
#        if {[regexp {(\.[a-zA-Z_]*.*)|([x^-])} $arg]} {
#            set arg $arg
#        }
#    }]
#}
