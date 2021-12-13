[manpage_begin utilities n "1.0"]
[titledesc "Tcl Utility Functions"]
[include ../../inc/utilities-meta.tcl]
[description]
This package contains a series of handy utility functions that may aid in the development of
Tcl-based applications.
The following functions are exported from the package.

[list_begin definitions]
[call assert [arg expression] [opt [arg message]]]
This works like the typical assertion you might have seen in other languages.
If [arg expression] evaluates to false, then an error is emitted.
You can tell assert to print [arg message] instead of the default "assertion failed" message.

[call bool [arg value]]
Returns 1 if [arg value] evaluates to true or 0 otherwise.
Used for converting between boolean values for mainly logging purposes.

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

[call random integer [opt [arg min]] [arg max]]
Returns a random integer between [arg min] and [arg max].
If [arg min] is omitted, it defaults to zero.

[call random string [arg length]]
Returns a randomly generated string of [arg length] characters.
The string will contain characters between a-z (upper and lowercase) and an underscore.

[call settemp [arg var] [opt [arg value]]]
Creates a temporary value that deletes itself at idle time.
Internally, [arg var] gets added to a queue that is processed at the start of the next event loop,
using [cmd {after idle}].
[list_end]

[para]
These functions belong to the [namespace ::Options] namespace.

[list_begin definitions]
[call getOptions [arg specs] [arg optVar] [arg argvVar]]
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

[manpage_end]
