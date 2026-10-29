package com.codequest.servlet;

import com.codequest.model.Mission;
import com.codequest.model.User;
import com.codequest.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp?msg=Session expired. Please log in.");
            return;
        }

        User sessionUser = (User) session.getAttribute("currentUser");
        int userId = sessionUser.getId();

        Connection conn = null;
        PreparedStatement pstUser = null;
        PreparedStatement pstRank = null;
        PreparedStatement pstTotalM = null;
        PreparedStatement pstSolvedM = null;
        PreparedStatement pstRecom = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 1. Refresh latest user stats
            String userSql = "SELECT id, username, email, password, xp, level FROM users WHERE id = ?";
            pstUser = conn.prepareStatement(userSql);
            pstUser.setInt(1, userId);
            rs = pstUser.executeQuery();
            if (rs.next()) {
                sessionUser.setUsername(rs.getString("username"));
                sessionUser.setEmail(rs.getString("email"));
                sessionUser.setXp(rs.getInt("xp"));
                sessionUser.setLevel(rs.getInt("level"));
            }
            rs.close();

            // 2. Compute Global Rank
            String rankSql = "SELECT COUNT(*) + 1 AS rank_pos FROM users WHERE xp > ?";
            pstRank = conn.prepareStatement(rankSql);
            pstRank.setInt(1, sessionUser.getXp());
            rs = pstRank.executeQuery();
            if (rs.next()) {
                sessionUser.setRank(rs.getInt("rank_pos"));
            }
            rs.close();

            // 3. Count total missions
            int totalMissions = 0;
            String totalSql = "SELECT COUNT(*) FROM missions";
            pstTotalM = conn.prepareStatement(totalSql);
            rs = pstTotalM.executeQuery();
            if (rs.next()) {
                totalMissions = rs.getInt(1);
            }
            rs.close();

            // 4. Count solved missions by this student
            int solvedMissions = 0;
            String solvedSql = "SELECT COUNT(*) FROM mission_submissions WHERE user_id = ? AND is_correct = TRUE";
            pstSolvedM = conn.prepareStatement(solvedSql);
            pstSolvedM.setInt(1, userId);
            rs = pstSolvedM.executeQuery();
            if (rs.next()) {
                solvedMissions = rs.getInt(1);
            }
            rs.close();
            sessionUser.setSolvedMissions(solvedMissions);

            // Update session user with enriched data
            session.setAttribute("currentUser", sessionUser);

            // 5. Featured / Recommended Missions (Unsolved by this user)
            List<Mission> recommendedMissions = new ArrayList<>();
            String recomSql = "SELECT m.id, m.title, m.description, m.category, m.difficulty, " +
                              "m.choice_a, m.choice_b, m.choice_c, m.choice_d, m.correct_answer, m.xp_reward " +
                              "FROM missions m " +
                              "WHERE m.id NOT IN (SELECT mission_id FROM mission_submissions WHERE user_id = ?) " +
                              "ORDER BY m.id ASC LIMIT 3";
            pstRecom = conn.prepareStatement(recomSql);
            pstRecom.setInt(1, userId);
            rs = pstRecom.executeQuery();
            while (rs.next()) {
                Mission m = new Mission(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("category"),
                    rs.getString("difficulty"),
                    rs.getString("choice_a"),
                    rs.getString("choice_b"),
                    rs.getString("choice_c"),
                    rs.getString("choice_d"),
                    rs.getString("correct_answer"),
                    rs.getInt("xp_reward")
                );
                m.setSolved(false);
                recommendedMissions.add(m);
            }

            request.setAttribute("totalMissions", totalMissions);
            request.setAttribute("solvedMissions", solvedMissions);
            request.setAttribute("recommendedMissions", recommendedMissions);

            request.getRequestDispatcher("dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading dashboard metrics: " + e.getMessage());
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        } finally {
            DBConnection.close(null, pstUser);
            DBConnection.close(null, pstRank);
            DBConnection.close(null, pstTotalM);
            DBConnection.close(null, pstSolvedM);
            DBConnection.close(conn, pstRecom, rs);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
