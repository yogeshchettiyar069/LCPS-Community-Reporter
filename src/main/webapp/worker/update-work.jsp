<%@ page import="model.User, model.Report, model.StatusTimeline, java.util.List, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User u = (User) session.getAttribute("user");
    if (u == null || u.getRoleId() != 4) {
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
    List<StatusTimeline> timeline = ops.getReportTimeline(reportId);

    if (report == null) {
        response.sendRedirect("dashboard.jsp?msg=Report+not+found&type=error");
        return;
    }

    String rTitle  = report.getTitle();
    String rDesc   = report.getDescription();
    String rStatus = report.getStatus();
    String rSev    = report.getSeverity();
    String rDept   = report.getDeptName();

    String stLow = rStatus != null ? rStatus.toLowerCase() : "";
    boolean isRework   = stLow.contains("rework");
    boolean isResolved = stLow.equals("resolved");
    boolean isPending  = stLow.equals("pending") || stLow.equals("assigned");
    boolean isProgress = stLow.contains("progress");

    String reworkComment = null;
    if (isRework) {
        reworkComment = ops.getLatestRejectionComment(reportId);
    }

    String badgeClass =
        stLow.equals("pending")        ? "badge-pending"  :
        stLow.equals("assigned")       ? "badge-assigned" :
        stLow.contains("progress")     ? "badge-progress" :
        stLow.equals("resolved")       ? "badge-resolved" :
        stLow.contains("rework")       ? "badge-rework"   :
        "badge-rejected";

    String sevLow = rSev != null ? rSev.toLowerCase() : "low";

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");

    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");
%>
<!DOCTYPE html>
<html>
<head>
<title>Update Work | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== WORKFLOW STEPS ===== */
.workflow-steps {
    display: flex;
    align-items: center;
    gap: 0;
    margin-bottom: 24px;
    overflow-x: auto;
    padding-bottom: 4px;
}

.wf-step {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 18px;
    border-radius: var(--r-sm);
    font-size: 13px;
    font-weight: 500;
    color: var(--text-3);
    background: var(--bg-surface);
    border: 1px solid var(--border);
    white-space: nowrap;
    flex-shrink: 0;
}

.wf-step.done {
    color: var(--green);
    background: rgba(16,185,129,0.08);
    border-color: rgba(16,185,129,0.3);
}

.wf-step.active {
    color: var(--accent);
    background: rgba(79,142,247,0.1);
    border-color: var(--border-blue);
    box-shadow: var(--glow-blue);
    font-weight: 700;
}

.wf-step.rework {
    color: #c084fc;
    background: rgba(168,85,247,0.08);
    border-color: rgba(168,85,247,0.3);
}

.wf-arrow {
    font-size: 18px;
    color: var(--border-md);
    padding: 0 4px;
    flex-shrink: 0;
}

.wf-num {
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: var(--border-md);
    color: var(--text-3);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 700;
    flex-shrink: 0;
}

.wf-step.done   .wf-num { background: var(--green);  color: #fff; }
.wf-step.active .wf-num { background: var(--accent);  color: #fff; }
.wf-step.rework .wf-num { background: #a855f7; color: #fff; }

/* ===== UPLOAD ZONE ===== */
.upload-zone {
    border: 2px dashed var(--border-md);
    border-radius: var(--r-md);
    padding: 32px 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
    background: var(--bg-input);
    position: relative;
}

.upload-zone:hover,
.upload-zone.drag-over {
    border-color: var(--border-blue);
    background: var(--accent-soft);
}

.upload-zone input[type="file"] {
    position: absolute;
    inset: 0;
    opacity: 0;
    cursor: pointer;
    width: 100%;
    height: 100%;
}

.upload-icon { font-size: 36px; margin-bottom: 10px; }

.upload-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-1);
    margin-bottom: 5px;
}

.upload-hint {
    font-size: 12.5px;
    color: var(--text-3);
}

/* Preview grid */
#previewGrid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
    gap: 10px;
    margin-top: 14px;
}

#previewGrid img {
    width: 100%;
    height: 100px;
    object-fit: cover;
    border-radius: var(--r-sm);
    border: 1px solid var(--border-md);
}

/* ===== ACTION CARD ===== */
.action-section {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 18px 20px;
    margin-bottom: 14px;
}

.action-section-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 4px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.action-section-desc {
    font-size: 12.5px;
    color: var(--text-3);
    margin-bottom: 14px;
    line-height: 1.5;
}

