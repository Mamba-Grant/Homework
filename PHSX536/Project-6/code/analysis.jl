using Measurements, Unitful, DataFrames, CSV, Plots
import Measurements: value
import Measurements: uncertainty
default(dpi=800)
theme(:vibrant)

dfs::Vector{DataFrame} = CSV.read.(readdir("../data/", join=true), DataFrame;)
dfs .= [rename(df[:, [4, 5, 10, 11]], [:t_CH1, :V_CH1, :t_CH2, :V_CH2]) for df in dfs] # grab only the columns needed
transform!.(dfs, 
            :t_CH1 => ByRow(x -> (x) * u"s") => :t_CH1,
            :V_CH1 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH1,
            :t_CH2 => ByRow(x -> (x) * u"s") => :t_CH2,
            :V_CH2 => ByRow(x -> (x ± x * 0.03) * u"V") => :V_CH2,
) # assign units and errors to data all at once

sim = CSV.read("../sim/EXP6.txt", comment="Step", delim="\t", DataFrame;)
sim = sim[( 0.02724 .< sim.time .< 0.05245), :]
transform!(sim, 
           :time => ByRow(x -> x* u"s" - (maximum(sim.time)* u"s" - maximum(dfs[1].t_CH1))) => :time,
           :"V(ch1)" => ByRow(x -> x * u"V") => :"V(ch1)",
           :"V(ch2)" => ByRow(x -> x * u"V") => :"V(ch2)",
           :"V(n001)" => ByRow(x -> x * u"V") => :"V(n001)",
           :"V(n003)" => ByRow(x -> x * u"V") => :"V(n003)",
) # assign units and errors to data all at once

plots = map(dfs) do df 
    CH1 = scatter(uconvert.(u"ms", df.t_CH1), (df.V_CH1), label="CH. 1", ms=1)
    CH2 = scatter!(uconvert.(u"ms", df.t_CH2), (df.V_CH2), label="CH. 2", ms=1)
end

plot!.(plots[2:4], Ref(uconvert.(u"ms", sim.time)), Ref(sim."V(ch1)"), label="Sim. CH1", seriestype=:line, ms=2)
plot!(plots[2], uconvert.(u"ms", sim.time), sim."V(n003)", label="Sim. CH2", seriestype=:line, ms=2)
plot!(plots[3], uconvert.(u"ms", sim.time), sim."V(n001)", label="Sim. n001", seriestype=:line, ms=2)
plot!(plots[4], uconvert.(u"ms", sim.time), sim."V(ch2)", label="Sim. n003", seriestype=:line, ms=2)

plotnames = ["Part 1: Zener", "Part 2: Va", "Part 2: Vb", "Part 2: Vc"]
p = plot(
    plot(plots[1], title=plotnames[1]),
    plot(plots[2], title=plotnames[2]),
    plot(plots[3], title=plotnames[3]),
    plot(plots[4], title=plotnames[4]),
    dpi=600
)

peaks = DataFrame(
    type = ["Zener", "Va (Half Wave)", "Vb (Half Wave)", "Vc (Full Wave)"],
    max_V_CH1 = [maximum(df.V_CH1) for df in dfs],
    min_V_CH1 = [minimum(df.V_CH1) for df in dfs],
    max_V_CH2 = [maximum(df.V_CH2) for df in dfs],
    min_V_CH2 = [minimum(df.V_CH2) for df in dfs]
)
function analyze_peaks(peaks)
    println("Peak Analysis Summary:")
    println("-" ^ 40)
    
    for type in peaks.type
        # Find the row for the current type
        ref_row = peaks[peaks.type .== type, :]
        
        # Calculate peaks and peak-to-peak values
        peak_ch1 = ref_row.max_V_CH1[1]
        peak_ch2 = ref_row.max_V_CH2[1]
        vpp_ch1 = ref_row.max_V_CH1[1] - ref_row.min_V_CH1[1]
        vpp_ch2 = ref_row.max_V_CH2[1] - ref_row.min_V_CH2[1]
        
        # Print results for each type
        println("$type:")
        println("  Peak CH1: $(peak_ch1)")
        println("  Peak CH2: $(peak_ch2)")
        println("  Peak Difference: $(peak_ch1 - peak_ch2)")
        println("  Peak-to-Peak CH1: $(vpp_ch1)")
        println("  Peak-to-Peak CH2: $(vpp_ch2)")
        println("  Peak-to-Peak Difference: $(vpp_ch1 - vpp_ch2)")
        println()
    end
end

# Call the function with your existing peaks DataFrame
analyze_peaks(peaks)
