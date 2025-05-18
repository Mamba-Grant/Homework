using Measurements, Unitful, CSV, DataFrames, Plots, Statistics, Measures, PyCall, Interpolations
import Measurements: value
import Measurements: uncertainty
iminuit = pyimport("iminuit")

# Read and clean data
function clean_dataframe(filepath)
    df = CSV.read(filepath, DataFrame)
    return filter(:y_rel => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df)
end

# df_low = clean_dataframe("../data/Config_A_Trace_low.csv")
# df_med = clean_dataframe("../data/Config_A_Trace_med.csv")
# df_high = clean_dataframe("../data/Config_A_Trace_high.csv")

df_low = clean_dataframe("../data/Config D/Config_D_Trace_low.csv")
df_med = clean_dataframe("../data/Config D/Config_D_Trace_med.csv")
df_high = clean_dataframe("../data/Config D/Config_D_Trace_high.csv")

# Use low resolution as baseline
baseline = df_low

function model(a, b)
    x_transformed = a .* baseline.x_rel .+ b
    return itp.(x_transformed)
end

function chi2_function(a, b)
    y_model = model(a, b)
    return sum(((baseline.y_rel .- y_model) ./ 3).^2)
end


# Create a function to fit any dataset to the baseline
function fit_to_baseline(df_to_fit, baseline; initial_a=1.0, initial_b=0.0)
    # Create interpolation for the dataset to fit
    itp = linear_interpolation(df_to_fit.x_rel, df_to_fit.y_rel, extrapolation_bc=Flat())
    
    # Define model and chi2 functions
    function model(a, b)
        x_transformed = a .* baseline.x_rel .+ b
        return itp.(x_transformed)
    end
    
    function chi2_function(a, b)
        y_model = model(a, b)
        return sum(((baseline.y_rel .- y_model) ./ 3).^2)
    end
    
    # Minimize chi-square
    m = iminuit.Minuit(chi2_function, a=initial_a, b=initial_b)
    m.migrad()
    m.hesse()
    
    params = Dict(String(k) => v for (k, v) in zip(m.parameters, m.values))
    errors = Dict(String(k) => v for (k, v) in zip(m.parameters, m.errors))
    chi2_min = m.fval

    best_a = params["a"]
    best_b = params["b"]

    # Return all relevant information
    return (
        parameters = (a=best_a, b=best_b),
        errors = errors,
        chi2 = chi2_min,
        model = model,
        fit_results = m
    )
end

# Perform fitting for medium and high resolution data
med_fit = fit_to_baseline(df_med, baseline, initial_a=1.0, initial_b=-50)
high_fit = fit_to_baseline(df_high, baseline, initial_a=1.0, initial_b=0)

# Create plots
p1 = plot(title="Fitting Results")

# Plot baseline (low resolution)
plot!(p1, df_low.x_rel, df_low.y_rel, linewidth=2, label="Low Resolution (Baseline)", linestyle=:dash, alpha=0.5)

# Plot medium resolution data transformed to baseline domain
# Transform the actual data points from df_med
x_med_original = df_med.x_rel
y_med_original = df_med.y_rel
# Apply inverse transformation to get to baseline domain
x_med_transformed = (x_med_original .- med_fit.parameters.b) ./ med_fit.parameters.a
plot!(p1, x_med_transformed, y_med_original, 
      label="Fitted Middle Peak (a=$(round(med_fit.parameters.a, digits=3)), b=$(round(med_fit.parameters.b, digits=1)))",
      linewidth=2, alpha=0.5)

# Plot high resolution data transformed to baseline domain
# Transform the actual data points from df_high
x_high_original = df_high.x_rel
y_high_original = df_high.y_rel
# Apply inverse transformation to get to baseline domain
x_high_transformed = (x_high_original .- high_fit.parameters.b) ./ high_fit.parameters.a
plot!(p1, x_high_transformed, y_high_original, 
      label="Fitted Left Peak (a=$(round(high_fit.parameters.a, digits=3)), b=$(round(high_fit.parameters.b, digits=1)))",
      linewidth=2, alpha=0.5)

# Optional: Set axis labels and display the plot
xlabel!(p1, "Relative Position")
ylabel!(p1, "Relative Value")
display(p1)

# Output:
df_med_transformed = DataFrame(x_rel=x_med_transformed, y_rel=y_med_original)
df_high_transformed = DataFrame(x_rel=x_high_transformed, y_rel=y_high_original)
CSV.write("../data/Config_A_Trace_med_transformed.csv", df_med_transformed)
CSV.write("../data/Config_A_Trace_high_transformed.csv", df_high_transformed)

