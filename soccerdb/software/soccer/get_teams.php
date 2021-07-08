<?php 
include_once("includes/errors.php");
?>

<?php

    include_once ("functions/db.php");
    include_once ("functions/team.php");

    $teams = [];

    $db = dbconnect();
     if(isset($db)){
        prepareGetTeams($db);
         $result = getTeams($db, []);
         while ($row = pg_fetch_row($result)) {
            $team = ["id" => $row[0], "value" => $row[1]];
            array_push($teams,$team);
         }
    }

    echo json_encode($teams);

?>