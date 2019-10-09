int: n = 10;

set of int: J = 1..(n div 2); % terrain 
set of int: I = 1..n-1; % semaine
set of int: M = 1..n; % equipe

array[I,J] of var set of M: t; %matrice de match

%un terrain contient 2 équipes
constraint forall(i in I, j in J)(card(t[i,j]) = 2); 
%chaque équipe joue 1 fois/semaine
constraint forall(i in I, j in J, j2 in J where j2 != j)(card(t[i,j] intersect t[i,j2]) = 0); 
%chaque équipe joue 2fois max sur le meme terrain
constraint forall(i in I, i2 in I where i2!=i, i3 in I where i3!=i2 /\ i3!=i, j in J)(t[i,j] intersect t[i2,j] intersect t[i3,j] = 1..0);
%toutes les équipes s'affrontent au moins une fois
var tmp = 
constraint forall(i in I, j in J)()

solve satisfy;

output [show(t)];