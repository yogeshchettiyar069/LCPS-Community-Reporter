<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="operations.UserOperations" %>

<%
    // ===== SESSION DATA =====
    Integer sessionOtp     = (Integer) session.getAttribute("otp");
    User    tempUser       = (User)    session.getAttribute("tempUser");
    Long    otpGeneratedAt = (Long)    session.getAttribute("otpGeneratedAt");

    // ===== EXPIRY CHECK (2 min = 120000 ms) =====
    boolean otpExpired  = false;
    long    remainingMs = 120000;

    if (otpGeneratedAt != null) {
        long elapsed = System.currentTimeMillis() - otpGeneratedAt;
        remainingMs  = 120000 - elapsed;
        if (remainingMs <= 0) { otpExpired = true; remainingMs = 0; }
    }
    long remainingSecs = remainingMs / 1000;

    // ===== OTP VERIFICATION =====
    String  enteredOtp          = request.getParameter("otp");
    boolean showError           = false;
    boolean registrationSuccess = false;
    String  errorMessage        = "Invalid OTP. Please try again.";

    if (enteredOtp != null && enteredOtp.trim().length() > 0) {
        enteredOtp = enteredOtp.trim();

        if (otpExpired) {
            errorMessage = "OTP has expired. Please click Resend OTP.";
            showError    = true;
        } else if (sessionOtp == null) {
            errorMessage = "Session expired. Please register again.";
            showError    = true;
        } else if (tempUser == null) {
            errorMessage = "Session data lost. Please register again.";
            showError    = true;
        } else {
            String sessionOtpStr = String.valueOf(sessionOtp);

            if (enteredOtp.equals(sessionOtpStr)) {
                try {
                    UserOperations ops = new UserOperations();
                    boolean registered = ops.register(tempUser);
                    if (registered) {
                        session.removeAttribute("otp");
                        session.removeAttribute("tempUser");
                        session.removeAttribute("otpGeneratedAt");
                        registrationSuccess = true;
                        response.setHeader("Refresh", "2; URL=login.jsp?registered=true");
                    } else {
                        errorMessage = "Registration failed. Email may already exist.";
                        showError    = true;
                    }
                } catch (Exception e) {
                    errorMessage = "System error: " + e.getMessage();
                    showError    = true;
                }
            } else {
                showError = true;
            }
        }
    }

    boolean justResent = "true".equals(request.getParameter("resent"));
%>

<!DOCTYPE html>
<html>
<head>
<title>Verify OTP | LCPS</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="css/theme-lcps-pro.css">
<style>
/* ===== PAGE LAYOUT ===== */
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
    max-width: 420px;
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
}
.auth-brand-text span { color: var(--accent); }
.auth-brand-sub {
    font-size: 11px;
    color: var(--text-3);
    letter-spacing: 0.3px;
}

/* Steps */
.steps {
    display: flex;
    align-items: center;
    justify-content: center;
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
}

.step.done .step-circle {
    background: var(--green);
    border-color: var(--green);
    color: #fff;
}

.step.active .step-circle {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
    box-shadow: var(--glow-blue);
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

/* Auth Card */
.auth-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--r-xl);
    padding: 32px;
    box-shadow: var(--shadow-lg);
    text-align: center;
}

.auth-card-title {
    font-size: 20px;
    font-weight: 700;
    color: var(--text-1);
    margin-bottom: 4px;
}

/* Email chip */
.email-chip {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    background: var(--accent-soft);
    border: 1px solid var(--accent-border);
    border-radius: var(--r-full);
    padding: 6px 14px;
    font-size: 13px;
    color: var(--accent);
    font-weight: 500;
    margin: 12px 0 24px;
    word-break: break-all;
    text-align: left;
}

/* ===== TIMER ===== */
.timer-section {
    margin-bottom: 20px;
}

.timer-wrap {
    position: relative;
    width: 96px;
    height: 96px;
    margin: 0 auto 8px;
}

.timer-wrap svg {
    transform: rotate(-90deg);
    filter: drop-shadow(0 0 6px rgba(79,142,247,0.3));
}

.ring-track {
    fill: none;
    stroke: rgba(255,255,255,0.05);
    stroke-width: 6;
}

