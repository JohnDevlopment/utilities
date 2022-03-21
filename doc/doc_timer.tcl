[vset version "1.0-beta"]
[vset pkgVer "1.0"]
[manpage_begin timer n [vset version]]
[require timer [opt [vset pkgVer]]]
[include copyright.tcl]
[titledesc "Delay the execution of scripts"]
[moddesc "Timer Class"]
[description]
This package contains the [class Timer] class, which can be used in place of calls to [cmd after] in scripts.
[class Timer] specializes in delayed execution of scripts.

To use this class, first call [cmd "Timer new"] to construct an object.
Then any of the object methods can be invoked.

[list_begin definitions]
[call [cmd Timer] new]
Constructs an instance of [class Timer] and returns it.
After this call, any of the object methods listed below can be used.
When you are done with the object it should be destroyed via [cmd "[emph obj] destroy"].

[call [emph obj] destroy]
Destroys a [class Timer] object previously constructed via [cmd "Timer new"].
After this call the object is no longer valid.

[call [emph obj] start [arg time]]
Sets a timer for [arg time] seconds.
After the timer completes, the script set with [cmd "[emph obj] set_script"] is invoked.

[call [emph obj] stop]
Stops the timer.
No script is invoked if this method is called.

[call [emph obj] set_script [arg script]]
Sets the script to be invoked by the timer when it completes.
For the most part, [arg script] is treated like any Tcl script that gets passed to [cmd eval], with one exception:
If "FREE" is found on a line by itself, it's replaced by [cmd "[emph obj] destroy"], where [emph obj] is subsituted with the object that invoked the script.
The destruction of the object is also wrapped in an [cmd "after idle"] call, so it will be freed on the next idle callback.
[list_end]

[manpage_end]
