<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sqlsystem.database.DatabaseConnection" %>
<%@ page import="java.sql.*" %>
<%
    // Role guard — only admin can access this page
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Admin Dashboard — SQL Query Evaluator</title>
  <link href="https://fonts.googleapis.com/css2?family=Oxanium:wght@300;400;600;700;800&family=JetBrains+Mono:wght@300;400;500;600&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg: #070710; --surface: #0d0d1a; --panel: #10101f;
      --border: #1c1c35; --border-hi: #2a2a50;
      --cyan: #00d4ff; --cyan-dim: rgba(0,212,255,0.15);
      --cyan-glow: rgba(0,212,255,0.35);
      --green: #39ff14; --green-dim: rgba(57,255,20,0.12);
      --text: #c8d6e8; --text-dim: #5a6a80; --text-mid: #8899aa;
      --red: #ff4560; --red-dim: rgba(255,69,96,0.15);
      --orange: #ffb86c;
    }
    html, body {
      min-height: 100%; background: var(--bg);
      color: var(--text); font-family: 'Oxanium', sans-serif;
    }
    body::before {
      content: ''; position: fixed; inset: 0;
      background-image:
        linear-gradient(rgba(0,212,255,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(0,212,255,0.03) 1px, transparent 1px);
      background-size: 40px 40px; pointer-events: none; z-index: 0;
    }

    /* ── TOPBAR ── */
    .topbar {
      position: sticky; top: 0; z-index: 100;
      display: flex; align-items: center; gap: 16px;
      padding: 0 32px; height: 56px;
      background: var(--surface); border-bottom: 1px solid var(--border);
      box-shadow: 0 4px 24px rgba(0,0,0,0.5);
    }
    .topbar-logo {
      font-size: 13px; font-weight: 700; letter-spacing: 2px;
      text-transform: uppercase; color: var(--cyan);
      display: flex; align-items: center; gap: 8px;
    }
    .topbar-logo::before { content: '◆'; font-size: 9px; }
    .topbar-sep { flex: 1; }
    .topbar-user {
      display: flex; align-items: center; gap: 10px;
      font-family: 'JetBrains Mono', monospace; font-size: 12px; color: var(--text-dim);
    }
    .user-badge {
      background: var(--cyan-dim); border: 1px solid rgba(0,212,255,0.25);
      border-radius: 4px; padding: 3px 10px; color: var(--cyan); font-size: 11px;
    }
    .btn-logout {
      background: var(--red-dim); border: 1px solid rgba(255,69,96,0.3);
      border-radius: 6px; padding: 6px 14px; color: var(--red);
      font-family: 'Oxanium', sans-serif; font-size: 12px; font-weight: 600;
      cursor: pointer; text-decoration: none; transition: all 0.2s;
      letter-spacing: 0.5px;
    }
    .btn-logout:hover { background: rgba(255,69,96,0.25); }

    /* ── LAYOUT ── */
    .layout {
      position: relative; z-index: 1;
      display: flex; min-height: calc(100vh - 56px);
    }

    /* ── SIDEBAR ── */
    .sidebar {
      width: 220px; flex-shrink: 0;
      background: var(--surface); border-right: 1px solid var(--border);
      padding: 24px 0; display: flex; flex-direction: column; gap: 4px;
    }
    .sidebar-section {
      font-family: 'JetBrains Mono', monospace; font-size: 9px;
      color: var(--text-dim); letter-spacing: 2px; text-transform: uppercase;
      padding: 0 20px; margin: 12px 0 6px;
    }
    .nav-item {
      display: flex; align-items: center; gap: 10px;
      padding: 10px 20px; cursor: pointer;
      font-size: 13px; color: var(--text-mid);
      border-left: 2px solid transparent;
      transition: all 0.15s;
    }
    .nav-item:hover { background: rgba(0,212,255,0.04); color: var(--text); }
    .nav-item.active {
      background: var(--cyan-dim); color: var(--cyan);
      border-left-color: var(--cyan);
    }
    .nav-icon { font-size: 15px; width: 20px; text-align: center; }

    /* ── MAIN CONTENT ── */
    .main { flex: 1; padding: 32px; overflow-x: auto; }

    .page-title {
      font-size: 22px; font-weight: 800; margin-bottom: 6px;
      background: linear-gradient(135deg, #fff 0%, var(--cyan) 100%);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
    }
    .page-subtitle {
      font-family: 'JetBrains Mono', monospace; font-size: 11px;
      color: var(--text-dim); margin-bottom: 28px; letter-spacing: 1px;
    }

    /* ── STAT CARDS ── */
    .stats-row {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px; margin-bottom: 28px;
    }
    .stat-card {
      background: var(--panel); border: 1px solid var(--border);
      border-radius: 10px; padding: 20px;
      box-shadow: 0 0 0 1px var(--border-hi);
    }
    .stat-label {
      font-family: 'JetBrains Mono', monospace; font-size: 10px;
      color: var(--text-dim); letter-spacing: 1px; text-transform: uppercase;
      margin-bottom: 10px;
    }
    .stat-value {
      font-size: 28px; font-weight: 800; color: var(--cyan);
    }
    .stat-sub { font-size: 11px; color: var(--text-dim); margin-top: 4px; }

    /* ── PANEL ── */
    .panel {
      background: var(--panel); border: 1px solid var(--border);
      border-radius: 12px; overflow: hidden;
      box-shadow: 0 0 0 1px var(--border-hi), 0 8px 32px rgba(0,0,0,0.4);
      margin-bottom: 24px;
    }
    .panel-header {
      display: flex; align-items: center; justify-content: space-between;
      padding: 16px 20px; background: var(--surface);
      border-bottom: 1px solid var(--border);
    }
    .panel-title {
      font-size: 13px; font-weight: 700; letter-spacing: 1px;
      text-transform: uppercase; display: flex; align-items: center; gap: 8px;
    }
    .panel-badge {
      font-family: 'JetBrains Mono', monospace; font-size: 10px;
      color: var(--cyan); background: var(--cyan-dim);
      border: 1px solid rgba(0,212,255,0.2); border-radius: 3px; padding: 2px 8px;
    }

    /* ── TABLE ── */
    .tbl-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; }
    th {
      padding: 12px 16px; text-align: left;
      font-family: 'JetBrains Mono', monospace; font-size: 10px;
      color: var(--text-dim); letter-spacing: 1px; text-transform: uppercase;
      background: var(--surface); border-bottom: 1px solid var(--border);
    }
    td {
      padding: 13px 16px;
      font-family: 'JetBrains Mono', monospace; font-size: 12px;
      color: var(--text); border-bottom: 1px solid var(--border);
      transition: background 0.1s;
    }
    tr:last-child td { border-bottom: none; }
    tr:hover td { background: rgba(0,212,255,0.03); }

    .role-badge {
      display: inline-block; border-radius: 4px; padding: 2px 10px;
      font-size: 10px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase;
    }
    .role-admin   { background: var(--cyan-dim);  color: var(--cyan);  border: 1px solid rgba(0,212,255,0.25); }
    .role-student { background: var(--green-dim); color: var(--green); border: 1px solid rgba(57,255,20,0.25); }

    /* ── ADD USER FORM ── */
    .form-row {
      display: flex; gap: 12px; padding: 16px 20px;
      background: var(--surface); border-top: 1px solid var(--border);
      flex-wrap: wrap; align-items: flex-end;
    }
    .form-field { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 130px; }
    .form-field label {
      font-family: 'JetBrains Mono', monospace; font-size: 10px;
      color: var(--text-dim); letter-spacing: 1px; text-transform: uppercase;
    }
    .form-field input, .form-field select {
      background: var(--panel); border: 1px solid var(--border);
      border-radius: 6px; padding: 9px 12px;
      font-family: 'JetBrains Mono', monospace; font-size: 12px;
      color: var(--text); outline: none; transition: border-color 0.2s;
    }
    .form-field input:focus, .form-field select:focus {
      border-color: rgba(0,212,255,0.4);
    }
    .form-field select option { background: var(--panel); }
    .btn-add {
      background: linear-gradient(135deg, #00b8e6, #0094cc);
      border: none; border-radius: 6px; padding: 10px 20px;
      font-family: 'Oxanium', sans-serif; font-size: 13px; font-weight: 700;
      color: #fff; cursor: pointer; transition: all 0.2s; white-space: nowrap;
      letter-spacing: 0.5px;
    }
    .btn-add:hover { transform: translateY(-1px); box-shadow: 0 0 20px rgba(0,212,255,0.3); }
    .btn-delete {
      background: var(--red-dim); border: 1px solid rgba(255,69,96,0.3);
      border-radius: 4px; padding: 4px 12px; color: var(--red);
      font-family: 'JetBrains Mono', monospace; font-size: 11px;
      cursor: pointer; transition: all 0.2s;
    }
    .btn-delete:hover { background: rgba(255,69,96,0.25); }

    /* ── TAB SECTIONS ── */
    .section { display: none; }
    .section.active { display: block; }

    /* ── INLINE QUERY RUNNER ── */
    .query-input {
      width: 100%; background: var(--surface); border: none;
      padding: 16px 20px; font-family: 'JetBrains Mono', monospace;
      font-size: 13px; color: #e2f0ff; outline: none; resize: vertical;
      min-height: 100px; caret-color: var(--cyan);
    }
    .query-toolbar {
      display: flex; align-items: center; justify-content: space-between;
      padding: 12px 20px; background: var(--surface);
      border-top: 1px solid var(--border);
    }
    .btn-run-query {
      background: linear-gradient(135deg, #00b8e6, #0094cc);
      border: none; border-radius: 6px; padding: 9px 20px;
      font-family: 'Oxanium', sans-serif; font-size: 13px; font-weight: 700;
      color: #fff; cursor: pointer; letter-spacing: 0.5px;
    }
    .result-info {
      font-family: 'JetBrains Mono', monospace; font-size: 11px; color: var(--text-dim);
    }

    /* ── ALERT ── */
    .alert {
      margin: 0 20px 0; padding: 10px 14px; border-radius: 6px;
      font-family: 'JetBrains Mono', monospace; font-size: 12px;
      display: none;
    }
    .alert-success {
      background: var(--green-dim); color: var(--green);
      border: 1px solid rgba(57,255,20,0.25);
    }
    .alert-error {
      background: var(--red-dim); color: var(--red);
      border: 1px solid rgba(255,69,96,0.3);
    }

    /* scrollbar */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: var(--surface); }
    ::-webkit-scrollbar-thumb { background: var(--border-hi); border-radius: 3px; }

    @keyframes fadeUp {
      from { opacity:0; transform:translateY(16px); }
      to   { opacity:1; transform:translateY(0); }
    }
    .main { animation: fadeUp 0.5s ease both; }
  </style>
</head>
<body>

<%-- ── FETCH DATA FROM DB ── --%>
<%
  int totalStudents = 0, totalAdmins = 0, totalEnrollments = 0;
  java.util.List<String[]> userList = new java.util.ArrayList<>();

  try {
    Connection conn = DatabaseConnection.getConnection();

    // Stats
    ResultSet rs1 = conn.createStatement().executeQuery(
        "SELECT Role, COUNT(*) AS cnt FROM Users GROUP BY Role");
    while (rs1.next()) {
      if (rs1.getString("Role").equals("student")) totalStudents = rs1.getInt("cnt");
      if (rs1.getString("Role").equals("admin"))   totalAdmins   = rs1.getInt("cnt");
    }
    ResultSet rs2 = conn.createStatement().executeQuery(
        "SELECT COUNT(*) AS cnt FROM Enrollments");
    if (rs2.next()) totalEnrollments = rs2.getInt("cnt");

    // Users list
    ResultSet rs3 = conn.createStatement().executeQuery(
        "SELECT UserID, Username, Role FROM Users ORDER BY Role, Username");
    while (rs3.next()) {
      userList.add(new String[]{
        rs3.getString("UserID"),
        rs3.getString("Username"),
        rs3.getString("Role")
      });
    }
    conn.close();
  } catch (Exception e) {
    e.printStackTrace();
  }

  // Handle add/delete user actions
  String actionMsg = "";
  String actionType = "";
  String action = request.getParameter("action");

  if ("add".equals(action)) {
    String newUser = request.getParameter("newUsername");
    String newPass = request.getParameter("newPassword");
    String newRole = request.getParameter("newRole");
    try {
      Connection conn = DatabaseConnection.getConnection();
      PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO Users (Username, Password, Role) VALUES (?, ?, ?)");
      ps.setString(1, newUser); ps.setString(2, newPass); ps.setString(3, newRole);
      ps.executeUpdate();
      conn.close();
      actionMsg = "✓ User '" + newUser + "' added successfully";
      actionType = "success";
    } catch (Exception e) {
      actionMsg = "✗ Failed to add user: " + e.getMessage();
      actionType = "error";
    }
  }

  if ("delete".equals(action)) {
    String delId = request.getParameter("userId");
    try {
      Connection conn = DatabaseConnection.getConnection();
      PreparedStatement ps = conn.prepareStatement("DELETE FROM Users WHERE UserID = ?");
      ps.setInt(1, Integer.parseInt(delId));
      ps.executeUpdate();
      conn.close();
      actionMsg = "✓ User deleted successfully";
      actionType = "success";
    } catch (Exception e) {
      actionMsg = "✗ Failed: " + e.getMessage();
      actionType = "error";
    }
  }
%>

<!-- TOPBAR -->
<div class="topbar">
  <div class="topbar-logo">SQL Query Evaluator</div>
  <div class="topbar-sep"></div>
  <div class="topbar-user">
    <span>Logged in as</span>
    <span class="user-badge">⚙ <%= username %></span>
  </div>
  <a href="logout" class="btn-logout">Sign Out</a>
</div>

<div class="layout">

  <!-- SIDEBAR -->
  <div class="sidebar">
    <div class="sidebar-section">Dashboard</div>
    <div class="nav-item active" onclick="showSection('overview', this)">
      <span class="nav-icon">📊</span> Overview
    </div>
    <div class="sidebar-section">Manage</div>
    <div class="nav-item" onclick="showSection('users', this)">
      <span class="nav-icon">👥</span> Users
    </div>
    <div class="nav-item" onclick="showSection('query', this)">
      <span class="nav-icon">⚡</span> Run Query
    </div>
    <div class="sidebar-section">Data</div>
    <div class="nav-item" onclick="showSection('students', this)">
      <span class="nav-icon">🎓</span> Students
    </div>
    <div class="nav-item" onclick="showSection('enrollments', this)">
      <span class="nav-icon">📋</span> Enrollments
    </div>
  </div>

  <!-- MAIN -->
  <div class="main">

    <%-- ACTION ALERT --%>
    <% if (!actionMsg.isEmpty()) { %>
    <div class="alert alert-<%= actionType %>" style="display:block; margin-bottom:20px;">
      <%= actionMsg %>
    </div>
    <% } %>

    <!-- ── OVERVIEW ── -->
    <div class="section active" id="sec-overview">
      <div class="page-title">Admin Dashboard</div>
      <div class="page-subtitle">// system overview · SQLPracticeDB</div>
      <div class="stats-row">
        <div class="stat-card">
          <div class="stat-label">Total Students</div>
          <div class="stat-value"><%= totalStudents %></div>
          <div class="stat-sub">registered users</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Admins</div>
          <div class="stat-value"><%= totalAdmins %></div>
          <div class="stat-sub">system admins</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Enrollments</div>
          <div class="stat-value"><%= totalEnrollments %></div>
          <div class="stat-sub">total enrollments</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">DB Tables</div>
          <div class="stat-value">3</div>
          <div class="stat-sub">Students · Courses · Enrollments</div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">📋 Quick Info</div>
        </div>
        <table>
          <tr><th>Property</th><th>Value</th></tr>
          <tr><td>Database</td><td>SQLPracticeDB</td></tr>
          <tr><td>Server</td><td>localhost:1433</td></tr>
          <tr><td>Connection</td><td><span style="color:var(--green)">● Connected</span></td></tr>
          <tr><td>Logged in as</td><td><%= username %></td></tr>
          <tr><td>Restricted Commands</td><td style="color:var(--orange)">DROP · ALTER · TRUNCATE · CREATE · DELETE</td></tr>
        </table>
      </div>
    </div>

    <!-- ── USERS ── -->
    <div class="section" id="sec-users">
      <div class="page-title">User Management</div>
      <div class="page-subtitle">// add · remove · manage access</div>
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">👥 All Users
            <span class="panel-badge"><%= userList.size() %> total</span>
          </div>
        </div>
        <div class="tbl-wrap">
          <table>
            <thead>
              <tr><th>#</th><th>Username</th><th>Role</th><th>Action</th></tr>
            </thead>
            <tbody>
              <% for (String[] u : userList) { %>
              <tr>
                <td><%= u[0] %></td>
                <td><%= u[1] %></td>
                <td>
                  <span class="role-badge role-<%= u[2] %>"><%= u[2] %></span>
                </td>
                <td>
                  <% if (!u[1].equals(username)) { %>
                  <form method="post" style="display:inline"
                        onsubmit="return confirm('Delete user <%= u[1] %>?')">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="userId" value="<%= u[0] %>"/>
                    <button class="btn-delete" type="submit">Delete</button>
                  </form>
                  <% } else { %>
                  <span style="color:var(--text-dim);font-size:11px;font-family:'JetBrains Mono',monospace">you</span>
                  <% } %>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
        <!-- Add User Form -->
        <form method="post">
          <input type="hidden" name="action" value="add"/>
          <div class="form-row">
            <div class="form-field">
              <label>Username</label>
              <input type="text" name="newUsername" placeholder="e.g. student2" required/>
            </div>
            <div class="form-field">
              <label>Password</label>
              <input type="password" name="newPassword" placeholder="password" required/>
            </div>
            <div class="form-field" style="max-width:130px">
              <label>Role</label>
              <select name="newRole">
                <option value="student">student</option>
                <option value="admin">admin</option>
              </select>
            </div>
            <button class="btn-add" type="submit">+ Add User</button>
          </div>
        </form>
      </div>
    </div>
<!-- ── RUN QUERY ── -->
<div class="section" id="sec-query">
  <div class="page-title">Query Runner</div>
  <div class="page-subtitle">// execute SQL directly on SQLPracticeDB</div>
  <div class="panel">
    <div class="panel-header">
      <div class="panel-title">⚡ SQL Console</div>
      <span class="panel-badge">Admin Only</span>
    </div>
    <textarea class="query-input" id="adminQueryInput"
      placeholder="-- Admin query runner&#10;SELECT * FROM Students;"></textarea>
    <div class="query-toolbar">
      <span class="result-info" id="queryStatus">Ready</span>
      <button class="btn-run-query" onclick="runAdminQuery()">▶ Execute</button>
    </div>
    <!-- Inline result area -->
    <div id="queryResultArea" style="border-top:1px solid var(--border)"></div>
  </div>
</div>
    <!-- ── STUDENTS TABLE ── -->
    <div class="section" id="sec-students">
      <div class="page-title">Students</div>
      <div class="page-subtitle">// dbo.Students</div>
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">🎓 Students Table</div>
        </div>
        <div class="tbl-wrap">
          <table>
            <thead><tr><th>StudentID</th><th>Name</th><th>Age</th><th>City</th></tr></thead>
            <tbody id="studentsBody">
              <tr><td colspan="4" style="text-align:center;color:var(--text-dim);padding:24px">
                Click "Load" to fetch data
              </td></tr>
            </tbody>
          </table>
        </div>
        <div style="padding:12px 20px;background:var(--surface);border-top:1px solid var(--border)">
          <button class="btn-add" onclick="loadTable('Students','studentsBody',['StudentID','Name','Age','City'])">
            Load Students
          </button>
        </div>
      </div>
    </div>

    <!-- ── ENROLLMENTS TABLE ── -->
    <div class="section" id="sec-enrollments">
      <div class="page-title">Enrollments</div>
      <div class="page-subtitle">// dbo.Enrollments</div>
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">📋 Enrollments Table</div>
        </div>
        <div class="tbl-wrap">
          <table>
            <thead><tr><th>EnrollmentID</th><th>StudentID</th><th>CourseID</th><th>Grade</th></tr></thead>
            <tbody id="enrollBody">
              <tr><td colspan="4" style="text-align:center;color:var(--text-dim);padding:24px">
                Click "Load" to fetch data
              </td></tr>
            </tbody>
          </table>
        </div>
        <div style="padding:12px 20px;background:var(--surface);border-top:1px solid var(--border)">
          <button class="btn-add" onclick="loadTable('Enrollments','enrollBody',['EnrollmentID','StudentID','CourseID','Grade'])">
            Load Enrollments
          </button>
        </div>
      </div>
    </div>

  </div><!-- /main -->
</div><!-- /layout -->

<script>
// Sidebar navigation
function showSection(name, el) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById('sec-' + name).classList.add('active');
  el.classList.add('active');
}

// Load table data via AdminQueryServlet
function loadTable(tableName, tbodyId, cols) {
  const tbody = document.getElementById(tbodyId);
  tbody.innerHTML = `<tr><td colspan="${cols.length}" 
    style="text-align:center;color:var(--text-dim);padding:20px">
    Loading...</td></tr>`;

  fetch('adminquery?table=' + tableName)
    .then(r => r.json())
    .then(data => {
      if (data.error) {
        tbody.innerHTML = `<tr><td colspan="${cols.length}" 
          style="color:var(--red);padding:20px">${data.error}</td></tr>`;
        return;
      }
      if (!data.rows || data.rows.length === 0) {
        tbody.innerHTML = `<tr><td colspan="${cols.length}" 
          style="text-align:center;color:var(--text-dim);padding:20px">
          No data found</td></tr>`;
        return;
      }
      tbody.innerHTML = '';
      data.rows.forEach(row => {
        const tr = document.createElement('tr');
        row.forEach(cell => {
          const td = document.createElement('td');
          td.textContent = cell === null ? 'NULL' : cell;
          if (cell === null) td.style.cssText = 'color:var(--text-dim);font-style:italic';
          tr.appendChild(td);
        });
        tbody.appendChild(tr);
      });
    })
    .catch(err => {
      tbody.innerHTML = `<tr><td colspan="${cols.length}" 
        style="color:var(--red);padding:20px">
        Failed to load: ${err}</td></tr>`;
    });
}

// Inline query runner
function runAdminQuery() {
    var queryText = document.getElementById('adminQueryInput').value.trim();
    var resultDiv = document.getElementById('queryResultArea');
    var statusEl  = document.getElementById('queryStatus');

    if (!queryText) {
        resultDiv.innerHTML = '<div style="padding:16px;color:var(--orange);'
            + 'font-family:\'JetBrains Mono\',monospace;font-size:12px">'
            + 'Please enter a query first</div>';
        return;
    }

    statusEl.textContent = 'Running...';
    resultDiv.innerHTML = '<div style="padding:20px;color:var(--text-dim);'
        + 'font-family:\'JetBrains Mono\',monospace;font-size:12px;text-align:center">'
        + 'Executing...</div>';

    // Use URLSearchParams instead of FormData — more reliable
    var params = new URLSearchParams();
    params.append('query', queryText);

    fetch('query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(function(r) { return r.text(); })
    .then(function(html) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        var table    = doc.querySelector('table');
        var emptyBox = doc.querySelector('.empty-box');
        var errorBox = doc.querySelector('.error-box');

        if (errorBox) {
            var errEl  = errorBox.querySelector('.error-msg');
            var errMsg = errEl ? errEl.textContent.trim() : 'Query blocked';
            resultDiv.innerHTML = '<div style="padding:16px;color:var(--red);'
                + 'font-family:\'JetBrains Mono\',monospace;font-size:12px;'
                + 'background:var(--red-dim);margin:16px;border-radius:6px">'
                + '&#9888; ' + errMsg + '</div>';
            statusEl.textContent = 'Blocked';

        } else if (emptyBox) {
            resultDiv.innerHTML = '<div style="padding:20px;color:var(--text-dim);'
                + 'text-align:center;font-family:\'JetBrains Mono\',monospace;font-size:12px">'
                + '&#10003; Query executed — 0 rows returned</div>';
            statusEl.textContent = 'Done — 0 rows';

        } else if (table) {
            table.style.cssText = 'width:100%;border-collapse:collapse;'
                + 'font-family:"JetBrains Mono",monospace;font-size:12px';
            table.querySelectorAll('th').forEach(function(th) {
                th.style.cssText = 'padding:10px 16px;background:var(--surface);'
                    + 'color:var(--cyan);font-size:10px;letter-spacing:1px;'
                    + 'border-bottom:1px solid var(--border);text-align:left';
            });
            table.querySelectorAll('td').forEach(function(td) {
                td.style.cssText = 'padding:10px 16px;'
                    + 'border-bottom:1px solid var(--border);color:var(--text)';
            });
            var wrap = document.createElement('div');
            wrap.style.cssText = 'overflow-x:auto;max-height:300px;overflow-y:auto';
            wrap.appendChild(table);
            resultDiv.innerHTML = '';
            resultDiv.appendChild(wrap);

            var rowCount = table.querySelectorAll('tbody tr').length;
            statusEl.textContent = 'Done — ' + rowCount + ' row' + (rowCount !== 1 ? 's' : '');

        } else {
            resultDiv.innerHTML = '<div style="padding:20px;color:var(--text-dim);'
                + 'font-family:\'JetBrains Mono\',monospace;font-size:12px">'
                + 'No results</div>';
            statusEl.textContent = 'Done';
        }
    })
    .catch(function(err) {
        resultDiv.innerHTML = '<div style="padding:16px;color:var(--red);'
            + 'font-family:\'JetBrains Mono\',monospace;font-size:12px">'
            + 'Error: ' + err + '</div>';
        statusEl.textContent = 'Error';
    });
}
</script>
</body>
</html>