package com.codequest.servlet;

import com.codequest.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminDeleteMissionServlet")
public class AdminDeleteMissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("login.jsp?role=admin");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pst = null;

            try {
                conn = DBConnection.getConnection();
                String sql = "DELETE FROM missions WHERE id = ?";
                pst = conn.prepareStatement(sql);
                pst.setInt(1, Integer.parseInt(idParam));
                pst.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                DBConnection.close(conn, pst);
            }
        }

        response.sendRedirect("AdminDashboardServlet?msg=Mission has been purged.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
