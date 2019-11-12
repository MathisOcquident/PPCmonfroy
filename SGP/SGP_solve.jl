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
        for s2 in (s1+1):w
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

function greedy_premiere_semaine!(liste_var::Array{Variable, 1}, w::Int, g::Int, p::Int)
    s1 = 1
    k = 1
    for i in 1:g
        indice = g*(s1-1)+i
        for j in 1:p
            push!(liste_var[indice].min, k)
            k += 1
        end
    end
end

function solve_SGP(w::Int, g::Int, p::Int)
    liste_var, liste_ctr = genere_contrainte_SGP(w, g, p)
    greedy_premiere_semaine!(liste_var, w, g, p)
    println(liste_var)
    println("branch_and_bound")
    @time faisable = branch_and_bound!(liste_var, liste_ctr)
    println(faisable ? "faisable" : "infaisable")
    if faisable
        println(liste_var)
    end
end

solve_SGP(2, 2, 2)


# 2, 2, 2 faisable 0.001 s
# 3, 3, 3 faisable 0.013 s
# 4, 4, 4 faisable 0.066 secondes
# 5, 5, 5 faisable, 57.36 secondes


# 7, 2, 2 infaisable
