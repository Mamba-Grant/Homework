using CSV, DataFrames, Unitful, Plots, Statistics, FFTW, Measurements
using Measurements: value 
using Measurements: uncertainty
theme(:bright)

# Read the data files
files = readdir("../data/frequency_sweep/", join=true, sort=true)
dfs = [(CSV.read(file, DataFrame), basename(file)) for file in files]
dfs = [(select(df, [4,5,10,11]), name) for (df, name) in dfs]
dfs = [(transform!(df,
                   [1] => ByRow(x -> x*u"s") => :time_in,
                   [3] => ByRow(x -> x*u"s") => :time_out,
                   [2] => ByRow(x -> (x ± x*0.03)*u"mV") => :v_in,
                   [4] => ByRow(x -> (x ± x*0.03)*u"mV") => :v_out
                   ), name) for (df, name) in dfs]

# Extract frequencies from filenames
frequencies = Float64[]
for (_, name) in dfs
    # Assuming filenames contain frequency info like "filter_response_1000Hz.csv"
    m = match(r"(\d+)Hz", name)
    if m !== nothing
        push!(frequencies, parse(Float64, m.captures[1]))
    end
end

# Calculate gain and phase for each frequency
gains = Measurement[]
phases = Measurement[]

for (i, (df, _)) in enumerate(dfs)
    # Calculate RMS values for accurate amplitude measurement
    v_in_rms = sqrt(mean(value.(df.v_in).^2))
    v_in_rms_uncertainty = sqrt(mean(uncertainty.(df.v_in).^2))
    v_in_rms_with_uncertainty = v_in_rms ± v_in_rms_uncertainty
    
    v_out_rms = sqrt(mean(value.(df.v_out).^2))
    v_out_rms_uncertainty = sqrt(mean(uncertainty.(df.v_out).^2))
    v_out_rms_with_uncertainty = v_out_rms ± v_out_rms_uncertainty
    
    # Calculate gain in dB with propagated uncertainty
    gain_db = 20 * log10(v_out_rms_with_uncertainty / v_in_rms_with_uncertainty)
    push!(gains, gain_db)
    
    # Prepare input and output signals for phase calculation
    in_signal = ustrip.(value.(df.v_in))
    out_signal = ustrip.(value.(df.v_out))
    
    min_length = min(length(in_signal), length(out_signal))
    in_signal = in_signal[1:min_length]
    out_signal = out_signal[1:min_length]
    
    # Cross-correlation for phase detection
    xcorr = real.(ifft(fft(in_signal) .* conj.(fft(out_signal))))
    _, max_idx = findmax(abs.(xcorr))
    
    # Time shift calculation
    sampling_period = ustrip(df.time_in[2] - df.time_in[1])
    time_shift = (max_idx > length(xcorr)÷2 ? max_idx - length(xcorr) : max_idx) * sampling_period
    
    # Estimate uncertainty in time shift
    # We can use uncertainty based on sampling rate and signal-to-noise ratio
    # As a rough estimate, let's use ±1 sample period as basic uncertainty
    # If noise is significant, this could be higher
    time_shift_uncertainty = sampling_period
    time_shift_measurement = time_shift ± time_shift_uncertainty
    freq = frequencies[i]
    phase_deg = time_shift_measurement * freq * 360
    push!(phases, phase_deg)
end

# Sort data by frequency
sorted_indices = sortperm(frequencies)
sorted_frequencies = frequencies[sorted_indices]
sorted_gains = gains[sorted_indices]
sorted_phases = phases[sorted_indices]

# Create Bode plot
p1 = scatter(sorted_frequencies, value.(sorted_gains), 
             yerr = uncertainty.(sorted_gains),
             xscale=:log10, 
             xlabel="Frequency (Hz)", 
             ylabel="Gain (dB)",
             title="Bode Plot - Magnitude",
             label="Gain",
             grid=true,
             ms=4,
             color=:red,
             xticks=[10, 10^2, 10^3, 10^4, 10^5, 10^6],
             legend=:topright)

vline!(p1, [12664.46], color=:gray, ls=:dash, label="3 dB Point")
annotate!(p1, (10e3,-30,text("12664.46 Hz", 14, :right, :gray)))

p2 = scatter(sorted_frequencies, value.(sorted_phases), 
             yerr = uncertainty.(sorted_phases),
             xscale=:log10, 
             xlabel="Frequency (Hz)", 
             ylabel="Phase (degrees)",
             title="Bode Plot - Phase",
             label="Phase",
             marker=:circle,
             markersize=4,
             grid=true,
             linewidth=2,
             xticks=[10, 10^2, 10^3, 10^4, 10^5, 10^6],
             color=:blue,
             legend=:topright)

# vline!(p2, [80e3], color=:gray, ls=:dash, label="3 dB Point")
# annotate!(p2, (78e3,-30,text("12664.46 Hz", 14, :right, :gray)))

# Combine plots
bode_plot = plot(p1, p2, layout=(2,1))
display(bode_plot)

using Interpolations
gain_values = value.(sorted_gains)
frequency_values = sorted_frequencies
# Step 1: Identify the index of the maximum gain
max_gain, max_index = findmax(gain_values)
target_gain = max_gain - 3

# Step 2: Search for the -3 dB point only on the right side of the peak
for i in (max_index+1):length(gain_values)
    if gain_values[i] ≤ target_gain && gain_values[i-1] > target_gain
        # Linear interpolation between points i-1 and i
        f1, f2 = frequency_values[i-1], frequency_values[i]
        g1, g2 = gain_values[i-1], gain_values[i]
        cutoff_freq = f1 + (target_gain - g1) * (f2 - f1) / (g2 - g1)
        println("Corrected 3 dB point (cutoff frequency): $(round(cutoff_freq, digits=2)) Hz")
        break
    end
end

