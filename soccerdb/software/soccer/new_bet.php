<?php

$pageName = "SoccerDB - New bet";
$title = "New bet";

include "includes/header.php";

if (!isset($_SESSION['db_username']) || $_SESSION['db_role'] != 'partner') {
    header("Location: index.php", true, 301);
    exit();
}

include_once("functions/db.php");
include_once("functions/match.php");
include_once("functions/bet.php");

$db = dbconnect();
prepareInsertBet($db);

if (isset($_GET["c"]) && !empty($_GET["c"])) {
    $_SESSION["queryBet"] = [];
}

if (isset($_POST["newBetSubmit"])) {

    $_SESSION["queryBet"] = [];

    $match = $_POST["hdn_match"];
    $matchText = $_POST["match"];
    $h = $_POST["h"];
    $d = $_POST["d"];
    $a = $_POST["a"];

    $_SESSION["queryBet"]["match"] = $match;
    $_SESSION["queryBet"]["matchText"] = $matchText;
    $_SESSION["queryBet"]["h"] = $h;
    $_SESSION["queryBet"]["d"] = $d;
    $_SESSION["queryBet"]["a"] = $a;

    if (empty($match))
        $errorMessage = "Inserted match doesn't exist";
    else {
        $result = insertBet($db, [$match, $_SESSION['db_user_id'], $h, $d, $a]);

        if ($result != 1) {
            switch ($result) {
                case -10:
                    $errorMessage = "All parameters must be specified";
                    break;
                case -20:
                    $errorMessage = "The specified parameters are not valid";
                    break;
                case -60:
                    $errorMessage = "Another partner of your own company has already placed a bet for this match";
                    break;
                default:
                    $errorMessage = "An error occurred while trying to insert the bet";
                    break;
            }
        }
    }

    if (!isset($errorMessage) || empty($errorMessage)) {
        $_SESSION["queryBet"] = [];
        $success = true;
    }
    
}
?>

<style>
    #newBetContainer {
        padding: 15px;
        text-align: center;
    }

    #submitNewBet {
        display: block;
        width: 300px;
        margin: auto;
    }

    .footer {
        position: initial !important;
    }
</style>

<div id="newBetContainer" class="container-fluid">

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
    if (isset($errorMessage) && !empty($errorMessage)) {
        ?>

    <div class="panel panel-danger">
        <div class="panel-heading">
            <h3 class="panel-title">Error!</h3>
        </div>
        <div class="panel-body">
            <?php 
                echo "<p>" . $errorMessage . "</p>";
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
            <p>The bet has correctly been inserted</p>
        </div>
    </div>

    <?php 
} ?>


    <div class="row">
        <div class="col-xs-12">
            <form id="newBet" action="new_bet.php" method="post" class="form-horizontal">

                <div class="row">
                    <div class="col-xs-12">

                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">Insert new match</h3>
                            </div>
                            <div class="panel-body" style="text-align:left;">
                                <div class="col-sm-3">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">Match</label>
                                        <input id="match" type="text" class="form-control" name="match" data-error="Must be a valid id match" placeholder="Id match" required value="<?php if (isset($_SESSION["queryBet"]) && !empty($_SESSION["queryBet"]["matchText"])) echo $_SESSION["queryBet"]["matchText"] ?>">
                                        <input type="hidden" id="hdn_match" name="hdn_match" value="<?php if (isset($_SESSION["queryBet"]) && !empty($_SESSION["queryBet"]["match"])) echo $_SESSION["queryBet"]["match"] ?>">
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                                <div class="col-sm-3">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">H</label>
                                        <input type="text" class="form-control" name="h" placeholder="h" pattern="^\d+(\.\d+)?$" data-error="Must be positive a float number" required value="<?php if (isset($_SESSION["queryBet"]) && !empty($_SESSION["queryBet"]["h"])) echo $_SESSION["queryBet"]["h"] ?>">
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                                <div class="col-sm-3">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">D</label>
                                        <input type="text" class="form-control" name="d" placeholder="d" pattern="^\d+(\.\d+)?$" data-error="Must be positive a float number" required value="<?php if (isset($_SESSION["queryBet"]) && !empty($_SESSION["queryBet"]["d"])) echo $_SESSION["queryBet"]["d"] ?>">
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                                <div class="col-sm-3">
                                    <div class="form-group" style="margin:5px">
                                        <label class="control-label">A</label>
                                        <input type="text" class="form-control" name="a" placeholder="a" pattern="^\d+(\.\d+)?$" data-error="Must be a positive float number" required value="<?php if (isset($_SESSION["queryBet"]) && !empty($_SESSION["queryBet"]["a"])) echo $_SESSION["queryBet"]["a"] ?>">
                                        <div class="help-block with-errors"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="row" style="margin-bottom:10px;margin-top:10px">
                    <div class="col-sm-4 col-sm-push-4">
                        <button id="submitNewBet" class="btn btn-primary" name="newBetSubmit" type="submit">Insert</button>
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
<script src="assets/bootstrap-validator/validator.min.js"></script>

<script>
    var matches;

    $(document).ready(function() {

        $.ajax({
            url: 'get_matches.php',
            type: 'get',
            dataType: 'JSON',
            success: function(response) {
                matches = response;
                $('#match').autocomplete({
                    maxShowItems: 5,
                    source: response,
                    select: function(event, ui) {
                        var txt = document.getElementById(event.target.id);
                        var hdn = document.getElementById('hdn_match');
                        hdn.value = ui.item.id;
                    }
                });
            }
        });

        $("#match").on("keydown", function(event) {
            var KeyID = event.keyCode;
            switch (KeyID) {
                case 8:
                    var txt = document.getElementById(event.target.id);
                    var hdn = document.getElementById('hdn_match');
                    hdn.value = '';
                    break;
                default:
                    break;
            }
        });

        $("#match").on("blur", function(event) {
            var txt = document.getElementById(event.target.id);
            matches.forEach(function(element) {
                if (element.value === txt.value) {
                    var hdn = document.getElementById('hdn_match');
                    hdn.value = element.id;
                }
            });
        });


        $('#newBet').validator();

    });
</script>

<?php
include "includes/footer.php"
?> 