# FIFA World Cup 2026 - Tournament Management System
**CS157A - Team 2 | SJSU**

Rajdeep Sodhi · Anthony Moll · Thi Ngoc Duyen Lam

---

## Architecture (3-Tier)
```
Tier 1 - Client    : Browser (HTML/CSS/JS)
Tier 2 - App Server: Apache Tomcat 11 + Java Servlets + JSP
Tier 3 - Database  : MySQL 9.x (worldcup2026 schema)
```

## Project Structure
```
worldcup2026/
├── sql/
│   ├── schema.sql        ← CREATE TABLE statements (run first)
│   └── seed_data.sql     ← Demo INSERT data (run second)
├── src/main/
│   ├── java/
│   │   ├── HomeServlet.java       ← Servlet: fetches data, forwards to JSP
│   │   └── dao/
│   │       └── DBConnection.java  ← MySQL connection helper
│   └── webapp/
│       ├── index.jsp          ← Homepage (match schedule + standings)
│       ├── matches.jsp        ← Stub (Part 2)
│       ├── standings.jsp      ← Stub (Part 2)
│       ├── teams.jsp          ← Stub (Part 2)
│       ├── predictions.jsp    ← Stub (Part 2)
│       ├── login.jsp          ← Stub (Part 2)
│       ├── register.jsp       ← Stub (Part 2)
│       ├── css/style.css      ← Global stylesheet
│       └── WEB-INF/web.xml    ← Tomcat config
└── README.md
```

---

## Setup Instructions

### Step 1 — Database (MySQL Workbench)
1. Open MySQL Workbench, connect to Local Instance 3306
2. Open a new query tab, paste and run `sql/schema.sql`
3. Open another query tab, paste and run `sql/seed_data.sql`

### Step 2 — Configure DB Password
Open `src/main/java/dao/DBConnection.java` and replace:
```java
private static final String DB_PASSWORD = "your_password_here";
```
with your actual MySQL root password.

### Step 3 — Add MySQL Connector JAR
- Download from: https://dev.mysql.com/downloads/connector/j/
- Place the `.jar` file in: `src/main/webapp/WEB-INF/lib/mysql-connector-j-x.x.x.jar`
- (Create the `lib/` folder if it does not exist)

### Step 4 — Compile Java Files
```bash
# From project root, compile both Java files together
javac -cp "path/to/tomcat/lib/servlet-api.jar:src/main/webapp/WEB-INF/lib/mysql-connector-j-*.jar" \
      -d src/main/webapp/WEB-INF/classes \
      src/main/java/dao/DBConnection.java \
      src/main/java/HomeServlet.java
```
On Windows replace `:` with `;` in the classpath.

### Step 5 — Deploy to Tomcat
Copy everything inside `src/main/webapp/` into your Tomcat `webapps/ROOT/` folder:
```bash
cp -r src/main/webapp/* /path/to/tomcat/webapps/ROOT/
```

### Step 6 — Start Tomcat & Test
```bash
cd /path/to/tomcat/bin
./startup.sh        # Mac/Linux
# startup.bat       # Windows
```
Open browser → http://localhost:8080

---

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Frontend | HTML5, CSS3, JSP |
| Backend | Java 17, Jakarta Servlet API |
| Server | Apache Tomcat 11 |
| Database | MySQL 9.x |
| Version Control | Git / GitHub |
