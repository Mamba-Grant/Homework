import os
import matplotlib.pyplot as plt
import matplotlib
import pandas as pd

data_dir = "./LTSpice Data/"

ltspice_data = {
    filename: pd.read_csv(
        os.path.join(data_dir, filename), 
        sep=r'\s+', 
        header=0, 
        decimal='E', 
        index_col=False
    ).apply(pd.to_numeric, errors='coerce')
    for filename in os.listdir(data_dir)
}

specifications = {
    "9.txt": (-5e-3, 5e-3),       # 9 Ω, ±5 mA
    "90.txt": (-500e-6, 500e-6),  # 90 Ω, ±500 μA
    "900.txt": (-50e-6, 50e-6)    # 900 Ω, ±50 μA
}

filtered_data = {
    filename: df.loc[df["I(VSense)"].between(*spec_range)]
    for filename, spec_range in specifications.items()
    if (df := ltspice_data.get(filename)) is not None
}

ltspice_data_9ohm = filtered_data.get("9.txt", pd.DataFrame())
ltspice_data_90ohm = filtered_data.get("90.txt", pd.DataFrame())
ltspice_data_900ohm = filtered_data.get("900.txt", pd.DataFrame())
ltspice_data = pd.concat([ltspice_data_900ohm, ltspice_data_90ohm, ltspice_data_9ohm])
ltspice_data = ltspice_data.sort_values(by="rx").reset_index(drop=True)

for key, df in filtered_data.items():
    print(f"{key}: {df.shape[0]} rows after filtering")


index = [0, 200, 260, 310, 360, 370, 390, 400, 410, 430, 500, 600, 700, 800, 999]
current = [1600, 380, 220, 140, 37, 18, 10, 0, -10, -28, -100, -180, -220, -280, -360]
error = [100, 10, 10, 10, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 10]

def galvanometer_fit(index) -> float: 
    return 5e-3 * index + 17e-3

resistance = [galvanometer_fit(x) for x in index]

print(resistance)

plt.figure(figsize=(10, 6))
plt.errorbar(resistance, current, yerr=error, fmt='o', capsize=5, label='Current with Error', color='b')

plt.plot(ltspice_data["rx"] / 1e3, ltspice_data["I(VSense)"] * 1e6, label="LTSpice Simulation", color='r')

plt.title("Current vs. Resistance", fontsize=14)
plt.xlabel("Resistance ($k\\Omega$)", fontsize=12)
plt.ylabel("Current ($\\mu$A)", fontsize=12)  # Corrected LaTeX formatting
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()
plt.show()
