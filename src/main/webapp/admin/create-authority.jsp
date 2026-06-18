<%@ page import="model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || admin.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String flash     = request.getParameter("msg");
    String flashType = request.getParameter("type");

    // Legacy param support
    boolean legacySuccess = "true".equals(request.getParameter("success"));
    boolean legacyError   = "true".equals(request.getParameter("error"));
%>
<!DOCTYPE html>
<html>
<head>
<title>Create Account | Admin | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== ROLE OPTION CARDS ===== */
.role-options {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 4px;
}

.role-option { position: relative; }

.role-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0; height: 0;
}

.role-option label {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 16px;
    background: var(--bg-input);
    border: 1.5px solid var(--border-md);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: all 0.18s;
}

.role-option label:hover {
    border-color: var(--border-blue);
    background: var(--accent-soft);
}

.role-option.r-authority input:checked + label {
    background: rgba(245,158,11,0.08);
    border-color: var(--gold);
    box-shadow: 0 0 0 3px rgba(245,158,11,0.15);
}

.role-option.r-worker input:checked + label {
    background: rgba(16,185,129,0.08);
    border-color: var(--green);
    box-shadow: 0 0 0 3px rgba(16,185,129,0.15);
}

.role-icon  { font-size: 24px; flex-shrink: 0; }

.role-name {
    font-size: 13.5px;
    font-weight: 600;
    color: var(--text-1);
    margin-bottom: 2px;
}

.role-desc {
    font-size: 11.5px;
    color: var(--text-3);
}

.role-check {
    margin-left: auto;
    width: 18px; height: 18px;
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

.role-option input:checked + label .role-check {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
}

/* ===== DEPT GRID ===== */
.dept-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
}

.dept-opt { position: relative; }

.dept-opt input[type="radio"] {
    position: absolute;
    opacity: 0; width: 0; height: 0;
}

.dept-opt label {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: var(--bg-input);
    border: 1px solid var(--border-md);
    border-radius: var(--r-sm);
    cursor: pointer;
    font-size: 13px;
    color: var(--text-2);
    transition: all 0.18s;
}

.dept-opt label:hover {
    border-color: var(--border-blue);
    color: var(--text-1);
}

.dept-opt input:checked + label {
    background: var(--accent-soft);
    border-color: var(--border-blue);
    color: var(--accent);
    font-weight: 600;
    box-shadow: 0 0 0 2px var(--accent-glow);
}

/* ===== PREVIEW CARD ===== */
.preview-card {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 18px;
    margin-bottom: 4px;
}

.preview-avatar {
    width: 52px; height: 52px;
    border-radius: 50%;
    background: var(--accent-soft);
    border: 2px solid var(--border-blue);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    font-weight: 700;
    color: var(--accent);
    margin: 0 auto 12px;
}

.preview-name {
    text-align: center;
    font-size: 15px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 4px;
}

.preview-email {
    text-align: center;
    font-size: 12.5px;
    color: var(--text-3);
    margin-bottom: 12px;
}

.preview-chips {
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-wrap: wrap;
}

/* Password strength */
.strength-bar {
    height: 5px;
    border-radius: var(--r-full);
    background: var(--bg-input);
    margin-top: 6px;
    overflow: hidden;
}

.strength-fill {
    height: 100%;
    border-radius: var(--r-full);
    transition: width 0.3s, background 0.3s;
    width: 0%;
}

.strength-label {
    font-size: 11.5px;
    margin-top: 4px;
    font-weight: 500;
}

/* ===== CONTENT SPLIT + MOBILE RESPONSIVE ===== */
.admin-split { display: grid; grid-template-columns: 1fr 300px; gap: 20px; align-items: start; }
.mobile-menu-btn { display: none; font-size: 24px; cursor: pointer; padding: 5px; user-select: none; }

