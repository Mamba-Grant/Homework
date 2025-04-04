p1 = plot(xlabel="Time (ms)", ylabel="Voltage (V)")
p2 = plot(xlabel="Time (ms)", ylabel="Voltage (V)")
scatter!(p1, uconvert.(u"ms", nd_dfs[1].t_CH1), nd_dfs[1].V_CH1, 
         c=1, ms=1, label="Low Resistance, No Diode", lw=2, alpha=0.7,
         )
scatter!(p2, uconvert.(u"ms", nd_dfs[end].t_CH1), nd_dfs[end].V_CH1, 
         c=2, ms=1, label="High Resistance, No Diode", lw=2, alpha=0.7,
         )
scatter!(p1, uconvert.(u"ms", nd_dfs[1].t_CH2), nd_dfs[1].V_CH2, 
         c=1, ms=1, label="", lw=2, alpha=0.7,
         )
scatter!(p2, uconvert.(u"ms", nd_dfs[end].t_CH2), nd_dfs[end].V_CH2, 
         c=2, ms=1, label="", lw=2, alpha=0.7,
         )

scatter!(p1, uconvert.(u"ms", d_dfs[1].t_CH1), d_dfs[1].V_CH1, 
         c=3, ms=1, label="Low Resistance, With Diode", lw=2, alpha=0.7,
         )
scatter!(p2, uconvert.(u"ms", d_dfs[end].t_CH1), d_dfs[end].V_CH1, 
         c=4, ms=1, label="High Resistance, With Diode", lw=2, alpha=0.7,
         )
scatter!(p1, uconvert.(u"ms", d_dfs[1].t_CH2), d_dfs[1].V_CH2, 
         c=3, ms=1, label="", lw=2, alpha=0.7,
         )
scatter!(p2, uconvert.(u"ms", d_dfs[end].t_CH2), d_dfs[end].V_CH2, 
         c=4, ms=1, label="", lw=2, alpha=0.7,
         )

p = plot(p1, p2, legend=:outertop)

