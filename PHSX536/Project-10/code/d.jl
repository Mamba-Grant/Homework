using CSV, Plots, Measurements, Unitful, LaTeXStrings, DataFrames

df = CSV.read("../data/part d.csv", DataFrame;)
transform!(df,
           "V1" => ByRow(x -> (x ± x*0.03)*u"V") => "V1",
           "V2" => ByRow(x -> (x ± x*0.03)*u"V") => "V2",
           "V3" => ByRow(x -> (x ± x*0.03)*u"V") => "V3",
           "Vout" => ByRow(x -> (x ± x*0.03)*u"V") => "Vout",
           :R1 => ByRow(x -> (x ± x*0.009)*u"Ω") => :R1,
           :R2 => ByRow(x -> (x ± x*0.009)*u"Ω") => :R2,
           :R3 => ByRow(x -> (x ± x*0.009)*u"Ω") => :R3,
           :Rf => ByRow(x -> (x ± x*0.009)*u"Ω") => :Rf,
           "V+12" => ByRow(x -> (x ± x*0.03)*u"V") => "V+12",
           "V-12" => ByRow(x -> (x ± x*0.03)*u"V") => "V-12",
)
