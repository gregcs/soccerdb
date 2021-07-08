<?php
    /*
        contenuto di params:
        1->id_user INTEGER
        2->new_match INTEGER
        3->new_player INTEGER
        4->new_team INTEGER

		valori di ritorno: 
		 1  se formation viene inserita correttamente
		-10 se non vengono specificati tutti i parametri
		-20 se utente non presente a sistema
		-30 se utente non è autorizzato
		-40 se formation già presente
		-50 se match non presente
		-60 se utente non può inserire formation per questo match
		-70 se player non presente
		-80 se team non presente
		-90 se il team è al già al completo (11 giocatori)
		-100 se il player gioca già in un team per il match dato
    */
    function insertFormation($db, $params)
    {
        $result = pg_execute($db, "insertFormation",  $params);
        return pg_fetch_result($result, 0, 0);
    }

    function prepareInsertFormation($db)
    {
        $sql = "SELECT insert_formation($1,$2,$3,$4)";
        pg_prepare($db, "insertFormation", $sql);
    }

 ?>