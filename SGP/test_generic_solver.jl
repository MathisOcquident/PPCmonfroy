include("generic_solver.jl")

#==============================================================================#
#============================= Test des fonctions =============================#
#==============================================================================#

Univers = Set((1, 2, 3, 4, 5, 6))
v1 = Variable(Set{Int64}((1, 2, 3)), Univers, 2, 4)
v2 = Variable(Set{Int64}((5, 6)), Univers, 2, 4)
v3 = Variable(Set{Int64}((3, 5, 6)), Univers, 2, 4)

function test_validite(var::Variable, varName::String = "var")
    println(varName, " ", verifie_validite(var) ? "est valide." : "n'est pas valide.")
end

function test_clot(var::Variable, varName::String = "var")
    println(varName, " ", verifie_clot(var) ? "est clot." : "n'est pas clot.")
end

function test_filtrage_intersection_vide(var1::Variable, var2::Variable, Univers::Set)
    println("---------------------------------------")
    println("Test de la contrainte intersection vide")
    println("---------------------------------------")
    print("var1 : ", var1, "var2 : ", var2)
    println("Filtrage (var1 inter var2) = emptySet.")
    filtrage_intersection_vide!([var1, var2], Univers)
    print("var1 : ", var1, "var2 : ", var2)
    test_validite(var1, "var1")
    test_validite(var2, "var2")
    test_clot(var1, "var1")
    test_clot(var2, "var2")
end
#test_filtrage_intersection_vide(v1, v2, Univers)
#test_filtrage_intersection_vide(v1, v3, Univers)


function test_solver_generique1()
    println("test solver generic 1")
    univers = Set([1, 2, 3, 4, 5, 6])
    v1 = Variable(Set([1]), univers, 2, 4)
    v2 = Variable(Set([3]), univers, 2, 4)
    v3 = Variable(Set([5]), Set([5, 6]), 2, 4)
    liste_variables = [v1 , v2, v3]
    ctr1 = Contrainte([1, 2], filtrage_intersection_vide!, univers)
    ctr2 = Contrainte([1, 3], filtrage_intersection_vide!, univers)
    ctr3 = Contrainte([3, 2], filtrage_intersection_vide!, univers)
    liste_contraintes = [ctr1, ctr2, ctr3]
    println("Début du solver.")
    faisable = solver_generique!(liste_variables, liste_contraintes)
    println("Fin du solver.")
    println(faisable ? "Faisable" : "Infaisable")
    println(v1, "\t", v1.est_clot ? "clot" : "libre")
    println(v2, "\t", v2.est_clot ? "clot" : "libre")
    println(v3, "\t", v3.est_clot ? "clot" : "libre")
end
test_solver_generique1()



function test_solver_generique2()
    println("test solver generic 2")
    univers = Set([1, 2, 3, 4, 5, 6, 8, 9, 10])
    v1 = Variable(Set([1]), Set([1, 2]), 2, 20)
    v2 = Variable(Set([3]), Set([1, 2, 3, 4]), 2, 20)
    v3 = Variable(Set([5]), Set([1, 2, 3, 4, 5, 6]), 2, 20)
    v4 = Variable(Set([7]), Set([1, 2, 3, 4, 5, 6, 7, 8]), 2, 20)
    v5 = Variable(Set([9]), Set([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), 2, 20)
    liste_variables = [v1 , v2, v3, v4, v5]

    liste_contraintes = [
        Contrainte([i, j], filtrage_intersection_vide!, univers)
        for i in 1:5 for j in (i+1):5
    ]

    println("Début du solver.")
    faisable = solver_generique!(liste_variables, liste_contraintes)
    println("Fin du solver.")
    println(faisable ? "Faisable" : "Infaisable")
    println(v1, "\t", v1.est_clot ? "clot" : "libre")
    println(v2, "\t", v2.est_clot ? "clot" : "libre")
    println(v3, "\t", v3.est_clot ? "clot" : "libre")
    println(v4, "\t", v4.est_clot ? "clot" : "libre")
    println(v5, "\t", v5.est_clot ? "clot" : "libre")
end
test_solver_generique2()

function test_branch_and_bound1()
    println("Test branch and bound 1")
    univers = Set([1, 2, 3, 4, 5, 6, 8, 9, 10])
    v1 = Variable(Set([1]), Set([1, 2]), 2, 20)
    v2 = Variable(Set([3]), Set([1, 2, 3, 4]), 2, 20)
    v3 = Variable(Set([5]), Set([1, 2, 3, 4, 5, 6]), 2, 20)
    v4 = Variable(Set([7]), Set([1, 2, 3, 4, 5, 6, 7, 8]), 2, 20)
    v5 = Variable(Set([9]), Set([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), 2, 20)
    liste_variables = [v1 , v2, v3, v4, v5]

    liste_contraintes = [
        Contrainte([i, j], filtrage_intersection_vide!, univers)
        for i in 1:5 for j in (i+1):5
    ]

    println("Début du solver.")
    faisable = branch_and_bound!(liste_variables, liste_contraintes)
    println("Fin du solver.")
    println(faisable ? "Faisable" : "Infaisable")
    for var in liste_variables
        println(var, "\t", var.est_clot ? "clot" : "libre")
    end
end

function test_branch_and_bound2()
    println("Test branch and bound 2")
    univers = Set([1, 2, 3, 4, 5, 6])
    v1 = Variable(Set([1]), univers, 2, 4)
    v2 = Variable(Set([3]), univers, 2, 4)
    v3 = Variable(Set([5]), Set([5, 6]), 2, 4)
    liste_variables = [v1 , v2, v3]
    ctr1 = Contrainte([1, 2], filtrage_intersection_vide!, univers)
    ctr2 = Contrainte([1, 3], filtrage_intersection_vide!, univers)
    ctr3 = Contrainte([3, 2], filtrage_intersection_vide!, univers)
    liste_contraintes = [ctr1, ctr2, ctr3]
    println("Début du solver.")
    faisable = branch_and_bound!(liste_variables, liste_contraintes)
    println("Fin du solver.")
    println(faisable ? "Faisable" : "Infaisable")
    for var in liste_variables
        println(var, "\t", var.est_clot ? "clot" : "libre")
    end
end

test_branch_and_bound1()
test_branch_and_bound2()
