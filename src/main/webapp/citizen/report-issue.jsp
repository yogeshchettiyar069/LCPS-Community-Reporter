<%@ page import="model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User u = (User) session.getAttribute("user");
    if (u == null || u.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<title>Report Issue | LCPS</title>
<!-- Required meta tag for mobile responsiveness -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/theme-lcps-pro.css">
<style>
/* ===== MAP SECTION ===== */
#map {
    width: 100%;
    height: 300px;
    border-radius: var(--r-md);
    border: 1px solid var(--border-md);
    margin-bottom: 10px;
    overflow: hidden;
    transition: border-color 0.2s;
}

#map:hover { border-color: var(--border-blue); }

.coords-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 4px;
}

.coord-box {
    background: var(--bg-surface);
    border: 1px solid var(--border);
    border-radius: var(--r-sm);
    padding: 9px 13px;
    font-size: 12.5px;
    color: var(--green);
    font-family: monospace;
    letter-spacing: 0.3px;
    cursor: default;
}

.coord-box.empty { color: var(--text-4); }

.location-status {
    font-size: 12.5px;
    color: var(--text-3);
    text-align: center;
    padding: 6px 0;
    min-height: 20px;
    transition: color 0.3s;
}

.location-status.success { color: var(--green); }
.location-status.error   { color: var(--red); }
.location-status.loading { color: var(--accent); }

/* ===== SEVERITY SELECTOR ===== */
.severity-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    margin-bottom: 4px;
}

.sev-option { position: relative; }

.sev-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0; height: 0;
}

.sev-option label {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    padding: 12px 8px;
    background: var(--bg-input);
    border: 1.5px solid var(--border-md);
    border-radius: var(--r-sm);
    cursor: pointer;
    transition: all 0.18s;
    font-size: 12px;
    font-weight: 500;
    color: var(--text-2);
    text-align: center;
}

.sev-option label .sev-emoji { font-size: 22px; }

.sev-option input[type="radio"]:checked + label {
    font-weight: 600;
}

/* Severity color states */
.sev-option.low input:checked + label {
    background: rgba(16,185,129,0.1);
    border-color: var(--green);
    color: var(--green);
    box-shadow: 0 0 0 3px rgba(16,185,129,0.15);
}

.sev-option.medium input:checked + label {
    background: rgba(245,158,11,0.1);
    border-color: var(--gold);
    color: var(--gold);
    box-shadow: 0 0 0 3px rgba(245,158,11,0.15);
}

.sev-option.high input:checked + label {
    background: rgba(239,68,68,0.1);
    border-color: var(--red);
    color: var(--red);
    box-shadow: 0 0 0 3px rgba(239,68,68,0.15);
}

/* ===== FILE UPLOAD ===== */
.file-upload-area {
    border: 2px dashed var(--border-md);
    border-radius: var(--r-md);
    padding: 24px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
    background: var(--bg-input);
    position: relative;
}

.file-upload-area:hover {
    border-color: var(--border-blue);
    background: var(--accent-soft);
}

.file-upload-area.dragover {
    border-color: var(--accent);
    background: var(--accent-soft);
    box-shadow: 0 0 0 3px var(--accent-glow);
}

.file-upload-area input[type="file"] {
    position: absolute;
    inset: 0;
    opacity: 0;
    cursor: pointer;
    width: 100%;
    height: 100%;
}

.upload-icon  { font-size: 32px; margin-bottom: 8px; }
.upload-text  { font-size: 14px; color: var(--text-2); font-weight: 500; }
.upload-hint  { font-size: 12px; color: var(--text-3); margin-top: 4px; }

.preview-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
    gap: 8px;
    margin-top: 14px;
}

.preview-grid img {
    width: 100%;
    height: 80px;
    object-fit: cover;
    border-radius: var(--r-sm);
    border: 1px solid var(--border-md);
}

/* ===== STEPS SIDEBAR ===== */
.form-steps {
    display: flex;
    flex-direction: column;
    gap: 0;
    margin-bottom: 24px;
}

.form-step-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 10px 0;
    position: relative;
}

.form-step-item:not(:last-child)::after {
    content: "";
    position: absolute;
    left: 11px;
    top: 34px;
    width: 2px;
    height: calc(100% - 14px);
    background: var(--border-md);
}

