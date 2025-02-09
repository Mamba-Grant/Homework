from iminuit.cost import LeastSquares
import pandas as pd
import matplotlib.pyplot as plt
import iminuit
import numpy as np

df = pd.read_csv("./Experiment 3 Data.csv", usecols=[3,4,10]) # type: ignore
df.columns = ['time', 'V_Supply', 'V_Capacitor']
df_rising = df[(df['time'] > 0) & (df['time'] < 0.0275)]
df_falling = df[(df['time'] >= 0.0275) & (df['time'] < np.inf )]

def charging_fcn(time, time_constant, Vs, V0) -> float:
    return (-Vs * np.exp(-time / time_constant) + V0)

def discharging_fcn(time, time_constant, Vs, V0) -> float:
    return (Vs * np.exp(-time / time_constant) + V0)

ls_charging = LeastSquares(
    df_rising['time'],
    df_rising['V_Capacitor'],
    1, # temporary unit error
    charging_fcn # type: ignore
)

m1 = iminuit.Minuit(ls_charging, time_constant=1, Vs=1, V0=1)
_ = m1.migrad()
_ = m1.hesse()

ls_discharging = LeastSquares(
    df_falling['time'],
    df_falling['V_Capacitor'],
    1, # temporary unit error
    discharging_fcn # type: ignore
)

m2 = iminuit.Minuit(ls_discharging, time_constant=1, Vs=1, V0=1)
_ = m2.migrad()
_ = m2.hesse()

fig, (ax1, ax2, ax3) = plt.subplots(3,1)
fig.subplots_adjust(hspace=0.5)

ax1.set_title("Raw Data")
ax1.set_xlabel("Time (ms)")
ax1.set_ylabel("Voltage (V)")
ax1.set_xticks(np.linspace(min(df['time']), max(df['time']), 10))
ax1.vlines([0, 0.0275, max(df['time'])], ymin=-6, ymax=6, colors=["#8d8d8d", "#8d8d8d"], linestyle='--')
ax1.plot(df['time'], df['V_Supply'], color='r')
ax1.plot(df['time'], df['V_Capacitor'], color='b')

ax2.set_title("Charging")
ax2.set_xlabel("Time (ms)")
ax2.set_ylabel("Voltage (V)")
ax2.set_xticks(np.linspace(min(df_rising['time']), max(df_rising['time']), 10))
ax2.grid()
ax2.plot(df_rising['time'], df_rising['V_Capacitor'])
x_fit = np.linspace(df_rising['time'].min(), df_rising['time'].max(), 100)
y_fit = charging_fcn(x_fit, *m1.values)
ax2.plot(x_fit, y_fit, color='r', linestyle="--", label='Charging Fit')

ax3.set_title("Discharging")
ax3.set_xlabel("Time (ms)")
ax3.set_ylabel("Voltage (V)")
ax3.set_xticks(np.linspace(min(df_falling['time']), max(df_falling['time']), 10))
ax3.grid()
ax3.plot(df_falling['time'], df_falling['V_Capacitor'])
x_fit = np.linspace(df_falling['time'].min(), df_falling['time'].max(), 100)
y_fit = discharging_fcn(x_fit, *m2.values)
ax3.plot(x_fit, y_fit, color='r', linestyle="--", label='Discharging Fit')

plt.show()
