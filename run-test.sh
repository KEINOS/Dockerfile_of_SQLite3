#!/usr/bin/env sh

which sqlite3
if [ $? -ne 0 ]; then
  exit 1
fi

cd $(dirname $0);

name_db='test.db'

rm -f $name_db

sqlite3 $name_db <<'EOL'
  create table table_sample(timestamp text, description text);
  insert into table_sample values(datetime("now"),"First sample data. Hoo");
  insert into table_sample values(datetime("now"),"Second sample data. Hoo");
EOL

echo 'select * from table_sample;' | sqlite3 $name_db | grep Hoo && rm $name_db
