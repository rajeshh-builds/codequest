<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Access Portal</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .role-switch {
            display: flex;
            background: var(--bg-darker);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 4px;
            margin-bottom: 1.5rem;
        }
        .role-btn {
            flex: 1;
            padding: 10px;
            text-align: center;
            border-radius: 6px;
            font-family: var(--font-heading);
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--text-muted);
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .role-btn.active {
            background: var(--surface);
            color: var(--primary-neon);
            box-shadow: 0 0 10px rgba(45, 212, 191, 0.2);
            border: 1px solid var(--border-bright);
        }
        .role-btn.active-admin {
            background: var(--surface);
            color: var(--accent-purple);
            box-shadow: 0 0 10px rgba(168, 85, 247, 0.2);
            border: 1px solid var(--border-bright);
        }
    </style>
</head>
<body>
    <%
        String roleParam = request.getParameter("role");
        boolean isAdmin = "admin".equalsIgnoreCase(roleParam);
    %>

    <div class="navbar">
        <a href="index.html" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <a href="index.html">Home</a>
            <a href="LeaderboardServlet">Leaderboard</a>
            <a href="register.jsp" class="btn-primary btn-sm">Join Quest</a>
        </div>
    </div>
    
    <div class="container" style="max-width: 480px; margin-top: 3.5rem;">
        <div style="text-align: center; margin-bottom: 1.5rem;">
            <% if (isAdmin) { %>
                <div class="badge" style="background: rgba(168, 85, 247, 0.15); color: var(--accent-purple); border: 1px solid rgba(168, 85, 247, 0.3); margin-bottom: 0.8rem;">
                    &#9881; Platform Administration &#9881;
                </div>
                <h2 style="color: var(--accent-purple);">Overseer Terminal</h2>
                <p class="subtitle" style="margin-bottom: 0;">Authorized administrator credentials required</p>
            <% } else { %>
                <div class="badge badge-solved" style="margin-bottom: 0.8rem;">&#9670; Player Terminal &#9670;</div>
                <h2 style="color: var(--primary-neon);">Initiate Session</h2>
                <p class="subtitle" style="margin-bottom: 0;">Authenticate your player identity to resume quest</p>
            <% } %>
        </div>

        <div class="role-switch">
            <a href="login.jsp" class="role-btn <%= (!isAdmin ? "active" : "") %>">
                &#9654; Student Coder
            </a>
            <a href="login.jsp?role=admin" class="role-btn <%= (isAdmin ? "active-admin" : "") %>">
                &#9881; Quest Overseer
            </a>
        </div>
        
        <% 
            String error = (String) request.getAttribute("errorMessage");
            if (error != null && !error.trim().isEmpty()) { 
        %>
            <div class="alert alert-danger">
                <span>&#9888;</span> <%= error %>
            </div>
        <% } %>

        <% 
            String msg = request.getParameter("msg");
            if (msg != null && !msg.trim().isEmpty()) { 
        %>
            <div class="alert alert-success">
                <span>&#10004;</span> <%= msg %>
            </div>
        <% } %>

        <form action="LoginServlet" method="post">
            <input type="hidden" name="role" value="<%= (isAdmin ? "admin" : "student") %>">

            <div class="form-group">
                <label for="username"><%= (isAdmin ? "Admin Username" : "Gamer Tag or Email") %></label>
                <input type="text" id="username" name="username" 
                       placeholder="<%= (isAdmin ? "Default: admin" : "Username or email") %>" 
                       required autocomplete="username">
            </div>
            
            <div class="form-group">
                <label for="password">Passkey</label>
                <input type="password" id="password" name="password" 
                       placeholder="<%= (isAdmin ? "Default: admin123" : "Your password") %>" 
                       required autocomplete="current-password">
            </div>
            
            <button type="submit" class="<%= (isAdmin ? "btn-secondary" : "btn-primary") %>" 
                    style="width: 100%; margin-top: 0.5rem; <%= (isAdmin ? "border-color: var(--accent-purple); color: var(--accent-purple);" : "") %>">
                &#10148; Access <%= (isAdmin ? "Admin Console" : "The Grid") %>
            </button>
        </form>

        <% if (!isAdmin) { %>
            <div style="text-align: center; margin-top: 1.8rem; font-size: 0.95rem; color: var(--text-muted);">
                New coder detected? 
                <a href="register.jsp" style="color: var(--primary-neon); text-decoration: none; font-weight: 700;">Enlist in CodeQuest &rarr;</a>
            </div>
        <% } %>
    </div>

    <footer>
        &copy; 2026 CodeQuest Platform &bull; All Rights Reserved
    </footer>
</body>
</html>
