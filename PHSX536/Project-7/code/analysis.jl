using Interpolations
include("import_data.jl")

# MAKE MY PLOTS FOR NO DIODE DATA

nd_p1 = plot(xlabel="Time (ms)", ylabel="Voltage (V)", legend=:false)
for (i, df) in enumerate(d_dfs)
    df = dropmissing(df)  # Skip missing rows
    scatter!(nd_p1, uconvert.(u"ms", df.t_CH1), df.V_CH1, 
          c=3, ms=1,
          label="CH1", lw=2, alpha=0.7)

    scatter!(nd_p1, uconvert.(u"ms", df.t_CH2), df.V_CH2, 
          c=2, ms=1,
          label="CH2", lw=2, alpha=0.7)
end

nd_stats = map(nd_dfs) do df 
    VPP = maximum(df.V_CH2) - minimum(df.V_CH2)
    m = mean(df.V_CH2)
    ripple = VPP/m
    DataFrame(PP=VPP, Mean=m, Ripple=ripple, Resistance=df.resistance[1])
end
nd_stats = vcat(nd_stats...) # get all the stats in one dataframe

nd_p2 = plot(xlabel="Ω", ylabel="V")
nd_px2 = plot(xlabel="Ω", ylabel="Ripple", legend=false)
# px2 = twinx(nd_p2)
scatter!(nd_p2, (nd_stats.Resistance), ustrip.(nd_stats.Ripple), label="Ripple", yaxis="Ripple", ms=2)
scatter!(nd_px2, ustrip.(nd_stats.Resistance), ustrip.(nd_stats.PP), label="Peak to Peak", yaxis="V", ms=2)
scatter!(nd_px2, ustrip.(nd_stats.Resistance), ustrip.(nd_stats.Mean), label="Mean", ms=2)

nd_p = plot(nd_p1, nd_p2, layout=[1,2])

# REPEAT FOR THE DIODE DATA

d_p1 = plot(xlabel="Time (ms)", ylabel="Voltage (V)", legend=:false)
for (i, df) in enumerate(d_dfs)
    df = dropmissing(df)  # Skip missing rows
    scatter!(d_p1, uconvert.(u"ms", df.t_CH1), df.V_CH1, 
          c=3, ms=1,
          label="CH1", lw=2, alpha=0.7)

    scatter!(d_p1, uconvert.(u"ms", df.t_CH2), df.V_CH2, 
          c=2, ms=1,
          label="CH2", lw=2, alpha=0.7)
end

d_stats = map(d_dfs) do df
    df = dropmissing(df)  # Ensure missing values are removed
    VPP = maximum(df.V_CH2) - minimum(df.V_CH2)
    m = mean(df.V_CH2)
    ripple = VPP / m
    DataFrame(PP=VPP, Mean=m, Ripple=ripple, Resistance=df.resistance[1])
end

d_stats = vcat(d_stats...)  # Ensure correct variable name

d_p2 = plot(xlabel="Ω", ylabel="V", legend=false)
d_px2 = plot(xlabel="Ω", ylabel="Ripple", legend=false)
scatter!(d_p2, ustrip.(d_stats.Resistance), ustrip.(d_stats.Ripple), label="Ripple", yaxis="Ripple", ms=2)
scatter!(d_px2, ustrip.(d_stats.Resistance), ustrip.(d_stats.PP), label="Peak to Peak", yaxis="V", ms=2)
scatter!(d_px2, ustrip.(d_stats.Resistance), ustrip.(d_stats.Mean), label="Mean", ms=2)

d_p = plot(d_p1, d_p2, layout=[1,2])

# SIMULATION: DIODE
e_df = CSV.read("../simulated_with_diode/EXP7Data", comment="Step", DataFrame;)
e_df = e_df[(44.95e-3 .< e_df.time .< 54.95e-3 ), :] .- 44.95e-3 .- (54.95e-3 - 44.95e-3)/2 .- 0.07e-3
plot!(d_p1, e_df.time .* u"s", e_df."V(ch1)" .* u"V", seriestype=:line, c=1, alpha=0.04)
plot!(d_p1, e_df.time .* u"s", e_df."V(ch2)" .* u"V", seriestype=:line, c=4, alpha=0.04)

e_s_df = CSV.read("../simulated_with_diode/EXP7Stats", comment="Step", DataFrame;)
plot!(d_px2, e_s_df.rl, e_s_df.VPP, label="Sim. VPP", c=1)
plot!(d_px2, e_s_df.rl, e_s_df.RMS, label="Sim. RMS", c=2)
plot!(d_p2, e_s_df.rl, e_s_df."VPP/RMS", label="Sim. Ripple")

