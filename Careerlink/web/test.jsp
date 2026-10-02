<%
// Session Validation: Verify that a user is logged in before allowing access to this test page
if(session.getAttribute("user")==null)
{
    // Redirect unauthenticated users back to the login page and halt execution
    response.sendRedirect("login.jsp");
    return;
}
%>
<%-- Import the Java SQL Connection interface and the custom DBConnection utility class --%>
<%@page import="java.sql.Connection"%>
<%@page import="com.careerlink.util.DBConnection"%>

<!DOCTYPE html>
<html>
<head>
    <title>Database Test</title>
</head>
<body>

<%
// Attempt to establish a connection to the MySQL database using the utility class
Connection con = DBConnection.getConnection();

// Verify if the database connection was successfully established
if(con != null){
%>

<!-- Display a success message in green text if the connection object is active -->
<h2 style="color:green;">
Database Connected Successfully
</h2>

<%
// Handle the scenario where the database connection fails
}else{
%>

<!-- Display a failure message in red text if the connection object evaluates to null -->
<h2 style="color:red;">
Connection Failed
</h2>

<%
}
%>

</body>
</html>