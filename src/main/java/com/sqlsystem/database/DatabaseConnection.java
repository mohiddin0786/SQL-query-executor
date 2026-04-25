package com.sqlsystem.database;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class DatabaseConnection {

    private static final Logger LOGGER = 
        Logger.getLogger(DatabaseConnection.class.getName());

    public static Connection getConnection() {
        try {
            Context ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/SQLPracticeDB");
            return ds.getConnection();

        } catch (NamingException | SQLException e) {
            LOGGER.severe("Database connection failed: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}