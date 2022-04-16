#!/usr/bin/env bash
# =============================================================================
#  Simple Test Script for sqlite3 command
# =============================================================================
#  This script executes basic commands to test if the sqlite3 command works
#  correctly. Feel free to PR any additional tests you would like to add.

# Check if sqlite3 is installed
which sqlite3 >/dev/null || {
  echo 'sqlite3 command not found.' >&2
  exit 1
}

name_file_db='test.db'
path_dir_tmp=$(dirname "$(mktemp -u)")
path_file_db="${path_dir_tmp}/${name_file_db}"

# Remove the existing test database
rm -f "$path_file_db"

# -----------------------------------------------------------------------------
#  Test Functions
# -----------------------------------------------------------------------------

# AssertContains retuns true if the 1st argument is a substring of the 2nd argument.
AssertContains() {
  local s="$1"
  local contains="$2"

  if [[ "$s" != *"$contains"* ]]; then
    echo "'${s}' does not contain '${contains}'" >&2
    return 1
  else
    return 0
  fi
}

# AssertEqual returns true if two arguments are equal.
AssertEqual() {
  local expect="$1"
  local actual="$2"

  if [[ "$expect" != "$actual" ]]; then
    echo "Expect: ${expect}" >&2
    echo "Actual: ${actual}" >&2
    return 1
  else
    return 0
  fi
}

# RunQuery runs the sqlite3 command with the given arguments.
RunQuery() {
  echo "$1" | sqlite3 "$path_file_db"
}

# TestContains tests if the results contains the given substring.
TestContains() {
  local title="$1"    # The title of the test
  local query="$2"    # The query to run
  local contains="$3" # The substring to look for

  printf "  %s ... " "$title"

  # Run query
  output=$(RunQuery "$query")

  # Assertion
  msgError=$(AssertContains "$output" "$contains" 2>&1) || {
    echo 'NG'
    echo "  Query runned: ${query}"
    echo "  Error Msg: ${msgError}"
    return 1
  }

  echo 'OK'
  return 0
}

# TestEquals tests if the results is equal to the given string.
TestEquals() {
  local title="$1"    # The title of the test
  local query="$2"    # The query to run
  local expect="$3" # The substring to look for

  printf "  %s ... " "$title"

  # Run query
  actual=$(RunQuery "$query")

  # Assertion
  msgError=$(AssertEqual "$expect" "$actual" 2>&1) || {
    echo 'NG'
    echo "  Query runned: ${query}"
    echo "  Error Msg: ${msgError}"
    return 1
  }

  echo 'OK'
  return 0
}

# -----------------------------------------------------------------------------
#  Create Test DB
# -----------------------------------------------------------------------------
printf "%s ... " '- Creating test DB'
sqlite3 "$path_file_db" <<'HEREDOC'
  create table table_sample(timestamp text, description text);
  insert into table_sample values(datetime("now"),"First sample data. Hoo");
  insert into table_sample values(datetime("now"),"Second sample data. Bar");
HEREDOC

result=$?
if ! [ $result -eq 0 ]; then
  exit 1
fi
echo 'created'

# Print created table information
sqlite3 "$path_file_db" <<'HEREDOC'
.header on
.mode column
  select rowid, * from table_sample;
HEREDOC

# -----------------------------------------------------------------------------
#  Tests
# -----------------------------------------------------------------------------
echo '- Testing ...'
isFailed=0

{
  title='1st row value'
  query='SELECT description FROM table_sample WHERE rowid=1;'
  expect='First sample data. Hoo'

  TestEquals "$title" "$query" "$expect" || {
    isFailed=1
  }
}

{
  title='2nd row value'
  query='SELECT * FROM table_sample;'
  contains='Second sample data. Bar'

  TestContains "$title" "$query" "$contains" || {
    isFailed=1
  }
}

# -----------------------------------------------------------------------------
#  Print Test Result
# -----------------------------------------------------------------------------
echo

echo '- Test result:'
if [ "$isFailed" -eq 0 ]; then
  echo 'success'
else
  echo 'failure'
fi

# Clean Up
rm -f "$path_file_db"

exit $isFailed
