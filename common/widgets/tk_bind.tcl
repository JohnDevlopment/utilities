# tk_bind pathname ?sequence? ?+??script?
proc ::exWidgets::tk_bind {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    set class [dict get $PackInfo class]
    ::bind $pathname.$class

    switch -exact $class {
        text -
        entry -
        tree {
            set cmd [list ::bind $pathname.$class {*}$args]
        }
        default {
            return -code error -errorcode [list TCL INVALID PARAM $pathname] \
                "$pathname is not one of our expanded widgets"
        }
    }

    tailcall {*}$cmd
}
