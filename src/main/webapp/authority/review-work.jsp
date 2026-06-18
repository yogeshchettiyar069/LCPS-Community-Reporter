<%@ page import="model.User, model.Report, model.StatusTimeline, java.util.List, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User auth = (User) session.getAttribute("user");
    if (auth == null || auth.getRoleId() != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int reportId = 0;
    try {
        reportId = Integer.parseInt(request.getParameter("reportId"));
    } catch (Exception e) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();

    Report report = ops.getReportDetails(reportId);

    if (report == null) {
        response.sendRedirect("dashboard.jsp?msg=Report+not+found&type=error");
        return;
    }

    List<String> afterPaths  = ops.getAfterImagesForAuthority(reportId);
    List<String> beforePaths = ops.getReportImages(reportId);
    List<StatusTimeline> timeline = ops.getReportTimeline(reportId);

    String rTitle  = report.getTitle();
    String rDesc   = report.getDescription();
    String rStatus = report.getStatus();
    String rSev    = report.getSeverity();
    String rDept   = report.getDeptName();
    String rCit    = report.getCitizenName();

    String stLow = rStatus != null ? rStatus.toLowerCase() : "";
    String badgeClass =
        stLow.equals("pending")        ? "badge-pending"  :
        stLow.equals("assigned")       ? "badge-assigned" :
        stLow.contains("progress")     ? "badge-progress" :
        stLow.equals("resolved")       ? "badge-resolved" :
        stLow.contains("rework")       ? "badge-rework"   :
        stLow.equals("rejected")       ? "badge-rejected" :
        "badge-progress";

    String sevLow = rSev != null ? rSev.toLowerCase() : "low";

    // Check if already reviewed
    boolean alreadyResolved = stLow.equals("resolved");
    boolean alreadyRework   = stLow.contains("rework");

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");

    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");
%>
<!DOCTYPE html>
<html>
<head>
<title>Review Work | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== IMAGE COMPARISON ===== */
.img-compare-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.img-col-title {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-2);
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 7px;
}

.images-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
    gap: 10px;
}

.images-grid img {
    width: 100%;
    height: 120px;
    object-fit: cover;
    border-radius: var(--r-sm);
    border: 1px solid var(--border-md);
    cursor: pointer;
    transition: transform 0.2s, border-color 0.2s;
}

.images-grid img:hover {
    transform: scale(1.04);
    border-color: var(--border-blue);
}

/* ===== DECISION CARDS ===== */
.decision-cards {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
    margin-bottom: 20px;
}

.decision-card {
    padding: 18px;
    border-radius: var(--r-md);
    border: 2px solid var(--border-md);
    cursor: pointer;
    transition: all 0.2s;
    text-align: center;
    background: var(--bg-input);
}

.decision-card:hover { transform: translateY(-2px); }

.decision-card.approve {
    border-color: rgba(16,185,129,0.3);
    background: rgba(16,185,129,0.05);
}

.decision-card.approve:hover {
    border-color: var(--green);
    background: rgba(16,185,129,0.1);
    box-shadow: 0 0 0 3px rgba(16,185,129,0.15);
}

.decision-card.reject {
    border-color: rgba(239,68,68,0.3);
    background: rgba(239,68,68,0.05);
}

.decision-card.reject:hover {
    border-color: var(--red);
    background: rgba(239,68,68,0.1);
    box-shadow: 0 0 0 3px rgba(239,68,68,0.15);
}

.decision-card.selected-approve {
    border-color: var(--green);
    background: rgba(16,185,129,0.12);
    box-shadow: 0 0 0 3px rgba(16,185,129,0.2);
}

.decision-card.selected-reject {
    border-color: var(--red);
    background: rgba(239,68,68,0.12);
    box-shadow: 0 0 0 3px rgba(239,68,68,0.2);
}

.decision-icon { font-size: 32px; margin-bottom: 8px; }

.decision-title {
    font-size: 15px;
    font-weight: 700;
    margin-bottom: 4px;
}

