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
// Retrieve the logged-in Candidate's email from the session and initialize state variables
String email=session.getAttribute("user").toString();
String name="Candidate";
boolean isProfileComplete = true; 
int userId = 0;

// Establish a database connection and query the candidate's user record by email
Connection con=DBConnection.getConnection();
PreparedStatement ps=con.prepareStatement("SELECT * FROM users WHERE email=?");
ps.setString(1,email);
ResultSet rs=ps.executeQuery();

// If the user record exists, extract their profile details
if(rs.next()) {
    userId = rs.getInt("user_id");
    name=rs.getString("full_name");
    String mobile = rs.getString("mobile");
    String edu = rs.getString("education");
    String skills = rs.getString("skills");
    String exp = rs.getString("experience");
    
    // Check if Resume Exists in the 'resume' table for this candidate
    boolean hasResume = false;
    PreparedStatement psRes = con.prepareStatement("SELECT * FROM resume WHERE user_id=?");
    psRes.setInt(1, userId);
    ResultSet rsRes = psRes.executeQuery();
    if(rsRes.next()) hasResume = true;
    
    // Mark the profile as incomplete if any required field is missing/empty or if no resume is uploaded
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || skills == null || skills.trim().isEmpty() || exp == null || exp.trim().isEmpty() || !hasResume) {
        isProfileComplete = false;
    }
}

