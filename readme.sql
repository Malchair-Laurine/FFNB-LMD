#1. Afficher toutes les localités et codes postaux disponibles.

SELECT localite, code_postal
FROM code_postaux;

#2. Lister tous les secrétaires avec leur nom, prénom et la localité où ils travaillent.

SELECT nom, prenom, code_postaux.localite
FROM secretariats
         INNER JOIN code_postaux ON secretariats.code_postal = code_postaux.code_postal;

#3. Afficher tous les clubs et le nombre de nageurs inscrits dans chaque club.

SELECT clubs.code_club, COALESCE(clubs.nom, '??') AS 'Nom club', COUNT(nageurs.nr_ligue) AS 'Nombre de nageur'
FROM nageurs
         INNER JOIN clubs ON nageurs.code_club = clubs.code_club
GROUP BY clubs.code_club;

#4. Rechercher le nom et le prénom des nageurs appartenant aux catégories d'âge de moins de 35 ans qui ont toujours spécifié un temps de référence à la première journée de la deuxième compétition de 2003.

SELECT nageurs.nom, prenom, categories.lib_categorie, resultats.temps_reference
FROM nageurs
         INNER JOIN categories ON nageurs.code_categorie = categories.code_categorie
         INNER JOIN resultats ON resultats.nr_ligue = nageurs.nr_ligue
WHERE categories.age_min < 35
  AND temps_reference IS NOT NULL
  AND annee = 2003
  AND jour = 1
  AND id_competition = 1;


#5. Lister les nageurs avec leur nom, prénom, sexe et la catégorie à laquelle ils appartiennent

SELECT nom, prenom, sexe, categories.code_categorie
FROM nageurs
         INNER JOIN categories ON categories.code_categorie = nageurs.code_categorie;

#6. Afficher toutes les piscines avec leur nom, adresse et nombre de couloirs.

SELECT nom, adresse, nb_couloirs
FROM piscines;

#7. Lister toutes les compétitions avec leur identifiant et leur libellé.

SELECT id_competition, libelle
FROM competitions;

#8. Afficher tous les juges avec le nom du club auquel ils sont affiliés.

SELECT juges.nom, clubs.nom
FROM juges
         INNER JOIN clubs ON juges.code_club = clubs.code_club;

#9. Lister toutes les journées de compétition avec la date, l’heure de la compétition et le nom de la piscine.

SELECT competitions.libelle, date_heure_competition, piscines.nom
FROM journees
         INNER JOIN piscines ON piscines.id_piscine = journees.id_piscine
         INNER JOIN competitions ON competitions.id_competition = journees.id_competition;

#10. Afficher le planning d’une journée spécifique d’une compétition, avec le numéro de course et le libellé de la course.

SELECT journees.jour, planning.nr_course, planning.libelle
FROM journees
         INNER JOIN planning ON planning.id_competition = journees.id_competition
WHERE journees.id_competition = 1
  AND journees.jour = 3;

#11. Lister tous les résultats d’une compétition pour un nageur spécifique, avec son temps réel et sa place.

SELECT nageurs.nom, competitions.libelle, temps_reel, place
FROM resultats
         INNER JOIN competitions ON resultats.id_competition = competitions.id_competition
         INNER JOIN nageurs ON nageurs.nr_ligue = resultats.nr_ligue
WHERE nageurs.nom LIKE 'stooker'
  AND nageurs.prenom LIKE 'Annie'
  AND competitions.libelle LIKE 'Challenge Jean-Baptiste Evrard';

#12. Afficher le nombre total de nageurs par club, avec le nom du club, trié par ordre décroissant.

SELECT COALESCE(clubs.nom, clubs.code_club) AS 'Nom club', clubs.code_club, COUNT(nr_ligue) AS 'Nb total nageurs'
FROM nageurs
         INNER JOIN clubs ON clubs.code_club = nageurs.code_club
GROUP BY clubs.nom, clubs.code_club
ORDER BY 3 DESC;

#13. Lister les nageurs avec le nom de leur club et de leur catégorie.

SELECT nageurs.nom, prenom, clubs.nom, categories.code_categorie
FROM nageurs
         INNER JOIN clubs ON nageurs.code_club = clubs.code_club
         INNER JOIN categories ON nageurs.code_categorie = categories.code_categorie;

