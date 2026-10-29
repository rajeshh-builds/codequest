<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Challenge Arena</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .timer-badge {
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid rgba(251, 191, 36, 0.3);
            color: #fbbf24;
            padding: 5px 14px;
            border-radius: 20px;
            font-family: var(--font-mono);
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 0 12px rgba(251, 191, 36, 0.15);
        }
        .hotkey-hint {
            font-size: 0.75rem;
            color: var(--text-dim);
            font-family: var(--font-mono);
            margin-left: auto;
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 2px 6px;
            border-radius: 4px;
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

        Mission mission = (Mission) request.getAttribute("mission");
        if (mission == null) {
            response.sendRedirect("MissionsServlet");
            return;
        }

        String result = request.getParameter("result");
        String xpParam = request.getParameter("xp");
        String leveledUp = request.getParameter("leveledUp");
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
        <!-- Breadcrumbs & Header -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.8rem; flex-wrap: wrap; gap: 12px;">
            <div>
                <a href="MissionsServlet" style="color: #00f2fe; text-decoration: none; font-size: 0.9rem; font-weight: 700; display: inline-flex; align-items: center; gap: 6px;">
                    &larr; Back to Mission Board
                </a>
                <h1 style="margin-top: 8px; margin-bottom: 0;"><%= SecurityUtil.escapeHtml(mission.getTitle()) %></h1>
            </div>
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                <div class="timer-badge">
                    <span>&#9201;</span> <span id="arenaTimer">00:00</span>
                </div>
                <% 
                    String diff = mission.getDifficulty();
                    String badgeClass = "badge-easy";
                    if ("Medium".equalsIgnoreCase(diff)) badgeClass = "badge-medium";
                    else if ("Hard".equalsIgnoreCase(diff)) badgeClass = "badge-hard";
                %>
                <span class="badge <%= badgeClass %>" style="font-size: 0.85rem; padding: 6px 14px;"><%= diff %></span>
                <span class="badge badge-solved" style="font-size: 0.85rem; padding: 6px 14px;">
                    +<%= mission.getXpReward() %> XP Bounty
                </span>
            </div>
        </div>

        <!-- Feedback Notifications -->
        <% if ("correct".equalsIgnoreCase(result)) { %>
            <div class="alert alert-success" id="successBanner">
                <span style="font-size: 1.5rem;">&#127881;</span>
                <div>
                    <strong style="color: #6ee7b7; font-size: 1.05rem;">Access Granted! Mission Cleared!</strong><br>
                    You harvested <strong style="color: #fff;">+<%= SecurityUtil.escapeHtml(xpParam != null ? xpParam : String.valueOf(mission.getXpReward())) %> XP</strong>.
                    <% if ("true".equalsIgnoreCase(leveledUp)) { %>
                        <span style="color: #fbbf24; font-weight: 800; margin-left: 8px;">
                            &#9889; LEVEL UP! Promoted to Level <%= user.getLevel() %> (<%= user.getTierTitle() %>)!
                        </span>
                    <% } %>
                </div>
            </div>
        <% } else if ("incorrect".equalsIgnoreCase(result)) { %>
            <div class="alert alert-danger">
                <span style="font-size: 1.4rem;">&#9888;</span>
                <div>
                    <strong style="color: #fca5a5; font-size: 1.05rem;">Verification Failed!</strong> Incorrect answer cipher. Re-examine the problem specification below and retry.
                </div>
            </div>
        <% } else if ("already_solved".equalsIgnoreCase(result)) { %>
            <div class="alert alert-info">
                <span style="font-size: 1.4rem;">&#8505;</span>
                <div>
                    <strong>Record Verified.</strong> You have already conquered this challenge previously. Duplicate submissions do not grant additional XP.
                </div>
            </div>
        <% } %>

        <% if (mission.isSolved() && result == null) { %>
            <div class="alert alert-success">
                <span>&#10004;</span>
                <div>
                    <strong>Mission Record: Solved!</strong> You have solved this challenge and collected its XP.
                </div>
            </div>
        <% } %>

        <!-- Arena Terminal & Submission Form -->
        <div class="arena-container">
            <!-- Left Pane: Problem Terminal -->
            <div class="terminal-box">
                <div class="terminal-header">
                    <span class="terminal-dot dot-red"></span>
                    <span class="terminal-dot dot-yellow"></span>
                    <span class="terminal-dot dot-green"></span>
                    <span class="terminal-title">mission_runner.sh &bull; Domain: [<%= SecurityUtil.escapeHtml(mission.getCategory()) %>]</span>
                </div>
                <div class="terminal-content">// ===================================================
// CODEQUEST MISSION RUNNER &bull; ID #<%= mission.getId() %>
// SPEC: <%= SecurityUtil.escapeHtml(mission.getTitle()) %>
// THREAT LEVEL: <%= mission.getDifficulty() %> &bull; XP REWARD: +<%= mission.getXpReward() %> XP
// ===================================================

<%= SecurityUtil.escapeHtml(mission.getDescription()) %>

---------------------------------------------------
Awaiting operative selection...
Select Option A, B, C, or D using mouse or keyboard hotkeys.</div>
            </div>

            <!-- Right Pane: Submission Form -->
            <div style="background: rgba(10, 16, 30, 0.9); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 14px; padding: 2rem; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 10px 30px rgba(0,0,0,0.4);">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                        <h3 style="color: #00f2fe; margin-bottom: 0;">Select Accurate Cipher</h3>
                        <span style="font-size: 0.8rem; color: var(--text-muted); font-family: var(--font-mono);">Press [A/B/C/D]</span>
                    </div>
                    <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">
                        Choose the matching resolution and transmit to the verification engine:
                    </p>

                    <form action="SubmitMissionServlet" method="post" id="missionForm">
                        <input type="hidden" name="mission_id" value="<%= mission.getId() %>">

                        <div class="choices-container">
                            <label class="choice-label" id="labelA" onclick="highlightChoice(this)">
                                <input type="radio" id="choiceA" name="selected_choice" value="<%= SecurityUtil.escapeHtml(mission.getChoiceA()) %>" required>
                                <span class="choice-key">A</span>
                                <span class="choice-text"><%= SecurityUtil.escapeHtml(mission.getChoiceA()) %></span>
                                <span class="hotkey-hint">[A]</span>
                            </label>

                            <label class="choice-label" id="labelB" onclick="highlightChoice(this)">
                                <input type="radio" id="choiceB" name="selected_choice" value="<%= SecurityUtil.escapeHtml(mission.getChoiceB()) %>">
                                <span class="choice-key">B</span>
                                <span class="choice-text"><%= SecurityUtil.escapeHtml(mission.getChoiceB()) %></span>
                                <span class="hotkey-hint">[B]</span>
                            </label>

                            <label class="choice-label" id="labelC" onclick="highlightChoice(this)">
                                <input type="radio" id="choiceC" name="selected_choice" value="<%= SecurityUtil.escapeHtml(mission.getChoiceC()) %>">
                                <span class="choice-key">C</span>
                                <span class="choice-text"><%= SecurityUtil.escapeHtml(mission.getChoiceC()) %></span>
                                <span class="hotkey-hint">[C]</span>
                            </label>

                            <label class="choice-label" id="labelD" onclick="highlightChoice(this)">
                                <input type="radio" id="choiceD" name="selected_choice" value="<%= SecurityUtil.escapeHtml(mission.getChoiceD()) %>">
                                <span class="choice-key">D</span>
                                <span class="choice-text"><%= SecurityUtil.escapeHtml(mission.getChoiceD()) %></span>
                                <span class="hotkey-hint">[D]</span>
                            </label>
                        </div>

                        <div style="margin-top: 2rem;">
                            <button type="submit" class="btn-primary" style="width: 100%; padding: 14px; font-size: 0.95rem;">
                                &#9654; Deploy Verification Cipher
                            </button>
                        </div>
                    </form>
                </div>

                <div style="margin-top: 1.6rem; text-align: center; border-top: 1px solid rgba(255, 255, 255, 0.08); padding-top: 1.2rem;">
                    <a href="MissionsServlet" style="color: var(--text-muted); text-decoration: none; font-size: 0.9rem; font-weight: 600;">
                        &larr; Return to Missions List
                    </a>
                </div>
            </div>
        </div>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; Challenge Arena
    </footer>

    <script>
        // Keyboard hotkeys [A], [B], [C], [D]
        document.addEventListener('keydown', function(e) {
            const tag = e.target.tagName.toLowerCase();
            if (tag === 'input' || tag === 'textarea') return;
            const key = e.key.toUpperCase();
            if (key === 'A') selectKey('choiceA', 'labelA');
            else if (key === 'B') selectKey('choiceB', 'labelB');
            else if (key === 'C') selectKey('choiceC', 'labelC');
            else if (key === 'D') selectKey('choiceD', 'labelD');
        });

        function selectKey(inputId, labelId) {
            const input = document.getElementById(inputId);
            const label = document.getElementById(labelId);
            if (input && label) {
                input.checked = true;
                highlightChoice(label);
            }
        }

        function highlightChoice(selectedLabel) {
            document.querySelectorAll('.choice-label').forEach(lbl => lbl.classList.remove('selected'));
            selectedLabel.classList.add('selected');
        }

        // Live Tactical Stopwatch
        (function() {
            let seconds = 0;
            const timerElem = document.getElementById('arenaTimer');
            setInterval(() => {
                seconds++;
                const mins = String(Math.floor(seconds / 60)).padStart(2, '0');
                const secs = String(seconds % 60).padStart(2, '0');
                if (timerElem) timerElem.textContent = mins + ':' + secs;
            }, 1000);
        })();
    </script>
</body>
</html>
