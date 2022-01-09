try {
    commandthatdoesnotexist
} trap {TCL LOOKUP COMMAND} {err opts} {
    set ec [dict get $opts -errorcode]
    set cmd [lindex $ec end]
    puts stderr "unknown command \"$cmd\""
}
