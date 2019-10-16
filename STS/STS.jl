using JuMP, GLPK, MathOptInterface, LinearAlgebra, Gurobi#, CPLEX
function IP(n)
	m = Model(with_optimizer(Gurobi.Optimizer))

	@variable(m,x[1:n-1,1:div(n,2),1:n], binary=true)
	@variable(m,z[1:n-1,1:div(n,2),1:n,1:n], binary=true)

	@constraint(m,ctr1[i=1:n-1,j=1:div(n,2)], sum(x[i,j,k] for k in 1:n)==2)
	@constraint(m,ctr2[i=1:n-1,k=1:n], sum(x[i,j,k] for j in 1:div(n,2))==1)
	@constraint(m,ctr3[j=1:div(n,2),k=1:n], sum(x[i,j,k] for i in 1:n-1)<=2)
	@constraint(m,ctraux[i=1:n-1,j=1:div(n,2),k1=1:n,k2=1:n;k1!=k2], z[i,j,k1,k2]<=x[i,j,k1]/2+x[i,j,k2]/2)
	@constraint(m,ctr4[k1=1:n,k2=1:n;k1!=k2], sum(z[i,j,k1,k2] for i in 1:n-1 for j in 1:div(n,2))>=1)
	return m
end

n = 6

m = IP(n)

optimize!(m)
println(termination_status(m))

x = value.(m[:x])

for i in 1:n-1
	println("Semaine ",i)
	for j in 1:div(n,2)
		println("    Match ",j,"  ",x[i,j,:])
	end
end
