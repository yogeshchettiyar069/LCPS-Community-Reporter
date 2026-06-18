<%@ page import="model.User, model.UserRow, java.util.List, operations.ReportOperations" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || admin.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    ReportOperations ops = new ReportOperations();
    List<UserRow> userRows = ops.getAllUsers();

    // Pre-collect
    java.util.List<java.util.Map<String,Object>> users = new java.util.ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    int cCitizen=0, cAuthority=0, cWorker=0, cAdmin=0;

    for (UserRow ur : userRows) {
        java.util.Map<String,Object> row = new java.util.LinkedHashMap<>();
        String roleName = ur.getRoleName();
        row.put("userId",   ur.getUserId());
        row.put("name",     ur.getName());
        row.put("email",    ur.getEmail());
        row.put("phone",    ur.getPhone());
        row.put("role",     roleName);
        row.put("dept",     ur.getDeptName());
        row.put("joined",   ur.getCreatedAt() != null
                            ? sdf.format(ur.getCreatedAt()) : "—");
        users.add(row);

        if      ("CITIZEN".equals(roleName))   cCitizen++;
        else if ("AUTHORITY".equals(roleName)) cAuthority++;
        else if ("WORKER".equals(roleName))    cWorker++;
        else if ("ADMIN".equals(roleName))     cAdmin++;
    }
    int totalUsers = users.size();

    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");
%>
<!DOCTYPE html>
<html>
<head>
<title>User Management | Admin | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== USER STAT CARDS ===== */
.user-stat-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 20px;
}

.user-stat {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 14px 16px;
    display: flex;
    align-items: center;
    gap: 14px;
    cursor: pointer;
    transition: transform 0.18s, border-color 0.18s;
}

.user-stat:hover {
    transform: translateY(-2px);
    border-color: var(--border-blue);
}

.user-stat.active {
    box-shadow: 0 0 0 2px var(--accent);
    border-color: var(--accent);
}

.us-icon { font-size: 26px; flex-shrink: 0; }

.us-num {
    font-size: 24px;
    font-weight: 800;
    line-height: 1.1;
}

.us-lbl {
    font-size: 12px;
    color: var(--text-3);
    font-weight: 500;
}

/* ===== ROLE BADGES ===== */
.role-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 3px 10px;
    border-radius: var(--r-full);
    font-size: 11.5px;
    font-weight: 600;
}

.role-admin     { background:rgba(239,68,68,0.1);    color:var(--red);    border:1px solid rgba(239,68,68,0.3); }
.role-citizen   { background:rgba(79,142,247,0.1);   color:var(--accent); border:1px solid rgba(79,142,247,0.3); }
.role-authority { background:rgba(245,158,11,0.1);   color:var(--gold);   border:1px solid rgba(245,158,11,0.3); }
.role-worker    { background:rgba(16,185,129,0.1);   color:var(--green);  border:1px solid rgba(16,185,129,0.3); }

/* ===== FILTER BAR ===== */
.filter-bar {
    display: flex;
    gap: 8px;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 14px;
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

.filter-chip:hover  { border-color: var(--border-blue); }
.filter-chip.active { background: var(--accent); border-color: var(--accent); color: #fff; }
.filter-chip.f-citizen.active   { background: var(--accent); border-color: var(--accent); }
.filter-chip.f-authority.active { background: var(--gold);   border-color: var(--gold);   color: #000; }
.filter-chip.f-worker.active    { background: var(--green);  border-color: var(--green); }
.filter-chip.f-admin.active     { background: var(--red);    border-color: var(--red); }

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

/* ===== USER TABLE ===== */
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
}

.admin-table td {
    padding: 12px 12px;
    font-size: 13px;
    border-bottom: 1px solid var(--border);
    vertical-align: middle;
    color: var(--text-2);
}

.admin-table tr:last-child td { border-bottom: none; }
.admin-table tr:hover td { background: var(--accent-soft); }

/* User avatar in table */
.table-avatar {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--accent-soft);
    border: 1px solid var(--border-blue);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 700;
    color: var(--accent);
    flex-shrink: 0;
}

.user-name-cell {
    display: flex;
    align-items: center;
    gap: 10px;
}

/* Delete button */
.delete-btn {
    background: rgba(239,68,68,0.08);
    border: 1px solid rgba(239,68,68,0.3);
    border-radius: var(--r-sm);
    color: var(--red);
    font-size: 12px;
    padding: 5px 12px;
    cursor: pointer;
    transition: all 0.18s;
    white-space: nowrap;
}

.delete-btn:hover {
    background: var(--red);
    color: #fff;
    border-color: var(--red);
}

.protected-tag {
    font-size: 12px;
    color: var(--text-3);
    display: flex;
    align-items: center;
    gap: 4px;
}

/* ===== MOBILE RESPONSIVE ===== */
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 992px) {
    .user-stat-row { grid-template-columns: repeat(2, 1fr); }
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
    .search-wrap { margin-left: 0; width: 100%; }
    .search-wrap input { width: 100%; box-sizing: border-box; }
    .lcps-footer { flex-direction: column; text-align: center; gap: 10px; }
    .f-right { justify-content: center; }
}

