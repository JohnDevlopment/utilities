[subsection "Standard Commands"]
[list_begin definitions]
[call exw [vset class] [opt [arg options]] [arg pathName] [opt [arg identifier]] [opt [arg options]]]
This function creates the widget; it is described thoroughly in [sectref Description].

[call exw focus [opt "-displayof [arg pathName]"]]
Returns the path name of the focus window for the display of the main window or for the display containing
[arg pathName] if [arg -displayof] is provided.
In either case, an empty string is returned if the application has no focus on the given display.
Note: [arg -displayof] is neccessary for this command to work in applications that use multiple displays.

[call exw focus [arg pathName]]
If the application currently has the input focus on [arg pathName]'s display, this command resets the focus
to be on [arg pathName] for its display, and returns an empty string.
If the application does not have the focus, then [arg pathName] will be remembered as the focus
for its top level; when the application is given focus again, it will redirect that focus to [arg pathName].
This command does nothing if [arg pathName] is an empty string.

[call exw focus -force [arg pathName]]
Sets the focus of [arg pathName]’s display to [arg pathName], even if the application does not currently have the input
focus for the display.
This command should be used sparingly, if at all.
In normal usage, an application should not claim the focus for itself; instead, it should wait for the window manager to give it the focus.
If [arg pathName] is an empty string then the command does nothing.

[call exw instate [arg pathName] [arg statespec] [opt [arg script]]]
This command tests the widget's state.
If [arg script] is not specified, this command returns 1 if the widget state matches [arg statespec] and 0 otherwise.
If [arg script] is specified, equivelent to
[example "if {\[exw instate [arg pathname] [arg statespec]]} [arg script]"]

[call exw subcmd [arg pathName] [arg subcommand] [opt args...]]
Call one of the underlying [vset class]'s underlying commands, if it is not one of the commands listed here.

[call exw state [arg pathName] [arg statespec]]
Modifies the widget state.
For the [widget text] widget, [arg statespec] can be either normal or disabled.
Functionally, this is the same as [example "[arg pathName].[vset class] configure -state [arg statespec]"]
However, for the ttk widgets, [arg statespec] is in the format allowed by [cmd "[arg pathname] state"] in [emph ttk::widget(n)].

[call [arg identifier] cmd [opt args...]]
If [arg identifier] is provided to the [cmd "exw [vset class]"] command, then it is available as a command.
It acts as a shorthand for [cmd "exw subcmd"].

[para]
The command [example "[arg identifier] COMMAND"] is analogous to [example "exw subcmd [arg pathname] COMMAND"]
[list_end]

[see_also ttk::widget(n)]
