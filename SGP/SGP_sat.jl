w = 4
g = 4
p = 4
q = g*p

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

function greedy_premiere_semaine(f)
	k = 1
	for kk in 1:g, j in 1:g
		write(f,string(pla(1,j,k)," 0 \n"))
		k+=1
	end
end

function sat(w,g,p,q)
	open("satsgp.cnf","w") do f
	greedy_premiere_semaine(f)
	# ctr 1
	for i in 1:w, k in 1:q
		s = ""
		for j in 1:g
			s = s*string(pla(i,j,k)," ")
		end
		s = s*"0"
		write(f,s*"\n")
	end
	for i in 1:w, j in 1:g-1, jj in j+1:g, k in 1:q
		write(f,string("-",pla(i,j,k)," -",pla(i,jj,k)," 0\n"))
	end

	# ctr 2
	for ii in 1:w, jj in 1:g
		enumar(f,ii,jj,q-p+1,q,true)
	end
	for ii in 1:w, jj in 1:g
		enumar(f,ii,jj,p+1,q,false)
	end

	# ctr 3
	for k in 1:q-1, kk in k+1:q, i in 1:w, ii in 1:w, j in 1:g, jj in 1:g
		if jj != j || ii!=i
			write(f,string("-",pla(i,j,k)," -",pla(i,j,kk)," -",pla(ii,jj,k)," -",pla(ii,jj,kk)," 0\n"))
		end
	end
	end
end

sat(w,g,p,q)
