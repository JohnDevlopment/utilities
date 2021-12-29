# Extending the API

This file is for teaching you how to add your own widgets to this package.

## Initialization

Let's assume the name of the widget is **tree**.

Make a file under widgets called `tk_tree.tcl`. Make sure it is sourced in the main file.

```tcl
# tk_widgets.tcl
namespace eval ::exWidgets {}

source [file join $dir tk_entry.tcl]
source [file join $dir tk_text.tcl]
source [file join $dir tk_tree.tcl] ;# here is our file
source [file join $dir tk_pack.tcl]
source [file join $dir tk_state.tcl]
source [file join $dir tk_subcmd.tcl]
```

Create a function called `::exWidgets::tk_tree`. For the parameters, only use `args`. For now the code should look like this:

```tcl
# tk_tree.tcl
proc ::exWidgets::tk_tree args {
	variable identifiers
}
```

## Option Processing

Next we parse the options using the function `::exWidgets::parseOptions`. In the end it will look something like this:

```tcl
set specs {
    scrolly
    scrollx
    {mode.arg all}
}

parseOptions data $specs args
```

The next step is somewhat loaded, so let's break it down. Here is the whole shebang:

```tcl
# Invalid path
set pathname [popFront args]
set id [lindex $args 0]

if {$pathname eq ""} {
	set frame [info frame -1]
	set cmd [getCommandName $frame 1 ?widgetOptions?]
	wrongArgs $cmd
} elseif {[string first . $id] >= 0} {
    set pathname $id
    return -code error -errorcode [list TCL INVALID PARAM $pathname] \
        "invalid path \"$pathname\""
}
```

### Get the Path & Identifier Argument

```tcl
set pathname [popFront args]
set id [lindex $args 0]
```

Widgets always require the first argument to be the path. Here, it is similar except that options specific to our function are processed first, then the path. Using `::exWidgets::popFront` we extract the first element of `args`, then we get the next element via `lindex`.

```tcl
if {$pathname eq ""} {
    set frame [info frame -1]
    set cmd [lindex $frame 1]
    return -code error -errorcode [list TCL WRONGARGS] \
        "wrong # args: should be \"$cmd\" ?options? pathname ?options?"
}
```

If the first argument is empty, then we return a standard "wrong # args" error. You do not have to worry about the stuff going on with `info frame`; that is simply used to get the name of the command.

```tcl
elseif {[string first . $id] >= 0} {
    set pathname $id
    return -code error -errorcode [list TCL INVALID PARAM $pathname] \
        "invalid path \"$pathname\""
}
```

The next argument is an optional identifier. An error is thrown if the argument starts with a '.'.

### Test Whether $id Is An Identifier or An Option

```tcl
# An identifier has no dots (i.e., TEXTBOX instead of .textbox)
# and is not an option (i.e., -textvariable)
set identifiers($pathname) ""
set cmd ""

if {([string first . $id] < 0 && [string first - $id] < 0) && [regexp {[a-zA-Z_]*} $id]} {
    set identifiers($pathname) $id
    set cmd $id
    set args [lreplace $args 0 0]
}
unset id
```

We do two checks on `$id` to test whether it is an identifier:

1. Check that it contains no dots or hyphens. If it contains dots then it is a path name; if it contains a hyphen then it might be an option.
2. It if passes the first check, check to make sure it is a word that contains only lowercase or uppercase characters.

If both tests succeed, then it is registered as an identifier. `$cmd` will be used later on when the identifier becomes relevent.

### Check the Integrity of Pathname using Tk

```tcl
# Invalid path name?
if {[catch {ttk::frame $pathname} err]} {
    unset identifiers($pathname)
    return -code error -errorcode [list TCL INVALID PARAM $pathname] $err
}
```

Try to create the frame which will be used to construct the actual widget. If it fails, an error is thrown after unsetting a variable. We do this because, when a widget is created in Tk, the pathname is checked to make sure all parents exist. Let Tk do all that work for us!

