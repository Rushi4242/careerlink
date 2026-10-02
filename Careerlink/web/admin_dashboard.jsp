<%
// Session Validation: Check if a user is logged in and holds the "Admin" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Admin")) {
    // Redirect unauthorized or unauthenticated users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL classes for database operations and the custom DBConnection utility --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
// Retrieve the logged-in Admin's email address from the active session
String email=session.getAttribute("user").toString();
// Establish a connection to the MySQL database
Connection con=DBConnection.getConnection();
// Set a default fallback display name for the Admin
String adminName="Admin";

// Prepare and execute a SQL query to fetch the Admin's full name using their email
PreparedStatement userPs=con.prepareStatement("SELECT full_name FROM users WHERE email=?");
userPs.setString(1,email);
ResultSet userRs=userPs.executeQuery();
// If a matching user record is found, update the adminName variable
if(userRs.next()) adminName=userRs.getString("full_name");

// Initialize counter variables for platform-wide statistics
int totalUsers=0, totalJobs=0, totalApps=0, totalInt=0;
// Execute COUNT queries to get total registered users, jobs, applications, and scheduled interviews
ResultSet rs1=con.prepareStatement("SELECT COUNT(*) FROM users").executeQuery(); if(rs1.next()) totalUsers=rs1.getInt(1);
ResultSet rs2=con.prepareStatement("SELECT COUNT(*) FROM jobs").executeQuery(); if(rs2.next()) totalJobs=rs2.getInt(1);
ResultSet rs3=con.prepareStatement("SELECT COUNT(*) FROM applications").executeQuery(); if(rs3.next()) totalApps=rs3.getInt(1);
ResultSet rs4=con.prepareStatement("SELECT COUNT(*) FROM interview").executeQuery(); if(rs4.next()) totalInt=rs4.getInt(1);

