package provide utilities 0.3

namespace eval Random {
    namespace export randi
    namespace ensemble create -command ::random -map {int randi string randstr}

    # Produce a random integer from a range.
    proc randi args {
        set funcname "randi_[llength $args]"
        if {[info proc $funcname] == ""} {
            return -code error "wrong # args: should be one of the following: random int ?min? max"
        }
        tailcall $funcname {*}$args
    }

    proc randi_1 max {tailcall randi_2 0 $max}

    proc randi_2 {min max} {
        return [expr "int(rand() * ($max - $min + 1) + $min)"]
    }

    # Produce a random string of characters with a specified length.
    proc randstr len {
        binary scan A c A
        binary scan z c z
        set result ""

        for {set i 0} {$i < $len} {incr i} {
            set c [binary format c [randi_2 $A $z]]
            if {[regexp {[a-zA-Z_]} $c]} {append result $c}
        }
        return $result
    }
}

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

# Returns an error if EXP evaluates to false.
# Customize the error message with MSG.
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

# Defines a readonly variable. Any subsequent attempts to
# modify the variable result in an error.
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

# Example:
#   set x 0
#   set varName x
#   deref varName
proc deref {varName} {
    upvar $varName Var
    return $Var
}

# Used to create a lambda function. Uses the same syntax as proc.
proc lambda {args body} {
    set namespace [uplevel 1 namespace current]
    return [list ::apply [list $args $body $namespace]]
}

proc lflat args {
    set lResult [list]
    foreach e $args {
        append lResult {*}$e
    }

    return $lResult
}

# Postfix increment function. Returns the old value.
proc pincr {var {i 1}} {
    upvar $var Var
    set temp $Var
    incr Var $i
    return $temp
}

# Sets a temporaru variable.
proc settemp {sVar sValue} {
    uplevel [list set $sVar $sValue]
    uplevel [subst {
        after idle {unset $sVar}
    }]

    return
}
