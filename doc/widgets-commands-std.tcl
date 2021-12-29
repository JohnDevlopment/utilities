[subsection "Standard Commands"]
[list_begin definitions]
[call exw [vset class] [opt [arg options]] [arg pathName] [opt [arg identifier]] [opt [arg options]]]
This function creates the widget; it is described thoroughly in [sectref Description].

[call exw subcmd [arg pathName] instate [arg statespec] [opt [arg script]]]
This command tests the widget's state.
If [arg script] is not specified, this command returns 1 if the widget state matches [arg statespec]
and 0 otherwise.
If [arg script] is specified, it is evaluated as a Tcl script if the widget state matches [arg statespec].

[call exw state [arg pathName] [arg statespec]]
Modifies the widget state.
[arg statespec] can be either normal or disabled.
Functionally, this is the same as [example "[arg pathName].[vset class] configure -state [arg statespec]"]

[call [arg identifier] cmd [opt args...]]
If [arg identifier] is provided to the [cmd "exw [vset class]"] command, then the command named [arg identifier] is available.
It acts as a shorthand for [cmd "exw subcmd"].

[para]
The command [example "[arg identifier] COMMAND"] is analogous to [example "exw subcmd [arg pathname] COMMAND"].
[list_end]
