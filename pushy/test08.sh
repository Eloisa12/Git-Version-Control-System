#! /usr/bin/env dash

# ==============================================================================
# test08.sh
# Test pushy-add and pushy-commit command, pushy-commit -a command
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

# Test invalid use of pushy-commit command: no argument/incorrect argument
cd "$expected_dir" || exit 1
2041 pushy-commit > "$expected_output" 2>&1
2041 pushy-commit -m >> "$expected_output" 2>&1
2041 pushy-commit -a -m >> "$expected_output" 2>&1
2041 pushy-commit -m -a "commit" >> "$expected_output" 2>&1
2041 pushy-commit -m "" >> "$expected_output" 2>&1
2041 pushy-commit -a -m "" >> "$expected_output" 2>&1
2041 pushy-commit -b >> "$expected_output" 2>&1
2041 pushy-commit --b >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-commit > "$actual_output" 2>&1
pushy-commit -m >> "$actual_output" 2>&1
pushy-commit -a -m >> "$actual_output" 2>&1
pushy-commit -m -a "commit" >> "$actual_output" 2>&1
pushy-commit -m "" >> "$actual_output" 2>&1
pushy-commit -a -m "" >> "$actual_output" 2>&1
pushy-commit -b >> "$actual_output" 2>&1
pushy-commit --b >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Nothing to commit in the biginning
cd "$expected_dir" || exit 1
2041 pushy-commit -m "first commit" > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-commit -m "first commit" > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test normal commit
cd "$expected_dir" || exit 1
echo "eh" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-commit -m "second commit" >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "eh" > a
pushy-add a > "$actual_output" 2>&1
pushy-commit -m "second commit" >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test remove file can create commit too
cd "$expected_dir" || exit 1
2041 pushy-rm a > "$expected_output" 2>&1
2041 pushy-commit -m "second commit" >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-rm a > "$actual_output" 2>&1
pushy-commit -m "second commit" >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test commit -a update all the file in index and commit
cd "$expected_dir" || exit 1
touch b c
2041 pushy-add b c > "$expected_output" 2>&1
echo "bruh" > b
echo "bingbing" > c
echo "Line 3" >> a
2041 pushy-commit -a -m "third commit" >> "$expected_output" 2>&1
2041 pushy-show 2:a >> "$expected_output" 2>&1
2041 pushy-show 2:b >> "$expected_output" 2>&1
2041 pushy-show 2:c >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
touch b c
pushy-add b c > "$actual_output" 2>&1
echo "bruh" > b
echo "bingbing" > c
echo "Line 3" >> a
pushy-commit -a -m "third commit" >> "$actual_output" 2>&1
pushy-show 2:a >> "$actual_output" 2>&1
pushy-show 2:b >> "$actual_output" 2>&1
pushy-show 2:c >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# If there is nothing to commit -a
cd "$expected_dir" || exit 1
2041 pushy-commit -a -m "nothing to commit" >> "$expected_output" 2>&1
2041 pushy-log >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-commit -a -m "nothing to commit" >> "$actual_output" 2>&1
pushy-log >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0