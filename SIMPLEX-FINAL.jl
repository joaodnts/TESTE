#..................................................................................
#Dados de entrada
using LinearAlgebra

Tipo_problema = "min"
Inicial = Float64[-3 -5 0; 1 0 4 ; 0 2 12 ; 3 2 18]
Sinais = ["="; "<="; ">="; "<="]



M = 1000


(Qtdd_linha, Qtdd_coluna) = size(Inicial) #Encontrando o tamanho da matriz

Funcao_obj = Inicial[1,1:(Qtdd_coluna-1)] #Criando vetor apenas com a Função objetivo

Independentes = Inicial[1:Qtdd_linha,Qtdd_coluna] #Trazendo um vetor com as variáveis independentes

Tableau_incompleto = Inicial[1:Qtdd_linha, 1:(Qtdd_coluna-1)] #Tableau parcial que recorta o Tableau inicial


if Tipo_problema == "min" #Definindo a tipologia do problema
    Tableau_incompleto[1,:] = Inicial[1, 1:(Qtdd_coluna-1)] * (-1)
else 
    Tableau_incompleto[1,:] = Inicial[1, 1:(Qtdd_coluna-1)] 
end

Add_FO = Float64[] #Vetor vazio, será acrescentado o M de acordo aos sinais

for i = 2:Qtdd_linha
    if Sinais[i] == ">="
        push!(Add_FO, 0.0)
        push!(Add_FO, M)
    elseif Sinais[i] == "="
        push!(Add_FO, M)
    else 
        push!(Add_FO, 0.0)
    end
end

Add_FO_t = Add_FO' #Transpõe o vetor para que seja coluna única

k = 0 #Determinará a quantidade necessária de variáveis a serem acrescentadas na Função Objetivo 

for i = 2:Qtdd_linha
    global k

    if  Sinais[i] == ">="
        k = k+2
    else
        k = k+1
    end
end


MatrizArtFol = zeros(Qtdd_linha-1, k) #Matriz que guardará os índices das variáveis de folga e artificiais

n = 0
for i = 2:Qtdd_linha
    global n
    if Sinais[i] == ">="
        n = n+1
    MatrizArtFol[i-1, n] = -1
        n = n+1
    MatrizArtFol[i-1, n] = 1
    else
        n = n+1
    MatrizArtFol[i-1, n] = 1
    end
end


Matriz_composicao = [Add_FO_t ; MatrizArtFol]
MatrizSum = [Tableau_incompleto Matriz_composicao Independentes] #Composição da matriz pra o tableau
Tableau = [Tableau_incompleto Matriz_composicao Independentes]

(Qtdd_linha_sum, Qtdd_coluna_sum) = size(MatrizSum)


for i = 2:Qtdd_linha_sum
    if Sinais[i] == "<="
        MatrizSum[i,:] = MatrizSum[i,:] * 0
    else
        MatrizSum[i,:] = MatrizSum[i,:] * (-M)
    end
end

SomaTotal_l0 = sum(MatrizSum, dims=1)

Tableau[1, :] = SomaTotal_l0 

#..................................................................................



println("Tableau inicial:  ")
println(Tableau)
(Qtd_linha, Qtd_coluna) = size(Tableau)

iteracao = 0

