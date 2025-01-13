using Interpolations
using GLMakie

# SECTION DIFFEQ
TIMESTEP = 0.000005 
drag_coeff = 0.47
frontal_area = π * 0.053^2
# θ₀ = 40
v₀ = 150
x₀, y₀ = 0, 0
# vx₀, vy₀ = v₀ * cos(deg2rad(θ₀)), v₀ * sin(deg2rad(θ₀))
mass = 5
g = 9.8

air_density(h) = 1.204*exp(-h / 10400)
# air_density(h) = 1.204*exp((-h*0)+1 / 10400)
drag_const(h) = 0.5*air_density(h)*frontal_area*drag_coeff

Fx(v, θ, h) = ( -drag_const(h) * v^2 * cos(deg2rad(θ)) ) / mass
Fy(v, θ, h) = ( -(mass * g) - (drag_const(h) * v^2) * sin(deg2rad(θ)) ) / mass

function RK2_state(time_range, initial_theta)
  t::Float16=step(time_range)
  θ::Float64=initial_theta
  vx::Float64=v₀ * cos(deg2rad(initial_theta))
  vy::Float64=v₀ * sin(deg2rad(initial_theta))
  x::Float64=x₀
  y::Float64=y₀

  result = [(vx, vy, x, y, θ, 0.0)]
  for timestep in time_range
    a = vx + t * Fx(vx, θ, x)
    b = vy + t * Fy(vy, θ, y)
    c = rad2deg(atan(b/a))
    vx += t/2 * (Fx(vx, θ, x) + Fx(a, c, x))
    vy += t/2 * (Fy(vy, θ, y) + Fy(b, c, y))

    c = t * vx
    d = t * vy
    x += t/2 * (vx + c)
    y += t/2 * (vy + d)

    θ = rad2deg(atan(vy/vx))

    push!(result, (vx, vy, x, y, θ, timestep+t))
  end
  return(result)
end


time_range = 0:TIMESTEP:25
RK2_state_vectors = RK2_state(time_range, 45)

x_velocities::Vector{Float64} = map(i -> i[1], RK2_state_vectors)
y_velocities::Vector{Float64} = map(i -> i[2], RK2_state_vectors)
x_positions::Vector{Float64} = map(i -> i[3], RK2_state_vectors)
y_positions::Vector{Float64} = map(i -> i[4], RK2_state_vectors)
time::Vector{Float64} = map(i -> i[6], RK2_state_vectors)

# SECTION FINDING ZEROES (currently using bisection)
SAMPLESIZE = 0.1
SAMPLES = 10
SAMPLERANGE = 1:SAMPLESIZE:length(time)

itp_method = BSpline(Quadratic(Reflect(OnCell())))

# perhaps the weirdest method call syntax, keeping here so I don't forget lmfao
# interpolate(time, itp_method)(SAMPLERANGE)

# since this is a smooth continuous function win change should represent a zero
# nearest_zero_indices(data) = ([[i,i+1] for i in 1:length(data)-1 if sign(data[i]) != sign(data[i+1])])
function nearest_zero_indices(data)
  indices = []
  for i in 1:length(data)-1
    if sign(data[i]) != sign(data[i+1])
      append!(indices, [i, i+1])
    end
  end
  return [indices[end]-1, indices[end]]
end
# filter_indices(data)::Vector{Int64} = [last(nearest_zero_indices(data))[1], last(nearest_zero_indices(data))[2]]
indicies_self_range(data) = range(data[nearest_zero_indices(data)[1]], data[nearest_zero_indices(data)[2]], 10)
indicies_time_range(data) = range(time[nearest_zero_indices(data)[1]], time[nearest_zero_indices(data)[2]], 10)

# filter_indices(data) = [last(nearest_zero_indices(data))[1], last(nearest_zero_indices(data))[2]]
# indicies_self_range(data) = range(data[filter_indices(data)[1]], data[filter_indices(data)[2]], 10)
# indicies_time_range(data) = range(time[filter_indices(data)[1]], time[filter_indices(data)[2]], 10)
# indicies_time_range(indices) = range(time[indicies[1]], time[indicies[2]], 10)

# interpolate subsection of values closest to the zero
BISECTIONS = 5
OVERSCAN_RADIUS = 5
global ynear::Vector{Int64} = []
global yitp::Vector{Float64} = []
global xitp::Vector{Float64} = x_positions
global titp::Vector{Float64} = time
global current_scope_data = y_positions

for i in 1:BISECTIONS
  # ynear contains the indices surrounding the sign change
  global ynear = nearest_zero_indices(current_scope_data)
  overscanleft = ynear[1]-OVERSCAN_RADIUS
  overscanright = ynear[1]+OVERSCAN_RADIUS
  global ynear = [clamp(overscanleft, 1, length(current_scope_data)), clamp(overscanright, 1, length(current_scope_data))] 

  global yitp = interpolate(current_scope_data, itp_method)(range(ynear[1], ynear[2], 10))
  global xitp = interpolate(xitp, itp_method)(range(ynear[1], ynear[2], 10))
  global titp = interpolate(titp, itp_method)(range(ynear[1], ynear[2], 10))
  global current_scope_data = yitp
end


# for i in 1:BISECTIONS
#   global ynear = nearest_zero_indices(current_scope_data)
  
#   println(ynear)
#   # println(ynear)
#   overscanleft = clamp(ynear[1]-OVERSCAN_RADIUS, 0, length(current_scope_data))
#   overscanright = clamp(ynear[2]+OVERSCAN_RADIUS, 0, length(current_scope_data))
  
#   # ynear contains the indices surrounding the sign change
#   global ynear = [overscanleft, overscanright] 
#   global yitp = interpolate(current_scope_data, itp_method)(ynear[1]:SAMPLESIZE:ynear[2])
#   global xitp = interpolate(xitp, itp_method)(ynear[1]:SAMPLESIZE:ynear[2])
#   global titp = interpolate(titp, itp_method)(ynear[1]:SAMPLESIZE:ynear[2])
#   global current_scope_data = yitp
# end


# SECTION FINDING NEAREST VALUE TO ZERO
min_val_abs, min_index_filtered = findmin(abs.(yitp[nearest_zero_indices(yitp)]))
min_index_absolute = nearest_zero_indices(yitp)[min_index_filtered]
time_at_second_zero = titp[min_index_absolute]

println("uncertainty in approximation of y-position zero: ", (yitp[ynear[1]], yitp[ynear[2]]))
println("Range: ", xitp[min_index_absolute])
println("Time: ", titp[min_index_absolute])

# SECTION PLOTTING
set_theme!(theme_dark())
fig = Figure(resolution=(800, 800))

ax11 = Axis(fig[1,1])
ax12 = Axis(fig[2,1])
# ax21 = Axis(fig[2,1])
# ax22 = Axis(fig[2,2])

# scatter!(ax11, interpolate(time, itp_method)(SAMPLERANGE), interpolate(y_positions, itp_method)(SAMPLERANGE))
scatter!(ax11, time, y_positions)
scatter!(ax12, titp, yitp)
scatter!(ax12, indicies_time_range(y_positions), indicies_self_range(y_positions))
# scatter!(ax22, indicies_time_range(y_velocities), indicies_self_range(y_velocities))
 
DataInspector(fig)
fig 
