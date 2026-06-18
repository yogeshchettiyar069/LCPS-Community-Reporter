<%@ page import="model.User, model.Report, java.util.List, operations.ReportOperations" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User u = (User) session.getAttribute("user");
    if (u == null || u.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<Report> reports = ops.getCitizenReports(u.getUserId());

    // Count totals for filter badges
    // We need two passes — store all rows first
    java.util.List<Object[]> allRows = new java.util.ArrayList<>();
    int total = 0, pending = 0, inProgress = 0, resolved = 0, rejected = 0;

    for (Report report : reports) {

        total++;

        String st = report.getStatus();
        String stLow = st != null ? st.toLowerCase() : "";

        if      (stLow.equals("pending"))                          pending++;
        else if (stLow.equals("assigned")
              || stLow.contains("progress")
              || stLow.contains("work"))                           inProgress++;
        else if (stLow.equals("resolved"))                         resolved++;
        else if (stLow.equals("rejected"))                         rejected++;

        allRows.add(new Object[]{
            report.getReportId(),
            report.getTitle(),
            report.getDeptName(),
            st,
            report.getCreatedAt()
        });
    }

    // Active filter from URL param
    String filter = request.getParameter("filter");
    if (filter == null) filter = "all";
    String firstName = u.getName().split(" ")[0];
%>
<!DOCTYPE html>
<html>
<head>
<title>My Reports | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== FILTER TABS ===== */
.filter-tabs {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.filter-tab {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 7px 16px;
    border-radius: var(--r-full);
    border: 1px solid var(--border-md);
    background: var(--bg-card);
    color: var(--text-2);
    font-size: 13px;
    font-weight: 500;
    text-decoration: none;
    transition: all 0.18s;
    cursor: pointer;
}

.filter-tab:hover {
    border-color: var(--border-blue);
    color: var(--text-1);
}

.filter-tab.active {
    background: var(--accent-soft);
    border-color: var(--accent);
    color: var(--accent);
    font-weight: 600;
}

.filter-tab .tab-count {
    background: rgba(255,255,255,0.08);
    padding: 1px 7px;
    border-radius: var(--r-full);
    font-size: 11px;
    font-weight: 700;
}

.filter-tab.active .tab-count {
    background: var(--accent-soft);
    border: 1px solid var(--accent-border);
    color: var(--accent);
}

/* ===== SEARCH BAR ===== */
.search-bar-wrap {
    position: relative;
    max-width: 320px;
}

.search-bar-wrap .search-icon {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 14px;
    color: var(--text-3);
    pointer-events: none;
}

.search-bar-wrap input {
    padding-left: 36px !important;
}

/* ===== DATE CHIP ===== */
.date-chip {
    font-size: 12px;
    color: var(--text-3);
    white-space: nowrap;
}

/* ===== RESPONSIVE OVERRIDES ===== */
.table-wrap {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    width: 100%;
}

.mobile-menu-btn {
    display: none;
    font-size: 24px;
    cursor: pointer;
    padding: 5px;
    user-select: none;
}

@media (max-width: 768px) {
    .mobile-menu-btn {
        display: block; /* Show hamburger menu */
    }
    .header-nav {
        display: none; /* Hide top nav to save space */
    }
    .lcps-header {
        flex-wrap: wrap;
        justify-content: space-between;
        padding: 10px 15px;
    }
    .header-right {
        gap: 10px;
    }
    
    /* Layout Stacking */
    .lcps-layout {
        display: flex;
        flex-direction: column;
    }
    
    /* Sidebar Toggle Logic */
    .lcps-sidebar {
        display: none;
        width: 100%;
        border-right: none;
        border-bottom: 1px solid var(--border, #eaeaea);
        padding-bottom: 15px;
    }
    .lcps-sidebar.active {
        display: block;
    }

    .page-header {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 15px;
    }
    .page-header .lcps-btn {
        width: 100%;
        text-align: center;
        justify-content: center;
    }

    .card-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
    }
    
    .search-bar-wrap {
        max-width: 100%;
        width: 100%;
    }
    .search-bar-wrap input {
        width: 100%;
    }

    /* Footer stacking */
    .lcps-footer {
        flex-direction: column;
        text-align: center;
        gap: 10px;
    }
    .f-right {
        justify-content: center;
    }
}
</style>
</head>
<body>

<div class="lcps-header">
    <div style="display:flex; align-items:center; gap:10px;">
        <div class="mobile-menu-btn" onclick="document.querySelector('.lcps-sidebar').classList.toggle('active')">
            ☰
        </div>
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
        <a href="my-reports.jsp" class="active">My Reports</a>
        <a href="report-issue.jsp">Report Issue</a>
    </div>
    <div class="header-right">
        <div class="notif-btn" title="Notifications">
            🔔
            <% if (pending > 0) { %><div class="notif-dot"></div><% } %>
        </div>
        <div class="user-chip">
            <div class="avatar">
                <%= u.getName().substring(0,1).toUpperCase() %>
            </div>
            <div>
                <div class="user-info-name"><%= u.getName() %></div>
                <div class="user-info-role">Citizen</div>
            </div>
        </div>
    </div>
</div>

<div class="lcps-layout">

    <div class="lcps-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Main</div>
            <a href="dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="my-reports.jsp" class="sidebar-link active">
                <span class="s-icon">📋</span> My Reports
                <% if (total > 0) { %>
                <span class="sidebar-badge"><%= total %></span>
                <% } %>
            </a>
            <a href="report-issue.jsp" class="sidebar-link">
                <span class="s-icon">➕</span> Report Issue
            </a>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-label">Filter By Status</div>
            <a href="my-reports.jsp?filter=all"
               class="sidebar-link <%= filter.equals("all") ? "active" : "" %>">
                <span class="s-icon">📁</span> All Reports
                <span class="sidebar-badge"><%= total %></span>
            </a>
            <a href="my-reports.jsp?filter=pending"
               class="sidebar-link <%= filter.equals("pending") ? "active" : "" %>">
                <span class="s-icon">⏳</span> Pending
                <% if (pending > 0) { %>
                <span class="sidebar-badge"><%= pending %></span>
                <% } %>
            </a>
            <a href="my-reports.jsp?filter=progress"
               class="sidebar-link <%= filter.equals("progress") ? "active" : "" %>">
                <span class="s-icon">🔧</span> In Progress
                <% if (inProgress > 0) { %>
                <span class="sidebar-badge"><%= inProgress %></span>
                <% } %>
            </a>
            <a href="my-reports.jsp?filter=resolved"
               class="sidebar-link <%= filter.equals("resolved") ? "active" : "" %>">
                <span class="s-icon">✅</span> Resolved
                <% if (resolved > 0) { %>
                <span class="sidebar-badge"><%= resolved %></span>
                <% } %>
            </a>
            <a href="my-reports.jsp?filter=rejected"
               class="sidebar-link <%= filter.equals("rejected") ? "active" : "" %>">
                <span class="s-icon">❌</span> Rejected
                <% if (rejected > 0) { %>
                <span class="sidebar-badge"><%= rejected %></span>
                <% } %>
            </a>
        </div>

        <div class="sidebar-divider"></div>

        <div class="sidebar-section">
            <div class="sidebar-label">Account</div>
            <a href="#" class="sidebar-link">
                <span class="s-icon">👤</span> Profile
            </a>
        </div>

        <div class="sidebar-footer">
            <a href="<%=request.getContextPath()%>/auth?action=logout"
               style="color:var(--red);">
                <span>🚪</span> Logout
            </a>
        </div>
    </div>

    <div class="lcps-main">

        <div class="page-header">
            <div class="page-header-left">
                <div class="breadcrumb">
                    <a href="dashboard.jsp">Home</a>
                    <span class="sep">›</span>
                    <span>My Reports</span>
                </div>
                <h1>My Reports</h1>
                <p>
                    You have <strong style="color:var(--text-1);">
                    <%= total %></strong> report<%= total != 1 ? "s" : "" %> submitted.
                </p>
            </div>
            <a href="report-issue.jsp" class="lcps-btn">
                ➕ New Report
            </a>
        </div>

        <div class="filter-tabs">
            <a href="my-reports.jsp?filter=all"
               class="filter-tab <%= filter.equals("all") ? "active" : "" %>">
                📁 All
                <span class="tab-count"><%= total %></span>
            </a>
            <a href="my-reports.jsp?filter=pending"
               class="filter-tab <%= filter.equals("pending") ? "active" : "" %>">
                ⏳ Pending
                <span class="tab-count"><%= pending %></span>
            </a>
            <a href="my-reports.jsp?filter=progress"
               class="filter-tab <%= filter.equals("progress") ? "active" : "" %>">
                🔧 In Progress
                <span class="tab-count"><%= inProgress %></span>
            </a>
            <a href="my-reports.jsp?filter=resolved"
               class="filter-tab <%= filter.equals("resolved") ? "active" : "" %>">
                ✅ Resolved
                <span class="tab-count"><%= resolved %></span>
            </a>
            <a href="my-reports.jsp?filter=rejected"
               class="filter-tab <%= filter.equals("rejected") ? "active" : "" %>">
                ❌ Rejected
                <span class="tab-count"><%= rejected %></span>
            </a>
        </div>

        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📋</div>
                    <%
                        String tabLabel =
                            filter.equals("pending")  ? "Pending Reports"    :
                            filter.equals("progress") ? "In Progress Reports" :
                            filter.equals("resolved") ? "Resolved Reports"   :
                            filter.equals("rejected") ? "Rejected Reports"   :
                            "All Reports";
                    %>
                    <%= tabLabel %>
                </h3>
                <div class="search-bar-wrap">
                    <span class="search-icon">🔍</span>
                    <input class="lcps-input sm"
                           type="text"
                           id="searchInput"
                           placeholder="Search reports..."
                           oninput="filterTable(this.value)"
                           style="font-size:13px; padding:7px 12px 7px 34px;">
                </div>
            </div>

            <%
                // Apply filter
                java.util.List<Object[]> filtered = new java.util.ArrayList<>();
                for (Object[] row : allRows) {
                    String st    = (String) row[3];
                    String stLow = st != null ? st.toLowerCase() : "";
                    boolean show =
                        filter.equals("all")      ||
                        (filter.equals("pending")  && stLow.equals("pending"))  ||
                        (filter.equals("progress") && (stLow.equals("assigned")
                                                    || stLow.contains("progress")
                                                    || stLow.contains("work")))  ||
                        (filter.equals("resolved") && stLow.equals("resolved")) ||
                        (filter.equals("rejected") && stLow.equals("rejected"));
                    if (show) filtered.add(row);
                }
            %>

            <% if (filtered.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">
                    <%= filter.equals("resolved") ? "🎉" :
                        filter.equals("pending")  ? "⏳" :
                        filter.equals("rejected") ? "❌" : "📭" %>
                </div>
                <h3>
                    <%= filter.equals("resolved") ? "No resolved reports yet" :
                        filter.equals("pending")  ? "No pending reports"      :
                        filter.equals("rejected") ? "No rejected reports"     :
                        "No reports yet" %>
                </h3>
                <p>
                    <%= filter.equals("all")
                        ? "You haven't submitted any community issues yet."
                        : "No reports match this filter." %>
                </p>
                <% if (filter.equals("all")) { %>
                <a href="report-issue.jsp" class="lcps-btn">
                    ➕ Report Your First Issue
                </a>
                <% } else { %>
                <a href="my-reports.jsp" class="lcps-btn outline">
                    View All Reports
                </a>
                <% } %>
            </div>

            <% } else { %>
            <div class="table-wrap">
                <table class="lcps-table" id="reportsTable">
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Title</th>
                            <th>Department</th>
                            <th>Status</th>
                            <th>Submitted</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Object[] row : filtered) {
                            int    rid   = (int)       row[0];
                            String rtitle= (String)    row[1];
                            String rdept = (String)    row[2];
                            String rst   = (String)    row[3];
                            java.sql.Timestamp rdate = (java.sql.Timestamp) row[4];

                            String stLow = rst != null ? rst.toLowerCase() : "";
                            String badgeClass =
                                stLow.equals("pending")              ? "badge-pending"  :
                                stLow.equals("assigned")             ? "badge-assigned" :
                                stLow.contains("progress")
                             || stLow.contains("work")               ? "badge-progress" :
                                stLow.equals("resolved")             ? "badge-resolved" :
                                stLow.equals("rejected")             ? "badge-rejected" :
                                "badge-rework";

                            // Format date nicely
                            String dateStr = "—";
                            if (rdate != null) {
                                java.text.SimpleDateFormat sdf =
                                    new java.text.SimpleDateFormat("dd MMM yyyy");
                                dateStr = sdf.format(rdate);
                            }
                        %>
                        <tr onclick="location.href='view-report.jsp?id=<%= rid %>'"
                            style="cursor:pointer;">
                            <td style="color:var(--text-3); font-weight:600;">
                                #<%= rid %>
                            </td>
                            <td>
                                <span style="font-weight:500;
                                             color:var(--text-1);">
                                    <%= rtitle %>
                                </span>
                            </td>
                            <td style="color:var(--text-2);">
                                <%= rdept != null ? rdept : "—" %>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %>">
                                    <span class="dot"></span>
                                    <%= rst %>
                                </span>
                            </td>
                            <td>
                                <span class="date-chip"><%= dateStr %></span>
                            </td>
                            <td>
                                <a href="view-report.jsp?id=<%= rid %>"
                                   class="lcps-icon-btn"
                                   title="View Report"
                                   onclick="event.stopPropagation();">
                                    👁️
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div style="padding:12px 22px;
                        border-top:1px solid var(--border);
                        font-size:12.5px;
                        color:var(--text-3);
                        display:flex;
                        justify-content:space-between;
                        align-items:center;">
                <span>
                    Showing <strong style="color:var(--text-2);">
                    <%= filtered.size() %></strong>
                    of <strong style="color:var(--text-2);">
                    <%= total %></strong> report<%= total != 1 ? "s" : "" %>
                </span>
                <a href="report-issue.jsp"
                   class="lcps-btn xs outline">
                    ➕ New Report
                </a>
            </div>
            <% } %>
        </div>

    </div>
</div>

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
function filterTable(query) {
    const rows  = document.querySelectorAll("#reportsTable tbody tr");
    const q     = query.toLowerCase().trim();

    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        row.style.display = text.includes(q) ? "" : "none";
    });
}
</script>

</body>
</html>