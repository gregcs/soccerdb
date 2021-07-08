<?php

include_once("errors.php");

if (session_status() == PHP_SESSION_NONE) {
  session_start();
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title><?php echo $pageName; ?></title>
    <link rel="shortcut icon" type="image/png" href="./assets/favicon.png" />
   
    <!-- Bootstrap -->
    <link href="./assets/jquery-ui/jquery-ui.min.css" rel="stylesheet">
    <link href="./assets/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="./assets/style.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>

<body>

    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="index.php">SoccerDB</a>
            </div>

            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                <ul class="nav navbar-nav">
                    <li><a href="./best_players.php?c=1">Best players</a></li>
                    <li><a href="./home_ranking.php">Rankings</a></li>
                    <?php
                    if (isset($_SESSION['db_role'])) {
                      if ($_SESSION['db_role'] === 'administrator') {  
                       
                      echo  '<li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button">Upload<span class="caret"></span></a>
                        <ul class="dropdown-menu">
                          <li><a href="./load_match_csv.php">Match file</a></li>
                          <li><a href="./load_stats_csv.php">Player\'s stats file</a></li>
                        </ul>
                      </li>';
                    
                      }
                      if ($_SESSION['db_role'] === 'operator')
                        echo '<li><a href="./new_match.php?c=1">New match</a></li>';
                      if ($_SESSION['db_role'] === 'partner')
                        echo '<li><a href="./new_bet.php?c=1">New bet</a></li>';
                    }
                    ?>
                </ul>
                <ul class="nav navbar-nav navbar-right">

                    <?php
                    if (isset($_SESSION['db_user_id'])) {
                      echo '<li><a href="./logout.php">Log out</a></li>';
                    } else {
                      echo '<li><a href="./login.php">Log in</a></li>';
                    }
                    ?>


                </ul>
            </div><!-- /.navbar-collapse -->
        </div><!-- /.container-fluid -->

    </nav>


    <div id="loading" style="display:none;">
        <label id="loading-image" alt="Loading"></label>
    </div> 