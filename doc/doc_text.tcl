[manpage_begin exw_text n ""]
[titledesc "Create and manipulate expanded multi-line 'text' widgets"]
[include ../../inc/widgets-meta.tcl]
[description]
The [cmd "exw text"] command creates a window (provided by the [arg pathName] argument) and makes
it into an extended [widget text] widget.
At the time this command is invoked, [arg pathName] must not already exist, yet its parent must exist.
If the optional [arg identifier] argument is specified, a command named after it will be created.
At the time of this widget's creation, there must not already be a command named [arg identifier].
In addition, [arg identifier] cannot have any hyphens or periods.

[para]
This command creates a megawidget that expands the functionality of the regular [widget text] widget,
giving it some additional features that weren't present in the original.
The options listed below talk about these features.

[section "command-specific options"]

[list_begin opt]
[opt_def -wrap "( word | char | none )"]
Specifies the way the widget will handle lines in the text that are too long to display on one
screen line.
If the option is [emph none], the text line will be displayed on exactly one line on the screen;
extra characters that do not fit on the screen are simply not displayed.
In the other modes the text line is split across two or more screen lines.
In [emph char] mode the line break may occur after any character; in [emph word] the line break
is made only after a word boundary.

[opt_def -maxlen [arg number]]
Specifies the maximum number of lines that can be contained in the text box.
If omitted, this option defaults to 0, which causes the text box to have no such limit.
This option must be a valid whole integer.

[opt_def -scrolly]
If this option is present, a vertical scrollbar is displayed on the right side of the text widget.

[opt_def -disabledbackground [arg color]]
Specifies the background color to use when the widget is disabled.
If this option is omitted or is an empty string, it defaults to the background color [widget ttk::entry]
uses when it is disabled.
[list_end]

[section "widget command"]
When an extended text widget is created, a number of commands are made available.
If a command other than any listed below is used, it is interpreted as a [widget text] widget
command (see related documentation).

[list_begin definitions]
[call exw text [opt [arg options]] [arg pathName] [opt [arg identifier]] [opt [arg options]]]
See [sectref DESCRIPTION].

[call exw subcmd [arg pathName] clear]
Clears the text widget, provided it is enabled.

[call exw subcmd [arg pathName] instate [arg statespec] [opt [arg script]]]
This command tests the widget's state.
If [arg script] is not specified, this command returns 1 if the widget state matches [arg statespec]
and 0 otherwise.
If [arg script] is specified, it is evaluated as a Tcl script if the widget state matches [arg statespec].

[call exw state [arg pathName] [arg statespec]]
Modifies the widget state.
[arg statespec] can be either normal or disabled.
Functionally, this is the same as [concat [arg pathName].text configure -state [arg statespec]].

[call [arg identifier] cmd [opt args...]]
As mentioned above, specifiying [arg identifier] at the creation of the text widget will result
in the creation of this command.
It works as a shortcut to the widget commands so the programmer doesn't have to recall the window path all the time.
[list_end]

[section examples]

[para]
Create a textbox with a vertical scrollbar using the identifier [emph TEXTBOX].

[example_begin]
exw text -scrolly .textbox TEXTBOX -state normal
exw pack .textbox

# Commands with identifier
TEXTBOX instate normal {puts normal}
TEXTBOX clear
TEXTBOX state disabled

# Alternate method
exw subcmd .textbox instate normal {puts normal}
exw subcmd .textbox clear
exw state .textbox disabled
[example_end]

[manpage_end]
