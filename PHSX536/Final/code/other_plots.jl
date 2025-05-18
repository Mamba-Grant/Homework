using CSV, Measurements, Plots, DataFrames, Unitful
using Measurements: uncertainty
using Measurements: value
theme(:bright)

df_output = CSV.read("../data/ideal_scope_trace.csv", DataFrame)
df_output = select(df_output, [4,5,10,11])
df_output = transform!(df_output,
                        [1] => ByRow(x -> x*u"s") => :time_in,
                        [3] => ByRow(x -> x*u"s") => :time_out,
                        [2] => ByRow(x -> (x ± x*0.03)*u"V") => :v_in,
                        [4] => ByRow(x -> (x ± x*0.03)*u"V") => :v_out
                       )

p = plot(title="Filter Output")
plot!(p, uconvert.(u"ms", df_output.time_in .- 2u"ms"), value.(df_output.v_in), ribbon=uncertainty.(df_output.v_in), label="Input Signal", color=:red)
scatter!(p, uconvert.(u"ms", df_output.time_out .- 2u"ms"), (df_output.v_out), ms=2, label="Output Signal", color=:blue)
