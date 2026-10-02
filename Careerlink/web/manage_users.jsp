<%
// Session Validation: Verify that a user is logged in and holds the "Admin" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Admin")) {
    // Redirect unauthorized or unauthenticated users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>
<%-- Import Java SQL package for database operations and the custom DBConnection utility class --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Establish a connection to the MySQL database and initialize the feedback message variable
Connection con = DBConnection.getConnection();
String message = "";

// Handle User Deletion: Check if a 'delete' user ID parameter was passed in the URL
if(request.getParameter("delete") != null) {
    // Parse the target user ID from the request parameter
    int deleteUserId = Integer.parseInt(request.getParameter("delete"));
    try {
        // 1. Delete associated interviews (as Candidate or HR) to prevent foreign-key constraint violations
        con.prepareStatement("DELETE FROM interview WHERE application_id IN (SELECT application_id FROM applications WHERE user_id=" + deleteUserId + ")").executeUpdate();
        con.prepareStatement("DELETE FROM interview WHERE application_id IN (SELECT application_id FROM applications WHERE job_id IN (SELECT job_id FROM jobs WHERE posted_by=" + deleteUserId + "))").executeUpdate();
        
        // 2. Delete associated applications (submitted by the user as a Candidate or received for jobs posted by the user as HR)
        con.prepareStatement("DELETE FROM applications WHERE user_id=" + deleteUserId).executeUpdate();
        con.prepareStatement("DELETE FROM applications WHERE job_id IN (SELECT job_id FROM jobs WHERE posted_by=" + deleteUserId + ")").executeUpdate();
        
        // 3. Delete associated resumes (if Candidate) and job postings (if HR)
        con.prepareStatement("DELETE FROM resume WHERE user_id=" + deleteUserId).executeUpdate();
        con.prepareStatement("DELETE FROM jobs WHERE posted_by=" + deleteUserId).executeUpdate();
        
        // 4. Finally, delete the user account from the 'users' table (safeguarding Admin accounts from deletion)
        PreparedStatement psDel = con.prepareStatement("DELETE FROM users WHERE user_id=? AND role != 'Admin'");
        psDel.setInt(1, deleteUserId);
        int i = psDel.executeUpdate();
        
        // If the deletion affected at least one row, set a success alert message
        if(i > 0) {
            message = "<div class='alert alert-success fw-bold'><i class='bi bi-check-circle-fill me-2'></i>User removed successfully.</div>";
        }
    } catch(Exception e) {
        // Capture and display any SQL or system errors encountered during deletion
        message = "<div class='alert alert-danger fw-bold'>Error removing user: " + e.getMessage() + "</div>";
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users | Admin Portal</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { background: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex container to align the sidebar and main content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Unified Light Blue & Purple Sidebar */
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
        /* Logout button background and font styling */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; }
        
        /* Main content container and padding */
        .content { width: 100%; padding: 30px; }
        /* Top navigation bar card styling */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        /* White card container holding the registered users table */
        .table-card { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation Menu -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4><i class="bi bi-shield-lock-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Admin Portal</div>
        </div>
        <!-- Navigation Links: Dynamically checks currentPageURI to highlight the active page -->
        <ul class="list-unstyled flex-grow-1">
            <li><a href="admin_dashboard.jsp" class="<%= currentPageURI.contains("admin_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> System Overview</a></li>
            <li><a href="manage_users.jsp" class="<%= currentPageURI.contains("manage_users.jsp") ? "active" : "" %>"><i class="bi bi-people-fill"></i> Manage Users</a></li>
            <li><a href="admin_approve_jobs.jsp" class="<%= currentPageURI.contains("admin_approve_jobs.jsp") ? "active" : "" %>"><i class="bi bi-briefcase-fill"></i> Review Jobs</a></li>
            <li><a href="admin_all_applications.jsp" class="<%= currentPageURI.contains("admin_all_applications.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-text-fill"></i> All Applications</a></li>
            <li><a href="admin_all_interviews.jsp" class="<%= currentPageURI.contains("admin_all_interviews.jsp") ? "active" : "" %>"><i class="bi bi-calendar-event-fill"></i> All Interviews</a></li>
            <li><a href="admin_reports.jsp" class="<%= currentPageURI.contains("admin_reports.jsp") ? "active" : "" %>"><i class="bi bi-bar-chart-fill"></i> View Reports</a></li>
        </ul>
        <!-- Logout Button Container -->
        <div class="p-3">
            <a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a>
        </div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Admin Role Indicator -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">User Management</h5>
            <div class="fw-semibold text-muted">Admin</div>
        </div>

        <!-- Data Card containing the Registered Users Table -->
        <div class="table-card">
            <h5 class="fw-bold mb-4 text-primary">All Registered Users</h5>
            <!-- Display feedback alert message if a user was removed or an error occurred -->
            <%=message%>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <!-- Table Column Headers -->
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Full Name</th>
                            <th>Email Address</th>
                            <th>Mobile</th>
                            <th>Role</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database -->
                    <tbody>
                        <%
                        try {
                            // Create a SQL statement to fetch all non-Admin users ordered from newest to oldest
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM users WHERE role != 'Admin' ORDER BY user_id DESC");
                            // Flag to track if at least one user record exists
                            boolean found = false;
                            // Iterate through each user row in the ResultSet
                            while(rs.next()) {
                                found = true;
                        %>
                        <tr>
                            <!-- Display User ID, Full Name, Email Address, and Mobile Number -->
                            <td class="text-muted fw-bold">#<%=rs.getInt("user_id")%></td>
                            <td class="fw-semibold"><%=rs.getString("full_name")%></td>
                            <td><%=rs.getString("email")%></td>
                            <td><%=rs.getString("mobile")%></td>
                            <!-- Conditionally render a purple badge for HR/Employers or a light-blue badge for Candidates -->
                            <td>
                                <% if(rs.getString("role").equals("HR")) { %>
                                    <span class="badge bg-purple-light text-purple px-2 py-1" style="background:#e0d4f5; color:#6f42c1;">Employer/HR</span>
                                <% } else { %>
                                    <span class="badge bg-info-light text-info px-2 py-1" style="background:#d1f4fa; color:#0dcaf0;">Candidate</span>
                                <% } %>
                            </td>
                            <!-- Remove Action Button: Passes the user_id via the 'delete' URL parameter after JS confirmation -->
                            <td>
                                <a href="manage_users.jsp?delete=<%=rs.getInt("user_id")%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to permanently remove this user?')"><i class="bi bi-trash-fill"></i> Remove</a>
                            </td>
                        </tr>
                        <%
                            }
                            // If no non-Admin users were found in the database, display an empty-state message row
                            if(!found) {
                        %>
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">No registered users found.</td>
                        </tr>
                        <%
                            }
                        } catch (Exception e) {
                            // Output an inline table row error message if the database query fails
                            out.println("<tr><td colspan='6' class='text-danger'>Error loading users: " + e.getMessage() + "</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>