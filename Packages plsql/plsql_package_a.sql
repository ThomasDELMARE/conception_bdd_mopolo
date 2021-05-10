/*

TABLE A --> EDITEUR

- Ajouter une nouvelle occurence --> editeurInserer
- Supprimer une occurence (les enregistrements dans la table B doivent aussi être supprimées) --> editeurSupprimer
- (2) Fonctions de modification d'informations --> editeurModifierTelephoneByNom, editeurModifierEmailByNom
- Lister toutes les occurences --> editeurLister
- Nombre total d'occurences --> editeurTotal
- (3) Requetes de consultations liant 2 tables au moins --> editeurTrierByAnneeParution, editeurTrierByTitreASC, editeurTrierByTitreDESC 

*/

CREATE OR REPLACE PACKAGE pk_editeur IS

TYPE refcursorType IS REF CURSOR;

no_data_updated EXCEPTION;
pragma exception_init(no_data_updated, -20001);

mess  varchar2(1000);

PROCEDURE editeurInserer(editeur IN editeur%rowtype);

PROCEDURE editeurSupprimer(nomASupprimer IN varchar2);

PROCEDURE editeurModifierTelephoneByNom(nomEditeur IN varchar2, nouveauTelephone IN varchar2);
PROCEDURE editeurModifierEmailByNom(nomEditeur IN varchar2, nouvelEmail IN varchar2);

FUNCTION editeurLister() RETURN pk_editeur.refcursorType;

FUNCTION editeurTotal() RETURN number;

FUNCTION editeurTrierByAnneeParution() RETURN pk_editeur.refcursorType;
FUNCTION editeurTrierByTitreASC() RETURN pk_editeur.refcursorType;
FUNCTION editeurTrierByTitreDESC() RETURN pk_editeur.refcursorType;

end pk_editeur;
/



CREATE OR REPLACE PACKAGE BODY pk_editeur IS

-- INSERT
PROCEDURE editeurInserer(editeur IN editeur%ROWTYPE) IS 

BEGIN 

INSERT INTO EDITEUR VALUES (editeur.nom, editeur.téléphone, editeur.email, editeur.adresse);

EXCEPTION
	
	WHEN DUP_VAL_ON_INDEX THEN
		raise;	
	WHEN OTHERS THEN
		raise;
END;

-- DELETE
PROCEDURE editeurSupprimer(nomASupprimer IN varchar2) IS 

BEGIN 

DELETE FROM EDITEUR WHERE editeur.nom = nomASupprimer;

EXCEPTION
	
	WHEN OTHERS THEN
		raise;
END;

-- UPDATE 1
PROCEDURE editeurModifierTelephoneByNom(nomEditeur IN varchar2, nouveauTelephone IN varchar2) IS

BEGIN 
	UPDATE EDITEUR
	SET telephone = nouveauTelephone
	WHERE nom = nomEditeur;
	
	IF SQL%ROWCOUNT = 0 THEN
		pk_editeur.mess:='Aucune ligne modifié';
		raise_application_error(-20001, mess);	
	END IF;
	
	EXCEPTION
	WHEN pk_editeur.no_data_updated THEN
		raise;
	WHEN OTHERS THEN
		raise;
END;

-- UPDATE 2
PROCEDURE editeurModifierEmailByNom(nomEditeur IN varchar2, nouvelEmail IN varchar2) IS

BEGIN 
	UPDATE EDITEUR
	SET email = nouvelEmail
	WHERE nom = nomEditeur;
	
	IF SQL%ROWCOUNT = 0 THEN
		pk_editeur.mess:='Aucune ligne modifié';
		raise_application_error(-20001, mess);	
	END IF;
	
	EXCEPTION
	WHEN pk_editeur.no_data_updated THEN
		raise;
	WHEN OTHERS THEN
		raise;
end;

-- LISTER
FUNCTION editeurLister() RETURN pk_editeur.refCursorType IS

cursEmp pk_editeur.refCursorType;

BEGIN

	OPEN cursEmp FOR
	
	SELECT * 
	FROM editeur;

	RETURN cursEmp ;
	
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
		raise;

	WHEN OTHERS THEN
		raise;
	
END;

-- TOTAL
FUNCTION editeurTotal() RETURN number IS

BEGIN
	SELECT COUNT(nom) AS total_editeur
	FROM editeur;

	RETURN total_editeur;

EXCEPTION 
	WHEN NO_DATA_FOUND THEN
		raise;
	WHEN OTHERS THEN
		raise;
		
