<%@ page import="model.User, model.Report, model.StatusTimeline, java.util.List, java.sql.Timestamp, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User u = (User) session.getAttribute("user");
    if (u == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int role = u.getRoleId(); // 2=citizen, 3=authority, 4=worker

    // Role-based URLs
    String backUrl  = (role == 3) ? "../authority/dashboard.jsp" : "my-reports.jsp";
    String dashUrl  = "dashboard.jsp";

    int reportId = 0;
    try {
        reportId = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        response.sendRedirect(backUrl);
        return;
    }

    ReportOperations ops = new ReportOperations();

    Report report = ops.getReportDetails(reportId);

    if (report == null) {
        response.sendRedirect(backUrl);
        return;
    }

    java.util.List<String> beforePaths = ops.getReportImages(reportId);
    java.util.List<String> afterPaths  = ops.getAfterImagesForCitizen(reportId);
    java.util.List<StatusTimeline> timeline = ops.getReportTimeline(reportId);

    String title       = report.getTitle();
    String description = report.getDescription();
    String severity    = report.getSeverity();
    String status      = report.getStatus();
    String deptName    = report.getDeptName();
    String citizenName = report.getCitizenName();
    double lat         = report.getLatitude();
    double lng         = report.getLongitude();
    int    deptId      = report.getDeptId();
    java.sql.Timestamp createdAt = report.getCreatedAt();

    boolean hasLocation = (lat != 0.0 && lng != 0.0);
    boolean isResolved  = status != null && status.equalsIgnoreCase("Resolved");

    // Resolution time predictor
    double avgHrs  = ops.getAvgResolutionHoursForDept(deptId);
    String estTime = ReportOperations.formatResolutionTime(avgHrs);

    String timeSpeedClass = "nodata";
    String pillClass      = "pill-nodata";
    String pillLabel      = "No Data Yet";
    if      (avgHrs > 0 && avgHrs <= 48)   { timeSpeedClass = "fast";   pillClass = "pill-fast";   pillLabel = "⚡ Fast Department"; }
    else if (avgHrs > 48 && avgHrs <= 120) { timeSpeedClass = "medium"; pillClass = "pill-medium"; pillLabel = "🕐 Average Department"; }
    else if (avgHrs > 120)                 { timeSpeedClass = "slow";   pillClass = "pill-slow";   pillLabel = "🐢 Slow Department"; }

    String stLow = status != null ? status.toLowerCase() : "";
    String badgeClass =
        stLow.equals("pending")          ? "badge-pending"  :
        stLow.equals("assigned")         ? "badge-assigned" :
        stLow.contains("progress")
     || stLow.contains("work")           ? "badge-progress" :
        stLow.equals("resolved")         ? "badge-resolved" :
        stLow.equals("rejected")         ? "badge-rejected" :
        "badge-rework";

    String sevLow = severity != null ? severity.toLowerCase() : "low";

    SimpleDateFormat sdf     = new SimpleDateFormat("dd MMM yyyy, HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd MMM yyyy");
    String createdStr = createdAt != null ? sdfDate.format(createdAt) : "—";

    // before/after image lists and the status timeline are loaded above
%>
<!DOCTYPE html>
<html>
<head>
<title>Report #<%= reportId %> | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">

<% if (hasLocation) { %>
<script>
function initMap() {
    const lat = <%= lat %>;
    const lng = <%= lng %>;
    const loc = { lat, lng };

    const map = new google.maps.Map(document.getElementById("reportMap"), {
        center: loc,
        zoom: 16,
        mapTypeId: "roadmap",
        styles: [
            { elementType: "geometry",        stylers: [{ color: "#0d1526" }] },
            { elementType: "labels.text.fill",stylers: [{ color: "#8ba3c7" }] },
            { elementType: "labels.text.stroke",stylers:[{ color: "#0d1526" }] },
            { featureType: "road", elementType: "geometry",
              stylers: [{ color: "#1c2d4f" }] },
            { featureType: "water", elementType: "geometry",
              stylers: [{ color: "#080d16" }] },
            { featureType: "poi", stylers: [{ visibility: "off" }] }
        ]
    });

    new google.maps.Marker({
        position: loc,
        map: map,
        title: "Issue Location",
        animation: google.maps.Animation.DROP
    });
}

window.gm_authFailure = function() {
    const el = document.getElementById("mapError");
    if (el) {
        el.style.display = "block";
        el.textContent   = "❌ Map failed to load. Invalid API Key.";
    }
};
</script>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCCLubAIgVpcz8kJNlbeAN1jsFBSeelubg&callback=initMap"
        async defer></script>
<% } %>

<style>
#reportMap {
    width: 100%;
    height: 280px;
    border-radius: var(--r-md);
    border: 1px solid var(--border-md);
    overflow: hidden;
}

