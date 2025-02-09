import os
from typing import Any
from iminuit.util import NDArray
import numpy as np
from numpy.typing import ArrayLike
import pandas as pd
import matplotlib.pyplot as plt
from iminuit import Minuit

data = {
    "Index": [0, 52, 105, 157, 210, 262, 315, 368, 420, 473, 525, 578, 630, 683, 736, 788, 841, 893, 946, 999],
    "Resistance_kohm": [0.0022, 0.2773, 0.5496, 0.818, 1.085, 1.362, 1.614, 1.905, 2.16, 2.425, 2.689, 2.964, 3.222, 3.498, 3.758, 4.052, 4.302, 4.579, 4.826, 5.065],
    "Error_kohm": np.multiply(0.1, [0.0004, 0.0252, 0.0497, 0.08, 0.098, 0.123, 0.146, 0.171, 0.195, 0.219, 0.243, 0.268, 0.291, 0.316, 0.34, 0.365, 0.388, 0.413, 0.435, 0.457])
}
df = pd.DataFrame(data)

def line(x: ArrayLike, a: float, b: float) -> NDArray[np.floating[Any]]:
    """Linear model function."""
    return a + np.multiply(x, b)


def chisq_cost(a: float, b: float) -> float:
    """Chi-square cost function for linear regression."""
    return np.sum(((df['Resistance_kohm'] - line(df['Index'], a, b))**2 / (df['Error_kohm']**2)))

# Perform Minuit minimization
m = Minuit(chisq_cost, a=0, b=0)
_ = m.migrad()
_ = m.hesse()

print(m)

# Fit Statistics
chi2 = m.fval  # χ² value
ndof = len(data["Index"]) - m.nfit  # ndof = N_data - N_parameters

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2)

# First subplot: Original data with fit
ax1.errorbar(df['Index'], df['Resistance_kohm'], 
             yerr=df['Error_kohm'], 
             capsize=5,
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

ax1.set_title('Potentiometer Resistance Data', fontsize=12)
ax1.set_xlabel('Index', fontsize=10)
ax1.set_ylabel('Resistance (kΩ)', fontsize=10)
ax1.legend(title=f"χ²/ndof = {(chi2/ndof):.2f}")

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
