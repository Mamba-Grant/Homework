using DataFrames, Plots, Unitful, Dates, PyCall, Measurements, CSV, Statistics
iminuit = pyimport("iminuit")
theme(:dao)

idx2resistance(x) = (5.1 * x + 2.2) * u"Ω"
resistance2idx(x) = ustrip(x / 5.1 - 2.2) 

df1::DataFrame = CSV.read.("../data/experiment_9_data.csv", DataFrame;)
df2::DataFrame = CSV.read.("../data/experiment_9_data_-_VBVE.csv", DataFrame;)
df3::DataFrame = CSV.read.("../data/experiment_9_data_-_VC.csv", DataFrame;)
df1 = rename(df1[:, [4, 5, 10, 11]], [:t_Vin, :Vin, :t_Vout, :Vout])
df2 = rename(df2[:, [4, 5, 10, 11]], [:t_VB, :VB, :t_VE, :VE])
df3 = rename(df3[:, [4, 5]], [:t_VC, :VC])

df = hcat(df1, df2, df3)

transform!(df, 
            :t_Vin => ByRow(x -> (x) * u"s") => :t_Vin,
            :t_Vout => ByRow(x -> (x) * u"s") => :t_Vout,
            :t_VB => ByRow(x -> (x) * u"s") => :t_VB,
            :t_VE => ByRow(x -> (x) * u"s") => :t_VE,
            :t_VC => ByRow(x -> (x) * u"s") => :t_VC,
            :Vin => ByRow(x -> (x ± x * 0.03) * u"V") => :Vin,
            :Vout => ByRow(x -> (x ± x * 0.03) * u"V") => :Vout,
            :VB => ByRow(x -> (x ± x * 0.03) * u"V") => :VB,
            :VE => ByRow(x -> (x ± x * 0.03) * u"V") => :VE,
            :VC => ByRow(x -> (x ± x * 0.03) * u"V") => :VC,
) # assign units and errors to data all at once

p1 = plot(title="Transistor Voltages", legend=:topleft);
p2 = plot(title="Input and Output Voltages", legend=:bottomleft);

scatter!(p1, uconvert.(u"ms", df.t_VB), df.VB, ms=1, label="VB (Mean: $(round(ustrip.(mean(df.VB)), digits=3)) V)", c=1);
# hline!(p1, [mean(df.VB)], c=1, label="")
hline!(p1, [(2.223 ± 0.011)*u"V"], ls=:dash, c=1, label="Theoretical (2.223 ± 0.011)")
scatter!(p1, uconvert.(u"ms", df.t_VE), df.VE, ms=1, label="VE (Mean: $(round(ustrip.(mean(df.VE)), digits=3)) V)", c=2);
# hline!(p1, [mean(df.VB)], c=2, label="")
hline!(p1, [(1.623 ± 0.011)*u"V"], ls=:dash, c=2, label="Theoretical (1.623 ± 0.011)")
scatter!(p1, uconvert.(u"ms", -df.t_VC), df.VC, ms=1, label="VC (Mean: $(round(ustrip.(mean(df.VC)), digits=3)) V)", c=3);
# hline!(p1, [mean(df.VC)], c=3, label="")
hline!(p1, [(7 ± 0.011)*u"V"], ls=:dash, c=3, label="Theoretical (7 ± 0.011)")
scatter!(p2, uconvert.(u"ms", df.t_Vin), df.Vin, ms=1, label="Input (Amplitude: $((maximum(df.Vin)-minimum(df.Vin))/2))", c=4);
scatter!(p2, uconvert.(u"ms", df.t_Vout), df.Vout, ms=1, label="Output (Amplitude: $((maximum(df.Vout)-minimum(df.Vout))/2))", c=5);

df4::DataFrame = CSV.read.("../data/exp9.txt", DataFrame;)
df4.time = @. df4.time * 1e3 - 2.02
plot!(p1, df4.time, df4."V(vb)", label="Simulated VB")
plot!(p1, df4.time, df4."V(ve)", label="Simulated VE")
plot!(p1, df4.time, df4."V(vc)", label="Simulated VC")
plot!(p2, df4.time, df4."V(vin)", label="Simulated Input")
plot!(p2, df4.time, df4."V(vout)", label="Simulated Output")

include("theory2.jl")

plot!(p2, df.t_Vin, Vout_theory, ms=1, label="Theoretical Output (Amplitude: $((maximum(Vout_theory)-minimum(Vout_theory))/2))") # Vout_theory comes from that other file

p = plot(p1, p2, layout=(2,1), size=[800, 600])
