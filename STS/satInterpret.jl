
global n
global w
global g
global q

function alp(x)
	k = min(div(x,w*g)+1,q)
	xx = x - w*g*(k-1)

	j = min(div(xx,g)+1,g)
	i = xx-g*(j-1)
	if i==0
		j=j-1
		i=g
	end
	return i,j,k
end

function interpret()
	x = zeros(Int,w,g,q)
	ss = Vector{Int}(undef,zpla(w,g,q-1,q)+1)
	open("res.out") do f
		s = readlines(f)
		println(s[1])
		s = split(s[2]," ")
		for i in 1:size(s,1)
			ss[i]=parse(Int,s[i])
		end
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
			println("    Match ",j,"  ",x[i,j,:])
		end
	end
end


interpret()

