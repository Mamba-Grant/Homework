using CSV, Plots, Measurements, Unitful, LaTeXStrings, DataFrames

df = CSV.read("../data/part1_latch.csv", DataFrame;)
transform!(df,
           "D" => ByRow(x -> (x ± x*0.03)*u"V") => "D",
           "C" => ByRow(x -> (x ± x*0.03)*u"V") => "C",
           "Qinitial" => ByRow(x -> (x ± x*0.03)*u"V") => "Qinitial",
           "Qfinal" => ByRow(x -> (x ± x*0.03)*u"V") => "Qfinal",
)
