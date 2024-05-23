#! /usr/bin/env dash

# ==============================================================================
# test01.sh
# Test pushy-show command
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

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# add a file to the repository staging area
cd "$expected_dir" || exit 1
# Create a simple file.
echo "line 1" > a
echo "line 1" > b
2041 pushy-add a b > "$expected_output" 2>&1

cd "$test_dir" || exit 1
# Create a simple file.
echo "line 1" > a
echo "line 1" > b
pushy-add a b > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# commit the file to the repository history
cd "$expected_dir" || exit 1
2041 pushy-commit -m 'first commit' > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-commit -m 'first commit' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# update the file in the repository staging area

cd "$expected_dir" || exit 1
# Update the file.
echo "line 2" >> a
2041 pushy-add a > "$expected_output" 2>&1
2041 pushy-commit -m 'second commit' >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
# Update the file.
echo "line 2" >> a
pushy-add a > "$actual_output" 2>&1
pushy-commit -m 'second commit' >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Update the file.
cd "$expected_dir" || exit 1
echo "line 3" >> a
# Check that the file that has been commited hasn't been updated
2041 pushy-show 0:a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
echo "line 3" >> a
pushy-show 0:a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Check that the file that is in the staging area hasn't been updated
cd "$expected_dir" || exit 1
2041 pushy-show :a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show :a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Check that invalid use of pushy-show give an error
cd "$expected_dir" || exit 1
2041 pushy-show a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test pushy-show successfully show commit 0
cd "$expected_dir" || exit 1
2041 pushy-show 0:a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show 0:a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test pushy-show successfully show commit 1
cd "$expected_dir" || exit 1
2041 pushy-show 1:a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show 1:a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test pushy-show successfully show different file
cd "$expected_dir" || exit 1
2041 pushy-show 0:b > "$expected_output" 2>&1
2041 pushy-show 1:b > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show 0:b > "$actual_output" 2>&1
pushy-show 1:b > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test if commit number leave blank, then print index content
cd "$expected_dir" || exit 1
2041 pushy-show :a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show :a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test if commit number leave blank, but file got removed from index
cd "$expected_dir" || exit 1
2041 pushy-rm --cached a > "$expected_output" 2>&1
2041 pushy-show :a >> "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-rm --cached a > "$actual_output" 2>&1
pushy-show :a >> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-show: unknown commit
cd "$expected_dir" || exit 1
2041 pushy-show hello:a > "$expected_output" 2>&1
2041 pushy-show 100:a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show hello:a > "$actual_output" 2>&1
pushy-show 100:a > "$actual_output" 2>&1


if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-show: file doesn't exist in index
cd "$expected_dir" || exit 1
2041 pushy-show :c > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show :c > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-show: incorrect arguments
cd "$expected_dir" || exit 1
2041 pushy-show > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-show: incorrect arguments
cd "$expected_dir" || exit 1
2041 pushy-show 0:a 0:a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show 0:a 0:a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-show: invalid filename
cd "$expected_dir" || exit 1
2041 pushy-show 0:/a > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show 0:/a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

# Test invalid use of pushy-show: invalid commit
cd "$expected_dir" || exit 1
2041 pushy-show -bruh > "$expected_output" 2>&1

cd "$test_dir" || exit 1
pushy-show -bruh > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    visualise_output "$actual_output" "$expected_output"
    echo "${RED}Failed test${NC}"
    exit 1
fi

echo "${GREEN}Passed test${NC}"
exit 0