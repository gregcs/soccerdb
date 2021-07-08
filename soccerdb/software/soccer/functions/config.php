<?php

$db["host"] = "localhost";
$db["port"] = "5432";
$db["dbname"] = "postgres";
$db["user"] = "postgres";
$db["dbpassword"] = "gitagita";

foreach ($db as $key => $value) {
    define(strtoupper($key), $value);
}
