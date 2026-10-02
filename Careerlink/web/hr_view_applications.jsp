<%
// Session Validation: Verify that a user is logged in and holds the "HR" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("HR")) {
    // Redirect unauthorized or unauthenticated users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL package for database operations and the custom DBConnection utility class --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in HR user's email from the session and establish a database connection
String email = session.getAttribute("user").toString();
Connection con = DBConnection.getConnection();
// Initialize default fallback values for the HR user's ID and display name
int hrId = 0; String hrName = "HR";

// Query the users table to fetch the logged-in HR manager's unique user_id and full_name
PreparedStatement hrPs = con.prepareStatement("SELECT user_id, full_name FROM users WHERE email=?");
hrPs.setString(1, email);
ResultSet hrRs = hrPs.executeQuery();
if(hrRs.next()) { hrId = hrRs.getInt("user_id"); hrName = hrRs.getString("full_name"); }

// Fetch all candidate applications submitted for jobs posted specifically by this HR user (newest first)
ResultSet rs = null;
if(hrId > 0) {
    PreparedStatement appPs = con.prepareStatement(
        "SELECT a.application_id, u.full_name AS candidate_name, j.job_title, u.skills, u.experience, a.apply_date, a.status " +
        "FROM applications a JOIN jobs j ON a.job_id = j.job_id JOIN users u ON a.user_id = u.user_id " +
        "WHERE j.posted_by = ? ORDER BY a.application_id DESC"
    );
    appPs.setInt(1, hrId);
    rs = appPs.executeQuery();
}

// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Applications | HR Portal</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex container to align the sidebar and main content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Light Blue & Purple Sidebar Styles */
        /* Fixed-width sticky vertical sidebar container */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        /* Purple header box at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        /* Sidebar brand heading and subtitle text styling */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        .sidebar-header .text-light { color: #f8f9fa !important; }
        /* Downward-pointing purple triangle caret positioned below the sidebar header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        
        /* Reset list margins/padding and add a white bottom border between menu items */
        .sidebar ul { margin: 0; padding: 0; }
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        /* Default styling for sidebar navigation links */
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        /* Hover state background color for sidebar links */
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        /* Active state styling (dark navy background with white text) for the current page */
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        /* Icon spacing and sizing inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }

        /* Bottom container pushing the logout button to the base of the sidebar */
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        /* Default and hover styles for the outline danger logout button */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }

        /* Main content container expanding to fill remaining horizontal space */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        /* Top navigation bar card styling */
        .top-navbar { background: #fff; padding: 20px 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-radius: 8px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        /* White card container holding the candidate applications table */
        .data-card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        /* Table header cell typography, background color, and border styling */
        .table th { background-color: #f8f9fa; color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; border-top: none; border-bottom: 1px solid #e5e7eb;}
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation Menu -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-buildings-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">HR Portal</div>
        </div>
        <!-- Navigation Links: Dynamically checks currentPageURI to highlight the active page -->
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="hr_dashboard.jsp" class="<%= currentPageURI.contains("hr_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> HR Dashboard</a></li>
            <li><a href="post_job.jsp" class="<%= currentPageURI.contains("post_job.jsp") ? "active" : "" %>"><i class="bi bi-plus-circle-fill"></i> Post New Job</a></li>
            <li><a href="hr_manage_jobs.jsp" class="<%= currentPageURI.contains("hr_manage_jobs.jsp") ? "active" : "" %>"><i class="bi bi-gear-fill"></i> Manage Jobs</a></li>
            <li><a href="hr_view_applications.jsp" class="<%= currentPageURI.contains("hr_view_applications.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-person-fill"></i> Applications</a></li>
        </ul>
        <!-- Logout Button -->
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in HR Manager's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Candidate Applications</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=hrName%></div>
        </div>

        <!-- Data Card containing the Candidate Applications Table -->
        <div class="data-card">
            <div class="table-responsive">
                <table class="table align-middle">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Candidate Name</th>
                            <th>Applied Role</th>
                            <th>Candidate Skills & Exp</th>
                            <th>Applied On</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database ResultSet -->
                    <tbody>
                    <% // Verify ResultSet is not null, track if any application rows exist, and iterate through each record %>
                    <% if(rs != null) { boolean found = false; while(rs.next()) { found = true; String status = rs.getString("status"); %>
                        <tr>
                            <!-- Display Candidate's Full Name -->
                            <td><b class="text-dark"><%=rs.getString("candidate_name")%></b></td>
                            <!-- Display Job Title the Candidate Applied For -->
                            <td><span class="text-primary fw-bold"><%=rs.getString("job_title")%></span></td>
                            <!-- Display Candidate's Experience and Technical Skills (with fallback text if null) -->
                            <td>
                                <small class="d-block text-muted">Exp: <%=rs.getString("experience") != null ? rs.getString("experience") : "Not provided"%></small>
                                <small class="d-block text-muted">Skills: <%=rs.getString("skills") != null ? rs.getString("skills") : "Not provided"%></small>
                            </td>
                            <!-- Display Application Submission Date -->
                            <td><%=rs.getString("apply_date")%></td>
                            <!-- Dynamically style the Application Status badge: Yellow for Pending, Red for Rejected, Green for Shortlisted/Accepted -->
                            <td><span class="badge rounded-pill <%=status.equals("Pending") ? "bg-warning text-dark" : (status.equals("Rejected") ? "bg-danger" : "bg-success")%> px-3"><%=status%></span></td>
                            <!-- Action Button: Links to hr_review_application.jsp passing the specific application_id -->
                            <td><a href="hr_review_application.jsp?appid=<%=rs.getString("application_id")%>" class="btn btn-sm btn-outline-primary fw-bold rounded-pill px-3">Review</a></td>
                        </tr>
                    <% // If no applications have been submitted for this HR user's jobs, display an empty-state message row %>
                    <% } if(!found) { %><tr><td colspan="6" class="text-center text-muted py-4"><i class="bi bi-inbox fs-3 d-block mb-2"></i>No applications received for your posted jobs yet.</td></tr><% } } %>
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