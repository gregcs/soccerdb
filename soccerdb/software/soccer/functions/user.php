<?php

function login($credentials)
{
    include_once("db.php");
    $connected = false;
    $db = dbconnect();
    $sql = "SELECT * FROM dbuser WHERE username =  $1 AND password = $2";
    $result = pg_prepare($db, "getuser", $sql);
    $result = pg_execute($db, "getuser", $credentials);
    if (pg_num_rows($result)) {

        $row = pg_fetch_assoc($result);
        $_SESSION["db_user_id"] = $row["id"];
        $_SESSION["db_username"] = $row["username"];
        $_SESSION["db_role"] = $row["role"];
        $_SESSION["betcompany"] = $row["betcompany"];
        $connected = true;
    }
    return $connected;
}


function getOperators($db, $params)
{
    return pg_execute($db, "getOperators",  $params);
}

function prepareGetOperators($db)
{
    $sql = "SELECT * FROM dbuser WHERE role = 'operator' order by id";
    pg_prepare($db, "getOperators", $sql);
}
 