#14. Afficher le nombre de compétitions organisées par chaque secrétariat, avec le nom et prénom du secrétaire.

SELECT libelle, secretariats.prenom, secretariats.nom, id_secretariat, COUNT(DISTINCT competitions.id_competition)
FROM competitions
         INNER JOIN organisateurs ON organisateurs.id_competition = competitions.id_competition
         INNER JOIN secretariats ON organisateurs.id_secretariat = secretariats.id_secretaire
GROUP BY libelle, secretariats.prenom, secretariats.nom, id_secretariat;

#15. Lister toutes les piscines et le nombre de journées de compétition prévues dans chacune, trié par nombre de journées décroissant.

SELECT nom, piscines.id_piscine, COUNT(journees.id_piscine)
FROM piscines
         INNER JOIN journees ON piscines.id_piscine = journees.id_piscine
         INNER JOIN organisateurs ON journees.id_competition = organisateurs.id_competition
GROUP BY nom, piscines.id_piscine
ORDER BY 3 DESC;

#16. Afficher les nageurs qui n’ont participé à aucune compétition.

SELECT nageurs.nom, prenom
FROM nageurs
WHERE nr_ligue NOT IN (SELECT nr_ligue FROM resultats);

#17. Lister toutes les journées d’une compétition donnée, avec le nom de la piscine et le nom du juge responsable.

SELECT jour, piscines.nom, juges.nom
FROM journees
         INNER JOIN piscines ON piscines.id_piscine = journees.id_piscine
         INNER JOIN juges ON juges.id_juge = journees.id_juge
         INNER JOIN competitions ON competitions.id_competition = journees.id_competition
WHERE competitions.libelle LIKE 'Championnat de belgique de natation';

#18. Afficher pour chaque année de compétition le nombre total de courses prévues dans le planning.

SELECT planning.id_competition, competitions.libelle, planning.annee, COUNT(*)
FROM competitions
         INNER JOIN organisateurs ON competitions.id_competition = organisateurs.id_competition
         INNER JOIN planning
                    ON planning.id_competition = organisateurs.id_competition AND planning.annee = organisateurs.annee
GROUP BY planning.id_competition, competitions.libelle, planning.annee;

#19. Lister les résultats d’un nageur donné, avec le libellé de la course et la place obtenue, triés par date de la journée.

SELECT temps_reel, place, distance, planning.libelle, competitions.libelle, planning.annee, date_heure_competition
FROM nageurs
         INNER JOIN resultats ON resultats.nr_ligue = nageurs.nr_ligue
         INNER JOIN planning ON planning.jour = resultats.jour
    AND planning.annee = resultats.annee
    AND planning.id_competition = resultats.id_competition
    AND planning.nr_course = resultats.nr_course
         INNER JOIN competitions ON competitions.id_competition = resultats.id_competition
         INNER JOIN journees ON journees.id_competition = planning.id_competition
    AND journees.jour = planning.jour
    AND journees.annee = planning.annee
WHERE nom LIKE 'Leroy'
  AND prenom LIKE 'Bruno'
ORDER BY date_heure_competition;

#20. Afficher le nombre de nageurs par catégorie, avec la catégorie et la tranche d’âge correspondante.

SELECT lib_categorie, code_categorie, COUNT(nageurs.nr_ligue)
FROM nageurs
         NATURAL JOIN categories
GROUP BY lib_categorie, code_categorie;

#21. Lister les clubs et le nom du secrétaire responsable, pour tous les clubs ayant plus de 10 nageurs inscrits.

SELECT clubs.nom, secretariats.prenom, secretariats.nom, clubs.code_club, COUNT(nr_ligue)
FROM clubs
         INNER JOIN secretariats ON clubs.id_secretariat = secretariats.id_secretaire
         INNER JOIN nageurs ON clubs.code_club = nageurs.code_club
GROUP BY clubs.nom, secretariats.prenom, secretariats.nom, clubs.code_club
HAVING COUNT(nr_ligue) > 10;

#22. Rechercher le nom et le prénom des nageurs appartenant aux catégories d'âge de moins de 35 ans qui n’ont jamais spécifié un temps de référence à la première journée de la deuxième compétition de 2003.

