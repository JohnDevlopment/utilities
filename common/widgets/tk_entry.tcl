# tk_entry ?switches? pathName ?ttk_entrySwitches ...?
proc ::exWidgets::tk_entry {args} {
    set specs {
        {maxlen.arg 0}
        {label.arg ""}
        scrollx
        clearbutton
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

    # Create subwidgets
    ttk::entry $pathname.entry {*}$args -xscrollcommand "$pathname.xscroll set"
    ttk::scrollbar $pathname.xscroll -orient horizontal -command "$pathname.entry xview"
    ttk::button $pathname.clear -text X -state disabled -command [subst {
        # Backup the state of the entry
        set oldstate \[$pathname.entry state]
        $pathname.entry state !disabled

        # Delete characters
        $pathname.entry delete 0 end

        # Restore state of entry
        $pathname.entry state \$oldstate
        unset oldstate

        # Disable button
        $pathname.clear state disabled

        # Set focus to the entry
        focus $pathname.entry
    }]
    ttk::label $pathname.label -text $data(label)

    # Entry validation

    set vcmd [list]
    set invcmd [list]

    # Enable/disable the clear button depending on there being text
    if {$data(clearbutton)} {
        lappend vcmd {
            if {[string length %P] > 0} {
                $pathname.clear state !disabled
            } else {
                $pathname.clear state disabled
            }
        }
    }

    set invcmd {
        if {[string length [$pathname.entry get]] > $data(maxlen)} {
            $pathname.entry delete $data(maxlen) end
        }
    }

    # Empty string passed as maxlen
    if {$data(maxlen) eq ""} {set data(maxlen) 0}

    # -maxlen is not a valid integer string
    if {! [regexp {[0-9]+} $data(maxlen)]} {
        # TODO: delete the line under this
        puts stderr "invalid \"-maxlen\" value: $data(maxlen)"
        set data(maxlen) 0
    }

    # Constrain entry text to a certain length
    if {$data(maxlen) > 0} {
        lappend vcmd {
            if {%d == 1 || %d == -1} {
                if {[string length %s] >= $data(maxlen)} {return 0}
            }
        }
    }

    # Final return
    lappend vcmd {return 1}

    set vcmd [join $vcmd "\n"]
    #set invcmd [join $invcmd "\n"]

    $pathname.entry configure -validate key -validatecommand [subst -nocommands $vcmd] \
        -invalidcommand [subst -nocommands $invcmd]

    # Information for the geometry manager.
    namespace upvar [namespace current] packinfo($pathname) PackInfo
    set PackInfo [dict create scrollbar $data(scrollx) clearbutton $data(clearbutton) \
        label $data(label) class entry]

    return $pathname
}

proc ::exWidgets::__subcmd_entry {pathname cmd args} {
    return [$pathname.entry $cmd {*}$args]
}
