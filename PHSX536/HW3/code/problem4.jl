using Plots, CSV, DataFrames

data_dir = "../problem4data"

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
data::Vector{DataFrame} = parse_data_file.(readdir("./problem4data/", join=true))

# Create a Bode plot for each dataset in `data`
plots = map(data) do df
    # Magnitude plot: dB vs Frequency (log scale)
    mag_plot = plot(df.Freq, df.dB,
                    xscale = :log10,
                    xlabel = "Frequency (Hz)",
                    ylabel = "Magnitude (dB)",
                    title = "Bode Plot (Magnitude)",
                    legend = false)

    # Phase plot: Phase vs Frequency (log scale)
    phase_plot = plot(df.Freq, df.Phase,
                      xscale = :log10,
                      xlabel = "Frequency (Hz)",
                      ylabel = "Phase (deg)",
                      title = "Bode Plot (Phase)",
                      legend = false)

    # Combine the two plots vertically into one figure
    plot(mag_plot, phase_plot, layout = (2, 1))
end
