using JuMP, GLPK, MathOptInterface, LinearAlgebra#, CPLEX
function IP(w,g,p,q)
	m = Model(with_optimizer(GLPK.Optimizer))
	
	@variable(m,x[1:w,1:g,1:q], binary=true)
	@variable(m,z[1:w,1:g,1:q,1:q], binary=true)

	#z=[x[i,j,q1]*x[i,j,q2] for i in 1:w,j in 1:g,q1 in 1:q,q2 in 1:q]
	#z[i,j,q1,q2] = floor((x[i,j,q1]+x[i,j,q2])/2)
	
	#@objective(m,Min,0)
	@constraint(m,ctr1[i=1:w,k=1:q], sum(x[i,j,k] for j in 1:g) == 1)
	@constraint(m,ctr2[i=1:w,j=1:g], sum(x[i,j,k] for k in 1:q) == p)
	@constraint(m,ctraux[i=1:w,j=1:g,q1=1:q,q2=1:q;q1!=q2],z[i,j,q1,q2]>=x[i,j,q1]+x[i,j,q2]-1)
	@constraint(m,ctr3[q1=1:q,q2=1:q;q1!=q2], sum(  z[i,j,q1,q2] for i in 1:w, j in 1:g) <= 1)
	return m
end

w = 4
g = 4
p = 4
q = 16

m = IP(w,g,p,q)

optimize!(m)
println(termination_status(m))

x = value.(m[:x])

for i in 1:w	
	println("Semaine ",i)
	for j in 1:g
		println("    Groupe ",j,"  ",x[i,j,:])
	end
end

