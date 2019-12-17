
global n
global w
global g
global q

function alp(x)
	k = min(div(x,w*g)+1,q)
	xx = x - w*g*(k-1)
	if xx == 0
		k=k-1	
		xx = w*g
	end
	j = min(div(xx,w)+1,g)
	i = xx-w*(j-1)
	if i==0
		j=j-1
		i=w
	end
	return i,j,k
end

function interpret()
	x = zeros(Int,w,g,q)
	ss = Vector{Int}(undef,zpla(w,g,q-1,q)+1)
	open("res.out") do f
		s = readlines(f)
		println(s[1])
		if s[1] == "SAT" || s[1] == "sat"
			s = split(s[2]," ")
			for i in 1:size(s,1)
				ss[i]=parse(Int,s[i])
			end
		
			s = ss[1:pla(w,g,q)]
			;println(s)
			for l in 1:size(s,1)
				if s[l]>0
					i,j,k = alp(s[l])
					x[i,j,k]=1
				end
			end
			for i in 1:w
				println("Semaine ",i)
				for j in 1:g
					println("    terrain ",j," : ",findall(isodd,x[i,j,:]))
				end
			end
		end
	end
end


interpret()

