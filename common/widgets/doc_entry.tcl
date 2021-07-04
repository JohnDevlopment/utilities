[manpage_begin exw_entry n ""]
[copyright "John Russell 2021"]
[titledesc "Create and manipulate expanded one-line 'entry' widgets"]
[moddesc "Expanded Tk Widgets"]
[description]
The command [cmd "exw entry"] creates a new window (given by the [arg pathName] argument) and makes
it an expanded [widget ttk::entry] widget.
The options to the left of [arg pathName] must be one of the options listed below.
The options to the right of [arg pathName] are forwarded to the [widget ttk::entry] command.
[cmd "exw entry"] returns [arg pathName].
At the time this command is invoked, [arg pathName] must not already exist while its parent must.

[list_begin definitions]
[call exw entry [opt [arg options]] [arg pathName] [opt [arg options]]]
[list_end]

[section "widget-specific options"]
The options listed in this section must be specified *before* [arg pathName], as it pertains to
this command and not the [widget ttk::entry] widget.

[list_begin tkoption]
[tkoption_def "-maxlen" maxLen MaxLen]
If this option is provided, it specifies the maximum length of the text inside the entry.
It must be greater than zero to take effect.
When active, it causes the entry to reject the adding of characters when the length of the current
string is greater than or equal to this option.
If this option is an empty string it defaults to zero.

[tkoption_def -label label Label]
If this option is provided, it specifies a textual string to display in a label to the left of the
entry widget.
If the option is left out or is an empty string, no label is displayed.

[tkoption_def -scrollx scrollX ScrollX]
When this option is present, a horizontal scrollbar is displayed below the entry widget.
The scrollbar is setup to scroll the entry widget when the textual data inside it gets too big.

[tkoption_def -clearbutton clearButton ClearButton]
If this option is present, a button is display inside the left edge of the entry widget.
When clicked, this button clears all the test inside of the entry widget.
[list_end]

[manpage_end]
