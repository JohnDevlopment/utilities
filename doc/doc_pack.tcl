[manpage_begin exw_pack n ""]
[titledesc "Pack-based geometry manager for expanded widgets"]
[include widgets-meta.tcl]
[description]
The subject of this document, [cmd "exw pack"] is a wrapper for Tcl command [cmd pack], for use with
this package's expanded widgets.

[list_begin definitions]
[call exw pack [arg pathname] [opt [arg pack_options...]]]
Arrange for [arg pathname] to be packed with [cmd pack].
[arg pathname] is a widget created from any of the [cmd "exw WIDGET"] commands.
After [arg pathname], you can pass any number of options supported by [cmd pack] (see the relevant manual).
[list_end]

[manpage_end]
