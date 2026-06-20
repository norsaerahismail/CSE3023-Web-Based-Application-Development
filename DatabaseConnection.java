/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.moonbae.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Util: DatabaseConnection
 * Menyediakan sambungan tunggal ke MySQL.
 * Tukar nilai DB_URL, DB_USER, DB_PASS mengikut persekitaran tempatan anda.
 */
public class DatabaseConnection {

    // ── Konfigurasi sambungan ────────────────────────────────
    private static final String DB_URL      = "jdbc:mysql://localhost:3306/moonbae_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER     = "root";   // Tukar kepada username MySQL anda
    private static final String DB_PASS     = "";       // Tukar kepada password MySQL anda
    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    // ── Dapatkan sambungan ───────────────────────────────────
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(JDBC_DRIVER);
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver tidak dijumpai. Sila tambah mysql-connector-java.jar ke Libraries.", e);
        }
    }

    // ── Tutup sambungan dengan selamat ───────────────────────
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("[MoonBae DB] Gagal menutup sambungan: " + e.getMessage());
            }
        }
    }
}