<?php
    /* 
        contenuto di params:
        1->id_user INTEGER
        2->new_id INTEGER
        3->date DATE
        4->stage INTEGER
        5->season VARCHAR
        6->home INTEGER
        7->away INTEGER
        8->home_goal INTEGER
        9->away_goal INTEGER
        10->league VARCHAR
        11->include_id INTEGER

		valori di ritorno: 
		>=0 se match viene inserito correttamente (corrisponde ad id match inserito)
		-10 se non vengono specificati tutti i parametri
		-20 se utente non presente a sistema
		-30 se utente non è autorizzato ad inserire match
		-40 se match è già presente a sistema
		-50 se viene riconosciuta uguaglianza del match con altri match non utilizzando id
		-60 se lega non è presente a sistema
		-70 se home team non è presente a sistema
		-80 se away team non è presente a sistema
        -90 se parametri non validi
        
       -- nel caso include_id sia 0 bisogna comunque passare un valore non null per new_id, qualsiasi valore va bene perchè non verrà considerato
    */
function insertMatch($db, $params)
{
    $result = pg_execute($db, "insertMatch",  $params);
    return pg_fetch_result($result, 0, 0);
}

function prepareInsertMatch($db)
{
    $sql = "SELECT insert_match($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)";
    pg_prepare($db, "insertMatch", $sql);
}

function getMatches($db, $params)
{
    return pg_execute($db, "getMatches",  $params);
}

function prepareGetMatches($db)
{
    $sql = "SELECT * from match";
    pg_prepare($db, "getMatches", $sql);
}
 