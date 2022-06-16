package require tk_widgets

set button 0

proc cmdbutton {text script} {
    global button
    set w ".bt[incr button]"
    set cmd [join [list $script "destroy $w"] "\n"]
    ttk::button $w -text $text -command $cmd
    pack $w -fill x
    return $w
}

exw entry .entry
exw text -wrap word .text
exw tree .tree

foreach w {.entry .text .tree} {
    exw pack $w -fill x
}

exw subcmd .entry insert end ......
exw state .entry readonly

cmdbutton "Test 'exw instate'" {
    exw instate .entry readonly {puts ".entry readonly"}
    exw instate .entry !readonly {puts ".entry not readonly"}
    exw instate .tree !readonly {puts ".tree not readonly"}
}