// Dynamically get the current page to highlight the correct sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Candidate Portal | Career Link</title>
    <!-- Include Bootstrap 5 CSS for responsive grid layout and UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    
    <style>
        /* Immersive corporate background for the main content area */
        body { 
            background: linear-gradient(rgba(17, 24, 39, 0.75), rgba(17, 24, 39, 0.75)), 
                        url('https://images.unsplash.com/photo-1497366811353-6870744d04b2?q=80&w=1920&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            background-repeat: no-repeat;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            overflow-x: hidden; 
        }
        
        /* Flex container to align the sidebar and main content side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* -------------------------------------------------------------------
           LIGHT BLUE & PURPLE SIDEBAR STYLES (Unified List)
           ------------------------------------------------------------------- */
        /* Fixed-width sticky vertical sidebar container with a light blue background */
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
        
        /* Main content container with transparent background to reveal body image */
        .content { width: 100%; padding: 30px; background: transparent; flex-grow: 1; }
        /* Glassmorphism top navigation bar displaying welcome text and current date */
        .top-navbar { background: rgba(255, 255, 255, 0.92); backdrop-filter: blur(10px); padding: 15px 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        
        /* Hero banner container, text typography, circular image, and bottom SVG wave styles */
        .hero-banner { position: relative; background: #0b428f; border-radius: 16px; overflow: hidden; padding: 50px 40px; margin-bottom: 30px; color: white; box-shadow: 0 10px 25px rgba(0,0,0,0.3); min-height: 280px; display: flex; align-items: center; border: 1px solid rgba(255,255,255,0.1); }
        .hero-content { position: relative; z-index: 3; max-width: 60%; }
        .hero-content h2 { font-weight: 800; font-size: 2.4rem; margin-bottom: 10px; letter-spacing: -0.5px; }
        .hero-content p { font-size: 1.1rem; opacity: 0.95; margin-bottom: 20px;}
        .hero-image { position: absolute; right: 8%; bottom: 30px; width: 220px; height: 220px; object-fit: cover; border-radius: 50%; border: 6px solid white; z-index: 3; box-shadow: 0 10px 20px rgba(0,0,0,0.3); }
        .hero-curve { position: absolute; bottom: -5px; left: 0; width: 100%; line-height: 0; z-index: 1; }
        .hero-curve svg { display: block; width: 100%; height: 120px; }
        
        /* Quick-action dashboard cards with glassmorphism, hover lift effect, and circular icon badges */
        .dashboard-card { border: none; border-radius: 16px; background: rgba(255, 255, 255, 0.95); box-shadow: 0 8px 25px rgba(0,0,0,0.2); transition: all 0.3s ease; text-align: center; padding: 30px 20px; height: 100%; display: flex; flex-direction: column; backdrop-filter: blur(5px); }
        .dashboard-card:hover { transform: translateY(-8px); box-shadow: 0 15px 35px rgba(0,0,0,0.3); background: #ffffff; }
        .card-icon { width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 30px; margin: 0 auto 20px auto; }
        /* Color themes for dashboard card icons */
        .icon-blue { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }
        .icon-purple { background: rgba(139, 92, 246, 0.1); color: #8b5cf6; }
        .icon-green { background: rgba(16, 185, 129, 0.1); color: #10b981; }
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
        <!-- Top Header Bar displaying Welcome Message and Formatted Current Date -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Welcome back, <%=name%> </h5>
            <div class="fw-semibold text-muted"><i class="bi bi-calendar-event me-2"></i><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %></div>
        </div>

        <!-- Hero Banner Section -->
        <div class="hero-banner">
            <div class="hero-content">
                <h2>The ultimate tool to advance your career</h2>
                <p>Access premium job listings, track applications, and secure your professional future with the Career Link portal.</p>
                <div class="mt-3">
                    <span class="badge bg-light text-dark me-2 p-2 px-3 rounded-pill shadow-sm">#HiredForSuccess</span>
                    <span class="badge bg-warning text-dark p-2 px-3 rounded-pill shadow-sm">A.Y. 2026-27</span>
                </div>
            </div>
            <!-- Circular Hero Image (hidden on smaller screens) -->
            <img src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=600&auto=format&fit=crop" class="hero-image d-none d-lg-block" alt="Candidate Working">
            <!-- Decorative Yellow SVG Wave at the bottom of the banner -->
            <div class="hero-curve">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="#ffc107" fill-opacity="1" d="M0,224L60,213.3C120,203,240,181,360,186.7C480,192,600,213,720,202.7C840,192,960,149,1080,138.7C1200,128,1320,149,1380,160L1440,171L1440,320L1380,320C1320,320,1200,320,1080,320C960,320,840,320,720,320C600,320,480,320,360,320C240,320,120,320,60,320L0,320Z"></path></svg>
            </div>
        </div>

        <% // Display a prominent warning alert banner if the candidate's profile or resume is incomplete %>
        <% if(!isProfileComplete) { %>
        <div class="alert alert-danger shadow-lg border-0 d-flex align-items-center mb-4 p-4 rounded-4" style="background: rgba(255,255,255,0.95); border-left: 5px solid #ef4444 !important; backdrop-filter: blur(5px);">
            <div class="icon-circle bg-danger text-white rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 40px; height: 40px;"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <div>
                <h6 class="fw-bold mb-1 text-dark">Action Required: Complete Profile & Upload Resume</h6>
                <p class="mb-0 text-muted" style="font-size: 14px;">Your profile is incomplete. You must <b>update your skills</b> and <b>upload your resume</b> before you can apply for any jobs.</p>
            </div>
        </div>
        <% } %>

        <!-- Quick-Action Feature Cards Row -->
        <div class="row g-4 mb-4">
            <!-- Card 1: Find / Search Jobs -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <div class="card-icon icon-blue"><i class="bi bi-search"></i></div>
                    <h5 class="fw-bold text-dark">Find Jobs</h5>
                    <p class="text-muted small mb-4">Browse and filter active vacancies from verified companies.</p>
                    <a href="search_jobs.jsp" class="btn btn-primary rounded-pill mt-auto fw-bold">Search Now</a>
                </div>
            </div>
            <!-- Card 2: View Submitted Applications -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <div class="card-icon icon-purple"><i class="bi bi-file-earmark-person"></i></div>
                    <h5 class="fw-bold text-dark">Applications</h5>
                    <p class="text-muted small mb-4">Track the current screening status of your submissions.</p>
                    <a href="my_applications.jsp" class="btn btn-outline-primary rounded-pill mt-auto fw-bold">View Status</a>
                </div>
            </div>
            <!-- Card 3: View Scheduled Interviews -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <div class="card-icon icon-green"><i class="bi bi-calendar-event"></i></div>
                    <h5 class="fw-bold text-dark">Interviews</h5>
                    <p class="text-muted small mb-4">Check scheduled dates and meeting links for roles.</p>
                    <a href="interview_status.jsp" class="btn btn-outline-primary rounded-pill mt-auto fw-bold">View Schedule</a>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>