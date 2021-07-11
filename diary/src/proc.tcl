# displayError msg ?-title msg? ?-detail str?
proc displayError {msg args} {
    tailcall tk_messageBox -parent . -icon error -message $msg {*}$args
}

proc fileCommand {op args} {
    set fileTypes {
        {"JSON Files" {.json .JSON}}
    }

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
        global FileModified CurrentFile

        if {$FileModified} {
            set yn [tk_messageBox -parent . -title "Unsaved Changes" -type yesnocancel -icon question \
                -message "You have unsaved changes to the file. Do you want to save those changes?"]
            if {$yn eq "yes"} {
                # File cannot be modified (flag = true) if no file is open, so only
                # check if the filename is "untitled" or not -- it will not be empty
                if {$CurrentFile eq "untitled"} {
                    set temp saveas
                } else {
                    set temp save
                }
                fileCommand $temp
            } elseif {$yn eq "cancel"} return
        }

        # Clear text box
        exw subcmd .nb.frame1.text clear
        exw state .nb.frame1.text disabled

        # Clear list of entries
        .nb.frame1.entries configure -values {}
        .nb.frame1.entries state disabled

        # Reset textbox history
        exw subcmd .nb.frame1.text edit modified 0
        exw subcmd .nb.frame1.text edit reset

        # Disable buttons
        foreach w {new save delete} {.nb.frame1.buttons.$w state disabled}

        uplevel #0 {
            set CurrentFile ""
            set SELECTED_ENTRY ""
            set CurrentEntry ""
        }

        focus .

        set FileModified 0
        printStatusbar 1 "File saved" 1000
    }

    save {
        global FileData CurrentFile FileModified

        if {! $FileModified} return

        # Input errors
        if {$CurrentFile eq ""} {
            return [displayError "Cannot save file!" -detail "No file to save!"]
        }
        if {$FileData eq ""} {
            return [displayError "Cannot save file!" -detail "There is no data to save to file."]
        }

        # Saveas for unnamed file
        if {$CurrentFile eq "untitled"} {tailcall fileCommand saveas}

        # Assemble list of key-value pairs
        set temp [list]
        dict for {k v} $FileData {lappend temp $k [json::write string $v]}

        # Format into json string
        set data [json::write object {*}$temp]

        # Write string to file
        set id [open $CurrentFile w]
        puts $id $data
        close $id

        # Reset textbox history
        exw subcmd .nb.frame1.text edit modified 0
        exw subcmd .nb.frame1.text edit reset

        set FileModified 0
        printStatusbar 1 "File saved" 1500
    }

    saveas {
        global FileData CurrentFile FileModified

        if {! $FileModified} return

        if {$CurrentFile eq ""} {
            return [displayError "Cannot save file!" -detail "No file to save!"]
        }

        if {$FileData eq ""} {
            return [displayError "Cannot save file!" -detail "There is no data to save to file."]
        }

        set ofile [tk_getSaveFile -filetypes $fileTypes -parent . -title "Save to File"]
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

            cd [file dirname $CurrentFile]

            # Reset textbox history
            exw subcmd .nb.frame1.text edit modified 0
            exw subcmd .nb.frame1.text edit reset

            set FileModified 0
            printStatusbar 1 "File saved" 1500
            printStatusbar 0 [pwd]
        }
    }

    open {
        set ifile [tk_getOpenFile -filetypes $fileTypes -parent . -title "Open File"]
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

            # Initialize variables
            global FileData SELECTED_ENTRY CurrentEntry CurrentFile
            set CurrentEntry ""
            set SELECTED_ENTRY ""
            set FileData $jsonData
            set CurrentFile $ifile

            cd [file dirname $ifile]

            printStatusbar 2 [pwd]
            printStatusbar 1 "File opened" 1500
        }
    }
    }
}

proc popFront {listVar} {
    upvar $listVar List
    set result [lindex $List 0]
    set List [lreplace $List 0 0]
    return $result
}

proc printErrorToStdout {msg {detail ""}} {
    global tcl_interactive

    if {$tcl_interactive} {
        if {$detail ne ""} {
            puts stderr "$msg\n  $detail"
        } else {
            puts stderr $msg
        }
    } else {
        if {$detail ne ""} {
            displayError $msg -title "Application Error" -detail $detail
        } else {
            displayError $msg -title "Application Error"
        }
    }
}

# idx:
#   0 = entryMod
#   1 = fileMod
#   2 = dir
proc printStatusbar {idx msg {timer -1}} {
    set bar .nb.frame1.statusbar
    set temp [list $bar.entryMod $bar.fileMod $bar.dir]
    assert {$idx >= 0 && $idx < 3} "Invalid index $idx"
    set w [lindex $temp $idx]
    $w configure -text $msg
    if {$timer > 0} {
        after $timer [list $w configure -text ""]
    }
}

proc processFlag {name1 name2 op} {
    upvar #0 $name1 Flag

    switch -exact $name1 {
        EntryModified {
            if {$Flag} {
                printStatusbar 0 "Entry modified"
            } else {
                printStatusbar 0 ""
            }
        }

        FileModified {
            if {$Flag} {
                printStatusbar 1 "File modified"
            } else {
                printStatusbar 1 ""
            }
        }
    }
}

proc textboxFocused {wgt script} {
    set fw [focus -displayof .]
    if {$fw eq $wgt} {
        uplevel [string map [list %W $fw] $script]
    }
}
