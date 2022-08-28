#!/usr/bin/env python3
# Branches to a subdirectory based on the final argument

import os, sys, subprocess

ENVPREFIX = 'INSTALLSCRIPT_'

def parse_arguments():
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('package', metavar='PACKAGE', nargs=1,
                        choices=['exwidgets', 'jdebug', 'timer', 'utilities', 'widgets'],
                        help='the package to install (can be exwidets, jdebug, timer, utilities, or widgets)')
    parser.add_argument('-d', '--debug', dest='debug',
                        action='store_true',
                        help='enables debug messages')
    parser.add_argument('-u', '--uninstall', dest='uninstall', action='store_true',
                        help='uninstall the given PACKAGE')
    parser.add_argument('-n', '--dry-run', dest='dryrun', action='store_true',
                        help='do not (un)install anything; simply print what will happen')
    args = parser.parse_args()

    return args

# Enviroment dictionary
subpenv = {}

for k, v in os.environ.items():
    subpenv[k] = v

args = parse_arguments()

# Boolean flags
 # Debug flag
subpenv[ENVPREFIX + 'DEBUG'] = '1' if args.debug else '0'

 # Uninstall flag
subpenv[ENVPREFIX + 'UNINSTALL'] = '1' if args.uninstall else '0'

 # Dry run flag
subpenv[ENVPREFIX + 'DRYRUN'] = '1' if args.dryrun else '0'

# Name of the script file
from pathlib import Path

rootdir = Path( Path(sys.argv[0]).parent )
command = None
packageName = args.package[0]
if packageName in ('utilities', 'jdebug', 'timer', 'widgets'):
    script = rootdir.joinpath('common', packageName, 'install.tcl').resolve()
    command = script
elif packageName == 'exwidgets':
    script = rootdir.joinpath('common', packageName, 'setup.py').resolve()
    print(f"Please change directory to '{script.parent}' and run setup.py")
    if args.debug:
        print(f"DEBUG: mkdir -p {tempdir} && cd {tempdir}", f"DEBUG: python3 {script} build", sep="\n")
        tempdir = rootdir.joinpath('temp', 'exwidgets').resolve()
    sys.exit()

subprocess.run(command, env=subpenv, cwd=script.parent)
