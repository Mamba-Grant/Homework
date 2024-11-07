using IMinuit, Plots, CSV, DataFrames, LaTeXStrings, PlotThemes

theme(:dao)

h = 6.626e-34
kb = 1.381e-23
c = 3e8

# TODO: apply untis to x-axis and then fit again

yaxis(p) = @. ((502.5-577) / (289-40 - 363-40)) * (p-363-40) + 577
dist1(x, T) = @. (8*π*h*c)/(x^5) * (exp( (h*c)/(x*kb*T) ) - 1)^(-1)
dist(x, T, b) = @. (8*π*h*c)/(x^5) * (exp( (h*c)/(x*kb*T) ) - 1)^(-1) + 0*b
dist(x, p) = dist(x, p...)

df = DataFrame(CSV.File("dump-2700k.csv", header=false))

y = Array(df[1, 100:300]) ./ 1.3e-2
x = Array(df[2, 100:300]) .* 10^(-9) 
yerr_data = 0 .* x .+ 1e-5

data = Data(x, y, yerr_data)

m_planck = @model_fit dist data [50000, 0]
migrad(m_planck)
hesse(m_planck)
p = @plt_best(dist, m_planck, data)

m_planck_values, m_planck_errors = convert.(Vector{Float64}, (m_planck.values, m_planck.errors))

print(m_planck_values)
x2 = 0:1e-9:3e-6
y2 = dist1.(x2, 2700)

x3 = 0:1e-9:3e-6
y3 = dist1.(x2, m_planck_values[1])

yDropped = Array(df[1, Not(100:300)]) ./ 1.3e-2 
xDropped = Array(df[2, Not(100:300)]) .* 10^-9

plot!(x2,y2, title="Spectral Density, Lightbulb", label="Planck's Law (2700k)", linestyle=:dash)
plot!(p)
plot!(xDropped, yDropped, seriestype=:scatter, label="Dropped (Bad) Values", ms=3, marker=:xcross, markeralpha=1)
plot!(x3,y3, label="Planck's Law ($(round(m_planck_values[1], sigdigits=3))k)", linestyle=:dash)

xlabel!("Wavelength")
ylabel!("Relative Intensity")

savefig("2700kSpectralDensity.png")

