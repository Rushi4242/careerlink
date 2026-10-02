<%
// --------------------------------------------------------------------------------
// 1. SESSION VALIDATION & SECURITY
// --------------------------------------------------------------------------------
// Protect the page: Ensure the user is actively logged in and is a 'Candidate'.
// If unauthorized, immediately redirect to the login page and stop execution.
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Candidate")) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import necessary Java SQL classes for database interactions and custom DB connection utility --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// --------------------------------------------------------------------------------
// 2. CANDIDATE DATA RETRIEVAL
// --------------------------------------------------------------------------------
String email = session.getAttribute("user").toString();
Connection con = DBConnection.getConnection();

// Initialize variables to store candidate information
int userId = 0; 
String name = "Candidate"; 
boolean isProfileComplete = true;

// Query the database to retrieve the candidate's account and profile details
PreparedStatement psUser = con.prepareStatement("SELECT * FROM users WHERE email=?");
psUser.setString(1, email);
ResultSet rsUser = psUser.executeQuery();

if(rsUser.next()) {
    userId = rsUser.getInt("user_id"); 
    name = rsUser.getString("full_name");
    
    // Extract profile fields to verify completeness
    String mobile = rsUser.getString("mobile"); 
    String edu = rsUser.getString("education"); 
    String skills = rsUser.getString("skills"); 
    String exp = rsUser.getString("experience");
    
    // If any required field is missing, flag the profile as incomplete
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || skills == null || skills.trim().isEmpty() || exp == null || exp.trim().isEmpty()) {
        isProfileComplete = false;
    }
}

// --------------------------------------------------------------------------------
// 3. JOB APPLICATION PROCESSING LOGIC
// --------------------------------------------------------------------------------
// Retrieve the target job ID from the URL parameters (e.g., apply_job.jsp?jobid=5)
String jobIdParam = request.getParameter("jobid");

// If no job ID is provided, safely redirect the user back to the search page to prevent errors
if(jobIdParam == null || jobIdParam.isEmpty()) { 
    response.sendRedirect("search_jobs.jsp"); 
    return; 
}
int jobId = Integer.parseInt(jobIdParam);

String message = ""; 
boolean isSuccess = false;

// Step 3a: Check for Duplicate Applications
// Query the 'applications' table to see if this user has already applied for this specific job
PreparedStatement check = con.prepareStatement("SELECT * FROM applications WHERE job_id=? AND user_id=?");
check.setInt(1, jobId); 
check.setInt(2, userId);

if(check.executeQuery().next()) {
    // If a record is found, the candidate has already applied. Set a notice message.
    message = "You have already applied for this position.";
} else {
    // Step 3b: Process New Application
    // If no record exists, insert a new application into the database with a 'Pending' status
    PreparedStatement insert = con.prepareStatement("INSERT INTO applications(job_id,user_id,apply_date,status) VALUES(?,?,CURDATE(),'Pending')");
    insert.setInt(1, jobId); 
    insert.setInt(2, userId);
    
    if(insert.executeUpdate() > 0) { 
        message = "Application Submitted Successfully!"; 
        isSuccess = true; 
    } else { 
        message = "Application Failed to Submit. Please try again."; 
    }
}

// Capture current page URI for the sidebar active-state logic
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Job Application Status</title>
    <!-- Include Bootstrap 5 CSS for UI grid and components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background and font setup */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Main flex container to align sidebar and content side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* --- SIDEBAR STYLING --- */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        .sidebar-header .text-light { color: #f8f9fa !important; }
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        
        /* Sidebar Navigation Items */
        .sidebar ul { margin: 0; padding: 0; }
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        
        /* Sidebar Logout Button */
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }
        
        /* --- MAIN CONTENT STYLING --- */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        
        /* Centered Status Card for Application Result */
        .status-card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); max-width: 500px; margin: 0 auto; text-align: center; }
        
        /* Circular Icon Styling for Success/Notice Indicators */
        .icon-circle { width: 80px; height: 80px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 40px; margin: 0 auto 20px auto; }
        .success-bg { background: rgba(25, 135, 84, 0.1); color: #198754; } /* Green theme for success */
        .warning-bg { background: rgba(255, 193, 7, 0.15); color: #ffc107; } /* Yellow theme for duplicate/error */
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation -->
    <nav class="sidebar">
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-layers-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Candidate Portal</div>
        </div>
        <ul class="list-unstyled mt-3 flex-grow-1">
            <!-- Dynamic active class highlighting based on the URL -->
            <li><a href="candidate_dashboard.jsp" class="<%= currentPageURI.contains("candidate_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>
            <li><a href="candidate_profile.jsp" class="<%= currentPageURI.contains("candidate_profile.jsp") ? "active" : "" %>"><i class="bi bi-person-vcard"></i> My Profile</a></li>
            <li><a href="search_jobs.jsp" class="<%= currentPageURI.contains("search_jobs.jsp") ? "active" : "" %>"><i class="bi bi-search"></i> Search Jobs</a></li>
            <li><a href="upload_resume.jsp" class="<%= currentPageURI.contains("upload_resume.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-arrow-up"></i> Upload Resume</a></li>
            <li><a href="my_applications.jsp" class="<%= currentPageURI.contains("my_applications.jsp") ? "active" : "" %>"><i class="bi bi-card-list"></i> My Applications</a></li>
            <li><a href="interview_status.jsp" class="<%= currentPageURI.contains("interview_status.jsp") ? "active" : "" %>"><i class="bi bi-calendar-check"></i> Interviews</a></li>
        </ul>
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Navigation Bar -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Application Status</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=name%></div>
        </div>

        <!-- Application Result Status Card -->
        <div class="status-card">
            <% // Dynamically render the UI based on whether the database insertion was successful %>
            <% if(isSuccess) { %>
                <!-- Success State: Green Checkmark -->
                <div class="icon-circle success-bg"><i class="bi bi-check2-circle"></i></div>
                <h3 class="fw-bold text-dark mb-2">Success!</h3>
                <p class="text-muted mb-4"><%=message%></p>
            <% } else { %>
                <!-- Notice/Error State: Yellow Warning Icon (e.g., already applied) -->
                <div class="icon-circle warning-bg"><i class="bi bi-exclamation-triangle-fill"></i></div>
                <h3 class="fw-bold text-dark mb-2">Notice</h3>
                <p class="text-muted mb-4"><%=message%></p>
            <% } %>

            <!-- Navigation Action Buttons -->
            <div class="d-grid gap-3">
                <a href="search_jobs.jsp" class="btn btn-primary rounded-pill py-2 fw-bold">Browse More Jobs</a>
                <a href="my_applications.jsp" class="btn btn-light border rounded-pill py-2 fw-bold text-dark">View My Applications</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>