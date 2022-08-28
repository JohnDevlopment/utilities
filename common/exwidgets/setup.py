#!/usr/bin/env python3
from setuptools import setup, find_packages
from pathlib import Path
from os import fspath

def read_file(filename):
    filename = fspath(filename)
    with open(filename) as fd:
        return fd.read()

def read_version(filename):
    import ast
    text = read_file(filename)
    tree = ast.parse(text)
    for node in tree.body:
        if isinstance(node, ast.Assign):
            targets = [x.id for x in node.targets]
            if '__version__' in targets:
                return node.value.value

ROOTDIR = Path(__file__).parent.resolve()

long_description = Path(ROOTDIR / 'README.md').read_text(encoding="utf-8")

VERSION = read_version(ROOTDIR / 'exwidgets' / '__init__.py')

print(find_packages())

setup(
    name='exwidgets',
    version=VERSION,
    description='Python wrapper of tk_widgets',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/JohnDevlopment/utilities',
    classifiers=[
        'Topic :: Software Development :: User Interfaces',
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',

        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: Implementation',
        'Programming Language :: Python :: Implementation :: CPython',
        
    ],
    project_urls={
        'Tracker': 'https://github.com/JohnDevlopment/utilities/issues',
        
    },
    author='JohnDevlopment',
    author_email='johndevlopment7@gmail.com',
    packages=find_packages(),
    python_requires='>=3.7',
)
