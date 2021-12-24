# tk_tree pathname ?options?
proc ::exWidgets::tk_tree args {
    variable identifiers

    set specs {
        scrolly
        scrollx
        {headings.arg {}}
    }

    parseOptions data $specs args

    # Invalid path
    set pathname [popFront args]
    set id [lindex $args 0]

    if {$pathname eq ""} {
        set frame [info frame -1]
        set cmd [lindex $frame 1]
        return -code error -errorcode [list TCL WRONGARGS] \
            "wrong # args: should be \"$cmd\""
    } elseif {[regexp {\.[a-z]*} $id]} {
        set pathname $id
        return -code error -errorcode [list TK INVALID PARAM $pathname] \
            "invalid path \"$pathname\""
    }

    # An identifier has no dots (i.e., TEXTBOX instead of .textbox)
    # and is not an option (i.e., -textvariable)
    set identifiers($pathname) ""
    set cmd ""

    if {([string first . $id] < 0 && [string first - $id] < 0) && [regexp {[a-zA-Z_]*} $id]} {
        set identifiers($pathname) $id
        set cmd $id
        set args [lreplace $args 0 0]
    }
    unset id

    # if list is non-empty, expect even number of elements
    set temp [llength $data(headings)]
    if {$temp > 0 && $temp & 1} {
        return -code error "invalid option '-headings': list needs an even number of elements"
    }

    # Invalid path name?
    if {[catch {ttk::frame $pathname} err]} {
        unset identifiers($pathname)
        return -code error -errorcode [list TK INVALID PARAM $pathname] $err
    }

    # Identifier already exists as a command
    if {$cmd ne ""} {
        if {[info commands $cmd] ne ""} {
            return -code error -errorcode [list TK INVALID_PARAM $cmd] \
                "invalid identifier \"$cmd\": a command by that name already exists"
        }
    }

    # Packing information for, well, the packer
    namespace upvar [namespace current] packinfo($pathname) PackInfo
    set PackInfo [dict create class tree xscrollbar 0 yscrollbar 0]

    # Link horizontal scrollbar
    if {$data(scrollx)} {
        lappend args -xscrollcommand "$pathname.xscroll set"
        dict set PackInfo xscrollbar 1
    }

    # Link vertical scrollbar
    if {$data(scrolly)} {
        lappend args -yscrollcommand "$pathname.yscroll set"
        dict set PackInfo yscrollbar 1
    }

    # Create the actual widget

    # Subwidgets
    ttk::treeview $pathname.tree {*}$args
    ttk::scrollbar $pathname.xscroll -orient horizontal -command "$pathname.text xview"
    ttk::scrollbar $pathname.yscroll -orient vertical -command "$pathname.text yview"

    if {[llength $data(headings)] > 0} {
        dict size $data(headings)
        dict for {column text} $data(headings) {
            $pathname.tree heading $column -text $text
        }
    }
    unset -nocomplain temp column text

    __set_cmd_and_destroy text $pathname $cmd

    return $pathname
}
