package provide timer 1.0

# Pretend that is is version 1.0-beta, because Tcl doesn't correctly load this package when
# the index uses an unstable version number.

package require utilities 1.1
package require jdebug

set TIMERDIR [file dirname [lindex [dict get [info frame -1] cmd] 1]]

namespace eval ::priv::Timer {
    variable refcount 0
    variable timers

    proc _enableProcess {} {
        #
    }

    proc _disableProcess {} {
        #
    }

    proc reference obj {
        variable refcount
        variable timers

        set oldCount [pincr refcount]
        jdebug::print debug "Incremented reference count of Timer from $oldCount to $refcount"
        if {! $oldCount} _enableProcess

        lappend timers $obj
    }

    proc unreference obj {
        variable refcount
        variable timers

        # Decrement the reference count and cancel the event
        # loop if the reference count is now zero.
        set oldCount [pincr refcount -1]
        jdebug::print debug "Decremented reference count of Timer from $oldCount to $refcount"
        if {! $refcount} _disableProcess

        # This effectively deletes $obj from the list.
        set timers [lmap timer $timers {
            if {$timer ne $obj} {set timer}
        }]
    }
}

# Timer class.
oo::class create Timer {
    # Usage: Timer new
    constructor {} {
        ::priv::Timer::reference [self]

        my variable elapsed
        set elapsed 0

        my variable remaining
        set remaining 0

        my variable started
        set started false

        my variable onCompleted
        array set onCompleted {}

        my variable afterID
        set afterID ""
    }

    destructor {
        my stop
        ::priv::Timer::unreference [self]
    }

    method start time {
        my stop

        my variable elapsed
        my variable remaining
        my variable started
        my variable afterID

        set started true
        set remaining $time
        set elapsed 0

        set afterTime [expr "int($time * 1000.0)"]
        set afterID [after $afterTime [list [self] eval_after]]
    }

    method stop {} {
        my variable elapsed
        my variable remaining
        my variable started
        my variable afterID

        set started false
        set remaining 0
        set elapsed 0

        if {$afterID ne ""} {
            after cancel $afterID
            set afterID ""
        }
    }

    # This method should be considered private. The only reason I didn't
    # prepend an underscore is because then it wouldn't be callable with 'after'.
    method eval_after {} {
        my variable afterID
        my variable afterScript

        # Evaluate script if nonempty
        if {$afterScript ne ""} {
            return [uplevel #0 $afterScript]
        }

        return
    }

    # Sets the script which gets evaluated after the timer goes off.
    # If any of the commands is "FREE", replace that with a destroy command
    method set_script script {
        my variable afterScript

        set freeCmd "after idle {[self] destroy}"
        set script [regsub -all {\n+} $script {;}]
        regsub {\s*FREE\s*} $script $freeCmd afterScript

        jdebug::print debug "Set after-script to \"$afterScript\""
    }

    method _bgerror message {
        # TODO: implement bgerror function
        jdebug::print error $message
    }
}
