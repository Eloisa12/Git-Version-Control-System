#! /usr/bin/env dash

# ==============================================================================
# test06.sh
# Test pushy-rm options forced with pushy-status
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

# Add to index, then rm --force --cached
cd "$expected_dir" || exit 1
echo "hi" > a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-rm --force --cached a >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > a
pushy-add a > "$actual_output" 2>&1
pushy-rm --force --cached a >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Add to index, then changed, then rm --force --cached: unsuccess
cd "$expected_dir" || exit 1
echo "hi" > b
2041 pushy-add b > "$expected_output" 2>&1
echo "hi again" > b
2041 pushy-rm --force --cached b >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > b
pushy-add b > "$actual_output" 2>&1
echo "hi again" > b
pushy-rm --force --cached b >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Add to index, commit, then rm --force --cached
cd "$expected_dir" || exit 1
echo "hi" > c
2041 pushy-add c > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
2041 pushy-rm --force --cached c >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > c
pushy-add c > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
pushy-rm --force --cached c >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Add to index, commit, change then rm --force --cached
cd "$expected_dir" || exit 1
echo "hi" > d
2041 pushy-add d > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "hi again" > d
2041 pushy-rm --force --cached d >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > d
pushy-add d > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
echo "hi again" > d
pushy-rm --force --cached d >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Make index different to working file and repo again --force --cached
cd "$expected_dir" || exit 1
echo "hi" > f
2041 pushy-add f > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "hi again" > f
2041 pushy-add f >> "$expected_output" 2>&1
echo "hi again and again" > f
2041 pushy-rm --force --cached f >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > f
pushy-add f > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
echo "hi again" > f
pushy-add f >> "$actual_output" 2>&1
echo "hi again and again" > f
pushy-rm --force --cached f >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test --force --cached when the file doesn't exist in working directory
cd "$expected_dir" || exit 1
echo "hi" > e
2041 pushy-add e > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "hi again" > e
rm e >> "$expected_output" 2>&1
2041 pushy-rm --force --cached e >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > e
pushy-add e > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
rm e >> "$actual_output" 2>&1
pushy-rm --force --cached e >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test --force --cached when the file doesn't exist in index
cd "$expected_dir" || exit 1
echo "hi" > e
2041 pushy-add e > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "hi again" > e
2041 pushy-rm --force --cached e >> "$expected_output" 2>&1
2041 pushy-rm --force --cached e >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > e
pushy-add e > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
pushy-rm --force --cached e >> "$actual_output" 2>&1
pushy-rm --force --cached e >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test --force when the file doesn't exist
cd "$expected_dir" || exit 1
echo "hi" > g
2041 pushy-add g > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "hi again" > g
rm g >> "$expected_output" 2>&1
2041 pushy-rm --force g >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > g
pushy-add g > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
rm g >> "$actual_output" 2>&1
pushy-rm --force g >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test --force will remove file anyway
cd "$expected_dir" || exit 1
echo "hi" > h
2041 pushy-add h > "$expected_output" 2>&1
2041 pushy-commit -m "msg" >> "$expected_output" 2>&1
echo "hi again" > h
2041 pushy-rm h >> "$expected_output" 2>&1
2041 pushy-rm --force h >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > h
pushy-add h > "$actual_output" 2>&1
pushy-commit -m "msg" >> "$actual_output" 2>&1
echo "hi again" > h
pushy-rm h >> "$actual_output" 2>&1
pushy-rm --force h >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

    visualise_output "$actual_output" "$expected_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test --force will remove file anyway
cd "$expected_dir" || exit 1
echo "hi" > i
2041 pushy-add i > "$expected_output" 2>&1
2041 pushy-rm --force i >> "$expected_output" 2>&1
2041 pushy-status >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "hi" > i
pushy-add i > "$actual_output" 2>&1
pushy-rm --force i >> "$actual_output" 2>&1
pushy-status >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0