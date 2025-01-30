using DataFrames, PlotlyJS, LaTeXStrings, IMinuit, CSV

# df = ods_read("~/home/mamba/Documents/repos/PHSX315/assignment5-Mamba-Grant/rsc/Table1.ods", sheetName="Sheet1", retType="DataFrame")
df = DataFrame(CSV.File("../rsc/Table1.csv"))

# Define functions for the PDF and Likelihood 
λ(N) = @. df.μ_bkg + df.μ_W + N * df.μ_SM
pdf(N) = (big.(λ(N)).^df.n_obs .* exp.(-big.(λ(N)))) ./ factorial.(big.(df.n_obs))
likelihood(N) = -2sum(log.(pdf(N)))

# Find maximum likelihood estimate and errors
m = Minuit(likelihood, N=3)
migrad(m)
hesse(m)
m_values, m_errors = convert.(Vector{Float64}, (m.values, m.errors))

# Create plot data
x_values = 0:0.01:12
y_values = likelihood.(x_values)

scatter_data = [
    scatter(
        x = x_values,
        y = y_values,
        mode = "lines",
        line = attr(width = 2, color = "#636efa"),
        name = "Likelihood"
    ),
    scatter(
        x = [m_values[1]],
        y = [likelihood(m_values[1])],
        mode = "markers",
        marker = attr(symbol = "star", size = 12, color = "red"),
        name = "MLE: $(round(m_values[1], sigdigits=5)) ± $(round(m_errors[1], sigdigits=5))"
    )
]

# Create plot layout
layout = Layout(
    title = "Likelihood Function for Model Parameter",
    xaxis = attr(title = L"N_{\nu}", tickformat = ".1f", gridcolor = "lightgray"),
    yaxis = attr(title = L"-2\ln(\text{Likelihood})", tickformat = ".1f", gridcolor = "lightgray"),
    showlegend = true,
    legend = attr(x = 0, y = 1, font = attr(size = 12)),
    plot_bgcolor = "white",
    margin = attr(l=70,r=30,t=60,b=70),
    hovermode = "closest"
)

# Render plot
p=plot(scatter_data, layout)
savefig(p, "p3.html")
