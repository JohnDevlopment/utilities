# tk_focus $pathname
proc ::exWidgets::tk_focus {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    set class [dict get $PackInfo class]
    switch -exact $class {
        text -
        entry -
        tree {
            set cmd [list ::focus $pathname.$class]
        }
        default {
            return -code error -errorcode [list TCL INVALID PARAM $pathname] \
                "$pathname is not one of our expanded widgets"
        }
    }

    eval $cmd
}
