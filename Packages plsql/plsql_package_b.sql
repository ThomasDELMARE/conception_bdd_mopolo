/*

TABLE B --> Ouvrage

- Ajouter une nouvelle occurence --> OuvrageInserer
- Supprimer une occurence --> OuvrageSupprimer
- (2) Fonctions de modification d'informations --> OuvrageModifierLangueByISBN, OuvrageModifierFormatByISBN
- Lister toutes les occurences de B pour une occurence de A donnée --> ouvrageLister

*/

create or replace package pk_ouvrage IS

TYPE refcursorType IS REF CURSOR;

no_data_updated EXCEPTION;
pragma exception_init(no_data_updated, -20001);

mess  varchar2(1000);

PROCEDURE ouvrageInserer(ouvrage IN ouvrage%ROWTYPE);

PROCEDURE ouvrageSupprimer(ISBNToDelete IN number);

PROCEDURE ouvrageModifierLangueByISBN(ISBNAModifier IN number, nouvelleLangue IN varchar2);

PROCEDURE ouvrageModifierFormatByISBN(ISBNAModifier IN number, nouveauFormat IN varchar2);

FUNCTION ouvrageLister(nomEditeurALister IN varchar2) RETURN pk_ouvrage.refcursorType;

END pk_ouvrage;
/



CREATE OR REPLACE PACKAGE BODY pk_ouvrage IS

-- INSERT
PROCEDURE ouvrageInserer(ouvrage IN ouvrage%rowtype) IS 

BEGIN 

INSERT INTO OUVRAGE VALUES (ouvrage.Isbn, ouvrage.Titre, ouvrage.Annee_de_parution, ouvrage.Langue, ouvrage.Format, ouvrage.Edition, ouvrage.Description, ouvrage.Couverture, ouvrage.Encours, ouvrage.tag, ouvrage.nom_editeur);

EXCEPTION
	
	WHEN DUP_VAL_ON_INDEX THEN
		raise;	
	WHEN OTHERS THEN
		raise;
END;

-- DELETE
PROCEDURE ouvrageSupprimer(ISBNToDelete IN number) IS

BEGIN 

DELETE FROM OUVRAGE WHERE ouvrage.ISBN = ISBNToDelete;

EXCEPTION
	
	WHEN OTHERS THEN
		raise;
END;

-- UPDATE 1
PROCEDURE ouvrageModifierLangueByISBN(ISBNAModifier IN number, nouvelleLangue IN varchar2) IS

BEGIN 
	UPDATE OUVRAGE
	SET Langue = nouvelleLangue
	WHERE ISBN = ISBNAModifier;
	
	IF SQL%ROWCOUNT = 0 THEN
		pk_ouvrage.mess:='Aucune ligne modifié';
		raise_application_error(-20001, mess);	
	END IF;
	
EXCEPTION
	WHEN pk_ouvrage.no_data_updated THEN
		raise;
	WHEN OTHERS THEN
		raise;
END; 

-- UPDATE 2
PROCEDURE ouvrageModifierFormatByISBN(ISBNAModifier IN number, nouveauFormat IN varchar2) IS

BEGIN 
	UPDATE OUVRAGE
	SET Format = nouveauFormat
	WHERE ISBN = ISBNAModifier;
	
	IF SQL%ROWCOUNT = 0 THEN
		pk_ouvrage.mess:='Aucune ligne modifié';
		raise_application_error(-20001, mess);	
	END IF;
	
EXCEPTION
	WHEN pk_ouvrage.no_data_updated THEN
		raise;
	WHEN OTHERS THEN
		raise;
END; 

-- LISTER
FUNCTION ouvrageLister(nomEditeurALister IN varchar2) RETURN pk_ouvrage.refcursorType IS

cursEmp pk_ouvrage.refCursorType;

BEGIN

	OPEN cursEmp FOR
	
	SELECT ouvrage.* 
	FROM ouvrage
	WHERE ouvrage.nom_editeur = nomEditeurALister;

	RETURN cursEmp ;
	
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
		raise;

	WHEN OTHERS THEN
		raise;
	
END;

END pk_ouvrage;
/










-- VERIFICATION DES OUVRAGES AVANT AJOUT
SELECT ISBN FROM ouvrage;

-- TEST DE LA FONCTION ouvrageInserer
SET serveroutput ON

DECLARE
    ouvrageAInserer  ouvrage%ROWTYPE;

BEGIN

	ouvrageAInserer.Isbn := 9782253002857;
	ouvrageAInserer.Titre := 'Les Rougon-Macquart, tome 7 : L''assommoir';
	ouvrageAInserer.Annee_de_parution := 1973;
	ouvrageAInserer.Langue := 'Française';
	ouvrageAInserer.Format := 'Poche';
	ouvrageAInserer.Edition := 1;
	ouvrageAInserer.Description := 'Zola, dans "L''Assommoir", septième roman des "Rougon-Macquart" raconte le drame de la vie populaire : l''alcoolisme, propagé par les débits de boissons nommés à juste titre des « assommoirs ». Coupeau, bon ouvrier zingueur, après un accident, au cours d''une longue convalescence, se laisse gagner par l''alcool. Sa femme Gervaise, qui avait de haute lutte acquis une blanchisserie, après avoir résisté, est à son tour entraîné jusqu''à la pire déchéance.';
	ouvrageAInserer.Couverture := NULL;
	ouvrageAInserer.Encours := 2;
    ouvrageAInserer.tag := 'PN';
    ouvrageAInserer.nom_editeur := 'Editis';
	 
	pk_ouvrage.ouvrageInserer(ouvrageAInserer);
	 
	DBMS_OUTPUT.PUT_LINE('L''ouvrage avec l''ISBN '|| ouvrageAInserer.Isbn || ' a été inséré.');
 
