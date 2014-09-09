<#-- @ftlvariable name="" type="org.neo4j.wcapp.web.MatchView" -->
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

  <h2>${match.description}</h2>
  <h3>
    ${match.date}, ${match.homeScore} - ${match.awayScore}
  </h3>

  <div class="row">
    <div class="col-md-6">
      <ul>
        <#list match.team1Players as player>
          <li>
            <td>${player}</td>
          </li>
        </#list>
      </ul>

    </div>
    <div class="col-md-6">
      <ul>
        <#list match.team2Players as player>
          <li>
            <td>${player}</td>
          </li>
        </#list>
      </ul>
    </div>
  </div>






</div>
</body>
</html>
