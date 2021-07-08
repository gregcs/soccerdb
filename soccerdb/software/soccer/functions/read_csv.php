<?php

function csvToArray($relativePath){
    $rows = array_map('str_getcsv', file($relativePath));
    $header = array_shift($rows);
    $csv = array();
    foreach ($rows as $row) {
        $csv[] = array_combine($header, $row);
    }

    return $csv;
}

function insertContentMatch($rows, $operator){
    $messages = array();

    try {

        if (isset($rows) && !empty($rows)) {

            include_once("db.php");
            $db = dbconnect();

            if (isset($db)) {

                include_once("functions/league.php");
                include_once("functions/team.php");
                include_once("functions/player.php");
                include_once("functions/match.php");
                include_once("functions/formation.php");

                prepareInsertLeague($db);
                prepareInsertTeam($db);
                prepareInsertPlayer($db);
                prepareInsertMatch($db);
                prepareInsertFormation($db);

                $id_user = $_SESSION["db_user_id"];
                $rowIndex = 1;

                foreach ($rows as $row) {

                    $paramsLeague = array($id_user, $row["league_name"], $row["country_name"]);
                    $retLeague = insertLeague($db, $paramsLeague);
                    if ($retLeague < 1) {
                        array_push($messages, "Riga->" . $rowIndex . ": league->" . $row["league_name"] . ", errore->" . $retLeague);
                    }

                    $paramsHomeTeam = array($id_user, $row["home_team_id"], $row["home_team_long_name"], $row["home_team_short_name"]);
                    $retHomeTeam =  insertTeam($db, $paramsHomeTeam);
                    if ($retHomeTeam < 1) {
                        array_push($messages, "Riga->" . $rowIndex . ": home_team->" . $row["home_team_id"] . ", errore->" . $retHomeTeam);
                    }

                    $paramsAwayTeam = array($id_user, $row["away_team_id"], $row["away_team_long_name"], $row["away_team_short_name"]);
                    $retAwayTeam =  insertTeam($db, $paramsAwayTeam);
                    if ($retAwayTeam < 1) {
                        array_push($messages, "Riga->" . $rowIndex . ": away_team->" . $row["away_team_id"] . ", errore->" . $retAwayTeam);
                    }

                    $paramsMatch = array($operator, $row["id"], $row["date"], $row["stage"], $row["season"], $row["home_team_id"], $row["away_team_id"], $row["home_team_goal"], $row["away_team_goal"], $row["league_name"], 1);
                    $retMatch = insertMatch($db, $paramsMatch);
                    if ($retMatch <= 0) {
                        array_push($messages, "Riga:->" . $rowIndex . ": id_team->" . $row["id"] . ", errore->" . $retMatch);
                    }


                    for ($playerIndex = 1; $playerIndex <= 11; $playerIndex++) {

                        $home_player_id = "home_player_" . $playerIndex . "_id";

                        if ($row[$home_player_id]) {

                            $home_player_name = "home_player_" . $playerIndex . "_name";
                            $home_player_birthday = "home_player_" . $playerIndex . "_birthday";
                            $home_player_height = "home_player_" . $playerIndex . "_height";
                            $home_player_weight = "home_player_" . $playerIndex . "_weight";

                            $paramsHomePlayer = array($id_user, $row[$home_player_id], $row[$home_player_name], $row[$home_player_birthday], $row[$home_player_weight], $row[$home_player_height]);
                            $retHomePlayer = insertPlayer($db, $paramsHomePlayer);
                            if ($retHomePlayer < 1) {
                                array_push($messages, "Riga->" . $rowIndex . ": " . $home_player_id . "->" . $row[$home_player_id] . ", errore->" . $retHomePlayer);
                            }

                            $paramsHomeFormation = array($operator, $row["id"], $row[$home_player_id], $row["home_team_id"]);
                            $retHomeFormation = insertFormation($db, $paramsHomeFormation);
                            if ($retHomeFormation < 1) {
                                array_push($messages, "Riga->" . $rowIndex . ": home formation-> M" . $row["id"] . "P" . $row[$home_player_id] . "T" . $row["home_team_id"] . ", errore->" . $retHomeFormation);
                            }
                        }

                        $away_player_id = "away_player_" . $playerIndex . "_id";

                        if ($row[$away_player_id]) {

                            $away_player_name = "away_player_" . $playerIndex . "_name";
                            $away_player_birthday = "away_player_" . $playerIndex . "_birthday";
                            $away_player_height = "away_player_" . $playerIndex . "_height";
                            $away_player_weight = "away_player_" . $playerIndex . "_weight";

                            $paramsAwayPlayer = array($id_user, $row[$away_player_id], $row[$away_player_name], $row[$away_player_birthday], $row[$away_player_weight], $row[$away_player_height]);
                            $retAwayPlayer = insertPlayer($db, $paramsAwayPlayer);
                            if ($retAwayPlayer < 1) {
                                array_push($messages, "Riga->" . $rowIndex . ": " . $away_player_id . "->" . $row[$away_player_id] . ", errore->" . $retAwayPlayer);
                            }

                            $paramsAwayFormation = array($operator, $row["id"], $row[$away_player_id], $row["away_team_id"]);
                            $retAwayFormation = insertFormation($db, $paramsAwayFormation);
                            if ($retAwayFormation < 1) {
                                array_push($messages, "Riga->" . $rowIndex . ": away formation-> M" . $row["id"] . "P" . $row[$away_player_id] . "T" . $row["away_team_id"] . ", errore->" . $retAwayFormation);
                            }
                        }
                    }

                    $rowIndex++;
                }
            }
        }
    } catch (Exception $e) {
        //salva a db;
    };
    return $messages;
}