.decision-card.approve .decision-title { color: var(--green); }
.decision-card.reject  .decision-title { color: var(--red); }

.decision-desc {
    font-size: 12px;
    color: var(--text-3);
    line-height: 1.5;
}

/* Already reviewed banner */
.reviewed-banner {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 16px 20px;
    border-radius: var(--r-md);
    margin-bottom: 4px;
}

.reviewed-banner.resolved {
    background: rgba(16,185,129,0.1);
    border: 1px solid rgba(16,185,129,0.3);
}

.reviewed-banner.rework {
    background: rgba(168,85,247,0.1);
    border: 1px solid rgba(168,85,247,0.3);
}

/* ===== TIMELINE ===== */
.timeline-item {
    display: flex;
    gap: 14px;
    padding-bottom: 18px;
    position: relative;
}

.timeline-item:last-child { padding-bottom: 0; }

.timeline-item:not(:last-child)::before {
    content: "";
    position: absolute;
    left: 10px;
    top: 22px;
    width: 2px;
    bottom: 0;
    background: var(--border-md);
}

.tl-dot {
    width: 22px;
    height: 22px;
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

.tl-status { font-size:13px; font-weight:600; color:var(--text-1); margin-bottom:2px; }
.tl-meta   { font-size:11.5px; color:var(--text-3); }

/* Lightbox */
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
}
#lightbox-close {
    position: absolute;
    top: 20px; right: 24px;
    font-size: 28px;
    color: var(--text-2);
    cursor: pointer;
    background: none;
    border: none;
}

