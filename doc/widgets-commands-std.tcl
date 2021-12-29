[subsection "Standard Commands"]
[list_begin definitions]
[call exw [vset class] [opt [arg options]] [arg pathName] [opt [arg identifier]] [opt [arg options]]]
This function creates the widget; it is described thoroughly in [sectref Description].

[call exw subcmd [arg pathName] instate [arg statespec] [opt [arg script]]]
This command tests the widget's state.
If [arg script] is not specified, this command returns 1 if the widget state matches [arg statespec] and 0 otherwise.
If [arg script] is specified, it is evaluated as a Tcl script if the widget state matches [arg statespec].

[call exw state [arg pathName] [arg statespec]]
Modifies the widget state.
For the [widget text] widget, [arg statespec] can be either normal or disabled.
But for the others, [arg statespec] is the same as in [emph ttk::widget(n)].
Functionally, this is the same as [example "[arg pathName].[vset class] configure -state [arg statespec]"]
However, for the ttk widgets, [arg statespec] is in the format allowed by [cmd "[arg pathname] state"] in [emph ttk::widget(n)].

[call [arg identifier] cmd [opt args...]]
If [arg identifier] is provided to the [cmd "exw [vset class]"] command, then it is available as a command.
It acts as a shorthand for [cmd "exw subcmd"].

[para]
The command [example "[arg identifier] COMMAND"] is analogous to [example "exw subcmd [arg pathname] COMMAND"]
[list_end]

[see_also ttk::widget(n)]
