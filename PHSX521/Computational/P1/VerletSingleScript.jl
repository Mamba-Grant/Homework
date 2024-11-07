using GLMakie

# This is a bit unique to Julia, this just defines a mutable struct initialized with kwargs which represents the state of the system. It's kinda like a state vector which I update with each time step.
Base.@kwdef mutable struct Newtonian
	dt::Float64 = 0.001
	# ϕ::Float64 = π/2
	ϕ::Float64 = 0.349
	dϕ::Float64 = 0.0
	ddϕ::Float64 = 0.0
	R::Float64 = 5
	g::Float64 = 9.8
end

# The step function where we implement the verlet velocity algorithm.
function step!(n::Newtonian)
	# Define the acceleration ddϕ after the time step. This is just given by force. Afterwards we use this result to compute position for the next step in time.
	ddϕ = -n.g/n.R * sin(n.ϕ)
	n.ϕ+= n.dt*n.dϕ + 0.25*(n.dt)^2 * (ddϕ+n.ddϕ)
	
	# I override the old velocity/acceleration after we compute dϕ intentionally
	n.dϕ += n.dt * 0.5 * (ddϕ + n.ddϕ)
	n.ddϕ = ddϕ 

	# This is constructed in polar coordinates, and I tell Makie (the plotting backend) this later.
	Point2f(n.ϕ, n.R)
end

function stepSmallApprox!(n::Newtonian)
    # Natural frequency of the pendulum
    ω = sqrt(n.g / n.R)
    
    # Using the analytical solution for simple harmonic motion with the small-angle approximation
    ϕ_new = n.ϕ * cos(ω * n.dt) + (n.dϕ / ω) * sin(ω * n.dt)
    dϕ_new = n.dϕ * cos(ω * n.dt) - n.ϕ * ω * sin(ω * n.dt)
    
    # Update the system's state
    n.ϕ = ϕ_new
    n.dϕ = dϕ_new
    
    # Return the position in polar coordinates (angle, radius)
    Point2f(n.ϕ, n.R)
end

begin 
	# Initially set system points and colors to Nothing. Julia has a quirk where everything happens in the REPL, so all variables are preserved between runs. This is handy for certain things, but in this case it will just make the simulation horrendous. Setting them to nothing clears them.
	system = Nothing
	points = Nothing
	colors = Nothing

	# Now we initialize the system, and arrays for points and the color of each point for the animation
	system = Newtonian(ϕ = 0.349)
	points = Observable(Point2f[])
	colors = Observable(Int[])

	set_theme!(theme_black()) # Dark theme for prettyness
end

begin 
	# Initially set system points and colors to Nothing. Julia has a quirk where everything happens in the REPL, so all variables are preserved between runs. This is handy for certain things, but in this case it will just make the simulation horrendous. Setting them to nothing clears them.
	system_analytical = Nothing
	points_analytical = Nothing
	colors_analytical = Nothing
	
	# Now we initialize the system, and arrays for points and the color of each point for the animation
	system_analytical = Newtonian()
	points_analytical = Observable(Point2f[])
	colors_analytical = Observable(Int[])
end

# Initialize the canvas and axes. We choose to render the animation using lines with the inferno colormap. Axes are initialized in polar coordinates.
fig, ax, n = lines(points, color = colors,
	colormap = :inferno, transparency = true,
	axis = (; type = PolarAxis, rlimits = (0, 6), theta_0 = -pi/2))

# Step through 120 frames at a rate of 30 frames/second. Each frame calls step on the system and updates the various state vectors.
record(fig, "newton.mp4", 1:120) do frame
    for i in 1:60
        push!(points[], stepSmallApprox!(system))
        push!(colors[], frame)
    end
    notify(points)
    notify(colors)
    n.colorrange = (0, frame)
end
