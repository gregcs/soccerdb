<?php 
include_once("includes/errors.php");
?>

<?php

    include_once ("functions/db.php");
    include_once ("functions/player.php");

    $players = [];

    $db = dbconnect();
     if(isset($db)){
         prepareGetPlayers($db);
         $result = getPlayers($db, []);
         while ($row = pg_fetch_row($result)) {
            $player = ["id" => $row[0], "value" => $row[1]];
            array_push($players,$player);
         }
    }

    echo json_encode($players);

?>