package db_config;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL  = AppConfig.get("db.url");
    private static final String USER = AppConfig.get("db.user");
    private static final String PASS = AppConfig.get("db.password");

    private DBConnection() {
    }

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {
            throw new RuntimeException("Database connection failed", e);
        }
    }
}
