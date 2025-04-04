include("./amplifier_noise.jl")

# Load and preprocess data
df = DataFrame(CSV.File("../data/dependence_on_frequency (1ohm).csv"))
df = df[!, Not("Column8", "Rin (Ohm)", "Gain (HLE)")]
df = stack(df, Not(:F1))
rename!(df, :variable => :F2, :value => :Voltage)
df.F1 = replace.(df.F1, r"\s*\(Hz\)" => "")
df.F2 = replace.(df.F2, r"\s*\(kHz\)" => "")
df.Ri .= (1_000 ± 1_000 * 0.001)u"Ω"

# Load frequency differences
DDD = DataFrame(CSV.File("../data/frequencies.csv"))
DDD = stack(DDD, Not("f1\\f2"))
df.δF = @. DDD.value * u"Hz" ± DDD.value * .05u"Hz"

# Convert units
transform!(df, 
    :F1 => ByRow(x -> tryparse(Float64, x)* u"Hz") => :F1,
    :F2 => ByRow(x -> tryparse(Float64, x)* u"kHz") => :F2,
    :Voltage => ByRow(x -> (convert(Float64, x)* u"V^2" ± (convert(Float64, x) * u"V^2" .* 0.009))) => :Voltage
)

fc = df.F2 .- df.F1
function frequency_dependent_gain(f, fc, R_feedback=1e3u"Ω", R_source=200u"Ω")
    G1 = 100 ± 2 
    G2 = 1500 ± 30
    G_dc = (1 + R_feedback/R_source) * G1 * G2  # DC gain
    # return G_dc
    return G_dc * 1/sqrt(1 + (f/fc)^4)  # Frequency rolloff
    # γ = 0.1
    # ω0 = 1/35740.77457414522 * u"Hz"
    # G_dc=0.0001
    # return 0.0001/sqrt((1-(f/fc)^2)^2 + (2*γ*(f/fc))^2)  # Frequency rolloff
    # return G_dc / sqrt((ω0^2 - f^2)^2 + (2γ*f*ω0)^2)
end

# Apply gain correction with uncertainty
gain = @. frequency_dependent_gain(
    df.δF, 
    fc,
    (1e3 ± 9)u"Ω",
    (200 ± 2)u"Ω"
)
df.Voltage = @. df.Voltage / gain^2
df = df[df.Voltage .<= 9e-12 * u"V^2", :]

frequency_fit = curve_fit(LinearFit, ustrip.(value.(df.δF)), ustrip.(value.(df.Voltage)))
df.Voltage = df.Voltage .- frequency_fit(0)u"V^2"

stat_σ_relative = stat_σ .* value.(df.Voltage)
df.Voltage = @. value(df.Voltage) ± sqrt(Measurements.uncertainty(df.Voltage)^2 + value.(stat_σ_relative)^2)

p = scatter(
    titlefont = font(12,"Computer Modern"),
    legendfont = font(8, "Computer Modern"),
    ustrip.(df.δF), 
    ustrip.(df.Voltage),
    title="Frequency-Dependent Johnson Noise",
    ms=3,
    size=(400, 250).*1.3,
    xlabel="Bandwidth (Hz)",
    ylabel=L"\mathrm{V^2}",
    label=L"\langle V_J^2 \rangle"
)

theoretical = johnson_noise_theoretical.(df.δF, df.Ri)
plot!(
    value.(ustrip.(df.δF)),
    value.(ustrip.(theoretical));
    ribbon=Measurements.uncertainty.(ustrip.(theoretical)),
    label="Theoretical Johnson Noise"
)

measured_vj2 = value.(df.Voltage)
theoretical_vj2 = value.(johnson_noise_theoretical.(df.δF, df.Ri))
uncertainties_measured = (uncertainty.(df.Voltage))
uncertainties_theory = uncertainty.(johnson_noise_theoretical.(df.δF, df.Ri))

z = (((df.Voltage .- theoretical_vj2)) ./ sqrt.(uncertainties_measured.^2 .+ uncertainties_theory.^2))
chi_squared = sum(z.^2)
ndf = length(measured_vj2) - 1  # Degrees of freedom
chi_squared_reduced = chi_squared / ndf  # Reduced chi-square
