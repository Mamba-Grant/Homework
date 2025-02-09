using DataFrames
using CSV
using Statistics
using Measurements

function remove_outliers(df, cols)
    if length(df[!, "neutral_fall_seconds"]) == 1
        return df
    end

    filtered_df = df  # Create a copy of df
    for col in cols
        μ = mean(filtered_df[!, col])  # Compute mean
        σ = std(filtered_df[!, col])   # Compute standard deviation
        filtered_df = filter(row -> abs(row[col] - μ) ≤ 2*σ, filtered_df)  # Keep rows within 1 std dev
    end
    return filtered_df
end

# Load data from CSV files into a vector of DataFrames, removing outliers
data::Vector{DataFrame} = DataFrame.(CSV.File.(readdir("raw_data/", join=true)))
data = [remove_outliers(df, [:neutral_fall_seconds, :charged_rise_seconds]) for df in data]

# Compute charges with uncertainty
charges = map(data) do df
    d_lines = 0.5e-3 ± 0.1e-4
    vf = d_lines / mean(df.neutral_fall_seconds)
    vr = d_lines / mean(df.charged_rise_seconds)

    voltage_error = round(mean(df.voltage_V) .* 0.0009 .+ 0.2, sigdigits=1)
    V = mean(df.voltage_V) ± voltage_error
    d = mean(df.d)
    E = V / d

    η = mean(df.eta)
    ρ = mean(df.rho)
    b = mean(df.b)
    p = mean(df.p) ± 1000
    
    a = @. sqrt((df.b / (2p))^2 + (9 * η * vf) / (2 * df.g * ρ)) - b / (2p)
    m = (4/3) * π * mean(a)^3 * ρ
    q = m * mean(df.g) * (vf + vr) / (E * vf)

    return q
end

real_charge::Float64 = 1.602e-19
number_of_measurements = length.(getproperty.(data, :neutral_fall_seconds))

# Extract values and uncertainties
charge_values = Measurements.value.(charges)  # Extract central values (nominal charge)
normalized_charge = charges ./ minimum(charge_values)
systematic_uncertainties = Measurements.uncertainty.(charges)  # Extract propagated systematic uncertainties
# statistical_uncertainties = (charge_values ./ Measurements.value.(normalized_charge)) ./ sqrt.(number_of_measurements)  # Statistical part
statistical_uncertainties = 1e-19 ./ sqrt.(number_of_measurements)  # Statistical part
z_scores = (charge_values ./ normalized_charge .- real_charge) ./ sqrt.(statistical_uncertainties.^2 + systematic_uncertainties.^2)
chi_squared = sum(z_scores .^ 2)

# Generate droplet labels: "A", "B", "C", ..., "Z", "AA", "AB", etc.
droplet_labels = [
    string(Char(65 + (i - 1) % 26)) * (i > 26 ? string(Char(65 + (i - 1) ÷ 26)) : "")
    for i in 1:length(charges)
]

# Display results including systematic and statistical uncertainties separately
df_results::DataFrame = DataFrame(zip(
    droplet_labels,
    round.(charge_values, sigdigits=4),  # Charge in Coulombs
    round.(normalized_charge, sigdigits=4),  # Number of charges per droplet
    round.(statistical_uncertainties, sigdigits=4),  # Statistical Uncertainty
    round.(systematic_uncertainties, sigdigits=4),  # Systematic Uncertainty
    round.(z_scores, sigdigits=4)  # Z-Score
))

colnames = [
    "",
    "Charge (C)",
    "# Charges",
    "Statistical Uncertainty",
    "Systematic Uncertainty",
    "Z-Score"
]

rename!(df_results, Symbol.(colnames))
println(df_results)
println("\nΧ² = $chi_squared")

using Plots

# Define the elementary charge (assumed to be the minimum of charge_values)
e = minimum(charge_values)
scale = e * 1e19  # Converts to the "1e19‐scaled" units

# Set the maximum y value in the original scaling and convert to electron charge units
y_tick_max = 1.629e-18 * 1e19
y_max_scaled = y_tick_max / scale
yticks_scaled = 0:1:ceil(y_max_scaled)

# Calculate properly scaled uncertainties
function scale_uncertainties(charges, normalized_charges, stat_uncertainties, sys_uncertainties)
    # Convert to elementary charge units directly
    y_errors = sqrt.(stat_uncertainties.^2 .+ sys_uncertainties.^2) ./ e
    
    # For x-errors, we need to properly propagate the uncertainty in the normalization
    x_errors = sqrt.(
        (Measurements.uncertainty.(normalized_charges)).^2 .+ 
        (stat_uncertainties ./ e).^2
    )
    
    return x_errors, y_errors
end

# Calculate scaled uncertainties for both high and low quality data
x_errs_high, y_errs_high = scale_uncertainties(
    charges[1:6], 
    normalized_charge[1:6], 
    statistical_uncertainties[1:6], 
    systematic_uncertainties[1:6]
)

x_errs_low, y_errs_low = scale_uncertainties(
    charges[7:end], 
    normalized_charge[7:end], 
    statistical_uncertainties[7:end], 
    systematic_uncertainties[7:end]
)

# Create the plot
p = scatter(
    Measurements.value.(normalized_charge[1:6]),
    Measurements.value.(charges[1:6]) ./ e,  # Convert directly to elementary charge units
    yerr = y_errs_high,
    xerr = x_errs_high,
    xlabel = "Number of Charges",
    ylabel = "Charge (elementary charge)",
    label = "Measured Charges, High Quality Data",
    title = "Number of Charges vs Charge",
    yticks = (yticks_scaled, yticks_scaled),
    xlims = [0, 8],
    ylims = [0, y_max_scaled],
    legend = :topleft,
    z = 1
)

# Add low quality data
scatter!(
    Measurements.value.(normalized_charge[7:end]),
    Measurements.value.(charges[7:end]) ./ e,
    yerr = y_errs_low,
    xerr = x_errs_low,
    label = "Measured Charges, Low Quality Data",
    alpha = 0.8
)

# Add Millikan's reference data
scatter!(1:7, 1:7, label = "Millikan's Data", alpha = 0.8)

# Optional: Add reference lines for integer charges
vline!(1:7, color = :gray, linestyle = :dash, label = "Integer Charge Multiples", alpha = 0.3)

savefig("output_plot.png")
display(p)
