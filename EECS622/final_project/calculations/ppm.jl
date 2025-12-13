using Plots, Unitful, LaTeXStrings
theme(:default)

x = 1570u"MHz":1u"MHz":1870u"MHz"
p = plot(x,
    10^6 .* (1u"MHz" ./ x),
    label=L"10^6 \left( \frac{\mathrm{\pm 1~MHz}}{\mathrm{f_0^{LO}(MHz)}} \right)",
    palette=palette(:tol_muted),
    size=(1000, 400),
    bottom_margin=5Plots.mm,
    top_margin=5Plots.mm,
    left_margin=5Plots.mm,
    background_color=:transparent,
    plot_background_color=:transparent,
    legend=:outerright
)

hline!([maximum(10^6 .* (1u"MHz" ./ x))], c=:gray, ls=:dash, label="$(round(maximum(10^6 .* (1u"MHz" ./ x)), sigdigits=5)) ppm")

xlabel!("LO Oscillator Frequency")
ylabel!("Accuracy (ppm)")
title!("LO Oscillator Accuracy")

