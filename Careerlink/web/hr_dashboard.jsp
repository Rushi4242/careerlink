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
// Initialize default fallback values for the HR user's name and ID
String hrName = "HR";
int hrId = 0; 

// Query the users table to fetch the logged-in HR manager's unique user_id and full_name
PreparedStatement userPs = con.prepareStatement("SELECT user_id, full_name FROM users WHERE email=?");
userPs.setString(1, email);
ResultSet userRs = userPs.executeQuery();
if(userRs.next()) { hrId = userRs.getInt("user_id"); hrName = userRs.getString("full_name"); }

// Initialize counter variables for HR-specific recruitment metrics
int totalJobs = 0, totalApplications = 0, totalInterviews = 0;
// Count the total number of jobs posted specifically by this HR user
PreparedStatement jobPs = con.prepareStatement("SELECT COUNT(*) FROM jobs WHERE posted_by = ?");
jobPs.setInt(1, hrId); ResultSet jobRs = jobPs.executeQuery(); if(jobRs.next()) totalJobs = jobRs.getInt(1);

// Count the total number of candidate applications submitted for jobs posted by this HR user
PreparedStatement appPs = con.prepareStatement("SELECT COUNT(a.application_id) FROM applications a JOIN jobs j ON a.job_id = j.job_id WHERE j.posted_by = ?");
appPs.setInt(1, hrId); ResultSet appRs = appPs.executeQuery(); if(appRs.next()) totalApplications = appRs.getInt(1);

// Count the total number of interviews scheduled for applications tied to this HR user's job postings
PreparedStatement interviewPs = con.prepareStatement("SELECT COUNT(i.interview_id) FROM interview i JOIN applications a ON i.application_id = a.application_id JOIN jobs j ON a.job_id = j.job_id WHERE j.posted_by = ?");
interviewPs.setInt(1, hrId); ResultSet interviewRs = interviewPs.executeQuery(); if(interviewRs.next()) totalInterviews = interviewRs.getInt(1);
// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HR Portal | Career Link</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and prebuilt UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Immersive HR corporate background */
        body { 
            background: linear-gradient(rgba(17, 24, 39, 0.75), rgba(17, 24, 39, 0.75)), 
                        url('https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1920&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            background-repeat: no-repeat;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            overflow-x: hidden; 
        }
        
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
        /* Default and hover styles for the outline danger logout button */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }
        
        /* Main content container with transparent background to reveal the body wallpaper */
        .content { width: 100%; padding: 30px; background: transparent; flex-grow: 1; }
        /* Glassmorphism top navigation bar */
        .top-navbar { background: rgba(255, 255, 255, 0.92); backdrop-filter: blur(10px); padding: 15px 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        
        /* Hero banner container, typography, interactive circular image, and bottom SVG wave styles */
        .hero-banner { position: relative; background: rgba(11, 66, 143, 0.95); backdrop-filter: blur(5px); border-radius: 16px; overflow: hidden; padding: 50px 40px; margin-bottom: 30px; color: white; box-shadow: 0 10px 25px rgba(0,0,0,0.3); min-height: 280px; display: flex; align-items: center; border: 1px solid rgba(255,255,255,0.1); }
        .hero-content { position: relative; z-index: 3; max-width: 60%; }
        .hero-content h2 { font-weight: 800; font-size: 2.4rem; margin-bottom: 10px; letter-spacing: -0.5px; }
        .hero-content p { font-size: 1.1rem; opacity: 0.95; margin-bottom: 20px;}
        .hero-image { position: absolute; right: 8%; bottom: 30px; width: 220px; height: 220px; object-fit: cover; border-radius: 50%; border: 6px solid white; z-index: 3; box-shadow: 0 10px 20px rgba(0,0,0,0.2); transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275), box-shadow 0.4s ease; cursor: pointer; }
        .hero-image:hover { transform: scale(1.08) rotate(3deg); box-shadow: 0 15px 30px rgba(0,0,0,0.3); }
        .hero-curve { position: absolute; bottom: -5px; left: 0; width: 100%; line-height: 0; z-index: 1; }
        .hero-curve svg { display: block; width: 100%; height: 120px; }

        /* Glassmorphism statistic cards with hover lift animation and icon box formatting */
        .stat-card { border: none; border-radius: 16px; background: rgba(255, 255, 255, 0.95); box-shadow: 0 8px 25px rgba(0,0,0,0.2); padding: 25px; display: flex; align-items: center; transition: all 0.3s ease; backdrop-filter: blur(5px); }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(0,0,0,0.3); background: #ffffff; }
        .stat-icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 28px; margin-right: 20px; }
        .stat-number { font-size: 28px; font-weight: 800; color: #111827; line-height: 1; margin-bottom: 5px; }
        
        /* Soft background and text color utility classes for stat card icons */
        .bg-blue-light { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }
        .bg-yellow-light { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
        .bg-green-light { background: rgba(16, 185, 129, 0.1); color: #10b981; }
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
        <!-- Logout Button Container -->
        <div class="p-3">
            <a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a>
        </div>
    </nav>

    <!-- Main Content Area -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in HR Manager's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Recruitment Overview</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=hrName%></div>
        </div>

        <!-- Hero Welcome Banner -->
        <div class="hero-banner">
            <div class="hero-content">
                <h2>Build Your Dream Team</h2>
                <p>Post new opportunities, review incoming AI-scored applications, and schedule candidate interviews effortlessly.</p>
                <div class="mt-3">
                    <span class="badge bg-light text-dark me-2 p-2 px-3 rounded-pill shadow-sm">#HiringTopTalent</span>
                    <span class="badge bg-warning text-dark p-2 px-3 rounded-pill shadow-sm">Employer Portal</span>
                </div>
            </div>
            
            <!-- Circular Hero Image (hidden on smaller screens) -->
            <img src="https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=800&auto=format&fit=crop" class="hero-image d-none d-lg-block" alt="Professional HR Team Collaborating">
            
            <!-- Decorative Yellow Wave SVG at the bottom of the banner -->
            <div class="hero-curve">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="#ffc107" fill-opacity="1" d="M0,224L60,213.3C120,203,240,181,360,186.7C480,192,600,213,720,202.7C840,192,960,149,1080,138.7C1200,128,1320,149,1380,160L1440,171L1440,320L1380,320C1320,320,1200,320,1080,320C960,320,840,320,720,320C600,320,480,320,360,320C240,320,120,320,60,320L0,320Z"></path></svg>
            </div>
        </div>

        <!-- Recruitment Statistics Cards Row -->
        <div class="row g-4 mb-4">
            <!-- Card 1: Total Active Jobs Posted by this HR -->
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon bg-blue-light"><i class="bi bi-briefcase-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalJobs%></div>
                        <div class="text-muted small fw-bold text-uppercase">Active Jobs</div>
                    </div>
                </div>
            </div>
            <!-- Card 2: Total Applications Received for this HR's Jobs -->
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon bg-yellow-light"><i class="bi bi-file-earmark-text-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalApplications%></div>
                        <div class="text-muted small fw-bold text-uppercase">Applications Received</div>
                    </div>
                </div>
            </div>
            <!-- Card 3: Total Interviews Scheduled for this HR's Jobs -->
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon bg-green-light"><i class="bi bi-calendar-event-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalInterviews%></div>
                        <div class="text-muted small fw-bold text-uppercase">Interviews Scheduled</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>