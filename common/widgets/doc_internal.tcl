[manpage_begin exWidgets n "0.1.0-beta"]
[titledesc "Internal functions in the exWidgets namespace"]
[copyright "John Russell 2021"]
[moddesc "Expanded Tk Widgets"]
[description]
This man page describes all of the internal functions that can be found in the
[namespace exWidgets] namespace.

[section api]

[list_begin definitions]
[call ::exWidgets::parseOptions [arg dataVar] [arg specs] [arg argVar]]
This function is used to parse commandline options.
[arg dataVar] is the name of a variable that will hold the values of each option.
It is an array where each index is the name of an option without the leading '-'.

[para]
[arg specs] is a list of lists where each element specifies an option in the form: [arg flag] [opt [arg default]]
If [arg flag] ends in ".arg" the option accepts an argument from the commandline.
Otherwise the option is a boolean flag that is set to 1 if present.

[para]
[arg argVar] is the name of the variable that holds the commandline options to be processed.
In practical applications this function will be called inside a procedure, so this will always be "args".

[para]
This function's result is put inside [arg dataVar].
It is an array where each index is the name of an option found in [arg specs].
The value of each option is mapped to its corresponding index in the array, be they user-defined
or defaults.

[para]
The result of this function is that [arg dataVar] will contain all the options and their values,
and [arg argVar] will be modified to contain the remainder of the commandline.
This function emits an error if an unknown option is found, and stops processing options if a
nonoption is found.

[call ::exWidgets::valid [arg name] [arg specs]]
Returns a string listing all the valid options are the command named by [arg name].
[arg specs] is a list of options and their defaults, formatted the same way as the [arg specs]
argument in [cmd ::exWidgets::parseOptions].

[call ::exWidgets::popFront [arg listVar]]
Removes the first element of the list contained in [arg listVar] and returns said element.
This is used frequently in the widget functions.

[call ::exWidgets::subcmd [arg pathname] [arg cmd] [opt [arg arg]]]
This command is not currently used.

[call ::exWidgets::validCommands]
Returns a string with all the valid exported commands in this namespace; i.e., tk_entry.
[list_end]

[manpage_end]
