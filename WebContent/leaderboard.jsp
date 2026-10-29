<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Global Hall of Champions</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .podium-section {
            display: grid;
            grid-template-columns: 1fr 1.15fr 1fr;
            gap: 1.5rem;
            align-items: flex-end;
            margin-bottom: 3rem;
            margin-top: 1rem;
        }

        @media (max-width: 850px) {
            .podium-section {
                grid-template-columns: 1fr;
            }
        }

        .podium-avatar {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin: 0 auto 1rem auto;
            border: 3px solid transparent;
        }

        .gold-border {
            border-color: #fbbf24;
            background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(217, 119, 6, 0.3));
            box-shadow: 0 0 20px rgba(251, 191, 36, 0.5);
        }

        .silver-border {
            border-color: #e2e8f0;
            background: linear-gradient(135deg, rgba(226, 232, 240, 0.2), rgba(148, 163, 184, 0.3));
            box-shadow: 0 0 15px rgba(226, 232, 240, 0.3);
        }

        .bronze-border {
            border-color: #f97316;
            background: linear-gradient(135deg, rgba(249, 115, 22, 0.2), rgba(180, 83, 9, 0.3));
            box-shadow: 0 0 15px rgba(249, 115, 22, 0.3);
        }

        .crown-icon {
            font-size: 1.8rem;
            margin-bottom: -10px;
            display: block;
            animation: floatCrown 3s ease-in-out infinite;
        }

        @keyframes floatCrown {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-6px); }
        }
    </style>