END;

-- TRI 1
FUNCTION editeurTrierByAnneeParution() RETURN pk_editeur.refcursorType IS

BEGIN

	OPEN cursEmp FOR
	
	SELECT ouvrage.* 
	FROM editeur, ouvrage
	WHERE editeur.nom = ouvrage.nom
	ORDER BY 'année de parution';

	RETURN cursEmp ;
	
EXCEPTION 

	WHEN NO_DATA_FOUND THEN
		raise;

	WHEN OTHERS THEN
		raise;
	
END;

-- TRI 2
FUNCTION editeurTrierByTitreASC() RETURN pk_editeur.refcursorType IS

BEGIN

	OPEN cursEmp FOR
	
	SELECT ouvrage.* 
	FROM editeur, ouvrage
	WHERE editeur.nom = ouvrage.nom
	ORDER BY ouvrage.titre ASC;

	RETURN cursEmp ;
	
EXCEPTION 

	WHEN NO_DATA_FOUND THEN
		raise;

	WHEN OTHERS THEN
		raise;
	
END;

-- TRI 3
FUNCTION editeurTrierByTitreDESC() RETURN pk_editeur.refcursorType IS

BEGIN

	OPEN cursEmp FOR
	
	SELECT ouvrage.* 
	FROM editeur, ouvrage
	WHERE editeur.nom = ouvrage.nom
	ORDER BY ouvrage.titre DESC;

	RETURN cursEmp ;
	
EXCEPTION 

	WHEN NO_DATA_FOUND THEN
		raise;

	WHEN OTHERS THEN
		raise;
	
END;

END pk_editeur;
/










-- VERIFICATION DES EDITEURS AVANT AJOUT
SELECT nom FROM editeur;

-- TEST DE LA FONCTION editeurInserer
SET serveroutput ON

DECLARE
editeur  editeur%ROWTYPE;

BEGIN

	editeur.nom := 'L''Arche';
	editeur.téléphone := 0606070708;
	editeur.email := 'hachette@gmail.com';
	editeur.adresse :='90 impasse de l''olivette';
	 
	pk_editeur.editeurInserer(editeur);
	 
	DBMS_OUTPUT.PUT_LINE('L''éditeur avec le nom '|| editeur.nom || ' a été inséré.');
 
EXCEPTION 

	WHEN DUP_VAL_ON_INDEX THEN
		DBMS_OUTPUT.PUT_LINE('Nom d''éditeur déjà existant.');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Erreur dans le programme');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

END;
/

-- VERIFICATION DE L AJOUT
SELECT nom FROM editeur;





-- TEST DE LA FONCTION editeurSupprimer
set serveroutput on

DECLARE
	nomASupprimer editeur.nom%type := 'L''Arche';

BEGIN

	pk_editeur.editeurSupprimer(nomASupprimer);

	DBMS_OUTPUT.PUT_LINE('L''éditeur avec le nom '|| editeur.nom || ' a été supprimé.');
 
EXCEPTION 

	WHEN DUP_VAL_ON_INDEX THEN
		DBMS_OUTPUT.PUT_LINE('Nom d''éditeur déjà existant.');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Erreur dans le programme');		
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

end;
/

-- VERIFICATION DE LA SUPPRESSION
SELECT nom FROM editeur;





-- TEST DE LA FONCTION editeurModifierTelephoneByNom
SET serveroutput ON;

-- VERIFIER LE NUMERO DE TELEPHONE ACTUEL DE L EDITEUR
SELECT telephone FROM editeur WHERE nom= 'Hachette';

DECLARE
	nomEditeur editeur.nom%type := 'Hachette';
	nouveauTelephone editeur.telephone%type := '0707070808';

BEGIN

	pk_editeur.editeurModifierTelephoneByNom(nomEditeur, nouveauTelephone);
	dbms_output.put_line('Mise à jour effectuée avec succès');
	
EXCEPTION

	WHEN pk_editeur.no_data_updated THEN
		dbms_output.put_line('Aucune mise à jour effectuée');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN			
		dbms_output.put_line('Erreur dans le programme');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);
		
END;
/

-- VERIFIER LE NOUVEAU NUMERO DE TELEPHONE DE L EDITEUR
SELECT telephone FROM editeur WHERE nom= 'Hachette';





-- TEST DE LA FONCTION editeurModifierEmailByNom
SET serveroutput ON;

-- VERIFIER L'EMAIL ACTUEL DE L EDITEUR
SELECT email FROM editeur WHERE nom= 'Hachette';

