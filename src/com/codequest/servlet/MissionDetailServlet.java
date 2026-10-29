package com.codequest.servlet;

import com.codequest.model.Mission;
import com.codequest.model.User;
import com.codequest.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class MissionDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp?msg=Please log in to play missions.");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("MissionsServlet");
            return;
        }

        int missionId;
        try {
            missionId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("MissionsServlet");
            return;
        }

        Connection conn = null;
        PreparedStatement pst = null;
        PreparedStatement solPst = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT id, title, description, category, difficulty, " +
                         "choice_a, choice_b, choice_c, choice_d, correct_answer, xp_reward " +
                         "FROM missions WHERE id = ?";
            pst = conn.prepareStatement(sql);
            pst.setInt(1, missionId);
            rs = pst.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("MissionsServlet?msg=Mission Not Found");
                return;
            }

            Mission mission = new Mission(
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
            rs.close();

            // Check if solved
            String solSql = "SELECT id FROM mission_submissions WHERE user_id = ? AND mission_id = ?";
            solPst = conn.prepareStatement(solSql);
            solPst.setInt(1, currentUser.getId());
            solPst.setInt(2, missionId);
            rs = solPst.executeQuery();
            mission.setSolved(rs.next());

            request.setAttribute("mission", mission);
            request.getRequestDispatcher("mission-view.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("MissionsServlet?error=" + e.getMessage());
        } finally {
            DBConnection.close(null, solPst, null);
            DBConnection.close(conn, pst, rs);
        }
    }
}
