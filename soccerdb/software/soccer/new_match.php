<?php

$pageName = "SoccerDB - New match";
$title = "New match";

include "includes/header.php";

if (!isset($_SESSION['db_username']) || $_SESSION['db_role'] != 'operator') {
    header("Location: index.php", true, 301);
    exit();
}

include_once("functions/db.php");
include_once("functions/league.php");
include_once("functions/team.php");
include_once("functions/player.php");
include_once("functions/match.php");
include_once("functions/formation.php");

$db = dbconnect();
if (isset($db)) {
    prepareGetTeams($db);
    prepareGetLeagues($db);
    prepareInsertMatch($db);
    prepareInsertFormation($db);
}

if (isset($_GET["c"]) && !empty($_GET["c"])) {
    $_SESSION["queryNM"] = [];
}
if (!isset($_SESSION["queryBP"])) {
    $_SESSION["queryNM"] = [];
}

if (isset($_POST["newPlayerSubmit"])) {

    $errorMessage = [];
    $homePlayers = [];
    $awayPlayers = [];

    $league = $_POST["league"];
    $season = $_POST["season"];
    $stage = $_POST["stage"];
    $date = $_POST["date"];
    $homeTeam = $_POST["home_team"];
    $awayTeam = $_POST["away_team"];
    $homeGoal = $_POST["home_goal"];
    $awayGoal = $_POST["away_goal"];

    $_SESSION["queryNM"] = [];
    $_SESSION["queryNM"]["league"] = $_POST["league"];
    $_SESSION["queryNM"]["season"] = $_POST["season"];
    $_SESSION["queryNM"]["stage"] = $_POST["stage"];
    $_SESSION["queryNM"]["date"] = $_POST["date"];
    $_SESSION["queryNM"]["home_team"] = $_POST["home_team"];
    $_SESSION["queryNM"]["away_team"] = $_POST["away_team"];
    $_SESSION["queryNM"]["home_goal"] = $_POST["home_goal"];
    $_SESSION["queryNM"]["away_goal"] = $_POST["away_goal"];
    $_SESSION["queryNM"]["home_player_1"] = $_POST["home_player_1"];
    $_SESSION["queryNM"]["home_player_2"] = $_POST["home_player_2"];
    $_SESSION["queryNM"]["home_player_3"] = $_POST["home_player_3"];
    $_SESSION["queryNM"]["home_player_4"] = $_POST["home_player_4"];
    $_SESSION["queryNM"]["home_player_5"] = $_POST["home_player_5"];
    $_SESSION["queryNM"]["home_player_6"] = $_POST["home_player_6"];
    $_SESSION["queryNM"]["home_player_7"] = $_POST["home_player_7"];
    $_SESSION["queryNM"]["home_player_8"] = $_POST["home_player_8"];
    $_SESSION["queryNM"]["home_player_9"] = $_POST["home_player_9"];
    $_SESSION["queryNM"]["home_player_10"] = $_POST["home_player_10"];
    $_SESSION["queryNM"]["home_player_11"] = $_POST["home_player_11"];
    $_SESSION["queryNM"]["away_player_1"] = $_POST["away_player_1"];
    $_SESSION["queryNM"]["away_player_2"] = $_POST["away_player_2"];
    $_SESSION["queryNM"]["away_player_3"] = $_POST["away_player_3"];
    $_SESSION["queryNM"]["away_player_4"] = $_POST["away_player_4"];
    $_SESSION["queryNM"]["away_player_5"] = $_POST["away_player_5"];
    $_SESSION["queryNM"]["away_player_6"] = $_POST["away_player_6"];
    $_SESSION["queryNM"]["away_player_7"] = $_POST["away_player_7"];
    $_SESSION["queryNM"]["away_player_8"] = $_POST["away_player_8"];
    $_SESSION["queryNM"]["away_player_9"] = $_POST["away_player_9"];
    $_SESSION["queryNM"]["away_player_10"] = $_POST["away_player_10"];
    $_SESSION["queryNM"]["away_player_11"] = $_POST["away_player_11"];
    $_SESSION["queryNM"]["hidden_home_player_1"] = $_POST["hidden_home_player_1"];
    $_SESSION["queryNM"]["hidden_home_player_2"] = $_POST["hidden_home_player_2"];
    $_SESSION["queryNM"]["hidden_home_player_3"] = $_POST["hidden_home_player_3"];
    $_SESSION["queryNM"]["hidden_home_player_4"] = $_POST["hidden_home_player_4"];
    $_SESSION["queryNM"]["hidden_home_player_5"] = $_POST["hidden_home_player_5"];
    $_SESSION["queryNM"]["hidden_home_player_6"] = $_POST["hidden_home_player_6"];
    $_SESSION["queryNM"]["hidden_home_player_7"] = $_POST["hidden_home_player_7"];
    $_SESSION["queryNM"]["hidden_home_player_8"] = $_POST["hidden_home_player_8"];
    $_SESSION["queryNM"]["hidden_home_player_9"] = $_POST["hidden_home_player_9"];
    $_SESSION["queryNM"]["hidden_home_player_10"] = $_POST["hidden_home_player_10"];
    $_SESSION["queryNM"]["hidden_home_player_11"] = $_POST["hidden_home_player_11"];
    $_SESSION["queryNM"]["hidden_away_player_1"] = $_POST["hidden_away_player_1"];
    $_SESSION["queryNM"]["hidden_away_player_2"] = $_POST["hidden_away_player_2"];
    $_SESSION["queryNM"]["hidden_away_player_3"] = $_POST["hidden_away_player_3"];
    $_SESSION["queryNM"]["hidden_away_player_4"] = $_POST["hidden_away_player_4"];
    $_SESSION["queryNM"]["hidden_away_player_5"] = $_POST["hidden_away_player_5"];
    $_SESSION["queryNM"]["hidden_away_player_6"] = $_POST["hidden_away_player_6"];
    $_SESSION["queryNM"]["hidden_away_player_7"] = $_POST["hidden_away_player_7"];
    $_SESSION["queryNM"]["hidden_away_player_8"] = $_POST["hidden_away_player_8"];
    $_SESSION["queryNM"]["hidden_away_player_9"] = $_POST["hidden_away_player_9"];
    $_SESSION["queryNM"]["hidden_away_player_10"] = $_POST["hidden_away_player_10"];
    $_SESSION["queryNM"]["hidden_away_player_11"] = $_POST["hidden_away_player_11"];


    if (!empty($awayTeam) && !empty($awayTeam) && $homeTeam === $awayTeam)
        array_push($errorMessage, "The selected teams must be different");


    for ($i = 1; $i <= 11; $i++) {
        $strHomePlayer = "hidden_home_player_" . $i;
        $strAwayPlayer = "hidden_away_player_" . $i;
        if(!empty($_POST["home_player_".$i]) && empty($_POST[$strHomePlayer])){
            array_push($errorMessage, $_POST["home_player_".$i]. " is not present in the system");
        }
        if(!empty($_POST["away_player_".$i]) && empty($_POST[$strAwayPlayer])){
            array_push($errorMessage, $_POST["away_player_".$i]. " is not present in the system");
        }
        if (isset($_POST[$strHomePlayer]) && !empty($_POST[$strHomePlayer])) {
            array_push($homePlayers, $_POST[$strHomePlayer]);
        }
        if (isset($_POST[$strAwayPlayer]) && !empty($_POST[$strAwayPlayer])) {
            array_push($awayPlayers, $_POST[$strAwayPlayer]);
        }
    }

    if ((count($homePlayers) != count(array_unique($homePlayers))) || (count($awayPlayers) != count(array_unique($awayPlayers)))) {
        array_push($errorMessage, "A player cannot be present in the same team more than once");
    }

    $intersect = array_intersect($homePlayers, $awayPlayers);
    if (!empty($intersect)) {
        array_push($errorMessage, "A player cannot play in two different teams in the same match");
    }

    if (empty($errorMessage)) {
        $matchId = insertMatch($db, [$_SESSION['db_user_id'], 0, $date, $stage, $season, $homeTeam, $awayTeam, $homeGoal, $awayGoal, $league, 0]);
        if ($matchId < 1) {
            switch ($matchId) {
                case -50:
                    $errorMessage = "The match has already been entered";
                    break;
                default:
                    array_push($errorMessage, "An error occurred while trying to insert the match");
                    break;
            }
        }
    }

    if (empty($errorMessage)) {
        for ($j = 1; $j <= 11; $j++) {
            if (!empty($_POST["hidden_home_player_" . $j])) {
                $result = insertFormation($db, [$_SESSION['db_user_id'], $matchId, $_POST["hidden_home_player_" . $j], $_POST["home_team"]]);
                if ($result < 1) {
                    array_push($errorMessage, "An error occurred while trying to insert the player " . $_POST["home_player_" . $j]);
                }
            }
            if (!empty($_POST["hidden_away_player_" . $j])) {
                $result = insertFormation($db, [$_SESSION['db_user_id'], $matchId, $_POST["hidden_away_player_" . $j], $_POST["away_team"]]);
                if ($result < 1) {
                    array_push($errorMessage, "An error occurred while trying to insert the player " . $_POST["away_player_" . $j]);
                }
            }
        }
    }

    if (empty($errorMessage)) {
        $_SESSION["queryNM"] = [];
        $success = true;
    }
}
?>

