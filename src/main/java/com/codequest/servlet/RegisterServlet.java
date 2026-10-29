package com.codequest.servlet;

import com.codequest.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String user = request.getParameter("username");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");
        
        if (user == null || user.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            pass == null || pass.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required to join the Quest.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        user = user.trim();
        email = email.trim();

        Connection conn = null;
        PreparedStatement checkPst = null;
        PreparedStatement insertPst = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Check if username or email already exists
            String checkSql = "SELECT id FROM users WHERE username = ? OR email = ?";
            checkPst = conn.prepareStatement(checkSql);
            checkPst.setString(1, user);
            checkPst.setString(2, email);
            rs = checkPst.executeQuery();

            if (rs.next()) {
                request.setAttribute("errorMessage", "Username or Email is already registered in the grid.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // New students start with 0 XP and Level 1 by default
            String sql = "INSERT INTO users (username, email, password, xp, level) VALUES (?, ?, ?, 0, 1)";
            insertPst = conn.prepareStatement(sql);
            insertPst.setString(1, user);
            insertPst.setString(2, email);
            insertPst.setString(3, pass);
            
            int rows = insertPst.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("login.jsp?msg=Account Created! Login to begin your quest.");
            } else {
                request.setAttribute("errorMessage", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System Error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } finally {
            DBConnection.close(null, checkPst, rs);
            DBConnection.close(conn, insertPst, null);
        }
    }
}
