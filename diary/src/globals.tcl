set CurrentFile ""
set CurrentEntry ""
set FileData ""

trace add variable CurrentFile write [lambda {name n op} {
    upvar #0 $name Var
    if {$Var ne ""} {
        global TitleBase
        wm title . "$TitleBase - $Var"
    } else {
        global TitleBase
        wm title . $TitleBase
    }
}]

trace add variable CurrentEntry write [lambda {name1 name2 op} {
    upvar #0 $name1 Date

    if {$Date ne ""} {
        global DateFormat
        .nb.frame1.date configure -text [clock format $Date -format "Date: $DateFormat"]
    } else {
        .nb.frame1.date configure -text $Date
    }
}]

trace add variable FileData write [lambda {name n op} {
    upvar #0 $name Data
    global DateFormat SELECTED_ENTRY CurrentEntry

    set keys [lmap key [dict keys $Data] {
        clock format $key -format $DateFormat
    }]
    .nb.frame1.entries configure -values $keys
    if {$CurrentEntry ne ""} {
        set SELECTED_ENTRY [clock format $CurrentEntry -format $DateFormat]
    } else {
        set SELECTED_ENTRY ""
    }
}]
