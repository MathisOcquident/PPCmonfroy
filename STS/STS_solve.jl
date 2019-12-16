include("../generic_solver.jl")
include("../filtrage.jl")


function pla(semaine::Int, terrain::Int, n::Int)
    return Int( (semaine-1)*(n/2) + terrain )
end


# n : nombre d'équipe
function genere_contrainte_STS(n::Int)
    @assert(n%2 == 0)
    n_semaine = n-1
    n_terrain = Int(n/2)
    equipe = Set(collect(1:n))
    liste_var = [ Variable(Set{Int64}([]), equipe, 2, 2, equipe) for i in 1:n_terrain*n_semaine]
    liste_ctr = Array{Contrainte, 1}()
    # Contrainte intersection vide
    for s in 1:n_semaine
        for i in 1:n_terrain-1
            for j in (i+1):n_terrain
                push!(liste_ctr, Contrainte([pla(s, i, n), pla(s, j, n)], filtrage_intersection_vide!))
            end
        end
    end

    # Contrainte (var1 inter var2 inter var3) = emptyset
    for s1 in 1:n_semaine-2
        for s2 in (s1+1):n_semaine-1
            for s3 in (s2+1):n_semaine
                for i in 1:n_terrain
                    push!(liste_ctr, Contrainte([pla(s1, i, n), pla(s2, i, n), pla(s3, i, n)], filtrage_triple_intersection_vide!))
                end
            end
        end
    end

    # contrainte union Equivalent to a all diff equivalent to a card inter <= card-1 = 1
    for k1 in 1:length(liste_var)-1, k2 in (k1+1):length(liste_var)
        push!(liste_ctr, Contrainte([k1, k2], filtrage_card_intersection_inferieur_1!))
    end

    return liste_var, liste_ctr
end

function listes_variables_vers_matrice(liste_var::Array{Variable, 1}, n::Int)
    n_semaine = n-1
    n_terrain = Int(n/2)
    mat = Array{Array{Int, 1}, 2}(undef, n_semaine, n_terrain)
    for semaine in 1:n_semaine
        for equipe in 1:n_terrain
            indice = pla(semaine, equipe, n)
            mat[semaine, equipe] = collect(liste_var[indice].min)
        end
    end
    return mat
end

function beau_print_res(matrice::Array{Array{Int, 1}, 2})
    n = size(matrice)[1]+1
    n_semaine = n-1
    n_terrain = Int(n/2)
    for semaine in 1:n_semaine
        println("Semaine ", semaine)
        for terrain in 1:n_terrain
            println("   terrain ", terrain, " : ", matrice[semaine, terrain])
        end
    end
end

# n : nombre d'équipes
function solve_STS(n::Int)
    liste_var, liste_ctr = genere_contrainte_STS(n)
    println("branch_and_bound")
    @time faisable = branch_and_bound!(liste_var, liste_ctr)
    println(faisable ? "faisable" : "infaisable")
    if faisable
        # println(liste_var)
        mat = listes_variables_vers_matrice(liste_var, n)
        beau_print_res(mat)
    end
end

solve_STS(6)


#=
 2 : 0.000119 seconds faisable
 4 : 0.057985 seconds infaisable
 6 : 0.185042 seconds faisable

=#
