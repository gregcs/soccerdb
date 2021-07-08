<?php

$pageName = "SoccerDB - Best players";
$title = "Best players";

include "includes/header.php";

include_once("functions/db.php");
include_once("functions/team.php");
include_once("functions/match.php");
include_once("functions/player.php");
include_once("includes/pagination.php");

$db = dbconnect();
prepareGetTeams($db);
prepareGetBestPlayers($db);

$query = "SELECT m.id, m.date, m.stage, m.season, m.home,m.away, m.home_goal, m.away_goal, m.league, h.long_name AS home_team, a.long_name AS away_team 
FROM match AS m JOIN team AS h on m.home = h.id JOIN team AS a ON m.away= a.id";

if (isset($_GET["c"]) && !empty($_GET["c"])) {
    $_SESSION["queryBP"] = [];
}
if (!isset($_SESSION["queryBP"])) {
    $_SESSION["queryBP"] = [];
}
if (isset($_POST["resetFilter"])) {
    $_SESSION["queryBP"] = [];
}

if (isset($_POST["submitFindMatch"])) {

    $_SESSION["queryBP"]["id_match"] = $_POST["id_match"];
    $_SESSION["queryBP"]["league"] = $_POST["league"];
    $_SESSION["queryBP"]["hdn_league"] = $_POST["hdn_league"];
    $_SESSION["queryBP"]["home_team"] = $_POST["home_team"];
    $_SESSION["queryBP"]["hdn_home"] = $_POST["hdn_home"];
    $_SESSION["queryBP"]["away_team"] = $_POST["away_team"];
    $_SESSION["queryBP"]["hdn_away"] = $_POST["hdn_away"];
}

$idFiltered = false;
$leagueFiltered = false;
$homeFiltered = false;

if (!empty($_SESSION["queryBP"]["id_match"]) || !empty($_SESSION["queryBP"]["hdn_league"]) || !empty($_SESSION["queryBP"]["hdn_home"]) || !empty($_SESSION["queryBP"]["hdn_away"])) {
    $query = $query . " WHERE ";

    if (!empty($_SESSION["queryBP"]["id_match"])) {
        $query = $query . " m.id= " . $_SESSION["queryBP"]["id_match"];
        $idFiltered = true;
    }

    if (!empty($_SESSION["queryBP"]["hdn_league"])) {
        if (!$idFiltered) {
            $query = $query . " league= '" . $_SESSION["queryBP"]["hdn_league"] . "'";
            $leagueFiltered = true;
        } else
            $query = $query . " AND league= '" . $_SESSION["queryBP"]["hdn_league"] . "'";
    }

   
    if (!empty($_SESSION["queryBP"]["hdn_home"])) {
        if (!$idFiltered && !$leagueFiltered) {
            $query = $query . " home = " . $_SESSION["queryBP"]["hdn_home"];
            $homeFiltered = true;
        } else
            $query = $query . " AND home = " . $_SESSION["queryBP"]["hdn_home"];
    }

    if (!empty($_SESSION["queryBP"]["hdn_away"])) {
        if (!$idFiltered && !$leagueFiltered && !$homeFiltered) {
            $query = $query . " away = " . $_SESSION["queryBP"]["hdn_away"];
        } else
            $query = $query . " AND away = " . $_SESSION["queryBP"]["hdn_away"];
    }
}


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

    .footer {
        position:initial !important;
    }
</style>