TODO: Talk about how to set up the widget itself.

## Setting Up the Actual Widget

### Packing Information

```tcl
# Packing information for, well, the packer
namespace upvar [namespace current] packinfo($pathname) PackInfo
```

Set up a dictionary in `PackInfo` that will be used for the packer later on. This dictionary will be used to decide what gets packed and what doesn't. Initialize all the keys to their default values. For example, these are the keys used for the text widget:

```tcl
set PackInfo [dict create xscrollbar 0 yscrollbar 0 class text disabledbackground $data(disabledbackground)]
```

One note about this dictionary: the key "class" is the only mandatory key. This key denotes the class of the widget, in this case "tree".

If you have options like `-scrollyx` or `-scrollyy`, then we will add keys `xscrollbar` `yscrollbar` to the dictionary to tell the packer whether to include scrollbars for the X and Y axis, respectively.

### Widget Creation

At this point you're ready to create the actual widgets. Check this block for an example of what we do:

```tcl
# Subwidgets
ttk::treeview $pathname.tree {*}$args
ttk::scrollbar $pathname.xscroll -orient horizontal -command "$pathname.text xview"
ttk::scrollbar $pathname.yscroll -orient vertical -command "$pathname.text yview"
```

Per the standard, the path of the actual widget is `$pathname.CLASS`, where "CLASS" is the class of the widget being created, in this case "tree". Any other widgets that grouped together with the main one should be descendants of `$pathname`.

## Finishing Touches On the Widget

At the very end, call `__set_cmd_and_destroy` to use the identifier to create the command. The function returns if `$cmd` is empty.

```tcl
__set_cmd_and_destroy text $pathname $cmd
```

The finished script can be found [here](tk_tree.tcl).

### Setting Up the Packer

In the file `tk_pack.tcl`, create a function called `::exWidgets::__pack_tree`. It accepts one or more arguments starting with the path name:

```tcl
proc ::exWidgets::__pack_tree {pathname args} {
    namespace upvar [namespace current] packinfo($pathname) PackInfo

    ::pack $pathname {*}$args
    ::pack $pathname.tree -fill both -expand 1 -side top -anchor n

    if {[dict get $PackInfo yscrollbar]} {
        ::place $pathname.yscroll -in $pathname.tree -bordermode outside -relx 1 -y 0 -relheight 1
    }
}
```

### Creating a Subcommand for the Widget

Go to [tk_subcmd.tcl](tk_subcmd.tcl). In the function `::exWidgets::tk_subcmd`, go inside the switch statement and add a case for the widget class you made, in our case "tree".

```tcl
switch -exact $class {
	text {
		return [$pathname.text $cmd {*}$args]
	}
	entry {
		return [$pathname.entry $cmd {*}$args]
	}
	#################
	tree {
		return [$pathname.tree $cmd {*}$args]
	}
	#################
	default {
		return -code error -errorcode [list TK LOOKUP $class] \
			"unknown class \"$class\""
	}
}
```

Between the comments is the switch-case we made for our tree widget. This allows the `exw subcmd` command to work. Now if you want *specialized* subcommands, do the following:

1. Create a function called `__subcmd_<cmd>_<class>`, replacing `<cmd>` with the name of a subcommand, and `<class>` with our widget class. If we wanted a command like `exw subcmd editheading` to work, we'd name the function `__subcmd_editheading_tree`. Also, lets we forget, the function must be in the **::exWidgets** namespace.
2. Fill the function body with the code for your command. The *pathname* argument is mandatory but any others are not.

The basic function template looks like this:

```tcl
proc ::exWidgets::__subcmd_<cmd>_<class> {pathname ?<other_args>?} {
    ...
}
```

Again, replace `<cmd>` with the name of your command and `<class>` with the widget class.

## Conclusion

This concludes the guide for creating your own widget.
