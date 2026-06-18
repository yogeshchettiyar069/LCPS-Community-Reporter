<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User, model.DeptResolution, java.util.List, operations.ReportOperations" %>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || admin.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<DeptResolution> resolutionRows = ops.getAvgResolutionTimeByDept();

    // Pre-collect
    String[] deptIcons = {"🛣️","⚡","💧","🗑️","🌳","🏗️","📦"};

    java.util.List<String>  deptNames = new java.util.ArrayList<>();
    java.util.List<Double>  avgHours  = new java.util.ArrayList<>();
    java.util.List<Integer> resolved  = new java.util.ArrayList<>();

    double maxHours     = 1;
    int    totalResolved = 0;
    double totalHours   = 0;
    int    fastCount    = 0, avgCount = 0, slowCount = 0;

    for (DeptResolution dr : resolutionRows) {
        double avg = dr.getAvgHours();
        int    cnt = dr.getTotalResolved();
        deptNames.add(dr.getDeptName());
        avgHours.add(avg);
        resolved.add(cnt);
        if (avg > maxHours) maxHours = avg;
        totalResolved += cnt;
        if (avg > 0) {
            totalHours += avg;
            if      (avg <= 48)  fastCount++;
            else if (avg <= 120) avgCount++;
            else                 slowCount++;
        }
    }

    double overallAvg = deptNames.size() > 0
                        ? (totalHours / deptNames.size()) : 0;
%>
<!DOCTYPE html>
<html>
<head>
<title>Resolution Predictor | Admin | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== SUMMARY CHIPS ===== */
.pred-summary {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 22px;
}

.pred-chip {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 16px 14px;
    text-align: center;
    position: relative;
    overflow: hidden;
}

.pred-chip::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
}

.pred-chip.c-total::before   { background: var(--accent); }
.pred-chip.c-fast::before    { background: var(--green); }
.pred-chip.c-avg::before     { background: var(--gold); }
.pred-chip.c-slow::before    { background: var(--red); }

.pred-chip-num {
    font-size: 26px;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 4px;
}

.pred-chip.c-total .pred-chip-num { color: var(--accent); }
.pred-chip.c-fast  .pred-chip-num { color: var(--green); }
.pred-chip.c-avg   .pred-chip-num { color: var(--gold); }
.pred-chip.c-slow  .pred-chip-num { color: var(--red); }

.pred-chip-lbl {
    font-size: 11.5px;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.4px;
}

/* ===== DEPT CARDS ===== */
.pred-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
    margin-bottom: 22px;
}

.pred-card {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 20px 18px;
    transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
    position: relative;
    overflow: hidden;
}

.pred-card:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-md);
}

.pred-card::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
}

.pred-card.speed-fast   { border-color: rgba(16,185,129,0.2); }
.pred-card.speed-fast::before   { background: var(--green); }
.pred-card.speed-avg    { border-color: rgba(245,158,11,0.2); }
.pred-card.speed-avg::before    { background: var(--gold); }
.pred-card.speed-slow   { border-color: rgba(239,68,68,0.2); }
.pred-card.speed-slow::before   { background: var(--red); }
.pred-card.speed-nodata::before { background: var(--border-md); }

.pred-icon {
    font-size: 30px;
    margin-bottom: 10px;
}

.pred-dept-name {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 6px;
}

/* Speed badge */
.speed-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 10px;
    border-radius: var(--r-full);
    font-size: 11.5px;
    font-weight: 600;
    margin-bottom: 12px;
}

.speed-badge.fast   {
    background: rgba(16,185,129,0.1);
    color: var(--green);
    border: 1px solid rgba(16,185,129,0.3);
}
.speed-badge.avg    {
    background: rgba(245,158,11,0.1);
    color: var(--gold);
    border: 1px solid rgba(245,158,11,0.3);
}
.speed-badge.slow   {
    background: rgba(239,68,68,0.1);
    color: var(--red);
    border: 1px solid rgba(239,68,68,0.3);
}
.speed-badge.nodata {
    background: var(--bg-input);
    color: var(--text-3);
    border: 1px solid var(--border-md);
}

.pred-time {
    font-size: 30px;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 3px;
}

.pred-time-lbl {
    font-size: 12px;
    color: var(--text-3);
    margin-bottom: 12px;
}

.pred-base {
    font-size: 12px;
    color: var(--text-3);
    margin-bottom: 10px;
}

.pred-base strong { color: var(--accent); }

/* Speed bar */
.pred-bar-track {
    width: 100%;
    height: 6px;
    background: var(--bg-input);
    border-radius: var(--r-full);
    overflow: hidden;
    margin-top: 8px;
}

.pred-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
    transition: width 1s ease;
}

/* ===== PERFORMANCE TABLE ===== */
.pred-table {
    width: 100%;
    border-collapse: collapse;
}

.pred-table th {
    font-size: 11px;
    font-weight: 600;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 10px 14px;
    border-bottom: 1px solid var(--border-md);
    background: var(--bg-input);
    text-align: left;
    white-space: nowrap;
}

