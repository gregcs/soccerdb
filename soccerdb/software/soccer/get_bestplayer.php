<?php
include_once("includes/errors.php");
?>

<?php

include_once("functions/db.php");
include_once("functions/player.php");

$db = dbconnect();
if (isset($db)) {
    prepareGetBestPlayers($db);
    $resultBestPlayer = getBestPlayers($db, [$_GET["match"]]);
    while ($row = pg_fetch_assoc($resultBestPlayer)) {
        $bestPlayers[] = $row;
    }
}


echo json_encode($bestPlayers);

?> 