<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.Admin" %>
<%@ page import="com.codequest.model.Mission" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Mission Editor</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <%
        Admin admin = (Admin) session.getAttribute("adminUser");
        if (admin == null) {
            response.sendRedirect("login.jsp?role=admin");
            return;
        }

        Mission mission = (Mission) request.getAttribute("mission");
        boolean isEdit = (mission != null && mission.getId() > 0);

        String title = isEdit ? mission.getTitle() : "";
        String description = isEdit ? mission.getDescription() : "";
        String category = isEdit ? mission.getCategory() : "Java Basics";
        String difficulty = isEdit ? mission.getDifficulty() : "Easy";
        String choiceA = isEdit ? mission.getChoiceA() : "";
        String choiceB = isEdit ? mission.getChoiceB() : "";
        String choiceC = isEdit ? mission.getChoiceC() : "";
        String choiceD = isEdit ? mission.getChoiceD() : "";
        String correctAnswer = isEdit ? mission.getCorrectAnswer() : "";
        int xpReward = isEdit ? mission.getXpReward() : 50;
    %>

    <div class="navbar">
        <a href="AdminDashboardServlet" class="brand-logo">
            <div class="brand-icon" style="background: linear-gradient(135deg, var(--accent-purple), #ec4899);">&lt;/&gt;</div>
            <div class="brand-text">OVERSEER<span>PORTAL</span></div>
        </a>
        <div class="nav-links">
            <a href="AdminDashboardServlet">&#9881; Console</a>
            <a href="AdminMissionServlet?action=new" class="active">&#10010; Forge Mission</a>
            <a href="LeaderboardServlet" target="_blank">&#127942; View Public Leaderboard</a>
            <span style="color: var(--accent-purple); font-weight: 700; margin-left: 10px;">
                &#128100; <%= admin.getFullName() %>
            </span>
            <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
        </div>
    </div>

    <div class="container" style="max-width: 800px;">
        <div style="margin-bottom: 2rem;">
            <a href="AdminDashboardServlet" style="color: var(--text-muted); text-decoration: none; font-size: 0.9rem; font-weight: 600;">
                &larr; Back to Overseer Console
            </a>
            <h1 style="margin-top: 8px;">
                <%= (isEdit ? "Re-Calibrate Mission #" + mission.getId() : "Forge New Quest Mission") %>
            </h1>
            <p class="subtitle" style="margin-bottom: 0;">
                Configure challenge parameters, description specs, multiple-choice options, and XP reward bounty.
            </p>
        </div>

        <% 
            String error = (String) request.getAttribute("errorMessage");
            if (error != null && !error.trim().isEmpty()) { 
        %>
            <div class="alert alert-danger">
                <span>&#9888;</span> <%= error %>
            </div>
        <% } %>

        <form action="AdminMissionServlet" method="post">
            <% if (isEdit) { %>
                <input type="hidden" name="id" value="<%= mission.getId() %>">
            <% } %>

            <div class="form-group">
                <label for="title">Mission Title</label>
                <input type="text" id="title" name="title" value="<%= title %>" placeholder="e.g. The Polymorphic Enigma" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem;">
                <div class="form-group">
                    <label for="category">Category Domain</label>
                    <select id="category" name="category" required>
                        <option value="Java Basics" <%= "Java Basics".equalsIgnoreCase(category) ? "selected" : "" %>>Java Basics</option>
                        <option value="OOP" <%= "OOP".equalsIgnoreCase(category) ? "selected" : "" %>>OOP</option>
                        <option value="Data Structures" <%= "Data Structures".equalsIgnoreCase(category) ? "selected" : "" %>>Data Structures</option>
                        <option value="Algorithms" <%= "Algorithms".equalsIgnoreCase(category) ? "selected" : "" %>>Algorithms</option>
                        <option value="Concurrency" <%= "Concurrency".equalsIgnoreCase(category) ? "selected" : "" %>>Concurrency</option>
                        <option value="SQL" <%= "SQL".equalsIgnoreCase(category) ? "selected" : "" %>>SQL</option>
                        <option value="Design Patterns" <%= "Design Patterns".equalsIgnoreCase(category) ? "selected" : "" %>>Design Patterns</option>
                        <option value="Web Architecture" <%= "Web Architecture".equalsIgnoreCase(category) ? "selected" : "" %>>Web Architecture</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="difficulty">Threat Level (Difficulty)</label>
                    <select id="difficulty" name="difficulty" required>
                        <option value="Easy" <%= "Easy".equalsIgnoreCase(difficulty) ? "selected" : "" %>>Easy</option>
                        <option value="Medium" <%= "Medium".equalsIgnoreCase(difficulty) ? "selected" : "" %>>Medium</option>
                        <option value="Hard" <%= "Hard".equalsIgnoreCase(difficulty) ? "selected" : "" %>>Hard</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="xp_reward">XP Reward Bounty</label>
                    <input type="number" id="xp_reward" name="xp_reward" value="<%= xpReward %>" min="10" max="1000" step="5" required>
                </div>
            </div>

            <div class="form-group">
                <label for="description">Problem Statement &amp; Code Challenge Specs</label>
                <textarea id="description" name="description" rows="5" placeholder="Explain the problem dilemma, scenario, and question for the student coder..." required><%= description %></textarea>
            </div>

            <h3 style="color: var(--primary-neon); margin-top: 1.8rem; margin-bottom: 0.8rem;">Choice Selections</h3>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <div class="form-group">
                    <label for="choice_a">Option A</label>
                    <input type="text" id="choice_a" name="choice_a" value="<%= choiceA %>" placeholder="Choice A value" required>
                </div>

                <div class="form-group">
                    <label for="choice_b">Option B</label>
                    <input type="text" id="choice_b" name="choice_b" value="<%= choiceB %>" placeholder="Choice B value" required>
                </div>

                <div class="form-group">
                    <label for="choice_c">Option C</label>
                    <input type="text" id="choice_c" name="choice_c" value="<%= choiceC %>" placeholder="Choice C value" required>
                </div>

                <div class="form-group">
                    <label for="choice_d">Option D</label>
                    <input type="text" id="choice_d" name="choice_d" value="<%= choiceD %>" placeholder="Choice D value" required>
                </div>
            </div>

            <div class="form-group" style="margin-top: 0.5rem;">
                <label for="correct_answer" style="color: #6ee7b7;">Correct Answer (Exact string match to one of the choices above)</label>
                <input type="text" id="correct_answer" name="correct_answer" value="<%= correctAnswer %>" 
                       placeholder="Must match exactly choice A, B, C, or D" required 
                       style="border-color: rgba(16, 185, 129, 0.5);">
            </div>

            <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                <button type="submit" class="btn-primary" style="flex: 1; padding: 14px;">
                    &#128190; <%= (isEdit ? "Update Mission Specs" : "Deploy Mission To Grid") %>
                </button>
                <a href="AdminDashboardServlet" class="btn-secondary" style="padding: 14px 24px;">
                    Cancel
                </a>
            </div>
        </form>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; Overseer Security Layer Active
    </footer>
</body>
</html>
