using DataFrames, CSV, Plots, Measurements, CurveFit, LaTeXStrings, Unitful
using Unitful: Latexify
using UnitfulLatexify, Latexify
import Measurements: value
import Measurements: uncertainty
theme(:wong)

df_resistance = DataFrame(CSV.File("../data/amplifier_noise_data.csv"))
df_resistance = df_resistance[!, Not("Column5", "TimeConstant")]

boltzmann = 1.38e-23u"J/K"
temperature = (294±5) * u"K"
bandwidth = (10996 ± 10996 * 0.0002) * u"Hz" 

resistance_mappings = Dict(
    "AEXT" => 2u"Ω",
    "BEXT" => 279.9u"Ω",
    "CEXT" => 2.996e3u"Ω"
)

input_resistances = [ get(resistance_mappings, key, key) for key in df_resistance.Rin ]
input_resistances = [x isa AbstractString ? parse(Float64, get(resistance_mappings, x, x)) * u"Ω" : get(resistance_mappings, x, x) for x in input_resistances]
input_resistances = [x ± (x * 0.003) for x in input_resistances] # add errors
df_resistance.Rin = input_resistances
df_resistance[!, "V2 (V)"] = @. df_resistance[!, "V2 (V)"] ± df_resistance[!, "V2 (V)"] * 0.0009
df_resistance[!, "V2 (V)"] = df_resistance[!, "V2 (V)"]u"V^2"
df_resistance.SecondaryGain = @. df_resistance.SecondaryGain ± (df_resistance.SecondaryGain * 0.0002)
# df_resistance = df_resistance[df_resistance.Rin .<= 5e4 * u"Ω", :]
df_resistance.δF .= (10996 ± (10996 * 0.05)) * u"Hz"
df_resistance = df_resistance[value.(df_resistance.SecondaryGain) .== 1500, :]

# df_resistance = df_resistance[value.(df_resistance.Rin) .<= 5e3u"Ω", :]

gain_factor = @. (1+((1e3 ± 9)u"Ω"/(200 ± 2)u"Ω")) * (100 ± 0.0001) * (df_resistance.SecondaryGain)
gain_adjusted_voltage = @. 10 * df_resistance[!, "V2 (V)"] / gain_factor^2

resistance_values = ustrip.(value.(df_resistance.Rin)) # Remove units for fitting
measured_voltage = ustrip.(value.(gain_adjusted_voltage))

linear_fit = curve_fit(LinearFit, resistance_values, (measured_voltage))
johnson_noise_theoretical(δf, R) = 4 * boltzmann * temperature * δf * R

df_resistance.VJ2 = gain_adjusted_voltage .- linear_fit(0) * u"V^2"

T=(50 ± 5) * u"s"
τ=0.1u"s"
Neff = T/(π*τ)
stat_σ = 1/sqrt(Neff)
stat_σ_relative = stat_σ .* value.(df_resistance.VJ2)
df_resistance.VJ2 = measurement.(value.(df_resistance.VJ2), sqrt.(Measurements.uncertainty.(df_resistance.VJ2).^2 + value.(stat_σ_relative.^2)))
gain_adjusted_voltage = measurement.(value.(gain_adjusted_voltage), sqrt.(Measurements.uncertainty.(gain_adjusted_voltage).^2 + value.(stat_σ_relative.^2)))

np = scatter(title="Resistance-Dependent Johnson Noise", 1e-3.*ustrip.(df_resistance.Rin), ustrip.(uconvert.(u"μV^2", gain_adjusted_voltage)), 
             size=(400, 250), ms = 3, label=L"\langle V_J^2 + V_N^2 \rangle", 
             titlefont = font(12,"Computer Modern"),
             legendfont = font(8,"Computer Modern"),
             xlabel=L"k\Omega", ylabel=L"\mu V^2",)
             # title="(a)", titlelocation=:left)  # Moves title to top-left

resistance_range = 0:10e3:100e3
plot!(1e-3 .* ustrip.(resistance_range), ustrip.(uconvert.(u"μV^2", (linear_fit.(ustrip.(resistance_range)) .* u"V^2"))), 
      ribbon=Measurements.uncertainty.(linear_fit.(ustrip.(resistance_range))),
      label="Linear Fit")