meas = d_stats.Ripple
x_meas = value.(ustrip.(nd_stats.Resistance))  # x-values of measured data
x_sim = e_s_df.rl
sim = e_s_df."VPP/RMS"

itp = LinearInterpolation(x_sim, unique.(value.(sim)), extrapolation_bc=Flat())
itp_unc = LinearInterpolation(x_sim, unique.(uncertainty.(sim)), extrapolation_bc=Flat())
sim_interp = vcat(itp.(sort(x_meas))...)
sim_unc_interp = vcat(itp_unc.(sort(x_meas))...)

zsim_diode = @. (value.(meas) - value.(sim_interp)) / sqrt.(uncertainty.(meas)^2 + uncertainty.(sim_unc_interp)^2)
chisq_sim_diode_full = sum(zsim_diode) ./ (length(meas)-1)

# SIMULATION: NO DIODE

e_df = CSV.read("../simulated_no_diode/EXP7DATANODIODE", comment="Step", DataFrame;)
e_df = e_df[(44.95e-3 .< e_df.time .< 54.95e-3 ), :] .- 44.95e-3 .- (54.95e-3 - 44.95e-3)/2 .- 0.07e-3
plot!(nd_p1, e_df.time .* u"s", e_df."V(ch1)" .* u"V", seriestype=:line, c=1, alpha=0.04)
plot!(nd_p1, e_df.time .* u"s", e_df."V(ch2)" .* u"V", seriestype=:line, c=4, alpha=0.04)

e_s_df = CSV.read("../simulated_no_diode/EXP7STATSNODIODE", comment="Step", DataFrame;)
plot!(nd_px2, e_s_df.rl, e_s_df.VPP, label="Sim. VPP", c=1)
plot!(nd_px2, e_s_df.rl, e_s_df.RMS, label="Sim. RMS", c=2)
plot!(nd_p2, e_s_df.rl, e_s_df."VPP/RMS", label="Sim. Ripple")

meas = d_stats.Ripple
x_meas = value.(ustrip.(nd_stats.Resistance))  # x-values of measured data
x_sim = e_s_df.rl
sim = e_s_df."VPP/RMS"

itp = LinearInterpolation(x_sim, unique.(value.(sim)), extrapolation_bc=Flat())
itp_unc = LinearInterpolation(x_sim, unique.(uncertainty.(sim)), extrapolation_bc=Flat())
sim_interp = vcat(itp.(sort(x_meas))...)
sim_unc_interp = vcat(itp_unc.(sort(x_meas))...)

zsim_diode = @. (value.(meas) - value.(sim_interp)) / sqrt.(uncertainty.(meas)^2 + uncertainty.(sim_unc_interp)^2)
chisq_sim_diode_full = sum(zsim_diode) ./ (length(meas)-1)


# THEORY
r(f, C, R) = 1/(2*f*(68.1u"Ω" + R)*C)
plot!(nd_p2, value.(sort(nd_stats.Resistance)), value.(ustrip.(r.(200u"Hz", (9.763 ± 0.156) * 1e-6u"F", sort(nd_stats.Resistance)))), 
      ribbon=uncertainty.(ustrip.(r.(200u"Hz", (9.763 ± 0.156) * 1e-6u"F", sort(nd_stats.Resistance)))),
      c=3, label="Theoretical Ripple")

meas = nd_stats.Ripple
theory = (ustrip.(r.(200u"Hz", (9.763 ± 0.156) * 1e-6u"F", sort(nd_stats.Resistance))))
ztheory = @. (value.(meas) - value.(theory)) / sqrt.(uncertainty.(meas)^2 + uncertainty.(theory)^2)
chisq_full = sum(ztheory) ./ (length(meas)-1)
chisq_better = sum(ztheory[4:end]) ./ (length(meas[4:end])-1)

p1 = plot(nd_p1, d_p1, layout=(2, 1), link=:all, title="CH. 1 & CH. 2")
p2 = plot(nd_p2, d_p2, layout=(2, 1), link=:all, title="Characteristic Curves", legend=:outerbottom, legendcolumns=2)
p3 = plot(nd_px2, d_px2, layout=(2, 1), link=:all, legend=:outerbottom, legendcolumns=2)
p = plot(p1, p2, p3, dpi=300, layout=(1,3), size=(1400, 600))
