#! /usr/bin/env dash

# ==============================================================================
# test09.sh
# Test pushy-add 
# Combined pushy-remove command to test if pushy-add record deletion
#
# Written by: Eloisa Hong
# Date: 2024-03-25
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

# Create pushy repository
cd "$expected_dir" || exit 1
2041 pushy-init > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-init > "$actual_output" 2>&1

# Test invalid use of pushy-add command: non-existing file
cd "$expected_dir" || exit 1
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-add a b >> "$expected_output" 2>&1
touch a
2041 pushy-add a b >> "$expected_output" 2>&1
2041 pushy-add >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-add a > "$actual_output" 2>&1
pushy-add a b >> "$actual_output" 2>&1
touch a
pushy-add a b >> "$actual_output" 2>&1
pushy-add >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-add command: invalid option
cd "$expected_dir" || exit 1
2041 pushy-add -bruh >> "$expected_output" 2>&1
2041 pushy-add --bruh >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-add -bruh >> "$actual_output" 2>&1
pushy-add --bruh >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-add command: invalid file name
cd "$expected_dir" || exit 1
2041 pushy-add .a > "$expected_output" 2>&1
2041 pushy-add .a b >> "$expected_output" 2>&1
2041 pushy-add a. >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-add .a > "$actual_output" 2>&1
pushy-add .a b >> "$actual_output" 2>&1
pushy-add a. >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test simple remove
cd "$expected_dir" || exit 1
echo "bruh" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-rm a >> "$expected_output" 2>&1
2041 pushy-add a >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "bruh" > a
pushy-add a > "$actual_output" 2>&1
pushy-rm a >> "$actual_output" 2>&1
pushy-add a >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test double remove
cd "$expected_dir" || exit 1
echo "bruh" > b
2041 pushy-add b > "$expected_output" 2>&1
2041 pushy-rm b >> "$expected_output" 2>&1
2041 pushy-rm b >> "$expected_output" 2>&1
2041 pushy-add b >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "bruh" > b
pushy-add b > "$actual_output" 2>&1
pushy-rm b >> "$actual_output" 2>&1
pushy-rm b >> "$actual_output" 2>&1
pushy-add b >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi


echo "${GREEN}Passed test${NC}"
exit 0