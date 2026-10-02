<%

// Destroy user session

session.invalidate();

// Redirect to Login Page

response.sendRedirect("login.jsp");

%>