<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User, model.Report, model.StatusCount, model.RoleCount, java.util.List, java.sql.Timestamp, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || admin.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();

    // ===== STATS =====
    List<StatusCount> statusCounts = ops.getReportStatusCounts();
    int totalPending=0, totalProgress=0, totalResolved=0, totalOther=0;
    for (StatusCount sc : statusCounts) {
        String s = sc.getStatus();
        int    c = sc.getTotal();
        if      (s.equalsIgnoreCase("Pending"))                             totalPending  += c;
        else if (s.contains("Progress") || s.equalsIgnoreCase("Assigned")) totalProgress += c;
        else if (s.equalsIgnoreCase("Resolved"))                            totalResolved += c;
        else                                                                totalOther    += c;
    }
    int grandTotal = totalPending + totalProgress + totalResolved + totalOther;

    // ===== USER COUNTS =====
    List<RoleCount> roleCounts = ops.getUserCountsByRole();
    int totalCitizens=0, totalAuthorities=0, totalWorkers=0;
    for (RoleCount rc : roleCounts) {
        String role = rc.getRoleName();
        int    cnt  = rc.getTotal();
        if      ("CITIZEN".equals(role))   totalCitizens    = cnt;
        else if ("AUTHORITY".equals(role)) totalAuthorities = cnt;
        else if ("WORKER".equals(role))    totalWorkers     = cnt;
    }
    int totalUsers = totalCitizens + totalAuthorities + totalWorkers;

    int resolutionRate = (grandTotal > 0) ? (totalResolved * 100 / grandTotal) : 0;

    // ===== RECENT REPORTS =====
    List<Report> recentReports = ops.getAllReports();

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM");
%>
<!DOCTYPE html>
<html>
<head>
<title>Admin Dashboard | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== STAT CARDS ===== */
.stat-cards-row {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 14px;
    margin-bottom: 22px;
}

.stat-card-lg {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 18px 16px;
    text-align: center;
    transition: transform 0.2s, box-shadow 0.2s;
    position: relative;
    overflow: hidden;
}

.stat-card-lg:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-md);
}

.stat-card-lg::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
    background: var(--border-md);
}

.stat-card-lg.c-total::before    { background: var(--accent); }
.stat-card-lg.c-pending::before  { background: var(--gold); }
.stat-card-lg.c-progress::before { background: var(--accent); }
.stat-card-lg.c-resolved::before { background: var(--green); }
.stat-card-lg.c-users::before    { background: #a855f7; }

.stat-icon  { font-size: 26px; margin-bottom: 10px; }

.stat-num {
    font-size: 34px;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 5px;
}

.stat-card-lg.c-total    .stat-num { color: var(--text-1); }
.stat-card-lg.c-pending  .stat-num { color: var(--gold); }
.stat-card-lg.c-progress .stat-num { color: var(--accent); }
.stat-card-lg.c-resolved .stat-num { color: var(--green); }
.stat-card-lg.c-users    .stat-num { color: #a855f7; }

.stat-lbl {
    font-size: 12px;
    color: var(--text-3);
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* ===== RESOLUTION BAR ===== */
.res-bar-card {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 18px 20px;
    margin-bottom: 20px;
}

.res-bar-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
    flex-wrap: wrap;
    gap: 8px;
}

.res-bar-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-1);
    display: flex;
    align-items: center;
    gap: 8px;
}

.res-bar-pct {
    font-size: 22px;
    font-weight: 800;
    color: var(--green);
}

.res-bar-track {
    width: 100%;
    height: 12px;
    background: var(--bg-input);
    border-radius: var(--r-full);
    overflow: hidden;
}

.res-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
    background: linear-gradient(90deg, var(--green), var(--accent));
    transition: width 1.2s ease;
}

.res-bar-segments {
    display: flex;
    gap: 16px;
    margin-top: 10px;
    flex-wrap: wrap;
}

.res-seg {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: var(--text-3);
}

.res-seg-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
}

/* ===== MODULE CARDS ===== */
.module-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 14px;
    margin-bottom: 22px;
}

.module-card {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 20px 18px;
    transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
    display: flex;
    flex-direction: column;
}

