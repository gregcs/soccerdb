<?php

if ((!isset($_GET["match"]) || empty($_GET["match"])) || (!isset($_GET["team"]) || empty($_GET["team"])) || (!isset($_GET["player"]) || empty($_GET["player"])) || (!isset($_GET["date"]) || empty($_GET["date"]))) {
    header("Location: best_players.php", true, 301);
    exit();
}

include_once("functions/db.php");
include_once("functions/player.php");

$db = dbconnect();
prepareGetPlayerStats($db);
$result = getPlayerStats($db, [$_GET["match"], $_GET["team"], $_GET["player"], $_GET["date"]]);

if (isset($result) && !empty($result)) {
    $row = pg_fetch_assoc($result);

    if (!empty($row)) {

        $pageName = "SoccerDB - " . $row["name"] . " - " . $row["attribute_date"];
        $title = $row["name"] . "-" . $row["attribute_date"];

        include "includes/header.php";
    } else {
        header("Location: best_players.php", true, 301);
        exit();
    }
}

?>

<style>
    #contentContainer {
        padding: 15px;
        padding-top: 0px;
        text-align: center;
    }

    table thead tr th {
        text-align: center;
    }

    .input-group-addon:first-child {
        min-width: 170px;
    }

    .input-group{
        margin:5px;
    }
</style>

<div id="contentContainer" class="container-fluid">

    <ol class="breadcrumb">
        <li><a href="index.php">Home</a></li>
        <li><a href="best_players.php?c='1'">Best players</a></li>
        <li class="active"><?php echo $title ?></li>
    </ol>

    <div class="page-header">
        <h1><?php echo $row["name"]; ?></h1>
        <p class="text-muted"><?php echo $row["attribute_date"]; ?></p>
    </div>


    <div class="panel panel-primary">
        <div class="panel-heading">General information</div>
        <div class="panel-body">
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon">Id</span>
                    <input type="text" class="form-control" placeholder="<?php echo $row["player"]; ?>" disabled>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon">Name</span>
                    <input type="text" class="form-control" placeholder="<?php echo $row["name"]; ?>" disabled>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon">Birthday</span>
                    <input type="text" class="form-control" placeholder="<?php echo $row["birthday"]; ?>" disabled>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon">Weight</span>
                    <input type="text" class="form-control" placeholder="<?php echo $row["weight"]; ?>" disabled>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon">Height</span>
                    <input type="text" class="form-control" placeholder="<?php echo $row["height"]; ?>" disabled>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon">Overall rating</span>
                    <input type="text" class="form-control" placeholder="<?php echo $row["overall_rating"]; ?>" disabled>
                </div>
            </div>
        </div>
    </div>

    <div class="panel panel-primary">
        <div class="panel-heading">Stats</div>
        <div class="panel-body">
            <div class="row">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Potential</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["potental"]) ? '-' : $row["potental"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Preferred foot</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["preferred_foot"]) ? '-' : $row["preferred_foot"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Attacking work rate</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["attacking_work_rate"]) ? '-' : $row["attacking_work_rate"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Defensive work rate</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["defensive_work_rate"]) ? '-' : $row["defensive_work_rate"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Crossing</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["crossing"]) ? '-' : $row["crossing"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Finishing</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["finishing"]) ? '-' : $row["finishing"] ?>" disabled>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top:10px">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Heading accuracy</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["heading_accuracy"]) ? '-' : $row["heading_accuracy"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Short passing</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["short_passing"]) ? '-' : $row["short_passing"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Volleys</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["volleys"]) ? '-' : $row["volleys"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Dribbling</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["dribbling"]) ? '-' : $row["dribbling"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Curve</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["curve"]) ? '-' : $row["curve"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Free kick accuracy</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["free_kick_accuracy"]) ? '-' : $row["free_kick_accuracy"] ?>" disabled>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top:10px">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Long passing</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["long_passing"]) ? '-' : $row["long_passing"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Ball control</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["ball_control"]) ? '-' : $row["ball_control"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Acceleration</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["acceleration"]) ? '-' : $row["acceleration"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Sprint speed</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["sprint_speed"]) ? '-' : $row["sprint_speed"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Agility</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["agility"]) ? '-' : $row["agility"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Reactions</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["reactions"]) ? '-' : $row["reactions"] ?>" disabled>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top:10px">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Balance</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["balance"]) ? '-' : $row["balance"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Shot power</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["shot_power"]) ? '-' : $row["shot_power"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Jumping</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["jumping"]) ? '-' : $row["jumping"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Stamina</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["stamina"]) ? '-' : $row["stamina"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Stenght</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["strength"]) ? '-' : $row["strength"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Long shots</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["long_shots"]) ? '-' : $row["long_shots"] ?>" disabled>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top:10px">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Aggression</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["aggression"]) ? '-' : $row["aggression"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Interceptions</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["interceptions"]) ? '-' : $row["interceptions"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Positioning</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["positioning"]) ? '-' : $row["positioning"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Vision</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["vision"]) ? '-' : $row["vision"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Penalties</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["penalties"]) ? '-' : $row["penalties"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Marking</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["marking"]) ? '-' : $row["marking"] ?>" disabled>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top:10px">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Standing tackle</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["standing_tackle"]) ? '-' : $row["standing_tackle"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">Sliding Tackle</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["sliding_tackle"]) ? '-' : $row["sliding_tackle"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">GK Diving</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["gk_diving"]) ? '-' : $row["gk_diving"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">GK handling</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["gk_handling"]) ? '-' : $row["gk_handling"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">GK Kicking</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["gk_kicking"]) ? '-' : $row["gk_kicking"] ?>" disabled>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">GK Positioning</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["gk_positioning"]) ? '-' : $row["gk_positioning"] ?>" disabled>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top:10px">
                <div class="col-md-2">
                    <div class="input-group">
                        <span class="input-group-addon">GK Reflexes</span>
                        <input type="text" class="form-control" placeholder="<?php echo empty($row["gk_reflexes"]) ? '-' : $row["gk_reflexes"] ?>" disabled>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


</div>

<?php
include "includes/basic_scripts.php";
?>


<?php
include "includes/footer.php"
?> 