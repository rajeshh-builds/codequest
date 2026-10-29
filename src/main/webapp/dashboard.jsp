<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Command Center</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <%
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("login.jsp?msg=Please log in to access the dashboard.");
            return;
        }

        Integer totalMissionsObj = (Integer) request.getAttribute("totalMissions");
        int totalMissions = (totalMissionsObj != null) ? totalMissionsObj : 0;

        Integer solvedMissionsObj = (Integer) request.getAttribute("solvedMissions");
        int solvedMissions = (solvedMissionsObj != null) ? solvedMissionsObj : user.getSolvedMissions();

        @SuppressWarnings("unchecked")
        List<Mission> recommended = (List<Mission>) request.getAttribute("recommendedMissions");
    %>

    <div class="navbar">
        <a href="DashboardServlet" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <a href="DashboardServlet" class="active">&#9881; Dashboard</a>
            <a href="MissionsServlet">&#128293; Missions</a>
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
        <!-- Welcome Gamer Banner -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
            <div>
                <div class="badge badge-solved" style="margin-bottom: 0.6rem;">&#9670; Player Terminal Active &#9670;</div>
                <h1 style="margin-bottom: 0.2rem;">Welcome back, <span style="color: var(--primary-neon);"><%= user.getUsername() %></span></h1>
                <p style="color: var(--text-muted); margin-bottom: 0;">Rank: <strong style="color: var(--accent-amber);">#<%= user.getRank() %></strong> &bull; Class: <strong style="color: var(--accent-purple);"><%= user.getTierTitle() %></strong></p>
            </div>
            <div>
                <a href="MissionsServlet" class="btn-primary">
                    &#9654; Enter Mission Board
                </a>
            </div>
        </div>

        <!-- Level XP Progression -->
        <div class="level-progress-container">
            <div class="progress-header">
                <span>Tier: <strong style="color: var(--primary-neon);">Level <%= user.getLevel() %> (<%= user.getTierTitle() %>)</strong></span>
                <span>Next Tier: <strong>Level <%= user.getLevel() + 1 %></strong></span>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: <%= user.getProgressPercentage() %>%;"></div>
            </div>
            <div style="display: flex; justify-content: space-between; margin-top: 8px; font-size: 0.85rem; color: var(--text-muted);">
                <span><%= user.getXp() %> XP earned</span>
                <span><%= user.getProgressPercentage() %>% to next level (<%= user.getXpForNextLevel() - user.getXp() %> XP needed)</span>
            </div>
        </div>

        <!-- Metric Stat Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">&#9889;</div>
                <div>
                    <div class="stat-label">Total Experience</div>
                    <div class="stat-value" style="color: var(--primary-neon);"><%= user.getXp() %> <span style="font-size: 0.9rem;">XP</span></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple">&#128737;</div>
                <div>
                    <div class="stat-label">Current Level</div>
                    <div class="stat-value" style="color: var(--accent-purple);">LVL <%= user.getLevel() %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber">&#127942;</div>
                <div>
                    <div class="stat-label">Global Standing</div>
                    <div class="stat-value" style="color: var(--accent-amber);">#<%= user.getRank() %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue">&#10004;</div>
                <div>
                    <div class="stat-label">Missions Solved</div>
                    <div class="stat-value" style="color: var(--accent-blue);"><%= solvedMissions %> / <%= totalMissions %></div>
                </div>
            </div>
        </div>

        <!-- Recommended Quests Section -->
        <div style="margin-top: 2.5rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.2rem;">
                <h2>Recommended Quests</h2>
                <a href="MissionsServlet" style="color: var(--primary-neon); text-decoration: none; font-size: 0.95rem; font-weight: 600;">View All Missions &rarr;</a>
            </div>

            <% if (recommended == null || recommended.isEmpty()) { %>
                <div class="alert alert-info">
                    <span>&#127881;</span> Outstanding! You have cleared all available recommended missions in the grid.
                </div>
            <% } else { %>
                <div class="mission-grid">
                    <% for (Mission m : recommended) { %>
                        <div class="mission-card">
                            <div>
                                <div class="mission-category"><%= m.getCategory() %></div>
                                <h3 class="mission-title"><%= m.getTitle() %></h3>
                                <p class="mission-desc"><%= m.getDescription() %></p>
                            </div>
                            <div class="mission-footer">
                                <div>
                                    <% 
                                        String diff = m.getDifficulty();
                                        String badgeClass = "badge-easy";
                                        if ("Medium".equalsIgnoreCase(diff)) badgeClass = "badge-medium";
                                        else if ("Hard".equalsIgnoreCase(diff)) badgeClass = "badge-hard";
                                    %>
                                    <span class="badge <%= badgeClass %>"><%= diff %></span>
                                    <span style="color: var(--primary-neon); font-size: 0.85rem; font-weight: 700; margin-left: 6px;">+<%= m.getXpReward() %> XP</span>
                                </div>
                                <a href="MissionDetailServlet?id=<%= m.getId() %>" class="btn-primary btn-sm">
                                    Launch &rarr;
                                </a>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>
</body>
</html>
