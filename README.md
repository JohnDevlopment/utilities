# utilities
A list of common utilities that I use in my projects.

The `utilities` folder contains a Tcl package with procedures to add some common functionality
from other languages.

Here are the functions defined in this package:

**assert**  
`assert exp ?msg?`  
Emits an error if `exp` evalutates to false. You can customize the error message with the
optional parameter `msg`.

**const**  
Creates a const variable. Any attempts to write to it after initialization will result
in an error. It creates a namespace called `::constants`, wherein the initial value of
each constant is stored. When this procedure is called it creates one such variable:
`::constants::[CONST]_original`, where [CONST] is a name for the constant being created.

Any time the user tries to write to a constant with the example name "temp", it is set to the
value in `::constants::temp_original`, thusly restoring the original value, before returning
an error.

**deref**  
If given the name of a variable, it takes its value of and interprets it as the
name of another variable. The function then returns the value of said variable. Here is an example:

    set original 1
    set reference original
    deref reference
    $ result = 1

**do**  
Executes SCRIPT once; then, while COND evaluates to true, continues to execute SCRIPT.
WORD must be "while".

**lambda**  
`lambda args body`  
Returns a lambda expression that can be evaluated as a scripts. Here is an example:

    set aVar 0
    trace add variable aVar write [lambda {name1 name2 op} {return true}]

**lremove**  
`lremove listVar begin ?end?`  
BEGIN is the first index, and the END index, if provided, specifies the last index in the range.
If END omitted, only one element is removed.

**pincr**  
`pincr var`  
`pincr var i`  
Same as `incr` but it returns the old value instead of the new value. So it is basically
postfix increment.

**settemp**  
`settemp var ?value?`  
Creates a temporary variable, setting its value to VALUE.
The variable is put on a queue, and on the next idle frame, it is unset.
