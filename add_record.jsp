<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("userID") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MoonBae – Tambah Rekod</title>
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
        .nav-links a.active, .nav-links a:hover { background:#fff5e0; color:#f5a623; }
        .nav-links a.btn-add { background:linear-gradient(135deg,#f5a623,#f5823a); color:white; font-weight:600; }

        main { max-width:700px; margin:0 auto; padding:32px 20px; }

        .page-title {
            font-size:22px; font-weight:700; color:#333;
            margin-bottom:24px;
            display:flex; align-items:center; gap:10px;
        }
        .page-title i { color:#f5a623; }

        .alert {
            padding:14px 18px; border-radius:12px; margin-bottom:20px;
            font-size:14px; font-weight:500; display:flex; align-items:center; gap:10px;
        }
        .alert-error   { background:#fff0f0; color:#d93025; border:1px solid #ffc5c5; }
        .alert-success { background:#f0fff4; color:#2d7a4f; border:1px solid #b2f0cc; }

        .card {
            background:white; border-radius:20px;
            box-shadow:0 4px 20px rgba(0,0,0,0.07);
            overflow:hidden;
        }
        .card-header {
            background:linear-gradient(135deg,#fff5e0,#ffe0cc);
            padding:20px 28px;
            display:flex; align-items:center; gap:12px;
        }
        .card-header .hdr-icon {
            width:44px; height:44px;
            background:linear-gradient(135deg,#f5a623,#f5823a);
            border-radius:50%; display:flex; align-items:center; justify-content:center;
        }
        .card-header .hdr-icon i { color:white; font-size:18px; }
        .card-header h2 { font-size:18px; font-weight:700; color:#333; }
        .card-body { padding:28px; }

        /* ─── Form fields ─────────────────────── */
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:22px; }
        .form-group { margin-bottom:22px; }
        .form-group:last-child { margin-bottom:0; }

        label.field-label {
            display:block; font-size:13px; font-weight:700; color:#555;
            margin-bottom:8px; letter-spacing:0.3px;
        }
        label.field-label i { color:#f5a623; margin-right:6px; }

        input[type="date"], textarea, select {
            width:100%; padding:12px 16px;
            border:2px solid #f0e8d0; border-radius:12px;
            font-size:14px; outline:none; color:#333;
            transition:border-color 0.3s; font-family:inherit;
        }
        input[type="date"]:focus, textarea:focus { border-color:#f5a623; }
        textarea { resize:vertical; min-height:90px; }

        /* ─── Flow buttons ────────────────────── */
        .flow-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:10px; }
        .flow-btn { position:relative; }
        .flow-btn input[type="radio"] { display:none; }
        .flow-btn label {
            display:flex; flex-direction:column; align-items:center;
            padding:14px 10px; border:2px solid #f0e8d0;
            border-radius:14px; cursor:pointer; transition:all 0.25s;
            font-size:12px; font-weight:600; color:#888; gap:6px;
        }
        .flow-btn label i { font-size:20px; color:#f5a623; }
        .flow-btn input:checked + label {
            border-color:#f5a623;
            background:linear-gradient(135deg,#fff5e0,#ffe0cc);
            color:#e57315;
            box-shadow:0 2px 10px rgba(245,166,35,0.25);
        }
        .flow-btn label:hover { border-color:#f5a623; background:#fff9f0; }

        /* ─── Symptom checkboxes ──────────────── */
        .symptom-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; }
        .symptom-item input[type="checkbox"] { display:none; }
        .symptom-item label {
            display:flex; align-items:center; justify-content:center;
            padding:10px 8px; border:2px solid #f0e8d0;
            border-radius:12px; cursor:pointer; transition:all 0.25s;
            font-size:12px; font-weight:600; color:#777; text-align:center;
        }
        .symptom-item input:checked + label {
            border-color:#f48fb1; background:#fff0f7; color:#c2185b;
        }
        .symptom-item label:hover { border-color:#f5a623; background:#fff9f0; }

        /* ─── Buttons ─────────────────────────── */
        .btn-row { display:flex; gap:14px; margin-top:28px; }
        .btn-cancel {
            flex:1; padding:14px;
            border:2px solid #f0e8d0; background:white;
            border-radius:12px; font-size:14px; font-weight:600;
            color:#888; cursor:pointer; text-decoration:none;
            display:flex; align-items:center; justify-content:center; gap:8px;
            transition:all 0.2s;
        }
        .btn-cancel:hover { border-color:#f5a623; color:#f5a623; }
        .btn-save {
            flex:2; padding:14px;
            background:linear-gradient(135deg,#f5a623,#f5823a);
            border:none; border-radius:12px;
            font-size:15px; font-weight:700; color:white;
            cursor:pointer; transition:opacity 0.3s, transform 0.2s;
        }
        .btn-save:hover { opacity:0.9; transform:translateY(-1px); }

        @media(max-width:600px) {
            .form-row { grid-template-columns:1fr; }
            .symptom-grid { grid-template-columns:repeat(2,1fr); }
            .flow-grid { grid-template-columns:repeat(2,1fr); }
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
        <a href="<%= request.getContextPath() %>/tracking" class="btn-add active"><i class="fas fa-plus"></i> Tambah Rekod</a>
        <a href="<%= request.getContextPath() %>/history"><i class="fas fa-history"></i> Sejarah</a>
        <a href="<%= request.getContextPath() %>/auth?action=logout"><i class="fas fa-sign-out-alt"></i> Log Keluar</a>
    </div>
</nav>

<main>
    <div class="page-title"><i class="fas fa-plus-circle"></i> Tambah Rekod Haid</div>

    <!-- Mesej maklum balas -->
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error"><i class="fas fa-times-circle"></i> <%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %></div>
    <% } %>

    <div class="card">
        <div class="card-header">
            <div class="hdr-icon"><i class="fas fa-calendar-plus"></i></div>
            <div>
                <h2>Rekod Tempoh Haid Baru</h2>
                <p style="font-size:12px;color:#888;margin-top:2px">Isi maklumat kitaran anda dengan lengkap</p>
            </div>
        </div>
        <div class="card-body">
            <form method="post" action="<%= request.getContextPath() %>/tracking">

                <!-- Tarikh Mula & Tamat -->
                <div class="form-row">
                    <div class="form-group">
                        <label class="field-label"><i class="fas fa-calendar-day"></i> Tarikh Mula *</label>
                        <input type="date" name="startDate" required>
                    </div>
                    <div class="form-group">
                        <label class="field-label"><i class="fas fa-calendar-check"></i> Tarikh Tamat</label>
                        <input type="date" name="endDate">
                    </div>
                </div>

                <!-- Jenis Aliran Darah -->
                <div class="form-group">
                    <label class="field-label"><i class="fas fa-tint"></i> Jenis Aliran Darah</label>
                    <div class="flow-grid">
                        <div class="flow-btn">
                            <input type="radio" name="bloodFlowType" id="light" value="Light">
                            <label for="light"><i class="fas fa-tint"></i> Light</label>
                        </div>
                        <div class="flow-btn">
                            <input type="radio" name="bloodFlowType" id="medium" value="Medium" checked>
                            <label for="medium"><i class="fas fa-tint"></i> Medium</label>
                        </div>
                        <div class="flow-btn">
                            <input type="radio" name="bloodFlowType" id="heavy" value="Heavy">
                            <label for="heavy"><i class="fas fa-tint"></i> Heavy</label>
                        </div>
                        <div class="flow-btn">
                            <input type="radio" name="bloodFlowType" id="spotting" value="Spotting">
                            <label for="spotting"><i class="fas fa-circle"></i> Spotting</label>
                        </div>
                    </div>
                </div>

                <!-- Simptom -->
                <div class="form-group">
                    <label class="field-label"><i class="fas fa-heartbeat"></i> Simptom (pilih yang berkaitan)</label>
                    <div class="symptom-grid">
                        <% String[] symptoms = {"Cramps","Headache","Mood Swings","Fatigue","Bloating","Back Pain","Nausea","Breast Tenderness","Acne","Insomnia"};
                           for (String s : symptoms) { %>
                        <div class="symptom-item">
                            <input type="checkbox" name="symptoms" id="sym_<%= s.replace(" ","_") %>" value="<%= s %>">
                            <label for="sym_<%= s.replace(" ","_") %>"><%= s %></label>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Nota Tambahan -->
                <div class="form-group">
                    <label class="field-label"><i class="fas fa-sticky-note"></i> Nota Tambahan (pilihan)</label>
                    <textarea name="notes" placeholder="Tambah nota atau pemerhatian peribadi..."></textarea>
                </div>

                <!-- Butang Tindakan -->
                <div class="btn-row">
                    <a href="<%= request.getContextPath() %>/dashboard" class="btn-cancel">
                        <i class="fas fa-times"></i> Batal
                    </a>
                    <button type="submit" class="btn-save">
                        <i class="fas fa-save"></i> Simpan Rekod
                    </button>
                </div>

            </form>
        </div>
    </div>
</main>

<script>
    // Set tarikh mula lalai kepada hari ini
    document.querySelector('input[name="startDate"]').valueAsDate = new Date();
</script>
</body>
</html>

