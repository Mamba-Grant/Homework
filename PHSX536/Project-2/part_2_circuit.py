import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from iminuit import Minuit
from iminuit.cost import LeastSquares

# Corrected data dictionary - make all errors positive
data = {
    "index": [999, 946, 893, 841, 788, 736, 683, 630, 578, 525, 473, 420, 368, 315, 262, 210, 157, 105, 52, 20, 10, 0],
    "current_mA": np.multiply([-0.47, -0.4, -0.42, -0.45, -0.48, -0.52, -0.55, -0.6, -0.65, -0.71, -0.79, -0.88, -1.01, -1.17, -1.39, -1.69, -2.24, -3.25, -5.7, -10.62, -14.44, -27.84], -1),
    "current_error_mA": [0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.032, 0.031, 0.031, 0.028, 0.024, 0.029, 0.027, 0.016, 0.023, 0.005],
    "voltage_V": [1.948, 1.952, 1.95, 1.949, 1.947, 1.944, 1.941, 1.939, 1.935, 1.931, 1.926, 1.92, 1.912, 1.9, 1.886, 1.867, 1.83, 1.763, 1.599, 1.272, 1.016, 0.115],
    "voltage_error_V": [0.019, 0.019, 0.019, 0.019, 0.019, 0.018, 0.018, 0.018, 0.018, 0.018, 0.018, 0.018, 0.018, 0.018, 0.018, 0.016, 0.015, 0.017, 0.015, 0.0011, 0.0092, 0.002]
}

df = pd.DataFrame(data)

def line(x, a, b):
    return np.multiply(a, x) + b

least_squares = LeastSquares(
    data['current_mA'],    
    data['voltage_V'],     
    data['current_error_mA'],
    line                   
)

# Create Minuit object with the least squares cost function
m = Minuit(least_squares, a=1.0, b=0.0)
_ = m.migrad()
_ = m.hesse()

# Fit Statistics
chi2 = m.fval
ndof = len(data["index"]) - m.nfit

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# First subplot: Original data with fit
ax1.errorbar(data['current_mA'], data['voltage_V'], 
             xerr=data['current_error_mA'],
             yerr=data['voltage_error_V'],
             capsize=5,
             fmt='o', 
             color='darkblue', 
             label='Experimental Data')

# Correct x_fit range using current values
x_fit = np.linspace(min(data['current_mA']), max(data['current_mA']), 100)
y_fit = line(x_fit, m.values[0], m.values[1])

ax1.plot(x_fit, y_fit, color='red', 
         label=f'Linear Fit\na={m.values[0]:.3f}±{m.errors[0]:.3f}\nb={m.values[1]:.3f}±{m.errors[1]:.3f}')

ax1.hlines(0.0, min(data['current_mA']), max(data['current_mA']))

ax1.set_title(f'Galvanometer Resistance Data\nχ²/ndof = {chi2:.1f}/{ndof}', fontsize=12)
ax1.set_xlabel('Current (mA)', fontsize=10)
ax1.set_ylabel('Voltage (V)', fontsize=10)
ax1.legend()

# Second subplot: Residuals
residuals = data['voltage_V'] - line(data['current_mA'], m.values[0], m.values[1])
ax2.errorbar(data['current_mA'], residuals,
             yerr=data['voltage_error_V'],
             xerr=data['current_error_mA'],
             capsize=5,
             fmt='o',
             color='darkblue')

ax2.axhline(y=0, color='red', linestyle='--')
ax2.set_title('Residuals', fontsize=12)
ax2.set_xlabel('Current (mA)', fontsize=10)
ax2.set_ylabel('Voltage Residuals (V)', fontsize=10)

plt.tight_layout()
plt.show()
