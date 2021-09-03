# Mastery with SQL

This is my local development environment for the course [Mastery with SQL](https://www.masterywithsql.com/).

## Setup

If you haven't cloned the repository using `--recursive` please run `git submodule update --init ` to setup the `mastery-with-sql` submodule.
Now, let's build the postgres container that contains the required database dumps: `docker build -t postgres:mastery-with-sql .` .
That's it, just run `docker-compose up`, wait until the dump import finished and then you can open [pgweb](http://localhost:8081) to interact with the database.

