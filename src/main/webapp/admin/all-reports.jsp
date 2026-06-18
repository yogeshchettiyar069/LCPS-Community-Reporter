<%@ page import="model.User, model.Report, model.StatusCount, model.DeptReportCount, java.util.List, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || admin.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<DeptReportCount> deptCountRows = ops.getReportsByDeptCount();
    List<StatusCount> statusCounts = ops.getReportStatusCounts();
    List<Report> allReports = ops.getAllReports();

    // Status counts
    int totalPending=0, totalProgress=0, totalResolved=0, totalOther=0;
    for (StatusCount sc : statusCounts) {
        String s = sc.getStatus();
        int cnt  = sc.getTotal();
        if      (s.equalsIgnoreCase("Pending"))                              totalPending  += cnt;
        else if (s.contains("Progress") || s.equalsIgnoreCase("Assigned"))  totalProgress += cnt;
        else if (s.equalsIgnoreCase("Resolved"))                             totalResolved += cnt;
        else                                                                 totalOther    += cnt;
    }
    int grandTotal = totalPending + totalProgress + totalResolved + totalOther;

    // Dept bar — pre-collect
    java.util.List<String> deptNames  = new java.util.ArrayList<>();
    java.util.List<Integer> deptCounts = new java.util.ArrayList<>();
    int deptMax = 1;
    for (DeptReportCount d : deptCountRows) {
        int dc = d.getTotalReports();
        deptNames.add(d.getDeptName());
        deptCounts.add(dc);
        if (dc > deptMax) deptMax = dc;
    }

    // All reports — pre-collect
    java.util.List<java.util.Map<String,Object>> reports = new java.util.ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    for (Report rep : allReports) {
        java.util.Map<String,Object> row = new java.util.LinkedHashMap<>();
        row.put("reportId",    rep.getReportId());
        row.put("title",       rep.getTitle());
        row.put("citizen",     rep.getCitizenName());
        row.put("dept",        rep.getDeptName());
        row.put("deptId",      rep.getDeptId());
        row.put("severity",    rep.getSeverity());
        row.put("status",      rep.getStatus());
        row.put("createdAt",   rep.getCreatedAt() != null
                               ? sdf.format(rep.getCreatedAt()) : "—");
        reports.add(row);
    }

    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");
%>
<!DOCTYPE html>
<html>
<head>
<title>All Reports | Admin | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== STAT CARDS ===== */
.stat-cards-row {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 12px;
    margin-bottom: 20px;
}

.stat-mini {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 14px 12px;
    text-align: center;
    position: relative;
    overflow: hidden;
    transition: transform 0.18s;
    cursor: pointer;
}

.stat-mini:hover { transform: translateY(-2px); }

.stat-mini::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
}

.stat-mini.c-all::before      { background: var(--text-3); }
.stat-mini.c-pending::before  { background: var(--gold); }
.stat-mini.c-progress::before { background: var(--accent); }
.stat-mini.c-resolved::before { background: var(--green); }
.stat-mini.c-other::before    { background: var(--red); }

.stat-mini-num {
    font-size: 28px;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 4px;
}

.stat-mini.c-all      .stat-mini-num { color: var(--text-1); }
.stat-mini.c-pending  .stat-mini-num { color: var(--gold); }
.stat-mini.c-progress .stat-mini-num { color: var(--accent); }
.stat-mini.c-resolved .stat-mini-num { color: var(--green); }
.stat-mini.c-other    .stat-mini-num { color: var(--red); }

.stat-mini-lbl {
    font-size: 11.5px;
    color: var(--text-3);
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-weight: 500;
}

/* ===== DEPT BARS ===== */
.dept-bars { display: flex; flex-direction: column; gap: 10px; }

.dept-bar-row {
    display: flex;
    align-items: center;
    gap: 12px;
}

.dept-bar-name {
    width: 160px;
    font-size: 13px;
    color: var(--text-2);
    font-weight: 500;
    flex-shrink: 0;
}

