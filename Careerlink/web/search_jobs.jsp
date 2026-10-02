<%
// --------------------------------------------------------------------------------
// 1. SESSION VALIDATION & SECURITY
// --------------------------------------------------------------------------------
// Protect the page: Ensure the user is actively logged in and holds the 'Candidate' role.
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
// 2. CANDIDATE DATA RETRIEVAL & PROFILE VALIDATION
// --------------------------------------------------------------------------------
// Retrieve the candidate's email from the active session
String email = session.getAttribute("user").toString();
Connection con = DBConnection.getConnection();

// Initialize variables to store candidate information and track profile completeness
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
    
    // Check if the candidate has uploaded a physical resume document in the 'resume' table
    boolean hasResume = false;
    PreparedStatement psRes = con.prepareStatement("SELECT * FROM resume WHERE user_id=?");
    psRes.setInt(1, userId);
    if(psRes.executeQuery().next()) hasResume = true;
    
    // The profile is marked incomplete if ANY required text field is missing OR if the resume is missing
    if(mobile == null || mobile.trim().isEmpty() || edu == null || edu.trim().isEmpty() || skills == null || skills.trim().isEmpty() || exp == null || exp.trim().isEmpty() || !hasResume) {
        isProfileComplete = false;
    }
}

// --------------------------------------------------------------------------------
// 3. CAPTURE URL PARAMETERS
// --------------------------------------------------------------------------------
// Capture current page URI for the sidebar active-state logic
String currentPageURI = request.getRequestURI();
// Capture the search query string (if the user submitted the search form)
String keyword = request.getParameter("keyword");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Search Jobs | Candidate Portal</title>
    <!-- Include Bootstrap 5 CSS for UI grid and components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* Global page background and font setup */
        body { background: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
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
        
        /* --- MAIN CONTENT & SEARCH COMPONENTS STYLING --- */
        .content { width: 100%; padding: 30px; }
        .top-navbar { background: #fff; padding: 20px 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-radius: 8px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        
        /* Search Bar Styles */
        .search-card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .search-input { background: #f8f9fa; border: 1px solid #dee2e6; padding: 15px 20px; border-radius: 6px; }
        /* Focus effect for search input */
        .search-input:focus { border-color: #0d6efd; box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25); background: #fff; }
        .search-btn { padding: 12px 30px; font-weight: bold; border-radius: 6px; }
        
        /* Job Card Grid Styling */
        .job-card { border: 1px solid rgba(255,255,255,0.6); border-radius: 16px; background: #ffffff; padding: 24px; box-shadow: 0px 8px 25px rgba(0,0,0,0.08); transition: 0.3s ease; height: 100%; display: flex; flex-direction: column; }
        .job-card:hover { transform: translateY(-8px); box-shadow: 0px 15px 35px rgba(0,0,0,0.15); }
        .job-card p { margin-bottom: 12px; font-size: 15px; color: #212529; }
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
            <h5 class="m-0 fw-bold text-dark">Search Open Opportunities</h5>
            <div class="text-muted"><i class="bi bi-person-circle me-1"></i><%=name%></div>
        </div>

        <!-- --------------------------------------------------------------------------------
             4. SEARCH BAR FORM
             -------------------------------------------------------------------------------- -->
        <!-- Wrapped in a Bootstrap grid to center and restrict the maximum width of the search bar -->
        <div class="row mb-4">
            <div class="col-md-8 mx-auto">
                <div class="search-card">
                    <!-- Form submits via GET request, passing 'keyword' to the URL -->
                    <form method="GET" class="d-flex">
                        <!-- Preserves the previously searched keyword inside the input box -->
                        <input type="text" name="keyword" class="form-control search-input me-3" placeholder="Search by Job Title or Company..." value="<%= keyword != null ? keyword : "" %>">
                        <button type="submit" class="btn btn-primary search-btn"><i class="bi bi-search me-2"></i>Search</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- --------------------------------------------------------------------------------
             5. DYNAMIC JOB GRID & QUERY GENERATION
             -------------------------------------------------------------------------------- -->
        <div class="row">
            <%
            try {
                // Initialize the base query. Candidates only see 'Approved' jobs.
                String query = "SELECT * FROM jobs WHERE approval_status='Approved'";
                
                // Flag to determine if the user has inputted a valid search query string
                boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
                
                // Construct query: Safely append placeholders for PreparedStatement if a keyword exists
                if (hasKeyword) {
                    query += " AND (job_title LIKE ? OR company_name LIKE ? OR location LIKE ?)";
                }
                
                // Ensure newest jobs appear first
                query += " ORDER BY job_id DESC";
                
                // Create PreparedStatement to prevent SQL injection vulnerabilities
                PreparedStatement st = con.prepareStatement(query);
                
                // Bind the search keyword parameters to the placeholders safely
                if (hasKeyword) {
                    String searchParam = "%" + keyword.trim() + "%";
                    st.setString(1, searchParam);
                    st.setString(2, searchParam);
                    st.setString(3, searchParam);
                }
                
                ResultSet rsJobs = st.executeQuery();
                
                boolean jobsFound = false;
                int cardIndex = 0; // Index used to cycle colors for job cards visually
                
                // Iterate through fetched job postings
                while(rsJobs.next()) {
                    jobsFound = true;
                    
                    // Logic to cycle through Bootstrap color themes (Blue, Green, Yellow) for visual variety
                    String titleColor = "text-primary";
                    String btnClass = "btn-primary";
                    if (cardIndex % 3 == 1) {
                        titleColor = "text-success";
                        btnClass = "btn-success";
                    } else if (cardIndex % 3 == 2) {
                        titleColor = "text-warning";
                        btnClass = "btn-warning text-dark";
                    }
                    cardIndex++;
            %>
            <!-- Output Individual Job Card -->
            <div class="col-md-4 mb-4">
                <div class="job-card">
                    <!-- Dynamic title color applied based on cardIndex -->
                    <h4 class="<%=titleColor%> fw-bold mb-0"><%=rsJobs.getString("job_title")%></h4>
                    <hr class="my-3">
                    <p><b>Company :</b> <%=rsJobs.getString("company_name")%></p>
                    <p><b>Location :</b> <%=rsJobs.getString("location")%></p>
                    <p><b>Salary :</b> <%=rsJobs.getString("salary")%></p>
                    <p class="mb-4"><b>Experience :</b> <%=rsJobs.getString("experience")%></p>
                    
                    <div class="mt-auto">
                        <!-- Check profile completeness before rendering the active 'Apply' button -->
                        <% if(isProfileComplete) { %>
                            <!-- Profile is complete: Provide link to action page passing the specific job_id -->
                            <a href="apply_job.jsp?jobid=<%=rsJobs.getInt("job_id")%>" class="btn <%=btnClass%> w-100 rounded-pill fw-bold py-2">Apply Now</a>
                        <% } else { %>
                            <!-- Profile incomplete: Disable apply button and redirect to profile page -->
                            <a href="candidate_profile.jsp" class="btn btn-secondary w-100 rounded-pill fw-bold py-2"><i class="bi bi-lock-fill me-1"></i> Complete Profile to Apply</a>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                }
                
                // If the search yielded no results, display a friendly empty-state block
                if(!jobsFound) {
            %>
                <div class="col-12 text-center text-muted py-5">
                    <i class="bi bi-search fs-1 d-block mb-3 opacity-50"></i>
                    <h5 class="fw-bold">No jobs found!</h5>
                    <p>There are currently no approved jobs matching your criteria.</p>
                </div>
            <%
                }
            } catch (Exception e) {
                // Catch any database querying errors and display them directly in the UI for debugging
                out.println("<div class='alert alert-danger'>Error loading jobs: " + e.getMessage() + "</div>");
            }
            %>
        </div>
    </div>
</div>
<!-- Load Bootstrap JS bundle for interactive components -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>