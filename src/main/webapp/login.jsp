<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Login | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="css/theme-lcps-pro.css">
<style>
/* ===== AUTH PAGE SPECIFIC ===== */
body {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    padding: 20px;
}

.auth-wrap {
    width: 100%;
    max-width: 420px;
}

/* Brand */
.auth-brand {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    margin-bottom: 32px;
    text-decoration: none;
}

.auth-brand-icon {
    width: 42px;
    height: 42px;
    background: var(--grad-blue);
    border-radius: var(--r-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    box-shadow: var(--glow-blue);
}

.auth-brand-text {
    font-size: 20px;
    font-weight: 800;
    color: var(--text-1);
    letter-spacing: -0.3px;
}

.auth-brand-text span { color: var(--accent); }

.auth-brand-sub {
    font-size: 11px;
    color: var(--text-3);
    font-weight: 400;
    letter-spacing: 0.3px;
}

/* Card */
.auth-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--r-xl);
    padding: 32px;
    box-shadow: var(--shadow-lg);
}

.auth-card-title {
    font-size: 20px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 4px;
    letter-spacing: -0.3px;
}

.auth-card-sub {
    font-size: 13.5px;
    color: var(--text-2);
    margin-bottom: 28px;
}

/* Role selector */
.role-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
    margin-bottom: 22px;
}

.role-option {
    position: relative;
}

.role-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0;
    height: 0;
}

.role-option label {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    padding: 10px 6px;
    background: var(--bg-input);
    border: 1px solid var(--border-md);
    border-radius: var(--r-sm);
    cursor: pointer;
    transition: all 0.18s;
    font-size: 11px;
    font-weight: 500;
    color: var(--text-2);
    text-align: center;
}

.role-option label .role-icon { font-size: 20px; }

.role-option input[type="radio"]:checked + label {
    background: var(--accent-soft);
    border-color: var(--accent);
    color: var(--accent);
    box-shadow: 0 0 0 3px var(--accent-glow);
}

.role-option label:hover {
    border-color: var(--border-blue);
    color: var(--text-1);
}

/* Divider */
.form-divider {
    height: 1px;
    background: var(--border);
    margin: 22px 0;
}

/* Auth footer */
.auth-footer {
    text-align: center;
    margin-top: 22px;
    font-size: 13.5px;
    color: var(--text-2);
}

.auth-footer a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 600;
    transition: opacity 0.2s;
}

.auth-footer a:hover { opacity: 0.8; }

/* Loader */
#loaderOverlay {
    position: fixed;
    inset: 0;
    background: var(--bg-overlay);
    display: none;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    gap: 20px;
    z-index: 9999;
    backdrop-filter: blur(6px);
}

.loader-ring {
    width: 52px;
    height: 52px;
    border: 3px solid var(--border-md);
    border-top: 3px solid var(--accent);
    border-radius: 50%;
    animation: spin 0.9s linear infinite;
}

@keyframes spin { 100% { transform: rotate(360deg); } }

#loaderText {
    font-size: 15px;
    font-weight: 500;
    color: var(--text-2);
}

/* Page footer */
.page-foot {
    margin-top: 24px;
    font-size: 12px;
    color: var(--text-4);
    text-align: center;
}

/* ===== RESPONSIVE ===== */

/* Tablet and below (≤ 480px) — tighten card padding */
@media (max-width: 480px) {
    .auth-card {
        padding: 24px 20px;
    }

    .auth-card-title {
        font-size: 18px;
    }

    .auth-brand {
        margin-bottom: 24px;
    }
}

/* Small phones (≤ 400px) — switch role grid to 2×2 */
@media (max-width: 400px) {
    body {
        padding: 14px;
    }

    .role-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .auth-card {
        padding: 20px 16px;
    }
}

/* Very small phones (≤ 360px) — further reduce spacing */
@media (max-width: 360px) {
    body {
        padding: 10px;
    }

    .auth-card {
        padding: 18px 14px;
    }

    .auth-brand-icon {
        width: 36px;
        height: 36px;
        font-size: 18px;
    }

    .auth-brand-text {
        font-size: 17px;
    }
}
</style>
</head>

<body>

<!-- ===== LOADER ===== -->
<div id="loaderOverlay">
    <div class="loader-ring"></div>
    <div id="loaderText">Verifying credentials...</div>
</div>