function insertContentStats($rows)
{

    $messages = array();

    try {

        if (isset($rows)) {
            include_once("db.php");
            $db = dbconnect();
            if (isset($db)) {

                include_once("player.php");

                $id_user = $_SESSION["db_user_id"];
                $rowIndex = 1;

                prepareInsertPlayerStats($db);
                
                foreach ($rows as $row) {


                    if (!$row["overall_rating"])
                        $row["overall_rating"] = null;
                    if (!$row["potential"])
                        $row["potential"] = null;
                    if ($row["preferred_foot"] != "left" && $row["preferred_foot"] != "right")
                        $row["preferred_foot"] = null;
                    if ($row["attacking_work_rate"] != "low" && $row["attacking_work_rate"] != "medium" && $row["attacking_work_rate"] != "high")
                        $row["attacking_work_rate"] = null;
                    if ($row["defensive_work_rate"] != "low" &&  $row["defensive_work_rate"] != "medium" && $row["defensive_work_rate"] != "high")
                        $row["defensive_work_rate"] = null;
                    if (!$row["crossing"])
                        $row["crossing"] = null;
                    if (!$row["finishing"])
                        $row["finishing"] = null;
                    if (!$row["heading_accuracy"])
                        $row["heading_accuracy"] = null;
                    if (!$row["short_passing"])
                        $row["short_passing"] = null;
                    if (!$row["volleys"])
                        $row["volleys"] = null;
                    if (!$row["dribbling"])
                        $row["dribbling"] = null;
                    if (!$row["curve"])
                        $row["curve"] = null;
                    if (!$row["free_kick_accuracy"])
                        $row["free_kick_accuracy"] = null;
                    if (!$row["long_passing"])
                        $row["long_passing"] = null;
                    if (!$row["ball_control"])
                        $row["ball_control"] = null;
                    if (!$row["acceleration"])
                        $row["acceleration"] = null;
                    if (!$row["sprint_speed"])
                        $row["sprint_speed"] = null;
                    if (!$row["agility"])
                        $row["agility"] = null;
                    if (!$row["reactions"])
                        $row["reactions"] = null;
                    if (!$row["balance"])
                        $row["balance"] = null;
                    if (!$row["shot_power"])
                        $row["shot_power"] = null;
                    if (!$row["jumping"])
                        $row["jumping"] = null;
                    if (!$row["stamina"])
                        $row["stamina"] = null;
                    if (!$row["strength"])
                        $row["strength"] = null;
                    if (!$row["long_shots"])
                        $row["long_shots"] = null;
                    if (!$row["aggression"])
                        $row["aggression"] = null;
                    if (!$row["interceptions"])
                        $row["interceptions"] = null;
                    if (!$row["positioning"])
                        $row["positioning"] = null;
                    if (!$row["vision"])
                        $row["vision"] = null;
                    if (!$row["penalties"])
                        $row["penalties"] = null;
                    if (!$row["marking"])
                        $row["marking"] = null;
                    if (!$row["standing_tackle"])
                        $row["standing_tackle"] = null;
                    if (!$row["sliding_tackle"])
                        $row["sliding_tackle"] = null;
                    if (!$row["gk_diving"])
                        $row["gk_diving"] = null;
                    if (!$row["gk_handling"])
                        $row["gk_handling"] = null;
                    if (!$row["gk_kicking"])
                        $row["gk_kicking"] = null;
                    if (!$row["gk_positioning"])
                        $row["gk_positioning"] = null;
                    if (!$row["gk_reflexes"])
                        $row["gk_reflexes"] = null;


                    $paramsPlayerStats = array(
                        $id_user,
                        $row["player_id"],
                        $row["attribute_date"],
                        $row["overall_rating"],
                        $row["potential"],
                        $row["preferred_foot"],
                        $row["attacking_work_rate"],
                        $row["defensive_work_rate"],
                        $row["crossing"],
                        $row["finishing"],
                        $row["heading_accuracy"],
                        $row["short_passing"],
                        $row["volleys"],
                        $row["dribbling"],
                        $row["curve"],
                        $row["free_kick_accuracy"],
                        $row["long_passing"],
                        $row["ball_control"],
                        $row["acceleration"],
                        $row["sprint_speed"],
                        $row["agility"],
                        $row["reactions"],
                        $row["balance"],
                        $row["shot_power"],
                        $row["jumping"],
                        $row["stamina"],
                        $row["strength"],
                        $row["long_shots"],
                        $row["aggression"],
                        $row["interceptions"],
                        $row["positioning"],
                        $row["vision"],
                        $row["penalties"],
                        $row["marking"],
                        $row["standing_tackle"],
                        $row["sliding_tackle"],
                        $row["gk_diving"],
                        $row["gk_handling"],
                        $row["gk_kicking"],
                        $row["gk_positioning"],
                        $row["gk_reflexes"]
                    );

                    $retPlayerStats = insertPlayerStats($db, $paramsPlayerStats);
                    if ($retPlayerStats != 0) {
                        array_push($messages, "Riga " . $rowIndex . ": playerstats-> ID: " . $row["player_id"] . " DATE: " . $row["attribute_date"] . " ERRORE->" . $retPlayerStats);
                    }

                    $rowIndex++;
                }
            }
        }
    } catch (Exception $e) {
        //salva a db;
    };
    return $messages;
}

 