
include "alldifferent.mzn";

int: ww = 5; %nb semaines
int: gg = 5; %nb groupes dans une semaine
int: pp = 5; %nb joueurs dans un groupe

int : n = gg*pp; %nombre de joueurs diférents
int : k = pp;
int : b = ww*gg; %nombre de groupes différents au total

set of int: S = 1..ww; %ensemble des semaines
set of int: G = 1..gg; % ensemble des groupes dans une semaine
set of int: P = 1..(pp*gg); % ensemble des joueurs

array[S,G] of var set of P: t; %matrice de match

%un groupe contient p équipes
constraint forall(s in S, g in G)(card(t[s,g]) = pp); 
%chaque golfeur joue 1 fois/semaine \\ j'ai enlevé la contrainte elle n'est pas utile et rajoute du temps d'execution 
%constraint forall(s in S)(card(array_union(t[s,G])) = pp*gg); 

%chaque golfeur joue dans 1 groupe chaque semaine
constraint forall(s in S, g in G,g2 in G where g!=g2)(card(t[s,g] intersect t[s,g2]) = 0); 
%Chaque joueurs rencontre des nouveaux joueurs chaque semaine
constraint forall(s in S,s2 in S , g in G,g2 in G where g!=g2\/ s!=s2)(card(t[s,g] intersect t[s2,g2]) <= 1); 


%pré-conditions que doit respecter l'instance pour etre satisfiable (attention certaines sont redondantes)
%nb joueurs disponibles >= nb de joueurs que rencontre un joueur 
constraint (ww*(pp-1)<=n);
%nombre de groupes à créer <= nombre de combinaisons possibles de joueurs (=nb groupes possibles) tq inter entre 2 grps <= 1
constraint (b<= n*(n-1)/(k*(k-1)));
%si ya trop de semaines et de grooupes par rapport au nombre de joueurs alors ya pas de solutions (equivalent précédent
constraint (ww <= (n-1)/(pp-1));
constraint (gg <= (n-1)/(pp-1));


%Contraintes redondantes qui améliorent la propagation
% inter des groupes dans chaque semaine est vide (redondant avec "chaque joueur joue dans 1 groupe chaque semaine" mais moins %fort)
constraint forall(s in S)(array_intersect(t[s,G]) = 1..0); 
% inter des semaines pour chaque groupe est au max 1 (redondant avec "chaque joueurs rencontre des nouveaux joueurs chaque %semaine" mais moins fort)
constraint forall(g in G)(card(array_intersect(t[S,g])) <=1); 

%tentative pour améliorer la propag mais c'est pas efficace
%constraint alldifferent(t[S,G]); 


%contraintes sym 
%constraint forall(s in S,g in G,g2 in G where g<g2)();

solve satisfy;

output [ show(t[s,g]) ++ 
         if g == gg then "\n" else " " endif |
         s in 1..ww, g in 1..gg
];