using CSV
using DataFrames 
using PlotlyJS
using IMinuit


df1 = DataFrame(CSV.File("../rsc/LowPrecisionPeriodData.csv"))
df2 = DataFrame(CSV.File("../rsc/HighPrecisionPeriodData.csv"))
data1 = Data(df1.theta, df1.T, df1.dT)
data2 = Data(df2.theta, df2.T, df2.dT)


legendre_quad_model(x, a, b, c) = @. a + b*x + c*0.5*(3*x^2 - 1)
legendre_quad_model(x, p) = legendre_quad_model(x, p...)

physical_model(θ, L, b) = @. 2*π*sqrt(L/9.8) * (1 + (1/16)*θ^2 + (11/3072)*θ^4) + 0*b
physical_model(x, p) = physical_model(x, p...)


# IMinuit wrapper has a macro for model_fit which automatically does χ² fitting
m1_physical = @model_fit physical_model data1 [1,0]
migrad(m1_physical)
hesse(m1_physical)

m2_physical = @model_fit physical_model data2 [1,0]
migrad(m2_physical)
hesse(m2_physical)

m1_physical_values, m1_physical_errors = convert.(Vector{Float64}, (m1_physical.values, m1_physical.errors))
m2_physical_values, m2_physical_errors = convert.(Vector{Float64}, (m2_physical.values, m2_physical.errors))


m1_quad = @model_fit legendre_quad_model data1 [1,0,1]
migrad(m1_quad)
hesse(m1_quad)

m2_quad = @model_fit legendre_quad_model data2 [1,0,1]
migrad(m2_quad)
hesse(m2_quad)

m1_quad_values, m1_quad_errors = convert.(Vector{Float64}, (m2_quad.values, m2_quad.errors))
m2_quad_values, m2_quad_errors = convert.(Vector{Float64}, (m2_quad.values, m2_quad.errors))

# function c_value(model(x_data, values), y_data, yerror)
#     z = @. (y_data - model(x_data, values))/yerror
#     return sum(z.^2)
# end 

ym = physical_model(df2.theta, m2_physical_values)
z = @. (df2.T - ym)/df1.dT
c = sum(z.^2)


# PLOTTING
fit(x, model, values) = model(x, values)

# Add empty traces for legend entries
empty_trace_1 = scatter(
    x=[0], y=[0], mode="markers",
    name="Low-Precision Parameter (L): $(round(m1_physical_values[1], sigdigits=5)) ± $(round(m1_physical_errors[1], sigdigits=5))",
    visible="legendonly",
    line=attr(color="#000000")
)
empty_trace_2 = scatter(
    x=[0], y=[0], mode="markers",
    name="High-Precision Parameter (L): $(round(m2_physical_values[1], sigdigits=5)) ± $(round(m2_physical_errors[1], sigdigits=5))",
    visible="legendonly",
    line=attr(color="#000000")
)

d1 = [
    scatter(df1, x=:theta, y=:T,
    showlegend=false,
    mode="markers", 
    name="Theta [rad] vs T [s] (Low Precision)",
    error_y=attr(type="data", array=:dT, visible=true),
    line=attr(color="#EFCA08")
    ),
    scatter(
        showlegend=false,
        x=0.05:0.01:1.1, 
        y=fit(0.05:0.01:1.1, physical_model, m1_physical_values),
        name="Fit (Physical)",
        mode="lines",
        line=attr(color="#F08700")
    ),
    scatter(
        showlegend=false,
        x=0.05:0.01:1.1, 
        y=fit(0.05:0.01:1.1, legendre_quad_model, m1_quad_values),
        name="Fit (Quad)",
        mode="lines",
        line=attr(dash="dash", color="#00A6A6"),
        )]

d2 = [
    scatter(df2, x=:theta, y=:T,
    showlegend=false,
    mode="markers",
    name="Theta [rad] vs T [s] (High Precision)",
    error_y=attr(type="data", array=:dT, visible=true),
    line=attr(color="#EFCA08")
    ),
    scatter(
        x=0.05:0.01:1.1, 
        y=fit(0.05:0.01:1.1, physical_model, m2_physical_values),
        name="Fit (Physical)",
        mode="lines",
        line=attr(color="#F08700")
    ),
    scatter(
        x=0.05:0.01:1.1, 
        y=fit(0.05:0.01:1.1, legendre_quad_model, m2_quad_values),
        name="Fit (Quad)",
        mode="lines",
        line=attr(dash="dash", color="#00A6A6"),
    ),
    empty_trace_1, empty_trace_2]

layout(title, xaxis, yaxis) = Layout(    
    title=title,
    xaxis=attr(title=xaxis, tickformat=".02f", gridcolor="lightgray"),
    yaxis=attr(title=yaxis, tickformat=".02f", gridcolor="lightgray"),
    showlegend=true,
    legend=attr(x=0, y=1, font=attr(size=12)),
    margin=attr(l=70, r=30, t=60, b=70),
    hovermode="closest",
    yaxis_range=[2.6, 2.89]
)

p1 = plot(d1, layout("Low Precision (P. 1)", "Theta [rad]", "Period [s]"))
p2 = plot(d2, layout("High Precision (P. 2)", "Theta [rad]", ""))
p = [p1 p2]
display(p)

# savefig(p, "p2.png")
