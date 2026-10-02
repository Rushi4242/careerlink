<%@page language="java" contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Career Link | Home</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* Immersive Bright Office Background */
body {
    font-family: 'Segoe UI', Arial, Helvetica, sans-serif;
    /* Light gradient overlay so the dark text remains perfectly readable */
    background: linear-gradient(rgba(240, 244, 248, 0.88), rgba(240, 244, 248, 0.88)), 
                url('https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=1920&auto=format&fit=crop');
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    background-repeat: no-repeat;
}

/* Glassmorphism Navigation */
.navbar {
    background: rgba(13, 110, 253, 0.95);
    backdrop-filter: blur(10px);
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}

.navbar-brand {
    font-size: 28px;
    font-weight: bold;
    color: white !important;
}

.nav-link {
    color: white !important;
    margin-left: 15px;
    font-weight: 500;
}

/* Hero Section with Translucent Gradient */
.hero {
    background: linear-gradient(135deg, rgba(13, 110, 253, 0.85), rgba(102, 16, 242, 0.85));
    backdrop-filter: blur(5px);
    color: white;
    padding: 80px 20px;
    text-align: center;
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.hero h1 {
    font-size: 50px;
    font-weight: bold;
}

.hero p {
    font-size: 20px;
    margin-top: 15px;
}

/* Buttons */
.btn-custom {
    padding: 12px 30px;
    font-size: 18px;
    margin: 10px;
    border-radius: 30px;
    font-weight: bold;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    transition: 0.3s;
}
.btn-custom:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.3);
}

.section-title {
    margin-top: 50px;
    margin-bottom: 30px;
    text-align: center;
    font-weight: 900;
    color: #0d6efd;
    text-transform: uppercase;
    letter-spacing: 1px;
}

/* Glassmorphism Cards */
.card {
    border: 1px solid rgba(255,255,255,0.6);
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.85); /* Semi-transparent white */
    backdrop-filter: blur(12px); /* Blurred glass effect */
    box-shadow: 0px 8px 25px rgba(0,0,0,0.08);
    transition: .3s ease;
}

.card:hover {
    transform: translateY(-8px);
    box-shadow: 0px 15px 35px rgba(0,0,0,0.15);
    background: rgba(255, 255, 255, 1); /* Turns solid white on hover */
}

/* Footer Transparency */
footer {
    background: rgba(13, 110, 253, 0.95) !important;
    backdrop-filter: blur(10px);
}
</style>
</head>
<body>

<!-- Navigation -->
<nav class="navbar navbar-expand-lg sticky-top">
<div class="container">
<a class="navbar-brand" href="#"><i class="bi bi-layers-fill me-2"></i>Career Link</a>
<button class="navbar-toggler bg-white" type="button" data-bs-toggle="collapse" data-bs-target="#menu">
<span class="navbar-toggler-icon"></span>
</button>
<div class="collapse navbar-collapse" id="menu">
<ul class="navbar-nav ms-auto">
<li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
<li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
<li class="nav-item"><a class="nav-link" href="register.jsp">Register</a></li>
</ul>
</div>
</div>
</nav>

<!-- Hero Section -->
<section class="hero">
<div class="container">
<h1>Welcome to Career Link</h1>
<p>Online Job Portal System</p>
<p>Find your dream job and build your career with us.</p>
<a href="register.jsp" class="btn btn-warning btn-custom text-dark">Get Started</a>
<a href="login.jsp" class="btn btn-light btn-custom text-primary">Login</a>
</div>
</section>

<!-- Featured Jobs -->
<div class="container">
<h2 class="section-title">Featured Jobs</h2>
<div class="row">
<!-- Job 1 -->
<div class="col-md-4 mb-4">
<div class="card p-3">
<h4 class="text-primary fw-bold">Java Developer</h4>
<hr>
<p><b>Company :</b> TCS</p>
<p><b>Location :</b> Pune</p>
<p><b>Salary :</b> ₹6 LPA</p>
<p><b>Experience :</b> 0-2 Years</p>
<a href="login.jsp" class="btn btn-primary w-100 rounded-pill fw-bold">Apply Now</a>
</div>
</div>
<!-- Job 2 -->
<div class="col-md-4 mb-4">
<div class="card p-3">
<h4 class="text-success fw-bold">Frontend Developer</h4>
<hr>
<p><b>Company :</b> Infosys</p>
<p><b>Location :</b> Mumbai</p>
<p><b>Salary :</b> ₹5 LPA</p>
<p><b>Experience :</b> 1 Year</p>
<a href="login.jsp" class="btn btn-success w-100 rounded-pill fw-bold">Apply Now</a>
</div>
</div>
<!-- Job 3 -->
<div class="col-md-4 mb-4">
<div class="card p-3">
<h4 class="text-warning fw-bold">Python Developer</h4>
<hr>
<p><b>Company :</b> Wipro</p>
<p><b>Location :</b> Bangalore</p>
<p><b>Salary :</b> ₹7 LPA</p>
<p><b>Experience :</b> 2 Years</p>
<a href="login.jsp" class="btn btn-warning w-100 rounded-pill fw-bold text-dark">Apply Now</a>
</div>
</div>
</div>
</div>

