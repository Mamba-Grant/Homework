using Unitful, Plots, Statistics, Latexify, PlotThemes

fH(fc) = fc .+ 1u"MHz"
fL(fc) = fc .- 1u"MHz"
f₀(fc) = sqrt(fH(fc) .* fL(fc))
spacing = 5u"MHz"
Δ(fc) = (f₀(fc) ./ (fH(fc) .- fL(fc)))

α(fc) = abs(Δ(fc) .* (((fc .+ spacing) ./ f₀(fc)) .- (f₀(fc) ./ (fc .+ spacing)))) .- 1

x = 170u"MHz":1u"MHz":470u"MHz"
p = plot(
    uconvert.(u"MHz", x),
    α.(x),
    label="",
    ylims=[3.90, 3.985],
    xlims=[170u"MHz", 470u"MHz"],
    palette=palette(:tol_muted),
    size=(800, 400),
    bottom_margin=2Plots.mm,
    top_margin=5Plots.mm,
    left_margin=5Plots.mm,
    background_color=:transparent,
    plot_background_color=:transparent,
    legend=:outerright
)

hline!([mean(α.(x))], c=:gray, style=:dash, label="α=$(round(mean(α.(x)), sigdigits=3))")
hline!([minimum(α.(x))], c=:red, style=:dash, label="α=$(round(minimum(α.(x)), sigdigits=3))")
hline!([maximum(α.(x))], c=:blue, style=:dash, label="α=$(round(maximum(α.(x)), sigdigits=3))")

xlabel!("IF Frequency")
ylabel!("Normalized Frequency (α)")
title!("Spacing Frequency (Relative) versus IF Frequency")
