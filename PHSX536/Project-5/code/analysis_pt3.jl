using DataFrames, Measurements, Statistics, CSV, Plots, Unitful
theme(:vibrant)

idx2resistance(x) = 1e3 * (0.0051 * x + 0.0022) # returns in ohms

df = DataFrame(CSV.File("../data/pt3.csv"))

transform!(df, 
           :P2P1 => ByRow(x -> (x ± x * 0.009) * u"mV") => :P2P1,
           :P2P2 => ByRow(x -> (x ± x * 0.009) * u"mV") => :P2P2,
   # "Vs (mV)" => ByRow(x -> x ± x * 0.009) => "Vs (mV)"
)
df.Freq = @. (df.Freq ± df.FreqErr) * u"Hz" 
df.Phase = @. (df.Phase ± df.PhaseErr) * u"°"
df.PotentiomerResistance = @. idx2resistance(df.Potentiometer) * u"Ω"
df.Gain = @. df.P2P2 ./ df.P2P1
df.Power = @. df.P2P2^2 ./ df.PotentiomerResistance

p1 = scatter(df.PotentiomerResistance, (df.Gain), label="Gain", ms=3)
p2 = scatter(df.PotentiomerResistance, uconvert.(u"W", df.Power), label="Power", ms=3)

p = plot(p1, p2, layout=(2,1))
#
print(df)
