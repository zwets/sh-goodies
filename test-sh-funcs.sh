#!/bin/sh
#
#   test-sh-funcs.sh - test script for the functions in sh-funcs.sh
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
#   ./test-sh-funcs.sh
#
#   If it outputs nothing, that's good.
#   To see verbose output, set VERBOSE to a non-empty string.
#

# Source the library

. "$(dirname "$0")/sh-funcs.sh"

# Helper functions 

PROGNAME="$(basename "$0")"  
TESTTEXT="Hello world!"

fail () {
	echo "FAIL: $*" >&2
	return 1
}

must_output () {
	local O="$(cat)"
	[ "$O" = "$1" ] || fail "must_output: ($O) vs ($1) $2"
}

# Test the message() function

message $TESTTEXT 2>/dev/null | must_output "" 'message() must not write to standard output'
message $TESTTEXT 2>&1        | must_output "$PROGNAME: $TESTTEXT" 'message() output incorrect'
message $TESTTEXT 2>/dev/null || fail "message() must return true state"

# Test the error() function

error $TESTTEXT 2>/dev/null   | must_output "" 'error() must not write to standard output'
error $TESTTEXT 2>&1          | must_output "$PROGNAME: $TESTTEXT" 'error() output incorrect'
error $TESTTEXT 2>/dev/null   && fail "error() must return false state"

# Test the verbose() function

OLD_VERBOSE="$VERBOSE"

VERBOSE=""
verbose $TESTTEXT 2>/dev/null | must_output "" 'verbose() must not write to standard output'
verbose $TESTTEXT 2>&1        | must_output "" 'verbose() must not output when VERBOSE is unset'
verbose $TESTTEXT 2>/dev/null || fail "verbose() must return true state"

VERBOSE="42"
verbose $TESTTEXT 2>/dev/null | must_output "" 'verbose() must not write to standard output even when VERBOSE is set'
verbose $TESTTEXT 2>&1        | must_output "$PROGNAME: $TESTTEXT" 'verbose() must write to stderr when VERBOSE is set'
verbose "test" 2>/dev/null    || fail "verbose() must return true state"

VERBOSE="$OLD_VERBOSE"

# Test the checked_symlink function

TMP_DIR=/tmp/$$
mkdir $TMP_DIR
verbose "Test directory: $TMP_DIR"

verbose "Create files"
echo target > $TMP_DIR/target
ln -s $TMP_DIR/target $TMP_DIR/abs_good_link
ln -sr $TMP_DIR/target $TMP_DIR/rel_good_link
ln -s $TMP_DIR/no-such-file $TMP_DIR/abs_bad_link
ln -sr $TMP_DIR/no-such-file $TMP_DIR/rel_bad_link

checked_symlink $TMP_DIR/target $TMP_DIR/abs_good_link && verbose "1.1 good" || message "fail 1.1"
checked_symlink -r $TMP_DIR/target $TMP_DIR/rel_good_link && verbose "1.2 good" || message "fail 1.2"
checked_symlink $TMP_DIR/no-such-file $TMP_DIR/abs_bad_link && verbose "1.3 good" || message "fail 1.3"
checked_symlink -r $TMP_DIR/no-such-file $TMP_DIR/rel_bad_link && verbose "1.4 good" || message "fail 1.4"

checked_symlink $TMP_DIR/target $TMP_DIR/abs_good_link.new && verbose "2.1 good" || message "fail 2.1"
checked_symlink -r $TMP_DIR/target $TMP_DIR/rel_good_link.new && verbose "2.2 good" || message "fail 2.2"
checked_symlink $TMP_DIR/no-such-file $TMP_DIR/abs_bad_link.new && verbose "2.3 good" || message "fail 2.3"
checked_symlink -r $TMP_DIR/no-such-file $TMP_DIR/rel_bad_link.new && verbose "2.4 good" || message "fail 2.4"

echo target.new > $TMP_DIR/target.new
checked_symlink $TMP_DIR/target.new $TMP_DIR/abs_good_link 2>/dev/null && message "fail 3.1" || verbose "3.1 good"
checked_symlink -r $TMP_DIR/target.new $TMP_DIR/rel_good_link 2>/dev/null && message "fail 3.2" || verbose "3.2 good"
checked_symlink $TMP_DIR/no-such-file.new $TMP_DIR/abs_bad_link 2>/dev/null && message "fail 3.3" || verbose "3.3 good"
checked_symlink -r $TMP_DIR/no-such-file.new $TMP_DIR/rel_bad_link 2>/dev/null && message "fail 3.4" || verbose "3.4 good"

[ -d "$TMP_DIR" ] && rm $TMP_DIR/* && rmdir "$TMP_DIR"

