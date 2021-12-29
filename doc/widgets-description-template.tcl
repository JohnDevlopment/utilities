The [cmd "exw [vset class]"] command creates a window (provided by the [arg pathName] argument) and makes
it into an extended [widget [vset widget]] widget.
At the time this command is invoked, [arg pathName] must not already exist, yet its parent must exist.
If the optional [arg identifier] argument is specified, a command named after it will be created.
At the time of this widget's creation, there must not already be a command named [arg identifier].
In addition, [arg identifier] cannot have any hyphens or periods.
See the section [sectref "Widget Command"] for more info about this.
