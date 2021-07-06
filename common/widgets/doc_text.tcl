[manpage_begin exw_entry n ""]
[copyright "John Russell 2021"]
[titledesc "Create and manipulate expanded multi-line 'text' widgets"]
[moddesc "Expanded Tk Widgets"]
[description]
The [cmd "exw text"] command creates a window (provided by the [arg pathName] argument) and makes
it into an extended [widget text] widget.
At the time this command is invoked, [arg pathName] must not already exist, yet its parent must exist.

[para]
This command creates a megawidget that expands the functionality of the regular [widget text] widget,
giving it some additional traits that weren't present in the original.
For example, the text widget changes its background color based on whether it's disabled or not.

[para]
The following command creates the extended text widget:

[list_begin definitions]
[call exw text [opt [arg options]] [arg pathName] [opt [arg options]]]
[list_end]

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

When an extended text widget is created, its commands can be invoked with [cmd "exw subcmd"].
In addition to these commands there are also a few extended commands, and they are listed below.

[list_begin definitions]
[call exw subcmd [arg pathName] clear]
This command clears all of the text in the widget, provided it is not disabled.

[call exw subcmd [arg pathName] instate [arg statespec] [opt [arg script]]]
This command tests the widget's state.
If [arg script] is not specified, this command returns 1 if the widget state matches
[arg statespec] and 0 otherwise.
If [arg script] is specified, it is evaluated as a Tcl script if the widget state matches [arg statespec].

[call exw state [arg pathName] [arg statespec]]
Modifies the widget state.
[arg statespec] can be either normal or disabled.
Internally, this command calls the [widget text] widget's [cmd configure] command, and the result
of that is returned, be it an empty string or otherwise.
[list_end]

[manpage_end]
