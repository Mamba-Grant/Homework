using Statistics
using NLsolve
using Measurements

pitri_width = measurement(8.75e-2, 0.05)
Dtot = measurement(87e-2, 0.05)
D1 = measurement(95.95e-2 - 68.25e-2, 0.05) 
D2 = measurement(68.25e-2 - 64e-2, 0.05)
D3 = measurement(64e-2 - 8.5e-2, 0.05)

fresh_y0 = vec.(eachrow(reshape(measurement.([-3.9, -4, -4, -2.09, -1.95, -1.95, -2.9, -2.94, -2.9], 0.05), 3, :)'))
fresh_y1 = vec.(eachrow(reshape(measurement.([3.25, 3.30, 3.40, 0.91, 0.90, 0.89, 2.05, 1.9, 1.9], 0.05), 3, :)'))

# Function to solve equations
# function solve_equations(mean_y0, θ1)
#    initial_guess = [1.0, 0.0, 0.0, 0.1, 0.1, 1.0]
#    
#    function equations!(F, x)
#       n2, θ2, θ3, y2, y3 = x
#    
#       F[1] = cos(θ1) - n2 * sin(θ2)  
#       F[2] = y2 - D2 * (sin(θ1) - sin(θ2))
#       F[3] = n2 * cos(θ2) - sin(θ3)
#       F[4] = y3 - D3 * (sin(θ2) - sin(θ3)) 
#       F[5] = mean_y0 - (y2 + y3 + D1 * tan(θ1))
#       F[6] = π - (θ1 + θ2 + θ3)
#    end
#    
#    return nlsolve(equations!, initial_guess)
# end

function solve_equations(a, b)
    x0 = [0.0, 0.0]

    function equations!(F, x)
        # n₂, θ₂, θ₃, y₂, y₃ = x
        n₂, θ₂ = x

        F[1] = n₂ + 2*θ₂ - 5
        F[2] = 3*n₂ - θ₂ - 7
    end

    return nlsolve(equations!, x0)
end

fresh_mean_y0 = [mean(y0) for y0 in fresh_y0] 
fresh_mean_y1 = [mean(y1) for y1 in fresh_y1]

θ1_fresh = [atan(mean_y0 / Dtot) for mean_y0 in fresh_mean_y0] 

solve_equations(fresh_mean_y0[1], θ1_fresh[1])

# results_fresh = [solve_equations(mean_y0, θ1) for (mean_y0, θ1) in zip(fresh_mean_y0, θ1_fresh)]
