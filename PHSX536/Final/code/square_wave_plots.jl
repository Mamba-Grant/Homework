using Plots

# Parameters
t = -1.01/2+0.01:0.01:4.01/2-0.01
freq = 1
amp = 1
offset1 = 2
offset2 = -2

# Define square waves
wave1 = amp * sign.(sin.(2π * freq * t)) .+ offset1
wave2 = amp * sign.(sin.(2π * freq * t)) .+ offset2

# Plot
p = plot(t, wave1, label="", lw=2, color=:blue)
plot!(t, wave2, label="", lw=2, color=:red)
plot!(legend=false, grid=false, framestyle=:none, ticks=nothing)
