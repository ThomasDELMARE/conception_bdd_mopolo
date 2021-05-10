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
WHERE age < 30;



-- 5 requêtes impliquant 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri


-- Afficher la liste des ouvrages ayant était validé dans un emprunt 
-- par le personnel dont l'id est 2
select o.*
from ouvrage o
inner join emprunt e ON o.ISBN = e.ISBN
where e.ID_bibliothecaire = 2;

-- Afficher la liste des bibliothecaires ayant validé un emprunt le 10 mai 2021
select b.*
from bibliothecaire b
inner join emprunt e on b.id = e.id_bibliothecaire
where TO_DATE(e.date_de_debut, 'DD-MM-YYYY') =  TO_DATE(sysdate, 'DD-MM-YYYY');

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

-- le nombre d'emprunts des livres dont l'éditeur est 'Larousse' 
select o.*, count(e.id_adherent) as NombreDeLivres
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
inner join auteur a on r.id_auteur = a.id
where e.rendu = 0;
group by r.id_auteur

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
where TO_DATE(date_de_debut, 'DD-MM-YYYY') = TO_DATE('2020/10/05','DD-MM-YYYY')
group by b.nom;

-- Affichez le titre et l'auteur des ouvrages empruntés ainsi que du nom de son adhérent ayant l'ouvrage
select o.titre, r.id_auteur, ad.nom
from ouvrage o
inner join emprunt e on o.ISBN = e.ISBN
left join adherent ad on e.ID_adherent = ad.ID
right join realise r on o.ISBN = r.ISBN
where e.rendu = 0
order by o.titre;

-- Afficher les livres qui ont été emprunté au moins 2 fois, ayant pour l'éditeur Hachette et afficher le nom de l'auteur
select o.titre, count(o.titre), a.nom
from emprunt e
inner join ouvrage o on e.ISBN = o.ISBN
inner join realise r on o.ISBN = r.ISBN
left join auteur a on r.id_auteur = a.id
where o.nom_editeur = 'Hachette'
group by o.titre
having count(o.titre)>2;