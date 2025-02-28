using DataFrames, CSV, Plots, Measurements
theme(:bright)
# plotlyjs();

df1 = DataFrame(CSV.File("../data/circuit1-data-1.csv"))
df1[!, "Frequency (Hz)"] = @. df1[!, "Frequency (Hz)"] ± df1[!, "FreqErr"]
df1[!, "Phase 2-1 (deg)"] = @. df1[!, "Phase 2-1 (deg)"] ± df1[!, "PhaseErr"]
df1[!, "V1Err"] = @. df1[!, "Amplitude 1 (V)"] * 0.03
df1[!, "V2Err"] = @. df1[!, "Amplitude 2 (V)"] * 0.03
df1[!, "Amplitude 1 (V)"] = @. df1[!, "Amplitude 1 (V)"] ± df1[!, "V1Err"]
df1[!, "Amplitude 2 (V)"] = @. df1[!, "Amplitude 2 (V)"] ± df1[!, "V2Err"]
df1[!, "Gain (dB)"] = @. df1[!, "Amplitude 2 (V)"] / df1[!, "Amplitude 1 (V)"]
df1 = select!(df1, ["Amplitude 1 (V)", "Amplitude 2 (V)", "Frequency (Hz)", "Gain (dB)", "Phase 2-1 (deg)"])

# df2 = DataFrame(CSV.File("../data/circuit2-data.csv"))
# df2[!, "Frequency (Hz)"] = @. df2[!, "Frequency (Hz)"] ± df2[!, "FreqErr"]
# df2[!, "Phase 2-1 (deg)"] = @. df2[!, "Phase 2-1 (deg)"] ± df2[!, "PhaseErr"]
# df2[!, "V1Err"] = @. df2[!, "Amplitude 1 (V)"] * 0.03
# df2[!, "V2Err"] = @. df2[!, "Amplitude 2 (V)"] * 0.03
# df2[!, "Amplitude 1 (V)"] = @. df2[!, "Amplitude 1 (V)"] ± df2[!, "V1Err"]
# df2[!, "Amplitude 2 (V)"] = @. df2[!, "Amplitude 2 (V)"] ± df2[!, "V2Err"]
# df2[!, "Gain (dB)"] = @. df2[!, "Amplitude 2 (V)"] / df2[!, "Amplitude 1 (V)"]
# df2 = select!(df2, ["Amplitude 1 (V)", "Amplitude 2 (V)", "Frequency (Hz)", "Gain (dB)", "Phase 2-1 (deg)"])

# Function to define the log scale markers
function get_log_ticks(min_val, max_val, n_ticks)
    log_min = log10(min_val)
    log_max = log10(max_val)
    tick_vals = [10^x for x in LinRange(log_min, log_max, n_ticks)]
    return tick_vals
end

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

# Apply the custom parser to all files in the "raw_data/" directory
sdf::DataFrame = parse_data_file("./data.txt")
sdf.dB = sdf.dB .+ abs(minimum(sdf.dB))
sdf.dB = sdf.dB/abs(maximum(sdf.dB))

plots = map([df1]) do df
    # Get 10 x-axis markers (log scale)
    x_ticks = get_log_ticks(Measurements.value(minimum(df[!, "Frequency (Hz)"])), Measurements.value(maximum(df[!, "Frequency (Hz)"])), 10)

    # Magnitude plot: dB vs Frequency (log scale)
    mag_plot = scatter(df[!, "Frequency (Hz)"], df[!, "Gain (dB)"],
                       xscale = :log10,
                       # xlabel = "Frequency (Hz)",
                       ylabel = "Magnitude (dB)",
                       title = "Bode Plot (Magnitude)",
                       legend = false,
                       ms=3,
                       # xticks = (x_ticks, string.(Int.(round.(Measurements.value.(x_ticks))))))  # Custom x-ticks
                       )

    plot!(sdf.Freq, sdf.dB)

    # Phase plot: Phase vs Frequency (log scale)
    phase_plot = scatter(df[!, "Frequency (Hz)"], df[!, "Phase 2-1 (deg)"],
                         xscale = :log10,
                         xlabel = "Frequency (Hz)",
                         ylabel = "Phase (deg)",
                         title = "Bode Plot (Phase)",
                         legend = false,
                         ms=3,
                         # xticks = (x_ticks, string.(Int.(round.(Measurements.value.(x_ticks))))))  # Custom x-ticks
                         )

    plot!(sdf.Freq, sdf.Phase)

    # Combine the two plots vertically into one figure
    plot(mag_plot, phase_plot, layout = (2, 1))
end
plots[1]
