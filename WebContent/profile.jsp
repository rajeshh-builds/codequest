<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Submission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Operative Profile</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .profile-header {
            display: flex;
            align-items: center;
            gap: 2rem;
            margin-bottom: 2.2rem;
            background: linear-gradient(145deg, rgba(15, 23, 42, 0.9), rgba(10, 16, 30, 0.95));
            padding: 2.2rem;
            border-radius: 16px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            flex-wrap: wrap;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            position: relative;
            overflow: hidden;
        }
        .profile-avatar {
            width: 95px;
            height: 95px;
            border-radius: 20px;
            background: linear-gradient(135deg, #00f2fe, #a855f7);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-heading);
            font-size: 2.8rem;
            font-weight: 900;
            color: #04070d;
            box-shadow: 0 0 25px rgba(0, 242, 254, 0.4);
            border: 2px solid rgba(255, 255, 255, 0.3);
            flex-shrink: 0;
        }
        .badges-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 1.2rem;
            margin-top: 1rem;
            margin-bottom: 2.2rem;
        }
        .badge-card {
            background: rgba(10, 16, 30, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 12px;
            padding: 1.2rem;
            text-align: center;
            transition: all 0.25s ease;
        }
        .badge-card.unlocked {
            border-color: rgba(0, 242, 254, 0.4);
            box-shadow: 0 0 15px rgba(0, 242, 254, 0.15);
        }
        .badge-card.locked {
            opacity: 0.5;
            filter: grayscale(80%);
        }
        .badge-card-icon {
            font-size: 2.2rem;
            margin-bottom: 6px;
        }
        .badge-card-title {
            font-family: var(--font-heading);
            font-size: 0.88rem;
            color: #fff;
            margin-bottom: 4px;
        }
        .badge-card-status {
            font-size: 0.75rem;
            color: var(--text-muted);
            text-transform: uppercase;
            font-weight: 700;
        }
    </style>
</head>
<body>
    <div class="top-glow-bar"></div>

    <%
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        @SuppressWarnings("unchecked")
        List<Submission> history = (List<Submission>) request.getAttribute("submissionHistory");
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
        int solvedCount = (history != null) ? history.size() : 0;
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
            <a href="ProfileServlet" class="active">&#128100; <%= SecurityUtil.escapeHtml(user.getUsername()) %></a>
            <div class="nav-user-badge">
                <span class="status-dot"></span>
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
            <div style="flex-grow: 1;">
                <div class="badge badge-solved" style="margin-bottom: 0.5rem;"><%= user.getTierTitle() %></div>
                <h1 style="margin-bottom: 0.3rem;"><%= SecurityUtil.escapeHtml(user.getUsername()) %></h1>
                <p style="color: var(--text-muted); margin-bottom: 0;">
                    Neural ID: <span style="color: #38bdf8;"><%= SecurityUtil.escapeHtml(user.getEmail()) %></span> &bull; 
                    Level <strong style="color: #00f2fe;"><%= user.getLevel() %></strong> &bull; 
                    Total Harvested XP: <strong style="color: var(--accent-amber);"><%= user.getXp() %> XP</strong>
                </p>
            </div>
            <div>
                <a href="MissionsServlet" class="btn-primary">
                    &#9654; Enter Missions
                </a>
            </div>
        </div>

        <!-- Level XP Progression Bar -->
        <div class="level-progress-container">
            <div class="progress-header">
                <span>Security Clearance: <strong style="color: #00f2fe;">Level <%= user.getLevel() %></strong></span>
                <span>Next Milestone: <strong style="color: var(--accent-purple);">Level <%= user.getLevel() + 1 %></strong></span>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: <%= user.getProgressPercentage() %>%;"></div>
            </div>
            <div style="display: flex; justify-content: space-between; margin-top: 10px; font-size: 0.88rem; color: var(--text-muted);">
                <span><%= user.getXp() %> XP accumulated</span>
                <span><%= user.getProgressPercentage() %>% to Level <%= user.getLevel() + 1 %> (<%= user.getXpForNextLevel() - user.getXp() %> XP remaining)</span>
            </div>
        </div>

        <!-- Achievements Badges Showcase -->
        <div>
            <h2>Operative Achievements &amp; Medallions</h2>
            <p class="subtitle" style="margin-bottom: 1rem;">Milestones unlocked based on problem-solving consistency and clearance levels</p>

            <div class="badges-grid">
                <!-- Badge 1: First Blood -->
                <div class="badge-card <%= (solvedCount >= 1 ? "unlocked" : "locked") %>">
                    <div class="badge-card-icon">&#128293;</div>
                    <div class="badge-card-title">First Blood</div>
                    <div class="badge-card-status" style="color: <%= (solvedCount >= 1 ? "#34d399" : "var(--text-dim)") %>;">
                        <%= (solvedCount >= 1 ? "&#10004; Unlocked" : "Solve 1 Mission") %>
                    </div>
                </div>

                <!-- Badge 2: Algorithm Ace -->
                <div class="badge-card <%= (solvedCount >= 3 ? "unlocked" : "locked") %>">
                    <div class="badge-card-icon">&#9889;</div>
                    <div class="badge-card-title">Code Adept</div>
                    <div class="badge-card-status" style="color: <%= (solvedCount >= 3 ? "#34d399" : "var(--text-dim)") %>;">
                        <%= (solvedCount >= 3 ? "&#10004; Unlocked" : "Solve 3 Missions") %>
                    </div>
                </div>

                <!-- Badge 3: Century Architect -->
                <div class="badge-card <%= (user.getXp() >= 500 ? "unlocked" : "locked") %>">
                    <div class="badge-card-icon">&#127942;</div>
                    <div class="badge-card-title">Overclocker</div>
                    <div class="badge-card-status" style="color: <%= (user.getXp() >= 500 ? "#34d399" : "var(--text-dim)") %>;">
                        <%= (user.getXp() >= 500 ? "&#10004; Unlocked" : "Earn 500+ XP") %>
                    </div>
                </div>

                <!-- Badge 4: Cyber Overlord -->
                <div class="badge-card <%= (user.getLevel() >= 10 ? "unlocked" : "locked") %>">
                    <div class="badge-card-icon">&#128081;</div>
                    <div class="badge-card-title">Cyber Overlord</div>
                    <div class="badge-card-status" style="color: <%= (user.getLevel() >= 10 ? "#34d399" : "var(--text-dim)") %>;">
                        <%= (user.getLevel() >= 10 ? "&#10004; Unlocked" : "Reach Level 10") %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Solved Missions History -->
        <div style="margin-top: 1.5rem;">
            <div style="margin-bottom: 1.2rem;">
                <h2>Mission Accomplishment Ledger</h2>
                <p class="subtitle" style="margin-bottom: 0;">Historical record of encrypted challenges solved and XP bounties secured</p>
            </div>

            <% if (history == null || history.isEmpty()) { %>
                <div class="alert alert-info">
                    No missions completed yet. Visit the <a href="MissionsServlet" style="color: #00f2fe; font-weight: 700; text-decoration: underline;">Mission Terminal</a> to start conquering quests!
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
                                        <a href="MissionDetailServlet?id=<%= sub.getMissionId() %>" style="color: var(--text-main); font-weight: 700; text-decoration: none;">
                                            <%= SecurityUtil.escapeHtml(sub.getMissionTitle()) %> &rarr;
                                        </a>
                                    </td>
                                    <td>
                                        <span style="color: var(--accent-blue);"><%= SecurityUtil.escapeHtml(sub.getCategory()) %></span>
                                    </td>
                                    <td>
                                        <strong style="color: #00f2fe;">+<%= sub.getXpReward() %> XP</strong>
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
        &copy; 2026 CodeQuest Platform &bull; Operative Profile
    </footer>
</body>
</html>
