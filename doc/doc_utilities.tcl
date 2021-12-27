[vset version "1.1"]
[vset pkgVer "1.1`"]
[manpage_begin utilities n [vset version]]
[require utilities [opt [vset pkgVer]]]
[copyright "John Russell 2021"]
[moddesc "Tcl Utility Functions"]
[titledesc "Tcl Utility Functions"]
[description]
This package contains a series of handy utility functions that may aid in the development of
Tcl-based applications.

[section "Public API"]

[list_begin definitions]
[call assert [arg expression] [opt [arg message]]]
If [arg expression] evaluates to false the current program exits with a non-zero status,
indicating an error.
[arg message] is printed to standard error as this happens; if it is omitted, it defaults to the
standard "assertion failed" message.

[para]
To use this function, you need to set [variable NDEBUG] to 0.
This is done automatically if the DEBUG enviroment variable is set to a non-zero value.

[call bitset [arg intVar] [arg bit] [arg flag]]
Set or clear the given [arg bit] in [arg intVar]; set if [arg flag] is true, clear otherwise.

[call const [arg name] [arg value]]
Creates a new variable by the name [arg name] and sets its value to [arg value].
At the time this function is called, [arg name] cannot already exist.
Returns [arg value].

[para]
This function creates a readonly variable: once its value is set upon creation, it cannot be changed
again. Any attempt to do so will result in an error.

[call deref [arg var]]
Returns the value of the variable [arg var].

[call do [arg body] while [arg cond]]
Implements a do-while loop. Evaluates the script [arg body] once and then continues to do so
while [arg cond] evaluates to true.

[call lambda [arg args] [arg body]]
Returns an apply lambda function with the arguments [arg args] and [arg body] as the function body.

[call lremove [arg listVar] [arg begin] [opt [arg end]]]
Removes one or more elements from a list found in the variable [arg listVar].
[arg begin] and [arg end] are index values that specify the start and end of a range of elements to remove.
Indices are interpreted in the same manner as [cmd lreplace].

[para]
Returns an empty string.

[call pincr [arg var] [opt [arg i]]]
Implements a post-fix increment operator in Tcl.
Increments the numeric value in [arg var] by the amount specified by [arg i].
If [arg i] is not provided, then 1 is used as the default.

[para]
The return value is the value of [arg var] prior to the increment.

[call popFront [arg listVar]]
Removes the first element of the list contained in [arg listVar] and returns it.
If the list is empty, so is the return value.

[call settemp [arg var] [opt [arg value]]]
Creates a temporary value that deletes itself at idle time.
Internally, [arg var] gets added to a queue that is processed at the start of the next event loop,
using [cmd {after idle}].
[list_end]

[subsection "Randon Number Generation"]

[list_begin definitions]
[call random integer [opt [arg min]] [arg max]]
Returns a random integer between [arg min] and [arg max].
If [arg min] is omitted, it defaults to zero.

[call random string [arg length]]
Returns a randomly generated string of [arg length] characters.
The string will contain characters between a-z (upper and lowercase) and an underscore.
[list_end]

[subsection "Option Processing"]
These functions belong to the [namespace ::Options] namespace.

[list_begin definitions]
[call getoptions [arg specs] [arg optVar] [arg argvVar]]
Processes commandline options according to the rules defined in [arg specs].

[para]
[arg specs] is a list of lists containing recognized options, where each element takes the form of {option default}.
If the option doesn't contain any special suffixes, the option is treated as a boolean flag:
it is set to true if provided, and false otherwise.
If [emph option] ends in ".arg", the option expects an argument.
[emph default] is used as the argument in the case that such option is not provided.

[para]
The options in [arg argvVar] are put into the array variable [arg optVar], where each index is
an option and its value is the corresponding argument.
[list_end]

[subsection "Expanded Math Functions"]
These functions are defined in the [namespace ::tcl::mathfunc] namespace, so they can be used inside of [cmd expr].

[list_begin definitions]
[call clamp [arg value] [arg min] [arg max]]
Returns [arg value] clamped between the [arg min] and [arg max] values.

[call snapped [arg number] [opt [arg step]]]
Snaps [arg number] to the given [arg step] (default is 1).

[example [list expr {snapped(3.0461, 0.01)} "# result is 3.0500000000000003"]]
[list_end]
[manpage_end]
