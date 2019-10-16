int : com = 35;

int : n=21;
int : k=3;


set of int: K = 1..k; % k 
set of int: N = 1..n; % n
set of int: C = 1..com; % combi


array[C] of var set of N: t;

constraint forall(c in C)(card(t[c])=k);
constraint forall(c in C, c2 in C where c!=c2)(card(t[c] intersect t[c2]) <=1); 

solve satisfy;

output [show(t)];