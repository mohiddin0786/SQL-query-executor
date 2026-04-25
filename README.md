# SQL Query Evaluator

A full-stack web application that allows students to write and execute SQL queries 
against a live Microsoft SQL Server database, with an admin dashboard for user and data management.

## Live Demo
> Deploy locally using Apache Tomcat 9 (see setup below)

---

## Features

### Student View
- Interactive SQL query editor with syntax hints and line numbers
- Schema Explorer panel showing all tables and columns (click to insert)
- Real-time query execution against MS SQL Server
- Query validation — blocks destructive commands (DROP, ALTER, TRUNCATE, CREATE, DELETE)
- Ctrl+Enter shortcut to run queries

### Admin Dashboard
- Overview with live DB stats (user count, enrollment count)
- User management — add and delete student/admin accounts
- Inline SQL console — run queries and see results without leaving the page
- Live table viewer for Students and Enrollments tables
- Role-based access control

### Security
- Session-based authentication (HttpSession)
- AuthFilter protects all routes — unauthenticated users are redirected to login
- Role-based redirection (student → editor, admin → dashboard)
- DB credentials hidden using Tomcat JNDI DataSource (never in source code)
- Secure logout with session invalidation and cookie clearing

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java Servlets (Jakarta EE) |
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Database | Microsoft SQL Server |
| DB Connection | JNDI DataSource + Connection Pooling |
| Server | Apache Tomcat 9 |
| IDE | Eclipse IDE |

---

## Project Structure

```
src/main/java/com/sqlsystem/
├── controller/
│   ├── QueryController.java     # Handles query execution
│   ├── LoginServlet.java        # Handles authentication
│   ├── LogoutServlet.java       # Session invalidation
│   └── AdminQueryServlet.java   # Admin AJAX query endpoint
├── database/
│   └── DatabaseConnection.java  # JNDI DataSource lookup
├── executor/
│   └── QueryExecutor.java       # JDBC query runner
├── validator/
│   └── QueryValidator.java      # Blocks restricted SQL commands
├── filter/
│   └── AuthFilter.java          # Route protection filter
└── evaluation/
└── QueryEvaluator.java      # Result comparison utility
src/main/webapp/
├── META-INF/
│   ├── context.xml.example      # DB config template (copy and fill in)
│   └── context.xml              # Your actual config (gitignored)
├── WEB-INF/
│   └── web.xml                  # Servlet and filter mappings
├── login.html                   # Login page
├── home.jsp                     # Student query editor
├── admin.jsp                    # Admin dashboard
└── result.jsp                   # Query result display
```

---

## Database Schema

```sql
-- Users table (authentication)
CREATE TABLE Users (
    UserID    INT PRIMARY KEY IDENTITY(1,1),
    Username  NVARCHAR(50) NOT NULL UNIQUE,
    Password  NVARCHAR(100) NOT NULL,
    Role      NVARCHAR(10) NOT NULL CHECK (Role IN ('student', 'admin'))
);

-- Practice tables
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    Name      NVARCHAR(50),
    Age       INT,
    City      NVARCHAR(50)
);

CREATE TABLE Courses (
    CourseID   INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(50),
    Credits    INT
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID    INT FOREIGN KEY REFERENCES Students(StudentID),
    CourseID     INT FOREIGN KEY REFERENCES Courses(CourseID),
    Grade        CHAR(2)
);
```

---

## Setup & Installation

### Prerequisites
- Java 17+
- Apache Tomcat 9
- Microsoft SQL Server
- Eclipse IDE (or any Java EE IDE)
- [mssql-jdbc driver](https://learn.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/sql-query-evaluator.git
```

**2. Set up the database**

Run the SQL scripts above in SQL Server Management Studio to create the database and tables.

Insert default users:
```sql
INSERT INTO Users VALUES ('admin', 'admin123', 'admin');
INSERT INTO Users VALUES ('student1', 'pass123', 'student');
```

**3. Configure database connection**
```bash
cp src/main/webapp/META-INF/context.xml.example src/main/webapp/META-INF/context.xml
```
Edit `context.xml` and fill in your SQL Server credentials.

**4. Add JDBC driver to Tomcat**

Copy `mssql-jdbc-xx.jar` to `<TOMCAT_HOME>/lib/`

**5. Deploy**

Import the project into Eclipse → Add to Tomcat server → Start

Visit: `http://localhost:8080/sql-query-evaluator/`

---

## Default Credentials

| Role | Username | Password |
|---|---|---|
| Admin | admin | admin123 |
| Student | student1 | pass123 |

> ⚠️ Change these after first login in a production environment.

---

## Author

**Roshan**  
[GitHub](https://github.com/mohiddin0786) · [LinkedIn](https://linkedin.com/in/md-m-mohiddin)