using Distributions, Random

f(x::Real) = x^4 * cos(x)^6
pdf(x) = f(x::Real)/736.26959

struct CustomSampler <: Sampleable{Univariate, Continuous}
end

function Distributions.rand(rng::AbstractRNG, sampler::CustomSampler)
  while true
    x = rand(rng, Uniform(0, 2*π))
    y = rand(rng, Uniform(0, 1))
    if y <= pdf(x) * 2*π
      return x
    end
  end
end

# Usage example
# sampler = CustomSampler()
# rand(sampler, 10)
