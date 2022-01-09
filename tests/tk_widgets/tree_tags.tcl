package require tk_widgets
package require utilities

exw tree .tree TREE -columns {CI CAm CWhat} -height 5
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

after idle {
    TREE tag configure RED -foreground red
    TREE tag add RED I002
}
