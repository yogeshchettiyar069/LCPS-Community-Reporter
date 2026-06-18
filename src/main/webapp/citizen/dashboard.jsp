<%@page import="model.User"%>
<%@page import="operations.ReportOperations"%>
<%@page import="java.util.List"%>
<%@page import="model.Report"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User u = (User) session.getAttribute("user");
    if (u == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations rOps = new ReportOperations();
    List<Report> reports = rOps.getCitizenReports(u.getUserId());

    int total = 0, pending = 0, inProgress = 0, resolved = 0, rejected = 0;

    // Store rows for recent table
    java.util.List<int[]>    ids        = new java.util.ArrayList<>();
    java.util.List<String[]> rowData    = new java.util.ArrayList<>();

    for (Report report : reports) {
        total++;
        String st = report.getStatus();
        if      (st == null)                          { /* skip */ }
        else if (st.equalsIgnoreCase("pending"))      pending++;
        else if (st.toLowerCase().contains("progress")
              || st.equalsIgnoreCase("assigned")
              || st.toLowerCase().contains("work"))   inProgress++;
        else if (st.equalsIgnoreCase("resolved"))     resolved++;
        else if (st.equalsIgnoreCase("rejected"))     rejected++;

        if (rowData.size() < 4) {
            ids.add(new int[]{ report.getReportId() });
            rowData.add(new String[]{
            	report.getTitle(),
            	report.getDeptName() != null ? report.getDeptName() : "—",
                st != null ? st : "Pending"
            });
        }
    }

    int resolvedPct  = total > 0 ? (resolved   * 100 / total) : 0;
    int progressPct  = total > 0 ? (inProgress  * 100 / total) : 0;
    int pendingPct   = total > 0 ? (pending     * 100 / total) : 0;

    String firstName = u.getName().split(" ")[0];
%>
<!DOCTYPE html>
<html>
<head>
<title>Dashboard | LCPS Citizen</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">

<style>
    /* Table scrolling for smaller screens */
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

    /* Tablet and Mobile Views */
    @media (max-width: 992px) {
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 15px;
        }
        .lcps-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }
    }

    /* Strict Mobile View */
    @media (max-width: 768px) {
        .mobile-menu-btn {
            display: block; /* Show hamburger menu */
        }
        .header-nav {
            display: none; /* Hide top nav items to save space */
        }
        .lcps-header {
            flex-wrap: wrap;
            justify-content: space-between;
            padding: 10px 15px;
        }
        .header-right {
            gap: 10px;
        }
        
        /* Stack Layout */
        .lcps-layout {
            display: flex;
            flex-direction: column;
        }
        
        /* Hide sidebar by default on mobile, show when active */
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
        <a href="dashboard.jsp" class="active">Dashboard</a>
        <a href="my-reports.jsp">My Reports</a>
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
            <a href="dashboard.jsp" class="sidebar-link active">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="my-reports.jsp" class="sidebar-link">
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
            <div class="sidebar-label">By Status</div>
            <a href="my-reports.jsp?filter=pending" class="sidebar-link">
                <span class="s-icon">⏳</span> Pending
                <% if (pending > 0) { %>
                <span class="sidebar-badge"><%= pending %></span>
                <% } %>
            </a>
            <a href="my-reports.jsp?filter=progress" class="sidebar-link">
                <span class="s-icon">🔧</span> In Progress
                <% if (inProgress > 0) { %>
                <span class="sidebar-badge"><%= inProgress %></span>
                <% } %>
            </a>
            <a href="my-reports.jsp?filter=resolved" class="sidebar-link">
                <span class="s-icon">✅</span> Resolved
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
                    <span>Home</span>
                    <span class="sep">›</span>
                    <span>Dashboard</span>
                </div>
                <h1>Welcome back, <%= firstName %> 👋</h1>
                <p>Here's an overview of your reported community issues.</p>
            </div>
            <a href="report-issue.jsp" class="lcps-btn">
                ➕ Report New Issue
            </a>
        </div>

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
                <div class="stat-icon-wrap">❌</div>
                <div class="stat-number"><%= rejected %></div>
                <div class="stat-label">Rejected</div>
            </div>
        </div>

        <% if (total > 0) { %>
        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📈</div>
                    Resolution Overview
                </h3>
                <span style="font-size:13px; color:var(--text-2);">
                    Based on your <%= total %> report<%= total > 1 ? "s" : "" %>
                </span>
            </div>
            <div class="card-body">
                <div class="progress-wrap">
                    <div class="progress-meta">
                        <span class="label">✅ Resolved</span>
                        <span class="value"><%= resolved %> / <%= total %></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill green"
                             style="width:<%= resolvedPct %>%"></div>
                    </div>
                </div>
                <div style="height:14px;"></div>
                <div class="progress-wrap">
                    <div class="progress-meta">
                        <span class="label">🔧 In Progress</span>
                        <span class="value"><%= inProgress %> / <%= total %></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill"
                             style="width:<%= progressPct %>%"></div>
                    </div>
                </div>
                <div style="height:14px;"></div>
                <div class="progress-wrap">
                    <div class="progress-meta">
                        <span class="label">⏳ Pending</span>
                        <span class="value"><%= pending %> / <%= total %></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill gold"
                             style="width:<%= pendingPct %>%"></div>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <div class="lcps-card">
            <div class="card-header">
                <h3>
                    <div class="card-icon">📋</div>
                    Recent Reports
                </h3>
                <div style="display:flex; gap:8px;">
                    <a href="report-issue.jsp" class="lcps-btn sm outline">
                        ➕ New
                    </a>
                    <a href="my-reports.jsp" class="lcps-btn sm ghost">
                        View All →
                    </a>
                </div>
            </div>

            <% if (rowData.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">📭</div>
                <h3>No reports yet</h3>
                <p>You haven't submitted any community issues.</p>
                <a href="report-issue.jsp" class="lcps-btn">
                    ➕ Report Your First Issue
                </a>
            </div>
            <% } else { %>
            <div class="table-wrap">
                <table class="lcps-table">
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Title</th>
                            <th>Department</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (int i = 0; i < rowData.size(); i++) {
                            int    rid    = ids.get(i)[0];
                            String rtitle = rowData.get(i)[0];
                            String rdept  = rowData.get(i)[1];
                            String rst    = rowData.get(i)[2];
                            String stLow  = rst.toLowerCase();

                            String badgeClass =
                                stLow.equals("pending")              ? "badge-pending"  :
                                stLow.equals("assigned")             ? "badge-assigned" :
                                stLow.contains("progress")
                             || stLow.contains("work")               ? "badge-progress" :
                                stLow.equals("resolved")             ? "badge-resolved" :
                                stLow.equals("rejected")             ? "badge-rejected" :
                                "badge-rework";
                        %>
                        <tr onclick="location.href='view-report.jsp?id=<%= rid %>'"
                            style="cursor:pointer;">
                            <td style="color:var(--text-3); font-weight:600;">
                                #<%= rid %>
                            </td>
                            <td style="font-weight:500;">
                                <%= rtitle %>
                            </td>
                            <td style="color:var(--text-2);">
                                <%= rdept %>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %>">
                                    <span class="dot"></span>
                                    <%= rst %>
                                </span>
                            </td>
                            <td>
                                <a href="view-report.jsp?id=<%= rid %>"
                                   class="lcps-icon-btn"
                                   title="View"
                                   onclick="event.stopPropagation();">
                                    👁️
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">⚡</div> Quick Actions</h3>
            </div>
            <div class="card-body">
                <div class="lcps-grid">
                    <a href="report-issue.jsp" style="text-decoration:none;">
                        <div class="quick-action-card"
                             style="background:var(--bg-input);
                                    border:1px solid var(--border);
                                    border-radius:var(--r-md);
                                    padding:18px;
                                    transition:border-color 0.2s, transform 0.2s;"
                             onmouseover="this.style.borderColor='var(--border-blue)';this.style.transform='translateY(-2px)'"
                             onmouseout="this.style.borderColor='var(--border)';this.style.transform='translateY(0)'">
                            <div style="font-size:26px; margin-bottom:10px;">🚧</div>
                            <div style="font-weight:600; color:var(--text-1); margin-bottom:4px;">Report Issue</div>
                            <div style="font-size:12px; color:var(--text-3);">Submit a new community problem</div>
                        </div>
                    </a>
                    <a href="my-reports.jsp" style="text-decoration:none;">
                        <div style="background:var(--bg-input);
                                    border:1px solid var(--border);
                                    border-radius:var(--r-md);
                                    padding:18px;
                                    transition:border-color 0.2s, transform 0.2s;"
                             onmouseover="this.style.borderColor='var(--border-blue)';this.style.transform='translateY(-2px)'"
                             onmouseout="this.style.borderColor='var(--border)';this.style.transform='translateY(0)'">
                            <div style="font-size:26px; margin-bottom:10px;">📋</div>
                            <div style="font-weight:600; color:var(--text-1); margin-bottom:4px;">My Reports</div>
                            <div style="font-size:12px; color:var(--text-3);">Track all your submitted issues</div>
                        </div>
                    </a>
                    <a href="my-reports.jsp?filter=resolved" style="text-decoration:none;">
                        <div style="background:var(--bg-input);
                                    border:1px solid var(--border);
                                    border-radius:var(--r-md);
                                    padding:18px;
                                    transition:border-color 0.2s, transform 0.2s;"
                             onmouseover="this.style.borderColor='rgba(16,185,129,0.3)';this.style.transform='translateY(-2px)'"
                             onmouseout="this.style.borderColor='var(--border)';this.style.transform='translateY(0)'">
                            <div style="font-size:26px; margin-bottom:10px;">✅</div>
                            <div style="font-weight:600; color:var(--text-1); margin-bottom:4px;">Resolved Issues</div>
                            <div style="font-size:12px; color:var(--text-3);">View all resolved reports</div>
                        </div>
                    </a>
                </div>
            </div>
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

</body>
</html>