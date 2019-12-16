using JuMP, Gurobi, MathOptInterface, LinearAlgebra#, CPLEX
function IP(w,g,p,q)
	m = Model(with_optimizer(Gurobi.Optimizer))
	
	@variable(m,x[1:w,1:g,1:q], binary=true)
	@variable(m,z[1:w,1:g,1:q,1:q], binary=true)

	#z=[x[i,j,q1]*x[i,j,q2] for i in 1:w,j in 1:g,q1 in 1:q,q2 in 1:q]
	#z[i,j,q1,q2] = floor((x[i,j,q1]+x[i,j,q2])/2)
	
	#@objective(m,Min,0)
	@constraint(m,ctr1[i=1:w,k=1:q], sum(x[i,j,k] for j in 1:g) == 1)
	@constraint(m,ctr2[i=1:w,j=1:g], sum(x[i,j,k] for k in 1:q) == p)
	@constraint(m,ctraux[i=1:w,j=1:g,q1=1:q-1,q2=q1+1:q],z[i,j,q1,q2]>=x[i,j,q1]+x[i,j,q2]-1)
	@constraint(m,ctr3[q1=1:q-1,q2=q1+1:q], sum(z[i,j,q1,q2] for i in 1:w, j in 1:g) <= 1)

	#@constraint(m,greedy_premiere_semaine[k=1:q,j=1:g;k=j*g],x[i,j,k]==1)

	k = 1
	for jj in 1:g, j in 1:g
		fix(m[:x][1,j,k], 1)
		k+=1
	end

	return m
end

w = 5
g = 5
p = 5
q = g*p

m = IP(w,g,p,q)

@time optimize!(m)
#println(termination_status(m))

x = value.(m[:x])

for i in 1:w	
	println("Semaine ",i)
	for j in 1:g
		println("    Groupe ",j,"  ",findall(x->x==1,x[i,j,:]))
	end
end

