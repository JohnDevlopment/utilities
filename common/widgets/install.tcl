#!/usr/bin/env tclsh
# Install package in machine-independent directory

source ../install_helpers/proc.tcl

# Set the directory path
set installdir [file join $installprefix widgets]
checkDirectory $installdir

# Get a list of files to copy
set srcfiles [glob *.tcl]
set idx [lsearch $srcfiles install.tcl]
set srcfiles [lreplace $srcfiles $idx $idx]

if {[getenv INSTALLSCRIPT_UNINSTALL 0]} {
    uninstall $installdir
} else {
    install $srcfiles $installdir
}
