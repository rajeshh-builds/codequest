package com.codequest.servlet;

import com.codequest.model.Mission;
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

public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("login.jsp?role=admin&msg=Admin access required.");
            return;
        }

        Connection conn = null;
        PreparedStatement pstUsers = null;
        PreparedStatement pstMissions = null;
        PreparedStatement pstSubs = null;
        PreparedStatement pstList = null;
        ResultSet rs = null;

        List<Mission> allMissions = new ArrayList<>();
        int totalUsers = 0;
        int totalMissions = 0;
        int totalSubmissions = 0;

        try {
            conn = DBConnection.getConnection();

            // Total students
            pstUsers = conn.prepareStatement("SELECT COUNT(*) FROM users");
            rs = pstUsers.executeQuery();
            if (rs.next()) totalUsers = rs.getInt(1);
            rs.close();

            // Total missions
            pstMissions = conn.prepareStatement("SELECT COUNT(*) FROM missions");
            rs = pstMissions.executeQuery();
            if (rs.next()) totalMissions = rs.getInt(1);
            rs.close();

            // Total submissions
            pstSubs = conn.prepareStatement("SELECT COUNT(*) FROM mission_submissions");
            rs = pstSubs.executeQuery();
            if (rs.next()) totalSubmissions = rs.getInt(1);
            rs.close();

            // All missions list
            String listSql = "SELECT id, title, description, category, difficulty, " +
                             "choice_a, choice_b, choice_c, choice_d, correct_answer, xp_reward " +
                             "FROM missions ORDER BY id DESC";
            pstList = conn.prepareStatement(listSql);
            rs = pstList.executeQuery();

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
                allMissions.add(m);
            }

            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalMissions", totalMissions);
            request.setAttribute("totalSubmissions", totalSubmissions);
            request.setAttribute("missionsList", allMissions);

            request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading admin console: " + e.getMessage());
            request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);
        } finally {
            DBConnection.close(null, pstUsers);
            DBConnection.close(null, pstMissions);
            DBConnection.close(null, pstSubs);
            DBConnection.close(conn, pstList, rs);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
