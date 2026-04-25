package com.sqlsystem.executor;

import com.sqlsystem.database.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.naming.NamingException;

public class QueryExecutor {
    public static List<List<String>> execute(String query) throws ClassNotFoundException, NamingException {
        List<List<String>> result = new ArrayList<>();
        try {

            Connection conn = DatabaseConnection.getConnection();
            Statement stmt = conn.createStatement();
            
            
            ResultSet rs = stmt.executeQuery(query);

            ResultSetMetaData meta = rs.getMetaData();
            int columns = meta.getColumnCount();
            
            List<String> headers = new ArrayList<>();
            for (int i = 1; i <= columns; i++)
                headers.add(meta.getColumnName(i));
            result.add(headers);
            
            while (rs.next()) {
                List<String> row = new ArrayList<>();
                for (int i = 1; i <= columns; i++)
                    row.add(rs.getString(i));
                result.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }
}