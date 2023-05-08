#= Fonction principale=#
function solve_Glouton(M::Matrix{Int64},start_city::Int64)
#= On pose i l'entier de référence et j celui qui va être modifié=#
i::Int64 = start_city
j::Int64 = i

#= Pratique moyenne, pourrait être améliorée=#
tmp::Int64 = 9999999999

#= On initialise la matrice d'état =#
passage_Matrix::Vector{Bool} = fill(false, size(M,2))


cycle::Vector{Int64} = []

distance::Int64 = 0
#= On ajoute le premier point dans la liste=#

push!(cycle,start_city)
passage_Matrix[start_city] = true

#= Début de la boucle pour parcourir la matrice de distances =#
while (is_True(passage_Matrix) != true)
	
    #= On parcourt la ligne de la matrice pour récupérer la plus petite distance dans des variables temporaires'=#
	for k in 1:size(M,1)
		if (M[i,k] < tmp && passage_Matrix[k] != true)
			
			tmp = M[i,k]
			j = k
		end
	end
    #= Ajout de la distance =#
	distance += tmp
	
	tmp = 99999999999
	passage_Matrix[j] = true
    #= On passe sur la ligne suivante =#
	i = j
	push!(cycle, j)	
	
end
	#= Ne pas oublier d'ajouter la dernière distance dans le compteur.=#
	distance += M[j,start_city]
	println("Distance totale de la boucle quand on commence par le point numéro"," ",start_city," ","est"," ",distance,"\n")
	println("Ce vecteur représente l'ordre des points traversées:"," ", cycle)
end


#= Fonction qui vérifie l'état de la matrice =#
function is_True(passage_Matrix::Vector{Bool})
	
	for i in 1:length(passage_Matrix)
		if passage_Matrix[i] == false
			return false
		end
	end
return true
end
	