@media (max-width: 480px) {
    .user-stat-row { grid-template-columns: 1fr; }
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
        <a href="all-reports.jsp">All Reports</a>
        <a href="users.jsp" class="active">Users</a>
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
            <a href="all-reports.jsp" class="sidebar-link">
                <span class="s-icon">📋</span> All Reports
            </a>
            <a href="users.jsp" class="sidebar-link active">
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

        <!-- User Counts -->
        <div class="sidebar-section">
            <div class="sidebar-label">By Role</div>
            <div style="display:flex; flex-direction:column;
                        gap:8px; padding:4px 0; font-size:13px;">
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Total</span>
                    <span style="font-weight:700; color:var(--text-1);">
                        <%= totalUsers %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Citizens</span>
                    <span style="font-weight:700; color:var(--accent);">
                        <%= cCitizen %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Authorities</span>
                    <span style="font-weight:700; color:var(--gold);">
                        <%= cAuthority %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Workers</span>
                    <span style="font-weight:700; color:var(--green);">
                        <%= cWorker %>
                    </span>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span style="color:var(--text-3);">Admins</span>
                    <span style="font-weight:700; color:var(--red);">
                        <%= cAdmin %>
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
                    <span>Users</span>
                </div>
                <h1>User Management</h1>
                <p>
                    View and manage all registered users.
                    <strong style="color:var(--text-1);">
                        <%= totalUsers %> total users
                    </strong>
                    registered.
                </p>
            </div>
            <a href="create-authority.jsp" class="lcps-btn">
                ➕ Create Account
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
        <% if ("true".equals(request.getParameter("deleted"))) { %>
        <div class="lcps-alert success" style="margin-bottom:20px;">
            <span class="alert-icon">✅</span>
            User deleted successfully.
        </div>
        <% } %>

        <!-- USER STAT CARDS -->
        <div class="user-stat-row">

            <div class="user-stat" id="sc-citizen"
                 onclick="filterUsers('CITIZEN', this)">
                <div class="us-icon">🧑‍💼</div>
                <div>
                    <div class="us-num" style="color:var(--accent);">
                        <%= cCitizen %>
                    </div>
                    <div class="us-lbl">Citizens</div>
                </div>
            </div>

            <div class="user-stat" id="sc-authority"
                 onclick="filterUsers('AUTHORITY', this)">
                <div class="us-icon">👮</div>
                <div>
                    <div class="us-num" style="color:var(--gold);">
                        <%= cAuthority %>
                    </div>
                    <div class="us-lbl">Authorities</div>
                </div>
            </div>

            <div class="user-stat" id="sc-worker"
                 onclick="filterUsers('WORKER', this)">
                <div class="us-icon">🦺</div>
                <div>
                    <div class="us-num" style="color:var(--green);">
                        <%= cWorker %>
                    </div>
                    <div class="us-lbl">Workers</div>
                </div>
            </div>

            <div class="user-stat" id="sc-admin"
                 onclick="filterUsers('ADMIN', this)">
                <div class="us-icon">🔐</div>
                <div>
                    <div class="us-num" style="color:var(--red);">
                        <%= cAdmin %>
                    </div>
                    <div class="us-lbl">Admins</div>
                </div>
            </div>

        </div>

        <!-- TABLE CARD -->
        <div class="lcps-card">
            <div class="card-header">
                <h3><div class="card-icon">👥</div> All Users</h3>
                <span style="font-size:12.5px; color:var(--text-3);"
                      id="userCount">
                    <%= totalUsers %> users
                </span>
            </div>
            <div class="card-body" style="padding-top:14px;">

                <!-- FILTER BAR -->
                <div class="filter-bar">
                    <button class="filter-chip active"
                            id="chip-all"
                            onclick="filterUsers('ALL', this)">
                        All (<%= totalUsers %>)
                    </button>
                    <button class="filter-chip f-citizen"
                            id="chip-citizen"
                            onclick="filterUsers('CITIZEN', this)">
                        🧑‍💼 Citizens (<%= cCitizen %>)
                    </button>
                    <button class="filter-chip f-authority"
                            id="chip-authority"
                            onclick="filterUsers('AUTHORITY', this)">
                        👮 Authorities (<%= cAuthority %>)
                    </button>
                    <button class="filter-chip f-worker"
                            id="chip-worker"
                            onclick="filterUsers('WORKER', this)">
                        🦺 Workers (<%= cWorker %>)
                    </button>
                    <button class="filter-chip f-admin"
                            id="chip-admin"
                            onclick="filterUsers('ADMIN', this)">
                        🔐 Admins (<%= cAdmin %>)
                    </button>
                    <div class="search-wrap">
                        <span class="search-icon">🔍</span>
                        <input type="text"
                               id="searchBox"
                               placeholder="Search users..."
                               oninput="searchUsers(this.value)">
                    </div>
                </div>

                <!-- TABLE -->
                <div style="overflow-x:auto;">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Department</th>
                            <th>Joined</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="userTbody">
                    <%
                        if (users.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="8"
                            style="text-align:center;
                                   padding:40px;
                                   color:var(--text-3);">
                            No users found.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (java.util.Map<String,Object> usr : users) {
                                int    uId    = (int)    usr.get("userId");
                                String uName  = (String) usr.get("name");
                                String uEmail = (String) usr.get("email");
                                String uPhone = (String) usr.get("phone");
                                String uRole  = (String) usr.get("role");
                                String uDept  = (String) usr.get("dept");
                                String uJoin  = (String) usr.get("joined");

                                String roleCss =
                                    "ADMIN".equals(uRole)     ? "role-admin"     :
                                    "AUTHORITY".equals(uRole) ? "role-authority" :
                                    "WORKER".equals(uRole)    ? "role-worker"    :
                                    "role-citizen";

                                String roleIcon =
                                    "ADMIN".equals(uRole)     ? "🔐" :
                                    "AUTHORITY".equals(uRole) ? "👮" :
                                    "WORKER".equals(uRole)    ? "🦺" : "🧑‍💼";

                                String initial = uName != null && !uName.isEmpty()
                                    ? uName.substring(0,1).toUpperCase() : "?";

                                String searchData = (uName + " " + uEmail
                                    + " " + uRole + " "
                                    + (uDept != null ? uDept : ""))
                                    .toLowerCase();
                    %>
                    <tr data-role="<%= uRole %>"
                        data-search="<%= searchData %>">
                        <td>
                            <span style="color:var(--text-3);
                                         font-size:12px;">
                                #<%= uId %>
                            </span>
                        </td>
                        <td>
                            <div class="user-name-cell">
                                <div class="table-avatar">
                                    <%= initial %>
                                </div>
                                <div>
                                    <div style="font-weight:600;
                                                color:var(--text-1);">
                                        <%= uName %>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td style="color:var(--text-3);">
                            <%= uEmail %>
                        </td>
                        <td>
                            <%= uPhone != null ? uPhone : "—" %>
                        </td>
                        <td>
                            <span class="role-badge <%= roleCss %>">
                                <%= roleIcon %> <%= uRole %>
                            </span>
                        </td>
                        <td>
                            <%= uDept != null ? uDept : "—" %>
                        </td>
                        <td style="color:var(--text-3);
                                   white-space:nowrap;">
                            <%= uJoin %>
                        </td>
                        <td>
                            <% if (!"ADMIN".equals(uRole)) { %>
                            <form action="<%=request.getContextPath()%>/admin"
                                  method="post"
                                  onsubmit="return confirmDelete('<%= uName %>');">
                                <input type="hidden"
                                       name="action"
                                       value="deleteUser">
                                <input type="hidden"
                                       name="user_id"
                                       value="<%= uId %>">
                                <button type="submit"
                                        class="delete-btn">
                                    🗑 Delete
                                </button>
                            </form>
                            <% } else { %>
                            <span class="protected-tag">
                                🔒 Protected
                            </span>
                            <% } %>
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
let currentRole = "ALL";

function filterUsers(role, el) {
    currentRole = role;

    document.querySelectorAll(".filter-chip").forEach(c =>
        c.classList.remove("active"));
    document.querySelectorAll(".user-stat").forEach(c =>
        c.classList.remove("active"));

    if (el) {
        el.classList.add("active");
        const chipEl = document.getElementById(
            "chip-" + role.toLowerCase());
        if (chipEl) chipEl.classList.add("active");
    }

    applyFilters();
}

function searchUsers(q) {
    applyFilters(q.toLowerCase().trim());
}

function applyFilters(searchQuery) {
    const q = searchQuery !== undefined
              ? searchQuery
              : document.getElementById("searchBox").value.toLowerCase().trim();

    const rows = document.querySelectorAll("#userTbody tr[data-role]");
    let visible = 0;

    rows.forEach(row => {
        const matchRole   = currentRole === "ALL" ||
                            row.dataset.role === currentRole;
        const matchSearch = !q || row.dataset.search.includes(q);
        const show = matchRole && matchSearch;
        row.style.display = show ? "" : "none";
        if (show) visible++;
    });

    document.getElementById("userCount").textContent =
        visible + " user" + (visible !== 1 ? "s" : "");
}

function confirmDelete(name) {
    return confirm("Delete user \"" + name + "\" permanently?\nThis cannot be undone.");
}
</script>

</body>
</html>
