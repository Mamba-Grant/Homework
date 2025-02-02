import os
from typing import Any
from iminuit.util import NDArray
import numpy as np
from numpy.typing import ArrayLike
import pandas as pd
import matplotlib.pyplot as plt
from iminuit import Minuit

columns = ["Index", 'Resistance_kohm', "Error_kohm"]
df = pd.read_csv("./potDat.txt", sep=r'\t', names=columns)
# print(df)

def line(x: ArrayLike, a: float, b: float) -> NDArray[np.floating[Any]]:
    """Linear model function."""
    return a + np.multiply(x, b)

def quadratic(x: ArrayLike, a: float, b: float, c: float) -> NDArray[np.floating[Any]]:
    """Quadratic model function."""
    return a + np.multiply(x, b) + np.multiply(x**2, c)

def chisq_cost_line(a: float, b: float) -> float:
    """Chi-square cost function for linear regression."""
    return np.sum(((df['Resistance_kohm'] - line(df['Index'], a, b))**2 / (df['Error_kohm']**2)))

def chisq_cost_quad(a: float, b: float, c: float) -> float:
    """Chi-square cost function for quadratic regression."""
    return np.sum(((df['Resistance_kohm'] - quadratic(df['Index'], a, b, c))**2 / (df['Error_kohm']**2)))

# Perform Minuit minimization for linear fit
m_line = Minuit(chisq_cost_line, a=0, b=0)
m_line.migrad()
m_line.hesse()

# Perform Minuit minimization for quadratic fit
m_quad = Minuit(chisq_cost_quad, a=0, b=0, c=0)
m_quad.migrad()
m_quad.hesse()

# print(m_line)
# print(m_quad)

# Fit Statistics
chi2_line = m_line.fval  # χ² value for linear fit
ndof_line = len(df["Index"]) - m_line.nfit  # ndof = N_data - N_parameters

chi2_quad = m_quad.fval  # χ² value for quadratic fit
ndof_quad = len(df["Index"]) - m_quad.nfit

# Create figure
fig, ax = plt.subplots()

# Plot original data with errors
ax.errorbar(df['Index'], df['Resistance_kohm'], 
             yerr=df['Error_kohm'], 
             capsize=5,
             fmt='o', 
             color='darkblue', 
             label='Experimental Data')

# Generate fit lines
x_fit = np.linspace(df['Index'].min(), df['Index'].max(), 100)
y_fit_line = line(x_fit, m_line.values[0], m_line.values[1])
y_fit_quad = quadratic(x_fit, m_quad.values[0], m_quad.values[1], m_quad.values[2])

# Plot fits
ax.plot(x_fit, y_fit_line, color='red', linestyle='dashed', label='Linear Fit')
ax.plot(x_fit, y_fit_quad, color='green', linestyle='dashed', label='Quadratic Fit')

# Fit parameters text
ax.text(0.05, 0.95, 
         f'Linear Fit:\n$y = {m_line.values[1]:.4f}x + {m_line.values[0]:.4f}$\n'
         f'$\chi^2/ndof = {(chi2_line/ndof_line):.2f}$\n'
         f'Quadratic Fit:\n$y = {m_quad.values[2]:.4f}x^2 + {m_quad.values[1]:.4f}x + {m_quad.values[0]:.4f}$\n'
         f'$\chi^2/ndof = {(chi2_quad/ndof_quad):.2f}$',
         transform=ax.transAxes, 
         verticalalignment='top', 
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.5))

ax.set_title('Galvanometer Resistance Data', fontsize=12)
ax.set_xlabel('Index', fontsize=10)
ax.set_ylabel('Resistance (Ω)', fontsize=10)
ax.legend()

plt.show()
