#! /usr/bin/env dash

# ==============================================================================
# test05.sh
# Test error messages for pushy-rm
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

# Test invalid use of remove: no file name
cd "$expected_dir" || exit 1
2041 pushy-rm > "$expected_output" 2>&1
2041 pushy-rm --cached >> "$expected_output" 2>&1
2041 pushy-rm --force >> "$expected_output" 2>&1
2041 pushy-rm --force --cached >> "$expected_output" 2>&1
2041 pushy-rm --cached --force >> "$expected_output" 2>&1
2041 pushy-rm --bruh > "$expected_output" 2>&1
2041 pushy-rm -bruh >> "$expected_output" 2>&1
    
cd "$test_dir" || exit 1
pushy-rm > "$actual_output" 2>&1
pushy-rm --cached >> "$actual_output" 2>&1
pushy-rm --force >> "$actual_output" 2>&1
pushy-rm --force --cached >> "$actual_output" 2>&1
pushy-rm --cached --force >> "$actual_output" 2>&1
pushy-rm --bruh > "$actual_output" 2>&1
pushy-rm -bruh >> "$actual_output" 2>&1


if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of remove: bad filename
cd "$expected_dir" || exit 1
2041 pushy-rm .bruh > "$expected_output" 2>&1
2041 pushy-rm /bruh >> "$expected_output" 2>&1
2041 pushy-rm br^uh >> "$expected_output" 2>&1
2041 pushy-rm br#uh >> "$expected_output" 2>&1
2041 pushy-rm a >> "$expected_output" 2>&1
2041 pushy-rm --cached a >> "$expected_output" 2>&1
2041 pushy-rm --force a >> "$expected_output" 2>&1
2041 pushy-rm --force --cached a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-rm .bruh > "$actual_output" 2>&1
pushy-rm /bruh >> "$actual_output" 2>&1
pushy-rm br^uh >> "$actual_output" 2>&1
pushy-rm br#uh >> "$actual_output" 2>&1
pushy-rm a >> "$actual_output" 2>&1
pushy-rm --cached a >> "$actual_output" 2>&1
pushy-rm --force a >> "$actual_output" 2>&1
pushy-rm --force --cached a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of remove: file not in the pushy repo
cd "$expected_dir" || exit 1
2041 pushy-rm a > "$expected_output" 2>&1
2041 pushy-rm --cached a >> "$expected_output" 2>&1
2041 pushy-rm --force a >> "$expected_output" 2>&1
2041 pushy-rm --force --cached a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-rm a > "$actual_output" 2>&1
pushy-rm --cached a >> "$actual_output" 2>&1
pushy-rm --force a >> "$actual_output" 2>&1
pushy-rm --force --cached a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test pushy-remove unsuccessfully: changes has staged
cd "$expected_dir" || exit 1
echo "hi" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-rm a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > a
pushy-add a > "$actual_output" 2>&1
pushy-rm a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test pushy-remove unsuccessfully: file changed again after commit
cd "$expected_dir" || exit 1
2041 pushy-commit -m "msg" > "$expected_output" 2>&1
echo "hi again" > a
2041 pushy-rm a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-commit -m "msg" > "$actual_output" 2>&1
echo "hi agian" > a
pushy-rm a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test pushy-remove unsuccessfully: file changed again after add
cd "$expected_dir" || exit 1
2041 pushy-add a > "$expected_output" 2>&1
echo "hi again and again" > a
2041 pushy-rm a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-add a > "$actual_output" 2>&1
echo "hi again and again" > a
pushy-rm a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0