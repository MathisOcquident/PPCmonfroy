# on filtre la contrainte : (var1 inter var2) = emptyset
function filtrage_intersection_vide!(liste_Variable::Array{Variable, 1})
    var1, var2 = liste_Variable
    setdiff!(var1.max, var2.min)
    var1.card_max = min(var1.card_max, length(setdiff( var1.univers, var2.min )) )

    setdiff!(var2.max, var1.min)
    var2.card_max = min(var2.card_max, length(setdiff( var2.univers, var1.min )) )

    return nothing
end

function filtrage_card_intersection_inferieur_1!(liste_Variable::Array{Variable, 1})
    var1, var2 = liste_Variable
    inter = intersect(var1.min, var2.min)

    if !isempty(inter)
        valeur = pop!(inter) # selectionner une valeur.

        min_v1 = setdiff(var1.min, valeur)
        setdiff!(var2.max, min_v1)

        min_v2 = setdiff(var2.min, valeur)
        setdiff!(var1.max, min_v2)

        # Utile pour la suite du problème
        filtrage_individuel!(var1)
        filtrage_individuel!(var2)
    end

    omega = union(var1.max, var2.max)
    n = length(omega)
    n1 = length(var1.min)
    n2 = length(var2.min)

    var1.card_max = min(var1.card_max, n+1 - n2 )
    var2.card_max = min(var2.card_max, n+1 - n1 )

    return nothing
end


# on filtre la contrainte : (var1 inter var2 inter var3) = emptyset
function filtrage_triple_intersection_vide!(liste_Variable::Array{Variable, 1})
    var1, var2, var3 = liste_Variable

    setdiff!(var1.max, intersect(var2.min, var3.min))
    var1.card_max = min(var1.card_max, length(setdiff( var1.univers, intersect(var2.min, var3.min) )) )

    setdiff!(var2.max, intersect(var1.min, var3.min))
    var2.card_max = min(var2.card_max, length(setdiff( var2.univers, intersect(var1.min, var3.min) )) )

    setdiff!(var3.max, intersect(var2.min, var1.min))
    var3.card_max = min(var3.card_max, length(setdiff( var3.univers, intersect(var2.min, var1.min) )) )

    return nothing
end
