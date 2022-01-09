package require tk_widgets

exw tree .tree -columns {CI CAm CWhat} -height 5
exw pack .tree

set temp {
    {I am Fred}
    {I am Tom}
    {I am pie}
}
foreach a $temp {
    exw subcmd .tree insert {} end -values $a
}
unset a temp

ttk::button .search -text Search -command {
    catch {exw subcmd .tree search 2 Tom} result
    puts $result
}
pack .search
