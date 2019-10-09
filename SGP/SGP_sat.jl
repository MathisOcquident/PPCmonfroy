# exemple de format dimacs
#c  simple_v3_c2.cnf
#c
#p cnf 3 2 # 3 var 2 clauses
#1 -3 0 # x1 et non x3 0 veut dire fin de ligne
#2 3 -1 0


w = 4
g = 4
p = 4
q = 16

function pla(i,j,k)
	return i + g*(j-1) + w*g*(k-1)
end  

cpt = 1




# ctr 3
for k in 1:q
	for kk in 1:q
		if kk != k
			for i in 1:w
				for ii in 1:w
					if ii != i
						for j in 1:g
							for jj in 1:g
								if jj != j
									println(cpt," -",pla(i,j,k)," -",pla(i,j,kk)," -",pla(ii,jj,k)," -",pla(ii,jj,kk)," 0")
									global cpt = cpt + 1
								end
							end
						end
					end
				end
			end
		end
	end
end


