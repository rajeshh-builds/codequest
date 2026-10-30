-- ==============================================================
-- CodeQuest Database Schema & Seed Data
-- Database Engine: MySQL 8.0+
-- Tech Stack: Java 17+, Apache Tomcat 10.1 (Jakarta EE 10)
-- ==============================================================

CREATE DATABASE IF NOT EXISTS codequest_db;
USE codequest_db;

-- 1. Users Table (Students)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    xp INT DEFAULT 0,
    level INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Admins Table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) DEFAULT 'Quest Overseer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Missions Table
CREATE TABLE IF NOT EXISTS missions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    choice_a VARCHAR(255) NOT NULL,
    choice_b VARCHAR(255) NOT NULL,
    choice_c VARCHAR(255) NOT NULL,
    choice_d VARCHAR(255) NOT NULL,
    correct_answer VARCHAR(255) NOT NULL,
    xp_reward INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Mission Submissions Table (User solved tracking)
CREATE TABLE IF NOT EXISTS mission_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mission_id INT NOT NULL,
    is_correct BOOLEAN DEFAULT TRUE,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE,
    UNIQUE(user_id, mission_id) -- Prevents duplicate XP rewards
);

-- Performance Indexes for Sub-millisecond Queries
CREATE INDEX idx_users_xp ON users(xp DESC);
CREATE INDEX idx_missions_cat_diff ON missions(category, difficulty);
CREATE INDEX idx_submissions_user_id ON mission_submissions(user_id, is_correct);

-- ==============================================================
-- Seed Data: Default Admin Credentials
-- Username: admin
-- Password: admin123
-- ==============================================================
INSERT IGNORE INTO admins (id, username, password, full_name) VALUES 
(1, 'admin', 'admin123', 'Master Architect');

-- ==============================================================
-- Seed Data: Sample Missions (Java, OOP, Algorithms, Web, SQL)
-- ==============================================================
INSERT IGNORE INTO missions (id, title, description, category, difficulty, choice_a, choice_b, choice_c, choice_d, correct_answer, xp_reward) VALUES
(1, 'The Void Invocation', 'In Java, what is the default return type of the main entry point method?', 'Java Basics', 'Easy', 'int', 'void', 'boolean', 'String', 'void', 50),

(2, 'PolyMorph Matrix', 'Which OOP principle allows a subclass to provide a specific implementation of a method that is already provided by its superclass?', 'OOP', 'Easy', 'Encapsulation', 'Polymorphism (Method Overriding)', 'Data Abstraction', 'Multiple Inheritance', 'Polymorphism (Method Overriding)', 75),

(3, 'Immutable Core', 'Which of the following classes in the java.lang package is inherently immutable?', 'Java Basics', 'Medium', 'StringBuilder', 'StringBuffer', 'String', 'ArrayList', 'String', 100),

(4, 'The Thread Protocol', 'Which method must be implemented by a class that implements the java.lang.Runnable interface?', 'Concurrency', 'Medium', 'start()', 'run()', 'execute()', 'init()', 'run()', 125),

(5, 'Big-O Nexus', 'What is the average time complexity of searching for an element in a balanced Binary Search Tree (AVL/Red-Black)?', 'Data Structures', 'Medium', 'O(1)', 'O(n)', 'O(log n)', 'O(n log n)', 'O(log n)', 150),

(6, 'SQL Relational Gateway', 'Which SQL clause is used to filter records resulting from an aggregate function like COUNT() or AVG()?', 'SQL', 'Easy', 'WHERE', 'HAVING', 'GROUP BY', 'ORDER BY', 'HAVING', 75),

(7, 'Memory Sanctum', 'In Java memory management, where are local variables and method invocation frames allocated?', 'Java Architecture', 'Hard', 'Heap Space', 'Stack Memory', 'Metaspace', 'PermGen', 'Stack Memory', 200),

(8, 'Singleton Integrity', 'In the classic Double-Checked Locking implementation of the Singleton pattern in Java, which keyword is required on the instance variable to prevent instruction reordering?', 'Design Patterns', 'Hard', 'transient', 'synchronized', 'volatile', 'final', 'volatile', 250);

-- ==============================================================
-- Seed Data: Initial Users for Leaderboard Showcase
-- ==============================================================
INSERT IGNORE INTO users (id, username, email, password, xp, level) VALUES
(1, 'NeoCoder', 'neo@codequest.io', 'pass123', 850, 9),
(2, 'CyberKnight', 'knight@codequest.io', 'pass123', 600, 7),
(3, 'PixelValkyrie', 'valkyrie@codequest.io', 'pass123', 425, 5),
(4, 'ByteHunter', 'hunter@codequest.io', 'pass123', 250, 3),
(5, 'ShadowDev', 'shadow@codequest.io', 'pass123', 100, 2);

-- Seed some completed submissions
INSERT IGNORE INTO mission_submissions (user_id, mission_id, is_correct) VALUES
(1, 1, TRUE), (1, 2, TRUE), (1, 3, TRUE), (1, 4, TRUE), (1, 5, TRUE), (1, 6, TRUE), (1, 7, TRUE),
(2, 1, TRUE), (2, 2, TRUE), (2, 3, TRUE), (2, 4, TRUE), (2, 5, TRUE),
(3, 1, TRUE), (3, 2, TRUE), (3, 3, TRUE), (3, 6, TRUE),
(4, 1, TRUE), (4, 2, TRUE), (4, 6, TRUE),
(5, 1, TRUE), (5, 6, TRUE);
