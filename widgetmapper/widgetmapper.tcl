##################################################
# Widget Mapper
##################################################

package require utilities
package require jdebug

const WidgetMapperRecursionLimit 10

namespace eval WidgetMapper {
    variable level
    variable widgets; array set widgets {0 ""}
    variable widgetreturn
    variable map_options; array set map_options {0 ""}
    variable mapping
    variable data

    namespace import ::Options::getoptions

    proc find {start name} {
        if {[string first . $name] >= 0} {
            return -code error -errorcode [list TCL INVALID PARAM] \
                "invalid parameter '$name', cannot contain dots"
        }

        variable level
        variable widgets
        variable widgetreturn

        set level 0
        array set widgets {0 ""}
        set widgetreturn ""

        jdebug::print debug "Starting point: $start, looking for $name"

        _find $start $start $name

        return $widgetreturn
    }

    proc map_widgets {start args} {
        variable map_options; array set map_options {0 ""}
        variable widgets; array set widgets {0 ""}
        variable level 0
        variable mapping ""

        set mapMode 0
        set args [lmap opt $args {
            if {$mapMode} {
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

        jdebug::print debug "Mapping: $mapping"

        set specs {
            {depth.arg 0}
        }
        getoptions $specs map_options args

        tailcall _map_children $start $start
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
    }

    proc _debug_put_line {level msg} {
        set indent [string repeat "  " [expr "$level - 1"]]
        jdebug::print debug "${indent}$msg"
    }

    proc _has_children {w} {
        set children [winfo children $w]
        return [expr "[llength $children] > 0"]
    }

    proc _find {root widget name} {
        variable level
        variable widgets
        variable widgetreturn

        if {$level >= $::WidgetMapperRecursionLimit} {
            return -code error "Recursion limit of $::WidgetMapperRecursionLimit exceeded"
        }

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
                    _find $root $child $name
                } else {
                    _debug_put_line [expr $level + 1] "$child has no children"
                }
            }
        }

        incr level -1
    }
}
