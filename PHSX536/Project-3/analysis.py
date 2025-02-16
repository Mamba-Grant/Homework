import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

# Load and prepare data
df = pd.read_csv("./Experiment 3 Data.csv", usecols=[3,4,10])
df_sim = pd.read_csv("./simulation data.txt", sep="\t")
df.columns = ['time', 'V_Supply', 'V_Capacitor']

df["verr_supply"] = np.abs(df["V_Supply"] * 0.01)
df["verr_capacitor"] = np.abs(df["V_Capacitor"] * 0.01)
df_rising = df[(df['time'] > 0) & (df['time'] < 0.0275)]
df_falling = df[(df['time'] >= 0.0275) & (df['time'] < np.inf)]
df_rising_sim = df_sim[(df_sim['time'] > 0.0275) & (df_sim['time'] < 0.0275*2)] - 0.0275
df_falling_sim = df_sim[(df_sim['time'] >= 0) & (df_sim['time'] < 0.0275)] + 0.0275

def charging_fcn(time, time_constant, Vs, V0):
    exp_term = np.clip(-time / time_constant, -100, 100)
    return (-Vs * np.exp(exp_term) + V0)

def discharging_fcn(time, time_constant, Vs, V0):
    exp_term = np.clip(time / time_constant, -100, 100)
    return (Vs * np.exp(-exp_term) + V0)

# Fit curves using scipy.optimize.curve_fit
p0 = [1e-3, 5, 5]  # Initial parameter guess
# bounds = ([0, 0, 0], [np.inf, 10, 10])  # Parameter bounds
bounds = ([0, -np.inf, -np.inf], [np.inf, np.inf, np.inf])

# Measured data fits
popt_charging, pcov_charging = curve_fit(
    charging_fcn, 
    df_rising['time'], 
    df_rising['V_Capacitor'],
    p0=p0,
    bounds=bounds,
    sigma=df_rising['verr_capacitor'] + 0.1
)

popt_discharging, pcov_discharging = curve_fit(
    discharging_fcn,
    df_falling['time'],
    df_falling['V_Capacitor'],
    p0=p0,
    bounds=bounds,
    sigma=df_falling['verr_capacitor'] + 3
)

# Simulation data fits
popt_charging_sim, pcov_charging_sim = curve_fit(
    charging_fcn,
    df_rising_sim['time'],
    df_rising_sim['V(out)'],
    p0=p0,
    bounds=bounds
)

popt_discharging_sim, pcov_discharging_sim = curve_fit(
    discharging_fcn,
    df_falling_sim['time'],
    df_falling_sim['V(out)'],
    p0=p0,
    bounds=bounds
)

plt.style.use('seaborn-v0_8')
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(12, 14))
fig.subplots_adjust(hspace=0.3)

plot_params = {
    'grid_color': '#E5E5E5',
    'grid_alpha': 0.5,
    'data_alpha': 0.6,
    'line_width': 2,
}

# Raw Data Plot
ax1.set_title("Raw Voltage Data", pad=20, fontsize=14, fontweight='bold')
ax1.set_xlabel("Time (ms)", fontsize=12)
ax1.set_ylabel("Voltage (V)", fontsize=12)
ax1.grid(color=plot_params['grid_color'], alpha=plot_params['grid_alpha'], linestyle='--')
ax1.vlines([0, 0.0275, max(df['time'])], ymin=-6, ymax=6, colors=["#8d8d8d"], linestyle='--', alpha=0.5)
ax1.plot(df['time'], df['V_Supply'], color='#FF6B6B', label='Measured Supply', linewidth=plot_params['line_width'])
ax1.plot(df['time'], df['V_Capacitor'], color='#4A90E2', label='Measured Capacitor', linewidth=plot_params['line_width'])
ax1.plot(df_sim['time']-0.0275, df_sim['V(in)'], color='#2ECC71', label="Simulated Supply", linewidth=plot_params['line_width'])
ax1.plot(df_sim['time']-0.0275, df_sim['V(out)'], color='#50C878', label="Simulated Capacitor", linewidth=plot_params['line_width'])
ax1.set_xlim([-0.045, 0.053])
ax1.legend(framealpha=0.95, fontsize=10)

# Charging Plot
ax2.set_title("Capacitor Charging Curve", pad=20, fontsize=14, fontweight='bold')
ax2.set_xlabel("Time (ms)", fontsize=12)
ax2.set_ylabel("Voltage (V)", fontsize=12)
ax2.grid(color=plot_params['grid_color'], alpha=plot_params['grid_alpha'], linestyle='--')

