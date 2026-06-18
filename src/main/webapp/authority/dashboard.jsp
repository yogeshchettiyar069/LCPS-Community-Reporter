<%@ page import="model.User, model.Report, java.util.List, java.sql.Timestamp, operations.ReportOperations" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User auth = (User) session.getAttribute("user");
    if (auth == null || auth.getRoleId() != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<Report> deptReports = ops.getDepartmentReports(auth.getDeptId());

    // Store all rows + compute stats
    java.util.List<Object[]> allRows = new java.util.ArrayList<>();
    int total = 0, pending = 0, inProgress = 0, resolved = 0, needsReview = 0;

    for (Report rep : deptReports) {
        total++;
        String st    = rep.getStatus();
        String stLow = st != null ? st.toLowerCase() : "";

        if      (stLow.equals("pending"))                      pending++;
        else if (stLow.equals("assigned")
              || stLow.contains("progress"))                   inProgress++;
        else if (stLow.equals("resolved"))                     resolved++;
        else if (stLow.contains("completed")
              || stLow.contains("rework"))                     needsReview++;

        allRows.add(new Object[]{
            rep.getReportId(),
            rep.getTitle(),
            rep.getCitizenName(),
            st,
            rep.getCreatedAt()
        });
    }

    // Active filter
    String filter = request.getParameter("filter");
    if (filter == null) filter = "all";

    String firstName = auth.getName().split(" ")[0];

    // Success / error flash from update-status / assign-worker
    String flash      = request.getParameter("msg");
    String flashType  = request.getParameter("type"); // success | error
%>
<!DOCTYPE html>
<html>
<head>
<title>Authority Dashboard | LCPS</title>
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
    background: rgba(255,255,255,0.07);
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

/* ===== ACTION BUTTONS IN TABLE ===== */
.action-group {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
    align-items: center;
}

/* Search */
.search-wrap {
    position: relative;
    max-width: 280px;
}

.search-wrap .s-icon {
    position: absolute;
    left: 11px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-3);
    font-size: 13px;
    pointer-events: none;
}

/* Date chip */
.date-chip {
    font-size: 12px;
    color: var(--text-3);
    white-space: nowrap;
}

/* Dept badge */
.dept-badge {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    background: var(--accent-soft);
    border: 1px solid var(--accent-border);
    border-radius: var(--r-full);
    padding: 5px 13px;
    font-size: 12.5px;
    color: var(--accent);
    font-weight: 500;
}

