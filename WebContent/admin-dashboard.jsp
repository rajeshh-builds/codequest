<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.Admin" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
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
    <div class="top-glow-bar" style="background: linear-gradient(90deg, #a855f7, #ec4899, #00f2fe, #a855f7);"></div>

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
            <div class="brand-text">OVERSEER<span style="background: linear-gradient(135deg, #a855f7, #ec4899); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">PORTAL</span></div>
        </a>
        <div class="nav-links">
            <a href="AdminDashboardServlet" class="active">&#9881; Console</a>
            <a href="AdminMissionServlet?action=new">&#10010; Forge Mission</a>
            <a href="LeaderboardServlet" target="_blank">&#127942; Public Standings</a>
            <span style="color: var(--accent-purple); font-weight: 700; margin-left: 10px;">
                &#128100; <%= SecurityUtil.escapeHtml(admin.getFullName()) %>
            </span>
            <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
        </div>
    </div>

    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2.2rem; flex-wrap: wrap; gap: 1.2rem;">
            <div>
                <div class="badge" style="background: rgba(168, 85, 247, 0.15); color: var(--accent-purple); border: 1px solid rgba(168, 85, 247, 0.35); margin-bottom: 0.6rem;">
                    &#9881; Master Security Control Matrix
                </div>
                <h1 style="margin-bottom: 0.3rem;">System Administration Console</h1>
                <p class="subtitle" style="margin-bottom: 0;">Supervise platform metrics, forge new challenges, and govern the mission grid</p>
            </div>
            <div>
                <a href="AdminMissionServlet?action=new" class="btn-primary" style="background: linear-gradient(135deg, var(--accent-purple), #ec4899); box-shadow: 0 4px 18px rgba(168, 85, 247, 0.35);">
                    &#10010; Forge New Mission
                </a>
            </div>
        </div>

        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="alert alert-success">
                <span>&#10004;</span> <%= SecurityUtil.escapeHtml(msg) %>
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
                    <div class="stat-value" style="color: #00f2fe;"><%= totalMissions %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber">&#9889;</div>
                <div>
                    <div class="stat-label">Solved Quests Logged</div>
                    <div class="stat-value" style="color: var(--accent-amber);"><%= totalSubmissions %></div>
                </div>
            </div>
        </div>

        <!-- Missions Management Ledger -->
        <div style="margin-top: 2.5rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.2rem; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h2>Mission Registry Management</h2>
                    <span style="color: var(--text-muted); font-size: 0.9rem;">
                        Showing <%= (missions != null ? missions.size() : 0) %> registered challenges
                    </span>
                </div>
                <div>
                    <input type="text" id="adminSearch" placeholder="Filter missions by title/domain..." 
                           style="padding: 8px 16px; border-radius: 20px; font-size: 0.88rem; width: 260px;"
                           oninput="filterAdminMissions()">
                </div>
            </div>

            <% if (missions == null || missions.isEmpty()) { %>
                <div class="alert alert-info">
                    No missions in the grid. Click "Forge New Mission" above to deploy the first one!
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="data-table" id="adminMissionsTable">
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
                                <tr data-search="<%= SecurityUtil.escapeHtml(m.getTitle().toLowerCase() + " " + m.getCategory().toLowerCase()) %>">
                                    <td style="color: var(--text-muted); font-family: var(--font-mono);">#<%= m.getId() %></td>
                                    <td>
                                        <strong style="color: var(--text-main);"><%= SecurityUtil.escapeHtml(m.getTitle()) %></strong>
                                    </td>
                                    <td>
                                        <span style="color: var(--accent-blue);"><%= SecurityUtil.escapeHtml(m.getCategory()) %></span>
                                    </td>
                                    <td>
                                        <span class="badge <%= badgeClass %>"><%= diff %></span>
                                    </td>
                                    <td>
                                        <strong style="color: #00f2fe;">+<%= m.getXpReward() %> XP</strong>
                                    </td>
                                    <td style="font-family: var(--font-mono); font-size: 0.9rem; color: #6ee7b7;">
                                        <%= SecurityUtil.escapeHtml(m.getCorrectAnswer()) %>
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

    <script>
        function filterAdminMissions() {
            const query = document.getElementById('adminSearch').value.toLowerCase().trim();
            const rows = document.querySelectorAll('#adminMissionsTable tbody tr');
            rows.forEach(r => {
                const s = r.getAttribute('data-search') || '';
                r.style.display = (!query || s.includes(query)) ? '' : 'none';
            });
        }
    </script>
</body>
</html>
