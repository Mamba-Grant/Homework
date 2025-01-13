using Base.Threads, Distributions, Random, GLMakie
include("../Problem 1/p1.jl")

RESOLUTION = (950,720)
n = 1000

# Implement my custom sampler from p1
sampler = CustomSampler()
fortune_arr = [] 

@threads for i in 1:1000
  rng = MersenneTwister(i)
  arr = [rand(rng, CustomSampler()) for i in 1:1000]
  append!(fortune_arr, sum(arr))
end

println("first: ", fortune_arr[1])
println("mean:  ", mean(fortune_arr))
println("rms:   ", sqrt(sum(fortune_arr .^ 2) / n))
println("max:   ", maximum(fortune_arr))
println("min:   ", minimum(fortune_arr))

set_theme!(theme_black())
fig = Figure(resolution=RESOLUTION)
hist(
  fig[1, 1],
  bar_labels = :values,
  label_formatter=x-> round(x, digits=2), label_size = 15,
  fortune_arr, 
  bins=25,
  color=:values
)
# save("../assets/FortuneDist.png", fig, resolution=RESOLUTION)
fig
