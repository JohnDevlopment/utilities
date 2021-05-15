package provide utilities 0.2

namespace eval tcl {
    namespace eval mathfunc {
        proc clamp {value min max} {
            if {$value < $min} {
                return $min
            } elseif {$value > $max} {
                return $max
            }

            return $value
        }
    }
}

# Example:
#   set x 0
#   set varName x
#   deref $varName
proc deref {varName} {
    upvar $varName Var
    return $Var
}

proc const {varName value} {
    namespace eval ::constants {namespace current}

    if {$varName == ""} {
        error "empty var name"
    } elseif {! [regexp "^\[a-zA-z]+\[0-9_]*" $varName]} {
        error "invalid var name \"$varName\", must start with a letter."
    }

    upvar $varName Var
    set Var $value

    set "::constants::${varName}_original" $value

    trace add variable Var write {apply {{name1 name2 op} {
        if {$op == "write"} {
            upvar $name1 Var
            set Var [subst "\$::constants::${name1}_original"]
            return -code 1 "Cannot rewrite value of constant \"$name1\""
        }
        return
    }}}
}

proc assert {exp {msg ""}} {
    if {$msg == ""} {
        set msg "Assertion failed: $exp"
    }

    set passed [uplevel "expr $exp"]

    if {! $passed} {
        return -code 1 $msg
    }

    return
}

proc lambda {args body} {
    set namespace [uplevel 1 namespace current]
    return [list ::apply [list $args $body $namespace]]
}

proc lflat {args} {
    set lResult [list]
    foreach e $args {
        append lResult {*}$e
    }

    return $lResult
}

proc settemp {sVar sValue} {
    uplevel [list set $sVar $sValue]
    uplevel [subst {
        after idle {unset $sVar}
    }]

    return
}

proc pincr {var {i 1}} {
    upvar $var Var
    set temp $Var
    incr Var $i
    return $temp
}
