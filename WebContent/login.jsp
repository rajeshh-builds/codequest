<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.util.SecurityUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Access Portal</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .quick-fill-container {
            display: flex;
            gap: 8px;
            margin-top: 1.2rem;
            flex-wrap: wrap;
        }
        .quick-fill-btn {
            background: rgba(15, 23, 42, 0.8);
            border: 1px dashed rgba(255, 255, 255, 0.15);
            color: var(--text-muted);
            padding: 5px 12px;
            border-radius: 6px;
            font-size: 0.78rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .quick-fill-btn:hover {
            border-color: #00f2fe;
            color: #00f2fe;
            background: rgba(0, 242, 254, 0.08);
        }
        .password-toggle-wrapper {
            position: relative;
        }
        .password-toggle-wrapper input {
            padding-right: 45px;
        }
        .toggle-pwd-btn {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            font-size: 1rem;
            padding: 0;
            line-height: 1;
        }
        .toggle-pwd-btn:hover {
            color: #00f2fe;
        }
    </style>
</head>
<body>
    <div class="top-glow-bar"></div>

    <%
        String roleParam = request.getParameter("role");
        boolean isAdmin = "admin".equalsIgnoreCase(roleParam);
        String msg = request.getParameter("msg");
        String error = (String) request.getAttribute("errorMessage");
    %>

    <div class="navbar">
        <a href="index.html" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <a href="index.html">Home</a>
            <a href="LeaderboardServlet">&#127942; Leaderboard</a>
            <a href="register.jsp" class="btn-primary btn-sm">&#9654; Join Quest</a>
        </div>
    </div>
    
    <div class="container" style="max-width: 480px; margin-top: 3.5rem;">
        <div style="text-align: center; margin-bottom: 1.6rem;">
            <% if (isAdmin) { %>
                <div class="badge" style="background: rgba(168, 85, 247, 0.15); color: var(--accent-purple); border: 1px solid rgba(168, 85, 247, 0.35); margin-bottom: 0.8rem;">
                    &#9881; Platform Administration &#9881;
                </div>
                <h2 style="color: var(--accent-purple);">Overseer Terminal</h2>
                <p class="subtitle" style="margin-bottom: 0;">Authorized administrator credentials required</p>
            <% } else { %>
                <div class="badge badge-solved" style="margin-bottom: 0.8rem;">&#9670; Player Terminal &#9670;</div>
                <h2 style="color: #00f2fe;">Initiate Session</h2>
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
        
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="alert alert-danger">
                <span>&#9888;</span> <%= SecurityUtil.escapeHtml(error) %>
            </div>
        <% } %>

        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="alert alert-success">
                <span>&#10004;</span> <%= SecurityUtil.escapeHtml(msg) %>
            </div>
        <% } %>

        <form action="LoginServlet" method="post" id="loginForm">
            <input type="hidden" name="role" value="<%= (isAdmin ? "admin" : "student") %>">

            <div class="form-group">
                <label for="username"><%= (isAdmin ? "Admin Username" : "Gamer Tag or Neural Email") %></label>
                <input type="text" id="username" name="username" 
                       placeholder="<%= (isAdmin ? "Username: admin" : "Username or email") %>" 
                       required autocomplete="username">
            </div>
            
            <div class="form-group">
                <label for="password">Security Cipher (Passkey)</label>
                <div class="password-toggle-wrapper">
                    <input type="password" id="password" name="password" 
                           placeholder="<%= (isAdmin ? "Passkey: admin123" : "Your password") %>" 
                           required autocomplete="current-password">
                    <button type="button" class="toggle-pwd-btn" onclick="togglePasswordVisibility()" title="Show/Hide Password">
                        &#128065;
                    </button>
                </div>
            </div>
            
            <button type="submit" class="<%= (isAdmin ? "btn-secondary" : "btn-primary") %>" 
                    style="width: 100%; margin-top: 0.8rem; padding: 13px; <%= (isAdmin ? "border-color: var(--accent-purple); color: var(--accent-purple);" : "") %>">
                &#10148; Access <%= (isAdmin ? "Admin Console" : "The Grid") %>
            </button>
        </form>

        <!-- Fast Credentials Help -->
        <div style="margin-top: 1.5rem; padding-top: 1.2rem; border-top: 1px solid rgba(255, 255, 255, 0.08);">
            <div style="font-size: 0.8rem; color: var(--text-dim); text-transform: uppercase; font-family: var(--font-subheading); letter-spacing: 0.05em; margin-bottom: 6px;">
                Portal Access Helper:
            </div>
            <div class="quick-fill-container">
                <% if (!isAdmin) { %>
                    <button type="button" class="quick-fill-btn" onclick="fillCreds('rajesh', 'rajesh123')">
                        &#128100; rajesh (Dev)
                    </button>
                <% } else { %>
                    <button type="button" class="quick-fill-btn" onclick="fillCreds('admin', 'admin123')">
                        &#9881; Overseer Admin
                    </button>
                <% } %>
            </div>
        </div>

        <% if (!isAdmin) { %>
            <div style="text-align: center; margin-top: 1.6rem; font-size: 0.95rem; color: var(--text-muted);">
                New coder detected? 
                <a href="register.jsp" style="color: #00f2fe; text-decoration: none; font-weight: 700;">Enlist in CodeQuest &rarr;</a>
            </div>
        <% } %>
    </div>

    <footer>
        &copy; 2026 CodeQuest Gaming Platform &bull; All Rights Reserved
    </footer>

    <script>
        function fillCreds(u, p) {
            document.getElementById('username').value = u;
            document.getElementById('password').value = p;
        }

        function togglePasswordVisibility() {
            const pwdInput = document.getElementById('password');
            if (pwdInput.type === 'password') {
                pwdInput.type = 'text';
            } else {
                pwdInput.type = 'password';
            }
        }
    </script>
</body>
</html>