/* ===== MOBILE RESPONSIVE ===== */
.table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; width: 100%; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 992px) {
    .stats-grid { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
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
    .search-wrap { max-width: 100%; width: 100%; }
    .search-wrap input { width: 100%; box-sizing: border-box; }
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
        <a href="assign-worker.jsp">Assign Workers</a>
        <a href="review-work.jsp">Review Work</a>
    </div>
    <div class="header-right">
        <div class="notif-btn" title="Pending Reports">
            🔔
            <% if (pending > 0) { %>
            <div class="notif-dot"></div>
            <% } %>
        </div>
        <div class="user-chip">
            <div class="avatar">
                <%= auth.getName().substring(0,1).toUpperCase() %>
            </div>
            <div>
                <div class="user-info-name"><%= auth.getName() %></div>
                <div class="user-info-role">Authority</div>
            </div>
        </div>
    </div>
</div>

<!-- ===== LAYOUT ===== -->
<div class="lcps-layout">

    <!-- SIDEBAR -->
    <div class="lcps-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Main</div>
            <a href="dashboard.jsp" class="sidebar-link active">
                <span class="s-icon">📊</span> Dashboard
                <% if (total > 0) { %>
                <span class="sidebar-badge"><%= total %></span>
                <% } %>
            </a>
            <a href="assign-worker.jsp" class="sidebar-link">
                <span class="s-icon">👷</span> Assign Workers
            </a>
            <a href="review-work.jsp" class="sidebar-link">
                <span class="s-icon">🔍</span> Review Work
                <% if (needsReview > 0) { %>
                <span class="sidebar-badge"><%= needsReview %></span>
                <% } %>
            </a>
            <a href="update-status.jsp" class="sidebar-link">
                <span class="s-icon">📝</span> Update Status
            </a>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-label">Filter by Status</div>
            <a href="dashboard.jsp?filter=all"
               class="sidebar-link <%= filter.equals("all") ? "active" : "" %>">
                <span class="s-icon">📁</span> All
                <span class="sidebar-badge"><%= total %></span>
            </a>
            <a href="dashboard.jsp?filter=pending"
               class="sidebar-link <%= filter.equals("pending") ? "active" : "" %>">
                <span class="s-icon">⏳</span> Pending
                <% if (pending > 0) { %>
                <span class="sidebar-badge"><%= pending %></span>
                <% } %>
            </a>
            <a href="dashboard.jsp?filter=progress"
               class="sidebar-link <%= filter.equals("progress") ? "active" : "" %>">
                <span class="s-icon">🔧</span> In Progress
                <% if (inProgress > 0) { %>
                <span class="sidebar-badge"><%= inProgress %></span>
                <% } %>
            </a>
            <a href="dashboard.jsp?filter=review"
               class="sidebar-link <%= filter.equals("review") ? "active" : "" %>">
                <span class="s-icon">🔍</span> Needs Review
                <% if (needsReview > 0) { %>
                <span class="sidebar-badge"><%= needsReview %></span>
                <% } %>
            </a>
            <a href="dashboard.jsp?filter=resolved"
               class="sidebar-link <%= filter.equals("resolved") ? "active" : "" %>">
                <span class="s-icon">✅</span> Resolved
                <% if (resolved > 0) { %>
                <span class="sidebar-badge"><%= resolved %></span>
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

    <!-- ===== MAIN ===== -->
    <div class="lcps-main">

        <!-- PAGE HEADER -->
        <div class="page-header">
            <div class="page-header-left">
                <div class="breadcrumb">
                    <span>Authority</span>
                    <span class="sep">›</span>
                    <span>Dashboard</span>
                </div>
                <h1>Welcome, <%= firstName %> 👋</h1>
                <p style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
                    Managing reports for your department
                    <span class="dept-badge">
                        🏢 Dept ID: <%= auth.getDeptId() %>
                    </span>
                </p>
            </div>
        </div>

        <!-- FLASH MESSAGE -->
        <% if (flash != null && !flash.isEmpty()) { %>
        <div class="lcps-alert <%= "error".equals(flashType) ? "error" : "success" %>"
             style="margin-bottom:20px;">
            <span class="alert-icon">
                <%= "error".equals(flashType) ? "⚠️" : "✅" %>
            </span>
            <%= flash %>
        </div>
        <% } %>

        <!-- STAT CARDS -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon-wrap">📋</div>
                <div class="stat-number"><%= total %></div>
                <div class="stat-label">Total Reports</div>
            </div>
            <div class="stat-card gold">
                <div class="stat-icon-wrap">⏳</div>
                <div class="stat-number"><%= pending %></div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card purple">
                <div class="stat-icon-wrap">🔧</div>
                <div class="stat-number"><%= inProgress %></div>
                <div class="stat-label">In Progress</div>
            </div>
            <div class="stat-card green">
                <div class="stat-icon-wrap">✅</div>
                <div class="stat-number"><%= resolved %></div>
                <div class="stat-label">Resolved</div>
            </div>
            <div class="stat-card red">
                <div class="stat-icon-wrap">🔍</div>
                <div class="stat-number"><%= needsReview %></div>
                <div class="stat-label">Needs Review</div>
            </div>
        </div>

        <!-- FILTER TABS -->
        <div class="filter-tabs">
            <a href="dashboard.jsp?filter=all"
               class="filter-tab <%= filter.equals("all") ? "active" : "" %>">
                📁 All <span class="tab-count"><%= total %></span>
            </a>
            <a href="dashboard.jsp?filter=pending"
               class="filter-tab <%= filter.equals("pending") ? "active" : "" %>">
                ⏳ Pending <span class="tab-count"><%= pending %></span>
            </a>
            <a href="dashboard.jsp?filter=progress"
               class="filter-tab <%= filter.equals("progress") ? "active" : "" %>">
                🔧 In Progress <span class="tab-count"><%= inProgress %></span>
            </a>
            <a href="dashboard.jsp?filter=review"
               class="filter-tab <%= filter.equals("review") ? "active" : "" %>">
                🔍 Needs Review <span class="tab-count"><%= needsReview %></span>
            </a>
            <a href="dashboard.jsp?filter=resolved"
               class="filter-tab <%= filter.equals("resolved") ? "active" : "" %>">
                ✅ Resolved <span class="tab-count"><%= resolved %></span>
            </a>
        </div>

        <!-- REPORTS TABLE CARD -->
        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📋</div>
                    Department Reports
                </h3>
                <div class="search-wrap">
                    <span class="s-icon">🔍</span>
                    <input class="lcps-input sm"
                           type="text"
                           id="searchInput"
                           placeholder="Search reports..."
                           oninput="filterTable(this.value)"
                           style="padding-left:32px; font-size:13px;">
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
                                                    || stLow.contains("progress"))) ||
                        (filter.equals("review")   && (stLow.contains("completed")
                                                    || stLow.contains("rework")))   ||
                        (filter.equals("resolved") && stLow.equals("resolved"));
                    if (show) filtered.add(row);
                }
            %>

            <% if (filtered.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">📭</div>
                <h3>No reports found</h3>
                <p>No reports match the current filter.</p>
                <a href="dashboard.jsp" class="lcps-btn outline">
                    View All Reports
                </a>
            </div>

            <% } else { %>
            <div class="table-wrap">
                <table class="lcps-table" id="reportsTable">
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Title</th>
                            <th>Citizen</th>
                            <th>Status</th>
                            <th>Submitted</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        java.text.SimpleDateFormat sdf =
                            new java.text.SimpleDateFormat("dd MMM yyyy");

                        for (Object[] row : filtered) {
                            int    rid    = (int)    row[0];
                            String rtitle = (String) row[1];
                            String rcit   = (String) row[2];
                            String rst    = (String) row[3];
                            java.sql.Timestamp rdate = (java.sql.Timestamp) row[4];

                            String stLow = rst != null ? rst.toLowerCase() : "";
                            String badgeClass =
                                stLow.equals("pending")            ? "badge-pending"  :
                                stLow.equals("assigned")           ? "badge-assigned" :
                                stLow.contains("progress")         ? "badge-progress" :
                                stLow.equals("resolved")           ? "badge-resolved" :
                                stLow.equals("rejected")           ? "badge-rejected" :
                                "badge-rework";

                            String dateStr = rdate != null
                                ? sdf.format(rdate) : "—";

                            boolean canAssign  = stLow.equals("pending")
                                              || stLow.equals("assigned");
                            boolean canReview  = stLow.contains("completed")
                                              || stLow.contains("rework");
                    %>
                    <tr>
                        <td style="color:var(--text-3); font-weight:600;">
                            #<%= rid %>
                        </td>
                        <td>
                            <span style="font-weight:500; color:var(--text-1);">
                                <%= rtitle %>
                            </span>
                        </td>
                        <td style="color:var(--text-2);">
                            <%= rcit != null ? rcit : "—" %>
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
                            <div class="action-group">

                                <!-- View -->
                                <a href="../citizen/view-report.jsp?id=<%= rid %>"
                                   class="lcps-icon-btn"
                                   title="View Report">
                                    👁️
                                </a>

                                <!-- Assign Worker -->
                                <% if (canAssign) { %>
                                <a href="assign-worker.jsp?reportId=<%= rid %>"
                                   class="lcps-btn xs outline"
                                   title="Assign Worker">
                                    👷 Assign
                                </a>
                                <% } %>

                                <!-- Review Work -->
                                <% if (canReview) { %>
                                <a href="review-work.jsp?reportId=<%= rid %>"
                                   class="lcps-btn xs"
                                   title="Review Completed Work">
                                    🔍 Review
                                </a>
                                <% } %>

                                <!-- Update Status -->
                                <a href="update-status.jsp?reportId=<%= rid %>"
                                   class="lcps-btn xs ghost"
                                   title="Update Status">
                                    📝 Status
                                </a>

                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Row count footer -->
            <div style="padding:12px 22px;
                        border-top: 1px solid var(--border);
                        font-size:12.5px;
                        color:var(--text-3);
                        display:flex;
                        justify-content:space-between;
                        align-items:center;">
                <span>
                    Showing
                    <strong style="color:var(--text-2);">
                        <%= filtered.size() %>
                    </strong>
                    of
                    <strong style="color:var(--text-2);">
                        <%= total %>
                    </strong>
                    report<%= total != 1 ? "s" : "" %>
                </span>
                <span style="color:var(--text-4); font-size:12px;">
                    Last updated: just now
                </span>
            </div>
            <% } %>
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

<!-- ===== SCRIPTS ===== -->
<script>
function filterTable(query) {
    const rows = document.querySelectorAll("#reportsTable tbody tr");
    const q    = query.toLowerCase().trim();
    rows.forEach(row => {
        row.style.display = row.innerText.toLowerCase().includes(q) ? "" : "none";
    });
}
</script>

</body>
</html>
