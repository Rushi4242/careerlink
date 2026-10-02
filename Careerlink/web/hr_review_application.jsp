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
// Retrieve the target application ID from the URL parameter and initialize state variables
String appId = request.getParameter("appid");
String message = "";
String email = session.getAttribute("user").toString();
// Establish a connection to the MySQL database and set a fallback HR display name
Connection con = DBConnection.getConnection();
String hrName = "HR";

// Query the users table to fetch the logged-in HR manager's full name
PreparedStatement hrPs = con.prepareStatement("SELECT full_name FROM users WHERE email=?");
hrPs.setString(1, email);
ResultSet hrRs = hrPs.executeQuery();
if(hrRs.next()) hrName = hrRs.getString("full_name");

// Handle Form Submission: Process the HR manager's evaluation decision when submitted via POST
if(request.getMethod().equalsIgnoreCase("POST")) {
    // Retrieve the selected decision status ('Shortlisted' or 'Rejected')
    String actionStatus = request.getParameter("status"); 
    try {
        // Case 1: If the candidate is rejected, update the application status and return to the applications list
        if(actionStatus.equals("Rejected")) {
            con.prepareStatement("UPDATE applications SET status='Rejected' WHERE application_id=" + appId).executeUpdate();
            response.sendRedirect("hr_view_applications.jsp"); return;
        // Case 2: If the candidate is shortlisted, capture the interview schedule details from the form
        } else if(actionStatus.equals("Shortlisted")) {
            String iDate = request.getParameter("interview_date"); String iTime = request.getParameter("interview_time"); String iMode = request.getParameter("interview_mode");
            // Check if an interview record already exists for this application to prevent duplicate entries
            PreparedStatement checkInt = con.prepareStatement("SELECT interview_id FROM interview WHERE application_id=?");
            checkInt.setString(1, appId);
            if(!checkInt.executeQuery().next()) {
                // Update the application status to 'Shortlisted'
                con.prepareStatement("UPDATE applications SET status='Shortlisted' WHERE application_id=" + appId).executeUpdate();
                // Insert the new interview schedule into the 'interview' table with status 'Scheduled'
                PreparedStatement insertPs = con.prepareStatement("INSERT INTO interview(application_id, interview_date, interview_time, interview_mode, status) VALUES (?, ?, ?, ?, 'Scheduled')");
                insertPs.setString(1, appId); insertPs.setString(2, iDate); insertPs.setString(3, iTime); insertPs.setString(4, iMode); insertPs.executeUpdate();
            }
            // Redirect back to the HR applications overview page after scheduling
            response.sendRedirect("hr_view_applications.jsp"); return;
        }
    } catch(Exception e) { message = "<div class='alert alert-danger shadow-sm'><i class='bi bi-exclamation-triangle-fill me-2'></i>System Error: " + e.getMessage() + "</div>"; }
}

// Prepare a SQL query joining applications, users, jobs, and resume (LEFT JOIN in case no resume exists) for this specific application
PreparedStatement ps = con.prepareStatement(
    "SELECT u.full_name, u.email, u.mobile, u.education, u.skills, u.experience, j.job_title, a.status, r.resume_file " +
    "FROM applications a " +
    "JOIN users u ON a.user_id = u.user_id " +
    "JOIN jobs j ON a.job_id = j.job_id " +
    "LEFT JOIN resume r ON u.user_id = r.user_id " +
    "WHERE a.application_id = ?"
);
ps.setString(1, appId);
// Execute the query to retrieve the candidate's full application and profile details
ResultSet rs = ps.executeQuery();