while minimum(Tableau[1, 1:Qtd_coluna-1])<0

    global iteracao = iteracao + 1
    println("")
    println("")
    println("Iteracao: ", iteracao)
    #..................................................................................
        #Definição de coluna pivô
        for j = 1:Qtd_coluna-1
            global Coluna_pivo
            if minimum(Tableau[1,1:Qtd_coluna-1]) == Tableau[1, j]
                Coluna_pivo = j
            end
        end
    
     #println("coluna pivo  ",Coluna_pivo)   
    #..................................................................................
        #Definição de variável a sair da base
        Sai_var = minimum(Tableau[1,:])
    
    #..................................................................................
        #Teste de razão e definição de linha pivô
    
        m = []
       
        
        for i = 1:Qtd_linha
            if Tableau[i, Qtd_coluna]/Tableau[i, Coluna_pivo] <= 0
                push!(m, 1000)
            else
            push!(m, (Tableau[i , Qtd_coluna]/Tableau[i , Coluna_pivo]))
           
            end    
        end
        


        for i = 1:Qtd_linha
         global Indice_linha
         if minimum(m[2:Qtd_linha, 1]) == m[i, 1]
                Indice_linha = i
           end
        end       
        Menor_razao = minimum(m)
        #println("Razao minima", m)
       # println("Menor valor", minimum(Raz_min[:,1]))
        #println("indice da linha pivô: ", Indice_linha)
    
    #..................................................................................
        #Definição do elemento pivô
    
        Elemento_pivo = Tableau[Indice_linha, Coluna_pivo]
    
      #println("o elemento pivo: ", Elemento_pivo)
    
    #..................................................................................
        #Definição da nova linha pivô
    
      Nova_linha_pivo = Tableau[Indice_linha, :]/ Elemento_pivo
    
    
    
        #println("nova linha pivo: ", Nova_linha_pivo)
    
    #..................................................................................
        #Definição das novas linhas
    
    
        for i = 1:Qtd_linha
    
            if i == Indice_linha
                Tableau[i,:] = Nova_linha_pivo
            else
            Tableau[i, :] = Nova_linha_pivo*(-1)*Tableau[i,Coluna_pivo]+Tableau[i,:]
            end
        end
    
    
        println(Tableau)
    end

if Tableau[1, Qtd_coluna]<0
    OFV = Tableau[1, Qtd_coluna]*(-1)
else
    OFV = Tableau[1, Qtd_coluna]
end
     println("")
println("OBJECTIVE FUNCTION VALUE   ", OFV)


#Zero = zeros(Int8, 1, Qtd_linha-1)
#Identidade = Matrix{Float64}(I, Qtd_linha-1, Qtd_linha-1)
(Tam_linhas, Tam_colunas) = size(Inicial)

#Zero = zeros(Int8, 1, Qtdd_linha-1)
#Identidade = Matrix{Float64}(I, Qtdd_linha-1, Qtdd_linha-1)
Independente2 = Inicial[:,Qtdd_coluna]

Principal = Inicial[1:Qtd_linha, 1:Qtdd_coluna-1]

#Tableau_ZI = [Zero;Identidade]
tableau = [Principal Independente2]

Independente_dual = Independente2[2:Qtd_linha,1]'
Principal_dual = Principal[2:Qtdd_linha,1:Qtdd_coluna-1]'
Result_dual = Inicial[1,1:Qtdd_coluna-1]
Zero_dual = zeros(Int8, 1, 1)

#Zero_Indep = [Independente_dual Zero_dual]
Inicial_dual = [Principal_dual Result_dual]
#Inicial_dual = [Zero_Indep; PR]

Inicial_dual[1,:] = Inicial_dual[1,:] * (-1)


Sinais_dual = []
        
for i = 1:Qtdd_linha
    if Sinais[i,1] == ">="
        push!(Sinais_dual, "<=")
    elseif Sinais[i,1] == "<="
        push!(Sinais_dual, ">=")
    else
        push!(Sinais_dual, "=")    
    end
end

y = []

for i = 2:Qtdd_linha
    global y
    if Tipo_problema == "max"
     Tipo_problema_dual = "min"
        if Sinais[i] == "<="
        push!(y, ">= 0")
        elseif Sinais[i] == ">="
        push!(y, "<= 0")
        else
        push!(y, "livre")
        end
    else
    Tipo_problema_dual = "max"
        if Sinais[i] == "<="
        push!(y, "<= 0")
        elseif Sinais[i] == ">="
        push!(y, ">= 0")
        else
        push!(y, "livre")
        end
    end
end

#println(Inicial_dual)

println("Dual:  ")
println("")
println(Inicial_dual)
println("")
println("Sinais do dual:")
println(Sinais_dual)

(Qtd_linha_dual,Qtd_coluna_dual) = size(Inicial_dual)


g = []
for i = 1:Qtd_coluna_dual-1
    global g
    push!(g, println("y", i)) 
    println(y[i]) 
end

Solucao_otm_dual = Tableau[1,(Qtd_coluna-Qtdd_coluna):Qtd_coluna-1]
println("Solucao otima do dual:  ")
println(Solucao_otm_dual)


#println("sinais do y")
#println(g)
#println(y)