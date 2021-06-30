proc processFlags {name1 name2 op} {
    switch -exact $name1 {
    FileLoaded {
        global FileLoaded

        if {$FileLoaded} {
            # Enable the list of entries but make it readonly
            .nb.frWrite.cxEntries state {!disabled readonly}
            .nb.frWrite.cxEntries configure -values {}
            insertText .nb.frWrite.frTextBody.txBody 1.0 "" 1

            tmpfile::new
        } else {
            #
        }

        # Causes the close button to update its state
        event generate .nb.frFile.btClose <Expose> -when tail
    }
    EditingEntry {
        #
    }
    }
}

proc finalizeWrite {} {
    global FileData SAVEFILE DIR

    set file [file join $DIR $SAVEFILE]

    if {$FileData ne ""} {
        try {
            file copy -force $tmpfile::filepath $file
        } on error {err codes} {
            puts stderr "error returned: $err"
            puts stderr "error codes: $codes"
        } finally {
            tmpfile::closetmp
        }
    }
}

proc writeEntriesToFile {entries} {
    global DateFormat

    set kv [list]
    dict for {k v} $entries {
        lappend kv [clock format $k -format $DateFormat] [json::write string $v]
    }

    set json [json::write object {*}$kv]
    tmpfile::write $json
}

proc readEntriesFromFile {file} {
    global DateFormat FileData

    set code 0
    set result ""

    set id [open $file r]

    try {
        set data [read $id]
        set FileData [json::json2dict $data]
    } on error {result} {
        set code 1
    } finally {
        close $id
    }

    set FileData [dict map {k v} $FileData {
        set k [clock scan $k -format $DateFormat]
        set v $v
    }]

    .nb.frWrite.cxEntries configure -values [dict keys $FileData]

    return -code $code $result
}

proc displayError {msg detail {title "Application Error"}} {
    return [tk_messageBox -icon error -title $title -parent . -message $msg -detail $detail]
}

proc addToCombobox {dictValue} {
    global DateFormat

    set w .nb.frWrite.cxEntries
    set dictValue [dict map {k v} $dictValue {
        set k [clock format $k -format $DateFormat]
        set v $v
    }]

    .nb.frWrite.cxEntries configure -values [dict keys $dictValue]

    return
}

proc updateEntryButtonsStates {} {
    global EditingEntry FileLoaded

    if {$FileLoaded} {
        set state !disabled
    } else {
        set state disabled
    }

    set entry [expr "$EditingEntry & 1"]
    set w .nb.frWrite.frButtons
    set states [list disabled !disabled]
    $w.btNew state [lindex $states $entry]

    foreach button {btSave btDelete} {$w.$button state $state}

    return
}

proc insertText {window index text {clear 0}} {
    set oldstate [$window cget -state]
    $window configure -state normal
    if {$clear} {$window delete 1.0 end}
    $window insert $index $text
    $window configure -state $oldstate
}

# usage: getFile var parent mode<open|save> ?-entry? ?-option value ...?
proc getFile {varname parent mode args} {
    set p [lindex $args 0]
    set fromEntry [expr {$p eq "-entry"}]
    if {$fromEntry} {set args [lreplace $args 0 0]}
    unset p

    # Command based on mode
    switch -exact $mode {
        open {
            set cmd tk_getOpenFile
        }
        save {
            set cmd tk_getSaveFile
        }
        default {
            return -code error "invalid mode \"$mode\": must be either open or save"
        }
    }

    set result [$cmd -parent $parent {*}$args]
    if {$result eq ""} return

    set file [file tail $result]
    set dir [file dirname $result]

    # Set globals and change the title
    uplevel #0 [subst {
        if {"$mode" eq "save" || \$SAVEFILE eq ""} {
            set SAVEFILE "$file"
        }

        set ENTRIES ""
        set OPENFILE "$file"
        set DIR "$dir"
        wm title . "Diary - \$$varname (\$DIR)"
        set FileLoaded 1
    }]

    return $result
}

proc getDir {varname parent args} {
    upvar #0 $varname Dir

    # Returns an error if the variable does not exist
    string length $Dir

    set result [tk_chooseDirectory -parent $parent {*}$args]
    if {$result ne ""} {
        set Dir [file dirname $result]
    }

    return
}

# tmpfile namespace

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
