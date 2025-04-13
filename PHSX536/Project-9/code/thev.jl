# Thevenin equivalent is given as:
#     V(I) = - Rth I + Vth 
# When working with the load.

using Measurements, Unitful, CSV, DataFrames, Plots, Statistics, Measures, PyCall
import Measurements: value
import Measurements: uncertainty
iminuit = pyimport("iminuit")
theme(:bright)

df1 = CSV.read("../data/RLoad - SWEEP.csv", DataFrame;)
transform!(df1, 
            "Pk-pk" => ByRow(x -> (x ± x * 0.03) * u"V") => "Pk-pk",
) # assign units and errors to data all at once


# df = vcat(nd_dfs...)
# df1 = vcat(nd_stats[(nd_stats.Resistance .< 4590u"Ω"), :])
df1.Ω = idx2resistance.(df1.idx)
thev = scatter(uconvert.(u"A", df1."Pk-pk" ./ df1.Ω), df1."Pk-pk", ms=2, label="IV at Various Load Values")

x_data = ustrip.(value.(uconvert.(u"A", df1."Pk-pk" ./ df1.Ω)))
y_data = ustrip.(value.(df1."Pk-pk"))
y_errors = ustrip.(uncertainty.(df1."Pk-pk"))

scipy_optimize = pyimport("scipy.optimize")
function model(x, a, b)
    return @. a * x + b
end

function chi2_function(a, b)
    y_model = model(x_data, a, b)
    return sum(((y_data .- y_model) ./ y_errors).^2)
end

m = iminuit.Minuit(chi2_function, a=1, b=1)
m.errordef = 1.0

m.migrad()  # Find minimum
m.hesse()   # Calculate accurate errors

params = Dict(String(k) => v for (k, v) in zip(m.parameters, m.values))
errors = Dict(String(k) => v for (k, v) in zip(m.parameters, m.errors))
chi2_min = m.fval

x_fit = range(minimum(x_data), maximum(x_data), length=100)
y_fit = model(x_fit, params["a"], params["b"])
plot!(thev, x_fit, y_fit, lw=2, label="Fit: $(round(params["a"], digits=2)) x + $(round(params["b"], digits=2))")

