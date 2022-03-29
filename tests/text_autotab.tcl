package require Tk

pack [text .text -background white -selectbackground #3465A4 -selectforeground white -width 100 -height 30]

.text insert end "Hello world!\n  Hello tabs!"

bind Text <Return> {
    tk::TextInsert %W "\n[tk::TextGetLeadingSpace %W]"
    if {[%W cget -autoseparators]} {
        %W edit separator
    }
}

bind Text <Shift-Return> {
    tk::TextInsert %W \n
    if {[%W cget -autoseparators]} {
        %W edit separator
    }
}

proc tk::TextGetLeadingSpace {w} {
    set lineToCursor [$w get "insert linestart" "insert lineend"]
    if {[regexp {^[ \t]+} $lineToCursor lineSpaces]} {
        return $lineSpaces
    }
    return
}
