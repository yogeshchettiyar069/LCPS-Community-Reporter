<%@ page import="model.User, model.DepartmentInfo, java.util.List, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || admin.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<DepartmentInfo> deptRows = ops.getAllDepartments();

    // Pre-collect
    String[] deptIcons = {"🛣️","⚡","💧","🗑️","🌳","🏗️","📦"};
    java.util.List<java.util.Map<String,Object>> depts = new java.util.ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");

    int totalReports = 0;
    int maxReports   = 1;

    for (DepartmentInfo di : deptRows) {
        java.util.Map<String,Object> d = new java.util.LinkedHashMap<>();
        int cnt = di.getTotalReports();
        d.put("deptId",   di.getDeptId());
        d.put("name",     di.getDeptName());
        d.put("count",    cnt);
        d.put("since",    di.getCreatedAt() != null
                          ? sdf.format(di.getCreatedAt()) : "—");
        depts.add(d);
        totalReports += cnt;
        if (cnt > maxReports) maxReports = cnt;
    }
%>
<!DOCTYPE html>
<html>
<head>
<title>Departments | Admin | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== DEPT CARDS GRID ===== */
.dept-cards-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 16px;
    margin-bottom: 24px;
}

.dept-card {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 22px 18px;
    text-align: center;
    transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
    position: relative;
    overflow: hidden;
}

.dept-card:hover {
    transform: translateY(-4px);
    border-color: var(--border-blue);
    box-shadow: var(--shadow-md);
}

/* Accent top bar cycles through colors */
.dept-card:nth-child(1)::before { background: var(--accent); }
.dept-card:nth-child(2)::before { background: var(--gold); }
.dept-card:nth-child(3)::before { background: #22d3ee; }
.dept-card:nth-child(4)::before { background: var(--green); }
.dept-card:nth-child(5)::before { background: #a855f7; }
.dept-card:nth-child(6)::before { background: var(--red); }
.dept-card:nth-child(7)::before { background: #f97316; }

.dept-card::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
}

.dept-icon {
    font-size: 36px;
    margin-bottom: 12px;
    line-height: 1;
}

.dept-name {
    font-size: 14.5px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 14px;
    line-height: 1.3;
}

.dept-count-wrap {
    margin-bottom: 12px;
}

.dept-count {
    font-size: 38px;
    font-weight: 800;
    color: var(--text-1);
    line-height: 1.1;
}

.dept-count-lbl {
    font-size: 11.5px;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-top: 3px;
}

/* Mini bar under count */
.dept-bar-track {
    width: 100%;
    height: 6px;
    background: var(--bg-input);
    border-radius: var(--r-full);
    overflow: hidden;
    margin: 10px 0 8px;
}

.dept-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
    background: var(--accent);
    transition: width 0.8s ease;
}

.dept-pct {
    font-size: 12px;
    color: var(--text-3);
}

.dept-since {
    font-size: 11.5px;
    color: var(--text-3);
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px solid var(--border);
}

/* ===== SUMMARY ROW ===== */
.summary-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
    margin-bottom: 22px;
}

.summary-chip {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 16px;
    text-align: center;
}

.summary-chip-num {
    font-size: 28px;
    font-weight: 800;
    color: var(--accent);
    margin-bottom: 4px;
}

.summary-chip-lbl {
    font-size: 12px;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.4px;
}

/* ===== TABLE VIEW ===== */
.dept-table {
    width: 100%;
    border-collapse: collapse;
}

.dept-table th {
    font-size: 11px;
    font-weight: 600;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 10px 14px;
    border-bottom: 1px solid var(--border-md);
    background: var(--bg-input);
    text-align: left;
}

.dept-table td {
    padding: 13px 14px;
    border-bottom: 1px solid var(--border);
    font-size: 13.5px;
    color: var(--text-2);
    vertical-align: middle;
}

.dept-table tr:last-child td { border-bottom: none; }
.dept-table tr:hover td      { background: var(--accent-soft); }

.inline-bar-track {
    flex: 1;
    height: 8px;
    background: var(--bg-input);
    border-radius: var(--r-full);
    overflow: hidden;
}

.inline-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
    background: linear-gradient(90deg, var(--accent), #6366f1);
}