sp = scatter!(1e-3 .* ustrip.(df_resistance.Rin), ustrip.(uconvert.(u"μV^2", df_resistance.VJ2)); 
             ms = 3, label=L"\langle V_J^2 \rangle",
              xlabel=L"k\Omega", ylabel=L"\mu V^2",)
             # title="(b)", titlelocation=:left)  # Moves title to top-left

plot!(1e-3 .* ustrip.(resistance_range), ustrip.(1e12 .* value.(johnson_noise_theoretical.(bandwidth, resistance_range)));
      ribbon=ustrip.(1e12 .* Measurements.uncertainty.(johnson_noise_theoretical.(bandwidth, resistance_range))),
      label="Theoretical Johnson Noise")

sp = scatter(1e-3 .* ustrip.(df_resistance.Rin), 1e12 .* ustrip.(df_resistance.VJ2), 
             ms = 3, label=L"\langle V_J^2 \rangle",
             xlabel=L"k\Omega", ylabel=L"\mu V^2",
             title="(b)", titlelocation=:left)  # Moves title to top-left


# plot!(1e-3 .* ustrip.(resistance_range), ustrip.(1e12 .* value.(johnson_noise_theoretical.(bandwidth, resistance_range)));
#       ribbon=ustrip.(1e12 .* Measurements.uncertainty.(johnson_noise_theoretical.(bandwidth, resistance_range))),
#       label="Theoretical Johnson Noise")

measured_vj2 = value.(df_resistance.VJ2)
theoretical_vj2 = value.(johnson_noise_theoretical.(bandwidth, df_resistance.Rin))
uncertainties_measured = (Measurements.uncertainty.(df_resistance.VJ2))
uncertainties_theory = Measurements.uncertainty.(johnson_noise_theoretical(bandwidth, df_resistance.Rin))

z = (((measured_vj2 .- theoretical_vj2)) ./ sqrt.(uncertainties_measured.^2 .+ uncertainties_theory.^2))
chi_squared = sum(z.^2)
ndf = length(measured_vj2) - 1  # Degrees of freedom
chi_squared_reduced = chi_squared / ndf  # Reduced chi-square

# # Process data by gain values
# gain_1500_subset = df_resistance[value.(df_resistance.SecondaryGain) .== 1500, :]
# gain_6000_subset = df_resistance[value.(df_resistance.SecondaryGain) .== 6000, :]
#
# # Prepare data for polynomial fits
# resistance_1500 = ustrip.(value.(gain_1500_subset.Rin))
# voltage_1500 = gain_1500_subset[!, "V2 (V)"] * u"V"
# fit_1500 = curve_fit(LinearFit, resistance_1500, ustrip.(value.(voltage_1500)))
#
# resistance_6000 = ustrip.(value.(gain_6000_subset.Rin))
# voltage_6000 = gain_6000_subset[!, "V2 (V)"] * u"V"
# fit_6000 = curve_fit(LinearFit, resistance_6000, ustrip.(value.(voltage_6000)))
#
# # Create raw data plot
# raw_data_plot = scatter(gain_1500_subset.Rin, gain_1500_subset[!, "V2 (V)"], 
#                         label=L"\langle \textrm{V_{sq}} \rangle\, (1600 \textrm{~HLE})", 
#                         xlabel=L"\textrm{R_{in}}\, (\Omega)", 
#                         ylabel=L"(V)", 
#                         title="Data")
# scatter!(gain_6000_subset.Rin, gain_6000_subset[!, "V2 (V)"], 
#          label=L"\langle \textrm{V_{sq}} \rangle\, (6000 \textrm{~HLE})", 
#          xlabel=L"\textrm{R_{in}}\, (\Omega)", 
#          ylabel=L"\textrm{V^2}")
#
# Combine plots
combined_plots = plot(np, sp, layout=(2, 1), link=:both)

# Print results
println("Extrapolated AMP Noise: $(linear_fit(0) * u"V")")
