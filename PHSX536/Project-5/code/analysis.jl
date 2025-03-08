using DataFrames, Measurements, Statistics, CSV, Plots, Unitful
using LaTeXStrings
theme(:dao)

idx2resistance(x) = 1e3 * (0.0051 ± 0.0001 * x + 0.0022 ± 0.0001) # returns in ohms

df = DataFrame(CSV.File("../data/pt1.1.csv"))

transform!(df, 
           :Vs => ByRow(x -> (x ± x * 0.03) * u"mV") => :Vs,
           :P2P1 => ByRow(x -> (x ± x * 0.03) * u"mV") => :P2P1,
           :P2P2 => ByRow(x -> (x ± x * 0.03) * u"mV") => :P2P2,
           :Potentiometer => ByRow(x -> (x ± 1)) => :Potentiometer,
)
df.Freq = @. (df.Freq ± df.FreqErr) * u"Hz"
df.Phase = @. (df.Phase ± df.PhaseErr) * u"°"
# df.PotentiomerResistance .= idx2resistance(df.Potentiometer) * u"Ω"
df.Gain = @. 20 * log.(df.P2P2 ./ df.P2P1) * u"dB"
df = df[!, Not("FreqErr", "PhaseErr")]

function parse_data_file(filename)
    df = DataFrame(Freq = Float64[], dB = Float64[], Phase = Float64[])
    
    open(filename, "r") do io
        readline(io)  # Skip the header
        for line in eachline(io)
            line = strip(line)
            if isempty(line)
                continue
            end
            
            parts = split(line, '\t')
            freq = parse(Float64, parts[1])
            
            tuple_str = strip(parts[2], ['(', ')'])
            values = split(tuple_str, ",")
            
            # Remove any unwanted characters explicitly, including the degree symbol.
            dB_val = parse(Float64, replace(values[1], r"[^0-9eE.\-]" => ""))
            phase_val = parse(Float64, replace(values[2], "\xb0" => ""))  

            push!(df, (Freq = freq, dB = dB_val, Phase = phase_val))
        end
    end
    
    return df
end

df_sim = parse_data_file("../data/pt1_sim.txt")

p1 = scatter(df.Freq, df.Gain, label="Gain", xscale=:log10, xlabel="Frequency", ms=3)
vline!([4.6e6], label="4.6 MHz", linestyle=:dash, color=:gray)
p2 = scatter(df.Freq, df.P2P2, label=L"V_S", xscale=:log10, xlabel="Frequency",  ms=3)
vline!([4e6], label="4 MHz", linestyle=:dash, color=:gray)

# plot!(df_sim.Freq, df_sim.dB,
#                     title = "Bode Plot (Magnitude)",
#                     legend = false)
# p2 = scatter(df.Freq, (df.Phase), label="Phase", xlabel="Frequency", xscale=:log10, ylabel="Phase (deg)", ms=3)
# plot!(df_sim.Freq, df_sim.Phase,
#                       title = "Bode Plot (Phase)",
#                       legend = false)

p = plot(p1, p2, layout=(2,1))

p1
print(df)

# p3 = scatter(df.PotentiomerResistance./1000, (df.P2P2./df.P2P1))

# p1 = scatter(df.Freq, (df.P2P2), label="Gain", ylabel="dB")
# scatter!(df.Freq, (df.P2P1), label="Gain", ylabel="dB")
