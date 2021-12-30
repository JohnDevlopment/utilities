#!/bin/bash

format=${1:?provide a format}

cd $(dirname $(realpath $0)) || exit 1

fileBase() {
    local value="${1%.tcl}"
    echo "${value#doc_}"
}

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

mkdir -p $format

for file in doc_*.tcl; do
    tcldoc2$format $file $format/$(fileBase $file).$ext
done
