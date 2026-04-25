package com.sqlsystem.controller;

import com.sqlsystem.executor.QueryExecutor;
import com.sqlsystem.validator.QueryValidator;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class QueryController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("query");

        if (!QueryValidator.validate(query)) {
            request.setAttribute("error", "Restricted SQL command");
            request.getRequestDispatcher("result.jsp").forward(request, response);
            return;
        }

        try {
            List<List<String>> result = QueryExecutor.execute(query);
            request.setAttribute("result", result);
        } catch (Exception e) {
            request.setAttribute("error", "Query execution failed: " + e.getMessage());
        }

        request.getRequestDispatcher("result.jsp").forward(request, response);
    }
}