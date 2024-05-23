#! /usr/bin/env dash

# ==============================================================================
# test00.sh
# Test the pushy-init command
# Test all the command before pushy repo created
#
# Written by: Eloisa Hong
# Date: 2024-03-24
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

visualise_output() {
    echo "${NC}Your program produce${RED}"
    cat "$1"
    echo "${NC}The correct output is${GREEN}"
    cat "$2"
}

# add the current directory to the PATH so scripts
# can still be executed from it after we cd

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"

cd "$test_dir" || exit 1
expected_dir="$(mktemp -d)"

# Create some files to hold output.

expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.

trap 'rm "$expected_output" "$actual_output" -rf "$test_dir" "expected_dir"' INT HUP QUIT TERM EXIT

##################################### TEST #####################################

# Test all incorrect usage of command before repo is created
cd "$expected_dir" || exit 1
2041 pushy-add >> "$expected_output" 2>&1
2041 pushy-add a >> "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
2041 pushy-commit -a -m "msg" >> "$expected_output" 2>&1
2041 pushy-show >> "$expected_output" 2>&1
2041 pushy-log >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1
2041 pushy-rm >> "$expected_output" 2>&1
2041 pushy-rm a >> "$expected_output" 2>&1
2041 pushy-rm --cached a >> "$expected_output" 2>&1
2041 pushy-rm --force a >> "$expected_output" 2>&1
2041 pushy-rm --force --cached a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-add >> "$actual_output" 2>&1
pushy-add a >> "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
pushy-commit -a -m "msg" >> "$actual_output" 2>&1
pushy-show >> "$actual_output" 2>&1
pushy-log >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1
pushy-rm >> "$actual_output" 2>&1
pushy-rm a >> "$actual_output" 2>&1
pushy-rm --cached a >> "$actual_output" 2>&1
pushy-rm --force a >> "$actual_output" 2>&1
pushy-rm --force --cached a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test incorrect usage of pushy-init: extra argument
cd "$expected_dir" || exit 1
2041 pushy-init bruh > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-init bruh > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test incorrect usage of pushy-init: incorrect option
cd "$expected_dir" || exit 1
2041 pushy-init -bruh > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-init -bruh > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Add a file called .pushy
cd "$expected_dir" || exit 1
touch .pushy
2041 pushy-init > "$expected_output" 2>&1

cd "$test_dir" || exit 1
touch .pushy
pushy-init > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Correctly create a pushy repository
cd "$expected_dir" || exit 1
rm .pushy
2041 pushy-init > "$expected_output" 2>&1

cd "$test_dir" || exit 1
rm .pushy
pushy-init > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Create pushy repository again
cd "$expected_dir" || exit 1
2041 pushy-init > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-init > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0