using DataFrames
using CSV
using Statistics

function remove_outliers(df, cols)
    filtered_df = df  # Create a copy of df
    for col in cols
        μ = mean(filtered_df[!, col])  # Compute mean
        σ = std(filtered_df[!, col])   # Compute standard deviation
        filtered_df = filter(row -> abs(row[col] - μ) ≤ σ*1.1, filtered_df)  # Keep rows within 1 std dev
    end
    return filtered_df
end

# Load data from CSV files into a vector of DataFrames, kill outliers 
data::Vector{DataFrame} = DataFrame.(CSV.File.(readdir("raw_data/", join=true)))
data::Vector{DataFrame} = [remove_outliers(df, [:neutral_fall_seconds, :charged_rise_seconds]) for df in data]

# The bulk of the analysis, doing the charge computation for each dataframe
charges::Vector{Float64} = map(data) do df
    vf = 0.5e-3 / mean(df.neutral_fall_seconds)
    vr = 0.5e-3 / mean(df.charged_rise_seconds)
    
    a = @. sqrt((df.b / (2df.p))^2 + (9 * df.eta * vf) / (2 * df.g * df.rho)) - df.b / (2df.p)
    m = (4/3) * π * mean(a)^3 * mean(df.rho)
    q = m * mean(df.g) * (vf + vr) / (mean(df.voltage_V ./ df.d) * vf)
    
    q
end

normalized_charge::Vector{Float64} = charges ./ minimum(charges)

# Display the analysis stuff
tmp::DataFrame = DataFrame(zip(charges, normalized_charge, std.(getproperty.(data, :neutral_fall_seconds)), std.(getproperty.(data, :charged_rise_seconds)) ))
colnames::Vector{String} = ["charge (coulomb)", "# charges on oil drop", "std(fall time)", "std(rise time)"]
rename!(tmp, Symbol.(colnames))
println(tmp)
