using CSV, Plots, Measurements, Unitful, LaTeXStrings, DataFrames

df = CSV.read("../data/frequency-dependence.csv", DataFrame;)
transform!(df,
           :freq => ByRow(x -> (x ± x*0.01)*u"Hz") => :freq,
           "Vin pk-pk" => ByRow(x -> (x ± x*0.03)*u"V") => "Vin pk-pk",
           "Vout pk-pk" => ByRow(x -> (x ± x*0.03)*u"V") => "Vout pk-pk",
           :phase => ByRow(x -> (x ± x*0.01)*u"°") => :phase
)
print(df)
