<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="guestbook.GuestBookEntry" %>
<%@ page import="guestbook.PMF" %>


<%@page import="java.util.Date"%><html>
  <head>
    <title>Searchable Google App Engine Guestbook Example</title>
  </head>

  <body>
  
      <form action="/search.jsp" method="get">
      <input name="search"></input>
      <input type="submit" value="Search" />
    </form>
  
  <%
    	UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        
        PersistenceManager pm = PMF.get().getPersistenceManager();
        

            String guestBookEntryParameter = request.getParameter("entry");
            
            if (guestBookEntryParameter != null) {
            	Date date = new Date();
            	GuestBookEntry guestBookEntry = new GuestBookEntry(guestBookEntryParameter);

            	
           
            	pm.makePersistent(guestBookEntry);
            }
    %>  
        



<%
	String query = "select from " + GuestBookEntry.class.getName() + " order by date desc range 0,5";
    List<GuestBookEntry> guestBookEntries = (List<GuestBookEntry>) pm.newQuery(query).execute();
    if (guestBookEntries.isEmpty()) {
%>
<p>The guestbook has no messages.</p>
<%
	} else {
        for (GuestBookEntry g : guestBookEntries) {
            
%>
<blockquote><%= g.getContent() %></blockquote>
<%
        }
    }
    pm.close();
%>

    <form action="/guestbook.jsp" method="post">
      <div><textarea name="entry" rows="3" cols="60"></textarea></div>
      <div><input type="submit" value="Post guestbook entry" /></div>
    </form>

  </body>
</html>
