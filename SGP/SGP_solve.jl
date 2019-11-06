
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
end

# Fait l'intersection la plus large des variables
function intersect(var::Variable, var::Variable)
    min = intersect(var1.min, var2.min)
    max = intersect(var1.max, var2.max) # On ne peut pas trouver moins large
    card_min = length(min)
    max = length(max)
    return generer_Variable(min, max, card_min, card_max)
end

function generer_Variable(min::Set{Int64}, max::Set{Int64},
    card_min::Int64, card_max::Int64, est_clot::Bool = false)
    return Variable(Set{Int64}(min), Set{Int64}(max), card_min, card_max, est_clot)
end

# Génère une variable vide
function generer_Variable_Vide()
    return Variable(Set{Int64}(), Set{Int64}(), 0, 0, true)
end

# Fixe une variable à une veleur.
function fixer(var::Variable, valeur::Set{Int})
    var.min = valeur
    var.max = valeur
    var.card_min = length(valeur)
    var.card_max = var.card_min
    var.est_clot = true
end

# On modifie le print lors d'un print(var::Variable) ou d'un println(var::Variable)
function Base.show(io::IO, var::Variable)
    println("Variable :")
    println("\tmin : ", var.min)
    println("\tmax : ", var.max)
    print("\t", var.card_min, " <= Cardinal <= ", var.card_max)
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
function filtrage_intersection_vide(var1::Variable, var2::Variable, Univers::Set)
    if (!var1.est_clot)
        setdiff!(var1.max, var2.min)
        var1.card_max = max(var1.card_max, length(setdiff( Univers, var2.min )) )
    end
    if (!var2.est_clot)
        setdiff!(var2.max, var1.min)
        var2.card_max = max(var2.card_max, length(setdiff( Univers, var1.min )) )
    end
end

function filtrage_card_intersection_inferieur_1(var1::Variable, var2::Variable)
    # TODO :
end

#==============================================================================#
#================================ Contrainte ==================================#
#==============================================================================#

struct Contrainte
    liste_argument::Array{Variable, 1}
    filtrage!::Fonction
end



#==============================================================================#
#============================= Test des fonctions =============================#
#==============================================================================#

Univers = Set((1, 2, 3, 4, 5, 6))
v1 = generer_Variable(Set{Int64}((1, 2, 3)), Univers, 2, 4)
v2 = generer_Variable(Set{Int64}((5, 6)), Univers, 2, 4)
v3 = generer_Variable(Set{Int64}((3, 5, 6)), Univers, 2, 4)
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
    filtrage_intersection_vide(var1, var2, Univers)
    print("var1 : ", var1, "var2 : ", var2)
    test_validite(var1, "var1")
    test_validite(var2, "var2")
    test_clot(var1, "var1")
    test_clot(var2, "var2")
end
test_filtrage_intersection_vide(v1, v2, Univers)
test_filtrage_intersection_vide(v1, v3, Univers)
