#!/bin/bash

format=${1:?provide a format}

cd $(dirname $(realpath $0)) || exit 1

case $format in
    man)
        ext=n
        ;;
    html)
        ext=html
        ;;
    md)
        ext=md
        ;;
    *)
        echo "unknown format '$format', only know man, html, and md"
        exit 1
        ;;
esac

for file in doc_*.tcl; do
    file=${file#doc_}
    tcldoc2$format $file ${file%.tcl}.$ext
done