// Dynamically get the current page to highlight the correct sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Portal | Career Link</title>
    <!-- Include Bootstrap 5 CSS for responsive grid and UI components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Full-screen fixed background image with a dark translucent gradient overlay */
        body { 
            background: linear-gradient(rgba(10, 15, 30, 0.85), rgba(10, 15, 30, 0.85)), 
                        url('https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=1920&auto=format&fit=crop');
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
           LIGHT BLUE & PURPLE SIDEBAR STYLES
           ------------------------------------------------------------------- */
        /* Fixed-width sticky vertical sidebar container */
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        /* Purple header box at the top of the sidebar */
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        /* Sidebar brand heading styling */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        /* Subtitle text color override */
        .sidebar-header .text-light { color: #f8f9fa !important; }
        /* Downward-pointing purple triangle caret below the sidebar header */
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        /* Reset default list margins and padding */
        .sidebar ul { margin: 0; padding: 0; }
        /* White horizontal divider line between sidebar links */
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
        /* Default styling for the outline danger logout button */
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        /* Hover state styling for the logout button */
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }
        
        /* Main content container with transparent background to show body wallpaper */
        .content { width: 100%; padding: 30px; background: transparent; flex-grow: 1; }
        
        /* Glassmorphism top navigation bar */
        .top-navbar { background: rgba(255, 255, 255, 0.92); backdrop-filter: blur(10px); padding: 15px 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        
        /* Hero banner container with blue translucent background and blur effect */
        .hero-banner {
            position: relative;
            background: rgba(11, 66, 143, 0.95);
            backdrop-filter: blur(5px);
            border-radius: 16px;
            overflow: hidden;
            padding: 50px 40px;
            margin-bottom: 30px;
            color: white;
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
            min-height: 280px;
            display: flex;
            align-items: center;
            border: 1px solid rgba(255,255,255,0.1);
        }
        /* Text container inside the hero banner */
        .hero-content { position: relative; z-index: 3; max-width: 60%; }
        /* Hero banner main heading typography */
        .hero-content h2 { font-weight: 800; font-size: 2.4rem; margin-bottom: 10px; letter-spacing: -0.5px; }
        /* Hero banner subtitle paragraph styling */
        .hero-content p { font-size: 1.1rem; opacity: 0.95; margin-bottom: 20px;}
        
        /* Circular decorative image positioned on the right side of the hero banner */
        .hero-image {
            position: absolute;
            right: 8%;
            bottom: 30px;
            width: 220px;
            height: 220px;
            object-fit: cover;
            border-radius: 50%;
            border: 6px solid white;
            z-index: 3;
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275), box-shadow 0.4s ease;
            cursor: pointer;
        }
        /* Interactive scale and tilt animation when hovering over the hero image */
        .hero-image:hover {
            transform: scale(1.08) rotate(-3deg);
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }
        
        /* Container for the decorative SVG wave at the bottom of the hero banner */
        .hero-curve { position: absolute; bottom: -5px; left: 0; width: 100%; line-height: 0; z-index: 1; }
        .hero-curve svg { display: block; width: 100%; height: 120px; }

        /* Glassmorphism statistic card styling */
        .stat-card { 
            border: none; 
            border-radius: 16px; 
            background: rgba(255, 255, 255, 0.95); 
            box-shadow: 0 8px 25px rgba(0,0,0,0.2); 
            transition: all 0.3s ease; 
            padding: 25px; 
            display: flex; 
            align-items: center; 
            backdrop-filter: blur(5px);
        }
        /* Lift effect when hovering over a statistic card */
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(0,0,0,0.3); background: #ffffff; }
        /* Rounded square icon container inside each statistic card */
        .stat-icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 28px; margin-right: 20px; }
        /* Large bold numeric display for statistics */
        .stat-number { font-size: 28px; font-weight: 800; color: #111827; line-height: 1; margin-bottom: 5px; }
        
        /* Color utility classes for stat card icons (Blue, Green, Yellow, Red) */
        .bg-blue-light { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }
        .bg-green-light { background: rgba(16, 185, 129, 0.1); color: #10b981; }
        .bg-yellow-light { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
        .bg-red-light { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
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
        <ul class="list-unstyled mt-3 flex-grow-1">
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
        <!-- Top Header Bar displaying Dashboard Title and Logged-in Admin's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Administrative Dashboard</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=adminName%></div>
        </div>

        <!-- Hero Welcome Banner -->
        <div class="hero-banner">
            <div class="hero-content">
                <h2>Platform Command Center</h2>
                <p>Monitor system health, manage registered users, and verify corporate job listings to ensure a secure recruitment ecosystem.</p>
                <div class="mt-3">
                    <span class="badge bg-light text-dark me-2 p-2 px-3 rounded-pill shadow-sm">#AdminControl</span>
                    <span class="badge bg-warning text-dark p-2 px-3 rounded-pill shadow-sm">Secure Portal</span>
                </div>
            </div>
            
            <!-- Circular Hero Image (hidden on small screens) -->
            <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=600&auto=format&fit=crop" class="hero-image d-none d-lg-block" alt="Data Analytics">
            
            <!-- Decorative Yellow Wave SVG at the bottom of the banner -->
            <div class="hero-curve">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="#ffc107" fill-opacity="1" d="M0,224L60,213.3C120,203,240,181,360,186.7C480,192,600,213,720,202.7C840,192,960,149,1080,138.7C1200,128,1320,149,1380,160L1440,171L1440,320L1380,320C1320,320,1200,320,1080,320C960,320,840,320,720,320C600,320,480,320,360,320C240,320,120,320,60,320L0,320Z"></path></svg>
            </div>
        </div>

        <!-- System Overview Statistic Cards Row -->
        <div class="row g-4 mb-4">
            <!-- Total Users Card -->
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-blue-light"><i class="bi bi-people-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalUsers%></div>
                        <div class="text-muted small fw-bold text-uppercase">Total Users</div>
                    </div>
                </div>
            </div>
            <!-- Active Jobs Card -->
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-green-light"><i class="bi bi-briefcase-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalJobs%></div>
                        <div class="text-muted small fw-bold text-uppercase">Active Jobs</div>
                    </div>
                </div>
            </div>
            <!-- Total Applications Card -->
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-yellow-light"><i class="bi bi-file-earmark-text-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalApps%></div>
                        <div class="text-muted small fw-bold text-uppercase">Applications</div>
                    </div>
                </div>
            </div>
            <!-- Total Interviews Card -->
            <div class="col-md-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-red-light"><i class="bi bi-calendar-event-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalInt%></div>
                        <div class="text-muted small fw-bold text-uppercase">Interviews</div>
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