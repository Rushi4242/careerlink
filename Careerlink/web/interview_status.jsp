<%
// Session Validation: Verify that a user is logged in and holds the "Candidate" role
if(session.getAttribute("user")==null || !session.getAttribute("role").equals("Candidate")) {
    // Redirect unauthorized or unauthenticated users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL package for database operations and the custom DBConnection utility class --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in Candidate's email from the session and establish a database connection
String email=session.getAttribute("user").toString();
Connection con=DBConnection.getConnection();
// Initialize candidate variables and a flag to track whether their profile is complete
int userId=0; String name="Candidate"; boolean isProfileComplete = true;

// Query the users table to fetch the candidate's user ID, full name, and profile details
PreparedStatement userPs=con.prepareStatement("SELECT * FROM users WHERE email=?");
userPs.setString(1,email);
ResultSet userRs=userPs.executeQuery();
if(userRs.next()) {
    userId=userRs.getInt("user_id"); name=userRs.getString("full_name");
    String mobile = userRs.getString("mobile"); String edu = userRs.getString("education"); String skills = userRs.getString("skills"); String exp = userRs.getString("experience");
    // Check if any required profile fields (mobile, education, skills, experience) are null or empty
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || skills == null || skills.trim().isEmpty() || exp == null || exp.trim().isEmpty()) {
        isProfileComplete = false;
    }
}

// Prepare a SQL query joining interview, applications, and jobs tables to fetch all interviews scheduled for this candidate (newest first)
PreparedStatement ps=con.prepareStatement(
    "SELECT j.company_name, j.job_title, i.interview_date, i.interview_time, i.interview_mode, i.status " +
    "FROM interview i JOIN applications a ON i.application_id = a.application_id JOIN jobs j ON a.job_id = j.job_id WHERE a.user_id = ? ORDER BY i.interview_date DESC"
);
ps.setInt(1,userId);
// Execute the query and store the scheduled interview records in a ResultSet
ResultSet rs=ps.executeQuery();

// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Interview Status | Candidate</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex container to align the sidebar and main content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Fixed-width sticky vertical sidebar with a light blue background */
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
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        /* White card container holding the interview schedule table */
        .data-card { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        /* Table header cell typography and background color styling */
        .table th { background-color: #f8f9fa; color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation Menu -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-layers-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Candidate Portal</div>
        </div>
        
        <!-- Navigation Links: Dynamically checks currentPageURI to highlight the active page -->
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="candidate_dashboard.jsp" class="<%= currentPageURI.contains("candidate_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>
            <li><a href="candidate_profile.jsp" class="<%= currentPageURI.contains("candidate_profile.jsp") ? "active" : "" %>"><i class="bi bi-person-vcard"></i> My Profile</a></li>
            <li><a href="search_jobs.jsp" class="<%= currentPageURI.contains("search_jobs.jsp") ? "active" : "" %>"><i class="bi bi-search"></i> Search Jobs</a></li>
            <li><a href="upload_resume.jsp" class="<%= currentPageURI.contains("upload_resume.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-arrow-up"></i> Upload Resume</a></li>
            <li><a href="my_applications.jsp" class="<%= currentPageURI.contains("my_applications.jsp") ? "active" : "" %>"><i class="bi bi-card-list"></i> My Applications</a></li>
            <li><a href="interview_status.jsp" class="<%= currentPageURI.contains("interview_status.jsp") ? "active" : "" %>"><i class="bi bi-calendar-check"></i> Interviews</a></li>
        </ul>
        <!-- Logout Button -->
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in Candidate's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-calendar-event text-danger me-2"></i>Interview Schedule</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=name%></div>
        </div>

        <!-- Data Card containing the Candidate's Scheduled Interviews Table -->
        <div class="data-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Company & Role</th>
                            <th>Date</th>
                            <th>Time & Mode</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database ResultSet -->
                    <tbody>
                    <% // Track if any scheduled interviews exist and iterate through each row in the ResultSet %>
                    <% boolean found=false; while(rs.next()) { found=true; %>
                        <tr>
                            <!-- Display Hiring Company Name and Job Title -->
                            <td><span class="fw-bold d-block text-dark"><i class="bi bi-building me-2 text-muted"></i><%=rs.getString("company_name")%></span><small class="text-primary fw-bold ms-4"><%=rs.getString("job_title")%></small></td>
                            <!-- Display Scheduled Interview Date -->
                            <td><b><%=rs.getString("interview_date")%></b></td>
                            <!-- Display Interview Time and Mode (e.g., Online, Offline, Phone Call) -->
                            <td><i class="bi bi-clock me-1 text-muted"></i><%=rs.getString("interview_time")%><br><small class="text-muted"><i class="bi bi-laptop me-1"></i><%=rs.getString("interview_mode")%></small></td>
                            <!-- Display Interview Status inside a green pill badge -->
                            <td><span class="badge bg-success px-3 rounded-pill"><i class="bi bi-check-circle me-1"></i><%=rs.getString("status")%></span></td>
                        </tr>
                    <% // If no interviews have been scheduled for this candidate yet, display an empty-state message row %>
                    <% } if(!found) { %><tr><td colspan="4" class="text-center text-muted py-4">No Interviews Scheduled Yet. Keep applying!</td></tr><% } %>
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