// Capture the current request URI to dynamically highlight the active sidebar link
String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Review Application | HR</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and UI styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script>
        // JavaScript function to dynamically show/hide and require/unrequire interview fields based on dropdown selection
        function toggleInterviewFields() {
            var status = document.getElementById("statusSelect").value;
            var interviewBox = document.getElementById("interviewBox");
            // Show the interview scheduling fields and make them mandatory if 'Shortlisted' is chosen
            if (status === "Shortlisted") { interviewBox.style.display = "block"; document.getElementById("iDate").required = true; document.getElementById("iTime").required = true; document.getElementById("iMode").required = true; } 
            // Hide the interview fields and remove the required constraint if 'Rejected' is chosen
            else { interviewBox.style.display = "none"; document.getElementById("iDate").required = false; document.getElementById("iTime").required = false; document.getElementById("iMode").required = false; }
        }
    </script>
    <style>
        /* Global page background color, font family, and horizontal overflow prevention */
        body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        /* Flex container to align the sidebar and main content area side-by-side */
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        
        /* Light Blue & Purple Sidebar Styles */
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

        /* Main content container expanding to fill remaining horizontal space */
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        /* Top navigation bar card styling */
        .top-navbar { background: #fff; padding: 20px 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-radius: 8px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        /* Centered white card container for the candidate evaluation view */
        .review-card { background: white; border-radius: 8px; padding: 35px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); max-width: 700px; margin: 0 auto; }
        /* Typography styles for candidate attribute labels and values */
        .data-label { color: #6c757d; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 3px; }
        .data-value { font-size: 15px; font-weight: 600; color: #212529; margin-bottom: 15px; }
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
        <!-- Navigation Links: Keeps 'Applications' highlighted while reviewing an individual application -->
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="hr_dashboard.jsp" class="<%= currentPageURI.contains("hr_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> HR Dashboard</a></li>
            <li><a href="post_job.jsp" class="<%= currentPageURI.contains("post_job.jsp") ? "active" : "" %>"><i class="bi bi-plus-circle-fill"></i> Post New Job</a></li>
            <li><a href="hr_manage_jobs.jsp" class="<%= currentPageURI.contains("hr_manage_jobs.jsp") ? "active" : "" %>"><i class="bi bi-gear-fill"></i> Manage Jobs</a></li>
            <li><a href="hr_view_applications.jsp" class="active"><i class="bi bi-file-earmark-person-fill"></i> Applications</a></li>
        </ul>
        <!-- Logout Button -->
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <!-- Main Content Section -->
    <div class="content">
        <!-- Top Header Bar displaying Page Title and Logged-in HR Manager's Name -->
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Evaluate Candidate</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=hrName%></div>
        </div>

        <!-- Candidate Review Card -->
        <div class="review-card">
            <!-- Display any system error messages if thrown during form processing -->
            <%=message%>
            <% // Check if the application record exists in the ResultSet and extract the resume filename %>
            <% if(rs.next()) { 
                String resumeFile = rs.getString("resume_file");
            %>
                <!-- Candidate Header: Displays Candidate Name, Applied Job Title -->
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                    <div>
                        <h4 class="fw-bold text-dark mb-1"><%=rs.getString("full_name")%></h4>
                        <div class="text-primary fw-bold">Applied for: <%=rs.getString("job_title")%></div>
                    </div>
                </div>

                <!-- Candidate Profile Details Grid (Email, Mobile, Education, Experience, Technical Skills) -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="data-label"><i class="bi bi-envelope me-1"></i>Email</div>
                        <div class="data-value"><%=rs.getString("email")%></div>
                    </div>
                    <div class="col-md-6">
                        <div class="data-label"><i class="bi bi-phone me-1"></i>Mobile</div>
                        <div class="data-value"><%=rs.getString("mobile") != null ? rs.getString("mobile") : "N/A"%></div>
                    </div>
                    <div class="col-md-6">
                        <div class="data-label"><i class="bi bi-mortarboard me-1"></i>Education</div>
                        <div class="data-value"><%=rs.getString("education") != null ? rs.getString("education") : "Not Provided"%></div>
                    </div>
                    <div class="col-md-6">
                        <div class="data-label"><i class="bi bi-briefcase me-1"></i>Experience</div>
                        <div class="data-value"><%=rs.getString("experience") != null ? rs.getString("experience") : "Not Provided"%></div>
                    </div>
                    <div class="col-12">
                        <div class="data-label"><i class="bi bi-code-slash me-1"></i>Technical Skills</div>
                        <div class="data-value"><%=rs.getString("skills") != null ? rs.getString("skills") : "Not Provided"%></div>
                    </div>
                </div>

                <!-- Candidate Resume Section: Provides a button to open/download the uploaded resume in a new tab -->
                <div class="p-3 mb-4 rounded-3" style="background: #f8f9fa; border: 1px dashed #dee2e6;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="fw-bold text-dark"><i class="bi bi-file-earmark-pdf-fill text-danger me-2"></i>Candidate Resume</div>
                            <small class="text-muted"><%=resumeFile != null ? resumeFile : "No document uploaded"%></small>
                        </div>
                        <% if(resumeFile != null) { %>
                            <a href="uploaded_resumes/<%=resumeFile%>" target="_blank" class="btn btn-sm btn-primary rounded-pill px-3 fw-bold">View Document</a>
                        <% } else { %>
                            <span class="badge bg-secondary">Unavailable</span>
                        <% } %>
                    </div>
                </div>

                <!-- Evaluation Decision Form -->
                <form method="post">
                    <!-- Final Decision Dropdown: Triggers toggleInterviewFields() on change -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-dark">Final Decision</label>
                        <select name="status" id="statusSelect" class="form-select form-select-lg" onchange="toggleInterviewFields()" required>
                            <option value="" disabled selected>-- Choose Action --</option>
                            <option value="Shortlisted"> Shortlist & Schedule Interview</option>
                            <option value="Rejected"> Reject Candidate</option>
                        </select>
                    </div>

                    <!-- Hidden Interview Scheduling Box: Displayed dynamically when 'Shortlisted' is selected -->
                    <div id="interviewBox" style="display:none; background: #f8f9fa; padding: 20px; border-radius: 8px; border: 1px solid #dee2e6; margin-bottom: 25px;">
                        <h6 class="text-primary fw-bold mb-3"><i class="bi bi-calendar-plus me-2"></i>Schedule Details</h6>
                        <div class="row">
                            <!-- Interview Date Picker -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-bold" style="font-size: 13px;">Date</label>
                                <input type="date" name="interview_date" id="iDate" class="form-control">
                            </div>
                            <!-- Interview Time Picker -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-bold" style="font-size: 13px;">Time</label>
                                <input type="time" name="interview_time" id="iTime" class="form-control">
                            </div>
                            <!-- Interview Mode Selector -->
                            <div class="col-12">
                                <label class="form-label text-muted fw-bold" style="font-size: 13px;">Mode</label>
                                <select name="interview_mode" id="iMode" class="form-select">
                                    <option value="">Select format...</option>
                                    <option value="Online">Online (Video Call)</option>
                                    <option value="Offline">Offline (In-Office)</option>
                                    <option value="Phone Call">Phone Call</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Form Submit and Cancel Buttons -->
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-pill mb-3">Submit Decision</button>
                    <a href="hr_view_applications.jsp" class="btn btn-light border w-100 py-2 rounded-pill text-dark fw-bold">Cancel</a>
                </form>
            <% // If no matching application record was found for the provided appid, show an error alert %>
            <% } else { %>
                <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill me-2"></i>Application not found!</div>
            <% } %>
        </div>
    </div>
</div>
<!-- Include Bootstrap 5 JavaScript Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>