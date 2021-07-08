<?php 
include_once("includes/errors.php");
?>

<?php

include_once("functions/db.php");
include_once("functions/league.php");

$leagues = [];

$db = dbconnect();
if (isset($db)) {
    prepareGetLeagues($db);
    $result = getLeagues($db, []);
    while ($row = pg_fetch_row($result)) {
        $league = ["id" => $row[0], "value" => $row[0]];
        array_push($leagues, $league);
    }
}

echo json_encode($leagues);

?> 