EXCEPTION 

	WHEN DUP_VAL_ON_INDEX THEN
		DBMS_OUTPUT.PUT_LINE('Numéro ISBN déjà existant.');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Erreur dans le programme');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

END;
/

-- VERIFICATION DE L AJOUT D OUVRAGE
SELECT ISBN FROM ouvrage;






-- TEST DE LA FONCTION ouvrageSupprimer
set serveroutput on

DECLARE
	ISBNToDelete ouvrage.Isbn%type := 9782253002857;

BEGIN

	pk_ouvrage.ouvrageSupprimer(ISBNToDelete);
	DBMS_OUTPUT.PUT_LINE('L''ouvrage avec l''ISBN '|| ISBNToDelete || ' a été supprimé.');
 
EXCEPTION 

	WHEN DUP_VAL_ON_INDEX THEN
		DBMS_OUTPUT.PUT_LINE('L''ISBN de l''ouvrage n''existe pas.');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Erreur dans le programme');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

END;
/

-- VERIFICATION DE LA SUPPRESSION D OUVRAGE
SELECT ISBN FROM ouvrage;





-- TEST DE LA FONCTION ouvrageModifierLangueByISBN
SET serveroutput ON;

-- VERIFIER LA LANGUE ACTUELLE DE L'OUVRAGE
SELECT Langue FROM ouvrage WHERE Isbn= 9782340034648;

DECLARE
	ISBNAModifier ouvrage.Isbn%type := 9782340034648;
	nouvelleLangue ouvrage.Langue%type := 'Portugais';

BEGIN
	pk_ouvrage.ouvrageModifierLangueByISBN(ISBNAModifier, nouvelleLangue);
	dbms_output.put_line('Mise à jour effectuée avec succès');
	
EXCEPTION

	WHEN pk_ouvrage.no_data_updated THEN
		dbms_output.put_line('Aucune mise à jour effectuée');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN			
		dbms_output.put_line('Erreur dans le programme');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);
		
END;
/

-- VERIFIER LA NOUVELLE LANGUE DE L'OUVRAGE
SELECT Langue FROM ouvrage WHERE Isbn= 9782340034648;





-- TEST DE LA FONCTION OuvrageModifierFormatByISBN
SET serveroutput ON;

-- VERIFIER LE FORMAT ACTUEL DE L'OUVRAGE
SELECT Format FROM ouvrage WHERE Isbn= 9782340034648;

DECLARE
	ISBNAModifier ouvrage.Isbn%type := 9782340034648;
	nouveauFormat ouvrage.Format%type := 'Broché';

BEGIN
	pk_ouvrage.ouvrageModifierFormatByISBN(ISBNAModifier, nouveauFormat);
	dbms_output.put_line('Mise à jour effectuée avec succès');
	
EXCEPTION

	WHEN pk_ouvrage.no_data_updated THEN
		dbms_output.put_line('Aucune mise à jour effectuée');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN			
		dbms_output.put_line('Erreur dans le programme');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);
		
END;
/

-- VERIFIER LE NOUVEAU FORMAT DE L'OUVRAGE
SELECT Format FROM ouvrage WHERE Isbn= 9782340034648;





-- TEST DE LA FONCTION ouvrageLister
SET serveroutput ON;

DECLARE
	listeOuvrages pk_ouvrage.refCursorType;
	ligneOuvrage ouvrage%rowtype;
	nbOuvrage number:= 0;
BEGIN

	listeOuvrages:= pk_ouvrage.ouvrageLister('Hachette') ;

	LOOP 
		FETCH listeOuvrages INTO ligneOuvrage;
		EXIT WHEN listeOuvrages%notfound;
		nbOuvrage:=nbOuvrage+1;
		
		-- Afficher les informations sur l'ouvrage extrait du curseur
		DBMS_OUTPUT.PUT_LINE('ISBN de l''ouvrage                       = '|| ligneOuvrage.Isbn);
		DBMS_OUTPUT.PUT_LINE('Titre de l''ouvrage                      = '|| ligneOuvrage.Titre); 
		DBMS_OUTPUT.PUT_LINE('Année de parution de l''ouvrage          = '|| ligneOuvrage.annee_de_parution); 
		DBMS_OUTPUT.PUT_LINE('Langue de l''ouvrage                     = '|| ligneOuvrage.langue);
		DBMS_OUTPUT.PUT_LINE('Format de l''ouvrage                     = '|| ligneOuvrage.Format);
		DBMS_OUTPUT.PUT_LINE('Edition de l''ouvrage                    = '|| ligneOuvrage.Edition);
		DBMS_OUTPUT.PUT_LINE('Description de l''ouvrage                = '|| ligneOuvrage.Description);
		DBMS_OUTPUT.PUT_LINE('Encours de l''ouvrage                    = '|| ligneOuvrage.Encours);
		DBMS_OUTPUT.PUT_LINE('');	
        DBMS_OUTPUT.PUT_LINE('');	
        DBMS_OUTPUT.PUT_LINE('');	
		
	END LOOP;
	
	-- Si le curseur est vide
	IF nbOuvrage = 0 then
		raise no_data_found;
	END IF;

	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Aucun ouvrage trouvé.');		
			dbms_output.put_line('sqlcode='|| sqlcode);
			dbms_output.put_line('sqlerrm='|| sqlerrm);

		WHEN OTHERS THEN
			dbms_output.put_line('sqlcode='|| sqlcode);
			dbms_output.put_line('sqlerrm='|| sqlerrm);

END;
/