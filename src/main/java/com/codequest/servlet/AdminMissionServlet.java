package com.codequest.servlet;

import com.codequest.model.Mission;
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

@WebServlet("/AdminMissionServlet")
public class AdminMissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("login.jsp?role=admin");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if ("edit".equalsIgnoreCase(action) && idParam != null && !idParam.trim().isEmpty()) {
            int missionId = Integer.parseInt(idParam);
            Connection conn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection();
                String sql = "SELECT id, title, description, category, difficulty, " +
                             "choice_a, choice_b, choice_c, choice_d, correct_answer, xp_reward " +
                             "FROM missions WHERE id = ?";
                pst = conn.prepareStatement(sql);
                pst.setInt(1, missionId);
                rs = pst.executeQuery();

                if (rs.next()) {
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
                    request.setAttribute("mission", mission);
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                DBConnection.close(conn, pst, rs);
            }
        }

        request.getRequestDispatcher("admin-mission-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("login.jsp?role=admin");
            return;
        }

        String idParam = request.getParameter("id");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String difficulty = request.getParameter("difficulty");
        String choiceA = request.getParameter("choice_a");
        String choiceB = request.getParameter("choice_b");
        String choiceC = request.getParameter("choice_c");
        String choiceD = request.getParameter("choice_d");
        String correctAnswer = request.getParameter("correct_answer");
        String xpParam = request.getParameter("xp_reward");

        int xpReward = 50;
        try {
            if (xpParam != null && !xpParam.trim().isEmpty()) {
                xpReward = Integer.parseInt(xpParam.trim());
            }
        } catch (NumberFormatException ignored) {}

        Connection conn = null;
        PreparedStatement pst = null;

        try {
            conn = DBConnection.getConnection();

            if (idParam != null && !idParam.trim().isEmpty()) {
                // Update existing mission
                int missionId = Integer.parseInt(idParam);
                String sql = "UPDATE missions SET title = ?, description = ?, category = ?, difficulty = ?, " +
                             "choice_a = ?, choice_b = ?, choice_c = ?, choice_d = ?, correct_answer = ?, xp_reward = ? " +
                             "WHERE id = ?";
                pst = conn.prepareStatement(sql);
                pst.setString(1, title);
                pst.setString(2, description);
                pst.setString(3, category);
                pst.setString(4, difficulty);
                pst.setString(5, choiceA);
                pst.setString(6, choiceB);
                pst.setString(7, choiceC);
                pst.setString(8, choiceD);
                pst.setString(9, correctAnswer);
                pst.setInt(10, xpReward);
                pst.setInt(11, missionId);
                pst.executeUpdate();

                response.sendRedirect("AdminDashboardServlet?msg=Mission updated successfully!");
            } else {
                // Insert new mission
                String sql = "INSERT INTO missions (title, description, category, difficulty, " +
                             "choice_a, choice_b, choice_c, choice_d, correct_answer, xp_reward) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                pst = conn.prepareStatement(sql);
                pst.setString(1, title);
                pst.setString(2, description);
                pst.setString(3, category);
                pst.setString(4, difficulty);
                pst.setString(5, choiceA);
                pst.setString(6, choiceB);
                pst.setString(7, choiceC);
                pst.setString(8, choiceD);
                pst.setString(9, correctAnswer);
                pst.setInt(10, xpReward);
                pst.executeUpdate();

                response.sendRedirect("AdminDashboardServlet?msg=New Quest mission forged successfully!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error saving mission: " + e.getMessage());
            request.getRequestDispatcher("admin-mission-form.jsp").forward(request, response);
        } finally {
            DBConnection.close(conn, pst);
        }
    }
}