/* ===== MOBILE RESPONSIVE ===== */
.table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; width: 100%; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 768px) {
    .mobile-menu-btn { display: block; }
    .header-nav { display: none; }
    .lcps-header { flex-wrap: wrap; justify-content: space-between; padding: 10px 15px; }
    .header-right { gap: 10px; }
    .lcps-layout { display: flex; flex-direction: column; }
    .lcps-sidebar { display: none; width: 100%; border-right: none; border-bottom: 1px solid var(--border); padding-bottom: 15px; }
    .lcps-sidebar.active { display: block; }
    .page-header { flex-direction: column; align-items: flex-start; gap: 15px; }
    .page-header .lcps-btn { width: 100%; text-align: center; justify-content: center; }
    .card-header { flex-direction: column; align-items: flex-start; gap: 10px; }
    .lcps-footer { flex-direction: column; text-align: center; gap: 10px; }
    .f-right { justify-content: center; }
}

@media (max-width: 600px) {
    .summary-row { grid-template-columns: 1fr; }
}
</style>
</head>
<body>

<!-- ===== HEADER ===== -->
<div class="lcps-header">
    <div style="display:flex; align-items:center; gap:10px;">
    <div class="mobile-menu-btn" onclick="document.querySelector('.lcps-sidebar').classList.toggle('active')">☰</div>
    <a href="dashboard.jsp" class="logo">
        <div class="logo-icon">🏛️</div>
        <div>
            <div class="logo-text-main">LC<span>PS</span></div>
            <div class="logo-text-sub">Community Problem Solver</div>
        </div>
    </a>
    </div>
    <div class="header-nav">
        <a href="dashboard.jsp">Dashboard</a>
        <a href="all-reports.jsp">All Reports</a>
        <a href="users.jsp">Users</a>
        <a href="departments.jsp" class="active">Departments</a>
    </div>
    <div class="header-right">
        <div class="user-chip">
            <div class="avatar">
                <%= admin.getName().substring(0,1).toUpperCase() %>
            </div>
            <div>
                <div class="user-info-name"><%= admin.getName() %></div>
                <div class="user-info-role">Admin</div>
            </div>
        </div>
    </div>
</div>