#mapError { display: none; margin-top: 10px; }

.detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}

.detail-item {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-sm);
    padding: 13px 16px;
}

.detail-item.full { grid-column: 1 / -1; }

.detail-item-label {
    font-size: 11.5px;
    color: var(--text-3);
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 5px;
}

.detail-item-value {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-1);
}

.detail-item-value.desc {
    font-weight: 400;
    color: var(--text-2);
    font-size: 13.5px;
    line-height: 1.6;
}

.predictor-wrap {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 4px 0;
}

.predictor-icon-lg { font-size: 40px; flex-shrink: 0; }

.predictor-time {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 5px;
    line-height: 1.2;
}

.predictor-time.fast   { color: var(--green); }
.predictor-time.medium { color: var(--gold); }
.predictor-time.slow   { color: var(--red); }
.predictor-time.nodata { color: var(--text-3); font-size: 16px; font-weight: 500; }

.predictor-sub {
    font-size: 12.5px;
    color: var(--text-2);
    line-height: 1.6;
    margin-bottom: 8px;
}

.speed-pill {
    display: inline-flex;
    align-items: center;
    padding: 3px 12px;
    border-radius: var(--r-full);
    font-size: 11.5px;
    font-weight: 600;
}

.pill-fast   { background:rgba(16,185,129,0.12); color:var(--green); border:1px solid rgba(16,185,129,0.3); }
.pill-medium { background:rgba(245,158,11,0.12);  color:var(--gold);  border:1px solid rgba(245,158,11,0.3); }
.pill-slow   { background:rgba(239,68,68,0.12);   color:var(--red);   border:1px solid rgba(239,68,68,0.3); }
.pill-nodata { background:var(--bg-surface);      color:var(--text-3); border:1px solid var(--border); }

.images-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 12px;
}

.images-grid img {
    width: 100%;
    height: 140px;
    object-fit: cover;
    border-radius: var(--r-sm);
    border: 1px solid var(--border-md);
    cursor: pointer;
    transition: transform 0.2s, border-color 0.2s;
}

.images-grid img:hover {
    transform: scale(1.03);
    border-color: var(--border-blue);
}

#lightbox {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.92);
    z-index: 9999;
    justify-content: center;
    align-items: center;
    backdrop-filter: blur(4px);
}

#lightbox img {
    max-width: 90vw;
    max-height: 85vh;
    border-radius: var(--r-md);
    border: 1px solid var(--border-md);
}

#lightbox-close {
    position: absolute;
    top: 20px;
    right: 24px;
    font-size: 28px;
    color: var(--text-2);
    cursor: pointer;
    background: none;
    border: none;
    line-height: 1;
}

.timeline-wrap { position: relative; padding: 8px 0; }

.timeline-item {
    display: flex;
    gap: 16px;
    position: relative;
    padding-bottom: 24px;
}

.timeline-item:last-child { padding-bottom: 0; }

.timeline-item:not(:last-child)::before {
    content: "";
    position: absolute;
    left: 11px;
    top: 24px;
    width: 2px;
    bottom: 0;
    background: var(--border-md);
}

.tl-dot {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    border: 2px solid var(--border-md);
    background: var(--bg-input);
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 10px;
    z-index: 1;
}

