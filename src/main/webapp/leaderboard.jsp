<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Global Leaderboard</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <%
        User currentUser = (User) session.getAttribute("currentUser");

        @SuppressWarnings("unchecked")
        List<User> leaderboard = (List<User>) request.getAttribute("leaderboardList");
    %>

    <div class="navbar">
        <a href="index.html" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <% if (currentUser != null) { %>
                <a href="DashboardServlet">&#9881; Dashboard</a>
                <a href="MissionsServlet">&#128293; Missions</a>
                <a href="LeaderboardServlet" class="active">&#127942; Leaderboard</a>
                <a href="ProfileServlet">&#128100; <%= currentUser.getUsername() %></a>
                <div class="nav-user-badge">
                    <span class="level-chip">LVL <%= currentUser.getLevel() %></span>
                    <span class="xp-chip"><%= currentUser.getXp() %> XP</span>
                </div>
                <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
            <% } else { %>
                <a href="index.html">Home</a>
                <a href="LeaderboardServlet" class="active">&#127942; Leaderboard</a>
                <a href="login.jsp" class="btn-secondary btn-sm">Sign In</a>
                <a href="register.jsp" class="btn-primary btn-sm">Join Quest</a>
            <% } %>
        </div>
    </div>

    <div class="container">
        <div style="text-align: center; margin-bottom: 2.5rem;">
            <div class="badge badge-solved" style="margin-bottom: 0.6rem;">&#9670; Hall of Champions &#9670;</div>
            <h1>Global Developer Leaderboard</h1>
            <p class="subtitle" style="margin-bottom: 0;">Top ranking architects recognized for tactical coding and problem-solving supremacy</p>
        </div>

        <% if (leaderboard == null || leaderboard.isEmpty()) { %>
            <div class="alert alert-info" style="text-align: center;">
                No rankings recorded yet. Complete your first mission to claim the summit!
            </div>
        <% } else { %>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 80px; text-align: center;">Rank</th>
                            <th>Coder Identity</th>
                            <th>Class / Tier</th>
                            <th>Level</th>
                            <th>Missions Cleared</th>
                            <th style="text-align: right;">Total Experience</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (User coder : leaderboard) { 
                            int rank = coder.getRank();
                            boolean isMe = (currentUser != null && coder.getId() == currentUser.getId());
                        %>
                            <tr style="<%= (isMe ? "background-color: rgba(45, 212, 191, 0.08); border-left: 3px solid var(--primary-neon);" : "") %>">
                                <td style="text-align: center;">
                                    <% if (rank == 1) { %>
                                        <span class="rank-badge rank-1">&#127941;</span>
                                    <% } else if (rank == 2) { %>
                                        <span class="rank-badge rank-2">&#129352;</span>
                                    <% } else if (rank == 3) { %>
                                        <span class="rank-badge rank-3">&#129353;</span>
                                    <% } else { %>
                                        <span style="font-family: var(--font-heading); font-weight: 700; color: var(--text-muted);">#<%= rank %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <strong style="color: <%= (isMe ? "var(--primary-neon)" : "var(--text-main)") %>; font-size: 1.05rem;">
                                        <%= coder.getUsername() %>
                                    </strong>
                                    <% if (isMe) { %>
                                        <span class="badge badge-solved" style="margin-left: 8px; font-size: 0.7rem;">You</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span style="color: var(--accent-purple); font-weight: 600;">
                                        <%= coder.getTierTitle() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="level-chip">LVL <%= coder.getLevel() %></span>
                                </td>
                                <td>
                                    <span style="color: var(--accent-blue); font-weight: 600;">
                                        &#10004; <%= coder.getSolvedMissions() %>
                                    </span>
                                </td>
                                <td style="text-align: right;">
                                    <strong style="color: var(--primary-neon); font-family: var(--font-heading); font-size: 1.1rem;">
                                        <%= coder.getXp() %>
                                    </strong> 
                                    <span style="font-size: 0.8rem; color: var(--text-muted);">XP</span>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>

        <% if (currentUser == null) { %>
            <div style="text-align: center; margin-top: 2.5rem;">
                <p style="color: var(--text-muted); margin-bottom: 1rem;">Want to see your name on the hall of fame?</p>
                <a href="register.jsp" class="btn-primary">Enlist Now &rarr;</a>
            </div>
        <% } %>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>
</body>
</html>
