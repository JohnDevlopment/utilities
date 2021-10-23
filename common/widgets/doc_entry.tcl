[manpage_begin exw_entry n ""]
[titledesc "Create and manipulate expanded one-line 'entry' widgets"]
[include ../../inc/widgets-meta.tcl]
[description]
The command [cmd "exw entry"] creates a new window (given by the [arg pathName] argument) and makes
it an expanded [widget ttk::entry] widget.
Options, listed in the section below, can be specified on the commandline to the left of [arg pathName].
Options to the right of [arg pathName] are forwarded as-is to the [widget ttk::entry] command.
(See the related documentation for details.)
The path to the newly created window is returned.
At the time this command is invoked [arg pathName] must not already exist, yet its parent must exist.

[para]
If [arg identifier] is specified a command of the same name is created.
At the time this command is invoked, [arg identifier] must not already exist as a command.
[arg identifier] cannot have any hyphens or periods.
See the section [sectref "WIDGET COMMAND"] for a complete description of this command.

[section "widget-specific options"]
The options listed below are only recognized when put to the left of [arg pathName].
They are write-only options that can be specified only at the creation of this widget.

[list_begin opt]
[opt_def "-maxlen"]
If this option is provided, it specifies the maximum length of the text inside the entry.
It must be greater than zero to take effect.
When active, it causes the entry to reject the adding of characters when the length of the current
string is greater than or equal to this option.
If this option is left out or is an empty string it defaults to zero.

[opt_def -label [arg text]]
If this option is provided, it specifies a textual string to display in a label to the left of the
entry widget.
If the option is left out or is an empty string, no label is displayed.

[opt_def -scrollx]
When this option is present, a horizontal scrollbar is displayed below the entry widget.
The scrollbar is setup to scroll the entry widget when the textual data inside it gets too big.

[opt_def -clearbutton]
If this option is present, a button is display inside the right edge of the entry widget that,
when pressed, clears all of the text inside the entry.
[list_end]

[section "widget command"]
After the entry widget is created, a number of subcommands are available.

[list_begin definitions]
[call exw entry [opt [arg options]] [arg pathName] [opt [arg identifier]] [opt [arg options]]]
This command creates a new extended entry widget located at [arg pathName].
The options to the left of [arg pathName] shall be one or more of the options listed above.
The options to the right can be any of the valid options for [widget ttk::entry].
If this command succeeds [arg pathName] is returned.

[call exw state [arg pathName] [arg statespec]]
Modify or inquire widget state.
If stateSpec is present, sets the widget state: for each flag in stateSpec, sets the corresponding
flag or clears it if prefixed by an exclamation point. (Source: https://tcl.tk/man/tcl8.6/TkCmd/ttk_widget.htm#M21)
Functionally, this is the same as [concat [arg pathName].text configure -state [arg statespec]].

[call exw subcmd [arg pathName] [arg cmd] [opt args...]]
This lets you access any of the entry's widget commands.
This command is equivelent to [concat [arg pathName].entry [arg cmd] [opt args...]].

[call [arg identifier] [arg cmd] [opt args...]]
Use this command as an alternative to [cmd "exw subcmd"].
[arg identifier] forwards its arguments to the command [arg pathName].
[list_end]

[section examples]

[para]
Create an entry with a max length of thirty characters.
No identifier is specified.

[example_begin]
exw entry -maxlen 30 .without
exw pack .without
exw subcmd .without insert end "I am a good programmer!"
[example_end]

[para]
Creates an entry with the identifier [emph ENTRY].

[example_begin]
exw entry .with ENTRY
exw pack .with
ENTRY insert end "I am a good programmer!"
[example_end]

[manpage_end]
