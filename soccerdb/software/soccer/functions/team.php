<?php
    /* 
        contenuto di params:
        1->id_user INTEGER
        2->id_team INTEGER
        3->long_name VARCHAR
        4->short_name VARCHAR(10)


		valori di ritorno: 
		  1 se team viene inserito correttamente
		-10 se non vengono specificati tutti i parametri
		-20 se utente non è presente a sistema
		-30 se utente non è autorizzato
		-40 se team è già presente a sistema
	*/
function insertTeam($db, $params)
{
    $result = pg_execute($db, "insertTeam",  $params);
    return pg_fetch_result($result, 0, 0);
}

function prepareInsertTeam($db)
{
    $sql = "SELECT insert_team($1,$2,$3,$4)";
    pg_prepare($db, "insertTeam", $sql);
}

function getTeams($db, $params)
{
    return pg_execute($db, "getTeams",  $params);
}

function prepareGetTeams($db)
{
    $sql = "SELECT * FROM team order by long_name";
    pg_prepare($db, "getTeams", $sql);
}
 