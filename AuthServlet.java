package com.moonbae.servlet;

import com.moonbae.dao.PeriodLogDAO;
import com.moonbae.dao.UserDAO;
import com.moonbae.model.PeriodLog;
import com.moonbae.model.Profile;
import com.moonbae.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * Controller: AuthServlet
 * Mengendalikan permintaan Log Masuk, Daftar, dan Log Keluar.
 * URL Pattern: /auth
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PeriodLogDAO logDAO = new PeriodLogDAO();

    // ── GET: Paparkan halaman berkaitan ──────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        // Kalau tak login lagi, tendang pergi page login
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        int userID = (int) session.getAttribute("userID");

        // 1. Ambil data Profile dari Database
        Profile profile = userDAO.getProfileByUserID(userID);
        request.setAttribute("profile", profile);

        // 2. Ambil data Logs dari Database
        List<PeriodLog> recentLogs = logDAO.getLogsByUserID(userID);
        request.setAttribute("recentLogs", recentLogs != null ? recentLogs : new ArrayList<PeriodLog>());
        request.setAttribute("monthLogs", recentLogs != null ? recentLogs : new ArrayList<PeriodLog>()); // Dummy fallback untuk kalendar

        // 3. Setup Dummy/Mock Data untuk Calendar & Attributes yang dashboard.jsp mintak (Bagi tak Crash)
        request.setAttribute("prediction", null);
        request.setAttribute("currentCycleDay", 0);
        request.setAttribute("cycleProgress", 0);
        request.setAttribute("activeReminder", "Selamat Datang ke MoonBae!");
        
        Calendar cal = Calendar.getInstance();
        request.setAttribute("today", cal.get(Calendar.DAY_OF_MONTH));
        request.setAttribute("daysInMonth", cal.getActualMaximum(Calendar.DAY_OF_MONTH));
        
        cal.set(Calendar.DAY_OF_MONTH, 1);
        request.setAttribute("firstDayOfWeek", cal.get(Calendar.DAY_OF_WEEK));
        request.setAttribute("monthName", "Semasa");
        request.setAttribute("currentYear", cal.get(Calendar.YEAR));
        request.setAttribute("currentMonth", cal.get(Calendar.MONTH));

        // 4. Hantar data ke dashboard.jsp
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    // ── POST: Proses borang Login / Register ─────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }

    // ── Proses Log Masuk ─────────────────────────────────────
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        // Validasi input asas
        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Sila isi semua ruangan.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            
            return;
        }

        // Sahkan kelayakan dengan database
        User user = userDAO.loginUser(email.trim(), password);

        if (user != null) {
            // Berjaya — cipta sesi baru
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userID", user.getUserID());
            session.setAttribute("username", user.getUsername());
            session.setMaxInactiveInterval(30 * 60); // Sesi tamat selepas 30 minit

            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            // Gagal — paparkan mesej ralat
            request.setAttribute("error", "E-mel atau kata laluan tidak sah.");
            request.setAttribute("activeTab", "login");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    // ── Proses Pendaftaran ───────────────────────────────────
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name      = request.getParameter("name");
        String username  = request.getParameter("username");
        String email     = request.getParameter("email");
        String password  = request.getParameter("password");
        String confirm   = request.getParameter("confirmPassword");

        // Validasi input
        if (name == null || username == null || email == null || password == null
                || name.isEmpty() || username.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("regError", "Sila isi semua ruangan pendaftaran.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Semak pengesahan kata laluan
        if (!password.equals(confirm)) {
            request.setAttribute("regError", "Kata laluan tidak sepadan.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Semak panjang kata laluan
        if (password.length() < 6) {
            request.setAttribute("regError", "Kata laluan mesti sekurang-kurangnya 6 aksara.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Semak duplikasi email
        if (userDAO.emailExists(email.trim())) {
            request.setAttribute("regError", "E-mel ini telah didaftarkan.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Semak duplikasi username
        if (userDAO.usernameExists(username.trim())) {
            request.setAttribute("regError", "Nama pengguna ini telah digunakan.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Daftar pengguna baru
        int newUserID = userDAO.registerUser(username.trim(), email.trim(), password, name.trim());

        if (newUserID > 0) {
            request.setAttribute("success", "Pendaftaran berjaya! Sila log masuk.");
            request.setAttribute("activeTab", "login");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("regError", "Pendaftaran gagal. Sila cuba lagi.");
            request.setAttribute("activeTab", "register");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
