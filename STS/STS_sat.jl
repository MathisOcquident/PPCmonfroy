# exemple de format dimacs
#c  simple_v3_c2.cnf
#c
#p cnf 3 2 # 3 var 2 clauses
#1 -3 0 # x1 et non x3 0 veut dire fin de ligne
#2 3 -1 0

n = 6
w = n-1
g = div(n,2)
q = n

function pla(i,j,k)
	return i + w*(j-1) + w*g*(k-1)
end  
function zpla(i,j,k,kk)
	return pla(w,g,q) + i + w*(j-1) + w*g*(k-1) + w*g*w*g*(kk-1)
end 

function sat(w,g,q)
	open("satsts.cnf","w") do f
	# ctr 1
	for i in 1:w
		for j in 1:g
			for kk in 1:q
				s = ""
				for k in 1:q
					if k != kk
						s = s*string(pla(i,j,k)," ")
					end
				end
				write(f,s*"0\n")	
			end
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:q-2
				for kk in k+1:q-1
					for kkk in kk+1:q
						write(f,string("-",pla(i,j,k)," -",pla(i,j,kk)," -",pla(i,j,kkk)," 0\n"))
					end
				end
			end
		end
	end

	# ctr 2
	for i in 1:w
		for k in 1:q
			s = ""
			for j in 1:g
				s = s*string(pla(i,j,k)," ")
			end
			write(f,s*"0\n")
		end
	end
	for i in 1:w
		for k in 1:q
			for j in 1:g-1
				for jj in j+1:g
					write(f,string("-",pla(i,j,k)," -",pla(i,jj,k)," 0\n"))
				end
			end
		end
	end

	# ctr 3
	for k in 1:q
		for j in 1:g
			for i in 1:w-2
				for ii in i+1:w-1
					for iii in ii+1:w
						write(f,string("-",pla(i,j,k)," -",pla(ii,j,k)," -",pla(iii,j,k)," 0\n"))
					end
				end
			end
		end
	end

	# ctr 4
	for i in 1:w
		for j in 1:g
			for k in 1:q-1
				for kk in k+1:q
					write(f,string(zpla(i,j,k,kk)," -",pla(i,j,k)," -",pla(i,j,kk)," 0\n"))
				end
			end
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:q-1
				for kk in k+1:q
					write(f,string("-",zpla(i,j,k,kk)," ",pla(i,j,k)," 0\n"))
				end
			end
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:q-1
				for kk in k+1:q
					write(f,string("-",zpla(i,j,k,kk)," ",pla(i,j,kk)," 0\n"))
				end
			end
		end
	end
	for i in 1:w
		for j in 1:g
			s = ""
			for k in 1:q-1
				for kk in k+1:q
					s = s*string(zpla(i,j,k,kk)," ")
				end
			end
			write(f,s*"0\n")
		end
	end
	end
end

sat(w,g,q)
