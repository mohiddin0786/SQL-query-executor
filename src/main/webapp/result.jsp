<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Query Result — SQL Evaluator</title>
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
      --red-dim:   rgba(255,69,96,0.15);
    }

    html, body {
      min-height: 100%;
      background: var(--bg);
      color: var(--text);
      font-family: 'Oxanium', sans-serif;
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
      top: 30%; left: 50%;
      transform: translate(-50%, -50%);
      width: 900px; height: 600px;
      background: radial-gradient(ellipse, rgba(0,212,255,0.05) 0%, transparent 70%);
      pointer-events: none;
      z-index: 0;
    }

    .page-wrap {
      position: relative; z-index: 1;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 40px 20px 60px;
    }

    /* ── HEADER ── */
    .header {
      text-align: center;
      margin-bottom: 32px;
      animation: fadeDown 0.7s ease both;
    }

    .logo-tag {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 4px 14px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      letter-spacing: 2px;
      text-transform: uppercase;
      border-radius: 4px;
      margin-bottom: 14px;
    }

    .logo-tag.ok {
      background: var(--green-dim);
      border: 1px solid rgba(57,255,20,0.25);
      color: var(--green);
    }

    .logo-tag.err {
      background: var(--red-dim);
      border: 1px solid rgba(255,69,96,0.3);
      color: var(--red);
    }

    h1 {
      font-size: clamp(24px, 4vw, 42px);
      font-weight: 800;
      letter-spacing: -0.5px;
    }

    h1.ok {
      background: linear-gradient(135deg, #fff 0%, var(--cyan) 50%, var(--green) 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    h1.err {
      background: linear-gradient(135deg, #fff 0%, var(--red) 80%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    /* ── CARD WRAPPER ── */
    .card {
      width: 100%;
      max-width: 1100px;
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 12px;
      overflow: hidden;
      box-shadow:
        0 0 0 1px var(--border-hi),
        0 24px 80px rgba(0,0,0,0.8);
      animation: fadeUp 0.7s 0.15s ease both;
    }

    .card.ok  { box-shadow: 0 0 0 1px rgba(57,255,20,0.1),  0 24px 80px rgba(0,0,0,0.8), 0 0 60px rgba(57,255,20,0.04); }
    .card.err { box-shadow: 0 0 0 1px rgba(255,69,96,0.15), 0 24px 80px rgba(0,0,0,0.8), 0 0 60px rgba(255,69,96,0.05); }

    /* ── TITLEBAR ── */
    .titlebar {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 14px 20px;
      background: var(--surface);
      border-bottom: 1px solid var(--border);
    }

    .dots { display: flex; gap: 7px; }
    .dot  { width: 12px; height: 12px; border-radius: 50%; }
    .dot-r { background: #ff5f57; }
    .dot-y { background: #ffbd2e; }
    .dot-g { background: #28ca41; }

    .titlebar-label {
      flex: 1;
      text-align: center;
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      color: var(--text-dim);
      letter-spacing: 1px;
    }

    .status-chip {
      font-family: 'JetBrains Mono', monospace;
      font-size: 10px;
      border-radius: 3px;
      padding: 2px 8px;
      font-weight: 600;
      letter-spacing: 1px;
    }

    .status-chip.ok  { background: var(--green-dim);  border: 1px solid rgba(57,255,20,0.25);  color: var(--green); }
    .status-chip.err { background: var(--red-dim);    border: 1px solid rgba(255,69,96,0.3);   color: var(--red); }

    /* ── META BAR ── */
    .meta-bar {
      display: flex;
      align-items: center;
      gap: 24px;
      padding: 12px 24px;
      background: var(--surface);
      border-bottom: 1px solid var(--border);
      flex-wrap: wrap;
    }

    .meta-item {
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      color: var(--text-dim);
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .meta-val { font-weight: 600; }
    .meta-val.cyan  { color: var(--cyan); }
    .meta-val.green { color: var(--green); }
    .meta-val.red   { color: var(--red); }

    /* ── ERROR BOX ── */
    .error-box {
      padding: 40px 36px;
      display: flex;
      align-items: flex-start;
      gap: 20px;
    }

    .error-icon {
      font-size: 36px;
      line-height: 1;
      flex-shrink: 0;
    }

    .error-title {
      font-size: 18px;
      font-weight: 700;
      color: var(--red);
      margin-bottom: 8px;
    }

    .error-msg {
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
      color: var(--text-mid);
      line-height: 1.7;
      background: var(--red-dim);
      border: 1px solid rgba(255,69,96,0.2);
      border-left: 3px solid var(--red);
      padding: 14px 18px;
      border-radius: 6px;
      margin-top: 10px;
      word-break: break-word;
    }

    /* ── EMPTY RESULT ── */
    .empty-box {
      padding: 60px 20px;
      text-align: center;
    }

    .empty-icon { font-size: 48px; margin-bottom: 16px; }
    .empty-title {
      font-size: 18px;
      font-weight: 700;
      color: var(--text-mid);
      margin-bottom: 8px;
    }

    .empty-sub {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      color: var(--text-dim);
    }

    /* ── TABLE WRAPPER ── */
    .table-scroll {
      overflow-x: auto;
      max-height: 520px;
      overflow-y: auto;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
    }

    /* Sticky header */
    thead {
      position: sticky;
      top: 0;
      z-index: 2;
    }

    thead tr {
      background: #13132a;
      border-bottom: 2px solid rgba(0,212,255,0.3);
    }

    thead th {
      padding: 14px 20px;
      text-align: left;
      font-size: 11px;
      font-weight: 600;
      letter-spacing: 1.5px;
      text-transform: uppercase;
      color: var(--cyan);
      white-space: nowrap;
      position: relative;
    }

    thead th::after {
      content: '';
      position: absolute;
      right: 0; top: 25%; bottom: 25%;
      width: 1px;
      background: var(--border-hi);
    }

    thead th:last-child::after { display: none; }

    /* Col index label */
    .col-idx {
      display: block;
      font-size: 9px;
      color: var(--text-dim);
      font-weight: 400;
      margin-bottom: 2px;
      letter-spacing: 0.5px;
    }

    tbody tr {
      border-bottom: 1px solid var(--border);
      transition: background 0.15s;
      animation: rowIn 0.4s ease both;
    }

    tbody tr:hover {
      background: rgba(0,212,255,0.04);
    }

    tbody tr:nth-child(even) {
      background: rgba(255,255,255,0.015);
    }

    tbody tr:nth-child(even):hover {
      background: rgba(0,212,255,0.04);
    }

    tbody td {
      padding: 13px 20px;
      color: var(--text);
      vertical-align: middle;
      white-space: nowrap;
      max-width: 320px;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    /* Row number column */
    .row-num {
      color: var(--text-dim);
      font-size: 11px;
      padding: 13px 16px 13px 20px;
      width: 50px;
      text-align: right;
      border-right: 1px solid var(--border);
      user-select: none;
    }

    /* NULL values */
    .null-val {
      color: var(--text-dim);
      font-style: italic;
      font-size: 12px;
    }

    /* ── FOOTER BAR ── */
    .footer-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 14px 20px;
      background: var(--surface);
      border-top: 1px solid var(--border);
      flex-wrap: wrap;
      gap: 12px;
    }

    .row-count {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      color: var(--text-mid);
    }

    .row-count strong { color: var(--cyan); }

    /* ── BACK BUTTON ── */
    .btn-back {
      display: inline-flex;
      align-items: center;
      gap: 9px;
      background: transparent;
      border: 1px solid var(--border-hi);
      border-radius: 8px;
      padding: 11px 24px;
      font-family: 'Oxanium', sans-serif;
      font-size: 13px;
      font-weight: 600;
      letter-spacing: 1px;
      text-transform: uppercase;
      color: var(--text-mid);
      cursor: pointer;
      text-decoration: none;
      transition: all 0.2s ease;
    }

    .btn-back:hover {
      border-color: var(--cyan);
      color: var(--cyan);
      background: var(--cyan-dim);
      transform: translateX(-3px);
    }

    /* ── ANIMATIONS ── */
    @keyframes fadeDown {
      from { opacity: 0; transform: translateY(-16px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(16px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    @keyframes rowIn {
      from { opacity: 0; transform: translateX(-8px); }
      to   { opacity: 1; transform: translateX(0); }
    }

    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: var(--surface); }
    ::-webkit-scrollbar-thumb { background: var(--border-hi); border-radius: 3px; }
    ::-webkit-scrollbar-thumb:hover { background: var(--cyan-dim); }
  </style>
</head>
<body>
<%
	String error            = (String) request.getAttribute("error");
	List<List<String>> rows = (List<List<String>>) request.getAttribute("result");
	boolean hasError        = (error != null && !error.isEmpty());
	boolean hasResults      = (!hasError && rows != null && rows.size() > 1); // ✅ >1 not just !empty

	// ✅ Moved up — extract headers & data rows immediately
	List<String> headers          = hasResults ? rows.get(0) : new java.util.ArrayList<>();
	List<List<String>> dataRows   = hasResults ? rows.subList(1, rows.size()) : new java.util.ArrayList<>();
	int colCount                  = headers.size();
	int rowCount                  = dataRows.size();
%>

<div class="page-wrap">

  <!-- HEADER -->
  <div class="header">
    <div class="logo-tag <%= hasError ? "err" : "ok" %>">
      <%= hasError ? "⚠ Validation Error" : "✓ Query Executed" %>
    </div>
    <h1 class="<%= hasError ? "err" : "ok" %>">
      <%= hasError ? "Query Blocked" : (hasResults ? "Result Set" : "Query Complete") %>
    </h1>
  </div>

  <!-- CARD -->
  <div class="card <%= hasError ? "err" : "ok" %>">

    <!-- Title bar -->
    <div class="titlebar">
      <div class="dots">
        <div class="dot dot-r"></div>
        <div class="dot dot-y"></div>
        <div class="dot dot-g"></div>
      </div>
      <div class="titlebar-label">result.output <%= hasError ? "error" : rowCount + " row" + (rowCount != 1 ? "s" : "") %></div>
      <div class="status-chip <%= hasError ? "err" : "ok" %>">
        <%= hasError ? "BLOCKED" : "SUCCESS" %>
      </div>
    </div>

    <!-- Meta bar -->
    <div class="meta-bar">
      <div class="meta-item">
        Status: <span class="meta-val <%= hasError ? "red" : "green" %>">
          <%= hasError ? "REJECTED" : "OK" %>
        </span>
      </div>
      <% if (!hasError) { %>
      	<div class="meta-item">Rows: <span class="meta-val cyan"><%= rowCount %></span></div>
		<div class="meta-item">Columns: <span class="meta-val cyan"><%= colCount %></span></div>
      <% } %>
      <div class="meta-item">
        Database: <span class="meta-val cyan">SQLPracticeDB</span>
      </div>
    </div>

    <!-- ERROR STATE -->
    <% if (hasError) { %>
    <div class="error-box">
      <div class="error-icon">X</div>
      <div>
        <div class="error-title">Query Rejected by Validator</div>
        <p style="font-size:13px;color:var(--text-mid);line-height:1.7">
          Your query contains a restricted SQL command. The following operations are not permitted:
          <code style="color:var(--red);font-family:'JetBrains Mono',monospace;background:var(--red-dim);padding:1px 6px;border-radius:3px">
            DROP · ALTER · TRUNCATE · CREATE · DELETE
          </code>
        </p>
        <div class="error-msg"><%= error %></div>
      </div>
    </div>

    <!-- EMPTY RESULT -->
    <% } else if (!hasResults) { %>
    <div class="empty-box">
      <div class="empty-icon">📭</div>
      <div class="empty-title">No rows returned</div>
      <div class="empty-sub">// Query executed successfully but returned 0 results</div>
    </div>

    <!-- DATA TABLE -->
    <% } else {
	%>
	<div class="table-scroll">
	  <table>
	    <thead>
	      <tr>
	        <th style="width:50px; color:var(--text-dim); font-size:10px;">#</th>
	        <% for (int c = 0; c < colCount; c++) { %>
	        <th>
	          <span class="col-idx">col_<%= String.format("%02d", c+1) %></span>
	          <%= headers.get(c) %>   <%-- ✅ actual column name --%>
	        </th>
	        <% } %>
	      </tr>
	    </thead>
	    <tbody>
	      <% for (int r = 0; r < dataRows.size(); r++) {
	           List<String> row = dataRows.get(r);
	      %>
	      <tr style="animation-delay: <%= Math.min(r * 40, 600) %>ms">
	        <td class="row-num"><%= r + 1 %></td>
	        <% for (String cell : row) { %>
	        <td>
	          <% if (cell == null) { %>
	            <span class="null-val">NULL</span>
	          <% } else { %>
	            <%= cell %>
	          <% } %>
	        </td>
	        <% } %>
	      </tr>
	      <% } %>
	    </tbody>
	  </table>
	</div>
	<% } %>

    <!-- FOOTER BAR -->
    <div class="footer-bar">
      <div class="row-count">
        <% if (!hasError) { %>
          Returned <strong><%= rowCount %></strong> row<%= rowCount != 1 ? "s" : "" %>
          <% if (colCount > 0) { %>· <strong><%= colCount %></strong> column<%= colCount != 1 ? "s" : "" %><% } %>
        <% } else { %>
          Query was blocked before execution
        <% } %>
      </div>
      <%
    	String userRole = (String) session.getAttribute("role");
	  %>
			<a href="<%= "admin".equals(userRole) ? "admin.jsp" : "home.jsp" %>" class="btn-back">
 				 ← Back to Editor
			</a>
    </div>

  </div>
</div>

</body>
</html>
