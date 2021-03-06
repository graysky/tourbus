<%@ page contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.solr.core.SolrCore,
                 org.apache.solr.schema.IndexSchema,
                 java.io.BufferedReader,
                 java.io.File,
                 java.io.FilenameFilter,
                 java.io.FileReader,
                 java.net.InetAddress,
                 java.net.UnknownHostException,
                 java.util.Date"%>

<%@include file="header.jsp" %>

<%
  File slaveinfo = new File(cwd + "/solr/logs/snappuller.status");

  StringBuffer buffer = new StringBuffer();
  StringBuffer buffer2 = new StringBuffer();
  String mode = "";

  if (slaveinfo.canRead()) {
    // Slave instance
    mode = "Slave";
    File slavevers = new File(cwd + "/solr/logs/snapshot.current");
    BufferedReader inforeader = new BufferedReader(new FileReader(slaveinfo));
    BufferedReader versreader = new BufferedReader(new FileReader(slavevers));
    buffer.append("<tr>\n" +
                    "<td>\n" +
                      "Version:" +
                    "</td>\n" +
                    "<td>\n")
          .append(    versreader.readLine())
          .append(  "<td>\n" +
                    "</td>\n" +
                  "</tr>\n" +
                  "<tr>\n" +
                    "<td>\n" +
                      "Status:" +
                    "</td>\n" +
                    "<td>\n")
          .append(    inforeader.readLine())
          .append(  "</td>\n" +
                  "</tr>\n");
  } else {
    // Master instance
    mode = "Master";
    File masterdir = new File(cwd + "/solr/logs/clients");
    FilenameFilter sfilter = new FilenameFilter() {
        public boolean accept(File dir, String name) {
            return name.startsWith("snapshot.status");
        }
    };
    FilenameFilter cfilter = new FilenameFilter() {
        public boolean accept(File dir, String name) {
            return name.startsWith("snapshot.current");
        }
    };
    File[] clients = masterdir.listFiles(cfilter);
    if (clients == null) {
      buffer.append("<tr>\n" +
                      "<td>\n" +
                      "</td>\n" +
                      "<td>\n" +
                        "No distribution info present" +
                      "</td>\n" +
                    "</tr>\n");
    } else {
      buffer.append("<h4>Client Snapshot In Use:</h4>\n" +
                    "<tr>\n" +
                      "<th>\n" +
                      "Client" +
                      "</th>\n" +
                      "<th>\n" +
                      "Version" +
                      "</th>\n" +
                    "</tr>\n");
      int i = 0;
      while (i < clients.length) {
        String fileName=clients[i].toString();
        int p=fileName.indexOf("snapshot.current");
        String clientName=fileName.substring(p+17);
        BufferedReader reader = new BufferedReader(new FileReader(clients[i]));
        buffer.append("<tr>\n" +
                        "<td>\n" +
                        clientName +
                        "</td>\n" +
                        "<td>\n")
              .append(    reader.readLine())
              .append(  "</td>\n" +
                      "</tr>\n" +
                      "<tr>\n" +
                      "</tr>\n");
        i++;
      }
      clients = masterdir.listFiles(sfilter);
      if (clients!=null) {
        buffer.append("</table>\n" +
                      "<h4>Client Snapshot Distribution Status:</h4>\n" +
                      "<table>\n" +
                      "<tr>\n" +
                        "<th>\n" +
                        "Client" +
                        "</th>\n" +
                        "<th>\n" +
                        "Status" +
                        "</th>\n" +
                      "</tr>\n");
        i = 0;
        while (i < clients.length) {
          String fileName=clients[i].toString();
          int p=fileName.indexOf("snapshot.status");
          String clientName=fileName.substring(p+16);
          BufferedReader reader = new BufferedReader(new FileReader(clients[i]));
          buffer.append("<tr>\n" +
                          "<td>\n" +
                          clientName +
                          "</td>\n" +
                          "<td>\n")
                .append(    reader.readLine())
                .append(  "</td>\n" +
                        "</tr>\n" +
                        "<tr>\n" +
                        "</tr>\n");
          i++;
        }
      }
    }
  }
%>


<br clear="all">
<h2>Distribution Info</h2>
<h3><%= mode %> Server</h3>
<table>
<%= buffer %>
</table>
<br><br>
    <a href=".">Return to Admin Page</a>
</body>
</html>
