include("frequency_dependence.jl")

theme(:wong)

function filter_column_outliers(df, column_name, threshold=10)
    data = df[!, column_name]
    weights = 1.0 ./ (uncertainty.(data) .^ 2)
    wmean = sum(weights .* value.(data)) / sum(weights)
    wstd = sqrt(1 / sum(weights))
    zscores = abs.((value.(data) .- wmean) ./ wstd)
    return df[zscores .<= threshold, :]
end

df.δF_normalised_V = df.Voltage ./ df.δF
df_resistance.δF_normalised_V = df_resistance.VJ2 ./ df_resistance.δF
df.all_normalised_V = df.Voltage ./ df.δF ./ df.Ri
df_resistance.all_normalised_V = df_resistance.VJ2 ./ df_resistance.δF ./ df_resistance.Rin


df_e1 = DataFrame(CSV.File("../data/dependence_on_frequency (CEXT).csv"))
df_e1 = df_e1[!, Not("Column8", "Rin (Ohm)", "Gain (HLE)")]
df_e1 = stack(df_e1, Not(:F1))
rename!(df_e1, :variable => :F2, :value => :Voltage)
df_e1.F1 = replace.(df_e1.F1, r"\s*\(Hz\)" => "")
df_e1.F2 = replace.(df_e1.F2, r"\s*\(kHz\)" => "")
df_e1.Ri .= (2.996e3 ± 2.996e3 * 0.09)u"Ω"
df_e1.δF = @. DDD.value * u"Hz" ± DDD.value * .05u"Hz"
df_e1.δF_normalised_V = df_e1.Voltage ./ df_e1.δF
df_e1.all_normalised_V = df_e1.Voltage ./ df_e1.δF ./ df_e1.Ri

df_e2 = DataFrame(CSV.File("../data/dependence_on_frequency (10k ohm).csv"))
df_e2 = df_e2[!, Not("Column8", "Rin (Ohm)", "Gain (HLE)")]
df_e2 = stack(df_e2, Not(:F1))
rename!(df_e2, :variable => :F2, :value => :Voltage)
df_e2.F1 = replace.(df_e2.F1, r"\s*\(Hz\)" => "")
df_e2.F2 = replace.(df_e2.F2, r"\s*\(kHz\)" => "")
df_e2.Ri .= (10_000 ± 10_000 * 0.001)u"Ω"
df_e2.δF = @. DDD.value * u"Hz" ± DDD.value * .05u"Hz"
df_e2.δF_normalised_V = df_e2.Voltage ./ df_e2.δF
df_e2.all_normalised_V = df_e2.Voltage ./ df_e2.δF ./ df_e1.Ri

f_df = filter_column_outliers(df, :all_normalised_V)
f_df_resistance = filter_column_outliers(df_resistance, :all_normalised_V, 1e5)
f_df_e1 = filter_column_outliers(df_e1, :all_normalised_V)
f_df_e2 = filter_column_outliers(df_e2, :all_normalised_V)

x = vcat( 
    ustrip.(f_df_resistance.Rin), 
    ustrip.(f_df.Ri),
         # ustrip.(f_df_e1.Ri), 
         # ustrip.(f_df_e2.Ri), 
         )

y = vcat( 
    ustrip.(f_df_resistance.δF_normalised_V), 
    ustrip.(f_df.δF_normalised_V),
         # ustrip.(f_df_e1.δF_normalised_V), 
         # ustrip.(f_df_e2.δF_normalised_V), 
         )

fit = curve_fit(LinearFit, x, y)

p = scatter(f_df.Ri, f_df.δF_normalised_V, label="Frequency Correlation Dataset", 
            titlefont = font(12,"Computer Modern"),
            legendfont = font(8,"Computer Modern"),
)
scatter!(f_df_resistance.Rin, f_df_resistance.δF_normalised_V, label="Resistance Correlation Dataset")
title!("Noise Density & Boltzmann's Constant")
xlabel!(L"\textrm{Resistance}~(\Omega)")
ylabel!(L"\textrm{Noise~Density}~\mathrm{(V^2 / Hz)}")

scatter!(p, f_df.Ri, f_df.δF_normalised_V, label="Frequency Correlation Dataset", xlims=[-100,3200], ylims=[0, 5e-17], legend=false, xlabel="", ylabel="", inset=bbox(0.05,0.5,0.3,0.3,:right), subplot=2)
scatter!(p, f_df_resistance.Rin, f_df_resistance.δF_normalised_V, label="Resistance Correlation Dataset", subplot=2)

vline!(p, [0, 3200], color=:gray, linestyle=:dash, linewidth=1, subplot=1, alpha=0.5, label="")
hline!(p, [0, 5e-17], color=:gray, linestyle=:dash, linewidth=1, subplot=1, alpha=0.5, label="")

grad = 1.56e-20 ± 1.6e-21 # b param from "fit"
kB = grad / (4 * temperature)

x_fit = range(minimum(x), maximum(x), length=100)
y_fit = fit.(x_fit)
plot!(value.(x_fit), value.(y_fit), ribbon=Measurements.uncertainty.(y_fit), label=L"y = (4 k_B T) R")
plot!(value.(x_fit), value.(y_fit), ribbon=Measurements.uncertainty.(y_fit), label=L"y = (4 k_B T) R", subplot=2)

p


# Chi-square calculation that properly handles units
# First, get the data with its original units preserved
measured_x_with_units = vcat(f_df_resistance.Rin, f_df.Ri)
measured_y_with_units = vcat(f_df_resistance.δF_normalised_V, f_df.δF_normalised_V)

# Create a theoretical model with proper units
# Boltzmann's constant in proper units
kB_val = ustrip(value(kB)) # Add appropriate units

# Calculate theoretical values based on the model (with units)
theoretical_values = @. 4 * kB_val * temperature * measured_x_with_units

# Extract values and uncertainties while preserving units
measured_vals = ustrip.(value.(measured_y_with_units))
measured_errs = ustrip.(uncertainty.(measured_y_with_units))
theoretical_vals = ustrip.(value.(theoretical_values))
# theoretical_errs = @. ustrip(theoretical_vals * (uncertainty(kB) / value(kB)))

# Now compute z-scores properly with compatible units
z_scores = @. (measured_vals - theoretical_vals) / sqrt(measured_errs^2)

# Calculate chi-squared from dimensionless z-scores
chi_squared = sum(ustrip.(z_scores).^2)
ndf = length(measured_y_with_units) - 1  # Degrees of freedom (n-1 for linear fit with 1 parameter)
chi_squared_reduced = chi_squared / ndf  # Reduced chi-square

# Print results
println("Boltzmann's constant: ", kB, " J/K")
println("Literature value: 1.380649e-23 J/K")
println("Chi-squared: ", chi_squared)
println("Reduced chi-squared: ", chi_squared_reduced)
println("Number of data points: ", length(measured_y_with_units))
println("Degrees of freedom: ", ndf)
