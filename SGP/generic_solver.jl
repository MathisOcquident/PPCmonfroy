
#==============================================================================#
#============================== Variable ======================================#
#==============================================================================#

# Une variable contient deux ensembles, et deux entiers
mutable struct Variable
    min::Set{Int64}
    max::Set{Int64}
    card_min::Int64
    card_max::Int64
    est_clot::Bool

    id::String

    Variable(min::Set{Int64}, max::Set{Int64},
            card_min::Int64, card_max::Int64,
            est_clot::Bool = false) = new(
        Set{Int64}(min),
        Set{Int64}(max),
        card_min,
        card_max,
        est_clot,
        generer_random_id(20)
    )
end

function generer_random_id(taille::Int)
    STR_RANDOM_ID_SEED = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ?.!+-*/^%&"
    str = ""
    for i in 1:taille
        str *= rand(STR_RANDOM_ID_SEED)
    end
    return str
end

# Fait l'intersection la plus large des variables
function intersection(var1::Variable, var2::Variable)
    min = intersect(var1.min, var2.min)
    max = intersect(var1.max, var2.max) # On ne peut pas trouver moins large
    card_min = length(min)
    max = length(max)
    return Variable(min, max, card_min, card_max)
end

# Génère une variable vide
function generer_Variable_Vide()
    return Variable(Set{Int64}(), Set{Int64}(), 0, 0, true)
end

function generer_Variable_fixe(valeur::Set{Int})
    n = length(valeur)
    return Variable(valeur, valeur, n, n, true)
end

# Fixe une variable à une valeur.
function fixer!(var::Variable, valeur::Set{Int})
    var.min = valeur
    var.max = valeur
    var.card_min = length(valeur)
    var.card_max = var.card_min
    var.est_clot = true
    return var
end

# On modifie le print lors d'un print(var::Variable) ou d'un println(var::Variable)
function Base.show(io::IO, var::Variable)
    compact = get(io, :compact, false)
    sep = ", "
    if !compact
        println(io, "Variable :")
        println(io, "\tmin : ", var.min)
        println(io, "\tmax : ", var.max)
        println(io, "\t", var.card_min, " <= Cardinal <= ", var.card_max)
        println(io, "\tid: ", var.id)
    else
        print(io, "Variable(")
        print(io, "min:")
        show(io, var.min)
        print(io, sep)
        print(io, "max:")
        show(io, var.max)
        print(io, sep)
        show(io, var.card_min)
        print(io, " <= Cardinal <= ")
        show(io,  var.card_max)
        print(sep)
        print(io, "id:")
        show(io, var.id)
        print(io, ")")
    end
end

# Surcharge l'opérateur == pour faire var1 == var2
function Base.:(==)(var1::Variable, var2::Variable)
    egalite_min = (var1.min == var2.min)
    egalite_max = (var1.max == var2.max)
    egalite_card_min = (var1.card_min == var2.card_min)
    egalite_card_max = (var1.card_max == var2.card_max)
    egalite_id = (var1.id == var2.id)
    return egalite_min && egalite_max && egalite_card_min && egalite_card_max && egalite_id
end

# Vérifie si la variable reste valide, ie qu'il reste des solutions possibles.
function verifie_validite(var::Variable)
    valide = true
    valide = valide && intersect(var.min, var.max) == var.min
    valide = valide && length(var.max) >= var.card_min
    valide = valide && length(var.min) <= var.card_max
    valide = valide && var.card_min <= var.card_max
    return valide
end

# Vérifie si la variable est close.
function verifie_clot(var::Variable)
    clot = false
    clot = clot || var.min == var.max
    clot = clot || length(var.min) == var.card_max
    var.est_clot = clot
    return clot
end

# Vérifie si la variable est vide.
function est_vide(var::Variable)
    vide = false
    if length(var.max) == 0 vide = true end
    if var.car_max == 0 vide = true end
    return vide
end

# on filtre la contrainte : (var1 inter var2) = emptyset
function filtrage_intersection_vide!(liste_Variable::Array{Variable, 1}, Univers::Set)
    var1, var2 = liste_Variable
    if (!var1.est_clot)
        setdiff!(var1.max, var2.min)
        var1.card_max = max(var1.card_max, length(setdiff( Univers, var2.min )) )
    end
    if (!var2.est_clot)
        setdiff!(var2.max, var1.min)
        var2.card_max = max(var2.card_max, length(setdiff( Univers, var1.min )) )
    end
    return nothing
end

function filtrage_card_intersection_inferieur_1!(liste_Variable::Array{Variable, 1}, Univers::Set)
    var1, var2 = liste_Variable
    # TODO :


    return nothing
end

function filtrage_individuel!(var::Variable, Univers::Set)
    if !var.est_clot
        nmax = length(var.max)
        nmin = length(var.min)

        # Card min = taille de  Set max
        if nmax == var.card_min
            union!(var.min, var.max)
        end

        # Card maw = taille de  Set min
        if nmin == var.card_max
            intersect!(var.max, var.min)
        end

        # card Max > taille de set Max
        if nmax < var.card_max
            var.card_max = nmax
        end

        # card Min < taille de set Min
        if nmin > var.card_min
            var.card_min = nmin
        end

    end
    verifie_clot(var)
    return nothing
end

#==============================================================================#
#================================ Contrainte ==================================#
#==============================================================================#

struct Contrainte
    liste_indice_arguments::Array{Int, 1}
    filtrage!::Function
    univers::Set{Int}
end

function filtrer!(ctr::Contrainte, liste_variables::Array{Variable, 1})
    liste_arguments = [liste_variables[i] for i in ctr.liste_indice_arguments]
    ctr.filtrage!(liste_arguments, ctr.univers)
    for var in liste_arguments
        filtrage_individuel!(var, ctr.univers)
    end
end

function solver_generique!(liste_variables::Array{Variable, 1}, liste_contraintes::Array{Contrainte, 1})
    # tableau qui associe toutes les contraintes d'une variable à l'indice de cet dernière dans liste_variables
    array_contrainte_variable = [
        findall(ctr -> indice in ctr.liste_indice_arguments, liste_contraintes)
        for indice in 1:length(liste_variables)
    ]

    liste_filtrage_restant = collect(length(liste_contraintes):-1:1)
    infaisable = false
    while !isempty(liste_filtrage_restant) && !infaisable
        indice_ctr = pop!(liste_filtrage_restant)
        ctr = liste_contraintes[indice_ctr]
        arguments = [deepcopy(liste_variables[i]) for i in ctr.liste_indice_arguments]
        filtrer!(ctr, liste_variables)
        for indice_var in ctr.liste_indice_arguments
            var = liste_variables[indice_var]
            if verifie_validite(var)
                if !(var in arguments) && !verifie_clot(var) # A changer et n'est pas clot.
                    for indice in array_contrainte_variable[indice_var]
                        #Ne pas mettre plusieurs fois la même contrainte en attente.
                        if !(indice in liste_filtrage_restant)
                            push!(liste_filtrage_restant, indice)
                        end
                    end
                end
            else
                infaisable = true
            end
        end
    end
    return !infaisable # retourne true si le solver a trouvé le problème faisable.
end

function branch_and_bound!(liste_variables::Array{Variable, 1}, liste_contraintes::Array{Contrainte, 1})
    faisable = solver_generique!(liste_variables, liste_contraintes)
    if faisable
        liste_non_clot = findall(var -> !verifie_clot(var), liste_variables)
        # TODO: finir
    end
    return faisable
end


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
#test_solver_generique1()



function test_solver_generique2()
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
#test_solver_generique2()
