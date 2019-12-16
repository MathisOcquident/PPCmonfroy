include("../generic_solver.jl")
include("../filtrage.jl")



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
    #println(liste_var)
    println("branch_and_bound")
    @time faisable = branch_and_bound!(liste_var, liste_ctr)
    println(faisable ? "faisable" : "infaisable")
    if faisable
        #println(liste_var)
        matrice = listes_variables_vers_matrice(liste_var, w, g, p)
        beau_print_res(matrice)
    end
end

function listes_variables_vers_matrice(liste_var::Array{Variable, 1}, w::Int, g::Int, p::Int)
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
