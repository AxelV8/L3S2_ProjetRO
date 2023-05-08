include("resolution_DFJ.jl")
include("resolution_MTZ.jl")
include("resolution_Glouton.jl")

#= Verneuil - Axel
   Cannavaciuolo - Nello
=#

using JuMP, GLPK

# Modification de la fonction: ajout de 3 booléen désignant quelle fonction lancer. De plus, vous aurez besoin d'appeler ExempleScriptTSP avec les 3 booléens en paramètres=# 
function resolutionRapideDuTSP(C::Matrix{Int64}, B1::Bool, B2::Bool, B3::Bool)
    
    if B1 
        model_solve_MTZ(C)
    elseif B2
        model_solve_DFJ(C)
    else B3
        solve_Glouton(C,1)
    end
end


#=------------------------------------------------------------------------------------------------------------------------------------------------------------------------------=#


# fonction qui prend en paramètre un fichier contenant un distancier et qui retourne le tableau bidimensionnel correspondant
function parseTSP(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")

    # Lecture de la première ligne pour connaître la taille n du problème
    s::String = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
    tab::Vector{Int64} = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau (qui ne contient ici qu'un entier)
    n::Int64 = tab[1]

    # Allocation mémoire pour le distancier
    C = Matrix{Int64}(undef,n,n)

    # Lecture du distancier
    for i in 1:n
        s = readline(f)
        tab = parse.(Int64,split(s," ",keepempty = false))
        for j in 1:n
            C[i,j] = tab[j]
        end
    end

    # Fermeture du fichier
    close(f)

    # Retour de la matrice de coûts
    return C
end


function ExempleScriptTSP(B1::Bool,B2::Bool,B3::Bool)
    # Première exécution sur l'exemple pour forcer la compilation si elle n'a pas encore été exécutée
    C::Matrix{Int64} = parseTSP("../dat/plat/exemple.dat")
    resolutionRapideDuTSP(C,B1,B2,B3)

    file::String = ""
    # Série d'exécution avec mesure du temps pour des instances symétriques
    for i in 10:10:70
        file = "../dat/plat/plat$i.dat"
        C = parseTSP(file)
        println("Instance à résoudre : plat$i.dat")
        @time resolutionRapideDuTSP(C,B1,B2,B3)
    end

    # Série d'exécution avec mesure du temps pour des instances asymétriques
    for i in 10:10:40
        file = "../dat/relief/relief$i.dat"
        println("Instance à résoudre : relief$i.dat")
        C = parseTSP(file)
        @time resolutionRapideDuTSP(C,B1,B2,B3)
    end
end

 
