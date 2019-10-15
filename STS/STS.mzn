include "alldifferent.mzn";

% Use this editor as a MiniZinc scratch book
int: n = 8;

set of int: J = 1..(n div 2); % terrain 
set of int: I = 1..n-1; % semaine
set of int: M = 1..n; % equipe

array[I,J] of var set of M: t; %matrice de match

%un terrain contient 2 équipes
constraint forall(i in I, j in J)(card(t[i,j]) = 2); 
%chaque équipe joue 1 fois/semaine
% moins efficace
%constraint forall(i in I, j in J, j2 in J where j2 != j)(card(t[i,j] intersect t[i,j2]) = 0); 
%la best 
constraint forall(i in I)(card(array_union(t[i,J])) = n); 
%chaque équipe joue 2fois max sur le meme terrain
constraint forall(i,i2,i3 in I where  i!=i2 /\i2!=i3/\ i3!=i , j in J)(t[i,j] intersect t[i2,j] intersect t[i3,j] = 1..0);
%toutes les équipes s'affrontent au moins une fois

%toutes les équipes s'affrontent au plus une fois
constraint alldifferent(t[I,J]);


% ça aide pour la resolution !! <3 <3 
constraint forall(j in J)(card(array_union(t[I,j])) = n); 


solve satisfy;

output [ show(t[i,j]) ++ 
         if j == (n div 2) then "\n" else " " endif |
         i in 1..n-1, j in 1..(n div 2)
];