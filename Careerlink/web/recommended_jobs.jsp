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
String name="Candidate";
String userSkills = "";
boolean isProfileComplete = true; 

// Establish a connection to the MySQL database
Connection con=DBConnection.getConnection();
// Prepare and execute a SQL query to fetch the candidate's user profile using their email
PreparedStatement psUser=con.prepareStatement("SELECT * FROM users WHERE email=?");
psUser.setString(1,email);
ResultSet rsUser=psUser.executeQuery();

// If the candidate's record is found, extract their profile data to verify completeness
if(rsUser.next()) {
    name=rsUser.getString("full_name");
    String mobile = rsUser.getString("mobile");
    String edu = rsUser.getString("education");
    userSkills = rsUser.getString("skills");
    String exp = rsUser.getString("experience");
    
    // Mark the profile as incomplete if any required fields (mobile, education, skills, experience) are null or empty
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || userSkills == null || userSkills.trim().isEmpty() || exp == null || exp.trim().isEmpty()) {
        isProfileComplete = false;
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Recommended Jobs | Candidate</title>
    <!-- Include Bootstrap 5 CSS for responsive grid layout and UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { background-color: #f9fafb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex wrapper to align the sidebar and main content side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Dark-Themed Sidebar Styles */
        /* Fixed-width sticky vertical sidebar with a dark slate background */
        .sidebar { min-width: 260px; max-width: 260px; background: #111827; color: #fff; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; }
        /* Slightly lighter dark header box at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #1f2937; text-align: center; border-bottom: 1px solid #374151; }
        /* Sidebar brand heading styled with a light blue color */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #60a5fa; }
        /* Default styling for sidebar navigation links (gray text, transparent left border) */
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; color: #9ca3af; text-decoration: none; border-left: 4px solid transparent; transition: 0.3s; font-weight: 500; }
        /* Hover and active states for sidebar links (white text, lighter dark background, blue left border) */
        .sidebar ul li a:hover, .sidebar ul li a.active { color: #fff; background: #1f2937; border-left: 4px solid #3b82f6; }
        /* Icon spacing and sizing inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        
        /* Main content container expanding to fill remaining horizontal space */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        /* Top navigation bar card styling */
        .top-navbar { background: #fff; padding: 15px 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        
        /* Job Recommendation Card Styling */
        /* Default white card with subtle shadow for individual job postings */
        .job-card { border: none; border-radius: 16px; background: white; box-shadow: 0 4px 15px rgba(0,0,0,0.03); transition: all 0.3s ease; padding: 25px; height: 100%; display: flex; flex-direction: column; }
        /* Hover effect: upward lift, deeper shadow, and a green top border indicator */
        .job-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); border-top: 4px solid #10b981; }
        /* Bold blue typography for the job title */
        .job-title { color: #0d6efd; font-weight: 800; margin-bottom: 5px; }
        /* Gray typography for the hiring company name */
        .company-name { font-weight: 600; color: #495057; font-size: 15px; }
        /* Flex layout for job metadata (location and salary) */
        .job-meta { display: flex; align-items: center; gap: 15px; margin-top: 15px; margin-bottom: 15px; color: #6c757d; font-size: 14px; }
        /* Job description text styling pushing the apply button to the bottom */
        .job-desc { color: #6c757d; font-size: 14px; margin-bottom: 25px; flex-grow: 1; }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Dark-Themed Sidebar Navigation Menu -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4><i class="bi bi-layers-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Candidate Portal</div>
        </div>
        <!-- Navigation Links -->
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="candidate_dashboard.jsp"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a></li>
            <li><a href="candidate_profile.jsp"><i class="bi bi-person-vcard"></i> My Profile</a></li>
            <li><a href="search_jobs.jsp"><i class="bi bi-search"></i> Search Jobs</a></li>
            <!-- Active link highlighted for the Recommendations page -->
            <li><a href="recommended_jobs.jsp" class="active"><i class="bi bi-star-fill text-warning"></i> For You</a></li>
            <% // Conditionally unlock the 'Apply For Job' link if the profile is complete; otherwise render a locked link redirecting to the profile page %>
            <% if(isProfileComplete) { %> <li><a href="apply_job.jsp"><i class="bi bi-briefcase"></i> Apply For Job</a></li> <% } else { %> <li><a href="candidate_profile.jsp" class="text-secondary"><i class="bi bi-lock-fill"></i> Apply For Job</a></li> <% } %>
            <li><a href="upload_resume.jsp"><i class="bi bi-file-earmark-arrow-up"></i> Upload Resume</a></li>
            <li><a href="my_applications.jsp"><i class="bi bi-card-list"></i> My Applications</a></li>
            <li><a href="interview_status.jsp"><i class="bi bi-calendar-check"></i> Interviews</a></li>
        </ul>
        <!-- Logout Button Container -->
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in Candidate's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark"><i class="bi bi-stars text-warning me-2"></i>AI Skill Matches</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=name%></div>
        </div>

        <% // If the candidate's profile is incomplete, display a warning alert requesting them to update their skills %>
        <% if(!isProfileComplete || userSkills == null || userSkills.trim().isEmpty()) { %>
            <div class="alert alert-warning">Please complete your profile and list your technical skills to receive accurate job recommendations.</div>
        <% } else { %>
            <!-- Display a success banner showing the candidate's extracted skills being used for matching -->
            <div class="alert alert-success border-0 shadow-sm d-flex align-items-center rounded-3 mb-4">
                <i class="bi bi-magic fs-3 me-3 text-success"></i>
                <div>Showing positions matching your skills: <b><%=userSkills%></b></div>
            </div>
            
            <div class="row g-4">
            <%
            // Safe matching logic: Extract the very first skill only after confirming userSkills is populated
            String firstSkill = userSkills.split(",")[0].trim();
            
            // Prepare a SQL query to fetch Approved jobs where the job_title or description contains the candidate's primary skill
            PreparedStatement psRec = con.prepareStatement("SELECT * FROM jobs WHERE approval_status = 'Approved' AND (job_title LIKE ? OR description LIKE ?) ORDER BY job_id DESC");
            psRec.setString(1, "%" + firstSkill + "%");
            psRec.setString(2, "%" + firstSkill + "%");
            // Execute the matching query
            ResultSet rsRec = psRec.executeQuery();
            // Track if at least one matching job was found
            boolean matchFound = false;
            
            // Loop through each matched job posting and render a job card
            while(rsRec.next()) {
                matchFound = true;
            %>
                <div class="col-md-6 col-lg-4">
                    <div class="job-card">
                        <!-- Job Header: Title, Company Name, and an artificial match percentage badge -->
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h5 class="job-title"><%=rsRec.getString("job_title")%></h5>
                                <div class="company-name"><i class="bi bi-building me-1"></i><%=rsRec.getString("company_name")%></div>
                            </div>
                            <span class="badge bg-success shadow-sm">98% Match</span>
                        </div>
                        <!-- Job Metadata: Location and Salary Details -->
                        <div class="job-meta">
                            <span><i class="bi bi-geo-alt-fill text-danger me-1"></i><%=rsRec.getString("location")%></span>
                            <span><i class="bi bi-cash-stack text-success me-1"></i><%=rsRec.getString("salary")%></span>
                        </div>
                        <!-- Job Description Section with Required Experience -->
                        <div class="job-desc border-top pt-3">
                            <span class="d-block mb-2 text-dark"><b>Req. Exp:</b> <%=rsRec.getString("experience")%></span>
                            <%=rsRec.getString("description")%>
                        </div>
                        <!-- Call-to-Action Button: Directs the candidate to apply for this specific matched job -->
                        <a href="apply_job.jsp?jobid=<%=rsRec.getInt("job_id")%>" class="btn btn-primary w-100 rounded-pill fw-bold mt-auto">Apply Match</a>
                    </div>
                </div>
            <% // If no job postings matched the candidate's primary skill, display an empty-state message %>
            <% } if(!matchFound) { %>
                <div class="col-12 text-center py-5">
                    <i class="bi bi-emoji-frown text-muted" style="font-size: 50px;"></i>
                    <h5 class="mt-3 text-muted">No direct matches found for your primary skills at the moment.</h5>
                    <a href="search_jobs.jsp" class="btn btn-outline-primary mt-2 rounded-pill">Browse All Jobs</a>
                </div>
            <% } %>
            </div>
        <% } %>
    </div>
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>