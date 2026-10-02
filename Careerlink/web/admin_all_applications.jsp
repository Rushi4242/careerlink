<%
// Session Validation: Check if a user is logged in and holds the "Admin" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Admin")) {
    // Redirect unauthorized users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL classes for database operations and the custom DBConnection utility --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in Admin's email from the active session
String email = session.getAttribute("user").toString();
// Establish a connection to the MySQL database
Connection con = DBConnection.getConnection();
// Default fallback name for the Admin
String adminName = "Admin";

// Prepare and execute SQL query to fetch the Admin's full name based on their email
PreparedStatement userPs = con.prepareStatement("SELECT full_name FROM users WHERE email=?");
userPs.setString(1, email);
ResultSet userRs = userPs.executeQuery();
// If a matching record is found, update the adminName variable
if(userRs.next()) adminName = userRs.getString("full_name");

// Prepare SQL query joining applications, jobs, and users tables to fetch all submitted applications (newest first)
PreparedStatement ps = con.prepareStatement(
    "SELECT a.application_id, u.full_name AS candidate_name, j.job_title, j.company_name, a.apply_date, a.status " +
    "FROM applications a JOIN jobs j ON a.job_id = j.job_id JOIN users u ON a.user_id = u.user_id ORDER BY a.application_id DESC"
);
// Execute the query and store the results
ResultSet rs = ps.executeQuery();
// Get the current request URI to dynamically highlight the active link in the sidebar
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>All Applications | Admin</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and prebuilt components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for UI iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background, typography, and horizontal scroll prevention */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex container to hold the sidebar and main content side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Unified Light Blue & Purple Sidebar */
        /* Fixed-width sticky sidebar container */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        /* Purple header box at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        /* Brand title styling inside the sidebar header */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        /* Subtitle text color override */
        .sidebar-header .text-light { color: #f8f9fa !important; }
        /* Downward-pointing purple triangle indicator below the sidebar header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        /* Reset list margins and padding */
        .sidebar ul { margin: 0; padding: 0; }
        /* White divider line between each sidebar menu item */
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        /* Default state for sidebar navigation links */
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        /* Hover effect for sidebar links */
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        /* Active state styling (dark navy background with white text) for the current page */
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        /* Icon spacing and sizing inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        /* Bottom container for the logout button */
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        /* Logout button default styling */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        /* Logout button hover effect */
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }

        /* Main content area flex configuration and padding */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        /* Top navigation bar card styling */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        /* White card container for the applications table */
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
        <!-- Navigation Links: Uses ternary operator with currentPageURI to apply the 'active' class dynamically -->
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

    <!-- Main Content Section -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in Admin's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-file-earmark-text-fill text-warning me-2"></i>Platform Applications</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=adminName%></div>
        </div>

        <!-- Data Card containing the Applications Table -->
        <div class="data-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Candidate</th>
                            <th>Job Title</th>
                            <th>Company</th>
                            <th>Date Applied</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database -->
                    <tbody>
                    <% // Track if any records exist and iterate through each application row in the ResultSet %>
                    <% boolean found = false; while(rs.next()) { found = true; String status = rs.getString("status"); %>
                        <tr>
                            <!-- Display Candidate's Full Name -->
                            <td><b class="text-dark"><%=rs.getString("candidate_name")%></b></td>
                            <!-- Display Applied Job Title -->
                            <td><span class="text-primary fw-bold"><%=rs.getString("job_title")%></span></td>
                            <!-- Display Hiring Company Name -->
                            <td><i class="bi bi-building me-1 text-muted"></i><%=rs.getString("company_name")%></td>
                            <!-- Display Application Submission Date -->
                            <td><%=rs.getString("apply_date")%></td>
                            <!-- Dynamically style the status badge: Yellow for Pending, Red for Rejected, Green for Accepted/Shortlisted -->
                            <td><span class="badge rounded-pill <%=status.equals("Pending") ? "bg-warning text-dark" : (status.equals("Rejected") ? "bg-danger" : "bg-success")%> px-3"><%=status%></span></td>
                        </tr>
                    <% // If no applications were returned by the query, display a fallback empty-state message %>
                    <% } if(!found) { %><tr><td colspan="5" class="text-center text-muted py-4">No applications exist in the system yet.</td></tr><% } %>
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