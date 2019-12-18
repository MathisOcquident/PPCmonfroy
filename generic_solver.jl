
#==============================================================================#
#============================== Variable ======================================#
#==============================================================================#

# Une variable contient deux ensembles, et deux entiers
mutable struct Variable
    min::Set{Int64}
    max::Set{Int64}
    card_min::Int64
    card_max::Int64

    univers::Set{Int64}

    est_clot::Bool
    id::String

    Variable(min::Set{Int64}, max::Set{Int64},
            card_min::Int64, card_max::Int64,
            univers::Set{Int64},
            est_clot::Bool = false) = new(
        Set{Int64}(min),
        Set{Int64}(max),
        card_min,
        card_max,
        univers,
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

# Ajoute une valeur au set min
function ajouter!(var::Variable, valeur::Int)
    push!(var.min, valeur)
    filtrage_individuel!(var)
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

#==============================================================================#
#================================ Contrainte ==================================#
#==============================================================================#

struct Contrainte
    liste_indice_arguments::Array{Int, 1}
    filtrage!::Function
end

function filtrer!(ctr::Contrainte, liste_variables::Array{Variable, 1})
    liste_arguments = [liste_variables[i] for i in ctr.liste_indice_arguments]
    ctr.filtrage!(liste_arguments)
    for var in liste_arguments
        filtrage_individuel!(var)
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
                if !(var in arguments) # A changer
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
    function inf_diff_card(left, right)
        left_var = liste_variables[left]
        right_var = liste_variables[right]
        return  left_var.card_max - length(left_var.min) <=
                right_var.card_max - length(right_var.min)
    end
    faisable = solver_generique!(liste_variables, liste_contraintes)
    if faisable
        liste_non_clot = findall(var -> !verifie_clot(var), liste_variables)
        if !isempty(liste_non_clot) # condition d'arret
            # branchement sur le plus petit écart entre la taille des bornes (pour clore rapidement)
            #sort!(liste_non_clot, lt=inf_diff_card)
            sort!(liste_non_clot, by = e -> liste_variables[e].card_max - length(liste_variables[e].min) )
            indice_branchement = liste_non_clot[1]
            var = liste_variables[indice_branchement]
            candidat_ajout = collect(setdiff(var.max, var.min))
            n = length(candidat_ajout)
            indice_valeur = 1
            faisable_temp = false
            liste_variables_temp = []
            while indice_valeur <= n && !faisable_temp
                liste_variables_temp = deepcopy(liste_variables)
                valeur_ajout = candidat_ajout[indice_valeur]
                ajouter!(liste_variables_temp[indice_branchement], valeur_ajout)
                faisable_temp = branch_and_bound!(liste_variables_temp, liste_contraintes)
                indice_valeur += 1
                # On sait le problème infaisable avec, alors on le retire.
                if !faisable_temp
                    setdiff!(liste_variables[indice_branchement].max, valeur_ajout)
                end
            end
            if faisable_temp
                for i in 1:length(liste_variables) # assignation
                    liste_variables[i] = liste_variables_temp[i]
                end
            else
                faisable_temp = branch_and_bound!(liste_variables, liste_contraintes)
                faisable = faisable_temp # pas faisable
            end
        end
    end
    return faisable
end

#==============================================================================#
#================================= Filtrage ===================================#
#==============================================================================#

function filtrage_individuel!(var::Variable)
    if !var.est_clot
        nmax = length(var.max)
        nmin = length(var.min)

        # card Max > taille de set Max
        if nmax < var.card_max
            var.card_max = nmax
        end

        # card Min < taille de set Min
        if nmin > var.card_min
            var.card_min = nmin
        end

        # Card min = taille de  Set max
        if nmax == var.card_min
            union!(var.min, var.max)
        end

        # Card maw = taille de  Set min
        if nmin == var.card_max
            intersect!(var.max, var.min)
        end

    end
    verifie_clot(var)
    return nothing
end
