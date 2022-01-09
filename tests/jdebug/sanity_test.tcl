#!/usr/bin/env tclsh
package require jdebug

proc printAllDebug {} {
    puts "###############################"
    foreach level {trace debug info warn error fatal} {
        jdebug::print $level "debug message"
    }
    puts "###############################"
}

jdebug::on

foreach level {all trace debug info warn error fatal} {
    jdebug::level $level
    printAllDebug
}