SELECT nom, prenom, lib_categorie, planning.id_competition, planning.annee, date_heure_competition
FROM nageurs
         NATURAL JOIN categories
         INNER JOIN resultats ON nageurs.nr_ligue = resultats.nr_ligue
         INNER JOIN planning ON resultats.annee = planning.annee
    AND resultats.jour = planning.jour
    AND resultats.id_competition = planning.id_competition
         INNER JOIN journees ON planning.jour = journees.jour
    AND planning.annee = journees.annee
    AND planning.id_competition = journees.id_competition
WHERE age_max < 35
  AND temps_reference IS NULL
  AND planning.jour = 1
  AND journees.id_competition = 1;

#23. Afficher le nom, la localité, la longueur et le nombre de couloirs de la piscine dans laquelle ont été organisées le plus de journées de compétition.

SELECT id_piscine, nom, localite, longueur, nb_couloirs, COUNT(*)
FROM piscines
         NATURAL JOIN code_postaux
         NATURAL JOIN journees
GROUP BY id_piscine, nom, localite, longueur, nb_couloirs
ORDER BY 6 DESC
LIMIT 1;

#24. Rechercher la date et le nom de la compétition qui a organisé au moins 10 courses sur une même journée

SELECT journees.id_competition, competitions.libelle, date_heure_competition, planning.jour, COUNT(*)
FROM competitions
         INNER JOIN journees ON journees.id_competition = competitions.id_competition
         INNER JOIN planning ON journees.id_competition = planning.id_competition
    AND journees.jour = planning.jour
    AND journees.annee = planning.annee
GROUP BY journees.id_competition, planning.jour, journees.annee
HAVING COUNT(*) >= 10;

#25. Rechercher le jour de compétition qui a commencé le plus tard. On précisera le libellé de la compétition, l'année, le jour, la date et l'heure du début de la compétition.

SELECT competitions.libelle, date_heure_competition, journees.jour, annee
FROM competitions
         INNER JOIN journees ON competitions.id_competition = journees.id_competition
ORDER BY EXTRACT(HOUR FROM date_heure_competition) DESC
LIMIT 1;

#26. Rechercher les numéro de ligue, nom, prénom, sexe, année de naissance, total des points du nageur qui a obtenu le plus de points sur toutes les compétitions.

SELECT nageurs.nr_ligue, nom, prenom, sexe, SUM(points)
FROM nageurs
         INNER JOIN resultats ON nageurs.nr_ligue = resultats.nr_ligue
GROUP BY nageurs.nr_ligue
ORDER BY SUM(points) DESC
LIMIT 1;

#27. Rechercher le numéro de ligue, le nom, le prénom et le nom du club des nageurs qui n'ont jamais été classés parmi les 10 premiers à aucune des courses auxquelles ils ont participé.

SELECT nageurs.nr_ligue, nageurs.nom, nageurs.prenom, clubs.nom, MIN(place) AS 'min points'
FROM nageurs
         INNER JOIN clubs ON clubs.code_club = nageurs.code_club
         INNER JOIN resultats ON resultats.nr_ligue = nageurs.nr_ligue
GROUP BY nageurs.nr_ligue
HAVING MIN(place) > 10;

#28. Rechercher le numéro de ligue, le nom, le prénom, le sexe, l'année de naissance et le nom du club des nageurs qui ont été classés premiers à toutes les courses auxquelles ils ont participé.

SELECT nageurs.nr_ligue, nageurs.nom, nageurs.prenom, nageurs.sexe, nageurs.annee_naissance, sum(place), count(*)
FROM nageurs
         INNER JOIN clubs ON clubs.code_club = nageurs.code_club
         INNER JOIN resultats ON resultats.nr_ligue = nageurs.nr_ligue
GROUP BY nageurs.nr_ligue
HAVING sum(place) = count(*);




#29. supprimez les code postaux inutiles (il y en aura plus que 30)

DELETE
FROM code_postaux
WHERE code_postal NOT IN (SELECT nageurs.code_postal FROM nageurs)
AND code_postal NOT IN (SELECT secretariats.code_postal FROM secretariats)
AND code_postal NOT IN (SELECT piscines.code_postal FROM piscines);
