# Projet de PPC
Université de Nantes - Master 2 ORO - Année 2019/2020.

* Package julia à installer pour le modèle FD:
```
using DataFrames,CSV,DelimitedFiles,JuMP
```


## Structure générale du dossier à respecter
```
Rapport.pdf       - Rapport du projet
Presentation.pdf  - Présentation
filtrage.jl       - Filtrages utilisés lors du solveur artisanal
generic_solver.jl - Solveur artisanal
\SGP
    satInterpret.jl        - script julia qui interprète une solution sat dans un fichier res.out
    SGP.jl                 - script julia qui résoud le problème FD
    SGP_sat.jl             - script julia qui génère un fichier DIMAX (CNF) nommé "satsgp.cnf"
    SGP_solve.jl           - script julia contenant la génération des variables et contraintes du problème SGP, puis qui appelle le solver `solve_SGP(w, g, p)`.
    test_generic_solver.jl - fichier de test
    \results               - dossier contenant les résultats pour les instances de SGP
        SGP444.out         - fichier résultat du problème SGP 4-4-4
	SGP555.out         - fichier résultat du problème SGP 5-5-5
    SGP.mzn                - fichier de résultion du SGP pour minizinc
    SGP_sat_sym.jl         - fichier de test
    SGPtechniqueThard.mzn  - fichier de test

\STS
    satInterpret.jl        - script julia qui interprète une solution sat dans un fichier res.ou
    STS.jl		   - script julia qui résoud le problème FD
    STS_sat.jl		   - script julia qui génère un fichier DIMAX (CNF) nommé "satsts.cnf"
    STSset.mzn		   - fichier de test pour la deuxième modélisation de STS ensembliste pour minizinc
    \results		   - dossier contenant les résultats pour les instances de SGP
        STS10.out	   - fichier résultat du problème STS 10
	STS12.out	   - fichier résultat du problème STS 12
	STS6.out	   - fichier résultat du problème STS 6
	STS8.out	   - fichier résultat du problème STS 8
    STS.mzn		   - fichier de résultion du STS pour minizinc
    STS_sat_sym.jl	   - fichier de test
    STS_solve.jl	   -  script julia contenant la génération des variables et contraintes du problème SGP, puis qui appelle le solver `solve_STS(n)`.

sudoku.jl		   - script julia permettant de résoudre un sudoku à l'aide du solver
README.md
```

**Remarques**


**Commandes d'éxécutions**
Pour les modèles Ensembliste, il suffit d’ouvrir les fichiers dans minizinc pour les exécuter.

```SGP.mzn```

Pour les fichier FD, il faut julia 1.2 avec les paquets :

```using JuMP, Gurobi, MathOptInterface, LinearAlgebra```

Attention, il faut une licence de Gurobi pour résoudre avec Gurobi. La commande pour résoudre est :

```include("SGP.jl")```

Pour résoudre les instances sat, il faut d’abord générer les fichiers cnf avec julia 1.2 et la commande :

```include("SGP_SAT.jl")```

ensuite, il faut résoudre le problème avec :

```z3 satsgp.cnf -st```

Puis il faut copier la solution du terminal dans le fichier res.out ou on peut le générer avec minisat :

```minisat satsgp.cnf res.out```

Il faut ensuite interpréter les résultats avec (dans le même environnement julia) :

```include("satInterpret.jl")```

Pour lancer le branch and bound il faut utiliser la commande suivante

```include("SGP_solve.jl")```

Pour changer l’instance, il faut modifier les paramètres dans le code.
Pour changer de problème il faut remplacer les SGP par STS.

Les résultats obtenus sont dans les fichiers results des deux dossiers SGP et STS


lien tuto minizinc : https://www.minizinc.org/doc-2.3.2/en/part_2_tutorial.html