<div id="contentContainer" class="container-fluid">

    <ol class="breadcrumb">
        <li><a href="index.php">Home</a></li>
        <li class="active"><?php echo $title; ?></li>
    </ol>

    <div class="page-header">
        <h1><?php echo $title; ?></h1>
    </div>

    <div class="row">
        <div class="col-sm-12">

            <form id="findMatch" action="best_players.php" method="post">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h3 class="panel-title"><span class="glyphicon glyphicon-search">&nbsp;Search</span></h3>
                    </div>
                    <div class="panel-body" style="text-align:left">
                        <div class="col-sm-8 col-sm-push-2">
                            <div class="col-sm-3">
                                <div class="form-group">
                                    <label>ID match</label>
                                    <input id="idMatch" type="number" min="0" class="form-control" name="id_match" value="<?php echo (!empty($_SESSION["queryBP"]["id_match"])) ? $_SESSION["queryBP"]["id_match"] : ''; ?>">
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="form-group">
                                    <label>League</label>
                                    <input id="league" type="text" class="form-control" name="league" value="<?php echo (!empty($_SESSION["queryBP"]["league"])) ? $_SESSION["queryBP"]["league"] : ''; ?>">
                                    <input type="hidden" id="hdn_league" name="hdn_league" value="<?php echo (!empty($_SESSION["queryBP"]["hdn_league"])) ? $_SESSION["queryBP"]["hdn_league"] : ''; ?>">
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="form-group">
                                    <label>Home team</label>
                                    <input id="homeTeam" type="text" class="form-control get-teams" name="home_team" value="<?php echo (!empty($_SESSION["queryBP"]["home_team"])) ? $_SESSION["queryBP"]["home_team"] : ''; ?>">
                                    <input type="hidden" id="hdn_homeTeam" name="hdn_home" value="<?php echo (!empty($_SESSION["queryBP"]["hdn_home"])) ? $_SESSION["queryBP"]["hdn_home"] : ''; ?>">
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="form-group">
                                    <label>Away team</label>
                                    <input id="awayTeam" type="text" class="form-control get-teams" name="away_team" value="<?php echo (!empty($_SESSION["queryBP"]["away_team"])) ? $_SESSION["queryBP"]["away_team"] : ''; ?>">
                                    <input type="hidden" id="hdn_awayTeam" name="hdn_away" value="<?php echo (!empty($_SESSION["queryBP"]["hdn_away"])) ? $_SESSION["queryBP"]["hdn_away"] : ''; ?>">
                                </div>
                            </div>
                            <div class="col-sm-4 col-sm-push-4" style="text-align:center">
                                <button name="submitFindMatch" type="submit" class="btn btn-primary">SEARCH</button>
                                <button name="resetFilter" type="submit" class="btn btn-primary">RESET</button>
                            </div>
                        </div>
                    </div>
                </div>
            </form>

        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">

            <?php if (!empty($results->data)) { ?>

            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>League</th>
                            <th>Season</th>
                            <th>Stage</th>
                            <th>Home team</th>
                            <th>Away team</th>
                            <th>Home goal</th>
                            <th>Away goal</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php 
                        $i = 1;
                        foreach ($results->data as $row) { ?>
                        <tr>
                            <td><?php echo $row["id"] ?></td>
                            <td><?php echo $row["league"] ?></td>
                            <td><?php echo $row["season"] ?></td>
                            <td><?php echo $row["stage"] ?></td>
                            <td><?php echo $row["home_team"] ?></td>
                            <td><?php echo $row["away_team"] ?></td>
                            <td><?php echo $row["home_goal"] ?></td>
                            <td><?php echo $row["away_goal"] ?></td>
                            <td>
                                <a role="button" class="open-close" data-toggle="collapse" href="#collapse<?php echo $i ?>">
                                    <span id="icon<?php echo $i ?>" class="glyphicon glyphicon-menu-down" data-index="<?php echo $i ?>" data-id="<?php echo $row["id"] ?>"></span>
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="9" style="padding:0px;">

                                <div class="collapse" id="collapse<?php echo $i ?>" style="padding:10px;text-align:center;">
                                    <div class="row">
                                        <div class="col-sm-6">

                                            <div id="homePlayersNoResult<?php echo $i ?>" class="panel panel-default" style="display:none">
                                                <div class="panel-body">
                                                    There are no best players for home team
                                                </div>
                                            </div>

                                            <table id="homePlayersTable<?php echo $i ?>" class="table table-bordered" style="display:none;">
                                                <caption>Best home players</caption>
                                                <thead>
                                                    <tr class="info">
                                                        <th></th>
                                                        <th>Id</th>
                                                        <th>Name</th>
                                                        <th>Rating</th>
                                                        <th></th>
                                                    </tr>
                                                </thead>
                                                <tbody id="homePlayersTableBody<?php echo $i ?>" class="table table-bordered">
                                                </tbody>
                                            </table>
                                        </div>
                                        <div class="col-sm-6">

                                            <div id="awayPlayersNoResult<?php echo $i ?>" class="panel panel-default" style="display:none">
                                                <div class="panel-body">
                                                    There are no best players for away team
                                                </div>
                                            </div>

                                            <table id="awayPlayersTable<?php echo $i ?>" class="table table-bordered" style="display:none;">
                                                <caption>Best away players</caption>
                                                <thead>
                                                    <tr class="info">
                                                        <th></th>
                                                        <th>Id</th>
                                                        <th>Name</th>
                                                        <th>Rating</th>
                                                        <th></th>
                                                    </tr>
                                                </thead>
                                                <tbody id="awayPlayersTableBody<?php echo $i ?>" class="table table-bordered table-hover">
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                            </td>
                        </tr>
                        <?php $i++;
                    } ?>
                    </tbody>
                </table>
            </div>
            <?php 
        } else { ?>
            <div class="panel panel-primary">
                <div class="panel-body">
                    There are no matches that meet these search criteria
                </div>
            </div>

            <?php 
        } ?>
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

<script src="assets/jquery-ui/jquery-ui.min.js"></script>
<script src="assets/scrollable_autocomplete/jquery.ui.autocomplete.scroll.min.js"></script>

