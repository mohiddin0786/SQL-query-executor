package com.sqlsystem.filter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request   = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        String uri = request.getRequestURI();

        boolean loggedIn = (session != null && session.getAttribute("username") != null);

        boolean isPublic =
            uri.endsWith("/login.html") ||
            uri.endsWith("/login")      ||
            uri.endsWith("/logout")     ||
            uri.contains("/fonts/")     ||
            uri.contains("/css/")       ||
            uri.contains("/js/");

        if (loggedIn || isPublic) {
            chain.doFilter(req, res);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.html");
        }
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}