<!-- ===== LAYOUT ===== -->
<div class="lcps-layout">

    <!-- SIDEBAR -->
    <div class="lcps-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Admin</div>
            <a href="dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="all-reports.jsp" class="sidebar-link">
                <span class="s-icon">📋</span> All Reports
            </a>
            <a href="users.jsp" class="sidebar-link">
                <span class="s-icon">👥</span> Users
            </a>
            <a href="create-authority.jsp" class="sidebar-link">
                <span class="s-icon">➕</span> Create Account
            </a>
            <a href="departments.jsp" class="sidebar-link active">
                <span class="s-icon">🏢</span> Departments
            </a>
            <a href="resolution-predictor.jsp" class="sidebar-link">
                <span class="s-icon">⏱️</span> Resolution Predictor
            </a>
        </div>

        <!-- Dept summary -->
        <div class="sidebar-section">
            <div class="sidebar-label">Overview</div>
            <div style="display:flex; flex-direction:column;
                        gap:8px; padding:4px 0; font-size:13px;">
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Departments</span>
                    <span style="font-weight:700;
                                 color:var(--text-1);">
                        <%= depts.size() %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Total Reports</span>
                    <span style="font-weight:700; color:var(--accent);">
                        <%= totalReports %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Avg per Dept</span>
                    <span style="font-weight:700; color:var(--gold);">
                        <%= depts.size() > 0
                            ? (totalReports / depts.size()) : 0 %>
                    </span>
                </div>
            </div>
        </div>

        <div class="sidebar-divider"></div>
        <div class="sidebar-footer">
            <form action="<%=request.getContextPath()%>/auth"
                  method="post" style="margin:0;">
                <input type="hidden" name="action" value="logout">
                <button type="submit"
                        style="background:none; border:none; cursor:pointer;
                               color:var(--red); font-size:13px; padding:0;
                               display:flex; align-items:center; gap:6px;">
                    🚪 Logout
                </button>
            </form>
        </div>
    </div>

    <!-- ===== MAIN ===== -->
    <div class="lcps-main">

        <!-- PAGE HEADER -->
        <div class="page-header">
            <div class="page-header-left">
                <div class="breadcrumb">
                    <a href="dashboard.jsp">Admin</a>
                    <span class="sep">›</span>
                    <span>Departments</span>
                </div>
                <h1>Department Overview</h1>
                <p>
                    <strong style="color:var(--text-1);">
                        <%= depts.size() %> active departments
                    </strong>
                    — reports are routed based on citizen category selection.
                </p>
            </div>
            <a href="all-reports.jsp" class="lcps-btn ghost">
                📋 All Reports
            </a>
        </div>

        <!-- SUMMARY ROW -->
        <div class="summary-row">
            <div class="summary-chip">
                <div class="summary-chip-num"><%= depts.size() %></div>
                <div class="summary-chip-lbl">Departments</div>
            </div>
            <div class="summary-chip">
                <div class="summary-chip-num"
                     style="color:var(--green);">
                    <%= totalReports %>
                </div>
                <div class="summary-chip-lbl">Total Reports</div>
            </div>
            <div class="summary-chip">
                <div class="summary-chip-num"
                     style="color:var(--gold);">
                    <%= depts.size() > 0
                        ? (totalReports / depts.size()) : 0 %>
                </div>
                <div class="summary-chip-lbl">Avg per Dept</div>
            </div>
        </div>

        <!-- DEPT CARDS -->
        <div class="dept-cards-grid">
        <%
            for (int i = 0; i < depts.size(); i++) {
                java.util.Map<String,Object> d = depts.get(i);
                String dName  = (String) d.get("name");
                int    dCount = (int)    d.get("count");
                String dSince = (String) d.get("since");
                String icon   = (i < deptIcons.length)
                                ? deptIcons[i] : "🏢";
                int barPct    = (maxReports > 0)
                                ? (dCount * 100 / maxReports) : 0;
                int totalPct  = (totalReports > 0)
                                ? (dCount * 100 / totalReports) : 0;
        %>
        <div class="dept-card">
            <div class="dept-icon"><%= icon %></div>
            <div class="dept-name"><%= dName %></div>
            <div class="dept-count-wrap">
                <div class="dept-count"><%= dCount %></div>
                <div class="dept-count-lbl">Total Reports</div>
            </div>
            <div class="dept-bar-track">
                <div class="dept-bar-fill"
                     style="width:<%= barPct %>%;">
                </div>
            </div>
            <div class="dept-pct">
                <%= totalPct %>% of all reports
            </div>
            <div class="dept-since">
                Active since <%= dSince %>
            </div>
        </div>
        <% } %>
        <% if (depts.isEmpty()) { %>
        <div style="grid-column:1/-1; text-align:center;
                    color:var(--text-3); padding:40px;">
            No departments found.
        </div>
        <% } %>
        </div>

        <!-- TABLE VIEW -->
        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📊</div>
                    Department Breakdown
                </h3>
                <span style="font-size:12.5px; color:var(--text-3);">
                    <%= totalReports %> total reports across
                    <%= depts.size() %> departments
                </span>
            </div>
            <div class="card-body" style="padding:0;">
                <div class="table-wrap">
                <table class="dept-table">
                    <thead>
                        <tr>
                            <th>Department</th>
                            <th>Reports</th>
                            <th style="width:200px;">Share</th>
                            <th>% Total</th>
                            <th>Active Since</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for (int i = 0; i < depts.size(); i++) {
                            java.util.Map<String,Object> d = depts.get(i);
                            String dName  = (String) d.get("name");
                            int    dCount = (int)    d.get("count");
                            String dSince = (String) d.get("since");
                            String icon   = (i < deptIcons.length)
                                            ? deptIcons[i] : "🏢";
                            int barPct   = (maxReports > 0)
                                           ? (dCount * 100 / maxReports) : 0;
                            int totalPct = (totalReports > 0)
                                           ? (dCount * 100 / totalReports) : 0;
                    %>
                    <tr>
                        <td>
                            <div style="display:flex; align-items:center;
                                        gap:10px;">
                                <span style="font-size:20px;"><%= icon %></span>
                                <span style="font-weight:600;
                                             color:var(--text-1);">
                                    <%= dName %>
                                </span>
                            </div>
                        </td>
                        <td>
                            <span style="font-weight:700;
                                         font-size:16px;
                                         color:var(--accent);">
                                <%= dCount %>
                            </span>
                        </td>
                        <td>
                            <div style="display:flex; align-items:center;
                                        gap:10px;">
                                <div class="inline-bar-track">
                                    <div class="inline-bar-fill"
                                         style="width:<%= barPct %>%;">
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span style="font-size:13px;
                                         color:var(--text-2);
                                         font-weight:600;">
                                <%= totalPct %>%
                            </span>
                        </td>
                        <td style="color:var(--text-3);">
                            <%= dSince %>
                        </td>
                    </tr>
                    <% } %>
                    <% if (depts.isEmpty()) { %>
                    <tr>
                        <td colspan="5"
                            style="text-align:center;
                                   padding:40px;
                                   color:var(--text-3);">
                            No departments found.
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- ===== FOOTER ===== -->
<div class="lcps-footer">
    <div class="f-left">
        © 2026 <span>LCPS</span> — Local Community Problem Solver
    </div>
    <div class="f-right">
        <a href="#">Help</a>
        <a href="#">Privacy</a>
        <span>v2.0</span>
    </div>
</div>

</body>
</html>
