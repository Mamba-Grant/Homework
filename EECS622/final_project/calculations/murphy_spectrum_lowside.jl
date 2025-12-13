
using Unitful, Plots, Statistics, Latexify, PlotThemes
theme(:wong2)

# --- Define constants ---
RFL = 1250u"MHz"
RFR = 1550u"MHz"
IF = 250u"MHz"

# --- LO functions ---
LO(if_val) = [RFL, RFR] .- if_val
LO_center(if_val) = mean([RFL, RFR]) .- if_val

# --- Define frequency signals ---
signals(if_val) = [
    LO(if_val) .- if_val,
    LO(if_val) .+ if_val,
    abs.(LO(if_val) .- if_val),
    if_val,
    if_val / 2,
    if_val / 3,
    abs.(LO(if_val) .- if_val) ./ 2,
    (LO(if_val) .+ if_val) ./ 2,
    abs.(2 .* LO(if_val) .- if_val),
    2 .* LO(if_val) .+ if_val
]

names = (
    :IF_minus_LO, :LO_plus_IF, :LO_minus_IF,
    :IF, :IF_over_2, :IF_over_3_f3a,
    :half_LO_plus_IF_f3b, :half_abs_IF_minus_LO_f3c,
    :two_LO_plus_IF_f3d, :abs_two_LO_minus_IF_f3e
)

# --- Alpha function ---
function α(vec)::Union{AbstractVector,AbstractFloat}
    f = vec
    f0 = sqrt(RFL * RFR)
    Δpct = (RFR - RFL) / f0
    α_func = x -> abs((x / f0 - f0 / x) / Δpct) - 1
    return round.(α_func.(f); sigdigits=4)
end

# --- Generate Murphy spectrum and normalized alpha ---
murphy_spectrum = NamedTuple{names}(
    uconvert.(u"MHz", s) for s in signals(IF)
)

normalized_alpha = NamedTuple{names}(
    α(s) for s in signals(IF)
)

# --- Print results ---
println(rpad("\nRF Bandwidth:", 25), ustrip.([RFL, RFR]))
println("="^50)
println(rpad("\nLO Bandwidth:", 25), ustrip.(LO(IF)))
println("="^50)

println("\nFrequency Signals (MHz):")
println("="^50)
for (name, value) in pairs(murphy_spectrum)
    println(rpad(string(name), 25), " = ", ustrip.(value))
end

println("\nNormalized Frequency Signals (α):")
println("="^50)
for (name, value) in pairs(normalized_alpha)
    println(rpad(string(name), 25), " = ", value)
end

# --- Plot alpha vs IF and Murphy frequency ---
x = 0u"MHz":1u"MHz":800u"MHz"  # entire possible IF range

# Image bandwidth and Murphy frequency centers
image_lowside_center(if_val) = LO_center(if_val) .- if_val

f1a(if_val) = if_val
f2a(if_val) = if_val ./ 2
f3a(if_val) = if_val ./ 3
f3b(if_val) = abs.(LO_center(if_val) .- if_val) ./ 2  # Was: (LO_center(if_val) .+ if_val) ./ 2
f3c(if_val) = (LO_center(if_val) .+ if_val) ./ 2      # Was: abs.(LO_center(if_val) .- if_val) ./ 2
f3d(if_val) = abs.(2 .* LO_center(if_val) .- if_val)  # Was: (2 .* LO_center(if_val) .+ if_val)
f3e(if_val) = 2 .* LO_center(if_val) .+ if_val        # Was: abs.(LO_center(if_val) .+ 2 .* if_val)


p = plot(
    uconvert.(u"MHz", x),
    α(uconvert.(u"MHz", image_lowside_center.(x))),
    label=latexify("LO - IF"),
    ylims=[0, 16],
    palette=palette(:tol_muted),
    size=(800, 400),
    bottom_margin=2Plots.mm,
    top_margin=5Plots.mm,
    left_margin=5Plots.mm,
    background_color=:transparent,
    plot_background_color=:transparent,
    legend=:outerright
    # yaxis=:log
)
for (f, expr) in zip([f1a, f2a, f3a, f3b, f3c, f3d, f3e], ["IF", "IF/2", "IF/3", "(LO + IF)/2", "abs(LO - IF)/2", "2LO+IF", "abs(LO + 2*IF)"])
    plot!(
        uconvert.(u"MHz", x),
        α(uconvert.(u"MHz", f.(x))),
        label=latexify(expr),
    )
end
vline!([IF], c=:gray, style=:dash, label="$IF")
hline!([1], c=:gray, style=:dash, label="α=1")

xlabel!("IF")
ylabel!("Normalized Frequency (α)")
title!("Image vs Murphy Frequency Bandwidth")


# --- Back-conversion functions

f_plus(α, fH, fL, f0) = (f0 / 2) * (((fH - fL) / f0) * (α + 1) +
                                    sqrt(((fH - fL) / f0)^2 * (α + 1)^2 + 4))

f_minus(α, fH, fL, f0) = (f0 / 2) * (((fH - fL) / f0) * (α + 1) -
                                     sqrt(((fH - fL) / f0)^2 * (α + 1)^2 + 4))
