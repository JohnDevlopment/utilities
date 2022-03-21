package require timer
package require jdebug
package require Tk

jdebug::on
jdebug::level debug

set ExitScript {
    catch {$timer1 destroy}
    exit
}

wm title . "Title"
wm geometry . 320x240
wm protocol . WM_DELETE_WINDOW $ExitScript

set timer1 [Timer new]
$timer1 set_script $ExitScript

pack [ttk::button .btStart -text "Start Timer" -command {
    .btStart state disabled
    $timer1 start 2
}]

pack [ttk::entry .enThing]

pack [ttk::button .btQuit -text Quit -command $ExitScript]
