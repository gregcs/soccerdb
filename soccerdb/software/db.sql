--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: soccerdb; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA soccerdb;


ALTER SCHEMA soccerdb OWNER TO postgres;

--
-- Name: delete_bet(integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_bet(id_user integer, matchtodelete integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per cancellare bet (id_user INTEGER, matchToDelete INTEGER)
	--concesso solo ad utente che ha inserito la bet
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		bt	bet%ROWTYPE;
	BEGIN
		
		IF id_user IS NULL OR matchToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'partner' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare formation';
		END IF;
				
		SELECT * INTO bt FROM bet WHERE match = matchToDelete AND dbuser = id_user;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'bet non è presente a sistema';
		END IF;
			
		DELETE FROM bet WHERE match = matchToDelete AND dbuser = id_user;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_bet(id_user integer, matchtodelete integer) OWNER TO postgres;

--
-- Name: delete_dbuser(integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_dbuser(id_user integer, usertodelete integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per cancellare dbuser (id_user INTEGER, userToDelete INTEGER)
	--concesso solo ad administrator
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
	BEGIN
		
		IF id_user IS NULL OR userToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare dbuser';
		END IF;
				
		PERFORM * FROM dbuser WHERE id = userToDelete;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'dbuser % non è presente a sistema', userToDelete;
		END IF;
			
		DELETE FROM dbuser WHERE id = userToDelete;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_dbuser(id_user integer, usertodelete integer) OWNER TO postgres;

--
-- Name: delete_formation(integer, integer, integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_formation(id_user integer, matchtodelete integer, playertodelete integer, teamtodelete integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per cancellare formation (id_user INTEGER, matchToDelete INTEGER, playerToDelete INTEGER, teamToDelete INTEGER)
	--concesso solo ad utente operator che ha inserito il match
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		currUsr	INTEGER;
	BEGIN
		
		IF id_user IS NULL OR matchToDelete IS NULL OR playerToDelete IS NULL OR teamToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'operator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare formation';
		END IF;
				
		SELECT match.dbuser INTO currUsr FROM formation JOIN match ON formation.match = match.id WHERE formation.match = matchToDelete AND formation.player = playerToDelete AND formation.team = teamToDelete;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'formation M%P%T% non è presente a sistema', matchToDelete,playerToDelete,teamToDelete;
		END IF;
		
		IF currUsr != id_user THEN
			RAISE EXCEPTION 'solo utente % può cancellare questa formation', currUsr;
		END IF;
			
		DELETE FROM formation WHERE match = matchToDelete AND player = playerToDelete AND team = teamToDelete;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_formation(id_user integer, matchtodelete integer, playertodelete integer, teamtodelete integer) OWNER TO postgres;

--
-- Name: delete_league(integer, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_league(id_user integer, leaguetodelete character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per eliminare league (id_user INTEGER, leagueToDelete VARCHAR)
	--concesso solo ad administrator
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		lg	league%ROWTYPE;
	BEGIN
		
		IF id_user IS NULL OR leagueToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare league';
		END IF;
				
		SELECT * INTO lg FROM league WHERE name = leagueToDelete;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'La league % non è presente a sistema', leagueToDelete;
		END IF;
			
		DELETE FROM league WHERE name = leagueToDelete;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_league(id_user integer, leaguetodelete character varying) OWNER TO postgres;

--
-- Name: delete_match(integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_match(id_user integer, idmatchtodelete integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per eliminare match (id_user INTEGER, idMatchToDelete INTEGER)
	--concesso solo ad operator che ha inserito il match
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		mt match%ROWTYPE;

	BEGIN
		
		IF id_user IS NULL OR idMatchToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'operator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare team';
		END IF;
				
		SELECT * INTO mt FROM match WHERE id = idMatchToDelete;
		IF NOT FOUND THEN	
			RAISE EXCEPTION 'Il match % non è presente a sistema', idMatchToDelete;
		END IF;
		
		IF mt.dbuser != id_user THEN
			RAISE EXCEPTION 'Solo utente % può cancellare questo match', mt.dbuser;
		END IF;
		
		DELETE FROM match WHERE id = idMatchToDelete;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_match(id_user integer, idmatchtodelete integer) OWNER TO postgres;

--
-- Name: delete_player(integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_player(id_user integer, playertodelete integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per cancellare player (id_user INTEGER, playerToDelete VARCHAR)
	--concesso solo ad administrator
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		pl	player%ROWTYPE;
	BEGIN
		
		IF id_user IS NULL OR playerToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare player';
		END IF;
				
		SELECT * INTO pl FROM player WHERE id = playerToDelete;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'Il player % non è presente a sistema', playerToDelete;
		END IF;
			
		DELETE FROM team WHERE id = playerToDelete;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_player(id_user integer, playertodelete integer) OWNER TO postgres;

--
-- Name: delete_playerstats(integer, integer, date); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_playerstats(id_user integer, playertodelete integer, attributedatetodelete date) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per cancellare player stats (id_user INTEGER, playerToDelete INTEGER, attributeDateToDelete DATE)
	--concesso solo ad administrator
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		ps	playerstats%ROWTYPE;

	BEGIN
	
		IF id_user IS NULL OR playerToDelete IS NULL OR attributeDateToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare team';
		END IF;
				
		SELECT * INTO ps FROM playerstats WHERE player = playerToDelete AND attribute_date = attributeDateToDelete;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'playertstat %,% non è presente a sistema', playerToDelete,attributeDateToDelete;
		END IF;
			
		DELETE FROM playerstats WHERE player = playerToDelete AND attribute_date = attributeDateToDelete;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.delete_playerstats(id_user integer, playertodelete integer, attributedatetodelete date) OWNER TO postgres;

--
-- Name: delete_team(integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.delete_team(id_user integer, teamtodelete integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

	--funzione per cancellare team (id_user INTEGER, teamToDelete VARCHAR)
	--concesso solo ad administrator
	--vanno specificati tutti i parametri
	
	DECLARE
		usr dbuser%ROWTYPE;
		tm	team%ROWTYPE;
	BEGIN
		
		IF id_user IS NULL OR leagueToDelete IS NULL THEN
			RAISE EXCEPTION 'i parametri vanno tutti obbligatoriamente specificati';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato a cancellare team';
		END IF;
				
		SELECT * INTO tm FROM team WHERE id = teamToDelete;
		IF  NOT FOUND THEN	
			RAISE EXCEPTION 'Il team % non è presente a sistema', teamToDelete;
		END IF;
			
		DELETE FROM team WHERE id = teamToDelete;
		
	END;

$$;


ALTER FUNCTION soccerdb.delete_team(id_user integer, teamtodelete integer) OWNER TO postgres;

--
-- Name: functgr_refresh_ranking(); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.functgr_refresh_ranking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

	BEGIN
		REFRESH MATERIALIZED VIEW ranking;
		RETURN NULL;
	END;

$$;


ALTER FUNCTION soccerdb.functgr_refresh_ranking() OWNER TO postgres;

--
-- Name: insert_bet(integer, integer, double precision, double precision, double precision); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_bet(new_match integer, new_dbuser integer, new_h double precision, new_d double precision, new_a double precision) RETURNS integer
    LANGUAGE plpgsql
    AS $$

	-- funzione per inserire bet (new_match INTEGER, new_dbuser INTEGER, new_h FLOAT, new_d FLOAT, new_a FLOAT)
	-- concesso solo a partner
	
	/*
		valori di ritorno: 
		1  se bet viene inserita correttamente
	   -10 se non vengono specificati tutti i parametri
	   -20 se new_h o new_d o new_a sono negativi
	   -30 se utente non presente a sistema
	   -40 se utente non è abilitato ad inserire bet
	   -50 se il match non è presente a sistema
	   -60 se è già stata inserita una bet per questo match da un'altro utente appartenente alla stessa società di scommesse
	*/
	
	DECLARE
		
		usr dbuser%ROWTYPE;
		insertedBets INTEGER;
		mt match%ROWTYPE;
		
	BEGIN
		
		IF new_match IS NULL OR new_dbuser IS NULL OR new_h IS NULL OR new_d IS NULL OR new_a IS NULL THEN
			RAISE INFO 'tutti i parametri vanno  obbligatoriamente specificati';
			RETURN -10;
		ELSE
			
			IF new_h < 0 OR new_a < 0 OR new_a < 0 THEN
				RAISE INFO 'h,d,a non devono essere valori negativi';
				RETURN -20;
			ELSE
			
				SELECT * INTO usr FROM dbuser WHERE id = new_dbuser;
				IF FOUND THEN
				
					IF usr.role = 'partner' THEN
					
						SELECT * INTO mt FROM match WHERE id = new_match;	
						IF NOT FOUND THEN
							RAISE INFO 'match già presente a sistema';
							RETURN -50;
						ELSE 
						
							--Un partner può inserire più bet per uno stesso match? Se si, si deve controllare anche bet.dbuser <> new_dbuser
							insertedBets := (SELECT count(*)::int FROM bet JOIN dbuser ON bet.dbuser = dbuser.id WHERE dbuser.betcompany = usr.betcompany AND bet.match = new_match);
							
							IF insertedBets > 0 THEN
								RAISE INFO 'è già presente una bet per match % fatta da altro utente della stessa società', new_match;
								RETURN -60;
							ELSE
								INSERT INTO bet (match, dbuser, h, d, a) VALUES (new_match, new_dbuser, new_h, new_d, new_a);
								RAISE INFO 'inserimento avvenuto con successo';
								RETURN 1;
							END IF;
						
						END IF;
						
					ELSE
						RAISE INFO 'utente % non autorizzato ad inserire bet', new_dbuser;
						RETURN -40;
					END IF;
			
				ELSE
					RAISE INFO 'utente % non presente a sistema', new_dbuser;
					RETURN -30;
				END IF;
				
			END IF;
			
		END IF;
		

		
	END;
	
$$;


ALTER FUNCTION soccerdb.insert_bet(new_match integer, new_dbuser integer, new_h double precision, new_d double precision, new_a double precision) OWNER TO postgres;

--
-- Name: insert_dbuser(integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_dbuser(id_user integer, new_username character varying, new_password character varying, new_role character varying, new_betcompany character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	
	-- funzione per inserire dbuser (id_user INTEGER, new_username VARCHAR, new_password VARCHAR, new_role VARCHAR, new_betcompany VARCHAR(10))
	-- concesso solo ad administrator
	-- id_user indica utente che compie inserimento
	-- vanno specificati id_user, new_username, new_password, new_role
	/*
		valori di ritorno: 
		 1  se nuovo utente viene inserito correttamente
		-10 se non vengono specificati tutti i parametri
		-20 se utente che sta eseguendo l'inserimento non è presente a sistema
		-30 se utente che sta eseguendo l'inserimento non è autorizzato
		-40 se utente che si sta inserendo è già presente a sistema
		-50 se ruolo specificato non è valido
		-60 se nuovo utente è partner deve essere specificato new_betcompany
	*/
	
	DECLARE
	
		ret INTEGER;
		usr dbuser%ROWTYPE;
		nusr dbuser%ROWTYPE;

	BEGIN
		
		IF id_user IS NULL OR new_username IS NULL OR new_password IS NULL OR new_role IS NULL THEN
		
			RAISE INFO 'bisogna obbligatoriamente specificare id_user, new_username, new_password, new_role';
			ret := -10;
			
		ELSE
		
			SELECT * INTO usr FROM dbuser WHERE id = id_user;
			IF FOUND THEN
			
				IF usr.role != 'administrator' THEN
				
					RAISE INFO 'utente non autorizzato ad inserire nuovi utenti';
					ret := -30;
					
				ELSE
				
					SELECT * INTO nusr FROM dbuser WHERE username = new_username;
					IF NOT FOUND THEN
						
						IF new_role = 'administrator' OR new_role = 'operator' OR new_role = 'partner' THEN
						
							IF new_role = 'partner' AND new_betcompany IS NULL THEN
								RAISE INFO 'se nuovo utente è partner deve essere specificato new_betcompany';
								ret := -60;
							ELSE
								INSERT INTO dbuser (username,password,role,betcompany) VALUES (new_username,new_password,new_role, new_betcompany);
								ret :=1;
							END IF;
							
						ELSE
							RAISE INFO 'role % non valido', new_role;
							ret := -50;
						END IF;
						
						
					ELSE
						RAISE INFO 'utente % è già presente a sistema', new_username;
						ret := -40;
					END IF;
					
				END IF;
				
			ELSE
				RAISE INFO 'utente % non presente a sistema', id_user;
				ret := -20;
			END IF;
			
		END IF;
		
		RETURN  ret;
		
	END;

$$;


ALTER FUNCTION soccerdb.insert_dbuser(id_user integer, new_username character varying, new_password character varying, new_role character varying, new_betcompany character varying) OWNER TO postgres;

--
-- Name: insert_formation(integer, integer, integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_formation(id_user integer, new_match integer, new_player integer, new_team integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	
	-- funzione per inserire formation (id_user INTEGER, new_match INTEGER, new_player INTEGER, new_team INTEGER)
	-- concesso solo a operator
	-- vanno specificati obbligatoriamente tutti i parametri
	/*
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
	
	DECLARE
		ret INTEGER;
		usr dbuser%ROWTYPE;
		mt match%ROWTYPE;
		fm formation%ROWTYPE;
		pl player%ROWTYPE;
		tm team%ROWTYPE;
		numberFormation INTEGER;
		count INTEGER;
		
	BEGIN
		
		IF id_user IS NULL OR new_match IS NULL OR new_player IS NULL OR new_team IS NULL THEN
		
			RAISE INFO 'bisogna obbligatoriamente specificare tutti i parametri';
			ret := -10;
			
		ELSE
		
			SELECT * INTO usr FROM dbuser WHERE id = id_user;
			IF FOUND THEN
			
				IF usr.role != 'operator' THEN
				
					RAISE INFO 'utente non autorizzato ad inserire formation';
					ret := -30;
					
				ELSE
				
					SELECT * INTO mt FROM match WHERE id = new_match;
					IF FOUND THEN
						
						IF mt.dbuser = id_user THEN 
						
							SELECT * INTO pl FROM player WHERE id = new_player;
							IF FOUND THEN
								
								SELECT * INTO tm FROM team WHERE id = new_team;
								IF FOUND THEN
											
									SELECT * INTO fm FROM formation WHERE match = new_match AND player = new_player AND team = new_team;
									IF FOUND THEN
										RAISE INFO 'formation m % p % t % è già presente a sistema', new_match, new_player, new_team;
										ret := -40;		
									ELSE
										
										numberFormation := (SELECT count(*)::int FROM formation WHERE match = new_match AND player = new_player);
										IF numberFormation > 0 THEN
											RAISE INFO 'Il player % gioca già in questo match', new_player;
											ret := -100;
										ELSE
										
											count := (SELECT count(*)::int FROM formation WHERE match = new_match AND team = new_team);
											IF count < 11 THEN
										
												INSERT INTO formation VALUES (new_match,new_player,new_team);
												ret := 1;
											
											ELSE 
												RAISE INFO 'il team % è già al completo', new_team;
												ret := -90;
											END IF;
											
										END IF;
										
									END IF;
										
								ELSE
									RAISE INFO 'team % non presente a sistema', new_team;
									ret := -80;
								END IF;
							
							ELSE
								RAISE INFO 'player % non presente a sistema', new_player;
								ret := -70;
							END IF;
					
						ELSE
							RAISE INFO 'solo utente % può inserire la formazione per questo match %', mt.dbuser, new_match;
							ret := -60;
						END IF;
						
					ELSE
						RAISE INFO 'match % non presente a sistema', new_match;
						ret := -50;
					END IF;
					
				END IF;
				
			ELSE
				RAISE INFO 'utente % non presente a sistema', id_user;
				ret := -20;
			END IF;
			
		END IF;
		
		RETURN  ret;
		
	END;

$$;


ALTER FUNCTION soccerdb.insert_formation(id_user integer, new_match integer, new_player integer, new_team integer) OWNER TO postgres;

--
-- Name: insert_league(integer, character varying, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_league(id_user integer, new_name character varying, country character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	
	-- funzione per inserire league (id_user INTEGER, new_name VARCHAR, country VARCHAR)
	-- concesso solo ad administrator
	-- vanno specificati obbligatoriamente tutti i parametri
	/*
		valori di ritorno: 
		  1 se l'inserimento va a buon fine
		-10 se non vengono specificati tutti i parametri
		-20 se utente non è presente a sistema
		-30 se l'utente non è autorizzato (solo amministratore)
		-40 se è lega già presente a sistema
	*/
	DECLARE
		ret INTEGER;
		usr dbuser%ROWTYPE;
		lg league%ROWTYPE;

	BEGIN
		
		IF id_user IS NULL OR new_name IS NULL OR country IS NULL THEN
		
			RAISE INFO 'bisogna obbligatoriamente specificare tutti i parametri';
			ret := -10;
			
		ELSE
		
			SELECT * INTO usr FROM dbuser WHERE id = id_user;
			
			IF FOUND THEN
			
				IF usr.role != 'administrator' THEN
				
					RAISE INFO 'utente non autorizzato ad inserire league';
					ret := -30;
					
				ELSE
				
					 SELECT * INTO lg FROM league WHERE name = new_name;
					
					IF FOUND THEN
					
						RAISE INFO 'La lega % è già presente a sistema', new_name;
						ret := -40;
						
					ELSE
					
						INSERT INTO league VALUES (new_name,country);
						ret := 1;
						
					END IF;
					
				END IF;
				
			ELSE
			
				RAISE INFO 'utente % non presente a sistema', id_user;
				ret := -20;
				
			END IF;
			
		END IF;
		
		RETURN  ret;
		
	END;

$$;


ALTER FUNCTION soccerdb.insert_league(id_user integer, new_name character varying, country character varying) OWNER TO postgres;

--
-- Name: insert_match(integer, integer, date, integer, character varying, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_match(id_user integer, new_id integer, new_date date, new_stage integer, new_season character varying, new_home integer, new_away integer, new_home_goal integer, new_away_goal integer, new_league character varying, include_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

	-- funzione per inserire match (id_user INTEGER, new_id INTEGER, new_date DATE, new_stage INTEGER, new_season VARCHAR, new_home INTEGER, new_away INTEGER, new_home_goal INTEGER, new_away_goal INTEGER, new_league VARCHAR, include_id INTEGER)
	-- concesso solo ad operator
	-- vanno specificati obbligatoriamente tutti i parametri
	
	/*
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
	*/
	
	-- nel caso include_id sia 0 bisogna comunque passare un valore non null per new_id, qualsiasi valore va bene perchè non verrà considerato


DECLARE
		ret INTEGER;
		usr dbuser%ROWTYPE;
		mt match%ROWTYPE;
		matches match%ROWTYPE;
		lg league%ROWTYPE;
		awayt team%ROWTYPE;
		homet team%ROWTYPE;
		
	BEGIN
		
		
		IF id_user IS NULL OR new_date IS NULL OR new_stage IS NULL OR new_season IS NULL OR new_home IS NULL OR new_away IS NULL OR new_home_goal IS NULL OR new_away_goal IS NULL 
		OR new_league IS NULL OR new_id IS NULL OR include_id IS NULL THEN
		
			RAISE INFO 'Tutti i parametri vanno  obbligatoriamente specificati';
			ret := -10;
			
		ELSE
			IF new_home = new_away OR new_home_goal < 0 OR new_away_goal < 0 OR new_stage < 0 THEN
			
				RAISE INFO 'Parametri non validi';
				ret := -90;
			
			ELSE 
		
				SELECT * INTO usr FROM dbuser WHERE id = id_user;
				
				IF NOT FOUND THEN
				
					RAISE INFO 'Utente % non presente a sistema',id_user;
					ret := -20;
				
				ELSE
					
					IF usr.role != 'operator' THEN
					
						RAISE INFO 'Utente % non ha i privilegi per inserire match', usr.id;
						ret := -30;
					
					ELSE
						
						SELECT * INTO matches FROM match WHERE league = new_league AND date = new_date AND stage = new_stage AND season = new_season AND ((home = new_home AND away = new_away) OR (home = new_away AND away = new_home));
						
						IF FOUND THEN
							RAISE INFO 'Si sta inserendo un match già presente a sistema';
							ret:= -50;
						ELSE
							
							SELECT * INTO lg FROM league WHERE name = new_league;
							IF FOUND THEN
							
								SELECT * INTO awayt FROM team WHERE id = new_away;
								IF FOUND THEN
								
										SELECT * INTO homet FROM team WHERE id = new_home;
										IF FOUND THEN
											
												IF include_id = 1 THEN
													SELECT * INTO mt FROM match WHERE id = new_id;
													
													IF NOT FOUND THEN
														INSERT INTO match (id,date,stage,season,home,away,home_goal,away_goal,league,dbuser) VALUES (new_id,new_date,new_stage,new_season,new_home,new_away,new_home_goal,new_away_goal,new_league,id_user) RETURNING match.id INTO ret;
													ELSE
														RAISE INFO 'Il match con id % è già presente a sistema', new_id;
														RETURN -40;
													END IF;
													
													
												ELSE
													INSERT INTO match (date,stage,season,home,away,home_goal,away_goal,league,dbuser) VALUES (new_date,new_stage,new_season,new_home,new_away,new_home_goal,new_away_goal,new_league,id_user) RETURNING match.id INTO ret;
												END IF;
										
										ELSE
											RAISE INFO 'Home team % non presente a sistema', new_home;
											ret:= -80;
										END IF;
								ELSE
									RAISE INFO 'Away team % non presente a sistema', new_away;
									ret:= -70;
								END IF;
								
								
							ELSE
								RAISE INFO 'Lega % non presente a sistema', new_league;
								ret:= -60;
							END IF;

							
						END IF;
						
					END IF;
				
				END IF;
			
			END IF;
		
		END IF;
		
		RETURN ret;
		
	END;
	
$$;


ALTER FUNCTION soccerdb.insert_match(id_user integer, new_id integer, new_date date, new_stage integer, new_season character varying, new_home integer, new_away integer, new_home_goal integer, new_away_goal integer, new_league character varying, include_id integer) OWNER TO postgres;

--
-- Name: insert_player(integer, integer, character varying, date, integer, double precision); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_player(id_user integer, id_player integer, name character varying, birthday date, weight integer, height double precision) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	
	-- funzione per inserire player (id_user INTEGER, id_player INTEGER, name VARCHAR, birthday DATE, weight INTEGER, height FLOAT)
	-- concesso solo ad administrator
	-- vanno specificati obbligatoriamente id_user, id_player e name
	
	/*
		valori di ritorno: 
		  1 se l'inserimento va a buon fine
		-10 se non vengono specificati tutti i parametri
		-20 se utente non è presente a sistema
		-30 se utente non è autorizzato
		-40 se player già presente a sistema
		-50 se i parametri non sono validi
	*/
	
	DECLARE
	
		ret INTEGER;
		usr dbuser%ROWTYPE;
		pl player%ROWTYPE;
		
	BEGIN
		
		IF id_user IS NULL OR id_player IS NULL OR name IS NULL THEN
		
			RAISE INFO 'bisogna obbligatoriamente specificare id_user, id_player e name';
			ret:= -10;
			
		ELSE
		
			IF (weight IS NOT NULL AND weight < 0) OR (height IS NOT NULL AND height < 0) THEN
			
				RAISE INFO 'parametri non validi';
				ret:= -50;
				
			ELSE 
				SELECT * INTO usr FROM dbuser WHERE id = id_user;
				
				IF FOUND THEN
				
					IF usr.role != 'administrator' THEN
					
						RAISE INFO 'utente non autorizzato ad inserire player';
						ret:= -30;
						
					ELSE
					
						SELECT * INTO pl FROM player WHERE id = id_player;
						
						IF FOUND THEN
						
							RAISE INFO 'Il player % è già presente a sistema', id_player;
							ret:= -40;
							
						ELSE
						
							INSERT INTO player VALUES (id_player,name,birthday,weight,height);
							ret:=1;
							
						END IF;
						
					END IF;
					
				ELSE
				
					RAISE INFO 'utente % non presente a sistema', id_user;
					ret:= -20;
					
				END IF;
				
			END IF;
			
		END IF;
		
		RETURN ret;
		
	END;

$$;


ALTER FUNCTION soccerdb.insert_player(id_user integer, id_player integer, name character varying, birthday date, weight integer, height double precision) OWNER TO postgres;

--
-- Name: insert_playerstats(integer, integer, date, integer, integer, character varying, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_playerstats(id_user integer, new_player integer, new_attribute_date date, overall_rating integer, potential integer, preferred_foot character varying, attacking_work_rate character varying, defensive_work_rate character varying, crossing integer, finishing integer, heading_accuracy integer, short_passing integer, volleys integer, dribbling integer, curve integer, free_kick_accuracy integer, long_passing integer, ball_control integer, acceleration integer, sprint_speed integer, agility integer, reactions integer, balance integer, shot_power integer, jumping integer, stamina integer, strength integer, long_shots integer, aggression integer, interceptions integer, positioning integer, vision integer, penalties integer, marking integer, standing_tackle integer, sliding_tackle integer, gk_diving integer, gk_handling integer, gk_kicking integer, gk_positioning integer, gk_reflexes integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	
	--funzione per inserire playerstats (id_user INTEGER, new_player INTEGER,new_attribute_date DATE,overall_rating INTEGER,potential INTEGER,preferred_foot VARCHAR(10),
	--attacking_work_rate VARCHAR(10),defensive_work_rate VARCHAR(10),crossing INTEGER,finishing INTEGER,heading_accuracy INTEGER,short_passing INTEGER,
	--volleys INTEGER,dribbling INTEGER,curve INTEGER,free_kick_accuracy INTEGER,long_passing INTEGER,ball_control INTEGER,acceleration INTEGER,sprint_speed INTEGER,
	--agility INTEGER,reactions INTEGER,balance INTEGER,shot_power INTEGER,jumping INTEGER,stamina INTEGER,strength INTEGER,long_shots INTEGER, aggression INTEGER, interceptions INTEGER,
	--positioning INTEGER,vision INTEGER,penalties INTEGER,marking INTEGER,standing_tackle INTEGER,sliding_tackle INTEGER,gk_diving INTEGER,gk_handling INTEGER,gk_kicking INTEGER,
	--gk_positioning INTEGER,gk_reflexes INTEGER)
								
	-- concesso solo ad administrator
	-- vanno specificati obbligatoriamente new_player e new_attribute_date
	/*
		valori di ritorno: 
		1 se stat viene inserita correttamente
	  -10 se non vengono specificati tutti i parametri
	  -20 se utente non presente è a sistema
	  -30 se utente non è autorizzato
	  -40 se player non è presente a sistema
	  -50 se statistica è già presente a sistema
	*/
	DECLARE
	
		ret INTEGER;
		usr dbuser%ROWTYPE;
		pl player%ROWTYPE;
		pls playerstats%ROWTYPE;
		
	BEGIN
		
		IF id_user IS NULL OR new_player IS NULL OR new_attribute_date IS NULL THEN
			RAISE INFO 'bisogna obbligatoriamente specificare new_player e new_attribute_date';
			ret:= -10;
		ELSE
		
			SELECT * INTO usr FROM dbuser WHERE id = id_user;
			IF FOUND THEN
			
				IF usr.role != 'administrator' THEN
					RAISE INFO 'utente non autorizzato ad inserire playerstats';
					ret:=-30;
				ELSE
				
						SELECT * INTO pl FROM player WHERE id = new_player;
						IF FOUND THEN
							
							SELECT * INTO pls FROM playerstats WHERE player = new_player AND attribute_date = new_attribute_date;		
							IF FOUND THEN
								RAISE INFO 'La statistica del player % del % è già presente a sistema', new_player,new_attribute_date;
								ret:=-50;
							ELSE
							
								IF (preferred_foot IS NOT NULL AND preferred_foot != 'left' AND preferred_foot != 'right') THEN
									preferred_foot := NULL;
								END IF;
								
								IF (attacking_work_rate IS NOT NULL AND attacking_work_rate != 'low' AND attacking_work_rate != 'medium' AND attacking_work_rate != 'high') THEN
									attacking_work_rate := NULL;
								END IF;
								
								IF(defensive_work_rate IS NOT NULL AND defensive_work_rate != 'low' AND defensive_work_rate != 'medium' AND defensive_work_rate != 'high')THEN
									RAISE INFO 'bisogna rispettare i vincoli check';
									defensive_work_rate:=NULL;
								END IF;
								
								INSERT INTO playerstats VALUES (new_player,new_attribute_date,overall_rating,potential,preferred_foot,
									attacking_work_rate,defensive_work_rate,crossing,finishing,heading_accuracy,short_passing,
									volleys,dribbling,curve,free_kick_accuracy,long_passing,ball_control,acceleration,sprint_speed,
									agility,reactions,balance,shot_power,jumping,stamina,strength,long_shots,aggression,interceptions,
									positioning,vision,penalties,marking,standing_tackle,sliding_tackle,gk_diving,gk_handling,gk_kicking,
									gk_positioning,gk_reflexes);
									ret:=1;
							
								
							END IF;
							
						ELSE
						
							RAISE INFO 'Il player % non è presente a sistema', new_player;
							ret :=-40;
							
						END IF;
					
				END IF;
				
			ELSE
			
				RAISE INFO 'utente % non presente a sistema', id_user;
				ret:=-20;
				
			END IF;
			
		END IF;
		
		RETURN ret;
		
	END;

$$;


ALTER FUNCTION soccerdb.insert_playerstats(id_user integer, new_player integer, new_attribute_date date, overall_rating integer, potential integer, preferred_foot character varying, attacking_work_rate character varying, defensive_work_rate character varying, crossing integer, finishing integer, heading_accuracy integer, short_passing integer, volleys integer, dribbling integer, curve integer, free_kick_accuracy integer, long_passing integer, ball_control integer, acceleration integer, sprint_speed integer, agility integer, reactions integer, balance integer, shot_power integer, jumping integer, stamina integer, strength integer, long_shots integer, aggression integer, interceptions integer, positioning integer, vision integer, penalties integer, marking integer, standing_tackle integer, sliding_tackle integer, gk_diving integer, gk_handling integer, gk_kicking integer, gk_positioning integer, gk_reflexes integer) OWNER TO postgres;

--
-- Name: insert_team(integer, integer, character varying, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.insert_team(id_user integer, id_team integer, long_name character varying, short_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	
	-- funzione per inserire team (id_user INTEGER, id_team INTEGER, long_name VARCHAR, short_name VARCHAR(10))
	-- concesso solo ad administrator
	-- vanno specificati obbligatoriamente tutti i parametri
	/*
		valori di ritorno: 
		  1 se team viene inserito correttamente
		-10 se non vengono specificati tutti i parametri
		-20 se utente non è presente a sistema
		-30 se utente non è autorizzato
		-40 se team è già presente a sistema
	*/
	
	DECLARE
		ret INTEGER;
		usr dbuser%ROWTYPE;
		tm team%ROWTYPE;

	BEGIN
		
		IF id_user IS NULL OR id_team IS NULL OR long_name IS NULL OR short_name IS NULL THEN
		
			RAISE INFO  'bisogna specificare tutti i parametri';
			ret := -10;
			
		ELSE
		
			SELECT * INTO usr FROM dbuser WHERE id = id_user;
			
			IF FOUND THEN
			
				IF usr.role != 'administrator' THEN
				
					RAISE INFO  'utente non autorizzato ad inserire team';
					ret := -30;
					
				ELSE
				
					SELECT * INTO tm FROM team WHERE id = id_team;
					
					IF FOUND THEN
					
						RAISE INFO  'Il team % è già presente a sistema', id_team;
						ret := -40;
						
					ELSE
						INSERT INTO team VALUES (id_team,long_name,short_name);
						ret := 1;
					END IF;
					
				END IF;
				
			ELSE
				RAISE INFO  'utente % non presente a sistema', id_user;
				ret := -20;
			END IF;
			
		END IF;
		
		RETURN ret;
	END;

$$;


ALTER FUNCTION soccerdb.insert_team(id_user integer, id_team integer, long_name character varying, short_name character varying) OWNER TO postgres;

--
-- Name: update_bet(integer, integer, double precision, double precision, double precision); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_bet(id_user integer, id_match integer, new_h double precision, new_d double precision, new_a double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare bet(id_user INTEGER, match INTEGER, h FLOAT, d FLOAT, a FLOAT)
	--concesso solo al partner che ha inserito la scommessa
	--è necessario specificare i parametri id_user (utente che compie aggiornamento), match
	--se h o d o a vengono specificati NULL il record viene aggiornato con i valori vecchi 
	
	DECLARE
	
		usr dbuser%ROWTYPE;
		bt 	bet%ROWTYPE;
		
		update_h INTEGER;
		update_d INTEGER;
		update_a INTEGER;
		
	BEGIN
		
		IF id_user IS NULL OR id_match IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornamento) e id_match';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
		
		IF usr.role != 'partner' THEN
			RAISE EXCEPTION 'solo i partner sono autorizzati ad aggiornare le scommesse';
		END IF;
		
		SELECT * INTO bt FROM bet WHERE dbuser = id_user AND match = id_match ;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'la scommessa di id_user % relativa al match % non è presente a sistema', id_user, id_match;
		END IF;
		
		IF new_h IS NOT NULL THEN
			update_h := new_h;
		ELSE
			update_h := bt.h;
		END IF;
		
		IF new_d IS NOT NULL THEN
			update_d := new_d;
		ELSE
			update_d := bt.d;
		END IF;

		IF new_a IS NOT NULL THEN
			update_a := new_a;
		ELSE
			update_a := bt.a;
		END IF;

		UPDATE bet SET h = update_h, d = update_d, a = update_a WHERE dbuser = id_user AND match = id_match;
		
	END;

$$;


ALTER FUNCTION soccerdb.update_bet(id_user integer, id_match integer, new_h double precision, new_d double precision, new_a double precision) OWNER TO postgres;

--
-- Name: update_formation(integer, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_formation(id_user integer, id_match integer, id_player integer, id_team integer, new_match integer, new_player integer, new_team integer) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare formation (id_user INTEGER, id_match INTEGER, id_player INTEGER, id_team INTEGER, new_match INTEGER, new_player INTEGER, new_team INTEGER)
	--concesso solo ad operator con id uguale al valore contenuto nel campo db_user del match in questione
	--è necessario specificare i parametri id_user, id_match, id_player, id_team
	
	DECLARE
		usr dbuser%ROWTYPE;
		dbuserInsertedMatch INTEGER;
		fm formation%ROWTYPE;
		
		update_id_match INTEGER;
		update_id_team INTEGER;
		update_id_player INTEGER;
		
		countFormation INTEGER;
	BEGIN
		
		IF id_user IS NULL OR id_match IS NULL OR id_player IS NULL OR id_team IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornamento), id_match, id_player, id_team';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
		
		IF usr.role != 'operator'  THEN
			RAISE EXCEPTION 'utente non autorizzato ad aggiornare formation';
		END IF;
		
		SELECT M.dbuser INTO dbuserInsertedMatch FROM formation AS F JOIN match AS M ON F.match = M.id WHERE F.match = id_match AND F.player = id_player AND F.team = id_team;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'formation %,%,% non è presente a sistema', id_match, id_player, id_team;
		END IF;
		
		IF id_user != dbuserInsertedMatch THEN
			RAISE EXCEPTION 'solo utente % può aggiornare formation', dbuserInsertedMatch;
		END IF;
		
		SELECT * INTO fm FROM formation WHERE match = id_match AND player = id_player AND team = id_team;
		
		IF new_match IS NOT NULL THEN
			PERFORM * FROM match WHERE id = new_match;
			IF FOUND THEN
				update_id_match := new_match;
			ELSE
				RAISE EXCEPTION 'match % non presente a sistema', new_match;
			END IF;
		ELSE
			update_id_match := fm.match;
		END IF;
		
		IF new_player IS NOT NULL THEN
			PERFORM * FROM player WHERE id = new_player;
			IF FOUND THEN
				update_id_player := new_player;
			ELSE
				RAISE EXCEPTION 'player % non presente a sistema', new_player;
			END IF;
		ELSE
			update_id_player := fm.player;
		END IF;
		
		IF new_team IS NOT NULL THEN
			PERFORM * FROM team WHERE id = new_team;
			IF FOUND THEN
				update_id_team := new_team;
			ELSE
				RAISE EXCEPTION 'team % non presente a sistema', new_team;
			END IF;
		ELSE
			update_id_team := fm.team;
		END IF;
		
		PERFORM * FROM formation WHERE match = update_id_match AND player = update_id_player AND team = update_id_team;
		IF FOUND THEN 
			RAISE EXCEPTION 'formation %,%,% è già presente a sistema', update_id_match, update_id_player, update_id_team;
		END IF;

		countFormation := (SELECT count(*)::int FROM formation WHERE match = update_id_match AND team = update_id_team);
		IF countFormation >= 11 THEN
			RAISE EXCEPTION 'formazione del team % per il match % è già al completo', update_id_team, update_id_match;
		END IF;
	
		UPDATE formation SET match = update_id_match, player = update_id_player, team = update_id_team WHERE match = id_match AND player = id_player AND team = id_team;
		
	END;

$$;


ALTER FUNCTION soccerdb.update_formation(id_user integer, id_match integer, id_player integer, id_team integer, new_match integer, new_player integer, new_team integer) OWNER TO postgres;

--
-- Name: update_league(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_league(id_user integer, leaguetoupdate character varying, new_name character varying, new_country character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare league (id_user INTEGER, curr_name VARCHAR,  new_name VARCHAR, new_country VARCHAR)
	--concesso solo ad administrator
	--bisogna obbligatoriamente specificare id_user e leagueToUpdate
	
	DECLARE
		usr dbuser%ROWTYPE;
		lg	league%ROWTYPE;
		lgn league%ROWTYPE;
		
		update_name VARCHAR;
		update_country VARCHAR;
		
	BEGIN
		
		IF id_user IS NULL OR curr_name IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornamento) e leagueToUpdate';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato ad aggiornare league';
		END IF;
		
		SELECT * INTO lg FROM league WHERE name = leagueToUpdate;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'la lega % non è presente a sistema', leagueToUpdate;
		END IF;
		
		IF new_country IS NOT NULL THEN
			update_country := new_country;
		ELSE
			update_country := lg.country;
		END IF;
		
		IF new_name IS NOT NULL THEN
			PERFORM * FROM league WHERE name = new_name;
			IF FOUND THEN
				RAISE EXCEPTION 'la lega % è già presente a sistema', new_name;
			ELSE
				update_name := new_name;
			END IF;
		ELSE
			update_name := lg.name;
		END IF;
							
		UPDATE league SET name = update_name, country = update_country WHERE name = leagueToUpdate;			
					
	END;

$$;


ALTER FUNCTION soccerdb.update_league(id_user integer, leaguetoupdate character varying, new_name character varying, new_country character varying) OWNER TO postgres;

--
-- Name: update_match(integer, integer, integer, date, integer, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_match(id_user integer, matchtoupdate integer, new_id_match integer, new_date date, new_stage integer, new_season integer, new_home integer, new_away integer, new_home_goal integer, new_away_goal integer, new_league character varying, new_db_user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare match (id_user INTEGER, matchToUpdate INTEGER, new_id_match INTEGER, new_date DATE, new_stage INTEGER,new_season INTEGER,new_home INTEGER,new_away INTEGER,new_home_goal INTEGER,new_away_goal INTEGER, new_league INTEGER,new_db_user INTEGER)
	--concesso solo ad user con stesso id dell'attributo dbuser di match
	--è necessario specificare id_user (utente che compie l'operazione) e matchToUpdate (da aggiornare)

	DECLARE
	
		usr dbuser%ROWTYPE;
		usr_new dbuser%ROWTYPE;
		mt match%ROWTYPE;
		lg league%ROWTYPE;
		
		update_id_match INTEGER;
		update_date DATE;
		update_stage INTEGER;
		update_season VARCHAR;
		update_home INTEGER;
		update_away INTEGER;
		update_home_goal INTEGER;
		update_away_goal INTEGER;
		update_league VARCHAR;
		update_dbuser INTEGER;
		
	BEGIN
		
		IF id_user IS NULL OR matchToUpdate IS NULL THEN
			RAISE EXCEPTION 'bisogna obbligatoriamente specificare id_user (utente che compie aggiornamento) e matchToUpdate';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
		
		SELECT * INTO mt FROM match WHERE id = matchToUpdate;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'match % non presente a sistema', matchToUpdate;
		END IF;
		
		PERFORM * FROM match WHERE league = new_league AND date = new_date AND stage = new_stage AND season = new_season AND ((home = new_home AND away = new_away) OR (home = new_away AND away = new_home));
		IF FOUND THEN
			RAISE EXCEPTION 'Si sta inserendo un match già presente a sistema';
		END IF;
			
		IF usr.role != 'operator' THEN
			RAISE EXCEPTION 'Solo gli utenti operator possono aggiornare i match';
		END IF;
		
		IF mt.dbuser != id_user THEN
			RAISE EXCEPTION 'Solo utente % può aggiornare questo match', mt.dbuser ;
		END IF;
		
		IF new_id_match IS NOT NULL THEN
			PERFORM * FROM match WHERE id = new_id_match;
			IF FOUND THEN
				RAISE EXCEPTION 'il match % è già presente a sistema', new_id_match;
			ELSE
				update_id_match := new_id_match;
			END IF;
		ELSE
			update_id_match := mt.id;
		END IF;
		
		IF new_db_user IS NOT NULL THEN
			SELECT * INTO usr_new FROM dbuser WHERE id = new_db_user;
			IF FOUND THEN
				IF usr_new.role != 'operator' THEN
					RAISE EXCEPTION 'utente % non è un operatore', usr_new.id ;
				ELSE
					update_dbuser := usr_new.id;
				END IF;
			ELSE
				RAISE EXCEPTION 'utente % non presente a sistema', new_db_user;
			END IF;
		ELSE
			update_dbuser := mt.dbuser;
		END IF;
		
		IF new_league IS NOT NULL THEN
			SELECT * INTO lg FROM league WHERE name = new_league;
			IF FOUND THEN
				update_league := new_league;
			ELSE
				RAISE EXCEPTION 'la lega % non è presente a sistema', new_league ;
			END IF;
		ELSE
			update_league := mt.league;
		END IF;
		
		IF new_home IS NOT NULL THEN
			PERFORM * FROM team WHERE id = new_home;
			IF FOUND THEN
				update_home := new_home;
			ELSE
				RAISE EXCEPTION 'il team % non è presente a sistema', new_home;
			END IF;
		ELSE
			update_home := tm.home;
		END IF;
		
		IF new_away IS NOT NULL THEN
			PERFORM * FROM team WHERE id = new_away;
			IF FOUND THEN
				update_away := new_away;
			ELSE
				RAISE EXCEPTION 'il team % non è presente a sistema', new_away;
			END IF;
		ELSE
			update_away := tm.away;
		END IF;
		
		IF new_date IS NOT NULL THEN
			update_date := new_date;
		ELSE
			update_date := mt.date;
		END IF;
		
		IF new_stage IS NOT NULL THEN
			update_stage := new_stage;
		ELSE
			update_stage := mt.stage;
		END IF;
		
		IF new_season IS NOT NULL THEN
			update_season := new_season;
		ELSE
			update_season := mt.season;
		END IF;
		
		IF new_home_goal IS NOT NULL THEN
			update_home_goal := new_home_goal;
		ELSE
			update_home_goal := mt.home_goal;
		END IF;

		IF new_away_goal IS NOT NULL THEN
			update_away_goal := new_away_goal;
		ELSE
			update_away_goal := mt.away_goal;
		END IF;
		
		UPDATE match SET id = update_id_match, date = update_date, stage = update_stage, season = update_season, home = update_home, away = update_away, home_goal = update_home_goal, away_goal = update_away_goal, league = update_league, dbuser = update_dbuser WHERE id = matchToUpdate;
		
	END;

$$;


ALTER FUNCTION soccerdb.update_match(id_user integer, matchtoupdate integer, new_id_match integer, new_date date, new_stage integer, new_season integer, new_home integer, new_away integer, new_home_goal integer, new_away_goal integer, new_league character varying, new_db_user integer) OWNER TO postgres;

--
-- Name: update_player(integer, integer, integer, character varying, date, double precision, double precision); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_player(id_user integer, playertoupdate integer, new_id_player integer, new_name character varying, new_birthday date, new_weight double precision, new_height double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare player (id_user INTEGER, playerToUpdate INTEGER, new_id_player INTEGER, new_name VARCHAR, new_birthday DATE, new_weight FLOAT, new_height FLOAT)
	--concesso solo ad administrator
	--è necessario specificare id_user  e playerToUpdate

	DECLARE
		usr dbuser%ROWTYPE;
		pl	player%ROWTYPE;
		
		update_id_player INTEGER;
		update_name VARCHAR;
		update_birthday DATE;
		update_weigth FLOAT;
		update_height FLOAT;
		
	BEGIN
		
		IF id_user IS NULL OR teamToUpdate IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornameto) e playerToUpdate';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
	
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato ad inserire player';
		END IF;

		SELECT * INTO pl FROM player WHERE id = teamToUpdate;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Il player % non è presente a sistema', teamToUpdate;
		END IF;
		
		IF new_id_player IS NOT NULL THEN
		PERFORM * FROM player WHERE id = new_id_player;
		IF FOUND THEN
			RAISE EXCEPTION 'Il player % è già presente a sistema', new_id_player;
			ELSE
				update_id_player := new_id_player;
			END IF;
		ELSE
			update_id_player := pl.id;
		END IF;
		
		IF new_name IS NOT NULL THEN
			update_name := new_name;
		ELSE
			update_name := pl.name;
		END IF;
						
		UPDATE player SET id = update_id_player, name = update_name, birthday = new_birthday, weight = new_weight, height = new_height WHERE id = teamToUpdate;
		
	END;

$$;


ALTER FUNCTION soccerdb.update_player(id_user integer, playertoupdate integer, new_id_player integer, new_name character varying, new_birthday date, new_weight double precision, new_height double precision) OWNER TO postgres;

--
-- Name: update_playerstats(integer, integer, date, integer, date, integer, integer, character varying, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_playerstats(id_user integer, id_player integer, upd_attribute_date date, new_player integer, new_attribute_date date, new_overall_rating integer, new_potential integer, new_preferred_foot character varying, new_attacking_work_rate character varying, new_defensive_work_rate character varying, new_crossing integer, new_finishing integer, new_heading_accuracy integer, new_short_passing integer, new_volleys integer, new_dribbling integer, new_curve integer, new_free_kick_accuracy integer, new_long_passing integer, new_ball_control integer, new_acceleration integer, new_sprint_speed integer, new_agility integer, new_reactions integer, new_balance integer, new_shot_power integer, new_jumping integer, new_stamina integer, new_strength integer, new_long_shots integer, new_aggression integer, new_interceptions integer, new_positioning integer, new_vision integer, new_penalties integer, new_marking integer, new_standing_tackle integer, new_sliding_tackle integer, new_gk_diving integer, new_gk_handling integer, new_gk_kicking integer, new_gk_positioning integer, new_gk_reflexes integer) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare playerstats 
	--(id_user INTEGER, player INTEGER, attribute_date DATE,new_player INTEGER,new_attribute_date DATE,new_overall_rating INTEGER,new_potential INTEGER,new_preferred_foot VARCHAR(10),new_attacking_work_rate VARCHAR(10),new_defensive_work_rate VARCHAR(10),
	--new_crossing INTEGER,new_finishing INTEGER,new_heading_accuracy INTEGER,new_short_passing INTEGER,new_volleys INTEGER,new_dribbling INTEGER,new_curve INTEGER,new_free_kick_accuracy INTEGER,new_ball_control INTEGER,
	--new_acceleration INTEGER,new_sprint_speed INTEGER,new_agility INTEGER,new_reactions INTEGER,new_shot_power INTEGER,new_jumping INTEGER,new_stamina INTEGER,new_long_shots INTEGER,
	--new_aggression INTEGER,new_interceptions INTEGER,new_positioning INTEGER,new_vision INTEGER,new_penalties INTEGER,new_marking INTEGER,new_standing_tackle INTEGER,new_sliding_tackle INTEGER,new_gk_diving INTEGER,
	--new_gk_handling INTEGER,new_gk_kicking INTEGER,new_gk_positioning INTEGER,new_gk_reflexes INTEGER)
	--concesso solo ad administrator
	--bisogna obbligatoriamente specificare id_user,player,attribute_date
	
	DECLARE
		usr dbuser%ROWTYPE;
		ps	playerstats%ROWTYPE;
		
		update_player INTEGER;
		update_attribute_date DATE;
		
	BEGIN
		
		IF id_user IS NULL OR curr_name IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornamento), player, attribute_date';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
			
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato ad aggiornare playerstats';
		END IF;
		
		SELECT * INTO ps FROM playerstats WHERE player = id_player AND attribute_date = upd_attribute_date;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'playerstat %,% non è presente a sistema', id_player, upd_attribute_date;
		END IF;
		
		IF new_player IS NOT NULL THEN
			PERFORM * FROM player WHERE id = new_player;
			IF NOT FOUND THEN
				RAISE EXCEPTION 'player % non è presente a sistema', new_player;
			ELSE
				update_player := new_player;
			END IF;
		ELSE
			update_player := ps.player;
		END IF;
		
		IF new_attribute_date IS NOT NULL THEN
			update_attribute_date := new_attribute_date;
		ELSE
			update_attribute_date := ps.attribute_date;
		END IF;
		
		UPDATE playerstats SET player = update_player, attribute_date = update_attribute_date,
								overall_rating =  new_overall_rating,
								potential = new_potential,
								preferred_foot = new_preferred_foot,
								attacking_work_rate = new_attacking_work_rate,
								defensive_work_rate = new_defensive_work_rate,
								crossing = new_crossing,
								finishing = new_finishing,
								heading_accuracy = new_heading_accuracy,
								short_passing = new_short_passing,
								volleys = new_volleys,
								dribbling = new_dribbling,
								curve = new_curve,
								free_kick_accuracy = new_free_kick_accuracy,
								long_passing = new_long_passing,
								ball_control = new_ball_control,
								acceleration = new_acceleration,
								sprint_speed = new_sprint_speed,
								agility = new_agility,
								reactions = new_reactions,
								balance = new_balance,
								shot_power = new_shot_power,
								jumping = new_jumping, 
								stamina = new_stamina,
								strength = new_strength, 
								long_shots = new_long_shots,
								aggression = new_aggression,
								interceptions = new_interceptions,
								positioning = new_positioning,
								vision = new_vision,
								penalties = new_penalties,
								marking = new_marking,
								standing_tackle = new_standing_tackle, 
								sliding_tackle = new_sliding_tackle,
								gk_diving = new_gk_diving,
								gk_handling = new_gk_handling,
								gk_kicking = new_gk_kicking,
								gk_positioning = new_gk_positioning,
								gk_reflexes = new_gk_reflexes
		WHERE player = id_player AND attribute_date = upd_attribute_date;			
					
	END;

$$;


ALTER FUNCTION soccerdb.update_playerstats(id_user integer, id_player integer, upd_attribute_date date, new_player integer, new_attribute_date date, new_overall_rating integer, new_potential integer, new_preferred_foot character varying, new_attacking_work_rate character varying, new_defensive_work_rate character varying, new_crossing integer, new_finishing integer, new_heading_accuracy integer, new_short_passing integer, new_volleys integer, new_dribbling integer, new_curve integer, new_free_kick_accuracy integer, new_long_passing integer, new_ball_control integer, new_acceleration integer, new_sprint_speed integer, new_agility integer, new_reactions integer, new_balance integer, new_shot_power integer, new_jumping integer, new_stamina integer, new_strength integer, new_long_shots integer, new_aggression integer, new_interceptions integer, new_positioning integer, new_vision integer, new_penalties integer, new_marking integer, new_standing_tackle integer, new_sliding_tackle integer, new_gk_diving integer, new_gk_handling integer, new_gk_kicking integer, new_gk_positioning integer, new_gk_reflexes integer) OWNER TO postgres;

--
-- Name: update_team(integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_team(id_user integer, teamtoupdate integer, new_id_team integer, new_long_name character varying, new_short_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per aggiornare team (id_user INTEGER, teamToUpdate INTEGER, new_id_team INTEGER, new_long_name VARCHAR, new_short_name VARCHAR(10))
	--concesso solo ad administrator
	--è necessario specificare i parametri id_user e teamToUpdate
	
	DECLARE
		usr dbuser%ROWTYPE;
		tm	team%ROWTYPE;
		tmn team%ROWTYPE;
		
		update_id_team VARCHAR;
		update_long_name VARCHAR;
		update_short_name VARCHAR(10);
		
	BEGIN
		
		IF id_user IS NULL OR teamToUpdate IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornamento) e teamToUpdate';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
		
		IF usr.role != 'administrator' THEN
			RAISE EXCEPTION 'utente non autorizzato ad aggiornare team';
		END IF;

		SELECT * INTO tm FROM team WHERE id = teamToUpdate;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'il team % non è presente a sistema', teamToUpdate;
		END IF;
		
		IF new_id_team IS NOT NULL THEN
			PERFORM * FROM team WHERE id= new_id_team;
			IF FOUND THEN 
				RAISE EXCEPTION 'Il team % è già presente a sistema', new_id_team;
			ELSE
				update_id_team := new_team_id;
			END IF;
		ELSE
			update_id_team := tm.id;				
		END IF;
		
		IF new_long_name IS NOT NULL THEN
			update_long_name := new_long_name;
		ELSE
			update_long_name := tm.long_name;
		END IF;
						
		IF new_short_name IS NOT NULL THEN
			update_short_name := new_short_name;
		ELSE 
			update_short_name := tm.short_name;
		END IF;
		
		UPDATE team SET id = update_id_team, long_name = update_long_name, short_name = update_short_name WHERE id = teamToUpdate;

	END;

$$;


ALTER FUNCTION soccerdb.update_team(id_user integer, teamtoupdate integer, new_id_team integer, new_long_name character varying, new_short_name character varying) OWNER TO postgres;

--
-- Name: update_user(integer, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: soccerdb; Owner: postgres
--

CREATE FUNCTION soccerdb.update_user(id_user integer, usertoupdate integer, new_username character varying, new_password character varying, new_role character varying, new_betcompany character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$ 

	--funzione per permettere di aggiornare utenti(id_user INTEGER, userToUpdate INTEGER, new_username VARCHAR, new_password VARCHAR, new_role VARCHAR, new_betcompany VARCHAR(10))
	--è necessario specificare i parametri id_user (utente che compie aggiornamento) e userToUpdate
	--se utente con id_user è admin allora può aggiornare qualsiasi utente altrimenti un utente non administrator può aggiorare solo sè stesso
	--se new_username e/o new_password e/o new_role vengono specificati con valore NULL il record viene aggiornato con i valori già esistenti
	--se l'utente che si vuole aggiornare è partner e deve rimanere partner anche dopo l'aggiornamento va specificato anche new_betcompany
	
	DECLARE
	
		usr dbuser%ROWTYPE;
		updUsr dbuser%ROWTYPE;
		
		update_username VARCHAR;
		update_password VARCHAR;
		update_role VARCHAR;
		update_betcompany VARCHAR(10);
		
	BEGIN
		
		IF id_user IS NULL OR userToUpdate IS NULL THEN
			RAISE EXCEPTION 'bisogna specificare id_user (utente che compie aggiornamento) e userToUpdate';
		END IF;
		
		SELECT * INTO usr FROM dbuser WHERE id = id_user;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % non presente a sistema', id_user;
		END IF;
		
		IF usr.role != 'administrator' AND usr.id != userToUpdate THEN
			RAISE EXCEPTION 'solo gli amministratori possono aggiornare altri utenti';
		END IF;
		
		SELECT * INTO updUsr FROM dbuser WHERE id = userToUpdate;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'utente % da aggiornare non presente a sistema', userToUpdate;
		END IF;
		
		IF new_username IS NOT NULL THEN
			update_username := new_username;
		ELSE
			update_username := updUsr.username;
		END IF;
		
		IF new_password IS NOT NULL THEN
			update_password := new_password;
		ELSE
			update_password := updUsr.password;
		END IF;

		IF new_role IS NOT NULL THEN
			update_role := new_role;
		ELSE
			update_role := updUsr.role;
		END IF;
		
		IF updUsr.role = 'partner' AND update_role = 'partner' AND new_betcompany IS NULL THEN
			update_betcompany := updUsr.betcompany;
		END IF;
		
		IF updUsr.role = 'partner' AND update_role = 'partner' AND new_betcompany IS NOT NULL THEN
			update_betcompany := new_betcompany;
		END IF;
		
		IF update_role = 'administrator' OR update_role = 'operator' AND new_betcompany IS NOT NULL THEN
			RAISE EXCEPTION 'solo gli utenti partner possono essere associati a società di scommesse';
		END IF;
	
		IF update_role = 'administrator' OR update_role = 'operator' THEN
			update_betcompany := NULL;
		END IF;

		UPDATE dbuser SET username = update_username, password = update_password, role = update_role, betcompany = update_betcompany WHERE id = updUsr.id;
		
	END;

$$;


ALTER FUNCTION soccerdb.update_user(id_user integer, usertoupdate integer, new_username character varying, new_password character varying, new_role character varying, new_betcompany character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: formation; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.formation (
    match integer NOT NULL,
    player integer NOT NULL,
    team integer NOT NULL
);


ALTER TABLE soccerdb.formation OWNER TO postgres;

--
-- Name: match; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.match (
    id integer NOT NULL,
    date date NOT NULL,
    stage integer NOT NULL,
    season character varying NOT NULL,
    home integer NOT NULL,
    away integer NOT NULL,
    home_goal integer NOT NULL,
    away_goal integer NOT NULL,
    league character varying NOT NULL,
    dbuser integer NOT NULL,
    CONSTRAINT match_positive_awaygoal CHECK ((away_goal >= 0)),
    CONSTRAINT match_positive_homegoal CHECK ((home_goal >= 0))
);


ALTER TABLE soccerdb.match OWNER TO postgres;

--
-- Name: playerstats; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.playerstats (
    player integer NOT NULL,
    attribute_date date NOT NULL,
    overall_rating integer,
    potential integer,
    preferred_foot character varying(10),
    attacking_work_rate character varying(10),
    defensive_work_rate character varying(10),
    crossing integer,
    finishing integer,
    heading_accuracy integer,
    short_passing integer,
    volleys integer,
    dribbling integer,
    curve integer,
    free_kick_accuracy integer,
    long_passing integer,
    ball_control integer,
    acceleration integer,
    sprint_speed integer,
    agility integer,
    reactions integer,
    balance integer,
    shot_power integer,
    jumping integer,
    stamina integer,
    strength integer,
    long_shots integer,
    aggression integer,
    interceptions integer,
    positioning integer,
    vision integer,
    penalties integer,
    marking integer,
    standing_tackle integer,
    sliding_tackle integer,
    gk_diving integer,
    gk_handling integer,
    gk_kicking integer,
    gk_positioning integer,
    gk_reflexes integer,
    CONSTRAINT attacking_work_rate CHECK (((attacking_work_rate)::text = ANY ((ARRAY['medium'::character varying, 'high'::character varying, 'low'::character varying])::text[]))),
    CONSTRAINT defensive_work_rate CHECK (((defensive_work_rate)::text = ANY ((ARRAY['medium'::character varying, 'high'::character varying, 'low'::character varying])::text[]))),
    CONSTRAINT preferred_foot_check CHECK (((preferred_foot)::text = ANY ((ARRAY['left'::character varying, 'right'::character varying])::text[])))
);


ALTER TABLE soccerdb.playerstats OWNER TO postgres;

--
-- Name: most_recent_attribute; Type: VIEW; Schema: soccerdb; Owner: postgres
--

CREATE VIEW soccerdb.most_recent_attribute AS
 SELECT m.id AS match,
    m.home,
    m.away,
    f.team,
    f.player,
    ps.attribute_date,
    ps.overall_rating
   FROM ((soccerdb.match m
     JOIN soccerdb.formation f ON ((m.id = f.match)))
     JOIN soccerdb.playerstats ps ON ((f.player = ps.player)))
  WHERE ((ps.attribute_date >= m.date) AND (ps.attribute_date <= ALL ( SELECT psi.attribute_date
           FROM soccerdb.playerstats psi
          WHERE ((psi.player = ps.player) AND (psi.attribute_date >= m.date)))));


ALTER TABLE soccerdb.most_recent_attribute OWNER TO postgres;

--
-- Name: player; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.player (
    id integer NOT NULL,
    name character varying NOT NULL,
    birthday date,
    weight integer,
    height double precision,
    CONSTRAINT player_positive_height CHECK ((height >= (0)::double precision)),
    CONSTRAINT player_positive_weight CHECK ((weight >= 0))
);


ALTER TABLE soccerdb.player OWNER TO postgres;

--
-- Name: best_player; Type: VIEW; Schema: soccerdb; Owner: postgres
--

CREATE VIEW soccerdb.best_player AS
 WITH best_home_player(match, team, player, attribute_date, overall_rating) AS (
         SELECT ra.match,
            ra.team,
            ra.player,
            ra.attribute_date,
            ra.overall_rating
           FROM soccerdb.most_recent_attribute ra
          WHERE ((ra.home = ra.team) AND (ra.overall_rating >= ALL ( SELECT rai.overall_rating
                   FROM soccerdb.most_recent_attribute rai
                  WHERE ((rai.match = ra.match) AND (rai.home = rai.team)))))
        ), best_away_player(match, team, player, attribute_date, overall_rating) AS (
         SELECT ra.match,
            ra.team,
            ra.player,
            ra.attribute_date,
            ra.overall_rating
           FROM soccerdb.most_recent_attribute ra
          WHERE ((ra.away = ra.team) AND (ra.overall_rating >= ALL ( SELECT rai.overall_rating
                   FROM soccerdb.most_recent_attribute rai
                  WHERE ((rai.match = ra.match) AND (rai.away = rai.team)))))
        )
 SELECT m.id AS match,
    m.home AS home_team_id,
    bh.player AS best_home_player_id,
    bh.overall_rating AS best_home_player_rating,
    bh.attribute_date AS home_player_attribute_date,
    hp.name AS best_home_player_name,
    hp.birthday AS best_home_player_birthday,
    hp.weight AS best_home_player_weight,
    hp.height AS best_home_player_height,
    m.away AS away_team_id,
    ba.player AS best_away_player_id,
    ba.overall_rating AS best_away_player_rating,
    ba.attribute_date AS away_player_attribute_date,
    ap.name AS best_away_player_name,
    ap.birthday AS best_away_player_birthday,
    ap.weight AS best_away_player_weight,
    ap.height AS best_away_player_height
   FROM ((((soccerdb.match m
     LEFT JOIN best_home_player bh ON ((m.id = bh.match)))
     LEFT JOIN best_away_player ba ON ((m.id = ba.match)))
     LEFT JOIN soccerdb.player hp ON ((bh.player = hp.id)))
     LEFT JOIN soccerdb.player ap ON ((ba.player = ap.id)));


ALTER TABLE soccerdb.best_player OWNER TO postgres;

--
-- Name: bet; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.bet (
    match integer NOT NULL,
    dbuser integer NOT NULL,
    h double precision NOT NULL,
    d double precision NOT NULL,
    a double precision NOT NULL,
    CONSTRAINT bet_positive_a CHECK ((a >= (0)::double precision)),
    CONSTRAINT bet_positive_d CHECK ((d >= (0)::double precision)),
    CONSTRAINT bet_positive_h CHECK ((h >= (0)::double precision))
);


ALTER TABLE soccerdb.bet OWNER TO postgres;

--
-- Name: dbuser; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.dbuser (
    id integer NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    role character varying NOT NULL,
    betcompany character varying(10),
    CONSTRAINT dbuser_role_check CHECK (((role)::text = ANY ((ARRAY['administrator'::character varying, 'operator'::character varying, 'partner'::character varying])::text[])))
);


ALTER TABLE soccerdb.dbuser OWNER TO postgres;

--
-- Name: dbuser_id_seq; Type: SEQUENCE; Schema: soccerdb; Owner: postgres
--

CREATE SEQUENCE soccerdb.dbuser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soccerdb.dbuser_id_seq OWNER TO postgres;

--
-- Name: dbuser_id_seq; Type: SEQUENCE OWNED BY; Schema: soccerdb; Owner: postgres
--

ALTER SEQUENCE soccerdb.dbuser_id_seq OWNED BY soccerdb.dbuser.id;


--
-- Name: league; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.league (
    name character varying NOT NULL,
    country character varying NOT NULL
);


ALTER TABLE soccerdb.league OWNER TO postgres;

--
-- Name: match_id_seq; Type: SEQUENCE; Schema: soccerdb; Owner: postgres
--

CREATE SEQUENCE soccerdb.match_id_seq
    AS integer
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soccerdb.match_id_seq OWNER TO postgres;

--
-- Name: match_id_seq; Type: SEQUENCE OWNED BY; Schema: soccerdb; Owner: postgres
--

ALTER SEQUENCE soccerdb.match_id_seq OWNED BY soccerdb.match.id;


--
-- Name: team; Type: TABLE; Schema: soccerdb; Owner: postgres
--

CREATE TABLE soccerdb.team (
    id integer NOT NULL,
    long_name character varying NOT NULL,
    short_name character varying(10) NOT NULL
);


ALTER TABLE soccerdb.team OWNER TO postgres;

--
-- Name: ranking; Type: MATERIALIZED VIEW; Schema: soccerdb; Owner: postgres
--

CREATE MATERIALIZED VIEW soccerdb.ranking AS
 WITH home_team_matches_won(league, season, team, matches_won, tie) AS (
         SELECT mh.league,
            mh.season,
            t.id AS team,
            count(mh.id) AS home_matches_won,
            0 AS tie
           FROM (soccerdb.team t
             JOIN soccerdb.match mh ON ((mh.home = t.id)))
          WHERE (mh.home_goal > mh.away_goal)
          GROUP BY mh.league, mh.season, t.id
        ), away_team_matches_won(league, season, team, matches_won, tie) AS (
         SELECT ma.league,
            ma.season,
            t.id AS team,
            count(ma.id) AS away_matches_won,
            0 AS tie
           FROM (soccerdb.team t
             JOIN soccerdb.match ma ON ((ma.away = t.id)))
          WHERE (ma.home_goal < ma.away_goal)
          GROUP BY ma.league, ma.season, t.id
        ), home_team_matches_tie(league, season, team, matches_won, tie) AS (
         SELECT mh.league,
            mh.season,
            t.id AS team,
            0 AS home_matches_won,
            count(mh.id) AS tie
           FROM (soccerdb.team t
             JOIN soccerdb.match mh ON ((mh.home = t.id)))
          WHERE (mh.home_goal = mh.away_goal)
          GROUP BY mh.league, mh.season, t.id
        ), away_team_matches_tie(league, season, team, matches_won, tie) AS (
         SELECT ma.league,
            ma.season,
            t.id AS team,
            0 AS away_matches_won,
            count(ma.id) AS tie
           FROM (soccerdb.team t
             JOIN soccerdb.match ma ON ((ma.away = t.id)))
          WHERE (ma.home_goal = ma.away_goal)
          GROUP BY ma.league, ma.season, t.id
        )
 SELECT d.league,
    d.season,
    d.team,
    sum(d.matches_won) AS matches_won,
    sum(d.tie) AS tie
   FROM ( SELECT home_team_matches_won.league,
            home_team_matches_won.season,
            home_team_matches_won.team,
            home_team_matches_won.matches_won,
            home_team_matches_won.tie
           FROM home_team_matches_won
        UNION ALL
         SELECT away_team_matches_won.league,
            away_team_matches_won.season,
            away_team_matches_won.team,
            away_team_matches_won.matches_won,
            away_team_matches_won.tie
           FROM away_team_matches_won
        UNION ALL
         SELECT home_team_matches_tie.league,
            home_team_matches_tie.season,
            home_team_matches_tie.team,
            home_team_matches_tie.matches_won,
            home_team_matches_tie.tie
           FROM home_team_matches_tie
        UNION ALL
         SELECT away_team_matches_tie.league,
            away_team_matches_tie.season,
            away_team_matches_tie.team,
            away_team_matches_tie.matches_won,
            away_team_matches_tie.tie
           FROM away_team_matches_tie) d
  GROUP BY d.league, d.season, d.team
  ORDER BY d.league, d.season, (sum(d.matches_won)) DESC, (sum(d.tie)) DESC
  WITH NO DATA;


ALTER TABLE soccerdb.ranking OWNER TO postgres;

--
-- Name: dbuser id; Type: DEFAULT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.dbuser ALTER COLUMN id SET DEFAULT nextval('soccerdb.dbuser_id_seq'::regclass);


--
-- Name: match id; Type: DEFAULT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.match ALTER COLUMN id SET DEFAULT nextval('soccerdb.match_id_seq'::regclass);


--
-- Data for Name: bet; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.bet (match, dbuser, h, d, a) FROM stdin;
\.


--
-- Data for Name: dbuser; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.dbuser (id, username, password, role, betcompany) FROM stdin;
1	admin1	admin1	administrator	\N
2	operator1	operator1	operator	\N
3	partner1	partner1	partner	B365
4	operator2	operator2	operator	\N
\.


--
-- Data for Name: formation; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.formation (match, player, team) FROM stdin;
145	39890	9996
145	34480	8635
145	38388	8635
145	38788	9996
145	26458	8635
145	38312	9996
145	13423	8635
145	26235	9996
145	38389	8635
145	38798	8635
145	30949	8635
145	38253	8635
145	26916	9996
145	106013	8635
145	38383	8635
145	94289	9996
145	46552	8635
146	38327	8203
146	37937	9987
146	67950	8203
146	38293	9987
146	67958	8203
146	148313	9987
146	67959	8203
146	104411	9987
146	37112	8203
146	148314	9987
146	36393	8203
146	37202	9987
146	148286	8203
146	43158	9987
146	67898	8203
146	9307	9987
146	164352	8203
146	42153	9987
146	38801	8203
146	32690	9987
146	26502	8203
146	38782	9987
147	95597	9986
147	38252	9998
147	39156	9998
147	39151	9998
147	38435	9986
147	166554	9998
147	94462	9986
147	15652	9998
147	46004	9986
147	39145	9998
147	164732	9986
147	46890	9998
147	38947	9998
147	38246	9986
147	46881	9998
147	38423	9986
147	39158	9998
147	38419	9986
147	119118	9998
148	36835	9984
148	39580	9985
148	37047	9984
148	30692	9985
148	37021	9984
148	37861	9985
148	38186	9984
148	47411	9985
148	27110	9984
148	119117	9985
148	32863	9984
148	35412	9985
148	37957	9984
148	39631	9985
148	37909	9984
148	39591	9985
148	104386	9984
148	25957	9985
148	38251	9984
148	38369	9985
148	37065	9984
149	30934	9994
149	104378	9991
149	38292	9994
149	27838	9991
149	11569	9994
149	36841	9991
149	38273	9994
149	38337	9991
149	14642	9994
149	38945	9994
149	33662	9991
149	38290	9994
149	37044	9991
149	95609	9994
149	32760	9991
149	38257	9994
149	38229	9991
149	12574	9991
149	121639	9994
149	46335	9991
150	37990	8342
150	38318	9999
150	37983	8342
150	46580	9999
150	21812	8342
150	38247	9999
150	11736	8342
150	16387	9999
150	37858	8342
150	94284	9999
150	39578	8342
150	38336	8342
150	45832	9999
150	38366	8342
150	33671	9999
150	52280	8342
150	163670	9999
150	27423	8342
150	33622	9999
150	38440	8342
150	148336	9999
151	38391	9993
151	33676	8571
151	36849	9993
151	67940	8571
151	46231	8571
151	36845	9993
151	67939	8571
151	38322	9993
151	38371	9993
151	38249	8571
151	36852	9993
151	39625	8571
151	38784	9993
151	39859	8571
151	38786	9993
151	40521	8571
151	30910	9993
151	148302	8571
151	38792	9993
151	148329	8571
152	39153	7947
152	32990	4049
152	39575	7947
152	94184	4049
152	46459	7947
152	15456	4049
152	26606	7947
152	15913	7947
152	15662	7947
152	37085	4049
152	178291	7947
152	37972	4049
152	45413	7947
152	148292	4049
152	148289	4049
152	149367	7947
152	17703	4049
152	116788	7947
152	94281	4049
153	37900	10000
153	38341	10001
153	37886	10000
153	38349	10001
153	37903	10000
153	21834	10001
153	37889	10000
153	37953	10001
153	94030	10000
153	38339	10001
153	37902	10000
153	30404	10001
153	38231	10000
153	38353	10001
153	131530	10000
153	38348	10001
153	130027	10000
153	37893	10000
153	37025	10001
153	37981	10000
153	17883	10001
154	36835	9984
154	37990	8342
154	37047	9984
154	21812	8342
154	37021	9984
154	11736	8342
154	37051	9984
154	37858	8342
154	104386	9984
154	38366	8342
154	32863	9984
154	37983	8342
154	37957	9984
154	39578	8342
154	37909	9984
154	38336	8342
154	38357	9984
154	52280	8342
154	37065	9984
154	27423	8342
154	78462	9984
154	38440	8342
155	38252	9998
155	39156	9998
155	30692	9985
155	39151	9998
155	38800	9985
155	68064	9998
155	37861	9985
155	166554	9998
155	47411	9985
155	35412	9985
155	46890	9998
155	39631	9985
155	39158	9998
155	39591	9985
155	119117	9985
155	39145	9998
155	25957	9985
155	38947	9998
155	38369	9985
156	34480	8635
156	37900	10000
156	38388	8635
156	37886	10000
156	26458	8635
156	37903	10000
156	13423	8635
156	37889	10000
156	38389	8635
156	94030	10000
156	30949	8635
156	37893	10000
156	38393	8635
156	37981	10000
156	38253	8635
156	131531	10000
156	38383	8635
156	130027	10000
156	38778	8635
156	38231	10000
156	37069	8635
156	131530	10000
157	33676	8571
157	30934	9994
157	67940	8571
157	38292	9994
157	38249	8571
157	11569	9994
157	37971	8571
157	14642	9994
157	33660	8571
157	38273	9994
157	39859	8571
157	12099	9994
157	40521	8571
157	38290	9994
157	148302	8571
157	95609	9994
157	149279	8571
157	38257	9994
157	148329	8571
157	121639	9994
158	37937	9987
158	39153	7947
158	38785	9987
158	39575	7947
158	38293	9987
158	46459	7947
158	148314	9987
158	26606	7947
158	148313	9987
158	45413	7947
158	32690	9987
158	42153	9987
158	15662	7947
158	9307	9987
158	131406	7947
158	38794	9987
158	178291	7947
158	37202	9987
158	149367	7947
158	38782	9987
158	116788	7947
159	38341	10001
159	38327	8203
159	38349	10001
159	36393	8203
159	21834	10001
159	67950	8203
159	37953	10001
159	67941	8203
159	47410	10001
159	67958	8203
159	30404	10001
159	37112	8203
159	38348	10001
159	67959	8203
159	148286	8203
159	39848	10001
159	164352	8203
159	17883	10001
159	67898	8203
159	50160	10001
159	33657	8203
160	38318	9999
160	39890	9996
160	38247	9999
160	16387	9999
160	38788	9996
160	94288	9999
160	39878	9996
160	94284	9999
160	26235	9996
160	45832	9999
160	26669	9999
160	38312	9996
160	33671	9999
160	163670	9999
160	94289	9996
160	37945	9999
160	33622	9999
161	104378	9991
161	32990	4049
161	38248	9991
161	35580	4049
161	36841	9991
161	37972	4049
161	38255	9991
161	37976	4049
161	148289	4049
161	33662	9991
161	37085	4049
161	38233	9991
161	148292	4049
161	104382	9991
161	38229	9991
161	94184	4049
161	12574	9991
161	9144	4049
161	46335	9991
161	97368	4049
162	95597	9986
162	38391	9993
162	36849	9993
162	37571	9986
162	36845	9993
162	94462	9986
162	38322	9993
162	38246	9986
162	30910	9993
162	38423	9986
162	36852	9993
162	38435	9986
162	38784	9993
162	131409	9986
162	38786	9993
162	38419	9986
162	38371	9993
162	164732	9986
162	41106	9993
163	38327	8203
163	34480	8635
163	67950	8203
163	38388	8635
163	67958	8203
163	38389	8635
163	38801	8203
163	31316	8635
163	67898	8203
163	164694	8635
163	37112	8203
163	30949	8635
163	67959	8203
163	38378	8635
163	148286	8203
163	38383	8635
163	164352	8203
163	38393	8635
163	33657	8203
163	38253	8635
163	26502	8203
163	37069	8635
164	37937	9987
164	30692	9985
164	38785	9987
164	38800	9985
164	38293	9987
164	37861	9985
164	104411	9987
164	47411	9985
164	148313	9987
164	35412	9985
164	37202	9987
164	26224	9985
164	9307	9987
164	39591	9985
164	43158	9987
164	37262	9985
164	32690	9987
164	25957	9985
164	42153	9987
164	38369	9985
164	38782	9987
165	38391	9993
165	38252	9998
165	42812	9993
165	39156	9998
165	36849	9993
165	39151	9998
165	68064	9998
165	38322	9993
165	166554	9998
165	38371	9993
165	30910	9993
165	46890	9998
165	36852	9993
165	39158	9998
165	38784	9993
165	38786	9993
165	39145	9998
165	34334	9993
165	119118	9998
166	30934	9994
166	95597	9986
166	38292	9994
166	11569	9994
166	37571	9986
166	14642	9994
166	94462	9986
166	38273	9994
166	131404	9986
166	12099	9994
166	38290	9994
166	38435	9986
166	131409	9986
166	38257	9994
166	164732	9986
166	38246	9986
166	69629	9994
166	38419	9986
167	39153	7947
167	36835	9984
167	39575	7947
167	37047	9984
167	46459	7947
167	37021	9984
167	131406	7947
167	37051	9984
167	67896	7947
167	104386	9984
167	26606	7947
167	32863	9984
167	15662	7947
167	37957	9984
167	178291	7947
167	37909	9984
167	38357	9984
167	149367	7947
167	37065	9984
167	116788	7947
167	78462	9984
168	37990	8342
168	104378	9991
168	38342	8342
168	36841	9991
168	39578	8342
168	38337	9991
168	21812	8342
168	38255	9991
168	37858	8342
168	37983	8342
168	33662	9991
168	38336	8342
168	37044	9991
168	38366	8342
168	32760	9991
168	52280	8342
168	38229	9991
168	27423	8342
168	12574	9991
168	38440	8342
168	46335	9991
169	37900	10000
169	38318	9999
169	37886	10000
169	38247	9999
169	37100	10000
169	16387	9999
169	37903	10000
169	94288	9999
169	37889	10000
169	94284	9999
169	37893	10000
169	45832	9999
169	37981	10000
169	26669	9999
169	131531	10000
169	33671	9999
169	131530	10000
169	163670	9999
169	38231	10000
169	37945	9999
169	130027	10000
169	33622	9999
170	148308	9996
170	33676	8571
170	6803	8571
170	38788	9996
170	39625	8571
170	38312	9996
170	148302	8571
170	39878	9996
170	67939	8571
170	67940	8571
170	39859	8571
170	26916	9996
170	26235	9996
170	40521	8571
170	148960	9996
170	131486	8571
170	94289	9996
171	32990	4049
171	38341	10001
171	148292	4049
171	38348	10001
171	37976	4049
171	148289	4049
171	38339	10001
171	94184	4049
171	47410	10001
171	37085	4049
171	30404	10001
171	37972	4049
171	38353	10001
171	38410	4049
171	21834	10001
171	39848	10001
171	9144	4049
171	17883	10001
171	97368	4049
171	50160	10001
172	33676	8571
172	37990	8342
172	67940	8571
172	39578	8342
172	6803	8571
172	21812	8342
172	39859	8571
172	11736	8342
172	148302	8571
172	37858	8342
172	39625	8571
172	37983	8342
172	27364	8342
172	40521	8571
172	38336	8342
172	148327	8571
172	38366	8342
172	131486	8571
172	27423	8342
172	148329	8571
172	38440	8342
173	95597	9986
173	30692	9985
173	38800	9985
173	37571	9986
173	37861	9985
173	94462	9986
173	47411	9985
173	38246	9986
173	37262	9985
173	38423	9986
173	35412	9985
173	38435	9986
173	39631	9985
173	131409	9986
173	39591	9985
173	38419	9986
173	25957	9985
173	164732	9986
173	38369	9985
174	104378	9991
174	37900	10000
174	38248	9991
174	37887	10000
174	36841	9991
174	37886	10000
174	38255	9991
174	37903	10000
174	104382	9991
174	94030	10000
174	33662	9991
174	37981	10000
174	37044	9991
174	131531	10000
174	32760	9991
174	131530	10000
174	38229	9991
174	130027	10000
174	39875	9991
174	38231	10000
174	46335	9991
174	75500	10000
175	38252	9998
175	30934	9994
175	39156	9998
175	38292	9994
175	39151	9998
175	14642	9994
175	68064	9998
175	166554	9998
175	38273	9994
175	12099	9994
175	39145	9998
175	38945	9994
175	46890	9998
175	38290	9994
175	38947	9998
175	38257	9994
175	39158	9998
175	69629	9994
176	38341	10001
176	39153	7947
176	38349	10001
176	39575	7947
176	21834	10001
176	46459	7947
176	67896	7947
176	38339	10001
176	131406	7947
176	38353	10001
176	38348	10001
176	26606	7947
176	15662	7947
176	47410	10001
176	178291	7947
176	17883	10001
176	149367	7947
176	50160	10001
176	116788	7947
177	38318	9999
177	38327	8203
177	38247	9999
177	38801	8203
177	16387	9999
177	67950	8203
177	94288	9999
177	67958	8203
177	94284	9999
177	164352	8203
177	26669	9999
177	67898	8203
177	33671	9999
177	37112	8203
177	163670	9999
177	67959	8203
177	148336	9999
177	148286	8203
177	37945	9999
177	33657	8203
177	33622	9999
177	26502	8203
178	36835	9984
178	12381	9996
178	37047	9984
178	37909	9984
178	38788	9996
178	37021	9984
178	38312	9996
178	37051	9984
178	39878	9996
178	27110	9984
178	37846	9996
178	37957	9984
178	26916	9996
178	104386	9984
178	26235	9996
178	38357	9984
178	94289	9996
178	38251	9984
178	78462	9984
179	37937	9987
179	32990	4049
179	38293	9987
179	37972	4049
179	104411	9987
179	38410	4049
179	148314	9987
179	37976	4049
179	148313	9987
179	148289	4049
179	42153	9987
179	37085	4049
179	9307	9987
179	148292	4049
179	43158	9987
179	12245	9987
179	94184	4049
179	32690	9987
179	9144	4049
179	37202	9987
179	97368	4049
180	34480	8635
180	38391	9993
180	33620	8635
180	36849	9993
180	38388	8635
180	13423	8635
180	36845	9993
180	38389	8635
180	38322	9993
180	30949	8635
180	30910	9993
180	38393	8635
180	36852	9993
180	36863	8635
180	38784	9993
180	38253	8635
180	38786	9993
180	10404	8635
180	38371	9993
180	37069	8635
180	34334	9993
181	30934	9994
181	34480	8635
181	38292	9994
181	33620	8635
181	11569	9994
181	38388	8635
181	14642	9994
181	13423	8635
181	38273	9994
181	38389	8635
181	12099	9994
181	38798	8635
181	38290	9994
181	38383	8635
181	95609	9994
181	38393	8635
181	38257	9994
181	164694	8635
181	38253	8635
181	69629	9994
181	37069	8635
182	148308	9996
182	38252	9998
182	38788	9996
182	39156	9998
182	37846	9996
182	31810	9998
182	39878	9996
182	68064	9998
182	94289	9996
182	166554	9998
182	40008	9998
182	39158	9998
182	26916	9996
182	38947	9998
182	39145	9998
182	46890	9998
183	37990	8342
183	95597	9986
183	21812	8342
183	11736	8342
183	37858	8342
183	37571	9986
183	38366	8342
183	94462	9986
183	39578	8342
183	38246	9986
183	37979	8342
183	38435	9986
183	27364	8342
183	131409	9986
183	38336	8342
183	164732	9986
183	27423	8342
183	38423	9986
183	38440	8342
183	38419	9986
184	37900	10000
184	36835	9984
184	37887	10000
184	37047	9984
184	37886	10000
184	37909	9984
184	37903	10000
184	37021	9984
184	94030	10000
184	37051	9984
184	37981	10000
184	38357	9984
184	131531	10000
184	37957	9984
184	131530	10000
184	104386	9984
184	130027	10000
184	78462	9984
184	75500	10000
184	37065	9984
184	12692	9984
185	39153	7947
185	104378	9991
185	34031	7947
185	36841	9991
185	46459	7947
185	38255	9991
185	26606	7947
185	67896	7947
185	104382	9991
185	15662	7947
185	37044	9991
185	178291	7947
185	38337	9991
185	45413	7947
185	32760	9991
185	38229	9991
185	149367	7947
185	33662	9991
185	116788	7947
185	12574	9991
186	32990	4049
186	38318	9999
186	38410	4049
186	46580	9999
186	37976	4049
186	16387	9999
186	15456	4049
186	94288	9999
186	94284	9999
186	37085	4049
186	45832	9999
186	37972	4049
186	33671	9999
186	148292	4049
186	163670	9999
186	94184	4049
186	148336	9999
186	9144	4049
186	37945	9999
186	17703	4049
186	33622	9999
187	39573	8203
187	33676	8571
187	38801	8203
187	6803	8571
187	67950	8203
187	39625	8571
187	37112	8203
187	46231	8571
187	67941	8203
187	67939	8571
187	67898	8203
187	67940	8571
187	38791	8203
187	38249	8571
187	39859	8571
187	148286	8203
187	17276	8203
187	148329	8571
187	33657	8203
188	37937	9987
188	38341	10001
188	38785	9987
188	38349	10001
188	38293	9987
188	21834	10001
188	43158	9987
188	148314	9987
188	38339	10001
188	32690	9987
188	38353	10001
188	38782	9987
188	38348	10001
188	104411	9987
188	20445	9987
188	47410	10001
188	42153	9987
188	17883	10001
188	12245	9987
188	50160	10001
189	38797	9985
189	38391	9993
189	30692	9985
189	42812	9993
189	37861	9985
189	36849	9993
189	119117	9985
189	47411	9985
189	38322	9993
189	35412	9985
189	38371	9993
189	38800	9985
189	30910	9993
189	39631	9985
189	38784	9993
189	39591	9985
189	38786	9993
189	37262	9985
189	41021	9993
189	38369	9985
189	38792	9993
190	34480	8635
190	37990	8342
190	33620	8635
190	39578	8342
190	38388	8635
190	21812	8342
190	13423	8635
190	11736	8342
190	38389	8635
190	37858	8342
190	38798	8635
190	37983	8342
190	30949	8635
190	27364	8342
190	38383	8635
190	38336	8342
190	38393	8635
190	38366	8342
190	38253	8635
190	27423	8342
190	37069	8635
190	38440	8342
191	38318	9999
191	37937	9987
191	46580	9999
191	38789	9987
191	16387	9999
191	38293	9987
191	94288	9999
191	104411	9987
191	94284	9999
191	148314	9987
191	26669	9999
191	38782	9987
191	33671	9999
191	43158	9987
191	163670	9999
191	20445	9987
191	148336	9999
191	32690	9987
191	37945	9999
191	37202	9987
191	33622	9999
191	38794	9987
192	38391	9993
192	37900	10000
192	42812	9993
192	37100	10000
192	36849	9993
192	37903	10000
192	37889	10000
192	38322	9993
192	94030	10000
192	30910	9993
192	37886	10000
192	41106	9993
192	37981	10000
192	38786	9993
192	131531	10000
192	94308	9993
192	131530	10000
192	41021	9993
192	38231	10000
192	38792	9993
192	75500	10000
193	38797	9985
193	30934	9994
193	30692	9985
193	38292	9994
193	38800	9985
193	11569	9994
193	37861	9985
193	14642	9994
193	119117	9985
193	38273	9994
193	39631	9985
193	12099	9994
193	39591	9985
193	95609	9994
193	47411	9985
193	38257	9994
193	148335	9985
193	38945	9994
193	37262	9985
193	38369	9985
193	69629	9994
194	33676	8571
194	39153	7947
194	6803	8571
194	46459	7947
194	40521	8571
194	26606	7947
194	46231	8571
194	67939	8571
194	45413	7947
194	67940	8571
194	34031	7947
194	39625	8571
194	15662	7947
194	178291	7947
194	149279	8571
194	67896	7947
194	148327	8571
194	149367	7947
194	148329	8571
194	116788	7947
195	38252	9998
195	39573	8203
195	39156	9998
195	38801	8203
195	40008	9998
195	67950	8203
195	67941	8203
195	166554	9998
195	67958	8203
195	38791	8203
195	39145	9998
195	37112	8203
195	46890	9998
195	39158	9998
195	67959	8203
195	31810	9998
195	17276	8203
195	38947	9998
195	26502	8203
196	95597	9986
196	148308	9996
196	38788	9996
196	38246	9986
196	38312	9996
196	94462	9986
196	39878	9996
196	38423	9986
196	38435	9986
196	37846	9996
196	131409	9986
196	26916	9996
196	167619	9986
196	94289	9996
196	38419	9986
196	104389	9986
197	36835	9984
197	148297	4049
197	37047	9984
197	35580	4049
197	37021	9984
197	148289	4049
197	37051	9984
197	38186	9984
197	32863	9984
197	37085	4049
197	37957	9984
197	148292	4049
197	37909	9984
197	104386	9984
197	12692	9984
197	9144	4049
197	38357	9984
197	39157	4049
208	38341	10001
208	34480	8635
208	38349	10001
208	33620	8635
208	37953	10001
208	38388	8635
208	38339	10001
208	13423	8635
208	38389	8635
208	38343	10001
208	38798	8635
208	38353	10001
208	30949	8635
208	21834	10001
208	38383	8635
208	47410	10001
208	38393	8635
208	17883	10001
208	38253	8635
208	50160	10001
208	37069	8635
209	148308	9996
209	38797	9985
209	38788	9996
209	30692	9985
209	38312	9996
209	38800	9985
209	37846	9996
209	37861	9985
209	39878	9996
209	47411	9985
209	35412	9985
209	26916	9996
209	39631	9985
209	39591	9985
209	94289	9996
209	148335	9985
209	37262	9985
209	148315	9985
210	37990	8342
210	38252	9998
210	38342	8342
210	39156	9998
210	11736	8342
210	46890	9998
210	38441	8342
210	38947	9998
210	37858	8342
210	166554	9998
210	37979	8342
210	38336	8342
210	40008	9998
210	38366	8342
210	39158	9998
210	27423	8342
210	38440	8342
210	39145	9998
210	34025	8342
210	119118	9998
211	32990	4049
211	95597	9986
211	35580	4049
211	37976	4049
211	148289	4049
211	37571	9986
211	94462	9986
211	37085	4049
211	38246	9986
211	37972	4049
211	38423	9986
211	148292	4049
211	38435	9986
211	104389	9986
211	9144	4049
211	38920	9986
211	39157	4049
211	131409	9986
212	39573	8203
212	36835	9984
212	36393	8203
212	37021	9984
212	67950	8203
212	37051	9984
212	67941	8203
212	37038	9984
212	67958	8203
212	38186	9984
212	38801	8203
212	27110	9984
212	67898	8203
212	37957	9984
212	104386	9984
212	38251	9984
212	33657	8203
212	37065	9984
212	148286	8203
212	78462	9984
213	170323	9987
213	37854	9991
213	38789	9987
213	36841	9991
213	38293	9987
213	38337	9991
213	104411	9987
213	38255	9991
213	148314	9987
213	9307	9987
213	33662	9991
213	39498	9987
213	37044	9991
213	20445	9987
213	32760	9991
213	32690	9987
213	39875	9991
213	37202	9987
213	38229	9991
213	38794	9987
213	12574	9991
214	39153	7947
214	38318	9999
214	39575	7947
214	46580	9999
214	34031	7947
214	38247	9999
214	26606	7947
214	16387	9999
214	94288	9999
214	26669	9999
214	15662	7947
214	33671	9999
214	178291	7947
214	163670	9999
214	45413	7947
214	148336	9999
214	33622	9999
214	149367	7947
214	32637	9999
215	33676	8571
215	37100	10000
215	6803	8571
215	37903	10000
215	37889	10000
215	40521	8571
215	94030	10000
215	67939	8571
215	37886	10000
215	148302	8571
215	131531	10000
215	149279	8571
215	131530	10000
215	148327	8571
215	130027	10000
215	131486	8571
215	40433	10000
215	38231	10000
216	30934	9994
216	38391	9993
216	38292	9994
216	42812	9993
216	11569	9994
216	36849	9993
216	14642	9994
216	38273	9994
216	38322	9993
216	12099	9994
216	38371	9993
216	38290	9994
216	30910	9993
216	38784	9993
216	95609	9994
216	94308	9993
216	38945	9994
216	41021	9993
216	69629	9994
216	38786	9993
217	38391	9993
217	37990	8342
217	42812	9993
217	37988	8342
217	36849	9993
217	38342	8342
217	37858	8342
217	38322	9993
217	39578	8342
217	38371	9993
217	37979	8342
217	30910	9993
217	38336	8342
217	38784	9993
217	38366	8342
217	38786	9993
217	27423	8342
217	41106	9993
217	38440	8342
217	41021	9993
217	34025	8342
218	36835	9984
218	37937	9987
218	37047	9984
218	38789	9987
218	37051	9984
218	38293	9987
218	37038	9984
218	104411	9987
218	38186	9984
218	148314	9987
218	37957	9984
218	9307	9987
218	37909	9984
218	39498	9987
218	104386	9984
218	43158	9987
218	38357	9984
218	20445	9987
218	37065	9984
218	32690	9987
218	12692	9984
218	37202	9987
219	95597	9986
219	37900	10000
219	37100	10000
219	37571	9986
219	37903	10000
219	94462	9986
219	37889	10000
219	131409	9986
219	94030	10000
219	38246	9986
219	37886	10000
219	38423	9986
219	37981	10000
219	38435	9986
219	131531	10000
219	167619	9986
219	130027	10000
219	164732	9986
219	38231	10000
219	38920	9986
219	75500	10000
220	38318	9999
220	104378	9991
220	46580	9999
220	38337	9991
220	16387	9999
220	38255	9991
220	94288	9999
220	12473	9991
220	94284	9999
220	104382	9991
220	45832	9999
220	33662	9991
220	26669	9999
220	38233	9991
220	33671	9999
220	32760	9991
220	163670	9999
220	38229	9991
220	33622	9999
220	12574	9991
220	32637	9999
220	46335	9991
221	34480	8635
221	39153	7947
221	33620	8635
221	34031	7947
221	38388	8635
221	26606	7947
221	13423	8635
221	38389	8635
221	45413	7947
221	38798	8635
221	30949	8635
221	178291	7947
221	38383	8635
221	67896	7947
221	38393	8635
221	38253	8635
221	37069	8635
221	149367	7947
222	38797	9985
222	39573	8203
222	39580	9985
222	67950	8203
222	38800	9985
222	6800	8203
222	37861	9985
222	67958	8203
222	47411	9985
222	67898	8203
222	35412	9985
222	37112	8203
222	39631	9985
222	39591	9985
222	67959	8203
222	148335	9985
222	148286	8203
222	37262	9985
222	33657	8203
222	148315	9985
222	26502	8203
223	30934	9994
223	148308	9996
223	38292	9994
223	11569	9994
223	38788	9996
223	14642	9994
223	38312	9996
223	38273	9994
223	39878	9996
223	12099	9994
223	38290	9994
223	95609	9994
223	37846	9996
223	38945	9994
223	26916	9996
223	69629	9994
223	94289	9996
223	38285	9994
224	33676	8571
224	32990	4049
224	37971	8571
224	37976	4049
224	33660	8571
224	148289	4049
224	148302	8571
224	149279	8571
224	37085	4049
224	67940	8571
224	35580	4049
224	38249	8571
224	37972	4049
224	39625	8571
224	148292	4049
224	148326	8571
224	148327	8571
224	17703	4049
224	148329	8571
224	39157	4049
225	38341	10001
225	39156	9998
225	38349	10001
225	31810	9998
225	39848	10001
225	68064	9998
225	38343	10001
225	166554	9998
225	38339	10001
225	39145	9998
225	38353	10001
225	40008	9998
225	38348	10001
225	46890	9998
225	21834	10001
225	39158	9998
225	38947	9998
225	17883	10001
225	119118	9998
225	50160	10001
226	32990	4049
226	34480	8635
226	148292	4049
226	30949	8635
226	37976	4049
226	33620	8635
226	94184	4049
226	38388	8635
226	38393	8635
226	37085	4049
226	38798	8635
226	35580	4049
226	38383	8635
226	37972	4049
226	164694	8635
226	37069	8635
226	17703	4049
226	13423	8635
226	39157	4049
226	38253	8635
227	37900	10000
227	38797	9985
227	37886	10000
227	39580	9985
227	37100	10000
227	30692	9985
227	37903	10000
227	38800	9985
227	37889	10000
227	47411	9985
227	37981	10000
227	35412	9985
227	131531	10000
227	39631	9985
227	94030	10000
227	39591	9985
227	130027	10000
227	148335	9985
227	37902	10000
227	37262	9985
227	38231	10000
227	148315	9985
228	39153	7947
228	39575	7947
228	39156	9998
228	46459	7947
228	46881	9998
228	26606	7947
228	166554	9998
228	67896	7947
228	39145	9998
228	15662	7947
228	40008	9998
228	178291	7947
228	38947	9998
228	39158	9998
228	45413	7947
228	149367	7947
228	116788	7947
228	38320	9998
229	39573	8203
229	95597	9986
229	36393	8203
229	67950	8203
229	37571	9986
229	6800	8203
229	94462	9986
229	67958	8203
229	167619	9986
229	38801	8203
229	38246	9986
229	67898	8203
229	38423	9986
229	38791	8203
229	131409	9986
229	37112	8203
229	164732	9986
229	148286	8203
229	38435	9986
229	33657	8203
229	38920	9986
230	104378	9991
230	36835	9984
230	27838	9991
230	37047	9984
230	38337	9991
230	37051	9984
230	38255	9991
230	37038	9984
230	12473	9991
230	38186	9984
230	33662	9991
230	27110	9984
230	37044	9991
230	37957	9984
230	32760	9991
230	37909	9984
230	38229	9991
230	104386	9984
230	131394	9991
230	38251	9984
230	46335	9991
230	12692	9984
231	37990	8342
231	30934	9994
231	38342	8342
231	11569	9994
231	39578	8342
231	14642	9994
231	11736	8342
231	37858	8342
231	38273	9994
231	37979	8342
231	38945	9994
231	27364	8342
231	38290	9994
231	38336	8342
231	15425	9994
231	38366	8342
231	104404	9994
231	27423	8342
231	38285	9994
231	38440	8342
231	69629	9994
232	38341	10001
232	38318	9999
232	38349	10001
232	46580	9999
232	21834	10001
232	38247	9999
232	37953	10001
232	16387	9999
232	38339	10001
232	26669	9999
232	38343	10001
232	33671	9999
232	30404	10001
232	94284	9999
232	38353	10001
232	163670	9999
232	39848	10001
232	33622	9999
232	17883	10001
232	148336	9999
232	50160	10001
232	94288	9999
233	37937	9987
233	148325	8571
233	38789	9987
233	6803	8571
233	38293	9987
233	39625	8571
233	104411	9987
233	33660	8571
233	148314	9987
233	67939	8571
233	43158	9987
233	39859	8571
233	20445	9987
233	148302	8571
233	148313	9987
233	149279	8571
233	32690	9987
233	148327	8571
233	37202	9987
233	148329	8571
233	38794	9987
234	148308	9996
234	38391	9993
234	42812	9993
234	38788	9996
234	38312	9996
234	38322	9993
234	39878	9996
234	38371	9993
234	30910	9993
234	38784	9993
234	26916	9996
234	38786	9993
234	41106	9993
234	148960	9996
234	41021	9993
234	94289	9996
234	36849	9993
235	38797	9985
235	37990	8342
235	30692	9985
235	37988	8342
235	38800	9985
235	38342	8342
235	37861	9985
235	11736	8342
235	47411	9985
235	38441	8342
235	35412	9985
235	37979	8342
235	39631	9985
235	27364	8342
235	39591	9985
235	38336	8342
235	148335	9985
235	38366	8342
235	37262	9985
235	38440	8342
235	38369	9985
235	34025	8342
236	95597	9986
236	37937	9987
236	38789	9987
236	37571	9986
236	38785	9987
236	94462	9986
236	148314	9987
236	167619	9986
236	148313	9987
236	38246	9986
236	9307	9987
236	38423	9986
236	43158	9987
236	38435	9986
236	20445	9987
236	131409	9986
236	32690	9987
236	38920	9986
236	42153	9987
236	164732	9986
236	38782	9987
237	148308	9996
237	37900	10000
237	38788	9996
237	37886	10000
237	38312	9996
237	37100	10000
237	39878	9996
237	37889	10000
237	131532	10000
237	37893	10000
237	37902	10000
237	37981	10000
237	26916	9996
237	37903	10000
237	94289	9996
237	131531	10000
237	148960	9996
237	38231	10000
238	148325	8571
238	104378	9991
238	6803	8571
238	27838	9991
238	67939	8571
238	38337	9991
238	39625	8571
238	12473	9991
238	39859	8571
238	41109	9991
238	40521	8571
238	33662	9991
238	148302	8571
238	37044	9991
238	149279	8571
238	38233	9991
238	148327	8571
238	38229	9991
238	12574	9991
238	33660	8571
238	46335	9991
239	30934	9994
239	39153	7947
239	38292	9994
239	39575	7947
239	14642	9994
239	46459	7947
239	67896	7947
239	38273	9994
239	15662	7947
239	38945	9994
239	38290	9994
239	45413	7947
239	95609	9994
239	149367	7947
239	69629	9994
239	116788	7947
239	38285	9994
239	26606	7947
239	104404	9994
239	178291	7947
240	38391	9993
240	39573	8203
240	42812	9993
240	67950	8203
240	6800	8203
240	38322	9993
240	38791	8203
240	94308	9993
240	67941	8203
240	30910	9993
240	38801	8203
240	38784	9993
240	36393	8203
240	38786	9993
240	67898	8203
240	41106	9993
240	41021	9993
240	33657	8203
240	37856	9993
240	37112	8203
241	34480	8635
241	38318	9999
241	33620	8635
241	46580	9999
241	38388	8635
241	37945	9999
241	13423	8635
241	38247	9999
241	38389	8635
241	94284	9999
241	38798	8635
241	45832	9999
241	38378	8635
241	26669	9999
241	38383	8635
241	33671	9999
241	38393	8635
241	163670	9999
241	106013	8635
241	148336	9999
241	37069	8635
241	33622	9999
242	148311	9998
242	32990	4049
242	39156	9998
242	37976	4049
242	148289	4049
242	94184	4049
242	166554	9998
242	15456	4049
242	39145	9998
242	37085	4049
242	46890	9998
242	9144	4049
242	39158	9998
242	94281	4049
242	46881	9998
242	38320	9998
242	39157	4049
242	38947	9998
242	97368	4049
243	131403	9984
243	38341	10001
243	37047	9984
243	38349	10001
243	37051	9984
243	38339	10001
243	37038	9984
243	38343	10001
243	38186	9984
243	38353	10001
243	37957	9984
243	21834	10001
243	37909	9984
243	39848	10001
243	104386	9984
243	17883	10001
243	38357	9984
243	50160	10001
243	37065	9984
243	37953	10001
243	78462	9984
243	30404	10001
244	37937	9987
244	34480	8635
244	38789	9987
244	33620	8635
244	38785	9987
244	38388	8635
244	38293	9987
244	13423	8635
244	148313	9987
244	38389	8635
244	9307	9987
244	30949	8635
244	43158	9987
244	38393	8635
244	104411	9987
244	38253	8635
244	32690	9987
244	38798	8635
244	38780	9987
244	38383	8635
244	42153	9987
244	37069	8635
245	104378	9991
245	38797	9985
245	38337	9991
245	30692	9985
245	38255	9991
245	38800	9985
245	12473	9991
245	37861	9985
245	41109	9991
245	156551	9985
245	33662	9991
245	35412	9985
245	37044	9991
245	26224	9985
245	32760	9991
245	39631	9985
245	38229	9991
245	39591	9985
245	12574	9991
245	37262	9985
245	46335	9991
245	38369	9985
246	37900	10000
246	148311	9998
246	37100	10000
246	39156	9998
246	37903	10000
246	40008	9998
246	37889	10000
246	94030	10000
246	166554	9998
246	37886	10000
246	37981	10000
246	31810	9998
246	131531	10000
246	39145	9998
246	130027	10000
246	38947	9998
246	37902	10000
246	38320	9998
246	38231	10000
246	46881	9998
247	39153	7947
247	95597	9986
247	39575	7947
247	46459	7947
247	15913	7947
247	37571	9986
247	167619	9986
247	15662	7947
247	38246	9986
247	178291	7947
247	38423	9986
247	67896	7947
247	38435	9986
247	45413	7947
247	164732	9986
247	149367	7947
247	38920	9986
247	116788	7947
247	104389	9986
248	38318	9999
248	131403	9984
248	46580	9999
248	37047	9984
248	37947	9999
248	37021	9984
248	38247	9999
248	37051	9984
248	94288	9999
248	37038	9984
248	37957	9984
248	45832	9999
248	37909	9984
248	21744	9999
248	104386	9984
248	131411	9999
248	38357	9984
248	37945	9999
248	38251	9984
248	32637	9999
248	78462	9984
249	39573	8203
249	30934	9994
249	6800	8203
249	38292	9994
249	67941	8203
249	11569	9994
249	67958	8203
249	14642	9994
249	38273	9994
249	38801	8203
249	38290	9994
249	36393	8203
249	67898	8203
249	95609	9994
249	104404	9994
249	33657	8203
249	26502	8203
249	69629	9994
250	37990	8342
250	39890	9996
250	38342	8342
250	11736	8342
250	26235	9996
250	38441	8342
250	39896	9996
250	37858	8342
250	37979	8342
250	37846	9996
250	27364	8342
250	26916	9996
250	34025	8342
250	38336	8342
250	166679	9996
250	27423	8342
250	38440	8342
250	148960	9996
251	38341	10001
251	148325	8571
251	38349	10001
251	148302	8571
251	37953	10001
251	46231	8571
251	38339	10001
251	67939	8571
251	149279	8571
251	38343	10001
251	38249	8571
251	30404	10001
251	39859	8571
251	38353	10001
251	40521	8571
251	39848	10001
251	148327	8571
251	17883	10001
251	78902	8571
251	50160	10001
252	148297	4049
252	131408	9993
252	37976	4049
252	42812	9993
252	148289	4049
252	36849	9993
252	15456	4049
252	38322	9993
252	37085	4049
252	30910	9993
252	148292	4049
252	38786	9993
252	94281	4049
252	94308	9993
252	9144	4049
252	39157	4049
252	41106	9993
252	37856	9993
307	38797	9985
307	37868	9997
307	39580	9985
307	33595	9997
307	38800	9985
307	38347	9997
307	37861	9985
307	3329	9997
307	47411	9985
307	149150	9997
307	35412	9985
307	38354	9997
307	39631	9985
307	37866	9997
307	39591	9985
307	36836	9997
307	37262	9985
307	25957	9985
307	5016	9997
307	38369	9985
307	45490	9997
308	40014	9986
308	37990	8342
308	11736	8342
308	37571	9986
308	37858	8342
308	38423	9986
308	42594	8342
308	46666	9986
308	37963	8342
308	38439	9986
308	37983	8342
308	131409	9986
308	37979	8342
308	114716	9986
308	38336	8342
308	25636	9986
308	38366	8342
308	38920	9986
308	52280	8342
308	164732	9986
308	38440	8342
309	36835	9984
309	104378	9991
309	38342	9984
309	38337	9991
309	37047	9984
309	38255	9991
309	37021	9984
309	12473	9991
309	37051	9984
309	41109	9991
309	37957	9984
309	33662	9991
309	37909	9984
309	37044	9991
309	104386	9984
309	26916	9991
309	78462	9984
309	37065	9991
309	38251	9984
309	12574	9991
309	38357	9984
309	46335	9991
310	30934	9994
310	37900	10000
310	38292	9994
310	37100	10000
310	39594	9994
310	37903	10000
310	25465	9994
310	37889	10000
310	38273	9994
310	94030	10000
310	12099	9994
310	37902	10000
310	38945	9994
310	37886	10000
310	95609	9994
310	37981	10000
310	15662	9994
310	131531	10000
310	30485	9994
310	75500	10000
310	104404	9994
310	130027	10000
311	37971	8571
311	38391	8635
311	37887	8571
311	33620	8635
311	6803	8571
311	38388	8635
311	16387	8571
311	13423	8635
311	67939	8571
311	38389	8635
311	67940	8571
311	38378	8635
311	38249	8571
311	38383	8635
311	39859	8571
311	38393	8635
311	40521	8571
311	38253	8635
311	39772	8571
311	37069	8635
311	78902	8571
311	46552	8635
312	38327	8203
312	38341	10001
312	38801	8203
312	38349	10001
312	67950	8203
312	37953	10001
312	6800	8203
312	38339	10001
312	67941	8203
312	67896	10001
312	67898	8203
312	38343	10001
312	37112	8203
312	30404	10001
312	178291	8203
312	38332	10001
312	67952	8203
312	17276	8203
312	17883	10001
312	39389	8203
312	47410	10001
313	38318	9999
313	13131	9993
313	36849	9993
313	38247	9999
313	36845	9993
313	94288	9999
313	38322	9993
313	94284	9999
313	38371	9993
313	45832	9999
313	30910	9993
313	26669	9999
313	38784	9993
313	33671	9999
313	36868	9993
313	148336	9999
313	38786	9993
313	37945	9999
313	33622	9993
313	24037	9999
313	34334	9993
314	37990	8342
314	38391	8635
314	36832	8342
314	33620	8635
314	21812	8342
314	38388	8635
314	11736	8342
314	38389	8635
314	95614	8342
314	38253	8635
314	39578	8342
314	38378	8635
314	38336	8342
314	38383	8635
314	38366	8342
314	38393	8635
314	163670	8342
314	106013	8635
314	27423	8342
314	37069	8635
314	38440	8342
314	12692	8635
315	38797	9985
315	37937	9987
315	39580	9985
315	38785	9987
315	37861	9985
315	38293	9987
315	47411	9985
315	94462	9987
315	129462	9985
315	148313	9987
315	37262	9985
315	32863	9987
315	35412	9985
315	38435	9987
315	25957	9985
315	148335	9985
315	43158	9987
315	156551	9985
315	148314	9987
315	38369	9985
315	42153	9987
316	37868	9997
316	37900	10000
316	3329	9997
316	37886	10000
316	178486	9997
316	37903	10000
316	104415	9997
316	37889	10000
316	149150	9997
316	94030	10000
316	38354	9997
316	37893	10000
316	37866	9997
316	37981	10000
316	131531	10000
316	93054	9997
316	38231	10000
316	5016	9997
316	75500	10000
316	104377	10000
317	40014	9986
317	37971	8571
317	37887	8571
317	38417	9986
317	6803	8571
317	37571	9986
317	38441	8571
317	131404	8571
317	38423	9986
317	38249	8571
317	39145	9986
317	38257	8571
317	38439	9986
317	40521	8571
317	40520	9986
317	149279	8571
317	131409	9986
317	39772	8571
317	38920	9986
317	78902	8571
318	39573	8203
318	38289	9994
318	67950	8203
318	38292	9994
318	6800	8203
318	39594	9994
318	38791	8203
318	25465	9994
318	164352	8203
318	38273	9994
318	67898	8203
318	38945	9994
318	37112	8203
318	38290	9994
318	38969	8203
318	95609	9994
318	178291	8203
318	15662	9994
318	154433	8203
318	34334	9994
318	17276	8203
318	69629	9994
319	38318	9999
319	131403	9984
319	38342	9984
319	38247	9999
319	37047	9984
319	94288	9999
319	38789	9984
319	69805	9999
319	38186	9984
319	26669	9999
319	27110	9984
319	46217	9999
319	37051	9984
319	23997	9999
319	38782	9984
319	94284	9999
319	104386	9984
319	148336	9999
319	78462	9984
319	37945	9999
319	38357	9984
320	13131	9993
320	38341	10001
320	37988	9993
320	38349	10001
320	36849	9993
320	43049	10001
320	36845	9993
320	21834	10001
320	38322	9993
320	67896	10001
320	38371	9993
320	37025	10001
320	36852	9993
320	38343	10001
320	38784	9993
320	179058	10001
320	38786	9993
320	182605	10001
320	33622	9993
320	39848	10001
320	178284	9993
320	25619	10001
321	37990	8342
321	104378	9991
321	36832	8342
321	37044	9991
321	39578	8342
321	38337	9991
321	21812	8342
321	12473	9991
321	11736	8342
321	104382	9991
321	37979	8342
321	33662	9991
321	38336	8342
321	26916	9991
321	38366	8342
321	32760	9991
321	163670	8342
321	37065	9991
321	38440	8342
321	12574	9991
321	75405	8342
321	46335	9991
322	38391	8635
322	40014	9986
322	33620	8635
322	38389	8635
322	39145	9986
322	38253	8635
322	39977	9986
322	69713	8635
322	46666	9986
322	38383	8635
322	38423	9986
322	38393	8635
322	38439	9986
322	106013	8635
322	104389	9986
322	12692	8635
322	25636	9986
322	37069	8635
322	38920	9986
322	181276	8635
322	38419	9986
323	37937	9987
323	39573	8203
323	38293	9987
323	67950	8203
323	94462	9987
323	6800	8203
323	148314	9987
323	39389	8203
323	148313	9987
323	164352	8203
323	32863	9987
323	67898	8203
323	38435	9987
323	37112	8203
323	39498	9987
323	38969	8203
323	43158	9987
323	178291	8203
323	42153	9987
323	17276	8203
323	38794	9987
323	148286	8203
324	37900	10000
324	13131	9993
324	37886	10000
324	37988	9993
324	37903	10000
324	36849	9993
324	37889	10000
324	36845	9993
324	94030	10000
324	38322	9993
324	37893	10000
324	38371	9993
324	37981	10000
324	36852	9993
324	131531	10000
324	38784	9993
324	38231	10000
324	38786	9993
324	75500	10000
324	33622	9993
324	104377	10000
324	178284	9993
325	30934	9994
325	131403	9984
325	11569	9994
325	37047	9984
325	14642	9994
325	37021	9984
325	25465	9994
325	38789	9984
325	38273	9994
325	37051	9984
325	38945	9994
325	38357	9984
325	38290	9994
325	37957	9984
325	15662	9994
325	38782	9984
325	30485	9994
325	104386	9984
325	69629	9994
325	78462	9984
325	104404	9994
325	38251	9984
326	37971	8571
326	38318	9999
326	39859	8571
326	38247	9999
326	38441	8571
326	94288	9999
326	16387	8571
326	69805	9999
326	131404	8571
326	94284	9999
326	38249	8571
326	26669	9999
326	38257	8571
326	40521	8571
326	33671	9999
326	149279	8571
326	148336	9999
326	78902	8571
326	37945	9999
326	148315	8571
326	24037	9999
327	38341	10001
327	38797	9985
327	38349	10001
327	25995	9985
327	39848	10001
327	37861	9985
327	38343	10001
327	47411	9985
327	37953	10001
327	129462	9985
327	21834	10001
327	32573	9985
327	38778	10001
327	37262	9985
327	67896	10001
327	35412	9985
327	182605	10001
327	26224	9985
327	37025	10001
327	148335	9985
327	25619	10001
327	38369	9985
328	148325	9985
328	37900	10000
328	25995	9985
328	37886	10000
328	39580	9985
328	37100	10000
328	129462	9985
328	37903	10000
328	47411	9985
328	37889	10000
328	32573	9985
328	37893	10000
328	37262	9985
328	37981	10000
328	37972	9985
328	131531	10000
328	148335	9985
328	38231	10000
328	156551	9985
328	75500	10000
328	166302	9985
328	104377	10000
329	37868	9997
329	104378	9991
329	33595	9997
329	27838	9991
329	38347	9997
329	38337	9991
329	3329	9997
329	12473	9991
329	149150	9997
329	33662	9991
329	38354	9997
329	37044	9991
329	38233	9991
329	68120	9997
329	104382	9991
329	5016	9997
329	12574	9991
329	45490	9997
329	46335	9991
329	166618	9991
330	40014	9986
330	38341	10001
330	38349	10001
330	38417	9986
330	39848	10001
330	37571	9986
330	38343	10001
330	46666	9986
330	37953	10001
330	38423	9986
330	21834	10001
330	185388	9986
330	38778	10001
330	38439	9986
330	67896	10001
330	104389	9986
330	182605	10001
330	40520	9986
330	37025	10001
330	38920	9986
330	25619	10001
331	131403	9984
331	37971	8571
331	37047	9984
331	39859	8571
331	37021	9984
331	38441	8571
331	38789	9984
331	16387	8571
331	104386	9984
331	131404	8571
331	38357	9984
331	38249	8571
331	27110	9984
331	38257	8571
331	37051	9984
331	40521	8571
331	78462	9984
331	149279	8571
331	38251	9984
331	78902	8571
331	89548	9984
331	148315	8571
332	30934	9994
332	37937	9987
332	11569	9994
332	38293	9987
332	14642	9994
332	94462	9987
332	25465	9994
332	148314	9987
332	38273	9994
332	148313	9987
332	38945	9994
332	38435	9987
332	38290	9994
332	15662	9994
332	39498	9987
332	30485	9994
332	43158	9987
332	69629	9994
332	32863	9987
332	104404	9994
332	163674	9987
333	39573	8203
333	38391	8635
333	67950	8203
333	38388	8635
333	6800	8203
333	38389	8635
333	39389	8203
333	69713	8635
333	164352	8203
333	38798	8635
333	67898	8203
333	38383	8635
333	37112	8203
333	38393	8635
333	38969	8203
333	38253	8635
333	178291	8203
333	106013	8635
333	148286	8203
333	46552	8635
333	17276	8203
333	181276	8635
334	38318	9999
334	37990	8342
334	36832	8342
334	38247	9999
334	21812	8342
334	94288	9999
334	11736	8342
334	69805	9999
334	95614	8342
334	94284	9999
334	39578	8342
334	23997	9999
334	37979	8342
334	148336	9999
334	38366	8342
334	148338	9999
334	163670	8342
334	173432	9999
334	75405	8342
334	37945	9999
334	52280	8342
335	37990	8342
335	37868	9997
335	36832	8342
335	38347	9997
335	21812	8342
335	3329	9997
335	11736	8342
335	104415	9997
335	95614	8342
335	149150	9997
335	39578	8342
335	38354	9997
335	38336	8342
335	37866	9997
335	38366	8342
335	52280	8342
335	68120	9997
335	38440	8342
335	163670	8342
336	38391	8635
336	38289	9994
336	38388	8635
336	38292	9994
336	38389	8635
336	11569	9994
336	38253	8635
336	14642	9994
336	69713	8635
336	38273	9994
336	33620	8635
336	12099	9994
336	38393	8635
336	38290	9994
336	106013	8635
336	15662	9994
336	12692	8635
336	104404	9994
336	46552	8635
336	34334	9994
336	181276	8635
336	166675	9994
337	37937	9987
337	131403	9984
337	38785	9987
337	38342	9984
337	38293	9987
337	37047	9984
337	37021	9984
337	94462	9987
337	37051	9984
337	32863	9987
337	37957	9984
337	39498	9987
337	37909	9984
337	43158	9987
337	104386	9984
337	148314	9987
337	38251	9984
337	38435	9987
337	78462	9984
337	38794	9987
337	89548	9984
338	37900	10000
338	40014	9986
338	37886	10000
338	37100	10000
338	38417	9986
338	37903	10000
338	37571	9986
338	37889	10000
338	46666	9986
338	37893	10000
338	38423	9986
338	37981	10000
338	39977	9986
338	131531	10000
338	38439	9986
338	75500	10000
338	104389	9986
338	104377	10000
338	185388	9986
338	38231	10000
338	38920	9986
339	104378	9991
339	13131	9993
339	37044	9991
339	37988	9993
339	38337	9991
339	36849	9993
339	12473	9991
339	38322	9993
339	104382	9991
339	38800	9993
339	33662	9991
339	38371	9993
339	26916	9991
339	38784	9993
339	38233	9991
339	36868	9993
339	166618	9991
339	38786	9993
339	12574	9991
339	33622	9993
339	46335	9991
339	178284	9993
340	37971	8571
340	39573	8203
340	39859	8571
340	67950	8203
340	38441	8571
340	6800	8203
340	131404	8571
340	39389	8203
340	149279	8571
340	164352	8203
340	38249	8571
340	67898	8203
340	38257	8571
340	37112	8203
340	40521	8571
340	38969	8203
340	95615	8571
340	178291	8203
340	78902	8571
340	148286	8203
340	148315	8571
340	17276	8203
341	38341	10001
341	38318	9999
341	38349	10001
341	38247	9999
341	37953	10001
341	94288	9999
341	166663	10001
341	69805	9999
341	94284	9999
341	21834	10001
341	33671	9999
341	38778	10001
341	23997	9999
341	67896	10001
341	182605	10001
341	148336	9999
341	37025	10001
341	37945	9999
341	25619	10001
341	173432	9999
342	38797	9985
342	37990	8342
342	37861	9985
342	21812	8342
342	47411	9985
342	11736	8342
342	129462	9985
342	42594	8342
342	159888	9985
342	37963	8342
342	39591	9985
342	39578	8342
342	119117	9985
342	37979	8342
342	148335	9985
342	38366	8342
342	156551	9985
342	163670	8342
342	37262	9985
342	38336	8342
342	38369	9985
342	75405	8342
343	37937	9987
343	38391	8635
343	38785	9987
343	33620	8635
343	38293	9987
343	38388	8635
343	38389	8635
343	94462	9987
343	69713	8635
343	32863	9987
343	38383	8635
343	38435	9987
343	38393	8635
343	39498	9987
343	38253	8635
343	43158	9987
343	106013	8635
343	38794	9987
343	37069	8635
343	148314	9987
343	46552	8635
344	40014	9986
344	104378	9991
344	27838	9991
344	39977	9986
344	38337	9991
344	38417	9986
344	12473	9991
344	37571	9986
344	41109	9991
344	46666	9986
344	104382	9991
344	38423	9986
344	26916	9991
344	39145	9986
344	32760	9991
344	185388	9986
344	37065	9991
344	104389	9986
344	12574	9991
344	38920	9986
344	46335	9991
345	131403	9984
345	38341	10001
345	38342	9984
345	38349	10001
345	37047	9984
345	38343	10001
345	37021	9984
345	43049	10001
345	37051	9984
345	37953	10001
345	38357	9984
345	21834	10001
345	27110	9984
345	38778	10001
345	37957	9984
345	67896	10001
345	38186	9984
345	182605	10001
345	104386	9984
345	37025	10001
345	38251	9984
345	25619	10001
346	38289	9994
346	37971	8571
346	38292	9994
346	38441	8571
346	39594	9994
346	131404	8571
346	11569	9994
346	38249	8571
346	14642	9994
346	39859	8571
346	12099	9994
346	38257	8571
346	38290	9994
346	40521	8571
346	15662	9994
346	149279	8571
346	30485	9994
346	78902	8571
346	34334	9994
346	95615	8571
346	104404	9994
346	148315	8571
347	38318	9999
347	37900	10000
347	38247	9999
347	37886	10000
347	94288	9999
347	37100	10000
347	69805	9999
347	37889	10000
347	94284	9999
347	94030	10000
347	33671	9999
347	37893	10000
347	23997	9999
347	37981	10000
347	131531	10000
347	148336	9999
347	38231	10000
347	37945	9999
347	75500	10000
347	173432	9999
347	104377	10000
348	13131	9993
348	37868	9997
348	37988	9993
348	38347	9997
348	36849	9993
348	3329	9997
348	38322	9993
348	104415	9997
348	38800	9993
348	149150	9997
348	38371	9993
348	37866	9997
348	38784	9993
348	36868	9993
348	68120	9997
348	38786	9993
348	33622	9993
348	45490	9997
348	178284	9993
349	37990	8342
349	13131	9993
349	21812	8342
349	37988	9993
349	11736	8342
349	36849	9993
349	42594	8342
349	38322	9993
349	37963	8342
349	38800	9993
349	39578	8342
349	30910	9993
349	37979	8342
349	38784	9993
349	37858	8342
349	36868	9993
349	52280	8342
349	27423	8342
349	41106	9993
349	75405	8342
349	33622	9993
350	38391	8635
350	38318	9999
350	38388	8635
350	38247	9999
350	38389	8635
350	94288	9999
350	38253	8635
350	69805	9999
350	69713	8635
350	94284	9999
350	33620	8635
350	26669	9999
350	38383	8635
350	33671	9999
350	38393	8635
350	23997	9999
350	37069	8635
350	148336	9999
350	106013	8635
350	37945	9999
350	181276	8635
350	173432	9999
351	37868	9997
351	131403	9984
351	33595	9997
351	38342	9984
351	3329	9997
351	37051	9984
351	38186	9984
351	104415	9997
351	104386	9984
351	38354	9997
351	27110	9984
351	37866	9997
351	37957	9984
351	38347	9997
351	37047	9984
351	37021	9984
351	5016	9997
351	38357	9984
351	89548	9984
352	37900	10000
352	39573	8203
352	37886	10000
352	67950	8203
352	37903	10000
352	38791	8203
352	37889	10000
352	67941	8203
352	131532	10000
352	164352	8203
352	37893	10000
352	67898	8203
352	37981	10000
352	37112	8203
352	26741	10000
352	38969	8203
352	131531	10000
352	178291	8203
352	104377	10000
352	148286	8203
352	38231	10000
352	17276	8203
353	104378	9991
353	38797	9985
353	27838	9991
353	37861	9985
353	38337	9991
353	47411	9985
353	12473	9991
353	129462	9985
353	104382	9991
353	159888	9985
353	26916	9991
353	35412	9985
353	32760	9991
353	39591	9985
353	41109	9991
353	156551	9985
353	39875	9991
353	37262	9985
353	12574	9991
353	38369	9985
353	46335	9991
353	166302	9985
354	37971	8571
354	37937	9987
354	38441	8571
354	38785	9987
354	131404	8571
354	38249	8571
354	94462	9987
354	39859	8571
354	148313	9987
354	38257	8571
354	32863	9987
354	40521	8571
354	38435	9987
354	149279	8571
354	39498	9987
354	78902	8571
354	43158	9987
354	95615	8571
354	148327	9987
354	148315	8571
354	163674	9987
355	38341	10001
355	38289	9994
355	38349	10001
355	38292	9994
355	43049	10001
355	39594	9994
355	37953	10001
355	11569	9994
355	14642	9994
355	38343	10001
355	12099	9994
355	38348	10001
355	38290	9994
355	38778	10001
355	34334	9994
355	182605	10001
355	15425	9994
355	37025	10001
355	166675	9994
355	166584	10001
356	37990	8342
356	40014	9986
356	36832	8342
356	21812	8342
356	38417	9986
356	37858	8342
356	167619	9986
356	42594	8342
356	46666	9986
356	39578	8342
356	38423	9986
356	37979	8342
356	39145	9986
356	38366	8342
356	38439	9986
356	52280	8342
356	40520	9986
356	38440	8342
356	38920	9986
356	163670	8342
356	164732	9986
357	38391	8635
357	37971	8571
357	33620	8635
357	39859	8571
357	38388	8635
357	38441	8571
357	38389	8635
357	131404	8571
357	69713	8635
357	149279	8571
357	38378	8635
357	38249	8571
357	38393	8635
357	33685	8571
357	38253	8635
357	38257	8571
357	106013	8635
357	40521	8571
357	37069	8635
357	95615	8571
357	181276	8635
357	148315	8571
358	37868	9997
358	38797	9985
358	33595	9997
358	37861	9985
358	3329	9997
358	47411	9985
358	104415	9997
358	119117	9985
358	149150	9997
358	159888	9985
358	38354	9997
358	39580	9985
358	37866	9997
358	26224	9985
358	5016	9997
358	39591	9985
358	148335	9985
358	68120	9997
358	37262	9985
358	178484	9985
359	37900	10000
359	38289	9994
359	37886	10000
359	38292	9994
359	37100	10000
359	39594	9994
359	37903	10000
359	11569	9994
359	37889	10000
359	14642	9994
359	37893	10000
359	25465	9994
359	37981	10000
359	38290	9994
359	131531	10000
359	34334	9994
359	26741	10000
359	69629	9994
359	38231	10000
359	166675	9994
359	104377	10000
360	104378	9991
360	131403	9984
360	27838	9991
360	38342	9984
360	38337	9991
360	37047	9984
360	12473	9991
360	37021	9984
360	104382	9991
360	38186	9984
360	27421	9991
360	38357	9984
360	33662	9991
360	27110	9984
360	26916	9991
360	37957	9984
360	32760	9991
360	104386	9984
360	12574	9991
360	166670	9984
360	46335	9991
360	89548	9984
361	38341	10001
361	39573	8203
361	38349	10001
361	67950	8203
361	43049	10001
361	38791	8203
361	37953	10001
361	67941	8203
361	38343	10001
361	67898	8203
361	38778	10001
361	178291	8203
361	67896	10001
361	67957	8203
361	182605	10001
361	67952	8203
361	37025	10001
361	166584	10001
361	17276	8203
362	13131	9993
362	38318	9999
362	37988	9993
362	38247	9999
362	36849	9993
362	94288	9999
362	38322	9993
362	69805	9999
362	38800	9993
362	94284	9999
362	38371	9993
362	26669	9999
362	38784	9993
362	33671	9999
362	36868	9993
362	23997	9999
362	38786	9993
362	148336	9999
362	41106	9993
362	37945	9999
362	33622	9993
362	24037	9999
363	38797	9985
363	13131	9993
363	39580	9985
363	37988	9993
363	156551	9985
363	36849	9993
363	47411	9985
363	38322	9993
363	159888	9985
363	38800	9993
363	32573	9985
363	38371	9993
363	39591	9985
363	38784	9993
363	148335	9985
363	36868	9993
363	166302	9985
363	38786	9993
363	37262	9985
363	41106	9993
363	25957	9985
363	33622	9993
364	37937	9987
364	38341	10001
364	38785	9987
364	38349	10001
364	38293	9987
364	38343	10001
364	43049	10001
364	94462	9987
364	37953	10001
364	32863	9987
364	38778	10001
364	39498	9987
364	67896	10001
364	43158	9987
364	179058	10001
364	148314	9987
364	182605	10001
364	169200	9987
364	37025	10001
364	42153	9987
364	166584	10001
365	40014	9986
365	37868	9997
365	33595	9997
365	38417	9986
365	38347	9997
365	167619	9986
365	3329	9997
365	46666	9986
365	104415	9997
365	38423	9986
365	38354	9997
365	104389	9986
365	37866	9997
365	40520	9986
365	45490	9997
365	131409	9986
365	38920	9986
365	68120	9997
365	38419	9986
365	5016	9997
366	36835	9984
366	38391	8635
366	38342	9984
366	33620	8635
366	37047	9984
366	38388	8635
366	37051	9984
366	38389	8635
366	37038	9984
366	69713	8635
366	38186	9984
366	38378	8635
366	27110	9984
366	38383	8635
366	37957	9984
366	38393	8635
366	104386	9984
366	38253	8635
366	38357	9984
366	106013	8635
366	38251	9984
366	37069	8635
367	38289	9994
367	37990	8342
367	38292	9994
367	36832	8342
367	39594	9994
367	21812	8342
367	11569	9994
367	37858	8342
367	14642	9994
367	42594	8342
367	12099	9994
367	38336	8342
367	38945	9994
367	38366	8342
367	25465	9994
367	52280	8342
367	38290	9994
367	39578	8342
367	15662	9994
367	37979	8342
367	69629	9994
367	75405	8342
368	37971	8571
368	37900	10000
368	37887	8571
368	37886	10000
368	6803	8571
368	37100	10000
368	38441	8571
368	37889	10000
368	131404	8571
368	131532	10000
368	38249	8571
368	37981	10000
368	33685	8571
368	26741	10000
368	38257	8571
368	131531	10000
368	40521	8571
368	130027	10000
368	104377	10000
368	148315	8571
368	38231	10000
369	39573	8203
369	104378	9991
369	6800	8203
369	27838	9991
369	67941	8203
369	38337	9991
369	12473	9991
369	164352	8203
369	104382	9991
369	67898	8203
369	27421	9991
369	178291	8203
369	26916	9991
369	67957	8203
369	32760	9991
369	67952	8203
369	39875	9991
369	148286	8203
369	46335	9991
369	17276	8203
369	148329	9991
370	37990	8342
370	39573	8203
370	36832	8342
370	6800	8203
370	21812	8342
370	39389	8203
370	37858	8342
370	67941	8203
370	42594	8342
370	37979	8342
370	67898	8203
370	11736	8342
370	37112	8203
370	38366	8342
370	38969	8203
370	27423	8342
370	178291	8203
370	38440	8342
370	67957	8203
370	38336	8342
370	17276	8203
371	38797	9985
371	38318	9999
371	25995	9985
371	39580	9985
371	38247	9999
371	47411	9985
371	94288	9999
371	156551	9985
371	148336	9999
371	35412	9985
371	33671	9999
371	26224	9985
371	23997	9999
371	37861	9985
371	69805	9999
371	39591	9985
371	148335	9985
371	148338	9999
371	37262	9985
371	37945	9999
372	37868	9997
372	37971	8571
372	33595	9997
372	37887	8571
372	3329	9997
372	38441	8571
372	36836	9997
372	131404	8571
372	149150	9997
372	149279	8571
372	38354	9997
372	38249	8571
372	37866	9997
372	33685	8571
372	38347	9997
372	68120	9997
372	38257	8571
372	5016	9997
372	40521	8571
372	45490	9997
372	39772	8571
373	37900	10000
373	36835	9984
373	37886	10000
373	38342	9984
373	37100	10000
373	37047	9984
373	37889	10000
373	38789	9984
373	131532	10000
373	37038	9984
373	37981	10000
373	38186	9984
373	131531	10000
373	27110	9984
373	130027	10000
373	37957	9984
373	37893	10000
373	104386	9984
373	38231	10000
373	166670	9984
373	104377	10000
373	38357	9984
374	104378	9991
374	37937	9987
374	27838	9991
374	38785	9987
374	38337	9991
374	38293	9987
374	12473	9991
374	104382	9991
374	94462	9987
374	27421	9991
374	32863	9987
374	26916	9991
374	38794	9987
374	32760	9991
374	39498	9987
374	46335	9991
374	43158	9987
374	148329	9991
374	148314	9987
374	166618	9991
374	42153	9987
375	38341	10001
375	38391	8635
375	38349	10001
375	33620	8635
375	39848	10001
375	38388	8635
375	43049	10001
375	38389	8635
375	69713	8635
375	38343	10001
375	38378	8635
375	38778	10001
375	38383	8635
375	67896	10001
375	38253	8635
375	182605	10001
375	148302	8635
375	17883	10001
375	46552	8635
375	166584	10001
375	181276	8635
376	13131	9993
376	40014	9986
376	36849	9993
376	36845	9993
376	38417	9986
376	38322	9993
376	167619	9986
376	38800	9993
376	46666	9986
376	38371	9993
376	38423	9986
376	38784	9993
376	38439	9986
376	36868	9993
376	40520	9986
376	166676	9993
376	131409	9986
376	41106	9993
376	38920	9986
376	33622	9993
376	38419	9986
377	38391	8635
377	37990	8342
377	33620	8635
377	36832	8342
377	38388	8635
377	21812	8342
377	38389	8635
377	38336	8342
377	38253	8635
377	39578	8342
377	69713	8635
377	37979	8342
377	38393	8635
377	11736	8342
377	148302	8635
377	42594	8342
377	38378	8635
377	38366	8342
377	38383	8635
377	163670	8342
377	181276	8635
377	75405	8342
378	37937	9987
378	37900	10000
378	38785	9987
378	37100	10000
378	38293	9987
378	37889	10000
378	94030	10000
378	94462	9987
378	131532	10000
378	32863	9987
378	37893	10000
378	43158	9987
378	37981	10000
378	148314	9987
378	131531	10000
378	127191	9987
378	130027	10000
378	42153	9987
378	104377	10000
378	38794	9987
378	38231	10000
379	104388	9986
379	38797	9985
379	39580	9985
379	38417	9986
379	47411	9985
379	37571	9986
379	35412	9985
379	46666	9986
379	159888	9985
379	38423	9986
379	39631	9985
379	39145	9986
379	39591	9985
379	38439	9986
379	148335	9985
379	40520	9986
379	156551	9985
379	38920	9986
379	25957	9985
379	164732	9986
379	38369	9985
380	38289	9994
380	104378	9991
380	38292	9994
380	27838	9991
380	39594	9994
380	38337	9991
380	11569	9994
380	12473	9991
380	14642	9994
380	104382	9991
380	12099	9994
380	27421	9991
380	38945	9994
380	33662	9991
380	25465	9994
380	32760	9991
380	38290	9994
380	46335	9991
380	15662	9994
380	148329	9991
380	69629	9994
380	166618	9991
381	37971	8571
381	38341	10001
381	37887	8571
381	39848	10001
381	38441	8571
381	21834	10001
381	131404	8571
381	37953	10001
381	149279	8571
381	38339	10001
381	38249	8571
381	38343	10001
381	33685	8571
381	38778	10001
381	38257	8571
381	67896	10001
381	40521	8571
381	182605	10001
381	39772	8571
381	37025	10001
381	78902	8571
381	166584	10001
382	38327	8203
382	13131	9993
382	6800	8203
382	37988	9993
382	39389	8203
382	36849	9993
382	67941	8203
382	38322	9993
382	67898	8203
382	38380	9993
382	37112	8203
382	38800	9993
382	67957	8203
382	38784	9993
382	67959	8203
382	38786	9993
382	148286	8203
382	166676	9993
382	17276	8203
382	41106	9993
382	26502	8203
382	33622	9993
383	38318	9999
383	37868	9997
383	38354	9997
383	38247	9999
383	38347	9997
383	94288	9999
383	3329	9997
383	148338	9999
383	149150	9997
383	33671	9999
383	33595	9997
383	23997	9999
383	69805	9999
383	68120	9997
383	148336	9999
383	5016	9997
383	37945	9999
383	36836	9997
384	37990	8342
384	30934	9994
384	21812	8342
384	38292	9994
384	11736	8342
384	39594	9994
384	37858	8342
384	11569	9994
384	42594	8342
384	14642	9994
384	37963	8342
384	12099	9994
384	39578	8342
384	38945	9994
384	37979	8342
384	95609	9994
384	38336	8342
384	15662	9994
384	27423	8342
384	30485	9994
384	38440	8342
384	104404	9994
385	38391	8635
385	131403	9984
385	33620	8635
385	38342	9984
385	38388	8635
385	37047	9984
385	13423	8635
385	37021	9984
385	38389	8635
385	37051	9984
385	30949	8635
385	38357	9984
385	38378	8635
385	32863	9984
385	38383	8635
385	37909	9984
385	38393	8635
385	104386	9984
385	37069	8635
385	78462	9984
385	46552	8635
385	89548	9984
386	37868	9997
386	40014	9986
386	33595	9997
386	38347	9997
386	38439	9986
386	3329	9997
386	167619	9986
386	149150	9997
386	46666	9986
386	38354	9997
386	37866	9997
386	25636	9986
386	38419	9986
386	5016	9997
386	40520	9986
386	36836	9997
386	38920	9986
386	45490	9997
386	131409	9986
387	37900	10000
387	37937	9987
387	37886	10000
387	38293	9987
387	37903	10000
387	104411	9987
387	37889	10000
387	148314	9987
387	94030	10000
387	148313	9987
387	37902	10000
387	9307	9987
387	37981	10000
387	39498	9987
387	131531	10000
387	43158	9987
387	130027	10000
387	42153	9987
387	38231	10000
387	169200	9987
387	104377	10000
387	163674	9987
388	104378	9991
388	38327	8203
388	38337	9991
388	67950	8203
388	38255	9991
388	6800	8203
388	12473	9991
388	39389	8203
388	41109	9991
388	67941	8203
388	33662	9991
388	38801	8203
388	26916	9991
388	67898	8203
388	38233	9991
388	37112	8203
388	32760	9991
388	178291	8203
388	37065	9991
388	67952	8203
388	12574	9991
388	17276	8203
389	38341	10001
389	37971	8571
389	38349	10001
389	6803	8571
389	37953	10001
389	16387	8571
389	38339	10001
389	67939	8571
389	67896	10001
389	149279	8571
389	38343	10001
389	38249	8571
389	38332	10001
389	39859	8571
389	47410	10001
389	38257	8571
389	17883	10001
389	40521	8571
389	25619	10001
389	39772	8571
389	166584	10001
389	95615	8571
390	13131	9993
390	38797	9985
390	36849	9993
390	39580	9985
390	36845	9993
390	37861	9985
390	38784	9993
390	47411	9985
390	37988	9993
390	37262	9985
390	38371	9993
390	39631	9985
390	30910	9993
390	39591	9985
390	36852	9993
390	156551	9985
390	36868	9993
390	25957	9985
390	38786	9993
390	38369	9985
390	33622	9993
390	178484	9985
391	37990	8342
391	36835	9984
391	36832	8342
391	38342	9984
391	21812	8342
391	37047	9984
391	37858	8342
391	38789	9984
391	42594	8342
391	37051	9984
391	39578	8342
391	38186	9984
391	38336	8342
391	27110	9984
391	38366	8342
391	37957	9984
391	163670	8342
391	166670	9984
391	75405	8342
391	38357	9984
391	52280	8342
391	38251	9984
392	38797	9985
392	38289	9994
392	37861	9985
392	38292	9994
392	129462	9985
392	11569	9994
392	159888	9985
392	14642	9994
392	37972	9985
392	25465	9994
392	26224	9985
392	38273	9994
392	39591	9985
392	38945	9994
392	148335	9985
392	38290	9994
392	156551	9985
392	95609	9994
392	25957	9985
392	15662	9994
392	38369	9985
392	69629	9994
393	37868	9997
393	38327	8203
393	38354	9997
393	67950	8203
393	33595	9997
393	67898	8203
393	3329	9997
393	38791	8203
393	149150	9997
393	148286	8203
393	38347	9997
393	17276	8203
393	37112	8203
393	36836	9997
393	38969	8203
393	67957	8203
393	5016	9997
393	39389	8203
393	68120	9997
393	164352	8203
394	37900	10000
394	38341	10001
394	37100	10000
394	38349	10001
394	37889	10000
394	43049	10001
394	94030	10000
394	37953	10001
394	131532	10000
394	67896	10001
394	37893	10000
394	37981	10000
394	38343	10001
394	26741	10000
394	38778	10001
394	131531	10000
394	182605	10001
394	75500	10000
394	37025	10001
394	104377	10000
394	50160	10001
395	104388	9986
395	38318	9999
395	38417	9986
395	38247	9999
395	37571	9986
395	94288	9999
395	46666	9986
395	69805	9999
395	38423	9986
395	46217	9999
395	39145	9986
395	33671	9999
395	38439	9986
395	23997	9999
395	131409	9986
395	148338	9999
395	38920	9986
395	148336	9999
395	38419	9986
395	173432	9999
396	104378	9991
396	38391	8635
396	27838	9991
396	38388	8635
396	38337	9991
396	38389	8635
396	12473	9991
396	38253	8635
396	104382	9991
396	69713	8635
396	27421	9991
396	33620	8635
396	39875	9991
396	38378	8635
396	26916	9991
396	38383	8635
396	32760	9991
396	38393	8635
396	46335	9991
396	148302	8635
396	148329	9991
396	181276	8635
397	13131	9993
397	91929	9987
397	37988	9993
397	38785	9987
397	36849	9993
397	39498	9987
397	38784	9993
397	94462	9987
397	33622	9993
397	148314	9987
397	41106	9993
397	32863	9987
397	38322	9993
397	42153	9987
397	38800	9993
397	38794	9987
397	166676	9993
397	43158	9987
397	38371	9993
397	38293	9987
397	36868	9993
398	38391	8635
398	37900	10000
398	38388	8635
398	37886	10000
398	38389	8635
398	37100	10000
398	38253	8635
398	37889	10000
398	69713	8635
398	94030	10000
398	33620	8635
398	37893	10000
398	38378	8635
398	37981	10000
398	38383	8635
398	26741	10000
398	148302	8635
398	131531	10000
398	37069	8635
398	104377	10000
398	181276	8635
398	38231	10000
399	91929	9987
399	37868	9997
399	38293	9987
399	33595	9997
399	38347	9997
399	94462	9987
399	3329	9997
399	148314	9987
399	149150	9997
399	32863	9987
399	38354	9997
399	38794	9987
399	39498	9987
399	36836	9997
399	9307	9987
399	169200	9987
399	68120	9997
399	42153	9987
399	5016	9997
400	36835	9984
400	38797	9985
400	38342	9984
400	39580	9985
400	38789	9984
400	129462	9985
400	37038	9984
400	156551	9985
400	38186	9984
400	159888	9985
400	38357	9984
400	37972	9985
400	27110	9984
400	37861	9985
400	37957	9984
400	39591	9985
400	37051	9984
400	119117	9985
400	38251	9984
400	148335	9985
400	166670	9984
400	38369	9985
401	38289	9994
401	13131	9993
401	38292	9994
401	37988	9993
401	11569	9994
401	36849	9993
401	14642	9994
401	38322	9993
401	38273	9994
401	38800	9993
401	12099	9994
401	38371	9993
401	38945	9994
401	38784	9993
401	25465	9994
401	36868	9993
401	38290	9994
401	166676	9993
401	34334	9994
401	41106	9993
401	69629	9994
401	33622	9993
402	37971	8571
402	37990	8342
402	39859	8571
402	36832	8342
402	38441	8571
402	21812	8342
402	131404	8571
402	37858	8342
402	149279	8571
402	42594	8342
402	6803	8571
402	39578	8342
402	33685	8571
402	37979	8342
402	38257	8571
402	38366	8342
402	40521	8571
402	38336	8342
402	95615	8571
402	163670	8342
402	148315	8571
402	75405	8342
403	38327	8203
403	104388	9986
403	38791	8203
403	38417	9986
403	164352	8203
403	37571	9986
403	37112	8203
403	46666	9986
403	38969	8203
403	39145	9986
403	178291	8203
403	38439	9986
403	67957	8203
403	40520	9986
403	67952	8203
403	131409	9986
403	148286	8203
403	38920	9986
403	17276	8203
403	38419	9986
404	38318	9999
404	104378	9991
404	38337	9991
404	38247	9999
404	38255	9991
404	94288	9999
404	12473	9991
404	69805	9999
404	104382	9991
404	27421	9991
404	46217	9999
404	33662	9991
404	33671	9999
404	166618	9991
404	23997	9999
404	39875	9991
404	148336	9999
404	12574	9991
404	37945	9999
404	148329	9991
405	37990	8342
405	38341	10001
405	36832	8342
405	43049	10001
405	37979	8342
405	37953	10001
405	11736	8342
405	38339	10001
405	95614	8342
405	39578	8342
405	38343	10001
405	38366	8342
405	21834	10001
405	166575	8342
405	38778	10001
405	38336	8342
405	182605	10001
405	163670	8342
405	37025	10001
405	75405	8342
405	50160	10001
406	38797	9985
406	38391	8635
406	39580	9985
406	38388	8635
406	37861	9985
406	38389	8635
406	47411	9985
406	38253	8635
406	156551	9985
406	69713	8635
406	35412	9985
406	33620	8635
406	26224	9985
406	38378	8635
406	39591	9985
406	38383	8635
406	148335	9985
406	38393	8635
406	25957	9985
406	148302	8635
406	38369	9985
406	181276	8635
407	37868	9997
407	38289	9994
407	33595	9997
407	38292	9994
407	38347	9997
407	11569	9994
407	178486	9997
407	14642	9994
407	149150	9997
407	38273	9994
407	38354	9997
407	12099	9994
407	37866	9997
407	38945	9994
407	36836	9997
407	25465	9994
407	45490	9997
407	38290	9994
407	5016	9997
407	15662	9994
407	34334	9994
408	104388	9986
408	91929	9987
408	38293	9987
408	38417	9986
408	167619	9986
408	104411	9987
408	46666	9986
408	148313	9987
408	39145	9986
408	32863	9987
408	38439	9986
408	38435	9987
408	40520	9986
408	39498	9987
408	20445	9987
408	38920	9986
408	38794	9987
408	164732	9986
408	150510	9987
409	104378	9991
409	37971	8571
409	27838	9991
409	37887	8571
409	38337	9991
409	38441	8571
409	12473	9991
409	131404	8571
409	104382	9991
409	149279	8571
409	33662	9991
409	6803	8571
409	37044	9991
409	166618	9991
409	38257	8571
409	39875	9991
409	40521	8571
409	12574	9991
409	39772	8571
409	148329	9991
409	95615	8571
410	38318	9999
410	38327	8203
410	69805	9999
410	67950	8203
410	94284	9999
410	6800	8203
410	148338	9999
410	39389	8203
410	129278	9999
410	67898	8203
410	33671	9999
410	37112	8203
410	23997	9999
410	38969	8203
410	148336	9999
410	67959	8203
410	67952	8203
410	25619	9999
410	148286	8203
410	106369	9999
410	26502	8203
411	13131	9993
411	36835	9984
411	37988	9993
411	37047	9984
411	36849	9993
411	38789	9984
411	38322	9993
411	38186	9984
411	38800	9993
411	104386	9984
411	38371	9993
411	27110	9984
411	30910	9993
411	37051	9984
411	38784	9993
411	166670	9984
411	36868	9993
411	38357	9984
411	41106	9993
411	38251	9984
411	33622	9993
411	38782	9984
412	91929	9987
412	37990	8342
412	38293	9987
412	36832	8342
412	43158	9987
412	11736	8342
412	94462	9987
412	39878	8342
412	178276	9987
412	42594	8342
412	32863	9987
412	39578	8342
412	39498	9987
412	37979	8342
412	104411	9987
412	37858	8342
412	169200	9987
412	163670	8342
412	38794	9987
412	38336	8342
412	150510	9987
412	75405	8342
413	37900	10000
413	37868	9997
413	37886	10000
413	38354	9997
413	37100	10000
413	33595	9997
413	37889	10000
413	3329	9997
413	94030	10000
413	149150	9997
413	37893	10000
413	37866	9997
413	37981	10000
413	38347	9997
413	26741	10000
413	36836	9997
413	131531	10000
413	45490	9997
413	104377	10000
413	38365	9997
413	75500	10000
413	5016	9997
414	36835	9984
414	40014	9986
414	38342	9984
414	37047	9984
414	39977	9986
414	38789	9984
414	38417	9986
414	37051	9984
414	46666	9986
414	38186	9984
414	39145	9986
414	27110	9984
414	38439	9986
414	166670	9984
414	40520	9986
414	178249	9984
414	20445	9986
414	38251	9984
414	38357	9984
414	38920	9986
415	38289	9994
415	38318	9999
415	38292	9994
415	38247	9999
415	11569	9994
415	94288	9999
415	14642	9994
415	94284	9999
415	38273	9994
415	129278	9999
415	12099	9994
415	33671	9999
415	38945	9994
415	23997	9999
415	25465	9994
415	25619	9999
415	38290	9994
415	148336	9999
415	34334	9994
415	37945	9999
415	17703	9994
415	106369	9999
416	37971	8571
416	13131	9993
416	6803	8571
416	37988	9993
416	39859	8571
416	36849	9993
416	33685	8571
416	36845	9993
416	38441	8571
416	38322	9993
416	38249	8571
416	38371	9993
416	38257	8571
416	38784	9993
416	95615	8571
416	36868	9993
416	78902	8571
416	38786	9993
416	149279	8571
416	41106	9993
416	148315	8571
416	33622	9993
417	38327	8203
417	38797	9985
417	67950	8203
417	37983	9985
417	6800	8203
417	25995	9985
417	39389	8203
417	39580	9985
417	67959	8203
417	156551	9985
417	67898	8203
417	37262	9985
417	17276	8203
417	25957	9985
417	38969	8203
417	26224	9985
417	67952	8203
417	39591	9985
417	148286	8203
417	148335	9985
417	26502	8203
417	38369	9985
418	38341	10001
418	104378	9991
418	43049	10001
418	27838	9991
418	37953	10001
418	38337	9991
418	38339	10001
418	12473	9991
418	21834	10001
418	37044	9991
418	38778	10001
418	26916	9991
418	67896	10001
418	38233	9991
418	182605	10001
418	39875	9991
418	50160	10001
418	46335	9991
418	166584	10001
418	166618	9991
419	38797	9985
419	37971	8571
419	37983	9985
419	6803	8571
419	39580	9985
419	16387	8571
419	47411	9985
419	67939	8571
419	156551	9985
419	131404	8571
419	37972	9985
419	38249	8571
419	39631	9985
419	38257	8571
419	39591	9985
419	40521	8571
419	148335	9985
419	95615	8571
419	37262	9985
419	78902	8571
419	25957	9985
419	148315	8571
420	37868	9997
420	38341	10001
420	33595	9997
420	38349	10001
420	38347	9997
420	43049	10001
420	3329	9997
420	21834	10001
420	149150	9997
420	37953	10001
420	38354	9997
420	38343	10001
420	37866	9997
420	38778	10001
420	36836	9997
420	47410	10001
420	45490	9997
420	182605	10001
420	5016	9997
420	37025	10001
420	68120	9997
420	17883	10001
421	104388	9986
421	30934	9994
421	39594	9994
421	39977	9986
421	11569	9994
421	38417	9986
421	25465	9994
421	46666	9986
421	38273	9994
421	38423	9986
421	12099	9994
421	39145	9986
421	38945	9994
421	20445	9986
421	38290	9994
421	167619	9986
421	95609	9994
421	38920	9986
421	30485	9994
421	164732	9986
421	34334	9994
422	104378	9991
422	37900	10000
422	27838	9991
422	37886	10000
422	12473	9991
422	37100	10000
422	41109	9991
422	37889	10000
422	104382	9991
422	94030	10000
422	33662	9991
422	37893	10000
422	37044	9991
422	37981	10000
422	38233	9991
422	26741	10000
422	166618	9991
422	131531	10000
422	12574	9991
422	38231	10000
422	46335	9991
422	104377	10000
423	38327	8203
423	36835	9984
423	67950	8203
423	37047	9984
423	6800	8203
423	38789	9984
423	39389	8203
423	38186	9984
423	67959	8203
423	104386	9984
423	37112	8203
423	38342	9984
423	38969	8203
423	27110	9984
423	178291	8203
423	37051	9984
423	67957	8203
423	38251	9984
423	38782	9984
423	67952	8203
423	89548	9984
424	38318	9999
424	91929	9987
424	38247	9999
424	38785	9987
424	94284	9999
424	38293	9987
424	148338	9999
424	104411	9987
424	129278	9999
424	148314	9987
424	32863	9987
424	33671	9999
424	39498	9987
424	23997	9999
424	43158	9987
424	37945	9999
424	42153	9987
424	25619	9999
424	38794	9987
424	106369	9999
424	169200	9987
425	13131	9993
425	38391	8635
425	37988	9993
425	33620	8635
425	36849	9993
425	38388	8635
425	38322	9993
425	38389	8635
425	38800	9993
425	38253	8635
425	38784	9993
425	38393	8635
425	36868	9993
425	148302	8635
425	38786	9993
425	12692	8635
425	41106	9993
425	38378	8635
425	33622	9993
425	38383	8635
425	69629	9993
425	181276	8635
426	38391	8635
426	37868	9997
426	33620	8635
426	33595	9997
426	38389	8635
426	3329	9997
426	38393	8635
426	178486	9997
426	69713	8635
426	149150	9997
426	38383	8635
426	38354	9997
426	38253	8635
426	37866	9997
426	148302	8635
426	36836	9997
426	25499	8635
426	68120	9997
426	46552	8635
426	5016	9997
426	12692	8635
426	45490	9997
427	91929	9987
427	38797	9985
427	38293	9987
427	39580	9985
427	43158	9987
427	38795	9985
427	94462	9987
427	156551	9985
427	148314	9987
427	159888	9985
427	32863	9987
427	37983	9985
427	39498	9987
427	26224	9985
427	104411	9987
427	39631	9985
427	169200	9987
427	39591	9985
427	42153	9987
427	38369	9985
427	150510	9987
427	37262	9985
428	37900	10000
428	37990	8342
428	37886	10000
428	36832	8342
428	37100	10000
428	27508	8342
428	37889	10000
428	21812	8342
428	94030	10000
428	11736	8342
428	37893	10000
428	39578	8342
428	37981	10000
428	39878	8342
428	131531	10000
428	42594	8342
428	75500	10000
428	163670	8342
428	112934	10000
428	52280	8342
428	104377	10000
428	75405	8342
429	36835	9984
429	38318	9999
429	38342	9984
429	38247	9999
429	37047	9984
429	94288	9999
429	38789	9984
429	94284	9999
429	38186	9984
429	129278	9999
429	27110	9984
429	33671	9999
429	37909	9984
429	23997	9999
429	104386	9984
429	148336	9999
429	166670	9984
429	37945	9999
429	178249	9984
429	25619	9999
429	38251	9984
429	106369	9999
430	30934	9994
430	38327	8203
430	38292	9994
430	67950	8203
430	39594	9994
430	6800	8203
430	11569	9994
430	39389	8203
430	14642	9994
430	67959	8203
430	38945	9994
430	67898	8203
430	25465	9994
430	37112	8203
430	38290	9994
430	38969	8203
430	30910	9994
430	67952	8203
430	30485	9994
430	148286	8203
430	34334	9994
430	178291	8203
431	37971	8571
431	104388	9986
431	38417	9986
431	38441	8571
431	37571	9986
431	16387	8571
431	46666	9986
431	131404	8571
431	38249	8571
431	33685	8571
431	38439	9986
431	40521	8571
431	40520	9986
431	78902	8571
431	38419	9986
431	95615	8571
431	20445	9986
431	148315	8571
432	38341	10001
432	13131	9993
432	43049	10001
432	37988	9993
432	37953	10001
432	38322	9993
432	38339	10001
432	36849	9993
432	38800	9993
432	38343	10001
432	38784	9993
432	21834	10001
432	38786	9993
432	38778	10001
432	166676	9993
432	67896	10001
432	33622	9993
432	182605	10001
432	69629	9993
432	17883	10001
432	166679	9993
433	38797	9985
433	38341	10001
433	38795	9985
433	38349	10001
433	47411	9985
433	38343	10001
433	159888	9985
433	43049	10001
433	37983	9985
433	37953	10001
433	35412	9985
433	21834	10001
433	39631	9985
433	38778	10001
433	39591	9985
433	67896	10001
433	148335	9985
433	182605	10001
433	156551	9985
433	37025	10001
433	25957	9985
433	39848	10001
434	104388	9986
434	38391	8635
434	33620	8635
434	39977	9986
434	38388	8635
434	38417	9986
434	38389	8635
434	46666	9986
434	31316	8635
434	38439	9986
434	38383	8635
434	40520	9986
434	38393	8635
434	20445	9986
434	148302	8635
434	37069	8635
434	38920	9986
434	46552	8635
434	164732	9986
434	12692	8635
435	36835	9984
435	30934	9994
435	38342	9984
435	38292	9994
435	37047	9984
435	39594	9994
435	38789	9984
435	38273	9994
435	38186	9984
435	30910	9994
435	27110	9984
435	38945	9994
435	37957	9984
435	38290	9994
435	37051	9984
435	95609	9994
435	38357	9984
435	30485	9994
435	38251	9984
435	34334	9994
435	89548	9984
435	104404	9994
436	104378	9991
436	37990	8342
436	27838	9991
436	36832	8342
436	38337	9991
436	21812	8342
436	12473	9991
436	11736	8342
436	104382	9991
436	95614	8342
436	27421	9991
436	39578	8342
436	37044	9991
436	38366	8342
436	38233	9991
436	163670	8342
436	166618	9991
436	166575	8342
436	12574	9991
436	38440	8342
436	148329	9991
436	75405	8342
437	38327	8203
437	91929	9987
437	67950	8203
437	38785	9987
437	6800	8203
437	38293	9987
437	39389	8203
437	67959	8203
437	148314	9987
437	38799	8203
437	32863	9987
437	67898	8203
437	9307	9987
437	37112	8203
437	38435	9987
437	38969	8203
437	39498	9987
437	148286	8203
437	42153	9987
437	178291	8203
437	38794	9987
438	38318	9999
438	37971	8571
438	38247	9999
438	39859	8571
438	94288	9999
438	38441	8571
438	94284	9999
438	38257	8571
438	129278	9999
438	131404	8571
438	37945	9999
438	38249	8571
438	23997	9999
438	33685	8571
438	40521	8571
438	148336	9999
438	95615	8571
438	25619	9999
438	78902	8571
438	106369	9999
438	148315	8571
439	13131	9993
439	37900	10000
439	36849	9993
439	37886	10000
439	36845	9993
439	37100	10000
439	38322	9993
439	107416	10000
439	38800	9993
439	94030	10000
439	38784	9993
439	37893	10000
439	36868	9993
439	37981	10000
439	38786	9993
439	131531	10000
439	33622	9993
439	131530	10000
439	69629	9993
439	130027	10000
439	166679	9993
439	104377	10000
440	37990	8342
440	38797	9985
440	36832	8342
440	39580	9985
440	21812	8342
440	47411	9985
440	11736	8342
440	186621	9985
440	42594	8342
440	159888	9985
440	39578	8342
440	37983	9985
440	37979	8342
440	25957	9985
440	38366	8342
440	39631	9985
440	163670	8342
440	39591	9985
440	38440	8342
440	37262	9985
440	75405	8342
440	38369	9985
441	38391	8635
441	38327	8203
441	38388	8635
441	6800	8203
441	38389	8635
441	39389	8203
441	38253	8635
441	67941	8203
441	69713	8635
441	67959	8203
441	38798	8635
441	67898	8203
441	38383	8635
441	38969	8203
441	38393	8635
441	178291	8203
441	148302	8635
441	38799	8203
441	37069	8635
441	148286	8203
441	46552	8635
441	17276	8203
442	91929	9987
442	30934	9994
442	38293	9987
442	38292	9994
442	43158	9987
442	39594	9994
442	94462	9987
442	11569	9994
442	148314	9987
442	14642	9994
442	32863	9987
442	30910	9994
442	39498	9987
442	38945	9994
442	104411	9987
442	25465	9994
442	169200	9987
442	38290	9994
442	42153	9987
442	30485	9994
442	150510	9987
442	34334	9994
443	37900	10000
443	38318	9999
443	37886	10000
443	37100	10000
443	38247	9999
443	37889	10000
443	94284	9999
443	94030	10000
443	129278	9999
443	37893	10000
443	33671	9999
443	37981	10000
443	23997	9999
443	131531	10000
443	94288	9999
443	75500	10000
443	148336	9999
443	112934	10000
443	37945	9999
443	104377	10000
443	25619	9999
444	104378	9991
444	37868	9997
444	27838	9991
444	33595	9997
444	38337	9991
444	3329	9997
444	178486	9997
444	12473	9991
444	149150	9997
444	104382	9991
444	38354	9997
444	27421	9991
444	37866	9997
444	33662	9991
444	36836	9997
444	26916	9991
444	68120	9997
444	46335	9991
444	5016	9997
444	148329	9991
444	45490	9997
445	38434	8571
445	36835	9984
445	37971	8571
445	38342	9984
445	39859	8571
445	37047	9984
445	38441	8571
445	38789	9984
445	131404	8571
445	37038	9984
445	38249	8571
445	27110	9984
445	33685	8571
445	37957	9984
445	38257	8571
445	178249	9984
445	40521	8571
445	38357	9984
445	78902	8571
445	38251	9984
445	148315	8571
445	89548	9984
446	38341	10001
446	104388	9986
446	38349	10001
446	39848	10001
446	38417	9986
446	21834	10001
446	46666	9986
446	37953	10001
446	38423	9986
446	38339	10001
446	39145	9986
446	67896	10001
446	38439	9986
446	38343	10001
446	167619	9986
446	38778	10001
446	20445	9986
446	182605	10001
446	38920	9986
446	37025	10001
447	37868	9997
447	37990	8342
447	33595	9997
447	36832	8342
447	37866	9997
447	21812	8342
447	3329	9997
447	11736	8342
447	149150	9997
447	42594	8342
447	38354	9997
447	39578	8342
447	178486	9997
447	37979	8342
447	36836	9997
447	38366	8342
447	45490	9997
447	163670	8342
447	68120	9997
447	27423	8342
447	5016	9997
447	38440	8342
448	104388	9986
448	37900	10000
448	37886	10000
448	39977	9986
448	37100	10000
448	38417	9986
448	37889	10000
448	37571	9986
448	94030	10000
448	46666	9986
448	37893	10000
448	38423	9986
448	26741	10000
448	39145	9986
448	131531	10000
448	20445	9986
448	131530	10000
448	38920	9986
448	38231	10000
448	164732	9986
448	104377	10000
449	36835	9984
449	170323	9987
449	38342	9984
449	38293	9987
449	37047	9984
449	104411	9987
449	38789	9984
449	94462	9987
449	37051	9984
449	148314	9987
449	27110	9984
449	32863	9987
449	38186	9984
449	39498	9987
449	104386	9984
449	43158	9987
449	38357	9984
449	42153	9987
449	38251	9984
449	38794	9987
449	89548	9984
449	169200	9987
450	38289	9994
450	38341	10001
450	38292	9994
450	38349	10001
450	39594	9994
450	37953	10001
450	11569	9994
450	38339	10001
450	38273	9994
450	30910	9994
450	21834	10001
450	38945	9994
450	38778	10001
450	38290	9994
450	67896	10001
450	30485	9994
450	182605	10001
450	34334	9994
450	37025	10001
450	104404	9994
450	39848	10001
451	38327	8203
451	37971	8571
451	6800	8203
451	39859	8571
451	39389	8203
451	38441	8571
451	67941	8203
451	38257	8571
451	67959	8203
451	131404	8571
451	67898	8203
451	38249	8571
451	37112	8203
451	33685	8571
451	148286	8203
451	40521	8571
451	38969	8203
451	78902	8571
451	38799	8203
451	95615	8571
451	17276	8203
451	148315	8571
452	38318	9999
452	38391	8635
452	33620	8635
452	38247	9999
452	38388	8635
452	94288	9999
452	38389	8635
452	94284	9999
452	69713	8635
452	129278	9999
452	38383	8635
452	33671	9999
452	38393	8635
452	23997	9999
452	38253	8635
452	148336	9999
452	148302	8635
452	37945	9999
452	37069	8635
452	106369	9999
452	46552	8635
453	13131	9993
453	104378	9991
453	37988	9993
453	27838	9991
453	36849	9993
453	38337	9991
453	38800	9993
453	166676	9993
453	12473	9991
453	38784	9993
453	27421	9991
453	38322	9993
453	26916	9991
453	38786	9993
453	38233	9991
453	33622	9993
453	104382	9991
453	69629	9993
453	26116	9991
453	166679	9993
453	148329	9991
454	31226	8342
454	38318	9999
454	36832	8342
454	38247	9999
454	21812	8342
454	94288	9999
454	11736	8342
454	94284	9999
454	37858	8342
454	129278	9999
454	39578	8342
454	37945	9999
454	37979	8342
454	38366	8342
454	33671	9999
454	166575	8342
454	23997	9999
454	34025	8342
454	148336	9999
454	75405	8342
454	106369	9999
455	38391	8635
455	91929	9987
455	38388	8635
455	38785	9987
455	38389	8635
455	104411	9987
455	69713	8635
455	148314	9987
455	38378	8635
455	178276	9987
455	38383	8635
455	32863	9987
455	38393	8635
455	39498	9987
455	38253	8635
455	43158	9987
455	148302	8635
455	42153	9987
455	46552	8635
455	38794	9987
455	181276	8635
455	169200	9987
456	149260	9997
456	13131	9993
456	33595	9997
456	37988	9993
456	38347	9997
456	36845	9993
456	3329	9997
456	38800	9993
456	178486	9997
456	166676	9993
456	38354	9997
456	36868	9993
456	37866	9997
456	38786	9993
456	36836	9997
456	45490	9997
456	41106	9993
456	68120	9997
456	69629	9993
456	5016	9997
456	166679	9993
457	37900	10000
457	38797	9985
457	37886	10000
457	38795	9985
457	37100	10000
457	47411	9985
457	37889	10000
457	129462	9985
457	94030	10000
457	159888	9985
457	37893	10000
457	37983	9985
457	37981	10000
457	39591	9985
457	131531	10000
457	148335	9985
457	131530	10000
457	156551	9985
457	130027	10000
457	37262	9985
457	104377	10000
457	25957	9985
458	104378	9991
458	104388	9986
458	27838	9991
458	38337	9991
458	38417	9986
458	46666	9986
458	12473	9991
458	38423	9986
458	37044	9991
458	39145	9986
458	26916	9991
458	40520	9986
458	38233	9991
458	167619	9986
458	166618	9991
458	20445	9986
458	12574	9991
458	38920	9986
458	148329	9991
458	164732	9986
459	37971	8571
459	30934	9994
459	39859	8571
459	11569	9994
459	38441	8571
459	14642	9994
459	95615	8571
459	25465	9994
459	131404	8571
459	38273	9994
459	38249	8571
459	30910	9994
459	33685	8571
459	12099	9994
459	38257	8571
459	38945	9994
459	40521	8571
459	38290	9994
459	78902	8571
459	30485	9994
459	148315	8571
459	17703	9994
460	38341	10001
460	36835	9984
460	38349	10001
460	38342	9984
460	43049	10001
460	37047	9984
460	21834	10001
460	38789	9984
460	37953	10001
460	38186	9984
460	38343	10001
460	38357	9984
460	38778	10001
460	27110	9984
460	67896	10001
460	37957	9984
460	182605	10001
460	37051	9984
460	39848	10001
460	38251	9984
460	192907	10001
460	89548	9984
461	38391	8635
461	38341	10001
461	33620	8635
461	38349	10001
461	38388	8635
461	37953	10001
461	13423	8635
461	38339	10001
461	38389	8635
461	67896	10001
461	38798	8635
461	38343	10001
461	38383	8635
461	38348	10001
461	38393	8635
461	38332	10001
461	38253	8635
461	47410	10001
461	37069	8635
461	25619	10001
461	46552	8635
461	166584	10001
462	37937	9987
462	104378	9991
462	38785	9987
462	27838	9991
462	104411	9987
462	38337	9991
462	148314	9987
462	38255	9991
462	148313	9987
462	12473	9991
462	9307	9987
462	41109	9991
462	38435	9987
462	38233	9991
462	39498	9987
462	32760	9991
462	43158	9987
462	39875	9991
462	42153	9987
462	37065	9991
462	163674	9987
462	12574	9991
463	40014	9986
463	13131	9993
463	37988	9993
463	38417	9986
463	36849	9993
463	37571	9986
463	36845	9993
463	46666	9986
463	36868	9993
463	30910	9993
463	38423	9986
463	36852	9993
463	38439	9986
463	38784	9993
463	40520	9986
463	38380	9993
463	38920	9986
463	38786	9993
463	38419	9986
463	33622	9993
464	131403	9984
464	37900	10000
464	38342	9984
464	37886	10000
464	37047	9984
464	37100	10000
464	37021	9984
464	37903	10000
464	37051	9984
464	37889	10000
464	38357	9984
464	37902	10000
464	27110	9984
464	37981	10000
464	32863	9984
464	131531	10000
464	37909	9984
464	130027	10000
464	78462	9984
464	104377	10000
464	89548	9984
464	38231	10000
465	30934	9994
465	37868	9997
465	38292	9994
465	33595	9997
465	39594	9994
465	38347	9997
465	14642	9994
465	3329	9997
465	149150	9997
465	12099	9994
465	38354	9997
465	38290	9994
465	37866	9997
465	95609	9994
465	36836	9997
465	15662	9994
465	30485	9994
465	5016	9997
465	45490	9997
466	38327	8203
466	37990	8342
466	67950	8203
466	21812	8342
466	6800	8203
466	11736	8342
466	39389	8203
466	37858	8342
466	67941	8203
466	37963	8342
466	38801	8203
466	37983	8342
466	37112	8203
466	39578	8342
466	38969	8203
466	37979	8342
466	178291	8203
466	38336	8342
466	148286	8203
466	38366	8342
466	17276	8203
466	38440	8342
467	38318	9999
467	38797	9985
467	39580	9985
467	38247	9999
467	47411	9985
467	94288	9999
467	46890	9985
467	69805	9999
467	39631	9985
467	94284	9999
467	39591	9985
467	26669	9999
467	148335	9985
467	46217	9999
467	156551	9985
467	33671	9999
467	37262	9985
467	148336	9999
467	25957	9985
467	24037	9999
467	38369	9985
468	38797	9985
468	104378	9991
468	39580	9985
468	38337	9991
468	38795	9985
468	38255	9991
468	47411	9985
468	159888	9985
468	104382	9991
468	35412	9985
468	27421	9991
468	39591	9985
468	33662	9991
468	148335	9985
468	26916	9991
468	37262	9985
468	39875	9991
468	25957	9985
468	12574	9991
468	178484	9985
468	46335	9991
469	91929	9987
469	37971	8571
469	43158	9987
469	39859	8571
469	104411	9987
469	38441	8571
469	148313	9987
469	95615	8571
469	148314	9987
469	131404	8571
469	32690	9987
469	38249	8571
469	9307	9987
469	33685	8571
469	38435	9987
469	38257	8571
469	169200	9987
469	40521	8571
469	38794	9987
469	78902	8571
469	150510	9987
469	148315	8571
470	36835	9984
470	149260	9997
470	38342	9984
470	33595	9997
470	37021	9984
470	3329	9997
470	38789	9984
470	178486	9997
470	38186	9984
470	149150	9997
470	37957	9984
470	38354	9997
470	37909	9984
470	37866	9997
470	104386	9984
470	36836	9997
470	178249	9984
470	68120	9997
470	38357	9984
470	5016	9997
470	38782	9984
470	45490	9997
471	30934	9994
471	38391	8635
471	38292	9994
471	38388	8635
471	39594	9994
471	38389	8635
471	11569	9994
471	38253	8635
471	38273	9994
471	69713	8635
471	30910	9994
471	38378	8635
471	25465	9994
471	38383	8635
471	38290	9994
471	38393	8635
471	15662	9994
471	148302	8635
471	46552	8635
471	34334	9994
471	181276	8635
472	38327	8203
472	37900	10000
472	6800	8203
472	37886	10000
472	39389	8203
472	37100	10000
472	38969	8203
472	37889	10000
472	67941	8203
472	131532	10000
472	67898	8203
472	37893	10000
472	17276	8203
472	37981	10000
472	37112	8203
472	26741	10000
472	67959	8203
472	38231	10000
472	148286	8203
472	131530	10000
472	178291	8203
472	104377	10000
473	38318	9999
473	38341	10001
473	38349	10001
473	39848	10001
473	38247	9999
473	43049	10001
473	94288	9999
473	37953	10001
473	129278	9999
473	38343	10001
473	37945	9999
473	21834	10001
473	46217	9999
473	38778	10001
473	33671	9999
473	67896	10001
473	148336	9999
473	182605	10001
473	106369	9999
473	192907	10001
474	13131	9993
474	37990	8342
474	37988	9993
474	36832	8342
474	36849	9993
474	27508	8342
474	38322	9993
474	11736	8342
474	38800	9993
474	37858	8342
474	38784	9993
474	39578	8342
474	36868	9993
474	38366	8342
474	38786	9993
474	163670	8342
474	41106	9993
474	34025	8342
474	69629	9993
474	75405	8342
474	166676	9993
474	166575	8342
475	37990	8342
475	37971	8571
475	37983	8342
475	16387	8571
475	11736	8342
475	149279	8571
475	37858	8342
475	38249	8571
475	37963	8342
475	131404	8571
475	39578	8342
475	39859	8571
475	37979	8342
475	38257	8571
475	37967	8342
475	40521	8571
475	38366	8342
475	39772	8571
475	27423	8342
475	78902	8571
475	38440	8342
475	95615	8571
476	38797	9985
476	40014	9986
476	39580	9985
476	46890	9985
476	38417	9986
476	47411	9985
476	131409	9986
476	156551	9985
476	46666	9986
476	35412	9985
476	39631	9985
476	38423	9986
476	39591	9985
476	38439	9986
476	148335	9985
476	40520	9986
476	37262	9985
476	38920	9986
476	38369	9985
476	38419	9986
477	37868	9997
477	38318	9999
477	33595	9997
477	38247	9999
477	38347	9997
477	94288	9999
477	3329	9997
477	69805	9999
477	149150	9997
477	94284	9999
477	38354	9997
477	46217	9999
477	37866	9997
477	33671	9999
477	45490	9997
477	148336	9999
477	5016	9997
477	37945	9999
477	36836	9997
477	24037	9999
478	37900	10000
478	38391	8635
478	37886	10000
478	38388	8635
478	37100	10000
478	13423	8635
478	37903	10000
478	38389	8635
478	37889	10000
478	69713	8635
478	37902	10000
478	38798	8635
478	37981	10000
478	30949	8635
478	131531	10000
478	38383	8635
478	94030	10000
478	38393	8635
478	130027	10000
478	46552	8635
478	104377	10000
478	12692	8635
479	104378	9991
479	30934	9994
479	38337	9991
479	38292	9994
479	38255	9991
479	39594	9994
479	12473	9991
479	25465	9994
479	104382	9991
479	38273	9994
479	39875	9991
479	12099	9994
479	38233	9991
479	38945	9994
479	32760	9991
479	95609	9994
479	166618	9991
479	15662	9994
479	12574	9991
479	30485	9994
479	46335	9991
479	110140	9994
480	38341	10001
480	37937	9987
480	38349	10001
480	38785	9987
480	38343	10001
480	104411	9987
480	30404	10001
480	148314	9987
480	148313	9987
480	38348	10001
480	38435	9987
480	38332	10001
480	38293	9987
480	47410	10001
480	39498	9987
480	39848	10001
480	43158	9987
480	25619	10001
480	42153	9987
480	166584	10001
480	163674	9987
481	13131	9993
481	38327	8203
481	37988	9993
481	67950	8203
481	36849	9993
481	6800	8203
481	36845	9993
481	39389	8203
481	36868	9993
481	67941	8203
481	38371	9993
481	67898	8203
481	38784	9993
481	37112	8203
481	38380	9993
481	38969	8203
481	38786	9993
481	178291	8203
481	33622	9993
481	148286	8203
481	34334	9993
481	17276	8203
482	38391	8635
482	38797	9985
482	38388	8635
482	39580	9985
482	13423	8635
482	46890	9985
482	38389	8635
482	47411	9985
482	69713	8635
482	156551	9985
482	38798	8635
482	37262	9985
482	30949	8635
482	35412	9985
482	33620	8635
482	25957	9985
482	38383	8635
482	39631	9985
482	38253	8635
482	39591	9985
482	46552	8635
482	38369	9985
483	37937	9987
483	13131	9993
483	39498	9987
483	37988	9993
483	104411	9987
483	36849	9993
483	148314	9987
483	36845	9993
483	148313	9987
483	38322	9993
483	9307	9987
483	38371	9993
483	38435	9987
483	38784	9993
483	43158	9987
483	36868	9993
483	38794	9987
483	38786	9993
483	169200	9987
483	30910	9993
483	163674	9987
483	33622	9993
484	131403	9984
484	31226	8342
484	38342	9984
484	21812	8342
484	37047	9984
484	11736	8342
484	37021	9984
484	37858	8342
484	78462	9984
484	37963	8342
484	38357	9984
484	37979	8342
484	27110	9984
484	38336	8342
484	104386	9984
484	38366	8342
484	32863	9984
484	52280	8342
484	38251	9984
484	27423	8342
484	37909	9984
484	38440	8342
485	37971	8571
485	104378	9991
485	16387	8571
485	38337	9991
485	131404	8571
485	38255	9991
485	149279	8571
485	12473	9991
485	38441	8571
485	104382	9991
485	38249	8571
485	33662	9991
485	39859	8571
485	38233	9991
485	38257	8571
485	166618	9991
485	40521	8571
485	39875	9991
485	39772	8571
485	12574	9991
485	78902	8571
485	46335	9991
486	38327	8203
486	37868	9997
486	67950	8203
486	38354	9997
486	6800	8203
486	33595	9997
486	39389	8203
486	3329	9997
486	67941	8203
486	67898	8203
486	37866	9997
486	37112	8203
486	38347	9997
486	38969	8203
486	36836	9997
486	178291	8203
486	149150	9997
486	148286	8203
486	5016	9997
486	17276	8203
486	45490	9997
487	38318	9999
487	40014	9986
487	38247	9999
487	94288	9999
487	38417	9986
487	69805	9999
487	37571	9986
487	94284	9999
487	46666	9986
487	46217	9999
487	38423	9986
487	33671	9999
487	39145	9986
487	38439	9986
487	148336	9999
487	40520	9986
487	37945	9999
487	38920	9986
487	24037	9999
487	38419	9986
488	38341	10001
488	37900	10000
488	38349	10001
488	37886	10000
488	30404	10001
488	37903	10000
488	21834	10001
488	37889	10000
488	67896	10001
488	94030	10000
488	38343	10001
488	37981	10000
488	38348	10001
488	131531	10000
488	47410	10001
488	75500	10000
488	179058	10001
488	130027	10000
488	39848	10001
488	104377	10000
488	17883	10001
488	38231	10000
489	31226	8342
489	37937	9987
489	21812	8342
489	38785	9987
489	37858	8342
489	104411	9987
489	37963	8342
489	94462	9987
489	37983	8342
489	148314	9987
489	39578	8342
489	148313	9987
489	37979	8342
489	39498	9987
489	38366	8342
489	43158	9987
489	163670	8342
489	32863	9987
489	27423	8342
489	42153	9987
489	38440	8342
489	38794	9987
490	38797	9985
490	38327	8203
490	47411	9985
490	67950	8203
490	156551	9985
490	6800	8203
490	39389	8203
490	25995	9985
490	67941	8203
490	35412	9985
490	67898	8203
490	39580	9985
490	37112	8203
490	39631	9985
490	38969	8203
490	37262	9985
490	178291	8203
490	25957	9985
490	148286	8203
490	38369	9985
490	17276	8203
491	37868	9997
491	38391	8635
491	33595	9997
491	38388	8635
491	38347	9997
491	38389	8635
491	3329	9997
491	38253	8635
491	149150	9997
491	69713	8635
491	38354	9997
491	38798	8635
491	37866	9997
491	33620	8635
491	36836	9997
491	38383	8635
491	5016	9997
491	38393	8635
491	45490	9997
491	37069	8635
491	46552	8635
492	37900	10000
492	37971	8571
492	37886	10000
492	38441	8571
492	37100	10000
492	16387	8571
492	37903	10000
492	131404	8571
492	37889	10000
492	149279	8571
492	37902	10000
492	38249	8571
492	37981	10000
492	39859	8571
492	131531	10000
492	38257	8571
492	94030	10000
492	40521	8571
492	38231	10000
492	39772	8571
492	104377	10000
492	78902	8571
493	40014	9986
493	131403	9984
493	38342	9984
493	39977	9986
493	37047	9984
493	37571	9986
493	38186	9984
493	46666	9986
493	38789	9984
493	38423	9986
493	37957	9984
493	38439	9986
493	37909	9984
493	40520	9986
493	104386	9984
493	131409	9986
493	78462	9984
493	38920	9986
493	38357	9984
493	38419	9986
493	38782	9984
494	104378	9991
494	38318	9999
494	38337	9991
494	38247	9999
494	38255	9991
494	94288	9999
494	41109	9991
494	69805	9999
494	104382	9991
494	94284	9999
494	33662	9991
494	26669	9999
494	38233	9991
494	46217	9999
494	166618	9991
494	33671	9999
494	39875	9991
494	148336	9999
494	12574	9991
494	24037	9999
494	46335	9991
494	23997	9999
495	13131	9993
495	30934	9994
495	37988	9993
495	38292	9994
495	36849	9993
495	39594	9994
495	36845	9993
495	25465	9994
495	38322	9993
495	38273	9994
495	38371	9993
495	12099	9994
495	30910	9993
495	38945	9994
495	38784	9993
495	95609	9994
495	38786	9993
495	15662	9994
495	33622	9993
495	30485	9994
495	178284	9993
495	69629	9994
496	38391	8635
496	104378	9991
496	38388	8635
496	38337	9991
496	38389	8635
496	38255	9991
496	38253	8635
496	12473	9991
496	69713	8635
496	104382	9991
496	33620	8635
496	33662	9991
496	38383	8635
496	41109	9991
496	38393	8635
496	166618	9991
496	148302	8635
496	38233	9991
496	46552	8635
496	12574	9991
496	181276	8635
496	46335	9991
497	37937	9987
497	40014	9986
497	104411	9987
497	39977	9986
497	94462	9987
497	37571	9986
497	148314	9987
497	46666	9986
497	148313	9987
497	38423	9986
497	32863	9987
497	38439	9986
497	39498	9987
497	40520	9986
497	43158	9987
497	131409	9986
497	42153	9987
497	25636	9986
497	163674	9987
497	38920	9986
498	131403	9984
498	13131	9993
498	38342	9984
498	37988	9993
498	37047	9984
498	36849	9993
498	38789	9984
498	36845	9993
498	38186	9984
498	38322	9993
498	37957	9984
498	38371	9993
498	37909	9984
498	36852	9993
498	104386	9984
498	38784	9993
498	78462	9984
498	38786	9993
498	38357	9984
498	33622	9993
498	38782	9984
498	178284	9993
499	30934	9994
499	38797	9985
499	38292	9994
499	25995	9985
499	39594	9994
499	39580	9985
499	25465	9994
499	129462	9985
499	15425	9994
499	47411	9985
499	38945	9994
499	35412	9985
499	38290	9994
499	25957	9985
499	95609	9994
499	148335	9985
499	15662	9994
499	156551	9985
499	34334	9994
499	178484	9985
499	69629	9994
499	38369	9985
500	37971	8571
500	37868	9997
500	39859	8571
500	33595	9997
500	38441	8571
500	38347	9997
500	16387	8571
500	3329	9997
500	131404	8571
500	149150	9997
500	38249	8571
500	38354	9997
500	38257	8571
500	37866	9997
500	40521	8571
500	36836	9997
500	149279	8571
500	39772	8571
500	5016	9997
500	78902	8571
500	45490	9997
215	37900	8571
\.


--
-- Data for Name: league; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.league (name, country) FROM stdin;
Belgium Jupiler League	Belgium
\.


--
-- Data for Name: match; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.match (id, date, stage, season, home, away, home_goal, away_goal, league, dbuser) FROM stdin;
1	2008-08-17	1	2008/2009	9987	9993	1	1	Belgium Jupiler League	2
2	2008-08-16	1	2008/2009	10000	9994	0	0	Belgium Jupiler League	2
3	2008-08-16	1	2008/2009	9984	8635	0	3	Belgium Jupiler League	2
4	2008-08-17	1	2008/2009	9991	9998	5	0	Belgium Jupiler League	2
5	2008-08-16	1	2008/2009	7947	9985	1	3	Belgium Jupiler League	2
6	2008-09-24	1	2008/2009	8203	8342	1	1	Belgium Jupiler League	2
7	2008-08-16	1	2008/2009	9999	8571	2	2	Belgium Jupiler League	2
8	2008-08-16	1	2008/2009	4049	9996	1	2	Belgium Jupiler League	2
9	2008-08-16	1	2008/2009	10001	9986	1	0	Belgium Jupiler League	2
10	2008-11-01	10	2008/2009	8342	8571	4	1	Belgium Jupiler League	2
11	2008-10-31	10	2008/2009	9985	9986	1	2	Belgium Jupiler League	2
12	2008-11-02	10	2008/2009	10000	9991	0	2	Belgium Jupiler League	2
13	2008-11-01	10	2008/2009	9994	9998	0	0	Belgium Jupiler League	2
14	2008-11-01	10	2008/2009	7947	10001	2	2	Belgium Jupiler League	2
15	2008-11-01	10	2008/2009	8203	9999	1	2	Belgium Jupiler League	2
16	2008-11-01	10	2008/2009	9996	9984	0	1	Belgium Jupiler League	2
17	2008-11-01	10	2008/2009	4049	9987	1	3	Belgium Jupiler League	2
18	2008-11-02	10	2008/2009	9993	8635	1	3	Belgium Jupiler League	2
19	2008-11-08	11	2008/2009	8635	9994	2	3	Belgium Jupiler League	2
20	2008-11-08	11	2008/2009	9998	9996	0	0	Belgium Jupiler League	2
21	2008-11-09	11	2008/2009	9986	8342	2	2	Belgium Jupiler League	2
22	2008-11-07	11	2008/2009	9984	10000	2	0	Belgium Jupiler League	2
23	2008-11-08	11	2008/2009	9991	7947	1	1	Belgium Jupiler League	2
24	2008-11-08	11	2008/2009	9999	4049	1	2	Belgium Jupiler League	2
25	2008-11-08	11	2008/2009	8571	8203	0	0	Belgium Jupiler League	2
26	2008-11-08	11	2008/2009	10001	9987	1	0	Belgium Jupiler League	2
27	2008-11-09	11	2008/2009	9993	9985	1	3	Belgium Jupiler League	2
28	2008-11-16	12	2008/2009	8342	8635	1	1	Belgium Jupiler League	2
29	2008-11-15	12	2008/2009	9987	9999	1	1	Belgium Jupiler League	2
30	2008-11-15	12	2008/2009	10000	9993	2	2	Belgium Jupiler League	2
31	2008-11-16	12	2008/2009	9994	9985	1	1	Belgium Jupiler League	2
32	2008-11-15	12	2008/2009	7947	8571	1	0	Belgium Jupiler League	2
33	2008-11-15	12	2008/2009	8203	9998	0	0	Belgium Jupiler League	2
34	2008-11-15	12	2008/2009	9996	9986	2	1	Belgium Jupiler League	2
35	2008-11-15	12	2008/2009	4049	9984	3	0	Belgium Jupiler League	2
36	2008-11-14	12	2008/2009	10001	9991	3	2	Belgium Jupiler League	2
37	2008-11-22	13	2008/2009	8635	10001	2	0	Belgium Jupiler League	2
38	2008-11-22	13	2008/2009	9985	9996	3	1	Belgium Jupiler League	2
39	2008-11-22	13	2008/2009	9998	8342	1	2	Belgium Jupiler League	2
40	2008-11-22	13	2008/2009	9986	4049	3	2	Belgium Jupiler League	2
41	2008-11-22	13	2008/2009	9984	8203	2	1	Belgium Jupiler League	2
42	2008-11-23	13	2008/2009	9991	9987	2	3	Belgium Jupiler League	2
43	2008-11-22	13	2008/2009	9999	7947	2	2	Belgium Jupiler League	2
44	2008-12-16	13	2008/2009	8571	10000	1	0	Belgium Jupiler League	2
45	2008-11-22	13	2008/2009	9993	9994	0	2	Belgium Jupiler League	2
46	2008-11-30	14	2008/2009	8342	9993	3	0	Belgium Jupiler League	2
47	2008-11-29	14	2008/2009	9987	9984	3	2	Belgium Jupiler League	2
48	2008-11-29	14	2008/2009	10000	9986	4	2	Belgium Jupiler League	2
49	2008-11-29	14	2008/2009	9991	9999	4	0	Belgium Jupiler League	2
50	2008-11-28	14	2008/2009	7947	8635	0	2	Belgium Jupiler League	2
51	2008-11-30	14	2008/2009	8203	9985	0	0	Belgium Jupiler League	2
52	2008-11-29	14	2008/2009	9996	9994	2	0	Belgium Jupiler League	2
53	2008-11-29	14	2008/2009	4049	8571	3	3	Belgium Jupiler League	2
54	2008-11-29	14	2008/2009	10001	9998	2	1	Belgium Jupiler League	2
55	2008-12-06	15	2008/2009	8635	4049	5	1	Belgium Jupiler League	2
56	2008-12-06	15	2008/2009	9985	10000	1	2	Belgium Jupiler League	2
57	2008-12-06	15	2008/2009	9998	7947	5	2	Belgium Jupiler League	2
58	2008-12-06	15	2008/2009	9986	8203	1	2	Belgium Jupiler League	2
59	2008-12-05	15	2008/2009	9984	9991	3	1	Belgium Jupiler League	2
60	2008-12-07	15	2008/2009	9994	8342	2	0	Belgium Jupiler League	2
61	2008-12-06	15	2008/2009	9999	10001	1	0	Belgium Jupiler League	2
62	2008-12-07	15	2008/2009	8571	9987	3	1	Belgium Jupiler League	2
63	2008-12-06	15	2008/2009	9993	9996	3	0	Belgium Jupiler League	2
64	2008-12-14	16	2008/2009	8342	9985	1	4	Belgium Jupiler League	2
65	2008-12-13	16	2008/2009	9987	9986	1	0	Belgium Jupiler League	2
66	2008-12-13	16	2008/2009	10000	9996	2	1	Belgium Jupiler League	2
67	2008-12-13	16	2008/2009	9991	8571	1	1	Belgium Jupiler League	2
68	2008-12-13	16	2008/2009	7947	9994	1	1	Belgium Jupiler League	2
69	2008-12-12	16	2008/2009	8203	9993	2	1	Belgium Jupiler League	2
70	2008-12-14	16	2008/2009	9999	8635	0	3	Belgium Jupiler League	2
71	2008-12-13	16	2008/2009	4049	9998	2	1	Belgium Jupiler League	2
72	2008-12-13	16	2008/2009	10001	9984	1	2	Belgium Jupiler League	2
73	2008-12-19	17	2008/2009	8635	9987	2	0	Belgium Jupiler League	2
74	2008-12-21	17	2008/2009	9985	9991	2	1	Belgium Jupiler League	2
75	2008-12-20	17	2008/2009	9998	10000	2	2	Belgium Jupiler League	2
76	2008-12-20	17	2008/2009	9986	7947	2	0	Belgium Jupiler League	2
77	2008-12-20	17	2008/2009	9984	9999	4	3	Belgium Jupiler League	2
78	2008-12-20	17	2008/2009	9994	8203	2	2	Belgium Jupiler League	2
79	2008-12-20	17	2008/2009	9996	8342	5	1	Belgium Jupiler League	2
80	2008-12-21	17	2008/2009	8571	10001	0	0	Belgium Jupiler League	2
81	2008-12-20	17	2008/2009	9993	4049	2	0	Belgium Jupiler League	2
82	2009-01-18	18	2008/2009	9993	9987	4	1	Belgium Jupiler League	2
83	2009-01-17	18	2008/2009	9994	10000	2	1	Belgium Jupiler League	2
84	2009-01-16	18	2008/2009	8635	9984	1	2	Belgium Jupiler League	2
85	2009-01-17	18	2008/2009	9998	9991	1	2	Belgium Jupiler League	2
86	2009-01-17	18	2008/2009	9985	7947	3	2	Belgium Jupiler League	2
87	2009-01-17	18	2008/2009	8342	8203	3	0	Belgium Jupiler League	2
88	2009-01-17	18	2008/2009	8571	9999	2	1	Belgium Jupiler League	2
89	2009-01-17	18	2008/2009	9996	4049	1	1	Belgium Jupiler League	2
90	2009-01-18	18	2008/2009	9986	10001	1	2	Belgium Jupiler League	2
91	2009-01-25	19	2008/2009	10000	8342	3	1	Belgium Jupiler League	2
92	2009-02-18	19	2008/2009	9991	8635	1	2	Belgium Jupiler League	2
93	2009-01-25	19	2008/2009	10001	9985	0	1	Belgium Jupiler League	2
94	2009-01-24	19	2008/2009	9987	9998	2	0	Belgium Jupiler League	2
95	2009-01-24	19	2008/2009	9999	9986	3	1	Belgium Jupiler League	2
96	2009-01-24	19	2008/2009	4049	9994	2	1	Belgium Jupiler League	2
97	2009-01-24	19	2008/2009	8203	9996	2	2	Belgium Jupiler League	2
98	2009-01-24	19	2008/2009	9984	8571	0	1	Belgium Jupiler League	2
99	2009-01-24	19	2008/2009	7947	9993	0	1	Belgium Jupiler League	2
100	2008-10-29	2	2008/2009	8342	10000	2	0	Belgium Jupiler League	2
101	2008-08-23	2	2008/2009	8635	9991	2	2	Belgium Jupiler League	2
102	2008-08-23	2	2008/2009	9985	10001	3	0	Belgium Jupiler League	2
103	2008-08-24	2	2008/2009	9998	9987	3	1	Belgium Jupiler League	2
104	2008-08-23	2	2008/2009	9986	9999	1	0	Belgium Jupiler League	2
105	2008-08-23	2	2008/2009	9994	4049	4	1	Belgium Jupiler League	2
106	2008-08-23	2	2008/2009	9996	8203	3	1	Belgium Jupiler League	2
107	2008-08-23	2	2008/2009	8571	9984	2	1	Belgium Jupiler League	2
108	2008-08-23	2	2008/2009	9993	7947	1	1	Belgium Jupiler League	2
109	2009-01-31	20	2008/2009	8571	8635	1	3	Belgium Jupiler League	2
110	2009-02-01	20	2008/2009	9994	9987	1	2	Belgium Jupiler League	2
111	2009-01-31	20	2008/2009	9998	9984	1	1	Belgium Jupiler League	2
112	2009-02-01	20	2008/2009	9986	9991	2	5	Belgium Jupiler League	2
113	2009-01-31	20	2008/2009	9996	7947	0	2	Belgium Jupiler League	2
114	2009-01-31	20	2008/2009	10000	8203	1	1	Belgium Jupiler League	2
115	2009-01-31	20	2008/2009	9985	9999	3	0	Belgium Jupiler League	2
116	2009-01-31	20	2008/2009	8342	4049	3	1	Belgium Jupiler League	2
117	2009-01-31	20	2008/2009	9993	10001	2	1	Belgium Jupiler League	2
118	2009-02-07	21	2008/2009	7947	8342	0	2	Belgium Jupiler League	2
119	2009-02-06	21	2008/2009	8571	9985	0	2	Belgium Jupiler League	2
120	2009-02-07	21	2008/2009	8635	9998	3	2	Belgium Jupiler League	2
121	2009-02-07	21	2008/2009	9987	10000	1	2	Belgium Jupiler League	2
122	2009-02-08	21	2008/2009	9984	9986	2	2	Belgium Jupiler League	2
123	2009-02-08	21	2008/2009	10001	9994	1	0	Belgium Jupiler League	2
124	2009-02-07	21	2008/2009	4049	8203	1	5	Belgium Jupiler League	2
125	2009-02-07	21	2008/2009	9991	9996	2	0	Belgium Jupiler League	2
126	2009-02-07	21	2008/2009	9999	9993	2	2	Belgium Jupiler League	2
127	2009-02-15	22	2008/2009	9986	8635	0	1	Belgium Jupiler League	2
128	2009-02-15	22	2008/2009	8342	9987	0	2	Belgium Jupiler League	2
129	2009-02-14	22	2008/2009	9993	9984	1	1	Belgium Jupiler League	2
130	2009-02-14	22	2008/2009	8203	9991	3	3	Belgium Jupiler League	2
131	2009-02-14	22	2008/2009	10000	7947	1	0	Belgium Jupiler League	2
132	2009-02-14	22	2008/2009	9994	9999	2	1	Belgium Jupiler League	2
133	2009-02-14	22	2008/2009	9998	8571	1	1	Belgium Jupiler League	2
134	2009-02-14	22	2008/2009	9985	4049	4	0	Belgium Jupiler League	2
135	2009-02-14	22	2008/2009	9996	10001	0	0	Belgium Jupiler League	2
136	2009-02-22	23	2008/2009	10001	8342	1	1	Belgium Jupiler League	2
137	2009-02-22	23	2008/2009	8635	9985	4	2	Belgium Jupiler League	2
138	2009-02-21	23	2008/2009	9999	9998	3	2	Belgium Jupiler League	2
139	2009-02-21	23	2008/2009	4049	10000	0	6	Belgium Jupiler League	2
140	2009-02-21	23	2008/2009	8571	9986	1	1	Belgium Jupiler League	2
141	2009-02-21	23	2008/2009	9984	9994	0	0	Belgium Jupiler League	2
142	2009-02-21	23	2008/2009	7947	8203	1	2	Belgium Jupiler League	2
143	2009-02-20	23	2008/2009	9987	9996	1	1	Belgium Jupiler League	2
144	2009-02-21	23	2008/2009	9991	9993	1	3	Belgium Jupiler League	2
145	2009-02-28	24	2008/2009	9996	8635	1	1	Belgium Jupiler League	2
146	2009-02-27	24	2008/2009	8203	9987	2	1	Belgium Jupiler League	2
147	2009-02-28	24	2008/2009	9986	9998	3	0	Belgium Jupiler League	2
148	2009-03-01	24	2008/2009	9985	9984	4	0	Belgium Jupiler League	2
149	2009-03-01	24	2008/2009	9994	9991	0	1	Belgium Jupiler League	2
150	2009-02-28	24	2008/2009	8342	9999	2	1	Belgium Jupiler League	2
151	2009-02-28	24	2008/2009	9993	8571	3	0	Belgium Jupiler League	2
152	2009-02-28	24	2008/2009	7947	4049	4	0	Belgium Jupiler League	2
153	2009-02-28	24	2008/2009	10000	10001	1	1	Belgium Jupiler League	2
154	2009-03-08	25	2008/2009	9984	8342	1	3	Belgium Jupiler League	2
155	2009-03-06	25	2008/2009	9998	9985	0	1	Belgium Jupiler League	2
156	2009-03-07	25	2008/2009	8635	10000	2	0	Belgium Jupiler League	2
157	2009-03-07	25	2008/2009	8571	9994	2	3	Belgium Jupiler League	2
158	2009-03-07	25	2008/2009	9987	7947	4	3	Belgium Jupiler League	2
159	2009-03-08	25	2008/2009	10001	8203	0	1	Belgium Jupiler League	2
160	2009-03-07	25	2008/2009	9999	9996	2	0	Belgium Jupiler League	2
161	2009-03-07	25	2008/2009	9991	4049	2	0	Belgium Jupiler League	2
162	2009-03-07	25	2008/2009	9986	9993	0	0	Belgium Jupiler League	2
163	2009-03-13	26	2008/2009	8203	8635	2	1	Belgium Jupiler League	2
164	2009-03-15	26	2008/2009	9985	9987	2	0	Belgium Jupiler League	2
165	2009-03-14	26	2008/2009	9993	9998	2	0	Belgium Jupiler League	2
166	2009-03-14	26	2008/2009	9994	9986	0	0	Belgium Jupiler League	2
167	2009-03-14	26	2008/2009	7947	9984	1	0	Belgium Jupiler League	2
168	2009-03-15	26	2008/2009	8342	9991	1	4	Belgium Jupiler League	2
169	2009-03-14	26	2008/2009	10000	9999	0	0	Belgium Jupiler League	2
170	2009-03-14	26	2008/2009	9996	8571	1	0	Belgium Jupiler League	2
171	2009-03-14	26	2008/2009	4049	10001	1	2	Belgium Jupiler League	2
172	2009-03-20	27	2008/2009	8571	8342	2	3	Belgium Jupiler League	2
173	2009-03-22	27	2008/2009	9986	9985	1	0	Belgium Jupiler League	2
174	2009-03-22	27	2008/2009	9991	10000	1	0	Belgium Jupiler League	2
175	2009-03-21	27	2008/2009	9998	9994	0	2	Belgium Jupiler League	2
176	2009-03-21	27	2008/2009	10001	7947	3	1	Belgium Jupiler League	2
177	2009-03-21	27	2008/2009	9999	8203	1	0	Belgium Jupiler League	2
178	2009-03-21	27	2008/2009	9984	9996	0	1	Belgium Jupiler League	2
179	2009-03-21	27	2008/2009	9987	4049	3	0	Belgium Jupiler League	2
180	2009-03-21	27	2008/2009	8635	9993	2	0	Belgium Jupiler League	2
181	2009-04-05	28	2008/2009	9994	8635	0	0	Belgium Jupiler League	2
182	2009-04-04	28	2008/2009	9996	9998	3	2	Belgium Jupiler League	2
183	2009-04-04	28	2008/2009	8342	9986	2	1	Belgium Jupiler League	2
184	2009-04-04	28	2008/2009	10000	9984	3	1	Belgium Jupiler League	2
185	2009-04-04	28	2008/2009	7947	9991	1	1	Belgium Jupiler League	2
186	2009-04-04	28	2008/2009	4049	9999	0	1	Belgium Jupiler League	2
187	2009-04-04	28	2008/2009	8203	8571	1	1	Belgium Jupiler League	2
188	2009-04-04	28	2008/2009	9987	10001	1	4	Belgium Jupiler League	2
189	2009-04-05	28	2008/2009	9985	9993	3	1	Belgium Jupiler League	2
190	2009-04-12	29	2008/2009	8635	8342	1	0	Belgium Jupiler League	2
191	2009-04-10	29	2008/2009	9999	9987	1	0	Belgium Jupiler League	2
192	2009-04-11	29	2008/2009	9993	10000	1	2	Belgium Jupiler League	2
193	2009-04-11	29	2008/2009	9985	9994	1	0	Belgium Jupiler League	2
194	2009-04-11	29	2008/2009	8571	7947	1	2	Belgium Jupiler League	2
195	2009-04-11	29	2008/2009	9998	8203	0	1	Belgium Jupiler League	2
196	2009-04-11	29	2008/2009	9986	9996	1	0	Belgium Jupiler League	2
197	2009-04-11	29	2008/2009	9984	4049	4	1	Belgium Jupiler League	2
198	2009-04-12	29	2008/2009	9991	10001	2	0	Belgium Jupiler League	2
199	2008-08-30	3	2008/2009	8635	8571	4	0	Belgium Jupiler League	2
200	2008-08-30	3	2008/2009	9987	9994	1	0	Belgium Jupiler League	2
201	2008-08-30	3	2008/2009	9984	9998	2	1	Belgium Jupiler League	2
202	2008-08-31	3	2008/2009	9991	9986	2	0	Belgium Jupiler League	2
203	2008-08-30	3	2008/2009	7947	9996	1	2	Belgium Jupiler League	2
204	2008-08-30	3	2008/2009	8203	10000	0	2	Belgium Jupiler League	2
205	2008-08-31	3	2008/2009	9999	9985	1	1	Belgium Jupiler League	2
206	2008-08-29	3	2008/2009	4049	8342	1	4	Belgium Jupiler League	2
207	2008-08-30	3	2008/2009	10001	9993	1	0	Belgium Jupiler League	2
208	2009-04-19	30	2008/2009	10001	8635	0	1	Belgium Jupiler League	2
209	2009-04-18	30	2008/2009	9996	9985	0	3	Belgium Jupiler League	2
210	2009-04-18	30	2008/2009	8342	9998	3	2	Belgium Jupiler League	2
211	2009-04-18	30	2008/2009	4049	9986	3	1	Belgium Jupiler League	2
212	2009-04-18	30	2008/2009	8203	9984	0	1	Belgium Jupiler League	2
213	2009-04-17	30	2008/2009	9987	9991	2	2	Belgium Jupiler League	2
214	2009-04-19	30	2008/2009	7947	9999	3	1	Belgium Jupiler League	2
215	2009-04-18	30	2008/2009	10000	8571	5	1	Belgium Jupiler League	2
216	2009-04-18	30	2008/2009	9994	9993	1	0	Belgium Jupiler League	2
217	2009-04-24	31	2008/2009	9993	8342	2	0	Belgium Jupiler League	2
218	2009-04-26	31	2008/2009	9984	9987	1	2	Belgium Jupiler League	2
219	2009-04-25	31	2008/2009	9986	10000	1	0	Belgium Jupiler League	2
220	2009-04-26	31	2008/2009	9999	9991	1	3	Belgium Jupiler League	2
221	2009-04-25	31	2008/2009	8635	7947	4	0	Belgium Jupiler League	2
222	2009-04-25	31	2008/2009	9985	8203	4	1	Belgium Jupiler League	2
223	2009-04-25	31	2008/2009	9994	9996	3	0	Belgium Jupiler League	2
224	2009-04-25	31	2008/2009	8571	4049	2	2	Belgium Jupiler League	2
225	2009-04-25	31	2008/2009	9998	10001	0	2	Belgium Jupiler League	2
226	2009-05-03	32	2008/2009	4049	8635	1	1	Belgium Jupiler League	2
227	2009-05-02	32	2008/2009	10000	9985	0	0	Belgium Jupiler League	2
228	2009-05-02	32	2008/2009	7947	9998	0	0	Belgium Jupiler League	2
229	2009-05-02	32	2008/2009	8203	9986	2	1	Belgium Jupiler League	2
230	2009-05-02	32	2008/2009	9991	9984	2	1	Belgium Jupiler League	2
231	2009-05-01	32	2008/2009	8342	9994	2	3	Belgium Jupiler League	2
232	2009-05-02	32	2008/2009	10001	9999	1	0	Belgium Jupiler League	2
233	2009-05-03	32	2008/2009	9987	8571	0	1	Belgium Jupiler League	2
234	2009-05-02	32	2008/2009	9996	9993	3	1	Belgium Jupiler League	2
235	2009-05-09	33	2008/2009	9985	8342	2	0	Belgium Jupiler League	2
236	2009-05-09	33	2008/2009	9986	9987	3	0	Belgium Jupiler League	2
237	2009-05-09	33	2008/2009	9996	10000	0	2	Belgium Jupiler League	2
238	2009-05-09	33	2008/2009	8571	9991	0	2	Belgium Jupiler League	2
239	2009-05-09	33	2008/2009	9994	7947	0	2	Belgium Jupiler League	2
240	2009-05-08	33	2008/2009	9993	8203	3	1	Belgium Jupiler League	2
241	2009-05-09	33	2008/2009	8635	9999	3	1	Belgium Jupiler League	2
242	2009-05-09	33	2008/2009	9998	4049	1	1	Belgium Jupiler League	2
243	2009-05-09	33	2008/2009	9984	10001	2	1	Belgium Jupiler League	2
244	2009-05-16	34	2008/2009	9987	8635	0	2	Belgium Jupiler League	2
245	2009-05-16	34	2008/2009	9991	9985	0	1	Belgium Jupiler League	2
246	2009-05-16	34	2008/2009	10000	9998	3	0	Belgium Jupiler League	2
247	2009-05-16	34	2008/2009	7947	9986	1	2	Belgium Jupiler League	2
248	2009-05-16	34	2008/2009	9999	9984	1	2	Belgium Jupiler League	2
249	2009-05-15	34	2008/2009	8203	9994	3	0	Belgium Jupiler League	2
250	2009-05-16	34	2008/2009	8342	9996	4	1	Belgium Jupiler League	2
251	2009-05-16	34	2008/2009	10001	8571	1	3	Belgium Jupiler League	2
252	2009-05-16	34	2008/2009	4049	9993	1	0	Belgium Jupiler League	2
253	2008-09-13	4	2008/2009	8342	7947	1	1	Belgium Jupiler League	2
254	2008-09-13	4	2008/2009	9985	8571	2	0	Belgium Jupiler League	2
255	2008-09-13	4	2008/2009	9998	8635	1	2	Belgium Jupiler League	2
256	2008-09-14	4	2008/2009	10000	9987	1	3	Belgium Jupiler League	2
257	2008-09-14	4	2008/2009	9986	9984	3	2	Belgium Jupiler League	2
258	2008-09-13	4	2008/2009	9994	10001	1	1	Belgium Jupiler League	2
259	2008-09-13	4	2008/2009	8203	4049	0	0	Belgium Jupiler League	2
260	2008-09-13	4	2008/2009	9996	9991	4	2	Belgium Jupiler League	2
261	2008-09-13	4	2008/2009	9993	9999	3	0	Belgium Jupiler League	2
262	2008-09-19	5	2008/2009	8635	9986	2	0	Belgium Jupiler League	2
263	2008-09-21	5	2008/2009	9987	8342	0	1	Belgium Jupiler League	2
264	2008-09-20	5	2008/2009	9984	9993	1	0	Belgium Jupiler League	2
265	2008-09-20	5	2008/2009	9991	8203	1	2	Belgium Jupiler League	2
266	2008-09-20	5	2008/2009	7947	10000	2	0	Belgium Jupiler League	2
267	2008-09-20	5	2008/2009	9999	9994	0	1	Belgium Jupiler League	2
268	2008-09-20	5	2008/2009	8571	9998	1	0	Belgium Jupiler League	2
269	2008-09-21	5	2008/2009	4049	9985	0	1	Belgium Jupiler League	2
270	2008-09-20	5	2008/2009	10001	9996	0	0	Belgium Jupiler League	2
271	2008-09-27	6	2008/2009	8342	10001	2	0	Belgium Jupiler League	2
272	2008-09-26	6	2008/2009	9985	8635	2	1	Belgium Jupiler League	2
273	2008-09-27	6	2008/2009	9998	9999	2	0	Belgium Jupiler League	2
274	2008-09-27	6	2008/2009	10000	4049	1	0	Belgium Jupiler League	2
275	2008-09-27	6	2008/2009	9986	8571	1	2	Belgium Jupiler League	2
276	2008-09-27	6	2008/2009	9994	9984	1	1	Belgium Jupiler League	2
277	2008-09-29	6	2008/2009	8203	7947	4	1	Belgium Jupiler League	2
278	2008-09-28	6	2008/2009	9996	9987	1	2	Belgium Jupiler League	2
279	2008-09-28	6	2008/2009	9993	9991	2	2	Belgium Jupiler League	2
280	2008-10-03	7	2008/2009	8635	9996	2	1	Belgium Jupiler League	2
281	2008-10-04	7	2008/2009	9987	8203	2	1	Belgium Jupiler League	2
282	2008-10-04	7	2008/2009	9998	9986	1	1	Belgium Jupiler League	2
283	2008-10-05	7	2008/2009	9984	9985	4	1	Belgium Jupiler League	2
284	2008-10-04	7	2008/2009	9991	9994	1	1	Belgium Jupiler League	2
285	2008-10-05	7	2008/2009	9999	8342	0	1	Belgium Jupiler League	2
286	2008-10-04	7	2008/2009	8571	9993	0	0	Belgium Jupiler League	2
287	2008-10-04	7	2008/2009	4049	7947	2	1	Belgium Jupiler League	2
288	2008-10-04	7	2008/2009	10001	10000	3	2	Belgium Jupiler League	2
289	2008-10-19	8	2008/2009	8342	9984	3	1	Belgium Jupiler League	2
290	2008-10-18	8	2008/2009	9985	9998	2	1	Belgium Jupiler League	2
291	2008-10-19	8	2008/2009	10000	8635	4	0	Belgium Jupiler League	2
292	2008-10-18	8	2008/2009	9994	8571	2	0	Belgium Jupiler League	2
293	2008-10-18	8	2008/2009	7947	9987	2	4	Belgium Jupiler League	2
294	2008-10-18	8	2008/2009	8203	10001	1	3	Belgium Jupiler League	2
295	2008-10-18	8	2008/2009	9996	9999	2	0	Belgium Jupiler League	2
296	2008-10-18	8	2008/2009	4049	9991	0	1	Belgium Jupiler League	2
297	2008-10-18	8	2008/2009	9993	9986	1	2	Belgium Jupiler League	2
298	2008-10-25	9	2008/2009	8635	8203	7	1	Belgium Jupiler League	2
299	2008-10-26	9	2008/2009	9987	9985	0	0	Belgium Jupiler League	2
300	2008-10-25	9	2008/2009	9998	9993	0	0	Belgium Jupiler League	2
301	2008-10-25	9	2008/2009	9986	9994	1	1	Belgium Jupiler League	2
302	2008-10-25	9	2008/2009	9984	7947	1	2	Belgium Jupiler League	2
303	2008-10-26	9	2008/2009	9991	8342	3	0	Belgium Jupiler League	2
304	2008-10-25	9	2008/2009	9999	10000	0	3	Belgium Jupiler League	2
305	2008-10-24	9	2008/2009	8571	9996	2	2	Belgium Jupiler League	2
306	2008-10-25	9	2008/2009	10001	4049	4	1	Belgium Jupiler League	2
307	2009-07-31	1	2009/2010	9985	9997	2	2	Belgium Jupiler League	2
308	2009-08-02	1	2009/2010	9986	8342	1	2	Belgium Jupiler League	2
309	2009-08-02	1	2009/2010	9984	9991	1	3	Belgium Jupiler League	2
310	2009-08-01	1	2009/2010	9994	10000	1	1	Belgium Jupiler League	2
311	2009-08-01	1	2009/2010	8571	8635	0	2	Belgium Jupiler League	2
312	2009-08-01	1	2009/2010	8203	10001	4	1	Belgium Jupiler League	2
313	2009-08-01	1	2009/2010	9999	9993	1	1	Belgium Jupiler League	2
314	2009-10-04	10	2009/2010	8342	8635	4	2	Belgium Jupiler League	2
315	2009-10-04	10	2009/2010	9985	9987	1	0	Belgium Jupiler League	2
316	2009-10-03	10	2009/2010	9997	10000	1	2	Belgium Jupiler League	2
317	2009-10-03	10	2009/2010	9986	8571	3	3	Belgium Jupiler League	2
318	2009-10-03	10	2009/2010	8203	9994	2	0	Belgium Jupiler League	2
319	2009-10-03	10	2009/2010	9999	9984	3	2	Belgium Jupiler League	2
320	2009-10-03	10	2009/2010	9993	10001	3	1	Belgium Jupiler League	2
321	2009-10-18	11	2009/2010	8342	9991	1	0	Belgium Jupiler League	2
322	2009-10-17	11	2009/2010	8635	9986	2	0	Belgium Jupiler League	2
323	2009-10-18	11	2009/2010	9987	8203	1	2	Belgium Jupiler League	2
324	2009-10-17	11	2009/2010	10000	9993	4	0	Belgium Jupiler League	2
325	2009-10-17	11	2009/2010	9994	9984	1	1	Belgium Jupiler League	2
326	2009-10-17	11	2009/2010	8571	9999	2	0	Belgium Jupiler League	2
327	2009-10-17	11	2009/2010	10001	9985	2	0	Belgium Jupiler League	2
328	2009-10-24	12	2009/2010	9985	10000	1	1	Belgium Jupiler League	2
329	2009-10-24	12	2009/2010	9997	9991	1	2	Belgium Jupiler League	2
330	2009-10-24	12	2009/2010	9986	10001	1	1	Belgium Jupiler League	2
331	2009-10-24	12	2009/2010	9984	8571	1	1	Belgium Jupiler League	2
332	2009-10-23	12	2009/2010	9994	9987	0	2	Belgium Jupiler League	2
333	2009-10-25	12	2009/2010	8203	8635	0	2	Belgium Jupiler League	2
334	2009-10-25	12	2009/2010	9999	8342	2	3	Belgium Jupiler League	2
335	2009-10-31	13	2009/2010	8342	9997	1	0	Belgium Jupiler League	2
336	2009-10-31	13	2009/2010	8635	9994	2	0	Belgium Jupiler League	2
337	2009-11-02	13	2009/2010	9987	9984	2	0	Belgium Jupiler League	2
338	2009-10-31	13	2009/2010	10000	9986	2	2	Belgium Jupiler League	2
339	2009-11-01	13	2009/2010	9991	9993	0	1	Belgium Jupiler League	2
340	2009-10-31	13	2009/2010	8571	8203	2	0	Belgium Jupiler League	2
341	2009-10-31	13	2009/2010	10001	9999	2	2	Belgium Jupiler League	2
342	2009-11-08	14	2009/2010	9985	8342	3	1	Belgium Jupiler League	2
343	2009-11-08	14	2009/2010	9987	8635	0	2	Belgium Jupiler League	2
344	2009-11-06	14	2009/2010	9986	9991	0	2	Belgium Jupiler League	2
345	2009-11-07	14	2009/2010	9984	10001	2	1	Belgium Jupiler League	2
346	2009-11-07	14	2009/2010	9994	8571	0	0	Belgium Jupiler League	2
347	2009-11-07	14	2009/2010	9999	10000	2	0	Belgium Jupiler League	2
348	2009-11-07	14	2009/2010	9993	9997	4	1	Belgium Jupiler League	2
349	2009-11-21	15	2009/2010	8342	9993	1	2	Belgium Jupiler League	2
350	2009-11-21	15	2009/2010	8635	9999	3	1	Belgium Jupiler League	2
351	2009-11-21	15	2009/2010	9997	9984	1	1	Belgium Jupiler League	2
352	2009-11-22	15	2009/2010	10000	8203	4	1	Belgium Jupiler League	2
353	2009-11-21	15	2009/2010	9991	9985	2	1	Belgium Jupiler League	2
354	2009-11-22	15	2009/2010	8571	9987	2	1	Belgium Jupiler League	2
355	2009-11-21	15	2009/2010	10001	9994	1	0	Belgium Jupiler League	2
356	2009-11-28	16	2009/2010	8342	9986	1	0	Belgium Jupiler League	2
357	2009-11-27	16	2009/2010	8635	8571	1	0	Belgium Jupiler League	2
358	2009-11-29	16	2009/2010	9997	9985	2	0	Belgium Jupiler League	2
359	2009-11-29	16	2009/2010	10000	9994	1	0	Belgium Jupiler League	2
360	2009-11-28	16	2009/2010	9991	9984	3	1	Belgium Jupiler League	2
361	2009-11-28	16	2009/2010	10001	8203	2	0	Belgium Jupiler League	2
362	2009-11-28	16	2009/2010	9993	9999	3	0	Belgium Jupiler League	2
363	2009-12-05	17	2009/2010	9985	9993	2	2	Belgium Jupiler League	2
364	2009-12-05	17	2009/2010	9987	10001	0	0	Belgium Jupiler League	2
365	2009-12-05	17	2009/2010	9986	9997	0	0	Belgium Jupiler League	2
366	2009-12-06	17	2009/2010	9984	8635	1	3	Belgium Jupiler League	2
367	2009-12-06	17	2009/2010	9994	8342	0	1	Belgium Jupiler League	2
368	2009-12-05	17	2009/2010	8571	10000	1	0	Belgium Jupiler League	2
369	2009-12-04	17	2009/2010	8203	9991	2	5	Belgium Jupiler League	2
370	2009-12-12	18	2009/2010	8342	8203	1	1	Belgium Jupiler League	2
371	2009-12-12	18	2009/2010	9985	9999	0	1	Belgium Jupiler League	2
372	2009-12-12	18	2009/2010	9997	8571	0	2	Belgium Jupiler League	2
373	2009-12-13	18	2009/2010	10000	9984	1	0	Belgium Jupiler League	2
374	2009-12-13	18	2009/2010	9991	9987	2	1	Belgium Jupiler League	2
375	2009-12-11	18	2009/2010	10001	8635	0	2	Belgium Jupiler League	2
376	2009-12-12	18	2009/2010	9993	9986	0	0	Belgium Jupiler League	2
377	2010-02-03	19	2009/2010	8635	8342	3	2	Belgium Jupiler League	2
378	2009-12-19	19	2009/2010	9987	10000	2	2	Belgium Jupiler League	2
379	2010-02-04	19	2009/2010	9986	9985	2	3	Belgium Jupiler League	2
380	2009-12-19	19	2009/2010	9994	9991	0	1	Belgium Jupiler League	2
381	2009-12-19	19	2009/2010	8571	10001	1	1	Belgium Jupiler League	2
382	2010-02-02	19	2009/2010	8203	9993	1	0	Belgium Jupiler League	2
383	2009-12-19	19	2009/2010	9999	9997	1	2	Belgium Jupiler League	2
384	2009-08-09	2	2009/2010	8342	9994	2	0	Belgium Jupiler League	2
385	2009-08-08	2	2009/2010	8635	9984	3	2	Belgium Jupiler League	2
386	2009-08-08	2	2009/2010	9997	9986	0	0	Belgium Jupiler League	2
387	2009-08-08	2	2009/2010	10000	9987	2	2	Belgium Jupiler League	2
388	2009-08-09	2	2009/2010	9991	8203	2	1	Belgium Jupiler League	2
389	2009-08-08	2	2009/2010	10001	8571	1	1	Belgium Jupiler League	2
390	2009-08-07	2	2009/2010	9993	9985	1	1	Belgium Jupiler League	2
391	2009-12-26	20	2009/2010	8342	9984	2	1	Belgium Jupiler League	2
392	2009-12-26	20	2009/2010	9985	9994	2	0	Belgium Jupiler League	2
393	2009-12-26	20	2009/2010	9997	8203	5	2	Belgium Jupiler League	2
394	2009-12-27	20	2009/2010	10000	10001	1	0	Belgium Jupiler League	2
395	2009-12-26	20	2009/2010	9986	9999	3	0	Belgium Jupiler League	2
396	2009-12-27	20	2009/2010	9991	8635	2	2	Belgium Jupiler League	2
397	2009-12-26	20	2009/2010	9993	9987	1	0	Belgium Jupiler League	2
398	2009-12-30	21	2009/2010	8635	10000	2	1	Belgium Jupiler League	2
399	2009-12-29	21	2009/2010	9987	9997	0	0	Belgium Jupiler League	2
400	2009-12-29	21	2009/2010	9984	9985	2	0	Belgium Jupiler League	2
401	2009-12-30	21	2009/2010	9994	9993	2	0	Belgium Jupiler League	2
402	2009-12-30	21	2009/2010	8571	8342	1	4	Belgium Jupiler League	2
403	2009-12-30	21	2009/2010	8203	9986	1	0	Belgium Jupiler League	2
404	2009-12-30	21	2009/2010	9999	9991	0	4	Belgium Jupiler League	2
405	2010-01-30	22	2009/2010	8342	10001	2	1	Belgium Jupiler League	2
406	2010-01-17	22	2009/2010	9985	8635	0	4	Belgium Jupiler League	2
407	2010-01-16	22	2009/2010	9997	9994	2	1	Belgium Jupiler League	2
408	2010-01-16	22	2009/2010	9986	9987	1	3	Belgium Jupiler League	2
409	2010-01-15	22	2009/2010	9991	8571	2	2	Belgium Jupiler League	2
410	2010-01-16	22	2009/2010	9999	8203	1	2	Belgium Jupiler League	2
411	2010-01-17	22	2009/2010	9993	9984	1	4	Belgium Jupiler League	2
412	2010-01-24	23	2009/2010	9987	8342	2	0	Belgium Jupiler League	2
413	2010-01-23	23	2009/2010	10000	9997	2	0	Belgium Jupiler League	2
414	2010-02-24	23	2009/2010	9984	9986	1	0	Belgium Jupiler League	2
415	2010-01-23	23	2009/2010	9994	9999	1	4	Belgium Jupiler League	2
416	2010-01-23	23	2009/2010	8571	9993	3	0	Belgium Jupiler League	2
417	2010-01-24	23	2009/2010	8203	9985	0	0	Belgium Jupiler League	2
418	2010-01-23	23	2009/2010	10001	9991	0	0	Belgium Jupiler League	2
419	2010-01-31	24	2009/2010	9985	8571	3	1	Belgium Jupiler League	2
420	2010-02-03	24	2009/2010	9997	10001	0	1	Belgium Jupiler League	2
421	2010-03-10	24	2009/2010	9986	9994	4	1	Belgium Jupiler League	2
422	2010-01-31	24	2009/2010	9991	10000	0	2	Belgium Jupiler League	2
423	2010-01-30	24	2009/2010	8203	9984	1	2	Belgium Jupiler League	2
424	2010-02-24	24	2009/2010	9999	9987	1	1	Belgium Jupiler League	2
425	2010-01-29	24	2009/2010	9993	8635	0	5	Belgium Jupiler League	2
426	2010-02-06	25	2009/2010	8635	9997	1	2	Belgium Jupiler League	2
427	2010-02-07	25	2009/2010	9987	9985	1	0	Belgium Jupiler League	2
428	2010-02-07	25	2009/2010	10000	8342	1	1	Belgium Jupiler League	2
429	2010-02-06	25	2009/2010	9984	9999	2	0	Belgium Jupiler League	2
430	2010-02-06	25	2009/2010	9994	8203	2	1	Belgium Jupiler League	2
431	2010-02-07	25	2009/2010	8571	9986	2	1	Belgium Jupiler League	2
432	2010-02-06	25	2009/2010	10001	9993	1	1	Belgium Jupiler League	2
433	2010-02-14	26	2009/2010	9985	10001	1	0	Belgium Jupiler League	2
434	2010-03-06	26	2009/2010	9986	8635	0	2	Belgium Jupiler League	2
435	2010-03-06	26	2009/2010	9984	9994	4	0	Belgium Jupiler League	2
436	2010-02-14	26	2009/2010	9991	8342	1	1	Belgium Jupiler League	2
437	2010-03-07	26	2009/2010	8203	9987	2	1	Belgium Jupiler League	2
438	2010-02-13	26	2009/2010	9999	8571	0	2	Belgium Jupiler League	2
439	2010-03-07	26	2009/2010	9993	10000	1	1	Belgium Jupiler League	2
440	2010-02-21	27	2009/2010	8342	9985	2	1	Belgium Jupiler League	2
441	2010-02-21	27	2009/2010	8635	8203	2	0	Belgium Jupiler League	2
442	2010-02-19	27	2009/2010	9987	9994	3	1	Belgium Jupiler League	2
443	2010-02-20	27	2009/2010	10000	9999	1	1	Belgium Jupiler League	2
444	2010-02-20	27	2009/2010	9991	9997	0	1	Belgium Jupiler League	2
445	2010-02-20	27	2009/2010	8571	9984	3	1	Belgium Jupiler League	2
446	2010-02-20	27	2009/2010	10001	9986	4	0	Belgium Jupiler League	2
447	2010-02-28	28	2009/2010	9997	8342	1	1	Belgium Jupiler League	2
448	2010-02-28	28	2009/2010	9986	10000	0	0	Belgium Jupiler League	2
449	2010-02-27	28	2009/2010	9984	9987	1	0	Belgium Jupiler League	2
450	2010-02-27	28	2009/2010	9994	10001	1	0	Belgium Jupiler League	2
451	2010-02-27	28	2009/2010	8203	8571	1	1	Belgium Jupiler League	2
452	2010-02-28	28	2009/2010	9999	8635	1	2	Belgium Jupiler League	2
453	2010-02-26	28	2009/2010	9993	9991	1	1	Belgium Jupiler League	2
454	2010-03-14	29	2009/2010	8342	9999	1	0	Belgium Jupiler League	2
455	2010-03-14	29	2009/2010	8635	9987	2	0	Belgium Jupiler League	2
456	2010-03-14	29	2009/2010	9997	9993	2	0	Belgium Jupiler League	2
457	2010-03-14	29	2009/2010	10000	9985	1	1	Belgium Jupiler League	2
458	2010-03-14	29	2009/2010	9991	9986	2	1	Belgium Jupiler League	2
459	2010-03-14	29	2009/2010	8571	9994	3	1	Belgium Jupiler League	2
460	2010-03-14	29	2009/2010	10001	9984	2	1	Belgium Jupiler League	2
461	2009-08-15	3	2009/2010	8635	10001	3	0	Belgium Jupiler League	2
462	2009-08-15	3	2009/2010	9987	9991	1	1	Belgium Jupiler League	2
463	2009-08-16	3	2009/2010	9986	9993	1	0	Belgium Jupiler League	2
464	2009-08-15	3	2009/2010	9984	10000	2	2	Belgium Jupiler League	2
465	2009-08-15	3	2009/2010	9994	9997	1	2	Belgium Jupiler League	2
466	2009-08-15	3	2009/2010	8203	8342	2	1	Belgium Jupiler League	2
467	2009-08-15	3	2009/2010	9999	9985	1	5	Belgium Jupiler League	2
468	2010-03-21	30	2009/2010	9985	9991	0	2	Belgium Jupiler League	2
469	2010-03-21	30	2009/2010	9987	8571	1	1	Belgium Jupiler League	2
470	2010-03-21	30	2009/2010	9984	9997	3	1	Belgium Jupiler League	2
471	2010-03-21	30	2009/2010	9994	8635	0	4	Belgium Jupiler League	2
472	2010-03-21	30	2009/2010	8203	10000	2	1	Belgium Jupiler League	2
473	2010-03-21	30	2009/2010	9999	10001	0	0	Belgium Jupiler League	2
474	2010-03-21	30	2009/2010	9993	8342	1	4	Belgium Jupiler League	2
475	2009-08-23	4	2009/2010	8342	8571	2	2	Belgium Jupiler League	2
476	2009-08-21	4	2009/2010	9985	9986	1	1	Belgium Jupiler League	2
477	2009-08-22	4	2009/2010	9997	9999	2	1	Belgium Jupiler League	2
478	2009-08-22	4	2009/2010	10000	8635	0	2	Belgium Jupiler League	2
479	2009-08-22	4	2009/2010	9991	9994	4	1	Belgium Jupiler League	2
480	2009-08-23	4	2009/2010	10001	9987	0	1	Belgium Jupiler League	2
481	2009-08-22	4	2009/2010	9993	8203	1	3	Belgium Jupiler League	2
482	2009-08-30	5	2009/2010	8635	9985	1	1	Belgium Jupiler League	2
483	2009-08-30	5	2009/2010	9987	9993	1	1	Belgium Jupiler League	2
484	2009-08-30	5	2009/2010	9984	8342	2	3	Belgium Jupiler League	2
485	2009-08-29	5	2009/2010	8571	9991	1	0	Belgium Jupiler League	2
486	2009-08-29	5	2009/2010	8203	9997	0	2	Belgium Jupiler League	2
487	2009-08-29	5	2009/2010	9999	9986	1	3	Belgium Jupiler League	2
488	2009-08-28	5	2009/2010	10001	10000	1	2	Belgium Jupiler League	2
489	2009-09-13	6	2009/2010	8342	9987	1	1	Belgium Jupiler League	2
490	2009-09-12	6	2009/2010	9985	8203	3	0	Belgium Jupiler League	2
491	2009-09-12	6	2009/2010	9997	8635	2	1	Belgium Jupiler League	2
492	2009-09-12	6	2009/2010	10000	8571	0	2	Belgium Jupiler League	2
493	2009-09-12	6	2009/2010	9986	9984	0	4	Belgium Jupiler League	2
494	2009-09-12	6	2009/2010	9991	9999	5	1	Belgium Jupiler League	2
495	2009-09-13	6	2009/2010	9993	9994	2	1	Belgium Jupiler League	2
496	2009-09-20	7	2009/2010	8635	9991	1	1	Belgium Jupiler League	2
497	2009-09-18	7	2009/2010	9987	9986	1	2	Belgium Jupiler League	2
498	2009-09-19	7	2009/2010	9984	9993	1	2	Belgium Jupiler League	2
499	2009-09-19	7	2009/2010	9994	9985	1	3	Belgium Jupiler League	2
500	2009-09-19	7	2009/2010	8571	9997	0	1	Belgium Jupiler League	2
\.


--
-- Data for Name: player; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.player (id, name, birthday, weight, height) FROM stdin;
39890	Mark Volders	1977-04-13	183	187.96000000000001
34480	Davy Schollen	1978-02-28	192	190.5
38388	Olivier Deschacht	1981-02-16	179	187.96000000000001
38788	Gonzague Vandooren	1979-08-19	179	193.03999999999999
26458	Arnold Kruiswijk	1984-11-02	161	182.88
38312	Chemcedine El Araichi	1981-05-18	165	177.80000000000001
13423	Marcin Wasilewski	1980-06-09	194	185.41999999999999
26235	Jeremy Sapina	1985-02-01	187	187.96000000000001
38389	Roland Juhasz	1983-07-01	207	193.03999999999999
38798	Thomas Chatelle	1981-03-31	159	175.25999999999999
30949	Jan Polak	1981-03-14	176	180.34
38253	Guillaume Gillet	1984-03-09	176	185.41999999999999
26916	Christophe Lepoint	1984-10-24	183	187.96000000000001
106013	Bakary Sare	1990-04-05	170	185.41999999999999
38383	Mbark Boussoufa	1984-08-15	134	167.63999999999999
94289	Idir Ouali	1988-05-21	152	175.25999999999999
46552	Matias Suarez	1988-05-09	165	182.88
38327	Wouter Biebauw	1984-05-21	181	187.96000000000001
37937	Davino Verhulst	1987-11-25	198	193.03999999999999
67950	Kenny van Hoevelen	1983-06-24	176	182.88
38293	Joao Carlos	1982-01-01	176	187.96000000000001
67958	Nana Asare	1986-07-11	143	172.72
148313	Dimitri Daeselaire	1990-05-18	134	170.18000000000001
67959	Maxime Biset	1986-03-26	196	193.03999999999999
104411	David Hubert	1988-02-12	174	182.88
37112	Julien Gorius	1985-03-17	172	182.88
148314	Anele Ngcongca	1987-10-21	150	182.88
36393	Kristof Imschoot	1980-12-04	163	182.88
37202	Tom de Mul	1986-03-04	143	172.72
148286	Joachim Mununga	1988-06-30	174	177.80000000000001
43158	Daniel Pudil	1985-09-27	181	185.41999999999999
67898	Koen Persoons	1983-07-12	165	177.80000000000001
9307	Balazs Toth	1981-09-24	154	175.25999999999999
164352	Romeo van Dessel	1989-04-09	183	190.5
42153	Elyaniv Barda	1981-12-15	154	177.80000000000001
38801	Wouter Vrancken	1979-02-03	176	185.41999999999999
32690	Stein Huysegems	1982-06-16	168	185.41999999999999
26502	Giuseppe Rossini	1986-08-23	185	193.03999999999999
38782	Jelle Vossen	1989-03-22	161	180.34
95597	Bertrand Laquait	1977-04-13	176	185.41999999999999
38252	Frederic Herpoel	1974-08-16	183	182.88
39156	Frederic Jay	1976-09-20	154	172.72
39151	Roberto Mirri	1978-08-21	172	185.41999999999999
38435	Fabien Camus	1985-02-28	150	175.25999999999999
166554	Francesco Migliore	1988-04-17	165	172.72
94462	Torben Joneleit	1987-05-17	185	185.41999999999999
15652	Ivica Dzidic	1984-02-08	174	182.88
46004	Damien Miceli	1984-10-27	165	177.80000000000001
39145	Alesandro Cordaro	1986-05-02	150	170.18000000000001
164732	Ilombe Mboyo	1987-04-27	181	185.41999999999999
46890	Cedric Collet	1984-03-07	168	182.88
38947	Mustapha Jarju Alasan	1986-07-18	179	182.88
38246	Christophe Gregoire	1980-04-20	163	187.96000000000001
46881	David Fleurival	1984-02-19	185	182.88
38423	Abdelmajid Oulmers	1978-09-12	143	172.72
39158	Hocine Ragued	1983-02-11	168	182.88
38419	Mahamadou Habib Habibou	1987-04-16	187	193.03999999999999
119118	Moussa Gueye	1989-02-20	172	185.41999999999999
36835	Bram Verbist	1983-03-05	196	182.88
39580	Mohamed Sarr	1983-12-23	185	185.41999999999999
37047	Denis Viane	1977-10-02	159	177.80000000000001
30692	Oguchi Onyewu	1982-05-13	209	195.58000000000001
37021	Anthony Portier	1982-06-01	181	182.88
37861	Landry Mulemo	1986-09-17	170	177.80000000000001
38186	Dejan Kelhar	1984-04-05	187	187.96000000000001
47411	Marcos Camozzato	1983-06-17	157	177.80000000000001
27110	Arnar Vidarsson	1978-03-15	170	177.80000000000001
119117	Reginald Goreux	1987-12-31	161	175.25999999999999
32863	Thomas Buffel	1981-02-19	150	175.25999999999999
35412	Wilfried Dalmat	1982-07-17	168	175.25999999999999
37957	Sergiy Serebrennikov	1976-09-01	192	185.41999999999999
39631	Steven Defour	1988-04-15	159	175.25999999999999
37909	Tony Sergeant	1977-06-06	163	182.88
39591	Axel Witsel	1989-01-12	161	185.41999999999999
104386	Vusumuzi Prince Nyoni	1984-04-24	168	177.80000000000001
25957	Igor de Camargo	1983-05-12	187	187.96000000000001
38251	Dominic Foley	1976-07-07	176	185.41999999999999
38369	Dieumerci Mbokani	1985-11-22	161	185.41999999999999
37065	Stijn De Smet	1985-03-27	172	182.88
30934	Boubacar Barry Copa	1979-12-30	152	180.34
104378	Bojan Jorgacevic	1982-02-12	190	187.96000000000001
38292	Olivier Doll	1973-06-09	181	182.88
27838	Erlend Hanstveit	1981-01-28	179	187.96000000000001
11569	Avi Strool	1980-09-18	172	185.41999999999999
36841	Jonas De Roeck	1979-12-20	176	187.96000000000001
38273	Hassan El Mouataz	1981-09-21	168	177.80000000000001
38337	Stef Wils	1982-08-02	179	187.96000000000001
14642	Yoav Ziv	1981-03-16	165	175.25999999999999
38945	Mario Carevic	1982-03-29	185	185.41999999999999
33662	Tim Smolders	1980-08-26	176	193.03999999999999
38290	Killan Overmeire	1985-12-06	185	187.96000000000001
37044	Christophe Grondin	1983-09-02	170	180.34
95609	Tshilola Tshinyama Tiko	1980-12-12	165	175.25999999999999
32760	Milos Maric	1982-03-05	176	177.80000000000001
38257	Nebojsa Pavlovic	1981-04-09	179	187.96000000000001
38229	Bryan Ruiz	1985-08-18	172	187.96000000000001
12574	Zlatan Ljubijankic	1983-12-15	176	185.41999999999999
121639	Moussa Maazou	1988-08-25	174	185.41999999999999
46335	Mbaye Leye	1982-12-01	165	182.88
37990	Stijn Stijnen	1981-04-07	183	187.96000000000001
38318	Jurgen Sierens	1976-04-10	196	190.5
37983	Koen Daerden	1982-03-08	185	190.5
46580	Azubuike Oliseh	1978-11-18	172	177.80000000000001
21812	Michael Klukowski	1981-05-27	170	182.88
38247	Damir Mirvic	1982-11-30	181	185.41999999999999
11736	Antolin Alcaraz	1982-07-30	176	187.96000000000001
16387	Mladen Lazarevic	1984-01-16	172	187.96000000000001
37858	Jeroen Simaeys	1985-05-12	176	193.03999999999999
94284	Anthony van Loo	1988-10-05	157	177.80000000000001
39578	Karel Geraerts	1982-01-05	176	180.34
38336	Nabil Dirar	1986-08-26	174	182.88
45832	Arturo ten Heuvel	1978-12-20	176	180.34
38366	Vadis Odjidja-Ofoe	1989-02-21	201	185.41999999999999
33671	Vincent Provoost	1984-02-07	168	177.80000000000001
52280	Ronald Vargas	1986-12-02	154	175.25999999999999
163670	Ivan Perisic	1989-02-02	179	185.41999999999999
27423	Wesley Sonck	1978-08-09	168	175.25999999999999
33622	Sherjill MacDonald	1984-11-20	187	182.88
38440	Joseph Akpala	1986-08-24	179	185.41999999999999
148336	Joerie Dequevy	1988-04-27	152	175.25999999999999
38391	Silvio Proto	1983-05-23	170	185.41999999999999
33676	Peter Mollez	1983-09-23	181	185.41999999999999
36849	Pieterjan Monteyne	1983-01-01	161	177.80000000000001
67940	Daniel Calvo	1979-07-11	148	175.25999999999999
46231	Tristan Lahaye	1983-02-16	150	177.80000000000001
36845	Kurt van Dooren	1978-08-03	170	182.88
67939	Bram De Ly	1984-01-21	168	182.88
38322	Martijn Monteyne	1984-11-12	172	175.25999999999999
38371	Bart Goor	1973-04-09	176	182.88
38249	Davy De Beule	1981-11-07	172	180.34
36852	Daniel Cruz	1981-05-09	168	180.34
39625	Mustapha Oussalah	1982-02-19	163	175.25999999999999
38784	Wim De Decker	1982-04-06	176	185.41999999999999
39859	Jimmy Hempte	1982-03-24	172	180.34
38786	Faris Haroun	1985-09-22	161	187.96000000000001
40521	Sven Kums	1988-02-26	150	175.25999999999999
30910	Ivan Leko	1978-02-07	174	177.80000000000001
148302	Cheikhou Kouyate	1989-12-21	172	193.03999999999999
38792	Kevin Vandenbergh	1983-05-16	161	177.80000000000001
148329	Elimane Coulibaly	1980-03-15	196	190.5
39153	Cedric Berthelin	1976-12-25	214	193.03999999999999
32990	Nicolas Ardouin	1978-02-07	176	185.41999999999999
39575	Eric Deflandre	1973-08-02	176	180.34
94184	Gregoire Neels	1982-08-02	161	185.41999999999999
46459	Samuel Neva	1981-05-15	172	182.88
15456	Josip Barisic	1981-03-07	185	193.03999999999999
26606	Siebe Blondelle	1986-04-20	183	185.41999999999999
15913	Dimitrija Lazarevski	1982-09-23	165	177.80000000000001
15662	Sulejman Smajic	1984-08-13	143	172.72
37085	Alan Haydock	1976-01-13	159	175.25999999999999
178291	David Destorme	1979-08-30	181	187.96000000000001
37972	Gregory Dufer	1981-12-19	154	175.25999999999999
45413	Ervin Zukanovic	1987-02-11	187	187.96000000000001
148292	Mvuezolo Muscal Musumbu	1979-03-30	161	175.25999999999999
148289	Yohan Brouckaert	1987-10-30	176	185.41999999999999
149367	Rudy Saintini	1987-05-02	148	175.25999999999999
17703	Jeremy Perbet	1984-12-12	172	182.88
116788	Admir Aganovic	1986-08-25	176	182.88
94281	Vittorio Villano	1988-02-02	137	165.09999999999999
37900	Sammy Bossuyt	1985-08-11	172	185.41999999999999
38341	Yves De Winter	1987-05-25	181	187.96000000000001
37886	Karel D'Haene	1980-09-05	172	182.88
38349	Nico van Kerckhoven	1970-12-14	183	190.5
37903	Stijn Minne	1978-06-29	150	170.18000000000001
21834	Rachid Farssi	1985-01-15	152	180.34
37889	Bart Buysse	1986-10-16	154	177.80000000000001
37953	Gunther Vanaudenaerde	1984-01-23	168	177.80000000000001
94030	Jeremy Taravel	1987-04-17	185	190.5
38339	Wouter Corstjens	1987-02-13	174	187.96000000000001
37902	Stijn Meert	1978-04-06	154	177.80000000000001
30404	Lukas Zelenka	1979-10-05	159	175.25999999999999
38231	Ernest Webnje Nfor	1986-04-28	159	177.80000000000001
38353	Tom van Imschoot	1981-09-04	174	185.41999999999999
131530	Thomas Matton	1985-10-24	159	177.80000000000001
38348	Michael Modubi	1985-04-22	159	175.25999999999999
130027	Khaleem Hyland	1989-06-05	187	182.88
37893	Ludwig van Nieuwenhuyze	1978-02-25	176	185.41999999999999
37025	Dieter Dekelver	1979-08-17	165	180.34
37981	Kevin Roelandts	1982-08-27	179	185.41999999999999
17883	Emanuel Obiora Odita,19	1983-05-15	179	182.88
37051	Frederik Boi	1981-10-25	152	182.88
38357	Oleg Iachtchouk	1977-10-26	172	182.88
78462	Honour Gombami	1983-01-09	157	177.80000000000001
38800	Tomislav Mikulic	1982-01-04	181	185.41999999999999
68064	Steven De Pauw	1982-05-17	179	185.41999999999999
38393	Lucas Biglia	1986-01-30	139	177.80000000000001
131531	Franck Berrier	1984-02-02	143	175.25999999999999
38778	Oleksandr Iakovenko	1987-07-23	163	182.88
37069	Tom De Sutter	1985-07-03	203	193.03999999999999
37971	Glenn Verbauwhede	1985-05-19	176	187.96000000000001
33660	Olivier Fontenette	1982-01-13	143	175.25999999999999
12099	Marcel MBayo,25	1978-04-24	137	167.63999999999999
149279	Karim Belhocine	1978-04-02	183	187.96000000000001
38785	Eric Matoukou	1983-07-08	179	187.96000000000001
131406	Fred	1986-01-15	183	187.96000000000001
38794	Marvin Ogunjimi	1987-10-12	176	182.88
67941	Xavier Chen	1983-10-05	152	175.25999999999999
47410	Mozes Adams	1988-07-21	154	182.88
39848	Joris van Hout	1977-01-10	176	187.96000000000001
50160	Jaime Alfonso Ruiz	1984-01-09	174	182.88
33657	Bjoern Vleminckx	1985-12-01	181	182.88
94288	Jeremy Huyghebaert	1989-01-07	159	180.34
39878	Daan van Gijseghem	1988-03-02	185	182.88
26669	Stefaan Tanghe,18	1972-01-15	150	175.25999999999999
37945	Mahamadou Dissa	1979-05-18	150	172.72
38248	Dario Smoje	1978-09-19	181	193.03999999999999
35580	Quinton Fortune	1977-05-21	163	182.88
38255	Kenny Thompson	1985-04-26	161	182.88
37976	Jason Vandelannoite	1986-11-06	176	177.80000000000001
38233	Randall Azofeifa	1984-12-30	183	182.88
104382	Roberto Rosales	1988-11-20	154	175.25999999999999
9144	Yasin Karaca	1983-12-16	148	170.18000000000001
97368	Jusuf Dajic	1984-08-21	176	180.34
37571	Mohamed Chakouri	1986-05-21	163	180.34
131409	Adlene Guedioura	1985-11-12	179	177.80000000000001
41106	Tosin Dosunmu	1980-07-15	159	177.80000000000001
31316	Nemanja Rnic	1984-09-30	161	177.80000000000001
164694	Victor Bernardez	1982-05-24	190	187.96000000000001
38378	Jonathan Legear	1987-04-13	170	180.34
26224	Benjamin Nicaise	1980-09-28	185	182.88
37262	Milan Jovanovic	1981-04-18	168	182.88
42812	Didier Dheedene	1972-01-22	176	182.88
34334	Sanharib Bueyueksal	1984-03-01	165	177.80000000000001
131404	David Vandenbroeck	1985-07-12	187	187.96000000000001
69629	Dawid Janczyk	1987-09-23	179	180.34
67896	Steven De Petter	1985-11-22	168	180.34
38342	Bernt Evens	1978-11-09	190	193.03999999999999
37100	Steve Colpaert	1986-09-13	163	177.80000000000001
148308	Sven De Volder	1990-03-09	179	182.88
6803	Brecht Verbrugghe	1982-04-29	165	182.88
148960	Jaycee Okwunwanne	1985-10-08	176	180.34
131486	Cedric Betremieux	1982-05-14	165	177.80000000000001
38410	Gerald Forschelet	1981-09-19	185	187.96000000000001
27364	Marc-Andre Kruska	1987-06-29	165	177.80000000000001
148327	Istvan Bakx	1986-01-20	154	175.25999999999999
37887	Loris Reina	1980-06-10	159	180.34
39875	Adnan Custovic	1978-04-16	183	185.41999999999999
75500	Chris Makiese	1987-10-14	163	182.88
12381	Jan Slovenciak	1981-11-11	196	193.03999999999999
37846	Asanda Sishuba	1980-04-13	143	167.63999999999999
12245	Adam Nemec	1985-09-02	198	190.5
33620	Jelle van Damme	1983-10-10	198	190.5
36863	Hernan Losada	1982-05-09	148	172.72
10404	Stanislav Vlcek	1976-02-26	174	182.88
31810	Antti Okkonen	1982-06-06	163	177.80000000000001
40008	Mounir Diane	1982-05-16	172	182.88
37979	Jonathan Blondel	1984-04-03	146	172.72
12692	Kanu	1987-09-23	181	190.5
34031	Michael Wiggers	1980-02-08	165	182.88
39573	Olivier Renard	1979-02-01	170	187.96000000000001
38791	Kenneth van Goethem	1984-02-13	139	177.80000000000001
17276	Aloys Nong	1983-10-16	170	180.34
20445	Ederson Tormena	1986-03-14	181	185.41999999999999
38797	Sinan Bolat	1988-09-03	174	190.5
41021	Paul Kpaka	1981-08-07	170	177.80000000000001
38789	Hans Cornelis	1982-10-13	154	185.41999999999999
94308	King Osei Gyan	1988-12-22	152	175.25999999999999
148335	Mehdi Carcela-Gonzalez	1989-07-01	148	175.25999999999999
167619	Jan Lella	1989-11-06	179	187.96000000000001
104389	Geoffrey Mujangi Bia	1989-08-12	174	180.34
148297	Mario Matos	1988-06-21	181	185.41999999999999
39157	Gauthier Diafutua	1985-11-04	181	182.88
38343	Jef Delen	1976-06-29	139	175.25999999999999
148315	Christian Benteke	1990-12-03	183	190.5
38441	Laurent Ciman	1985-08-05	154	182.88
34025	Mohamed Dahmane	1982-04-09	163	180.34
38920	Cyril Thereau	1983-04-24	172	187.96000000000001
37038	Igor Gjuzelov	1976-04-02	181	185.41999999999999
170323	Thibaut Courtois	1992-05-11	194	198.12
37854	Frank Boeckx	1986-09-27	187	180.34
39498	Daniel Tozser	1985-05-12	163	185.41999999999999
32637	Abdessalam Benjelloun	1985-01-28	179	187.96000000000001
40433	Tarmo Neemelo	1982-02-10	201	193.03999999999999
37988	Philippe Clement	1974-03-22	192	190.5
12473	Marko Suler	1983-03-09	174	185.41999999999999
6800	Jonas Ivens	1984-10-14	190	187.96000000000001
38285	Benjamin De Wilde	1986-04-07	168	185.41999999999999
148326	Rob Claeys	1987-08-24	179	185.41999999999999
38320	Kevin Oris	1984-12-06	201	190.5
131394	Benoit Ladriere	1987-04-27	157	172.72
15425	Veldin Muharemovic	1984-12-06	170	182.88
104404	Nill De Pauw	1990-01-06	154	180.34
148325	Kristof van Hout	1987-02-09	243	208.28
131532	Miguel Dachelet	1988-01-16	168	182.88
41109	Adriano	1980-01-29	176	182.88
37856	Henri Munyaneza	1984-06-19	183	185.41999999999999
148311	Gregory Delwarte	1978-01-30	181	185.41999999999999
131403	Jo Coppens	1990-12-21	176	190.5
38780	Goran Ljubojevic	1983-05-04	194	190.5
156551	Eliaquim Mangala	1991-02-13	185	187.96000000000001
37947	Sekou Ouattara	1986-03-19	159	180.34
21744	Bart Goossens	1985-01-05	150	182.88
131411	Boubacar Dembele	1982-03-01	172	182.88
39896	Romain Haghedooren	1986-09-28	176	187.96000000000001
166679	Guillaume Francois	1990-06-03	159	175.25999999999999
78902	Ebrahima Ibou Sawaneh	1986-09-07	165	182.88
131408	Thomas Kaminski	1992-10-23	154	193.03999999999999
37868	Simon Mignolet	1988-08-06	192	193.03999999999999
33595	Mario Cantaluppi,25	1974-04-11	165	182.88
38347	Marc Wagemakers	1978-06-07	163	182.88
3329	Vincent Euvrard	1982-03-12	165	182.88
149150	Denis Odoi	1988-05-27	148	177.80000000000001
38354	Wim Mennes	1977-01-25	176	185.41999999999999
37866	Peter Delorge	1980-04-19	152	177.80000000000001
36836	Cephas Chimedza	1984-12-05	172	177.80000000000001
5016	Ibrahim Sidibe	1984-11-22	154	177.80000000000001
45490	Jonathan Wilmet	1986-01-07	161	182.88
40014	Sebastien Chabbert	1978-05-15	176	185.41999999999999
42594	Ryan Donk	1986-03-30	176	193.03999999999999
46666	Maxime Brillault	1983-04-25	174	187.96000000000001
37963	Jorn Vermeulen	1987-04-16	172	185.41999999999999
38439	Gregory Christ	1982-10-04	157	175.25999999999999
114716	Mouhcine Iajour	1985-06-14	165	177.80000000000001
25636	Orlando Dos Santos Costa	1981-02-26	185	187.96000000000001
39594	Frederic Dupre	1979-05-12	172	182.88
25465	Ibrahima Gueye	1978-02-19	185	190.5
30485	Tomislav Sokota	1977-04-08	174	182.88
39772	Leon Benko	1983-11-11	165	182.88
38332	Emanuel Sarki	1987-12-26	150	175.25999999999999
67952	Abdul-Yakinu Iddi	1986-05-25	146	172.72
39389	Antonio Ghomsi	1986-04-22	174	177.80000000000001
13131	Tomislav Pacovski	1982-06-28	185	185.41999999999999
36868	Justice Wamfor	1981-08-05	168	175.25999999999999
24037	Collins John	1985-10-17	172	180.34
36832	Carl Hoefkens	1978-10-06	181	185.41999999999999
95614	Gertjan De Mets	1987-04-02	159	175.25999999999999
129462	Felipe	1987-05-15	198	193.03999999999999
178486	Ludovic Buysens	1986-03-13	174	187.96000000000001
104415	Giel Deferm	1988-06-30	152	177.80000000000001
93054	Massimo Moia	1987-03-09	165	177.80000000000001
104377	Teddy Chevalier	1987-06-28	168	177.80000000000001
38417	Ibrahima Diallo	1985-09-26	172	180.34
40520	Herve Kage	1989-04-10	181	177.80000000000001
38289	Jugoslav Lazic	1979-12-12	190	198.12
38969	Yoni Buyens	1988-03-10	176	182.88
154433	Boubacar Diabang Dialiba	1988-07-13	152	177.80000000000001
69805	Stepan Kucera	1984-06-11	192	190.5
46217	Samir El Gaaouiri	1984-05-28	174	182.88
23997	Bjarni Vidarsson	1988-03-05	168	187.96000000000001
43049	Adnan Mravac	1982-04-10	185	193.03999999999999
179058	Glenn van Asten	1987-06-16	172	180.34
182605	Lens Annab	1988-07-20	170	182.88
178284	Bavon Tshibuabua	1991-07-17	157	177.80000000000001
25619	Bertin Tomou	1978-08-08	185	187.96000000000001
75405	Dorge Kouemaha	1983-06-28	198	182.88
39977	Peter Franquart	1985-01-04	181	182.88
69713	Ondrej Mazuch	1989-03-15	183	187.96000000000001
181276	Romelu Lukaku	1993-05-13	207	190.5
25995	Ricardo Rocha	1978-10-03	176	182.88
32573	Olivier Dacourt	1974-09-25	161	177.80000000000001
166302	Gohi Bi Cyriac	1990-08-05	150	172.72
68120	Nils Schouterden	1988-12-14	165	175.25999999999999
166618	Yassine El Ghanassy	1990-07-12	154	175.25999999999999
185388	Amad Al Hosni	1984-07-18	150	177.80000000000001
89548	Bojan Bozovic	1985-02-03	185	190.5
163674	Moussa Koita	1982-11-19	207	193.03999999999999
148338	Jeroen Vanthournout	1989-06-29	163	182.88
173432	Stefan Nikolic	1990-04-16	190	193.03999999999999
166675	Derrick Tshimanga	1988-11-06	159	175.25999999999999
95615	Brecht Capon	1988-04-22	159	180.34
166663	Jo Christiaens	1988-04-17	163	187.96000000000001
159888	Victor Ramos	1989-05-05	181	190.5
26741	Steffen Ernemann	1982-04-26	172	185.41999999999999
166584	Momodou Ceesay	1988-12-24	185	195.58000000000001
33685	Mohamed Messoudi	1984-01-07	161	177.80000000000001
178484	Moussa Traore	1990-03-09	174	182.88
27421	Bernd Thijs	1978-06-28	179	185.41999999999999
166670	Lucas van Eenoo	1991-02-06	148	175.25999999999999
67957	Kevin Geudens	1980-12-02	148	185.41999999999999
169200	Kevin de Bruyne	1991-06-28	168	180.34
166676	Victor Wanyama	1991-06-25	168	187.96000000000001
127191	Dugary Ndabashinze	1989-10-08	170	182.88
104388	Cyprien Baguette,23	1989-05-12	185	187.96000000000001
38380	Mark de Man	1983-04-27	174	177.80000000000001
91929	Laszlo Koteles	1984-09-01	185	185.41999999999999
166575	Maxime Lestienne	1992-06-17	139	175.25999999999999
150510	Samuel Yeboah	1986-08-08	150	177.80000000000001
129278	Holmar Oern Eyjolfsson	1990-08-06	190	190.5
106369	Nikita Rukavytsya	1987-06-22	163	182.88
178276	Timothy Durwael	1991-02-24	146	172.72
38365	Sebastien Siani	1986-12-21	168	175.25999999999999
178249	Reynaldo	1989-08-24	157	172.72
25499	Nicolas Frutos	1981-05-10	194	193.03999999999999
38795	Sebastien Pocognoli	1987-08-01	161	180.34
27508	Peter van der Heyden	1976-07-16	185	182.88
112934	Emil Lyng	1989-08-03	194	187.96000000000001
38799	Tom Soetaers	1980-07-21	165	175.25999999999999
107416	Badis Lebbihi	1990-03-14	176	180.34
186621	Rami Gershon	1988-08-12	194	187.96000000000001
38434	Damien Lahaye	1984-01-30	181	180.34
26116	Luigi Pieroni	1980-09-08	185	187.96000000000001
31226	Geert De Vlieger	1971-10-16	179	185.41999999999999
149260	Tom Muyters	1984-12-05	181	187.96000000000001
192907	Liliu	1990-03-30	165	180.34
37967	Daniel Chavez	1988-01-08	152	175.25999999999999
110140	Donovan Deekman	1988-06-23	143	182.88
\.


--
-- Data for Name: playerstats; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.playerstats (player, attribute_date, overall_rating, potential, preferred_foot, attacking_work_rate, defensive_work_rate, crossing, finishing, heading_accuracy, short_passing, volleys, dribbling, curve, free_kick_accuracy, long_passing, ball_control, acceleration, sprint_speed, agility, reactions, balance, shot_power, jumping, stamina, strength, long_shots, aggression, interceptions, positioning, vision, penalties, marking, standing_tackle, sliding_tackle, gk_diving, gk_handling, gk_kicking, gk_positioning, gk_reflexes) FROM stdin;
38423	2010-02-22	68	70	right	\N	\N	60	50	60	74	\N	74	\N	53	62	73	74	70	\N	63	\N	64	\N	71	64	55	63	69	70	\N	47	52	50	\N	7	20	62	20	20
38423	2009-08-30	68	70	right	\N	\N	60	50	60	74	\N	74	\N	53	62	73	74	70	\N	63	\N	64	\N	71	64	55	63	69	70	\N	47	52	50	\N	7	20	62	20	20
38423	2008-08-30	68	69	right	\N	\N	60	50	60	74	\N	74	\N	53	62	73	74	70	\N	63	\N	64	\N	71	64	55	63	69	70	\N	47	52	50	\N	7	20	62	20	20
38423	2007-08-30	70	69	right	\N	\N	60	50	60	74	\N	74	\N	53	62	73	74	70	\N	63	\N	64	\N	71	64	55	63	69	70	\N	47	52	50	\N	7	20	62	20	20
38423	2007-02-22	70	69	right	\N	\N	60	50	70	74	\N	74	\N	47	62	73	76	70	\N	63	\N	74	\N	73	74	55	73	69	70	\N	47	72	70	\N	7	7	62	12	5
32637	2010-02-22	61	65	right	\N	\N	42	60	54	52	\N	51	\N	42	35	60	74	77	\N	52	\N	71	\N	61	71	59	30	52	57	\N	66	22	27	\N	7	20	35	20	20
32637	2009-08-30	56	65	right	\N	\N	42	50	39	57	\N	51	\N	42	35	53	71	74	\N	52	\N	66	\N	61	46	59	30	52	49	\N	47	22	27	\N	7	20	35	20	20
32637	2009-02-22	66	76	right	\N	\N	42	74	39	57	\N	76	\N	42	35	71	81	84	\N	52	\N	68	\N	61	53	52	41	52	49	\N	47	22	27	\N	7	20	35	20	20
32637	2008-08-30	66	76	right	\N	\N	42	74	39	57	\N	76	\N	42	35	71	81	84	\N	52	\N	68	\N	61	53	52	41	52	49	\N	47	22	27	\N	7	20	35	20	20
32637	2007-08-30	72	76	right	\N	\N	42	74	39	57	\N	76	\N	42	35	71	81	84	\N	52	\N	68	\N	61	53	52	41	52	49	\N	47	22	27	\N	7	20	35	20	20
32637	2007-02-22	59	70	right	\N	\N	42	65	39	57	\N	54	\N	47	35	55	63	65	\N	52	\N	55	\N	57	52	44	41	52	49	\N	47	22	27	\N	7	6	35	7	4
67952	2014-07-25	64	65	left	medium	medium	50	46	47	62	53	73	51	55	61	71	73	70	81	66	85	60	76	71	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2014-03-14	64	65	left	medium	medium	50	46	47	62	53	73	51	55	61	71	73	70	81	66	85	60	76	71	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2013-12-20	66	67	left	medium	medium	51	46	47	67	53	73	51	55	66	71	74	70	81	67	85	60	76	74	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2013-09-20	66	66	left	medium	medium	51	46	47	67	53	73	51	55	66	71	74	70	81	67	85	60	76	74	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2013-03-28	66	66	left	medium	medium	51	46	47	67	53	73	51	55	66	71	74	71	81	67	85	60	75	74	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2013-02-22	66	66	left	medium	medium	51	46	47	67	53	73	51	55	66	71	74	71	81	67	85	60	75	74	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2013-02-15	65	66	left	medium	medium	51	46	47	68	53	75	51	55	67	71	74	71	81	67	85	60	75	74	46	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2012-08-31	64	66	left	medium	medium	51	46	47	68	53	75	51	55	67	71	74	72	81	67	85	60	73	74	45	58	48	48	53	61	47	34	48	46	5	9	10	11	14
67952	2012-02-22	61	66	left	medium	medium	56	46	47	64	53	73	51	55	61	71	70	68	81	63	85	60	69	66	45	58	48	48	53	61	47	34	46	43	5	9	10	11	14
67952	2011-08-30	61	66	left	medium	medium	56	46	47	64	53	73	51	55	61	71	70	68	76	63	85	60	69	66	45	58	48	48	53	61	47	34	46	43	5	9	10	11	14
67952	2010-08-30	61	66	left	medium	medium	56	57	47	61	54	68	51	55	58	67	68	63	71	61	56	60	65	63	54	59	49	32	56	59	47	22	34	37	5	9	10	11	14
67952	2009-08-30	62	66	left	medium	medium	64	53	45	64	54	73	51	55	58	71	68	63	71	61	56	60	65	63	54	58	46	57	58	59	60	22	34	37	3	20	58	20	20
67952	2008-08-30	60	66	right	medium	medium	56	51	45	61	54	73	51	55	56	71	68	63	71	61	56	60	65	58	51	58	31	47	48	59	53	22	31	37	3	20	56	20	20
67952	2007-08-30	63	66	right	medium	medium	56	51	45	61	54	73	51	55	56	71	68	63	71	61	56	60	65	58	51	58	31	47	48	59	53	22	31	37	3	20	56	20	20
67952	2007-02-22	63	66	right	medium	medium	56	51	45	61	54	73	51	55	56	71	68	63	71	61	56	60	65	58	51	58	31	47	48	59	53	22	31	37	3	20	56	20	20
12245	2015-09-21	66	66	left	medium	medium	44	65	78	53	62	55	50	43	42	59	55	55	34	65	43	78	67	55	86	63	48	34	64	42	56	15	13	12	9	16	8	15	15
12245	2015-08-14	65	65	left	medium	medium	43	64	77	52	61	54	49	42	41	58	55	55	34	64	43	77	67	55	86	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-07-03	65	65	left	medium	medium	43	64	77	52	61	54	49	42	41	58	59	55	40	64	43	77	67	60	86	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-06-12	65	65	left	medium	medium	43	64	77	52	61	54	49	42	41	58	59	55	40	64	43	77	67	60	86	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-06-05	65	65	left	medium	medium	43	64	77	52	61	54	49	42	41	59	59	55	40	64	43	77	67	60	87	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-05-08	66	66	left	medium	medium	43	65	77	54	61	58	49	42	41	64	59	55	40	64	43	77	67	60	87	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-04-24	66	66	left	medium	medium	43	65	77	54	61	58	49	42	41	64	59	55	40	64	43	77	67	60	88	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-04-17	66	66	left	medium	medium	43	65	77	54	61	58	49	42	41	64	55	55	40	64	43	77	67	60	88	62	47	33	63	41	55	25	25	25	8	15	7	14	14
12245	2015-04-10	67	67	left	medium	medium	43	65	77	54	61	58	49	42	41	64	55	55	40	67	43	77	67	60	88	62	47	33	67	41	55	25	25	25	8	15	7	14	14
12245	2015-03-10	67	67	left	medium	medium	43	67	77	54	61	58	49	42	41	65	55	55	40	67	43	77	67	60	90	62	47	33	69	41	55	25	25	25	8	15	7	14	14
12245	2014-10-31	67	67	left	medium	medium	43	67	77	54	61	58	49	42	41	65	55	55	40	67	43	77	67	60	90	62	47	33	69	41	55	25	25	25	8	15	7	14	14
12245	2014-09-18	68	68	left	medium	medium	43	67	78	54	61	58	49	42	41	65	55	55	40	69	43	77	67	62	90	62	47	33	70	41	55	25	25	25	8	15	7	14	14
12245	2014-04-25	69	69	left	medium	medium	43	68	78	54	63	58	49	42	41	65	55	64	40	71	43	77	67	62	86	64	47	33	70	41	55	25	25	25	8	15	7	14	14
12245	2014-02-07	70	70	left	medium	medium	43	70	78	54	65	58	49	42	41	65	55	64	40	71	43	77	67	62	86	66	47	33	72	41	55	25	25	25	8	15	7	14	14
12245	2013-12-06	70	70	left	medium	medium	43	70	78	54	65	58	49	42	41	65	55	64	40	71	43	77	67	62	86	66	47	33	72	41	55	25	25	25	8	15	7	14	14
12245	2013-09-20	70	70	left	medium	medium	43	70	78	54	65	58	49	42	41	65	55	64	40	71	43	77	67	62	86	66	47	33	72	41	55	25	25	25	8	15	7	14	14
12245	2013-09-06	68	68	left	medium	medium	43	69	77	54	62	58	49	42	41	65	55	62	40	68	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2013-04-19	68	69	left	medium	medium	43	69	77	54	62	58	49	42	41	65	55	62	40	68	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2013-03-22	68	69	left	medium	medium	43	69	75	56	62	58	49	42	41	65	55	62	40	67	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2013-03-08	68	69	left	medium	medium	43	69	75	56	62	58	49	42	41	65	55	62	40	67	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2013-02-22	68	69	left	medium	medium	43	69	75	56	62	58	49	42	41	65	55	62	40	67	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2013-02-15	67	69	left	medium	medium	43	69	75	56	62	57	49	42	41	63	55	62	40	66	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2012-08-31	67	72	left	medium	medium	43	69	75	56	62	57	49	42	41	63	55	62	40	66	43	76	66	62	84	66	47	33	68	41	55	14	12	11	8	15	7	14	14
12245	2012-02-22	68	72	left	medium	medium	44	71	78	57	63	57	49	42	48	63	55	62	40	69	43	76	66	62	84	64	47	47	68	41	55	14	12	11	8	15	7	14	14
12245	2011-08-30	68	71	left	medium	medium	44	71	78	57	63	57	49	42	48	63	55	62	40	69	43	76	66	62	84	63	47	47	68	41	55	14	12	11	8	15	7	14	14
12245	2011-02-22	68	74	left	medium	medium	44	69	78	57	63	57	49	42	48	62	65	70	45	66	82	74	76	65	86	63	47	47	64	41	55	14	12	11	8	15	7	14	14
12245	2010-08-30	68	74	left	medium	medium	44	69	78	57	63	57	49	42	48	62	65	70	45	66	82	74	76	65	85	63	47	47	64	41	55	14	12	11	8	15	7	14	14
12245	2010-02-22	66	74	left	medium	medium	44	69	78	55	63	57	49	42	48	58	67	71	45	57	82	69	76	62	85	61	47	48	59	41	46	21	21	11	4	21	48	21	21
12245	2009-08-30	65	74	left	medium	medium	44	69	76	51	63	57	49	42	54	57	69	71	45	53	82	66	76	62	85	61	47	48	51	41	46	21	21	11	4	21	54	21	21
12245	2008-08-30	65	74	left	medium	medium	44	69	78	51	63	57	49	42	54	57	69	66	45	53	82	66	76	62	85	61	47	48	51	41	46	21	21	11	4	21	54	21	21
12245	2007-08-30	63	74	left	medium	medium	44	69	78	51	63	57	49	42	54	57	69	66	45	53	82	66	76	52	77	61	47	48	51	41	46	21	21	11	4	21	54	21	21
12245	2007-02-22	63	74	left	medium	medium	44	69	78	51	63	57	49	42	54	57	69	66	45	53	82	66	76	52	77	61	47	48	51	41	46	21	21	11	4	21	54	21	21
131409	2016-05-12	70	70	right	medium	high	62	63	64	74	64	68	36	56	72	72	69	72	65	65	67	84	74	76	84	75	81	64	59	68	57	60	67	66	13	14	14	12	6
131409	2016-04-28	69	69	right	medium	high	62	63	64	73	64	68	36	56	70	72	69	72	65	65	67	84	74	76	84	75	81	63	59	68	57	60	67	65	13	14	14	12	6
131409	2016-04-07	69	69	right	medium	high	62	63	64	73	64	68	36	56	69	72	69	72	65	65	67	84	74	76	84	75	81	61	59	66	57	58	67	65	13	14	14	12	6
131409	2015-12-24	68	68	right	medium	high	62	63	64	72	64	68	36	56	68	72	69	72	65	65	67	82	74	76	84	74	81	61	59	66	57	58	67	65	13	14	14	12	6
131409	2015-11-19	68	68	right	medium	high	62	63	64	72	64	68	36	56	68	72	69	72	65	65	67	82	74	76	84	74	81	61	59	66	57	58	67	65	13	14	14	12	6
131409	2015-09-21	68	68	right	medium	high	62	63	64	72	64	68	36	56	68	72	69	72	65	65	67	82	74	76	84	74	81	61	59	66	57	58	67	65	13	14	14	12	6
131409	2015-05-08	67	67	right	medium	high	61	62	63	71	63	67	35	55	67	71	69	75	72	64	67	81	74	76	84	73	85	60	58	65	56	57	66	64	12	13	13	11	5
131409	2015-03-06	67	67	right	medium	high	61	62	63	71	63	67	35	55	67	71	69	75	72	64	67	81	74	76	84	73	85	60	58	65	56	57	66	64	12	13	13	11	5
131409	2015-01-02	67	67	right	medium	high	61	62	63	71	63	67	35	55	67	71	69	75	72	64	67	81	74	76	84	73	85	60	58	65	56	57	66	64	12	13	13	11	5
131409	2014-11-28	67	67	right	medium	high	61	62	63	71	63	67	35	55	67	71	69	75	72	64	67	81	74	76	84	73	85	60	58	65	56	57	66	64	12	13	13	11	5
131409	2014-10-10	67	67	right	medium	high	61	62	63	71	63	67	35	55	67	71	69	75	72	64	67	81	74	76	84	73	85	60	58	65	56	57	66	64	12	13	13	11	5
131409	2014-09-18	67	67	right	medium	high	61	62	63	71	63	67	35	55	67	71	69	75	72	62	67	81	74	76	84	73	85	60	58	65	56	57	66	64	12	13	13	11	5
131409	2014-05-09	69	69	right	medium	high	65	63	63	71	63	73	35	55	68	74	69	75	72	59	65	85	74	72	84	76	85	62	62	72	56	58	68	67	12	13	13	11	5
131409	2014-04-11	69	69	right	medium	high	65	63	63	71	63	73	35	55	68	74	69	75	72	59	65	85	74	72	84	76	85	62	62	72	56	58	68	67	12	13	13	11	5
131409	2014-01-24	69	69	right	medium	high	65	63	63	71	63	73	35	55	68	74	69	75	72	59	65	85	74	72	84	76	85	62	62	72	56	58	68	67	12	13	13	11	5
131409	2014-01-10	69	69	right	medium	high	65	63	63	71	63	73	35	55	68	74	69	75	72	59	65	85	74	72	84	76	85	62	62	72	56	58	68	67	12	13	13	11	5
131409	2013-12-27	69	70	right	medium	high	65	63	63	71	63	73	35	55	68	74	69	75	72	59	65	85	74	72	84	76	85	62	62	72	56	58	68	67	12	13	13	11	5
131409	2013-11-22	69	69	right	medium	high	65	63	63	71	63	73	35	55	68	74	69	75	72	59	65	85	74	72	84	76	85	62	62	72	56	58	68	67	12	13	13	11	5
131409	2013-09-20	71	74	right	medium	high	65	63	63	73	63	73	35	55	75	74	69	75	72	59	65	85	74	72	84	78	85	62	62	75	56	58	68	67	12	13	13	11	5
131409	2013-05-03	71	76	right	medium	high	65	63	63	73	63	73	35	55	75	74	72	75	72	59	65	85	74	72	84	78	85	62	62	75	56	58	68	67	12	13	13	11	5
131409	2013-03-28	70	76	right	medium	high	65	63	63	73	63	72	35	55	75	73	72	75	72	59	65	85	74	72	84	78	85	62	62	73	56	58	68	65	12	13	13	11	5
131409	2013-03-15	70	76	right	medium	high	65	63	63	73	63	72	35	55	75	73	72	75	70	59	66	85	74	72	84	78	85	62	62	73	56	58	68	65	12	13	13	11	5
131409	2013-02-15	70	76	right	medium	high	65	63	63	73	63	72	35	55	75	73	72	75	70	59	66	85	74	72	84	78	85	62	62	73	56	58	68	65	12	13	13	11	5
131409	2012-08-31	70	76	right	medium	high	65	61	63	73	63	72	35	55	75	73	72	75	70	59	66	85	74	72	84	81	78	62	62	73	56	58	68	65	12	13	13	11	5
131409	2012-02-22	66	71	right	medium	high	45	58	67	72	45	70	26	38	68	73	72	75	70	57	66	80	74	63	84	67	75	62	62	61	56	58	66	67	12	13	13	11	5
131409	2011-08-30	70	74	right	medium	high	45	58	67	72	45	70	26	38	68	74	72	75	70	64	66	77	74	63	85	70	75	77	68	69	56	62	69	70	12	13	13	11	5
131409	2011-02-22	70	77	right	medium	high	45	58	67	72	45	70	26	38	68	74	72	74	70	64	78	77	73	63	85	70	72	77	68	62	56	62	69	70	12	13	13	11	5
131409	2010-08-30	70	77	right	medium	high	45	58	67	72	45	70	26	38	68	74	72	74	70	64	78	77	73	63	85	70	72	77	68	62	56	62	69	70	12	13	13	11	5
131409	2010-02-22	65	69	right	medium	high	40	44	66	64	45	58	26	37	61	61	66	68	70	63	78	67	73	63	84	59	71	63	68	62	66	61	64	70	6	21	61	21	21
131409	2009-08-30	63	70	right	medium	high	31	45	55	65	45	59	26	38	62	56	67	69	70	69	78	62	73	64	65	60	62	60	69	62	67	62	63	70	6	21	62	21	21
131409	2009-02-22	59	65	right	medium	high	31	21	46	35	45	21	26	38	41	36	67	69	70	69	78	24	73	64	65	23	62	41	49	62	47	62	63	70	6	21	41	21	21
131409	2008-08-30	59	65	right	medium	high	31	21	46	35	45	21	26	38	41	36	67	69	70	69	78	24	73	64	65	23	62	41	49	62	47	62	63	70	6	21	41	21	21
131409	2007-08-30	57	65	right	medium	high	31	21	46	35	45	21	26	38	41	36	67	69	70	69	78	24	73	64	65	23	62	41	49	62	47	62	63	70	6	21	41	21	21
131409	2007-02-22	57	65	right	medium	high	31	21	46	35	45	21	26	38	41	36	67	69	70	69	78	24	73	64	65	23	62	41	49	62	47	62	63	70	6	21	41	21	21
116788	2012-08-31	61	66	left	medium	low	46	63	48	52	56	60	38	48	45	61	67	69	62	62	63	60	62	60	63	58	57	31	68	47	58	36	46	20	13	7	15	14	6
116788	2012-02-22	59	64	left	medium	low	46	57	56	52	56	59	38	48	45	57	63	64	62	62	63	60	62	60	63	61	57	31	62	47	58	36	46	20	13	7	15	14	6
116788	2010-02-22	59	64	left	medium	low	46	57	56	52	56	59	38	48	45	57	63	64	62	62	63	60	62	60	63	61	57	31	62	47	58	36	46	20	13	7	15	14	6
116788	2009-08-30	59	64	left	medium	low	46	57	56	52	56	59	38	51	45	57	63	64	62	62	63	60	62	60	63	61	57	31	62	47	58	22	22	20	13	7	15	14	6
116788	2009-02-22	59	64	left	medium	low	46	57	56	52	56	59	38	51	45	57	63	64	62	62	63	60	62	60	63	61	57	31	62	47	58	22	22	20	13	7	15	14	6
116788	2007-02-22	59	64	left	medium	low	46	57	56	52	56	59	38	51	45	57	63	64	62	62	63	60	62	60	63	61	57	31	62	47	58	22	22	20	13	7	15	14	6
39875	2011-08-30	66	66	right	medium	medium	67	68	64	66	71	63	69	73	64	68	57	59	64	68	56	80	62	62	76	72	58	46	71	70	78	26	40	42	15	11	13	11	8
39875	2011-02-22	68	70	right	medium	medium	67	69	65	66	69	63	69	71	64	68	58	64	62	66	65	81	61	71	70	73	58	46	71	70	74	26	40	42	15	11	13	11	8
39875	2010-08-30	69	70	right	medium	medium	67	73	67	67	73	65	69	72	64	69	61	65	64	67	65	82	62	72	71	74	58	46	74	71	79	36	45	47	15	11	13	11	8
39875	2010-02-22	68	73	right	medium	medium	67	71	66	65	73	64	69	72	62	66	61	65	64	67	65	82	62	72	71	74	58	66	67	71	64	36	45	47	12	20	62	20	20
39875	2009-08-30	68	73	right	medium	medium	63	68	68	65	73	64	69	71	61	66	61	65	64	67	65	82	62	72	71	74	58	66	71	71	64	26	45	47	12	20	61	20	20
39875	2009-02-22	67	71	right	medium	medium	63	68	68	65	73	64	69	71	61	66	61	65	64	67	65	77	62	72	71	74	58	66	71	71	64	26	45	47	12	20	61	20	20
39875	2008-08-30	67	70	right	medium	medium	62	68	68	65	73	64	69	71	57	64	62	65	64	70	65	74	62	72	67	69	49	63	71	71	64	20	30	47	12	20	57	20	20
39875	2007-08-30	69	70	right	medium	medium	62	68	63	65	73	64	69	67	57	64	62	65	64	63	65	74	62	72	67	69	49	63	71	71	64	20	30	47	12	20	57	20	20
39875	2007-02-22	61	60	right	medium	medium	65	67	60	65	73	57	69	64	45	54	62	66	64	53	65	58	62	59	59	48	49	63	71	71	64	16	30	47	12	13	45	8	7
43049	2014-05-16	61	61	right	medium	medium	41	33	61	53	40	41	29	41	47	50	52	52	40	58	39	47	56	76	85	42	84	52	36	43	48	55	60	55	6	7	12	13	7
43049	2014-01-10	62	62	right	medium	medium	41	33	63	53	40	41	29	41	47	50	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	58	60	55	6	7	12	13	7
43049	2013-11-08	62	62	right	medium	medium	41	33	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	58	60	55	6	7	12	13	7
43049	2013-09-20	62	62	right	medium	medium	41	29	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	58	60	55	6	7	12	13	7
43049	2013-04-12	61	61	right	medium	medium	41	29	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	57	58	54	6	7	12	13	7
43049	2013-03-22	61	64	right	medium	medium	41	29	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	57	58	54	6	7	12	13	7
43049	2013-03-15	61	64	right	medium	medium	41	29	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	57	58	54	6	7	12	13	7
43049	2013-02-22	61	64	right	medium	medium	41	29	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	57	58	54	6	7	12	13	7
43049	2013-02-15	61	64	right	medium	medium	41	29	63	53	40	42	29	41	47	48	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	57	58	54	6	7	12	13	7
43049	2012-08-31	65	65	right	medium	medium	41	29	63	53	40	42	29	41	47	52	52	52	40	61	39	47	56	76	85	42	84	52	36	43	48	63	68	61	6	7	12	13	7
43049	2012-02-22	64	64	right	medium	medium	41	29	63	53	40	42	29	41	47	52	52	52	40	61	39	47	56	76	79	42	84	62	36	43	48	63	62	61	6	7	12	13	7
43049	2011-08-30	63	64	right	medium	medium	41	29	63	53	40	42	29	41	47	52	52	52	40	61	39	47	56	66	79	42	69	62	36	43	48	63	62	61	6	7	12	13	7
43049	2011-02-22	65	70	right	medium	medium	52	30	65	54	41	43	30	42	48	53	57	62	53	62	70	51	62	67	74	43	70	65	37	51	49	65	67	64	6	7	12	13	7
43049	2010-08-30	67	70	right	medium	medium	52	30	65	54	41	45	30	42	48	55	58	63	53	62	70	51	67	69	75	43	73	65	37	51	49	67	70	69	6	7	12	13	7
43049	2010-02-22	67	70	right	medium	medium	52	30	65	54	41	45	30	42	48	55	58	63	53	62	70	51	67	69	75	43	73	60	66	51	58	67	70	69	6	23	48	23	23
43049	2009-08-30	68	75	right	medium	medium	52	30	66	54	41	45	30	42	48	55	63	63	53	62	70	51	67	69	75	43	73	60	66	51	58	66	70	69	6	23	48	23	23
43049	2008-08-30	62	68	right	medium	medium	43	32	63	58	41	53	30	47	45	57	54	56	53	51	70	58	67	69	71	49	66	58	57	51	46	66	60	69	6	23	45	23	23
43049	2007-08-30	65	68	right	medium	medium	43	60	63	58	41	53	30	47	45	57	54	56	53	51	70	58	67	69	63	49	58	58	57	51	46	66	65	69	6	23	45	23	23
43049	2007-02-22	64	65	right	medium	medium	42	59	62	57	41	52	30	45	44	56	53	55	53	50	70	57	67	68	62	48	57	58	57	51	45	65	64	69	6	9	44	7	11
41109	2010-08-30	67	72	right	\N	\N	59	35	62	62	32	64	56	45	57	66	58	62	68	62	67	60	58	65	70	46	74	64	34	72	63	72	68	66	15	12	10	15	6
41109	2010-02-22	65	67	right	\N	\N	54	35	62	62	32	46	56	45	57	60	58	62	68	64	67	60	58	61	70	46	74	71	73	72	72	65	66	66	9	25	57	25	25
41109	2009-08-30	66	69	right	\N	\N	64	35	62	67	32	64	56	45	57	66	58	62	68	67	67	60	58	59	70	46	74	73	73	72	74	66	68	66	9	25	57	25	25
41109	2008-08-30	63	64	right	\N	\N	41	35	58	55	32	57	56	45	45	62	58	62	68	67	67	60	58	59	70	46	74	60	73	72	65	62	63	66	9	25	45	25	25
41109	2007-08-30	62	62	right	\N	\N	41	35	58	55	32	57	56	45	45	62	58	62	68	67	67	60	58	59	70	46	59	60	73	72	65	61	63	66	9	25	45	25	25
41109	2007-02-22	70	72	right	\N	\N	39	35	73	40	32	39	56	65	45	39	60	60	68	69	67	69	58	69	79	46	74	60	73	72	65	71	72	66	9	11	45	9	8
37085	2008-08-30	64	65	right	\N	\N	60	43	60	65	\N	46	\N	43	63	56	60	61	\N	60	\N	63	\N	70	62	55	71	74	75	\N	69	55	64	\N	13	24	63	24	24
37085	2007-08-30	63	66	right	\N	\N	60	43	64	64	\N	60	\N	43	64	59	67	68	\N	62	\N	63	\N	66	64	55	71	74	75	\N	69	55	64	\N	13	24	64	24	24
37085	2007-02-22	63	66	right	\N	\N	60	43	64	64	\N	60	\N	69	64	59	67	68	\N	62	\N	63	\N	66	64	55	71	74	75	\N	69	55	64	\N	13	12	64	13	12
39145	2016-04-21	69	69	right	high	medium	62	64	47	65	62	75	58	56	63	72	77	73	82	74	81	68	69	81	57	63	55	44	58	66	62	15	40	25	11	12	8	7	15
39145	2015-09-21	69	69	right	high	medium	62	64	47	65	62	75	58	56	63	72	77	73	82	74	81	68	69	81	57	63	55	44	58	65	62	15	40	25	11	12	8	7	15
39145	2015-07-03	68	68	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	81	57	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2015-06-12	68	68	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	81	57	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2015-01-09	68	68	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	81	57	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2014-10-24	68	68	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	81	57	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2014-09-18	68	68	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	81	57	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2013-12-20	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	80	58	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2013-10-11	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	80	58	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2013-09-20	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	67	80	58	62	54	43	57	64	61	25	39	24	10	11	7	6	14
39145	2013-05-31	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	66	80	56	62	54	43	57	64	61	14	39	24	10	11	7	6	14
39145	2013-02-22	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	66	80	56	62	54	43	57	64	61	14	39	24	10	11	7	6	14
39145	2013-02-15	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	71	77	74	82	73	81	67	66	80	56	62	54	43	57	64	61	14	39	24	10	11	7	6	14
39145	2012-08-31	68	69	right	high	medium	61	63	46	64	61	74	57	55	62	72	77	75	82	69	81	67	66	78	51	62	54	43	57	64	51	14	39	24	10	11	7	6	14
39145	2012-02-22	66	68	right	high	medium	61	52	46	64	61	69	57	55	62	68	77	73	76	64	81	58	66	69	48	60	54	43	57	64	51	14	39	24	10	11	7	6	14
39145	2011-08-30	64	68	right	high	medium	61	52	46	64	61	69	57	55	62	68	77	75	76	64	81	58	66	69	48	60	54	43	57	64	51	14	39	24	10	11	7	6	14
39145	2011-02-22	63	69	left	high	medium	59	52	46	64	61	69	57	55	62	68	62	67	71	64	42	58	63	67	47	60	54	43	61	64	51	14	39	24	10	11	7	6	14
39145	2010-08-30	63	69	right	high	medium	59	52	46	64	61	69	57	55	62	68	62	67	71	64	42	58	63	67	47	60	54	43	61	64	51	14	39	24	10	11	7	6	14
39145	2009-08-30	62	69	right	high	medium	59	52	46	64	61	69	57	55	62	68	62	67	71	64	42	58	63	67	47	60	54	62	55	64	63	23	39	24	15	23	62	23	23
39145	2008-08-30	62	69	right	high	medium	59	52	46	64	61	69	57	55	62	68	62	67	71	64	42	58	63	67	47	60	54	62	55	64	63	23	39	24	15	23	62	23	23
39145	2007-08-30	64	69	right	high	medium	59	52	46	64	61	69	57	55	62	68	62	67	71	64	42	58	63	67	47	60	54	62	55	64	63	23	39	24	15	23	62	23	23
39145	2007-02-22	60	63	right	high	medium	52	52	42	59	61	64	57	63	46	65	65	66	71	43	42	58	63	69	36	53	54	62	55	64	63	14	23	24	15	10	46	12	7
17276	2014-07-18	68	68	right	high	medium	62	63	64	62	67	72	55	55	51	69	82	81	80	64	66	73	83	79	75	66	60	32	67	58	59	25	45	26	11	9	8	13	5
17276	2014-04-11	68	68	right	high	medium	62	63	64	62	67	72	55	55	51	69	82	81	80	64	66	73	83	79	75	66	60	32	67	58	59	25	45	26	11	9	8	13	5
17276	2014-03-21	68	68	right	high	medium	62	63	64	62	67	72	55	55	51	69	82	81	80	64	66	73	83	79	75	66	60	32	67	58	59	25	45	26	11	9	8	13	5
17276	2014-01-31	67	67	right	high	medium	62	63	64	62	67	72	55	55	51	69	82	81	80	64	66	73	83	79	75	66	60	32	67	58	59	25	45	26	11	9	8	13	5
17276	2014-01-24	70	70	right	high	medium	63	71	64	65	75	74	56	56	53	69	87	85	84	71	66	78	91	79	75	67	64	32	69	65	69	25	45	26	11	9	8	13	5
17276	2014-01-10	70	70	right	high	medium	64	71	65	66	76	74	56	56	53	69	87	85	84	71	66	78	91	79	75	67	64	36	69	65	69	25	45	26	11	9	8	13	5
17276	2013-11-01	70	70	right	high	medium	64	71	65	66	76	74	56	56	53	69	87	85	84	72	66	78	91	79	75	67	65	36	72	67	69	25	45	26	11	9	8	13	5
17276	2013-09-20	70	70	right	high	medium	64	71	65	66	76	74	56	56	53	69	87	85	84	72	66	78	91	79	73	67	65	36	71	67	69	25	45	26	11	9	8	13	5
17276	2013-02-15	67	67	right	high	medium	57	71	62	64	62	67	56	37	47	64	87	85	84	72	66	72	91	80	67	67	64	36	70	67	65	13	45	26	11	9	8	13	5
17276	2012-08-31	69	69	right	high	medium	57	70	60	64	62	67	56	37	47	64	87	85	84	72	65	72	91	78	67	67	64	36	70	67	65	13	45	26	11	9	8	13	5
17276	2012-02-22	70	70	right	high	medium	56	70	55	64	63	68	56	37	47	67	87	85	84	73	68	72	91	78	70	67	65	36	73	67	65	13	45	26	11	9	8	13	5
17276	2011-08-30	70	71	right	high	medium	56	70	55	64	63	68	56	37	47	67	87	87	88	73	68	72	89	78	70	67	65	36	73	67	65	13	45	26	11	9	8	13	5
17276	2011-02-22	68	73	right	high	medium	48	67	55	59	60	68	56	37	42	65	83	80	81	73	74	72	80	74	68	66	67	30	69	61	65	13	45	26	11	9	8	13	5
17276	2010-08-30	67	71	right	high	medium	48	67	45	59	61	67	56	37	42	65	83	80	81	73	73	72	80	74	68	60	67	30	65	61	62	13	45	26	11	9	8	13	5
17276	2009-08-30	67	70	right	high	medium	48	67	45	59	61	67	56	37	42	65	83	80	81	73	73	72	80	74	68	58	67	59	57	61	57	20	29	26	9	20	42	20	20
17276	2008-08-30	65	67	right	high	medium	48	66	51	56	61	67	56	37	39	65	80	78	81	67	73	65	80	72	62	56	55	54	53	61	56	20	29	26	10	20	39	20	20
17276	2007-08-30	62	63	right	high	medium	48	58	44	48	61	62	56	37	29	57	71	74	81	62	73	60	80	68	53	49	51	54	53	61	56	23	29	26	10	20	29	20	20
17276	2007-02-22	62	63	right	high	medium	48	58	44	48	61	62	56	37	29	57	71	74	81	62	73	60	80	68	53	49	51	54	53	61	56	23	29	26	10	20	29	20	20
185388	2013-12-27	72	72	right	high	medium	42	75	73	59	72	68	63	57	34	67	79	82	81	74	54	68	80	82	74	60	53	21	74	67	70	25	25	22	8	9	12	14	9
185388	2013-05-31	72	72	right	high	medium	42	75	73	59	72	68	63	57	34	67	79	82	81	74	54	68	80	82	74	60	53	21	74	67	70	25	25	22	8	9	12	14	9
185388	2013-05-10	72	72	right	high	medium	42	75	72	59	72	68	63	57	34	67	79	82	81	74	54	68	80	82	74	60	53	21	74	67	70	25	25	22	8	9	12	14	9
185388	2013-02-15	72	72	right	high	medium	42	75	72	59	72	68	63	57	34	67	79	82	81	74	54	68	80	82	74	60	53	21	74	67	70	25	25	22	8	9	12	14	9
185388	2012-08-31	73	73	right	high	medium	42	78	72	59	72	68	63	57	34	67	76	82	82	78	62	68	77	74	64	62	53	21	78	67	70	25	25	22	8	9	12	14	9
185388	2010-02-22	73	73	right	high	medium	42	78	72	59	72	68	63	57	34	67	76	82	82	78	62	68	77	74	64	62	53	21	78	67	70	25	25	22	8	9	12	14	9
185388	2007-02-22	73	73	right	high	medium	42	78	72	59	72	68	63	57	34	67	76	82	82	78	62	68	77	74	64	62	53	21	78	67	70	25	25	22	8	9	12	14	9
148314	2016-05-05	72	72	right	medium	medium	68	40	69	73	47	61	64	37	69	69	79	78	83	74	75	63	86	82	68	57	72	72	58	59	47	73	71	74	16	10	6	9	14
148314	2016-03-10	73	73	right	medium	medium	68	40	69	70	47	67	64	37	68	69	79	78	83	74	75	63	88	82	68	57	72	72	58	59	47	74	74	74	16	10	6	9	14
148314	2015-10-30	74	74	right	medium	high	68	40	69	70	47	67	64	37	68	69	79	78	83	74	75	63	88	82	68	57	72	72	58	59	47	74	74	74	16	10	6	9	14
148314	2015-10-23	74	75	right	medium	high	68	40	69	70	47	67	64	37	68	69	79	78	83	74	75	63	88	82	68	57	72	72	58	59	47	74	74	74	16	10	6	9	14
148314	2015-09-21	74	75	right	medium	high	68	40	69	70	47	67	64	37	68	69	79	78	83	74	75	63	88	82	68	57	78	72	58	59	47	74	74	74	16	10	6	9	14
148314	2015-05-22	72	73	right	medium	high	67	39	68	69	46	66	63	36	67	68	79	82	83	73	75	62	85	82	68	56	71	71	57	58	46	70	71	70	15	9	5	8	13
148314	2015-05-15	72	73	right	medium	high	67	39	68	69	46	66	63	36	67	68	79	82	83	73	75	62	85	82	68	56	71	71	57	58	46	72	73	71	15	9	5	8	13
148314	2015-04-10	72	73	right	medium	high	69	39	68	69	46	66	63	36	67	68	79	82	83	73	75	62	85	82	68	56	69	71	57	58	46	72	73	71	15	9	5	8	13
148314	2015-02-20	72	73	right	high	medium	69	39	68	69	46	66	63	36	67	68	79	82	83	73	75	62	85	82	68	56	69	71	57	58	46	72	73	71	15	9	5	8	13
148314	2014-09-18	72	73	right	high	medium	69	39	68	69	46	66	63	36	67	68	79	82	83	73	75	62	85	82	68	56	69	71	57	58	46	72	73	71	15	9	5	8	13
148314	2014-04-04	72	73	right	high	medium	69	39	68	69	46	66	63	36	67	68	79	82	83	73	75	62	83	81	68	56	69	71	57	58	46	72	73	71	15	9	5	8	13
148314	2014-01-03	73	74	right	high	medium	69	49	68	69	46	66	63	36	67	68	79	82	83	74	75	62	83	81	68	58	69	72	57	58	46	73	74	72	15	9	5	8	13
148314	2013-12-06	73	75	right	high	medium	69	49	68	69	46	66	63	36	67	68	79	82	83	74	75	62	83	81	68	58	69	72	57	58	46	73	74	72	15	9	5	8	13
148314	2013-10-11	73	75	right	high	medium	69	49	68	69	46	66	63	36	67	68	79	82	83	74	75	62	83	81	68	58	69	72	57	58	46	73	74	72	15	9	5	8	13
148314	2013-09-20	72	75	right	high	medium	68	49	67	69	46	66	63	36	67	68	79	82	83	73	75	62	83	81	68	58	69	71	57	58	46	73	74	72	15	9	5	8	13
148314	2013-03-22	72	75	right	high	medium	68	49	67	69	46	66	63	36	67	68	79	82	83	73	75	62	83	81	68	58	69	71	57	58	46	73	74	72	15	9	5	8	13
148314	2013-03-08	72	75	right	high	medium	68	49	67	69	46	66	63	36	67	68	79	82	83	73	75	62	83	81	68	58	69	71	57	58	46	73	74	72	15	9	5	8	13
148314	2013-02-22	72	75	right	high	medium	68	49	67	69	46	66	63	36	67	68	79	82	83	73	75	62	83	81	68	58	69	71	57	58	46	73	74	72	15	9	5	8	13
148314	2013-02-15	72	75	right	high	medium	68	49	67	69	46	66	63	36	67	68	79	82	83	73	75	62	83	81	68	58	69	71	57	54	46	73	74	72	15	9	5	8	13
148314	2012-08-31	72	75	right	high	medium	68	49	67	69	46	66	63	36	66	68	79	82	83	73	74	62	82	78	68	58	66	68	57	60	46	73	74	72	15	9	5	8	13
148314	2012-02-22	71	75	right	high	medium	68	49	66	69	46	66	63	36	66	68	79	82	83	71	74	62	82	78	66	58	63	66	57	60	46	72	73	71	15	9	5	8	13
148314	2011-08-30	71	75	right	high	medium	68	49	66	69	46	66	63	36	66	68	79	82	83	71	74	62	81	78	66	58	63	66	57	60	46	72	73	71	15	9	5	8	13
148314	2011-02-22	66	71	right	high	medium	58	49	60	66	42	63	48	36	59	68	72	69	68	65	63	57	69	65	68	58	66	66	48	59	41	68	65	67	15	9	5	8	13
148314	2010-08-30	66	71	right	high	medium	58	49	60	66	42	63	48	36	59	68	72	69	68	65	63	57	69	65	68	58	66	66	58	59	41	68	65	67	15	9	5	8	13
148314	2009-08-30	63	71	right	high	medium	52	46	57	55	42	38	48	33	59	56	72	69	68	64	63	51	69	63	66	47	65	59	62	59	48	63	62	67	9	21	59	21	21
148314	2008-08-30	54	68	right	high	medium	52	28	49	50	42	38	48	33	43	42	64	65	68	64	63	51	69	63	54	37	65	30	30	59	31	54	51	67	9	21	43	21	21
148314	2007-02-22	54	68	right	high	medium	52	28	49	50	42	38	48	33	43	42	64	65	68	64	63	51	69	63	54	37	65	30	30	59	31	54	51	67	9	21	43	21	21
37021	2013-03-04	63	63	right	medium	medium	44	54	64	54	32	45	30	37	49	55	62	55	53	58	61	64	77	76	72	47	72	57	55	52	45	63	62	61	5	9	10	11	14
37021	2013-02-15	63	63	right	medium	medium	44	54	64	54	32	45	30	37	49	55	62	55	53	58	61	64	77	76	72	47	72	57	55	52	45	63	62	61	5	9	10	11	14
37021	2012-08-31	63	63	right	medium	medium	44	54	64	54	32	45	30	37	49	55	62	59	52	58	58	64	74	75	72	47	72	57	55	52	45	63	62	61	5	9	10	11	14
37021	2012-02-22	62	65	right	medium	medium	44	54	64	54	32	42	30	37	49	52	62	58	52	58	63	64	74	75	70	47	72	57	55	52	45	62	61	60	5	9	10	11	14
37021	2011-08-30	63	63	right	medium	medium	44	54	64	54	32	45	30	37	49	55	62	59	52	58	66	64	79	77	72	47	72	57	55	52	45	63	62	61	5	9	10	11	14
37021	2011-02-22	63	67	right	medium	medium	44	54	64	54	32	45	30	37	49	55	62	64	56	58	70	64	65	75	69	47	72	57	55	52	45	63	62	61	5	9	10	11	14
37021	2010-08-30	65	67	right	medium	medium	44	57	67	55	32	27	30	37	51	47	62	64	56	58	72	65	65	67	70	47	74	65	57	59	45	64	65	63	5	9	10	11	14
37021	2009-08-30	64	65	right	medium	medium	44	57	67	55	32	27	30	37	51	47	62	64	56	58	72	65	65	67	70	47	74	58	57	59	63	64	65	63	10	25	51	25	25
37021	2008-08-30	63	65	right	medium	medium	39	54	62	50	32	27	30	37	46	39	62	63	56	60	72	67	65	67	71	40	74	48	47	59	53	64	65	63	10	25	46	25	25
37021	2007-08-30	59	59	right	medium	medium	39	54	58	40	32	27	30	37	46	39	54	59	56	40	72	47	65	57	61	40	65	38	42	59	45	64	59	63	10	25	46	25	25
37021	2007-02-22	59	59	right	medium	medium	39	54	58	40	32	27	30	45	46	39	54	59	56	40	72	47	65	57	61	40	65	38	42	59	45	64	59	63	10	10	46	14	9
94284	2015-10-09	66	67	right	medium	medium	63	33	58	63	44	56	44	63	58	65	69	68	71	66	75	58	72	65	60	40	68	65	53	59	45	69	68	70	16	13	13	14	6
94284	2015-09-21	66	67	right	medium	medium	63	33	58	63	44	56	44	63	58	65	69	68	71	66	75	58	72	65	60	40	68	65	53	59	45	69	68	70	16	13	13	14	6
94284	2015-04-24	64	66	right	medium	medium	62	32	57	62	43	55	43	62	57	64	70	70	71	65	75	57	70	65	60	39	67	64	52	58	44	65	65	66	15	12	12	13	5
94284	2015-04-17	64	66	right	medium	medium	60	24	57	62	43	54	43	35	57	62	70	72	71	65	75	54	70	65	60	39	67	64	52	56	44	65	66	66	15	12	12	13	5
94284	2015-01-23	63	64	right	medium	medium	60	24	55	62	43	54	43	35	57	62	70	72	71	65	75	54	70	65	60	39	67	62	52	56	44	64	64	65	15	12	12	13	5
94284	2014-10-24	63	64	right	medium	medium	60	24	55	62	43	54	43	35	57	62	70	72	71	65	75	54	70	65	60	39	67	62	52	56	44	64	64	65	15	12	12	13	5
94284	2014-09-18	64	66	right	medium	medium	60	24	55	62	43	54	43	35	57	62	73	73	72	67	77	54	72	68	60	39	68	62	52	56	44	64	64	65	15	12	12	13	5
94284	2013-12-20	64	68	right	medium	medium	60	24	55	62	43	54	43	35	57	62	73	73	72	67	77	54	70	68	60	39	68	62	52	56	44	64	64	65	15	12	12	13	5
94284	2013-09-20	64	68	right	medium	medium	60	24	55	62	43	54	43	35	57	62	73	73	72	67	77	54	70	68	60	39	68	62	52	56	44	64	64	65	15	12	12	13	5
94284	2013-02-15	64	68	right	medium	medium	60	24	55	62	43	54	43	35	57	62	73	73	72	67	77	54	69	68	60	39	68	62	52	56	44	64	64	65	15	12	12	13	5
94284	2012-08-31	64	68	right	medium	medium	60	24	55	62	43	54	43	35	57	62	73	74	72	67	76	54	68	68	57	39	68	62	52	56	44	64	64	65	15	12	12	13	5
94284	2011-08-30	65	69	right	medium	medium	63	24	55	64	43	48	43	35	61	59	71	74	70	64	76	60	68	68	57	39	64	62	52	56	44	67	67	68	15	12	12	13	5
94284	2011-02-22	63	67	right	medium	medium	60	24	53	63	43	46	43	35	56	56	69	72	67	64	55	60	65	67	56	39	64	61	51	57	44	65	65	66	15	12	12	13	5
94284	2010-08-30	63	67	right	medium	medium	60	24	53	63	43	46	43	35	56	56	69	72	67	64	55	60	65	67	56	39	64	61	51	57	44	65	65	66	15	12	12	13	5
94284	2010-02-22	63	67	right	medium	medium	60	24	53	63	43	46	43	35	56	56	69	72	67	64	55	60	65	67	56	39	64	60	59	57	58	65	65	66	12	23	56	23	21
94284	2009-08-30	60	67	right	medium	medium	56	24	51	55	43	46	43	35	53	53	67	72	67	62	55	57	65	67	56	39	63	54	56	57	53	60	62	66	12	23	53	23	21
94284	2008-08-30	51	62	right	medium	medium	48	24	48	50	43	27	43	25	32	50	62	65	67	57	55	45	65	56	51	31	50	33	49	57	34	52	46	66	1	23	32	23	23
94284	2007-02-22	51	62	right	medium	medium	48	24	48	50	43	27	43	25	32	50	62	65	67	57	55	45	65	56	51	31	50	33	49	57	34	52	46	66	1	23	32	23	23
11736	2015-10-16	73	73	right	medium	medium	47	38	78	71	35	61	21	35	16	66	49	33	55	71	56	54	72	65	76	42	72	70	58	44	48	75	76	78	8	11	10	16	11
11736	2015-09-21	73	73	right	medium	medium	47	38	78	71	35	61	21	35	16	66	51	34	55	71	56	54	72	65	76	42	72	70	58	44	48	75	76	78	8	11	10	16	11
11736	2014-09-18	74	74	right	medium	medium	46	37	71	66	34	52	20	34	64	65	51	54	57	73	56	53	80	65	74	41	71	76	47	43	47	75	75	76	7	10	9	15	10
11736	2013-09-20	74	74	right	medium	medium	46	37	71	66	34	52	20	34	64	64	51	54	57	73	56	53	80	65	74	41	71	76	47	43	47	75	75	76	7	10	9	15	10
11736	2013-04-19	74	74	right	medium	medium	46	37	71	66	34	52	20	34	64	64	53	54	57	73	56	53	80	65	74	41	71	76	47	43	47	75	75	76	7	10	9	15	10
11736	2013-02-15	73	73	right	medium	medium	46	37	71	66	34	52	20	34	64	62	53	54	57	70	56	53	80	65	74	41	71	75	47	43	47	73	75	76	7	10	9	15	10
11736	2012-08-31	73	77	right	medium	medium	46	37	71	66	34	52	20	34	64	62	53	54	57	70	56	53	80	65	74	41	71	75	47	43	47	73	75	76	7	10	9	15	10
11736	2011-08-30	73	77	right	medium	medium	46	37	71	66	34	52	20	34	64	62	53	54	57	70	56	53	79	65	74	41	71	75	47	43	47	73	75	76	7	10	9	15	10
11736	2011-02-22	72	73	right	medium	medium	46	37	71	66	34	52	20	34	64	62	58	63	57	67	71	53	77	65	74	41	68	72	47	63	47	73	75	76	7	10	9	15	10
11736	2010-08-30	69	72	right	medium	medium	46	37	71	66	34	45	20	34	64	62	50	59	53	67	71	53	65	65	74	41	68	72	47	63	47	68	73	70	7	10	9	15	10
11736	2010-02-22	70	72	right	medium	medium	47	38	72	67	34	46	20	35	65	63	53	60	53	68	71	54	65	67	75	42	69	68	76	63	77	69	74	70	6	23	65	23	23
11736	2009-08-30	68	71	right	medium	medium	56	38	71	67	34	46	20	35	62	63	53	58	53	63	71	54	65	62	72	42	69	70	75	63	76	66	73	70	6	23	62	23	23
11736	2009-02-22	66	69	right	medium	medium	62	40	71	65	34	46	20	35	61	61	51	56	53	60	71	54	65	62	74	42	69	68	72	63	67	60	68	70	6	23	61	23	23
11736	2008-08-30	66	69	right	medium	medium	62	40	71	65	34	37	20	35	61	60	51	56	53	60	71	54	65	62	74	42	69	68	72	63	67	60	68	70	6	23	61	23	23
11736	2007-08-30	66	69	right	medium	medium	62	40	71	65	34	37	20	35	61	54	51	56	53	60	71	54	65	70	74	42	69	68	72	63	67	60	68	70	6	23	61	23	23
11736	2007-02-22	62	65	right	medium	medium	35	40	59	38	34	37	20	57	45	47	56	52	53	50	71	44	65	70	74	42	69	68	72	63	57	60	61	70	6	7	45	15	10
39389	2014-10-02	64	65	left	medium	medium	61	36	54	62	37	65	53	47	60	62	81	74	77	66	70	62	83	71	75	31	87	63	56	54	54	63	61	62	13	11	11	15	5
39389	2014-09-18	65	65	left	medium	medium	62	36	54	62	37	68	53	47	60	62	81	74	77	69	70	62	83	74	75	31	87	63	56	54	54	65	61	64	13	11	11	15	5
39389	2013-09-20	65	68	left	medium	medium	62	36	54	62	37	68	53	47	60	62	81	74	77	69	70	62	81	74	75	31	87	63	56	54	54	65	61	64	13	11	11	15	5
39389	2013-08-16	65	68	left	medium	medium	62	36	54	62	37	68	53	47	60	62	81	74	77	69	70	62	81	74	75	31	87	63	56	54	54	65	61	64	13	11	11	15	5
39389	2013-02-15	65	68	left	medium	medium	62	36	54	62	37	68	53	47	60	62	81	74	77	69	70	62	81	74	75	31	87	63	56	54	54	65	61	64	13	11	11	15	5
39389	2012-08-31	66	68	left	high	medium	62	36	54	62	37	68	53	47	60	62	76	75	77	69	68	62	78	74	75	31	67	66	56	54	54	66	65	68	13	11	11	15	5
39389	2011-08-30	64	65	left	medium	medium	62	36	54	59	37	52	53	47	58	59	73	68	71	65	73	62	78	74	71	31	67	63	56	54	54	64	63	66	13	11	11	15	5
39389	2010-08-30	64	69	left	medium	medium	62	36	54	59	37	52	53	47	58	59	71	73	68	65	67	62	70	72	68	31	67	63	56	53	54	64	63	66	13	11	11	15	5
39389	2010-02-22	62	67	right	medium	medium	58	36	54	56	37	52	53	47	54	57	71	73	68	65	67	62	70	72	62	31	67	56	57	53	60	62	62	66	4	20	54	20	20
39389	2009-08-30	58	67	right	medium	medium	58	36	51	52	37	43	53	47	54	56	63	64	68	62	67	57	70	63	62	31	68	56	55	53	53	59	61	66	4	20	54	20	20
39389	2009-02-22	57	71	right	medium	medium	34	24	20	28	37	23	53	47	36	47	64	63	68	64	67	20	70	57	68	20	68	44	44	53	44	61	66	66	4	20	36	20	20
39389	2007-08-30	57	71	right	medium	medium	34	24	20	28	37	23	53	47	36	47	64	63	68	64	67	20	70	57	68	20	68	44	44	53	44	61	66	66	4	20	36	20	20
39389	2007-02-22	57	71	right	medium	medium	34	24	20	28	37	23	53	47	36	47	64	63	68	64	67	20	70	57	68	20	68	44	44	53	44	61	66	66	4	20	36	20	20
31810	2008-08-30	60	73	right	\N	\N	59	54	54	66	\N	47	\N	41	59	65	62	63	\N	66	\N	58	\N	71	62	43	53	63	62	\N	58	66	67	\N	9	25	59	25	25
31810	2007-02-22	60	73	right	\N	\N	59	54	54	66	\N	47	\N	41	59	65	62	63	\N	66	\N	58	\N	71	62	43	53	63	62	\N	58	66	67	\N	9	25	59	25	25
27110	2014-03-14	60	60	left	low	high	52	27	57	61	33	39	27	49	56	60	46	38	53	53	71	56	46	50	56	39	67	75	43	61	43	54	61	58	9	8	9	11	14
27110	2014-02-14	62	62	left	low	high	54	27	57	61	33	39	27	49	53	60	51	43	58	58	74	58	56	60	61	39	72	75	43	61	43	61	65	63	9	8	9	11	14
27110	2013-11-08	63	63	left	low	high	54	27	57	61	33	39	27	49	53	61	52	43	58	58	74	58	56	62	61	39	74	75	43	61	43	61	65	63	9	8	9	11	14
27110	2013-09-20	63	63	left	low	high	54	27	57	61	33	39	27	49	53	61	52	43	58	58	74	58	56	62	61	39	74	75	43	61	43	61	65	63	9	8	9	11	14
27110	2013-06-07	64	64	left	low	high	54	27	57	61	33	39	27	56	53	61	52	43	58	64	74	58	56	68	61	39	74	75	43	61	43	61	65	63	9	8	9	11	14
27110	2013-05-31	64	64	left	low	high	54	27	57	61	33	39	27	56	53	61	52	43	58	64	74	58	56	68	61	39	74	75	43	61	43	61	65	63	9	8	9	11	14
27110	2013-05-10	64	64	left	low	high	54	27	57	61	33	39	27	56	53	61	52	43	58	64	74	58	56	68	61	39	74	75	43	61	43	61	65	63	9	8	9	11	14
27110	2013-03-28	65	65	left	low	high	56	27	61	63	33	45	27	56	60	61	56	46	61	66	74	60	56	68	61	39	74	75	43	61	43	63	67	66	9	8	9	11	14
27110	2013-03-04	65	65	left	low	high	56	27	61	63	33	45	27	56	60	61	56	46	61	66	74	60	56	68	61	39	74	75	43	61	43	63	67	66	9	8	9	11	14
27110	2013-02-15	65	65	left	low	high	56	27	61	63	33	45	27	56	60	61	56	46	61	66	74	60	56	68	61	39	74	75	43	61	43	63	67	66	9	8	9	11	14
27110	2012-08-31	69	69	left	low	high	54	37	61	66	43	53	27	56	63	63	65	49	62	72	73	63	66	77	70	43	78	74	43	71	63	64	69	68	9	8	9	11	14
27110	2012-02-22	66	66	left	low	high	52	37	61	58	43	42	27	50	53	56	65	49	62	68	76	63	66	77	70	43	78	73	43	71	54	64	69	68	9	8	9	11	14
27110	2011-08-30	66	66	left	low	high	52	37	61	58	43	42	27	50	53	56	65	50	62	68	76	63	66	77	70	43	78	73	43	71	54	64	69	68	9	8	9	11	14
27110	2011-02-22	65	67	left	low	high	52	37	61	58	43	42	27	50	53	56	64	62	61	68	70	63	63	75	62	43	78	73	43	71	54	64	69	68	9	8	9	11	14
27110	2010-08-30	65	67	left	low	high	54	37	61	61	43	42	27	50	56	57	64	62	61	68	70	63	63	75	62	43	78	70	43	71	54	67	69	68	9	8	9	11	14
27110	2009-08-30	65	67	left	low	high	54	37	61	61	43	42	27	50	56	53	64	62	61	68	70	63	63	75	62	43	78	74	72	71	68	67	69	68	11	20	56	20	20
27110	2009-02-22	66	70	left	low	high	54	37	61	61	43	42	27	50	56	53	64	62	61	68	70	63	63	75	62	43	78	74	72	71	68	69	71	68	11	20	56	20	20
27110	2008-08-30	67	69	left	low	high	58	37	61	62	43	47	27	50	56	56	64	62	61	68	70	63	63	75	62	43	78	77	72	71	69	74	76	68	11	20	56	20	20
27110	2007-08-30	65	76	left	low	high	71	41	61	62	43	62	27	50	56	58	64	62	61	68	70	63	63	75	59	43	73	73	69	71	63	78	76	68	11	20	56	20	20
27110	2007-02-22	65	76	left	low	high	71	41	61	62	43	62	27	63	56	58	64	62	61	68	70	63	63	75	59	43	73	73	69	71	63	78	76	68	11	9	56	14	13
26458	2016-02-18	72	72	left	low	medium	45	32	70	70	35	43	33	55	71	68	55	54	58	71	66	63	81	71	73	48	68	72	33	35	59	74	75	73	6	12	6	9	6
26458	2016-01-07	72	72	left	low	medium	45	32	70	70	35	43	33	55	71	68	55	54	58	71	66	63	81	71	73	48	68	72	33	35	59	74	75	73	6	12	6	9	6
26458	2015-09-21	71	71	left	low	medium	45	34	73	59	35	43	33	55	76	68	55	53	58	70	64	63	84	71	74	55	68	70	33	35	59	72	74	73	6	12	6	9	6
26458	2015-04-17	70	70	left	low	medium	44	33	72	58	34	42	32	54	59	53	55	53	58	69	64	62	70	71	74	54	67	74	32	34	58	70	74	72	5	11	5	8	5
26458	2014-12-12	70	70	left	low	medium	44	33	72	58	34	42	32	54	59	53	55	53	58	69	64	62	70	71	74	54	67	74	32	34	58	70	74	72	5	11	5	8	5
26458	2014-11-07	70	70	left	low	medium	44	33	72	58	34	42	32	54	59	53	55	53	58	69	64	62	70	71	74	54	67	74	32	34	58	70	74	72	5	11	5	8	5
26458	2014-10-10	69	69	left	low	medium	44	33	72	58	34	42	32	54	59	53	55	49	58	67	63	62	70	71	74	54	65	72	32	34	58	68	73	72	5	11	5	8	5
26458	2014-09-18	66	66	left	low	medium	44	33	72	58	34	42	32	54	59	53	55	49	58	67	63	62	70	71	74	54	65	72	32	34	58	68	73	72	5	11	5	8	5
26458	2014-03-28	69	69	left	low	medium	49	33	71	69	34	42	32	54	67	53	54	48	58	66	63	62	70	71	74	54	65	72	32	58	58	68	73	71	5	11	5	8	5
26458	2013-09-20	69	69	left	low	medium	49	33	71	69	34	42	32	54	67	53	54	48	58	66	63	62	70	71	74	54	65	70	32	58	58	68	73	71	5	11	5	8	5
26458	2013-05-10	68	69	left	low	medium	49	33	71	69	34	47	32	54	67	58	55	48	58	68	56	62	70	71	72	54	65	69	32	58	58	67	68	71	5	11	5	8	5
26458	2013-04-05	68	69	left	low	medium	49	33	71	69	34	47	32	62	67	58	55	48	58	68	56	62	70	71	72	54	67	68	32	58	63	67	68	69	5	11	5	8	5
26458	2013-03-01	68	69	left	low	medium	49	33	71	68	34	47	32	62	64	58	55	48	58	68	56	62	70	71	72	54	67	68	32	58	63	67	68	69	5	11	5	8	5
26458	2013-02-15	68	69	left	low	medium	49	33	71	68	34	47	32	62	64	58	55	48	58	68	56	62	70	71	74	54	67	68	32	58	63	67	68	69	5	11	5	8	5
26458	2012-08-31	69	71	left	medium	medium	49	33	72	66	34	43	32	62	64	58	55	54	58	65	54	62	63	70	72	54	67	66	32	56	63	69	72	69	5	11	5	8	5
26458	2012-02-22	67	68	left	medium	medium	49	33	68	64	34	43	32	62	63	58	56	53	63	65	43	62	63	73	71	55	67	66	32	56	63	68	70	68	5	11	5	8	5
26458	2011-08-30	68	70	left	medium	medium	49	33	68	66	34	43	32	62	58	58	56	54	63	69	43	62	63	76	71	55	67	66	32	58	63	68	71	72	5	11	5	8	5
26458	2010-08-30	71	75	left	medium	medium	49	33	66	70	34	43	32	62	58	58	63	67	65	71	66	62	72	73	73	55	70	73	32	64	63	75	71	72	5	11	5	8	5
26458	2010-02-22	69	72	left	medium	medium	49	33	62	69	34	43	32	62	58	58	58	66	65	64	66	37	72	72	69	55	69	63	71	64	51	74	69	72	13	22	58	22	22
26458	2009-08-30	69	72	left	medium	medium	49	33	62	69	34	43	32	62	58	58	58	66	65	64	66	37	72	72	69	55	69	63	71	64	51	74	69	72	13	22	58	22	22
26458	2009-02-22	69	74	left	medium	medium	49	33	62	69	34	43	32	62	58	58	61	66	65	68	66	37	72	72	69	55	69	63	71	64	51	74	69	72	13	22	58	22	22
26458	2008-08-30	69	74	left	medium	medium	49	33	62	69	34	43	32	62	53	58	61	66	65	68	66	37	72	72	69	55	69	63	71	64	51	74	69	72	13	22	53	22	22
26458	2007-08-30	68	78	left	medium	medium	49	33	64	62	34	43	32	62	53	58	63	58	65	63	66	37	72	74	72	55	76	63	63	64	51	68	69	72	13	22	53	22	22
26458	2007-02-22	66	78	left	medium	medium	49	33	64	30	34	43	32	43	23	35	63	58	65	63	66	37	72	77	75	38	76	63	63	64	43	68	69	72	13	8	23	15	8
45832	2009-08-30	60	61	left	\N	\N	63	56	57	65	\N	53	\N	72	67	56	58	53	\N	55	\N	65	\N	66	68	67	69	64	67	\N	61	45	56	\N	8	24	67	24	24
45832	2009-02-22	58	60	left	\N	\N	62	52	57	65	\N	53	\N	72	67	50	58	45	\N	55	\N	65	\N	66	68	65	69	55	67	\N	53	45	56	\N	8	24	67	24	24
45832	2007-02-22	58	60	left	\N	\N	62	52	57	65	\N	53	\N	72	67	50	58	45	\N	55	\N	65	\N	66	68	65	69	55	67	\N	53	45	56	\N	8	24	67	24	24
37846	2010-02-22	62	64	left	\N	\N	56	54	34	55	\N	70	\N	45	51	65	71	70	\N	64	\N	55	\N	65	42	55	49	54	55	\N	56	24	24	\N	5	23	51	23	23
37846	2009-08-30	62	64	left	\N	\N	56	54	34	55	\N	70	\N	45	51	65	71	70	\N	64	\N	55	\N	65	42	55	49	54	55	\N	56	24	24	\N	5	23	51	23	23
37846	2009-02-22	62	78	left	\N	\N	56	54	34	55	\N	70	\N	45	51	65	71	70	\N	64	\N	55	\N	65	42	55	49	54	55	\N	56	24	24	\N	5	23	51	23	23
37846	2008-08-30	62	64	left	\N	\N	56	54	34	55	\N	70	\N	45	51	65	71	70	\N	64	\N	55	\N	65	42	55	49	54	55	\N	56	24	24	\N	5	23	51	23	23
37846	2007-08-30	64	64	left	\N	\N	56	54	44	57	\N	72	\N	48	52	67	71	70	\N	64	\N	54	\N	65	42	57	49	54	55	\N	56	34	34	\N	5	23	52	23	23
37846	2007-02-22	62	64	right	\N	\N	64	34	44	63	\N	64	\N	48	54	59	63	59	\N	59	\N	54	\N	54	44	39	49	54	55	\N	48	44	44	\N	5	7	54	13	9
11569	2010-02-22	65	68	right	\N	\N	43	32	64	62	\N	43	\N	38	66	63	60	66	\N	57	\N	63	\N	59	71	68	69	71	69	\N	67	65	67	\N	1	24	66	24	24
11569	2009-08-30	67	69	right	\N	\N	43	32	64	64	\N	43	\N	38	68	65	60	66	\N	57	\N	63	\N	59	71	68	69	71	69	\N	67	68	70	\N	1	24	68	24	24
11569	2008-08-30	60	62	right	\N	\N	43	24	62	64	\N	43	\N	38	53	53	45	60	\N	49	\N	53	\N	54	71	48	54	66	64	\N	62	58	66	\N	1	24	53	24	24
11569	2007-02-22	60	62	right	\N	\N	43	24	62	64	\N	43	\N	38	53	53	45	60	\N	49	\N	53	\N	54	71	48	54	66	64	\N	62	58	66	\N	1	24	53	24	24
39591	2016-01-21	81	82	right	medium	medium	69	71	77	83	67	83	69	68	78	85	67	74	82	81	60	78	72	85	79	74	78	80	75	78	81	69	73	71	5	7	7	10	7
39591	2015-11-06	81	83	right	medium	medium	69	71	77	83	67	83	69	68	78	85	67	74	82	81	60	78	72	85	79	74	78	80	75	78	81	69	73	71	5	7	7	10	7
39591	2015-09-25	81	84	right	medium	medium	69	71	77	83	67	83	69	68	78	85	67	74	82	81	60	78	72	85	79	74	78	80	75	78	81	69	73	71	5	7	7	10	7
39591	2015-09-21	81	84	right	medium	medium	69	71	77	83	67	83	69	68	78	85	67	74	82	81	60	78	72	85	79	74	78	85	75	78	81	69	73	71	5	7	7	10	7
39591	2015-05-15	80	85	right	medium	medium	69	71	77	83	67	83	69	68	78	86	67	74	87	82	60	78	76	85	79	77	78	82	75	78	81	69	73	71	5	7	7	10	7
39591	2014-10-17	80	85	right	medium	medium	70	71	77	83	70	83	69	70	78	86	67	74	87	82	60	78	76	85	79	77	78	82	75	78	77	70	73	71	5	7	7	10	7
39591	2014-10-02	80	85	right	medium	medium	70	71	77	83	70	83	69	70	78	85	67	74	87	82	60	78	76	85	79	77	78	82	75	78	77	70	73	71	5	7	7	10	7
39591	2014-09-18	80	85	right	medium	medium	70	71	77	83	70	83	69	70	78	85	67	74	87	82	60	77	76	85	79	72	78	82	75	78	77	70	73	71	5	7	7	10	7
39591	2013-09-20	80	85	right	medium	medium	70	71	77	83	70	83	69	70	78	85	67	74	87	82	64	77	76	85	79	72	78	82	75	78	77	70	73	71	5	7	7	10	7
39591	2013-08-16	81	87	right	high	medium	75	75	77	83	81	84	80	70	81	87	67	74	86	82	64	77	76	84	79	75	78	74	82	84	81	55	65	68	5	7	7	10	7
39591	2013-02-15	81	87	right	high	medium	75	75	77	83	81	84	80	70	81	87	67	74	86	82	64	77	76	84	79	75	78	74	82	84	81	55	65	68	5	7	7	10	7
39591	2012-08-31	81	87	right	high	medium	75	75	77	83	81	84	80	70	81	87	67	74	86	82	64	77	76	84	79	75	78	74	82	84	81	65	71	74	5	7	7	10	7
39591	2012-02-22	79	84	right	medium	medium	75	75	76	82	67	81	80	70	74	84	67	75	86	79	64	76	74	85	79	75	78	69	79	82	79	65	69	64	5	7	7	10	7
39591	2011-08-30	76	83	right	high	medium	69	75	74	76	67	78	67	70	73	84	69	75	83	74	58	74	73	86	76	75	77	64	78	72	84	57	67	64	5	7	7	10	7
39591	2011-02-22	75	83	right	high	medium	69	71	70	75	66	78	67	70	73	83	67	73	75	74	65	70	67	81	66	74	79	64	74	72	80	56	68	62	5	7	7	10	7
39591	2010-08-30	75	83	right	high	medium	69	71	70	77	66	78	67	70	75	83	69	73	77	74	65	70	67	80	66	74	65	64	76	74	80	64	68	64	5	7	7	10	7
39591	2010-02-22	75	83	right	high	medium	69	71	70	77	66	78	67	70	75	83	69	73	77	74	65	70	67	80	66	74	65	75	72	74	80	64	68	64	1	20	75	20	20
39591	2009-08-30	75	83	right	high	medium	67	71	70	77	66	78	67	70	75	83	65	75	77	74	65	70	67	80	66	74	62	75	72	74	80	64	65	64	1	20	75	20	20
39591	2009-02-22	75	83	right	high	medium	67	71	66	77	66	78	67	70	75	83	67	75	77	74	65	69	67	78	67	74	62	67	72	74	80	62	65	64	1	20	75	20	20
39591	2008-08-30	71	84	right	high	medium	67	69	66	73	66	77	67	62	68	75	67	70	77	72	65	69	67	73	67	67	55	65	72	74	73	66	67	64	1	20	68	20	20
39591	2007-08-30	68	74	right	high	medium	63	57	64	68	66	69	67	62	65	72	67	69	77	64	65	67	67	73	67	65	52	54	49	74	53	48	53	64	1	20	65	20	20
39591	2007-02-22	55	73	right	high	medium	53	35	54	48	66	57	67	43	43	62	63	65	77	56	65	56	67	64	66	41	52	54	49	74	43	43	46	64	1	1	43	1	1
46580	2008-08-30	59	67	right	\N	\N	37	41	69	52	\N	63	\N	38	57	52	65	62	\N	62	\N	38	\N	68	68	32	63	55	64	\N	67	53	63	\N	2	20	57	20	20
46580	2007-02-22	59	67	right	\N	\N	37	41	69	52	\N	63	\N	38	57	52	65	62	\N	62	\N	38	\N	68	68	32	63	55	64	\N	67	53	63	\N	2	20	57	20	20
107416	2009-08-30	54	72	left	\N	\N	47	23	49	49	\N	41	\N	30	48	46	64	66	\N	58	\N	48	\N	61	64	33	62	44	46	\N	51	52	50	\N	5	21	48	21	21
107416	2009-02-22	44	75	right	\N	\N	27	23	37	39	\N	21	\N	30	38	38	46	46	\N	47	\N	21	\N	41	42	21	49	19	22	\N	21	44	49	\N	5	21	38	21	21
107416	2008-08-30	41	75	right	\N	\N	27	23	21	39	\N	21	\N	30	38	38	46	46	\N	47	\N	21	\N	41	42	21	49	19	22	\N	21	44	49	\N	5	21	38	21	21
107416	2007-02-22	41	75	right	\N	\N	27	23	21	39	\N	21	\N	30	38	38	46	46	\N	47	\N	21	\N	41	42	21	49	19	22	\N	21	44	49	\N	5	21	38	21	21
106013	2016-04-07	74	76	right	low	high	47	62	72	68	48	65	34	35	62	72	72	74	64	77	64	72	82	84	75	58	90	78	54	62	33	75	76	74	11	15	8	10	11
106013	2015-12-24	75	77	right	low	high	47	62	69	72	48	65	34	35	68	72	72	74	64	77	64	72	82	86	75	58	90	78	48	62	33	75	76	74	11	15	8	10	11
106013	2015-11-06	75	77	right	low	high	47	62	69	72	48	65	34	35	70	72	72	74	64	77	64	72	82	86	75	58	90	78	48	62	33	75	76	74	11	15	8	10	11
106013	2015-10-23	75	78	right	low	high	47	62	69	72	48	65	34	35	70	72	72	74	64	77	64	72	82	86	75	58	90	78	48	62	33	75	76	74	11	15	8	10	11
106013	2015-10-09	76	81	right	medium	high	47	52	69	74	55	72	34	35	70	74	72	74	64	77	64	72	82	86	75	65	90	78	58	62	33	75	76	75	11	15	8	10	11
106013	2015-10-02	76	81	right	medium	high	47	52	69	74	55	72	34	35	72	74	72	74	64	77	64	72	82	86	75	65	88	78	58	65	33	75	76	75	11	15	8	10	11
106013	2015-09-25	77	82	right	medium	high	47	52	69	76	55	72	34	35	74	74	72	74	64	77	64	72	80	86	75	65	88	78	58	65	33	75	76	75	11	15	8	10	11
106013	2015-09-21	76	81	right	medium	high	47	52	69	76	55	72	34	35	74	74	72	74	64	75	64	72	80	86	75	65	88	78	58	65	33	75	76	75	11	15	8	10	11
106013	2015-05-08	72	77	right	medium	medium	46	45	68	75	54	67	33	34	70	72	72	68	64	68	64	71	80	82	75	64	85	72	57	64	32	68	74	70	10	14	7	9	10
106013	2015-04-24	72	77	right	medium	medium	53	45	68	75	54	67	33	34	70	72	72	68	64	68	64	71	80	82	75	64	85	72	57	64	32	68	74	67	10	14	7	9	10
106013	2015-02-20	72	77	right	medium	medium	53	45	68	75	54	67	33	34	70	72	72	68	64	68	64	71	80	82	75	64	83	72	57	66	32	68	74	67	10	14	7	9	10
106013	2015-01-09	72	77	right	medium	medium	53	45	68	75	54	67	33	34	70	72	72	68	64	68	64	71	77	76	75	64	83	72	57	66	32	68	74	67	10	14	7	9	10
106013	2014-11-28	71	77	right	medium	medium	53	45	68	74	54	67	33	34	69	71	72	68	64	68	64	71	77	73	73	64	83	70	57	66	32	63	74	67	10	14	7	9	10
106013	2014-11-14	69	75	right	medium	medium	53	42	68	72	38	65	33	34	67	68	72	67	62	66	64	64	77	68	73	56	83	66	54	66	32	62	73	67	10	14	7	9	10
106013	2014-11-07	69	75	right	medium	medium	53	42	68	72	38	65	33	34	67	68	72	67	62	66	64	64	77	68	73	56	83	66	54	66	32	62	73	67	10	14	7	9	10
106013	2014-10-10	67	69	right	medium	medium	53	42	68	68	38	63	33	34	63	67	72	67	62	66	64	64	77	68	73	56	83	65	50	55	32	62	71	67	10	14	7	9	10
106013	2014-09-18	65	69	right	medium	medium	53	39	68	66	38	56	33	34	61	63	72	67	62	64	64	60	77	65	73	51	83	61	43	54	32	63	71	68	10	14	7	9	10
106013	2011-02-22	65	69	right	medium	medium	53	39	68	66	38	56	33	34	61	63	72	67	62	64	64	60	77	65	73	51	83	61	43	54	32	63	71	68	10	14	7	9	10
106013	2010-08-30	69	69	right	medium	medium	53	39	68	70	38	61	33	34	61	73	72	67	62	64	64	60	77	65	73	51	83	61	43	54	32	66	71	68	10	14	7	9	10
106013	2010-02-22	66	69	right	medium	medium	53	39	68	64	38	47	33	34	61	57	68	73	62	64	64	67	77	81	73	31	83	56	53	54	63	66	71	68	11	22	57	22	22
106013	2009-08-30	61	73	right	medium	medium	53	29	56	65	38	43	33	34	56	53	65	70	62	58	64	65	77	78	73	31	80	43	45	54	47	61	66	68	1	22	56	22	22
106013	2008-08-30	57	73	right	medium	medium	38	29	53	51	38	39	33	34	48	51	65	69	62	57	64	65	77	72	76	31	77	31	33	54	42	61	64	68	1	22	48	22	22
106013	2007-02-22	57	73	right	medium	medium	38	29	53	51	38	39	33	34	48	51	65	69	62	57	64	65	77	72	76	31	77	31	33	54	42	61	64	68	1	22	48	22	22
9307	2011-02-22	66	67	right	\N	\N	43	43	62	60	48	49	38	33	58	60	63	64	58	68	75	82	65	82	71	69	85	67	55	65	53	62	67	65	6	7	8	5	12
9307	2010-08-30	66	67	right	\N	\N	43	43	62	60	48	49	38	33	58	60	63	64	58	68	75	76	65	82	71	69	82	67	55	65	53	62	67	65	6	7	8	5	12
9307	2010-02-22	66	67	right	\N	\N	43	43	62	60	48	48	38	33	58	60	63	64	58	65	75	76	65	82	71	69	82	71	73	65	68	60	67	65	8	20	58	20	20
9307	2009-08-30	66	67	right	\N	\N	43	43	62	60	48	48	38	33	58	60	63	64	58	65	75	76	65	82	71	69	82	71	73	65	68	60	66	65	8	20	58	20	20
9307	2008-08-30	65	67	right	\N	\N	43	43	62	60	48	48	38	33	58	58	63	64	58	65	75	75	65	83	71	65	82	71	73	65	68	60	62	65	8	20	58	20	20
9307	2007-08-30	63	67	right	\N	\N	43	43	62	60	48	48	38	33	58	58	63	64	58	65	75	75	65	83	71	65	82	71	73	65	68	60	62	65	8	20	58	20	20
9307	2007-02-22	63	67	right	\N	\N	43	43	62	60	48	48	38	33	58	58	63	64	58	65	75	75	65	83	71	65	82	71	73	65	68	60	62	65	8	20	58	20	20
37889	2016-03-03	66	66	left	high	medium	68	36	55	67	37	63	61	56	65	66	68	70	73	65	73	61	79	70	62	40	67	65	60	64	46	65	63	70	13	6	12	11	11
37889	2015-09-21	67	67	left	high	medium	70	36	55	67	37	63	61	56	65	66	68	70	73	65	73	61	79	72	62	40	70	65	60	64	46	67	64	70	13	6	12	11	11
37889	2015-05-08	66	66	left	high	medium	69	35	57	66	36	63	60	55	64	65	72	72	73	66	73	60	79	72	62	39	69	64	59	63	45	65	65	67	12	5	11	10	10
37889	2015-01-09	66	67	left	high	medium	69	35	57	66	36	63	60	55	64	65	72	72	73	66	73	60	79	72	62	39	69	64	59	63	45	65	65	67	12	5	11	10	10
37889	2014-09-18	66	67	left	high	medium	69	35	57	66	36	63	60	55	64	65	72	72	73	66	73	60	79	72	62	39	69	64	59	63	45	65	65	67	12	5	11	10	10
37889	2013-09-20	66	67	left	high	medium	69	35	57	66	36	63	60	55	64	65	72	72	73	66	73	60	77	72	62	39	69	64	59	63	45	65	65	67	12	5	11	10	10
37889	2013-02-22	67	68	left	high	medium	69	35	57	66	36	63	60	55	64	65	72	72	73	67	73	60	76	72	62	39	69	65	59	63	45	66	66	68	12	5	11	10	10
37889	2013-02-15	66	68	left	high	medium	68	35	56	66	36	62	60	55	63	65	72	72	73	65	73	60	76	72	62	39	69	64	59	58	45	66	66	65	12	5	11	10	10
37889	2012-08-31	66	68	left	high	medium	68	35	56	66	36	62	60	55	63	65	72	73	73	65	71	60	73	72	60	39	69	64	59	58	45	66	66	65	12	5	11	10	10
37889	2012-02-22	66	68	left	high	medium	68	35	56	66	36	62	60	55	63	65	72	73	73	65	71	60	73	79	60	39	69	64	59	58	45	66	66	65	12	5	11	10	10
37889	2011-08-30	68	72	left	high	medium	64	35	56	67	36	62	60	57	64	66	72	73	73	66	71	60	73	79	60	39	70	67	59	58	45	67	69	69	12	5	11	10	10
37889	2010-08-30	67	69	left	high	medium	64	35	56	65	36	62	61	57	59	65	69	74	72	67	59	64	67	75	57	39	70	66	62	65	45	67	69	69	12	5	11	10	10
37889	2010-02-22	64	69	left	high	medium	60	28	54	62	36	47	61	37	55	57	69	72	72	64	59	60	67	73	55	39	70	62	59	65	57	65	67	69	21	23	55	23	23
37889	2009-08-30	63	69	left	high	medium	60	28	53	62	36	47	61	37	54	55	69	72	72	62	59	57	67	73	55	39	69	62	57	65	55	64	65	69	21	23	54	23	23
37889	2009-02-22	60	65	left	high	medium	55	28	53	57	36	37	61	31	52	47	65	67	72	62	59	57	67	70	55	36	59	54	55	65	53	62	63	69	1	23	52	23	23
37889	2008-08-30	55	64	left	high	medium	52	28	55	49	36	35	61	31	44	43	61	63	72	58	59	56	67	62	53	36	56	44	48	65	46	58	55	69	1	23	44	23	23
37889	2007-08-30	54	64	left	high	medium	52	28	55	49	36	35	61	31	44	43	61	63	72	58	59	56	67	62	53	36	56	44	48	65	46	58	55	69	1	23	44	23	23
37889	2007-02-22	54	64	left	high	medium	52	28	55	49	36	35	61	46	44	43	61	63	72	58	59	56	67	62	53	36	56	44	48	65	46	58	55	69	1	1	44	1	1
38371	2012-02-22	66	66	left	high	medium	68	64	57	70	66	63	65	58	66	66	53	56	58	65	63	69	34	67	71	65	63	62	73	73	69	42	54	52	7	5	5	12	15
38371	2011-08-30	66	66	left	high	medium	69	64	57	70	66	64	65	58	66	65	54	57	61	67	65	69	34	64	71	65	67	61	73	73	69	45	56	54	7	5	5	12	15
38371	2011-02-22	67	72	left	high	medium	69	64	57	71	66	64	65	58	67	66	57	64	60	63	67	72	58	77	67	67	67	62	73	76	69	45	56	54	7	5	5	12	15
38371	2010-08-30	69	72	left	high	medium	73	64	58	72	66	64	65	58	69	66	65	69	62	68	69	74	61	80	68	68	71	66	74	72	70	53	62	58	7	5	5	12	15
38371	2010-02-22	69	72	left	high	medium	73	64	58	72	66	64	65	58	67	66	65	69	62	68	69	74	61	80	68	68	71	78	75	72	74	53	62	58	10	22	67	22	22
38371	2009-08-30	69	72	left	high	medium	73	64	58	72	66	64	65	68	67	66	65	69	62	68	69	74	61	80	68	72	71	78	75	72	74	53	62	58	10	22	67	22	22
38371	2009-02-22	69	76	left	high	medium	73	69	58	72	66	64	65	68	67	66	63	66	62	68	69	74	61	78	68	72	71	80	75	72	74	53	64	58	10	22	67	22	22
38371	2008-08-30	69	76	left	high	medium	73	69	58	72	66	64	65	68	67	66	63	66	62	68	69	74	61	78	68	72	71	80	75	72	74	53	64	58	10	22	67	22	22
38371	2007-08-30	74	76	left	high	medium	75	74	58	77	66	68	65	72	72	73	68	71	62	73	69	78	61	83	70	76	73	79	75	72	76	56	66	58	10	22	72	22	22
38371	2007-02-22	77	77	left	high	medium	77	77	63	80	66	74	65	76	75	75	74	73	62	75	69	81	61	82	71	77	75	79	75	72	76	61	68	58	10	9	75	7	13
21744	2009-08-30	57	62	right	\N	\N	53	29	51	60	\N	48	\N	42	55	53	60	65	\N	57	\N	53	\N	72	57	40	59	66	62	\N	55	54	57	\N	8	23	55	23	23
21744	2008-08-30	53	64	right	\N	\N	50	29	44	60	\N	54	\N	40	54	55	58	63	\N	55	\N	53	\N	56	56	40	51	45	40	\N	53	45	49	\N	8	23	54	23	23
21744	2007-02-22	53	64	right	\N	\N	50	29	44	60	\N	54	\N	40	54	55	58	63	\N	55	\N	53	\N	56	56	40	51	45	40	\N	53	45	49	\N	8	23	54	23	23
178284	2011-02-22	61	71	right	\N	\N	50	58	51	55	52	63	53	44	49	61	71	73	69	62	63	67	67	62	65	56	41	27	55	47	42	31	32	32	8	13	11	12	11
178284	2010-08-30	63	65	right	\N	\N	50	64	53	55	52	67	54	44	49	65	71	76	75	65	58	67	67	62	60	56	41	29	55	55	42	31	32	32	8	13	11	12	11
178284	2010-02-22	62	65	right	\N	\N	50	61	53	55	52	67	54	44	49	65	71	76	75	65	58	67	67	62	60	56	41	47	51	55	54	31	32	32	3	23	49	23	23
178284	2009-08-30	56	61	right	\N	\N	50	50	52	55	52	57	54	44	49	47	66	71	75	57	58	63	67	55	70	49	41	41	41	55	44	31	32	32	3	23	49	23	23
178284	2007-02-22	56	61	right	\N	\N	50	50	52	55	52	57	54	44	49	47	66	71	75	57	58	63	67	55	70	49	41	41	41	55	44	31	32	32	3	23	49	23	23
38285	2008-08-30	53	65	right	\N	\N	38	28	62	60	\N	30	\N	32	38	35	56	62	\N	48	\N	53	\N	54	64	34	54	45	40	\N	48	49	51	\N	4	22	38	22	22
38285	2007-02-22	53	65	right	\N	\N	38	28	62	60	\N	30	\N	32	38	35	56	62	\N	48	\N	53	\N	54	64	34	54	45	40	\N	48	49	51	\N	4	22	38	22	22
26224	2012-08-31	66	66	right	medium	high	60	54	68	65	61	53	76	72	66	62	63	64	58	66	54	75	67	76	78	65	83	68	45	54	68	56	67	66	7	9	13	5	10
26224	2012-02-22	66	66	right	medium	high	60	54	68	65	61	53	76	72	66	62	63	64	58	66	56	75	67	76	78	65	83	68	45	54	68	56	67	66	7	9	13	5	10
26224	2011-08-30	66	66	right	medium	high	60	54	68	65	61	53	76	72	66	62	63	64	58	66	53	75	67	76	78	65	83	68	45	54	68	56	67	66	7	9	13	5	10
26224	2010-08-30	66	66	right	medium	high	60	54	68	65	61	53	76	72	66	62	63	64	58	66	53	75	67	76	78	65	83	68	45	54	68	56	67	66	7	9	13	5	10
26224	2010-02-22	68	66	right	medium	high	63	54	70	66	61	53	76	72	68	63	71	69	58	64	53	76	67	76	73	66	82	68	67	54	68	62	71	66	7	22	68	22	22
26224	2009-08-30	68	70	right	medium	high	63	55	68	66	61	60	76	55	68	70	85	75	58	61	53	72	67	72	67	69	82	65	67	54	68	62	67	66	7	22	68	22	22
26224	2008-08-30	65	70	right	medium	high	63	55	56	66	61	60	76	55	65	70	85	75	58	61	53	67	67	69	67	61	82	62	65	54	68	62	65	66	7	22	65	22	22
26224	2007-08-30	64	69	right	medium	high	63	44	56	66	61	60	76	44	65	70	85	75	58	57	53	67	67	66	60	59	62	62	54	54	52	58	44	66	7	22	65	22	22
26224	2007-02-22	66	67	right	medium	high	63	44	56	66	61	60	76	52	65	70	85	75	58	57	53	67	67	66	60	59	62	62	54	54	52	58	44	66	7	14	65	13	6
131394	2014-05-09	61	64	right	high	medium	59	52	52	62	56	57	62	67	60	62	75	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2014-02-07	62	64	right	high	high	59	52	52	62	56	57	62	67	60	62	75	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2013-05-31	62	64	right	high	high	59	52	52	62	56	57	62	67	60	62	75	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2013-05-24	62	64	right	high	high	59	52	52	62	56	57	62	67	60	62	75	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2013-03-22	62	64	right	high	high	59	52	52	62	56	57	62	67	60	62	75	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2013-03-15	62	64	right	high	high	59	52	52	62	56	57	62	67	60	62	79	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2013-02-15	62	64	right	high	high	59	52	52	62	56	57	62	67	60	62	79	67	77	60	79	70	79	74	63	62	74	61	58	57	54	57	58	59	13	5	8	11	15
131394	2012-08-31	61	62	right	high	high	57	52	52	60	56	45	53	63	58	60	79	69	77	60	78	70	75	74	62	62	74	61	58	58	50	57	58	59	13	5	8	11	15
131394	2008-08-30	61	62	right	high	high	57	52	52	60	56	45	53	63	58	60	79	69	77	60	78	70	75	74	62	62	74	61	58	58	50	57	58	59	13	5	8	11	15
131394	2007-02-22	61	62	right	high	high	57	52	52	60	56	45	53	63	58	60	79	69	77	60	78	70	75	74	62	62	74	61	58	58	50	57	58	59	13	5	8	11	15
27421	2014-02-21	65	65	right	medium	high	61	62	70	67	60	42	67	79	65	64	28	32	29	58	51	69	50	53	68	67	70	74	64	72	78	57	65	60	6	12	7	5	7
27421	2014-01-10	65	65	right	medium	medium	61	62	70	67	60	42	67	79	65	64	28	32	29	58	51	69	50	53	68	67	70	74	64	72	78	57	65	60	6	12	7	5	7
27421	2013-09-20	65	65	right	medium	medium	61	62	70	67	60	42	67	79	65	64	28	32	29	58	51	69	50	53	68	67	70	74	64	72	78	57	65	60	6	12	7	5	7
27421	2013-05-31	66	66	right	medium	medium	61	62	72	69	60	48	72	79	67	64	28	32	34	62	50	69	58	53	68	67	70	74	64	72	78	59	65	61	6	12	7	5	7
27421	2013-05-17	69	69	right	medium	medium	65	65	75	72	64	58	76	79	70	67	32	32	39	67	55	74	63	58	72	70	70	77	64	72	78	60	67	63	6	12	7	5	7
27421	2013-05-10	69	69	right	medium	medium	65	65	75	72	64	58	76	79	70	67	32	32	39	67	55	74	63	58	72	70	70	77	64	72	78	60	67	63	6	12	7	5	7
27421	2013-02-15	70	70	right	medium	medium	65	65	75	72	67	58	76	79	70	67	32	32	45	67	57	77	72	65	74	72	70	77	69	72	78	64	70	65	6	12	7	5	7
27421	2012-08-31	72	72	right	medium	high	65	65	75	72	67	58	76	79	70	67	32	32	45	74	52	77	73	75	76	72	71	78	69	72	78	64	70	65	6	12	7	5	7
27421	2012-02-22	72	72	right	medium	high	65	65	75	72	67	54	74	79	70	67	32	32	51	74	58	77	73	75	77	72	72	79	69	70	75	64	70	65	6	12	7	5	7
27421	2011-08-30	70	70	right	medium	high	66	66	74	71	67	56	32	69	68	66	43	34	51	69	58	77	73	70	76	72	71	77	68	68	67	67	71	66	6	12	7	5	7
27421	2011-02-22	71	72	right	medium	high	67	66	74	72	67	56	32	69	69	66	52	57	54	63	75	77	67	72	78	72	72	83	61	77	67	69	71	67	6	12	7	5	7
27421	2010-08-30	71	72	left	medium	high	67	66	74	72	67	56	32	69	69	66	52	57	54	63	75	77	67	77	78	72	72	83	61	77	74	69	71	67	6	12	7	5	7
27421	2010-02-22	70	72	left	medium	high	67	57	74	72	67	54	32	69	69	64	47	57	54	60	75	77	67	77	78	72	72	77	75	77	74	67	70	67	8	22	69	22	22
27421	2009-08-30	69	74	left	medium	high	64	54	74	70	67	54	32	69	65	64	47	57	54	60	75	77	67	77	78	67	72	76	71	77	70	67	70	67	8	22	65	22	22
27421	2008-08-30	69	71	left	medium	high	64	54	74	70	67	54	32	69	65	64	47	57	54	60	75	77	67	77	78	67	72	76	71	77	70	67	70	67	8	22	65	22	22
27421	2008-02-22	68	76	left	medium	high	59	39	69	66	67	54	32	49	60	61	53	64	54	61	75	57	67	77	78	54	79	76	69	77	70	67	70	67	8	22	60	22	22
27421	2007-02-22	68	76	left	medium	high	59	39	69	66	67	54	32	49	60	61	53	64	54	61	75	57	67	77	78	54	79	76	69	77	70	67	70	67	8	22	60	22	22
38342	2013-07-05	63	63	left	high	high	62	34	67	62	28	42	45	43	57	52	27	54	35	56	38	71	31	79	80	45	75	62	49	59	53	60	65	62	10	12	9	8	11
38342	2013-05-31	63	63	left	high	high	62	34	67	62	28	42	45	43	57	52	27	54	35	56	38	71	31	79	80	45	75	62	49	59	53	60	65	62	10	12	9	8	11
38342	2013-03-28	64	64	left	high	high	62	34	67	62	28	42	45	43	57	52	37	62	41	58	38	71	31	84	85	45	75	62	49	59	53	60	65	62	10	12	9	8	11
38342	2013-03-04	64	64	left	high	high	62	34	67	62	28	42	45	43	57	52	37	62	41	58	38	71	31	84	85	45	75	62	49	59	53	60	65	62	10	12	9	8	11
38342	2013-02-22	64	64	left	high	high	62	34	67	62	28	42	45	43	57	52	37	62	41	58	38	71	31	84	85	45	75	62	49	59	53	60	65	62	10	12	9	8	11
38342	2013-02-15	64	64	left	high	high	62	34	67	62	28	42	45	43	57	52	37	62	41	58	38	71	31	84	85	45	75	62	49	59	53	60	65	62	10	12	9	8	11
38342	2012-08-31	65	65	left	high	high	62	34	67	62	28	42	45	43	57	52	37	67	42	59	39	72	31	88	86	45	77	62	49	59	53	60	65	62	10	12	9	8	11
38342	2011-08-30	65	65	left	high	high	62	34	67	62	28	42	45	43	57	52	37	67	42	59	41	72	31	88	86	45	77	62	49	59	53	60	65	62	10	12	9	8	11
38342	2011-02-22	65	66	left	high	high	62	34	67	62	28	42	45	43	57	52	47	67	50	59	75	72	60	85	80	45	77	62	49	59	53	60	65	62	10	12	9	8	11
38342	2010-08-30	65	66	left	high	high	62	34	67	62	28	42	45	43	57	52	47	67	50	59	75	72	60	85	80	45	77	62	49	62	53	60	65	62	10	12	9	8	11
38342	2009-08-30	65	66	left	high	high	62	34	67	62	28	42	45	43	57	52	47	67	50	59	75	72	60	85	80	45	77	64	61	62	54	60	65	62	5	23	57	23	23
38342	2009-02-22	64	68	left	high	high	57	34	67	60	28	42	45	43	55	47	55	65	50	57	75	70	60	79	85	45	76	64	61	62	54	60	65	62	5	23	55	23	23
38342	2008-08-30	65	65	left	high	high	59	34	67	63	28	42	45	43	58	47	55	65	50	57	75	70	60	79	85	45	76	64	61	62	54	62	67	62	5	23	58	23	23
38342	2007-08-30	64	67	left	high	high	48	34	61	53	28	39	45	53	58	46	61	63	50	54	75	24	60	75	73	45	76	64	61	62	54	71	71	62	5	23	58	23	23
38342	2007-02-22	64	65	left	high	high	48	34	61	53	28	39	45	54	58	46	61	63	50	54	75	24	60	75	73	45	76	64	61	62	54	71	71	62	5	6	58	13	11
25619	2010-02-22	64	66	right	\N	\N	51	69	78	56	\N	53	\N	42	43	58	61	64	\N	53	\N	72	\N	58	81	54	65	58	66	\N	71	23	54	\N	9	23	43	23	23
25619	2009-08-30	64	66	right	\N	\N	51	69	78	56	\N	53	\N	42	43	58	61	64	\N	53	\N	72	\N	58	81	54	65	58	66	\N	71	23	54	\N	9	23	43	23	23
25619	2008-08-30	64	66	right	\N	\N	51	69	78	56	\N	53	\N	42	43	58	61	64	\N	53	\N	72	\N	58	81	54	65	58	66	\N	68	23	54	\N	11	23	43	23	23
25619	2007-08-30	58	59	right	\N	\N	60	57	64	52	\N	53	\N	42	54	63	53	54	\N	52	\N	56	\N	57	75	51	65	65	69	\N	63	29	42	\N	16	23	54	23	23
25619	2007-02-22	58	59	right	\N	\N	60	57	64	52	\N	53	\N	63	54	63	53	54	\N	52	\N	56	\N	57	75	51	54	65	69	\N	63	29	42	\N	16	9	54	10	15
95597	2015-03-20	65	65	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	64	48	27	72	25	75	25	32	27	25	25	25	25	25	25	67	67	62	64	63
95597	2015-02-13	67	67	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	64	48	27	72	25	75	25	32	27	25	25	25	25	25	25	69	69	64	66	65
95597	2015-01-23	69	69	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	64	48	27	72	25	75	25	32	27	25	25	25	25	25	25	71	71	66	68	67
95597	2015-01-16	72	72	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	64	48	27	72	25	75	25	32	27	25	25	25	25	25	25	74	76	68	71	71
95597	2014-10-24	72	72	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	64	48	27	72	25	75	25	32	27	25	25	25	25	25	25	74	76	68	71	71
95597	2014-10-17	72	72	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	64	48	27	72	25	75	25	32	27	25	25	25	25	25	25	74	76	68	71	71
95597	2014-09-18	72	72	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	51	48	27	72	25	75	25	32	27	25	25	25	25	25	25	75	77	69	72	72
95597	2014-03-21	72	72	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	51	48	27	72	25	75	25	32	27	25	25	25	25	25	25	75	77	69	72	72
95597	2013-09-20	72	72	right	medium	medium	25	25	25	26	25	25	25	25	21	30	51	52	36	51	48	27	72	25	75	25	32	27	25	25	25	25	25	25	75	77	69	72	72
95597	2013-06-21	73	73	right	medium	medium	11	11	12	26	10	14	10	15	21	30	51	52	36	62	48	27	72	47	75	11	32	27	15	34	14	9	10	11	75	77	69	72	72
95597	2013-02-15	72	72	right	medium	medium	11	11	12	26	10	14	10	15	21	30	51	52	36	51	48	27	72	47	75	11	32	27	15	34	14	9	10	11	75	77	69	72	72
95597	2012-08-31	71	71	right	medium	medium	11	11	12	26	10	14	10	15	21	30	30	34	36	51	48	27	72	47	75	11	32	27	15	34	14	9	10	11	72	74	69	72	72
95597	2012-02-22	71	71	right	medium	medium	11	11	12	26	10	14	10	15	21	30	30	34	36	51	48	27	72	47	75	11	32	27	15	34	14	9	10	11	72	74	69	72	72
95597	2011-08-30	71	71	right	medium	medium	11	11	12	26	10	14	10	15	21	30	30	58	36	51	70	27	72	47	75	11	32	27	15	34	14	9	10	11	72	74	69	72	72
95597	2011-02-22	70	74	right	medium	medium	11	11	12	26	10	14	10	15	21	30	20	58	36	51	56	27	72	47	75	19	32	27	15	34	14	9	10	11	70	72	67	70	70
95597	2010-08-30	70	74	right	medium	medium	11	11	12	26	10	9	10	15	21	30	20	58	36	51	56	27	72	47	75	19	32	27	15	58	9	21	10	11	70	72	67	70	70
95597	2008-08-30	70	74	right	medium	medium	11	11	12	26	10	9	10	15	21	30	20	58	36	51	56	27	72	47	75	19	32	27	15	58	9	21	10	11	70	72	67	70	70
95597	2007-08-30	74	74	right	medium	medium	11	11	12	26	10	9	10	15	21	30	20	58	36	51	56	27	72	47	75	19	32	27	15	58	9	21	10	11	73	72	67	75	73
95597	2007-02-22	74	74	right	medium	medium	21	21	31	26	10	21	10	27	21	30	20	58	36	51	56	27	72	67	75	19	32	27	15	58	9	21	24	11	73	72	67	75	73
23997	2015-01-23	61	64	right	medium	medium	55	58	58	63	60	62	60	60	62	63	64	53	52	59	60	62	51	69	74	61	55	54	61	64	36	54	54	52	10	15	13	5	5
23997	2014-09-18	61	62	right	medium	medium	55	58	58	63	60	62	60	60	62	63	64	53	52	59	60	62	51	69	74	61	55	54	61	64	36	54	54	52	10	15	13	5	5
23997	2013-04-19	61	62	right	medium	medium	55	58	58	63	60	62	60	60	62	63	64	53	52	59	60	62	51	69	74	61	55	54	61	64	36	54	54	52	10	15	13	5	5
23997	2013-03-22	62	62	right	medium	medium	56	58	58	64	62	64	60	61	63	66	64	53	52	59	60	64	51	69	78	63	55	54	63	66	36	55	55	52	10	15	13	5	5
23997	2013-03-08	62	62	right	medium	medium	56	58	58	64	62	64	60	61	63	66	64	53	52	59	60	64	51	69	78	63	55	54	63	66	36	55	55	52	10	15	13	5	5
23997	2013-02-15	62	62	right	medium	medium	56	58	58	64	62	64	60	61	63	66	64	53	52	59	60	64	51	69	78	63	55	54	63	66	36	55	55	52	10	15	13	5	5
23997	2012-08-31	62	62	right	medium	medium	56	58	58	64	62	64	60	61	63	66	64	53	52	59	60	64	38	69	78	63	55	54	63	66	36	55	55	52	10	15	13	5	5
23997	2011-08-30	63	67	right	medium	medium	57	58	58	65	63	65	61	62	64	67	64	59	48	59	61	65	39	66	71	64	55	54	64	67	36	56	56	53	10	15	13	5	5
23997	2010-08-30	64	72	right	medium	medium	57	58	58	65	63	65	61	62	64	67	63	64	54	59	58	65	48	65	61	64	55	54	64	67	36	56	56	53	10	15	13	5	5
23997	2010-02-22	64	72	right	medium	medium	57	58	58	65	63	65	61	62	64	67	63	64	54	59	58	65	48	65	61	64	55	62	62	67	51	56	56	53	12	20	64	20	20
23997	2009-08-30	61	69	right	medium	medium	55	58	58	62	63	63	61	57	60	64	63	64	54	59	58	61	48	65	61	57	55	62	62	67	51	56	56	53	12	20	60	20	20
23997	2008-08-30	61	67	right	medium	medium	55	58	58	62	63	63	61	57	60	64	63	64	54	59	58	61	48	65	61	57	55	62	62	67	51	56	56	53	12	20	60	20	20
23997	2007-08-30	69	77	right	medium	medium	57	58	66	74	63	65	61	64	64	70	69	66	54	65	58	72	48	67	67	62	55	62	65	67	51	56	63	53	12	20	64	20	20
23997	2007-02-22	60	77	right	medium	medium	46	42	54	63	63	64	61	51	61	65	65	59	54	65	58	58	48	60	48	51	55	62	65	67	51	36	37	53	12	5	61	10	8
33657	2015-02-20	69	69	right	medium	medium	56	73	75	63	63	51	43	44	48	60	66	66	61	70	65	78	85	87	84	64	78	36	72	61	71	27	34	36	9	8	5	13	6
33657	2014-12-12	70	70	right	medium	medium	56	75	76	63	63	51	43	44	48	61	66	66	61	71	65	79	85	89	84	64	78	36	73	61	71	27	34	36	9	8	5	13	6
33657	2014-09-18	70	70	right	medium	medium	56	75	76	63	63	51	43	44	48	61	66	66	61	71	65	79	85	89	84	64	78	36	73	61	71	27	34	36	9	8	5	13	6
33657	2012-02-22	70	70	right	medium	medium	56	75	76	63	63	51	43	44	48	61	66	66	61	71	65	79	85	89	84	64	78	36	73	61	71	27	34	36	9	8	5	13	6
33657	2011-08-30	73	74	right	medium	medium	56	80	75	63	63	47	43	43	48	67	66	66	61	75	60	83	85	89	84	64	87	47	80	61	71	27	34	49	9	8	5	13	6
33657	2011-02-22	72	75	right	medium	medium	56	83	75	62	68	46	43	43	47	67	62	66	58	75	81	83	77	83	84	64	86	48	81	67	71	27	53	49	9	8	5	13	6
33657	2010-08-30	68	72	right	medium	medium	61	73	77	63	54	47	43	43	57	64	57	65	52	72	81	82	77	86	84	60	86	48	73	67	71	27	45	57	9	8	5	13	6
33657	2010-02-22	68	73	right	medium	medium	60	74	77	62	54	52	43	53	57	63	66	68	52	72	81	75	77	85	77	60	87	74	76	67	68	22	45	57	15	22	57	22	22
33657	2009-08-30	68	73	right	medium	medium	60	74	77	62	54	52	43	53	57	63	66	68	52	72	81	75	77	85	77	60	87	74	76	67	68	22	45	57	15	22	57	22	22
33657	2009-02-22	64	69	right	medium	medium	55	65	72	59	54	52	43	53	45	57	65	67	52	67	81	74	77	82	75	54	87	54	59	67	62	22	45	57	15	22	45	22	22
33657	2008-08-30	64	67	right	medium	medium	55	65	72	59	54	52	43	53	45	57	65	67	52	67	81	74	77	82	75	54	87	54	59	67	62	22	45	57	15	22	45	22	22
33657	2007-08-30	63	65	right	medium	medium	55	62	65	54	54	50	43	56	45	52	62	67	52	60	81	67	77	75	70	53	77	56	57	67	62	32	47	57	15	22	45	22	22
33657	2007-02-22	63	65	right	medium	medium	55	62	65	54	54	50	43	56	45	52	62	67	52	60	81	67	77	75	70	53	77	56	57	67	62	32	47	57	15	22	45	22	22
89548	2015-07-03	61	61	right	high	medium	46	62	64	65	57	58	43	56	47	63	50	56	49	60	46	63	55	63	82	59	61	31	61	67	54	26	42	23	12	14	11	14	13
89548	2015-06-12	61	61	right	high	medium	46	62	64	65	57	58	43	56	47	63	50	56	49	60	46	63	55	63	82	59	61	31	61	67	54	26	42	23	12	14	11	14	13
89548	2015-02-13	61	61	right	high	medium	46	62	64	65	57	58	43	56	47	63	50	56	49	60	46	63	55	63	82	59	61	31	61	67	54	26	42	23	12	14	11	14	13
89548	2011-02-22	61	61	right	high	medium	46	62	64	65	57	58	43	56	47	63	50	56	49	60	46	63	55	63	82	59	61	31	61	67	54	26	42	23	12	14	11	14	13
89548	2010-08-30	63	69	right	high	medium	49	62	69	72	57	58	43	58	52	66	50	63	49	60	77	65	55	64	81	59	59	31	61	71	57	26	47	23	12	14	11	14	13
89548	2009-08-30	63	69	right	high	medium	49	62	69	72	57	56	43	58	52	66	50	63	49	60	77	65	55	64	81	59	59	67	64	71	58	26	47	23	15	21	52	21	21
89548	2007-02-22	63	69	right	high	medium	49	62	69	72	57	56	43	58	52	66	50	63	49	60	77	65	55	64	81	59	59	67	64	71	58	26	47	23	15	21	52	21	21
104378	2013-06-07	70	70	right	medium	medium	17	13	15	31	16	11	12	8	32	15	63	61	58	72	54	39	71	55	70	17	42	14	13	6	26	15	17	19	74	63	53	71	73
104378	2013-04-12	70	71	right	medium	medium	17	13	15	31	16	11	12	8	32	15	63	61	58	72	54	39	71	55	70	17	42	14	13	6	26	15	17	19	74	63	53	71	73
104378	2013-03-22	70	71	right	medium	medium	17	13	15	31	16	11	12	8	32	15	63	61	58	72	54	39	71	55	81	17	66	27	13	35	26	15	17	19	74	63	53	71	73
104378	2013-02-15	70	71	right	medium	medium	17	13	15	31	16	11	12	8	32	15	63	61	58	72	54	39	71	55	81	17	66	27	13	35	26	15	17	19	74	63	53	71	73
104378	2012-08-31	71	71	right	medium	medium	17	13	15	31	16	11	12	8	32	15	63	61	58	72	54	39	71	55	86	17	71	27	13	35	26	15	17	19	74	65	62	72	73
104378	2012-02-22	72	72	right	medium	medium	17	13	15	31	16	11	12	8	32	15	65	62	66	74	54	39	75	56	86	17	67	27	13	35	26	15	17	19	74	70	62	71	73
104378	2011-08-30	72	74	right	medium	medium	17	13	15	31	16	11	12	8	32	23	65	62	66	74	54	39	73	57	86	17	73	27	13	35	26	15	17	19	74	73	68	72	71
104378	2011-02-22	72	74	right	medium	medium	17	13	15	41	16	11	12	22	34	37	74	67	66	72	88	55	73	57	86	17	67	27	13	35	50	15	17	19	74	70	67	70	73
104378	2010-08-30	71	76	right	medium	medium	17	9	15	53	16	26	27	22	67	37	74	67	66	72	88	75	71	63	86	17	63	24	13	59	56	15	17	19	74	70	69	70	72
104378	2010-02-22	71	76	right	medium	medium	21	26	21	23	16	26	27	22	69	39	74	67	66	72	88	45	71	65	86	21	63	59	63	59	57	21	21	19	72	67	69	70	74
104378	2009-08-30	71	76	right	medium	medium	21	26	21	23	16	26	27	22	69	58	74	67	66	72	88	75	71	65	86	35	63	59	63	59	57	21	21	19	72	70	69	70	74
104378	2008-08-30	66	69	right	medium	medium	21	21	37	23	16	21	27	12	60	28	74	67	66	68	88	65	71	52	82	21	63	59	23	59	57	21	21	19	73	51	60	62	72
104378	2007-08-30	63	67	right	medium	medium	21	21	21	21	16	21	27	12	65	21	53	46	66	48	88	21	71	62	58	21	63	69	63	59	57	21	21	19	56	69	65	69	56
104378	2007-02-22	63	67	right	medium	medium	21	21	21	21	16	21	27	12	65	21	53	46	66	48	88	21	71	62	58	21	63	69	63	59	57	21	21	19	56	69	65	69	56
30934	2016-04-07	68	68	right	medium	medium	14	14	11	32	14	25	14	14	35	36	53	43	66	73	61	36	83	23	46	15	34	25	13	48	27	11	13	12	74	60	56	63	75
30934	2016-02-04	69	69	right	medium	medium	14	14	11	32	14	25	14	14	35	36	53	43	66	76	61	36	83	23	46	15	34	25	13	48	27	11	13	12	75	60	56	63	77
30934	2016-01-21	70	70	right	medium	medium	14	14	11	32	14	25	14	14	35	36	53	43	66	76	61	36	83	23	46	15	34	25	13	48	27	11	13	12	75	61	56	63	80
30934	2015-09-21	70	70	right	medium	medium	14	14	11	32	14	25	14	14	35	36	53	43	66	76	61	36	83	23	46	15	34	25	13	48	27	11	13	12	75	61	56	63	80
30934	2015-01-09	69	69	right	medium	medium	25	25	25	31	25	25	25	25	34	35	53	43	68	75	61	35	81	23	46	25	33	24	25	25	26	25	25	25	74	60	55	62	79
30934	2014-09-18	70	70	right	medium	medium	25	25	25	31	25	25	25	25	34	35	53	43	68	77	61	35	81	23	46	25	33	24	25	25	26	25	25	25	74	64	55	62	80
30934	2014-05-16	71	71	right	medium	medium	25	25	25	31	25	45	25	25	34	57	53	43	68	79	61	35	81	23	46	25	33	24	25	25	26	25	25	25	72	67	55	63	81
30934	2014-04-25	71	71	right	medium	medium	25	25	25	31	25	45	25	25	34	57	53	43	68	79	61	35	81	23	46	25	33	24	25	25	26	25	25	25	72	67	55	63	81
30934	2014-03-14	72	72	right	medium	medium	25	25	25	31	25	45	25	25	34	57	53	43	68	79	61	35	81	23	46	25	33	24	25	25	26	25	25	25	72	73	55	63	81
30934	2013-09-20	73	73	right	medium	medium	25	25	25	31	25	45	25	25	34	57	53	43	68	79	61	35	81	23	46	25	33	24	25	25	26	25	25	25	72	74	55	63	83
30934	2013-05-17	72	72	right	medium	medium	13	13	9	31	13	45	13	13	34	57	62	61	70	80	67	35	83	48	53	14	33	24	26	17	26	10	12	11	72	74	53	62	83
30934	2013-04-12	72	72	right	medium	medium	13	13	9	31	13	45	13	13	34	57	62	61	70	80	67	35	83	48	53	14	33	24	26	17	26	10	12	11	72	74	53	62	83
30934	2013-03-28	72	72	right	medium	medium	13	13	9	31	13	45	13	13	34	57	62	61	70	80	67	35	83	48	53	14	59	23	17	33	26	10	12	11	72	74	53	62	83
30934	2013-02-15	72	72	right	medium	medium	13	13	9	31	13	45	13	13	34	57	62	61	70	80	67	35	83	48	53	14	59	23	17	33	26	10	12	11	72	74	53	62	83
30934	2012-08-31	72	72	right	medium	medium	13	13	9	31	13	61	13	13	34	63	62	61	72	80	67	35	83	48	53	14	69	23	17	33	26	10	12	11	76	70	53	62	83
30934	2012-02-22	72	73	right	medium	medium	20	13	9	31	13	61	20	13	34	63	64	61	78	80	67	35	83	48	53	14	29	27	17	44	26	10	12	11	76	68	53	61	83
30934	2011-08-30	72	73	right	medium	medium	20	13	9	31	13	61	20	13	34	63	64	61	78	80	67	35	83	48	53	14	29	27	17	44	26	10	12	11	76	68	53	61	83
30934	2011-02-22	72	73	right	medium	medium	24	13	22	31	13	63	33	13	41	65	68	66	78	80	51	51	83	48	53	14	29	27	17	34	42	8	12	11	76	68	53	61	83
30934	2010-08-30	72	73	right	medium	medium	24	13	22	61	33	63	31	13	51	65	68	66	78	80	51	51	83	48	53	31	29	27	17	61	42	24	30	27	76	68	53	61	83
30934	2010-02-22	73	78	right	medium	medium	24	26	22	52	33	63	31	13	58	62	68	66	78	80	51	51	83	47	53	21	29	46	40	61	80	24	23	27	76	68	58	63	83
30934	2009-08-30	73	78	right	medium	medium	24	26	22	52	33	63	31	13	58	68	68	66	78	80	51	51	83	47	53	33	29	46	40	61	80	24	23	27	76	68	58	63	83
30934	2008-08-30	68	69	right	medium	medium	24	31	32	62	33	30	31	24	41	40	73	64	78	80	51	60	83	53	56	23	62	61	30	61	85	47	30	27	73	63	41	58	81
30934	2007-08-30	67	68	right	medium	medium	24	31	32	62	33	70	31	24	41	73	73	64	78	80	51	60	83	53	56	23	62	61	30	61	85	47	30	27	72	63	41	58	78
30934	2007-02-22	64	68	right	medium	medium	24	31	32	62	33	70	31	85	41	73	71	64	78	72	51	60	83	53	56	23	62	61	30	61	85	47	30	27	65	63	41	59	72
131411	2008-08-30	58	61	right	\N	\N	56	45	54	57	\N	56	\N	44	54	58	68	67	\N	64	\N	65	\N	70	66	44	68	51	45	\N	44	38	48	\N	4	22	54	22	22
131411	2007-02-22	58	61	right	\N	\N	56	45	54	57	\N	56	\N	44	54	58	68	67	\N	64	\N	65	\N	70	66	44	68	51	45	\N	44	38	48	\N	4	22	54	22	22
154433	2016-03-03	66	66	left	high	medium	63	58	52	58	55	68	59	48	55	63	93	93	70	52	79	65	85	83	58	59	49	38	56	60	55	48	51	50	7	6	9	10	8
154433	2016-02-11	66	67	left	high	medium	64	58	52	58	55	68	59	48	55	63	93	93	70	53	79	65	85	83	58	59	49	38	56	60	55	48	51	50	7	6	9	10	8
154433	2016-01-07	66	67	left	high	medium	64	58	52	58	55	68	59	48	55	63	93	93	70	53	79	65	85	83	58	59	49	38	56	60	55	48	51	50	7	6	9	10	8
154433	2015-09-21	66	67	left	high	high	64	58	52	58	55	68	59	48	55	63	93	93	70	53	79	65	85	83	58	59	49	38	56	60	55	48	51	50	7	6	9	10	8
154433	2015-03-20	64	65	left	high	high	63	57	51	57	54	67	58	47	54	62	89	93	70	52	79	64	85	83	58	58	48	37	55	59	54	47	50	49	6	5	8	9	7
154433	2015-02-20	66	67	left	high	high	65	57	51	57	54	67	58	47	54	65	89	93	70	67	79	65	85	83	58	58	48	37	55	59	54	47	52	49	6	5	8	9	7
154433	2014-09-18	66	67	left	high	high	65	57	51	57	54	67	58	47	54	65	89	93	70	67	79	65	85	83	58	58	48	37	55	59	54	47	52	49	6	5	8	9	7
154433	2013-12-20	65	67	left	high	high	65	57	51	57	54	67	58	47	54	65	82	82	77	67	79	65	85	67	58	58	48	37	55	59	54	47	52	49	6	5	8	9	7
154433	2013-09-20	65	68	left	high	high	65	57	51	57	54	67	58	47	54	65	82	82	77	67	79	65	85	67	58	58	48	37	55	59	54	47	52	49	6	5	8	9	7
154433	2013-02-22	65	68	left	high	high	65	57	51	57	54	67	58	47	54	65	82	82	77	67	79	65	85	67	57	58	48	37	55	59	54	47	52	49	6	5	8	9	7
154433	2013-02-15	65	68	left	high	high	65	57	51	57	54	67	58	47	54	65	82	82	77	67	79	65	85	67	57	58	48	37	55	59	54	47	52	49	6	5	8	9	7
154433	2012-08-31	65	69	left	high	high	66	59	51	58	58	68	58	47	54	66	82	82	78	70	78	66	85	68	57	58	48	37	56	59	54	17	26	27	6	5	8	9	7
154433	2012-02-22	62	65	left	low	medium	62	59	51	56	58	65	58	47	52	62	81	82	78	66	78	64	85	68	57	58	48	37	54	51	54	17	26	27	6	5	8	9	7
154433	2011-08-30	63	67	left	medium	medium	62	59	51	56	58	64	58	47	52	65	75	78	71	59	74	62	63	64	56	58	48	37	54	51	54	17	26	27	6	5	8	9	7
154433	2010-08-30	61	68	left	medium	medium	59	58	51	55	53	63	58	47	44	60	67	70	67	59	58	61	62	64	57	56	48	37	54	51	54	14	26	27	6	5	8	9	7
154433	2010-02-22	62	75	left	medium	medium	59	60	51	55	53	65	58	47	44	60	70	75	67	62	58	62	62	65	57	54	48	50	48	51	47	22	26	27	2	22	44	22	22
154433	2009-08-30	64	75	left	medium	medium	63	60	61	55	53	68	58	47	44	62	75	77	67	62	58	62	62	65	57	54	48	50	68	51	47	22	26	27	2	22	44	22	22
154433	2009-02-22	68	75	left	medium	medium	68	72	67	54	53	73	58	52	53	69	77	79	67	67	58	67	62	70	62	59	53	55	73	51	52	36	38	27	2	22	53	22	22
154433	2008-08-30	70	75	left	medium	medium	68	72	67	67	53	73	58	52	69	69	75	78	67	67	58	67	62	70	62	59	53	55	73	51	52	59	61	27	2	22	69	22	22
154433	2007-02-22	70	75	left	medium	medium	68	72	67	67	53	73	58	52	69	69	75	78	67	67	58	67	62	70	62	59	53	55	73	51	52	59	61	27	2	22	69	22	22
67939	2009-08-30	60	62	right	\N	\N	45	26	60	52	\N	25	\N	39	47	57	65	65	\N	57	\N	56	\N	69	67	33	64	58	57	\N	50	61	58	\N	6	20	47	20	20
67939	2008-08-30	58	62	right	\N	\N	39	26	60	42	\N	25	\N	39	47	48	65	65	\N	57	\N	56	\N	67	67	33	64	56	55	\N	48	57	54	\N	6	20	47	20	20
67939	2007-02-22	58	62	right	\N	\N	39	26	60	42	\N	25	\N	39	47	48	65	65	\N	57	\N	56	\N	67	67	33	64	56	55	\N	48	57	54	\N	6	20	47	20	20
36835	2015-09-21	66	66	right	medium	medium	13	13	10	33	13	12	9	13	33	26	46	41	58	72	53	36	67	16	56	14	27	12	11	29	26	14	13	20	63	63	69	65	67
36835	2014-02-28	66	66	right	medium	medium	13	13	10	33	13	12	9	13	33	26	46	41	58	72	53	36	67	16	56	14	27	12	11	29	26	14	13	20	63	63	69	65	67
36835	2014-02-07	66	66	right	medium	medium	13	13	10	33	13	12	9	13	33	26	46	41	58	72	53	36	67	16	56	14	27	12	11	29	26	14	13	20	63	63	69	65	67
36835	2014-01-31	66	66	right	medium	medium	13	13	10	33	13	12	9	13	33	26	46	41	58	72	53	36	67	16	56	14	27	12	11	29	26	14	13	20	63	63	69	65	67
36835	2013-09-20	66	66	right	medium	medium	13	13	10	33	13	12	9	13	33	26	46	41	58	72	53	36	67	16	56	14	27	12	11	29	26	14	13	20	63	63	69	65	67
36835	2013-05-31	66	68	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	27	11	10	8	26	13	12	19	63	63	69	65	67
36835	2013-05-17	66	66	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	27	11	10	8	26	13	12	19	66	63	69	63	67
36835	2013-04-12	66	66	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	27	11	10	8	26	13	12	19	66	63	69	63	67
36835	2013-03-28	66	66	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	64	22	10	31	26	13	12	19	66	63	69	63	67
36835	2013-03-04	66	66	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	64	22	10	31	26	13	12	19	66	63	69	63	67
36835	2013-02-15	66	66	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	64	22	10	31	26	13	12	19	66	63	69	63	67
36835	2012-08-31	67	68	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	59	36	71	43	58	13	64	22	10	31	26	13	12	19	66	63	73	63	71
36835	2011-08-30	66	67	right	medium	medium	12	12	9	33	12	11	8	12	33	26	61	58	62	70	66	36	71	43	58	13	64	22	10	31	26	13	12	19	66	63	72	63	71
36835	2011-02-22	65	67	right	medium	medium	12	12	27	45	12	23	28	12	41	37	63	58	62	67	56	45	71	43	58	13	64	22	10	31	43	13	12	19	63	63	73	63	66
36835	2010-08-30	65	67	right	medium	medium	12	12	27	56	31	23	28	33	72	37	63	58	62	67	56	65	71	43	58	13	64	22	10	63	43	13	12	19	63	63	73	63	66
36835	2010-02-22	64	67	right	medium	medium	20	22	27	38	31	23	28	33	71	38	63	58	62	67	56	49	71	43	58	21	64	52	59	63	62	20	20	19	63	63	71	61	66
36835	2009-08-30	64	67	right	medium	medium	20	22	27	56	31	46	28	33	71	58	63	58	62	67	56	65	71	43	58	32	64	52	59	63	62	20	20	19	63	63	71	61	66
36835	2008-08-30	64	67	right	medium	medium	20	20	20	56	31	36	28	13	71	33	63	58	62	67	56	65	71	43	58	20	64	52	59	63	62	20	20	19	63	63	71	61	66
36835	2007-08-30	60	62	right	medium	medium	22	20	20	20	31	36	28	13	55	33	56	48	62	67	56	20	71	43	53	20	64	52	59	63	62	20	20	19	55	63	55	60	64
36835	2007-02-22	60	62	right	medium	medium	22	20	20	20	31	36	28	13	55	33	56	48	62	67	56	20	71	43	53	20	64	52	59	63	62	20	20	19	55	63	55	60	64
95615	2016-04-28	69	69	right	high	medium	67	64	59	66	61	66	60	64	62	64	73	74	78	68	74	62	77	78	64	63	64	67	66	66	65	73	69	67	13	15	9	16	14
95615	2016-03-24	69	70	right	high	medium	67	64	59	66	61	66	60	64	62	64	73	74	78	68	74	62	77	78	64	63	64	67	66	66	65	73	69	67	13	15	9	16	14
95615	2015-09-21	69	70	right	high	medium	67	64	59	66	61	66	60	64	62	64	73	74	80	68	74	62	77	78	64	63	64	67	66	66	65	73	69	67	13	15	9	16	14
95615	2015-05-15	66	67	right	high	medium	66	63	58	65	60	65	59	63	61	63	73	75	80	67	74	61	74	78	64	62	63	66	65	65	64	69	66	63	12	14	8	15	13
95615	2015-04-24	66	68	right	high	medium	66	63	58	65	60	65	59	63	61	63	73	75	80	67	74	61	74	78	64	62	63	66	65	65	64	69	66	63	12	14	8	15	13
95615	2015-04-10	66	68	right	high	medium	66	63	58	65	61	63	61	63	61	63	73	75	81	67	74	58	74	78	62	61	63	66	65	65	64	68	66	63	12	14	8	15	13
95615	2015-01-23	67	69	right	high	medium	66	63	58	65	61	65	61	63	61	64	77	79	81	67	74	58	74	78	60	61	66	66	67	66	64	66	65	64	12	14	8	15	13
95615	2014-12-05	67	69	right	high	medium	66	63	58	65	61	65	61	63	61	64	77	79	81	67	74	58	74	78	60	61	66	66	67	66	64	66	65	64	12	14	8	15	13
95615	2014-09-18	67	69	right	high	medium	66	63	58	65	61	65	61	63	61	64	77	79	81	67	74	58	74	78	60	61	66	66	67	66	64	66	65	64	12	14	8	15	13
95615	2014-03-21	67	69	right	high	medium	66	63	58	65	61	65	61	63	61	64	77	79	81	67	74	58	72	78	60	61	66	66	67	66	64	66	65	64	12	14	8	15	13
95615	2013-11-08	66	68	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	72	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2013-09-20	66	68	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	72	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2013-06-07	66	68	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	71	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2013-05-31	66	69	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	71	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2013-05-10	66	69	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	71	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2013-03-28	66	69	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	71	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2013-02-15	66	69	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	74	58	71	78	62	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2012-08-31	66	69	right	high	medium	65	63	58	62	61	64	61	63	56	63	77	79	81	67	73	58	69	77	60	61	67	66	67	66	64	64	63	63	12	14	8	15	13
95615	2012-02-22	64	70	right	high	medium	65	63	56	60	61	64	61	63	56	63	74	76	81	67	73	58	69	74	58	61	67	60	66	66	64	64	62	61	12	14	8	15	13
95615	2011-08-30	65	70	right	high	high	65	63	56	60	61	64	61	63	56	63	74	76	81	67	73	58	69	72	57	61	67	60	66	65	64	62	60	58	12	14	8	15	13
95615	2011-02-22	63	69	right	high	high	65	63	56	60	61	64	61	63	56	63	72	74	75	67	45	58	65	69	47	61	67	60	66	62	64	62	60	58	12	14	8	15	13
95615	2010-08-30	65	69	right	high	high	65	63	56	60	61	66	63	63	56	64	69	74	75	67	47	58	65	67	52	61	67	60	66	62	64	62	60	58	12	14	8	15	13
95615	2010-02-22	63	70	right	high	high	60	64	46	54	61	67	63	63	56	62	74	72	75	67	47	56	65	67	42	62	27	54	55	62	47	32	39	58	17	20	56	20	20
95615	2009-08-30	63	70	right	high	high	60	64	46	54	61	67	63	63	56	62	74	72	75	67	47	56	65	67	42	62	27	54	55	62	47	20	26	58	17	20	56	20	20
95615	2008-08-30	63	70	right	high	high	60	64	54	52	61	67	63	63	56	65	67	72	75	66	47	60	65	69	62	62	50	56	55	62	54	32	36	58	1	20	56	20	20
95615	2007-08-30	60	69	right	high	high	55	58	51	52	61	58	63	53	34	57	65	70	75	69	47	56	65	69	47	51	32	49	45	62	54	20	20	58	1	20	34	20	20
95615	2007-02-22	60	69	right	high	high	55	58	51	52	61	58	63	53	34	57	65	70	75	69	47	56	65	69	47	51	32	49	45	62	54	20	20	58	1	20	34	20	20
6803	2009-08-30	63	65	right	\N	\N	50	46	65	63	\N	48	\N	32	58	52	53	63	\N	65	\N	54	\N	70	65	46	77	58	71	\N	43	57	60	\N	10	25	58	25	25
6803	2008-08-30	58	63	right	\N	\N	50	46	65	63	\N	48	\N	32	58	49	53	63	\N	57	\N	54	\N	70	58	46	59	52	63	\N	43	51	51	\N	10	25	58	25	25
6803	2007-02-22	58	63	right	\N	\N	50	46	65	63	\N	48	\N	32	58	49	53	63	\N	57	\N	54	\N	70	58	46	59	52	63	\N	43	51	51	\N	10	25	58	25	25
38229	2016-04-14	78	78	left	medium	low	79	71	79	81	82	85	83	74	75	85	68	69	79	79	71	77	56	68	61	76	33	49	78	82	71	45	57	48	9	7	12	7	6
38229	2016-03-17	78	78	left	medium	low	79	71	79	81	82	85	83	74	75	85	68	69	79	79	71	77	56	68	61	76	33	49	78	82	71	45	57	48	9	7	12	7	6
38229	2016-01-07	78	78	left	medium	low	78	73	79	81	82	85	83	74	75	85	68	69	79	79	71	77	56	68	61	76	33	49	78	82	71	45	57	48	9	7	12	7	6
38229	2015-12-10	78	78	left	medium	low	78	73	79	82	81	85	80	74	72	85	68	69	79	79	71	76	56	68	61	73	33	49	79	82	71	45	57	48	9	7	12	7	6
38229	2015-11-06	78	78	left	medium	low	78	73	79	82	81	85	80	74	72	85	68	69	79	79	71	76	56	68	61	73	33	49	79	82	71	45	57	48	9	7	12	7	6
38229	2015-10-16	78	78	left	medium	low	78	73	79	82	81	85	80	74	72	85	68	69	79	79	71	76	56	68	61	73	33	49	79	82	71	45	57	48	9	7	12	7	6
38229	2015-10-09	78	78	left	medium	low	78	73	79	82	81	85	80	74	72	85	68	69	80	79	71	76	56	68	61	73	33	49	79	82	71	45	57	48	9	7	12	7	6
38229	2015-09-25	79	79	left	medium	low	77	71	79	82	81	85	80	74	72	85	68	69	80	79	71	76	56	75	61	71	33	49	79	82	71	45	57	48	9	7	12	7	6
38229	2015-09-21	79	79	left	medium	low	77	71	79	82	81	85	80	74	72	85	68	69	80	79	75	76	56	75	57	71	33	49	79	82	71	45	57	48	9	7	12	7	6
38229	2015-05-22	79	79	left	medium	low	72	70	78	80	80	84	79	73	67	84	68	69	80	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2015-02-27	79	79	left	medium	low	72	70	78	80	80	84	79	73	67	84	68	69	80	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-10-31	79	79	left	medium	low	72	70	78	80	80	84	79	73	67	84	68	71	80	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-10-02	79	79	left	medium	low	72	75	78	80	80	84	79	73	67	84	68	71	80	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-09-18	78	78	left	medium	low	72	75	78	80	80	84	79	73	67	84	68	71	80	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-07-18	78	78	left	medium	low	72	75	78	80	80	84	79	73	67	84	68	71	79	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-05-16	78	78	left	medium	low	72	75	78	80	80	84	79	73	67	84	68	71	79	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-04-04	78	78	left	medium	low	76	75	78	80	80	84	79	73	67	84	68	71	79	77	75	75	56	73	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-03-14	79	79	left	medium	low	76	75	78	81	80	85	79	73	67	85	68	71	79	77	75	75	56	82	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-01-17	79	79	left	medium	medium	75	73	78	81	80	84	79	73	67	84	68	71	79	75	75	75	56	82	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2014-01-10	79	79	left	medium	medium	75	73	78	81	80	84	79	73	67	84	68	71	79	75	75	75	56	82	57	70	32	48	77	80	70	44	56	47	8	6	11	6	5
38229	2013-12-20	79	79	left	medium	medium	75	74	78	82	80	84	79	73	67	84	68	71	79	76	75	76	56	83	57	70	32	48	79	81	70	44	56	47	8	6	11	6	5
38229	2013-09-20	80	81	left	medium	medium	75	74	78	82	80	85	79	73	67	85	68	71	79	76	75	76	56	83	57	70	32	57	79	81	70	44	56	47	8	6	11	6	5
38229	2013-05-17	82	84	left	medium	medium	75	81	78	83	80	86	75	73	67	87	68	71	79	76	75	76	56	83	57	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2013-05-10	82	84	left	medium	low	75	81	78	83	80	86	75	73	67	87	68	71	79	76	75	76	56	79	56	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2013-04-26	82	84	left	medium	low	75	81	78	83	80	86	75	73	67	87	68	71	79	76	75	76	56	79	67	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2013-04-19	82	84	left	medium	low	75	81	78	83	80	87	75	73	67	87	68	71	79	76	75	76	56	79	67	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2013-02-15	82	84	left	medium	low	75	81	78	83	80	87	75	73	67	87	68	71	79	76	75	76	56	79	67	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2012-08-31	82	84	left	medium	low	75	79	78	83	80	87	75	73	67	87	63	72	79	76	75	76	56	83	67	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2012-02-22	81	84	left	medium	medium	75	79	78	83	80	87	75	73	67	87	63	72	79	76	75	76	56	83	78	70	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2011-08-30	82	84	left	medium	medium	76	82	78	84	80	87	75	73	67	87	65	75	82	80	75	76	56	83	78	72	32	32	83	83	74	34	35	36	8	6	11	6	5
38229	2011-02-22	81	87	left	medium	medium	77	83	75	85	80	88	75	75	67	89	74	77	86	85	82	76	76	78	74	72	32	32	84	82	74	34	35	36	8	6	11	6	5
38229	2010-08-30	81	87	left	medium	medium	77	85	74	83	80	86	75	74	71	88	73	77	85	85	82	76	76	78	70	72	32	32	84	83	75	34	35	36	8	6	11	6	5
38229	2010-02-22	80	87	left	medium	medium	77	84	76	74	80	87	75	69	72	86	75	77	85	82	82	75	76	78	68	69	32	70	84	83	80	34	41	36	28	22	72	22	37
38229	2009-08-30	78	84	left	medium	medium	77	74	74	74	80	87	75	69	72	85	75	77	85	77	82	65	76	75	67	67	50	70	80	83	76	34	41	36	28	22	72	22	37
38229	2008-08-30	71	76	left	medium	medium	66	69	53	67	80	77	75	57	62	72	75	77	85	67	82	65	76	65	62	64	37	62	56	83	69	24	29	36	18	20	62	20	20
38229	2007-08-30	63	69	left	medium	medium	62	60	47	60	80	73	75	54	55	71	62	67	85	61	82	55	76	60	57	62	37	60	52	83	54	24	29	36	18	20	55	20	20
38229	2007-02-22	53	64	left	medium	medium	46	64	47	57	80	60	75	64	55	39	67	55	85	62	82	45	76	53	60	49	67	60	52	83	64	14	19	36	18	12	55	12	2
36832	2015-04-10	66	66	right	medium	high	64	36	71	63	31	41	41	52	61	56	46	48	39	57	43	72	46	63	80	43	71	76	56	58	71	63	66	64	14	14	5	7	5
36832	2015-03-13	67	67	right	medium	high	66	36	72	63	31	41	41	48	61	56	46	48	41	57	43	72	46	63	81	43	71	76	56	58	71	64	67	66	14	14	5	7	5
36832	2015-01-09	67	67	right	medium	high	66	36	72	63	31	41	41	48	61	56	46	48	41	57	43	64	46	63	81	43	71	76	56	58	71	64	67	66	14	14	5	7	5
36832	2014-09-18	67	67	right	medium	high	66	36	72	63	31	41	41	48	61	56	46	48	41	57	43	64	46	63	81	43	71	76	56	58	71	64	67	66	14	14	5	7	5
36832	2014-04-04	68	68	right	medium	high	66	36	72	63	31	41	41	48	61	56	46	48	41	61	43	64	49	63	81	43	71	76	56	58	71	64	67	66	14	14	5	7	5
36832	2014-03-14	69	69	right	medium	high	66	36	72	63	33	43	43	51	61	58	51	53	46	64	48	66	54	68	83	46	77	76	56	58	73	67	67	68	14	14	5	7	5
36832	2013-10-11	68	68	right	medium	high	66	36	73	64	33	43	43	51	61	58	51	53	46	66	48	66	54	68	83	46	78	76	56	58	73	68	67	69	14	14	5	7	5
36832	2013-09-20	69	69	right	medium	high	67	36	73	64	36	43	43	51	60	61	53	55	46	66	54	68	55	73	83	46	80	76	56	58	73	68	67	70	14	14	5	7	5
36832	2013-05-31	69	69	right	medium	high	67	36	73	64	36	43	43	51	60	61	53	56	46	66	53	68	55	73	83	46	80	76	56	58	73	68	67	70	14	14	5	7	5
36832	2013-02-15	70	70	right	medium	high	67	36	73	64	36	43	43	51	60	61	53	56	46	66	53	68	58	73	83	46	80	76	56	58	73	70	71	72	14	14	5	7	5
36832	2012-08-31	71	71	right	medium	high	66	36	73	64	36	43	43	51	58	61	58	66	46	68	56	68	68	74	82	46	83	76	46	56	76	71	74	72	14	14	5	7	5
36832	2012-02-22	71	71	right	medium	high	66	36	73	64	36	38	43	51	58	53	58	66	46	68	56	68	68	74	82	46	83	76	46	56	76	71	74	72	14	14	5	7	5
36832	2011-08-30	70	70	right	medium	high	63	36	73	64	39	39	43	51	58	53	54	66	46	68	54	68	68	74	83	46	86	76	36	56	78	71	74	72	14	14	5	7	5
36832	2011-02-22	72	74	right	medium	high	61	36	72	63	39	38	43	51	58	53	53	61	51	68	81	68	64	73	83	46	86	76	36	72	78	70	74	72	14	14	5	7	5
36832	2010-08-30	73	74	right	medium	high	63	36	72	64	39	38	43	51	58	53	56	61	51	68	81	68	64	73	83	46	86	76	36	72	78	71	76	73	14	14	5	7	5
36832	2010-02-22	71	71	right	medium	high	68	37	72	63	39	43	43	51	58	58	59	61	51	69	81	62	64	74	72	43	78	72	74	72	76	71	76	73	7	22	58	22	22
36832	2009-08-30	69	71	right	medium	high	72	37	70	59	39	44	43	51	51	59	59	61	51	69	81	62	64	74	72	43	78	59	64	72	57	69	70	73	7	22	51	22	22
36832	2009-02-22	70	72	right	medium	high	73	38	71	60	39	45	43	52	52	60	60	62	51	70	81	63	64	75	73	44	79	60	65	72	58	70	71	73	7	22	52	22	22
36832	2008-08-30	70	70	right	medium	high	73	38	71	60	39	45	43	52	52	60	60	62	51	70	81	63	64	75	73	44	79	60	65	72	58	70	71	73	7	22	52	22	22
36832	2007-08-30	66	68	right	medium	high	38	25	68	53	39	38	43	52	48	53	60	62	51	68	81	63	64	74	73	34	72	58	63	72	66	71	70	73	7	22	48	22	22
36832	2007-02-22	67	68	right	medium	high	62	43	59	53	39	51	43	66	48	53	60	62	51	68	81	53	64	76	67	52	67	58	63	72	66	70	70	73	7	14	48	7	13
39153	2014-01-17	61	61	right	medium	medium	25	25	25	25	25	25	25	25	25	23	25	25	24	62	22	26	39	25	77	25	26	25	25	25	32	25	25	25	60	62	56	66	57
39153	2013-09-20	61	61	right	medium	medium	25	25	25	25	25	25	25	25	25	23	25	25	24	62	22	26	39	25	77	25	26	25	25	25	32	25	25	25	60	62	56	66	57
39153	2013-07-12	64	64	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	32	62	32	26	59	36	83	10	51	21	11	36	32	11	10	19	64	63	58	67	64
39153	2013-06-07	64	64	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	32	62	32	26	59	36	83	10	51	21	11	36	32	11	10	19	64	63	58	67	64
39153	2013-03-08	64	64	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	32	62	32	26	59	36	83	10	51	21	11	36	32	11	10	19	64	63	58	67	64
39153	2013-02-15	63	63	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	32	62	32	26	59	36	83	10	51	21	11	36	32	11	10	19	64	63	58	66	62
39153	2012-08-31	63	63	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	32	62	32	26	59	36	89	10	51	21	11	36	32	11	10	19	64	63	58	66	62
39153	2012-02-22	63	63	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	32	58	33	26	47	36	83	10	51	21	11	36	32	11	10	19	65	62	59	65	62
39153	2011-08-30	62	62	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	52	58	33	26	47	36	76	10	51	21	11	36	32	11	10	19	61	62	57	65	62
39153	2010-02-22	62	62	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	52	58	33	26	47	36	76	10	51	21	11	36	32	11	10	19	61	62	57	65	62
39153	2008-08-30	62	62	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	42	52	58	33	26	47	36	76	10	51	21	11	36	32	11	10	19	61	62	57	65	62
39153	2007-08-30	65	66	right	medium	medium	19	11	13	13	13	16	12	10	13	23	33	32	52	58	33	26	47	36	76	10	51	21	11	36	32	11	10	19	63	63	57	65	63
39153	2007-02-22	56	59	right	medium	medium	19	11	13	13	13	16	12	51	55	13	33	32	52	48	33	26	47	36	26	10	51	21	11	36	32	11	10	19	54	65	55	64	54
131486	2009-02-22	61	63	right	\N	\N	31	63	54	51	\N	61	\N	41	27	51	71	66	\N	62	\N	69	\N	56	65	60	47	43	50	\N	52	22	22	\N	5	22	27	22	22
131486	2008-08-30	61	63	right	\N	\N	31	63	54	51	\N	61	\N	41	27	51	71	66	\N	62	\N	69	\N	56	65	60	47	43	50	\N	52	22	22	\N	5	22	27	22	22
131486	2007-02-22	61	63	right	\N	\N	31	63	54	51	\N	61	\N	41	27	51	71	66	\N	62	\N	69	\N	56	65	60	47	43	50	\N	52	22	22	\N	5	22	27	22	22
46890	2014-05-16	60	60	left	medium	high	64	46	51	63	47	59	56	68	61	65	59	67	64	61	59	59	64	65	64	55	65	61	53	58	39	50	59	47	14	14	7	7	10
46890	2014-02-14	61	61	left	medium	high	64	46	51	63	47	59	56	68	61	67	64	67	64	61	59	59	64	70	71	55	69	66	53	58	39	50	59	47	14	14	7	7	10
46890	2013-09-20	61	63	left	medium	high	64	46	51	63	47	59	56	68	61	67	64	67	64	61	59	59	64	70	71	55	69	66	53	58	39	50	59	47	14	14	7	7	10
46890	2012-08-31	61	63	left	medium	high	64	46	51	63	47	59	56	68	61	67	64	67	64	61	59	59	64	70	71	55	69	66	53	58	39	50	59	47	14	14	7	7	10
46890	2011-08-30	64	65	left	medium	medium	66	51	53	63	49	66	56	68	51	64	64	71	64	63	58	59	64	70	71	55	68	51	55	60	40	46	53	49	14	14	7	7	10
46890	2010-02-22	64	65	left	medium	medium	66	51	53	63	49	66	56	68	51	64	64	71	64	63	58	59	64	70	71	55	68	51	55	60	40	46	53	49	14	14	7	7	10
46890	2009-08-30	67	65	left	medium	medium	69	51	55	68	49	71	56	68	51	67	64	71	64	63	58	59	64	68	64	55	64	51	55	60	67	53	56	49	14	14	7	7	10
46890	2009-02-22	61	68	left	medium	medium	64	45	49	63	49	67	56	68	51	67	72	71	64	51	58	54	64	50	60	50	54	51	50	60	49	20	28	49	14	14	7	7	10
46890	2008-08-30	62	66	left	medium	medium	64	45	49	63	49	67	56	68	51	67	72	71	64	51	58	54	64	50	60	50	54	51	50	60	49	20	28	49	14	14	7	7	10
46890	2007-08-30	52	59	right	medium	medium	52	45	49	40	49	57	56	68	47	53	55	57	64	51	58	54	64	50	60	50	54	51	50	60	49	20	28	49	14	14	47	7	10
46890	2007-02-22	52	59	right	medium	medium	52	45	49	40	49	57	56	49	47	53	55	57	64	51	58	54	64	50	60	50	54	51	50	60	49	12	28	49	14	3	47	13	19
36836	2011-02-22	67	70	left	\N	\N	59	57	58	69	61	71	63	64	65	72	66	61	65	64	67	73	65	62	65	67	56	45	65	68	64	45	54	52	7	10	13	12	10
36836	2010-02-22	67	70	left	\N	\N	59	57	58	69	61	71	63	64	65	72	66	61	65	64	67	73	65	62	65	67	56	45	65	68	64	45	54	52	7	10	13	12	10
36836	2009-08-30	63	65	left	\N	\N	59	53	63	62	61	65	63	61	61	67	66	63	65	62	67	70	65	60	65	65	65	64	60	68	55	45	54	52	7	10	61	12	10
36836	2007-08-30	63	65	left	\N	\N	59	53	63	62	61	65	63	61	61	67	66	63	65	62	67	70	65	60	65	65	65	64	60	68	55	45	54	52	7	10	61	12	10
36836	2007-02-22	56	72	left	\N	\N	59	53	48	62	61	53	63	55	61	56	53	53	65	62	67	70	65	58	54	65	54	64	60	68	55	35	40	52	7	12	61	14	13
148302	2016-05-05	76	78	right	high	medium	54	64	80	68	50	67	39	47	64	74	75	79	65	79	60	74	78	92	86	59	84	81	72	63	52	70	81	75	15	8	9	12	9
148302	2016-04-07	76	78	right	high	medium	54	64	80	68	50	67	39	47	64	74	74	79	65	79	60	74	78	92	86	59	84	81	72	63	52	70	81	75	15	8	9	12	9
148302	2016-02-11	75	77	right	high	medium	54	62	79	64	47	64	39	47	62	72	71	79	65	79	57	72	78	92	86	59	84	81	70	61	52	70	81	75	15	8	9	12	9
148302	2015-12-24	75	77	right	medium	medium	54	61	79	64	47	64	39	47	62	72	71	79	65	79	57	72	78	92	86	59	84	81	68	61	52	70	81	75	15	8	9	12	9
148302	2015-11-06	75	78	right	medium	medium	54	61	79	64	47	64	39	47	62	72	71	79	65	79	57	72	78	92	86	59	84	81	68	61	52	70	81	75	15	8	9	12	9
148302	2015-10-16	75	78	right	medium	medium	54	61	79	64	47	64	39	47	62	72	69	79	65	79	57	72	78	92	86	59	84	81	68	61	52	70	81	75	15	8	9	12	9
148302	2015-09-21	75	78	right	medium	medium	54	61	79	64	47	64	39	47	62	72	69	82	65	79	57	72	78	92	86	59	84	81	68	61	52	70	81	75	15	8	9	12	9
148302	2015-04-10	72	78	right	medium	medium	46	54	78	66	46	61	38	46	64	68	67	87	59	74	57	71	78	92	86	58	79	71	58	60	51	67	78	73	14	7	8	11	8
148302	2015-03-20	71	77	right	medium	medium	46	54	78	66	46	61	38	46	64	68	67	87	59	74	57	71	78	92	86	58	79	71	58	60	51	66	78	73	14	7	8	11	8
148302	2014-09-18	71	77	right	medium	medium	46	54	78	66	46	61	38	46	64	68	67	87	59	74	57	71	78	92	86	58	79	71	58	60	51	66	78	73	14	7	8	11	8
148302	2014-05-02	74	77	right	high	high	46	54	78	65	46	61	38	46	64	66	67	85	59	71	57	71	78	92	86	58	79	67	58	56	51	66	78	73	14	7	8	11	8
148302	2014-04-25	74	77	right	medium	medium	46	54	78	67	46	61	38	46	64	66	75	85	63	71	57	71	78	84	86	58	75	67	58	56	51	66	78	73	14	7	8	11	8
148302	2014-01-24	74	77	right	medium	medium	46	54	78	67	46	61	38	46	64	66	75	85	63	71	57	71	78	84	86	58	75	67	58	56	51	66	78	73	14	7	8	11	8
148302	2014-01-03	74	77	right	medium	medium	46	54	78	67	46	61	38	46	64	66	75	85	63	71	57	71	78	84	86	58	75	68	58	56	51	66	78	73	14	7	8	11	8
148302	2013-12-13	74	78	right	medium	medium	46	54	78	67	46	61	38	46	64	66	75	85	63	71	57	71	78	84	86	58	75	68	58	56	51	66	78	73	14	7	8	11	8
148302	2013-11-01	74	80	right	medium	medium	46	54	78	67	46	61	38	46	64	66	75	85	63	71	57	71	78	84	86	58	75	68	58	56	51	66	78	73	14	7	8	11	8
148302	2013-10-25	74	80	right	medium	medium	46	54	78	68	46	58	38	46	64	66	73	85	63	71	57	68	78	84	86	58	74	68	58	56	51	68	78	73	14	7	8	11	8
148302	2013-10-11	75	80	right	medium	medium	46	54	78	68	46	58	38	46	64	66	73	85	63	73	57	68	78	84	86	58	75	68	58	57	51	71	78	73	14	7	8	11	8
148302	2013-10-04	75	80	right	medium	medium	51	54	78	68	46	58	38	46	64	66	78	81	63	73	57	68	80	84	86	58	75	70	58	57	51	71	76	73	14	7	8	11	8
148302	2013-09-20	75	80	right	medium	medium	51	54	78	68	46	63	38	46	64	66	78	85	64	73	57	68	82	84	88	58	75	74	58	57	51	69	76	71	14	7	8	11	8
148302	2013-05-31	75	80	right	medium	medium	51	54	78	68	46	63	38	46	64	66	78	85	68	73	57	68	82	84	88	58	75	74	58	57	51	69	76	71	14	7	8	11	8
148302	2013-03-22	75	80	right	medium	medium	51	54	78	68	46	63	38	46	64	66	78	85	68	73	57	68	82	84	88	58	75	74	58	57	51	69	76	71	14	7	8	11	8
148302	2013-03-15	75	80	right	medium	medium	51	54	78	68	46	63	38	46	64	66	78	85	68	73	57	68	82	84	88	58	75	74	58	57	51	69	76	71	14	7	8	11	8
148302	2013-02-22	75	80	right	medium	medium	51	54	78	68	46	63	38	46	64	66	78	85	68	73	57	68	82	84	88	58	75	74	58	57	51	69	76	71	14	7	8	11	8
148302	2013-02-15	75	80	right	medium	medium	51	54	78	68	46	63	38	46	64	66	78	85	68	73	57	68	82	85	88	58	75	74	58	57	51	69	76	71	14	7	8	11	8
148302	2012-08-31	74	80	right	medium	medium	51	57	77	68	56	63	38	46	64	66	80	85	71	71	51	68	78	91	88	58	75	73	61	63	51	68	75	71	14	7	8	11	8
148302	2012-02-22	73	78	left	medium	medium	51	58	78	68	56	63	38	46	63	68	78	85	71	68	55	71	73	93	88	61	81	66	61	63	51	68	73	66	14	7	8	11	8
148302	2011-08-30	69	77	left	high	high	53	58	76	66	56	61	38	46	63	66	76	85	68	68	48	73	73	93	88	63	78	66	64	53	51	63	71	66	14	7	8	11	8
148302	2011-02-22	69	81	left	high	high	53	62	75	66	56	63	48	56	63	68	73	83	68	69	80	74	70	88	85	66	81	68	62	65	54	64	71	68	14	7	8	11	8
148302	2010-08-30	71	81	left	high	high	53	62	78	71	56	63	48	56	66	68	73	83	68	69	80	76	70	88	85	66	81	68	66	67	54	63	73	71	14	7	8	11	8
148302	2010-02-22	66	76	left	high	high	48	61	72	62	56	61	48	53	57	66	68	75	68	66	80	75	70	87	85	57	78	57	62	67	68	58	66	71	15	21	57	21	21
148302	2009-08-30	62	76	left	high	high	43	58	68	58	56	58	48	51	53	61	65	73	68	60	80	73	70	76	75	55	68	64	65	67	58	55	66	71	15	21	53	21	21
148302	2008-08-30	54	72	right	high	high	44	37	62	53	56	58	48	43	41	62	62	67	68	57	80	72	70	72	75	53	60	37	40	67	48	36	48	71	5	21	41	21	21
148302	2007-02-22	54	72	right	high	high	44	37	62	53	56	58	48	43	41	62	62	67	68	57	80	72	70	72	75	53	60	37	40	67	48	36	48	71	5	21	41	21	21
38312	2010-08-30	64	66	right	\N	\N	48	42	54	55	44	57	44	42	54	56	73	71	68	60	56	52	64	78	64	47	79	66	61	69	66	69	68	64	9	11	12	7	15
38312	2010-02-22	62	64	right	\N	\N	48	42	54	55	44	57	44	42	54	46	71	71	68	60	56	52	64	75	63	47	79	65	59	69	55	67	64	64	13	20	54	20	20
38312	2009-08-30	62	64	right	\N	\N	48	42	54	55	44	57	44	42	54	46	71	71	68	60	56	52	64	75	63	47	79	65	59	69	55	67	64	64	13	20	54	20	20
38312	2008-08-30	62	64	right	\N	\N	48	42	54	55	44	57	44	42	54	46	71	71	68	60	56	52	64	75	63	47	79	65	59	69	55	67	64	64	13	20	54	20	20
38312	2007-08-30	61	64	right	\N	\N	48	42	54	55	44	57	44	42	54	46	71	71	68	60	56	52	64	75	63	47	79	65	59	69	55	67	64	64	13	20	54	20	20
38312	2007-02-22	61	64	right	\N	\N	48	42	54	55	44	57	44	55	54	46	71	71	68	60	56	52	64	75	63	47	79	65	59	69	55	67	64	64	13	11	54	15	8
75500	2011-08-30	64	68	right	medium	low	51	62	62	54	60	61	43	53	42	60	71	80	79	67	67	65	70	63	68	56	46	35	64	59	58	18	20	28	14	15	6	11	6
75500	2011-02-22	63	71	right	medium	low	51	62	62	54	60	61	43	53	42	60	70	74	71	67	64	65	70	63	68	56	46	35	64	59	58	18	20	28	14	15	6	11	6
75500	2010-08-30	64	71	right	medium	low	51	64	62	54	60	61	43	53	42	60	70	74	71	67	64	67	70	63	68	56	46	35	64	59	58	18	20	28	14	15	6	11	6
75500	2010-02-22	64	71	right	medium	low	51	64	62	54	60	61	43	53	42	60	70	74	71	67	64	67	70	63	68	56	46	49	56	59	58	21	21	28	15	21	42	21	23
75500	2009-08-30	63	71	right	medium	low	48	64	60	54	60	59	43	53	41	58	69	74	71	67	64	65	70	63	68	56	46	49	56	59	58	21	21	28	15	21	41	21	23
75500	2009-02-22	56	71	right	medium	low	28	51	52	31	60	50	43	53	26	49	74	72	71	72	64	57	70	59	64	45	45	37	36	59	39	21	21	28	5	21	26	21	21
75500	2008-08-30	56	71	right	medium	low	28	51	52	31	60	50	43	53	26	49	74	72	71	72	64	57	70	59	64	45	45	37	36	59	39	21	21	28	5	21	26	21	21
75500	2007-02-22	56	71	right	medium	low	28	51	52	31	60	50	43	53	26	49	74	72	71	72	64	57	70	59	64	45	45	37	36	59	39	21	21	28	5	21	26	21	21
148315	2016-02-04	80	83	right	medium	medium	58	81	85	72	74	75	60	67	48	81	75	79	74	71	48	85	82	77	92	76	76	29	76	73	77	25	30	18	14	5	12	8	5
148315	2015-12-10	82	85	right	medium	medium	58	82	85	72	74	75	60	67	48	81	75	79	74	75	48	85	82	77	92	76	76	29	81	73	77	25	30	18	14	5	12	8	5
148315	2015-09-21	82	86	right	medium	medium	58	82	85	72	74	75	60	67	48	81	75	79	74	75	48	85	82	77	92	76	76	29	81	73	77	25	30	18	14	5	12	8	5
148315	2015-05-15	81	84	right	medium	medium	58	83	84	72	72	75	60	67	48	80	77	78	74	68	48	85	81	77	91	76	76	29	81	73	81	25	30	25	14	5	12	8	5
148315	2015-05-01	80	83	right	medium	medium	58	82	84	72	72	75	60	54	48	78	77	78	74	68	48	85	81	77	91	76	73	29	81	73	81	25	30	25	14	5	12	8	5
148315	2015-03-13	80	83	right	medium	medium	58	82	84	72	72	75	60	46	48	78	77	78	74	68	48	85	81	77	91	76	80	29	81	73	81	25	30	25	14	5	12	8	5
148315	2015-02-27	80	85	right	medium	medium	58	82	84	72	72	75	60	46	48	78	77	78	74	68	48	85	81	77	91	76	80	29	81	73	81	25	30	25	14	5	12	8	5
148315	2014-11-14	80	85	right	medium	medium	58	82	84	72	72	75	60	46	48	78	79	81	74	68	48	85	81	77	91	76	80	29	81	73	81	25	30	25	14	5	12	8	5
148315	2014-09-18	80	85	right	medium	medium	58	82	84	73	72	75	60	46	48	79	79	81	74	68	48	85	81	77	92	76	80	29	81	73	81	25	30	25	14	5	12	8	5
148315	2014-03-21	81	87	right	medium	medium	58	84	81	73	72	75	60	46	48	79	82	81	74	68	48	83	81	77	90	78	80	29	81	70	81	25	30	25	14	5	12	8	5
148315	2013-11-01	81	87	right	medium	medium	58	84	81	73	72	75	60	46	48	79	82	81	70	68	48	83	81	77	90	78	80	29	81	70	81	25	30	25	14	5	12	8	5
148315	2013-09-27	81	87	right	medium	medium	58	84	81	73	72	75	60	46	48	79	82	81	70	68	48	83	81	77	90	78	80	29	81	70	84	25	30	25	14	5	12	8	5
148315	2013-09-20	80	85	right	medium	medium	58	83	81	73	70	75	60	46	48	79	82	81	70	68	48	83	81	77	90	78	80	29	78	70	84	25	30	25	14	5	12	8	5
148315	2013-05-03	77	84	right	medium	medium	58	78	80	65	60	70	46	46	46	76	77	81	68	70	44	78	81	76	89	66	69	29	78	70	74	17	27	20	14	5	12	8	5
148315	2013-04-26	76	82	right	medium	medium	58	77	79	65	60	70	46	46	46	76	77	81	68	70	44	78	78	76	89	66	69	29	78	70	74	17	27	20	14	5	12	8	5
148315	2013-04-19	76	82	right	medium	medium	58	77	79	65	60	70	46	46	46	76	77	81	68	70	44	75	78	76	89	66	69	29	78	70	74	17	27	20	14	5	12	8	5
148315	2013-03-28	76	82	right	medium	medium	58	75	79	65	60	70	46	46	46	76	77	81	68	70	44	75	78	76	89	66	69	29	78	70	74	17	27	20	14	5	12	8	5
148315	2013-03-08	75	81	right	medium	medium	58	75	79	65	60	70	46	46	46	76	77	81	68	71	44	75	79	76	89	66	69	29	75	70	74	17	27	20	14	5	12	8	5
148315	2013-02-15	73	81	right	medium	medium	58	74	76	65	60	70	46	46	46	75	77	81	68	69	44	75	79	76	89	61	69	29	75	70	74	17	27	20	14	5	12	8	5
148315	2012-08-31	72	80	right	medium	medium	58	73	75	65	63	69	46	46	46	71	78	81	68	68	44	74	72	75	87	61	46	31	69	65	57	19	27	20	14	5	12	8	5
148315	2012-02-22	68	74	right	medium	medium	48	67	72	62	57	66	46	46	40	63	78	80	68	64	44	73	71	75	85	58	51	31	63	56	54	19	27	20	14	5	12	8	5
148315	2011-08-30	67	76	right	medium	medium	39	67	72	60	55	61	46	46	40	66	77	80	63	64	44	71	71	75	85	58	51	41	62	62	54	19	47	20	14	5	12	8	5
148315	2010-08-30	67	76	right	medium	medium	39	67	72	60	55	61	46	46	40	66	73	78	61	64	74	71	79	73	78	58	51	41	62	62	54	19	47	20	14	5	12	8	5
148315	2010-02-22	66	78	right	medium	medium	29	67	68	54	55	61	46	46	40	66	73	78	61	62	74	74	79	72	78	54	51	48	47	62	60	21	54	20	1	21	40	21	21
148315	2009-08-30	63	78	right	medium	medium	29	66	65	45	55	61	46	46	40	63	63	65	61	62	74	66	79	72	78	54	48	46	42	62	55	21	54	20	1	21	40	21	21
148315	2009-02-22	56	78	right	medium	medium	29	45	58	37	55	58	46	46	28	63	63	65	61	62	74	62	79	72	78	42	48	46	42	62	46	21	23	20	1	21	28	21	21
148315	2008-08-30	56	78	right	medium	medium	29	45	58	37	55	58	46	46	28	63	63	65	61	62	74	62	79	72	78	42	48	46	42	62	46	21	23	20	1	21	28	21	21
148315	2007-02-22	56	78	right	medium	medium	29	45	58	37	55	58	46	46	28	63	63	65	61	62	74	62	79	72	78	42	48	46	42	62	46	21	23	20	1	21	28	21	21
38246	2011-02-22	64	70	left	\N	\N	71	60	51	65	65	65	76	69	67	70	58	64	65	61	57	70	62	53	65	71	48	35	52	62	83	22	39	35	7	14	9	5	10
38246	2010-02-22	64	70	left	\N	\N	71	60	51	65	65	65	76	69	67	70	58	64	65	61	57	70	62	53	65	71	48	35	52	62	83	22	39	35	7	14	9	5	10
38246	2009-08-30	64	69	left	\N	\N	71	60	51	65	65	70	76	69	67	65	58	64	65	61	57	70	62	53	65	71	59	35	52	62	83	44	39	35	7	14	9	5	10
38246	2009-02-22	66	69	left	\N	\N	75	62	51	67	65	73	76	67	69	68	58	64	65	61	57	70	62	53	65	69	59	35	52	62	83	44	39	35	7	14	69	5	10
38246	2008-08-30	66	69	left	\N	\N	75	62	51	67	65	73	76	67	69	68	58	64	65	61	57	70	62	53	65	69	59	35	52	62	83	44	39	35	7	14	69	5	10
38246	2007-08-30	71	72	left	\N	\N	75	62	51	67	65	73	76	66	69	68	58	64	65	61	57	70	62	53	65	69	59	35	52	62	83	44	39	35	7	14	69	5	10
38246	2007-02-22	70	69	left	\N	\N	75	62	51	65	65	72	76	62	70	68	58	64	65	61	57	70	62	68	65	69	59	35	52	62	83	44	39	35	7	9	70	10	6
37044	2013-02-15	66	66	right	medium	high	71	35	67	66	32	58	63	68	62	67	66	64	66	65	64	65	75	80	75	45	78	70	57	54	59	57	64	66	11	11	9	15	13
37044	2012-08-31	68	69	right	medium	high	71	35	67	68	32	58	63	68	64	67	66	64	69	67	67	65	72	78	70	45	78	73	57	57	59	64	69	68	11	11	9	15	13
37044	2011-08-30	68	69	right	medium	high	71	35	67	68	32	58	63	68	64	67	66	64	69	67	67	65	72	78	70	45	78	73	57	57	59	64	69	68	11	11	9	15	13
37044	2011-02-22	68	72	right	medium	high	69	35	67	68	32	56	63	69	64	67	64	66	66	65	74	65	67	78	73	45	80	73	57	66	42	64	69	67	11	11	9	15	13
37044	2010-08-30	68	72	right	medium	high	69	35	67	68	32	56	63	69	64	67	64	66	66	65	74	65	67	78	73	45	76	73	57	66	42	64	69	67	11	11	9	15	13
37044	2010-02-22	68	72	right	medium	high	64	35	67	67	32	55	63	61	62	65	64	66	66	65	74	65	67	78	73	45	76	76	73	66	72	65	69	67	3	23	62	23	23
37044	2009-08-30	69	72	right	medium	high	66	35	67	68	32	56	63	41	63	66	64	66	66	65	74	65	67	78	73	45	76	76	73	66	72	66	69	67	3	23	63	23	23
37044	2008-08-30	64	69	right	medium	high	48	35	65	64	32	46	63	41	58	56	63	66	66	60	74	60	67	73	68	45	69	65	63	66	66	63	66	67	3	23	58	23	23
37044	2007-08-30	63	69	right	medium	high	48	35	65	64	32	46	63	41	58	56	63	66	66	60	74	60	67	73	68	45	69	65	63	66	66	63	66	67	3	23	58	23	23
37044	2007-02-22	56	57	right	medium	high	43	35	55	58	32	45	63	51	53	51	55	60	66	52	74	60	67	63	59	45	61	65	63	66	51	54	57	67	3	4	53	3	9
26916	2016-04-28	71	71	right	high	high	60	67	79	70	63	61	40	58	65	66	56	66	48	74	46	71	59	90	84	64	79	71	76	69	69	66	70	63	11	7	16	10	12
26916	2016-04-21	70	70	right	high	high	60	67	77	70	63	61	40	58	65	66	56	66	53	74	46	71	59	90	84	64	79	69	76	69	69	64	68	61	11	7	16	10	12
26916	2016-03-17	70	70	right	high	high	60	67	77	70	63	61	40	58	65	66	56	66	53	74	46	71	59	90	84	64	79	69	76	70	69	64	68	61	11	7	16	10	12
26916	2015-09-21	70	70	right	high	high	60	67	77	70	63	61	40	58	65	66	56	66	53	74	46	71	59	90	84	64	79	69	76	70	69	64	68	61	11	7	16	10	12
26916	2015-03-13	69	69	right	high	high	59	66	76	69	62	60	39	57	64	65	59	68	53	73	46	70	57	89	84	63	78	68	76	69	68	63	67	60	10	6	15	9	11
26916	2015-02-20	69	69	right	high	high	59	66	76	69	62	60	39	57	64	65	59	68	53	73	46	70	67	89	84	63	78	68	76	69	68	63	67	60	10	6	15	9	11
26916	2015-01-30	69	69	right	high	high	59	66	76	69	62	60	39	57	64	65	59	68	53	73	46	70	67	89	84	63	78	68	76	69	68	63	67	60	10	6	15	9	11
26916	2015-01-09	69	69	right	high	high	59	66	76	69	62	60	39	57	64	65	59	68	53	73	46	70	67	89	84	63	78	68	76	69	68	63	67	60	10	6	15	9	11
26916	2014-09-18	68	68	right	high	high	56	64	73	68	62	62	39	57	63	66	59	68	58	73	46	69	67	87	83	63	78	66	76	69	68	58	67	62	10	6	15	9	11
26916	2014-08-01	67	68	right	high	high	56	64	71	67	62	63	39	57	62	66	59	67	58	70	46	68	67	85	83	61	78	63	73	65	68	59	66	63	10	6	15	9	11
26916	2014-03-07	67	68	right	high	high	56	64	71	67	62	63	39	57	62	66	59	67	58	70	46	68	67	85	83	61	78	63	73	65	68	59	66	63	10	6	15	9	11
26916	2014-02-14	67	68	right	high	medium	56	64	71	67	62	63	39	57	62	66	59	67	58	70	46	68	67	85	83	61	78	63	73	65	68	59	66	63	10	6	15	9	11
26916	2014-01-24	68	68	right	medium	high	56	68	73	69	62	63	39	57	62	66	59	70	58	72	46	70	67	87	86	65	78	64	74	70	68	59	66	63	10	6	15	9	11
26916	2014-01-17	68	68	right	high	medium	56	68	73	69	62	63	39	57	62	66	59	70	58	72	46	70	67	87	86	65	78	64	74	70	68	59	66	63	10	6	15	9	11
26916	2013-11-29	69	69	right	medium	medium	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	66	90	86	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2013-11-01	69	69	right	high	high	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	66	90	86	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2013-09-20	69	69	right	high	high	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	66	90	86	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2013-05-31	69	69	right	high	high	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	65	90	85	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2013-05-17	69	69	right	high	high	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	65	90	85	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2013-02-22	69	69	right	high	high	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	65	90	85	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2013-02-15	69	69	right	high	high	56	69	73	70	61	63	39	57	64	66	58	73	57	72	46	72	65	90	85	66	78	66	76	71	68	58	66	63	10	6	15	9	11
26916	2012-08-31	66	70	right	high	high	51	67	72	64	53	65	39	57	56	67	67	71	68	69	48	69	73	65	82	62	78	61	74	71	68	64	71	66	10	6	15	9	11
26916	2012-02-22	68	71	right	high	high	53	67	74	68	53	65	39	63	61	69	63	73	53	69	59	76	70	90	82	63	81	61	71	67	68	61	69	66	10	6	15	9	11
26916	2011-08-30	68	74	right	high	high	53	67	72	66	53	65	39	57	58	69	69	76	73	69	59	73	70	90	76	62	78	64	76	71	68	62	71	66	10	6	15	9	11
26916	2011-02-22	68	71	right	high	high	53	66	72	66	53	62	39	57	58	67	62	72	58	64	78	70	68	86	83	62	78	65	73	71	68	62	71	66	10	6	15	9	11
26916	2010-08-30	69	74	right	high	high	53	66	72	66	53	67	39	57	58	67	67	73	68	64	78	69	73	85	83	62	78	71	74	71	68	64	71	66	10	6	15	9	11
26916	2010-02-22	68	70	right	high	high	53	61	72	66	53	64	39	57	58	65	65	71	68	64	78	69	73	85	83	62	78	71	68	71	69	62	71	66	13	22	58	22	22
26916	2009-08-30	65	70	right	high	high	53	61	71	64	53	64	39	57	58	65	65	69	68	64	78	69	73	85	83	62	69	64	63	71	67	62	71	66	13	22	58	22	22
26916	2008-08-30	61	67	right	high	high	53	48	70	61	53	64	39	33	58	52	63	67	68	64	78	69	73	78	67	60	63	64	58	71	52	39	27	66	13	22	58	22	22
26916	2007-02-22	61	67	right	high	high	53	48	70	61	53	64	39	33	58	52	63	67	68	64	78	69	73	78	67	60	63	64	58	71	52	39	27	66	13	22	58	22	22
24037	2013-10-18	63	63	right	medium	low	43	63	60	52	65	66	63	44	44	64	68	53	59	55	76	70	73	58	83	61	58	25	62	57	44	25	21	21	8	11	14	6	7
24037	2013-09-20	63	64	right	medium	low	43	63	60	52	65	66	63	44	44	64	68	53	59	55	76	70	73	58	83	61	58	25	62	57	44	25	21	21	8	11	14	6	7
24037	2010-08-30	63	64	right	medium	low	43	63	60	52	65	66	63	44	44	64	68	53	59	55	76	70	73	58	83	61	58	25	62	57	44	25	21	21	8	11	14	6	7
24037	2010-02-22	69	64	right	medium	low	46	71	60	55	65	71	63	44	44	64	68	78	59	70	76	75	73	43	73	61	58	64	68	57	66	20	21	21	13	20	44	20	20
24037	2009-08-30	69	64	right	medium	low	46	71	60	55	65	71	63	44	44	64	68	78	59	70	76	75	73	43	73	61	58	64	68	57	66	20	21	21	13	20	44	20	20
24037	2008-08-30	71	78	right	medium	low	46	70	60	55	65	73	63	44	44	70	84	82	59	74	76	76	73	77	74	61	71	64	79	57	66	22	41	21	13	20	44	20	20
24037	2008-02-22	74	78	right	medium	low	46	70	60	70	65	73	63	44	54	70	84	82	59	74	76	76	73	77	74	61	71	64	79	57	66	52	41	21	13	20	54	20	20
24037	2007-08-30	74	78	right	medium	low	46	70	60	70	65	73	63	44	54	70	84	82	59	74	76	76	73	77	74	61	71	64	79	57	66	52	41	21	13	20	54	20	20
24037	2007-02-22	77	84	right	medium	low	46	76	60	70	65	78	63	66	54	74	86	82	59	82	76	76	73	77	74	69	77	64	79	57	66	52	41	21	13	6	54	14	11
104388	2012-08-31	58	64	right	medium	medium	12	11	13	32	11	10	10	11	26	11	61	56	53	52	43	11	63	51	73	10	72	20	10	38	14	13	11	11	61	56	58	53	64
104388	2011-02-22	58	64	right	medium	medium	12	11	13	32	11	10	10	11	26	11	61	56	53	52	43	11	63	51	73	10	72	20	10	38	14	13	11	11	61	56	58	53	64
104388	2010-08-30	58	64	right	medium	medium	7	6	8	32	6	5	5	6	26	11	61	56	53	52	43	6	63	63	73	5	72	20	10	38	9	8	11	6	61	56	58	53	64
104388	2010-02-22	52	67	right	medium	medium	21	21	21	32	6	21	5	6	49	21	61	56	53	52	43	21	63	64	73	21	72	39	26	38	31	21	21	6	48	53	49	52	53
104388	2008-08-30	52	67	right	medium	medium	21	21	21	32	6	21	5	6	49	21	61	56	53	52	43	21	63	76	73	21	72	39	26	38	31	21	21	6	48	53	49	52	53
104388	2007-02-22	52	67	right	medium	medium	21	21	21	32	6	21	5	6	49	21	61	56	53	52	43	21	63	76	73	21	72	39	26	38	31	21	21	6	48	53	49	52	53
38920	2016-05-12	77	77	right	high	high	66	78	77	72	79	78	70	66	58	80	68	78	68	76	58	79	72	69	79	72	66	25	80	69	73	16	24	20	9	5	13	8	12
38920	2016-05-05	77	77	right	high	high	66	78	77	72	79	78	70	66	58	80	68	78	68	76	58	79	72	74	79	72	66	25	80	69	73	16	24	20	9	5	13	8	12
38920	2016-04-28	77	77	right	high	high	66	78	77	72	79	78	70	66	58	80	68	78	68	76	58	79	72	74	79	72	72	25	80	69	73	16	24	20	9	5	13	8	12
38920	2016-04-21	77	77	right	high	high	67	78	78	73	70	78	70	71	59	80	68	78	68	77	58	79	72	74	79	73	77	25	79	69	77	16	24	20	9	5	13	8	12
38920	2016-04-07	77	77	right	high	high	67	78	78	73	70	78	75	71	59	80	68	78	68	77	58	79	72	74	79	73	77	25	79	69	77	16	24	20	9	5	13	8	12
38920	2016-03-10	77	77	right	high	high	67	78	78	73	70	76	75	71	59	78	68	78	68	77	58	79	72	74	79	73	77	25	79	69	77	16	24	20	9	5	13	8	12
38920	2016-01-07	77	77	right	high	high	67	77	78	73	70	76	75	71	59	78	68	78	68	77	58	79	72	74	79	73	73	25	79	69	77	16	24	20	9	5	13	8	12
38920	2015-09-21	77	77	right	high	high	67	77	77	73	70	76	75	71	59	78	68	78	68	75	58	79	72	74	79	73	73	25	79	69	77	16	24	20	9	5	13	8	12
38920	2015-05-08	75	75	right	high	high	66	76	76	72	69	75	74	70	58	77	68	78	68	74	58	78	72	74	80	72	72	24	78	68	76	25	23	25	8	4	12	7	11
38920	2015-03-20	75	75	right	high	high	66	76	76	72	69	75	74	70	58	77	68	78	68	74	58	78	72	74	80	72	72	24	78	68	76	25	23	25	8	4	12	7	11
38920	2015-02-20	75	75	right	high	high	66	76	76	72	68	76	74	70	58	78	68	78	68	74	58	78	78	76	82	72	72	24	76	68	76	25	23	25	8	4	12	7	11
38920	2014-09-18	74	74	right	medium	medium	65	75	77	77	65	77	75	75	51	80	63	72	65	73	58	75	78	69	82	75	64	24	74	75	72	25	23	25	8	4	12	7	11
38920	2014-04-25	76	76	right	medium	medium	66	76	80	78	70	80	76	76	52	83	64	72	64	75	58	76	78	70	82	76	65	25	77	81	73	25	24	20	9	5	13	8	12
38920	2014-04-18	76	76	right	medium	medium	66	76	80	78	70	80	76	76	52	83	64	72	64	75	58	76	78	70	82	76	65	25	77	79	73	25	24	20	9	5	13	8	12
38920	2014-04-11	76	76	right	medium	medium	68	72	80	77	70	80	76	76	51	83	64	72	64	73	58	80	78	70	82	76	64	26	76	78	73	25	24	20	9	5	13	8	12
38920	2014-04-04	76	76	right	medium	medium	68	72	80	77	70	80	76	76	51	83	64	72	68	75	59	80	79	75	79	76	55	25	75	78	73	25	24	20	9	5	13	8	12
38920	2013-11-01	78	78	right	high	medium	68	78	80	77	70	80	76	76	51	83	68	74	69	77	56	80	79	75	79	76	55	25	79	78	73	25	24	20	9	5	13	8	12
38920	2013-10-18	78	78	right	high	medium	68	78	80	77	70	80	76	76	51	83	68	74	68	77	56	80	79	75	78	76	55	25	79	78	73	25	24	20	9	5	13	8	12
38920	2013-10-04	78	78	right	high	medium	68	78	80	77	70	80	76	76	51	83	68	74	68	77	56	80	79	75	78	76	55	25	79	78	73	25	24	20	9	5	13	8	12
38920	2013-09-27	78	78	right	high	medium	68	78	80	77	70	80	76	76	51	83	68	74	68	77	56	80	79	75	78	76	55	25	78	78	73	25	24	20	9	5	13	8	12
38920	2013-09-20	78	78	right	high	medium	74	80	80	77	72	80	78	76	59	83	69	74	69	77	56	80	79	75	78	77	55	25	78	78	73	25	24	20	9	5	13	8	12
38920	2013-04-26	78	78	right	high	medium	72	78	82	78	72	83	78	76	62	83	73	77	63	76	49	80	78	69	77	70	73	34	78	78	72	16	30	25	9	5	13	8	12
38920	2013-04-19	78	78	right	high	medium	72	76	82	78	72	83	78	76	62	83	73	77	63	76	49	80	78	69	77	70	73	34	78	78	72	16	30	25	9	5	13	8	12
38920	2013-04-05	78	78	right	high	medium	72	76	82	78	72	83	78	76	62	83	73	77	63	76	49	80	78	69	77	70	60	34	78	78	72	16	30	25	9	5	13	8	12
38920	2013-03-08	77	77	right	high	medium	72	75	82	78	72	83	76	68	62	83	73	77	63	76	49	80	78	69	77	67	60	34	78	78	72	16	30	25	9	5	13	8	12
38920	2013-02-22	77	77	right	high	medium	72	75	82	78	72	83	76	68	62	83	73	77	63	76	49	80	78	69	77	67	60	34	78	78	72	15	30	25	9	5	13	8	12
38920	2013-02-15	77	77	right	high	medium	72	75	82	78	72	83	76	68	62	83	73	77	63	76	49	80	78	69	79	67	65	44	78	78	72	27	41	34	9	5	13	8	12
38920	2012-08-31	75	75	right	high	medium	70	68	82	75	70	82	74	68	65	79	67	71	62	74	49	78	80	69	79	72	45	46	76	76	70	27	41	34	9	5	13	8	12
38920	2012-02-22	74	74	right	high	medium	61	75	82	72	63	74	56	61	56	75	62	64	58	72	49	76	78	69	79	66	45	46	78	69	64	27	41	34	9	5	13	8	12
38920	2011-08-30	70	70	right	high	medium	61	75	78	66	63	61	56	61	56	68	52	54	56	64	49	72	75	58	79	66	45	46	79	69	64	27	41	34	9	5	13	8	12
38920	2011-02-22	69	73	right	high	medium	61	75	78	66	63	61	56	61	56	68	62	67	63	64	78	72	65	67	80	66	45	46	79	69	64	27	41	34	9	5	13	8	12
38920	2010-08-30	67	69	right	high	medium	61	69	73	66	63	61	56	61	56	68	61	71	60	64	67	67	65	67	71	66	45	46	69	69	64	27	51	34	9	5	13	8	12
38920	2010-02-22	66	69	right	high	medium	61	69	71	64	63	61	56	61	56	68	62	69	60	64	67	67	65	67	68	60	45	68	66	69	60	27	51	34	14	21	56	21	21
38920	2009-08-30	65	69	right	high	medium	61	66	71	64	63	61	56	61	56	68	62	67	60	64	67	67	65	67	65	60	45	68	66	69	60	27	51	34	14	21	56	21	21
38920	2009-02-22	66	69	right	high	medium	61	66	73	64	63	61	56	61	56	68	62	69	60	64	67	67	65	71	72	68	65	68	66	69	60	27	51	34	14	21	56	21	21
38920	2008-08-30	68	71	right	high	medium	63	69	75	64	63	66	56	61	59	71	62	69	60	64	67	69	65	72	74	68	67	68	66	69	65	37	59	34	14	21	59	21	21
38920	2007-08-30	70	71	right	high	medium	63	69	75	64	63	66	56	61	59	71	62	69	60	64	67	69	65	72	74	68	67	68	66	69	65	37	59	34	14	21	59	21	21
38920	2007-02-22	68	69	right	high	medium	63	69	72	62	63	66	56	60	58	68	69	68	60	61	67	68	65	66	67	59	59	68	66	69	60	53	59	34	14	10	58	11	6
39878	2013-09-20	67	69	right	medium	high	54	31	65	65	27	54	29	32	62	63	64	67	58	68	59	55	64	72	76	34	72	69	37	47	45	66	67	65	12	8	9	11	9
39878	2013-02-15	68	71	right	medium	high	54	31	66	65	27	54	29	32	62	65	64	67	58	69	59	55	65	72	76	34	72	71	37	54	45	67	69	66	12	8	9	11	9
39878	2012-08-31	68	71	right	medium	high	54	31	66	65	27	54	29	32	62	65	64	69	57	69	54	55	65	72	76	34	72	71	37	54	45	67	69	66	12	8	9	11	9
39878	2012-02-22	69	72	right	medium	high	54	31	66	65	27	54	29	32	62	65	64	69	57	69	59	55	65	72	79	34	74	72	37	54	45	67	70	66	12	8	9	11	9
39878	2011-08-30	69	72	right	medium	high	57	31	65	65	30	55	29	31	62	67	64	69	57	69	59	55	65	72	79	33	74	72	37	54	45	67	71	66	12	8	9	11	9
39878	2011-02-22	67	72	right	medium	high	57	26	65	65	30	42	29	31	62	64	62	67	60	64	69	55	62	72	72	33	67	74	35	72	45	67	68	66	12	8	9	11	9
39878	2010-08-30	67	72	right	medium	high	57	26	65	65	30	42	29	31	62	62	62	67	60	64	69	55	62	72	72	33	67	74	35	70	45	67	67	65	12	8	9	11	9
39878	2010-02-22	67	74	right	medium	high	63	22	65	66	30	52	29	31	62	62	62	69	60	60	69	55	62	72	69	33	67	72	69	70	71	68	69	65	13	22	62	22	22
39878	2009-08-30	65	72	right	medium	high	63	22	64	66	30	52	29	31	62	62	62	67	60	60	69	55	62	71	67	33	63	72	69	70	56	66	67	65	13	22	62	22	22
39878	2008-08-30	62	69	right	medium	high	63	22	59	66	30	60	29	31	62	69	69	64	60	52	69	50	62	66	65	33	63	72	69	70	56	61	63	65	13	22	62	22	22
39878	2007-08-30	63	69	right	medium	high	63	22	59	66	30	52	29	31	62	69	69	60	60	52	69	50	62	62	57	33	63	72	69	70	56	58	63	65	13	22	62	22	22
39878	2007-02-22	56	64	right	medium	high	47	16	59	60	30	36	29	48	51	53	55	60	60	52	69	50	62	62	57	33	63	72	69	70	48	58	59	65	13	7	51	11	18
38434	2011-02-22	58	59	right	\N	\N	12	18	24	24	18	13	15	11	26	25	43	35	55	37	42	38	46	45	46	15	35	22	10	38	26	20	12	12	59	54	56	57	64
38434	2010-08-30	58	60	right	\N	\N	26	18	24	24	18	27	29	29	26	25	43	35	55	37	42	38	46	45	46	15	35	22	10	38	26	20	29	45	59	54	56	57	64
38434	2009-08-30	54	57	right	\N	\N	26	22	24	24	18	27	29	29	52	25	43	35	55	37	42	38	46	45	46	27	35	29	17	38	28	22	29	45	55	50	52	53	60
38434	2007-08-30	54	57	right	\N	\N	26	22	24	24	18	27	29	29	52	25	43	35	55	37	42	38	46	45	46	27	35	29	17	38	28	22	29	45	55	50	52	53	60
38434	2007-02-22	54	57	right	\N	\N	26	18	24	24	18	27	29	28	52	25	43	35	55	37	42	38	46	45	46	27	35	29	17	38	28	20	29	45	55	50	52	53	60
46004	2008-08-30	59	65	left	\N	\N	52	40	54	59	\N	67	\N	44	55	58	72	67	\N	56	\N	41	\N	60	58	45	54	45	58	\N	56	57	62	\N	6	22	55	22	22
46004	2007-08-30	57	60	left	\N	\N	52	40	54	50	\N	62	\N	44	43	58	72	67	\N	38	\N	41	\N	60	58	45	54	45	58	\N	56	35	28	\N	6	22	43	22	22
46004	2007-02-22	57	60	left	\N	\N	52	40	54	50	\N	62	\N	44	43	58	72	67	\N	38	\N	41	\N	60	58	45	54	45	58	\N	56	35	28	\N	6	22	43	22	22
38247	2009-08-30	62	63	right	\N	\N	51	38	61	53	\N	43	\N	43	49	45	61	63	\N	60	\N	62	\N	66	71	47	73	54	60	\N	48	64	66	\N	3	22	49	22	22
38247	2009-02-22	62	64	right	\N	\N	51	38	61	53	\N	43	\N	43	49	45	61	63	\N	60	\N	62	\N	66	71	47	73	54	60	\N	48	64	66	\N	3	22	49	22	22
38247	2008-08-30	62	64	right	\N	\N	51	38	61	53	\N	43	\N	43	49	45	61	63	\N	60	\N	62	\N	66	71	47	73	54	60	\N	48	64	66	\N	3	22	49	22	22
38247	2007-08-30	58	64	right	\N	\N	51	38	55	53	\N	43	\N	43	49	45	65	63	\N	59	\N	62	\N	62	58	47	60	51	52	\N	48	63	65	\N	3	22	49	22	22
38247	2007-02-22	58	64	right	\N	\N	51	38	55	53	\N	43	\N	48	49	45	65	63	\N	59	\N	62	\N	62	58	47	60	51	52	\N	48	63	65	\N	3	4	49	3	7
67940	2008-08-30	60	63	left	\N	\N	52	36	51	64	\N	58	\N	49	62	61	62	60	\N	58	\N	51	\N	72	46	53	53	64	63	\N	61	47	53	\N	9	20	62	20	20
67940	2007-02-22	60	63	left	\N	\N	52	36	51	64	\N	58	\N	49	62	61	62	60	\N	58	\N	51	\N	72	46	53	53	64	63	\N	61	47	53	\N	9	20	62	20	20
37967	2015-09-21	65	66	right	medium	medium	60	65	55	63	62	74	64	61	55	72	68	73	71	68	76	63	63	62	55	59	34	38	62	65	58	31	44	49	8	12	12	8	16
37967	2014-10-10	65	66	right	medium	medium	60	65	55	63	62	74	64	61	55	72	68	73	71	68	76	63	63	62	55	59	34	38	62	65	58	31	44	49	8	12	12	8	16
37967	2011-08-30	65	66	right	medium	medium	60	65	55	63	62	74	64	61	55	72	68	73	71	68	76	63	63	62	55	59	34	38	62	65	58	31	44	49	8	12	12	8	16
37967	2010-08-30	64	68	right	medium	medium	60	65	55	63	62	75	64	61	55	72	68	73	71	68	59	63	63	62	55	59	34	38	62	65	58	31	44	49	8	12	12	8	16
37967	2010-02-22	65	73	right	medium	medium	60	65	55	63	62	75	64	61	55	72	68	73	71	68	59	63	63	62	55	59	34	54	56	65	58	31	44	49	8	20	54	20	20
37967	2009-08-30	64	73	right	medium	medium	54	65	55	57	62	72	64	61	49	69	68	73	71	68	59	63	63	62	55	59	63	60	61	65	60	31	44	49	8	20	49	20	20
37967	2008-08-30	63	76	right	medium	medium	43	65	55	51	62	72	64	61	39	67	68	73	71	68	59	63	63	62	52	59	63	60	54	65	60	31	44	49	8	20	39	20	20
37967	2007-08-30	65	78	right	medium	medium	43	65	55	51	62	72	64	61	39	67	68	73	71	68	59	63	63	62	52	59	63	60	54	65	60	31	44	49	8	20	39	20	20
37967	2007-02-22	67	82	right	medium	medium	43	65	55	61	62	74	64	70	39	67	73	74	71	72	59	63	63	69	52	63	63	60	54	65	70	31	44	49	8	6	39	12	10
36852	2013-05-31	65	65	right	medium	low	64	41	38	67	57	70	67	64	65	72	58	53	68	67	73	56	55	52	62	58	46	31	62	67	54	21	23	24	10	5	9	13	6
36852	2013-03-22	65	65	right	medium	low	64	41	38	67	57	70	67	64	65	72	58	53	68	67	73	56	55	52	62	58	46	31	62	67	54	21	23	24	10	5	9	13	6
36852	2013-03-15	66	66	right	medium	low	64	41	38	67	57	71	67	64	65	73	58	53	71	67	73	56	55	52	63	58	46	31	62	68	54	21	23	24	10	5	9	13	6
36852	2013-02-15	66	66	right	medium	low	64	41	38	67	57	71	67	64	65	73	58	53	71	67	73	56	55	52	63	58	46	31	62	68	54	21	23	24	10	5	9	13	6
36852	2012-08-31	66	66	right	medium	low	65	46	38	68	63	72	69	65	66	74	67	65	76	67	69	56	62	53	51	66	47	31	61	66	54	21	23	24	10	5	9	13	6
36852	2012-02-22	67	67	left	low	low	65	46	38	69	63	72	69	65	67	74	69	67	76	67	72	56	62	61	47	66	45	31	58	69	54	21	23	24	10	5	9	13	6
36852	2011-08-30	67	67	left	low	low	65	46	38	69	63	72	69	65	67	74	69	67	76	67	62	56	62	61	47	66	45	31	58	69	54	21	23	24	10	5	9	13	6
36852	2011-02-22	66	73	left	low	low	68	46	38	69	63	76	69	65	67	78	69	67	72	67	37	56	62	61	47	66	45	31	58	69	54	21	23	24	10	5	9	13	6
36852	2010-08-30	69	73	left	low	low	69	51	38	76	66	78	68	65	68	80	72	67	71	69	42	64	65	61	37	66	55	31	58	74	54	21	23	24	10	5	9	13	6
36852	2010-02-22	71	73	left	low	low	69	53	52	76	66	79	68	65	71	82	72	67	71	69	42	64	65	62	47	66	55	67	65	74	76	28	23	24	9	21	71	21	21
36852	2009-08-30	72	73	left	low	low	69	53	52	76	66	82	68	65	71	85	67	65	71	69	42	68	65	61	52	66	55	67	65	74	76	28	23	24	9	21	71	21	21
36852	2008-08-30	69	70	right	low	low	69	53	47	73	66	76	68	65	71	78	67	65	71	69	42	58	65	64	47	66	35	67	65	74	73	28	23	24	9	21	71	21	21
36852	2007-08-30	71	70	left	low	low	61	68	67	73	66	73	68	63	62	72	71	70	71	59	42	71	65	74	72	57	65	70	70	74	73	38	73	24	9	21	62	21	21
36852	2007-02-22	71	70	left	low	low	61	68	67	73	66	73	68	73	62	72	71	70	71	59	42	71	65	74	72	57	65	70	70	74	73	38	73	24	9	13	62	5	13
43158	2016-06-09	67	67	left	medium	medium	70	49	63	69	54	66	71	69	70	69	57	60	67	65	59	74	64	85	73	68	82	62	59	59	61	68	68	67	13	14	13	7	9
43158	2016-05-12	67	67	left	medium	medium	70	49	63	69	54	66	71	69	70	69	57	60	67	65	59	74	64	85	73	68	82	62	59	59	61	68	68	67	13	14	13	7	9
43158	2016-04-14	67	67	left	medium	medium	70	49	63	69	54	66	71	69	70	69	57	60	67	65	59	74	64	85	73	68	82	62	59	59	61	68	68	67	13	14	13	7	9
43158	2016-02-25	67	67	left	medium	medium	70	49	63	69	54	66	71	69	70	69	57	60	67	65	59	74	63	85	70	68	82	62	59	59	61	63	65	67	13	14	13	7	9
43158	2015-10-30	67	67	left	medium	medium	70	49	63	69	54	66	71	69	70	69	57	60	67	65	59	74	63	85	70	68	82	62	59	59	61	63	65	67	13	14	13	7	9
43158	2015-09-21	67	67	left	medium	high	70	49	63	69	54	66	71	69	70	69	57	60	67	65	59	74	63	85	70	68	82	62	59	59	61	63	65	67	13	14	13	7	9
43158	2015-02-20	67	67	left	medium	high	69	48	62	68	53	65	70	68	69	68	62	65	67	64	59	73	63	85	69	67	81	61	58	58	60	62	64	66	12	13	12	6	8
43158	2014-11-14	67	67	left	medium	high	69	48	62	68	53	65	70	68	69	68	62	65	67	64	59	73	63	85	69	67	81	61	58	58	60	62	64	66	12	13	12	6	8
43158	2014-10-02	67	67	left	medium	high	67	48	58	67	53	67	70	76	69	68	68	69	67	64	59	73	63	85	71	67	81	61	58	58	60	62	64	66	12	13	12	6	8
43158	2014-09-18	67	67	left	medium	high	67	48	58	67	53	67	70	76	69	68	74	78	67	64	59	73	63	84	71	67	81	61	58	58	60	62	64	66	12	13	12	6	8
43158	2014-03-14	69	69	left	medium	high	67	48	58	67	53	69	70	76	69	70	78	81	72	66	59	82	63	84	71	72	81	67	58	58	60	63	67	68	12	13	12	6	8
43158	2014-02-14	69	69	left	medium	high	67	48	58	67	53	69	72	76	69	72	78	81	72	66	59	82	63	84	71	72	81	67	58	58	60	63	67	68	12	13	12	6	8
43158	2014-01-17	71	71	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	72	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2014-01-10	70	70	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	72	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-09-20	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	72	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-08-16	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-07-12	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-05-31	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-04-26	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-03-22	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-03-15	70	76	left	medium	high	74	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-03-08	70	76	left	medium	high	75	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2013-02-15	70	76	left	medium	high	75	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2012-08-31	71	76	left	high	medium	75	48	59	67	53	69	72	76	69	72	78	81	68	67	59	82	66	84	71	72	81	69	58	58	60	63	72	72	12	13	12	6	8
43158	2012-02-22	69	75	left	high	medium	73	48	56	71	66	68	71	72	67	72	73	75	67	69	62	81	66	82	72	68	77	64	68	62	60	60	68	68	12	13	12	6	8
43158	2011-08-30	66	70	left	high	medium	73	48	58	68	66	66	71	67	67	71	73	75	66	65	65	81	66	77	71	68	72	57	54	62	60	56	65	67	12	13	12	6	8
43158	2011-02-22	67	76	left	high	medium	71	59	59	65	68	65	71	67	67	71	62	72	64	64	66	81	64	74	65	65	71	61	62	68	60	59	59	67	12	13	12	6	8
43158	2010-08-30	69	76	left	high	medium	69	59	59	65	68	65	70	67	67	71	77	75	69	64	66	78	64	74	65	65	71	61	62	68	62	59	59	67	12	13	12	6	8
43158	2009-08-30	67	76	left	high	medium	69	58	56	64	68	62	70	63	66	69	77	75	69	61	66	77	64	74	62	65	71	63	62	68	59	56	57	67	9	20	66	20	20
43158	2008-08-30	67	83	left	high	medium	65	56	54	62	68	60	70	61	65	71	75	77	69	56	66	81	64	74	57	62	62	66	66	68	60	59	58	67	10	20	65	20	20
43158	2008-02-22	63	73	left	high	medium	65	56	54	62	68	60	70	61	65	59	68	69	69	56	66	65	64	66	57	62	62	59	58	68	60	59	58	67	10	20	65	20	20
43158	2007-08-30	63	73	left	high	medium	65	56	54	62	68	60	70	61	65	59	68	69	69	56	66	65	64	66	57	62	62	59	58	68	60	59	58	67	10	20	65	20	20
43158	2007-02-22	63	73	left	high	medium	65	56	54	62	68	60	70	61	65	59	68	69	69	56	66	65	64	66	57	62	62	59	58	68	60	59	58	67	10	20	65	20	20
39498	2015-09-21	71	71	left	medium	medium	78	67	70	75	73	64	79	80	77	73	45	52	56	62	72	82	65	78	75	78	56	69	63	71	67	64	61	55	6	15	10	12	13
39498	2015-08-14	70	70	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	56	61	72	81	65	78	75	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2015-07-03	70	70	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	56	61	72	81	65	78	75	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2015-06-12	70	70	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	56	61	72	81	65	78	75	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2015-02-27	70	70	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	56	61	72	81	65	78	75	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-11-14	70	70	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	54	61	72	81	65	78	75	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-10-02	70	70	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	54	61	72	81	65	78	75	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-09-18	69	69	left	medium	medium	77	66	69	74	72	63	78	79	76	72	45	52	54	61	72	81	65	74	73	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-09-12	69	71	left	medium	medium	77	66	69	74	72	63	86	86	76	72	52	55	54	61	72	81	65	74	73	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-05-16	69	71	left	medium	medium	77	66	69	74	72	63	86	86	76	72	52	55	54	61	72	81	65	74	73	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-04-11	69	71	left	medium	medium	77	66	69	74	72	63	86	86	76	72	52	55	54	61	72	81	65	74	73	77	55	68	62	70	66	63	60	54	5	14	9	11	12
39498	2014-04-04	69	71	left	medium	medium	77	66	65	72	72	63	86	86	75	71	42	42	46	61	60	81	48	74	68	77	55	68	62	70	66	60	60	54	5	14	9	11	12
39498	2014-03-21	69	71	left	medium	medium	77	66	65	72	72	63	86	86	75	71	42	42	46	61	60	81	48	74	68	77	55	68	62	70	66	60	60	54	5	14	9	11	12
39498	2014-03-14	69	71	left	medium	medium	77	66	65	73	72	63	86	86	76	71	34	34	45	61	62	81	48	74	68	79	55	68	62	70	66	60	62	54	5	14	9	11	12
39498	2014-01-31	70	76	left	medium	medium	77	66	65	73	72	63	86	86	76	73	34	34	45	61	62	81	48	74	68	79	55	68	62	70	66	60	62	54	5	14	9	11	12
39498	2013-09-20	70	76	left	medium	medium	77	66	65	73	72	63	86	86	76	73	34	34	45	61	62	81	48	74	68	79	55	68	62	70	66	60	62	54	5	14	9	11	12
39498	2013-08-16	72	76	left	medium	medium	79	70	65	78	76	65	86	86	80	75	34	34	45	66	62	81	48	75	69	79	55	71	59	74	70	60	65	55	5	14	9	11	12
39498	2013-02-15	72	76	left	medium	medium	79	70	65	78	76	65	86	86	80	75	34	34	45	66	62	81	48	75	69	79	55	71	59	74	70	60	65	55	5	14	9	11	12
39498	2012-08-31	74	78	left	medium	medium	81	70	65	80	76	65	86	86	82	77	34	34	45	66	62	83	48	75	69	80	55	71	59	79	70	60	65	55	5	14	9	11	12
39498	2012-02-22	72	74	left	medium	medium	77	67	65	76	74	65	86	86	79	75	37	44	42	66	56	79	45	72	69	80	55	71	59	75	65	47	62	52	5	14	9	11	12
39498	2011-08-30	72	74	left	medium	medium	74	67	65	76	74	67	86	86	79	75	55	51	59	69	65	79	53	72	70	80	52	67	59	75	65	49	64	59	5	14	9	11	12
39498	2011-02-22	70	72	left	medium	medium	67	62	65	74	67	69	79	75	75	74	55	60	62	62	62	78	55	65	67	77	57	67	59	74	64	47	62	57	5	14	9	11	12
39498	2010-08-30	70	77	left	medium	medium	63	62	63	74	66	68	77	73	69	72	53	59	57	62	62	85	55	64	67	77	51	66	66	69	64	54	59	56	5	14	9	11	12
39498	2009-08-30	68	77	left	medium	medium	63	62	60	74	66	67	77	71	69	70	53	59	57	58	62	85	55	63	67	74	48	61	60	69	62	21	49	56	4	23	69	23	23
39498	2009-02-22	68	74	left	medium	medium	65	62	60	75	66	67	77	72	70	72	52	57	57	55	62	80	55	60	67	75	27	61	60	69	62	21	29	56	14	23	70	23	23
39498	2008-08-30	70	74	left	medium	medium	64	62	61	75	66	70	77	72	70	71	68	67	57	63	62	86	55	60	71	78	27	61	60	69	62	21	29	56	14	23	70	23	23
39498	2007-08-30	65	67	left	medium	medium	63	52	58	72	66	62	77	62	64	63	57	64	57	63	62	67	55	66	71	63	53	69	67	69	62	49	47	56	14	23	64	23	23
39498	2007-02-22	62	67	left	medium	medium	63	52	58	69	66	53	77	62	64	58	57	64	57	63	62	67	55	66	71	63	43	69	67	69	62	49	47	56	14	8	64	5	11
38248	2009-02-22	69	74	right	\N	\N	61	36	78	69	\N	63	\N	48	73	69	47	53	\N	58	\N	65	\N	62	83	37	57	73	87	\N	90	64	76	\N	5	22	73	22	22
38248	2008-08-30	69	74	right	\N	\N	61	36	78	69	\N	63	\N	48	73	69	47	53	\N	58	\N	65	\N	62	83	37	57	73	87	\N	93	64	76	\N	5	22	73	22	22
38248	2007-08-30	72	73	right	\N	\N	58	54	76	68	\N	68	\N	53	71	78	51	56	\N	53	\N	64	\N	61	83	53	66	63	76	\N	88	63	73	\N	5	22	71	22	22
38248	2007-02-22	71	71	right	\N	\N	58	54	75	67	\N	69	\N	88	69	79	48	58	\N	54	\N	63	\N	64	84	53	67	63	76	\N	88	61	70	\N	5	7	69	7	10
178291	2016-03-24	64	64	right	medium	medium	63	65	68	66	63	63	46	62	61	68	37	32	54	61	47	70	33	47	75	67	63	54	73	68	63	32	48	39	14	9	16	6	15
178291	2015-09-21	64	64	right	medium	medium	63	65	68	66	63	63	46	62	61	68	37	37	54	61	47	70	33	57	75	67	63	54	73	68	63	32	48	39	14	9	16	6	15
178291	2015-07-03	64	64	right	medium	medium	62	65	67	65	62	62	45	61	61	65	42	47	54	61	46	70	42	58	75	66	62	53	72	67	62	31	47	38	13	8	15	5	14
178291	2015-04-10	64	64	right	medium	medium	62	65	67	65	62	62	45	61	61	65	42	47	54	61	46	70	42	58	75	66	62	53	72	67	62	31	47	38	13	8	15	5	14
178291	2015-03-20	65	65	right	medium	medium	63	66	67	66	63	63	45	61	63	66	45	51	56	63	56	72	42	61	76	67	67	53	72	67	62	31	47	43	13	8	15	5	14
178291	2015-02-27	65	65	right	medium	medium	63	66	67	66	63	62	45	61	63	65	45	54	57	65	56	72	42	67	76	67	70	53	72	67	62	31	47	43	13	8	15	5	14
178291	2014-12-12	65	65	right	medium	medium	63	66	67	65	63	62	45	61	63	65	45	54	57	65	60	72	42	74	76	67	70	53	72	68	62	34	47	45	13	8	15	5	14
178291	2014-10-10	65	65	right	medium	medium	57	65	67	65	46	62	45	61	63	65	45	54	57	65	60	72	42	74	76	67	70	53	72	68	62	34	47	45	13	8	15	5	14
178291	2014-09-18	65	65	right	medium	medium	57	65	67	65	46	62	45	61	63	65	45	54	57	60	60	72	42	74	76	67	70	53	72	70	62	34	47	45	13	8	15	5	14
178291	2014-07-25	66	66	right	medium	medium	57	67	68	68	46	62	45	61	63	65	45	59	57	60	60	73	42	77	76	69	70	53	73	71	62	34	47	45	13	8	15	5	14
178291	2013-12-27	66	66	right	medium	medium	57	67	68	68	46	62	45	61	63	65	45	59	57	60	60	73	42	77	76	69	70	53	73	71	62	34	47	45	13	8	15	5	14
178291	2013-11-01	67	67	right	medium	medium	57	67	68	68	46	62	45	61	63	65	50	59	57	65	60	73	42	81	76	69	70	53	73	71	62	34	47	45	13	8	15	5	14
178291	2013-09-20	67	67	right	medium	medium	57	67	68	68	46	62	45	61	63	65	50	59	57	65	60	73	42	81	76	69	70	53	73	71	62	34	47	45	13	8	15	5	14
178291	2013-02-15	67	67	right	medium	medium	57	67	68	68	46	62	45	61	63	65	50	61	57	65	60	73	51	81	76	69	70	53	73	71	62	34	47	45	13	8	15	5	14
178291	2012-08-31	66	66	right	medium	medium	57	67	68	68	46	62	45	61	63	65	50	63	57	65	56	73	54	79	76	69	70	53	73	68	62	34	47	45	13	8	15	5	14
178291	2012-02-22	68	68	right	medium	medium	57	67	67	68	46	67	45	61	63	69	55	65	57	65	56	73	54	79	76	69	65	53	73	68	62	34	47	45	13	8	15	5	14
178291	2011-08-30	67	67	right	medium	medium	57	67	67	68	46	64	45	61	63	67	55	65	57	65	55	73	54	79	76	69	65	53	73	68	62	34	58	54	13	8	15	5	14
178291	2010-08-30	66	69	right	medium	medium	57	67	65	68	46	56	45	61	63	64	61	64	58	63	71	73	58	75	74	69	65	63	73	68	62	34	58	54	13	8	15	5	14
178291	2009-08-30	65	69	right	medium	medium	56	67	65	66	46	56	45	61	61	64	59	62	58	63	71	73	58	75	74	69	65	71	72	68	67	34	58	54	7	20	61	20	20
178291	2008-08-30	59	63	right	medium	medium	51	57	65	56	46	57	45	51	53	62	56	64	58	61	71	71	58	75	74	58	58	57	57	68	55	24	28	54	7	20	53	20	20
178291	2007-08-30	54	54	right	medium	medium	51	54	67	56	46	48	45	48	53	52	45	46	58	53	71	61	58	67	74	53	49	57	57	68	55	24	20	54	7	20	53	20	20
178291	2007-02-22	54	54	right	medium	medium	51	54	67	56	46	48	45	48	53	52	45	46	58	53	71	61	58	67	74	53	49	57	57	68	55	24	20	54	7	20	53	20	20
46881	2014-11-07	64	64	right	medium	medium	43	39	58	64	44	55	52	62	57	64	61	54	62	62	49	67	66	84	73	65	67	66	45	57	49	58	63	56	15	5	9	9	7
46881	2014-09-18	64	64	right	medium	medium	43	39	58	64	44	55	52	62	57	64	61	54	62	62	49	67	66	84	73	65	67	66	45	57	49	58	63	56	15	5	9	9	7
46881	2014-04-18	64	64	right	medium	medium	43	39	58	64	44	55	52	62	57	64	61	59	62	62	49	67	66	80	81	65	67	66	45	57	49	58	63	56	15	5	9	9	7
46881	2014-03-14	65	65	right	medium	medium	43	39	61	64	44	55	52	62	59	66	58	55	62	62	49	67	76	80	81	65	67	66	45	57	49	62	63	58	15	5	9	9	7
46881	2014-02-14	65	65	right	medium	medium	43	31	57	64	44	55	41	30	59	66	58	55	62	62	49	55	76	80	81	58	67	66	45	57	49	62	63	58	15	5	9	9	7
46881	2014-01-10	65	66	right	medium	medium	43	31	57	64	44	55	41	30	59	66	58	55	62	62	49	55	76	80	81	58	67	66	45	57	49	62	63	58	15	5	9	9	7
46881	2013-11-22	65	68	right	medium	medium	43	31	57	64	44	55	41	30	59	66	58	55	62	62	49	55	76	80	81	58	67	66	45	57	49	62	63	58	15	5	9	9	7
46881	2013-11-15	65	68	right	medium	medium	43	31	57	64	44	55	41	30	59	66	58	57	62	62	49	55	76	80	81	58	67	66	45	57	49	62	63	58	15	5	9	9	7
46881	2013-09-20	66	68	right	medium	medium	43	31	57	67	44	55	41	30	59	66	63	60	62	64	49	55	76	85	81	58	67	66	45	60	49	62	67	60	15	5	9	9	7
46881	2013-04-05	66	68	right	medium	medium	43	31	57	67	44	55	41	30	59	66	63	60	62	64	49	51	76	85	81	50	67	66	45	60	49	62	67	60	15	5	9	9	7
46881	2013-02-15	66	68	right	medium	medium	43	31	49	70	44	55	41	30	49	67	63	60	62	64	49	51	76	83	79	50	67	66	45	63	49	67	68	62	15	5	9	9	7
46881	2012-08-31	63	65	right	medium	medium	43	31	49	67	44	45	41	30	49	65	60	58	62	62	47	51	71	84	80	50	64	52	45	62	49	65	64	59	15	5	9	9	7
46881	2011-08-30	63	65	right	medium	medium	43	31	49	67	44	45	41	30	49	65	60	58	62	62	47	51	71	84	80	50	64	52	45	62	49	65	64	59	15	5	9	9	7
46881	2011-02-22	63	71	right	medium	medium	44	32	50	68	45	46	42	31	50	66	59	55	58	63	80	52	74	74	78	51	65	53	46	63	50	66	65	60	15	5	9	9	7
46881	2010-08-30	62	71	right	medium	medium	40	19	50	65	39	22	26	31	48	64	59	55	58	63	80	48	74	74	78	51	65	53	46	63	50	66	65	60	15	5	9	9	7
46881	2009-08-30	64	71	right	medium	medium	40	20	50	65	39	22	26	31	48	64	59	55	58	63	80	48	74	74	78	51	65	65	69	63	62	66	65	60	16	20	48	20	20
46881	2009-02-22	64	71	right	medium	medium	40	20	50	65	39	22	26	31	48	64	59	55	58	63	80	48	74	74	78	51	65	65	69	63	62	66	65	60	16	20	48	20	20
46881	2008-08-30	64	67	right	medium	medium	40	20	50	65	39	22	26	31	48	64	59	55	58	63	80	48	74	74	78	51	65	65	69	63	62	66	65	60	16	20	48	20	20
46881	2007-08-30	62	67	right	medium	medium	40	20	50	65	39	22	26	31	48	64	59	55	58	63	80	48	74	74	78	51	65	65	69	63	62	66	65	60	16	20	48	20	20
46881	2007-02-22	50	60	right	medium	medium	40	19	50	54	39	22	26	49	38	53	54	51	58	50	80	48	74	61	62	51	65	65	69	63	49	39	45	60	16	19	38	17	12
104411	2016-03-10	68	68	right	low	high	53	39	69	67	64	54	57	54	64	64	58	53	60	67	63	71	64	73	70	65	69	75	47	57	57	64	69	67	13	14	16	9	12
104411	2016-01-28	68	68	right	low	high	53	39	69	67	64	54	57	54	64	64	58	53	60	67	63	71	64	73	68	65	69	75	47	57	57	64	69	67	13	14	16	9	12
104411	2015-09-25	68	69	right	low	high	53	39	69	67	64	54	57	54	64	64	58	53	60	67	63	71	64	73	68	65	69	75	47	57	57	64	69	67	13	14	16	9	12
104411	2015-09-21	68	69	right	low	high	53	39	69	67	64	54	57	54	64	64	58	57	60	67	63	71	64	73	68	65	69	75	47	57	57	64	69	67	13	14	16	9	12
104411	2015-07-03	66	67	right	low	high	52	38	68	66	63	53	56	53	63	63	58	57	60	66	63	70	64	73	68	64	68	74	46	56	56	63	68	66	12	13	15	8	11
104411	2015-03-20	66	67	right	low	high	52	38	68	66	63	53	56	53	63	63	58	57	60	66	63	70	64	73	68	64	68	74	46	56	56	63	68	66	12	13	15	8	11
104411	2015-02-27	67	68	right	low	high	52	38	68	66	63	53	56	53	63	63	58	57	60	66	63	70	64	73	68	64	68	74	46	60	56	63	68	66	12	13	15	8	11
104411	2015-02-13	67	68	right	low	high	56	38	67	68	65	56	51	53	64	63	58	57	60	66	61	70	67	73	68	65	68	76	46	61	54	64	68	66	12	13	15	8	11
104411	2014-11-07	68	69	right	low	high	56	38	67	68	65	56	51	53	66	63	61	58	60	67	61	70	67	73	68	65	68	76	46	61	54	64	69	66	12	13	15	8	11
104411	2014-10-10	68	69	right	low	high	56	38	67	68	65	56	51	53	66	63	61	58	60	67	61	70	67	73	68	65	68	76	46	61	54	64	69	66	12	13	15	8	11
104411	2014-09-18	68	70	right	low	high	56	38	67	68	65	56	51	53	66	63	63	54	60	67	59	71	67	73	68	66	68	76	46	66	54	64	70	66	12	13	15	8	11
104411	2014-01-17	68	70	right	low	high	56	38	67	68	65	56	51	53	66	63	63	54	60	67	59	71	67	73	68	66	68	76	46	66	54	64	70	66	12	13	15	8	11
104411	2013-09-20	69	70	right	low	high	56	38	67	69	65	56	51	53	66	63	66	54	68	72	59	71	73	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-08-16	69	70	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-07-05	69	70	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-06-07	69	70	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-05-31	69	72	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-05-17	69	72	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-02-22	69	72	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2013-02-15	69	72	right	low	high	56	38	67	69	65	56	51	53	66	63	66	62	68	72	59	71	72	76	68	66	68	76	46	66	54	64	71	68	12	13	15	8	11
104411	2012-08-31	70	74	right	low	high	56	38	67	71	65	56	51	53	66	67	66	64	68	74	67	71	73	76	68	66	69	76	46	66	54	67	71	68	12	13	15	8	11
104411	2011-08-30	70	73	right	low	high	56	38	67	71	65	56	51	53	66	67	66	64	68	74	67	71	73	76	68	66	69	76	46	66	54	67	71	68	12	13	15	8	11
104411	2011-02-22	65	69	right	low	high	53	33	64	64	41	53	45	46	62	63	63	68	64	67	65	57	66	71	67	49	66	66	48	64	47	64	66	65	12	13	15	8	11
104411	2010-08-30	65	69	right	low	high	53	33	64	64	41	53	45	46	62	63	63	68	64	67	65	57	66	71	67	49	66	66	48	64	47	64	66	65	12	13	15	8	11
104411	2010-02-22	65	72	right	low	high	53	33	64	64	41	53	45	46	62	63	63	68	64	67	65	57	66	71	67	49	66	62	63	64	67	64	66	65	1	21	62	21	21
104411	2009-08-30	62	72	right	low	high	49	33	58	60	41	53	45	46	58	63	68	65	64	67	65	57	66	67	64	49	66	62	64	64	60	62	57	65	1	21	58	21	21
104411	2008-08-30	55	72	right	low	high	52	38	35	52	41	28	45	46	50	47	68	65	64	68	65	31	66	65	64	32	66	54	47	64	44	53	54	65	1	21	50	21	21
104411	2007-02-22	55	72	right	low	high	52	38	35	52	41	28	45	46	50	47	68	65	64	68	65	31	66	65	64	32	66	54	47	64	44	53	54	65	1	21	50	21	21
131404	2015-09-21	66	66	right	low	medium	33	32	68	58	33	36	44	49	55	53	33	32	41	63	43	56	56	60	78	42	66	70	29	43	45	66	67	63	9	16	8	16	11
131404	2012-08-31	66	66	right	low	medium	33	32	68	58	33	36	44	49	55	53	33	32	41	63	43	56	56	60	78	42	66	70	29	43	45	66	67	63	9	16	8	16	11
131404	2012-02-22	66	66	right	low	medium	33	32	68	58	33	36	44	49	55	53	33	32	41	63	43	56	56	60	78	42	66	70	29	43	45	66	67	63	9	16	8	16	11
131404	2011-08-30	67	69	right	low	medium	49	32	71	58	33	46	44	49	55	53	40	48	48	63	43	56	63	68	83	42	71	72	29	48	45	65	66	63	9	16	8	16	11
131404	2011-02-22	64	67	right	low	medium	49	28	66	59	33	42	44	49	54	57	52	60	54	57	70	62	62	67	72	29	65	74	44	64	39	64	65	62	9	16	8	16	11
131404	2010-08-30	64	67	right	low	medium	49	28	66	59	33	42	44	49	54	57	52	60	54	57	70	62	62	67	72	29	65	74	64	64	39	64	65	62	9	16	8	16	11
131404	2010-02-22	64	67	right	low	medium	49	28	65	59	33	42	44	49	54	57	52	60	54	57	70	62	62	67	72	29	65	67	62	64	64	64	65	62	9	25	54	25	25
131404	2009-08-30	63	67	right	low	medium	50	28	62	56	33	42	44	49	51	57	52	60	54	57	70	62	62	67	72	29	65	67	62	64	64	62	63	62	9	25	51	25	25
131404	2009-02-22	62	67	right	low	medium	48	28	62	54	33	42	44	49	47	52	52	60	54	57	70	58	62	67	72	29	65	67	62	64	64	62	64	62	9	25	47	25	25
131404	2008-08-30	59	64	right	low	medium	48	28	60	49	33	40	44	49	32	50	47	54	54	54	70	33	62	65	72	29	56	57	53	64	54	57	62	62	9	25	32	25	25
131404	2007-02-22	59	64	right	low	medium	48	28	60	49	33	40	44	49	32	50	47	54	54	54	70	33	62	65	72	29	56	57	53	64	54	57	62	62	9	25	32	25	25
37937	2016-04-14	70	70	right	medium	medium	12	12	13	27	14	14	9	14	26	30	56	48	37	65	53	13	61	37	85	13	45	23	14	39	29	11	12	15	74	68	72	69	71
37937	2015-11-26	70	70	right	medium	medium	12	12	13	27	14	14	9	14	26	30	56	48	37	65	53	13	61	37	85	13	45	23	14	39	29	11	12	15	74	68	72	69	71
37937	2015-09-21	70	71	right	medium	medium	12	12	13	27	14	14	9	14	26	30	56	48	37	65	53	13	61	37	85	13	45	23	14	39	29	11	12	15	74	68	72	69	71
37937	2015-04-17	69	70	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	64	53	25	61	37	79	25	44	22	25	25	28	25	25	25	73	67	71	68	70
37937	2015-04-10	68	69	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	64	53	25	61	37	79	25	44	22	25	25	28	25	25	25	71	65	71	67	70
37937	2015-02-20	68	70	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	64	53	25	61	37	79	25	44	22	25	25	28	25	25	25	71	65	71	65	72
37937	2014-10-24	68	70	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	64	53	25	61	37	79	25	44	22	25	25	28	25	25	25	69	65	71	65	75
37937	2014-09-18	68	70	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	79	25	44	22	25	25	28	25	25	25	69	65	72	65	76
37937	2014-04-25	67	70	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	87	25	44	22	25	25	28	25	25	25	68	62	70	65	74
37937	2014-04-04	64	65	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	87	25	44	22	25	25	28	25	25	25	66	64	61	63	66
37937	2014-02-28	64	68	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	87	25	44	22	25	25	28	25	25	25	66	64	61	63	66
37937	2013-09-20	63	68	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	85	25	44	22	25	25	28	25	25	25	66	62	61	61	64
37937	2012-02-22	63	68	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	85	25	44	22	25	25	28	25	25	25	66	62	61	61	64
37937	2011-02-22	63	68	right	medium	medium	25	25	25	26	25	25	25	25	25	29	56	48	37	56	53	25	61	37	85	25	44	22	25	25	28	25	25	25	66	62	61	61	64
37937	2010-08-30	65	68	right	medium	medium	25	25	25	26	25	25	25	25	25	39	56	48	37	56	53	25	61	37	85	25	44	22	25	25	28	21	25	25	66	66	63	62	67
37937	2010-02-22	65	68	right	medium	medium	22	22	22	26	25	22	25	25	63	39	56	48	37	56	53	22	61	37	85	22	44	55	64	25	41	21	22	25	66	66	63	62	67
37937	2009-08-30	64	68	right	medium	medium	22	22	22	26	25	22	25	25	62	39	56	48	37	56	53	22	61	43	89	22	44	55	64	25	41	21	22	25	64	65	62	61	66
37937	2009-02-22	62	68	right	medium	medium	22	22	22	26	25	22	25	11	60	22	56	48	37	56	53	22	61	43	89	22	44	55	30	25	41	21	22	25	62	63	60	59	64
37937	2008-08-30	60	68	right	medium	medium	22	22	22	26	25	22	25	11	61	22	44	42	37	56	53	22	61	43	89	22	44	55	30	25	41	21	22	25	59	62	61	57	62
37937	2007-08-30	58	68	right	medium	medium	22	22	22	26	25	22	25	11	57	22	44	44	37	56	53	22	61	43	49	22	44	55	30	25	41	21	22	25	57	60	57	55	62
37937	2007-02-22	55	66	right	medium	medium	11	11	12	26	25	13	25	41	54	11	44	44	37	56	53	12	61	43	49	5	44	55	30	25	41	21	11	25	54	57	54	52	59
38249	2014-04-04	63	63	right	medium	medium	59	54	49	69	64	63	38	63	63	62	61	61	65	65	67	63	68	67	68	62	60	66	60	64	64	57	54	60	14	14	5	15	9
38249	2013-12-06	64	64	right	medium	medium	60	54	49	69	64	66	38	63	66	65	65	65	68	70	67	63	71	70	68	62	60	66	60	64	64	57	54	61	14	14	5	15	9
38249	2013-09-20	65	65	right	medium	medium	60	54	49	69	64	66	38	63	66	69	65	65	68	70	67	63	71	70	68	62	60	66	60	64	64	59	54	61	14	14	5	15	9
38249	2013-02-15	65	65	right	medium	medium	60	54	49	69	64	66	38	63	66	69	65	65	68	70	67	63	71	74	68	62	60	66	60	64	64	59	54	61	14	14	5	15	9
38249	2012-08-31	67	67	right	medium	high	63	64	52	66	66	66	63	63	64	69	65	67	70	70	68	63	69	73	64	66	60	33	66	68	64	39	43	41	14	14	5	15	9
38249	2012-02-22	67	67	right	medium	high	63	64	52	66	66	66	63	63	64	69	65	67	70	70	68	63	69	76	60	66	60	33	66	68	64	33	43	37	14	14	5	15	9
38249	2011-08-30	67	67	right	medium	medium	63	64	52	66	66	66	63	63	64	69	65	67	70	70	68	63	69	76	60	66	58	33	66	68	64	33	43	37	14	14	5	15	9
38249	2011-02-22	66	68	right	medium	medium	63	64	52	66	66	66	63	63	64	69	71	72	71	70	58	63	67	72	60	66	58	33	66	68	64	33	43	37	14	14	5	15	9
38249	2010-08-30	66	68	right	medium	medium	63	66	42	66	66	68	61	63	64	71	71	72	73	70	58	63	67	74	60	68	58	59	66	68	64	33	43	37	14	14	5	15	9
38249	2009-08-30	66	68	right	medium	medium	63	66	42	66	66	68	61	63	64	71	71	72	73	70	58	63	67	74	60	68	58	61	63	68	66	33	43	37	5	23	64	23	23
38249	2009-02-22	66	68	right	medium	medium	63	66	42	66	66	68	61	63	64	71	71	72	73	70	58	63	67	74	60	68	58	61	63	68	66	33	43	37	5	23	64	23	23
38249	2008-08-30	66	68	right	medium	medium	63	66	42	66	66	68	61	63	64	71	71	72	73	70	58	63	67	74	60	68	58	61	63	68	66	33	43	37	5	23	64	23	23
38249	2007-08-30	71	72	right	medium	medium	63	69	42	68	66	73	61	63	66	74	71	72	73	70	58	63	67	71	60	68	60	61	63	68	66	33	43	37	5	23	66	23	23
38249	2007-02-22	69	71	right	medium	medium	67	72	37	65	66	73	61	63	64	70	70	72	73	70	58	64	67	68	59	71	53	61	63	68	63	39	34	37	5	12	64	13	7
34480	2012-02-22	69	69	right	medium	medium	12	14	13	38	14	12	11	13	37	34	58	47	45	62	35	25	65	55	82	12	17	16	15	29	29	11	11	12	67	69	73	71	69
34480	2011-08-30	69	69	right	medium	medium	12	14	13	38	14	12	11	13	37	34	58	57	45	62	35	25	65	55	82	12	17	16	15	29	21	11	11	12	67	69	73	71	69
34480	2011-02-22	69	70	right	medium	medium	12	14	13	38	14	12	11	13	37	34	59	58	56	62	76	25	63	54	79	12	63	21	15	49	21	11	11	12	67	69	73	71	69
34480	2010-08-30	69	69	right	medium	medium	29	9	13	38	9	12	11	8	37	34	59	58	56	62	76	25	63	54	79	7	63	21	15	49	21	11	11	12	67	69	73	71	69
34480	2010-02-22	67	69	right	medium	medium	29	36	25	38	9	23	11	23	73	39	60	58	56	62	76	25	63	55	79	23	63	52	13	49	44	23	31	12	67	67	73	65	70
34480	2009-02-22	67	69	right	medium	medium	29	36	25	52	9	23	11	23	73	54	60	58	56	62	76	25	63	55	79	23	63	52	13	49	44	39	31	12	67	67	73	65	70
34480	2008-08-30	67	70	right	medium	medium	29	36	25	31	9	23	11	23	73	34	60	58	56	62	76	25	63	55	79	23	63	52	13	49	44	39	31	12	67	67	73	65	70
34480	2007-08-30	67	70	right	medium	medium	29	36	25	31	9	23	11	23	73	34	60	58	56	62	76	25	63	57	79	23	63	52	13	49	44	39	31	12	59	67	73	63	71
34480	2007-02-22	67	70	right	medium	medium	29	36	25	31	9	23	11	44	73	34	60	58	56	62	76	25	63	57	79	12	63	52	13	49	44	39	31	12	59	67	73	63	71
69629	2014-11-14	61	65	right	low	low	50	64	60	58	64	62	60	58	52	61	51	57	55	64	57	61	51	47	67	59	41	21	61	58	62	21	35	32	15	10	5	14	11
69629	2014-10-10	62	68	right	low	low	50	65	60	58	64	63	60	58	52	62	51	57	55	66	57	62	51	47	67	60	41	21	62	58	62	21	35	32	15	10	5	14	11
69629	2014-09-18	65	67	right	low	low	53	68	64	61	66	65	63	60	56	66	53	59	57	69	59	65	52	46	67	63	44	24	66	60	66	27	37	36	15	10	5	14	11
69629	2011-02-22	65	67	right	low	low	53	68	64	61	66	65	63	60	56	66	53	59	57	69	59	65	52	46	67	63	44	24	66	60	66	27	37	36	15	10	5	14	11
69629	2010-08-30	65	67	right	low	low	53	68	64	61	66	65	63	60	56	66	53	59	57	69	59	65	52	46	67	63	44	24	66	60	66	27	37	36	15	10	5	14	11
69629	2010-02-22	68	80	right	low	low	53	71	64	66	66	69	63	55	56	69	75	59	57	69	59	63	52	65	67	58	44	46	68	60	60	27	37	36	7	23	56	23	23
69629	2009-08-30	67	80	right	low	low	53	68	64	66	66	69	63	55	56	68	75	59	57	69	59	63	52	65	67	58	44	46	68	60	60	27	37	36	7	23	56	23	23
69629	2009-02-22	59	88	right	low	low	43	61	43	56	66	66	63	35	46	61	69	65	57	61	59	60	52	68	58	53	54	46	63	60	50	27	37	36	7	23	46	23	23
69629	2007-02-22	59	88	right	low	low	43	61	43	56	66	66	63	35	46	61	69	65	57	61	59	60	52	68	58	53	54	46	63	60	50	27	37	36	7	23	46	23	23
38186	2015-02-27	62	62	right	medium	high	37	29	62	53	22	27	35	30	56	47	48	53	62	56	49	43	46	72	86	24	71	55	33	52	37	62	61	63	5	5	13	12	10
38186	2014-09-18	62	62	right	medium	high	37	29	62	53	22	27	35	30	56	47	48	58	62	56	49	43	46	72	86	24	71	55	33	52	37	62	61	63	5	5	13	12	10
38186	2013-06-21	62	62	right	medium	high	37	29	62	53	22	27	35	30	56	47	48	58	62	56	49	43	46	72	86	24	71	55	33	52	37	62	61	63	5	5	13	12	10
38186	2013-02-15	62	62	right	medium	high	37	29	62	53	22	27	35	30	56	47	48	58	62	56	49	43	46	72	86	24	71	55	33	52	37	62	61	63	5	5	13	12	10
38186	2012-08-31	62	62	right	medium	high	37	29	62	53	22	27	35	30	56	47	48	58	62	56	49	43	46	72	86	24	71	55	33	52	37	62	61	63	5	5	13	12	10
38186	2011-02-22	62	62	right	medium	high	37	29	62	53	22	27	35	30	56	47	48	58	62	56	49	43	46	72	86	24	71	55	33	52	37	62	61	63	5	5	13	12	10
38186	2010-08-30	63	62	right	medium	high	41	29	58	53	22	27	35	30	51	47	58	61	53	56	49	65	60	72	78	24	67	66	33	52	37	63	66	62	5	5	13	12	10
38186	2009-08-30	63	62	right	medium	high	41	29	58	53	22	27	35	30	51	47	58	61	53	56	49	65	60	72	78	24	67	52	53	52	59	63	66	62	8	20	51	20	20
38186	2009-02-22	63	74	right	medium	high	41	29	58	50	22	20	35	30	50	47	65	67	53	64	49	71	60	71	78	20	75	51	52	52	59	70	71	62	8	20	50	20	20
38186	2007-08-30	63	74	right	medium	high	41	29	58	50	22	20	35	30	50	47	65	67	53	64	49	71	60	71	78	20	75	51	52	52	59	70	71	62	8	20	50	20	20
38186	2007-02-22	63	74	right	medium	high	41	29	58	50	22	17	35	59	50	47	65	67	53	64	49	71	60	71	78	14	75	51	52	52	59	70	71	62	8	6	50	9	9
149150	2016-04-14	72	72	right	high	high	67	39	65	69	49	71	59	59	64	68	83	88	91	71	77	62	94	85	63	54	73	64	62	59	49	69	71	73	16	8	11	12	6
149150	2016-01-28	72	72	right	high	high	67	39	65	69	49	71	59	59	64	68	83	88	91	71	77	62	94	85	63	54	73	64	62	59	49	69	71	73	16	8	11	12	6
149150	2015-09-21	72	73	right	high	high	67	39	65	69	49	71	59	59	64	68	83	88	91	71	77	62	94	85	63	54	73	64	62	59	49	69	71	73	16	8	11	12	6
149150	2015-03-13	70	71	right	high	high	67	38	66	68	48	71	58	58	64	68	81	86	91	71	77	61	93	85	66	53	74	66	61	58	48	66	68	69	15	7	10	11	5
149150	2014-11-28	69	70	right	high	high	67	38	66	68	48	66	58	58	64	66	81	86	91	70	77	61	93	78	66	53	74	64	53	50	48	63	66	68	15	7	10	11	5
149150	2014-10-24	69	70	right	high	medium	67	38	66	68	48	66	58	58	64	66	81	86	91	70	77	61	93	78	66	53	74	64	53	50	48	63	66	68	15	7	10	11	5
149150	2014-09-18	69	72	right	high	medium	67	38	66	68	48	66	58	58	64	66	81	86	91	70	77	61	93	78	66	53	74	64	53	50	48	63	66	68	15	7	10	11	5
149150	2013-12-13	69	72	right	high	medium	67	38	66	68	48	66	58	58	64	66	81	86	91	70	77	61	93	78	66	53	74	64	53	50	48	63	66	68	15	7	10	11	5
149150	2013-11-15	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	81	86	91	66	77	61	93	78	66	53	73	62	53	50	48	63	66	68	15	7	10	11	5
149150	2013-10-04	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	81	86	91	66	77	61	93	78	66	53	73	62	53	50	48	63	66	68	15	7	10	11	5
149150	2013-09-20	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	81	86	91	66	77	61	93	78	66	53	73	62	53	50	48	63	66	68	15	7	10	11	5
149150	2013-03-22	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	81	81	91	66	77	61	93	78	66	53	73	62	53	50	48	63	66	68	15	7	10	11	5
149150	2013-03-15	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	81	81	91	66	77	61	93	78	66	53	73	62	53	50	48	63	66	68	15	7	10	11	5
149150	2013-02-15	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	81	81	91	66	77	61	93	78	66	53	73	62	53	50	48	63	66	68	15	7	10	11	5
149150	2012-08-31	68	72	right	high	medium	67	38	66	66	48	63	58	58	62	66	80	81	91	68	76	61	93	78	62	53	73	62	53	61	48	64	66	68	15	7	10	11	5
149150	2012-02-22	69	72	right	high	medium	67	38	63	66	49	63	58	58	57	66	81	83	92	73	76	61	94	80	55	45	74	62	53	58	48	66	68	69	15	7	10	11	5
149150	2011-08-30	68	72	right	high	medium	67	34	62	62	49	65	59	55	57	67	81	83	91	72	76	62	93	80	53	45	76	59	52	57	50	66	67	69	15	7	10	11	5
149150	2011-02-22	65	72	right	high	medium	67	37	54	62	49	62	59	55	57	65	73	80	83	72	55	62	78	76	60	45	68	57	52	62	50	63	65	66	15	7	10	11	5
149150	2010-08-30	65	72	right	high	medium	67	37	54	62	49	62	59	55	57	64	78	80	77	72	55	62	75	67	57	45	68	62	53	62	50	63	65	66	15	7	10	11	5
149150	2009-08-30	60	67	right	high	medium	51	33	45	53	49	53	59	37	46	58	75	78	77	72	55	54	75	67	57	39	64	45	52	62	56	62	60	66	17	21	46	21	21
149150	2007-02-22	60	67	right	high	medium	51	33	45	53	49	53	59	37	46	58	75	78	77	72	55	54	75	67	57	39	64	45	52	62	56	62	60	66	17	21	46	21	21
37047	2011-02-22	64	65	right	\N	\N	51	39	63	61	36	44	38	49	56	51	65	67	59	62	68	65	67	73	64	47	48	71	42	66	62	69	68	66	6	7	12	8	7
37047	2010-08-30	64	65	right	\N	\N	51	39	63	61	36	44	38	49	56	51	65	67	59	62	68	65	67	73	64	47	48	71	42	66	62	71	68	66	6	7	12	8	7
37047	2009-08-30	64	68	right	\N	\N	51	39	63	61	36	44	38	49	56	51	65	67	59	62	68	65	67	73	64	47	48	69	71	66	73	71	68	66	9	20	56	20	20
37047	2009-02-22	64	67	right	\N	\N	54	39	60	61	36	44	38	67	53	48	67	69	59	63	68	65	67	73	64	56	69	64	66	66	71	66	65	66	9	20	53	20	20
37047	2008-08-30	64	64	right	\N	\N	54	39	60	61	36	44	38	67	53	48	67	69	59	63	68	65	67	73	64	56	69	64	66	66	71	66	65	66	9	20	53	20	20
37047	2007-08-30	59	63	right	\N	\N	44	39	56	33	36	44	38	67	33	44	67	69	59	57	68	21	67	73	71	66	69	61	56	66	68	66	64	66	9	20	33	20	20
37047	2007-02-22	63	63	left	\N	\N	44	39	56	33	36	44	38	68	33	44	67	69	59	57	68	21	67	73	71	66	69	61	56	66	68	66	64	66	9	15	33	5	11
166675	2016-03-24	71	71	left	medium	high	66	54	63	66	52	72	52	48	62	71	86	88	81	69	78	64	82	73	71	53	72	67	64	59	48	71	71	72	14	16	6	6	8
166675	2016-03-17	71	71	left	medium	high	66	54	63	66	52	72	52	48	62	71	86	88	81	69	83	64	82	73	71	53	72	67	64	59	48	71	71	72	14	16	6	6	8
166675	2015-11-26	72	72	left	medium	high	66	54	63	66	52	73	52	48	62	71	86	88	81	70	83	66	85	75	71	53	74	68	64	59	48	71	72	74	14	16	6	6	8
166675	2015-10-23	73	74	left	medium	high	66	54	63	66	52	74	52	48	62	72	86	88	81	71	83	66	85	75	71	53	74	68	64	59	48	73	73	76	14	16	6	6	8
166675	2015-09-21	74	75	left	medium	high	66	54	63	66	52	74	52	48	62	72	88	90	83	72	86	66	87	80	73	53	79	69	64	59	48	73	73	76	14	16	6	6	8
166675	2015-04-17	71	72	left	medium	medium	65	53	62	65	51	73	51	47	61	71	93	91	85	71	87	65	91	83	71	52	78	68	63	58	47	69	70	72	13	15	5	5	7
166675	2015-03-06	72	75	left	medium	medium	65	53	62	65	51	73	51	47	61	71	93	91	85	74	87	65	91	85	73	52	78	68	63	58	47	69	70	72	13	15	5	5	7
166675	2014-09-18	72	73	left	medium	medium	65	53	62	65	51	73	51	47	61	71	93	91	85	74	87	65	91	85	73	52	78	68	63	58	47	69	70	72	13	15	5	5	7
166675	2014-05-09	72	73	left	medium	medium	65	53	62	65	51	73	51	47	61	71	93	91	85	74	87	65	88	83	73	52	78	68	63	58	47	69	70	72	13	15	5	5	7
166675	2014-01-03	71	73	left	medium	medium	63	53	62	63	51	73	51	47	61	71	93	91	85	72	87	65	88	83	73	52	77	66	63	58	47	68	69	71	13	15	5	5	7
166675	2013-11-01	70	73	left	medium	medium	63	53	60	63	51	73	51	47	61	71	93	91	85	71	87	65	88	83	73	52	76	64	62	58	47	65	69	71	13	15	5	5	7
166675	2013-09-20	69	73	left	medium	medium	62	52	59	63	45	73	51	47	61	71	93	91	85	71	82	65	87	83	73	52	76	63	60	57	41	64	68	71	13	15	5	5	7
166675	2013-03-01	69	73	left	medium	medium	62	52	59	63	45	73	51	47	61	71	93	91	85	71	82	65	87	83	73	52	76	63	60	57	41	64	68	71	13	15	5	5	7
166675	2013-02-15	69	73	left	medium	medium	62	52	59	63	45	73	51	47	61	71	93	91	85	71	82	65	87	83	73	52	73	65	60	57	41	64	68	71	13	15	5	5	7
166675	2012-08-31	68	73	left	medium	medium	62	52	58	63	45	71	51	47	61	70	93	91	85	71	82	65	86	81	70	52	73	58	60	63	41	61	66	71	13	15	5	5	7
166675	2012-02-22	69	74	left	medium	medium	62	52	57	63	45	66	51	47	59	70	93	91	85	70	78	65	86	81	70	52	71	65	58	64	41	66	68	69	13	15	5	5	7
166675	2011-08-30	69	74	left	medium	medium	67	52	57	63	45	66	51	47	59	70	92	93	85	70	78	65	84	81	70	52	69	65	58	64	41	64	67	69	13	15	5	5	7
166675	2011-02-22	67	75	left	medium	medium	66	51	57	63	45	62	51	47	59	64	87	88	75	70	65	65	75	78	62	52	69	65	52	64	41	64	67	69	13	15	5	5	7
166675	2010-08-30	63	69	left	medium	medium	61	56	57	62	46	60	51	49	57	62	80	81	73	67	56	58	75	72	53	54	65	59	57	55	41	57	60	59	13	15	5	5	7
166675	2009-08-30	51	56	right	medium	medium	27	47	52	39	46	51	51	49	27	45	59	61	73	61	56	50	75	59	60	46	59	26	27	55	33	22	22	59	1	22	27	22	22
166675	2007-02-22	51	56	right	medium	medium	27	47	52	39	46	51	51	49	27	45	59	61	73	61	56	50	75	59	60	46	59	26	27	55	33	22	22	59	1	22	27	22	22
42812	2009-02-22	62	73	left	\N	\N	57	51	67	62	\N	46	\N	60	65	56	42	52	\N	56	\N	69	\N	62	72	58	67	71	73	\N	78	57	64	\N	14	22	65	22	22
42812	2008-08-30	64	73	left	\N	\N	57	42	72	62	\N	51	\N	60	65	56	51	56	\N	60	\N	71	\N	67	73	58	68	71	73	\N	78	62	64	\N	14	22	65	22	22
42812	2007-08-30	64	73	left	\N	\N	57	42	72	62	\N	57	\N	50	65	46	56	61	\N	60	\N	67	\N	82	77	58	61	66	63	\N	48	72	55	\N	14	22	65	22	22
42812	2007-02-22	64	73	left	\N	\N	57	42	72	62	\N	57	\N	50	65	46	56	61	\N	60	\N	67	\N	82	77	58	61	66	63	\N	48	72	55	\N	14	22	65	22	22
37025	2012-02-22	64	64	right	medium	medium	57	71	54	58	54	56	48	57	53	52	70	76	71	70	68	67	74	72	68	60	56	43	68	57	62	23	34	39	6	12	13	7	5
37025	2011-08-30	64	64	right	medium	medium	57	71	54	58	54	56	48	57	53	52	70	76	71	70	68	67	74	72	68	60	56	43	68	57	62	23	34	39	6	12	13	7	5
37025	2011-02-22	63	65	right	medium	medium	59	68	55	59	54	57	49	57	54	52	69	74	67	70	59	69	68	72	61	61	64	48	66	57	62	43	44	49	6	12	13	7	5
37025	2010-08-30	63	65	right	medium	medium	59	65	55	59	54	57	49	57	54	52	69	74	67	70	59	69	68	72	61	61	64	48	66	57	62	43	44	49	6	12	13	7	5
37025	2010-02-22	63	65	right	medium	medium	59	65	55	59	54	57	49	57	54	52	69	74	67	70	59	69	68	72	61	61	64	59	57	57	63	43	44	49	4	20	54	20	20
37025	2009-08-30	63	65	right	medium	medium	59	65	55	59	54	57	49	57	54	52	69	74	67	70	59	69	68	72	61	61	64	59	57	57	63	43	44	49	4	20	54	20	20
37025	2008-08-30	63	65	right	medium	medium	59	65	55	59	54	57	49	57	54	52	69	74	67	70	59	69	68	72	61	61	64	59	57	57	63	43	44	49	14	20	54	20	20
37025	2007-08-30	65	65	right	medium	medium	59	65	55	59	54	57	49	57	54	52	69	74	67	70	59	69	68	72	61	61	64	59	57	57	63	43	44	49	14	20	54	20	20
37025	2007-02-22	65	65	right	medium	medium	59	65	55	59	54	57	49	63	54	52	69	74	67	70	59	69	68	72	61	61	64	59	57	57	63	43	44	49	14	13	54	8	9
38369	2016-03-10	78	78	right	medium	medium	46	79	79	73	72	75	48	46	53	76	79	84	83	78	66	80	83	78	82	68	68	35	79	69	72	16	36	28	8	6	9	10	12
38369	2016-02-11	78	78	right	medium	medium	46	79	79	73	72	75	48	46	53	76	79	84	83	78	66	80	83	80	82	68	68	35	79	69	72	16	36	28	8	6	9	10	12
38369	2016-01-07	78	78	right	medium	medium	62	79	79	73	72	75	48	46	53	76	79	84	83	78	66	80	83	80	82	68	68	35	79	69	72	16	36	28	8	6	9	10	12
38369	2015-12-10	78	78	right	medium	medium	62	79	79	73	72	75	48	46	53	76	79	84	83	78	66	80	83	80	81	68	68	35	79	69	72	16	36	28	8	6	9	10	12
38369	2015-10-16	79	79	right	medium	medium	62	82	78	75	72	75	48	46	53	80	79	84	83	78	66	80	83	80	81	68	68	35	79	70	72	16	36	28	8	6	9	10	12
38369	2015-10-02	79	79	right	medium	medium	62	82	78	75	72	75	48	46	53	80	80	84	83	78	66	80	83	80	81	68	68	35	79	70	72	16	36	28	8	6	9	10	12
38369	2015-09-21	79	79	right	medium	medium	62	82	78	75	72	75	48	46	53	81	80	84	83	78	66	80	83	80	81	68	68	35	79	73	72	16	36	28	8	6	9	10	12
38369	2013-02-22	79	79	right	medium	medium	62	82	78	75	72	75	48	46	53	81	80	84	83	78	66	80	83	80	81	68	68	35	79	73	72	16	36	28	8	6	9	10	12
38369	2013-02-15	79	79	right	medium	medium	62	78	78	75	73	75	48	46	53	81	80	84	83	78	66	80	83	80	81	71	68	35	79	73	72	16	36	28	8	6	9	10	12
38369	2012-08-31	77	79	right	medium	medium	62	76	78	72	73	75	48	46	53	77	81	84	84	75	65	80	82	77	85	71	68	27	75	73	74	16	36	28	8	6	9	10	12
38369	2012-02-22	77	79	right	medium	medium	62	76	78	72	73	75	48	46	53	77	82	84	81	75	65	80	82	77	85	71	68	27	75	73	74	16	36	28	8	6	9	10	12
38369	2011-08-30	77	78	right	medium	medium	58	76	81	68	70	79	41	44	64	77	85	85	86	75	63	76	80	66	83	69	75	46	74	73	72	17	36	28	8	6	9	10	12
38369	2011-02-22	76	82	right	medium	medium	58	76	81	68	70	79	41	44	64	78	77	78	83	74	83	72	77	73	84	68	75	46	75	73	72	17	36	28	8	6	9	10	12
38369	2010-08-30	78	85	right	medium	medium	62	84	80	69	70	82	41	44	65	81	77	78	86	74	83	70	75	73	85	70	75	46	77	75	72	17	65	28	8	6	9	10	12
38369	2010-02-22	77	85	right	medium	medium	62	84	80	69	70	82	41	44	65	80	77	78	86	74	83	70	75	73	80	70	55	54	67	75	88	20	65	28	1	20	65	20	20
38369	2009-08-30	77	85	right	medium	medium	62	84	80	69	70	82	41	44	65	80	77	78	86	74	83	70	75	73	73	70	55	54	67	75	88	20	65	28	1	20	65	20	20
38369	2009-02-22	74	80	right	medium	medium	51	81	73	65	70	74	41	44	55	76	75	77	86	71	83	70	75	67	73	69	43	54	65	75	88	20	35	28	1	20	55	20	20
38369	2008-08-30	73	75	right	medium	medium	48	77	71	67	70	76	41	44	59	78	74	75	86	71	83	70	75	65	67	72	43	37	55	75	78	20	55	28	1	20	59	20	20
38369	2007-08-30	69	73	right	medium	medium	43	71	67	58	70	68	41	44	40	67	68	73	86	67	83	65	75	65	67	61	53	37	45	75	57	27	24	28	1	20	40	20	20
38369	2007-02-22	64	73	right	medium	medium	43	61	56	53	70	64	41	47	40	60	66	68	86	58	83	65	75	65	65	46	53	37	45	75	47	27	24	28	1	1	40	1	1
148313	2012-02-22	62	69	right	medium	medium	63	31	53	62	46	56	53	46	57	61	71	66	83	63	91	48	87	67	34	38	73	58	53	55	37	66	60	61	10	6	15	7	11
148313	2011-08-30	64	68	right	medium	medium	61	31	57	63	48	56	53	46	59	62	74	70	79	66	90	49	93	69	33	38	78	62	53	55	41	65	62	63	10	6	15	7	11
148313	2010-08-30	63	71	right	medium	medium	61	31	59	63	48	56	53	46	59	59	72	70	73	67	62	49	73	67	58	38	74	63	56	53	41	65	62	63	10	6	15	7	11
148313	2010-02-22	63	71	right	medium	medium	61	31	59	63	48	56	53	46	59	59	72	70	73	67	62	49	73	67	58	38	74	56	55	53	58	65	62	63	2	21	59	21	21
148313	2009-08-30	63	71	right	medium	medium	61	31	59	63	48	56	53	46	59	59	72	70	73	67	62	49	73	67	58	38	74	56	55	53	58	65	62	63	2	21	59	21	21
148313	2009-02-22	59	71	right	medium	medium	56	31	56	61	48	42	53	46	60	47	69	71	73	62	62	49	73	65	51	35	74	54	53	53	56	65	60	63	2	21	60	21	21
148313	2008-08-30	56	71	right	medium	medium	56	34	38	61	48	39	53	46	60	42	66	71	73	62	62	44	73	52	56	35	31	51	53	53	50	59	60	63	2	21	60	21	21
148313	2007-02-22	56	71	right	medium	medium	56	34	38	61	48	39	53	46	60	42	66	71	73	62	62	44	73	52	56	35	31	51	53	53	50	59	60	63	2	21	60	21	21
15913	2009-02-22	59	61	left	\N	\N	51	38	54	48	\N	38	\N	45	45	51	67	65	\N	60	\N	63	\N	63	62	46	66	59	64	\N	61	60	61	\N	5	22	45	22	22
15913	2007-02-22	59	61	left	\N	\N	51	38	54	48	\N	38	\N	45	45	51	67	65	\N	60	\N	63	\N	63	62	46	66	59	64	\N	61	60	61	\N	5	22	45	22	22
38251	2013-09-20	55	55	left	medium	medium	52	57	63	62	57	46	53	55	51	57	33	30	52	58	54	58	81	33	71	55	67	22	60	71	64	27	44	43	6	15	8	11	9
38251	2012-02-22	55	55	left	medium	medium	52	57	63	62	57	46	53	55	51	57	33	30	52	58	54	58	81	33	71	55	67	22	60	71	64	27	44	43	6	15	8	11	9
38251	2011-08-30	55	55	left	medium	medium	52	57	63	62	57	46	53	55	51	57	33	33	52	58	54	58	81	41	71	55	67	22	60	71	64	27	44	43	6	15	8	11	9
38251	2011-02-22	63	69	left	medium	medium	52	63	63	67	67	46	53	55	51	57	47	55	56	58	70	58	57	65	71	66	67	45	68	71	64	27	46	43	6	15	8	11	9
38251	2010-08-30	67	69	left	medium	medium	54	69	76	70	72	57	53	55	52	67	52	57	60	65	75	72	65	75	77	65	73	45	67	71	64	32	49	46	6	15	8	11	9
38251	2009-08-30	65	67	left	medium	medium	54	63	76	70	72	57	53	55	52	67	52	57	60	65	75	72	65	75	77	65	73	75	72	71	67	32	49	46	9	25	52	25	25
38251	2009-02-22	67	69	left	medium	medium	54	66	76	68	72	57	53	47	49	72	62	64	60	69	75	69	65	75	78	64	75	74	71	71	66	42	49	46	9	25	49	25	25
38251	2008-08-30	67	67	left	medium	medium	54	66	76	68	72	57	53	47	49	72	62	64	60	69	75	69	65	75	78	64	75	74	71	71	66	42	49	46	9	25	49	25	25
38251	2007-08-30	68	67	left	medium	medium	54	66	76	68	72	57	53	47	49	72	62	64	60	69	75	69	65	73	78	64	75	74	71	71	66	42	49	46	9	25	49	25	25
38251	2007-02-22	69	70	left	medium	medium	54	64	80	68	72	58	53	62	39	74	63	68	60	66	75	72	65	73	80	64	75	74	71	71	62	42	49	46	9	13	39	6	6
110140	2012-02-22	59	69	right	medium	medium	56	46	27	51	48	66	46	32	43	56	77	88	77	61	71	50	72	40	43	51	31	22	38	46	52	17	24	23	11	13	6	6	7
110140	2011-08-30	59	69	right	medium	medium	56	46	27	51	48	66	46	32	43	56	77	88	77	61	71	50	72	46	43	51	31	22	38	46	52	17	24	23	11	13	6	6	7
110140	2011-02-22	61	69	right	medium	medium	57	48	27	52	53	66	46	32	45	56	75	80	71	61	47	55	67	53	51	51	33	22	43	51	52	17	24	23	11	13	6	6	7
110140	2010-08-30	61	69	right	medium	medium	57	48	27	52	53	66	46	32	45	56	75	80	71	61	47	55	67	53	51	51	33	22	43	51	52	17	24	23	11	13	6	6	7
110140	2010-02-22	60	69	right	medium	medium	53	48	37	50	53	62	46	32	47	60	74	78	71	62	47	57	67	58	51	51	33	37	46	51	53	21	24	23	14	21	47	21	21
110140	2009-08-30	65	75	right	medium	medium	69	50	52	62	53	73	46	32	54	70	81	81	71	64	47	62	67	60	64	59	43	47	55	51	60	33	34	23	14	21	54	21	21
110140	2008-08-30	62	72	right	medium	medium	41	61	62	32	53	68	46	32	38	56	81	81	71	64	47	62	67	52	59	69	32	42	43	51	43	33	34	23	14	21	38	21	21
110140	2007-08-30	63	72	right	medium	medium	41	61	62	32	53	68	46	32	38	56	81	81	71	64	47	62	67	52	59	69	32	42	43	51	43	33	34	23	14	21	38	21	21
110140	2007-02-22	63	72	right	medium	medium	41	61	62	32	53	68	46	32	38	56	81	81	71	64	47	62	67	52	59	69	32	42	43	51	43	33	34	23	14	21	38	21	21
75405	2014-11-28	66	66	right	high	medium	51	65	71	60	63	61	56	55	48	64	61	64	48	65	43	73	63	60	86	61	67	38	68	66	63	37	42	34	7	10	8	8	11
75405	2014-09-18	66	66	right	high	medium	51	65	71	60	63	61	56	55	48	64	61	64	48	65	43	73	63	60	86	61	67	38	68	66	63	37	42	34	7	10	8	8	11
75405	2012-08-31	66	66	right	high	medium	51	65	71	60	63	61	56	55	48	64	61	64	48	65	43	73	63	60	86	61	67	38	68	66	63	37	42	34	7	10	8	8	11
75405	2012-02-22	73	73	right	high	medium	51	74	76	60	63	69	56	55	48	71	61	75	67	65	58	81	63	60	86	66	65	38	68	66	63	37	42	34	7	10	8	8	11
75405	2011-08-30	71	71	right	high	medium	51	73	72	60	67	69	56	55	48	67	61	75	67	68	58	78	63	60	85	63	65	38	66	66	63	37	42	34	7	10	8	8	11
75405	2011-02-22	69	73	right	high	medium	51	71	70	58	69	64	56	55	48	63	68	71	61	65	85	75	66	73	87	62	65	38	66	63	63	37	42	34	7	10	8	8	11
75405	2010-08-30	71	73	right	high	medium	65	74	69	66	73	66	56	59	56	68	68	73	58	63	85	78	66	72	87	63	65	48	68	63	63	37	42	34	7	10	8	8	11
75405	2010-02-22	70	73	right	high	medium	65	73	71	63	73	66	56	59	57	67	71	73	58	65	85	70	66	58	83	60	55	65	60	63	67	41	47	34	34	22	57	24	45
75405	2009-08-30	69	72	right	high	medium	52	72	70	58	73	71	56	59	47	67	75	72	58	65	85	70	66	58	71	60	55	65	60	63	67	22	22	34	4	22	47	22	22
75405	2009-02-22	69	72	right	high	medium	52	72	70	58	73	71	56	59	47	67	75	72	58	65	85	70	66	58	71	60	55	65	60	63	67	22	22	34	4	22	47	22	22
75405	2008-08-30	67	72	right	high	medium	52	75	70	48	73	72	56	69	47	64	60	62	58	60	85	72	66	53	51	68	45	50	48	63	47	31	22	34	4	22	47	22	22
75405	2007-02-22	67	72	right	high	medium	52	75	70	48	73	72	56	69	47	64	60	62	58	60	85	72	66	53	51	68	45	50	48	63	47	31	22	34	4	22	47	22	22
127191	2013-03-22	64	69	right	medium	low	61	48	53	58	53	68	58	36	53	66	81	83	74	64	73	66	81	69	73	56	56	33	58	53	48	31	36	46	10	12	6	9	14
127191	2013-03-15	64	69	right	medium	low	61	48	53	58	53	68	58	36	53	66	81	83	74	64	73	66	81	69	73	56	56	33	58	53	48	31	36	46	10	12	6	9	14
127191	2013-02-15	64	69	right	medium	low	61	48	53	58	53	68	58	36	53	66	81	83	74	64	73	66	81	69	73	56	56	33	58	53	48	31	36	46	10	12	6	9	14
127191	2012-08-31	64	69	right	medium	low	61	48	53	58	53	68	58	36	53	66	81	83	74	64	71	66	78	69	73	56	56	33	58	53	48	31	36	46	10	12	6	9	14
127191	2012-02-22	66	73	right	medium	low	63	48	48	61	53	71	58	36	53	66	83	81	78	64	68	66	78	73	71	58	56	33	58	58	48	31	36	58	10	12	6	9	14
127191	2011-08-30	64	73	right	medium	low	63	48	48	61	51	68	43	36	53	64	80	83	84	64	66	66	78	61	66	58	31	29	56	58	48	26	28	31	10	12	6	9	14
127191	2010-08-30	61	67	right	medium	low	57	56	46	60	53	68	45	46	54	66	66	68	65	58	62	67	65	64	67	59	56	36	61	63	46	26	32	33	10	12	6	9	14
127191	2009-08-30	59	72	right	medium	low	51	56	46	56	53	68	45	46	48	66	68	71	65	58	62	68	65	63	66	58	49	55	51	63	53	26	32	33	5	21	48	21	21
127191	2009-02-22	57	73	right	medium	low	51	56	46	56	53	68	45	46	48	66	68	71	65	58	62	68	65	63	64	58	43	34	33	63	53	26	32	33	5	21	48	21	21
127191	2008-08-30	52	70	right	medium	low	43	48	43	53	53	62	45	41	46	64	65	67	65	57	62	55	65	60	62	47	43	34	33	63	53	21	22	33	5	21	46	21	21
127191	2007-02-22	52	70	right	medium	low	43	48	43	53	53	62	45	41	46	64	65	67	65	57	62	55	65	60	62	47	43	34	33	63	53	21	22	33	5	21	46	21	21
78902	2016-04-28	65	65	left	\N	\N	61	62	55	62	63	66	62	61	56	64	78	77	75	63	74	66	78	61	62	61	38	29	63	62	65	26	28	30	6	12	9	12	7
78902	2016-03-31	66	66	left	\N	\N	62	63	55	63	63	67	64	61	56	64	79	78	76	64	74	67	80	67	62	62	38	29	63	62	65	26	28	30	6	12	9	12	7
78902	2016-03-24	66	66	left	\N	\N	62	63	55	63	63	67	64	61	56	64	79	78	76	64	74	67	80	67	62	62	38	29	63	62	65	26	28	30	6	12	9	12	7
78902	2015-12-03	66	66	left	\N	\N	62	63	55	63	63	67	64	61	56	64	79	78	81	64	74	67	85	67	62	62	38	29	63	62	65	26	28	30	6	12	9	12	7
78902	2015-09-25	66	66	left	\N	\N	62	63	55	63	63	67	64	61	56	64	79	78	81	64	74	67	85	67	62	62	38	29	63	62	65	26	28	30	6	12	9	12	7
78902	2015-09-21	66	66	left	\N	\N	62	63	55	63	63	67	64	61	56	64	79	78	81	64	74	67	85	67	62	62	38	29	63	62	65	26	28	30	6	12	9	12	7
78902	2015-03-20	65	65	left	high	medium	61	62	54	62	62	67	63	60	55	63	80	78	81	63	74	66	83	67	58	61	47	38	63	62	64	25	27	29	5	11	8	11	6
78902	2015-02-13	66	66	left	high	medium	62	66	61	62	62	67	63	62	55	65	80	78	81	65	74	67	83	67	61	65	47	38	66	62	67	25	27	29	5	11	8	11	6
78902	2014-12-05	67	67	left	high	medium	63	69	61	64	62	68	63	66	58	67	81	80	82	67	74	68	83	70	62	66	47	38	67	62	71	25	27	29	5	11	8	11	6
78902	2014-10-10	67	67	left	high	medium	63	69	61	64	62	68	63	66	58	67	81	80	82	67	74	68	83	70	62	66	47	38	67	62	71	25	27	29	5	11	8	11	6
78902	2014-09-18	67	67	left	high	medium	62	69	61	64	62	68	63	66	58	67	81	80	82	67	74	68	83	70	62	66	47	38	67	65	71	25	27	29	5	11	8	11	6
78902	2014-03-14	69	70	left	high	medium	66	70	63	64	67	68	64	66	66	67	85	81	82	70	74	70	82	70	64	67	47	38	68	66	72	25	27	29	5	11	8	11	6
78902	2014-02-07	69	73	left	high	medium	66	70	63	64	67	68	64	66	66	67	85	81	82	70	74	70	82	70	64	67	47	38	68	66	72	25	27	29	5	11	8	11	6
78902	2013-09-20	69	73	left	high	medium	66	70	63	64	67	68	64	66	66	67	85	81	82	70	74	70	82	70	64	67	47	38	68	66	72	25	27	29	5	11	8	11	6
78902	2013-05-31	70	73	left	high	medium	68	74	63	66	68	70	64	66	69	67	85	81	82	70	74	70	82	70	64	69	47	38	71	66	72	25	27	29	5	11	8	11	6
78902	2013-05-17	70	73	left	high	medium	68	74	63	66	68	70	64	66	69	67	85	81	82	70	74	70	82	70	64	69	47	38	71	66	72	25	27	29	5	11	8	11	6
78902	2013-02-22	72	73	left	high	medium	71	77	63	68	68	72	64	66	70	69	85	81	82	70	74	70	82	70	64	69	47	38	71	67	72	25	27	29	5	11	8	11	6
78902	2013-02-15	72	73	left	high	medium	71	77	63	68	68	69	64	66	66	68	85	81	82	70	74	70	82	70	64	69	47	38	71	67	72	25	27	29	5	11	8	11	6
78902	2012-08-31	67	69	left	high	medium	68	66	62	62	63	68	63	33	53	63	85	81	82	66	73	68	80	70	64	63	37	33	64	61	64	25	27	29	5	11	8	11	6
78902	2012-02-22	66	67	left	high	medium	67	66	53	62	63	68	63	33	53	63	85	81	82	66	73	68	80	70	64	63	37	33	62	61	64	25	27	29	5	11	8	11	6
78902	2011-08-30	66	67	left	high	medium	67	66	53	62	63	68	63	33	53	63	85	81	82	66	73	68	79	70	64	63	37	33	62	61	64	25	27	29	5	11	8	11	6
78902	2011-02-22	66	72	left	high	medium	67	66	53	62	63	68	63	33	53	63	80	78	75	66	59	68	72	67	57	63	37	33	62	61	64	25	27	29	5	11	8	11	6
78902	2010-08-30	66	72	left	high	medium	69	66	53	63	63	68	63	33	54	63	80	78	73	66	59	68	72	67	57	63	37	41	62	45	64	20	22	24	5	11	8	11	6
78902	2010-02-22	65	66	left	high	medium	61	66	53	58	63	66	63	33	51	61	80	78	73	66	59	68	72	67	58	63	27	48	58	45	67	22	22	24	11	22	51	22	22
78902	2008-08-30	60	64	left	high	medium	35	66	45	41	63	62	63	33	25	57	71	76	73	61	59	58	72	55	52	53	22	45	58	45	67	22	22	24	11	22	25	22	22
78902	2007-02-22	60	64	left	high	medium	35	66	45	41	63	62	63	33	25	57	71	76	73	61	59	58	72	55	52	53	22	45	58	45	67	22	22	24	11	22	25	22	22
20445	2014-02-21	66	66	left	medium	high	53	57	73	64	46	63	47	56	57	65	48	52	47	67	55	65	57	75	78	63	78	68	64	64	48	58	64	59	9	10	11	5	11
20445	2013-09-20	65	66	left	medium	high	53	57	73	64	46	63	47	56	57	65	48	52	47	65	55	65	57	75	78	63	78	67	64	63	48	56	62	57	9	10	11	5	11
20445	2013-03-22	65	66	left	medium	high	53	57	73	64	46	63	47	56	57	65	48	54	47	65	52	65	57	75	78	63	78	67	64	63	48	56	62	57	9	10	11	5	11
20445	2013-02-15	64	65	left	medium	high	53	57	73	64	46	63	47	56	57	65	53	54	48	64	55	65	55	74	77	63	78	65	64	63	48	56	62	57	9	10	11	5	11
20445	2012-08-31	64	65	left	medium	high	53	57	73	64	46	63	47	56	57	65	53	58	48	64	51	65	58	74	77	63	78	65	64	63	48	56	62	57	9	10	11	5	11
20445	2010-08-30	64	65	left	medium	high	53	57	73	64	46	63	47	56	57	65	53	58	48	64	51	65	58	74	77	63	78	65	64	63	48	56	62	57	9	10	11	5	11
20445	2010-02-22	65	65	left	medium	high	53	57	73	65	46	65	47	56	57	67	56	58	48	63	51	65	58	74	77	63	78	66	68	63	65	56	62	57	9	20	55	20	20
20445	2009-08-30	65	65	left	medium	high	53	57	73	65	46	65	47	56	57	67	56	58	48	63	51	65	58	74	77	63	78	66	68	63	65	56	62	57	9	20	55	20	20
20445	2009-02-22	63	68	left	medium	high	48	58	74	63	46	56	47	57	56	65	55	58	48	56	51	65	58	71	75	64	78	66	68	63	65	58	62	57	19	20	56	20	20
20445	2008-08-30	63	68	left	medium	high	48	58	74	63	46	56	47	57	56	65	55	58	48	56	51	65	58	71	75	64	78	66	68	63	65	58	62	57	19	20	56	20	20
20445	2007-08-30	58	68	left	medium	high	31	34	64	40	46	35	47	47	36	40	50	58	48	56	51	50	58	67	68	64	56	51	58	63	50	58	52	57	19	20	36	20	20
20445	2007-02-22	58	68	left	medium	high	31	34	64	40	46	35	47	50	36	40	50	58	48	56	51	50	58	67	68	64	56	51	58	63	50	58	52	57	19	12	36	8	14
156551	2016-05-12	79	82	left	medium	high	59	27	83	61	44	56	47	48	59	66	70	78	62	74	57	72	86	77	86	41	90	75	39	47	46	75	79	84	10	13	6	10	14
156551	2016-02-04	79	82	left	medium	high	59	27	83	61	44	56	47	48	59	66	70	78	62	76	57	72	86	77	86	41	90	75	39	47	46	76	79	84	10	13	6	10	14
156551	2015-10-16	79	83	left	medium	high	59	27	83	61	44	56	47	48	59	66	70	78	62	76	57	72	86	77	86	41	90	75	39	47	46	79	79	84	10	13	6	10	14
156551	2015-09-21	80	84	left	medium	high	59	27	83	61	44	56	47	48	59	66	70	83	62	76	57	72	86	77	86	41	90	75	39	47	46	79	79	84	10	13	6	10	14
156551	2015-05-22	79	83	left	medium	high	58	26	83	60	43	55	46	47	63	65	72	85	62	75	57	71	86	77	86	40	89	79	38	46	45	76	76	81	9	12	5	9	13
156551	2015-02-13	79	83	left	medium	high	64	26	83	65	43	60	46	47	63	65	72	85	62	79	57	71	86	77	86	40	89	79	38	46	45	76	76	81	9	12	5	9	13
156551	2015-01-30	79	83	left	medium	high	64	26	83	65	43	60	46	47	63	65	72	85	62	80	57	71	86	77	86	40	89	79	38	46	45	76	76	81	9	12	5	9	13
156551	2015-01-09	79	83	left	medium	high	64	26	83	65	43	60	46	47	63	65	72	85	62	80	57	71	86	77	86	40	89	81	38	46	45	76	76	81	9	12	5	9	13
156551	2014-12-19	80	85	left	medium	high	64	26	84	65	43	60	46	47	63	65	72	85	62	80	57	71	90	77	86	40	91	81	38	46	45	76	76	81	9	12	5	9	13
156551	2014-10-02	80	86	left	high	high	64	26	84	66	43	60	46	47	63	65	72	85	62	80	57	71	90	77	86	40	91	83	38	46	45	76	77	82	9	12	5	9	13
156551	2014-09-18	80	86	left	high	high	64	26	84	66	43	60	46	47	63	65	72	79	62	80	57	71	90	77	86	40	91	83	38	46	45	76	77	82	9	12	5	9	13
156551	2014-05-02	80	86	left	high	high	64	26	84	66	43	61	46	47	63	65	75	79	74	80	57	77	90	77	86	40	91	83	38	56	45	76	77	82	9	12	5	9	13
156551	2014-04-18	80	86	left	high	high	64	26	85	66	43	61	46	47	63	65	75	79	74	81	57	77	90	77	86	40	91	82	27	56	45	76	77	82	9	12	5	9	13
156551	2014-03-07	80	86	left	high	high	64	26	86	66	43	61	46	47	63	65	75	79	74	81	57	77	90	77	86	40	91	82	27	56	45	76	77	82	9	12	5	9	13
156551	2014-02-28	80	86	left	high	high	64	26	85	66	43	61	46	47	63	65	75	79	74	80	57	77	90	77	86	40	91	83	27	56	45	76	77	82	9	12	5	9	13
156551	2014-02-21	81	86	left	high	high	64	26	84	66	43	61	46	47	63	65	75	79	74	81	57	77	90	77	86	40	91	83	27	56	45	78	77	82	9	12	5	9	13
156551	2014-01-31	81	86	left	high	high	64	26	86	66	43	61	46	47	59	65	75	79	74	81	57	77	90	77	86	40	91	83	27	55	45	78	77	82	9	12	5	9	13
156551	2014-01-24	81	86	left	high	high	64	26	86	66	43	61	46	47	59	65	75	79	66	81	57	77	90	77	86	40	91	83	27	55	45	78	77	82	9	12	5	9	13
156551	2013-12-06	81	86	left	high	high	64	26	86	66	43	61	46	47	59	65	75	79	66	81	57	77	90	79	86	40	91	83	27	55	45	78	77	82	9	12	5	9	13
156551	2013-11-29	81	86	left	high	high	64	26	87	66	43	61	46	47	59	65	75	79	66	81	57	77	90	79	84	40	91	84	27	55	45	79	77	82	9	12	5	9	13
156551	2013-10-11	81	86	left	high	high	64	26	87	66	43	61	46	47	59	65	74	79	66	81	57	77	90	79	84	40	91	84	27	55	45	79	77	82	9	12	5	9	13
156551	2013-10-04	81	86	left	high	high	64	26	87	66	43	61	46	47	59	65	74	79	66	81	57	77	90	79	84	40	91	84	27	55	45	79	77	82	9	12	5	9	13
156551	2013-09-27	81	86	left	high	high	64	26	87	66	43	61	46	47	59	65	74	79	66	80	57	77	90	79	84	40	89	84	27	55	45	79	77	82	9	12	5	9	13
156551	2013-09-20	81	86	left	high	high	64	26	87	66	43	61	46	47	59	65	74	79	66	83	57	77	90	79	84	40	91	84	27	55	45	79	77	82	9	12	5	9	13
156551	2013-05-10	79	85	left	medium	high	66	26	85	67	43	62	46	47	59	67	77	79	71	72	57	62	91	74	84	40	91	81	27	55	45	78	76	78	9	12	5	9	13
156551	2013-04-19	78	85	left	medium	high	66	26	80	67	43	62	46	47	59	67	77	79	71	72	57	62	91	74	84	40	91	76	27	55	45	78	76	77	9	12	5	9	13
156551	2013-04-05	78	85	left	medium	high	66	26	78	67	43	62	46	47	59	67	77	79	71	72	57	62	88	74	88	40	91	76	27	55	45	78	76	77	9	12	5	9	13
156551	2013-03-28	78	85	left	medium	high	66	26	78	67	43	62	46	47	59	69	77	79	71	72	57	62	86	74	85	40	91	76	27	55	45	78	76	77	9	12	5	9	13
156551	2013-03-15	78	85	left	medium	high	66	26	78	67	43	62	46	47	59	69	77	79	71	72	57	62	85	74	84	40	91	76	27	55	45	78	76	77	9	12	5	9	13
156551	2013-03-08	78	84	left	medium	high	66	26	78	67	43	62	46	47	59	69	77	79	71	72	57	62	85	74	84	40	91	76	27	55	45	78	76	77	9	12	5	9	13
156551	2013-02-15	78	84	left	medium	high	66	26	78	67	43	62	46	47	59	69	77	79	71	72	57	62	85	74	84	40	91	76	27	55	45	77	75	77	9	12	5	9	13
156551	2012-08-31	77	84	left	medium	high	66	26	79	67	43	62	46	47	59	69	78	79	69	73	57	62	80	74	82	40	86	76	27	55	45	77	77	76	9	12	5	9	13
156551	2012-02-22	77	83	left	medium	high	47	30	79	67	43	61	46	47	59	69	77	79	72	73	57	62	82	75	83	46	84	77	27	55	45	78	77	76	9	12	5	9	13
156551	2011-08-30	72	82	right	medium	high	47	32	72	62	43	57	46	47	56	64	78	81	72	71	53	68	80	74	81	58	72	67	27	44	45	73	74	72	9	12	5	9	13
156551	2011-02-22	70	80	right	medium	high	47	52	70	58	46	57	46	47	53	62	68	71	60	66	72	70	70	77	74	62	78	67	40	57	45	69	72	70	9	12	5	9	13
156551	2010-08-30	70	80	right	medium	high	47	52	70	58	46	57	46	47	53	62	68	71	60	66	72	70	70	77	74	62	78	67	50	57	45	69	72	70	9	12	5	9	13
156551	2010-02-22	71	83	right	medium	high	47	52	70	58	46	57	46	47	53	62	68	73	60	66	72	70	70	77	74	62	78	58	56	57	60	71	74	70	12	22	53	22	22
156551	2009-08-30	67	78	right	medium	high	45	45	61	61	46	56	46	43	54	61	64	73	60	59	72	65	70	75	69	60	77	56	58	57	51	66	70	70	2	22	54	22	22
156551	2009-02-22	59	74	right	medium	high	49	33	57	61	46	49	46	43	54	57	62	69	60	60	72	58	70	75	69	37	68	46	38	57	37	57	63	70	2	22	54	22	22
156551	2007-02-22	59	74	right	medium	high	49	33	57	61	46	49	46	43	54	57	62	69	60	60	72	58	70	75	69	37	68	46	38	57	37	57	63	70	2	22	54	22	22
148329	2016-04-21	64	64	right	low	low	46	68	73	63	63	51	36	33	38	56	38	33	41	56	37	71	51	33	88	61	68	32	74	66	60	22	32	25	19	15	19	13	18
148329	2016-03-24	64	64	right	low	low	46	68	73	63	63	51	36	33	38	56	38	33	41	56	37	71	51	33	88	61	68	32	74	69	60	22	32	25	19	15	19	13	18
148329	2016-01-28	64	64	right	low	low	46	68	73	63	63	51	36	33	38	56	38	43	41	56	37	71	56	33	88	61	68	32	74	69	60	22	32	25	19	15	19	13	18
148329	2015-12-17	64	64	right	low	low	46	68	73	63	63	51	36	33	38	56	38	43	41	56	37	71	56	33	88	61	68	32	74	69	60	22	32	25	19	15	19	13	18
148329	2015-09-21	65	65	right	low	low	47	69	75	64	64	52	37	33	39	57	42	43	46	57	37	72	57	33	89	62	69	32	74	69	61	22	32	25	19	15	19	13	18
148329	2015-03-06	64	64	right	low	low	46	68	74	63	63	51	36	32	38	56	48	50	46	56	37	71	56	49	89	61	68	31	74	68	60	21	31	24	18	14	18	12	17
148329	2014-09-18	66	66	right	low	low	48	69	76	64	63	53	36	32	43	57	50	50	48	57	37	73	56	49	91	61	68	38	74	68	60	31	41	34	18	14	18	12	17
148329	2014-07-18	67	67	right	low	low	48	69	76	66	64	56	36	32	43	57	53	50	51	61	37	74	58	53	93	61	68	38	74	68	60	31	41	34	18	28	18	12	17
148329	2013-11-29	67	67	right	low	low	48	69	76	66	64	56	36	32	43	57	53	50	51	61	37	74	58	53	93	61	68	38	74	68	60	31	41	34	18	28	18	12	17
148329	2013-11-22	67	67	right	low	low	48	69	76	66	63	56	36	32	43	57	53	58	51	60	37	73	58	53	91	61	68	38	74	68	60	31	41	34	18	28	18	12	17
148329	2013-09-20	66	66	right	low	low	48	69	76	66	63	56	36	32	43	57	51	56	53	60	37	73	58	53	91	61	68	38	74	68	60	31	41	34	18	28	18	12	17
148329	2013-04-12	67	67	right	low	low	48	70	78	66	63	58	36	32	43	58	52	59	54	61	37	74	60	58	93	61	73	38	74	68	60	31	41	34	18	28	18	12	17
148329	2013-02-15	68	68	right	low	low	48	73	78	66	63	58	36	32	43	58	58	61	56	61	37	74	63	58	93	61	73	38	74	68	60	31	41	34	18	28	18	12	17
148329	2012-08-31	68	68	right	low	low	48	73	78	66	63	58	36	32	43	58	58	63	53	61	38	74	63	58	93	61	73	38	74	68	60	31	41	34	18	28	18	12	17
148329	2012-02-22	68	68	right	medium	medium	47	71	78	66	63	58	36	32	43	63	63	68	58	58	43	74	63	59	93	61	73	38	68	68	60	31	47	34	7	8	9	7	8
148329	2011-08-30	69	69	right	medium	medium	47	69	84	62	63	58	36	32	43	63	64	69	62	63	43	74	58	64	93	61	73	48	74	68	60	41	47	34	18	28	18	12	17
148329	2011-02-22	68	71	right	medium	medium	47	71	78	60	63	58	36	32	43	63	63	69	64	62	90	74	64	68	91	61	68	48	74	68	60	41	47	34	18	28	18	12	17
148329	2010-08-30	69	71	right	medium	medium	47	74	74	64	63	58	36	32	43	67	63	71	60	62	90	74	63	68	91	61	68	48	72	69	60	41	47	34	8	8	8	6	7
148329	2010-02-22	68	70	right	medium	medium	47	69	73	67	63	58	36	32	43	68	68	72	60	63	90	74	63	68	91	62	68	45	67	69	63	55	59	34	11	22	43	22	22
148329	2009-08-30	67	70	right	medium	medium	48	72	71	58	63	53	36	32	43	69	66	73	60	53	90	78	63	66	91	62	68	45	61	69	48	43	59	34	11	22	43	22	22
148329	2009-02-22	64	67	right	medium	medium	43	66	64	54	63	53	36	32	37	61	66	73	60	53	90	78	63	66	83	62	68	45	51	69	48	22	29	34	11	22	37	22	22
148329	2008-08-30	53	58	right	medium	medium	27	51	55	47	63	48	36	32	24	53	58	58	60	47	90	65	63	60	78	42	45	35	40	69	42	22	22	34	11	22	24	22	22
148329	2007-02-22	53	58	right	medium	medium	27	51	55	47	63	48	36	32	24	53	58	58	60	47	90	65	63	60	78	42	45	35	40	69	42	22	22	34	11	22	24	22	22
42153	2013-05-17	71	71	right	medium	low	64	72	66	71	71	73	67	66	66	74	73	70	72	73	77	68	76	68	62	71	62	41	76	73	70	29	33	34	8	6	11	15	6
42153	2013-02-15	71	71	right	medium	low	64	72	66	71	71	73	67	66	66	74	73	70	72	73	77	68	76	68	62	71	62	41	76	73	70	29	33	34	8	6	11	15	6
42153	2012-08-31	72	72	right	high	medium	64	72	66	71	71	73	67	66	66	74	73	71	72	73	76	68	73	68	61	71	62	41	76	73	70	29	33	34	8	6	11	15	6
42153	2012-02-22	73	73	right	high	medium	65	74	66	72	72	75	67	66	67	76	73	71	72	73	74	68	73	68	60	71	56	46	76	73	72	29	33	34	8	6	11	15	6
42153	2011-08-30	74	74	right	high	medium	65	76	66	73	72	75	67	67	70	76	78	76	76	76	74	69	78	68	61	71	56	48	78	74	72	29	33	34	8	6	11	15	6
42153	2011-02-22	72	76	right	high	medium	65	74	62	73	72	77	67	67	70	76	74	73	69	70	66	69	70	67	68	71	56	43	75	74	72	29	33	34	8	6	11	15	6
42153	2010-08-30	72	76	right	high	medium	64	74	57	73	72	74	67	67	70	77	74	73	69	69	66	68	70	67	68	70	51	43	73	74	66	32	33	34	8	6	11	15	6
42153	2009-08-30	70	73	right	high	medium	62	73	53	72	72	73	67	66	65	76	73	71	69	69	66	67	70	67	62	69	46	67	72	74	77	32	33	34	9	23	65	23	23
42153	2009-02-22	70	73	right	high	medium	60	74	53	72	72	73	67	66	62	76	73	71	69	69	66	67	70	67	57	65	46	65	72	74	77	32	33	34	11	23	62	23	23
42153	2008-08-30	69	75	right	high	medium	58	76	38	70	72	73	67	63	42	74	79	73	69	57	66	72	70	67	57	55	56	50	69	74	77	32	33	34	11	23	42	23	23
42153	2007-08-30	73	74	right	high	medium	58	74	38	70	72	73	67	62	42	74	79	73	69	57	66	70	70	67	57	55	54	50	69	74	77	32	33	34	11	23	42	23	23
42153	2007-02-22	73	74	right	high	medium	58	74	38	70	72	73	67	62	42	74	79	73	69	57	66	70	70	67	57	55	54	50	69	74	77	32	33	34	11	23	42	23	23
17883	2009-08-30	65	69	right	\N	\N	41	68	63	54	\N	64	\N	42	52	62	66	68	\N	63	\N	66	\N	69	73	63	61	53	58	\N	56	21	21	\N	5	21	52	21	21
17883	2009-02-22	63	69	right	\N	\N	41	65	63	54	\N	64	\N	42	52	43	66	67	\N	65	\N	63	\N	69	67	65	61	49	51	\N	43	21	21	\N	5	21	52	21	21
17883	2007-02-22	63	69	right	\N	\N	41	65	63	54	\N	64	\N	42	52	43	66	67	\N	65	\N	63	\N	69	67	65	61	49	51	\N	43	21	21	\N	5	21	52	21	21
38332	2016-04-07	63	63	right	medium	medium	55	45	36	53	64	71	54	62	62	55	95	91	70	69	73	70	70	58	49	62	42	39	66	49	43	38	41	39	6	15	14	15	10
38332	2016-03-03	63	63	right	medium	medium	55	45	36	53	64	71	54	62	62	55	95	91	70	69	73	70	70	58	49	62	42	39	66	49	43	38	41	39	6	15	14	15	10
38332	2016-02-11	63	63	right	medium	medium	55	45	36	53	64	71	54	62	62	55	95	91	70	69	73	70	70	58	49	62	42	39	66	49	43	38	41	39	6	15	14	15	10
38332	2015-11-06	63	63	right	medium	medium	55	45	36	53	64	71	54	62	62	55	95	91	70	69	73	70	70	58	49	62	42	39	66	49	43	38	41	39	6	15	14	15	10
38332	2015-09-21	63	65	right	medium	medium	55	45	36	53	64	71	54	62	62	55	95	91	70	69	73	70	70	58	49	62	42	39	66	49	43	38	41	39	6	15	14	15	10
38332	2015-03-20	60	62	right	medium	medium	54	34	35	52	63	65	53	61	61	54	95	91	70	58	63	69	70	58	49	61	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2014-09-18	60	65	right	medium	medium	54	34	35	52	63	65	53	61	61	54	95	91	70	58	63	69	70	58	49	61	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2014-02-28	60	68	right	medium	medium	54	34	35	52	63	65	53	61	61	54	91	90	70	58	84	69	70	58	49	61	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2013-12-06	60	68	right	medium	low	54	34	35	52	63	65	53	61	61	54	91	90	70	58	84	69	70	58	49	61	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2013-11-01	61	68	right	medium	low	60	34	35	52	63	65	53	61	61	57	91	90	70	58	84	69	70	58	49	61	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2013-10-18	63	68	right	medium	low	71	34	35	52	63	65	53	61	61	57	91	90	70	62	84	69	70	58	49	61	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2013-09-20	63	68	right	medium	low	71	34	35	52	48	65	53	61	61	57	91	90	70	62	84	66	70	58	49	46	41	38	55	48	42	37	40	38	5	14	13	14	9
38332	2013-04-26	62	63	right	medium	low	66	38	37	60	48	61	53	61	61	63	75	73	70	58	80	66	70	58	53	46	43	36	53	52	42	31	36	36	5	14	13	14	9
38332	2013-03-08	61	63	right	medium	low	66	38	37	60	48	61	53	51	61	63	71	68	70	58	80	66	70	58	53	46	43	36	53	52	42	31	36	36	5	14	13	14	9
38332	2013-02-22	61	63	right	medium	low	66	38	37	60	48	61	53	51	61	63	71	68	70	58	80	66	68	58	53	46	43	36	53	52	42	31	36	36	5	14	13	14	9
38332	2009-08-30	61	63	right	medium	low	66	38	37	60	48	61	53	51	61	63	71	68	70	58	80	66	68	58	53	46	43	36	53	52	42	31	36	36	5	14	13	14	9
38332	2008-08-30	61	63	right	medium	low	70	25	37	60	48	58	53	29	61	63	74	75	70	67	80	66	68	58	60	46	73	36	53	52	42	31	34	36	5	14	13	14	9
38332	2007-08-30	56	73	right	medium	low	64	25	37	60	48	58	53	29	48	63	74	75	70	67	80	66	68	58	52	46	73	36	53	52	42	21	25	36	5	14	48	14	9
38332	2007-02-22	56	73	right	medium	low	64	25	37	60	48	58	53	37	48	63	74	75	70	67	80	66	68	58	52	46	73	36	53	52	42	19	25	36	5	14	48	14	13
112934	2015-11-12	62	64	right	medium	low	63	55	63	61	49	68	53	46	44	65	72	69	73	58	52	63	62	66	77	58	43	26	57	47	42	25	30	27	12	12	14	8	14
112934	2015-10-16	62	64	right	medium	low	63	55	63	61	49	68	53	46	44	65	72	69	73	58	52	63	62	66	77	58	43	26	57	47	56	25	30	27	12	12	14	8	14
112934	2015-09-21	62	65	right	medium	low	63	55	63	61	49	68	53	46	44	65	72	69	73	58	52	63	62	66	77	58	43	26	57	47	56	25	30	27	12	12	14	8	14
112934	2015-06-05	60	66	right	medium	low	62	54	62	60	48	64	52	45	43	65	72	71	59	57	52	62	60	66	77	54	42	25	56	46	55	24	29	26	11	11	13	7	13
112934	2014-11-14	59	63	right	medium	low	62	54	62	60	45	64	48	40	43	61	72	71	59	57	52	62	60	64	77	52	42	25	56	46	55	24	25	25	11	11	13	7	13
112934	2014-09-18	59	63	right	medium	low	62	54	62	60	45	64	48	40	43	61	72	71	59	57	52	62	60	64	77	52	42	25	56	46	55	24	25	25	11	11	13	7	13
112934	2013-11-29	59	67	right	medium	low	62	54	62	60	45	64	48	40	43	61	72	71	59	57	52	62	60	64	77	52	42	25	56	46	55	24	25	25	11	11	13	7	13
112934	2013-10-18	59	67	right	medium	low	62	54	62	60	45	64	48	40	43	61	72	71	59	57	52	62	60	64	77	52	42	25	56	46	55	24	25	25	11	11	13	7	13
112934	2013-09-20	57	67	right	medium	low	62	54	62	60	45	59	48	40	43	55	69	68	57	57	42	62	60	51	81	52	42	25	53	46	55	24	25	25	11	11	13	7	13
112934	2013-03-22	58	67	right	medium	medium	62	54	62	60	45	59	48	40	43	55	69	68	53	57	42	62	60	51	81	52	42	25	53	46	55	24	19	15	11	11	13	7	13
112934	2013-03-08	58	67	right	medium	medium	62	54	62	60	45	59	48	40	43	55	69	68	53	57	42	62	60	51	81	52	42	25	53	46	55	24	19	15	11	11	13	7	13
112934	2012-08-31	58	67	right	medium	medium	62	54	62	60	45	59	48	40	43	55	69	68	53	57	42	62	60	51	81	52	42	25	53	46	55	24	19	15	11	11	13	7	13
112934	2012-02-22	58	66	right	medium	medium	61	53	61	59	44	58	47	39	42	54	66	70	55	56	43	61	62	52	81	51	41	24	54	45	54	23	18	14	11	11	13	7	13
112934	2011-08-30	57	66	right	medium	medium	61	53	61	59	44	58	47	39	42	54	63	67	52	56	41	61	59	55	78	51	41	24	54	45	54	23	18	14	11	11	13	7	13
112934	2011-02-22	60	74	right	medium	medium	61	56	56	58	47	59	50	42	45	57	67	69	62	59	67	64	62	58	70	54	44	37	57	58	57	26	21	17	11	11	13	7	13
112934	2010-08-30	60	74	right	medium	medium	61	56	56	58	47	59	50	42	45	57	67	69	62	59	67	64	62	58	70	54	44	37	57	58	57	26	21	17	11	11	13	7	13
112934	2010-02-22	58	74	right	medium	medium	61	56	49	58	47	59	50	42	45	57	71	66	62	59	67	59	62	43	38	49	44	61	54	58	39	26	21	17	8	21	45	21	21
112934	2009-08-30	58	74	right	medium	medium	61	56	49	58	47	59	50	42	45	57	71	66	62	59	67	59	62	43	38	49	44	61	54	58	39	26	21	17	8	21	45	21	21
112934	2009-02-22	52	69	right	medium	medium	63	48	42	35	47	52	50	42	38	52	69	63	62	58	67	42	62	43	38	46	34	41	44	58	39	26	21	17	8	21	38	21	21
112934	2008-08-30	52	55	right	medium	medium	63	48	42	35	47	52	50	42	38	52	69	63	62	58	67	42	62	43	38	46	34	41	44	58	39	26	21	17	8	21	38	21	21
112934	2007-02-22	52	55	right	medium	medium	63	48	42	35	47	52	50	42	38	52	69	63	62	58	67	42	62	43	38	46	34	41	44	58	39	26	21	17	8	21	38	21	21
39575	2008-08-30	64	73	right	\N	\N	68	38	64	66	\N	61	\N	46	61	63	60	60	\N	61	\N	68	\N	61	64	53	68	65	66	\N	72	65	64	\N	9	21	61	21	21
39575	2007-08-30	66	73	right	\N	\N	69	38	66	67	\N	62	\N	47	62	64	62	62	\N	64	\N	71	\N	62	66	53	71	65	66	\N	72	67	66	\N	9	21	62	21	21
39575	2007-02-22	69	72	right	\N	\N	70	38	69	69	\N	67	\N	69	64	68	67	67	\N	68	\N	74	\N	65	69	61	73	65	66	\N	69	70	69	\N	9	10	64	12	13
38785	2014-10-24	67	67	right	medium	medium	29	25	68	38	25	36	25	21	24	48	63	66	62	65	54	67	78	68	78	25	81	61	23	37	24	66	69	68	15	5	11	7	5
38785	2014-09-18	67	67	right	medium	medium	29	25	68	38	25	36	25	21	24	48	63	66	62	65	54	67	78	68	78	25	81	61	23	37	24	66	69	68	15	5	11	7	5
38785	2011-08-30	67	67	right	medium	medium	29	25	68	38	25	36	25	21	24	48	63	66	62	65	54	67	78	68	78	25	81	61	23	37	24	66	69	68	15	5	11	7	5
38785	2011-02-22	66	68	right	medium	medium	49	32	68	48	37	40	35	41	38	46	61	63	58	53	73	67	65	65	78	25	81	62	43	37	45	64	66	65	15	5	11	7	5
38785	2010-08-30	66	68	right	medium	medium	49	32	68	48	37	40	35	41	38	46	61	63	58	53	73	67	65	65	78	25	81	62	43	47	45	64	66	65	15	5	11	7	5
38785	2009-08-30	66	68	right	medium	medium	27	32	68	48	37	40	35	41	38	46	61	63	58	53	73	67	65	65	78	25	81	46	66	47	53	64	66	65	3	20	38	20	20
38785	2009-02-22	66	68	right	medium	medium	27	32	68	48	37	40	35	41	38	46	61	63	58	53	73	67	65	65	78	25	81	46	66	47	53	64	66	65	13	20	38	20	20
38785	2008-08-30	66	68	right	medium	medium	27	32	68	48	37	40	35	41	38	46	61	63	58	53	73	67	65	65	78	25	81	46	66	47	53	64	66	65	13	20	38	20	20
38785	2007-08-30	65	68	right	medium	medium	27	32	68	48	37	40	35	41	38	46	61	63	58	53	73	67	65	65	78	25	81	46	66	47	53	64	66	65	13	20	38	20	20
38785	2007-02-22	65	69	right	medium	medium	27	32	68	48	37	40	35	53	38	46	57	61	58	54	73	67	65	65	77	25	81	46	66	47	53	65	63	65	13	9	38	13	9
27838	2015-01-30	63	63	left	medium	medium	69	40	53	62	51	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	72	44	58	43	62	67	57	14	11	10	14	15
27838	2014-09-12	63	63	left	medium	medium	69	40	53	62	51	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	72	44	58	43	62	67	57	14	11	10	14	15
27838	2014-03-14	64	64	left	medium	medium	69	40	53	62	51	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	72	44	58	43	62	67	57	14	11	10	14	15
27838	2014-02-07	64	64	left	medium	medium	69	40	53	62	51	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	72	44	58	43	62	67	57	14	11	10	14	15
27838	2014-01-03	64	64	left	medium	medium	69	40	53	62	51	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	72	44	58	43	62	67	57	14	11	10	14	15
27838	2013-12-06	64	64	left	medium	medium	69	40	53	62	51	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	72	44	58	43	62	67	57	14	11	10	14	15
27838	2013-11-29	64	64	left	medium	medium	69	40	53	62	60	53	68	31	67	61	44	49	42	66	56	68	60	74	73	58	67	76	44	58	43	62	67	57	14	11	10	14	15
27838	2013-10-25	64	64	left	medium	medium	69	40	53	62	60	53	68	31	67	61	44	49	42	66	56	68	60	74	73	64	67	76	44	58	43	62	67	57	14	11	10	14	15
27838	2013-08-30	65	65	left	medium	medium	69	40	53	62	60	53	68	31	67	61	44	49	42	66	56	71	60	74	73	64	67	76	44	58	43	64	69	57	14	11	10	14	15
27838	2013-08-09	65	65	left	medium	medium	69	40	53	62	60	53	68	31	67	61	44	49	42	66	56	71	60	74	73	64	67	76	44	58	43	64	69	57	14	11	10	14	15
27838	2013-07-19	65	65	left	medium	medium	69	40	53	62	60	53	68	31	67	61	44	49	45	64	56	71	60	77	73	64	67	76	52	58	43	64	69	57	14	11	10	14	15
27838	2013-03-08	63	63	left	medium	medium	69	40	53	58	60	53	68	31	67	61	44	49	45	64	56	71	60	77	73	64	58	76	52	58	43	54	66	57	14	11	10	14	15
27838	2013-02-15	66	66	left	medium	medium	73	40	57	61	64	57	68	31	70	63	44	49	45	73	56	75	60	77	73	68	71	76	52	58	43	62	66	57	14	11	10	14	15
27838	2012-08-31	68	68	left	medium	medium	73	40	65	61	64	57	68	31	70	67	44	49	45	73	56	75	60	77	73	68	71	76	52	58	43	66	66	61	14	11	10	14	15
27838	2012-02-22	69	69	left	medium	medium	72	39	64	60	63	56	75	30	69	66	47	54	51	72	55	74	59	76	72	67	70	75	51	57	42	72	70	66	14	11	10	14	15
27838	2011-08-30	68	68	left	medium	medium	71	39	68	69	63	63	70	30	67	68	65	73	57	64	55	67	59	76	72	69	70	66	66	68	42	67	68	66	14	11	10	14	15
27838	2011-02-22	67	71	left	medium	medium	71	39	68	69	58	69	70	30	67	68	55	62	52	64	62	67	71	76	67	69	70	66	66	68	42	65	67	66	14	11	10	14	15
27838	2010-08-30	69	76	left	medium	medium	71	39	68	69	73	69	70	30	67	68	72	73	65	64	67	67	71	76	69	69	70	77	66	68	42	68	69	67	14	11	10	14	15
27838	2009-08-30	68	76	left	medium	medium	71	39	68	69	73	69	70	30	67	68	74	74	65	64	67	67	71	76	69	69	70	80	77	68	74	60	69	67	12	20	67	20	20
27838	2009-02-22	69	76	left	medium	medium	66	39	68	67	73	69	70	30	65	68	74	74	65	64	67	67	71	76	69	69	70	80	77	68	74	60	69	67	12	20	65	20	20
27838	2008-08-30	69	76	left	medium	medium	66	39	68	67	73	69	70	30	65	68	74	74	65	64	67	67	71	76	69	69	70	80	77	68	74	60	69	67	12	20	65	20	20
27838	2007-08-30	68	76	left	medium	medium	66	39	68	67	73	69	70	30	65	68	74	74	65	64	67	67	71	76	69	69	70	80	77	68	74	60	69	67	12	20	65	20	20
27838	2007-02-22	68	76	left	medium	medium	66	39	68	67	73	69	70	74	65	68	74	74	65	64	67	67	71	76	69	69	70	80	77	68	74	60	69	67	12	13	65	8	10
38231	2016-03-03	67	67	right	high	high	62	69	58	69	67	66	72	65	54	68	71	73	64	64	67	70	55	62	65	65	66	55	69	68	68	24	33	36	14	6	10	7	16
38231	2016-01-28	69	69	right	high	high	62	70	58	69	67	70	72	65	54	72	81	83	84	74	73	69	88	82	61	65	79	48	69	69	68	24	33	36	14	6	10	7	16
38231	2013-05-31	69	69	right	high	high	62	70	58	69	67	70	72	65	54	72	81	83	84	74	73	69	88	82	61	65	79	48	69	69	68	24	33	36	14	6	10	7	16
38231	2013-05-17	69	69	right	medium	high	62	70	58	69	67	70	72	65	54	72	81	83	84	74	73	69	88	82	61	65	79	48	69	69	68	24	33	36	14	6	10	7	16
38231	2013-03-28	69	69	right	medium	high	62	70	58	69	67	70	72	65	54	72	81	83	84	74	73	69	88	82	61	65	79	48	69	69	68	24	33	36	14	6	10	7	16
38231	2013-02-15	69	69	right	medium	high	62	70	58	69	67	70	72	65	54	72	81	83	84	74	73	69	88	82	61	65	79	48	69	69	68	24	33	36	14	6	10	7	16
38231	2012-08-31	68	68	right	high	medium	59	70	58	67	64	70	76	65	52	72	80	83	84	71	68	67	87	83	56	63	79	48	67	67	68	24	33	36	14	6	10	7	16
38231	2012-02-22	68	68	right	high	medium	57	64	58	67	61	68	76	65	52	66	80	83	84	71	73	67	87	83	56	62	79	48	65	67	68	24	33	36	14	6	10	7	16
38231	2011-08-30	66	67	right	medium	high	57	64	58	62	61	68	76	69	52	65	85	88	89	71	72	67	91	80	61	62	68	48	65	65	68	24	33	36	14	6	10	7	16
38231	2010-08-30	65	70	right	medium	high	57	62	58	62	61	65	53	46	52	60	81	83	82	72	56	67	80	76	53	62	68	48	65	58	62	24	33	36	14	6	10	7	16
38231	2010-02-22	67	68	right	medium	high	58	68	60	62	61	67	53	46	48	62	82	85	82	71	56	64	80	77	48	61	52	59	60	58	71	24	23	36	21	23	48	23	27
38231	2009-08-30	65	68	right	medium	high	56	67	56	60	61	66	53	46	48	62	80	82	82	68	56	62	80	77	46	56	42	51	58	58	71	24	23	36	21	23	48	23	27
38231	2009-02-22	58	64	right	medium	high	38	62	50	38	61	57	53	43	32	52	75	77	82	62	56	60	80	67	42	52	32	37	50	58	45	24	23	36	1	23	32	23	23
38231	2008-08-30	58	64	right	medium	high	38	62	50	38	61	57	53	43	32	52	75	77	82	62	56	60	80	67	42	52	32	37	50	58	45	24	23	36	1	23	32	23	23
38231	2007-02-22	58	64	right	medium	high	38	62	50	38	61	57	53	43	32	52	75	77	82	62	56	60	80	67	42	52	32	37	50	58	45	24	23	36	1	23	32	23	23
45413	2016-03-24	74	74	left	low	high	66	25	78	66	27	50	76	79	66	60	68	67	48	73	46	85	54	69	85	69	70	73	38	51	69	76	77	74	15	12	8	12	11
45413	2016-03-10	73	73	left	medium	medium	66	25	78	66	27	50	76	79	66	60	68	67	48	73	46	85	54	69	85	69	70	78	38	51	69	81	82	79	15	12	8	12	11
45413	2016-02-04	73	73	left	medium	medium	66	25	78	66	27	50	76	79	66	60	68	67	48	73	46	85	54	69	85	69	70	78	38	51	69	81	82	79	15	12	8	12	11
45413	2015-09-21	73	73	left	medium	medium	66	25	78	66	27	50	76	79	66	60	68	67	48	73	46	85	54	69	85	69	70	78	38	51	69	81	82	79	15	12	8	12	11
45413	2015-07-03	71	74	left	medium	medium	69	24	74	60	26	47	75	75	69	57	54	54	48	67	46	80	54	73	83	68	69	77	37	50	63	77	79	75	14	11	7	11	10
45413	2015-04-10	71	74	left	medium	medium	69	24	74	60	26	47	75	75	69	57	54	54	48	67	46	80	54	73	83	68	69	77	37	50	63	77	79	75	14	11	7	11	10
45413	2015-03-13	70	73	left	medium	medium	69	24	72	60	26	47	75	73	64	57	50	54	48	67	46	76	54	70	81	68	69	77	37	50	63	77	77	73	14	11	7	11	10
45413	2015-02-27	70	73	left	medium	medium	64	24	72	60	26	47	75	71	64	57	50	54	48	67	46	76	54	70	81	65	69	77	37	50	63	77	77	73	14	11	7	11	10
45413	2015-02-13	70	73	left	medium	medium	64	24	72	60	26	47	75	71	64	57	50	54	48	67	46	71	54	70	81	65	69	77	37	50	63	77	77	73	14	11	7	11	10
45413	2015-02-06	71	75	left	medium	medium	49	24	71	55	26	41	75	68	59	51	50	54	48	64	46	71	54	66	81	65	68	76	37	48	63	77	77	73	14	11	7	11	10
45413	2014-11-28	71	75	left	medium	medium	49	24	71	55	26	41	75	68	59	51	50	54	48	64	46	71	54	66	81	65	68	76	37	48	63	77	77	73	14	11	7	11	10
45413	2014-10-31	70	75	left	medium	medium	49	24	71	59	26	41	75	68	67	51	49	54	45	64	43	71	49	66	81	65	68	76	37	48	63	73	75	69	14	11	7	11	10
45413	2014-10-02	70	75	left	medium	medium	49	24	71	59	26	41	75	68	67	51	49	54	45	64	43	71	49	66	81	65	68	76	37	58	63	73	75	69	14	11	7	11	10
45413	2014-09-18	70	75	left	medium	medium	54	34	71	59	31	41	75	73	67	51	49	54	45	64	43	71	49	66	81	65	68	76	42	58	68	73	75	69	14	11	7	11	10
45413	2014-03-07	70	71	left	medium	medium	65	35	71	67	32	55	76	74	70	66	51	53	45	67	42	72	49	66	82	65	69	70	43	59	69	70	71	67	15	12	8	12	11
45413	2014-02-07	70	71	left	medium	medium	65	35	71	67	32	55	74	72	70	66	51	53	45	67	42	72	49	66	82	65	69	70	43	59	69	70	71	67	15	12	8	12	11
45413	2013-10-18	70	71	left	medium	medium	65	35	71	67	32	55	69	72	70	66	51	53	45	67	42	72	49	66	82	65	69	70	43	59	69	70	71	67	15	12	8	12	11
45413	2013-09-20	70	72	left	medium	medium	65	35	71	67	32	55	67	72	70	66	51	53	45	67	42	72	49	66	82	65	69	70	43	59	69	70	71	67	15	12	8	12	11
45413	2013-05-17	70	72	left	medium	medium	65	35	71	67	32	55	67	72	70	66	51	55	45	67	42	72	54	66	82	65	69	70	43	59	69	70	71	67	15	12	8	12	11
45413	2013-03-15	70	72	left	medium	medium	65	35	71	67	32	55	67	72	70	66	51	55	45	67	42	72	54	66	82	65	69	70	43	59	69	70	71	67	15	12	8	12	11
45413	2013-02-15	69	72	left	medium	medium	62	35	68	67	32	55	67	72	69	66	51	55	58	66	50	70	54	67	82	65	70	69	43	57	67	69	70	66	15	12	8	12	11
45413	2012-08-31	69	74	left	medium	medium	50	35	68	65	32	57	66	69	63	66	56	53	57	66	47	70	57	67	82	59	70	69	43	57	67	69	68	66	15	12	8	12	11
45413	2012-02-22	66	67	left	medium	medium	50	35	67	64	32	57	56	45	62	63	56	53	57	64	51	65	57	71	80	46	66	64	43	57	63	64	66	62	15	12	8	12	11
45413	2011-08-30	66	67	left	medium	medium	50	35	67	64	32	57	56	45	62	63	56	54	57	64	51	65	57	71	81	46	66	64	43	57	63	64	66	62	15	12	8	12	11
45413	2011-02-22	63	66	left	medium	medium	46	27	67	58	24	37	35	34	56	53	58	63	48	60	71	55	62	68	76	29	66	62	43	57	46	60	62	58	15	12	8	12	11
45413	2010-08-30	60	66	left	medium	medium	46	27	60	58	24	37	35	34	56	51	58	63	48	60	71	55	62	68	76	29	66	60	43	56	46	57	60	58	15	12	8	12	11
45413	2009-02-22	60	66	left	medium	medium	46	27	60	58	24	37	35	34	56	51	58	63	48	60	71	55	62	68	76	29	66	60	43	56	46	57	60	58	15	12	8	12	11
45413	2007-02-22	60	66	left	medium	medium	46	27	60	58	24	37	35	34	56	51	58	63	48	60	71	55	62	68	76	29	66	60	43	56	46	57	60	58	15	12	8	12	11
38435	2016-05-05	74	74	right	medium	low	74	68	48	74	72	74	76	77	75	77	68	68	72	72	74	75	66	63	56	78	54	63	74	73	73	47	57	52	11	12	8	7	13
38435	2015-09-21	74	74	right	medium	low	74	68	48	74	72	74	76	77	75	77	68	68	72	72	74	75	66	63	56	78	54	63	74	73	73	47	57	52	11	12	8	7	13
38435	2015-07-03	72	72	right	medium	low	73	67	47	73	71	73	75	76	74	75	71	69	72	70	74	70	66	66	52	76	53	62	72	72	72	46	56	51	10	11	7	6	12
38435	2015-03-06	72	72	right	medium	low	73	67	47	73	71	73	75	76	74	75	71	69	72	70	74	70	66	66	52	76	53	62	72	72	72	46	56	51	10	11	7	6	12
38435	2014-09-18	72	72	right	medium	low	73	67	47	73	71	73	75	76	74	75	71	69	72	70	74	70	66	66	52	76	53	62	72	72	72	46	56	51	10	11	7	6	12
38435	2014-04-04	72	72	right	medium	low	73	67	47	73	71	73	75	76	74	75	71	69	72	70	74	70	66	70	54	76	53	62	72	72	72	46	56	51	10	11	7	6	12
38435	2014-03-28	73	73	right	medium	low	74	67	47	74	71	73	75	76	75	76	71	69	72	70	74	70	66	70	54	76	53	64	72	74	72	46	56	51	10	11	7	6	12
38435	2013-12-20	73	73	right	medium	low	74	67	47	74	71	73	75	76	75	76	71	69	72	70	74	70	66	70	54	76	53	64	72	74	72	46	56	51	10	11	7	6	12
38435	2013-12-06	73	74	right	medium	low	74	67	47	74	71	73	75	76	75	76	71	69	72	70	74	70	66	70	54	76	53	64	72	74	72	46	56	51	10	11	7	6	12
38435	2013-11-01	73	75	right	medium	medium	74	67	47	74	71	73	75	76	75	76	71	69	72	68	74	70	66	70	54	76	53	64	68	74	72	46	56	51	10	11	7	6	12
38435	2013-09-20	73	75	right	medium	medium	74	67	47	74	71	73	75	76	75	76	71	69	72	68	74	70	66	70	54	76	53	64	68	74	72	46	56	51	10	11	7	6	12
38435	2013-07-05	72	75	right	medium	medium	74	67	47	74	66	73	75	76	75	74	71	70	72	68	74	75	65	70	51	76	53	64	68	74	72	46	56	51	10	11	7	6	12
38435	2013-02-15	72	75	right	medium	medium	74	67	47	74	66	73	75	76	75	74	71	70	72	68	74	75	65	70	51	76	53	64	68	74	72	46	56	51	10	11	7	6	12
38435	2012-08-31	70	71	right	medium	medium	72	56	47	73	66	71	69	72	74	73	66	56	73	66	74	68	65	67	51	71	53	64	66	73	64	46	56	51	10	11	7	6	12
38435	2012-02-22	65	71	right	medium	low	71	56	46	70	66	71	69	72	72	72	68	55	74	63	79	68	65	62	50	71	46	51	61	69	64	32	39	37	10	11	7	6	12
38435	2011-08-30	68	71	right	medium	low	71	56	46	72	66	71	69	72	70	72	68	56	74	63	79	68	65	62	49	71	46	51	61	69	64	32	39	37	10	11	7	6	12
38435	2011-02-22	68	71	right	medium	low	71	56	46	72	66	71	69	72	70	72	66	64	67	63	42	68	62	65	39	71	46	47	66	69	64	32	39	37	10	11	7	6	12
38435	2010-08-30	69	72	right	medium	low	71	61	51	72	66	71	69	72	70	72	66	64	67	65	42	72	62	67	49	71	46	51	68	71	64	42	39	37	10	11	7	6	12
38435	2010-02-22	68	72	right	medium	low	71	61	51	72	66	71	69	72	70	72	66	64	67	65	42	72	62	67	49	71	46	58	64	71	63	42	39	37	7	21	70	21	21
38435	2009-08-30	69	72	right	medium	low	71	61	52	72	66	71	69	72	70	73	67	65	67	68	42	75	62	69	55	71	54	58	65	71	64	42	39	37	7	21	70	21	21
38435	2009-02-22	67	75	left	medium	low	69	61	57	72	66	71	69	72	70	71	65	65	67	66	42	65	62	71	57	71	56	58	63	71	64	46	45	37	12	21	70	21	21
38435	2008-08-30	69	75	left	medium	low	71	62	57	74	66	72	69	74	72	72	67	67	67	69	42	65	62	71	60	72	56	58	63	71	64	51	50	37	12	21	72	21	21
38435	2007-08-30	73	75	left	medium	low	71	62	57	76	66	75	69	72	74	75	79	76	67	72	42	65	62	82	60	72	56	58	63	71	64	51	53	37	12	21	74	21	21
38435	2007-02-22	56	59	right	medium	low	69	44	55	52	66	55	69	58	57	52	65	69	67	57	42	59	62	71	55	43	59	58	63	71	58	61	58	37	12	12	57	12	12
38786	2015-01-09	65	65	right	high	medium	60	56	68	64	60	69	63	62	64	66	66	72	71	64	54	67	60	85	71	64	61	57	70	65	58	37	47	48	8	15	5	6	14
38786	2014-11-28	66	66	right	high	medium	60	56	58	64	60	69	63	62	64	66	66	72	71	64	54	67	60	85	71	64	61	27	70	65	58	27	37	38	8	15	5	6	14
38786	2014-11-14	66	66	right	high	medium	60	56	58	64	60	69	63	62	64	66	66	72	71	64	54	67	60	85	71	64	61	27	70	65	58	27	37	38	8	15	5	6	14
38786	2014-03-14	66	66	right	high	medium	60	56	58	64	60	69	63	62	64	66	66	72	71	64	54	67	60	85	71	64	61	27	70	65	58	27	37	38	8	15	5	6	14
38786	2014-02-07	66	66	right	high	medium	60	56	58	64	60	69	63	62	64	67	66	72	71	64	54	67	60	85	71	64	61	27	70	65	58	27	37	38	8	15	5	6	14
38786	2014-01-10	66	66	right	high	medium	60	56	58	64	60	69	63	62	64	67	66	72	71	64	54	67	60	85	71	64	61	27	70	65	58	27	37	38	8	15	5	6	14
38786	2013-09-20	67	69	right	high	medium	60	58	58	66	60	69	63	62	64	68	67	72	73	66	54	68	60	85	71	65	61	27	72	65	58	27	37	38	8	15	5	6	14
38786	2012-08-31	67	69	right	high	medium	60	58	58	66	60	69	63	62	64	68	67	72	73	66	54	68	60	85	71	65	61	27	72	65	58	27	37	38	8	15	5	6	14
38786	2012-02-22	69	71	right	high	medium	64	68	66	68	63	69	63	62	65	73	67	72	73	66	56	72	69	85	71	70	61	27	72	65	64	27	37	38	8	15	5	6	14
38786	2011-08-30	69	71	right	high	medium	64	68	66	68	63	69	63	62	65	72	67	72	73	66	56	72	69	85	71	70	61	27	72	65	64	27	37	38	8	15	5	6	14
38786	2011-02-22	69	72	right	high	medium	62	69	66	67	63	68	63	62	64	73	66	71	73	67	62	71	65	80	67	70	61	46	74	67	64	43	53	54	8	15	5	6	14
38786	2010-08-30	70	72	right	high	medium	64	71	66	68	63	73	63	62	65	77	66	71	73	67	62	69	65	83	67	67	61	46	74	67	64	43	53	54	8	15	5	6	14
38786	2010-02-22	70	72	right	high	medium	64	71	66	68	63	73	63	62	65	77	66	71	73	67	62	69	65	83	67	67	61	59	70	67	73	43	53	54	15	21	65	21	21
38786	2009-08-30	68	72	right	high	medium	64	66	64	66	63	73	63	62	65	77	66	71	73	67	62	69	65	83	67	64	61	59	57	67	71	43	53	54	15	21	65	21	21
38786	2009-02-22	67	72	right	high	medium	64	63	64	66	63	73	63	62	65	77	66	71	73	67	62	69	65	83	67	64	61	59	57	67	71	43	53	54	15	21	65	21	21
38786	2008-08-30	68	73	right	high	medium	66	65	65	68	63	73	63	62	65	78	68	73	73	68	62	67	65	85	67	64	66	59	57	67	71	43	53	54	15	21	65	21	21
38786	2007-08-30	72	73	right	high	medium	66	65	65	68	63	73	63	62	65	78	68	73	73	68	62	67	65	85	67	64	66	59	57	67	71	43	53	54	15	21	65	21	21
38786	2007-02-22	65	71	right	high	medium	67	72	65	66	63	70	63	69	59	66	76	75	73	63	62	64	65	69	64	58	61	59	57	67	69	43	52	54	15	8	59	7	13
129462	2016-01-07	73	73	left	medium	medium	43	24	76	67	26	52	33	31	64	63	62	65	53	70	46	76	70	50	86	58	80	69	26	38	52	72	75	71	13	16	14	12	15
129462	2015-11-06	73	73	left	medium	medium	43	24	76	67	26	52	33	31	64	63	62	65	53	70	46	78	70	50	86	62	80	69	26	38	52	72	75	71	13	16	14	12	15
129462	2015-09-21	74	74	left	medium	medium	43	24	77	69	26	52	33	31	65	63	62	65	53	70	46	78	71	50	86	62	81	69	26	38	52	73	76	72	13	16	14	12	15
129462	2014-09-18	72	75	left	medium	medium	42	23	76	60	25	51	32	30	62	62	63	65	55	69	37	63	71	50	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2014-01-31	72	75	left	medium	medium	42	23	76	60	25	51	32	30	62	62	65	73	56	69	37	63	71	50	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2013-11-15	72	72	left	medium	medium	42	23	76	60	25	51	32	30	62	62	65	73	56	69	37	63	71	50	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2013-10-25	72	75	left	medium	medium	42	23	76	60	25	51	32	30	62	62	67	75	57	69	37	63	71	72	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2013-09-20	72	76	left	medium	medium	42	23	76	60	25	51	32	30	62	62	67	75	57	69	37	63	71	72	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2013-04-12	72	76	left	medium	medium	42	23	76	60	25	57	32	30	62	62	67	75	57	69	37	63	71	72	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2013-02-15	72	76	left	medium	medium	42	23	76	60	25	57	32	30	62	62	67	75	57	69	37	63	71	72	86	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2012-08-31	72	76	left	medium	medium	42	23	76	60	25	57	32	30	62	62	67	75	57	69	37	63	71	72	85	35	82	68	25	37	51	70	73	69	12	15	13	11	14
129462	2012-02-22	70	72	left	medium	medium	42	23	72	59	25	54	32	30	62	62	64	69	52	65	35	63	64	67	84	35	82	67	25	24	51	68	72	67	12	15	13	11	14
129462	2011-08-30	67	70	left	medium	medium	42	23	65	59	25	54	32	30	52	64	55	65	34	65	36	63	64	67	84	35	74	67	25	21	51	64	68	62	12	15	13	11	14
129462	2011-02-22	67	69	left	medium	medium	42	33	65	59	25	42	32	30	52	65	57	67	43	66	67	63	69	65	72	35	74	69	45	61	51	65	69	62	12	15	13	11	14
129462	2010-08-30	67	69	left	medium	medium	42	33	65	59	25	42	32	30	55	65	57	67	43	66	67	63	69	65	72	35	74	69	45	61	51	65	69	62	12	15	13	11	14
129462	2010-02-22	67	69	left	medium	medium	42	33	65	59	25	42	32	30	55	65	57	67	43	66	67	63	69	65	72	35	74	38	60	61	32	65	69	62	7	22	55	22	22
129462	2009-08-30	66	69	left	medium	medium	42	33	66	59	25	41	32	30	55	70	72	71	43	66	67	63	69	66	57	35	75	38	60	61	32	68	69	62	7	22	55	22	22
129462	2009-02-22	68	72	left	medium	medium	42	33	66	59	25	41	32	46	55	73	72	71	43	66	67	63	69	66	57	35	65	38	69	61	38	76	69	62	7	22	55	22	22
129462	2008-08-30	68	69	left	medium	medium	42	33	66	59	25	41	32	46	55	73	72	71	43	66	67	63	69	66	57	35	65	38	69	61	38	76	69	62	7	22	55	22	22
129462	2007-02-22	68	69	left	medium	medium	42	33	66	59	25	41	32	46	55	73	72	71	43	66	67	63	69	66	57	35	65	38	69	61	38	76	69	62	7	22	55	22	22
166554	2016-04-21	66	66	left	medium	medium	64	26	60	63	44	63	58	57	56	63	73	72	73	64	86	55	84	90	72	33	66	62	33	56	48	63	63	64	12	13	5	15	14
166554	2016-04-07	66	67	left	medium	medium	64	26	60	63	44	63	58	57	56	63	73	72	73	64	86	55	84	90	72	33	66	62	33	56	48	63	63	64	12	13	5	15	14
166554	2015-09-25	66	67	left	medium	medium	64	26	60	63	44	63	58	57	56	63	73	72	73	64	86	55	84	90	72	33	66	62	33	56	48	63	63	64	12	13	5	15	14
166554	2015-09-21	66	67	left	medium	medium	64	26	60	63	44	63	58	57	56	63	73	72	73	64	86	55	84	86	72	33	66	62	33	56	48	63	63	64	12	13	5	15	14
166554	2015-07-03	59	64	left	medium	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	32	31	47	59	60	60	11	12	4	14	13
166554	2015-06-12	59	64	left	medium	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	32	31	47	59	60	60	11	12	4	14	13
166554	2015-05-01	59	64	left	medium	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	32	31	47	59	60	60	11	12	4	14	13
166554	2014-11-14	63	68	left	high	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	32	31	47	59	60	60	11	12	4	14	13
166554	2014-11-07	63	68	left	high	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	32	31	47	59	60	60	11	12	4	14	13
166554	2014-10-31	63	68	left	high	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	42	31	47	59	60	60	11	12	4	14	13
166554	2014-10-17	63	68	left	high	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	65	61	42	35	47	59	60	60	11	12	4	14	13
166554	2014-09-18	63	68	left	high	medium	63	25	59	59	43	62	57	56	55	62	72	72	72	63	86	54	81	84	70	32	67	61	42	45	47	59	60	60	11	12	4	14	13
166554	2014-04-18	64	70	left	high	medium	64	26	60	60	44	63	58	57	56	63	72	69	72	64	86	55	81	79	70	33	68	62	43	46	48	60	61	61	12	13	5	15	14
166554	2014-03-21	64	70	left	high	medium	64	26	60	60	44	62	47	57	56	62	72	69	72	64	86	55	81	79	70	33	68	62	43	46	48	60	61	61	12	13	5	15	14
166554	2013-11-01	62	67	left	high	medium	58	26	60	58	33	55	33	52	54	57	71	61	72	64	86	55	81	70	70	33	68	62	40	46	48	60	61	61	12	13	5	15	14
166554	2013-09-20	62	67	left	high	medium	58	26	60	58	33	55	33	52	54	57	71	61	72	64	86	55	81	70	70	33	68	62	40	46	48	60	61	61	12	13	5	15	14
166554	2012-08-31	62	67	left	high	medium	58	26	60	58	33	55	33	52	54	60	71	61	70	64	85	55	80	68	68	33	68	62	40	46	48	60	61	61	12	13	5	15	14
166554	2012-02-22	60	69	left	high	medium	56	24	58	56	31	53	31	50	52	58	69	59	70	62	79	53	73	66	65	31	66	60	38	44	46	58	59	59	12	13	5	15	14
166554	2011-08-30	62	77	left	high	medium	58	26	60	58	33	55	33	52	54	60	71	61	70	64	77	55	74	68	67	33	68	62	40	46	48	60	61	61	12	13	5	15	14
166554	2011-02-22	63	69	left	high	medium	60	26	60	60	33	55	33	52	55	60	71	71	69	68	66	55	65	70	66	33	70	62	40	46	48	62	63	62	12	13	5	15	14
166554	2010-08-30	59	69	left	high	medium	60	26	53	50	33	42	33	52	42	53	71	67	69	65	64	55	65	68	56	33	64	68	40	46	48	54	57	59	12	13	5	15	14
166554	2009-02-22	59	69	left	high	medium	60	26	53	50	33	42	33	52	42	53	71	67	69	65	64	55	65	68	56	33	64	68	40	46	48	54	57	59	12	13	5	15	14
166554	2008-08-30	51	69	left	high	medium	60	26	53	50	33	21	33	52	31	53	47	64	69	65	64	21	65	68	62	21	64	38	30	46	33	44	41	59	12	13	31	15	14
166554	2007-02-22	51	69	left	high	medium	60	26	53	50	33	21	33	52	31	53	47	64	69	65	64	21	65	68	62	21	64	38	30	46	33	44	41	59	12	13	31	15	14
131531	2016-03-24	72	72	right	medium	low	74	64	35	78	64	67	73	71	76	73	61	58	69	71	77	66	59	62	45	72	37	52	72	82	72	22	33	30	8	10	11	10	11
131531	2015-09-21	73	73	right	medium	low	74	64	35	78	64	67	73	71	76	73	61	60	69	71	77	66	59	62	45	72	37	52	72	82	72	22	33	30	8	10	11	10	11
131531	2015-04-10	70	70	right	medium	high	72	63	34	74	63	66	72	70	73	71	62	60	65	66	72	65	57	63	45	70	36	51	69	80	71	21	32	29	7	9	10	9	10
131531	2015-01-23	71	71	right	medium	high	73	64	36	75	66	67	72	70	74	72	64	61	66	67	74	68	58	64	45	72	41	51	69	81	71	33	42	39	7	9	10	9	10
131531	2014-12-05	71	71	right	medium	high	73	64	36	75	66	67	72	70	74	72	64	61	66	67	74	68	58	64	45	72	41	51	69	81	71	33	42	39	7	9	10	9	10
131531	2014-09-18	72	72	right	medium	high	74	66	36	76	66	67	73	71	75	72	66	63	71	70	78	69	63	66	46	73	41	56	70	81	72	33	42	39	7	9	10	9	10
131531	2014-05-16	72	72	right	medium	high	74	66	36	76	66	67	73	71	75	72	66	64	71	70	78	69	63	66	46	73	41	56	70	81	72	33	42	39	7	9	10	9	10
131531	2014-03-28	72	72	right	medium	high	74	66	36	76	66	67	73	71	75	72	66	64	71	70	78	69	63	66	46	73	41	56	70	81	72	33	42	39	7	9	10	9	10
131531	2014-02-28	72	72	right	medium	high	74	66	36	76	66	67	73	71	75	72	66	64	71	70	78	69	63	66	46	73	41	56	70	81	72	33	42	39	7	9	10	9	10
131531	2014-01-31	72	72	right	medium	high	74	66	36	76	66	67	73	71	75	72	66	64	71	70	78	69	63	66	46	73	41	56	70	81	72	33	42	39	7	9	10	9	10
131531	2013-11-15	72	72	right	medium	high	74	66	36	76	66	67	73	71	75	72	66	64	71	70	78	69	63	66	46	73	41	56	70	81	72	33	42	39	7	9	10	9	10
131531	2013-09-20	73	73	right	medium	high	74	66	36	76	66	67	73	71	75	73	66	65	71	70	78	69	64	66	46	73	46	56	70	82	72	33	42	39	7	9	10	9	10
131531	2013-02-15	74	74	right	medium	high	77	67	36	78	66	67	73	72	76	74	66	66	72	73	78	69	64	67	36	73	46	57	70	82	72	33	42	39	7	9	10	9	10
131531	2012-08-31	73	73	right	medium	high	77	64	36	78	66	67	73	72	76	72	66	68	72	72	77	68	64	67	36	71	46	57	68	82	72	33	42	39	7	9	10	9	10
131531	2012-02-22	72	73	right	medium	medium	77	64	36	78	66	67	73	72	76	72	66	68	72	70	77	68	64	67	36	71	46	57	66	82	59	33	42	39	7	9	10	9	10
131531	2011-08-30	73	75	right	medium	medium	76	64	36	79	66	69	73	72	77	72	66	68	72	72	78	68	64	67	37	71	46	58	68	83	59	33	42	39	7	9	10	9	10
131531	2011-02-22	71	78	right	medium	medium	74	62	47	77	66	70	73	72	76	72	69	67	71	72	42	67	65	74	37	70	57	62	68	83	59	45	47	48	7	9	10	9	10
131531	2010-08-30	72	78	right	medium	medium	76	63	47	78	66	70	73	72	77	73	72	70	73	71	57	67	65	76	53	71	57	63	69	84	59	45	47	48	7	9	10	9	10
131531	2010-02-22	74	78	right	medium	medium	76	60	47	78	66	70	73	69	77	73	72	72	73	71	57	67	65	79	52	68	57	74	70	84	71	45	47	48	11	21	77	21	21
131531	2009-08-30	71	74	right	medium	medium	73	53	36	74	66	67	73	68	72	67	73	73	73	67	57	65	65	80	46	66	57	68	64	84	65	42	48	48	11	21	72	21	21
131531	2009-02-22	66	69	right	medium	medium	68	53	36	70	66	62	73	62	69	61	73	72	73	66	57	64	65	70	46	56	51	54	56	84	57	32	38	48	11	21	69	21	21
131531	2008-08-30	57	63	right	medium	medium	52	54	36	49	66	64	73	52	43	62	67	71	73	64	57	60	65	57	43	56	52	49	54	84	48	32	38	48	11	21	43	21	21
131531	2007-02-22	57	63	right	medium	medium	52	54	36	49	66	64	73	52	43	62	67	71	73	64	57	60	65	57	43	56	52	49	54	84	48	32	38	48	11	21	43	21	21
37854	2015-09-25	68	68	right	medium	medium	15	15	13	37	12	15	13	19	37	34	47	38	44	66	47	34	60	21	63	13	17	16	14	18	26	13	10	17	71	66	73	65	72
37854	2015-09-21	68	68	right	medium	medium	15	15	13	37	12	15	13	19	37	34	47	38	44	66	47	34	60	21	63	13	17	16	14	8	26	13	10	17	71	66	73	65	72
37854	2014-04-11	68	68	right	medium	medium	15	15	13	37	12	15	13	19	37	34	47	38	44	66	47	34	60	21	63	13	17	16	14	8	26	13	10	17	71	66	73	65	72
37854	2013-09-20	68	68	right	medium	medium	15	15	13	37	12	15	13	19	37	34	47	38	44	66	47	34	60	21	63	13	17	16	14	8	26	13	10	17	71	66	73	65	72
37854	2013-05-10	68	68	right	medium	medium	14	14	12	37	11	14	12	18	37	34	61	58	56	66	57	50	71	32	63	12	16	20	13	7	26	12	9	16	71	66	73	65	72
37854	2013-04-12	67	68	right	medium	medium	14	14	12	37	11	14	12	18	37	34	61	58	56	66	57	50	71	32	63	12	16	20	13	7	26	12	9	16	71	62	73	66	70
37854	2013-03-22	67	68	right	medium	medium	14	14	12	37	11	14	12	18	37	34	61	58	56	66	57	50	71	32	68	12	16	20	13	31	26	12	9	16	71	62	73	66	70
37854	2013-02-15	66	67	right	medium	medium	14	14	12	37	11	14	12	18	37	34	61	58	56	66	57	50	71	32	68	12	16	20	13	31	26	12	9	16	70	60	73	65	69
37854	2012-08-31	67	69	right	medium	medium	14	14	12	37	11	14	12	18	37	34	61	63	58	66	57	50	71	32	68	12	16	20	13	31	26	12	9	16	70	63	73	65	69
37854	2012-02-22	67	69	right	medium	medium	14	11	12	52	24	17	12	18	51	31	61	63	58	66	64	50	71	42	68	12	16	20	13	58	26	12	9	16	70	63	73	65	69
37854	2011-08-30	65	68	right	medium	medium	14	11	12	35	14	18	12	18	31	25	59	58	57	66	64	34	66	59	64	12	16	20	13	37	26	12	9	16	65	64	73	64	67
37854	2011-02-22	61	68	right	medium	medium	14	11	12	10	14	18	12	8	11	17	56	65	61	60	58	45	63	51	64	12	66	19	13	37	33	12	11	16	61	60	62	62	61
37854	2010-08-30	61	68	right	medium	medium	9	11	12	10	9	18	12	25	11	17	56	65	61	60	58	45	63	67	64	12	66	19	13	65	33	12	6	42	61	60	62	62	61
37854	2009-08-30	61	68	right	medium	medium	23	23	23	23	9	23	12	25	62	23	56	65	61	53	58	45	63	67	71	23	66	63	11	65	62	23	23	42	61	60	62	62	61
37854	2008-08-30	61	68	right	medium	medium	23	23	23	23	9	23	12	25	62	23	56	65	61	53	58	45	63	67	71	23	66	63	11	65	62	23	23	42	61	60	62	62	61
37854	2007-08-30	62	68	right	medium	medium	23	23	23	23	9	23	12	25	62	23	56	65	61	53	58	45	63	67	71	23	66	63	11	65	62	23	23	42	61	60	62	62	61
37854	2007-02-22	56	62	right	medium	medium	9	11	12	10	9	18	12	62	55	17	56	65	61	53	58	45	63	67	71	12	66	63	11	65	62	12	6	42	52	53	55	55	53
131406	2012-08-31	68	70	right	medium	medium	51	30	70	60	38	46	70	73	55	55	39	45	48	68	41	73	56	53	78	60	61	67	40	50	49	70	71	68	13	12	14	7	15
131406	2012-02-22	66	68	right	medium	medium	51	30	70	51	38	46	48	62	55	55	50	55	51	63	41	67	55	63	78	60	61	67	36	49	45	66	69	68	13	12	14	7	15
131406	2008-08-30	66	68	right	medium	medium	51	30	70	51	38	46	48	62	55	55	50	55	51	63	41	67	55	63	78	60	61	67	36	49	45	66	69	68	13	12	14	7	15
131406	2007-08-30	59	68	right	medium	medium	50	30	70	53	38	46	48	45	46	55	50	55	51	63	41	26	55	63	67	36	61	44	42	49	45	56	56	68	13	12	46	7	15
131406	2007-02-22	59	68	right	medium	medium	50	30	70	53	38	46	48	45	46	55	50	55	51	63	41	26	55	63	67	36	61	44	42	49	45	56	56	68	13	12	46	7	15
39594	2010-02-22	64	68	right	\N	\N	64	56	65	63	\N	58	\N	55	56	63	57	63	\N	62	\N	66	\N	69	68	59	73	62	63	\N	66	62	64	\N	11	25	56	25	25
39594	2009-08-30	66	68	right	\N	\N	64	57	66	59	\N	62	\N	55	54	64	66	68	\N	66	\N	70	\N	69	63	59	79	64	63	\N	68	65	67	\N	1	25	54	25	25
39594	2008-08-30	66	68	right	\N	\N	63	57	61	66	\N	62	\N	55	61	64	66	68	\N	66	\N	70	\N	69	63	59	79	64	63	\N	68	65	67	\N	1	25	61	25	25
39594	2007-08-30	66	68	right	\N	\N	63	57	61	66	\N	62	\N	55	61	64	66	68	\N	66	\N	70	\N	69	63	59	79	64	63	\N	68	65	67	\N	1	25	61	25	25
39594	2007-02-22	66	68	right	\N	\N	63	57	61	66	\N	62	\N	68	61	64	66	68	\N	66	\N	70	\N	69	63	59	79	64	63	\N	68	65	67	\N	1	1	61	1	1
38252	2008-08-30	68	71	right	\N	\N	22	20	20	53	\N	35	\N	17	68	40	35	35	\N	72	\N	63	\N	60	67	25	53	55	17	\N	50	20	42	\N	68	67	68	69	69
38252	2007-02-22	68	71	right	\N	\N	22	20	20	53	\N	35	\N	17	68	40	35	35	\N	72	\N	63	\N	60	67	25	53	55	17	\N	50	20	42	\N	68	67	68	69	69
39156	2008-08-30	62	65	right	\N	\N	54	40	61	65	\N	54	\N	48	59	60	47	52	\N	54	\N	48	\N	61	53	49	58	63	59	\N	62	67	69	\N	9	23	59	23	23
39156	2007-08-30	64	65	right	\N	\N	54	40	61	65	\N	54	\N	48	59	60	47	52	\N	54	\N	48	\N	61	53	49	58	63	59	\N	62	67	69	\N	9	23	59	23	23
39156	2007-02-22	64	65	right	\N	\N	54	40	61	65	\N	54	\N	62	59	60	47	52	\N	54	\N	48	\N	61	53	49	58	63	59	\N	62	67	69	\N	9	5	59	8	12
37051	2014-12-12	62	62	right	high	high	62	66	68	66	63	58	61	63	63	60	55	68	61	55	62	65	59	86	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2014-10-02	63	63	right	high	high	65	66	68	66	63	58	61	63	63	63	55	68	61	60	62	65	59	86	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2014-09-18	63	63	right	high	high	65	66	68	66	63	58	61	63	63	63	55	68	61	60	62	65	59	86	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2014-03-21	63	63	right	high	high	65	66	68	66	63	58	61	63	63	63	57	68	61	60	62	65	60	85	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2013-12-27	63	63	right	high	high	65	66	68	66	63	58	61	63	63	63	57	68	61	60	62	65	60	85	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2013-11-29	64	64	right	high	high	65	66	68	66	63	58	61	63	63	65	57	70	63	64	62	65	62	85	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2013-11-15	63	63	right	high	high	65	66	68	66	63	58	61	63	63	65	53	62	63	64	62	65	62	85	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2013-09-20	64	64	right	high	high	65	66	68	66	63	58	61	63	63	65	53	62	63	64	62	65	62	85	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2013-05-10	64	64	right	high	high	65	66	68	66	63	58	61	63	63	65	53	63	63	64	62	65	62	85	61	67	53	63	68	68	64	60	60	61	5	14	13	9	5
37051	2013-03-04	64	64	right	high	high	61	66	68	66	63	55	61	63	63	65	53	63	63	64	62	65	62	85	61	67	53	63	68	68	64	60	63	61	5	14	13	9	5
37051	2013-02-15	64	64	right	high	high	61	66	68	66	63	55	61	63	63	65	53	63	63	64	62	65	62	85	61	67	53	63	68	68	64	60	63	61	5	14	13	9	5
37051	2012-08-31	64	64	right	high	high	61	66	68	66	63	55	61	63	63	65	53	65	63	64	61	65	62	85	58	67	53	63	68	68	64	60	63	61	5	14	13	9	5
37051	2012-02-22	66	66	right	high	medium	61	66	68	66	63	56	61	63	63	66	51	67	65	65	67	65	56	89	60	67	53	63	68	72	64	62	65	64	5	14	13	9	5
37051	2011-08-30	65	65	right	high	high	61	66	68	66	63	56	61	63	63	66	51	67	65	65	67	65	56	89	60	67	53	63	68	72	64	62	65	64	5	14	13	9	5
37051	2011-02-22	65	66	right	high	high	61	66	68	66	63	56	61	63	63	66	57	67	63	65	53	65	59	86	58	67	53	63	68	73	64	62	65	64	5	14	13	9	5
37051	2010-08-30	64	66	right	high	high	53	64	68	66	59	53	56	61	63	66	58	68	63	64	53	65	59	83	58	65	51	61	66	73	62	62	65	64	5	14	13	9	5
37051	2010-02-22	64	66	right	high	high	53	64	68	66	59	53	56	61	63	66	58	68	63	64	53	65	59	83	58	65	51	71	69	73	68	62	65	64	18	25	63	25	25
37051	2009-08-30	65	66	right	high	high	68	63	66	66	59	54	56	61	65	64	58	68	63	64	53	65	59	78	58	64	58	68	67	73	66	62	63	64	18	25	65	25	25
37051	2009-02-22	62	67	right	high	high	57	56	61	63	59	53	56	41	54	58	63	68	63	58	53	60	59	73	58	47	68	68	60	73	53	65	61	64	8	25	54	25	25
37051	2008-08-30	62	62	right	high	high	57	56	61	63	59	53	56	41	54	58	63	68	63	58	53	60	59	73	58	47	68	68	60	73	53	65	61	64	8	25	54	25	25
37051	2007-08-30	59	62	right	high	high	57	56	61	63	59	55	56	41	54	59	60	65	63	58	53	60	59	67	45	47	68	68	60	73	53	65	61	64	8	25	54	25	25
37051	2007-02-22	58	62	left	high	high	52	50	61	63	59	55	56	53	54	59	56	57	63	53	53	60	59	67	70	17	68	68	60	73	53	65	61	64	8	7	54	13	10
39157	2009-02-22	54	58	right	\N	\N	40	52	48	48	\N	54	\N	49	40	59	52	62	\N	56	\N	60	\N	57	65	53	52	42	33	\N	34	49	37	\N	21	21	40	20	22
39157	2008-08-30	54	58	right	\N	\N	40	52	48	48	\N	54	\N	49	40	59	52	62	\N	56	\N	60	\N	57	65	53	52	42	33	\N	34	49	37	\N	21	21	40	20	22
39157	2007-02-22	54	58	right	\N	\N	40	52	48	48	\N	54	\N	49	40	59	52	62	\N	56	\N	60	\N	57	65	53	52	42	33	\N	34	49	37	\N	21	21	40	20	22
31226	2011-02-22	65	74	right	\N	\N	15	12	14	45	9	24	22	15	41	37	50	45	57	60	65	44	53	51	67	10	15	23	10	36	39	15	19	11	62	67	65	75	60
31226	2010-08-30	65	74	right	\N	\N	15	12	35	54	23	24	22	15	47	37	50	45	57	60	65	55	53	51	67	10	15	23	10	83	39	15	19	11	62	67	65	75	60
31226	2010-02-22	65	74	right	\N	\N	35	33	35	35	23	24	22	35	63	38	55	47	57	62	65	29	53	51	62	40	62	74	62	83	73	25	39	11	64	65	63	70	63
31226	2009-08-30	65	74	right	\N	\N	35	33	35	35	23	24	22	35	63	47	55	47	57	62	65	29	53	51	62	40	62	74	62	83	73	25	39	11	64	65	63	70	63
31226	2008-08-30	65	74	right	\N	\N	35	33	35	35	23	24	22	35	63	23	52	47	57	62	65	29	53	51	62	40	62	74	62	83	73	25	39	11	64	65	63	70	63
31226	2007-08-30	67	74	right	\N	\N	35	33	35	35	23	24	22	35	64	23	56	53	57	62	65	29	53	56	62	40	62	74	62	83	73	25	39	11	67	65	64	71	67
31226	2007-02-22	74	74	right	\N	\N	35	33	35	35	23	24	22	78	66	23	62	56	57	64	65	29	53	63	70	40	62	74	62	83	78	25	39	11	73	70	66	75	76
104389	2016-03-10	75	77	right	medium	low	76	75	38	72	77	78	70	72	71	74	84	80	76	73	77	82	88	64	71	80	23	21	74	74	81	13	22	19	15	7	16	13	16
104389	2015-09-21	75	76	right	medium	low	76	75	38	72	77	78	70	72	71	74	84	80	76	73	77	82	85	64	71	80	23	21	74	74	81	13	22	19	15	7	16	13	16
104389	2015-05-15	73	75	right	medium	low	76	73	46	71	76	75	69	73	70	73	85	83	77	71	77	81	82	64	68	78	22	26	70	71	78	25	21	25	14	6	15	12	15
104389	2015-05-08	72	74	right	medium	low	76	73	46	71	76	74	69	73	70	73	85	83	77	69	77	81	82	48	68	78	22	26	68	71	75	25	21	25	14	6	15	12	15
104389	2015-04-24	72	75	right	medium	low	76	73	46	71	76	74	69	73	70	73	85	83	77	69	77	81	82	48	68	78	32	26	68	71	75	25	21	25	14	6	15	12	15
104389	2015-04-17	72	75	right	medium	low	76	73	46	71	76	74	69	73	70	73	85	83	77	69	77	81	82	48	68	78	32	26	68	71	70	25	21	25	14	6	15	12	15
104389	2015-03-13	72	75	right	medium	low	72	73	46	71	76	74	69	73	70	73	85	83	77	69	77	81	82	48	68	78	32	26	68	71	70	25	21	25	14	6	15	12	15
104389	2014-11-07	72	75	right	medium	low	72	73	46	71	76	74	69	73	70	73	85	83	77	69	77	81	82	48	68	78	32	26	68	71	70	25	21	25	14	6	15	12	15
104389	2014-09-18	72	75	right	medium	low	72	73	46	71	76	74	69	73	70	73	85	83	77	69	77	81	82	48	68	78	32	26	68	71	70	25	21	25	14	6	15	12	15
104389	2014-05-02	72	75	right	medium	low	72	73	46	71	76	74	69	73	70	73	85	83	77	69	83	81	80	53	68	78	32	26	68	71	70	25	21	25	14	6	15	12	15
104389	2014-03-21	72	75	right	medium	low	72	73	46	71	76	74	69	73	70	73	85	83	77	69	83	81	80	53	68	78	32	26	68	71	70	25	21	25	14	6	15	12	15
104389	2014-03-14	71	74	right	medium	low	71	71	46	71	73	73	69	73	70	72	85	83	77	68	83	81	80	53	68	78	32	26	66	68	70	25	21	25	14	6	15	12	15
104389	2014-03-07	71	74	right	medium	low	71	71	46	71	73	73	69	73	70	72	85	83	77	68	83	81	80	53	68	78	32	26	66	68	70	25	21	25	14	6	15	12	15
104389	2014-01-24	70	74	right	medium	low	70	68	46	66	71	73	68	71	68	72	85	83	77	68	83	80	80	53	68	75	32	26	66	61	64	25	21	25	14	6	15	12	15
104389	2014-01-10	70	74	right	medium	low	70	68	46	66	71	73	68	71	68	72	85	83	77	68	83	80	80	53	68	75	32	26	66	61	64	25	21	25	14	6	15	12	15
104389	2013-12-20	70	74	right	medium	low	70	68	46	66	71	73	68	71	68	72	85	83	77	68	83	80	80	53	68	75	32	26	66	61	64	25	21	25	14	6	15	12	15
104389	2013-11-01	69	73	right	medium	low	70	63	46	66	71	72	68	71	64	71	85	83	77	68	83	78	80	53	68	75	32	26	61	60	64	25	21	25	14	6	15	12	15
104389	2013-09-20	68	73	right	medium	low	65	63	46	66	71	72	68	69	64	71	82	81	77	68	83	78	80	53	68	75	32	26	61	60	64	25	21	25	14	6	15	12	15
104389	2013-05-31	68	73	right	medium	low	65	63	46	66	71	72	68	69	64	71	82	81	77	68	83	78	80	53	68	75	32	26	61	60	64	25	21	25	14	6	15	12	15
104389	2013-04-19	68	73	right	medium	low	65	63	46	66	71	72	68	69	64	71	82	81	77	68	83	78	80	53	68	75	32	26	61	60	64	25	21	25	14	6	15	12	15
104389	2013-03-22	66	73	right	medium	low	64	63	46	64	66	72	67	69	64	68	82	81	77	68	83	78	80	53	68	69	32	26	61	66	64	25	21	25	14	6	15	12	15
104389	2013-03-08	66	73	right	medium	low	64	63	46	64	66	72	67	69	64	68	82	81	77	68	83	78	80	53	68	69	32	26	61	66	64	25	21	25	14	6	15	12	15
104389	2013-02-15	66	73	right	medium	low	64	63	46	64	66	72	67	69	64	68	82	81	77	68	83	78	80	53	68	69	32	26	61	66	64	25	21	25	14	6	15	12	15
104389	2012-08-31	68	73	right	medium	low	67	63	46	66	71	73	68	69	65	71	82	80	81	65	83	78	81	51	68	71	32	26	57	67	64	25	21	25	14	6	15	12	15
104389	2012-02-22	69	74	right	medium	low	69	63	46	68	71	73	68	69	67	71	83	80	82	68	83	78	81	53	68	71	32	26	58	67	64	25	21	25	14	6	15	12	15
104389	2011-08-30	67	75	right	medium	low	64	61	46	63	63	76	64	69	58	71	88	83	85	68	83	73	80	53	71	66	32	26	58	47	64	25	21	25	14	6	15	12	15
104389	2011-02-22	66	77	right	medium	low	66	62	47	66	65	76	62	62	62	73	75	71	69	69	64	72	68	64	65	64	63	46	68	54	64	25	35	32	14	6	15	12	15
104389	2010-08-30	69	77	right	medium	low	66	62	47	66	65	78	62	69	62	75	75	71	69	69	64	74	68	64	65	64	63	46	68	74	64	25	35	32	14	6	15	12	15
104389	2010-02-22	66	76	right	medium	low	65	61	46	65	65	77	62	68	61	74	75	73	69	68	64	73	68	64	64	63	62	45	50	74	65	24	34	32	5	21	61	21	21
104389	2009-08-30	67	77	right	medium	low	66	62	47	66	65	78	62	69	62	75	76	74	69	69	64	74	68	65	65	64	63	46	51	74	66	25	35	32	5	21	62	21	21
104389	2008-08-30	65	77	right	medium	low	66	62	47	66	65	75	62	69	62	72	76	74	69	69	64	72	68	65	65	64	63	46	51	74	66	25	35	32	5	21	62	21	21
104389	2007-02-22	65	77	right	medium	low	66	62	47	66	65	75	62	69	62	72	76	74	69	69	64	72	68	65	65	64	63	46	51	74	66	25	35	32	5	21	62	21	21
38410	2008-08-30	58	61	right	\N	\N	49	48	60	63	\N	46	\N	47	58	53	52	61	\N	51	\N	64	\N	66	76	52	60	65	63	\N	61	46	53	\N	6	20	58	20	20
38410	2007-02-22	58	61	right	\N	\N	49	48	60	63	\N	46	\N	47	58	53	52	61	\N	51	\N	64	\N	66	76	52	60	65	63	\N	61	46	53	\N	6	20	58	20	20
95614	2016-04-21	71	71	right	medium	medium	71	49	65	71	59	60	71	65	72	68	67	61	71	71	74	74	77	78	67	69	74	75	60	68	58	67	72	69	13	16	15	7	14
95614	2016-02-25	71	71	right	medium	medium	71	49	65	71	59	60	71	65	72	68	67	61	71	71	74	74	77	78	67	69	74	75	60	69	58	67	72	69	13	16	15	7	14
95614	2015-09-21	71	71	right	medium	medium	71	49	65	71	59	60	71	65	72	68	67	61	71	71	74	74	77	78	62	69	70	75	60	69	58	67	72	69	13	16	15	7	14
95614	2015-04-17	70	70	right	medium	medium	64	48	64	70	58	59	63	64	71	67	67	65	71	71	74	73	73	78	62	68	70	74	59	68	60	66	69	70	12	15	14	6	13
95614	2015-04-10	69	70	right	medium	medium	64	48	63	68	53	59	63	64	71	66	67	65	71	71	74	73	73	76	62	67	69	73	59	68	60	66	67	70	12	15	14	6	13
95614	2015-02-06	69	69	right	medium	high	67	49	63	68	53	61	68	69	65	66	67	66	71	71	73	73	71	76	62	67	69	75	56	66	67	67	70	69	12	15	14	6	13
95614	2015-01-16	69	69	right	medium	high	67	49	63	68	53	61	68	69	65	66	67	66	71	71	73	67	71	76	62	61	69	75	56	66	67	67	70	69	12	15	14	6	13
95614	2014-09-18	68	70	right	medium	high	67	39	63	67	50	62	68	69	64	65	67	66	71	70	73	60	71	72	61	39	68	72	54	65	42	67	70	69	12	15	14	6	13
95614	2013-11-01	68	70	right	medium	high	67	39	63	67	50	62	68	69	64	65	67	66	71	70	73	60	69	72	61	39	68	72	54	65	42	67	70	69	12	15	14	6	13
95614	2013-09-20	68	70	right	medium	high	67	39	63	67	50	62	53	42	64	65	67	66	71	70	73	60	69	72	61	39	68	72	54	65	42	67	70	69	12	15	14	6	13
95614	2013-06-07	68	70	right	medium	medium	67	39	63	67	50	62	53	42	64	65	67	66	71	70	73	60	67	72	61	39	68	72	54	65	42	67	70	69	12	15	14	6	13
95614	2013-05-10	68	68	right	medium	medium	67	39	63	67	50	62	53	42	64	65	67	66	71	70	73	60	67	72	61	39	68	72	54	65	42	67	70	69	12	15	14	6	13
95614	2013-03-22	67	68	right	medium	medium	67	39	63	65	50	62	53	42	62	65	67	66	71	69	73	60	67	72	61	39	68	71	54	65	42	67	68	69	12	15	14	6	13
95614	2013-03-01	66	67	right	medium	medium	67	39	62	65	50	62	53	42	62	65	67	66	71	69	73	60	67	72	61	39	60	68	54	65	42	67	66	65	12	15	14	6	13
95614	2013-02-15	66	67	right	medium	medium	67	39	62	65	50	62	53	42	62	65	67	66	71	69	73	60	67	72	61	39	60	68	54	65	42	67	66	65	12	15	14	6	13
95614	2012-08-31	65	67	right	medium	medium	67	39	62	65	50	62	53	42	62	65	67	68	71	69	72	60	67	72	58	39	60	68	54	65	42	67	66	65	12	15	14	6	13
95614	2012-02-22	65	67	right	medium	medium	69	39	62	65	50	62	53	42	62	65	67	68	71	69	74	45	67	72	58	39	60	68	38	53	42	67	66	65	12	15	14	6	13
95614	2011-08-30	63	64	right	medium	medium	69	39	62	65	50	62	53	42	60	63	67	68	66	63	77	45	65	66	61	39	52	63	37	56	42	67	66	65	12	15	14	6	13
95614	2011-02-22	64	71	right	medium	medium	69	39	63	65	50	61	49	42	60	63	66	68	64	63	56	45	53	65	53	39	52	63	37	53	42	67	66	65	12	15	14	6	13
95614	2010-08-30	64	71	right	medium	medium	69	39	63	65	50	61	49	42	60	63	66	68	64	63	56	45	53	65	53	39	52	63	37	53	42	67	66	65	12	15	14	6	13
95614	2010-02-22	63	71	right	medium	medium	69	39	63	65	50	61	49	42	60	63	66	68	64	63	56	45	53	65	53	39	52	54	52	53	48	67	66	65	4	23	60	23	23
95614	2009-08-30	63	71	right	medium	medium	69	39	63	60	50	61	49	42	59	63	66	68	64	63	56	45	53	62	65	39	52	54	52	53	48	66	63	65	4	23	59	23	23
95614	2008-08-30	60	69	right	medium	medium	69	48	60	60	50	61	49	42	59	63	63	62	64	62	56	45	53	46	65	39	50	40	46	53	41	65	62	65	2	23	59	23	23
95614	2007-08-30	49	58	right	medium	medium	49	48	41	52	50	55	49	42	46	51	42	48	64	51	56	45	53	46	43	39	47	36	41	53	35	38	40	65	2	23	46	23	23
95614	2007-02-22	49	58	right	medium	medium	49	48	41	52	50	55	49	42	46	51	42	48	64	51	56	45	53	46	43	39	47	36	41	53	35	38	40	65	2	23	46	23	23
104415	2013-03-22	63	66	left	medium	medium	64	46	56	63	51	56	59	56	60	65	65	67	66	62	74	57	65	67	57	52	65	64	56	54	50	63	62	60	9	12	10	14	6
104415	2013-03-01	63	66	left	medium	medium	64	46	56	63	51	56	59	56	60	65	65	67	66	62	74	57	65	67	57	52	65	64	56	54	50	63	62	60	9	12	10	14	6
104415	2013-02-15	63	66	left	medium	medium	64	46	56	63	51	56	59	56	60	65	65	67	66	62	74	57	65	67	57	52	65	64	56	54	50	63	62	60	9	12	10	14	6
104415	2012-02-22	63	66	left	medium	medium	64	46	56	63	51	56	59	56	60	65	65	67	66	62	74	57	65	67	57	52	65	64	56	54	50	63	62	60	9	12	10	14	6
104415	2011-08-30	63	66	left	medium	medium	58	53	56	63	51	59	59	56	60	65	63	66	66	59	74	57	66	67	56	52	52	53	56	54	47	53	56	57	9	12	10	14	6
104415	2010-08-30	59	65	left	medium	medium	60	37	52	63	51	54	59	56	60	59	62	67	64	59	49	62	63	65	47	60	52	56	47	62	47	57	58	59	9	12	10	14	6
104415	2009-08-30	56	67	left	medium	medium	57	33	49	55	51	47	59	50	56	53	59	65	64	57	49	53	63	65	42	52	50	56	63	62	45	55	57	59	12	21	56	21	21
104415	2007-02-22	56	67	left	medium	medium	57	33	49	55	51	47	59	50	56	53	59	65	64	57	49	53	63	65	42	52	50	56	63	62	45	55	57	59	12	21	56	21	21
26502	2014-09-18	64	64	right	medium	low	38	70	82	54	64	42	35	36	35	49	45	38	32	64	32	74	54	32	89	62	71	21	68	54	61	25	28	22	8	14	7	15	9
26502	2014-08-29	64	64	right	medium	low	38	70	82	54	64	42	35	36	35	49	45	40	32	64	32	74	55	32	89	62	71	21	68	54	61	25	28	22	8	14	7	15	9
26502	2014-03-07	64	65	right	medium	low	38	70	82	54	64	42	35	36	35	49	45	40	32	64	32	74	55	32	89	62	71	21	68	54	61	25	28	22	8	14	7	15	9
26502	2013-09-20	65	66	right	medium	low	38	71	82	54	64	42	35	36	35	49	45	40	32	65	32	74	55	32	89	62	71	21	69	54	61	25	28	22	8	14	7	15	9
26502	2013-03-28	64	65	right	medium	medium	38	71	80	54	61	42	35	36	35	49	45	40	32	64	32	72	55	32	89	62	71	21	69	54	61	18	28	22	8	14	7	15	9
26502	2013-03-22	63	65	right	medium	medium	38	70	77	54	61	42	35	36	35	49	45	40	32	62	32	72	55	32	89	64	64	21	69	54	57	18	28	22	8	14	7	15	9
26502	2013-03-15	63	65	right	medium	medium	38	70	77	54	61	42	35	36	35	49	45	40	32	62	32	72	55	32	89	64	64	21	69	54	57	18	28	22	8	14	7	15	9
26502	2013-02-15	63	65	right	medium	medium	38	70	77	54	61	42	35	36	35	49	45	40	32	62	32	72	55	32	89	64	64	21	69	54	57	18	28	22	8	14	7	15	9
26502	2012-08-31	64	65	right	low	low	38	70	77	54	61	42	35	36	35	49	45	42	33	62	33	72	59	33	89	64	64	21	69	54	57	18	28	22	8	14	7	15	9
26502	2012-02-22	64	65	right	low	low	38	70	77	54	61	42	35	36	35	49	45	42	33	62	33	72	59	33	89	64	64	21	69	54	57	18	28	22	8	14	7	15	9
26502	2011-08-30	64	65	right	low	low	38	70	77	54	61	42	35	36	35	49	45	46	34	62	34	72	59	39	89	64	64	21	69	54	57	18	28	22	8	14	7	15	9
26502	2011-02-22	64	66	right	low	low	38	68	78	47	61	53	45	26	35	58	62	60	61	58	78	63	62	77	83	59	64	31	67	51	54	38	38	32	8	14	7	15	9
26502	2010-08-30	64	66	right	low	low	38	68	78	47	61	53	45	26	35	58	62	60	61	58	78	63	62	77	83	59	64	31	67	51	54	38	38	32	8	14	7	15	9
26502	2010-02-22	64	66	right	low	low	38	68	78	47	61	53	45	26	35	58	62	60	61	58	78	63	62	77	83	59	64	58	67	51	50	38	38	32	6	20	35	20	20
26502	2009-08-30	63	66	right	low	low	38	67	77	47	61	55	45	26	35	55	62	60	61	58	78	63	62	77	77	59	64	58	67	51	50	38	38	32	6	20	35	20	20
26502	2008-08-30	58	66	right	low	low	38	56	77	47	61	52	45	26	35	60	62	60	61	58	78	63	62	77	67	59	64	58	62	51	46	38	38	32	6	20	35	20	20
26502	2007-08-30	58	66	right	low	low	38	56	77	47	61	52	45	26	35	60	62	60	61	58	78	51	62	77	76	59	64	58	62	51	46	38	38	32	6	20	35	20	20
26502	2007-02-22	55	63	right	low	low	38	56	77	47	61	48	45	46	25	44	62	60	61	58	78	51	62	77	76	59	64	58	62	51	46	38	38	32	6	10	25	15	8
179058	2009-08-30	60	68	right	\N	\N	48	62	58	63	\N	53	\N	56	57	59	63	66	\N	62	\N	58	\N	67	63	59	61	61	64	\N	63	31	28	\N	3	23	57	23	23
179058	2007-02-22	60	68	right	\N	\N	48	62	58	63	\N	53	\N	56	57	59	63	66	\N	62	\N	58	\N	67	63	59	61	61	64	\N	63	31	28	\N	3	23	57	23	23
37971	2012-02-22	68	70	right	medium	medium	19	11	8	11	14	13	12	13	23	24	61	60	58	59	56	37	70	56	71	13	66	27	13	31	15	10	13	10	70	68	72	65	71
37971	2011-02-22	68	70	right	medium	medium	19	11	8	11	14	13	12	13	23	24	61	60	58	59	56	37	70	56	71	13	66	27	13	31	15	10	13	10	70	68	72	65	71
37971	2010-08-30	68	70	right	medium	medium	19	11	8	11	14	13	12	13	23	24	61	60	58	59	56	37	70	56	71	13	66	27	13	59	15	22	13	10	70	68	72	65	73
37971	2010-02-22	67	70	right	medium	medium	21	26	8	21	14	13	12	13	67	24	61	60	58	59	56	37	70	56	71	21	66	54	21	59	59	22	21	10	70	65	67	63	71
37971	2009-08-30	64	68	right	medium	medium	21	26	8	21	14	13	12	13	62	24	61	60	58	59	56	37	70	56	71	21	66	54	21	59	59	22	21	10	66	63	62	62	66
37971	2009-02-22	64	68	right	medium	medium	21	26	8	21	14	13	12	13	62	24	61	60	58	59	56	37	70	56	71	21	66	54	21	59	59	22	21	10	66	63	62	62	66
37971	2008-08-30	64	68	right	medium	medium	21	26	8	21	14	13	12	13	62	24	61	60	58	59	56	37	70	56	71	21	66	54	21	59	59	22	21	10	66	63	62	62	66
37971	2007-08-30	64	68	right	medium	medium	21	26	8	21	14	13	12	13	60	24	61	60	58	59	56	37	70	56	71	21	66	54	21	59	59	22	21	10	65	63	60	60	66
37971	2007-02-22	63	68	right	medium	medium	19	26	8	11	14	13	12	59	59	24	61	60	58	59	56	37	70	56	71	13	66	54	21	59	59	22	13	10	64	62	59	59	65
166302	2016-04-21	72	74	right	high	medium	65	78	67	68	66	72	58	60	44	71	84	85	88	70	80	70	91	69	61	72	48	24	72	64	69	13	28	26	15	14	8	12	11
166302	2015-12-10	72	74	right	high	medium	65	78	67	68	66	72	58	60	44	71	84	85	88	70	80	70	91	69	61	72	48	24	72	65	69	13	28	26	15	14	8	12	11
166302	2015-11-12	71	73	right	high	medium	65	72	68	69	67	71	58	60	44	71	83	85	88	72	80	67	91	69	60	70	48	24	71	65	68	13	28	26	15	14	8	12	11
166302	2015-09-21	71	73	right	high	medium	65	72	68	69	67	71	58	60	44	71	83	85	88	72	80	67	91	69	60	70	48	24	71	65	68	13	28	26	15	14	8	12	11
166302	2015-05-22	70	73	right	high	medium	64	71	67	68	66	70	57	59	43	70	83	85	87	71	80	66	88	68	63	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2014-10-31	70	74	right	high	medium	64	71	67	68	66	70	57	59	43	70	83	85	87	71	80	66	88	68	63	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2014-10-02	70	74	right	high	medium	64	71	67	68	66	70	57	59	43	70	81	83	81	71	80	66	88	57	63	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2014-09-18	70	74	right	high	medium	64	71	67	68	66	70	57	59	43	70	81	83	81	71	80	66	88	57	60	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2014-04-25	70	73	right	high	medium	64	71	67	68	66	70	57	59	43	70	81	83	81	71	80	66	85	58	60	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2014-02-28	70	73	right	high	medium	64	71	67	68	66	70	57	59	43	70	81	83	81	71	80	66	85	58	60	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2014-01-31	71	74	right	high	medium	64	72	67	68	66	71	57	59	43	71	81	83	81	71	80	68	85	58	60	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2013-11-01	70	74	right	high	medium	64	72	67	68	66	71	57	59	43	71	78	81	81	71	80	68	83	61	60	67	47	23	70	62	67	25	27	25	14	13	7	11	10
166302	2013-10-04	70	74	right	high	medium	64	72	67	68	66	71	57	59	43	71	78	81	81	71	80	68	83	61	63	67	47	23	70	65	67	25	27	25	14	13	7	11	10
166302	2013-09-20	70	74	right	high	medium	64	72	67	68	66	71	57	59	43	71	78	81	82	71	80	68	83	61	63	67	47	23	70	65	67	25	27	25	14	13	7	11	10
166302	2013-05-10	72	80	right	high	medium	64	72	68	68	69	72	57	59	43	72	88	87	87	71	83	71	91	66	64	68	47	23	70	65	67	12	27	25	14	13	7	11	10
166302	2013-03-22	73	80	right	high	medium	64	73	71	68	69	74	57	59	52	72	91	89	90	74	83	73	93	73	64	69	47	32	70	65	67	12	37	35	14	13	7	11	10
166302	2013-03-15	73	80	right	high	medium	64	73	71	68	69	74	57	59	52	72	91	89	90	74	83	73	93	73	64	69	47	32	70	65	67	12	37	35	14	13	7	11	10
166302	2013-02-15	73	80	right	high	medium	64	73	71	68	69	74	57	59	52	72	91	89	90	74	83	73	93	73	64	69	47	32	70	65	67	12	37	35	14	13	7	11	10
166302	2012-08-31	73	80	right	high	medium	64	73	71	68	69	74	57	59	57	72	91	87	90	74	83	73	93	72	63	69	47	32	70	65	67	12	37	35	14	13	7	11	10
166302	2012-02-22	71	79	right	medium	medium	64	71	65	68	67	74	57	59	57	72	87	85	89	74	82	70	87	72	60	69	45	37	67	65	67	12	37	35	14	13	7	11	10
166302	2011-08-30	69	79	right	medium	medium	63	71	62	63	66	74	57	59	54	69	87	82	87	71	81	69	85	66	57	64	41	37	62	63	64	12	37	35	14	13	7	11	10
166302	2011-02-22	68	80	right	medium	medium	61	69	62	58	63	72	56	59	54	67	82	77	74	71	64	67	80	63	53	62	41	42	60	58	64	12	40	35	14	13	7	11	10
166302	2010-08-30	67	80	right	medium	medium	55	69	62	53	63	68	54	59	52	65	77	75	74	71	60	67	74	63	53	62	41	42	60	58	64	12	50	45	14	13	7	11	10
166302	2009-08-30	66	80	right	medium	medium	55	69	59	49	63	68	54	59	43	65	77	75	74	71	60	66	74	63	53	60	41	50	50	58	51	22	22	45	8	22	43	22	22
166302	2009-02-22	65	80	right	medium	medium	50	68	59	49	63	66	54	59	43	63	77	75	74	71	60	66	74	63	53	60	41	40	42	58	51	22	22	45	8	22	43	22	22
166302	2007-02-22	65	80	right	medium	medium	50	68	59	49	63	66	54	59	43	63	77	75	74	71	60	66	74	63	53	60	41	40	42	58	51	22	22	45	8	22	43	22	22
38788	2011-08-30	64	64	left	medium	medium	63	62	73	62	66	57	59	58	57	62	55	67	58	63	44	60	38	84	78	56	65	64	58	62	64	60	62	57	6	6	13	14	11
38788	2010-08-30	64	66	left	medium	medium	63	62	73	62	66	57	59	58	57	62	57	67	58	63	67	60	59	79	72	56	65	64	58	62	64	60	62	57	6	6	13	14	11
38788	2010-02-22	63	64	left	medium	medium	63	62	73	62	66	57	59	58	57	62	57	67	58	63	67	60	59	79	72	56	65	63	56	62	68	60	62	57	14	20	57	20	20
38788	2009-02-22	63	64	left	medium	medium	63	62	73	62	66	57	59	58	57	62	57	67	58	63	67	60	59	79	72	56	65	63	56	62	68	60	62	57	14	20	57	20	20
38788	2008-08-30	62	64	left	medium	medium	63	62	73	54	66	57	59	58	57	62	57	67	58	63	67	60	59	79	72	56	65	63	56	62	68	60	62	57	14	20	57	20	20
38788	2007-08-30	64	64	left	medium	medium	63	62	73	54	66	57	59	58	57	62	57	67	58	63	67	60	59	79	72	56	65	63	56	62	68	60	62	57	14	20	57	20	20
38788	2007-02-22	64	64	left	medium	medium	63	62	73	54	66	57	59	58	57	62	57	67	58	63	67	60	59	79	72	56	65	63	56	62	68	60	62	57	14	20	57	20	20
38780	2010-08-30	62	67	right	\N	\N	46	66	72	48	58	53	39	49	44	56	49	51	54	57	61	75	76	56	88	64	66	33	67	55	66	25	44	36	8	6	10	8	14
38780	2008-08-30	62	67	right	\N	\N	46	66	72	48	58	53	39	49	44	56	49	51	54	57	61	75	76	56	88	64	66	33	67	55	66	25	44	36	8	6	10	8	14
38780	2007-08-30	71	67	right	\N	\N	46	66	72	48	58	53	39	49	44	56	49	51	54	57	61	75	76	56	88	64	66	33	67	55	66	25	44	36	8	6	10	8	14
38780	2007-02-22	71	67	right	\N	\N	46	66	72	48	58	53	39	49	44	56	49	51	54	57	61	75	76	56	88	64	66	33	67	55	66	25	44	36	8	6	10	8	14
94184	2008-08-30	56	59	right	\N	\N	53	34	54	50	\N	42	\N	51	50	55	59	64	\N	58	\N	52	\N	67	50	49	55	63	61	\N	51	56	57	\N	6	25	50	25	25
94184	2007-08-30	56	59	right	\N	\N	53	34	54	50	\N	42	\N	51	50	55	59	64	\N	58	\N	52	\N	67	50	49	55	63	61	\N	51	56	57	\N	6	25	50	25	25
94184	2007-02-22	56	59	right	\N	\N	53	34	54	50	\N	42	\N	51	50	55	59	64	\N	58	\N	52	\N	67	50	49	55	63	61	\N	51	56	57	\N	6	25	50	25	25
38439	2012-02-22	65	65	right	medium	medium	65	52	54	67	66	67	68	64	69	67	65	43	67	64	79	70	62	60	59	65	62	42	62	65	44	42	47	35	11	9	6	10	13
38439	2011-08-30	64	65	right	medium	medium	65	54	56	67	67	67	68	64	69	65	65	46	65	65	79	69	65	63	59	65	59	45	57	67	44	55	58	33	11	9	6	10	13
38439	2010-08-30	64	65	right	medium	medium	65	54	56	67	67	67	68	64	69	65	65	46	65	65	79	69	65	63	59	65	59	45	57	67	44	55	58	33	11	9	6	10	13
38439	2010-02-22	66	68	right	medium	medium	66	55	57	68	67	68	68	54	70	66	65	46	65	66	79	62	65	63	67	66	60	64	66	67	68	56	59	33	11	20	70	20	20
38439	2009-08-30	63	66	right	medium	medium	60	49	57	68	67	68	68	54	62	63	65	46	65	63	79	58	65	58	67	64	60	64	64	67	64	56	59	33	11	20	62	20	20
38439	2008-08-30	63	64	right	medium	medium	60	49	57	68	67	68	68	54	62	63	65	46	65	63	79	58	65	58	67	64	60	64	64	67	64	56	59	33	11	20	62	20	20
38439	2007-08-30	62	64	right	medium	medium	60	49	57	68	67	68	68	54	62	63	72	46	65	63	79	58	65	58	67	64	60	64	64	67	64	56	59	33	11	20	62	20	20
38439	2007-02-22	61	62	right	medium	medium	59	48	56	67	67	67	68	63	61	62	71	59	65	62	79	57	65	57	66	63	59	64	64	67	63	55	58	33	11	7	61	10	14
148311	2008-08-30	60	65	right	\N	\N	24	24	35	35	\N	24	\N	18	61	27	25	28	\N	62	\N	35	\N	50	60	34	39	41	27	\N	35	21	24	\N	62	55	61	62	62
148311	2007-02-22	60	65	right	\N	\N	24	24	35	35	\N	24	\N	18	61	27	25	28	\N	62	\N	35	\N	50	60	34	39	41	27	\N	35	21	24	\N	62	55	61	62	62
37972	2012-02-22	66	66	right	medium	medium	69	66	36	66	68	67	67	72	64	67	68	66	71	64	76	73	64	59	47	76	33	43	63	67	62	27	33	29	5	6	14	11	7
37972	2011-08-30	66	66	right	medium	medium	68	66	41	66	68	67	67	72	62	67	68	66	66	64	76	74	64	63	48	76	37	43	64	67	58	31	34	29	5	6	14	11	7
37972	2011-02-22	66	71	right	medium	medium	68	61	41	66	60	67	62	65	62	67	66	67	64	64	46	64	62	64	50	64	37	43	64	67	58	31	34	29	5	6	14	11	7
37972	2010-08-30	67	71	right	medium	medium	69	62	46	66	60	68	62	65	62	68	68	69	68	67	46	64	62	66	50	64	50	46	66	67	59	41	44	39	5	6	14	11	7
37972	2009-08-30	68	71	right	medium	medium	70	64	46	67	60	70	62	65	63	68	70	69	68	69	46	65	62	66	50	64	50	63	62	67	64	41	44	39	6	25	63	25	25
37972	2009-02-22	66	70	right	medium	medium	68	54	46	67	60	69	62	65	63	64	68	67	68	66	46	60	62	63	44	64	50	61	53	67	52	41	41	39	6	25	63	25	25
37972	2008-08-30	67	70	right	medium	medium	67	54	46	67	60	70	62	65	71	65	70	69	68	67	46	60	62	63	44	64	50	61	53	67	52	41	41	39	6	25	71	25	25
37972	2008-02-22	67	68	right	medium	medium	67	54	46	67	60	70	62	65	66	65	70	65	68	67	46	60	62	63	44	64	50	61	53	67	52	41	41	39	6	25	66	25	25
37972	2007-02-22	67	68	right	medium	medium	67	54	46	67	60	70	62	65	66	65	70	65	68	67	46	60	62	63	44	64	50	61	53	67	52	41	41	39	6	25	66	25	25
166679	2016-03-24	67	69	right	high	medium	64	54	55	62	54	68	62	59	59	67	78	74	76	65	76	62	71	69	64	59	70	64	59	57	58	68	67	67	12	16	6	14	6
166679	2015-09-21	67	69	right	high	medium	64	54	55	62	54	68	62	59	59	67	78	74	76	65	80	62	71	69	64	59	70	64	59	57	58	68	67	67	12	16	6	14	6
166679	2015-05-15	64	67	right	high	medium	63	53	54	61	53	67	61	58	58	66	78	74	76	64	80	61	69	68	64	58	69	63	58	56	57	64	64	63	11	15	5	13	5
166679	2014-11-07	61	66	right	high	medium	62	53	48	58	53	67	61	58	57	66	78	73	74	63	77	61	69	64	61	58	58	56	57	53	57	62	63	61	11	15	5	13	5
166679	2014-10-02	63	67	right	medium	high	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	69	57	61	54	52	46	57	53	57	60	57	59	11	15	5	13	5
166679	2014-09-18	63	67	right	medium	high	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	69	57	61	54	52	46	57	53	57	48	49	47	11	15	5	13	5
166679	2014-03-28	63	67	right	medium	high	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	68	58	61	54	52	46	57	53	57	48	49	47	11	15	5	13	5
166679	2014-03-21	63	67	right	medium	high	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	68	58	61	54	52	46	57	53	57	48	49	47	11	15	5	13	5
166679	2014-02-28	63	67	right	medium	high	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	68	58	61	54	52	46	57	53	57	48	49	47	11	15	5	13	5
166679	2013-10-11	63	67	right	medium	low	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	68	58	61	54	52	46	57	53	57	48	49	47	11	15	5	13	5
166679	2013-09-20	63	67	right	medium	low	62	56	43	58	53	67	61	58	57	66	78	73	74	63	77	58	68	58	61	54	52	46	57	53	57	48	49	47	11	15	5	13	5
166679	2013-03-15	63	69	right	medium	low	60	56	43	58	53	67	64	58	51	65	78	72	71	63	77	60	72	49	61	54	46	26	57	52	57	29	22	28	11	15	5	13	5
166679	2013-02-15	63	69	right	medium	low	60	56	43	58	53	67	64	58	51	65	78	72	71	63	77	60	72	49	61	54	46	26	57	52	57	29	22	28	11	15	5	13	5
166679	2012-08-31	63	69	right	medium	low	60	56	43	58	53	67	64	58	51	65	78	73	71	63	76	60	70	52	58	54	46	26	57	52	57	29	22	28	11	15	5	13	5
166679	2012-02-22	64	71	right	medium	medium	60	56	43	58	53	67	66	58	51	65	78	76	71	67	76	60	70	55	58	54	46	26	57	52	57	29	22	28	11	15	5	13	5
166679	2011-08-30	65	70	right	medium	medium	60	56	43	58	53	71	66	58	51	68	83	77	71	67	76	60	70	67	58	54	46	26	57	54	57	29	22	28	11	15	5	13	5
166679	2011-02-22	62	69	right	medium	medium	63	58	37	60	53	64	53	58	56	61	72	70	67	62	57	60	65	61	52	54	46	33	57	54	48	29	22	28	11	15	5	13	5
166679	2010-08-30	64	69	right	medium	medium	64	58	37	61	53	64	53	58	57	61	74	72	69	62	57	60	65	61	52	54	46	33	57	57	48	29	22	28	11	15	5	13	5
166679	2010-02-22	62	67	right	medium	medium	61	57	37	56	53	64	53	58	52	61	74	72	69	62	57	60	65	61	47	61	46	29	39	57	36	29	22	28	12	21	52	21	21
166679	2009-08-30	56	67	right	medium	medium	52	45	34	49	53	54	53	47	38	51	72	70	69	62	57	53	65	59	45	48	46	29	39	57	36	21	22	28	2	21	38	21	21
166679	2009-02-22	51	67	right	medium	medium	49	42	34	39	53	54	53	47	28	48	63	63	69	57	57	43	65	59	41	48	46	29	39	57	36	21	22	28	2	21	28	21	21
166679	2008-08-30	51	67	right	medium	medium	49	42	34	39	53	54	53	47	28	48	63	63	69	57	57	43	65	59	41	48	46	29	39	57	36	21	22	28	2	21	28	21	21
166679	2007-02-22	51	67	right	medium	medium	49	42	34	39	53	54	53	47	28	48	63	63	69	57	57	43	65	59	41	48	46	29	39	57	36	21	22	28	2	21	28	21	21
38253	2016-05-12	76	76	right	high	high	72	73	78	79	71	71	65	65	75	77	68	72	67	75	60	73	78	85	76	72	75	77	76	71	69	72	74	78	9	14	15	12	10
38253	2016-04-28	75	75	right	high	high	73	73	78	79	71	71	65	65	73	77	68	72	67	75	60	73	78	83	76	72	75	77	76	71	69	72	74	78	9	14	15	12	10
38253	2016-01-07	73	73	right	high	high	73	73	77	74	71	70	65	65	70	72	68	72	67	75	60	73	78	83	76	72	71	70	76	73	69	67	70	77	9	14	15	12	10
38253	2015-11-12	73	73	right	high	high	73	73	77	74	71	70	65	65	70	72	68	72	67	75	60	73	78	83	76	72	71	70	76	73	69	67	70	77	9	14	15	12	10
38253	2015-10-30	73	73	right	high	high	73	73	77	74	71	70	65	65	70	72	68	72	67	75	60	73	78	83	76	72	71	70	76	73	69	67	70	77	9	14	15	12	10
38253	2015-10-09	73	73	right	high	high	73	73	77	74	69	70	65	65	70	72	68	72	67	75	60	73	78	83	76	72	71	70	76	73	69	67	70	77	9	14	15	12	10
38253	2015-09-25	73	73	right	high	high	73	73	77	74	69	70	65	65	70	72	68	72	67	75	60	73	78	83	76	72	71	70	76	73	69	67	70	77	9	14	15	12	10
38253	2015-09-21	73	73	right	high	high	73	72	77	74	69	70	65	65	70	72	68	72	67	75	60	73	78	83	76	72	71	70	76	73	69	67	70	77	9	14	15	12	10
38253	2015-07-03	72	72	right	high	high	72	71	76	73	68	69	64	64	69	71	72	74	67	74	60	72	78	83	76	71	70	69	76	72	68	66	69	76	8	13	14	11	9
38253	2015-03-06	72	72	right	high	high	72	71	76	73	68	69	64	64	69	71	72	74	67	74	60	72	78	83	76	71	70	69	76	72	68	66	69	76	8	13	14	11	9
38253	2015-02-20	72	72	right	high	high	72	71	76	73	68	69	64	64	69	71	72	74	67	74	60	72	78	83	76	71	70	69	76	72	68	66	69	76	8	13	14	11	9
38253	2015-01-16	72	72	right	high	high	72	71	76	73	68	69	64	64	69	71	71	74	67	74	60	72	78	83	76	71	68	67	76	72	68	66	69	76	8	13	14	11	9
38253	2014-09-18	72	72	right	high	medium	72	71	76	73	68	69	64	64	69	71	71	74	67	74	60	72	78	83	76	71	68	67	76	72	68	66	69	76	8	13	14	11	9
38253	2014-04-25	72	72	right	high	medium	72	71	76	73	68	69	64	64	69	71	71	74	67	74	60	72	78	83	76	71	68	67	76	72	68	66	69	76	8	13	14	11	9
38253	2014-03-14	72	72	right	high	medium	72	71	76	73	68	69	64	64	69	71	71	74	67	74	60	72	78	83	76	71	68	67	76	72	68	66	69	76	8	13	14	11	9
38253	2014-01-24	72	72	right	high	medium	72	71	76	73	68	69	64	64	69	71	71	74	67	74	60	72	78	83	76	71	68	67	76	72	68	66	69	76	8	13	14	11	9
38253	2014-01-03	72	72	right	high	medium	72	71	75	73	68	69	64	64	69	71	71	73	67	73	60	72	78	83	76	71	68	67	76	72	70	65	69	76	8	13	14	11	9
38253	2013-12-27	71	71	right	high	medium	72	71	75	73	68	69	64	64	69	71	68	73	67	73	60	72	80	83	76	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-11-15	71	71	right	high	medium	72	71	75	73	68	69	64	64	69	71	68	73	67	73	60	72	80	83	76	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-11-01	72	72	right	high	medium	72	71	75	73	68	69	64	64	69	71	68	73	67	73	60	72	80	86	76	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-10-04	72	72	right	high	medium	72	71	75	73	68	69	64	64	69	71	68	73	67	73	60	72	80	86	74	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-09-20	72	72	right	high	medium	72	73	75	73	68	69	64	64	69	71	68	73	67	73	60	72	80	86	74	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-05-31	72	72	right	high	medium	72	73	75	73	68	69	64	64	69	72	68	73	67	73	60	72	80	86	74	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-03-15	72	72	right	high	medium	72	73	75	73	68	69	64	64	69	72	68	73	67	73	60	72	80	86	74	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2013-02-15	72	73	right	high	medium	72	73	75	73	68	69	64	64	69	72	68	73	67	73	60	72	80	86	74	71	68	67	76	72	70	63	66	76	8	13	14	11	9
38253	2012-08-31	73	73	right	high	medium	72	76	76	73	69	70	64	66	70	73	69	73	67	75	59	72	77	86	76	71	67	66	78	73	70	63	66	72	8	13	14	11	9
38253	2012-02-22	72	73	right	high	medium	71	76	76	72	69	69	63	66	70	72	67	73	65	75	59	71	79	86	75	70	66	63	78	73	69	63	66	71	8	13	14	11	9
38253	2011-08-30	69	71	right	high	medium	71	71	76	72	66	66	63	66	70	71	66	73	65	69	59	73	80	86	75	69	66	58	73	65	70	62	67	71	8	13	14	11	9
38253	2011-02-22	71	74	right	high	medium	71	71	76	73	67	66	63	66	70	71	66	71	65	68	70	74	72	82	76	70	68	56	71	70	69	62	67	71	8	13	14	11	9
38253	2010-08-30	70	74	right	high	medium	69	71	76	73	67	66	63	66	68	71	66	71	65	68	70	74	72	82	76	70	68	56	71	70	69	62	67	71	8	13	14	11	9
38253	2010-02-22	71	74	right	high	medium	69	71	76	73	67	66	63	66	68	71	67	73	65	68	70	74	72	83	76	70	68	67	66	70	69	62	66	71	7	21	68	21	21
38253	2009-08-30	70	74	right	high	medium	66	71	76	72	67	66	63	66	67	72	67	73	65	68	70	73	72	83	76	68	67	66	64	70	68	56	60	71	1	21	67	21	21
38253	2009-02-22	70	74	right	high	medium	66	71	76	72	67	66	63	66	67	72	67	73	65	68	70	73	72	83	76	68	67	66	64	70	68	56	60	71	1	21	67	21	21
38253	2008-08-30	69	73	right	high	medium	66	68	76	69	67	66	63	63	65	71	67	73	65	66	70	73	72	83	75	66	67	66	60	70	63	62	63	71	1	21	65	21	21
38253	2007-08-30	64	71	right	high	medium	60	63	68	60	67	62	63	56	57	65	62	67	65	64	70	66	72	76	73	62	66	61	62	70	64	60	63	71	1	21	57	21	21
38253	2007-02-22	61	65	right	high	medium	57	64	58	57	67	62	63	63	52	63	59	61	65	64	70	66	72	68	73	55	64	61	62	70	63	43	52	71	1	1	52	1	1
37953	2013-10-11	65	65	right	medium	medium	62	31	56	67	26	37	54	35	52	61	64	65	62	63	73	48	36	73	68	33	72	65	49	45	55	69	61	66	9	9	12	5	8
37953	2013-09-20	64	64	right	medium	medium	62	31	56	67	26	37	54	35	52	61	63	63	56	62	73	48	36	73	68	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2013-05-31	64	64	right	medium	medium	62	31	56	67	26	37	54	35	52	61	63	64	56	62	73	48	37	73	68	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2013-02-15	64	64	right	medium	medium	62	31	56	67	26	37	54	35	52	61	63	64	56	62	73	48	37	73	68	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2012-08-31	65	65	right	medium	medium	62	31	56	67	26	37	54	35	52	61	63	66	54	62	71	48	43	73	68	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2012-02-22	65	67	right	medium	medium	62	31	56	67	26	37	54	35	52	61	63	66	54	62	71	48	43	73	68	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2011-08-30	65	67	right	medium	medium	62	31	56	67	26	37	54	35	52	61	63	66	54	62	71	48	43	73	68	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2010-08-30	64	67	right	medium	medium	62	31	56	67	26	37	54	35	52	61	62	67	57	62	72	48	52	71	67	33	71	65	49	45	55	69	59	66	9	9	12	5	8
37953	2009-08-30	64	71	right	medium	medium	56	31	56	67	26	37	54	35	52	61	62	67	57	62	72	48	52	71	67	33	71	42	56	45	55	71	59	66	9	22	52	22	22
37953	2008-08-30	63	71	right	medium	medium	56	31	50	67	26	37	54	35	52	62	62	67	57	62	72	48	52	71	67	33	71	42	56	45	55	70	55	66	9	22	52	22	22
37953	2007-08-30	63	71	right	medium	medium	56	31	50	67	26	37	54	35	52	62	62	67	57	62	72	48	52	71	67	33	71	42	56	45	55	70	55	66	9	22	52	22	22
37953	2007-02-22	63	71	right	medium	medium	56	31	50	67	26	37	54	55	52	62	62	67	57	62	72	48	52	71	67	33	71	42	56	45	55	70	55	66	9	12	52	8	13
38789	2015-05-08	65	65	right	medium	medium	67	49	63	65	59	60	62	66	66	65	53	51	58	61	68	67	56	74	63	65	68	68	58	62	66	63	65	66	8	9	5	15	11
38789	2015-01-09	66	66	right	medium	medium	68	49	63	65	59	60	63	67	67	65	55	53	59	64	68	68	56	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2014-11-14	66	66	right	medium	medium	68	49	63	65	59	60	63	67	67	65	55	53	59	64	68	68	56	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2014-09-18	66	66	right	medium	medium	68	49	63	65	59	60	63	67	67	65	55	53	59	64	68	68	56	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2014-02-14	66	66	right	medium	medium	68	49	63	65	59	60	63	67	67	65	56	57	59	64	68	68	58	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2014-01-24	66	66	right	medium	medium	68	49	63	65	59	60	63	67	64	65	56	57	59	64	68	68	58	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2013-09-20	66	66	right	medium	medium	68	49	63	65	59	60	63	67	64	65	62	67	59	64	68	68	58	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2013-03-28	66	66	right	medium	medium	68	49	63	65	59	60	63	67	64	65	62	67	59	64	68	68	58	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2013-03-04	66	66	right	medium	medium	68	49	63	65	59	60	63	67	64	65	62	67	59	64	68	68	58	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2013-02-15	66	66	right	medium	medium	68	49	63	65	59	60	63	67	64	65	62	67	59	64	68	68	58	75	64	66	70	65	58	62	66	64	66	67	8	9	5	15	11
38789	2012-08-31	67	67	right	medium	medium	68	49	63	65	59	62	63	67	64	67	62	70	59	64	66	68	61	76	64	66	72	65	58	68	66	65	67	69	8	9	5	15	11
38789	2012-02-22	67	67	right	medium	medium	68	49	63	65	59	62	63	67	64	67	62	70	59	64	68	68	61	76	64	66	72	65	58	68	66	65	67	69	8	9	5	15	11
38789	2011-08-30	67	67	right	medium	medium	68	49	63	65	59	62	63	62	64	67	62	70	59	64	68	68	61	76	64	63	72	65	58	68	66	65	67	69	8	9	5	15	11
38789	2011-02-22	67	70	right	medium	medium	68	49	63	65	59	62	63	62	64	67	62	69	59	64	67	68	61	73	62	63	72	65	58	68	66	65	67	69	8	9	5	15	11
38789	2010-08-30	68	70	right	medium	medium	68	49	64	63	59	61	63	62	64	69	61	70	59	64	67	68	61	73	62	63	72	65	56	68	66	69	68	70	8	9	5	15	11
38789	2010-02-22	67	70	right	medium	medium	68	49	64	63	59	61	63	62	64	69	61	70	59	64	67	68	61	73	62	63	72	67	64	68	71	69	68	70	8	25	64	25	25
38789	2009-08-30	67	70	right	medium	medium	68	49	64	63	59	61	63	62	64	69	61	70	59	64	67	68	61	73	62	63	72	67	64	68	71	69	68	70	8	25	64	25	25
38789	2008-08-30	69	70	right	medium	medium	72	61	64	64	59	66	63	62	69	71	55	70	59	64	67	68	61	75	62	65	72	68	64	68	74	71	70	70	10	25	69	25	25
38789	2007-08-30	71	70	right	medium	medium	72	61	64	64	59	66	63	62	69	71	55	70	59	64	67	68	61	75	62	65	72	68	64	68	74	71	70	70	10	25	69	25	25
38789	2007-02-22	68	71	right	medium	medium	77	62	65	65	59	67	63	58	70	62	72	74	59	63	67	59	61	77	72	75	73	68	64	68	58	67	64	70	10	9	70	6	11
38273	2013-05-17	63	63	left	high	high	65	30	56	61	47	56	56	46	58	64	72	74	70	62	68	66	70	61	65	60	64	64	49	57	45	58	64	63	9	10	5	8	7
38273	2013-05-03	63	63	left	high	high	65	30	56	61	47	56	56	46	58	64	72	74	70	62	68	66	70	61	65	60	64	64	49	57	45	58	64	63	9	10	5	8	7
38273	2013-04-12	62	62	left	high	high	65	30	56	61	47	56	56	46	58	64	72	67	67	62	68	66	70	61	65	60	64	64	49	57	45	58	64	63	9	10	5	8	7
38273	2013-03-28	64	64	left	high	high	65	38	58	63	47	58	56	46	58	69	73	73	69	64	70	69	72	61	69	60	64	64	49	57	45	62	63	62	9	10	5	8	7
38273	2013-02-15	64	64	left	high	high	65	38	58	63	47	58	56	46	58	69	73	73	69	64	70	69	72	61	69	60	64	64	49	57	45	62	63	62	9	10	5	8	7
38273	2012-08-31	64	64	left	high	high	65	38	58	63	47	58	56	46	58	69	73	74	69	64	68	69	70	61	69	60	64	64	49	57	45	62	63	62	9	10	5	8	7
38273	2012-02-22	63	63	left	high	medium	65	38	58	63	47	58	56	46	58	64	73	74	69	64	70	69	70	61	69	54	67	64	49	57	45	62	64	61	9	10	5	8	7
38273	2011-08-30	65	65	left	high	medium	69	38	58	63	47	58	56	46	58	64	73	74	69	64	70	69	70	68	69	54	67	64	56	57	45	62	66	64	9	10	5	8	7
38273	2011-02-22	64	65	left	high	medium	69	38	58	63	47	58	56	46	58	64	71	72	66	64	68	69	65	66	64	54	67	64	66	65	45	62	66	64	9	10	5	8	7
38273	2010-08-30	64	65	left	high	medium	69	38	58	63	47	58	56	46	58	64	71	72	66	64	68	65	65	66	64	54	67	64	66	65	45	62	66	64	9	10	5	8	7
38273	2009-08-30	64	65	left	high	medium	69	38	58	63	47	58	56	46	58	64	71	72	66	64	68	65	65	66	64	54	67	68	63	65	64	62	66	64	1	23	58	23	23
38273	2007-08-30	59	60	left	high	medium	52	38	48	63	47	60	56	46	54	55	71	67	66	57	68	56	65	66	54	44	52	68	63	65	59	56	59	64	1	23	54	23	23
38273	2007-02-22	59	60	left	high	medium	52	38	48	63	47	56	56	59	59	54	74	69	66	57	68	56	65	66	54	44	66	68	63	65	59	62	59	64	1	1	59	1	1
37856	2009-02-22	63	70	left	\N	\N	48	63	60	46	\N	61	\N	49	37	60	71	76	\N	61	\N	64	\N	70	73	58	33	45	54	\N	47	25	26	\N	5	25	37	25	25
37856	2008-08-30	63	64	right	\N	\N	48	63	64	46	\N	63	\N	49	37	66	71	70	\N	60	\N	61	\N	64	72	58	33	45	54	\N	47	25	26	\N	5	25	37	25	25
37856	2007-08-30	62	64	right	\N	\N	58	60	63	46	\N	61	\N	49	37	60	71	70	\N	60	\N	60	\N	62	69	56	53	35	34	\N	37	33	36	\N	5	25	37	25	25
37856	2007-02-22	61	64	right	\N	\N	42	62	64	46	\N	55	\N	37	37	53	65	67	\N	60	\N	63	\N	57	74	54	53	35	34	\N	37	33	36	\N	5	8	37	5	10
36863	2014-10-24	69	69	right	medium	medium	67	66	41	69	67	72	72	67	67	74	69	61	77	65	80	66	62	65	53	67	54	51	70	69	66	32	43	39	13	6	8	5	10
36863	2014-10-10	69	69	right	medium	medium	67	66	41	69	67	72	72	67	67	74	69	61	77	65	80	66	62	65	53	67	54	51	70	69	66	32	43	39	13	6	8	5	10
36863	2014-09-18	69	69	right	medium	medium	67	66	41	69	67	72	72	67	67	74	69	61	77	65	80	66	62	65	53	67	54	51	70	69	66	32	33	29	13	6	8	5	10
36863	2013-10-11	70	70	right	medium	medium	67	66	41	69	67	74	72	67	67	75	69	63	77	66	80	66	62	65	52	67	54	51	70	69	66	32	33	29	13	6	8	5	10
36863	2013-09-20	70	70	right	medium	medium	67	66	41	69	67	74	72	67	67	75	69	63	77	66	80	66	62	65	52	67	54	51	70	69	66	32	33	29	13	6	8	5	10
36863	2013-05-10	70	70	right	medium	medium	67	66	41	69	67	74	72	67	67	75	69	64	77	66	80	66	62	65	50	67	54	51	70	69	66	32	33	29	13	6	8	5	10
36863	2013-03-22	71	71	right	medium	medium	70	68	41	71	67	75	72	67	69	76	69	64	77	66	80	66	62	65	50	71	54	56	71	71	66	43	49	47	13	6	8	5	10
36863	2013-03-08	71	71	right	medium	medium	70	68	41	71	67	75	72	67	69	76	69	64	77	66	80	66	62	65	50	71	54	56	71	71	66	43	49	47	13	6	8	5	10
36863	2013-02-15	71	71	right	medium	medium	70	68	41	71	67	75	72	67	69	76	69	64	77	66	80	66	62	65	50	71	54	56	71	71	66	43	49	47	13	6	8	5	10
36863	2012-08-31	72	72	right	medium	medium	71	69	41	72	68	76	72	67	70	77	71	65	82	67	80	66	67	68	48	71	57	56	71	72	66	43	49	47	13	6	8	5	10
36863	2012-02-22	72	72	right	medium	medium	71	66	41	73	67	76	72	67	70	77	73	65	83	66	82	61	70	69	48	70	57	56	71	74	66	43	49	47	13	6	8	5	10
36863	2011-08-30	72	72	right	medium	medium	71	66	41	73	67	76	72	67	70	76	75	65	86	66	84	61	75	70	47	70	57	56	68	74	66	46	49	47	13	6	8	5	10
36863	2010-08-30	69	72	right	medium	medium	68	58	41	71	67	78	72	67	69	76	72	67	78	66	56	61	68	67	48	70	37	46	71	72	66	46	49	47	13	6	8	5	10
36863	2010-02-22	69	73	right	medium	medium	66	58	51	74	67	73	72	67	71	75	71	66	78	64	56	61	68	65	48	70	44	64	67	72	65	37	39	47	7	25	71	25	25
36863	2009-08-30	70	73	right	medium	medium	70	58	51	74	67	75	72	67	71	79	72	67	78	66	56	61	68	65	48	70	44	64	67	72	65	37	39	47	7	25	71	25	25
36863	2008-08-30	70	74	right	medium	medium	71	58	51	76	67	75	72	67	71	76	72	67	78	66	56	60	68	65	52	70	44	64	67	72	65	37	39	47	7	25	71	25	25
36863	2007-08-30	68	67	right	medium	medium	71	51	51	76	67	71	72	53	80	61	60	57	78	57	56	72	68	61	42	56	44	47	40	72	56	38	29	47	7	25	80	25	25
36863	2007-02-22	68	67	left	medium	medium	71	51	51	76	67	71	72	56	80	61	60	57	78	57	56	72	68	61	42	56	44	47	40	72	56	38	29	47	7	11	80	5	14
40520	2016-03-31	69	70	right	medium	low	69	53	59	62	57	76	69	61	59	72	81	78	80	67	77	72	76	65	62	64	74	55	64	66	55	57	58	59	10	16	16	11	9
40520	2016-03-24	69	70	right	high	medium	69	53	59	62	57	76	69	61	59	72	81	78	80	67	77	72	76	65	62	64	74	55	64	66	55	57	58	59	10	16	16	11	9
40520	2015-10-30	69	70	right	high	medium	69	53	59	62	57	76	69	61	59	72	83	78	85	67	77	72	76	65	62	64	74	55	64	66	55	57	58	59	10	16	16	11	9
40520	2015-09-25	69	70	right	high	medium	69	58	59	62	57	76	69	61	59	72	83	78	85	67	77	72	76	65	62	64	74	55	64	66	55	57	58	59	10	16	16	11	9
40520	2015-09-21	69	70	right	high	medium	69	58	59	62	57	76	69	61	59	72	83	78	85	67	77	72	76	65	62	64	74	55	64	66	55	57	58	59	10	16	16	11	9
40520	2015-05-08	68	69	right	high	medium	63	57	58	61	56	75	58	60	58	71	83	80	86	66	81	71	73	65	62	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2015-04-17	68	71	right	high	medium	63	57	58	61	56	75	58	60	58	71	83	80	86	66	81	71	73	65	62	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2015-04-10	68	71	right	high	medium	63	57	53	61	56	75	58	60	58	71	83	80	86	66	81	71	73	65	62	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2015-03-06	69	71	right	high	medium	63	57	53	63	56	78	58	60	58	73	83	80	86	66	81	71	75	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-10-10	69	71	right	high	medium	63	57	53	63	56	78	58	60	58	73	83	80	86	66	81	71	75	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-09-18	69	71	right	high	medium	63	57	53	63	56	78	58	60	58	73	83	80	86	66	81	71	75	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-05-02	69	73	right	high	medium	63	57	53	63	56	80	58	60	58	73	83	79	86	66	81	71	73	68	64	63	73	54	63	67	54	56	57	58	9	15	15	10	8
40520	2014-04-04	69	73	right	high	medium	63	57	53	63	56	80	58	60	58	73	83	79	86	66	81	71	73	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-02-21	70	73	right	high	medium	63	57	53	63	56	80	58	60	58	73	83	79	86	66	81	71	73	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-01-31	70	73	right	high	medium	63	57	53	63	56	80	58	60	58	73	83	79	86	66	81	71	73	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-01-17	70	73	right	high	medium	63	57	53	63	56	80	58	60	58	73	83	79	86	66	81	71	73	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2014-01-10	70	73	right	high	medium	62	57	53	62	56	80	58	60	58	73	83	79	86	66	81	71	73	68	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-12-20	70	73	right	high	medium	62	57	53	62	56	77	58	60	58	72	83	79	86	66	81	71	73	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-11-01	69	73	right	high	medium	62	57	53	62	56	77	58	60	58	72	83	79	86	63	81	71	73	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-09-20	69	73	right	high	medium	62	57	53	62	56	77	58	60	58	72	83	79	86	63	81	71	73	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-05-31	69	73	right	high	medium	62	57	53	62	56	77	58	60	58	72	83	79	86	63	81	71	72	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-04-19	69	73	right	medium	medium	66	57	53	64	56	78	58	60	60	73	83	79	86	63	81	72	72	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-03-28	69	73	right	medium	medium	66	57	53	64	56	78	58	60	60	73	83	79	86	63	81	66	72	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-03-22	69	73	right	medium	medium	66	57	53	64	56	78	58	60	60	73	83	79	86	63	81	66	72	66	64	63	73	54	63	65	54	56	57	58	9	15	15	10	8
40520	2013-02-15	66	70	right	medium	medium	61	57	53	64	56	71	58	60	60	68	73	72	78	63	81	66	72	66	64	63	73	54	63	64	54	56	57	58	9	15	15	10	8
40520	2012-08-31	61	66	right	medium	medium	63	46	53	61	51	68	56	48	56	66	73	71	72	63	80	63	70	66	58	60	61	51	53	58	45	56	57	58	9	15	15	10	8
40520	2010-08-30	61	66	right	medium	medium	63	46	53	61	51	68	56	48	56	66	73	71	72	63	80	63	70	66	58	60	61	51	53	58	45	56	57	58	9	15	15	10	8
40520	2010-02-22	61	66	right	medium	medium	63	46	53	61	51	68	56	48	56	66	73	71	72	63	80	63	70	66	58	60	61	51	53	58	64	56	57	58	12	23	58	23	23
40520	2009-08-30	56	68	right	medium	medium	63	46	52	60	51	53	56	37	56	56	67	65	72	61	80	55	70	69	58	43	58	48	46	58	56	51	52	58	12	23	58	23	23
40520	2007-02-22	56	68	right	medium	medium	63	46	52	60	51	53	56	37	56	56	67	65	72	61	80	55	70	69	58	43	58	48	46	58	56	51	52	58	12	23	58	23	23
39158	2011-02-22	65	70	left	\N	\N	60	44	58	66	50	56	59	45	59	66	67	70	64	65	69	63	66	77	69	44	84	63	48	55	50	54	65	68	5	7	11	15	9
39158	2010-08-30	65	70	left	\N	\N	60	44	58	66	50	56	59	45	59	66	67	70	64	65	69	63	66	77	69	44	84	63	48	55	50	54	65	68	5	7	11	15	9
39158	2009-08-30	65	70	left	\N	\N	60	44	58	66	50	56	59	45	59	66	67	70	64	65	69	63	66	77	69	44	84	63	64	55	58	54	65	68	10	21	59	21	21
39158	2008-08-30	62	64	left	\N	\N	59	41	55	58	50	53	59	42	56	63	68	69	64	64	69	60	66	74	66	41	83	52	53	55	55	57	64	68	7	21	56	21	21
39158	2007-08-30	62	64	left	\N	\N	59	41	55	58	50	53	59	42	56	63	68	69	64	64	69	60	66	74	66	41	83	52	53	55	55	57	64	68	7	21	56	21	21
39158	2007-02-22	59	75	left	\N	\N	57	51	55	58	50	49	59	55	56	63	68	69	64	54	69	60	66	64	56	41	58	52	53	55	55	41	43	68	7	13	56	14	11
129278	2016-04-28	67	71	right	medium	medium	57	38	66	57	33	49	31	38	56	53	69	70	46	64	58	59	77	55	78	44	67	65	38	51	45	66	71	66	8	12	11	11	11
129278	2016-03-24	67	71	right	medium	medium	57	38	66	57	33	49	31	38	56	53	69	70	46	64	58	59	77	55	78	44	67	65	38	51	45	66	71	64	8	12	11	11	11
129278	2016-03-10	67	71	right	medium	medium	57	38	66	57	33	49	31	38	56	53	69	70	46	64	58	59	73	55	78	44	67	65	38	51	45	66	71	64	8	12	11	11	11
129278	2015-10-16	67	71	right	medium	medium	57	38	66	57	33	49	31	38	56	53	69	70	46	64	58	59	69	55	78	44	67	65	38	51	45	66	71	64	8	12	11	11	11
129278	2015-09-21	67	71	right	medium	medium	57	38	66	57	33	49	31	38	56	53	69	70	46	64	58	59	69	55	78	44	63	65	38	51	45	66	71	64	8	12	11	11	11
129278	2015-06-05	64	68	right	medium	medium	56	37	65	56	32	48	30	37	55	52	70	71	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2015-02-06	64	68	right	medium	medium	56	37	65	56	32	48	30	37	55	52	59	64	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2014-11-14	64	68	right	medium	medium	56	37	65	56	32	48	30	37	55	52	59	64	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2014-09-12	64	68	right	medium	medium	56	37	65	56	32	48	30	37	55	52	49	54	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2014-08-15	64	68	right	medium	medium	56	37	65	56	32	48	30	37	55	52	49	53	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2014-02-28	64	68	right	medium	medium	56	37	65	56	32	48	30	37	55	52	49	53	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2013-12-27	64	68	right	medium	medium	53	37	65	56	32	44	30	37	55	49	49	53	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2013-11-08	64	68	right	medium	medium	53	37	65	56	32	44	30	37	55	49	49	53	44	63	58	58	69	55	78	43	62	64	37	50	44	63	68	61	7	11	10	10	10
129278	2013-09-20	65	68	right	medium	medium	53	37	65	56	32	44	30	37	55	56	49	53	44	63	58	58	69	55	78	43	67	68	37	50	44	63	68	61	7	11	10	10	10
129278	2013-04-12	63	68	right	medium	medium	53	37	65	56	32	44	30	37	55	56	53	53	54	56	58	58	64	55	78	43	67	59	37	50	44	59	62	61	7	11	10	10	10
129278	2013-02-15	62	68	right	medium	medium	53	37	63	56	32	44	30	37	55	56	53	53	54	56	58	58	64	55	76	43	64	59	37	50	44	59	60	61	7	11	10	10	10
129278	2012-08-31	62	68	right	medium	medium	53	37	63	56	32	44	30	37	55	56	53	53	54	56	58	58	64	55	76	43	64	59	37	50	44	59	60	61	7	11	10	10	10
129278	2012-02-22	62	68	right	medium	medium	53	37	63	56	32	44	30	37	55	56	53	53	54	56	58	58	64	55	75	43	64	59	37	50	44	59	60	61	7	11	10	10	10
129278	2011-08-30	62	67	right	medium	medium	53	37	63	56	32	44	30	37	55	56	53	53	54	56	58	58	64	55	75	43	64	59	37	50	44	59	60	61	7	11	10	10	10
129278	2010-08-30	62	67	right	medium	medium	53	37	63	56	32	44	30	37	55	56	53	53	54	56	58	58	64	55	75	43	64	59	37	50	44	59	60	61	7	11	10	10	10
129278	2010-02-22	59	73	right	medium	medium	49	33	57	52	32	40	30	33	51	52	53	65	54	56	58	54	64	67	72	39	64	51	52	50	47	55	56	61	7	22	51	22	22
129278	2008-08-30	51	69	right	medium	medium	49	33	27	51	32	30	30	33	46	38	62	57	54	46	58	34	64	63	64	29	60	32	27	50	28	49	56	61	7	22	46	22	22
129278	2007-02-22	51	69	right	medium	medium	49	33	27	51	32	30	30	33	46	38	62	57	54	46	58	34	64	63	64	29	60	32	27	50	28	49	56	61	7	22	46	22	22
78462	2012-02-22	63	63	right	medium	medium	60	60	53	63	56	65	42	53	48	61	73	78	71	61	71	63	66	43	53	61	38	43	58	54	54	26	31	27	15	7	6	13	6
78462	2011-08-30	63	63	right	medium	medium	60	63	56	63	53	66	42	53	48	61	76	88	73	66	74	62	72	63	51	61	53	43	58	54	54	26	36	37	15	7	6	13	6
78462	2011-02-22	63	68	right	medium	medium	60	63	56	63	53	66	42	53	48	61	73	78	68	66	60	62	67	63	51	61	53	43	58	54	54	26	36	37	15	7	6	13	6
78462	2010-08-30	66	69	right	medium	medium	61	64	58	64	56	67	42	54	51	62	78	83	73	71	65	64	67	83	56	62	65	46	63	54	56	44	46	43	15	7	6	13	6
78462	2009-08-30	66	69	right	medium	medium	61	64	58	64	56	65	42	54	51	62	78	83	73	71	65	60	67	83	56	62	65	58	56	54	57	44	46	43	9	23	51	23	23
78462	2008-08-30	65	67	right	medium	medium	61	64	58	64	56	65	42	54	51	62	78	80	73	71	65	60	67	83	56	62	65	58	56	54	57	44	46	43	9	23	51	23	23
78462	2007-08-30	61	67	right	medium	medium	49	47	62	64	56	58	42	54	51	62	62	66	73	61	65	56	67	81	67	32	62	63	67	54	57	54	56	43	9	23	51	23	23
78462	2007-02-22	61	67	right	medium	medium	49	47	62	64	56	58	42	54	51	62	62	66	73	61	65	56	67	81	67	32	62	63	67	54	57	54	56	43	9	23	51	23	23
5016	2016-05-05	65	65	right	high	medium	64	25	44	57	30	58	35	29	62	65	76	76	75	63	67	49	59	76	63	49	81	53	46	59	39	65	67	68	13	8	13	7	9
5016	2016-04-21	65	65	right	high	medium	64	25	44	57	30	58	35	29	62	65	76	76	75	63	67	49	59	76	63	49	81	53	46	59	39	65	67	68	13	8	13	7	9
5016	2016-02-04	65	65	right	medium	medium	64	25	44	57	30	58	35	29	62	65	76	76	75	63	67	49	59	76	63	49	81	53	46	59	39	65	67	68	13	8	13	7	9
5016	2015-10-30	65	65	right	medium	medium	64	25	44	57	30	58	35	29	62	65	76	76	75	63	67	49	59	76	63	49	81	53	46	59	39	65	67	68	13	8	13	7	9
5016	2015-02-27	65	65	right	medium	medium	64	25	44	57	30	58	35	29	62	65	76	76	75	63	67	49	59	76	63	49	81	53	46	59	39	65	67	68	13	8	13	7	9
5016	2014-11-14	65	65	right	medium	medium	68	25	44	57	30	58	35	29	62	65	76	78	75	63	67	49	59	76	66	49	81	47	46	59	39	57	67	67	13	8	13	7	9
5016	2014-09-18	65	65	right	medium	medium	68	25	44	57	30	58	35	29	62	65	76	78	75	63	67	49	59	76	66	49	81	47	46	59	39	57	67	67	13	8	13	7	9
5016	2013-09-20	65	65	right	medium	medium	68	25	44	57	30	58	35	29	62	65	76	78	75	63	67	49	59	76	66	49	81	47	46	59	39	57	67	67	13	8	13	7	9
5016	2013-02-15	64	65	right	medium	medium	78	25	44	57	30	58	35	29	63	71	82	84	75	63	67	49	59	76	69	49	81	47	46	59	39	59	65	69	13	8	13	7	9
5016	2012-08-31	64	65	right	medium	medium	78	25	44	57	30	58	35	29	63	71	79	77	75	63	70	49	58	70	59	49	81	47	46	59	39	59	65	69	13	8	13	7	9
5016	2007-02-22	64	65	right	medium	medium	78	25	44	57	30	58	35	29	63	71	79	77	75	63	70	49	58	70	59	49	81	47	46	59	39	59	65	69	13	8	13	7	9
38417	2015-09-21	61	61	left	high	medium	53	22	46	55	34	58	35	44	47	57	71	69	73	62	79	57	75	62	67	39	68	60	57	53	51	63	60	64	12	13	7	6	16
38417	2015-04-10	59	59	left	high	medium	52	21	45	54	33	57	34	43	46	56	74	72	74	61	80	56	75	67	60	38	67	59	56	52	50	59	57	60	11	12	6	5	15
38417	2014-11-14	59	59	left	high	medium	52	21	45	54	33	57	34	43	46	56	74	72	74	61	80	56	75	67	60	38	67	59	56	52	50	59	57	60	11	12	6	5	15
38417	2014-09-18	59	59	left	high	medium	52	21	45	54	33	57	34	43	46	56	74	72	74	61	80	56	75	67	60	38	67	59	56	52	50	59	57	60	11	12	6	5	15
38417	2014-04-04	59	62	left	high	medium	52	21	45	54	33	57	34	43	46	56	72	73	71	61	80	56	70	64	58	38	67	59	56	52	50	59	57	60	11	12	6	5	15
38417	2013-09-20	59	62	left	high	medium	52	21	45	54	33	57	34	43	46	56	72	73	71	61	80	56	70	64	58	38	67	59	56	52	50	59	57	60	11	12	6	5	15
38417	2013-02-15	59	63	left	medium	medium	52	21	45	54	33	61	34	43	46	59	72	73	71	61	78	56	67	64	56	38	67	59	56	52	50	60	59	61	11	12	6	5	15
38417	2012-08-31	59	61	left	medium	medium	52	21	45	54	33	61	34	43	46	59	72	73	71	61	78	56	67	64	56	38	67	59	56	52	50	60	59	61	11	12	6	5	15
38417	2009-08-30	59	61	left	medium	medium	52	21	45	54	33	61	34	43	46	59	72	73	71	61	78	56	67	64	56	38	67	59	56	52	50	60	59	61	11	12	6	5	15
38417	2009-02-22	59	61	left	medium	medium	52	21	45	54	33	61	34	43	46	59	72	73	71	61	78	56	67	64	56	38	67	59	56	52	50	60	59	61	11	12	6	5	15
38417	2007-08-30	59	61	left	medium	medium	52	21	45	54	33	61	34	43	46	59	72	73	71	61	78	56	67	64	56	38	67	59	56	52	50	60	59	61	11	12	6	5	15
38417	2007-02-22	57	62	right	medium	medium	43	21	69	54	33	38	34	68	33	63	72	54	71	61	78	37	67	55	56	38	53	59	56	52	50	49	53	61	11	3	33	4	8
25465	2013-05-31	63	63	right	low	medium	36	27	65	56	23	31	37	34	60	56	36	30	30	50	49	58	55	54	78	31	83	63	39	38	42	59	62	58	5	9	11	10	11
25465	2013-05-10	63	63	right	low	medium	36	27	65	56	23	31	37	34	60	56	36	30	30	50	49	58	55	54	78	31	83	63	39	38	42	59	62	58	5	9	11	10	11
25465	2013-03-28	64	64	right	low	medium	36	27	65	56	23	31	37	34	60	56	36	30	30	54	49	58	55	54	78	31	83	63	39	43	42	61	64	60	5	9	11	10	11
25465	2013-02-15	64	64	right	low	medium	36	27	65	56	23	31	37	34	60	56	36	30	30	54	49	58	55	54	78	31	83	63	39	43	42	61	64	60	5	9	11	10	11
25465	2012-08-31	65	65	right	low	medium	36	27	65	61	23	31	37	34	65	58	36	29	29	56	46	58	59	55	78	31	83	61	39	43	42	63	65	60	5	9	11	10	11
25465	2012-02-22	64	64	right	low	medium	36	27	65	58	23	31	37	34	53	51	50	29	37	56	46	58	59	55	82	31	80	61	39	43	42	58	65	60	5	9	11	10	11
25465	2011-08-30	64	64	right	low	medium	36	27	65	58	23	31	37	34	53	51	50	31	40	56	46	58	59	56	83	31	80	61	39	43	42	58	65	60	5	9	11	10	11
25465	2011-02-22	65	67	right	low	medium	36	27	65	58	23	31	37	34	53	51	56	61	53	61	83	68	60	73	88	31	80	65	39	63	42	58	65	60	5	9	11	10	11
25465	2010-08-30	65	67	right	low	medium	36	27	65	58	23	31	37	34	53	51	58	63	56	61	73	65	60	75	78	31	80	65	39	63	42	60	65	62	5	9	11	10	11
25465	2009-08-30	66	67	right	low	medium	48	32	62	50	23	30	37	42	53	52	63	63	56	64	73	59	60	77	76	31	82	58	65	63	64	60	66	62	2	23	53	23	23
25465	2007-02-22	66	67	right	low	medium	48	32	62	50	23	30	37	42	53	52	63	63	56	64	73	59	60	77	76	31	82	58	65	63	64	60	66	62	2	23	53	23	23
94289	2016-04-28	67	67	left	high	low	62	53	49	62	60	72	65	61	52	68	91	92	84	62	80	70	67	72	53	62	41	31	57	59	54	27	26	17	14	7	7	10	11
94289	2015-11-19	67	68	left	high	low	62	53	49	62	60	73	65	61	52	68	91	92	84	62	80	70	67	72	53	62	41	31	57	59	54	27	26	17	14	7	7	10	11
94289	2015-10-16	67	68	left	high	low	62	53	49	62	60	73	65	61	52	68	91	92	84	62	80	70	67	72	53	62	41	31	57	59	54	27	26	17	14	7	7	10	11
94289	2015-09-21	67	69	left	high	low	62	53	49	62	60	73	65	61	52	68	91	92	84	62	80	70	67	72	53	62	41	31	57	59	54	27	26	17	14	7	7	10	11
94289	2015-04-17	67	70	left	high	low	61	52	48	63	59	74	64	60	51	68	91	92	84	61	79	70	68	72	55	61	40	30	56	58	53	26	25	25	13	6	6	9	10
94289	2015-04-10	67	70	left	high	low	61	52	48	63	59	74	64	60	51	68	91	92	84	60	79	70	68	72	55	61	40	30	56	58	53	26	25	25	13	6	6	9	10
94289	2014-10-10	67	71	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	55	61	40	30	56	58	53	26	25	25	13	6	6	9	10
94289	2014-09-18	67	71	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	57	61	40	30	56	58	53	26	25	25	13	6	6	9	10
94289	2014-03-21	67	73	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	58	61	40	30	56	58	53	26	25	25	13	6	6	9	10
94289	2014-02-07	67	73	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	58	61	40	27	56	58	53	26	23	25	13	6	6	9	10
94289	2014-01-17	67	73	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	58	61	40	27	56	58	53	26	23	25	13	6	6	9	10
94289	2014-01-10	67	73	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	58	61	40	23	56	58	53	22	20	25	13	6	6	9	10
94289	2013-11-01	67	73	left	high	low	61	52	48	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	58	61	34	25	56	58	53	25	25	25	13	6	6	9	10
94289	2013-09-20	67	73	left	high	low	61	52	49	63	59	77	64	60	51	70	91	92	84	60	79	70	68	74	58	61	33	25	56	58	53	25	25	25	13	6	6	9	10
94289	2013-05-17	66	70	left	high	low	61	61	49	63	59	72	64	60	51	66	90	88	84	60	79	67	68	74	58	62	33	17	56	58	59	19	16	12	13	6	6	9	10
94289	2013-03-22	65	70	left	high	low	61	61	49	62	59	71	64	60	51	64	90	88	84	58	79	67	68	74	58	62	33	17	54	58	59	19	16	12	13	6	6	9	10
94289	2013-03-15	65	70	left	high	low	61	61	49	62	59	71	64	60	51	64	90	88	84	58	79	67	68	74	58	62	33	17	54	58	59	19	16	12	13	6	6	9	10
94289	2013-03-08	65	70	left	high	low	61	61	49	62	59	71	64	60	51	64	90	88	84	58	79	67	68	74	58	62	33	17	54	58	59	19	16	12	13	6	6	9	10
94289	2013-03-01	65	70	left	high	low	61	61	49	63	58	71	64	60	51	64	90	88	84	58	79	67	68	74	58	62	33	17	54	58	59	19	16	12	13	6	6	9	10
94289	2013-02-15	65	69	left	medium	low	62	62	49	63	59	71	64	60	52	64	86	87	83	60	73	62	64	74	62	61	33	17	54	57	59	19	16	12	13	6	6	9	10
94289	2012-08-31	65	68	left	medium	medium	64	66	49	65	59	71	64	60	51	66	80	87	83	75	73	62	64	70	62	61	51	30	51	59	63	31	38	35	13	6	6	9	10
94289	2012-02-22	63	66	left	medium	medium	59	66	49	63	59	68	64	60	51	66	80	87	82	75	73	62	64	70	62	61	46	24	41	59	63	31	26	27	13	6	6	9	10
94289	2011-08-30	63	66	left	medium	medium	59	66	49	63	59	68	64	60	51	66	80	87	82	75	73	62	64	70	62	61	46	14	41	59	63	31	26	27	13	6	6	9	10
94289	2010-08-30	65	75	right	medium	medium	58	65	48	62	58	66	63	59	50	64	77	79	73	74	55	61	65	62	50	60	45	13	40	58	62	30	25	26	13	6	6	9	10
94289	2010-02-22	65	75	right	medium	medium	58	65	48	62	58	66	63	59	50	64	77	79	73	74	55	61	65	62	50	60	45	57	52	58	62	30	25	26	6	21	50	21	21
94289	2009-08-30	65	75	right	medium	medium	58	67	48	65	58	66	63	59	50	66	77	77	73	74	55	60	65	62	47	59	45	58	52	58	64	30	25	26	6	21	50	21	21
94289	2009-02-22	62	70	right	medium	medium	53	64	48	52	58	62	63	59	50	61	75	77	73	72	55	56	65	62	47	56	45	54	52	58	57	30	25	26	6	21	50	21	21
94289	2008-08-30	57	70	right	medium	medium	51	60	48	50	58	56	63	59	50	61	65	65	73	62	55	56	65	54	42	56	55	52	50	58	55	50	40	26	6	21	50	21	21
94289	2007-02-22	57	70	right	medium	medium	51	60	48	50	58	56	63	59	50	61	65	65	73	62	55	56	65	54	42	56	55	52	50	58	55	50	40	26	6	21	50	21	21
25957	2016-04-28	71	71	right	medium	low	57	72	81	70	66	66	63	57	57	71	51	53	58	68	51	73	73	68	84	69	77	48	76	67	70	41	51	38	8	8	14	8	15
25957	2016-04-21	72	72	right	medium	low	57	73	82	70	66	66	63	57	57	71	51	53	60	72	51	74	74	72	84	70	77	48	76	67	70	41	51	38	8	8	14	8	15
25957	2016-03-24	72	72	right	medium	low	57	73	82	70	66	66	63	57	57	71	51	53	60	72	51	74	74	72	84	70	77	48	76	70	70	41	51	38	8	8	14	8	15
25957	2016-01-28	72	72	right	medium	low	57	73	82	70	66	66	63	57	57	71	51	63	60	72	51	74	74	72	84	70	77	48	76	70	70	41	51	38	8	8	14	8	15
25957	2015-11-26	73	73	right	medium	low	57	73	85	73	69	67	63	57	57	73	51	63	60	72	51	74	78	75	84	70	77	48	78	74	70	41	51	38	8	8	14	8	15
25957	2015-10-02	74	74	right	medium	low	57	73	87	73	69	67	63	57	57	74	51	63	60	72	51	75	82	75	84	71	79	48	78	74	70	41	55	38	8	8	14	8	15
25957	2015-09-25	74	74	right	medium	low	57	74	87	73	69	65	63	57	57	73	51	63	60	72	51	75	82	75	84	71	79	48	78	72	70	41	55	38	8	8	14	8	15
25957	2015-09-21	74	74	right	high	medium	57	72	86	73	69	68	63	57	57	73	51	63	60	72	51	75	82	75	84	71	84	48	78	72	70	41	55	38	8	8	14	8	15
25957	2015-03-13	73	73	right	high	medium	64	71	90	72	66	69	64	56	66	73	64	67	62	72	57	73	90	75	84	67	87	47	75	71	69	40	54	37	7	7	13	7	14
25957	2014-11-07	73	73	right	high	medium	64	69	90	72	66	69	64	56	66	73	64	67	62	72	57	73	90	75	84	67	87	47	75	71	69	40	54	37	7	7	13	7	14
25957	2014-10-31	73	73	right	high	medium	64	69	90	72	66	69	64	56	66	73	64	67	62	72	57	73	90	75	84	67	87	47	75	71	69	40	54	37	7	7	13	7	14
25957	2014-09-18	73	73	right	high	medium	64	69	90	72	66	69	64	56	66	73	64	67	62	72	57	73	90	75	84	67	74	47	75	69	69	40	54	37	7	7	13	7	14
25957	2014-05-09	73	73	right	high	medium	64	69	90	73	66	70	64	56	67	73	65	67	64	73	63	74	87	77	84	67	74	47	75	69	69	40	44	37	7	7	13	7	14
25957	2014-03-21	73	73	right	high	medium	64	69	90	73	66	70	64	56	67	73	65	67	64	73	63	74	87	77	84	67	74	47	75	69	69	40	44	37	7	7	13	7	14
25957	2014-02-28	73	73	right	high	medium	64	69	90	72	66	69	64	56	66	73	64	67	62	72	57	73	87	75	84	67	74	47	75	69	69	40	44	37	7	7	13	7	14
25957	2013-12-13	73	73	right	high	medium	64	69	90	73	66	70	64	56	67	73	65	67	64	73	63	74	87	77	84	67	74	47	75	69	69	40	44	37	7	7	13	7	14
25957	2013-11-22	74	74	right	high	medium	64	70	90	74	66	71	64	56	67	73	65	67	64	74	63	75	87	77	84	67	74	47	75	69	69	40	44	37	7	7	13	7	14
25957	2013-09-20	73	73	right	high	medium	64	70	90	74	66	71	64	56	67	73	65	67	64	74	63	75	87	77	82	67	74	47	75	69	69	40	44	37	7	7	13	7	14
25957	2013-07-05	74	74	right	high	medium	64	72	90	74	68	72	64	56	67	74	66	68	70	74	62	75	87	77	81	67	68	47	75	69	69	40	44	37	7	7	13	7	14
25957	2013-04-19	74	74	right	high	medium	64	72	90	74	68	72	64	56	67	74	66	68	70	74	62	75	87	77	81	67	68	47	75	69	69	40	44	37	7	7	13	7	14
25957	2013-02-15	75	75	right	high	medium	64	74	90	74	68	73	64	56	67	75	66	68	70	74	62	76	87	77	81	67	68	47	75	69	69	40	44	37	7	7	13	7	14
25957	2012-08-31	75	75	right	high	medium	64	74	90	74	68	73	64	56	67	75	66	68	70	74	62	76	87	77	81	67	68	47	75	69	69	40	44	37	7	7	13	7	14
25957	2012-02-22	76	76	right	high	medium	64	76	90	74	66	74	69	57	66	73	67	68	71	78	61	77	90	78	81	70	68	55	76	73	68	36	49	42	7	7	13	7	14
25957	2011-08-30	76	76	right	high	medium	64	76	87	74	66	74	69	57	66	75	67	66	71	78	61	77	90	78	79	70	68	55	76	73	68	36	49	42	7	7	13	7	14
25957	2011-02-22	73	78	right	high	medium	66	69	84	75	66	70	63	57	66	76	72	73	74	75	79	78	86	86	81	74	81	55	71	75	68	36	49	42	7	7	13	7	14
25957	2010-08-30	74	78	right	high	medium	66	69	87	76	66	70	63	57	66	76	72	73	74	75	83	78	82	85	81	74	84	50	71	75	68	36	60	48	7	7	13	7	14
25957	2009-08-30	72	74	right	high	medium	58	68	85	70	66	72	63	51	59	77	76	72	74	73	83	69	82	83	82	68	72	73	74	75	69	26	59	48	11	20	59	20	20
25957	2009-02-22	71	74	right	high	medium	58	71	80	72	66	72	63	51	59	77	67	72	74	71	83	69	82	83	73	65	69	73	71	75	66	26	44	48	11	20	59	20	20
25957	2008-08-30	71	73	right	high	medium	58	71	80	70	66	72	63	51	59	77	66	71	74	69	83	69	82	75	74	65	59	69	67	75	68	26	44	48	11	20	59	20	20
25957	2007-08-30	72	72	left	high	medium	58	70	76	68	66	72	63	51	49	77	66	71	74	69	83	69	82	75	72	65	49	62	67	75	68	26	44	48	11	20	49	20	20
25957	2007-02-22	71	76	left	high	medium	57	69	75	67	66	71	63	67	48	76	65	70	74	68	83	68	82	74	71	64	48	62	67	75	67	25	43	48	11	14	48	7	13
37038	2011-02-22	61	68	right	\N	\N	39	21	63	56	32	36	33	39	46	48	46	48	43	46	71	56	51	51	73	37	64	76	36	66	45	56	63	61	12	7	10	6	7
37038	2010-08-30	63	66	right	\N	\N	39	21	63	56	32	36	33	39	46	48	53	58	51	54	73	56	58	56	76	37	69	68	36	58	45	63	64	62	12	7	10	6	7
37038	2009-08-30	63	66	right	\N	\N	39	21	63	56	32	36	33	39	46	48	53	58	51	54	73	56	58	56	76	37	69	60	63	58	61	62	63	62	8	23	46	23	23
37038	2008-08-30	62	63	right	\N	\N	40	21	62	56	32	36	33	39	41	48	61	62	51	54	73	62	58	60	75	37	69	57	53	58	61	61	62	62	8	23	41	23	23
37038	2007-08-30	65	65	right	\N	\N	42	41	59	61	32	46	33	39	41	50	63	64	51	57	73	22	58	70	69	37	69	57	53	58	61	68	67	62	8	23	41	23	23
37038	2007-02-22	65	66	right	\N	\N	42	41	59	61	32	46	33	61	41	50	63	64	51	57	73	22	58	70	69	37	69	57	53	58	61	68	67	62	8	14	41	6	12
164732	2015-09-21	72	72	right	high	medium	66	70	72	70	62	76	62	66	58	74	71	73	70	70	58	71	79	69	81	69	69	38	75	70	71	24	39	30	14	9	15	14	9
164732	2015-05-22	72	72	right	high	medium	65	72	71	68	61	73	61	65	57	73	71	73	70	69	61	71	76	72	81	68	68	43	75	67	68	23	40	39	13	8	14	13	8
164732	2015-05-01	72	72	right	high	medium	65	72	71	68	61	73	61	65	57	73	71	73	70	69	61	71	76	72	81	68	68	43	75	67	68	23	40	39	13	8	14	13	8
164732	2015-04-17	72	73	right	high	medium	65	72	71	68	61	73	61	65	57	73	71	73	70	69	61	71	76	72	81	68	68	43	75	67	68	23	40	39	13	8	14	13	8
164732	2014-10-24	73	74	right	high	medium	65	73	72	68	61	74	61	65	57	74	73	76	71	70	61	72	80	77	83	68	68	43	76	67	68	23	40	39	13	8	14	13	8
164732	2014-09-18	73	74	right	high	medium	65	73	72	68	61	74	61	65	57	74	73	76	71	70	61	72	80	77	83	68	68	43	76	67	68	23	40	39	13	8	14	13	8
164732	2014-02-14	74	75	right	high	medium	65	76	72	70	61	76	61	65	57	75	73	76	71	73	61	72	78	77	83	68	68	43	76	67	68	23	40	39	13	8	14	13	8
164732	2013-11-22	74	75	right	high	medium	65	76	72	70	61	76	61	65	57	75	73	76	71	73	61	72	78	77	83	68	68	43	76	67	68	23	40	39	13	8	14	13	8
164732	2013-11-01	74	75	right	high	medium	65	76	72	70	61	76	61	65	57	75	72	76	71	73	61	72	78	77	83	68	68	43	76	67	68	23	40	39	13	8	14	13	8
164732	2013-09-20	74	75	right	high	medium	65	76	72	70	61	76	61	65	57	75	72	76	71	73	61	72	78	77	83	68	68	43	76	67	58	23	40	39	13	8	14	13	8
164732	2013-06-07	73	75	right	high	medium	65	73	72	68	71	75	56	56	57	74	69	75	71	72	61	72	77	77	83	69	68	43	74	64	58	23	40	45	13	8	14	13	8
164732	2013-05-31	73	76	right	high	medium	65	73	72	68	71	75	56	56	57	74	69	75	71	72	61	72	77	77	83	69	68	43	74	64	58	23	40	45	13	8	14	13	8
164732	2013-05-17	72	74	right	high	medium	65	73	72	68	71	75	56	56	57	73	69	75	71	69	61	72	77	77	83	69	68	43	72	61	58	23	40	45	13	8	14	13	8
164732	2013-03-28	72	74	right	high	medium	65	73	72	68	71	75	56	56	57	73	69	75	71	69	61	72	77	77	83	69	68	43	72	61	58	23	40	45	13	8	14	13	8
164732	2013-03-22	72	74	right	high	medium	65	73	72	68	71	75	56	56	57	73	69	75	71	69	61	72	77	77	83	69	68	43	72	61	58	23	40	45	13	8	14	13	8
164732	2013-03-01	71	73	right	high	medium	65	71	72	68	71	75	56	56	57	73	69	75	71	65	61	72	77	77	83	69	68	43	71	59	58	23	40	45	13	8	14	13	8
164732	2013-02-22	71	73	right	high	medium	65	71	73	68	69	77	56	56	57	75	65	75	71	64	61	72	72	77	83	66	68	43	71	57	58	23	40	45	13	8	14	13	8
164732	2013-02-15	71	73	right	high	medium	65	71	73	68	69	77	56	56	57	75	65	75	71	64	61	72	72	77	83	66	68	43	71	57	58	23	40	45	13	8	14	13	8
164732	2012-08-31	69	72	right	high	high	63	69	67	64	63	75	56	56	55	72	77	78	74	68	52	68	73	76	80	63	67	43	68	54	58	23	40	45	13	8	14	13	8
164732	2012-02-22	68	72	right	medium	medium	61	64	64	64	63	75	56	56	55	72	77	78	74	68	51	68	69	76	80	63	67	31	62	52	58	13	40	27	13	8	14	13	8
164732	2011-08-30	69	70	left	high	medium	61	65	64	64	63	75	56	56	55	72	75	79	81	68	51	68	69	79	81	63	67	31	70	57	58	30	40	27	13	8	14	13	8
164732	2011-02-22	66	71	left	high	medium	60	61	62	62	56	73	56	56	52	68	71	73	72	68	68	68	65	63	73	65	67	31	57	55	58	30	40	27	13	8	14	13	8
164732	2010-08-30	66	71	right	high	medium	52	61	68	56	56	73	56	56	44	68	71	73	82	68	69	68	64	65	68	65	67	41	62	49	58	30	40	27	13	8	14	13	8
164732	2009-08-30	61	70	right	high	medium	52	61	68	48	56	65	56	56	41	60	59	63	82	59	69	59	64	62	68	65	67	43	52	49	47	30	40	27	5	23	41	23	23
164732	2007-02-22	61	70	right	high	medium	52	61	68	48	56	65	56	56	41	60	59	63	82	59	69	59	64	62	68	65	67	43	52	49	47	30	40	27	5	23	41	23	23
148327	2010-02-22	64	70	left	\N	\N	62	62	42	60	\N	65	\N	54	47	60	77	74	\N	64	\N	57	\N	64	52	60	47	55	62	\N	60	27	21	\N	6	21	47	21	21
148327	2009-08-30	65	70	left	\N	\N	62	64	42	60	\N	65	\N	54	47	60	79	77	\N	62	\N	57	\N	67	52	60	67	55	64	\N	60	27	21	\N	6	21	47	21	21
148327	2008-08-30	64	70	left	\N	\N	62	64	42	55	\N	65	\N	54	47	60	75	77	\N	62	\N	57	\N	67	52	60	37	55	54	\N	60	27	21	\N	6	21	47	21	21
148327	2007-02-22	64	70	left	\N	\N	62	64	42	55	\N	65	\N	54	47	60	75	77	\N	62	\N	57	\N	67	52	60	37	55	54	\N	60	27	21	\N	6	21	47	21	21
30910	2013-09-20	67	67	left	medium	medium	65	60	38	76	62	62	75	82	74	74	28	33	39	44	63	63	25	38	62	64	46	42	72	82	64	23	30	25	15	8	8	10	9
30910	2013-05-24	68	68	left	medium	medium	65	60	38	77	62	62	75	82	78	72	38	33	48	58	63	63	25	42	62	64	46	42	72	82	64	23	37	30	15	8	8	10	9
30910	2013-05-10	68	68	left	medium	medium	65	60	38	77	62	62	75	82	78	72	38	33	48	58	63	63	25	42	62	64	46	42	72	82	64	23	37	30	15	8	8	10	9
30910	2013-03-28	69	69	left	medium	medium	67	63	38	77	62	62	75	82	78	72	38	33	48	61	63	65	30	44	65	67	46	42	72	82	64	23	37	30	15	8	8	10	9
30910	2013-03-08	69	69	left	medium	medium	67	63	38	77	62	62	75	82	78	72	38	33	48	61	63	65	30	44	65	67	46	42	72	82	64	23	37	30	15	8	8	10	9
30910	2013-02-15	69	69	left	medium	medium	67	63	38	77	62	62	75	82	78	72	38	33	48	61	63	65	30	44	65	67	46	42	72	82	64	23	37	30	15	8	8	10	9
30910	2012-08-31	67	67	left	medium	medium	60	63	38	73	62	64	68	72	71	73	38	34	48	61	62	65	20	48	65	60	46	42	74	75	64	23	37	30	15	8	8	10	9
30910	2012-02-22	68	68	left	medium	medium	74	60	53	75	69	65	74	77	77	74	39	34	52	67	62	73	35	52	65	73	46	54	64	75	72	23	42	35	15	8	8	10	9
30910	2011-08-30	70	70	left	medium	medium	71	63	53	74	69	67	73	76	75	75	49	51	60	63	69	73	45	64	70	73	46	44	67	75	72	35	46	42	15	8	8	10	9
30910	2010-08-30	69	72	left	medium	medium	71	63	53	74	69	67	73	76	75	74	56	53	60	63	67	73	53	64	62	73	46	64	67	75	72	35	46	42	15	8	8	10	9
30910	2010-02-22	70	74	left	medium	medium	71	62	53	74	69	67	73	78	75	75	57	53	60	64	67	73	53	65	62	74	46	78	72	75	73	35	46	42	8	22	75	22	22
30910	2009-08-30	71	74	left	medium	medium	72	64	54	75	69	67	73	78	77	75	58	53	60	62	67	75	53	65	62	74	46	78	72	75	73	37	46	42	8	22	77	22	22
30910	2009-02-22	70	74	left	medium	medium	72	64	61	75	69	67	73	80	78	75	58	53	60	62	67	77	53	65	62	78	51	74	72	75	73	37	51	42	8	22	78	22	22
30910	2008-08-30	72	74	left	medium	medium	73	68	66	77	69	73	73	80	81	75	61	60	60	70	67	81	53	66	67	78	55	73	72	75	73	48	56	42	8	22	81	22	22
30910	2007-08-30	75	76	left	medium	medium	73	71	73	78	69	73	73	75	81	75	64	61	60	70	67	81	53	68	75	80	75	73	66	75	73	63	68	42	13	22	81	22	22
30910	2007-02-22	75	76	left	medium	medium	73	71	73	78	69	73	73	73	81	75	64	61	60	70	67	81	53	68	75	80	75	73	66	75	73	63	68	42	13	15	81	16	15
163670	2016-05-12	81	82	right	high	medium	83	76	78	79	83	82	73	76	76	81	83	84	74	76	67	83	83	82	75	82	59	42	81	79	76	26	35	34	6	7	10	9	6
163670	2016-05-05	81	82	right	high	medium	83	76	78	79	83	82	73	76	76	81	83	84	74	76	67	83	83	82	75	82	59	42	81	79	76	26	41	39	6	7	10	9	6
163670	2016-04-28	81	82	right	high	medium	83	76	80	79	83	82	73	76	76	81	83	84	74	76	67	83	83	82	75	82	59	42	81	79	76	26	41	39	6	7	10	9	6
163670	2016-04-21	81	82	right	high	medium	83	76	80	79	83	82	73	76	76	81	83	84	74	76	67	83	83	82	75	82	59	52	81	79	76	26	41	39	6	7	10	9	6
163670	2016-03-31	81	82	right	high	medium	83	76	80	79	83	82	76	76	76	81	83	84	74	76	67	83	83	82	75	82	67	52	81	79	76	26	41	39	6	7	10	9	6
163670	2016-02-04	81	82	right	high	high	83	76	80	79	83	82	76	76	76	81	83	84	74	76	67	83	83	82	75	82	67	52	81	79	76	26	41	39	6	7	10	9	6
163670	2016-01-28	82	84	right	high	high	83	78	80	79	85	82	76	76	76	81	83	84	74	80	67	83	83	82	75	82	67	52	81	79	76	26	41	39	6	7	10	9	6
163670	2016-01-21	81	83	right	high	high	83	78	80	79	85	82	76	76	76	81	83	78	74	80	67	83	83	81	75	82	67	52	81	79	76	26	41	39	6	7	10	9	6
163670	2016-01-14	81	83	right	medium	medium	83	78	80	79	85	82	76	76	76	81	83	78	74	80	67	83	83	81	75	82	67	52	81	79	76	26	41	39	6	7	10	9	6
163670	2015-09-21	81	83	right	medium	medium	83	78	80	79	85	80	76	76	76	80	83	78	74	80	67	83	83	77	75	82	67	52	81	79	76	26	41	39	6	7	10	9	6
163670	2014-12-05	79	82	right	medium	medium	80	78	81	78	85	78	76	76	75	79	83	78	75	79	67	83	82	77	75	82	65	52	81	78	73	26	41	36	6	7	10	9	6
163670	2014-11-28	78	82	right	medium	medium	80	78	81	78	85	78	76	76	75	79	83	78	75	79	67	83	82	77	75	82	65	52	80	77	73	26	41	36	6	7	10	9	6
163670	2014-09-18	78	82	right	medium	medium	79	78	81	77	85	78	76	76	74	77	83	78	75	79	67	83	82	77	75	81	65	52	79	75	73	26	41	36	6	7	10	9	6
163670	2014-05-16	77	81	right	medium	medium	78	78	81	77	85	78	76	76	74	77	83	78	76	79	67	83	82	75	75	81	64	52	77	75	73	26	41	36	6	7	10	9	6
163670	2014-01-31	77	81	right	medium	medium	78	78	81	76	85	78	76	76	73	77	83	78	75	77	67	83	82	74	73	81	64	52	77	74	73	26	41	36	6	7	10	9	6
163670	2013-09-20	77	82	right	medium	medium	78	78	81	76	85	78	76	76	73	77	83	78	75	77	67	83	82	74	73	81	64	52	77	74	73	26	41	36	6	7	10	9	6
163670	2013-02-15	77	83	right	medium	medium	78	79	81	76	85	78	76	76	73	77	83	78	75	77	67	83	82	74	73	81	64	52	77	74	73	26	41	36	6	7	10	9	6
163670	2012-08-31	78	83	right	medium	medium	78	81	82	78	85	79	76	76	74	77	82	81	74	78	66	81	82	74	74	81	60	52	82	74	73	26	51	41	6	7	10	9	6
163670	2012-02-22	77	84	right	medium	medium	77	81	82	77	83	77	70	73	73	78	76	80	69	76	66	83	81	76	76	81	58	56	83	75	71	36	54	45	6	7	10	9	6
163670	2011-08-30	77	84	right	medium	medium	78	81	82	77	73	77	69	73	73	78	76	80	69	74	64	75	80	75	77	76	58	56	83	75	69	36	54	45	6	7	10	9	6
163670	2011-02-22	71	79	right	medium	medium	67	71	74	71	69	72	69	69	68	75	62	67	65	67	65	70	70	77	69	72	57	53	73	72	67	34	49	44	6	7	10	9	6
163670	2010-08-30	72	79	right	medium	medium	67	72	76	71	71	72	69	69	69	75	62	68	65	67	65	70	70	77	69	73	57	53	69	73	67	34	49	44	6	7	10	9	6
163670	2010-02-22	72	79	right	medium	medium	67	72	76	71	71	72	69	69	69	75	62	68	65	67	65	70	70	77	67	73	57	68	69	73	72	34	49	44	12	20	69	20	20
163670	2009-08-30	67	79	right	medium	medium	62	67	64	67	71	66	69	69	65	71	66	68	65	67	65	65	70	71	61	72	57	63	61	73	59	24	39	44	2	20	65	20	20
163670	2009-02-22	60	79	right	medium	medium	56	57	62	58	71	60	69	69	57	64	64	66	65	61	65	60	70	63	62	66	35	54	49	73	54	34	39	44	2	20	57	20	20
163670	2008-08-30	56	79	right	medium	medium	51	67	61	48	71	59	69	40	28	54	56	47	65	56	65	59	70	33	27	53	35	24	14	73	20	20	20	44	2	20	28	20	20
163670	2007-08-30	57	79	right	medium	medium	51	67	61	48	71	59	69	40	28	54	56	47	65	56	65	59	70	33	27	53	35	24	14	73	20	20	20	44	2	20	28	20	20
163670	2007-02-22	57	79	right	medium	medium	51	67	61	48	71	59	69	40	28	54	56	47	65	56	65	59	70	33	27	53	35	24	14	73	20	20	20	44	2	20	28	20	20
15652	2008-08-30	56	64	right	\N	\N	39	29	57	54	\N	27	\N	41	47	51	58	60	\N	56	\N	56	\N	61	66	27	56	59	56	\N	60	50	56	\N	7	22	47	22	22
15652	2007-02-22	56	64	right	\N	\N	39	29	57	54	\N	27	\N	41	47	51	58	60	\N	56	\N	56	\N	61	66	27	56	59	56	\N	60	50	56	\N	7	22	47	22	22
50160	2013-05-10	64	64	right	medium	low	33	65	70	51	64	58	36	51	34	62	67	72	46	55	64	71	71	47	72	60	63	31	64	57	59	13	24	11	14	15	13	10	13
50160	2013-02-15	65	65	right	medium	low	33	67	70	51	66	58	36	51	34	62	67	72	46	56	64	72	71	47	72	60	64	31	66	57	59	13	24	11	14	15	13	10	13
50160	2012-08-31	66	66	right	medium	low	33	69	70	51	66	58	36	51	34	62	71	74	46	56	63	73	71	54	72	60	65	31	67	57	59	13	24	11	14	15	13	10	13
50160	2012-02-22	67	67	right	medium	medium	33	71	72	51	66	58	36	51	34	62	73	75	46	56	63	73	74	54	72	60	65	31	69	57	59	13	24	11	14	15	13	10	13
50160	2011-08-30	67	69	right	medium	medium	33	71	72	51	66	58	36	51	34	62	73	75	46	56	63	73	74	55	72	60	65	31	69	57	59	13	24	11	14	15	13	10	13
50160	2011-02-22	67	71	right	medium	medium	33	72	73	51	66	58	36	51	34	63	72	74	53	56	67	74	69	60	73	60	65	31	69	57	59	13	24	11	14	15	13	10	13
50160	2010-08-30	68	72	right	medium	medium	33	74	74	51	66	58	36	51	34	63	76	79	53	56	67	74	69	67	73	60	65	31	69	57	59	13	24	11	14	15	13	10	13
50160	2009-08-30	69	74	right	medium	medium	33	76	74	51	66	58	36	51	34	63	76	79	53	56	67	74	69	67	73	60	65	48	68	57	64	22	24	11	2	22	34	22	22
50160	2008-08-30	62	65	right	medium	medium	33	62	74	51	66	48	36	51	34	46	71	74	53	56	67	67	69	63	73	60	65	56	58	57	59	22	24	11	2	22	34	22	22
50160	2007-02-22	62	65	right	medium	medium	33	62	74	51	66	48	36	51	34	46	71	74	53	56	67	67	69	63	73	60	65	56	58	57	59	22	24	11	2	22	34	22	22
167619	2010-02-22	58	68	right	\N	\N	47	37	53	49	\N	31	\N	39	45	45	61	66	\N	60	\N	65	\N	64	73	34	69	57	61	\N	47	57	59	\N	8	23	45	23	23
167619	2009-08-30	55	60	right	\N	\N	31	37	51	49	\N	31	\N	37	45	45	61	65	\N	60	\N	45	\N	64	63	34	69	57	61	\N	32	55	54	\N	8	23	45	23	23
167619	2007-02-22	55	60	right	\N	\N	31	37	51	49	\N	31	\N	37	45	45	61	65	\N	60	\N	45	\N	64	63	34	69	57	61	\N	32	55	54	\N	8	23	45	23	23
30949	2016-02-18	67	67	right	low	medium	53	47	60	68	66	50	58	48	63	68	34	33	57	68	63	80	68	56	72	58	80	73	46	59	46	65	68	64	12	14	16	11	11
30949	2015-12-24	67	67	right	low	medium	53	47	60	68	66	50	58	48	63	68	34	33	61	68	63	80	68	56	72	58	80	73	46	59	46	65	68	64	12	14	16	11	11
30949	2015-12-10	68	68	right	low	medium	53	47	61	70	66	50	58	48	65	68	34	33	61	68	63	80	68	56	72	60	80	75	47	60	46	65	69	65	12	14	16	11	11
30949	2015-11-19	68	68	right	low	medium	53	47	61	70	66	50	58	48	65	68	35	33	61	68	63	80	68	56	72	60	80	75	47	60	46	65	69	65	12	14	16	11	11
30949	2015-11-12	69	69	right	low	medium	53	47	61	70	66	50	58	48	65	69	35	33	61	68	63	80	68	57	73	64	80	75	50	60	46	65	70	66	12	14	16	11	11
30949	2015-10-30	69	69	right	low	medium	53	47	61	70	66	50	58	50	65	69	35	33	61	68	63	80	68	57	75	64	81	75	56	60	46	65	70	66	12	14	16	11	11
30949	2015-10-23	69	69	right	low	medium	53	47	61	70	66	50	58	54	65	70	35	33	62	69	63	82	70	60	75	64	81	76	56	60	46	65	70	66	12	14	16	11	11
30949	2015-10-09	69	69	right	low	medium	53	47	61	70	66	50	58	54	65	70	35	33	62	69	63	82	70	60	75	68	81	76	56	60	46	65	70	66	12	14	16	11	11
30949	2015-10-02	70	70	right	low	medium	53	47	61	70	66	53	58	54	68	70	35	33	62	72	66	82	70	65	75	68	81	76	56	64	46	65	71	66	12	14	16	11	11
30949	2015-09-21	70	70	right	low	medium	53	47	61	70	66	53	58	54	68	70	43	50	62	72	66	82	70	65	75	68	81	76	56	64	46	65	71	66	12	14	16	11	11
30949	2014-10-17	72	72	right	low	medium	55	48	68	72	65	54	59	65	70	71	52	55	64	74	68	83	73	68	77	73	80	78	58	63	51	68	76	73	11	13	15	10	10
30949	2014-10-02	72	72	right	low	medium	55	48	68	73	65	54	59	65	70	72	52	55	64	75	68	83	73	68	77	73	80	76	58	63	51	68	76	73	11	13	15	10	10
30949	2014-09-18	72	72	right	low	medium	55	48	68	73	65	54	59	65	70	72	52	55	64	75	68	83	73	68	77	73	80	76	58	63	51	68	76	73	11	13	15	10	10
30949	2014-01-03	72	72	right	medium	medium	55	48	68	73	65	54	59	65	70	72	62	55	64	75	68	83	73	68	77	73	80	76	58	63	51	68	76	73	11	13	15	10	10
30949	2013-09-20	74	74	right	medium	medium	55	48	68	73	65	54	59	65	70	72	63	55	64	75	68	83	74	84	77	73	80	76	58	63	51	69	76	73	11	13	15	10	10
30949	2013-05-10	74	74	right	medium	medium	55	48	68	73	65	64	59	65	70	72	63	55	64	73	63	83	74	84	76	73	78	75	60	72	51	67	76	72	11	13	15	10	10
30949	2013-03-01	74	74	right	medium	medium	55	48	68	73	65	64	59	65	70	72	63	55	64	73	63	83	74	84	76	73	78	75	60	72	51	67	76	72	11	13	15	10	10
30949	2013-02-15	74	74	right	medium	medium	55	48	68	73	65	64	59	65	70	72	63	55	64	73	63	83	74	84	76	73	78	75	66	72	51	67	76	72	11	13	15	10	10
30949	2012-08-31	74	74	right	medium	medium	55	52	68	73	69	64	59	65	70	72	63	55	64	73	63	83	74	84	76	73	78	75	66	72	64	67	76	72	11	13	15	10	10
30949	2012-02-22	74	74	right	medium	medium	55	59	68	73	69	64	59	65	70	72	63	55	64	73	63	85	74	84	76	73	78	75	66	72	64	67	76	72	11	13	15	10	10
30949	2011-08-30	73	73	right	medium	medium	55	59	69	73	69	65	59	65	70	72	66	58	64	72	63	85	74	84	73	73	77	75	66	72	64	63	75	72	11	13	15	10	10
30949	2011-02-22	73	77	right	medium	medium	55	59	69	73	69	65	59	65	70	72	73	75	68	72	80	85	71	84	78	75	77	75	67	74	64	62	75	72	11	13	15	10	10
30949	2010-08-30	75	77	right	medium	medium	69	57	67	76	69	67	59	65	74	74	75	77	71	73	81	85	71	84	78	72	79	75	67	76	64	70	75	74	11	13	15	10	10
30949	2010-02-22	75	78	right	medium	medium	69	57	67	76	69	65	59	65	74	74	75	77	71	73	81	85	71	85	78	72	79	82	83	76	76	70	75	74	7	22	74	22	22
30949	2009-02-22	75	78	right	medium	medium	70	53	67	78	69	65	59	65	75	75	75	77	71	73	81	85	71	85	78	69	79	82	83	76	76	72	76	74	14	22	75	22	22
30949	2008-08-30	75	78	right	medium	medium	70	47	67	78	69	65	59	56	75	75	75	77	71	73	81	85	71	85	78	67	79	82	83	76	76	72	76	74	14	22	75	22	22
30949	2007-08-30	78	78	left	medium	medium	77	47	67	81	69	68	59	54	76	78	76	77	71	68	81	86	71	83	76	62	74	82	84	76	76	77	75	74	14	22	76	22	22
30949	2007-02-22	77	89	left	medium	medium	79	29	69	83	69	48	59	76	77	86	78	79	71	77	81	88	71	81	78	51	74	82	84	76	76	79	76	74	14	6	77	13	8
12381	2010-02-22	59	68	right	\N	\N	24	21	21	21	\N	21	\N	24	53	22	53	50	\N	48	\N	21	\N	49	85	21	35	32	27	\N	27	21	21	\N	63	56	53	60	59
12381	2008-08-30	59	68	right	\N	\N	24	21	21	21	\N	21	\N	24	53	22	53	50	\N	48	\N	21	\N	49	85	21	35	32	27	\N	27	21	21	\N	63	56	53	60	59
12381	2007-02-22	59	68	right	\N	\N	24	21	21	21	\N	21	\N	24	53	22	53	50	\N	48	\N	21	\N	49	85	21	35	32	27	\N	27	21	21	\N	63	56	53	60	59
37976	2008-08-30	64	68	right	\N	\N	53	46	68	55	\N	51	\N	42	56	56	63	61	\N	61	\N	60	\N	55	68	48	68	43	52	\N	57	63	66	\N	5	22	56	22	22
37976	2008-02-22	66	73	right	\N	\N	54	49	71	55	\N	54	\N	42	56	61	65	63	\N	61	\N	59	\N	55	72	55	69	43	52	\N	57	65	67	\N	5	22	56	22	22
37976	2007-02-22	66	73	right	\N	\N	54	49	71	55	\N	54	\N	42	56	61	65	63	\N	61	\N	59	\N	55	72	55	69	43	52	\N	57	65	67	\N	5	22	56	22	22
148960	2011-02-22	66	72	right	\N	\N	34	66	60	46	54	71	47	46	29	72	76	73	75	66	68	67	72	59	69	56	31	19	67	45	62	18	13	12	14	10	10	11	10
148960	2010-08-30	64	67	right	\N	\N	34	66	60	46	54	62	47	46	29	59	76	73	71	66	68	67	72	59	69	56	31	19	67	45	62	18	15	12	14	10	6	11	10
148960	2010-02-22	66	69	right	\N	\N	36	68	62	48	54	64	47	48	31	61	78	75	71	68	68	69	72	61	71	58	33	45	57	45	62	22	22	12	5	22	31	22	22
148960	2009-08-30	62	66	right	\N	\N	36	66	62	48	54	61	47	48	31	57	73	68	71	56	68	64	72	57	72	54	33	45	56	45	62	22	22	12	5	22	31	22	22
148960	2008-08-30	59	66	right	\N	\N	46	57	59	48	54	58	47	54	41	57	69	66	71	56	68	62	72	61	69	55	49	43	54	45	42	22	22	12	5	22	41	22	22
148960	2007-02-22	59	66	right	\N	\N	46	57	59	48	54	58	47	54	41	57	69	66	71	56	68	62	72	61	69	55	49	43	54	45	42	22	22	12	5	22	41	22	22
38343	2011-08-30	62	62	left	medium	medium	63	56	56	62	52	54	53	57	60	61	63	62	66	63	82	63	67	66	42	59	64	65	52	65	62	62	61	63	10	8	12	11	9
38343	2011-02-22	62	65	left	medium	medium	63	56	56	62	52	54	53	57	60	61	62	65	64	63	60	63	64	74	53	59	64	65	62	65	62	62	61	63	10	8	12	11	9
38343	2010-08-30	64	65	left	medium	medium	63	43	57	61	38	54	53	57	58	61	63	67	65	64	61	59	69	78	59	54	65	65	62	63	62	67	63	64	10	8	12	11	9
38343	2009-08-30	64	65	left	medium	medium	63	43	57	61	38	54	53	57	58	61	63	67	65	64	61	59	69	78	59	54	65	64	68	63	67	67	63	64	7	25	58	25	25
38343	2008-08-30	64	65	left	medium	medium	63	62	59	63	38	58	53	58	58	60	72	67	65	64	61	66	69	83	54	61	65	62	60	63	67	44	64	64	7	25	58	25	25
38343	2007-08-30	64	65	left	medium	medium	63	62	59	63	38	58	53	58	58	60	72	67	65	64	61	66	69	83	54	61	65	62	60	63	67	44	64	64	7	25	58	25	25
38343	2007-02-22	67	69	left	medium	medium	63	62	59	63	38	68	53	65	51	62	61	68	65	64	61	66	69	83	54	61	58	62	60	63	65	44	64	64	7	15	51	8	6
33620	2016-06-09	75	75	left	high	high	62	54	84	70	72	62	59	60	70	68	65	72	59	76	42	77	85	86	91	68	86	65	73	63	63	66	72	72	6	11	6	9	15
33620	2016-05-12	75	75	left	high	high	73	54	84	75	72	62	59	60	73	68	65	72	59	76	42	83	85	86	91	68	86	65	73	71	63	66	72	72	6	11	6	9	15
33620	2016-03-17	75	75	left	high	high	73	54	84	75	72	54	59	60	73	68	65	72	59	76	42	83	85	86	91	68	86	65	73	71	63	66	72	72	6	11	6	9	15
33620	2016-02-04	75	75	left	high	high	73	67	84	75	72	68	59	60	73	68	65	72	59	76	42	83	85	86	91	68	86	65	73	71	63	66	72	72	6	11	6	9	15
33620	2016-01-28	72	72	left	high	high	73	67	84	75	72	68	59	60	73	68	65	72	59	76	42	83	85	86	91	68	86	65	73	71	63	66	72	72	6	11	6	9	15
33620	2015-10-30	72	72	left	high	high	73	67	84	75	72	68	59	60	73	68	65	72	59	76	42	83	85	86	91	68	86	65	73	71	63	66	72	72	6	11	6	9	15
33620	2015-09-21	72	72	left	high	high	73	67	84	75	71	68	59	60	73	68	65	73	59	76	42	83	90	86	91	68	86	65	73	71	63	66	72	72	6	11	6	9	15
33620	2015-05-08	72	72	left	high	high	72	66	84	74	70	67	58	59	72	67	65	74	59	75	42	82	87	92	91	67	85	64	72	70	62	62	69	68	5	10	5	8	14
33620	2015-04-17	73	73	left	high	high	72	66	84	74	70	67	58	59	72	67	67	75	59	77	42	82	88	94	92	67	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2014-09-18	73	73	left	high	high	72	66	84	74	68	67	58	59	72	67	67	75	59	77	42	82	88	94	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2014-01-03	73	73	left	high	high	72	66	84	74	64	67	58	59	72	67	67	75	59	77	42	82	85	95	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2013-11-15	73	73	left	high	high	72	66	84	74	64	67	58	59	72	67	67	75	59	77	42	82	85	95	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2013-11-01	73	73	left	high	high	72	66	84	74	64	67	58	59	72	67	69	75	59	77	42	82	85	95	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2013-09-20	73	73	left	high	high	72	66	84	74	64	67	58	59	72	67	69	74	59	77	42	82	85	95	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2013-05-31	73	73	left	high	high	72	66	82	74	64	67	58	59	72	69	69	74	59	77	42	82	85	95	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2013-02-15	73	73	left	high	high	72	66	82	74	64	67	58	59	72	69	69	74	59	77	42	82	85	95	92	65	87	64	72	70	62	62	69	68	5	10	5	8	14
33620	2012-08-31	73	74	left	high	high	72	66	82	74	64	67	58	59	72	69	69	75	64	77	43	82	84	95	92	65	91	68	72	73	62	62	69	68	5	10	5	8	14
33620	2012-02-22	72	74	left	high	high	71	66	84	72	64	65	58	59	70	67	67	75	60	75	43	82	85	94	92	65	92	71	72	73	62	62	70	69	5	10	5	8	14
33620	2011-08-30	71	74	left	high	high	71	66	84	72	64	65	58	59	70	67	67	77	65	75	43	82	84	94	92	65	92	71	72	73	62	62	71	69	5	10	5	8	14
33620	2011-02-22	73	75	left	high	high	62	62	79	67	63	64	57	56	64	63	65	71	60	67	85	79	72	85	89	64	87	72	67	73	54	69	73	72	5	10	5	8	14
33620	2010-08-30	73	75	left	high	high	62	62	79	67	63	64	57	56	64	63	65	71	60	67	85	79	72	90	89	64	87	72	67	73	54	69	73	72	5	10	5	8	14
33620	2010-02-22	72	74	left	high	high	67	57	79	65	63	62	57	51	64	61	61	74	60	65	85	77	72	91	89	56	87	74	67	73	78	67	72	72	14	21	64	21	21
33620	2009-08-30	72	74	left	high	high	67	57	79	65	63	62	57	51	64	61	61	73	60	65	85	77	72	91	89	56	87	74	67	73	78	67	72	72	14	21	64	21	21
33620	2008-08-30	72	74	left	high	high	63	56	79	63	63	62	57	51	60	60	57	67	60	65	85	77	72	91	89	56	84	71	65	73	78	72	74	72	14	21	60	21	21
33620	2007-08-30	73	74	left	high	high	63	42	70	58	63	64	57	37	59	69	63	72	60	55	85	68	72	84	77	33	82	69	65	73	76	73	75	72	14	21	59	21	21
33620	2007-02-22	73	74	left	high	high	63	42	70	58	63	64	57	76	59	69	63	72	60	55	85	68	72	84	77	33	82	69	65	73	76	73	75	72	14	6	59	11	6
38782	2015-12-24	75	76	right	high	high	67	80	72	72	83	68	72	70	68	73	63	66	74	81	73	75	70	85	61	76	64	48	82	73	75	33	39	40	11	8	13	9	13
38782	2015-09-21	75	76	right	high	high	67	80	72	72	83	68	72	70	68	73	63	66	74	81	73	75	70	85	61	76	64	48	82	73	75	33	39	40	11	8	13	9	13
38782	2015-07-03	72	75	right	high	high	66	69	71	71	83	63	71	69	67	71	63	66	74	80	73	73	70	85	58	78	63	47	83	73	74	32	38	39	10	7	12	8	12
38782	2015-01-16	72	75	right	high	high	66	69	71	71	83	63	71	69	67	71	63	66	74	80	73	73	70	85	58	78	63	47	83	73	74	32	38	39	10	7	12	8	12
38782	2014-09-18	74	77	right	high	high	66	79	71	71	83	63	71	69	67	71	63	66	74	80	73	73	70	85	58	78	63	47	83	73	74	32	38	39	10	7	12	8	12
38782	2014-02-07	76	79	right	high	high	66	86	71	73	83	63	71	69	67	71	63	66	74	80	73	73	69	84	58	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-12-13	76	79	right	high	high	66	86	68	73	83	63	71	69	67	71	63	66	74	80	73	73	69	84	58	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-11-01	76	78	right	high	high	66	86	68	73	83	63	71	69	67	71	63	66	74	80	73	73	69	84	58	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-09-20	75	78	right	high	high	66	86	66	73	83	63	71	69	67	71	63	68	71	80	73	73	69	84	58	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-05-31	75	79	right	high	high	66	86	66	73	83	63	71	69	67	69	63	68	71	80	73	73	67	84	57	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-03-22	75	79	right	high	high	66	86	66	73	83	63	71	69	67	69	63	68	71	80	73	73	67	84	57	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-03-08	75	79	right	high	high	66	86	66	73	83	63	71	69	67	69	63	68	71	80	73	73	67	84	57	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-02-22	75	79	right	high	high	66	86	66	73	83	63	71	69	67	69	63	68	71	80	73	73	67	84	57	78	63	56	83	73	74	32	38	39	10	7	12	8	12
38782	2013-02-15	75	79	right	high	high	66	86	66	73	83	63	71	69	67	69	62	65	68	80	73	76	63	84	57	78	66	56	83	73	74	39	48	49	10	7	12	8	12
38782	2012-08-31	74	79	right	high	high	66	83	66	73	81	63	71	69	67	69	62	67	68	80	71	73	63	83	53	78	66	56	83	73	74	39	48	49	10	7	12	8	12
38782	2012-02-22	73	79	right	high	high	66	81	61	73	81	63	71	69	68	69	62	67	68	77	81	73	63	84	56	78	66	56	83	72	74	39	48	49	10	7	12	8	12
38782	2011-08-30	73	79	right	high	high	66	81	61	73	80	63	71	69	68	69	62	65	68	77	81	73	63	84	54	78	66	56	83	72	74	39	48	49	10	7	12	8	12
38782	2011-02-22	71	76	right	high	high	65	83	66	72	73	63	71	69	67	69	60	67	65	73	56	72	64	78	58	76	67	48	77	70	74	39	48	49	10	7	12	8	12
38782	2010-08-30	67	72	right	high	high	58	73	63	65	63	64	59	62	55	64	64	65	67	68	61	66	62	68	64	68	56	43	69	61	67	19	24	22	10	7	12	8	12
38782	2009-08-30	64	72	right	high	high	53	68	63	55	63	64	59	61	45	63	64	65	67	68	61	65	62	63	58	66	40	57	62	61	60	23	24	22	9	23	45	23	23
38782	2008-08-30	63	72	right	high	high	48	66	59	47	63	64	59	46	45	61	64	75	67	68	61	62	62	72	60	58	65	60	52	61	54	23	34	22	13	23	45	23	23
38782	2007-08-30	63	72	right	high	high	38	63	53	47	63	56	59	43	40	57	64	75	67	68	61	60	62	72	60	58	63	60	49	61	54	23	34	22	13	23	40	23	23
38782	2007-02-22	58	72	right	high	high	38	55	39	37	63	42	59	54	30	50	54	75	67	68	61	60	62	72	60	44	63	60	49	61	54	18	34	22	13	8	30	6	14
94288	2011-02-22	60	69	left	\N	\N	56	31	52	54	35	54	49	52	52	59	65	70	62	62	55	59	62	67	57	37	65	59	40	59	42	62	61	62	14	6	11	15	9
94288	2009-08-30	60	69	left	\N	\N	56	31	52	54	35	54	49	52	52	59	65	70	62	62	55	59	62	67	57	37	65	59	40	59	42	62	61	62	14	6	11	15	9
94288	2009-02-22	57	67	left	\N	\N	53	31	52	54	35	54	49	48	52	59	62	65	62	57	55	54	62	65	57	33	55	47	40	59	45	55	56	62	14	6	11	15	9
94288	2008-08-30	48	59	left	\N	\N	48	21	51	54	35	21	49	38	48	30	42	46	62	41	55	49	62	47	45	21	52	42	52	59	51	50	51	62	14	6	48	15	9
94288	2007-02-22	48	59	left	\N	\N	48	21	51	54	35	21	49	38	48	30	42	46	62	41	55	49	62	47	45	21	52	42	52	59	51	50	51	62	14	6	48	15	9
17703	2016-03-24	72	72	right	low	low	31	83	77	57	68	56	61	36	42	61	58	53	63	74	61	73	68	62	72	71	46	24	86	54	69	13	17	15	8	9	8	15	7
17703	2016-03-03	72	72	right	low	low	31	83	77	57	68	56	61	36	42	61	58	56	63	74	61	73	68	62	72	71	46	24	86	54	69	13	17	15	8	9	8	15	7
17703	2016-01-21	72	72	right	medium	low	31	83	77	57	68	56	61	36	42	61	58	56	63	74	61	73	68	62	72	71	46	24	86	54	69	13	17	15	8	9	8	15	7
17703	2015-12-10	72	72	right	medium	low	31	83	77	57	68	56	61	36	42	61	58	56	63	74	61	73	68	62	72	71	46	24	86	54	72	13	17	15	8	9	8	15	7
17703	2015-10-30	71	71	right	medium	low	31	82	74	57	68	56	61	36	42	61	58	56	63	74	61	73	68	62	72	71	46	24	80	54	72	13	17	15	8	9	8	15	7
17703	2015-09-25	71	71	right	medium	low	31	78	72	57	68	60	61	36	42	61	65	65	64	79	62	73	71	67	72	71	46	24	80	54	72	13	17	15	8	9	8	15	7
17703	2015-09-21	71	71	right	medium	low	31	78	72	57	68	60	61	36	42	61	65	65	64	79	62	73	71	67	72	71	46	24	80	54	74	13	17	15	8	9	8	15	7
17703	2015-03-06	72	72	right	medium	low	30	79	71	56	67	61	60	35	41	60	65	65	64	80	62	72	68	74	72	70	45	23	80	53	73	25	25	25	7	8	7	14	6
17703	2015-01-30	73	73	right	medium	low	30	82	71	56	67	61	60	35	41	60	65	67	64	81	62	72	68	74	74	70	45	23	83	53	73	25	25	25	7	8	7	14	6
17703	2015-01-16	73	73	right	medium	low	30	83	70	56	67	52	37	35	41	60	65	67	64	80	62	72	68	74	74	70	45	23	83	53	73	25	25	25	7	8	7	14	6
17703	2015-01-09	71	71	right	medium	low	30	83	62	56	67	52	37	35	41	60	65	67	64	78	62	72	68	74	74	70	45	23	80	53	73	25	25	25	7	8	7	14	6
17703	2014-09-18	71	71	right	medium	low	30	81	62	56	67	52	37	35	41	60	65	67	64	74	62	72	68	74	74	70	45	23	80	53	73	25	25	25	7	8	7	14	6
17703	2014-07-18	72	72	right	low	low	31	82	63	57	68	53	38	36	42	61	66	68	65	75	63	73	69	70	75	71	46	24	81	54	74	25	25	25	7	8	7	14	6
17703	2013-09-20	72	72	right	low	low	31	82	63	57	68	53	38	36	42	61	66	68	65	75	63	73	69	70	75	71	46	24	81	54	74	25	25	25	7	8	7	14	6
17703	2013-07-05	72	72	right	low	low	31	82	63	57	68	53	38	36	42	61	66	68	65	75	63	73	69	70	75	71	46	24	81	54	74	13	17	15	7	8	7	14	6
17703	2013-05-31	72	72	right	low	low	31	82	63	57	68	53	38	36	42	61	66	68	65	75	63	73	69	70	75	71	46	24	81	54	74	13	17	15	7	8	7	14	6
17703	2013-03-22	72	72	right	low	low	31	82	63	57	68	53	38	36	42	61	70	70	65	75	63	73	69	70	74	71	46	24	81	54	74	13	17	15	7	8	7	14	6
17703	2013-03-01	72	72	right	low	low	31	82	63	57	68	53	38	36	42	61	70	70	65	75	63	73	69	70	74	71	46	24	81	54	74	13	17	15	7	8	7	14	6
17703	2013-02-22	71	71	right	low	low	31	82	63	57	68	53	38	36	42	61	63	62	59	75	58	73	57	70	74	71	46	24	81	54	74	13	17	15	7	8	7	14	6
17703	2013-02-15	71	71	right	low	low	31	82	63	57	68	53	38	36	42	61	63	62	59	75	58	73	57	70	74	71	46	24	81	54	74	13	17	15	7	8	7	14	6
17703	2012-08-31	69	70	right	low	low	31	77	71	57	63	54	38	36	42	61	53	53	48	72	54	71	54	54	74	66	46	24	80	54	68	13	17	15	7	8	7	14	6
17703	2012-02-22	70	70	right	medium	low	31	78	71	57	63	54	38	36	42	60	53	53	48	74	46	71	54	54	74	68	46	24	81	54	68	13	17	15	7	8	7	14	6
17703	2011-08-30	68	68	right	medium	low	43	74	68	54	63	53	38	36	41	58	55	55	51	72	58	72	59	55	78	69	52	24	74	54	67	13	17	15	7	8	7	14	6
17703	2010-08-30	68	68	right	medium	low	43	74	68	54	63	53	38	36	41	58	55	55	51	72	58	72	59	55	78	69	52	24	74	54	67	13	17	15	7	8	7	14	6
17703	2010-02-22	65	69	right	medium	low	58	74	67	60	63	62	38	36	53	64	59	66	51	68	58	72	59	62	71	66	52	63	63	54	58	25	21	15	10	25	53	25	25
17703	2009-02-22	65	69	right	medium	low	58	74	67	60	63	62	38	36	53	64	59	66	51	68	58	72	59	62	71	66	52	63	63	54	58	25	21	15	10	25	53	25	25
17703	2008-08-30	65	69	right	medium	low	58	74	67	60	63	62	38	36	53	64	59	66	51	68	58	72	59	62	71	66	52	63	63	54	58	25	21	15	10	25	53	25	25
17703	2007-08-30	69	71	right	medium	low	68	73	67	60	63	62	38	36	58	64	59	66	51	70	58	69	59	72	67	69	52	63	63	54	58	48	21	15	10	25	58	25	25
17703	2007-02-22	69	71	right	medium	low	68	73	67	60	63	62	38	36	58	64	59	66	51	70	58	69	59	72	67	69	52	63	63	54	58	48	21	15	10	25	58	25	25
26235	2014-02-14	65	67	right	low	medium	42	42	65	54	39	37	51	47	55	56	30	33	44	66	57	65	57	57	79	56	73	69	43	44	58	63	64	63	15	8	13	11	15
26235	2013-09-20	66	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	30	33	44	66	57	65	57	57	79	56	73	71	43	44	58	64	66	63	15	8	13	11	15
26235	2013-02-15	66	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	30	33	44	66	54	65	57	57	79	56	73	71	43	44	58	64	66	63	15	8	13	11	15
26235	2012-08-31	66	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	34	45	66	49	65	60	57	79	56	73	71	43	44	58	64	66	63	15	8	13	11	15
26235	2012-02-22	64	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	34	45	57	57	65	60	57	77	56	73	69	43	44	58	62	64	61	15	8	13	11	15
26235	2011-08-30	64	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	40	45	57	56	65	60	57	77	56	73	69	43	44	58	62	64	61	15	8	13	11	15
26235	2010-08-30	64	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	40	45	57	56	65	60	57	77	56	73	69	43	44	58	62	64	61	15	8	13	11	15
26235	2010-02-22	64	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	40	45	57	56	65	60	57	77	56	73	47	55	44	51	62	64	61	4	22	50	22	22
26235	2009-02-22	64	67	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	40	45	57	56	65	60	57	77	56	73	47	55	44	51	62	64	61	4	22	50	22	22
26235	2008-08-30	58	75	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	42	45	57	56	65	60	44	77	56	69	44	52	44	49	55	58	61	4	22	50	22	22
26235	2008-02-22	58	75	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	42	45	57	56	65	60	44	77	56	69	44	52	44	49	55	58	61	4	22	50	22	22
26235	2007-02-22	58	75	right	low	medium	42	42	65	54	39	37	51	47	55	57	29	42	45	57	56	65	60	44	77	56	69	44	52	44	49	55	58	61	4	22	50	22	22
94030	2013-11-08	70	71	left	medium	medium	62	36	71	64	34	35	37	56	63	64	66	72	56	65	59	71	73	66	77	32	76	71	42	53	49	72	70	66	15	14	10	5	11
94030	2013-10-18	70	71	left	medium	medium	62	36	71	64	34	35	37	47	63	64	71	72	56	65	59	68	73	66	77	32	76	71	42	53	49	72	70	66	15	14	10	5	11
94030	2013-09-20	70	71	left	medium	medium	62	36	71	64	34	35	37	47	63	64	71	72	56	65	59	68	73	66	77	32	76	71	42	53	49	72	69	66	15	14	10	5	11
94030	2013-06-07	70	71	left	medium	medium	62	36	71	64	34	35	37	47	63	64	71	72	56	65	59	68	72	66	77	32	76	71	42	53	49	72	69	66	15	14	10	5	11
94030	2013-05-24	70	72	left	medium	medium	62	36	71	64	34	35	37	47	63	64	71	72	56	65	59	68	72	66	77	32	76	71	42	53	49	72	69	66	15	14	10	5	11
94030	2013-03-28	70	72	left	medium	medium	62	36	71	64	34	35	37	47	63	64	71	72	56	65	59	60	72	66	77	32	76	71	42	53	49	72	69	66	15	14	10	5	11
94030	2013-02-15	70	72	left	medium	medium	62	36	71	64	34	35	37	47	63	64	71	72	56	65	59	60	72	66	77	32	76	71	42	53	49	72	69	66	15	14	10	5	11
94030	2012-08-31	70	72	left	medium	medium	62	36	71	57	34	35	37	47	60	64	72	73	55	65	54	60	70	66	77	32	76	71	42	53	49	72	69	66	15	14	10	5	11
94030	2012-02-22	68	69	left	medium	medium	43	36	71	60	34	35	37	47	57	61	65	71	55	65	54	60	70	66	77	32	76	64	42	48	49	66	65	66	15	14	10	5	11
94030	2011-08-30	68	69	left	medium	medium	43	36	71	60	34	35	37	47	57	61	65	71	55	65	53	60	70	66	77	32	76	64	42	48	49	66	65	66	15	14	10	5	11
94030	2010-08-30	64	70	left	medium	medium	43	37	69	57	34	35	37	57	54	56	54	64	55	58	62	64	58	65	72	32	67	64	42	56	49	65	64	62	15	14	10	5	11
94030	2010-02-22	64	70	right	medium	medium	43	37	69	57	34	35	37	42	54	56	54	64	55	58	62	58	58	65	67	32	67	64	62	56	57	65	64	62	17	21	54	21	22
94030	2009-08-30	64	70	right	medium	medium	43	37	66	57	34	35	37	42	54	56	54	64	55	58	62	58	58	65	67	32	67	64	62	56	57	65	64	62	17	21	54	21	22
94030	2009-02-22	49	74	right	medium	medium	27	21	21	38	34	21	37	42	35	51	69	63	55	61	62	21	58	62	60	21	67	28	32	56	37	47	50	62	7	21	35	21	21
94030	2008-08-30	49	74	right	medium	medium	27	21	21	38	34	21	37	42	35	51	69	63	55	61	62	21	58	62	60	21	67	28	32	56	37	47	50	62	7	21	35	21	21
94030	2007-08-30	46	74	right	medium	medium	27	21	21	38	34	21	37	42	35	51	69	63	55	61	62	21	58	62	60	21	67	28	32	56	37	47	50	62	7	21	35	21	21
94030	2007-02-22	46	74	right	medium	medium	27	21	21	38	34	21	37	42	35	51	69	63	55	61	62	21	58	62	60	21	67	28	32	56	37	47	50	62	7	21	35	21	21
37858	2016-02-25	72	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	72	43	70	47	68	63	70	75	57	76	73	59	60	59	72	74	71	10	8	15	10	13
37858	2015-09-21	72	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	74	43	70	47	68	63	70	75	57	76	73	59	60	59	72	74	71	10	8	15	10	13
37858	2014-02-14	72	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	74	43	70	47	68	63	70	75	57	76	73	59	60	59	72	74	71	10	8	15	10	13
37858	2013-10-18	71	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	74	43	70	47	68	63	70	75	57	76	74	59	60	59	71	73	70	10	8	15	10	13
37858	2013-09-27	71	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	74	43	70	47	68	63	80	75	61	76	74	59	54	59	71	73	70	10	8	15	10	13
37858	2013-09-20	71	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	74	43	70	47	68	63	80	75	61	76	74	59	54	59	71	73	70	10	8	15	10	13
37858	2013-03-15	71	72	right	medium	medium	52	49	74	70	52	52	44	52	66	66	58	54	43	70	47	68	63	80	75	61	76	74	59	54	59	71	73	70	10	8	15	10	13
37858	2013-03-08	71	72	right	medium	medium	52	56	74	68	53	53	44	57	63	63	58	54	43	68	47	68	63	84	75	61	76	74	59	54	59	69	72	68	10	8	15	10	13
37858	2013-02-15	70	71	right	medium	medium	52	56	74	68	53	53	44	57	63	63	58	54	43	68	47	68	63	84	75	61	74	73	59	54	59	68	71	67	10	8	15	10	13
37858	2012-08-31	70	71	right	medium	medium	52	56	74	68	53	53	44	57	63	63	58	58	43	68	45	68	63	83	75	61	74	73	59	64	59	68	71	67	10	8	15	10	13
37858	2012-02-22	69	71	right	medium	medium	52	56	74	66	53	51	44	57	61	63	58	57	48	68	45	73	61	83	75	63	74	73	59	63	59	68	69	66	10	8	15	10	13
37858	2011-08-30	69	71	right	medium	medium	52	56	74	66	53	51	44	57	61	63	53	66	48	68	45	73	61	83	75	63	74	73	59	63	59	68	69	66	10	8	15	10	13
37858	2010-08-30	69	74	right	medium	medium	53	64	74	67	53	53	44	57	62	65	58	68	53	66	68	73	63	80	71	65	71	73	66	75	59	68	67	66	10	8	15	10	13
37858	2010-02-22	69	74	right	medium	medium	58	64	74	67	53	62	44	57	62	65	62	72	53	60	68	73	63	77	75	65	67	70	73	75	71	69	66	66	6	22	62	22	22
37858	2009-08-30	69	74	right	medium	medium	58	64	74	67	53	62	44	57	62	65	62	72	53	60	68	73	63	77	75	65	67	70	70	75	71	69	66	66	6	22	62	22	22
37858	2008-08-30	67	72	right	medium	medium	58	64	74	65	53	62	44	57	60	67	62	72	53	60	68	73	63	77	75	65	67	70	66	75	71	67	65	66	6	22	60	22	22
37858	2007-08-30	69	72	right	medium	medium	58	64	74	65	53	62	44	57	60	67	62	72	53	60	68	73	63	77	75	65	67	70	66	75	71	67	65	66	6	22	60	22	22
37858	2007-02-22	66	76	right	medium	medium	48	64	74	65	53	67	44	69	60	64	62	72	53	60	68	73	63	77	75	65	64	70	66	75	69	67	53	66	6	12	60	8	4
148338	2012-02-22	60	65	left	medium	high	42	43	61	59	37	42	27	38	54	59	62	67	65	62	62	57	61	72	64	45	66	60	37	57	45	54	60	61	12	5	8	9	7
148338	2011-08-30	56	64	left	medium	high	39	37	57	55	36	39	27	38	49	50	59	62	64	62	66	55	64	69	67	39	60	54	37	56	45	52	55	54	12	5	8	9	7
148338	2011-02-22	56	65	left	medium	high	39	37	57	55	36	39	27	38	49	50	60	65	62	62	55	55	62	67	63	39	60	54	37	56	45	52	55	54	12	5	8	9	7
148338	2009-08-30	56	65	left	medium	high	39	37	57	55	36	39	27	38	49	50	60	65	62	62	55	55	62	67	63	39	60	54	37	56	45	52	55	54	12	5	8	9	7
148338	2008-08-30	41	65	left	medium	high	44	37	35	46	36	39	27	53	39	50	64	57	62	38	55	31	62	52	42	21	35	53	47	56	45	21	28	54	12	5	39	9	7
148338	2007-02-22	41	65	left	medium	high	44	37	35	46	36	39	27	53	39	50	64	57	62	38	55	31	62	52	42	21	35	53	47	56	45	21	28	54	12	5	39	9	7
39859	2015-01-16	62	62	left	high	medium	66	46	49	64	66	57	67	66	63	61	61	62	63	61	66	69	62	64	63	64	63	66	56	57	60	63	64	62	15	8	7	14	7
39859	2014-09-18	63	63	left	high	medium	71	48	49	65	66	59	68	74	64	60	66	59	65	62	70	77	74	70	64	65	67	61	60	57	60	64	65	64	15	8	7	14	7
39859	2014-05-02	63	63	left	high	medium	71	48	49	65	66	59	68	74	64	60	66	62	65	62	70	77	72	70	64	65	67	61	60	57	60	64	65	64	15	8	7	14	7
39859	2014-03-28	64	64	left	high	medium	71	48	49	65	66	60	68	74	64	61	66	62	65	65	70	77	72	70	64	65	67	61	60	57	60	64	65	64	15	8	7	14	7
39859	2013-09-20	64	64	left	high	medium	71	48	49	65	66	60	68	74	64	61	66	62	65	65	70	77	72	70	64	65	67	61	60	57	60	64	65	64	15	8	7	14	7
39859	2013-05-17	64	64	left	high	medium	71	48	49	65	66	60	68	74	64	63	66	63	65	65	70	75	71	70	64	65	67	61	60	57	60	64	65	64	15	8	7	14	7
39859	2013-02-15	65	65	left	high	medium	71	48	49	67	66	60	68	74	67	63	66	63	65	67	70	75	71	80	64	65	67	62	60	57	60	64	65	66	15	8	7	14	7
39859	2012-08-31	66	66	left	high	medium	72	48	49	69	66	60	68	74	69	64	68	67	65	69	68	77	69	79	64	72	67	64	60	57	60	64	65	67	15	8	7	14	7
39859	2012-02-22	66	66	left	high	medium	72	48	49	68	66	60	67	74	69	64	67	69	65	69	68	77	69	79	64	74	67	64	60	55	60	64	63	67	15	8	7	14	7
39859	2011-08-30	67	67	left	high	medium	74	48	47	68	66	59	67	74	69	64	67	71	65	69	68	77	69	79	64	74	63	66	62	59	60	68	67	67	15	8	7	14	7
39859	2011-02-22	67	69	left	high	medium	74	46	47	67	66	55	65	72	69	64	69	71	66	69	67	75	66	75	64	69	63	66	66	58	54	68	67	67	15	8	7	14	7
39859	2010-08-30	65	68	left	high	medium	70	46	47	62	66	52	65	62	65	61	65	67	64	66	57	68	66	75	60	67	53	66	66	58	54	67	66	66	15	8	7	14	7
39859	2010-02-22	62	64	left	high	medium	70	46	47	62	66	52	65	62	65	57	65	67	64	62	57	65	66	75	60	67	53	62	60	58	57	59	62	66	6	23	65	23	23
39859	2009-08-30	60	62	left	high	medium	70	46	47	62	66	53	65	58	66	55	64	66	64	55	57	60	66	75	54	66	52	57	55	58	47	56	58	66	6	23	66	23	23
39859	2008-08-30	57	62	left	high	medium	64	46	47	60	66	53	65	58	62	55	60	62	64	55	57	60	66	60	54	62	52	57	55	58	47	56	58	66	6	23	62	23	23
39859	2007-02-22	57	62	left	high	medium	64	46	47	60	66	53	65	58	62	55	60	62	64	55	57	60	66	60	54	62	52	57	55	58	47	56	58	66	6	23	62	23	23
166663	2009-08-30	57	65	left	\N	\N	44	32	60	49	\N	37	\N	39	45	57	52	57	\N	61	\N	53	\N	63	65	45	57	46	45	\N	47	56	55	\N	3	21	45	21	21
166663	2008-08-30	54	65	left	\N	\N	52	32	55	50	\N	35	\N	39	47	45	57	67	\N	55	\N	57	\N	72	65	45	57	46	45	\N	47	50	54	\N	3	21	47	21	21
166663	2007-02-22	54	65	left	\N	\N	52	32	55	50	\N	35	\N	39	47	45	57	67	\N	55	\N	57	\N	72	65	45	57	46	45	\N	47	50	54	\N	3	21	47	21	21
131403	2013-09-20	63	67	left	medium	medium	25	25	25	33	25	25	25	25	37	23	43	42	38	60	47	33	63	33	62	25	23	25	25	25	35	25	25	25	67	62	65	57	68
131403	2013-06-07	63	67	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	47	33	62	55	65	16	23	14	8	4	35	13	12	11	67	62	65	57	68
131403	2013-04-12	63	69	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	47	33	62	55	65	16	23	14	8	4	35	13	12	11	67	62	65	57	68
131403	2013-03-28	63	69	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	47	33	62	55	65	16	23	24	14	35	35	13	12	11	67	62	65	57	68
131403	2013-03-04	63	69	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	47	33	62	55	65	16	23	24	14	35	35	13	12	11	67	62	65	57	68
131403	2013-02-15	63	69	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	47	33	62	55	65	16	23	24	14	35	35	13	12	11	67	62	65	57	68
131403	2012-08-31	63	71	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	47	33	62	55	65	16	23	24	14	35	35	13	12	11	67	62	65	57	68
131403	2012-02-22	63	69	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	51	33	62	55	65	16	23	24	14	35	35	13	12	11	67	62	65	57	68
131403	2011-08-30	63	69	left	medium	medium	19	10	10	33	19	16	15	10	37	23	47	52	45	60	51	33	62	55	65	16	23	24	14	35	35	13	12	11	67	62	65	57	68
131403	2011-02-22	62	70	left	medium	medium	19	10	27	41	19	16	15	9	37	23	47	52	45	42	57	44	62	55	65	16	23	24	14	46	35	13	12	11	65	62	63	56	67
131403	2010-08-30	63	70	left	medium	medium	19	6	27	53	19	16	15	25	65	23	47	52	45	42	57	55	62	55	65	16	23	24	14	46	35	27	29	25	67	62	65	57	68
131403	2010-02-22	62	72	left	medium	medium	21	21	27	38	19	21	15	25	65	23	47	52	45	42	57	55	62	55	65	21	23	37	24	46	50	27	29	25	67	60	65	55	68
131403	2009-08-30	62	72	left	medium	medium	21	21	27	53	19	21	15	25	65	23	47	52	45	42	57	55	62	55	65	21	23	37	24	46	50	27	29	25	67	60	65	55	68
131403	2008-08-30	50	65	left	medium	medium	21	21	21	21	19	21	15	5	57	21	53	41	45	42	57	21	62	60	68	21	64	32	34	46	30	21	21	25	52	49	57	52	46
131403	2007-02-22	50	65	left	medium	medium	21	21	21	21	19	21	15	5	57	21	53	41	45	42	57	21	62	60	68	21	64	32	34	46	30	21	21	25	52	49	57	52	46
148286	2014-03-07	65	67	right	high	medium	56	63	61	62	53	66	47	52	58	65	81	82	80	68	79	68	84	71	73	57	73	46	62	58	60	27	34	31	11	14	14	6	11
148286	2014-02-21	65	69	right	high	medium	56	63	61	62	53	66	47	52	58	65	81	82	80	68	79	68	84	71	73	57	73	46	62	58	60	27	34	31	11	14	14	6	11
148286	2013-09-20	65	69	right	high	medium	56	63	61	62	53	66	47	52	58	65	81	82	80	68	79	68	84	71	73	57	73	46	62	58	60	27	34	31	11	14	14	6	11
148286	2013-05-10	65	69	right	high	medium	56	63	61	62	53	66	47	52	58	65	81	82	80	68	79	68	84	71	73	57	73	46	62	58	60	27	34	31	11	14	14	6	11
148286	2013-02-15	66	69	right	high	medium	58	63	62	63	53	68	47	52	58	66	81	82	80	68	79	68	84	71	73	58	73	46	63	58	60	27	34	31	11	14	14	6	11
148286	2012-08-31	66	69	right	high	medium	58	63	62	63	53	68	47	52	58	66	81	82	80	68	78	68	83	71	68	58	73	46	63	58	60	27	34	31	11	14	14	6	11
148286	2011-02-22	66	69	right	high	medium	58	63	62	63	53	68	47	52	58	66	81	82	80	68	78	68	83	71	68	58	73	46	63	58	60	27	34	31	11	14	14	6	11
148286	2010-08-30	66	69	right	high	medium	58	63	62	63	53	68	47	52	58	66	81	82	80	68	78	68	83	71	68	58	73	46	63	58	60	27	34	31	11	14	14	6	11
148286	2010-02-22	66	70	right	high	medium	58	63	62	63	53	68	47	52	58	66	81	82	80	68	78	68	83	71	68	58	73	51	54	58	64	27	34	31	4	23	51	23	23
148286	2009-08-30	64	70	right	high	medium	56	62	64	58	53	68	47	44	49	66	81	78	80	72	78	63	83	65	64	52	61	50	57	58	54	27	34	31	4	23	49	23	23
148286	2009-02-22	60	69	right	high	medium	55	56	33	52	53	62	47	44	43	60	79	74	80	72	78	57	83	65	56	52	36	48	45	58	52	28	24	31	4	23	43	23	23
148286	2008-08-30	56	66	right	high	medium	50	46	33	52	53	59	47	44	43	54	72	74	80	64	78	52	83	58	44	42	36	43	45	58	42	28	24	31	4	23	43	23	23
148286	2007-02-22	56	66	right	high	medium	50	46	33	52	53	59	47	44	43	54	72	74	80	64	78	52	83	58	44	42	36	43	45	58	42	28	24	31	4	23	43	23	23
38293	2016-05-19	70	70	right	high	medium	55	42	74	68	31	52	55	66	64	64	53	59	63	62	49	59	57	60	74	54	66	75	29	52	55	69	74	70	6	15	11	8	11
38293	2016-01-21	70	70	right	high	medium	55	42	74	68	31	52	55	66	64	64	53	59	63	62	49	59	57	60	74	54	66	75	29	52	55	69	74	70	6	15	11	8	11
38293	2014-09-18	70	70	right	high	medium	55	42	74	68	31	52	55	66	64	64	53	59	63	62	49	59	57	60	74	54	66	75	29	52	55	69	74	70	6	15	11	8	11
38293	2014-05-16	73	73	right	high	medium	55	42	74	68	46	59	55	66	64	64	66	59	63	62	49	68	57	60	79	63	66	75	29	62	55	69	74	70	6	15	11	8	11
38293	2013-09-20	72	72	right	high	medium	55	42	74	68	46	59	55	66	64	64	66	59	63	68	49	68	57	60	79	63	65	75	29	62	55	67	76	72	6	15	11	8	11
38293	2013-08-16	73	73	right	medium	medium	55	42	74	68	46	59	55	66	64	64	66	59	63	68	49	68	57	60	79	63	65	82	29	62	55	67	76	72	6	15	11	8	11
38293	2013-04-19	73	73	right	medium	medium	55	42	74	68	46	59	55	66	64	64	66	59	63	68	49	68	57	60	79	63	65	82	29	62	55	67	76	72	6	15	11	8	11
38293	2013-02-15	73	73	right	medium	medium	55	42	74	68	46	59	55	66	64	64	66	59	63	68	49	68	57	60	79	63	65	82	29	62	55	67	76	72	6	15	11	8	11
38293	2012-08-31	73	74	right	medium	medium	55	42	74	68	46	59	55	66	64	64	66	59	63	68	49	68	57	60	79	63	65	82	29	62	55	67	76	72	6	15	11	8	11
38293	2012-02-22	73	75	right	medium	medium	55	42	74	68	46	60	55	66	64	64	66	69	63	68	49	68	57	60	79	63	65	82	29	62	55	67	76	72	6	15	11	8	11
38293	2011-08-30	73	74	right	medium	medium	55	42	74	68	46	60	55	66	64	64	66	69	63	68	55	68	57	60	79	63	65	82	29	62	55	67	76	72	6	15	11	8	11
38293	2011-02-22	72	77	right	medium	medium	55	42	74	68	46	67	55	66	64	64	65	69	67	68	77	68	69	68	79	63	65	82	29	74	55	67	76	72	6	15	11	8	11
38293	2010-08-30	73	77	right	medium	medium	55	46	77	69	66	69	55	66	64	74	65	69	67	68	77	68	69	68	80	63	67	82	58	74	55	69	76	72	6	15	11	8	11
38293	2009-08-30	70	72	right	medium	medium	55	43	75	69	66	69	55	66	64	74	65	69	67	57	77	67	69	68	79	62	65	72	82	74	83	65	76	72	4	20	67	20	20
38293	2009-02-22	70	72	right	medium	medium	55	43	75	69	66	70	55	66	64	75	65	69	67	57	77	67	69	65	79	62	65	72	77	74	82	65	74	72	14	20	67	20	20
38293	2008-08-30	69	72	right	medium	medium	55	43	72	69	66	67	55	66	64	75	65	69	67	57	77	67	69	65	79	62	62	72	77	74	82	64	72	72	14	20	67	20	20
38293	2007-08-30	69	74	right	medium	medium	55	63	70	68	66	74	55	56	61	78	68	73	67	57	77	66	69	65	78	58	66	73	78	74	77	63	68	72	14	20	61	20	20
38293	2007-02-22	69	74	right	medium	medium	55	63	70	68	66	74	55	77	61	78	68	73	67	57	77	66	69	65	78	58	66	73	78	74	77	63	68	72	14	13	61	13	16
148336	2012-02-22	64	67	right	high	low	56	57	37	62	53	69	53	56	57	67	79	75	82	62	82	57	69	61	45	60	37	27	59	55	52	26	30	27	6	9	8	7	7
148336	2011-08-30	64	67	right	high	low	56	59	37	62	53	69	53	56	57	67	82	76	83	64	82	57	63	57	54	60	37	27	57	57	52	26	30	27	6	9	8	7	7
148336	2010-08-30	64	67	right	high	low	56	59	37	62	53	69	53	56	57	67	77	74	75	64	52	57	57	60	47	60	37	27	57	57	52	26	30	27	6	9	8	7	7
148336	2010-02-22	62	67	right	high	low	56	59	37	62	53	67	53	56	57	62	74	72	75	64	52	57	57	60	47	60	37	47	52	57	65	26	30	27	12	23	57	23	23
148336	2009-08-30	56	67	right	high	low	55	47	35	62	53	60	53	53	57	62	72	70	75	57	52	55	57	59	47	54	37	44	47	57	56	26	30	27	12	23	57	23	23
148336	2007-02-22	56	67	right	high	low	55	47	35	62	53	60	53	53	57	62	72	70	75	57	52	55	57	59	47	54	37	44	47	57	56	26	30	27	12	23	57	23	23
36841	2013-03-08	64	64	right	medium	medium	53	36	66	63	43	42	58	52	61	57	45	52	47	64	57	59	61	70	69	51	67	68	21	57	54	63	65	62	11	11	15	11	9
36841	2013-02-15	66	66	right	medium	medium	53	36	67	64	43	42	58	52	61	57	45	52	47	64	57	59	62	70	75	51	67	74	18	57	54	64	67	62	11	11	15	11	9
36841	2012-08-31	66	66	right	medium	medium	53	36	67	64	43	42	58	52	61	57	45	54	47	64	52	59	62	70	75	51	67	74	18	57	54	64	67	62	11	11	15	11	9
36841	2012-02-22	66	66	right	medium	medium	53	36	67	64	43	42	58	52	61	57	54	54	56	67	60	59	66	63	75	51	68	63	18	57	54	65	70	62	11	11	15	11	9
36841	2011-08-30	68	68	right	medium	medium	53	36	68	66	43	42	58	52	63	58	54	54	56	69	60	59	66	63	75	51	69	66	18	57	54	67	71	63	11	11	15	11	9
36841	2011-02-22	68	70	right	medium	medium	53	36	68	66	43	42	58	52	63	58	59	63	52	69	69	59	74	68	74	51	69	66	18	71	54	67	71	63	11	11	15	11	9
36841	2010-08-30	69	70	right	medium	medium	53	36	72	66	43	42	58	52	63	58	59	63	52	69	69	59	66	68	74	51	69	66	18	70	54	68	73	63	11	11	15	11	9
36841	2010-02-22	67	69	right	medium	medium	53	38	69	66	43	42	58	52	63	58	54	58	52	69	69	59	66	68	72	51	65	69	74	70	69	67	73	63	1	25	63	25	25
36841	2009-08-30	67	70	right	medium	medium	53	38	69	66	43	42	58	52	63	58	54	58	52	69	69	59	66	68	72	51	65	69	74	70	69	67	73	63	1	25	63	25	25
36841	2008-08-30	64	65	right	medium	medium	52	38	67	64	43	47	58	52	62	55	47	54	52	69	69	59	66	65	71	51	64	67	73	70	66	62	65	63	6	25	62	25	25
36841	2007-08-30	65	65	right	medium	medium	56	38	67	66	43	54	58	52	61	65	56	60	52	69	69	59	66	62	71	51	64	67	70	70	66	63	63	63	6	25	61	25	25
36841	2007-02-22	63	72	right	medium	medium	56	38	65	67	43	54	58	66	66	66	63	42	52	69	69	49	66	54	61	51	52	67	70	70	66	63	64	63	6	10	66	14	13
6800	2014-07-18	64	64	right	medium	medium	36	30	67	64	28	35	31	45	64	58	34	48	34	58	56	60	42	60	80	35	70	68	27	42	65	62	65	59	6	8	8	10	8
6800	2014-03-28	64	64	right	medium	medium	36	30	67	64	28	35	31	45	64	58	34	48	34	58	56	60	42	60	80	35	70	68	27	42	65	62	65	59	6	8	8	10	8
6800	2013-09-20	65	65	right	medium	medium	36	30	67	64	28	35	31	45	64	58	34	48	34	60	56	60	46	70	82	35	70	68	27	42	65	62	66	62	6	8	8	10	8
6800	2013-07-05	66	66	right	medium	medium	36	30	68	64	28	35	31	45	64	58	38	48	34	62	56	60	46	72	82	35	70	71	27	42	65	65	67	62	6	8	8	10	8
6800	2013-03-22	66	66	right	medium	medium	36	30	68	64	28	35	31	45	64	58	38	48	34	62	56	60	46	72	82	35	70	71	27	42	65	65	67	62	6	8	8	10	8
6800	2013-03-15	66	66	right	medium	medium	43	30	68	64	28	35	36	45	64	60	38	48	34	62	56	62	46	75	86	35	75	70	27	42	65	65	63	60	6	8	8	10	8
6800	2013-02-22	66	66	right	medium	medium	43	30	68	64	28	35	36	45	64	60	38	48	34	62	56	62	46	75	86	35	75	70	27	42	65	65	63	60	6	8	8	10	8
6800	2013-02-15	66	66	right	medium	medium	43	30	68	64	28	35	36	45	64	60	38	48	34	62	56	62	46	75	86	35	75	70	27	42	65	65	63	60	6	8	8	10	8
6800	2012-08-31	68	69	right	medium	medium	43	30	70	64	28	35	36	45	64	60	55	63	34	62	54	62	44	88	86	35	75	74	27	42	65	70	67	62	6	8	8	10	8
6800	2012-02-22	68	69	right	medium	medium	43	30	70	63	28	35	36	45	60	58	37	43	34	64	50	62	44	84	86	35	75	74	27	47	67	70	67	62	6	8	8	10	8
6800	2011-08-30	68	74	right	medium	medium	43	31	70	63	28	35	36	45	60	58	37	43	35	64	50	62	44	84	86	35	75	75	27	47	67	70	67	62	6	8	8	10	8
6800	2011-02-22	68	71	right	medium	medium	43	31	70	63	28	35	36	36	51	58	59	63	52	65	73	62	73	69	78	35	65	73	38	66	67	70	67	62	6	8	13	10	15
6800	2010-08-30	67	71	right	medium	medium	43	31	67	63	28	35	36	36	51	58	59	63	52	65	73	62	73	69	78	35	65	73	38	66	67	70	64	62	6	8	13	10	15
6800	2009-08-30	65	68	right	medium	medium	43	31	67	58	28	35	36	36	51	58	59	63	52	61	73	62	73	69	78	35	65	68	64	66	64	65	64	62	9	22	51	22	22
6800	2009-02-22	63	68	right	medium	medium	43	31	67	53	28	35	36	36	46	53	59	61	52	49	73	62	73	66	78	30	65	68	60	66	64	61	64	62	21	22	46	22	21
6800	2008-08-30	63	66	right	medium	medium	43	31	67	53	28	35	36	36	46	53	59	61	52	49	73	62	73	66	78	30	65	68	60	66	64	61	64	62	21	22	46	22	21
6800	2007-08-30	62	63	right	medium	medium	49	31	67	51	28	35	36	36	43	53	59	60	52	49	73	59	73	66	78	30	65	68	60	66	64	56	58	62	21	22	43	22	21
6800	2007-02-22	62	63	right	medium	medium	49	31	67	51	28	35	36	36	43	53	59	60	52	49	73	59	73	66	78	30	65	68	60	66	64	56	58	62	21	22	43	22	21
37979	2014-09-23	68	68	left	medium	high	67	57	62	70	72	65	67	69	68	67	76	73	75	76	85	74	78	76	62	70	87	66	62	67	57	67	69	70	14	15	15	8	14
37979	2014-04-04	68	68	left	medium	high	67	57	62	70	72	65	67	69	68	67	76	73	75	76	85	74	78	76	62	70	87	66	62	67	57	67	69	70	14	15	15	8	14
37979	2014-01-17	68	68	left	medium	high	67	57	62	70	72	65	67	69	68	67	76	73	75	76	85	74	78	76	62	70	87	66	62	67	57	67	69	70	14	15	15	8	14
37979	2013-09-20	68	72	left	medium	high	67	57	62	70	72	65	67	69	68	67	76	73	75	76	85	74	78	76	62	70	87	66	62	67	57	67	69	70	14	15	15	8	14
37979	2013-05-31	72	72	left	medium	high	67	57	62	70	72	65	67	69	68	67	76	73	75	76	85	79	78	76	62	72	87	69	62	67	57	69	71	72	14	15	15	8	14
37979	2013-02-15	72	72	left	medium	high	67	57	62	70	72	65	67	69	68	67	76	73	75	76	85	79	78	76	62	72	87	69	62	67	57	69	71	72	14	15	15	8	14
37979	2012-08-31	70	70	left	high	high	67	57	62	70	72	65	67	69	68	67	76	74	75	72	85	79	83	82	58	72	87	67	62	64	57	67	69	71	14	15	15	8	14
37979	2012-02-22	69	70	left	high	high	65	59	62	70	72	65	67	69	68	70	76	74	75	72	85	79	83	82	58	72	87	65	62	62	57	67	67	69	14	15	15	8	14
37979	2011-08-30	69	70	left	high	high	65	57	62	70	71	65	67	69	68	71	76	74	75	72	85	79	82	82	57	72	87	65	62	62	57	67	65	69	14	15	15	8	14
37979	2011-02-22	69	72	left	high	high	62	63	64	69	73	69	67	69	68	72	75	72	73	74	67	79	74	79	59	72	91	65	62	67	57	67	65	69	14	15	15	8	14
37979	2010-08-30	69	72	left	high	high	62	63	64	69	73	69	67	69	68	72	75	72	73	74	67	79	74	79	59	72	91	65	62	67	57	67	65	69	14	15	15	8	14
37979	2009-08-30	69	74	left	high	high	62	65	64	68	73	68	67	68	70	72	74	72	73	73	67	79	74	78	60	71	91	61	64	67	59	67	65	69	8	20	70	20	20
37979	2009-02-22	70	77	left	high	high	71	64	66	72	73	73	67	68	70	75	75	73	73	75	67	75	74	82	65	70	91	54	55	67	52	62	71	69	8	20	70	20	20
37979	2008-08-30	70	72	left	high	high	71	64	66	72	73	73	67	68	70	75	75	73	73	75	67	75	74	82	65	70	91	54	55	67	52	62	71	69	8	20	70	20	20
37979	2007-08-30	73	72	left	high	high	71	64	66	72	73	73	67	68	70	75	75	73	73	75	67	75	74	82	65	70	91	54	55	67	52	62	71	69	8	20	70	20	20
37979	2007-02-22	71	74	left	high	high	71	64	66	72	73	73	67	52	69	75	75	73	73	75	67	75	74	80	61	70	85	54	55	67	52	65	58	69	8	10	69	12	11
38378	2016-04-21	67	67	right	high	medium	70	66	52	65	65	72	70	69	59	67	78	74	76	65	75	69	73	47	62	68	56	44	64	62	57	32	40	42	16	14	13	8	13
38378	2016-03-24	67	67	right	high	medium	70	66	52	65	65	72	70	69	59	67	78	74	76	65	75	69	73	47	62	68	56	44	64	64	57	32	40	42	16	14	13	8	13
38378	2015-10-16	67	67	right	high	medium	70	66	52	65	65	72	70	69	59	67	78	74	76	65	75	69	73	57	62	68	56	44	64	64	57	32	40	42	16	14	13	8	13
38378	2015-09-21	67	68	right	high	medium	70	66	52	65	65	72	70	69	59	67	78	74	76	65	75	69	73	57	62	68	56	44	64	64	57	32	40	42	16	14	13	8	13
38378	2015-05-15	69	69	right	high	medium	70	65	57	64	64	72	74	71	58	67	85	87	84	67	75	68	80	67	62	68	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2015-02-06	69	69	right	high	medium	70	65	57	64	64	72	74	71	58	67	85	87	84	67	75	68	80	67	62	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2014-11-07	69	69	right	high	medium	70	65	57	64	64	72	74	71	58	67	85	87	84	67	75	68	80	67	62	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2014-03-21	69	69	right	high	medium	70	65	57	64	64	72	74	71	58	67	85	87	84	67	75	68	80	67	62	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2014-02-14	69	72	right	high	medium	70	65	57	64	64	70	74	71	58	67	81	91	85	67	71	68	80	84	64	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2014-02-07	69	72	right	high	medium	70	65	57	64	64	70	74	71	58	67	81	91	85	67	71	68	80	84	64	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2013-11-01	69	72	right	high	medium	70	65	57	64	64	70	74	71	58	67	81	91	85	67	71	68	80	84	64	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2013-09-20	69	72	right	high	medium	70	65	57	64	64	70	74	71	58	67	81	91	85	67	71	68	80	84	64	70	55	43	63	63	56	37	41	44	15	13	12	7	12
38378	2013-04-19	71	76	right	high	medium	73	67	57	65	66	73	76	72	58	71	84	91	85	67	71	70	80	83	64	73	55	43	63	63	57	37	42	45	15	13	12	7	12
38378	2013-02-15	71	76	right	high	medium	73	67	57	65	66	73	76	72	58	71	84	91	85	67	71	70	80	83	64	73	55	43	63	63	57	37	42	45	15	13	12	7	12
38378	2012-08-31	71	76	right	high	medium	73	67	57	65	66	73	76	72	58	71	84	91	85	67	71	70	80	83	64	73	55	43	63	63	57	37	42	45	15	13	12	7	12
38378	2012-02-22	71	76	right	high	medium	73	67	57	65	66	73	76	72	58	71	84	93	85	67	71	70	80	83	64	73	55	43	63	63	57	37	42	45	15	13	12	7	12
38378	2011-08-30	71	76	right	high	medium	73	67	57	65	66	73	76	72	58	71	92	93	85	67	71	70	80	83	64	73	55	43	63	63	57	37	42	45	15	13	12	7	12
38378	2011-02-22	72	76	right	high	medium	70	67	57	65	66	73	63	70	58	71	85	87	75	67	53	70	70	77	56	73	55	43	63	52	57	37	42	45	15	13	12	7	12
38378	2010-08-30	73	76	right	high	medium	71	70	59	66	66	76	63	71	58	73	85	87	76	67	53	70	70	77	57	73	55	43	63	53	57	37	42	47	15	13	12	7	12
38378	2010-02-22	72	76	right	high	medium	71	70	52	63	66	72	63	61	58	70	85	87	76	67	53	67	70	78	57	58	55	47	54	53	73	37	39	47	10	20	58	20	20
38378	2009-08-30	70	76	right	high	medium	67	62	35	62	66	72	63	51	53	67	85	87	76	67	53	62	70	78	53	56	56	45	47	53	52	37	39	47	10	20	53	20	20
38378	2009-02-22	70	76	right	high	medium	67	62	35	62	66	72	63	51	53	67	85	87	76	67	53	62	70	78	53	56	56	45	47	53	52	37	39	47	10	20	53	20	20
38378	2008-08-30	69	76	right	high	medium	67	57	35	62	66	72	63	51	53	69	82	85	76	65	53	57	70	78	58	55	56	48	50	53	53	40	38	47	10	20	53	20	20
38378	2007-08-30	69	74	right	high	medium	67	57	35	62	66	72	63	51	53	69	76	78	76	65	53	57	70	67	47	55	56	48	50	53	53	40	38	47	10	20	53	20	20
38378	2007-02-22	61	74	right	high	medium	60	57	35	52	66	65	63	53	49	62	73	71	76	65	53	57	70	57	47	55	56	48	50	53	53	22	18	47	10	12	49	5	4
45490	2015-07-03	64	64	right	high	low	63	61	57	61	66	61	63	67	56	62	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	47	52	15	9	15	13	10
45490	2015-03-20	64	64	right	high	low	63	61	57	61	66	61	63	67	56	62	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	47	52	15	9	15	13	10
45490	2015-03-13	64	64	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	47	52	15	9	15	13	10
45490	2015-01-30	64	64	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2015-01-28	64	64	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2015-01-09	64	64	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2014-03-21	64	64	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2014-02-28	64	65	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2013-09-20	64	65	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2011-08-30	64	65	right	high	low	63	61	57	61	66	62	63	67	56	63	74	78	76	67	67	72	68	68	66	69	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2011-02-22	66	69	right	high	low	63	61	57	61	66	62	63	67	56	63	73	76	71	67	53	74	65	67	55	72	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2010-08-30	66	69	right	high	low	63	61	57	61	66	62	63	67	56	63	73	76	71	67	53	74	65	67	55	72	47	43	64	62	62	25	25	29	15	9	15	13	10
45490	2010-02-22	63	68	right	high	low	61	61	62	56	66	58	63	60	53	56	73	76	71	67	53	71	65	67	55	71	47	59	57	62	62	20	20	29	3	20	53	20	20
45490	2009-08-30	63	68	right	high	low	61	61	62	56	66	58	63	60	53	56	73	76	71	67	53	67	65	67	55	66	47	59	57	62	62	20	20	29	3	20	53	20	20
45490	2007-08-30	63	68	right	high	low	61	61	62	56	66	58	63	60	53	56	73	76	71	67	53	67	65	67	55	66	47	59	57	62	62	20	20	29	3	20	53	20	20
45490	2007-02-22	63	68	right	high	low	61	61	62	56	66	58	63	38	53	56	73	76	71	67	53	67	65	67	55	66	47	59	57	62	62	15	15	29	3	1	53	4	5
39848	2011-08-30	62	62	right	medium	medium	52	45	72	65	53	50	45	46	45	60	42	32	49	57	58	70	60	55	75	58	70	60	52	55	54	56	57	54	6	13	9	5	7
39848	2011-02-22	62	67	right	medium	medium	52	57	72	65	53	50	45	46	45	60	52	62	54	57	72	70	60	73	75	58	70	60	52	65	54	56	57	54	6	13	9	5	7
39848	2010-08-30	64	67	right	medium	medium	52	61	74	67	53	52	45	46	47	62	57	65	55	60	73	70	67	75	77	58	72	60	62	65	54	58	57	54	6	13	9	5	7
39848	2009-08-30	63	67	right	medium	medium	52	60	74	67	53	52	45	46	47	62	57	65	55	60	73	70	67	75	77	58	72	67	69	65	65	52	57	54	6	22	47	22	22
39848	2009-02-22	63	67	right	medium	medium	52	60	74	67	53	52	45	46	47	62	57	65	55	60	73	70	67	75	77	58	72	67	69	65	65	52	57	54	10	22	47	22	22
39848	2008-08-30	64	67	right	medium	medium	58	62	74	67	53	54	45	46	48	62	62	65	55	62	73	67	67	74	75	60	71	75	77	65	67	36	37	54	10	22	48	22	22
39848	2007-08-30	66	73	right	medium	medium	58	69	77	69	53	54	45	46	48	68	66	59	55	62	73	67	67	64	72	63	71	75	77	65	67	36	37	54	10	22	48	22	22
39848	2007-02-22	66	73	right	medium	medium	58	69	77	69	53	54	45	67	48	68	66	59	55	62	73	67	67	64	72	63	71	75	77	65	67	36	37	54	10	8	48	8	12
37963	2015-05-08	63	63	right	high	medium	63	46	63	64	56	58	61	58	62	63	58	62	57	63	58	67	62	68	70	62	58	63	56	62	54	62	63	64	13	11	11	14	10
37963	2015-01-28	63	64	right	high	medium	63	46	63	64	56	58	61	58	62	63	58	62	57	63	58	67	62	68	70	62	58	63	56	62	54	62	63	64	13	11	11	14	10
37963	2014-11-07	63	64	right	high	medium	63	46	63	64	56	58	61	58	62	63	58	62	57	63	58	67	62	68	70	62	58	63	56	62	54	62	63	64	13	11	11	14	10
37963	2014-10-10	63	64	right	high	medium	63	46	64	64	56	61	61	58	62	64	61	62	58	63	59	67	62	68	71	62	58	63	58	62	54	63	64	61	13	11	11	14	10
37963	2014-09-18	63	64	right	high	medium	63	46	64	64	56	61	61	58	62	64	61	62	58	64	59	67	62	68	71	62	58	63	58	64	54	63	64	61	13	11	11	14	10
37963	2014-02-28	63	65	right	medium	medium	62	46	63	63	56	59	61	57	60	63	61	65	60	64	60	68	62	68	72	61	58	63	55	60	54	63	64	62	13	11	11	14	10
37963	2013-11-08	63	65	right	medium	medium	62	46	63	63	56	59	61	57	60	63	61	65	60	64	60	68	62	68	72	61	58	63	55	60	54	63	64	62	13	11	11	14	10
37963	2013-10-11	63	65	right	medium	medium	62	46	62	63	56	59	61	57	60	63	61	65	60	64	60	68	62	68	72	61	58	63	55	60	54	63	64	62	13	11	11	14	10
37963	2013-09-20	64	65	right	medium	medium	62	46	62	63	56	59	61	57	60	63	63	67	60	64	60	68	63	76	73	61	58	63	55	60	54	63	64	62	13	11	11	14	10
37963	2012-02-22	64	65	right	medium	medium	62	46	62	63	56	59	61	57	60	63	63	67	60	64	60	68	63	76	73	61	58	63	55	60	54	63	64	62	13	11	11	14	10
37963	2011-08-30	64	65	right	medium	medium	62	46	62	63	56	59	61	57	60	63	63	67	60	64	60	68	63	76	73	61	58	63	55	60	54	63	64	62	13	11	11	14	10
37963	2010-08-30	64	70	right	medium	medium	63	46	63	65	58	60	61	57	62	64	63	67	60	62	69	69	62	75	73	62	58	63	57	64	54	65	63	64	13	11	11	14	10
37963	2010-02-22	64	68	right	medium	medium	63	43	63	64	58	60	61	56	62	64	63	66	60	59	69	67	62	74	73	62	53	62	61	64	64	65	62	64	9	23	62	23	23
37963	2009-08-30	63	68	right	medium	medium	63	43	63	64	58	60	61	56	62	64	63	66	60	59	69	67	62	70	73	62	53	62	61	64	64	65	62	64	9	23	62	23	23
37963	2008-08-30	58	70	right	medium	medium	54	57	63	61	58	54	61	46	56	59	58	63	60	57	69	58	62	68	66	56	58	50	52	64	56	55	57	64	3	23	56	23	23
37963	2007-08-30	59	70	right	medium	medium	54	57	63	61	58	54	61	46	56	59	58	63	60	57	69	58	62	68	66	56	58	50	52	64	56	55	57	64	3	23	56	23	23
37963	2007-02-22	59	70	right	medium	medium	54	57	63	61	58	54	61	46	56	59	58	63	60	57	69	58	62	68	66	56	58	50	52	64	56	55	57	64	3	23	56	23	23
38440	2016-04-21	70	70	right	high	medium	53	72	69	62	66	62	33	49	43	57	77	78	62	70	65	78	85	76	77	67	73	32	71	62	66	26	42	36	12	13	8	8	8
38440	2016-03-24	70	70	right	high	medium	53	72	69	62	66	62	33	49	43	57	77	78	62	70	65	78	85	76	77	67	73	32	71	65	66	26	42	36	12	13	8	8	8
38440	2015-10-16	70	70	right	high	medium	53	72	69	62	66	62	33	49	43	57	77	80	73	70	65	78	87	76	77	67	73	32	71	65	66	26	42	36	12	13	8	8	8
38440	2015-09-21	70	70	right	medium	medium	53	72	69	62	66	62	33	49	43	57	77	80	73	70	65	78	87	76	77	67	73	32	71	65	66	26	42	36	12	13	8	8	8
38440	2015-05-08	69	69	right	medium	medium	52	69	68	61	65	64	32	48	42	56	80	83	76	69	65	77	84	76	77	71	72	31	68	64	65	25	41	35	11	12	7	7	7
38440	2015-03-20	69	69	right	medium	medium	52	69	68	61	65	64	32	48	42	56	80	83	76	69	65	77	84	76	77	71	72	31	68	64	65	25	41	35	11	12	7	7	7
38440	2015-03-06	70	70	right	medium	medium	52	72	70	61	65	64	32	48	42	56	80	83	76	69	65	77	86	76	78	71	72	31	70	64	65	25	41	35	11	12	7	7	7
38440	2015-02-13	71	71	right	medium	medium	52	74	72	61	65	64	32	48	42	56	80	83	76	69	65	77	86	76	78	71	72	31	73	64	65	25	41	35	11	12	7	7	7
38440	2014-09-18	71	71	right	medium	medium	52	74	72	61	65	64	32	48	42	52	78	83	75	69	65	77	86	74	78	71	72	31	73	64	65	25	41	35	11	12	7	7	7
38440	2013-04-26	71	71	right	medium	medium	52	74	72	61	65	64	32	48	42	52	78	83	75	69	65	77	86	74	78	71	72	31	73	64	65	25	41	35	11	12	7	7	7
38440	2013-04-19	71	71	right	medium	medium	52	74	72	61	65	64	32	48	42	52	78	79	75	69	65	77	86	74	78	71	72	31	73	64	65	25	41	35	11	12	7	7	7
38440	2013-03-08	71	71	right	medium	medium	52	74	72	61	65	64	32	48	42	52	78	83	75	69	65	77	86	74	78	71	72	31	73	64	65	25	41	35	11	12	7	7	7
38440	2013-02-15	71	71	right	medium	medium	52	74	72	61	65	64	32	48	42	52	78	83	75	69	65	77	86	74	78	71	72	31	73	66	65	25	41	35	11	12	7	7	7
38440	2012-08-31	72	71	right	high	medium	52	74	72	61	65	64	32	48	42	52	78	88	81	69	65	77	86	84	78	71	72	31	73	66	64	25	41	35	11	12	7	7	7
38440	2012-02-22	71	71	right	high	medium	51	74	71	61	63	64	32	48	42	56	78	88	81	69	73	78	86	84	81	71	72	31	69	63	64	23	30	31	11	12	7	7	7
38440	2011-08-30	68	71	right	high	medium	51	71	67	56	56	64	32	45	42	53	78	88	81	69	71	75	83	83	78	67	58	24	66	46	64	21	31	29	11	12	7	7	7
38440	2011-02-22	68	73	right	high	medium	51	71	67	56	56	53	32	45	42	57	78	81	71	69	73	75	75	80	78	67	48	24	66	46	64	21	29	24	11	12	7	7	7
38440	2010-08-30	69	73	right	high	medium	51	73	68	56	63	56	32	45	42	57	78	81	71	69	73	75	75	80	78	68	48	24	66	46	64	21	29	24	11	12	7	7	7
38440	2009-08-30	68	73	right	high	medium	51	73	68	57	63	56	32	55	45	57	73	75	71	68	73	70	75	67	78	68	43	35	58	46	66	21	29	24	3	23	45	23	23
38440	2009-02-22	68	74	right	high	medium	51	73	68	57	63	56	32	55	45	58	72	75	71	68	73	70	75	67	78	68	43	35	58	46	66	21	29	24	1	23	45	23	23
38440	2008-08-30	68	74	right	high	medium	51	71	65	57	63	60	32	55	45	62	72	73	71	68	73	70	75	67	74	68	43	35	58	46	66	21	29	24	1	23	45	23	23
38440	2007-08-30	63	68	right	high	medium	68	65	58	46	63	57	32	41	33	60	62	67	71	61	73	64	75	58	66	56	43	35	58	46	61	21	39	24	1	23	33	23	23
38440	2007-02-22	61	73	right	high	medium	34	62	58	46	63	57	32	54	33	52	62	67	71	61	73	64	75	58	66	56	43	35	58	46	54	25	22	24	1	1	33	1	1
15456	2008-08-30	59	62	right	\N	\N	41	37	60	49	\N	30	\N	39	47	41	53	57	\N	55	\N	59	\N	65	75	39	70	59	62	\N	65	56	60	\N	5	22	47	22	22
15456	2007-02-22	59	62	right	\N	\N	41	37	60	49	\N	30	\N	39	47	41	53	57	\N	55	\N	59	\N	65	75	39	70	59	62	\N	65	56	60	\N	5	22	47	22	22
38289	2015-04-24	60	60	right	medium	medium	25	25	25	37	25	25	25	25	31	25	25	25	25	56	25	39	38	25	71	25	25	25	25	25	34	25	25	25	60	54	61	68	58
38289	2014-09-18	61	61	right	medium	medium	25	25	25	37	25	25	25	25	31	25	25	25	25	58	25	39	38	25	71	25	25	25	25	25	34	25	25	25	62	54	64	68	61
38289	2014-07-18	61	61	right	medium	medium	25	25	25	37	25	25	25	25	31	25	25	25	25	58	25	39	38	25	71	25	25	25	25	25	34	25	25	25	62	54	64	68	61
38289	2014-03-14	61	61	right	medium	medium	25	25	25	37	25	25	25	25	31	25	25	25	25	58	25	39	38	25	71	25	25	25	25	25	34	25	25	25	62	54	64	68	61
38289	2013-09-20	63	63	right	medium	medium	25	25	25	37	25	25	25	25	31	25	25	25	25	58	25	39	38	25	71	25	25	25	25	25	34	25	25	25	66	55	65	68	64
38289	2013-06-07	63	63	right	medium	medium	11	19	14	37	17	13	11	13	31	15	33	28	24	58	33	39	56	38	82	13	12	24	11	5	34	16	12	11	66	55	65	68	64
38289	2013-05-10	63	65	right	medium	medium	11	19	14	37	17	13	11	13	31	15	33	28	24	58	33	39	56	38	82	13	12	24	11	5	34	16	12	11	66	55	65	68	64
38289	2013-04-12	64	65	right	medium	medium	11	19	14	37	17	13	11	13	31	15	33	28	24	58	33	39	56	38	82	13	12	24	11	5	34	16	12	11	66	58	65	68	67
38289	2013-03-28	64	64	right	medium	medium	11	19	14	37	17	13	11	13	31	15	33	28	24	45	33	39	56	38	82	13	17	24	11	29	34	16	12	11	66	58	65	68	67
38289	2013-02-15	64	64	right	medium	medium	11	19	14	37	17	13	11	13	31	15	33	28	24	45	33	39	56	38	82	13	17	24	11	29	34	16	12	11	66	58	65	68	67
38289	2012-08-31	64	64	right	medium	medium	11	19	14	37	17	13	11	13	31	15	33	28	44	45	33	39	62	51	82	13	17	24	11	29	34	16	12	11	71	53	66	67	69
38289	2012-02-22	63	64	right	medium	medium	11	19	14	37	17	13	11	13	31	15	36	46	55	53	21	39	60	51	83	13	17	24	11	29	34	16	12	11	62	63	61	66	64
38289	2011-08-30	63	63	right	medium	medium	11	19	14	37	17	13	11	13	31	15	36	46	55	53	21	39	60	51	83	13	17	24	11	29	34	16	12	11	62	63	61	66	64
38289	2011-02-22	63	64	right	medium	medium	11	19	14	37	17	13	11	13	31	15	36	46	55	53	73	45	60	51	83	13	17	24	11	49	34	16	12	11	62	63	54	66	64
38289	2010-08-30	63	64	right	medium	medium	11	19	37	37	17	13	11	13	31	15	36	46	55	53	73	59	60	51	83	9	17	24	11	49	34	16	29	11	62	63	54	66	64
38289	2009-08-30	61	64	right	medium	medium	21	29	37	32	17	33	11	33	53	30	34	39	55	53	73	49	60	61	77	21	57	37	10	49	49	26	39	11	61	62	53	65	63
38289	2008-08-30	61	64	right	medium	medium	21	29	37	32	17	33	11	33	53	30	34	39	55	53	73	49	60	61	77	21	57	37	10	49	49	26	39	11	61	60	53	65	63
38289	2007-08-30	66	67	right	medium	medium	21	29	37	32	17	33	11	33	56	30	34	39	55	53	73	49	60	61	77	21	57	37	10	49	49	26	39	11	63	61	56	65	66
38289	2007-02-22	67	65	right	medium	medium	11	29	37	32	17	33	11	49	58	30	49	54	55	58	73	49	60	61	77	9	57	37	10	49	49	26	39	11	68	63	58	65	66
37112	2015-09-25	72	72	right	high	high	75	68	58	74	74	69	75	75	75	72	52	50	62	70	65	73	62	76	65	75	55	70	73	75	83	42	58	53	6	10	12	7	10
37112	2015-09-21	72	72	right	high	high	75	68	58	72	74	69	75	75	74	73	57	54	63	70	65	73	62	77	65	74	55	70	73	75	83	53	63	61	6	10	12	7	10
37112	2015-05-15	71	71	right	high	high	67	67	57	72	71	69	75	74	74	72	62	59	65	70	67	72	64	75	67	75	54	69	74	75	82	42	53	56	5	9	11	6	9
37112	2015-04-17	71	71	right	high	high	67	67	57	72	71	69	75	74	74	72	62	59	65	70	67	75	64	75	67	77	54	69	74	75	82	42	53	56	5	9	11	6	9
37112	2015-03-13	71	71	right	high	high	67	67	57	72	71	69	75	77	74	72	62	59	65	70	67	75	64	75	67	77	54	69	74	75	82	42	53	56	5	9	11	6	9
37112	2015-02-06	71	71	right	high	high	67	67	57	72	71	69	75	77	74	72	62	59	65	70	67	75	64	75	67	77	65	69	74	75	82	42	53	56	5	9	11	6	9
37112	2015-01-09	71	71	right	high	high	67	67	57	72	71	69	75	77	74	72	62	59	65	70	67	75	64	75	67	77	65	69	74	75	89	42	53	56	5	9	11	6	9
37112	2014-09-18	72	72	right	high	high	67	67	57	72	71	69	76	79	74	73	62	59	67	70	67	75	65	80	67	77	67	69	74	75	89	42	53	56	5	9	11	6	9
37112	2014-03-21	72	72	right	high	high	67	67	57	72	71	69	76	79	74	73	62	62	67	70	67	75	65	79	67	77	67	69	74	75	89	42	53	56	5	9	11	6	9
37112	2014-01-03	72	72	right	high	high	67	67	57	72	71	69	76	79	74	73	62	62	67	70	67	75	65	79	67	77	67	69	74	75	73	42	53	56	5	9	11	6	9
37112	2013-12-06	71	72	right	high	high	67	67	57	72	71	69	76	79	74	73	62	61	67	70	67	75	67	79	65	77	67	62	74	75	73	42	53	56	5	9	11	6	9
37112	2013-11-29	71	72	right	high	high	67	67	57	72	71	69	76	79	74	73	62	61	67	70	67	75	67	79	65	77	67	62	74	75	73	42	53	56	5	9	11	6	9
37112	2013-11-01	71	72	right	high	high	67	67	57	72	71	69	76	79	74	73	62	61	67	70	67	75	67	79	65	77	67	62	74	71	73	42	53	56	5	9	11	6	9
37112	2013-09-20	70	72	right	high	high	67	67	57	72	71	69	76	79	71	73	62	61	67	70	67	73	67	80	70	76	70	62	74	71	73	42	53	56	5	9	11	6	9
37112	2013-05-31	70	72	right	high	high	67	67	57	72	71	69	76	79	71	73	62	62	67	70	67	73	66	79	70	76	70	62	74	71	73	42	53	56	5	9	11	6	9
37112	2013-03-01	71	72	right	high	high	69	72	57	72	71	69	76	79	71	73	62	62	67	70	67	75	66	79	70	76	70	62	74	71	73	45	57	59	5	9	11	6	9
37112	2013-02-15	71	72	right	high	high	69	72	57	72	71	69	76	79	71	73	62	65	67	70	67	75	66	79	70	76	70	62	74	71	73	45	57	59	5	9	11	6	9
37112	2012-08-31	71	72	right	high	high	67	72	57	71	71	69	76	79	69	73	61	67	67	68	66	75	66	77	72	76	70	53	74	71	73	45	52	57	5	9	11	6	9
37112	2011-08-30	71	73	right	high	high	67	72	57	71	71	69	76	79	69	73	61	67	67	68	66	75	66	77	72	76	70	53	74	71	73	45	52	57	5	9	11	6	9
37112	2011-02-22	67	73	right	high	high	64	62	55	70	67	64	63	69	68	68	62	67	65	64	65	74	63	69	64	73	70	52	66	69	70	47	52	57	5	9	11	6	9
37112	2010-08-30	67	73	right	high	high	64	62	55	70	67	64	63	69	68	68	62	67	65	64	65	74	63	69	64	73	70	52	66	69	70	47	52	57	5	9	11	6	9
37112	2010-02-22	65	69	right	high	high	62	62	55	69	67	60	63	68	64	65	57	62	65	64	65	72	63	67	60	69	67	65	63	69	59	37	42	57	8	20	64	20	20
37112	2009-08-30	64	69	right	high	high	62	59	55	69	67	60	63	68	64	65	57	62	65	64	65	72	63	67	60	69	42	65	63	69	59	37	42	57	8	20	64	20	20
37112	2008-08-30	60	65	right	high	high	49	48	52	74	67	55	63	64	64	65	42	57	65	54	65	63	63	57	52	60	42	65	63	69	52	47	42	57	8	20	64	20	20
37112	2007-08-30	62	65	right	high	high	49	48	52	74	67	55	63	64	64	65	42	57	65	54	65	63	63	57	52	60	42	65	63	69	52	47	42	57	8	20	64	20	20
37112	2007-02-22	62	65	right	high	high	49	48	52	74	67	55	63	52	64	65	42	57	65	54	65	63	63	57	52	60	42	65	63	69	52	47	42	57	8	8	64	8	7
38318	2010-02-22	64	66	right	\N	\N	25	25	25	22	\N	25	\N	9	53	27	43	46	\N	62	\N	51	\N	49	76	25	28	64	12	\N	58	25	25	\N	65	62	53	64	67
38318	2009-08-30	64	66	right	\N	\N	25	25	25	22	\N	25	\N	9	53	27	43	46	\N	62	\N	51	\N	49	76	25	28	64	12	\N	58	25	25	\N	65	62	53	64	67
38318	2009-02-22	64	66	right	\N	\N	25	25	25	22	\N	25	\N	9	53	27	43	46	\N	62	\N	51	\N	49	76	25	28	64	12	\N	58	25	25	\N	65	62	53	64	67
38318	2008-08-30	64	67	right	\N	\N	25	25	25	22	\N	25	\N	9	53	27	43	46	\N	62	\N	51	\N	49	76	25	28	64	12	\N	58	25	25	\N	65	62	53	64	67
38318	2007-08-30	63	65	right	\N	\N	25	25	25	25	\N	25	\N	9	48	27	43	46	\N	62	\N	25	\N	49	76	25	68	64	32	\N	48	25	25	\N	60	62	48	63	61
38318	2007-02-22	63	65	right	\N	\N	11	11	8	12	\N	12	\N	48	48	27	43	46	\N	62	\N	11	\N	49	76	12	68	64	32	\N	48	9	12	\N	60	62	48	63	61
36868	2011-02-22	64	67	right	\N	\N	52	42	60	60	47	53	34	51	56	63	68	67	63	63	80	65	66	76	79	43	76	62	46	58	54	59	64	63	5	6	15	8	7
36868	2010-08-30	65	67	right	\N	\N	56	42	60	63	47	53	34	51	56	63	68	67	63	63	80	65	66	76	79	43	76	64	51	58	54	62	67	66	5	6	15	8	7
36868	2009-08-30	65	67	right	\N	\N	56	42	60	63	47	53	34	51	56	63	68	67	63	63	80	65	66	76	79	43	76	65	66	58	66	62	67	66	12	20	56	20	20
36868	2008-08-30	62	64	right	\N	\N	56	42	60	61	47	53	34	51	56	58	68	67	63	63	80	65	66	72	73	43	74	51	52	58	62	62	64	66	12	20	56	20	20
36868	2007-08-30	62	64	right	\N	\N	56	42	60	58	47	53	34	51	56	58	68	67	63	63	80	65	66	71	73	43	74	51	52	58	62	61	63	66	12	20	56	20	20
36868	2007-02-22	64	63	left	\N	\N	59	62	70	63	47	60	34	62	65	67	60	67	63	63	80	49	66	69	65	65	63	51	52	58	62	60	57	66	12	11	65	6	10
97368	2009-02-22	64	70	right	\N	\N	45	64	68	49	\N	66	\N	79	52	77	59	65	\N	66	\N	68	\N	57	62	61	66	69	57	\N	58	22	22	\N	8	22	52	22	22
97368	2008-08-30	64	66	right	\N	\N	45	64	68	49	\N	66	\N	79	52	77	59	65	\N	66	\N	68	\N	57	62	61	66	69	57	\N	58	22	22	\N	8	22	52	22	22
97368	2007-02-22	64	66	right	\N	\N	45	64	68	49	\N	66	\N	79	52	77	59	65	\N	66	\N	68	\N	57	62	61	66	69	57	\N	58	22	22	\N	8	22	52	22	22
12692	2015-10-16	70	70	left	medium	medium	64	64	71	70	63	77	63	65	69	79	67	75	62	68	49	77	65	75	81	71	70	63	66	65	61	48	58	53	14	6	7	10	12
12692	2015-10-02	70	71	left	medium	medium	64	64	71	70	63	77	63	65	69	79	67	75	62	68	49	77	65	75	81	71	70	63	66	65	61	48	58	53	14	6	7	10	12
12692	2015-09-21	70	72	left	medium	medium	64	64	71	70	63	77	63	65	69	79	67	75	62	68	49	77	65	75	81	71	70	63	66	65	61	48	58	53	14	6	7	10	12
12692	2014-09-18	69	74	left	medium	medium	65	65	70	69	62	76	62	64	68	78	67	75	62	67	49	76	65	75	81	70	69	62	65	64	60	47	57	52	13	5	6	9	11
12692	2014-04-25	69	74	left	medium	medium	65	65	70	69	62	76	62	64	68	78	67	75	62	67	50	76	65	75	81	70	69	62	65	64	60	47	57	52	13	5	6	9	11
12692	2013-11-01	69	72	left	medium	medium	65	65	70	69	62	76	62	64	68	78	67	75	62	67	50	76	65	75	85	70	69	62	65	64	60	47	57	52	13	5	6	9	11
12692	2013-09-20	69	72	left	medium	medium	65	65	70	69	62	76	62	64	68	78	67	75	62	67	50	76	65	75	85	70	69	62	65	64	60	47	57	52	13	5	6	9	11
12692	2013-03-22	70	73	left	medium	medium	65	65	70	70	62	77	62	64	69	79	67	75	62	67	50	77	65	75	85	71	69	62	65	65	60	47	57	52	13	5	6	9	11
12692	2013-03-01	70	73	left	medium	medium	65	65	70	70	62	77	62	64	69	79	67	75	62	67	50	77	65	75	85	71	69	62	65	65	60	47	57	52	13	5	6	9	11
12692	2013-02-15	70	73	left	medium	medium	65	65	70	70	62	77	62	64	69	79	67	75	62	67	50	77	65	75	85	71	69	62	65	65	60	47	57	52	13	5	6	9	11
12692	2012-08-31	71	74	left	high	medium	65	65	70	72	62	74	62	64	67	77	72	74	69	68	47	75	65	70	85	69	65	57	67	67	60	42	55	47	13	5	6	9	11
12692	2012-02-22	68	72	left	medium	medium	62	64	64	65	62	72	57	65	62	74	66	68	70	65	45	75	65	67	81	69	64	45	64	64	62	34	45	39	13	5	6	9	11
12692	2011-08-30	68	72	left	high	medium	61	64	67	65	63	72	57	66	62	74	66	69	71	67	45	75	65	67	82	69	65	45	64	64	62	34	45	39	13	5	6	9	11
12692	2011-02-22	70	74	left	high	medium	62	65	67	66	63	74	57	66	64	77	65	70	71	67	70	75	63	66	77	69	65	47	72	65	62	39	37	35	13	5	6	9	11
12692	2010-08-30	69	74	left	high	medium	62	64	67	67	63	74	57	66	65	77	62	69	64	64	70	75	63	66	77	69	65	47	67	65	62	39	37	35	13	5	6	9	11
12692	2010-02-22	67	73	left	high	medium	61	62	65	63	63	70	57	64	62	75	62	67	64	60	70	74	63	60	77	67	63	49	51	65	52	22	27	35	9	22	62	22	22
12692	2009-08-30	66	70	left	high	medium	51	61	65	62	63	70	57	51	48	75	62	67	64	60	70	72	63	60	77	67	63	45	51	65	47	22	27	35	9	22	48	22	22
12692	2009-02-22	64	70	left	high	medium	51	61	65	62	63	65	57	51	48	67	62	67	64	60	70	72	63	60	77	64	63	45	51	65	47	22	27	35	9	22	48	22	22
12692	2008-08-30	64	70	left	high	medium	51	61	65	62	63	62	57	51	48	67	62	67	64	60	70	69	63	60	77	64	63	45	51	65	47	22	27	35	9	22	48	22	22
12692	2007-02-22	64	70	left	high	medium	51	61	65	62	63	62	57	51	48	67	62	67	64	60	70	69	63	60	77	64	63	45	51	65	47	22	27	35	9	22	48	22	22
37886	2016-03-24	67	67	right	medium	medium	48	28	71	68	34	44	42	41	66	58	31	32	54	61	59	56	54	68	67	37	65	75	35	47	49	68	71	66	12	9	12	15	11
37886	2016-02-11	67	67	right	medium	medium	48	28	71	68	34	44	42	41	66	58	35	32	54	61	59	56	56	68	67	37	65	75	35	47	49	68	71	66	12	9	12	15	11
37886	2015-09-21	69	69	right	medium	medium	48	28	72	69	34	44	42	41	66	61	36	34	56	66	59	58	62	75	70	37	66	75	35	47	49	70	72	68	12	9	12	15	11
37886	2015-02-06	67	67	right	medium	medium	47	27	71	68	33	43	41	40	65	60	41	46	56	65	59	57	60	75	70	36	65	74	34	46	48	67	69	65	11	8	11	14	10
37886	2014-11-28	67	67	right	medium	medium	47	27	71	68	33	43	41	40	65	60	41	46	56	65	59	57	60	75	70	36	65	74	34	46	48	67	69	65	11	8	11	14	10
37886	2014-09-18	68	68	right	medium	medium	47	27	72	68	33	43	41	40	65	60	41	47	57	66	59	57	62	77	70	36	65	74	34	46	48	68	71	66	11	8	11	14	10
37886	2014-02-21	68	68	right	medium	medium	47	27	72	68	33	43	41	40	65	60	41	46	57	66	59	57	62	77	70	36	65	74	34	46	48	68	71	66	11	8	11	14	10
37886	2013-11-29	68	68	right	medium	medium	47	27	72	68	33	43	41	40	65	60	41	46	57	65	59	57	62	77	70	36	65	74	34	46	48	68	71	66	11	8	11	14	10
37886	2013-09-20	68	68	right	medium	medium	47	27	72	68	33	43	41	40	65	60	41	46	57	65	59	57	62	77	70	36	65	74	34	46	48	68	71	66	11	8	11	14	10
37886	2013-05-17	69	69	right	medium	medium	47	27	72	69	33	43	41	40	65	61	41	48	57	66	59	57	64	79	70	36	67	74	34	46	48	69	71	67	11	8	11	14	10
37886	2013-03-28	69	69	right	medium	medium	47	27	72	69	33	43	41	40	65	61	41	48	57	66	59	57	64	79	70	36	67	74	34	46	48	69	71	67	11	8	11	14	10
37886	2013-03-15	69	69	right	medium	medium	47	27	72	69	33	43	41	40	65	61	41	48	57	66	59	57	64	79	70	36	67	74	34	46	48	69	71	67	11	8	11	14	10
37886	2013-02-15	67	67	right	medium	medium	47	27	72	68	33	43	41	40	63	61	41	48	56	63	66	57	64	79	70	36	69	73	34	46	48	66	67	64	11	8	11	14	10
37886	2012-08-31	67	67	right	medium	medium	47	27	72	68	33	43	41	40	63	61	41	50	54	63	65	57	64	77	70	36	69	73	34	46	48	66	67	64	11	8	11	14	10
37886	2012-02-22	67	67	right	medium	medium	47	27	72	68	33	43	41	40	63	61	41	50	54	63	65	57	64	77	70	36	69	73	34	46	48	66	67	64	11	8	11	14	10
37886	2011-08-30	67	67	right	medium	medium	47	27	72	68	33	43	41	40	63	61	41	51	54	63	65	57	64	77	70	36	69	73	34	46	48	66	67	64	11	8	11	14	10
37886	2011-02-22	68	69	right	medium	medium	53	37	73	68	43	48	46	45	63	62	57	62	59	64	67	57	65	78	70	36	69	74	44	72	51	67	68	65	11	8	11	14	10
37886	2010-08-30	68	69	right	medium	medium	53	37	73	68	43	48	46	45	63	62	57	62	59	64	67	57	65	78	70	36	69	74	54	72	51	67	68	65	11	8	11	14	10
37886	2010-02-22	68	69	right	medium	medium	53	37	73	68	43	48	46	45	63	65	57	62	59	64	67	57	65	78	70	36	69	74	71	72	73	67	68	65	13	23	63	23	23
37886	2009-08-30	67	69	right	medium	medium	53	37	73	68	43	48	46	45	63	65	56	62	59	64	67	57	65	78	67	36	69	74	71	72	73	65	67	65	13	23	63	23	23
37886	2009-02-22	66	67	right	medium	medium	51	50	68	68	43	53	46	47	58	66	56	57	59	64	67	57	65	78	66	36	67	74	65	72	73	66	66	65	13	23	58	23	23
37886	2008-08-30	66	67	right	medium	medium	50	50	68	51	43	53	46	47	48	66	56	57	59	64	67	57	65	78	66	36	74	75	65	72	76	66	66	65	13	23	48	23	23
37886	2007-08-30	68	67	right	medium	medium	50	50	68	51	43	53	46	47	48	66	56	57	59	64	67	57	65	78	66	36	74	75	65	72	76	66	66	65	13	23	48	23	23
37886	2007-02-22	68	67	right	medium	medium	50	50	68	51	43	53	46	76	48	66	56	57	59	64	67	57	65	78	66	36	74	75	65	72	76	66	66	65	13	11	48	7	7
39578	2016-04-28	67	67	right	high	high	62	62	72	67	58	55	47	59	65	64	45	50	57	67	60	70	65	75	72	67	72	72	77	67	65	57	67	65	14	6	14	13	16
39578	2016-02-25	68	68	right	high	high	64	65	75	68	63	57	48	59	66	65	47	55	60	70	62	72	71	80	75	68	75	72	77	67	65	57	67	65	14	6	14	13	16
39578	2015-09-21	68	68	right	high	high	64	65	75	68	63	57	48	59	66	65	47	55	60	70	62	72	71	80	75	68	75	72	77	67	65	57	67	65	14	6	14	13	16
39578	2015-04-10	69	69	right	high	high	64	65	76	68	62	59	47	58	66	64	53	58	62	73	62	74	71	82	78	68	78	71	75	67	64	59	67	66	13	5	13	12	15
39578	2015-01-09	69	69	right	high	high	64	65	76	68	62	59	47	58	66	64	53	58	62	73	62	74	71	82	78	68	78	71	75	67	64	59	67	66	13	5	13	12	15
39578	2014-11-28	68	68	right	high	high	64	65	76	68	62	59	47	58	66	64	53	58	62	73	62	74	71	82	78	68	78	71	75	67	64	59	67	66	13	5	13	12	15
39578	2014-11-07	68	68	right	high	high	64	65	76	68	62	59	47	58	66	64	55	65	62	73	62	74	71	82	78	68	78	71	75	67	64	59	67	66	13	5	13	12	15
39578	2014-09-18	68	68	right	high	high	64	65	76	68	62	59	47	58	66	64	55	65	62	73	62	74	71	82	78	68	78	71	75	67	64	59	67	66	13	5	13	12	15
39578	2014-02-14	69	69	right	high	high	64	65	77	69	62	59	47	58	67	64	55	65	62	73	62	75	71	85	78	68	78	71	75	67	64	59	68	66	13	5	13	12	15
39578	2013-09-20	69	69	right	high	high	64	65	77	69	62	59	47	58	67	64	55	65	62	73	62	75	71	85	78	68	78	71	75	67	64	59	69	67	13	5	13	12	15
39578	2013-05-31	69	69	right	high	high	64	65	77	69	62	59	47	58	67	64	57	65	62	73	62	75	70	85	78	68	78	71	75	67	64	59	69	67	13	5	13	12	15
39578	2013-03-22	69	69	right	high	high	64	65	77	69	62	59	47	58	67	64	57	65	62	73	62	75	70	85	78	68	78	71	75	67	64	59	69	67	13	5	13	12	15
39578	2013-03-08	69	69	right	high	high	64	65	77	69	62	59	47	58	67	64	57	65	62	73	62	75	70	85	78	68	78	71	75	67	64	59	69	67	13	5	13	12	15
39578	2013-02-15	69	69	right	high	high	64	65	77	69	62	59	47	58	67	64	57	65	62	73	62	75	70	85	78	68	78	71	75	67	64	59	69	67	13	5	13	12	15
39578	2012-08-31	68	68	right	high	high	63	65	75	68	62	55	47	58	66	62	52	65	62	73	59	75	65	85	78	67	78	71	75	65	64	57	67	65	13	5	13	12	15
39578	2012-02-22	67	67	right	high	high	62	67	75	67	61	52	47	58	65	62	52	65	62	72	59	72	60	86	75	65	80	73	75	67	64	57	67	65	13	5	13	12	15
39578	2011-08-30	67	70	right	high	high	62	67	75	67	61	52	47	58	65	62	52	65	62	72	59	72	60	85	75	65	80	73	75	67	64	57	67	65	13	5	13	12	15
39578	2010-08-30	67	72	right	high	high	60	67	75	65	61	52	47	58	62	62	55	67	62	72	82	72	72	87	79	65	80	73	75	73	64	57	67	65	13	5	13	12	15
39578	2010-02-22	68	72	right	high	high	60	67	75	65	61	55	47	58	62	62	55	65	62	73	82	72	72	85	75	65	80	74	83	73	72	57	67	65	7	20	62	20	20
39578	2009-08-30	67	72	right	high	high	61	66	74	66	61	54	47	58	64	62	55	65	62	72	82	72	72	80	75	65	80	72	76	73	71	61	62	65	7	20	64	20	20
39578	2009-02-22	69	72	right	high	high	62	67	75	67	61	55	47	58	65	62	60	65	62	72	82	74	72	83	78	65	82	75	80	73	73	65	69	65	11	20	65	20	20
39578	2008-08-30	70	72	right	high	high	65	67	75	70	61	55	47	58	65	62	60	65	62	73	82	74	72	83	78	67	82	75	80	73	73	67	70	65	11	20	65	20	20
39578	2007-08-30	71	74	right	high	high	68	72	75	72	61	62	47	64	65	67	65	67	62	73	82	75	72	85	78	72	81	75	82	73	73	67	74	65	11	20	65	20	20
39578	2007-02-22	72	74	right	high	high	68	73	75	73	61	65	47	71	66	70	72	74	62	73	82	75	72	83	73	72	81	75	82	73	71	74	74	65	11	9	66	14	6
149279	2015-02-06	63	63	right	medium	medium	53	31	66	63	36	43	60	63	58	58	38	46	41	54	48	65	49	58	72	58	68	71	46	57	62	60	64	59	8	7	14	14	13
149279	2014-09-18	64	64	right	medium	medium	53	31	66	63	36	43	60	63	58	58	42	54	41	56	48	65	49	60	72	58	72	71	46	57	62	63	65	59	8	7	14	14	13
149279	2014-05-09	63	63	right	medium	medium	53	31	66	61	36	42	60	61	56	55	42	53	41	56	48	65	51	60	72	48	72	68	46	57	62	63	63	59	8	7	14	14	13
149279	2014-03-21	64	64	right	medium	medium	53	31	66	61	36	42	60	61	56	57	42	53	41	61	48	65	51	60	74	48	72	70	46	57	62	63	64	59	8	7	14	14	13
149279	2014-02-07	64	64	right	medium	medium	57	41	66	64	36	42	60	61	58	57	43	53	41	62	48	65	51	60	74	54	72	70	46	57	62	63	64	59	8	7	14	14	13
149279	2013-12-13	64	64	right	medium	medium	57	41	64	64	36	42	60	61	58	57	43	53	41	62	48	65	51	61	74	54	72	70	46	57	62	63	65	59	8	7	14	14	13
149279	2013-11-29	64	64	right	medium	medium	57	41	64	64	36	42	60	61	58	57	43	53	41	52	48	65	51	61	74	54	72	70	46	57	62	63	65	59	8	7	14	14	13
149279	2013-10-11	64	64	right	medium	medium	57	41	64	64	36	42	60	61	58	57	43	56	41	52	48	65	51	61	74	54	72	70	46	57	62	63	65	59	8	7	14	14	13
149279	2013-09-20	64	64	right	medium	medium	57	41	64	64	36	42	60	61	58	57	43	58	41	52	48	65	51	61	73	54	72	70	46	57	62	63	65	59	8	7	14	14	13
149279	2013-05-31	64	64	right	medium	medium	57	41	63	64	36	42	60	61	61	57	42	46	41	52	48	65	54	64	74	54	72	69	46	57	62	62	64	59	8	7	14	14	13
149279	2013-05-10	64	64	right	medium	medium	57	41	63	64	36	42	60	61	61	57	42	46	41	52	48	65	54	64	74	54	72	69	46	57	62	62	64	59	8	7	14	14	13
149279	2013-03-22	64	64	right	medium	medium	57	41	63	64	36	42	60	61	61	57	42	46	41	52	48	65	54	64	74	54	72	69	46	57	62	62	64	59	8	7	14	14	13
149279	2013-03-15	64	64	right	medium	medium	57	41	63	64	36	42	60	61	61	57	42	46	41	52	48	65	54	64	74	54	72	69	46	57	62	62	64	59	8	7	14	14	13
149279	2013-02-15	64	64	right	medium	medium	57	41	63	64	36	42	60	61	61	57	42	46	41	52	48	65	54	64	74	54	72	69	46	57	62	62	64	59	8	7	14	14	13
149279	2012-08-31	64	64	right	medium	medium	60	42	63	64	36	45	61	64	61	57	47	54	52	60	48	68	57	67	74	58	72	70	46	54	62	62	64	61	8	7	14	14	13
149279	2012-02-22	66	66	right	medium	medium	64	47	62	66	36	56	66	66	63	61	53	61	54	60	57	68	57	73	76	63	74	72	46	54	63	64	66	63	8	7	14	14	13
149279	2011-08-30	66	66	right	medium	medium	64	47	62	66	36	56	66	66	63	61	53	61	54	60	56	68	57	73	76	63	74	72	46	54	63	64	66	63	8	7	14	14	13
149279	2011-02-22	65	66	right	medium	medium	66	52	58	64	36	45	66	66	63	61	61	66	60	60	65	68	60	72	73	63	72	72	57	62	63	64	65	63	8	7	14	14	13
149279	2010-08-30	65	67	right	medium	medium	66	52	58	64	36	45	66	66	63	61	61	66	60	60	65	68	60	72	73	63	72	72	57	62	63	64	65	63	8	7	14	14	13
149279	2010-02-22	64	68	right	medium	medium	62	43	58	59	36	45	66	64	55	60	61	66	60	60	65	64	60	72	73	57	72	70	68	62	66	64	65	63	1	23	55	23	23
149279	2009-08-30	63	64	right	medium	medium	62	43	58	59	36	45	66	64	55	60	60	64	60	60	65	64	60	68	73	57	72	70	68	62	66	64	65	63	1	23	55	23	23
149279	2009-02-22	58	60	right	medium	medium	40	33	58	59	36	45	66	34	50	48	56	60	60	58	65	59	60	68	73	37	70	64	63	62	61	51	57	63	1	23	50	23	23
149279	2008-08-30	55	58	right	medium	medium	37	30	55	56	36	42	66	31	47	45	53	57	60	55	65	56	60	65	70	34	67	61	60	62	58	48	54	63	1	23	47	23	23
149279	2007-02-22	55	58	right	medium	medium	37	30	55	56	36	42	66	31	47	45	53	57	60	55	65	56	60	65	70	34	67	61	60	62	58	48	54	63	1	23	47	23	23
38791	2014-02-14	64	64	right	medium	medium	54	31	60	67	46	53	43	48	65	61	62	65	72	65	78	63	63	77	60	61	67	66	53	64	47	58	59	60	10	9	10	10	7
38791	2013-11-29	64	64	right	medium	medium	54	31	60	67	46	53	43	48	65	61	62	65	72	65	78	63	63	77	60	61	67	66	53	64	47	58	59	60	10	9	10	10	7
38791	2013-09-20	64	64	right	medium	medium	54	31	60	67	46	53	43	48	65	61	62	65	72	65	78	63	63	77	60	61	67	66	53	64	47	58	59	60	10	9	10	10	7
38791	2013-04-26	64	64	right	medium	medium	54	31	60	67	46	53	43	48	65	61	62	65	72	65	78	63	63	77	60	61	67	66	53	64	47	58	59	60	10	9	10	10	7
38791	2013-02-15	64	64	right	medium	medium	54	31	60	67	46	53	43	48	65	61	62	65	72	65	78	63	63	77	60	61	67	66	53	64	47	58	59	60	10	9	10	10	7
38791	2012-08-31	63	63	right	medium	medium	53	27	57	64	37	48	43	48	65	59	62	67	74	63	77	57	63	73	57	53	67	66	48	56	47	61	62	63	10	9	10	10	7
38791	2012-02-22	62	63	right	medium	medium	53	27	57	63	37	48	43	48	65	59	62	67	74	63	77	57	63	73	42	53	67	66	48	56	47	61	62	63	10	9	10	10	7
38791	2011-08-30	62	63	right	medium	medium	53	27	57	63	37	48	43	48	65	59	62	67	74	63	77	57	63	73	42	53	67	66	48	56	47	61	62	63	10	9	10	10	7
38791	2009-08-30	62	63	right	medium	medium	53	27	57	63	37	48	43	48	65	59	62	67	74	63	77	57	63	73	42	53	67	66	48	56	47	61	62	63	10	9	10	10	7
38791	2008-08-30	62	63	right	medium	medium	53	27	39	63	37	48	43	48	65	59	62	67	74	63	77	57	63	73	42	53	67	66	48	56	47	61	62	63	11	9	10	10	7
38791	2007-08-30	55	63	left	medium	medium	45	27	39	63	37	48	43	48	65	59	59	65	74	63	77	57	63	66	64	53	67	66	48	56	47	34	62	63	11	9	10	10	7
38791	2007-02-22	55	63	left	medium	medium	45	27	39	63	37	48	43	48	65	59	59	65	74	63	77	57	63	66	64	53	67	66	48	56	47	34	62	63	11	9	10	10	7
38255	2014-05-02	65	65	left	high	high	61	46	67	57	43	37	33	47	54	47	71	72	65	64	65	72	80	84	67	62	85	59	52	53	45	63	64	65	12	11	11	10	11
38255	2013-09-20	65	68	left	high	high	61	46	67	57	43	37	33	47	54	47	71	72	65	64	65	72	80	84	67	62	85	59	52	53	45	63	64	65	12	11	11	10	11
38255	2013-02-15	65	68	left	high	high	61	46	67	57	43	37	33	47	54	47	71	72	65	64	65	72	79	84	67	62	85	59	52	53	45	63	64	65	12	11	11	10	11
38255	2012-08-31	66	68	left	high	high	62	46	70	57	43	37	33	47	54	47	72	73	65	64	64	72	76	84	67	62	85	60	52	53	45	64	66	67	12	11	11	10	11
38255	2012-02-22	66	67	left	high	high	62	46	70	57	43	37	33	47	54	47	72	73	65	64	64	72	76	84	67	62	85	60	52	53	45	64	66	67	12	11	11	10	11
38255	2011-08-30	66	68	left	high	high	60	53	70	57	47	43	44	44	54	47	78	75	65	64	67	68	76	86	65	62	83	60	53	53	45	63	65	66	12	11	11	10	11
38255	2011-02-22	65	69	left	high	high	62	53	70	57	47	43	44	44	54	47	75	73	63	64	67	68	69	80	65	62	83	61	55	57	45	64	66	67	12	11	11	10	11
38255	2010-08-30	65	69	left	high	high	62	53	70	57	47	43	44	44	54	47	77	75	63	64	67	68	69	80	65	62	83	61	55	57	45	64	66	67	12	11	11	10	11
38255	2010-02-22	66	69	left	high	high	66	53	65	62	47	53	44	44	59	57	77	75	63	64	67	66	69	80	65	62	83	66	63	57	60	63	66	67	1	23	59	23	23
38255	2009-08-30	66	69	left	high	high	66	53	65	62	47	53	44	44	59	57	77	75	63	64	67	66	69	80	65	62	83	68	63	57	60	63	66	67	1	23	59	23	23
38255	2008-08-30	63	67	left	high	high	55	53	65	62	47	53	44	44	57	56	65	67	63	64	67	62	69	70	65	60	72	58	56	57	55	65	62	67	1	23	57	23	23
38255	2007-08-30	61	67	left	high	high	47	48	64	57	47	49	44	44	46	54	63	67	63	64	67	58	69	66	57	43	64	55	53	57	55	60	61	67	1	23	46	23	23
38255	2007-02-22	61	67	left	high	high	47	48	64	57	47	49	44	55	46	54	63	67	63	64	67	58	69	66	57	43	64	55	53	57	55	60	61	67	1	1	46	1	1
67950	2014-07-18	65	65	right	low	high	47	32	67	57	34	45	41	28	52	60	61	65	37	60	65	37	36	69	73	46	66	67	46	59	25	68	68	66	7	7	9	10	15
67950	2014-03-07	65	65	right	low	high	47	32	67	57	34	45	41	28	52	60	61	65	37	60	65	37	36	69	73	46	66	67	46	59	25	68	68	66	7	7	9	10	15
67950	2014-02-14	65	65	right	low	high	47	32	67	57	34	45	41	28	52	60	61	65	37	60	65	37	36	69	73	46	66	67	46	59	25	68	68	66	7	7	9	10	15
67950	2013-09-20	65	65	right	low	high	47	32	67	57	34	45	41	28	52	62	61	65	37	60	65	37	36	69	71	46	66	67	46	59	25	68	68	66	7	7	9	10	15
67950	2013-02-15	65	67	right	low	high	47	32	67	57	34	45	41	28	52	62	61	65	37	60	65	37	36	71	71	46	66	67	46	59	25	68	68	66	7	7	9	10	15
67950	2012-08-31	67	67	right	low	high	47	32	67	57	34	45	41	28	52	62	61	67	40	60	64	37	72	71	71	46	66	67	46	59	25	68	68	66	7	7	9	10	15
67950	2012-02-22	65	66	right	medium	medium	47	32	65	53	34	45	41	28	49	58	61	67	42	57	64	37	68	64	71	46	63	66	46	59	25	68	66	65	7	7	9	10	15
67950	2011-08-30	65	65	right	medium	medium	47	32	65	53	34	45	41	28	49	58	61	67	42	57	64	37	68	64	71	46	63	66	46	59	25	68	66	65	7	7	9	10	15
67950	2010-08-30	65	68	right	medium	medium	47	32	65	53	34	45	41	28	49	58	62	67	49	57	63	37	65	64	68	46	63	66	46	59	25	68	66	65	7	7	9	10	15
67950	2010-02-22	62	63	right	medium	medium	47	32	63	49	34	45	41	28	45	56	62	67	49	51	63	28	65	59	68	46	61	61	57	59	54	66	61	65	9	20	45	20	20
67950	2009-08-30	60	63	right	medium	medium	47	32	62	49	34	45	41	28	45	56	67	67	49	51	63	28	65	59	62	46	61	61	57	59	54	66	59	65	9	20	45	20	20
67950	2009-02-22	57	59	right	medium	medium	37	32	62	39	34	40	41	28	35	36	67	67	49	51	63	28	65	59	55	46	61	61	37	59	52	66	57	65	13	20	35	20	20
67950	2008-08-30	57	59	right	medium	medium	37	32	62	39	34	40	41	28	35	36	67	67	49	51	63	28	65	59	55	46	61	61	37	59	52	66	57	65	13	20	35	20	20
67950	2007-08-30	59	59	right	medium	medium	37	32	62	39	34	40	41	28	35	36	67	67	49	51	63	28	65	59	55	46	61	61	37	59	52	66	57	65	13	20	35	20	20
67950	2007-02-22	59	59	right	medium	medium	37	32	62	39	34	40	41	28	35	36	67	67	49	51	63	28	65	59	55	46	61	61	37	59	52	66	57	65	13	20	35	20	20
169200	2016-02-18	86	89	right	high	medium	90	82	53	88	82	85	78	77	82	86	76	78	78	87	75	84	65	85	73	85	68	52	83	88	77	30	39	40	15	13	5	10	13
169200	2016-01-21	86	89	right	high	medium	90	82	53	88	82	85	78	77	82	86	76	78	78	87	75	84	65	85	73	85	68	52	83	88	77	30	39	40	15	13	5	10	13
169200	2015-09-21	86	89	right	high	medium	90	82	53	88	82	85	78	77	82	86	76	78	78	87	75	84	65	85	73	85	68	52	83	88	77	30	39	40	15	13	5	10	13
169200	2015-05-22	85	88	right	high	medium	80	82	53	87	81	85	76	77	82	86	77	78	79	85	79	84	65	85	75	86	63	52	83	88	75	37	39	40	15	13	5	10	13
169200	2015-04-17	84	87	right	high	medium	80	82	53	86	81	84	76	77	81	84	77	78	79	84	79	84	65	85	75	86	56	52	83	88	75	37	39	40	15	13	5	10	13
169200	2015-04-10	84	87	right	high	medium	80	82	53	86	81	84	76	77	81	84	77	78	79	84	79	84	65	83	75	86	56	52	83	88	75	37	39	40	15	13	5	10	13
169200	2015-03-06	84	87	right	high	medium	80	82	41	85	80	84	76	77	81	84	77	78	78	83	79	84	65	83	75	86	43	52	83	86	75	37	39	40	15	13	5	10	13
169200	2015-02-27	84	88	right	high	medium	80	82	41	85	80	84	76	77	81	84	77	78	78	83	79	84	65	83	75	86	43	52	83	86	75	37	39	40	15	13	5	10	13
169200	2015-02-13	84	88	right	high	medium	80	80	41	85	80	84	76	77	81	84	77	78	78	83	79	84	65	83	75	86	43	52	83	86	75	37	39	40	15	13	5	10	13
169200	2015-02-06	83	87	right	high	medium	80	78	41	85	80	84	76	77	81	84	77	78	78	80	79	82	65	83	74	83	43	52	82	85	75	37	39	40	15	13	5	10	13
169200	2015-01-09	83	87	right	high	medium	80	78	41	85	80	84	76	77	81	84	75	78	78	80	79	82	65	83	74	83	43	52	82	85	75	37	39	40	15	13	5	10	13
169200	2014-12-12	82	86	right	high	medium	79	78	41	84	80	84	76	76	81	84	75	78	78	79	79	82	65	83	74	83	42	52	82	84	75	37	39	40	15	13	5	10	13
169200	2014-11-14	82	86	right	high	medium	79	78	41	84	80	82	76	76	81	83	75	78	78	79	79	82	65	83	74	83	42	52	82	84	75	37	39	40	15	13	5	10	13
169200	2014-09-18	81	86	right	high	medium	78	78	41	82	78	82	76	76	81	83	75	78	78	78	79	82	65	83	74	83	42	52	82	80	75	37	39	40	15	13	5	10	13
169200	2014-05-09	81	86	right	high	medium	78	78	41	82	78	82	76	76	82	82	75	82	78	78	77	82	65	85	74	83	42	52	82	80	75	37	39	40	15	13	5	10	13
169200	2014-04-18	81	86	right	high	medium	78	78	41	82	78	82	76	76	82	82	75	82	78	78	77	80	65	85	74	83	42	52	82	80	75	37	39	40	15	13	5	10	13
169200	2014-01-24	81	86	right	high	medium	78	78	41	82	78	82	76	76	82	82	79	82	78	78	77	80	65	85	74	83	42	52	82	80	75	37	39	40	15	13	5	10	13
169200	2013-10-25	81	86	right	high	medium	78	78	41	82	78	82	76	76	82	82	79	82	78	78	77	80	65	85	74	83	42	52	82	80	75	37	39	40	15	13	5	10	13
169200	2013-09-20	81	86	right	high	medium	78	78	41	82	78	82	76	76	82	82	79	82	78	78	77	80	65	85	74	83	42	52	82	80	75	37	39	40	15	13	5	10	13
169200	2013-07-05	79	85	right	high	medium	78	78	35	80	78	82	76	76	80	81	74	82	75	78	75	80	65	85	73	83	39	59	77	80	75	37	38	39	15	13	5	10	13
169200	2013-06-07	79	85	right	high	medium	78	78	35	80	78	82	76	76	80	81	74	82	75	78	75	80	65	85	73	83	39	59	77	80	75	37	38	39	15	13	5	10	13
169200	2013-05-31	79	85	right	high	medium	78	78	35	80	78	82	76	76	80	81	72	82	75	79	75	80	65	85	73	83	39	59	77	80	75	37	38	39	15	13	5	10	13
169200	2013-05-10	79	85	right	high	medium	78	78	35	80	78	82	76	76	80	81	72	82	75	79	69	80	65	85	59	83	39	59	77	80	75	37	38	39	15	13	5	10	13
169200	2013-04-26	79	85	right	high	medium	78	75	35	80	78	80	76	76	80	81	72	82	75	79	69	80	65	85	59	83	39	59	77	80	75	37	38	39	15	13	5	10	13
169200	2013-04-19	78	85	right	high	low	78	75	27	80	78	79	76	76	80	80	72	82	75	77	69	80	65	85	59	83	39	59	76	78	75	37	38	39	15	13	5	10	13
169200	2013-04-12	78	86	right	high	low	78	75	27	80	78	79	76	76	80	80	72	81	75	77	69	80	65	82	59	83	39	62	76	78	67	37	38	39	15	13	5	10	13
169200	2013-04-05	78	86	right	high	low	78	75	27	80	78	79	76	76	80	80	67	81	75	77	69	80	65	82	59	83	39	62	76	78	67	37	38	39	15	13	5	10	13
169200	2013-03-22	78	86	right	high	low	77	75	27	80	78	79	76	76	82	80	67	81	74	76	69	80	65	85	59	84	39	62	74	81	67	37	45	42	15	13	5	10	13
169200	2013-03-01	78	86	right	high	low	77	75	27	80	78	77	76	76	82	79	67	81	74	76	69	80	65	85	59	84	39	62	74	81	67	37	45	42	15	13	5	10	13
169200	2013-02-15	78	86	right	high	medium	77	75	27	80	78	77	76	76	82	79	67	81	74	76	69	80	65	85	59	84	39	62	74	81	67	37	45	42	15	13	5	10	13
169200	2012-08-31	78	87	right	high	medium	77	72	27	80	74	77	76	75	82	79	67	77	74	75	69	75	65	72	59	79	39	62	72	85	65	37	45	42	15	13	5	10	13
169200	2012-02-22	76	85	right	medium	medium	74	72	35	77	74	75	76	75	82	79	67	78	74	74	69	75	64	70	58	79	35	47	70	79	65	19	21	23	15	13	5	10	13
169200	2011-08-30	75	83	right	medium	medium	74	71	35	77	69	75	76	75	82	77	67	78	74	75	73	67	64	69	54	79	35	45	70	80	63	19	21	23	15	13	5	10	13
169200	2011-02-22	71	79	right	medium	medium	72	68	27	77	66	72	72	72	79	75	62	72	66	63	59	67	61	67	63	76	35	47	69	71	63	19	21	23	15	13	5	10	13
169200	2010-08-30	70	77	right	medium	medium	69	68	62	67	61	71	70	71	73	74	69	69	66	63	59	67	61	67	63	76	55	47	67	71	63	19	21	23	15	13	5	10	13
169200	2010-02-22	62	75	right	medium	medium	59	66	52	62	61	64	70	58	57	62	64	69	66	62	59	60	61	62	52	56	35	62	57	71	59	23	23	23	9	23	57	23	23
169200	2009-08-30	62	75	right	medium	medium	59	66	52	57	61	64	70	58	52	62	64	69	66	62	59	60	61	62	52	56	35	62	57	71	59	23	23	23	9	23	52	23	23
169200	2007-02-22	62	75	right	medium	medium	59	66	52	57	61	64	70	58	52	62	64	69	66	62	59	60	61	62	52	56	35	62	57	71	59	23	23	23	9	23	52	23	23
67957	2014-09-18	64	64	left	medium	high	54	42	66	63	43	54	43	46	60	58	44	43	67	62	67	55	55	77	58	57	72	69	54	63	31	62	64	65	15	11	15	7	14
67957	2012-02-22	64	64	left	medium	high	54	42	66	63	43	54	43	46	60	58	44	43	67	62	67	55	55	77	58	57	72	69	54	63	31	62	64	65	15	11	15	7	14
67957	2011-08-30	64	64	left	medium	high	54	42	66	63	43	54	43	46	60	58	44	50	67	62	67	55	55	77	58	57	72	69	54	63	31	62	64	65	15	11	15	7	14
67957	2010-08-30	63	66	left	medium	high	54	42	65	61	43	54	43	46	59	55	53	62	65	62	63	55	59	77	65	47	72	67	51	62	31	59	63	64	15	11	15	7	14
67957	2009-08-30	60	64	left	medium	high	47	42	65	57	43	42	43	46	52	47	52	62	65	59	63	55	59	77	63	47	72	65	62	62	59	55	62	64	7	25	52	25	25
67957	2008-08-30	59	62	left	medium	high	47	42	65	57	43	42	43	46	52	47	52	62	65	59	63	55	59	77	59	47	72	65	62	62	59	55	62	64	13	25	52	25	25
67957	2007-08-30	55	57	left	medium	high	52	42	58	55	43	47	43	46	51	47	49	59	65	52	63	51	59	73	57	47	59	62	58	62	50	48	54	64	13	25	51	25	25
67957	2007-02-22	55	57	left	medium	high	52	42	58	55	43	47	43	46	51	47	49	59	65	52	63	51	59	73	57	47	59	62	58	62	50	48	54	64	13	25	51	25	25
38320	2016-05-12	66	66	right	high	low	44	69	77	52	64	61	33	40	47	64	57	50	45	59	37	71	66	69	80	65	64	20	65	53	64	13	16	14	7	8	6	7	10
38320	2016-05-05	66	66	right	high	low	44	69	77	52	64	61	33	40	47	64	57	50	45	59	37	71	66	69	80	65	64	20	65	53	64	13	16	14	7	8	6	7	10
38320	2016-03-10	66	66	right	high	low	44	69	77	52	64	61	33	40	47	64	57	50	45	59	37	71	66	69	80	65	64	20	65	53	64	13	16	14	7	8	6	7	10
38320	2015-09-21	66	66	right	high	low	44	69	77	52	64	61	33	40	47	64	59	56	46	59	48	71	63	69	80	65	64	20	65	53	64	13	16	14	7	8	6	7	10
38320	2015-02-20	68	68	right	medium	low	45	70	78	53	65	62	34	41	48	65	62	61	68	60	33	72	70	71	82	66	65	21	66	54	65	25	25	25	6	7	5	6	9
38320	2013-09-20	68	68	right	medium	low	45	70	78	53	65	62	34	41	48	65	62	61	68	60	33	72	70	71	82	66	65	21	66	54	65	25	25	25	6	7	5	6	9
38320	2013-08-23	68	68	right	medium	low	45	70	78	53	65	62	34	41	48	65	62	61	46	60	33	72	70	71	82	66	65	21	66	54	65	11	17	15	6	7	5	6	9
38320	2013-08-16	68	68	right	medium	low	35	70	78	53	65	62	34	41	28	65	62	58	46	60	33	72	70	71	82	66	65	21	66	54	65	11	17	15	6	7	5	6	9
38320	2013-06-21	68	68	right	medium	low	35	70	78	53	65	62	34	41	28	65	62	61	46	60	33	72	68	71	80	66	65	21	66	54	65	11	17	15	6	7	5	6	9
38320	2013-04-26	70	70	right	medium	low	35	74	78	53	65	62	34	41	28	65	69	71	46	60	33	72	68	71	90	66	65	21	74	54	65	11	17	15	6	7	5	6	9
38320	2013-02-15	70	70	right	medium	low	35	74	78	53	65	62	34	41	28	65	69	71	46	60	33	72	68	71	90	66	65	21	74	54	65	11	17	15	6	7	5	6	9
38320	2012-08-31	68	69	right	medium	low	35	74	78	53	65	62	34	41	28	61	63	64	37	60	33	67	64	57	85	63	65	21	67	54	65	11	17	15	6	7	5	6	9
38320	2012-02-22	63	66	right	medium	low	35	64	78	53	56	51	34	41	28	54	51	57	37	60	33	67	64	57	88	57	65	21	67	54	65	11	17	15	6	7	5	6	9
38320	2009-02-22	63	66	right	medium	low	35	64	78	53	56	51	34	41	28	54	51	57	37	60	33	67	64	57	88	57	65	21	67	54	65	11	17	15	6	7	5	6	9
38320	2008-08-30	63	60	right	medium	low	35	64	78	53	56	51	34	41	28	54	51	57	37	60	33	67	64	57	88	57	65	21	67	54	65	11	17	15	6	7	5	6	9
38320	2007-02-22	63	60	right	medium	low	35	64	78	53	56	51	34	41	28	54	51	57	37	60	33	67	64	57	88	57	65	21	67	54	65	11	17	15	6	7	5	6	9
37981	2012-02-22	67	67	right	low	low	65	66	71	69	72	66	63	70	66	70	43	43	52	63	59	71	58	34	75	72	48	56	68	71	67	33	43	39	10	10	7	6	5
37981	2011-08-30	67	67	right	low	low	65	66	71	69	72	66	63	70	66	70	43	47	52	63	59	71	58	41	75	72	48	56	68	71	67	33	43	39	10	10	7	6	5
37981	2010-08-30	69	71	right	low	low	66	68	72	71	73	67	63	71	68	71	53	61	56	63	71	72	60	58	73	74	48	56	68	71	67	33	43	39	10	10	7	6	5
37981	2009-08-30	69	71	right	low	low	67	68	72	69	73	68	63	69	68	73	53	61	56	63	71	70	60	56	73	74	48	64	68	71	66	38	48	39	6	23	68	23	23
37981	2008-08-30	67	69	right	low	low	63	56	70	69	73	68	63	61	64	73	53	61	56	63	71	68	60	58	71	66	52	64	66	71	63	41	53	39	6	23	64	23	23
37981	2007-08-30	68	69	right	low	low	66	56	73	69	73	71	63	63	67	76	53	63	56	66	71	66	60	66	73	66	62	64	66	71	63	51	58	39	6	23	67	23	23
37981	2007-02-22	69	78	right	low	low	69	54	75	70	73	69	63	66	69	73	64	69	56	72	71	66	60	74	75	70	67	64	66	71	66	57	58	39	6	14	69	13	8
38792	2014-12-05	61	61	right	low	low	46	66	62	56	63	57	61	60	36	63	53	45	64	61	66	58	51	31	47	46	21	24	73	54	66	25	25	25	12	8	11	15	8
38792	2014-09-18	63	63	right	low	low	46	62	65	56	64	57	61	62	36	63	56	50	67	66	68	61	54	46	57	59	21	24	73	54	71	25	25	25	12	8	11	15	8
38792	2012-02-22	63	63	right	low	low	46	62	65	56	64	57	61	62	36	63	56	50	67	66	68	61	54	46	57	59	21	24	73	54	71	25	25	25	12	8	11	15	8
38792	2011-08-30	68	68	right	low	low	46	76	65	56	72	65	61	62	43	67	56	50	69	61	70	65	66	45	63	59	21	24	82	63	74	25	25	25	12	8	11	15	8
38792	2011-02-22	66	69	right	low	low	46	78	59	56	73	65	61	62	43	67	65	67	69	61	48	65	63	66	42	59	21	24	83	63	74	25	25	25	12	8	11	15	8
38792	2010-08-30	66	69	right	low	low	46	78	59	56	73	65	61	62	43	67	65	67	69	61	48	65	63	66	42	59	21	24	73	63	74	25	25	25	12	8	11	15	8
38792	2010-02-22	67	70	right	low	low	46	78	59	53	73	65	61	62	43	67	65	67	69	83	48	65	63	66	42	59	21	58	76	63	79	25	25	25	13	25	43	25	25
38792	2009-08-30	66	70	right	low	low	46	77	59	53	73	65	61	62	43	67	65	62	69	83	48	62	63	56	42	59	21	58	76	63	79	25	25	25	13	25	43	25	25
38792	2009-02-22	67	73	right	low	low	46	81	64	53	73	65	61	62	43	67	65	62	69	83	48	62	63	56	42	59	21	58	76	63	79	25	25	25	13	25	43	25	25
38792	2008-08-30	68	71	right	low	low	51	83	64	56	73	65	61	62	47	67	67	62	69	86	48	62	63	56	42	59	31	58	76	63	77	24	27	25	13	25	47	25	25
38792	2007-08-30	69	71	right	low	low	51	83	64	56	73	65	61	62	47	67	67	62	69	86	48	62	63	56	42	59	31	58	76	63	77	24	27	25	13	25	47	25	25
38792	2007-02-22	73	81	right	low	low	57	77	67	56	73	69	61	66	60	70	70	70	69	74	48	73	63	69	75	67	74	58	76	63	66	25	35	25	13	7	60	9	6
130027	2016-04-14	70	71	right	medium	medium	57	49	69	70	57	67	49	64	65	72	63	66	61	69	66	81	81	73	86	69	82	68	66	66	55	64	69	67	7	12	13	8	9
130027	2016-03-31	70	71	right	medium	medium	57	49	69	70	57	67	49	64	65	72	63	66	61	69	66	81	81	73	86	69	82	68	66	66	55	64	69	67	7	12	13	8	9
130027	2015-10-30	68	69	right	medium	medium	57	49	69	70	57	67	49	64	65	72	63	66	61	69	66	81	81	73	86	69	82	68	66	66	55	64	69	67	7	12	13	8	9
130027	2015-10-02	70	72	right	medium	medium	57	49	69	70	57	67	49	64	65	72	63	66	61	69	66	81	81	73	86	69	82	68	66	66	55	64	69	67	7	12	13	8	9
130027	2015-09-21	70	72	right	medium	medium	57	49	69	70	57	67	49	64	65	72	63	66	61	69	66	81	81	73	86	69	82	68	66	66	55	64	69	67	7	12	13	8	9
130027	2015-04-17	69	71	right	medium	medium	56	48	68	69	56	66	48	63	64	71	63	68	58	68	66	80	78	73	86	68	81	67	65	65	54	63	68	66	6	11	12	7	8
130027	2014-09-18	70	72	right	medium	medium	56	48	68	71	56	68	48	63	66	73	63	68	58	73	66	80	80	78	89	68	86	73	65	65	54	65	71	67	6	11	12	7	8
130027	2014-01-31	71	74	right	medium	medium	56	48	68	69	56	66	48	63	66	69	63	68	58	68	66	80	78	78	89	68	86	71	57	61	54	65	71	67	6	11	12	7	8
130027	2014-01-03	71	74	right	medium	medium	56	48	68	69	56	66	48	63	66	69	63	68	58	68	66	80	78	78	89	68	86	71	57	61	54	65	71	67	6	11	12	7	8
130027	2013-10-11	70	74	right	medium	medium	56	48	68	69	56	66	48	63	66	69	63	66	58	66	64	80	78	74	89	68	86	68	57	61	54	65	71	67	6	11	12	7	8
130027	2013-09-20	70	74	right	medium	medium	56	48	68	69	56	66	48	63	66	69	63	66	58	66	64	80	78	74	89	68	86	68	57	61	54	65	71	67	6	11	12	7	8
130027	2013-05-31	70	74	right	medium	medium	56	48	68	69	56	66	48	63	66	69	63	66	58	66	64	80	77	74	89	68	86	68	57	61	54	65	71	67	6	11	12	7	8
130027	2013-02-22	70	74	right	medium	medium	56	48	68	69	56	66	48	63	66	69	63	66	58	66	64	80	77	74	89	68	86	68	57	61	54	65	71	67	6	11	12	7	8
130027	2013-02-15	70	74	right	medium	medium	56	48	67	68	56	66	48	63	64	69	70	66	64	69	64	80	77	74	89	68	86	68	57	61	54	65	69	66	6	11	12	7	8
130027	2012-08-31	68	72	right	high	medium	56	58	68	66	48	66	48	63	63	68	71	68	64	67	63	80	74	74	89	68	86	66	57	61	54	58	66	64	6	11	12	7	8
130027	2012-02-22	66	73	right	high	medium	56	58	69	66	48	66	48	63	63	68	71	68	64	64	63	80	74	74	89	68	86	58	57	62	54	53	66	64	6	11	12	7	8
130027	2011-08-30	67	75	right	high	medium	56	58	69	69	48	63	48	63	65	68	71	68	64	64	54	77	74	74	84	68	78	64	57	61	54	61	67	64	6	11	12	7	8
130027	2011-02-22	66	74	right	high	medium	56	48	69	69	48	63	48	63	65	68	68	68	63	64	81	78	67	74	84	68	74	57	56	61	54	58	64	61	6	11	12	7	8
130027	2010-08-30	65	74	right	high	medium	56	48	68	66	48	63	46	61	64	66	66	68	61	63	81	74	66	73	83	66	73	54	56	60	54	58	62	61	6	11	12	7	8
130027	2009-08-30	64	76	right	high	medium	54	45	68	66	48	61	46	48	61	66	66	68	61	58	81	71	66	73	83	58	69	54	56	60	53	58	64	61	7	22	61	22	22
130027	2009-02-22	55	72	right	high	medium	51	45	57	53	48	53	46	48	52	58	66	68	61	58	81	67	66	66	68	50	69	34	35	60	39	54	52	61	7	22	52	22	22
130027	2007-02-22	55	72	right	high	medium	51	45	57	53	48	53	46	48	52	58	66	68	61	58	81	67	66	66	68	50	69	34	35	60	39	54	52	61	7	22	52	22	22
38290	2016-05-12	73	73	right	medium	high	62	42	70	75	48	60	50	61	76	73	64	67	63	72	60	76	78	90	82	55	77	74	64	68	48	60	71	70	6	10	6	9	6
38290	2016-04-21	71	71	right	medium	high	62	42	70	75	48	60	50	61	76	73	64	67	63	72	60	76	78	90	82	55	77	74	64	68	48	60	71	70	6	10	6	9	6
38290	2015-12-10	71	71	right	medium	high	62	42	70	75	48	61	50	61	71	73	64	67	63	74	60	76	78	90	82	55	78	76	66	68	48	62	73	70	6	10	6	9	6
38290	2015-11-06	71	71	right	medium	high	62	42	70	75	48	61	50	61	71	73	64	67	63	74	60	76	78	90	82	55	78	76	66	68	48	62	73	70	6	10	6	9	6
38290	2015-09-21	71	71	right	medium	high	62	42	70	75	48	61	50	61	71	73	64	67	63	74	60	76	78	90	82	55	78	76	66	68	48	62	73	70	6	10	6	9	6
38290	2014-09-18	71	71	right	medium	high	61	41	68	74	47	59	49	60	70	72	74	75	68	77	60	75	78	90	83	54	79	75	68	67	47	58	72	69	5	9	5	8	5
38290	2014-05-09	71	71	right	medium	high	61	41	68	74	47	59	49	60	70	72	74	78	68	77	60	75	76	87	83	54	79	75	68	67	47	58	72	69	5	9	5	8	5
38290	2014-04-25	70	70	right	medium	high	61	41	68	74	47	59	49	60	70	72	74	78	68	76	60	75	76	87	83	54	79	75	68	67	47	58	70	67	5	9	5	8	5
38290	2014-02-21	70	70	right	medium	high	61	41	68	74	47	59	49	60	70	72	75	74	68	76	60	75	76	87	83	54	79	75	68	67	47	58	70	67	5	9	5	8	5
38290	2013-12-13	70	71	right	medium	high	61	41	68	74	47	59	49	60	70	72	75	74	68	76	60	75	76	87	83	54	79	75	68	67	47	72	70	67	5	9	5	8	5
38290	2013-09-20	70	71	right	medium	high	56	41	68	72	47	59	49	60	69	70	75	74	68	74	60	75	76	87	80	59	76	74	68	67	47	64	67	62	5	9	5	8	5
38290	2013-05-31	70	71	right	medium	high	64	41	62	66	53	49	54	60	65	65	75	74	68	71	60	75	75	87	80	57	76	74	53	64	47	64	68	63	5	9	5	8	5
38290	2013-03-28	70	71	right	medium	high	64	41	62	66	53	49	54	60	65	65	75	74	68	71	60	75	75	87	80	57	76	74	53	64	47	64	68	63	5	9	5	8	5
38290	2013-03-22	70	71	right	medium	high	64	41	62	66	53	49	54	60	65	65	75	74	68	71	60	75	75	87	80	57	76	74	53	64	47	64	68	63	5	9	5	8	5
38290	2013-02-15	70	73	right	medium	high	64	41	62	66	53	49	54	60	65	65	75	74	68	71	60	75	75	87	80	57	76	74	53	64	47	64	68	63	5	9	5	8	5
38290	2012-08-31	70	73	right	medium	high	64	41	62	66	53	49	54	60	65	65	75	75	68	71	56	75	73	87	80	57	76	74	53	64	47	64	68	63	5	9	5	8	5
38290	2012-02-22	69	71	right	medium	high	64	46	67	68	53	58	60	63	65	67	66	71	60	69	58	71	73	87	80	63	67	73	53	63	47	64	68	59	5	9	5	8	5
38290	2011-08-30	67	68	right	medium	high	64	46	67	68	53	58	60	63	65	66	66	71	60	63	51	71	69	83	81	63	67	73	53	63	47	58	62	59	5	9	5	8	5
38290	2011-02-22	66	68	right	medium	high	64	46	67	68	53	61	60	63	65	66	61	66	60	63	71	71	62	75	73	58	58	68	63	68	47	58	62	59	5	9	5	8	5
38290	2010-08-30	66	68	right	medium	high	64	46	67	68	53	61	60	63	65	66	61	66	60	63	71	71	62	75	73	58	58	68	63	68	47	58	62	59	5	9	5	8	5
38290	2010-02-22	65	68	right	medium	high	64	46	66	68	53	58	60	60	63	65	60	66	60	60	71	70	62	75	73	56	55	66	64	68	62	58	62	59	11	22	63	22	22
38290	2009-08-30	64	68	right	medium	high	64	46	66	67	53	58	60	60	63	65	60	66	60	60	71	74	62	75	73	56	55	66	62	68	58	57	61	59	11	22	63	22	22
38290	2008-08-30	63	68	right	medium	high	60	46	66	66	53	58	60	60	61	63	58	66	60	56	71	67	62	75	73	56	53	66	60	68	58	57	61	59	11	22	61	22	22
38290	2007-08-30	64	66	right	medium	high	57	46	65	63	53	57	60	60	58	62	58	66	60	56	71	67	62	75	73	56	65	65	56	68	57	57	61	59	11	22	58	22	22
38290	2007-02-22	62	69	right	medium	high	57	36	56	63	53	55	60	57	55	57	59	62	60	54	71	57	62	70	72	50	62	65	56	68	57	59	59	59	11	14	55	15	7
94308	2016-02-04	67	68	right	medium	high	62	52	58	69	58	60	55	42	67	71	72	72	75	63	84	71	71	71	70	65	77	67	46	63	48	59	63	59	10	13	15	14	13
94308	2015-12-24	67	68	right	medium	high	62	52	58	69	58	60	55	42	67	71	72	72	75	63	84	71	71	71	70	65	77	67	46	63	48	59	63	59	10	13	15	14	13
94308	2015-11-06	67	69	right	medium	high	62	52	58	69	58	60	55	42	67	71	72	72	75	63	84	71	71	71	70	65	77	67	46	63	48	59	63	59	10	13	15	14	13
94308	2015-09-21	67	70	right	medium	high	62	52	58	69	58	60	55	42	67	71	72	72	75	63	84	71	71	71	70	65	77	67	46	63	48	59	63	59	10	13	15	14	13
94308	2015-05-08	64	67	right	medium	high	61	51	57	68	57	59	54	41	66	70	72	72	75	62	84	70	71	71	70	64	76	66	45	62	47	58	62	58	9	12	14	13	12
94308	2015-04-10	64	67	right	medium	high	61	51	57	68	57	59	54	41	66	70	72	72	75	62	84	76	71	71	70	67	76	66	45	62	47	64	62	64	9	12	14	13	12
94308	2015-03-20	64	67	right	medium	high	61	51	57	68	57	59	54	41	66	70	72	72	75	62	84	76	71	71	70	67	76	66	45	62	47	64	62	64	9	12	14	13	12
94308	2015-02-20	65	68	right	medium	high	61	51	57	68	57	59	54	41	66	70	72	72	75	62	84	76	71	71	70	67	76	66	56	62	47	63	61	64	9	12	14	13	12
94308	2014-12-19	62	65	right	medium	high	51	45	55	64	57	56	54	41	61	69	72	72	75	60	84	76	71	71	70	65	75	64	55	61	44	58	60	63	9	12	14	13	12
94308	2014-11-14	62	65	right	medium	high	51	45	55	64	57	56	54	41	61	69	72	72	75	60	84	76	71	71	70	65	75	64	55	61	44	58	60	63	9	12	14	13	12
94308	2014-10-24	62	65	right	medium	high	51	45	55	64	57	56	54	41	61	69	72	72	75	60	84	76	71	71	70	65	75	64	55	61	44	58	60	63	9	12	14	13	12
94308	2014-09-18	61	65	right	medium	high	51	45	55	63	57	50	54	41	60	69	72	72	75	60	84	76	71	71	70	68	75	61	55	61	44	58	60	63	9	12	14	13	12
94308	2014-09-12	61	65	right	medium	high	51	45	55	63	57	50	54	41	60	69	72	72	75	60	84	76	71	71	70	68	75	61	55	61	44	58	60	63	9	12	14	13	12
94308	2014-08-22	61	68	right	medium	high	51	45	55	63	57	50	54	41	60	69	72	72	75	60	84	76	71	71	70	68	75	61	55	58	44	58	60	63	9	12	14	13	12
94308	2014-02-14	60	68	right	medium	high	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	60	63	9	12	14	13	12
94308	2013-09-20	60	68	right	medium	high	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	60	63	9	12	14	13	12
94308	2013-07-12	60	65	right	medium	high	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	60	63	9	12	14	13	12
94308	2013-06-07	60	65	right	medium	high	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	60	63	9	12	14	13	12
94308	2013-05-24	60	65	right	medium	high	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	56	44	9	12	14	13	12
94308	2013-05-03	62	71	right	medium	high	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	56	44	9	12	14	13	12
94308	2013-04-19	62	71	right	high	medium	51	45	55	61	57	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	56	44	9	12	14	13	12
94308	2013-02-15	62	71	right	high	medium	51	45	55	61	55	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	56	44	9	12	14	13	12
94308	2012-08-31	62	71	right	high	medium	51	45	55	61	55	50	54	41	60	69	72	72	75	57	84	76	71	71	70	68	75	61	53	58	44	58	56	44	9	12	14	13	12
94308	2012-02-22	63	71	right	high	medium	51	45	55	66	55	50	54	41	60	69	72	72	75	60	84	76	71	71	64	68	75	61	59	63	44	58	56	44	9	12	14	13	12
94308	2011-08-30	63	71	right	high	medium	51	45	55	66	55	50	54	41	60	69	72	72	75	60	84	76	71	71	64	68	75	61	59	63	44	58	56	44	9	12	14	13	12
94308	2009-08-30	63	71	right	high	medium	51	45	55	66	55	50	54	41	60	69	72	72	75	60	84	76	71	71	64	68	75	61	59	63	44	58	56	44	9	12	14	13	12
94308	2008-08-30	58	71	right	high	medium	51	30	55	58	55	53	54	41	53	56	68	66	75	64	84	76	71	71	64	68	75	49	45	63	49	56	57	44	9	12	53	13	12
94308	2007-08-30	57	67	right	high	medium	48	30	55	56	55	51	54	41	53	56	68	66	75	60	84	26	71	66	64	68	75	49	45	63	49	51	56	44	9	12	53	13	12
94308	2007-02-22	57	67	right	high	medium	48	30	55	56	55	51	54	41	53	56	68	66	75	60	84	26	71	66	64	68	75	49	45	63	49	51	56	44	9	12	53	13	12
37983	2012-02-22	67	67	left	high	high	65	64	69	70	60	59	57	64	65	64	45	65	42	65	45	72	53	82	77	67	73	64	67	72	64	52	65	62	9	9	8	8	10
37983	2011-08-30	65	65	left	medium	medium	65	65	68	69	60	60	62	64	64	65	46	65	41	65	45	72	53	90	80	67	76	62	67	77	64	51	67	63	9	9	8	8	10
37983	2010-08-30	65	72	left	medium	medium	65	65	68	69	60	60	62	64	64	65	53	68	48	65	73	72	64	78	74	67	76	62	67	77	64	51	67	63	9	9	8	8	10
37983	2010-02-22	67	72	left	medium	medium	67	65	70	73	60	60	62	64	65	65	53	70	48	67	73	72	64	82	75	67	76	79	70	77	72	51	67	63	2	25	65	25	25
37983	2009-08-30	67	72	left	medium	medium	67	65	70	73	60	60	62	64	65	65	53	70	48	67	73	72	64	82	75	67	76	79	70	77	72	51	67	63	2	25	65	25	25
37983	2009-02-22	70	76	left	medium	medium	71	69	70	73	60	62	62	66	66	67	68	74	48	70	73	73	64	85	77	69	78	79	70	77	71	58	67	63	11	25	66	25	25
37983	2008-08-30	70	72	left	medium	medium	71	69	70	73	60	62	62	66	66	67	68	74	48	70	73	73	64	85	77	69	78	79	70	77	71	58	67	63	11	25	66	25	25
37983	2007-08-30	71	72	left	medium	medium	71	69	70	73	60	62	62	66	66	67	68	74	48	70	73	73	64	85	77	69	78	79	70	77	71	58	67	63	11	25	66	25	25
37983	2007-02-22	74	74	left	medium	medium	71	70	71	75	60	68	62	75	66	73	68	75	48	71	73	77	64	85	76	72	76	79	70	77	75	58	68	63	11	9	66	14	9
67898	2016-04-14	69	69	right	high	medium	55	56	66	71	55	63	58	65	66	72	69	65	67	67	73	75	76	73	68	67	76	74	73	71	55	58	68	67	10	14	13	12	10
67898	2016-04-07	69	69	right	high	medium	55	56	66	71	55	63	58	65	66	72	69	65	67	67	73	75	76	73	68	67	76	74	73	71	55	58	68	67	10	14	13	12	10
67898	2016-02-11	70	70	right	high	medium	55	56	66	71	55	63	58	65	66	72	69	65	67	68	74	75	78	75	70	67	76	74	73	71	55	58	68	67	10	14	13	12	10
67898	2015-09-21	70	70	right	high	medium	55	56	66	71	55	65	58	65	66	72	71	66	68	72	75	75	81	77	72	67	76	74	73	71	55	59	69	68	10	14	13	12	10
67898	2015-03-13	70	70	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	69	68	71	75	74	78	77	72	66	75	73	72	70	54	58	68	67	9	13	12	11	9
67898	2014-12-19	70	70	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	69	68	71	75	68	78	77	72	63	75	73	72	70	54	58	68	67	9	13	12	11	9
67898	2014-09-18	70	70	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	69	68	71	75	68	78	77	72	63	75	73	72	70	54	58	68	67	9	13	12	11	9
67898	2014-04-04	70	70	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	69	68	71	75	68	76	77	72	63	75	73	72	70	54	58	68	67	9	13	12	11	9
67898	2014-02-21	69	69	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	69	68	70	75	68	76	77	72	63	75	69	72	67	54	53	66	65	9	13	12	11	9
67898	2013-11-29	69	69	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	69	68	70	75	68	76	77	72	63	75	69	72	67	54	63	66	65	9	13	12	11	9
67898	2013-09-20	69	69	right	high	medium	54	57	65	70	54	64	57	64	65	73	71	70	68	70	75	68	76	77	72	63	75	69	72	67	54	63	66	65	9	13	12	11	9
67898	2013-06-07	68	68	right	high	medium	54	57	59	70	54	62	57	64	65	70	71	71	68	70	75	68	75	77	72	63	75	69	68	67	54	58	66	65	9	13	12	11	9
67898	2013-05-31	68	69	right	high	medium	54	57	59	70	54	62	57	64	65	70	71	71	68	70	75	68	75	77	72	63	75	69	68	67	54	58	66	65	9	13	12	11	9
67898	2013-05-24	68	69	right	high	medium	54	57	59	70	54	62	57	64	65	70	71	71	68	70	75	68	75	77	72	63	75	69	68	67	54	58	66	65	9	13	12	11	9
67898	2013-05-17	69	69	right	high	medium	54	57	59	70	54	64	57	64	65	73	71	71	68	70	75	68	75	77	72	63	75	69	68	69	54	58	66	65	9	13	12	11	9
67898	2013-03-28	69	69	right	high	medium	54	57	59	70	54	64	57	64	65	73	71	71	68	70	75	68	75	77	72	63	75	69	68	69	54	58	66	65	9	13	12	11	9
67898	2013-03-15	69	69	right	high	medium	54	57	59	70	54	64	57	64	65	73	71	71	68	70	75	68	75	77	72	63	75	69	68	69	54	58	66	65	9	13	12	11	9
67898	2013-02-15	69	69	right	high	medium	54	57	59	70	54	64	57	64	65	73	71	71	68	70	75	68	75	77	72	63	75	69	68	69	54	58	66	65	9	13	12	11	9
67898	2012-08-31	68	69	right	medium	medium	59	57	59	69	61	64	61	64	65	72	72	72	68	70	74	68	73	76	70	63	72	69	68	69	54	58	66	63	9	13	12	11	9
67898	2011-08-30	68	71	right	medium	medium	64	53	59	71	61	63	61	64	66	72	70	69	75	69	70	68	69	76	67	66	72	66	66	72	54	58	61	63	9	13	12	11	9
67898	2010-08-30	66	68	right	medium	medium	64	53	59	68	61	63	61	64	66	68	68	69	63	67	67	68	65	73	61	66	72	66	66	71	54	58	61	63	9	13	12	11	9
67898	2009-08-30	66	68	right	medium	medium	64	53	59	68	61	63	61	64	66	68	68	69	63	67	67	68	65	73	61	66	72	72	66	71	65	58	61	63	9	25	66	25	25
67898	2008-08-30	66	68	right	medium	medium	64	53	59	66	61	63	61	62	63	68	68	69	63	64	67	67	65	73	56	61	69	68	64	71	63	48	59	63	15	25	63	25	25
67898	2007-08-30	61	63	right	medium	medium	53	53	59	60	61	58	61	56	56	63	65	68	63	61	67	64	65	72	56	55	69	63	60	71	62	49	53	63	15	25	56	25	25
67898	2007-02-22	61	63	right	medium	medium	53	53	59	60	61	58	61	56	56	63	65	68	63	61	67	64	65	72	56	55	69	63	60	71	62	49	53	63	15	25	56	25	25
36393	2008-08-30	63	65	right	\N	\N	63	54	53	68	\N	64	\N	62	66	63	62	60	\N	61	\N	65	\N	63	56	63	51	64	60	\N	56	48	53	\N	10	21	66	21	21
36393	2008-02-22	61	65	right	\N	\N	62	54	44	66	\N	64	\N	62	60	63	62	60	\N	61	\N	60	\N	63	56	63	51	64	60	\N	56	42	44	\N	10	21	60	21	21
36393	2007-08-30	61	65	right	\N	\N	62	54	44	66	\N	64	\N	62	60	63	62	60	\N	61	\N	60	\N	63	56	63	51	64	60	\N	56	42	44	\N	10	21	60	21	21
36393	2007-02-22	61	65	right	\N	\N	62	54	44	66	\N	64	\N	56	60	63	62	60	\N	61	\N	60	\N	63	56	63	51	64	60	\N	56	42	44	\N	10	9	60	10	6
148325	2015-10-30	67	67	right	medium	medium	18	13	17	29	12	15	13	15	28	24	33	23	16	63	12	36	31	23	83	19	28	22	12	37	25	19	16	13	70	63	62	69	70
148325	2015-09-21	67	68	right	medium	medium	18	13	17	29	12	15	13	15	28	24	33	23	16	63	12	36	31	23	83	19	28	22	12	37	25	19	16	13	70	63	62	69	70
148325	2014-01-03	67	68	right	medium	medium	18	13	17	29	12	15	13	15	28	24	33	23	16	63	12	36	31	23	83	19	28	22	12	37	25	19	16	13	70	63	62	69	70
148325	2013-09-20	67	69	right	medium	medium	18	13	17	29	12	15	13	15	28	24	33	23	16	63	12	36	31	23	83	19	28	22	12	37	25	19	16	13	70	63	62	69	70
148325	2013-02-15	67	69	right	medium	medium	17	12	16	29	11	14	12	14	28	24	35	42	35	65	20	36	55	37	85	18	40	25	11	35	25	18	15	12	70	63	62	69	70
148325	2012-08-31	65	67	right	medium	medium	17	12	16	29	11	14	12	14	28	24	35	42	35	60	20	36	55	37	93	18	40	25	11	35	25	18	15	12	67	65	60	66	65
148325	2011-08-30	65	69	right	medium	medium	17	12	16	29	11	14	12	14	28	24	35	42	35	60	26	36	55	37	93	18	40	25	11	35	25	18	15	12	64	66	65	66	64
148325	2011-02-22	64	67	right	medium	medium	17	12	16	29	11	14	12	14	28	24	35	42	35	55	91	45	55	37	93	18	40	25	11	35	25	18	15	12	64	66	65	66	64
148325	2010-08-30	63	67	right	medium	medium	17	12	16	29	11	14	12	14	28	24	35	42	55	55	91	75	55	37	94	18	40	25	11	35	25	18	15	2	64	66	60	64	62
148325	2010-02-22	63	67	right	medium	medium	21	21	21	29	11	21	12	14	60	24	35	42	55	55	91	49	55	37	94	21	40	37	20	35	37	21	21	2	64	66	60	64	62
148325	2009-08-30	63	67	right	medium	medium	21	21	21	29	11	21	12	14	60	24	35	42	55	55	91	75	55	37	94	21	40	37	20	35	37	21	21	2	64	66	60	64	62
148325	2009-02-22	47	62	right	medium	medium	21	21	21	29	11	21	12	14	41	24	35	42	55	45	91	75	55	37	94	21	29	37	20	35	37	21	21	2	56	52	41	45	37
148325	2008-08-30	47	62	right	medium	medium	21	21	21	29	11	21	12	14	41	24	35	42	55	45	91	75	55	37	94	21	29	37	20	35	37	21	21	2	56	52	41	45	37
148325	2007-02-22	47	62	right	medium	medium	21	21	21	29	11	21	12	14	41	24	35	42	55	45	91	75	55	37	94	21	29	37	20	35	37	21	21	2	56	52	41	45	37
36845	2010-08-30	65	67	right	\N	\N	39	34	66	47	33	37	48	48	45	47	57	54	55	52	78	59	64	70	76	31	69	61	34	60	53	68	66	66	11	11	9	15	8
36845	2009-08-30	66	67	right	\N	\N	39	34	66	54	33	37	48	48	47	54	62	64	55	59	78	59	64	70	76	31	69	58	55	60	60	68	66	66	9	23	47	23	23
36845	2009-02-22	64	66	right	\N	\N	39	24	60	54	33	37	48	48	47	44	62	64	55	59	78	59	64	70	67	31	69	58	68	60	55	68	68	66	9	23	47	23	23
36845	2008-08-30	65	65	right	\N	\N	39	24	60	55	33	37	48	48	47	44	62	64	55	59	78	59	64	70	69	31	69	58	68	60	55	69	68	66	9	23	47	23	23
36845	2007-08-30	63	64	right	\N	\N	39	34	54	65	33	37	48	48	57	44	62	64	55	59	78	39	64	70	69	61	69	58	54	60	55	69	64	66	9	23	57	23	23
36845	2007-02-22	63	62	right	\N	\N	39	34	54	65	33	37	48	55	57	44	62	64	55	59	78	39	64	70	69	61	69	58	54	60	55	69	64	66	9	9	57	10	5
37861	2014-09-18	65	65	left	high	medium	67	56	53	62	54	66	47	53	54	67	80	81	73	68	78	62	77	72	67	60	69	63	53	52	52	58	62	64	10	14	6	8	15
37861	2013-05-31	65	65	left	high	medium	67	56	53	62	54	66	47	53	54	67	80	81	73	68	78	62	77	72	67	60	69	63	53	52	52	58	62	64	10	14	6	8	15
37861	2013-03-28	65	65	left	high	medium	67	56	53	62	54	66	47	53	54	67	80	81	73	68	78	62	77	72	67	60	69	63	53	52	52	58	62	64	10	14	6	8	15
37861	2013-02-22	65	65	left	high	medium	67	56	53	62	54	66	47	53	54	67	80	81	73	68	78	62	77	72	67	60	69	63	53	52	52	58	62	64	10	14	6	8	15
37861	2013-02-15	64	67	left	high	medium	67	56	53	62	54	66	47	53	54	67	78	80	71	68	68	62	72	72	63	60	69	63	53	52	52	57	62	64	10	14	6	8	15
37861	2012-08-31	64	67	left	high	medium	67	56	53	62	54	66	47	53	54	67	78	79	71	68	66	62	70	72	62	60	69	63	53	52	52	57	62	64	10	14	6	8	15
37861	2012-02-22	64	71	left	high	medium	67	56	53	62	54	66	47	53	54	67	78	79	71	68	76	62	70	72	62	60	69	63	53	52	52	57	62	64	10	14	6	8	15
37861	2011-08-30	64	71	left	high	medium	67	56	53	62	54	66	47	53	54	67	78	79	71	68	76	62	70	72	62	60	69	63	53	52	52	57	62	64	10	14	6	8	15
37861	2011-02-22	63	66	left	high	medium	59	40	53	57	50	64	47	53	49	62	78	79	70	68	72	62	69	72	62	60	69	63	57	59	51	57	62	61	10	14	6	8	15
37861	2010-08-30	63	66	left	high	medium	59	40	53	57	50	64	47	53	49	62	78	79	70	68	72	62	69	72	62	60	69	63	57	59	51	57	62	61	10	14	6	8	15
37861	2010-02-22	65	69	left	high	medium	62	43	56	60	50	67	47	56	52	65	81	82	70	71	72	65	69	75	65	63	72	58	54	59	65	60	65	61	11	20	52	20	20
37861	2009-08-30	67	73	left	high	medium	70	48	61	62	50	72	47	56	62	67	78	80	70	72	72	70	69	76	77	68	72	63	55	59	65	60	67	61	11	20	62	20	20
37861	2008-08-30	65	73	left	high	medium	69	48	61	56	50	65	47	56	54	63	80	83	70	74	72	61	69	73	67	57	67	63	53	59	62	56	66	61	11	20	54	20	20
37861	2007-08-30	64	71	left	high	medium	62	43	47	56	50	61	47	56	54	63	80	83	70	74	72	61	69	73	54	57	64	63	53	59	62	56	60	61	11	20	54	20	20
37861	2007-02-22	62	69	left	high	medium	61	40	44	51	50	58	47	62	51	60	85	84	70	70	72	54	69	71	64	52	59	63	53	59	62	59	57	61	11	7	51	9	12
91929	2016-02-04	71	71	right	medium	medium	14	12	13	19	12	18	19	15	24	22	51	43	46	73	38	24	66	26	78	14	34	16	13	36	44	15	15	15	74	70	66	67	75
91929	2015-11-19	72	72	right	medium	medium	14	12	13	19	12	18	19	15	24	22	51	43	46	77	38	24	66	26	78	14	34	16	13	36	44	15	15	15	75	71	66	67	76
91929	2015-10-23	71	71	right	medium	medium	14	12	13	19	12	18	19	15	24	22	51	43	46	77	38	24	66	26	78	14	34	16	13	36	44	15	15	15	75	71	66	62	76
91929	2015-09-21	71	71	right	medium	medium	14	12	13	19	12	18	19	15	24	22	51	43	46	77	38	24	66	26	78	14	34	16	13	36	44	15	15	15	75	71	66	62	76
91929	2015-05-15	71	71	right	medium	medium	25	25	25	25	25	25	25	25	23	21	51	43	46	76	38	23	66	26	78	25	33	25	25	25	43	25	25	25	74	70	65	63	78
91929	2015-03-13	71	71	right	medium	medium	25	25	25	25	25	25	25	25	23	21	51	43	46	76	38	23	66	26	78	25	33	25	25	25	43	25	25	25	74	66	67	65	78
91929	2014-03-28	71	71	right	medium	medium	25	25	25	25	25	25	25	25	23	21	51	43	46	76	38	23	66	26	71	25	33	25	25	25	43	25	25	25	74	66	67	65	78
91929	2013-11-29	70	70	right	medium	medium	25	25	25	25	25	25	25	25	23	21	51	43	46	76	38	23	66	26	71	25	33	25	25	25	43	25	25	25	73	64	66	65	76
91929	2013-10-04	70	70	right	medium	medium	25	25	25	25	25	25	25	25	23	21	51	43	46	76	38	23	66	26	71	25	33	25	25	25	43	25	25	25	73	62	66	66	76
91929	2013-09-20	68	70	right	medium	medium	25	25	25	25	25	25	25	25	23	21	51	43	46	76	38	23	66	26	71	25	33	25	25	25	43	25	25	25	71	62	66	66	73
91929	2013-03-08	68	70	right	medium	medium	13	11	12	18	11	17	18	14	23	21	63	58	53	61	38	23	71	48	72	13	46	20	12	11	58	14	14	14	71	62	66	66	73
91929	2013-02-22	68	70	right	medium	medium	13	11	12	18	11	17	18	14	23	21	63	58	53	61	38	23	71	48	72	13	46	20	12	11	21	14	14	14	71	62	66	66	73
91929	2012-08-31	68	70	right	medium	medium	13	11	12	18	11	17	18	14	23	21	63	58	53	61	38	23	71	48	72	13	46	20	12	11	21	14	14	14	71	65	66	66	73
91929	2012-02-22	66	68	right	medium	medium	13	11	12	18	11	17	18	14	23	21	63	58	53	61	38	23	68	48	72	13	46	20	12	11	21	14	14	14	69	62	61	64	72
91929	2011-08-30	66	68	right	medium	medium	13	11	12	18	11	17	18	14	23	21	63	58	53	61	38	23	68	48	72	13	26	20	12	11	21	14	14	14	69	62	61	63	71
91929	2011-02-22	67	72	right	medium	medium	13	11	12	18	11	17	18	14	23	21	54	51	51	61	37	23	73	52	60	13	56	20	12	31	21	14	14	14	65	72	61	65	70
91929	2010-08-30	67	72	right	medium	medium	8	11	12	18	11	17	18	8	23	21	54	51	51	61	37	23	73	67	60	7	56	20	12	31	21	9	9	9	65	72	61	65	70
91929	2009-08-30	67	72	right	medium	medium	21	21	21	21	11	21	18	8	61	21	54	51	51	61	37	23	73	67	60	21	56	52	31	31	41	21	21	9	65	72	61	65	70
91929	2008-08-30	57	57	right	medium	medium	21	21	21	21	11	21	18	25	58	21	34	21	51	51	37	58	73	67	60	23	40	31	31	31	41	22	21	9	56	58	58	54	59
91929	2007-02-22	57	57	right	medium	medium	21	21	21	21	11	21	18	25	58	21	34	21	51	51	37	58	73	67	60	23	40	31	31	31	41	22	21	9	56	58	58	54	59
38441	2016-06-23	77	77	right	medium	high	66	41	72	73	54	62	62	69	77	74	76	76	74	78	74	80	72	79	69	69	85	80	54	60	47	80	75	80	12	16	14	6	12
38441	2016-06-16	77	77	right	medium	high	69	41	72	73	54	62	62	69	76	74	76	76	74	78	74	80	72	79	69	69	85	80	54	60	47	80	75	80	12	16	14	6	12
38441	2016-06-09	77	77	right	medium	high	69	41	72	73	54	62	62	69	76	74	78	77	74	78	74	80	72	79	69	69	85	80	54	60	47	80	75	80	12	16	14	6	12
38441	2016-05-26	77	77	right	medium	high	69	41	70	73	54	62	62	69	76	74	75	74	72	78	72	80	72	79	69	69	85	80	42	60	47	80	76	80	12	16	14	6	12
38441	2016-05-19	76	76	right	medium	high	69	41	70	71	54	60	57	69	76	73	75	74	72	76	72	80	72	78	68	69	85	80	42	60	47	80	76	80	12	16	14	6	12
38441	2016-04-28	76	76	right	medium	high	69	41	70	71	54	56	57	69	76	73	75	74	72	76	72	80	70	78	68	69	85	80	42	60	47	80	76	80	12	16	14	6	12
38441	2016-04-14	76	76	right	medium	high	69	41	70	71	54	56	57	69	75	72	75	74	72	75	72	80	70	77	68	69	85	79	42	60	47	79	77	80	12	16	14	6	12
38441	2016-04-07	76	76	right	medium	high	69	41	72	71	54	56	57	69	73	72	75	74	72	75	72	80	66	77	68	69	85	79	42	60	47	79	77	79	12	16	14	6	12
38441	2016-03-17	76	76	right	medium	medium	69	41	72	71	54	56	57	69	73	72	75	74	72	75	72	80	66	77	68	69	85	79	42	60	47	79	77	79	12	16	14	6	12
38441	2016-03-03	76	76	right	medium	medium	69	41	72	71	54	56	57	69	73	72	69	74	67	71	72	80	66	77	68	69	85	79	42	46	47	79	77	79	12	16	14	6	12
38441	2016-02-18	76	76	right	medium	medium	69	41	72	71	54	50	57	69	73	68	69	74	67	71	72	80	66	77	68	69	85	79	42	46	47	79	77	79	12	16	14	6	12
38441	2015-11-06	76	76	right	medium	medium	69	41	72	71	54	50	57	69	73	68	69	74	67	71	72	80	80	77	68	69	85	79	42	46	47	79	77	79	12	16	14	6	12
38441	2015-09-21	76	76	right	medium	medium	69	41	72	71	54	50	57	69	73	68	69	74	67	71	72	80	80	77	68	69	83	79	42	46	47	79	77	79	12	16	14	6	12
38441	2015-08-14	75	75	right	medium	medium	68	41	71	71	54	50	56	69	72	68	69	74	67	70	72	79	80	77	68	68	82	79	41	46	46	76	75	77	11	15	13	5	11
38441	2015-07-03	74	75	right	medium	medium	68	41	71	71	54	42	56	69	72	57	69	74	67	70	67	79	80	77	68	68	82	79	41	38	46	76	76	75	11	15	13	5	11
38441	2015-01-30	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	74	67	70	67	79	80	77	68	68	82	72	41	38	46	76	77	75	11	15	13	5	11
38441	2015-01-28	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	74	67	70	67	79	80	77	68	68	82	72	41	38	46	76	77	75	11	15	13	5	11
38441	2015-01-23	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	74	67	70	67	79	80	77	68	68	82	72	41	38	46	76	77	75	11	15	13	5	11
38441	2014-11-14	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	74	67	70	67	79	80	77	68	68	82	72	41	38	46	76	77	75	11	15	13	5	11
38441	2014-09-18	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	74	67	70	67	79	80	77	68	68	84	72	41	38	46	76	77	75	11	15	13	5	11
38441	2014-05-02	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	69	67	70	67	79	75	77	68	68	84	72	41	38	46	76	77	75	11	15	13	5	11
38441	2014-04-04	73	73	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	69	67	70	67	79	75	77	68	68	84	72	41	38	46	76	77	75	11	15	13	5	11
38441	2013-11-29	71	71	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	69	67	66	67	79	75	77	68	68	84	68	41	38	46	71	74	73	11	15	13	5	11
38441	2013-10-18	71	71	right	medium	medium	68	27	71	64	46	42	56	69	72	57	69	70	67	66	67	79	75	77	68	68	84	68	41	38	46	71	74	73	11	15	13	5	11
38441	2013-09-20	71	74	right	medium	medium	68	27	71	64	46	42	56	69	72	59	69	70	67	64	67	79	75	77	68	68	84	68	41	38	46	69	76	74	11	15	13	5	11
38441	2013-05-31	71	74	right	medium	medium	68	27	71	64	46	42	56	69	72	59	69	71	67	64	67	79	74	77	68	68	84	68	41	38	46	69	76	74	11	15	13	5	11
38441	2013-04-19	71	74	right	medium	medium	68	27	71	64	46	42	56	69	72	59	69	71	67	64	67	79	74	77	68	68	84	68	41	38	46	69	76	74	11	15	13	5	11
38441	2013-03-22	71	72	right	medium	medium	68	27	71	64	46	42	56	69	67	59	69	71	67	64	67	79	74	77	68	68	84	68	41	38	46	69	76	74	11	15	13	5	11
38441	2013-03-15	71	72	right	medium	medium	68	27	71	64	46	42	56	69	67	59	69	71	67	64	67	79	74	77	68	68	84	68	41	38	46	69	76	74	11	15	13	5	11
38441	2013-03-08	70	71	right	medium	medium	68	27	70	58	46	42	56	68	67	52	69	71	67	64	66	78	74	76	67	66	84	63	41	38	46	67	76	74	11	15	13	5	11
38441	2013-02-15	70	71	right	medium	medium	68	27	70	58	46	42	56	68	67	52	69	71	67	64	66	78	74	76	67	66	84	63	41	38	46	67	76	74	11	15	13	5	11
38441	2012-08-31	70	71	right	medium	medium	68	27	70	58	46	42	56	68	67	52	69	72	67	64	65	78	72	75	67	66	84	63	41	38	46	67	76	74	11	15	13	5	11
38441	2012-02-22	70	71	right	medium	medium	68	27	69	57	46	47	56	68	67	56	67	70	67	60	70	78	72	75	65	66	83	61	43	36	46	76	73	74	11	15	13	5	11
38441	2011-08-30	70	71	right	medium	medium	66	21	70	56	30	31	36	61	63	53	67	70	67	60	70	76	72	75	63	59	83	61	43	36	46	76	73	74	11	15	13	5	11
38441	2011-02-22	69	73	right	medium	medium	65	35	70	64	36	45	36	61	66	59	64	66	65	65	68	71	67	71	67	67	81	72	54	50	46	68	71	69	11	15	13	5	11
38441	2010-08-30	68	73	right	medium	medium	65	55	70	64	36	45	36	61	64	57	64	66	65	65	68	71	67	71	67	67	81	72	61	50	46	67	69	67	11	15	13	5	11
38441	2010-02-22	64	68	right	medium	medium	53	39	66	51	36	31	36	61	48	51	63	66	65	60	68	71	67	71	63	60	81	45	51	50	47	61	66	67	12	20	48	20	20
38441	2009-08-30	64	68	right	medium	medium	53	39	66	51	36	31	36	61	48	51	63	66	65	60	68	68	67	71	63	56	81	45	51	50	47	61	66	67	12	20	48	20	20
38441	2009-02-22	66	73	right	medium	medium	53	39	66	51	36	31	36	61	48	51	63	68	65	60	68	71	67	72	63	56	81	45	56	50	57	68	66	67	12	20	48	20	20
38441	2008-08-30	66	68	right	medium	medium	51	39	66	58	36	48	36	63	53	53	63	66	65	65	68	65	67	71	63	56	81	45	63	50	57	68	66	67	12	20	53	20	20
38441	2007-08-30	65	66	right	medium	medium	54	20	70	63	36	49	36	35	55	53	55	54	65	58	68	28	67	69	63	54	50	45	52	50	57	63	64	67	12	20	55	20	20
38441	2007-02-22	58	61	right	medium	medium	54	19	62	66	36	53	36	57	49	48	55	54	65	58	68	28	67	58	53	54	50	45	52	50	57	63	60	67	12	9	49	8	12
182605	2014-01-24	63	65	right	medium	low	46	44	55	61	49	71	59	49	62	70	65	63	71	61	65	51	50	68	71	52	65	41	64	65	51	42	48	49	6	8	6	6	10
182605	2013-12-20	63	65	right	medium	low	46	44	55	61	49	71	59	49	62	70	65	63	71	61	65	51	50	68	71	52	65	41	64	65	51	42	48	49	6	8	6	6	10
182605	2013-09-20	63	67	right	medium	low	46	44	55	61	49	71	59	49	62	70	65	63	71	61	65	51	50	68	71	52	65	41	64	65	51	42	48	49	6	8	6	6	10
182605	2013-05-10	63	67	right	medium	medium	46	44	55	61	49	71	59	49	62	70	65	64	71	61	65	51	54	68	71	52	65	41	64	65	51	42	48	49	6	8	6	6	10
182605	2013-02-15	64	69	right	medium	medium	46	48	53	64	53	73	59	49	63	72	65	64	71	61	65	53	54	68	71	53	65	41	64	65	51	42	51	52	6	8	6	6	10
182605	2012-02-22	64	69	right	medium	medium	46	48	53	64	53	73	59	49	63	72	65	64	71	61	65	53	54	68	71	53	65	41	64	65	51	42	51	52	6	8	6	6	10
182605	2011-08-30	64	69	right	medium	medium	46	48	53	64	53	73	59	49	63	72	65	64	71	61	65	53	55	68	71	53	65	41	64	65	51	42	51	52	6	8	6	6	10
182605	2010-08-30	63	68	right	medium	medium	46	44	53	64	53	72	59	49	67	71	64	66	67	61	59	53	58	66	65	47	65	42	64	66	51	43	51	56	6	8	6	6	10
182605	2010-02-22	61	68	right	medium	medium	42	37	53	58	53	72	59	49	63	67	63	66	67	62	59	53	58	66	65	47	60	58	58	66	56	51	50	56	9	22	63	22	22
182605	2009-08-30	59	68	right	medium	medium	42	37	53	58	53	59	59	49	63	62	63	66	67	62	59	53	58	66	65	47	60	58	58	66	56	51	50	56	9	22	63	22	22
182605	2007-02-22	59	68	right	medium	medium	42	37	53	58	53	59	59	49	63	62	63	66	67	62	59	53	58	66	65	47	60	58	58	66	56	51	50	56	9	22	63	22	22
39772	2010-08-30	65	69	left	\N	\N	56	63	63	58	61	64	41	41	43	64	77	73	55	68	66	69	66	72	69	63	57	37	60	54	53	22	60	43	6	5	15	6	13
39772	2010-02-22	66	69	left	\N	\N	63	66	63	58	61	64	41	41	43	64	77	73	55	65	66	69	66	72	69	65	57	57	59	54	57	22	60	43	1	20	43	20	20
39772	2009-08-30	67	81	left	\N	\N	63	69	63	58	61	64	41	41	43	64	77	73	55	65	66	69	66	66	69	65	57	57	59	54	57	22	60	43	1	20	43	20	20
39772	2008-08-30	63	81	left	\N	\N	63	69	57	58	61	58	41	41	43	64	77	73	55	55	66	69	66	57	69	49	57	57	59	54	51	22	51	43	1	20	43	20	20
39772	2007-08-30	64	81	left	\N	\N	59	64	57	52	61	52	41	41	43	59	77	71	55	55	66	69	66	57	69	49	57	57	59	54	51	22	21	43	1	20	43	20	20
39772	2007-02-22	64	81	left	\N	\N	59	64	57	52	61	52	41	41	43	59	77	71	55	55	66	69	66	57	69	49	57	57	59	54	51	22	21	43	1	20	43	20	20
192907	2012-02-22	63	70	left	medium	medium	57	62	56	55	58	66	67	61	47	68	73	75	68	66	69	65	70	40	68	59	56	21	58	55	56	23	29	31	7	8	10	5	10
192907	2011-08-30	63	70	left	medium	medium	57	62	56	55	58	66	67	61	47	68	73	75	68	66	69	65	70	46	68	59	56	21	58	55	56	23	29	31	7	8	10	5	10
192907	2011-02-22	63	69	left	medium	medium	57	64	56	55	56	62	67	61	47	65	71	73	65	66	53	66	65	52	49	58	56	21	58	55	56	23	29	31	7	8	10	5	10
192907	2010-08-30	64	69	left	medium	medium	59	64	58	55	56	63	69	61	51	66	72	74	64	66	51	67	54	52	49	59	61	31	63	55	56	33	29	31	7	8	10	5	10
192907	2010-02-22	52	57	left	medium	medium	42	46	45	43	56	43	69	61	44	63	68	66	64	64	51	43	54	52	48	49	53	53	42	55	53	39	36	31	5	24	44	24	24
192907	2007-02-22	52	57	left	medium	medium	42	46	45	43	56	43	69	61	44	63	68	66	64	64	51	43	54	52	48	49	53	53	42	55	53	39	36	31	5	24	44	24	24
37887	2011-02-22	64	68	left	\N	\N	66	48	63	64	56	54	77	69	58	63	64	67	69	61	64	67	67	72	64	64	68	67	37	64	62	62	63	61	11	5	6	15	12
37887	2010-08-30	65	68	left	\N	\N	66	48	63	66	56	54	77	72	58	63	64	67	69	61	64	67	67	72	64	67	71	69	64	64	64	63	63	61	11	5	6	15	12
37887	2009-08-30	64	68	left	\N	\N	66	48	63	66	56	54	77	72	58	61	64	67	69	61	64	67	67	72	64	67	71	68	63	64	58	63	63	61	6	21	58	21	21
37887	2009-02-22	64	68	left	\N	\N	62	38	63	66	56	54	77	49	54	61	64	67	69	61	64	43	67	72	64	42	71	68	63	64	48	63	63	61	6	21	54	21	21
37887	2007-08-30	64	64	left	\N	\N	62	38	63	66	56	54	77	49	54	61	64	67	69	61	64	43	67	72	64	42	71	68	63	64	48	63	63	61	6	21	54	21	21
37887	2007-02-22	65	66	left	\N	\N	63	39	64	67	56	55	77	49	55	62	65	68	69	62	64	44	67	73	65	43	72	68	63	64	49	64	64	61	6	12	55	14	6
38393	2016-05-05	81	81	right	medium	high	68	52	54	83	78	67	71	76	82	84	74	69	76	80	78	77	62	80	72	75	83	82	55	78	72	72	82	78	14	12	7	12	7
38393	2016-04-21	81	81	right	medium	high	68	52	55	83	78	67	71	76	82	84	74	69	76	80	78	77	62	80	72	75	83	82	55	78	72	72	82	78	14	12	7	12	7
38393	2016-03-10	81	81	right	medium	high	68	55	55	83	78	73	76	76	82	84	74	69	76	80	78	77	62	80	72	75	83	82	55	78	72	72	82	78	14	12	7	12	7
38393	2016-01-28	82	82	right	medium	high	68	55	55	86	78	73	76	76	82	85	74	69	76	83	78	77	62	82	72	75	83	82	55	82	66	72	82	77	14	12	7	12	7
38393	2016-01-07	82	82	right	medium	high	62	52	55	86	79	73	76	76	81	85	74	70	76	83	77	77	61	82	75	75	83	82	55	82	64	70	82	77	14	12	7	12	7
38393	2015-11-26	82	82	right	medium	high	62	52	55	86	79	73	76	76	81	85	74	70	76	83	77	77	61	82	75	75	83	82	55	82	64	70	82	77	14	12	7	12	7
38393	2015-09-25	82	82	right	medium	high	62	52	55	86	79	73	76	76	81	85	74	70	76	83	77	77	61	82	75	75	83	82	55	82	64	70	82	77	14	12	7	12	7
38393	2015-09-21	82	82	right	medium	high	62	52	55	86	79	73	76	76	81	85	74	64	76	83	77	77	61	82	75	75	83	82	55	82	64	70	82	77	14	12	7	12	7
38393	2015-04-17	80	80	right	medium	high	62	52	55	86	76	73	76	73	79	84	64	64	76	80	77	74	61	82	75	72	83	82	55	79	64	68	81	79	14	12	7	12	7
38393	2015-04-10	80	81	right	medium	high	62	52	55	86	76	73	76	73	79	84	64	64	76	80	77	74	61	82	75	72	83	82	55	79	64	68	81	79	14	12	7	12	7
38393	2015-03-20	80	81	right	medium	high	62	52	55	86	74	73	76	73	79	84	64	64	76	80	77	74	61	82	75	72	83	82	55	79	64	68	81	79	14	12	7	12	7
38393	2015-03-13	80	81	right	medium	high	62	52	55	86	74	73	76	73	79	84	64	64	76	80	77	74	61	82	75	72	83	82	55	79	64	68	83	80	14	12	7	12	7
38393	2015-02-27	79	80	right	medium	high	62	52	55	86	65	73	76	73	79	84	64	64	76	80	77	74	61	82	75	72	77	78	55	79	64	68	81	79	14	12	7	12	7
38393	2014-12-19	79	79	right	medium	high	62	52	55	86	65	73	76	73	79	84	64	64	76	80	77	74	61	82	75	72	77	78	55	79	64	68	81	79	14	12	7	12	7
38393	2014-11-07	78	78	right	medium	high	62	52	55	85	65	73	73	73	79	83	61	62	76	78	77	71	61	78	72	72	75	78	55	79	64	64	80	77	14	12	7	12	7
38393	2014-10-31	78	78	right	medium	high	62	57	55	85	65	73	73	73	79	83	61	62	76	78	77	71	61	78	72	72	75	78	55	77	64	63	80	74	14	12	7	12	7
38393	2014-09-18	77	77	right	medium	high	62	57	55	85	65	73	73	65	79	83	61	62	76	78	77	71	61	78	72	72	75	78	55	77	64	63	80	74	14	12	7	12	7
38393	2014-04-25	77	77	right	medium	high	63	58	56	84	66	74	74	66	80	84	62	62	76	77	77	72	61	79	73	72	72	79	56	77	65	64	79	72	15	13	8	13	8
38393	2014-04-04	77	77	right	medium	high	63	58	56	84	66	74	74	66	80	84	62	62	76	77	77	72	61	79	73	74	72	79	56	73	65	64	79	72	15	13	8	13	8
38393	2013-11-01	76	78	right	medium	high	63	58	56	84	60	74	66	66	80	82	57	57	76	77	77	66	61	79	73	68	72	79	56	73	65	64	72	64	15	13	8	13	8
38393	2013-10-18	76	78	right	medium	high	63	58	56	84	60	74	66	66	80	82	54	55	76	77	77	66	61	79	73	68	72	79	56	73	65	64	72	64	15	13	8	13	8
38393	2013-09-27	76	78	right	medium	high	63	58	56	84	60	74	66	66	80	82	54	55	76	77	77	66	61	79	73	68	72	79	56	73	65	64	72	64	15	13	8	13	8
38393	2013-09-20	76	78	right	medium	high	63	58	56	84	60	74	66	66	80	82	54	55	76	77	77	66	61	79	73	68	72	79	56	73	65	66	72	64	15	13	8	13	8
38393	2013-05-10	76	78	right	medium	high	63	58	56	83	63	77	66	66	73	83	53	56	76	79	77	66	61	80	73	68	72	86	56	73	66	66	73	66	15	13	8	13	8
38393	2013-03-22	77	78	right	medium	high	63	58	56	83	63	77	66	66	73	83	53	56	76	79	77	66	61	80	73	68	72	86	56	73	66	66	73	66	15	13	8	13	8
38393	2013-03-15	77	78	right	medium	high	63	58	56	83	63	77	66	66	73	83	53	56	76	79	77	66	61	80	73	68	72	86	56	73	66	66	73	66	15	13	8	13	8
38393	2013-02-15	77	78	right	medium	high	63	58	56	83	63	77	66	66	73	83	53	56	76	79	77	66	61	80	73	68	72	86	56	73	66	66	73	66	15	13	8	13	8
38393	2012-08-31	76	79	right	medium	high	63	58	56	83	63	74	68	69	73	83	56	55	73	77	76	66	61	78	67	68	71	86	56	76	66	63	73	66	15	13	8	13	8
38393	2012-02-22	76	79	right	medium	high	63	58	56	83	63	74	68	69	73	83	58	54	73	77	76	66	61	78	67	68	71	84	56	76	66	63	73	66	15	13	8	13	8
38393	2011-08-30	75	77	right	medium	high	63	56	56	83	63	74	68	69	73	83	51	54	73	77	76	67	61	78	67	68	63	86	53	69	66	63	73	67	15	13	8	13	8
38393	2011-02-22	76	79	right	medium	high	67	56	57	84	66	77	68	69	77	84	56	63	70	80	71	65	58	76	66	68	66	86	64	79	67	66	76	72	15	13	8	13	8
38393	2010-08-30	76	79	right	medium	high	67	56	57	84	66	77	68	69	77	84	56	63	67	73	71	65	58	76	66	68	66	86	64	79	67	66	76	72	15	13	8	13	8
38393	2010-02-22	74	79	right	medium	high	67	53	50	80	66	78	68	69	74	83	56	61	67	71	71	67	58	76	67	66	66	72	79	79	73	62	73	72	8	20	74	20	20
38393	2009-08-30	74	79	right	medium	high	67	53	50	80	66	78	68	69	74	83	56	61	67	71	71	67	58	76	65	66	63	72	79	79	73	62	73	72	8	20	74	20	20
38393	2008-08-30	74	80	right	medium	high	71	53	60	78	66	78	68	65	76	83	60	65	67	73	71	67	58	76	67	63	63	72	78	79	75	67	74	72	8	20	76	20	20
38393	2007-08-30	79	83	right	medium	high	71	53	58	83	66	77	68	65	78	83	65	62	67	73	71	67	58	77	60	63	72	71	74	79	76	71	76	72	8	20	78	20	20
38393	2007-02-22	76	83	right	medium	high	77	58	58	84	66	70	68	63	79	80	69	67	67	73	71	72	58	79	63	63	50	71	74	79	63	80	78	72	8	15	79	11	11
166670	2016-03-31	66	68	left	high	medium	65	57	49	69	62	68	74	71	66	69	65	59	72	66	76	66	56	67	53	67	57	63	67	68	67	48	52	46	9	11	11	9	11
166670	2016-03-10	66	68	left	high	medium	65	57	49	69	62	68	74	71	66	69	65	59	72	66	76	66	56	67	53	67	57	63	67	68	67	48	52	46	9	11	11	9	11
166670	2015-10-30	66	69	left	high	medium	65	57	49	69	62	68	74	71	66	69	65	59	72	66	76	66	56	67	53	67	57	63	67	68	67	48	52	46	9	11	11	9	11
166670	2015-09-25	66	69	left	high	medium	65	57	49	69	62	68	74	71	66	69	65	59	72	66	76	66	56	67	53	67	57	63	67	68	67	48	52	46	9	11	11	9	11
166670	2015-09-21	66	69	left	high	medium	65	57	49	69	62	68	74	71	66	69	65	59	72	66	76	66	56	67	53	67	57	63	67	68	67	48	52	46	9	11	11	9	11
166670	2015-04-17	65	68	left	high	medium	64	56	48	68	61	67	73	70	65	68	65	59	72	65	76	65	59	67	53	66	56	62	66	67	66	47	51	45	8	10	10	8	10
166670	2015-03-13	65	68	left	high	medium	64	56	48	68	61	67	73	70	65	68	65	59	72	65	76	65	59	67	53	66	56	62	66	67	66	47	51	45	8	10	10	8	10
166670	2015-01-09	65	68	left	high	medium	64	56	48	68	61	67	73	70	65	68	65	59	72	65	76	65	59	67	53	66	56	62	66	67	66	47	51	45	8	10	10	8	10
166670	2014-12-19	67	70	left	high	medium	64	58	53	69	57	70	73	70	65	69	66	59	72	72	76	66	59	67	56	64	58	63	67	68	66	49	54	45	8	10	10	8	10
166670	2014-10-02	67	70	left	high	medium	64	58	53	69	57	70	73	70	65	69	66	59	72	72	76	66	59	67	56	64	58	63	67	68	66	49	54	45	8	10	10	8	10
166670	2014-09-18	67	70	left	high	medium	64	58	53	69	57	70	73	70	65	69	66	59	72	72	76	66	59	67	56	64	58	63	67	68	66	49	54	45	8	10	10	8	10
166670	2014-07-18	67	70	left	high	medium	64	58	53	69	57	70	73	70	65	69	66	62	72	72	76	66	60	67	56	64	58	63	67	68	66	49	54	45	8	10	10	8	10
166670	2014-01-17	67	70	left	high	medium	64	58	53	69	57	70	73	70	65	69	66	62	72	72	76	66	60	67	56	64	58	63	67	68	66	49	54	45	8	10	10	8	10
166670	2013-09-20	67	70	left	high	medium	64	58	53	69	57	70	73	70	65	69	66	62	72	72	76	66	60	67	56	64	58	63	67	68	66	49	54	45	8	10	10	8	10
166670	2013-05-31	67	72	left	medium	medium	64	58	53	64	57	70	73	70	65	69	66	63	72	69	76	66	60	67	55	64	58	60	66	67	66	39	48	45	8	10	10	8	10
166670	2013-03-28	66	72	left	medium	medium	64	58	53	64	57	68	73	70	65	69	66	63	72	64	76	66	60	67	55	64	58	60	66	67	66	39	48	45	8	10	10	8	10
166670	2013-03-04	66	72	left	medium	medium	64	58	53	64	57	68	73	70	65	69	66	63	72	64	76	66	60	67	55	64	58	60	66	67	66	39	48	45	8	10	10	8	10
166670	2013-02-15	66	72	left	medium	medium	64	58	53	64	57	68	73	70	65	69	66	63	72	64	76	66	60	67	55	64	58	60	66	67	66	39	48	45	8	10	10	8	10
166670	2012-08-31	64	69	left	high	medium	68	58	53	64	57	69	73	73	66	69	66	66	72	65	75	66	64	65	49	64	58	53	68	70	66	39	43	45	8	10	10	8	10
166670	2011-08-30	64	69	left	medium	medium	56	58	53	63	56	65	60	63	61	68	66	66	71	63	84	61	64	75	39	64	56	53	58	64	54	39	43	45	8	10	10	8	10
166670	2011-02-22	63	71	left	medium	medium	56	58	53	63	56	65	60	63	61	68	65	67	67	63	39	61	62	73	41	64	56	53	58	64	54	39	43	45	8	10	10	8	10
166670	2010-08-30	62	71	left	medium	medium	56	58	53	63	53	65	60	60	58	68	65	67	67	61	39	58	62	73	41	61	56	53	58	62	52	39	43	45	8	10	10	8	10
166670	2010-02-22	60	71	left	medium	medium	56	53	39	63	53	63	60	56	58	66	65	67	67	61	39	58	62	73	45	61	56	61	53	62	54	39	43	45	19	21	58	21	25
166670	2009-08-30	50	65	left	medium	medium	48	39	29	55	53	51	60	52	53	53	60	62	67	57	39	49	62	62	35	51	43	41	38	62	37	37	43	45	19	21	53	21	25
166670	2009-02-22	43	63	left	medium	medium	45	34	29	49	53	36	60	52	47	49	59	59	67	67	39	37	62	42	47	27	41	37	38	62	27	27	28	45	9	21	47	21	21
166670	2008-08-30	43	63	right	medium	medium	45	34	29	49	53	36	60	52	47	49	59	59	67	67	39	37	62	42	47	27	41	37	38	62	27	27	28	45	9	21	47	21	21
166670	2007-02-22	43	63	right	medium	medium	45	34	29	49	53	36	60	52	47	49	59	59	67	67	39	37	62	42	47	27	41	37	38	62	27	27	28	45	9	21	47	21	21
178486	2014-09-18	63	63	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	47	57	60	63	55	43	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2014-01-31	63	64	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	48	57	60	63	55	43	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2013-09-20	63	64	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	48	57	60	63	55	43	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2013-02-15	63	64	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	48	57	60	63	55	51	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2012-08-31	63	64	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	50	56	60	62	55	54	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2012-02-22	63	64	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	50	56	60	62	55	54	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2011-08-30	63	64	right	medium	medium	42	37	70	56	29	38	40	39	53	52	47	51	56	60	62	55	55	74	68	42	64	62	32	52	40	63	65	62	9	8	8	5	9
178486	2010-08-30	63	65	right	medium	medium	42	37	70	56	29	38	40	39	53	52	54	62	57	60	62	55	58	72	67	42	64	62	32	65	40	63	65	62	9	8	8	5	9
178486	2009-08-30	60	65	right	medium	medium	42	37	64	54	29	38	40	39	49	51	54	62	57	60	62	55	58	72	67	42	59	58	56	65	54	59	63	62	3	22	49	22	22
178486	2008-08-30	58	63	right	medium	medium	42	36	62	52	29	38	40	37	47	51	58	62	57	55	62	55	58	65	67	42	56	56	54	65	51	57	60	62	3	22	47	22	22
178486	2007-02-22	58	63	right	medium	medium	42	36	62	52	29	38	40	37	47	51	58	62	57	55	62	55	58	65	67	42	56	56	54	65	51	57	60	62	3	22	47	22	22
37893	2011-02-22	66	67	right	\N	\N	52	46	64	67	51	46	38	53	64	61	56	61	51	63	73	73	58	79	75	61	73	71	56	67	57	59	66	64	7	15	6	7	11
37893	2010-08-30	66	68	right	\N	\N	52	46	64	67	51	46	38	53	64	61	56	61	51	63	73	73	58	79	75	61	73	71	56	67	57	59	66	64	7	15	6	7	11
37893	2009-08-30	65	66	right	\N	\N	54	43	62	66	51	48	38	53	62	62	56	60	51	61	73	71	58	80	74	61	73	72	71	67	68	57	65	64	7	25	62	25	25
37893	2009-02-22	64	67	right	\N	\N	46	38	66	63	51	48	38	37	53	63	57	59	51	58	73	69	58	76	74	44	72	68	67	67	63	54	66	64	1	25	53	25	25
37893	2008-08-30	62	67	right	\N	\N	46	38	66	63	51	48	38	37	53	63	57	59	51	58	73	63	58	76	74	44	72	54	57	67	55	54	66	64	1	25	53	25	25
37893	2007-08-30	65	67	right	\N	\N	46	38	66	63	51	48	38	37	53	63	57	59	51	58	73	63	58	76	74	44	72	54	57	67	55	54	66	64	1	25	53	25	25
37893	2007-02-22	65	67	right	\N	\N	46	38	66	63	51	48	38	55	53	63	57	59	51	58	73	63	58	76	74	44	72	54	57	67	55	54	66	64	1	1	53	1	1
26116	2012-08-31	63	63	right	medium	low	43	68	67	50	58	47	39	44	37	52	52	55	72	64	52	68	84	51	80	63	33	18	68	54	63	12	22	20	9	8	12	6	12
26116	2012-02-22	65	65	right	medium	low	44	69	68	51	59	48	40	45	38	53	68	71	72	65	52	69	74	66	80	64	34	19	69	55	64	13	23	21	9	8	12	6	12
26116	2011-08-30	66	66	right	medium	low	45	70	69	52	60	49	41	46	39	54	68	71	72	65	52	70	74	66	80	65	34	19	69	55	65	14	24	22	9	8	12	6	12
26116	2011-02-22	68	72	right	medium	low	48	74	71	54	63	56	48	54	46	58	67	71	65	68	69	74	68	65	71	70	61	43	73	61	69	16	26	24	9	8	12	6	12
26116	2010-08-30	69	72	right	medium	low	48	74	72	54	71	56	48	54	46	58	68	72	66	71	69	74	68	66	71	71	61	43	74	61	69	16	26	24	9	8	12	6	12
26116	2010-02-22	69	72	right	medium	low	54	72	73	65	71	60	48	54	59	62	66	70	66	71	69	71	68	66	71	71	61	64	66	61	68	22	26	24	8	22	59	22	22
26116	2009-08-30	69	72	right	medium	low	54	72	73	65	71	60	48	54	59	62	66	70	66	71	69	71	68	66	71	71	61	64	66	61	68	22	26	24	8	22	59	22	22
26116	2008-08-30	70	72	right	medium	low	54	74	73	65	71	60	48	54	59	62	66	70	66	71	69	74	68	66	71	71	61	64	66	61	68	22	26	24	8	22	59	22	22
26116	2008-02-22	71	72	right	medium	low	57	72	72	65	71	67	48	54	59	69	66	70	66	71	69	74	68	66	68	71	61	69	66	61	68	22	26	24	8	22	59	22	22
26116	2007-08-30	71	72	right	medium	low	57	72	72	65	71	67	48	54	59	69	66	70	66	71	69	74	68	66	68	71	61	69	66	61	68	22	26	24	8	22	59	22	22
26116	2007-02-22	74	75	right	medium	low	68	78	65	73	71	74	48	71	59	71	73	70	66	70	69	75	68	68	75	76	61	69	66	61	71	16	25	24	8	8	59	6	6
30404	2010-02-22	68	72	right	\N	\N	63	61	55	69	\N	69	\N	70	64	70	65	67	\N	66	\N	71	\N	64	57	65	56	71	73	\N	72	31	47	\N	5	25	64	25	25
30404	2009-08-30	68	72	right	\N	\N	63	61	55	69	\N	69	\N	70	64	70	65	67	\N	66	\N	71	\N	64	57	65	56	71	73	\N	72	31	47	\N	5	25	64	25	25
30404	2008-08-30	70	72	right	\N	\N	78	67	55	71	\N	71	\N	70	67	72	66	71	\N	66	\N	71	\N	64	65	71	61	75	76	\N	73	54	48	\N	11	25	67	25	25
30404	2008-02-22	76	81	right	\N	\N	81	72	58	81	\N	76	\N	73	72	78	69	74	\N	71	\N	74	\N	67	69	74	62	78	79	\N	76	57	51	\N	11	25	72	25	25
30404	2007-08-30	76	81	right	\N	\N	81	72	58	81	\N	76	\N	73	72	78	69	74	\N	71	\N	74	\N	67	69	74	62	78	79	\N	76	57	51	\N	11	25	72	25	25
30404	2007-02-22	79	84	right	\N	\N	81	77	58	82	\N	76	\N	82	74	83	79	84	\N	77	\N	80	\N	67	69	79	62	78	79	\N	82	57	51	\N	11	11	74	13	13
37945	2010-02-22	63	66	right	\N	\N	47	68	54	60	\N	66	\N	63	48	64	73	75	\N	68	\N	58	\N	62	45	55	25	54	62	\N	60	25	23	\N	1	22	48	22	22
37945	2009-08-30	63	66	right	\N	\N	47	68	54	60	\N	66	\N	45	48	64	73	75	\N	68	\N	58	\N	62	45	55	25	54	62	\N	60	25	23	\N	1	22	48	22	22
37945	2008-08-30	63	66	right	\N	\N	47	68	54	60	\N	66	\N	45	48	64	73	75	\N	68	\N	58	\N	62	45	55	25	54	62	\N	60	25	23	\N	1	22	48	22	22
37945	2007-08-30	63	69	right	\N	\N	52	65	62	53	\N	63	\N	54	46	61	72	70	\N	68	\N	59	\N	59	54	55	55	54	57	\N	60	25	23	\N	1	22	46	22	22
37945	2007-02-22	63	69	right	\N	\N	52	65	62	53	\N	63	\N	60	46	61	72	70	\N	68	\N	59	\N	59	54	55	55	54	57	\N	60	25	23	\N	1	1	46	1	1
38419	2016-06-09	70	70	right	high	low	62	70	68	63	69	70	47	52	49	67	71	72	68	70	57	76	70	60	80	69	67	28	71	60	58	13	33	24	11	9	12	7	6
38419	2016-01-28	70	70	right	high	low	62	70	68	63	69	70	47	52	49	67	71	72	68	70	57	76	70	60	80	69	67	28	71	60	58	13	33	24	11	9	12	7	6
38419	2015-10-02	70	70	right	high	low	62	70	68	63	69	70	47	52	49	67	71	72	68	70	57	76	70	60	80	69	67	28	71	60	58	13	33	24	11	9	12	7	6
38419	2015-09-21	71	71	right	high	low	62	72	68	63	69	71	47	52	49	68	74	75	68	70	57	76	71	65	80	70	59	28	71	62	58	13	33	24	11	9	12	7	6
38419	2015-04-17	69	69	right	high	medium	61	70	67	62	66	68	46	51	48	63	76	77	67	67	57	73	71	67	78	69	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-09-18	69	70	right	high	medium	61	70	67	62	66	68	46	51	48	63	76	77	67	67	57	73	71	67	78	69	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-02-28	69	71	right	high	medium	61	70	67	62	66	68	46	51	48	63	76	77	67	67	57	73	70	67	78	69	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-02-21	69	70	right	high	medium	61	69	67	62	66	68	46	51	48	61	76	77	67	65	57	73	70	67	78	68	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-02-14	69	70	right	high	medium	61	69	67	62	66	66	46	51	48	61	76	77	67	65	57	73	70	67	78	68	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-02-07	69	70	right	high	medium	61	71	67	62	66	66	46	51	48	61	76	77	67	66	57	73	70	67	78	68	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-01-31	69	70	right	high	medium	61	72	67	62	66	66	46	51	48	61	76	77	67	66	57	73	70	67	78	68	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-01-17	69	70	right	high	medium	61	72	67	62	66	66	46	51	48	61	76	77	67	66	57	73	70	67	75	68	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-01-10	69	70	right	high	medium	61	72	67	62	66	66	46	51	48	61	76	77	67	66	57	73	70	67	75	68	57	27	68	61	57	25	32	23	10	8	11	6	5
38419	2014-01-03	69	70	right	high	medium	61	71	67	62	66	66	46	51	48	61	76	77	67	66	57	73	70	67	75	68	57	27	66	61	57	25	32	23	10	8	11	6	5
38419	2013-12-13	68	69	right	high	medium	61	68	67	62	64	66	46	51	48	61	76	77	67	65	57	73	70	67	75	66	57	27	65	61	57	25	32	23	10	8	11	6	5
38419	2013-11-29	67	68	right	high	medium	61	68	67	62	64	66	46	51	48	61	76	77	65	63	50	73	70	64	74	66	57	27	64	54	57	25	32	23	10	8	11	6	5
38419	2013-09-20	67	68	right	high	medium	61	68	67	62	64	66	46	51	48	61	76	77	65	63	50	73	69	64	74	66	57	27	64	54	57	25	32	23	10	8	11	6	5
38419	2013-07-12	67	68	right	high	medium	61	67	67	62	64	71	46	51	48	65	76	77	65	63	49	70	66	64	74	64	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2013-06-07	67	68	right	high	medium	61	67	67	62	64	71	46	51	48	65	76	77	65	63	49	70	66	64	74	64	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2013-05-31	66	70	right	high	medium	61	67	67	62	64	71	46	51	48	65	76	77	65	63	49	70	66	64	74	64	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2013-05-17	67	70	right	high	medium	61	67	67	62	64	71	46	51	48	65	76	77	65	63	49	70	66	64	74	64	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2013-04-05	67	70	right	high	medium	61	67	67	62	64	71	46	51	48	65	76	77	65	63	49	70	66	64	74	64	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2013-03-22	67	70	right	high	medium	61	67	67	62	64	71	46	51	48	65	76	77	65	63	49	70	66	64	74	64	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2013-02-15	68	71	right	high	medium	61	67	67	62	64	75	46	51	48	66	76	79	73	63	49	70	66	64	75	65	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2012-08-31	67	71	right	medium	medium	61	67	67	62	62	75	46	51	48	66	76	82	73	63	47	68	66	64	77	65	57	27	64	54	57	12	32	23	10	8	11	6	5
38419	2012-02-22	66	71	right	medium	medium	57	68	67	62	66	68	46	51	48	66	76	82	73	64	47	76	69	66	77	71	57	27	63	54	57	12	32	23	10	8	11	6	5
38419	2011-08-30	68	71	right	medium	medium	57	68	67	62	66	65	46	51	48	63	76	82	73	64	47	76	69	66	77	71	57	27	61	54	57	12	32	23	10	8	11	6	5
38419	2011-02-22	69	74	right	medium	medium	57	68	67	62	66	65	46	51	48	63	73	78	71	64	68	76	72	65	71	71	57	27	61	54	57	12	32	23	10	8	11	6	5
38419	2010-08-30	67	74	right	medium	medium	46	67	65	52	66	63	46	51	37	61	68	78	67	65	68	73	67	65	71	71	59	27	61	57	57	12	32	23	10	8	11	6	5
38419	2010-02-22	68	74	right	medium	medium	46	67	65	55	66	63	46	51	37	61	79	75	67	67	68	73	67	65	68	72	59	48	57	57	62	20	32	23	8	20	37	20	20
38419	2009-08-30	64	72	right	medium	medium	46	66	64	55	66	63	46	43	37	58	68	75	67	60	68	65	67	65	68	58	59	34	57	57	42	20	32	23	8	20	37	20	20
38419	2009-02-22	60	72	right	medium	medium	46	61	60	48	66	58	46	43	37	53	65	75	67	60	68	61	67	61	68	56	34	34	37	57	42	20	32	23	8	20	37	20	20
38419	2008-08-30	57	63	right	medium	medium	31	57	53	36	66	59	46	43	37	54	62	67	67	60	68	58	67	58	67	54	34	37	37	57	37	20	32	23	8	20	37	20	20
38419	2007-02-22	57	63	right	medium	medium	31	57	53	36	66	59	46	43	37	54	62	67	67	60	68	58	67	58	67	54	34	37	37	57	37	20	32	23	8	20	37	20	20
38347	2010-08-30	63	64	right	\N	\N	66	53	61	62	48	53	63	60	63	58	62	67	61	60	62	71	63	70	64	61	64	63	61	65	57	61	63	62	5	5	13	12	10
38347	2009-08-30	63	64	right	\N	\N	66	53	61	62	48	58	63	60	63	60	62	67	61	60	62	71	63	70	64	61	64	64	68	65	62	60	62	62	12	20	63	20	20
38347	2007-08-30	63	64	right	\N	\N	66	53	61	62	48	58	63	60	63	60	62	67	61	60	62	71	63	70	64	61	64	64	68	65	62	60	62	62	12	20	63	20	20
38347	2007-02-22	63	64	right	\N	\N	66	53	61	62	48	58	63	62	63	60	62	67	61	60	62	71	63	70	64	61	64	64	68	65	62	60	62	62	12	11	63	13	11
27364	2016-05-05	65	65	right	medium	medium	63	41	48	65	50	66	63	61	67	68	65	54	69	67	77	72	72	72	64	61	73	64	58	63	72	67	62	58	14	14	10	9	8
27364	2015-10-16	65	65	right	medium	medium	59	41	48	65	50	66	60	61	67	68	65	54	69	67	77	72	72	72	64	61	73	64	58	63	72	67	62	58	14	14	10	9	8
27364	2015-09-21	65	66	right	medium	medium	59	41	48	65	50	66	60	61	67	68	65	54	69	67	77	72	72	72	64	61	73	64	58	63	72	67	62	58	14	14	10	9	8
27364	2015-01-09	64	67	right	medium	medium	58	40	47	64	49	65	59	60	66	67	65	54	69	66	78	71	71	72	63	60	72	63	57	62	71	66	61	57	13	13	9	8	7
27364	2014-10-02	64	67	right	medium	medium	58	40	47	64	49	65	59	60	66	67	65	61	69	66	78	71	71	72	63	60	72	63	57	62	71	66	61	57	13	13	9	8	7
27364	2014-09-18	64	69	right	medium	medium	58	40	47	64	49	65	59	60	66	67	65	61	69	66	78	71	71	72	63	60	72	63	57	62	71	66	61	57	13	13	9	8	7
27364	2014-04-25	64	69	right	medium	medium	58	40	47	64	49	65	59	60	66	67	65	61	69	66	78	71	71	69	63	60	72	63	57	62	71	66	61	57	13	13	9	8	7
27364	2014-02-07	65	69	right	medium	medium	58	40	47	65	49	65	59	60	66	67	65	61	69	66	78	71	71	69	63	60	72	64	57	64	71	66	65	60	13	13	9	8	7
27364	2014-01-10	65	69	right	medium	medium	58	40	47	65	49	65	59	60	66	67	65	61	69	66	78	71	71	69	63	60	72	64	57	64	71	66	65	60	13	13	9	8	7
27364	2013-12-13	65	69	right	medium	medium	58	40	47	65	49	65	59	60	66	67	65	61	69	66	78	71	71	69	63	60	72	64	57	64	71	66	65	60	13	13	9	8	7
27364	2013-09-20	66	70	right	medium	medium	58	40	47	67	49	65	59	60	68	67	65	61	69	68	78	71	71	69	63	60	72	64	57	66	71	71	65	60	13	13	9	8	7
27364	2013-05-17	66	71	right	medium	medium	58	40	47	67	49	65	59	60	68	67	65	61	69	68	78	71	71	69	63	60	72	64	57	66	71	71	65	60	13	13	9	8	7
27364	2013-04-19	66	71	right	medium	medium	58	40	47	67	49	65	59	60	68	67	65	61	69	68	78	71	71	69	63	60	72	64	57	66	71	71	65	60	13	13	9	8	7
27364	2013-03-01	67	71	right	medium	medium	58	40	47	69	49	65	59	60	71	67	65	61	69	68	78	71	71	69	63	60	72	64	57	69	71	71	65	60	13	13	9	8	7
27364	2013-02-15	67	71	right	medium	medium	58	40	47	69	49	65	59	60	71	67	65	61	69	68	78	71	71	69	63	60	72	64	59	69	71	71	65	60	13	13	9	8	7
27364	2012-08-31	66	72	right	medium	medium	58	51	47	69	49	65	59	60	68	67	65	61	69	67	78	71	71	69	63	60	72	64	59	68	71	71	65	60	13	13	9	8	7
27364	2012-02-22	68	74	right	medium	high	63	51	66	67	47	65	59	61	67	67	65	61	69	73	71	71	71	70	63	60	73	66	54	71	73	71	65	66	13	13	9	8	7
27364	2011-08-30	71	76	right	medium	high	65	50	66	72	47	65	68	68	70	68	69	63	70	75	70	73	73	82	68	62	73	66	54	74	75	71	65	68	13	13	9	8	7
27364	2011-02-22	69	76	right	medium	high	62	50	52	72	47	65	68	68	67	66	71	70	71	78	74	69	60	77	71	62	72	66	54	69	75	67	70	70	13	13	9	8	7
27364	2010-08-30	69	76	right	medium	high	62	50	52	72	47	65	63	64	67	66	68	71	71	78	74	69	60	77	72	62	72	66	54	69	75	67	70	70	13	13	9	8	7
27364	2010-02-22	69	74	right	medium	high	55	50	58	72	47	59	63	62	59	69	61	64	71	67	74	69	60	77	69	54	76	75	72	69	73	73	68	70	17	21	59	21	21
27364	2009-08-30	69	75	right	medium	high	55	50	58	72	47	59	63	62	59	69	67	71	71	67	74	69	60	77	69	54	76	75	72	69	73	73	68	70	17	21	59	21	21
27364	2009-02-22	71	80	right	medium	high	67	45	64	74	47	53	63	56	71	71	60	62	71	76	74	64	60	77	66	63	74	76	72	69	71	71	69	70	7	21	71	21	21
27364	2008-08-30	72	80	right	medium	high	69	45	67	76	47	53	63	56	73	72	72	74	71	76	74	64	60	77	66	63	78	71	72	69	71	72	69	70	7	21	73	21	21
27364	2007-08-30	70	83	right	medium	high	74	30	64	78	47	53	63	54	67	72	72	73	71	78	74	61	60	76	64	58	76	67	70	69	76	69	68	70	7	21	67	21	21
27364	2007-02-22	69	84	right	medium	high	75	26	64	78	47	51	63	76	66	72	68	71	71	78	74	58	60	76	63	56	75	67	70	69	76	63	67	70	7	12	66	6	10
12099	2010-08-30	62	67	right	\N	\N	57	58	23	64	61	72	51	62	54	67	74	72	73	67	53	58	65	65	37	64	26	43	57	58	54	31	37	38	7	5	6	14	14
12099	2010-02-22	64	67	right	\N	\N	61	60	33	65	61	69	51	61	57	64	75	77	73	70	53	60	65	70	39	64	30	58	65	58	66	21	27	38	4	20	57	20	20
12099	2009-08-30	66	67	right	\N	\N	61	60	33	67	61	72	51	61	57	69	75	77	73	70	53	60	65	70	39	64	30	58	65	58	67	21	27	38	4	20	57	20	20
12099	2008-08-30	65	67	right	\N	\N	61	60	33	67	61	72	51	61	57	69	72	74	73	70	53	60	65	62	39	64	30	58	65	58	67	21	27	38	4	20	57	20	20
12099	2007-08-30	66	67	right	\N	\N	64	57	43	62	61	65	51	52	57	69	72	74	73	78	53	51	65	62	39	59	51	41	44	58	50	31	27	38	4	20	57	20	20
12099	2007-02-22	66	67	right	\N	\N	64	57	43	62	61	65	51	52	57	69	72	74	73	78	53	51	65	62	39	59	51	41	44	58	50	31	27	38	4	20	57	20	20
13423	2016-04-07	72	72	right	medium	high	67	47	78	58	37	37	54	67	54	48	32	48	33	61	34	79	58	59	87	54	88	75	49	43	72	69	71	73	6	16	14	7	6
13423	2015-09-21	72	72	right	medium	high	67	47	78	58	37	37	54	67	54	48	32	53	33	61	34	79	60	62	87	54	88	75	49	43	72	69	71	73	6	16	14	7	6
13423	2014-10-02	70	70	right	medium	high	66	46	77	57	36	36	53	66	53	47	33	54	33	60	34	78	60	62	87	53	87	64	48	42	71	66	68	70	5	15	13	6	5
13423	2014-09-18	71	71	right	medium	high	66	46	79	60	36	36	53	66	53	50	33	54	33	60	34	78	60	62	87	53	87	66	48	56	71	67	69	71	5	15	13	6	5
13423	2014-04-11	71	71	right	medium	high	66	46	81	61	36	36	53	66	53	51	48	56	41	60	38	78	58	73	88	53	88	66	48	56	71	66	70	71	5	15	13	6	5
13423	2013-09-20	71	71	right	medium	high	66	46	81	61	36	36	53	66	53	51	48	56	41	60	38	78	58	73	88	53	88	66	48	56	71	66	70	71	5	15	13	6	5
13423	2013-03-15	71	71	right	medium	high	66	46	81	61	36	36	53	66	53	51	48	56	41	60	38	78	58	73	88	53	91	66	48	56	71	66	70	71	5	15	13	6	5
13423	2013-02-15	72	72	right	medium	high	66	46	81	61	36	38	38	48	53	53	48	56	43	61	48	78	59	76	88	53	93	67	51	56	71	66	71	71	5	15	13	6	5
13423	2012-08-31	71	71	right	medium	high	66	46	83	61	36	36	38	48	53	51	48	68	41	63	46	78	62	78	88	53	96	68	56	53	71	71	74	73	5	15	13	6	5
13423	2012-02-22	70	70	right	medium	high	66	46	83	61	36	36	38	48	53	48	48	63	43	63	46	78	62	71	88	53	83	69	56	51	71	73	76	73	5	15	13	6	5
13423	2011-08-30	69	69	right	medium	high	63	46	83	61	36	38	46	23	53	48	47	64	41	61	52	78	62	68	88	53	83	66	53	48	71	71	78	73	5	15	13	6	5
13423	2011-02-22	71	73	right	medium	high	63	46	83	61	36	38	46	23	53	48	53	66	51	61	83	78	56	66	81	53	80	71	56	60	68	73	78	74	5	15	13	6	5
13423	2010-08-30	71	73	right	medium	high	63	39	81	61	36	38	46	23	53	48	53	68	48	61	91	78	64	77	91	53	96	71	38	60	68	68	73	71	5	15	13	6	5
13423	2009-08-30	69	71	right	medium	high	63	36	81	61	36	36	46	23	53	48	51	66	48	61	91	73	64	78	91	53	96	58	56	60	61	68	71	71	13	24	53	24	24
13423	2008-08-30	69	71	right	medium	high	63	36	76	61	36	37	46	23	54	51	48	61	48	60	91	73	64	81	91	53	93	58	62	60	61	68	73	71	13	24	54	24	24
13423	2007-08-30	70	71	right	medium	high	67	56	76	61	36	59	46	56	54	54	68	68	48	62	91	67	64	79	85	63	78	82	59	60	62	71	73	71	13	24	54	24	24
13423	2007-02-22	57	59	right	medium	high	54	49	64	44	36	34	46	50	49	59	64	63	48	62	91	54	64	50	63	50	52	82	59	60	50	49	64	71	13	12	49	7	7
47411	2012-02-22	67	70	right	high	medium	76	54	53	73	56	71	75	68	70	72	75	74	79	71	75	65	76	66	58	66	65	63	64	65	54	65	68	67	10	6	13	10	13
47411	2011-08-30	68	70	right	high	medium	76	54	53	74	56	71	75	68	71	72	75	74	79	71	75	65	76	66	58	66	66	63	63	66	54	66	68	67	10	6	13	10	13
47411	2011-02-22	69	78	right	high	medium	73	54	63	72	56	68	73	68	69	72	73	74	72	71	66	65	68	72	63	66	63	67	66	69	54	66	67	68	10	6	13	10	13
47411	2010-08-30	72	78	right	high	medium	77	46	58	74	56	72	73	68	71	74	75	76	75	71	63	65	68	75	58	66	64	67	66	74	54	71	72	72	10	6	13	10	13
47411	2009-08-30	73	78	right	high	medium	77	58	60	75	56	74	73	68	72	74	75	72	75	74	63	65	68	75	65	65	65	68	72	74	72	73	74	72	8	20	72	20	20
47411	2009-02-22	71	74	right	high	medium	74	58	56	71	56	72	73	62	69	72	71	72	75	72	63	65	68	70	62	60	60	66	69	74	68	71	72	72	8	20	69	20	20
47411	2008-08-30	69	74	right	high	medium	73	58	56	68	56	72	73	58	67	72	68	68	75	69	63	62	68	65	56	59	62	63	71	74	65	69	70	72	8	20	67	20	20
47411	2007-08-30	65	67	right	high	medium	62	36	52	63	56	67	73	43	57	68	68	68	75	63	63	62	68	65	52	49	62	59	63	74	57	63	62	72	8	20	57	20	20
47411	2007-02-22	65	67	right	high	medium	62	36	52	63	56	67	73	43	57	68	68	68	75	63	63	62	68	65	52	49	62	59	63	74	57	63	62	72	8	20	57	20	20
33595	2009-08-30	65	78	right	\N	\N	69	47	62	73	\N	61	\N	74	75	68	45	52	\N	62	\N	70	\N	65	71	59	63	76	80	\N	77	62	68	\N	6	20	75	20	20
33595	2007-08-30	65	78	right	\N	\N	69	47	62	73	\N	61	\N	74	75	68	45	52	\N	62	\N	70	\N	65	71	59	63	76	80	\N	77	62	68	\N	6	20	75	20	20
33595	2007-02-22	70	75	right	\N	\N	68	45	60	71	\N	67	\N	75	65	74	63	60	\N	75	\N	73	\N	68	70	57	74	76	80	\N	75	70	75	\N	6	10	65	11	9
38945	2013-05-31	64	64	left	medium	low	67	52	57	67	66	67	72	71	69	69	38	32	45	55	51	72	50	58	73	66	74	57	65	68	70	42	48	43	14	8	9	13	13
38945	2013-05-17	64	64	left	medium	medium	67	52	57	67	66	67	72	71	69	69	38	32	45	55	51	72	50	58	73	66	74	57	65	68	70	42	48	43	14	8	9	13	13
38945	2013-04-12	64	64	left	medium	medium	67	52	57	67	66	67	72	71	69	69	38	32	45	55	51	72	50	58	73	66	74	57	65	68	70	42	48	43	14	8	9	13	13
38945	2013-03-28	65	65	left	medium	medium	69	52	57	70	66	67	72	71	71	69	38	32	45	55	51	75	55	62	79	69	74	57	65	68	70	42	52	45	14	8	9	13	13
38945	2013-02-15	65	65	left	medium	medium	69	52	57	70	66	67	72	71	71	69	38	32	45	55	51	75	55	62	79	69	74	57	65	68	70	42	52	45	14	8	9	13	13
38945	2012-08-31	66	66	left	medium	medium	73	58	57	72	71	67	74	71	76	71	38	33	47	52	51	76	55	59	79	71	76	54	66	72	70	24	37	39	14	8	9	13	13
38945	2011-02-22	66	66	left	medium	medium	73	58	57	72	71	67	74	71	76	71	38	33	47	52	51	76	55	59	79	71	76	54	66	72	70	24	37	39	14	8	9	13	13
38945	2010-08-30	67	66	left	medium	medium	71	58	57	69	71	67	74	71	72	71	38	33	47	52	74	76	55	60	78	71	76	54	66	72	70	24	37	39	14	8	9	13	13
38945	2010-02-22	68	66	left	medium	medium	71	58	57	69	71	67	74	71	72	71	38	33	47	52	74	76	55	60	78	71	76	63	71	72	70	24	37	39	11	20	72	20	20
38945	2009-08-30	68	66	left	medium	medium	73	51	57	74	71	67	74	71	72	72	38	33	47	52	74	76	55	60	78	72	66	63	71	72	69	24	27	39	11	20	72	20	20
38945	2008-08-30	68	66	left	medium	medium	73	41	57	74	71	67	74	71	72	72	38	33	47	47	74	76	55	60	78	72	36	53	71	72	69	24	27	39	11	20	72	20	20
38945	2007-08-30	68	77	left	medium	medium	73	41	58	81	71	67	74	75	76	72	73	66	47	44	74	71	55	60	61	72	59	53	72	72	69	24	27	39	11	20	76	20	20
38945	2007-02-22	68	77	left	medium	medium	73	41	58	81	71	67	74	75	76	72	73	66	47	44	74	71	55	60	61	72	59	53	72	72	69	24	27	39	11	20	76	20	20
148297	2013-04-12	56	60	left	medium	medium	19	8	16	13	13	16	15	10	20	13	33	38	57	56	49	26	58	34	53	10	24	15	17	6	14	11	9	12	62	50	55	51	60
148297	2013-02-15	56	60	left	medium	medium	19	8	16	13	13	16	15	10	20	13	33	38	61	56	55	26	58	46	65	10	24	15	17	19	14	11	9	12	62	50	55	51	60
148297	2012-08-31	51	57	left	medium	medium	19	8	16	13	13	16	15	10	20	13	33	38	61	56	55	26	58	46	65	10	24	15	17	19	14	11	9	12	53	45	49	51	56
148297	2008-08-30	51	57	left	medium	medium	19	8	16	13	13	16	15	10	20	13	33	38	61	56	55	26	58	46	65	10	24	15	17	19	14	11	9	12	53	45	49	51	56
148297	2007-02-22	51	57	left	medium	medium	19	8	16	13	13	16	15	10	20	13	33	38	61	56	55	26	58	46	65	10	24	15	17	19	14	11	9	12	53	45	49	51	56
38380	2010-08-30	64	69	right	\N	\N	53	29	65	66	46	53	54	53	61	63	66	67	65	64	68	60	65	67	63	52	56	66	24	64	45	63	67	66	5	9	8	12	9
38380	2010-02-22	67	69	right	\N	\N	56	40	67	66	46	53	54	51	61	66	68	69	65	66	68	61	65	67	68	52	63	65	66	64	65	67	69	66	12	23	61	23	23
38380	2009-08-30	68	71	right	\N	\N	56	40	67	66	46	62	54	51	58	68	68	72	65	67	68	61	65	66	66	52	68	64	66	64	65	68	70	66	12	23	58	23	23
38380	2009-02-22	68	71	right	\N	\N	56	40	67	66	46	62	54	51	58	68	68	72	65	67	68	61	65	66	66	52	68	64	66	64	65	68	70	66	12	23	58	23	23
38380	2008-08-30	68	71	right	\N	\N	56	40	67	66	46	62	54	51	58	68	68	72	65	67	68	61	65	66	66	52	68	64	66	64	65	68	70	66	12	23	58	23	23
38380	2007-08-30	68	71	right	\N	\N	56	40	67	66	46	66	54	51	58	68	68	72	65	67	68	61	65	66	66	52	68	64	66	64	65	68	70	66	12	23	58	23	23
38380	2007-02-22	68	71	right	\N	\N	56	40	67	66	46	66	54	65	58	68	68	72	65	67	68	61	65	66	66	52	68	64	66	64	65	68	70	66	12	6	58	12	7
39890	2012-02-22	64	64	left	medium	medium	12	15	13	31	17	13	8	18	32	25	46	36	43	66	41	35	62	31	68	12	15	26	13	35	22	10	12	19	61	64	61	68	62
39890	2011-08-30	66	66	left	medium	medium	12	15	13	31	17	13	8	18	32	25	58	56	53	67	46	35	67	51	71	12	15	21	18	35	22	10	12	19	66	65	62	68	67
39890	2011-02-22	66	69	left	medium	medium	12	15	13	31	17	22	21	18	41	37	58	56	53	67	68	45	67	51	71	12	12	21	18	35	48	9	12	19	66	65	62	68	67
39890	2010-08-30	68	69	left	medium	medium	12	15	34	46	17	22	21	18	49	37	61	58	58	67	69	56	68	56	73	24	12	21	18	68	48	22	28	19	68	66	64	68	70
39890	2010-02-22	67	70	left	medium	medium	20	20	34	46	17	22	21	18	64	37	53	48	58	67	69	56	68	66	70	24	20	54	13	68	66	22	28	19	68	66	64	65	70
39890	2009-08-30	67	70	left	medium	medium	20	20	34	46	17	22	21	18	64	37	53	48	58	67	69	56	68	66	70	24	20	54	13	68	66	22	28	19	68	66	64	65	70
39890	2009-02-22	66	68	left	medium	medium	20	20	34	46	17	22	21	18	62	37	53	48	58	67	69	56	68	66	70	24	20	54	13	68	66	22	28	19	67	64	62	63	70
39890	2008-08-30	64	69	left	medium	medium	32	25	24	33	17	32	21	28	63	27	42	45	58	55	69	36	68	71	70	20	54	54	35	68	57	32	28	19	67	55	63	63	72
39890	2007-08-30	62	63	right	medium	medium	32	25	24	33	17	32	21	28	54	27	42	45	58	55	69	36	68	58	48	20	54	54	35	68	57	32	28	19	64	55	54	63	72
39890	2007-02-22	62	63	right	medium	medium	32	25	24	33	17	32	21	28	54	27	42	45	58	55	69	36	68	58	48	20	54	54	35	68	57	32	28	19	64	55	54	63	72
12473	2013-11-15	63	63	right	medium	medium	57	23	64	66	25	36	36	37	61	50	73	77	56	67	60	55	70	72	73	33	67	64	36	54	39	55	61	64	7	9	6	6	8
12473	2013-09-20	63	63	right	medium	medium	57	23	64	66	25	36	36	37	61	50	73	77	56	67	60	55	70	72	73	33	67	64	36	54	39	55	61	64	7	9	6	6	8
12473	2013-05-17	63	63	right	medium	medium	57	23	64	66	11	36	36	37	61	50	73	77	56	67	60	55	70	72	73	33	67	64	36	54	39	55	61	64	7	9	6	6	8
12473	2013-05-10	62	63	right	medium	medium	57	23	64	65	11	36	36	37	61	50	73	77	56	67	60	55	70	72	73	33	67	64	36	54	39	52	61	63	7	9	6	6	8
12473	2013-05-03	62	63	right	medium	medium	57	23	64	61	11	36	36	37	61	50	73	77	56	67	60	55	70	72	73	33	67	64	36	52	39	52	61	63	7	9	6	6	8
12473	2013-02-15	64	68	right	medium	medium	57	23	68	64	11	36	36	37	64	50	73	77	56	67	60	55	70	72	73	33	67	64	36	52	39	55	64	67	7	9	6	6	8
12473	2012-08-31	68	68	right	medium	medium	57	23	71	64	11	36	36	37	66	52	73	77	56	67	60	55	70	72	73	33	67	72	36	56	39	65	69	71	7	9	6	6	8
12473	2012-02-22	72	73	right	medium	medium	57	23	71	64	11	36	36	37	66	52	74	73	56	71	60	55	70	71	73	33	73	74	36	56	39	67	77	79	7	9	6	6	8
12473	2011-08-30	72	73	right	medium	medium	57	23	71	64	11	36	36	37	66	52	74	73	56	71	60	55	70	72	73	33	73	74	36	56	39	69	77	79	7	9	6	6	8
12473	2011-02-22	72	73	right	medium	medium	57	23	72	60	11	32	36	37	65	52	67	72	57	72	71	55	67	72	74	33	73	78	36	72	39	71	77	80	7	9	6	6	8
12473	2010-08-30	72	73	right	medium	medium	56	22	72	59	11	32	36	37	62	52	67	72	57	55	65	55	67	72	72	33	73	77	47	53	39	73	77	79	7	9	6	6	8
12473	2010-02-22	70	72	right	medium	medium	43	22	72	47	11	32	36	37	45	52	67	72	57	55	65	55	67	72	72	33	73	56	57	53	58	73	75	79	4	21	45	21	21
12473	2009-08-30	69	74	right	medium	medium	58	22	72	52	11	32	36	37	54	52	67	72	57	55	65	55	67	73	74	33	73	56	57	53	58	68	73	79	4	21	54	21	21
12473	2009-02-22	65	69	right	medium	medium	41	22	65	45	11	32	36	37	46	33	67	72	57	55	65	55	67	75	72	33	73	46	42	53	56	64	68	79	4	21	46	21	21
12473	2008-08-30	64	69	right	medium	medium	46	22	65	42	11	32	36	37	53	33	67	72	57	60	65	55	67	77	72	33	73	51	47	53	65	64	65	79	4	21	53	21	21
12473	2007-02-22	64	69	right	medium	medium	46	22	65	42	11	32	36	37	53	33	67	72	57	60	65	55	67	77	72	33	73	51	47	53	65	64	65	79	4	21	53	21	21
38322	2015-09-21	64	64	right	medium	medium	63	37	59	65	37	65	56	46	58	58	54	54	57	63	67	67	65	72	66	63	70	64	55	52	44	65	65	69	7	15	9	11	7
38322	2014-03-28	64	64	right	medium	medium	63	37	59	65	37	65	56	46	58	58	54	54	57	63	67	67	65	72	66	63	70	64	55	52	44	65	65	69	7	15	9	11	7
38322	2014-01-24	65	65	right	high	medium	63	37	59	65	37	65	56	46	58	58	54	54	57	65	67	67	65	72	66	63	70	64	55	52	44	64	64	67	7	15	9	11	7
38322	2013-09-20	65	65	right	high	medium	63	37	59	65	37	65	56	46	58	58	54	54	57	65	67	67	65	72	66	63	70	64	55	52	44	64	64	67	7	15	9	11	7
38322	2013-05-24	65	65	right	high	medium	63	37	59	65	37	65	56	46	58	60	54	54	57	65	67	67	65	72	66	63	70	64	55	52	44	64	64	67	7	15	9	11	7
38322	2013-02-15	65	65	right	high	medium	68	37	59	65	37	65	56	46	58	60	54	54	57	65	67	67	65	72	66	63	70	64	55	52	44	64	64	67	7	15	9	11	7
38322	2012-08-31	65	66	right	high	medium	68	37	59	65	37	65	56	46	58	60	69	67	57	65	74	67	73	81	66	63	70	64	55	52	44	63	64	66	7	15	9	11	7
38322	2012-02-22	65	66	right	medium	medium	67	38	59	62	37	62	56	46	56	58	69	66	57	64	74	67	75	85	56	63	70	62	55	52	44	62	63	65	7	15	9	11	7
38322	2011-08-30	63	66	right	high	medium	67	38	56	62	37	62	56	46	57	60	69	66	57	59	74	67	75	81	56	63	70	56	52	60	44	60	61	63	7	15	9	11	7
38322	2011-02-22	61	66	right	high	medium	67	36	56	62	32	62	56	46	57	57	69	71	63	59	62	62	67	76	59	63	66	56	52	60	44	59	60	62	7	15	9	11	7
38322	2010-08-30	64	66	right	high	medium	67	36	54	63	32	51	56	46	58	57	69	71	63	59	62	60	67	76	59	60	74	56	58	60	41	71	62	65	7	15	9	11	7
38322	2010-02-22	64	67	right	high	medium	67	36	54	63	32	51	56	46	58	57	69	71	63	59	62	60	67	76	59	60	74	63	58	60	60	71	62	65	11	25	58	25	25
38322	2009-08-30	64	67	right	high	medium	67	36	54	63	32	51	56	46	58	57	69	71	63	59	62	60	67	76	59	60	74	63	58	60	60	71	62	65	11	25	58	25	25
38322	2008-08-30	62	67	right	high	medium	57	36	54	56	32	51	56	46	51	53	67	69	63	59	62	60	67	75	59	51	74	63	54	60	60	71	62	65	11	25	51	25	25
38322	2007-08-30	62	67	right	high	medium	57	36	54	56	32	51	56	46	51	53	67	69	63	59	62	60	67	75	59	51	74	63	54	60	60	71	62	65	11	25	51	25	25
38322	2007-02-22	60	63	right	high	medium	51	36	51	56	32	47	56	60	38	52	69	65	63	49	62	57	67	68	54	51	70	63	54	60	60	67	62	65	11	10	38	15	11
38794	2015-10-16	66	66	left	medium	low	52	65	67	60	64	60	59	52	49	63	72	77	65	63	63	69	70	62	74	61	44	25	68	61	65	18	21	15	9	8	9	8	7
38794	2015-09-21	66	68	left	medium	low	52	65	67	60	64	60	59	52	49	63	72	77	65	63	63	69	70	62	74	61	44	25	68	61	65	18	21	15	9	8	9	8	7
38794	2015-07-31	65	66	left	medium	low	51	62	65	59	63	59	58	51	48	62	71	76	65	62	63	68	70	62	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2015-07-24	65	68	left	medium	low	51	65	67	59	63	59	58	51	48	62	72	77	65	62	63	68	70	62	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2015-01-30	65	66	left	medium	low	51	62	65	59	63	59	58	51	48	62	71	76	65	62	63	68	70	62	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2014-10-31	65	66	left	medium	low	51	62	65	59	63	59	58	51	48	62	71	76	65	62	63	68	70	62	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2014-09-12	65	66	left	medium	low	51	63	65	59	63	59	58	51	48	62	71	76	65	62	63	66	70	62	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2014-08-15	65	72	left	medium	low	51	63	65	59	63	59	58	51	48	62	71	76	65	62	63	66	70	62	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2014-08-08	64	66	left	medium	low	51	63	65	59	63	59	58	51	48	62	67	68	65	62	57	66	70	52	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2014-07-18	64	66	left	medium	low	51	63	65	59	63	59	58	51	48	62	67	70	65	62	57	66	67	52	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2013-12-13	64	66	left	medium	low	51	63	65	59	63	59	58	51	48	62	67	70	65	62	57	66	67	52	74	60	43	24	67	60	64	25	20	25	8	7	8	7	6
38794	2013-11-15	67	70	left	medium	low	51	67	65	59	66	59	58	51	48	62	71	72	67	67	60	66	70	52	74	60	43	24	70	60	64	25	20	25	8	7	8	7	6
38794	2013-09-20	68	72	left	medium	low	51	67	65	59	67	59	58	51	48	66	73	75	72	70	60	66	75	64	72	60	43	24	71	60	64	25	20	25	8	7	8	7	6
38794	2013-06-21	68	72	left	medium	low	51	67	65	59	67	59	58	51	48	66	73	75	72	70	60	66	74	64	72	60	43	24	71	60	64	17	20	14	8	7	8	7	6
38794	2013-05-10	68	72	left	medium	low	51	67	65	59	67	59	58	51	48	66	73	75	72	70	60	66	74	64	72	60	43	24	71	60	64	17	20	14	8	7	8	7	6
38794	2013-03-22	70	72	left	medium	low	51	71	70	61	67	59	58	51	48	66	73	75	72	70	60	72	74	64	72	64	43	24	74	60	64	17	20	14	8	7	8	7	6
38794	2013-02-22	70	72	left	medium	low	51	71	70	61	67	59	58	51	48	66	76	78	74	70	63	72	82	64	72	64	43	24	74	60	64	17	20	14	8	7	8	7	6
38794	2013-02-15	70	72	left	medium	low	51	71	70	61	67	59	58	51	48	66	76	78	74	70	63	72	82	64	72	64	43	24	74	60	64	17	20	14	8	7	8	7	6
38794	2012-08-31	72	74	left	medium	low	51	72	70	61	68	59	58	51	48	66	78	80	76	74	62	73	83	68	74	64	43	24	78	60	64	17	20	14	8	7	8	7	6
38794	2012-02-22	73	75	left	medium	low	51	74	70	59	71	60	58	51	48	64	77	78	76	81	62	72	83	68	74	64	43	24	82	64	64	17	20	14	8	7	8	7	6
38794	2011-08-30	72	75	left	medium	low	51	74	71	64	71	63	58	51	48	66	82	82	76	72	62	72	83	68	74	66	43	24	72	64	64	17	20	14	8	7	8	7	6
38794	2011-02-22	70	73	left	medium	low	51	73	67	62	63	63	61	48	56	66	76	78	71	72	72	69	73	68	73	64	61	33	69	62	62	17	20	14	8	7	8	7	6
38794	2010-08-30	66	71	left	medium	low	49	68	65	62	56	61	60	43	56	64	69	71	66	64	72	67	67	65	73	62	61	33	67	58	53	17	20	14	8	7	8	7	6
38794	2010-02-22	64	69	left	medium	low	49	66	60	54	56	61	60	43	48	64	69	71	66	64	72	67	67	65	73	60	52	48	61	58	54	22	22	14	4	22	48	22	22
38794	2009-08-30	64	69	left	medium	low	49	63	62	56	56	63	60	43	48	66	70	72	66	64	72	67	67	65	73	60	52	48	58	58	54	22	22	14	4	22	48	22	22
38794	2009-02-22	63	68	left	medium	low	49	63	62	53	56	60	60	43	48	61	68	69	66	61	72	67	67	60	73	60	52	48	51	58	54	22	22	14	4	22	48	22	22
38794	2008-08-30	59	68	left	medium	low	47	59	60	48	56	57	60	33	52	54	67	64	66	59	72	64	67	57	70	51	52	43	49	58	49	27	40	14	4	22	52	22	22
38794	2007-02-22	59	68	left	medium	low	47	59	60	48	56	57	60	33	52	54	67	64	66	59	72	64	67	57	70	51	52	43	49	58	49	27	40	14	4	22	52	22	22
93054	2010-08-30	61	67	left	\N	\N	62	58	50	61	50	62	50	60	60	62	72	70	71	65	57	64	62	65	55	54	64	57	59	60	48	57	58	59	9	9	5	12	10
93054	2010-02-22	63	67	left	\N	\N	62	58	50	61	50	62	50	60	60	62	72	70	71	65	57	64	62	65	55	54	64	57	60	60	65	52	55	59	1	21	60	21	21
93054	2009-08-30	64	67	left	\N	\N	65	58	50	62	50	62	50	60	60	62	74	73	71	67	57	64	62	68	55	54	66	60	60	60	65	52	55	59	1	21	60	21	21
93054	2009-02-22	62	67	left	\N	\N	60	50	45	55	50	62	50	51	56	60	75	74	71	67	57	60	62	69	51	49	66	50	52	60	56	52	55	59	1	21	56	21	21
93054	2008-08-30	62	67	left	\N	\N	60	50	45	55	50	62	50	51	56	60	75	74	71	67	57	60	62	69	51	49	66	50	52	60	56	52	55	59	1	21	56	21	21
93054	2007-08-30	59	67	left	\N	\N	58	50	45	55	50	47	50	51	56	55	65	69	71	64	57	60	62	68	51	44	66	50	52	60	56	55	56	59	1	21	56	21	21
93054	2007-02-22	59	67	left	\N	\N	58	50	45	55	50	47	50	51	56	55	65	69	71	64	57	60	62	68	51	44	66	50	52	60	56	55	56	59	1	21	56	21	21
46552	2016-05-12	74	74	right	medium	low	72	72	62	75	75	75	74	70	68	77	69	67	74	76	72	73	67	47	57	76	33	18	77	75	68	14	29	24	9	16	11	13	8
46552	2016-04-28	74	75	right	medium	low	72	72	62	75	75	75	74	70	68	77	69	67	74	76	72	73	67	47	57	76	33	18	77	75	68	14	29	24	9	16	11	13	8
46552	2016-01-07	74	75	right	medium	low	72	74	62	75	75	78	74	70	68	79	71	70	76	78	72	76	67	47	57	77	33	18	78	75	68	14	29	24	9	16	11	13	8
46552	2015-12-10	74	75	right	medium	low	72	74	62	75	75	78	74	70	68	79	71	70	76	78	72	76	67	47	57	77	33	18	78	75	68	14	29	24	9	16	11	13	8
46552	2015-10-09	74	75	right	medium	low	72	76	62	75	75	78	74	70	68	79	71	70	76	80	72	76	67	47	57	77	33	18	78	75	68	14	29	24	9	16	11	13	8
46552	2015-10-02	75	76	right	medium	low	72	76	62	75	75	80	74	70	68	81	73	72	76	80	72	76	67	42	57	77	33	18	78	75	68	14	29	24	9	16	11	13	8
46552	2015-09-21	75	76	right	medium	low	72	76	62	75	75	80	74	70	68	81	73	72	76	81	72	76	67	42	57	77	33	18	78	75	68	14	29	24	9	16	11	13	8
46552	2015-03-20	75	77	right	medium	low	70	78	61	74	74	79	73	69	67	80	67	70	72	80	71	75	65	46	61	76	32	25	77	75	67	25	28	23	8	15	10	12	7
46552	2014-10-31	76	78	right	medium	low	70	78	61	74	74	79	73	69	67	80	76	75	78	80	71	75	70	56	61	76	32	25	77	75	67	25	28	23	8	15	10	12	7
46552	2014-10-02	76	78	right	medium	low	71	78	61	75	74	81	73	69	67	80	78	80	83	80	71	75	75	60	61	76	32	25	77	75	67	25	28	23	8	15	10	12	7
46552	2014-09-18	76	78	right	medium	low	71	78	61	75	74	81	73	69	67	80	78	80	81	80	71	75	75	60	61	76	32	25	77	75	67	25	28	23	8	15	10	12	7
46552	2014-04-25	78	80	right	medium	low	72	76	53	75	74	82	73	69	71	83	80	81	84	80	71	73	73	64	57	76	36	25	77	75	67	25	28	23	8	15	10	12	7
46552	2014-01-17	78	80	right	medium	low	72	76	53	75	74	82	73	69	71	83	80	81	84	80	71	73	73	64	57	76	36	25	77	75	67	25	28	23	8	15	10	12	7
46552	2013-12-13	78	80	right	medium	low	72	76	53	75	74	82	73	69	71	83	80	81	84	80	71	73	73	64	57	76	36	25	77	75	67	25	28	23	8	15	10	12	7
46552	2013-11-08	78	79	right	medium	low	72	76	53	75	74	82	73	69	71	83	80	81	84	80	71	73	73	64	57	76	36	25	77	75	67	25	28	23	8	15	10	12	7
46552	2013-10-25	78	79	right	medium	low	72	76	53	75	74	82	72	66	71	83	80	81	84	80	71	73	73	64	57	76	36	25	77	75	67	25	28	23	8	15	10	12	7
46552	2013-10-04	78	80	right	medium	low	72	76	53	75	74	82	72	66	71	83	82	81	84	80	71	73	73	69	58	76	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2013-09-20	78	81	right	medium	low	72	77	53	75	74	82	72	66	71	83	82	81	81	80	70	73	73	69	60	76	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2013-05-10	77	81	right	medium	low	73	77	53	76	73	82	72	66	71	83	82	81	81	80	70	73	72	69	60	76	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2013-03-22	78	81	right	medium	low	73	78	53	76	73	83	72	66	71	83	84	83	83	82	70	73	74	71	60	78	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2013-03-15	78	81	right	medium	low	73	78	53	76	73	83	72	66	71	83	84	83	83	82	70	73	74	71	60	78	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2013-02-15	78	81	right	medium	low	73	78	53	76	73	83	72	66	71	83	84	83	83	82	70	73	74	71	60	78	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2012-08-31	78	81	right	high	low	71	78	53	76	73	83	71	66	73	83	84	83	83	80	68	75	72	66	57	78	36	32	77	75	67	23	28	23	8	15	10	12	7
46552	2012-02-22	76	80	right	high	low	69	76	46	74	73	80	68	66	72	83	88	85	83	76	68	75	72	66	57	78	36	32	71	70	63	23	28	23	8	15	10	12	7
46552	2011-08-30	74	78	right	medium	low	69	69	48	73	67	78	66	66	71	76	86	83	81	71	68	74	72	66	56	73	43	26	67	68	64	14	28	23	8	15	10	12	7
46552	2010-08-30	73	78	right	medium	low	67	71	53	68	68	78	66	66	58	76	81	78	77	74	51	74	67	64	56	73	43	36	71	73	64	24	28	23	8	15	10	12	7
46552	2010-02-22	71	78	right	medium	low	67	71	56	69	68	76	66	66	57	74	78	76	77	70	51	72	67	65	47	73	33	58	62	73	63	24	28	23	16	22	57	22	22
46552	2009-08-30	72	78	right	medium	low	68	71	57	71	68	76	66	66	58	74	78	76	77	71	51	72	67	65	52	73	43	58	62	73	63	24	28	23	16	22	58	22	22
46552	2008-08-30	68	76	right	medium	low	61	68	56	63	68	73	66	61	53	71	78	73	77	67	51	70	67	65	42	66	32	42	49	73	56	24	22	23	6	22	53	22	22
46552	2007-02-22	68	76	right	medium	low	61	68	56	63	68	73	66	61	53	71	78	73	77	67	51	70	67	65	42	66	32	42	49	73	56	24	22	23	6	22	53	22	22
67959	2014-09-18	67	67	right	medium	medium	38	41	71	58	31	47	34	44	59	58	31	56	42	60	34	64	34	75	86	57	63	69	48	59	37	70	68	69	14	11	14	12	14
67959	2013-12-27	67	67	right	medium	medium	38	41	71	58	31	47	34	44	59	58	31	59	42	60	34	64	34	75	86	57	63	69	48	59	37	70	68	69	14	11	14	12	14
67959	2013-10-11	66	67	right	medium	medium	38	41	69	58	31	47	34	44	59	58	31	59	42	58	34	64	34	75	86	57	63	65	48	59	37	66	66	67	14	11	14	12	14
67959	2013-09-20	66	67	right	medium	medium	38	41	69	58	31	47	34	44	59	58	31	59	42	58	34	64	34	75	87	57	63	65	48	59	37	66	66	67	14	11	14	12	14
67959	2013-05-31	66	67	right	medium	medium	38	41	69	58	31	47	34	44	59	58	31	61	42	58	34	64	40	75	87	57	63	65	48	59	37	66	66	67	14	11	14	12	14
67959	2013-02-15	66	67	right	medium	medium	38	41	69	58	31	47	34	44	59	58	31	61	42	58	34	64	40	75	87	57	63	65	48	59	37	66	66	67	14	11	14	12	14
67959	2012-08-31	66	67	right	medium	medium	38	41	69	58	31	47	34	44	59	58	56	39	43	58	36	64	45	75	87	57	63	65	48	59	37	66	66	67	14	11	14	12	14
67959	2012-02-22	63	64	right	medium	medium	38	41	67	58	31	47	34	44	59	58	56	39	43	58	36	61	25	71	87	57	60	62	48	59	37	64	59	63	14	11	14	12	14
67959	2011-08-30	63	64	right	medium	medium	38	41	67	58	31	47	34	44	59	58	56	45	43	58	37	61	25	71	87	57	60	62	48	59	37	64	59	63	14	11	14	12	14
67959	2010-08-30	63	66	right	medium	medium	38	41	67	58	31	47	34	44	59	58	58	59	51	58	76	61	53	69	79	57	60	62	48	59	37	64	59	63	14	11	14	12	14
67959	2010-02-22	57	63	right	medium	medium	37	41	56	57	31	46	34	44	59	56	57	59	51	55	76	58	53	67	79	57	58	57	61	59	54	52	51	63	5	22	59	22	22
67959	2009-08-30	58	63	right	medium	medium	37	41	56	57	31	46	34	44	59	56	57	59	51	55	76	58	53	67	79	57	58	57	61	59	54	52	51	63	5	22	59	22	22
67959	2008-08-30	53	60	right	medium	medium	37	43	46	47	31	46	34	47	56	53	47	53	51	51	76	46	53	67	82	57	55	48	56	59	57	40	42	63	5	22	56	22	22
67959	2007-08-30	53	60	right	medium	medium	37	43	46	47	31	46	34	47	56	53	47	53	51	51	76	46	53	67	82	57	55	48	56	59	57	40	42	63	5	22	56	22	22
67959	2007-02-22	53	60	right	medium	medium	37	43	46	47	31	46	34	47	56	53	47	53	51	51	76	46	53	67	82	57	55	48	56	59	57	40	42	63	5	22	56	22	22
46666	2016-03-03	65	65	right	medium	medium	38	38	63	54	33	36	41	43	51	48	39	52	57	61	48	47	66	63	71	30	68	66	38	45	44	65	68	67	8	15	6	12	13
46666	2015-09-21	66	66	right	medium	medium	38	38	63	54	33	36	41	43	51	48	39	52	57	61	48	47	66	63	71	30	68	66	38	45	44	67	70	69	8	15	6	12	13
46666	2015-07-03	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2015-06-12	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2014-11-21	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2014-11-14	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2014-09-18	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2011-02-22	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2010-08-30	64	64	right	medium	medium	37	37	62	53	32	35	40	42	50	47	57	64	57	60	60	46	66	63	71	29	67	65	37	44	43	64	67	66	7	14	5	11	12
46666	2009-08-30	61	64	right	medium	medium	37	37	51	42	32	31	40	42	45	46	57	64	57	58	60	46	66	61	71	29	67	62	62	44	57	62	63	66	9	20	45	20	20
46666	2008-08-30	58	64	right	medium	medium	37	37	51	42	32	31	40	42	45	46	57	61	57	58	60	46	66	61	71	29	64	48	52	44	46	57	57	66	9	20	45	20	20
46666	2007-08-30	57	64	right	medium	medium	37	37	51	42	32	31	40	42	45	46	57	61	57	58	60	46	66	61	71	29	64	48	52	44	46	57	57	66	9	20	45	20	20
46666	2007-02-22	57	64	right	medium	medium	37	37	51	42	32	31	40	46	45	46	57	61	57	58	60	46	66	61	71	29	64	48	52	44	46	57	57	66	9	5	45	8	8
166575	2016-04-07	76	80	left	high	medium	69	72	47	74	67	82	72	73	72	77	85	84	84	73	85	71	73	91	47	72	71	35	72	75	68	29	27	34	9	15	12	11	7
166575	2015-10-09	77	81	left	high	medium	70	75	47	75	67	82	72	73	72	77	86	85	84	75	85	71	73	91	47	73	71	35	74	76	68	29	27	34	9	15	12	11	7
166575	2015-09-21	77	81	left	high	medium	70	75	47	75	67	82	72	73	72	76	86	85	84	74	85	71	73	91	47	73	71	35	74	76	68	29	27	34	9	15	12	11	7
166575	2015-05-01	75	82	left	high	medium	69	74	46	74	66	76	71	72	70	72	87	86	84	78	85	70	73	91	47	72	70	29	72	74	67	28	26	33	8	14	11	10	6
166575	2014-10-02	75	82	left	high	medium	69	74	46	74	66	76	71	72	70	72	87	86	84	78	85	70	73	91	47	72	70	29	72	74	67	28	26	33	8	14	11	10	6
166575	2014-09-18	75	82	left	high	medium	69	74	46	74	66	76	71	72	70	72	87	86	84	78	85	70	73	91	47	72	70	34	72	74	67	28	31	38	8	14	11	10	6
166575	2014-03-07	77	85	left	high	medium	73	78	46	74	66	80	71	72	70	75	87	86	84	78	85	70	71	92	47	72	70	34	72	74	67	28	31	38	8	14	11	10	6
166575	2014-01-17	76	83	left	high	medium	73	78	46	71	66	80	71	70	68	75	87	86	84	78	85	67	68	92	42	72	70	34	69	70	57	28	31	38	8	14	11	10	6
166575	2013-12-13	76	83	left	high	medium	73	78	46	71	66	80	71	70	68	75	87	86	84	78	85	67	68	92	42	72	70	34	69	70	57	28	31	38	8	14	11	10	6
166575	2013-11-01	76	81	left	high	medium	73	78	46	71	66	80	71	70	68	75	87	86	84	78	85	67	68	92	42	72	70	34	69	70	57	28	31	38	8	14	11	10	6
166575	2013-09-20	76	81	left	high	medium	69	78	46	71	66	80	71	70	68	75	87	86	84	78	85	67	68	92	42	72	70	34	69	68	57	28	31	38	8	14	11	10	6
166575	2013-05-17	74	81	left	high	medium	69	76	46	69	66	75	71	70	68	73	87	86	84	76	85	67	67	82	42	72	70	34	69	68	57	28	31	38	8	14	11	10	6
166575	2013-02-15	72	81	left	high	medium	68	71	38	67	66	74	69	70	64	72	83	78	84	72	85	67	67	77	46	69	64	34	67	64	57	28	31	38	8	14	11	10	6
166575	2012-08-31	68	76	left	medium	medium	67	63	35	62	58	73	66	60	57	71	78	72	77	64	83	62	73	58	41	61	68	34	62	60	57	28	31	38	8	14	11	10	6
166575	2012-02-22	67	76	left	medium	medium	67	54	35	62	58	71	66	60	57	70	78	72	77	64	83	62	73	58	41	61	68	34	62	54	57	28	31	38	8	14	11	10	6
166575	2011-08-30	67	77	left	medium	medium	67	58	43	62	56	71	66	58	55	70	78	72	77	67	83	60	73	58	41	58	83	26	57	54	57	24	31	33	8	14	11	10	6
166575	2011-02-22	65	74	left	medium	medium	64	58	42	62	56	71	66	53	55	70	74	72	72	67	37	49	67	60	35	58	83	26	48	54	57	24	31	33	8	14	11	10	6
166575	2010-08-30	65	74	left	medium	medium	64	58	42	62	56	71	66	53	55	70	74	72	72	67	37	49	67	60	35	58	46	26	48	54	57	24	31	33	8	14	11	10	6
166575	2010-02-22	67	75	left	medium	medium	67	56	42	62	56	73	66	53	57	71	75	74	72	67	37	44	67	61	39	58	36	52	62	54	47	24	41	33	7	23	57	23	23
166575	2009-08-30	50	65	left	medium	medium	52	46	47	51	56	54	66	36	51	33	60	62	72	56	37	44	67	51	54	47	48	38	28	54	34	24	41	33	7	23	51	23	23
166575	2007-02-22	50	65	left	medium	medium	52	46	47	51	56	54	66	36	51	33	60	62	72	56	37	44	67	51	54	47	48	38	28	54	34	24	41	33	7	23	51	23	23
38383	2016-04-21	79	79	right	medium	medium	77	73	45	82	67	84	79	76	79	78	82	76	91	75	89	72	79	81	34	74	65	46	75	81	71	35	42	47	10	14	13	13	14
38383	2016-03-24	79	79	right	medium	medium	77	73	45	82	67	84	79	76	79	78	82	76	91	75	89	72	79	81	34	74	65	46	75	81	71	35	42	47	10	14	13	13	14
38383	2016-02-25	79	79	right	medium	medium	77	73	45	82	67	84	79	76	79	78	84	76	91	75	89	72	79	81	34	74	65	46	75	81	71	35	42	47	10	14	13	13	14
38383	2016-02-04	79	79	right	medium	medium	77	73	45	82	67	84	79	76	79	78	84	76	91	75	89	72	79	81	34	74	65	46	75	81	71	35	42	47	10	14	13	13	14
38383	2015-11-26	79	79	right	medium	medium	77	73	45	82	67	84	79	76	79	78	84	76	91	75	89	72	79	81	34	74	65	46	75	81	71	35	42	47	10	14	13	13	14
38383	2015-05-15	80	80	right	medium	medium	81	72	45	82	69	84	79	77	80	80	84	76	92	77	91	72	80	84	34	74	66	47	76	84	72	35	42	47	10	14	13	13	14
38383	2015-04-10	80	80	right	medium	medium	81	72	45	82	69	84	79	77	80	80	84	76	92	77	91	72	80	84	34	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2014-10-17	81	81	right	medium	medium	81	72	45	83	69	86	79	77	80	85	84	76	92	77	91	72	80	84	34	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2014-09-18	81	81	right	medium	medium	81	72	45	83	69	86	79	77	80	84	84	76	92	77	91	72	80	84	34	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2014-05-16	81	81	right	medium	medium	85	72	45	83	69	86	79	77	80	84	85	76	90	77	93	72	76	84	32	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2014-02-14	81	81	right	medium	medium	85	72	45	83	69	86	79	77	80	84	85	76	90	77	93	72	76	84	32	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2013-11-29	81	81	right	medium	medium	85	72	45	81	69	86	77	77	78	84	83	76	90	77	93	72	76	84	32	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2013-09-20	81	81	right	medium	medium	78	72	45	81	69	86	77	77	78	84	83	76	90	77	93	72	76	84	32	74	66	47	76	84	71	35	42	47	10	14	13	13	14
38383	2013-08-16	82	82	right	medium	medium	78	72	45	80	69	86	77	77	77	84	83	75	88	77	93	72	76	83	32	74	66	47	77	84	71	35	42	47	10	14	13	13	14
38383	2013-05-17	82	84	right	medium	medium	78	72	45	80	69	86	77	77	77	84	83	75	88	77	93	72	76	83	32	74	66	47	77	84	71	35	42	47	10	14	13	13	14
38383	2013-03-01	82	84	right	medium	medium	78	72	45	80	69	86	77	77	77	84	83	75	88	77	93	72	76	83	32	74	66	47	77	84	71	35	42	47	10	14	13	13	14
38383	2013-02-15	82	84	right	medium	medium	78	72	45	80	69	86	77	77	77	84	83	75	88	77	93	72	76	83	32	74	66	47	77	84	71	35	42	47	10	14	13	13	14
38383	2012-08-31	82	84	right	medium	medium	78	72	45	80	69	86	77	77	77	84	83	75	91	77	93	72	71	83	32	74	66	47	77	84	71	35	42	47	10	14	13	13	14
38383	2011-08-30	82	84	right	medium	medium	78	75	45	80	69	86	77	77	77	84	79	75	91	77	93	72	71	83	32	76	66	47	77	84	71	35	42	47	10	14	13	13	14
38383	2011-02-22	79	82	right	medium	medium	78	74	45	80	69	86	77	77	78	84	77	75	82	77	75	67	65	76	37	76	66	47	77	84	74	35	42	47	10	14	13	13	14
38383	2010-08-30	79	82	right	medium	medium	79	74	45	80	69	85	77	77	79	84	77	75	82	77	47	67	65	76	37	76	66	47	77	84	74	35	42	47	10	14	13	13	14
38383	2010-02-22	77	80	right	medium	medium	77	74	45	79	69	85	77	77	80	82	78	75	82	77	47	67	65	78	37	76	66	74	75	84	79	35	42	47	18	21	80	21	21
38383	2009-08-30	77	82	right	medium	medium	77	74	51	76	69	87	77	77	75	85	79	75	82	79	47	62	65	80	37	76	67	76	75	84	78	34	41	47	18	21	75	21	27
38383	2008-08-30	74	78	right	medium	medium	78	71	53	77	69	85	77	79	79	82	78	76	82	82	47	62	65	83	45	74	74	74	70	84	77	34	43	47	8	21	79	21	21
38383	2007-08-30	76	78	right	medium	medium	78	69	53	76	69	87	77	79	79	85	81	76	82	80	47	67	65	83	46	74	73	75	69	84	77	44	43	47	8	21	79	21	21
38383	2007-02-22	77	84	right	medium	medium	80	69	55	78	69	90	77	77	83	88	84	79	82	82	47	70	65	80	49	75	73	75	69	84	77	44	43	47	8	8	83	9	7
46335	2016-05-19	72	72	right	medium	medium	69	73	80	69	69	70	68	67	58	71	64	67	66	67	67	71	78	71	70	69	59	37	80	72	73	28	35	33	9	16	13	15	6
46335	2016-04-21	72	72	right	medium	medium	69	73	80	69	69	70	68	67	58	71	64	67	66	67	67	71	78	71	70	69	59	37	80	72	73	28	35	33	9	16	13	15	6
46335	2016-03-03	71	71	right	medium	medium	69	73	73	69	69	70	68	67	58	72	58	65	62	67	67	71	79	71	71	69	59	37	80	73	73	28	35	33	9	16	13	15	6
46335	2016-02-11	71	71	right	medium	medium	69	73	73	69	69	70	68	67	58	72	58	65	62	67	67	71	79	71	71	69	59	37	80	73	73	28	35	33	9	16	13	15	6
46335	2015-10-16	72	72	right	medium	medium	69	71	73	72	69	71	68	67	58	73	67	66	68	69	67	71	79	71	71	69	59	37	80	73	73	28	35	33	9	16	13	15	6
46335	2015-09-25	72	72	right	medium	medium	69	70	73	72	69	71	68	67	58	73	67	66	68	69	67	71	79	71	71	69	59	37	80	71	73	28	35	33	9	16	13	15	6
46335	2015-09-21	72	72	right	medium	medium	66	70	73	72	69	71	68	67	58	73	67	66	68	69	67	71	79	71	71	69	59	37	80	71	73	28	35	33	9	16	13	15	6
46335	2015-04-10	69	69	right	medium	medium	65	68	73	68	68	67	69	66	60	70	67	68	69	68	67	70	76	71	70	67	58	46	74	68	72	27	34	39	8	15	12	14	5
46335	2014-11-14	69	69	right	medium	medium	65	68	73	68	69	67	72	67	60	70	61	63	69	68	67	72	78	71	70	71	58	46	74	66	74	27	34	39	8	15	12	14	5
46335	2014-09-18	70	70	right	medium	medium	65	68	73	68	69	67	72	67	60	70	74	72	75	68	67	72	78	78	70	71	58	46	74	71	74	27	34	39	8	15	12	14	5
46335	2014-02-28	71	71	right	medium	medium	65	70	73	70	69	69	72	71	60	72	74	72	75	70	67	72	76	78	70	71	58	46	74	71	74	27	34	39	8	15	12	14	5
46335	2013-11-22	71	71	right	medium	medium	65	70	73	70	69	69	72	71	60	72	74	72	75	70	67	72	84	81	70	71	58	46	74	71	74	27	34	39	8	15	12	14	5
46335	2013-09-20	71	71	right	medium	medium	65	70	73	70	69	69	72	71	60	72	73	72	78	70	67	72	84	81	70	71	58	46	74	71	74	27	34	39	8	15	12	14	5
46335	2013-05-31	70	70	right	medium	medium	65	68	72	65	64	68	72	71	64	69	74	75	78	70	67	68	87	81	73	66	58	46	72	71	64	27	34	39	8	15	12	14	5
46335	2013-02-15	70	70	right	medium	medium	65	68	72	65	64	68	72	71	64	69	74	75	78	70	67	68	87	81	73	66	58	46	72	71	64	27	34	39	8	15	12	14	5
46335	2012-08-31	70	70	right	medium	medium	69	69	72	65	64	69	72	71	64	71	74	76	81	70	66	70	90	79	73	66	58	46	72	71	64	27	34	39	8	15	12	14	5
46335	2012-02-22	70	70	right	medium	medium	69	69	72	65	64	70	72	71	64	71	74	76	81	70	66	70	90	79	73	66	58	46	72	71	64	27	34	39	8	15	12	14	5
46335	2011-08-30	71	71	right	medium	medium	69	69	72	65	64	70	72	71	64	71	80	78	83	70	66	70	88	79	73	66	58	46	72	71	64	27	34	39	8	15	12	14	5
46335	2011-02-22	70	73	right	medium	medium	67	66	72	65	69	68	64	63	60	73	76	75	75	69	64	73	75	75	67	66	56	46	74	72	64	37	34	39	8	15	12	14	5
46335	2010-08-30	70	73	right	medium	medium	67	66	72	65	69	68	64	63	60	73	76	75	75	69	64	73	75	75	67	66	56	46	74	72	64	37	34	39	8	15	12	14	5
46335	2010-02-22	70	73	right	medium	medium	67	67	69	65	69	69	64	63	60	73	76	75	75	69	64	73	75	75	67	66	56	74	71	72	65	37	34	39	8	20	60	20	20
46335	2009-08-30	69	73	right	medium	medium	67	66	67	65	69	69	64	63	60	73	76	75	75	69	64	73	75	75	67	66	56	74	71	72	65	37	34	39	8	20	60	20	20
46335	2009-02-22	68	71	right	medium	medium	62	66	61	60	69	67	64	58	55	71	76	75	75	69	64	69	75	73	67	64	46	60	64	72	62	20	34	39	8	20	55	20	20
46335	2008-08-30	66	70	right	medium	medium	62	63	61	60	69	65	64	53	55	67	74	73	75	67	64	70	75	73	67	62	54	52	54	72	52	20	34	39	8	20	55	20	20
46335	2007-08-30	59	62	right	medium	medium	54	57	53	55	69	57	64	53	47	52	71	74	75	67	64	55	75	67	65	47	54	52	54	72	52	37	44	39	8	20	47	20	20
46335	2007-02-22	59	62	right	medium	medium	54	57	53	55	69	57	64	53	47	52	71	74	75	67	64	55	75	67	65	47	54	52	54	72	52	37	44	39	8	20	47	20	20
148335	2016-04-14	76	78	left	high	medium	71	70	35	73	70	84	74	71	68	81	86	81	89	80	80	76	66	64	53	76	28	39	73	73	65	25	38	30	8	15	14	7	12
148335	2016-03-10	76	78	left	medium	low	71	70	35	73	70	84	74	71	68	81	86	81	89	78	80	76	66	64	53	76	28	35	73	70	65	25	38	30	8	15	14	7	12
148335	2016-01-21	76	78	left	medium	low	71	70	35	73	70	84	74	71	68	81	86	81	89	78	80	76	66	64	58	76	28	35	73	70	65	25	38	30	8	15	14	7	12
148335	2016-01-14	76	78	left	medium	low	71	70	35	73	70	84	74	71	68	81	86	81	89	78	80	76	66	64	58	76	28	25	73	70	65	30	46	35	8	15	14	7	12
148335	2015-11-06	75	77	left	medium	low	71	66	35	73	70	84	74	71	68	81	85	78	89	74	80	76	66	64	58	74	28	25	71	66	65	16	28	22	8	15	14	7	12
148335	2015-10-23	74	76	left	medium	low	71	66	35	73	70	84	72	71	68	81	79	76	89	73	80	74	66	64	58	74	28	25	71	65	65	16	28	22	8	15	14	7	12
148335	2015-10-16	74	76	left	medium	low	71	66	35	73	69	84	72	71	68	81	79	76	89	73	80	71	66	64	58	74	28	25	71	65	65	16	28	22	8	15	14	7	12
148335	2015-10-09	74	76	left	medium	low	71	66	35	73	69	84	72	71	68	81	79	76	89	73	80	71	66	64	58	74	28	25	71	65	65	16	28	22	8	15	14	7	12
148335	2015-09-25	74	76	left	medium	low	71	66	35	73	69	84	72	71	68	81	79	76	89	73	80	71	66	64	58	74	28	25	71	65	65	16	28	22	8	15	14	7	12
148335	2015-09-21	74	76	left	medium	low	71	66	35	73	69	84	72	71	68	81	81	76	89	73	80	71	66	64	58	74	28	25	71	65	65	16	28	22	8	15	14	7	12
148335	2015-04-17	73	75	left	medium	low	70	65	34	70	68	80	71	70	67	78	81	76	89	73	80	70	66	64	46	70	27	24	68	64	64	25	27	21	7	14	13	6	11
148335	2015-04-10	72	76	left	medium	low	70	65	34	70	68	77	71	70	67	75	81	76	89	73	80	70	66	64	46	70	27	24	68	64	64	25	27	21	7	14	13	6	11
148335	2014-10-02	73	76	left	medium	low	72	68	34	72	68	80	73	72	67	77	81	76	89	73	80	70	66	64	46	73	27	24	68	64	64	25	27	21	7	14	13	6	11
148335	2014-09-18	73	76	left	medium	low	72	68	34	72	68	80	73	72	67	77	81	76	89	73	80	70	66	64	46	73	27	24	68	64	64	25	27	21	7	14	13	6	11
148335	2014-05-02	73	76	left	medium	low	69	68	34	72	68	81	73	72	67	78	81	78	89	73	80	70	66	64	46	73	27	24	68	64	64	25	27	21	7	14	13	6	11
148335	2014-03-21	73	76	left	medium	low	69	68	34	72	68	81	73	72	67	78	81	78	89	73	80	70	66	64	46	73	27	24	68	64	64	25	27	21	7	14	13	6	11
148335	2014-02-14	74	77	left	medium	low	71	69	37	74	68	81	74	72	67	78	86	83	90	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2014-01-10	74	77	left	medium	low	71	69	37	70	68	83	74	72	67	78	86	83	90	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2013-09-20	74	77	left	high	low	71	69	37	70	68	83	74	72	67	78	86	83	90	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2013-04-19	74	80	left	high	low	71	69	37	70	68	83	74	72	67	78	86	83	88	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2012-08-31	74	80	left	high	low	71	69	37	70	68	83	74	72	67	78	86	83	88	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2012-02-22	74	80	left	high	low	71	69	37	70	68	83	74	72	67	78	89	83	88	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2011-08-30	74	80	left	high	low	71	69	37	70	68	83	74	72	67	78	89	83	88	74	80	71	71	71	46	74	37	34	64	65	64	23	34	26	7	14	13	6	11
148335	2011-02-22	73	78	left	high	low	71	69	42	70	68	78	74	72	67	75	82	77	80	70	38	67	67	69	32	74	47	38	67	70	64	31	37	26	7	14	13	6	11
148335	2010-08-30	70	78	left	high	low	71	65	46	68	68	76	74	70	64	72	75	65	74	69	50	69	42	65	40	70	37	40	67	72	63	45	55	38	7	14	13	6	11
148335	2010-02-22	68	78	left	high	low	70	65	46	65	68	75	74	69	60	72	73	65	74	68	50	68	42	65	40	69	37	54	57	72	70	45	55	38	1	21	60	21	21
148335	2009-08-30	65	70	left	high	low	70	52	46	60	68	70	74	66	60	72	69	62	74	68	50	52	42	65	40	49	37	49	47	72	65	40	55	38	1	21	60	21	21
148335	2008-08-30	54	69	left	high	low	33	49	46	50	68	65	74	66	50	62	61	57	74	64	50	41	42	57	37	44	27	41	42	72	61	21	21	38	1	21	50	21	21
148335	2007-02-22	54	69	left	high	low	33	49	46	50	68	65	74	66	50	62	61	57	74	64	50	41	42	57	37	44	27	41	42	72	61	21	21	38	1	21	50	21	21
21812	2011-02-22	69	70	left	\N	\N	69	33	69	64	52	54	63	65	67	64	62	71	63	68	64	69	65	73	69	55	65	69	54	64	54	68	71	69	14	9	13	14	9
21812	2010-08-30	69	71	left	\N	\N	69	33	69	64	52	54	63	65	67	64	62	71	63	68	64	69	65	73	69	55	65	69	54	64	54	68	71	69	14	9	13	14	9
21812	2010-02-22	68	69	left	\N	\N	71	33	67	63	52	54	63	65	68	64	57	71	63	68	64	70	65	70	69	55	65	72	68	64	66	68	70	69	9	20	68	20	20
21812	2009-02-22	67	69	left	\N	\N	71	33	67	63	52	60	63	46	73	65	55	71	63	68	64	74	65	69	61	65	65	72	68	64	56	68	67	69	9	20	73	20	20
21812	2008-08-30	68	69	left	\N	\N	71	33	72	63	52	63	63	46	73	65	55	71	63	68	64	74	65	69	61	65	65	72	68	64	56	70	67	69	9	20	73	20	20
21812	2007-08-30	67	69	left	\N	\N	71	33	72	63	52	63	63	46	73	65	55	71	63	68	64	74	65	69	61	65	65	72	68	64	56	70	67	69	9	20	73	20	20
21812	2007-02-22	69	73	left	\N	\N	73	35	74	65	52	65	63	58	75	67	57	73	63	70	64	76	65	71	63	67	67	72	68	64	58	72	69	69	9	10	75	11	13
38348	2010-08-30	63	66	right	\N	\N	49	29	57	64	33	53	44	48	61	61	63	63	65	61	68	61	63	74	73	53	69	61	41	62	47	61	62	64	10	12	5	7	5
38348	2009-08-30	64	67	right	\N	\N	49	29	57	64	33	53	44	48	61	61	63	63	65	61	68	61	63	74	73	53	69	65	63	62	63	61	62	64	9	23	61	23	23
38348	2008-08-30	61	66	right	\N	\N	53	29	56	63	33	53	44	48	58	58	67	65	65	58	68	60	63	73	63	51	66	54	60	62	58	59	61	64	9	23	58	23	23
38348	2007-08-30	55	55	right	\N	\N	50	39	50	55	33	53	44	43	59	50	48	53	65	45	68	44	63	71	68	61	50	64	60	62	58	45	49	64	9	23	59	23	23
38348	2007-02-22	55	55	right	\N	\N	50	39	50	55	33	53	44	58	59	50	48	53	65	45	68	44	63	71	68	61	50	64	60	62	58	45	49	64	9	13	59	15	9
34031	2008-08-30	58	60	right	\N	\N	62	48	52	58	\N	46	\N	47	55	53	62	73	\N	59	\N	60	\N	66	61	65	52	63	66	\N	54	52	54	\N	5	22	55	22	22
34031	2007-08-30	56	60	right	\N	\N	62	48	52	58	\N	46	\N	47	55	53	62	73	\N	59	\N	60	\N	66	61	65	52	63	66	\N	54	52	54	\N	5	22	55	22	22
34031	2007-02-22	51	58	right	\N	\N	42	48	52	58	\N	46	\N	54	65	47	62	73	\N	59	\N	60	\N	56	61	65	52	63	66	\N	54	22	44	\N	5	8	65	13	5
131532	2013-05-10	64	66	right	medium	medium	56	24	64	62	23	39	37	31	55	58	72	72	68	64	71	55	82	70	65	26	70	60	37	47	34	64	67	65	7	6	11	12	14
131532	2013-04-19	64	66	right	medium	medium	56	24	64	62	23	39	37	31	55	58	72	72	68	64	71	55	82	70	65	26	70	60	37	47	34	64	67	65	7	6	11	12	14
131532	2013-02-15	64	66	right	medium	medium	56	24	64	62	23	39	37	31	55	58	72	72	68	64	71	55	82	70	65	26	70	60	37	47	34	64	67	65	7	6	11	12	14
131532	2012-08-31	65	66	right	medium	medium	43	24	64	62	23	39	37	31	55	52	72	73	68	64	69	55	80	70	65	26	70	60	37	47	34	64	67	65	7	6	11	12	14
131532	2012-02-22	62	66	right	medium	medium	43	24	57	57	23	39	37	31	52	52	65	64	63	62	69	55	80	66	62	26	66	58	37	47	34	64	65	63	7	6	11	12	14
131532	2011-08-30	62	66	right	medium	medium	43	24	57	57	23	39	37	31	52	52	65	64	63	62	69	55	79	66	62	26	66	58	37	47	34	64	65	63	7	6	11	12	14
131532	2010-08-30	62	69	right	medium	medium	43	24	57	57	23	39	37	31	52	52	64	66	62	62	64	55	65	65	62	26	66	58	37	47	34	64	65	63	7	6	11	12	14
131532	2009-08-30	55	67	right	medium	medium	34	24	51	47	23	33	37	31	42	42	64	66	62	56	64	55	65	63	62	26	66	40	44	47	42	51	54	63	21	23	42	23	21
131532	2008-08-30	53	65	right	medium	medium	34	24	51	47	23	33	37	31	42	42	64	66	62	56	64	55	65	63	58	26	54	40	44	47	42	51	54	63	1	23	42	23	23
131532	2007-02-22	53	65	right	medium	medium	34	24	51	47	23	33	37	31	42	42	64	66	62	56	64	55	65	63	58	26	54	40	44	47	42	51	54	63	1	23	42	23	23
37262	2013-05-31	74	74	left	medium	low	71	75	64	76	72	75	72	72	69	74	73	72	75	75	69	74	66	64	71	71	52	36	79	76	70	26	29	27	14	10	5	15	14
37262	2013-05-03	74	74	left	medium	low	71	75	64	76	72	75	72	72	69	74	73	72	75	75	69	74	66	64	71	71	52	36	79	76	70	26	29	27	14	10	5	15	14
37262	2013-03-22	75	75	left	medium	low	72	76	65	76	72	77	74	72	69	75	76	72	77	76	69	74	66	64	72	73	52	46	79	76	72	35	39	37	14	10	5	15	14
37262	2013-03-15	75	75	left	medium	low	72	76	65	76	72	77	74	72	69	75	76	72	77	76	69	74	66	64	72	73	52	46	79	76	72	35	39	37	14	10	5	15	14
37262	2013-02-15	75	75	left	medium	low	72	76	65	76	72	77	74	72	69	75	76	72	77	76	69	74	66	64	72	73	52	46	79	76	72	35	39	37	14	10	5	15	14
37262	2012-08-31	73	73	left	high	low	72	76	66	74	72	79	74	75	67	75	79	75	74	76	67	74	66	62	69	73	62	37	78	64	75	35	39	37	14	10	5	15	14
37262	2012-02-22	76	76	left	medium	low	72	77	66	74	75	82	74	75	64	76	84	79	75	76	67	74	66	62	70	73	62	35	78	64	75	35	39	37	14	10	5	15	14
37262	2011-08-30	77	77	left	high	low	73	77	65	73	73	82	71	75	64	77	84	79	75	76	67	74	66	62	70	72	68	35	78	73	75	29	40	37	14	10	5	15	14
37262	2011-02-22	76	83	left	high	low	73	77	65	73	74	82	71	75	64	79	81	82	75	76	71	74	66	76	73	72	68	35	78	73	75	30	40	37	14	10	5	15	14
37262	2010-08-30	80	83	left	high	low	77	81	70	74	78	85	74	79	65	82	82	82	77	74	77	85	71	78	78	76	70	37	80	77	79	32	42	39	14	10	5	15	14
37262	2010-02-22	78	80	left	high	low	69	80	62	70	78	85	74	75	62	79	89	87	77	84	77	74	71	79	72	70	74	68	76	77	79	45	50	39	6	23	62	23	23
37262	2009-08-30	76	80	left	high	low	69	76	62	70	78	85	74	75	62	74	89	87	77	84	77	74	71	79	72	65	74	68	76	77	79	45	50	39	6	23	62	23	23
37262	2009-02-22	76	79	left	high	low	67	76	62	64	78	85	74	72	57	74	89	84	77	87	77	74	71	79	72	65	57	65	70	77	79	33	31	39	6	23	57	23	23
37262	2008-08-30	74	77	left	high	low	62	77	67	62	78	82	74	72	57	71	85	83	77	73	77	74	71	77	73	65	76	45	62	77	79	23	21	39	6	23	57	23	23
37262	2007-08-30	75	74	left	high	low	62	74	64	62	78	77	74	67	57	71	85	80	77	73	77	74	71	77	73	65	76	45	62	77	79	23	21	39	6	23	57	23	23
37262	2007-02-22	68	72	left	high	low	65	68	79	64	78	72	74	73	57	68	69	63	77	65	77	72	71	77	74	65	72	45	62	77	73	33	35	39	6	8	57	10	6
32760	2016-05-12	66	66	right	medium	high	64	53	51	66	66	64	69	71	69	68	51	42	58	64	78	80	52	74	76	68	76	67	57	63	66	57	63	60	14	7	6	15	14
32760	2016-03-24	66	66	right	medium	high	64	53	51	66	66	64	69	71	69	68	51	42	58	64	78	80	52	74	76	68	76	67	57	63	66	57	63	60	14	7	6	15	14
32760	2016-03-03	66	66	right	medium	high	64	53	51	66	66	64	69	71	69	68	51	42	58	64	78	80	56	74	76	68	76	67	57	63	66	57	63	60	14	7	6	15	14
32760	2016-02-25	66	66	right	medium	high	64	53	51	67	66	64	69	71	70	68	51	42	58	64	78	80	56	74	76	68	71	67	57	63	66	57	63	60	14	7	6	15	14
32760	2015-10-02	66	66	right	high	high	66	53	51	68	66	64	69	72	71	68	53	42	60	64	78	82	58	75	76	68	72	67	57	63	66	57	64	61	14	7	6	15	14
32760	2015-09-21	66	66	right	high	high	66	53	63	68	66	64	69	72	71	68	53	42	60	64	78	82	58	75	76	68	72	67	57	63	66	57	64	61	14	7	6	15	14
32760	2015-02-27	66	66	right	high	high	63	56	62	67	65	66	66	72	69	67	58	48	60	64	74	86	62	72	76	67	71	65	56	62	65	56	63	60	13	6	5	14	13
32760	2015-01-09	65	65	right	high	high	63	56	62	66	63	66	66	68	68	67	58	48	60	64	74	83	65	72	76	67	71	64	56	62	66	56	63	60	13	6	5	14	13
32760	2014-10-10	66	66	right	high	high	66	63	65	67	66	67	68	69	71	68	65	52	60	65	76	86	65	74	77	68	73	63	56	64	68	56	65	60	13	6	5	14	13
32760	2014-09-18	66	66	right	high	high	66	63	65	67	66	66	68	69	71	68	65	52	60	65	76	86	65	74	77	68	73	63	56	65	68	56	65	60	13	6	5	14	13
32760	2014-02-28	66	66	right	high	high	66	63	65	67	66	66	68	69	71	68	65	62	66	65	76	86	65	75	79	68	73	63	56	65	68	56	65	60	13	6	5	14	13
32760	2013-12-20	66	66	right	high	high	66	63	65	67	66	66	68	69	71	68	65	62	66	65	76	86	65	75	79	68	73	63	56	65	68	56	65	60	13	6	5	14	13
32760	2013-12-13	66	66	right	high	high	66	63	65	67	66	66	68	69	71	68	67	65	66	65	76	86	67	75	79	68	73	63	56	65	68	56	65	60	13	6	5	14	13
32760	2013-11-29	67	67	right	high	high	66	63	65	70	66	65	71	70	71	67	67	65	66	67	76	86	67	75	79	72	73	63	60	65	68	56	65	60	13	6	5	14	13
32760	2013-11-15	67	67	right	high	high	66	63	65	70	66	65	71	73	71	67	67	65	66	67	76	86	67	75	79	72	73	63	60	65	68	56	65	60	13	6	5	14	13
32760	2013-09-27	67	67	right	high	high	66	63	65	70	66	65	74	76	71	67	67	65	66	67	77	86	67	75	79	72	73	63	60	65	68	56	65	60	13	6	5	14	13
32760	2013-09-20	68	68	right	high	high	67	66	65	70	69	66	76	78	72	68	68	66	67	71	77	83	67	76	79	73	74	63	62	66	68	56	66	61	13	6	5	14	13
32760	2013-05-31	68	68	right	high	high	65	66	62	68	69	65	76	78	69	68	71	68	70	71	77	83	70	80	79	71	76	63	62	66	68	58	66	61	13	6	5	14	13
32760	2013-04-12	68	68	right	high	high	65	66	62	68	69	65	76	78	69	68	71	68	70	71	77	83	70	80	79	71	76	63	62	66	68	58	66	61	13	6	5	14	13
32760	2013-03-28	69	69	right	high	high	65	66	62	70	69	68	76	78	69	70	71	68	70	71	77	83	70	80	79	71	76	63	62	66	68	58	66	61	13	6	5	14	13
32760	2013-02-22	69	69	right	high	high	65	66	62	70	69	68	76	78	69	70	71	68	70	71	77	83	70	80	79	71	76	63	62	66	68	58	66	61	13	6	5	14	13
32760	2013-02-15	69	69	right	high	high	65	66	62	70	69	68	74	78	69	70	71	68	70	71	77	83	70	80	79	71	76	63	62	66	68	58	66	61	13	6	5	14	13
32760	2012-08-31	70	70	right	high	high	65	66	62	70	69	70	77	78	69	71	73	71	74	74	76	83	72	83	79	71	78	66	67	62	68	63	70	65	13	6	5	14	13
32760	2012-02-22	70	70	right	medium	high	65	66	62	70	69	70	77	78	69	71	73	71	74	74	76	83	72	83	79	71	78	66	67	62	68	63	70	65	13	6	5	14	13
32760	2011-08-30	71	72	right	medium	high	65	66	62	70	71	71	79	80	69	72	74	76	75	74	71	80	73	87	77	71	78	68	69	70	68	62	70	65	13	6	5	14	13
32760	2011-02-22	71	72	right	medium	high	67	66	62	72	71	69	78	80	71	71	71	73	70	70	80	82	67	83	78	73	78	68	69	63	68	62	71	66	13	6	5	14	13
32760	2010-08-30	73	75	right	medium	high	71	64	62	76	71	73	68	80	72	73	76	73	72	75	81	82	68	83	77	75	84	68	69	70	68	67	73	70	13	6	5	14	13
32760	2010-02-22	71	75	right	medium	high	69	64	58	73	71	67	68	80	66	71	76	71	72	72	81	85	68	83	76	74	81	64	72	70	79	64	69	70	7	21	66	21	21
32760	2009-08-30	71	74	right	medium	high	71	64	58	73	71	69	68	74	69	71	76	71	72	72	81	82	68	85	78	74	78	74	71	70	70	64	71	70	7	21	69	21	21
32760	2009-02-22	69	72	right	medium	high	64	50	56	71	71	62	68	62	67	67	76	71	72	72	81	74	68	83	69	67	78	74	71	70	65	64	69	70	7	21	67	21	21
32760	2008-08-30	69	72	right	medium	high	64	50	56	71	71	62	68	62	67	70	76	71	72	72	81	74	68	77	69	67	78	74	71	70	65	64	69	70	7	21	67	21	21
32760	2007-08-30	73	72	right	medium	high	66	50	56	77	71	71	68	57	69	72	69	71	72	75	81	69	68	76	75	58	64	63	74	70	53	66	68	70	7	21	69	21	21
32760	2007-02-22	76	77	right	medium	high	66	50	56	87	71	71	68	53	69	72	69	71	72	75	81	69	68	76	75	58	64	63	74	70	53	66	68	70	7	13	69	12	12
16387	2009-08-30	61	66	left	\N	\N	49	24	58	54	\N	21	\N	26	57	55	55	63	\N	59	\N	60	\N	65	65	31	69	54	58	\N	54	62	67	\N	4	22	57	22	22
16387	2009-02-22	57	61	left	\N	\N	47	22	58	41	\N	21	\N	26	52	33	55	63	\N	59	\N	50	\N	63	65	21	69	46	53	\N	49	60	65	\N	4	22	52	22	22
16387	2007-02-22	57	61	left	\N	\N	47	22	58	41	\N	21	\N	26	52	33	55	63	\N	59	\N	50	\N	63	65	21	69	46	53	\N	49	60	65	\N	4	22	52	22	22
37571	2010-08-30	61	67	right	\N	\N	47	45	58	54	44	55	32	41	57	61	62	64	57	62	59	62	62	59	59	62	62	59	35	54	47	59	64	64	10	5	11	12	6
37571	2009-08-30	61	67	right	\N	\N	47	45	58	54	44	55	32	41	57	61	62	64	57	62	59	62	62	59	59	62	62	55	65	54	56	59	64	64	6	21	57	21	21
37571	2008-08-30	61	67	right	\N	\N	47	45	58	54	44	55	32	41	57	61	62	64	57	62	59	62	62	59	59	62	62	55	65	54	56	59	64	64	6	21	57	21	21
37571	2007-08-30	56	67	right	\N	\N	47	36	51	54	44	43	32	41	48	54	60	61	57	58	59	58	62	55	57	62	57	50	51	54	54	59	56	64	6	21	48	21	21
37571	2007-02-22	56	67	right	\N	\N	47	36	51	54	44	43	32	41	48	54	60	61	57	58	59	58	62	55	57	62	57	50	51	54	54	59	56	64	6	21	48	21	21
34025	2011-02-22	67	69	left	\N	\N	59	69	58	64	64	69	69	68	61	68	72	74	73	67	58	61	67	62	60	62	58	17	71	59	71	19	19	24	14	15	14	12	8
34025	2010-08-30	67	69	left	\N	\N	59	69	58	64	64	69	69	68	61	68	72	74	73	67	58	61	67	62	60	62	58	17	71	59	71	19	19	24	14	15	14	12	8
34025	2010-02-22	67	71	left	\N	\N	59	69	58	64	64	69	69	68	61	68	72	74	73	67	58	61	67	68	62	62	58	57	66	59	61	20	20	24	7	20	61	20	20
34025	2009-08-30	67	71	left	\N	\N	59	69	58	64	64	69	69	68	61	68	72	74	73	67	58	61	67	68	62	62	58	57	66	59	61	20	20	24	7	20	61	20	20
34025	2009-02-22	65	76	left	\N	\N	57	70	52	60	64	69	69	63	54	64	72	74	73	63	58	63	67	68	62	62	58	52	66	59	57	20	20	24	7	20	54	20	20
34025	2008-08-30	65	76	left	\N	\N	62	67	52	64	64	70	69	63	54	65	72	74	73	63	58	63	67	68	62	62	58	52	66	59	57	20	20	24	7	20	54	20	20
34025	2007-08-30	67	68	left	\N	\N	62	67	50	60	64	70	69	63	54	65	72	75	73	63	58	63	67	68	56	62	58	42	62	59	51	20	20	24	7	20	54	20	20
34025	2007-02-22	57	68	left	\N	\N	46	61	60	55	64	57	69	51	54	48	62	65	73	58	58	55	67	58	61	57	58	42	62	59	51	19	19	24	7	6	54	7	7
33685	2015-04-10	67	67	right	medium	medium	65	62	58	66	61	66	67	61	64	68	70	65	74	67	72	67	58	77	60	66	64	38	67	67	64	45	50	46	5	14	5	9	15
33685	2015-01-09	68	68	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	65	76	67	72	67	58	81	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2014-09-18	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	65	76	67	72	67	58	81	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2014-02-14	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	66	76	67	72	67	59	80	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-11-29	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	66	76	67	72	67	59	80	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-11-15	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	66	76	67	72	67	59	80	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-11-01	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	66	76	67	72	67	59	80	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-09-20	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	66	76	67	72	67	59	80	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-05-31	67	67	right	medium	medium	65	62	58	66	61	67	68	61	64	68	70	66	76	67	72	67	59	79	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-05-17	68	68	right	medium	medium	65	62	58	68	61	70	68	61	66	71	70	66	76	67	72	67	59	79	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2013-02-15	68	68	right	medium	medium	65	62	58	68	61	70	68	61	66	71	70	66	76	67	72	67	59	79	60	66	64	38	68	67	64	45	50	46	5	14	5	9	15
33685	2012-08-31	67	67	right	high	medium	63	56	62	65	56	70	66	58	61	70	71	68	76	66	70	64	61	77	60	59	61	38	68	67	54	45	50	46	5	14	5	9	15
33685	2012-02-22	67	69	right	high	medium	63	56	62	65	56	70	66	58	61	70	67	68	76	66	74	64	61	77	44	59	61	38	68	67	54	45	50	46	5	14	5	9	15
33685	2011-08-30	67	69	right	high	medium	63	56	62	65	56	70	66	58	61	70	67	68	76	66	74	64	61	77	44	59	61	38	68	67	54	45	50	46	5	14	5	9	15
33685	2011-02-22	65	69	right	high	medium	63	56	62	65	56	72	66	58	61	70	66	69	63	66	54	64	61	74	58	59	61	52	64	67	54	45	50	46	5	14	5	9	15
33685	2010-08-30	66	74	right	high	medium	63	58	65	67	62	76	72	50	61	71	66	70	63	68	62	64	61	75	68	49	64	63	72	68	54	60	65	61	5	14	5	9	15
33685	2010-02-22	65	74	right	high	medium	58	58	65	67	62	76	72	50	59	71	66	70	63	68	62	64	61	75	68	49	64	64	63	68	65	60	65	61	13	23	59	23	23
33685	2009-08-30	64	74	right	high	medium	58	58	65	66	62	76	72	50	54	69	66	70	63	68	62	64	61	75	68	49	64	64	63	68	61	60	65	61	13	23	54	23	23
33685	2008-08-30	64	74	right	high	medium	53	58	65	64	62	76	72	50	49	69	66	70	63	68	62	64	61	75	68	49	64	64	63	68	61	60	65	61	13	23	49	23	23
33685	2007-08-30	67	74	right	high	medium	53	58	65	64	62	76	72	50	49	69	66	70	63	68	62	64	61	75	68	49	64	64	63	68	61	60	65	61	13	23	49	23	23
33685	2007-02-22	67	74	right	high	medium	53	58	65	64	62	76	72	61	49	69	66	72	63	68	62	64	61	77	69	49	64	64	63	68	61	69	65	61	13	10	49	5	11
39580	2012-02-22	65	67	right	low	high	32	16	65	47	21	32	19	30	42	42	65	67	57	65	47	58	65	55	80	24	74	64	23	42	49	64	67	65	14	7	12	9	8
39580	2011-08-30	70	72	right	low	high	45	36	67	59	51	37	29	50	54	51	70	72	58	70	54	58	71	67	84	44	81	64	40	42	49	70	72	67	14	7	12	9	8
39580	2011-02-22	73	77	right	low	high	45	36	69	59	51	37	29	50	54	53	69	74	67	70	78	58	73	75	83	44	81	73	40	55	49	71	72	78	14	7	12	9	8
39580	2010-08-30	75	77	right	low	high	45	36	74	59	51	37	29	50	54	58	69	74	67	70	78	58	73	75	83	44	79	78	40	65	49	77	76	74	14	7	12	9	8
39580	2009-08-30	74	79	right	low	high	55	36	74	59	51	47	29	50	54	62	69	74	67	70	78	58	73	79	79	44	79	63	72	65	60	77	76	74	12	20	54	20	20
39580	2009-02-22	74	77	right	low	high	55	36	79	59	51	47	29	58	54	57	71	74	67	70	78	58	73	82	78	44	77	67	71	65	62	77	76	74	12	20	54	20	20
39580	2008-08-30	73	77	right	low	high	65	36	79	64	51	50	29	58	54	57	78	67	67	70	78	38	73	82	78	44	74	67	70	65	57	75	74	74	12	20	54	20	20
39580	2007-08-30	73	72	right	low	high	65	36	81	58	51	41	29	58	30	51	81	61	67	60	78	38	73	82	77	44	74	58	59	65	57	75	67	74	12	20	30	20	20
39580	2007-02-22	71	74	right	low	high	65	36	81	58	51	31	29	37	30	51	81	31	67	60	78	38	73	82	72	44	72	58	59	65	37	75	61	74	12	9	30	5	11
166584	2010-02-22	62	67	right	\N	\N	43	61	62	56	\N	56	\N	43	46	63	63	68	\N	59	\N	70	\N	73	88	51	63	52	57	\N	58	22	36	\N	7	22	46	22	22
166584	2009-08-30	60	67	right	\N	\N	46	60	63	49	\N	57	\N	43	43	58	69	67	\N	59	\N	63	\N	63	74	46	53	55	58	\N	51	22	26	\N	7	22	43	22	22
166584	2009-02-22	55	67	right	\N	\N	47	53	57	49	\N	45	\N	42	43	50	58	68	\N	58	\N	60	\N	63	78	45	42	26	33	\N	41	22	26	\N	7	22	43	22	22
166584	2007-02-22	55	67	right	\N	\N	47	53	57	49	\N	45	\N	42	43	50	58	68	\N	58	\N	60	\N	63	78	45	42	26	33	\N	41	22	26	\N	7	22	43	22	22
114716	2010-02-22	62	66	right	\N	\N	55	63	49	54	\N	67	\N	58	52	65	71	68	\N	61	\N	60	\N	56	55	61	36	52	59	\N	58	27	26	\N	4	22	52	22	22
114716	2008-08-30	57	66	right	\N	\N	51	60	47	56	\N	62	\N	58	52	61	64	62	\N	56	\N	58	\N	56	56	61	36	53	49	\N	48	27	26	\N	4	22	52	22	22
114716	2007-02-22	57	66	right	\N	\N	51	60	47	56	\N	62	\N	58	52	61	64	62	\N	56	\N	58	\N	56	56	61	36	53	49	\N	48	27	26	\N	4	22	52	22	22
40008	2009-02-22	61	63	right	\N	\N	58	58	66	63	\N	68	\N	56	52	68	68	57	\N	56	\N	62	\N	60	60	43	52	56	61	\N	59	30	43	\N	7	22	52	22	22
40008	2008-08-30	60	63	right	\N	\N	58	58	66	63	\N	68	\N	56	52	68	68	57	\N	56	\N	62	\N	60	60	43	52	56	61	\N	59	30	43	\N	7	22	52	22	22
40008	2007-08-30	64	68	right	\N	\N	58	58	66	63	\N	71	\N	56	58	68	68	57	\N	56	\N	62	\N	60	60	43	61	65	68	\N	59	69	60	\N	7	22	58	22	22
40008	2007-02-22	64	68	right	\N	\N	58	58	66	63	\N	69	\N	59	58	68	68	57	\N	56	\N	62	\N	60	60	43	61	65	68	\N	59	69	60	\N	14	6	58	15	8
119118	2014-07-18	62	67	right	medium	medium	31	62	73	51	52	51	41	44	30	53	71	75	66	57	55	71	74	71	78	53	62	21	60	46	62	25	25	25	7	6	12	7	12
119118	2014-03-14	62	67	right	medium	medium	31	62	73	51	52	51	41	44	30	53	71	75	66	57	55	71	74	71	78	53	62	21	60	46	62	25	25	25	7	6	12	7	12
119118	2014-02-07	62	67	right	medium	medium	31	62	68	51	52	51	41	44	30	53	71	75	66	57	55	71	71	71	78	53	62	21	60	46	62	25	25	25	7	6	12	7	12
119118	2014-01-24	62	67	right	medium	medium	31	62	68	51	52	51	41	44	30	53	71	75	66	57	55	71	71	71	78	53	62	21	60	46	62	25	25	25	7	6	12	7	12
119118	2013-12-06	62	67	right	medium	medium	31	62	68	51	52	51	41	44	30	53	71	75	66	57	55	71	71	71	78	53	62	21	60	46	62	25	25	25	7	6	12	7	12
119118	2013-11-22	63	67	right	medium	medium	31	64	71	51	52	51	41	44	30	53	71	75	66	60	55	71	71	71	78	53	62	21	61	46	62	25	25	25	7	6	12	7	12
119118	2013-09-20	63	67	right	medium	medium	31	64	71	51	52	51	41	44	30	53	71	75	66	60	55	71	71	70	78	53	62	21	61	46	62	25	25	25	7	6	12	7	12
119118	2011-02-22	63	67	right	medium	medium	31	64	71	51	52	51	41	44	30	53	71	75	66	60	55	71	71	70	78	53	62	21	61	46	62	25	25	25	7	6	12	7	12
119118	2010-08-30	63	65	right	medium	medium	31	56	52	51	45	52	41	44	30	57	71	75	62	60	67	62	71	65	72	52	62	21	61	46	62	25	25	25	7	6	12	7	12
119118	2008-08-30	63	65	right	medium	medium	31	56	52	51	45	52	41	44	30	57	71	75	62	60	67	62	71	65	72	52	62	21	61	46	62	25	25	25	7	6	12	7	12
119118	2007-02-22	63	65	right	medium	medium	31	56	52	51	45	52	41	44	30	57	71	75	62	60	67	62	71	65	72	52	62	21	61	46	62	25	25	25	7	6	12	7	12
163674	2010-08-30	61	67	left	\N	\N	46	64	76	59	53	46	43	44	51	51	63	69	64	58	82	65	76	73	85	41	71	37	61	65	44	18	17	14	8	12	6	6	8
163674	2010-02-22	61	67	left	\N	\N	46	64	76	59	53	46	43	44	51	51	63	69	64	58	82	65	76	73	85	41	71	61	64	65	57	21	21	14	6	21	51	21	21
163674	2009-08-30	61	67	left	\N	\N	46	64	76	59	53	46	43	44	51	51	63	69	64	58	82	65	76	73	85	41	71	61	64	65	57	21	21	14	6	21	51	21	21
163674	2007-02-22	61	67	left	\N	\N	46	64	76	59	53	46	43	44	51	51	63	69	64	58	82	65	76	73	85	41	71	61	64	65	57	21	21	14	6	21	51	21	21
121639	2016-03-24	73	74	right	high	medium	62	72	80	61	69	66	53	45	42	64	88	87	69	71	59	81	78	76	82	63	79	22	66	58	70	15	27	25	15	12	11	8	12
121639	2016-02-25	74	75	right	high	medium	62	75	81	61	69	66	53	45	42	64	91	89	69	73	59	83	78	76	82	63	82	22	66	58	70	15	27	25	15	12	11	8	12
121639	2014-10-31	74	75	right	high	medium	62	75	81	61	69	66	53	45	42	64	91	89	69	73	59	83	78	76	82	63	82	22	66	58	70	15	27	25	15	12	11	8	12
121639	2014-10-10	71	74	right	medium	medium	62	72	74	61	69	61	53	45	42	61	91	89	69	73	59	78	74	76	82	63	82	22	66	58	70	15	27	25	15	12	11	8	12
121639	2014-10-02	69	74	right	medium	medium	62	66	68	61	66	60	53	45	42	60	91	89	69	73	59	78	74	76	82	63	82	22	66	58	70	15	27	25	15	12	11	8	12
121639	2014-09-18	69	74	right	medium	medium	56	66	68	58	66	60	53	45	42	60	91	89	69	73	59	78	74	76	82	63	82	22	66	51	70	15	27	25	15	12	11	8	12
121639	2014-02-28	69	74	right	medium	medium	56	66	68	58	61	60	53	45	42	60	91	90	69	73	59	81	74	76	82	59	82	22	66	51	70	15	27	25	15	12	11	8	12
121639	2014-01-24	69	74	right	medium	medium	56	66	68	58	61	60	53	45	42	60	92	90	69	73	59	81	74	76	82	59	82	22	66	51	70	15	27	25	15	12	11	8	12
121639	2013-11-15	69	74	right	medium	medium	56	66	68	58	61	60	53	45	42	60	92	90	69	73	59	81	74	76	76	59	82	22	66	51	70	15	27	25	15	12	11	8	12
121639	2013-09-27	69	74	right	medium	medium	56	66	68	58	61	60	53	45	42	60	92	90	69	73	59	81	74	76	76	59	60	22	66	51	70	15	27	25	15	12	11	8	12
121639	2013-09-20	68	74	right	medium	medium	56	64	68	58	61	54	53	45	42	60	92	90	69	73	59	81	74	76	74	59	60	22	62	51	63	15	27	25	15	12	11	8	12
121639	2012-02-22	68	74	right	medium	medium	56	64	68	58	61	54	53	45	42	60	92	90	69	73	59	81	74	76	74	59	60	22	62	51	63	15	27	25	15	12	11	8	12
121639	2011-08-30	71	74	right	medium	medium	56	70	74	58	64	58	53	49	42	61	89	83	69	73	59	83	74	76	83	69	60	22	68	51	66	15	27	25	15	12	11	8	12
121639	2011-02-22	73	80	right	medium	medium	59	70	75	61	66	60	53	49	43	62	84	82	65	74	83	84	71	73	82	69	60	31	82	53	66	15	27	25	15	12	11	8	12
121639	2010-08-30	73	80	right	medium	medium	59	70	75	61	66	60	53	49	43	62	84	82	65	74	83	84	71	73	82	69	60	31	82	53	66	15	27	25	15	12	11	8	12
121639	2010-02-22	74	77	right	medium	medium	43	79	73	54	66	56	53	49	41	58	81	84	65	74	83	84	71	73	86	71	57	47	66	53	65	21	27	25	3	21	41	21	21
121639	2009-08-30	74	77	right	medium	medium	43	79	73	54	66	56	53	49	41	58	81	84	65	74	83	84	71	73	86	71	57	47	66	53	65	21	27	25	3	21	41	21	21
121639	2009-02-22	69	77	right	medium	medium	43	74	71	51	66	56	53	49	41	58	73	80	65	67	83	78	71	73	85	71	57	47	55	53	65	21	27	25	3	21	41	21	21
121639	2008-08-30	58	68	right	medium	medium	36	46	65	46	66	54	53	42	31	57	68	73	65	62	83	67	71	69	79	48	52	37	32	53	29	21	27	25	3	21	31	21	21
121639	2007-02-22	58	68	right	medium	medium	36	46	65	46	66	54	53	42	31	57	68	73	65	62	83	67	71	69	79	48	52	37	32	53	29	21	27	25	3	21	31	21	21
178484	2012-02-22	62	70	right	medium	medium	47	63	56	48	56	58	43	48	43	53	77	78	77	66	63	65	84	60	73	57	56	34	58	48	42	32	38	39	11	15	12	11	10
178484	2011-08-30	62	70	right	medium	medium	47	63	56	48	56	58	43	48	43	53	77	78	77	66	63	65	82	60	73	57	56	34	58	48	42	32	38	39	11	15	12	11	10
178484	2010-08-30	62	68	right	medium	medium	47	63	56	48	56	58	43	48	43	53	74	76	71	66	69	65	73	61	71	57	56	34	58	48	42	32	38	39	11	15	12	11	10
178484	2010-02-22	62	68	right	medium	medium	47	63	56	48	56	58	43	48	43	53	74	76	71	66	69	65	73	61	71	57	56	37	35	48	49	32	38	39	7	23	43	23	23
178484	2009-08-30	59	68	right	medium	medium	48	65	35	46	56	55	43	48	53	50	72	72	71	65	69	59	73	59	62	58	56	40	35	48	29	32	38	39	7	23	53	23	23
178484	2007-02-22	59	68	right	medium	medium	48	65	35	46	56	55	43	48	53	50	72	72	71	65	69	59	73	59	62	58	56	40	35	48	29	32	38	39	7	23	53	23	23
47410	2011-08-30	63	69	right	\N	\N	59	54	58	66	55	66	64	47	63	67	70	66	68	61	68	58	66	67	62	59	66	43	64	59	51	18	21	23	11	11	13	13	15
47410	2010-08-30	63	66	right	\N	\N	59	54	58	66	55	66	64	47	63	67	68	67	65	61	56	58	63	65	62	59	66	43	64	59	51	18	21	23	11	11	13	13	15
47410	2009-08-30	63	71	right	\N	\N	59	54	58	66	55	66	64	47	63	67	68	67	65	61	56	58	63	65	62	59	66	62	63	59	58	20	21	23	3	20	63	20	20
47410	2008-08-30	58	71	right	\N	\N	56	46	37	61	55	67	64	45	58	65	62	67	65	58	56	54	63	56	47	56	29	34	37	59	36	20	20	23	3	20	58	20	20
47410	2007-02-22	58	71	right	\N	\N	56	46	37	61	55	67	64	45	58	65	62	67	65	58	56	54	63	56	47	56	29	34	37	59	36	20	20	23	3	20	58	20	20
38947	2014-03-28	67	70	right	medium	low	50	67	56	64	69	67	64	69	41	68	77	71	78	66	60	75	72	64	67	68	54	28	66	65	71	39	28	26	8	13	13	9	13
38947	2014-02-14	68	70	right	medium	low	50	67	56	64	69	69	64	69	41	68	77	71	78	66	60	76	72	64	67	69	54	28	67	65	71	39	28	26	8	13	13	9	13
38947	2013-09-20	68	70	right	medium	low	50	67	56	64	69	69	64	69	41	68	77	71	78	66	60	76	72	64	67	69	54	28	67	65	71	39	28	26	8	13	13	9	13
38947	2013-05-31	67	70	right	medium	low	50	67	56	59	69	68	64	69	41	66	77	71	78	66	60	76	71	64	67	68	54	28	65	60	71	39	28	26	8	13	13	9	13
38947	2013-02-15	67	70	right	medium	low	50	67	56	59	69	68	64	69	41	66	77	71	78	66	60	76	71	64	67	68	54	28	65	60	71	39	28	26	8	13	13	9	13
38947	2012-08-31	66	70	right	medium	low	50	67	56	59	69	68	64	69	41	66	77	72	77	63	57	76	69	64	67	67	54	28	64	60	71	39	28	26	8	13	13	9	13
38947	2012-02-22	64	72	right	medium	low	50	59	56	56	67	66	64	69	41	64	75	73	62	62	63	75	69	61	72	63	54	28	63	60	71	39	28	26	8	13	13	9	13
38947	2011-08-30	68	72	right	medium	low	50	65	56	59	67	72	64	69	41	68	75	73	62	65	63	78	69	61	72	65	54	28	67	66	71	39	28	26	8	13	13	9	13
38947	2008-08-30	68	72	right	medium	low	50	65	56	59	67	72	64	69	41	68	75	73	62	65	63	78	69	61	72	65	54	28	67	66	71	39	28	26	8	13	13	9	13
38947	2007-02-22	68	72	right	medium	low	50	65	56	59	67	72	64	69	41	68	75	73	62	65	63	78	69	61	72	65	54	28	67	66	71	39	28	26	8	13	13	9	13
39625	2016-05-05	66	66	left	high	high	73	55	52	67	62	66	69	61	66	66	65	62	68	67	72	69	68	71	61	65	64	69	66	65	63	63	67	65	8	6	16	8	15
39625	2015-09-21	66	66	left	high	high	73	55	52	67	62	66	69	61	66	66	65	62	68	67	72	69	68	71	61	65	64	69	66	65	63	63	67	65	8	6	16	8	15
39625	2015-03-20	66	66	left	high	high	69	56	53	66	61	67	68	63	63	66	67	64	68	66	71	67	66	71	62	65	63	68	65	65	62	62	66	64	7	5	15	7	14
39625	2015-03-06	67	67	left	high	high	70	56	53	66	61	67	68	63	63	66	68	66	70	67	71	67	66	74	63	65	64	68	65	65	62	62	66	64	7	5	15	7	14
39625	2014-09-18	68	68	left	high	high	71	57	55	67	63	68	69	64	64	67	70	67	71	67	71	67	68	78	64	65	64	66	65	65	63	62	66	64	7	5	15	7	14
39625	2013-11-01	67	67	left	high	medium	72	58	55	67	64	69	69	64	64	67	73	67	72	69	71	67	69	81	67	65	64	66	65	65	63	62	66	64	7	5	15	7	14
39625	2013-09-20	65	65	left	high	medium	72	58	55	65	61	67	69	64	62	65	73	67	72	68	71	67	69	81	67	64	63	63	64	64	63	59	65	63	7	5	15	7	14
39625	2013-05-24	65	65	left	high	medium	72	58	55	65	61	67	69	64	62	65	73	67	72	68	71	67	67	81	67	64	63	63	64	64	63	59	65	63	7	5	15	7	14
39625	2013-02-15	67	67	left	high	medium	72	58	55	65	61	67	69	64	62	65	73	67	72	66	71	67	67	81	67	64	63	61	64	64	63	59	62	63	7	5	15	7	14
39625	2012-08-31	63	63	left	high	low	69	56	55	63	59	67	69	64	59	65	73	69	72	66	69	65	67	75	67	64	63	58	64	64	63	59	61	62	7	5	15	7	14
39625	2011-08-30	66	66	left	high	high	69	56	48	62	59	67	69	64	59	65	73	69	72	66	70	65	67	71	67	64	63	57	62	62	61	57	58	59	7	5	15	7	14
39625	2011-02-22	62	69	left	high	high	69	54	45	62	59	67	63	58	59	65	71	68	68	66	55	60	64	69	59	62	63	57	62	62	57	57	58	59	7	5	15	7	14
39625	2010-08-30	66	69	left	high	high	69	54	45	59	61	69	63	58	57	67	71	68	68	66	55	63	64	68	59	64	59	57	64	65	57	52	56	59	7	5	15	7	14
39625	2009-02-22	66	69	left	high	high	69	54	45	59	61	69	63	58	57	67	71	68	68	66	55	63	64	68	59	64	59	57	64	65	57	52	56	59	7	5	15	7	14
39625	2008-08-30	66	69	left	high	high	69	54	45	59	61	69	63	58	57	67	71	68	68	66	55	63	64	68	59	64	59	57	64	65	57	52	56	59	7	5	15	7	14
39625	2007-08-30	62	62	left	high	high	61	45	45	59	61	69	63	58	57	67	63	61	68	60	55	59	64	57	59	56	55	49	46	65	48	52	38	59	7	5	15	7	14
39625	2007-02-22	62	62	left	high	high	61	45	45	59	61	69	63	48	57	67	63	61	68	60	55	59	64	57	59	56	55	49	46	65	48	52	38	59	7	10	15	15	6
148292	2008-08-30	54	57	right	\N	\N	53	47	45	57	\N	58	\N	54	52	56	65	67	\N	67	\N	53	\N	58	53	53	45	43	49	\N	53	26	32	\N	7	20	52	20	20
148292	2007-02-22	54	57	right	\N	\N	53	47	45	57	\N	58	\N	54	52	56	65	67	\N	67	\N	53	\N	58	53	53	45	43	49	\N	53	26	32	\N	7	20	52	20	20
38336	2016-05-12	75	75	right	medium	medium	77	65	47	77	62	82	72	62	67	79	81	82	78	69	65	70	74	71	76	68	70	44	70	69	52	43	33	32	6	8	8	15	13
38336	2016-02-18	75	75	right	medium	medium	77	65	47	77	62	82	72	62	67	79	81	82	78	69	65	70	74	71	76	68	70	44	70	69	52	43	33	32	6	8	8	15	13
38336	2015-12-24	75	75	right	medium	medium	77	65	47	77	62	82	72	62	67	79	81	82	78	69	65	70	74	71	76	68	64	44	70	69	52	43	33	32	6	8	8	15	13
38336	2015-10-23	75	75	right	medium	medium	77	65	47	77	62	82	72	62	67	79	81	82	78	69	65	70	74	71	76	68	64	44	70	69	52	43	33	32	6	8	8	15	13
38336	2015-09-21	75	75	right	medium	medium	77	65	47	77	62	82	72	62	67	79	80	82	78	69	65	70	74	71	76	68	64	44	68	64	52	43	33	32	6	8	8	15	13
38336	2015-04-10	74	74	right	medium	medium	76	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	77	79	67	63	43	65	59	51	42	32	31	5	7	7	14	12
38336	2015-03-06	74	74	right	medium	medium	76	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	77	79	67	63	43	65	59	51	42	32	31	5	7	7	14	12
38336	2014-10-02	74	74	right	medium	medium	76	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	77	79	67	63	43	65	59	51	42	32	31	5	7	7	14	12
38336	2014-09-18	73	73	right	medium	medium	70	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	77	79	67	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2014-02-14	73	75	right	medium	medium	70	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	77	79	67	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2013-09-20	74	75	right	medium	medium	70	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	81	79	67	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2013-04-26	74	75	right	medium	medium	70	64	46	76	61	81	71	61	66	78	82	87	81	65	65	69	74	81	79	67	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2013-03-22	73	74	right	medium	medium	70	56	46	71	61	81	71	61	66	76	82	87	81	65	65	69	74	81	79	63	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2013-02-15	73	74	right	medium	medium	70	56	46	71	61	81	71	61	66	76	82	87	81	65	65	69	74	81	79	63	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2012-02-22	69	74	right	medium	medium	70	56	46	71	61	81	71	61	66	76	82	87	79	65	65	69	74	78	79	63	63	27	65	59	51	20	32	31	5	7	7	14	12
38336	2011-08-30	72	74	right	medium	low	69	55	47	72	61	82	72	62	64	77	82	87	79	67	65	70	74	75	79	62	56	27	57	59	54	23	33	31	5	7	7	14	12
38336	2010-08-30	72	74	right	medium	low	69	55	47	67	63	80	66	63	62	75	76	81	72	67	73	70	67	75	75	60	56	37	58	62	54	23	33	31	5	7	7	14	12
38336	2010-02-22	71	76	right	medium	low	71	55	47	67	63	80	66	62	62	75	74	79	72	67	73	70	67	75	75	58	64	54	59	62	73	23	33	31	7	20	62	20	20
38336	2009-08-30	71	76	right	medium	low	71	58	42	67	63	78	66	60	64	76	77	76	72	62	73	68	67	74	76	67	56	56	58	62	65	23	33	31	7	20	64	20	20
38336	2009-02-22	68	73	right	medium	low	67	58	42	65	63	77	66	60	62	72	72	74	72	62	73	70	67	67	76	67	45	51	53	62	65	23	33	31	7	20	62	20	20
38336	2008-08-30	67	71	right	medium	low	67	62	42	65	63	77	66	60	62	72	67	65	72	62	73	70	67	67	76	67	45	51	53	62	65	23	33	31	7	20	62	20	20
38336	2007-08-30	64	71	right	medium	low	55	58	51	58	63	73	66	53	47	71	62	67	72	60	73	59	67	69	70	54	52	59	53	62	55	24	33	31	7	20	47	20	20
38336	2007-02-22	59	73	right	medium	low	40	58	40	53	63	67	66	45	42	58	58	64	72	60	73	59	67	69	67	49	52	59	53	62	45	24	43	31	7	8	42	9	11
67958	2016-04-28	73	73	left	high	high	72	53	63	74	61	74	68	65	73	77	80	78	82	75	83	62	87	88	62	67	72	79	69	75	66	74	76	72	10	7	7	11	15
67958	2016-03-24	73	73	left	high	high	72	53	63	74	61	72	68	65	73	77	78	78	82	75	83	62	87	88	62	67	72	79	69	75	66	74	76	72	10	7	7	11	15
67958	2016-02-04	73	73	left	high	high	72	53	63	74	61	72	68	65	73	77	78	78	85	75	83	62	87	88	62	67	72	79	69	75	66	74	76	72	10	7	7	11	15
67958	2016-01-21	73	73	left	high	high	72	53	63	74	61	72	68	65	73	77	78	78	85	75	83	62	87	88	62	67	72	79	69	72	66	74	76	72	10	7	7	11	15
67958	2015-12-17	73	73	left	high	high	72	53	63	74	61	72	68	65	73	77	78	78	85	75	83	62	87	88	62	67	72	79	69	72	66	74	76	72	10	7	7	11	15
67958	2015-10-02	73	73	left	high	high	68	53	63	74	62	72	68	61	73	72	78	78	85	75	83	68	91	88	62	66	72	79	69	72	66	74	76	72	10	7	7	11	15
67958	2015-09-21	73	73	left	high	high	68	53	63	72	62	72	68	61	67	72	78	78	85	75	83	68	91	88	62	66	72	79	69	71	66	74	76	72	10	7	7	11	15
67958	2015-05-15	71	71	left	high	high	67	52	62	71	61	71	67	60	66	71	78	78	85	74	83	67	89	85	62	65	71	78	68	70	65	71	73	69	9	6	6	10	14
67958	2015-03-06	70	70	left	high	high	67	52	61	71	61	71	67	60	66	71	78	78	85	72	83	67	89	87	62	65	71	77	68	70	65	71	73	68	9	6	6	10	14
67958	2015-02-27	71	71	left	high	high	68	52	58	69	61	71	67	60	67	70	78	74	85	72	83	65	89	87	58	65	71	77	68	70	65	65	71	66	9	6	6	10	14
67958	2014-11-07	71	71	left	high	high	68	52	58	69	61	71	67	60	67	70	78	74	85	72	83	65	89	87	58	65	71	77	68	70	65	65	71	66	9	6	6	10	14
67958	2014-10-24	70	70	left	high	high	68	52	58	69	61	71	67	60	67	70	78	74	85	71	83	65	89	87	58	65	71	75	68	70	65	63	68	66	9	6	6	10	14
67958	2014-10-17	69	69	left	high	high	68	52	58	69	61	71	67	60	67	70	78	74	85	71	83	65	89	87	58	65	71	72	68	70	65	63	68	66	9	6	6	10	14
67958	2014-10-02	69	69	left	high	high	68	52	58	69	61	71	67	60	67	70	78	74	85	71	83	65	89	87	58	65	71	72	68	70	65	63	68	66	9	6	6	10	14
67958	2014-09-18	69	69	left	high	high	68	52	58	69	61	71	67	60	67	70	78	74	85	71	83	65	89	87	58	65	71	69	68	70	65	63	68	66	9	6	6	10	14
67958	2014-04-04	68	69	left	high	high	69	64	58	69	61	72	67	60	67	70	78	74	85	71	83	65	86	86	63	65	69	66	68	70	65	59	66	64	9	6	6	10	14
67958	2014-01-17	68	69	left	high	high	69	64	58	69	61	72	67	60	67	70	78	74	85	71	83	65	86	86	63	65	69	66	68	70	65	59	66	64	9	6	6	10	14
67958	2013-12-27	68	69	left	high	high	69	66	58	70	61	72	67	60	68	70	78	73	78	71	83	65	86	86	64	67	72	66	74	71	65	58	67	65	9	6	6	10	14
67958	2013-11-15	71	72	left	high	high	69	66	58	70	61	72	67	60	68	70	78	73	78	71	83	65	86	86	64	67	72	66	74	71	65	58	67	65	9	6	6	10	14
67958	2013-09-20	71	72	left	high	high	69	66	58	70	61	72	67	60	68	70	78	73	78	71	83	65	86	86	64	67	72	66	74	71	65	58	67	65	9	6	6	10	14
67958	2013-04-05	72	73	left	high	high	68	66	58	70	61	72	67	60	64	73	78	73	80	74	83	65	86	85	64	67	79	66	75	71	65	61	67	65	9	6	6	10	14
67958	2013-02-15	72	73	left	high	high	68	66	58	72	61	72	67	60	64	73	78	73	80	74	83	65	86	85	64	67	79	66	75	71	65	61	67	65	9	6	6	10	14
67958	2012-08-31	71	73	left	high	high	68	66	58	72	61	72	67	60	64	73	78	75	80	74	81	65	82	79	64	67	79	66	75	71	65	61	67	65	9	6	6	10	14
67958	2012-02-22	71	73	left	high	high	68	66	58	72	61	72	67	60	64	73	85	79	80	74	81	65	82	79	64	67	79	66	75	71	65	61	67	65	9	6	6	10	14
67958	2011-08-30	70	74	left	medium	high	69	66	61	70	51	70	67	60	64	73	80	79	79	71	81	64	82	79	64	66	81	56	70	70	65	61	65	65	9	6	6	10	14
67958	2011-02-22	71	77	left	medium	high	68	61	45	69	51	71	67	60	64	71	76	79	78	71	65	62	68	75	64	56	81	65	70	70	52	61	65	65	9	6	6	10	14
67958	2010-08-30	72	77	left	medium	high	71	61	45	69	51	72	67	60	64	72	76	80	78	73	63	62	68	77	57	56	85	67	71	70	52	61	65	65	9	6	6	10	14
67958	2010-02-22	70	77	left	medium	high	65	42	45	67	51	72	67	60	62	71	75	80	78	72	63	57	68	74	52	53	85	67	62	70	65	59	61	65	9	20	62	20	20
67958	2009-08-30	69	76	left	medium	high	65	42	45	67	51	72	67	60	62	71	75	78	78	72	63	57	68	72	52	53	70	67	62	70	65	59	61	65	9	20	62	20	20
67958	2009-02-22	67	72	left	medium	high	62	52	49	67	51	72	67	56	60	70	73	78	78	67	63	57	68	67	42	57	49	57	52	70	55	60	65	65	9	20	60	20	20
67958	2008-08-30	65	72	left	medium	high	60	52	49	65	51	67	67	56	57	67	72	74	78	67	63	57	68	67	42	57	49	57	52	70	55	57	62	65	9	20	57	20	20
67958	2007-08-30	64	72	left	medium	high	64	51	49	63	51	72	67	56	62	74	73	74	78	67	63	57	68	67	47	57	49	51	49	70	55	54	55	65	9	20	62	20	20
67958	2007-02-22	64	72	left	medium	high	64	51	49	63	51	72	67	56	62	74	73	74	78	67	63	57	68	67	47	57	49	51	49	70	55	54	55	65	9	20	62	20	20
38257	2016-04-21	69	69	right	low	high	45	54	72	67	43	41	45	55	58	59	32	31	35	64	44	62	55	75	81	57	78	79	53	61	46	68	71	65	9	12	16	13	16
38257	2016-03-24	69	69	right	low	high	45	54	72	67	43	41	45	55	58	59	32	31	35	64	44	62	55	75	81	57	78	79	53	61	46	68	71	65	9	12	16	13	16
38257	2016-02-25	69	69	right	low	high	45	54	72	67	43	41	45	55	58	59	39	37	35	64	44	62	55	75	81	57	78	79	53	61	46	68	71	65	9	12	16	13	16
38257	2016-02-04	69	69	right	low	high	45	54	72	67	43	41	45	55	58	59	39	37	42	67	44	62	55	75	77	57	78	79	53	64	46	68	71	65	9	12	16	13	16
38257	2015-09-21	69	69	right	low	high	45	54	72	67	43	41	45	55	58	59	39	37	42	67	44	62	55	75	77	57	78	79	53	64	46	68	71	65	9	12	16	13	16
38257	2015-04-17	69	69	right	low	high	44	58	72	67	42	48	44	54	57	58	44	47	42	66	44	64	57	78	81	56	78	78	52	63	45	68	72	66	8	11	15	12	15
38257	2015-04-10	68	68	right	low	high	44	58	72	67	42	48	44	54	57	58	49	47	47	65	64	64	63	76	75	56	78	74	52	61	45	68	72	66	8	11	15	12	15
38257	2014-09-18	67	67	right	low	high	48	58	72	63	42	48	44	59	57	60	49	47	47	65	56	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2013-09-20	67	67	right	low	high	48	58	72	63	42	48	34	48	57	60	49	50	47	65	56	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2013-05-31	67	67	right	low	high	48	58	72	63	42	48	34	48	57	60	49	52	47	65	53	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2013-05-17	67	67	right	low	high	48	58	72	63	42	48	34	48	57	60	49	52	47	65	53	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2013-03-28	67	67	right	low	high	48	58	72	63	42	48	34	48	57	60	49	52	47	65	53	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2013-02-15	67	67	right	low	high	48	58	72	63	42	48	34	48	57	60	49	52	47	65	53	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2012-08-31	67	67	right	medium	high	48	58	72	63	42	48	34	48	57	60	49	54	47	65	49	69	63	73	76	60	76	74	52	66	45	64	69	67	8	11	15	12	15
38257	2011-08-30	66	66	right	medium	high	46	56	72	62	32	48	34	48	56	60	49	54	47	62	48	69	63	73	76	57	76	74	52	66	45	63	68	64	8	11	15	12	15
38257	2011-02-22	66	69	right	medium	high	46	56	72	62	32	48	34	48	56	60	56	65	53	62	73	69	62	72	76	57	76	74	52	66	45	63	68	64	8	11	15	12	15
38257	2010-08-30	67	69	right	medium	high	46	56	73	62	32	48	34	48	56	60	56	65	53	61	73	69	62	75	78	57	76	74	69	66	45	63	68	64	8	11	15	12	15
38257	2010-02-22	66	68	right	medium	high	46	56	73	62	32	48	34	48	56	60	56	65	53	61	73	69	62	75	78	57	76	73	69	66	68	60	68	64	1	23	56	23	23
38257	2009-08-30	65	66	right	medium	high	46	56	73	62	32	48	34	48	56	58	56	65	53	61	73	69	62	75	78	57	76	73	69	66	68	60	68	64	1	23	56	23	23
38257	2007-08-30	65	66	right	medium	high	46	56	73	62	32	48	34	48	56	58	56	65	53	61	73	69	62	75	78	57	76	73	69	66	68	60	68	64	1	23	56	23	23
38257	2007-02-22	62	65	right	medium	high	44	32	72	51	32	47	34	65	46	57	54	64	53	59	73	65	62	74	75	37	74	73	69	66	65	57	68	64	1	1	46	1	1
31316	2016-01-28	64	64	right	medium	medium	57	24	62	55	29	37	46	32	51	58	69	67	56	59	69	63	59	67	77	50	72	63	39	41	46	60	63	62	7	14	16	9	7
31316	2015-09-21	66	66	right	medium	medium	57	24	65	61	29	37	46	32	51	58	69	67	56	59	69	63	59	72	84	50	72	63	39	41	46	64	65	66	7	14	16	9	7
31316	2014-09-18	64	64	right	medium	medium	56	23	64	60	28	36	45	31	50	57	69	67	56	58	69	62	59	72	84	49	71	62	38	40	45	61	62	63	6	13	15	8	6
31316	2013-10-04	63	65	right	medium	medium	56	23	57	60	28	36	45	31	50	57	69	67	52	58	68	62	59	71	75	49	71	62	38	40	45	64	62	63	6	13	15	8	6
31316	2013-09-20	62	65	right	low	medium	56	23	57	60	28	36	45	31	50	57	69	67	52	58	68	62	59	71	75	49	71	62	38	40	45	64	62	63	6	13	15	8	6
31316	2011-02-22	62	65	right	low	medium	56	23	57	60	28	36	45	31	50	57	69	67	52	58	68	62	59	71	75	49	71	62	38	40	45	64	62	63	6	13	15	8	6
31316	2010-08-30	62	65	right	low	medium	56	23	57	60	28	36	45	31	50	58	69	67	52	58	68	62	59	69	75	49	71	63	38	40	45	64	62	63	6	13	15	8	6
31316	2009-08-30	66	71	right	low	medium	57	23	58	61	28	56	45	31	58	61	71	69	52	66	68	62	59	72	69	49	83	57	60	40	56	67	68	63	5	22	58	22	22
31316	2008-08-30	66	71	right	low	medium	57	23	58	61	28	56	45	31	58	61	71	69	52	66	68	62	59	72	69	49	80	60	62	40	61	68	69	63	5	22	58	22	22
31316	2007-02-22	66	71	right	low	medium	57	23	58	61	28	56	45	31	58	61	71	69	52	66	68	62	59	72	69	49	80	60	62	40	61	68	69	63	5	22	58	22	22
38349	2009-08-30	65	75	left	\N	\N	67	44	71	69	\N	55	\N	53	65	61	42	47	\N	61	\N	68	\N	67	69	62	66	77	83	\N	78	60	69	\N	9	21	65	21	21
38349	2008-08-30	65	71	left	\N	\N	65	44	71	65	\N	55	\N	53	60	61	42	47	\N	61	\N	68	\N	67	69	62	66	77	76	\N	78	63	70	\N	9	21	60	21	21
38349	2007-08-30	71	74	left	\N	\N	65	45	74	65	\N	57	\N	53	62	62	51	58	\N	65	\N	71	\N	71	78	62	65	74	72	\N	73	67	71	\N	9	21	62	21	21
38349	2007-02-22	73	82	left	\N	\N	58	39	77	62	\N	48	\N	52	54	48	59	65	\N	70	\N	73	\N	73	81	58	64	74	72	\N	52	74	72	\N	9	12	54	15	11
32990	2009-02-22	61	67	right	\N	\N	31	21	21	21	\N	21	\N	11	64	24	66	53	\N	50	\N	22	\N	55	76	21	60	64	28	\N	43	21	21	\N	64	65	64	68	48
32990	2007-08-30	61	67	right	\N	\N	31	21	21	21	\N	21	\N	11	64	24	66	53	\N	50	\N	22	\N	55	76	21	60	64	28	\N	43	21	21	\N	64	65	64	68	48
32990	2007-02-22	64	68	right	\N	\N	31	11	12	12	\N	9	\N	43	65	24	66	53	\N	50	\N	22	\N	75	76	12	60	64	28	\N	43	12	11	\N	65	66	65	69	49
25499	2010-02-22	75	78	right	\N	\N	54	85	87	74	\N	62	\N	61	51	75	60	65	\N	80	\N	75	\N	62	82	70	67	77	85	\N	79	23	37	\N	7	23	51	23	23
25499	2009-08-30	77	78	right	\N	\N	59	85	89	74	\N	67	\N	67	53	77	62	67	\N	82	\N	75	\N	75	83	71	74	78	85	\N	82	23	37	\N	1	23	53	23	23
25499	2008-08-30	77	78	right	\N	\N	62	85	87	74	\N	72	\N	67	53	77	62	67	\N	82	\N	75	\N	75	85	71	74	78	83	\N	85	23	43	\N	1	23	53	23	23
25499	2007-08-30	78	78	right	\N	\N	62	85	87	74	\N	72	\N	67	63	82	62	67	\N	82	\N	75	\N	75	85	71	74	78	83	\N	85	23	43	\N	1	23	63	23	23
25499	2007-02-22	83	84	right	\N	\N	64	86	93	74	\N	76	\N	88	63	86	59	71	\N	86	\N	84	\N	78	90	75	79	78	83	\N	88	40	43	\N	1	1	63	1	1
106369	2015-06-26	64	64	left	medium	low	60	61	51	51	48	70	65	61	59	62	90	91	77	66	64	67	58	62	75	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2015-02-20	64	67	left	medium	low	60	61	51	51	48	70	65	61	59	62	90	91	77	66	64	67	58	62	75	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2015-02-06	64	67	left	medium	low	60	61	51	51	48	70	65	61	59	62	90	91	77	66	64	67	58	62	75	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2015-01-16	64	68	left	medium	low	60	61	51	51	48	70	65	61	59	62	90	91	73	66	64	67	58	62	64	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2014-11-14	64	68	left	medium	low	60	61	51	51	48	70	65	61	59	62	90	91	73	66	64	67	58	62	64	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2014-10-24	64	68	left	medium	low	60	61	51	63	48	70	65	61	59	66	90	91	73	66	64	67	58	62	64	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2014-10-17	64	68	left	medium	low	60	61	51	63	48	70	65	61	59	66	90	91	73	66	64	67	58	62	64	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2014-09-18	64	68	left	medium	low	60	61	51	63	48	70	65	61	59	66	90	91	73	66	64	67	58	62	64	59	41	34	62	54	59	25	25	25	8	6	7	6	14
106369	2014-07-18	65	68	left	medium	low	63	62	51	65	48	71	65	61	59	66	90	91	74	67	67	68	58	65	62	60	41	34	63	56	59	25	25	25	8	6	7	6	14
106369	2014-03-28	65	68	left	medium	low	63	62	51	65	48	71	65	61	59	66	90	91	74	67	67	68	58	65	62	60	41	34	63	56	59	25	25	25	8	6	7	6	14
106369	2014-02-28	65	68	left	medium	low	63	62	51	65	48	70	65	61	59	66	90	91	74	67	67	68	58	65	62	60	41	34	63	56	59	25	25	25	8	6	7	6	14
106369	2014-02-14	66	68	left	medium	low	63	64	51	65	48	70	65	61	59	66	90	91	74	67	67	68	58	65	62	62	41	34	65	56	59	25	25	25	8	6	7	6	14
106369	2014-01-31	67	72	left	medium	low	64	62	51	65	48	70	65	61	59	65	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	23	28	24	8	6	7	6	14
106369	2013-12-20	67	73	left	medium	low	64	62	51	65	48	70	65	61	59	65	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	23	28	24	8	6	7	6	14
106369	2013-11-22	68	73	left	medium	low	64	62	51	65	48	70	65	61	59	65	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	23	28	24	8	6	7	6	14
106369	2013-10-25	68	73	left	medium	low	64	61	51	65	48	69	65	61	59	66	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	28	33	29	8	6	7	6	14
106369	2013-10-18	68	73	left	medium	low	64	61	51	65	48	69	65	61	59	66	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	28	33	29	8	6	7	6	14
106369	2013-09-20	68	73	left	medium	low	64	61	51	65	48	69	65	61	59	66	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	28	33	29	8	6	7	6	14
106369	2013-05-24	68	73	left	medium	low	64	61	51	65	48	69	65	61	59	66	90	91	74	67	67	65	58	65	62	58	41	34	65	56	59	28	33	29	8	6	7	6	14
106369	2013-04-19	68	73	left	high	low	66	62	51	65	48	71	65	61	59	66	90	91	74	69	67	66	58	68	63	58	41	34	67	56	59	28	33	29	8	6	7	6	14
106369	2013-03-22	69	73	left	high	low	67	62	51	66	48	72	65	61	59	67	90	91	74	69	67	66	58	68	63	58	41	34	67	56	59	28	33	29	8	6	7	6	14
106369	2013-02-22	69	73	left	high	low	68	62	51	66	48	73	65	61	59	68	90	91	74	70	67	66	58	68	63	58	41	34	68	57	59	28	33	29	8	6	7	6	14
106369	2013-02-15	69	73	left	medium	low	68	62	51	66	48	73	65	61	59	68	90	91	74	70	67	66	58	68	63	58	41	34	68	57	59	33	38	34	8	6	7	6	14
106369	2012-08-31	70	73	left	medium	low	69	60	51	67	48	73	65	61	59	68	89	91	74	70	67	66	58	71	63	56	41	34	68	57	59	33	38	34	8	6	7	6	14
106369	2012-02-22	70	73	left	medium	medium	67	60	51	66	48	73	64	65	59	68	90	91	76	70	67	66	58	71	63	56	41	34	69	57	63	33	38	34	8	6	7	6	14
106369	2011-08-30	69	72	left	medium	medium	65	66	51	64	46	72	64	65	57	67	89	91	76	70	66	66	58	71	62	56	41	34	69	57	63	33	38	34	8	6	7	6	14
106369	2011-02-22	68	73	left	medium	medium	62	65	51	63	46	72	64	65	56	67	87	85	77	70	66	66	58	70	60	56	41	34	68	55	63	33	38	34	8	6	7	6	14
106369	2010-08-30	67	73	left	medium	medium	62	65	51	58	46	72	64	38	56	67	87	85	77	73	66	66	58	70	60	56	41	34	68	55	63	33	38	34	8	6	7	6	14
106369	2010-02-22	67	73	left	medium	medium	62	65	47	58	46	68	64	38	56	65	76	81	77	73	66	67	58	70	60	56	41	48	61	55	56	33	38	34	8	21	56	21	21
106369	2009-08-30	67	73	left	medium	medium	62	65	47	58	46	68	64	38	56	65	76	81	77	73	66	67	58	70	60	56	41	48	61	55	56	33	38	34	8	21	56	21	21
106369	2009-02-22	59	73	left	medium	medium	48	60	47	54	46	59	64	38	52	58	79	81	77	53	66	61	58	70	54	56	41	38	61	55	56	33	38	34	8	21	52	21	21
106369	2008-08-30	59	73	left	medium	medium	48	60	47	54	46	59	64	38	52	58	79	81	77	53	66	61	58	70	54	56	41	38	61	55	56	33	38	34	8	21	52	21	21
106369	2007-08-30	54	68	left	medium	medium	59	54	47	52	46	57	64	38	52	51	59	55	77	50	66	57	58	46	52	53	41	38	47	55	42	36	38	34	8	21	52	21	21
106369	2007-02-22	54	68	left	medium	medium	59	54	47	52	46	57	64	38	52	51	59	55	77	50	66	57	58	46	52	53	41	38	47	55	42	36	38	34	8	21	52	21	21
104404	2015-11-19	70	72	right	high	high	67	57	63	68	67	72	57	62	65	74	73	75	74	71	72	71	76	72	70	70	68	49	67	68	54	25	38	24	12	16	12	8	8
104404	2015-09-21	71	73	right	high	high	67	57	63	68	67	75	57	62	65	74	73	75	74	71	72	71	76	72	70	70	68	49	73	70	54	25	38	24	12	16	12	8	8
104404	2015-03-06	70	72	right	high	high	63	53	62	67	66	74	56	61	63	73	76	74	75	70	72	70	76	72	76	69	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2014-12-05	70	73	right	high	high	63	53	62	67	66	74	56	61	63	73	76	74	75	70	72	70	76	72	76	69	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2014-09-18	70	73	right	high	high	63	53	62	67	66	74	56	61	63	73	76	74	75	70	72	70	76	72	76	69	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2014-04-25	70	73	right	high	high	63	63	62	67	66	74	56	61	63	73	76	74	75	70	72	70	74	72	76	69	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2014-03-21	70	73	right	high	high	63	63	62	67	66	74	56	61	63	73	76	74	75	70	72	70	74	72	76	69	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2014-02-14	70	72	right	high	high	63	63	62	67	66	74	56	61	63	73	76	74	75	70	72	70	74	72	76	69	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2014-02-07	70	72	right	high	high	63	63	62	67	66	74	56	61	63	73	76	74	75	70	72	70	74	72	76	62	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2013-11-29	70	74	right	high	high	63	66	62	67	66	74	56	61	63	73	76	74	75	70	72	70	74	72	76	59	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2013-11-15	70	74	right	high	high	63	66	62	67	66	74	56	61	63	73	76	74	75	70	72	70	74	72	76	59	67	48	72	69	53	24	37	23	11	15	11	7	7
104404	2013-11-08	69	72	right	high	medium	63	66	62	65	63	74	56	61	62	71	76	74	75	68	72	67	74	72	76	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-11-01	69	72	right	high	medium	63	66	62	65	56	74	56	61	62	71	76	71	75	68	72	67	74	72	76	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-09-20	69	72	right	high	medium	63	66	62	65	56	74	56	61	62	71	76	71	75	68	72	67	74	72	76	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-06-07	69	72	right	high	medium	63	66	62	65	56	72	56	61	62	71	74	70	75	65	72	67	73	72	74	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-05-31	69	74	right	high	medium	63	66	62	65	56	72	56	61	62	71	74	70	75	65	72	67	73	72	74	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-04-19	69	74	right	high	medium	63	66	62	65	56	72	56	61	62	71	74	70	75	65	72	67	73	72	74	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-04-12	69	74	right	high	medium	63	66	62	65	56	72	56	61	62	71	74	70	75	65	72	67	73	72	74	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2013-02-15	68	74	right	high	medium	60	66	62	64	56	72	56	61	60	71	74	70	75	58	72	67	73	70	72	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2012-08-31	67	74	right	high	medium	60	66	62	64	56	70	56	61	60	71	72	70	75	58	70	67	71	70	72	59	67	48	72	68	53	24	37	23	11	15	11	7	7
104404	2012-02-22	67	73	right	high	medium	63	63	58	66	56	72	56	61	58	72	78	70	73	58	68	69	71	70	69	66	67	28	56	68	53	24	37	23	11	15	11	7	7
104404	2011-08-30	67	73	right	high	medium	63	63	58	66	56	72	56	61	58	72	78	70	73	58	68	69	71	70	69	66	67	28	56	68	53	24	37	23	11	15	11	7	7
104404	2010-08-30	63	75	right	high	medium	63	63	58	66	51	66	52	48	58	63	75	70	68	63	72	64	66	68	70	47	67	28	56	65	53	24	37	23	11	15	11	7	7
104404	2009-08-30	65	75	right	high	medium	67	63	58	70	51	69	52	48	62	72	75	70	68	67	72	64	66	73	70	47	67	52	54	65	74	24	56	23	12	21	62	21	21
104404	2008-08-30	51	65	right	high	medium	39	47	48	37	51	49	52	48	34	45	59	63	68	69	72	44	66	47	53	47	49	27	29	65	39	24	22	23	2	21	34	21	21
104404	2007-02-22	51	65	right	high	medium	39	47	48	37	51	49	52	48	34	45	59	63	68	69	72	44	66	47	53	47	49	27	29	65	39	24	22	23	2	21	34	21	21
68120	2015-09-25	66	67	left	medium	medium	70	48	46	63	54	67	67	65	66	66	79	79	77	63	75	74	74	73	61	66	55	43	62	59	53	35	44	43	8	10	9	13	9
68120	2015-09-21	66	67	left	medium	medium	70	48	46	63	54	67	67	65	66	66	79	79	77	63	75	74	74	73	61	64	55	43	62	59	53	35	44	43	8	10	9	13	9
68120	2015-05-15	65	67	left	medium	medium	69	47	45	62	53	65	66	64	65	64	79	82	77	62	75	64	72	62	58	61	54	42	57	53	52	34	43	42	7	9	8	12	8
68120	2014-10-02	65	69	left	medium	medium	69	47	45	62	53	65	66	64	65	64	79	82	77	62	75	64	72	62	58	61	54	42	57	53	52	34	43	42	7	9	8	12	8
68120	2014-09-18	65	69	left	medium	medium	69	47	45	62	53	65	66	62	65	64	79	82	77	62	75	64	72	62	58	61	54	42	57	53	52	34	43	42	7	9	8	12	8
68120	2012-02-22	65	69	left	medium	medium	69	47	45	62	53	65	66	62	65	64	79	82	77	62	75	64	72	62	58	61	54	42	57	53	52	34	43	42	7	9	8	12	8
68120	2011-08-30	65	68	left	medium	medium	69	55	47	62	53	65	66	63	67	64	76	82	68	60	73	64	71	61	66	61	54	45	57	55	54	39	43	42	7	9	8	12	8
68120	2010-08-30	63	69	left	medium	medium	64	55	47	59	53	65	66	63	61	62	67	65	65	60	67	64	66	62	62	61	54	45	57	55	54	39	43	42	7	9	8	12	8
68120	2010-02-22	61	67	left	medium	medium	64	55	44	59	53	63	66	63	61	61	65	65	65	60	67	64	66	62	62	61	67	54	52	55	55	39	43	42	17	20	61	20	20
68120	2009-08-30	59	67	left	medium	medium	60	51	42	55	53	61	66	55	57	60	65	65	65	60	67	59	66	62	62	57	47	54	50	55	52	39	43	42	17	20	57	20	20
68120	2007-02-22	59	67	left	medium	medium	60	51	42	55	53	61	66	55	57	60	65	65	65	60	67	59	66	62	62	57	47	54	50	55	52	39	43	42	17	20	57	20	20
30692	2015-01-09	65	65	right	medium	medium	34	28	68	48	36	33	24	30	37	38	29	34	31	56	32	46	49	51	94	32	77	65	24	23	38	64	66	62	6	8	7	12	10
30692	2014-11-07	67	67	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	56	32	46	49	51	94	32	77	65	24	23	38	66	68	64	6	8	7	12	10
30692	2014-05-02	67	67	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	56	32	46	49	51	94	32	77	65	24	23	38	66	68	64	6	8	7	12	10
30692	2014-04-25	67	67	right	medium	medium	42	28	70	50	36	33	24	30	37	43	32	41	31	56	32	46	49	51	94	32	77	68	24	23	38	67	68	65	6	8	7	12	10
30692	2014-02-07	66	66	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	56	32	46	49	51	94	32	77	63	24	23	38	66	68	64	6	8	7	12	10
30692	2014-01-24	66	66	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	47	32	46	49	33	94	32	77	63	24	23	38	66	68	64	6	8	7	12	10
30692	2014-01-17	66	66	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	47	32	46	49	33	94	32	77	63	24	23	38	66	68	64	6	8	7	12	10
30692	2013-10-25	67	67	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	47	32	46	49	33	94	32	81	63	32	28	38	67	70	65	6	8	7	12	10
30692	2013-07-05	67	67	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	47	32	46	49	33	94	32	81	63	32	28	38	67	70	65	6	8	7	12	10
30692	2013-03-28	67	67	right	medium	medium	34	28	70	48	36	33	24	30	37	38	29	34	31	47	32	46	49	33	94	32	81	63	32	28	38	67	70	65	6	8	7	12	10
30692	2013-03-22	74	77	right	medium	medium	34	38	84	61	36	43	24	30	37	42	29	34	31	58	32	72	49	33	94	52	81	67	42	40	38	74	81	72	6	8	7	12	10
30692	2013-02-22	74	77	right	medium	medium	34	38	84	61	36	43	24	30	37	42	29	34	31	58	32	72	49	33	94	52	81	67	42	40	38	74	81	72	6	8	7	12	10
30692	2013-02-15	74	77	right	medium	medium	34	38	84	61	36	43	24	30	37	42	29	34	31	58	32	72	49	33	94	52	81	67	42	40	38	74	81	72	6	8	7	12	10
30692	2012-08-31	75	77	right	medium	medium	34	38	84	61	36	43	24	30	37	42	29	34	31	65	32	72	49	33	94	52	81	74	42	40	38	74	76	78	6	8	7	12	10
30692	2012-02-22	77	79	right	medium	medium	42	38	81	66	36	43	24	30	37	42	33	54	32	69	32	75	47	68	94	60	81	81	42	40	38	78	79	75	6	8	7	12	10
30692	2011-08-30	73	75	right	low	medium	42	21	80	53	36	32	24	30	37	41	40	57	26	65	32	69	29	63	94	62	70	79	25	37	38	78	78	71	6	8	7	12	10
30692	2011-02-22	75	80	right	low	medium	42	21	80	63	36	33	24	30	67	53	60	70	56	65	87	69	84	66	89	62	70	79	25	68	38	78	78	71	6	8	7	12	10
30692	2010-08-30	75	80	right	low	medium	32	21	80	63	36	38	24	30	67	55	57	63	54	65	84	72	80	68	86	62	70	75	25	68	38	78	80	74	6	8	7	12	10
30692	2010-02-22	76	80	right	low	medium	39	21	82	65	36	42	24	30	67	62	56	60	54	64	84	75	80	77	91	62	80	73	73	68	72	77	75	74	9	21	67	21	21
30692	2009-08-30	77	80	right	low	medium	39	21	82	62	36	42	24	30	67	66	56	64	54	61	84	75	80	80	92	62	80	76	74	68	76	78	78	74	9	21	67	21	21
30692	2009-02-22	75	79	right	low	medium	37	45	82	59	36	37	24	30	55	55	65	70	54	72	84	70	80	77	92	29	89	62	67	68	72	74	72	74	11	21	55	21	21
30692	2008-08-30	74	74	right	low	medium	38	44	80	64	36	44	24	30	55	64	71	65	54	79	84	65	80	77	85	29	86	60	68	68	64	73	69	74	11	21	55	21	21
30692	2007-08-30	76	77	right	low	medium	38	44	80	64	36	44	24	30	38	64	68	65	54	60	84	65	80	77	85	29	86	60	66	68	64	72	74	74	11	21	38	21	21
30692	2007-02-22	75	84	right	low	medium	38	44	75	64	36	40	24	59	38	60	68	62	54	67	84	60	80	77	89	29	83	60	66	68	59	74	74	74	11	7	38	11	7
38357	2012-08-31	69	69	right	high	medium	68	66	56	70	71	68	69	67	67	71	58	60	63	67	59	65	57	58	59	72	37	46	73	72	70	29	33	32	9	12	14	14	8
38357	2012-02-22	70	70	right	high	medium	68	68	56	72	73	69	69	67	67	73	61	60	66	66	64	67	60	61	58	71	37	46	73	72	70	29	33	32	9	12	14	14	8
38357	2011-08-30	70	70	right	high	medium	69	71	58	72	73	72	69	68	68	76	64	62	69	69	65	69	60	61	66	70	37	46	74	75	73	36	34	37	9	12	14	14	8
38357	2011-02-22	70	76	right	high	medium	69	73	58	73	76	72	69	68	70	78	63	65	66	69	56	69	60	66	53	73	37	46	76	83	73	36	34	37	9	12	14	14	8
38357	2010-08-30	70	76	right	high	medium	69	73	58	73	76	72	69	68	70	78	63	65	66	69	56	69	60	66	53	73	37	46	76	83	73	36	34	37	9	12	14	14	8
38357	2009-08-30	70	76	right	high	medium	69	73	58	73	76	72	69	68	70	78	63	65	66	69	56	69	60	66	53	73	37	80	78	83	83	36	34	37	11	20	70	20	20
38357	2009-02-22	69	71	right	high	medium	69	68	58	73	76	74	69	68	70	76	63	62	66	69	56	70	60	66	53	71	47	78	76	83	67	36	34	37	11	20	70	20	20
38357	2008-08-30	69	71	right	high	medium	69	68	58	73	76	74	69	68	70	76	63	62	66	69	56	70	60	66	53	71	47	78	76	83	67	36	34	37	11	20	70	20	20
38357	2007-08-30	70	71	right	high	medium	70	61	58	72	76	75	69	69	70	73	70	72	66	72	56	73	60	69	55	71	47	62	60	83	42	36	34	37	11	20	70	20	20
38357	2007-02-22	70	71	right	high	medium	70	61	58	72	76	75	69	69	70	73	70	72	66	72	56	73	60	69	55	71	47	62	60	83	42	36	34	37	11	20	70	20	20
38778	2015-10-16	70	70	right	medium	low	68	69	49	64	68	70	67	73	66	71	78	78	75	61	67	69	73	67	62	71	28	21	68	66	57	20	20	25	15	10	6	14	14
38778	2015-09-21	70	71	right	medium	low	68	69	49	64	68	70	67	73	66	71	78	78	75	61	67	69	73	67	62	71	28	21	68	66	57	20	20	25	15	10	6	14	14
38778	2015-07-03	69	71	right	medium	low	67	68	48	63	67	69	66	72	65	70	78	78	75	60	67	68	73	67	62	70	27	20	67	65	56	25	25	24	14	9	5	13	13
38778	2015-02-06	69	71	right	medium	low	67	68	48	63	67	69	66	72	65	70	78	78	75	60	67	68	73	67	62	70	27	20	67	65	56	25	25	24	14	9	5	13	13
38778	2014-09-18	68	71	right	medium	low	67	68	48	63	67	69	66	72	65	70	78	78	75	60	67	68	73	67	62	70	27	20	67	65	56	25	25	24	14	9	5	13	13
38778	2014-04-11	69	72	right	medium	low	68	69	49	64	68	70	67	73	66	71	78	78	75	61	66	69	73	67	62	70	28	21	68	66	57	20	20	25	15	10	6	14	14
38778	2014-02-21	69	72	right	medium	low	68	69	49	64	68	70	67	73	66	71	78	78	75	61	66	69	73	67	62	70	28	21	68	66	57	20	20	25	15	10	6	14	14
38778	2014-02-07	69	72	right	medium	low	67	69	49	64	68	71	69	73	64	69	78	78	75	60	66	70	73	67	62	71	28	21	67	65	57	20	20	25	15	10	6	14	14
38778	2013-10-04	69	72	right	medium	low	67	69	49	64	68	71	69	73	64	69	78	78	75	60	66	70	73	67	62	71	28	21	67	65	57	20	20	25	15	10	6	14	14
38778	2013-09-20	69	72	right	medium	low	67	69	49	64	68	71	69	73	64	69	78	78	75	60	66	70	73	67	62	71	28	21	67	65	57	20	20	25	15	10	6	14	14
38778	2013-05-10	70	72	right	medium	low	67	69	49	67	68	73	69	73	65	71	79	77	75	67	66	70	73	67	62	71	29	32	67	65	62	22	25	27	15	10	6	14	14
38778	2013-03-22	71	72	right	medium	low	67	69	49	67	68	74	69	73	65	72	79	77	75	67	66	70	73	67	62	71	29	32	67	65	62	22	25	27	15	10	6	14	14
38778	2013-02-15	70	72	right	medium	low	67	64	49	67	66	74	69	73	65	72	79	77	75	67	66	70	73	67	62	71	29	32	67	65	62	22	25	27	15	10	6	14	14
38778	2012-08-31	69	72	right	medium	low	64	64	49	67	66	74	67	69	65	72	79	77	75	67	65	70	71	67	62	71	29	27	67	65	62	22	25	27	15	10	6	14	14
38778	2012-02-22	67	71	right	medium	low	65	62	42	70	67	75	67	67	65	74	79	77	79	65	66	67	71	70	67	70	29	27	62	62	62	22	25	27	15	10	6	14	14
38778	2011-08-30	67	71	right	medium	medium	65	64	45	70	65	74	67	67	65	73	79	77	79	64	66	68	71	70	67	70	27	37	62	62	62	22	34	33	15	10	6	14	14
38778	2011-02-22	68	72	right	medium	medium	65	64	45	70	65	74	67	67	65	73	75	74	72	64	47	68	65	67	54	70	27	37	62	62	62	22	34	33	15	10	6	14	14
38778	2010-08-30	70	72	right	medium	medium	62	65	47	71	68	77	67	69	65	75	79	77	75	62	47	72	65	71	54	74	27	37	62	60	55	22	34	33	15	10	6	14	14
38778	2010-02-22	67	72	right	medium	medium	62	57	47	64	68	77	67	65	65	75	79	77	75	62	47	65	65	71	54	67	27	52	54	60	37	22	34	33	4	22	65	22	22
38778	2009-08-30	65	72	right	medium	medium	61	57	47	62	68	72	67	62	60	72	79	77	75	62	47	60	65	67	54	63	27	52	54	60	37	22	34	33	4	22	60	22	22
38778	2008-08-30	64	72	left	medium	medium	61	57	51	60	68	72	67	58	58	72	69	74	75	60	47	65	65	67	55	63	41	53	55	60	58	22	34	33	4	22	58	22	22
38778	2007-08-30	62	72	right	medium	medium	53	57	56	58	68	67	67	52	53	62	67	62	75	54	47	62	65	70	65	58	61	63	55	60	58	22	34	33	4	22	53	22	22
38778	2007-02-22	65	72	right	medium	medium	53	67	66	63	68	66	67	58	70	56	67	62	75	54	47	67	65	70	65	63	61	63	55	60	58	22	64	33	4	11	70	8	2
32573	2009-02-22	76	81	right	\N	\N	59	49	77	80	\N	55	\N	42	74	75	74	75	\N	78	\N	77	\N	76	74	38	78	72	74	\N	56	79	73	\N	8	21	74	21	21
32573	2008-08-30	76	81	right	\N	\N	59	49	77	80	\N	55	\N	42	74	75	74	75	\N	78	\N	77	\N	76	74	38	78	72	74	\N	56	79	73	\N	8	21	74	21	21
32573	2007-08-30	72	81	right	\N	\N	56	47	77	79	\N	55	\N	41	71	71	77	74	\N	79	\N	77	\N	72	74	35	79	69	71	\N	48	79	69	\N	8	21	71	21	21
32573	2007-02-22	72	81	right	\N	\N	56	47	77	79	\N	55	\N	48	71	71	77	74	\N	79	\N	77	\N	72	74	35	79	69	71	\N	48	79	69	\N	8	15	71	7	12
38388	2016-03-24	73	73	left	medium	high	66	38	73	66	26	47	46	36	60	62	57	59	57	72	59	66	68	72	70	54	70	80	47	57	36	75	78	74	6	14	10	12	6
38388	2016-03-10	73	73	left	medium	high	66	38	73	66	26	47	46	36	60	62	57	60	57	72	59	66	68	72	70	54	70	80	47	57	36	75	78	74	6	14	10	12	6
38388	2016-02-25	73	73	left	medium	high	66	38	73	66	26	47	46	36	60	62	57	62	57	72	59	66	68	75	70	54	70	80	47	57	36	75	78	74	6	14	10	12	6
38388	2016-02-18	73	73	left	medium	high	66	28	73	66	26	47	46	36	60	62	57	62	57	72	59	66	68	75	70	54	70	80	47	52	36	75	78	74	6	14	10	12	6
38388	2016-01-28	73	73	left	medium	high	66	28	73	66	26	47	46	36	60	62	57	62	57	72	59	66	68	75	70	54	70	80	47	52	36	75	78	74	6	14	10	12	6
38388	2015-09-21	73	73	left	medium	high	66	28	73	66	26	47	46	36	60	62	57	62	57	72	59	66	68	75	70	54	70	80	47	52	36	75	78	74	6	14	10	12	6
38388	2015-08-07	72	72	left	medium	high	65	27	72	65	25	47	45	35	59	62	62	65	60	72	57	65	67	75	70	53	73	79	47	57	35	72	75	71	5	13	9	11	5
38388	2015-05-01	72	72	left	medium	high	65	27	72	65	25	47	45	35	59	62	62	65	60	72	57	65	67	75	70	53	73	79	47	57	35	72	75	71	5	13	9	11	5
38388	2015-03-20	71	71	left	medium	high	65	27	70	65	25	47	45	35	59	62	62	65	60	72	57	65	67	75	70	53	73	79	47	57	35	72	75	71	5	13	9	11	5
38388	2015-02-27	70	70	left	medium	high	65	27	70	65	25	47	45	35	59	62	62	65	60	70	57	65	67	75	70	53	71	75	42	57	35	72	72	71	5	13	9	11	5
38388	2015-02-20	70	70	left	medium	high	65	27	70	65	25	47	45	35	59	62	62	65	60	70	57	65	67	75	70	53	69	74	42	57	35	72	72	71	5	13	9	11	5
38388	2014-11-14	70	70	left	medium	high	65	27	70	62	25	47	45	35	59	60	62	65	60	70	57	65	67	75	70	52	69	74	42	55	35	72	72	71	5	13	9	11	5
38388	2014-10-02	70	70	left	medium	high	65	27	70	62	25	47	45	35	59	60	62	65	60	70	57	65	67	75	70	52	69	74	42	55	35	72	72	71	5	13	9	11	5
38388	2014-09-18	70	70	left	medium	high	65	27	70	62	25	47	45	35	59	60	62	67	60	70	59	65	68	75	70	52	69	74	37	54	35	72	72	71	5	13	9	11	5
38388	2014-07-18	69	69	left	medium	high	65	27	69	62	25	47	45	35	59	60	62	67	60	67	59	65	67	71	70	52	67	74	37	54	35	72	72	71	5	13	9	11	5
38388	2014-04-25	69	69	left	medium	high	65	27	69	62	25	47	45	35	59	60	62	67	60	67	59	65	67	71	70	52	67	74	37	54	35	72	72	71	5	13	9	11	5
38388	2014-04-04	69	69	left	medium	high	65	27	69	62	25	47	45	35	59	60	62	67	60	67	59	65	67	71	70	52	67	74	37	54	35	72	72	71	5	13	9	11	5
38388	2013-11-08	70	70	left	medium	high	65	27	70	62	25	47	45	35	59	60	62	69	62	72	60	65	69	72	71	52	71	74	37	54	35	75	72	73	5	13	9	11	5
38388	2013-10-04	70	70	left	medium	high	60	27	70	62	25	47	45	35	59	60	62	69	62	72	60	65	69	72	71	52	71	74	37	54	35	75	72	73	5	13	9	11	5
38388	2013-09-20	70	70	left	medium	high	60	27	70	62	25	47	45	35	59	60	65	70	65	72	60	65	69	72	71	52	71	75	37	54	35	73	72	73	5	13	9	11	5
38388	2013-05-10	70	70	left	medium	high	60	27	70	62	25	47	45	35	59	60	67	72	65	72	60	65	67	72	71	52	71	75	37	54	35	73	72	73	5	13	9	11	5
38388	2013-02-15	71	71	left	medium	high	60	27	70	62	25	47	45	35	59	60	67	72	65	72	60	65	68	72	72	52	74	75	37	59	35	75	74	75	5	13	9	11	5
38388	2012-08-31	70	70	left	medium	high	60	27	70	62	25	47	45	35	59	60	67	72	65	71	57	65	67	72	70	52	72	69	35	60	35	75	74	72	5	13	9	11	5
38388	2012-02-22	70	70	left	medium	high	62	27	70	62	25	47	45	35	60	62	70	70	69	71	63	65	72	79	70	52	72	70	35	59	35	72	74	72	5	13	9	11	5
38388	2011-08-30	72	72	left	medium	high	62	27	72	67	23	47	45	32	59	62	72	73	69	71	63	67	72	79	70	57	74	72	37	60	45	72	75	74	5	13	9	11	5
38388	2011-02-22	72	73	left	medium	high	62	27	72	67	23	47	45	32	59	62	70	72	65	71	74	67	68	74	72	57	74	78	37	76	45	72	75	74	5	13	9	11	5
38388	2010-08-30	72	73	left	medium	high	62	27	72	67	23	47	45	32	59	62	72	74	65	71	70	67	68	74	72	47	75	77	37	76	45	72	75	74	5	13	9	11	5
38388	2010-02-22	72	75	left	medium	high	60	23	72	65	23	47	45	32	57	62	72	74	65	71	70	62	68	75	72	35	74	82	75	76	79	75	74	74	13	20	57	20	20
38388	2009-08-30	70	75	left	medium	high	57	23	70	62	23	47	45	32	55	62	70	72	65	67	70	62	68	75	72	35	72	76	74	76	77	72	73	74	13	20	55	20	20
38388	2009-02-22	72	75	left	medium	high	59	23	74	65	23	57	45	46	57	62	70	72	65	71	70	65	68	75	73	35	75	77	73	76	83	74	75	74	13	20	57	20	20
38388	2008-08-30	72	72	left	medium	high	59	23	74	65	23	57	45	46	57	62	70	72	65	71	70	65	68	75	73	35	75	77	73	76	83	74	75	74	13	20	57	20	20
38388	2007-08-30	71	72	left	medium	high	57	31	74	65	23	55	45	46	55	60	67	72	65	70	70	65	68	75	73	37	75	74	71	76	83	75	74	74	13	20	55	20	20
38388	2007-02-22	71	72	left	medium	high	61	36	73	66	23	55	45	66	56	63	63	68	65	69	70	63	68	74	72	43	75	74	71	76	66	74	73	74	13	13	56	14	6
38292	2010-02-22	67	69	right	\N	\N	51	32	67	54	\N	31	\N	31	46	54	56	55	\N	64	\N	60	\N	62	67	30	74	78	82	\N	80	65	72	\N	7	22	46	22	22
38292	2009-08-30	68	69	right	\N	\N	51	32	67	54	\N	31	\N	31	46	62	60	58	\N	66	\N	60	\N	65	70	30	81	78	82	\N	80	66	68	\N	7	22	46	22	22
38292	2008-08-30	66	69	right	\N	\N	51	32	67	54	\N	31	\N	31	46	45	60	58	\N	66	\N	60	\N	57	70	30	81	64	67	\N	66	66	68	\N	7	22	46	22	22
38292	2007-08-30	65	69	right	\N	\N	51	32	67	54	\N	31	\N	31	46	45	60	58	\N	66	\N	60	\N	57	70	30	81	64	67	\N	66	66	68	\N	7	22	46	22	22
38292	2007-02-22	68	69	right	\N	\N	52	33	68	55	\N	38	\N	66	47	48	61	59	\N	67	\N	61	\N	64	71	31	82	64	67	\N	66	69	75	\N	7	5	47	11	4
33660	2009-02-22	58	62	right	\N	\N	59	27	43	57	\N	54	\N	37	48	52	63	68	\N	67	\N	57	\N	74	48	37	59	57	57	\N	54	56	54	\N	17	22	48	22	22
33660	2007-02-22	58	62	right	\N	\N	59	27	43	57	\N	54	\N	37	48	52	63	68	\N	67	\N	57	\N	74	48	37	59	57	57	\N	54	56	54	\N	17	22	48	22	22
39573	2013-09-20	66	66	right	\N	\N	25	25	25	32	25	25	25	25	32	31	29	24	27	61	41	39	47	25	70	25	20	25	25	25	25	25	25	25	64	68	64	71	65
39573	2013-02-15	67	67	right	\N	\N	12	13	11	32	10	10	18	12	32	31	40	51	58	64	41	39	65	47	72	11	30	22	13	33	10	10	11	13	66	69	65	65	70
39573	2012-08-31	71	71	right	\N	\N	12	13	11	32	10	10	18	12	32	31	46	55	61	68	41	39	68	47	74	11	30	22	13	33	10	10	11	13	72	75	66	66	74
39573	2012-02-22	69	70	right	\N	\N	12	13	11	32	10	10	18	12	32	31	46	55	61	62	33	39	68	47	74	11	30	22	13	33	10	10	11	13	69	74	64	66	71
39573	2011-08-30	69	69	right	\N	\N	12	13	11	32	10	10	18	12	32	31	46	55	61	62	33	41	68	47	74	11	30	22	13	33	10	10	11	13	69	74	64	66	71
39573	2011-02-22	69	73	right	\N	\N	12	13	11	32	10	21	18	12	32	31	46	55	61	62	67	41	68	47	74	11	30	22	13	33	10	10	11	13	69	74	64	66	71
39573	2010-08-30	69	73	right	\N	\N	12	13	11	32	10	21	18	7	32	31	46	55	61	62	67	62	68	47	74	11	30	22	13	58	5	10	11	13	69	74	64	66	71
39573	2010-02-22	70	72	right	\N	\N	21	21	21	32	10	21	18	7	65	31	46	55	61	62	67	48	68	47	74	21	30	61	18	58	65	21	21	13	70	75	65	67	72
39573	2009-08-30	70	72	right	\N	\N	21	21	21	32	10	21	18	7	65	31	46	55	61	62	67	62	68	47	74	21	30	61	18	58	65	21	21	13	70	75	65	67	72
39573	2008-08-30	70	72	right	\N	\N	21	21	21	32	10	21	18	7	65	31	46	55	61	62	67	62	68	47	74	21	30	61	18	58	65	21	21	13	70	75	65	67	72
39573	2007-08-30	67	68	right	\N	\N	21	21	21	21	10	21	18	7	61	21	46	55	61	62	67	21	68	47	62	21	30	61	18	58	65	21	21	13	72	69	61	62	67
39573	2007-02-22	67	68	right	\N	\N	21	21	21	21	10	21	18	7	61	21	46	55	61	62	67	21	68	47	62	21	30	61	18	58	65	21	21	13	72	69	61	62	67
69713	2014-07-18	73	76	right	medium	medium	37	25	75	52	22	38	27	22	47	59	62	65	52	62	52	55	65	67	82	25	78	65	26	35	42	76	78	75	13	6	12	12	5
69713	2013-10-18	73	76	right	medium	medium	37	25	75	52	22	38	27	22	47	59	62	65	52	62	52	55	65	67	82	25	78	65	26	35	42	76	78	75	13	6	12	12	5
69713	2011-08-30	73	76	right	medium	medium	37	25	75	52	22	38	27	22	47	59	62	65	52	62	52	55	65	67	82	25	78	65	26	35	42	76	78	75	13	6	12	12	5
69713	2011-02-22	71	79	right	medium	medium	26	35	70	52	41	38	38	32	47	59	62	67	57	62	77	55	67	66	83	47	78	65	46	55	42	70	78	69	13	6	12	12	5
69713	2010-08-30	72	79	right	medium	medium	26	35	70	52	41	38	38	32	47	59	62	67	57	62	77	55	67	66	85	47	79	65	46	55	42	72	75	70	13	6	12	12	5
69713	2010-02-22	70	80	right	medium	medium	26	35	70	52	41	39	38	32	47	49	55	65	57	54	77	55	67	60	83	47	79	54	58	55	67	72	74	70	7	20	47	20	20
69713	2009-08-30	67	77	right	medium	medium	26	35	67	51	41	39	38	32	46	49	55	65	57	54	77	55	67	60	83	47	74	54	58	55	57	68	69	70	7	20	46	20	20
69713	2008-08-30	56	77	right	medium	medium	46	35	56	44	41	49	38	32	46	49	49	52	57	44	77	53	67	62	57	47	60	67	66	55	55	59	59	70	10	20	46	20	20
69713	2008-02-22	58	77	right	medium	medium	46	35	56	44	41	49	38	32	46	49	49	52	57	44	77	53	67	62	57	47	60	67	66	55	55	59	59	70	10	20	46	20	20
69713	2007-02-22	58	77	right	medium	medium	46	35	56	44	41	49	38	32	46	49	49	52	57	44	77	53	67	62	57	47	60	67	66	55	55	59	59	70	10	20	46	20	20
25636	2010-08-30	62	64	left	\N	\N	57	47	58	56	56	72	52	44	52	71	67	70	69	53	65	65	60	65	74	59	45	46	56	45	48	43	50	42	13	15	11	10	7
25636	2010-02-22	62	64	left	\N	\N	57	47	58	56	56	72	52	44	52	71	67	70	69	53	65	65	60	65	74	59	45	37	50	45	45	43	50	42	10	20	52	20	20
25636	2009-08-30	62	64	left	\N	\N	57	47	58	56	56	72	52	44	52	71	67	70	69	53	65	65	60	65	74	59	45	37	50	45	45	43	50	42	10	20	52	20	20
25636	2009-02-22	62	64	left	\N	\N	57	47	58	56	56	72	52	44	52	71	67	70	69	53	65	65	60	65	74	59	45	37	50	45	45	25	29	42	10	20	52	20	20
25636	2008-08-30	62	64	left	\N	\N	57	47	58	56	56	72	52	44	52	71	67	70	69	53	65	65	60	65	74	59	45	37	50	45	45	25	29	42	10	20	52	20	20
25636	2007-08-30	63	64	left	\N	\N	62	52	63	59	56	72	52	54	62	67	65	67	69	53	65	65	60	65	74	59	45	54	50	45	45	25	39	42	10	20	62	20	20
25636	2007-02-22	60	61	left	\N	\N	62	66	53	59	56	50	52	55	62	59	55	50	69	53	65	58	60	62	50	59	50	54	50	45	55	35	39	42	10	5	62	6	8
41021	2010-02-22	62	68	right	\N	\N	43	68	53	54	\N	61	\N	48	37	60	66	64	\N	65	\N	66	\N	61	58	64	33	50	46	\N	61	25	25	\N	9	25	37	25	25
41021	2009-08-30	64	68	right	\N	\N	43	71	53	54	\N	63	\N	48	37	61	66	68	\N	67	\N	66	\N	61	58	66	33	50	46	\N	61	25	25	\N	9	25	37	25	25
41021	2009-02-22	63	68	right	\N	\N	43	68	53	54	\N	63	\N	48	37	61	63	66	\N	67	\N	66	\N	61	58	66	33	50	46	\N	61	25	25	\N	9	25	37	25	25
41021	2008-08-30	64	68	right	\N	\N	43	66	53	54	\N	61	\N	48	37	58	78	74	\N	71	\N	66	\N	62	63	58	33	50	46	\N	61	25	25	\N	9	25	37	25	25
41021	2007-08-30	68	70	right	\N	\N	46	68	63	61	\N	65	\N	53	37	66	73	72	\N	71	\N	68	\N	62	65	64	53	50	46	\N	66	23	24	\N	9	25	37	25	25
41021	2007-02-22	70	69	right	\N	\N	51	69	70	48	\N	66	\N	69	48	69	69	70	\N	70	\N	71	\N	70	74	59	65	50	46	\N	69	23	49	\N	9	10	48	10	12
37866	2012-02-22	65	65	right	medium	high	51	33	63	61	36	43	35	47	55	53	64	67	71	70	69	65	71	83	63	43	85	68	42	60	46	62	67	66	13	13	6	12	14
37866	2011-08-30	65	65	right	medium	high	51	35	62	62	36	45	35	47	55	53	67	67	71	70	75	67	71	85	56	43	85	68	42	65	46	62	66	65	13	13	6	12	14
37866	2011-02-22	65	66	right	medium	high	51	35	62	62	36	45	35	47	55	53	65	67	67	70	69	67	66	78	64	43	85	68	42	65	46	62	66	65	13	13	6	12	14
37866	2010-08-30	65	67	right	medium	high	51	35	62	62	36	45	35	47	55	53	65	67	67	70	69	67	66	78	64	43	85	68	42	65	46	62	66	65	13	13	6	12	14
37866	2009-08-30	63	64	right	medium	high	53	32	62	60	36	42	35	46	54	53	65	68	67	70	69	67	66	78	62	39	85	64	65	65	63	58	62	65	7	23	54	23	23
37866	2007-08-30	63	64	right	medium	high	53	32	62	60	36	42	35	46	54	53	65	68	67	70	69	67	66	78	62	39	85	64	65	65	63	58	62	65	7	23	54	23	23
37866	2007-02-22	63	64	right	medium	high	53	32	58	59	36	43	35	58	48	53	65	68	67	70	69	66	66	78	57	39	85	64	65	65	63	58	66	65	7	11	48	15	15
39977	2014-02-21	64	64	left	medium	medium	50	38	66	62	23	42	50	54	64	50	50	35	60	63	61	57	61	68	71	58	66	65	32	58	52	64	65	65	15	8	5	9	9
39977	2014-02-14	64	66	left	medium	medium	50	38	66	62	23	42	50	54	64	50	50	35	60	63	61	57	61	68	71	58	66	65	32	58	52	64	65	65	15	8	5	9	9
39977	2013-09-20	65	66	left	medium	medium	50	38	66	63	23	42	50	54	64	52	50	35	60	64	61	57	62	71	71	58	68	68	32	58	52	64	66	65	15	8	5	9	9
39977	2013-02-15	65	66	left	medium	medium	50	38	66	63	23	42	50	54	64	52	50	35	60	64	61	57	62	71	71	58	68	68	32	58	52	64	66	65	15	8	5	9	9
39977	2012-08-31	65	66	left	medium	medium	50	38	66	63	23	42	50	54	64	52	50	36	60	64	58	57	62	71	71	58	68	68	32	58	52	64	66	65	15	8	5	9	9
39977	2012-02-22	64	65	left	medium	medium	50	38	66	63	23	42	50	54	64	52	50	36	60	61	64	57	62	71	71	58	66	68	32	58	52	60	65	63	15	8	5	9	9
39977	2011-08-30	64	65	left	medium	medium	50	38	66	63	23	42	50	54	64	52	50	43	60	61	64	57	62	71	71	58	66	68	32	58	52	60	65	63	15	8	5	9	9
39977	2010-08-30	63	68	left	medium	medium	50	38	62	63	23	42	50	54	64	52	56	58	60	61	64	57	61	68	67	58	66	68	32	62	52	60	65	63	15	8	5	9	9
39977	2009-08-30	61	72	left	medium	medium	50	48	57	57	23	52	50	54	64	52	56	58	60	61	64	57	61	68	63	68	66	62	68	62	64	60	65	63	9	21	64	21	21
39977	2009-02-22	61	72	right	medium	medium	50	48	57	57	23	52	50	54	64	52	56	58	60	61	64	57	61	68	63	68	66	62	68	62	64	60	65	63	9	21	64	21	21
39977	2008-08-30	59	72	right	medium	medium	50	48	57	57	23	52	50	54	53	52	56	58	60	61	64	57	61	68	63	68	56	62	68	62	64	60	59	63	9	21	53	21	21
39977	2007-02-22	59	72	right	medium	medium	50	48	57	57	23	52	50	54	53	52	56	58	60	61	64	57	61	68	63	68	56	62	68	62	64	60	59	63	9	21	53	21	21
33676	2008-08-30	61	63	right	\N	\N	23	23	28	57	\N	23	\N	39	65	35	60	60	\N	63	\N	64	\N	54	71	32	23	69	9	\N	65	23	23	\N	60	63	65	58	61
33676	2007-02-22	61	63	right	\N	\N	23	23	28	57	\N	23	\N	39	65	35	60	60	\N	63	\N	64	\N	54	71	32	23	69	9	\N	65	23	23	\N	60	63	65	58	61
27508	2011-08-30	64	64	left	high	medium	65	37	67	65	52	54	35	62	57	64	61	62	61	63	61	70	65	63	78	60	63	67	52	64	54	61	66	65	5	15	7	10	12
27508	2011-02-22	65	72	left	high	medium	65	37	67	65	52	54	35	62	57	64	61	65	60	63	68	70	62	76	71	60	63	68	60	71	54	61	66	65	5	15	7	10	12
27508	2010-08-30	67	72	left	high	medium	65	37	67	65	52	54	35	62	57	64	65	67	60	66	69	70	65	76	71	60	68	69	65	67	54	66	69	67	5	15	7	10	12
27508	2010-02-22	69	75	left	high	medium	65	32	67	67	52	52	35	63	58	64	69	73	60	68	69	74	65	82	71	60	72	69	68	67	71	66	71	67	7	20	58	20	20
27508	2009-08-30	69	75	left	high	medium	65	32	67	67	52	52	35	63	58	64	69	73	60	68	69	74	65	82	71	60	72	69	68	67	71	66	71	67	7	20	58	20	20
27508	2009-02-22	69	75	left	high	medium	65	32	67	67	52	52	35	63	55	64	69	73	60	68	69	74	65	82	71	60	72	69	68	67	71	66	71	67	7	20	55	20	20
27508	2008-08-30	68	75	left	high	medium	66	32	70	67	52	51	35	63	56	64	69	73	60	68	69	74	65	78	71	60	72	66	64	67	69	68	71	67	7	20	56	20	20
27508	2007-08-30	72	75	left	high	medium	71	52	70	67	52	67	35	63	62	65	72	76	60	68	69	74	65	83	73	60	72	66	65	67	69	73	71	67	7	20	62	20	20
27508	2007-02-22	70	75	left	high	medium	50	42	77	67	52	50	35	69	56	63	72	73	60	68	69	69	65	78	73	45	78	66	65	67	69	78	71	67	7	7	56	5	8
37988	2011-02-22	64	73	right	\N	\N	46	52	78	63	36	27	26	46	61	58	35	45	37	45	71	62	56	72	73	51	64	75	58	72	60	60	68	61	10	9	12	14	15
37988	2010-08-30	66	73	right	\N	\N	47	53	80	64	37	27	43	46	62	61	37	47	43	47	72	65	56	73	74	53	66	77	56	73	60	62	71	63	10	9	12	14	15
37988	2009-08-30	68	73	right	\N	\N	59	62	83	69	37	43	43	46	62	61	43	51	43	66	72	65	56	71	74	53	70	73	74	73	75	65	71	63	11	22	62	22	22
37988	2009-02-22	70	73	right	\N	\N	59	62	85	71	37	46	43	46	61	61	43	53	43	66	72	65	56	74	78	53	71	74	75	73	76	67	74	63	12	22	61	22	22
37988	2008-08-30	72	77	right	\N	\N	60	62	85	73	37	46	43	51	63	61	46	56	43	66	72	67	56	74	78	54	73	74	75	73	76	71	76	63	12	22	63	22	22
37988	2007-08-30	76	77	right	\N	\N	60	62	85	73	37	46	43	51	63	61	46	56	43	66	72	67	56	74	78	54	73	74	75	73	76	71	76	63	12	22	63	22	22
37988	2007-02-22	71	73	right	\N	\N	63	62	84	74	37	49	43	76	64	59	47	57	43	63	72	67	56	73	80	54	75	74	75	73	76	68	76	63	12	15	64	8	5
36849	2016-03-24	65	65	left	medium	medium	68	42	57	64	64	57	63	65	65	63	62	57	68	62	72	67	64	74	60	68	65	67	53	59	63	64	67	67	12	11	15	10	15
36849	2016-02-11	65	65	left	medium	medium	68	42	57	64	64	57	63	65	65	63	62	59	68	62	72	67	64	74	60	68	65	67	53	59	63	64	67	67	12	11	15	10	15
36849	2015-09-21	66	66	left	medium	medium	68	42	57	64	64	57	63	65	65	63	64	61	70	64	72	67	64	75	60	68	65	67	53	59	63	66	68	68	12	11	15	10	15
36849	2015-03-13	65	65	left	medium	medium	68	46	57	64	66	58	64	65	65	63	66	64	71	64	72	67	64	76	61	68	65	66	52	58	64	63	66	65	11	10	14	9	14
36849	2014-09-18	65	65	left	medium	medium	68	46	57	64	66	58	64	65	65	63	66	64	71	64	72	67	64	76	61	68	65	66	52	58	64	63	66	65	11	10	14	9	14
36849	2014-04-04	65	65	left	medium	medium	68	48	57	64	66	60	64	65	65	63	66	65	71	64	72	67	64	76	61	68	65	66	52	58	64	63	66	65	11	10	14	9	14
36849	2013-09-20	66	66	left	medium	medium	69	48	57	64	66	62	64	65	65	64	68	66	74	65	72	67	64	80	64	68	65	63	52	58	64	64	67	66	11	10	14	9	14
36849	2013-02-15	64	64	left	medium	medium	69	48	57	64	66	62	64	65	65	64	68	66	74	65	72	67	64	80	64	68	61	63	52	58	64	61	63	62	11	10	14	9	14
36849	2012-08-31	64	64	left	medium	medium	69	48	57	64	66	62	64	65	65	64	68	68	74	65	70	67	64	78	63	68	61	63	52	64	64	61	63	62	11	10	14	9	14
36849	2011-08-30	64	64	left	medium	medium	69	48	57	64	66	62	64	65	65	64	68	68	74	65	74	67	64	78	63	68	61	63	52	64	64	61	63	62	11	10	14	9	14
36849	2011-02-22	62	65	left	medium	medium	69	48	57	64	66	62	64	65	65	64	67	68	69	65	60	67	62	75	58	68	61	56	52	62	64	59	62	59	11	10	14	9	14
36849	2010-08-30	64	65	left	medium	medium	69	48	53	66	66	56	64	65	65	61	67	68	69	65	60	67	62	75	58	68	61	60	52	62	64	64	66	65	11	10	14	9	14
36849	2010-02-22	65	67	left	medium	medium	69	48	53	66	66	56	64	65	65	61	67	68	69	65	60	67	62	75	58	68	61	66	65	62	64	62	65	65	10	20	65	20	20
36849	2009-08-30	64	67	left	medium	medium	67	46	53	64	66	56	64	65	63	61	66	68	69	64	60	67	62	75	58	66	61	65	64	62	57	61	63	65	10	20	63	20	20
36849	2008-08-30	63	66	left	medium	medium	65	46	53	64	66	56	64	65	63	61	64	65	69	64	60	67	62	72	58	66	61	65	64	62	57	61	63	65	10	20	63	20	20
36849	2007-08-30	65	66	left	medium	medium	44	46	56	59	66	50	64	50	48	59	56	59	69	64	60	25	62	72	71	57	71	60	56	62	57	70	67	65	10	20	48	20	20
36849	2007-02-22	64	66	left	medium	medium	43	45	55	58	66	49	64	56	47	58	55	58	69	63	60	24	62	71	70	56	70	60	56	62	56	69	66	65	10	15	47	13	14
35580	2010-02-22	72	76	left	\N	\N	77	54	65	72	\N	76	\N	45	59	74	65	67	\N	68	\N	72	\N	85	70	68	69	79	76	\N	74	70	70	\N	14	22	59	22	22
35580	2009-08-30	72	76	left	\N	\N	77	54	65	72	\N	76	\N	45	59	74	65	67	\N	68	\N	72	\N	85	70	68	69	79	76	\N	74	70	70	\N	14	22	59	22	22
35580	2009-02-22	72	76	left	\N	\N	77	54	65	72	\N	76	\N	45	59	74	65	67	\N	68	\N	72	\N	85	70	68	69	79	76	\N	74	70	70	\N	14	22	59	22	22
35580	2007-08-30	72	76	left	\N	\N	77	54	65	72	\N	76	\N	45	59	74	65	67	\N	68	\N	72	\N	85	70	68	69	79	76	\N	74	70	70	\N	14	22	59	22	22
35580	2007-02-22	78	76	left	\N	\N	77	54	65	76	\N	76	\N	74	72	74	75	81	\N	68	\N	72	\N	85	70	68	69	79	76	\N	74	70	74	\N	14	6	72	8	9
21834	2014-05-02	65	65	left	medium	medium	65	54	57	66	53	67	62	66	64	65	65	67	69	63	65	61	62	70	57	60	61	65	62	62	64	61	62	60	7	13	12	13	13
21834	2013-09-20	65	65	left	medium	medium	65	54	57	66	53	67	62	66	64	65	65	67	69	63	65	61	62	70	57	60	61	65	62	62	64	61	62	60	7	13	12	13	13
21834	2013-05-31	65	65	left	medium	medium	65	54	57	66	53	67	62	66	64	65	65	67	69	63	65	61	62	70	56	60	61	65	62	62	64	61	62	60	7	13	12	13	13
21834	2013-03-22	65	65	left	medium	medium	65	54	57	66	53	67	62	66	64	65	65	67	69	63	65	61	62	70	56	60	61	65	62	62	64	61	62	60	7	13	12	13	13
21834	2013-03-15	65	65	left	medium	medium	65	54	57	66	53	67	62	66	64	65	65	67	69	63	65	61	62	70	56	60	61	65	62	62	64	61	62	60	7	13	12	13	13
21834	2013-02-15	65	65	left	medium	medium	65	54	57	66	53	67	62	66	64	65	65	67	69	63	65	61	62	70	56	60	61	65	62	62	64	61	62	60	7	13	12	13	13
21834	2012-08-31	66	66	left	medium	medium	67	54	57	66	53	65	62	66	65	65	70	72	71	65	69	61	62	71	52	60	61	64	62	63	64	61	62	60	7	13	12	13	13
21834	2011-08-30	65	67	left	medium	medium	67	48	59	61	53	64	57	62	64	63	71	76	71	64	74	59	62	71	46	57	61	52	57	61	63	61	59	57	7	13	12	13	13
21834	2010-08-30	64	67	left	medium	medium	67	48	59	61	53	64	57	62	64	63	69	73	67	64	62	59	61	68	63	57	61	52	57	61	63	61	59	57	7	13	12	13	13
21834	2009-08-30	63	67	left	medium	medium	67	48	59	61	53	64	57	56	64	63	69	73	67	64	62	59	61	68	63	57	61	58	57	61	59	61	59	57	9	21	64	21	21
21834	2008-08-30	56	62	left	medium	medium	59	52	45	57	53	62	57	51	52	61	60	67	67	61	62	56	61	65	52	59	57	50	47	61	51	51	52	57	11	21	52	21	21
21834	2007-08-30	52	58	left	medium	medium	47	49	35	45	53	50	57	41	48	54	62	60	67	61	62	56	61	62	56	59	37	34	37	61	41	43	45	57	11	21	48	21	21
21834	2007-02-22	52	58	left	medium	medium	47	49	35	45	53	50	57	41	48	54	62	60	67	61	62	56	61	62	56	59	37	34	37	61	41	43	45	57	11	21	48	21	21
186621	2015-11-12	72	73	left	medium	medium	63	27	74	66	24	55	38	40	65	65	62	69	58	70	56	64	76	75	78	34	71	68	38	57	45	73	74	72	10	14	12	16	14
186621	2015-09-21	73	74	left	medium	medium	63	27	74	66	24	55	38	40	65	65	62	69	58	71	56	64	76	75	78	34	71	69	38	57	45	74	75	72	10	14	12	16	14
186621	2015-05-15	71	72	left	medium	medium	62	26	73	65	23	54	37	39	64	64	62	71	58	70	53	63	73	75	78	33	70	68	37	56	44	71	72	69	9	13	11	15	13
186621	2015-03-06	70	71	left	medium	medium	62	26	72	65	23	54	37	39	64	64	62	71	58	69	53	63	71	70	75	33	69	68	37	54	44	70	71	68	9	13	11	15	13
186621	2015-02-06	69	71	left	medium	medium	62	26	72	65	23	54	37	39	64	64	62	71	58	67	53	63	71	70	75	33	69	68	37	54	44	69	70	68	9	13	11	15	13
186621	2014-11-14	69	71	left	medium	medium	62	26	72	65	23	54	37	39	64	64	62	71	58	67	53	63	71	70	75	33	69	68	37	54	44	69	70	68	9	13	11	15	13
186621	2014-09-18	69	72	left	medium	medium	62	26	72	65	23	54	37	39	64	64	62	71	58	67	53	63	71	70	75	33	69	68	37	54	44	69	70	68	9	13	11	15	13
186621	2014-05-09	70	72	left	medium	medium	62	26	72	65	23	58	37	39	64	64	62	67	61	67	58	63	70	72	75	33	69	69	37	54	44	71	72	69	9	13	11	15	13
186621	2014-02-14	68	72	left	medium	medium	62	26	70	65	23	58	37	39	64	64	62	67	61	65	58	63	70	72	75	33	69	67	37	54	44	67	68	65	9	13	11	15	13
186621	2013-10-18	68	72	left	medium	medium	62	26	70	65	23	58	37	39	64	64	62	67	61	65	58	63	70	72	75	33	69	67	37	54	44	67	68	65	9	13	11	15	13
186621	2013-09-20	68	72	left	medium	medium	62	26	70	65	23	58	37	39	64	64	62	67	61	65	58	63	64	72	79	33	69	67	37	54	44	67	68	65	9	13	11	15	13
186621	2013-07-05	67	70	left	medium	medium	62	26	67	65	23	58	37	39	64	64	55	63	61	65	58	63	64	70	77	33	70	68	37	54	44	68	69	66	9	13	11	15	13
186621	2013-02-22	67	70	left	medium	medium	62	26	67	65	23	58	37	39	64	64	55	63	61	65	58	63	64	70	77	33	70	68	37	54	44	68	69	66	9	13	11	15	13
186621	2013-02-15	67	70	left	medium	medium	62	26	67	65	23	58	37	39	64	64	55	63	61	65	58	63	64	70	77	33	70	68	37	54	44	68	69	66	9	13	11	15	13
186621	2012-08-31	67	71	left	medium	medium	62	26	67	65	23	58	37	39	64	64	57	67	61	65	53	63	64	68	79	33	70	68	37	54	44	68	69	66	9	13	11	15	13
186621	2012-02-22	66	71	left	medium	medium	62	26	67	65	23	52	37	39	64	62	57	67	59	65	53	63	64	71	79	33	70	66	37	52	44	66	68	65	9	13	11	15	13
186621	2011-08-30	65	72	left	medium	medium	57	36	67	60	33	52	37	39	58	63	52	66	70	64	52	63	64	71	79	43	64	64	37	58	44	63	64	62	9	13	11	15	13
186621	2011-02-22	61	67	left	medium	medium	53	26	62	56	36	42	37	39	54	57	57	67	67	57	65	56	62	69	67	33	64	60	27	60	44	61	62	60	9	13	11	15	13
186621	2010-08-30	55	67	left	medium	medium	46	24	55	49	36	34	37	21	47	48	62	67	60	57	59	50	64	65	63	29	61	56	37	53	39	53	55	53	9	13	11	15	13
186621	2009-08-30	56	67	left	medium	medium	46	24	55	49	36	34	37	21	47	48	62	67	60	57	59	50	64	65	63	29	61	48	51	53	52	53	55	53	14	23	47	23	23
186621	2007-02-22	56	67	left	medium	medium	46	24	55	49	36	34	37	21	47	48	62	67	60	57	59	50	64	65	63	29	61	48	51	53	52	53	55	53	14	23	47	23	23
38233	2011-02-22	69	72	right	\N	\N	71	63	58	74	64	67	79	83	76	73	60	58	72	64	63	76	59	65	63	74	58	66	66	75	68	48	58	56	9	10	14	14	8
38233	2010-08-30	68	72	right	\N	\N	69	64	60	72	64	67	77	83	73	69	60	58	68	66	63	79	59	67	63	74	60	72	66	74	62	55	60	58	9	10	14	14	8
38233	2010-02-22	68	72	right	\N	\N	69	58	60	72	64	67	77	83	73	69	60	58	68	66	63	79	59	67	63	74	60	67	65	74	66	55	60	58	3	23	73	23	23
38233	2009-08-30	67	72	right	\N	\N	66	58	58	71	64	66	77	77	69	68	62	60	68	66	63	78	59	65	63	72	60	67	65	74	65	52	60	58	3	23	69	23	23
38233	2008-08-30	64	68	right	\N	\N	64	53	61	69	64	63	77	73	67	68	61	60	68	62	63	76	59	58	63	74	55	62	60	74	58	44	51	58	3	23	67	23	23
38233	2007-08-30	64	64	right	\N	\N	67	51	63	69	64	63	77	66	67	68	63	64	68	58	63	73	59	60	59	64	65	59	57	74	48	44	46	58	3	23	67	23	23
38233	2007-02-22	63	65	right	\N	\N	67	24	63	69	64	63	77	48	67	68	63	64	68	48	63	49	59	54	59	58	65	59	57	74	48	44	46	58	3	4	67	7	9
119117	2016-05-26	71	71	right	high	medium	68	54	62	67	67	67	69	67	64	69	78	76	78	70	75	75	81	73	62	71	73	69	66	66	59	71	72	74	13	12	11	6	15
119117	2016-03-24	71	71	right	high	medium	68	54	62	67	67	67	69	67	64	69	78	76	78	70	75	75	81	73	62	71	73	69	66	66	59	71	72	74	13	12	11	6	15
119117	2016-01-28	72	72	right	high	medium	68	54	62	67	67	67	69	67	64	69	82	79	80	70	75	78	81	73	62	71	73	69	66	66	59	71	74	76	13	12	11	6	15
119117	2015-11-19	72	72	right	high	medium	68	54	62	67	67	67	69	67	64	69	82	79	80	70	75	78	81	73	62	71	73	69	66	66	59	71	74	76	13	12	11	6	15
119117	2015-10-23	70	70	right	high	medium	68	54	62	67	67	67	69	67	64	69	82	79	80	70	75	78	81	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2015-02-13	70	70	right	high	medium	68	54	62	67	67	67	69	67	64	69	82	79	80	70	75	78	81	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2014-09-18	69	70	right	high	medium	71	54	62	67	67	67	69	67	68	69	82	79	80	70	75	78	81	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2014-05-16	69	70	right	high	medium	71	54	62	67	67	67	69	67	68	69	82	79	80	70	75	78	81	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2013-09-20	69	70	right	high	medium	71	54	62	67	67	67	69	67	68	69	82	79	80	70	75	78	81	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2013-03-15	69	71	right	high	medium	71	54	62	67	67	67	69	67	69	69	81	79	76	70	75	78	78	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2013-02-15	69	71	right	high	medium	71	54	62	67	67	67	69	67	69	69	81	79	76	70	75	78	78	73	62	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2012-08-31	69	71	right	high	medium	71	54	62	67	67	67	69	67	69	69	81	78	76	70	74	78	75	73	61	71	71	65	65	66	59	68	70	71	13	12	11	6	15
119117	2012-02-22	68	71	right	high	medium	71	61	60	66	67	67	69	67	68	69	80	78	76	70	74	78	73	71	59	71	68	62	63	63	59	66	68	69	13	12	11	6	15
119117	2011-08-30	67	71	right	medium	medium	69	61	47	62	67	64	69	67	63	67	90	82	74	66	76	73	74	71	69	71	58	58	56	58	48	60	63	60	13	12	11	6	15
119117	2011-02-22	65	72	right	medium	medium	70	62	47	56	67	64	69	57	58	67	75	71	68	66	68	73	69	68	57	65	56	53	58	62	44	45	62	50	13	12	11	6	15
119117	2010-08-30	64	72	right	medium	medium	70	59	47	54	67	64	69	57	56	67	75	71	67	66	68	71	69	68	57	64	56	53	58	59	44	45	62	48	13	12	11	6	15
119117	2009-08-30	64	72	right	medium	medium	70	59	47	54	67	64	69	57	56	67	75	71	67	66	68	71	69	68	57	64	56	50	52	59	61	45	62	48	1	23	56	23	23
119117	2008-08-30	64	70	right	medium	medium	70	59	47	54	67	64	69	57	56	67	75	71	67	66	68	71	69	68	57	64	51	42	49	59	61	45	62	48	1	23	56	23	23
119117	2007-02-22	64	70	right	medium	medium	70	59	47	54	67	64	69	57	56	67	75	71	67	66	68	71	69	68	57	64	51	42	49	59	61	45	62	48	1	23	56	23	23
178249	2012-08-31	66	72	right	medium	low	61	64	39	64	62	72	57	58	60	72	83	82	84	67	85	67	77	64	51	63	23	15	54	51	54	17	26	24	10	13	7	11	14
178249	2012-02-22	65	70	right	medium	low	60	62	37	62	62	72	57	58	55	72	83	82	84	67	85	65	77	62	37	64	23	15	54	48	54	17	26	24	10	13	7	11	14
178249	2011-08-30	68	75	right	medium	low	62	62	37	61	61	74	59	58	56	72	83	82	84	66	87	60	77	65	37	65	23	35	52	52	54	15	28	24	10	13	7	11	14
178249	2011-02-22	68	74	right	medium	low	57	62	40	65	61	74	59	58	60	72	79	77	75	67	55	60	67	65	47	63	23	35	62	57	54	15	28	24	10	13	7	11	14
178249	2010-08-30	64	74	right	medium	low	50	58	39	65	57	76	59	53	60	71	79	78	75	64	47	58	62	65	42	56	23	35	62	57	54	15	28	24	10	13	7	11	14
178249	2010-02-22	62	74	right	medium	low	50	46	39	65	57	72	59	51	60	67	79	78	75	64	47	57	62	50	34	59	23	38	57	57	53	22	28	24	13	22	60	22	24
178249	2009-08-30	62	74	right	medium	low	50	46	39	65	57	72	59	51	60	67	79	78	75	64	47	57	62	50	34	59	23	38	57	57	53	22	28	24	13	22	60	22	24
178249	2009-02-22	57	74	right	medium	low	56	43	34	63	57	68	59	51	60	66	62	65	75	60	47	55	62	53	47	52	23	38	45	57	53	22	28	24	3	22	60	22	22
178249	2007-02-22	57	74	right	medium	low	56	43	34	63	57	68	59	51	60	66	62	65	75	60	47	55	62	53	47	52	23	38	45	57	53	22	28	24	3	22	60	22	22
25995	2013-02-15	65	65	right	medium	medium	52	40	68	50	49	46	43	49	57	46	47	49	58	60	60	56	65	55	77	47	73	69	41	57	41	62	67	65	6	9	9	11	8
25995	2011-08-30	65	65	right	medium	medium	52	40	68	50	49	46	43	49	57	46	47	49	58	60	60	56	65	55	77	47	73	69	41	57	41	62	67	65	6	9	9	11	8
25995	2011-02-22	67	76	right	medium	medium	52	40	68	50	49	46	43	49	57	46	57	61	58	60	80	56	65	68	77	47	73	69	41	57	41	62	67	65	6	9	9	11	8
25995	2010-02-22	67	76	right	medium	medium	52	40	68	50	49	46	43	49	57	46	57	61	58	60	80	56	65	68	77	47	73	69	41	57	41	62	67	65	6	9	9	11	8
25995	2009-08-30	73	77	right	medium	medium	46	40	76	52	49	46	43	49	74	46	66	61	58	60	80	36	65	74	83	47	73	71	77	57	52	62	78	65	6	9	74	11	8
25995	2008-08-30	73	77	right	medium	medium	46	40	76	52	49	46	43	49	74	46	66	61	58	60	80	36	65	74	83	47	73	71	77	57	52	62	78	65	6	9	74	11	8
25995	2007-08-30	73	77	right	medium	medium	46	40	76	52	49	46	43	49	74	46	66	61	58	60	80	36	65	74	83	47	73	71	77	57	52	62	78	65	6	9	74	11	8
25995	2007-02-22	73	77	right	medium	medium	46	40	76	52	49	46	43	49	74	46	66	61	58	60	80	36	65	74	83	47	73	71	77	57	52	62	78	65	6	9	74	11	8
148326	2009-08-30	52	60	left	\N	\N	52	30	45	53	\N	37	\N	50	55	47	47	52	\N	51	\N	59	\N	65	64	54	57	47	48	\N	50	50	49	\N	6	21	55	21	21
148326	2008-08-30	51	60	left	\N	\N	52	22	45	53	\N	27	\N	50	55	37	47	52	\N	51	\N	59	\N	65	64	54	57	47	48	\N	50	50	49	\N	6	21	55	21	21
148326	2007-02-22	51	60	left	\N	\N	52	22	45	53	\N	27	\N	50	55	37	47	52	\N	51	\N	59	\N	65	64	54	57	47	48	\N	50	50	49	\N	6	21	55	21	21
39151	2008-08-30	63	65	left	\N	\N	44	29	62	58	\N	51	\N	39	50	60	62	64	\N	57	\N	54	\N	69	71	43	74	52	74	\N	60	61	60	\N	14	20	50	20	20
39151	2007-08-30	63	62	left	\N	\N	44	29	62	58	\N	51	\N	39	50	60	62	64	\N	57	\N	54	\N	69	71	43	74	52	74	\N	60	61	60	\N	14	20	50	20	20
39151	2007-02-22	63	62	right	\N	\N	44	29	62	58	\N	51	\N	60	50	60	62	64	\N	57	\N	54	\N	69	71	43	74	52	74	\N	60	61	60	\N	14	6	50	6	13
104382	2016-02-18	76	77	right	high	medium	76	51	60	75	54	77	75	54	70	79	78	78	86	78	78	73	73	86	65	63	73	71	71	63	48	63	76	80	11	12	11	16	8
104382	2015-12-03	75	76	right	high	medium	76	51	60	74	54	77	75	54	68	79	77	76	86	78	78	71	73	86	65	63	73	71	69	63	48	59	75	78	11	12	11	16	8
104382	2015-11-06	75	77	right	high	medium	76	51	60	74	54	77	75	54	68	79	77	76	86	78	78	71	73	86	65	63	73	71	69	63	48	59	75	78	11	12	11	16	8
104382	2015-10-16	75	78	right	high	medium	76	51	60	74	54	77	75	54	68	79	77	76	86	78	78	71	73	86	65	63	73	71	69	63	48	59	75	78	11	12	11	16	8
104382	2015-09-21	75	78	right	high	medium	76	51	60	74	54	77	75	54	68	79	78	77	86	78	79	71	73	86	66	63	73	71	69	63	48	59	75	78	11	12	11	16	8
104382	2014-09-18	73	76	right	high	medium	71	46	59	72	53	74	74	53	67	77	77	78	86	76	79	68	70	86	57	62	72	69	68	62	47	68	72	74	10	11	10	15	7
104382	2014-05-09	73	76	right	high	medium	71	46	59	74	53	74	74	53	71	76	83	81	86	75	80	68	71	86	56	62	72	69	68	66	47	68	72	74	10	11	10	15	7
104382	2013-09-20	74	76	right	high	medium	82	46	59	74	53	74	73	53	71	76	83	81	86	75	80	68	71	86	56	62	72	69	68	66	47	68	72	74	10	11	10	15	7
104382	2013-04-26	72	75	right	high	medium	82	46	57	72	53	75	73	53	74	75	82	81	86	74	80	68	72	86	57	62	71	68	67	67	47	67	69	72	10	11	10	15	7
104382	2013-03-08	72	75	right	high	medium	82	46	57	72	53	75	73	53	74	75	82	81	86	74	80	68	72	86	57	62	71	68	67	67	47	67	69	72	10	11	10	15	7
104382	2013-02-15	73	76	right	high	medium	79	56	59	72	53	75	73	53	70	75	82	81	86	75	80	68	79	86	57	62	71	68	72	67	47	68	69	74	10	11	10	15	7
104382	2012-08-31	72	77	right	high	medium	79	56	58	71	53	75	73	53	71	76	82	81	86	74	82	68	75	85	57	62	70	67	72	67	47	70	65	74	10	11	10	15	7
104382	2012-02-22	72	76	right	high	low	76	56	58	71	53	73	73	53	71	74	82	81	84	74	82	68	75	85	63	62	70	67	72	67	47	70	65	74	10	11	10	15	7
104382	2011-08-30	72	77	right	high	low	75	58	63	71	53	73	73	53	72	74	80	81	84	75	82	68	75	85	63	62	65	70	69	62	47	72	68	72	10	11	10	15	7
104382	2011-02-22	72	80	right	high	low	79	58	63	71	53	72	73	53	76	74	78	76	80	74	68	68	69	75	63	62	63	77	72	74	47	70	65	66	10	11	10	15	7
104382	2010-08-30	71	78	right	high	low	76	58	63	71	53	72	73	53	76	74	78	76	80	74	68	68	69	72	63	62	63	77	72	74	47	70	65	66	10	11	10	15	7
104382	2010-02-22	67	76	right	high	low	76	42	51	69	53	71	73	53	70	72	78	75	80	74	68	68	69	72	63	60	63	72	73	74	74	70	63	66	15	21	70	21	21
104382	2009-08-30	65	72	right	high	low	66	39	53	64	53	72	73	53	58	66	78	75	80	71	68	63	69	72	63	45	58	60	65	74	58	59	58	66	5	21	58	21	21
104382	2008-08-30	63	72	right	high	low	57	39	53	58	53	66	73	53	53	64	78	76	80	71	68	63	69	72	63	45	63	57	56	74	58	59	58	66	5	21	53	21	21
104382	2007-08-30	57	72	right	high	low	57	29	51	58	53	66	73	53	53	64	67	72	80	67	68	58	69	65	45	35	48	43	47	74	48	54	56	66	5	21	53	21	21
104382	2007-02-22	57	72	right	high	low	57	29	51	58	53	66	73	53	53	64	67	72	80	67	68	58	69	65	45	35	48	43	47	74	48	54	56	66	5	21	53	21	21
38389	2016-05-05	72	72	right	medium	medium	37	59	81	58	47	34	32	37	56	57	48	51	48	58	55	61	69	56	85	54	82	71	62	47	59	73	70	68	11	6	12	13	15
38389	2015-10-16	72	72	right	medium	medium	37	59	81	58	47	34	32	37	56	57	48	51	48	58	55	61	69	56	85	54	82	71	62	47	59	74	70	68	11	6	12	13	15
38389	2015-10-09	72	72	right	medium	medium	37	59	81	62	47	34	32	37	61	57	48	51	48	64	55	61	69	56	85	54	82	71	62	47	59	74	70	68	11	6	12	13	15
38389	2015-04-17	72	72	right	medium	medium	37	59	81	62	47	34	32	37	61	57	48	51	48	64	55	61	69	56	85	54	82	71	62	47	59	74	70	68	11	6	12	13	15
38389	2014-10-24	72	72	right	medium	medium	37	59	82	62	47	34	32	37	61	57	48	51	48	64	55	61	69	56	85	54	85	71	62	47	59	74	70	68	11	6	12	13	15
38389	2014-09-18	71	71	right	medium	medium	37	59	82	62	47	34	32	37	61	57	48	51	48	64	55	61	69	56	85	54	85	71	62	47	59	68	70	68	11	6	12	13	15
38389	2014-09-12	70	70	right	medium	medium	37	59	82	62	47	34	32	37	61	57	48	51	38	64	37	61	63	56	85	54	85	71	62	47	59	66	70	68	11	6	12	13	15
38389	2014-03-07	70	70	right	medium	medium	37	59	82	62	47	34	32	37	61	57	48	51	38	64	37	61	63	56	85	54	85	71	62	47	59	66	70	68	11	6	12	13	15
38389	2013-11-29	71	71	right	medium	medium	37	59	84	62	47	34	32	37	61	57	42	48	38	64	37	61	63	66	85	54	83	71	62	47	59	67	68	66	11	6	12	13	15
38389	2013-11-15	71	71	right	medium	medium	37	59	84	62	47	34	32	37	61	57	42	48	38	64	37	61	63	66	81	54	83	71	62	47	59	69	70	68	11	6	12	13	15
38389	2013-09-20	71	71	right	medium	medium	37	59	84	62	47	34	32	37	61	57	42	48	38	64	37	61	63	66	81	54	83	71	62	47	59	69	70	68	11	6	12	13	15
38389	2013-08-16	72	72	right	medium	medium	37	59	83	62	47	34	32	37	61	57	38	46	35	64	37	61	63	66	83	54	85	71	62	47	59	69	72	68	11	6	12	13	15
38389	2013-06-07	72	72	right	medium	medium	37	59	83	62	47	34	32	37	61	57	38	46	35	64	37	61	63	66	83	54	85	71	62	47	59	69	72	68	11	6	12	13	15
38389	2013-02-15	72	72	right	medium	medium	37	59	83	62	47	34	32	37	61	57	38	46	35	64	37	61	63	66	83	54	85	71	62	47	59	69	72	68	11	6	12	13	15
38389	2012-08-31	73	74	right	medium	medium	37	59	84	62	47	34	32	37	61	57	38	48	37	66	38	61	65	67	84	54	83	73	63	53	59	72	74	69	11	6	12	13	15
38389	2012-02-22	74	75	right	medium	medium	46	60	85	63	47	38	33	37	61	58	47	52	45	66	45	63	65	73	78	54	76	76	60	53	61	76	78	71	11	6	12	13	15
38389	2011-08-30	74	75	right	medium	medium	46	50	83	63	47	43	33	37	61	58	47	54	45	67	45	65	65	73	78	54	74	76	57	51	61	76	78	73	11	6	12	13	15
38389	2011-02-22	75	76	right	medium	medium	46	66	85	66	47	53	33	37	63	63	53	63	51	67	79	65	66	71	83	54	71	76	58	69	64	76	78	73	11	6	12	13	15
38389	2010-08-30	74	76	right	medium	medium	46	63	85	64	47	51	33	37	58	61	53	61	50	66	79	62	61	67	83	54	68	76	66	64	60	76	78	71	11	6	12	13	15
38389	2009-08-30	73	77	right	medium	medium	51	56	83	64	47	51	33	37	58	61	53	61	50	66	79	60	61	68	81	43	68	65	66	64	63	74	78	71	12	23	58	23	23
38389	2009-02-22	72	77	right	medium	medium	51	56	83	64	47	51	33	37	58	61	53	61	50	66	79	60	61	68	81	43	68	65	66	64	63	73	78	71	12	23	58	23	23
38389	2008-08-30	72	77	right	medium	medium	51	56	83	64	47	51	33	37	60	61	53	61	50	66	79	60	61	68	83	43	68	65	66	64	63	73	78	71	12	23	60	23	23
38389	2007-08-30	74	73	right	medium	medium	51	66	83	67	47	53	33	46	62	63	53	63	50	66	79	65	61	69	78	45	63	65	66	64	61	71	73	71	12	23	62	23	23
38389	2007-02-22	71	73	right	medium	medium	49	64	79	67	47	55	33	71	57	64	54	59	50	64	79	66	61	68	74	32	63	65	66	64	71	68	70	71	12	15	57	11	7
39896	2008-08-30	57	64	right	\N	\N	63	25	64	59	\N	40	\N	37	51	52	52	49	\N	43	\N	29	\N	69	53	49	62	60	57	\N	52	55	62	\N	11	23	51	23	23
39896	2007-02-22	57	64	right	\N	\N	63	25	64	59	\N	40	\N	37	51	52	52	49	\N	43	\N	29	\N	69	53	49	62	60	57	\N	52	55	62	\N	11	23	51	23	23
181276	2016-01-28	82	88	left	medium	medium	68	84	80	67	71	76	64	66	58	76	80	85	64	73	48	86	71	80	92	76	72	27	84	69	80	27	30	30	8	15	14	7	10
181276	2015-12-10	81	87	left	medium	medium	68	84	78	67	71	76	64	66	58	76	80	85	64	73	48	85	71	80	90	75	72	27	81	69	80	27	30	30	8	15	14	7	10
181276	2015-11-26	80	86	left	medium	medium	68	82	78	67	71	76	64	66	58	76	80	85	64	73	48	85	71	78	90	74	72	27	80	69	80	27	30	30	8	15	14	7	10
181276	2015-09-21	80	86	left	medium	medium	68	82	78	67	70	76	64	66	58	76	79	85	64	73	48	85	71	76	90	72	72	27	78	69	80	27	30	30	8	15	14	7	10
181276	2015-05-29	80	86	left	medium	medium	69	82	78	67	70	77	62	63	59	78	80	86	64	73	48	85	70	73	90	75	72	27	77	69	80	24	26	25	8	15	14	7	10
181276	2015-05-22	79	84	left	medium	medium	68	81	78	67	70	76	62	63	58	78	79	85	64	73	48	84	70	73	90	72	72	27	77	69	79	24	26	25	8	15	14	7	10
181276	2015-05-15	79	85	left	medium	medium	68	81	78	67	69	76	60	62	58	78	79	85	64	73	48	84	70	73	90	72	72	27	77	69	79	25	25	22	8	15	14	7	10
181276	2015-05-08	80	85	left	medium	medium	68	81	78	67	69	77	60	62	58	80	79	86	64	73	48	84	70	73	90	72	72	27	77	69	79	25	25	22	8	15	14	7	10
181276	2015-05-01	80	85	left	medium	medium	68	81	78	67	69	77	60	62	58	80	79	86	64	73	48	84	70	73	90	72	72	27	77	69	75	25	25	22	8	15	14	7	10
181276	2015-04-10	80	85	left	medium	medium	68	81	78	67	69	77	56	51	58	80	79	86	64	73	48	84	70	73	90	72	72	27	77	69	75	25	25	22	8	15	14	7	10
181276	2015-03-13	80	84	left	medium	medium	68	81	78	67	69	77	56	51	58	80	79	86	64	73	48	84	70	73	90	72	72	27	77	69	75	25	25	22	8	15	14	7	10
181276	2015-02-27	80	86	left	medium	medium	68	83	78	67	69	77	56	51	58	80	79	86	64	73	48	84	70	73	90	72	72	27	77	69	75	25	25	22	8	15	14	7	10
181276	2015-02-13	80	86	left	medium	medium	68	83	78	67	69	77	56	51	58	80	82	86	64	73	48	84	70	73	90	72	72	27	77	69	75	25	25	22	8	15	14	7	10
181276	2014-09-18	80	86	left	high	medium	68	83	78	67	69	77	56	51	58	80	82	86	64	74	48	84	70	73	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2014-07-18	80	86	left	high	medium	68	81	77	67	69	77	56	51	58	80	82	86	49	74	48	84	70	73	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2013-12-13	80	86	left	high	medium	68	81	77	67	69	77	56	51	58	80	82	86	49	74	48	84	70	73	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2013-11-29	80	86	left	medium	medium	68	81	77	67	69	77	56	51	58	80	82	86	49	74	48	84	70	73	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2013-11-22	79	86	left	medium	medium	68	81	74	67	69	77	56	51	58	80	82	86	49	74	48	84	70	68	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2013-11-15	80	86	left	medium	medium	68	82	74	67	69	77	56	51	58	80	82	86	49	74	48	84	70	68	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2013-11-01	79	86	left	medium	medium	68	80	74	67	69	77	56	51	58	80	82	86	49	74	48	84	70	68	90	72	73	27	77	69	75	25	25	22	8	15	14	7	10
181276	2013-10-25	78	86	left	medium	medium	68	80	74	67	69	75	56	51	58	76	80	86	49	73	48	84	70	68	90	72	66	27	76	69	75	25	25	22	8	15	14	7	10
181276	2013-10-18	78	86	left	medium	medium	68	78	74	67	69	75	56	51	58	76	79	85	49	73	48	84	70	68	90	72	66	27	76	69	75	25	25	22	8	15	14	7	10
181276	2013-09-20	77	86	left	medium	medium	68	78	74	67	69	75	56	51	58	76	79	85	49	73	48	84	70	68	90	72	66	27	76	69	75	25	25	22	8	15	14	7	10
181276	2013-07-12	77	86	left	medium	medium	68	78	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-06-07	77	86	left	medium	medium	68	78	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-05-31	77	86	left	medium	low	68	78	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-05-03	77	86	left	medium	low	68	78	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-04-19	77	86	left	medium	low	68	78	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-03-22	77	86	left	medium	low	68	79	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-03-08	77	86	left	medium	low	68	79	74	67	69	75	56	51	58	76	81	85	49	73	48	84	70	68	90	72	66	27	76	69	75	17	25	22	8	15	14	7	10
181276	2013-03-01	76	86	left	medium	low	68	79	73	67	69	69	56	51	58	72	81	85	49	72	48	84	70	68	90	72	66	27	73	69	75	17	25	22	8	15	14	7	10
181276	2013-02-22	74	86	left	medium	low	68	78	68	67	69	68	56	51	58	68	79	83	49	71	48	84	70	68	89	72	66	27	72	69	75	17	25	22	8	15	14	7	10
181276	2013-02-15	74	86	left	medium	low	68	76	68	67	69	68	56	51	58	68	79	83	49	71	48	84	70	68	89	72	66	27	72	69	75	17	25	22	8	15	14	7	10
181276	2012-08-31	74	86	left	medium	low	68	78	68	67	69	68	56	51	58	68	79	83	49	71	48	84	70	68	88	72	66	27	72	69	69	17	25	22	8	15	14	7	10
181276	2012-02-22	75	88	left	medium	low	68	80	68	67	69	68	56	51	58	68	81	86	66	72	48	85	70	68	92	72	66	27	73	69	69	17	25	22	8	15	14	7	10
181276	2011-08-30	78	88	left	medium	low	68	83	68	67	69	71	56	51	58	68	84	88	71	72	48	85	73	68	94	72	66	27	73	69	69	17	25	22	8	15	14	7	10
181276	2011-02-22	74	88	left	medium	low	68	81	65	65	68	66	48	51	63	68	78	83	66	71	88	83	76	64	91	66	66	27	73	68	69	17	25	22	8	15	14	7	10
181276	2010-08-30	74	88	left	medium	low	68	78	63	67	68	66	48	51	53	68	80	85	66	68	88	80	76	64	92	66	58	27	66	66	64	17	25	22	8	15	14	7	10
181276	2007-02-22	74	88	left	medium	low	68	78	63	67	68	66	48	51	53	68	80	85	66	68	88	80	76	64	92	66	58	27	66	66	64	17	25	22	8	15	14	7	10
164352	2010-08-30	60	65	right	\N	\N	38	31	63	49	27	34	37	42	47	60	61	65	59	58	64	55	60	65	67	41	57	57	43	51	46	61	56	58	12	8	5	10	5
164352	2010-02-22	58	65	right	\N	\N	38	28	62	49	27	29	37	41	47	52	55	65	59	58	64	55	60	65	67	38	56	52	54	51	51	59	51	58	9	22	47	22	22
164352	2009-08-30	55	65	right	\N	\N	38	28	57	49	27	29	37	41	47	52	55	65	59	58	64	55	60	65	67	38	56	52	54	51	51	59	51	58	9	22	47	22	22
164352	2009-02-22	50	65	right	\N	\N	38	28	57	47	27	22	37	41	45	48	55	65	59	58	64	55	60	65	67	38	56	32	29	51	30	47	52	58	9	22	45	22	22
164352	2007-02-22	50	65	right	\N	\N	38	28	57	47	27	22	37	41	45	48	55	65	59	58	64	55	60	65	67	38	56	32	29	51	30	47	52	58	9	22	45	22	22
52280	2015-10-30	71	71	right	medium	medium	67	69	38	71	68	74	68	68	69	74	68	67	70	67	72	66	65	32	57	70	43	26	70	69	64	19	26	28	14	9	9	10	6
52280	2015-09-21	71	72	right	medium	medium	67	69	38	71	68	74	68	68	69	74	68	67	70	67	72	66	65	32	57	70	43	26	70	69	64	19	26	28	14	9	9	10	6
52280	2014-12-12	69	70	right	medium	medium	66	68	37	70	67	73	67	67	68	73	68	67	70	66	72	65	65	32	57	69	42	25	69	68	63	25	25	27	13	8	8	9	5
52280	2014-09-18	69	70	right	medium	medium	66	68	37	70	67	73	67	67	68	73	68	67	70	66	72	65	65	32	57	69	42	25	69	68	63	25	25	27	13	8	8	9	5
52280	2014-04-25	70	71	right	medium	medium	67	69	38	71	68	74	68	68	69	74	69	68	71	67	73	66	66	33	58	70	43	26	70	69	64	25	26	28	13	8	8	9	5
52280	2014-03-07	70	71	right	medium	medium	67	69	38	71	68	74	68	68	69	74	69	68	71	67	73	66	66	33	58	70	43	26	70	69	64	25	26	28	13	8	8	9	5
52280	2013-09-20	71	73	right	medium	medium	68	70	38	71	68	75	68	68	70	74	73	71	74	67	75	66	70	33	58	71	43	26	70	69	64	25	26	28	13	8	8	9	5
52280	2013-05-10	71	74	right	medium	low	69	70	38	71	69	76	68	68	70	74	72	71	74	67	75	66	69	33	57	72	43	26	70	69	64	19	26	28	13	8	8	9	5
52280	2013-03-22	72	74	right	medium	low	69	71	38	72	69	78	68	68	70	76	74	71	76	68	75	66	70	33	57	72	43	26	71	70	64	19	26	28	13	8	8	9	5
52280	2013-03-15	73	74	right	medium	low	69	71	38	73	69	80	68	68	70	78	76	73	78	68	76	66	74	33	57	73	43	26	71	71	64	19	26	28	13	8	8	9	5
52280	2013-02-15	73	74	right	medium	low	69	71	38	73	69	80	68	68	70	78	76	73	78	68	76	66	74	33	57	73	43	26	71	71	64	19	26	28	13	8	8	9	5
52280	2012-08-31	74	77	right	medium	low	70	71	38	73	69	81	68	70	70	80	80	78	81	73	76	66	75	36	56	73	46	26	71	71	64	19	26	28	13	8	8	9	5
52280	2012-02-22	75	78	right	medium	low	70	73	43	73	70	83	68	70	70	80	83	81	86	73	78	68	75	53	57	74	56	26	73	71	64	19	26	28	13	8	8	9	5
52280	2011-08-30	75	78	right	medium	low	71	74	43	73	66	80	67	69	70	78	86	81	90	70	78	68	75	53	58	72	46	23	71	72	64	19	25	28	13	8	8	9	5
52280	2011-02-22	73	78	right	medium	low	71	73	45	75	66	80	69	69	70	78	83	78	87	71	66	68	68	58	63	74	26	32	68	74	64	19	25	28	13	8	8	9	5
52280	2010-08-30	72	78	right	medium	low	71	68	45	75	66	76	69	69	70	75	78	76	73	71	51	68	68	58	53	73	26	32	68	74	64	19	25	28	13	8	8	9	5
52280	2010-02-22	73	78	right	medium	low	73	68	53	75	66	79	69	71	71	78	79	77	73	71	51	68	68	58	51	73	26	61	64	74	67	22	25	28	13	22	71	22	22
52280	2009-08-30	68	76	right	medium	low	64	64	52	69	66	75	69	72	67	74	75	76	73	67	51	65	68	56	61	69	36	57	53	74	67	29	35	28	3	22	67	22	22
52280	2009-02-22	67	79	right	medium	low	62	62	52	67	66	77	69	72	65	75	79	75	73	67	51	65	68	65	65	69	55	54	50	74	57	29	35	28	3	22	65	22	22
52280	2008-08-30	69	79	right	medium	low	62	62	52	67	66	77	69	72	65	75	79	75	73	67	51	65	68	65	65	69	55	54	50	74	57	29	35	28	3	22	65	22	22
52280	2007-02-22	69	79	right	medium	low	62	62	52	67	66	77	69	72	65	75	79	75	73	67	51	65	68	65	65	69	55	54	50	74	57	29	35	28	3	22	65	22	22
149367	2009-02-22	53	62	right	\N	\N	48	53	33	45	\N	54	\N	46	39	49	67	72	\N	68	\N	53	\N	60	45	46	35	34	37	\N	42	22	22	\N	8	22	39	22	22
149367	2007-02-22	53	62	right	\N	\N	48	53	33	45	\N	54	\N	46	39	49	67	72	\N	68	\N	53	\N	60	45	46	35	34	37	\N	42	22	22	\N	8	22	39	22	22
42594	2016-03-10	73	73	right	medium	high	73	55	79	72	42	73	44	39	68	74	68	69	44	67	42	79	78	72	88	70	74	75	66	63	50	75	78	72	12	12	11	7	16
42594	2016-03-03	74	74	right	medium	high	73	55	79	72	42	73	44	39	70	74	68	74	44	67	42	79	78	72	88	70	74	75	66	63	50	76	78	72	12	12	11	7	16
42594	2016-02-11	74	74	right	medium	high	73	55	79	74	42	75	44	39	74	74	68	74	44	67	42	72	78	72	88	67	74	75	66	63	50	76	78	72	12	12	11	7	16
42594	2016-01-28	74	74	right	medium	high	73	55	79	74	42	75	44	39	74	74	68	74	44	67	42	72	78	72	86	67	74	74	66	63	50	76	76	72	12	12	11	7	16
42594	2016-01-14	74	74	right	medium	high	73	55	79	74	42	75	44	39	74	74	68	74	44	67	42	72	78	72	84	67	74	74	66	63	50	76	76	72	12	12	11	7	16
42594	2015-11-06	73	73	right	medium	high	73	54	79	73	42	75	44	39	73	74	68	70	44	65	42	72	78	72	84	67	74	73	66	63	50	74	75	70	12	12	11	7	16
42594	2015-10-16	73	73	right	medium	high	73	54	79	73	42	75	44	39	73	74	68	70	44	65	42	72	78	72	84	60	74	73	66	63	50	74	75	70	12	12	11	7	16
42594	2015-09-21	74	74	right	medium	high	73	57	81	73	42	72	44	39	73	74	68	74	44	65	42	72	82	79	91	58	74	73	66	63	50	74	77	70	12	12	11	7	16
42594	2015-04-17	73	73	right	medium	medium	49	56	80	72	41	66	43	38	72	71	68	68	67	64	65	71	82	79	85	57	73	69	65	62	49	71	73	67	11	11	10	6	15
42594	2015-04-10	73	75	right	medium	medium	49	56	80	72	41	66	43	38	72	71	68	68	67	64	65	71	82	79	85	57	73	69	65	62	49	71	73	67	11	11	10	6	15
42594	2015-03-20	74	76	right	medium	medium	49	56	80	72	41	66	43	38	72	71	68	68	67	64	65	71	82	79	85	57	73	69	65	62	49	72	73	69	11	11	10	6	15
42594	2015-02-13	74	76	right	medium	medium	49	56	80	72	41	66	43	38	72	71	68	68	67	64	65	71	82	79	85	57	73	70	65	62	49	73	74	69	11	11	10	6	15
42594	2015-01-23	74	76	right	medium	medium	49	56	80	72	41	66	43	38	72	72	68	68	67	66	65	71	82	79	85	57	73	70	65	62	49	73	74	69	11	11	10	6	15
42594	2014-12-12	73	73	right	medium	medium	49	56	80	72	41	66	43	38	72	72	68	68	67	66	65	71	82	79	85	57	73	67	65	62	49	70	74	67	11	11	10	6	15
42594	2014-09-18	73	73	right	high	medium	49	56	79	72	41	66	43	38	72	72	68	68	67	66	65	71	82	81	85	57	74	67	65	62	49	70	75	67	11	11	10	6	15
42594	2013-06-07	73	73	right	high	medium	49	56	79	72	41	66	43	38	72	72	68	68	67	66	65	71	82	81	85	57	74	67	65	62	49	70	75	67	11	11	10	6	15
42594	2013-05-31	73	74	right	high	medium	49	56	79	72	41	66	43	38	72	72	68	68	67	66	65	71	82	81	85	57	80	67	65	62	49	62	73	72	11	11	10	6	15
42594	2013-05-24	72	74	right	high	medium	49	56	79	72	41	66	43	38	72	72	68	68	67	66	65	71	82	81	85	57	80	67	65	62	49	62	73	72	11	11	10	6	15
42594	2013-03-22	73	74	right	high	medium	49	48	79	71	41	66	43	38	73	72	68	68	67	68	65	71	82	81	85	57	77	63	58	63	49	63	75	73	11	11	10	6	15
42594	2013-03-08	73	74	right	high	medium	49	48	79	71	41	66	43	38	73	72	68	68	67	68	65	71	82	81	85	57	77	63	58	63	49	63	75	73	11	11	10	6	15
42594	2013-02-22	73	74	right	high	medium	49	48	79	71	41	66	43	38	73	72	68	68	67	68	65	66	82	81	85	37	77	63	58	63	49	63	75	73	11	11	10	6	15
42594	2013-02-15	73	74	right	high	low	49	48	79	71	41	66	43	38	73	72	68	68	67	68	65	66	82	81	85	37	77	63	58	63	49	63	75	73	11	11	10	6	15
42594	2012-08-31	73	74	right	high	low	49	48	79	71	41	68	43	38	73	71	68	68	71	68	58	66	82	83	85	37	77	63	58	63	49	63	75	73	11	11	10	6	15
42594	2012-02-22	72	73	right	high	low	49	40	80	71	41	68	43	38	73	71	74	68	71	67	56	63	82	83	85	37	74	60	58	63	49	59	74	73	11	11	10	6	15
42594	2011-08-30	71	73	right	high	low	56	35	74	66	41	66	43	36	68	68	74	68	71	66	54	58	75	78	83	37	72	64	43	56	42	64	74	71	11	11	10	6	15
42594	2011-02-22	68	74	right	high	low	47	27	72	64	41	64	43	36	57	67	68	78	61	59	72	60	75	71	77	34	67	57	43	57	42	57	72	71	11	11	10	6	15
42594	2010-08-30	70	80	right	high	low	47	27	72	64	41	64	43	36	57	67	68	73	61	57	72	60	70	71	77	34	67	64	43	57	42	69	72	71	11	11	10	6	15
42594	2010-02-22	70	80	right	high	low	45	30	74	65	41	64	43	41	57	67	66	71	61	67	72	23	70	69	74	34	73	60	61	57	68	69	71	71	8	20	57	20	20
42594	2009-08-30	70	80	right	high	low	45	30	75	62	41	44	43	41	57	63	68	68	61	67	72	23	70	69	74	34	72	63	61	57	68	69	73	71	8	20	57	20	20
42594	2009-02-22	71	83	right	high	low	46	31	76	63	41	45	43	42	58	64	69	69	61	68	72	24	70	70	73	35	73	64	62	57	69	70	74	71	1	20	58	20	20
42594	2008-08-30	70	83	right	high	low	46	31	76	63	41	45	43	42	58	64	69	69	61	68	72	24	70	70	73	35	69	64	62	57	69	70	69	71	1	20	58	20	20
42594	2007-08-30	71	83	right	high	low	46	31	73	63	41	45	43	42	58	64	69	69	61	68	72	24	70	70	73	35	69	64	62	57	61	70	69	71	1	20	58	20	20
42594	2007-02-22	58	68	right	high	low	46	16	43	58	41	45	43	61	58	45	65	63	61	68	72	24	70	57	69	15	67	64	62	57	61	62	64	71	1	3	58	8	2
46217	2010-02-22	65	68	left	\N	\N	63	62	35	62	\N	67	\N	65	58	69	68	69	\N	62	\N	64	\N	71	63	63	47	58	57	\N	63	30	31	\N	9	24	58	24	24
46217	2009-08-30	66	68	left	\N	\N	63	64	35	60	\N	67	\N	65	58	70	71	72	\N	65	\N	62	\N	76	66	62	60	58	57	\N	63	40	31	\N	9	24	58	24	24
46217	2007-08-30	66	68	left	\N	\N	63	64	35	60	\N	67	\N	65	58	70	71	72	\N	65	\N	62	\N	76	66	62	60	58	57	\N	63	40	31	\N	9	24	58	24	24
46217	2007-02-22	66	68	left	\N	\N	63	64	35	60	\N	67	\N	65	58	70	71	72	\N	65	\N	62	\N	76	66	62	60	58	57	\N	63	40	31	\N	9	24	58	24	24
37900	2016-04-28	71	71	right	medium	medium	12	13	12	36	11	11	11	15	38	32	52	41	45	75	42	40	71	29	64	16	16	17	16	45	17	18	14	13	72	69	65	71	72
37900	2015-09-21	72	72	right	medium	medium	12	13	12	36	11	11	11	15	38	32	52	41	45	75	42	40	71	29	64	16	16	17	16	45	17	18	14	13	73	69	65	71	74
37900	2014-09-18	71	71	right	medium	medium	25	25	25	35	25	25	25	25	37	31	52	41	45	74	42	39	70	29	64	25	25	25	25	25	25	25	25	25	72	68	64	70	73
37900	2014-02-21	71	71	right	medium	medium	25	25	25	35	25	25	25	25	37	31	52	41	45	74	42	39	70	29	64	25	25	25	25	25	25	25	25	25	72	68	64	70	73
37900	2013-09-20	70	71	right	medium	medium	25	25	25	35	25	25	25	25	37	31	52	41	45	74	42	39	65	29	64	25	25	25	25	25	25	25	25	25	72	68	62	69	72
37900	2013-05-10	69	71	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	42	65	15	15	21	15	10	16	17	13	12	72	68	59	65	72
37900	2013-04-12	69	71	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	42	65	15	15	21	15	10	16	17	13	12	72	68	59	65	72
37900	2013-03-28	69	71	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	42	65	15	15	21	15	27	16	17	13	12	72	68	59	65	72
37900	2013-03-08	69	71	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	42	65	15	15	21	15	27	16	17	13	12	72	68	59	65	72
37900	2013-02-15	68	70	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	42	65	15	15	21	15	27	16	17	13	12	71	67	57	64	72
37900	2012-08-31	68	70	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	58	65	15	15	21	15	27	16	17	13	12	71	67	57	64	72
37900	2012-02-22	68	72	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	58	65	15	15	21	15	27	16	17	13	12	71	67	57	64	72
37900	2011-08-30	68	72	right	medium	medium	11	12	11	35	10	10	10	14	37	31	62	61	67	70	52	39	75	58	65	15	15	21	15	27	16	17	13	12	71	67	62	64	72
37900	2011-02-22	69	75	right	medium	medium	11	12	13	35	10	21	10	14	37	31	65	65	67	70	62	39	75	58	65	15	11	20	15	37	16	17	13	12	72	67	62	63	74
37900	2010-08-30	69	75	right	medium	medium	11	12	34	35	10	21	5	14	37	31	65	65	67	70	62	39	75	58	65	15	11	20	15	65	16	17	8	12	72	67	62	63	74
37900	2010-02-22	67	75	right	medium	medium	23	23	34	35	10	21	5	14	60	31	65	65	67	70	62	39	75	58	65	23	23	13	11	65	27	23	23	12	69	66	60	63	72
37900	2009-08-30	67	75	right	medium	medium	23	23	34	35	10	21	5	14	61	31	65	65	67	70	62	39	75	58	65	23	23	13	11	65	27	23	23	12	69	66	61	63	71
37900	2009-02-22	61	65	right	medium	medium	23	23	34	35	10	21	5	14	54	31	53	59	67	62	62	39	75	58	64	23	23	13	11	65	27	23	23	12	64	60	54	60	62
37900	2008-08-30	59	65	right	medium	medium	23	23	34	35	10	21	5	14	51	31	47	56	67	57	62	39	75	58	65	23	23	13	11	65	27	23	23	12	61	57	51	58	59
37900	2007-08-30	57	63	right	medium	medium	23	23	34	35	10	21	5	14	47	31	47	56	67	57	62	39	75	58	58	23	23	13	11	65	27	23	23	12	58	53	47	56	57
37900	2007-02-22	57	63	right	medium	medium	23	23	34	35	10	21	5	14	47	31	47	56	67	57	62	39	75	58	58	23	23	13	11	65	27	23	23	12	58	53	47	56	57
46459	2008-08-30	63	65	right	\N	\N	39	44	39	58	\N	39	\N	52	55	57	77	75	\N	60	\N	39	\N	73	70	57	81	68	63	\N	58	66	57	\N	18	22	55	22	22
46459	2007-02-22	63	65	right	\N	\N	39	44	39	58	\N	39	\N	52	55	57	77	75	\N	60	\N	39	\N	73	70	57	81	68	63	\N	58	66	57	\N	18	22	55	22	22
150510	2012-02-22	65	67	right	medium	medium	48	68	62	55	57	49	50	35	41	54	81	85	80	70	75	70	80	60	67	61	38	37	64	59	64	14	22	22	6	5	8	5	6
150510	2011-08-30	65	67	right	medium	medium	48	68	62	55	57	49	50	35	41	54	81	85	80	70	75	70	80	60	67	61	38	37	64	59	64	14	22	22	6	5	8	5	6
150510	2010-08-30	65	67	right	medium	medium	48	68	62	55	57	49	50	35	41	54	81	85	80	70	75	70	80	60	67	61	38	37	64	59	64	14	22	22	6	5	8	5	6
150510	2010-02-22	65	72	right	medium	medium	48	68	62	55	57	49	50	35	41	54	82	77	80	70	75	70	80	60	67	61	38	51	65	59	63	23	22	22	14	23	41	23	23
150510	2007-02-22	65	72	right	medium	medium	48	68	62	55	57	49	50	35	41	54	82	77	80	70	75	70	80	60	67	61	38	51	65	59	63	23	22	22	14	23	41	23	23
34334	2016-03-10	67	67	right	high	low	37	68	66	56	64	62	54	56	30	62	66	63	64	72	68	67	72	65	74	61	69	38	76	41	68	31	40	44	10	9	8	10	9
34334	2015-12-10	68	68	right	high	low	37	68	66	56	64	62	54	56	30	62	72	69	74	72	68	67	72	65	74	61	69	38	76	41	68	31	40	44	10	9	8	10	9
34334	2015-11-06	68	68	right	high	low	37	68	66	56	64	62	54	56	30	62	72	69	74	72	68	67	72	65	74	61	69	38	76	41	68	31	40	44	10	9	8	10	9
34334	2015-09-25	70	70	right	high	low	37	71	69	56	64	62	54	56	30	62	72	69	77	76	68	69	74	65	76	61	69	38	81	41	68	31	40	44	10	9	8	10	9
34334	2015-09-21	70	70	right	high	low	37	71	69	56	64	62	54	56	30	62	72	69	77	76	68	69	74	71	76	61	69	38	81	41	68	31	40	44	10	9	8	10	9
34334	2015-08-27	70	70	right	high	low	36	76	68	55	63	61	53	55	29	61	72	69	65	67	68	72	74	71	66	60	68	37	80	40	67	30	39	43	9	8	7	9	8
34334	2014-10-17	70	70	right	high	low	36	76	68	55	63	61	53	55	29	61	72	69	65	67	68	72	74	71	66	60	68	37	80	40	67	30	39	43	9	8	7	9	8
34334	2014-10-10	69	69	right	high	low	36	76	68	55	63	61	53	55	29	61	69	66	65	67	68	72	74	71	66	60	68	37	80	40	67	30	39	43	9	8	7	9	8
34334	2014-09-18	69	69	right	high	low	36	76	68	56	63	60	53	56	29	62	69	66	65	66	68	73	74	71	66	60	68	37	80	40	67	30	39	43	9	8	7	9	8
34334	2013-06-07	69	69	right	high	low	36	76	68	56	63	60	53	56	29	62	69	66	65	66	68	73	74	71	66	60	68	37	80	40	67	30	39	43	9	8	7	9	8
34334	2013-04-19	69	69	right	high	low	36	76	68	56	63	60	53	56	29	62	69	66	65	66	68	73	74	71	66	60	68	37	80	40	67	30	39	43	9	8	7	9	8
34334	2013-02-15	69	69	right	high	low	36	76	68	56	63	60	53	56	29	62	69	66	65	66	68	73	74	71	66	60	68	37	80	40	69	30	39	43	9	8	7	9	8
34334	2012-08-31	69	69	right	high	low	42	81	71	56	63	64	52	56	29	62	76	72	65	71	74	70	72	80	79	62	75	37	84	60	69	30	37	36	9	8	7	9	8
34334	2012-02-22	69	70	right	high	medium	45	74	67	55	63	57	52	56	42	61	76	75	65	68	70	68	76	77	70	60	75	37	76	54	64	30	37	33	9	8	7	9	8
34334	2011-08-30	64	66	right	high	medium	48	62	66	54	56	58	52	56	45	61	76	75	71	62	68	67	76	69	70	61	57	23	64	58	64	11	27	23	9	8	7	9	8
34334	2010-08-30	64	66	right	high	medium	48	62	66	54	56	58	52	56	45	61	76	75	71	62	68	67	76	69	70	61	57	23	64	58	64	11	27	23	9	8	7	9	8
34334	2010-02-22	66	69	right	high	medium	53	66	67	55	56	58	52	60	54	60	73	75	71	62	68	68	76	72	78	62	57	58	64	58	61	20	27	23	10	20	54	20	20
34334	2009-08-30	66	69	right	high	medium	53	69	67	55	56	58	52	60	54	60	73	75	71	62	68	68	76	72	78	62	57	58	64	58	61	20	27	23	10	20	54	20	20
34334	2009-02-22	66	74	right	high	medium	53	69	67	55	56	58	52	60	54	56	73	75	71	62	68	68	76	72	68	62	57	58	64	58	61	20	27	23	10	20	54	20	20
34334	2008-08-30	67	72	right	high	medium	63	71	62	65	56	69	52	64	64	65	73	72	71	61	68	68	76	67	68	60	45	61	68	58	61	20	27	23	10	20	64	20	20
34334	2007-08-30	63	64	right	high	medium	53	64	41	51	56	62	52	44	43	60	70	72	71	61	68	62	76	58	55	56	55	57	64	58	44	20	20	23	10	20	43	20	20
34334	2007-02-22	60	64	right	high	medium	53	61	31	49	56	60	52	44	33	57	70	72	71	61	68	56	76	55	55	36	55	57	64	58	44	11	17	23	10	7	33	12	5
40014	2014-02-28	64	64	right	medium	medium	25	25	25	21	25	25	25	25	25	21	35	40	54	60	67	25	64	32	68	25	32	23	25	25	25	25	25	25	63	64	55	66	64
40014	2014-01-24	64	64	right	medium	medium	25	25	25	21	25	25	25	25	25	21	35	58	54	60	67	25	64	32	68	25	32	23	25	25	25	25	25	25	63	64	55	66	64
40014	2013-09-20	64	64	right	medium	medium	25	25	25	21	25	25	25	25	25	21	35	58	54	60	67	25	64	32	68	25	32	23	25	25	25	25	25	25	63	64	55	66	64
40014	2013-07-12	64	64	right	medium	medium	7	10	10	21	10	9	11	13	10	21	35	58	54	60	67	10	64	32	68	18	48	23	12	32	12	11	11	13	63	64	55	66	64
40014	2013-05-10	64	64	right	medium	medium	7	10	10	21	10	9	11	13	10	21	35	58	54	60	67	10	64	32	68	18	48	23	12	32	12	11	11	13	63	64	55	66	64
40014	2013-04-05	64	64	right	medium	medium	7	10	10	21	10	9	11	13	10	21	35	58	54	61	67	10	64	32	68	18	48	23	12	32	12	11	11	13	63	67	55	66	64
40014	2013-02-15	64	64	right	medium	medium	7	10	10	21	10	9	11	13	10	21	35	58	54	61	67	10	64	32	68	18	48	23	12	32	12	11	11	13	63	67	55	66	64
40014	2011-08-30	64	64	right	medium	medium	7	10	10	21	10	9	11	13	10	21	35	58	54	61	67	10	64	32	68	18	48	23	12	32	12	11	11	13	63	67	55	66	64
40014	2011-02-22	67	74	right	medium	medium	21	10	10	21	10	21	27	13	10	21	35	58	54	61	50	10	64	52	68	18	48	23	12	32	12	11	11	13	66	70	57	70	66
40014	2010-08-30	67	74	right	medium	medium	21	10	10	21	10	21	27	9	10	21	35	58	54	61	50	10	64	66	68	18	48	23	12	51	8	11	11	32	66	70	57	70	66
40014	2009-08-30	67	74	right	medium	medium	35	22	22	21	10	35	27	9	57	21	35	58	54	61	50	22	64	66	68	22	48	66	20	51	57	22	22	32	66	70	57	70	66
40014	2008-08-30	70	74	right	medium	medium	35	22	22	21	10	35	27	9	57	21	51	58	54	61	50	22	64	66	68	22	48	66	20	51	57	22	22	32	66	78	57	77	67
40014	2007-08-30	72	74	right	medium	medium	35	22	22	21	10	35	27	9	57	21	51	58	54	61	50	22	64	66	68	22	48	66	20	51	57	22	22	32	66	78	57	77	67
40014	2007-02-22	73	74	right	medium	medium	35	11	11	21	10	35	27	57	57	21	51	58	54	61	50	11	64	59	68	19	48	66	20	51	57	12	12	32	66	78	57	79	67
38795	2015-09-21	75	75	left	high	medium	77	50	63	69	59	74	73	69	68	70	78	77	76	75	69	73	79	84	71	64	77	68	67	58	58	74	76	78	10	9	8	15	13
38795	2014-10-02	72	72	left	high	medium	76	49	62	68	58	73	72	68	67	69	78	79	77	74	69	72	79	84	71	63	76	67	66	57	57	70	73	74	9	8	7	14	12
38795	2014-09-18	72	75	left	high	medium	76	49	62	68	58	73	72	68	67	69	78	79	77	74	69	72	79	84	71	63	76	67	66	57	57	70	73	74	9	8	7	14	12
38795	2014-01-31	72	76	left	high	medium	76	49	62	68	58	73	72	68	67	70	78	79	77	74	69	72	79	84	71	63	76	67	66	57	57	70	73	74	9	8	7	14	12
38795	2014-01-03	72	76	left	high	medium	76	49	62	68	58	73	72	68	67	70	78	79	77	74	69	72	79	84	71	63	76	67	66	57	57	70	73	74	9	8	7	14	12
38795	2013-10-25	73	76	left	high	medium	76	49	62	68	58	74	74	70	67	70	78	79	77	75	69	72	79	84	71	63	79	67	66	57	57	70	74	76	9	8	7	14	12
38795	2013-09-27	73	76	left	high	medium	76	49	62	68	58	74	74	70	67	70	78	82	77	75	69	72	79	84	71	63	79	67	66	57	57	70	74	76	9	8	7	14	12
38795	2013-09-20	73	76	left	high	medium	77	49	62	67	62	74	74	70	68	70	78	82	77	75	69	72	79	84	71	63	79	67	64	57	57	68	71	76	9	8	7	14	12
38795	2013-05-10	73	76	left	high	medium	77	49	62	67	62	74	74	70	68	70	80	82	84	75	69	72	79	84	71	63	79	67	64	57	57	68	71	76	9	8	7	14	12
38795	2013-05-03	72	76	left	high	medium	77	49	62	67	62	73	74	70	68	69	80	82	84	74	69	72	79	84	71	63	76	65	59	57	57	68	71	76	9	8	7	14	12
38795	2013-04-19	72	76	left	high	medium	76	49	62	67	62	72	74	70	72	69	80	82	84	74	67	72	79	84	71	65	73	65	59	57	57	68	71	74	9	8	7	14	12
38795	2013-03-01	72	74	left	high	medium	76	49	62	67	62	72	74	70	72	69	80	82	84	74	67	72	79	84	71	65	73	65	59	57	57	68	71	74	9	8	7	14	12
38795	2013-02-15	72	74	left	high	medium	76	49	62	67	62	72	74	70	72	69	80	82	84	74	67	72	79	84	71	65	73	65	62	57	57	68	71	74	9	8	7	14	12
38795	2012-08-31	72	74	left	high	medium	76	49	62	67	62	72	74	70	72	69	80	82	84	74	66	72	76	83	71	65	73	65	62	57	57	68	71	74	9	8	7	14	12
38795	2012-02-22	69	74	left	high	medium	76	49	59	67	62	72	74	70	72	69	80	82	82	74	66	72	76	83	71	65	72	59	60	57	57	62	69	71	9	8	7	14	12
38795	2011-08-30	68	74	left	high	medium	76	47	59	67	49	72	65	57	72	67	81	82	84	74	66	72	76	83	71	57	72	56	59	57	47	56	69	71	9	8	7	14	12
38795	2011-02-22	71	74	left	high	medium	76	47	57	67	39	72	65	47	72	67	77	80	75	74	65	71	70	78	71	53	75	64	65	64	42	67	72	71	9	8	7	14	12
38795	2010-08-30	72	79	left	high	medium	78	47	57	67	39	73	65	47	72	67	77	80	75	74	65	71	70	78	71	53	75	64	65	64	42	73	75	77	9	8	7	14	12
38795	2010-02-22	73	79	left	high	medium	78	47	57	67	39	73	65	47	72	67	77	80	75	74	65	71	70	78	71	53	75	73	67	64	66	73	75	77	13	21	72	21	21
38795	2009-08-30	73	79	left	high	medium	78	47	57	67	39	73	65	47	72	67	77	80	75	74	65	71	70	78	71	53	75	73	67	64	66	73	75	77	13	21	72	21	21
38795	2008-08-30	70	79	left	high	medium	73	47	57	65	39	71	65	47	70	65	75	75	75	70	65	71	70	75	73	53	67	69	66	64	65	67	74	77	13	21	70	21	21
38795	2007-08-30	70	79	left	high	medium	73	47	57	65	39	62	65	47	70	65	75	75	75	77	65	71	70	72	73	53	67	69	66	64	65	67	74	77	13	21	70	21	21
38795	2007-02-22	65	78	left	high	medium	74	47	47	64	39	55	65	65	69	59	75	75	75	77	65	66	70	72	73	34	62	69	66	64	65	65	54	77	13	14	69	11	14
38365	2016-05-12	70	70	right	medium	medium	66	61	65	72	57	68	68	71	69	71	73	66	78	72	77	76	77	78	70	66	64	73	63	66	84	63	69	65	9	9	6	10	11
38365	2016-03-10	70	70	right	medium	medium	66	61	65	72	57	68	68	71	69	71	73	66	78	72	77	76	77	78	70	66	64	73	63	66	84	63	69	65	9	9	6	10	11
38365	2016-02-11	69	69	right	medium	medium	64	59	62	72	57	68	68	71	68	69	73	66	78	72	77	76	77	71	70	64	64	73	63	64	84	63	69	65	9	9	6	10	11
38365	2015-09-21	68	68	right	medium	medium	64	59	62	72	57	68	64	67	68	69	73	66	78	69	77	76	77	71	68	64	64	72	63	64	84	59	67	62	9	9	6	10	11
38365	2015-05-15	67	67	right	medium	medium	63	58	61	71	56	67	63	66	67	68	73	69	78	68	77	75	74	71	68	63	63	71	62	63	83	58	66	61	8	8	5	9	10
38365	2015-04-10	67	68	right	medium	medium	63	58	61	71	56	67	63	66	67	68	73	69	78	68	77	75	74	71	68	63	63	71	62	63	83	58	66	61	8	8	5	9	10
38365	2015-02-20	67	68	right	medium	medium	63	58	61	71	56	67	63	66	67	68	73	69	78	68	77	75	74	71	68	63	63	71	62	63	83	58	66	61	8	8	5	9	10
38365	2015-01-09	67	68	right	medium	medium	63	58	61	71	56	67	63	66	67	68	73	69	78	68	77	75	74	71	68	63	63	71	62	63	83	58	66	61	8	8	5	9	10
38365	2014-11-28	67	68	right	medium	medium	63	58	61	71	56	67	63	66	67	68	73	69	78	68	77	75	74	71	68	63	63	71	62	63	73	58	66	61	8	8	5	9	10
38365	2014-11-14	64	65	right	medium	medium	61	56	60	66	53	67	63	66	64	66	73	69	78	64	77	75	74	69	66	63	63	66	60	58	68	57	61	56	8	8	5	9	10
38365	2014-09-18	64	65	right	medium	medium	61	56	60	66	53	67	63	66	64	66	73	69	78	64	77	75	74	69	66	63	63	66	60	58	68	57	61	56	8	8	5	9	10
38365	2014-04-04	64	65	right	medium	medium	61	61	60	66	53	67	63	66	64	66	73	71	78	64	77	64	72	69	66	63	63	66	60	58	68	57	61	56	8	8	5	9	10
38365	2014-03-07	63	65	right	medium	medium	61	61	60	65	53	67	51	56	64	66	73	71	78	64	77	64	72	69	62	58	63	63	60	56	68	56	61	54	8	8	5	9	10
38365	2014-02-28	63	65	right	medium	medium	54	61	60	61	53	67	51	48	56	66	73	71	78	64	77	64	72	65	61	56	57	53	60	56	64	42	46	45	8	8	5	9	10
38365	2014-01-31	63	65	right	medium	medium	54	61	60	61	53	67	51	48	56	66	73	71	78	64	77	64	72	65	61	56	57	53	60	56	64	42	46	45	8	8	5	9	10
38365	2013-12-27	63	65	right	medium	medium	54	61	60	61	53	67	51	48	56	66	73	71	78	64	77	64	72	65	61	56	57	53	60	56	64	42	46	45	8	8	5	9	10
38365	2013-12-20	63	65	right	medium	medium	54	61	54	61	53	67	51	48	56	66	73	71	78	64	77	64	72	65	61	56	57	53	60	56	64	42	46	45	8	8	5	9	10
38365	2013-11-29	61	63	right	medium	medium	53	61	54	52	53	67	42	43	48	66	73	71	78	69	74	64	71	64	57	56	33	25	58	54	64	34	25	35	8	8	5	9	10
38365	2013-11-15	61	63	right	medium	medium	53	61	54	52	53	67	42	43	48	65	73	71	78	69	74	64	71	64	57	56	33	25	58	54	64	34	25	35	8	8	5	9	10
38365	2013-11-08	61	63	right	medium	medium	53	61	54	52	53	67	42	43	48	65	73	71	78	69	74	64	71	64	57	56	33	25	58	54	59	34	25	35	8	8	5	9	10
38365	2013-09-20	61	63	right	medium	medium	53	61	54	52	53	67	42	43	48	65	73	71	78	69	64	64	71	64	57	56	33	25	58	54	59	34	25	35	8	8	5	9	10
38365	2009-08-30	61	63	right	medium	medium	53	61	54	52	53	67	42	43	48	65	73	71	78	69	64	64	71	64	57	56	33	25	58	54	59	34	25	35	8	8	5	9	10
38365	2007-02-22	61	63	right	medium	medium	53	61	54	52	53	67	42	43	48	65	73	71	78	69	64	64	71	64	57	56	33	25	58	54	59	34	25	35	8	8	5	9	10
37947	2008-08-30	55	60	right	\N	\N	48	46	53	53	\N	62	\N	54	49	64	59	63	\N	52	\N	35	\N	57	54	22	49	38	43	\N	46	60	54	\N	6	21	49	21	21
37947	2007-02-22	55	60	right	\N	\N	48	46	53	53	\N	62	\N	54	49	64	59	63	\N	52	\N	35	\N	57	54	22	49	38	43	\N	46	60	54	\N	6	21	49	21	21
37957	2011-02-22	65	71	right	\N	\N	54	53	66	68	53	58	61	63	66	68	53	56	56	56	73	66	54	66	76	62	61	71	60	76	59	41	57	53	11	15	11	6	8
37957	2010-08-30	68	71	right	\N	\N	60	55	67	73	63	66	59	57	66	68	62	67	63	64	66	68	65	70	68	64	64	68	63	76	55	54	61	55	11	15	11	6	8
37957	2009-08-30	68	71	right	\N	\N	60	55	67	73	63	66	59	57	66	68	62	67	63	64	66	68	65	70	68	64	64	74	68	76	69	54	61	55	10	23	66	23	23
37957	2008-08-30	68	69	right	\N	\N	60	55	67	73	63	66	59	57	66	68	62	67	63	64	66	68	65	70	68	64	64	74	68	76	69	54	61	55	10	23	66	23	23
37957	2007-08-30	67	69	right	\N	\N	60	55	67	68	63	63	59	57	63	68	62	67	63	64	66	68	65	70	68	64	64	71	65	76	67	54	61	55	10	23	63	23	23
37957	2007-02-22	69	70	right	\N	\N	60	55	67	71	63	68	59	67	64	68	70	67	63	64	66	68	65	75	65	67	72	71	65	76	67	54	71	55	10	15	64	13	13
33622	2015-03-13	65	65	right	high	medium	48	63	58	55	66	67	54	57	43	68	80	81	79	60	59	69	75	62	72	61	57	23	62	51	64	21	24	27	5	14	11	8	10
33622	2014-09-18	66	66	right	high	medium	48	63	58	55	66	70	54	57	43	71	82	83	79	60	59	72	75	64	74	62	57	23	63	51	64	21	24	27	5	14	11	8	10
33622	2013-05-31	66	66	right	high	medium	48	63	58	55	66	70	54	57	43	71	82	83	79	60	59	72	75	64	74	62	57	23	63	51	64	21	24	27	5	14	11	8	10
33622	2013-04-19	68	68	right	high	medium	55	65	58	65	66	73	54	57	57	71	83	85	79	62	59	72	75	64	78	62	57	23	63	58	64	21	24	27	5	14	11	8	10
33622	2013-04-12	67	67	right	high	medium	55	65	58	65	66	73	54	57	57	71	83	80	79	62	59	72	75	64	78	62	57	23	63	58	64	21	24	27	5	14	11	8	10
33622	2013-03-15	68	68	right	high	medium	55	66	58	65	66	74	54	57	57	71	90	83	79	62	59	72	78	64	81	67	57	23	63	58	64	21	24	27	5	14	11	8	10
33622	2013-02-15	69	69	right	high	medium	55	66	58	65	66	74	54	57	57	71	90	83	79	65	59	72	78	64	81	67	57	23	66	58	64	21	24	27	5	14	11	8	10
33622	2012-08-31	68	71	right	high	medium	55	66	58	65	66	73	54	57	57	71	88	83	74	65	59	72	78	55	81	67	57	23	58	58	64	21	24	27	5	14	11	8	10
33622	2012-02-22	67	70	right	high	medium	55	62	58	65	66	73	54	57	57	71	83	79	74	65	59	72	78	55	81	67	57	23	58	58	64	21	24	27	5	14	11	8	10
33622	2011-08-30	66	70	right	high	medium	52	64	67	62	66	72	52	53	48	71	83	78	77	65	59	72	80	65	82	67	57	23	58	58	64	21	24	27	5	14	11	8	10
33622	2011-02-22	68	74	right	high	medium	52	62	65	62	66	72	52	53	48	71	75	74	70	65	74	70	72	60	75	64	57	23	58	57	63	11	24	27	5	14	11	8	10
33622	2010-08-30	69	74	right	high	medium	52	66	65	56	66	74	52	43	48	72	78	76	71	65	74	72	72	64	73	62	57	23	62	58	64	21	24	27	5	14	11	8	10
33622	2010-02-22	70	74	right	high	medium	52	66	66	56	66	71	52	43	48	69	81	78	71	72	74	72	72	64	73	62	57	56	63	58	69	21	24	27	12	23	48	23	23
33622	2009-08-30	69	74	right	high	medium	32	70	64	54	66	68	52	43	46	69	77	75	71	75	74	72	72	67	75	58	67	54	69	58	69	21	24	27	12	23	46	23	23
33622	2009-02-22	65	68	right	high	medium	22	75	58	54	66	62	52	43	46	70	66	64	71	60	74	62	72	69	68	48	44	50	76	58	59	21	24	27	12	23	46	23	23
33622	2008-08-30	63	65	right	high	medium	22	68	58	54	66	62	52	43	46	70	66	64	71	60	74	62	72	69	63	48	44	30	76	58	59	21	24	27	12	23	46	23	23
33622	2008-02-22	67	68	right	high	medium	22	68	58	64	66	62	52	43	46	72	66	64	71	60	74	62	72	69	63	51	44	30	76	58	59	21	24	27	12	23	46	23	23
33622	2007-02-22	67	68	right	high	medium	22	68	58	64	66	62	52	43	46	72	66	64	71	60	74	62	72	69	63	51	44	30	76	58	59	21	24	27	12	23	46	23	23
26606	2015-02-27	64	64	left	medium	medium	57	37	65	65	24	50	34	57	60	60	60	57	55	63	57	67	59	70	72	57	72	64	27	57	42	64	65	64	7	13	6	14	9
26606	2014-10-10	65	65	left	medium	medium	59	39	65	66	24	52	34	60	62	62	60	57	57	64	58	70	59	70	72	62	72	65	27	57	42	63	65	64	7	13	6	14	9
26606	2014-09-18	65	65	left	medium	medium	59	39	65	66	24	52	34	60	62	62	60	57	57	65	58	70	59	70	72	62	72	65	27	54	42	63	65	64	7	13	6	14	9
26606	2014-05-09	65	65	left	medium	medium	59	41	65	66	24	47	34	60	62	62	60	62	57	65	58	70	60	70	72	62	69	65	27	54	37	64	66	65	7	13	6	14	9
26606	2013-11-15	64	65	left	medium	medium	59	41	65	64	24	47	34	60	60	62	60	62	57	63	58	70	60	70	72	62	67	65	27	54	37	63	65	64	7	13	6	14	9
26606	2013-09-20	64	65	left	low	medium	59	41	65	64	24	47	34	60	60	62	60	62	57	63	58	70	60	70	72	62	67	65	27	54	37	63	65	64	7	13	6	14	9
26606	2013-05-31	63	64	left	low	medium	57	41	64	63	24	47	34	60	59	62	60	63	57	63	58	70	60	70	72	62	67	64	27	54	37	62	64	64	7	13	6	14	9
26606	2013-05-24	63	64	left	low	medium	57	41	64	63	24	47	34	60	59	62	60	63	57	63	58	70	60	70	72	62	67	64	27	54	37	62	64	64	7	13	6	14	9
26606	2013-05-10	63	64	left	low	medium	57	41	64	63	24	47	34	60	59	62	60	63	57	63	58	70	60	70	72	62	67	64	27	54	37	62	64	64	7	13	6	14	9
26606	2013-03-28	64	65	left	low	medium	57	41	64	63	24	47	34	60	59	62	60	63	57	63	58	70	60	70	72	62	67	64	27	54	37	62	64	64	7	13	6	14	9
26606	2013-03-22	63	65	left	low	medium	52	41	62	57	24	45	34	59	55	57	60	63	57	62	61	70	65	72	75	62	67	64	27	55	37	63	65	64	7	13	6	14	9
26606	2013-03-15	63	65	left	low	medium	52	41	62	57	24	45	34	59	55	57	60	63	57	62	61	70	65	72	75	62	67	64	27	55	37	63	65	64	7	13	6	14	9
26606	2013-02-15	63	65	left	low	medium	52	41	62	57	24	45	34	59	55	57	60	63	57	62	61	70	65	72	75	62	67	64	27	55	37	63	65	64	7	13	6	14	9
26606	2012-08-31	63	65	left	low	medium	52	41	62	57	24	45	34	50	55	57	60	65	57	62	58	31	65	72	75	38	67	64	27	55	37	63	65	64	7	13	6	14	9
26606	2011-08-30	62	66	left	low	medium	41	41	57	52	24	49	34	50	50	59	64	62	61	60	62	31	67	72	74	38	59	60	22	55	37	60	63	62	7	13	6	14	9
26606	2010-02-22	62	66	left	low	medium	41	41	57	52	24	49	34	50	50	59	64	62	61	60	62	31	67	72	74	38	59	60	22	55	37	60	63	62	7	13	6	14	9
26606	2008-08-30	62	66	left	low	medium	41	41	57	52	24	49	34	50	50	59	64	62	61	60	62	31	67	72	74	38	59	60	22	55	37	60	63	62	7	13	6	14	9
26606	2007-08-30	62	66	left	low	medium	41	41	57	52	24	49	34	50	50	59	64	62	61	60	62	31	67	72	74	38	59	60	22	55	37	60	63	62	7	13	6	14	9
26606	2007-02-22	60	64	left	low	medium	41	41	57	52	24	49	34	54	50	56	54	62	61	53	62	31	67	66	74	38	50	60	22	55	54	54	62	62	7	9	6	13	10
38391	2016-02-04	75	75	right	medium	medium	17	14	14	33	17	11	11	17	37	32	60	58	61	76	61	37	82	31	62	15	22	28	18	51	25	11	11	17	77	69	72	74	81
38391	2015-10-16	74	74	right	medium	medium	17	14	14	33	17	11	11	17	37	32	60	58	61	78	61	37	82	31	62	15	22	28	18	51	25	11	11	17	78	69	71	70	77
38391	2015-09-21	75	75	right	medium	medium	17	14	14	33	17	11	11	17	37	32	60	58	61	78	61	37	82	31	62	15	22	28	18	51	25	11	11	17	81	69	71	70	78
38391	2015-07-03	74	74	right	medium	medium	25	25	25	32	25	25	25	25	36	31	60	58	61	78	39	36	83	31	64	25	21	25	25	25	24	25	25	25	81	68	73	67	80
38391	2014-10-02	74	74	right	medium	medium	25	25	25	32	25	25	25	25	36	31	60	58	61	78	39	36	83	31	64	25	21	25	25	25	24	25	25	25	81	68	73	67	80
38391	2014-09-18	74	74	right	medium	medium	25	25	25	32	25	25	25	25	36	31	60	58	61	78	39	36	83	31	63	25	21	25	25	25	24	25	25	25	81	68	73	67	80
38391	2014-04-25	74	74	right	medium	medium	25	25	25	32	25	25	25	25	36	31	60	58	61	80	39	36	83	31	63	25	21	25	25	25	24	25	25	25	81	68	73	67	80
38391	2014-03-28	74	74	right	medium	medium	25	25	25	32	25	25	25	25	36	31	60	58	61	80	39	36	83	31	63	25	21	25	25	25	24	25	25	25	81	68	73	67	80
38391	2013-10-04	75	75	right	medium	medium	25	25	25	32	25	25	25	25	36	31	60	58	61	80	39	36	83	31	63	25	21	25	25	25	24	25	25	25	82	68	73	67	81
38391	2013-09-20	75	75	right	medium	medium	25	25	25	32	25	25	25	25	36	31	53	58	61	80	39	36	83	31	63	25	21	25	25	25	24	25	25	25	82	68	73	67	81
38391	2013-03-22	75	75	right	medium	medium	16	13	13	32	16	10	10	16	36	37	65	65	69	74	39	36	85	50	64	14	24	16	17	26	24	10	10	16	82	68	73	67	81
38391	2013-03-15	75	75	right	medium	medium	16	13	13	32	16	10	10	16	36	37	65	65	69	74	39	36	85	50	64	14	24	16	17	26	24	10	10	16	82	68	73	67	81
38391	2013-02-15	75	75	right	medium	medium	16	13	13	32	16	10	10	16	36	37	65	65	69	74	39	36	85	50	64	14	24	16	17	26	24	10	10	16	82	68	73	67	81
38391	2012-08-31	74	74	right	medium	medium	16	13	13	32	16	10	10	16	36	35	68	62	72	72	39	36	85	55	62	14	24	16	17	26	24	10	10	16	82	68	73	67	81
38391	2012-02-22	73	76	right	medium	medium	16	13	13	32	16	10	10	16	36	35	54	50	60	72	39	36	85	55	62	14	24	16	17	26	24	10	10	16	82	67	65	64	81
38391	2011-08-30	73	73	right	medium	medium	16	13	13	34	16	10	10	16	33	35	64	62	72	72	39	36	85	55	62	14	24	16	17	26	24	10	10	16	82	67	65	64	81
38391	2011-02-22	72	73	right	medium	medium	16	13	23	45	16	21	23	16	41	35	71	67	72	74	57	45	76	55	62	14	24	26	17	36	24	9	21	16	78	66	63	64	81
38391	2010-08-30	72	73	right	medium	medium	16	13	58	45	16	21	23	16	47	35	71	68	72	74	57	56	76	55	62	14	24	26	17	54	24	22	21	27	78	66	64	63	81
38391	2009-08-30	71	74	right	medium	medium	25	22	58	41	16	21	23	36	67	35	71	68	72	74	57	56	76	56	62	24	54	51	33	54	52	22	21	27	76	66	67	58	81
38391	2009-02-22	71	77	right	medium	medium	25	22	28	41	16	21	23	36	69	35	68	63	72	72	57	56	76	56	62	24	54	51	33	54	60	22	21	27	73	66	69	62	81
38391	2008-08-30	71	73	right	medium	medium	25	22	28	51	16	31	23	36	69	45	68	63	72	72	57	56	76	56	62	24	54	51	33	54	60	22	21	27	74	66	69	62	81
38391	2007-08-30	70	73	right	medium	medium	25	22	28	51	16	31	23	36	69	45	68	63	72	72	57	56	76	56	62	24	54	51	33	54	60	22	21	27	74	66	69	62	81
38391	2007-02-22	70	76	right	medium	medium	16	22	28	51	16	31	23	60	69	45	68	63	72	72	57	56	76	56	62	24	54	51	33	54	60	22	21	27	74	66	69	62	81
37868	2016-03-17	78	78	right	medium	medium	11	11	16	39	16	14	16	12	34	24	55	59	28	75	42	45	69	31	72	16	34	21	16	40	41	13	14	16	82	73	65	72	84
37868	2016-03-10	78	78	right	medium	medium	11	11	16	39	16	14	16	12	34	24	55	59	28	75	42	45	69	31	72	16	34	21	16	20	41	13	14	16	82	73	65	72	84
37868	2016-01-21	78	78	right	medium	medium	11	11	16	39	16	14	16	12	34	24	55	59	28	75	42	45	69	31	72	16	34	21	16	20	41	13	14	16	82	75	65	73	84
37868	2015-09-21	78	78	right	medium	medium	11	11	16	39	16	14	16	12	34	24	55	59	28	75	42	45	69	31	72	16	34	21	16	20	41	13	14	16	82	75	65	73	84
37868	2015-04-17	80	80	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	74	42	44	69	31	72	25	33	20	25	25	40	25	25	25	82	75	72	76	84
37868	2015-01-16	79	81	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	74	42	44	69	31	72	25	33	20	25	25	40	25	25	25	82	75	72	76	82
37868	2014-12-19	80	82	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	74	42	44	69	31	72	25	33	20	25	25	40	25	25	25	82	76	72	77	82
37868	2014-10-17	81	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	74	42	44	69	31	72	25	33	20	25	25	40	25	25	25	84	79	72	77	84
37868	2014-10-02	81	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	69	42	44	69	31	72	25	33	20	25	25	40	25	25	25	84	79	72	77	84
37868	2014-09-18	82	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	69	42	44	69	31	72	25	33	20	25	25	40	25	25	25	84	79	72	80	84
37868	2014-04-25	82	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	69	42	44	69	54	72	25	33	20	25	25	40	25	25	25	84	79	72	80	84
37868	2013-12-06	81	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	69	42	44	69	54	72	25	33	20	25	25	40	25	25	25	84	79	72	80	84
37868	2013-09-27	81	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	28	69	42	44	69	54	72	25	47	20	25	25	40	25	25	25	84	79	72	80	84
37868	2013-09-20	81	83	right	medium	medium	25	25	25	38	25	25	25	25	33	23	55	59	55	69	65	44	69	54	72	25	47	20	25	25	40	25	25	25	83	81	72	80	83
37868	2013-04-12	78	83	right	medium	medium	10	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	19	40	12	13	15	81	79	72	74	83
37868	2013-03-22	78	83	right	medium	medium	10	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	35	40	12	13	15	81	79	72	74	83
37868	2013-03-08	76	81	right	medium	medium	10	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	35	40	12	13	15	78	79	71	71	77
37868	2013-02-15	76	81	right	medium	medium	10	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	35	40	12	13	15	78	79	71	71	77
37868	2012-08-31	76	81	right	medium	medium	9	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	35	37	12	13	15	78	79	71	71	77
37868	2012-02-22	74	80	right	medium	medium	9	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	35	37	12	13	15	78	81	80	57	81
37868	2011-08-30	74	80	right	medium	medium	9	10	15	38	15	13	15	11	33	23	60	59	55	69	65	44	69	54	72	15	47	20	15	35	37	12	13	15	78	81	80	57	81
37868	2011-02-22	74	78	right	medium	medium	23	8	15	38	15	24	15	11	41	37	60	59	55	69	68	44	69	54	72	15	47	20	15	35	37	12	13	15	75	75	72	69	79
37868	2010-08-30	70	76	right	medium	medium	23	20	15	50	15	24	39	20	49	37	60	59	55	69	68	55	69	54	72	15	47	20	15	60	37	12	34	39	70	69	68	68	73
37868	2010-02-22	67	70	right	medium	medium	23	23	23	38	15	24	39	20	67	38	52	57	55	55	68	55	69	50	79	23	47	33	18	60	52	23	34	39	68	63	67	66	71
37868	2009-08-30	64	70	right	medium	medium	23	23	23	50	15	24	39	20	65	47	52	57	55	55	68	55	69	50	79	23	47	33	18	60	52	31	34	39	66	63	65	59	67
37868	2007-08-30	64	70	right	medium	medium	23	23	23	50	15	24	39	20	65	47	52	57	55	55	68	55	69	50	79	23	47	33	18	60	52	31	34	39	66	63	65	59	67
37868	2007-02-22	64	70	right	medium	medium	23	20	23	50	15	14	39	37	65	47	52	57	55	55	68	55	69	50	79	11	47	33	18	60	52	31	34	39	66	63	65	59	67
38797	2016-01-28	69	70	right	medium	medium	15	12	43	33	13	17	19	11	38	21	47	42	51	69	43	21	69	26	72	11	16	11	17	37	28	12	14	13	70	67	72	68	72
38797	2015-11-06	70	71	right	medium	medium	15	12	43	33	13	17	19	11	38	21	47	42	51	69	43	21	69	26	72	11	16	11	17	37	28	12	14	13	72	68	72	68	74
38797	2015-10-23	70	72	right	medium	medium	15	12	43	33	13	17	19	11	38	21	47	42	51	69	43	21	69	26	72	11	16	11	17	37	28	12	14	13	72	68	72	68	74
38797	2015-09-21	71	73	right	medium	medium	15	12	43	33	13	17	19	11	38	21	47	42	51	69	43	21	69	26	72	11	16	11	17	37	28	12	14	13	72	69	72	68	76
38797	2015-05-29	70	72	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	68	43	20	66	26	72	25	25	25	25	25	27	25	25	25	70	70	72	66	75
38797	2015-04-24	70	72	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	68	43	20	66	26	72	25	25	25	25	25	27	25	25	25	70	70	73	66	75
38797	2015-03-27	71	73	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	71	72	73	66	75
38797	2015-02-06	72	74	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	71	74	73	66	75
38797	2015-01-30	72	76	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	72	74	78	66	75
38797	2014-12-19	74	78	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	72	74	78	74	74
38797	2014-10-31	75	79	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	74	75	78	76	76
38797	2014-09-18	76	79	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	74	77	78	78	76
38797	2014-01-03	76	79	right	medium	medium	25	25	42	32	25	25	25	25	37	20	47	42	51	73	43	20	66	26	72	25	25	25	25	25	27	25	25	25	74	77	78	78	76
38797	2013-09-20	73	79	right	medium	medium	25	25	42	32	25	25	25	25	37	26	47	42	51	76	43	20	66	26	72	25	25	25	25	25	27	25	25	25	75	77	78	78	76
38797	2013-05-31	73	79	right	medium	medium	14	11	42	32	12	16	18	10	37	26	55	52	57	72	43	20	74	51	72	10	15	15	16	24	27	11	13	12	75	77	78	78	76
38797	2013-02-15	73	79	right	medium	medium	14	11	42	32	12	16	18	10	37	26	55	52	57	72	43	20	74	51	72	10	15	15	16	24	27	11	13	12	75	77	78	78	76
38797	2012-08-31	73	78	right	medium	medium	14	11	42	32	12	16	18	10	37	26	55	52	57	72	43	20	74	51	72	10	15	15	16	24	27	11	13	12	75	77	78	78	76
38797	2012-02-22	73	78	right	medium	medium	14	11	42	32	12	16	18	10	37	26	55	52	57	72	43	20	74	51	72	10	15	15	16	24	27	11	13	12	75	77	78	78	76
38797	2011-08-30	71	76	right	medium	medium	14	11	42	32	12	16	18	10	37	26	55	52	57	72	43	20	74	51	72	10	15	15	16	24	27	11	13	12	72	67	76	68	75
38797	2011-02-22	69	76	right	medium	medium	14	11	12	19	12	20	18	10	17	21	65	62	67	75	67	40	73	61	72	10	61	22	16	49	12	11	13	12	66	67	69	65	75
38797	2010-08-30	69	76	right	medium	medium	9	11	12	19	7	20	18	10	17	21	65	62	67	75	67	40	73	61	72	10	61	22	16	49	7	11	8	12	66	67	69	65	75
38797	2010-02-22	71	76	right	medium	medium	21	21	21	21	7	21	18	10	66	21	65	62	67	75	67	40	73	61	72	21	61	64	52	49	58	21	21	12	72	70	66	70	72
38797	2009-08-30	70	76	right	medium	medium	21	21	21	21	7	21	18	10	69	21	65	62	67	75	67	40	73	61	72	21	61	64	52	49	58	28	21	12	69	70	69	70	72
38797	2009-02-22	63	71	right	medium	medium	21	21	21	21	7	21	18	10	59	21	63	66	67	72	67	31	73	61	63	21	61	64	52	49	58	28	21	12	67	60	59	62	63
38797	2008-08-30	63	71	right	medium	medium	21	21	21	21	7	21	18	10	59	21	63	66	67	72	67	31	73	61	63	21	61	64	52	49	58	28	21	12	67	60	59	62	63
38797	2007-08-30	61	69	right	medium	medium	21	21	21	21	7	21	18	10	58	21	63	66	67	72	67	31	73	53	63	21	61	64	42	49	58	28	21	12	59	60	58	57	63
38797	2007-02-22	59	68	right	medium	medium	19	17	12	9	7	9	18	58	56	15	63	66	67	72	67	31	73	53	63	10	61	64	42	49	58	28	8	12	57	58	56	55	61
10404	2011-02-22	71	77	right	\N	\N	74	72	60	75	64	72	61	65	68	71	67	72	70	74	70	77	75	71	73	66	70	41	73	71	66	35	48	46	13	8	6	15	14
10404	2010-08-30	73	77	right	\N	\N	74	76	60	75	64	73	61	65	68	73	73	76	70	74	70	77	75	84	73	66	70	41	73	71	66	35	48	46	13	8	6	15	14
10404	2009-08-30	73	77	right	\N	\N	74	76	60	75	64	73	61	65	68	73	73	76	70	74	70	77	75	84	73	66	70	76	73	71	66	35	48	46	10	22	68	22	22
10404	2008-08-30	70	73	right	\N	\N	74	67	59	72	64	67	61	64	67	67	74	75	70	72	70	76	75	83	72	65	69	75	72	71	65	34	47	46	10	22	67	22	22
10404	2007-08-30	75	75	right	\N	\N	74	69	64	70	64	78	61	65	72	77	80	75	70	77	70	76	75	78	67	62	58	63	65	71	62	34	45	46	10	22	72	22	22
10404	2007-02-22	75	75	right	\N	\N	74	69	64	70	64	78	61	65	72	77	80	75	70	77	70	76	75	78	67	62	58	63	65	71	62	34	45	46	10	22	72	22	22
38337	2015-05-08	64	64	right	low	medium	53	36	70	60	27	38	33	42	57	58	47	49	46	58	45	56	56	61	74	41	68	65	28	46	68	62	64	61	6	7	6	7	7
38337	2015-01-09	65	65	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	49	46	59	45	56	56	65	74	41	70	65	28	46	68	63	65	62	6	7	6	7	7
38337	2014-09-18	65	65	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	49	46	59	45	56	56	65	74	41	70	65	28	46	68	63	65	62	6	7	6	7	7
38337	2013-09-20	65	65	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	49	46	59	45	56	58	65	74	41	70	65	28	46	68	63	65	62	6	7	6	7	7
38337	2013-06-07	65	65	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	51	46	59	45	56	58	65	74	41	70	65	28	46	68	63	65	62	6	7	6	7	7
38337	2013-05-17	65	66	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	51	46	59	45	56	58	65	74	41	70	65	28	46	68	63	65	62	6	7	6	7	7
38337	2013-05-10	65	66	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	51	46	59	45	56	58	65	74	41	70	65	28	46	68	63	65	62	6	7	6	7	7
38337	2013-03-28	66	66	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	51	46	63	45	56	58	65	74	41	70	65	28	46	68	66	67	64	6	7	6	7	7
38337	2013-03-15	66	66	right	low	medium	53	36	71	60	27	38	33	42	57	58	47	51	46	63	45	56	58	65	74	41	70	65	28	46	68	66	67	64	6	7	6	7	7
38337	2013-03-04	67	67	right	low	medium	53	36	72	60	37	38	53	52	57	60	52	53	49	64	51	60	67	70	74	46	70	65	28	54	68	66	67	65	6	7	6	7	7
38337	2013-02-15	67	67	right	low	medium	53	36	72	60	37	38	53	52	57	60	52	53	49	64	51	60	67	70	74	46	70	65	28	54	68	66	67	65	6	7	6	7	7
38337	2012-08-31	69	69	right	low	medium	53	36	73	62	37	38	53	52	57	61	53	58	50	65	51	60	70	73	75	46	71	66	28	54	68	68	67	69	6	7	6	7	7
38337	2012-02-22	69	70	right	low	medium	53	36	74	62	37	52	53	52	60	62	53	62	55	65	52	60	70	75	72	46	71	67	28	54	68	67	70	68	6	7	6	7	7
38337	2011-08-30	69	70	right	low	medium	53	36	74	62	37	52	53	52	60	64	53	62	56	66	62	63	78	75	72	48	71	68	28	54	68	67	71	69	6	7	6	7	7
38337	2011-02-22	70	71	right	low	medium	53	36	74	66	37	52	53	52	63	65	57	65	59	66	73	63	70	72	74	48	71	74	28	68	68	69	73	68	6	7	6	7	7
38337	2010-08-30	71	73	right	low	medium	56	58	74	66	37	52	53	52	60	67	57	65	59	60	73	63	64	76	74	48	71	77	54	68	70	72	74	72	6	7	6	7	7
38337	2009-08-30	69	71	right	low	medium	56	48	74	65	37	52	53	52	60	62	57	65	59	60	73	63	64	76	74	48	71	67	70	68	73	68	71	72	8	20	60	20	20
38337	2009-02-22	67	69	right	low	medium	46	34	73	65	37	47	53	42	60	57	57	65	59	60	73	60	64	76	72	48	71	57	65	68	72	65	67	72	8	20	60	20	20
38337	2008-08-30	62	68	right	low	medium	46	34	70	57	37	54	53	52	60	59	65	67	59	70	73	60	64	68	66	58	68	52	56	68	72	63	67	72	8	20	60	20	20
38337	2007-08-30	63	68	right	low	medium	46	34	70	57	37	54	53	52	60	59	65	67	59	70	73	60	64	68	66	58	68	52	56	68	72	63	67	72	8	20	60	20	20
38337	2007-02-22	63	68	right	low	medium	46	34	70	57	37	54	53	72	60	59	65	67	59	70	73	60	64	68	66	58	68	52	56	68	72	63	67	72	8	9	60	5	10
26669	2010-02-22	65	70	right	\N	\N	57	60	42	70	\N	65	\N	61	65	70	54	57	\N	62	\N	59	\N	67	52	62	47	72	70	\N	71	37	42	\N	9	20	65	20	20
26669	2009-08-30	65	70	right	\N	\N	57	60	42	70	\N	65	\N	61	65	70	54	57	\N	62	\N	59	\N	67	52	62	47	72	70	\N	71	37	42	\N	9	20	65	20	20
26669	2008-08-30	66	70	right	\N	\N	52	60	46	70	\N	67	\N	61	65	71	55	58	\N	62	\N	62	\N	72	58	62	65	74	67	\N	71	42	46	\N	9	20	65	20	20
26669	2007-08-30	67	70	right	\N	\N	52	60	46	70	\N	67	\N	61	65	71	55	58	\N	62	\N	62	\N	72	58	62	65	74	67	\N	71	42	46	\N	9	20	65	20	20
26669	2007-02-22	66	77	right	\N	\N	52	46	56	71	\N	69	\N	81	66	68	65	61	\N	62	\N	64	\N	77	78	62	65	74	67	\N	81	49	46	\N	9	14	66	6	10
173432	2016-04-28	63	65	right	high	medium	42	61	69	59	52	59	57	45	38	62	52	65	44	58	61	61	66	65	83	53	59	36	66	54	55	22	23	22	12	6	8	9	15
173432	2016-04-21	63	65	right	high	medium	42	61	69	59	52	59	57	45	38	62	52	65	44	58	61	61	66	65	83	53	49	36	66	54	55	22	23	22	12	6	8	9	15
173432	2016-04-14	63	65	right	high	medium	42	61	69	59	52	59	57	45	38	62	52	65	44	58	61	61	66	65	83	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2016-03-10	63	67	right	high	medium	42	61	69	59	52	59	57	45	38	62	52	65	44	58	61	61	66	65	83	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2016-02-11	62	66	right	high	medium	42	61	69	59	52	59	57	45	38	62	62	65	44	58	71	61	66	65	73	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2014-04-11	62	66	right	high	medium	42	61	69	59	52	59	57	45	38	62	62	65	44	58	71	61	66	65	73	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2014-03-14	62	64	right	high	medium	42	63	69	61	52	61	57	45	38	62	62	65	44	58	71	61	66	65	73	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2014-02-07	62	64	right	medium	medium	42	63	69	61	52	61	57	45	38	62	62	65	44	58	71	61	66	65	73	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2009-08-30	62	64	right	medium	medium	42	63	69	61	52	61	57	45	38	62	62	65	44	58	71	61	66	65	73	53	49	36	66	54	55	24	23	22	12	6	8	9	15
173432	2007-02-22	62	64	right	medium	medium	42	63	69	61	52	61	57	45	38	62	62	65	44	58	71	61	66	65	73	53	49	36	66	54	55	24	23	22	12	6	8	9	15
26741	2016-04-28	66	66	left	high	medium	68	59	37	67	64	59	70	69	66	66	71	65	58	62	58	80	59	80	71	70	66	58	63	70	65	59	64	61	8	15	6	8	13
26741	2015-10-02	66	66	left	high	medium	68	59	37	67	64	59	70	69	66	66	71	65	58	62	58	80	59	80	71	70	66	58	63	70	65	59	57	54	8	15	6	8	13
26741	2015-09-21	64	64	left	high	medium	68	59	37	67	64	59	70	69	66	66	71	65	58	62	58	80	59	80	71	70	66	58	63	70	65	59	57	54	8	15	6	8	13
26741	2015-05-15	62	62	left	high	medium	67	58	36	64	63	58	62	66	65	65	77	64	58	61	58	79	59	78	71	69	65	49	62	69	64	58	54	53	7	14	5	7	12
26741	2015-01-23	60	60	left	high	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	79	59	74	71	69	65	49	62	69	64	45	48	46	7	14	5	7	12
26741	2014-12-05	60	60	left	high	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	79	59	74	71	69	65	49	62	69	64	45	48	46	7	14	5	7	12
26741	2014-11-14	60	60	left	high	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	79	59	74	71	69	65	49	62	69	64	45	48	46	7	14	5	7	12
26741	2014-09-18	60	60	left	high	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	79	59	74	71	69	65	49	62	69	64	45	48	46	7	14	5	7	12
26741	2014-09-12	60	60	left	high	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	79	59	74	71	69	65	49	62	69	64	45	48	46	7	14	5	7	12
26741	2014-08-15	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	76	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2014-07-25	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	76	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2014-07-18	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	76	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2013-09-20	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2013-08-16	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	58	61	58	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2013-03-22	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	55	61	58	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2013-03-08	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	55	61	58	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2013-02-15	62	62	left	medium	medium	67	52	36	64	63	55	56	66	65	65	77	64	55	61	58	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2012-08-31	64	64	left	medium	medium	67	52	36	64	63	55	56	66	65	65	78	64	55	61	55	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2009-08-30	64	64	left	medium	medium	67	52	36	64	63	55	56	66	65	65	78	64	55	61	55	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
26741	2007-02-22	64	64	left	medium	medium	67	52	36	64	63	55	56	66	65	65	78	64	55	61	55	70	59	74	71	65	65	46	62	69	64	35	43	36	7	14	5	7	12
32690	2014-03-14	65	65	left	medium	medium	65	72	57	60	62	64	60	56	52	66	71	72	72	59	62	67	72	81	71	59	45	37	62	59	64	22	27	35	8	5	11	11	15
32690	2014-02-14	65	65	left	medium	medium	65	72	57	60	62	64	60	56	52	66	71	72	72	59	62	67	72	81	71	59	45	37	62	59	64	22	27	35	8	5	11	11	15
32690	2014-02-07	64	64	left	medium	medium	65	70	57	60	62	61	60	56	52	62	71	72	72	59	62	67	72	81	71	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2014-01-31	64	64	left	medium	medium	65	70	57	60	62	61	60	56	52	62	71	72	72	59	62	67	72	78	71	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2013-12-13	63	63	left	medium	medium	65	64	57	60	62	61	60	56	52	62	71	72	72	59	62	67	72	78	71	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2013-11-29	63	63	left	medium	medium	65	64	57	60	62	61	60	56	52	62	71	72	72	59	62	67	72	59	71	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2013-09-20	63	63	left	medium	medium	65	64	57	60	62	61	60	56	52	62	71	72	72	59	62	67	72	59	67	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2013-04-05	62	62	left	medium	medium	65	63	50	60	62	59	60	59	52	62	69	72	72	59	62	67	72	59	67	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2013-02-15	62	62	left	medium	medium	65	63	50	60	62	59	60	59	52	62	69	72	72	59	62	67	72	59	67	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2012-02-22	62	62	left	medium	medium	65	63	50	60	62	59	60	59	52	62	69	72	72	59	62	67	72	59	67	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2011-02-22	62	62	left	medium	medium	65	63	50	60	62	59	60	59	52	62	69	72	72	59	62	67	72	59	67	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2010-08-30	62	62	left	medium	medium	65	63	50	60	62	59	60	59	52	62	69	72	72	59	62	67	72	59	67	59	45	37	63	59	64	22	27	35	8	5	11	11	15
32690	2010-02-22	62	62	left	medium	medium	65	63	50	60	62	59	60	59	52	62	69	72	72	59	62	67	72	59	67	59	45	62	63	59	65	22	27	35	9	22	52	22	22
32690	2009-08-30	69	62	left	medium	medium	69	68	50	60	62	72	60	59	52	69	75	77	72	74	62	67	72	70	67	59	55	64	70	59	66	22	38	35	9	22	52	22	22
32690	2009-02-22	68	62	left	medium	medium	73	72	52	52	62	74	60	50	42	69	76	78	72	70	62	55	72	70	67	69	66	65	70	59	66	42	52	35	9	22	42	22	22
32690	2008-08-30	68	62	left	medium	medium	73	72	52	52	62	74	60	50	42	69	76	78	72	70	62	55	72	70	67	69	66	65	70	59	66	42	52	35	9	22	42	22	22
32690	2007-08-30	68	62	left	medium	medium	73	72	52	52	62	74	60	50	42	69	82	78	72	83	62	55	72	70	74	69	66	65	70	59	66	42	52	35	9	22	42	22	22
32690	2007-02-22	71	62	left	medium	medium	73	72	52	52	62	83	60	66	42	79	82	78	72	83	62	55	72	70	74	69	66	65	70	59	66	42	52	35	9	13	42	6	13
69805	2009-08-30	64	70	left	\N	\N	31	23	65	54	\N	34	\N	41	52	48	58	63	\N	52	\N	59	\N	68	77	33	71	48	53	\N	52	64	65	\N	9	20	52	20	20
69805	2009-02-22	59	73	left	\N	\N	24	23	64	40	\N	33	\N	38	55	43	38	54	\N	54	\N	44	\N	68	70	28	71	49	54	\N	62	58	60	\N	10	20	55	20	20
69805	2008-08-30	72	76	left	\N	\N	23	22	52	34	\N	37	\N	37	49	52	51	67	\N	77	\N	47	\N	81	88	27	85	62	77	\N	75	71	80	\N	10	20	49	20	20
69805	2007-08-30	72	76	left	\N	\N	23	22	52	34	\N	37	\N	37	49	52	51	67	\N	77	\N	47	\N	86	89	27	87	62	77	\N	75	72	82	\N	10	20	49	20	20
69805	2007-02-22	72	76	left	\N	\N	23	22	52	34	\N	37	\N	37	49	52	51	67	\N	77	\N	47	\N	86	89	27	87	62	77	\N	75	72	82	\N	10	20	49	20	20
37100	2014-11-28	70	70	right	low	high	51	23	66	61	31	46	23	28	56	58	71	73	73	66	78	50	78	78	66	36	74	67	26	41	34	73	72	73	11	10	11	14	5
37100	2014-09-18	70	70	right	low	high	51	23	66	61	31	46	23	28	56	58	71	73	73	66	78	50	78	78	66	36	74	67	26	41	34	73	72	73	11	10	11	14	5
37100	2013-12-27	69	69	right	low	high	51	23	66	61	31	46	23	28	56	58	71	69	73	66	78	50	76	78	66	36	74	67	26	41	34	73	72	73	11	10	11	14	5
37100	2013-10-18	69	69	right	low	high	51	23	66	61	31	46	23	28	56	58	71	69	73	66	78	50	83	78	66	36	74	67	26	41	34	73	72	71	11	10	11	14	5
37100	2013-03-28	69	70	right	low	high	51	23	66	61	31	46	23	28	56	58	71	69	73	66	78	50	83	81	66	36	74	67	26	41	34	73	72	71	11	10	11	14	5
37100	2013-03-15	69	70	right	low	high	51	23	66	61	31	46	23	28	56	58	71	69	73	66	78	50	83	81	66	36	74	67	26	41	34	73	72	71	11	10	11	14	5
37100	2013-02-15	68	70	right	low	high	53	23	66	63	36	41	23	34	58	56	69	68	71	65	78	60	86	71	65	46	70	66	26	58	44	71	69	70	11	10	11	14	5
37100	2012-08-31	68	70	right	low	high	53	23	66	63	36	41	23	34	58	56	71	70	71	65	77	60	85	71	65	46	70	66	26	58	44	71	69	70	11	10	11	14	5
37100	2012-02-22	67	68	right	low	high	53	23	66	63	36	41	23	34	58	56	71	70	71	65	77	60	85	71	61	46	66	66	26	58	44	71	69	70	11	10	11	14	5
37100	2011-08-30	64	68	right	low	high	53	23	66	63	36	41	23	34	58	56	70	69	71	65	77	60	83	71	61	46	66	66	26	58	44	71	69	70	11	10	11	14	5
37100	2010-08-30	67	68	right	low	high	53	33	63	62	38	41	43	41	58	56	68	69	67	63	66	60	69	68	58	51	71	66	36	58	48	70	69	71	11	10	11	14	5
37100	2010-02-22	64	68	right	low	high	53	33	58	62	38	48	43	41	58	58	66	68	67	63	66	60	69	66	54	51	68	63	62	58	60	66	65	71	8	21	58	21	21
37100	2009-08-30	63	68	right	low	high	53	33	58	61	38	46	43	41	58	58	64	68	67	57	66	60	69	66	54	51	67	61	60	58	57	65	64	71	8	21	58	21	21
37100	2008-08-30	61	66	left	low	high	53	21	55	55	38	46	43	54	56	51	64	68	67	57	66	41	69	66	54	43	67	58	56	58	55	65	63	71	8	21	56	21	21
37100	2007-08-30	61	66	left	low	high	53	21	55	55	38	46	43	54	56	51	64	68	67	57	66	41	69	66	54	43	67	58	56	58	55	65	63	71	8	21	56	21	21
37100	2007-02-22	61	66	left	low	high	53	20	55	55	38	46	43	55	56	51	64	68	67	57	66	41	69	66	54	43	67	58	56	58	55	65	63	71	8	5	56	9	15
68064	2008-08-30	50	54	right	\N	\N	57	58	61	42	\N	46	\N	43	57	51	56	43	\N	45	\N	55	\N	56	57	50	55	53	45	\N	48	51	43	\N	6	22	57	22	22
68064	2007-02-22	50	54	right	\N	\N	57	58	61	42	\N	46	\N	43	57	51	56	43	\N	45	\N	55	\N	56	57	50	55	53	45	\N	48	51	43	\N	6	22	57	22	22
67896	2016-04-28	69	69	left	medium	medium	54	57	75	67	44	47	34	58	63	64	67	58	68	70	67	68	77	73	71	59	73	74	64	67	66	66	70	68	10	7	12	11	15
67896	2016-04-21	69	69	left	medium	medium	54	57	75	67	44	47	34	58	63	64	67	58	68	70	67	68	77	73	71	59	73	74	64	67	66	66	70	68	10	7	12	11	15
67896	2016-04-07	69	69	left	medium	medium	54	57	75	67	44	47	34	58	63	64	67	58	68	70	67	68	77	73	71	59	73	74	64	69	66	66	70	68	10	7	12	11	15
67896	2016-03-24	68	68	left	medium	medium	54	57	75	66	44	47	34	58	63	64	67	58	68	70	67	68	77	73	71	59	73	74	64	69	66	65	69	67	10	7	12	11	15
67896	2016-03-03	68	68	left	medium	medium	54	57	75	66	44	47	34	58	63	64	67	60	68	70	70	68	77	73	71	59	73	74	64	69	66	65	69	67	10	7	12	11	15
67896	2015-09-21	68	68	left	medium	medium	54	57	75	66	44	47	34	58	63	64	67	60	68	70	70	68	77	73	71	59	73	71	64	69	66	65	69	67	10	7	12	11	15
67896	2015-03-13	67	67	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	60	68	69	70	67	75	73	71	58	72	70	63	68	65	64	68	66	9	6	11	10	14
67896	2014-09-18	67	67	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	60	68	69	70	67	75	73	71	58	72	70	63	68	65	64	68	66	9	6	11	10	14
67896	2014-07-25	67	68	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	63	68	69	70	67	73	73	71	58	72	70	63	68	65	64	68	66	9	6	11	10	14
67896	2014-02-14	67	68	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	63	68	69	70	67	73	73	71	58	72	70	63	68	65	64	68	66	9	6	11	10	14
67896	2013-11-01	67	68	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	63	68	69	70	67	73	73	71	58	72	70	62	67	65	64	68	66	9	6	11	10	14
67896	2013-09-20	67	68	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	63	68	69	70	67	73	73	71	58	72	70	62	67	65	64	68	66	9	6	11	10	14
67896	2013-02-15	67	68	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	64	68	69	70	67	72	73	71	58	72	70	62	67	65	64	68	66	9	6	11	10	14
67896	2012-08-31	67	68	left	medium	medium	53	56	74	65	43	46	33	57	62	63	67	66	68	69	68	67	70	73	71	58	72	70	62	67	65	64	68	66	9	6	11	10	14
67896	2011-08-30	66	68	left	medium	medium	53	56	65	64	43	46	33	57	61	60	67	66	68	65	68	66	70	73	68	58	72	69	52	67	64	64	67	65	9	6	11	10	14
67896	2011-02-22	65	67	left	medium	medium	53	56	65	64	43	46	33	57	61	60	65	67	65	65	62	66	65	71	63	58	72	69	52	67	64	64	67	65	9	6	11	10	14
67896	2010-08-30	63	67	left	medium	medium	53	32	63	63	41	46	33	47	60	56	65	67	65	64	62	55	65	69	63	43	61	66	46	67	63	60	66	64	9	6	11	10	14
67896	2010-02-22	63	68	right	medium	medium	53	32	63	63	41	46	33	47	60	56	65	67	65	64	62	55	65	69	63	43	61	68	66	67	64	60	66	64	9	20	60	20	20
67896	2009-08-30	63	68	right	medium	medium	53	32	63	63	41	46	33	47	60	56	65	67	65	64	62	55	65	69	63	43	61	68	66	67	64	60	66	64	9	20	60	20	20
67896	2008-08-30	61	66	right	medium	medium	53	32	60	59	41	41	33	47	57	51	65	67	65	62	62	55	65	65	63	43	56	63	61	67	52	60	63	64	12	20	57	20	20
67896	2007-08-30	61	66	right	medium	medium	52	32	60	54	41	41	33	47	51	51	65	67	65	62	62	45	65	65	63	43	64	43	60	67	52	61	62	64	12	20	51	20	20
67896	2007-02-22	61	66	right	medium	medium	52	32	60	54	41	41	33	47	51	51	65	67	65	62	62	45	65	65	63	43	64	43	60	67	52	61	62	64	12	20	51	20	20
39631	2016-04-21	78	78	right	medium	medium	72	66	62	80	64	74	70	73	78	78	71	66	74	78	78	76	71	81	66	75	81	81	72	80	69	74	74	71	7	6	14	16	10
39631	2016-03-10	78	79	right	medium	medium	72	66	62	80	64	74	70	73	78	78	71	66	74	78	78	76	71	81	66	75	81	81	72	80	69	74	74	71	7	6	14	16	10
39631	2016-01-28	78	78	right	medium	medium	72	66	62	80	64	74	70	73	78	78	71	66	74	78	78	76	71	81	66	75	81	81	72	80	69	74	74	71	7	6	14	16	10
39631	2016-01-07	78	78	right	medium	medium	72	66	62	80	64	74	70	73	78	78	71	66	74	78	78	76	71	81	66	75	81	81	72	80	69	74	74	71	7	6	14	16	10
39631	2015-09-21	77	78	right	medium	medium	72	66	62	80	64	74	70	71	78	78	71	66	74	78	78	74	71	81	66	73	80	81	72	78	69	74	74	71	7	6	14	16	10
39631	2015-05-15	76	77	right	medium	medium	70	64	61	78	63	74	69	68	76	78	67	68	72	77	80	73	73	83	66	71	78	80	71	75	70	68	73	68	6	5	13	15	9
39631	2015-03-27	76	78	right	medium	medium	70	64	61	78	63	74	69	68	76	78	67	68	72	77	80	73	73	83	66	71	78	80	71	75	70	68	73	68	6	5	13	15	9
39631	2014-10-02	76	78	right	medium	medium	70	64	61	78	63	74	69	68	76	78	67	68	72	77	80	73	73	83	66	71	78	80	71	75	70	68	73	68	6	5	13	15	9
39631	2014-09-18	76	78	right	medium	medium	70	64	61	77	63	74	69	68	75	78	67	64	72	77	80	73	73	83	66	71	78	80	71	74	70	68	73	68	6	5	13	15	9
39631	2014-05-02	75	81	right	medium	medium	70	64	61	77	63	74	69	68	75	77	74	72	73	76	80	73	71	82	66	71	75	77	71	73	70	68	73	68	6	5	13	15	9
39631	2014-04-25	76	81	right	medium	medium	72	64	61	79	63	74	69	68	77	79	74	72	73	76	80	73	71	82	66	73	75	77	71	73	70	68	73	67	6	5	13	15	9
39631	2014-04-11	76	81	right	medium	medium	72	64	61	80	63	74	69	68	78	79	74	72	73	76	80	73	71	82	66	73	75	77	71	74	70	68	73	67	6	5	13	15	9
39631	2014-03-28	76	81	right	medium	medium	72	64	61	80	63	74	69	68	78	79	74	72	73	76	80	73	71	82	66	73	75	77	71	74	70	68	73	67	6	5	13	15	9
39631	2013-12-27	76	82	right	medium	medium	72	64	61	80	63	74	69	68	78	79	74	72	73	76	80	73	71	82	66	73	75	77	71	74	70	68	73	67	6	5	13	15	9
39631	2013-09-27	77	82	right	medium	medium	72	64	61	80	63	74	69	68	79	79	74	72	73	76	80	73	71	82	66	74	76	79	72	78	70	70	73	67	6	5	13	15	9
39631	2013-09-20	77	82	right	medium	medium	72	64	61	80	63	74	69	68	79	79	74	72	73	78	80	73	71	81	66	74	76	79	72	78	70	69	73	67	6	5	13	15	9
39631	2013-05-31	77	82	right	medium	medium	73	64	61	77	63	74	69	68	76	78	72	71	78	77	80	73	71	81	66	74	78	79	72	78	70	69	73	67	6	5	13	15	9
39631	2013-03-15	77	82	right	medium	medium	73	64	61	77	63	74	69	68	76	78	72	71	78	77	80	73	71	81	66	74	78	79	72	78	70	69	73	67	6	5	13	15	9
39631	2013-02-15	77	82	right	medium	medium	73	64	61	77	63	74	69	68	75	78	72	71	78	77	80	73	71	81	66	74	78	79	72	78	70	69	73	67	6	5	13	15	9
39631	2012-08-31	77	82	right	medium	high	73	64	61	77	63	74	69	68	75	78	72	71	80	77	80	73	71	81	66	74	78	79	72	78	70	69	73	67	6	5	13	15	9
39631	2012-02-22	78	83	right	medium	high	74	65	63	77	68	74	69	73	75	80	77	74	81	82	79	73	71	81	66	74	78	80	75	80	70	68	73	71	6	5	13	15	9
39631	2011-08-30	79	84	right	medium	high	73	61	62	81	66	73	68	73	76	80	77	70	81	83	83	72	75	80	55	73	78	80	71	82	70	68	72	71	6	5	13	15	9
39631	2011-02-22	77	83	right	medium	high	73	66	63	83	68	74	68	74	77	81	73	68	74	82	67	72	68	83	65	73	78	81	74	86	70	68	69	67	6	5	13	15	9
39631	2010-08-30	78	83	right	medium	high	74	69	63	83	68	76	68	78	79	81	73	68	78	81	67	72	69	86	65	73	79	81	80	82	70	68	69	67	6	5	13	15	9
39631	2009-08-30	78	83	right	medium	high	78	69	62	83	68	75	68	78	79	80	73	68	78	80	67	72	69	86	65	73	79	85	82	82	84	71	70	67	13	22	79	22	22
39631	2009-02-22	76	82	right	medium	high	76	58	62	83	68	76	68	72	79	78	76	74	78	79	67	64	69	83	57	67	76	78	77	82	80	59	65	67	13	22	79	22	22
39631	2008-08-30	74	82	right	medium	high	74	58	59	82	68	77	68	70	79	78	74	75	78	77	67	64	69	79	60	67	76	74	67	82	80	54	53	67	13	22	79	22	22
39631	2007-08-30	74	82	right	medium	high	74	56	57	78	68	77	68	62	76	76	72	74	78	75	67	61	69	79	57	67	74	64	62	82	67	42	53	67	13	22	76	22	22
39631	2007-02-22	71	80	right	medium	high	67	49	54	74	68	77	68	57	70	74	70	73	78	75	67	54	69	74	46	61	68	64	62	82	57	38	43	67	13	6	70	3	7
37065	2016-01-21	68	68	right	medium	medium	65	67	63	70	64	72	65	66	63	72	51	61	63	67	64	66	65	71	68	68	69	49	72	71	69	38	49	41	15	11	9	15	8
37065	2016-01-07	69	69	right	medium	medium	65	67	63	70	64	72	65	66	63	72	51	61	63	67	64	66	65	71	68	68	69	49	72	71	69	38	49	41	15	11	9	15	8
37065	2015-09-21	69	69	right	medium	medium	65	67	63	70	64	72	65	66	63	72	51	61	63	67	64	66	65	71	68	68	69	49	72	71	69	38	49	41	15	11	9	15	8
37065	2015-05-15	68	68	right	medium	medium	64	66	62	69	63	71	64	65	62	71	55	65	63	66	64	65	63	71	68	67	68	48	69	69	68	37	48	40	14	10	8	14	7
37065	2015-05-08	68	68	right	medium	medium	64	66	62	69	63	71	64	65	62	71	55	65	63	66	64	65	63	71	68	67	68	48	69	69	68	37	48	40	14	10	8	14	7
37065	2015-04-24	68	68	right	medium	medium	64	66	62	69	63	71	64	65	62	71	55	65	63	66	64	65	63	71	68	67	68	48	69	69	68	37	48	40	14	10	8	14	7
37065	2015-04-17	68	68	right	medium	medium	64	66	62	69	63	71	64	65	62	71	55	65	63	66	64	65	63	71	68	67	68	48	69	69	68	37	48	40	14	10	8	14	7
37065	2015-04-10	67	67	right	medium	medium	64	66	62	69	63	71	64	65	62	71	55	65	62	65	64	65	63	70	63	67	68	46	67	68	63	37	48	40	14	10	8	14	7
37065	2015-01-16	67	67	right	medium	medium	67	64	63	67	65	70	64	65	62	71	55	64	62	65	60	67	65	71	67	68	68	43	67	66	61	23	35	37	14	10	8	14	7
37065	2014-09-18	67	67	right	medium	medium	67	64	63	67	65	70	64	65	62	71	55	64	62	65	60	67	65	71	67	68	68	43	67	66	61	23	35	37	14	10	8	14	7
37065	2014-02-07	67	67	right	medium	medium	67	64	63	67	65	70	64	65	62	71	57	65	62	65	60	67	65	71	67	68	68	43	67	66	61	23	35	37	14	10	8	14	7
37065	2013-12-27	67	67	right	medium	medium	64	64	63	67	65	67	64	65	62	71	57	65	62	65	60	67	65	71	67	68	68	43	67	66	61	23	35	37	14	10	8	14	7
37065	2013-11-01	66	67	right	medium	medium	64	64	63	67	63	66	64	65	62	71	55	65	62	63	60	66	65	68	65	67	68	41	66	65	60	23	35	37	14	10	8	14	7
37065	2013-09-20	66	67	right	medium	medium	64	64	63	67	63	66	64	65	62	71	55	65	62	63	60	66	65	68	65	67	57	41	66	65	60	23	35	37	14	10	8	14	7
37065	2013-07-05	66	67	right	medium	medium	64	64	63	67	63	66	64	65	62	69	56	65	62	63	60	66	65	68	65	67	57	41	66	65	60	23	35	37	14	10	8	14	7
37065	2013-06-07	66	67	right	medium	medium	64	64	63	67	63	66	64	65	62	69	56	65	62	63	60	66	65	68	65	67	57	41	66	65	60	23	35	37	14	10	8	14	7
37065	2013-05-31	66	68	right	medium	medium	64	64	63	67	63	66	64	65	62	69	56	65	62	63	60	66	65	68	65	67	57	41	66	65	60	23	35	37	14	10	8	14	7
37065	2013-05-10	66	68	right	medium	medium	64	64	63	67	63	66	64	65	62	69	56	65	62	63	60	66	65	68	65	67	57	41	66	65	60	23	35	37	14	10	8	14	7
37065	2013-03-22	67	68	right	medium	medium	64	64	63	66	63	69	66	65	62	71	62	66	65	63	60	66	65	63	65	67	57	41	66	66	60	23	27	37	14	10	8	14	7
37065	2013-02-22	67	68	right	medium	medium	64	64	61	66	63	69	66	65	62	71	64	66	67	63	60	66	65	63	65	67	57	41	66	67	60	23	27	37	14	10	8	14	7
37065	2013-02-15	67	68	right	medium	medium	64	64	61	66	63	69	66	65	62	71	64	66	67	63	60	66	65	63	65	67	57	41	66	67	60	23	27	37	14	10	8	14	7
37065	2012-08-31	68	69	right	medium	medium	69	68	54	68	66	73	66	64	65	74	73	68	76	64	59	66	68	62	58	67	57	41	66	70	60	23	27	37	14	10	8	14	7
37065	2012-02-22	68	71	right	medium	medium	69	66	54	68	66	73	66	64	66	74	73	68	76	64	66	64	68	62	58	69	57	41	66	73	60	23	27	37	14	10	8	14	7
37065	2011-08-30	69	71	right	medium	medium	71	66	57	69	66	74	66	64	66	76	73	68	78	64	66	64	68	62	67	69	58	41	68	74	60	23	27	37	14	10	8	14	7
37065	2011-02-22	68	73	right	medium	medium	71	66	57	69	66	74	66	64	66	76	71	68	72	64	62	64	64	62	56	69	58	41	68	74	60	23	27	37	14	10	8	14	7
37065	2010-08-30	68	73	right	medium	medium	71	66	57	69	66	74	66	64	66	76	71	68	75	64	62	64	64	62	56	69	58	41	66	74	60	23	27	37	14	10	8	14	7
37065	2009-08-30	68	73	right	medium	medium	71	66	57	69	66	74	66	64	66	76	71	68	75	64	62	64	64	65	56	69	58	62	64	74	53	23	27	37	9	21	66	21	21
37065	2009-02-22	68	73	right	medium	medium	66	66	57	69	66	74	66	64	64	76	71	68	75	64	62	64	64	65	51	69	48	58	61	74	53	23	27	37	9	21	64	21	21
37065	2008-08-30	68	73	left	medium	medium	66	66	57	69	66	74	66	64	64	76	68	68	75	64	62	64	64	65	53	69	48	61	63	74	53	23	27	37	9	21	64	21	21
37065	2007-08-30	64	68	left	medium	medium	62	61	57	62	66	71	66	60	57	73	61	66	75	60	62	57	64	58	48	64	38	52	54	74	48	28	27	37	9	21	57	21	21
37065	2007-02-22	62	66	right	medium	medium	54	59	56	59	66	64	66	48	54	65	61	66	75	59	62	57	64	64	58	53	38	52	54	74	48	28	27	37	9	14	54	5	6
37902	2010-08-30	65	67	left	\N	\N	65	60	54	65	59	63	60	64	62	62	65	65	67	65	62	67	64	75	60	65	74	53	65	70	60	45	46	47	13	13	14	5	8
37902	2009-08-30	66	67	left	\N	\N	67	62	55	65	59	64	60	64	62	63	65	67	67	65	62	70	64	75	58	65	74	66	65	70	67	45	46	47	12	25	62	25	25
37902	2009-02-22	65	68	left	\N	\N	66	57	54	65	59	64	60	61	60	63	66	68	67	63	62	64	64	70	58	59	66	65	63	70	67	46	46	47	1	25	60	25	25
37902	2008-08-30	65	65	left	\N	\N	66	57	54	65	59	64	60	61	60	63	66	68	67	63	62	64	64	70	58	59	66	65	63	70	67	46	46	47	1	25	60	25	25
37902	2007-08-30	66	65	left	\N	\N	66	57	54	65	59	64	60	61	60	63	66	68	67	63	62	64	64	70	58	59	66	65	63	70	67	46	46	47	1	25	60	25	25
37902	2007-02-22	66	65	left	\N	\N	66	57	54	65	59	64	60	67	60	63	66	68	67	63	62	64	64	70	58	59	66	65	63	70	67	46	46	47	1	1	60	1	1
37903	2012-02-22	64	64	right	medium	medium	58	23	58	60	31	37	46	36	56	56	68	67	69	67	83	61	65	66	56	43	67	69	35	56	45	66	65	67	12	13	5	9	9
37903	2011-08-30	64	64	right	medium	medium	58	23	58	60	31	37	46	36	56	56	68	67	69	67	83	61	65	66	53	43	67	69	35	56	45	66	65	67	12	13	5	9	9
37903	2010-08-30	65	66	right	medium	medium	59	33	58	58	36	37	46	36	56	56	73	71	68	69	68	63	67	65	58	43	71	68	38	61	45	69	66	68	12	13	5	9	9
37903	2009-08-30	64	65	right	medium	medium	58	33	56	55	36	37	46	36	50	54	73	71	68	66	68	63	67	65	58	43	71	63	65	61	64	67	66	68	13	25	50	25	25
37903	2009-02-22	61	64	right	medium	medium	56	33	51	49	36	37	46	36	44	47	71	68	68	63	68	56	67	63	58	43	68	63	65	61	64	66	63	68	1	25	44	25	25
37903	2008-08-30	61	61	right	medium	medium	56	33	51	49	36	37	46	36	44	47	71	68	68	63	68	56	67	63	58	43	68	63	65	61	64	66	63	68	1	25	44	25	25
37903	2007-08-30	58	61	right	medium	medium	56	33	51	49	36	37	46	36	44	47	67	66	68	63	68	56	67	61	59	43	68	63	65	61	64	66	63	68	1	25	44	25	25
37903	2007-02-22	57	59	right	medium	medium	46	33	52	49	36	37	46	54	44	47	67	66	68	59	68	57	67	61	54	43	65	63	65	61	54	63	64	68	1	1	44	1	1
37990	2013-05-17	69	70	right	medium	medium	13	14	13	31	19	16	11	12	33	37	39	47	47	74	43	14	71	48	82	18	79	28	13	34	25	10	16	8	70	65	64	70	71
37990	2013-05-03	69	70	right	medium	medium	13	14	13	31	19	16	11	12	33	37	39	47	47	74	43	14	71	48	82	18	79	28	13	34	25	10	16	8	70	65	64	70	71
37990	2013-03-08	70	70	right	medium	medium	13	14	13	31	19	16	11	12	33	37	39	47	47	74	43	14	71	48	82	18	79	28	13	34	25	10	16	8	71	65	64	70	72
37990	2013-02-15	71	71	right	medium	medium	13	14	13	31	19	16	11	12	33	37	39	49	47	74	43	14	71	48	82	18	79	28	13	34	25	10	16	8	72	65	65	75	74
37990	2012-08-31	71	71	right	medium	medium	13	14	13	31	19	16	11	12	33	37	39	49	47	74	43	14	71	48	82	18	89	28	13	34	25	10	16	8	72	65	65	75	74
37990	2012-02-22	71	72	right	medium	medium	13	14	13	31	19	16	11	12	33	33	39	49	61	74	46	14	71	62	71	18	81	28	13	34	25	10	16	8	72	65	65	75	74
37990	2011-08-30	71	72	right	medium	medium	13	14	13	31	19	16	11	12	33	37	39	49	61	74	46	14	71	62	71	18	81	28	13	34	25	10	16	8	72	65	65	75	74
37990	2011-02-22	72	76	right	medium	medium	13	14	13	45	19	16	26	12	39	37	57	62	65	74	81	14	71	62	83	18	81	28	13	34	42	10	16	21	72	65	65	75	74
37990	2010-08-30	73	76	right	medium	medium	13	14	13	54	19	16	26	12	39	37	57	62	65	74	81	14	71	62	83	18	81	28	13	62	42	6	16	21	74	65	65	75	76
37990	2010-02-22	72	74	right	medium	medium	25	25	25	38	19	25	26	12	65	37	57	65	65	74	81	25	71	62	83	25	73	56	53	62	62	25	25	21	75	67	65	71	74
37990	2009-08-30	73	74	right	medium	medium	25	25	25	54	19	25	26	12	67	37	57	65	65	74	81	25	71	62	83	25	73	56	53	62	62	25	25	21	75	69	67	71	76
37990	2009-02-22	73	76	right	medium	medium	25	25	25	54	19	25	26	12	69	25	52	65	65	74	81	25	71	62	83	25	73	56	53	62	62	25	25	21	75	70	69	71	76
37990	2008-08-30	73	73	right	medium	medium	25	25	25	54	19	25	26	12	69	25	52	65	65	74	81	25	71	62	83	25	73	56	53	62	62	25	25	21	75	70	69	71	76
37990	2007-08-30	71	73	right	medium	medium	25	25	25	54	19	25	26	12	65	25	52	65	65	72	81	25	71	62	71	25	60	56	53	62	62	25	25	21	74	67	65	67	75
37990	2007-02-22	70	78	right	medium	medium	13	14	13	54	19	16	26	62	74	19	52	65	65	72	81	14	71	62	71	18	60	56	53	62	62	6	16	21	70	69	74	67	71
15662	2010-08-30	66	69	right	\N	\N	62	61	33	60	56	71	63	66	57	65	76	71	73	64	43	66	62	65	45	63	51	43	69	61	54	32	37	38	7	12	15	12	6
15662	2010-02-22	68	71	right	\N	\N	68	63	33	66	56	71	63	66	61	70	76	71	73	64	43	66	62	65	45	63	51	62	66	61	63	32	37	38	1	21	61	21	21
15662	2009-08-30	69	71	right	\N	\N	68	63	33	66	56	73	63	66	61	70	76	71	73	64	43	66	62	65	45	63	65	64	66	61	64	32	37	38	1	21	61	21	21
15662	2009-02-22	63	68	right	\N	\N	58	53	33	56	56	68	63	61	51	66	76	71	73	64	43	58	62	65	45	63	43	50	51	61	54	32	37	38	1	21	51	21	21
15662	2008-08-30	62	66	right	\N	\N	58	56	37	56	56	66	63	53	45	61	76	74	73	67	43	55	62	65	45	54	43	50	52	61	54	32	37	38	1	21	45	21	21
15662	2007-02-22	62	66	right	\N	\N	58	56	37	56	56	66	63	53	45	61	76	74	73	67	43	55	62	65	45	54	43	50	52	61	54	32	37	38	1	21	45	21	21
148308	2008-08-30	49	67	right	\N	\N	22	22	22	23	\N	22	\N	17	53	22	46	52	\N	42	\N	56	\N	58	61	22	28	34	34	\N	28	22	22	\N	43	49	53	51	52
148308	2007-02-22	49	67	right	\N	\N	22	22	22	23	\N	22	\N	17	53	22	46	52	\N	42	\N	56	\N	58	61	22	28	34	34	\N	28	22	22	\N	43	49	53	51	52
40521	2016-04-28	78	78	right	medium	high	74	57	52	83	67	73	74	73	80	81	64	68	76	80	78	69	62	77	56	71	73	81	66	80	78	63	73	68	10	14	15	14	7
40521	2016-03-24	78	78	right	medium	high	74	57	52	83	67	73	74	73	80	81	64	68	76	80	78	69	62	77	56	71	73	81	66	80	78	63	73	68	10	14	15	14	7
40521	2016-03-03	78	78	right	medium	high	74	57	52	83	67	73	74	73	80	81	64	68	76	80	82	69	62	77	56	71	73	81	66	80	78	63	73	68	10	14	15	14	7
40521	2016-02-11	78	79	right	medium	high	74	57	52	83	67	73	74	73	80	81	64	68	76	80	82	69	62	77	56	71	73	81	66	80	78	63	73	68	10	14	15	14	7
40521	2015-11-26	78	79	right	medium	high	74	57	52	83	67	73	74	73	80	81	64	68	76	80	82	69	62	77	56	71	73	81	66	80	78	63	73	68	10	14	15	14	7
40521	2015-10-23	78	79	right	medium	high	74	57	52	83	67	73	74	73	80	81	64	68	76	80	82	69	62	77	56	71	73	81	66	80	76	63	73	68	10	14	15	14	7
40521	2015-10-09	77	78	right	medium	high	74	57	52	82	67	71	74	73	80	76	64	66	76	80	82	69	62	77	56	71	73	81	66	79	75	63	71	68	10	14	15	14	7
40521	2015-10-02	77	78	right	medium	high	74	57	52	82	67	71	74	73	80	76	62	61	76	80	82	69	62	77	56	71	73	81	66	79	67	63	67	64	10	14	15	14	7
40521	2015-09-21	75	76	right	medium	high	72	57	52	80	67	71	74	73	75	76	62	61	76	80	82	69	62	77	56	71	72	76	66	78	67	63	67	64	10	14	15	14	7
40521	2015-05-22	71	72	right	medium	high	66	56	51	72	66	68	71	70	71	73	69	68	76	71	82	68	60	77	56	70	71	73	65	76	66	62	66	63	9	13	14	13	6
40521	2015-05-15	71	72	right	medium	high	66	56	51	72	66	68	71	70	71	73	71	68	76	71	82	68	60	77	56	70	71	73	65	72	66	62	66	63	9	13	14	13	6
40521	2015-03-06	71	71	right	medium	high	66	56	51	72	66	68	71	70	71	73	71	68	76	71	82	68	60	77	56	70	71	73	65	72	66	62	66	63	9	13	14	13	6
40521	2015-02-06	71	72	right	medium	high	66	56	51	72	66	68	71	70	71	73	71	68	76	71	82	68	60	77	56	70	71	73	65	72	66	62	66	63	9	13	14	13	6
40521	2015-01-09	71	72	right	medium	high	66	56	51	72	66	68	71	70	71	73	71	68	76	71	82	68	60	77	56	70	71	73	65	72	66	62	66	63	9	13	14	13	6
40521	2014-11-07	71	71	right	medium	high	66	56	51	72	66	68	71	70	71	73	71	68	76	71	82	68	60	77	56	70	71	73	65	72	66	62	66	63	9	13	14	13	6
40521	2014-09-18	71	71	right	medium	high	66	56	51	72	66	68	71	70	71	73	71	68	76	71	82	68	60	77	56	70	71	73	65	72	66	62	66	63	9	13	14	13	6
40521	2014-04-04	69	71	right	medium	high	66	61	51	72	66	68	71	70	71	73	72	68	76	71	82	68	60	77	53	70	71	73	65	72	67	61	64	63	9	13	14	13	6
40521	2014-03-07	68	71	right	medium	high	63	58	51	72	60	68	71	70	71	74	72	68	76	71	82	63	60	77	49	70	69	69	65	70	67	57	60	60	9	13	14	13	6
40521	2014-02-21	68	71	right	medium	high	63	58	51	72	60	68	71	70	71	74	72	68	76	71	82	63	60	77	49	57	69	69	65	70	67	57	60	60	9	13	14	13	6
40521	2014-01-03	69	71	right	medium	medium	63	56	51	72	60	68	71	70	71	74	72	68	76	71	82	63	60	77	49	55	69	69	61	70	67	57	60	60	9	13	14	13	6
40521	2013-09-20	68	72	right	medium	medium	63	56	51	72	60	68	71	70	71	74	72	68	76	66	82	63	60	77	49	55	68	67	60	69	67	57	60	60	9	13	14	13	6
40521	2013-05-24	69	74	right	medium	medium	63	57	51	74	60	68	71	70	72	75	74	68	76	66	82	63	60	77	48	55	69	67	60	73	67	62	63	63	9	13	14	13	6
40521	2013-03-01	69	74	right	medium	medium	63	57	51	74	63	68	70	70	72	75	74	68	76	66	82	63	61	77	48	55	69	67	60	73	67	62	63	63	9	13	14	13	6
40521	2013-02-22	70	74	right	medium	medium	63	62	51	74	63	68	70	70	72	75	74	68	76	66	82	65	61	77	48	66	69	67	64	73	67	64	63	63	9	13	14	13	6
40521	2013-02-15	70	74	right	medium	medium	63	62	51	74	60	68	70	70	72	75	74	68	76	66	82	65	61	77	48	66	69	67	64	73	67	64	63	63	9	13	14	13	6
40521	2012-08-31	74	77	right	medium	high	63	62	51	78	64	69	70	73	72	77	67	68	76	75	80	65	64	85	57	66	78	75	64	77	67	60	68	69	9	13	14	13	6
40521	2012-02-22	71	74	right	high	medium	66	62	51	76	66	67	66	70	72	76	67	68	70	70	79	65	81	81	48	68	60	72	62	75	67	51	57	62	9	13	14	13	6
40521	2011-08-30	71	76	right	high	medium	66	62	51	76	66	64	66	70	73	73	67	63	70	69	79	65	81	78	48	68	60	72	62	77	67	51	61	53	9	13	14	13	6
40521	2011-02-22	68	72	right	high	medium	66	64	51	72	63	66	64	70	69	71	63	67	72	69	61	67	62	76	56	71	56	67	61	73	68	49	59	53	9	13	14	13	6
40521	2010-08-30	67	72	right	high	medium	66	66	51	71	63	66	64	69	67	69	60	67	72	66	57	67	60	73	54	69	50	67	72	75	68	49	53	49	9	13	14	13	6
40521	2009-08-30	67	73	right	high	medium	66	66	51	70	63	66	64	69	67	76	60	67	72	66	57	67	60	73	42	69	50	65	68	75	65	47	51	49	1	23	67	23	23
40521	2009-02-22	66	73	right	high	medium	66	61	51	70	63	66	64	69	67	71	67	69	72	66	57	62	60	71	42	67	45	58	68	75	63	47	51	49	1	23	67	23	23
40521	2008-08-30	60	72	right	high	medium	61	53	51	65	63	62	64	67	60	65	60	65	72	57	57	57	60	67	42	65	45	52	47	75	56	42	51	49	1	23	60	23	23
40521	2007-02-22	60	72	right	high	medium	61	53	51	65	63	62	64	67	60	65	60	65	72	57	57	57	60	67	42	65	45	52	47	75	56	42	51	49	1	23	60	23	23
40433	2009-02-22	60	63	right	\N	\N	21	61	67	46	\N	47	\N	42	22	54	62	67	\N	65	\N	66	\N	57	85	51	54	49	55	\N	37	23	25	\N	9	23	22	23	23
40433	2007-02-22	60	63	right	\N	\N	21	61	67	46	\N	47	\N	42	22	54	62	67	\N	65	\N	66	\N	57	85	51	54	49	55	\N	37	23	25	\N	9	23	22	23	23
104377	2016-03-10	68	68	right	high	medium	64	67	62	64	67	70	62	57	59	66	78	79	78	65	79	73	78	71	66	70	77	38	67	67	65	25	29	33	7	8	16	16	15
104377	2016-01-07	68	68	right	high	medium	64	67	62	64	67	70	62	57	59	66	80	81	78	65	79	73	78	71	68	70	77	38	67	67	65	25	29	33	7	8	16	16	15
104377	2015-12-17	69	69	right	high	medium	67	69	65	64	67	70	62	57	59	66	80	81	78	65	79	73	78	71	68	70	77	38	70	67	65	25	29	33	7	8	16	16	15
104377	2015-11-26	72	72	right	high	medium	67	76	67	69	67	73	62	57	59	66	82	83	78	65	79	73	78	71	68	71	77	38	75	70	65	25	29	33	7	8	16	16	15
104377	2015-09-21	72	72	right	high	medium	67	76	67	69	67	73	62	57	59	66	82	83	78	65	79	73	78	71	68	71	77	38	75	70	65	25	29	33	7	8	16	16	15
104377	2015-07-03	71	71	right	high	medium	66	75	66	68	66	72	61	56	63	65	82	83	76	64	79	72	78	69	64	70	76	42	74	70	64	24	28	32	6	7	15	15	14
104377	2015-04-10	71	72	right	high	medium	66	75	66	68	66	72	61	56	63	65	82	83	76	64	79	72	78	69	64	70	76	42	74	70	64	24	28	32	6	7	15	15	14
104377	2015-03-13	71	72	right	high	low	68	74	66	68	66	69	61	56	63	68	85	84	78	71	80	72	86	73	62	70	72	34	71	70	66	24	28	32	6	7	15	15	14
104377	2015-02-27	70	72	right	high	low	68	71	66	68	63	69	58	56	63	68	83	82	76	68	74	72	86	72	60	68	72	34	67	61	66	24	28	32	6	7	15	15	14
104377	2015-01-23	69	70	right	high	low	65	68	66	65	63	68	56	56	63	68	83	82	76	68	74	71	86	72	60	68	72	34	67	61	64	24	28	32	6	7	15	15	14
104377	2014-09-18	68	69	right	medium	low	64	68	66	63	63	66	56	56	60	67	82	81	76	68	74	71	86	72	59	66	66	34	67	61	64	24	28	32	6	7	15	15	14
104377	2014-04-04	67	68	right	medium	low	64	68	66	63	63	66	56	56	60	67	82	81	76	68	74	71	84	72	59	66	66	34	67	61	64	24	28	32	6	7	15	15	14
104377	2014-03-21	67	68	right	medium	low	64	68	66	63	63	66	56	56	60	67	82	81	76	68	74	71	84	72	59	66	66	34	67	61	64	24	28	32	6	7	15	15	14
104377	2014-03-07	67	69	right	medium	low	64	68	66	63	63	66	56	56	60	67	82	81	76	68	74	71	84	72	59	66	66	34	67	61	64	24	28	32	6	7	15	15	14
104377	2013-12-13	68	69	right	high	medium	64	68	66	63	63	66	56	56	60	67	82	81	76	68	74	71	84	77	59	66	74	34	67	61	64	24	28	32	6	7	15	15	14
104377	2013-09-20	68	70	right	high	medium	64	68	66	63	63	66	56	56	60	67	82	81	76	68	74	71	84	77	59	66	74	34	67	61	64	24	28	32	6	7	15	15	14
104377	2013-07-12	69	72	right	high	medium	64	70	68	63	64	66	56	56	60	67	85	82	76	68	74	72	84	77	59	66	74	34	67	61	64	24	28	32	6	7	15	15	14
104377	2013-05-31	69	72	right	high	medium	64	70	68	63	64	66	56	56	60	67	85	82	76	68	74	72	84	77	59	66	74	34	67	61	64	24	28	32	6	7	15	15	14
104377	2013-03-08	69	72	right	high	medium	64	70	68	63	64	66	56	56	60	67	85	82	76	68	74	72	84	77	59	66	74	34	67	61	64	24	28	32	6	7	15	15	14
104377	2013-02-15	69	72	right	high	medium	64	70	68	63	64	66	56	56	60	67	85	82	76	68	74	72	84	77	59	66	74	34	67	61	64	24	28	32	6	7	15	15	14
104377	2012-08-31	67	69	right	high	medium	64	65	68	61	63	67	53	56	58	65	74	77	76	66	74	71	84	75	70	65	70	34	65	61	64	24	28	32	6	7	15	15	14
104377	2012-02-22	67	68	right	high	medium	64	66	63	62	63	68	53	56	57	63	80	79	76	66	74	71	84	71	64	64	67	34	63	58	64	24	28	32	6	7	15	15	14
104377	2011-08-30	66	68	right	high	medium	66	66	63	62	63	64	53	56	57	62	80	80	76	66	74	71	82	71	64	64	68	34	63	58	64	24	28	32	6	7	15	15	14
104377	2011-02-22	68	72	right	high	medium	68	69	64	62	63	65	53	56	58	63	81	78	72	66	67	72	74	68	63	63	66	34	64	62	64	24	28	32	6	7	15	15	14
104377	2010-08-30	67	72	right	high	medium	68	69	64	62	63	57	53	56	58	63	80	78	72	66	67	72	74	68	63	63	66	34	64	62	64	24	28	32	6	7	15	15	14
104377	2010-02-22	67	72	right	high	medium	69	71	65	62	63	57	53	47	58	65	79	77	72	65	67	70	74	68	65	60	66	46	68	62	65	24	28	32	11	21	58	21	21
104377	2009-08-30	63	67	right	high	medium	28	66	55	43	63	57	53	47	36	62	74	76	72	65	67	70	74	58	52	60	50	46	51	62	56	21	21	32	11	21	36	21	21
104377	2007-08-30	63	67	right	high	medium	28	66	55	43	63	57	53	47	36	62	74	76	72	65	67	70	74	58	52	60	50	46	51	62	56	21	21	32	11	21	36	21	21
104377	2007-02-22	63	67	right	high	medium	28	66	55	43	63	57	53	47	36	62	74	76	72	65	67	70	74	58	52	60	50	46	51	62	56	21	21	32	11	21	36	21	21
170323	2015-09-21	86	90	left	medium	medium	14	14	13	32	12	13	19	11	31	23	46	52	61	81	45	36	68	38	70	17	23	15	13	44	27	11	18	16	84	87	69	86	88
170323	2014-10-17	86	90	left	medium	medium	25	25	25	32	25	25	25	25	31	23	46	52	61	81	45	36	68	38	70	25	23	25	25	25	27	25	25	25	84	87	69	86	88
170323	2014-09-18	86	90	left	medium	medium	25	25	25	32	25	25	25	25	31	23	46	52	61	76	45	36	68	38	70	25	23	25	25	25	27	25	25	25	84	87	69	86	88
170323	2014-07-18	84	88	left	medium	medium	25	25	25	32	25	25	25	25	31	23	46	52	64	76	45	36	68	38	70	25	23	25	25	25	27	25	25	25	82	87	69	86	88
170323	2014-02-28	84	88	left	medium	medium	25	25	25	32	25	25	25	25	31	23	46	52	64	76	45	36	68	38	70	25	23	25	25	25	27	25	25	25	82	87	69	86	88
170323	2013-09-20	84	88	left	medium	medium	25	25	25	32	25	25	25	25	31	23	46	52	64	76	45	36	68	38	70	25	23	25	25	25	27	25	25	25	82	88	69	84	86
170323	2013-06-28	83	88	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	58	64	78	45	36	71	56	81	17	23	15	13	34	27	11	18	16	81	87	69	84	86
170323	2013-06-07	83	88	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	58	64	78	45	36	71	56	81	17	23	15	13	34	27	11	18	16	81	87	69	84	86
170323	2013-05-24	83	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	58	64	78	45	36	71	56	81	17	23	15	13	34	27	11	18	16	80	87	69	84	83
170323	2013-04-12	83	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	58	64	78	45	36	71	56	81	17	23	15	13	34	27	11	18	16	80	87	69	84	83
170323	2013-03-22	83	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	56	64	78	45	36	71	42	81	17	23	15	13	34	27	11	18	16	80	87	69	84	83
170323	2013-03-08	83	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	56	64	78	45	36	71	42	81	17	23	15	13	34	27	11	18	16	80	87	69	84	83
170323	2013-02-22	82	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	56	64	78	45	36	71	42	78	17	23	15	13	34	27	11	18	16	80	87	64	83	82
170323	2013-02-15	82	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	56	64	78	45	36	71	42	78	17	23	15	13	34	27	11	18	16	78	88	64	83	82
170323	2012-08-31	79	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	51	58	64	74	45	36	71	56	78	17	23	15	13	34	27	11	18	16	73	89	64	77	82
170323	2012-02-22	76	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	59	58	64	71	45	36	71	56	68	17	23	15	13	34	27	11	18	16	67	84	64	77	81
170323	2011-08-30	73	87	left	medium	medium	14	14	13	32	12	13	19	11	31	23	59	58	64	71	45	36	71	56	68	17	23	15	13	34	27	11	18	16	71	80	58	63	81
170323	2011-02-22	68	75	left	medium	medium	14	14	24	38	12	13	19	11	41	28	59	58	64	63	49	57	71	52	57	17	23	24	13	31	27	11	18	16	72	66	57	61	74
170323	2010-08-30	60	68	left	medium	medium	24	24	36	38	26	27	19	21	47	18	59	48	64	54	39	37	68	52	57	17	23	24	13	37	27	11	18	27	59	57	53	59	66
170323	2010-02-22	57	59	left	medium	medium	24	24	36	38	26	27	19	21	49	22	59	48	64	54	39	37	68	52	57	21	23	58	37	37	39	22	22	27	55	53	49	56	63
170323	2009-08-30	57	59	left	medium	medium	24	24	36	38	26	27	19	21	49	22	59	48	64	54	39	37	68	52	57	38	23	58	37	37	39	31	22	27	55	53	49	56	63
170323	2007-02-22	57	59	left	medium	medium	24	24	36	38	26	27	19	21	49	22	59	48	64	54	39	37	68	52	57	38	23	58	37	37	39	31	22	27	55	53	49	56	63
32863	2016-04-28	71	71	right	medium	low	74	72	53	71	68	73	66	67	69	72	65	67	67	69	73	64	60	71	54	66	65	59	75	74	71	43	52	47	13	8	8	15	15
32863	2016-03-24	71	71	right	medium	low	76	72	53	71	68	74	66	67	69	73	65	67	67	66	73	64	60	72	54	66	65	59	68	74	71	43	52	47	13	8	8	15	15
32863	2016-03-17	71	71	right	medium	low	76	72	53	71	68	74	66	67	69	73	65	67	70	66	70	64	60	71	54	66	65	59	68	74	71	43	52	47	13	8	8	15	15
32863	2015-12-24	71	71	right	medium	low	76	70	53	70	68	74	66	67	69	73	65	67	70	66	70	64	60	71	54	66	65	59	68	74	71	43	52	47	13	8	8	15	15
32863	2015-10-16	71	71	right	medium	low	76	70	53	70	68	74	66	67	69	73	65	67	70	66	70	64	60	71	54	66	65	59	68	74	71	43	52	47	13	8	8	15	15
32863	2015-09-25	70	70	right	medium	low	76	70	53	70	68	71	66	67	69	73	65	67	70	61	70	64	60	71	54	66	61	59	68	74	71	43	52	47	13	8	8	15	15
32863	2015-09-21	70	70	right	medium	low	73	70	53	70	68	71	66	67	69	73	65	65	70	61	70	64	60	71	54	66	61	59	68	74	71	43	52	47	13	8	8	15	15
32863	2015-05-15	71	71	right	medium	low	72	69	52	69	67	70	65	66	71	74	69	69	70	67	72	63	61	71	57	65	60	58	70	73	70	42	51	46	12	7	7	14	14
32863	2015-05-08	71	71	right	medium	low	72	69	52	69	67	70	65	66	71	74	69	69	70	69	72	63	61	71	60	65	60	58	70	73	70	42	51	46	12	7	7	14	14
32863	2015-05-01	71	71	right	medium	low	72	69	52	69	67	70	65	66	71	74	69	69	70	69	72	63	61	71	60	65	60	58	70	73	70	42	51	46	12	7	7	14	14
32863	2015-04-24	71	71	right	medium	low	74	69	52	69	69	72	68	66	71	74	69	69	70	69	72	63	61	71	60	67	60	58	70	73	70	42	51	46	12	7	7	14	14
32863	2015-04-17	71	71	right	medium	low	74	69	52	69	69	72	68	66	71	74	69	69	70	69	72	63	61	71	60	67	60	58	70	73	70	42	51	46	12	7	7	14	14
32863	2015-04-10	71	71	right	high	high	74	69	52	69	69	72	68	66	71	74	69	69	70	69	72	63	61	71	60	67	60	58	70	73	70	42	51	46	12	7	7	14	14
32863	2015-03-13	72	72	right	high	high	74	72	52	73	69	72	71	66	71	74	69	69	70	69	74	65	61	73	60	69	63	58	75	75	70	42	51	46	12	7	7	14	14
32863	2014-11-14	72	72	right	high	high	74	72	52	73	69	72	71	66	71	72	69	69	70	72	74	67	61	73	60	71	63	58	75	75	70	42	51	46	12	7	7	14	14
32863	2014-09-18	72	72	right	high	high	74	72	52	73	69	72	71	66	71	72	69	69	70	72	74	67	61	73	60	71	63	58	75	75	70	42	51	46	12	7	7	14	14
32863	2014-03-21	72	72	right	high	high	72	72	52	73	69	72	71	66	71	72	69	70	71	72	74	67	61	75	60	71	63	58	75	75	70	42	51	46	12	7	7	14	14
32863	2014-02-14	73	73	right	high	high	72	72	52	73	69	73	73	66	72	73	70	72	73	73	76	67	65	77	60	71	65	58	75	75	70	42	53	49	12	7	7	14	14
32863	2013-11-01	73	73	right	high	high	72	72	52	73	69	71	73	66	72	73	70	72	73	73	76	67	65	77	60	71	65	58	75	75	70	42	53	49	12	7	7	14	14
32863	2013-05-31	73	73	right	high	high	72	72	52	73	69	71	73	66	72	73	70	72	73	73	76	67	65	77	60	71	63	60	75	75	70	42	53	49	12	7	7	14	14
32863	2013-02-15	73	73	right	high	high	72	72	52	73	69	71	73	66	72	73	70	72	73	73	76	67	65	77	60	71	63	60	75	75	70	42	53	49	12	7	7	14	14
32863	2012-08-31	72	72	right	high	high	69	70	52	75	66	72	67	66	70	73	71	70	73	73	75	67	65	76	60	71	62	60	75	72	70	42	53	49	12	7	7	14	14
32863	2012-02-22	73	73	right	high	high	69	70	47	75	67	73	67	66	70	75	72	70	73	73	77	68	65	78	62	71	62	63	75	72	70	45	53	49	12	7	7	14	14
32863	2011-08-30	72	72	right	high	medium	69	66	47	75	66	72	67	65	70	75	73	66	72	75	80	67	67	69	62	70	62	62	75	73	70	43	45	47	12	7	7	14	14
32863	2010-08-30	72	75	right	high	medium	69	67	53	76	66	76	67	65	69	76	67	70	67	69	63	66	64	69	58	69	65	51	75	77	70	37	45	47	12	7	7	14	14
32863	2010-02-22	70	75	right	high	medium	69	67	47	74	66	74	67	65	67	75	67	70	67	67	63	65	64	67	52	67	65	73	71	77	70	37	45	47	9	20	67	20	20
32863	2009-08-30	70	75	right	high	medium	69	67	47	74	66	74	67	65	67	75	67	70	67	67	63	65	64	67	52	67	65	73	71	77	70	37	45	47	9	20	67	20	20
32863	2008-08-30	72	76	right	high	medium	70	71	62	75	66	77	67	74	67	83	75	75	67	63	63	73	64	78	56	68	58	80	79	77	75	39	54	47	15	20	67	20	20
32863	2007-08-30	74	83	right	high	medium	77	63	62	73	66	73	67	74	64	81	78	75	67	69	63	73	64	86	66	68	41	80	79	77	75	39	54	47	15	20	64	20	20
32863	2007-02-22	78	83	right	high	medium	77	72	62	79	66	80	67	75	70	81	78	75	67	69	63	73	64	86	66	68	41	80	79	77	75	39	54	47	15	16	70	20	15
38798	2014-03-21	64	64	right	medium	medium	66	60	38	65	68	66	68	70	64	68	63	56	61	61	73	65	45	53	53	70	33	46	68	67	65	26	30	28	13	6	5	5	7
38798	2014-03-07	65	65	right	medium	medium	66	60	38	65	68	66	68	70	64	68	65	58	67	64	73	65	45	54	53	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2014-02-28	65	65	right	medium	medium	66	60	38	65	68	66	68	70	64	68	65	58	67	64	73	65	45	54	53	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2014-02-14	65	65	right	medium	medium	66	60	38	65	68	66	68	70	64	68	65	58	67	64	73	65	45	54	53	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2013-09-20	66	66	right	medium	medium	68	60	38	67	68	66	68	70	66	68	66	58	68	64	73	65	45	54	53	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2013-03-22	66	66	right	medium	medium	68	60	38	67	68	66	68	70	66	68	66	61	68	64	73	65	52	57	51	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2013-03-01	66	66	right	medium	medium	68	60	38	67	68	66	68	70	66	68	66	61	68	64	73	65	52	57	51	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2013-02-15	66	66	right	medium	medium	68	60	38	67	68	66	68	70	66	68	66	61	68	64	73	65	52	57	51	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2012-02-22	66	66	right	medium	medium	68	60	38	67	68	66	68	70	66	68	66	61	68	64	73	65	52	57	51	70	33	46	66	70	65	26	30	28	13	6	5	5	7
38798	2011-08-30	66	66	right	medium	medium	69	64	43	67	65	68	64	70	64	68	74	69	76	64	73	65	68	67	63	70	41	44	68	71	65	32	35	37	13	6	5	5	7
38798	2011-02-22	68	73	right	medium	medium	69	64	43	67	65	68	64	70	64	68	71	69	70	64	58	65	64	65	51	70	41	44	68	71	65	32	35	37	13	6	5	5	7
38798	2010-08-30	71	73	right	medium	medium	71	66	43	70	66	70	66	70	69	71	73	72	71	69	60	69	66	67	53	73	43	46	71	74	68	34	37	39	13	6	5	5	7
38798	2010-02-22	71	73	right	medium	medium	71	66	43	70	66	70	66	70	69	71	73	72	71	69	60	67	66	69	46	69	43	73	71	74	67	34	37	39	13	20	69	20	20
38798	2009-08-30	71	73	right	medium	medium	72	66	46	71	66	71	66	67	69	72	73	72	71	70	60	67	66	69	46	69	45	73	72	74	68	34	37	39	13	20	69	20	20
38798	2009-02-22	71	73	right	medium	medium	72	66	46	71	66	71	66	67	69	72	71	72	71	70	60	67	66	69	46	69	45	73	72	74	68	34	37	39	13	20	69	20	20
38798	2008-08-30	72	73	right	medium	medium	72	68	53	73	66	71	66	67	71	73	75	72	71	73	60	67	66	71	53	72	56	73	72	74	68	39	46	39	13	20	71	20	20
38798	2007-08-30	72	73	right	medium	medium	73	66	57	74	66	69	66	67	71	71	70	69	71	73	60	67	66	72	60	72	68	71	72	74	63	46	52	39	13	20	71	20	20
38798	2007-02-22	72	74	right	medium	medium	73	69	77	77	66	71	66	63	73	64	70	69	71	73	60	73	66	79	64	72	68	71	72	74	63	60	62	39	13	8	73	12	11
131408	2015-09-21	69	76	right	medium	medium	18	14	10	32	17	11	11	17	32	16	47	35	43	66	42	21	65	35	62	15	28	17	18	39	24	11	11	17	71	68	66	65	75
131408	2014-04-25	69	76	right	medium	medium	18	14	10	32	17	11	11	17	32	16	47	35	43	66	42	21	65	35	62	15	28	17	18	39	24	11	11	17	71	68	66	65	75
131408	2014-03-28	69	76	right	medium	medium	18	14	10	32	17	11	11	17	32	16	47	35	43	66	42	21	65	35	62	15	28	17	18	39	24	11	11	17	71	68	66	65	75
131408	2014-01-03	67	75	right	medium	medium	18	14	10	32	17	11	11	17	32	16	47	35	43	66	42	21	65	35	62	15	28	17	18	39	24	11	11	17	69	61	66	65	75
131408	2013-09-20	67	77	right	medium	medium	18	14	10	32	17	11	11	17	32	16	47	35	43	66	42	21	65	35	62	15	28	17	18	39	24	11	11	17	69	61	66	65	75
131408	2013-03-22	67	77	right	medium	medium	17	13	9	32	16	10	10	16	32	16	65	58	57	66	65	21	78	51	65	14	31	21	17	33	24	10	10	16	69	61	66	65	75
131408	2013-03-15	67	77	right	medium	medium	17	13	9	32	16	10	10	16	32	16	65	58	57	66	65	21	78	51	65	14	31	21	17	33	24	10	10	16	69	61	66	65	75
131408	2013-02-15	67	77	right	medium	medium	17	13	9	32	16	10	10	16	32	16	65	58	57	66	65	21	78	51	65	14	31	21	17	33	24	10	10	16	69	61	66	65	75
131408	2012-08-31	67	77	right	medium	medium	17	13	9	32	16	10	10	16	32	16	65	58	73	69	65	21	78	51	65	14	31	21	17	33	24	10	10	16	69	61	66	65	75
131408	2012-02-22	67	76	right	medium	medium	17	13	9	32	16	10	10	16	32	16	65	67	73	69	65	21	78	61	65	14	31	21	17	33	24	10	10	16	69	61	66	65	75
131408	2011-08-30	67	76	right	medium	medium	17	13	9	32	16	10	10	16	32	16	65	63	74	69	65	21	78	61	55	14	31	21	17	33	24	10	10	16	69	61	66	65	75
131408	2011-02-22	64	74	right	medium	medium	17	13	23	42	16	21	23	16	41	35	62	68	72	69	58	45	73	61	55	14	24	26	17	33	24	9	21	16	67	56	52	57	75
131408	2010-08-30	62	74	right	medium	medium	17	13	23	42	16	21	23	16	47	35	62	68	65	69	48	56	67	61	45	14	24	26	17	54	24	22	21	27	65	59	56	52	69
131408	2010-02-22	56	73	right	medium	medium	22	22	22	22	16	22	23	11	56	22	43	52	65	51	48	49	67	49	45	22	23	19	14	54	30	22	22	27	61	55	56	52	58
131408	2008-08-30	56	73	right	medium	medium	22	22	22	22	16	22	23	11	56	22	43	52	65	51	48	49	67	49	45	22	23	19	14	54	30	22	22	27	61	55	56	52	58
131408	2007-02-22	56	73	right	medium	medium	22	22	22	22	16	22	23	11	56	22	43	52	65	51	48	49	67	49	45	22	23	19	14	54	30	22	22	27	61	55	56	52	58
131530	2015-11-26	72	72	right	medium	medium	72	72	47	73	69	72	74	71	70	74	62	67	75	69	72	70	52	84	57	73	48	52	74	72	63	29	35	38	11	6	9	6	10
131530	2015-10-09	71	71	right	medium	medium	71	69	47	73	66	72	71	71	69	74	62	67	70	69	58	65	52	84	57	67	48	52	71	72	63	29	35	38	11	6	9	6	10
131530	2015-09-21	71	71	right	medium	medium	71	67	48	73	66	70	71	71	69	74	62	65	70	69	58	63	52	84	57	65	48	52	70	72	63	29	35	38	11	6	9	6	10
131530	2015-04-10	69	69	right	medium	medium	70	66	47	72	65	72	70	70	68	70	67	64	64	68	45	62	52	73	53	64	47	53	66	70	62	28	34	37	10	5	8	5	9
131530	2015-03-27	69	69	right	medium	medium	70	65	47	72	67	72	68	69	71	71	57	55	67	68	45	69	52	72	54	70	47	48	68	69	64	28	35	37	10	5	8	5	9
131530	2015-02-27	68	68	right	medium	medium	69	65	47	71	66	72	67	69	71	71	57	55	67	67	45	67	40	72	54	68	47	48	67	67	64	28	35	37	10	5	8	5	9
131530	2015-01-23	67	67	right	medium	medium	68	65	47	69	66	69	65	67	68	69	57	55	67	67	45	67	40	72	54	68	47	48	67	67	64	28	35	37	10	5	8	5	9
131530	2014-11-07	64	64	right	medium	medium	66	62	43	67	61	69	63	67	60	67	53	50	67	60	71	64	40	72	54	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2014-09-18	65	65	right	medium	medium	66	62	43	67	61	69	63	67	60	67	53	50	67	60	71	64	40	72	54	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2014-07-18	65	65	right	medium	medium	66	62	43	67	61	69	63	67	60	67	54	55	67	60	71	64	40	72	52	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2013-12-27	65	65	right	medium	medium	66	62	43	67	61	69	63	67	60	67	54	55	67	60	71	64	40	72	52	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2013-09-20	65	66	right	medium	medium	66	62	43	67	61	69	63	67	60	67	54	55	67	60	71	64	40	72	52	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2013-06-07	65	66	right	medium	medium	66	62	43	67	61	69	63	67	60	67	55	59	67	60	71	64	49	72	50	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2013-05-10	65	67	right	medium	medium	66	62	43	67	61	69	63	67	60	67	55	59	67	60	71	64	49	72	50	67	47	48	60	65	64	28	35	37	10	5	8	5	9
131530	2013-03-28	66	67	right	medium	medium	66	62	43	67	61	70	63	67	65	71	55	59	67	64	71	64	55	74	57	67	47	48	60	67	64	28	35	37	10	5	8	5	9
131530	2013-02-15	66	67	right	medium	medium	66	62	43	67	61	70	63	67	65	71	55	59	67	64	71	64	55	74	57	67	47	48	60	67	64	28	35	37	10	5	8	5	9
131530	2012-08-31	66	67	right	medium	medium	66	62	43	67	61	70	63	67	65	71	55	62	67	64	69	64	59	74	53	67	47	48	60	67	64	28	35	37	10	5	8	5	9
131530	2012-02-22	66	67	right	medium	medium	66	62	43	67	61	70	63	67	65	71	55	62	67	64	72	64	59	74	53	67	47	48	60	67	64	28	35	37	10	5	8	5	9
131530	2011-08-30	66	67	right	medium	medium	66	62	43	67	61	70	63	67	65	71	55	62	67	64	72	64	59	74	52	67	47	48	60	67	64	28	35	37	10	5	8	5	9
131530	2010-08-30	65	70	right	medium	medium	65	62	43	67	61	70	60	67	65	71	60	65	64	62	47	60	60	70	52	66	43	42	60	67	64	30	35	37	10	5	8	5	9
131530	2009-08-30	66	72	right	medium	medium	66	62	43	67	61	70	60	67	65	71	62	67	64	63	47	60	60	74	49	66	43	64	67	67	61	30	35	37	11	23	65	23	23
131530	2009-02-22	64	72	right	medium	medium	57	61	43	64	61	64	60	65	62	67	60	62	64	61	47	57	60	67	42	63	23	60	67	67	56	40	35	37	1	23	62	23	23
131530	2008-08-30	60	62	left	medium	medium	57	60	43	59	61	65	60	63	56	67	60	62	64	61	47	55	60	55	40	62	23	54	53	67	51	40	35	37	1	23	56	23	23
131530	2007-02-22	60	62	left	medium	medium	57	60	43	59	61	65	60	63	56	67	60	62	64	61	47	55	60	55	40	62	23	54	53	67	51	40	35	37	1	23	56	23	23
33662	2015-05-08	63	63	right	medium	medium	60	60	64	65	63	58	61	62	63	63	26	29	37	56	45	65	38	51	69	64	57	70	72	71	69	40	54	50	13	10	10	7	12
33662	2015-01-09	65	65	right	medium	medium	61	62	65	67	66	60	63	63	64	65	30	32	39	58	45	67	38	56	69	67	62	70	72	71	70	45	57	52	13	10	10	7	12
33662	2014-09-18	66	66	right	medium	medium	61	62	67	67	67	60	63	63	64	67	35	32	42	58	47	70	40	64	69	69	62	70	72	71	72	47	58	55	13	10	10	7	12
33662	2014-05-02	65	65	right	medium	medium	61	68	69	67	67	59	63	63	64	65	35	32	42	58	47	70	40	64	69	69	62	70	72	71	72	53	58	55	13	10	10	7	12
33662	2013-09-20	67	67	right	medium	medium	61	68	69	67	67	59	63	63	64	68	35	32	47	67	47	70	40	72	72	69	62	70	72	71	72	53	58	55	13	10	10	7	12
33662	2013-05-31	67	67	right	medium	medium	61	68	69	67	67	59	63	63	64	68	35	32	47	67	47	70	49	72	72	69	62	70	72	71	72	53	58	55	13	10	10	7	12
33662	2013-05-10	68	68	right	medium	medium	63	68	69	69	67	63	63	63	67	70	35	32	47	67	47	70	49	72	72	69	62	70	72	71	72	53	60	55	13	10	10	7	12
33662	2013-03-04	69	69	right	medium	medium	66	68	69	71	71	65	66	65	70	70	35	32	47	69	47	72	49	72	72	70	62	70	72	71	72	53	60	55	13	10	10	7	12
33662	2013-02-22	69	69	right	medium	medium	66	68	69	71	71	65	66	65	70	70	35	32	47	69	47	72	49	72	72	70	62	70	72	71	72	53	60	55	13	10	10	7	12
33662	2013-02-15	69	69	right	medium	medium	66	68	69	71	71	65	66	65	70	70	35	32	47	69	47	72	49	72	72	70	62	70	72	71	72	53	60	55	13	10	10	7	12
33662	2012-08-31	71	71	right	high	medium	67	68	69	72	73	67	66	65	71	72	35	33	47	72	45	75	53	73	73	72	62	70	75	73	72	56	60	59	13	10	10	7	12
33662	2012-02-22	71	71	right	medium	medium	67	68	69	72	73	67	66	65	71	72	35	33	47	72	49	71	53	73	73	72	62	70	70	73	72	56	60	59	13	10	10	7	12
33662	2011-08-30	68	68	right	medium	medium	65	67	67	72	69	61	63	63	66	72	38	36	47	72	49	70	53	68	75	70	56	61	72	73	72	56	60	59	13	10	10	7	12
33662	2011-02-22	69	71	right	medium	medium	65	66	67	72	62	65	63	63	67	72	47	57	52	72	62	70	57	77	67	67	56	65	70	75	72	56	64	59	13	10	10	7	12
33662	2010-08-30	69	71	right	medium	medium	65	66	67	70	62	65	63	63	67	72	47	62	52	72	62	70	57	77	67	67	56	72	66	74	63	56	64	59	13	10	10	7	12
33662	2010-02-22	70	71	right	medium	medium	65	67	67	72	62	65	63	63	67	72	47	62	52	68	62	70	57	77	67	67	56	74	74	74	83	66	64	59	14	25	67	25	25
33662	2009-08-30	69	71	right	medium	medium	65	66	67	72	62	65	63	63	67	72	47	62	52	64	62	70	57	77	67	67	56	74	74	74	83	66	64	59	14	25	67	25	25
33662	2009-02-22	69	70	right	medium	medium	65	66	67	72	62	65	63	63	67	70	47	62	52	64	62	70	57	77	67	67	56	74	74	74	69	47	57	59	14	25	67	25	25
33662	2008-08-30	69	70	right	medium	medium	63	65	68	72	62	65	63	63	67	67	51	62	52	64	62	70	57	77	67	67	56	74	74	74	69	47	57	59	14	25	67	25	25
33662	2007-08-30	68	67	right	medium	medium	63	65	64	69	62	68	63	62	62	70	61	66	52	58	62	65	57	71	66	63	61	72	71	74	69	27	36	59	14	25	62	25	25
33662	2007-02-22	70	69	right	medium	medium	65	67	66	71	62	70	63	71	64	72	63	68	52	60	62	67	57	73	68	65	63	72	71	74	71	29	38	59	14	15	64	6	10
178276	2011-08-30	58	68	right	medium	medium	61	26	51	56	34	31	33	33	51	57	75	70	72	57	84	44	65	62	45	31	57	56	24	35	36	56	58	60	12	7	9	6	5
178276	2010-08-30	58	66	right	medium	medium	36	26	56	53	34	31	33	33	48	57	60	64	63	61	57	44	54	62	58	31	56	58	34	55	36	59	56	58	12	7	9	6	5
178276	2009-08-30	56	66	right	medium	medium	36	22	49	53	34	27	33	29	48	56	60	64	63	61	57	30	54	60	56	27	56	57	52	55	53	59	55	58	8	21	48	21	21
178276	2007-02-22	56	66	right	medium	medium	36	22	49	53	34	27	33	29	48	56	60	64	63	61	57	30	54	60	56	27	56	57	52	55	53	59	55	58	8	21	48	21	21
37202	2012-02-22	70	72	right	medium	low	75	65	45	65	56	73	67	72	68	72	72	69	73	72	73	58	54	58	46	62	45	28	66	67	54	22	21	27	10	10	9	5	13
37202	2011-08-30	70	72	right	low	low	75	65	45	65	56	73	67	72	68	72	70	70	73	72	73	58	57	68	46	62	45	28	66	67	54	22	21	27	10	10	9	5	13
37202	2011-02-22	70	76	right	low	low	74	65	45	65	56	74	65	72	65	73	74	75	73	72	51	58	67	58	46	62	45	28	63	67	54	22	21	27	10	10	9	5	13
37202	2010-08-30	71	76	right	low	low	74	65	45	65	56	74	65	72	67	73	76	77	75	72	51	58	67	58	47	62	51	28	56	67	54	22	21	27	10	10	9	5	13
37202	2009-08-30	72	76	right	low	low	75	65	45	65	56	77	65	72	67	75	77	79	75	72	51	58	67	68	47	62	51	60	62	67	65	22	21	27	13	20	67	20	20
37202	2009-02-22	72	76	right	low	low	75	65	45	65	56	77	65	72	67	75	77	79	75	72	51	58	67	68	47	62	51	60	62	67	65	22	21	27	13	20	67	20	20
37202	2008-08-30	69	76	right	low	low	75	55	49	60	56	71	65	55	59	72	77	78	75	71	51	58	67	68	47	53	61	49	56	67	62	27	21	27	13	20	59	20	20
37202	2007-08-30	71	76	right	low	low	75	55	49	60	56	71	65	55	59	72	77	78	75	71	51	58	67	68	47	53	61	49	56	67	62	27	21	27	13	20	59	20	20
37202	2007-02-22	59	65	right	low	low	62	45	49	60	56	59	65	62	59	60	66	65	75	58	51	58	67	68	69	53	61	49	56	67	62	47	51	27	13	8	59	10	14
37069	2016-05-12	71	71	right	high	high	54	70	78	66	74	63	57	54	54	68	57	65	53	68	38	76	70	78	90	72	71	42	74	66	68	33	44	29	10	11	10	7	13
37069	2016-04-14	72	72	right	high	high	54	72	78	66	74	65	57	54	54	70	63	67	57	70	45	76	74	78	90	72	71	42	74	66	68	33	44	29	10	11	10	7	13
37069	2016-02-11	72	72	right	high	high	54	72	73	68	74	65	57	54	54	70	66	67	57	73	45	76	74	80	90	72	71	48	74	70	68	33	44	29	10	11	10	7	13
37069	2016-01-21	73	73	right	high	high	54	72	75	68	74	65	57	54	54	72	66	67	57	73	45	76	74	80	90	72	71	48	74	70	68	33	44	29	10	11	10	7	13
37069	2016-01-07	72	72	right	high	high	54	70	75	68	74	65	57	54	54	72	66	67	57	73	45	76	74	80	90	72	71	48	74	70	68	33	44	29	10	11	10	7	13
37069	2015-11-19	73	73	right	high	high	54	73	77	68	74	65	57	54	54	72	66	67	57	73	45	76	74	80	90	72	71	48	74	70	68	33	44	29	10	11	10	7	13
37069	2015-11-12	74	74	right	high	high	54	73	78	74	74	65	57	54	54	72	72	73	57	73	45	76	79	81	87	72	71	48	77	72	68	33	44	29	10	11	10	7	13
37069	2015-09-21	75	75	right	high	high	54	73	81	74	74	65	57	54	54	72	72	73	57	73	45	76	79	81	87	72	71	48	77	72	68	33	44	29	10	11	10	7	13
37069	2015-03-27	74	74	right	high	high	53	73	80	73	73	64	56	53	53	74	72	75	57	72	45	75	75	83	87	71	70	47	76	71	67	32	43	28	9	10	9	6	12
37069	2015-01-16	73	73	right	high	medium	53	73	78	71	67	63	56	53	53	72	71	73	56	72	45	74	74	76	84	69	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2014-09-18	73	73	right	high	medium	53	73	78	71	67	63	56	53	53	72	71	73	56	72	45	74	74	76	84	69	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2014-02-28	73	73	right	high	medium	53	73	78	71	67	63	56	53	53	72	71	73	56	72	45	74	72	76	84	69	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2013-12-13	72	72	right	high	medium	51	72	78	71	66	62	56	53	53	72	71	69	56	71	45	69	72	74	86	67	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2013-11-29	71	71	right	high	medium	51	72	78	71	66	62	56	53	53	72	71	69	55	68	35	69	77	74	86	67	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2013-11-22	71	71	right	high	medium	51	72	78	71	66	62	56	53	53	72	71	70	55	68	35	69	77	74	86	67	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2013-09-20	71	71	right	high	medium	51	72	78	71	66	62	56	53	53	72	72	70	55	68	35	69	77	74	87	67	66	47	76	71	67	32	43	28	9	10	9	6	12
37069	2013-07-05	71	71	right	high	medium	51	72	77	71	66	62	56	53	53	71	72	71	55	68	35	69	76	74	87	67	66	47	72	71	67	32	43	28	9	10	9	6	12
37069	2013-02-15	71	72	right	high	medium	51	72	77	71	66	62	56	53	53	71	72	71	55	68	35	69	76	74	87	67	66	47	72	71	67	32	43	28	9	10	9	6	12
37069	2012-08-31	71	72	right	high	medium	46	71	77	71	66	63	56	53	58	71	69	71	57	67	37	69	73	74	90	67	65	42	72	71	67	32	43	28	9	10	9	6	12
37069	2012-02-22	71	72	right	high	medium	46	71	77	71	66	63	56	53	58	73	70	72	57	67	37	69	79	74	90	67	65	42	72	71	67	32	43	28	9	10	9	6	12
37069	2011-08-30	71	73	right	high	medium	46	72	77	73	66	63	56	55	61	71	70	74	57	68	38	73	78	74	89	67	63	39	72	71	70	27	38	31	9	10	9	6	12
37069	2011-02-22	71	74	right	high	medium	46	72	77	73	66	63	56	55	61	71	67	72	57	68	82	73	67	70	83	67	63	39	72	73	70	27	38	31	9	10	9	6	12
37069	2010-08-30	71	74	right	high	medium	46	72	77	73	66	63	56	55	61	71	67	72	57	68	73	73	67	70	79	67	63	39	72	73	70	27	38	31	9	10	9	6	12
37069	2010-02-22	72	75	right	high	medium	46	74	77	73	66	65	56	55	63	72	69	73	57	68	73	73	67	71	79	67	65	72	75	73	76	27	38	31	3	23	63	23	23
37069	2009-08-30	73	75	right	high	medium	56	77	79	72	66	63	56	53	65	71	71	73	57	70	73	73	67	73	79	67	65	72	75	73	77	27	38	31	3	23	65	23	23
37069	2009-02-22	69	75	right	high	medium	56	72	71	68	66	62	56	51	54	67	69	71	57	65	73	69	67	65	78	67	62	66	67	73	65	27	38	31	3	23	54	23	23
37069	2008-08-30	69	73	right	high	medium	56	70	73	68	66	62	56	51	54	67	73	71	57	67	73	67	67	75	78	62	67	66	65	73	63	27	38	31	3	23	54	23	23
37069	2007-08-30	60	67	right	high	medium	43	59	67	58	66	52	56	42	43	62	71	62	57	58	73	60	67	60	78	46	67	49	38	73	54	32	38	31	3	23	43	23	23
37069	2007-02-22	56	62	right	high	medium	43	57	66	58	66	46	56	54	43	59	46	56	57	49	73	56	67	58	78	46	57	49	38	73	54	32	38	31	3	5	43	6	5
149260	2016-01-14	64	64	left	medium	medium	11	13	14	32	11	15	14	20	28	27	58	56	56	62	51	39	55	48	66	17	36	25	14	36	28	12	12	13	65	67	64	60	64
149260	2015-12-10	63	63	left	medium	medium	11	13	14	32	11	15	14	20	28	27	58	56	56	62	51	39	55	48	66	17	36	25	14	36	28	12	12	13	64	66	64	60	63
149260	2015-09-21	62	62	left	medium	medium	11	13	14	32	11	15	14	20	28	27	58	56	56	62	51	39	55	48	66	17	36	25	14	36	28	12	12	13	64	66	63	56	63
149260	2011-08-30	62	62	left	medium	medium	11	13	14	32	11	15	14	20	28	27	58	56	56	62	51	39	55	48	66	17	36	25	14	36	28	12	12	13	64	66	63	56	63
149260	2011-02-22	62	65	left	medium	medium	23	13	14	32	9	21	25	20	28	27	58	56	56	62	70	39	55	48	66	17	36	25	14	36	28	12	12	13	64	66	63	56	63
149260	2010-08-30	62	65	left	medium	medium	23	13	33	32	23	21	25	20	28	27	58	56	56	62	70	39	55	48	66	17	36	25	14	59	28	24	26	28	64	66	63	56	63
149260	2010-02-22	58	65	left	medium	medium	23	21	33	32	23	21	25	20	58	27	58	56	56	62	70	39	55	63	70	22	36	47	56	59	44	24	26	28	59	61	58	51	58
149260	2009-08-30	58	65	left	medium	medium	23	40	33	32	23	21	25	20	58	27	58	56	56	62	70	39	55	63	70	22	36	47	56	59	44	24	26	28	59	61	58	51	58
149260	2007-02-22	58	65	left	medium	medium	23	40	33	32	23	21	25	20	58	27	58	56	56	62	70	39	55	63	70	22	36	47	56	59	44	24	26	28	59	61	58	51	58
38799	2010-08-30	66	71	left	\N	\N	69	61	43	64	61	66	70	70	62	63	71	70	68	66	61	69	63	65	53	67	48	46	68	61	64	32	36	41	5	9	9	15	7
38799	2010-02-22	66	71	left	\N	\N	71	61	43	64	61	66	70	70	62	63	73	71	68	66	61	69	63	65	53	68	48	62	64	61	63	32	36	41	11	20	62	20	20
38799	2009-08-30	69	71	left	\N	\N	76	63	46	66	61	66	70	73	65	64	78	76	68	68	61	74	63	67	56	69	58	64	67	61	63	32	36	41	11	20	65	20	20
38799	2007-08-30	71	72	left	\N	\N	76	64	51	66	61	67	70	73	69	65	78	83	68	73	61	69	63	70	57	66	64	62	67	61	63	32	38	41	11	20	69	20	20
38799	2007-02-22	71	73	left	\N	\N	72	67	65	66	61	67	70	57	69	65	79	84	68	75	61	64	63	74	62	66	64	62	67	61	57	32	56	41	11	13	69	7	13
38353	2015-04-10	62	62	left	medium	medium	57	55	60	65	61	57	62	66	65	65	42	35	45	56	59	64	33	57	67	65	55	67	60	65	56	37	57	52	14	15	13	13	6
38353	2015-03-06	60	60	left	medium	medium	57	55	60	65	61	57	62	66	65	65	45	35	47	56	59	64	33	60	67	65	55	64	60	65	56	37	57	52	14	15	13	13	6
38353	2015-01-30	62	62	left	medium	medium	60	57	62	65	62	62	63	66	65	68	47	36	50	60	59	65	33	64	67	68	57	64	60	65	56	45	59	55	14	15	13	13	6
38353	2014-09-18	62	62	left	medium	medium	60	57	62	65	62	62	63	66	65	68	47	36	50	60	59	65	33	64	67	68	57	64	60	65	56	45	59	55	14	15	13	13	6
38353	2014-03-28	64	64	left	medium	medium	60	57	62	64	62	62	63	66	65	67	47	39	50	63	59	65	33	64	67	68	57	64	60	65	56	45	59	55	14	15	13	13	6
38353	2013-09-20	64	64	left	medium	medium	60	57	62	64	62	62	63	66	65	67	47	39	50	63	59	65	33	64	67	68	57	64	60	65	56	45	59	55	14	15	13	13	6
38353	2013-02-15	64	64	left	medium	medium	55	67	64	63	64	68	54	58	60	70	58	39	49	69	69	58	33	64	65	68	53	47	66	69	54	39	59	55	14	15	13	13	6
38353	2012-08-31	64	64	left	medium	medium	55	67	64	63	64	68	54	58	60	70	58	41	49	69	67	58	42	64	65	68	53	47	66	69	54	39	59	55	14	15	13	13	6
38353	2012-02-22	64	64	left	medium	medium	55	67	64	63	64	68	54	58	60	70	58	41	49	63	70	58	42	64	65	68	53	47	66	69	54	39	59	55	14	15	13	13	6
38353	2011-08-30	64	64	left	medium	medium	55	67	64	63	64	68	54	58	60	70	58	46	49	63	70	58	42	64	65	68	53	47	66	69	54	39	59	55	14	15	13	13	6
38353	2008-08-30	64	64	left	medium	medium	55	67	64	63	64	68	54	58	60	70	58	46	49	63	70	58	42	64	65	68	53	47	66	69	54	39	59	55	14	15	13	13	6
38353	2007-08-30	65	64	left	medium	medium	55	67	64	63	64	68	54	58	60	70	58	46	49	63	70	58	42	64	65	68	53	47	66	69	54	39	59	55	14	15	13	13	6
38353	2007-02-22	65	64	left	medium	medium	55	67	64	63	64	68	54	54	60	70	58	46	49	63	70	58	42	64	65	68	53	47	66	69	54	39	59	55	14	12	13	8	12
38800	2015-03-20	64	64	left	medium	medium	58	34	67	55	37	47	47	44	57	58	54	57	68	61	61	65	66	69	76	39	57	66	42	49	56	63	64	62	9	11	9	8	5
38800	2014-09-18	64	64	left	medium	medium	59	34	67	56	37	48	47	44	58	59	54	62	68	61	61	65	66	69	76	39	57	66	42	49	56	64	65	63	9	11	9	8	5
38800	2014-04-04	63	63	left	medium	medium	59	34	67	56	37	48	47	44	58	59	62	62	68	61	61	65	66	69	66	39	57	66	42	49	56	64	65	63	9	11	9	8	5
38800	2014-02-21	65	65	left	medium	medium	59	34	67	56	37	48	47	44	58	59	62	62	68	64	61	65	66	79	76	39	67	66	42	49	56	64	65	63	9	11	9	8	5
38800	2013-05-10	65	65	left	medium	medium	59	34	67	56	37	48	47	44	58	59	62	62	68	64	61	65	66	79	76	39	67	66	42	49	56	64	65	63	9	11	9	8	5
38800	2013-03-08	66	66	left	medium	medium	62	34	68	58	37	48	47	44	61	62	62	62	68	64	61	65	66	79	79	39	67	66	42	49	56	65	66	64	9	11	9	8	5
38800	2013-02-15	67	67	left	medium	medium	62	34	68	58	37	48	47	44	61	62	62	62	68	64	61	65	66	79	79	39	67	68	42	49	56	67	68	66	9	11	9	8	5
38800	2012-08-31	67	67	left	medium	medium	62	34	68	58	37	48	47	44	61	62	62	64	68	64	58	65	66	77	79	39	67	68	42	49	56	67	68	66	9	11	9	8	5
38800	2012-02-22	67	68	left	medium	medium	62	34	68	58	37	48	47	44	61	62	62	64	68	64	58	65	66	77	79	39	67	68	42	49	56	67	68	66	9	11	9	8	5
38800	2011-08-30	67	68	left	medium	medium	62	34	68	58	37	48	47	44	61	62	64	64	68	64	57	65	66	77	79	39	67	68	42	49	56	67	68	66	9	11	9	8	5
38800	2011-02-22	66	68	left	medium	medium	57	24	70	56	37	43	47	44	58	58	62	65	63	62	70	65	67	71	72	39	64	71	42	60	56	66	67	65	9	11	9	8	5
38800	2010-08-30	67	68	left	medium	medium	62	44	70	58	37	48	47	54	61	62	63	66	65	62	70	65	69	75	74	39	63	77	52	60	56	67	68	66	9	11	9	8	5
38800	2009-08-30	68	71	left	medium	medium	62	44	71	58	37	48	47	54	61	62	63	66	65	62	70	65	69	75	74	39	63	62	67	60	65	69	70	66	5	22	61	22	22
38800	2009-02-22	64	66	left	medium	medium	62	44	71	58	37	48	47	54	61	58	61	66	65	59	70	65	69	71	71	39	63	62	61	60	65	66	63	66	5	22	61	22	22
38800	2008-08-30	64	66	left	medium	medium	62	64	71	58	37	48	47	54	61	58	61	66	65	59	70	65	69	71	71	39	63	62	61	60	65	66	63	66	5	22	61	22	22
38800	2007-08-30	67	66	left	medium	medium	62	64	71	58	37	48	47	54	61	58	61	66	65	59	70	65	69	71	71	39	63	62	61	60	65	66	63	66	5	22	61	22	22
38800	2007-02-22	64	68	left	medium	medium	62	64	74	57	37	50	47	65	62	60	61	66	65	59	70	65	69	70	64	39	57	62	61	60	65	64	60	66	5	6	62	3	6
13131	2014-10-24	66	66	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	64	64	56	68	66
13131	2014-10-02	65	65	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	64	63	56	65	67
13131	2014-09-18	66	66	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	65	66	56	65	69
13131	2014-07-25	66	66	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	65	66	56	65	69
13131	2014-03-28	66	66	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	65	66	56	65	69
13131	2014-02-28	66	67	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	65	66	56	65	69
13131	2013-09-20	67	67	right	medium	medium	25	25	25	32	25	25	25	25	36	24	48	31	38	73	53	41	61	25	68	25	31	25	25	25	29	25	25	25	66	67	56	65	71
13131	2013-02-15	68	68	right	medium	medium	14	11	12	32	18	17	10	11	36	24	60	60	68	73	53	41	83	52	74	13	47	23	11	31	29	13	12	12	67	68	57	66	72
13131	2012-08-31	65	67	right	medium	medium	14	11	12	32	18	17	10	11	36	24	60	60	74	73	53	41	83	52	74	13	47	23	11	31	29	13	12	12	67	61	57	62	68
13131	2012-02-22	66	66	right	medium	medium	14	11	12	32	18	17	10	11	36	24	60	60	74	73	38	41	83	52	74	13	47	23	11	31	29	13	12	12	68	61	57	64	69
13131	2011-08-30	65	66	right	medium	medium	14	11	12	32	18	17	10	11	36	24	60	60	74	73	38	41	83	52	74	13	47	23	11	31	29	13	12	12	68	61	57	64	66
13131	2011-02-22	65	69	right	medium	medium	14	11	12	32	18	17	23	11	36	24	62	61	84	73	71	41	83	52	74	13	47	23	11	31	29	13	12	12	68	61	57	64	66
13131	2010-08-30	66	69	right	medium	medium	14	11	12	32	18	17	23	11	36	24	62	61	84	73	71	61	83	65	74	9	47	23	11	52	29	13	12	8	71	61	58	64	67
13131	2010-02-22	66	69	right	medium	medium	21	21	21	32	18	21	23	11	58	24	62	61	84	73	71	48	83	56	74	21	47	43	16	52	67	21	21	8	70	62	58	64	67
13131	2009-08-30	64	69	right	medium	medium	24	21	21	22	18	27	23	11	58	21	60	63	84	73	71	21	83	58	52	21	47	43	16	52	67	21	21	8	64	62	58	62	68
13131	2007-02-22	64	69	right	medium	medium	24	21	21	22	18	27	23	11	58	21	60	63	84	73	71	21	83	58	52	21	47	43	16	52	67	21	21	8	64	62	58	62	68
30485	2010-02-22	64	73	left	\N	\N	51	62	66	62	\N	54	\N	53	56	64	68	68	\N	61	\N	73	\N	63	80	56	66	62	66	\N	62	36	24	\N	15	21	56	21	21
30485	2009-08-30	68	73	left	\N	\N	51	69	73	62	\N	54	\N	53	56	66	72	68	\N	67	\N	73	\N	63	80	67	75	68	74	\N	70	36	24	\N	15	21	56	21	21
30485	2007-02-22	68	73	left	\N	\N	51	69	73	62	\N	54	\N	53	56	66	72	68	\N	67	\N	73	\N	63	80	67	75	68	74	\N	70	36	24	\N	15	21	56	21	21
37909	2012-02-22	64	64	right	medium	medium	57	64	70	67	55	57	56	63	64	64	41	37	52	62	65	67	52	67	59	65	57	60	71	70	62	42	50	47	12	9	8	9	6
37909	2011-08-30	65	65	right	medium	medium	57	64	70	67	55	57	56	63	64	64	41	44	51	62	67	67	52	72	56	65	62	61	71	70	62	42	52	50	12	9	8	9	6
37909	2011-02-22	64	67	right	medium	medium	57	64	70	67	55	57	56	63	65	64	52	60	55	62	52	67	57	70	57	65	62	63	73	70	62	42	52	50	12	9	8	9	6
37909	2010-08-30	66	67	right	medium	medium	59	65	72	67	57	57	56	64	65	64	55	65	59	67	62	70	65	75	60	67	65	64	74	70	64	52	57	55	12	9	8	9	6
37909	2009-08-30	66	67	right	medium	medium	59	65	72	67	57	57	56	64	65	64	55	65	59	67	62	70	65	75	60	67	65	72	74	70	69	52	57	55	8	25	65	25	25
37909	2009-02-22	67	69	right	medium	medium	60	67	72	67	57	60	56	62	62	65	57	67	59	69	62	70	65	75	62	67	65	72	74	70	70	42	57	55	8	25	62	25	25
37909	2008-08-30	67	67	right	medium	medium	62	68	72	67	57	60	56	57	62	65	62	67	59	69	62	67	65	75	55	67	65	70	72	70	67	42	57	55	8	25	62	25	25
37909	2007-08-30	67	67	right	medium	medium	62	68	72	67	57	60	56	57	62	65	62	67	59	69	62	67	65	75	55	67	60	70	72	70	67	42	57	55	8	25	62	25	25
37909	2007-02-22	68	67	right	medium	medium	63	69	74	69	57	63	56	68	64	65	63	68	59	71	62	68	65	73	54	67	57	70	72	70	68	43	57	55	8	10	64	10	11
94462	2013-05-10	67	70	left	low	medium	62	22	71	60	18	37	18	27	57	57	58	53	53	67	49	60	65	53	77	24	67	71	36	52	34	66	67	65	6	5	15	11	9
94462	2013-02-15	69	70	left	low	medium	53	22	72	60	18	37	18	27	57	57	58	53	53	67	49	60	65	70	77	24	67	72	37	52	34	69	70	67	6	5	15	11	9
94462	2012-08-31	69	70	left	low	medium	53	22	72	60	18	37	18	27	57	57	58	57	52	67	47	60	65	70	77	24	67	72	37	52	34	69	70	67	6	5	15	11	9
94462	2012-02-22	68	70	left	low	medium	53	22	72	60	18	37	18	27	57	55	58	57	52	67	57	60	65	70	75	24	67	72	37	52	34	67	69	64	6	5	15	11	9
94462	2011-08-30	68	70	left	low	medium	53	22	72	60	18	37	18	27	57	55	58	58	52	67	56	60	65	70	75	24	67	72	37	52	34	67	69	64	6	5	15	11	9
94462	2010-08-30	64	69	left	low	medium	53	22	70	57	18	37	18	27	55	50	57	64	55	62	72	60	67	68	75	24	67	64	45	62	34	62	64	60	6	5	15	11	9
94462	2010-02-22	64	74	left	low	medium	43	22	70	57	18	37	18	27	55	50	57	64	55	62	72	60	67	68	75	24	67	64	59	62	55	62	64	60	5	21	55	21	21
94462	2009-08-30	62	70	left	low	medium	43	21	72	32	18	36	18	27	38	42	57	64	55	59	72	60	67	68	72	22	67	41	52	62	52	62	64	60	5	21	38	21	21
94462	2009-02-22	64	74	left	low	medium	38	21	78	27	18	36	18	27	33	42	57	64	55	59	72	22	67	68	69	22	68	41	52	62	52	64	66	60	5	21	33	21	21
94462	2008-08-30	64	67	right	low	medium	38	21	78	27	18	36	18	27	33	42	57	64	55	59	72	22	67	68	69	22	68	41	52	62	52	64	66	60	5	21	33	21	21
94462	2007-08-30	66	67	right	low	medium	38	21	78	27	18	36	18	27	33	42	57	64	55	59	72	22	67	68	69	22	68	41	52	62	52	64	66	60	5	21	33	21	21
94462	2007-02-22	66	67	right	low	medium	38	21	78	27	18	36	18	27	33	42	57	64	55	59	72	22	67	68	69	22	68	41	52	62	52	64	66	60	5	21	33	21	21
41106	2010-08-30	64	68	right	\N	\N	59	63	53	59	56	63	48	54	53	58	85	83	78	68	53	65	73	71	56	58	36	31	52	58	62	25	26	22	8	14	5	11	6
41106	2010-02-22	65	68	right	\N	\N	59	68	53	55	56	63	48	54	49	58	85	83	78	68	53	65	73	71	56	58	36	56	61	58	60	25	26	22	7	20	49	20	20
41106	2009-08-30	66	68	right	\N	\N	64	69	53	59	56	63	48	54	49	56	85	83	78	66	53	67	73	68	56	61	36	60	56	58	58	25	26	22	7	20	49	20	20
41106	2009-02-22	66	68	right	\N	\N	51	68	57	53	56	63	48	54	43	58	85	83	78	66	53	65	73	68	56	63	36	45	54	58	58	25	26	22	7	20	43	20	20
41106	2008-08-30	66	68	right	\N	\N	57	68	57	52	56	66	48	54	47	59	84	82	78	59	53	63	73	70	59	67	46	53	54	58	68	25	26	22	7	20	47	20	20
41106	2007-08-30	70	71	right	\N	\N	57	79	57	52	56	66	48	54	47	59	84	82	78	59	53	63	73	70	59	67	46	53	54	58	68	25	26	22	7	20	47	20	20
41106	2007-02-22	70	73	right	\N	\N	57	79	57	52	56	66	48	68	47	59	84	82	78	59	53	63	73	70	59	67	46	53	54	58	68	25	26	22	7	6	47	7	6
46231	2016-01-21	65	65	right	high	medium	68	32	60	63	22	50	40	33	57	58	62	67	59	50	71	53	59	77	66	40	67	66	58	63	35	68	68	67	7	16	14	11	15
46231	2015-09-21	65	65	right	high	medium	68	32	60	63	22	50	40	33	57	58	59	67	59	50	71	53	59	77	63	40	67	66	58	63	35	68	68	67	7	16	14	11	15
46231	2015-02-06	64	64	right	high	medium	71	31	59	62	21	49	39	32	60	57	59	67	59	49	71	52	59	77	63	39	66	65	57	62	34	62	65	63	6	15	13	10	14
46231	2014-09-18	63	63	right	high	medium	71	31	59	62	21	49	39	32	60	57	59	67	59	49	71	52	59	77	63	39	66	65	57	62	34	62	61	63	6	15	13	10	14
46231	2014-04-18	63	63	right	high	medium	71	31	59	62	21	49	39	32	60	57	62	70	57	49	71	52	58	74	62	39	66	65	57	62	34	62	61	63	6	15	13	10	14
46231	2014-02-07	63	63	right	high	medium	71	31	59	62	21	49	39	32	60	57	62	70	57	49	71	52	58	74	62	39	66	65	57	62	34	62	61	63	6	15	13	10	14
46231	2014-01-10	63	63	right	high	medium	71	31	59	62	21	49	39	32	60	57	62	70	57	49	71	52	58	74	62	39	66	65	57	62	34	62	61	63	6	15	13	10	14
46231	2013-12-06	62	62	right	high	medium	67	31	59	62	21	49	39	32	60	57	62	70	57	49	71	52	58	70	62	39	66	65	57	49	34	62	61	63	6	15	13	10	14
46231	2013-09-20	62	62	right	high	medium	68	31	59	62	21	49	39	32	60	57	62	70	57	49	71	52	58	70	62	39	66	65	57	49	34	62	61	63	6	15	13	10	14
46231	2013-05-24	62	62	right	high	medium	68	31	59	62	21	49	39	32	60	57	62	65	56	49	71	52	58	69	61	39	66	65	57	49	34	62	61	63	6	15	13	10	14
46231	2013-04-05	61	61	right	high	medium	65	31	59	55	21	33	39	32	60	57	62	65	56	49	71	52	58	63	61	39	66	65	48	49	34	62	59	63	6	15	13	10	14
46231	2013-02-15	60	60	right	high	medium	58	31	59	55	21	33	39	32	60	57	62	65	56	49	71	52	58	63	61	39	66	65	48	49	34	62	59	63	6	15	13	10	14
46231	2012-08-31	60	60	right	high	medium	58	31	59	55	21	33	39	32	60	57	62	65	56	49	71	52	58	63	61	39	66	65	48	49	34	62	59	63	6	15	13	10	14
46231	2011-02-22	60	60	right	high	medium	58	31	59	55	21	33	39	32	60	57	62	65	56	49	71	52	58	63	61	39	66	65	48	49	34	62	59	63	6	15	13	10	14
46231	2010-08-30	57	60	right	high	medium	58	31	51	50	21	33	39	32	52	50	58	55	56	49	49	52	52	63	52	39	59	58	51	49	34	62	59	61	6	15	13	10	14
46231	2010-02-22	56	70	right	high	medium	58	31	51	50	21	33	39	32	52	50	58	55	56	49	49	52	52	63	52	39	53	44	48	49	49	62	59	61	7	23	52	23	23
46231	2009-08-30	63	73	right	high	medium	66	35	53	53	21	39	39	32	57	59	69	68	56	63	49	63	52	78	60	49	59	59	58	49	56	68	65	61	7	23	57	23	23
46231	2008-08-30	61	73	right	high	medium	58	25	53	51	21	23	39	32	55	49	64	63	56	63	49	43	52	74	60	39	59	59	48	49	56	68	65	61	7	23	55	23	23
46231	2007-08-30	61	73	right	high	medium	58	25	53	51	21	23	39	32	55	49	64	63	56	63	49	43	52	74	60	39	59	59	48	49	56	68	65	61	7	23	55	23	23
46231	2007-02-22	61	73	right	high	medium	58	25	53	51	21	19	39	56	55	49	64	63	56	63	49	43	52	74	60	39	59	59	48	49	56	68	65	61	7	6	55	11	5
95609	2013-04-12	62	62	right	\N	\N	55	35	62	52	36	39	43	40	51	49	70	68	56	65	74	65	81	75	71	38	76	62	46	50	54	56	64	60	13	8	10	14	12
95609	2013-03-28	63	63	right	\N	\N	55	35	62	52	36	39	43	40	51	52	73	71	62	65	74	65	81	77	74	38	76	62	46	50	54	60	66	62	13	8	10	14	12
95609	2013-02-15	63	63	right	\N	\N	55	35	62	52	36	39	43	40	51	52	73	71	62	65	74	65	81	77	74	38	76	62	46	50	54	60	66	62	13	8	10	14	12
95609	2012-08-31	63	63	right	\N	\N	55	35	62	52	36	39	43	40	51	52	73	72	62	65	73	65	78	75	74	38	76	62	46	50	54	60	66	62	13	8	10	14	12
95609	2011-08-30	63	63	right	\N	\N	51	35	56	53	36	46	43	49	51	58	70	64	62	63	77	65	72	75	63	49	76	68	46	50	54	58	63	64	13	8	10	14	12
95609	2011-02-22	63	67	right	\N	\N	51	35	56	60	36	46	43	49	56	58	68	66	61	63	71	65	67	73	68	49	76	68	46	60	54	58	63	64	13	8	10	14	12
95609	2010-08-30	63	67	right	\N	\N	51	35	56	60	36	46	43	49	56	58	68	66	61	63	71	65	67	73	68	49	76	68	46	60	54	58	63	64	13	8	10	14	12
95609	2010-02-22	64	67	right	\N	\N	53	35	58	60	36	48	43	49	58	60	68	67	61	63	71	63	67	72	72	49	76	66	64	60	62	60	65	64	21	23	58	23	23
95609	2009-08-30	64	67	right	\N	\N	53	35	58	62	36	48	43	49	60	60	68	67	61	63	71	63	67	72	72	49	75	67	65	60	62	60	65	64	21	23	60	23	23
95609	2008-08-30	58	61	right	\N	\N	53	35	56	54	36	48	43	49	52	49	68	67	61	60	71	63	67	72	65	49	68	63	61	60	59	46	60	64	21	23	52	23	23
95609	2007-08-30	53	69	right	\N	\N	63	35	46	49	36	62	43	49	42	49	68	67	61	45	71	59	67	62	59	49	62	58	53	60	49	46	51	64	21	23	42	23	23
95609	2007-02-22	53	69	right	\N	\N	63	35	46	49	36	62	43	49	42	49	68	67	61	45	71	59	67	62	59	49	62	58	53	60	49	46	51	64	21	23	42	23	23
38366	2016-01-21	73	74	right	medium	medium	67	67	68	76	66	70	64	72	72	73	69	69	66	72	51	79	76	77	83	75	75	70	68	75	74	64	72	70	10	16	11	13	9
38366	2015-12-10	73	74	right	medium	medium	67	67	68	76	66	70	64	72	72	73	69	69	66	72	51	79	76	77	83	75	75	70	68	75	74	64	72	70	10	16	11	13	9
38366	2015-10-02	74	75	right	medium	medium	67	67	68	76	66	72	64	72	72	76	69	69	66	72	51	79	77	84	83	77	75	70	68	75	74	64	72	70	10	16	11	13	9
38366	2015-09-21	74	75	right	medium	medium	67	67	68	76	66	72	64	72	72	76	69	69	66	72	51	79	77	84	83	77	75	70	68	75	74	64	72	70	10	16	11	13	9
38366	2015-03-06	73	75	right	medium	medium	66	66	72	75	71	71	63	71	71	75	71	73	66	71	60	78	77	84	83	76	74	69	71	74	73	63	71	69	9	15	10	12	8
38366	2014-09-18	73	76	right	medium	medium	66	66	72	75	71	71	63	71	71	75	71	73	66	71	60	78	77	84	83	76	74	69	71	74	73	63	71	69	9	15	10	12	8
38366	2014-05-02	74	76	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	74	60	78	75	83	83	76	74	69	71	74	73	63	71	69	9	15	10	12	8
38366	2014-01-10	73	76	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	72	60	78	75	83	83	76	72	66	71	73	73	58	71	69	9	15	10	12	8
38366	2013-09-20	73	76	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	72	60	78	75	83	83	76	72	66	71	73	73	58	71	69	9	15	10	12	8
38366	2013-06-07	73	75	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	72	60	78	74	83	83	76	72	66	71	73	73	58	71	69	9	15	10	12	8
38366	2013-05-31	73	77	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	72	60	78	74	83	83	76	72	66	71	73	73	58	71	69	9	15	10	12	8
38366	2013-05-17	73	77	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	72	60	78	74	83	83	76	72	66	71	73	73	58	71	69	9	15	10	12	8
38366	2013-02-15	73	77	right	medium	medium	66	66	72	75	71	74	63	71	71	78	71	73	66	72	60	78	74	83	83	76	72	66	71	73	73	58	71	69	9	15	10	12	8
38366	2012-08-31	74	80	right	medium	medium	66	66	72	75	71	76	63	71	72	78	73	78	74	74	57	78	72	82	83	76	74	66	72	74	74	58	72	69	9	15	10	12	8
38366	2012-02-22	74	80	right	medium	low	66	63	71	76	68	76	63	68	73	78	73	78	74	74	63	78	73	84	83	76	73	64	69	73	74	58	71	68	9	15	10	12	8
38366	2011-08-30	73	78	right	medium	low	63	63	71	76	68	76	63	68	71	78	73	78	73	71	63	78	73	83	83	76	72	63	68	68	72	58	71	68	9	15	10	12	8
38366	2011-02-22	71	78	right	medium	low	61	58	69	73	63	68	63	68	68	73	68	71	71	66	72	68	69	75	77	66	61	71	63	75	72	64	69	68	9	15	10	12	8
38366	2010-08-30	71	78	right	medium	low	61	58	69	73	63	68	63	68	68	73	68	71	71	66	72	68	69	75	77	66	61	71	63	75	72	64	69	68	9	15	10	12	8
38366	2010-02-22	70	78	right	medium	low	61	56	66	73	63	68	63	68	68	73	68	71	71	66	72	68	69	75	74	63	60	69	68	75	78	63	69	68	13	23	68	23	23
38366	2009-08-30	68	78	right	medium	low	58	56	66	69	63	68	63	51	63	73	68	73	71	66	72	68	69	71	75	63	61	65	64	75	71	63	67	68	3	23	63	23	23
38366	2009-02-22	66	75	right	medium	low	58	56	66	68	63	68	63	51	63	73	68	73	71	65	72	68	69	70	73	63	61	58	53	75	71	63	66	68	1	23	63	23	23
38366	2008-08-30	63	75	right	medium	low	58	51	61	64	63	68	63	48	60	73	68	73	71	65	72	68	69	68	73	62	61	47	44	75	67	61	66	68	1	23	60	23	23
38366	2008-02-22	62	73	right	medium	low	58	46	49	63	63	64	63	48	60	69	64	69	71	60	72	53	69	66	63	56	51	47	44	75	62	67	60	68	1	23	60	23	23
38366	2007-08-30	62	73	right	medium	low	58	46	49	63	63	64	63	48	60	69	64	69	71	60	72	53	69	66	63	56	51	47	44	75	62	67	60	68	1	23	60	23	23
38366	2007-02-22	62	75	right	medium	low	58	46	49	63	63	64	63	62	60	69	64	69	71	60	72	53	69	66	63	56	51	47	44	75	62	67	60	68	1	1	60	1	1
15425	2009-08-30	57	60	right	\N	\N	57	49	54	58	\N	56	\N	60	55	62	60	58	\N	55	\N	57	\N	62	56	51	60	55	58	\N	55	56	60	\N	1	21	55	21	21
15425	2008-08-30	53	60	right	\N	\N	45	35	33	54	\N	47	\N	39	46	54	53	58	\N	55	\N	35	\N	62	51	43	53	55	58	\N	50	56	60	\N	1	21	46	21	21
15425	2007-02-22	53	60	right	\N	\N	45	35	33	54	\N	47	\N	39	46	54	53	58	\N	55	\N	35	\N	62	51	43	53	55	58	\N	50	56	60	\N	1	21	46	21	21
164694	2015-09-21	70	70	right	high	high	53	39	64	58	49	60	42	70	63	63	55	55	55	65	48	86	77	73	86	59	85	66	57	47	64	68	72	65	6	10	13	14	9
164694	2015-08-14	68	68	right	high	high	52	38	63	57	48	59	41	69	62	62	55	55	56	64	48	85	59	73	85	58	84	65	56	46	63	65	69	62	5	9	12	13	8
164694	2015-07-03	68	68	right	high	high	52	38	63	57	48	59	41	69	62	62	57	58	57	64	48	85	59	73	85	58	84	65	56	46	63	65	69	62	5	9	12	13	8
164694	2015-06-12	68	68	right	high	high	52	38	63	57	48	59	41	69	62	62	57	58	57	64	48	85	59	73	85	58	84	65	56	46	63	65	69	62	5	9	12	13	8
164694	2015-05-08	68	68	right	high	high	52	38	63	57	48	59	41	69	62	62	57	58	57	64	48	85	59	73	85	58	84	65	56	46	63	65	69	62	5	9	12	13	8
164694	2015-01-09	69	69	right	high	high	52	38	63	57	48	59	41	69	65	62	57	58	57	71	48	85	59	73	85	58	84	66	56	46	63	74	66	64	5	9	12	13	8
164694	2014-11-14	69	69	right	high	high	52	38	63	57	48	39	41	69	65	62	57	58	57	71	48	85	59	73	85	58	84	66	56	46	63	74	66	64	5	9	12	13	8
164694	2014-09-18	69	69	right	high	high	52	38	63	57	48	39	41	69	65	62	57	58	57	71	48	85	59	73	85	58	84	66	56	46	63	74	66	64	5	9	12	13	8
164694	2014-04-18	70	70	right	high	high	52	38	63	57	48	39	41	69	65	62	58	57	57	71	48	85	77	73	86	58	84	66	56	46	63	74	66	64	5	9	12	13	8
164694	2014-01-24	70	70	right	high	high	52	38	63	57	48	39	41	69	56	62	58	57	57	71	48	85	77	73	86	58	84	66	56	46	63	74	66	64	5	9	12	13	8
164694	2014-01-03	72	72	right	high	high	52	38	68	63	48	39	41	69	67	62	58	57	57	71	48	85	77	73	86	72	84	73	56	46	63	74	72	64	5	9	12	13	8
164694	2013-12-27	72	72	right	high	high	52	38	68	63	48	39	41	69	67	62	58	57	57	71	48	85	77	73	86	72	84	73	56	46	63	74	72	64	5	9	12	13	8
164694	2013-12-06	72	72	right	high	high	52	38	68	63	48	39	41	69	67	62	58	57	57	71	48	85	77	73	86	72	84	73	56	46	63	75	72	64	5	9	12	13	8
164694	2013-09-20	72	72	right	high	high	52	38	68	64	48	39	41	69	60	60	49	53	57	71	48	85	77	73	86	72	84	73	56	46	63	75	72	64	5	9	12	13	8
164694	2013-08-23	72	72	right	high	high	52	38	68	64	48	39	41	69	60	53	49	53	57	71	48	85	77	73	86	58	84	73	56	46	63	75	72	64	5	9	12	13	8
164694	2013-08-02	72	72	right	high	high	52	38	68	64	48	39	41	69	60	53	49	55	57	71	48	85	77	73	84	58	84	75	56	46	63	75	72	64	5	9	12	13	8
164694	2013-07-12	72	72	right	high	high	52	38	68	64	48	39	41	69	60	53	49	55	57	71	48	85	77	73	84	58	84	77	56	46	60	75	71	64	5	9	12	13	8
164694	2013-07-05	72	72	right	high	high	52	38	68	65	48	39	41	69	58	53	49	55	57	71	48	85	77	73	84	58	84	77	56	46	60	75	71	64	5	9	12	13	8
164694	2013-05-24	72	72	right	low	high	52	28	68	65	41	29	41	69	58	53	49	55	57	71	48	85	77	73	83	58	79	77	39	46	60	75	71	64	5	9	12	13	8
164694	2013-02-15	72	73	right	low	high	52	28	68	65	41	29	41	69	58	53	49	55	57	71	48	85	77	73	83	58	79	77	39	46	60	75	71	64	5	9	12	13	8
164694	2012-08-31	66	66	right	low	high	52	28	68	62	41	23	41	68	58	60	49	53	57	65	48	83	68	52	80	58	70	69	39	46	60	72	59	55	5	9	12	13	8
164694	2012-02-22	66	67	right	low	high	47	28	68	62	41	23	41	68	58	48	49	53	57	56	48	83	68	52	80	61	70	66	39	46	60	64	67	62	5	9	12	13	8
164694	2011-02-22	66	67	right	low	high	47	28	68	62	41	23	41	68	58	48	49	53	57	56	48	83	68	52	80	61	70	66	39	46	60	64	67	62	5	9	12	13	8
164694	2010-08-30	66	67	right	low	high	47	28	68	62	41	23	41	68	58	48	49	53	57	56	48	83	68	52	80	61	70	66	39	46	60	64	67	62	5	9	12	13	8
164694	2009-08-30	67	73	right	low	high	27	28	68	49	41	22	41	69	40	39	64	62	57	65	48	83	68	66	80	61	70	54	59	46	54	64	65	62	11	23	40	23	23
164694	2009-02-22	67	73	right	low	high	27	28	68	49	41	22	41	69	40	39	64	62	57	65	48	83	68	66	80	61	70	54	59	46	54	64	65	62	11	23	40	23	23
164694	2007-02-22	67	73	right	low	high	27	28	68	49	41	22	41	69	40	39	64	62	57	65	48	83	68	66	80	61	70	54	59	46	54	64	65	62	11	23	40	23	23
159888	2015-09-21	70	71	right	medium	medium	25	15	75	56	12	33	27	30	55	51	50	63	52	65	39	58	66	66	79	36	76	68	43	45	50	73	72	70	15	7	13	15	15
159888	2015-01-16	70	71	right	medium	medium	25	15	75	56	12	33	27	30	55	51	50	63	52	65	39	58	66	66	79	36	76	68	43	45	50	73	72	70	15	7	13	15	15
159888	2014-12-05	70	71	right	medium	medium	25	15	75	56	12	33	27	30	55	51	50	63	52	65	39	58	66	66	79	36	76	68	43	45	50	73	72	70	15	7	13	15	15
159888	2014-09-18	65	71	right	medium	medium	25	15	75	57	12	33	27	30	55	51	50	63	52	65	39	58	66	66	79	36	76	68	43	45	50	64	72	61	15	7	13	15	15
159888	2013-12-20	70	71	right	medium	medium	25	15	75	58	12	33	27	30	50	51	66	69	53	62	40	58	71	76	76	36	76	65	23	45	40	74	75	68	15	7	13	15	15
159888	2013-11-08	70	71	right	medium	medium	25	15	75	58	12	33	27	30	50	51	66	69	53	62	40	58	71	76	76	36	76	65	23	45	40	74	75	68	15	7	13	15	15
159888	2013-09-20	67	71	right	medium	medium	25	15	75	58	12	33	27	30	50	51	66	69	53	62	40	58	71	76	76	36	69	65	23	45	40	66	70	65	15	7	13	15	15
159888	2011-08-30	67	71	right	medium	medium	25	15	75	58	12	33	27	30	50	51	66	69	53	62	40	58	71	76	76	36	69	65	23	45	40	66	70	65	15	7	13	15	15
159888	2010-08-30	67	71	right	medium	medium	25	15	75	58	12	33	27	30	50	51	66	69	53	62	40	58	71	76	76	36	69	65	23	45	40	66	70	65	15	7	13	15	15
159888	2009-08-30	67	75	right	medium	medium	25	22	75	58	12	45	27	30	57	52	66	69	53	62	40	58	71	76	76	36	69	68	77	45	59	75	66	65	4	22	57	22	22
159888	2009-02-22	64	76	right	medium	medium	25	22	59	34	12	22	27	30	22	43	74	69	53	77	40	58	71	80	75	22	70	45	57	45	29	64	65	65	4	22	22	22	22
159888	2008-08-30	64	76	right	medium	medium	25	22	59	34	12	22	27	30	22	43	74	69	53	77	40	58	71	80	75	22	70	45	57	45	29	64	65	65	4	22	22	22	22
159888	2007-02-22	64	76	right	medium	medium	25	22	59	34	12	22	27	30	22	43	74	69	53	77	40	58	71	80	75	22	70	45	57	45	29	64	65	65	4	22	22	22	22
166676	2015-09-21	77	81	right	medium	high	63	62	73	72	62	72	62	57	68	72	62	69	72	79	66	79	81	84	92	64	90	79	64	64	65	74	83	79	6	14	10	13	16
166676	2015-03-06	76	80	right	medium	high	62	61	75	73	61	71	61	56	69	71	64	72	72	78	66	84	81	84	91	70	89	77	63	65	64	73	82	77	5	13	9	12	15
166676	2015-01-16	76	80	right	medium	high	62	61	76	73	61	71	61	56	69	71	64	72	72	78	66	84	81	84	91	70	89	76	63	65	64	73	82	77	5	13	9	12	15
166676	2015-01-09	76	80	right	medium	high	62	61	76	73	61	71	61	56	70	71	64	72	72	78	66	84	81	84	91	70	89	76	63	68	64	73	82	77	5	13	9	12	15
166676	2014-11-14	76	78	right	medium	high	62	61	76	72	61	71	61	56	68	71	63	72	72	78	66	84	81	84	91	70	89	76	63	64	64	73	80	76	5	13	9	12	15
166676	2014-10-31	75	78	right	medium	high	66	61	80	72	61	73	69	56	68	67	63	72	72	78	66	84	81	84	90	70	89	76	63	64	64	73	78	74	5	13	9	12	15
166676	2014-10-24	76	79	right	medium	high	66	61	80	74	61	73	69	56	70	69	63	72	72	78	66	84	81	84	90	70	89	76	63	64	64	73	78	74	5	13	9	12	15
166676	2014-09-18	75	79	right	medium	high	66	61	80	74	61	73	69	56	70	69	63	72	72	78	66	84	81	84	90	70	89	76	63	64	64	73	76	74	5	13	9	12	15
166676	2013-11-29	76	81	right	medium	high	66	61	83	74	61	73	69	56	70	75	72	75	72	78	69	84	81	84	90	70	88	74	63	64	64	73	76	71	5	13	9	12	15
166676	2013-11-01	76	81	right	medium	high	66	61	83	76	61	73	69	56	70	75	72	75	72	78	69	84	81	84	90	70	88	74	63	64	64	73	76	71	5	13	9	12	15
166676	2013-10-25	76	81	right	medium	high	66	61	83	76	61	73	69	56	70	75	72	75	72	78	69	84	81	84	89	73	83	74	63	64	64	73	76	68	5	13	9	12	15
166676	2013-10-11	76	81	right	medium	high	66	61	83	78	61	75	69	56	72	77	73	76	72	78	69	84	81	84	89	73	83	74	63	72	64	73	72	63	5	13	9	12	15
166676	2013-10-04	74	81	right	medium	high	66	61	83	78	61	75	69	56	72	77	73	76	72	78	69	84	81	84	89	73	83	74	63	72	64	73	72	63	5	13	9	12	15
166676	2013-09-20	74	81	right	high	high	66	61	83	78	61	75	69	56	72	77	73	76	72	78	69	84	81	84	89	73	83	74	63	72	64	73	72	63	5	13	9	12	15
166676	2013-05-31	76	81	right	medium	medium	66	59	83	82	61	75	69	56	77	77	73	75	72	78	69	84	81	85	88	73	83	74	63	72	64	73	72	63	5	13	9	12	15
166676	2013-03-28	76	81	right	high	medium	66	59	83	82	61	75	69	56	77	77	73	75	72	78	69	84	81	85	88	73	83	74	63	72	64	73	72	63	5	13	9	12	15
166676	2013-02-15	75	81	right	high	medium	66	59	82	81	61	74	69	56	76	76	72	75	70	77	69	83	80	83	88	73	83	74	58	72	64	73	72	63	5	13	9	12	15
166676	2012-08-31	72	81	right	high	medium	66	58	78	76	61	72	69	56	71	70	70	67	67	74	69	79	77	81	86	69	79	72	58	72	64	72	70	63	5	13	9	12	15
166676	2012-02-22	70	80	left	high	medium	58	58	75	76	61	72	64	56	71	73	70	68	71	73	66	79	74	75	81	67	79	72	52	68	64	69	71	65	5	13	9	12	15
166676	2011-08-30	66	78	left	medium	medium	51	31	65	66	36	63	31	36	61	64	71	73	61	64	60	68	61	81	83	52	88	54	37	57	42	62	62	62	5	13	9	12	15
166676	2011-02-22	62	69	left	medium	medium	53	44	64	58	46	68	41	36	57	64	68	73	69	68	73	68	67	74	78	58	78	46	43	57	52	54	62	61	5	13	9	12	15
166676	2010-08-30	63	76	right	medium	medium	55	58	64	62	51	68	41	36	59	64	68	71	70	63	76	66	67	65	74	62	66	52	44	65	57	62	66	65	5	13	9	12	15
166676	2010-02-22	63	76	right	medium	medium	55	58	61	62	51	64	41	36	57	64	68	71	70	63	76	66	67	65	74	62	66	54	56	65	61	58	66	65	2	22	57	22	22
166676	2009-08-30	63	76	right	medium	medium	55	58	61	62	51	64	41	36	57	64	68	71	70	63	76	66	67	65	74	62	66	54	56	65	56	58	64	65	2	22	57	22	22
166676	2008-08-30	52	71	right	medium	medium	30	61	33	52	51	48	41	36	43	63	56	59	70	43	76	58	67	38	65	32	29	30	32	65	31	22	22	65	2	22	43	22	22
166676	2007-02-22	52	71	right	medium	medium	30	61	33	52	51	48	41	36	43	63	56	59	70	43	76	58	67	38	65	32	29	30	32	65	31	22	22	65	2	22	43	22	22
3329	2012-02-22	64	65	right	medium	medium	42	25	65	63	34	34	32	48	58	55	47	54	49	61	56	56	62	70	69	40	60	70	28	52	52	63	64	62	6	12	13	10	13
3329	2011-08-30	64	64	right	medium	medium	48	35	63	65	44	44	34	48	58	56	57	54	59	61	65	56	62	72	69	50	60	70	38	52	52	64	65	63	6	12	13	10	13
3329	2010-08-30	64	65	right	medium	medium	48	35	63	65	44	44	34	48	58	56	58	63	59	61	64	56	61	71	68	50	60	70	38	71	52	64	65	63	6	12	13	10	13
3329	2009-08-30	62	63	right	medium	medium	47	34	57	63	44	43	34	47	55	53	57	62	59	60	64	55	61	65	67	49	68	64	63	71	58	63	62	63	15	20	55	20	20
3329	2007-02-22	62	63	right	medium	medium	47	34	57	63	44	43	34	47	55	53	57	62	59	60	64	55	61	65	67	49	68	64	63	71	58	63	62	63	15	20	55	20	20
33671	2010-02-22	61	65	right	\N	\N	46	36	57	56	\N	48	\N	32	51	53	67	70	\N	66	\N	67	\N	77	63	37	69	63	62	\N	58	59	65	\N	10	21	51	21	21
33671	2009-08-30	60	65	right	\N	\N	46	36	57	56	\N	48	\N	32	51	53	65	70	\N	63	\N	67	\N	77	63	37	67	59	57	\N	56	57	63	\N	10	21	51	21	21
33671	2008-08-30	57	62	right	\N	\N	46	36	56	56	\N	48	\N	32	48	58	65	70	\N	63	\N	67	\N	77	65	37	65	52	47	\N	51	48	56	\N	10	21	48	21	21
33671	2007-02-22	57	62	right	\N	\N	46	36	56	56	\N	48	\N	32	48	58	65	70	\N	63	\N	67	\N	77	65	37	65	52	47	\N	51	48	56	\N	10	21	48	21	21
94281	2008-08-30	55	72	left	\N	\N	58	65	37	59	\N	63	\N	62	51	65	67	68	\N	68	\N	52	\N	59	41	42	62	52	44	\N	61	28	32	\N	2	21	51	21	21
94281	2007-08-30	50	75	right	\N	\N	44	26	37	54	\N	29	\N	65	51	65	65	69	\N	68	\N	39	\N	54	41	36	54	52	44	\N	42	28	32	\N	2	21	51	21	21
94281	2007-02-22	50	75	right	\N	\N	44	26	37	54	\N	29	\N	65	51	65	65	69	\N	68	\N	39	\N	54	41	36	54	52	44	\N	42	28	32	\N	2	21	51	21	21
104386	2014-03-14	64	64	left	medium	medium	62	58	47	64	61	64	66	66	62	63	73	71	76	64	72	65	70	66	58	65	60	65	61	63	56	62	62	63	14	6	9	12	6
104386	2014-02-14	65	65	left	medium	medium	62	58	47	67	61	64	66	67	66	63	74	72	76	66	72	65	71	68	61	65	62	67	61	63	56	64	65	66	14	6	9	12	6
104386	2013-12-20	66	66	left	medium	medium	64	58	47	68	61	66	66	67	66	65	74	72	76	66	72	65	71	68	61	65	62	67	61	63	56	64	65	66	14	6	9	12	6
104386	2013-09-20	67	67	left	medium	medium	64	58	47	68	61	67	66	68	66	66	76	73	78	66	72	65	77	68	61	66	62	67	61	63	56	65	68	67	14	6	9	12	6
104386	2013-05-31	66	66	left	medium	medium	64	58	47	65	61	67	66	68	63	66	76	73	78	66	72	65	76	68	61	66	62	67	61	63	56	65	65	64	14	6	9	12	6
104386	2013-02-15	66	66	left	medium	medium	64	58	47	65	61	67	66	68	63	66	76	73	78	66	72	65	76	68	61	66	62	67	61	63	56	65	65	64	14	6	9	12	6
104386	2012-08-31	64	64	left	high	medium	64	62	43	65	61	68	66	68	63	66	80	78	81	66	76	65	78	68	58	66	57	67	61	63	56	62	65	64	14	6	9	12	6
104386	2012-02-22	65	66	left	medium	medium	63	53	42	64	58	69	66	68	60	67	78	81	82	64	76	64	73	66	60	66	53	58	52	54	54	57	59	58	14	6	9	12	6
104386	2011-08-30	64	66	left	medium	medium	63	53	42	60	56	71	63	66	58	67	76	83	82	66	71	60	73	61	65	64	51	53	46	47	54	56	57	55	14	6	9	12	6
104386	2011-02-22	64	67	left	medium	medium	63	53	42	60	56	72	63	66	58	67	73	78	75	66	52	60	67	62	55	64	51	53	46	47	54	56	57	55	14	6	9	12	6
104386	2010-08-30	66	67	left	medium	medium	65	46	42	62	56	72	63	66	59	67	73	78	75	69	52	57	67	62	55	61	56	57	58	55	54	60	59	62	14	6	9	12	6
104386	2009-08-30	66	67	left	medium	medium	65	46	42	62	56	72	63	66	59	67	73	78	75	69	52	57	67	62	55	61	56	52	54	55	53	60	59	62	12	21	59	21	21
104386	2009-02-22	62	70	left	medium	medium	61	53	42	62	56	62	63	54	59	60	71	71	75	79	52	55	67	59	64	54	62	45	54	55	41	51	52	62	2	21	59	21	21
104386	2008-08-30	63	70	left	medium	medium	69	53	42	65	56	52	63	64	64	62	71	71	75	79	52	50	67	59	64	54	62	45	54	55	41	29	37	62	2	21	64	21	21
104386	2007-08-30	63	70	left	medium	medium	69	53	42	65	56	52	63	64	64	62	71	71	75	79	52	50	67	59	64	54	62	45	54	55	41	29	37	62	2	21	64	21	21
104386	2007-02-22	63	70	left	medium	medium	69	53	42	65	56	52	63	64	64	62	71	71	75	79	52	50	67	59	64	54	62	45	54	55	41	29	37	62	2	21	64	21	21
27423	2013-05-31	65	65	right	medium	low	54	65	64	62	62	64	66	65	56	66	60	54	64	62	73	63	63	61	59	61	45	32	80	65	69	14	23	12	10	15	13	10	8
27423	2013-05-17	65	65	right	medium	low	54	65	64	62	62	64	66	65	56	66	60	54	64	62	73	63	63	61	59	61	45	32	80	65	69	14	23	12	10	15	13	10	8
27423	2013-03-28	65	65	right	medium	low	54	65	64	62	62	64	66	65	56	66	60	54	64	62	73	63	63	61	59	61	45	32	80	65	69	14	23	12	10	15	13	10	8
27423	2013-03-22	65	65	right	medium	low	54	65	64	62	62	64	66	65	56	66	60	54	64	62	73	63	63	61	59	61	45	32	80	65	69	14	23	12	10	15	13	10	8
27423	2013-02-15	66	66	right	medium	low	54	66	65	63	63	65	68	67	57	67	62	55	65	65	74	63	64	62	59	62	45	32	80	65	70	14	23	12	10	15	13	10	8
27423	2012-02-22	66	66	right	medium	low	54	66	65	63	63	65	68	67	57	67	62	55	65	65	74	63	64	62	59	62	45	32	80	65	70	14	23	12	10	15	13	10	8
27423	2011-08-30	70	70	right	medium	low	57	72	65	67	67	65	68	67	56	68	72	66	75	73	75	68	80	63	69	62	45	32	80	70	71	14	23	12	10	15	13	10	8
27423	2011-02-22	70	76	right	medium	low	57	76	65	67	69	65	71	73	56	70	69	67	70	73	65	71	72	63	62	70	45	32	80	70	74	13	23	11	10	15	13	10	8
27423	2010-08-30	71	76	right	medium	low	57	76	74	67	69	65	73	73	56	71	69	67	71	74	65	72	73	64	62	70	58	32	80	72	74	13	23	11	10	15	13	10	8
27423	2009-08-30	72	76	right	medium	low	57	76	74	67	69	65	73	73	56	70	70	72	71	75	65	75	73	67	65	70	58	69	76	72	77	21	23	11	8	21	56	21	21
27423	2009-02-22	73	76	right	medium	low	57	80	74	67	69	65	73	76	56	67	70	72	71	75	65	75	73	67	65	73	58	69	76	72	77	21	23	11	10	21	56	21	21
27423	2008-08-30	73	74	right	medium	low	56	74	77	67	69	70	73	76	56	71	74	76	71	74	65	75	73	71	67	70	68	69	72	72	71	21	23	11	10	21	56	21	21
27423	2007-08-30	76	76	right	medium	low	56	82	78	62	69	71	73	76	31	73	78	76	71	78	65	73	73	71	61	72	68	69	68	72	71	21	23	11	10	21	31	21	21
27423	2007-02-22	79	81	left	medium	low	56	83	82	66	69	73	73	71	41	74	75	79	71	78	65	82	73	67	84	72	68	69	68	72	71	13	23	11	10	8	41	8	5
35412	2011-02-22	71	74	right	\N	\N	69	64	56	68	66	69	59	68	64	66	84	86	73	63	68	74	74	76	63	69	56	43	63	62	56	22	36	38	14	10	5	9	9
35412	2010-08-30	72	74	right	\N	\N	69	64	56	68	66	69	59	68	64	66	86	88	73	68	73	74	78	83	69	69	64	48	63	62	56	42	46	48	14	10	5	9	9
35412	2010-02-22	73	76	right	\N	\N	72	64	56	68	66	69	59	68	67	66	86	88	73	68	73	74	78	83	69	69	64	61	62	62	66	44	56	48	8	20	67	20	20
35412	2009-08-30	74	76	right	\N	\N	78	64	58	70	66	70	59	70	66	68	86	86	73	65	73	75	78	82	69	70	61	67	62	62	66	44	64	48	8	20	66	20	20
35412	2009-02-22	71	74	right	\N	\N	70	64	58	68	66	69	59	65	64	66	89	88	73	67	73	71	78	80	69	65	61	67	62	62	63	44	64	48	8	20	64	20	20
35412	2008-08-30	69	69	right	\N	\N	70	64	63	65	66	68	59	65	64	64	81	83	73	65	73	63	78	74	69	65	58	67	61	62	53	44	64	48	8	20	64	20	20
35412	2007-08-30	70	69	right	\N	\N	69	64	67	65	66	71	59	65	70	66	73	73	73	65	73	63	78	75	69	66	58	67	61	62	53	44	60	48	8	20	70	20	20
35412	2007-02-22	68	67	right	\N	\N	67	62	65	63	66	69	59	51	68	64	71	71	73	63	73	61	78	73	67	64	56	67	61	62	51	42	58	48	8	7	68	6	8
38784	2013-02-15	65	65	right	medium	medium	53	44	67	63	56	53	39	49	57	60	37	49	47	64	56	67	57	75	75	57	69	71	48	63	54	61	64	63	14	15	13	14	6
38784	2012-08-31	66	66	right	medium	medium	53	44	67	64	56	48	39	49	57	60	37	51	47	64	52	67	60	74	75	49	71	72	41	65	54	63	67	65	14	15	13	14	6
38784	2012-02-22	65	65	right	medium	medium	53	44	67	64	56	48	39	49	57	60	37	51	56	63	60	67	70	70	72	49	71	72	41	65	54	63	67	65	14	15	13	14	6
38784	2011-08-30	64	65	right	medium	medium	53	44	67	56	56	48	39	49	57	55	48	39	56	63	60	67	70	70	72	49	71	72	41	65	54	63	67	65	14	15	13	14	6
38784	2010-08-30	65	67	right	medium	medium	53	44	67	56	56	48	39	49	57	55	62	65	64	63	66	67	65	77	72	49	74	73	41	65	54	67	68	66	14	15	13	14	6
38784	2010-02-22	66	67	right	medium	medium	53	44	67	64	56	48	39	49	57	60	53	62	64	65	66	67	65	77	75	49	74	69	67	65	70	62	67	66	8	21	57	21	21
38784	2009-08-30	64	69	right	medium	medium	50	44	63	64	56	48	39	49	56	60	62	67	64	63	66	59	65	65	70	49	70	65	67	65	67	62	66	66	8	21	56	21	21
38784	2009-02-22	66	69	right	medium	medium	50	54	68	56	56	48	39	49	50	55	62	67	64	63	66	59	65	82	72	49	75	65	68	65	67	70	72	66	8	21	50	21	21
38784	2008-08-30	66	69	right	medium	medium	50	54	68	56	56	48	39	49	50	55	62	67	64	63	66	59	65	82	72	49	75	65	68	65	67	70	72	66	8	21	50	21	21
38784	2007-08-30	64	69	right	medium	medium	50	54	68	56	56	48	39	49	50	55	62	67	64	63	66	59	65	82	72	49	75	65	68	65	67	70	72	66	8	21	50	21	21
38784	2007-02-22	62	67	right	medium	medium	50	54	68	56	56	48	39	67	50	55	62	67	64	63	66	59	65	77	68	49	75	65	68	65	67	72	68	66	8	5	50	14	8
38354	2012-02-22	65	65	right	medium	medium	54	56	65	68	58	53	60	68	66	63	53	58	56	63	56	68	57	76	71	66	66	74	58	68	65	56	63	61	12	14	11	5	14
38354	2011-08-30	66	66	right	medium	medium	54	56	65	68	58	53	58	68	66	63	61	61	65	65	61	69	64	79	75	67	63	74	62	71	65	57	61	60	12	14	11	5	14
38354	2011-02-22	66	67	right	medium	medium	54	56	65	68	58	53	58	68	66	63	61	66	63	65	67	69	62	76	71	67	63	74	62	71	65	57	61	60	12	14	11	5	14
38354	2010-08-30	66	68	right	medium	medium	54	56	65	68	58	53	58	68	66	63	61	66	63	65	67	69	62	76	71	67	63	74	62	71	65	57	61	60	12	14	11	5	14
38354	2009-08-30	63	64	right	medium	medium	56	48	61	66	58	51	58	64	61	60	59	63	63	64	67	65	62	71	66	63	61	70	67	71	66	53	58	60	11	20	61	20	20
38354	2009-02-22	63	63	right	medium	medium	49	40	65	69	58	64	58	44	61	55	59	69	63	64	67	60	62	72	65	61	67	61	59	71	64	61	65	60	11	20	61	20	20
38354	2008-08-30	63	63	right	medium	medium	49	40	65	69	58	64	58	44	61	55	59	69	63	64	67	60	62	72	65	61	67	61	59	71	64	61	65	60	11	20	61	20	20
38354	2007-08-30	65	66	right	medium	medium	49	40	65	69	58	64	58	44	61	55	59	69	63	64	67	60	62	72	65	61	67	61	59	71	64	61	65	60	11	20	61	20	20
38354	2007-02-22	64	66	right	medium	medium	48	39	64	68	58	63	58	63	60	54	58	68	63	63	67	59	62	71	64	60	66	61	59	71	63	60	64	60	11	9	60	6	10
38327	2015-09-21	68	68	right	medium	medium	13	12	11	12	11	11	17	13	12	34	31	32	46	67	30	12	57	28	76	16	29	19	12	43	13	13	13	13	69	66	65	66	73
38327	2014-07-25	67	67	right	medium	medium	25	25	25	25	25	25	25	25	25	33	31	23	28	62	30	25	36	28	71	25	28	25	25	25	25	25	25	25	68	65	62	64	73
38327	2014-02-28	67	67	right	medium	medium	25	25	25	25	25	25	25	25	25	33	31	23	28	62	30	25	36	28	71	25	28	25	25	25	25	25	25	25	68	65	62	64	73
38327	2013-09-20	66	66	right	medium	medium	25	25	25	25	25	25	25	25	25	33	31	23	28	62	30	25	36	28	71	25	28	25	25	25	25	25	25	25	68	63	60	63	72
38327	2012-08-31	64	65	right	medium	medium	12	11	10	11	10	10	16	12	11	35	45	41	41	62	50	11	56	30	73	15	57	23	11	31	12	12	12	12	67	61	55	61	71
38327	2012-02-22	64	65	right	medium	medium	12	11	10	11	10	10	16	12	11	32	45	41	41	62	41	11	56	40	73	15	57	23	11	31	12	12	12	12	67	61	55	61	71
38327	2011-08-30	64	65	right	medium	medium	12	11	10	11	10	10	16	12	11	35	45	41	41	62	41	11	56	40	73	15	57	23	11	31	12	12	12	12	67	61	55	61	71
38327	2011-02-22	64	67	right	medium	medium	12	11	10	11	10	10	16	12	11	35	45	41	41	62	72	11	56	40	73	15	57	23	11	31	12	12	12	12	67	61	55	61	71
38327	2010-08-30	64	67	right	medium	medium	12	11	10	11	10	10	16	12	11	35	45	41	41	62	72	11	56	40	73	15	57	23	11	50	12	12	12	35	67	61	55	61	71
38327	2010-02-22	62	67	right	medium	medium	25	25	25	25	10	25	16	12	53	35	45	41	41	62	72	25	56	40	73	25	57	40	33	50	48	25	25	35	65	59	53	59	69
38327	2009-08-30	61	67	right	medium	medium	25	25	25	25	10	25	16	12	52	35	45	41	41	62	72	25	56	40	73	25	57	40	33	50	48	25	25	35	63	57	52	59	68
38327	2008-08-30	58	67	right	medium	medium	25	25	25	25	10	25	16	12	46	35	45	41	41	57	72	25	56	40	73	25	57	40	33	50	48	25	25	35	63	51	46	53	68
38327	2007-08-30	58	67	right	medium	medium	25	25	25	25	10	25	16	12	46	35	45	41	41	57	72	25	56	40	73	25	57	40	33	50	48	25	25	35	63	48	46	45	66
38327	2007-02-22	58	67	right	medium	medium	12	11	10	11	10	10	16	48	46	35	45	41	41	57	72	11	56	40	73	15	57	40	33	50	48	12	12	35	63	48	46	45	66
38339	2015-07-03	64	64	left	medium	medium	58	28	65	59	31	56	39	59	56	59	55	57	59	62	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2015-05-08	64	64	left	medium	medium	58	28	65	59	31	56	39	59	56	59	55	57	59	62	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2015-01-09	64	65	left	medium	medium	58	28	65	59	31	56	39	59	56	59	55	57	59	62	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2014-10-10	63	65	left	medium	medium	58	28	65	59	31	56	39	59	56	59	55	57	59	62	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2014-09-18	63	65	left	medium	medium	58	28	65	59	31	56	39	59	56	59	55	57	59	64	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2014-02-14	63	65	left	medium	medium	58	28	65	59	31	56	39	59	56	59	55	57	59	64	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2013-11-29	64	65	left	medium	medium	47	28	65	59	31	56	39	59	56	59	55	57	59	64	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2013-09-20	64	65	left	medium	medium	47	28	65	59	31	56	39	59	56	59	55	57	59	64	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2012-08-31	64	65	left	medium	medium	47	28	65	59	31	56	39	59	56	59	55	57	59	64	58	48	43	65	72	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2012-02-22	64	70	left	medium	medium	47	28	65	59	31	56	39	59	56	59	55	57	59	64	64	48	43	65	69	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2011-08-30	64	70	left	medium	medium	47	28	65	59	31	56	39	59	56	59	55	57	59	64	64	48	55	65	69	38	74	65	45	47	39	65	62	65	11	6	13	5	13
38339	2010-08-30	64	67	left	medium	medium	47	28	65	59	31	56	39	59	56	59	63	65	59	61	61	48	58	65	66	38	74	64	45	67	39	66	58	59	11	6	13	5	13
38339	2009-08-30	62	69	right	medium	medium	50	27	65	55	31	58	39	59	44	58	62	65	59	59	61	44	58	48	59	38	74	57	62	67	55	64	56	59	6	23	44	23	23
38339	2008-08-30	59	69	right	medium	medium	50	27	65	55	31	58	39	59	44	58	62	65	59	59	61	44	58	48	59	38	74	55	52	67	45	59	48	59	10	23	44	23	23
38339	2007-08-30	57	69	right	medium	medium	50	27	65	55	31	58	39	59	44	58	62	65	59	59	61	44	58	48	59	38	74	55	52	67	45	59	48	59	10	23	44	23	23
38339	2007-02-22	62	69	right	medium	medium	55	32	70	60	31	63	39	50	49	63	67	70	59	64	61	49	58	53	64	43	79	55	52	67	50	64	53	59	10	10	49	10	10
38801	2010-08-30	65	67	right	\N	\N	61	64	72	71	46	47	44	52	62	60	54	62	55	64	72	67	65	75	73	57	84	74	72	74	65	60	64	62	12	7	8	10	11
38801	2010-02-22	65	66	right	\N	\N	61	64	70	71	46	55	44	52	58	61	57	61	55	62	72	66	65	75	68	55	74	72	74	74	71	59	64	62	9	20	58	20	20
38801	2009-08-30	65	66	right	\N	\N	61	64	70	71	46	55	44	52	58	61	57	61	55	62	72	66	65	75	68	55	74	72	74	74	71	59	64	62	9	20	58	20	20
38801	2009-02-22	65	66	right	\N	\N	61	64	70	71	46	55	44	52	58	61	57	61	55	62	72	66	65	75	68	55	74	72	74	74	71	59	64	62	11	20	58	20	20
38801	2008-08-30	65	66	right	\N	\N	61	64	70	71	46	55	44	52	58	61	57	61	55	62	72	66	65	75	68	55	74	72	74	74	71	59	64	62	11	20	58	20	20
38801	2007-08-30	68	67	right	\N	\N	61	64	73	71	46	56	44	52	61	61	57	64	55	66	72	66	65	82	74	55	76	66	74	74	71	59	71	62	11	20	61	20	20
38801	2007-02-22	64	67	right	\N	\N	55	45	71	64	46	52	44	61	56	53	57	61	55	65	72	68	65	78	67	51	75	66	74	74	61	63	66	62	11	16	56	15	10
67941	2016-03-24	67	67	right	high	high	68	21	62	67	46	66	72	67	63	67	68	69	74	63	76	57	68	65	59	48	66	67	48	58	49	69	68	67	14	15	14	6	10
67941	2016-02-11	67	67	right	high	high	68	21	62	67	46	66	72	67	63	67	71	72	74	63	76	57	68	65	59	48	66	67	48	58	49	69	68	67	14	15	14	6	10
67941	2016-02-04	68	68	right	high	high	68	21	62	67	46	66	72	67	63	67	71	72	74	66	76	57	68	70	62	48	66	67	48	58	49	69	68	67	14	15	14	6	10
67941	2016-01-07	70	70	right	high	high	68	21	62	67	46	66	72	67	63	67	78	77	80	69	78	57	76	75	62	48	71	67	48	58	49	74	69	68	14	15	14	6	10
67941	2012-08-31	70	70	right	high	high	68	21	62	67	46	66	72	67	63	67	78	77	80	69	78	57	76	75	62	48	71	67	48	58	49	74	69	68	14	15	14	6	10
67941	2012-02-22	68	71	right	medium	medium	68	21	62	67	46	61	72	67	63	63	78	74	79	73	78	57	72	70	56	48	66	67	48	58	49	74	69	68	14	15	14	6	10
67941	2011-08-30	68	71	right	medium	medium	68	21	62	67	46	61	72	67	63	63	78	74	79	73	78	57	72	70	55	48	66	67	48	58	49	74	69	68	14	15	14	6	10
67941	2011-02-22	65	68	right	medium	medium	65	38	61	66	46	56	72	67	62	62	68	71	73	66	60	57	65	67	56	51	61	65	51	67	49	68	65	64	14	15	14	6	10
67941	2010-08-30	65	68	right	medium	medium	65	38	61	66	46	56	72	67	62	62	68	71	70	66	60	57	65	67	56	51	61	65	51	67	49	68	65	64	14	15	14	6	10
67941	2009-08-30	63	66	right	medium	medium	64	38	57	66	46	56	72	67	61	61	68	71	70	66	60	57	65	67	56	51	61	68	64	67	69	62	64	64	8	20	61	20	20
67941	2009-02-22	62	66	right	medium	medium	63	38	57	60	46	56	72	67	57	61	68	71	70	66	60	57	65	67	56	51	61	63	60	67	64	62	64	64	14	20	57	20	20
67941	2008-08-30	58	63	right	medium	medium	63	38	57	58	46	56	72	67	55	58	66	67	70	61	60	55	65	64	53	45	57	56	52	67	60	57	58	64	14	20	55	20	20
67941	2007-08-30	58	63	right	medium	medium	63	38	57	58	46	56	72	67	55	58	66	67	70	61	60	55	65	64	53	45	57	56	52	67	60	57	58	64	14	20	55	20	20
67941	2007-02-22	58	63	right	medium	medium	63	38	57	58	46	56	72	67	55	58	66	67	70	61	60	55	65	64	53	45	57	56	52	67	60	57	58	64	14	20	55	20	20
9144	2008-08-30	61	63	right	\N	\N	62	56	33	61	\N	73	\N	66	60	71	61	58	\N	56	\N	58	\N	46	48	61	38	46	51	\N	56	21	22	\N	5	22	60	22	22
9144	2007-02-22	61	63	right	\N	\N	62	56	33	61	\N	73	\N	66	60	71	61	58	\N	56	\N	58	\N	46	48	61	38	46	51	\N	56	21	22	\N	5	22	60	22	22
166618	2016-04-21	70	72	right	medium	medium	68	62	44	68	64	78	70	64	65	73	78	74	83	67	77	69	64	63	59	68	49	31	62	67	65	28	39	28	14	12	10	16	8
166618	2016-03-24	70	72	right	medium	medium	68	62	44	68	64	78	70	64	65	73	78	74	83	67	77	69	64	63	59	68	49	31	62	70	65	28	39	28	14	12	10	16	8
166618	2016-01-28	70	72	right	medium	medium	68	62	44	68	64	78	70	64	65	73	78	74	83	67	80	69	64	63	59	68	49	31	62	70	65	28	39	28	14	12	10	16	8
166618	2016-01-14	70	71	right	medium	medium	68	62	44	68	64	78	70	64	65	73	78	74	83	67	80	69	64	63	59	68	49	31	62	70	65	28	39	28	14	12	10	16	8
166618	2015-10-09	70	71	right	medium	medium	68	62	44	68	64	78	70	64	65	73	78	74	83	67	80	69	64	63	59	68	49	31	62	70	65	28	39	28	14	12	10	16	8
166618	2015-09-21	71	72	right	medium	medium	68	62	44	68	64	78	70	64	65	73	78	74	83	67	80	69	71	63	59	68	49	31	62	70	65	28	39	28	14	12	10	16	8
166618	2015-06-05	69	70	right	medium	medium	63	61	43	63	63	77	69	63	60	72	78	74	83	66	80	68	71	63	59	67	48	30	61	66	64	27	38	27	13	11	9	15	7
166618	2015-05-29	69	70	right	medium	medium	63	61	43	62	63	77	69	63	56	72	78	74	83	66	80	68	71	63	59	67	48	30	61	58	64	27	38	27	13	11	9	15	7
166618	2015-05-08	69	72	right	medium	medium	63	61	43	62	63	77	69	63	56	72	81	77	83	66	80	68	71	68	59	67	48	30	61	55	64	27	38	27	13	11	9	15	7
166618	2015-05-01	69	72	right	medium	medium	63	61	43	62	63	77	69	63	56	72	81	77	83	66	80	68	71	73	59	67	48	30	61	55	64	27	38	27	13	11	9	15	7
166618	2015-04-01	69	72	right	medium	medium	63	61	43	62	63	77	69	63	56	72	81	77	83	66	80	68	71	73	59	67	48	30	61	55	64	27	38	27	13	11	9	15	7
166618	2014-01-10	69	72	right	medium	medium	63	61	43	62	63	77	69	63	56	72	81	77	83	66	80	68	71	73	59	67	48	30	61	55	64	27	38	27	13	11	9	15	7
166618	2013-11-01	71	77	right	medium	low	63	63	43	64	65	80	67	63	56	73	87	80	90	66	80	68	71	73	59	59	48	30	61	60	64	27	38	27	13	11	9	15	7
166618	2013-09-20	71	77	right	medium	low	63	63	43	64	65	80	67	63	56	73	87	80	90	66	80	68	71	73	59	59	48	30	61	60	64	27	38	27	13	11	9	15	7
166618	2013-07-05	73	78	left	high	medium	68	63	43	64	65	83	67	63	56	76	91	80	90	66	80	68	75	73	58	59	48	30	61	60	64	27	38	27	13	11	9	15	7
166618	2013-05-24	73	78	left	high	medium	68	63	43	64	65	83	67	63	56	76	91	80	90	66	80	68	75	73	58	59	48	30	61	60	64	27	38	27	13	11	9	15	7
166618	2013-05-17	73	78	left	high	medium	68	63	43	64	65	83	67	63	56	76	91	80	90	66	80	68	75	73	58	59	48	30	61	60	64	27	38	27	13	11	9	15	7
166618	2013-05-10	73	78	left	high	medium	69	63	43	64	65	83	67	63	56	76	91	79	90	66	80	68	75	73	58	59	48	30	67	60	64	27	38	27	13	11	9	15	7
166618	2013-04-19	73	78	left	high	medium	69	60	43	64	65	83	67	63	56	76	91	79	90	66	80	68	75	73	58	59	48	30	67	60	64	27	38	27	13	11	9	15	7
166618	2013-04-05	73	78	left	high	medium	69	60	43	64	65	83	67	63	56	76	91	79	90	66	80	68	75	73	58	59	48	30	67	60	64	27	38	27	13	11	9	15	7
166618	2013-03-15	73	78	left	high	medium	69	58	43	64	63	83	67	63	56	76	91	79	90	66	80	68	75	73	58	59	48	30	67	60	64	27	38	27	13	11	9	15	7
166618	2013-02-15	73	78	right	high	medium	69	58	43	64	63	83	67	63	56	76	91	79	90	66	80	68	75	73	58	59	48	30	67	60	64	27	38	27	13	11	9	15	7
166618	2012-08-31	73	80	right	high	medium	69	58	43	64	63	83	67	63	56	76	92	81	90	66	80	68	75	73	58	59	48	30	68	60	64	27	38	27	13	11	9	15	7
166618	2012-02-22	73	80	right	high	high	69	58	43	65	63	83	67	63	56	76	90	83	90	66	80	58	75	73	58	59	43	39	68	57	64	27	38	27	13	11	9	15	7
166618	2011-08-30	72	76	right	high	high	69	56	43	65	63	82	67	63	56	76	90	83	85	66	78	58	75	78	58	56	43	43	68	52	64	22	38	27	13	11	9	15	7
166618	2011-02-22	72	74	right	high	high	69	56	43	64	63	86	67	63	56	77	84	75	77	67	58	58	68	65	47	56	43	37	59	52	64	18	28	26	13	11	9	15	7
166618	2010-08-30	69	74	right	high	high	69	52	35	64	63	80	67	63	56	73	80	75	76	67	65	58	68	65	47	56	43	33	59	47	64	23	31	24	13	11	9	15	7
166618	2010-02-22	68	76	right	high	high	65	58	43	59	63	80	67	53	54	73	79	74	76	64	65	58	68	65	47	54	43	37	45	47	65	22	21	24	2	22	54	22	22
166618	2009-08-30	68	76	left	high	high	69	58	43	62	63	75	67	53	54	72	79	75	76	64	65	58	68	65	47	54	43	37	43	47	60	22	22	24	2	22	54	22	22
166618	2009-02-22	58	69	left	high	high	47	56	27	49	63	70	67	53	45	65	67	65	76	60	65	51	68	55	47	54	43	37	42	47	56	22	22	24	2	22	45	22	22
166618	2007-02-22	58	69	left	high	high	47	56	27	49	63	70	67	53	45	65	67	65	76	60	65	51	68	55	47	54	43	37	42	47	56	22	22	24	2	22	45	22	22
14642	2010-02-22	66	69	right	\N	\N	69	58	64	64	\N	64	\N	69	62	67	76	68	\N	64	\N	67	\N	72	64	66	54	66	67	\N	63	62	64	\N	8	21	62	21	21
14642	2009-08-30	67	69	right	\N	\N	69	67	66	64	\N	69	\N	69	62	74	76	68	\N	67	\N	67	\N	72	64	66	54	66	67	\N	63	62	64	\N	8	21	62	21	21
14642	2009-02-22	62	67	right	\N	\N	63	67	66	55	\N	64	\N	56	53	74	76	68	\N	57	\N	67	\N	72	56	68	54	53	57	\N	56	56	56	\N	8	21	53	21	21
14642	2007-02-22	62	67	right	\N	\N	63	67	66	55	\N	64	\N	56	53	74	76	68	\N	57	\N	67	\N	72	56	68	54	53	57	\N	56	56	56	\N	8	21	53	21	21
148289	2014-01-31	63	65	right	high	medium	64	56	59	67	51	58	64	68	63	60	60	65	61	61	57	68	62	79	75	63	68	57	59	62	68	56	58	57	5	10	14	7	9
148289	2013-11-08	63	65	right	high	medium	64	56	59	67	51	58	64	68	63	60	60	65	61	61	57	68	62	79	75	63	68	57	59	62	68	56	58	57	5	10	14	7	9
148289	2013-10-11	63	65	right	high	medium	64	56	59	67	51	58	64	69	63	60	60	65	61	61	57	68	62	79	75	63	68	57	59	62	68	56	58	57	5	10	14	7	9
148289	2013-09-20	63	65	right	high	medium	64	56	59	67	51	58	64	69	63	60	60	65	61	61	57	68	62	79	75	63	68	57	59	62	68	56	58	57	5	10	14	7	9
148289	2008-08-30	63	65	right	high	medium	64	56	59	67	51	58	64	69	63	60	60	65	61	61	57	68	62	79	75	63	68	57	59	62	68	56	58	57	5	10	14	7	9
148289	2007-02-22	63	65	right	high	medium	64	56	59	67	51	58	64	69	63	60	60	65	61	61	57	68	62	79	75	63	68	57	59	62	68	56	58	57	5	10	14	7	9
38969	2016-04-21	70	70	right	high	high	59	58	74	72	57	62	55	56	67	67	65	69	64	72	67	75	77	88	75	69	81	74	74	67	72	64	73	68	15	8	9	14	6
38969	2016-03-24	70	70	right	high	high	59	58	74	72	57	62	55	56	67	67	65	69	64	72	67	75	77	88	75	69	81	74	74	69	72	64	73	68	15	8	9	14	6
38969	2015-11-26	70	70	right	high	high	59	58	74	72	57	62	55	56	67	67	65	70	64	72	67	75	77	88	75	69	81	74	74	69	72	64	73	68	15	8	9	14	6
38969	2015-10-09	69	69	right	high	high	56	58	73	72	53	62	53	56	66	67	65	70	64	71	67	75	77	88	74	66	81	70	68	68	70	61	73	68	15	8	9	14	6
38969	2015-09-25	69	69	right	high	high	56	58	73	72	53	62	53	56	66	67	65	70	64	71	67	75	77	88	74	66	81	70	68	68	74	61	73	68	15	8	9	14	6
38969	2015-09-21	69	69	right	medium	high	56	58	73	69	53	60	53	56	66	67	65	70	64	71	67	75	77	88	74	66	77	70	74	68	74	59	70	68	15	8	9	14	6
38969	2015-07-03	67	67	right	medium	high	55	57	72	67	52	59	52	55	65	67	65	72	64	70	67	74	79	87	70	65	75	67	69	65	70	58	69	67	14	7	8	13	5
38969	2015-04-24	67	67	right	medium	high	55	57	72	67	52	59	52	55	65	67	65	72	64	70	67	74	79	87	70	65	75	67	69	65	70	58	69	67	14	7	8	13	5
38969	2015-03-13	67	67	right	medium	high	55	57	72	67	52	59	52	55	65	67	65	72	64	70	67	74	79	87	70	65	75	67	69	65	62	58	69	67	14	7	8	13	5
38969	2015-02-06	68	69	right	high	high	55	57	72	67	52	59	52	55	65	67	65	72	64	70	67	74	79	92	70	65	75	67	69	65	62	58	69	67	14	7	8	13	5
38969	2014-09-18	68	69	right	high	high	55	57	72	67	52	59	52	55	65	67	65	72	64	70	67	74	79	92	70	65	75	67	69	65	62	58	69	67	14	7	8	13	5
38969	2014-05-02	70	71	right	high	high	58	57	72	68	52	59	52	55	67	67	65	72	64	70	67	74	75	92	70	65	77	72	69	65	62	64	70	68	14	7	8	13	5
38969	2014-04-04	70	71	right	high	high	58	57	72	68	52	59	52	55	67	67	65	72	64	70	67	74	75	92	70	65	77	72	69	65	62	64	70	68	14	7	8	13	5
38969	2014-01-24	71	73	right	high	high	58	57	72	68	52	59	52	55	67	67	67	72	65	72	67	74	75	92	70	65	79	74	69	65	62	65	71	69	14	7	8	13	5
38969	2013-09-20	71	73	right	high	high	58	57	72	68	52	59	52	55	67	67	67	72	65	72	67	74	75	92	72	65	79	74	69	65	62	65	71	69	14	7	8	13	5
38969	2013-03-22	70	74	right	high	high	58	57	72	68	52	59	52	55	67	65	67	71	69	72	70	74	74	91	69	65	79	69	67	65	62	64	70	67	14	7	8	13	5
38969	2013-03-08	70	74	right	high	high	58	57	72	68	52	59	52	55	67	65	67	71	69	72	70	74	74	91	69	65	79	69	67	65	62	64	70	67	14	7	8	13	5
38969	2013-02-15	70	74	right	high	high	58	57	72	68	52	59	52	55	67	65	67	71	69	72	70	74	74	91	69	65	79	69	67	65	62	64	70	67	14	7	8	13	5
38969	2012-08-31	69	72	right	high	high	58	57	72	68	52	59	52	55	67	65	67	72	69	72	68	74	72	82	69	65	79	69	67	65	62	64	70	67	14	7	8	13	5
38969	2012-02-22	68	72	right	medium	medium	58	33	72	67	51	59	52	55	65	65	67	72	69	72	68	72	72	82	67	62	79	67	65	65	50	62	67	65	14	7	8	13	5
38969	2011-08-30	68	72	right	medium	medium	58	33	72	67	51	59	52	55	65	65	67	72	69	72	68	72	72	82	67	62	79	67	47	65	50	62	67	65	14	7	8	13	5
38969	2011-02-22	65	72	right	medium	medium	58	47	65	67	48	61	57	64	65	64	65	68	63	67	63	63	66	74	69	63	66	58	63	68	60	54	53	59	14	7	8	13	5
38969	2010-08-30	65	72	right	medium	medium	58	47	65	67	48	61	57	64	65	64	65	68	63	67	63	63	66	74	69	63	66	58	63	68	60	54	53	59	14	7	8	13	5
38969	2009-08-30	62	72	right	medium	medium	53	38	64	61	48	59	57	49	64	61	65	68	63	67	63	58	66	69	63	61	66	65	64	68	68	53	51	59	2	20	64	20	20
38969	2007-02-22	62	72	right	medium	medium	53	38	64	61	48	59	57	49	64	61	65	68	63	67	63	58	66	69	63	61	66	65	64	68	68	53	51	59	2	20	64	20	20
38341	2016-04-28	65	65	right	medium	medium	11	13	12	38	11	18	19	20	32	28	45	54	46	66	42	38	60	37	64	12	25	22	12	42	16	11	13	20	68	64	56	66	65
38341	2015-11-19	65	65	right	medium	medium	11	13	12	38	11	18	19	20	32	28	45	54	46	66	42	38	60	37	64	12	25	22	12	42	16	11	13	20	68	64	56	66	65
38341	2015-09-21	66	66	right	medium	medium	11	13	12	38	11	18	19	20	32	28	45	54	46	66	42	38	60	37	64	12	25	22	12	42	16	11	13	20	69	64	56	66	66
38341	2015-05-08	66	67	right	medium	medium	25	25	25	37	25	25	25	25	31	27	48	54	46	67	42	37	62	37	64	25	24	21	25	25	25	25	25	25	70	63	59	65	68
38341	2014-11-07	66	68	right	medium	medium	25	25	25	37	25	25	25	25	31	27	48	54	46	67	42	37	62	37	64	25	24	21	25	25	25	25	25	25	70	63	59	65	68
38341	2014-09-18	67	68	right	medium	medium	25	25	25	37	25	25	25	25	31	27	48	54	46	67	42	37	62	37	64	25	24	21	25	25	25	25	25	25	71	65	60	66	69
38341	2013-12-20	68	68	right	medium	medium	25	25	25	37	25	25	25	25	31	27	48	54	46	67	42	37	62	37	64	25	24	21	25	25	25	25	25	25	72	66	61	67	70
38341	2013-10-18	68	69	right	medium	medium	25	25	25	37	25	25	25	25	31	27	48	54	46	67	42	37	62	37	64	25	24	21	25	25	25	25	25	25	71	66	61	67	71
38341	2013-09-20	68	71	right	medium	medium	25	25	25	37	25	25	25	25	31	27	48	54	46	67	42	37	62	37	72	25	24	21	25	25	25	25	25	25	71	66	61	67	71
38341	2013-04-19	68	71	right	medium	medium	10	12	11	37	10	17	18	19	31	27	48	54	46	67	42	37	62	37	72	11	24	21	11	15	15	10	12	19	71	66	61	67	71
38341	2012-08-31	68	71	right	medium	medium	10	12	11	37	10	17	18	19	31	27	51	54	57	67	42	37	68	49	72	11	24	23	11	23	15	10	12	19	71	66	61	67	71
38341	2012-02-22	68	72	right	medium	medium	10	12	11	37	10	17	18	19	31	27	51	54	57	67	42	37	68	49	72	11	24	23	11	23	15	10	12	19	71	66	61	67	71
38341	2011-08-30	68	72	right	medium	medium	10	12	11	37	10	17	18	19	31	27	51	54	56	63	42	37	67	49	72	11	54	23	11	43	15	10	12	19	70	66	61	67	71
38341	2011-02-22	68	74	right	medium	medium	13	12	19	41	9	17	18	19	31	31	51	54	56	59	67	37	65	49	69	11	19	24	11	21	15	9	12	19	70	66	65	67	71
38341	2010-08-30	68	74	right	medium	medium	9	12	19	53	23	17	18	19	59	31	51	54	56	59	67	37	65	49	69	11	19	24	11	21	15	23	12	19	70	66	65	67	71
38341	2010-02-22	67	73	right	medium	medium	20	20	20	38	23	20	18	19	63	31	51	54	56	53	67	37	65	49	72	20	20	15	11	21	20	23	20	19	67	64	63	67	71
38341	2009-08-30	67	73	right	medium	medium	20	20	20	53	23	20	18	19	63	31	51	54	56	53	67	37	65	49	72	20	20	15	11	21	20	23	20	19	67	64	63	67	71
38341	2008-08-30	64	73	right	medium	medium	20	20	20	50	23	20	18	19	62	20	50	54	56	52	67	51	65	46	72	20	20	15	11	21	20	20	20	19	64	63	62	62	67
38341	2007-08-30	60	73	right	medium	medium	20	20	20	24	23	20	18	19	58	20	42	54	56	52	67	51	65	36	53	20	20	15	11	21	20	20	20	19	64	63	58	56	59
38341	2007-02-22	60	73	right	medium	medium	20	20	20	24	23	20	18	19	58	20	42	54	56	52	67	51	65	36	53	20	20	15	11	21	20	20	20	19	64	63	58	56	59
12574	2016-02-04	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2016-01-21	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2015-09-21	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2015-01-30	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2015-01-23	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2014-11-14	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2014-09-18	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2013-12-06	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2013-11-22	72	72	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	84	80	77	67	72	48	73	72	59	32	49	54	6	16	16	6	8
12574	2013-09-20	71	71	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	86	82	77	67	72	48	74	72	59	32	49	54	6	16	16	6	8
12574	2013-04-12	71	71	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	86	82	77	67	72	48	74	72	59	32	49	54	6	16	16	6	8
12574	2012-02-22	71	71	right	high	medium	70	69	72	69	64	70	64	59	65	71	79	78	73	75	61	69	86	82	77	67	72	48	74	72	59	32	49	54	6	16	16	6	8
12574	2011-08-30	71	72	right	high	medium	70	69	72	66	64	68	64	59	65	71	82	79	79	75	61	69	84	84	78	64	72	47	76	72	59	36	38	43	6	16	16	6	8
12574	2011-02-22	70	74	right	high	medium	71	69	72	64	64	67	64	59	62	71	77	75	75	75	78	69	75	80	75	64	72	47	74	72	59	36	38	43	6	16	16	6	8
12574	2010-08-30	69	74	right	high	medium	69	69	72	64	64	67	64	59	58	71	75	73	71	75	78	69	72	75	75	64	72	41	74	72	59	36	34	43	6	16	16	6	8
12574	2010-02-22	70	74	right	high	medium	61	69	72	64	64	66	64	59	58	71	75	73	71	75	78	69	72	75	75	64	72	74	75	72	70	36	34	43	11	23	58	23	23
12574	2009-08-30	70	74	right	high	medium	61	72	72	64	64	66	64	59	58	69	75	73	71	75	78	69	72	75	75	64	72	74	75	72	70	36	34	43	11	23	58	23	23
12574	2008-08-30	66	69	right	high	medium	68	64	67	67	64	68	64	66	66	65	70	67	71	62	78	65	72	68	71	64	58	59	67	72	66	36	34	43	11	23	66	23	23
12574	2007-08-30	65	82	right	high	medium	68	67	67	67	64	68	64	66	66	57	70	67	71	62	78	65	72	68	57	64	68	59	67	72	66	56	64	43	11	23	66	23	23
12574	2007-02-22	65	82	right	high	medium	68	67	67	67	64	68	64	66	66	57	70	67	71	62	78	65	72	68	57	64	68	59	67	72	66	56	64	43	11	23	66	8	2
\.


--
-- Data for Name: team; Type: TABLE DATA; Schema: soccerdb; Owner: postgres
--

COPY soccerdb.team (id, long_name, short_name) FROM stdin;
9987	KRC Genk	GEN
9993	Beerschot AC	BAC
10000	SV Zulte-Waregem	ZUL
9994	Sporting Lokeren	LOK
9984	KSV Cercle Brugge	CEB
8635	RSC Anderlecht	AND
9991	KAA Gent	GEN
9998	RAEC Mons	MON
7947	FCV Dender EH	DEN
9985	Standard de Liège	STL
8203	KV Mechelen	MEC
8342	Club Brugge KV	CLB
9999	KSV Roeselare	ROS
8571	KV Kortrijk	KOR
4049	Tubize	TUB
9996	Royal Excel Mouscron	MOU
10001	KVC Westerlo	WES
9986	Sporting Charleroi	CHA
9997	Sint-Truidense VV	STT
\.


--
-- Name: dbuser_id_seq; Type: SEQUENCE SET; Schema: soccerdb; Owner: postgres
--

SELECT pg_catalog.setval('soccerdb.dbuser_id_seq', 4, true);


--
-- Name: match_id_seq; Type: SEQUENCE SET; Schema: soccerdb; Owner: postgres
--

SELECT pg_catalog.setval('soccerdb.match_id_seq', 1000, false);


--
-- Name: bet bet_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.bet
    ADD CONSTRAINT bet_pkey PRIMARY KEY (match, dbuser);


--
-- Name: dbuser dbuser_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.dbuser
    ADD CONSTRAINT dbuser_pkey PRIMARY KEY (id);


--
-- Name: dbuser dbuser_username_key; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.dbuser
    ADD CONSTRAINT dbuser_username_key UNIQUE (username);


--
-- Name: formation formation_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.formation
    ADD CONSTRAINT formation_pkey PRIMARY KEY (match, player, team);


--
-- Name: league league_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.league
    ADD CONSTRAINT league_pkey PRIMARY KEY (name);


--
-- Name: match match_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (id);


--
-- Name: player player_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.player
    ADD CONSTRAINT player_pkey PRIMARY KEY (id);


--
-- Name: playerstats playerstats_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.playerstats
    ADD CONSTRAINT playerstats_pkey PRIMARY KEY (player, attribute_date);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: match functgr_refresh_ranking; Type: TRIGGER; Schema: soccerdb; Owner: postgres
--

CREATE TRIGGER functgr_refresh_ranking AFTER INSERT OR DELETE OR UPDATE ON soccerdb.match FOR EACH STATEMENT EXECUTE PROCEDURE soccerdb.functgr_refresh_ranking();


--
-- Name: bet bet_dbuser_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.bet
    ADD CONSTRAINT bet_dbuser_fkey FOREIGN KEY (dbuser) REFERENCES soccerdb.dbuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bet bet_match_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.bet
    ADD CONSTRAINT bet_match_fkey FOREIGN KEY (match) REFERENCES soccerdb.match(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: formation formation_match_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.formation
    ADD CONSTRAINT formation_match_fkey FOREIGN KEY (match) REFERENCES soccerdb.match(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: formation formation_player_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.formation
    ADD CONSTRAINT formation_player_fkey FOREIGN KEY (player) REFERENCES soccerdb.player(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: formation formation_team_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.formation
    ADD CONSTRAINT formation_team_fkey FOREIGN KEY (team) REFERENCES soccerdb.team(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_away_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.match
    ADD CONSTRAINT match_away_fkey FOREIGN KEY (away) REFERENCES soccerdb.team(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_dbuser_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.match
    ADD CONSTRAINT match_dbuser_fkey FOREIGN KEY (dbuser) REFERENCES soccerdb.dbuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_home_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.match
    ADD CONSTRAINT match_home_fkey FOREIGN KEY (home) REFERENCES soccerdb.team(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_league_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.match
    ADD CONSTRAINT match_league_fkey FOREIGN KEY (league) REFERENCES soccerdb.league(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerstats playerstats_player_fkey; Type: FK CONSTRAINT; Schema: soccerdb; Owner: postgres
--

ALTER TABLE ONLY soccerdb.playerstats
    ADD CONSTRAINT playerstats_player_fkey FOREIGN KEY (player) REFERENCES soccerdb.player(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ranking; Type: MATERIALIZED VIEW DATA; Schema: soccerdb; Owner: postgres
--

REFRESH MATERIALIZED VIEW soccerdb.ranking;


--
-- PostgreSQL database dump complete
--
