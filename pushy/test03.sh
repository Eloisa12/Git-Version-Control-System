#! /usr/bin/env dash

# ==============================================================================
# test03.sh
# Test the pushy-status
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

# Create pushy repository
cd "$expected_dir" || exit 1
2041 pushy-init > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-init > "$actual_output" 2>&1

# a: add
# Check add behavior status
cd "$expected_dir" || exit 1
echo "Line 1" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line 1" > a
pushy-add a > "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# a: change
# Check change behavior status
cd "$expected_dir" || exit 1
echo "Line 2" > a
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line 2" > a
pushy-status > "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# a: commit and change again status
# Check remove file can be add and commited
cd "$expected_dir" || exit 1
2041 pushy-commit -m "first commit" >> "$expected_output" 2>&1
echo "Line 2" >> a
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-commit -m "first commit" >> "$actual_output" 2>&1
echo "Line 2" >> a
pushy-status > "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# a: pushy-rm --cached status
cd "$expected_dir" || exit 1
2041 pushy-rm --cached a >> "$expected_output" 2>&1
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-rm --cached a >> "$actual_output" 2>&1
pushy-status > "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# a: add to index again after pushy-rm status
cd "$expected_dir" || exit 1
2041 pushy-add a > "$expected_output" 2>&1
echo "change a" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-commit -m "second commit" >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-add a > "$actual_output" 2>&1
echo "change a" > a
pushy-add a > "$actual_output" 2>&1
pushy-commit -m "second commit" >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# a: several changes status
cd "$expected_dir" || exit 1
echo "change a again" > a
2041 pushy-add a > "$expected_output" 2>&1
echo "change a again and again" > a
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "change a again" > a
pushy-add a > "$actual_output" 2>&1
echo "change a again and again" > a
pushy-status >> "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# a: force remove status
cd "$expected_dir" || exit 1
rm --force a
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
rm --force a
pushy-status > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# untracked file
cd "$expected_dir" || exit 1
touch b c d
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
touch b c d
pushy-status > "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0