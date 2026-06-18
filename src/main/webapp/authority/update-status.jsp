<%@ page import="model.User, model.Report, model.StatusTimeline, java.util.List, operations.ReportOperations, java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User auth = (User) session.getAttribute("user");
    if (auth == null || auth.getRoleId() != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // ===== HANDLE POST (process update) =====
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int    reportId = 0;
        String status   = request.getParameter("status");
        String comment  = request.getParameter("comment");

        try {
            reportId = Integer.parseInt(request.getParameter("reportId"));
        } catch (Exception e) {
            response.sendRedirect("dashboard.jsp?msg=Invalid+report&type=error");
            return;
        }

        if (status == null || status.trim().isEmpty()) {
            response.sendRedirect("update-status.jsp?reportId=" + reportId
                + "&msg=Please+select+a+status&type=error");
            return;
        }

        try {
            ReportOperations ops = new ReportOperations();
            ops.changeReportStatus(reportId, status, auth.getUserId(),
                comment != null ? comment.trim() : "");
            response.sendRedirect("dashboard.jsp?msg=Status+updated+successfully&type=success");
        } catch (Exception e) {
            response.sendRedirect("dashboard.jsp?msg=Update+failed&type=error");
        }
        return;
    }

    // ===== HANDLE GET (show form) =====
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
    String rStatus = report.getStatus();
    String rDept   = report.getDeptName();
    String rSev    = report.getSeverity();

    String stLow = rStatus != null ? rStatus.toLowerCase() : "";
    String badgeClass =
        stLow.equals("pending")        ? "badge-pending"  :
        stLow.equals("assigned")       ? "badge-assigned" :
        stLow.contains("progress")     ? "badge-progress" :
        stLow.equals("resolved")       ? "badge-resolved" :
        stLow.equals("rejected")       ? "badge-rejected" :
        "badge-rework";

    String sevLow = rSev != null ? rSev.toLowerCase() : "low";

    // Flash from redirect
    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
<title>Update Status | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== STATUS OPTION CARDS ===== */
.status-options {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 4px;
}

.status-option { position: relative; }

.status-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0; height: 0;
}

.status-option label {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 13px 15px;
    background: var(--bg-input);
    border: 1.5px solid var(--border-md);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: all 0.18s;
}

.status-option label:hover {
    border-color: var(--border-blue);
    background: var(--accent-soft);
}

.status-option input:checked + label {
    box-shadow: 0 0 0 3px var(--accent-glow);
}

/* Per-status selected colors */
.status-option.s-pending    input:checked + label
    { background:rgba(245,158,11,0.1);  border-color:var(--gold);   }
.status-option.s-progress   input:checked + label
    { background:rgba(79,142,247,0.1);  border-color:var(--accent);  }
.status-option.s-resolved   input:checked + label
    { background:rgba(16,185,129,0.1);  border-color:var(--green);   }
.status-option.s-rejected   input:checked + label
    { background:rgba(239,68,68,0.1);   border-color:var(--red);     }
