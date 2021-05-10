/*

TABLE B --> Ouvrage

- Ajouter une nouvelle occurence --> OuvrageInserer
- Supprimer une occurence --> OuvrageSupprimer
- (2) Fonctions de modification d'informations --> OuvrageModifierLangueByISBN, OuvrageModifierFormatByISBN
- Lister toutes les occurences de B pour une occurence de A donnée --> 

*/

create or replace package pk_Ouvrage IS

TYPE refcursorType IS REF CURSOR;

no_data_updated EXCEPTION;
pragma exception_init(no_data_updated, -20001);

mess  varchar2(1000);

procedure OuvrageInserer(Ouvrage IN Ouvrage%rowtype);

procedure OuvrageSupprimer(biblioId IN number);

procedure OuvrageModifierLangueByISBN(ISBN IN number, nouvelleLangue IN varchar2);

procedure OuvrageModifierFormatByISBN(ISBN IN number, nouveauFormat IN varchar2);

function OuvrageLister()return pk_bibliothecaire.refcursorType;