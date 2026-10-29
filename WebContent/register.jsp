<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.util.SecurityUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeQuest - Register Operative</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
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

    <div class="navbar">
        <a href="index.html" class="brand-logo">
            <div class="brand-icon">&lt;&gt;</div>
            <div class="brand-text">CODE<span>QUEST</span></div>
        </a>
        <div class="nav-links">
            <a href="index.html">Home</a>
            <a href="LeaderboardServlet">&#127942; Leaderboard</a>
            <a href="login.jsp" class="btn-secondary btn-sm">Sign In</a>
        </div>
    </div>
    
    <div class="container" style="max-width: 480px; margin-top: 3.5rem;">
        <div style="text-align: center; margin-bottom: 1.8rem;">
            <div class="badge badge-solved" style="margin-bottom: 0.8rem;">&#9670; Player Enlistment &#9670;</div>
            <h2 style="color: #00f2fe;">Join the Quest</h2>
            <p class="subtitle" style="margin-bottom: 0;">Forge your gamer identity and enter the coding arena</p>
        </div>
        
        <% 
            String error = (String) request.getAttribute("errorMessage");
            if (error != null && !error.trim().isEmpty()) { 
        %>
            <div class="alert alert-danger">
                <span>&#9888;</span> <%= SecurityUtil.escapeHtml(error) %>
            </div>
        <% } %>

        <form action="RegisterServlet" method="post">
            <div class="form-group">
                <label for="username">Gamer Tag (Username)</label>
                <input type="text" id="username" name="username" placeholder="e.g. CyberSamurai" required autocomplete="username">
            </div>
            
            <div class="form-group">
                <label for="email">Coder Neural ID (Email)</label>
                <input type="email" id="email" name="email" placeholder="name@domain.com" required autocomplete="email">
            </div>
            
            <div class="form-group">
                <label for="password">Security Cipher (Password)</label>
                <div class="password-toggle-wrapper">
                    <input type="password" id="password" name="password" placeholder="Choose a strong passkey" required autocomplete="new-password">
                    <button type="button" class="toggle-pwd-btn" onclick="togglePasswordVisibility()" title="Show/Hide Password">
                        &#128065;
                    </button>
                </div>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 0.8rem; padding: 13px;">
                &#9889; Create Player Profile
            </button>
        </form>

        <div style="text-align: center; margin-top: 1.8rem; font-size: 0.95rem; color: var(--text-muted);">
            Already have an active identity? 
            <a href="login.jsp" style="color: #00f2fe; text-decoration: none; font-weight: 700;">Login Here &rarr;</a>
        </div>
    </div>

    <footer>
        &copy; 2026 CodeQuest Gaming Platform &bull; All Rights Reserved
    </footer>

    <script>
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