DECLARE
	nomEditeur editeur.nom%type := 'Hachette';
	nouvelEmail editeur.email%type := 'hachetteuh@gmail.com';

BEGIN

	pk_editeur.editeurModifierEmailByNom(nomEditeur, nouvelEmail);
	dbms_output.put_line('Mise à jour effectuée avec succès');
	
EXCEPTION

	WHEN pk_editeur.no_data_updated THEN
		dbms_output.put_line('Aucune mise à jour effectuée');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);

	WHEN OTHERS THEN			
		dbms_output.put_line('Erreur dans le programme');
		dbms_output.put_line('sqlcode='|| sqlcode);
		dbms_output.put_line('sqlerrm='|| sqlerrm);
		
END;
/

-- VERIFIER LE NOUVEL EMAIL DE L EDITEUR
SELECT email FROM editeur WHERE nom= 'Hachette';





-- TEST DE LA FONCTION editeurLister
SET serveroutput ON;

DECLARE
	listeEditeurs pk_editeur.refCursorType;
	ligneEditeur editeur%rowtype;
	nbEditeur number:= 0;
BEGIN

	listeEditeurs:= pk_editeur.editeurLister() ;

	LOOP 
		FETCH listeEditeurs INTO ligneEditeur;
		EXIT WHEN listeEditeurs%notfound;
		nbEditeur:=nbEditeur+1;
		
		-- Afficher les informations sur l'éditeur du curseur
		DBMS_OUTPUT.PUT_LINE('Nom de l''éditeur            ='|| ligneEditeur.nom);
		DBMS_OUTPUT.PUT_LINE('Téléphone de l''éditeur      ='|| lignePilote.plnom); 
		DBMS_OUTPUT.PUT_LINE('Email de l''éditeur          ='|| lignePilote.adr); 
		DBMS_OUTPUT.PUT_LINE('Adresse de l''éditeur        ='|| lignePilote.sal);

	END LOOP;
	
	-- Si le curseur est vide
	IF nbEditeur = 0 then
		raise no_data_found;
	END IF;

	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Aucun éditeur trouvé.');		
			dbms_output.put_line('sqlcode='|| sqlcode);
			dbms_output.put_line('sqlerrm='|| sqlerrm);

		WHEN OTHERS THEN
			dbms_output.put_line('sqlcode='|| sqlcode);
			dbms_output.put_line('sqlerrm='|| sqlerrm);

END;
/





-- TEST DE LA FONCTION editeurTotal
SET serveroutput ON;

DECLARE
	listeEditeurs pk_editeur.refCursorType;
	nbEditeur number:= 0;
BEGIN

	listeEditeurs:= pk_editeur.editeurTotal() ;

	LOOP 
		FETCH listeEditeurs INTO ligneEditeur;
		EXIT WHEN listeEditeurs%notfound;
		nbEditeur:=nbEditeur+1;
	END LOOP;
	
	-- Si le curseur est vide
	IF nbEditeur = 0 then
		raise no_data_found;
	END IF;
	
	DBMS_OUTPUT.PUT_LINE(nbEditeur || ' éditeur(s) trouvé.');
	
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('0 éditeur trouvé.');		
			dbms_output.put_line('sqlcode='|| sqlcode);
			dbms_output.put_line('sqlerrm='|| sqlerrm);

		WHEN OTHERS THEN
			dbms_output.put_line('sqlcode='|| sqlcode);
			dbms_output.put_line('sqlerrm='|| sqlerrm);

END;
/





-- TEST DE LA FONCTION editeurTrierByAnneeParution
SET serveroutput ON;

DECLARE
	listeOuvrages pk_editeur.refCursorType;
	ligneOuvrage editeur%rowtype;
	nbOuvrage number:= 0;
	
