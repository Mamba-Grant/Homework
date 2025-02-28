include("frequency_dependence.jl")

    # Load and preprocess data
df_e1 = DataFrame(CSV.File("../data/dependence_on_frequency (CEXT).csv"))
df_e1 = df_e1[!, Not("Column8", "Rin (Ohm)", "Gain (HLE)")]
df_e1 = stack(df_e1, Not(:F1))
rename!(df_e1, :variable => :F2, :value => :Voltage)
df_e1.F1 = replace.(df_e1.F1, r"\s*\(Hz\)" => "")
df_e1.F2 = replace.(df_e1.F2, r"\s*\(kHz\)" => "")
df_e1.Ri .= (2.996e3 ± 2.996e3 * 0.09)u"Ω"
df_e1.δF = @. DDD.value * u"Hz" ± DDD.value * .05u"Hz"

df_e2 = DataFrame(CSV.File("../data/dependence_on_frequency (10k ohm).csv"))
df_e2 = df_e2[!, Not("Column8", "Rin (Ohm)", "Gain (HLE)")]
df_e2 = stack(df_e2, Not(:F1))
rename!(df_e2, :variable => :F2, :value => :Voltage)
df_e2.F1 = replace.(df_e2.F1, r"\s*\(Hz\)" => "")
df_e2.F2 = replace.(df_e2.F2, r"\s*\(kHz\)" => "")
df_e2.Ri .= (10_000 ± 10_000 * 0.001)u"Ω"
df_e2.δF = @. DDD.value * u"Hz" ± DDD.value * .05u"Hz"

x = vcat(ustrip.(df.Ri), 
         ustrip.(df_resistance.δF), 
         # ustrip.(df_e1.Ri), 
         # ustrip.(df_e2.Ri)
         )
y = vcat(ustrip.(df.Voltage ./ df.δF), 
         ustrip.(df_resistance[!, "VJ2"] ./ df_resistance.δF),
         # ustrip.(df_e1.Voltage ./ df_e1.δF),
         # ustrip.(df_e2.Voltage ./ df_e2.δF)
         )

fit = curve_fit(LinearFit, x, y)

p = scatter(ustrip.(df.Ri), ustrip.(df.Voltage ./ df.δF))
scatter!(ustrip.(df_resistance.δF), ustrip.(df_resistance[!, "VJ2"] ./ df_resistance.δF))
# scatter!(ustrip.(df_e1.Ri), ustrip.(df_e1.Voltage ./ df_e1.δF))
# scatter!(ustrip.(df_e2.Ri), ustrip.(df_e2.Voltage ./ df_e2.δF))

grad = -7.31e-15 ± 7.3e-16 
kB = grad / (4 * temperature)

x_fit = range(minimum(x), maximum(x), length=100)
y_fit = fit.(x_fit)
plot!(value.(x_fit), value.(y_fit), 
      ribbon=Measurements.uncertainty.(y_fit), label="Fit")

p
