# tk_text ?options? path ?text_options?
proc ::exWidgets::tk_text {args} {
    set specs {
        {wrap.arg char}
        {maxlines.arg 0}
        scrolly
        {disabledbackground.arg ""}
    }

    parseOptions data $specs args

    set pathname [popFront args]
    if {$pathname eq ""} {
        return -code error -errorcode {TK MISSING PATHNAME} \
            "missing pathname for entry"
    }

    # Invalid path name?
    if {[catch {ttk::frame $pathname} err]} {
        return -code error -errorcode {TK INVALID PARAM} $err
    }

    # Background when the widget is disabled
    if {$data(disabledbackground) eq ""} {
        set data(disabledbackground) [ttk::style lookup TEntry -fieldbackground disabled]
    }

    # Wrap parameter
    if {$data(wrap) ni {none word char}} {
        # Invalid wrap parameter
        return -code error -errorcode [list TK INVALID PARAM -wrap] \
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

    dict set PackInfo background [$pathname.text cget -background]

    # Automatically call the state subcommand in the background
    after idle [list exw state $pathname [$pathname.text cget -state]]

    return $pathname
}
