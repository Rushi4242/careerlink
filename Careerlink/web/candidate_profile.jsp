<%
// Session Validation: Verify that a user is logged in and holds the "Candidate" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Candidate")) {
    // Redirect unauthorized or unauthenticated users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL package for database operations and the custom DBConnection utility class --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in Candidate's email from the session and initialize profile variables
String email=session.getAttribute("user").toString();
String fullname="", mobile="", education="", skills="", experience="", message="";

// Establish a connection to the MySQL database
Connection con=DBConnection.getConnection();

// Handle Form Submission: Check if the page was requested via a POST method
if(request.getMethod().equalsIgnoreCase("POST")) {
    // Retrieve updated profile field values submitted from the HTML form
    fullname=request.getParameter("fullname");
    mobile=request.getParameter("mobile");
    education=request.getParameter("education");
    skills=request.getParameter("skills");
    experience=request.getParameter("experience");

    // Prepare and execute a SQL UPDATE statement to save the candidate's new profile details
    PreparedStatement update=con.prepareStatement("UPDATE users SET full_name=?, mobile=?, education=?, skills=?, experience=? WHERE email=?");
    update.setString(1,fullname); update.setString(2,mobile); update.setString(3,education); update.setString(4,skills); update.setString(5,experience); update.setString(6,email);
    
    // Set a success or error alert message depending on whether the database update succeeded
    if(update.executeUpdate() > 0) message = "<div class='alert alert-success fw-bold'><i class='bi bi-check-circle-fill me-2'></i>Profile Updated Successfully!</div>";
    else message = "<div class='alert alert-danger fw-bold'>Failed to update profile.</div>";
}

// Prepare and execute a SQL SELECT query to fetch the candidate's current profile data
PreparedStatement ps=con.prepareStatement("SELECT * FROM users WHERE email=?");
ps.setString(1,email);
ResultSet rs=ps.executeQuery();

// If the user record is found, populate the variables (using empty strings as fallbacks for null values)
if(rs.next()) {
    fullname=rs.getString("full_name");
    mobile = rs.getString("mobile") != null ? rs.getString("mobile") : "";
    education = rs.getString("education") != null ? rs.getString("education") : "";
    skills = rs.getString("skills") != null ? rs.getString("skills") : "";
    experience = rs.getString("experience") != null ? rs.getString("experience") : "";
}
// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile | Candidate</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and form styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, typography, and horizontal overflow prevention */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex wrapper to align the sidebar and main content side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Fixed-width sticky vertical sidebar with a light blue background */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        
        /* Purple header box at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        /* Sidebar brand heading and subtitle text styling */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        .sidebar-header .text-light { color: #f8f9fa !important; }
        /* Downward-pointing purple triangle indicator below the sidebar header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }

        /* Reset list margins/padding and add a white divider line between menu items */
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
        /* Centered white card container for the candidate profile form */
        .profile-card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); max-width: 700px; margin: 0 auto; }
        /* Custom styling and focus glow for form text inputs and dropdown selects */
        .form-control, .form-select { background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 12px; }
        .form-control:focus, .form-select:focus { border-color: #3b82f6; box-shadow: 0 0 0 0.25rem rgba(59, 130, 246, 0.25); background-color: #fff; }
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

    <!-- Main Content Section -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Candidate's Full Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Account Settings</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=fullname%></div>
        </div>

        <!-- Candidate Profile Form Card -->
        <div class="profile-card">
            <!-- Card Header with Avatar Icon and Instructions -->
            <div class="text-center mb-4">
                <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 80px; height: 80px; font-size: 35px;">
                    <i class="bi bi-person"></i>
                </div>
                <h4 class="fw-bold">My Profile</h4>
                <p class="text-muted small">Update your skills and education to unlock job applications.</p>
            </div>
            
            <!-- Display feedback alert message after form submission -->
            <%=message%>

            <!-- Profile Update Form submitting via POST -->
            <form method="post">
                <div class="row">
                    <!-- Full Name Input Field -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Full Name</label>
                        <input type="text" name="fullname" class="form-control" value="<%=fullname%>" required>
                    </div>
                    <!-- Mobile Number Input Field (restricted to 10 characters) -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Mobile Number</label>
                        <input type="text" name="mobile" class="form-control" value="<%=mobile%>" maxlength="10" required>
                    </div>
                </div>

                <!-- Read-Only Email Address Field (cannot be changed) -->
                <div class="mb-3">
                    <label class="form-label fw-bold text-muted small">Email Address (Read Only)</label>
                    <input type="email" class="form-control text-muted" value="<%=email%>" readonly style="background: #e9ecef;">
                </div>
                
                <!-- Highest Education Input Field -->
                <div class="mb-3">
                    <label class="form-label fw-bold text-muted small">Highest Education</label>
                    <input type="text" name="education" class="form-control" value="<%=education%>" placeholder="e.g. B.Tech Computer Science" required>
                </div>
                
                <!-- Technical Skills Input Field -->
                <div class="mb-3">
                    <label class="form-label fw-bold text-muted small">Technical Skills (Comma separated)</label>
                    <input type="text" name="skills" class="form-control" value="<%=skills%>" placeholder="e.g. Java, Python, SQL" required>
                </div>
                
                <!-- Professional Experience Dropdown: Dynamically pre-selects the saved experience level -->
                <div class="mb-4">
                    <label class="form-label fw-bold text-muted small">Professional Experience</label>
                    <select name="experience" class="form-select" required>
                        <option value="" disabled <%=experience.isEmpty() ? "selected" : ""%>>Select Experience Level</option>
                        <option value="Fresher" <%=experience.equals("Fresher") ? "selected" : ""%>>Fresher</option>
                        <option value="1-2 Years" <%=experience.equals("1-2 Years") ? "selected" : ""%>>1-2 Years</option>
                        <option value="3-5 Years" <%=experience.equals("3-5 Years") ? "selected" : ""%>>3-5 Years</option>
                        <option value="5+ Years" <%=experience.equals("5+ Years") ? "selected" : ""%>>5+ Years</option>
                    </select>
                </div>

                <!-- Submit Button to save profile updates -->
                <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-pill shadow-sm mb-3">Save Profile Updates</button>
            </form>
        </div>
    </div>
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>