<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.Admin" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Overseer Command Center</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <%
        Admin admin = (Admin) session.getAttribute("adminUser");
        if (admin == null) {
            response.sendRedirect("login.jsp?role=admin&msg=Access Denied. Overseer login required.");
            return;
        }

        Integer totalUsersObj = (Integer) request.getAttribute("totalUsers");
        int totalUsers = (totalUsersObj != null) ? totalUsersObj : 0;

        Integer totalMissionsObj = (Integer) request.getAttribute("totalMissions");
        int totalMissions = (totalMissionsObj != null) ? totalMissionsObj : 0;

        Integer totalSubmissionsObj = (Integer) request.getAttribute("totalSubmissions");
        int totalSubmissions = (totalSubmissionsObj != null) ? totalSubmissionsObj : 0;

        @SuppressWarnings("unchecked")
        List<Mission> missions = (List<Mission>) request.getAttribute("missionsList");

        String msg = request.getParameter("msg");
    %>

    <div class="navbar">
        <a href="AdminDashboardServlet" class="brand-logo">
            <div class="brand-icon" style="background: linear-gradient(135deg, var(--accent-purple), #ec4899);">&lt;/&gt;</div>
            <div class="brand-text">OVERSEER<span>PORTAL</span></div>
        </a>
        <div class="nav-links">
            <a href="AdminDashboardServlet" class="active">&#9881; Console</a>
            <a href="AdminMissionServlet?action=new">&#10010; Forge Mission</a>
            <a href="LeaderboardServlet" target="_blank">&#127942; View Public Leaderboard</a>
            <span style="color: var(--accent-purple); font-weight: 700; margin-left: 10px;">
                &#128100; <%= admin.getFullName() %>
            </span>
            <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
        </div>
    </div>

    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
            <div>
                <div class="badge" style="background: rgba(168, 85, 247, 0.15); color: var(--accent-purple); border: 1px solid rgba(168, 85, 247, 0.3); margin-bottom: 0.6rem;">
                    &#9881; Master Control Matrix
                </div>
                <h1>System Administration Panel</h1>
                <p class="subtitle" style="margin-bottom: 0;">Manage mission catalogs, inspect player submissions, and supervise the platform grid</p>
            </div>
            <div>
                <a href="AdminMissionServlet?action=new" class="btn-primary" style="background: linear-gradient(135deg, var(--accent-purple), #ec4899); box-shadow: 0 4px 15px rgba(168, 85, 247, 0.3);">
                    &#10010; Create New Mission
                </a>
            </div>
        </div>

        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="alert alert-success">
                <span>&#10004;</span> <%= msg %>
            </div>
        <% } %>

        <!-- Overseer Metrics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon purple">&#128101;</div>
                <div>
                    <div class="stat-label">Enlisted Coders</div>
                    <div class="stat-value" style="color: var(--accent-purple);"><%= totalUsers %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">&#127919;</div>
                <div>
                    <div class="stat-label">Total Missions</div>
                    <div class="stat-value" style="color: var(--primary-neon);"><%= totalMissions %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber">&#9889;</div>
                <div>
                    <div class="stat-label">Total Solved Quests</div>
                    <div class="stat-value" style="color: var(--accent-amber);"><%= totalSubmissions %></div>
                </div>
            </div>
        </div>

        <!-- Missions Management Ledger -->
        <div style="margin-top: 2rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.2rem;">
                <h2>Mission Registry Management</h2>
                <span style="color: var(--text-muted); font-size: 0.9rem;">
                    Displaying <%= (missions != null ? missions.size() : 0) %> registered challenges
                </span>
            </div>

            <% if (missions == null || missions.isEmpty()) { %>
                <div class="alert alert-info">
                    No missions in the grid. Click "Create New Mission" above to forge the first one!
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Mission Title</th>
                                <th>Category</th>
                                <th>Difficulty</th>
                                <th>XP Bounty</th>
                                <th>Correct Answer</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Mission m : missions) { 
                                String diff = m.getDifficulty();
                                String badgeClass = "badge-easy";
                                if ("Medium".equalsIgnoreCase(diff)) badgeClass = "badge-medium";
                                else if ("Hard".equalsIgnoreCase(diff)) badgeClass = "badge-hard";
                            %>
                                <tr>
                                    <td style="color: var(--text-muted); font-family: var(--font-mono);">#<%= m.getId() %></td>
                                    <td>
                                        <strong style="color: var(--text-main);"><%= m.getTitle() %></strong>
                                    </td>
                                    <td>
                                        <span style="color: var(--accent-blue);"><%= m.getCategory() %></span>
                                    </td>
                                    <td>
                                        <span class="badge <%= badgeClass %>"><%= diff %></span>
                                    </td>
                                    <td>
                                        <strong style="color: var(--primary-neon);">+<%= m.getXpReward() %> XP</strong>
                                    </td>
                                    <td style="font-family: var(--font-mono); font-size: 0.9rem; color: #6ee7b7;">
                                        <%= m.getCorrectAnswer() %>
                                    </td>
                                    <td style="text-align: right; white-space: nowrap;">
                                        <a href="AdminMissionServlet?action=edit&id=<%= m.getId() %>" class="btn-secondary btn-sm" style="margin-right: 6px;">
                                            &#9998; Edit
                                        </a>
                                        <a href="AdminDeleteMissionServlet?id=<%= m.getId() %>" 
                                           class="btn-danger btn-sm"
                                           onclick="return confirm('Purge this mission permanently from the database?');">
                                            &#128465; Delete
                                        </a>
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
        &copy; 2026 CodeQuest Platform &bull; Overseer Security Layer Active
    </footer>
</body>
</html>