<script>
    var leagues;
    var teams;

    $(document).ready(function() {

        $.ajax({
            url: 'get_leagues.php',
            type: 'get',
            dataType: 'JSON',
            success: function(response) {
                players = response;
                $('#league').autocomplete({
                    maxShowItems: 5,
                    source: response,
                    select: function(event, ui) {
                        var hdn = document.getElementById('hdn_league');
                        hdn.value = ui.item.id;
                    }
                });
            }
        });

        $.ajax({
            url: 'get_teams.php',
            type: 'get',
            dataType: 'JSON',
            success: function(response) {
                players = response;
                $('.get-teams').autocomplete({
                    maxShowItems: 5, // Make list height fit to 5 items when items are over 5.
                    source: response,
                    select: function(event, ui) {
                        var txt = document.getElementById(event.target.id);
                        var hdn = document.getElementById('hdn_' + txt.id);
                        hdn.value = ui.item.id;
                    }
                });
            }
        });

        $(".open-close").on("click", function(event) {

            var icon = document.getElementById(event.target.id);
            var index = icon.dataset.index;
            $(`#awayPlayersNoResult${index}`).hide();
            $(`#homePlayersNoResult${index}`).hide();
            $(`#awayPlayersTable${index}`).hide();
            $(`#homePlayersTable${index}`).hide();

            if (icon.classList[1] == "glyphicon-menu-down") {
                icon.classList.remove("glyphicon-menu-down");
                icon.classList.add("glyphicon-menu-up");

                $.ajax({
                    url: 'get_bestplayer.php',
                    type: 'get',
                    dataType: 'JSON',
                    data: {
                        match: icon.dataset.id
                    },
                    success: function(response) {

                        var homePlayersId = [];
                        var awayPlayersId = [];
                        var homePlayers = [];
                        var awayPlayers = [];
                        response.forEach(function(element) {
                            if (!homePlayersId.includes(element.best_home_player_id)) {
                                homePlayers.push(element);
                                homePlayersId.push(element.best_home_player_id);
                            }
                            if (!awayPlayersId.includes(element.best_away_player_id))
                                awayPlayers.push(element);
                            awayPlayersId.push(element.best_away_player_id);
                        });

                        var homeIsEmpty = homePlayers.length === 1 && homePlayers[0].best_home_player_id === null;
                        var awayIsEmpty = awayPlayers.length === 1 && awayPlayers[0].best_away_player_id === null;

                        if (!homeIsEmpty) {
                            $(`#homePlayersTableBody${index}`).empty();
                            $(`#homePlayersTable${index}`).show();

                            homePlayers.forEach(function(element) {
                                $('#homePlayersTableBody' + index).append(`<tr>
                                <td><span style="color:#f1c40f;" class="glyphicon glyphicon-star"></span></td>
                                <td>${element.best_home_player_id}</td>
                                <td>${element.best_home_player_name}</td>
                                <td>${element.best_home_player_rating}</td>
                                <td><a href="player_detail.php?match=${element.match}&team=${element.home_team_id}&player=${element.best_home_player_id}&date=${element.home_player_attribute_date}" target="_blank" data-toggle="tooltip" data-placement="bottom" title="View player's stats"><span style="color:#2e6da4;" class="glyphicon glyphicon-user" ></span></a></td>
                                </tr>`);
                            });

                        } else {
                            $(`#homePlayersNoResult${index}`).show();
                        }

                        if (!awayIsEmpty) {
                            $(`#awayPlayersTableBody${index}`).empty();
                            $(`#awayPlayersTable${index}`).show();

                            awayPlayers.forEach(function(element) {
                                $('#awayPlayersTableBody' + index).append(`<tr>
                                <td><span style="color:#f1c40f;" class="glyphicon glyphicon-star"></span></td>
                                <td>${element.best_away_player_id}</td>
                                <td>${element.best_away_player_name}</td>
                                <td>${element.best_away_player_rating}</td>
                                <td><a href="player_detail.php?match=${element.match}&team=${element.away_team_id}&player=${element.best_away_player_id}&date=${element.away_player_attribute_date}" target="_blank" data-toggle="tooltip" data-placement="bottom" title="View player's stats"><span style="color:#2e6da4;" class="glyphicon glyphicon-user"></span></a></td>
                                </tr>`);
                            });

                        } else {
                            $(`#awayPlayersNoResult${index}`).show();
                        }

                        $('[data-toggle="tooltip"]').tooltip();

                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.log(jqXHR);
                        console.log(textStatus);
                        console.log(errorThrown);
                    }
                });

            } else {
                icon.classList.remove("glyphicon-menu-up");
                icon.classList.add("glyphicon-menu-down");
            }

        });

    });
</script>

<?php
include "includes/footer.php"
?> 