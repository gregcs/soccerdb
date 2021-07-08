<?php
$pageName = "SoccerDB - Home";

include "includes/header.php";

?>

<style>
    #welcome {
        position: absolute;
        top: 50%;
        left: 50%;
        -webkit-transform: translate(-50%, -50%);
        transform: translate(-50%, -50%);
        z-index: -99;
    }

    .jumbotron {
        border-radius: 15px 15px 15px 15px;
        -moz-border-radius: 15px 15px 15px 15px;
        -webkit-border-radius: 15px 15px 15px 15px;
    }
</style>

<div id="welcome" class="col-md-6 col-md-push-3">
    <div class="jumbotron">
        <div class="container-fluid" style="text-align:center;">
            <?php if (!isset($_SESSION["db_user_id"])) { ?>
            <h2>Welcome to <span class="text-success"><b>SoccerDB</b></span></h2>
            <p>a platform for football fans</p>
            <br>
            <div class="container">
                <div class="col-sm-5">
                    <a class="btn btn-primary btn-lg" style="max-width:200px;min-width:200px" href="./best_players.php?c='1'" role="button">View best players</a>
                </div>
                <div class="col-sm-2">
                    <p class="text-muted" style="padding-top:10px">or</p>
                </div>
                <div class="col-sm-5">
                    <p><a class="btn btn-primary btn-lg" style="max-width:200px;min-width:200px" href="./home_ranking.php" role="button">View rankings</a></p>
                </div>
            </div>
            <?php 
        } ?>

            <?php if (isset($_SESSION["db_user_id"])) { ?>
            <h2>Welcome <span class="text-success"><b><?php echo $_SESSION["db_username"]; ?></b></span></h2>
            <br>
            <br>
            <div class="container">
                <div class="col-sm-4">
                    <p><a style="width:180px" class="btn btn-primary btn-md" href="./best_players.php?c=1" role="button">View best players</a></p>
                </div>
                <div class="col-sm-4">
                    <p><a style="width:180px" class="btn btn-primary btn-md" href="./home_ranking.php" role="button">View rankings</a></p>
                </div>
                <?php if ($_SESSION['db_role'] === 'operator') { ?>
                <div class="col-sm-4">
                    <p><a style="width:180px" class="btn btn-primary btn-md" href="./new_match.php?c=1" role="button">Insert new match</a></p>
                </div>

                <?php 
            } ?>

                <?php if ($_SESSION['db_role'] === 'administrator') { ?>
                <div class="col-sm-4">
                    <div class="btn-group">
                        <button style="width:180px" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                            Upload <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <li><a href="./load_match_csv.php">Match file</a></li>
                            <li><a href="./load_stats_csv.php">Player's stats file</a></li>
                        </ul>
                    </div>
                </div>

                <?php 
            } ?>


                <?php if ($_SESSION['db_role'] === 'partner') { ?>
                <div class="col-sm-4">
                    <p><a style="width:180px" class="btn btn-primary btn-md" href="./new_bet.php?c=1" role="button">Insert new bet</a></p>
                </div>

                <?php 
            } ?>

            </div>
            <?php 
        } ?>

        </div>
    </div>
</div>

<?php
include "includes/basic_scripts.php";
?>

<?php
include "includes/footer.php";
?> 