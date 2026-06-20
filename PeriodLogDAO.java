package com.moonbae.dao;

import com.moonbae.model.PeriodLog;
import com.moonbae.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO: PeriodLogDAO
 * Menguruskan operasi CRUD bagi jadual 'period_logs'.
 */
public class PeriodLogDAO {

    /**
     * Simpan rekod haid baru ke dalam database.
     * @return true jika berjaya
     */
    public boolean insertLog(PeriodLog log) {
        String sql = "INSERT INTO period_logs (userID, startDate, endDate, bloodFlowType, symptoms, notes) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, log.getUserID());
            ps.setDate(2, log.getStartDate());
            ps.setDate(3, log.getEndDate());
            ps.setString(4, log.getBloodFlowType());
            ps.setString(5, log.getSymptoms());
            ps.setString(6, log.getNotes());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[PeriodLogDAO] Gagal simpan log: " + e.getMessage());
        }
        return false;
    }

    /**
     * Dapatkan semua rekod haid pengguna, disusun dari terbaru.
     */
    public List<PeriodLog> getLogsByUserID(int userID) {
        String sql = "SELECT * FROM period_logs WHERE userID = ? ORDER BY startDate DESC";
        List<PeriodLog> logs = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                logs.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PeriodLogDAO] Gagal dapatkan logs: " + e.getMessage());
        }
        return logs;
    }

    /**
     * Dapatkan rekod haid terkini (paling baru) pengguna.
     */
    public PeriodLog getLatestLog(int userID) {
        String sql = "SELECT * FROM period_logs WHERE userID = ? ORDER BY startDate DESC LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSet(rs);

        } catch (SQLException e) {
            System.err.println("[PeriodLogDAO] Gagal dapatkan log terkini: " + e.getMessage());
        }
        return null;
    }

    /**
     * Dapatkan rekod bagi bulan tertentu (untuk paparan kalendar).
     */
    public List<PeriodLog> getLogsByMonth(int userID, int year, int month) {
        String sql = "SELECT * FROM period_logs WHERE userID = ? "
                   + "AND YEAR(startDate) = ? AND MONTH(startDate) = ? "
                   + "ORDER BY startDate ASC";
        List<PeriodLog> logs = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ps.setInt(2, year);
            ps.setInt(3, month);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                logs.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PeriodLogDAO] Gagal dapatkan logs bulanan: " + e.getMessage());
        }
        return logs;
    }

    /**
     * Padam rekod haid berdasarkan dataID.
     */
    public boolean deleteLog(int dataID, int userID) {
        String sql = "DELETE FROM period_logs WHERE dataID = ? AND userID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, dataID);
            ps.setInt(2, userID);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[PeriodLogDAO] Gagal padam log: " + e.getMessage());
        }
        return false;
    }

    /**
     * Kira purata selang hari antara kitaran (untuk algoritma ramalan).
     * Menggunakan 3 rekod terkini.
     */
    public double getAverageCycleInterval(int userID) {
        String sql = "SELECT startDate FROM period_logs WHERE userID = ? "
                   + "ORDER BY startDate DESC LIMIT 4";
        List<Date> dates = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                dates.add(rs.getDate("startDate"));
            }
        } catch (SQLException e) {
            System.err.println("[PeriodLogDAO] Gagal kira purata: " + e.getMessage());
        }

        // Perlu sekurang-kurangnya 2 rekod untuk kira purata
        if (dates.size() < 2) return -1;

        long totalDiff = 0;
        for (int i = 0; i < dates.size() - 1; i++) {
            long diff = dates.get(i).getTime() - dates.get(i + 1).getTime();
            totalDiff += diff / (1000 * 60 * 60 * 24); // tukar ke hari
        }
        return (double) totalDiff / (dates.size() - 1);
    }

    // ── Helper: Petakan ResultSet kepada objek PeriodLog ─────
    private PeriodLog mapResultSet(ResultSet rs) throws SQLException {
        PeriodLog log = new PeriodLog();
        log.setDataID(rs.getInt("dataID"));
        log.setUserID(rs.getInt("userID"));
        log.setStartDate(rs.getDate("startDate"));
        log.setEndDate(rs.getDate("endDate"));
        log.setBloodFlowType(rs.getString("bloodFlowType"));
        log.setSymptoms(rs.getString("symptoms"));
        log.setNotes(rs.getString("notes"));
        log.setCreatedAt(rs.getTimestamp("createdAt"));
        return log;
    }
}
