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



-- 5 requêtes impliquant 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri


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

-- Donner le nombre de livres réalisés par auteur et les trier par ordre decroissant 
select r.nom, count(o.titre) as NombreLivres
from ouvrage o
RIGHT JOIN realise r ON o.ISBN = r.ISBN
group by r.nom
order by NombreLivres DESC;


-- Selectionner le titre, la description, le format et la langue des ouvrages 
-- qui sont empruntés et dont la langue est français ou anglais
select titre, description, format, langue, ISBN
left join emprunt e ON o.ISBN = e.ISBN
where langue = "Français" or langue = "Anglais"
order by titre ASC;

-- le nombre d'emprunts des livres dont l'éditeur est 'Larousse' 
select o.*, count(e.id) as NombreDeLivres
from emprunt e
inner join ouvrage o on e.ISBN = o.ISBN
where nom_editeur = 'Larousse'
group by titre;



-- 5 requêtes impliquant plus de 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri)


-- afficher toutes les informations des auteurs dont les ouvrages sont actuellement empruntés
select r.*
from realise r 
inner join ouvrage o on r.ISBN = o.ISBN
inner join emprunt e on o.ISBN = e.ISBN
where e.rendu = 0;
group by r.nom

-- trouver les adhérents qui ont le même nom qu'un auteur
select ad.*
from adherent ad
inner join emprunt e on ad.id = e.id
inner join ouvrage o on e.ISBN = o.ISBN
inner join realise r on o.ISBN = r.ISBN;
where ad.nom = a.nom
order by ad.nom;

-- afficher les emprunts , les titres d'ouvrages et les noms et prénoms des bibliothecaires qui ont validé un emprunt le 5 mai 2020
select b.nom, b.prenom, e.*, o.titre
from emprunt e
left join bibliothecaire b on e.ID_bibliothecaire = b.ID
inner join ouvrage o on e.ISBN = o.ISBN
where date_de_debut = '2020/10/05'
group by b.nom;

-- Affichez le titre et l'auteur des ouvrages empruntés ainsi que du nom de son adhérent ayant l'ouvrage
select o.titre, r.nom, ad.nom
from ouvrage o , auteurs, emprunteurs, emprunts
inner join emprunt e on o.ISBN = e.ISBN
left join adherent ad on e.ID = ad.ID
right join realise r on o.ISBN = r.ISBN
where e.rendu = 0
order by o.titre;

-- Afficher les livres qui ont été emprunté au moins 2 fois, ayant pour l'éditeur Hachette et afficher le nom de l'auteur
select o.titre, count(o.titre), r.nom
from emprunt e
inner join ouvrage o on e.ISBN = o.ISBN
left join realise r on o.nom = r.nom
where o.nom = 'Hachette'
group by o.titre
having count(o.titre)>2;


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

-- Mise à jour du numéro de téléphone d'un adhérent ayant l'ID 1
UPDATE ADHERENT
SET TELEPHONE = '0663377889'
WHERE ID = 1;

-- Mise à jour de la biographie de l'auteur Victor Hugo
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

-- Tout les ouvrages nommées 'Les Misérables' de l'éditeur 'Galliamard' sont rendus
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