</head>
<body>
    <div class="top-glow-bar"></div>

    <%
        User currentUser = (User) session.getAttribute("currentUser");

        @SuppressWarnings("unchecked")
        List<User> leaderboard = (List<User>) request.getAttribute("leaderboardList");

        User top1 = null;
        User top2 = null;
        User top3 = null;

        if (leaderboard != null) {
            if (leaderboard.size() > 0) top1 = leaderboard.get(0);
            if (leaderboard.size() > 1) top2 = leaderboard.get(1);
            if (leaderboard.size() > 2) top3 = leaderboard.get(2);
        }
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
                <a href="ProfileServlet">&#128100; <%= SecurityUtil.escapeHtml(currentUser.getUsername()) %></a>
                <div class="nav-user-badge">
                    <span class="status-dot"></span>
                    <span class="level-chip">LVL <%= currentUser.getLevel() %></span>
                    <span class="xp-chip"><%= currentUser.getXp() %> XP</span>
                </div>
                <a href="LogoutServlet" class="btn-secondary btn-sm" style="margin-left: 8px;">Logout</a>
            <% } else { %>
                <a href="index.html">Home</a>
                <a href="LeaderboardServlet" class="active">&#127942; Leaderboard</a>
                <a href="login.jsp" class="btn-secondary btn-sm">Sign In</a>
                <a href="register.jsp" class="btn-primary btn-sm">&#9654; Join Quest</a>
            <% } %>
        </div>
    </div>

    <div class="container">
        <div style="text-align: center; margin-bottom: 2rem;">
            <div class="badge badge-solved" style="margin-bottom: 0.6rem;">&#9670; Hall of Champions &#9670;</div>
            <h1 style="margin-bottom: 0.4rem;">Global Developer Leaderboard</h1>
            <p class="subtitle" style="margin-bottom: 0;">Top ranking architects recognized for tactical coding and problem-solving supremacy</p>
        </div>

        <!-- Top 3 Podium Cards -->
        <% if (top1 != null) { %>
            <div class="podium-section">
                <!-- Rank #2 Silver -->
                <% if (top2 != null) { %>
                    <div class="podium-card rank-2-card">
                        <span class="rank-badge rank-2" style="position: absolute; top: 12px; left: 12px;">#2</span>
                        <div class="podium-avatar silver-border">&#129352;</div>
                        <h3 style="margin-bottom: 0.3rem;"><%= SecurityUtil.escapeHtml(top2.getUsername()) %></h3>
                        <div style="color: var(--accent-purple); font-weight: 700; font-size: 0.9rem; margin-bottom: 0.6rem;"><%= top2.getTierTitle() %></div>
                        <div style="font-family: var(--font-heading); font-size: 1.4rem; color: #38bdf8; font-weight: 800;">
                            <%= top2.getXp() %> <span style="font-size: 0.8rem; color: var(--text-muted);">XP</span>
                        </div>
                        <div style="margin-top: 8px;">
                            <span class="level-chip">LVL <%= top2.getLevel() %></span>
                        </div>
                    </div>
                <% } else { %>
                    <div></div>
                <% } %>

                <!-- Rank #1 Gold Champion -->
                <div class="podium-card rank-1-card">
                    <span class="crown-icon">&#128081;</span>
                    <span class="rank-badge rank-1" style="position: absolute; top: 14px; left: 14px;">#1</span>
                    <div class="podium-avatar gold-border">&#127941;</div>
                    <h2 style="color: #fbbf24; margin-bottom: 0.3rem; font-size: 1.6rem;"><%= SecurityUtil.escapeHtml(top1.getUsername()) %></h2>
                    <div style="color: #fbbf24; font-weight: 800; font-size: 0.95rem; margin-bottom: 0.8rem;"><%= top1.getTierTitle() %></div>
                    <div style="font-family: var(--font-heading); font-size: 1.8rem; color: #fbbf24; font-weight: 900; text-shadow: 0 0 15px rgba(251, 191, 36, 0.4);">
                        <%= top1.getXp() %> <span style="font-size: 0.9rem; color: var(--text-muted);">XP</span>
                    </div>
                    <div style="margin-top: 10px;">
                        <span class="level-chip" style="background: linear-gradient(135deg, #fbbf24, #d97706); color: #000; font-weight: 900;">LVL <%= top1.getLevel() %></span>
                        <span class="badge badge-solved" style="margin-left: 6px;">&#10004; <%= top1.getSolvedMissions() %> Cleared</span>
                    </div>
                </div>

                <!-- Rank #3 Bronze -->
                <% if (top3 != null) { %>
                    <div class="podium-card rank-3-card">
                        <span class="rank-badge rank-3" style="position: absolute; top: 12px; left: 12px;">#3</span>
                        <div class="podium-avatar bronze-border">&#129353;</div>
                        <h3 style="margin-bottom: 0.3rem;"><%= SecurityUtil.escapeHtml(top3.getUsername()) %></h3>
                        <div style="color: var(--accent-purple); font-weight: 700; font-size: 0.9rem; margin-bottom: 0.6rem;"><%= top3.getTierTitle() %></div>
                        <div style="font-family: var(--font-heading); font-size: 1.4rem; color: #f97316; font-weight: 800;">
                            <%= top3.getXp() %> <span style="font-size: 0.8rem; color: var(--text-muted);">XP</span>
                        </div>
                        <div style="margin-top: 8px;">
                            <span class="level-chip">LVL <%= top3.getLevel() %></span>
                        </div>
                    </div>
                <% } else { %>
                    <div></div>
                <% } %>
            </div>
        <% } %>

        <!-- Search Table Filter -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.2rem; flex-wrap: wrap; gap: 10px;">
            <div style="font-size: 1.1rem; font-family: var(--font-heading); font-weight: 700; color: #00f2fe;">
                Complete Standings Registry
            </div>
            <div style="position: relative;">
                <span style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: var(--text-muted);">🔍</span>
                <input type="text" id="coderSearch" placeholder="Find coder tag..." 
                       style="padding: 8px 14px 8px 34px; border-radius: 20px; font-size: 0.88rem; width: 220px;"
                       oninput="filterLeaderboard()">
            </div>
        </div>

        <% if (leaderboard == null || leaderboard.isEmpty()) { %>
            <div class="alert alert-info" style="text-align: center;">
                No rankings recorded yet. Complete your first mission to claim the summit!
            </div>
        <% } else { %>
            <div class="table-responsive">
                <table class="data-table" id="leaderboardTable">
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
                            <tr style="<%= (isMe ? "background-color: rgba(0, 242, 254, 0.1); border-left: 3px solid #00f2fe;" : "") %>" data-username="<%= SecurityUtil.escapeHtml(coder.getUsername().toLowerCase()) %>">
                                <td style="text-align: center;">
                                    <% if (rank == 1) { %>
                                        <span class="rank-badge rank-1">&#127941;</span>
                                    <% } else if (rank == 2) { %>
                                        <span class="rank-badge rank-2">&#129352;</span>
                                    <% } else if (rank == 3) { %>
                                        <span class="rank-badge rank-3">&#129353;</span>
                                    <% } else { %>
                                        <span style="font-family: var(--font-heading); font-weight: 800; color: var(--text-muted);">#<%= rank %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <strong style="color: <%= (isMe ? "#00f2fe" : "var(--text-main)") %>; font-size: 1.05rem;">
                                        <%= SecurityUtil.escapeHtml(coder.getUsername()) %>
                                    </strong>
                                    <% if (isMe) { %>
                                        <span class="badge badge-solved" style="margin-left: 8px; font-size: 0.72rem;">You</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span style="color: var(--accent-purple); font-weight: 700;">
                                        <%= coder.getTierTitle() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="level-chip">LVL <%= coder.getLevel() %></span>
                                </td>
                                <td>
                                    <span style="color: var(--accent-blue); font-weight: 700;">
                                        &#10004; <%= coder.getSolvedMissions() %>
                                    </span>
                                </td>
                                <td style="text-align: right;">
                                    <strong style="color: #00f2fe; font-family: var(--font-heading); font-size: 1.15rem;">
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
                <p style="color: var(--text-muted); margin-bottom: 1rem;">Ready to claim your place on the hall of champions?</p>
                <a href="register.jsp" class="btn-primary">&#9654; Enlist In The Grid</a>
            </div>
        <% } %>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; Hall of Champions
    </footer>

    <script>
        function filterLeaderboard() {
            const query = document.getElementById('coderSearch').value.toLowerCase().trim();
            const rows = document.querySelectorAll('#leaderboardTable tbody tr');
            rows.forEach(r => {
                const u = r.getAttribute('data-username') || '';
                r.style.display = (!query || u.includes(query)) ? '' : 'none';
            });
        }
    </script>
</body>
</html>
