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
[nl][nl]
[arg specs] is a list of lists where each element specifies an option in the form: [arg flag] [opt [arg default]]
If [arg flag] ends in ".arg" the option accepts an argument from the commandline.
Otherwise the option is a boolean flag that is set to 1 if present.
[nl][nl]
[arg argVar] is the name of the variable that holds the commandline options to be processed.
In practical applications, this function will be called inside a procedure, so this will always be "args".
[nl][nl]
This function's result is put inside [arg dataVar].
It is an array where each index is the name of an option found in [arg specs].
The value of each option is mapped to its corresponding index in the array, be they user-defined
or defaults.
[list_end]

[manpage_end]
