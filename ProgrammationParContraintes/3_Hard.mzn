% NOM_ETUDIANT_1 (MATRICULE_1)
% NOM_ETUDIANT_2 (MATRICULE_2)

include "globals.mzn";

% Énumérations des équipes participant au tournoi
enum equipes = {CO, TA, HO, DA, NA, MU, AL, UT};

% Lieux de rencontres des equipes (0 = pas de rencontre).
% Tout lieu i, tel que 0 < i <= card(equipes), 
% est designé comme le domicile de l'équipe associée par la relation to_enum(equipe, i)
set of int: terrains = 0..card(equipes);

% Étendue du tournoi (en jours)
int: d = 16;
set of int: jours = 1..d;

% Calendrier de placement des matchs
array[equipes, jours] of var terrains: calendrier;

% Nombres de rencontres entre deux equipes
array[equipes, equipes] of var 0..2: rencontres;

% Tuples des dates de match entre deux équipes
array[equipes, equipes] of var tuple (0..d, 0..d): dates;

% Variable objectif à maximiser
var int: objectif_match_espaces;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%

% 1 - Pour effectuer une rencontre, deux équipe doivent être présente sur le même terrain.
constraint 
  forall(equipe1 in equipes) (
  forall(equipe2 in equipes) (
    calendrier[equipe1, dates[equipe1, equipe2].1] = calendrier[equipe2, dates[equipe1, equipe2].1]
  ));
  
constraint 
  forall(equipe1 in equipes) (
  forall(equipe2 in equipes) (
    calendrier[equipe1, dates[equipe1, equipe2].2] = calendrier[equipe2, dates[equipe1, equipe2].2]
  ));

% 2 - Un match doit avoir lieu sur le terrain désigné comme le domicile de l’une des deux équipes.
% 8 - Les deux rencontres de deux équipes doivent avoir lieu sur des terrains différents.

constraint
  forall(equipe1 in equipes) (
  forall(equipe2 in equipes) (
    (to_enum(equipes, calendrier[equipe1, dates[equipe1, equipe2].1]) = equipe1
    /\ to_enum(equipes, calendrier[equipe1, dates[equipe1, equipe2].2]) = equipe2)
    \/
    (to_enum(equipes, calendrier[equipe1, dates[equipe1, equipe2].1]) = equipe2
    /\ to_enum(equipes, calendrier[equipe1, dates[equipe1, equipe2].2]) = equipe1)
   ));
   
% 3- Un terrain ne peut accueillir plus de deux équipes.
constraint
  forall(terrain in terrains) (
  forall(jour in jours) (
    sum([if calendrier[equipe, jour] = terrain then 1 else 0 endif | equipe in equipes]) <= 2
  ));
  
%4- Si une équipe ne joue pas lors d’une période elle est placée sur le terrain n°0.
constraint
  forall(jour in jours) (
  forall(equipe1 in equipes) (
      calendrier[equipe1, jour] = 0 
      \/ (sum([if ((dates[equipe1, equipe2].1 = jour \/ dates[equipe1, equipe2].2 = jour) /\ equipe1 != equipe2) then 1 else 0 endif | equipe2 in equipes]) > 0)  
    ));
  
% 5- Une équipe ne doit pas jouer trop souvent à domicile, elle n’est donc pas autorisée à jouer plus de 7 jours sur son propre terrain. 
% Déjà vérifié par les autres contraintes

% 6- Les équipes doivent jouer deux fois l’une contre l’autre.
constraint
  forall(equipe1 in equipes) (
  forall(equipe2 in equipes) (
    equipe1 = equipe2
    \/
    (
    (dates[equipe1, equipe2] = dates[equipe2, equipe1]) 
    /\ dates[equipe1, equipe2].1 > 0 
    /\ dates[equipe1, equipe2].2 > 0)
  ));

% 7- Les deux rencontres de deux équipes doivent être espacées de 3 jours au minimum.
constraint
  forall(equipe1 in equipes) (
  forall(equipe2 in equipes) (
    dates[equipe1, equipe2].2 - dates[equipe1, equipe2].1 >= 3 \/ equipe1 = equipe2
  ));


objectif_match_espaces = sum([if equipe1 != equipe2 /\ (dates[equipe1, equipe2].2 - dates[equipe1, equipe2].1 >= 6) then 1 else 0 endif | equipe1 in equipes, equipe2 in equipes]) div 2;
 
solve maximize objectif_match_espaces;
%-----------------------------------------------------------------------------%

% Affichage du calendrier par equipes et par jours puis du résultat de la fonction objectif.
% Lorsqu'une équipe ne joue pas, l'emplacement de match reste vide sinon elle contient le nom de l'équipie adverse.
% Si une équipe ne joue pas à domicile, un "@" précède le nom de l'équipe adverse.
output 
["Calendrier:\n"]
++
[if j = 1 then "   " else "" endif ++ if j < 10 then "  j" ++ show(j) else " j" ++ show(j) endif ++ if j = d then "\n" else "" endif | j in jours ]
++
[if j = 1 then show(e1) ++ ":" else "" endif ++ if fix(calendrier[e1,j]) = 0 then "    " else if fix(calendrier[e1,j]) = e1 then "  " ++ concat([if e1 != e2 /\ fix(calendrier[e2,j]) = e1 then show(e2) else "" endif | e2 in equipes])  else " @" ++ show(to_enum(equipes, calendrier[e1,j])) endif endif ++ if j = d then "\n" else "" endif | e1 in equipes, j in jours ]
++
["\nMatchs retour espacés de 6 jours ou plus = " ++ show(objectif_match_espaces) ++ "\n"]
;
