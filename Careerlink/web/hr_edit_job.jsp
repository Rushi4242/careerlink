<%
// Session Validation
if(session.getAttribute("user") == null || !session.getAttribute("role").equals("HR")) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%
String email = session.getAttribute("user").toString();
String message = "";
Connection con = DBConnection.getConnection();
String hrName = "HR";
int hrId = 0;

PreparedStatement hrPs = con.prepareStatement("SELECT user_id, full_name FROM users WHERE email=?");
hrPs.setString(1, email);
ResultSet hrRs = hrPs.executeQuery();
if(hrRs.next()) { hrId = hrRs.getInt("user_id"); hrName = hrRs.getString("full_name"); }

// Get Job ID from URL
String jobIdStr = request.getParameter("jobid");
if(jobIdStr == null || jobIdStr.isEmpty()) {
    response.sendRedirect("hr_manage_jobs.jsp");
    return;
}
int jobId = Integer.parseInt(jobIdStr);

// Process Update on POST
if(request.getMethod().equalsIgnoreCase("POST")) {
    String title = request.getParameter("title");
    String company = request.getParameter("company");
    String location = request.getParameter("location");
    String salary = request.getParameter("salary");
    String experience = request.getParameter("experience");
    String description = request.getParameter("description");
    String lastDate = request.getParameter("last_date");

    try {
        // Update the job details securely
        PreparedStatement updatePs = con.prepareStatement(
            "UPDATE jobs SET job_title=?, company_name=?, location=?, salary=?, experience=?, description=?, last_date=? WHERE job_id=? AND posted_by=?"
        );
        updatePs.setString(1, title); updatePs.setString(2, company); updatePs.setString(3, location); 
        updatePs.setString(4, salary); updatePs.setString(5, experience); updatePs.setString(6, description); 
        updatePs.setString(7, lastDate); updatePs.setInt(8, jobId); updatePs.setInt(9, hrId);
        
        if(updatePs.executeUpdate() > 0) message = "<div class='alert alert-success fw-bold'><i class='bi bi-check-circle-fill me-2'></i>Job Updated Successfully!</div>";
        else message = "<div class='alert alert-danger fw-bold'>Failed to Update Job. Ensure you have permission.</div>";
    } catch(Exception e) { 
        message = "<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"; 
    }
}

// Fetch existing job details to pre-fill the form
PreparedStatement fetchJob = con.prepareStatement("SELECT * FROM jobs WHERE job_id=? AND posted_by=?");
fetchJob.setInt(1, jobId); fetchJob.setInt(2, hrId);
ResultSet jobDetails = fetchJob.executeQuery();

// If job isn't found or doesn't belong to this HR, redirect
if(!jobDetails.next()) {
    response.sendRedirect("hr_manage_jobs.jsp");
    return;
}

