proc ::exWidgets::tk_subcmd {pathname cmd args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    # Error if the widget $pathname was not created by our functions
    if {[catch {dict size $PackInfo} err]} {
        return -code error -errorcode [list TCL INVALID PARAM $pathname] \
            "$pathname is not a path that was created by any of our functions"
    }

    set class [dict get $PackInfo class]

    # A specialized function exists, use it
    if {[info proc "__subcmd_${cmd}_$class"] ne ""} {
        tailcall "__subcmd_${cmd}_$class" $pathname {*}$args
    }

    switch -exact $class {
        text {
            return [$pathname.text $cmd {*}$args]
        }
        entry {
            return [$pathname.entry $cmd {*}$args]
        }
        tree {
            return [$pathname.tree $cmd {*}$args]
        }
        default {
            return -code error -errorcode [list TK LOOKUP $class] \
                "unknown class \"$class\""
        }
    }
}

# Specialized command functions, in the format: __subcmd_<cmd>_<class>
# Example: __subcmd_configure_text

# exw subcmd pathname clear
proc ::exWidgets::__subcmd_clear_tree {pathname} {
    #set oldstate [$pathname.tree state]
    $pathname.tree instate {!disabled !readonly} {
        set list [$pathname.tree children {}]
        if {[llength $list]} {
            $pathname.tree delete $list
        }
    }
    #$pathname.tree state $oldstate
}

# exw subcmd pathname search ?options? index pattern
proc ::exWidgets::__subcmd_search_tree {pathname args} {
    # error if incorrect usage
    set temp [lmap a $args {
        if {[string first - $a] == 0} continue
        set a
    }]
    if {[llength $temp] != 2} {
        set frame [info frame -1]
        set cmd [getCommandName $frame 1 {column pattern}]
        wrongArgs $cmd
    }
    unset -nocomplain temp a

    set specs {glob regex exact all inline}
    parseOptions data $specs args

    set modes [list]
    foreach a $specs {
        if {$data($a)} {
            lappend modes -$a
        }
    }

    # error if more than one of the mode switches are given
    set len [llength $modes]
    if {$len == 0} {
        set data(glob) 1
    } elseif {$len > 1} {
        set temp [lrange $modes 1 end]
        invalidParam $temp "cannot mix options \"[join $temp {, }]\": only one of -glob, -regex, and -exact is allowed"
    }

    # column index
    set column [popFront args]

    if {$column eq ""} {emptyParam column}

    $pathname.tree column $column

    #if {[catch "$pathname.tree column $column" err]} {
    #    invalidParam $column "invalid column \"$column\": $err"
    #}

    if {! [string is digit $column]} {
        # convert column name into an index
        set column [lsearch -exact [$pathname.tree cget -columns] $column]
    }

    # search term
    set pattern [popFront args]
    if {$pattern eq ""} {emptyParam "search pattern"}

    set result ""

    # find the search term
    foreach item [$pathname.tree children {}] {
        set values [$pathname.tree item $item -values]
        set compared [lindex $values $column]

        if {$data(glob)} {
            if {[string match $pattern $compared]} {
                if {$data(all)} {
                    lappend result $item
                } else {
                    set result $item
                }
            }
        } elseif {$data(regex)} {
            if {[regexp $pattern $compared]} {
                if {$data(all)} {
                    lappend result $item
                } else {
                    set result $item
                }
            }
        } else {
            # exact
            if {$compared eq $pattern} {
                if {$data(all)} {
                    lappend result $item
                } else {
                    set result $item
                }
            }
        }
    }

    return $result
}

# usage: exw subcmd PATHNAME clear
proc ::exWidgets::__subcmd_clear_text {pathname} {
    set textState [$pathname.text cget -state]
    if {$textState eq "normal"} {
        return [$pathname.text delete 1.0 end]
    }
    return
}

# usage: exw subcmd PATHNAME instate STATE ?script?
proc ::exWidgets::__subcmd_instate_text {pathname statespec {script ""}} {
    # Invalid state, is not normal or disabled
    if {$statespec ni {normal disabled}} {
        return -code error -errorcode [list TCL INVALID PARAM $statespec] \
            "invalid state \"$statespec\", must be normal or disabled"
    }

    set result 0
    set textState [$pathname.text cget -state]

    if {$textState eq $statespec} {
        if {$script eq ""} {
            set result 1
        } else {
            set result [uplevel $script]
        }
    }

    return $result
}
