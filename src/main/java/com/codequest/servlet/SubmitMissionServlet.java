package com.codequest.servlet;

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

@WebServlet("/SubmitMissionServlet")
public class SubmitMissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int userId = currentUser.getId();

        String missionIdParam = request.getParameter("mission_id");
        String selectedChoice = request.getParameter("selected_choice");

        if (missionIdParam == null || selectedChoice == null || selectedChoice.trim().isEmpty()) {
            response.sendRedirect("MissionsServlet?error=Invalid submission data");
            return;
        }

        int missionId = Integer.parseInt(missionIdParam);
        selectedChoice = selectedChoice.trim();

        Connection conn = null;
        PreparedStatement pstMission = null;
        PreparedStatement pstCheckSub = null;
        PreparedStatement pstInsertSub = null;
        PreparedStatement pstUpdateUser = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 1. Fetch correct answer and XP reward
            String missionSql = "SELECT correct_answer, xp_reward FROM missions WHERE id = ?";
            pstMission = conn.prepareStatement(missionSql);
            pstMission.setInt(1, missionId);
            rs = pstMission.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("MissionsServlet?error=Mission not found");
                return;
            }

            String correctAnswer = rs.getString("correct_answer");
            int xpReward = rs.getInt("xp_reward");
            rs.close();

            // 2. Validate student answer
            boolean isCorrect = selectedChoice.equalsIgnoreCase(correctAnswer.trim());

            if (!isCorrect) {
                // Wrong answer - allow retry
                response.sendRedirect("MissionDetailServlet?id=" + missionId + "&result=incorrect");
                return;
            }

            // 3. Check if already solved to prevent duplicate XP exploitation
            String checkSubSql = "SELECT id FROM mission_submissions WHERE user_id = ? AND mission_id = ?";
            pstCheckSub = conn.prepareStatement(checkSubSql);
            pstCheckSub.setInt(1, userId);
            pstCheckSub.setInt(2, missionId);
            rs = pstCheckSub.executeQuery();

            if (rs.next()) {
                // Already completed
                response.sendRedirect("MissionDetailServlet?id=" + missionId + "&result=already_solved");
                return;
            }
            rs.close();

            // 4. Record new successful submission
            String insertSubSql = "INSERT INTO mission_submissions (user_id, mission_id, is_correct) VALUES (?, ?, TRUE)";
            pstInsertSub = conn.prepareStatement(insertSubSql);
            pstInsertSub.setInt(1, userId);
            pstInsertSub.setInt(2, missionId);
            pstInsertSub.executeUpdate();

            // 5. Update User XP & calculate Level
            int currentXp = currentUser.getXp();
            int oldLevel = currentUser.getLevel();

            int newXp = currentXp + xpReward;
            int newLevel = (newXp / 100) + 1; // 100 XP per level
            boolean leveledUp = (newLevel > oldLevel);

            String updateUserSql = "UPDATE users SET xp = ?, level = ? WHERE id = ?";
            pstUpdateUser = conn.prepareStatement(updateUserSql);
            pstUpdateUser.setInt(1, newXp);
            pstUpdateUser.setInt(2, newLevel);
            pstUpdateUser.setInt(3, userId);
            pstUpdateUser.executeUpdate();

            // Update user in session
            currentUser.setXp(newXp);
            currentUser.setLevel(newLevel);
            session.setAttribute("currentUser", currentUser);

            response.sendRedirect("MissionDetailServlet?id=" + missionId + "&result=correct&xp=" + xpReward + "&leveledUp=" + leveledUp);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("MissionDetailServlet?id=" + missionId + "&error=" + e.getMessage());
        } finally {
            DBConnection.close(null, pstMission);
            DBConnection.close(null, pstCheckSub);
            DBConnection.close(null, pstInsertSub);
            DBConnection.close(conn, pstUpdateUser, rs);
        }
    }
}
