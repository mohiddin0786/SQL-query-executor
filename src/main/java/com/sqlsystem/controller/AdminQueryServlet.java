package com.sqlsystem.controller;

import com.sqlsystem.database.DatabaseConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

public class AdminQueryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Role check
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendError(403);
            return;
        }

        String table = request.getParameter("table");

        // Whitelist only allowed tables
        if (!table.equals("Students") && 
            !table.equals("Enrollments") && 
            !table.equals("Courses")) {
            response.sendError(400, "Invalid table");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Connection conn = DatabaseConnection.getConnection();
            ResultSet rs = conn.createStatement()
                .executeQuery("SELECT * FROM " + table);
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();

            StringBuilder json = new StringBuilder();
            json.append("{\"columns\":[");

            // Column names
            for (int i = 1; i <= cols; i++) {
                json.append("\"").append(meta.getColumnName(i)).append("\"");
                if (i < cols) json.append(",");
            }
            json.append("],\"rows\":[");

            // Rows
            boolean firstRow = true;
            while (rs.next()) {
                if (!firstRow) json.append(",");
                json.append("[");
                for (int i = 1; i <= cols; i++) {
                    String val = rs.getString(i);
                    if (val == null) {
                        json.append("null");
                    } else {
                        // Escape quotes
                        json.append("\"")
                           .append(val.replace("\\", "\\\\")
                                     .replace("\"", "\\\""))
                           .append("\"");
                    }
                    if (i < cols) json.append(",");
                }
                json.append("]");
                firstRow = false;
            }
            json.append("]}");

            conn.close();
            out.print(json.toString());

        } catch (SQLException e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}