.ring-fill {
    fill: none;
    stroke: var(--accent);
    stroke-width: 6;
    stroke-linecap: round;
    stroke-dasharray: 264;
    stroke-dashoffset: 0;
    transition: stroke-dashoffset 1s linear, stroke 0.4s;
}

.timer-center {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    font-size: 19px;
    font-weight: 700;
    font-family: 'Inter', monospace;
    color: var(--accent);
    transition: color 0.4s;
    letter-spacing: 0.5px;
}

.timer-label {
    font-size: 12px;
    color: var(--text-3);
    font-weight: 500;
    min-height: 18px;
    transition: color 0.3s;
}

/* ===== OTP BOXES ===== */
.otp-boxes {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin: 22px 0 16px;
}

.otp-box {
    width: 46px;
    height: 54px;
    border-radius: var(--r-sm);
    border: 1.5px solid var(--border-md);
    background: var(--bg-input);
    color: var(--text-1);
    font-size: 22px;
    font-weight: 700;
    text-align: center;
    outline: none;
    transition: border-color 0.2s, box-shadow 0.2s, transform 0.1s;
    caret-color: var(--accent);
}

.otp-box:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px var(--accent-glow);
    transform: scale(1.05);
}

.otp-box.filled {
    border-color: var(--accent);
    background: var(--accent-soft);
    color: var(--accent);
}

.otp-box:disabled {
    border-color: var(--border);
    color: var(--text-4);
    cursor: not-allowed;
    background: var(--bg-surface);
}

/* Hidden real input for form submit */
#otpHidden { display: none; }

/* Divider */
.otp-divider {
    height: 1px;
    background: var(--border);
    margin: 20px 0;
}

/* Auth footer */
.auth-footer {
    text-align: center;
    margin-top: 20px;
    font-size: 13px;
    color: var(--text-2);
}

.auth-footer a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 600;
}

.page-foot {
    margin-top: 20px;
    font-size: 12px;
    color: var(--text-4);
    text-align: center;
}

/* ===== RESPONSIVE ===== */

/* Tablet / large phones (≤ 480px) — tighten card, shrink OTP boxes slightly */
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

    .otp-box {
        width: 42px;
        height: 50px;
        font-size: 20px;
    }

    .otp-boxes {
        gap: 8px;
    }
}

/* Small phones (≤ 400px) — shrink OTP boxes more, reduce body padding */
@media (max-width: 400px) {
    body {
        padding: 14px;
    }

    .auth-card {
        padding: 20px 16px;
    }

    .otp-box {
        width: 38px;
        height: 46px;
        font-size: 18px;
    }

    .otp-boxes {
        gap: 6px;
    }

    .step-line {
        width: 36px;
    }
}

/* Very small phones (≤ 360px) — minimum viable OTP boxes */
@media (max-width: 360px) {
    body {
        padding: 10px;
    }

    .auth-card {
        padding: 18px 14px;
    }

    .otp-box {
        width: 34px;
        height: 42px;
        font-size: 16px;
    }

    .otp-boxes {
        gap: 5px;
    }

    .auth-brand-icon {
        width: 36px;
        height: 36px;
        font-size: 18px;
    }

    .auth-brand-text {
        font-size: 17px;
    }

    .email-chip {
        font-size: 11px;
        padding: 5px 10px;
    }
}
</style>
</head>

