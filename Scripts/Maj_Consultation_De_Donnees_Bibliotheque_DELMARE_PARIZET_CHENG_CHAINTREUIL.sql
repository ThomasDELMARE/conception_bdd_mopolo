--La description textuelles des requêtes de consultation 
--(5 requêtes impliquant 1 table dont 1 avec un group By et une avec un Order By, 
-- 5 requêtes impliquant 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri,
-- 5 requêtes impliquant plus de 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri)



-- 5 requêtes impliquant 1 table dont 1 avec un group By 
--et une avec un Order By


-- Pour chaque classification, afficher les ouvrages avec son titre, sa description,  
-- sa couverture, son année de parution dont la langue n'est pas anglais
select titre, description, couverture, annee_de_parution
from ouvrage
where langue != 'Anglais';

-- Afficher le titre, la description, la couverture, l'édition des ouvrages 
-- par année de parution décroissante
select titre, description, couverture, edition, annee_de_parution
from ouvrage
order by annee_de_parution DESC;

-- Quels sont les bibliothecaires qui ont un nom dont le début se prononce "KAL" ? 
select *
from bibliothecaire
where SOUNDEX(nom) = SOUNDEX('CAL');

-- Afficher les ouvrages qui sont empruntés
select *
from emprunt
where rendu = 0;
	
-- Quels sont les adhérents de moins de 30 ans ?
SELECT ADHERENT.*,  ROUND((SYSDATE - date_de_naissance)/365) AS age
FROM ADHERENT
WHERE ROUND((SYSDATE - date_de_naissance)/365) < 30;


-- Afficher la liste des ouvrages ayant était validé dans un emprunt 
-- par le personnel dont l'id est 2
select o.*
from ouvrage o
inner join emprunt e ON o.ISBN = e.ISBN
where e.ID_bibliothecaire = 2;

-- Afficher la liste des bibliothecaires ayant validé un emprunt le 2 juillet 2003
select b.*
from bibliothecaire b
inner join emprunt e on b.id = e.id_bibliothecaire
where e.date_de_debut = to_date('10/05/21','DD/MM/YY');

-- Donner le nombre de livres réalisés par auteur (id)et les trier par ordre decroissant 
select r.id_auteur, count(o.titre) as NombreLivres
from ouvrage o
RIGHT JOIN realise r ON o.ISBN = r.ISBN
group by r.id_auteur
order by NombreLivres DESC;

-- Selectionner le titre, la description, le format et la langue des ouvrages 
-- qui sont empruntés et dont la langue est française ou espagnole
select titre, description, format, langue, e.ISBN
from ouvrage o
left join emprunt e ON o.ISBN = e.ISBN
where langue = 'Française' or langue = 'Espagnole'
order by titre ASC;

-- la liste des livres dont l'éditeur est 'Hachette' et qui est emprunté
select *
from ouvrage o 
inner join emprunt e on o.ISBN = e.ISBN
where nom_editeur = 'Hachette' and rendu = 0;



-- afficher toutes les informations des auteurs dont les ouvrages sont actuellement empruntés
select a.*
from realise r 
inner join ouvrage o on r.ISBN = o.ISBN
inner join emprunt e on o.ISBN = e.ISBN
inner join auteur a on r.id_auteur = a.id
where e.rendu = 0;

-- trouver les adhérents qui ont le même nom qu'un auteur
select ad.*
from adherent ad
inner join emprunt e on ad.id = e.id_adherent
inner join ouvrage o on e.ISBN = o.ISBN
inner join realise r on o.ISBN = r.ISBN
inner join auteur a on r.id_auteur = a.id
where ad.nom = a.nom
order by ad.nom;

-- afficher les emprunts , les titres d'ouvrages et les noms et prénoms des bibliothecaires qui ont validé un emprunt le 5 mai 2020
select b.nom, b.prenom, e.*, o.titre
from emprunt e
left join bibliothecaire b on e.ID_bibliothecaire = b.ID
inner join ouvrage o on e.ISBN = o.ISBN
where TO_DATE(date_de_debut, 'DD-MM-YYYY') = TO_DATE(sysdate,'DD-MM-YYYY');

-- Affichez le titre et l'auteur des ouvrages empruntés ainsi que du nom de son adhérent ayant l'ouvrage
select o.titre, r.id_auteur, ad.nom
from ouvrage o
inner join emprunt e on o.ISBN = e.ISBN
left join adherent ad on e.ID_adherent = ad.ID
right join realise r on o.ISBN = r.ISBN
where e.rendu = 0
order by o.titre;



-- Nombre de livre par auteur
SELECT a.nom, COUNT(r.id_auteur) as nbLivre
FROM auteur a INNER JOIN realise r ON a.id = r.id_auteur
GROUP BY a.nom;

--Les livres qui n'ont pas été empruntés
SELECT ouvrage.ISBN, emprunt.ISBN AS valid
FROM ouvrage LEFT JOIN emprunt ON ouvrage.ISBN = emprunt.ISBN
WHERE emprunt.ISBN IS NULL
ORDER BY ouvrage.ISBN ASC;

--les bibliothecaires ayant validé un emprunt
SELECT DISTINCT Bibliothecaire.*
FROM bibliothecaire RIGHT JOIN emprunt ON emprunt.id_bibliothecaire = bibliothecaire.id;


--- Requêtes de supression
-- 1 Table

-- Suppression d'un adhérent via son ID
DELETE FROM ADHERENT WHERE ID = 11;
-- Suppression d'un ouvrage via son ISBN
DELETE FROM OUVRAGE WHERE ISBN = 9781470887131;

-- 2 Table
-- Suppression des adhérents n'ayant jamais emprunté
DELETE FROM ADHERENT WHERE ID NOT IN (
    SELECT ID_Adherent FROM EMPRUNT);
-- Suppression des ouvrages de la classification Esthétique
DELETE FROM OUVRAGE WHERE TAG IN (
    SELECT TAG FROM CLASSIFICATION WHERE LIBELLE = 'Esthétique');

-- 3 Table
-- Suppression de tout les ouvrages d'un auteur
DELETE FROM OUVRAGE WHERE ISBN IN (
    SELECT ISBN FROM REALISE WHERE ID_AUTEUR IN (
        SELECT ID FROM AUTEUR WHERE UPPER(NOM) = 'HUGO' AND UPPER(PRENOM) = 'VICTOR'));


-- Requête de mise à jour
-- 1 Table

-- Mise à jour du numéro de téléphone d'un adhérent
UPDATE ADHERENT
SET TELEPHONE = '0663377889'
WHERE ID = 1;

-- Mise à jour de la biographie de Victor Hugo
UPDATE AUTEUR
SET BIO = 'Lorem Ipsum Sit Dolor Amet'
WHERE UPPER(NOM) = 'HUGO' AND UPPER(PRENOM) = 'VICTOR';

-- 2 Table

-- Un adhérent du nom de 'Hunt' rend tout ses livres
UPDATE Emprunt
SET Rendu = 1
WHERE Emprunt.ID_Adherent IN
    (
        SELECT ID
        FROM ADHERENT
        WHERE NOM = 'Hunt');

-- Tout les ouvrages nommés 'Les Misérables' sont rendus
UPDATE emprunt
SET Rendu = 1
WHERE emprunt.ISBN IN
    (
        SELECT ISBN
        FROM OUVRAGE
        WHERE Titre = 'Les Misérables');
        
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