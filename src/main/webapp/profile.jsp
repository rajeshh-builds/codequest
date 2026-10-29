<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Submission" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Coder Profile</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .profile-header {
            display: flex;
            align-items: center;
            gap: 2rem;
            margin-bottom: 2rem;
            background: var(--surface-alt);
            padding: 2rem;
            border-radius: 14px;
            border: 1px solid var(--border);
            flex-wrap: wrap;
        }
        .profile-avatar {
            width: 90px;
            height: 90px;
            border-radius: 18px;
            background: linear-gradient(135deg, var(--primary-neon), var(--accent-purple));
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-heading);
            font-size: 2.5rem;
            font-weight: 900;
            color: var(--bg-darker);
            box-shadow: 0 0 20px var(--primary-glow);
        }
        .profile-info {
            flex-grow: 1;
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

        @SuppressWarnings("unchecked")
        List<Submission> history = (List<Submission>) request.getAttribute("submissionHistory");
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
    %>

    <div class="navbar">
        <a href="DashboardServlet" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <a href="DashboardServlet">&#9881; Dashboard</a>
            <a href="MissionsServlet">&#128293; Missions</a>
            <a href="LeaderboardServlet">&#127942; Leaderboard</a>
            <a href="ProfileServlet" class="active">&#128100; <%= user.getUsername() %></a>
            <div class="nav-user-badge">
                <span class="level-chip">LVL <%= user.getLevel() %></span>
                <span class="xp-chip"><%= user.getXp() %> XP</span>
            </div>
            <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
        </div>
    </div>

    <div class="container">
        <!-- Profile Overview Card -->
        <div class="profile-header">
            <div class="profile-avatar">
                <%= (user.getUsername() != null && user.getUsername().length() > 0) ? user.getUsername().substring(0, 1).toUpperCase() : "Q" %>
            </div>
            <div class="profile-info">
                <div class="badge badge-solved" style="margin-bottom: 0.5rem;"><%= user.getTierTitle() %></div>
                <h1 style="margin-bottom: 0.3rem;"><%= user.getUsername() %></h1>
                <p style="color: var(--text-muted); margin-bottom: 0;">
                    Neural ID: <span style="color: var(--accent-blue);"><%= user.getEmail() %></span> &bull; 
                    Level <strong style="color: var(--primary-neon);"><%= user.getLevel() %></strong> &bull; 
                    Total XP: <strong style="color: var(--accent-amber);"><%= user.getXp() %></strong>
                </p>
            </div>
            <div>
                <a href="MissionsServlet" class="btn-primary">
                    &#9654; Solve Missions
                </a>
            </div>
        </div>

        <!-- Level XP Progression -->
        <div class="level-progress-container">
            <div class="progress-header">
                <span>Current Mastery: <strong>Level <%= user.getLevel() %></strong></span>
                <span>Next Milestone: <strong>Level <%= user.getLevel() + 1 %></strong></span>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: <%= user.getProgressPercentage() %>%;"></div>
            </div>
            <div style="display: flex; justify-content: space-between; margin-top: 8px; font-size: 0.85rem; color: var(--text-muted);">
                <span><%= user.getXp() %> XP accumulated</span>
                <span><%= user.getProgressPercentage() %>% to Level <%= user.getLevel() + 1 %></span>
            </div>
        </div>

        <!-- Solved Missions History -->
        <div style="margin-top: 2rem;">
            <div style="margin-bottom: 1.2rem;">
                <h2>Mission Accomplishment Ledger</h2>
                <p class="subtitle" style="margin-bottom: 0;">Historical record of encrypted challenges solved and XP bounties secured</p>
            </div>

            <% if (history == null || history.isEmpty()) { %>
                <div class="alert alert-info">
                    No missions completed yet. Visit the <a href="MissionsServlet" style="color: var(--primary-neon); font-weight: 700; text-decoration: underline;">Mission Terminal</a> to start conquering quests!
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Mission Title</th>
                                <th>Domain Category</th>
                                <th>XP Harvested</th>
                                <th>Verification Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int counter = 1;
                                for (Submission sub : history) { 
                            %>
                                <tr>
                                    <td style="color: var(--text-muted);"><%= counter++ %></td>
                                    <td>
                                        <a href="MissionDetailServlet?id=<%= sub.getMissionId() %>" style="color: var(--text-main); font-weight: 600; text-decoration: none;">
                                            <%= sub.getMissionTitle() %> &rarr;
                                        </a>
                                    </td>
                                    <td>
                                        <span style="color: var(--accent-blue);"><%= sub.getCategory() %></span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--primary-neon);">+<%= sub.getXpReward() %> XP</strong>
                                    </td>
                                    <td style="color: var(--text-muted); font-size: 0.9rem;">
                                        <%= (sub.getSubmittedAt() != null) ? sdf.format(sub.getSubmittedAt()) : "Recent" %>
                                    </td>
                                    <td>
                                        <span class="badge badge-solved">&#10004; Cleared</span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>
</body>
</html>
