using StatsBase
using Random
using Plots

PESOS = [16, 18, 1, 8, 12, 0, 5, 6, 2, 13]
VALORES = [32, 20, 25, 11, 35, 50, 47, 34, 19, 33]
PESO_MAX = 50
TOTAL_CROMOSSOMOS = length(pesos)
rng = MersenneTwister(42)

# Funções com "!" alteram o conteúdo do dado

# Valida peso
function valida_peso(x)
    valor = sum(x .* pesos)
    if valor >= PESO_MAX
        return 0
    end
    return valor
end

# Geração
function gera_pop(tamanho_populacao)
    pop = [;]
    i = 0
    while i < tamanho_populacao
        ind = rand(0:1, TOTAL_CROMOSSOMOS)
        peso = valida_peso(ind)
        # println("Ind:Peso - ", ind, peso)
        if peso != 0
            push!(ind, peso)
            push!(pop, ind)
            i += 1
        end
    end
    return pop
    # return [rand(0:1, TOTAL_CROMOSSOMOS) for j=1:tamanho_populacao]    
end

# Fitness
function fitness(x)
    return sum(x .* VALORES)
end

# Sorteios
function elitismo(pop, num_ind)
    sort!(pop, by=x -> x[TOTAL_CROMOSSOMOS + 2], rev=true)
    return pop[1:num_ind]
end

function sorteio_aleatorio(pop, num_ind)
    indexes = sort!(sample(1:length(pop), num_ind, replace=false))
    return pop[indexes]
end

function sorteio_roleta(pop, num_ind)
    new_pop = [;]
    total = sum(last(i) for i in pop)
    props = [last(i) / total for i in pop]
    for j = 1:num_ind
        r = rand(rng, 1)[1]
        diff = [abs(i - r) for i in props]
        push!(new_pop, pop[findmin(diff)[2]])
    end
    return new_pop
end

function sorteio_torneio(pop, num_ind, num_sample)
    new_pop = [;]
    for i = 1:num_ind
        indexes = sample(1:length(pop), num_sample, replace=false, ordered=true)
        chosen = copy(pop[indexes])
        sort!(chosen, by=x -> x[TOTAL_CROMOSSOMOS + 2], rev=true)
        push!(new_pop, chosen[1])
    end
    return new_pop
end

# Cruzamento
function one_point(parents)
    point = sample(2:TOTAL_CROMOSSOMOS - 1, 1)[1]
    pA = parents[1][1:point]
    pB = parents[2][point + 1:TOTAL_CROMOSSOMOS]
    return vcat(pA, pB)
end

function two_points(parents)
    points = sample(2:TOTAL_CROMOSSOMOS - 1, 2, replace=false, ordered=true)
    pA = parents[1][1:points[1]]
    pB = parents[2][points[1] + 1:points[2]]
    pA = vcat(pA, parents[1][points[2] + 1:TOTAL_CROMOSSOMOS])
    return vcat(pA, pB)  
end

function uniform(parents)
    perc = 0.25
    indexes = sample(1:TOTAL_CROMOSSOMOS, round(Int, perc * TOTAL_CROMOSSOMOS), replace=false, ordered=true)
    parents[2][indexes] = parents[1][indexes]
    return parents[2][1:TOTAL_CROMOSSOMOS]
end

# Mutação
function mutacao(x, prob)
    if rand(rng, 1)[1] <= prob
        idx = sample(1:TOTAL_CROMOSSOMOS, 1)[1]
        x[idx] = 1 - x[idx]
    end
    return x
end

# Valida população
function valida_populacao(pop)
    for i in pop
        push!(i, valida_peso(i[1:TOTAL_CROMOSSOMOS]))
        if last(i) == -1
            push!(i, 0)
        else
            push!(i, fitness(i[1:TOTAL_CROMOSSOMOS]))
        end
    end
    return pop
end

# Main
iter = 0
tamanho_populacao = 30
num_ind = 6
prop_mutacao = 0.05
melhores = []

# Gera população
pop = gera_pop(tamanho_populacao)
# println("Init pop: ", pop)
pop = [push!(i, fitness(i[1:TOTAL_CROMOSSOMOS])) for i in pop]

while iter < 50
    filhos = []
    pop = sorteio_roleta(pop, num_ind)
    new_pop = gera_pop(tamanho_populacao / 2 - num_ind)
    pop = vcat(pop, [push!(i, fitness(i[1:TOTAL_CROMOSSOMOS])) for i in new_pop])
    # println("Pop; ", pop)
    i = 0
    while i < tamanho_populacao / 2
        indexes = sample(1:length(pop), 2, replace=false, ordered=true)
        # println("Idx: ", indexes)
        filho = one_point(pop[indexes])
        filho = mutacao(filho, prop_mutacao)
        peso = valida_peso(filho)
        if peso > 0
            push!(filho, peso)
            push!(filho, fitness(filho[1:TOTAL_CROMOSSOMOS]))
            push!(filhos, filho)
            i += 1
        end
    end
    # println("Fil: ", filhos)
    pop = vcat(pop, filhos)
    push!(melhores, last(sort!(pop, by=x -> x[TOTAL_CROMOSSOMOS + 2], rev=true)[1]))
    iter += 1
end

# println(pop)
# println("Mel: ", melhores)
plot(1:iter, melhores, label="fitness")