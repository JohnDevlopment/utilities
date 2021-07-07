# displayError msg ?-title msg? ?-detail str?
proc displayError {msg args} {
    tailcall tk_messageBox -parent . -icon error -message $msg {*}$args
}

proc popFront {listVar} {
    upvar $listVar List
    set result [lindex $List 0]
    set List [lreplace $List 0 0]
    return $result
}

proc textboxFocused {wgt script} {
    set fw [focus -displayof .]
    if {$fw eq $wgt} {
        uplevel [string map [list %W $fw] $script]
    }
}

proc fileCommand {op args} {
    switch -exact $op {
    new {
        # Clear text box
        exw state .nb.frame1.text normal
        exw subcmd .nb.frame1.text clear
        exw state .nb.frame1.text disabled

        # Clear list of entries
        .nb.frame1.entries configure -values {}
        .nb.frame1.entries state {!disabled readonly}

        # Enable buttons
        foreach w {new save delete} {.nb.frame1.buttons.$w state !disabled}

        uplevel #0 {
            set SELECTED_ENTRY ""
            set CurrentFile "untitled"
        }
    }

    close {
        # Clear text box
        exw subcmd .nb.frame1.text clear
        exw state .nb.frame1.text disabled

        # Clear list of entries
        .nb.frame1.entries configure -values {}
        .nb.frame1.entries state disabled

        exw subcmd .nb.frame1.text edit modified 0
        exw subcmd .nb.frame1.text edit reset

        # Enable buttons
        foreach w {new save delete} {.nb.frame1.buttons.$w state disabled}

        uplevel #0 {
            set CurrentFile ""
            set SELECTED_ENTRY ""
        }
        focus .
    }

    save {
        global FileData CurrentFile

        if {$CurrentFile ne "" && $CurrentFile ne "untitled"} {
            # Assemble list of key-value pairs
            set temp [list]
            dict for {k v} $FileData {lappend temp $k [json::write string $v]}

            # Format into json string
            set data [json::write object {*}$temp]

            # Write string to file
            set id [open $ofile w]
            puts $id $data
            close $id

            exw subcmd .nb.frame1.text edit modified 0
            exw subcmd .nb.frame1.text edit reset
        }
    }

    saveas {
        global FileData CurrentFile

        if {$CurrentFile eq ""} {
            return [displayError "Cannot save file!" -detail "No file to save!"]
        }

        if {$FileData eq ""} {
            return [displayError "Cannot save file!" -detail "There is no data to save to file."]
        }

        set ofile [tk_getSaveFile -parent . -title "Save to File"]
        if {$ofile ne ""} {
            # Assemble list of key-value pairs
            set temp [list]
            dict for {k v} $FileData {lappend temp $k [json::write string $v]}

            # Format into json string
            set data [json::write object {*}$temp]

            # Write string to file
            set id [open $ofile w]
            puts $id $data
            close $id

            set CurrentFile $ofile

            cd [file dirname $ofile]

            exw subcmd .nb.frame1.text edit modified 0
            exw subcmd .nb.frame1.text edit reset

            # TODO: print confirmation message to a statusbar
        }
    }

    open {
        set ifile [tk_getOpenFile -parent . -title "Open File"]
        if {$ifile ne ""} {
            set id [open $ifile r]
            set data [read $id]
            close $id

            set jsonData [json::json2dict $data]

            # Clear text box
            exw state .nb.frame1.text normal
            exw subcmd .nb.frame1.text clear

            # Clear list of entries
            .nb.frame1.entries configure -values {}
            .nb.frame1.entries state {!disabled readonly}

            # Enable buttons
            foreach w {new save delete} {.nb.frame1.buttons.$w state !disabled}

            global FileData SELECTED_ENTRY CurrentEntry CurrentFile
            set CurrentEntry ""
            set FileData $jsonData
            set SELECTED_ENTRY ""
            set CurrentFile $ifile

            cd [file dirname $ifile]

            # TODO: print confirmation message to a statusbar
        }
    }
    }
}

namespace eval tmpfile {
    variable tmpid ""
    variable filepath ""
}

proc ::tmpfile::__check {} {
    variable tmpid
    variable filepath

    if {$tmpid eq ""} {
        return -code error "no tempfile is open right now"
    }

    return
}

proc ::tmpfile::new {} {
    variable tmpid
    variable filepath

    closetmp

    set tmpid [file tempfile filepath]

    return $tmpid
}

proc ::tmpfile::closetmp {} {
    variable tmpid
    variable filepath

    if {$tmpid ne ""} {
        close $tmpid
        file delete $filepath
        set tmpid ""
        set filepath ""
    }
}

proc ::tmpfile::write {data} {
    variable tmpid
    variable filepath

    __check
    chan truncate $tmpid 0
    seek $tmpid 0 start
    puts $tmpid $data
    flush $tmpid
}
