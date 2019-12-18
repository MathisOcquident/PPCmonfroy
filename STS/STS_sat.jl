n = 10
w = n-1
g = div(n,2)
q = n

function pla(i,j,k)
	return i + w*(j-1) + w*g*(k-1)
end  
function zpla(i,j,k,kk)
	return pla(w,g,q) + i + w*(j-1) + w*g*(k-1) + w*g*w*g*(kk-1)
end 

function s1(f)# glouton pour fixer la première semaine
	k = 1
	for j in 1:div(n,2), kk in 1:2
		write(f,string(pla(1,j,k)," 0\n"))
		k+=1
	end
end

function sat(w,g,q)
	open("satsts.cnf","w") do f
	s1(f)
	# ctr 1
	for i in 1:w, j in 1:g, kk in 1:q
		s = ""
		for k in 1:q
			if k != kk
				s = s*string(pla(i,j,k)," ")
			end
		end
		write(f,s*"0\n")	
	end
	for i in 1:w, j in 1:g, k in 1:q-2, kk in k+1:q-1, kkk in kk+1:q
		write(f,string("-",pla(i,j,k)," -",pla(i,j,kk)," -",pla(i,j,kkk)," 0\n"))
	end

	# ctr 2
	for i in 1:w, k in 1:q
		s = ""
		for j in 1:g
			s = s*string(pla(i,j,k)," ")
		end
		write(f,s*"0\n")
	end
	for i in 1:w, k in 1:q, j in 1:g-1, jj in j+1:g
		write(f,string("-",pla(i,j,k)," -",pla(i,jj,k)," 0\n"))
	end

	# ctr 3
	for k in 1:q, j in 1:g, i in 1:w-2, ii in i+1:w-1, iii in ii+1:w
		write(f,string("-",pla(i,j,k)," -",pla(ii,j,k)," -",pla(iii,j,k)," 0\n"))
	end

	# ctr 4
	for i in 1:w, j in 1:g, k in 1:q-1, kk in k+1:q
		write(f,string(zpla(i,j,k,kk)," -",pla(i,j,k)," -",pla(i,j,kk)," 0\n"))
	end
	for i in 1:w, j in 1:g, k in 1:q-1, kk in k+1:q
		write(f,string("-",zpla(i,j,k,kk)," ",pla(i,j,k)," 0\n"))
	end
	for i in 1:w, j in 1:g, k in 1:q-1, kk in k+1:q
		write(f,string("-",zpla(i,j,k,kk)," ",pla(i,j,kk)," 0\n"))
	end
	for k in 1:q-1, kk in k+1:q
		s = ""
		for i in 1:w, j in 1:g
			s = s*string(zpla(i,j,k,kk)," ")
		end
		write(f,s*"0\n")
	end
	end
end

sat(w,g,q)
