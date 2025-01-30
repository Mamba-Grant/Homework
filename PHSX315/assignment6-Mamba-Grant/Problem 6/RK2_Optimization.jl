using Interpolations, IMinuit, GLMakie, ColorTypes 

# SECTION DIFFEQ
TIMESTEP = 0.0005 
drag_coeff = 0.47
frontal_area = π * 0.053^2
v₀ = 150
x₀, y₀ = 0, 0
mass = 5
g = 9.8

# air_density(h) = 1.204*exp(-h / 10400)
air_density(h) = 1.204*exp((-h*0)+1 / 10400)
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

function approximate_range(initial_theta)
  
  # Decided to cheat a fair bit here, since very vertical angles cause a strange oob bug I could not fix.
  # Also, it's a fair assumption that very vertical angles will not have a very good range...
  if initial_theta > 80
    return 0
  end

  time_range = 0:TIMESTEP:25
  RK2_state_vectors = RK2_state(time_range, initial_theta)

  x_positions::Vector{Float64} = map(i -> i[3], RK2_state_vectors)
  y_positions::Vector{Float64} = map(i -> i[4], RK2_state_vectors)
  time::Vector{Float64} = map(i -> i[6], RK2_state_vectors)

  itp_method = BSpline(Quadratic(Reflect(OnCell())))

  # since this is a smooth continuous function win change should represent a zero
  function nearest_zero_indices(data)
    indices = []
    for i in 1:length(data)-1
      if sign(data[i]) != sign(data[i+1])
        append!(indices, [i, i+1])
      end
    end
    return [indices[end]-1, indices[end]]
  end
  indicies_self_range(data) = range(data[nearest_zero_indices(data)[1]], data[nearest_zero_indices(data)[2]], 10)
  indicies_time_range(data) = range(time[nearest_zero_indices(data)[1]], time[nearest_zero_indices(data)[2]], 10)

  # interpolate subsection of values closest to the zero
  BISECTIONS = 5
  OVERSCAN_RADIUS = 5
  ynear::Vector{Int64} = []
  yitp::Vector{Float64} = []
  xitp::Vector{Float64} = x_positions
  titp::Vector{Float64} = time
  current_scope_data = y_positions

  for i in 1:BISECTIONS
    # ynear contains the indices surrounding the sign change
    ynear = nearest_zero_indices(current_scope_data)
    overscanleft = ynear[1]-OVERSCAN_RADIUS
    overscanright = ynear[1]+OVERSCAN_RADIUS
    ynear = [clamp(overscanleft, 1, length(current_scope_data)), clamp(overscanright, 1, length(current_scope_data))] 

    yitp = interpolate(current_scope_data, itp_method)(range(ynear[1], ynear[2], 10))
    xitp = interpolate(xitp, itp_method)(range(ynear[1], ynear[2], 10))
    titp = interpolate(titp, itp_method)(range(ynear[1], ynear[2], 10))
    current_scope_data = yitp
  end


  # SECTION FINDING NEAREST VALUE TO ZERO
  min_val_abs, min_index_filtered = findmin(abs.(yitp[nearest_zero_indices(yitp)]))
  min_index_absolute = nearest_zero_indices(yitp)[min_index_filtered]

  # println("uncertainty in approximation of y-position zero: ", (yitp[ynear[1]], yitp[ynear[2]]))
  # println("Range: ", xitp[min_index_absolute])
  # println("Time: ", titp[min_index_absolute])

  return -xitp[min_index_absolute]
  # return (titp, yitp, xitp)
end

# Find maximum likelihood estimate and errors
m = Minuit(approximate_range, initial_theta=45)
migrad(m)
hesse(m)
m_values, m_errors = convert.(Vector{Float64}, (m.values, m.errors))

# # SECTION PLOTTING
# set_theme!(theme_dark())
# fig = Figure(resolution=(800, 800))

# ax1 = Axis(fig[1,1])
# ax2 = Axis(fig[2,1])

# p1 = RK2_state(0:TIMESTEP:25, 45)
# p2 = RK2_state(0:TIMESTEP:25, 10)
# p3 = RK2_state(0:TIMESTEP:25, 75)

# x_normalized = map(i -> i[1], p1) ./ maximum(map(i -> i[1], p1))
# y_normalized = map(i -> i[2], p1) ./ maximum(map(i -> i[2], p1))
# colors::Vector{RGB{Float32}} = [RGBf(x, y, 0) for (x, y) in zip(x_normalized, y_normalized)]


# lines!(ax1, map(i -> i[3], p1), map(i -> i[4], p1), color=colors, label="θ₀=45°")
# lines!(ax2, map(i -> i[6], p1), map(i -> i[1], p1), color=RGBf(1, 0, 0), label="x-velocity, θ₀=45°")
# lines!(ax2, map(i -> i[6], p1), map(i -> i[2], p1), color=RGBf(0, 1, 0), label="y_velocity, θ₀=45°")

# lines!(ax1, map(i -> i[3], p2), map(i -> i[4], p2), color=(:purple, 0.3), label="θ₀=10°")
# lines!(ax2, map(i -> i[6], p2), map(i -> i[1], p2), color=(:yellow, 0.3), label="x-velocity, θ₀=10°")
# lines!(ax2, map(i -> i[6], p2), map(i -> i[2], p2), color=(:blue, 0.3), label="y_velocity, θ₀=10°")

# lines!(ax1, map(i -> i[3], p3), map(i -> i[4], p3), color=(:orange, 0.3), label="θ₀=75°")
# lines!(ax2, map(i -> i[6], p3), map(i -> i[1], p3), color=(:white, 0.3), label="x-velocity, θ₀=75°")
# lines!(ax2, map(i -> i[6], p3), map(i -> i[2], p3), color=(:violet, 0.3), label="y_velocity, θ₀=75°")

# axislegend(ax1, position=:lb)
# axislegend(ax2, position=:lb)

# DataInspector(fig)
# fig 
# # save("../assets/RK2_Multiplot.png", fig, resolution=(720,720))

