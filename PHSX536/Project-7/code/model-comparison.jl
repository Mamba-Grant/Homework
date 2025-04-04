m = CSV.read("../simulated_no_diode/EXP7STATSNODIODE", comment="Step", DataFrame;)
mthev = CSV.read("../simulated_thevenin_equivalent/EXP7THEV", comment="Step", DataFrame;)

# Create the plot with both lines
p = plot(m.rl, m.RMS, label="Full-Wave Rectifier Model", linewidth=2)
plot!(mthev.rl, mthev.RMS, label="Thevenin Equivalent Model", linewidth=2)

# To shade between curves, we need to ensure they have the same x values
# First, let's check if they already do
if all(m.rl .== mthev.rl)
    # If x values are identical, we can directly fill between curves
    plot!(m.rl, m.RMS, fillrange=mthev.RMS, alpha=0, fillalpha=0.3, fillcolor=:lightblue, label="")
else
    # If x values differ, we need to interpolate
    using Interpolations
    
    # Create interpolation functions for both datasets
    itp_m = linear_interpolation(m.rl, m.RMS)
    itp_mthev = linear_interpolation(mthev.rl, mthev.RMS)
    
    # Create a common x range that covers both datasets
    x_common = range(min(minimum(m.rl), minimum(mthev.rl)), 
                     max(maximum(m.rl), maximum(mthev.rl)), 
                     length=100)
    
    # Interpolate y values for both curves at these x points
    y_m = [itp_m(x) for x in x_common]
    y_mthev = [itp_mthev(x) for x in x_common]
    
    # Add the shaded area
    plot!(x_common, y_m, fillrange=y_mthev, lw=0, fillalpha=0.3, fillcolor=:lightblue, label="Difference")
end

# Enhance the plot
xlabel!("Load Resistance (Ω)")
ylabel!("RMS Voltage (V)")
title!("Model Comparison")
