package com.moonbae.servlet;

import com.moonbae.dao.UserDAO;
import com.moonbae.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Controller: AuthServlet
 * Mengendalikan permintaan Log Masuk, Daftar, dan Log Keluar.
 * URL Pattern: /auth
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    // ── GET: Paparkan halaman berkaitan ──────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            // Musnahkan sesi dan ubah hala ke halaman login
            HttpSession session = request.getSession(false);
            if (session != null) session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    // ── POST: Proses borang Login / Register ─────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "login":
                handleLogin(request, response);
                break;
            case "register":
                handleRegister(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
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
