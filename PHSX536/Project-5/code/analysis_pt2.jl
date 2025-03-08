using DataFrames, Measurements, Statistics, CSV, Plots, Unitful
theme(:vibrant)

idx2resistance(x) = 1e3 * (0.0051 * x + 0.0022) # returns in ohms

df = DataFrame(CSV.File("../data/pt2.csv"))

transform!(df, 
           :Vs => ByRow(x -> (x ± x * 0.03) * u"mV") => :Vs,
           :P2P1 => ByRow(x -> (x ± x * 0.03) * u"mV") => :P2P1,
           :P2P2 => ByRow(x -> (x ± x * 0.03) * u"mV") => :P2P2,
           :Potentiometer => ByRow(x -> (x ± 1)) => :Potentiometer,
)
df.Freq = @. (df.Freq ± df.FreqErr) * u"Hz"
df.Phase = @. (df.Phase ± df.PhaseErr) * u"°"
df.PotentiomerResistance = @. idx2resistance(df.Potentiometer) * u"Ω"
df.Gain = @. 20 * log.(df.P2P2 ./ df.P2P1) * u"dB"
df = df[!, Not("FreqErr", "PhaseErr")]
df.Power = @. df.P2P2^2 ./ df.PotentiomerResistance
df.Power = uconvert.(u"W", df.Power)

p1 = scatter(df.PotentiomerResistance, df.Phase .- 90u"°", label="Phase", ms=3)
p2 = scatter(df.PotentiomerResistance, df.Power, label="Power", ms=3)

p = plot(p1, p2, layout=(2,1))

print(df)