.pred-table td {
    padding: 12px 14px;
    font-size: 13.5px;
    border-bottom: 1px solid var(--border);
    color: var(--text-2);
    vertical-align: middle;
}

.pred-table tr:last-child td { border-bottom: none; }
.pred-table tr:hover td      { background: var(--accent-soft); }

/* Inline table bar */
.tbl-bar-wrap {
    display: flex;
    align-items: center;
    gap: 10px;
}

.tbl-bar-track {
    flex: 1;
    height: 7px;
    background: var(--bg-input);
    border-radius: var(--r-full);
    overflow: hidden;
}

.tbl-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
}

/* Legend */
.legend-row {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    margin-bottom: 16px;
}

.legend-item {
    display: flex;
    align-items: center;
    gap: 7px;
    font-size: 12.5px;
    color: var(--text-3);
}

.legend-dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
}

/* ===== MOBILE RESPONSIVE ===== */
.table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; width: 100%; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 992px) {
    .pred-summary { grid-template-columns: repeat(2, 1fr); }
}

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
    .legend-row { gap: 12px; }
    .lcps-footer { flex-direction: column; text-align: center; gap: 10px; }
    .f-right { justify-content: center; }
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
        <a href="departments.jsp">Departments</a>
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
            <a href="departments.jsp" class="sidebar-link">
                <span class="s-icon">🏢</span> Departments
            </a>
            <a href="resolution-predictor.jsp" class="sidebar-link active">
                <span class="s-icon">⏱️</span> Resolution Predictor
            </a>
        </div>

        <!-- How it works -->
        <div class="sidebar-section">
            <div class="sidebar-label">How It Works</div>
            <div style="font-size:12.5px; color:var(--text-3);
                        line-height:1.7; padding:4px 0;">
                <div style="margin-bottom:8px;">
                    ⚡ <strong style="color:var(--green);">Fast</strong>
                    — resolved within 48 hrs
                </div>
                <div style="margin-bottom:8px;">
                    🕐 <strong style="color:var(--gold);">Average</strong>
                    — 48–120 hrs
                </div>
                <div>
                    🐢 <strong style="color:var(--red);">Slow</strong>
                    — over 120 hrs
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
                    <span>Resolution Predictor</span>
                </div>
                <h1>⏱️ Resolution Time Predictor</h1>
                <p>
                    Historical resolution averages per department —
                    shown to citizens as estimated completion time.
                </p>
            </div>
            <a href="departments.jsp" class="lcps-btn ghost">
                🏢 Departments
            </a>
        </div>

        <!-- SUMMARY CHIPS -->
        <div class="pred-summary">

            <div class="pred-chip c-total">
                <div class="pred-chip-num"><%= totalResolved %></div>
                <div class="pred-chip-lbl">Reports Analysed</div>
            </div>

            <div class="pred-chip c-fast">
                <div class="pred-chip-num"><%= fastCount %></div>
                <div class="pred-chip-lbl">⚡ Fast Depts</div>
            </div>

            <div class="pred-chip c-avg">
                <div class="pred-chip-num"><%= avgCount %></div>
                <div class="pred-chip-lbl">🕐 Average Depts</div>
            </div>

            <div class="pred-chip c-slow">
                <div class="pred-chip-num"><%= slowCount %></div>
                <div class="pred-chip-lbl">🐢 Slow Depts</div>
            </div>

        </div>

        <!-- DEPT CARDS -->
        <% if (deptNames.isEmpty()) { %>
        <div class="lcps-card" style="margin-bottom:22px;">
            <div class="card-body" style="text-align:center;
                                          padding:50px 20px;">
                <div style="font-size:48px; margin-bottom:14px;">📭</div>
                <div style="font-size:16px; font-weight:600;
                             color:var(--text-2); margin-bottom:8px;">
                    No Data Yet
                </div>
                <div style="font-size:13.5px; color:var(--text-3);">
                    Predictions will appear once reports are resolved.
                </div>
            </div>
        </div>
        <% } else { %>
        <div class="pred-grid">
        <%
            for (int i = 0; i < deptNames.size(); i++) {
                double hrs     = avgHours.get(i);
                int    cnt     = resolved.get(i);
                String icon    = (i < deptIcons.length) ? deptIcons[i] : "🏢";
                String timeStr = ReportOperations.formatResolutionTime(hrs);

                String speedCss, speedLabel, barColor;
                int    barWidth;

                if (hrs <= 0) {
                    speedCss   = "nodata";
                    speedLabel = "No Data";
                    barColor   = "var(--border-md)";
                    barWidth   = 0;
                } else if (hrs <= 48) {
                    speedCss   = "fast";
                    speedLabel = "⚡ Fast";
                    barColor   = "var(--green)";
                    barWidth   = Math.max(20, 100 - (int)(hrs / maxHours * 100));
                } else if (hrs <= 120) {
                    speedCss   = "avg";
                    speedLabel = "🕐 Average";
                    barColor   = "var(--gold)";
                    barWidth   = Math.max(15, 100 - (int)(hrs / maxHours * 70));
                } else {
                    speedCss   = "slow";
                    speedLabel = "🐢 Slow";
                    barColor   = "var(--red)";
                    barWidth   = 20;
                }

                String timeColor =
                    hrs <= 0   ? "var(--text-3)"  :
                    hrs <= 48  ? "var(--green)"   :
                    hrs <= 120 ? "var(--gold)"    :
                    "var(--red)";
        %>
        <div class="pred-card speed-<%= speedCss %>">
            <div class="pred-icon"><%= icon %></div>
            <div class="pred-dept-name"><%= deptNames.get(i) %></div>
            <span class="speed-badge <%= speedCss %>">
                <%= speedLabel %>
            </span>
            <div class="pred-time"
                 style="color:<%= timeColor %>;">
                <%= hrs > 0 ? timeStr : "—" %>
            </div>
            <div class="pred-time-lbl">
                Average resolution time
            </div>
            <div class="pred-base">
                Based on
                <strong><%= cnt %></strong>
                resolved report<%= cnt != 1 ? "s" : "" %>
            </div>
            <div class="pred-bar-track">
                <div class="pred-bar-fill"
                     style="width:<%= barWidth %>%;
                            background:<%= barColor %>;">
                </div>
            </div>
        </div>
        <% } %>
        </div>
        <% } %>

        <!-- PERFORMANCE TABLE -->
        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📋</div>
                    Performance Table
                </h3>
                <div class="legend-row" style="margin-bottom:0;">
                    <div class="legend-item">
                        <div class="legend-dot"
                             style="background:var(--green);">
                        </div>
                        Fast (&lt;48 hrs)
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot"
                             style="background:var(--gold);">
                        </div>
                        Average (48–120 hrs)
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot"
                             style="background:var(--red);">
                        </div>
                        Slow (&gt;120 hrs)
                    </div>
                </div>
            </div>
            <div class="card-body" style="padding:0;">
                <div class="table-wrap">
                <table class="pred-table">
                    <thead>
                        <tr>
                            <th>Department</th>
                            <th>Avg Resolution</th>
                            <th>Raw (hrs)</th>
                            <th style="width:180px;">Speed</th>
                            <th>Resolved</th>
                            <th>Performance</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (deptNames.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6"
                            style="text-align:center;
                                   padding:40px;
                                   color:var(--text-3);">
                            No resolved reports yet.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (int i = 0; i < deptNames.size(); i++) {
                                double hrs     = avgHours.get(i);
                                int    cnt     = resolved.get(i);
                                String icon    = (i < deptIcons.length) ? deptIcons[i] : "🏢";
                                String timeStr = ReportOperations.formatResolutionTime(hrs);

                                String speedCss, speedLabel, barColor;
                                int    barW;

                                if (hrs <= 0) {
                                    speedCss   = "nodata"; speedLabel = "No Data";
                                    barColor   = "var(--border-md)"; barW = 0;
                                } else if (hrs <= 48) {
                                    speedCss   = "fast"; speedLabel = "⚡ Fast";
                                    barColor   = "var(--green)";
                                    barW = Math.max(20, 100 - (int)(hrs/maxHours*100));
                                } else if (hrs <= 120) {
                                    speedCss   = "avg"; speedLabel = "🕐 Average";
                                    barColor   = "var(--gold)";
                                    barW = Math.max(15, 100 - (int)(hrs/maxHours*70));
                                } else {
                                    speedCss   = "slow"; speedLabel = "🐢 Slow";
                                    barColor   = "var(--red)"; barW = 20;
                                }
                    %>
                    <tr>
                        <td>
                            <div style="display:flex; align-items:center;
                                        gap:10px;">
                                <span style="font-size:18px;">
                                    <%= icon %>
                                </span>
                                <span style="font-weight:600;
                                             color:var(--text-1);">
                                    <%= deptNames.get(i) %>
                                </span>
                            </div>
                        </td>
                        <td>
                            <span style="font-weight:700;
                                         font-size:15px;
                                         color:<%= hrs<=0?"var(--text-3)":hrs<=48?"var(--green)":hrs<=120?"var(--gold)":"var(--red)" %>;">
                                <%= hrs > 0 ? timeStr : "—" %>
                            </span>
                        </td>
                        <td style="color:var(--text-3);">
                            <%= hrs > 0
                                ? String.format("%.1f", hrs) + " hrs"
                                : "—" %>
                        </td>
                        <td>
                            <div class="tbl-bar-wrap">
                                <div class="tbl-bar-track">
                                    <div class="tbl-bar-fill"
                                         style="width:<%= barW %>%;
                                                background:<%= barColor %>;">
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span style="font-weight:700;
                                         color:var(--accent);">
                                <%= cnt %>
                            </span>
                        </td>
                        <td>
                            <span class="speed-badge <%= speedCss %>">
                                <%= speedLabel %>
                            </span>
                        </td>
                    </tr>
                    <% } } %>
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
