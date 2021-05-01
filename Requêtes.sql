/* SELECTION */

SELECT ouvrage.* 
FROM ouvrage INNER JOIN emprunter ON ouvrage.isbn = emprunter.isbn
WHERE ouvrage.isbn = 5;

SELECT *
FROM classification
WHERE id_classification = 