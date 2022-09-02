# Tcl Utilities
An assortment of Tcl libraries, all of which can be easily installed.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Tcl Utilities](#tcl-utilities)
    - [Available Libraries](#available-libraries)
- [Installation](#installation)
- [Usage](#usage)

<!-- markdown-toc end -->

## Available Libraries

1. **jdebug**  
   Packages logging functions. Useful for debugging messages.
2. **timer**  
   Timed asyncronious execution.
3. **utilities**  
   Common utility functions that can help you in scripts.
4. **tk_widgets**  
   Expanded Tk widgets.

# Installation
Close this repository or download a zip archive of this

You can install any of these libraries by running `install.py`.
In a terminal, enter `install.py` or `python3 install.py` to
run the script.

If you've downloaded one of the [releases], then a compiled
installer should be there. It has the same commandline arguments
as the install script.

``` sh
# To install a package
install.py [OPTIONS] PACKAGE

# For a help message
install.py -h
install.py --help
```

*PACKAGE* is the package you want to install; it can be one of `jdebug`, 
`timer`, `utilities`, or `widgets`.

# Usage
After install one of these libraries, you just have to import it in your script.

``` tcl
package require jdebug
package require timer
package require utilities
package require tk_widgets
```

Please refer to the [wiki] for detailed documentation of each library.

[wiki]:      https://github.com/JohnDevlopment/utilities/wiki
[releases]:  https://github.com/JohnDevlopment/utilities/releases
