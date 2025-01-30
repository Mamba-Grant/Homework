using Random, Distributions, GLMakie 

f(x) = x^4 * cos(x)^6

n = 1000
a = 0
b = 2 * π
c = 16 * π^4

rng = MersenneTwister(1234)

@time arr::Vector{Tuple{Float64, Float64}} = [(rand(rng, Uniform(a, b)), rand(rng, Uniform(a, c))) for i in 1:n]
@time in_bounds::Vector{Tuple{Float64, Float64}} = [(arr[i][1], arr[i][2]) for i in 1:n if arr[i][2] < f(arr[i][1])]
@time not_in_bounds::Vector{Tuple{Float64, Float64}} = [(arr[i][1], arr[i][2]) for i in 1:n if !(arr[i][2] < f(arr[i][1]))]


p = length(in_bounds) / n
println("\n", (b * c) * p)

set_theme!(theme_black())
fig = Figure(resolution=(720, 720))
ax = Axis(fig[1, 1], title = "Problem 3 (1000 Samples)", xticks=-1:0.5:8, yticks=-200:200:1800)

lin = lines!( 0:0.01:2*π, f.(0:0.01:2*π), linewidth=3, label=L"x^4cos^6x" )
out = scatter!( first.(not_in_bounds), last.(not_in_bounds), marker=:xcross, color=:red, label="out-of-bounds" ) 
in = scatter!( first.(in_bounds), last.(in_bounds), color=:green, label="in-bounds" )

axislegend(ax, position=:lt)

# save("../assets/MCHitMiss.png", fig, resolution=(800, 800))
fig
