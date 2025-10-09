using CSV
using Plots
using DataFrames
using Dates

df = CSV.read("./MER_T01_02.csv", DataFrame, types=Dict(:Value => Float64))

# Remove or replace missing values
df = dropmissing(df, :Value)
# Ensure Value is numeric
df.Value = Float64.(df.Value)
df.YYYYMM = Int.(df.YYYYMM)
df = df[df.YYYYMM.>=202000, :]
df = df[mod.(df.YYYYMM, 100).==13, :]
filter!(row -> row.Description in ["Total Renewable Energy Production",
        "Total Primary Energy Production"], df)
df_wide = unstack(df, :YYYYMM, :Description, :Value, fill=0.0, combine=first)

# Convert YYYYMM to years (month 13 = annual data)
# Extract just the year part since 13 represents annual totals
years = div.(df_wide.YYYYMM, 100)

value_cols = select(df_wide, Not(:YYYYMM)) |> Matrix
value_cols = coalesce.(value_cols, 0.0)

# Simple color array - will cycle through these colors for each column
colors = ["#FFF783", "#40C1B8", "#8EF6AF", "#6E9BDE", "#76DEFF", "#00CED1",
    "#20B2AA", "#48D1CC", "#5F9EA0", "#4682B4", "#1E90FF", "#00BFFF"]

p1 = areaplot(years, value_cols,
    labels=permutedims(names(select(df_wide, Not(:YYYYMM)))),
    xlabel="Year",
    ylabel="Production (Quadrillion BTU)",
    color=reshape(colors[1:size(value_cols, 2)], 1, :),
    xticks=years,  # Show all years as tick marks
    xrotation=45,
    legend=:outertopright,
    size=(1000, 600),  # Larger plot for better readability
    title="",
    legendfontsize=14,
    tickfontsize=14,
    guidefontsize=14)

# Calculate relative growth from 2020 baseline
baseline_values = value_cols[1, :]  # First row is 2020
growth_cols = similar(value_cols)
for i in 1:size(value_cols, 1)
    for j in 1:size(value_cols, 2)
        if baseline_values[j] != 0
            growth_cols[i, j] = ((value_cols[i, j] - baseline_values[j]) / baseline_values[j]) * 100
        else
            growth_cols[i, j] = 0.0
        end
    end
end

p2 = plot(years, growth_cols,
    labels=permutedims(names(select(df_wide, Not(:YYYYMM)))),
    xlabel="Year",
    ylabel="Growth from 2020 (%)",
    color=reshape(colors[1:size(value_cols, 2)], 1, :),
    xticks=years,
    xrotation=45,
    title="",
    legendfontsize=14,
    legend=:outertopright,
    # aspect_ratio=1e-1,
    size=(1200, 200),
    linewidth=2,
    tickfontsize=14,
    guidefontsize=14,
    ylimits=(0, :auto),
    lw=5)

final_plot = plot(p1, p2,
    layout=grid(2, 1, heights=[0.8, 0.2]),  # p1 tall, p2 short
    size=(1000, 800),
    left_margin=8Plots.mm,
    bottom_margin=6Plots.mm)


# Save as transparent SVG
savefig(final_plot, "energy_plot.png")
