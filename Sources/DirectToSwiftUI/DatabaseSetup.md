<h2>Direct to SwiftUI Database Setup
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

## Setting up PostgreSQL

### Using Homebrew

```shell
brew install PostgreSQL
brew services start postgresql # start at computer start
createuser -s postgres
```

### Using Postgres.app

Download and install [Postgres.app](https://postgresapp.com),
a nice UI wrapper to manage PostgreSQL databases.

## Loading the `dvdrental` DB

  - [PostgreSQL Tutorial](http://www.postgresqltutorial.com/load-postgresql-sample-database/)

```shell
curl -o /tmp/dvdrental.zip \
  http://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip
mkdir -p /tmp/dvdrental && cd /tmp/dvdrental
tar zxf /tmp/dvdrental.zip
tar xf  /tmp/dvdrental.tar # crazy, right?
createdb dvdrental
pg_restore -h localhost -U postgres -d dvdrental .
```

```shell
$ psql -h localhost -U postgres dvdrental
psql (11.4)
Type "help" for help.

dvdrental=# \dt
             List of relations
 Schema |     Name      | Type  |  Owner   
--------+---------------+-------+----------
 public | actor         | table | postgres
 public | address       | table | postgres
 public | category      | table | postgres
 public | city          | table | postgres
 public | country       | table | postgres
 public | customer      | table | postgres
 public | film          | table | postgres
 public | film_actor    | table | postgres
 public | film_category | table | postgres
 public | inventory     | table | postgres
 public | language      | table | postgres
 public | payment       | table | postgres
 public | rental        | table | postgres
 public | staff         | table | postgres
 public | store         | table | postgres
(15 rows)

```

### Make a Backup Copy

To create a backup copy of your database, run:

```sql
CREATE DATABASE dvdrental_org TEMPLATE dvdrental;
```

## Setting up SQLite dvdrental (Sakila)

```shell
cd /tmp
wget https://raw.githubusercontent.com/jOOQ/jOOQ/master/jOOQ-examples/Sakila/sqlite-sakila-db/sqlite-sakila-schema.sql
wget https://raw.githubusercontent.com/jOOQ/jOOQ/master/jOOQ-examples/Sakila/sqlite-sakila-db/sqlite-sakila-insert-data.sql
sqlite3 dvdrental.sqlite3 < sqlite-sakila-schema.sql
sqlite3 dvdrental.sqlite3 < sqlite-sakila-insert-data.sql
```

```shell
sqlite3 dvdrental.sqlite3
sqlite> .tables
actor                   film                    payment               
address                 film_actor              rental                
category                film_category           sales_by_film_category
city                    film_list               sales_by_store        
country                 film_text               staff                 
customer                inventory               staff_list            
customer_list           language                store                 
```