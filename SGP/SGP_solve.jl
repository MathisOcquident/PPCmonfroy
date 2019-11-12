include("generic_solver.jl")


# w : nombre de semaine, g : nombre de groupe, p : nombre de joueur
function genere_contrainte_SGP(w::Int, g::Int, p::Int)
    q = g * p # nombre de joueurs
    joueurs = Set(collect(1:q))
    liste_var = [ Variable(Set{Int64}([]), joueurs, p, p) for i in 1:(w*g)]
    liste_ctr = Array{Contrainte, 1}()
    # Contrainte intersection vide
    for s in 1:w
        for i in 1:(g-1)
            for j in (i+1):g
                k1 = g*(s-1)+i
                k2 = g*(s-1)+j
                push!(liste_ctr, Contrainte([k1, k2], filtrage_intersection_vide!, joueurs))
            end
        end
    end
    # Contrainte card(v1 inter v2) <= 1
    for s1 in 1:(w-1)
        for s2 in s1:w
            for i in 1:g
                for j in 1:g
                    k1 = g*(s1-1)+i
                    k2 = g*(s2-1)+j
                    push!(liste_ctr, Contrainte([k1, k2], filtrage_card_intersection_inferieur_1!, joueurs))
                end
            end
        end
    end


    return liste_var, liste_ctr
end

liste_var, liste_ctr = genere_contrainte_SGP(4, 4, 4)
println(liste_var)
println("branch_and_bound")
faisable = branch_and_bound!(liste_var, liste_ctr)
println(faisable ? "faisable" : "infaisable")
if faisable
    println(liste_var)
end
