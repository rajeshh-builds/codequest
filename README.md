# CodeQuest - Gamified Web-Based Programming Learning Platform

[![Public Live Link](https://img.shields.io/badge/Public%20Live%20Website-Click%20To%20Open-00f2fe?style=for-the-badge&logo=googlechrome&logoColor=white)](https://consumer-artist-naples-steve.trycloudflare.com/codequest/)
[![GitHub](https://img.shields.io/badge/GitHub-samachakradhar%2Fcodequest-181717?style=for-the-badge&logo=github)](https://github.com/samachakradhar/codequest)
[![Java](https://img.shields.io/badge/Java-17%20%7C%2021%20%7C%2025-orange.svg)](https://www.oracle.com/java/)
[![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-10.1%20%7C%2011-yellow.svg)](https://tomcat.apache.org/)
[![Database](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![Aesthetic](https://img.shields.io/badge/UI%2FUX-Cyber%20Neon%20Gaming-00f2fe.svg)]()

---

> 🌐 **Public Live Website URL (Opens on Any Laptop, Phone, or Browser Worldwide):**  
> ## 🚀 **[https://consumer-artist-naples-steve.trycloudflare.com/codequest/](https://consumer-artist-naples-steve.trycloudflare.com/codequest/)**  
>
> *(Click the link above to view and test the website live from anywhere without installing Java, Tomcat, or MySQL!)*
>
> **Local Machine Launchers (For Local Development):**
> - `http://localhost:8080/codequest` (Localhost fallback)
> - Run `start-server.bat` to launch the local Tomcat server.
> - Run `start-public-tunnel.bat` to create a live public tunnel to the internet.

---

**CodeQuest** is a web-based programming learning platform designed with a sleek, dark cyber-gaming aesthetic. Developers solve algorithmic dilemmas, advance through security clearance tiers, earn XP bounties, and climb the real-time global leaderboard.

---

## Master Architecture & Constraints

- **Tech Stack:** HTML5, Vanilla CSS3, JSP, Servlets, JDBC, MySQL 8.0+, JDK 17/21/25, Apache Tomcat 10.1.
- **Jakarta EE 10:** Built using `jakarta.servlet.*` namespace compatible with Tomcat 10.1+.
- **Strict JSP Constraint Complied:** **100% pure standard JSP scriptlets (`<% %>`, `<%= %>`)** and HTML. **Zero JSTL** and **Zero JSP Expression Language (`${}`)** used.
- **Database Architecture:** Singleton `DBConnection` pattern, strictly parameterized `PreparedStatement` across all queries, and relational integrity.
- **Session Security:** Distinct HTTP session contexts (`currentUser` for Students, `adminUser` for Platform Overseers).
- **Gamification Mechanics:**
  - Automated Level Formula: `Level = (XP / 100) + 1`
  - Dynamic XP Progression Bar calculation
  - Duplicate Submission Prevention (`UNIQUE(user_id, mission_id)`)
  - Tier titles: *Novice Hacker*, *Byte Hunter*, *Code Adept*, *Elite Architect*, *Cyber Overlord*

---

## Directory & File Structure

```
Java_chakri/
├── database/
│   └── schema.sql                  # Schema & rich seed data (admin, missions, users, submissions)
├── src/
│   ├── com/codequest/
│   │   ├── model/
│   │   │   ├── User.java           # Student model with XP/level progression logic
│   │   │   ├── Admin.java          # Admin overseer model
│   │   │   ├── Mission.java        # Mission quest model with choices & difficulty
│   │   │   └── Submission.java     # Completed mission ledger
│   │   ├── util/
│   │   │   └── DBConnection.java   # Thread-safe Singleton JDBC connection manager
│   │   └── servlet/
│   │       ├── RegisterServlet.java          # Student registration
│   │       ├── LoginServlet.java             # Dual student/admin authentication
│   │       ├── LogoutServlet.java            # Session termination
│   │       ├── DashboardServlet.java         # Student command center
│   │       ├── MissionsServlet.java          # Quest list with filters (Category, Difficulty)
│   │       ├── MissionDetailServlet.java     # Interactive quest arena terminal
│   │       ├── SubmitMissionServlet.java     # Answer evaluation, XP & Level-up engine
│   │       ├── LeaderboardServlet.java       # Real-time ranked coder standings
│   │       ├── ProfileServlet.java           # Student profile & history ledger
│   │       ├── AdminDashboardServlet.java    # Overseer metrics & mission manager
│   │       ├── AdminMissionServlet.java      # Create/edit mission operations
│   │       └── AdminDeleteMissionServlet.java# Mission deletion operation
├── WebContent/                     # Web root deployed to Tomcat
│   ├── css/
│   │   └── style.css               # Futuristic dark neon gaming design system
│   ├── WEB-INF/
│   │   ├── web.xml                 # Servlet mappings & session configurations
│   │   ├── lib/
│   │   │   ├── jakarta.servlet-api-6.0.0.jar
│   │   │   └── mysql-connector-j-8.3.0.jar
│   │   └── classes/                # Compiled .class files
│   ├── index.html                  # Landing page
│   ├── register.jsp                # Student enlistment
│   ├── login.jsp                   # Role-switching login
│   ├── dashboard.jsp               # Student command center
│   ├── missions.jsp                # Missions catalog
│   ├── mission-view.jsp            # Quest arena & challenge terminal
│   ├── leaderboard.jsp             # Global hall of champions
│   ├── profile.jsp                 # Student achievement ledger
│   ├── admin-dashboard.jsp         # Overseer control console
│   └── admin-mission-form.jsp      # Mission forge form
├── codequest.war                   # Ready-to-deploy WAR package
├── build.bat                       # One-click compile & WAR packager
└── pom.xml                         # Maven build configuration
```

---

## Getting Started

### 1. Database Setup (MySQL)
Run the bundled SQL script to create the schema and seed data:
```bash
mysql -u root -p < database/schema.sql
```
*(Or paste the contents of `database/schema.sql` into MySQL Workbench / phpMyAdmin).*

### 2. Configure Database Credentials
By default, [DBConnection.java](file:///c:/Users/samal/OneDrive/Documents/Java_chakri/src/com/codequest/util/DBConnection.java) connects to `localhost:3306` with user `root` and password `root`.

You can modify the constants in [DBConnection.java](file:///c:/Users/samal/OneDrive/Documents/Java_chakri/src/com/codequest/util/DBConnection.java), or set environment variables:
- `CQ_DB_URL` (optional custom JDBC URL)
- `CQ_DB_USER` (default: `root`)
- `CQ_DB_PASSWORD` (default: `root`)

### 3. Build & Package
Run the included build script:
```cmd
build.bat
```
Or with Maven:
```cmd
mvn clean package
```
This generates `codequest.war`.

### 4. Deploy to Apache Tomcat 10.1
1. Copy `codequest.war` into your Tomcat `webapps/` folder:
   ```cmd
   copy codequest.war "C:\path\to\apache-tomcat-10.1.x\webapps\"
   ```
2. Start Tomcat (`bin\startup.bat`).
3. Open your browser:
   ```
   http://localhost:8080/codequest
   ```

---

## Seed Accounts

### Admin Account (Overseer):
- **Username:** `admin`
- **Password:** `admin123`
- **Access URL:** `http://localhost:8080/codequest/login.jsp?role=admin`

### Pre-loaded Students (for testing & Leaderboard):
- **Username:** `NeoCoder` | **Password:** `pass123` (Level 9, 850 XP)
- **Username:** `CyberKnight` | **Password:** `pass123` (Level 7, 600 XP)
- **Username:** `PixelValkyrie` | **Password:** `pass123` (Level 5, 425 XP)
- **Username:** `ByteHunter` | **Password:** `pass123` (Level 3, 250 XP)
- Or click **"Join Quest"** to register your own custom gamer identity!
