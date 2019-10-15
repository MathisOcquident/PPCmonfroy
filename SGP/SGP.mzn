
include "alldifferent.mzn";

% Use this editor as a MiniZinc scratch book
int: ww = 4;
int: gg = 4;
int: pp = 4;

int : n = gg*pp;
int : k = pp;
int : b = ww*gg;

set of int: S = 1..ww; % terrain 
set of int: G = 1..gg; % semaine
set of int: P = 1..(pp*gg); % equipe

array[S,G] of var set of P: t; %matrice de match
% contraint de Week*groupe max 
constraint (ww*(pp-1)<=n);
constraint (b<= n*(n-1)/(k*(k-1)));

constraint (ww <= ((n)-1)/(pp-1));
constraint (gg <= ((n)-1)/(pp-1));

%un groupe contient p équipes
constraint forall(s in S, g in G)(card(t[s,g]) = pp); 
%chaque golfeur joue 1 fois/semaine \\ j'ai enlevé la contrainte elle n'est pas utile et rejoute de temps d'execution 
%constraint forall(s in S)(card(array_union(t[s,G])) = pp*gg); 

%chaque golfeur joue dans 1 groupe chaque semaine
constraint forall(s in S, g in G,g2 in G where g!=g2)(card(t[s,g] intersect t[s,g2]) = 0); 
%Chaque joueurs rencontre des nouveaux joueurs chaque semain
constraint forall(s in S,s2 in S , g in G,g2 in G where g!=g2\/ s!=s2)(card(t[s,g] intersect t[s2,g2]) <= 1); 


% 
constraint forall(s in S)(array_intersect(t[s,G]) = 1..0); 
constraint forall(g in G)(card(array_intersect(t[S,g])) <=1); 


%constraint alldifferent(t[S,G]); 


solve satisfy;

output [ show(t[s,g]) ++ 
         if g == gg then "\n" else " " endif |
         s in 1..ww, g in 1..gg
];