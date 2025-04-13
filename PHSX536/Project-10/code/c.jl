using CSV, Plots, Measurements, Unitful, LaTeXStrings, DataFrames

df = CSV.read("../data/part c.csv", DataFrame;)
transform!(df,
           "Vin" => ByRow(x -> (x ± x*0.03)*u"V") => "Vin",
           "Vout" => ByRow(x -> (x ± x*0.03)*u"V") => "Vout",
           :R1 => ByRow(x -> (x ± x*0.009)*u"Ω") => :R1,
           :R2 => ByRow(x -> (x ± x*0.009)*u"Ω") => :R2,
           "V+12" => ByRow(x -> (x ± x*0.03)*u"V") => "V+12",
           "V-12" => ByRow(x -> (x ± x*0.03)*u"V") => "V-12",
)
print(df)
df.G = df.Vout./df.Vin
df."G (Theoretical)" = 1 .+ df.R2./df.R1
