import numpy as np
import matplotlib.pyplot as plt
from iminuit import Minuit
from iminuit.cost import LeastSquares

def generate_random_walk(walk_length):
    rng = np.random.default_rng()
    route = np.cumsum((rng.integers(-1, 0, size=walk_length, endpoint=True) + 0.5) * 2)
    return route

def run_multiple_walks(walk_length, num_walks):
    endpoints = []
    for _ in range(num_walks):
        walk = generate_random_walk(walk_length)
        endpoints.append(walk[-1])
    return endpoints

# Parameters
walk_length = 1000
num_walks = 10000
n_bins = 30
binomValues = [0, np.sqrt(walk_length)]

endpoints = run_multiple_walks(walk_length, num_walks)

hist, bin_edges = np.histogram(endpoints, bins=n_bins, density=True)
bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
bin_widths = np.diff(bin_edges)

def gaussian(x, mu, sigma):
    return (1/np.sqrt(2*np.pi*sigma**2)) * np.exp(-(x - mu)**2 / (2 * sigma**2))

# Perform the fit, minuit converges better with large sigma
least_squares = LeastSquares(bin_centers, hist, np.sqrt(hist), gaussian)
m = Minuit(least_squares, mu=0, sigma=50)
m.migrad()
m.hesse()

# Plotting
plt.figure(figsize=(10, 6))
plt.hist(endpoints, bins=n_bins, density=True, alpha=0.7, label='Data')
x_plot = np.linspace(min(bin_centers), max(bin_centers), 1000)
plt.plot(x_plot, gaussian(x_plot, *m.values), 'r-', label='Least Squares Fit')
plt.plot(x_plot, gaussian(x_plot, *binomValues), label='Binomial Approximation')
plt.xlabel('Value')
plt.ylabel('Probability Density')
plt.legend()
plt.title(f'Random Walk 1D - {num_walks} Walks - {walk_length} Walk Length - {n_bins} Bins')

# Print fit results
print("Percent Difference (Fit vs Binomial):")
for param, v1, v2 in zip(m.parameters, m.values, binomValues):
    pDiff = np.absolute(v1 - v2) / ((v1+v2)/2)
    print(f"{param}: {pDiff:.3f}%")

plt.show()
