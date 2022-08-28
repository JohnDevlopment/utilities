# Tcl functions
proc getenv {name {default ""}} {
    # Retreive an enviroment variable
    global env
    set code [subst {set result \$env($name)}]
    if {[catch $code result]} {
	set result $default
    }
    return $result
}

proc getRandomFilename {prefix name} {
    set path "$prefix/$name"
    if {! [file exists $path]} {return $path}
    set LIMIT 1000
    for {set i 1} {$i <= $LIMIT} {incr i} {
	set path "$prefix$i/$name"
	if {! [file exists $path]} {return $path}
    }
    error "Failed to get random filename!"
}

proc checkDirectory dir {
    global DRYRUN UNINSTALL

    # DEBUG: check flags
    dprint "checkDirectory: \$DRYRUN = $DRYRUN, \$UNINSTALL = $UNINSTALL"

    # Check if the path exists
    if {[file exists $dir]} {
	# If a file, raise error
	if {! [file isdirectory $dir]} {
	    error "\"$dir\" exists and is not a directory"
	}
	# If directory is nonempty, raise error
	try {
	    set temp [glob $dir/*]
	} on error {} {
	    set temp ""
	}
	if {$temp ne "" && (! $UNINSTALL && ! $DRYRUN)} {
	    error "\"$dir\" is nonempty"
	}
    } elseif {! $UNINSTALL} {
	# Installing the package
	if {! $DRYRUN} {
	    # Create the directory
	    dprint "Write \"$dir\""
	    file mkdir $dir
	}
	puts "Created \"$dir\""
    }

    return
}

proc install {sources dir} {
    global DRYRUN

    # Copy each file to the destination
    foreach src $sources {
	if {! $DRYRUN} {
	    file copy -force $src [file join $dir $src]
	}
	puts "Copied $src to $dir"
    }
}

proc uninstall {dir} {
    global DRYRUN

    try {
	set files [glob "$dir/*"]
    } on error {} {
	set files [list]
    }

    if {! $DRYRUN} {
	file delete -force $dir
    }
    foreach file $files {
	puts "Deleted '$file'"
    }
    puts "Deleted '$dir'"
}

proc getPkgPath {pkgName} {
    global auto_path
    set pkgPath ""
    foreach path [lsearch -glob -inline -all $auto_path {*/tcl*}] {
	set path [file join $path $pkgName]
	set code [catch [list checkDirectory $path] err]
	if {! $code} {
	    set pkgPath $path
	    break
	} else {
	    dprint stderr $err
	}
    }
    return $pkgPath
}

# Create debug function
set code ""
if {[getenv INSTALLSCRIPT_DEBUG 0]} {
    set code {
	set id stdout
	if {[lindex $args 0] eq "stderr"} {
	    set id stderr
	    set args [lreplace $args 0 0]
	}
	puts $id "DEBUG: [join $args]"
    }
}
proc dprint args $code

# Fetch the correct path prefix
catch {
    set installprefix ""
    set len [llength $tcl_pkgPath]

    if {$len == 2} {
	set installprefix [lindex $tcl_pkgPath 1]
    } else {
	set installprefix [lindex $tcl_pkgPath 0]
    }
    set pkgPath 1
}

if {$installprefix eq ""} {
    set installprefix [getPkgPath]
}

# DEBUG: print the install prefix
dprint "Install prefix is \"$installprefix\""

set DRYRUN [getenv INSTALLSCRIPT_DRYRUN 0]
set UNINSTALL [getenv INSTALLSCRIPT_UNINSTALL 0]

# See if the current user can write to this directory
if {! $DRYRUN} {
    try {
	set filename [getRandomFilename $installprefix "utilities-script.txt"]
	dprint "Temp file: $filename"
	set id [open $filename w]
    } on error err {
	puts stderr "unable to write to \"$installprefix\": $err"
    } finally {
	catch {close $id}
	catch {file delete -force $filename}
	unset -nocomplain filename id
    }
}

unset -nocomplain code err len
