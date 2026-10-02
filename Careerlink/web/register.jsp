<%-- Import Java SQL package, custom DBConnection utility, and MessageDigest for secure password hashing --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%@page import="java.security.MessageDigest"%>

<%! 
// Helper method to securely hash plain-text passwords using the SHA-256 cryptographic algorithm
public String hashPassword(String password) {
    try {
        // Initialize the MessageDigest with the SHA-256 algorithm
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        // Compute the hash of the UTF-8 encoded password
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        // Convert the resulting byte array into a 64-character hexadecimal string
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            // Pad single-digit hex values with a leading zero
            if(hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    } catch (Exception ex) {
        // Catch and rethrow any hashing errors as a RuntimeException
        throw new RuntimeException(ex);
    }
}
%>

<%
// Initialize an empty string to hold success or error alert messages
String message = "";
// Process the registration request when the form is submitted via POST
if(request.getMethod().equalsIgnoreCase("POST")) {
    // Retrieve the user's input from the HTML registration form
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String mobile = request.getParameter("mobile");
    String role = request.getParameter("role");
    String password = request.getParameter("password");
    
    try {
        // Establish a connection to the MySQL database
        Connection con = DBConnection.getConnection();
        
        // Check if the provided email address is already registered in the system
        PreparedStatement psCheck = con.prepareStatement("SELECT * FROM users WHERE email=?");
        psCheck.setString(1, email);
        ResultSet rsCheck = psCheck.executeQuery();
        
        // If the email exists, display a warning message with a link to the login page
        if(rsCheck.next()) {
            message = "<div class='alert alert-warning p-2 text-center' style='font-size: 14px;'>Email Address is already registered! <a href='login.jsp'>Sign In</a></div>";
        } else {
            // If the email is unique, hash the new password before storing it
            String encryptedPassword = hashPassword(password);
            // Prepare an INSERT statement to create the new user account
            PreparedStatement ps = con.prepareStatement("INSERT INTO users (full_name, email, mobile, password, role) VALUES (?, ?, ?, ?, ?)");
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, mobile);
            ps.setString(4, encryptedPassword);
            ps.setString(5, role);
            
            // Execute the insertion and display a success message if the account is created
            if(ps.executeUpdate() > 0) {
                message = "<div class='alert alert-success p-2 text-center' style='font-size: 14px;'>Registration successful! <a href='login.jsp' class='alert-link'>Sign In Here</a></div>";
            } else {
                // Display a failure message if the insertion affected zero rows
                message = "<div class='alert alert-danger p-2 text-center' style='font-size: 14px;'>Registration failed. Please try again.</div>";
            }
        }
    } catch (Exception e) {
        // Catch and display any database or SQL execution errors
        message = "<div class='alert alert-danger p-2' style='font-size: 14px;'>System Error: " + e.getMessage() + "</div>";
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Register | Career Link</title>
    <!-- Include Bootstrap 5 CSS for responsive form layout and components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* New vibrant, modern workspace background with an indigo-blue gradient overlay */
        body { 
            background: linear-gradient(rgba(17, 24, 39, 0.85), rgba(37, 99, 235, 0.65)), 
                        url('https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=1920&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            background-repeat: no-repeat;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            display: flex; 
            align-items: center; 
            min-height: 100vh; 
            margin: 0; 
            padding: 20px 0;
        }
        
        /* Deep shadow so the white card pops cleanly off the rich background */
        .login-card { background: #fff; border-radius: 20px; box-shadow: 0 15px 50px rgba(0,0,0,0.4); overflow: hidden; max-width: 900px; width: 100%; margin: auto; display: flex; }
        
        /* Left branding panel with a blue gradient background (hidden on mobile) */
        .brand-side { background: linear-gradient(135deg, #0d6efd, #0056b3); color: white; padding: 50px; display: flex; flex-direction: column; justify-content: center; width: 45%; }
        /* Right panel container holding the registration form */
        .form-side { padding: 40px 50px; width: 55%; }
        /* Custom padding, border-radius, and focus glow for form inputs and dropdowns */
        .form-control, .form-select { border-radius: 8px; padding: 10px 15px; background: #f8f9fa; border: 1px solid #dee2e6; font-size: 14px;}
        .form-control:focus, .form-select:focus { border-color: #0d6efd; box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25); background: #fff; }
        /* Primary submit button styling and hover lift animation */
        .btn-primary { padding: 12px; font-weight: bold; border-radius: 8px; transition: 0.3s; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(13, 110, 253, 0.3); }
    </style>
</head>
<body>

<div class="container">
    <!-- Main Split-Screen Registration Card -->
    <div class="login-card">
        <!-- Left Side: Brand Logo and Tagline -->
        <div class="brand-side d-none d-md-flex">
            <h1 class="fw-bold mb-3"><i class="bi bi-layers-fill me-2"></i>Career Link</h1>
            <p class="fs-5 opacity-75">Join thousands of professionals finding their next big opportunity today.</p>
        </div>
        <!-- Right Side: Registration Form -->
        <div class="form-side">
            <h3 class="fw-bold text-dark mb-4">Create Account</h3>
            
            <!-- Output any success or error messages generated during form processing -->
            <%=message%>

            <!-- Registration Form submitting via POST -->
            <form method="post">
                <div class="row g-3 mb-3">
                    <!-- Role Selection Dropdown (Candidate or HR) -->
                    <div class="col-md-12">
                        <label class="form-label text-muted fw-bold" style="font-size: 12px;">Register As</label>
                        <select name="role" class="form-select" required>
                            <option value="" disabled selected>-- Select Account Type --</option>
                            <option value="Candidate">Candidate (Looking for Jobs)</option>
                            <option value="HR">HR Manager (Posting Jobs)</option>
                        </select>
                    </div>
                    
                    <!-- Full Name Input Field -->
                    <div class="col-md-12">
                        <label class="form-label text-muted fw-bold" style="font-size: 12px;">Full Name</label>
                        <input type="text" name="fullName" class="form-control" placeholder="abc" required>
                    </div>
                    
                    <!-- Mobile Number Input Field (enforces 10 digits via pattern matching) -->
                    <div class="col-md-6">
                        <label class="form-label text-muted fw-bold" style="font-size: 12px;">Mobile Number</label>
                        <input type="tel" name="mobile" class="form-control" placeholder="10-digit number" pattern="[0-9]{10}" required>
                    </div>
                    
                    <!-- Email Address Input Field -->
                    <div class="col-md-6">
                        <label class="form-label text-muted fw-bold" style="font-size: 12px;">Email Address</label>
                        <input type="email" name="email" class="form-control" placeholder="name@example.com" required>
                    </div>
                    
                    <!-- Password Input Field -->
                    <div class="col-md-12">
                        <label class="form-label text-muted fw-bold" style="font-size: 12px;">Create Password</label>
                        <input type="password" name="password" class="form-control" placeholder="Create a strong password (must contain '@')" pattern=".*@.*" title="Password must contain an '@' special character" required>
                    </div>
                </div>

                <!-- Registration Submit Button -->
                <button type="submit" class="btn btn-primary w-100 mb-3 mt-2">Sign Up</button>
            </form>
            
            <!-- Login Redirect Link for Existing Users -->
            <div class="text-center mt-3 border-top pt-3">
                <p class="text-muted mb-0" style="font-size: 14px;">Already have an account? <a href="login.jsp" class="text-decoration-none fw-bold text-primary">Sign In</a></p>
            </div>
        </div>
    </div>
</div>

</body>
</html> 