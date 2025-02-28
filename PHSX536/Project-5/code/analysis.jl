using DataFrames, Measurements, Statistics, CSV, Plots, Unitful
theme(:vibrant)

idx2resistance(x) = 1e3 * (5.1e-3 * x + 2.2e-3) # returns in ohms

df = DataFrame(CSV.File("../data/pt1.1.csv"))

transform!(df, 
           :P2P1 => ByRow(x -> (x ± x * 0.009) * u"mV") => :P2P1,
           :P2P2 => ByRow(x -> (x ± x * 0.009) * u"mV") => :P2P2,
)
df.Freq = @. df.Freq ± df.FreqErr
df.Phase = @. df.Phase ± df.PhaseErr
df.PotentiomerResistance = @. idx2resistance(df.Potentiometer)
df.Gain = @. df.P2P2 ./ df.P2P1
rename!(df, "Vs (mV)" => "Vs")
df = df[!, Not("FreqErr", "PhaseErr")]

p1 = scatter(df.Freq, (df.P2P2./df.P2P1), label="Gain", ylabel="Gain", ms=3)
p2 = scatter(df.Freq, (df.Phase), label="Phase", xlabel="Hz", ylabel="Phase (deg)", ms=3)

p = plot(p1, p2, layout=(2,1))

print(df)

# p3 = scatter(df.PotentiomerResistance./1000, (df.P2P2./df.P2P1))

# p1 = scatter(df.Freq, (df.P2P2), label="Gain", ylabel="dB")
# scatter!(df.Freq, (df.P2P1), label="Gain", ylabel="dB")
