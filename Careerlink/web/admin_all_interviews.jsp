<%
// Session Validation: Verify that a user is logged in and holds the "Admin" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Admin")) {
    // Redirect unauthorized users back to the login page and stop page execution
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL package for database operations and the custom DBConnection class --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in Admin's email address from the current session
String email = session.getAttribute("user").toString();
// Establish a connection to the MySQL database
Connection con = DBConnection.getConnection();
// Initialize a default fallback display name for the Admin
String adminName = "Admin";

// Prepare and execute a SQL query to retrieve the Admin's full name using their email
PreparedStatement userPs = con.prepareStatement("SELECT full_name FROM users WHERE email=?");
userPs.setString(1, email);
ResultSet userRs = userPs.executeQuery();
// If a matching user record is found, store their full name in the adminName variable
if(userRs.next()) adminName = userRs.getString("full_name");

// Prepare a SQL query joining the interview, applications, users, and jobs tables to fetch all scheduled interviews ordered by date (newest first)
PreparedStatement ps = con.prepareStatement(
    "SELECT i.interview_date, i.interview_time, i.interview_mode, i.status, u.full_name AS candidate_name, j.job_title, j.company_name " +
    "FROM interview i JOIN applications a ON i.application_id = a.application_id JOIN users u ON a.user_id = u.user_id JOIN jobs j ON a.job_id = j.job_id ORDER BY i.interview_date DESC"
);
// Execute the query and store the resulting interview records in a ResultSet
ResultSet rs = ps.executeQuery();
// Capture the current request URI to dynamically highlight the active sidebar menu link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>All Interviews | Admin</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector icons across the interface -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Set global page background color, font stack, and prevent horizontal scrolling */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Main flex wrapper to position the sidebar and content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Unified Light Blue & Purple Sidebar */
        /* Sticky full-height sidebar container with a light blue background */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        /* Purple header section at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        /* Sidebar brand heading typography */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        /* Force light text color for the portal subtitle */
        .sidebar-header .text-light { color: #f8f9fa !important; }
        /* CSS triangle caret pointing downward at the bottom-left of the purple header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        /* Reset default margin and padding on the navigation list */
        .sidebar ul { margin: 0; padding: 0; }
        /* White horizontal separator border between navigation items */
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        /* Default styling for sidebar navigation links */
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        /* Hover state background color for sidebar links */
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        /* Active state styling (dark navy background and white text) for the current page link */
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        /* Spacing and font size for icons inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        /* Bottom container pushing the logout button to the base of the sidebar */
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        /* Default styling for the outline danger logout button */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        /* Hover state styling for the logout button */
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }

        /* Main content container taking up remaining horizontal space */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        /* Top header bar styling with subtle shadow and flex alignment */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        /* Card container holding the interviews data table */
        .data-card { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        /* Table header cell styling */
        .table th { background-color: #f8f9fa; color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation -->
    <nav class="sidebar">
        <!-- Sidebar Header with Brand Title and Portal Subtitle -->
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-shield-lock-fill text-warning me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Admin Portal</div>
        </div>
        <!-- Sidebar Menu Items: Dynamically checks currentPageURI to apply the 'active' class -->
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="admin_dashboard.jsp" class="<%= currentPageURI.contains("admin_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> System Overview</a></li>
            <li><a href="manage_users.jsp" class="<%= currentPageURI.contains("manage_users.jsp") ? "active" : "" %>"><i class="bi bi-people-fill"></i> Manage Users</a></li>
            <li><a href="admin_approve_jobs.jsp" class="<%= currentPageURI.contains("admin_approve_jobs.jsp") ? "active" : "" %>"><i class="bi bi-briefcase-fill"></i> Review Jobs</a></li>
            <li><a href="admin_all_applications.jsp" class="<%= currentPageURI.contains("admin_all_applications.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-text-fill"></i> All Applications</a></li>
            <li><a href="admin_all_interviews.jsp" class="<%= currentPageURI.contains("admin_all_interviews.jsp") ? "active" : "" %>"><i class="bi bi-calendar-event-fill"></i> All Interviews</a></li>
            <li><a href="admin_reports.jsp" class="<%= currentPageURI.contains("admin_reports.jsp") ? "active" : "" %>"><i class="bi bi-bar-chart-fill"></i> View Reports</a></li>
        </ul>
        <!-- Logout Button Container -->
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Page Content -->
    <div class="content">
        <!-- Top Navigation Bar showing Page Title and Logged-in Admin's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-calendar-event-fill text-danger me-2"></i>Platform Interviews</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=adminName%></div>
        </div>

        <!-- Card Container for the Interviews Table -->
        <div class="data-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Candidate</th>
                            <th>Company & Job</th>
                            <th>Date & Time</th>
                            <th>Mode</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database ResultSet -->
                    <tbody>
                    <% // Flag to check if at least one interview exists; loop through all rows in the ResultSet %>
                    <% boolean found = false; while(rs.next()) { found = true; %>
                        <tr>
                            <!-- Display Candidate's Full Name -->
                            <td><b class="text-dark"><%=rs.getString("candidate_name")%></b></td>
                            <!-- Display Company Name and Applied Job Title -->
                            <td><i class="bi bi-building me-1 text-muted"></i><%=rs.getString("company_name")%><br><small class="text-primary fw-bold"><%=rs.getString("job_title")%></small></td>
                            <!-- Display Scheduled Interview Date and Time -->
                            <td><%=rs.getString("interview_date")%><br><small class="text-muted"><i class="bi bi-clock me-1"></i><%=rs.getString("interview_time")%></small></td>
                            <!-- Display Interview Mode (e.g., Online, Offline, Phone Call) -->
                            <td><i class="bi bi-laptop me-1 text-muted"></i><%=rs.getString("interview_mode")%></td>
                            <!-- Display Interview Status inside a green pill badge -->
                            <td><span class="badge bg-success rounded-pill px-3"><%=rs.getString("status")%></span></td>
                        </tr>
                    <% // If no interview records were found in the database, display an empty-state message row %>
                    <% } if(!found) { %><tr><td colspan="5" class="text-center text-muted py-4">No interviews have been scheduled yet.</td></tr><% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>