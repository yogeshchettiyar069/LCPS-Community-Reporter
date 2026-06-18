<%@ page import="model.User, model.Report, java.util.List, java.sql.Timestamp, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User u = (User) session.getAttribute("user");
    if (u == null || u.getRoleId() != 4) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<Report> workerReports = ops.getWorkerReports(u.getUserId());

    java.util.List<java.util.Map<String, Object>> reports = new java.util.ArrayList<>();
    for (Report rep : workerReports) {
        java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
        row.put("reportId",  rep.getReportId());
        row.put("title",     rep.getTitle());
        row.put("deptName",  rep.getDeptName());
        row.put("status",    rep.getStatus());
        row.put("severity",  rep.getSeverity());
        row.put("createdAt", rep.getCreatedAt());
        reports.add(row);
    }

    int total = reports.size();
    int pending = 0, inProgress = 0, rework = 0, resolved = 0;
    for (java.util.Map<String,Object> r : reports) {
        String st = ((String) r.get("status")).toLowerCase();
        if      (st.equals("pending"))         pending++;
        else if (st.contains("progress"))      inProgress++;
        else if (st.contains("rework"))        rework++;
        else if (st.equals("resolved"))        resolved++;
    }

    int completionPct = total > 0 ? (resolved * 100 / total) : 0;
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");

    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");
%>
<!DOCTYPE html>
<html>
<head>
<title>Worker Dashboard | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== STAT MINI CHIPS (replaces lcps-stat-chip) ===== */
.w-stat-row {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.w-stat-chip {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 14px 18px;
    display: flex;
    align-items: center;
    gap: 14px;
    min-width: 110px;
    flex: 1;
    position: relative;
    overflow: hidden;
    transition: border-color 0.18s;
}

.w-stat-chip::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
}

