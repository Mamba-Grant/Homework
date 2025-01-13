using CSV
using DataFrames 
using PlotlyJS
using SpecialFunctions: gamma           # Contains an implementation of the Gamma Function 
using NumericalIntegration: integrate   # Integration Library

const G_earth = 6.67430e-11
const mass_earth = 5.97219e24
const radius_earth = 6378e3
g(h) = G_earth*(mass_earth/((radius_earth+h)^2))
# χ² distribution (x, degrees of freedom)
c(x, n) = (x^(n/2-1)*ℯ^(-x/2))/(2^(n/2) *gamma(n/2))

df_1 = DataFrame(CSV.File("experiment1.csv"))
df_2 = DataFrame(CSV.File("experiment2.csv"))

χ²_1 = sum((df_1.g.-9.8).^2 ./ df_1.dg.^2)
χ²_2 = sum((df_2.g.-9.8 ).^2 ./ df_2.dg)
χ²_3 = 0.0
for (i,e) in enumerate(df_2.Height)
    global χ²_3 += ((df_2.g[i]-g(e))^2 / df_2.dg[i])
end

# PRINTING THINGS
x1 = collect(0:0.001:χ²_1)
x2 = collect(0:0.001:χ²_2)
x3 = collect(0:0.001:χ²_3)

probability1 = 1-integrate(x1, c.(x1, 19))
probability2 = 1-integrate(x2, c.(x2, 29))
probability3 = 1-integrate(x3, c.(x3, 29))

println("   RESULTS           (Chi-Square, p-value)")
println("χ² Constant (Set 1): (", χ²_1, ", ", probability1*100, "%)")
println("χ² Constant (Set 2): (", χ²_2, ", ", probability2*100, "%)")
println("χ² Newton's (Set 2): (", χ²_3, ", ", probability3*100, "%)")

# PLOTTING THINGS
d1 =  [
    scatter(x=[0,1900], y=[9.8,9.8], mode="lines", name="Prediction (Constant)")
    
    scatter(df_1, x=:Height, y=:g,
    mode="markers", 
    name="Data (Set 1)", 
    error_y=attr(
        type="percent",
        value=0.05
    ))]

d2 = [
    scatter(x=[0,14500], y=[9.8,9.8], mode="lines", name="Prediction (Constant)", showlegend=false)
    
    scatter(df_2, x=:Height, y=:g, 
    mode="markers", 
    name="Data (Set 2)", 
    error_y=attr(
        type="percent",
        value=0.01
    ))]

d3 = [
    scatter(x=[0,14500], y=[g(0),g(14500)], mode="lines", name="Prediction (Newton's)")
    
    scatter(df_2, x=:Height, y=:g, 
    mode="markers", 
    name="Data (Set 2)", 
    showlegend=false, 
    legendgroup="group2", 
    error_y=attr(
        type="percent",
        value=0.01
    ))]

layout1 = Layout(title="H₀ (Set 1)", yaxis_range=[9.7, 9.90])
layout2 = Layout(title="H₀ (Set 2)", yaxis_range=[9.7, 9.90])
layout3 = Layout(title="H₁ (Set 2)", yaxis_range=[9.7, 9.90])
chsq_layout_set1 = Layout(title="χ² (n=19)", yaxis_range=[0, 0.08])
chsq_layout_set2 = Layout(title="χ² (n=29)", yaxis_range=[0, 0.08])

p1 = plot(d1, layout1)
p2 = plot()
c1 = plot(c.(0:0.1:65, 19), chsq_layout_set1)
p3 = plot(d2, layout2)
p4 = plot(d3, layout3)
c2 = plot(c.(0:0.1:65, 29), chsq_layout_set2)

p = [p1 p2 c1; p3 p4 c2]
relayout!(p, height=1300, width=4000, title_text="")
display(p)
println("Done!  saved file to:")
savefig(p, "Plots.png")