##################################################
# Widget Mapper
# Version 0.1-alpha
# Created by John Russell
##################################################
package provide widgetmapper 1.0

package require utilities
package require jdebug

const WidgetMapperRecursionLimit 100

namespace eval WidgetMapper {
    variable level
    variable widgets; array set widgets {0 ""}
    variable widgetreturn
    variable map_options; array set map_options {0 ""}
    variable mapping
    variable data

    namespace import ::Options::getoptions
    namespace export find map_widgets
    namespace ensemble create -command ::mapper -map {find find map map_widgets}

    # find ?-start path? name
    proc find args {
        getoptions {{start.arg .} {depth.arg 0}} opts args

        if {[llength $args] != 1} {
            return -code error -errorcode [list TCL WRONGARGS] \
                "wrong # args: should be \"WidgetMapper::find ?options? name\""
        }

        # invalid starting point
        if {! [winfo exists $opts(start)]} {
            return -code error -errorcode [list TCL INVALID PARAM $opts(start)] \
                "invalid parameter '$opts(start)', widget does not exist"
        }

        # last argument is name to search for
        set name [lindex $args 0]
        if {[string first . $name] >= 0} {
            return -code error -errorcode [list TCL INVALID PARAM $name] \
                "invalid parameter '$name', cannot contain dots"
        }

        variable level
        variable widgets
        variable widgetreturn

        set level 0
        array set widgets {0 ""}
        set widgetreturn ""

        set start $opts(start)
        _debug_put_line 0 "Starting point: $start, looking for $name"
        _find $start $start $name $opts(depth)

        return $widgetreturn
    }

    proc map_widgets {args} {
        variable map_options; array set map_options {0 ""}
        variable widgets; array set widgets {0 ""}
        variable level 0
        variable mapping ""

        # process all -map options
        set mapMode 0
        set args [lmap opt $args {
            if {$mapMode} {
                if {[llength $opt] != 2} {
                    return -code error -errorcode [list TCL INVALID PARAM -map] \
                        "invalid mapping '$opt', must be a two-element list"
                }
                lassign $opt v k
                dict set mapping $k $v
                set mapMode 0
                continue
            } else {
                if {$opt eq "-map"} {
                    set mapMode 1
                    continue
                }
                set opt
            }
        }]
        unset -nocomplain v k opt mapMode

        _debug_put_line 0 "Mapping: $mapping"

        set specs {
            {depth.arg 0}
            {start.arg .}
        }
        getoptions $specs map_options args

        tailcall _map_children $map_options(start) $map_options(start)
    }

    proc _map_children {root widget} {
        variable map_options
        variable level
        variable widgets
        variable mapping

        incr level 1

        # We've exceeded the depth limit, so return
        if {$map_options(depth) > 0 && $level > $map_options(depth)} return

        _debug_put_line $level "Enter recursion level $level, parent widget: $widget"

        set widgets($level) [winfo children $widget]
        foreach child $widgets($level) {
            set key [lindex [split $child .] end]
            if {[dict exists $mapping $key]} {
                set var [dict get $mapping $key]
                uplevel #0 [list set $var $child]
                _debug_put_line $level "Variable $var mapped to $key"
            }

            if {[llength $widgets($level)] > 0} {
                _map_children $root $child
            }
        }

        _debug_put_line $level "Exit recursion level $level"

        incr level -1

        return
    }

    proc _debug_put_line {level msg} {
        #set indent [string repeat "  " [expr "$level - 1"]]
        #jdebug::print debug "${indent}$msg"
    }

    proc _has_children {w} {
        set children [winfo children $w]
        return [expr "[llength $children] > 0"]
    }

    proc _find {root widget name depth} {
        variable level
        variable widgets
        variable widgetreturn

        assert {$level < $::WidgetMapperRecursionLimit} "Recursion limit of $::WidgetMapperRecursionLimit exceeded"

        if {$depth > 0 && $level >= $depth} return

        incr level 1
        set widgets($level) [winfo children $widget]

        _debug_put_line $level "Children of $widget = [deref widgets($level)]"

        if {$widgetreturn eq ""} {
            set children [deref widgets($level)]

            # Look for $name
            foreach child $children {
                if {[string first $name $child] >= 0} {
                    set widgetreturn $child
                    set children ""
                    break
                }
            }

            # Recurse
            foreach child $children {
                if {[_has_children $child]} {
                    _find $root $child $name $depth
                } else {
                    _debug_put_line [expr $level + 1] "$child has no children"
                }
            }
        }

        incr level -1
    }
}
