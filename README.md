# CS157A - Team 2: FIFA World Cup 2026 Web App

This is a Java web application (JSP + Servlets) backed by a MySQL database, built for the CS157A course project. It implements team, player, match, venue, and referee management, along with user registration, login, comments, and predictions.

## Requirements

Before setting this up, you will need the following installed:

- JDK 17 or later
- Apache Tomcat 10 or later (this project uses Jakarta EE `jakarta.servlet.*` imports, so Tomcat 9 or older will not work)
- MySQL 8.0 or later
- MySQL Connector/J (the JDBC driver jar). Place this in Tomcat's `lib/` folder so it is available to every deployed app.

## 1. Set up the database

Create the database and load the schema and seed data:

```
mysql -u root -p -e "CREATE DATABASE worldcup2026;"
mysql -u root -p worldcup2026 < sql/schema.sql
mysql -u root -p worldcup2026 < sql/seed_data.sql
```

`schema.sql` includes a short migration section near the bottom of the file (a few `ALTER TABLE` statements). These are safe to run even if you already have the tables created, since the `CREATE TABLE` statements above them use `IF NOT EXISTS`.

## 2. Configure the database connection

Open `src/main/java/dao/DBConnection.java` and update the password field to match your local MySQL root password:

```java
private static final String DB_PASSWORD = "your_mysql_password_here";
```

The database URL and username can be left as-is unless your MySQL setup differs from the default (`localhost:3306`, user `root`).

## 3. Compile and deploy

This project does not use Maven or another build tool. Compile the source directly into Tomcat's deployment folder.

From the project root, run:

```
javac -cp "/path/to/Tomcat/lib/*" \
  -d /path/to/Tomcat/webapps/ROOT/WEB-INF/classes \
  src/main/java/*.java \
  src/main/java/dao/*.java \
  src/main/java/model/*.java \
  src/main/java/util/*.java
```

Then copy the web files (JSPs, CSS, `WEB-INF/web.xml`) into the same Tomcat deployment:

```
cp -r src/main/webapp/* /path/to/Tomcat/webapps/ROOT/
```

## 4. Start Tomcat

```
/path/to/Tomcat/bin/startup.sh
```

Once it is running, visit:

```
http://localhost:8080/
```

To stop Tomcat:

```
/path/to/Tomcat/bin/shutdown.sh
```

If you make further changes and redeploy, it is a good idea to clear Tomcat's compiled JSP cache first, since it does not always pick up changes to already-compiled pages:

```
rm -rf /path/to/Tomcat/work/Catalina/localhost/ROOT
```

## Demo accounts

The seed data includes the following accounts for testing:

| Email | Password | Role |
|---|---|---|
| rajdeep.sodhi@sjsu.edu | password | admin |
| anthony.moll@sjsu.edu | password | admin |
| thingocduyen.lam@sjsu.edu | password | admin |
| mike.wu@sjsu.edu | password | fan |

Admin accounts can add, edit, and delete teams, players, matches, venues, and referees. Fan accounts and guests (not logged in) can view all of this information, and logged-in fans can post comments and predictions.

## Project structure

```
src/main/java/         Servlets (one per feature: Login, Register, Team, Match, Venue, Referee, Comment, Prediction, Home) SQL code imbedded
src/main/java/dao/     Database access classes, one per entity (SQL LOGIC EXISTS HERE)
src/main/java/model/   Simple data classes (User, Referee, MatchAssignment)
src/main/java/util/    Shared helpers (admin access checks)
src/main/webapp/       JSP pages and static assets (CSS)
sql/schema.sql         Table definitions and migrations
sql/seed_data.sql      Sample data for testing
```

## Notes

- SQL logic and structure exists in DAO files, schema, ServerletFiles (DeleteComment) and seed for data
- A team is identified by its country name rather than a numeric ID, matching the ERD.
- Deleting a team also deletes its players, along with their recorded stats and match events.
- A stadium cannot be double-booked for the same date and time; this is enforced both in the application code and with a database constraint.
- A referee cannot be assigned to a match involving a team from their own country.
