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
// Initialize variables for the HR user's ID, status feedback message, and display name
int hrId = 0;
String message = "";
String hrName = "HR";

// Query the users table to fetch the logged-in HR manager's user_id and full_name
PreparedStatement hrPs = con.prepareStatement("SELECT user_id, full_name FROM users WHERE email=?");
hrPs.setString(1, email);
ResultSet hrRs = hrPs.executeQuery();
if(hrRs.next()) { hrId = hrRs.getInt("user_id"); hrName = hrRs.getString("full_name"); }

// Handle Job Deletion: Check if a 'delete' job ID parameter was passed in the URL and the HR ID is valid
if(request.getParameter("delete") != null && hrId > 0) {
    // Parse the job ID to be deleted from the request parameter
    int deleteJobId = Integer.parseInt(request.getParameter("delete"));
    try {
        // Step 1: Delete any scheduled interviews linked to applications for this job (prevents foreign key constraint errors)
        con.prepareStatement("DELETE FROM interview WHERE application_id IN (SELECT application_id FROM applications WHERE job_id=" + deleteJobId + ")").executeUpdate();
        // Step 2: Delete all candidate applications submitted for this job
        con.prepareStatement("DELETE FROM applications WHERE job_id=" + deleteJobId).executeUpdate();
        // Step 3: Delete the job posting itself, ensuring it belongs to the logged-in HR user
        int i = con.prepareStatement("DELETE FROM jobs WHERE job_id=" + deleteJobId + " AND posted_by=" + hrId).executeUpdate();
        // Display a success alert banner if the job record was deleted
        if(i > 0) message = "<div class='alert alert-success fw-bold'><i class='bi bi-check-circle-fill me-2'></i>Job successfully deleted.</div>";
    } catch(Exception e) { message = "<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"; }
}

// Fetch all jobs posted by this HR user, ordered from newest to oldest
ResultSet rs = null;
if(hrId > 0) {
    PreparedStatement jobPs = con.prepareStatement("SELECT * FROM jobs WHERE posted_by = ? ORDER BY job_id DESC");
    jobPs.setInt(1, hrId);
    rs = jobPs.executeQuery();
}

// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Jobs | HR Portal</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, font stack, and horizontal overflow prevention */
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
        /* White card container holding the jobs table */
        .data-card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        /* Table header cell typography, background color, and border styling */
        .table th { background-color: #f8f9fa; color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; border-top: none; border-bottom: 1px solid #e5e7eb; }
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
            <h5 class="m-0 fw-bold text-dark">Manage Postings</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=hrName%></div>
        </div>

        <!-- Data Card containing the Posted Jobs Table -->
        <div class="data-card">
            <!-- Display feedback alert message if a job was deleted or an error occurred -->
            <%=message%>
            <div class="table-responsive">
                <table class="table align-middle">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Job Title & Location</th>
                            <th>Salary & Exp</th>
                            <th>Posted Date</th>
                            <th>Admin Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database ResultSet -->
                    <tbody>
                    <% // Verify ResultSet is not null, track if any rows exist, and loop through each job posting %>
                    <% if(rs != null) { boolean found = false; while(rs.next()) { found = true; String status = rs.getString("approval_status"); %>
                        <tr>
                            <!-- Display Job Title, Company Name, and Location -->
                            <td>
                                <b class="text-dark"><%=rs.getString("job_title")%></b><br>
                                <small class="text-muted"><i class="bi bi-building me-1"></i><%=rs.getString("company_name")%> | <i class="bi bi-geo-alt me-1"></i><%=rs.getString("location")%></small>
                            </td>
                            <!-- Display Salary Package and Required Experience -->
                            <td><span class="text-success fw-bold"><%=rs.getString("salary")%></span><br><small class="text-muted">Req Exp: <%=rs.getString("experience")%></small></td>
                            <!-- Display Date the Job was Posted -->
                            <td><%=rs.getString("posted_date")%></td>
                            <!-- Dynamically style the Admin Approval Status badge: Yellow for Pending, Green for Approved, Red for Rejected -->
                            <td><span class="badge rounded-pill <%=status.equals("Pending") ? "bg-warning text-dark" : (status.equals("Approved") ? "bg-success" : "bg-danger")%>"><%=status%></span></td>
                            <!-- Delete Action Button with a JavaScript confirmation prompt -->
                            <td><a href="hr_manage_jobs.jsp?delete=<%=rs.getInt("job_id")%>" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="return confirm('Permanently delete this job and all associated applications?')"><i class="bi bi-trash3-fill me-1"></i>Delete</a></td>
                        </tr>
                    <% // If the HR user has not posted any jobs yet, display an empty-state message row %>
                    <% } if(!found) { %><tr><td colspan="5" class="text-center text-muted py-4"><i class="bi bi-inbox fs-3 d-block mb-2"></i>No jobs posted yet.</td></tr><% } } %>
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