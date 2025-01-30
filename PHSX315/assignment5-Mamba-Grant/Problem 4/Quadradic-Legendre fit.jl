using Distributions, IMinuit, PlotlyJS

# quad_model(x, p...) = @. p[1]*x^2 + p[2]*x + p[3]
# legendre_model(x, p...) = @. p[1]*x + p[2] + p[3]*(3*x^2 - 1)/2

quad_model(x, a, b, c) = @. a*x^2 + b*x .+ c
quad_model(x, p) = quad_model(x, p...)

legendre_model(x, a, b, c) = @. a + b*x + c*0.5*(3*x^2 - 1)
legendre_model(x, p) = legendre_model(x, p...)

const numpoints = 64
x_data = range(-1, 1, numpoints)
y_true = quad_model(x_data, 1, 2, 3)
yerr_data = 0.1 .+ 0.05.*x_data
ran = rand(Normal(), numpoints)
y_data = y_true.+yerr_data.*ran
data = Data(x_data, y_data, yerr_data)

m_quad = @model_fit quad_model data [1,2,3]
migrad(m_quad)
hesse(m_quad)

m_leg = @model_fit legendre_model data [1,2,3]
migrad(m_leg)
hesse(m_leg)

m_quad_values, m_quad_errors = convert.(Vector{Float64}, (m_quad.values, m_quad.errors))
m_leg_values, m_leg_errors = convert.(Vector{Float64}, (m_leg.values, m_leg.errors))

# Print correlation between values and errors
println("Value Correlation: ", cor(m_quad_values, m_leg_values))
println("Error Correlation: ", cor(m_quad_errors, m_leg_errors))

fit(x, model, values) = model(x, values)

layout = Layout(    
    title="Quadratic-Legendre Fit",
    xaxis=attr(title="x", tickformat=".1f", gridcolor="lightgray"),
    yaxis=attr(title="y", tickformat=".1f", gridcolor="lightgray"),
    showlegend=true,
    legend=attr(x=0, y=1, font=attr(size=12)),
    plot_bgcolor="white",
    margin=attr(l=70, r=30, t=60, b=70),
    hovermode="closest"
)

d = [
    scatter(
        x=x_data, 
        y=y_data, 
        mode="markers",
        name="Randomly Generated Data",
        error_y=attr(type="data", array=yerr_data, visible=true),
        line=attr(color="#59A5D8")
    ),
    scatter(
        x=-1:0.05:1, 
        y=fit(-1:0.05:1, quad_model, m_quad_values), 
        name="Quadratic Model: $(join(["$(round(m_quad_values[i], sigdigits=3))±$(round(m_quad_errors[i], sigdigits=3))" for i in 1:3], ", "))",
        line=attr(color="#91E5F6")
    ),
    scatter(
        x=-1:0.05:1, 
        y=fit(-1:0.05:1, legendre_model, m_leg_values),
        name="Legendre Model: $(join(["$(round(m_leg_values[i], sigdigits=3))±$(round(m_leg_errors[i], sigdigits=3))" for i in 1:3], ", "))",
        line=attr(dash="dash", color="#FF1053"),
        )
]

p = plot(d, layout)
display(p)
savefig(p, "p4.png")