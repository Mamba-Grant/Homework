using NoiseRobustDifferentiation, CSV, DataFrames, Plots, Unitful, Statistics, Interpolations, Measures, Measurements, LaTeXStrings
using Measurements: value, uncertainty

theme(:mute)

# Read data
df_example = CSV.read("../data/Config D/Config_D_final.csv", DataFrame)

df_h = df_example[df_example.res .!= "low", :]
df_l_all = df_example[df_example.res .== "low", :]

# Filter out overlaps
h_min = minimum(df_h.x_abs)
h_max = maximum(df_h.x_abs)
df_l = df_l_all[.!(h_min .<= df_l_all.x_abs .<= h_max), :]
df_example = vcat(df_l, df_h)

# Extract and sort data
x_rel = df_example.x_rel
x_abs_values = df_example.x_abs
y_rel_values = df_example.y_rel

sort_indices = sortperm(x_rel)
x_rel_sorted = x_rel[sort_indices]
x_abs_values_sorted = x_abs_values[sort_indices]
y_rel_values_sorted = y_rel_values[sort_indices]

# Remove duplicates
unique_indices = findall(i -> i == 1 || x_rel_sorted[i] > x_rel_sorted[i-1], 1:length(x_rel_sorted))
x_rel_unique = x_rel_sorted[unique_indices]
x_abs_values_unique = x_abs_values_sorted[unique_indices]
y_rel_values_unique = y_rel_values_sorted[unique_indices]

# Interpolation
x_abs_itp = linear_interpolation(x_rel_unique, x_abs_values_unique)
y_rel_itp = linear_interpolation(x_rel_unique, y_rel_values_unique)

# Generate equidistant points
x_rel_min = minimum(x_rel_unique)
x_rel_max = maximum(x_rel_unique)
num_points = 1500
x_rel_equidistant = range(x_rel_min, x_rel_max, length=num_points)

# Interpolate to equidistant points
x_abs_interp = x_abs_itp.(x_rel_equidistant)
y_rel_interp = y_rel_itp.(x_rel_equidistant)

# Create DataFrame
df_interpolated = DataFrame(
    x_rel = collect(x_rel_equidistant),
    y_rel = y_rel_interp,
    x_abs = x_abs_interp
)

# Assign units
transform!(df_interpolated, 
           :x_abs => ByRow(x -> (x ± x * 0.03) .* u"Hz") => :x_abs,
           :y_rel => ByRow(x -> (x ± x * 0.03)) => :y_rel,
           )

# Differentiate
û = tvdiff(value.(df_interpolated.y_rel), 500, 0.2, scale="small", ε=1e-6)

# Plot data and derivative
p = plot(value.(df_interpolated.x_abs), value.(df_interpolated.y_rel), ribbon=uncertainty.(df_interpolated.y_rel),
         seriestype=:line, label="Oscilloscope Data", xlims=[1500, 7500], ylabel="a.u.", yticks=false, left_margin = [10mm 0mm])
plot!(p, value.(range(minimum(df_interpolated.x_abs), maximum(df_interpolated.x_abs), length=length(û))), value.(û ./ 150 .+ minimum(df_interpolated.y_rel) .- 50), label="Derivative", xlims=[1500, 7500], alpha=0.5)

# Define peaks
peaks_first = [2135.0, 2222.0, 2320.0, 2429.0, 2523.0, 2653.0, 2735.0] .* u"Hz"
peaks_second = sort([4337, 4431, 4484, 4577, 4643, 4758, 4781, 4828] .* u"Hz")
peaks_third = sort([6784, 6715, 6968, 7027] .* u"Hz")

peaks_first = map(x -> x ± x * 0.002, peaks_first)
peaks_second = map(x -> x ± x * 0.002, peaks_second)
peaks_third = map(x -> x ± x * 0.002, peaks_third)

peaks = vcat(peaks_first, peaks_second, peaks_third)

# Add peak lines
vline!(p, peaks, label="Peaks", alpha=0.8, ls=:dash)

using LaTeXStrings

# Convert frequency to quasi-momentum using the relation k = ω / v
# Assuming a linear dispersion: k = ω / v with v = slope from the first band
# For demonstration, let's compute an effective v from first two peaks
v_eff = (peaks_first[2] - peaks_first[1]) / (π_over_a)  # crude estimate

# Convert frequency to momentum
function freq_to_k(peaks, v_eff)
    return map(p -> p / v_eff, peaks)
end

k_first = freq_to_k(peaks_first, v_eff)
k_second = freq_to_k(peaks_second, v_eff)
k_third = freq_to_k(peaks_third, v_eff)

# Extended zone scheme plot
p1 = plot(label="", xlabel=L"k", ylabel=L"\omega~(\mathrm{Hz})", title="Extended Zone Scheme", legend=false)
scatter!(p1, ustrip.(k_first), ustrip.(peaks_first), label="1st Band")
scatter!(p1, ustrip.(k_second), ustrip.(peaks_second), label="2nd Band")
scatter!(p1, ustrip.(k_third), ustrip.(peaks_third), label="3rd Band")
# vline!(p1, [-π_over_a, 0, π_over_a], linestyle=:dash, label="", alpha=0.4)

a=75

# Folded zone scheme (back into first Brillouin zone)
function fold_k(k_vals, a)
    return mod.(ustrip.(k_vals), 2π/a) .- π/a
end

k_folded_1 = fold_k(k_first, a)
k_folded_2 = fold_k(k_second, a)
k_folded_3 = fold_k(k_third, a)

# Plot folded zone scheme
p2 = plot(label="", xlabel=L"k~\mathrm{(folded)}", ylabel=L"\omega~(\mathrm{Hz})", title="Folded Zone Scheme", legend=false)
scatter!(p2, ustrip.(k_folded_1), ustrip.(peaks_first), label="1st Band")
scatter!(p2, ustrip.(k_folded_2), ustrip.(peaks_second), label="2nd Band")
scatter!(p2, ustrip.(k_folded_3), ustrip.(peaks_third), label="3rd Band")
vline!(p2, [-π_over_a, 0, π_over_a], linestyle=:dash, label="", alpha=0.4)

# Display side by side
plot(p1, p2, layout=(1,2), size=(1000,400))
