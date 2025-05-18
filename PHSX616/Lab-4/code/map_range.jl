using CSV, DataFrames, Unitful, Plots

function clean_dataframe(filepath)
    df = CSV.read(filepath, DataFrame)
    return filter(:y_rel => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df)
end

df_low = clean_dataframe("../data/Config_A_Trace_low.csv")
df_med = clean_dataframe("../data/Config_A_Trace_med_transformed.csv")
df_high = clean_dataframe("../data/Config_A_Trace_high_transformed.csv")

# X-axis was swept from 100-10k Hz, and vertical axis is left relative.
df_low.x_abs .= (((10_000-99)/maximum(df_low.x_rel.-1) .* (df_low.x_rel.-1)) .+ 99)
df_low.res .= "low"
df_med.x_abs .= (((10_000-99)/maximum(df_low.x_rel.-1) .* (df_med.x_rel.-1)) .+ 99)
df_med.res .= "med"
df_high.x_abs .= (((10_000-99)/maximum(df_low.x_rel.-1) .* (df_high.x_rel.-1)) .+ 99)
df_high.res .= "high"

p = plot(title="Transformed", yaxis=:log)
plot!(p, df_low.x_abs, df_low.y_rel)
plot!(p, df_med.x_abs, df_med.y_rel)
plot!(p, df_high.x_abs, df_high.y_rel)

df = vcat(df_low, df_med, df_high)
CSV.write("../data/Config_A_final.csv", df)

p
