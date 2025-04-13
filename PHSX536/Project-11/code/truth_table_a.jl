using Measurements, Unitful, CSV, DataFrames

df = CSV.read("../data/truth table.csv", DataFrame)
transform!(df,
           :VA => ByRow(x -> (x ± (0.009*x + 0.002))*u"V") => :VA,
           :VB => ByRow(x -> (x ± (0.009*x + 0.002))*u"V") => :VB,
           :VY => ByRow(x -> (x ± (0.009*x + 0.002))*u"V") => :VY,
           :VCC => ByRow(x -> (x ± (0.009*x + 0.002))*u"V") => :VCC,
           )

df
