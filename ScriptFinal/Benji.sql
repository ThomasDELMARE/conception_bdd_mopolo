-- Suppression d'un adhérent
DELETE FROM ADHERENT WHERE ADHID = 11;

-- Suppression d'un ouvrage
DELETE FROM BOOK WHERE ISBN = 9781470887131;

--- 2 Table
-- Suppression des adhérents n'ayant jamais emprunté
DELETE FROM ADHERENT WHERE ADHID NOT IN (
    SELECT ADHID FROM EMPRUNT);

-- Suppression des ouvrages de la catégorie Esthétique
DELETE BOOK WHERE TAG IN (
    SELECT TAG FROM TYPE WHERE TAGDESC = 'Esthétique');

--- 3 Table
-- Suppression de tout les ouvrages d'un auteur
DELETE FROM BOOK WHERE ISBN IN (
    SELECT ISBN FROM RÉALISE WHERE AUTID IN (
        SELECT AUTID FROM AUTHOR WHERE UPPER(AUTNAME) = 'HUGO' AND UPPER(AUTSURNAME) = 'VICTOR'));

--- Mise à jour ---

-- 1 Table
-- Mise à jour du numéro de téléphone d'un adhérent
UPDATE ADHERENT
SET ADHPHONE = '0663377889'
WHERE ADHID = 1;

-- Mise à jour de la biographie de Victor Hugo
UPDATE AUTHOR
SET AUTBIO = 'Lorem Ipsum Sit Dolor Amet'
WHERE UPPER(AUTNAME) = 'HUGO' AND UPPER(AUTSURNAME) = 'VICTOR';

-- 2 Table

-- Un adhérent rend tout ses livres
UPDATE Emprunt
SET Rendu = 1
WHERE Emprunt.ADHID IN
    (
        SELECT ADHID
        FROM adherent
        WHERE ADHNAME = 'Hunt');

-- Tout les ouvrages nommés 'Les Misérables' sont rendus
UPDATE emprunt
SET ISBACK = 1
WHERE emprunt.ISBN IN
    (
        SELECT ISBN
        FROM BOOK
        WHERE TITLE = 'Les Misérables');
        
--- 3 Table
UPDATE emprunt
SET Rendu = 1
WHERE emprunt.ISBN IN
    (
        SELECT ISBN
        FROM ouvrage 
        WHERE titre = 'Les Misérables' AND ouvrage.nom_editeur IN 
        (
            SELECT nom
            FROM editeur
            WHERE nom = 'Galliamard'
        ));