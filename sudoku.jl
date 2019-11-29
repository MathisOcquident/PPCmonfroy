include("generic_solver.jl")

function coordBlock(b)
    l = floor(Int, (b-1)/3)*3 +1
    c = (b-1)%3 * 3 + 1
    return l, c
end

function pla(l, c)
    return (l-1)*9 + c
end

function varToMat(Vars)
    mat = zeros(Int, (9, 9))
    for l in 1:9
        for c in 1:9
            v = Vars[pla(l, c)]
            if verifie_clot(v)
                val = pop!(v.min)
                push!(v.min, val)
                mat[l, c] = val
            end
        end
    end
    return mat
end

function beauPrint(mat)
    for l in 1:9
        for c in 1:9
            print(mat[l, c])
            print(" ")
            if c == 3 || c == 6 print(" ") end
        end
        print("\n")
        if l == 3 || l == 6 print("\n") end
    end
end

function checkMat(Mat)
    for l in 1:9
        for c1 in 1:8, c2 in (c1+1):9
            if Mat[l, c1] == Mat[l, c2]
                println("teste Ligne: l:", l, " c1:", c1, " c2:", c2)
            end
        end
    end

    for c in 1:9
        for l1 in 1:8, l2 in (l1+1):9
            if Mat[l1, c] == Mat[l2, c]
                println("teste Colonne: c:", c, " l1:", l1, " l2:", l2)
            end
        end
    end
    for b in 1:9
        l0, c0 = coordBlock(b)
        for i in 1:8
            l1 = l0 + floor(Int, (i-1)/3)
            c1 = c0 + (i-1)%3
            k1 = pla(l1, c1)
            for j in (i+1):9
                l2 = l0 + floor(Int, (j-1)/3)
                c2 = c0 + (j-1)%3
                k2 = pla(l2, c2)
                if Mat[l1, c1] == Mat[l2, c2]
                    println("teste Block: l1:", l1, " l2:", l2, " c1:", c1, " c2:", c2)
                end
            end
        end
    end
end

function filtrage_intersection_vide!(liste_Variable::Array{Variable, 1})
    var1, var2 = liste_Variable
    setdiff!(var1.max, var2.min)
    var1.card_max = min(var1.card_max, length(setdiff( var1.univers, var2.min )) )

    setdiff!(var2.max, var1.min)
    var2.card_max = min(var2.card_max, length(setdiff( var2.univers, var1.min )) )

    return nothing
end

univers = Set(collect(1:9))
variables = [Variable(Set{Int64}(), univers, 1, 1, univers) for i in 1:(9*9)]
contraintes = Array{Contrainte, 1}()
# Contrainte ligne
contraintesL = Array{Contrainte, 1}()
for l in 1:9
    for c1 in 1:8, c2 in (c1+1):9
        push!(contraintesL, Contrainte([pla(l, c1), pla(l, c2)], filtrage_intersection_vide!))
    end
end
append!(contraintes, contraintesL)

#contrainte colonne
contraintesC = Array{Contrainte, 1}()
for c in 1:9
    for l1 in 1:8, l2 in (l1+1):9
        push!(contraintesC, Contrainte([pla(l1, c), pla(l2, c)], filtrage_intersection_vide!))
    end
end
append!(contraintes, contraintesC)


#contrainte Bloc
contraintesB = Array{Contrainte, 1}()
for b in 1:9
    l0, c0 = coordBlock(b)
    for i in 1:8
        l1 = l0 + floor(Int, (i-1)/3)
        c1 = c0 + (i-1)%3
        k1 = pla(l1, c1)
        for j in (i+1):9
            l2 = l0 + floor(Int, (j-1)/3)
            c2 = c0 + (j-1)%3
            k2 = pla(l2, c2)
            push!(contraintesB, Contrainte([k1, k2], filtrage_intersection_vide!))
        end
    end
end
append!(contraintes, contraintesB)




fixer!(variables[2], Set([2]))
fixer!(variables[8], Set([7]))

fixer!(variables[13], Set([1]))
fixer!(variables[15], Set([4]))

fixer!(variables[20], Set([3]))
fixer!(variables[21], Set([1]))
fixer!(variables[25], Set([5]))
fixer!(variables[26], Set([2]))

fixer!(variables[28], Set([3]))
fixer!(variables[29], Set([5]))
fixer!(variables[35], Set([6]))
fixer!(variables[36], Set([9]))

fixer!(variables[pla(5, 1)], Set([8]))
fixer!(variables[pla(5, 9)], Set([2]))

fixer!(variables[pla(6, 4)], Set([6]))
fixer!(variables[pla(6, 6)], Set([5]))

fixer!(variables[pla(7, 3)], Set([7]))
fixer!(variables[pla(7, 5)], Set([3]))
fixer!(variables[pla(7, 7)], Set([4]))

fixer!(variables[pla(8, 3)], Set([3]))
fixer!(variables[pla(8, 4)], Set([4]))
fixer!(variables[pla(8, 6)], Set([8]))
fixer!(variables[pla(8, 7)], Set([6]))

fixer!(variables[pla(9, 5)], Set([9]))

mat = varToMat(variables)
beauPrint(mat)
#status = solver_generique!(variables, contraintes)
status = branch_and_bound!(variables, contraintes)
println("status: ", status ? "faisable" : "infaisable")
mat = varToMat(variables)
beauPrint(mat)
checkMat(mat)