.tl-dot.done     { background:var(--green);  border-color:var(--green);  color:#fff; }
.tl-dot.active   { background:var(--accent); border-color:var(--accent); color:#fff; box-shadow:var(--glow-blue); }
.tl-dot.rejected { background:var(--red);    border-color:var(--red);    color:#fff; }

.tl-body  { flex: 1; }
.tl-status { font-size:14px; font-weight:600; color:var(--text-1); margin-bottom:3px; }
.tl-meta   { font-size:12px; color:var(--text-3); }

.coord-chips { display:flex; gap:10px; margin-bottom:12px; }

.coord-chip {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-sm);
    padding: 6px 12px;
    font-size: 12px;
    font-family: monospace;
    color: var(--green);
}

/* Authority-only action bar */
.authority-actions {
    display: flex;
    gap: 10px;
    padding: 14px 16px;
    background: rgba(79,142,247,0.06);
    border: 1px solid rgba(79,142,247,0.2);
    border-radius: var(--r-md);
    margin-bottom: 20px;
    align-items: center;
    flex-wrap: wrap;
}

.authority-actions-label {
    font-size: 12.5px;
    color: var(--text-3);
    font-weight: 500;
    margin-right: 4px;
}

/* ===== RESPONSIVE OVERRIDES ===== */
.mobile-menu-btn {
    display: none;
    font-size: 24px;
    cursor: pointer;
    padding: 5px;
    user-select: none;
}

@media (max-width: 768px) {
    .mobile-menu-btn { display: block; }
    .header-nav { display: none; }
    
    .lcps-header {
        flex-wrap: wrap;
        justify-content: space-between;
        padding: 10px 15px;
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
    .lcps-sidebar.active { display: block; }

    /* Detail Grid Stacking */
    .detail-grid { grid-template-columns: 1fr; }
    .detail-item.full { grid-column: auto; }

    /* Predictor Wrap Adjustments */
    .predictor-wrap { 
        flex-direction: column; 
        align-items: flex-start; 
        gap: 12px; 
    }

    /* Authority Action Buttons */
    .authority-actions {
        flex-direction: column;
        align-items: stretch;
    }
    .authority-actions .lcps-btn {
        width: 100%;
        text-align: center;
        justify-content: center;
    }

    /* Coordinate Chips */
    .coord-chips { flex-wrap: wrap; }

    /* Footer */
    .lcps-footer {
        flex-direction: column;
        text-align: center;
        gap: 10px;
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
        <a href="<%= dashUrl %>" class="logo">
            <div class="logo-icon">🏛️</div>
            <div>
                <div class="logo-text-main">LC<span>PS</span></div>
                <div class="logo-text-sub">Community Problem Solver</div>
            </div>
        </a>
    </div>
    <div class="header-nav">
        <a href="<%= dashUrl %>">Dashboard</a>
        <% if (role == 2) { %>
            <a href="my-reports.jsp" class="active">My Reports</a>
            <a href="report-issue.jsp">Report Issue</a>
        <% } else if (role == 3) { %>
            <a href="assign-worker.jsp">Assign Workers</a>
            <a href="review-work.jsp">Review Work</a>
        <% } %>
    </div>
    <div class="header-right">
        <div class="user-chip">
            <div class="avatar">
                <%= u.getName().substring(0,1).toUpperCase() %>
            </div>
            <div>
                <div class="user-info-name"><%= u.getName() %></div>
                <div class="user-info-role">
                    <%= role == 2 ? "Citizen" : role == 3 ? "Authority" : "Worker" %>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="lcps-layout">

    <div class="lcps-sidebar">
        <div class="sidebar-section">
            <% if (role == 2) { %>
            <div class="sidebar-label">Main</div>
            <a href="dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="my-reports.jsp" class="sidebar-link active">
                <span class="s-icon">📋</span> My Reports
            </a>
            <a href="report-issue.jsp" class="sidebar-link">
                <span class="s-icon">➕</span> Report Issue
            </a>
            <% } else if (role == 3) { %>
            <div class="sidebar-label">Authority</div>
            <a href="../authority/dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="../authority/assign-worker.jsp" class="sidebar-link">
                <span class="s-icon">👷</span> Assign Workers
            </a>
            <a href="../authority/review-work.jsp" class="sidebar-link">
                <span class="s-icon">🔍</span> Review Work
            </a>
            <a href="../authority/update-status.jsp" class="sidebar-link">
                <span class="s-icon">📝</span> Update Status
            </a>
            <% } %>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-label">This Report</div>
            <div style="padding:4px 0; font-size:13px;">
                <div style="color:var(--text-3); margin-bottom:8px;">Report ID</div>
                <div style="font-weight:700; color:var(--text-1);
                            font-size:18px; margin-bottom:12px;">
                    #<%= reportId %>
                </div>
                <div style="color:var(--text-3); margin-bottom:5px;">Status</div>
                <span class="badge <%= badgeClass %>"
                      style="margin-bottom:12px; display:inline-flex;">
                    <span class="dot"></span><%= status %>
                </span>
                <div style="color:var(--text-3);
                            margin-top:8px; margin-bottom:5px;">
                    Severity
                </div>
                <span class="severity <%= sevLow %>" style="display:inline-flex;">
                    <span class="sev-dot"></span><%= severity %>
                </span>
                <div style="color:var(--text-3);
                            margin-top:12px; margin-bottom:5px;">
                    Submitted
                </div>
                <div style="color:var(--text-2); font-size:12.5px;">
                    <%= createdStr %>
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

    <div class="lcps-main">

        <div class="page-header">
            <div class="page-header-left">
                <div class="breadcrumb">
                    <a href="<%= dashUrl %>">Home</a>
                    <span class="sep">›</span>
                    <% if (role == 2) { %>
                        <a href="my-reports.jsp">My Reports</a>
                    <% } else { %>
                        <a href="../authority/dashboard.jsp">Dashboard</a>
                    <% } %>
                    <span class="sep">›</span>
                    <span>Report #<%= reportId %></span>
                </div>
                <h1 style="display:flex; align-items:center;
                            gap:12px; flex-wrap:wrap;">
                    <%= title %>
                    <span class="badge <%= badgeClass %>">
                        <span class="dot"></span><%= status %>
                    </span>
                </h1>
                <p>
                    Submitted by
                    <strong style="color:var(--text-1);"><%= citizenName %></strong>
                    &nbsp;·&nbsp;
                    <span style="color:var(--text-3);"><%= createdStr %></span>
                </p>
            </div>
            <a href="<%= backUrl %>" class="lcps-btn ghost">← Back</a>
        </div>

        <% if (role == 3) { %>
        <div class="authority-actions">
            <span class="authority-actions-label">🔧 Authority Actions:</span>
            <a href="../authority/update-status.jsp?reportId=<%= reportId %>"
               class="lcps-btn sm">
                📝 Update Status
            </a>
            <a href="../authority/assign-worker.jsp?reportId=<%= reportId %>"
               class="lcps-btn sm outline">
                👷 Assign Worker
            </a>
            <a href="../authority/review-work.jsp?reportId=<%= reportId %>"
               class="lcps-btn sm outline">
                🔍 Review Work
            </a>
        </div>
        <% } %>

        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">📋</div> Report Details</h3>
            </div>
            <div class="card-body">
                <div class="detail-grid">
                    <div class="detail-item">
                        <div class="detail-item-label">Department</div>
                        <div class="detail-item-value">
                            <%= deptName != null ? deptName : "—" %>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-item-label">Severity</div>
                        <div class="detail-item-value">
                            <span class="severity <%= sevLow %>">
                                <span class="sev-dot"></span><%= severity %>
                            </span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-item-label">Current Status</div>
                        <div class="detail-item-value">
                            <span class="badge <%= badgeClass %>">
                                <span class="dot"></span><%= status %>
                            </span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-item-label">Submitted On</div>
                        <div class="detail-item-value"><%= createdStr %></div>
                    </div>
                    <div class="detail-item full">
                        <div class="detail-item-label">Description</div>
                        <div class="detail-item-value desc"><%= description %></div>
                    </div>
                </div>
            </div>
        </div>

        <% if (!isResolved) { %>
        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">⏱️</div> Estimated Resolution Time</h3>
                <span class="speed-pill <%= pillClass %>"><%= pillLabel %></span>
            </div>
            <div class="card-body">
                <div class="predictor-wrap">
                    <div class="predictor-icon-lg">📊</div>
                    <div>
                        <div class="predictor-time <%= timeSpeedClass %>">
                            <%= estTime %>
                        </div>
                        <% if (avgHrs > 0) { %>
                        <div class="predictor-sub">
                            Based on historical resolution data for the
                            <strong style="color:var(--text-1);"><%= deptName %></strong>
                            department. Actual time may vary based on issue complexity.
                        </div>
                        <% } else { %>
                        <div class="predictor-sub">
                            Not enough historical data for
                            <strong style="color:var(--text-1);"><%= deptName %></strong>
                            yet. Check back once more reports are resolved.
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">🕒</div> Status Timeline</h3>
            </div>
            <div class="card-body">
                <div class="timeline-wrap">
                <%
                    boolean hasTimeline = false;
                    for (StatusTimeline t : timeline) {
                        hasTimeline = true;
                        String tStatus = t.getStatus();
                        String tUser   = t.getUpdatedBy();
                        String tTime   = sdf.format(t.getUpdatedAt());
                        String tLow    = tStatus != null ? tStatus.toLowerCase() : "";

                        String dotCls =
                            tLow.equals("resolved")        ? "done"     :
                            tLow.contains("rework")
                         || tLow.equals("rejected")        ? "rejected" :
                            tLow.equals("pending")         ? ""         :
                            "active";

                        String dotIcon =
                            tLow.equals("resolved")  ? "✓" :
                            tLow.contains("rework")
                         || tLow.equals("rejected")  ? "✕" : "•";
                %>
                <div class="timeline-item">
                    <div class="tl-dot <%= dotCls %>"><%= dotIcon %></div>
                    <div class="tl-body">
                        <div class="tl-status"><%= tStatus %></div>
                        <div class="tl-meta">
                            By <%= tUser %> &nbsp;·&nbsp; <%= tTime %>
                        </div>
                    </div>
                </div>
                <% } %>
                <% if (!hasTimeline) { %>
                <div class="empty-state" style="padding:20px 0;">
                    <div class="empty-icon">📭</div>
                    <p>No timeline entries yet.</p>
                </div>
                <% } %>
                </div>
            </div>
        </div>

        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">📍</div> Issue Location</h3>
                <% if (hasLocation) { %>
                <div style="font-size:12px; color:var(--text-3);">
                    <%= lat %>, <%= lng %>
                </div>
                <% } %>
            </div>
            <div class="card-body">
                <% if (hasLocation) { %>
                <div class="coord-chips">
                    <div class="coord-chip">📍 Lat: <%= lat %></div>
                    <div class="coord-chip">📍 Lng: <%= lng %></div>
                </div>
                <div id="reportMap"></div>
                <div id="mapError" class="lcps-alert error"></div>
                <% } else { %>
                <div class="lcps-alert info">
                    <span class="alert-icon">ℹ️</span>
                    No location data was attached to this report.
                </div>
                <% } %>
            </div>
        </div>

        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">📸</div> Before Images</h3>
                <span style="font-size:12px; color:var(--text-3);">
                    <%= beforePaths.size() %> image<%= beforePaths.size()!=1?"s":"" %>
                </span>
            </div>
            <div class="card-body">
                <% if (beforePaths.isEmpty()) { %>
                <div class="lcps-alert info">
                    <span class="alert-icon">ℹ️</span>
                    No before images uploaded.
                </div>
                <% } else { %>
                <div class="images-grid">
                    <% for (String path : beforePaths) { %>
                    <img src="<%= request.getContextPath()+"/"+path %>"
                         alt="Before"
                         onclick="openLightbox(this.src)">
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">✅</div> After Work Images</h3>
                <% if (isResolved) { %>
                <span class="badge badge-resolved">
                    <span class="dot"></span>Resolved
                </span>
                <% } %>
            </div>
            <div class="card-body">
                <% if (afterPaths.isEmpty()) { %>
                <div class="lcps-alert info">
                    <span class="alert-icon">🔒</span>
                    After-work images will appear once the authority
                    approves the completed work.
                </div>
                <% } else { %>
                <div class="images-grid">
                    <% for (String path : afterPaths) { %>
                    <img src="<%= request.getContextPath()+"/"+path %>"
                         alt="After"
                         onclick="openLightbox(this.src)">
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

    </div>
</div>

<div class="lcps-footer">
    <div class="f-left">© 2026 <span>LCPS</span> — Local Community Problem Solver</div>
    <div class="f-right">
        <a href="#">Help</a>
        <a href="#">Privacy</a>
        <span>v2.0</span>
    </div>
</div>

<div id="lightbox" onclick="closeLightbox()">
    <button id="lightbox-close" onclick="closeLightbox()">✕</button>
    <img id="lightbox-img" src="" alt="Preview">
</div>

<script>
function openLightbox(src) {
    document.getElementById("lightbox-img").src = src;
    document.getElementById("lightbox").style.display = "flex";
    document.body.style.overflow = "hidden";
}

function closeLightbox() {
    document.getElementById("lightbox").style.display = "none";
    document.body.style.overflow = "";
}

document.addEventListener("keydown", e => {
    if (e.key === "Escape") closeLightbox();
});
</script>

</body>
</html>