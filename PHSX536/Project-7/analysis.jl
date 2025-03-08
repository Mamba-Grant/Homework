using Measurements, Unitful, CSV, DataFrames, Plots, Statistics
import Measurements: value
import Measurements: uncertainty
theme(:wong2)
default(dpi=800)
# idx2resistance(x) = 1e3 * (0.0051 ± 0.0001 * x + 0.0022 ± 0.0001) # returns in ohms
idx2resistance(x) = 1e3 * (0.0051 * x + 0.0022) # returns in ohms

nd_dfs::Vector{DataFrame} = CSV.read.(readdir("measurements_no_diode/", join=true), DataFrame;)
# d_dfs::Vector{DataFrame} = CSV.read.(readdir("measurements_with_diode/", join=true), DataFrame;)

nd_dfs .= [rename(df[:, [4, 5, 10, 11]], [:t_CH1, :V_CH1, :t_CH2, :V_CH2]) for df in nd_dfs] # grab only the columns needed
# d_dfs .= [rename(df[:, [4, 5, 10, 11]], [:t_CH1, :V_CH1, :t_CH2, :V_CH2]) for df in d_dfs] # grab only the columns needed

# filter(:x => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), nd_dfs)
# filter(:x => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), d_dfs)

transform!.(nd_dfs, 
            :t_CH1 => ByRow(x -> (x) * u"s") => :t_CH1,
            :V_CH1 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH1,
            :t_CH2 => ByRow(x -> (x) * u"s") => :t_CH2,
            :V_CH2 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH2,
) # assign units and errors to data all at once

# transform!.(d_dfs, 
#             :t_CH1 => ByRow(x -> (x) * u"s") => :t_CH1,
#             :V_CH1 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH1,
#             :t_CH2 => ByRow(x -> (x) * u"s") => :t_CH2,
#             :V_CH2 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH2,
# ) # assign units and errors to data all at once

nd_stats = map(nd_dfs) do df 
    VPP = maximum(df.V_CH2) - minimum(df.V_CH2)
    m = mean(df.V_CH2)
    ripple = VPP/m
    DataFrame(PP=VPP, Mean=m, Ripple=ripple)
end


p = plot(xlabel="Time (ms)", ylabel="Voltage (V)", legend=:false)

for (i, df) in enumerate(nd_dfs)
    plot!(p, uconvert.(u"ms", df.t_CH1), value.(df.V_CH1), 
          ribbon=ustrip.(uncertainty.(df.t_CH1)), c=:orange, 
          label="CH1 (df$i)", lw=2, alpha=0.7)
          
    plot!(p, uconvert.(u"ms", df.t_CH2), value.(df.V_CH2), 
          ribbon=ustrip.(uncertainty.(df.t_CH2)), c=:black, 
          label="CH2 (df$i)", lw=2, alpha=0.7)
end
# hline!(p, [only(a.Mean) for a in nd_stats], c=:red, ls=:dash, label="Mean")
# hline!([only(a.PP) for a in nd_stats], label="Mean", color=:red)

xrange = idx2resistance.(reverse([10,20,40,60,80,100,200,300,400,500,600,700,800,900,1000])) .* u"Ω"
p2 = plot(
    scatter(xrange, [only(a.Ripple) for a in nd_stats], label="Ripple"),
    scatter(xrange, [only(a.PP) for a in nd_stats], label="VPP"),
    scatter(xrange, [only(a.Mean) for a in nd_stats], label="Mean"),
)

# d_plots = map(d_dfs) do df
#     # Ensure to align the corresponding x and y values after skipping missing values
#     t_CH1_clean = collect(skipmissing(df.t_CH1))
#     V_CH1_clean = collect(skipmissing(df.V_CH1))
#
#     t_CH2_clean = collect(skipmissing(df.t_CH2))
#     V_CH2_clean = collect(skipmissing(df.V_CH2))
#
#     # Plot without missing values
#     CH1 = plot!(uconvert.(u"ms", t_CH1_clean), value.(V_CH1_clean), ribbon=ustrip.(uncertainty.(t_CH1_clean)), label="CH. 1", color=:orange, legend=false)
#     CH2 = plot!(uconvert.(u"ms", t_CH2_clean), value.(V_CH2_clean), ribbon=ustrip.(uncertainty.(t_CH2_clean)), label="CH. 2", color=:black)
# end
