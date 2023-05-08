using JuMP, GLPK

#= Fonction modèle =#
function model_DFJ(solverSelected::DataType, c::Matrix{Int64}, cycle::Vector{Tuple{Int64,Int64}}, vector_Of_Loop::Vector{Vector{Tuple{Int64,Int64}}}, fly_i_j::Vector{Tuple{Int64,Int64}})
	
	m::Model = Model(solverSelected)
	
	nbLieu::Int64 = size(c,1)
	acc::Int64 = 0
	
	#= le drone va du lieu i au lieu j=#
	@variable(m, x[1:nbLieu, 1:nbLieu], binary = true)		
	
	@objective(m, Min, (sum(sum(c[i,j]*x[i,j] for j in 1:nbLieu) for i in 1:nbLieu)))

	@constraint(m, Start[i = 1:nbLieu], (sum(x[i,j] for j in 1:nbLieu if j!=i)) == 1) 
	@constraint(m, End[j = 1:nbLieu], (sum(x[i,j] for i in 1:nbLieu if i!=j) == 1))
	
	optimize!(m)
        #= Début de la casse des cycles existants =#
        while (length(vector_Of_Loop) != 1)
	        
            cycle = []
		    vector_Of_Loop = []
	        passage_Vector::Vector{Bool} = fill(false, size(value.(m[:x]),1))	
            #= On récupère la matrice de la variable x contenant les permutations =#
            x_matrix = value.(m[:x])
            #= Appel de la fonction qui converti en permutation =#
	        fly_i_j = convertion_M_V(x_matrix)
	        
	        #= On passe de la permutation au produit de cycles disjoint =#
	        vector_Of_Loop = transform_into_loops(fly_i_j, passage_Vector)
	        
            #= Si le vector_Of_Loop n'a q'un cycle on a fini en pleine boucle. On break =#
		    if( length(vector_Of_Loop) == 1)
				
			    println("\n","On ajoute ", acc," contraintes. Le cycle final est:","\n",vector_Of_Loop)
		        break
	        end
		    #= Le vecteur_Of_Loop possède plusieurs cycle, on récupère le plus petit =#
	        cycle = min_Loop(vector_Of_Loop)
	        
            #= On ajoute ce cycle dans une nouvelle contrainte =#
            test = @expression(m, 1.0*x[(cycle[1])[1],(cycle[1])[2]])

    		for i in 2:length(cycle)
		        add_to_expression!(test, 1.0, x[(cycle[i])[1],(cycle[i])[2]])
		    end
		
	        @constraint(m, test <= length(cycle)-1 )
		    acc += 1
            fly_i_j = []
		    optimize!(m)
		
        end
    	
	return m
end

#= Fonction qui parcours la matrice x. Si elle repère une permutation, elle la récupère dans le vecteur  =# 
function convertion_M_V(M::Matrix{Float64})
	test::Vector{Tuple{Int64,Int64}} = []

	for i in 1:size(M,1), j in 1:size(M,2)
		
		if (M[i,j] == 1.0)
			
			push!(test, (i,j))
			
		end
	end
	return test
end

#= Fonction qui parcours la permutation et la transforme en cycle =#
function transform_into_loops(fly_i_j::Vector{Tuple{Int64,Int64}}, passage_Vector::Vector{Bool})
	vector_Of_Loop::Vector{Vector{Tuple{Int64,Int64}}} = []
	acc::Int64 = 1
	tmp::Vector{Tuple{Int64,Int64}} = []	
	while (is_True(passage_Vector) != 1)

		while (passage_Vector[acc] != false)
			acc +=1
		end
		
		i::Int64 = (fly_i_j[acc])[1]
		j::Int64 = (fly_i_j[acc])[2]
		
		push!(tmp, fly_i_j[acc])
		passage_Vector[acc] = 1
			
		while (j != i)
			push!(tmp, fly_i_j[j])
			passage_Vector[j] = 1
			
			
			j = (fly_i_j[j])[2]
			
		end
		push!(vector_Of_Loop, tmp)
		
		tmp = []
		acc += 1
		
	end
	
	return vector_Of_Loop	
end

#= Regarde l'état du vecteur d'état =#
function is_True(passage_Vector::Vector{Bool})
	for i in 1:length(passage_Vector)
		if passage_Vector[i] == false
			return false
		end
	end
	return true
end

			
#= prend le produit de cycle et retourne le plus petit cycle sous forme de vecteur =#
function min_Loop(vector_Of_Loop::Vector{Vector{Tuple{Int64,Int64}}})
	test::Vector{Tuple{Int64,Int64}} = vector_Of_Loop[1]	
	for i in 2:length(vector_Of_Loop)
		if length(vector_Of_Loop[i]) < length(test)
			
			test = vector_Of_Loop[i]
		end
	end
	return test
end

#= main function =#
function model_solve_DFJ(c::Matrix{Int64})

cycle::Vector{Tuple{Int64,Int64}} = []


fly_i_j::Vector{Tuple{Int64,Int64}} = []


vector_Of_Loop::Vector{Vector{Tuple{Int64,Int64}}} = []

n::Model = model_DFJ(GLPK.Optimizer, c, cycle, vector_Of_Loop, fly_i_j)

status = termination_status(n)

	if status == MOI.OPTIMAL
		println("Optimale !!!")
	
		println("z =", objective_value(n))
		
		
	
	elseif status == MOI.INFEASIBLE
		println("Pb non-borné")
		
	elseif status == MOI.INFEASIBLE_OR_UNBOUNDED
		println("Pb impossible")
	end
end
