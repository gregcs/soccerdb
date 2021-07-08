<?php
    /*
        contenuto di params:
        1->id_user INTEGER
        2->id_player INTEGER
        3->name VARCHAR
        4->birthday DATE
        5->weight INTEGER
        6->height FLOAT

		valori di ritorno: 
		  1 se l'inserimento va a buon fine
		-10 se non vengono specificati tutti i parametri
		-20 se utente non è presente a sistema
		-30 se utente non è autorizzato
		-40 se player già presente a sistema
		-50 se i parametri non sono validi
	*/
function insertPlayer($db, $params)
{
    $result = pg_execute($db, "insertPlayer",  $params);
    return pg_fetch_result($result, 0, 0);
}

function prepareInsertPlayer($db)
{
    $sql = "SELECT insert_player($1,$2,$3,$4,$5,$6)";
    pg_prepare($db, "insertPlayer", $sql);
}

/*
        contenuto di params:
        1->id_user INTEGER
        2->new_player INTEGER
        3->new_attribute_date DATE
        4->overall_rating INTEGER
        5->potential INTEGER
        6->preferred_foot VARCHAR(10)
        7->attacking_work_rate VARCHAR(10)
        8->defensive_work_rate VARCHAR(10)
        9->crossing INTEGER
        10->finishing INTEGER
        11->heading_accuracy INTEGER
        12->short_passing INTEGER
        13->volleys INTEGER
        14->dribbling INTEGER
        15->curve INTEGER
        16->free_kick_accuracy INTEGER
        17->long_passing INTEGER
        18->ball_control INTEGER
        19->acceleration INTEGER
        20->sprint_speed INTEGER
        21->agility INTEGER
        22->reactions INTEGER
        23->balance INTEGER
        24->shot_power INTEGER
        25->jumping INTEGER
        26->stamina INTEGER
        27->strength INTEGER
        28->long_shots INTEGER
        29->aggression INTEGER
        30->interceptions INTEGER
        31->positioning INTEGER
        32->vision INTEGER
        33->penalties INTEGER
        34->marking INTEGER
        35->standing_tackle INTEGER
        36->sliding_tackle INTEGER
        37->gk_diving INTEGER
        38->gk_handling INTEGER
        39->gk_kicking INTEGER
        40->gk_positioning INTEGER
        41->gk_reflexes INTEGER

        valori di ritorno: 
        0 se stat viene inserita correttamente
        1 se non vengono specificati tutti i parametri
        2 utente non presente a sistema
        3 se utente non è autorizzato
        4 player non presente a sistema
        5 statistica già presente
        6 bisogna rispettare i vincoli check
    */
function insertPlayerStats($db, $params)
{
    $result = pg_execute($db, "insertPlayerStats",  $params);
    return pg_fetch_result($result, 0, 0);
}

function prepareInsertPlayerStats($db)
{
    $sql = "SELECT insert_playerstats($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41)";
    pg_prepare($db, "insertPlayerStats", $sql);
}


/*
    contenuto di params:
    al momento params è un array vuoto e non viene usato, potrebbe essere usato per filtrare i risultati

    valori di ritorno:
    elenco di players
*/
function getPlayers($db, $params)
{
    return pg_execute($db, "getPlayers",  $params);
}

function prepareGetPlayers($db)
{
    $sql = "SELECT * from player order by name";
    pg_prepare($db, "getPlayers", $sql);
}

/*
    contenuto di params:
    1->idMatch

    valori di ritorno:
    ritorna il contenuto della vista best_player retaliva al match
*/
function getBestPlayers($db, $params)
{
    return pg_execute($db, "getBestPlayers",  $params);
}

function prepareGetBestPlayers($db)
{
    $sql = "SELECT * from best_player WHERE match=$1";
    pg_prepare($db, "getBestPlayers", $sql);
}


/*
    contenuto di params:
    1->id match
    2->id team
    3->id player
    4->attribute_date

    valori di ritorno:
    ritorna le statistiche del giocatore con attributo più recente rispetto alla data del match
*/

function getPlayerStats($db, $params)
{
    return pg_execute($db, "getPlayerStats",  $params);
}

function prepareGetPlayerStats($db)
{
    $sql = 'SELECT P.name, p.birthday,p.weight,p.height,PS.*
    FROM most_recent_attribute AS MR
    JOIN player AS P
    ON MR.player = P.id
    JOIN playerstats AS PS
    ON MR.player = PS.player AND MR.attribute_date = PS.attribute_date
    WHERE MR.match = $1 AND MR.team = $2 AND MR.player = $3 AND MR.attribute_date = $4';
    pg_prepare($db, "getPlayerStats", $sql);
}
 

