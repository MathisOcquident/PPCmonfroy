using JuMP, GLPK, MathOptInterface, LinearAlgebra, Gurobi#, CPLEX
function IP(n)
	m = Model(with_optimizer(Gurobi.Optimizer))

	@variable(m,x[1:n-1,1:div(n,2),1:n], binary=true)
	@variable(m,z[1:n-1,1:div(n,2),1:n,1:n], binary=true)

	@constraint(m,ctr1[i=1:n-1,j=1:div(n,2)], sum(x[i,j,k] for k in 1:n)==2)
	@constraint(m,ctr2[i=1:n-1,k=1:n], sum(x[i,j,k] for j in 1:div(n,2))==1)
	@constraint(m,ctr3[j=1:div(n,2),k=1:n], sum(x[i,j,k] for i in 1:n-1)<=2)
	@constraint(m,ctraux[i=1:n-1,j=1:div(n,2),k1=1:n-1,k2=k1+1:n], z[i,j,k1,k2]<=x[i,j,k1]/2+x[i,j,k2]/2)
	@constraint(m,ctr4[k1=1:n-1,k2=k1+1:n], sum(z[i,j,k1,k2] for i in 1:n-1 for j in 1:div(n,2))>=1)

	if false
	k = 1
	for j in 1:div(n,2), kk in 1:2
		fix(m[:x][1,j,k], 1)
		k+=1
	end
	end
	return m
end

function main(n::Int=6)
	println("n = ", n)
	m = IP(n)

	@time optimize!(m)
	term = termination_status(m)

	if term == MathOptInterface.OPTIMAL
		x = value.(m[:x])

		for i in 1:n-1
			println("Semaine ",i)
			for j in 1:div(n,2)
				println("    terrain ",j," : ",findall(isodd,map(Int,x[i,j,:])))
			end
		end
	end
end

main(10)
