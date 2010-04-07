<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="guestbook.GuestBookEntry" %>
<%@ page import="guestbook.PMF" %>


<%@page import="guestbook.SearchJanitor"%><html>
  <head>
    <title>Searchable Guestbook Example</title>
  </head>

  <body>

    <form action="/search.jsp" method="get">
      <div><input name="search"></input></div>
      <div><input type="submit" value="Search" /></div>
    </form>

<%
	String searchString = request.getParameter("search");


if (searchString != null) {
	
	out.println("Results for:<b> " + searchString + "</b>");
	   PersistenceManager pm = PMF.get().getPersistenceManager();
	   
	
		List<GuestBookEntry> searchResults = SearchJanitor.searchGuestBookEntries(searchString, pm);
	
	
    if (searchResults.isEmpty()) {
%>
    	<p>No results found. Please try different search.</p>
    	<%
    		} else {
    	    	        for (GuestBookEntry g : searchResults) {

    	%>
    	<blockquote><%= g.getContent() %></blockquote>
    	<%
    	        }
    	    }
    	    pm.close();
}

%>


	<a href="guestbook.jsp">Back to main page</a>
	
	    <p>
    Example project <a href="http://code.google.com/p/guestbook-example-appengine-full-text-search/">guestbook-example-appengine-full-text-search</a>.
    </p>

  </body>
</html>