<body>

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
        <div class="step done">
            <div class="step-circle">✓</div>
            <div class="step-label">Your Details</div>
        </div>
        <div class="step-line done"></div>
        <div class="step active">
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

        <% if (registrationSuccess) { %>
        <!-- ===== SUCCESS STATE ===== -->
        <div style="padding: 20px 0;">
            <div style="font-size:52px; margin-bottom:16px;">🎉</div>
            <div class="auth-card-title">Registration Successful!</div>
            <p style="color:var(--text-2); font-size:13.5px; margin:10px 0 20px;">
                Your account has been created.<br>
                Redirecting to login...
            </p>
            <div class="lcps-alert success"
                 style="justify-content:center; text-align:left;">
                <span class="alert-icon">✅</span>
                Account created for
                <strong style="color:var(--text-1);">
                    <%= tempUser != null ? tempUser.getEmail() : "" %>
                </strong>
            </div>
            <!-- Animated redirect bar -->
            <div style="margin-top:16px;">
                <div class="progress-bar">
                    <div class="progress-fill green"
                         id="redirectBar"
                         style="width:0%;
                                transition: width 2s linear;">
                    </div>
                </div>
                <div style="font-size:12px;
                            color:var(--text-3);
                            margin-top:6px;">
                    Redirecting in 2 seconds...
                </div>
            </div>
        </div>

        <% } else { %>
        <!-- ===== VERIFY STATE ===== -->

        <div class="auth-card-title">Check your email</div>

        <% if (tempUser != null) { %>
        <div class="email-chip">
            📧 <%= tempUser.getEmail() %>
        </div>
        <% } %>

        <!-- Alerts -->
        <% if (justResent) { %>
        <div class="lcps-alert info" style="text-align:left; margin-bottom:16px;">
            <span class="alert-icon">📨</span>
            New OTP sent! Previous OTP is now invalid.
        </div>
        <% } %>

        <% if (showError) { %>
        <div class="lcps-alert error" style="text-align:left; margin-bottom:16px;">
            <span class="alert-icon">⚠️</span>
            <%= errorMessage %>
        </div>
        <% } %>

        <!-- Timer -->
        <div class="timer-section">
            <div class="timer-wrap">
                <svg width="96" height="96" viewBox="0 0 100 100">
                    <circle class="ring-track" cx="50" cy="50" r="42"/>
                    <circle class="ring-fill"  cx="50" cy="50" r="42"
                            id="timerRing"/>
                </svg>
                <div class="timer-center" id="timerDisplay">2:00</div>
            </div>
            <div class="timer-label" id="timerLabel">
                OTP valid for 2 minutes
            </div>
        </div>

        <!-- OTP Form -->
        <form method="post"
              action="verify-otp.jsp"
              id="otpForm"
              onsubmit="return submitOtp();">

            <!-- 6 individual boxes -->
            <div class="otp-boxes">
                <input class="otp-box" type="text"
                       maxlength="1" inputmode="numeric"
                       id="b0" autocomplete="off">
                <input class="otp-box" type="text"
                       maxlength="1" inputmode="numeric"
                       id="b1" autocomplete="off">
                <input class="otp-box" type="text"
                       maxlength="1" inputmode="numeric"
                       id="b2" autocomplete="off">
                <input class="otp-box" type="text"
                       maxlength="1" inputmode="numeric"
                       id="b3" autocomplete="off">
                <input class="otp-box" type="text"
                       maxlength="1" inputmode="numeric"
                       id="b4" autocomplete="off">
                <input class="otp-box" type="text"
                       maxlength="1" inputmode="numeric"
                       id="b5" autocomplete="off">
            </div>

            <!-- Hidden input that carries combined OTP value -->
            <input type="hidden" name="otp" id="otpHidden">

            <button type="submit"
                    class="lcps-btn lg"
                    id="verifyBtn"
                    style="width:100%;">
                Verify OTP →
            </button>
        </form>

        <div class="otp-divider"></div>

        <!-- Resend Form -->
        <form method="post"
              action="<%=request.getContextPath()%>/auth">
            <input type="hidden" name="action" value="resendOtp">
            <button type="submit"
                    class="lcps-btn ghost"
                    id="resendBtn"
                    style="width:100%;">
                🔁 Resend OTP
            </button>
        </form>

        <p style="font-size:12px;
                  color:var(--text-4);
                  margin-top:14px;
                  line-height:1.7;">
            Didn't receive it? Check your spam/junk folder.<br>
            Resending will invalidate the current OTP.
        </p>

        <% } %>

    </div>

    <div class="auth-footer">
        Wrong account?
        <a href="register.jsp">Register again</a>
    </div>

    <div class="page-foot">
        © 2026 LCPS — Local Community Problem Solver
    </div>

</div>

<!-- ===== SCRIPTS ===== -->
<script>
/* ===== OTP BOX LOGIC ===== */
const boxes = Array.from(document.querySelectorAll(".otp-box"));

