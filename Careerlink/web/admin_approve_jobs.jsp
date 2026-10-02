<%
// Session Validation: Verify that a user is logged in and holds the "Admin" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Admin")) {
    // Redirect unauthorized users back to the login page and stop execution
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL classes for database connectivity and the custom DBConnection utility --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in Admin's email from the current session
String email=session.getAttribute("user").toString();
// Establish a connection to the MySQL database
Connection con=DBConnection.getConnection();
// Initialize a default fallback display name for the Admin
String adminName="Admin";

// Prepare and execute a SQL query to fetch the Admin's full name using their email
PreparedStatement userPs=con.prepareStatement("SELECT full_name FROM users WHERE email=?");
userPs.setString(1,email);
ResultSet userRs=userPs.executeQuery();
// If a matching record is found, update the adminName variable
if(userRs.next()) adminName=userRs.getString("full_name");

// Initialize feedback message and retrieve action ('approve'/'reject') and job ID parameters from the URL
String message = "";
String action = request.getParameter("action");
String jobIdStr = request.getParameter("jobid");

// Process Job Approval or Rejection if both action and jobid parameters are present in the request
if (action != null && jobIdStr != null) {
    // Convert the job ID string parameter to an integer
    int jobId = Integer.parseInt(jobIdStr);
    // Determine the new status string based on whether the action is "approve" or "reject"
    String newStatus = action.equals("approve") ? "Approved" : "Rejected";
    // Prepare and execute an UPDATE query to change the job's approval_status in the database
    PreparedStatement psUpdate = con.prepareStatement("UPDATE jobs SET approval_status=? WHERE job_id=?");
    psUpdate.setString(1, newStatus); psUpdate.setInt(2, jobId);
    // Display a success alert banner if the database update succeeds
    if(psUpdate.executeUpdate() > 0) message = "<div class='alert alert-success fw-bold'>Job " + newStatus + " successfully.</div>";
}

// Prepare a SQL query joining the jobs and users tables to fetch all pending job postings (newest first)
PreparedStatement ps = con.prepareStatement(
    "SELECT j.job_id, j.job_title, j.company_name, j.location, j.experience, u.full_name AS hr_name " +
    "FROM jobs j JOIN users u ON j.posted_by = u.user_id " +
    "WHERE j.approval_status = 'Pending' ORDER BY j.job_id DESC"
);
// Execute the query and store the pending jobs in a ResultSet
ResultSet rs = ps.executeQuery();
// Capture the current request URI to dynamically highlight the active link in the sidebar
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Review Jobs | Admin</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, font stack, and horizontal scroll prevention */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex wrapper to align the sidebar and main content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Unified Light Blue & Purple Sidebar */
        /* Fixed-width sticky sidebar container with a light blue background */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        /* Purple header box at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        /* Brand title styling inside the sidebar header */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        /* Force light text color for the portal subtitle */
        .sidebar-header .text-light { color: #f8f9fa !important; }
        /* Downward-pointing purple triangle caret below the sidebar header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        /* Reset default list margins and padding */
        .sidebar ul { margin: 0; padding: 0; }
        /* White horizontal divider line between sidebar menu items */
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        /* Default styling for sidebar navigation links */
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        /* Hover effect for sidebar links */
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        /* Active state styling (dark navy background with white text) for the current page */
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        /* Icon spacing and size inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        /* Bottom container pushing the logout button to the base of the sidebar */
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        /* Default styling for the outline danger logout button */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        /* Hover effect for the logout button */
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }

        /* Main content container expanding to fill remaining space */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        /* Top navigation bar card styling */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        /* White card container for the pending jobs table */
        .data-card { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        /* Table header typography and background styling */
        .table th { background-color: #f8f9fa; color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation Menu -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-shield-lock-fill text-warning me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Admin Portal</div>
        </div>
        <!-- Navigation Links: Uses currentPageURI to dynamically highlight the active page -->
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="admin_dashboard.jsp" class="<%= currentPageURI.contains("admin_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> System Overview</a></li>
            <li><a href="manage_users.jsp" class="<%= currentPageURI.contains("manage_users.jsp") ? "active" : "" %>"><i class="bi bi-people-fill"></i> Manage Users</a></li>
            <li><a href="admin_approve_jobs.jsp" class="<%= currentPageURI.contains("admin_approve_jobs.jsp") ? "active" : "" %>"><i class="bi bi-briefcase-fill"></i> Review Jobs</a></li>
            <li><a href="admin_all_applications.jsp" class="<%= currentPageURI.contains("admin_all_applications.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-text-fill"></i> All Applications</a></li>
            <li><a href="admin_all_interviews.jsp" class="<%= currentPageURI.contains("admin_all_interviews.jsp") ? "active" : "" %>"><i class="bi bi-calendar-event-fill"></i> All Interviews</a></li>
            <li><a href="admin_reports.jsp" class="<%= currentPageURI.contains("admin_reports.jsp") ? "active" : "" %>"><i class="bi bi-bar-chart-fill"></i> View Reports</a></li>
        </ul>
        <!-- Logout Button -->
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in Admin's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-briefcase-fill text-success me-2"></i>Review Pending Jobs</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=adminName%></div>
        </div>

        <!-- Data Card containing the Pending Jobs Table -->
        <div class="data-card">
            <!-- Output status alert message if a job was just approved or rejected -->
            <%=message%>
            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Job Title</th>
                            <th>Company</th>
                            <th>Location / Exp</th>
                            <th>Posted By (HR)</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database ResultSet -->
                    <tbody>
                    <% // Track if any pending jobs exist and iterate through each row in the ResultSet %>
                    <% boolean found = false; while(rs.next()) { found = true; %>
                        <tr>
                            <!-- Display Job Title -->
                            <td><b class="text-primary"><%=rs.getString("job_title")%></b></td>
                            <!-- Display Company Name -->
                            <td><i class="bi bi-building me-1 text-muted"></i><%=rs.getString("company_name")%></td>
                            <!-- Display Job Location and Required Experience -->
                            <td><%=rs.getString("location")%> <br> <small class="text-muted">Exp: <%=rs.getString("experience")%></small></td>
                            <!-- Display the Name of the HR User who posted the job -->
                            <td><span class="badge bg-light text-dark border"><i class="bi bi-person me-1"></i><%=rs.getString("hr_name")%></span></td>
                            <!-- Action Buttons: Pass 'approve' or 'reject' along with the job_id as URL query parameters -->
                            <td>
                                <a href="admin_approve_jobs.jsp?action=approve&jobid=<%=rs.getInt("job_id")%>" class="btn btn-sm btn-success rounded-pill px-3 fw-bold me-1">Approve</a>
                                <a href="admin_approve_jobs.jsp?action=reject&jobid=<%=rs.getInt("job_id")%>" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">Reject</a>
                            </td>
                        </tr>
                    <% // If no pending jobs were found, render an empty-state message row %>
                    <% } if(!found) { %>
                        <tr><td colspan="5" class="text-center text-muted py-4"><i class="bi bi-check-circle fs-3 d-block mb-2 text-success"></i>No pending jobs to review.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>a
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>