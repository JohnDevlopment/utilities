[manpage_begin exw_text n ""]
[titledesc "Create and manipulate expanded multi-line 'text' widgets"]
[include widgets-meta.tcl]
[vset class text]
[vset widget text]
[description]
[include widgets-description-template.tcl]

[para]
This command creates a megawidget that expands the functionality of the regular [widget text] widget,
giving it some additional features that weren't present in the original.

[include widgets-options-header.tcl]

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

[include widgets-commands-header.tcl]

[include widgets-commands-std.tcl]

[subsection "Widget-Specific Commands"]

[list_begin definitions]
[call exw subcmd [arg pathName] clear]
Clears the text widget, provided it is enabled.
[list_end]

[section Examples]

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