String currentPageURI = request.getRequestURI();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Job | HR Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        .wrapper { display: flex; width: 100%; min-height: 100vh; }
        .sidebar { min-width: 260px; max-width: 260px; background: #dae6f2; transition: all 0.3s; z-index: 10; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        .sidebar-header { padding: 25px; background: #655b8e; text-align: center; color: #ffffff; position: relative; margin-bottom: 10px; }
        .sidebar-header h4 { font-weight: 800; margin: 0; color: #ffffff; }
        .sidebar-header .text-light { color: #f8f9fa !important; }
        .sidebar-header::after { content: ''; position: absolute; bottom: -10px; left: 25px; width: 0; height: 0; border-left: 10px solid transparent; border-right: 10px solid transparent; border-top: 10px solid #655b8e; z-index: 10; }
        .sidebar ul { margin: 0; padding: 0; }
        .sidebar ul li { border-bottom: 1px solid #ffffff; }
        .sidebar ul li a { padding: 15px 25px; font-size: 15px; display: block; background-color: #dae6f2; color: #0d2857; text-decoration: none; transition: 0.3s; font-weight: 500; }
        .sidebar ul li a:hover { background-color: #c4d6ea; }
        .sidebar ul li a.active { background-color: #2c2560; color: #ffffff; }
        .sidebar ul li a i { margin-right: 12px; font-size: 18px; }
        .sidebar .p-3 { background-color: #dae6f2; margin-top: auto; }
        .sidebar .btn-outline-danger { background-color: #ffffff; font-weight: bold; border: 1px solid #ef4444; color: #ef4444; }
        .sidebar .btn-outline-danger:hover { background-color: #ef4444; color: #ffffff; }
        .content { width: 100%; padding: 30px; flex-grow: 1; }
        .top-navbar { background: #fff; padding: 20px 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-radius: 8px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        .form-card { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); max-width: 800px; margin: 0 auto; }
        .form-control { background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 12px; }
        .form-control:focus { border-color: #3b82f6; box-shadow: 0 0 0 0.25rem rgba(59, 130, 246, 0.25); background-color: #fff; }
    </style>
</head>
<body>
<div class="wrapper">
    <nav class="sidebar">
        <div class="sidebar-header">
            <h4 class="fw-bold m-0"><i class="bi bi-buildings-fill me-2"></i>Career Link</h4>
            <div class="text-light opacity-75 mt-1" style="font-size: 13px;">HR Portal</div>
        </div>
        <ul class="list-unstyled mt-3 flex-grow-1">
            <li><a href="hr_dashboard.jsp" class="<%= currentPageURI.contains("hr_dashboard.jsp") ? "active" : "" %>"><i class="bi bi-grid-1x2-fill"></i> HR Dashboard</a></li>
            <li><a href="post_job.jsp" class="<%= currentPageURI.contains("post_job.jsp") ? "active" : "" %>"><i class="bi bi-plus-circle-fill"></i> Post New Job</a></li>
            <li><a href="hr_manage_jobs.jsp" class="active"><i class="bi bi-gear-fill"></i> Manage Jobs</a></li>
            <li><a href="hr_view_applications.jsp" class="<%= currentPageURI.contains("hr_view_applications.jsp") ? "active" : "" %>"><i class="bi bi-file-earmark-person-fill"></i> Applications</a></li>
        </ul>
        <div class="p-3"><a href="logout.jsp" class="btn btn-outline-danger w-100 rounded-pill"><i class="bi bi-power me-2"></i>Logout</a></div>
    </nav>

    <div class="content">
        <div class="top-navbar">
            <h5 class="m-0 fw-bold text-dark">Edit Job Posting</h5>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-2"></i><%=hrName%></div>
        </div>

        <div class="form-card">
            <%=message%>
            <form method="post">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Job Title</label>
                        <input type="text" name="title" class="form-control" value="<%=jobDetails.getString("job_title")%>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Company Name</label>
                        <input type="text" name="company" class="form-control" value="<%=jobDetails.getString("company_name")%>" required>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Location</label>
                        <input type="text" name="location" class="form-control" value="<%=jobDetails.getString("location")%>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Salary Details</label>
                        <input type="text" name="salary" class="form-control" value="<%=jobDetails.getString("salary")%>" required>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Required Experience</label>
                        <input type="text" name="experience" class="form-control" value="<%=jobDetails.getString("experience")%>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold text-muted small">Application Deadline</label>
                        <!-- Safely populate the date field -->
                        <input type="date" name="last_date" class="form-control" value="<%=jobDetails.getString("last_date") != null ? jobDetails.getString("last_date") : ""%>" required>
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-bold text-muted small">Comprehensive Job Description</label>
                    <textarea name="description" class="form-control" rows="5" required><%=jobDetails.getString("description")%></textarea>
                </div>
                <div class="d-flex gap-3">
                    <button type="submit" class="btn btn-primary w-50 py-2 fw-bold rounded-pill">Update Listing</button>
                    <a href="hr_manage_jobs.jsp" class="btn btn-light border w-50 py-2 fw-bold rounded-pill text-dark">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>