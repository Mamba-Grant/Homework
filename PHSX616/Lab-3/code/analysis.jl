using Measurements, Unitful, Latexify, Statistics, Plots, CSV, DataFrames, LaTeXStrings, PyCall
iminuit = pyimport("iminuit")
import Measurements: value
import Measurements: uncertainty
theme(:wong2)

df = CSV.read("../data/data.csv", header=2, DataFrame;)
df_1o = dropmissing(rename(df[:, 1:3], ["Path Difference", "Intensity", "Trial"]))
df_5o = dropmissing(rename(df[:, 4:6], ["Path Difference", "Intensity", "Trial"]))

s1 = scatter(df_1o."Path Difference", df_1o."Intensity", group=df_1o.Trial, label=reshape(["1st Order (Trial $t)" for t in unique(df_1o.Trial)], :, 2), title="1st Order Data")
s2 = scatter(df_5o."Path Difference", df_5o."Intensity", group=df_5o.Trial, label=reshape(["5th Order (Trial $t)" for t in unique(df_5o.Trial)], :, 3), title="5th Order Data")

# Fit Some Gaussian Functions

# Some guesstimates at where peaks may lie
peaks_1o = [
    df_1o[(6.2 .< df_1o."Path Difference" .< 6.75), :],
    df_1o[(6.8 .< df_1o."Path Difference" .< 7.80), :]
]
vline!(s1, [6.2, 6.75], ls=:dash, c=3, label="Peak 1 Domain")
vline!(s1, [6.8, 7.8], ls=:dash, c=4, label="Peak 2 Domain")

peaks_5o = [
    df_5o[(33.2 .< df_5o."Path Difference" .< 33.85), :], 
    df_5o[(33.9 .< df_5o."Path Difference" .< 34.50), :], 
    df_5o[(38.0 .< df_5o."Path Difference" .< 40.00), :],
]
vline!(s2, [33.2, 33.85], ls=:dash, c=4, label="Peak 1 Domain")
vline!(s2, [33.9, 34.50], ls=:dash, c=5, label="Peak 2 Domain")
vline!(s2, [38.0, 40.00], ls=:dash, c=6, label="Peak 3 Domain")

x_data_1o = [df."Path Difference" for df in peaks_1o]
y_data_1o = [df."Intensity" for df in peaks_1o]
x_data_5o = [df."Path Difference" for df in peaks_5o]
y_data_5o = [df."Intensity" for df in peaks_5o]

function model(x, a, μ, σ, b)
    return @. a * exp(-((x - μ)^2) / (2 * σ^2)) + b
end

function chi2(a, μ, σ, b)
    y_model = model(x_data_1o[1], a, μ, σ, b)
    return sum(((y_data_1o[1] .- y_model) ./ 1).^2)
end

m = iminuit.Minuit(chi2, a=200, μ=6.5, σ=0.18, b=0)
m.errordef = 1.0

m.migrad()  # Find minimum
m.hesse()   # Calculate accurate errors

params = Dict(String(k) => v for (k, v) in zip(m.parameters, m.values))
errors = Dict(String(k) => v for (k, v) in zip(m.parameters, m.errors))

# Function to fit Gaussian model to a dataframe
function fit_peak(df; initial_params=(a=200, μ=6.5, σ=0.18, b=0))
    x_data = df."Path Difference"
    y_data = df."Intensity"

    function model(x, a, μ, σ, b)
        return @. a * exp(-((x - μ)^2) / (2 * σ^2)) + b
    end

    function chi2(a, μ, σ, b)
        y_model = model(x_data, a, μ, σ, b)
        return sum(((y_data .- y_model) ./ 1).^2)
    end

    m = iminuit.Minuit(chi2, a=initial_params.a, μ=initial_params.μ, σ=initial_params.σ, b=initial_params.b)
    m.errordef = 1.0
    m.migrad()  # Find minimum
    m.hesse()   # Calculate accurate errors

    # params = Dict(String(k) => v for (k, v) in zip(m.parameters, m.values))
    # errors = Dict(String(k) => v for (k, v) in zip(m.parameters, m.errors))

    values = @. m.values ± m.errors
    params = Dict(String(k) => v for (k, v) in zip(m.parameters, values))
    return (params=params, model=model, fval=m.fval, minuit=m)
