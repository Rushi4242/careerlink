<%-- Import Java SQL package, custom DBConnection utility, and MessageDigest for SHA-256 password hashing --%>
<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%@page import="java.security.MessageDigest"%>

<%! 
// Helper method to hash plain-text passwords using the SHA-256 cryptographic algorithm
public String hashPassword(String password) {
    try {
        // Create a MessageDigest instance for SHA-256
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        // Compute the hash of the UTF-8 encoded password bytes
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        // Convert the resulting byte array into a hexadecimal string representation
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            // Pad single-digit hex values with a leading zero to maintain a 64-character hash
            if(hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    } catch (Exception ex) {
        // Wrap and rethrow any hashing errors as a RuntimeException
        throw new RuntimeException(ex);
    }
}
%>

<%
// Initialize an empty string to store authentication error messages
String message = "";
// Process login credentials when the form is submitted via a POST request
if(request.getMethod().equalsIgnoreCase("POST")) {
    // Retrieve the selected role, email address, and plain-text password from the form
    String role = request.getParameter("role");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    
    try {
        // Hash the user's input password using SHA-256 to compare against the stored database hash
        String encryptedInputPassword = hashPassword(password);
        // Establish a connection to the MySQL database
        Connection con = DBConnection.getConnection();
        
        // Updated query to check for the selected role as well
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE email=? AND password=? AND role=?");
        ps.setString(1, email);
        ps.setString(2, encryptedInputPassword); 
        ps.setString(3, role);
        
        // Execute the authentication query
        ResultSet rs = ps.executeQuery();
        // If a matching user record is found, initialize the user's session
        if(rs.next()) {
            session.setAttribute("user", email);
            session.setAttribute("role", role);
            
            // Redirect the authenticated user to their respective portal dashboard based on role
            if(role.equals("Candidate")) response.sendRedirect("candidate_dashboard.jsp");
            else if(role.equals("HR")) response.sendRedirect("hr_dashboard.jsp");
            else if(role.equals("Admin")) response.sendRedirect("admin_dashboard.jsp");
            return;
        } else {
            // Set an error message if the credentials or selected role do not match any record
            message = "Invalid Email, Password, or Role selection!";
        }
    } catch (Exception e) {
        // Capture and display any database or system exceptions
        message = "System Error: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign In | Career Link</title>
    <!-- Include Bootstrap 5 CSS for responsive layout and form components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include Bootstrap Icons for vector iconography -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* New crisp, bright modern workspace background with a soft blue overlay */
        body { 
            background: linear-gradient(rgba(230, 240, 255, 0.7), rgba(230, 240, 255, 0.7)), 
                        url('https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?q=80&w=1920&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            background-repeat: no-repeat;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            display: flex; 
            align-items: center; 
            min-height: 100vh; 
            margin: 0; 
        }
        
        /* Softer shadow to match the bright, clean aesthetic */
        .login-card { background: #fff; border-radius: 20px; box-shadow: 0 15px 40px rgba(0, 40, 100, 0.15); overflow: hidden; max-width: 900px; width: 100%; margin: auto; display: flex; }
        
        /* Left branding panel with a blue gradient background */
        .brand-side { background: linear-gradient(135deg, #0d6efd, #0056b3); color: white; padding: 50px; display: flex; flex-direction: column; justify-content: center; width: 45%; }
        /* Right panel container holding the sign-in form */
        .form-side { padding: 50px; width: 55%; }
        /* Custom padding, border-radius, and focus glow for form inputs and dropdowns */
        .form-control, .form-select { border-radius: 8px; padding: 12px 15px; background: #f8f9fa; border: 1px solid #dee2e6; }
        .form-control:focus, .form-select:focus { border-color: #0d6efd; box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25); background: #fff; }
        /* Primary submit button styling and hover lift animation */
        .btn-primary { padding: 12px; font-weight: bold; border-radius: 8px; transition: 0.3s; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(13, 110, 253, 0.3); }
    </style>
</head>
<body>

<div class="container">
    <!-- Main Split-Screen Login Card -->
    <div class="login-card">
        <!-- Left Side: Brand Logo and Tagline (hidden on mobile screens) -->
        <div class="brand-side d-none d-md-flex">
            <h1 class="fw-bold mb-3"><i class="bi bi-layers-fill me-2"></i>Career Link</h1>
            <p class="fs-5 opacity-75">Your bridge to the best professional opportunities and top-tier talent.</p>
        </div>
        <!-- Right Side: Login Form -->
        <div class="form-side">
            <h3 class="fw-bold text-dark mb-4">Welcome Back</h3>
            
            <% // Display an error alert banner if login authentication fails %>
            <% if(!message.equals("")) { %>
                <div class="alert alert-danger p-3 rounded-3" style="font-size: 14px;"><i class="bi bi-exclamation-circle-fill me-2"></i><%=message%></div>
            <% } %>

            <!-- Authentication Form submitting via POST -->
            <form method="post">
                <!-- Added Role Selection Dropdown -->
                <div class="mb-3">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">Login As</label>
                    <select name="role" class="form-select" required>
                        <option value="" disabled selected>-- Select your role --</option>
                        <option value="Candidate">Candidate</option>
                        <option value="HR">HR Manager</option>
                        <option value="Admin">System Administrator</option>
                    </select>
                </div>
                
                <!-- Email Address Input Field -->
                <div class="mb-3">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="name@example.com" required>
                </div>
                
                <!-- Password Input Field -->
                <div class="mb-2">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">Password</label>
                    <input type="password" name="password" class="form-control" placeholder="Enter your password" required>
                </div>
                
                <!-- Forgot Password Recovery Link -->
                <div class="text-start mb-4">
                    <a href="forgot_password.jsp" class="text-decoration-none fw-bold text-primary" style="font-size: 13px;">Forgot Password?</a>
                </div>

                <!-- Sign In Submit Button -->
                <button type="submit" class="btn btn-primary w-100 mb-3">Sign In</button>
            </form>
            
            <!-- Registration Redirect Link for New Users -->
            <div class="text-center mt-4 border-top pt-4">
                <p class="text-muted mb-0" style="font-size: 14px;">Don't have an account? <a href="register.jsp" class="text-decoration-none fw-bold text-primary">Register Here</a></p>
            </div>
        </div>
    </div>
</div>

</body>
</html>