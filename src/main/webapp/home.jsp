<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.html");
        return;
    }
    String loggedUser = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQL Query Evaluator</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Oxanium:wght@300;400;600;700;800&family=JetBrains+Mono:wght@300;400;500;600&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg:        #070710;
      --surface:   #0d0d1a;
      --panel:     #10101f;
      --border:    #1c1c35;
      --border-hi: #2a2a50;
      --cyan:      #00d4ff;
      --cyan-dim:  rgba(0,212,255,0.15);
      --cyan-glow: rgba(0,212,255,0.35);
      --green:     #39ff14;
      --green-dim: rgba(57,255,20,0.12);
      --text:      #c8d6e8;
      --text-dim:  #5a6a80;
      --text-mid:  #8899aa;
      --red:       #ff4560;
    }

    html, body {
      height: 100%;
      background: var(--bg);
      color: var(--text);
      font-family: 'Oxanium', sans-serif;
      overflow-x: hidden;
    }

    body::before {
      content: '';
      position: fixed; inset: 0;
      background-image:
        linear-gradient(rgba(0,212,255,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(0,212,255,0.03) 1px, transparent 1px);
      background-size: 40px 40px;
      pointer-events: none;
      z-index: 0;
    }

    body::after {
      content: '';
      position: fixed;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 800px; height: 600px;
      background: radial-gradient(ellipse, rgba(0,212,255,0.06) 0%, transparent 70%);
      pointer-events: none;
      z-index: 0;
    }

    .page-wrap {
      position: relative; z-index: 1;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 40px 20px;
    }

    .header {
      text-align: center;
      margin-bottom: 40px;
      animation: fadeDown 0.8s ease both;
    }

    .logo-tag {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: var(--cyan-dim);
      border: 1px solid rgba(0,212,255,0.25);
      border-radius: 4px;
      padding: 4px 14px;
      font-size: 11px;
      font-family: 'JetBrains Mono', monospace;
      color: var(--cyan);
      letter-spacing: 2px;
      text-transform: uppercase;
      margin-bottom: 20px;
    }

    .logo-tag::before {
      content: '◆';
      font-size: 8px;
    }

    h1 {
      font-size: clamp(28px, 5vw, 52px);
      font-weight: 800;
      letter-spacing: -1px;
      line-height: 1.1;
      background: linear-gradient(135deg, #fff 0%, var(--cyan) 60%, var(--green) 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .subtitle {
      margin-top: 10px;
      font-size: 13px;
      color: var(--text-dim);
      font-family: 'JetBrains Mono', monospace;
      letter-spacing: 1px;
    }

    .card {
      width: 100%;
      max-width: 820px;
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 12px;
      overflow: hidden;
      box-shadow:
        0 0 0 1px var(--border-hi),
        0 24px 80px rgba(0,0,0,0.8),
        0 0 60px rgba(0,212,255,0.05);
      animation: fadeUp 0.8s 0.2s ease both;
    }

    .titlebar {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 14px 20px;
      background: var(--surface);
      border-bottom: 1px solid var(--border);
    }

    .dots { display: flex; gap: 7px; }
    .dot { width: 12px; height: 12px; border-radius: 50%; }
    .dot-r { background: #ff5f57; box-shadow: 0 0 6px #ff5f5780; }
    .dot-y { background: #ffbd2e; box-shadow: 0 0 6px #ffbd2e80; }
    .dot-g { background: #28ca41; box-shadow: 0 0 6px #28ca4180; }

    .titlebar-label {
      flex: 1;
      text-align: center;
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      color: var(--text-dim);
      letter-spacing: 1px;
    }

    .titlebar-badge {
      font-family: 'JetBrains Mono', monospace;
      font-size: 10px;
      color: var(--cyan);
      background: var(--cyan-dim);
      border: 1px solid rgba(0,212,255,0.2);
      border-radius: 3px;
      padding: 2px 8px;
    }

    .editor-area {
      display: flex;
      border-bottom: 1px solid var(--border);
    }

    .line-numbers {
      display: flex;
      flex-direction: column;
      padding: 20px 0;
      min-width: 52px;
      background: var(--surface);
      border-right: 1px solid var(--border);
      align-items: center;
      gap: 0;
      user-select: none;
    }

    .ln {
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
      line-height: 24px;
      color: var(--border-hi);
      padding: 0 14px;
      transition: color 0.2s;
    }

    .textarea-wrap { flex: 1; position: relative; }

    textarea {
      width: 100%;
      height: 220px;
      padding: 20px;
      background: transparent;
      border: none;
      outline: none;
      resize: none;
      font-family: 'JetBrains Mono', monospace;
      font-size: 14px;
      line-height: 24px;
      color: #e2f0ff;
      caret-color: var(--cyan);
      letter-spacing: 0.3px;
    }

    textarea::placeholder { color: var(--text-dim); font-style: italic; }

    textarea:focus ~ .focus-line { opacity: 1; transform: scaleX(1); }

    .focus-line {
      position: absolute;
      bottom: 0; left: 0; right: 0;
      height: 1px;
      background: linear-gradient(90deg, transparent, var(--cyan), transparent);
      opacity: 0;
      transform: scaleX(0);
      transition: all 0.4s ease;
    }

    .hint-bar {
      display: flex;
      gap: 16px;
      padding: 10px 20px;
      background: var(--surface);
      border-top: 1px solid var(--border);
      flex-wrap: wrap;
    }

    .hint {
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      display: flex;
      align-items: center;
      gap: 6px;
      color: var(--text-dim);
    }

    .hint-dot { width: 7px; height: 7px; border-radius: 50%; }
    .kw  { background: #ff79c6; }
    .fn  { background: #50fa7b; }
    .tbl { background: #8be9fd; }
    .op  { background: #ffb86c; }

    .toolbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px 20px;
      background: var(--panel);
      flex-wrap: wrap;
      gap: 12px;
    }

    .toolbar-left { display: flex; align-items: center; gap: 16px; }

    .stat {
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: var(--text-dim);
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .stat-val { color: var(--cyan); font-weight: 600; }

    .btn-run {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      background: linear-gradient(135deg, #00b8e6, #0094cc);
      border: none;
      border-radius: 8px;
      padding: 13px 32px;
      font-family: 'Oxanium', sans-serif;
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 1.5px;
      text-transform: uppercase;
      color: #fff;
      cursor: pointer;
      position: relative;
      overflow: hidden;
      transition: all 0.25s ease;
      box-shadow: 0 0 20px rgba(0,180,230,0.3), 0 4px 15px rgba(0,0,0,0.4);
    }

    .btn-run::before {
      content: '';
      position: absolute; inset: 0;
      background: linear-gradient(135deg, rgba(255,255,255,0.15), transparent);
      opacity: 0;
      transition: opacity 0.25s;
    }

    .btn-run:hover { transform: translateY(-2px); box-shadow: 0 0 35px rgba(0,212,255,0.5), 0 8px 25px rgba(0,0,0,0.5); }
    .btn-run:hover::before { opacity: 1; }
    .btn-run:active { transform: translateY(0); box-shadow: 0 0 15px rgba(0,212,255,0.3); }

    .run-icon { width: 16px; height: 16px; fill: none; stroke: white; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
    .btn-run.loading .run-icon { animation: spin 1s linear infinite; }

    .main-layout {
      display: flex;
      gap: 20px;
      width: 100%;
      max-width: 1300px;
      align-items: flex-start;
      animation: fadeUp 0.8s 0.2s ease both;
    }

    .editor-col { flex: 1; min-width: 0; }
    .editor-col .card { max-width: 100%; animation: none; }

    .schema-panel {
      width: 280px;
      flex-shrink: 0;
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 0 0 1px var(--border-hi), 0 24px 80px rgba(0,0,0,0.8);
      animation: fadeUp 0.8s 0.35s ease both;
    }

    .schema-titlebar {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 14px 16px;
      background: var(--surface);
      border-bottom: 1px solid var(--border);
    }

    .schema-icon {
      width: 28px; height: 28px;
      border-radius: 6px;
      background: var(--cyan-dim);
      border: 1px solid rgba(0,212,255,0.2);
      display: flex; align-items: center; justify-content: center;
      font-size: 13px;
      flex-shrink: 0;
    }

    .schema-title {
      flex: 1;
      font-size: 12px;
      font-weight: 700;
      letter-spacing: 1px;
      text-transform: uppercase;
      color: var(--text);
    }

    .schema-db-badge {
      font-family: 'JetBrains Mono', monospace;
      font-size: 9px;
      color: var(--cyan);
      background: var(--cyan-dim);
      border: 1px solid rgba(0,212,255,0.2);
      border-radius: 3px;
      padding: 2px 6px;
      letter-spacing: 1px;
    }

    .schema-body { padding: 10px 0; max-height: 500px; overflow-y: auto; }

    .tbl-block { border-bottom: 1px solid var(--border); }
    .tbl-block:last-child { border-bottom: none; }

    .tbl-header {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 16px;
      cursor: pointer;
      transition: background 0.15s;
      user-select: none;
    }

    .tbl-header:hover { background: rgba(0,212,255,0.04); }

    .tbl-chevron {
      font-size: 9px;
      color: var(--text-dim);
      transition: transform 0.25s ease;
      flex-shrink: 0;
    }

    .tbl-block.open .tbl-chevron { transform: rotate(90deg); }
    .tbl-icon { font-size: 14px; flex-shrink: 0; }

    .tbl-name {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      font-weight: 600;
      color: var(--cyan);
      flex: 1;
    }

    .tbl-schema {
      font-family: 'JetBrains Mono', monospace;
      font-size: 9px;
      color: var(--text-dim);
      margin-bottom: 1px;
    }

    .tbl-col-count {
      font-family: 'JetBrains Mono', monospace;
      font-size: 9px;
      color: var(--text-dim);
      background: var(--border);
      border-radius: 10px;
      padding: 1px 7px;
    }

    .col-list { display: none; flex-direction: column; padding-bottom: 6px; }
    .tbl-block.open .col-list { display: flex; }

    .col-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 6px 16px 6px 36px;
      cursor: pointer;
      transition: background 0.12s;
      position: relative;
    }

    .col-row:hover { background: rgba(0,212,255,0.05); }
    .col-row:hover .col-name { color: var(--cyan); }

    .col-row::before {
      content: '';
      position: absolute;
      left: 24px; top: 50%;
      width: 8px; height: 1px;
      background: var(--border-hi);
    }

    .col-badge {
      font-family: 'JetBrains Mono', monospace;
      font-size: 8px;
      font-weight: 700;
      border-radius: 3px;
      padding: 1px 5px;
      letter-spacing: 0.5px;
      flex-shrink: 0;
    }

    .badge-pk { background: rgba(255,215,0,0.15); color: #ffd700; border: 1px solid rgba(255,215,0,0.3); }
    .badge-fk { background: rgba(255,120,50,0.15); color: #ff9060; border: 1px solid rgba(255,120,50,0.3); }

    .col-name {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      color: var(--text);
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      transition: color 0.15s;
    }

    .col-type { font-family: 'JetBrains Mono', monospace; font-size: 10px; color: var(--text-dim); position: relative; flex-shrink: 0; }

    .col-row .col-type .insert-hint {
      display: none;
      position: absolute;
      right: 0; top: 50%;
      transform: translateY(-50%);
      color: var(--cyan);
      white-space: nowrap;
      font-size: 10px;
    }

    .col-row:hover .col-type .type-label { visibility: hidden; }
    .col-row:hover .col-type .insert-hint { display: block; }

    .schema-footer {
      padding: 10px 16px;
      border-top: 1px solid var(--border);
      background: var(--surface);
      font-family: 'JetBrains Mono', monospace;
      font-size: 10px;
      color: var(--text-dim);
      display: flex;
      justify-content: space-between;
    }

    .footer-note {
      margin-top: 24px;
      display: flex;
      gap: 20px;
      flex-wrap: wrap;
      justify-content: center;
      animation: fadeUp 0.8s 0.5s ease both;
    }

    .fn-badge {
      display: flex;
      align-items: center;
      gap: 7px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: var(--text-dim);
      padding: 6px 14px;
      border: 1px solid var(--border);
      border-radius: 20px;
      background: var(--surface);
    }

    .fn-icon { font-size: 13px; }

    @media (max-width: 900px) {
      .main-layout { flex-direction: column; }
      .schema-panel { width: 100%; }
      .schema-body  { max-height: 280px; }
    }

    @keyframes fadeDown { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes fadeUp   { from { opacity: 0; transform: translateY(20px);  } to { opacity: 1; transform: translateY(0); } }
    @keyframes spin     { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
    @keyframes blink    { 0%, 100% { opacity: 1; } 50% { opacity: 0; } }

    .card:focus-within {
      border-color: rgba(0,212,255,0.3);
      box-shadow: 0 0 0 1px rgba(0,212,255,0.15), 0 24px 80px rgba(0,0,0,0.8), 0 0 80px rgba(0,212,255,0.1);
      transition: all 0.4s ease;
    }

    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: var(--surface); }
    ::-webkit-scrollbar-thumb { background: var(--border-hi); border-radius: 3px; }
    ::-webkit-scrollbar-thumb:hover { background: var(--cyan-dim); }
  </style>
</head>
<body>
  <div class="page-wrap">

    <!-- USER TOPBAR -->
    <div style="position:fixed;top:16px;right:24px;z-index:99;display:flex;align-items:center;gap:12px;">
      <span style="font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--text-dim)">
        👤 <%= loggedUser %>
      </span>
      <a href="logout" style="
        background:rgba(255,69,96,0.15);
        border:1px solid rgba(255,69,96,0.3);
        border-radius:6px;padding:6px 14px;color:#ff4560;
        font-family:'Oxanium',sans-serif;font-size:12px;font-weight:600;
        text-decoration:none;letter-spacing:0.5px;">
        Sign Out
      </a>
    </div>

    <!-- HEADER -->
    <div class="header">
      <div class="logo-tag">SQL Query Evaluator</div>
      <h1>Query the Database</h1>
      <p class="subtitle">// connected · SQLPracticeDB</p>
    </div>

    <!-- TWO COLUMN LAYOUT -->
    <div class="main-layout">

      <!-- LEFT: SCHEMA PANEL -->
      <div class="schema-panel">
        <div class="schema-titlebar">
          <div class="schema-icon">🗄️</div>
          <div>
            <div class="tbl-schema">SQLPracticeDB</div>
            <div class="schema-title">Schema Explorer</div>
          </div>
          <div class="schema-db-badge">dbo</div>
        </div>

        <div class="schema-body">

          <!-- dbo.Students -->
          <div class="tbl-block open">
            <div class="tbl-header" onclick="toggleTable(this)">
              <span class="tbl-chevron">▶</span>
              <span class="tbl-icon">📋</span>
              <div style="flex:1">
                <div class="tbl-schema">dbo</div>
                <div class="tbl-name">Students</div>
              </div>
              <span class="tbl-col-count">4 cols</span>
            </div>
            <div class="col-list">
              <div class="col-row" onclick="insertCol('StudentID')">
                <span class="col-badge badge-pk">PK</span>
                <span class="col-name">StudentID</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('Name')">
                <span class="col-name">Name</span>
                <span class="col-type">
                  <span class="type-label">nvarchar(50)</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('Age')">
                <span class="col-name">Age</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('City')">
                <span class="col-name">City</span>
                <span class="col-type">
                  <span class="type-label">nvarchar(50)</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
            </div>
          </div>

          <!-- dbo.Courses -->
          <div class="tbl-block">
            <div class="tbl-header" onclick="toggleTable(this)">
              <span class="tbl-chevron">▶</span>
              <span class="tbl-icon">📋</span>
              <div style="flex:1">
                <div class="tbl-schema">dbo</div>
                <div class="tbl-name">Courses</div>
              </div>
              <span class="tbl-col-count">3 cols</span>
            </div>
            <div class="col-list">
              <div class="col-row" onclick="insertCol('CourseID')">
                <span class="col-badge badge-pk">PK</span>
                <span class="col-name">CourseID</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('CourseName')">
                <span class="col-name">CourseName</span>
                <span class="col-type">
                  <span class="type-label">nvarchar(50)</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('Credits')">
                <span class="col-name">Credits</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
            </div>
          </div>

          <!-- dbo.Enrollments -->
          <div class="tbl-block">
            <div class="tbl-header" onclick="toggleTable(this)">
              <span class="tbl-chevron">▶</span>
              <span class="tbl-icon">📋</span>
              <div style="flex:1">
                <div class="tbl-schema">dbo</div>
                <div class="tbl-name">Enrollments</div>
              </div>
              <span class="tbl-col-count">4 cols</span>
            </div>
            <div class="col-list">
              <div class="col-row" onclick="insertCol('EnrollmentID')">
                <span class="col-badge badge-pk">PK</span>
                <span class="col-name">EnrollmentID</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('StudentID')">
                <span class="col-badge badge-fk">FK</span>
                <span class="col-name">StudentID</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('CourseID')">
                <span class="col-badge badge-fk">FK</span>
                <span class="col-name">CourseID</span>
                <span class="col-type">
                  <span class="type-label">int</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
              <div class="col-row" onclick="insertCol('Grade')">
                <span class="col-name">Grade</span>
                <span class="col-type">
                  <span class="type-label">char(2)</span>
                  <span class="insert-hint">click to insert</span>
                </span>
              </div>
            </div>
          </div>

        </div><!-- /schema-body -->

        <div class="schema-footer">
          <span>3 tables</span>
          <span>11 columns</span>
        </div>
      </div><!-- /schema-panel -->

      <!-- RIGHT: EDITOR -->
      <div class="editor-col">
        <form action="query" method="post" id="queryForm">
          <div class="card">

            <!-- Titlebar -->
            <div class="titlebar">
              <div class="dots">
                <div class="dot dot-r"></div>
                <div class="dot dot-y"></div>
                <div class="dot dot-g"></div>
              </div>
              <div class="titlebar-label">query.sql — editor</div>
              <div class="titlebar-badge">T-SQL</div>
            </div>

            <!-- Editor -->
            <div class="editor-area">
              <div class="line-numbers" id="lineNums">
                <div class="ln">1</div>
                <div class="ln">2</div>
                <div class="ln">3</div>
                <div class="ln">4</div>
                <div class="ln">5</div>
                <div class="ln">6</div>
                <div class="ln">7</div>
                <div class="ln">8</div>
                <div class="ln">9</div>
              </div>
              <div class="textarea-wrap">
                <textarea
                  name="query"
                  id="queryInput"
                  placeholder="-- Write your SQL query here&#10;SELECT * FROM your_table&#10;WHERE condition = 'value';"
                  spellcheck="false"
                  autocorrect="off"
                  autocomplete="off"
                ></textarea>
                <div class="focus-line"></div>
              </div>
            </div>

            <!-- Syntax hints -->
            <div class="hint-bar">
              <span class="hint"><span class="hint-dot kw"></span>Keywords</span>
              <span class="hint"><span class="hint-dot fn"></span>Functions</span>
              <span class="hint"><span class="hint-dot tbl"></span>Identifiers</span>
              <span class="hint"><span class="hint-dot op"></span>Operators</span>
              <span class="hint" style="margin-left:auto;color:var(--text-dim)">
                <kbd style="background:var(--border);padding:2px 6px;border-radius:3px;font-size:10px">Ctrl+Enter</kbd> to run
              </span>
            </div>

            <!-- Toolbar -->
            <div class="toolbar">
              <div class="toolbar-left">
                <div class="stat">Lines: <span class="stat-val" id="lineCount">1</span></div>
                <div class="stat">Chars: <span class="stat-val" id="charCount">0</span></div>
                <div class="stat">
                  <span style="width:8px;height:8px;border-radius:50%;background:var(--green);box-shadow:0 0 6px var(--green);display:inline-block"></span>
                  Ready
                </div>
              </div>
              <button class="btn-run" type="submit" id="runBtn">
                <svg class="run-icon" viewBox="0 0 24 24">
                  <polygon points="5,3 19,12 5,21" fill="white" stroke="none"/>
                </svg>
                Execute Query
              </button>
            </div>

          </div>
        </form>
      </div><!-- /editor-col -->

    </div><!-- /main-layout -->

    <!-- FOOTER BADGES -->
    <div class="footer-note">
      <div class="fn-badge"><span class="fn-icon">🛡️</span> DROP · ALTER · TRUNCATE · CREATE · DELETE blocked</div>
      <div class="fn-badge"><span class="fn-icon">⚡</span> MS SQL Server · JDBC</div>
      <div class="fn-badge"><span class="fn-icon">🔒</span> TLS encrypted connection</div>
    </div>

  </div>

  <script>
    const ta        = document.getElementById('queryInput');
    const lineNums  = document.getElementById('lineNums');
    const lineCount = document.getElementById('lineCount');
    const charCount = document.getElementById('charCount');
    const form      = document.getElementById('queryForm');
    const runBtn    = document.getElementById('runBtn');

    function updateLineNumbers() {
      const lines = ta.value.split('\n').length;
      lineCount.textContent = lines;
      charCount.textContent = ta.value.length;
      lineNums.innerHTML = '';
      const total = Math.max(lines, 9);
      for (let i = 1; i <= total; i++) {
        const d = document.createElement('div');
        d.className = 'ln';
        d.textContent = i;
        lineNums.appendChild(d);
      }
    }

    ta.addEventListener('input', updateLineNumbers);

    ta.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        e.preventDefault();
        const start = ta.selectionStart;
        const end   = ta.selectionEnd;
        ta.value = ta.value.substring(0, start) + '  ' + ta.value.substring(end);
        ta.selectionStart = ta.selectionEnd = start + 2;
        updateLineNumbers();
      }
      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        form.submit();
      }
    });

    form.addEventListener('submit', () => {
      runBtn.classList.add('loading');
      runBtn.innerHTML = `
        <svg class="run-icon" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5">
          <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>
        </svg>
        Running...
      `;
    });

    window.addEventListener('pageshow', (e) => {
      if (e.persisted) {
        runBtn.classList.remove('loading');
        runBtn.innerHTML = `
          <svg class="run-icon" viewBox="0 0 24 24">
            <polygon points="5,3 19,12 5,21" fill="white" stroke="none"/>
          </svg>
          Execute Query
        `;
      }
    });

    function toggleTable(header) {
      header.closest('.tbl-block').classList.toggle('open');
    }

    function insertCol(name) {
      const start = ta.selectionStart;
      const end   = ta.selectionEnd;
      ta.value = ta.value.substring(0, start) + name + ta.value.substring(end);
      ta.selectionStart = ta.selectionEnd = start + name.length;
      ta.focus();
      updateLineNumbers();
    }

    updateLineNumbers();
  </script>
</body>
</html>