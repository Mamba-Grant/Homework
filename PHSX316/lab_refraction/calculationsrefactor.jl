using Statistics
using NLsolve

const pitri_width = 8.75e-2
const Dtot = 87e-2
const D1 = 95.95e-2 - 68.25e-2 
const D2 = 68.25e-2 - 64e-2
const D3 = 64e-2 - 8.5e-2

# Extract data into arrays
fresh_y0 = [[-3.9, -4, -4], [-2.09, -1.95, -1.95], [-2.9, -2.94, -2.9]] .* 10^-2 
fresh_y1 = [[3.25, 3.30, 3.40], [0.91, 0.90, 0.89], [2.05, 1.9, 1.9]] .* 10^-2

creamer_y0 = [[-3.9, -3.95, -3.95], [-2.95, -2.89, -2.9], [-1.99, -1.98, -1.95]] .* 10^-2
creamer_y1 = [[2.85, 2.75, 2.8], [1.55, 1.5, 1.57], [1.21, 1.98, 1.99]] .* 10^-2

# Calculate means
fresh_mean_y0 = [mean(y0) for y0 in fresh_y0] 
fresh_mean_y1 = [mean(y1) for y1 in fresh_y1]

creamer_mean_y0 = [mean(y0) for y0 in creamer_y0]
creamer_mean_y1 = [mean(y1) for y1 in creamer_y1]

# Function to solve equations
function solve_equations(mean_y0, θ1)
   initial_guess = [1.0, 0.0, 0.0, 0.1, 0.1, 1.0]
   
   function equations!(F, x)
      n2, θ2, θ3, y2, y3 = x
   
      F[1] = cos(θ1) - n2 * sin(θ2)  
      F[2] = y2 - D2 * (sin(θ1) - sin(θ2))
      F[3] = n2 * cos(θ2) - sin(θ3)
      F[4] = y3 - D3 * (sin(θ2) - sin(θ3)) 
      F[5] = mean_y0 - (y2 + y3 + D1 * tan(θ1))
      F[6] = π - (θ1 + θ2 + θ3)
   end
   
   return nlsolve(equations!, initial_guess)
end

# Calculate θ1 and solve for each data set
θ1_fresh = [atan(mean_y0 / Dtot) for mean_y0 in fresh_mean_y0] 
results_fresh = [solve_equations(mean_y0, θ1) for (mean_y0, θ1) in zip(fresh_mean_y0, θ1_fresh)]

θ1_creamer = [atan(mean_y0 / Dtot) for mean_y0 in creamer_mean_y0]
results_creamer = [solve_equations(mean_y0, θ1) for (mean_y0, θ1) in zip(creamer_mean_y0, θ1_creamer)]

# Extract n2 values
r1 = mean([result.zero for result in results_fresh])  
r2 = mean([result.zero for result in results_creamer])
