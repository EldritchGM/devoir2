include "globals.mzn";

var 1000..9999: nombre;

array[1..4] of var 1..9: chiffres;

constraint chiffres[1] > chiffres[2];
constraint chiffres[1] != chiffres[3];
constraint chiffres[1] != chiffres[4];
constraint chiffres[2] != chiffres[3];
constraint chiffres[2] > chiffres[4];
constraint chiffres[3] < chiffres[4];

constraint chiffres[1] + chiffres[2] + chiffres[3] + chiffres[4] > 15;


solve minimize chiffres[2] * chiffres[3] * chiffres[4];

nombre = 1000 * chiffres[1] + 100 * chiffres[2] + 10 * chiffres[3] + chiffres[4];

output [
  show(nombre)
];

