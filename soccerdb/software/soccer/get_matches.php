<?php 
include_once("includes/errors.php");
?>

<?php

include_once("functions/db.php");
include_once("functions/match.php");

$matches = [];

$db = dbconnect();
if (isset($db)) {
    prepareGetMatches($db);
    $result = getMatches($db, []);
    while ($row = pg_fetch_row($result)) {
        $match = ["id" => $row[0], "value" => $row[0]];
        array_push($matches, $match);
    }
}

echo json_encode($matches);

?> 