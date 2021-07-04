[manpage_begin jdebug n "2.0.1"]
[titledesc "Debug logging functions"]
[copyright "John Russell 2021"]
[require jdebug 2.0.1]

[description]
This man page contains all the public exported functions from the [namespace jdebug] namespace.
These functions are used to print diagnostic debugging messages to the programmer.
Messages can be filtered using loglevels. (See [sectref LOGLEVELS])

[section api]

[list_begin definitions]
[call ::jdebug::on]
Enables the debugging mechanism and resets all of its parameters.

[call ::jdebug::off]
Disables the debugging mechanism.

[call ::jdebug::level level]
Call this function to set the loglevel.
[arg level] may be one of the loglevels specified in the section [sectref LOGLEVELS].
[arg level] is not case-sensitive.

[call ::jdebug::print [arg tag] [arg msg]]
Prints the argument [arg msg] to the loglevel specified by [arg tag].
If [arg tag] is one of the levels above the current loglevel, this function has no effect.
For more information, see [sectref LOGLEVELS].
[list_end]

[section loglevels]
[namespace jdebug] uses standard debugging levels, listed below.
The levels are sorted in descending order of priority.
When a level is selected, the ones above it on this list are ignored.
For example, if the loglevel is debug, trace messages will be not printed.

[list_begin definitions]
[lst_item ALL]
All debug messages are printed; this is the default.

[lst_item TRACE]
This loglevel is used to print very verbose messages for individual steps in a function.
Programmers use this when they want to print each individual step in a complex algorithm, for example.
Using this loglevel tends to result in large amounts of text, so use with caution.

[lst_item DEBUG]
This loglevel is less detailed than trace overall but can still provide useful information
about the state of the application.

[lst_item INFO]
Use this for general-purpose diagnostic messages about the state of the application.
For example, you may use this to print that a file was saved or loaded.
Less detailed than debug and used to signal to the programmer than an action was taken.

[lst_item WARN]
This is used to supply information about problems that don't necessarily amount to errors.
They could be minor syntax errors or missing fonts, or something of similar weight.
The problems that get reported on here don't generally lead to huge problems.

[lst_item ERROR]
Prints messages about errors that are very much in need of attention.
Unlike warnings, errors can affect performance or potentially cause the application to not work correctly.
In some cases these errors can even cause the function to return or the application to quit.

[lst_item FATAL]
Messages printed on this loglevel represent problems in the application that need [emph immediate]
attention, lest the application crash or there be negative side effects.
Reserve this loglevel for the truly dire situations.
[list_end]

[manpage_end]
