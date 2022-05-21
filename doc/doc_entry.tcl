[manpage_begin exw_entry n ""]
[titledesc "Create and manipulate expanded one-line 'entry' widgets"]
[include widgets-meta.tcl]
[vset class entry]
[vset widget ttk::entry]
[description]
[include widgets-description-template.tcl]

[include widgets-options-header.tcl]

[list_begin opt]
[opt_def -allowedchars [arg expr]]
If this option is present, it defines a regular expression which specifies what characters are
allowed to be inserted.
It is matched against each character as it is inserted, so the regular expression should be written
with that in mind.

[opt_def -clearbutton]
If this option is present, a button is display inside the right edge of the entry widget that,
when pressed, clears all of the text inside the entry.

[opt_def -label [arg text]]
If this option is provided, it specifies a textual string to display in a label above the entry widget.
If the option is left out or is an empty string, no label is displayed.

[opt_def -maxlen [arg number]]
If this option is provided, it specifies the maximum length of the text inside the entry.
It must be greater than zero to take effect.
When active, it causes the entry to reject the adding of characters when the length of the current
string is greater than or equal to this option.
If this option is left out or is an empty string it defaults to zero.

[opt_def -scrollx]
When this option is present, a horizontal scrollbar is displayed below the entry widget.
The scrollbar is setup to scroll the entry widget when the textual data inside it gets too big.
[list_end]

[include widgets-commands-header.tcl]

[include widgets-commands-std.tcl]

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
