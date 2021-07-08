<?php

$pageName = "SoccerDB - Upload player's stats file";
$title = "Upload player_attribute.csv";

include "includes/header.php";
include_once("functions/read_csv.php");
?>

<?php
if (!isset($_SESSION['db_username']) || $_SESSION['db_role'] != 'administrator') {
    header("Location: index.php", true, 301);
    exit();
}
?>

<?php

include_once("functions/db.php");

if (isset($_POST["submit"])) {

    if ($_FILES["file"]["error"] > 0) {
        $errorMessage = "An error occurred while uploading the file";
    } else {
        if ($filename = $_FILES['file']['name'] !== "player_attribute.csv") {
            $errorMessage = "Please upload a correct player_attribute.csv file";
        } else {
            if (file_exists("upload/" . $_FILES["file"]["name"])) {
                unlink("upload/player_attribute.csv") or die("An error occurred while deleting the file");
            }
            move_uploaded_file($_FILES["file"]["tmp_name"], "upload/" .  "player_attribute.csv");

            //converti csv in array e inserisci a db
            $csvContent = csvToArray("upload/player_attribute.csv");
            $messages = insertContentStats($csvContent);

            //logga i messaggi ottenuti dall'inserimento del contenuto del file csv a db
            if (isset($messages) && !empty($messages)) {
                $logFileName = "log/player_attribute.csv" . time() . ".txt";
                $messages = print_r($messages, true);
                file_put_contents($logFileName, $messages);
                $fileCreated = true;
            }
            $terminated = true;
        }
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
</style>

<div id="contentContainer" class="container-fluid">

    <ol class="breadcrumb">
        <li><a href="index.php">Home</a></li>
        <li class="active">Upload player's stats</li>
    </ol>

    <div class="page-header">
        <h1><?php echo $title; ?></h1>

    </div>

    <div class="col-md-4 col-md-push-4">

        <?php if (!empty($errorMessage)) {
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

        <?php if (isset($terminated) && $terminated) { ?>

        <div class="panel panel-info">
            <div class="panel-heading">
                <h3 class="panel-title">Result</h3>
            </div>
            <div class="panel-body">
                <p>file upload is complete</p>
                <?php 
                if (isset($terminated) && $terminated) {
                    echo "<p>log file " . $logFileName . " has been created</p>";
                }
                ?>
            </div>
        </div>

        <?php 
    } ?>

        <div class="panel panel-primary">
            <div class="panel-heading">Upload</div>
            <div class="panel-body">
                <form action="load_stats_csv.php" method="POST" enctype="multipart/form-data">
                    <div class="form-group"><br>
                        <label>Load a player_attibute.csv file</label><br><br>
                        <input style="display:inline" name="file" type="file">
                    </div>
                    <button name="submit" type="submit" class="btn btn-primary">Upload</button>
                </form>
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