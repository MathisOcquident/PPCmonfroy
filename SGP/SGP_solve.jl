include("../generic_solver.jl")


# on filtre la contrainte : (var1 inter var2) = emptyset
function filtrage_intersection_vide!(liste_Variable::Array{Variable, 1})
    var1, var2 = liste_Variable
    if (!var1.est_clot)
        setdiff!(var1.max, var2.min)
        var1.card_max = min(var1.card_max, length(setdiff( var1.univers, var2.min )) )
    end
    if (!var2.est_clot)
        setdiff!(var2.max, var1.min)
        var2.card_max = min(var2.card_max, length(setdiff( var2.univers, var1.min )) )
    end
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

# w : nombre de semaine, g : nombre de groupe, p : nombre de joueur
function genere_contrainte_SGP(w::Int, g::Int, p::Int)
    q = g * p # nombre de joueurs
    joueurs = Set(collect(1:q))
    liste_var = [ Variable(Set{Int64}([]), joueurs, p, p, joueurs) for i in 1:(w*g)]
    liste_ctr = Array{Contrainte, 1}()
    # Contrainte intersection vide
    for s in 1:w
        for i in 1:(g-1)
            for j in (i+1):g
                k1 = g*(s-1)+i
                k2 = g*(s-1)+j
                push!(liste_ctr, Contrainte([k1, k2], filtrage_intersection_vide!))
            end
        end
    end
    # Contrainte card(v1 inter v2) <= 1
    for s1 in 1:(w-1)
        for s2 in (s1+1):w
            for i in 1:g
                for j in 1:g
                    k1 = g*(s1-1)+i
                    k2 = g*(s2-1)+j
                    push!(liste_ctr, Contrainte([k1, k2], filtrage_card_intersection_inferieur_1!))
                end
            end
        end
    end


    return liste_var, liste_ctr
end

function greedy_premiere_semaine!(liste_var::Array{Variable, 1}, w::Int, g::Int, p::Int)
    s1 = 1
    s2 = 2
    k = 1
    for i in 1:g
        indice1 = g*(s1-1)+i
        indice2 = g*(s2-1)
        for j in 1:p
            ajouter!(liste_var[indice1], k)
            ajouter!(liste_var[indice2+j], k)
            if i == 1
                for si in 3:w
                    indice3 = g*(si-1)+j
                    ajouter!(liste_var[indice3], k)
                end
            end
            k += 1
        end
    end

end

# w : nombre de semaine, g : nombre de groupe, p : nombre de joueur
function solve_SGP(w::Int, g::Int, p::Int)
    liste_var, liste_ctr = genere_contrainte_SGP(w, g, p)
    greedy_premiere_semaine!(liste_var, w, g, p)
    println(liste_var)
    println("branch_and_bound")
    @time faisable = branch_and_bound!(liste_var, liste_ctr)
    println(faisable ? "faisable" : "infaisable")
    if faisable
        println(liste_var)
        matrice = listes_variables_vers_matrice(liste_var, w, g, p)
        beau_print_res(matrice)
    end
end

function listes_variables_vers_matrice(liste_var, w, g, p)
    mat = Array{Array{Int, 1}, 2}(undef, (w, g))
    for semaine in 1:w
        for groupe in 1:g
            indice = g*(semaine-1)+groupe
            mat[semaine, groupe] = collect(liste_var[indice].min)
        end
    end
    return mat
end

function beau_print_res(matrice::Array{Array{Int, 1}, 2})
    w, g = size(matrice)
    for semaine in 1:w
        println("Semaine ", semaine)
        for groupe in 1:g
            println("   groupe ", groupe, " : ", matrice[semaine, groupe])
        end
    end
end

solve_SGP(5,5,5)


# 2, 2, 2 faisable 0.001 secondes
# 3, 3, 3 faisable 0.013 secondes
# 4, 4, 4 faisable 0.066 secondes
# 5, 5, 5 faisable 57.36 secondes
# 5, 3, 2 faisable 0.029 secondes


# 7, 2, 2 infaisable
