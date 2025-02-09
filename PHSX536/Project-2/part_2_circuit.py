import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from iminuit import Minuit
from iminuit.cost import LeastSquares
from scipy import interpolate

# Load and process data
data = {
    "index": [999, 946, 893, 841, 788, 736, 683, 630, 578, 525, 473, 420, 368, 315, 262, 210, 157, 105, 52, 20, 10, 0],
    "current_mA": np.multiply([-0.47, -0.4, -0.42, -0.45, -0.48, -0.52, -0.55, -0.6, -0.65, -0.71, -0.79, -0.88, -1.01, -1.17, -1.39, -1.69, -2.24, -3.25, -5.7, -10.62, -14.44, -27.84], -1),
    "current_error_mA": [0.03, 0.03, 0.03, 0.03, 0.03, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.05, 0.05, 0.06, 0.09, 0.14, 0.17, 0.31],
    "voltage_V": [1.948, 1.952, 1.95, 1.949, 1.947, 1.944, 1.941, 1.939, 1.935, 1.931, 1.926, 1.92, 1.912, 1.9, 1.886, 1.867, 1.83, 1.763, 1.599, 1.272, 1.016, 0.115],
    "voltage_error_V": [0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.002, 0.001, 0.001, 0.001]
}
df = pd.DataFrame(data)

ltspice_data = pd.read_csv(
        "./simulation_data.txt", 
        sep=r'\s+', 
        header=0, 
        decimal='E', 
        index_col=False
    ).apply(pd.to_numeric, errors='coerce')

print(ltspice_data)

# Convert simulation currents to mA for comparison
ltspice_data['I(ISense)'] = ltspice_data['I(ISense)'] * 1000

def line(x, a, b):
    return np.multiply(a/1000, x) + b

# Fit experimental data
least_squares = LeastSquares(
    data['current_mA'],    
    data['voltage_V'],     
    data['current_error_mA'],
    line                   
)
m = Minuit(least_squares, a=1.0, b=0.0)
_ = m.migrad()
_ = m.hesse()

print(m)

# Fit statistics
chi2 = m.fval
ndof = len(data["index"]) - m.nfit

# Create equally spaced current values
current_min = min(data['current_mA'])
current_max = max(data['current_mA'])
n_points = 25  # Number of equally spaced points
current_resampled = np.linspace(current_min, current_max, n_points)

# Interpolate voltage values and errors
voltage_interpolator = interpolate.interp1d(data['current_mA'], data['voltage_V'])
voltage_error_interpolator = interpolate.interp1d(data['current_mA'], data['voltage_error_V'])

voltage_resampled = voltage_interpolator(current_resampled)
voltage_error_resampled = voltage_error_interpolator(current_resampled)

# Perform fit on resampled data
least_squares_resampled = LeastSquares(
    current_resampled,
    voltage_resampled,
    np.ones_like(current_resampled) * np.mean(data['current_error_mA']),  # Use mean error
    line
)
m_resampled = Minuit(least_squares_resampled, a=1.0, b=0.0)
_ = m_resampled.migrad()
_ = m_resampled.hesse()

# Fit simulation data
least_squares_sim = LeastSquares(
    ltspice_data['I(ISense)'],
    ltspice_data['V(n002)'],
    np.ones_like(ltspice_data['I(ISense)']) * 0.001,  # Assuming small error for simulation
    line
)
m_sim = Minuit(least_squares_sim, a=1.0, b=0.0)
_ = m_sim.migrad()
_ = m_sim.hesse()

sim_x_fit = np.linspace(min(ltspice_data['I(ISense)']), max(ltspice_data['I(ISense)']), 100)
sim_y_fit = line(sim_x_fit, m_sim.values[0], m_sim.values[1])

# Create figure with three subplots
fig, (ax1, ax3) = plt.subplots(1, 2)

x_fit = np.linspace(min(data['current_mA']), max(data['current_mA']), 100)
y_fit = line(x_fit, m.values[0], m.values[1])

# First subplot: Original experimental data with fit
ax1.errorbar(data['current_mA'], data['voltage_V'], 
             xerr=data['current_error_mA'],
             yerr=data['voltage_error_V'],
             capsize=5, fmt='o', color='darkblue', 
             label='Experimental Data')
ax1.plot(x_fit, y_fit, color='red', 
         label=f'Linear Fit\na={m.values[0]:.3f}±{m.errors[0]:.3f}\nb={m.values[1]:.3f}±{m.errors[1]:.3f}')
ax1.plot(sim_x_fit, sim_y_fit, color='green',
         label=f'Sim Fit\na={m_sim.values[0]:.3f}\nb={m_sim.values[1]:.3f}', linestyle="--")
ax1.set_title(f'Original Fit\nχ²/ndof = {chi2:.1f}/{ndof}')
ax1.set_xlabel('Current (mA)')
ax1.set_ylabel('Voltage (V)')
ax1.grid(True, linestyle='--', alpha=0.6)
ax1.legend()

# Third subplot: Resampled fit
ax3.errorbar(current_resampled, voltage_resampled,
             yerr=voltage_error_resampled,
             xerr=np.mean(data['current_error_mA']),
             capsize=5, fmt='o', color='purple',
             label='Resampled Data')
y_fit_resampled = line(x_fit, m_resampled.values[0], m_resampled.values[1])
ax3.plot(x_fit, y_fit_resampled, color='red',
         linestyle="--",
         label=f'Resampled Fit\na={m_resampled.values[0]:.3f}±{m_resampled.errors[0]:.3f}\nb={m_resampled.values[1]:.3f}±{m_resampled.errors[1]:.3f}')
ax3.plot(sim_x_fit, sim_y_fit, color='green',
         label=f'Sim Fit\na={m_sim.values[0]:.3f}\nb={m_sim.values[1]:.3f}', linestyle="--")
ax3.set_title('Resampled Fit')
ax3.set_xlabel('Current (mA)')
ax3.set_ylabel('Voltage (V)')
ax3.grid(True, linestyle='--', alpha=0.6)
ax3.legend()

plt.tight_layout()
plt.show()

print(f"Original fit resistance: {m.values[0]:.2f} ± {m.errors[0]:.2f} Ω")
print(f"Resampled fit resistance: {m_resampled.values[0]:.2f} ± {m_resampled.errors[0]:.2f} Ω")
sim_resistance = ltspice_data['V(n002)'] / (ltspice_data['I(ISense)'] / 1000)  # Convert back to A for resistance
print(f"Average simulated resistance: {sim_resistance.mean():.2f} Ω")
print(f"Experimental resistance (from fit): {m.values[0]:.2f} ± {m.errors[0]:.2f} Ω")
print(f"Simulation average resistance: {sim_resistance.mean():.2f} Ω")
