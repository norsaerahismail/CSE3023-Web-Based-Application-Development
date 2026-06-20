package com.moonbae.servlet;

import com.moonbae.dao.PeriodLogDAO;
import com.moonbae.dao.PredictionDAO;
import com.moonbae.dao.UserDAO;
import com.moonbae.model.PeriodLog;
import com.moonbae.model.Prediction;
import com.moonbae.model.Profile;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Controller: TrackingServlet
 * Mengendalikan input rekod haid baru dan paparan sejarah.
 * URL Patterns: /tracking, /history, /delete-log
 */
@WebServlet(name = "TrackingServlet", urlPatterns = {"/tracking", "/history", "/delete-log"})
public class TrackingServlet extends HttpServlet {

    private final PeriodLogDAO  periodLogDAO  = new PeriodLogDAO();
    private final PredictionDAO predictionDAO = new PredictionDAO();
    private final UserDAO       userDAO       = new UserDAO();

    // ── GET: Paparkan borang atau sejarah ────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Semak sesi
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userID = (int) session.getAttribute("userID");
        String path = request.getServletPath();

        if ("/history".equals(path)) {
            // Paparan sejarah semua rekod
            List<PeriodLog> allLogs = periodLogDAO.getLogsByUserID(userID);
            request.setAttribute("allLogs", allLogs);
            request.getRequestDispatcher("/history.jsp").forward(request, response);

        } else if ("/delete-log".equals(path)) {
            // Padam rekod berdasarkan dataID
            String dataIDStr = request.getParameter("id");
            if (dataIDStr != null) {
                try {
                    int dataID = Integer.parseInt(dataIDStr);
                    periodLogDAO.deleteLog(dataID, userID);
                } catch (NumberFormatException e) {
                    // ID tidak sah, abaikan
                }
            }
            response.sendRedirect(request.getContextPath() + "/history");

        } else {
            // Paparan borang tambah rekod
            request.getRequestDispatcher("/add_record.jsp").forward(request, response);
        }
    }

    // ── POST: Simpan rekod haid baru ─────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Semak sesi
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userID = (int) session.getAttribute("userID");

        // Ambil nilai dari borang
        String startDateStr   = request.getParameter("startDate");
        String endDateStr     = request.getParameter("endDate");
        String bloodFlowType  = request.getParameter("bloodFlowType");
        String[] symptomsArr  = request.getParameterValues("symptoms");
        String notes          = request.getParameter("notes");

        // Validasi input
        if (startDateStr == null || startDateStr.isEmpty()) {
            request.setAttribute("error", "Tarikh mula diperlukan.");
            request.getRequestDispatcher("/add_record.jsp").forward(request, response);
            return;
        }

        // Bina objek PeriodLog
        PeriodLog log = new PeriodLog();
        log.setUserID(userID);
        log.setStartDate(Date.valueOf(startDateStr));

        if (endDateStr != null && !endDateStr.isEmpty()) {
            Date endDate = Date.valueOf(endDateStr);
            // Pastikan tarikh tamat tidak lebih awal dari tarikh mula
            if (endDate.before(log.getStartDate())) {
                request.setAttribute("error", "Tarikh tamat tidak boleh lebih awal dari tarikh mula.");
                request.getRequestDispatcher("/add_record.jsp").forward(request, response);
                return;
            }
            log.setEndDate(endDate);
        }

        // Set jenis aliran darah (lalai: Medium)
        log.setBloodFlowType((bloodFlowType != null && !bloodFlowType.isEmpty()) ? bloodFlowType : "Medium");

        // Gabung simptom menjadi satu string CSV
        if (symptomsArr != null && symptomsArr.length > 0) {
            log.setSymptoms(String.join(",", symptomsArr));
        }

        log.setNotes((notes != null && !notes.isEmpty()) ? notes : null);

        // Simpan ke database
        boolean saved = periodLogDAO.insertLog(log);

        if (saved) {
            // Jana ramalan baru selepas rekod disimpan
            generateAndSavePrediction(userID);
            request.setAttribute("success", "Rekod haid berjaya disimpan!");
        } else {
            request.setAttribute("error", "Gagal menyimpan rekod. Sila cuba lagi.");
        }

        request.getRequestDispatcher("/add_record.jsp").forward(request, response);
    }

    // ── Jana dan simpan ramalan baru ─────────────────────────
    private void generateAndSavePrediction(int userID) {
        // Dapatkan rekod terkini
        PeriodLog latestLog = periodLogDAO.getLatestLog(userID);
        if (latestLog == null) return;

        // Dapatkan profil untuk cycleLength lalai
        Profile profile = userDAO.getProfileByUserID(userID);
        int cycleLength = (profile != null) ? profile.getCycleLength() : 28;

        // Kira purata selang (jika ada cukup data)
        double avgInterval = periodLogDAO.getAverageCycleInterval(userID);
        int predictedInterval = (avgInterval > 0) ? (int) Math.round(avgInterval) : cycleLength;

        // Tarikh mula ramalan = tarikh mula terkini + selang kitaran
        long predictedStartMillis = latestLog.getStartDate().getTime()
                + (long) predictedInterval * 24 * 60 * 60 * 1000;
        Date predictedStart = new Date(predictedStartMillis);

        // Anggap tempoh haid = 5 hari (boleh disesuaikan)
        int estimatedDuration = 5;
        if (latestLog.getEndDate() != null) {
            estimatedDuration = latestLog.getDuration();
        }
        Date predictedEnd = new Date(predictedStartMillis + (long)(estimatedDuration - 1) * 24 * 60 * 60 * 1000);

        // Simpan ramalan
        Prediction prediction = new Prediction(userID, predictedStart, predictedEnd);
        predictionDAO.savePrediction(prediction);
    }
}