.status-option.s-rework     input:checked + label
    { background:rgba(168,85,247,0.1);  border-color:#a855f7;        }

.status-icon { font-size: 22px; flex-shrink: 0; }

.status-name {
    font-size: 13.5px;
    font-weight: 600;
    color: var(--text-1);
}

.status-desc {
    font-size: 11.5px;
    color: var(--text-3);
    margin-top: 1px;
}

.status-check {
    margin-left: auto;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    border: 2px solid var(--border-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 10px;
    color: transparent;
    flex-shrink: 0;
    transition: all 0.18s;
}

.status-option input:checked + label .status-check {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
}

/* ===== TIMELINE ===== */
.timeline-wrap { padding: 4px 0; }

.timeline-item {
    display: flex;
    gap: 14px;
    padding-bottom: 20px;
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

.tl-dot.done     { background: var(--green);  border-color: var(--green);  color: #fff; }
.tl-dot.active   { background: var(--accent); border-color: var(--accent); color: #fff; box-shadow: var(--glow-blue); }
.tl-dot.rejected { background: var(--red);    border-color: var(--red);    color: #fff; }

.tl-status {
    font-size: 13.5px;
    font-weight: 600;
    color: var(--text-1);
    margin-bottom: 2px;
}

.tl-meta { font-size: 12px; color: var(--text-3); }

/* Report context */
.report-ctx {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 14px 16px;
}

.report-ctx-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--text-1);
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.ctx-meta {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
    font-size: 12.5px;
    color: var(--text-3);
}

.ctx-meta strong { color: var(--text-2); }

/* ===== CONTENT SPLIT + MOBILE RESPONSIVE ===== */
.lcps-split { display: grid; grid-template-columns: 1fr 360px; gap: 20px; align-items: start; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 992px) {
    .lcps-split { grid-template-columns: 1fr; }
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
    .status-options { grid-template-columns: 1fr; }
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
        <a href="review-work.jsp">Review Work</a>
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
            <a href="review-work.jsp" class="sidebar-link">
                <span class="s-icon">🔍</span> Review Work
            </a>
            <a href="update-status.jsp" class="sidebar-link active">
                <span class="s-icon">📝</span> Update Status
            </a>
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
                    <span>Update Status</span>
                </div>
                <h1>Update Report Status</h1>
                <p>Change the current status of this report.</p>
            </div>
            <a href="dashboard.jsp" class="lcps-btn ghost">
                ← Back
            </a>
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

            <!-- LEFT: UPDATE FORM -->
            <div>
                <!-- Report Context -->
                <div class="lcps-card" style="margin-bottom:20px;">
                    <div class="card-header">
                        <h3>
                            <div class="card-icon">📋</div>
                            Report
                        </h3>
                        <a href="../citizen/view-report.jsp?id=<%= reportId %>"
                           class="lcps-btn xs ghost">
                            👁️ View
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="report-ctx">
                            <div class="report-ctx-title">
                                #<%= reportId %> — <%= rTitle %>
                                <span class="badge <%= badgeClass %>">
                                    <span class="dot"></span>
                                    <%= rStatus %>
                                </span>
                            </div>
                            <div class="ctx-meta">
                                <span>Department: <strong><%= rDept %></strong></span>
                                <span>
                                    Severity:
                                    <strong>
                                        <span class="severity <%= sevLow %>">
                                            <span class="sev-dot"></span>
                                            <%= rSev %>
                                        </span>
                                    </strong>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Status Form -->
                <div class="lcps-card">
                    <div class="card-header">
                        <h3>
                            <div class="card-icon">📝</div>
                            Set New Status
                        </h3>
                    </div>
                    <div class="card-body">
                        <form method="post"
                              action="update-status.jsp"
                              onsubmit="return confirmUpdate();">

                            <input type="hidden"
                                   name="reportId"
                                   value="<%= reportId %>">

                            <div class="form-group">
                                <label class="form-label">
                                    Select Status
                                    <span class="req">*</span>
                                </label>
                                <div class="status-options">

                                    <div class="status-option s-pending">
                                        <input type="radio"
                                               name="status"
                                               id="s-pending"
                                               value="Pending"
                                               <%= "pending".equals(stLow) ? "checked" : "" %>>
                                        <label for="s-pending">
                                            <span class="status-icon">⏳</span>
                                            <div>
                                                <div class="status-name">Pending</div>
                                                <div class="status-desc">Awaiting assignment</div>
                                            </div>
                                            <div class="status-check">✓</div>
                                        </label>
                                    </div>

                                    <div class="status-option s-progress">
                                        <input type="radio"
                                               name="status"
                                               id="s-progress"
                                               value="In Progress"
                                               <%= stLow.contains("progress") ? "checked" : "" %>>
                                        <label for="s-progress">
                                            <span class="status-icon">🔧</span>
                                            <div>
                                                <div class="status-name">In Progress</div>
                                                <div class="status-desc">Work has started</div>
                                            </div>
                                            <div class="status-check">✓</div>
                                        </label>
                                    </div>

                                    <div class="status-option s-resolved">
                                        <input type="radio"
                                               name="status"
                                               id="s-resolved"
                                               value="Resolved"
                                               <%= "resolved".equals(stLow) ? "checked" : "" %>>
                                        <label for="s-resolved">
                                            <span class="status-icon">✅</span>
                                            <div>
                                                <div class="status-name">Resolved</div>
                                                <div class="status-desc">Issue fixed</div>
                                            </div>
                                            <div class="status-check">✓</div>
                                        </label>
                                    </div>

                                    <div class="status-option s-rejected">
                                        <input type="radio"
                                               name="status"
                                               id="s-rejected"
                                               value="Rejected"
                                               <%= "rejected".equals(stLow) ? "checked" : "" %>>
                                        <label for="s-rejected">
                                            <span class="status-icon">❌</span>
                                            <div>
                                                <div class="status-name">Rejected</div>
                                                <div class="status-desc">Invalid report</div>
                                            </div>
                                            <div class="status-check">✓</div>
                                        </label>
                                    </div>

                                    <div class="status-option s-rework"
                                         style="grid-column: 1 / -1;">
                                        <input type="radio"
                                               name="status"
                                               id="s-rework"
                                               value="Rework Required"
                                               <%= stLow.contains("rework") ? "checked" : "" %>>
                                        <label for="s-rework">
                                            <span class="status-icon">🔄</span>
                                            <div>
                                                <div class="status-name">Rework Required</div>
                                                <div class="status-desc">
                                                    Work incomplete — send back to worker
                                                </div>
                                            </div>
                                            <div class="status-check">✓</div>
                                        </label>
                                    </div>

                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">
                                    Comment
                                    <span style="color:var(--text-3);
                                                 font-size:12px;
                                                 font-weight:400;">
                                        (optional)
                                    </span>
                                </label>
                                <textarea class="lcps-textarea"
                                          name="comment"
                                          rows="3"
                                          id="commentBox"
                                          placeholder="Add a note about this status change...">
                                </textarea>
                                <div class="form-hint" id="commentHint"></div>
                            </div>

                            <div style="display:flex; gap:10px;">
                                <a href="dashboard.jsp"
                                   class="lcps-btn ghost lg"
                                   style="flex:1; text-align:center;">
                                    Cancel
                                </a>
                                <button type="submit"
                                        class="lcps-btn lg"
                                        id="updateBtn"
                                        style="flex:2;">
                                    📝 Update Status
                                </button>
                            </div>

                        </form>
                    </div>
                </div>
            </div>

            <!-- RIGHT: TIMELINE -->
            <div class="lcps-card">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">🕒</div>
                        History
                    </h3>
                </div>
                <div class="card-body">
                    <div class="timeline-wrap">
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
                                By <%= tUser %><br>
                                <%= tTime %>
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
// Require comment when rejecting or rework
document.querySelectorAll('input[name="status"]').forEach(radio => {
    radio.addEventListener("change", () => {
        const val   = radio.value.toLowerCase();
        const hint  = document.getElementById("commentHint");
        const cbox  = document.getElementById("commentBox");
        if (val === "rejected" || val.includes("rework")) {
            hint.textContent = "⚠️ Please provide a reason for this action.";
            hint.style.color = "var(--gold)";
            cbox.placeholder = "Reason for rejection / rework...";
            cbox.required    = true;
        } else {
            hint.textContent = "";
            cbox.placeholder = "Add a note about this status change...";
            cbox.required    = false;
        }
    });
});

function confirmUpdate() {
    const selected = document.querySelector('input[name="status"]:checked');
    if (!selected) {
        alert("Please select a status.");
        return false;
    }
    const btn = document.getElementById("updateBtn");
    btn.textContent = "⏳ Updating...";
    btn.disabled    = true;
    return true;
}
</script>

</body>
</html>
