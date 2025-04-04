using PyCall
using Plots
using Statistics
using Random

iminuit = pyimport("iminuit")

# Model function: linear
function model(x, a, b)
    return @. a * x + b
end

function chi2_function(a, b, c)
    y_model = model(x_data, a, b, c)
    return sum(((y_data .- y_model) ./ y_errors).^2)
end

m = iminuit.Minuit(chi2_function, a=1, b=1, c=0)
m.errordef = 1.0
m.limits["a"] = (0, nothing)  # a > 0
m.limits["b"] = (0, nothing)  # b > 0

m.migrad()  # Find minimum
m.hesse()   # Calculate accurate errors

params = Dict(String(k) => v for (k, v) in zip(m.parameters, m.values))
errors = Dict(String(k) => v for (k, v) in zip(m.parameters, m.errors))
chi2_min = m.fval
ndof = length(x_data) - length(fit_params)
reduced_chi2 = chi2_min / ndof


# Print results
# println("Fit Results:")
# println("a = $(fit_params["a"]) ± $(fit_errors["a"])")
# println("b = $(fit_params["b"]) ± $(fit_errors["b"])")
# println("c = $(fit_params["c"]) ± $(fit_errors["c"])")
# println("Chi² = $(chi2_min)")
# println("degrees of freedom = $(ndof)")
# println("Reduced Chi² = $(reduced_chi2)")
#
# # Plot the results
# p = scatter(x_data, y_data, yerror=y_errors, label="Data", markersize=4)
# x_fit = range(minimum(x_data), maximum(x_data), length=100)
# y_fit = model(x_fit, fit_params["a"], fit_params["b"], fit_params["c"])
# plot!(p, x_fit, y_fit, lw=2, label="Fit: $(round(fit_params["a"], digits=2)) exp(-$(round(fit_params["b"], digits=2))x) + $(round(fit_params["c"], digits=2))")
# plot!(p, x_data, y_true, lw=2, ls=:dash, label="True function")
# xlabel!("x")
# ylabel!("y")
# title!("Chi-square fit with Iminuit")
