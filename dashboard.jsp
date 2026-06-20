<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.moonbae.model.*,java.util.*,java.sql.Date" %>
<%
    // Semak sesi
    if (session.getAttribute("userID") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String username    = (String) session.getAttribute("username");
    Profile profile    = (Profile) request.getAttribute("profile");
    Prediction pred    = (Prediction) request.getAttribute("prediction");
    List<PeriodLog> recentLogs  = (List<PeriodLog>) request.getAttribute("recentLogs");
    List<PeriodLog> monthLogs   = (List<PeriodLog>) request.getAttribute("monthLogs");
    Integer cycleDay   = (Integer) request.getAttribute("currentCycleDay");
    Integer progress   = (Integer) request.getAttribute("cycleProgress");
    String reminder    = (String)  request.getAttribute("activeReminder");
    int firstDOW       = (int) request.getAttribute("firstDayOfWeek");
    int daysInMonth    = (int) request.getAttribute("daysInMonth");
    int todayDay       = (int) request.getAttribute("today");
    String monthName   = (String)  request.getAttribute("monthName");
    int currentYear    = (int) request.getAttribute("currentYear");
    int currentMonth   = (int) request.getAttribute("currentMonth");
    int cycleLen       = (profile != null) ? profile.getCycleLength() : 28;

    // Bina set hari haid dan hari ramalan untuk kalendar
    Set<Integer> periodDays    = new HashSet<>();
    Set<Integer> predictedDays = new HashSet<>();
    java.util.Calendar cal = java.util.Calendar.getInstance();

    if (monthLogs != null) {
        for (PeriodLog log : monthLogs) {
            if (log.getStartDate() != null) {
                java.util.Calendar s = java.util.Calendar.getInstance();
                s.setTime(log.getStartDate());
                java.util.Calendar e = java.util.Calendar.getInstance();
                if (log.getEndDate() != null) e.setTime(log.getEndDate()); else e = (java.util.Calendar) s.clone();
                while (!s.after(e)) {
                    if (s.get(java.util.Calendar.MONTH) + 1 == currentMonth) {
                        periodDays.add(s.get(java.util.Calendar.DAY_OF_MONTH));
                    }
                    s.add(java.util.Calendar.DAY_OF_MONTH, 1);
                }
            }
        }
    }

    if (pred != null && pred.getPredictedStartDate() != null) {
        java.util.Calendar ps = java.util.Calendar.getInstance();
        ps.setTime(pred.getPredictedStartDate());
        java.util.Calendar pe = java.util.Calendar.getInstance();
        if (pred.getPredictedEndDate() != null) pe.setTime(pred.getPredictedEndDate()); else pe = (java.util.Calendar) ps.clone();
        while (!ps.after(pe)) {
            if (ps.get(java.util.Calendar.MONTH) + 1 == currentMonth && ps.get(java.util.Calendar.YEAR) == currentYear) {
                predictedDays.add(ps.get(java.util.Calendar.DAY_OF_MONTH));
            }
            ps.add(java.util.Calendar.DAY_OF_MONTH, 1);
        }
    }
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MoonBae – Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #fff9f0; color: #333; }

        /* ─── Navbar ────────────────────────── */
        nav {
            background: white;
            padding: 14px 32px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            position: sticky; top: 0; z-index: 100;
        }
        .nav-logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .nav-logo .icon {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, #f5a623, #f5823a);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
        }
        .nav-logo .icon i { color: white; font-size: 16px; }
        .nav-logo span { font-size: 20px; font-weight: 700; color: #f5a623; }
        .nav-links { display: flex; gap: 8px; align-items: center; }
        .nav-links a {
            padding: 8px 16px;
            border-radius: 10px;
            text-decoration: none;
            font-size: 14px; font-weight: 500;
            color: #666; transition: all 0.2s;
        }
        .nav-links a:hover, .nav-links a.active { background: #fff5e0; color: #f5a623; }
        .nav-links a.btn-add {
            background: linear-gradient(135deg, #f5a623, #f5823a);
            color: white; font-weight: 600;
        }
        .nav-links a.btn-add:hover { opacity: 0.9; }
        .nav-links a.btn-logout { color: #999; }

        /* ─── Main ──────────────────────────── */
        main { max-width: 1100px; margin: 0 auto; padding: 28px 20px; }

        /* ─── Reminder Banner ───────────────── */
        .reminder-banner {
            background: linear-gradient(135deg, #f5a623, #f5823a);
            color: white;
            border-radius: 14px;
            padding: 14px 20px;
            margin-bottom: 24px;
            display: flex; align-items: center; gap: 12px;
            font-size: 14px; font-weight: 500;
            box-shadow: 0 4px 15px rgba(245,166,35,0.35);
        }
        .reminder-banner i { font-size: 20px; }

        /* ─── Stats Row ─────────────────────── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            border-left: 4px solid #f5a623;
        }
        .stat-card.pink { border-left-color: #f48fb1; }
        .stat-card.orange { border-left-color: #f5a623; }
        .stat-label {
            font-size: 12px; color: #999; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .stat-value {
            font-size: 28px; font-weight: 700; color: #333;
            margin: 6px 0 4px;
        }
        .stat-sub { font-size: 12px; color: #aaa; }
        .stat-icon { float: right; color: #f5a623; font-size: 22px; margin-top: -30px; }
        .progress-bar {
            height: 6px; background: #f0e0c0;
            border-radius: 3px; margin-top: 8px;
        }
        .progress-fill {
            height: 100%; background: linear-gradient(90deg, #f5a623, #f5823a);
            border-radius: 3px; transition: width 0.5s;
        }

        /* ─── Content Grid ───────────────────── */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 20px;
        }

        /* ─── Kalendar ───────────────────────── */
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .card-header {
            padding: 16px 20px;
            border-bottom: 1px solid #f5f5f5;
            display: flex; align-items: center; justify-content: space-between;
        }
        .card-title {
            font-size: 15px; font-weight: 700; color: #333;
            display: flex; align-items: center; gap: 8px;
        }
        .card-body { padding: 20px; }

        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 4px;
        }
        .cal-header {
            text-align: center;
            font-size: 12px; font-weight: 700; color: #bbb;
            padding: 8px 0; text-transform: uppercase;
        }
        .cal-day {
            aspect-ratio: 1;
            display: flex; align-items: center; justify-content: center;
            border-radius: 50%;
            font-size: 13px;
            cursor: default;
            transition: all 0.2s;
        }
        .cal-day.period    { background: #f48fb1; color: white; font-weight: 600; }
        .cal-day.predicted { background: #ffe0cc; color: #e57315; font-weight: 600; border: 2px dashed #f5a623; }
        .cal-day.today     { background: #f5a623; color: white; font-weight: 700; }
        .cal-day.empty     { /* kosong */ }

        .cal-legend {
            display: flex; gap: 16px; flex-wrap: wrap;
            margin-top: 16px; padding-top: 16px;
            border-top: 1px solid #f5f5f5;
        }
        .legend-item { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #777; }
        .legend-dot {
            width: 12px; height: 12px; border-radius: 50%;
        }

        /* ─── Rekod & Sidebar ─────────────────── */
        .recent-log {
            padding: 14px 0;
            border-bottom: 1px solid #fafafa;
            display: flex; justify-content: space-between; align-items: flex-start;
        }
        .recent-log:last-child { border-bottom: none; }
        .log-date  { font-weight: 600; font-size: 14px; color: #333; }
        .log-dur   { font-size: 12px; color: #aaa; margin-top: 2px; }
        .tag {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 20px;
            font-size: 11px; font-weight: 600;
            background: #fff5e0; color: #f5a623;
            margin: 4px 3px 0 0;
        }
        .tag.pink { background: #fff0f5; color: #e91e8c; }
        .log-flow {
            font-size: 11px; font-weight: 600; color: white;
            background: #f5a623;
            padding: 3px 10px; border-radius: 20px;
        }

        /* ─── Track Cycle Card ────────────────── */
        .track-card {
            background: linear-gradient(135deg, #f8e8ff, #ffe0ee);
            border: none; padding: 20px; text-align: center;
            border-radius: 16px;
        }
        .track-card h4 { font-size: 15px; font-weight: 700; color: #c2185b; margin-bottom: 8px; }
        .track-card p  { font-size: 12px; color: #888; margin-bottom: 16px; }
        .btn-track {
            display: block;
            background: linear-gradient(135deg, #f5a623, #f5823a);
            color: white; text-decoration: none;
            padding: 12px; border-radius: 12px;
            font-size: 14px; font-weight: 700;
        }

        @media (max-width: 768px) {
            .stats-row { grid-template-columns: 1fr 1fr; }
            .content-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- ═══════════ NAVBAR ═══════════ -->
<nav>
    <a href="<%= request.getContextPath() %>/dashboard" class="nav-logo">
        <div class="icon"><i class="fas fa-moon"></i></div>
        <span>MoonBae</span>
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/dashboard" class="active"><i class="fas fa-home"></i> Home</a>
        <a href="<%= request.getContextPath() %>/tracking" class="btn-add"><i class="fas fa-plus"></i> Tambah Rekod</a>
        <a href="<%= request.getContextPath() %>/history"><i class="fas fa-history"></i> Sejarah</a>
        <a href="<%= request.getContextPath() %>/auth?action=logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Log Keluar</a>
    </div>
</nav>

<!-- ═══════════ MAIN ═══════════ -->
<main>

    <!-- Peringatan (jika ada) -->
    <% if (reminder != null) { %>
    <div class="reminder-banner">
        <i class="fas fa-bell"></i>
        <span><%= reminder %></span>
    </div>
    <% } %>

    <!-- ── Kad Statistik ── -->
    <div class="stats-row">
        <!-- Haid Seterusnya -->
        <div class="stat-card pink">
            <div class="stat-label"><i class="fas fa-calendar-alt"></i> Haid Seterusnya</div>
            <% if (pred != null) { %>
                <div class="stat-value"><%= pred.getPredictedStartDate() %></div>
                <div class="stat-sub">
                    <% int days = pred.getDaysUntilPeriod();
                       if (days < 0) { %> Sudah berlalu
                    <% } else if (days == 0) { %> Hari ini!
                    <% } else { %> Dalam <%= days %> hari lagi <% } %>
                </div>
            <% } else { %> <div class="stat-value">–</div><div class="stat-sub">Belum ada data</div> <% } %>
        </div>

        <!-- Hari Semasa Kitaran -->
        <div class="stat-card orange">
            <div class="stat-label"><i class="fas fa-sync-alt"></i> Hari Dalam Kitaran</div>
            <div class="stat-value"><%= cycleDay != null ? cycleDay : "–" %></div>
            <div class="stat-sub">daripada <%= cycleLen %> hari</div>
            <div class="progress-bar">
                <div class="progress-fill" style="width:<%= progress != null ? progress : 0 %>%"></div>
            </div>
        </div>

        <!-- Panjang Kitaran -->
        <div class="stat-card">
            <div class="stat-label"><i class="fas fa-ruler"></i> Panjang Kitaran</div>
            <div class="stat-value"><%= cycleLen %> <span style="font-size:16px;color:#aaa">hari</span></div>
            <div class="stat-sub">Purata kitaran anda</div>
        </div>
    </div>

    <!-- ── Kandungan Utama ── -->
    <div class="content-grid">

        <!-- Kalendar -->
        <div class="card">
            <div class="card-header">
                <div class="card-title"><i class="fas fa-calendar" style="color:#f5a623"></i>
                    <%= monthName %> <%= currentYear %> – Kalendar Kitaran</div>
            </div>
            <div class="card-body">
                <div class="calendar-grid">
                    <!-- Header Hari -->
                    <% String[] days = {"Ahd","Isn","Sel","Rab","Kha","Jum","Sab"};
                       for (String d : days) { %><div class="cal-header"><%= d %></div><% } %>

                    <!-- Sel Kosong sebelum hari pertama -->
                    <% for (int i = 0; i < firstDOW; i++) { %><div class="cal-day empty"></div><% } %>

                    <!-- Hari dalam bulan -->
                    <% for (int day = 1; day <= daysInMonth; day++) {
                        String cls = "";
                        if (day == todayDay) cls = "today";
                        else if (periodDays.contains(day)) cls = "period";
                        else if (predictedDays.contains(day)) cls = "predicted";
                    %>
                        <div class="cal-day <%= cls %>"><%= day %></div>
                    <% } %>
                </div>

                <!-- Legend -->
                <div class="cal-legend">
                    <div class="legend-item"><div class="legend-dot" style="background:#f48fb1"></div> Haid Lepas</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#f5a623"></div> Hari Ini</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#ffe0cc;border:2px dashed #f5a623"></div> Ramalan</div>
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div style="display:flex;flex-direction:column;gap:16px;">

            <!-- Rekod Terkini -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fas fa-list" style="color:#f5a623"></i> Rekod Terkini</div>
                    <a href="<%= request.getContextPath() %>/history" style="font-size:12px;color:#f5a623;text-decoration:none">Lihat Semua →</a>
                </div>
                <div class="card-body" style="padding:12px 20px">
                    <% if (recentLogs != null && !recentLogs.isEmpty()) {
                        for (PeriodLog log : recentLogs) { %>
                        <div class="recent-log">
                            <div>
                                <div class="log-date"><%= log.getStartDate() %></div>
                                <div class="log-dur"><%= log.getDuration() %> hari</div>
                                <% if (log.getSymptoms() != null) {
                                    for (String s : log.getSymptomsArray()) { %>
                                    <span class="tag pink"><%= s.trim() %></span>
                                <% }} %>
                            </div>
                            <span class="log-flow"><%= log.getBloodFlowType() != null ? log.getBloodFlowType() : "–" %></span>
                        </div>
                    <% }} else { %>
                        <p style="color:#aaa;font-size:13px;padding:10px 0">Tiada rekod lagi.</p>
                    <% } %>
                </div>
            </div>

            <!-- Kad Tambah Rekod -->
            <div class="track-card">
                <h4><i class="fas fa-plus-circle"></i> Rekod Kitaran Anda</h4>
                <p>Tambah rekod baru untuk menjejak kitaran dan simptom anda.</p>
                <a href="<%= request.getContextPath() %>/tracking" class="btn-track">
                    <i class="fas fa-plus"></i> Tambah Rekod Baru
                </a>
            </div>

        </div>
    </div>
</main>
</body>
</html>

