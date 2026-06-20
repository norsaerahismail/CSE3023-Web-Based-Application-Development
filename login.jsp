<%-- 
    Document   : login
    Created on : 20 Jun 2026, 11:59:28 pm
    Author     : ASUS
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Jika pengguna sudah log masuk, ubah hala ke dashboard
    if (session.getAttribute("userID") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "login";
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MoonBae – Log Masuk</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #fff5f7 0%, #ffeef5 50%, #fff9e6 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .auth-wrapper {
            width: 100%;
            max-width: 440px;
            padding: 20px;
        }

        /* ─── Logo ─────────────────────────── */
        .logo-section {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo-icon {
            width: 64px; height: 64px;
            background: linear-gradient(135deg, #f5a623, #f5823a);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
            box-shadow: 0 4px 15px rgba(245,166,35,0.4);
        }
        .logo-icon i { color: white; font-size: 28px; }
        .logo-section h1 { font-size: 28px; color: #f5a623; font-weight: 700; }
        .logo-section p  { color: #999; font-size: 14px; margin-top: 4px; }

        /* ─── Card ─────────────────────────── */
        .auth-card {
            background: white;
            border-radius: 20px;
            padding: 36px 32px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.08);
        }

        /* ─── Tab ──────────────────────────── */
        .tab-buttons {
            display: flex;
            background: #f8f8f8;
            border-radius: 12px;
            padding: 4px;
            margin-bottom: 28px;
        }
        .tab-btn {
            flex: 1;
            padding: 10px;
            border: none;
            background: transparent;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            color: #999;
            cursor: pointer;
            transition: all 0.3s;
        }
        .tab-btn.active {
            background: white;
            color: #f5a623;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        /* ─── Form ─────────────────────────── */
        .form-panel { display: none; }
        .form-panel.active { display: block; }

        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
        }
        .input-wrap { position: relative; }
        .input-wrap i {
            position: absolute;
            left: 14px; top: 50%;
            transform: translateY(-50%);
            color: #f5a623;
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 12px 14px 12px 40px;
            border: 2px solid #f0e8d0;
            border-radius: 12px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
            color: #333;
        }
        .form-group input:focus { border-color: #f5a623; }

        /* ─── Alerts ───────────────────────── */
        .alert {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 18px;
            font-size: 13px;
            font-weight: 500;
        }
        .alert-error { background: #fff0f0; color: #d93025; border: 1px solid #ffc5c5; }
        .alert-success { background: #f0fff4; color: #2d7a4f; border: 1px solid #b2f0cc; }

        /* ─── Button ───────────────────────── */
        .btn-primary {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #f5a623, #f5823a);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: opacity 0.3s, transform 0.2s;
            margin-top: 8px;
        }
        .btn-primary:hover { opacity: 0.9; transform: translateY(-1px); }

        .forgot-link {
            text-align: right;
            margin-top: -10px;
            margin-bottom: 14px;
        }
        .forgot-link a { color: #f5a623; font-size: 12px; text-decoration: none; }
    </style>
</head>
<body>

<div class="auth-wrapper">
    <!-- Logo -->
    <div class="logo-section">
        <div class="logo-icon"><i class="fas fa-moon"></i></div>
        <h1>MoonBae</h1>
        <p>Track your cycle with care 🌙</p>
    </div>

    <!-- Kad Autentikasi -->
    <div class="auth-card">
        <!-- Tab Butang -->
        <div class="tab-buttons">
            <button class="tab-btn <%= "login".equals(activeTab) ? "active" : "" %>"
                    onclick="switchTab('login')">Log Masuk</button>
            <button class="tab-btn <%= "register".equals(activeTab) ? "active" : "" %>"
                    onclick="switchTab('register')">Daftar</button>
        </div>

        <!-- ══ PANEL LOG MASUK ══ -->
        <div id="panel-login" class="form-panel <%= "login".equals(activeTab) ? "active" : "" %>">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/auth?action=login" method="POST">
                <input type="hidden" name="action" value="login">

                <div class="form-group">
                    <label>E-mel</label>
                    <div class="input-wrap">
                        <i class="fas fa-envelope"></i>
                        <input type="email" name="email" placeholder="your@email.com" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Kata Laluan</label>
                    <div class="input-wrap">
                        <i class="fas fa-lock"></i>
                        <input type="password" name="password" placeholder="Masukkan kata laluan" required>
                    </div>
                </div>

                <button type="submit" class="btn-primary">
                    <i class="fas fa-sign-in-alt"></i> Log Masuk
                </button>
            </form>
        </div>

        <!-- ══ PANEL DAFTAR ══ -->
        <div id="panel-register" class="form-panel <%= "register".equals(activeTab) ? "active" : "" %>">
            <% if (request.getAttribute("regError") != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("regError") %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/auth?action=register" method="POST">
                <input type="hidden" name="action" value="register">

                <div class="form-group">
                    <label>Nama Penuh</label>
                    <div class="input-wrap">
                        <i class="fas fa-user"></i>
                        <input type="text" name="name" placeholder="Nama penuh anda" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Nama Pengguna</label>
                    <div class="input-wrap">
                        <i class="fas fa-at"></i>
                        <input type="text" name="username" placeholder="username unik" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>E-mel</label>
                    <div class="input-wrap">
                        <i class="fas fa-envelope"></i>
                        <input type="email" name="email" placeholder="your@email.com" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Kata Laluan</label>
                    <div class="input-wrap">
                        <i class="fas fa-lock"></i>
                        <input type="password" name="password" placeholder="Min. 6 aksara" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Sahkan Kata Laluan</label>
                    <div class="input-wrap">
                        <i class="fas fa-shield-alt"></i>
                        <input type="password" name="confirmPassword" placeholder="Ulang kata laluan" required>
                    </div>
                </div>

                <button type="submit" class="btn-primary">
                    <i class="fas fa-user-plus"></i> Daftar Sekarang
                </button>
            </form>
        </div>
    </div><!-- /auth-card -->
</div>

<script>
    function switchTab(tab) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.form-panel').forEach(p => p.classList.remove('active'));
        document.querySelector('#panel-' + tab).classList.add('active');
        event.target.classList.add('active');
    }
</script>
</body>
</html>
