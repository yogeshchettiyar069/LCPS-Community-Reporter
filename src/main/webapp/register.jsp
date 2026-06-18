<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Register | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="css/theme-lcps-pro.css">
<style>
/* ===== AUTH PAGE ===== */
body {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    padding: 30px 20px;
}

.auth-wrap {
    width: 100%;
    max-width: 460px;
}

/* Brand */
.auth-brand {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    margin-bottom: 28px;
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
    font-size: 13px;
    color: var(--text-2);
    margin-bottom: 24px;
}

/* Citizen locked badge */
.citizen-badge {
    display: flex;
    align-items: center;
    gap: 10px;
    background: var(--accent-soft);
    border: 1px solid var(--accent-border);
    border-radius: var(--r-md);
    padding: 11px 14px;
    margin-bottom: 24px;
    font-size: 13px;
    color: var(--accent);
}

.citizen-badge .cb-icon {
    font-size: 18px;
    flex-shrink: 0;
}

.citizen-badge strong { color: var(--text-1); }
.citizen-badge small  { color: var(--text-3); font-size: 11px; display:block; margin-top:1px; }

/* Two column grid for form */
.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}

/* Password strength */
.strength-bar-wrap {
    margin-top: 8px;
}

.strength-bars {
    display: flex;
    gap: 4px;
    margin-bottom: 5px;
}

.strength-bar {
    flex: 1;
    height: 4px;
    border-radius: 4px;
    background: var(--border-md);
    transition: background 0.3s;
}

.strength-text {
    font-size: 11.5px;
    color: var(--text-3);
    font-weight: 500;
}

/* Auth footer */
.auth-footer {
    text-align: center;
    margin-top: 20px;
    font-size: 13.5px;
    color: var(--text-2);
}

.auth-footer a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 600;
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

/* Steps indicator */
.steps {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0;
    margin-bottom: 28px;
}

.step {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
}

.step-circle {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: var(--bg-input);
    border: 2px solid var(--border-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 700;
    color: var(--text-3);
    transition: all 0.2s;
}

.step.active .step-circle {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
    box-shadow: var(--glow-blue);
}

.step.done .step-circle {
    background: var(--green);
    border-color: var(--green);
    color: #fff;
}

.step-label {
    font-size: 10px;
    color: var(--text-3);
    font-weight: 500;
    white-space: nowrap;
}

.step.active .step-label { color: var(--accent); }
.step.done   .step-label { color: var(--green); }

.step-line {
    width: 50px;
    height: 2px;
    background: var(--border-md);
    margin-bottom: 16px;
    flex-shrink: 0;
}

.step-line.done { background: var(--green); }

.page-foot {
    margin-top: 20px;
    font-size: 12px;
    color: var(--text-4);
    text-align: center;
}

/* ===== RESPONSIVE ===== */

/* Tablet / large phones (≤ 480px) — tighten card & brand */
@media (max-width: 480px) {
    .auth-card {
        padding: 24px 20px;
    }

    .auth-card-title {
        font-size: 18px;
    }

    .auth-brand {
        margin-bottom: 20px;
    }
}

/* Small phones (≤ 400px) — stack the 2-col form row, reduce spacing */
@media (max-width: 400px) {
    body {
        padding: 14px;
    }

    .form-row {
        grid-template-columns: 1fr;
        gap: 0;
    }

    .auth-card {
        padding: 20px 16px;
    }

    .step-line {
        width: 36px;
    }
}

/* Very small phones (≤ 360px) — further trim */
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

    .citizen-badge {
        font-size: 12px;
        padding: 9px 11px;
    }
}
</style>
</head>

<body>

<!-- ===== LOADER ===== -->
<div id="loaderOverlay">
    <div class="loader-ring"></div>
    <div id="loaderText">Creating your account...</div>
</div>

