package provide utilities 1.2

# Define NDEBUG if it doesn't exist
if {! [info exists NDEBUG]} {set NDEBUG 1}

# If DEBUG is set in the enviroment, NDEBUG is set to 1
if {[info exists env(DEBUG)] && $env(DEBUG)} {
    set NDEBUG 0
}

namespace eval Random {
    namespace export randi
    namespace ensemble create -command ::random -map {float randf int randi string randstr}

    # Produce a random float from a range.
    proc randf args {
        set funcname "randf_[llength $args]"
        if {[info proc $funcname] == ""} {
            return -code error -errorcode {TCL WRONGARGS} \
                "wrong # args: should be \"random float ?min? max\""
        }
        tailcall $funcname {*}$args
    }

    proc randf_1 max {tailcall randf_2 0 $max}

    proc randf_2 {min max} {
        return [expr "rand() * ($max - $min + 1) + $min"]
    }

    # Produce a random integer from a range.
    proc randi args {
        set funcname "randi_[llength $args]"
        if {[info proc $funcname] == ""} {
            return -code error -errorcode {TCL WRONGARGS} \
                "wrong # args: should be \"random int ?min? max\""
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

proc ::tcl::mathfunc::snapped {value {step 1.0}} {
    if {$step != 0.0} {
        set value [expr "floor($value / $step + 0.5) * $step"]
    }
    return $value
}

# Returns an error if EXP evaluates to false.
# Customize the error message with MSG.
if {! $NDEBUG} {
    proc assert {exp {msg ""}} {
        #set msg ""
        #set exp ""

        #Options::getoptions fatal opts args

        if {$msg == ""} {
            set msg "Assertion failed: $exp"
        }

        set passed [uplevel [list expr $exp]]
        if {! $passed} {
            #return -code 1 $msg
            puts stderr $msg
            exit 1
        }

        return
    }
} else {
    proc assert {exp {msg ""}} {
        # do nothing
        return
    }
}

proc bitset {intVar bit flag} {
    upvar $intVar Int

    if {[string first 0x $bit] == 0} {
        set bit [scan $bit "0x%x"]
    }

    if {$flag} {
        set Int [expr "$Int | $bit"]
    } else {
        set bitmask [expr "$bit ^ -1"]
        set Int [expr "$Int & $bitmask"]
    }

    return
}

namespace eval ::constants {}

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
# WORD must be "while".
proc do {script word cond} {
    if {$word ne "while"} {
        return -code error "second parameter wrong: must be \"while\""
    }

    set condCmd [list expr $cond]

    uplevel $script
    while {[uplevel $condCmd]} {uplevel $script}

    return
}

# Used to create a lambda function. Uses the same syntax as proc.
proc lambda {args body} {
    set namespace [uplevel 1 namespace current]
    return [list ::apply [list $args $body $namespace]]
}

# Removes an element-range from a list pointed to by VARNAME.
# BEGIN is the first index, and the END index, if provided, specifies the last index in the range.
# If END omitted, only one element is removed.
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

# Removes the front element of a list and returns it.
proc popFront {listVar} {
    upvar $listVar List
    set result ""
    if {[llength $List] > 0} {
        set result [lindex $List 0]
        set List [lreplace $List 0 0]
    }
    return $result
}

namespace eval ::deletequeue {
    variable vars ""
    variable afterid ""

    namespace export settemp processQueue

    proc processQueue {} {
        variable vars
        variable afterid ""
        unset -nocomplain {*}$vars
        set vars ""
    }

    # Creates a temporary variable, setting its value to VALUE.
    # The variable is put on a queue, and on the next idle frame, it is unset.
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
                set vname "${ns}$var"
            } else {
                set vname [join [concat $ns $var] ::]
            }

            # Only add to the queue once
            if {$vname ni $Vars} {lappend Vars $vname}
        }

        if {$AfterID eq ""} {
            set AfterID [after idle ::deletequeue::processQueue]
        }

        return $value
    }
}

namespace import ::deletequeue::settemp

namespace eval ::Options {
    namespace export getoptions valid
}

# Mode corresponds to the behavior of traditional C getopt().
# The default is '+', which causes it to stop processing as soon as the first non-option is found
proc ::Options::getoptions {specs optVar argVar {mode +}} {
    if {$optVar eq ""} {
        return -code error "Provide a variable name!"
    }

    if {$argVar eq ""} {
        return -code error "Provide a variable name!"
    }

    upvar $optVar Data

    if { ! [llength $specs] } {
        return -code error "Empty specs argument provided"
    }

    # Build list of allowed options
    foreach spec $specs {
        set opt [lindex $spec 0]
        set optbase [regsub {([a-zA-Z0-9]*)\.arg} $opt {\1}]
        set optarg [lindex $spec 1]

        if {[ regexp {.*\.arg} $opt ]} {
            # Option with argument
            set spectype($optbase) arg
            set Data($optbase) $optarg
        } else {
            # Boolean flag
            set spectype($optbase) bool
            set Data($optbase) 0
        }
    }

    upvar $argVar args

    set specnames [array names spectype]

    set derefArray [lambda {name index} {
        upvar $name Array
        return $Array($index)
    }]

    while {[llength $args] > 0} {
        set opt [popFront args]

        if {[string first - $opt] == 0} {
            # Found an option

            set opt2 [string range $opt 1 end]
            if {$opt2 in $specnames} {
                # Parse option

                if {[eval $derefArray spectype $opt2] eq "arg"} {
                    # Expects an argument

                    if {! [llength $args]} {
                        return -code error -errorcode [list TCL MISSING PARAM $opt2] \
                            "Missing argument for option '-$opt2'"
                    }

                    set optarg [popFront args]
                } else {
                    # Boolean flag
                    set optarg 1
                }

                set Data($opt2) $optarg
            } else {
                # Invalid option
                return -code error -errorcode [list TCL INVALID PARAM $opt2] \
                    "Unknown option '-$opt2'"
            }
        } else {
            # First nonoption reached

            set args [list $opt {*}$args]
            break
        }
    }

    return
}

proc ::Options::valid {name specs} {
    set i 1
    set length [llength $specs]
    set msg ""
    set sep ""

    foreach spec $specs {
        set opt [regsub {([a-zA-Z0-9]*)\.arg} [lindex $spec 0] {\1}]
        set msg "$msg$sep-$opt"
        incr i
        if {$i <= $length} {
            set sep ", "
            if {$i == $length} {append sep "or "}
        } else {
            set sep ""
        }
    }

    return $msg
}

unset NDEBUG
