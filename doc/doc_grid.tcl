[manpage_begin exw_grid n ""]
[titledesc "Grid-based geometry manager"]
[include widgets-meta.tcl]
[description]
The subject of this document, [cmd "exw grid"] is a wrapper for Tcl command [cmd grid], for use with
this package's expanded widgets.

[list_begin definitions]
[call exw grid [arg slave] [opt [arg "slave ..."]] [opt options]]
[cmd "exw grid"] is a wrapper for Tcl's [cmd grid]; as such it accepts all the options that [cmd grid] does.
[arg slave] can be any one of the arguments specified in [sectref OPTIONS].
At least one widget path must be provided.
[list_end]

[section OPTIONS]

[arg slave] can be any one of the following:

[list_begin definitions]
[def [arg pathname]]
A path to a widget: it can, but doesn't have to be, one of our expanded widgets.

[def x]
This leaves an empty column between the [arg slave] on its left and the [arg slave] on its right.

[def ^]
This extends the row span of the [arg slave] above the ^'s in the grid.
The number of ^'s in a row must match the number of columns spanned by the [arg slave] above it.

[def -]
Increases the column span of the [arg slave] to the left.
Several of these will successively increase the number of columns spanned.
A - may not follow a ^ or a x, nor may it be the first [arg slave] argument to [cmd "exw grid"].
[list_end]

Options that apply to [cmd grid] apply to this command as well.

[see_also [emph grid](n)]

[manpage_end]
