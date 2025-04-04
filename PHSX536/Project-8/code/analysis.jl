using Measurements, Unitful, CSV, DataFrames, Plots, Statistics, LaTeXStrings
# Note to self: add stdev in VBE (non constant) to the total uncertainty so far

import Measurements: value
import Measurements: uncertainty
theme(:wong2)

idx2resistance(x) = (5.1 * x + 2.2) * u"Ω"
resistance2idx(x) = ustrip(x / 5.1 - 2.2) 

V12 = (12.12 ± 0.02) * u"V"
V5 = (4.960 ± 0.005) * u"V"

df::DataFrame = CSV.read.("../data/data.csv", DataFrame;)

transform!(df, 
           :VBE => ByRow(x -> (x ± x * 0.009) * u"V") => :VBE,
           :VCE => ByRow(x -> (x ± x * 0.009) * u"V") => :VCE,
           :idx => ByRow(x -> (x ± 2)) => :idx,
           :Rb => ByRow(x -> (x ± x * 0.09) * 1e3u"Ω")  => :Rb,
) # assign units and errors to data all at once
df.Rc = idx2resistance.(df.idx)

Ic(Vce, Rc) = (V12 - Vce) / Rc  
Ib(Vbe, Rb) = (Vbe - V5) / Rb
# β = @. Ic(df1.VCE, df1.Rc) / Ib(df1.VBE)

df1 = df[(value.(df.Rb) .== 100.8u"kΩ"), :]
df2 = df[(value.(df.Rb) .== 47.6u"kΩ"), :]
df3 = df[(value.(df.Rb) .== 9.97u"kΩ"), :]

p = scatter(df1.VCE, uconvert.(u"mA", Ic.(df1.VCE, df1.Rc));
        xlabel=L"\mathrm{V_{ce}}", ylabel=L"\mathrm{I_{c}}", 
        label=L"R_B = 100\mathrm{~k\Omega}",
        c=1
)
# annotate!(0.1, 50, L"α", c=1)
annotate!(4, 6, "IB=$(uconvert(u"mA", mean(Ib.(df1.VBE, df1.Rb))))", c=1)

scatter!(df2.VCE, uconvert.(u"mA", Ic.(df2.VCE, df2.Rc));
         xlabel=L"\mathrm{V_{ce}}", ylabel=L"\mathrm{I_{c}}", 
         label=L"R_B = 47\mathrm{~k\Omega}",
         c=2
)
# annotate!(0.23, 25, L"β", c=2)
annotate!(4.7, 39, "IB=$(uconvert(u"mA", mean(Ib.(df2.VBE, df2.Rb))))", c=2)

scatter!(df3.VCE, uconvert.(u"mA", Ic.(df3.VCE, df3.Rc));
         xlabel=L"\mathrm{V_{ce}}", ylabel=L"\mathrm{I_{c}}", 
         label=L"R_B = 10\mathrm{~k\Omega}",
         c=3
)
annotate!(2, 70, "IB=$(uconvert(u"mA", mean(Ib.(df3.VBE, df3.Rb))))", c=3)

# RL = 155u"Ω"
VCC = 12u"V"
load(x, RL) = - 1/(RL) * (x*u"V" - VCC)

plot!(0:6, load.(0:6, 155u"Ω"), ls=:dash, label="Load Line #3: 155Ω")
plot!(0:6, load.(0:6, 410u"Ω"), ls=:dash, label="Load Line #2: 410Ω")
plot!(0:6, load.(0:6, 614u"Ω"), ls=:dash, label="Load Line #1: 614Ω")

# -----------------------------------------------------

Ic(V12, Vce, Rc) = (V12 - Vce) / Rc  
Ib(V5, Vbe, Rb) = (Vbe - V5) / Rb

df1_sim = CSV.read("../data/100ksim", DataFrame)
df2_sim = CSV.read("../data/47ksim", DataFrame)
df3_sim = CSV.read("../data/10ksim", DataFrame)

transform!.([df1_sim, df2_sim, df3_sim], 
           "V(bout)" => ByRow(x -> x * u"V") => "V(bout)",
           "V(cout)" => ByRow(x -> x * u"V") => "V(cout)",
           :r => ByRow(x -> x * u"Ω")  => :r,
) # assign units and errors to data all at once

plot!(p, df1_sim."V(cout)", uconvert.(u"mA", Ic.(12.0u"V", df1_sim."V(cout)", df1_sim.r));
      c=1, label="Simulated 100k", xlims=[0, 6]
)

plot!(p, df2_sim."V(cout)", uconvert.(u"mA", Ic.(12.0u"V", df2_sim."V(cout)", df2_sim.r));
      c=2, label="Simulated 47k", xlims=[0, 6]
)

plot!(p, df3_sim."V(cout)", uconvert.(u"mA", Ic.(12.0u"V", df3_sim."V(cout)", df3_sim.r));
      c=3, label="Simulated 10k", xlims=[0, 6]
)


# -----------------------------------------------------
df1.Ic .= Ic.(df1.VCE, df1.Rc)
df1.Ib .= Ib.(df1.VBE, df1.Rb)
df2.Ic .= Ic.(df2.VCE, df2.Rc)
df2.Ib .= Ib.(df2.VBE, df2.Rb)
df3.Ic .= Ic.(df3.VCE, df3.Rc)
df3.Ib .= Ib.(df3.VBE, df3.Rb)

Ic1 = mean(uconvert.(u"mA", df1[(df1.Ic .> 10u"mA"), :].Ic))
Ib1 = mean(uconvert.(u"mA", df1[(df1.Ic .> 10u"mA"), :].Ib))
Ic2 = mean(uconvert.(u"mA", df2[(df2.Ic .> 20u"mA"), :].Ic))
Ib2 = mean(uconvert.(u"mA", df2[(df2.Ic .> 20u"mA"), :].Ib))
Ic3 = mean(uconvert.(u"mA", df3[(80u"mA" .> df3.Ic .> 75u"mA"), :].Ic))
Ib3 = mean(uconvert.(u"mA", df3[(80u"mA" .> df3.Ic .> 75u"mA"), :].Ib))

β = (
    df1=Ic1/Ib1,
    df2=Ic2/Ib2,
    df3=Ic3/Ib3,
)

df2_sim.Ic .= Ic.(12.0u"V", df2_sim."V(cout)", df2_sim.r)
df2_sim.Ib .= Ib.(5u"V", df2_sim."V(bout)", df2_sim.r)
Ic1 = mean(uconvert.(u"mA", df2_sim[(1u"V" .< df2_sim."V(cout)" .< 6u"V"), :].Ic))
Ib1 = mean(uconvert.(u"mA", df2_sim[(1u"V" .< df2_sim."V(cout)" .< 6u"V"), :].Ib))

