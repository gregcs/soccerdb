<?php

include_once("config.php");

function dbconnect()
{

    $connectionString = "host=" . HOST . " port=" . PORT . " dbname=" . DBNAME . " user=" . USER . " password=" . DBPASSWORD;
    $db = pg_connect($connectionString);
    pg_query($db, 'SET SEARCH_PATH TO soccerdb');

    return $db;
}
 