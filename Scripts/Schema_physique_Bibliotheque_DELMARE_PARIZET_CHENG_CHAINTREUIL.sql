---------------------------------------------------------------
--        Script Oracle.  
---------------------------------------------------------------

------------------------------------------------------------
-- Table: Auteur
------------------------------------------------------------
CREATE TABLE Auteur(
	ID NUMBER NOT NULL,
	Nom VARCHAR2 (32) NOT NULL,
	Prenom VARCHAR2 (32) NOT NULL,
	Date_de_naissance DATE NOT NULL,
	Nationalite VARCHAR2 (32) NOT NULL,
	Bio CLOB,
	CONSTRAINT Auteur_PK PRIMARY KEY (ID)
);

------------------------------------------------------------
-- Table: Éditeur
------------------------------------------------------------
CREATE TABLE Editeur(
	Nom VARCHAR2 (32) NOT NULL,
	Telephone VARCHAR2 (32),
	Email VARCHAR2 (64),
	Adresse VARCHAR2 (256),
	CONSTRAINT Editeur_PK PRIMARY KEY (Nom)
);

------------------------------------------------------------
-- Table: Adhérent
------------------------------------------------------------
CREATE TABLE Adherent(
	ID NUMBER NOT NULL,
	Nom VARCHAR2 (32) NOT NULL,
	Prenom VARCHAR2 (32) NOT NULL,
	Date_de_naissance DATE NOT NULL,
	Telephone VARCHAR2 (32) NOT NULL,
	Email VARCHAR2 (64) NOT NULL,
	Adresse VARCHAR2 (256) NOT NULL,
	CONSTRAINT Adherent_PK PRIMARY KEY (ID)
);

------------------------------------------------------------
-- Table: Bibliothécaire
------------------------------------------------------------
CREATE TABLE Bibliothecaire(
	ID NUMBER NOT NULL,
	Nom VARCHAR2 (32) NOT NULL,
	Prenom VARCHAR2 (32) NOT NULL,
	Date_de_naissance DATE NOT NULL,
	Telephone VARCHAR2 (32) NOT NULL,
	Email VARCHAR2 (64) NOT NULL,
	Adresse VARCHAR2 (256) NOT NULL,
	CONSTRAINT Bibliothecaire_PK PRIMARY KEY (ID)
);

------------------------------------------------------------
-- Table: Classification
------------------------------------------------------------
CREATE TABLE Classification(
	Tag VARCHAR2 (16) NOT NULL,
	Libelle VARCHAR2 (256) NOT NULL,
	CONSTRAINT Classification_PK PRIMARY KEY (Tag)
);

------------------------------------------------------------
-- Table: Ouvrage
------------------------------------------------------------
CREATE TABLE Ouvrage(
	ISBN NUMBER(32, 0) NOT NULL,
	Titre VARCHAR2 (256) NOT NULL,
	Annee_de_parution NUMBER(4, 0),
	Langue VARCHAR2 (32) NOT NULL,
	Format VARCHAR2 (32) NOT NULL CONSTRAINT ouvrage_check_format CHECK (
		Format IN ('Broché', 'Relié', 'Poche', 'Numérique', 'Audio')
	),
	Edition NUMBER(10, 0) NOT NULL,
	Description CLOB,
	Couverture BLOB,
	Encours NUMBER(10, 0) NOT NULL,
	Tag VARCHAR2 (16) NOT NULL,
	Nom_Editeur VARCHAR2 (32) NOT NULL,
	CONSTRAINT Ouvrage_PK PRIMARY KEY (ISBN),
	CONSTRAINT Ouvrage_Classification_FK FOREIGN KEY (Tag) REFERENCES Classification(Tag),
	CONSTRAINT Ouvrage_Éditeur0_FK FOREIGN KEY (Nom_Editeur) REFERENCES Editeur(Nom),
	CONSTRAINT Emprunt_Not_Zero CHECK (Encours >= 0)
);

