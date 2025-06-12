#!/bin/sh

require() {
    if [ -z "$1" ]; then
        echo "[REQUIRE VARIABLE VALUE]: $2"
        echo "Process is stopped because of that"
        exit 1
    fi
}

ROOT=$(pwd)

goto_root() {
    cd "$ROOT"
}

goto_root_and_defaults() {
    goto_root
    source "./env"
}

directory_needed() {
    if ! [ -d "$1" ]; then
        PATH=$(pwd)
        echo "directory $1 must be available in $PATH"
        exit
    fi
}

file_needed() {
    if ! [ -f "$1" ]; then
        PATH=$(pwd)
        echo "file must be available in $PATH $1"
        exit
    fi
}
