# exemple de format dimacs
#c  simple_v3_c2.cnf
#c
#p cnf 3 2 # 3 var 2 clauses
#1 -3 0 # x1 et non x3 0 veut dire fin de ligne
#2 3 -1 0


w = 7
g = 5
p = 3
q = 15

function pla(i,j,k)
	return i + w*(j-1) + w*g*(k-1)
end  

function printar(ii,jj,i,k,ar)
	print(i)
	for j in 1:k
		print(" ",ar[j])
	end
	println(" 0")
end

function writear(f,ii,jj,i,k,ar)
	for j in 1:k
		write(f,string(pla(ii,jj,ar[j])," "))
	end
	write(f,"0\n")
end
function writearneg(f,ii,jj,i,k,ar)
	for j in 1:k
		write(f,string("-",pla(ii,jj,ar[j])," "))
	end
	write(f,"0\n")
end

function enumar(f,ii1,jj,k,n,sign)
	ar = collect(1:k)
	writear(f,ii1,jj,1,k,ar)
	for i in 2:binomial(n,k)
		ii = 0
		while ii<k
			if ar[end-ii] + 1<=n-ii
				ar[end-ii] = ar[end-ii] + 1
				for iii in k-ii+1:k
					ar[iii] = ar[iii-1]+1
				end
				ii = k
			else 
				ii = ii + 1
			end
		end
		if sign
			writear(f,ii1,jj,i,k,ar)
		else
			writearneg(f,ii1,jj,i,k,ar)
		end
	end
end

function sat(w,g,p,q)
	open("satsgp.cnf","w") do f
	# ctr 1
	for i in 1:w
		for k in 1:q
			s = ""
			for j in 1:g
				s = s*string(pla(i,j,k)," ")
			end
			s = s*"0"
			write(f,s*"\n")
		end
	end
	for i in 1:w
		for j in 1:g-1
			for jj in j+1:g
				for k in 1:q
					write(f,string("-",pla(i,j,k)," -",pla(i,jj,k)," 0\n"))
				end
			end
		end
	end

	# ctr 2
	for ii in 1:w
		for jj in 1:g
			enumar(f,ii,jj,q-p+1,q,true)
		end
	end
	for ii in 1:w
		for jj in 1:g
			enumar(f,ii,jj,p+1,q,false)
		end
	end

	# ctr 3
	for k in 1:q-1
		for kk in k+1:q
			for i in 1:w
				for ii in 1:w
					for j in 1:g
						for jj in 1:g
							if jj != j || ii!=i
								write(f,string("-",pla(i,j,k)," -",pla(i,j,kk)," -",pla(ii,jj,k)," -",pla(ii,jj,kk)," 0\n"))
							end
						end
					end
				end
			end
		end
	end
	end
end

sat(w,g,p,q)