.w-stat-chip.c-total::before    { background: var(--text-3); }
.w-stat-chip.c-progress::before { background: var(--accent); }
.w-stat-chip.c-rework::before   { background: #a855f7; }
.w-stat-chip.c-resolved::before { background: var(--green); }

.w-stat-num {
    font-size: 28px;
    font-weight: 800;
    line-height: 1;
}

.w-stat-chip.c-total    .w-stat-num { color: var(--text-1); }
.w-stat-chip.c-progress .w-stat-num { color: var(--accent); }
.w-stat-chip.c-rework   .w-stat-num { color: #a855f7; }
.w-stat-chip.c-resolved .w-stat-num { color: var(--green); }

.w-stat-label {
    font-size: 12px;
    color: var(--text-3);
    margin-top: 3px;
    text-transform: uppercase;
    letter-spacing: 0.4px;
}

.w-stat-icon {
    font-size: 22px;
    flex-shrink: 0;
    opacity: 0.7;
}

/* ===== REPORT CARDS ===== */
.report-card {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 18px 20px 18px 24px;
    margin-bottom: 12px;
    transition: border-color 0.2s, box-shadow 0.2s;
    position: relative;
}

.report-card:hover {
    border-color: var(--border-blue);
    box-shadow: var(--shadow-md);
}

.report-card::before {
    content: "";
    position: absolute;
    left: 0; top: 0; bottom: 0;
    width: 4px;
    border-radius: var(--r-md) 0 0 var(--r-md);
}

.report-card.s-pending::before  { background: var(--gold); }
.report-card.s-progress::before { background: var(--accent); }
.report-card.s-rework::before   { background: #a855f7; }
.report-card.s-resolved::before { background: var(--green); }

.card-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 14px;
    flex-wrap: wrap;
}

.card-title-row {
    font-size: 15px;
    font-weight: 700;
    color: var(--text-1);
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 8px;
}

.card-id {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-3);
}

.card-meta {
    display: flex;
    gap: 18px;
    flex-wrap: wrap;
    font-size: 12.5px;
    color: var(--text-3);
    align-items: center;
}

.card-meta strong { color: var(--text-2); }

.card-actions {
    display: flex;
    gap: 8px;
    align-items: center;
    flex-shrink: 0;
    flex-wrap: wrap;
}

/* ===== REWORK STRIP ===== */
.rework-strip {
    background: rgba(168,85,247,0.07);
    border: 1px solid rgba(168,85,247,0.22);
    border-radius: var(--r-sm);
    padding: 11px 15px;
    margin-top: 14px;
    display: flex;
    gap: 12px;
    align-items: flex-start;
}

.rework-strip-title {
    font-size: 12.5px;
    font-weight: 700;
    color: #c084fc;
    margin-bottom: 4px;
}

.rework-strip-body {
    font-size: 12.5px;
    color: var(--text-2);
    line-height: 1.55;
}

/* ===== FILTER BAR ===== */
.filter-bar {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-bottom: 16px;
    align-items: center;
}

.filter-btn {
    padding: 6px 16px;
    border-radius: var(--r-full);
    border: 1px solid var(--border-md);
    background: var(--bg-input);
    color: var(--text-2);
    font-size: 12.5px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.18s;
    white-space: nowrap;
}

.filter-btn:hover { border-color: var(--border-blue); color: var(--accent); }

/* Active states per type */
.filter-btn.active          { background: var(--accent);  border-color: var(--accent);  color: #fff; }
.filter-btn.f-pending.active{ background: var(--gold);    border-color: var(--gold);    color: #000; }
.filter-btn.f-rework.active { background: #a855f7;        border-color: #a855f7;        color: #fff; }
.filter-btn.f-resolved.active{background: var(--green);   border-color: var(--green);   color: #fff; }
.filter-btn.f-progress.active{background: var(--accent);  border-color: var(--accent);  color: #fff; }

.results-count {
    margin-left: auto;
    font-size: 12.5px;
    color: var(--text-3);
    white-space: nowrap;
}

/* Complete label */
.complete-label {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 12.5px;
    font-weight: 600;
    color: var(--green);
    background: rgba(16,185,129,0.08);
    border: 1px solid rgba(16,185,129,0.25);
    border-radius: var(--r-sm);
    padding: 5px 12px;
}
/* =========================================
   RESPONSIVE DESIGN
   ========================================= */

/* Tablet */
@media (max-width: 992px) {

    .lcps-layout {
        flex-direction: column;
    }

    .lcps-sidebar {
        width: 100%;
        max-width: 100%;
        position: static;
    }

    .lcps-main {
        width: 100%;
    }

    .w-stat-chip {
        min-width: calc(50% - 8px);
        flex: 1 1 calc(50% - 8px);
    }

    .page-header {
        flex-direction: column;
        gap: 12px;
    }
}

/* Mobile */
@media (max-width: 768px) {

    /* Header */
    .lcps-header {
        flex-direction: column;
        align-items: stretch;
        gap: 14px;
        padding: 14px;
    }

    .header-nav {
        display: flex;
        justify-content: center;
        flex-wrap: wrap;
        gap: 8px;
    }

    .header-right {
        justify-content: center;
        display: flex;
    }

    .user-chip {
        width: 100%;
        justify-content: center;
    }

    /* Sidebar */
    .lcps-sidebar {
        width: 100%;
        padding: 15px;
    }

    /* Main */
    .lcps-main {
        padding: 15px;
    }

    /* Page title */
    .page-header-left h1 {
        font-size: 24px;
    }

    /* Stats */
    .w-stat-row {
        gap: 10px;
    }

    .w-stat-chip {
        min-width: 100%;
        flex: 1 1 100%;
    }

    .w-stat-num {
        font-size: 24px;
    }

    /* Filter bar */
    .filter-bar {
        flex-direction: column;
        align-items: stretch;
    }

    .filter-btn {
        width: 100%;
        text-align: center;
    }

    .results-count {
        margin-left: 0;
        text-align: center;
        margin-top: 5px;
    }

    /* Report cards */
    .report-card {
        padding: 15px;
    }

    .card-top {
        flex-direction: column;
        align-items: stretch;
    }

    .card-title-row {
        flex-direction: column;
        align-items: flex-start;
        gap: 6px;
    }

    .card-meta {
        flex-direction: column;
        gap: 8px;
        align-items: flex-start;
    }

    .card-actions {
        width: 100%;
        margin-top: 12px;
        display: flex;
        flex-direction: column;
    }

    .card-actions a,
    .card-actions span {
        width: 100%;
        text-align: center;
    }

    .lcps-btn {
        width: 100%;
    }

    /* Rework section */
    .rework-strip {
        flex-direction: column;
    }

    /* Footer */
    .lcps-footer {
        flex-direction: column;
        gap: 10px;
        text-align: center;
    }

    .f-right {
        justify-content: center;
        flex-wrap: wrap;
    }
}

/* Extra Small Devices */
@media (max-width: 480px) {

    .logo-text-main {
        font-size: 20px;
    }

    .logo-text-sub {
        font-size: 11px;
    }

    .page-header-left h1 {
        font-size: 20px;
    }

    .card-title-row {
        font-size: 14px;
    }

    .card-meta {
        font-size: 12px;
    }

    .w-stat-num {
        font-size: 22px;
    }

    .report-card {
        padding: 12px;
    }

    .lcps-main {
        padding: 12px;
    }
}
</style>
</head>
<body>

<!-- ===== HEADER ===== -->
<div class="lcps-header">
    <a href="dashboard.jsp" class="logo">
        <div class="logo-icon">🏛️</div>
        <div>
            <div class="logo-text-main">LC<span>PS</span></div>
            <div class="logo-text-sub">Community Problem Solver</div>
        </div>
    </a>
    <div class="header-nav">
        <a href="dashboard.jsp" class="active">Dashboard</a>
        <a href="update-work.jsp">Update Work</a>
    </div>
    <div class="header-right">
        <div class="user-chip">
            <div class="avatar">
                <%= u.getName().substring(0,1).toUpperCase() %>
            </div>
            <div>
                <div class="user-info-name"><%= u.getName() %></div>
                <div class="user-info-role">Worker</div>
            </div>
        </div>
    </div>
</div>

<!-- ===== LAYOUT ===== -->
<div class="lcps-layout">

    <!-- SIDEBAR -->
    <div class="lcps-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Worker</div>
            <a href="dashboard.jsp" class="sidebar-link active">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="update-work.jsp" class="sidebar-link">
                <span class="s-icon">🔧</span> Update Work
            </a>
        </div>

        <!-- MY STATS -->
        <div class="sidebar-section">
            <div class="sidebar-label">My Stats</div>
            <div style="display:flex; flex-direction:column;
                        gap:10px; padding:4px 0;">

                <div style="display:flex; justify-content:space-between;">
                    <span style="font-size:12.5px; color:var(--text-3);">
                        Total Assigned
                    </span>
                    <span style="font-weight:700; color:var(--text-1);">
                        <%= total %>
                    </span>
                </div>

                <div style="display:flex; justify-content:space-between;">
                    <span style="font-size:12.5px; color:var(--text-3);">
                        In Progress
                    </span>
                    <span style="font-weight:700; color:var(--accent);">
                        <%= inProgress %>
                    </span>
                </div>

                <div style="display:flex; justify-content:space-between;">
                    <span style="font-size:12.5px; color:var(--text-3);">
                        Rework Required
                    </span>
                    <span style="font-weight:700; color:#a855f7;">
                        <%= rework %>
                    </span>
                </div>

                <div style="display:flex; justify-content:space-between;">
                    <span style="font-size:12.5px; color:var(--text-3);">
                        Resolved
                    </span>
                    <span style="font-weight:700; color:var(--green);">
                        <%= resolved %>
                    </span>
                </div>

                <% if (total > 0) { %>
                <div style="margin-top:6px;">
                    <div style="display:flex; justify-content:space-between;
                                margin-bottom:5px;">
                        <span style="font-size:11px; color:var(--text-3);">
                            Completion Rate
                        </span>
                        <span style="font-size:11px; color:var(--green);
                                     font-weight:700;">
                            <%= completionPct %>%
                        </span>
                    </div>
                    <div style="background:var(--bg-input);
                                border-radius:var(--r-full);
                                height:7px; overflow:hidden;">
                        <div style="height:100%;
                                    width:<%= completionPct %>%;
                                    background:var(--green);
                                    border-radius:var(--r-full);">
                        </div>
                    </div>
                </div>
                <% } %>

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
                    <span>Worker</span>
                    <span class="sep">›</span>
                    <span>Dashboard</span>
                </div>
                <h1>My Assigned Work</h1>
                <p>Manage and update the reports assigned to you.</p>
            </div>
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

        <!-- STAT CHIPS -->
        <div class="w-stat-row">

            <div class="w-stat-chip c-total">
                <div style="font-size:20px; opacity:0.5;">📋</div>
                <div>
                    <div class="w-stat-num"><%= total %></div>
                    <div class="w-stat-label">Total</div>
                </div>
            </div>

            <div class="w-stat-chip c-progress">
                <div style="font-size:20px; opacity:0.6;">🔧</div>
                <div>
                    <div class="w-stat-num"><%= inProgress %></div>
                    <div class="w-stat-label">In Progress</div>
                </div>
            </div>

            <div class="w-stat-chip c-rework">
                <div style="font-size:20px; opacity:0.6;">🔄</div>
                <div>
                    <div class="w-stat-num"><%= rework %></div>
                    <div class="w-stat-label">Rework</div>
                </div>
            </div>

            <div class="w-stat-chip c-resolved">
                <div style="font-size:20px; opacity:0.6;">✅</div>
                <div>
                    <div class="w-stat-num"><%= resolved %></div>
                    <div class="w-stat-label">Resolved</div>
                </div>
            </div>

        </div>

        <!-- REWORK ALERT -->
        <% if (rework > 0) { %>
        <div style="background:rgba(168,85,247,0.07);
                    border:1px solid rgba(168,85,247,0.25);
                    border-radius:var(--r-md);
                    padding:13px 18px;
                    display:flex; align-items:center; gap:12px;
                    margin-bottom:20px;">
            <span style="font-size:20px;">🔄</span>
            <span style="font-size:13.5px; color:var(--text-2);">
                You have
                <strong style="color:#c084fc;">
                    <%= rework %> report<%= rework > 1 ? "s" : "" %>
                </strong>
                requiring rework. Please review the authority's comments
                below and re-upload your work.
            </span>
        </div>
        <% } %>

        <!-- FILTER BAR -->
        <div class="filter-bar">
            <button class="filter-btn active" id="btn-all"
                    onclick="filterCards('all', this)">
                All (<%= total %>)
            </button>
            <button class="filter-btn f-pending" id="btn-pending"
                    onclick="filterCards('s-pending', this)">
                ⏳ Pending (<%= pending %>)
            </button>
            <button class="filter-btn f-progress" id="btn-progress"
                    onclick="filterCards('s-progress', this)">
                🔧 In Progress (<%= inProgress %>)
            </button>
            <button class="filter-btn f-rework" id="btn-rework"
                    onclick="filterCards('s-rework', this)">
                🔄 Rework (<%= rework %>)
            </button>
            <button class="filter-btn f-resolved" id="btn-resolved"
                    onclick="filterCards('s-resolved', this)">
                ✅ Resolved (<%= resolved %>)
            </button>
            <span class="results-count" id="resultsCount">
                Showing <%= total %> reports
            </span>
        </div>

        <!-- REPORT CARDS -->
        <div id="reportList">
        <%
            if (reports.isEmpty()) {
        %>
        <div class="lcps-card">
            <div class="card-body" style="text-align:center; padding:50px 20px;">
                <div style="font-size:48px; margin-bottom:14px;">🛠️</div>
                <div style="font-size:16px; font-weight:600;
                             color:var(--text-2); margin-bottom:8px;">
                    No work assigned yet
                </div>
                <div style="font-size:13.5px; color:var(--text-3);">
                    You will see your assigned reports here once
                    an authority assigns work to you.
                </div>
            </div>
        </div>
        <%
            } else {
                for (java.util.Map<String,Object> r : reports) {
                    int    rId    = (int)    r.get("reportId");
                    String rTitle = (String) r.get("title");
                    String rDept  = (String) r.get("deptName");
                    String rSt    = (String) r.get("status");
                    String rSev   = (String) r.get("severity");
                    java.sql.Timestamp rDate =
                        (java.sql.Timestamp) r.get("createdAt");

                    String stLow = rSt != null ? rSt.toLowerCase() : "";

                    String cardCls =
                        stLow.contains("rework")   ? "s-rework"   :
                        stLow.contains("progress") ? "s-progress" :
                        stLow.equals("resolved")   ? "s-resolved" :
                        "s-pending";

                    String badgeClass =
                        stLow.equals("pending")    ? "badge-pending"  :
                        stLow.equals("assigned")   ? "badge-assigned" :
                        stLow.contains("progress") ? "badge-progress" :
                        stLow.equals("resolved")   ? "badge-resolved" :
                        stLow.contains("rework")   ? "badge-rework"   :
                        "badge-rejected";

                    String sevLow  = rSev  != null ? rSev.toLowerCase()  : "low";
                    String dateStr = rDate != null ? sdf.format(rDate)   : "—";

                    String reworkComment = null;
                    if (stLow.contains("rework")) {
                        reworkComment = ops.getLatestRejectionComment(rId);
                    }
        %>
        <div class="report-card <%= cardCls %>"
             data-status="<%= cardCls %>">

            <div class="card-top">
                <!-- LEFT: title + meta -->
                <div style="flex:1; min-width:0;">
                    <div class="card-title-row">
                        <span class="card-id">#<%= rId %></span>
                        <span><%= rTitle %></span>
                        <span class="badge <%= badgeClass %>">
                            <span class="dot"></span><%= rSt %>
                        </span>
                    </div>
                    <div class="card-meta">
                        <span>
                            🏢 Dept:
                            <strong><%= rDept != null ? rDept : "—" %></strong>
                        </span>
                        <span>
                            Severity:
                            <span class="severity <%= sevLow %>">
                                <span class="sev-dot"></span><%= rSev %>
                            </span>
                        </span>
                        <span>
                            📅 Assigned:
                            <strong><%= dateStr %></strong>
                        </span>
                    </div>
                </div>

                <!-- RIGHT: actions -->
                <div class="card-actions">
                    <a href="../citizen/view-report.jsp?id=<%= rId %>"
                       class="lcps-btn xs ghost">
                        👁 View
                    </a>

                    <% if (stLow.equals("resolved")) { %>
                    <span class="complete-label">
                        ✅ Complete
                    </span>

                    <% } else if (stLow.contains("rework")) { %>
                    <a href="update-work.jsp?reportId=<%= rId %>"
                       class="lcps-btn xs"
                       style="background:#a855f7;
                              border-color:#a855f7;
                              color:#fff;">
                        🔄 Re-Upload
                    </a>

                    <% } else { %>
                    <a href="update-work.jsp?reportId=<%= rId %>"
                       class="lcps-btn xs outline">
                        🔧 Update Work
                    </a>
                    <% } %>
                </div>
            </div>

            <!-- REWORK STRIP -->
            <% if (stLow.contains("rework")) { %>
            <div class="rework-strip">
                <span style="font-size:20px; flex-shrink:0;">🔄</span>
                <div>
                    <div class="rework-strip-title">
                        Authority Requested Rework
                    </div>
                    <div class="rework-strip-body">
                        <%= (reworkComment != null && !reworkComment.isEmpty())
                            ? reworkComment
                            : "No specific comment provided. Please check with authority." %>
                    </div>
                </div>
            </div>
            <% } %>

        </div>
        <%
                }
            }
        %>
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
function filterCards(statusClass, btn) {
    // Remove active from ALL filter buttons
    document.querySelectorAll(".filter-btn")
            .forEach(b => b.classList.remove("active"));
    btn.classList.add("active");

    const cards = document.querySelectorAll(".report-card");
    let visible = 0;

    cards.forEach(card => {
        const show = statusClass === "all" ||
                     card.dataset.status === statusClass;
        card.style.display = show ? "" : "none";
        if (show) visible++;
    });

    document.getElementById("resultsCount").textContent =
        "Showing " + visible + " report" + (visible !== 1 ? "s" : "");
}
</script>

</body>
</html>
