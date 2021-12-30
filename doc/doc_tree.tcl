[manpage_begin exw_tree n ""]
[titledesc "Create and manipulate expanded 'ttk::treeview' widgets"]
[include widgets-meta.tcl]
[vset class tree]
[vset widget ttk::treeview]
[description]
[include widgets-description-template.tcl]

[include widgets-options-header.tcl]

[list_begin opt]
[opt_def -scrollx]
If this option is present, a horizontal scrollbar is displayed at the bottom of the widget.

[opt_def -scrolly]
If this option is present, a vertical scrollbar is displayed on the right side of the widget.

[opt_def -headings [arg list]]
A list consisting of column-heading pairs: for each column, its associated heading displays the string following it.
Each column must be valid according to the section [sectref-external "COLUMN IDENTIFIERS"] under [emph ttk::treeview(n)].

[para]
Example: [example "{FirstColumn First SecondColumn Second}"]
[list_end]

[include widgets-commands-header.tcl]

[include widgets-commands-std.tcl]

[subsection "Widget-Specific Commands"]

[list_begin definitions]
[call exw subcmd [arg pathname] clear]
Clears the entire tree.

[call exw subcmd [arg pathname] itemindex [arg index]]
Finds and returns the item in the tree located at [arg index].
It is any index understood by [cmd lindex].

[call exw subcmd [arg pathname] search [opt [arg options]] [arg column] [arg pattern]]
Searches the entire tree for an item whose [arg column] matches [arg pattern].
If a match is found, the ID of the item which contains the matched value is returned;
otherwise an empty string is returned.
This function expects [arg column] to be a valid column identifier per the definition under
[sectref-external "COLUMN IDENTIFIERS"] in [emph ttk::treeview(n)].

[para]
How [arg pattern] is matched can be controlled through the [option -glob], [option -regex], or [option -exact] commandline options.
If [option -glob] is provided, glob-style matching is used in the vein of [cmd "string match"].
If [option -regex] is provided, a regular expression is used.
And if [option -exact] os provided, a simple string comparison is done instead and the text must match [arg pattern] exactly.
[option -glob] is the default matching style if no options are passed.
[list_end]

[see_also ttk::treeview(n)]

[manpage_end]