.module-card:hover {
    transform: translateY(-3px);
    border-color: var(--border-blue);
    box-shadow: var(--shadow-md);
}

.module-icon {
    font-size: 30px;
    margin-bottom: 10px;
}

.module-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 6px;
}

.module-desc {
    font-size: 12px;
    color: var(--text-3);
    line-height: 1.55;
    margin-bottom: 16px;
    flex: 1;
}

/* ===== USER BREAKDOWN ===== */
.user-row {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 14px;
}

.user-row:last-child { margin-bottom: 0; }

.user-row-icon  { font-size: 20px; flex-shrink: 0; }
.user-row-label { flex: 1; font-size: 13px; color: var(--text-2); font-weight: 500; }

.user-row-count {
    font-size: 18px;
    font-weight: 700;
    min-width: 36px;
    text-align: right;
}

.user-bar-bg {
    width: 100%;
    height: 5px;
    background: var(--bg-input);
    border-radius: var(--r-full);
    margin-top: 5px;
    overflow: hidden;
}

.user-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
}

/* ===== RECENT TABLE ===== */
.admin-table {
    width: 100%;
    border-collapse: collapse;
}

.admin-table th {
    font-size: 11px;
    font-weight: 600;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 8px 12px;
    border-bottom: 1px solid var(--border-md);
    text-align: left;
    background: var(--bg-input);
}

.admin-table td {
    padding: 10px 12px;
    font-size: 13px;
    border-bottom: 1px solid var(--border);
    vertical-align: middle;
    color: var(--text-2);
}

.admin-table tr:last-child td { border-bottom: none; }

.admin-table tr:hover td {
    background: var(--accent-soft);
}

/* COMING SOON tag */
.tag-soon {
    display: inline-flex;
    align-items: center;
    padding: 5px 14px;
    border-radius: var(--r-full);
    background: rgba(245,158,11,0.08);
    border: 1px solid rgba(245,158,11,0.3);
    color: var(--gold);
    font-size: 11.5px;
    font-weight: 600;
}

/* ===== CONTENT SPLIT + MOBILE RESPONSIVE ===== */
.admin-split { display: grid; grid-template-columns: 340px 1fr; gap: 20px; margin-bottom: 22px; }
.table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; width: 100%; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 1100px) {
    .stat-cards-row { grid-template-columns: repeat(3, 1fr); }
}

