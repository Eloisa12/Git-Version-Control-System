#! /usr/bin/env dash

# ==============================================================================
# test04.sh
# Test the pushy-status with pushy-rm
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

# pushy-rm status
cd "$expected_dir" || exit 1
echo "Line1" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-rm a >> "$expected_output" 2>&1
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line1" > a
pushy-add a > "$actual_output" 2>&1
pushy-rm a >> "$actual_output" 2>&1
pushy-status > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# pushy-rm status
cd "$expected_dir" || exit 1
echo "Line1" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-rm a >> "$expected_output" 2>&1
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line1" > a
pushy-add a > "$actual_output" 2>&1
pushy-rm a >> "$actual_output" 2>&1
pushy-status > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# pushy-rm --cached status
cd "$expected_dir" || exit 1
echo "Line1" > b
2041 pushy-add b > "$expected_output" 2>&1
2041 pushy-rm --cached b >> "$expected_output" 2>&1
2041 pushy-status > "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line1" > b
2041 pushy-add b > "$actual_output" 2>&1
pushy-rm --cached b >> "$actual_output" 2>&1
pushy-status > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# pushy-rm --force status
cd "$expected_dir" || exit 1
echo "Line1" > c
2041 pushy-add c > "$expected_output" 2>&1
2041 pushy-rm --force c >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line1" > c
pushy-add c > "$actual_output" 2>&1
pushy-rm --force c >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# add -> commit -> deleted status
cd "$expected_dir" || exit 1
echo "Line1" > d
2041 pushy-add d > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
2041 pushy-rm d >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line1" > d
pushy-add d > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
pushy-rm d >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# add -> commit -> change -> deleted status
cd "$expected_dir" || exit 1
echo "Line1" > e
2041 pushy-add e > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "change" > e
2041 pushy-rm e >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "Line1" > e
pushy-add e > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
echo "change" > e
pushy-rm e >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0