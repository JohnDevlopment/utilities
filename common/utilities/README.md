
[//000000001]: # (utilities \- Tcl Utility Functions)
[//000000002]: # (Generated from file '' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; John Russell 2021)
[//000000004]: # (utilities\(n\) 1\.1  "Tcl Utility Functions")

# NAME

utilities \- Tcl Utility Functions

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Public API](#section2)

      - [Randon Number Generation](#subsection1)

      - [Option Processing](#subsection2)

      - [Expanded Math Functions](#subsection3)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require utilities ?1\.1\`?  

[assert *expression* ?*message*?](#1)  
[bitset *intVar* *bit* *flag*](#2)  
[const *name* *value*](#3)  
[deref *var*](#4)  
[do *body* while *cond*](#5)  
[lambda *args* *body*](#6)  
[lremove *listVar* *begin* ?*end*?](#7)  
[pincr *var* ?*i*?](#8)  
[popFront *listVar*](#9)  
[settemp *var* ?*value*?](#10)  
[random integer ?*min*? *max*](#11)  
[random float ?*min*? *max*](#12)  
[random string *length*](#13)  
[getoptions *specs* *optVar* *argvVar*](#14)  
[clamp *value* *min* *max*](#15)  
[snapped *number* ?*step*?](#16)  

# <a name='description'></a>DESCRIPTION

This package contains a series of handy utility functions that may aid in the
development of Tcl\-based applications\.

# <a name='section2'></a>Public API

  - <a name='1'></a>assert *expression* ?*message*?

    If *expression* evaluates to false the current program exits with a
    non\-zero status, indicating an error\. *message* is printed to standard
    error as this happens; if it is omitted, it defaults to the standard
    "assertion failed" message\.

    To use this function, you need to set to 0\. This is done automatically if
    the DEBUG enviroment variable is set to a non\-zero value\.

  - <a name='2'></a>bitset *intVar* *bit* *flag*

    Set or clear the given *bit* in *intVar*; set if *flag* is true, clear
    otherwise\.

  - <a name='3'></a>const *name* *value*

    Creates a new variable by the name *name* and sets its value to *value*\.
    At the time this function is called, *name* cannot already exist\. Returns
    *value*\.

    This function creates a readonly variable: once its value is set upon
    creation, it cannot be changed again\. Any attempt to do so will result in an
    error\.

  - <a name='4'></a>deref *var*

    Returns the value of the variable *var*\.

  - <a name='5'></a>do *body* while *cond*

    Implements a do\-while loop\. Evaluates the script *body* once and then
    continues to do so while *cond* evaluates to true\.

  - <a name='6'></a>lambda *args* *body*

    Returns an apply lambda function with the arguments *args* and *body* as
    the function body\.

  - <a name='7'></a>lremove *listVar* *begin* ?*end*?

    Removes one or more elements from a list found in the variable *listVar*\.
    *begin* and *end* are index values that specify the start and end of a
    range of elements to remove\. Indices are interpreted in the same manner as
    __lreplace__\.

    Returns an empty string\.

  - <a name='8'></a>pincr *var* ?*i*?

    Implements a post\-fix increment operator in Tcl\. Increments the numeric
    value in *var* by the amount specified by *i*\. If *i* is not provided,
    then 1 is used as the default\.

    The return value is the value of *var* prior to the increment\.

  - <a name='9'></a>popFront *listVar*

    Removes the first element of the list contained in *listVar* and returns
    it\. If the list is empty, so is the return value\.

  - <a name='10'></a>settemp *var* ?*value*?

    Creates a temporary value that deletes itself at idle time\. Internally,
    *var* gets added to a queue that is processed at the start of the next
    event loop, using __after idle__\.

## <a name='subsection1'></a>Randon Number Generation

  - <a name='11'></a>random integer ?*min*? *max*

    Returns a random integer between *min* and *max*\. If *min* is omitted,
    it defaults to zero\.

  - <a name='12'></a>random float ?*min*? *max*

    Returns a random floating point number between *min* and *max*\. If
    *min* is omitted, it defaults to zero\.

  - <a name='13'></a>random string *length*

    Returns a randomly generated string of *length* characters\. The string
    will contain characters between a\-z \(upper and lowercase\) and an underscore\.

## <a name='subsection2'></a>Option Processing

These functions belong to the __::Options__ namespace\.

  - <a name='14'></a>getoptions *specs* *optVar* *argvVar*

    Processes commandline options according to the rules defined in *specs*\.

    *specs* is a list of lists containing recognized options, where each
    element takes the form of \{option default\}\. If the option doesn't contain
    any special suffixes, the option is treated as a boolean flag: it is set to
    true if provided, and false otherwise\. If *option* ends in "\.arg", the
    option expects an argument\. *default* is used as the argument in the case
    that such option is not provided\.

    The options in *argvVar* are put into the array variable *optVar*, where
    each index is an option and its value is the corresponding argument\.

## <a name='subsection3'></a>Expanded Math Functions

These functions are defined in the __::tcl::mathfunc__ namespace, so they
can be used inside of __expr__\.

  - <a name='15'></a>clamp *value* *min* *max*

    Returns *value* clamped between the *min* and *max* values\.

  - <a name='16'></a>snapped *number* ?*step*?

    Snaps *number* to the given *step* \(default is 1\)\.

        expr {snapped(3.0461, 0.01)} {# result is 3.0500000000000003}

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; John Russell 2021