<!-- Top Companies -->
<div class="container">
<h2 class="section-title">Top Hiring Companies</h2>
<div class="row">
<div class="col-md-3 mb-3">
<div class="card text-center p-4">
<h4 class="fw-bold">TCS</h4>
<p class="text-muted mb-0">50+ Jobs</p>
</div>
</div>
<div class="col-md-3 mb-3">
<div class="card text-center p-4">
<h4 class="fw-bold">Infosys</h4>
<p class="text-muted mb-0">35+ Jobs</p>
</div>
</div>
<div class="col-md-3 mb-3">
<div class="card text-center p-4">
<h4 class="fw-bold">Wipro</h4>
<p class="text-muted mb-0">28+ Jobs</p>
</div>
</div>
<div class="col-md-3 mb-3">
<div class="card text-center p-4">
<h4 class="fw-bold">Capgemini</h4>
<p class="text-muted mb-0">20+ Jobs</p>
</div>
</div>
</div>
</div>

<!-- AI Resume Tips -->
<div class="container">
<h2 class="section-title">AI Resume Tips</h2>
<div class="row">
<div class="col-md-4 mb-4">
<div class="card text-center p-4 h-100">
<i class="bi bi-file-earmark-text-fill text-primary" style="font-size:50px;"></i>
<h4 class="mt-3 fw-bold">Professional Resume</h4>
<p class="text-muted">Create a clean and professional resume with updated information.</p>
</div>
</div>
<div class="col-md-4 mb-4">
<div class="card text-center p-4 h-100">
<i class="bi bi-award-fill text-success" style="font-size:50px;"></i>
<h4 class="mt-3 fw-bold">Add Skills</h4>
<p class="text-muted">Mention technical skills, certifications and projects to improve your profile.</p>
</div>
</div>
<div class="col-md-4 mb-4">
<div class="card text-center p-4 h-100">
<i class="bi bi-graph-up-arrow text-danger" style="font-size:50px;"></i>
<h4 class="mt-3 fw-bold">Improve Score</h4>
<p class="text-muted">A better resume increases your chances of getting shortlisted.</p>
</div>
</div>
</div>
</div>

<!-- Why Choose Career Link -->
<div class="container">
<h2 class="section-title">Why Choose Career Link?</h2>
<div class="row">
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<i class="bi bi-search text-primary" style="font-size:45px;"></i>
<h5 class="mt-3 fw-bold">Easy Job Search</h5>
</div>
</div>
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<i class="bi bi-person-check-fill text-success" style="font-size:45px;"></i>
<h5 class="mt-3 fw-bold">Verified Companies</h5>
</div>
</div>
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<i class="bi bi-calendar-check-fill text-warning" style="font-size:45px;"></i>
<h5 class="mt-3 fw-bold">Interview Updates</h5>
</div>
</div>
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<i class="bi bi-briefcase-fill text-danger" style="font-size:45px;"></i>
<h5 class="mt-3 fw-bold">100+ Jobs</h5>
</div>
</div>
</div>
</div>

<!-- Website Statistics -->
<div class="container">
<h2 class="section-title">Career Link Statistics</h2>
<div class="row">
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<h2 class="text-primary fw-bold">500+</h2>
<p class="text-muted fw-bold mb-0">Registered Candidates</p>
</div>
</div>
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<h2 class="text-success fw-bold">120+</h2>
<p class="text-muted fw-bold mb-0">Companies</p>
</div>
</div>
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<h2 class="text-warning fw-bold">300+</h2>
<p class="text-muted fw-bold mb-0">Jobs Posted</p>
</div>
</div>
<div class="col-md-3 mb-4">
<div class="card text-center p-4">
<h2 class="text-danger fw-bold">200+</h2>
<p class="text-muted fw-bold mb-0">Successful Placements</p>
</div>
</div>
</div>
</div>

<!-- Contact Section -->
<div class="container mb-5">
<h2 class="section-title">Contact Us</h2>
<div class="row">
<div class="col-md-6 mb-4">
<div class="card p-4 h-100">
<h4 class="fw-bold mb-3 text-primary"><i class="bi bi-headset me-2"></i>Get In Touch</h4>
<p class="mb-2"><i class="bi bi-envelope-fill text-muted me-2"></i><b>Email :</b> careerlink@gmail.com</p>
<p class="mb-2"><i class="bi bi-telephone-fill text-muted me-2"></i><b>Phone :</b> +91 9876543210</p>
<p class="mb-3"><i class="bi bi-geo-alt-fill text-muted me-2"></i><b>Address :</b> Pune, Maharashtra, India</p>
<p class="text-muted small">We help students and job seekers find the best career opportunities.</p>
</div>
</div>
<div class="col-md-6 mb-4">
<div class="card p-4 h-100">
<h4 class="fw-bold mb-3 text-primary"><i class="bi bi-link-45deg me-2"></i>Quick Links</h4>
<div class="d-grid gap-3">
<a href="login.jsp" class="btn btn-outline-primary rounded-pill fw-bold">Login to your account</a>
<a href="register.jsp" class="btn btn-outline-success rounded-pill fw-bold">Register as a new user</a>
<a href="search_jobs.jsp" class="btn btn-outline-warning rounded-pill fw-bold text-dark">Search for open Jobs</a>
</div>
</div>
</div>
</div>
</div>

<!-- Footer -->
<footer class="bg-primary text-white mt-5">
<div class="container text-center p-5">
<h3 class="fw-bold"><i class="bi bi-layers-fill me-2"></i>Career Link</h3>
<p class="mb-1">Assisted Online Job Portal System</p>
<p class="opacity-75">Helping Students Build Their Career</p>
<hr class="my-4 mx-auto w-50 opacity-25">
<p class="mb-0 small">© 2026 Career Link. All Rights Reserved.</p>
</div>
</footer>

<!-- Bootstrap JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>