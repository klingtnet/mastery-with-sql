FROM postgres:11
ADD mastery-with-sql/videoezy.sql /docker-entrypoint-initdb.d/00_videoezy.sql
ADD mastery-with-sql/ch11-create.sql /docker-entrypoint-initdb.d/01_ch11_create.sql
ADD mastery-with-sql/ch11-*.csv /mastery-with-sql/