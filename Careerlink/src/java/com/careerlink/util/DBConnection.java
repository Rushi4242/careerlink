package com.careerlink.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static Connection con;

    public static Connection getConnection() {

        try {

            Class.forName("com.mysql.jdbc.Driver");

            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/careerlink",
                    "root",
                    "root"
            );

        } catch (Exception e) {

            e.printStackTrace();

        }

        return con;

    }
}