<%@ page import="model.User, model.Report, model.WorkerSummary, java.util.List, operations.ReportOperations" %>
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

    // Load report details for context card
    Report report = ops.getReportDetails(reportId);
    String rTitle  = "Report #" + reportId;
    String rStatus = "—";
    String rDept   = "—";
    if (report != null) {
        rTitle  = report.getTitle();
        rStatus = report.getStatus();
        rDept   = report.getDeptName();
    }

    // Load workers in this dept
    List<WorkerSummary> workers = ops.getWorkersByDepartment(auth.getDeptId());
    java.util.List<int[]>    wIds   = new java.util.ArrayList<>();
    java.util.List<String>   wNames = new java.util.ArrayList<>();

    for (WorkerSummary w : workers) {
        wIds.add(new int[]{ w.getUserId() });
        wNames.add(w.getName());
    }

    // Status badge
    String stLow = rStatus != null ? rStatus.toLowerCase() : "";
    String badgeClass =
        stLow.equals("pending")            ? "badge-pending"  :
        stLow.equals("assigned")           ? "badge-assigned" :
        stLow.contains("progress")         ? "badge-progress" :
        stLow.equals("resolved")           ? "badge-resolved" :
        stLow.equals("rejected")           ? "badge-rejected" :
        "badge-rework";
%>
<!DOCTYPE html>
<html>
<head>
<title>Assign Worker | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== WORKER OPTION CARDS ===== */
.worker-options {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin: 4px 0;
}

.worker-option { position: relative; }

.worker-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0; height: 0;
}

.worker-option label {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 14px 16px;
    background: var(--bg-input);
    border: 1.5px solid var(--border-md);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: all 0.18s;
}

.worker-option label:hover {
    border-color: var(--border-blue);
    background: var(--accent-soft);
}

.worker-option input[type="radio"]:checked + label {
    background: var(--accent-soft);
    border-color: var(--accent);
    box-shadow: 0 0 0 3px var(--accent-glow);
}

.worker-avatar {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: var(--grad-blue);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 700;
    color: #fff;
    flex-shrink: 0;
}

.worker-name {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-1);
}

.worker-sub {
    font-size: 12px;
    color: var(--text-3);
    margin-top: 2px;
}

.worker-check {
    margin-left: auto;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 2px solid var(--border-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    color: transparent;
    transition: all 0.18s;
    flex-shrink: 0;
}

.worker-option input[type="radio"]:checked + label .worker-check {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
}

/* Report context card */
.report-context {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 16px;
    margin-bottom: 4px;
}

.report-context-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--text-1);
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.rc-meta {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
}

.rc-item {
    font-size: 12.5px;
    color: var(--text-3);
}

.rc-item strong { color: var(--text-2); }

