package com.codequest.servlet;

import com.codequest.model.Submission;
import com.codequest.model.User;
import com.codequest.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp?msg=Please log in to view profile.");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int userId = currentUser.getId();

        Connection conn = null;
        PreparedStatement pstUser = null;
        PreparedStatement pstHistory = null;
        ResultSet rs = null;

        List<Submission> history = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();

            // Refresh user details
            String uSql = "SELECT id, username, email, password, xp, level FROM users WHERE id = ?";
            pstUser = conn.prepareStatement(uSql);
            pstUser.setInt(1, userId);
            rs = pstUser.executeQuery();
            if (rs.next()) {
                currentUser.setUsername(rs.getString("username"));
                currentUser.setEmail(rs.getString("email"));
                currentUser.setXp(rs.getInt("xp"));
                currentUser.setLevel(rs.getInt("level"));
            }
            rs.close();

            // Fetch submission history with mission details
            String histSql = "SELECT s.id, s.user_id, s.mission_id, s.is_correct, s.submitted_at, " +
                             "m.title, m.category, m.xp_reward " +
                             "FROM mission_submissions s " +
                             "JOIN missions m ON s.mission_id = m.id " +
                             "WHERE s.user_id = ? " +
                             "ORDER BY s.submitted_at DESC";
            pstHistory = conn.prepareStatement(histSql);
            pstHistory.setInt(1, userId);
            rs = pstHistory.executeQuery();

            while (rs.next()) {
                Submission sub = new Submission(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getInt("mission_id"),
                    rs.getBoolean("is_correct"),
                    rs.getTimestamp("submitted_at")
                );
                sub.setMissionTitle(rs.getString("title"));
                sub.setCategory(rs.getString("category"));
                sub.setXpReward(rs.getInt("xp_reward"));
                history.add(sub);
            }

            currentUser.setSolvedMissions(history.size());
            session.setAttribute("currentUser", currentUser);

            request.setAttribute("submissionHistory", history);
            request.getRequestDispatcher("profile.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading profile data: " + e.getMessage());
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        } finally {
            DBConnection.close(null, pstUser);
            DBConnection.close(conn, pstHistory, rs);
        }
    }
}
