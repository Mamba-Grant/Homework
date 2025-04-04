using Plots, LaTeXStrings

Rf_Ri_ratio = 100  # Rf = 100 * Ri
omega_RC = 1  # Normalization factor for frequency
omega_normalized = exp10.(range(-2, 2, 500))  # From 0.01 to 100 in log scale

G(ω) = 1 + Rf_Ri_ratio / (1 + im * ω)
p = plot(omega_normalized, abs.(G.(omega_normalized)), 
     xlabel=L"ω/ω_{RC}", ylabel=L"|G(f)|",
     label=L"|G(f)|", xaxis=:log, yaxis=:log)

