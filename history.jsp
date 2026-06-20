<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.moonbae.model.PeriodLog,java.util.List" %>
<%
    if (session.getAttribute("userID") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    List<PeriodLog> allLogs = (List<PeriodLog>) request.getAttribute("allLogs");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MoonBae – Sejarah Haid</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',Tahoma,sans-serif; background:#fff9f0; color:#333; }

        nav {
            background:white; padding:14px 32px;
            display:flex; align-items:center; justify-content:space-between;
            box-shadow:0 2px 10px rgba(0,0,0,0.06); position:sticky; top:0; z-index:100;
        }
        .nav-logo { display:flex; align-items:center; gap:10px; text-decoration:none; }
        .nav-logo .icon {
            width:36px; height:36px;
            background:linear-gradient(135deg,#f5a623,#f5823a);
            border-radius:50%; display:flex; align-items:center; justify-content:center;
        }
        .nav-logo .icon i { color:white; font-size:16px; }
        .nav-logo span { font-size:20px; font-weight:700; color:#f5a623; }
        .nav-links { display:flex; gap:8px; align-items:center; }
        .nav-links a {
            padding:8px 16px; border-radius:10px;
            text-decoration:none; font-size:14px; font-weight:500; color:#666;
        }
        .nav-links a.active,
        .nav-links a:hover { background:#fff5e0; color:#f5a623; }
        .nav-links a.btn-add { background:linear-gradient(135deg,#f5a623,#f5823a); color:white; font-weight:600; }

        main { max-width:900px; margin:0 auto; padding:32px 20px; }

        .page-header {
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:28px;
        }
        .page-title {
            font-size:22px; font-weight:700; color:#333;
            display:flex; align-items:center; gap:10px;
        }
        .page-title i { color:#f5a623; }
        .badge {
            background:#fff5e0; color:#f5a623;
            padding:6px 14px; border-radius:20px;
            font-size:13px; font-weight:700;
        }
        .btn-add-link {
            padding:10px 20px;
            background:linear-gradient(135deg,#f5a623,#f5823a);
            color:white; text-decoration:none;
            border-radius:12px; font-size:14px; font-weight:700;
        }

        /* ─── Rekod card ─── */
        .log-card {
            background:white; border-radius:16px;
            box-shadow:0 2px 12px rgba(0,0,0,0.06);
            margin-bottom:16px; overflow:hidden;
            border-left:5px solid #f5a623;
            transition:box-shadow 0.2s;
        }
        .log-card:hover { box-shadow:0 4px 20px rgba(0,0,0,0.1); }
        .log-card.heavy  { border-left-color:#e53935; }
        .log-card.light  { border-left-color:#81c784; }
        .log-card.spotting { border-left-color:#9575cd; }

        .log-card-header {
            padding:16px 24px;
            display:flex; align-items:center; justify-content:space-between;
            cursor:pointer;
        }
        .log-left { display:flex; align-items:center; gap:16px; }
        .log-date-badge {
            width:52px; height:52px;
            background:linear-gradient(135deg,#fff5e0,#ffe0cc);
            border-radius:14px;
            display:flex; flex-direction:column; align-items:center; justify-content:center;
        }
        .date-day   { font-size:22px; font-weight:800; color:#f5a623; line-height:1; }
        .date-month { font-size:10px; font-weight:700; color:#f5a623; text-transform:uppercase; }

        .log-info h3 { font-size:16px; font-weight:700; color:#333; }
        .log-info p  { font-size:13px; color:#aaa; margin-top:2px; }

        .log-right { display:flex; align-items:center; gap:12px; }
        .flow-badge {
            padding:5px 14px; border-radius:20px;
            font-size:12px; font-weight:700; color:white;
        }
        .flow-badge.Light    { background:#81c784; }
        .flow-badge.Medium   { background:#f5a623; }
        .flow-badge.Heavy    { background:#e53935; }
        .flow-badge.Spotting { background:#9575cd; }

        .toggle-btn {
            background:none; border:none; color:#ccc;
            font-size:14px; cursor:pointer; padding:6px;
            transition:transform 0.3s, color 0.2s;
        }
        .toggle-btn.open { transform:rotate(180deg); color:#f5a623; }

        /* ─── Rekod detail (tersembunyi) ─── */
        .log-detail {
            display:none;
            padding:0 24px 20px;
            border-top:1px solid #f8f8f8;
        }
        .log-detail.show { display:block; }
        .detail-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-top:16px; }
        .detail-item .d-label { font-size:11px; color:#bbb; font-weight:700; text-transform:uppercase; margin-bottom:4px; }
        .detail-item .d-value { font-size:14px; color:#333; font-weight:600; }

        .symptom-tags { margin-top:14px; }
        .stag {
            display:inline-block; margin:3px;
            padding:5px 12px; border-radius:20px;
            font-size:12px; font-weight:600;
            background:#fff0f7; color:#c2185b;
        }
        .notes-box {
            margin-top:14px; padding:12px 16px;
            background:#fafafa; border-radius:10px;
            font-size:13px; color:#666;
            border-left:3px solid #f5a623;
        }

        .del-btn {
            display:inline-flex; align-items:center; gap:6px;
            margin-top:16px;
            padding:8px 16px; border-radius:10px;
            background:#fff0f0; color:#e53935;
            border:1px solid #ffc5c5;
            font-size:12px; font-weight:600;
            text-decoration:none; cursor:pointer;
            transition:background 0.2s;
        }
        .del-btn:hover { background:#ffe0e0; }

        /* ─── Empty state ─── */
        .empty-state {
            text-align:center; padding:60px 20px;
            background:white; border-radius:20px;
        }
        .empty-state i { font-size:50px; color:#f0d8b0; margin-bottom:16px; }
        .empty-state h3 { font-size:18px; color:#555; margin-bottom:8px; }
        .empty-state p { font-size:14px; color:#aaa; margin-bottom:20px; }
        .empty-state a {
            padding:12px 24px;
            background:linear-gradient(135deg,#f5a623,#f5823a);
            color:white; text-decoration:none;
            border-radius:12px; font-weight:700;
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<nav>
    <a href="<%= request.getContextPath() %>/dashboard" class="nav-logo">
        <div class="icon"><i class="fas fa-moon"></i></div>
        <span>MoonBae</span>
    </a>
    <div class="nav-links">
        <a href="<%= request.getContextPath() %>/dashboard"><i class="fas fa-home"></i> Home</a>
        <a href="<%= request.getContextPath() %>/tracking" class="btn-add"><i class="fas fa-plus"></i> Tambah Rekod</a>
        <a href="<%= request.getContextPath() %>/history" class="active"><i class="fas fa-history"></i> Sejarah</a>
        <a href="<%= request.getContextPath() %>/auth?action=logout"><i class="fas fa-sign-out-alt"></i> Log Keluar</a>
    </div>
</nav>

<main>
    <div class="page-header">
        <div>
            <div class="page-title"><i class="fas fa-history"></i> Sejarah Haid</div>
            <% if (allLogs != null) { %>
            <span class="badge"><i class="fas fa-folder"></i> <%= allLogs.size() %> rekod disimpan</span>
            <% } %>
        </div>
        <a href="<%= request.getContextPath() %>/tracking" class="btn-add-link">
            <i class="fas fa-plus"></i> Rekod Baru
        </a>
    </div>

    <!-- Senarai rekod -->
    <% if (allLogs == null || allLogs.isEmpty()) { %>
        <div class="empty-state">
            <i class="fas fa-calendar-times"></i>
            <h3>Tiada Rekod Lagi</h3>
            <p>Mulakan dengan menambah rekod haid pertama anda.</p>
            <a href="<%= request.getContextPath() %>/tracking"><i class="fas fa-plus"></i> Tambah Rekod Pertama</a>
        </div>
    <% } else {
        String[] monthNames = {"","Jan","Feb","Mac","Apr","Mei","Jun","Jul","Ogos","Sep","Okt","Nov","Dis"};
        int idx = 0;
        for (PeriodLog log : allLogs) {
            idx++;
            java.util.Calendar c = java.util.Calendar.getInstance();
            c.setTime(log.getStartDate());
            int dayNum = c.get(java.util.Calendar.DAY_OF_MONTH);
            String mon = monthNames[c.get(java.util.Calendar.MONTH) + 1];
            String flow = log.getBloodFlowType() != null ? log.getBloodFlowType() : "Medium";
    %>
    <div class="log-card <%= flow.toLowerCase() %>">
        <!-- Header (boleh diklik) -->
        <div class="log-card-header" onclick="toggleDetail(<%= idx %>)">
            <div class="log-left">
                <div class="log-date-badge">
                    <span class="date-day"><%= dayNum %></span>
                    <span class="date-month"><%= mon %></span>
                </div>
                <div class="log-info">
                    <h3><%= log.getStartDate() %> – <%= log.getEndDate() != null ? log.getEndDate() : "?" %></h3>
                    <p><i class="fas fa-clock"></i> Tempoh: <%= log.getDuration() %> hari
                        <% if (log.getSymptoms() != null) { %> &nbsp;|&nbsp; <i class="fas fa-stethoscope"></i> <%= log.getSymptomsArray().length %> simptom <% } %>
                    </p>
                </div>
            </div>
            <div class="log-right">
                <span class="flow-badge <%= flow %>"><%= flow %></span>
                <button class="toggle-btn" id="btn-<%= idx %>"><i class="fas fa-chevron-down"></i></button>
            </div>
        </div>

        <!-- Detail (tersembunyi) -->
        <div class="log-detail" id="detail-<%= idx %>">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="d-label"><i class="fas fa-play"></i> Tarikh Mula</div>
                    <div class="d-value"><%= log.getStartDate() %></div>
                </div>
                <div class="detail-item">
                    <div class="d-label"><i class="fas fa-stop"></i> Tarikh Tamat</div>
                    <div class="d-value"><%= log.getEndDate() != null ? log.getEndDate() : "Tidak diisi" %></div>
                </div>
                <div class="detail-item">
                    <div class="d-label"><i class="fas fa-ruler-horizontal"></i> Tempoh</div>
                    <div class="d-value"><%= log.getDuration() %> hari</div>
                </div>
            </div>

            <!-- Simptom -->
            <% if (log.getSymptoms() != null && !log.getSymptoms().isEmpty()) { %>
            <div class="symptom-tags">
                <div class="d-label" style="margin-bottom:8px"><i class="fas fa-heartbeat"></i> Simptom</div>
                <% for (String s : log.getSymptomsArray()) { %><span class="stag"><%= s.trim() %></span><% } %>
            </div>
            <% } %>

            <!-- Nota -->
            <% if (log.getNotes() != null && !log.getNotes().isEmpty()) { %>
            <div class="notes-box"><i class="fas fa-sticky-note" style="color:#f5a623"></i> <%= log.getNotes() %></div>
            <% } %>

            <!-- Butang Padam -->
            <a href="<%= request.getContextPath() %>/delete-log?id=<%= log.getDataID() %>"
               class="del-btn"
               onclick="return confirm('Padam rekod ini? Tindakan ini tidak boleh dibatalkan.')">
                <i class="fas fa-trash-alt"></i> Padam Rekod
            </a>
        </div>
    </div>
    <% }} %>

</main>

<script>
    function toggleDetail(idx) {
        const detail = document.getElementById('detail-' + idx);
        const btn    = document.getElementById('btn-' + idx);
        detail.classList.toggle('show');
        btn.classList.toggle('open');
    }
</script>
</body>
</html>
