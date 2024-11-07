using Statistics
using NLsolve

const pitri_width = 8.75e-2
const Dtot = 87e-2
const D1 = 95.95e-2 - 68.25e-2
const D2 = 68.25e-2 - 64e-2
const D3 = 64e-2 - 8.5e-2

mean_y₀_fresh1 = mean([-3.9, -4, -4] .* 10^-2)
mean_y₁_fresh1 = mean([3.25, 3.30, 3.40] .* 10^-2)

mean_y₀_fresh2 = mean([-2.09, -1.95, -1.95] .* 10^-2)
mean_y₁_fresh2 = mean([0.91, 0.90, 0.89] .* 10^-2)

mean_y₀_fresh3 = mean([-2.9, -2.94, -2.9] .* 10^-2)
mean_y₁_fresh3 = mean([2.05, 1.9, 1.9] .* 10^-2)

mean_y₀_creamer1 = mean([-3.9, -3.95, -3.95] .* 10^-2)
mean_y₁_creamer1 = mean([2.85, 2.75, 2.8] .* 10^-2)

mean_y₀_creamer2 = mean([-2.95, -2.89, -2.9] .* 10^-2)
mean_y₁_creamer2 = mean([1.55, 1.5, 1.57] .* 10^-2)

mean_y₀_creamer3 = mean([-1.99, -1.98, -1.95] .* 10^-2)
mean_y₁_creamer3 = mean([1.21, 1.98, 1.99] .* 10^-2)

θ₁_fresh1 = atan(mean_y₀_fresh1 / Dtot)
y₁_fresh1 = D1 * tan(θ₁_fresh1)
θ₁_fresh2 = atan(mean_y₀_fresh2 / Dtot)
y₁_fresh2 = D1 * tan(θ₁_fresh2)
θ₁_fresh3 = atan(mean_y₀_fresh3 / Dtot)
y₁_fresh3 = D1 * tan(θ₁_fresh3)
initial_guess = [1.0, 0.0, 0.0, 0.1, 0.1, 1.0]

function equations!(F, x)
   n₂, θ₂, θ₃, y₂, y₃ = x

   # Losing my mind over the sign of my angles
   F[1] = cos(θ₁_fresh1) - n₂ * sin(θ₂)
   F[2] = y₂ - D2 * (sin(θ₁_fresh1) - sin(θ₂))
   F[3] = n₂ * cos(θ₂) - sin(θ₃)
   F[4] = y₃ - D3 * (sin(θ₂) - sin(θ₃))
   F[5] = mean_y₀_fresh1 - (y₂ + y₃ + D1 * tan(θ₁_fresh1))
   F[6] = π - (θ₁_fresh1 + θ₂ + θ₃)
end

result_fresh1 = nlsolve(equations!, initial_guess)
result_fresh1.zero

# ORIGINAL
# function equations!(F, x)
#    n₂, θ₂, θ₃, y₂, y₃ = x
#
#    F[1] = sin(θ₁_fresh₁) - n₂ * sin(θ₂)
#    F[2] = y₂ - D2 * (sin(θ₁_fresh₁) - sin(θ₂))
#    F[3] = n₂ * sin(θ₂) - sin(θ₃)
#    F[4] = y₃ - 0.555 * (sin(θ₂) - sin(θ₃))
#    F[5] = 0.332 - (y₂ + y₃ + 0.0126)
#    F[6] = θ₂ - π + 0.0456 + θ₃
# end


function equations!(F, x)
   n₂, θ₂, θ₃, y₂, y₃ = x

   # Losing my mind over the sign of my angles
   F[1] = cos(θ₁_fresh2) - n₂ * sin(θ₂)
   F[2] = y₂ - D2 * (sin(θ₁_fresh2) - sin(θ₂))
   F[3] = n₂ * cos(θ₂) - sin(θ₃)
   F[4] = y₃ - D3 * (sin(θ₂) - sin(θ₃))
   F[5] = mean_y₀_fresh2 - (y₂ + y₃ + D1 * tan(θ₁_fresh2))
   F[6] = π - (θ₁_fresh2 + θ₂ + θ₃)
