# displayError msg ?-title msg? ?-detail str?
proc displayError {msg args} {
    tailcall tk_messageBox -parent . -icon error -message $msg {*}$args
}

proc fileCommand {op args} {
    global FileModified CurrentFile EntryModified

    set fileTypes {
        {"JSON Files" {.json .JSON}}
    }

    switch -exact $op {
    new {
        # Save modified file if it already has a name
        if {$FileModified && $CurrentFile ne "untitled"} {
            set yn [tk_messageBox -parent . -title "Unsaved Changes" -type yesnocancel -icon question \
                -message "You have unsaved changes to the file. Do you want to save those changes?"]
            if {$yn eq "yes"} {
                fileCommand save
            } elseif {$yn eq "cancel"} return
        }

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
            set EntryModified 0
            set FileModified 0
        }
    }

    close {
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
        set EntryModified 0
        printStatusbar 1 "File saved" 1000
    }

    save {
        if {! $FileModified} return

        # Input errors
        global FileData
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
        if {! $FileModified} return

        if {$CurrentFile eq ""} {
            return [displayError "Cannot save file!" -detail "No file to save!"]
        }

        global FileData
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
            set CurrentDir [file dirname $CurrentFile]

            cd [file dirname $CurrentFile]

            # Reset textbox history
            exw subcmd .nb.frame1.text edit modified 0
            exw subcmd .nb.frame1.text edit reset

            set FileModified 0
            printStatusbar 1 "File saved" 1500
        }
    }

    open {
        global CurrentDir
        set ifile [tk_getOpenFile -filetypes $fileTypes -parent . -title "Open File" -initialdir $CurrentDir]
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
            set CurrentDir [file dirname $CurrentFile]

            printStatusbar 1 "File opened" 1500
        }
    }
    } ; # end switch
}

proc popFront {listVar} {
    upvar $listVar List
    set result [lindex $List 0]
    set List [lreplace $List 0 0]
    return $result
}

proc getConfigPath {xVar lenVar} {
    global env

    if {$xVar ne ""} {upvar $xVar X}
    if {$lenVar ne ""} {upvar $lenVar Len}

    set paths [split $env(DIARY_CONFIG_PATH) :]
    set X 0
    set Len [llength $paths]

    # Choose the path from the list that exists and is a directory
    foreach path $paths {
        if {[file exists $path] && [file isdirectory $path]} {
            jdebug::print info "Chosen config path $path"
            break
        }
        incr X
    }

    return $path
}

proc openConfig {} {
    global ConfigFile

    set code ok
    set result ""

    set path [getConfigPath x len]
    set ConfigFile [file join $path config.ini]

    # Last path in list is in user home directory; create it if it does not exist
    if {$x == $len} {
        jdebug::print info "Creating directory: $path"
        file mkdir $path
    }
    unset x len

    if {! [file exists $ConfigFile]} {
        jdebug::print info "Creating config file: $ConfigFile"
        saveConfig
        return
    }

    set ini [ini::open $ConfigFile r]

    proc __getKey {section key default} [subst -nocommands {
        if {\$section eq ""} {
            set sn "the global section"
            set section global
        } else {
            set sn "\\\"\$section\\\" section"
        }
        jdebug::print debug "Getting \$key key from \$sn in [ini::filename $ini]"
        return [ini::value $ini \$section \$key \$default]
    }]

    global CurrentDir

    try {
        set CurrentDir [__getKey "" curdir [pwd]]
    } on error err {
        set code error
        set result "Failed to read $ConfigFile: $err"
    } finally {
        rename __getKey {}
    }

    return -code $code $result
}

proc saveConfig {} {
    global ConfigFile

    set code ok
    set result ""

    proc __writeKey {ini section key value {comment ""}} {
        if {$section eq ""} {
            set sn "the global section"
            set section global
        } else {
            set sn "\"$section\" section"
        }
        jdebug::print debug "Writing $key key to $sn in [ini::filename $ini]"
        ini::set $ini $section $key $value
        if {$comment ne ""} {
            ini::comment $ini $section $key $comment
        }
    }

    try {
        jdebug::print debug "Saving configuration options to $ConfigFile"
        set ini [ini::open $ConfigFile w]
        __writeKey $ini "" curdir $::CurrentDir
        ini::comment $ini global "" "This file is auto-generated by the Diary application." \
            "Do not edit unless you know what these options do!"
        ini::commit $ini
        ini::close $ini
    } on error err {
        set code error
        set result "Failed to write $ConfigFile: $err"
    } finally {
        rename __writeKey {}
    }

    return -code $code $result
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
        global StatusBarTimer
        $StatusBarTimer set_script [list $w configure -text ""]
        $StatusBarTimer start [expr "double($timer) / 1000.0"]
        #after $timer [list $w configure -text ""]
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

        CurrentDir {
            printStatusbar 2 $Flag

            #puts $Flag

            set w .nb.frame2.subframe1.directory
            set s [exw state $w]
            exw state $w {!disabled !readonly}
            exw subcmd $w delete 0 end
            exw subcmd $w insert 0 $Flag
            exw state $w $s
        }
    }
}

proc textboxFocused {wgt script} {
    set fw [focus -displayof .]
    if {$fw eq $wgt} {
        uplevel [string map [list %W $fw] $script]
    }
}
