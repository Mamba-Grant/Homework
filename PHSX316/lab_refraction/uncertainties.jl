using NLsolve
using Measurements

# Define the system of equations as a function
function equations!(F, x)
    F[0] = x[1] + 2x[2] - 5
    F[1] = 3x[1] - x[2] - 7
end

# Initial guess for the solution
x0 = [0.0, 0.0]

# Solve the nonlinear system
result = nlsolve(equations!, x0)

# Extract the solution
x = result.zero

# Create measurements for the solution variables
x_with_uncertainty = Measurements.uncertainty(x)

# Print the solution with uncertainties
println("x = $x_with_uncertainty")