@media (max-width: 992px) {
    .admin-split { grid-template-columns: 1fr; }
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
    .stat-cards-row { grid-template-columns: repeat(2, 1fr); }
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
        <a href="dashboard.jsp" class="active">Dashboard</a>
        <a href="all-reports.jsp">All Reports</a>
        <a href="users.jsp">Users</a>
        <a href="departments.jsp">Departments</a>
    </div>
    <div class="header-right">
        <div id="liveClock"
             style="font-size:12px; color:var(--text-3);
                    text-align:right; margin-right:12px; line-height:1.5;">
        </div>
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
            <a href="dashboard.jsp" class="sidebar-link active">
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
            <a href="resolution-predictor.jsp" class="sidebar-link">
                <span class="s-icon">⏱️</span> Resolution Predictor
            </a>
        </div>

        <!-- System Health -->
        <div class="sidebar-section">
            <div class="sidebar-label">System Health</div>
            <div style="display:flex; flex-direction:column;
                        gap:10px; padding:4px 0;">

                <div style="display:flex; justify-content:space-between;
                            align-items:center;">
                    <span style="font-size:12px; color:var(--text-3);">
                        Total Reports
                    </span>
                    <span style="font-weight:700; color:var(--text-1);">
                        <%= grandTotal %>
                    </span>
                </div>

                <div style="display:flex; justify-content:space-between;
                            align-items:center;">
                    <span style="font-size:12px; color:var(--text-3);">
                        Resolution Rate
                    </span>
                    <span style="font-weight:700; color:var(--green);">
                        <%= resolutionRate %>%
                    </span>
                </div>

                <div style="display:flex; justify-content:space-between;
                            align-items:center;">
                    <span style="font-size:12px; color:var(--text-3);">
                        Total Users
                    </span>
                    <span style="font-weight:700; color:#a855f7;">
                        <%= totalUsers %>
                    </span>
                </div>

                <!-- Mini bar -->
                <div style="margin-top:4px;">
                    <div style="font-size:11px; color:var(--text-3);
                                margin-bottom:5px;">
                        Resolution Progress
                    </div>
                    <div style="background:var(--bg-input);
                                border-radius:var(--r-full);
                                height:7px; overflow:hidden;">
                        <div style="height:100%;
                                    width:<%= resolutionRate %>%;
                                    background:var(--green);
                                    border-radius:var(--r-full);">
                        </div>
                    </div>
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
                    <span>Admin</span>
                    <span class="sep">›</span>
                    <span>Dashboard</span>
                </div>
                <h1>
                    👋 Welcome back,
                    <span style="color:var(--accent);">
                        <%= admin.getName() %>
                    </span>
                </h1>
                <p>
                    📧 <%= admin.getEmail() %>
                    &nbsp;·&nbsp;
                    🔐 Administrator
                    &nbsp;·&nbsp;
                    🖥️ System Governance & Monitoring
                </p>
            </div>
        </div>

        <!-- ===== STAT CARDS ===== -->
        <div class="stat-cards-row">

            <div class="stat-card-lg c-total">
                <div class="stat-icon">📋</div>
                <div class="stat-num"><%= grandTotal %></div>
                <div class="stat-lbl">Total Reports</div>
            </div>

            <div class="stat-card-lg c-pending">
                <div class="stat-icon">⏳</div>
                <div class="stat-num"><%= totalPending %></div>
                <div class="stat-lbl">Pending</div>
            </div>

            <div class="stat-card-lg c-progress">
                <div class="stat-icon">🔧</div>
                <div class="stat-num"><%= totalProgress %></div>
                <div class="stat-lbl">In Progress</div>
            </div>

            <div class="stat-card-lg c-resolved">
                <div class="stat-icon">✅</div>
                <div class="stat-num"><%= totalResolved %></div>
                <div class="stat-lbl">Resolved</div>
            </div>

            <div class="stat-card-lg c-users">
                <div class="stat-icon">👥</div>
                <div class="stat-num"><%= totalUsers %></div>
                <div class="stat-lbl">Total Users</div>
            </div>

        </div>

        <!-- ===== RESOLUTION BAR ===== -->
        <div class="res-bar-card">
            <div class="res-bar-header">
                <div class="res-bar-title">
                    📈 System Resolution Rate
                </div>
                <div>
                    <span class="res-bar-pct"><%= resolutionRate %>%</span>
                    <span style="font-size:12.5px; color:var(--text-3);
                                 margin-left:6px;">
                        (<%= totalResolved %> of <%= grandTotal %> resolved)
                    </span>
                </div>
            </div>
            <div class="res-bar-track">
                <div class="res-bar-fill"
                     style="width:<%= resolutionRate %>%;">
                </div>
            </div>
            <div class="res-bar-segments">
                <div class="res-seg">
                    <div class="res-seg-dot"
                         style="background:var(--gold);"></div>
                    Pending: <%= totalPending %>
                </div>
                <div class="res-seg">
                    <div class="res-seg-dot"
                         style="background:var(--accent);"></div>
                    In Progress: <%= totalProgress %>
                </div>
                <div class="res-seg">
                    <div class="res-seg-dot"
                         style="background:var(--green);"></div>
                    Resolved: <%= totalResolved %>
                </div>
                <div class="res-seg">
                    <div class="res-seg-dot"
                         style="background:var(--red);"></div>
                    Other: <%= totalOther %>
                </div>
            </div>
        </div>

        <!-- ===== TWO COL: USER BREAKDOWN + RECENT REPORTS ===== -->
        <div class="admin-split">

            <!-- USER BREAKDOWN -->
            <div class="lcps-card">
                <div class="card-header">
                    <h3><div class="card-icon">👥</div> User Breakdown</h3>
                    <a href="users.jsp" class="lcps-btn xs ghost">
                        View All →
                    </a>
                </div>
                <div class="card-body">

                    <div class="user-row">
                        <div class="user-row-icon">🧑‍💼</div>
                        <div style="flex:1;">
                            <div style="display:flex; justify-content:space-between;">
                                <span class="user-row-label">Citizens</span>
                                <span class="user-row-count"
                                      style="color:var(--accent);">
                                    <%= totalCitizens %>
                                </span>
                            </div>
                            <div class="user-bar-bg">
                                <div class="user-bar-fill"
                                     style="width:<%= totalUsers>0
                                            ? (totalCitizens*100/totalUsers)
                                            : 0 %>%;
                                            background:var(--accent);">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="user-row">
                        <div class="user-row-icon">👮</div>
                        <div style="flex:1;">
                            <div style="display:flex; justify-content:space-between;">
                                <span class="user-row-label">Authorities</span>
                                <span class="user-row-count"
                                      style="color:var(--gold);">
                                    <%= totalAuthorities %>
                                </span>
                            </div>
                            <div class="user-bar-bg">
                                <div class="user-bar-fill"
                                     style="width:<%= totalUsers>0
                                            ? (totalAuthorities*100/totalUsers)
                                            : 0 %>%;
                                            background:var(--gold);">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="user-row">
                        <div class="user-row-icon">🦺</div>
                        <div style="flex:1;">
                            <div style="display:flex; justify-content:space-between;">
                                <span class="user-row-label">Field Workers</span>
                                <span class="user-row-count"
                                      style="color:var(--green);">
                                    <%= totalWorkers %>
                                </span>
                            </div>
                            <div class="user-bar-bg">
                                <div class="user-bar-fill"
                                     style="width:<%= totalUsers>0
                                            ? (totalWorkers*100/totalUsers)
                                            : 0 %>%;
                                            background:var(--green);">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div style="border-top:1px solid var(--border);
                                margin-top:16px; padding-top:14px;
                                display:flex; gap:8px; flex-wrap:wrap;">
                        <a href="users.jsp" class="lcps-btn sm outline"
                           style="flex:1; text-align:center;">
                            👥 Manage Users
                        </a>
                        <a href="create-authority.jsp"
                           class="lcps-btn sm"
                           style="flex:1; text-align:center;">
                            ➕ Create Account
                        </a>
                    </div>

                </div>
            </div>

            <!-- RECENT REPORTS -->
            <div class="lcps-card">
                <div class="card-header">
                    <h3><div class="card-icon">🕐</div> Recent Reports</h3>
                    <a href="all-reports.jsp" class="lcps-btn xs ghost">
                        View All →
                    </a>
                </div>
                <div class="card-body" style="padding:0;">
                    <div class="table-wrap">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>#ID</th>
                                <th>Title</th>
                                <th>Status</th>
                                <th>Department</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            int count = 0;
                            for (Report rep : recentReports) {
                                if (count >= 7) break;
                                count++;
                                String rStatus  = rep.getStatus();
                                String stLow    = rStatus != null
                                                  ? rStatus.toLowerCase() : "";
                                String badgeCss =
                                    stLow.equals("pending")        ? "badge-pending"  :
                                    stLow.equals("assigned")       ? "badge-assigned" :
                                    stLow.contains("progress")     ? "badge-progress" :
                                    stLow.equals("resolved")       ? "badge-resolved" :
                                    stLow.contains("rework")       ? "badge-rework"   :
                                    "badge-rejected";

                                String titleStr = rep.getTitle();
                                if (titleStr != null && titleStr.length() > 28)
                                    titleStr = titleStr.substring(0,28) + "…";

                                String deptStr = rep.getDeptName();
                                if (deptStr != null && deptStr.length() > 14)
                                    deptStr = deptStr.substring(0,14) + "…";

                                java.sql.Timestamp rDate =
                                    rep.getCreatedAt();
                                String dateStr = rDate != null
                                                 ? sdf.format(rDate) : "—";
                        %>
                        <tr>
                            <td>
                                <a href="../citizen/view-report.jsp?id=<%= rep.getReportId() %>"
                                   style="color:var(--accent);
                                          font-weight:600;
                                          text-decoration:none;">
                                    #<%= rep.getReportId() %>
                                </a>
                            </td>
                            <td style="color:var(--text-1);">
                                <%= titleStr %>
                            </td>
                            <td>
                                <span class="badge <%= badgeCss %>">
                                    <span class="dot"></span>
                                    <%= rStatus != null &&
                                        rStatus.length() > 12
                                        ? rStatus.substring(0,12)+"…"
                                        : rStatus %>
                                </span>
                            </td>
                            <td><%= deptStr != null ? deptStr : "—" %></td>
                            <td style="color:var(--text-3);">
                                <%= dateStr %>
                            </td>
                        </tr>
                        <% } %>
                        <% if (count == 0) { %>
                        <tr>
                            <td colspan="5"
                                style="text-align:center;
                                       padding:30px;
                                       color:var(--text-3);">
                                No reports yet
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                    </div>
                </div>
            </div>

        </div>

        <!-- ===== MODULE CARDS ===== -->
        <div class="lcps-card" style="margin-bottom:22px;">
            <div class="card-header">
                <h3><div class="card-icon">⚙️</div> Admin Modules</h3>
            </div>
            <div class="card-body">
                <div class="module-grid">

                    <div class="module-card">
                        <div class="module-icon">📊</div>
                        <div class="module-title">All Reports</div>
                        <div class="module-desc">
                            View every report, filter by status,
                            reassign departments, track system-wide progress.
                        </div>
                        <a href="all-reports.jsp" class="lcps-btn sm">
                            Open →
                        </a>
                    </div>

                    <div class="module-card">
                        <div class="module-icon">👥</div>
                        <div class="module-title">User Management</div>
                        <div class="module-desc">
                            View all citizens, authorities and workers.
                            Filter by role and manage accounts.
                        </div>
                        <a href="users.jsp" class="lcps-btn sm">
                            Open →
                        </a>
                    </div>

                    <div class="module-card">
                        <div class="module-icon">👮</div>
                        <div class="module-title">Create Authority</div>
                        <div class="module-desc">
                            Register new authority supervisors or
                            field workers and assign to departments.
                        </div>
                        <a href="create-authority.jsp" class="lcps-btn sm">
                            Open →
                        </a>
                    </div>

                    <div class="module-card">
                        <div class="module-icon">🏢</div>
                        <div class="module-title">Departments</div>
                        <div class="module-desc">
                            View all civic departments with report
                            counts and activity overview.
                        </div>
                        <a href="departments.jsp" class="lcps-btn sm">
                            Open →
                        </a>
                    </div>

                    <div class="module-card">
                        <div class="module-icon">⏱️</div>
                        <div class="module-title">Resolution Predictor</div>
                        <div class="module-desc">
                            Avg resolution times per department
                            based on historical resolved reports.
                        </div>
                        <a href="resolution-predictor.jsp"
                           class="lcps-btn sm">
                            Open →
                        </a>
                    </div>

                    <div class="module-card">
                        <div class="module-icon">📈</div>
                        <div class="module-title">Analytics</div>
                        <div class="module-desc">
                            Resolution rates, performance metrics
                            and department heatmaps.
                        </div>
                        <span class="tag-soon">🔜 Coming Soon</span>
                    </div>

                    <div class="module-card">
                        <div class="module-icon">⚠️</div>
                        <div class="module-title">Escalations</div>
                        <div class="module-desc">
                            Handle citizen escalations, disputes
                            and authority overrides.
                        </div>
                        <span class="tag-soon">🔜 Coming Soon</span>
                    </div>

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

<script>
function updateClock() {
    const now    = new Date();
    const days   = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    const months = ["Jan","Feb","Mar","Apr","May","Jun",
                    "Jul","Aug","Sep","Oct","Nov","Dec"];
    let h    = now.getHours();
    const m  = String(now.getMinutes()).padStart(2,"0");
    const s  = String(now.getSeconds()).padStart(2,"0");
    const ap = h >= 12 ? "PM" : "AM";
    h = h % 12 || 12;

    document.getElementById("liveClock").innerHTML =
        `${days[now.getDay()]}, ${now.getDate()} ${months[now.getMonth()]} ${now.getFullYear()}<br>
         <strong style="color:var(--accent);">${h}:${m}:${s} ${ap}</strong>`;
}
updateClock();
setInterval(updateClock, 1000);
</script>

</body>
</html>
