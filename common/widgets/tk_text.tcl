# tk_text ?options? path ?identifier? ?text_options?
proc ::exWidgets::tk_text {args} {
    variable identifiers

    set specs {
        {wrap.arg char}
        {maxlines.arg 0}
        scrolly
        {disabledbackground.arg ""}
    }

    parseOptions data $specs args

    # Invalid path
    set pathname [popFront args]
    set id [lindex $args 0]

    if {$pathname eq ""} {
        set frame [info frame -1]
        set cmd [getCommandName $frame 1 ?widgetOptions?]
        wrongArgs $cmd
    } elseif {[string first . $id] >= 0} {
        set pathname $id
        return -code error -errorcode [list TCL INVALID PARAM $pathname] \
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

    # Invalid path name?
    if {[catch {ttk::frame $pathname} err]} {
        unset identifiers($pathname)
        return -code error -errorcode [list TCL INVALID PARAM $pathname] $err
    }

    # Identifier already exists as a command
    if {$cmd ne ""} {
        if {[info commands $cmd] ne ""} {
            return -code error -errorcode [list TCL INVALID PARAM $cmd] \
                "invalid identifier \"$cmd\": a command by that name already exists"
        }
    }

    # Background when the widget is disabled
    if {$data(disabledbackground) eq ""} {
        set data(disabledbackground) [ttk::style lookup TEntry -fieldbackground disabled]
    }

    # Wrap parameter
    if {$data(wrap) ni {none word char}} {
        # Invalid wrap parameter
        return -code error -errorcode [list TCL INVALID PARAM -wrap] \
            "invalid -wrap option \"$data(wrap)\": must be either none, word or char"
    }
    lappend args -wrap $data(wrap)

    # No background color specified, use the ttk default
    if {"-background" ni $args} {
        set bg [ttk::style lookup TEntry -fieldbackground]
        lappend args -background $bg
    }

    # No foreground color specified, use the ttk default
    if {"-foreground" ni $args} {
        set fg [ttk::style lookup TEntry -foreground]
        lappend args -foreground $fg
    }

    # Packing information for, well, the packer
    namespace upvar [namespace current] packinfo($pathname) PackInfo
    set PackInfo [dict create xscrollbar 0 yscrollbar 0 class text \
        disabledbackground $data(disabledbackground)]

    # Link horizontal scrollbar if there is no text wrap
    if {$data(wrap) eq "none"} {
        lappend args -xscrollcommand "$pathname.xscroll set"
        dict set PackInfo xscrollbar 1
    }

    # Link vertical scrollbar
    if {$data(scrolly)} {
        lappend args -yscrollcommand "$pathname.yscroll set"
        dict set PackInfo yscrollbar 1
    }

    # Subwidgets
    text $pathname.text {*}$args
    ttk::scrollbar $pathname.xscroll -orient horizontal -command "$pathname.text xview"
    ttk::scrollbar $pathname.yscroll -orient vertical -command "$pathname.text yview"

    __set_cmd_and_destroy text $pathname $cmd

    dict set PackInfo background [$pathname.text cget -background]

    # Automatically call the state subcommand in the background
    after idle [list exw state $pathname [$pathname.text cget -state]]

    return $pathname
}
