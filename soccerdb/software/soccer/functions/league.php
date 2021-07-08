<?php
    /*
        contenuto di params:
        1->id_user INTEGER
        2->new_name VARCHAR
        3->country VARCHAR

		valori di ritorno: 
		  1 se l'inserimento va a buon fine
		-10 se non vengono specificati tutti i parametri
		-20 se utente non è presente a sistema
		-30 se l'utente non è autorizzato (solo amministratore)
		-40 se è lega già presente a sistema
    */
function insertLeague($db, $params)
{
    $result = pg_execute($db, "insertLeague",  $params);
    return  pg_fetch_result($result, 0, 0);
}

function prepareInsertLeague($db)
{
    $sql = "SELECT insert_league($1,$2,$3)";
    pg_prepare($db, "insertLeague", $sql);
}

/*
    contenuto di params:
    al momento params è un array vuoto e non viene usato, potrebbe essere usato per filtrare i risultati

    valori di ritorno:
    elenco di leagues
*/
function getLeagues($db, $params)
{
    return pg_execute($db, "getLeagues",  $params);
}

function prepareGetLeagues($db)
{
    $sql = "SELECT * from league";
    pg_prepare($db, "getLeagues", $sql);
}
