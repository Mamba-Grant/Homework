using DataFrames, CSV, Plots

# Load data
noise_df = DataFrame(CSV.File("../data/amplifier_noise_data.csv"))

# Extract x (Rin) and y (V2) values
x = noise_df[!, "Rin (Ohm)"]
y = noise_df[!, "V2 (V)"]

# # Define the loss function (sum of squared errors)
# function loss(p)
#     y_pred = p[1] .+ p[2] .* x  # Linear model: y = p1 + p2 * x
#     return sum((y .- y_pred) .^ 2)  # Sum of squared errors
# end

# # Optimize the loss function
# result = optimize(loss, [0.0, 0.0])  # Initial guess [p1, p2]
#
# # Extract fitted parameters
# p_opt = Optim.minimizer(result)
# p1, p2 = p_opt  # Intercept and slope
#
# # Generate fitted line
# x_fit = range(minimum(x), maximum(x), length=100)
# y_fit = p1 .+ p2 .* x_fit

# Plot data and fitted line
p = scatter(x, y, label="Data", xlabel="Rin (Ohm)", ylabel="V2 (V)")
display(p)
# plot!(x_fit, y_fit, label="Optim Fit", lw=2, color=:red)
