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
	return i + g*(j-1) + w*g*(k-1)
end  
function zpla(i,j,k,kk)
	return pla(w,g,n) + i + g*(j-1) + w*g*(k-1) + w*g*w*g*(kk-1)
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
				s = s*"0"
				write(f,s*"\n")	
			end
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:q
				for kk in 1:q
					for kkk in 1:q
						if k!=kk && kk!=kkk && k!=kkk
							write(f,string("-",pla(i,j,k)," -",pla(i,j,kk)," -",pla(i,j,kkk)," 0\n"))
						end
					end
				end
			end
		end
	end

	# ctr 2
	for i in 1:w
		for j in 1:g
			s = ""
			for k in 1:q
				s = s*" "*string(pla(i,j,k))
			end
			s = s*" 0"
			write(f,s*"\n")
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:q
				for kk in 1:q
					if k!=kk
						write(f,string("-",pla(i,j,k)," -",pla(i,j,kk)," 0\n"))
					end
				end
			end
		end
	end

	# ctr 3
	for k in 1:q
		for j in 1:g
			for i in 1:w
				for ii in 1:w
					for iii in 1:w
						if i!=ii && ii!=iii && i!=iii
							write(f,string("-",pla(i,j,k)," -",pla(ii,j,k)," -",pla(iii,j,k)," 0\n"))
						end
					end
				end
			end
		end
	end

	# ctr 4
	for i in 1:w
		for j in 1:g
			for k in 1:n
				for kk in 1:n
					if k!=kk
						write(f,string(zpla(i,j,k,kk)," -",pla(i,j,k)," -",pla(i,j,kk)," 0\n"))
					end
				end
			end
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:n
				for kk in 1:n
					if k!=kk
						write(f,string("-",zpla(i,j,k,kk)," ",pla(i,j,k)," 0\n"))
					end
				end
			end
		end
	end
	for i in 1:w
		for j in 1:g
			for k in 1:n
				for kk in 1:n
					if k!=kk
						write(f,string("-",zpla(i,j,k,kk)," ",pla(i,j,kk)," 0\n"))
					end
				end
			end
		end
	end
	for i in 1:w
		for j in 1:g
			s = ""
			for k in 1:n
				for kk in 1:n
					if k!=kk
						s = s*string(zpla(i,j,k,kk)," ")
					end
				end
			end
			s = s*"0"
			write(f,s*"\n")
		end
	end
	end
end

sat(w,g,q)
