using Distributions, Random, GLMakie

global temporary_samples::Vector{Float64} = []
global sample_times::Vector{Float64} = []
ITERATIONS = 1000

f(x::Real) = x^4 * cos(x)^6
pdf(x) = f(x::Real)/736.26959
struct CustomSampler <: Sampleable{Univariate, Continuous}
end

function Distributions.rand(rng::AbstractRNG, sampler::CustomSampler)
  while true
    x = rand(rng, Uniform(0, 2*π))
    y = rand(rng, Uniform(0, 1))
    
    append!(temporary_samples, x)
    append!(temporary_samples, y)

    if y <= pdf(x) * 2*π
      return x
    end
  end
end

sampler = CustomSampler()
sample_numbers = []

for i in 1:ITERATIONS+1
  global temporary_samples::Vector{Float64} = []
  global compilation_time::Vector{Float64} = []

  r = @timed rand(sampler, ITERATIONS+1)
  append!(sample_numbers, length(temporary_samples))
  append!(sample_times, r.time)
end 

popfirst!(sample_numbers)
popfirst!(sample_times)

println("--- SAMPLE COUNTS ---\n")
println("    mean: ", mean(sample_numbers)) 
println("    rms:  ", sqrt(sum(sample_numbers .^ 2) / ITERATIONS+1))
println("    max:  ", maximum(sample_numbers))
println("    min:  ", minimum(sample_numbers))

println("\n--- SAMPLE TIMES ---\n")
println("    mean: ", mean(sample_times)) 
println("    rms:  ", sqrt(sum(sample_times .^ 2) / ITERATIONS+1))
println("    max:  ", maximum(sample_times))
println("    min:  ", minimum(sample_times))

println("\n--- END ---\n")

set_theme!(theme_black())
fig = Figure(resolution = (800, 450))
ax1 = Axis(fig[1, 1])
ax2 = Axis(fig[1, 2])

hist1 = hist!(ax1, sample_numbers, color=:values, bar_labels = :values, label_formatter = x->round(x, digits=2), label_size = 12, bins = 15)
hist2 = hist!(ax2, sample_times, color=:values, bar_labels = :values, label_formatter = x->round(x, digits=2), label_size = 12, bins = 15)

# save("../assets/p1_profile.png", fig, resolution=(800, 450))
fig
