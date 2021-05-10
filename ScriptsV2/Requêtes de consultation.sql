--La description textuelles des requêtes de consultation 
--(5 requêtes impliquant 1 table dont 1 avec un group By et une avec un Order By, 
-- 5 requêtes impliquant 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri,
-- 5 requêtes impliquant plus de 2 tables avec jointures internes dont 1 externe + 1 group by + 1 tri)



-- 5 requêtes impliquant 1 table dont 1 avec un group By et une avec un Order By


-- Pour chaque classification, afficher les ouvrages avec son titre, sa description, sa couverture, 
-- son année de parution dont la langue n'est pas anglais
select titre, description, couverture, annee_de_parution, tag
from ouvrage
where langue != "anglais"
group by tag;

-- Afficher le titre, la description, la couverture, l'édition des ouvrages par année de parution décroissante
select titre, description, couverture, edition, annee_de_parution
from ouvrage
order by annee_de_parution DESC;

-- Quels sont les bibliothecaires qui ont un nom qui termine par un "I" ou dont le début se prononce "GO" ? 
select *
from bibliothecaire
where nom LIKE '%I' 
	OR SOUNDEX(nom) = SOUNDEX('GO');

-- Afficher les ouvrages qui sont empruntés
select *
from emprunt
where rendu = FALSE;
	
-- Quels sont les adhérents de moins de 30 ans ?
select *, datediff(YY,date_de_naissance,getdate()) as age
from adherent
where age < 30;












