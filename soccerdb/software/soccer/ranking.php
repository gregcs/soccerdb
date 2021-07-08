<?php

if (count($_GET) === 0) {
    $_SESSION["queryR"] = [];
    header("Location: home_ranking.php", true, 301);
    exit();
}

if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

$pageName = 'SoccerDB - Ranking';
if (isset($_GET["league"]) && !empty($_GET["league"]) && isset($_GET["season"]) && !empty($_GET["season"])) {
    $pageName = 'SoccerDB - ' . $_GET["league"] . ' - ' . $_GET["season"];
} else {
    if (count($_GET) !== 0) {
        $pageName = 'SoccerDB - ' . $_SESSION["queryR"]["league"] . ' - ' . $_SESSION["queryR"]["season"];
    }
}

include "includes/header.php";

include_once("functions/db.php");
include_once("functions/league.php");
include_once("includes/pagination.php");

$db = dbconnect();

if (!isset($_SESSION["queryR"])) {
    $_SESSION["queryR"] = [];
}

if (isset($_GET["league"]) && !empty($_GET["league"]) && isset($_GET["season"]) && !empty($_GET["season"])) {
    $_SESSION["queryR"]["league"] = $_GET["league"];
    $_SESSION["queryR"]["season"] = $_GET["season"];
}

$title = $_SESSION["queryR"]["league"] . " - " . $_SESSION["queryR"]["season"];

$query = "
SELECT * FROM ranking JOIN team ON ranking.team = team.id WHERE league = '" . $_SESSION["queryR"]["league"] . "' AND season = '" . $_SESSION["queryR"]["season"] . "'";

$limit = (isset($_GET['limit'])) ? $_GET['limit'] : 10;
$page = (isset($_GET['page'])) ? $_GET['page'] : 1;
$links = 5;
$paginator = new Paginator($db, $query);
$results = $paginator->getData($limit, $page);


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
</style>

<div id="contentContainer" class="container-fluid">

    <ol class="breadcrumb">
        <li><a href="index.php">Home</a></li>
        <li><a href="home_ranking.php">Rankings</a></li>
        <li class="active"><?php echo $title ?></li>
    </ol>

    <div class="page-header">
        <h1><?php echo $_SESSION["queryR"]["league"]; ?></h1>

        <h2><small><?php echo $_SESSION["queryR"]["season"]; ?></small></h2>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="col-sm-4 col-sm-push-4">

                <?php if (!empty($results->data)) { ?>
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th></th>
                                <th>Team</th>
                                <th>Wins</th>
                                <th>Ties</th>
                                <th>Points</th>
                            </tr>
                        <tbody>
                            <?php
                            $rowIndex = 1;
                            foreach ($results->data as $row) { ?>
                            <tr>
                                <td><?php echo $rowIndex; ?></td>
                                <td><?php echo $row["short_name"] ?></td>
                                <td><?php echo $row["matches_won"] ?></td>
                                <td><?php echo $row["tie"] ?></td>
                                <td><?php echo ($row["matches_won"] * 3) + ($row["tie"]) ?></td>
                            </tr>
                            <?php $rowIndex++;
                        } ?>
                        </tbody>
                        </thead>
                    </table>
                </div>
                <?php

            } else { ?>
                <div class="panel panel-primary">
                    <div class="panel-body">
                        There are no teams for this league in this season
                    </div>
                </div>
                <?php 
            } ?>
            </div>
        </div>
    </div>

    <?php if (!empty($results->data)) { ?>
    <div class="row">
        <div class="col-sm-12">
            <div class="col-sm-6 col-sm-push-3">
                <?php
                echo $paginator->createLinks($links, 'pagination pagination-md');
                ?>
            </div>
        </div>
    </div>
    <?php 
} ?>

</div>

<?php
include "includes/basic_scripts.php";
?>

<?php
include "includes/footer.php"
?> 