/* ===== CONTENT SPLIT + MOBILE RESPONSIVE ===== */
.lcps-split { display: grid; grid-template-columns: 1fr 320px; gap: 20px; align-items: start; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 992px) {
    .lcps-split { grid-template-columns: 1fr; }
    .img-compare-grid { grid-template-columns: 1fr; }
    .decision-cards { grid-template-columns: 1fr; }
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
        <a href="assign-worker.jsp">Assign Workers</a>
        <a href="review-work.jsp" class="active">Review Work</a>
    </div>
    <div class="header-right">
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
            <div class="sidebar-label">Authority</div>
            <a href="dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="assign-worker.jsp" class="sidebar-link">
                <span class="s-icon">👷</span> Assign Workers
            </a>
            <a href="review-work.jsp" class="sidebar-link active">
                <span class="s-icon">🔍</span> Review Work
            </a>
            <a href="update-status.jsp" class="sidebar-link">
                <span class="s-icon">📝</span> Update Status
            </a>
        </div>

        <!-- Report quick info -->
        <div class="sidebar-section">
            <div class="sidebar-label">This Report</div>
            <div style="padding:4px 0; font-size:13px;">
                <div style="color:var(--text-3); margin-bottom:5px;">ID</div>
                <div style="font-weight:700; color:var(--text-1);
                            font-size:18px; margin-bottom:12px;">
                    #<%= reportId %>
                </div>
                <div style="color:var(--text-3); margin-bottom:5px;">Status</div>
                <span class="badge <%= badgeClass %>"
                      style="display:inline-flex; margin-bottom:12px;">
                    <span class="dot"></span><%= rStatus %>
                </span>
                <div style="color:var(--text-3); margin-top:4px; margin-bottom:5px;">
                    Severity
                </div>
                <span class="severity <%= sevLow %>" style="display:inline-flex;">
                    <span class="sev-dot"></span><%= rSev %>
                </span>
                <div style="color:var(--text-3); margin-top:12px; margin-bottom:5px;">
                    After Images
                </div>
                <div style="font-weight:700; color:var(--text-1); font-size:18px;">
                    <%= afterPaths.size() %>
                </div>
            </div>
        </div>

        <div class="sidebar-divider"></div>
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
                    <a href="dashboard.jsp">Dashboard</a>
                    <span class="sep">›</span>
                    <span>Review Work</span>
                </div>
                <h1 style="display:flex; align-items:center;
                            gap:12px; flex-wrap:wrap;">
                    Review Work
                    <span class="badge <%= badgeClass %>">
                        <span class="dot"></span><%= rStatus %>
                    </span>
                </h1>
                <p>
                    Report #<%= reportId %> —
                    <strong style="color:var(--text-1);"><%= rTitle %></strong>
                </p>
            </div>
            <a href="dashboard.jsp" class="lcps-btn ghost">← Back</a>
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

        <div class="lcps-split">

            <!-- LEFT COLUMN -->
            <div>

                <!-- REPORT DETAILS -->
                <div class="lcps-card" style="margin-bottom:20px;">
                    <div class="card-header">
                        <h3><div class="card-icon">📋</div> Report Details</h3>
                        <a href="../citizen/view-report.jsp?id=<%= reportId %>"
                           class="lcps-btn xs ghost">👁️ Full View</a>
                    </div>
                    <div class="card-body">
                        <div style="display:grid;
                                    grid-template-columns:1fr 1fr;
                                    gap:12px;">
                            <div style="background:var(--bg-surface);
                                        border:1px solid var(--border);
                                        border-radius:var(--r-sm);
                                        padding:12px 14px;">
                                <div style="font-size:11px; color:var(--text-3);
                                            text-transform:uppercase;
                                            letter-spacing:0.5px; margin-bottom:4px;">
                                    Citizen
                                </div>
                                <div style="font-weight:600; color:var(--text-1);">
                                    <%= rCit != null ? rCit : "—" %>
                                </div>
                            </div>
                            <div style="background:var(--bg-surface);
                                        border:1px solid var(--border);
                                        border-radius:var(--r-sm);
                                        padding:12px 14px;">
                                <div style="font-size:11px; color:var(--text-3);
                                            text-transform:uppercase;
                                            letter-spacing:0.5px; margin-bottom:4px;">
                                    Department
                                </div>
                                <div style="font-weight:600; color:var(--text-1);">
                                    <%= rDept != null ? rDept : "—" %>
                                </div>
                            </div>
                            <div style="background:var(--bg-surface);
                                        border:1px solid var(--border);
                                        border-radius:var(--r-sm);
                                        padding:12px 14px;
                                        grid-column:1/-1;">
                                <div style="font-size:11px; color:var(--text-3);
                                            text-transform:uppercase;
                                            letter-spacing:0.5px; margin-bottom:6px;">
                                    Description
                                </div>
                                <div style="color:var(--text-2);
                                            font-size:13.5px; line-height:1.6;">
                                    <%= rDesc %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- IMAGE COMPARISON -->
                <div class="lcps-card" style="margin-bottom:20px;">
                    <div class="card-header">
                        <h3><div class="card-icon">🖼️</div> Work Evidence</h3>
                        <span style="font-size:12px; color:var(--text-3);">
                            Click images to enlarge
                        </span>
                    </div>
                    <div class="card-body">
                        <div class="img-compare-grid">

                            <!-- BEFORE -->
                            <div>
                                <div class="img-col-title">
                                    📷 Before
                                    <span style="background:rgba(245,158,11,0.1);
                                                 color:var(--gold);
                                                 border:1px solid rgba(245,158,11,0.3);
                                                 padding:2px 8px;
                                                 border-radius:var(--r-full);
                                                 font-size:11px;">
                                        <%= beforePaths.size() %> image<%= beforePaths.size()!=1?"s":"" %>
                                    </span>
                                </div>
                                <% if (beforePaths.isEmpty()) { %>
                                <div class="lcps-alert info" style="font-size:12.5px;">
                                    <span class="alert-icon">ℹ️</span>
                                    No before images
                                </div>
                                <% } else { %>
                                <div class="images-grid">
                                    <% for (String p : beforePaths) { %>
                                    <img src="<%= request.getContextPath()+"/"+p %>"
                                         alt="Before"
                                         onclick="openLightbox(this.src)">
                                    <% } %>
                                </div>
                                <% } %>
                            </div>

                            <!-- AFTER -->
                            <div>
                                <div class="img-col-title">
                                    ✅ After
                                    <span style="background:rgba(16,185,129,0.1);
                                                 color:var(--green);
                                                 border:1px solid rgba(16,185,129,0.3);
                                                 padding:2px 8px;
                                                 border-radius:var(--r-full);
                                                 font-size:11px;">
                                        <%= afterPaths.size() %> image<%= afterPaths.size()!=1?"s":"" %>
                                    </span>
                                </div>
                                <% if (afterPaths.isEmpty()) { %>
                                <div class="lcps-alert info" style="font-size:12.5px;">
                                    <span class="alert-icon">⚠️</span>
                                    Worker has not uploaded after images yet
                                </div>
                                <% } else { %>
                                <div class="images-grid">
                                    <% for (String p : afterPaths) { %>
                                    <img src="<%= request.getContextPath()+"/"+p %>"
                                         alt="After"
                                         onclick="openLightbox(this.src)">
                                    <% } %>
                                </div>
                                <% } %>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- DECISION FORM -->
                <div class="lcps-card">
                    <div class="card-header">
                        <h3><div class="card-icon">⚖️</div> Your Decision</h3>
                    </div>
                    <div class="card-body">

                        <% if (alreadyResolved) { %>
                        <div class="reviewed-banner resolved">
                            <div style="font-size:32px;">✅</div>
                            <div>
                                <div style="font-weight:700;
                                            color:var(--green);
                                            font-size:15px;">
                                    Already Approved
                                </div>
                                <div style="font-size:13px; color:var(--text-2);">
                                    This report has been resolved.
                                    No further action needed.
                                </div>
                            </div>
                        </div>
                        <a href="dashboard.jsp" class="lcps-btn outline"
                           style="width:100%; text-align:center; margin-top:10px;">
                            ← Back to Dashboard
                        </a>

                        <% } else if (alreadyRework) { %>
                        <div class="reviewed-banner rework">
                            <div style="font-size:32px;">🔄</div>
                            <div>
                                <div style="font-weight:700;
                                            color:#a855f7;
                                            font-size:15px;">
                                    Rework Requested
                                </div>
                                <div style="font-size:13px; color:var(--text-2);">
                                    Worker has been asked to redo the work.
                                    Awaiting resubmission.
                                </div>
                            </div>
                        </div>
                        <a href="dashboard.jsp" class="lcps-btn outline"
                           style="width:100%; text-align:center; margin-top:10px;">
                            ← Back to Dashboard
                        </a>

                        <% } else { %>

                        <!-- Decision cards -->
                        <div class="decision-cards">
                            <div class="decision-card approve"
                                 id="card-approve"
                                 onclick="selectDecision('approve')">
                                <div class="decision-icon">✅</div>
                                <div class="decision-title">Approve</div>
                                <div class="decision-desc">
                                    Work is satisfactory.<br>
                                    Mark report as Resolved.
                                </div>
                            </div>
                            <div class="decision-card reject"
                                 id="card-reject"
                                 onclick="selectDecision('reject')">
                                <div class="decision-icon">🔄</div>
                                <div class="decision-title">Send Back</div>
                                <div class="decision-desc">
                                    Work is incomplete.<br>
                                    Request rework from worker.
                                </div>
                            </div>
                        </div>

                        <form action="<%=request.getContextPath()%>/authority-review"
                              method="post"
                              onsubmit="return confirmDecision();">

                            <input type="hidden"
                                   name="reportId"
                                   value="<%= reportId %>">
                            <input type="hidden"
                                   name="action"
                                   id="actionInput"
                                   value="">

                            <div class="form-group">
                                <label class="form-label">
                                    Comment
                                    <span style="color:var(--text-3);
                                                 font-size:12px;
                                                 font-weight:400;"
                                          id="commentLabel">
                                        (optional for approval)
                                    </span>
                                </label>
                                <textarea class="lcps-textarea"
                                          name="comment"
                                          id="commentBox"
                                          rows="3"
                                          placeholder="Add your review remarks...">
                                </textarea>
                            </div>

                            <div style="display:flex; gap:10px; margin-top:6px;">
                                <a href="dashboard.jsp"
                                   class="lcps-btn ghost lg"
                                   style="flex:1; text-align:center;">
                                    Cancel
                                </a>
                                <button type="submit"
                                        class="lcps-btn lg"
                                        id="decisionBtn"
                                        style="flex:2;"
                                        disabled>
                                    Select a decision above
                                </button>
                            </div>
                        </form>

                        <% } %>
                    </div>
                </div>

            </div>

            <!-- RIGHT: TIMELINE -->
            <div class="lcps-card">
                <div class="card-header">
                    <h3><div class="card-icon">🕒</div> Timeline</h3>
                </div>
                <div class="card-body">
                    <%
                        boolean hasTimeline = false;
                        for (StatusTimeline t : timeline) {
                            hasTimeline = true;
                            String tSt   = t.getStatus();
                            String tUser = t.getUpdatedBy();
                            String tTime = sdf.format(t.getUpdatedAt());
                            String tLow  = tSt != null ? tSt.toLowerCase() : "";

                            String dotCls =
                                tLow.equals("resolved")   ? "done"     :
                                tLow.contains("rework")
                             || tLow.equals("rejected")   ? "rejected" :
                                tLow.equals("pending")    ? ""         :
                                "active";

                            String dotIcon =
                                tLow.equals("resolved")         ? "✓" :
                                tLow.contains("rework")
                             || tLow.equals("rejected")         ? "✕" : "•";
                    %>
                    <div class="timeline-item">
                        <div class="tl-dot <%= dotCls %>"><%= dotIcon %></div>
                        <div>
                            <div class="tl-status"><%= tSt %></div>
                            <div class="tl-meta">
                                By <%= tUser %><br><%= tTime %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <% if (!hasTimeline) { %>
                    <div style="text-align:center; color:var(--text-3);
                                font-size:13px; padding:16px 0;">
                        No history yet
                    </div>
                    <% } %>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- ===== FOOTER ===== -->
<div class="lcps-footer">
    <div class="f-left">© 2026 <span>LCPS</span> — Local Community Problem Solver</div>
    <div class="f-right">
        <a href="#">Help</a>
        <a href="#">Privacy</a>
        <span>v2.0</span>
    </div>
</div>

<!-- LIGHTBOX -->
<div id="lightbox" onclick="closeLightbox()">
    <button id="lightbox-close" onclick="closeLightbox()">✕</button>
    <img id="lightbox-img" src="" alt="Preview">
</div>

<script>
let currentDecision = "";

function selectDecision(type) {
    currentDecision = type;
    const btn   = document.getElementById("decisionBtn");
    const input = document.getElementById("actionInput");
    const hint  = document.getElementById("commentLabel");
    const cbox  = document.getElementById("commentBox");

    document.getElementById("card-approve").className =
        "decision-card approve" + (type === "approve" ? " selected-approve" : "");
    document.getElementById("card-reject").className  =
        "decision-card reject"  + (type === "reject"  ? " selected-reject"  : "");

    input.value = type;

    if (type === "approve") {
        btn.textContent  = "✅ Approve & Mark Resolved";
        btn.className    = "lcps-btn lg";
        btn.disabled     = false;
        hint.textContent = "(optional)";
        cbox.placeholder = "Any remarks for approval...";
        cbox.required    = false;
    } else {
        btn.textContent  = "🔄 Send Back for Rework";
        btn.className    = "lcps-btn lg";
        btn.style.background = "var(--red)";
        btn.disabled     = false;
        hint.textContent = "* required for rework";
        hint.style.color = "var(--gold)";
        cbox.placeholder = "Explain what needs to be redone...";
        cbox.required    = true;
    }
}

function confirmDecision() {
    if (!currentDecision) {
        alert("Please select Approve or Send Back.");
        return false;
    }
    if (currentDecision === "reject" &&
        !document.getElementById("commentBox").value.trim()) {
        alert("Please provide a reason for sending back.");
        return false;
    }
    const btn = document.getElementById("decisionBtn");
    btn.textContent = "⏳ Submitting...";
    btn.disabled    = true;
    return true;
}

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