ax2.errorbar(df_rising['time'], df_rising['V_Capacitor'],
             yerr=df_rising["verr_capacitor"],
             fmt='o', alpha=plot_params['data_alpha'],
             color='#4A90E2', label='Measured Data',
             markersize=4, elinewidth=1)

ax2.scatter(df_rising_sim['time'], df_rising_sim['V(out)'],
            color='#50C878', alpha=plot_params['data_alpha'],
            s=30, label='Simulation Data')

x_fit = np.linspace(df_rising['time'].min(), df_rising['time'].max(), 200)
y_fit = charging_fcn(x_fit, *popt_charging)
fit_label = f'Measured Fit (τ={popt_charging[0]:.2e}s, Vs={popt_charging[1]:.1f}V, V0={popt_charging[2]:.1f}V)'
ax2.plot(x_fit, y_fit, color='#FF6B6B', linewidth=plot_params['line_width'], label=fit_label)

x_fit = np.linspace(df_rising_sim['time'].min(), df_rising_sim['time'].max(), 200)
y_fit = charging_fcn(x_fit, *popt_charging_sim)
sim_fit_label = f'Simulation Fit (τ={popt_charging_sim[0]:.2e}s, Vs={popt_charging_sim[1]:.1f}V, V0={popt_charging_sim[2]:.1f}V)'
ax2.plot(x_fit, y_fit, color='#2ECC71', linewidth=plot_params['line_width'], label=sim_fit_label)

ax2.legend(framealpha=0.95, fontsize=10)

# Discharging Plot
ax3.set_title("Capacitor Discharging Curve", pad=20, fontsize=14, fontweight='bold')
ax3.set_xlabel("Time (ms)", fontsize=12)
ax3.set_ylabel("Voltage (V)", fontsize=12)
ax3.grid(color=plot_params['grid_color'], alpha=plot_params['grid_alpha'], linestyle='--')

ax3.errorbar(df_falling['time'], df_falling['V_Capacitor'],
             yerr=df_falling["verr_capacitor"],
             fmt='o', alpha=plot_params['data_alpha'],
             color='#4A90E2', label='Measured Data',
             markersize=4, elinewidth=1)

ax3.scatter(df_falling_sim['time'], df_falling_sim['V(out)'],
            color='#50C878', alpha=plot_params['data_alpha'],
            s=30, label='Simulation Data')

x_fit = np.linspace(df_falling['time'].min(), df_falling['time'].max(), 200)
y_fit = discharging_fcn(x_fit, *popt_discharging)
fit_label = f'Measured Fit (τ={popt_discharging[0]:.2e}s, Vs={popt_discharging[1]:.1f}V, V0={popt_discharging[2]:.1f}V)'
ax3.plot(x_fit, y_fit, color='#FF6B6B', linewidth=plot_params['line_width'], label=fit_label)

x_fit = np.linspace(df_falling_sim['time'].min(), df_falling_sim['time'].max(), 200)
y_fit = discharging_fcn(x_fit, *popt_discharging_sim)
sim_fit_label = f'Simulation Fit (τ={popt_discharging_sim[0]:.2e}s, Vs={popt_discharging_sim[1]:.1f}V, V0={popt_discharging_sim[2]:.1f}V)'
ax3.plot(x_fit, y_fit, color='#2ECC71', linewidth=plot_params['line_width'], label=sim_fit_label)

ax3.legend(framealpha=0.95, fontsize=10)

# Print fit parameters and their errors (standard deviations) for each curve fit

def print_fit_results(popt, pcov, fit_type):
    print(f"{fit_type} Fit Parameters (τ, Vs, V0):")
    print(f"Time Constant (τ): {popt[0]:.2e} s ± {np.sqrt(pcov[0, 0]):.2e} s")
    print(f"Supply Voltage (Vs): {popt[1]:.1f} V ± {np.sqrt(pcov[1, 1]):.1f} V")
    print(f"Initial Voltage (V0): {popt[2]:.1f} V ± {np.sqrt(pcov[2, 2]):.1f} V")
    print()

# Measured Charging Fit
print_fit_results(popt_charging, pcov_charging, "Measured Charging")

# Measured Discharging Fit
print_fit_results(popt_discharging, pcov_discharging, "Measured Discharging")

# Simulation Charging Fit
print_fit_results(popt_charging_sim, pcov_charging_sim, "Simulation Charging")

# Simulation Discharging Fit
print_fit_results(popt_discharging_sim, pcov_discharging_sim, "Simulation Discharging")


plt.tight_layout()
plt.savefig("./output/", dpi=300, bbox_inches='tight')
plt.show()
