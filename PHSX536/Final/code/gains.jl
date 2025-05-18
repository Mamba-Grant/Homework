using Plots, Unitful, DataFrames, CSV

df_normal = CSV.read("../data/normal response", DataFrame)
df_diode = CSV.read("../data/diode response", DataFrame)

# Compute gain
df_normal.gain = -df_normal."V(out)" ./ df_normal."V(in)"
df_diode.gain = -df_diode."V(out)" ./ df_diode."V(in)"

# Plot gain vs. input voltage
p1 = plot(
    title="Gain vs Input Voltage",
    xlabel="in (V)",
    ylabel="Gain",
    xlims=(0.01, 1),
    ylims=(0, nothing),
    grid=false,
    legend=:outerright
)
p2 = plot(
    title="Input vs Output Voltage",
    xlabel="in (V)",
    ylabel="out (V)",
    xlims=(0.01, 1),
    ylims=(0, nothing),
    grid=false,
    legend=:outerright
)
plot!(p1, df_normal."V(in)", df_normal.gain, label="Ordinary Multiplier", c=:red)
plot!(p1, df_diode."V(in)", df_diode.gain, label="Multiplier with Diodes", c=:blue)
plot!(p2, df_normal."V(in)", -df_normal."V(out)", c=:red, label="Ordinary Multiplier")
plot!(p2, df_diode."V(in)", -df_diode."V(out)", c=:blue, label="Multiplier with Diodes")

p = plot(p1, p2,layout=(2,1))
