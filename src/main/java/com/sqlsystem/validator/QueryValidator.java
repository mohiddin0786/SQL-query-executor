package com.sqlsystem.validator;

import java.util.Arrays;
import java.util.List;

public class QueryValidator {

    private static final List<String> restricted = Arrays.asList("DROP", "ALTER", "TRUNCATE", "CREATE", "DELETE");

    public static boolean validate(String query) {
        if (query == null || query.trim().isEmpty()) {
            return false;
        }
        String upper = query.toUpperCase();

        for (String word : restricted) {

            if (upper.contains(word))
                return false;
        }

        return true;
    }
}