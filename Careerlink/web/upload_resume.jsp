<%
// --------------------------------------------------------------------------------
// 1. SESSION VALIDATION & SECURITY
// --------------------------------------------------------------------------------
// Protect the page: Ensure the user is actively logged in and holds the 'Candidate' role.
// If the session is invalid or the role doesn't match, redirect to the login page immediately.
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Candidate")) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import necessary Java SQL, IO, Servlet Part (for multipart file uploads), and custom DB utility classes --%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="javax.servlet.http.Part"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// --------------------------------------------------------------------------------
// 2. CANDIDATE PROFILE CHECK & INITIALIZATION
// --------------------------------------------------------------------------------
// Retrieve the candidate's email from the active session
String email = session.getAttribute("user").toString();
Connection con = DBConnection.getConnection();

// Initialize variables to store candidate information and track profile completeness
int userId = 0; 
String name = "Candidate"; 
boolean isProfileComplete = true;

// Query the database to retrieve the candidate's specific user record
PreparedStatement psUser = con.prepareStatement("SELECT * FROM users WHERE email=?");
psUser.setString(1, email);
ResultSet rsUser = psUser.executeQuery();

if(rsUser.next()) {
    // Populate variables with data from the database
    userId = rsUser.getInt("user_id"); 
    name = rsUser.getString("full_name");
    
    // Extract profile fields to check if the candidate has completed their profile
    String mobile = rsUser.getString("mobile"); 
    String edu = rsUser.getString("education"); 
    String skills = rsUser.getString("skills"); 
    String exp = rsUser.getString("experience");
    
    // Validate profile completeness: if any required field is null or empty, flag the profile as incomplete
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || skills == null || skills.trim().isEmpty() || exp == null || exp.trim().isEmpty()) {
        isProfileComplete = false;
    }
}

// --------------------------------------------------------------------------------
// 3. EXISTING RESUME CHECK
// --------------------------------------------------------------------------------
// Initialize flags and variables to handle the UI state if a resume already exists
boolean hasExistingResume = false;
String existingFileName = "";

// Query the 'resume' table to check if a resume document is already linked to this candidate's user_id
PreparedStatement psCheck = con.prepareStatement("SELECT * FROM resume WHERE user_id=?");
psCheck.setInt(1, userId);
ResultSet rsCheck = psCheck.executeQuery();

if(rsCheck.next()) {
    // If a record is found, update the boolean flag and store the existing filename for display
    hasExistingResume = true;
    existingFileName = rsCheck.getString("resume_file");
}

String message = ""; 

// --------------------------------------------------------------------------------
// 4. FILE UPLOAD PROCESSING (POST REQUEST)
// --------------------------------------------------------------------------------
// Execute file upload logic only when the form is submitted via POST
if(request.getMethod().equalsIgnoreCase("POST")) {
    try {
        // Retrieve the file part from the multipart/form-data request payload
        Part filePart = request.getPart("resumeFile");
        String fileName = filePart.getSubmittedFileName();
        
        // Proceed only if a valid file name was extracted and submitted
        if(fileName != null && !fileName.isEmpty()) {
            // Define the absolute physical path on the server where resumes will be saved securely
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploaded_resumes";
            File uploadDir = new File(uploadPath);
            
            // Create the directory dynamically if it does not already exist on the server filesystem
            if(!uploadDir.exists()) uploadDir.mkdir();
            
            // Write the uploaded file byte stream to the server disk at the defined path
            filePart.write(uploadPath + File.separator + fileName);
            
            // Database Logic: Update vs Insert
            if(hasExistingResume) {
                // If a resume already exists, execute an UPDATE statement to overwrite the database record
                PreparedStatement update = con.prepareStatement("UPDATE resume SET resume_file=?, upload_date=CURDATE() WHERE user_id=?");
                update.setString(1, fileName);
                update.setInt(2, userId);
                
                if(update.executeUpdate() > 0) {
                    message = "<div class='alert alert-success fw-bold'><i class='bi bi-check-circle-fill me-2'></i>Resume Updated Successfully! Saved as: " + fileName + "</div>";
                    existingFileName = fileName; // Update local variable to refresh UI instantly
                }
            } else {
                // If this is the candidate's first upload, execute an INSERT statement to create a new record
                PreparedStatement insert = con.prepareStatement("INSERT INTO resume(user_id,resume_file,upload_date) VALUES(?,?,CURDATE())");
                insert.setInt(1, userId); 
                insert.setString(2, fileName);
                
                if(insert.executeUpdate() > 0) { 
                    message = "<div class='alert alert-success fw-bold'><i class='bi bi-check-circle-fill me-2'></i>Resume Uploaded Successfully! Saved as: " + fileName + "</div>"; 
                    hasExistingResume = true; // Switch flag to true to change UI state on re-render
                    existingFileName = fileName; 
                }
            }
        } else { 
            // Warning message if the form is somehow submitted but the file payload is empty
            message = "<div class='alert alert-warning'>Please select a file to upload.</div>"; 
        }
    } catch(Exception e) { 
        // Catch and display any file IO errors or SQL execution exceptions
        message = "<div class='alert alert-danger'>Upload Failed: " + e.getMessage() + "</div>"; 
    }
}

