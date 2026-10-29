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
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class MissionsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp?msg=Please log in to view missions.");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int userId = currentUser.getId();

        String selectedCategory = request.getParameter("category");
        String selectedDifficulty = request.getParameter("difficulty");

        Connection conn = null;
        PreparedStatement pst = null;
        PreparedStatement catPst = null;
        ResultSet rs = null;

        List<Mission> missions = new ArrayList<>();
        List<String> categories = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();

            // 1. Fetch distinct categories
            String catSql = "SELECT DISTINCT category FROM missions ORDER BY category ASC";
            catPst = conn.prepareStatement(catSql);
            rs = catPst.executeQuery();
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
            rs.close();

            // 2. Build filtered missions query
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT m.id, m.title, m.description, m.category, m.difficulty, ")
               .append("m.choice_a, m.choice_b, m.choice_c, m.choice_d, m.correct_answer, m.xp_reward, ")
               .append("CASE WHEN s.id IS NOT NULL THEN TRUE ELSE FALSE END AS is_solved ")
               .append("FROM missions m ")
               .append("LEFT JOIN mission_submissions s ON m.id = s.mission_id AND s.user_id = ? ")
               .append("WHERE 1=1 ");

            List<Object> params = new ArrayList<>();
            params.add(userId);

            if (selectedCategory != null && !selectedCategory.trim().isEmpty() && !"all".equalsIgnoreCase(selectedCategory)) {
                sql.append("AND m.category = ? ");
                params.add(selectedCategory.trim());
            }

            if (selectedDifficulty != null && !selectedDifficulty.trim().isEmpty() && !"all".equalsIgnoreCase(selectedDifficulty)) {
                sql.append("AND m.difficulty = ? ");
                params.add(selectedDifficulty.trim());
            }

            sql.append("ORDER BY m.id ASC");

            pst = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pst.setObject(i + 1, params.get(i));
            }

            rs = pst.executeQuery();
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
                m.setSolved(rs.getBoolean("is_solved"));
                missions.add(m);
            }

            request.setAttribute("missionsList", missions);
            request.setAttribute("categoryList", categories);
            request.setAttribute("currentCategory", selectedCategory != null ? selectedCategory : "all");
            request.setAttribute("currentDifficulty", selectedDifficulty != null ? selectedDifficulty : "all");

            request.getRequestDispatcher("missions.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Unable to load mission grid: " + e.getMessage());
            request.getRequestDispatcher("missions.jsp").forward(request, response);
        } finally {
            DBConnection.close(null, catPst, null);
            DBConnection.close(conn, pst, rs);
        }
    }
}
