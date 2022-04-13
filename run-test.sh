#!/usr/bin/env sh
# -----------------------------------------------------------------------------
#  This script executes basic commands to test if the sqlite3 command works
#  correctly.
# -----------------------------------------------------------------------------

which sqlite3 >/dev/null || {
  echo 'sqlite3 command not found.' >&2
  exit 1
}

name_file_db='test.db'
path_dir_tmp=$(dirname "$(mktemp -u)")
path_file_db="${path_dir_tmp}/${name_file_db}"

# Remove the existing test database
rm -f "$path_file_db"

echo '- Creating test DB:'
sqlite3 "$path_file_db" <<'HEREDOC'
  create table table_sample(timestamp text, description text);
  insert into table_sample values(datetime("now"),"First sample data. Hoo");
  insert into table_sample values(datetime("now"),"Second sample data. Hoo");
HEREDOC

sqlite3 "$path_file_db" <<'HEREDOC'
.header on
.mode column
  select rowid, * from table_sample;
HEREDOC

query='select * from table_sample;'
echo "- Query to run:"
echo "$query"
echo "- Result of query:"
echo "$query" | sqlite3 "$path_file_db" | grep Hoo
result=$?

echo '- Test result:'
if [ "$result" -eq 0 ]; then
  echo 'success'
else
  echo 'failed. Did not return expected output.' >&2
fi

rm -f "$path_file_db"

exit $result
