<?php
    /* 
        contenuto di params:
        1->new_match INTEGER
        2->new_dbuser INTEGER
        3->new_h FLOAT
        4->new_d FLOAT
        5->new_a FLOAT

		valori di ritorno: 
		1  se bet viene inserita correttamente
	   -10 se non vengono specificati tutti i parametri
	   -20 se new_h o new_d o new_a sono negativi
	   -30 se utente non presente a sistema
	   -40 se utente non è abilitato ad inserire bet
	   -50 se il match non è presente a sistema
       -60 se è già stata inserita una bet per questo match da un'altro utente appartenente alla stessa società di scommesse
     
    */
function insertBet($db, $params)
{
    $result = pg_execute($db, "insertBet",  $params);
    return pg_fetch_result($result, 0, 0);
}

function prepareInsertBet($db)
{
    $sql = "SELECT insert_bet($1,$2,$3,$4,$5)";
    pg_prepare($db, "insertBet", $sql);
}
