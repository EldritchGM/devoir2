% NOM_ETUDIANT_1 (MATRICULE_1)
% NOM_ETUDIANT_2 (MATRICULE_2)

include "globals.mzn";

% États possibles pour une case du terrain
% V = Vide
% B = Tour bleue
% R = Tour rouge
enum etat = {V, B, R};

% Dimension du terrain (carré)
int: n;
set of int: dim = 1..n;

% État du terrain
array[dim, dim] of var etat: terrain;

% Variable objectif à maximiser
var int: total_commun;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%


constraint total_commun = sum([if terrain[i,j] == B then 1 else 0 endif | i in 1..n, j in 1..n]);
constraint total_commun = sum([if terrain[i,j] == R then 1 else 0 endif | i in 1..n, j in 1..n]);



constraint
  forall(i in 1..n) (
    (sum([if terrain[i,j] == R then 1 else 0 endif | j in 1..n]) <= 0) 
    \/ (sum([if terrain[i,j] == B then 1 else 0 endif | j in 1..n]) <= 0) 
  );

constraint
  forall(j in 1..n) (
    (sum([if terrain[i,j] == R then 1 else 0 endif | i in 1..n]) <= 0) 
    \/ (sum([if terrain[i,j] == B then 1 else 0 endif | i in 1..n]) <= 0) 
  );
 
 
constraint 
  forall (i1 in 1..n) (
  forall (i2 in 1..n) (
  forall (j1 in 1..n) (
  forall (j2 in 1..n) (
    not (terrain[i1, j1] = R /\ terrain[i2, j2] = B /\ (i1 + j1) = (i2 + j2))
  ))));
constraint 
  forall (i1 in 1..n) (
  forall (i2 in 1..n) (
  forall (j1 in 1..n) (
  forall (j2 in 1..n) (
    not (terrain[i1, j1] = R /\ terrain[i2, j2] = B /\ (j1 - i1) = (j2 - i2))
  ))));
solve maximize total_commun;

% symmetry breaking
constraint sum([if terrain[i,j] == R then 1 else 0 endif | i in 1..(n div 2), j in 1..(n div 2)]) > 0;

%-----------------------------------------------------------------------------%
output 
["Terrain :\n"]
++
[if j = 1 then "["  endif ++ if fix(terrain[i,j]) == V then "_" else show(terrain[i,j]) endif ++ if j = n then "]\n" else "," endif | i in 1..n, j in 1..n]
++
["\n"]
++
["Total de tours commun: " ++ show(total_commun)]