------------------------------------------------------------
-- Table: Emprunt
------------------------------------------------------------
CREATE TABLE Emprunt(
	ID_Adherent NUMBER(10, 0) NOT NULL,
	ID_Bibliothecaire NUMBER(10, 0) NOT NULL,
	ISBN NUMBER(32, 0) NOT NULL,
	Date_de_debut DATE NOT NULL,
	Date_de_fin DATE,
	Rendu NUMBER (1) NOT NULL,
	CONSTRAINT Emprunt_PK PRIMARY KEY (
		ID_Adherent,
		ID_Bibliothecaire,
		ISBN,
		Date_de_debut
	),
	CONSTRAINT CHK_BOOLEAN_Rendu CHECK (Rendu IN (0, 1)),
	CONSTRAINT Emprunt_Adherent_FK FOREIGN KEY (ID_Adherent) REFERENCES Adherent(ID) ON DELETE CASCADE,
	CONSTRAINT Emprunt_Bibliothecaire0_FK FOREIGN KEY (ID_Bibliothecaire) REFERENCES Bibliothecaire(ID) ON DELETE CASCADE,
	CONSTRAINT Emprunt_Ouvrage1_FK FOREIGN KEY (ISBN) REFERENCES Ouvrage(ISBN) ON DELETE CASCADE
);

------------------------------------------------------------
-- Table: Réalise
------------------------------------------------------------
CREATE TABLE Realise(
	ISBN NUMBER(32, 0) NOT NULL,
	ID_Auteur NUMBER(10, 0) NOT NULL,
	Role VARCHAR2 (32) NOT NULL CONSTRAINT realise_check_role CHECK (Role IN ('ecrire', 'illustrer', 'participer')),
	CONSTRAINT Realise_PK PRIMARY KEY (ISBN, ID_Auteur),
	CONSTRAINT Realise_Ouvrage_FK FOREIGN KEY (ISBN) REFERENCES Ouvrage(ISBN) ON DELETE CASCADE,
	CONSTRAINT Realise_Auteur0_FK FOREIGN KEY (ID_Auteur) REFERENCES Auteur(ID) ON DELETE CASCADE
);


--CREATION DES TRIGGERS
CREATE SEQUENCE Seq_Adherent_ID START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE Seq_Bibliothecaire_ID START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE Seq_Autheur_ID START WITH 1 INCREMENT BY 1 NOCYCLE;

CREATE OR REPLACE TRIGGER Adherent_ID BEFORE
INSERT ON Adherent FOR EACH ROW
	WHEN (NEW.ID IS NULL) BEGIN
select Seq_Adherent_ID.NEXTVAL INTO :NEW.ID
from DUAL;
END;
/

CREATE OR REPLACE TRIGGER Bibliothecaire_ID BEFORE
INSERT ON Bibliothecaire FOR EACH ROW
	WHEN (NEW.ID IS NULL) BEGIN
select Seq_Bibliothecaire_ID.NEXTVAL INTO :NEW.ID
from DUAL;
END;
/

CREATE OR REPLACE TRIGGER Auteur_ID BEFORE
INSERT ON Auteur FOR EACH ROW
	WHEN (NEW.ID IS NULL) BEGIN
select Seq_Autheur_ID.NEXTVAL INTO :NEW.ID
from DUAL;
END;
/

CREATE OR REPLACE TRIGGER new_emprunt BEFORE
INSERT ON emprunt FOR EACH ROW
DECLARE BEGIN --indication date de fin (théorique)
	:NEW.date_de_fin := :NEW.date_de_debut + INTERVAL '14' DAY;
--update ouvrage.Encours
UPDATE ouvrage
SET encours = encours -1
WHERE ISBN =: NEW.ISBN;
END;
/

CREATE OR REPLACE TRIGGER retour_emprunt BEFORE
UPDATE ON Emprunt FOR EACH ROW BEGIN IF: NEW.rendu = 1 THEN --indication date de rendu ( = edit date de fin)
	:NEW.date_de_fin := sysdate;
-- update encours
UPDATE ouvrage
SET encours = encours + 1
WHERE ISBN =: NEW.ISBN;
END IF;
END;
/