package com.moonbae.dao;

import com.moonbae.model.Prediction;
import com.moonbae.util.DatabaseConnection;

import java.sql.*;

/**
 * DAO: PredictionDAO
 * Menguruskan operasi bagi jadual 'predictions' dan 'reminders'.
 */
public class PredictionDAO {

    /**
     * Simpan atau kemaskini ramalan untuk pengguna.
     * (Padam yang lama dan masukkan yang baru)
     */
    public boolean savePrediction(Prediction prediction) {
        String sqlDelete = "DELETE FROM predictions WHERE userID = ?";
        String sqlInsert = "INSERT INTO predictions (userID, predictedStartDate, predictedEndDate) VALUES (?, ?, ?)";
        Connection conn  = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Padam ramalan lama
            try (PreparedStatement psD = conn.prepareStatement(sqlDelete)) {
                psD.setInt(1, prediction.getUserID());
                psD.executeUpdate();
            }

            // Masukkan ramalan baru
            try (PreparedStatement psI = conn.prepareStatement(sqlInsert)) {
                psI.setInt(1, prediction.getUserID());
                psI.setDate(2, prediction.getPredictedStartDate());
                psI.setDate(3, prediction.getPredictedEndDate());
                psI.executeUpdate();
            }

            // Kemaskini peringatan
            updateReminder(conn, prediction);

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("[PredictionDAO] Gagal simpan ramalan: " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { /* abaikan */ }
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
        return false;
    }

    /**
     * Dapatkan ramalan terkini bagi pengguna.
     */
    public Prediction getLatestPrediction(int userID) {
        String sql = "SELECT * FROM predictions WHERE userID = ? ORDER BY generatedAt DESC LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Prediction p = new Prediction();
                p.setPredictionID(rs.getInt("predictionID"));
                p.setUserID(rs.getInt("userID"));
                p.setPredictedStartDate(rs.getDate("predictedStartDate"));
                p.setPredictedEndDate(rs.getDate("predictedEndDate"));
                return p;
            }
        } catch (SQLException e) {
            System.err.println("[PredictionDAO] Gagal dapatkan ramalan: " + e.getMessage());
        }
        return null;
    }

    /**
     * Dapatkan peringatan aktif untuk pengguna.
     * Peringatan dipaparkan jika haid dijangka dalam masa 3 hari.
     */
    public String getActiveReminder(int userID) {
        String sql = "SELECT reminderText FROM reminders "
                   + "WHERE userID = ? AND status = 'active' "
                   + "ORDER BY createdAt DESC LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("reminderText");

        } catch (SQLException e) {
            System.err.println("[PredictionDAO] Gagal dapatkan peringatan: " + e.getMessage());
        }
        return null;
    }

    /**
     * Cipta atau kemaskini peringatan berdasarkan tarikh ramalan.
     * Peringatan diaktifkan jika haid dalam masa 3 hari.
     */
    private void updateReminder(Connection conn, Prediction prediction) throws SQLException {
        // Padam peringatan lama
        String sqlDel = "DELETE FROM reminders WHERE userID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlDel)) {
            ps.setInt(1, prediction.getUserID());
            ps.executeUpdate();
        }

        int daysLeft = prediction.getDaysUntilPeriod();

        // Hanya cipta peringatan jika haid dijangka dalam masa 7 hari
        if (daysLeft >= 0 && daysLeft <= 7) {
            String text;
            if (daysLeft == 0) {
                text = "⚠️ Haid anda dijangka HARI INI. Bersedia ya!";
            } else if (daysLeft <= 3) {
                text = "🌙 Haid anda dijangka dalam " + daysLeft + " hari lagi. Sediakan kelengkapan anda!";
            } else {
                text = "📅 Haid anda dijangka dalam " + daysLeft + " hari (" + prediction.getPredictedStartDate() + ")";
            }

            String sqlIns = "INSERT INTO reminders (userID, reminderDate, reminderText, status) VALUES (?, ?, ?, 'active')";
            try (PreparedStatement ps = conn.prepareStatement(sqlIns)) {
                ps.setInt(1, prediction.getUserID());
                ps.setDate(2, prediction.getPredictedStartDate());
                ps.setString(3, text);
                ps.executeUpdate();
            }
        }
    }
}
