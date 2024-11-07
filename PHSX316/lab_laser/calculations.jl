using Statistics

Δy = ([1.75, 3.25, 4.5, 11] ./ 2) .* 10^-3
m = [1, 2, 3, 4]
D = 1.0193
θ = @. atan(Δy / D)
λ = 650e-9
d = @. m * λ / sin(θ)

println("D: $(mean(d) * 10^3) mm")