/* ===== REWORK BANNER ===== */
.rework-banner {
    background: rgba(168,85,247,0.08);
    border: 1px solid rgba(168,85,247,0.3);
    border-radius: var(--r-md);
    padding: 16px 18px;
    margin-bottom: 20px;
    display: flex;
    gap: 14px;
    align-items: flex-start;
}

.rework-banner-icon { font-size: 28px; flex-shrink: 0; }

.rework-banner-title {
    font-size: 14px;
    font-weight: 700;
    color: #c084fc;
    margin-bottom: 5px;
}

.rework-banner-comment {
    font-size: 13px;
    color: var(--text-2);
    line-height: 1.6;
    background: rgba(168,85,247,0.06);
    border-left: 3px solid #a855f7;
    padding: 8px 12px;
    border-radius: 0 var(--r-sm) var(--r-sm) 0;
    margin-top: 6px;
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
    left: 10px; top: 22px;
    width: 2px; bottom: 0;
    background: var(--border-md);
}

.tl-dot {
    width: 22px; height: 22px;
    border-radius: 50%;
    border: 2px solid var(--border-md);
    background: var(--bg-input);
    flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: 10px; z-index: 1;
}

.tl-dot.done     { background:var(--green);  border-color:var(--green);  color:#fff; }
.tl-dot.active   { background:var(--accent); border-color:var(--accent); color:#fff; box-shadow:var(--glow-blue); }
.tl-dot.rejected { background:var(--red);    border-color:var(--red);    color:#fff; }

.tl-status { font-size:13px; font-weight:600; color:var(--text-1); margin-bottom:2px; }
.tl-meta   { font-size:11.5px; color:var(--text-3); }

/* Resolved overlay */
.resolved-overlay {
    text-align: center;
    padding: 32px 20px;
    background: rgba(16,185,129,0.06);
    border: 1px solid rgba(16,185,129,0.25);
    border-radius: var(--r-md);
}

/* =========================================
   RESPONSIVE DESIGN
   ========================================= */
.wu-split { display: grid; grid-template-columns: 1fr 300px; gap: 20px; align-items: start; }

@media (max-width: 992px) {
    .lcps-layout { flex-direction: column; }
    .lcps-sidebar { width: 100%; max-width: 100%; position: static; }
    .lcps-main { width: 100%; }
    .wu-split { grid-template-columns: 1fr; }
    .page-header { flex-direction: column; align-items: flex-start; gap: 12px; }
}

@media (max-width: 768px) {
    .lcps-header { flex-direction: column; align-items: stretch; gap: 14px; padding: 14px; }
    .header-nav { display: flex; justify-content: center; flex-wrap: wrap; gap: 8px; }
    .header-right { justify-content: center; display: flex; }
    .user-chip { width: 100%; justify-content: center; }
    .lcps-sidebar { width: 100%; padding: 15px; }
    .lcps-main { padding: 15px; }
    .page-header .lcps-btn { width: 100%; text-align: center; justify-content: center; }
    .workflow-steps { gap: 4px; }
    .lcps-footer { flex-direction: column; gap: 10px; text-align: center; }
    .f-right { justify-content: center; flex-wrap: wrap; }
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
        <a href="dashboard.jsp">Dashboard</a>
        <a href="update-work.jsp" class="active">Update Work</a>
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
            <a href="dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="update-work.jsp" class="sidebar-link active">
                <span class="s-icon">🔧</span> Update Work
            </a>
        </div>

        <!-- Report Quick Info -->
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
                <div style="color:var(--text-3);
                            margin-top:4px; margin-bottom:5px;">
                    Severity
                </div>
                <span class="severity <%= sevLow %>" style="display:inline-flex;">
                    <span class="sev-dot"></span><%= rSev %>
                </span>
                <div style="color:var(--text-3);
                            margin-top:12px; margin-bottom:5px;">
                    Department
                </div>
                <div style="color:var(--text-2); font-size:12.5px;
                            font-weight:600;">
                    <%= rDept != null ? rDept : "—" %>
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
                    <a href="dashboard.jsp">Dashboard</a>
                    <span class="sep">›</span>
                    <span>Update Work</span>
                </div>
                <h1 style="display:flex; align-items:center;
                            gap:12px; flex-wrap:wrap;">
                    Report #<%= reportId %>
                    <span class="badge <%= badgeClass %>">
                        <span class="dot"></span><%= rStatus %>
                    </span>
                </h1>
                <p style="color:var(--text-2);">
                    <%= rTitle %>
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

        <div class="wu-split">

            <!-- LEFT: ACTIONS -->
            <div>

                <!-- WORKFLOW STEPS -->
                <div class="workflow-steps">
                    <div class="wf-step done">
                        <div class="wf-num">✓</div>
                        Assigned
                    </div>
                    <div class="wf-arrow">›</div>
                    <div class="wf-step <%= isProgress || isRework || isResolved ? "done" : "active" %>">
                        <div class="wf-num">
                            <%= isProgress || isRework || isResolved ? "✓" : "2" %>
                        </div>
                        In Progress
                    </div>
                    <div class="wf-arrow">›</div>
                    <div class="wf-step <%= isRework ? "rework" : isResolved ? "done" : isPending || isProgress ? "active" : "" %>">
                        <div class="wf-num">
                            <%= isResolved ? "✓" : isRework ? "↺" : "3" %>
                        </div>
                        <%= isRework ? "Rework" : "Submit Work" %>
                    </div>
                    <div class="wf-arrow">›</div>
                    <div class="wf-step <%= isResolved ? "done" : "" %>">
                        <div class="wf-num">
                            <%= isResolved ? "✓" : "4" %>
                        </div>
                        Resolved
                    </div>
                </div>

                <!-- REWORK BANNER -->
                <% if (isRework) { %>
                <div class="rework-banner">
                    <div class="rework-banner-icon">🔄</div>
                    <div>
                        <div class="rework-banner-title">
                            Authority Requested Rework
                        </div>
                        <div style="font-size:12.5px;
                                    color:var(--text-3);
                                    margin-bottom:4px;">
                            Please review the comment below and
                            re-upload your completed work images.
                        </div>
                        <div class="rework-banner-comment">
                            <%= reworkComment != null && !reworkComment.isEmpty()
                                ? reworkComment
                                : "No specific comment. Please check with the authority." %>
                        </div>
                    </div>
                </div>
                <% } %>

                <% if (isResolved) { %>
                <!-- RESOLVED STATE -->
                <div class="lcps-card">
                    <div class="card-body">
                        <div class="resolved-overlay">
                            <div style="font-size:48px; margin-bottom:12px;">✅</div>
                            <div style="font-size:18px; font-weight:700;
                                        color:var(--green); margin-bottom:8px;">
                                Work Complete!
                            </div>
                            <div style="font-size:13.5px; color:var(--text-2);
                                        margin-bottom:20px;">
                                This report has been resolved and approved
                                by the authority. No further action needed.
                            </div>
                            <a href="dashboard.jsp"
                               class="lcps-btn outline">
                                ← Back to Dashboard
                            </a>
                        </div>
                    </div>
                </div>

                <% } else { %>

                <!-- STEP 1: MARK IN PROGRESS -->
                <% if (isPending) { %>
                <div class="lcps-card" style="margin-bottom:14px;">
                    <div class="card-header">
                        <h3>
                            <div class="card-icon">🔧</div>
                            Step 1 — Start Work
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="action-section">
                            <div class="action-section-title">
                                🔧 Mark as In Progress
                            </div>
                            <div class="action-section-desc">
                                Click below to confirm you have started
                                working on this report. This notifies
                                the authority and citizen.
                            </div>
                            <form action="<%=request.getContextPath()%>/worker-update"
                                  method="post"
                                  onsubmit="return confirmProgress();">
                                <input type="hidden"
                                       name="reportId"
                                       value="<%= reportId %>">
                                <input type="hidden"
                                       name="action"
                                       value="progress">
                                <button type="submit"
                                        id="progressBtn"
                                        class="lcps-btn lg">
                                    🔧 Mark In Progress
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                <% } %>

                <!-- STEP 2: SUBMIT / RE-UPLOAD WORK -->
                <div class="lcps-card">
                    <div class="card-header">
                        <h3>
                            <div class="card-icon">
                                <%= isRework ? "🔄" : "📸" %>
                            </div>
                            <%= isRework
                                ? "Re-Upload Work Images"
                                : "Step 2 — Submit Completed Work" %>
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="action-section">
                            <div class="action-section-title">
                                <%= isRework
                                    ? "🔄 Re-Upload After Images"
                                    : "📸 Upload After Work Images" %>
                            </div>
                            <div class="action-section-desc">
                                <%= isRework
                                    ? "Upload new images showing the corrected/completed work."
                                    : "Upload clear photos showing the completed work. These will be reviewed by the authority." %>
                            </div>

                            <form action="<%=request.getContextPath()%>/worker-update"
                                  method="post"
                                  enctype="multipart/form-data"
                                  onsubmit="return confirmSubmit();">

                                <input type="hidden"
                                       name="reportId"
                                       value="<%= reportId %>">
                                <input type="hidden"
                                       name="action"
                                       value="complete">

                                <div class="form-group">
                                    <label class="form-label">
                                        After Work Images
                                        <span class="req">*</span>
                                    </label>
                                    <div class="upload-zone"
                                         id="uploadZone"
                                         ondragover="handleDrag(event, true)"
                                         ondragleave="handleDrag(event, false)"
                                         ondrop="handleDrop(event)">
                                        <input type="file"
                                               name="images"
                                               id="imageInput"
                                               multiple
                                               accept="image/*"
                                               required
                                               onchange="previewImages(this)">
                                        <div class="upload-icon">📷</div>
                                        <div class="upload-title"
                                             id="uploadTitle">
                                            Click or drag images here
                                        </div>
                                        <div class="upload-hint">
                                            JPG, PNG, WEBP supported
                                        </div>
                                    </div>
                                    <div id="previewGrid"></div>
                                </div>

                                <div style="display:flex; gap:10px; margin-top:6px;">
                                    <a href="dashboard.jsp"
                                       class="lcps-btn ghost lg"
                                       style="flex:1; text-align:center;">
                                        Cancel
                                    </a>
                                    <button type="submit"
                                            id="submitBtn"
                                            class="lcps-btn lg"
                                            style="flex:2; <%= isRework
                                                ? "background:#a855f7; border-color:#a855f7;"
                                                : "" %>">
                                        <%= isRework
                                            ? "🔄 Re-Submit Work"
                                            : "✅ Submit Completed Work" %>
                                    </button>
                                </div>

                            </form>
                        </div>
                    </div>
                </div>

                <% } %>
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
                                tLow.equals("resolved")     ? "done"     :
                                tLow.contains("rework")
                             || tLow.equals("rejected")     ? "rejected" :
                                tLow.equals("pending")      ? ""         :
                                "active";

                            String dotIcon =
                                tLow.equals("resolved") ? "✓" :
                                tLow.contains("rework")
                             || tLow.equals("rejected") ? "✕" : "•";
                    %>
                    <div class="timeline-item">
                        <div class="tl-dot <%= dotCls %>">
                            <%= dotIcon %>
                        </div>
                        <div>
                            <div class="tl-status"><%= tSt %></div>
                            <div class="tl-meta">
                                By <%= tUser %><br><%= tTime %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <% if (!hasTimeline) { %>
                    <div style="text-align:center;
                                color:var(--text-3);
                                font-size:13px;
                                padding:16px 0;">
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
function previewImages(input) {
    const grid  = document.getElementById("previewGrid");
    const title = document.getElementById("uploadTitle");
    grid.innerHTML = "";

    const files = Array.from(input.files);
    if (files.length === 0) return;

    title.textContent = files.length + " image" +
                        (files.length > 1 ? "s" : "") + " selected";

    files.forEach(file => {
        const reader = new FileReader();
        reader.onload = e => {
            const img = document.createElement("img");
            img.src = e.target.result;
            grid.appendChild(img);
        };
        reader.readAsDataURL(file);
    });
}

function handleDrag(e, over) {
    e.preventDefault();
    document.getElementById("uploadZone").classList
        .toggle("drag-over", over);
}

function handleDrop(e) {
    e.preventDefault();
    document.getElementById("uploadZone").classList.remove("drag-over");
    const input = document.getElementById("imageInput");
    input.files = e.dataTransfer.files;
    previewImages(input);
}

function confirmProgress() {
    const btn = document.getElementById("progressBtn");
    btn.textContent = "⏳ Updating...";
    btn.disabled    = true;
    return true;
}

function confirmSubmit() {
    const input = document.getElementById("imageInput");
    if (!input.files || input.files.length === 0) {
        alert("Please select at least one after-work image.");
        return false;
    }
    const btn = document.getElementById("submitBtn");
    btn.textContent = "⏳ Uploading...";
    btn.disabled    = true;
    return true;
}
</script>

</body>
</html>
