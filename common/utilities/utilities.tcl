package provide utilities 0.51

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

proc ::tcl::mathfunc::clamp {value min max} {
    if {$value < $min} {
        return $min
    } elseif {$value > $max} {
        return $max
    }

    return $value
}

namespace eval ::constants {namespace current}

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
    set constName "::constants::${varName}_original"

    # Cannot redefine a constant.
    if {[info exists $constName]} {
        return -code error "$varName already exists"
    }

    # Parameter errors
    if {$varName == ""} {
        return -code error "empty var name"
    } elseif {! [regexp "^\[a-zA-z]+\[0-9_]*" $varName]} {
        return -code error "invalid var name \"$varName\", must start with a letter."
    }

    upvar $varName Var
    set Var $value

    # Trace function
    set lambda {apply {{name1 name2 op} {
        if {$op eq "write"} {
            upvar $name1 Var
            set Var [subst "\$::constants::${name1}_original"]
            return -code 1 "\"$name1\" is a readonly"
        } elseif {$op eq "unset"} {
            unset -nocomplain "::constants::${name1}_original"
        }
        return
    }}}

    set $constName $value
    trace add variable Var write $lambda
    trace add variable Var unset $lambda

    return $value
}

# Example:
#   set x 0
#   deref x => returns 0
proc deref {varName} {
    upvar $varName Var
    return $Var
}

# Implements a do-while loop.
# Executes SCRIPT once; then, while COND evaluates to true, continues to execute SCRIPT.
# WORD must be equal to "while".
proc do {script word cond} {
    if {$word ne "while"} {
        return -code error "second parameter wrong: must be \"while\""
    }

    set condCmd [list expr $cond]

    uplevel $script
    while {[uplevel $condCmd]} {uplevel $script}

    return
}

# Returns the value of the variable VAR or DEF if it doesn't exist.
proc get {var {def ""}} {
    upvar $var Var
    if {[catch {set res $Var}]} {set res $def}
    return $res
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

proc lremove {varname begin {end -1}} {
    upvar $varname ListVar

    # Convert "end" to the actual end index
    set len [llength $ListVar]

    # Calculate start index
    set beginExpr [split $begin]
    set begin [lindex $beginExpr 0]
    if {$begin eq "end"} {
        set begin [expr "$len - 1"]
        set beginExpr [lreplace $beginExpr 0 0 $begin]
    }

    # Calculate end index
    set endExpr [split $end]
    set end [lindex $endExpr 0]
    if {$end eq "end"} {
        set end [expr "$len - 1"]
        set endExpr [lreplace $endExpr 0 0 $end]
    }
    if {$end < $begin} {
        set end $begin
        set endExpr [lreplace $endExpr 0 0 $end]
    }

    set temp [lreplace $ListVar $beginExpr $endExpr]
    set ListVar $temp

    return
}

# Postfix increment function. Returns the old value.
proc pincr {var {i 1}} {
    upvar $var Var
    set temp $Var
    incr Var $i
    return $temp
}

namespace eval ::deletequeue {
    variable vars ""
    variable afterid ""

    namespace export settemp processQueue

    proc processQueue {} {
        variable vars
        variable afterid

        foreach v $vars {unset -nocomplain $v}

        set afterid ""
        set vars ""
    }

    proc settemp {var {value ""}} {
        set frame [info frame -1]
        if {[dict get $frame type] eq "proc"} {
            return -code error "Do not call settemp within a procedure!"
        }
        namespace upvar ::deletequeue vars Vars
        namespace upvar ::deletequeue afterid AfterID

        # Set the value of the variable
        uplevel [list set $var $value]

        if {! [regexp {(::[a-z_]+)+} $var]} {
            set ns [uplevel {namespace current}]
            if {$ns eq "::"} {
                lappend Vars "${ns}$var"
            } else {
                lappend Vars [join [concat $ns $var] ::]
            }
        }

        if {$AfterID eq ""} {
            set AfterID [after idle ::deletequeue::processQueue]
        }

        return $value
    }
}

namespace import ::deletequeue::settemp