<link href="./assets/bootstrap-datepicker/css/bootstrap-datepicker.min.css" rel="stylesheet">

<style>
    #newMatchContainer {
        padding: 15px;
        text-align: center;
    }

    #submitNewMatch {
        display: block;
        width: 300px;
        margin: auto;
    }

    .footer {
        position: initial !important;
    }
</style>

<div id="newMatchContainer" class="container-fluid">

    <div class="row">
        <div class="col-xs-12">
            <ol class="breadcrumb">
                <li><a href="index.php">Home</a></li>
                <li class="active"><?php echo $title; ?></li>
            </ol>
        </div>
    </div>

    <div class="row">
        <div class="col-xs-12">
            <div class="page-header">
                <h1><?php echo $title; ?></h1>
            </div>
        </div>
    </div>

    <?php
    if (!empty($errorMessage)) {
        ?>

    <div class="panel panel-danger">
        <div class="panel-heading">
            <h3 class="panel-title">Error!</h3>
        </div>
        <div class="panel-body">
            <?php 
            foreach ($errorMessage as $message) {
                echo "<p>" . $message . "</p>";
            }
            ?>
        </div>
    </div>

    <?php 
} ?>

    <?php if (isset($success) && $success) { ?>

    <div class="panel panel-success">
        <div class="panel-heading">
            <h3 class="panel-title">Success!</h3>
        </div>
        <div class="panel-body">
            <p>The match has correctly been inserted</p>
        </div>
    </div>

    <?php 
} ?>


    <div class="row">
        <div class="col-xs-12">
            <form id="newMatch" action="new_match.php" method="post" class="form-horizontal">

                <div class="row">
                    <div class="col-xs-12">

                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">General information</h3>
                            </div>
                            <div class="panel-body">
                                <div class="col-sm-3" style="text-align:left;">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">League</label>
                                        <select class="form-control" name="league">
                                            <?php
                                            $result = getLeagues($db, []);
                                            while ($row = pg_fetch_row($result)) {
                                                if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["league"]) && $row[0] === $_SESSION["queryNM"]["league"])
                                                    echo '<option value="' . $row[0] . '" selected>' . $row[0] . '</option>';
                                                else
                                                    echo '<option value="' . $row[0] . '" >' . $row[0] . '</option>';
                                            }
                                            ?>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-sm-3" style="text-align:left;">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">Season</label>
                                        <input type="text" class="form-control" name="season" placeholder="YYYY/YYYY" pattern="^\d{4}\/\d{4}$" data-error="Must comply with the required format" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["season"])) echo $_SESSION["queryNM"]["season"] ?>" required>
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                                <div class="col-sm-3" style="text-align:left;">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">Stage</label>
                                        <input id="stage" type="number" min="0" class="form-control" name="stage" data-error="must be a positive integer number" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["stage"])) echo $_SESSION["queryNM"]["stage"] ?>" required>
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                                <div class="col-sm-3" style="text-align:left;">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">Date</label>
                                        <input type="text" class="form-control date" name="date" data-error="must be a valid date" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["date"])) echo $_SESSION["queryNM"]["date"] ?>" required>
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-6">

                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">Home team</h3>
                            </div>
                            <div class="panel-body">


                                <div class="col-sm-8">
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Team</label>
                                        <div class="col-sm-9">
                                            <select name="home_team" class="form-control ddlTeam">
                                                <?php
                                                $result = getTeams($db, []);
                                                while ($row = pg_fetch_row($result)) {
                                                    if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_team"]) && $row[0] === $_SESSION["queryNM"]["home_team"])
                                                        echo '<option value="' . $row[0] . '" selected>' . $row[1] . '</option>';
                                                    else
                                                        echo '<option value="' . $row[0] . '" >' . $row[1] . '</option>';
                                                }
                                                ?>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Goal</label>
                                        <div class="col-sm-8">
                                            <input type="number" min="0" class="form-control" name="home_goal" data-error="must be a positive integer number" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_goal"])) echo $_SESSION["queryNM"]["home_goal"] ?>" required>
                                            <div class="help-block with-errors"></div>
                                        </div>
                                    </div>
                                </div>


                                <div class="col-sm-12" style="text-align:left;margin-top:10px;margin-bottom:10px">
                                    <div class="col-sm-8 col-sm-push-2" style="padding:0px">
                                        <label>Formation:</label>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_1" type="text" class="form-control autocomplete" name="home_player_1" data-nctrl="1" data-type-player="home" placeholder="player's name 1" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_1"])) echo $_SESSION["queryNM"]["home_player_1"] ?>">
                                        <input type="hidden" id="hidden_home_player_1" name="hidden_home_player_1" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_1"])) echo $_SESSION["queryNM"]["hidden_home_player_1"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_2" type="text" class="form-control autocomplete" name="home_player_2" data-nctrl="2" data-type-player="home" placeholder="player's name 2" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_2"])) echo $_SESSION["queryNM"]["home_player_2"] ?>">
                                        <input type="hidden" id="hidden_home_player_2" name="hidden_home_player_2" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_2"])) echo $_SESSION["queryNM"]["hidden_home_player_2"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_3" type="text" class="form-control autocomplete" name="home_player_3" data-nctrl="3" data-type-player="home" placeholder="player's name 3" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_3"])) echo $_SESSION["queryNM"]["home_player_3"] ?>">
                                        <input type="hidden" id="hidden_home_player_3" name="hidden_home_player_3" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_3"])) echo $_SESSION["queryNM"]["hidden_home_player_3"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_4" type="text" class="form-control autocomplete" name="home_player_4" data-nctrl="4" data-type-player="home" placeholder="player's name 4" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_4"])) echo $_SESSION["queryNM"]["home_player_4"] ?>">
                                        <input type="hidden" id="hidden_home_player_4" name="hidden_home_player_4" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_4"])) echo $_SESSION["queryNM"]["hidden_home_player_4"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_5" type="text" class="form-control autocomplete" name="home_player_5" data-nctrl="5" data-type-player="home" placeholder="player's name 5" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_5"])) echo $_SESSION["queryNM"]["home_player_5"] ?>">
                                        <input type="hidden" id="hidden_home_player_5" name="hidden_home_player_5" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_5"])) echo $_SESSION["queryNM"]["hidden_home_player_5"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_6" type="text" class="form-control autocomplete" name="home_player_6" data-nctrl="6" data-type-player="home" placeholder="player's name 6" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_6"])) echo $_SESSION["queryNM"]["home_player_6"] ?>">
                                        <input type="hidden" id="hidden_home_player_6" name="hidden_home_player_6" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_6"])) echo $_SESSION["queryNM"]["hidden_home_player_6"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_7" type="text" class="form-control autocomplete" name="home_player_7" data-nctrl="7" data-type-player="home" placeholder="player's name 7" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_7"])) echo $_SESSION["queryNM"]["home_player_7"] ?>">
                                        <input type="hidden" id="hidden_home_player_7" name="hidden_home_player_7" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_7"])) echo $_SESSION["queryNM"]["hidden_home_player_7"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_8" type="text" class="form-control autocomplete" name="home_player_8" data-nctrl="8" data-type-player="home" placeholder="player's name 8" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_8"])) echo $_SESSION["queryNM"]["home_player_8"] ?>">
                                        <input type="hidden" id="hidden_home_player_8" name="hidden_home_player_8" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_8"])) echo $_SESSION["queryNM"]["hidden_home_player_8"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_9" type="text" class="form-control autocomplete" name="home_player_9" data-nctrl="9" data-type-player="home" placeholder="player's name 9" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_9"])) echo $_SESSION["queryNM"]["home_player_9"] ?>">
                                        <input type="hidden" id="hidden_home_player_9" name="hidden_home_player_9" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_9"])) echo $_SESSION["queryNM"]["hidden_home_player_9"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_10" type="text" class="form-control autocomplete" name="home_player_10" data-nctrl="10" data-type-player="home" placeholder="player's name 10" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_10"])) echo $_SESSION["queryNM"]["home_player_10"] ?>">
                                        <input type="hidden" id="hidden_home_player_10" name="hidden_home_player_10" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_10"])) echo $_SESSION["queryNM"]["hidden_home_player_10"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="home_player_11" type="text" class="form-control autocomplete" name="home_player_11" data-nctrl="11" data-type-player="home" placeholder="player's name 11" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["home_player_11"])) echo $_SESSION["queryNM"]["home_player_11"] ?>">
                                        <input type="hidden" id="hidden_home_player_11" name="hidden_home_player_11" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_home_player_11"])) echo $_SESSION["queryNM"]["hidden_home_player_11"] ?>">
                                    </div>
                                </div>

                            </div>
                            <!--end panel body-->
                        </div>
                        <!--end panel-->

                    </div>

                    <div class="col-sm-6">

                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">Away team</h3>
                            </div>
                            <div class="panel-body">

                                <div class="col-sm-8">
                                    <div id="awayTeamFormGroup" class="form-group">
                                        <label class="col-sm-3 control-label">Team</label>
                                        <div class="col-sm-9">
                                            <select id="awayTeam" name="away_team" class="form-control ddlTeam">
                                                <?php
                                                $result = getTeams($db, []);
                                                while ($row = pg_fetch_row($result)) {
                                                    if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_team"]) && $row[0] === $_SESSION["queryNM"]["away_team"])
                                                        echo '<option value="' . $row[0] . '" selected>' . $row[1] . '</option>';
                                                    else
                                                        echo '<option value="' . $row[0] . '" >' . $row[1] . '</option>';
                                                }
                                                ?>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label">Goal</label>
                                        <div class="col-sm-8">
                                            <input type="number" min="0" class="form-control" name="away_goal" data-error="must be a positive integer number" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_goal"])) echo $_SESSION["queryNM"]["away_goal"] ?>" required>
                                            <div class="help-block with-errors"></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-12" style="text-align:left;margin-top:10px;margin-bottom:10px">
                                    <div class="col-sm-8 col-sm-push-2" style="padding:0px">
                                        <label>Formation:</label>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_1" type="text" class="form-control autocomplete" name="away_player_1" data-nctrl="1" data-type-player="away" placeholder="player's name 1" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_1"])) echo $_SESSION["queryNM"]["away_player_1"] ?>">
                                        <input type="hidden" id="hidden_away_player_1" name="hidden_away_player_1" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_1"])) echo $_SESSION["queryNM"]["hidden_away_player_1"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_2" type="text" class="form-control autocomplete" name="away_player_2" data-nctrl="2" data-type-player="away" placeholder="player's name 2" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_2"])) echo $_SESSION["queryNM"]["away_player_2"] ?>">
                                        <input type="hidden" id="hidden_away_player_2" name="hidden_away_player_2" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_2"])) echo $_SESSION["queryNM"]["hidden_away_player_2"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_3" type="text" class="form-control autocomplete" name="away_player_3" data-nctrl="3" data-type-player="away" placeholder="player's name 3" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_3"])) echo $_SESSION["queryNM"]["away_player_3"] ?>">
                                        <input type="hidden" id="hidden_away_player_3" name="hidden_away_player_3" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_3"])) echo $_SESSION["queryNM"]["hidden_away_player_3"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_4" type="text" class="form-control autocomplete" name="away_player_4" data-nctrl="4" data-type-player="away" placeholder="player's name 4" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_4"])) echo $_SESSION["queryNM"]["away_player_4"] ?>">
                                        <input type="hidden" id="hidden_away_player_4" name="hidden_away_player_4" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_4"])) echo $_SESSION["queryNM"]["hidden_away_player_4"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_5" type="text" class="form-control autocomplete" name="away_player_5" data-nctrl="5" data-type-player="away" placeholder="player's name 5" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_5"])) echo $_SESSION["queryNM"]["away_player_5"] ?>">
                                        <input type="hidden" id="hidden_away_player_5" name="hidden_away_player_5" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_5"])) echo $_SESSION["queryNM"]["hidden_away_player_5"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_6" type="text" class="form-control autocomplete" name="away_player_6" data-nctrl="6" data-type-player="away" placeholder="player's name 6" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_6"])) echo $_SESSION["queryNM"]["away_player_6"] ?>">
                                        <input type="hidden" id="hidden_away_player_6" name="hidden_away_player_6" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_6"])) echo $_SESSION["queryNM"]["hidden_away_player_6"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_7" type="text" class="form-control autocomplete" name="away_player_7" data-nctrl="7" data-type-player="away" placeholder="player's name 7" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_7"])) echo $_SESSION["queryNM"]["away_player_7"] ?>">
                                        <input type="hidden" id="hidden_away_player_7" name="hidden_away_player_7" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_7"])) echo $_SESSION["queryNM"]["hidden_away_player_7"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_8" type="text" class="form-control autocomplete" name="away_player_8" data-nctrl="8" data-type-player="away" placeholder="player's name 8" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_8"])) echo $_SESSION["queryNM"]["away_player_8"] ?>">
                                        <input type="hidden" id="hidden_away_player_8" name="hidden_away_player_8" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_8"])) echo $_SESSION["queryNM"]["hidden_away_player_8"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_9" type="text" class="form-control autocomplete" name="away_player_9" data-nctrl="9" data-type-player="away" placeholder="player's name 9" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_9"])) echo $_SESSION["queryNM"]["away_player_9"] ?>">
                                        <input type="hidden" id="hidden_away_player_9" name="hidden_away_player_9" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_9"])) echo $_SESSION["queryNM"]["hidden_away_player_9"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_10" type="text" class="form-control autocomplete" name="away_player_10" data-nctrl="10" data-type-player="away" placeholder="player's name 10" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_10"])) echo $_SESSION["queryNM"]["away_player_10"] ?>">
                                        <input type="hidden" id="hidden_away_player_10" name="hidden_away_player_10" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_10"])) echo $_SESSION["queryNM"]["hidden_away_player_10"] ?>">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-8 col-sm-push-2">
                                        <input id="away_player_11" type="text" class="form-control autocomplete" name="away_player_11" data-nctrl="11" data-type-player="away" placeholder="player's name 11" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["away_player_11"])) echo $_SESSION["queryNM"]["away_player_11"] ?>">
                                        <input type="hidden" id="hidden_away_player_11" name="hidden_away_player_11" value="<?php if (isset($_SESSION["queryNM"]) && !empty($_SESSION["queryNM"]["hidden_away_player_11"])) echo $_SESSION["queryNM"]["hidden_away_player_11"] ?>">
                                    </div>
                                </div>

                            </div>
                            <!--end panel body-->
                        </div>
                        <!--end panel-->

                    </div>
                </div>

                <div class="row" style="margin-bottom:10px;margin-top:10px">
                    <div class="col-sm-4 col-sm-push-4">
                        <button id="submitNewMatch" class="btn btn-primary" name="newPlayerSubmit" type="submit">Insert</button>
                    </div>
                </div>

            </form>
        </div>
    </div>

