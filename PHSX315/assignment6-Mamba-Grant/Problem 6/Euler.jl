@time using GLMakie, ColorTypes

TIMESTEP = 0.5
const drag_coefficient = 0.47
const frontal_area = π * 0.053^2
const θ₀ = 45
const v₀ = 150
const x₀, y₀ = 0, 0
const vx₀, vy₀ = v₀ * cos(deg2rad(θ₀)), v₀ * sin(deg2rad(θ₀))
const m = 5
const g = 9.8

air_density(h) = 1.204*exp(-h / 10400)
b(h) = 0.5*air_density(h)*frontal_area*drag_coefficient

Fx(v, θ, h) = ( -b(h) * v^2 * cos(deg2rad(θ)) ) / m
Fy(v, θ, h) = ( -(m * g) - (b(h) * v^2) * sin(deg2rad(θ)) ) / m

time_range = 1:TIMESTEP:25
@time euler_state_vectors = let t=step(time_range), vx=vx₀, vy=vy₀, x=x₀, y=y₀, θ=θ₀
  map(time_range) do timestep
    vx += (t * Fx(vx, θ, y) )
    vy += (t * Fy(vy, θ, y) )
    x += (t * vx )
    y += (t * vy )
    θ = rad2deg(atan(vy/vx))

    (vx, vy, x, y, θ, timestep)
  end
end

# Add the initial values back in and fix time range
pushfirst!(euler_state_vectors, (vx₀, vy₀, x₀, y₀, θ₀, 0))
time_range = 0:1:length(euler_state_vectors)-1

x_velocities::Vector{Float64} = map(i -> i[1], euler_state_vectors)
y_velocities::Vector{Float64} = map(i -> i[2], euler_state_vectors)
x_positions::Vector{Float64} = map(i -> i[3], euler_state_vectors)
y_positions::Vector{Float64} = map(i -> i[4], euler_state_vectors)

x_normalized = x_velocities ./ maximum(x_velocities)
y_normalized = y_velocities ./ maximum(y_velocities)
colors::Vector{RGB{Float32}} = [RGBf(x, y, 0) for (x, y) in zip(x_normalized, y_normalized)]

set_theme!(theme_black())
f = Figure(resolution=(720, 720))
ax1 = Axis(f[1, 1], title = "Euler", xlabel="x-position", ylabel="y-position", yticks=-500:250:500)
ax2 = Axis(f[2, 1], xlabel = "Time", ylabel="velocity", xticks=-10:5:40)
pos = scatter!(ax1, x_positions, y_positions, label="Position", color=colors)
vel1 = scatter!(ax2, time_range.*TIMESTEP, x_velocities, label="x-velocity", color=RGBf(1, 0, 0))
vel2 = scatter!(ax2, time_range.*TIMESTEP, y_velocities, label="y-velocity", color=RGBf(0, 1, 0))

axislegend(ax1, position=:lb)
axislegend(ax2, position=:lb)

DataInspector(f)
# save("../assets/Euler.png", f, resolution=(720,720))
f
