using Measurements, Unitful, CSV, DataFrames, Plots, Statistics, Measures
import Measurements: value
import Measurements: uncertainty
theme(:bright)

idx2resistance(x) = (5.1 * x + 2.2) * u"Ω"
resistance2idx(x) = x / 5.1 - 2.2

# Filenames are the respective index of the 
nd_dfs = map(f -> (f, CSV.read(f, DataFrame)), readdir("../measurements_no_diode/", join=true))
d_dfs = map(f -> (f, CSV.read(f, DataFrame)), readdir("../measurements_with_diode/", join=true))

nd_dfs = map(t -> begin # iterate over the (file, DataFrame)
    filename = splitext(basename(t[1]))[1] # strip file path, then strip the file extension
    df = t[2]
    df = rename(df[:, [4, 5, 10, 11]], [:t_CH1, :V_CH1, :t_CH2, :V_CH2]) # Grab only the columns needed
    df.idx .= parse(Float64, filename)
    df.resistance .= idx2resistance.(df.idx)
    df
end, nd_dfs)

d_dfs = map(t -> begin # iterate over the (file, DataFrame)
    filename = splitext(basename(t[1]))[1] # strip file path, then strip the file extension
    df = t[2]
    df = rename(df[:, [4, 5, 10, 11]], [:t_CH1, :V_CH1, :t_CH2, :V_CH2]) # Grab only the columns needed
    df.idx .= parse(Float64, filename)
    df.resistance .= idx2resistance.(df.idx)
    df
end, d_dfs)

transform!.(nd_dfs, 
            :t_CH1 => ByRow(x -> (x) * u"s") => :t_CH1,
            :V_CH1 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH1,
            :t_CH2 => ByRow(x -> (x) * u"s") => :t_CH2,
            :V_CH2 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH2,
) # assign units and errors to data all at once

transform!.(d_dfs, 
            :t_CH1 => ByRow(x -> (x) * u"s") => :t_CH1,
            :V_CH1 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH1,
            :t_CH2 => ByRow(x -> (x) * u"s") => :t_CH2,
            :V_CH2 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH2,
) # assign units and errors to data all at once

