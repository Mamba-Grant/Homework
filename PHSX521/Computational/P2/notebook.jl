### A Pluto.jl notebook ###
# v0.20.0

using Markdown
using InteractiveUtils

# ╔═╡ 8605c414-9c68-11ef-1bef-dda25fdea1c7
md"
# Problem 1

To get an accurate trajectory for a projectile, one must often take account of several complications. For example, if a projectile goes very high, then we have to allow for the reduction in air resistance as atmospheric density decreases. To illustrate this, consider an iron cannonball (diameter 15 cm, density 7.8 g/cm³) that is fired with an initial velocity of 300 m/s at 50 degrees above the horizontal. The drag force is approximately quadratic, but since the drag is proportional to the atmospheric density, and the density falls off exponentially with height, the drag force is 

$\mathbf{f} = -c(y) v^2 \hat{\mathbf{v}} = -c(y) |\mathbf{v}| \mathbf{v},$

where $c(y) = \gamma D^2 \exp(-y/\lambda)$, with $\gamma = 0.25 \, \text{Ns}^2/\text{m}^4$ and $\lambda \approx 10,000 \, \text{m}$. Note that the drag force depends on both the $x$ and $y$ components of the velocity, and that the drag force is always pointing in the direction opposite of the velocity.

Note that the drag force is not conservative, as it depends on $\mathbf{v}$. We therefore have to modify the Verlet algorithm slightly. One option would be 

$\mathbf{f} = \text{the total force}, \quad \mathbf{r} = \text{the position vector (with \(x\) and \(y\) coordinates)}, \quad \mathbf{v} = \text{the velocity vector (with components \(v_x\) and \(v_y\))}.$

The update rules are as follows:

$\mathbf{r}_\text{new} = \mathbf{r}_\text{old} + \mathbf{v}_\text{old} \Delta t + \frac{1}{2m} (\Delta t)^2 \mathbf{f}(\mathbf{r}_\text{old}, \mathbf{v}_\text{old}) \tag{1}$

$\mathbf{v}_\text{new, updated} = \mathbf{v}_\text{old} + \frac{1}{2m} \Delta t \left[\mathbf{f}(\mathbf{r}_\text{old}, \mathbf{v}_\text{old}) + \mathbf{f}(\mathbf{r}_\text{new}, \mathbf{v}_\text{updated})\right] \tag{2}$

$\mathbf{v}_\text{new} = \mathbf{v}_\text{old} + \frac{1}{2m} \Delta t \left[\mathbf{f}(\mathbf{r}_\text{old}, \mathbf{v}_\text{old}) + \mathbf{f}(\mathbf{r}_\text{new}, \mathbf{v}_\text{new, updated})\right] \tag{3}$

In the last term of line 2, we calculate the forces using the new positions (\(\mathbf{r}_\text{new}\)) using our best estimate of the new velocity, namely the old velocity (\(\mathbf{v}_\text{old}\)). This way we obtain an updated value for the new velocity (\(\mathbf{v}_\text{new, updated}\)). We then use that updated value to calculate the new velocity \(\mathbf{v}_\text{new}\) in line 3. Of course, there are many ways to optimize this procedure, but for our purposes this approximation will be sufficient.

## Tasks

- (a) Write down the equations of motion for the cannonball and use the Velocity Verlet algorithm described above to solve numerically for $x(t)$ and $y(t)$ for $0 < t < 60 \, \text{s}$. Plot the ball's trajectory and find its horizontal range.

- (b) Do the same calculation ignoring the variation of atmospheric density (that is, setting $c(y) = c(0)$).

- (c) Do (a) again, ignoring any air resistance.

- (d) Plot all three trajectories on the same graph, and discuss your results.

"

# ╔═╡ 6a003f4e-15d4-4734-8fec-434895936ef2
md"
# (a) Equations of Motion

We have equations of motion given by

$$F = \begin{pmatrix} m \ddot{x}  \\ m\ddot{y} \end{pmatrix} = \begin{pmatrix}
-f_{D,~x}  \\
-mg-f_{D,~y}
\end{pmatrix} = \begin{pmatrix}
c(y)|\mathbf{v}|\dot{x}  \\
-mg -c(y)|\mathbf{v}|\dot{y}
\end{pmatrix}$$

$c(y) = \gamma D^2 \exp(-y/\lambda)$
with $\gamma = 0.25 \, \text{Ns}^2/\text{m}^4$ and $\lambda \approx 10,000 \, \text{m}$.

"

# ╔═╡ 6bed3e89-c81b-4ad4-ab05-aa605e0a43c5


# ╔═╡ Cell order:
# ╟─8605c414-9c68-11ef-1bef-dda25fdea1c7
# ╟─6a003f4e-15d4-4734-8fec-434895936ef2
# ╠═6bed3e89-c81b-4ad4-ab05-aa605e0a43c5
