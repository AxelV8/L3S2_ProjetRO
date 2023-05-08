using JuMP, GLPK
#= Implémentation basique suivant le modèle décrit dans le projet=#
function model_MTZ(solverSelected::DataType, c::Matrix{Int64})
	
	m::Model = Model(solverSelected)
	
	nbLieu::Int64 = size(c,1)
	
	
	#= le drone va du lieu i au lieu j=#
	@variable(m, x[1:nbLieu, 1:nbLieu], binary = true)
	
	#= Date à laquelle la ville est visité =#
	@variable(m, t[2:nbLieu] >= 0)
	
	@objective(m, Min, (sum(sum(c[i,j]*x[i,j] for j in 1:nbLieu) for i in 1:nbLieu)))

	@constraint(m, Start[i = 1:nbLieu], (sum(x[i,j] for j in 1:nbLieu if j!=i)) == 1) 
	@constraint(m, End[j = 1:nbLieu], (sum(x[i,j] for i in 1:nbLieu if i!=j) == 1))
	@constraint(m, Date[i = 2:nbLieu, j = 2:nbLieu], t[i]-t[j] + nbLieu*x[i,j] <= nbLieu - 1)

	return m
end

function model_solve_MTZ(c::Matrix{Int64})

m::Model = model_MTZ(GLPK.Optimizer,c)

optimize!(m)

status = termination_status(m)

	if status == MOI.OPTIMAL
		println("Optimale !!!")
	
		println("z =", objective_value(m))
	
	elseif status == MOI.INFEASIBLE
		println("Pb non-borné")
		
	elseif status == MOI.INFEASIBLE_OR_UNBOUNDED
		println("Pb impossible")
	end
end
 