<!-- ===== AUTH WRAP ===== -->
<div class="auth-wrap">

    <!-- Brand -->
    <a href="#" class="auth-brand">
        <div class="auth-brand-icon">🏛️</div>
        <div>
            <div class="auth-brand-text">LC<span>PS</span></div>
            <div class="auth-brand-sub">Local Community Problem Solver</div>
        </div>
    </a>

    <!-- Card -->
    <div class="auth-card">

        <div class="auth-card-title">Welcome back</div>
        <div class="auth-card-sub">Sign in to your account to continue</div>

        <!-- Error -->
        <% if (request.getParameter("error") != null) { %>
        <div class="lcps-alert error" style="margin-bottom:20px;">
            <span class="alert-icon">⚠️</span>
            Invalid email or password. Please try again.
        </div>
        <% } %>

        <!-- Registered success -->
        <% if ("true".equals(request.getParameter("registered"))) { %>
        <div class="lcps-alert success" style="margin-bottom:20px;">
            <span class="alert-icon">✅</span>
            Registration successful! You can now log in.
        </div>
        <% } %>

        <!-- Form -->
        <form id="loginForm"
              action="<%=request.getContextPath()%>/auth"
              method="post"
              onsubmit="return handleLogin();">

            <input type="hidden" name="action" value="login">

            <!-- Role Selector -->
            <div class="form-group">
                <label class="form-label">
                    Login As <span class="req">*</span>
                </label>
                <div class="role-grid">
                    <div class="role-option">
                        <input type="radio" name="role_id"
                               id="role-admin" value="1">
                        <label for="role-admin">
                            <span class="role-icon">🛡️</span>
                            Admin
                        </label>
                    </div>
                    <div class="role-option">
                        <input type="radio" name="role_id"
                               id="role-citizen" value="2" checked>
                        <label for="role-citizen">
                            <span class="role-icon">👤</span>
                            Citizen
                        </label>
                    </div>
                    <div class="role-option">
                        <input type="radio" name="role_id"
                               id="role-authority" value="3">
                        <label for="role-authority">
                            <span class="role-icon">🏢</span>
                            Authority
                        </label>
                    </div>
                    <div class="role-option">
                        <input type="radio" name="role_id"
                               id="role-worker" value="4">
                        <label for="role-worker">
                            <span class="role-icon">👷</span>
                            Worker
                        </label>
                    </div>
                </div>
            </div>

            <div class="form-divider"></div>

            <!-- Email -->
            <div class="form-group">
                <label class="form-label" for="email">
                    Email Address <span class="req">*</span>
                </label>
                <input class="lcps-input"
                       type="email"
                       id="email"
                       name="email"
                       placeholder="you@example.com"
                       required
                       autocomplete="email">
            </div>

            <!-- Password -->
            <div class="form-group">
                <label class="form-label" for="password">
                    Password <span class="req">*</span>
                </label>
                <div style="position:relative;">
                    <input class="lcps-input"
                           type="password"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           required
                           autocomplete="current-password"
                           style="padding-right:44px;">
                    <button type="button"
                            onclick="togglePassword()"
                            style="position:absolute; right:12px; top:50%;
                                   transform:translateY(-50%);
                                   background:none; border:none;
                                   cursor:pointer; font-size:16px;
                                   color:var(--text-3); padding:0;"
                            id="eyeBtn">👁️</button>
                </div>
            </div>

            <!-- Submit -->
            <button type="submit"
                    class="lcps-btn lg"
                    style="width:100%; margin-top:6px; color: black; background: yellow;">
                Sign In →
            </button>

        </form>

    </div>

    <!-- Footer link -->
    <div class="auth-footer">
        Don't have an account?
        <a href="register.jsp">Create one free</a>
    </div>

    <div class="page-foot">
        © 2026 LCPS — Local Community Problem Solver
    </div>

</div>

<!-- ===== SCRIPTS ===== -->
<script>
function handleLogin() {
    const email    = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value.trim();
    const role     = document.querySelector("input[name='role_id']:checked");

    if (!email || !password) {
        showAlert("Please enter your email and password.");
        return false;
    }

    if (!role) {
        showAlert("Please select a role.");
        return false;
    }

    // Show loader
    const overlay   = document.getElementById("loaderOverlay");
    const loaderTxt = document.getElementById("loaderText");
    overlay.style.display = "flex";
    loaderTxt.textContent = "Verifying credentials...";

    setTimeout(() => {
        loaderTxt.textContent = "Logging you in...";
    }, 900);

    setTimeout(() => {
        document.getElementById("loginForm").submit();
    }, 1800);

    return false;
}

function togglePassword() {
    const pwd    = document.getElementById("password");
    const btn    = document.getElementById("eyeBtn");
    const isText = pwd.type === "text";
    pwd.type     = isText ? "password" : "text";
    btn.textContent = isText ? "👁️" : "🙈";
}

function showAlert(msg) {
    const existing = document.getElementById("js-alert");
    if (existing) existing.remove();

    const div = document.createElement("div");
    div.id = "js-alert";
    div.className = "lcps-alert error";
    div.style.marginBottom = "16px";
    div.innerHTML = `<span class="alert-icon">⚠️</span>${msg}`;

    const form = document.getElementById("loginForm");
    form.parentNode.insertBefore(div, form);
}
</script>

</body>
</html>
