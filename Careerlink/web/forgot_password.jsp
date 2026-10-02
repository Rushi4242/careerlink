<%@page import="java.sql.*"%>
<%@page import="com.careerlink.util.DBConnection"%>
<%@page import="java.security.MessageDigest"%>

<%! 
// SHA-256 Password Hashing Method
public String hashPassword(String password) {
    try {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if(hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    } catch (Exception ex) {
        throw new RuntimeException(ex);
    }
}
%>

<%
String message = "";
boolean success = false;

if(request.getMethod().equalsIgnoreCase("POST")) {
    String email = request.getParameter("email");
    String mobile = request.getParameter("mobile");
    String newPassword = request.getParameter("new_password");
    String confirmPassword = request.getParameter("confirm_password");
    
    if(newPassword.equals(confirmPassword)) {
        try {
            Connection con = DBConnection.getConnection();
            
            // 1. Verify if the Email and Mobile combination exists in the database
            PreparedStatement verifyPs = con.prepareStatement("SELECT * FROM users WHERE email=? AND mobile=?");
            verifyPs.setString(1, email);
            verifyPs.setString(2, mobile);
            ResultSet rs = verifyPs.executeQuery();
            
            if(rs.next()) {
                // 2. If verified, hash the new password and update the database
                String hashedNewPassword = hashPassword(newPassword);
                PreparedStatement updatePs = con.prepareStatement("UPDATE users SET password=? WHERE email=?");
                updatePs.setString(1, hashedNewPassword);
                updatePs.setString(2, email);
                
                if(updatePs.executeUpdate() > 0) {
                    message = "Password reset successfully! You can now sign in.";
                    success = true;
                } else {
                    message = "Failed to reset password. Please try again.";
                }
            } else {
                message = "Verification failed. Email and Mobile Number do not match our records.";
            }
        } catch (Exception e) {
            message = "System Error: " + e.getMessage();
        }
    } else {
        message = "New Password and Confirm Password do not match!";
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Forgot Password | Career Link</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; display: flex; align-items: center; min-height: 100vh; margin: 0; }
        .login-card { background: #fff; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); overflow: hidden; max-width: 900px; width: 100%; margin: auto; display: flex; }
        .brand-side { background: linear-gradient(135deg, #0d6efd, #0056b3); color: white; padding: 50px; display: flex; flex-direction: column; justify-content: center; width: 45%; }
        .form-side { padding: 50px; width: 55%; }
        .form-control { border-radius: 8px; padding: 12px 15px; background: #f8f9fa; border: 1px solid #dee2e6; }
        .form-control:focus { border-color: #0d6efd; box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25); background: #fff; }
        .btn-primary { padding: 12px; font-weight: bold; border-radius: 8px; transition: 0.3s; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(13, 110, 253, 0.3); }
    </style>
</head>
<body>

<div class="container">
    <div class="login-card">
        <div class="brand-side d-none d-md-flex">
            <h1 class="fw-bold mb-3"><i class="bi bi-shield-lock-fill me-2"></i>Account Recovery</h1>
            <p class="fs-5 opacity-75">Verify your identity to securely reset your Career Link password.</p>
        </div>
        <div class="form-side">
            <h3 class="fw-bold text-dark mb-4">Reset Password</h3>
            
            <% if(!message.equals("") && !success) { %>
                <div class="alert alert-danger p-3 rounded-3 fw-semibold" style="font-size: 14px;"><i class="bi bi-exclamation-circle-fill me-2"></i><%=message%></div>
            <% } else if (success) { %>
                <div class="alert alert-success p-3 rounded-3 fw-semibold" style="font-size: 14px;"><i class="bi bi-check-circle-fill me-2"></i><%=message%></div>
            <% } %>

            <% if(!success) { %>
            <form method="post">
                <div class="mb-3">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">Registered Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="name@example.com" required>
                </div>
                <div class="mb-4">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">Registered Mobile Number</label>
                    <input type="text" name="mobile" class="form-control" placeholder="10-digit number" maxlength="10" required>
                </div>
                
                <hr class="mb-4">

                <div class="mb-3">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">New Password</label>
                    <input type="password" name="new_password" class="form-control" placeholder="Enter new password" required>
                </div>
                <div class="mb-4">
                    <label class="form-label text-muted fw-bold" style="font-size: 13px;">Confirm New Password</label>
                    <input type="password" name="confirm_password" class="form-control" placeholder="Re-enter new password" required>
                </div>

                <button type="submit" class="btn btn-primary w-100 mb-3">Reset Password</button>
            </form>
            <% } else { %>
                <a href="login.jsp" class="btn btn-primary w-100 mb-3 mt-4">Return to Sign In</a>
            <% } %>
            
            <div class="text-center mt-4 border-top pt-4">
                <a href="login.jsp" class="text-decoration-none fw-bold text-muted"><i class="bi bi-arrow-left me-1"></i> Back to Login</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>