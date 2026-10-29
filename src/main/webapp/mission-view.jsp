<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Mission" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Challenge Arena</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .arena-wrapper {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-top: 1.5rem;
        }
        @media (max-width: 900px) {
            .arena-wrapper {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Mission mission = (Mission) request.getAttribute("mission");
        if (mission == null) {
            response.sendRedirect("MissionsServlet");
            return;
        }

        String result = request.getParameter("result");
        String xpParam = request.getParameter("xp");
        String leveledUp = request.getParameter("leveledUp");
    %>

    <div class="navbar">
        <a href="DashboardServlet" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <a href="DashboardServlet">&#9881; Dashboard</a>
            <a href="MissionsServlet" class="active">&#128293; Missions</a>
            <a href="LeaderboardServlet">&#127942; Leaderboard</a>
            <a href="ProfileServlet">&#128100; <%= user.getUsername() %></a>
            <div class="nav-user-badge">
                <span class="level-chip">LVL <%= user.getLevel() %></span>
                <span class="xp-chip"><%= user.getXp() %> XP</span>
            </div>
            <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
        </div>
    </div>

    <div class="container">
        <!-- Breadcrumbs & Header -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 10px;">
            <div>
                <a href="MissionsServlet" style="color: var(--text-muted); text-decoration: none; font-size: 0.9rem; font-weight: 600;">
                    &larr; Back to Mission Board
                </a>
                <h1 style="margin-top: 6px; margin-bottom: 0;"><%= mission.getTitle() %></h1>
            </div>
            <div>
                <% 
                    String diff = mission.getDifficulty();
                    String badgeClass = "badge-easy";
                    if ("Medium".equalsIgnoreCase(diff)) badgeClass = "badge-medium";
                    else if ("Hard".equalsIgnoreCase(diff)) badgeClass = "badge-hard";
                %>
                <span class="badge <%= badgeClass %>" style="font-size: 0.85rem; padding: 6px 14px;"><%= diff %></span>
                <span class="badge badge-solved" style="font-size: 0.85rem; padding: 6px 14px; margin-left: 8px;">
                    +<%= mission.getXpReward() %> XP Bounty
                </span>
            </div>
        </div>

        <!-- Feedback Notifications -->
        <% if ("correct".equalsIgnoreCase(result)) { %>
            <div class="alert alert-success">
                <span>&#127881;</span>
                <div>
                    <strong>Access Granted! Mission Completed!</strong><br>
                    You earned <strong style="color: #fff;">+<%= (xpParam != null ? xpParam : mission.getXpReward()) %> XP</strong>.
                    <% if ("true".equalsIgnoreCase(leveledUp)) { %>
                        <span style="color: var(--accent-amber); font-weight: 700; margin-left: 8px;">
                            &#9889; LEVEL UP! You reached Level <%= user.getLevel() %> (<%= user.getTierTitle() %>)!
                        </span>
                    <% } %>
                </div>
            </div>
        <% } else if ("incorrect".equalsIgnoreCase(result)) { %>
            <div class="alert alert-danger">
                <span>&#9888;</span>
                <div>
                    <strong>Verification Failed!</strong> Incorrect choice. Re-evaluate the problem statement and try again.
                </div>
            </div>
        <% } else if ("already_solved".equalsIgnoreCase(result)) { %>
            <div class="alert alert-info">
                <span>&#8505;</span>
                <div>
                    <strong>Mission Record Verified.</strong> You have already solved this challenge previously. Duplicate submissions do not grant additional XP.
                </div>
            </div>
        <% } %>

        <% if (mission.isSolved() && result == null) { %>
            <div class="alert alert-success">
                <span>&#10004;</span>
                <div>
                    <strong>Mission Cleared!</strong> You have solved this challenge and collected its XP.
                </div>
            </div>
        <% } %>

        <!-- Arena Terminal & Interactive Form -->
        <div class="arena-wrapper">
            <!-- Left Pane: Problem Terminal -->
            <div class="terminal-box">
                <div class="terminal-header">
                    <span class="terminal-dot dot-red"></span>
                    <span class="terminal-dot dot-yellow"></span>
                    <span class="terminal-dot dot-green"></span>
                    <span class="terminal-title">mission_runner.sh &bull; Domain: [<%= mission.getCategory() %>]</span>
                </div>
                <div class="terminal-content">
// CODEQUEST MISSION SPECIFICATION:
// TITLE: <%= mission.getTitle() %>
// SECURITY LEVEL: <%= mission.getDifficulty() %>
// XP REWARD: <%= mission.getXpReward() %> XP

<%= mission.getDescription() %>

---------------------------------------------------
System Status: Awaiting player selection input...
Select the accurate cipher below to deploy.
                </div>
            </div>

            <!-- Right Pane: Submission Form -->
            <div style="background: var(--surface-alt); border: 1px solid var(--border); border-radius: 12px; padding: 2rem; display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <h3 style="color: var(--primary-neon); margin-bottom: 0.5rem;">Select Correct Answer</h3>
                    <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">
                        Identify the right implementation or answer from the choices below:
                    </p>

                    <form action="SubmitMissionServlet" method="post" id="missionForm">
                        <input type="hidden" name="mission_id" value="<%= mission.getId() %>">

                        <div class="choices-container">
                            <label class="choice-label">
                                <input type="radio" name="selected_choice" value="<%= mission.getChoiceA() %>" required>
                                <span class="choice-key">A</span>
                                <span class="choice-text"><%= mission.getChoiceA() %></span>
                            </label>

                            <label class="choice-label">
                                <input type="radio" name="selected_choice" value="<%= mission.getChoiceB() %>">
                                <span class="choice-key">B</span>
                                <span class="choice-text"><%= mission.getChoiceB() %></span>
                            </label>

                            <label class="choice-label">
                                <input type="radio" name="selected_choice" value="<%= mission.getChoiceC() %>">
                                <span class="choice-key">C</span>
                                <span class="choice-text"><%= mission.getChoiceC() %></span>
                            </label>

                            <label class="choice-label">
                                <input type="radio" name="selected_choice" value="<%= mission.getChoiceD() %>">
                                <span class="choice-key">D</span>
                                <span class="choice-text"><%= mission.getChoiceD() %></span>
                            </label>
                        </div>

                        <div style="margin-top: 2rem;">
                            <button type="submit" class="btn-primary" style="width: 100%; padding: 14px;">
                                &#9654; Submit Verification Cipher
                            </button>
                        </div>
                    </form>
                </div>

                <div style="margin-top: 1.5rem; text-align: center; border-top: 1px solid var(--border); padding-top: 1.2rem;">
                    <a href="MissionsServlet" style="color: var(--text-muted); text-decoration: none; font-size: 0.9rem;">
                        &larr; Return to Missions List
                    </a>
                </div>
            </div>
        </div>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>
</body>
</html>
