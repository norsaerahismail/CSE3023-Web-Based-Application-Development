/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.moonbae.dao;

import com.moonbae.model.Profile;
import com.moonbae.model.User;
import com.moonbae.util.DatabaseConnection;
import com.moonbae.util.PasswordUtil;

import java.sql.*;

/**
 * DAO: UserDAO
 * Menguruskan operasi CRUD bagi jadual 'users' dan 'profiles'.
 */
public class UserDAO {

    // ══════════════════════════════════════════════════════════
    // OPERASI: USER
    // ══════════════════════════════════════════════════════════

    /**
     * Daftar pengguna baru ke dalam sistem.
     * @return userID yang baru dijana, atau -1 jika gagal
     */
    public int registerUser(String username, String email, String password, String name) {
        String sqlUser    = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
        String sqlProfile = "INSERT INTO profiles (userID, name, cycleLength) VALUES (?, ?, 28)";
        Connection conn   = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Mulakan transaksi

            // 1. Masukkan ke jadual users
            try (PreparedStatement psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, username);
                psUser.setString(2, email);
                psUser.setString(3, PasswordUtil.hashPassword(password));
                psUser.executeUpdate();

                ResultSet rs = psUser.getGeneratedKeys();
                if (rs.next()) {
                    int newUserID = rs.getInt(1);

                    // 2. Cipta profil lalai untuk user baru
                    try (PreparedStatement psProfile = conn.prepareStatement(sqlProfile)) {
                        psProfile.setInt(1, newUserID);
                        psProfile.setString(2, name);
                        psProfile.executeUpdate();
                    }

                    conn.commit(); // Sahkan transaksi
                    return newUserID;
                }
            }
            conn.rollback();
        } catch (SQLException e) {
            System.err.println("[UserDAO] Gagal mendaftar pengguna: " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { /* abaikan */ }
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
        return -1;
    }

    /**
     * Sahkan kelayakan log masuk pengguna.
     * @return objek User jika berjaya, null jika gagal
     */
    public User loginUser(String email, String password) {
        String sql = "SELECT userID, username, email, password FROM users WHERE email = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");
                // Sahkan password menggunakan PasswordUtil
                if (PasswordUtil.verifyPassword(password, storedHash)) {
                    User user = new User();
                    user.setUserID(rs.getInt("userID"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] Gagal log masuk: " + e.getMessage());
        }
        return null;
    }

    /**
     * Semak sama ada email sudah wujud dalam sistem.
     */
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] Gagal semak email: " + e.getMessage());
        }
        return false;
    }

    /**
     * Semak sama ada username sudah wujud dalam sistem.
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] Gagal semak username: " + e.getMessage());
        }
        return false;
    }

    // ══════════════════════════════════════════════════════════
    // OPERASI: PROFILE
    // ══════════════════════════════════════════════════════════

    /**
     * Dapatkan profil pengguna berdasarkan userID.
     */
    public Profile getProfileByUserID(int userID) {
        String sql = "SELECT * FROM profiles WHERE userID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Profile p = new Profile();
                p.setProfileID(rs.getInt("profileID"));
                p.setUserID(rs.getInt("userID"));
                p.setName(rs.getString("name"));
                p.setBirthDate(rs.getDate("birthDate"));
                p.setCycleLength(rs.getInt("cycleLength"));
                return p;
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] Gagal dapatkan profil: " + e.getMessage());
        }
        return null;
    }

    /**
     * Kemaskini profil pengguna.
     */
    public boolean updateProfile(Profile profile) {
        String sql = "UPDATE profiles SET name=?, birthDate=?, cycleLength=? WHERE userID=?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, profile.getName());
            ps.setDate(2, profile.getBirthDate());
            ps.setInt(3, profile.getCycleLength());
            ps.setInt(4, profile.getUserID());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO] Gagal kemaskini profil: " + e.getMessage());
        }
        return false;
    }
}
