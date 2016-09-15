#!/bin/sh
#
#   sh-funcs.sh - library of sh functions for use in shell scripts
#   Part of <https://github.com/zwets/sh-goodies>.
#   Copyright (C) 2016  Marco van Zwetselaar <io@zwets.it>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Usage
#
#   Put this file on PATH and source it: 
#
#   . sh-funcs.sh
#
#   Or put it in the same directory as the script that uses it, and:
#
#   . "$(dirname "$0")/sh-funcs.sh"
#


# Function: message ARGS
#
# Print ARGS to stderr and return success.

message () {
    echo "$(basename "$0"): $*" >&2 || true
    }


# Function: error ARGS
#
# Print ARGS to stderr and return failure.

error () {
    message $*
    return 1
    }


# Function: verbose ARGS
#
# Print ARGS to stderr when $VERBOSE is set.

verbose () {
    [ -z "$VERBOSE" ] || message $*
    }


# Function: err_exit ARGS
#
# Print ARGS to stderr and exit shell with failure.

err_exit () {
    message $*
    exit 1
    }


# Function: checked_symlink [OPTIONS] TARGET LINK
#
# Create LINK pointing to TARGET.
# If LINK exists, then verify that it canonically points to TARGET.
# 
# OPTIONS
#   -r Create a relative link, that is make TARGET relative to LINK.

checked_symlink() {
   
    local ARG_R=""
    while getopts r o; do case $o in r) ARG_R="r" ;; esac done; shift $((OPTIND - 1))
    local TARGET="$1" LINK="$2"

    if [ -h "$LINK" ]; then
        [ "$(readlink -m "$LINK")" = "$(readlink -m "$TARGET")" ] || error "symlink points to different target: $LINK -> $(readlink "$LINK")"
    else
        ln -s${ARG_R} "$TARGET" "$LINK"
    fi
}

# vim: sts=4:sw=4:ai:si:et
