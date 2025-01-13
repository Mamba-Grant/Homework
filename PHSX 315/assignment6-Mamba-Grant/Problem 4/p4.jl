using Random, Distributions

f(x) = x^4*cos(x)^6
a = 0
b = 2*π
n = 1000

estimate_array::Vector{Float64} = []
@time for i in 1:1000 
  rng = MersenneTwister(i)
  values::Vector{Float64} = [rand(rng, Uniform(a, b)) for i in 1:n]
  
  estimate = (b-a) * 1/(n) * sum(f.(values))
  append!(estimate_array, estimate)
end

println("Estimate: ", mean(estimate_array))
println("STDEV: ", std(estimate_array))