// Capture current page URI for the sidebar active-state logic
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Upload Resume | Candidate</title>
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
        
        /* Centered White Card Container for the Upload Form */
        .form-card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); max-width: 600px; margin: 0 auto; }
        
        /* Custom styling and focus glow for the file input element */
        .form-control { background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 12px; }
        .form-control:focus { border-color: #3b82f6; box-shadow: 0 0 0 0.25rem rgba(59, 130, 246, 0.25); background-color: #fff; }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation Menu -->
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
        <!-- Top Navigation Bar showing Page Title and User Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-file-earmark-arrow-up text-primary me-2"></i>Upload Document</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=name%></div>
        </div>

        <!-- Document Upload Card -->
        <div class="form-card">
            <!-- Display feedback alert message (Success/Error/Warning) -->
            <%=message%>
            
            <% // Conditional UI Rendering based on whether the user already has a resume uploaded %>
            <% if(hasExistingResume) { %>
                <!-- Display an info banner showing the current active resume file name -->
                <div class="alert border mb-4" style="background-color: #f0f9ff; border-color: #bfdbfe;">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="text-primary fw-bold m-0"><i class="bi bi-file-earmark-check-fill me-2"></i>Current Active Resume</h6>
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check-circle-fill me-1"></i> Uploaded</span>
                    </div>
                    <p class="mb-1 text-dark fw-bold"><%=existingFileName%></p>
                    <p class="mb-0 text-muted small">Uploading a new file below will safely overwrite this existing document.</p>
                </div>
            <% } else { %>
                <!-- Display a warning banner instructing the user to upload their first resume -->
                <div class="alert alert-warning mb-4"><i class="bi bi-exclamation-triangle-fill me-2"></i>You have not uploaded a resume yet. You must upload one to apply for jobs.</div>
            <% } %>

            <!-- File Upload Form: Crucially requires enctype="multipart/form-data" for binary file submissions -->
            <form method="post" enctype="multipart/form-data" class="mb-4">
                <div class="mb-3">
                    <!-- Dynamic Label text based on whether a resume already exists -->
                    <label class="form-label fw-bold text-muted small"><%= hasExistingResume ? "Select New Document to Replace" : "Select Document (PDF or Word)" %></label>
                    <!-- File input element restricting selection to common document formats (.pdf, .doc, .docx) -->
                    <input type="file" name="resumeFile" class="form-control" accept=".pdf,.doc,.docx" required>
                </div>
                <!-- Dynamic Submit Button text -->
                <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-pill shadow-sm"><%= hasExistingResume ? "Update Resume" : "Upload Resume" %></button>
            </form>
        </div>
    </div>
</div>
<!-- Load Bootstrap JS bundle for interactive components -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>