<%
// --------------------------------------------------------------------------------
// 1. SESSION VALIDATION & SECURITY
// --------------------------------------------------------------------------------
// Verify that a user is actively logged in and holds the "Candidate" role.
// If the session is invalid or the role doesn't match, redirect to the login page to prevent unauthorized access.
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Candidate")) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import required Java SQL packages for database operations and the custom DBConnection utility --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// --------------------------------------------------------------------------------
// 2. USER DATA & PROFILE COMPLETENESS CHECK
// --------------------------------------------------------------------------------
// Retrieve the logged-in Candidate's email address from the active session
String email = session.getAttribute("user").toString();
Connection con = DBConnection.getConnection();

// Initialize variables to store candidate details and a flag for profile completeness
int userId = 0; 
String name = "Candidate"; 
boolean isProfileComplete = true;

// Query the 'users' table to fetch the candidate's unique user_id, full name, and profile details
PreparedStatement userPs = con.prepareStatement("SELECT * FROM users WHERE email=?");
userPs.setString(1, email);
ResultSet userRs = userPs.executeQuery();

if(userRs.next()) {
    userId = userRs.getInt("user_id"); 
    name = userRs.getString("full_name");
    
    // Extract profile fields to check if the candidate has completed their profile
    String mobile = userRs.getString("mobile"); 
    String edu = userRs.getString("education"); 
    String skills = userRs.getString("skills"); 
    String exp = userRs.getString("experience");
    
    // If any mandatory text field is missing or empty, flag the profile as incomplete
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || skills == null || skills.trim().isEmpty() || exp == null || exp.trim().isEmpty()) {
        isProfileComplete = false;
    }
}

// --------------------------------------------------------------------------------
// 3. FETCH CANDIDATE'S JOB APPLICATIONS
// --------------------------------------------------------------------------------
// Prepare a SQL query joining the 'applications' and 'jobs' tables.
// This retrieves all job details that the current candidate has applied for, ordered by newest application first.
PreparedStatement appPs = con.prepareStatement(
    "SELECT j.job_title, j.company_name, j.location, a.apply_date, a.status " +
    "FROM applications a JOIN jobs j ON a.job_id = j.job_id " +
    "WHERE a.user_id = ? ORDER BY a.application_id DESC"
);
appPs.setInt(1, userId);

// Execute the query and store the application records in a ResultSet to iterate over later in the HTML
ResultSet rs = appPs.executeQuery();

// Capture the current request URI to dynamically highlight the active link in the sidebar navigation
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Applications | Candidate</title>
    
    <!-- --------------------------------------------------------------------------------
         4. EXTERNAL LIBRARIES & CSS STYLING
         -------------------------------------------------------------------------------- -->
    <!-- Include Bootstrap 5 CSS for responsive grid layout and prebuilt UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography used in the sidebar and tables -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        
        /* Flex container to seamlessly align the fixed sidebar and the main scrolling content side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Fixed-width sticky vertical sidebar container with a light blue background */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        
        /* Purple header box at the top of the sidebar containing the brand name */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        .sidebar-header .text-light { color: #f8f9fa !important; }
        
        /* Downward-pointing purple triangle indicator positioned below the sidebar header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        
        /* Reset list margins/padding and add a white bottom border between sidebar menu items */
        .sidebar ul { margin: 0; padding: 0; }
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        
        /* Default styling for sidebar navigation links */
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        
        /* Hover and Active state background colors for sidebar links */
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        
        /* Icon spacing and sizing inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        
        /* Bottom container pushing the logout button to the base of the sidebar */
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }
        
        /* Main content container expanding to fill remaining horizontal space */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        
        /* Top navigation bar card styling for page title and user display */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        
        /* White card container holding the applications data table */
        .data-card { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        
        /* Table header cell typography, background color, and border styling */
        .table th { background-color: #f8f9fa; color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- --------------------------------------------------------------------------------
         5. SIDEBAR NAVIGATION
         -------------------------------------------------------------------------------- -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-layers-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Candidate Portal</div>
        </div>
        
        <!-- Navigation Links: Uses the 'currentPageURI' variable to dynamically apply the 'active' class to the current page -->
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

    <!-- --------------------------------------------------------------------------------
         6. MAIN CONTENT AREA
         -------------------------------------------------------------------------------- -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and the Logged-in Candidate's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-card-list text-primary me-2"></i>My Job Applications</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=name%></div>
        </div>

        <!-- Data Card containing the Candidate's Applications Table -->
        <div class="data-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <!-- Table Column Headers -->
                    <thead>
                        <tr>
                            <th>Job Title</th>
                            <th>Company & Location</th>
                            <th>Applied On</th>
                            <th>Application Status</th>
                        </tr>
                    </thead>
                    <!-- Table Body populated dynamically from the database ResultSet -->
                    <tbody>
                    <% 
                    // Track if any applications exist using the 'found' boolean.
                    // Iterate through each application row in the ResultSet.
                    boolean found = false; 
                    while(rs.next()) { 
                        found = true; 
                        String status = rs.getString("status"); 
                    %>
                        <tr>
                            <!-- Display the Job Title -->
                            <td><span class="text-primary fw-bold"><%=rs.getString("job_title")%></span></td>
                            
                            <!-- Display the Hiring Company Name and Job Location side-by-side -->
                            <td>
                                <span class="fw-bold d-block text-dark"><i class="bi bi-building me-2 text-muted"></i><%=rs.getString("company_name")%></span>
                                <small class="text-muted"><i class="bi bi-geo-alt me-1"></i><%=rs.getString("location")%></small>
                            </td>
                            
                            <!-- Display Application Submission Date -->
                            <td><i class="bi bi-calendar-date me-1 text-muted"></i><b><%=rs.getString("apply_date")%></b></td>
                            
                            <!-- Dynamically render the Application Status Badge based on HR's evaluation decision -->
                            <td>
                                <% if(status.equals("Pending")) { %>
                                    <!-- Yellow badge for applications not yet reviewed by HR -->
                                    <span class="badge bg-warning text-dark px-3 rounded-pill">Pending Review</span>
                                <% } else if(status.equals("Rejected")) { %>
                                    <!-- Red badge for rejected applications -->
                                    <span class="badge bg-danger px-3 rounded-pill">Rejected</span>
                                <% } else if(status.equals("Shortlisted") || status.equals("Accepted")) { %>
                                    <!-- Green badge for successfully shortlisted candidates -->
                                    <span class="badge bg-success px-3 rounded-pill">Shortlisted</span>
                                <% } %>
                            </td>
                        </tr>
                    <% 
                    } 
                    // If no applications have been made by the candidate yet, display a helpful empty-state message row
                    if(!found) { 
                    %>
                        <tr>
                            <td colspan="4" class="text-center text-muted py-4">You have not applied for any jobs yet. Head over to <b>Search Jobs</b> to get started!</td>
                        </tr>
                    <% 
                    } 
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Include Bootstrap 5 JavaScript Bundle for interactive components (like dropdowns and mobile toggles) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>