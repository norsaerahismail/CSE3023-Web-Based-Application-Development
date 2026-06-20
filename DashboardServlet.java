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
import java.time.LocalDate;
import java.util.List;

/**
 * Controller: DashboardServlet
 * Mengendalikan paparan utama (dashboard) pengguna.
 * URL Pattern: /dashboard
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final UserDAO       userDAO       = new UserDAO();
    private final PeriodLogDAO  periodLogDAO  = new PeriodLogDAO();
    private final PredictionDAO predictionDAO = new PredictionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Semak Sesi: Pengguna mesti log masuk ─────────────
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userID = (int) session.getAttribute("userID");

        // ── Ambil data yang diperlukan ────────────────────────

        // 1. Profil pengguna (untuk cycleLength)
        Profile profile = userDAO.getProfileByUserID(userID);
        request.setAttribute("profile", profile);

        // 2. 3 rekod haid terkini untuk paparan ringkas
        List<PeriodLog> recentLogs = periodLogDAO.getLogsByUserID(userID);
        List<PeriodLog> top3 = recentLogs.size() > 3 ? recentLogs.subList(0, 3) : recentLogs;
        request.setAttribute("recentLogs", top3);

        // 3. Rekod haid untuk bulan semasa (untuk kalendar)
        LocalDate today = LocalDate.now();
        List<PeriodLog> monthLogs = periodLogDAO.getLogsByMonth(userID, today.getYear(), today.getMonthValue());
        request.setAttribute("monthLogs", monthLogs);
        request.setAttribute("currentYear", today.getYear());
        request.setAttribute("currentMonth", today.getMonthValue());
        request.setAttribute("today", today.getDayOfMonth());
        request.setAttribute("todayFull", today.toString());

        // 4. Ramalan terkini
        Prediction prediction = predictionDAO.getLatestPrediction(userID);
        request.setAttribute("prediction", prediction);

        // 5. Kiraan hari semasa dalam kitaran (Current Cycle Day)
        PeriodLog latestLog = periodLogDAO.getLatestLog(userID);
        if (latestLog != null) {
            long diffMillis = System.currentTimeMillis() - latestLog.getStartDate().getTime();
            int currentCycleDay = (int)(diffMillis / (1000 * 60 * 60 * 24)) + 1;
            request.setAttribute("currentCycleDay", currentCycleDay);
            request.setAttribute("latestLog", latestLog);
            // Progres dalam kitaran (peratusan)
            int cycleLen = (profile != null) ? profile.getCycleLength() : 28;
            int progress = Math.min((currentCycleDay * 100) / cycleLen, 100);
            request.setAttribute("cycleProgress", progress);
        }

        // 6. Peringatan aktif
        String reminder = predictionDAO.getActiveReminder(userID);
        request.setAttribute("activeReminder", reminder);

        // 7. Hari pertama bulan (untuk susun atur kalendar)
        LocalDate firstDay = LocalDate.of(today.getYear(), today.getMonthValue(), 1);
        request.setAttribute("firstDayOfWeek", firstDay.getDayOfWeek().getValue() % 7); // 0=Ahad
        request.setAttribute("daysInMonth", firstDay.lengthOfMonth());

        // 8. Nama bulan
        String[] monthNames = {"", "Januari","Februari","Mac","April","Mei","Jun",
                               "Julai","Ogos","September","Oktober","November","Disember"};
        request.setAttribute("monthName", monthNames[today.getMonthValue()]);

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}