boxes.forEach((box, idx) => {
    box.addEventListener("keydown", e => {
        if (e.key === "Backspace") {
            if (box.value === "" && idx > 0) {
                boxes[idx - 1].focus();
                boxes[idx - 1].value = "";
                boxes[idx - 1].classList.remove("filled");
            } else {
                box.value = "";
                box.classList.remove("filled");
            }
            e.preventDefault();
        }
    });

    box.addEventListener("input", e => {
        const val = e.target.value.replace(/[^0-9]/g, "");
        box.value = val;

        if (val) {
            box.classList.add("filled");
            if (idx < 5) boxes[idx + 1].focus();
        } else {
            box.classList.remove("filled");
        }
    });

    // Paste support — paste 6 digits at once
    box.addEventListener("paste", e => {
        e.preventDefault();
        const pasted = (e.clipboardData || window.clipboardData)
            .getData("text")
            .replace(/[^0-9]/g,"")
            .slice(0, 6);
        pasted.split("").forEach((ch, i) => {
            if (boxes[i]) {
                boxes[i].value = ch;
                boxes[i].classList.add("filled");
            }
        });
        if (pasted.length === 6) boxes[5].focus();
    });
});

// Auto-focus first box
if (boxes[0]) boxes[0].focus();

function submitOtp() {
    const otp = boxes.map(b => b.value).join("");
    if (otp.length < 6) {
        showOtpAlert("Please enter all 6 digits.");
        return false;
    }
    document.getElementById("otpHidden").value = otp;
    return true;
}

function showOtpAlert(msg) {
    const ex = document.getElementById("js-otp-alert");
    if (ex) ex.remove();
    const div = document.createElement("div");
    div.id = "js-otp-alert";
    div.className = "lcps-alert error";
    div.style.cssText = "text-align:left; margin-bottom:14px;";
    div.innerHTML = `<span class="alert-icon">⚠️</span>${msg}`;
    const form = document.getElementById("otpForm");
    form.parentNode.insertBefore(div, form);
}

/* ===== TIMER ===== */
const TOTAL   = 120;
const CIRCUMF = 2 * Math.PI * 42;
let timeLeft  = <%= remainingSecs %>;

const ring      = document.getElementById("timerRing");
const display   = document.getElementById("timerDisplay");
const label     = document.getElementById("timerLabel");
const verifyBtn = document.getElementById("verifyBtn");

if (ring) {
    ring.style.strokeDasharray  = CIRCUMF;
    ring.style.strokeDashoffset = 0;
}

function pad(n) { return String(n).padStart(2,"0"); }
function fmtTime(s) { return Math.floor(s/60)+":"+pad(s%60); }

function tick() {
    if (timeLeft <= 0) {
        if (ring)      { ring.style.strokeDashoffset = CIRCUMF; ring.style.stroke = "var(--red)"; }
        if (display)   { display.textContent = "0:00"; display.style.color = "var(--red)"; }
        if (label)     { label.textContent = "OTP expired — click Resend OTP"; label.style.color = "var(--red)"; }
        if (verifyBtn) { verifyBtn.disabled = true; verifyBtn.textContent = "⏰ OTP Expired"; }
        boxes.forEach(b => { b.disabled = true; b.style.opacity = "0.4"; });
        clearInterval(ticker);
        return;
    }

    if (display) display.textContent = fmtTime(timeLeft);

    const pct = timeLeft / TOTAL;
    if (ring) ring.style.strokeDashoffset = CIRCUMF * (1 - pct);

    if (timeLeft <= 20) {
        if (ring)    ring.style.stroke    = "var(--red)";
        if (display) display.style.color  = "var(--red)";
        if (label)   { label.textContent  = "⚠️ Expiring very soon!"; label.style.color = "var(--red)"; }
    } else if (timeLeft <= 60) {
        if (ring)    ring.style.stroke    = "var(--gold)";
        if (display) display.style.color  = "var(--gold)";
        if (label)   { label.textContent  = "⚠️ Less than 1 minute left"; label.style.color = "var(--gold)"; }
    } else {
        if (ring)    ring.style.stroke    = "var(--accent)";
        if (display) display.style.color  = "var(--accent)";
        if (label)   { label.textContent  = "OTP valid for 2 minutes"; label.style.color = "var(--text-3)"; }
    }
    timeLeft--;
}

tick();
const ticker = setInterval(tick, 1000);

/* ===== REDIRECT PROGRESS BAR (success state) ===== */
const bar = document.getElementById("redirectBar");
if (bar) setTimeout(() => { bar.style.width = "100%"; }, 50);
</script>

</body>
</html>
