<#-- @ftlvariable name="" type="org.neo4j.wcapp.web.HomeView" -->
<html>
<head>
  <title>World Cup Graph</title>
  <link rel="stylesheet" href="/assets/css/bootstrap.min.css">

  <!-- Optional theme -->
  <link rel="stylesheet" href="/assets/css/bootstrap-theme.min.css">

  <!-- Latest compiled and minified JavaScript -->
  <script src="/assets/js/bootstrap.min.js"></script>
<head>
<body>
<div class="container">
  <h1>World Cup Graph</h1>



  <div>
    <table class="table">
      <thead>

      </thead>
      <tbody>
      <#list worldCups as wc>
        <tr>
          <td> <a href="/events/${wc.year?c}">${wc.year?c}</a></td>
          <td> ${wc.host}</td>
        </tr>

      </#list>
      </tbody>
    </table>
  </div>

</div>
</body>
</html>