@media (max-width: 992px) {
    .admin-split { grid-template-columns: 1fr; }
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

@media (max-width: 480px) {
    .role-options { grid-template-columns: 1fr; }
    .dept-grid { grid-template-columns: 1fr; }
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
        <a href="users.jsp">Users</a>
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
            <a href="users.jsp" class="sidebar-link">
                <span class="s-icon">👥</span> Users
            </a>
            <a href="create-authority.jsp" class="sidebar-link active">
                <span class="s-icon">➕</span> Create Account
            </a>
            <a href="departments.jsp" class="sidebar-link">
                <span class="s-icon">🏢</span> Departments
            </a>
            <a href="resolution-predictor.jsp" class="sidebar-link">
                <span class="s-icon">⏱️</span> Resolution Predictor
            </a>
        </div>

        <!-- Tips -->
        <div class="sidebar-section">
            <div class="sidebar-label">Guidelines</div>
            <div style="font-size:12.5px; color:var(--text-3);
                        line-height:1.7; padding:4px 0;">
                <div style="margin-bottom:8px;">
                    👮 <strong style="color:var(--text-2);">Authority</strong>
                    — supervises reports and assigns workers.
                </div>
                <div>
                    🦺 <strong style="color:var(--text-2);">Worker</strong>
                    — field staff who resolve on-ground issues.
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
                    <a href="users.jsp">Users</a>
                    <span class="sep">›</span>
                    <span>Create Account</span>
                </div>
                <h1>Create New Account</h1>
                <p>Register a new Authority or Field Worker account.</p>
            </div>
            <a href="users.jsp" class="lcps-btn ghost">← All Users</a>
        </div>

        <!-- FLASH -->
        <% if (legacySuccess || "success".equals(flashType)) { %>
        <div class="lcps-alert success" style="margin-bottom:20px;">
            <span class="alert-icon">✅</span>
            Account created successfully!
            <a href="users.jsp"
               style="color:var(--green); font-weight:600;
                      margin-left:10px; text-decoration:underline;">
                View Users →
            </a>
        </div>
        <% } %>
        <% if (legacyError || "error".equals(flashType)) { %>
        <div class="lcps-alert error" style="margin-bottom:20px;">
            <span class="alert-icon">⚠️</span>
            <%= flash != null ? flash :
                "Failed to create account. Email may already exist." %>
        </div>
        <% } %>

        <!-- FORM + PREVIEW GRID -->
        <div class="admin-split">

            <!-- FORM -->
            <div class="lcps-card">
                <div class="card-header">
                    <h3><div class="card-icon">➕</div> Account Details</h3>
                </div>
                <div class="card-body">
                    <form action="<%=request.getContextPath()%>/admin"
                          method="post"
                          id="createForm"
                          onsubmit="return validateForm();">

                        <input type="hidden"
                               name="action"
                               value="createAuthority">

                        <!-- ROLE SELECTION -->
                        <div class="form-group">
                            <label class="form-label">
                                Role
                                <span class="req">*</span>
                            </label>
                            <div class="role-options">

                                <div class="role-option r-authority">
                                    <input type="radio"
                                           name="role_id"
                                           id="role-auth"
                                           value="3"
                                           onchange="onRoleChange()">
                                    <label for="role-auth">
                                        <span class="role-icon">👮</span>
                                        <div>
                                            <div class="role-name">Authority</div>
                                            <div class="role-desc">
                                                Supervisor
                                            </div>
                                        </div>
                                        <div class="role-check">✓</div>
                                    </label>
                                </div>

                                <div class="role-option r-worker">
                                    <input type="radio"
                                           name="role_id"
                                           id="role-work"
                                           value="4"
                                           onchange="onRoleChange()">
                                    <label for="role-work">
                                        <span class="role-icon">🦺</span>
                                        <div>
                                            <div class="role-name">Worker</div>
                                            <div class="role-desc">
                                                Field Staff
                                            </div>
                                        </div>
                                        <div class="role-check">✓</div>
                                    </label>
                                </div>

                            </div>
                            <div class="form-hint" id="roleHint"></div>
                        </div>

                        <!-- DEPARTMENT -->
                        <div class="form-group" id="deptGroup"
                             style="display:none;">
                            <label class="form-label">
                                Department
                                <span class="req">*</span>
                            </label>
                            <div class="dept-grid">
                                <div class="dept-opt">
                                    <input type="radio" name="dept_id"
                                           id="d1" value="1"
                                           onchange="updatePreview()">
                                    <label for="d1">🛣️ Road</label>
                                </div>
                                <div class="dept-opt">
                                    <input type="radio" name="dept_id"
                                           id="d2" value="2"
                                           onchange="updatePreview()">
                                    <label for="d2">⚡ Electrical</label>
                                </div>
                                <div class="dept-opt">
                                    <input type="radio" name="dept_id"
                                           id="d3" value="3"
                                           onchange="updatePreview()">
                                    <label for="d3">💧 Water</label>
                                </div>
                                <div class="dept-opt">
                                    <input type="radio" name="dept_id"
                                           id="d4" value="4"
                                           onchange="updatePreview()">
                                    <label for="d4">🗑️ Garbage</label>
                                </div>
                                <div class="dept-opt">
                                    <input type="radio" name="dept_id"
                                           id="d5" value="5"
                                           onchange="updatePreview()">
                                    <label for="d5">🌳 Parks</label>
                                </div>
                                <div class="dept-opt">
                                    <input type="radio" name="dept_id"
                                           id="d6" value="6"
                                           onchange="updatePreview()">
                                    <label for="d6">🏗️ Building</label>
                                </div>
                                <div class="dept-opt"
                                     style="grid-column:1/-1;">
                                    <input type="radio" name="dept_id"
                                           id="d7" value="7"
                                           onchange="updatePreview()">
                                    <label for="d7">📦 Others</label>
                                </div>
                            </div>
                        </div>

                        <!-- NAME -->
                        <div class="form-group">
                            <label class="form-label" for="nameInput">
                                Full Name
                                <span class="req">*</span>
                            </label>
                            <input type="text"
                                   class="lcps-input"
                                   id="nameInput"
                                   name="name"
                                   placeholder="e.g. Ravi Kumar"
                                   oninput="updatePreview()"
                                   required>
                        </div>

                        <!-- EMAIL -->
                        <div class="form-group">
                            <label class="form-label" for="emailInput">
                                Email
                                <span class="req">*</span>
                            </label>
                            <input type="email"
                                   class="lcps-input"
                                   id="emailInput"
                                   name="email"
                                   placeholder="authority@dept.gov.in"
                                   oninput="updatePreview()"
                                   required>
                        </div>

                        <!-- PHONE -->
                        <div class="form-group">
                            <label class="form-label" for="phoneInput">
                                Phone
                                <span class="req">*</span>
                            </label>
                            <input type="text"
                                   class="lcps-input"
                                   id="phoneInput"
                                   name="phone"
                                   placeholder="10-digit phone number"
                                   maxlength="10"
                                   pattern="[0-9]{10}"
                                   oninput="updatePreview()"
                                   required>
                        </div>

                        <!-- PASSWORD -->
                        <div class="form-group">
                            <label class="form-label" for="passInput">
                                Password
                                <span class="req">*</span>
                            </label>
                            <div style="position:relative;">
                                <input type="password"
                                       class="lcps-input"
                                       id="passInput"
                                       name="password"
                                       placeholder="Set login password"
                                       oninput="checkStrength(this.value)"
                                       style="padding-right:40px;"
                                       required>
                                <button type="button"
                                        id="togglePass"
                                        onclick="togglePassword()"
                                        style="position:absolute; right:10px;
                                               top:50%; transform:translateY(-50%);
                                               background:none; border:none;
                                               cursor:pointer; font-size:16px;
                                               color:var(--text-3);">
                                    👁️
                                </button>
                            </div>
                            <div class="strength-bar">
                                <div class="strength-fill"
                                     id="strengthFill">
                                </div>
                            </div>
                            <div class="strength-label"
                                 id="strengthLabel"
                                 style="color:var(--text-3);">
                            </div>
                        </div>

                        <!-- ADDRESS -->
                        <div class="form-group">
                            <label class="form-label" for="addrInput">
                                Office Address
                                <span style="color:var(--text-3);
                                             font-size:12px;
                                             font-weight:400;">
                                    (optional)
                                </span>
                            </label>
                            <input type="text"
                                   class="lcps-input"
                                   id="addrInput"
                                   name="address"
                                   placeholder="Office or depot address">
                        </div>

                        <div style="display:flex; gap:10px; margin-top:4px;">
                            <a href="users.jsp"
                               class="lcps-btn ghost lg"
                               style="flex:1; text-align:center;">
                                Cancel
                            </a>
                            <button type="submit"
                                    class="lcps-btn lg"
                                    id="submitBtn"
                                    style="flex:2;">
                                ➕ Create Account
                            </button>
                        </div>

                    </form>
                </div>
            </div>

            <!-- RIGHT: PREVIEW -->
            <div>
                <!-- Live Preview -->
                <div class="lcps-card" style="margin-bottom:16px;">
                    <div class="card-header">
                        <h3>
                            <div class="card-icon">👤</div>
                            Preview
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="preview-card">
                            <div class="preview-avatar" id="prevAvatar">?</div>
                            <div class="preview-name" id="prevName">
                                Full Name
                            </div>
                            <div class="preview-email" id="prevEmail">
                                email@example.com
                            </div>
                            <div class="preview-chips">
                                <span class="badge badge-pending"
                                      id="prevRole"
                                      style="display:none;">
                                </span>
                                <span class="badge badge-assigned"
                                      id="prevDept"
                                      style="display:none;">
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Checklist -->
                <div class="lcps-card">
                    <div class="card-header">
                        <h3>
                            <div class="card-icon">✅</div>
                            Checklist
                        </h3>
                    </div>
                    <div class="card-body">
                        <div style="display:flex; flex-direction:column;
                                    gap:8px; font-size:13px;">
                            <div id="chk-role"  class="chk-item">
                                ⬜ Role selected
                            </div>
                            <div id="chk-dept"  class="chk-item">
                                ⬜ Department selected
                            </div>
                            <div id="chk-name"  class="chk-item">
                                ⬜ Name entered
                            </div>
                            <div id="chk-email" class="chk-item">
                                ⬜ Valid email
                            </div>
                            <div id="chk-phone" class="chk-item">
                                ⬜ 10-digit phone
                            </div>
                            <div id="chk-pass"  class="chk-item">
                                ⬜ Password set
                            </div>
                        </div>
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
const deptNames = {
    "1":"Road","2":"Electrical","3":"Water",
    "4":"Garbage","5":"Parks","6":"Building","7":"Others"
};

function onRoleChange() {
    const role = document.querySelector('input[name="role_id"]:checked');
    const deptGroup = document.getElementById("deptGroup");
    deptGroup.style.display = role ? "block" : "none";
    updateChecklist();
    updatePreview();
}

function updatePreview() {
    const name  = document.getElementById("nameInput").value.trim();
    const email = document.getElementById("emailInput").value.trim();
    const role  = document.querySelector('input[name="role_id"]:checked');
    const dept  = document.querySelector('input[name="dept_id"]:checked');

    // Avatar
    const av = document.getElementById("prevAvatar");
    av.textContent = name ? name.charAt(0).toUpperCase() : "?";

    document.getElementById("prevName").textContent  = name  || "Full Name";
    document.getElementById("prevEmail").textContent = email || "email@example.com";

    const roleEl = document.getElementById("prevRole");
    if (role) {
        roleEl.style.display = "inline-flex";
        roleEl.textContent = role.value === "3" ? "👮 Authority" : "🦺 Worker";
        roleEl.className = "badge " +
            (role.value === "3" ? "badge-assigned" : "badge-resolved");
    } else {
        roleEl.style.display = "none";
    }

    const deptEl = document.getElementById("prevDept");
    if (dept) {
        deptEl.style.display = "inline-flex";
        deptEl.textContent = "🏢 " + (deptNames[dept.value] || "");
    } else {
        deptEl.style.display = "none";
    }

    updateChecklist();
}

function updateChecklist() {
    const role  = document.querySelector('input[name="role_id"]:checked');
    const dept  = document.querySelector('input[name="dept_id"]:checked');
    const name  = document.getElementById("nameInput").value.trim();
    const email = document.getElementById("emailInput").value.trim();
    const phone = document.getElementById("phoneInput").value.trim();
    const pass  = document.getElementById("passInput").value.trim();

    setChk("chk-role",  !!role);
    setChk("chk-dept",  !!dept);
    setChk("chk-name",  name.length > 1);
    setChk("chk-email", /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email));
    setChk("chk-phone", /^\d{10}$/.test(phone));
    setChk("chk-pass",  pass.length >= 6);
}

function setChk(id, done) {
    const el = document.getElementById(id);
    const label = el.textContent.replace(/^[✅⬜] /, "");
    el.textContent = (done ? "✅" : "⬜") + " " + label;
    el.style.color = done ? "var(--green)" : "var(--text-3)";
}

function checkStrength(val) {
    const fill  = document.getElementById("strengthFill");
    const label = document.getElementById("strengthLabel");
    let   score = 0;
    if (val.length >= 6)  score++;
    if (val.length >= 10) score++;
    if (/[A-Z]/.test(val)) score++;
    if (/[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;

    const pct   = (score / 5) * 100;
    const color = score <= 1 ? "var(--red)"    :
                  score <= 2 ? "var(--gold)"   :
                  score <= 3 ? "var(--accent)"  :
                  "var(--green)";
    const lbl   = score <= 1 ? "Weak"      :
                  score <= 2 ? "Fair"      :
                  score <= 3 ? "Good"      :
                  score <= 4 ? "Strong"    :
                  "Very Strong";

    fill.style.width      = pct + "%";
    fill.style.background = color;
    label.textContent     = val.length ? lbl : "";
    label.style.color     = color;

    updateChecklist();
}

function togglePassword() {
    const inp = document.getElementById("passInput");
    inp.type = inp.type === "password" ? "text" : "password";
}

function validateForm() {
    const role  = document.querySelector('input[name="role_id"]:checked');
    const dept  = document.querySelector('input[name="dept_id"]:checked');
    const phone = document.getElementById("phoneInput").value.trim();

    if (!role) {
        alert("Please select a role.");
        return false;
    }
    if (!dept) {
        alert("Please select a department.");
        return false;
    }
    if (!/^\d{10}$/.test(phone)) {
        alert("Phone must be exactly 10 digits.");
        return false;
    }

    const btn = document.getElementById("submitBtn");
    btn.textContent = "⏳ Creating...";
    btn.disabled    = true;
    return true;
}

// Init checklist
document.querySelectorAll(".lcps-input").forEach(el => {
    el.addEventListener("input", updateChecklist);
});
</script>

</body>
</html>