</div>

<?php
include "includes/basic_scripts.php";
?>

<script src="assets/jquery-ui/jquery-ui.min.js"></script>
<script src="assets/scrollable_autocomplete/jquery.ui.autocomplete.scroll.min.js"></script>
<script src="assets/bootstrap-datepicker/js/bootstrap-datepicker.min.js"></script>
<!-- <script src="assets/bootstrap-datepicker/locales/bootstrap-datepicker.it.min.js"></script> -->
<script src="assets/bootstrap-validator/validator.min.js"></script>

<script>
    var players;

    $(document).ready(function() {

        $.ajax({
            url: 'get_players.php',
            type: 'get',
            dataType: 'JSON',
            success: function(response) {
                players = response;
                $('.autocomplete').autocomplete({
                    maxShowItems: 5, // Make list height fit to 5 items when items are over 5.
                    source: response,
                    select: function(event, ui) {
                        var txt = document.getElementById(event.target.id);
                        var hdn = document.getElementById('hidden_' + txt.dataset.typePlayer + '_player_' + txt.dataset.nctrl);
                        hdn.value = ui.item.id;
                    }
                });
            }
        });

        $(".autocomplete").on("keydown", function(event) {
            var KeyID = event.keyCode;
            switch (KeyID) {
                case 8:
                    var txt = document.getElementById(event.target.id);
                    var hdn = document.getElementById('hidden_' + txt.dataset.typePlayer + '_player_' + txt.dataset.nctrl);
                    hdn.value = '';
                    break;
                default:
                    break;
            }
        });

        $(".autocomplete").on("blur", function(event) {
            var txt = document.getElementById(event.target.id);
            var hdn = document.getElementById('hidden_' + txt.dataset.typePlayer + '_player_' + txt.dataset.nctrl);
            var found;
            players.forEach(function(element) {
                if (element.value === txt.value) {
                    hdn.value = element.id;
                    found = true;
                }
            });
            console.log(found);
            if (!found) {
                hdn.value = "";
            }
        });

        $('.date').datepicker({
            format: "dd/mm/yyyy",
            language: "it"
        });

        $('#newMatch').validator();

    });
</script>

<?php
include "includes/footer.php";
?> 