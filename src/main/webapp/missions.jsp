<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Missions Terminal</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .filter-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2rem;
            background: var(--surface-alt);
            padding: 1.2rem;
            border-radius: 12px;
            border: 1px solid var(--border);
        }
        .filter-group {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-chip {
            padding: 6px 14px;
            background: var(--bg-darker);
            border: 1px solid var(--border);
            border-radius: 20px;
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .filter-chip:hover {
            color: var(--primary-neon);
            border-color: var(--primary-neon);
        }
        .filter-chip.active {
            background: var(--primary-neon);
            color: var(--bg-darker);
            font-weight: 700;
            box-shadow: 0 0 10px var(--primary-glow);
        }
    </style>
</head>
<body>
    <%
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("login.jsp?msg=Please log in to view missions.");
            return;
        }

        @SuppressWarnings("unchecked")
        List<Mission> missions = (List<Mission>) request.getAttribute("missionsList");

        @SuppressWarnings("unchecked")
        List<String> categories = (List<String>) request.getAttribute("categoryList");

        String currentCat = (String) request.getAttribute("currentCategory");
        if (currentCat == null) currentCat = "all";

        String currentDiff = (String) request.getAttribute("currentDifficulty");
        if (currentDiff == null) currentDiff = "all";
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
        <div style="margin-bottom: 1.8rem;">
            <div class="badge badge-solved" style="margin-bottom: 0.6rem;">&#9670; Quest Database &#9670;</div>
            <h1>Active Mission Operations</h1>
            <p class="subtitle" style="margin-bottom: 0;">Solve algorithmic coding dilemmas to harvest XP and ascend your security clearance</p>
        </div>

        <!-- Filter Controls -->
        <div class="filter-bar">
            <!-- Category Filter -->
            <div class="filter-group">
                <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase;">Domain:</span>
                <a href="MissionsServlet?category=all&difficulty=<%= currentDiff %>" 
                   class="filter-chip <%= ("all".equalsIgnoreCase(currentCat) ? "active" : "") %>">All</a>
                <% if (categories != null) { 
                    for (String cat : categories) { %>
                        <a href="MissionsServlet?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>&difficulty=<%= currentDiff %>" 
                           class="filter-chip <%= (cat.equalsIgnoreCase(currentCat) ? "active" : "") %>">
                           <%= cat %>
                        </a>
                <%  } 
                } %>
            </div>

            <!-- Difficulty Filter -->
            <div class="filter-group">
                <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase;">Threat Level:</span>
                <a href="MissionsServlet?category=<%= java.net.URLEncoder.encode(currentCat, "UTF-8") %>&difficulty=all" 
                   class="filter-chip <%= ("all".equalsIgnoreCase(currentDiff) ? "active" : "") %>">All</a>
                <a href="MissionsServlet?category=<%= java.net.URLEncoder.encode(currentCat, "UTF-8") %>&difficulty=Easy" 
                   class="filter-chip <%= ("Easy".equalsIgnoreCase(currentDiff) ? "active" : "") %>">Easy</a>
                <a href="MissionsServlet?category=<%= java.net.URLEncoder.encode(currentCat, "UTF-8") %>&difficulty=Medium" 
                   class="filter-chip <%= ("Medium".equalsIgnoreCase(currentDiff) ? "active" : "") %>">Medium</a>
                <a href="MissionsServlet?category=<%= java.net.URLEncoder.encode(currentCat, "UTF-8") %>&difficulty=Hard" 
                   class="filter-chip <%= ("Hard".equalsIgnoreCase(currentDiff) ? "active" : "") %>">Hard</a>
            </div>
        </div>

        <!-- Missions Grid -->
        <% if (missions == null || missions.isEmpty()) { %>
            <div class="alert alert-info" style="text-align: center; justify-content: center;">
                No missions found matching the selected filter criteria.
            </div>
        <% } else { %>
            <div class="mission-grid">
                <% for (Mission m : missions) { 
                    String diff = m.getDifficulty();
                    String badgeClass = "badge-easy";
                    if ("Medium".equalsIgnoreCase(diff)) badgeClass = "badge-medium";
                    else if ("Hard".equalsIgnoreCase(diff)) badgeClass = "badge-hard";
                %>
                    <div class="mission-card <%= (m.isSolved() ? "solved" : "") %>">
                        <div>
                            <div class="mission-card-header">
                                <div class="mission-category"><%= m.getCategory() %></div>
                                <% if (m.isSolved()) { %>
                                    <span class="badge badge-solved">&#10004; Solved</span>
                                <% } %>
                            </div>
                            <h3 class="mission-title"><%= m.getTitle() %></h3>
                            <p class="mission-desc"><%= m.getDescription() %></p>
                        </div>
                        <div class="mission-footer">
                            <div>
                                <span class="badge <%= badgeClass %>"><%= diff %></span>
                                <span style="color: var(--primary-neon); font-size: 0.85rem; font-weight: 700; margin-left: 6px;">+<%= m.getXpReward() %> XP</span>
                            </div>
                            <% if (m.isSolved()) { %>
                                <a href="MissionDetailServlet?id=<%= m.getId() %>" class="btn-secondary btn-sm" style="border-color: rgba(45, 212, 191, 0.4); color: var(--primary-neon);">
                                    Review &rarr;
                                </a>
                            <% } else { %>
                                <a href="MissionDetailServlet?id=<%= m.getId() %>" class="btn-primary btn-sm">
                                    Initiate &rarr;
                                </a>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>
</body>
</html>
