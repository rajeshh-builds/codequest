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
    <title>CodeQuest - Missions Terminal</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .filter-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 1.2rem;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2.2rem;
            background: rgba(10, 16, 30, 0.85);
            padding: 1.4rem;
            border-radius: 14px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
        }
        .filter-group {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-chip {
            padding: 7px 16px;
            background: rgba(4, 7, 13, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 20px;
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.25s var(--ease-smooth);
            font-family: var(--font-subheading);
            letter-spacing: 0.03em;
        }
        .filter-chip:hover {
            color: #00f2fe;
            border-color: #00f2fe;
            box-shadow: 0 0 12px rgba(0, 242, 254, 0.2);
        }
        .filter-chip.active {
            background: #00f2fe;
            color: #04070d;
            font-weight: 800;
            border-color: #00f2fe;
            box-shadow: 0 0 15px rgba(0, 242, 254, 0.45);
        }
        .client-search-input {
            background: rgba(4, 7, 13, 0.9);
            border: 1px solid rgba(255, 255, 255, 0.15);
            padding: 10px 16px 10px 38px;
            border-radius: 20px;
            color: #fff;
            font-size: 0.9rem;
            width: 260px;
            transition: all 0.25s ease;
        }
        .client-search-input:focus {
            outline: none;
            border-color: #00f2fe;
            box-shadow: 0 0 15px rgba(0, 242, 254, 0.3);
            width: 300px;
        }
    </style>
</head>
<body>
    <div class="top-glow-bar"></div>

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
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
            <div>
                <div class="badge badge-solved" style="margin-bottom: 0.6rem;">&#9670; Quest Database Active &#9670;</div>
                <h1 style="margin-bottom: 0.2rem;">Active Mission Operations</h1>
                <p class="subtitle" style="margin-bottom: 0;">Solve algorithmic coding dilemmas to harvest XP and ascend your security clearance</p>
            </div>
            <!-- Real-time Instant Search Input -->
            <div style="position: relative;">
                <span style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 0.95rem;">&#128269;</span>
                <input type="text" id="liveSearchInput" class="client-search-input" placeholder="Instant filter missions..." oninput="filterMissionsRealtime()">
            </div>
        </div>

        <!-- Filter Controls -->
        <div class="filter-bar">
            <!-- Category Filter -->
            <div class="filter-group">
                <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; font-family: var(--font-subheading); letter-spacing: 0.05em;">Domain:</span>
                <a href="MissionsServlet?category=all&difficulty=<%= currentDiff %>" 
                   class="filter-chip <%= ("all".equalsIgnoreCase(currentCat) ? "active" : "") %>">All</a>
                <% if (categories != null) { 
                    for (String cat : categories) { %>
                        <a href="MissionsServlet?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>&difficulty=<%= currentDiff %>" 
                           class="filter-chip <%= (cat.equalsIgnoreCase(currentCat) ? "active" : "") %>">
                           <%= SecurityUtil.escapeHtml(cat) %>
                        </a>
                <%  } 
                } %>
            </div>

            <!-- Difficulty Filter -->
            <div class="filter-group">
                <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; font-family: var(--font-subheading); letter-spacing: 0.05em;">Threat Level:</span>
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
            <div class="mission-grid" id="missionsGridContainer">
                <% for (Mission m : missions) { 
                    String diff = m.getDifficulty();
                    String badgeClass = "badge-easy";
                    if ("Medium".equalsIgnoreCase(diff)) badgeClass = "badge-medium";
                    else if ("Hard".equalsIgnoreCase(diff)) badgeClass = "badge-hard";
                %>
                    <div class="mission-card <%= (m.isSolved() ? "solved" : "") %>" data-title="<%= SecurityUtil.escapeHtml(m.getTitle().toLowerCase()) %>" data-category="<%= SecurityUtil.escapeHtml(m.getCategory().toLowerCase()) %>">
                        <div>
                            <div class="mission-card-header">
                                <div class="mission-category"><%= SecurityUtil.escapeHtml(m.getCategory()) %></div>
                                <% if (m.isSolved()) { %>
                                    <span class="badge badge-solved">&#10004; Solved</span>
                                <% } %>
                            </div>
                            <h3 class="mission-title"><%= SecurityUtil.escapeHtml(m.getTitle()) %></h3>
                            <p class="mission-desc"><%= SecurityUtil.escapeHtml(m.getDescription()) %></p>
                        </div>
                        <div class="mission-footer">
                            <div>
                                <span class="badge <%= badgeClass %>"><%= diff %></span>
                                <span style="color: #00f2fe; font-size: 0.88rem; font-weight: 800; margin-left: 8px;">+<%= m.getXpReward() %> XP</span>
                            </div>
                            <% if (m.isSolved()) { %>
                                <a href="MissionDetailServlet?id=<%= m.getId() %>" class="btn-secondary btn-sm" style="border-color: rgba(0, 242, 254, 0.4); color: #00f2fe;">
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
            <div id="noMatchAlert" class="alert alert-info" style="display: none; text-align: center; justify-content: center; margin-top: 1.5rem;">
                No mission titles or domains match your search query.
            </div>
        <% } %>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>

    <script>
        function filterMissionsRealtime() {
            const query = document.getElementById('liveSearchInput').value.toLowerCase().trim();
            const cards = document.querySelectorAll('#missionsGridContainer .mission-card');
            let visibleCount = 0;

            cards.forEach(card => {
                const title = card.getAttribute('data-title') || '';
                const cat = card.getAttribute('data-category') || '';
                if (!query || title.includes(query) || cat.includes(query)) {
                    card.style.display = 'flex';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            });

            const noMatch = document.getElementById('noMatchAlert');
            if (noMatch) {
                noMatch.style.display = (visibleCount === 0) ? 'flex' : 'none';
            }
        }
    </script>
</body>
</html>
