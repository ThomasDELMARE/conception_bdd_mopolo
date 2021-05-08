/* SELECTION */


-- infos sur l'ouvrage d'isbn = 5
SELECT * 
FROM ouvrage
WHERE isbn = 5;


-- informations sur la classification P
SELECT *
FROM classification
WHERE id_classification LIKE "P";


-- liste des ouvrage ayant était validé dans une commande par le personnel nb 2
SELECT o.*
FROM ouvrage o INNER JOIN emprunter e ON o.isbn = e.isbn
INNER JOIN commande c ON e.num = c.num
WHERE c.id_personne = 2;