/* ===== MOBILE RESPONSIVE ===== */
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

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
        <a href="assign-worker.jsp" class="active">Assign Workers</a>
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
            <a href="assign-worker.jsp" class="sidebar-link active">
                <span class="s-icon">👷</span> Assign Workers
            </a>
            <a href="review-work.jsp" class="sidebar-link">
                <span class="s-icon">🔍</span> Review Work
            </a>
            <a href="update-status.jsp" class="sidebar-link">
                <span class="s-icon">📝</span> Update Status
            </a>
        </div>

        <div class="sidebar-divider"></div>

        <!-- Workers count info -->
        <div class="sidebar-section">
            <div class="sidebar-label">Available Workers</div>
            <div style="padding:8px 0;
                        font-size:28px;
                        font-weight:700;
                        color:var(--text-1);">
                <%= wNames.size() %>
            </div>
            <div style="font-size:12px; color:var(--text-3);">
                Workers in your department
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
                    <span>Assign Worker</span>
                </div>
                <h1>Assign Worker</h1>
                <p>Select a worker from your department to handle this report.</p>
            </div>
            <a href="dashboard.jsp" class="lcps-btn ghost">
                ← Back
            </a>
        </div>

        <div style="max-width: 580px;">

            <!-- REPORT CONTEXT CARD -->
            <div class="lcps-card" style="margin-bottom:20px;">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">📋</div>
                        Report to Assign
                    </h3>
                    <a href="../citizen/view-report.jsp?id=<%= reportId %>"
                       class="lcps-btn xs ghost">
                        👁️ View
                    </a>
                </div>
                <div class="card-body">
                    <div class="report-context">
                        <div class="report-context-title">
                            #<%= reportId %> — <%= rTitle %>
                            <span class="badge <%= badgeClass %>">
                                <span class="dot"></span>
                                <%= rStatus %>
                            </span>
                        </div>
                        <div class="rc-meta">
                            <div class="rc-item">
                                Department:
                                <strong><%= rDept %></strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ASSIGN FORM CARD -->
            <div class="lcps-card">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">👷</div>
                        Select Worker
                    </h3>
                    <span style="font-size:12.5px; color:var(--text-3);">
                        <%= wNames.size() %>
                        worker<%= wNames.size() != 1 ? "s" : "" %> available
                    </span>
                </div>
                <div class="card-body">

                    <% if (wNames.isEmpty()) { %>
                    <div class="empty-state" style="padding:24px 0;">
                        <div class="empty-icon">👷</div>
                        <h3>No workers available</h3>
                        <p>
                            There are no workers assigned to your department yet.
                            Contact the Admin to add workers.
                        </p>
                        <a href="dashboard.jsp" class="lcps-btn outline">
                            ← Back to Dashboard
                        </a>
                    </div>

                    <% } else { %>

                    <form action="<%=request.getContextPath()%>/assign-worker"
                          method="post"
                          onsubmit="return confirmAssign();">

                        <input type="hidden" name="reportId" value="<%= reportId %>">

                        <div class="form-group">
                            <label class="form-label">
                                Choose a Worker
                                <span class="req">*</span>
                            </label>
                            <div class="worker-options">
                                <% for (int i = 0; i < wNames.size(); i++) {
                                    int wid  = wIds.get(i)[0];
                                    String wname = wNames.get(i);
                                    String initial = wname.substring(0,1).toUpperCase();
                                %>
                                <div class="worker-option">
                                    <input type="radio"
                                           name="workerId"
                                           id="w<%= wid %>"
                                           value="<%= wid %>"
                                           required>
                                    <label for="w<%= wid %>">
                                        <div class="worker-avatar">
                                            <%= initial %>
                                        </div>
                                        <div>
                                            <div class="worker-name">
                                                <%= wname %>
                                            </div>
                                            <div class="worker-sub">
                                                Worker ID: <%= wid %>
                                                &nbsp;·&nbsp; Dept Worker
                                            </div>
                                        </div>
                                        <div class="worker-check">✓</div>
                                    </label>
                                </div>
                                <% } %>
                            </div>
                        </div>

                        <div class="form-group"
                             style="margin-top:20px;">
                            <label class="form-label">
                                Assignment Note
                                <span style="color:var(--text-3);
                                             font-size:12px;
                                             font-weight:400;">
                                    (optional)
                                </span>
                            </label>
                            <textarea class="lcps-textarea"
                                      name="note"
                                      rows="2"
                                      placeholder="Any specific instructions for the worker...">
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
                                    id="assignBtn"
                                    style="flex:2;">
                                👷 Assign Worker
                            </button>
                        </div>

                    </form>
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
function confirmAssign() {
    const selected = document.querySelector(
        'input[name="workerId"]:checked'
    );
    if (!selected) {
        const ex = document.getElementById("assign-alert");
        if (ex) ex.remove();
        const div = document.createElement("div");
        div.id = "assign-alert";
        div.className = "lcps-alert error";
        div.style.marginBottom = "14px";
        div.innerHTML = '<span class="alert-icon">⚠️</span>Please select a worker.';
        document.querySelector(".worker-options")
                .insertAdjacentElement("beforebegin", div);
        return false;
    }

    const btn = document.getElementById("assignBtn");
    btn.textContent = "⏳ Assigning...";
    btn.disabled = true;
    btn.classList.add("ghost");
    return true;
}
</script>

</body>
</html>
