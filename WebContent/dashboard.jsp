<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Operative Command Center</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="top-glow-bar"></div>

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
            <a href="ProfileServlet">&#128100; <%= SecurityUtil.escapeHtml(user.getUsername()) %></a>
            <div class="nav-user-badge">
                <span class="status-dot"></span>
                <span class="level-chip">LVL <%= user.getLevel() %></span>
                <span class="xp-chip"><%= user.getXp() %> XP</span>
            </div>
            <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
        </div>
    </div>

    <div class="container">
        <!-- Welcome Gamer HUD Banner -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1.2rem;">
            <div>
                <div class="badge badge-solved" style="margin-bottom: 0.6rem;">
                    <span class="status-dot" style="display: inline-block;"></span>
                    Operative Terminal Active
                </div>
                <h1 style="margin-bottom: 0.2rem;">Welcome back, <span style="color: #00f2fe;"><%= SecurityUtil.escapeHtml(user.getUsername()) %></span></h1>
                <p style="color: var(--text-muted); margin-bottom: 0;">Global Standing: <strong style="color: var(--accent-amber);">#<%= user.getRank() %></strong> &bull; Security Clearance: <strong style="color: var(--accent-purple);"><%= user.getTierTitle() %></strong></p>
            </div>
            <div style="display: flex; gap: 10px;">
                <a href="MissionsServlet" class="btn-primary">
                    &#9654; Enter Mission Board
                </a>
                <a href="LeaderboardServlet" class="btn-secondary">
                    &#127942; Hall of Fame
                </a>
            </div>
        </div>

        <!-- Level XP Progression Bar -->
        <div class="level-progress-container">
            <div class="progress-header">
                <span>Current Tier: <strong style="color: #00f2fe;">Level <%= user.getLevel() %> (<%= user.getTierTitle() %>)</strong></span>
                <span>Next Clearance: <strong style="color: var(--accent-purple);">Level <%= user.getLevel() + 1 %></strong></span>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: <%= user.getProgressPercentage() %>%;"></div>
            </div>
            <div style="display: flex; justify-content: space-between; margin-top: 10px; font-size: 0.88rem; color: var(--text-muted);">
                <span><%= user.getXp() %> Total XP harvested</span>
                <span><%= user.getProgressPercentage() %>% to next level (<%= user.getXpForNextLevel() - user.getXp() %> XP required)</span>
            </div>
        </div>

        <!-- Metric Stat Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">&#9889;</div>
                <div>
                    <div class="stat-label">Total Experience</div>
                    <div class="stat-value" style="color: #00f2fe;"><%= user.getXp() %> <span style="font-size: 0.85rem; color: var(--text-muted);">XP</span></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple">&#128737;</div>
                <div>
                    <div class="stat-label">Security Clearance</div>
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
                    <div class="stat-label">Missions Cleared</div>
                    <div class="stat-value" style="color: var(--accent-blue);"><%= solvedMissions %> / <%= totalMissions %></div>
                </div>
            </div>
        </div>

        <!-- Recommended Quests Section -->
        <div style="margin-top: 2.8rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.4rem;">
                <div>
                    <h2>Recommended Tactical Quests</h2>
                    <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 0;">Unsolved algorithmic challenges tailored to accelerate your clearance</p>
                </div>
                <a href="MissionsServlet" style="color: #00f2fe; text-decoration: none; font-size: 0.95rem; font-weight: 700;">View All Missions &rarr;</a>
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
                                <div class="mission-category"><%= SecurityUtil.escapeHtml(m.getCategory()) %></div>
                                <h3 class="mission-title"><%= SecurityUtil.escapeHtml(m.getTitle()) %></h3>
                                <p class="mission-desc"><%= SecurityUtil.escapeHtml(m.getDescription()) %></p>
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
                                    <span style="color: #00f2fe; font-size: 0.88rem; font-weight: 800; margin-left: 8px;">+<%= m.getXpReward() %> XP</span>
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
        &copy; 2026 CodeQuest Platform &bull; Engineered by Rajesh &bull; Operative Session Active
    </footer>
</body>
</html>
