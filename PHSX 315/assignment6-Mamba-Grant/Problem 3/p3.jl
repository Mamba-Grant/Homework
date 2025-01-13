using Random, Distributions, GLMakie 

f(x) = x^4 * cos(x)^6

n = 1000000
a = 0
b = 2 * π
c = 16 * π^4

estimate_array = []
@time for j in 1:100
  rng = MersenneTwister(j)

  arr::Vector{Tuple{Float64, Float64}} = [(rand(rng, Uniform(a, b)), rand(rng, Uniform(a, c))) for i in 1:n]
  in_bounds::Vector{Tuple{Float64, Float64}} = [(arr[i][1], arr[i][2]) for i in 1:n if arr[i][2] < f(arr[i][1])]
  not_in_bounds::Vector{Tuple{Float64, Float64}} = [(arr[i][1], arr[i][2]) for i in 1:n if !(arr[i][2] < f(arr[i][1]))]

  p = length(in_bounds) / n
  append!(estimate_array, (b*c) * p)
end

println("mean estimate: ", mean(estimate_array))
println("uncertainty: ", (b*c)*std(estimate_array)/n )