end

# Fit all peaks
results_1o = [fit_peak(df) for df in peaks_1o]
results_5o = [fit_peak(df, initial_params=(a=5, μ=34, σ=0.05, b=0)) for df in peaks_5o[1:2]]
b = fit_peak(peaks_5o[3], initial_params=(a=10, μ=38, σ=0.1, b=0))
push!(results_5o, b)

d = 564
λ(β, n) = 2 * d * sind( β / 2 ) / n

β_ticks = range(minimum(df_1o."Path Difference"), maximum(df_1o."Path Difference"), length=7)
λ_ticks = λ.(β_ticks, 1)

# easiest way to plot this stuff
model(x, params) = @. params["a"] * exp(-((x - params["μ"])^2) / (2 * params["σ"]^2)) + params["b"]
plot!(s1, 6.2:1e-2:6.75, value.(model(6.2:1e-2:6.75, results_1o[1].params)),
    c=3, lw=3, label="K-beta", xticks=(β_ticks, round.(λ_ticks, digits=2)))  # Update X-axis ticks
plot!(s1, 6.2:1e-2:6.75, value.(model(6.2:1e-2:6.75, results_1o[1].params)), 
      c=3, lw=3, label="K-beta", xticks=(β_ticks, round.(λ_ticks, digits=2)))
plot!(s1, 6.8:1e-2:7.8,  value.(model(6.8:1e-2:7.8, results_1o[2].params)), 
      c=4, lw=3, label="K-alpha", xticks=(β_ticks, round.(λ_ticks, digits=2)))

β_ticks = range(minimum(df_5o."Path Difference"), maximum(df_5o."Path Difference"), length=7)  # Example β values in degrees
λ_ticks = λ.(β_ticks, 5)  # Convert to wavelength

plot!(s2, 33.2:1e-2:33.85, value.(model(33.2:1e-2:33.85, results_5o[1].params)), #ribbon=uncertainty.(model(38.0:1e-2:40.00, results_5o[1].params)), 
      c=4, lw=3, label="K-gamma", xticks=(β_ticks, round.(λ_ticks, digits=2))) 
plot!(s2, 33.9:1e-2:34.50, value.(model(33.9:1e-2:34.50, results_5o[2].params)), #ribbon=uncertainty.(model(38.0:1e-2:40.00, results_5o[2].params)), 
      c=5, lw=3, label="K-beta", xticks=(β_ticks, round.(λ_ticks, digits=2))) 
plot!(s2, 38.0:1e-2:40.00, value.(model(38.0:1e-2:40.00, results_5o[3].params)), #ribbon=uncertainty.(model(38.0:1e-2:40.00, results_5o[3].params)),
      c=6, lw=3, label="K-alpha1", xticks=(β_ticks, round.(λ_ticks, digits=2))) 


p = plot(s1, s2, legend=:outerleft, layout=(2,1))
xlabel!("nλ/pm")
ylabel!("R₀ / 1/s")

# keep these separate so that I can append order
x1 = [result.params for result in results_1o] # combine all data into a vector of dictionaries
x2 = [result.params for result in results_5o]
df1 = DataFrame([Dict(Symbol(String(k)) => v for (k, v) in d) for d in x1]) # get those dictionaries into a dataframe of results
df2 = DataFrame([Dict(Symbol(String(k)) => v for (k, v) in d) for d in x2])

df1.order .= 1
df2.order .= 5

df = reduce(append!, (df1, df2))
df.μ = λ.(df.μ, df.order)
df

x3 = [result.fval for result in reduce(append!, (results_1o, results_5o))]