.dept-bar-track {
    flex: 1;
    background: var(--bg-input);
    border-radius: var(--r-full);
    height: 10px;
    overflow: hidden;
}

.dept-bar-fill {
    height: 100%;
    border-radius: var(--r-full);
    background: linear-gradient(90deg, var(--accent), #6366f1);
    transition: width 0.8s ease;
}

.dept-bar-count {
    width: 32px;
    text-align: right;
    font-size: 13px;
    font-weight: 700;
    color: var(--accent);
}

/* ===== FILTER BAR ===== */
.filter-row {
    display: flex;
    gap: 8px;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 16px;
}

.filter-chip {
    padding: 6px 16px;
    border-radius: var(--r-full);
    border: 1px solid var(--border-md);
    background: var(--bg-input);
    color: var(--text-2);
    font-size: 12.5px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.18s;
}

.filter-chip:hover  { border-color: var(--border-blue); color: var(--accent); }
.filter-chip.active { background: var(--accent); border-color: var(--accent); color: #fff; }
.filter-chip.f-pending.active  { background: var(--gold);  border-color: var(--gold);  color: #000; }
.filter-chip.f-resolved.active { background: var(--green); border-color: var(--green); color: #fff; }
.filter-chip.f-other.active    { background: var(--red);   border-color: var(--red);   color: #fff; }

.search-wrap {
    margin-left: auto;
    position: relative;
}

.search-wrap input {
    background: var(--bg-input);
    border: 1px solid var(--border-md);
    border-radius: var(--r-full);
    padding: 7px 14px 7px 34px;
    font-size: 13px;
    color: var(--text-1);
    width: 200px;
    outline: none;
    transition: border-color 0.2s;
}

.search-wrap input:focus { border-color: var(--border-blue); }

.search-icon {
    position: absolute;
    left: 11px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 14px;
    color: var(--text-3);
    pointer-events: none;
}

.results-count {
    font-size: 12.5px;
    color: var(--text-3);
    white-space: nowrap;
}

/* ===== ADMIN TABLE ===== */
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
    padding: 10px 12px;
    border-bottom: 1px solid var(--border-md);
    text-align: left;
    background: var(--bg-input);
    white-space: nowrap;
    cursor: pointer;
    user-select: none;
}

.admin-table th:hover { color: var(--text-1); }

.admin-table td {
    padding: 11px 12px;
    font-size: 13px;
    border-bottom: 1px solid var(--border);
    vertical-align: middle;
    color: var(--text-2);
}

.admin-table tr:last-child td { border-bottom: none; }
.admin-table tr:hover td { background: var(--accent-soft); }

/* Reassign select */
.reassign-form {
    display: flex;
    align-items: center;
    gap: 6px;
}

.reassign-select {
    background: var(--bg-input);
    border: 1px solid var(--border-md);
    border-radius: var(--r-sm);
    color: var(--text-1);
    font-size: 12px;
    padding: 5px 8px;
    outline: none;
    cursor: pointer;
    transition: border-color 0.18s;
    max-width: 120px;
}

.reassign-select:focus { border-color: var(--border-blue); }

.reassign-btn {
    background: var(--accent);
    border: none;
    border-radius: var(--r-sm);
    color: #fff;
    font-size: 12px;
    font-weight: 600;
    padding: 5px 10px;
    cursor: pointer;
    transition: opacity 0.18s;
    white-space: nowrap;
}

.reassign-btn:hover { opacity: 0.85; }

/* ===== MOBILE RESPONSIVE ===== */
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 1100px) {
    .stat-cards-row { grid-template-columns: repeat(3, 1fr); }
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
    .search-wrap { margin-left: 0; width: 100%; }
    .search-wrap input { width: 100%; box-sizing: border-box; }
    .dept-bar-name { width: 110px; font-size: 12px; }
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
        <a href="all-reports.jsp" class="active">All Reports</a>
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
            <a href="all-reports.jsp" class="sidebar-link active">
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

        <!-- Report Counts -->
        <div class="sidebar-section">
            <div class="sidebar-label">Counts</div>
            <div style="display:flex; flex-direction:column;
                        gap:8px; padding:4px 0; font-size:13px;">
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Total</span>
                    <span style="font-weight:700; color:var(--text-1);">
                        <%= grandTotal %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Pending</span>
                    <span style="font-weight:700; color:var(--gold);">
                        <%= totalPending %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">In Progress</span>
                    <span style="font-weight:700; color:var(--accent);">
                        <%= totalProgress %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Resolved</span>
                    <span style="font-weight:700; color:var(--green);">
                        <%= totalResolved %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Other</span>
                    <span style="font-weight:700; color:var(--red);">
                        <%= totalOther %>
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
                    <span>All Reports</span>
                </div>
                <h1>System-Wide Reports</h1>
                <p>View, filter and reassign all reports across departments.</p>
            </div>
            <a href="dashboard.jsp" class="lcps-btn ghost">← Dashboard</a>
        </div>

        <!-- FLASH -->
        <% if (flash != null && !flash.isEmpty()) { %>
        <div class="lcps-alert <%= "error".equals(flashType) ? "error" : "success" %>"
             style="margin-bottom:20px;">
            <span class="alert-icon">
                <%= "error".equals(flashType) ? "⚠️" : "✅" %>
            </span>
            <%= flash %>
        </div>
        <% } %>
        <% if ("true".equals(request.getParameter("reassigned"))) { %>
        <div class="lcps-alert success" style="margin-bottom:20px;">
            <span class="alert-icon">✅</span>
            Report successfully reassigned to new department.
        </div>
        <% } %>

        <!-- STAT CARDS -->
        <div class="stat-cards-row">
            <div class="stat-mini c-all"
                 onclick="filterTable('all', this)">
                <div class="stat-mini-num"><%= grandTotal %></div>
                <div class="stat-mini-lbl">Total</div>
            </div>
            <div class="stat-mini c-pending"
                 onclick="filterTable('pending', this)">
                <div class="stat-mini-num"><%= totalPending %></div>
                <div class="stat-mini-lbl">Pending</div>
            </div>
            <div class="stat-mini c-progress"
                 onclick="filterTable('progress', this)">
                <div class="stat-mini-num"><%= totalProgress %></div>
                <div class="stat-mini-lbl">In Progress</div>
            </div>
            <div class="stat-mini c-resolved"
                 onclick="filterTable('resolved', this)">
                <div class="stat-mini-num"><%= totalResolved %></div>
                <div class="stat-mini-lbl">Resolved</div>
            </div>
            <div class="stat-mini c-other"
                 onclick="filterTable('other', this)">
                <div class="stat-mini-num"><%= totalOther %></div>
                <div class="stat-mini-lbl">Other</div>
            </div>
        </div>

        <!-- DEPT BAR CHART -->
        <div class="lcps-card" style="margin-bottom:20px;">
            <div class="card-header">
                <h3><div class="card-icon">📁</div> Reports by Department</h3>
                <span style="font-size:12.5px; color:var(--text-3);">
                    <%= grandTotal %> total reports
                </span>
            </div>
            <div class="card-body">
                <div class="dept-bars">
                <%
                    for (int di = 0; di < deptNames.size(); di++) {
                        int    dc  = deptCounts.get(di);
                        int    pct = (deptMax > 0) ? (dc * 100 / deptMax) : 0;
                        int    gpct = (grandTotal > 0) ? (dc * 100 / grandTotal) : 0;
                %>
                <div class="dept-bar-row">
                    <div class="dept-bar-name">
                        <%= deptNames.get(di) %>
                    </div>
                    <div class="dept-bar-track">
                        <div class="dept-bar-fill"
                             style="width:<%= pct %>%;">
                        </div>
                    </div>
                    <div class="dept-bar-count"><%= dc %></div>
                    <div style="font-size:11.5px; color:var(--text-3);
                                width:36px; text-align:right;">
                        <%= gpct %>%
                    </div>
                </div>
                <% } %>
                <% if (deptNames.isEmpty()) { %>
                <div style="color:var(--text-3); font-size:13px;
                            text-align:center; padding:16px 0;">
                    No data yet
                </div>
                <% } %>
                </div>
            </div>
        </div>

        <!-- ALL REPORTS TABLE -->
        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📋</div>
                    All Reports
                </h3>
                <span style="font-size:12.5px; color:var(--text-3);"
                      id="tableCount">
                    <%= reports.size() %> reports
                </span>
            </div>
            <div class="card-body" style="padding-top:14px;">

                <!-- FILTER BAR -->
                <div class="filter-row">
                    <button class="filter-chip active"
                            id="chip-all"
                            onclick="filterTable('all', this)">
                        All (<%= grandTotal %>)
                    </button>
                    <button class="filter-chip f-pending"
                            id="chip-pending"
                            onclick="filterTable('pending', this)">
                        ⏳ Pending (<%= totalPending %>)
                    </button>
                    <button class="filter-chip"
                            id="chip-progress"
                            onclick="filterTable('progress', this)">
                        🔧 In Progress (<%= totalProgress %>)
                    </button>
                    <button class="filter-chip f-resolved"
                            id="chip-resolved"
                            onclick="filterTable('resolved', this)">
                        ✅ Resolved (<%= totalResolved %>)
                    </button>
                    <button class="filter-chip f-other"
                            id="chip-other"
                            onclick="filterTable('other', this)">
                        ⚠️ Other (<%= totalOther %>)
                    </button>
                    <div class="search-wrap">
                        <span class="search-icon">🔍</span>
                        <input type="text"
                               id="searchBox"
                               placeholder="Search reports..."
                               oninput="searchTable(this.value)">
                    </div>
                    <span class="results-count" id="tableCount2">
                        Showing <%= reports.size() %>
                    </span>
                </div>

                <!-- TABLE -->
                <div style="overflow-x:auto;">
                <table class="admin-table" id="reportsTable">
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Title</th>
                            <th>Citizen</th>
                            <th>Department</th>
                            <th>Severity</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>View</th>
                            <th>Reassign</th>
                        </tr>
                    </thead>
                    <tbody id="reportsTbody">
                    <%
                        if (reports.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="9"
                            style="text-align:center;
                                   padding:40px;
                                   color:var(--text-3);">
                            No reports in system yet.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (java.util.Map<String,Object> r : reports) {
                                int    rId   = (int)    r.get("reportId");
                                String rT    = (String) r.get("title");
                                String rCit  = (String) r.get("citizen");
                                String rDept = (String) r.get("dept");
                                int    rDId  = (int)    r.get("deptId");
                                String rSev  = (String) r.get("severity");
                                String rSt   = (String) r.get("status");
                                String rDate = (String) r.get("createdAt");

                                String stLow = rSt != null ? rSt.toLowerCase() : "";
                                String badgeCss =
                                    stLow.equals("pending")        ? "badge-pending"  :
                                    stLow.equals("assigned")       ? "badge-assigned" :
                                    stLow.contains("progress")     ? "badge-progress" :
                                    stLow.equals("resolved")       ? "badge-resolved" :
                                    stLow.contains("rework")       ? "badge-rework"   :
                                    "badge-rejected";

                                String filterTag =
                                    stLow.equals("pending")        ? "pending"  :
                                    stLow.equals("assigned")
                                 || stLow.contains("progress")     ? "progress" :
                                    stLow.equals("resolved")       ? "resolved" :
                                    "other";

                                String sevLow = rSev != null ? rSev.toLowerCase() : "low";
                    %>
                    <tr data-status="<%= filterTag %>"
                        data-search="<%= (rT + " " + rCit + " " + rDept + " " + rSt).toLowerCase() %>">
                        <td>
                            <span style="font-weight:700;
                                         color:var(--accent);">
                                #<%= rId %>
                            </span>
                        </td>
                        <td style="color:var(--text-1); max-width:180px;">
                            <%= rT != null && rT.length() > 30
                                ? rT.substring(0,30) + "…" : rT %>
                        </td>
                        <td><%= rCit != null ? rCit : "—" %></td>
                        <td style="color:var(--text-2);">
                            <%= rDept != null ? rDept : "—" %>
                        </td>
                        <td>
                            <span class="severity <%= sevLow %>">
                                <span class="sev-dot"></span>
                                <%= rSev %>
                            </span>
                        </td>
                        <td>
                            <span class="badge <%= badgeCss %>">
                                <span class="dot"></span>
                                <%= rSt != null && rSt.length() > 14
                                    ? rSt.substring(0,14) + "…" : rSt %>
                            </span>
                        </td>
                        <td style="color:var(--text-3); white-space:nowrap;">
                            <%= rDate %>
                        </td>
                        <td>
                            <a href="../citizen/view-report.jsp?id=<%= rId %>"
                               class="lcps-btn xs ghost">
                                👁️
                            </a>
                        </td>
                        <td>
                            <form class="reassign-form"
                                  action="<%=request.getContextPath()%>/admin"
                                  method="post">
                                <input type="hidden"
                                       name="action"
                                       value="reassign">
                                <input type="hidden"
                                       name="report_id"
                                       value="<%= rId %>">
                                <select name="dept_id"
                                        class="reassign-select">
                                    <option value="1" <%= rDId==1?"selected":"" %>>
                                        Road
                                    </option>
                                    <option value="2" <%= rDId==2?"selected":"" %>>
                                        Electrical
                                    </option>
                                    <option value="3" <%= rDId==3?"selected":"" %>>
                                        Water
                                    </option>
                                    <option value="4" <%= rDId==4?"selected":"" %>>
                                        Garbage
                                    </option>
                                    <option value="5" <%= rDId==5?"selected":"" %>>
                                        Parks
                                    </option>
                                    <option value="6" <%= rDId==6?"selected":"" %>>
                                        Building
                                    </option>
                                    <option value="7" <%= rDId==7?"selected":"" %>>
                                        Others
                                    </option>
                                </select>
                                <button type="submit"
                                        class="reassign-btn"
                                        title="Reassign">
                                    ↗
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        }
                    %>
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

<script>
let currentFilter = "all";

function filterTable(status, el) {
    currentFilter = status;

    // Sync chips
    document.querySelectorAll(".filter-chip").forEach(c =>
        c.classList.remove("active"));
    // Sync stat cards
    document.querySelectorAll(".stat-mini").forEach(c =>
        c.style.outline = "");

    if (el) {
        el.classList.add("active");
        // Also highlight matching chip if stat card clicked
        const chipEl = document.getElementById("chip-" + status);
        if (chipEl) chipEl.classList.add("active");
    }

    applyFilters();
}

function searchTable(query) {
    applyFilters(query.toLowerCase().trim());
}

function applyFilters(searchQuery) {
    const q    = searchQuery !== undefined
                 ? searchQuery
                 : document.getElementById("searchBox").value.toLowerCase().trim();
    const rows = document.querySelectorAll("#reportsTbody tr[data-status]");
    let   visible = 0;

    rows.forEach(row => {
        const matchStatus = currentFilter === "all" ||
                            row.dataset.status === currentFilter;
        const matchSearch = !q ||
                            row.dataset.search.includes(q);
        const show = matchStatus && matchSearch;
        row.style.display = show ? "" : "none";
        if (show) visible++;
    });

    document.getElementById("tableCount").textContent =
        visible + " report" + (visible !== 1 ? "s" : "");
    document.getElementById("tableCount2").textContent =
        "Showing " + visible;
}
</script>

</body>
</html>
