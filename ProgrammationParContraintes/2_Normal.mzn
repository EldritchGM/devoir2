% Romain LUCAS (2309703)
% Corentin CLEMENT (2311514)

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

% Il y a autant de ours B que de tours R et ce nombre est total_commun
constraint total_commun = sum([if terrain[i,j] == B then 1 else 0 endif | i in 1..n, j in 1..n]);
constraint total_commun = sum([if terrain[i,j] == R then 1 else 0 endif | i in 1..n, j in 1..n]);


% Sur une même ligne, il ne peut pas y avoir les deux types de tours
constraint
  forall(i in 1..n) (
  forall (j1 in 1..n) (
  forall (j2 in 1..n) (
    not (terrain[i, j1] = R /\ terrain[i,j2] = B)
  )));
  
% Sur une même colonne, il ne peut pas y avoir les deux types de tours
constraint
  forall(j in 1..n) (
  forall (i1 in 1..n) (
  forall (i2 in 1..n) (
    not (terrain[i1, j] = R /\ terrain[i2,j] = B)
  )));
  
% Sur une même diagonale, il ne peut pas y avoir les deux types de tours
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

% symmetry breaking: on prend seulement les solutions n'ayant pas de tours sur la première colonne ou seulement des tours bleues
constraint forall(i in 1..n) (terrain[i, 1] != R);

%-----------------------------------------------------------------------------%
output 
["Terrain :\n"]
++
[if j = 1 then "["  endif ++ if fix(terrain[i,j]) == V then "_" else show(terrain[i,j]) endif ++ if j = n then "]\n" else "," endif | i in 1..n, j in 1..n]
++
["\n"]
++
["Total de tours commun: " ++ show(total_commun)]
