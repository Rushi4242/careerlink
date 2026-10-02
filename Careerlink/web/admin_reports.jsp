<%
// Session Validation: Verify that a user is logged in and holds the "Admin" role
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("Admin")) {
    // Redirect unauthorized or unauthenticated users back to the login page
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import Java SQL package for database queries and the custom DBConnection utility class --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>

<%
// Retrieve the logged-in Admin's email from the current session and set a fallback display name
String email = session.getAttribute("user").toString();
String adminName = "Admin";

// Establish a connection to the MySQL database and query the Admin's full name
Connection con = DBConnection.getConnection();
PreparedStatement userPs = con.prepareStatement("SELECT full_name FROM users WHERE email=?");
userPs.setString(1, email);
ResultSet userRs = userPs.executeQuery();
// If a matching record is found, update the adminName variable
if(userRs.next()) adminName = userRs.getString("full_name");

// Fetching Specific Report Analytics as per Project Synopsis
// Initialize counters for user demographics, job postings, and application status breakdowns
int totalCandidates = 0, totalHR = 0, totalJobs = 0, totalApplications = 0;
int pendingApps = 0, acceptedApps = 0, rejectedApps = 0;

// Query the total number of registered Candidates
ResultSet rsCand = con.prepareStatement("SELECT COUNT(*) FROM users WHERE role='Candidate'").executeQuery(); 
if(rsCand.next()) totalCandidates = rsCand.getInt(1);

// Query the total number of registered HR / Employers
ResultSet rsHR = con.prepareStatement("SELECT COUNT(*) FROM users WHERE role='HR'").executeQuery(); 
if(rsHR.next()) totalHR = rsHR.getInt(1);

// Query the total number of job postings across the platform
ResultSet rsJobs = con.prepareStatement("SELECT COUNT(*) FROM jobs").executeQuery(); 
if(rsJobs.next()) totalJobs = rsJobs.getInt(1);

// Query the total number of job applications submitted
ResultSet rsApps = con.prepareStatement("SELECT COUNT(*) FROM applications").executeQuery(); 
if(rsApps.next()) totalApplications = rsApps.getInt(1);

// Application Status Breakdown
// Group applications by their status to count Pending, Accepted/Selected, and Rejected submissions
ResultSet rsStatus = con.prepareStatement("SELECT status, COUNT(*) FROM applications GROUP BY status").executeQuery();
while(rsStatus.next()) {
    String status = rsStatus.getString(1);
    int count = rsStatus.getInt(2);
    // Assign the count to the corresponding status counter variable
    if(status.equalsIgnoreCase("Pending")) pendingApps = count;
    else if(status.equalsIgnoreCase("Accepted") || status.equalsIgnoreCase("Selected")) acceptedApps = count;
    else if(status.equalsIgnoreCase("Rejected")) rejectedApps = count;
}

// Calculate Percentages for Demographics and Application Statuses
int totalUsers = totalCandidates + totalHR;
String candPct = totalUsers > 0 ? String.format("%.1f", (totalCandidates * 100.0) / totalUsers) : "0.0";
String hrPct = totalUsers > 0 ? String.format("%.1f", (totalHR * 100.0) / totalUsers) : "0.0";

String pendingPct = totalApplications > 0 ? String.format("%.1f", (pendingApps * 100.0) / totalApplications) : "0.0";
String acceptedPct = totalApplications > 0 ? String.format("%.1f", (acceptedApps * 100.0) / totalApplications) : "0.0";
String rejectedPct = totalApplications > 0 ? String.format("%.1f", (rejectedApps * 100.0) / totalApplications) : "0.0";

// Dynamically get the current page to highlight the correct sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>System Reports | Career Link Admin</title>
    <!-- Include Bootstrap 5 CSS for responsive grid layout and UI styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { 
            background: #f4f7f6;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            overflow-x: hidden; 
        }
        
        /* Flex container to align the sidebar and main content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* -------------------------------------------------------------------
           LIGHT BLUE & PURPLE SIDEBAR STYLES
           ------------------------------------------------------------------- */
        /* Fixed-width sticky vertical sidebar with a light blue background */
        .sidebar { 
            min-width: 260px; 
            max-width: 260px; 
            background: #dae6f2; 
            transition: all 0.3s; 
            z-index: 10; 
            display: flex; 
            flex-direction: column; 
            position: sticky; 
            top: 0; 
            height: 100vh; 
            box-shadow: 2px 0 15px rgba(0,0,0,0.1);
        }
        
        /* Purple header box at the top of the sidebar */
        .sidebar-header { 
            padding: 25px; 
            background: #655b8e; 
            text-align: center; 
            color: #ffffff;
            position: relative;
            margin-bottom: 10px; 
        }
        
        /* Sidebar brand heading and subtitle text styling */
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        .sidebar-header .text-light { color: #f8f9fa !important; }

        /* Downward-pointing purple triangle indicator positioned below the sidebar header */
        .sidebar-header::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 25px; 
            width: 0; 
            height: 0; 
            border-left: 10px solid transparent;
            border-right: 10px solid transparent;
            border-top: 10px solid #655b8e; 
            z-index: 10;
        }

        /* Reset list margins/padding and add a white bottom border between menu items */
        .sidebar ul { margin: 0; padding: 0; }
        .sidebar ul li { border-bottom: 1px solid #ffffff; }

        /* Default styling for sidebar navigation links */
        .sidebar ul li a { 
            padding: 15px 25px; 
            font-size: 15px; 
            display: block; 
            background-color: #dae6f2; 
            color: #0d2857; 
            text-decoration: none; 
            transition: 0.3s; 
            font-weight: 500; 
        }

        /* Hover effect for sidebar navigation links */
        .sidebar ul li a:hover { background-color: #c4d6ea; }

        /* Active state styling (dark navy background with white text) for the current page */
        .sidebar ul li a.active { 
            background-color: #2c2560; 
            color: #ffffff; 
        }
        
        /* Icon spacing and sizing inside sidebar links */
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }

        /* Bottom container pushing the logout button to the base of the sidebar */
        .sidebar .p-3 {
            background-color: #dae6f2;
            margin-top: auto;
        }

        /* Default and hover styles for the outline danger logout button */
        .sidebar .btn-outline-danger {
            background-color: #ffffff;
            font-weight: bold;
            border: 1px solid #ef4444; 
            color: #ef4444;
        }
        .sidebar .btn-outline-danger:hover {
            background-color: #ef4444; 
            color: #ffffff;
        }
        
        /* -------------------------------------------------------------------
           CONTENT AREA STYLES 
           ------------------------------------------------------------------- */
        /* Main content container expanding to fill remaining horizontal space */
        .content { width: 100%; padding: 30px; background: transparent; flex-grow: 1; }
        
        /* Top navigation bar card styling */
        .top-navbar { 
            background: #ffffff; 
            padding: 15px 30px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.05); 
            border-radius: 12px; 
            margin-bottom: 30px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
        }
        
        /* Analytics report card container styling */
        .report-card { 
            border: none; 
            border-radius: 12px; 
            background: #fff; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.03); 
            transition: all 0.3s ease; 
            padding: 25px; 
            display: flex; 
            align-items: center; 
        }
        /* Upward lift animation when hovering over a report card */
        .report-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); }
        /* Rounded square icon box inside each report card */
        .stat-icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 28px; margin-right: 20px; }
        /* Large bold number styling for metric counts */
        .stat-number { font-size: 28px; font-weight: 800; color: #111827; line-height: 1; margin-bottom: 5px; }
        
        /* Soft background and text color utility classes for report card icons */
        .bg-primary-light { background: rgba(13, 110, 253, 0.1); color: #0d6efd; }
        .bg-purple-light { background: rgba(111, 66, 193, 0.1); color: #6f42c1; }
        .bg-success-light { background: rgba(25, 135, 84, 0.1); color: #198754; }
        .bg-danger-light { background: rgba(220, 53, 69, 0.1); color: #dc3545; }
        .bg-warning-light { background: rgba(255, 193, 7, 0.1); color: #ffc107; }
        .bg-info-light { background: rgba(13, 202, 240, 0.1); color: #0dcaf0; }

        /* Custom styling for chart containers to ensure they don't over-expand */
        .chart-container {
            position: relative;
            height: 280px;
            width: 100%;
            display: flex;
            justify-content: center;
        }
        /* Styling for the inline percentage badges inside the cards */
        .pct-badge {
            font-size: 14px;
            font-weight: 600;
            margin-left: 8px;
            padding: 3px 8px;
            border-radius: 20px;
            background: #f8f9fa;
        }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar Navigation Menu -->
    <nav class="sidebar">
        <!-- Sidebar Brand Header -->
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-shield-lock-fill text-warning me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">Admin Portal</div>
        </div>
        
        <!-- ADMIN SIDEBAR LINKS -->
        <!-- Uses currentPageURI to dynamically apply the 'active' class to the current page link -->
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

    <!-- Main Content Section -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in Admin's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">System Analytics & Reports</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=adminName%></div>
        </div>

        <!-- Section 1: User Demographics Breakdown -->
        <h6 class="fw-bold text-secondary mb-3 text-uppercase" style="letter-spacing: 1px;">User Demographics</h6>
        <div class="row g-4 mb-5">
            <!-- Total Candidates Card -->
            <div class="col-md-4">
                <div class="report-card border-bottom border-primary border-4">
                    <div class="stat-icon bg-primary-light"><i class="bi bi-person-badge-fill"></i></div>
                    <div>
                        <!-- Added Percentage text next to the raw count -->
                        <div class="stat-number d-flex align-items-center"><%=totalCandidates%> <span class="pct-badge text-primary"><%=candPct%>%</span></div>
                        <div class="text-muted small fw-bold text-uppercase">Total Candidates</div>
                    </div>
                </div>
            </div>
            <!-- Registered HR / Employers Card -->
            <div class="col-md-4">
                <div class="report-card border-bottom border-purple border-4" style="border-color: #6f42c1 !important;">
                    <div class="stat-icon bg-purple-light"><i class="bi bi-building-fill-gear"></i></div>
                    <div>
                        <!-- Added Percentage text next to the raw count -->
                        <div class="stat-number d-flex align-items-center"><%=totalHR%> <span class="pct-badge text-purple" style="color: #6f42c1;"><%=hrPct%>%</span></div>
                        <div class="text-muted small fw-bold text-uppercase">Registered HR / Employers</div>
                    </div>
                </div>
            </div>
            <!-- Total Job Postings Card -->
            <div class="col-md-4">
                <div class="report-card border-bottom border-info border-4">
                    <div class="stat-icon bg-info-light"><i class="bi bi-briefcase-fill"></i></div>
                    <div>
                        <div class="stat-number"><%=totalJobs%></div>
                        <div class="text-muted small fw-bold text-uppercase">Total Job Postings</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section 2: Application Processing Tracking Breakdown -->
        <h6 class="fw-bold text-secondary mb-3 text-uppercase" style="letter-spacing: 1px;">Application Processing Tracking</h6>
        <div class="row g-4 mb-5">
            <!-- Total Application Submissions Card -->
            <div class="col-md-3">
                <div class="report-card">
                    <div class="stat-icon bg-primary-light"><i class="bi bi-files"></i></div>
                    <div>
                        <div class="stat-number"><%=totalApplications%></div>
                        <div class="text-muted small fw-bold text-uppercase">Total Submissions</div>
                    </div>
                </div>
            </div>
            <!-- Pending Review Applications Card -->
            <div class="col-md-3">
                <div class="report-card">
                    <div class="stat-icon bg-warning-light"><i class="bi bi-hourglass-split"></i></div>
                    <div>
                        <!-- Added Percentage text next to the raw count -->
                        <div class="stat-number d-flex align-items-center"><%=pendingApps%> <span class="pct-badge text-warning"><%=pendingPct%>%</span></div>
                        <div class="text-muted small fw-bold text-uppercase">Pending Review</div>
                    </div>
                </div>
            </div>
            <!-- Accepted / Selected Applications Card -->
            <div class="col-md-3">
                <div class="report-card">
                    <div class="stat-icon bg-success-light"><i class="bi bi-check-circle-fill"></i></div>
                    <div>
                        <!-- Added Percentage text next to the raw count -->
                        <div class="stat-number d-flex align-items-center"><%=acceptedApps%> <span class="pct-badge text-success"><%=acceptedPct%>%</span></div>
                        <div class="text-muted small fw-bold text-uppercase">Accepted / Selected</div>
                    </div>
                </div>
            </div>
            <!-- Rejected Applications Card -->
            <div class="col-md-3">
                <div class="report-card">
                    <div class="stat-icon bg-danger-light"><i class="bi bi-x-circle-fill"></i></div>
                    <div>
                        <!-- Added Percentage text next to the raw count -->
                        <div class="stat-number d-flex align-items-center"><%=rejectedApps%> <span class="pct-badge text-danger"><%=rejectedPct%>%</span></div>
                        <div class="text-muted small fw-bold text-uppercase">Rejected Applications</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section 3: Visual Analytics (Chart.js Integration with Percentages) -->
        <h6 class="fw-bold text-secondary mb-3 text-uppercase" style="letter-spacing: 1px;">Visual Analytics</h6>
        <div class="row g-4 mb-4">
            <!-- User Demographics Pie Chart -->
            <div class="col-md-6">
                <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                    <h6 class="fw-bold text-center mb-3 text-dark">User Distribution</h6>
                    <div class="chart-container">
                        <canvas id="userDemographicsChart"></canvas>
                    </div>
                </div>
            </div>
            <!-- Application Status Doughnut Chart -->
            <div class="col-md-6">
                <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                    <h6 class="fw-bold text-center mb-3 text-dark">Application Status Overview</h6>
                    <div class="chart-container">
                        <canvas id="applicationStatusChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Section 4: Export / Print System Report Call-to-Action Card -->
        <div class="card border-0 shadow-sm mt-4 rounded-4 d-print-none">
            <div class="card-body p-4 text-center">
                <i class="bi bi-file-earmark-bar-graph text-muted mb-3" style="font-size: 40px;"></i>
                <h5 class="fw-bold">Export System Report</h5>
                <p class="text-muted small mb-4">Download a full comprehensive breakdown of all registered users, hiring activity, and application statuses.</p>
                <!-- Triggers the browser's native print/save-as-PDF dialog -->
                <button class="btn btn-primary rounded-pill px-4 fw-bold" onclick="window.print()"><i class="bi bi-printer-fill me-2"></i> Print Report</button>
            </div>
        </div>

    </div>
</div>

<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- Include Chart.js Library for Data Visualization -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    // Custom Tooltip function to automatically calculate and display percentages on chart hover
    const percentageTooltip = {
        callbacks: {
            label: function(context) {
                let label = context.label || '';
                if (label) {
                    label += ': ';
                }
                // Get the raw count value
                let value = context.raw;
                // Calculate total dynamically from dataset
                let total = context.chart._metasets[context.datasetIndex].total;
                let percentage = 0;
                if (total > 0) {
                    percentage = ((value / total) * 100).toFixed(1);
                }
                // Return string formatted as "Label: Value (Percentage%)"
                return label + value + ' (' + percentage + '%)';
            }
        }
    };

    // --------------------------------------------------------
    // Chart 1: User Demographics Pie Chart
    // --------------------------------------------------------
    const ctxUser = document.getElementById('userDemographicsChart').getContext('2d');
    new Chart(ctxUser, {
        type: 'pie',
        data: {
            // Append the Java-calculated percentage directly into the legend labels
            labels: ['Candidates (<%=candPct%>%)', 'HR / Employers (<%=hrPct%>%)'],
            datasets: [{
                // Pass Java raw count variables into the JavaScript array
                data: [<%=totalCandidates%>, <%=totalHR%>],
                // Colors matching the Bootstrap theme used in the stat cards (#0d6efd for Primary, #6f42c1 for Purple)
                backgroundColor: ['rgba(13, 110, 253, 0.85)', 'rgba(111, 66, 193, 0.85)'],
                borderColor: ['#ffffff', '#ffffff'],
                borderWidth: 2
            }]
        },
        options: { 
            responsive: true, 
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' },
                tooltip: percentageTooltip // Attach the custom percentage tooltip
            }
        }
    });

    // --------------------------------------------------------
    // Chart 2: Application Status Doughnut Chart
    // --------------------------------------------------------
    const ctxApp = document.getElementById('applicationStatusChart').getContext('2d');
    new Chart(ctxApp, {
        type: 'doughnut',
        data: {
            // Append the Java-calculated percentage directly into the legend labels
            labels: ['Pending (<%=pendingPct%>%)', 'Accepted (<%=acceptedPct%>%)', 'Rejected (<%=rejectedPct%>%)'],
            datasets: [{
                // Pass Java raw count variables into the JavaScript array
                data: [<%=pendingApps%>, <%=acceptedApps%>, <%=rejectedApps%>],
                // Colors matching the Bootstrap theme (Warning Yellow, Success Green, Danger Red)
                backgroundColor: ['rgba(255, 193, 7, 0.85)', 'rgba(25, 135, 84, 0.85)', 'rgba(220, 53, 69, 0.85)'],
                borderColor: ['#ffffff', '#ffffff', '#ffffff'],
                borderWidth: 2
            }]
        },
        options: { 
            responsive: true, 
            maintainAspectRatio: false,
            cutout: '60%', // Makes it a doughnut rather than a pie
            plugins: {
                legend: { position: 'bottom' },
                tooltip: percentageTooltip // Attach the custom percentage tooltip
            }
        }
    });
</script>
</body>
</html>