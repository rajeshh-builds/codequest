package com.codequest.servlet;

import com.codequest.model.Admin;
import com.codequest.model.User;
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
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String identifier = request.getParameter("username"); // username or email
        String pass = request.getParameter("password");
        String role = request.getParameter("role"); // "student" or "admin"

        if (role == null || role.trim().isEmpty()) {
            role = "student";
        }

        if (identifier == null || identifier.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Credentials cannot be blank.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        identifier = identifier.trim();

        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            if ("admin".equalsIgnoreCase(role)) {
                // Admin authentication
                String sql = "SELECT id, username, password, full_name FROM admins WHERE username = ? AND password = ?";
                pst = conn.prepareStatement(sql);
                pst.setString(1, identifier);
                pst.setString(2, pass);
                rs = pst.executeQuery();

                if (rs.next()) {
                    Admin admin = new Admin(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("full_name")
                    );

                    HttpSession session = request.getSession(true);
                    session.removeAttribute("currentUser"); // clean student session
                    session.setAttribute("adminUser", admin);
                    session.setAttribute("userRole", "admin");

                    response.sendRedirect("AdminDashboardServlet");
                    return;
                } else {
                    request.setAttribute("errorMessage", "Invalid Admin credentials. Access Denied.");
                    request.getRequestDispatcher("login.jsp?role=admin").forward(request, response);
                    return;
                }
            } else {
                // Student authentication (allows username OR email)
                String sql = "SELECT id, username, email, password, xp, level FROM users WHERE (username = ? OR email = ?) AND password = ?";
                pst = conn.prepareStatement(sql);
                pst.setString(1, identifier);
                pst.setString(2, identifier);
                pst.setString(3, pass);
                rs = pst.executeQuery();

                if (rs.next()) {
                    User user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getInt("xp"),
                        rs.getInt("level")
                    );

                    HttpSession session = request.getSession(true);
                    session.removeAttribute("adminUser"); // clean admin session
                    session.setAttribute("currentUser", user);
                    session.setAttribute("userRole", "student");

                    response.sendRedirect("DashboardServlet");
                    return;
                } else {
                    request.setAttribute("errorMessage", "Invalid username or password. Check your cipher.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database Connection Error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            DBConnection.close(conn, pst, rs);
        }
    }
}
