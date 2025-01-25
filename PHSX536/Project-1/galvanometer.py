import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use("WebAgg")
from iminuit import Minuit

# Data preparation
data = {
    "Index": [999, 946, 893, 841, 788, 736, 683, 631, 578, 526, 473, 420, 368, 315, 263, 210, 157, 105, 52, 0],
    "Resistance_kohm": [5.037, 4.752, 4.494, 4.233, 3.959, 3.751, 3.431, 3.172, 2.902, 2.652, 2.379, 2.108, 1.834, 1.576, 1.321, 1.051, 0.7330, 0.5145, 0.248, 0.002],
    "Error_kohm": [0.454, 0.429, 0.405, 0.382, 0.357, 0.339, 0.310, 0.286, 0.262, 0.240, 0.215, 0.191, 0.166, 0.143, 0.120, 0.096, 0.06599, 0.04632, 0.0225, 0.003],
}
df = pd.DataFrame(data)

def line(x, a, b):
    """Linear model function."""
    return a + x * b

def chisq_cost(a, b):
    """Chi-square cost function for linear regression."""
    return np.sum(((df['Resistance_kohm'] - line(df['Index'], a, b))**2 / (df['Error_kohm']**2)))

# Perform Minuit minimization
m = Minuit(chisq_cost, a=0, b=0)
m.migrad()
m.hesse()

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(2, 1)

# First subplot: Original data with fit
ax1.errorbar(df['Index'], df['Resistance_kohm'], 
             yerr=df['Error_kohm'], 
             fmt='o', 
             color='darkblue', 
             label='Experimental Data')

x_fit = np.linspace(df['Index'].min(), df['Index'].max(), 100)
y_fit = line(x_fit, m.values[0], m.values[1])
ax1.plot(x_fit, y_fit, color='red', 
         label='Linear Fit')

ax1.text(0.05, 0.95, 
         f'$y = {m.values[1]:.4f}x + {m.values[0]:.4f}$\n'
         f'$a = {m.values[0]:.4f} \\pm {m.errors[0]:.4f}$\n'
         f'$b = {m.values[1]:.4f} \\pm {m.errors[1]:.4f}$', 
         transform=ax1.transAxes, 
         verticalalignment='top', 
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.5))

ax1.set_title('Galvanometer Resistance Data', fontsize=12)
ax1.set_xlabel('Index', fontsize=10)
ax1.set_ylabel('Resistance (kΩ)', fontsize=10)
ax1.legend()

# Second subplot: Contour plot of fit parameters
a_range = np.linspace(m.values[0] - 3*m.errors[0], m.values[0] + 3*m.errors[0], 100)
b_range = np.linspace(m.values[1] - 3*m.errors[1], m.values[1] + 3*m.errors[1], 100)
A, B = np.meshgrid(a_range, b_range)

Z = np.array([chisq_cost(a, b) for a, b in zip(A.flatten(), B.flatten())]).reshape(A.shape)

contour = ax2.contourf(A, B, Z, levels=20, cmap='viridis')
plt.colorbar(contour, ax=ax2)
ax2.set_title('Chi-Square Contour of Fit Parameters', fontsize=12)
ax2.set_xlabel('Intercept (a)', fontsize=10)
ax2.set_ylabel('Slope (b)', fontsize=10)
ax2.scatter(m.values[0], m.values[1], color='red', marker='x')

plt.tight_layout()
plt.show()