end

result_fresh2 = nlsolve(equations!, initial_guess)
result_fresh2.zero

function equations!(F, x)
   n₂, θ₂, θ₃, y₂, y₃ = x

   # Losing my mind over the sign of my angles
   F[1] = cos(θ₁_fresh3) - n₂ * sin(θ₂)
   F[2] = y₂ - D2 * (sin(θ₁_fresh3) - sin(θ₂))
   F[3] = n₂ * cos(θ₂) - sin(θ₃)
   F[4] = y₃ - D3 * (sin(θ₂) - sin(θ₃))
   F[5] = mean_y₀_fresh3 - (y₂ + y₃ + D1 * tan(θ₁_fresh3))
   F[6] = π - (θ₁_fresh3 + θ₂ + θ₃)
end

result_fresh3 = nlsolve(equations!, initial_guess)
result_fresh3.zero

# ======== CREAMER =========

θ₁_creamer1 = atan(mean_y₀_creamer1 / Dtot)
y₁_creamer1 = D1 * tan(θ₁_creamer1)
θ₁_creamer2 = atan(mean_y₀_creamer2 / Dtot)
y₁_creamer2 = D1 * tan(θ₁_creamer2)
θ₁_creamer3 = atan(mean_y₀_creamer3 / Dtot)
y₁_creamer3 = D1 * tan(θ₁_creamer3)
initial_guess = [1.0, 0.0, 0.0, 0.1, 0.1, 1.0]

function equations!(F, x)
   n₂, θ₂, θ₃, y₂, y₃ = x

   # Losing my mind over the sign of my angles
   F[1] = cos(θ₁_creamer1) - n₂ * sin(θ₂)
   F[2] = y₂ - D2 * (sin(θ₁_creamer1) - sin(θ₂))
   F[3] = n₂ * cos(θ₂) - sin(θ₃)
   F[4] = y₃ - D3 * (sin(θ₂) - sin(θ₃))
   F[5] = mean_y₀_creamer1 - (y₂ + y₃ + D1 * tan(θ₁_creamer1))
   F[6] = π - (θ₁_creamer1 + θ₂ + θ₃)
end

result_creamer1 = nlsolve(equations!, initial_guess)
result_creamer1.zero

function equations!(F, x)
   n₂, θ₂, θ₃, y₂, y₃ = x

   # Losing my mind over the sign of my angles
   F[1] = cos(θ₁_creamer2) - n₂ * sin(θ₂)
   F[2] = y₂ - D2 * (sin(θ₁_creamer2) - sin(θ₂))
   F[3] = n₂ * cos(θ₂) - sin(θ₃)
   F[4] = y₃ - D3 * (sin(θ₂) - sin(θ₃))
   F[5] = mean_y₀_creamer2 - (y₂ + y₃ + D2 * tan(θ₁_creamer2))
   F[6] = π - (θ₁_creamer2 + θ₂ + θ₃)
end

result_creamer2 = nlsolve(equations!, initial_guess)
result_creamer2.zero

function equations!(F, x)
   n₂, θ₂, θ₃, y₂, y₃ = x

   # Losing my mind over the sign of my angles
   F[1] = cos(θ₁_creamer3) - n₂ * sin(θ₂)
   F[2] = y₂ - D2 * (sin(θ₁_creamer3) - sin(θ₂))
   F[3] = n₂ * cos(θ₂) - sin(θ₃)
   F[4] = y₃ - D3 * (sin(θ₂) - sin(θ₃))
   F[5] = mean_y₀_creamer3 - (y₂ + y₃ + D3 * tan(θ₁_creamer3))
   F[6] = π - (θ₁_creamer3 + θ₂ + θ₃)
end

result_creamer3 = nlsolve(equations!, initial_guess)
result_creamer3.zero

# mean IOR of Mallott water
r1 = mean([result_fresh1.zero[1], result_fresh2.zero[1], result_fresh3.zero[1]])

# mean IOR of Mallott water
r2 = mean([result_creamer1.zero[1], result_creamer2.zero[1], result_creamer3.zero[1]])