.step-num {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: var(--bg-input);
    border: 2px solid var(--border-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 700;
    color: var(--text-3);
    flex-shrink: 0;
    margin-top: 1px;
    z-index: 1;
}

.form-step-item.done .step-num {
    background: var(--green);
    border-color: var(--green);
    color: #fff;
}

.form-step-item.active .step-num {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
    box-shadow: var(--glow-blue);
}

.step-info-title {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-1);
    line-height: 1.3;
}

.step-info-sub {
    font-size: 11.5px;
    color: var(--text-3);
}

/* ===== RESPONSIVE OVERRIDES ===== */
.mobile-menu-btn {
    display: none;
    font-size: 24px;
    cursor: pointer;
    padding: 5px;
    user-select: none;
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

@media (max-width: 768px) {
    .mobile-menu-btn {
        display: block; /* Show hamburger menu */
    }
    .header-nav {
        display: none; /* Hide top nav */
    }
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
    .lcps-sidebar.active {
        display: block;
    }

    /* Form Fields Stacking */
    .form-grid {
        grid-template-columns: 1fr; /* Stack Dept and Severity */
    }
    
    .coords-row {
        grid-template-columns: 1fr; /* Stack Lat/Lng outputs */
    }
    
    .severity-grid {
        gap: 6px; /* Tighter gap on mobile */
    }

    /* Submit Actions Stacking */
    .submit-actions {
        flex-direction: column;
        width: 100%;
    }
    .submit-actions .lcps-btn {
        width: 100%;
        text-align: center;
        justify-content: center;
    }

    .lcps-footer {
        flex-direction: column;
        text-align: center;
        gap: 10px;
    }
}
</style>
</head>
<body>

<!-- ===== HEADER ===== -->
<div class="lcps-header">
    <div style="display:flex; align-items:center; gap:10px;">
        <!-- Mobile Menu Toggle -->
        <div class="mobile-menu-btn" onclick="document.querySelector('.lcps-sidebar').classList.toggle('active')">
            ☰
        </div>
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
        <a href="my-reports.jsp">My Reports</a>
        <a href="report-issue.jsp" class="active">Report Issue</a>
    </div>
    <div class="header-right">
        <div class="user-chip">
            <div class="avatar">
                <%= u.getName().substring(0,1).toUpperCase() %>
            </div>
            <div>
                <div class="user-info-name"><%= u.getName() %></div>
                <div class="user-info-role">Citizen</div>
            </div>
        </div>
    </div>
</div>

<!-- ===== LAYOUT ===== -->
<div class="lcps-layout">

    <!-- SIDEBAR -->
    <div class="lcps-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Main</div>
            <a href="dashboard.jsp" class="sidebar-link">
                <span class="s-icon">📊</span> Dashboard
            </a>
            <a href="my-reports.jsp" class="sidebar-link">
                <span class="s-icon">📋</span> My Reports
            </a>
            <a href="report-issue.jsp" class="sidebar-link active">
                <span class="s-icon">➕</span> Report Issue
            </a>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-label">Form Steps</div>
            <div class="form-steps">
                <div class="form-step-item active" id="step-ind-1">
                    <div class="step-num">1</div>
                    <div>
                        <div class="step-info-title">Issue Details</div>
                        <div class="step-info-sub">Title, description</div>
                    </div>
                </div>
                <div class="form-step-item" id="step-ind-2">
                    <div class="step-num">2</div>
                    <div>
                        <div class="step-info-title">Category</div>
                        <div class="step-info-sub">Dept & severity</div>
                    </div>
                </div>
                <div class="form-step-item" id="step-ind-3">
                    <div class="step-num">3</div>
                    <div>
                        <div class="step-info-title">Location</div>
                        <div class="step-info-sub">Pin on map</div>
                    </div>
                </div>
                <div class="form-step-item" id="step-ind-4">
                    <div class="step-num">4</div>
                    <div>
                        <div class="step-info-title">Photos</div>
                        <div class="step-info-sub">Upload images</div>
                    </div>
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
                    <a href="dashboard.jsp">Home</a>
                    <span class="sep">›</span>
                    <a href="my-reports.jsp">My Reports</a>
                    <span class="sep">›</span>
                    <span>Report Issue</span>
                </div>
                <h1>Report a Community Issue</h1>
                <p>Fill in the details below to submit a new report.</p>
            </div>
        </div>

        <form id="reportForm"
              action="<%=request.getContextPath()%>/report"
              method="post"
              enctype="multipart/form-data"
              onsubmit="return validateAndSubmit();">

            <!-- ===== STEP 1 — ISSUE DETAILS ===== -->
            <div class="lcps-card" id="section-1">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">📝</div>
                        Step 1 — Issue Details
                    </h3>
                    <span class="badge badge-pending">
                        <span class="dot"></span>Required
                    </span>
                </div>
                <div class="card-body">
                    <div class="form-group">
                        <label class="form-label">
                            Issue Title <span class="req">*</span>
                        </label>
                        <input class="lcps-input"
                               type="text"
                               name="title"
                               id="titleInput"
                               placeholder="e.g. Large pothole on MG Road"
                               maxlength="100"
                               required
                               oninput="updateCharCount(this, 'titleCount', 100)">
                        <div class="form-hint"
                             style="display:flex;
                                    justify-content:space-between;">
                            <span>Be specific — mention street/area name</span>
                            <span id="titleCount"
                                  style="color:var(--text-3);">
                                0/100
                            </span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            Description <span class="req">*</span>
                        </label>
                        <textarea class="lcps-textarea"
                                  name="description"
                                  id="descInput"
                                  rows="4"
                                  placeholder="Describe the issue in detail — when did you notice it, how serious is it, who is affected..."
                                  maxlength="500"
                                  required
                                  oninput="updateCharCount(this, 'descCount', 500)"></textarea>
                        <div class="form-hint"
                             style="display:flex;
                                    justify-content:space-between;">
                            <span>Minimum 20 characters</span>
                            <span id="descCount"
                                  style="color:var(--text-3);">
                                0/500
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ===== STEP 2 — CATEGORY & SEVERITY ===== -->
            <div class="lcps-card" id="section-2">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">🏷️</div>
                        Step 2 — Category &amp; Severity
                    </h3>
                </div>
                <div class="card-body">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                Department <span class="req">*</span>
                            </label>
                            <select class="lcps-select"
                                    name="dept_id"
                                    required>
                                <option value="">Select Department</option>
                                <option value="1">🛣️ Road Maintenance</option>
                                <option value="2">💡 Electrical</option>
                                <option value="3">💧 Water &amp; Sanitation</option>
                                <option value="4">🗑️ Garbage Collection</option>
                                <option value="5">🌳 Parks &amp; Recreation</option>
                                <option value="6">🏗️ Building Violations</option>
                                <option value="7">📌 Others</option>
                            </select>
                            <div class="form-hint">
                                Choose the most relevant department
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">
                                Severity Level <span class="req">*</span>
                            </label>
                            <div class="severity-grid">
                                <div class="sev-option low">
                                    <input type="radio"
                                           name="severity"
                                           id="sev-low"
                                           value="Low">
                                    <label for="sev-low">
                                        <span class="sev-emoji">🟢</span>
                                        Low
                                    </label>
                                </div>
                                <div class="sev-option medium">
                                    <input type="radio"
                                           name="severity"
                                           id="sev-med"
                                           value="Medium"
                                           checked>
                                    <label for="sev-med">
                                        <span class="sev-emoji">🟡</span>
                                        Medium
                                    </label>
                                </div>
                                <div class="sev-option high">
                                    <input type="radio"
                                           name="severity"
                                           id="sev-high"
                                           value="High">
                                    <label for="sev-high">
                                        <span class="sev-emoji">🔴</span>
                                        High
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ===== STEP 3 — LOCATION ===== -->
            <div class="lcps-card" id="section-3">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">📍</div>
                        Step 3 — Pin Location
                    </h3>
                    <button type="button"
                            class="lcps-btn sm outline"
                            onclick="autoDetectLocation()">
                        🎯 Auto-detect
                    </button>
                </div>
                <div class="card-body">
                    <!-- Map -->
                    <div id="map"></div>

                    <!-- Status -->
                    <div class="location-status" id="locationStatus">
                        Click the map or use Auto-detect to set location
                    </div>

                    <!-- Coordinate display -->
                    <div class="coords-row">
                        <div class="coord-box empty" id="latDisplay">
                            Latitude —
                        </div>
                        <div class="coord-box empty" id="lngDisplay">
                            Longitude —
                        </div>
                    </div>

                    <div class="form-hint" style="margin-top:8px;">
                        📌 You can drag the marker to fine-tune the location
                    </div>

                    <!-- Hidden inputs -->
                    <input type="hidden" name="latitude"  id="latInput">
                    <input type="hidden" name="longitude" id="lngInput">
                </div>
            </div>

            <!-- ===== STEP 4 — PHOTOS ===== -->
            <div class="lcps-card" id="section-4">
                <div class="card-header">
                    <h3>
                        <div class="card-icon">📷</div>
                        Step 4 — Upload Photos
                    </h3>
                    <span style="font-size:12.5px; color:var(--text-3);">
                        1–5 images
                    </span>
                </div>
                <div class="card-body">
                    <div class="file-upload-area"
                         id="uploadArea"
                         ondragover="handleDragOver(event)"
                         ondragleave="handleDragLeave(event)"
                         ondrop="handleDrop(event)">
                        <input type="file"
                               name="images"
                               id="fileInput"
                               multiple
                               accept="image/*"
                               required
                               onchange="previewImages(this)">
                        <div class="upload-icon">📸</div>
                        <div class="upload-text">
                            Drag &amp; drop photos here or
                            <span style="color:var(--accent);
                                         font-weight:600;">
                                click to browse
                            </span>
                        </div>
                        <div class="upload-hint">
                            JPG, PNG, WEBP — Max 5 images
                        </div>
                    </div>

                    <!-- Image previews -->
                    <div class="preview-grid" id="previewGrid"></div>
                    <div id="fileCountMsg"
                         style="font-size:12px;
                                color:var(--text-3);
                                margin-top:8px;">
                    </div>
                </div>
            </div>

            <!-- ===== SUBMIT ===== -->
            <div class="submit-actions" 
                 style="display:flex;
                        justify-content:flex-end;
                        gap:12px;
                        margin-top:4px;
                        margin-bottom:30px;">
                <a href="my-reports.jsp"
                   class="lcps-btn ghost lg">
                    Cancel
                </a>
                <button type="submit"
                        class="lcps-btn lg"
                        id="submitBtn">
                    📤 Submit Report
                </button>
            </div>

        </form>
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

<!-- ===== SCRIPTS ===== -->
<script>
let map, marker;

/* ===== GOOGLE MAPS ===== */
function initMap() {
    const defaultLocation = { lat: 19.0760, lng: 72.8777 };

    map = new google.maps.Map(document.getElementById("map"), {
        center: defaultLocation,
        zoom: 13,
        mapTypeId: "roadmap",
        styles: [
            { elementType: "geometry",
              stylers: [{ color: "#0d1526" }] },
            { elementType: "labels.text.fill",
              stylers: [{ color: "#8ba3c7" }] },
            { elementType: "labels.text.stroke",
              stylers: [{ color: "#0d1526" }] },
            { featureType: "road",
              elementType: "geometry",
              stylers: [{ color: "#1c2d4f" }] },
            { featureType: "road",
              elementType: "geometry.stroke",
              stylers: [{ color: "#111d35" }] },
            { featureType: "water",
              elementType: "geometry",
              stylers: [{ color: "#080d16" }] },
            { featureType: "poi",
              stylers: [{ visibility: "off" }] },
            { featureType: "transit",
              stylers: [{ visibility: "off" }] }
        ]
    });

    map.addListener("click", function(event) {
        placeMarker(event.latLng.lat(), event.latLng.lng());
    });

    autoDetectLocation();
}

function placeMarker(lat, lng) {
    if (marker) marker.setMap(null);

    marker = new google.maps.Marker({
        position: { lat: lat, lng: lng },
        map: map,
        draggable: true,
        title: "Issue Location",
        animation: google.maps.Animation.DROP
    });

    marker.addListener("dragend", function(e) {
        updateCoords(e.latLng.lat(), e.latLng.lng());
    });

    updateCoords(lat, lng);
}

function updateCoords(lat, lng) {
    const latR = lat.toFixed(6);
    const lngR = lng.toFixed(6);

    document.getElementById("latInput").value = latR;
    document.getElementById("lngInput").value = lngR;

    const latBox = document.getElementById("latDisplay");
    const lngBox = document.getElementById("lngDisplay");

    latBox.textContent = "📍 " + latR;
    lngBox.textContent = "📍 " + lngR;
    latBox.classList.remove("empty");
    lngBox.classList.remove("empty");

    setStatus("✅ Location pinned: " + latR + ", " + lngR, "success");
}

function autoDetectLocation() {
    if (!navigator.geolocation) {
        setStatus("❌ Geolocation not supported", "error");
        return;
    }
    setStatus("🔍 Detecting your location...", "loading");

    navigator.geolocation.getCurrentPosition(
        function(pos) {
            const lat = pos.coords.latitude;
            const lng = pos.coords.longitude;
            map.setCenter({ lat, lng });
            map.setZoom(16);
            placeMarker(lat, lng);
        },
        function(err) {
            const msgs = {
                1: "❌ Permission denied. Click the map to pin manually.",
                2: "❌ Location unavailable. Click the map to pin manually.",
                3: "❌ Timed out. Click the map to pin manually."
            };
            setStatus(msgs[err.code] || "❌ Location error", "error");
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
}

function setStatus(msg, type) {
    const el = document.getElementById("locationStatus");
    el.textContent = msg;
    el.className = "location-status " + (type || "");
}

/* ===== IMAGE PREVIEW ===== */
function previewImages(input) {
    const grid    = document.getElementById("previewGrid");
    const countMsg= document.getElementById("fileCountMsg");
    const files   = Array.from(input.files).slice(0, 5);
    grid.innerHTML = "";

    files.forEach(file => {
        const reader = new FileReader();
        reader.onload = e => {
            const img = document.createElement("img");
            img.src = e.target.result;
            grid.appendChild(img);
        };
        reader.readAsDataURL(file);
    });

    countMsg.textContent = files.length > 0
        ? `${files.length} image${files.length > 1 ? "s" : ""} selected`
        : "";

    if (files.length > 5) {
        countMsg.textContent = "⚠️ Max 5 images — only first 5 will be uploaded";
        countMsg.style.color = "var(--gold)";
    }
}

/* ===== DRAG & DROP ===== */
function handleDragOver(e) {
    e.preventDefault();
    document.getElementById("uploadArea").classList.add("dragover");
}

function handleDragLeave(e) {
    document.getElementById("uploadArea").classList.remove("dragover");
}

function handleDrop(e) {
    e.preventDefault();
    document.getElementById("uploadArea").classList.remove("dragover");
    const input = document.getElementById("fileInput");
    input.files = e.dataTransfer.files;
    previewImages(input);
}

/* ===== CHAR COUNTER ===== */
function updateCharCount(el, counterId, max) {
    const len = el.value.length;
    const counter = document.getElementById(counterId);
    counter.textContent = len + "/" + max;
    counter.style.color = len > max * 0.9
        ? "var(--gold)" : "var(--text-3)";
}

/* ===== FORM VALIDATION ===== */
function validateAndSubmit() {
    const lat   = document.getElementById("latInput").value;
    const lng   = document.getElementById("lngInput").value;
    const desc  = document.getElementById("descInput").value.trim();
    const title = document.getElementById("titleInput").value.trim();

    if (!title) {
        showFormAlert("Please enter an issue title.");
        return false;
    }
    if (desc.length < 20) {
        showFormAlert("Description must be at least 20 characters.");
        return false;
    }
    if (!lat || !lng) {
        showFormAlert("Please pin a location on the map.");
        document.getElementById("section-3")
                .scrollIntoView({ behavior: "smooth" });
        return false;
    }

    const btn = document.getElementById("submitBtn");
    btn.textContent = "⏳ Submitting...";
    btn.disabled = true;
    btn.classList.add("ghost");
    return true;
}

function showFormAlert(msg) {
    const ex = document.getElementById("form-alert");
    if (ex) ex.remove();
    const div = document.createElement("div");
    div.id = "form-alert";
    div.className = "lcps-alert error";
    div.style.marginBottom = "16px";
    div.innerHTML = `<span class="alert-icon">⚠️</span>${msg}`;
    const form = document.getElementById("reportForm");
    form.insertAdjacentElement("afterbegin", div);
    div.scrollIntoView({ behavior: "smooth", block: "center" });
}

/* ===== SCROLL STEP HIGHLIGHT ===== */
window.addEventListener("scroll", () => {
    const sections = [1, 2, 3, 4];
    sections.forEach(n => {
        const sec = document.getElementById("section-" + n);
        const ind = document.getElementById("step-ind-" + n);
        if (!sec || !ind) return;
        const rect = sec.getBoundingClientRect();
        if (rect.top < window.innerHeight * 0.5 && rect.bottom > 0) {
            ind.classList.add("active");
        } else {
            ind.classList.remove("active");
        }
    });
});
</script>

<!-- Load Google Maps — replace with your API key -->
<script
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCCLubAIgVpcz8kJNlbeAN1jsFBSeelubg&callback=initMap"
    async defer>
</script>

</body>
</html>