<div class="auth-wrap">

    <!-- Brand -->
    <a href="login.jsp" class="auth-brand">
        <div class="auth-brand-icon">🏛️</div>
        <div>
            <div class="auth-brand-text">LC<span>PS</span></div>
            <div class="auth-brand-sub">Local Community Problem Solver</div>
        </div>
    </a>

    <!-- Steps -->
    <div class="steps">
        <div class="step active">
            <div class="step-circle">1</div>
            <div class="step-label">Your Details</div>
        </div>
        <div class="step-line"></div>
        <div class="step">
            <div class="step-circle">2</div>
            <div class="step-label">Verify OTP</div>
        </div>
        <div class="step-line"></div>
        <div class="step">
            <div class="step-circle">✓</div>
            <div class="step-label">Done!</div>
        </div>
    </div>

    <!-- Card -->
    <div class="auth-card">

        <div class="auth-card-title">Create your account</div>
        <div class="auth-card-sub">
            Join LCPS to report and track community issues
        </div>

        <!-- Citizen badge -->
        <div class="citizen-badge">
            <span class="cb-icon">👤</span>
            <div>
                <strong>Registering as Citizen</strong>
                <small>
                    Authority &amp; Worker accounts are created by Admin
                </small>
            </div>
        </div>

        <!-- Form -->
        <form id="regForm"
              action="<%=request.getContextPath()%>/auth"
              method="post"
              onsubmit="return handleRegister();">

            <input type="hidden" name="action"  value="register">
            <input type="hidden" name="role_id" value="2">

            <!-- Name + Phone row -->
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">
                        Full Name <span class="req">*</span>
                    </label>
                    <input class="lcps-input"
                           type="text"
                           name="name"
                           id="name"
                           placeholder="Yogesh Chettiyar"
                           required
                           autocomplete="name">
                </div>
                <div class="form-group">
                    <label class="form-label">
                        Phone <span class="req">*</span>
                    </label>
                    <input class="lcps-input"
                           type="text"
                           name="phone"
                           id="phone"
                           placeholder="10-digit number"
                           maxlength="10"
                           required>
                </div>
            </div>

            <!-- Email -->
            <div class="form-group">
                <label class="form-label">
                    Email Address <span class="req">*</span>
                </label>
                <input class="lcps-input"
                       type="email"
                       name="email"
                       id="email"
                       placeholder="you@example.com"
                       required
                       autocomplete="email">
                <div class="form-hint">
                    OTP will be sent to this email
                </div>
            </div>

            <!-- Password -->
            <div class="form-group">
                <label class="form-label">
                    Password <span class="req">*</span>
                </label>
                <div style="position:relative;">
                    <input class="lcps-input"
                           type="password"
                           name="password"
                           id="password"
                           placeholder="Create a strong password"
                           required
                           autocomplete="new-password"
                           oninput="checkStrength(this.value)"
                           style="padding-right:44px;">
                    <button type="button"
                            onclick="togglePwd()"
                            style="position:absolute; right:12px; top:50%;
                                   transform:translateY(-50%);
                                   background:none; border:none;
                                   cursor:pointer; font-size:16px;
                                   color:var(--text-3); padding:0;"
                            id="eyeBtn">👁️</button>
                </div>
                <!-- Strength meter -->
                <div class="strength-bar-wrap">
                    <div class="strength-bars">
                        <div class="strength-bar" id="sb1"></div>
                        <div class="strength-bar" id="sb2"></div>
                        <div class="strength-bar" id="sb3"></div>
                        <div class="strength-bar" id="sb4"></div>
                    </div>
                    <div class="strength-text" id="strengthText">
                        Enter a password
                    </div>
                </div>
            </div>

            <!-- Address -->
            <div class="form-group">
                <label class="form-label">
                    Address
                    <span style="color:var(--text-3);
                                 font-weight:400;
                                 font-size:12px;">
                        (optional)
                    </span>
                </label>
                <textarea class="lcps-textarea"
                          name="address"
                          rows="2"
                          placeholder="Your locality / area"></textarea>
            </div>

            <!-- Submit -->
            <button type="submit"
                    class="lcps-btn lg"
                    style="width:100%;">
                📧 Register &amp; Send OTP
            </button>

        </form>

    </div>

    <div class="auth-footer">
        Already have an account?
        <a href="login.jsp">Sign in</a>
    </div>

    <div class="page-foot">
        © 2026 LCPS — Local Community Problem Solver
    </div>

</div>

<!-- ===== SCRIPTS ===== -->
<script>
function handleRegister() {
    const name     = document.getElementById("name").value.trim();
    const email    = document.getElementById("email").value.trim();
    const phone    = document.getElementById("phone").value.trim();
    const password = document.getElementById("password").value.trim();

    if (!name || !email || !phone || !password) {
        showAlert("Please fill in all required fields.");
        return false;
    }

    if (!/^\d{10}$/.test(phone)) {
        showAlert("Please enter a valid 10-digit phone number.");
        return false;
    }

    if (password.length < 6) {
        showAlert("Password must be at least 6 characters.");
        return false;
    }

    const overlay   = document.getElementById("loaderOverlay");
    const loaderTxt = document.getElementById("loaderText");
    overlay.style.display = "flex";
    loaderTxt.textContent = "Creating your account...";

    setTimeout(() => {
        loaderTxt.textContent = "Sending OTP to your email...";
    }, 1000);

    setTimeout(() => {
        document.getElementById("regForm").submit();
    }, 2000);

    return false;
}

function togglePwd() {
    const pwd    = document.getElementById("password");
    const btn    = document.getElementById("eyeBtn");
    const isText = pwd.type === "text";
    pwd.type     = isText ? "password" : "text";
    btn.textContent = isText ? "👁️" : "🙈";
}

function checkStrength(val) {
    const bars   = [
        document.getElementById("sb1"),
        document.getElementById("sb2"),
        document.getElementById("sb3"),
        document.getElementById("sb4")
    ];
    const txt    = document.getElementById("strengthText");
    let score    = 0;

    if (val.length >= 6)                       score++;
    if (val.length >= 10)                      score++;
    if (/[A-Z]/.test(val) && /[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val))             score++;

    const colors = ["#ef4444","#f59e0b","#4f8ef7","#10b981"];
    const labels = ["Weak","Fair","Good","Strong"];

    bars.forEach((b, i) => {
        b.style.background = i < score
            ? colors[score - 1]
            : "var(--border-md)";
    });

    if (val.length === 0) {
        txt.textContent = "Enter a password";
        txt.style.color = "var(--text-3)";
    } else {
        txt.textContent = "Strength: " + labels[score - 1] || "Weak";
        txt.style.color = colors[score - 1];
    }
}

function showAlert(msg) {
    const existing = document.getElementById("js-alert");
    if (existing) existing.remove();

    const div = document.createElement("div");
    div.id = "js-alert";
    div.className = "lcps-alert error";
    div.style.marginBottom = "16px";
    div.innerHTML = `<span class="alert-icon">⚠️</span>${msg}`;

    const form = document.getElementById("regForm");
    form.parentNode.insertBefore(div, form);
    div.scrollIntoView({ behavior: "smooth", block: "center" });
}
</script>

</body>
</html>
