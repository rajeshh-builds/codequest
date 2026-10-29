package com.codequest.servlet;

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

public class LeaderboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        List<User> leaderboard = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT u.id, u.username, u.email, u.password, u.xp, u.level, " +
                         "COUNT(s.id) AS solved_count " +
                         "FROM users u " +
                         "LEFT JOIN mission_submissions s ON u.id = s.user_id AND s.is_correct = TRUE " +
                         "GROUP BY u.id, u.username, u.email, u.password, u.xp, u.level " +
                         "ORDER BY u.xp DESC, u.level DESC, u.id ASC " +
                         "LIMIT 50";

            pst = conn.prepareStatement(sql);
            rs = pst.executeQuery();

            int rank = 1;
            while (rs.next()) {
                User u = new User(
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("email"),
                    rs.getString("password"),
                    rs.getInt("xp"),
                    rs.getInt("level")
                );
                u.setRank(rank++);
                u.setSolvedMissions(rs.getInt("solved_count"));
                leaderboard.add(u);
            }

            request.setAttribute("leaderboardList", leaderboard);
            request.getRequestDispatcher("leaderboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Unable to load leaderboard data: " + e.getMessage());
            request.getRequestDispatcher("leaderboard.jsp").forward(request, response);
        } finally {
            DBConnection.close(conn, pst, rs);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
