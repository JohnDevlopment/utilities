[vset version 1.0-alpha]
[vset vtag 1.0a0]
[manpage_begin WidgetMapper n [vset version]]
[require widgetmapper [opt [vset vtag]]]
[copyright "John Russell 2021"]
[moddesc "Tk Widget Mapper"]
[description]
This package provides functions to recursively search for widgets.

[list_begin definitions]
[call ::WidgetMapper::find [opt options] [arg name]]
Recursively search for the given [arg name] in the widget hierchy.
[arg name] is the name of a widget without any '.' separators (e.g., "button").
Returns the full path of [arg name] if found, or an empty string otherwise.

[para]
The following options are supported and are used to modify the behavior of this function:

[list_begin options]
[opt_def [option "-start"] [arg opt]]
Specifies the starting point of the search.
It must be a valid path to a Tk widget.
It defaults to '.'.

[opt_def [option "-depth"] [arg n]]
Specifies the recursion limit of the search; it is relative to the starting position.
So a depth of 3 and a starting point of '.' would mean "3 levels deep from '.'".
If it is less than or equal to zero, this option is ignored.
It defaults to 0.
[list_end]

[call ::WidgetMapper::map_widgets [opt options] [opt [list [arg mapping1] .. [arg mappingN]]]]
Recursively search the widget hierchy and map widgets to variables based on the mappings provided.
Returns an empty string.

[para]
Mappings are defined with the [option -map] option; there can zero or more of them.

[para]
The following options are supported and are used to modify the behavior of this function:

[list_begin options]
[opt_def [option "-map"] "{[arg variable] [arg name]}"]
Defines a mapping for the widget [arg name] to the global [arg variable].
If [arg name] is found, then said variable is set to the full path to that widget.
There can be zero or more of these mappings.
But if no mappings are provided, then nothing happens.

[opt_def [option "-start"] [arg opt]]
Specifies the starting point of the search.
It must be a valid path to a Tk widget.
It defaults to '.'.

[opt_def [option "-depth"] [arg n]]
Specifies the recursion limit of the search; it is relative to the starting position.
So a depth of 3 and a starting point of '.' would mean "3 levels deep from '.'".
If it is less than or equal to zero, this option is ignored.
It defaults to 0.
[list_end]
[list_end]

[section EXAMPLES]

[para]
Examples for using [cmd WidgetMapper::find]:

[example_begin]
package require widgetmapper [vset vtag]

# Default behavior
button .frame1.button -text "Click Me" -command {puts "Hello world!"}
set button [lb]WidgetMapper::find button[rb] ; # Returns ".frame1.button"

# Start seatch from .frame1.subframe1
entry .frame1.subframe1.entry1
entry .frame1.subframe1.entry2
entry .frame1.subframe1.entry3

set entry3 [lb]WidgetMapper::find -start .frame1.subframe1 -depth 3 entry3[rb] ; # returns ".frame1.subframe1.entry3"
[example_end]

[para]
Examples for using [cmd WidgetMapper::map_widgets]:

[example_begin]
package require widgetmapper [vset vtag]

ttk::frame .frame1
ttk::label .frame1.lbName -text Name
ttk::entry .frame1.name

ttk::frame .frame2
ttk::label .frame2.lbAge -text Age
ttk::entry .frame2.age

WidgetMapper::map_widgets -map {Age age} -map {Name name}

puts "Entry for name: $Name\nEntry for age: $Age"
[example_end]

[manpage_end]