BEGIN

	listeOuvrages:= pk_editeur.editeurTrierByAnneeParution();

	LOOP 
		FETCH listeOuvrages INTO ligneOuvrage;
		EXIT WHEN listeOuvrages%notfound;
		nbOuvrage := nbOuvrage + 1;
		
		-- Affichier les informations sur le pilote extrait du curseur
		DBMS_OUTPUT.PUT_LINE('ISBN de l''ouvrage                       ='|| ligneOuvrage.ISBN);
		DBMS_OUTPUT.PUT_LINE('Titre de l''ouvrage                      ='|| ligneOuvrage.Titre); 
		DBMS_OUTPUT.PUT_LINE('Année de parution de l''ouvrage          ='|| ligneOuvrage.Annee_de_parution); 
		DBMS_OUTPUT.PUT_LINE('Langue de l''ouvrage                     ='|| ligneOuvrage.Langue);
		DBMS_OUTPUT.PUT_LINE('Format de l''ouvrage                     ='|| ligneOuvrage.Format);
		DBMS_OUTPUT.PUT_LINE('Edition de l''ouvrage                    ='|| ligneOuvrage.Edition);
		DBMS_OUTPUT.PUT_LINE('Description de l''ouvrage                ='|| ligneOuvrage.Description);
		DBMS_OUTPUT.PUT_LINE('Couverture de l''ouvrage                 ='|| ligneOuvrage.Couverture);
		DBMS_OUTPUT.PUT_LINE('Encours de l''ouvrage                    ='|| ligneOuvrage.Encours);	

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





-- TEST DE LA FONCTION editeurTrierByTitreASC
SET serveroutput ON;

DECLARE
	listeOuvrages pk_editeur.refCursorType;
	ligneOuvrage editeur%rowtype;
	nbOuvrage number:= 0;

BEGIN
	listeOuvrages:= pk_editeur.editeurTrierByTitreASC();

	LOOP 
		FETCH listeOuvrages INTO ligneOuvrage;
		EXIT WHEN listeOuvrages%notfound;
		nbOuvrage := nbOuvrage + 1;
		
		-- Affichier les informations sur le pilote extrait du curseur
		DBMS_OUTPUT.PUT_LINE('ISBN de l''ouvrage                       ='|| ligneOuvrage.ISBN);
		DBMS_OUTPUT.PUT_LINE('Titre de l''ouvrage                      ='|| ligneOuvrage.Titre); 
		DBMS_OUTPUT.PUT_LINE('Année de parution de l''ouvrage          ='|| ligneOuvrage.Annee_de_parution); 
		DBMS_OUTPUT.PUT_LINE('Langue de l''ouvrage                     ='|| ligneOuvrage.Langue);
		DBMS_OUTPUT.PUT_LINE('Format de l''ouvrage                     ='|| ligneOuvrage.Format);
		DBMS_OUTPUT.PUT_LINE('Edition de l''ouvrage                    ='|| ligneOuvrage.Edition);
		DBMS_OUTPUT.PUT_LINE('Description de l''ouvrage                ='|| ligneOuvrage.Description);
		DBMS_OUTPUT.PUT_LINE('Couverture de l''ouvrage                 ='|| ligneOuvrage.Couverture);
		DBMS_OUTPUT.PUT_LINE('Encours de l''ouvrage                    ='|| ligneOuvrage.Encours);	

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





-- TEST DE LA FONCTION editeurTrierByTitreDESC
SET serveroutput ON;

DECLARE
	listeOuvrages pk_editeur.refCursorType;
	ligneOuvrage editeur%rowtype;
	nbOuvrage number:= 0;
	
BEGIN
	listeOuvrages:= pk_editeur.editeurTrierByTitreDESC() ;

	LOOP 
		FETCH listeOuvrages INTO ligneOuvrage;
		EXIT WHEN listeOuvrages%notfound;
		nbOuvrage := nbOuvrage + 1;
		
		-- Affichier les informations sur le pilote extrait du curseur
		DBMS_OUTPUT.PUT_LINE('ISBN de l''ouvrage                       ='|| ligneOuvrage.ISBN);
		DBMS_OUTPUT.PUT_LINE('Titre de l''ouvrage                      ='|| ligneOuvrage.Titre); 
		DBMS_OUTPUT.PUT_LINE('Année de parution de l''ouvrage          ='|| ligneOuvrage.Annee_de_parution); 
		DBMS_OUTPUT.PUT_LINE('Langue de l''ouvrage                     ='|| ligneOuvrage.Langue);
		DBMS_OUTPUT.PUT_LINE('Format de l''ouvrage                     ='|| ligneOuvrage.Format);
		DBMS_OUTPUT.PUT_LINE('Edition de l''ouvrage                    ='|| ligneOuvrage.Edition);
		DBMS_OUTPUT.PUT_LINE('Description de l''ouvrage                ='|| ligneOuvrage.Description);
		DBMS_OUTPUT.PUT_LINE('Couverture de l''ouvrage                 ='|| ligneOuvrage.Couverture);
		DBMS_OUTPUT.PUT_LINE('Encours de l''ouvrage                    ='|| ligneOuvrage.Encours);	

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